@echo off
setlocal EnableExtensions

rem Tracker_HUD repeatable performance profile runner.
rem Pure cmd.exe only. No PowerShell dependency.
rem This is an observational fixture, not a wall-clock CI gate.

set "TRACKER_HUD_PROFILE_RESULTS=%USERPROFILE%\Desktop\trackerHUD_profile_results.txt"
set "TRACKER_HUD_PROFILE_TEMP=%TEMP%\trackerHUD_profile_output_%RANDOM%_%RANDOM%.txt"

if not exist "%USERPROFILE%\Desktop" (
    echo [FAIL] Desktop directory not found: "%USERPROFILE%\Desktop"
    exit /b 1
)

pushd "%~dp0"
if errorlevel 1 (
    echo [FAIL] Could not enter Tracker_HUD repository root.
    exit /b 1
)

echo [Tracker_HUD] Running automated ASM performance profile...
echo [Tracker_HUD] Results: %TRACKER_HUD_PROFILE_RESULTS%
echo.

nvim --headless -c "lua local ok, err = pcall(vim.cmd, 'luafile tests/asm_performance_profile_fixture.lua'); if not ok then io.stderr:write(tostring(err) .. string.char(10)); vim.cmd('cquit 1') end" -c "qa!" > "%TRACKER_HUD_PROFILE_TEMP%" 2>&1
set "PROFILE_EXIT=%errorlevel%"

type "%TRACKER_HUD_PROFILE_TEMP%"
copy /y "%TRACKER_HUD_PROFILE_TEMP%" "%TRACKER_HUD_PROFILE_RESULTS%" >nul
del /q "%TRACKER_HUD_PROFILE_TEMP%" >nul 2>&1

if not "%PROFILE_EXIT%"=="0" (
    echo.
    echo [RED] Tracker_HUD automated performance profile failed.
    echo Results: %TRACKER_HUD_PROFILE_RESULTS%
    popd
    exit /b %PROFILE_EXIT%
)

echo.
echo [GREEN] Tracker_HUD automated performance profile passed.
echo Results: %TRACKER_HUD_PROFILE_RESULTS%

popd
exit /b 0
