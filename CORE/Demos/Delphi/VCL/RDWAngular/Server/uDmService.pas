UNIT uDmService;

INTERFACE

USES
  SysUtils,
  System.StrUtils,
  Classes,
  SysTypes,
  System.Variants,
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
  RestDWServerFormU,
  URESTDWPoolerDB,
  URestDWDriverFD,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  uDWConsts, uRESTDWServerEvents, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, uDWAbout, FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL,
  System.NetEncoding;

Const
 WelcomeSample = False;
 Const404Page  = 'www\404.html';

TYPE
  TServerMethodDM = CLASS(TServerMethodDataModule)
    Server_FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDTransaction1: TFDTransaction;
    FDQuery1: TFDQuery;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    DWServerEvents1: TDWServerEvents;
    RESTDWDriverFD1: TRESTDWDriverFD;
    qryEmployee: TFDQuery;
    qryEmployeeEMP_NO: TSmallintField;
    qryEmployeeFIRST_NAME: TStringField;
    qryEmployeeLAST_NAME: TStringField;
    qryEmployeePHONE_EXT: TStringField;
    qryEmployeeHIRE_DATE: TSQLTimeStampField;
    qryEmployeeDEPT_NO: TStringField;
    qryEmployeeJOB_CODE: TStringField;
    qryEmployeeJOB_GRADE: TSmallintField;
    qryEmployeeJOB_COUNTRY: TStringField;
    qryEmployeeFULL_NAME: TStringField;
    qryEmployeeSALARY: TFloatField;
    PROCEDURE ServerMethodDataModuleCreate(Sender: TObject);
    PROCEDURE Server_FDConnectionBeforeConnect(Sender: TObject);
    PROCEDURE Server_FDConnectionError(ASender, AInitiator: TObject; VAR AException: Exception);
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
    procedure ServerMethodDataModuleWelcomeMessage(Welcomemsg,
      AccessTag: string; var Accept: Boolean);
    procedure DWServerEvents1EventsgetemployeeDWReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWServerEvents1EventsemployeeReplyEvent(var Params: TDWParams;
      var Result: string);
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
    function GetGenID(GenName: String): Integer;
    procedure employeeReplyEvent(var Params: TDWParams; dJsonMode : TJsonMode; Var Result : String);
  PUBLIC
    { Public declarations }
  END;

VAR
  ServerMethodDM: TServerMethodDM;

implementation

uses
  uDWJSONTools;

{%CLASSGROUP 'Vcl.Controls.TControl'}
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

procedure TServerMethodDM.DWServerEvents1EventsemployeeReplyEvent(
  var Params: TDWParams; var Result: string);
var
  JObj: TJSONObject;
  JSONValue: TJSONValue;
  EMP_NO: Integer;
  FIRST_NAME, LAST_NAME, PHONE_EXT: string;
  SALARY: Currency;
  bytes: TBytes;
  text: string;

  function GetEmployee(AId: Integer): String;
  begin
    JSONValue := TJSONValue.Create;
    Try
      qryEmployee.Close;
      qryEmployee.Macros[0].AsRaw := IfThen(AId > 0, ' WHERE EMP_NO = ' + Aid.ToString, '');
      qryEmployee.Open;
      JSONValue.Encoding :=Encoding;
      JSONValue.LoadFromDataset('', qryEmployee, False,  Params.JsonMode, 'dd/mm/yyyy', '.');
      Result :=  JSONValue.ToJSON;
    Finally
      JSONValue.Free;
    End;
  end;

  function RemoveLineBreaks(Str: string ): string;
  begin
    Result := stringReplace(Str, #$D#$A, '', [rfReplaceAll]);
    Result := stringReplace(Result, #13#10, '', [rfReplaceAll]);
    Result := stringReplace(Result, #9, '', [rfReplaceAll]);
    Result := stringReplace(Result, '"', '', [rfReplaceAll]);
  end;
begin
  if Params.ItemsString['set'].AsString <> '' then
  begin
    text:='';
    bytes := TNetEncoding.Base64.DecodeStringToBytes(Params.ItemsString['set'].AsString);
    text := TEncoding.ANSI.GetString(bytes);
    JObj := TJSONObject.ParseJSONValue(text) as TJSONObject;

    if Jobj.TryGetValue('EMP_NO', EMP_NO) then
    begin
      try
        qryEmployee.Close;
        qryEmployee.Macros[0].AsRaw := ' WHERE EMP_NO = ' + EMP_NO.ToString;
        qryEmployee.Open;

        if qryEmployee.IsEmpty then
          qryEmployee.Append
        else
          qryEmployee.Edit;

        Jobj.TryGetValue('FIRST_NAME', FIRST_NAME);
        Jobj.TryGetValue('LAST_NAME', LAST_NAME);
        Jobj.TryGetValue('PHONE_EXT', PHONE_EXT);
        Jobj.TryGetValue('SALARY', SALARY);

        qryEmployeeFIRST_NAME.AsString  := FIRST_NAME;
        qryEmployeeLAST_NAME.AsString   := LAST_NAME;
        qryEmployeePHONE_EXT.AsString   := PHONE_EXT;

        if qryEmployee.State = dsInsert then
        begin
          qryEmployeeDEPT_NO.AsString     := '600';
          qryEmployeeJOB_CODE.AsString    := 'VP';
          qryEmployeeJOB_GRADE.AsInteger  := 2;
          qryEmployeeJOB_COUNTRY.AsString := 'USA';
        end;

        qryEmployeeSALARY.AsFloat      := SALARY;
        qryEmployee.Post;
        Server_FDConnection.Commit;
        Params.ItemsString['result'].AsBoolean := True;
      except
        on E: Exception do
          raise Exception.Create('Erro ao Salvar Employee: ' + RemoveLineBreaks(E.Message));
      end;
    end;
  end
  else if Params.ItemsString['delete'].AsString <> '' then
  begin
    EMP_NO := StrToInt(DecodeStrings( Params.ItemsString['delete'].AsString));
    qryEmployee.Close;
    qryEmployee.Macros[0].AsRaw := ' WHERE EMP_NO = ' + EMP_NO.ToString;
    qryEmployee.Open;

    if qryEmployee.IsEmpty then
      raise Exception.Create('ID não encontrado');
    try
      qryEmployee.Delete; 
      Server_FDConnection.Commit;
      Params.ItemsString['result'].AsBoolean := True;
    except
      on E: EFDDBEngineException do
      begin
        case E.Kind of
                ekOther: ;
                ekNoDataFound: ;
                ekTooManyRows: ;
                ekRecordLocked: ;
                ekUKViolated: ShowMessage('Esse ID Já Existe!!');
                ekFKViolated: ShowMessage('Registro Com Vínculo Na Tabela Employee,'+#13+
                                          'Não Pode Ser Excluído!!');
                ekObjNotExists: ;
                ekUserPwdInvalid: ;
                ekUserPwdExpired: ;
                ekUserPwdWillExpire: ;
                ekCmdAborted: ;
                ekServerGone: ;
                ekServerOutput: ;
                ekArrExecMalfunc: ;
                ekInvalidParams: ;
        end; 
      end;
    end;  
  end
  else
  begin
    try
      if Params.ItemsString['get'].AsString <> '' then
      begin
        EMP_NO := StrToInt(DecodeStrings( Params.ItemsString['get'].AsString));
         //Params.ItemsString['result'].AsObject := GetEmployee(EMP_NO);
         result := GetEmployee(EMP_NO);
      end else
         employeeReplyEvent(Params, Params.JsonMode, Result);
    except
      on E: Exception do
        raise Exception.Create('Erro ao Listar Employee: ' + RemoveLineBreaks(E.Message));
    end;
  end;
end;

procedure TServerMethodDM.DWServerEvents1EventsgetemployeeDWReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 employeeReplyEvent(Params, Params.JsonMode,Result);
end;

procedure TServerMethodDM.DWServerEvents1EventsgetemployeeReplyEvent(
  var Params: TDWParams; var Result: string);
Begin
 employeeReplyEvent(Params, Params.JsonMode, Result);
End;

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

    End;
   Finally
    JSONValue.DisposeOf;
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
  RESTDWPoolerDB1.Active := RestDWForm.CbPoolerState.Checked;
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
   FDQuery1.Close;
   FDQuery1.SQL.Clear;
   FDQuery1.SQL.Add('select * from TB_USUARIO where Upper(NM_LOGIN) = Upper(:NM_LOGIN) and Upper(DS_SENHA) = Upper(:DS_SENHA)');
   Try
    FDQuery1.ParamByName('NM_LOGIN').AsString := vMyClient;
    FDQuery1.ParamByName('DS_SENHA').AsString := vMyPass;
    FDQuery1.Open;
   Finally
    Accept     := Not(FDQuery1.EOF);
    If Not Accept Then
     Begin
      ErrorMessage := cInvalidAuth;
      ErrorCode  := 401;
     End
    Else
     TokenID := AuthOptions.GetToken(Format('{"id":"%s", "login":"%s"}', [FDQuery1.FindField('ID_PESSOA').AsString,
                                                                          FDQuery1.FindField('NM_LOGIN').AsString]));
    FDQuery1.Close;
   End;
  End
 Else
  Begin
   ErrorMessage := cInvalidAuth;
   ErrorCode  := 401;
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
 Accept := True;
end;

procedure TServerMethodDM.ServerMethodDataModuleWelcomeMessage(Welcomemsg,
  AccessTag: string; var Accept: Boolean);
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
    FDQuery1.Close;
    FDQuery1.SQL.Clear;
    FDQuery1.SQL.Add('select * from TB_USUARIO where Upper(NM_LOGIN) = Upper(:USERNAME) AND Upper(DS_SENHA) = Upper(:PASSWORD)');
    FDQuery1.ParamByName('USERNAME').AsString := vUserNameWM;
    FDQuery1.ParamByName('PASSWORD').AsString := vPasswordWM;
    FDQuery1.Open;
   Finally
    Accept := Not(FDQuery1.Eof);
    FDQuery1.Close;
   End;
// Accept := ((AccessTag)  = RESTDWPoolerDB1.AccessTag) Or
//          ((Welcomemsg) = 'teste');
  End;
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
BEGIN
 database:= RestDWForm.EdBD.Text;

  Driver_BD := RestDWForm.CbDriver.Text;
  If RestDWForm.CkUsaURL.Checked Then
  Begin
    Servidor_BD := RestDWForm.EdURL.Text;
  end
  Else
  Begin
    Servidor_BD := RestDWForm.DatabaseIP;
  end;

  Case RestDWForm.CbDriver.ItemIndex Of
    0: // FireBird
      Begin
        Pasta_BD := IncludeTrailingPathDelimiter(RestDWForm.EdPasta.Text);
        Database := RestDWForm.edBD.Text;
        Database := Pasta_BD + Database;
      end;
    1: // MSSQL
      Begin
        Database := RestDWForm.EdBD.Text;
      end;
  end;

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
  TFDConnection(Sender).DriverName  := Driver_BD;
  TFDConnection(Sender).LoginPrompt := FALSE;
  TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
END;

PROCEDURE TServerMethodDM.Server_FDConnectionError(ASender, AInitiator: TObject; VAR AException: Exception);
BEGIN
  RestDWForm.memoResp.Lines.Add(AException.Message);
END;

END.
