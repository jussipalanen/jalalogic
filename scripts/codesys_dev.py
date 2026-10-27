# JalaLogic Lite - CODESYS automation script used by ./dev
# Simulation-only educational project. Not a certified safety function.
#
# Runs inside CODESYS (IronPython 2.7), started by scripts/run_codesys.cmd:
#   CODESYS.exe --profile="..." --noUI --runscript="scripts\codesys_dev.py"
#
# Settings come from environment variables set by ./dev:
#   DEV_MODE  build = build the application, do not change the project
#             sync  = copy src/*.st into the project, build, save if no errors
#   DEV_ROOT  repository root (Windows path)
#
# The last output line is "DEV_RESULT: OK" or "DEV_RESULT: FAILED".
from __future__ import print_function

import io
import os
import re
import traceback

import scriptengine

MODE = os.environ.get("DEV_MODE", "")
ROOT = os.environ.get("DEV_ROOT", "")
PROJECT_PATH = os.path.join(ROOT, "codesys", "JalaLogicLite.project")
SOURCE_DIRS = [os.path.join(ROOT, "src", "DUTs"), os.path.join(ROOT, "src", "POUs")]
IMPLEMENTATION_MARKER = "// IMPLEMENTATION PART"


def read_lines(path):
    with io.open(path, "r", encoding="utf-8-sig") as source:
        return source.read().replace("\r\n", "\n").split("\n")


def split_source(lines):
    """Return (declaration, implementation) of a src/*.st file.

    The whole file is kept, comments included, so the project and src/
    stay identical. The implementation starts at the banner line above
    "// IMPLEMENTATION PART"; everything before it is the declaration.
    DUT files have no implementation (None).
    """
    marker = None
    for index, line in enumerate(lines):
        if line.strip() == IMPLEMENTATION_MARKER:
            marker = index
            break

    if marker is None:
        return "\r\n".join(lines).strip(), None
    split = marker - 1
    declaration = "\r\n".join(lines[:split]).strip()
    implementation = "\r\n".join(lines[split:]).strip()
    return declaration, implementation


def normalize(text):
    lines = (text or "").replace("\r\n", "\n").split("\n")
    return "\n".join(line.rstrip() for line in lines).strip()


def find_object(project, name):
    # Task calls share the POU name (MainTask > PLC_PRG) but hold no code.
    found = [obj for obj in project.find(name, True) if obj.has_textual_declaration]
    if not found:
        raise RuntimeError("Object '%s' not found in the project" % name)
    if len(found) > 1:
        raise RuntimeError("Object name '%s' is not unique in the project" % name)
    return found[0]


def replace_if_changed(document, new_text):
    if normalize(document.text) == normalize(new_text):
        return False
    document.replace(new_text)
    return True


def sync_sources(project):
    """Copy every src/*.st file into the object with the same name.

    Return the number of objects that changed.
    """
    changed_objects = 0
    for directory in SOURCE_DIRS:
        for file_name in sorted(os.listdir(directory)):
            if not file_name.endswith(".st"):
                continue
            name = file_name[:-3]
            declaration, implementation = split_source(read_lines(os.path.join(directory, file_name)))
            target = find_object(project, name)

            changed = []
            if replace_if_changed(target.textual_declaration, declaration):
                changed.append("declaration")
            if implementation is not None:
                if not target.has_textual_implementation:
                    raise RuntimeError("Object '%s' has no implementation part" % name)
                if replace_if_changed(target.textual_implementation, implementation):
                    changed.append("implementation")

            if changed:
                changed_objects += 1
                print("  updated    %s (%s)" % (name, ", ".join(changed)))
            else:
                print("  unchanged  %s" % name)
    return changed_objects


def build_messages():
    system = scriptengine.system
    for category in system.get_message_categories():
        if system.get_message_category_description(category) == "Build":
            return list(system.get_messages(category))
    return []


def build(project):
    """Build the active application. Return True only if 0 errors are confirmed."""
    application = project.active_application
    if application is None:
        raise RuntimeError("The project has no active application")
    application.build()

    error_count = None
    for message in build_messages():
        print("  " + message)
        match = re.search(r"(\d+) errors?", message)
        if match:
            error_count = int(match.group(1))

    if error_count is None:
        print("Could not read the build result from the message store.")
        return False
    return error_count == 0


def main():
    if MODE not in ("build", "sync"):
        raise RuntimeError("DEV_MODE must be 'build' or 'sync', got '%s'" % MODE)

    flags = scriptengine.VersionUpdateFlags.NoUpdates | scriptengine.VersionUpdateFlags.SilentMode
    project = scriptengine.projects.open(PROJECT_PATH, update_flags=flags)
    try:
        changed_objects = 0
        if MODE == "sync":
            print("Copying src/*.st into %s" % PROJECT_PATH)
            changed_objects = sync_sources(project)

        print("Building application")
        build_ok = build(project)

        if changed_objects > 0:
            if build_ok:
                project.save()
                print("Project saved.")
            else:
                print("Build not clean: project NOT saved.")
        return build_ok
    finally:
        project.close()


try:
    succeeded = main()
except Exception:
    traceback.print_exc()
    succeeded = False

print("DEV_RESULT: %s" % ("OK" if succeeded else "FAILED"))
