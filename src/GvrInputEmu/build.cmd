@echo off
REM Build GvrInputEmu -> GVRInputRaw.dll (32-bit, static CRT).
REM 32-bit: the host UndergroundGVR.exe is a 2003 x86 process.
REM Static CRT (/MT): no runtime redistributable dependency inside the ancient host process.

setlocal
set VCVARS=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars32.bat
if not exist "%VCVARS%" (
    echo ERROR: vcvars32.bat not found at "%VCVARS%"
    exit /b 1
)
call "%VCVARS%" >nul 2>&1
if errorlevel 1 ( echo ERROR: vcvars32 failed & exit /b 1 )

cd /d "%~dp0"
if not exist build mkdir build

cl /nologo /LD /MT /EHsc /O2 /W3 ^
   /Fo:build\ /Fd:build\ ^
   GvrInputEmu.cpp ^
   /link /DEF:GvrInputEmu.def /OUT:build\GVRInputRaw.dll /IMPLIB:build\GvrInputEmu.lib ^
   hid.lib setupapi.lib user32.lib

if errorlevel 1 ( echo BUILD FAILED & exit /b 1 )

echo BUILD_OK
dir /b build\GVRInputRaw.dll
endlocal
