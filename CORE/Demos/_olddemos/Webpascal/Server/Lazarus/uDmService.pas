unit uDmService;

interface

{$DEFINE APPWIN}

uses
  SysUtils, Classes, IBConnection, sqldb, uDWDatamodule, uDWJSONObject, Dialogs,
  ZConnection, ZDataset, ServerUtils, uDWConsts, uDWConstsData, uRESTDWPoolerDB,
  uRESTDWServerEvents, uRESTDWServerContext, uDWJSONTools,
  LConvEncoding,
  {$IFDEF APPWIN}
  RestDWServerFormU
  {$ELSE}
  uConsts
  {$ENDIF}, SysTypes;

Const
 WelcomeSample = False;
 Const404Page  = 'www\404.html';
 bl            = #10#13;
 cInvalidChar  = #65533;


type

  { TServerMethodDM }

  TServerMethodDM = class(TServerMethodDataModule)
    dwcrIndex: TDWContextRules;
    dwcrLogin: TDWContextRules;
    dwsCrudServer: TDWServerContext;
    rOpenSecrets: TRESTDWClientSQL;
    Server_FDConnection: TZConnection;
    FDQuery1: TZQuery;
    procedure DataModuleGetToken(Welcomemsg, AccessTag: String;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage: String; var TokenID: String;
      var Accept: Boolean);
    procedure DataModuleUserTokenAuth(Welcomemsg, AccessTag: String;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage: String; var TokenID: String;
      var Accept: Boolean);
    procedure dwcrIndexBeforeRenderer(aSelf: TComponent);
    procedure dwcrIndexItemscadModalBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsdatatableRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrIndexItemsdeleteModalRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrIndexItemsdwcbCargosRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrIndexItemsdwcbpaisesBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsdwcbpaisesRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrIndexItemsdwframeBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsdwmyhtmlRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrIndexItemsdwsidemenuBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemseditModalRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrIndexItemsLabelMenuBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsmeuloginnameBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsoperationRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrLoginBeforeRenderer(aSelf: TComponent);
    procedure dwcrLoginItemsmeuloginnameBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwsCrudServerBeforeRenderer(aSelf: TComponent);
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
  private
    { Private declarations }
    IDUser     : Integer;
    IDUserName,
    vTokenID   : String;
    Function MyMenu: String;
  public
    { Public declarations }
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

uses uDWConstsCharset;
{$R *.lfm}

Function LoadHTMLFile(FileName : String) : String;
Var
 vStringCad : TStringList;
begin
 vStringCad := TStringList.Create;
 Try
  vStringCad.LoadFromFile(FileName);
  Result := utf8decode(vStringCad.Text);
 Finally
  vStringCad.Free;
 End;
end;

Function SwapHTMLDateToDelphiDate(Value : String) : String;
Begin
 Result := Value;
 If Pos('-', Value) > 0 Then
  Begin
   Result := Copy(Value, 1, Pos('-', Value) -1);
   Delete(Value, 1, Pos('-', Value));
   Result := Copy(Value, 1, Pos('-', Value) -1) + '/' + Result;
   Delete(Value, 1, Pos('-', Value));
   Result := Copy(Value, 1, Length(Value)) + '/' + Result;
  End;
End;

procedure TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
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
   TZConnection(Sender).LibraryLocation := IncludeTrailingPathDelimiter(ExtractFilePath(ParamSTR(0))) + 'fbclient.dll';
End;

procedure TServerMethodDM.DataModuleGetToken(Welcomemsg, AccessTag: String;
  Params: TDWParams; AuthOptions: TRDWAuthTokenParam; var ErrorCode: Integer;
  var ErrorMessage: String; var TokenID: String; var Accept: Boolean);
Var
 vMyClient,
 vTokenID,
 vMyPass,
 vIddToken    : String;
 Function RejectURL : String;
 Var
  v404Error  : TStringList;
 Begin
  v404Error  := TStringList.Create;
  Try
   {$IFDEF APPWIN}
    {$IFDEF SYNOPSE}
     v404Error.LoadFromFile(RestDWForm.RESTDWServiceSynPooler1.RootPath + Const404Page);
    {$ELSE}
     v404Error.LoadFromFile(RestDWForm.RESTServicePooler1.RootPath + Const404Page);
    {$ENDIF}
   {$ELSE}
   v404Error.LoadFromFile('.\www\' + Const404Page);
   {$ENDIF}
   Result := v404Error.Text;
  Finally
   v404Error.Free;
  End;
 End;
begin
 vTokenID   := TokenID;
 If Pos('bearer', lowercase(vTokenID)) > 0 Then
  vTokenID  := StringReplace(DecodeStrings(Trim(Copy(vTokenID, Pos('bearer', lowercase(vTokenID)) + 6, Length(vTokenID))), csUndefined), cInvalidChar, '', [rfReplaceAll])
 Else
  vTokenID  := StringReplace(DecodeStrings(vTokenID, csUndefined), cInvalidChar, '', [rfReplaceAll]);
 vMyClient  := Copy(vTokenID, InitStrPos, Pos(':', vTokenID) -1);
 Delete(vTokenID, InitStrPos, Pos(':', vTokenID));
 vMyPass    := Trim(vTokenID);
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

procedure TServerMethodDM.DataModuleUserTokenAuth(Welcomemsg,
  AccessTag: String; Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
  var ErrorCode: Integer; var ErrorMessage: String; var TokenID: String;
  var Accept: Boolean);
Var
 vSecrets : String;
 vUserID : Integer;
 Function RejectURL : String;
 Var
  v404Error  : TStringList;
 Begin
  v404Error  := TStringList.Create;
  Try
   {$IFDEF APPWIN}
    {$IFDEF SYNOPSE}
     v404Error.LoadFromFile(RestDWForm.RESTDWServiceSynPooler1.RootPath + Const404Page);
    {$ELSE}
     v404Error.LoadFromFile(RestDWForm.RESTServicePooler1.RootPath + Const404Page);
    {$ENDIF}
   {$ELSE}
   v404Error.LoadFromFile('.\www\' + Const404Page);
   {$ENDIF}
   Result := v404Error.Text;
  Finally
   v404Error.Free;
  End;
 End;
begin
 Accept  := TokenID <> '';
 If Accept Then
  Begin
   rOpenSecrets.OpenJson(AuthOptions.Secrets);
   vSecrets := rOpenSecrets.FindField('secrets').AsString;
   rOpenSecrets.Close;
   rOpenSecrets.OpenJson(DecodeStrings(vSecrets, csUndefined));
   vUserID := rOpenSecrets.FindField('ID').AsInteger;
   rOpenSecrets.Close;
   FDQuery1.Close;
   FDQuery1.SQL.Clear;
   FDQuery1.SQL.Add('select * from TB_USUARIO where ID_PESSOA = :ID');
   Try
    FDQuery1.ParamByName('ID').AsInteger := vUserID;
    FDQuery1.Open;
    IDUser     := FDQuery1.FindField('ID_PESSOA').AsInteger;
    IDUserName := FDQuery1.FindField('NM_LOGIN').AsString;
   Finally
    Accept  := Not FDQuery1.EOF;
    If Not Accept Then
     Begin
      ErrorMessage := RejectURL;
      ErrorCode  := 404;
     End;
    FDQuery1.Close;
   End;
  End
 Else
  Begin
   ErrorMessage := RejectURL;
   ErrorCode  := 404;
  End;
end;

procedure TServerMethodDM.dwcrIndexBeforeRenderer(aSelf: TComponent);
begin
 TDWContextRules(aSelf).MasterHtml.LoadFromFile('.\www\templates\index.html');
end;

procedure TServerMethodDM.dwcrIndexItemscadModalBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 ContextItemTag := LoadHTMLFile('.\www\templates\cademployee.html');
end;

procedure TServerMethodDM.dwcrIndexItemsdatatableRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
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

procedure TServerMethodDM.dwcrIndexItemsdeleteModalRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
begin
 result := 'true';
 FDQuery1.Close;
 FDQuery1.SQL.Clear;
 FDQuery1.SQL.Add('delete from employee where emp_no = ' + Params.ItemsString['id'].AsString);
 Server_FDConnection.StartTransaction;
 Try
  FDQuery1.ExecSQL;
  Server_FDConnection.Commit;
 Except
  Server_FDConnection.Rollback;
  result := 'false';
 End;
end;

procedure TServerMethodDM.dwcrIndexItemsdwcbCargosRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue            := TJSONValue.Create;
 Try
  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add('select JOB_GRADE, (JOB_COUNTRY ||''/''|| JOB_TITLE)JOB_TITLE from JOB');
  Try
   FDQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
   JSONValue.LoadFromDataset('', FDQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.');
   Result             := JSONValue.ToJson;
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

procedure TServerMethodDM.dwcrIndexItemsdwcbpaisesBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 FDQuery1.Close;
 FDQuery1.SQL.Clear;
 FDQuery1.SQL.Add('select * from COUNTRY');
 FDQuery1.Open;
 ContextItemTag := ContextItemTag + '<option value="" >Selecione seu país</option>';
 While Not FDQuery1.EOF Do
  Begin
   ContextItemTag := ContextItemTag + Format('<option value="%s">%s</option>', [FDQuery1.FindField('UF').AsString,
                                                                                FDQuery1.FindField('COUNTRY').AsString]);
   FDQuery1.Next;
  End;
 ContextItemTag := ContextItemTag + '</select>';
 FDQuery1.Close;
end;

procedure TServerMethodDM.dwcrIndexItemsdwcbpaisesRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue            := TJSONValue.Create;
 Try
  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add('select UF, COUNTRY from COUNTRY');
  Try
   FDQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
   JSONValue.LoadFromDataset('', FDQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.');
   Result             := JSONValue.ToJson;
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

procedure TServerMethodDM.dwcrIndexItemsdwframeBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 ContextItemTag := LoadHTMLFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamSTR(0))) + 'www\templates\dataFrame.html');
end;

procedure TServerMethodDM.dwcrIndexItemsdwmyhtmlRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
begin
 ContentType := 'text/html';
 If Params.ItemsString['myhtml'] <> Nil Then
  Result := LoadHTMLFile('www\templates\' + Params.ItemsString['myhtml'].AsString + '.html');
end;

procedure TServerMethodDM.dwcrIndexItemsdwsidemenuBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 ContextItemTag := ContextItemTag + MyMenu;
end;

procedure TServerMethodDM.dwcrIndexItemseditModalRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue            := TJSONValue.Create;
 Try
  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add('select * from employee where emp_no = '+params.ItemsString['id'].AsString);

  Try
   FDQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
   JSONValue.LoadFromDataset('', FDQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.');
   Result             := JSONValue.ToJson;
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

procedure TServerMethodDM.dwcrIndexItemsLabelMenuBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 If IDUser > 0 then
  ContextItemTag := MyMenu;
end;

procedure TServerMethodDM.dwcrIndexItemsmeuloginnameBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 ContextItemTag := Format('<p id="mynamepan" idd="%d">%s</p>', [IDUser, IDUserName]);
end;

procedure TServerMethodDM.dwcrIndexItemsoperationRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
begin
 Result := 'true';
 Server_FDConnection.StartTransaction;
 FDQuery1.Close;
 FDQuery1.SQL.Clear;
 If Params.ItemsString['operation'].AsString = 'edit' Then
  FDQuery1.SQL.Add('update employee set FIRST_NAME = :FIRST_NAME, LAST_NAME = :LAST_NAME, ' +
                   'PHONE_EXT = :PHONE_EXT, HIRE_DATE = :HIRE_DATE, DEPT_NO = :DEPT_NO, ' +
                   'JOB_CODE  = :JOB_CODE, JOB_GRADE = :JOB_GRADE, JOB_COUNTRY = :JOB_COUNTRY, ' +
                   'SALARY = :SALARY ' +
                   'Where EMP_NO = ' + Params.ItemsString['id'].AsString)
 Else If Params.ItemsString['operation'].AsString = 'insert' Then
  FDQuery1.SQL.Add('insert into employee (EMP_NO, FIRST_NAME, LAST_NAME, ' +
                                          'PHONE_EXT, HIRE_DATE, DEPT_NO, ' +
                                          'JOB_CODE, JOB_GRADE, JOB_COUNTRY, SALARY) ' +
                   'VALUES (gen_id(emp_no_gen, 1), :FIRST_NAME, :LAST_NAME, :PHONE_EXT, :HIRE_DATE, :DEPT_NO, :JOB_CODE, ' +
                           ':JOB_GRADE, :JOB_COUNTRY, :SALARY)')
 Else If Params.ItemsString['operation'].AsString = 'delete' Then
  FDQuery1.SQL.Add('delete from employee Where EMP_NO = ' + Params.ItemsString['id'].AsString);
 Try
  If Params.ItemsString['operation'].AsString <> 'delete' Then
   Begin
    FDQuery1.ParamByName('FIRST_NAME').AsString  := Params.ItemsString['FIRST_NAME'].AsString;
    FDQuery1.ParamByName('LAST_NAME').AsString   := Params.ItemsString['LAST_NAME'].AsString;
    FDQuery1.ParamByName('PHONE_EXT').AsString   := StringReplace(StringReplace(Params.ItemsString['PHONE_EXT'].AsString, '(', '', [rfReplaceAll]), ')', '', [rfReplaceAll]);
    FDQuery1.ParamByName('DEPT_NO').AsString     := '600';
    FDQuery1.ParamByName('JOB_CODE').AsString    := 'Vp';
    FDQuery1.ParamByName('HIRE_DATE').AsDateTime := StrToDate(SwapHTMLDateToDelphiDate(Params.ItemsString['HIRE_DATE'].asstring));
    FDQuery1.ParamByName('JOB_GRADE').AsString   := Params.ItemsString['JOB_GRADE'].AsString;
    FDQuery1.ParamByName('JOB_COUNTRY').AsString := Params.ItemsString['JOB_COUNTRY'].AsString;
    FDQuery1.ParamByName('SALARY').AsFloat       := Params.ItemsString['SALARY'].AsFloat;
   End;
  FDQuery1.ExecSQL;
  Server_FDConnection.Commit;
 Except
  On E : Exception Do
    Begin
     Server_FDConnection.Rollback;
     Result := 'false';
    End;
 End;
end;

procedure TServerMethodDM.dwcrLoginBeforeRenderer(aSelf: TComponent);
begin
 TDWContextRules(aSelf).MasterHtml.LoadFromFile('.\www\templates\login.html');
end;

procedure TServerMethodDM.dwcrLoginItemsmeuloginnameBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 ContextItemTag := Format('<p id="mynamepan" idd="%d">%s</p>', [IDUser, IDUserName]);
end;

procedure TServerMethodDM.dwsCrudServerBeforeRenderer(aSelf: TComponent);
begin
 TDWServerContext(aSelf).BaseHeader.LoadFromFile('.\www\templates\master.html');
 TDWServerContext(aSelf).BaseHeader.text := utf8decode(TDWServerContext(aSelf).BaseHeader.text);
end;

Function TServerMethodDM.MyMenu: String;
Begin
 If (IDUser > 0) Then
  Result := Format('<li class="active"><a href=# onClick="newEmployee()"><i class="fa fa-address-book"></i> <span>Novo Empregado</span></a></li>'    + bl +
                   '<li class="active"><a href=# onClick="reloadDatatable(true)"><i class="fa fa-users"></i> <span>Lista de Empregados</span></a></li>' + bl +
                   '<li class="active"><a href="./login"><i class="fa fa-sign-out"></i> <span>Logout</span></a></li>', [Uppercase(IDUserName)])
 Else
  Result := '';
End;

end.
