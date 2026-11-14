@echo off
setlocal EnableExtensions

rem Tracker_HUD full ERIDU maintenance gate.
rem Intended for the Visual Studio 2022 Native Tools Command Prompt.
rem Pure cmd.exe / batch: no PowerShell dependency.
rem
rem Pipeline:
rem   1. git pull --ff-only        (visible)
rem   2. headless Lazy sync        (visible)
rem   3. cumulative test suite     (silent console; Desktop transcript)
rem
rem Test transcript:
rem   %USERPROFILE%\Desktop\trackerHUD_test_results.txt

pushd "%~dp0"
if errorlevel 1 (
    echo [RED] Could not enter Tracker_HUD repository root.
    exit /b 1
)

echo.
echo [Tracker_HUD] 1/3 Git fast-forward pull
echo ----------------------------------------
git pull --ff-only
if errorlevel 1 goto :git_fail

echo.
echo [Tracker_HUD] 2/3 Neovim Lazy sync
echo -----------------------------------
nvim --headless -c "Lazy! sync" -c "qa!"
if errorlevel 1 goto :lazy_fail

echo.
echo [Tracker_HUD] 3/3 Cumulative tests
echo -----------------------------------
echo Running tests silently...
echo Results: %USERPROFILE%\Desktop\trackerHUD_test_results.txt

call tests\run_tests.bat >nul 2>&1
if errorlevel 1 goto :test_fail

echo.
echo [GREEN] Tracker_HUD full gate passed.
echo Test results: %USERPROFILE%\Desktop\trackerHUD_test_results.txt

popd
exit /b 0

:git_fail
set "TRACKER_HUD_EXIT=%errorlevel%"
echo.
echo [RED] git pull --ff-only failed.
popd
exit /b %TRACKER_HUD_EXIT%

:lazy_fail
set "TRACKER_HUD_EXIT=%errorlevel%"
echo.
echo [RED] Neovim Lazy sync failed.
popd
exit /b %TRACKER_HUD_EXIT%

:test_fail
set "TRACKER_HUD_EXIT=%errorlevel%"
echo.
echo [RED] Tracker_HUD cumulative tests failed.
echo Inspect: %USERPROFILE%\Desktop\trackerHUD_test_results.txt
popd
exit /b %TRACKER_HUD_EXIT%
