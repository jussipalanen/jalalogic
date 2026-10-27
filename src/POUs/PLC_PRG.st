// JalaLogic Lite - PLC_PRG
// Simulation-only educational project. Not a certified safety function.
//
// Main program. Connects the HMI variables to FB_CraneControl.
// Visualization elements bind only to the xHmi*/rHmi*/eHmi*/sHmi* variables
// below; all control logic stays inside FB_CraneControl.
// Operator texts are not generated here: the HMI shows the text list entry
// TL_Status selected by sHmiStatusId (see docs/VISUALIZATION.md).
//
// ============================================================================
// DECLARATION PART
// Paste from "PROGRAM" down to the last "END_VAR" into the declaration
// editor (upper half) of PLC_PRG, replacing the existing text.
// ============================================================================

PROGRAM PLC_PRG
VAR
    // HMI commands (written by visualization)
    xHmiBoomUp            : BOOL := FALSE;
    xHmiBoomDown          : BOOL := FALSE;
    xHmiGrappleOpen       : BOOL := FALSE;
    xHmiGrappleClose      : BOOL := FALSE;
    xHmiEmergencyStop     : BOOL := FALSE;
    xHmiSimulateFault     : BOOL := FALSE;
    xHmiReset             : BOOL := FALSE;

    // HMI indications (read by visualization)
    rHmiBoomPosition      : REAL := 0.0;   // 0..100 %
    rHmiBoomAngleDeg      : REAL := 0.0;   // Boom drawing rotation
    xHmiBoomMovingUp      : BOOL := FALSE;
    xHmiBoomMovingDown    : BOOL := FALSE;
    xHmiBoomAtUpperLimit  : BOOL := FALSE;
    xHmiBoomAtLowerLimit  : BOOL := FALSE;
    xHmiGrappleIsOpen     : BOOL := FALSE;
    xHmiReady             : BOOL := FALSE;
    xHmiFault             : BOOL := FALSE;
    eHmiStatus            : E_HmiStatus := E_HmiStatus.READY;
    sHmiStatusId          : STRING(10) := '0'; // Text list ID for TL_Status

    fbCrane               : FB_CraneControl;
END_VAR
VAR CONSTANT
    c_tTaskCycleTime      : TIME := T#20MS; // Must match the MainTask interval
    c_rBoomSpeed          : REAL := 10.0;   // Percent per second (0 -> 100 % in 10 s)
    c_rBoomMaxAngleDeg    : REAL := -60.0;  // Drawing angle at 100 %; flip sign if it rotates the wrong way
END_VAR

// ============================================================================
// IMPLEMENTATION PART
// Paste everything below this block into the implementation editor
// (lower half) of PLC_PRG.
// ============================================================================

fbCrane(
    xBoomUp               := xHmiBoomUp,
    xBoomDown             := xHmiBoomDown,
    xGrappleOpen          := xHmiGrappleOpen,
    xGrappleClose         := xHmiGrappleClose,
    xEmergencyStopPressed := xHmiEmergencyStop,
    xSimulatedFault       := xHmiSimulateFault,
    xReset                := xHmiReset,
    tCycleTime            := c_tTaskCycleTime,
    rBoomSpeed            := c_rBoomSpeed);

// Map FB outputs to HMI indications.
rHmiBoomPosition     := fbCrane.rBoomPosition;
rHmiBoomAngleDeg     := fbCrane.rBoomPosition / 100.0 * c_rBoomMaxAngleDeg;
xHmiBoomMovingUp     := fbCrane.xBoomMovingUp;
xHmiBoomMovingDown   := fbCrane.xBoomMovingDown;
xHmiBoomAtUpperLimit := fbCrane.xBoomAtUpperLimit;
xHmiBoomAtLowerLimit := fbCrane.xBoomAtLowerLimit;
xHmiGrappleIsOpen    := fbCrane.xGrappleIsOpen;
xHmiReady            := fbCrane.xReady;
xHmiFault            := fbCrane.xFault;

// Operator status, most important condition first.
IF fbCrane.xFault THEN
    CASE fbCrane.eFaultCode OF
        E_CraneFault.EMERGENCY_STOP:
            eHmiStatus := E_HmiStatus.FAULT_EMERGENCY_STOP;
        E_CraneFault.SIMULATED_FAULT:
            eHmiStatus := E_HmiStatus.FAULT_SIMULATED;
        E_CraneFault.INVALID_CONFIGURATION:
            eHmiStatus := E_HmiStatus.FAULT_INVALID_CONFIGURATION;
    ELSE
        eHmiStatus := E_HmiStatus.FAULT_UNKNOWN;
    END_CASE
ELSIF fbCrane.xWaitingForRelease THEN
    eHmiStatus := E_HmiStatus.RELEASE_ALL_CONTROLS;
ELSIF fbCrane.xBoomCommandConflict OR fbCrane.xGrappleCommandConflict THEN
    eHmiStatus := E_HmiStatus.CONFLICTING_COMMANDS;
ELSE
    eHmiStatus := E_HmiStatus.READY;
END_IF

// Text list IDs are strings; the enum value is used as the ID.
sHmiStatusId := INT_TO_STRING(TO_INT(eHmiStatus));
