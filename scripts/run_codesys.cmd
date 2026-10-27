@echo off
rem JalaLogic Lite - starts CODESYS without UI and runs one script.
rem Called by ./dev. Git Bash cannot pass --profile="name with spaces"
rem in the form CODESYS expects, so the command line is built here.
"%CODESYS_EXE%" --profile="%CODESYS_PROFILE%" --noUI --runscript="%~1"
exit /b %errorlevel%
