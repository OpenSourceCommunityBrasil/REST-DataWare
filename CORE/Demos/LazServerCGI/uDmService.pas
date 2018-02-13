unit uDmService;

interface

uses
  SysUtils, Classes, IBConnection, sqldb, uDWDatamodule,
  uDWJSONObject, Dialogs, uDWConstsData,
  uRESTDWPoolerDB, uRESTDWServerEvents, uRESTDWLazDriver,  uConsts;

type

  { TServerMethodDM }

  TServerMethodDM = class(TServerMethodDataModule)
    DWServerEvents1: TDWServerEvents;
    FDQuery1: TSQLQuery;
    RESTDWLazDriver1: TRESTDWLazDriver;
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    Server_FDConnection: TIBConnection;
    SQLTransaction1: TSQLTransaction;
    procedure DWServerEvents1EventsgetemployeeReplyEvent(Var Params: TDWParams;
      Var Result: String);
    procedure DWServerEvents1EventsservertimeReplyEvent(Var Params: TDWParams;
      Var Result: String);
    procedure DWServerEvents1EventstesteReplyEvent(Var Params: TDWParams;
      Var Result: String);
    procedure ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
      Context: string; var Params: TDWParams; var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
  private
    { Private declarations }
   Function ConsultaBanco(Var Params : TDWParams) : String;Overload;
  public
    { Public declarations }
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.lfm}

Function TServerMethodDM.ConsultaBanco(Var Params : TDWParams) : String;
Var
 vSQL      : String;
 JSONValue : TJSONValue;
 fdQuery   : TSQLQuery;
Begin
 If Params.ItemsString['SQL'] <> Nil Then
  Begin
   JSONValue          := TJSONValue.Create;
   If Params.ItemsString['SQL'].value <> '' Then
    Begin
     If Params.ItemsString['TESTPARAM'] <> Nil Then
      Params.ItemsString['TESTPARAM'].SetValue('OK, OK');
     vSQL      := Params.ItemsString['SQL'].value;
     fdQuery   := TSQLQuery.Create(Nil);
     Try
      fdQuery.DataBase := Server_FDConnection;
      fdQuery.SQL.Add(vSQL);
      JSONValue.LoadFromDataset('sql', fdQuery, EncodedData);
      Result             := JSONValue.ToJSON;
     Finally
      JSONValue.Free;
      fdQuery.Free;
     End;
    End;
  End;
End;

procedure TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
begin
 RESTDWPoolerDB1.Active := ActivePooler;
end;

procedure TServerMethodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
  Context: string; var Params: TDWParams; var Result: string);
Begin
 Case SendType Of
  sePOST   :
   Begin
    If UpperCase(Context) = Uppercase('ConsultaBanco') Then
     Result := ConsultaBanco(Params)
    Else
     Result := '{(''STATUS'',   ''NOK''), (''MENSAGEM'', ''Método não encontrado'')}';
   End;
 End;
End;

procedure TServerMethodDM.DWServerEvents1EventsservertimeReplyEvent(
  Var Params: TDWParams; Var Result: String);
begin
 If Params.ItemsString['inputdata'].AsString <> '' Then //servertime
  Params.ItemsString['result'].AsDateTime := Now
 Else
  Params.ItemsString['result'].AsDateTime := Now - 1;
 Params.ItemsString['resultstring'].AsString := 'testservice';
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
   JSONValue.Encoding        := Encoding;
   JSONValue.DatabaseCharSet := RESTDWLazDriver1.DatabaseCharSet;
   JSONValue.LoadFromDataset('employee', FDQuery1, False,  Params.JsonMode, '');
   Params.ItemsString['result'].AsString := JSONValue.ToJSON;
   Params.ItemsString['segundoparam'].AsString := 'teste de array';
  Except
  End;
 Finally
  JSONValue.Free;
 End;
end;

procedure TServerMethodDM.DWServerEvents1EventstesteReplyEvent(
  Var Params: TDWParams; Var Result: String);
begin
 Params.ItemsString['result'].Asstring := 'hello World';
end;

procedure TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
Begin
 TIBConnection(Sender).HostName     := Servidor;
 TIBConnection(Sender).DatabaseName := pasta + database;
 TIBConnection(Sender).UserName     := usuario_BD;
 TIBConnection(Sender).Password     := senha_BD;
end;

end.
