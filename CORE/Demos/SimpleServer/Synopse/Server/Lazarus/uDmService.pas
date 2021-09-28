unit uDmService;

interface

uses
  SysUtils, Classes, IBConnection, sqldb, db, SysTypes, uDWDatamodule,
  uDWJSONObject, Dialogs, ZConnection, ZDataset,
  ServerUtils, uDWConsts, uDWConstsData, RestDWServerFormU, uRESTDWPoolerDB,
  uRESTDWServerEvents, uRESTDWServerContext, uRestDWLazDriver,
  uRESTDWDriverZEOS, uDWJSONTools;


type

  { TServerMethodDM }

  TServerMethodDM = class(TServerMethodDataModule)
    DataSource1: TDataSource;
    dwcrEmployee: TDWContextRules;
    DWServerContext1: TDWServerContext;
    DWServerEvents1: TDWServerEvents;
    IBConnection1: TIBConnection;
    RESTDWDriverZeos1: TRESTDWDriverZeos;
    RESTDWLazDriver1: TRESTDWLazDriver;
    RESTDWPoolerSqlDB: TRESTDWPoolerDB;
    RESTDWPoolerZEOS: TRESTDWPoolerDB;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure DataModuleGetToken(Welcomemsg, AccessTag: String;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage: String; var TokenID: String;
      var Accept: Boolean);
    procedure DataModuleUserBasicAuth(Welcomemsg, AccessTag, Username,
      Password: String; var Params: TDWParams; var ErrorCode: Integer;
      var ErrorMessage: String; var Accept: Boolean);
    procedure dwcrEmployeeItemsdatatableRequestExecute(const Params: TDWParams;
      Var ContentType, Result: String);
    procedure DWServerContext1ContextListangularReplyRequest(
      const Params: TDWParams; Var ContentType, Result: String;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListindexReplyRequest(
      const Params: TDWParams; Var ContentType, Result: String;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListinitReplyRequest(
      const Params: TDWParams; Var ContentType, Result: String;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListopenfileReplyRequestStream(
      const Params: TDWParams; var ContentType: String;
      const Result: TMemoryStream; const RequestType: TRequestType;
      var StatusCode: Integer);
    procedure DWServerContext1ContextListphpReplyRequest(
      const Params: TDWParams; Var ContentType, Result: String);
    procedure DWServerEvents1EventsgetemployeeReplyEvent(Var Params: TDWParams;
      Var Result: String);
    procedure DWServerEvents1EventsservertimeReplyEvent(Var Params: TDWParams;
      Var Result: String);
    procedure DWServerEvents1EventstesteReplyEvent(var Params: TDWParams;
      var Result: String);
    procedure IBConnection1BeforeConnect(Sender: TObject);
    procedure ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
      Context: string; var Params: TDWParams; var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure ZConnection1BeforeConnect(Sender: TObject);
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
 RESTDWPoolerZEOS.Active := RestDWForm.cbPoolerState.Checked;
end;

procedure TServerMethodDM.ZConnection1BeforeConnect(Sender: TObject);
VAR
  Driver_BD: STRING;
  Porta_BD: STRING;
  Servidor_BD: STRING;
  DataBase: STRING;
  Pasta_BD: STRING;
  Usuario_BD: STRING;
  Senha_BD: STRING;
BEGIN
   database:= RestDWForm.EdBD.Text;
   Driver_BD := RestDWForm.CbDriver.Text;
   If RestDWForm.CkUsaURL.Checked Then
    Servidor_BD := RestDWForm.EdURL.Text
   Else
    Servidor_BD := RestDWForm.DatabaseIP;
   Case RestDWForm.CbDriver.ItemIndex Of
    0 : Begin
         Pasta_BD := IncludeTrailingPathDelimiter(RestDWForm.EdPasta.Text);
         Database := RestDWForm.edBD.Text;
         Database := Pasta_BD + Database;
        End;
    1 : Database := RestDWForm.EdBD.Text;
   End;
   Porta_BD   := RestDWForm.EdPortaBD.Text;
   Usuario_BD := RestDWForm.EdUserNameBD.Text;
   Senha_BD   := RestDWForm.EdPasswordBD.Text;
   TZConnection(Sender).Database := Database;
   TZConnection(Sender).HostName := Servidor_BD;
   TZConnection(Sender).Port     := StrToInt(Porta_BD);
   TZConnection(Sender).User     := Usuario_BD;
   TZConnection(Sender).Password := Senha_BD;
   TZConnection(Sender).LoginPrompt := FALSE;
End;

procedure TServerMethodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
  Context: string; var Params: TDWParams; var Result: string);
Begin
 Case SendType Of
  sePOST   : Result := '{(''STATUS'',   ''NOK''), (''MENSAGEM'', ''Método não encontrado'')}';
 End;
End;

procedure TServerMethodDM.DWServerEvents1EventsgetemployeeReplyEvent(
  Var Params: TDWParams; Var Result: String);
Var
 JSONValue: TJSONValue;
begin
 JSONValue          := TJSONValue.Create;
 Try
  zQuery1.Close;
  zQuery1.SQL.Clear;
  zQuery1.SQL.Add('select * from employee');
  Try
   zQuery1.Open;
   JSONValue.Encoding := Encoding;
   JSONValue.Encoded  := False;
   JSONValue.DatabaseCharSet := RESTDWDriverZeos1.DatabaseCharSet;
   JSONValue.LoadFromDataset('', zQuery1, False,  Params.JsonMode, 'dd/mm/yyyy', '.');
   Params.ItemsString['result'].AsObject := JSONValue.ToJSON;
  Except
  End;
 Finally
  JSONValue.Free;
 End;
end;

procedure TServerMethodDM.DWServerContext1ContextListphpReplyRequest(
  const Params: TDWParams; Var ContentType, Result: String);
var
 s : TStringlist;
begin
 s := TStringlist.Create;
 Try
  s.LoadFromFile('.\www\index_php.html');
  Result := s.Text;
 Finally
  s.Free;
 End;
end;

procedure TServerMethodDM.DWServerContext1ContextListinitReplyRequest(
  const Params: TDWParams; Var ContentType, Result: String;
  const RequestType: TRequestType);
begin
 Result := '<!DOCTYPE html> ' +
           '<html>' +
           '  <head>' +
           '    <meta charset="utf-8">' +
           '    <title>My test page</title>' +
           '    <link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>' +
           '  </head>' +
           '  <body>' +
           '    <h1>REST Dataware (Lazarus) is cool</h1>' +
           '    <img src="http://www.resteasyobjects.com.br/myimages/LogoDW.png" alt="The REST Dataware logo: Powerfull Web Service.">' +
           '  ' +
           '  ' +
           '    <p>working together to keep the Internet alive and accessible, help us to help you. Be free.</p>' +
           ' ' +
           '    <p><a href="http://www.restdw.com.br/">REST Dataware site</a> to learn and help us.</p>' +
           '  </body>' +
           '</html>';
end;

procedure TServerMethodDM.DWServerContext1ContextListopenfileReplyRequestStream(
  const Params: TDWParams; var ContentType: String;
  const Result: TMemoryStream; const RequestType: TRequestType;
  var StatusCode: Integer);
Var
 vNotFound   : Boolean;
 vFileName   : String;
 vStringStream : TStringStream;
begin
 vNotFound := True;
 If Params.ItemsString['filename'] <> Nil Then
  Begin
   vFileName := '.\www\' + DecodeStrings(Params.ItemsString['filename'].AsString,
                                         RESTDWDriverZeos1.DatabaseCharSet);
   vNotFound := Not FileExists(vFileName);
   If Not vNotFound Then
    Begin
     Try
      Result.LoadFromFile(vFileName);
      ContentType := GetMIMEType(vFileName);
     Finally
     End;
    End;
  End;
 If vNotFound Then
  Begin
   vStringStream := TStringStream.Create('<!DOCTYPE html> ' +
                                         '<html>' +
                                         '  <head>' +
                                         '    <meta charset="utf-8">' +
                                         '    <title>My test page</title>' +
                                         '    <link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>' +
                                         '  </head>' +
                                         '  <body>' +
                                         '    <h1>REST Dataware</h1>' +
                                         '    <img src="http://www.resteasyobjects.com.br/myimages/LogoDW.png" alt="The REST Dataware logo: Powerfull Web Service.">' +
                                         '  ' +
                                         '  ' +
                                         Format('    <p>File "%s" not Found.</p>', [vFileName]) +
                                         '  </body>' +
                                         '</html>');
   Try
    vStringStream.Position := 0;
    Result.CopyFrom(vStringStream, vStringStream.Size);
   Finally
    vStringStream.Free;
   End;
  End;
end;

procedure TServerMethodDM.DWServerContext1ContextListindexReplyRequest(
  const Params: TDWParams; Var ContentType, Result: String;
  const RequestType: TRequestType);
var
 s : TStringlist;
begin
 s := TStringlist.Create;
 Try
  s.LoadFromFile('.\www\index.html');
  Result := s.Text;
 Finally
  s.Free;
 End;
end;

procedure TServerMethodDM.DWServerContext1ContextListangularReplyRequest(
  const Params: TDWParams; Var ContentType, Result: String;
  const RequestType: TRequestType);
var
 s : TStringlist;
begin
 s := TStringlist.Create;
 Try
  s.LoadFromFile('.\www\dw_angular.html');
  Result := s.Text;
 Finally
  s.Free;
 End;
end;

procedure TServerMethodDM.dwcrEmployeeItemsdatatableRequestExecute(
  const Params: TDWParams; Var ContentType, Result: String);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue := TJSONValue.Create;
 Try
  zQuery1.Close;
  zQuery1.SQL.Clear;
  zQuery1.SQL.Add('select * from employee');
  Try
   zQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
   JSONValue.DatabaseCharSet := RESTDWDriverZeos1.DatabaseCharSet;
   JSONValue.LoadFromDataset('', zQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.');
   Result := JSONValue.ToJson;
  Except
   On E : Exception Do
    Begin
     Result := Format('{"Error":"%s"}', [E.Message]);
    End;
  End;
 Finally
  JSONValue.Free;
 End;
end;

procedure TServerMethodDM.DataModuleGetToken(Welcomemsg, AccessTag: String;
  Params: TDWParams; AuthOptions: TRDWAuthTokenParam; var ErrorCode: Integer;
  var ErrorMessage: String; var TokenID: String; var Accept: Boolean);
Var
 vMyClient,
 vMyPass    : String;
begin
 vMyClient  := '';
 vMyPass    := vMyClient;
 If (Params.ItemsString['username'] <> Nil) And
    (Params.ItemsString['password'] <> Nil) Then
  Begin
   vMyClient  := Params.ItemsString['username'].AsString;
   vMyPass    := Params.ItemsString['password'].AsString;
  End
 Else
  Begin
   vMyClient  := Copy(Welcomemsg, InitStrPos, Pos('|', Welcomemsg) -1);
   Delete(Welcomemsg, InitStrPos, Pos('|', Welcomemsg));
   vMyPass    := Trim(Welcomemsg);
  End;
 Accept     := Not ((vMyClient = '') Or
                    (vMyPass   = ''));
 If Accept Then
  Begin
   ZQuery1.Close;
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.Add('select * from TB_USUARIO where Upper(NM_LOGIN) = Upper(:NM_LOGIN) and Upper(DS_SENHA) = Upper(:DS_SENHA)');
   Try
    ZQuery1.ParamByName('NM_LOGIN').AsString := vMyClient;
    ZQuery1.ParamByName('DS_SENHA').AsString := vMyPass;
    ZQuery1.Open;
   Finally
    Accept     := Not(ZQuery1.EOF);
    If Not Accept Then
     Begin
      ErrorMessage := cInvalidAuth;
      ErrorCode  := 401;
     End
    Else
     TokenID := AuthOptions.GetToken(Format('{"id":"%s", "login":"%s"}', [ZQuery1.FindField('ID_PESSOA').AsString,
                                                                          ZQuery1.FindField('NM_LOGIN').AsString]));
    ZQuery1.Close;
   End;
  End
 Else
  Begin
   ErrorMessage := cInvalidAuth;
   ErrorCode  := 401;
  End;
end;

procedure TServerMethodDM.DataModuleUserBasicAuth(Welcomemsg, AccessTag,
  Username, Password: String; var Params: TDWParams; var ErrorCode: Integer;
  var ErrorMessage: String; var Accept: Boolean);
Var
 vMyClient,
 vMyPass    : String;
begin
 vMyClient  := '';
 vMyPass    := vMyClient;
 If (Params.ItemsString['username'] <> Nil) And
    (Params.ItemsString['password'] <> Nil) Then
  Begin
   vMyClient  := Params.ItemsString['username'].AsString;
   vMyPass    := Params.ItemsString['password'].AsString;
  End
 Else
  Begin
   vMyClient  := Copy(Welcomemsg, InitStrPos, Pos('|', Welcomemsg) -1);
   Delete(Welcomemsg, InitStrPos, Pos('|', Welcomemsg));
   vMyPass    := Trim(Welcomemsg);
  End;
 Accept     := Not ((vMyClient = '') Or
                    (vMyPass   = ''));
 If Accept Then
  Begin
   ZQuery1.Close;
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.Add('select * from TB_USUARIO where Upper(NM_LOGIN) = Upper(:NM_LOGIN) and Upper(DS_SENHA) = Upper(:DS_SENHA)');
   Try
    ZQuery1.ParamByName('NM_LOGIN').AsString := vMyClient;
    ZQuery1.ParamByName('DS_SENHA').AsString := vMyPass;
    ZQuery1.Open;
   Finally
    Accept     := Not(ZQuery1.EOF);
    If Not Accept Then
     Begin
      ErrorMessage := cInvalidAuth;
      ErrorCode  := 401;
     End;
    ZQuery1.Close;
   End;
  End
 Else
  Begin
   ErrorMessage := cInvalidAuth;
   ErrorCode  := 401;
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
 Result := Params.ToJSON;
end;

procedure TServerMethodDM.DWServerEvents1EventstesteReplyEvent(
  var Params: TDWParams; var Result: String);
begin
 result := Params.ItemsString['value'].AsString;
end;

procedure TServerMethodDM.IBConnection1BeforeConnect(Sender: TObject);
VAR
  Driver_BD: STRING;
  Porta_BD: STRING;
  Servidor_BD: STRING;
  DataBase: STRING;
  Pasta_BD: STRING;
  Usuario_BD: STRING;
  Senha_BD: STRING;
BEGIN
   database:= RestDWForm.EdBD.Text;
   Driver_BD := RestDWForm.CbDriver.Text;
   If RestDWForm.CkUsaURL.Checked Then
    Servidor_BD := RestDWForm.EdURL.Text
   Else
    Servidor_BD := RestDWForm.DatabaseIP;
   Case RestDWForm.CbDriver.ItemIndex Of
    0 : Begin
         Pasta_BD := IncludeTrailingPathDelimiter(RestDWForm.EdPasta.Text);
         Database := RestDWForm.edBD.Text;
         Database := Pasta_BD + Database;
        End;
    1 : Database := RestDWForm.EdBD.Text;
   End;
   Porta_BD   := RestDWForm.EdPortaBD.Text;
   Usuario_BD := RestDWForm.EdUserNameBD.Text;
   Senha_BD   := RestDWForm.EdPasswordBD.Text;
   TIBConnection(Sender).DatabaseName := Database;
   TIBConnection(Sender).HostName    := Servidor_BD;
//   TIBConnection(Sender).Port        := StrToInt(Porta_BD);
   TIBConnection(Sender).Username    := Usuario_BD;
   TIBConnection(Sender).Password    := Senha_BD;
   TIBConnection(Sender).LoginPrompt := FALSE;
End;


end.
