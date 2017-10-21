unit uDWConstsData;

{$I uRESTDW.inc}

interface

Uses
 SysUtils,  Classes,  DB
 {$IFDEF FPC}
  ,memds;
 {$ELSE}
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
 {$ELSE}
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
End;

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

end.
