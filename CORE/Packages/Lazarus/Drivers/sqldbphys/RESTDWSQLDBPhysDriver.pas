{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWSQLDBPhysDriver;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWSQLDBPhysLink, uRESTDWSQLDBConnection, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWSQLDBPhysLink', @uRESTDWSQLDBPhysLink.Register);
end;

initialization
  RegisterPackage('RESTDWSQLDBPhysDriver', @Register);
end.
