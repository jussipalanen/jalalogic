
# AGENTS.md

## Purpose
Instructions for AI coding agents working on JalaLogic.

## Development Principles
- Read CLAUDE.md before making changes.
- Keep changes minimal.
- Prefer maintainable, understandable code.
- Avoid overengineering.
- Ask for clarification only when essential.

## PLC Development
- Use CODESYS-compatible Structured Text.
- Put control logic in function blocks.
- Avoid unnecessary dependencies.
- Never assume generated code is production-safe.
- Use simulated inputs and outputs only.

## Testing
Check the following cases:
1. Boom moves up when commanded.
2. Boom moves down when commanded.
3. Boom stops at upper and lower limits.
4. Conflicting commands result in no movement.
5. Grapple opens and closes correctly.
6. Faults prevent movement.
7. Reset does not automatically restart movement.

Document which tests are simulated, manually
verified or not executed.

## Git Workflow
- main: Stable releases
- feature/*: New features
- fix/*: Corrections
- docs/*: Documentation

Use Conventional Commits:
- feat:
- fix:
- docs:
- refactor:
- test:
- chore:

## Releases
Use Semantic Versioning:
- PATCH: Bug fixes
- MINOR: Backward-compatible features
- MAJOR: Breaking changes

Initial milestone: v0.1.0

## CODESYS Integration
Treat the native CODESYS project as authoritative.

Plain .st files are not automatically synchronized
with CODESYS project objects.

Use supported import/export workflows.
Do not assume PLCopen XML is fully compatible with
every project object.

## Completion Criteria
A feature is complete only when:
- Code has been reviewed.
- Required test cases are documented.
- CODESYS compilation is verified or clearly pending.
- README is updated if behavior changed.
