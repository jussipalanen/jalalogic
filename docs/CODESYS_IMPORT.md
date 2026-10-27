# Importing the code into CODESYS

The `.st` files in `src/` are plain-text copies of the CODESYS objects.
CODESYS V3 does not synchronize plain `.st` files with project objects, so
the code is transferred by **copy and paste** into the CODESYS editors.

Once the project exists, the native CODESYS project (`.project`) is the
authoritative source. If you change code in CODESYS, copy the changes back
into the matching `.st` file so Git stays up to date.

PLCopen XML export/import is intentionally not used in v0.1.0: hand-written
XML could not be verified here, and PLCopen XML does not cover every
CODESYS object type.

## 1. Create the project

1. Start CODESYS V3.5.
2. **File > New Project > Projects > Standard project**.
3. Name the project, for example `JalaCraneLite`.
4. In the dialog, choose:
   - **Device:** `CODESYS Control Win V3` (or `CODESYS Control Win V3 x64`)
   - **PLC_PRG in:** `Structured Text (ST)`

The standard project creates `Application`, `PLC_PRG`, a `Task Configuration`
with `MainTask`, and a `Library Manager` that includes the `Standard` library
(needed for `R_TRIG`).

## 2. Add the enumeration E_CraneFault

1. In the device tree, right-click **Application > Add Object > DUT...**
2. Name: `E_CraneFault`, type: **Enumeration**, click **Add**.
3. Select all text in the DUT editor and replace it with the contents of
   `src/DUTs/E_CraneFault.st` (comments at the top are optional).

## 3. Add the function block FB_CraneControl

1. Right-click **Application > Add Object > POU...**
2. Name: `FB_CraneControl`, type: **Function Block**,
   implementation language: **Structured Text (ST)**, click **Add**.
3. Open `src/POUs/FB_CraneControl.st`.
4. Copy the **DECLARATION PART** (from `FUNCTION_BLOCK` to the last
   `END_VAR`) into the upper editor, replacing the generated text.
5. Copy the **IMPLEMENTATION PART** (everything after the second comment
   banner) into the lower editor.

Note: the files do not contain `END_FUNCTION_BLOCK` / `END_PROGRAM`.
CODESYS does not use these keywords in its POU editors.

## 4. Replace PLC_PRG

1. Open **PLC_PRG**.
2. Replace the declaration part with the **DECLARATION PART** of
   `src/POUs/PLC_PRG.st`.
3. Replace the implementation part with the **IMPLEMENTATION PART**.

## 5. Check the task cycle time

The simulated boom speed is calculated from the cycle time passed to
`FB_CraneControl`. That value must match the real task interval.

1. Open **Task Configuration > MainTask**.
2. Check that the type is **Cyclic** and note the interval.
3. Make sure `c_tTaskCycleTime` in `PLC_PRG` has the same value
   (default in this code: `T#20MS`). Change one of them if they differ.

If they do not match, the boom moves faster or slower than 10 %/s, but
limits and fault handling still work.

## 6. Build

1. **Build > Build** (`F11`).
2. Check the **Messages** window for errors and warnings.

> Compilation status of this code: **not yet verified**. It was written
> to follow CODESYS V3 Structured Text syntax, but has not been compiled.
> Report any compiler messages so the `.st` files can be fixed.

## 7. Run in simulation

1. **Online > Simulation** (a check mark shows it is enabled).
2. **Online > Login** (`Alt+F8`), confirm downloading the application.
3. **Debug > Start** (`F5`).
4. Follow [TESTING.md](TESTING.md) using the watch view or the
   visualization from [VISUALIZATION.md](VISUALIZATION.md).

## 8. Keep Git in sync

- Save the CODESYS project in the repository folder (for example
  `codesys/JalaCraneLite.project`) if you want it under version control.
- After editing code in CODESYS, copy the declaration and implementation
  back into the `.st` files before committing.
