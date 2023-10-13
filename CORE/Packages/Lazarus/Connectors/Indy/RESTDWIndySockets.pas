{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWIndySockets;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWIdBase, uRESTDWIdReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWIdReg', @uRESTDWIdReg.Register);
end;

initialization
  RegisterPackage('RESTDWIndySockets', @Register);
end.
