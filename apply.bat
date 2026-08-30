@echo off
setlocal
cd /d "%~dp0"

set "PCK=%~1"
if not "%PCK%"=="" goto havepck
if exist "%ProgramFiles(x86)%\Steam\steamapps\common\Gawr Gura Quest for Bread\ggqfb_win.pck" (
    set "PCK=%ProgramFiles(x86)%\Steam\steamapps\common\Gawr Gura Quest for Bread\ggqfb_win.pck"
)
:havepck
if "%PCK%"=="" (
    echo pck not found. Usage: apply.bat "C:\path\to\ggqfb_win.pck"
    exit /b 1
)
if not exist "%PCK%" (
    echo not found: %PCK%
    exit /b 1
)

set "GPCT=godotpcktool"
if exist "%~dp0tools\godotpcktool.exe" set "GPCT=%~dp0tools\godotpcktool.exe"

echo == 1/4 unpack base pck
if exist work rmdir /s /q work
mkdir work
"%GPCT%" "%PCK%" -a e -o "work\extracted" >nul
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

echo == 4/4 install
if not exist "%PCK%.orig" copy "%PCK%" "%PCK%.orig" >nul
copy /y "work\new.pck" "%PCK%" >nul
echo DONE: %PCK%
endlocal
