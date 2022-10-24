set path_brcc32="D:\IDE\Embarcadero\Studio\7\Bin\brcc32.exe"

# Pacote Principal
%path_brcc32% -fo "..\..\Packages\Delphi\RESTDWCoreDesign.dcr" "Core.rc"

# Shell Services
%path_brcc32% -fo "..\..\Packages\Delphi\ShellTools\RESTDWShellServicesDesign.dcr" "ShellServices.rc"

# Sockets
%path_brcc32% -fo "..\..\Packages\Delphi\Connectors\Indy\RESTDWSocketIndyDesign.dcr" "SocketIndy.rc"
%path_brcc32% -fo "..\..\Packages\Delphi\Connectors\Ics\RESTDWSocketIcsDesign.dcr" "SocketIcs.rc"

# Drivers DBWare
%path_brcc32% -fo "..\..\Packages\Delphi\Drivers\FireDAC\RESTDWFireDACDriver.dcr" "DriverFireDAC.rc"
%path_brcc32% -fo "..\..\Packages\Delphi\Drivers\MyDAC\RESTDWMyDACDriver.dcr" "DriverMyDAC.rc"
%path_brcc32% -fo "..\..\Packages\Delphi\Drivers\UniDAC\RESTDWUniDACDriver.dcr" "DriverUNIDAC.rc"
%path_brcc32% -fo "..\..\Packages\Delphi\Drivers\Zeos\RESTDWZeosDriver.dcr" "DriverZEOS.rc"