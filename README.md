# JalaLogic

A small educational forestry crane control simulator written in
IEC 61131-3 Structured Text for CODESYS V3. Built as a PLC programming
portfolio project.

> **Simulation only.** This project is not connected to and must not be
> connected to physical machinery. The simulated emergency stop and limits
> are **not** certified safety functions, and the project makes no claim of
> compliance with any machinery safety standard.

## Status

Version **0.1.0 (in development)**.

| Item                        | Status                                  |
|-----------------------------|-----------------------------------------|
| Structured Text code        | Written, **not yet compiled**           |
| CODESYS simulation tests    | **Not executed** (see [docs/TESTING.md](docs/TESTING.md)) |
| Visualization               | Guide written, **not yet built**        |

## Features (v0.1.0)

- Boom up/down with hold-to-run manual controls
- Simulated boom position 0–100 %, integrated from the PLC cycle time
- Upper and lower boom limits (position clamped, movement stops at limit)
- Grapple open/close; the grapple keeps its state during faults
- Conflicting commands (up + down, open + close) cause no movement
- Simulated emergency stop and simulated hydraulic fault
- Latched faults with rising-edge reset; reset only works when the fault
  source is gone
- Reset never restarts movement: all commands must be released first
- Configuration validation (cycle time, boom speed); invalid values fault
- Operator status text for the HMI

Out of scope for v0.1.0: CAN bus, real hydraulic control, 3D graphics,
databases and external APIs.

## Technologies

- CODESYS Development System V3.5
- IEC 61131-3 Structured Text
- CODESYS Visualization
- CODESYS Control Win V3 (simulation mode)
- Git and GitHub

Only the CODESYS `Standard` library is used (`R_TRIG`).

## Project structure

```
src/
  DUTs/E_CraneFault.st       Fault code enumeration
  POUs/FB_CraneControl.st    Crane control logic
  POUs/PLC_PRG.st            Main program, HMI variable mapping
docs/
  CODESYS_IMPORT.md          How to create the CODESYS project
  VISUALIZATION.md           How to build the operator screen
  TESTING.md                 Manual test cases and results
```

### Architecture

- **FB_CraneControl** holds all control logic: fault latching, command
  validation, boom simulation, limits and grapple state.
- **PLC_PRG** calls the FB once per cycle and maps its inputs/outputs to
  `xHmi*` / `rHmi*` / `sHmi*` variables.
- **VIS_Main** (visualization) only binds to those HMI variables. There
  is no logic in the visualization.

### Key design decisions

- **Cycle time as an input.** The FB receives `tCycleTime` from
  `PLC_PRG` instead of measuring time. This keeps the FB deterministic and
  easy to test. The value must match the `MainTask` interval (default
  `T#20MS`).
- **Default to no movement.** Movement requires: no latched fault, no
  conflicting command for that function, and all commands released since
  the last fault or start-up.
- **Latched faults.** A fault stays active after its cause disappears
  until the operator presses Reset, so the operator always sees what
  happened.
- **Grapple holds on fault.** Opening the grapple on a fault could drop
  a load, so the grapple keeps its last state.

## Installation

1. Install CODESYS V3.5 (the free Development System includes
   CODESYS Control Win V3 simulation).
2. Clone this repository.
3. Create a CODESYS project and copy the code in, following
   [docs/CODESYS_IMPORT.md](docs/CODESYS_IMPORT.md).

The `.st` files are plain-text copies. CODESYS does not synchronize them
automatically; the native CODESYS project is the authoritative source.

## Simulation

1. In CODESYS: **Online > Simulation**.
2. **Online > Login** (`Alt+F8`), then **Debug > Start** (`F5`).
3. Open the visualization built from
   [docs/VISUALIZATION.md](docs/VISUALIZATION.md), or write values in the
   `PLC_PRG` online view.
4. Run the test cases in [docs/TESTING.md](docs/TESTING.md).

## Screenshots

Screenshots will be added once the visualization has been built and
tested in CODESYS.

## AI-assisted development disclosure

The Structured Text code and documentation in v0.1.0 were generated with
the help of an AI coding assistant. The author reviews all generated code
before release. AI-generated code is not assumed to be correct:
compilation and simulation results are recorded only after they have
actually been run in CODESYS (see the status table above and
[docs/TESTING.md](docs/TESTING.md)).

## License

No license has been chosen yet.
