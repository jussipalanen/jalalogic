# Making changes with Claude Code and ./dev

This guide shows the everyday loop: ask Claude Code for a change, let it
update the code and the CODESYS project, then try the result in simulation.

> Status: `./dev help` and the "project is open in the IDE" check are
> tested. `./dev build` and `./dev sync` against the real project are not
> tested yet. Update this note after the first successful run.

## How it fits together

```
 you ask Claude ──> Claude edits src/*.st ──> ./dev sync ──> CODESYS project
                                                 │          (built, saved)
                                                 └─ build errors? Claude
                                                    fixes src/ and reruns
```

- `src/*.st` is where code is changed. Claude edits these files.
- `./dev sync` copies them into `codesys/JalaLogicLite.project`, builds the
  application and saves the project only if the build has no errors.
- The CODESYS IDE is used to look at the result: login, start, test.

Copying goes one way only, from `src/` into the project.

## One-time setup

1. Install [Git for Windows](https://git-scm.com/download/win) (provides
   Git Bash) and make sure CODESYS has the **Scripting Engine** component.
2. In the project root, copy the settings template:

   ```bash
   cp .dev.env.example .dev.env
   ```

3. Edit `.dev.env`: set `CODESYS_EXE` to your `CODESYS.exe` and
   `CODESYS_PROFILE` to your profile name. The file is not committed.
4. Check the setup from the project root in Git Bash:

   ```bash
   ./dev help
   ./dev build
   ```

## Everyday loop

### 1. Close the project in the IDE

In CODESYS: **File > Close Project**. CODESYS itself can stay open.
`./dev` refuses to run while the IDE has the project open, so the IDE and
the script never write the same file.

### 2. Ask Claude for the change

Start Claude Code in the project root and describe the change. Name the
behaviour you want, not the code. Examples:

```
Add a grapple fault: if open and close are both pressed for longer than
2 seconds, latch a GRAPPLE_CONFLICT fault. Update src/ and run ./dev sync.
```

```
The boom moves too fast. Make the speed 5 %/s and run ./dev sync.
```

```
./dev sync failed with the build errors above. Fix them.
```

Claude follows `CLAUDE.md`: it edits the `.st` files, runs `./dev sync`
and reads the build output. On build errors the project is not saved;
Claude fixes `src/` and runs the sync again.

### 3. Check the result in CODESYS

1. Open `codesys/JalaLogicLite.project` in the IDE.
2. **Online > Simulation**, **Online > Login**, **Debug > Start**.
3. Test with the visualization or the steps in [TESTING.md](TESTING.md).

Before the next change, close the project again (step 1).

### 4. Commit

Ask Claude, for example:

```
Commit this on a feature branch and update CHANGELOG.md.
```

Commit the `.st` files and `codesys/JalaLogicLite.project` together, so
both describe the same code.

## What ./dev sync does not do

| Situation | What to do |
| --- | --- |
| A new POU or DUT is needed | Create the empty object in the IDE first (**Add Object**), with the same name as the new `.st` file, then sync. `./dev sync` only fills existing objects and stops with "not found in the project" otherwise. |
| Code was changed in the IDE | Copy it back into the matching `.st` file, or ask Claude to. The next sync would otherwise overwrite it. |
| Visualization or text list changes | Make them in the IDE. They are not in `src/` and sync does not touch them. |
| Download to the simulation or a PLC | Use **Online > Login** in the IDE. |

## Troubleshooting

| Message | Fix |
| --- | --- |
| `JalaLogicLite.project is open in the CODESYS IDE` | **File > Close Project** in the IDE, then run again. |
| `CODESYS_EXE: not set` | Create `.dev.env` (see One-time setup). |
| `CODESYS not found` | Fix the path in `.dev.env`. |
| `you must specify a profile` | Fix `CODESYS_PROFILE` in `.dev.env`. Use the name of the file in `<install>/CODESYS/Profiles` without `.profile.xml`. |
| `Object '...' not found in the project` | Create the object in the IDE (see table above). |
| `Build not clean: project NOT saved.` | Fix the build errors listed above it, then run again. |
| `Could not read the build result` | The build summary was not found in the message store. Build in the IDE (`F11`) to see the messages. |
