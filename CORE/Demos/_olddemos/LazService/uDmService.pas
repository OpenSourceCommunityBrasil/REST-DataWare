unit uDmService;

interface

uses
  SysUtils, Classes, IBConnection, sqldb, mysql55conn, mysql50conn,
  uDWDatamodule, uDWJSONObject, Dialogs, ZConnection, ZDataset, uDWConstsData,
  uRESTDWPoolerDB, uRESTDWServerEvents, uRESTDWServerContext,
  uRESTDWDriverZEOS, uConsts, uDWConsts, uSystemEvents, uDWConstsCharset, ServerUtils, SysTypes;

Const
 Const404Page = '404.html';

type
  TServerMethodDM = class(TServerMethodDataModule)
    DWServerContext1: TDWServerContext;
    DWServerEvents1: TDWServerEvents;
    RESTDWDriverZeos1: TRESTDWDriverZeos;
    RESTDWPoolerZEOS: TRESTDWPoolerDB;
    ZConnection1: TZConnection;
    FDQuery1: TZQuery;
    FDQLogin: TZQuery;
    procedure DataModuleUserTokenAuth(Welcomemsg, AccessTag: String;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage: String; var TokenID: String;
      var Accept: Boolean);
    procedure DWServerEvents1EventsservertimeReplyEvent(var Params: TDWParams;
      var Result: String);
    procedure ZConnection1BeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

uses uDWJSONTools;

{$R *.lfm}

procedure TServerMethodDM.DataModuleUserTokenAuth(Welcomemsg,
  AccessTag: String; Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
  var ErrorCode: Integer; var ErrorMessage: String; var TokenID: String;
  var Accept: Boolean);
begin
 //Novo código para validação
 Accept := True;
 // AuthOptions.BeginTime
 // AuthOptions.EndTime
 // AuthOptions.Secrets
end;

procedure TServerMethodDM.DWServerEvents1EventsservertimeReplyEvent(
  var Params: TDWParams; var Result: String);
begin
  Result := 'teste';
end;

procedure TServerMethodDM.ZConnection1BeforeConnect(Sender: TObject);
begin
 //TZConnection(Sender).Database := pasta + database;
 //TZConnection(Sender).HostName := Servidor;
 //TZConnection(Sender).Port     := porta_BD;
 //TZConnection(Sender).User     := Usuario_BD;
 //TZConnection(Sender).Password := Senha_BD;
 //TZConnection(Sender).LoginPrompt := FALSE;
end;

end.
