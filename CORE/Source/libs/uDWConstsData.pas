unit uDWConstsData;

{$I uRESTDW.inc}

interface

Uses
 SysUtils,  Classes,  DB
 {$IFDEF FPC}
  , memds;
 {$ELSE}
   {$IFDEF CLIENTDATASET}
    ,  DBClient
   {$ENDIF}
   {$IFDEF RESJEDI}
    , JvMemoryDataset
   {$ENDIF}
   {$IFDEF RESTKBMMEMTABLE}
    , kbmmemtable
   {$ENDIF}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    {$IFDEF RESTFDMEMTABLE}
     , FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
     FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
     FireDAC.Comp.DataSet, FireDAC.Comp.Client
    {$ENDIF}
   {$IFEND};
 {$ENDIF}


Type
 TMassiveDataset         = Class
End;

Type
 {$IFDEF FPC}
  TRESTDWClientSQLBase   = Class(TMemDataset)                   //Classe com as funcionalidades de um DBQuery
//   Constructor Create(AOwner: TComponent); Override;
 {$ELSE}
  {$IFDEF CLIENTDATASET}
  TRESTDWClientSQLBase   = Class(TClientDataSet)                 //Classe com as funcionalidades de um DBQuery
  {$ENDIF}
  {$IFDEF RESJEDI}
  TRESTDWClientSQLBase   = Class(TJvMemoryData)                 //Classe com as funcionalidades de um DBQuery
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
  TRESTDWClientSQLBase   = Class(TKbmMemtable)                 //Classe com as funcionalidades de um DBQuery
  {$ENDIF}
  {$IFDEF RESTFDMEMTABLE}
  TRESTDWClientSQLBase   = Class(TFDMemtable)                 //Classe com as funcionalidades de um DBQuery
  {$ENDIF}
 {$ENDIF}
  Private
   Function OnEditingState: Boolean;
  Public
   Procedure ForceInternalCalc;
End;

Type
 {$IFDEF FPC}
 TRESTDWDatasetArray = Array of TRESTDWClientSQLBase;
 {$ELSE}
 TRESTDWDatasetArray = Array Of TRESTDWClientSQLBase;
 {$ENDIF}

Type
 TSendEvent       = (seGET,       sePOST,
                     sePUT,       seDELETE);
 TTypeRequest     = (trHttp,      trHttps);
 TEncodeSelect    = (esASCII,     esUtf8);
 TDatabaseCharSet = (csUndefined, csWin1250, csWin1251, csWin1252,
                     csWin1253,   csWin1254, csWin1255, csWin1256,
                     csWin1257,   csWin1258);
 TObjectDirection = (odIN, odOUT, odINOUT);
 TDatasetEvents   = Procedure (DataSet: TDataSet) Of Object;

implementation


Function TRESTDWClientSQLBase.OnEditingState: Boolean;
Begin
 Result := not (State in [dsEdit, dsInsert]);
 If Result then
  Edit;
end;

Procedure TRESTDWClientSQLBase.ForceInternalCalc;
Var
 needsPost : Boolean;
 saveState : TDataSetState;
Begin
 needsPost := OnEditingState;
 saveState := setTempState(dsInternalCalc);
 Try
  RefreshInternalCalcFields(ActiveBuffer);
 Finally
  RestoreState(saveState);
 End;
 If needsPost Then
  Post;
End;

end.
