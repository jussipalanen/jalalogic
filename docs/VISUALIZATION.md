# CODESYS Visualization guide

This guide describes how to build the operator screen for JalaLogic Lite.
The visualization only reads and writes the `PLC_PRG.xHmi*`, `rHmi*` and
`sHmi*` variables and the text list `TL_Status`. No control logic is placed in the visualization.

Element names refer to the CODESYS V3.5 **ToolBox**. Names and categories
may differ slightly between CODESYS versions.

## 1. Add the visualization

1. Right-click **Application > Add Object > Visualization...**
2. Name: `VIS_Main`, click **Add**.
3. Check that a **Visualization Manager** exists under `Application`.
   CODESYS normally adds it automatically with the first visualization.

## 2. Suggested layout

```
+------------------------------------------------------------+
|  JalaLogic Lite v0.1.0          [ Status text            ] |
|                                                            |
|   Boom position        Boom drawing          Indicators    |
|   +---+                    /                 (o) Ready     |
|   |###|  57.3 %           /                  (o) Fault     |
|   |###|                  /                   (o) Upper lim |
|   |###|              ___/                    (o) Lower lim |
|   +---+             |___|                    (o) Grapple   |
|                                                  open      |
|   [ BOOM UP ]  [ BOOM DOWN ]                               |
|   [ GRAPPLE OPEN ]  [ GRAPPLE CLOSE ]                      |
|                                                            |
|   [ E-STOP ]   [ SIMULATE FAULT ]   [ RESET ]              |
|                                                            |
|  Simulation only - not a certified safety function         |
+------------------------------------------------------------+
```

## 3. Command buttons

Use **Common Controls > Button** for each command. Set the button text
under **Texts > Text** and the behaviour under **Input configuration**.

| Button text    | Input configuration | Variable                    |
|----------------|---------------------|-----------------------------|
| BOOM UP        | Tap                 | `PLC_PRG.xHmiBoomUp`        |
| BOOM DOWN      | Tap                 | `PLC_PRG.xHmiBoomDown`      |
| GRAPPLE OPEN   | Tap                 | `PLC_PRG.xHmiGrappleOpen`   |
| GRAPPLE CLOSE  | Tap                 | `PLC_PRG.xHmiGrappleClose`  |
| E-STOP         | Toggle              | `PLC_PRG.xHmiEmergencyStop` |
| SIMULATE FAULT | Toggle              | `PLC_PRG.xHmiSimulateFault` |
| RESET          | Tap                 | `PLC_PRG.xHmiReset`         |

- **Tap** sets the variable TRUE while the button is held and FALSE on
  release. This gives hold-to-run behaviour for boom and grapple.
- **Toggle** flips the variable on each click, so E-stop and simulated
  fault stay active until clicked again.
- Make the E-STOP button red. If your CODESYS version offers
  **Color variables > Toggle color**, bind it to `PLC_PRG.xHmiEmergencyStop`
  and set an **Alarm color** so the button shows when E-stop is latched.

## 4. Boom position

**Bar display** (Measurement Controls > Bar display):

- **Value:** `PLC_PRG.rHmiBoomPosition`
- **Scale start:** `0`, **Scale end:** `100`
- **Orientation:** vertical

**Numeric text** (Basic > Rectangle or Text field):

- **Texts > Text:** `Boom: %.1f`
- **Text variables > Text variable:** `PLC_PRG.rHmiBoomPosition`

## 5. Indicator lamps

Use **Lamps/Switches/Bitmaps > Lamp**, one per indication, with a label
next to it.

| Label         | Variable                       | Suggested color |
|---------------|--------------------------------|-----------------|
| Ready         | `PLC_PRG.xHmiReady`            | Green           |
| Fault         | `PLC_PRG.xHmiFault`            | Red             |
| Upper limit   | `PLC_PRG.xHmiBoomAtUpperLimit` | Yellow          |
| Lower limit   | `PLC_PRG.xHmiBoomAtLowerLimit` | Yellow          |
| Moving up     | `PLC_PRG.xHmiBoomMovingUp`     | Blue            |
| Moving down   | `PLC_PRG.xHmiBoomMovingDown`   | Blue            |
| Grapple open  | `PLC_PRG.xHmiGrappleIsOpen`    | Green           |

## 6. Status text

`PLC_PRG` does not generate the status text. It selects a status
(`eHmiStatus`, type `E_HmiStatus`) and converts its numeric value to the
text list ID `sHmiStatusId`. The visualization looks up the text in a
text list. This keeps operator language out of the PLC logic and allows
translations (for example Finnish) to be added later without changing code.

### 6a. Create the text list TL_Status

1. Right-click **Application > Add Object > Text List...**
2. Name: `TL_Status`, click **Add**.
3. Enter one row per status. The **ID** must equal the numeric value in
   `E_HmiStatus`; the text goes in the **Default** column.

| ID | Default                                     | E_HmiStatus                   |
|----|---------------------------------------------|-------------------------------|
| 0  | Ready                                       | `READY`                       |
| 1  | Conflicting commands - no movement          | `CONFLICTING_COMMANDS`        |
| 2  | Release all controls                        | `RELEASE_ALL_CONTROLS`        |
| 10 | FAULT: Emergency stop - release, then Reset | `FAULT_EMERGENCY_STOP`        |
| 11 | FAULT: Simulated fault - clear, then Reset  | `FAULT_SIMULATED`             |
| 12 | FAULT: Invalid configuration                | `FAULT_INVALID_CONFIGURATION` |
| 19 | FAULT: Unknown                              | `FAULT_UNKNOWN`               |

If you add a value to `E_HmiStatus`, add the matching row here. A missing
ID shows an empty or default text on the HMI.

### 6b. Status text field

**Text field** (Basic > Text field) across the top of the screen:

- **Dynamic texts > Text list:** `'TL_Status'` (with single straight
  quotes - the property expects a string literal)
- **Dynamic texts > Text index:** `PLC_PRG.sHmiStatusId` (no quotes -
  this is a variable)
- **Texts > Text:** leave empty

**Dynamic texts** is hidden by default. Enable **Advanced** in the
toolbar of the **Properties** view to show it.

Verified manually: the status field shows the `TL_Status` texts in
CODESYS simulation.

When debugging without the visualization, read `PLC_PRG.eHmiStatus` in
the online view; it shows the status name.

## 7. Optional boom drawing

A simple moving boom makes the demo easier to understand.

1. Draw a base with a **Rectangle**.
2. Draw the boom as a thin **Rectangle** (or **Polyline**) starting at the
   pivot point and pointing horizontally.
3. In the boom element, open **Absolute movement > Rotation** and set it to
   `PLC_PRG.rHmiBoomAngleDeg`.
4. Move the element's **center point** (rotation point) to the pivot.

`rHmiBoomAngleDeg` goes from `0` at 0 % to `c_rBoomMaxAngleDeg` at 100 %.
The default is `-60.0`. If the boom rotates downwards when raised, change
the sign of `c_rBoomMaxAngleDeg` in `PLC_PRG`.

## 8. Test the visualization

1. Build, log in in simulation mode and start the application
   (see [CODESYS_IMPORT.md](CODESYS_IMPORT.md)).
2. Open `VIS_Main`. The visualization is live while logged in.
3. Run the manual test cases in [TESTING.md](TESTING.md).
4. Take screenshots for the README (for example into `docs/images/`).

> Visualization status: `VIS_Main` has been built in
> `codesys/JalaLogicLite.project` (command buttons, position bar, lamps,
> status text). The full test run in [TESTING.md](TESTING.md) is pending.
> The optional boom drawing (section 7) has not been built.
