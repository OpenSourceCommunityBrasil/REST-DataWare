{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDWShellServices;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWShellServicesLazarus, uRESTDWShellServicesRegLazarus, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWShellServicesRegLazarus', 
    @uRESTDWShellServicesRegLazarus.Register);
end;

initialization
  RegisterPackage('RESTDWShellServices', @Register);
end.
