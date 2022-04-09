UNIT uDmService;

INTERFACE

USES
  SysUtils, Classes, SysTypes, UDWDatamodule, uDWMassiveBuffer, System.JSON,
  UDWJSONObject, Dialogs, ServerUtils, FireDAC.Dapt, UDWConstsData, FireDAC.Phys.FBDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.UI, FireDAC.Phys.IBBase, FireDAC.Stan.StorageJSON,
  URESTDWPoolerDB, URestDWDriverFD, FireDAC.Phys.MSSQLDef, FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL, uDWConsts, uRESTDWServerEvents, uSystemEvents, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, uDWAbout, FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL, uRESTDWServerContext, FireDAC.Phys.PGDef, FireDAC.Phys.PG,
  FireDAC.Moni.Base, FireDAC.Moni.RemoteClient, FireDAC.Phys.ODBCDef,
  FireDAC.Phys.ODBC, uRESTDWDriverRDW, FireDAC.Stan.StorageBin;

Const
 WelcomeSample = True;
 Const404Page  = 'www\404.html';

TYPE
  TServerMethodDM = CLASS(TServerMethodDataModule)
    RESTDWPoolerFD: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    Server_FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDTransaction1: TFDTransaction;
    FDQuery1: TFDQuery;
    DWServerEvents2: TDWServerEvents;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    dwcrEmployee: TDWContextRules;
    dwcLogin: TDWContextRules;
    FDMoniRemoteClientLink1: TFDMoniRemoteClientLink;
    FDPhysODBCDriverLink1: TFDPhysODBCDriverLink;
    FDQuery2: TFDQuery;
    FDQLogin: TFDQuery;
    DWServerContext1: TDWServerContext;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    PROCEDURE Server_FDConnectionBeforeConnect(Sender: TObject);
    PROCEDURE Server_FDConnectionError(ASender, AInitiator: TObject; VAR AException: Exception);
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
    procedure RESTDWDriverFD1PrepareConnection(
      var ConnectionDefs: TConnectionDefs);
    procedure DWServerContext1ContextListinitReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListzsendReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListangularReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListphpReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListindexReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure dwcrEmployeeItemsdatatableRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure DWServerEvents1EventsassynceventReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventshelloworldRDWReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure FDQuery1AfterScroll(DataSet: TDataSet);
    procedure DWSETESTEEventsservertimeReplyEventByType(var Params: TDWParams;
      var Result: string; const RequestType: TRequestType;
      var StatusCode: Integer; RequestHeader: TStringList);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure DWServerContext1ContextListopenfileReplyRequestStream(
      const Params: TDWParams; var ContentType: string;
      const Result: TMemoryStream; const RequestType: TRequestType;
      var StatusCode: Integer);
    procedure ServerMethodDataModuleMassiveProcess(
      var MassiveDataset: TMassiveDatasetBuffer; var Ignore: Boolean);
    procedure ServerMethodDataModuleGetToken(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
    procedure ServerMethodDataModuleUserTokenAuth(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
    procedure DWServerContext1ContextListindexReplyRequestStream(
      const Params: TDWParams; var ContentType: string;
      const Result: TMemoryStream; const RequestType: TRequestType;
      var StatusCode: Integer);
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

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uDWJSONTools, uFullRDWServerIndy;
{$R *.dfm}


procedure TServerMethodDM.employeeReplyEvent(var Params: TDWParams; dJsonMode : TJsonMode; Var Result : String);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue := TJSONValue.Create;
 Try
  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add('select * from employee');
  Try
   FDQuery1.Open;
   JSONValue.JsonMode := Params.JsonMode;
   JSONValue.Encoding := Encoding;
   If Params.JsonMode = jmPureJSON Then
    Begin
     JSONValue.Utf8SpecialChars := True;
     JSONValue.LoadFromDataset('', FDQuery1, False, Params.JsonMode, 'dd/mm/yyyy hh:mm:ss', '.');
     Result := JSONValue.ToJson;
    End
   Else
    Begin
     JSONValue.LoadFromDataset('employee', FDQuery1, False,  Params.JsonMode);
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

procedure TServerMethodDM.FDQuery1AfterScroll(DataSet: TDataSet);
begin
 If FDQuery1.FieldByName('emp_no') <> Nil Then
  Begin
   FDQuery2.Close;
   FDQuery2.ParamByName('emp_no').AsInteger := FDQuery1.FieldByName('emp_no').AsInteger;
   FDQuery2.Open;
  End;
end;

procedure TServerMethodDM.dwcrEmployeeItemsdatatableRequestExecute(
  const Params: TDWParams; var ContentType, Result: string);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue := TJSONValue.Create;
 Try
  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add('select * from employee');
  Try
   FDQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
   JSONValue.LoadFromDataset('', FDQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.');
   JSONValue.LoadFromDataset('', FDQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.');
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

procedure TServerMethodDM.DWServerContext1ContextListangularReplyRequest(
  const Params: TDWParams; var ContentType, Result: string;
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

procedure TServerMethodDM.DWServerContext1ContextListindexReplyRequest(
  const Params: TDWParams; var ContentType, Result: string;
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

procedure TServerMethodDM.DWServerContext1ContextListindexReplyRequestStream(
  const Params: TDWParams; var ContentType: string; const Result: TMemoryStream;
  const RequestType: TRequestType; var StatusCode: Integer);
begin
 Result.LoadFromFile('.\www\index.html');
 Result.Position := 0;
end;

procedure TServerMethodDM.DWServerContext1ContextListinitReplyRequest(
  const Params: TDWParams; var ContentType, Result: string;
  const RequestType: TRequestType);
begin
 Result := '<!DOCTYPE html> ' +
           '<html>' +
           '  <head>' +
           '    <meta charset="utf-8">' +
           '    <title>REST Dataware - Webpascal</title>' +
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

procedure TServerMethodDM.DWServerContext1ContextListopenfileReplyRequestStream(
  const Params: TDWParams; var ContentType: string; const Result: TMemoryStream;
  const RequestType: TRequestType; var StatusCode: Integer);
Var
 vNotFound   : Boolean;
 vFileName   : String;
 vStringStream : TStringStream;
begin
 vNotFound := True;
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

procedure TServerMethodDM.DWServerContext1ContextListphpReplyRequest(
  const Params: TDWParams; var ContentType, Result: string;
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

procedure TServerMethodDM.DWServerContext1ContextListzsendReplyRequest(
  const Params: TDWParams; var ContentType, Result: string;
  const RequestType: TRequestType);
var
 s : TStringlist;
begin
 s := TStringlist.Create;
 Try
  s.LoadFromFile('.\zenvia\data\envio_simples.php');
  Result := s.Text;
 Finally
  s.Free;
 End;
end;

procedure TServerMethodDM.DWServerEvents1EventsassynceventReplyEvent(
  var Params: TDWParams; var Result: string);
Var
 vstringtime : TStringlist;
begin
 vstringtime := TStringlist.Create;
 Try
  vstringtime.Add(DateTimeToStr(Now));
  vstringtime.SaveToFile(ExtractFilePath(Paramstr(0)) + 'assynctime.txt');
 Finally
  vstringtime.Free;
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

procedure TServerMethodDM.DWServerEvents1EventshelloworldRDWReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Params.ItemsString['result'].AsString := 'Hello World : ' + QuotedSTR(Params.ItemsString['entrada'].AsString);
end;

procedure TServerMethodDM.DWServerEvents1EventshelloworldReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Result := Format('Hello World :"%s"', [Params.ItemsString['entrada'].AsString]);
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
    FDQuery1.Close;
    FDQuery1.SQL.Clear;
    FDQuery1.SQL.Add(Params.ItemsString['sql'].AsString);
    Try
     FDQuery1.Open;
     JSONValue.Encoding := Encoding;
     JSONValue.LoadFromDataset('temp', FDQuery1, True);
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

procedure TServerMethodDM.DWServerEvents2Eventshelloworld2ReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Result := 'Sou eu ServerEvent2';
end;

procedure TServerMethodDM.DWSETESTEEventsservertimeReplyEventByType(
  var Params: TDWParams; var Result: string; const RequestType: TRequestType;
  var StatusCode: Integer; RequestHeader: TStringList);
begin
  If Params.ItemsString['inputdata'].AsString <> '' Then //servertime
   Params.ItemsString['result'].AsDateTime := Now
  Else
   Params.ItemsString['result'].AsDateTime := Now - 1;
  Params.ItemsString['resultstring'].AsString := Params.ItemsString['inputdata'].AsString;
End;

Function TServerMethodDM.GetGenID(GenName  : String): Integer;
Var
 vTempClient : TFDQuery;
Begin
 vTempClient := TFDQuery.Create(Nil);
 Result      := -1;
 Try
  vTempClient.Connection := Server_FDConnection;
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

procedure TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
begin
 vConnectFromClient := False;
 RESTDWPoolerFD.Active  := RestDWForm.CbPoolerState.Checked;
end;

procedure TServerMethodDM.ServerMethodDataModuleGetToken(Welcomemsg,
  AccessTag: string; Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
  var ErrorCode: Integer; var ErrorMessage, TokenID: string;
  var Accept: Boolean);
Var
 vMyClient,
 vMyPass    : String;
 Function RejectURL : String;
 Var
  v404Error  : TStringList;
 Begin
  v404Error  := TStringList.Create;
  Try
   {$IFDEF APPWIN}
   v404Error.LoadFromFile(RestDWForm.RESTServicePooler1.RootPath + Const404Page);
   {$ELSE}
   v404Error.LoadFromFile('.\www\' + Const404Page);
   {$ENDIF}
   Result := v404Error.Text;
  Finally
   v404Error.Free;
  End;
 End;
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
   FDQLogin.Close;
   FDQLogin.SQL.Clear;
   FDQLogin.SQL.Add('select * from TB_USUARIO where Upper(NM_LOGIN) = Upper(:NM_LOGIN) and Upper(DS_SENHA) = Upper(:DS_SENHA)');
   Try
    FDQLogin.ParamByName('NM_LOGIN').AsString := vMyClient;
    FDQLogin.ParamByName('DS_SENHA').AsString := vMyPass;
    FDQLogin.Open;
   Finally
    Accept     := Not(FDQLogin.EOF);
    If Not Accept Then
     Begin
      ErrorMessage := cInvalidAuth;
      ErrorCode  := 401;
     End
    Else
     TokenID := AuthOptions.GetToken(Format('{"id":"%s", "login":"%s"}', [FDQLogin.FindField('ID_PESSOA').AsString,
                                                                          FDQLogin.FindField('NM_LOGIN').AsString]));
    FDQLogin.Close;
   End;
  End
 Else
  Begin
   ErrorMessage := cInvalidAuth;
   ErrorCode  := 401;
  End;
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
 If MassiveDataset.MassiveMode = mmInsert Then
  Begin
   If lowercase(MassiveDataset.TableName) = 'vendas' Then
    Begin
     If MassiveDataset.Fields.FieldByName('ID') <> Nil Then
      If (MassiveDataset.Fields.FieldByName('ID').Value <= 0)  then
       Begin
        vIDVenda := GetGenID('GEN_' + lowercase(MassiveDataset.TableName));
        MassiveDataset.Fields.FieldByName('ID').Value   := IntToStr(vIDVenda);
        MassiveDataset.Fields.FieldByName('DATA').Value := Now;
       End
      Else
       vIDVenda := StrToInt(MassiveDataset.Fields.FieldByName('ID').Value)
    End
   Else If lowercase(MassiveDataset.TableName) = 'vendas_items' Then
    Begin
     If MassiveDataset.Fields.FieldByName('ID_VENDA') <> Nil Then
      If (MassiveDataset.Fields.FieldByName('ID_VENDA').Value <= 0)  then
       MassiveDataset.Fields.FieldByName('ID_VENDA').Value := IntToStr(vIDVenda);
     If MassiveDataset.Fields.FieldByName('ID_ITEMS') <> Nil Then
      If (MassiveDataset.Fields.FieldByName('ID_ITEMS').Value <= 0)  then
       MassiveDataset.Fields.FieldByName('ID_ITEMS').Value := IntToStr(GetGenID('GEN_' + lowercase(MassiveDataset.TableName)));
    End;
  End;
end;

Procedure TServerMethodDM.ServerMethodDataModuleUserTokenAuth(Welcomemsg,
  AccessTag: string; Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
  Var ErrorCode: Integer; var ErrorMessage, TokenID: string;
  Var Accept: Boolean);
begin
 //Novo código para validação
 Accept := True;
// AuthOptions.BeginTime
// AuthOptions.EndTime
// AuthOptions.Secrets
end;

PROCEDURE TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
VAR
  Driver_BD: STRING;
  Porta_BD: STRING;
  Servidor_BD: STRING;
  DataBase: STRING;
  Pasta_BD: STRING;
  Usuario_BD: STRING;
  Senha_BD: STRING;
  DataSource_BD: STRING;
  Monitor_BD: STRING;
  OsAuthent_BD: BOOLEAN;
BEGIN
 If Not vConnectFromClient Then
  Begin
   database     := RestDWForm.EdBD.Text;
   Driver_BD    := RestDWForm.CbDriver.Text;
   Monitor_BD   := RestDWForm.EdMonitor.Text;
   OsAuthent_BD := RestDWForm.cbOsAuthent.Checked;
   DataSource_BD:= RestDWForm.EdDataSource.Text;

   If RestDWForm.CkUsaURL.Checked Then
    Servidor_BD := RestDWForm.EdURL.Text
   Else
    Servidor_BD := RestDWForm.DatabaseIP;
   Case RestDWForm.CbDriver.ItemIndex Of
    0 : Begin                                                               // FB
         Pasta_BD := IncludeTrailingPathDelimiter(RestDWForm.EdPasta.Text);
         Database := RestDWForm.edBD.Text;
         Database := Pasta_BD + Database;
        End;
    1 : Begin                                                               // MSSQL
          Database := RestDWForm.EdBD.Text;
          TFDConnection(Sender).Params.Add('OsAuthent=' + OsAuthent_BD.ToString());
          TFDConnection(Sender).Params.Add('MonitorBy=' + Monitor_BD);
        End;
    2 :   Driver_BD := 'MySQL'; // Desenvolver
    3 :   Driver_BD := 'PG';    // Desenvolver
    4 : begin
          Driver_BD := 'ODBC';
          TFDConnection(Sender).Params.Add('DataSource=' + DataSource_BD);
        end;
   End;
   Porta_BD   := RestDWForm.EdPortaBD.Text;
   Usuario_BD := RestDWForm.EdUserNameBD.Text;
   Senha_BD   := RestDWForm.EdPasswordBD.Text;
   TFDConnection(Sender).Params.Clear;
   TFDConnection(Sender).Params.Add('DriverID=' + Driver_BD);
   TFDConnection(Sender).Params.Add('Server=' + Servidor_BD);
   TFDConnection(Sender).Params.Add('Port=' + Porta_BD);
   TFDConnection(Sender).Params.Add('Database=' + Database);
   TFDConnection(Sender).Params.Add('User_Name=' + Usuario_BD);
   TFDConnection(Sender).Params.Add('Password=' + Senha_BD);
   TFDConnection(Sender).Params.Add('Protocol=TCPIP');
   TFDConnection(Sender).Params.Add('Charset=ISO8859_1');
   TFDConnection(Sender).DriverName  := Driver_BD;
   TFDConnection(Sender).LoginPrompt := FALSE;
   TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
  End;
End;

PROCEDURE TServerMethodDM.Server_FDConnectionError(ASender, AInitiator: TObject; VAR AException: Exception);
BEGIN
  RestDWForm.memoResp.Lines.Add(AException.Message);
END;

END.
