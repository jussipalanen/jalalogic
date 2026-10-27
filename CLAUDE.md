
# JalaCrane Lite - Claude Code Instructions

## Project
JalaCrane Lite is a small educational forestry crane
control simulator built with CODESYS and Structured Text.

The project demonstrates PLC programming skills for
a software engineering portfolio.

## Technology
- CODESYS Development System V3
- IEC 61131-3 Structured Text (ST)
- CODESYS Visualization
- Git and GitHub

## Scope - Version 0.1.0
Implement only:
- Boom up/down
- Grapple open/close
- Simulated boom position (0–100%)
- Boom movement limits
- Manual controls
- Simple HMI visualization
- Basic simulated fault handling

Do not implement CAN bus, real hydraulic control,
3D graphics, databases or external APIs in v0.1.0.

## Architecture
- PLC_PRG: Main application
- FB_CraneControl: Crane control logic
- DUTs: Shared types, only when necessary
- CODESYS Visualization: Operator interface

Keep business logic separate from visualization.

## Structured Text Rules
- Follow IEC 61131-3 syntax supported by CODESYS.
- Use meaningful English variable names.
- Prefer simple, readable function blocks.
- Avoid unnecessary abstractions.
- Use explicit types and initialization.
- Use PLC cycle time for simulated movements.
- Validate operating limits.
- Ensure conflicting commands cannot cause movement.
- Default to no movement on invalid input or faults.

## Safety
This is a simulation-only educational project.
Never claim compliance with machinery safety standards.
Do not connect it to physical machinery.

Simulated emergency stop and limits are not
certified safety functions.

## AI Development
- Explain important technical decisions.
- Review existing code before making changes.
- Keep modifications small and focused.
- Do not invent CODESYS APIs or library functions.
- Distinguish generated code from tested code.
- Never claim compilation or simulation succeeded
  without actual verification.
- Provide manual CODESYS test steps when needed.

## Workflow
- Use feature/* branches for new features.
- Use fix/* branches for bug fixes.
- Use Conventional Commits.
- Follow Semantic Versioning.
- Maintain CHANGELOG.md.
- Do not commit directly to main.
- Do not push without user approval.

## Documentation
Maintain README.md with:
- Project description
- Features
- Technologies
- Installation instructions
- Simulation instructions
- Screenshots
- AI-assisted development disclosure

## Priorities
1. Working PLC logic
2. Correct simulation
3. Simple HMI
4. Clear documentation
5. Additional features only after v0.1.0

Keep the project achievable as a small demo.
