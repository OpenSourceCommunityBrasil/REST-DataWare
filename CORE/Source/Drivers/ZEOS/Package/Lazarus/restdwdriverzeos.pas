{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWDriverZEOS;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWDriverZEOS, uRESTDWDriverZEOSReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWDriverZEOSReg', @uRESTDWDriverZEOSReg.Register);
end;

initialization
  RegisterPackage('RESTDWDriverZEOS', @Register);
end.
