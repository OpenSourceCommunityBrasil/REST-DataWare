{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWLazDriver;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRestDWLazDriver, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRestDWLazDriver', @uRestDWLazDriver.Register);
end;

initialization
  RegisterPackage('RESTDWLazDriver', @Register);
end.
