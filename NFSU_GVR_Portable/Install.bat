@echo off
rem ==========================================================================
rem  Double-click this file to install NFS Underground GlobalVR (arcade).
rem
rem  It asks Windows for administrator rights, then runs
rem  Install-NFSU-GVR-Portable.ps1 from this folder. Nothing else is needed:
rem  no PowerShell window to open, no folder to type, no execution policy.
rem  Advanced options can still be passed, e.g.  Install.bat -NoShortcut
rem ==========================================================================
setlocal
cd /d "%~dp0"

rem already running as administrator?
fltmc >nul 2>&1
if errorlevel 1 (
    echo Asking Windows for administrator rights...
    set "SELF=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

rem -STA: lets the installer show the Windows folder pickers (needed on Windows 7)
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0Install-NFSU-GVR-Portable.ps1" %*
echo.
echo You can close this window.
pause >nul
