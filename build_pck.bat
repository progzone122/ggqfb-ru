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
    echo exe not found. Usage: build_pck.bat "C:\path\to\ggqfb_win.exe" [out.pck]
    exit /b 1
)
if not exist "%EXE%" (
    echo not found: %EXE%
    exit /b 1
)

set "OUT=%~2"
if "%OUT%"=="" set "OUT=%~dp0ggqfb_ru.pck"

where python >nul 2>nul
if errorlevel 1 (
    echo python is required in PATH: https://www.python.org/downloads/
    exit /b 1
)

set "GPCT=godotpcktool"
if exist "%~dp0tools\godotpcktool.exe" set "GPCT=%~dp0tools\godotpcktool.exe"

echo == 1/4 unpack embedded pck from exe
if exist work rmdir /s /q work
mkdir work
python "%~dp0tools\extract_pck.py" "%EXE%" "work\embedded.pck"
if errorlevel 1 exit /b 1
"%GPCT%" "work\embedded.pck" -a e -o "work\extracted" >nul
xcopy "work\extracted" "work\pristine\" /e /i /y /q >nul

echo == 2/4 overlay translation resources
xcopy "resources\*" "work\extracted\" /e /i /y /q >nul

echo == 3/4 build pck (V4, 4.7.2)
if exist "work\new.pck" del "work\new.pck"
"%GPCT%" "work\new.pck" -a a "work\extracted" --remove-prefix "work\extracted" --set-godot-version 4.7.2 >nul
if errorlevel 1 (
    echo pck build failed
    exit /b 1
)

echo == 4/4 write pck
copy /y "work\new.pck" "%OUT%" >nul
echo DONE: %OUT%
endlocal
