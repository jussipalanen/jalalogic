// JalaLogic Lite - PLC_PRG
// Simulation-only educational project. Not a certified safety function.
//
// Main program. Connects the HMI variables to FB_CraneControl.
// Visualization elements bind only to the xHmi*/rHmi*/sHmi* variables below;
// all control logic stays inside FB_CraneControl.
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
    sHmiStatusText        : STRING(60) := '';

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

// Operator status text, most important condition first.
IF fbCrane.xFault THEN
    CASE fbCrane.eFaultCode OF
        E_CraneFault.EMERGENCY_STOP:
            sHmiStatusText := 'FAULT: Emergency stop - release, then Reset';
        E_CraneFault.SIMULATED_FAULT:
            sHmiStatusText := 'FAULT: Simulated fault - clear, then Reset';
        E_CraneFault.INVALID_CONFIGURATION:
            sHmiStatusText := 'FAULT: Invalid configuration';
    ELSE
        sHmiStatusText := 'FAULT: Unknown';
    END_CASE
ELSIF fbCrane.xWaitingForRelease THEN
    sHmiStatusText := 'Release all controls';
ELSIF fbCrane.xBoomCommandConflict OR fbCrane.xGrappleCommandConflict THEN
    sHmiStatusText := 'Conflicting commands - no movement';
ELSE
    sHmiStatusText := 'Ready';
END_IF
