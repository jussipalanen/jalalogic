# Manual test instructions

These tests verify `FB_CraneControl` through `PLC_PRG` in CODESYS
simulation mode. They can be run from the visualization (`VIS_Main`) or
from the watch view in `PLC_PRG`.

## Test status

| Status        | Meaning                                         |
|---------------|-------------------------------------------------|
| Not executed  | Test is written but has not been run            |
| Manual - pass | Run manually in CODESYS simulation and passed   |
| Manual - fail | Run manually and failed (describe in notes)     |

**Current state:** the code builds in CODESYS. T1 has been run manually
in simulation; the other tests have not been executed yet. Update the
table at the end of this file when tests are run.

## Setup

1. Import the code as described in [CODESYS_IMPORT.md](CODESYS_IMPORT.md).
2. **Online > Simulation**, **Online > Login** (`Alt+F8`),
   **Debug > Start** (`F5`).
3. Either open `VIS_Main`, or open `PLC_PRG` and use the online
   declaration view.

### Writing values without the visualization

1. In the online view of `PLC_PRG`, double-click the **Prepared value**
   cell of a variable (for example `xHmiBoomUp`) to select `TRUE`.
2. **Debug > Write Values** (`Ctrl+F7`) writes the prepared values once.
3. Set the prepared value to `FALSE` and write again to release.

Expand `fbCrane` in the online view to see all FB outputs.

Expected boom speed with default settings: 10 % per second
(0 % to 100 % in about 10 s), assuming `c_tTaskCycleTime` matches the
MainTask interval.

## Test cases

Start every test from this state unless stated otherwise:
no fault, all commands FALSE, `eHmiStatus` = `READY`.

### T1 - Boom moves up

1. Start with the boom below 100 % (start value is 0 %).
2. Hold `xHmiBoomUp` TRUE.

Expected: `rHmiBoomPosition` increases about 10 %/s, `xHmiBoomMovingUp`
is TRUE. Releasing the command stops the boom immediately.

### T2 - Boom moves down

1. Raise the boom to around 50 %.
2. Hold `xHmiBoomDown` TRUE.

Expected: position decreases, `xHmiBoomMovingDown` is TRUE. Releasing
stops the boom.

### T3 - Boom stops at upper and lower limits

1. Hold `xHmiBoomUp` until movement stops.
2. Expected: position is exactly `100.0`, `xHmiBoomAtUpperLimit` TRUE,
   `xHmiBoomMovingUp` FALSE while the command is still held.
3. Hold `xHmiBoomDown` until movement stops.
4. Expected: position is exactly `0.0`, `xHmiBoomAtLowerLimit` TRUE,
   `xHmiBoomMovingDown` FALSE.

### T4 - Conflicting commands cause no movement

1. Set boom to around 50 %. Set `xHmiBoomUp` and `xHmiBoomDown` both TRUE
   in the same write.
2. Expected: position does not change, both moving flags FALSE,
   `fbCrane.xBoomCommandConflict` TRUE, `eHmiStatus` =
   `CONFLICTING_COMMANDS`.
3. Set `xHmiGrappleOpen` and `xHmiGrappleClose` both TRUE.
4. Expected: `xHmiGrappleIsOpen` keeps its previous value,
   `fbCrane.xGrappleCommandConflict` TRUE.

### T5 - Grapple opens and closes

1. Pulse `xHmiGrappleOpen` (TRUE, then FALSE).
2. Expected: `xHmiGrappleIsOpen` TRUE and stays TRUE after release.
3. Pulse `xHmiGrappleClose`.
4. Expected: `xHmiGrappleIsOpen` FALSE.

### T6 - Faults prevent movement

1. Set `xHmiEmergencyStop` TRUE.
2. Expected: `xHmiFault` TRUE, `xHmiReady` FALSE, `fbCrane.eFaultCode` =
   `EMERGENCY_STOP`, `eHmiStatus` = `FAULT_EMERGENCY_STOP`.
3. Try `xHmiBoomUp`, `xHmiBoomDown`, `xHmiGrappleOpen`, `xHmiGrappleClose`.
4. Expected: no boom movement, grapple state unchanged.
5. Repeat with `xHmiSimulateFault` TRUE (E-stop FALSE).
   Expected: same behaviour, fault code `SIMULATED_FAULT`.
6. Boom moving while fault occurs: hold `xHmiBoomUp`, then set
   `xHmiEmergencyStop` TRUE. Expected: movement stops in the same cycle.

### T7 - Reset does not automatically restart movement

1. Hold `xHmiBoomUp` TRUE (boom moving).
2. Set `xHmiEmergencyStop` TRUE. Boom stops.
3. Keep `xHmiBoomUp` TRUE. Set `xHmiEmergencyStop` FALSE.
4. Expected: fault is still latched (`xHmiFault` TRUE). Boom does not move.
5. Pulse `xHmiReset`.
6. Expected: `xHmiFault` FALSE, but boom **does not move** because
   `xHmiBoomUp` is still held. `fbCrane.xWaitingForRelease` TRUE,
   `eHmiStatus` = `RELEASE_ALL_CONTROLS`.
7. Release `xHmiBoomUp`, then press it again.
8. Expected: boom moves up again.

### T8 - Reset is ignored while a fault source is active

1. Set `xHmiSimulateFault` TRUE.
2. Pulse `xHmiReset`.
3. Expected: fault remains latched.
4. Set `xHmiSimulateFault` FALSE, pulse `xHmiReset`.
5. Expected: fault clears, `eHmiStatus` = `READY`.

### T9 - Held command at start-up causes no movement

`xWaitForRelease` is initialized to TRUE, so a command that is already
TRUE in the first cycle must be released before the crane moves. This is
hard to reproduce from the visualization because a cold or warm reset also
re-initializes the HMI variables. Treat this case as **code review only**
unless you find a reliable way to hold a command through the first cycle.

### T10 - Invalid configuration (optional)

1. In `PLC_PRG`, temporarily change `c_rBoomSpeed` to `0.0`, build and
   download (Online Change or full download).
2. Expected: fault code `INVALID_CONFIGURATION`, no movement.
3. Restore `10.0`, download, pulse `xHmiReset`. Fault clears.

## Results

| Test | Description                          | Status       | Date | Notes |
|------|--------------------------------------|--------------|------|-------|
| T1   | Boom moves up                        | Manual - pass | 2026-10-27 | Online view, Write Values |
| T2   | Boom moves down                      | Not executed |      |       |
| T3   | Upper and lower limits               | Not executed |      |       |
| T4   | Conflicting commands                 | Not executed |      |       |
| T5   | Grapple open/close                   | Not executed |      |       |
| T6   | Faults prevent movement              | Not executed |      |       |
| T7   | Reset does not restart movement      | Not executed |      |       |
| T8   | Reset ignored while fault active     | Not executed |      |       |
| T9   | Held command at start-up             | Not executed |      | Code review only |
| T10  | Invalid configuration                | Not executed |      |       |
