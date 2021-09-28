{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit restdwdriverunidac;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWDriverUNIDACReg, uRESTDWDriverUNIDAC, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWDriverUNIDACReg', @uRESTDWDriverUNIDACReg.Register);
end;

initialization
  RegisterPackage('restdwdriverunidac', @Register);
end.
