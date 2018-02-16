unit uDmService;

interface

uses
  SysUtils, Classes, IBConnection, sqldb, SysTypes, uDWDatamodule,
  uDWJSONObject, Dialogs, ServerUtils, uDWConsts, uDWConstsData,
  RestDWServerFormU, uRESTDWPoolerDB, uRESTDWServerEvents,  uRESTDWLazDriver;


type

  { TServerMethodDM }

  TServerMethodDM = class(TServerMethodDataModule)
    DWServerEvents1: TDWServerEvents;
    RESTDWDriverFD1: TRESTDWLazDriver;
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    Server_FDConnection: TIBConnection;
    FDQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleWelcomeMessage(Welcomemsg: String);
    procedure DWServerEvents1EventsgetemployeeReplyEvent(Var Params: TDWParams;
      Var Result: String);
    procedure DWServerEvents1EventsservertimeReplyEvent(Var Params: TDWParams;
      Var Result: String);
    procedure ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
      Context: string; var Params: TDWParams; var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.lfm}

procedure TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
begin
 RESTDWPoolerDB1.Active := RestDWForm.cbPoolerState.Checked;
end;

procedure TServerMethodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
  Context: string; var Params: TDWParams; var Result: string);
Begin
 Case SendType Of
  sePOST   : Result := '{(''STATUS'',   ''NOK''), (''MENSAGEM'', ''Método não encontrado'')}';
 End;
End;

procedure TServerMethodDM.DataModuleWelcomeMessage(Welcomemsg: String);
begin
 RestDWForm.edBD.Text := Welcomemsg;
end;

procedure TServerMethodDM.DWServerEvents1EventsgetemployeeReplyEvent(
  Var Params: TDWParams; Var Result: String);
Var
 JSONValue: TJSONValue;
begin
 JSONValue          := TJSONValue.Create;
 Try
  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add('select * from employee');
  Try
   FDQuery1.Open;
   JSONValue.Encoding := Encoding;
   JSONValue.Encoded  := False;
   JSONValue.LoadFromDataset('employee', FDQuery1, False,  Params.JsonMode, '');
   Params.ItemsString['result'].AsString := JSONValue.ToJSON;
   Params.ItemsString['segundoparam'].AsString := 'teste de array';
  Except
  End;
 Finally
  JSONValue.Free;
 End;
end;

procedure TServerMethodDM.DWServerEvents1EventsservertimeReplyEvent(
  Var Params: TDWParams; Var Result: String);
begin
 If Params.ItemsString['inputdata'].AsString <> '' Then //servertime
  Params.ItemsString['result'].AsDateTime := Now
 Else
  Params.ItemsString['result'].AsDateTime := Now - 1;
 Params.ItemsString['resultstring'].AsString := 'testservice';
end;

procedure TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
Var
 porta_BD,
 servidor,
 database,
 pasta,
 usuario_BD,
 senha_BD      : String;
Begin
 servidor      := RestDWForm.DatabaseIP;
 database      := RestDWForm.edBD.Text;
 pasta         := IncludeTrailingPathDelimiter(RestDWForm.edPasta.Text);
 porta_BD      := RestDWForm.edPortaBD.Text;
 usuario_BD    := RestDWForm.edUserNameBD.Text;
 senha_BD      := RestDWForm.edPasswordBD.Text;
 RestDWForm.DatabaseName := pasta + database;
 TIBConnection(Sender).HostName     := Servidor;
 TIBConnection(Sender).DatabaseName := RestDWForm.DatabaseName;
 TIBConnection(Sender).UserName     := usuario_BD;
 TIBConnection(Sender).Password     := senha_BD;
end;

end.
