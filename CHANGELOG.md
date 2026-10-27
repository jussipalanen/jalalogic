# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Planned as **0.1.0**. Builds in CODESYS; manual test run in progress.

### Added

- `FB_CraneControl` function block with simulated boom position (0–100 %),
  cycle-time based movement, upper/lower limits and grapple open/close.
- Conflicting command detection (boom up + down, grapple open + close)
  resulting in no movement.
- Simulated emergency stop, simulated hydraulic fault and configuration
  validation with latched fault codes.
- Rising-edge fault reset that requires all commands to be released
  before movement resumes.
- `E_CraneFault` enumeration for fault codes.
- `PLC_PRG` main program with HMI variable mapping and operator status.
- `E_HmiStatus` enumeration and text list `TL_Status` for the operator
  status. `PLC_PRG` outputs a status code (`eHmiStatus`, `sHmiStatusId`)
  instead of a text string, so HMI texts can be translated without code
  changes.
- Native CODESYS project `codesys/JalaLogicLite.project` with the
  `VIS_Main` operator screen and `TL_Status` text list.
- Project logo in `assets/logo.png`.
- README instructions for the optional community CODESYS MCP server
  (`@codesys/mcp-toolkit`) for AI-assisted development, with tested
  behaviour, example prompts and troubleshooting.
- Operator screen layout in the visualization guide: status bar and
  BOOM, GRAPPLE and SAFETY AND FAULTS panels, help footer and toggle
  colors for E-stop and simulated fault (not yet built in `VIS_Main`).
- Documentation: README, CODESYS import guide, visualization guide and
  manual test instructions.
- `./dev` developer script (Git Bash): `./dev sync` copies `src/*.st`
  into the CODESYS project, builds headless and saves only on a clean
  build; `./dev build` only builds. Refuses to run while the project is
  open in the IDE. Tested with CODESYS V3.5 SP22 Patch 3.
- `docs/DEV_WORKFLOW.md`: everyday workflow for changes with Claude Code
  and `./dev`.
- Visualization guide: build sheet with exact positions, sizes and colors
  for the operator screen layout (1024 x 600), and WebVisu setup for
  viewing `VIS_Main` in a browser via CODESYS Control Win V3. Not yet
  built in the project.
