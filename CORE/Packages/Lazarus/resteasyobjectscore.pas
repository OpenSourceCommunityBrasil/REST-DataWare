{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit resteasyobjectscore;

{$warn 5023 off : no warning about unused units}
interface

uses
  ServerUtils, SysTypes, uDWConsts, uDWJSONObject, uDWJSONTools, uRESTDWBase, 
  uRESTDWReg, uRESTDWMasterDetailData, uRESTDWPoolerDB, uZlibLaz, 
  uDWPoolerMethod, uDWDatamodule, uDWJSON, uDWMassiveBuffer, uDWDataset, 
  uDWSqlEditor, uAboutForm, uDWAbout, uDWConstsData, uDWJSONViewer, 
  DWDCPbase64, DWDCPblockciphers, DWDCPconst, DWDCPcrypt2, DWDCPtypes, 
  DWDCPcast256, DWDCPrijndael, DWDCPsha256, uDWUpdSqlEditor, utemplateproglaz, 
  uRESTDWFileBuffer, uDWResponseTranslator, uDWFieldSourceEditor, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWReg', @uRESTDWReg.Register);
end;

initialization
  RegisterPackage('resteasyobjectscore', @Register);
end.
