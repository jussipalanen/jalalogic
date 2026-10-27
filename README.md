# JalaLogic Lite

![JalaLogic](assets/logo.png)

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
| Structured Text code        | Builds in CODESYS (manual build)        |
| CODESYS simulation tests    | T1 passed manually; T2–T10 **not yet executed** (see [docs/TESTING.md](docs/TESTING.md)) |
| Visualization               | `VIS_Main` built (buttons, position bar, lamps, status text); **full test run pending** |

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
- Operator status for the HMI, with texts in a CODESYS text list
  (no language-specific text in the PLC code)

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
assets/
  logo.png                   Project logo
codesys/
  JalaLogicLite.project      Native CODESYS project (code and visualization)
src/
  DUTs/E_CraneFault.st       Fault code enumeration
  DUTs/E_HmiStatus.st        Operator status enumeration (text list IDs)
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
3. Open `codesys/JalaLogicLite.project` in CODESYS.

To build the project from scratch instead, follow
[docs/CODESYS_IMPORT.md](docs/CODESYS_IMPORT.md).

The `.st` files are plain-text copies for review on GitHub. CODESYS does
not synchronize them automatically; `codesys/JalaLogicLite.project` is the
authoritative source. Copy code changes back into the `.st` files before
committing.

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

## AI assistant with CODESYS MCP (optional)

An AI assistant that supports the Model Context Protocol (MCP), such as
Claude Code, can work with the CODESYS project directly through the
community MCP server
[`@codesys/mcp-toolkit`](https://github.com/johannesPettersson80/codesys-mcp-toolkit).
It is not needed to build or run the simulator.

> **Status: partly verified with this project.** Connecting, opening
> `codesys/JalaLogicLite.project`, listing its objects and reading POU code
> have been tried and work. Editing code through MCP has not been tried.
> The toolkit is a third-party project, not affiliated with CODESYS.

### What it can and cannot do

| Can                                                      | Cannot                                      |
|----------------------------------------------------------|---------------------------------------------|
| Open, create and save projects                           | Create or edit visualizations (`VIS_Main`)  |
| List the project objects and read POU code               | Create DUTs (enumerations such as `E_HmiStatus`) |
| Create programs, function blocks, functions, methods and properties | Run the simulation or the manual tests |
| Write POU code                                           | Return build errors (see below)             |
| Start a build                                            |                                             |

The build tool only starts the build. Errors and warnings appear in the
**Messages** window of CODESYS, not in the assistant's answer, so check
them there (**Build > Build**, `F11`).

Code read through MCP comes back without indentation. Use the `.st` files
in `src/` or the project in CODESYS as the reference, not the MCP output.

### Requirements

- CODESYS V3.5 with the **Scripting Engine** component installed
- Node.js 18 or later
- An MCP client, for example Claude Code

### Setup

1. Install the toolkit:

   ```
   npm install -g @codesys/mcp-toolkit
   ```

2. Find the two values for your installation:
   - **CODESYS path:** `<install folder>/CODESYS/Common/CODESYS.exe`
   - **Profile name:** the file name in `<install folder>/CODESYS/Profiles/`
     without `.profile.xml`, for example `CODESYS V3.5 SP22 Patch 3`

3. Register the server in Claude Code from the repository folder. The
   default local scope keeps your machine-specific paths out of Git.
   On Windows, `cmd /c` is needed to start the npm command shim.

   PowerShell:

   ```
   claude.cmd mcp add codesys '--' cmd /c codesys-mcp-tool --codesys-path "C:/Path/To/CODESYS/Common/CODESYS.exe" --codesys-profile "CODESYS V3.5 SP22 Patch 3" --workspace "C:/Path/To/jalalogic"
   ```

   Command Prompt (`cmd.exe`): the same command with `--` instead of
   `'--'`.

   In PowerShell, plain `claude` runs the `claude.ps1` script shim and
   PowerShell removes an unquoted `--`, which causes
   `error: unknown option '--codesys-path'`. Use `claude.cmd` and the
   quoted `'--'` as shown.

4. Restart Claude Code and check the connection with `claude mcp list`.
   The `codesys` server should show as connected.

For other MCP clients, use the same command and arguments in the client's
MCP configuration. See the toolkit README for details.

### Try the project with the assistant

1. **Close the project in CODESYS** (**File > Close Project**) or close
   CODESYS. The toolkit starts its own CODESYS instance in the background,
   and only one instance can have the project open at a time.
2. Start Claude Code in the repository folder.
3. Ask the assistant, for example:
   - "Check that you can connect to CODESYS."
   - "Open `codesys/JalaLogicLite.project` and list its objects."
   - "Show the code of `FB_CraneControl` and explain how the fault reset
     works."
   - "Which test cases in `docs/TESTING.md` cover the emergency stop?"
4. To run the simulator, close Claude Code, open the project in CODESYS
   and follow [Simulation](#simulation) and
   [docs/TESTING.md](docs/TESTING.md). The assistant cannot run the
   simulation or the manual tests for you.

These requests only read the project. If you let the assistant change
code, commit or stash your own changes first so every change can be
reviewed and reverted with Git. Copy changed code into the matching `.st`
file in `src/`, build in CODESYS and run the manual tests. A successful
build does not mean the logic is correct.

### Troubleshooting

| Problem | Solution |
|---------|----------|
| `The selected project is currently in use by '<user>' on '<computer>'` | The project is open in CODESYS. Close it there and ask again. |
| `error: unknown option '--codesys-path'` when registering | See step 3 of [Setup](#setup): use `claude.cmd` and `'--'` in PowerShell. |
| `codesys` is not listed or fails in `claude mcp list` | Check the CODESYS path and profile name from step 2 of [Setup](#setup). The **Scripting Engine** component must be installed. |

The official
[CODESYS Development System MCP Server](https://content.helpme-codesys.com/en/CODESYS%20Development%20System%20MCP%20Server/_idemcp_start_page.html)
is an alternative. It requires a CODESYS Professional Developer Edition
license and has not been tried with this project.

## License

No license has been chosen yet.
