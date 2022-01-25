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
 Const404Page  = 'www\404.html';

TYPE
  TServerMethodDM = CLASS(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    RESTDWDriverZeos1: TRESTDWDriverZeos;
    dwsCrudServer: TDWServerContext;
    dwcrLogin: TDWContextRules;
    dwcrIndex: TDWContextRules;
    PROCEDURE ServerMethodDataModuleCreate(Sender: TObject);
    procedure ZConnection1BeforeConnect(Sender: TObject);
    procedure dwsCrudServerContextListindexAuthRequest(
      const Params: TDWParams; var Rejected: Boolean;
      var ResultError: String);
    procedure dwcrIndexItemscadModalRequestExecute(const Params: TDWParams;
      var ContentType, Result: String);
    procedure dwcrIndexItemsoperationRequestExecute(
      const Params: TDWParams; var ContentType, Result: String);
    procedure dwcrIndexItemsdwcbPaisesBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsdwcbCargosBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsdwsidemenuBeforeRendererContextItem(
      var ContextItemTag: String);
    procedure dwcrIndexItemsdatatableRequestExecute(
      const Params: TDWParams; var ContentType, Result: String);
  PRIVATE
    { Private declarations }
    function GetGenID(GenName: String): Integer;
  PUBLIC
    { Public declarations }
  END;

VAR
  ServerMethodDM: TServerMethodDM;

IMPLEMENTATION

uses uDWJSONTools;
{$R *.dfm}


Function SwapHTMLDateToDelphiDate(Value : String) : String;
Begin
 Result := Copy(Value, 1, Pos('-', Value) -1);
 Delete(Value, 1, Pos('-', Value));
 Result := Copy(Value, 1, Pos('-', Value) -1) + '/' + Result;
 Delete(Value, 1, Pos('-', Value));
 Result := Copy(Value, 1, Length(Value)) + '/' + Result;
End;

PROCEDURE TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
BEGIN
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

procedure TServerMethodDM.dwsCrudServerContextListindexAuthRequest(
  const Params: TDWParams; var Rejected: Boolean; var ResultError: String);
Var
 vusername,
 vpassword  : String;
 Function RejectURL : String;
 Var
  v404Error  : TStringList;
 Begin
  v404Error  := TStringList.Create;
  Try
   v404Error.LoadFromFile(RestDWForm.RESTServicePooler1.RootPath + Const404Page);
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
   vusername := Uppercase(decodestrings(Params.ItemsString['username'].AsString));
   vpassword := Uppercase(decodestrings(Params.ItemsString['password'].AsString));
   zQuery1.Close;
   zQuery1.SQL.Clear;
   zQuery1.SQL.Add('select * from TB_USUARIO where NM_LOGIN = :NM_LOGIN and DS_SENHA = :DS_SENHA');
   Try
    zQuery1.ParamByName('NM_LOGIN').AsString := vusername;
    zQuery1.ParamByName('DS_SENHA').AsString := vpassword;
    zQuery1.Open;
   Finally
    Rejected  := zQuery1.EOF;
    zQuery1.Close;
    If Rejected Then
     ResultError := RejectURL;
   End;
  End
 Else
  ResultError := RejectURL;
end;

procedure TServerMethodDM.dwcrIndexItemscadModalRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
Var
 JSONValue :  TJSONValue;
begin
 JSONValue            := TJSONValue.Create;
 Try
  zQuery1.Close;
  zQuery1.SQL.Clear;
  zQuery1.SQL.Add('select * from employee where emp_no = '+params.ItemsString['id'].AsString);

  Try
   zQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
   JSONValue.LoadFromDataset('', zQuery1, False,  JSONValue.JsonMode, 'yyyy-mm-dd', '.');
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

procedure TServerMethodDM.dwcrIndexItemsoperationRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
begin
 Result := 'true';
 zConnection1.StartTransaction;
 zQuery1.Close;
 zQuery1.SQL.Clear;
 If Params.ItemsString['operation'].AsString = 'edit' Then
  zQuery1.SQL.Add('update employee set FIRST_NAME = :FIRST_NAME, LAST_NAME = :LAST_NAME, ' +
                   'PHONE_EXT = :PHONE_EXT, HIRE_DATE = :HIRE_DATE, DEPT_NO = :DEPT_NO, ' +
                   'JOB_CODE  = :JOB_CODE, JOB_GRADE = :JOB_GRADE, JOB_COUNTRY = :JOB_COUNTRY, ' +
                   'SALARY = :SALARY ' +
                   'Where EMP_NO = ' + Params.ItemsString['id'].AsString)
 Else If Params.ItemsString['operation'].AsString = 'insert' Then
  zQuery1.SQL.Add('insert into employee (EMP_NO, FIRST_NAME, LAST_NAME, ' +
                                          'PHONE_EXT, HIRE_DATE, DEPT_NO, ' +
                                          'JOB_CODE, JOB_GRADE, JOB_COUNTRY, SALARY) ' +
                   'VALUES (gen_id(emp_no_gen, 1), :FIRST_NAME, :LAST_NAME, :PHONE_EXT, :HIRE_DATE, :DEPT_NO, :JOB_CODE, ' +
                           ':JOB_GRADE, :JOB_COUNTRY, :SALARY)')
 Else If Params.ItemsString['operation'].AsString = 'delete' Then
  zQuery1.SQL.Add('delete from employee Where EMP_NO = ' + Params.ItemsString['id'].AsString);
 Try
  If Params.ItemsString['operation'].AsString <> 'delete' Then
   Begin
    zQuery1.ParamByName('FIRST_NAME').AsString  := Params.ItemsString['FIRST_NAME'].AsString;
    zQuery1.ParamByName('LAST_NAME').AsString   := Params.ItemsString['LAST_NAME'].AsString;
    zQuery1.ParamByName('PHONE_EXT').AsString   := Params.ItemsString['PHONE_EXT'].AsString;
    zQuery1.ParamByName('DEPT_NO').AsString     := '600';
    zQuery1.ParamByName('JOB_CODE').AsString    := 'Vp';
    zQuery1.ParamByName('HIRE_DATE').AsDateTime := StrToDate(SwapHTMLDateToDelphiDate(Params.ItemsString['HIRE_DATE'].asstring));
    zQuery1.ParamByName('JOB_GRADE').AsString   := Params.ItemsString['JOB_GRADE'].AsString;
    zQuery1.ParamByName('JOB_COUNTRY').AsString := Params.ItemsString['JOB_COUNTRY'].AsString;
    zQuery1.ParamByName('SALARY').AsFloat       := Params.ItemsString['SALARY'].AsFloat;
   End;
  zQuery1.ExecSQL;
  zConnection1.Commit;
 Except
  On E : Exception Do
    Begin
     zConnection1.Rollback;
     Result := 'false';
    End;
 End;
end;

procedure TServerMethodDM.dwcrIndexItemsdwcbPaisesBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 zQuery1.Close;
 zQuery1.SQL.Clear;
 zQuery1.SQL.Add('select * from COUNTRY');
 zQuery1.Open;
 ContextItemTag := ContextItemTag + '<option value="" >Selecione seu país</option>';
 While Not zQuery1.EOF Do
  Begin
   ContextItemTag := ContextItemTag + Format('<option value="%s">%s</option>', [zQuery1.FindField('UF').AsString,
                                                                                zQuery1.FindField('COUNTRY').AsString]);
   zQuery1.Next;
  End;
 ContextItemTag := ContextItemTag + '</select>';
 zQuery1.Close;
end;

procedure TServerMethodDM.dwcrIndexItemsdwcbCargosBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 zQuery1.Close;
 zQuery1.SQL.Clear;
 zQuery1.SQL.Add('select * from JOB');
 zQuery1.Open;
 ContextItemTag := ContextItemTag + '<option value="" >Selecione Cargo</option>';
 While Not zQuery1.EOF Do
  Begin
   ContextItemTag := ContextItemTag + Format('<option value="%s">%s</option>', [zQuery1.FindField('JOB_GRADE').AsString,
                                                                                zQuery1.FindField('JOB_COUNTRY').AsString + ' - ' +
                                                                                zQuery1.FindField('JOB_TITLE').AsString]);
   zQuery1.Next;
  End;
 ContextItemTag := ContextItemTag + '</select>';
 zQuery1.Close;
end;

procedure TServerMethodDM.dwcrIndexItemsdwsidemenuBeforeRendererContextItem(
  var ContextItemTag: String);
begin
 ContextItemTag := ContextItemTag +
                   '<li class="active"><a href="javascript:window.location.reload(true)"><i class="fa fa-home"></i> <span>Home</span></a></li>'+
                   '<li class="active"><a href="javascript:void(0)" onClick="reloadDatatable()"><i class="fa fa-users"></i> <span>Lista de Empregado</span></a></li>' +
                   '<li class="active"><a href="./login"><i class="fa fa-sign-out"></i> <span>Logout</span></a></li>';
end;

procedure TServerMethodDM.dwcrIndexItemsdatatableRequestExecute(
  const Params: TDWParams; var ContentType, Result: String);
Var
 JSONValue :  TJSONValue;
begin
// ContentType := 'text/html';
// dwcrIndex.Items.MarkByName['datatable'].OnBeforeRendererContextItem(Result);
 JSONValue := TJSONValue.Create;
 Try
  zQuery1.Close;
  zQuery1.SQL.Clear;
  zQuery1.SQL.Add('select * from employee');
  Try
   zQuery1.Open;
   JSONValue.JsonMode := jmPureJSON;
   JSONValue.Encoding := Encoding;
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

END.
