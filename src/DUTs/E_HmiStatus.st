// JalaLogic Lite - E_HmiStatus
// Simulation-only educational project. Not a certified safety function.
//
// Operator status shown on the HMI. PLC_PRG selects the status; the
// visualization looks up the displayed text in the text list TL_Status,
// so the PLC code contains no language-specific text.
// The numeric values are the text list IDs - keep both in sync.
//
// CODESYS: Add Object > DUT > name "E_HmiStatus", type "Enumeration".
// Replace the generated text in the DUT editor with everything below.

{attribute 'qualified_only'}
TYPE E_HmiStatus :
(
    READY                       := 0,   // No fault, no conflict, crane can be operated
    CONFLICTING_COMMANDS        := 1,   // Opposite commands active at the same time
    RELEASE_ALL_CONTROLS        := 2,   // Commands must be released after start-up or reset
    FAULT_EMERGENCY_STOP        := 10,  // Simulated emergency stop latched
    FAULT_SIMULATED             := 11,  // Simulated hydraulic fault latched
    FAULT_INVALID_CONFIGURATION := 12,  // Cycle time or boom speed outside valid range
    FAULT_UNKNOWN               := 19   // Fault code not handled by PLC_PRG
);
END_TYPE
