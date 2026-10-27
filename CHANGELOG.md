# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Planned as **0.1.0**. Not yet compiled or tested in CODESYS.

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
- Documentation: README, CODESYS import guide, visualization guide and
  manual test instructions.
