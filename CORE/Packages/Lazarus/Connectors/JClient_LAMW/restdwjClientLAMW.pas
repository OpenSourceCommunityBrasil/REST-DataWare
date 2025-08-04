{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWJClientLAMW;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWjClientLAMWBase, uRESTDWjClientLAMWReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWjClientLAMWReg', @uRESTDWjClientLAMWReg.Register);
end;

initialization
  RegisterPackage('RESTDWJClientLAMW', @Register);
end.
