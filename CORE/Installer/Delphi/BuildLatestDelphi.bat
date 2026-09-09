@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

tasklist /FI "IMAGENAME eq bds.exe" | find /I "bds.exe" >nul
if not errorlevel 1 (
 echo Uma IDE Delphi/BDS esta aberta. Feche a IDE antes de compilar o instalador.
 exit /b 1
)
tasklist /FI "IMAGENAME eq delphi32.exe" | find /I "delphi32.exe" >nul
if not errorlevel 1 (
 echo Delphi 7 esta aberto. Feche a IDE antes de compilar o instalador.
 exit /b 1
)

set ROOTDIR=
for /L %%V in (40,-1,9) do (
 for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Embarcadero\BDS\%%V.0" /v RootDir 2^>nul ^| find /I "RootDir"') do (
  if not defined ROOTDIR set ROOTDIR=%%B
 )
)

if not defined ROOTDIR (
 echo Nenhum Delphi moderno com suporte ao build dos instaladores foi localizado.
 exit /b 1
)

if not exist "%ROOTDIR%\bin\rsvars.bat" (
 echo rsvars.bat nao encontrado em %ROOTDIR%\bin.
 exit /b 1
)

call "%ROOTDIR%\bin\rsvars.bat"

if /I "%~1"=="Packager" (
 dcc32 -B -Q -U"..\Common" "..\Packager\RESTDWPackager.pas" -E"..\.."
 exit /b %errorlevel%
)

msbuild "VCL\RESTDWInstallerVCL.dproj" /t:Build /p:Config=Release /p:Platform=Win32
if errorlevel 1 exit /b 1

if exist "FMX\RESTDWInstallerFMX.dproj" (
 msbuild "FMX\RESTDWInstallerFMX.dproj" /t:Build /p:Config=Release /p:Platform=Win32
 if errorlevel 1 exit /b 1
)

endlocal
