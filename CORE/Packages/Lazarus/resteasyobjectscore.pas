{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit resteasyobjectscore;

interface

uses
  ServerUtils, SysTypes, uDWConsts, uDWJSONObject, uDWJSONTools, uRESTDWBase, 
  uRESTDWReg, uRESTDWMasterDetailData, uRESTDWPoolerDB, uZlibLaz, 
  uDWPoolerMethod, uDWDatamodule, uDWJSON, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWReg', @uRESTDWReg.Register);
end;

initialization
  RegisterPackage('resteasyobjectscore', @Register);
end.
