@echo off
rem ---------------------------------------------------------------
rem Build Powersoft Thai Professional EGA/VGA 3.10 driver (THAIPRO.EXE)
rem Toolchain: JWasm 2.20 + JWlink 2.0 (in .\tools\)
rem ---------------------------------------------------------------
setlocal
cd /d "%~dp0"

if not exist tools\JWasm.exe (
    echo ERROR: tools\JWasm.exe not found. See README.md for toolchain setup.
    exit /b 1
)

if not exist build mkdir build

set M=INSTALL INT9 INT8 INT10 INT17 INT60 MENU GAP
for %%F in (%M%) do (
    echo Assembling src\%%F.ASM
    tools\JWasm.exe -Cu -q -Fo build\%%F.OBJ src\%%F.ASM
    if errorlevel 1 exit /b 1
)

echo Linking build\THAIPRO.EXE
tools\JWlink.exe @link.rsp
if errorlevel 1 exit /b 1

if not exist dist mkdir dist
copy /y build\THAIPRO.EXE dist\THAIPRO.EXE >nul
echo.
echo Done: dist\THAIPRO.EXE
endlocal
