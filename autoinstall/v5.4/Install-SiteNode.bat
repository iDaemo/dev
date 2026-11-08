@echo off
setlocal
rem ==========================================================================
rem SonosLibra - Site Node Installer Launcher v5.4
rem Keep this file ASCII only (no Thai text) and save WITHOUT BOM.
rem Setup-SiteNode.ps1 must be in the same folder as this file.
rem ==========================================================================

rem --- 1) Check Administrator rights ---------------------------------------
rem fltmc works even when the Server service is disabled (net session does not)
fltmc >nul 2>&1
if not errorlevel 1 goto :IsAdmin

if /i "%~1"=="--elevated" goto :ElevateFailed

rem Pass our own path via an environment variable so spaces or quotes
rem in the USB path cannot break the PowerShell command line.
set "SELF=%~f0"
powershell.exe -NoProfile -Command "try { Start-Process -FilePath $env:SELF -ArgumentList '--elevated' -Verb RunAs -ErrorAction Stop } catch { exit 1 }"
if errorlevel 1 goto :UacCancelled
exit /b 0

:IsAdmin
rem --- 2) Check the script exists ------------------------------------------
cd /d "%~dp0"
if not exist "%~dp0Setup-SiteNode.ps1" goto :ScriptMissing

rem --- 3) Run the installer -------------------------------------------------
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-SiteNode.ps1"
set "RC=%errorlevel%"
if "%RC%"=="0" exit /b 0

echo.
echo [!] Setup did NOT finish. Error code: %RC%
echo [!] Do NOT leave this PC on site. Fix the problem and run again.
pause
exit /b %RC%

:ElevateFailed
echo [!] Could not get Administrator rights.
echo [!] Log in with an Administrator account and run again.
pause
exit /b 1

:UacCancelled
echo [!] UAC was cancelled. Click YES on the UAC prompt to continue.
pause
exit /b 1

:ScriptMissing
echo [!] Setup-SiteNode.ps1 not found in: %~dp0
echo [!] Copy both files to the same folder on the USB drive.
pause
exit /b 1
