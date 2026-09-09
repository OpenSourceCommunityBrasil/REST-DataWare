{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWNativeLinkZeos;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWNativeLinkZeos, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWNativeLinkZeos', @uRESTDWNativeLinkZeos.Register);
end;

initialization
  RegisterPackage('RESTDWNativeLinkZeos', @Register);
end.
