{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit restdwlazarusdriver;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWLazarusDriver, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWLazarusDriver', @uRESTDWLazarusDriver.Register);
end;

initialization
  RegisterPackage('restdwlazarusdriver', @Register);
end.
