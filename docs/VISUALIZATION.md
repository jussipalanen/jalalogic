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

## 2. Layout

The screen is split into one status bar and three panels, so each control
sits next to the indications it affects. Read it from top to bottom: what
is the crane doing, how do I move it, how do I recover from a fault.

```
+--------------------------------------------------------------------+
| JalaLogic Lite v0.1.0   (o) Ready  [ Status text                 ] |
+----------------------+-------------------+-------------------------+
| BOOM                 | GRAPPLE           | SAFETY AND FAULTS       |
|                      |                   |                         |
| (o) Upper limit      | [ OPEN  ]         |  +-------------------+  |
| +---+                | [ CLOSE ]         |  |      E-STOP       |  |
| |   |  57.3 %        |                   |  +-------------------+  |
| |###|                | (o) Grapple open  |                         |
| |###|  [ BOOM UP   ] |                   |  [ SIMULATE FAULT ]     |
| |###|  (o) Moving up |                   |  (o) Fault              |
| |###|                |                   |                         |
| |###|  [ BOOM DOWN ] |                   |  [ RESET ]              |
| |###|  (o) Moving dn |                   |                         |
| +---+                |                   |                         |
| (o) Lower limit      |                   |                         |
+----------------------+-------------------+-------------------------+
| Hold BOOM UP / DOWN to move. After a fault: clear the cause,       |
| release all controls, then press RESET.                            |
| Simulation only - not a certified safety function.                 |
+--------------------------------------------------------------------+
```

| Area              | Elements                                                    | Notes |
|-------------------|-------------------------------------------------------------|-------|
| Status bar        | Title text, Ready lamp, status text field (section 6b)      | Make the status field wide; it is the main message to the operator. Optional: **Color variables > Toggle color** = `PLC_PRG.xHmiFault` with a red **Alarm color**, so the bar turns red on a fault. |
| Panel BOOM        | Bar display, position text, BOOM UP / BOOM DOWN, Moving up / Moving down lamps, Upper / Lower limit lamps | Put Upper limit above the bar and Lower limit below it, and BOOM UP above BOOM DOWN, so their positions match the direction. |
| Panel GRAPPLE     | OPEN / CLOSE buttons, Grapple open lamp                     | |
| Panel SAFETY AND FAULTS | E-STOP, SIMULATE FAULT, Fault lamp, RESET             | Make E-STOP the largest button, red, and clearly apart from the movement buttons. |
| Help footer       | Two text lines                                              | Plain **Text field** elements, static text. |

Draw each panel as a **Rectangle** (Basic) with a light fill and a
**Text field** heading. Draw the panels first, then the elements on top,
so the panels stay in the background.

Use the same size for all movement buttons (for example 160 x 50) and
leave a gap of at least 10 pixels between buttons, so a mis-click does not
press a neighbouring button.

The optional boom drawing (section 7) fits between the BOOM and GRAPPLE
panels if you make the screen wider.

## 2a. Build sheet

Exact positions for the layout above, on a **1024 x 600** screen. Enter
them in the **Properties** view under **Position** (X, Y, Width, Height).
The coordinates were checked with a script: every element lies inside its
panel, nothing overlaps and buttons are at least 10 px apart.

`VIS_Main` already contains the buttons, bar, lamps and status text. **Move
the existing elements** instead of deleting and redrawing them, so their
variables (sections 3-6) stay connected. Add only what is missing: the
five background rectangles, headings, labels and help texts.

Work in this order:

1. Draw the five background rectangles (table A).
2. Select all five and send them to the back (right-click > **Order** >
   **To back**; the menu name may differ slightly by version).
3. Move or add the elements of tables B-F.
4. Build, log in and check that nothing is hidden behind a rectangle.

Colors are given as RGB. Font sizes are suggestions.

**A. Backgrounds** (Basic > Rectangle)

| Element    | X   | Y   | W    | H   | Properties |
|------------|-----|-----|------|-----|------------|
| Status bar | 10  | 10  | 1004 | 60  | Fill 225,230,235. **Color variables > Toggle color:** `PLC_PRG.xHmiFault`, **Alarm color** fill 230,60,60 |
| BOOM       | 10  | 80  | 400  | 420 | Fill 242,242,242 |
| GRAPPLE    | 420 | 80  | 270  | 420 | Fill 242,242,242 |
| SAFETY AND FAULTS | 700 | 80 | 314 | 420 | Fill 242,242,242 |
| Help footer | 10 | 510 | 1004 | 80  | Fill 250,250,250 |

**B. Status bar**

| Element      | Toolbox    | X   | Y  | W   | H  | Properties |
|--------------|------------|-----|----|-----|----|------------|
| Title        | Text field | 20  | 20 | 220 | 40 | Text `JalaLogic Lite v0.1.0`, bold 16 |
| Ready lamp   | Lamp       | 250 | 20 | 40  | 40 | `PLC_PRG.xHmiReady`, green |
| Ready label  | Text field | 295 | 25 | 65  | 30 | Text `Ready` |
| Status text  | Text field | 370 | 20 | 634 | 40 | Section 6b, font 16, left aligned |

**C. Panel BOOM**

| Element           | Toolbox     | X   | Y   | W   | H   | Properties |
|-------------------|-------------|-----|-----|-----|-----|------------|
| Heading           | Text field  | 20  | 88  | 200 | 30  | Text `BOOM`, bold 14, left aligned |
| Upper limit lamp  | Lamp        | 30  | 125 | 30  | 30  | `PLC_PRG.xHmiBoomAtUpperLimit`, yellow |
| Upper limit label | Text field  | 70  | 125 | 120 | 30  | Text `Upper limit`, left aligned |
| Position bar      | Bar display | 30  | 165 | 60  | 250 | Section 4, vertical |
| Position text     | Text field  | 100 | 165 | 120 | 40  | Section 4, font 16 |
| BOOM UP           | Button      | 230 | 215 | 160 | 50  | Section 3 |
| Moving up lamp    | Lamp        | 230 | 275 | 30  | 30  | `PLC_PRG.xHmiBoomMovingUp`, blue |
| Moving up label   | Text field  | 270 | 275 | 120 | 30  | Text `Moving up`, left aligned |
| BOOM DOWN         | Button      | 230 | 325 | 160 | 50  | Section 3 |
| Moving down lamp  | Lamp        | 230 | 385 | 30  | 30  | `PLC_PRG.xHmiBoomMovingDown`, blue |
| Moving down label | Text field  | 270 | 385 | 120 | 30  | Text `Moving down`, left aligned |
| Lower limit lamp  | Lamp        | 30  | 425 | 30  | 30  | `PLC_PRG.xHmiBoomAtLowerLimit`, yellow |
| Lower limit label | Text field  | 70  | 425 | 120 | 30  | Text `Lower limit`, left aligned |

**D. Panel GRAPPLE**

| Element            | Toolbox    | X   | Y   | W   | H  | Properties |
|--------------------|------------|-----|-----|-----|----|------------|
| Heading            | Text field | 430 | 88  | 200 | 30 | Text `GRAPPLE`, bold 14, left aligned |
| GRAPPLE OPEN       | Button     | 475 | 165 | 160 | 50 | Section 3 |
| GRAPPLE CLOSE      | Button     | 475 | 225 | 160 | 50 | Section 3 |
| Grapple open lamp  | Lamp       | 475 | 300 | 30  | 30 | `PLC_PRG.xHmiGrappleIsOpen`, green |
| Grapple open label | Text field | 515 | 300 | 150 | 30 | Text `Grapple open`, left aligned |

**E. Panel SAFETY AND FAULTS**

| Element        | Toolbox    | X   | Y   | W   | H  | Properties |
|----------------|------------|-----|-----|-----|----|------------|
| Heading        | Text field | 710 | 88  | 280 | 30 | Text `SAFETY AND FAULTS`, bold 14, left aligned |
| E-STOP         | Button     | 737 | 130 | 240 | 90 | Section 3. Fill 210,40,40, white bold text 20. **Toggle color:** `PLC_PRG.xHmiEmergencyStop`, **Alarm color** fill 120,0,0 |
| SIMULATE FAULT | Button     | 777 | 250 | 160 | 50 | Section 3. **Toggle color:** `PLC_PRG.xHmiSimulateFault`, **Alarm color** fill 255,150,0 |
| Fault lamp     | Lamp       | 777 | 310 | 30  | 30 | `PLC_PRG.xHmiFault`, red |
| Fault label    | Text field | 817 | 310 | 120 | 30 | Text `Fault`, left aligned |
| RESET          | Button     | 777 | 380 | 160 | 50 | Section 3 |

E-STOP is 30 px away from SIMULATE FAULT and 120 px away from the
nearest movement button, so it cannot be hit by accident.

**F. Help footer**

| Element     | Toolbox    | X  | Y   | W   | H  | Properties |
|-------------|------------|----|-----|-----|----|------------|
| Help line 1 | Text field | 20 | 518 | 984 | 30 | Text `Hold BOOM UP / DOWN to move. After a fault: clear the cause, release all controls, then press RESET.`, left aligned |
| Help line 2 | Text field | 20 | 552 | 984 | 30 | Text `Simulation only - not a certified safety function.`, left aligned, italic |

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
- Do the same for SIMULATE FAULT with `PLC_PRG.xHmiSimulateFault` (for
  example orange). A toggle button looks the same pressed and released
  unless it has a toggle color, and the operator then cannot see that the
  cause must be cleared before RESET works.

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
> The panel layout (section 2a), the optional boom drawing (section 7) and
> WebVisu (section 9) have not been built yet.

## 9. WebVisu (browser)

WebVisu shows `VIS_Main` in a web browser. It is the same visualization
object, so it uses the same layout (section 2a): there is nothing to
draw twice, and a change to `VIS_Main` appears in both the IDE and the
browser after the next download. It does **not** work in
**Online > Simulation** mode: the simulator inside the IDE has no web
server. It needs the soft PLC **CODESYS Control Win V3**, which is
installed together with CODESYS.

### 9a. Add the WebVisu object

1. Right-click **Visualization Manager > Add Object > WebVisu...**, click
   **Add**.
2. In the WebVisu object set **Start visualization** to `VIS_Main`.
3. Leave the **.htm file name** at `webvisu.htm`.
4. **Scaling options:** `Isotropic`, so the 1024 x 600 screen fits the
   browser window without distortion. (Property names may differ
   slightly by version.)
5. Build (`F11`).

### 9b. Start the soft PLC

Start **CODESYS Control Win V3 - x64**, either:

- from the system tray: right-click the **CODESYS Control Win V3** icon >
  **Start PLC**, or
- from an **administrator** PowerShell:

  ```powershell
  Start-Service "CODESYS Control Win V3 - x64"
  ```

Without a license, the runtime runs in demo mode and stops after about
two hours. Restart it to continue.

### 9c. Log in to the soft PLC

1. **Online > Simulation** must be **off** (no check mark).
2. Double-click **Device** > **Communication Settings** > **Scan Network**,
   select the local `CODESYS Control Win V3` device and set it active.
3. On the first connection CODESYS may ask you to create a device user.
   Create one and remember the password; it is stored in the runtime, not
   in this repository.
4. **Online > Login** (`Alt+F8`), confirm the download, then
   **Debug > Start** (`F5`).

### 9d. Open the browser

Open <http://localhost:8080/webvisu.htm>.

The operator screen works the same as in the IDE. Hold-to-run (**Tap**)
buttons need the mouse button held down in the browser as well.

If the page does not load: check that the application is running
(**Debug > Start**), that the WebVisu object exists and the project was
downloaded after adding it, and that no other program uses port 8080.

When finished, **Online > Logout** and stop the soft PLC (tray icon >
**Stop PLC** or `Stop-Service "CODESYS Control Win V3 - x64"`).

To return to the IDE simulator, switch **Online > Simulation** back on.
