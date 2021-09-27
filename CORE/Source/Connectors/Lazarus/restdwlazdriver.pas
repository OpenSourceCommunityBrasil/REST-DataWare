{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWLazDriver;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRestDWLazDriver, uRestDWLazDriverReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRestDWLazDriverReg', @uRestDWLazDriverReg.Register);
end;

initialization
  RegisterPackage('RESTDWLazDriver', @Register);
end.
