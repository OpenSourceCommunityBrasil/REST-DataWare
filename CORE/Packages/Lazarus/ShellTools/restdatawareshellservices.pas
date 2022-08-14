{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RestDatawareShellservices;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWShellServices, uRESTDWShellServicesReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWShellServicesReg', @uRESTDWShellServicesReg.Register);
end;

initialization
  RegisterPackage('RestDatawareShellservices', @Register);
end.
