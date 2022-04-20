UNIT uDmService;

INTERFACE

USES
  SysUtils,
  Classes,
  SysTypes,
  UDWDatamodule,
  uDWMassiveBuffer,
  UDWJSONObject,
  Dialogs,
  ServerUtils,
  UDWConstsData,
  RestDWServerFormU,
  URESTDWPoolerDB,
  uDWConsts, uRESTDWServerEvents, uSystemEvents, uDWAbout, uRESTDWServerContext,
  DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  uRESTDWDriverZEOS;

Const
 WelcomeSample = False;

TYPE
  TServerMethodDM = CLASS(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    DWServerEvents2: TDWServerEvents;
    DWServerContext1: TDWServerContext;
    ZConnection1: TZConnection;
    RESTDWDriverZeos1: TRESTDWDriverZeos;
    DWContextRules1: TDWContextRules;
    dwcrEmployee: TDWContextRules;
    ZQuery1: TZQuery;
    PROCEDURE ServerMethodDataModuleCreate(Sender: TObject);
    procedure ServerMethodDataModuleMassiveProcess(
      var MassiveDataset: TMassiveDatasetBuffer; var Ignore: Boolean);
    procedure DWServerEvents1EventsservertimeReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsloaddataseteventReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWServerEvents1EventsgetemployeeReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsgetemployeeDWReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWServerEvents1EventseventintReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventseventdatetimeReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWServerEvents1EventshelloworldReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents2Eventshelloworld2ReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure ServerMethodDataModuleWelcomeMessage(Welcomemsg,
      AccessTag: string; var ConnectionDefs: TConnectionDefs;
      var Accept: Boolean);
    procedure RESTDWDriverFD1PrepareConnection(
      var ConnectionDefs: TConnectionDefs);
    procedure ZConnection1BeforeConnect(Sender: TObject);
    procedure DWServerContext1ContextListinitReplyRequest(
      const Params: TDWParams; var ContentType, Result: String;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListangularReplyRequest(
      const Params: TDWParams; var ContentType, Result: String;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListphpReplyRequest(
      const Params: TDWParams; var ContentType, Result: String;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListopenfileReplyRequestStream(
      const Params: TDWParams; var ContentType: String;
      var Result: TMemoryStream; const RequestType: TRequestType);
    procedure DWServerContext1ContextListindexReplyRequest(
      const Params: TDWParams; var ContentType, Result: String;
      const RequestType: TRequestType);
    procedure dwcrEmployeeItemsdatatableRequestExecute(
      const Params: TDWParams; var ContentType, Result: String);
  PRIVATE
    { Private declarations }
    vIDVenda : Integer;
    vConnectFromClient : Boolean;
    function GetGenID(GenName: String): Integer;
    procedure employeeReplyEvent(var Params: TDWParams; dJsonMode: TJsonMode; Var Result : String);
  PUBLIC
    { Public declarations }
  END;

VAR
  ServerMethodDM: TServerMethodDM;

IMPLEMENTATION

uses uDWJSONTools;
{$R *.dfm}


procedure TServerMethodDM.employeeReplyEvent(var Params: TDWParams; dJsonMode : TJsonMode; Var Result : String);
Var
 JSONValue: TJSONValue;
begin
 JSONValue          := TJSONValue.Create;
 Try
  ZQuery1.Close;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('select * from employee');
  Try
   ZQuery1.Open;
   JSONValue.JsonMode := Params.JsonMode;
   JSONValue.Encoding := Encoding;
   If Params.JsonMode = jmPureJSON Then
    Begin
     JSONValue.LoadFromDataset('', ZQuery1, False,  Params.JsonMode, 'dd/mm/yyyy', '.');
     Result := JSONValue.ToJson;
    End
   Else
    Begin
     JSONValue.LoadFromDataset('employee', ZQuery1, False,  Params.JsonMode);
     Params.ItemsString['result'].AsObject       := JSONValue.ToJSON;
    End; 
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

procedure TServerMethodDM.DWServerEvents1EventseventdatetimeReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Params.ItemsString['result'].AsDateTime := Params.ItemsString['mydatetime'].AsDateTime + 1;
end;

procedure TServerMethodDM.DWServerEvents1EventseventintReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Params.ItemsString['result'].AsInteger := Random(Params.ItemsString['mynumber'].AsInteger);
end;

procedure TServerMethodDM.DWServerEvents1EventsgetemployeeDWReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 employeeReplyEvent(Params, Params.JsonMode, Result);
end;

procedure TServerMethodDM.DWServerEvents1EventsgetemployeeReplyEvent(
  var Params: TDWParams; var Result: string);
Begin
 employeeReplyEvent(Params, Params.JsonMode, Result);
End;

procedure TServerMethodDM.DWServerEvents1EventshelloworldReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Result := Format('{"Message":"%s"}', ['Sou eu ServerEvent1']);
end;

procedure TServerMethodDM.DWServerEvents1EventsloaddataseteventReplyEvent(
  var Params: TDWParams; var Result: string);
Var
 JSONValue: TJSONValue;
BEGIN
 If Params.ItemsString['sql'] <> Nil Then
  Begin
   JSONValue          := TJSONValue.Create;
   Try
    ZQuery1.Close;
    ZQuery1.SQL.Clear;
    ZQuery1.SQL.Add(Params.ItemsString['sql'].AsString);
    Try
     ZQuery1.Open;
     JSONValue.Encoding := Encoding;
     JSONValue.LoadFromDataset('temp', ZQuery1, True);
     Params.ItemsString['result'].AsString := JSONValue.ToJSON;
    Except
     On E : Exception Do
      Begin
       Result := Format('{"Error":"%s"}', [E.Message]);
      End;
    End;
   Finally
    JSONValue.Free;
   End;
  End;
end;

procedure TServerMethodDM.DWServerEvents1EventsservertimeReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 If Params.ItemsString['inputdata'].AsString <> '' Then //servertime
  Params.ItemsString['result'].AsDateTime := Now
 Else
  Params.ItemsString['result'].AsDateTime := Now - 1;
 Params.ItemsString['resultstring'].AsString := 'testservice';
end;

procedure TServerMethodDM.DWServerEvents2Eventshelloworld2ReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Result := 'Sou eu ServerEvent2';
end;

PROCEDURE TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
BEGIN
 vConnectFromClient := False;
 RESTDWPoolerDB1.Active := RestDWForm.CbPoolerState.Checked;
END;

Function TServerMethodDM.GetGenID(GenName  : String): Integer;
Var
 vTempClient : TZQuery;
Begin
 vTempClient := TZQuery.Create(Nil);
 Result      := -1;
 Try
  vTempClient.Connection := ZConnection1;
  vTempClient.SQL.Add(Format('select gen_id(%s, 1)GenID From rdb$database', [GenName]));
  vTempClient.Active := True;
  Result := vTempClient.FindField('GenID').AsInteger;
 Except

 End;
 vTempClient.Free;
End;

procedure TServerMethodDM.RESTDWDriverFD1PrepareConnection(
  var ConnectionDefs: TConnectionDefs);
begin
 vConnectFromClient := True;
 ConnectionDefs.DatabaseName := IncludeTrailingPathDelimiter(RestDWForm.EdPasta.Text) + ConnectionDefs.DatabaseName;
 ConnectionDefs.HostName     := 'localhost';
 ConnectionDefs.dbPort       := 3050;
 ConnectionDefs.Username     := 'sysdba';
 ConnectionDefs.Password     := 'masterkey';
end;

procedure TServerMethodDM.ServerMethodDataModuleMassiveProcess(
  var MassiveDataset: TMassiveDatasetBuffer; var Ignore: Boolean);
begin
{ //Esse código é para manipular o evento nao permitindo que sejam alteradas por massive outras
  //tabelas diferentes de employee e se você alterar o campo last_name no client ele substitui o valor
  //pelo valor setado abaixo
 Ignore := (MassiveDataset.MassiveMode in [mmInsert, mmUpdate, mmDelete]) and
           (lowercase(MassiveDataset.TableName) <> 'employee');
}
 If lowercase(MassiveDataset.TableName) = 'vendas' Then
  Begin
   If MassiveDataset.Fields.FieldByName('ID_VENDA') <> Nil Then
    If (Trim(MassiveDataset.Fields.FieldByName('ID_VENDA').Value) = '') or
       (Trim(MassiveDataset.Fields.FieldByName('ID_VENDA').Value) = '-1')  then
     Begin
      vIDVenda := GetGenID('GEN_' + lowercase(MassiveDataset.TableName));
      MassiveDataset.Fields.FieldByName('ID_VENDA').Value := IntToStr(vIDVenda);
     End
    Else
     vIDVenda := StrToInt(MassiveDataset.Fields.FieldByName('ID_VENDA').Value)
  End
 Else If lowercase(MassiveDataset.TableName) = 'vendas_items' Then
  Begin
   If MassiveDataset.Fields.FieldByName('ID_VENDA') <> Nil Then
    If (Trim(MassiveDataset.Fields.FieldByName('ID_VENDA').Value) = '') or
       (Trim(MassiveDataset.Fields.FieldByName('ID_VENDA').Value) = '-1')  then
     MassiveDataset.Fields.FieldByName('ID_VENDA').Value := IntToStr(vIDVenda);
   If MassiveDataset.Fields.FieldByName('ID_ITEMS') <> Nil Then
    If (Trim(MassiveDataset.Fields.FieldByName('ID_ITEMS').Value) = '') or
       (Trim(MassiveDataset.Fields.FieldByName('ID_ITEMS').Value) = '-1')  then
     MassiveDataset.Fields.FieldByName('ID_ITEMS').Value := IntToStr(GetGenID('GEN_' + lowercase(MassiveDataset.TableName)));
  End;
end;

procedure TServerMethodDM.ServerMethodDataModuleWelcomeMessage(Welcomemsg,
                                                               AccessTag          : String;
                                                               Var ConnectionDefs : TConnectionDefs;
                                                               Var Accept         : Boolean);
Var
 vUserNameWM,
 vPasswordWM : String;
begin
 vUserNameWM := '';
 vPasswordWM := '';
 If WelcomeSample Then
  Begin
   Try
    If Pos('|', Welcomemsg) > 0 Then
     Begin
      vUserNameWM := Copy(Welcomemsg, 1, Pos('|', Welcomemsg)-1);
      Delete(Welcomemsg, 1, Pos('|', Welcomemsg));
     End
    Else
     Begin
      vUserNameWM := Copy(Welcomemsg, 1, Length(Welcomemsg));
      Delete(Welcomemsg, 1, Length(Welcomemsg));
     End;
    vPasswordWM := Copy(Welcomemsg, 1, Length(Welcomemsg));
    ZQuery1.Close;
    ZQuery1.SQL.Clear;
    ZQuery1.SQL.Add('select * from TB_USUARIO where Upper(NM_LOGIN) = Upper(:USERNAME) AND Upper(DS_SENHA) = Upper(:PASSWORD)');
    ZQuery1.ParamByName('USERNAME').AsString := vUserNameWM;
    ZQuery1.ParamByName('PASSWORD').AsString := vPasswordWM;
    ZQuery1.Open;
   Finally
    Accept := Not(ZQuery1.Eof);
    ZQuery1.Close;
   End;
// Accept := ((AccessTag)  = RESTDWPoolerDB1.AccessTag) Or
//          ((Welcomemsg) = 'teste');
  End;
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
 If Not vConnectFromClient Then
  Begin
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
End;

procedure TServerMethodDM.DWServerContext1ContextListinitReplyRequest(
  const Params: TDWParams; var ContentType, Result: String;
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
           '    <h1>REST Dataware is cool</h1>' +
           '    <img src="http://www.resteasyobjects.com.br/myimages/LogoDW.png" alt="The REST Dataware logo: Powerfull Web Service.">' +
           '  ' +
           '  ' +
           '    <p>working together to keep the Internet alive and accessible, help us to help you. Be free.</p>' +
           ' ' +
           '    <p><a href="http://www.restdw.com.br/">REST Dataware site</a> to learn and help us.</p>' +
           '  </body>' +
           '</html>';
end;

procedure TServerMethodDM.DWServerContext1ContextListangularReplyRequest(
  const Params: TDWParams; var ContentType, Result: String;
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

procedure TServerMethodDM.DWServerContext1ContextListphpReplyRequest(
  const Params: TDWParams; var ContentType, Result: String;
  const RequestType: TRequestType);
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

procedure TServerMethodDM.DWServerContext1ContextListopenfileReplyRequestStream(
  const Params: TDWParams; var ContentType: String;
  var Result: TMemoryStream; const RequestType: TRequestType);
Var
 vNotFound   : Boolean;
 vFileName   : String;
 vStringStream : TStringStream;
begin
 vNotFound := True;
 Result    := TMemoryStream.Create;
 If Params.ItemsString['filename'] <> Nil Then
  Begin
   vFileName := '.\www\' + DecodeStrings(Params.ItemsString['filename'].AsString);
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
  const Params: TDWParams; var ContentType, Result: String;
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

procedure TServerMethodDM.dwcrEmployeeItemsdatatableRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue := TJSONValue.Create;
 Try
  ZQuery1.Close;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('select * from employee');
  Try
   ZQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
   JSONValue.LoadFromDataset('', ZQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.');
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

END.
