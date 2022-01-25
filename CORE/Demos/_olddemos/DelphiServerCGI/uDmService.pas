UNIT uDmService;

INTERFACE

USES
  SysUtils,
  Classes,
  SysTypes,
  UDWDatamodule,
  uDWMassiveBuffer,
  System.JSON,
  UDWJSONObject,
  Dialogs,
  ServerUtils,
  FireDAC.Dapt,
  UDWConstsData,
  FireDAC.Phys.FBDef,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase,
  FireDAC.Stan.StorageJSON,
  URESTDWPoolerDB,
  URestDWDriverFD,
  uSystemEvents,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  uDWConsts, uRESTDWServerEvents, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, uDWAbout, uRESTDWServerContext;

Const
 Const404Page  = 'www\404.html';

TYPE
  TServerMethodDM = CLASS(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    Server_FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDTransaction1: TFDTransaction;
    FDQuery1: TFDQuery;
    DWServerContext1: TDWServerContext;
    dwcrEmployee: TDWContextRules;
    FDQLogin: TFDQuery;
    PROCEDURE ServerMethodDataModuleCreate(Sender: TObject);
    PROCEDURE Server_FDConnectionBeforeConnect(Sender: TObject);
    procedure ServerMethodDataModuleMassiveProcess(
      var MassiveDataset: TMassiveDatasetBuffer; var Ignore: Boolean);
    procedure DWServerEvents1EventsservertimeReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventstesteReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsloaddataseteventReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWServerEvents1EventsgetemployeeReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventshelloworldReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerContext1ContextListangularReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListopenfileReplyRequestStream(
      const Params: TDWParams; var ContentType: string;
      var Result: TMemoryStream; const RequestType: TRequestType);
    procedure DWServerContext1ContextListinitReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure DWServerContext1ContextListindexReplyRequest(
      const Params: TDWParams; var ContentType, Result: string;
      const RequestType: TRequestType);
    procedure dwcrEmployeeItemsdatatableRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure ServerMethodDataModuleGetToken(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
    procedure ServerMethodDataModuleUserTokenAuth(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
  PRIVATE
    { Private declarations }
    vIDVenda : Integer;
    FUNCTION ConsultaBanco(VAR Params: TDWParams): STRING; OVERLOAD;
    function GetGenID(GenName: String): Integer;
  PUBLIC
    { Public declarations }
  END;

VAR
  ServerMethodDM: TServerMethodDM;

IMPLEMENTATION

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

uses uConsts, uDWJSONTools;

FUNCTION TServerMethodDM.ConsultaBanco(VAR Params: TDWParams): STRING;
VAR
  VSQL: STRING;
  JSONValue: TJSONValue;
  FdQuery: TFDQuery;
BEGIN
  IF Params.ItemsString['SQL'] <> NIL THEN
  BEGIN
    JSONValue          := UDWJSONObject.TJSONValue.Create;
    JSONValue.Encoding := Encoding;
    IF Params.ItemsString['SQL'].Value <> '' THEN
    BEGIN
      IF Params.ItemsString['TESTPARAM'] <> NIL THEN
        Params.ItemsString['TESTPARAM'].SetValue('OK, OK');
      VSQL := Params.ItemsString['SQL'].Value;
{$IFDEF FPC}
{$ELSE}
      FdQuery := TFDQuery.Create(NIL);
      TRY
        FdQuery.Connection := Server_FDConnection;
        FdQuery.SQL.Add(VSQL);
        JSONValue.LoadFromDataset('sql', FdQuery, true);
        Result := JSONValue.ToJSON;
      FINALLY
        JSONValue.Free;
        FdQuery.Free;
      END;
{$ENDIF}
    END;
  END;
END;

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
  If Params.ItemsString['codcli'] <> Nil Then
   FDQuery1.SQL.Add('where emp_no = ' + Params.ItemsString['codcli'].AsString);
  Try
   FDQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
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

procedure TServerMethodDM.DWServerContext1ContextListinitReplyRequest(
  const Params: TDWParams; var ContentType, Result: string;
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

procedure TServerMethodDM.DWServerContext1ContextListopenfileReplyRequestStream(
  const Params: TDWParams; var ContentType: string; var Result: TMemoryStream;
  const RequestType: TRequestType);
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
                                         '    <p>File not Found.</p>' +
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

procedure TServerMethodDM.DWServerEvents1EventsgetemployeeReplyEvent(
  var Params: TDWParams; var Result: string);
Var
 JSONValue: TJSONValue;
begin
 JSONValue          := TJSONValue.Create;
 Try
  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add('select * from employee');
  If Params.ItemsString['id'].AsInteger > 0 Then
   FDQuery1.SQL.Add('Where emp_no = ' + intTostr(Params.ItemsString['id'].AsInteger));

  Try
   FDQuery1.Open;
   JSONValue.JsonMode := Params.JsonMode;
   JSONValue.Encoding := Encoding;
   JSONValue.LoadFromDataset('employee', FDQuery1, False,  Params.JsonMode);
   Params.ItemsString['result'].AsObject := JSONValue.ToJSON;
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

procedure TServerMethodDM.DWServerEvents1EventshelloworldReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Result := Format('{"Message":"%s"}', [Params.ItemsString['entrada'].AsString]);
end;

procedure TServerMethodDM.DWServerEvents1EventsloaddataseteventReplyEvent(
  var Params: TDWParams; var Result: string);
Var
 JSONValue: TJSONValue;
Begin
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

procedure TServerMethodDM.DWServerEvents1EventstesteReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Params.ItemsString['result'].Asstring := 'hello World';
end;

PROCEDURE TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
BEGIN
  RESTDWPoolerDB1.Active := ActivePooler;
END;

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
      ErrorCode  := 404;
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
   ErrorCode  := 404;
  End;
end;

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

procedure TServerMethodDM.ServerMethodDataModuleUserTokenAuth(Welcomemsg,
  AccessTag: string; Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
  var ErrorCode: Integer; var ErrorMessage, TokenID: string;
  var Accept: Boolean);
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
  DataBaseB: STRING;
  Pasta_BD: STRING;
BEGIN
 Servidor_BD := servidor;
 Pasta_BD := IncludeTrailingPathDelimiter(pasta);
 DataBaseB := Pasta_BD + Database;
  TFDConnection(Sender).Params.Clear;
  TFDConnection(Sender).Params.Add('DriverID=FB');
  TFDConnection(Sender).Params.Add('Server=' + Servidor_BD);
  TFDConnection(Sender).Params.Add('Port=' + Porta_BD);
  TFDConnection(Sender).Params.Add('Database=' + DataBaseB);
  TFDConnection(Sender).Params.Add('User_Name=' + Usuario_BD);
  TFDConnection(Sender).Params.Add('Password=' + Senha_BD);
  TFDConnection(Sender).Params.Add('Protocol=TCPIP');
  TFDConnection(Sender).DriverName  := 'FB';
  TFDConnection(Sender).LoginPrompt := FALSE;
  TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
END;

END.
