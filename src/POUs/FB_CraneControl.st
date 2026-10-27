// JalaLogic - FB_CraneControl
// Simulation-only educational project. Not a certified safety function.
//
// CODESYS: Add Object > POU > name "FB_CraneControl", type "Function Block",
// language "Structured Text (ST)".
//
// ============================================================================
// DECLARATION PART
// Paste from "FUNCTION_BLOCK" down to the last "END_VAR" into the
// declaration editor (upper half) of the POU, replacing the generated text.
// ============================================================================

FUNCTION_BLOCK FB_CraneControl
VAR_INPUT
    xBoomUp               : BOOL := FALSE;  // Manual command: raise boom (hold to move)
    xBoomDown             : BOOL := FALSE;  // Manual command: lower boom (hold to move)
    xGrappleOpen          : BOOL := FALSE;  // Manual command: open grapple
    xGrappleClose         : BOOL := FALSE;  // Manual command: close grapple
    xEmergencyStopPressed : BOOL := FALSE;  // Simulated E-stop, TRUE = pressed
    xSimulatedFault       : BOOL := FALSE;  // Simulated hydraulic fault injection
    xReset                : BOOL := FALSE;  // Fault reset, acts on rising edge
    tCycleTime            : TIME := T#20MS; // Must match the calling task interval
    rBoomSpeed            : REAL := 10.0;   // Boom speed in percent per second
END_VAR
VAR_OUTPUT
    rBoomPosition           : REAL := 0.0;   // Simulated boom position, 0..100 %
    xBoomMovingUp           : BOOL := FALSE;
    xBoomMovingDown         : BOOL := FALSE;
    xBoomAtUpperLimit       : BOOL := FALSE;
    xBoomAtLowerLimit       : BOOL := TRUE;
    xGrappleIsOpen          : BOOL := FALSE;
    xBoomCommandConflict    : BOOL := FALSE; // Up and down requested together
    xGrappleCommandConflict : BOOL := FALSE; // Open and close requested together
    xWaitingForRelease      : BOOL := FALSE; // All commands must be released first
    xReady                  : BOOL := FALSE; // No fault, movement permitted
    xFault                  : BOOL := FALSE; // A fault is latched
    eFaultCode              : E_CraneFault := E_CraneFault.NONE;
END_VAR
VAR
    fbResetTrigger  : R_TRIG;
    rPosition       : REAL := 0.0;
    rStep           : REAL := 0.0;
    xConfigValid    : BOOL := FALSE;
    eActiveFault    : E_CraneFault := E_CraneFault.NONE;
    xAnyCommand     : BOOL := FALSE;
    xMotionAllowed  : BOOL := FALSE;
    xWaitForRelease : BOOL := TRUE;  // TRUE at start: a held button must not move the crane
END_VAR
VAR CONSTANT
    c_rBoomMin      : REAL := 0.0;
    c_rBoomMax      : REAL := 100.0;
    c_rMaxBoomSpeed : REAL := 100.0;
    c_tMaxCycleTime : TIME := T#1S;
END_VAR

// ============================================================================
// IMPLEMENTATION PART
// Paste everything below this block into the implementation editor
// (lower half) of the POU.
// ============================================================================

// 1. Reset edge detection: holding Reset must not reset repeatedly.
fbResetTrigger(CLK := xReset);

// 2. Validate configuration. Invalid values are treated as a fault.
xConfigValid := (tCycleTime > T#0MS)
                AND (tCycleTime <= c_tMaxCycleTime)
                AND (rBoomSpeed > 0.0)
                AND (rBoomSpeed <= c_rMaxBoomSpeed);

// 3. Determine the currently active fault source, highest priority first.
IF xEmergencyStopPressed THEN
    eActiveFault := E_CraneFault.EMERGENCY_STOP;
ELSIF xSimulatedFault THEN
    eActiveFault := E_CraneFault.SIMULATED_FAULT;
ELSIF NOT xConfigValid THEN
    eActiveFault := E_CraneFault.INVALID_CONFIGURATION;
ELSE
    eActiveFault := E_CraneFault.NONE;
END_IF

// 4. Latch faults. Reset clears the latch only when no fault source is active.
IF eActiveFault <> E_CraneFault.NONE THEN
    eFaultCode := eActiveFault;
ELSIF fbResetTrigger.Q THEN
    eFaultCode := E_CraneFault.NONE;
END_IF
xFault := (eFaultCode <> E_CraneFault.NONE);

// 5. After a fault (and at start-up) all commands must be released before
//    movement is allowed again. Reset therefore never restarts movement.
xAnyCommand := xBoomUp OR xBoomDown OR xGrappleOpen OR xGrappleClose;
IF xFault THEN
    xWaitForRelease := TRUE;
ELSIF NOT xAnyCommand THEN
    xWaitForRelease := FALSE;
END_IF
xMotionAllowed := NOT xFault AND NOT xWaitForRelease;

// 6. Conflicting commands result in no movement of that function.
xBoomCommandConflict    := xBoomUp AND xBoomDown;
xGrappleCommandConflict := xGrappleOpen AND xGrappleClose;

// 7. Boom movement with limits. xMotionAllowed implies a valid configuration.
xBoomMovingUp   := xMotionAllowed AND xBoomUp AND NOT xBoomDown
                   AND (rPosition < c_rBoomMax);
xBoomMovingDown := xMotionAllowed AND xBoomDown AND NOT xBoomUp
                   AND (rPosition > c_rBoomMin);

IF xMotionAllowed THEN
    // TIME_TO_REAL returns milliseconds.
    rStep := rBoomSpeed * TIME_TO_REAL(tCycleTime) / 1000.0;
ELSE
    rStep := 0.0;
END_IF

IF xBoomMovingUp THEN
    rPosition := rPosition + rStep;
ELSIF xBoomMovingDown THEN
    rPosition := rPosition - rStep;
END_IF
rPosition := LIMIT(c_rBoomMin, rPosition, c_rBoomMax);

rBoomPosition     := rPosition;
xBoomAtUpperLimit := (rPosition >= c_rBoomMax);
xBoomAtLowerLimit := (rPosition <= c_rBoomMin);

// 8. Grapple. On fault or conflict the grapple keeps its current state,
//    so a held load is not released unexpectedly.
IF xMotionAllowed AND NOT xGrappleCommandConflict THEN
    IF xGrappleOpen THEN
        xGrappleIsOpen := TRUE;
    ELSIF xGrappleClose THEN
        xGrappleIsOpen := FALSE;
    END_IF
END_IF

// 9. Status outputs.
xWaitingForRelease := xWaitForRelease AND NOT xFault;
xReady             := xMotionAllowed;
