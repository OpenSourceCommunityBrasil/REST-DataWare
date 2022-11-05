{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit restdwzeosdriver;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWZeosDriver, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWZeosDriver', @uRESTDWZeosDriver.Register);
end;

initialization
  {$I restdwlazarusdrivres.lrs}
  RegisterPackage('restdwzeosdriver', @Register);
end.
