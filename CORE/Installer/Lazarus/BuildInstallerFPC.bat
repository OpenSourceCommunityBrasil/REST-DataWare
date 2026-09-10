@echo off
setlocal
cd /d "%~dp0"
tasklist /FI "IMAGENAME eq lazarus.exe" | find /I "lazarus.exe" >nul
if not errorlevel 1 (
 echo Lazarus esta aberto. Feche a IDE antes de compilar o instalador.
 exit /b 1
)
where fpc.exe >nul 2>&1
if errorlevel 1 (
 echo fpc.exe nao encontrado no PATH.
 exit /b 1
)
fpc.exe -O2 -Mobjfpc -Fu..\Common -o..\..\RESTDWInstallerFPC.exe RESTDWInstallerFPC.pas
endlocal
