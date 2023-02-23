{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWZeos8Driver;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWZeosDriver, uRESTDWZAnalyser, uRESTDWZDbc, uRESTDWZDbcMetadata, 
  uRESTDWZDbcResultSet, uRESTDWZDbcStatement, uRESTDWZeosPhysLink, 
  uRESTDWZPlainDriver, uRESTDWZToken, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWZeosDriver', @uRESTDWZeosDriver.Register);
end;

initialization
  RegisterPackage('RESTDWZeos8Driver', @Register);
end.
