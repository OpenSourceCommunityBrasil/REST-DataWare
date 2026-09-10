@echo off
setlocal
cd /d "%~dp0"
where fpc.exe >nul 2>&1
if errorlevel 1 (
 echo fpc.exe nao encontrado no PATH.
 exit /b 1
)
fpc.exe -O2 -Mobjfpc -o..\..\RESTDWPackager.exe RESTDWPackager.pas
endlocal
