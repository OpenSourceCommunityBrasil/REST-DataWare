@echo off
setlocal
cd /d "%~dp0"
call "..\Delphi\BuildLatestDelphi.bat" Packager
endlocal
