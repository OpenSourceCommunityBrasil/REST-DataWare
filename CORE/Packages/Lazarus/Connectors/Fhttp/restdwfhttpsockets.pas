{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWFhttpSockets;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWFhttpBase, uRESTDWFReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWFReg', @uRESTDWFReg.Register);
end;

initialization
  RegisterPackage('RESTDWFhttpSockets', @Register);
end.
