{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWFphttpSockets;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWFphttpBase, uRESTDWFphttpReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWFphttpReg', @uRESTDWFphttpReg.Register);
end;

initialization
  RegisterPackage('RESTDWFphttpSockets', @Register);
end.
