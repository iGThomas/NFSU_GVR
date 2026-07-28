@echo off
REM Build GvrLaunch.exe - launcher that applies the gvr_settings.ini [Display] resolution in memory.
setlocal
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars32.bat" >nul 2>&1
cd /d "%~dp0"
if not exist build mkdir build
REM Embed NFSU_GVR.ico so the exe carries the game's icon in Explorer/taskbar/alt-tab.
rc /nologo /fo build\GvrLaunch.res GvrLaunch.rc
if errorlevel 1 ( echo RESOURCE COMPILE FAILED & exit /b 1 )
cl /nologo /MT /EHsc /O2 /W3 /D_CRT_SECURE_NO_WARNINGS /Fo:build\ /Fd:build\ GvrLaunch.cpp ^
   /link /OUT:build\GvrLaunch.exe /SUBSYSTEM:WINDOWS build\GvrLaunch.res ^
   user32.lib kernel32.lib gdi32.lib ole32.lib oleaut32.lib
if errorlevel 1 ( echo BUILD FAILED & exit /b 1 )
echo BUILD_OK
