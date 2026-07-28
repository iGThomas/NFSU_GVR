@echo off
REM Build dsound.dll proxy (32-bit, static CRT) - adds DSBCAPS_GLOBALFOCUS so audio survives focus loss.
setlocal
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars32.bat" >nul 2>&1
cd /d "%~dp0"
if not exist build mkdir build
cl /nologo /LD /MT /EHsc /O2 /W3 /D_CRT_SECURE_NO_WARNINGS /Fo:build\ /Fd:build\ dsound.cpp ^
   /link /DEF:dsound.def /OUT:build\dsound.dll /IMPLIB:build\dsound.lib user32.lib
if errorlevel 1 ( echo BUILD FAILED & exit /b 1 )
echo BUILD_OK
