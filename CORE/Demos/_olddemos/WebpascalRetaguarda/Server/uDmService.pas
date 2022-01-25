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
  FireDAC.Phys.MySQL, uRESTDWServerContext, FireDAC.Phys.PGDef, FireDAC.Phys.PG,
  uDWJSONInterface, System.MaskUtils;

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
    FDQuery1: TFDQuery;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    dwsCrudServer: TDWServerContext;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    dwcrIndex: TDWContextRules;
    dwcrMain: TDWContextRules;
    rOpenSecrets: TRESTDWClientSQL;
    seUsuarios: TDWServerEvents;
    Procedure ServerMethodDataModuleCreate(Sender: TObject);
    Procedure Server_FDConnectionBeforeConnect(Sender: TObject);
    procedure dwcrIndexBeforeRenderer(aSelf: TComponent);
    procedure dwcrMainBeforeRenderer(aSelf: TComponent);
    procedure ServerMethodDataModuleGetToken(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions : TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
    procedure ServerMethodDataModuleUserTokenAuth(Welcomemsg, AccessTag: string;
      Params: TDWParams; AuthOptions: TRDWAuthTokenParam;
      var ErrorCode: Integer; var ErrorMessage, TokenID: string;
      var Accept: Boolean);
    procedure seUsuariosEventsusuariosReplyEventByType(var Params: TDWParams;
      var Result: string; const RequestType: TRequestType;
      var StatusCode: Integer; RequestHeader: TStringList);
    procedure seUsuariosEventsloginReplyEventByType(var Params: TDWParams;
      var Result: string; const RequestType: TRequestType;
      var StatusCode: Integer; RequestHeader: TStringList);
  Private
    { Private declarations }
   IDUser     : Integer;
   IDUserName,
   vTokenID   : String;
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
 TDWContextRules(aSelf).MasterHtml.Text := LoadHTMLFile('.\www\index.html');
end;

procedure TServerMethodDM.dwcrMainBeforeRenderer(aSelf: TComponent);
begin
 TDWContextRules(aSelf).MasterHtml.Text :=  LoadHTMLFile('.\www\main.html');
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
 vMyCNPJ,
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
 vMyCNPJ  := Copy(vTokenID, InitStrPos, Pos(':', vTokenID) -1);
 Delete(vTokenID, InitStrPos, Pos(':', vTokenID));
 vMyPass    := Trim(vTokenID);
 Accept     := Not ((vMyClient = '') Or
                    (vMyPass   = ''));
 If Accept Then
  Begin
   FDQuery1.Close;
   FDQuery1.SQL.Clear;
   FDQuery1.SQL.Add('select * from USUARIOS where Upper(CNPJ) = Upper(:CNPJ) and Upper(EMAIL) = Upper(:EMAIL) and Upper(SENHA) = Upper(:SENHA)');
   Try
    FDQuery1.ParamByName('EMAIL').AsString := vMyClient;
    FDQuery1.ParamByName('CNPJ').AsString  := vMyCNPJ;
    FDQuery1.ParamByName('SENHA').AsString := vMyPass;
    FDQuery1.Open;
   Finally
    Accept     := Not(FDQuery1.EOF);
    If Not Accept Then
     Begin
      ErrorMessage := cInvalidAuth;
      ErrorCode  := 401;
     End
    Else
     TokenID := AuthOptions.GetToken(Format('{"id":"%s", "login":"%s"}', [FDQuery1.FindField('ID').AsString,
                                                                          FDQuery1.FindField('NOME').AsString]));
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
   FDQuery1.SQL.Add('select * from USUARIOS where id = :ID');
   Try
    FDQuery1.ParamByName('ID').AsInteger := vUserID;
    FDQuery1.Open;
    IDUser     := FDQuery1.FindField('id').AsInteger;
    IDUserName := FDQuery1.FindField('NOME').AsString;
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

procedure TServerMethodDM.seUsuariosEventsloginReplyEventByType(
  var Params: TDWParams; var Result: string; const RequestType: TRequestType;
  var StatusCode: Integer; RequestHeader: TStringList);
begin
 Result := '';
 Case RequestType Of
  rtGet    : Begin
              FDQuery1.Close;
              FDQuery1.SQL.Clear;
              FDQuery1.SQL.Add('Select * from USUARIOS where cnpj = :cnpj');
              Try
               FDQuery1.ParamByName('CNPJ').AsString  := FormatMaskText('00\.000\.000\/0000\-00;0;', Params.ItemsString['cnpj'].AsString);
               FDQuery1.Open;
               If Not FDQuery1.EOF Then
                Result := Format('{"nome":"%s"}', [FDQuery1.FindField('nome').AsString])
               Else
                Raise Exception.Create('CNPJ Não encontrado...');
              Except
               On E : Exception Do
                Begin
                 Raise Exception.Create('CNPJ Não encontrado...');
                End;
              End;
             End;
  End;
end;

procedure TServerMethodDM.seUsuariosEventsusuariosReplyEventByType(
  var Params: TDWParams; var Result: string; const RequestType: TRequestType;
  var StatusCode: Integer; RequestHeader: TStringList);
Var
 JSONValue :  TJSONValue;
 vJsonOBJ  : TDWJSONObject;
begin
 Case RequestType Of
  rtGet    : Begin
              JSONValue := TJSONValue.Create;
              Try
               FDQuery1.Close;
               FDQuery1.SQL.Clear;
               FDQuery1.SQL.Add('select * from USUARIOS');
               Try
                FDQuery1.Open;
                JSONValue.JsonMode := jmPureJSON;
                JSONValue.Encoding := Encoding;
                JSONValue.LoadFromDataset( '', FDQuery1, False,  JSONValue.JsonMode, 'dd/mm/yyyy', '.', False, True);
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
             End;
  rtPost   : Begin
              FDQuery1.Close;
              FDQuery1.SQL.Clear;
              FDQuery1.SQL.Add('Select * from USUARIOS where id is null ');
              Try
               FDQuery1.Open;
               FDQuery1.Insert;
               vJsonOBJ      := TDWJSONObject.Create(Params.ItemsString['undefined'].Value);
               FDQuery1.FindField('ID').AsInteger   := 0;
               FDQuery1.FindField('NOME').AsString  := vJsonOBJ.PairByName['nome'].Value;
               FDQuery1.FindField('EMAIL').AsString := vJsonOBJ.PairByName['email'].Value;
               FDQuery1.Post;
               FDQuery1.Connection.CommitRetaining;
               Result := Format('{"result":"%s"}', ['Cadastrado com sucesso']);
              Except
               On E : Exception Do
                Begin
                 Result := Format('{"Error":"%s"}', [E.Message]);
                End;
              End;
              FreeAndNil(vJsonOBJ);
             End;
  rtPut    : Begin
              FDQuery1.Close;
              FDQuery1.SQL.Clear;
              FDQuery1.SQL.Add('Select * from USUARIOS where id = ' + Params.itemsstring['id'].Value);
              vJsonOBJ      := TDWJSONObject.Create(Params.ItemsString['undefined'].Value);
              Try
               FDQuery1.Open;
               FDQuery1.Edit;
               FDQuery1.FindField('NOME').AsString  := vJsonOBJ.PairByName['nome'].Value;
               FDQuery1.FindField('EMAIL').AsString := vJsonOBJ.PairByName['email'].Value;
               FDQuery1.Post;
               FDQuery1.Connection.CommitRetaining;
               Result := Format('{"result":"%s"}', ['Editado com sucesso']);
              Except
               On E : Exception Do
                Begin
                 Result := Format('{"Error":"%s"}', [E.Message]);
                End;
              End;
              FreeAndNil(vJsonOBJ);
             End;
  rtDelete : Begin
              FDQuery1.Close;
              FDQuery1.SQL.Clear;
              FDQuery1.SQL.Add('delete from USUARIOS where id = ' + Params.itemsstring['id'].Value);
              Try
               FDQuery1.ExecSQL;
               Result := Format('{"result":"%s"}', ['deletado com sucesso']);
              Except
               On E : Exception Do
                Begin
                 Result := Format('{"Error":"%s"}', [E.Message]);
                End;
              End;
             End;
 End;
end;

End.
