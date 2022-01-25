Unit uDmService;

Interface

{$DEFINE APPWIN}
{.$DEFINE SYNOPSE}

Uses
  SysUtils,
  Classes,
  SysTypes,
  UDWDatamodule,
  uDWMassiveBuffer,
  System.IOUtils,
  System.JSON,
  UDWJSONObject,
  {$IFDEF APPWIN}
  RestDWServerFormU,
  {$ELSE}
  uConsts,
  {$ENDIF}
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
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  uDWConsts, uRESTDWServerEvents, uSystemEvents, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, uDWAbout, FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL, uRESTDWServerContext, FireDAC.Phys.PGDef, FireDAC.Phys.PG;

Const
 WelcomeSample = False;
 Const404Page  = 'www\404.html';
 bl            = #10#13;
 cInvalidChar  = #65533;

Type
  TServerMethodDM = Class(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    Server_FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDTransaction1: TFDTransaction;
    FDQuery1: TFDQuery;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    dwsCrudServer: TDWServerContext;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    dwcrIndex: TDWContextRules;
    dwcrLogin: TDWContextRules;
    rOpenSecrets: TRESTDWClientSQL;
    Procedure ServerMethodDataModuleCreate(Sender: TObject);
    Procedure Server_FDConnectionBeforeConnect(Sender: TObject);
    procedure dwcrIndexItemsdatatableRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure dwcrIndexItemseditModalRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure dwcrIndexItemsdeleteModalRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure dwcrIndexItemsoperationRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure dwcrIndexItemsdwcbPaisesBeforeRendererContextItem(
      var ContextItemTag: string);
    procedure dwcrIndexItemsdwsidemenuBeforeRendererContextItem(
      var ContextItemTag: string);
    procedure dwcrIndexBeforeRenderer(aSelf: TComponent);
    procedure dwcrLoginBeforeRenderer(aSelf: TComponent);
    procedure dwcrIndexItemscadModalBeforeRendererContextItem(
      var ContextItemTag: string);
    procedure dwsCrudServerBeforeRenderer(aSelf: TComponent);
    procedure dwcrLoginItemsmeuloginnameBeforeRendererContextItem(
      var ContextItemTag: string);
    procedure dwcrIndexItemsmeuloginnameBeforeRendererContextItem(
      var ContextItemTag: string);
    procedure dwcrIndexItemsLabelMenuBeforeRendererContextItem(
      var ContextItemTag: string);
    procedure dwcrIndexItemsdwmyhtmlRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure dwcrIndexItemsdwframeBeforeRendererContextItem(
      var ContextItemTag: string);
    procedure dwcrIndexItemsdwcbPaisesRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure dwcrIndexItemsdwcbCargosRequestExecute(const Params: TDWParams;
      var ContentType, Result: string);
    procedure ServerMethodDataModuleGetToken(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions : TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
    procedure ServerMethodDataModuleUserTokenAuth(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
    procedure dwsCrudServerContextListindex2BeforeRenderer(
      const BaseHeader: string; var ContentType, ContentRenderer: string;
      const RequestType: TRequestType);
  Private
    { Private declarations }
   IDUser     : Integer;
   IDUserName,
   vTokenID   : String;
   Function MyMenu: String;
  Public
    { Public declarations }
  End;

Var
 ServerMethodDM : TServerMethodDM;

Implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

Uses uDWJSONTools;

{$R *.dfm}

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

procedure TServerMethodDM.dwcrIndexBeforeRenderer(aSelf: TComponent);
begin
 TDWContextRules(aSelf).MasterHtml.LoadFromFile('.\www\templates\index.html');
end;

procedure TServerMethodDM.dwcrIndexItemscadModalBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 ContextItemTag := LoadHTMLFile('.\www\templates\cademployee.html');
end;

procedure TServerMethodDM.dwcrIndexItemsdatatableRequestExecute(
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
  const Params: TDWParams; var ContentType, Result: string);
begin
 result := 'true';
 FDQuery1.Close;
 FDQuery1.SQL.Clear;
 FDQuery1.SQL.Add('delete from employee where emp_no = ' + Params.ItemsString['id'].AsString);
 Try
  FDQuery1.ExecSQL;
  Server_FDConnection.CommitRetaining;
 Except
  Server_FDConnection.Rollback;
  result := 'false';
 End;
end;

procedure TServerMethodDM.dwcrIndexItemsdwcbCargosRequestExecute(
  const Params: TDWParams; var ContentType, Result: string);
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

procedure TServerMethodDM.dwcrIndexItemsdwcbPaisesBeforeRendererContextItem(
  var ContextItemTag: string);
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

procedure TServerMethodDM.dwcrIndexItemsdwcbPaisesRequestExecute(
  const Params: TDWParams; var ContentType, Result: string);
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
  var ContextItemTag: string);
begin
 ContextItemTag := LoadHTMLFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamSTR(0)), 'www\templates\dataFrame.html'));
end;

procedure TServerMethodDM.dwcrIndexItemsdwmyhtmlRequestExecute(
  const Params: TDWParams; var ContentType, Result: string);
begin
 ContentType := 'text/html';
 If Params.ItemsString['myhtml'] <> Nil Then
  Result := LoadHTMLFile('www\templates\' + Params.ItemsString['myhtml'].AsString + '.html');
end;

procedure TServerMethodDM.dwcrIndexItemsdwsidemenuBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 ContextItemTag := ContextItemTag + MyMenu;
end;

procedure TServerMethodDM.dwcrIndexItemseditModalRequestExecute(
  const Params: TDWParams; var ContentType, Result: string);
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
   JSONValue.LoadFromDataset('', FDQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', ',');
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

Function TServerMethodDM.MyMenu : String;
Begin
 If (IDUser > 0) Then
  Result := '<li class="nav-item menu-open"><a href="#" class="nav-link" onClick="newEmployee()"><i class="nav-icon far fa-image"></i><p>Novo Empregado</p></a></li>' +
            '<li class="nav-item menu-open"><a href="#" class="nav-link" onClick="reloadDatatable(true)"><i class="nav-icon far fa-image"></i><p>Lista de Empregados</p></a></li>' +
            '<li class="nav-item menu-open"><a href="#" class="nav-link" onClick="logout()"><i class="nav-icon far fa-image"></i><p>Logout<i class="right fas fa-angle-left"></i></p></a></li>'
 Else
  Result := '';
End;

procedure TServerMethodDM.dwcrIndexItemsLabelMenuBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 If IDUser > 0 then
  ContextItemTag := MyMenu;
end;

procedure TServerMethodDM.dwcrIndexItemsmeuloginnameBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 ContextItemTag := Format('<a id="mynamepan" idd="%d" href="#" class="d-block">%s</a>', [IDUser, IDUserName]);
end;

procedure TServerMethodDM.dwcrIndexItemsoperationRequestExecute(
  const Params: TDWParams; var ContentType, Result: string);
Var
 vSalary : String;
 Function LimpaLixo(Value : String) : String;
 Begin
  Result := Value;
  Result := StringReplace(Result, 'R', '', [rfReplaceAll]);
  Result := StringReplace(Result, '$', '', [rfReplaceAll]);
  Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
 End;
begin
 Result := 'true';
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
    vSalary := Limpalixo(Params.ItemsString['SALARY'].asstring);
    FDQuery1.ParamByName('SALARY').AsFloat       := StrToFloat(vSalary);
   End;
  FDQuery1.ExecSQL;
  Server_FDConnection.CommitRetaining;
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
  var ContextItemTag: string);
begin
 ContextItemTag := Format('<a id="mynamepan" idd="%d" href="#" class="d-block">%s</a>', [IDUser, IDUserName]);
end;

procedure TServerMethodDM.dwsCrudServerBeforeRenderer(aSelf: TComponent);
begin
 TDWServerContext(aSelf).BaseHeader.LoadFromFile('.\www\templates\master.html');
 TDWServerContext(aSelf).BaseHeader.text := utf8decode(TDWServerContext(aSelf).BaseHeader.text);
end;

procedure TServerMethodDM.dwsCrudServerContextListindex2BeforeRenderer(
  const BaseHeader: string; var ContentType, ContentRenderer: string;
  const RequestType: TRequestType);
Var
 vIndexPage : TStringStream;
begin
 vIndexPage := TStringStream.Create;
 Try
  vIndexPage.LoadFromFile('.\www\index.html');
  ContentRenderer := vIndexPage.DataString;
 Finally
  FreeAndNil(vIndexPage);
 End;
end;

Procedure TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
Begin
 {$IFDEF APPWIN}
 RESTDWPoolerDB1.Active := RestDWForm.CbPoolerState.Checked;
 {$ENDIF}
End;

procedure TServerMethodDM.ServerMethodDataModuleGetToken(Welcomemsg,
  AccessTag: string; Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
  var ErrorCode: Integer; var ErrorMessage, TokenID: string;
  var Accept: Boolean);
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
  vTokenID  := StringReplace(DecodeStrings(Trim(Copy(vTokenID, Pos('bearer', lowercase(vTokenID)) + 6, Length(vTokenID)))), cInvalidChar, '', [rfReplaceAll])
 Else
  vTokenID  := StringReplace(DecodeStrings(vTokenID), cInvalidChar, '', [rfReplaceAll]);
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

procedure TServerMethodDM.ServerMethodDataModuleUserTokenAuth(Welcomemsg,
  AccessTag: string; Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
  var ErrorCode: Integer; var ErrorMessage, TokenID: string;
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
   rOpenSecrets.OpenJson(DecodeStrings(vSecrets));
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

Procedure TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
Var
 Driver_BD,
 Porta_BD,
 Servidor_BD,
 DataBase,
 Pasta_BD,
 Usuario_BD,
 Senha_BD   : String;
Begin
 {$IFDEF APPWIN}
 database     := RestDWForm.EdBD.Text;
 Driver_BD    := RestDWForm.CbDriver.Text;
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
  3 : Driver_BD := 'PG';
 End;
 Porta_BD   := RestDWForm.EdPortaBD.Text;
 Usuario_BD := RestDWForm.EdUserNameBD.Text;
 Senha_BD   := RestDWForm.EdPasswordBD.Text;
 {$ELSE}
 Servidor_BD := servidor;
 Porta_BD    := IntToStr(portaBD);
 Database    := pasta + databaseC;
 Usuario_BD  := usuarioBD;
 Senha_BD    := senhaBD;
 Driver_BD   := DriverBD;
 {$ENDIF}
 TFDConnection(Sender).Params.Clear;
 TFDConnection(Sender).Params.Add('DriverID='  + Driver_BD);
 TFDConnection(Sender).Params.Add('Server='    + Servidor_BD);
 TFDConnection(Sender).Params.Add('Port='      + Porta_BD);
 TFDConnection(Sender).Params.Add('Database='  + Database);
 TFDConnection(Sender).Params.Add('User_Name=' + Usuario_BD);
 TFDConnection(Sender).Params.Add('Password='  + Senha_BD);
 TFDConnection(Sender).Params.Add('Protocol=TCPIP');
 TFDConnection(Sender).DriverName                        := Driver_BD;
 TFDConnection(Sender).LoginPrompt                       := FALSE;
 TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
End;

End.
