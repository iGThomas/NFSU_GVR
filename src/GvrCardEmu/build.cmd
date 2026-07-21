@echo off
REM Build GvrCardEmu -> GVRSCR28.dll (32-bit).
REM Must be 32-bit: the host (UniverShell2.exe / UndergroundGVR.exe) is a 2003 x86 process.
REM Static CRT (/MT) so the DLL has no runtime redistributable dependency - it is loaded
REM into a process that links the ancient MSVC 7.1 runtimes.

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
   GvrCardEmu.cpp ^
   /link /DEF:GvrCardEmu.def /OUT:build\GVRSCR28.dll /IMPLIB:build\GvrCardEmu.lib ^
   user32.lib

if errorlevel 1 ( echo BUILD FAILED ^(GVRSCR28^) & exit /b 1 )

REM PCSCSCR2.dll - the virtual PC/SC layer. Without this the shell asks Windows
REM directly whether a physical reader exists (via SCDiagnostic.dll) and greys out CAREER,
REM no matter how well the virtual card behaves.
cl /nologo /LD /MT /EHsc /O2 /W3 ^
   /Fo:build\pcsc_ /Fd:build\pcsc_ ^
   GvrPcscEmu.cpp ^
   /link /DEF:GvrPcscEmu.def /OUT:build\PCSCSCR2.dll /IMPLIB:build\GvrPcscEmu.lib ^
   user32.lib

if errorlevel 1 ( echo BUILD FAILED ^(PCSCSCR2^) & exit /b 1 )

REM GvrCardKey.exe - out-of-process key watcher. In-process keyboard detection does not work
REM inside UniverShell2 (see the header of GvrCardKey.cpp), so S/F9 are watched from here.
cl /nologo /MT /EHsc /O2 /W3 ^
   /Fo:build\key_ /Fd:build\key_ ^
   GvrCardKey.cpp ^
   /link /OUT:build\GvrCardKey.exe /SUBSYSTEM:WINDOWS ^
   user32.lib kernel32.lib

if errorlevel 1 ( echo BUILD FAILED ^(GvrCardKey^) & exit /b 1 )

echo BUILD_OK
dir /b build\GVRSCR28.dll build\PCSCSCR2.dll build\GvrCardKey.exe
endlocal
