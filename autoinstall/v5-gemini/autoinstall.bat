@echo off
:: ตรวจสอบและขอสิทธิ์ Administrator อัตโนมัติ
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-SiteNode.ps1"
pause