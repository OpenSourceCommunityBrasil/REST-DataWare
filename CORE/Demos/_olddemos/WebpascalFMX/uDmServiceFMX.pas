unit uDmServiceFMX;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.UI, uRESTDWServerContext, System.IOUtils,
  FireDAC.Comp.DataSet, uRESTDWPoolerDB, uRestDWDriverFD, uDWAbout, UDWJSONObject,
  uDWConsts, uDWJSONTools, UDWDatamodule;

Const
 WelcomeSample = False;
 Const404Page  = 'www/404.html';
 bl            = #10#13;

type
  TServerMethodDM = class(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    FDQuery1: TFDQuery;
    dwsCrudServer: TDWServerContext;
    dwcrIndex: TDWContextRules;
    dwcrLogin: TDWContextRules;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDTransaction: TFDTransaction;
    sqlLocalDBC: TFDConnection;
    procedure sqlLocalDBCBeforeConnect(Sender: TObject);
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
    procedure dwcrIndexItemsdwcbCargosBeforeRendererContextItem(
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
    procedure dwsCrudServerContextListindexAuthRequest(const Params: TDWParams;
      var Rejected: Boolean; var ResultError: string; var StatusCode: Integer;
      RequestHeader: TStringList);  private
    { Private declarations }
  public
    { Public declarations }
   IDUser     : Integer;
   IDUserName : String;
   Function MyMenu: String;
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

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

procedure TServerMethodDM.dwcrIndexBeforeRenderer(aSelf: TComponent);
begin
 TDWContextRules(aSelf).MasterHtml.LoadFromFile(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'www/templates/index.html'));
end;

procedure TServerMethodDM.dwcrIndexItemscadModalBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 ContextItemTag := LoadHTMLFile(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'www/templates/cademployee.html'));
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
 Result := 'true';
 FDQuery1.Close;
 FDQuery1.SQL.Clear;
 FDQuery1.SQL.Add('delete from employee where emp_no = ' + Params.ItemsString['id'].AsString);
 Try
  FDQuery1.ExecSQL;
  sqlLocalDBC.CommitRetaining;
 Except
  sqlLocalDBC.Rollback;
  Result := 'false';
 End;
end;

procedure TServerMethodDM.dwcrIndexItemsdwcbCargosBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 FDQuery1.Close;
 FDQuery1.SQL.Clear;
 FDQuery1.SQL.Add('select JOB_CODE, JOB_GRADE, JOB_COUNTRY, JOB_TITLE from JOB');
 FDQuery1.Open;
 ContextItemTag := ContextItemTag + '<option value="" >Selecione Cargo</option>';
 While Not FDQuery1.EOF Do
  Begin
   ContextItemTag := ContextItemTag + Format('<option value="%s">%s</option>', [FDQuery1.FindField('JOB_GRADE').AsString,
                                                                                FDQuery1.FindField('JOB_COUNTRY').AsString + ' - ' +
                                                                                FDQuery1.FindField('JOB_TITLE').AsString]);
   FDQuery1.Next;
  End;
 ContextItemTag := ContextItemTag + '</select>';
 FDQuery1.Close;
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

procedure TServerMethodDM.dwcrIndexItemsdwsidemenuBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 ContextItemTag := ContextItemTag +
                   '<li class="active"><a href="javascript:window.location.reload(true)"><i class="fa fa-home"></i> <span>Home</span></a></li>'+ bl +
                   '<li class="active"><a href=# onClick="loadEditCad()"><i class="fa fa-vcard"></i> <span>Novo Empregado</span></a></li>' + bl +
                   '<li class="active"><a href=# onClick="reloadDatatable(true)"><i class="fa fa-users"></i> <span>Lista de Empregado</span></a></li>' + bl +
                   '<li class="active"><a href="./login"><i class="fa fa-sign-out"></i> <span>Logout</span></a></li>';
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
  var ContextItemTag: string);
begin
 If IDUser > 0 then
  ContextItemTag := MyMenu;
end;

procedure TServerMethodDM.dwcrIndexItemsmeuloginnameBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 ContextItemTag := Format('<p id="mynamepan" idd="%d">%s</p>', [IDUser, IDUserName]);
end;

procedure TServerMethodDM.dwcrIndexItemsoperationRequestExecute(
  const Params: TDWParams; var ContentType, Result: string);
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
    FDQuery1.ParamByName('SALARY').AsFloat       := Params.ItemsString['SALARY'].AsFloat;
   End;
  FDQuery1.ExecSQL;
  sqlLocalDBC.CommitRetaining;
 Except
  On E : Exception Do
    Begin
     sqlLocalDBC.Rollback;
     Result := 'false';
    End;
 End;
end;

procedure TServerMethodDM.dwcrLoginBeforeRenderer(aSelf: TComponent);
begin
 TDWContextRules(aSelf).MasterHtml.LoadFromFile(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'www/templates/login.html'));
end;

procedure TServerMethodDM.dwcrLoginItemsmeuloginnameBeforeRendererContextItem(
  var ContextItemTag: string);
begin
 ContextItemTag := Format('<p id="mynamepan" idd="%d">%s</p>', [IDUser, IDUserName]);
end;

procedure TServerMethodDM.dwsCrudServerBeforeRenderer(aSelf: TComponent);
begin
 TDWServerContext(aSelf).BaseHeader.LoadFromFile(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'www/templates/master.html'));
 TDWServerContext(aSelf).BaseHeader.text := utf8decode(TDWServerContext(aSelf).BaseHeader.text);
end;

procedure TServerMethodDM.dwsCrudServerContextListindexAuthRequest(
  const Params: TDWParams; var Rejected: Boolean; var ResultError: string;
  var StatusCode: Integer; RequestHeader: TStringList);
Var
 vusername,
 vpassword  : String;
 vContar    : Integer;
 Function RejectURL : String;
 Var
  v404Error  : TStringList;
 Begin
  v404Error  := TStringList.Create;
  Try
   v404Error.LoadFromFile(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, Const404Page));
   Result := v404Error.Text;
  Finally
   v404Error.Free;
  End;
 End;
begin
 Rejected  := (Params.ItemsString['username'] = Nil) Or
              (Params.ItemsString['password'] = Nil);
 If Not Rejected Then
  Begin
   vusername := Lowercase(decodestrings(Params.ItemsString['username'].AsString));
   vpassword := Lowercase(decodestrings(Params.ItemsString['password'].AsString));
   FDQuery1.Close;
   FDQuery1.SQL.Clear;
   FDQuery1.SQL.Add('select count(*)contar from TB_USUARIO');
   FDQuery1.Open;
   vContar := FDQuery1.FindField('contar').AsInteger;
   If vContar = 0 Then
    Begin
     FDQuery1.Close;
     FDQuery1.SQL.Clear;
     FDQuery1.SQL.Add('select * from TB_USUARIO');
     FDQuery1.Open;
     FDQuery1.Insert;
     FDQuery1.FindField('NM_LOGIN').AsString := vusername;
     FDQuery1.FindField('DS_SENHA').AsString := vpassword;
     FDQuery1.Post;
     sqlLocalDBC.CommitRetaining;
    End;
   FDQuery1.Close;
   FDQuery1.SQL.Clear;
   FDQuery1.SQL.Add('select * from TB_USUARIO where NM_LOGIN = lower(:NM_LOGIN) and DS_SENHA = lower(:DS_SENHA)');
   Try
    FDQuery1.ParamByName('NM_LOGIN').AsString := Lowercase(vusername);
    FDQuery1.ParamByName('DS_SENHA').AsString := Lowercase(vpassword);
    FDQuery1.Open;
    IDUser     := FDQuery1.FindField('ID_PESSOA').AsInteger;
    IDUserName := FDQuery1.FindField('NM_LOGIN').AsString;
   Finally
    Rejected  := FDQuery1.EOF;
    FDQuery1.Close;
    If Rejected Then
     Begin
      ResultError := RejectURL;
      StatusCode  := 404;
     End;
   End;
  End
 Else
  Begin
   ResultError := RejectURL;
   StatusCode  := 404;
  End;
end;

Function TServerMethodDM.MyMenu: String;
Begin
 If (IDUser > 0) Then
  Result := Format('<li class="active"><a href=# onClick="newEmployee()"><i class="fa fa-address-book"></i> <span>Novo Empregado</span></a></li>'    + bl +
                   '<li class="active"><a href=# onClick="reloadDatatable(false)"><i class="fa fa-users"></i> <span>Lista de Empregados</span></a></li>' + bl +
                   '<li class="active"><a href="./login"><i class="fa fa-sign-out"></i> <span>Logout</span></a></li>', [Uppercase(IDUserName)])
 Else
  Result := '';
End;

procedure TServerMethodDM.sqlLocalDBCBeforeConnect(Sender: TObject);
Var
 vFileExists : String;
begin
 sqlLocalDBC.Params.Values['ColumnMetadataSupported'] := 'False';
 vFileExists := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'db/employee.db');
 sqlLocalDBC.Params.Values['Database'] := vFileExists;
end;

end.
