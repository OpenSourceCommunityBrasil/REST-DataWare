unit uDmService;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uDWDatamodule, uRESTDWPoolerDB, uRESTDWServerEvents,
  uRESTDWDriverZEOS, ZConnection, ZDataset, untServer, db, SysTypes,
  uDWJSONObject, Dialogs,  fpjson, jsonparser,
  ServerUtils, uDWConsts, uDWConstsData, uRESTDWServerContext, uDWJSONTools;

type

  { TServerMethodDM }

  TServerMethodDM = class(TServerMethodDataModule)
    DWServerEvents1: TDWServerEvents;
    RESTDWDriverZeos1: TRESTDWDriverZeos;
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    ZConnection1: TZConnection;
    procedure DWServerEvents1EventstesteserverReplyEvent(var Params: TDWParams;
      var Result: String);
  private

  public

  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

{$R *.lfm}

{ TServerMethodDM }

procedure TServerMethodDM.DWServerEvents1EventstesteserverReplyEvent(
  var Params: TDWParams; var Result: String);
var
  Json : string;
  jData : TJSONData;
begin
  Json := '{"Nome":"Gledston Prego","Cidade":"Brasília-DF"}';
  try
    Result := Json;
  finally
  end;
end;

end.

