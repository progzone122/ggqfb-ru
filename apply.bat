@echo off
setlocal
cd /d "%~dp0"

set "EXE=%~1"
if not "%EXE%"=="" goto haveexe
if exist "%ProgramFiles(x86)%\Steam\steamapps\common\Gawr Gura Quest for Bread\ggqfb_win.exe" (
    set "EXE=%ProgramFiles(x86)%\Steam\steamapps\common\Gawr Gura Quest for Bread\ggqfb_win.exe"
)
:haveexe
if "%EXE%"=="" (
    echo exe not found. Usage: apply.bat "C:\path\to\ggqfb_win.exe"
    exit /b 1
)
if not exist "%EXE%" (
    echo not found: %EXE%
    exit /b 1
)

where python >nul 2>nul
if errorlevel 1 (
    echo python is required in PATH: https://www.python.org/downloads/
    exit /b 1
)

set "GPCT=godotpcktool"
if exist "%~dp0tools\godotpcktool.exe" set "GPCT=%~dp0tools\godotpcktool.exe"

echo == 1/5 unpack embedded pck from exe
if exist work rmdir /s /q work
mkdir work
python "%~dp0tools\extract_pck.py" "%EXE%" "work\embedded.pck"
if errorlevel 1 exit /b 1
"%GPCT%" "work\embedded.pck" -a e -o "work\extracted" >nul
xcopy "work\extracted" "work\pristine\" /e /i /y /q >nul

echo == 2/5 overlay translation resources
xcopy "resources\*" "work\extracted\" /e /i /y /q >nul

echo == 3/5 build pck (V4, 4.7.2)
if exist "work\new.pck" del "work\new.pck"
"%GPCT%" "work\new.pck" -a a "work\extracted" --remove-prefix "work\extracted" --set-godot-version 4.7.2 >nul
if errorlevel 1 (
    echo pck build failed
    exit /b 1
)

echo == 4/5 splice pck into exe
python "%~dp0tools\splice_pck.py" "%EXE%" "work\new.pck" "work\patched.exe"
if errorlevel 1 exit /b 1

echo == 5/5 install
if not exist "%EXE%.orig" copy "%EXE%" "%EXE%.orig" >nul
move /y "work\patched.exe" "%EXE%" >nul
echo DONE: %EXE% patched
endlocal
