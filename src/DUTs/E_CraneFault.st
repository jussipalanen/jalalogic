// JalaCrane Lite - E_CraneFault
// Simulation-only educational project. Not a certified safety function.
//
// CODESYS: Add Object > DUT > name "E_CraneFault", type "Enumeration".
// Replace the generated text in the DUT editor with everything below.

{attribute 'qualified_only'}
TYPE E_CraneFault :
(
    NONE                  := 0,   // No fault latched
    EMERGENCY_STOP        := 1,   // Simulated emergency stop pressed
    SIMULATED_FAULT       := 2,   // Operator-injected simulated hydraulic fault
    INVALID_CONFIGURATION := 3    // Cycle time or boom speed outside valid range
);
END_TYPE
