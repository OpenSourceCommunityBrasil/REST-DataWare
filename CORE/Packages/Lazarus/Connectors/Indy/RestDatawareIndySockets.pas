{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RestDatawareIndySockets;

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
  {$I restdatawareindysockets.lrs}
  RegisterPackage('RestDatawareIndySockets', @Register);
end.
