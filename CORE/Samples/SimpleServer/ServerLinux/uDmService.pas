UNIT uDmService;

INTERFACE

USES
  SysUtils,
  Classes,
  SysTypes,
  UDWDatamodule,
  System.JSON,
  UDWJSONObject,
  {$IFDEF WINDOWS}
  Dialogs,
  RestDWServerFormU,
  {$ENDIF}
  ServerUtils,
  UDWConsts,
  FireDAC.Dapt,
  UDWConstsData,
  FireDAC.Phys.FBDef,
  FireDAC.UI.Intf,
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
  URestDWDriverFD, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet;

TYPE
  TServerMethodDM = CLASS(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    Server_FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDQuery1: TFDQuery;
    PROCEDURE ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: STRING; VAR Params: TDWParams; VAR Result: STRING);
    PROCEDURE ServerMethodDataModuleCreate(Sender: TObject);
    PROCEDURE Server_FDConnectionBeforeConnect(Sender: TObject);
    PROCEDURE ServerMethodDataModuleWelcomeMessage(Welcomemsg: STRING);
    PROCEDURE Server_FDConnectionError(ASender, AInitiator: TObject; VAR AException: Exception);
  PRIVATE
    { Private declarations }
    FUNCTION ConsultaBanco(VAR Params: TDWParams): STRING; OVERLOAD;
  PUBLIC
    { Public declarations }
  END;

VAR
  ServerMethodDM: TServerMethodDM;

IMPLEMENTATION


{$R *.dfm}

FUNCTION TServerMethodDM.ConsultaBanco(VAR Params: TDWParams): STRING;
VAR
  VSQL: STRING;
  JSONValue: TJSONValue;
  FdQuery: TFDQuery;
BEGIN
  IF Params.ItemsString['SQL'] <> NIL THEN
  BEGIN
    JSONValue          := UDWJSONObject.TJSONValue.Create;
    JSONValue.Encoding := GetEncoding(Encoding);
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
        {$IFDEF WINDOWS}
        JSONValue.LoadFromDataset('sql', FdQuery, RestDWForm.CbEncode.Checked);
        {$ELSE}
        JSONValue.LoadFromDataset('sql', FdQuery, true);
        {$ENDIF}
        Result := JSONValue.ToJSON;
      FINALLY
        JSONValue.Free;
        FdQuery.Free;
      END;
{$ENDIF}
    END;
  END;
END;

PROCEDURE TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
BEGIN
  Server_fdconnection.Connected:=true;
  {$IFDEF WINDOWS}
  RESTDWPoolerDB1.Active := RestDWForm.CbPoolerState.Checked;
  {$ELSE}
  RESTDWPoolerDB1.Active := True;
  {$ENDIF}
END;

PROCEDURE TServerMethodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: STRING; VAR Params: TDWParams; VAR Result: STRING);
VAR
  JSONObject: TJSONObject;
BEGIN
  JSONObject := TJSONObject.Create;
  CASE SendType OF
    SePOST:
      BEGIN
        IF UpperCase(Context) = UpperCase('ConsultaBanco') THEN
          Result := ConsultaBanco(Params)
        ELSE
        BEGIN
          JSONObject.AddPair(TJSONPair.Create('STATUS', 'NOK'));
          JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Método não encontrado'));
          Result := JSONObject.ToJSON;
        END;
      END;
  END;
  JSONObject.Free;
END;

PROCEDURE TServerMethodDM.ServerMethodDataModuleWelcomeMessage(Welcomemsg: STRING);
BEGIN
{$IFDEF WINDOWS}
// RestDWForm.EdBD.Text := Welcomemsg;
{$ENDIF}
END;

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
  {$IFDEF WINDOWS}
 database:= 'EMPLOYEE.FDB' //RestDWForm.EdBD.Text;

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
  TFDConnection(Sender).Params.Add('CharacterSet=NONE');
  TFDConnection(Sender).DriverName  := Driver_BD;
  TFDConnection(Sender).LoginPrompt := FALSE;
  // Server_FDConnection.Params.Add('CharacterSet=ISO8859_1');
  TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
  {$ELSE}
  database:= 'employee.fdb'; //RestDWForm.EdBD.Text;

    Driver_BD := 'FB';
    Servidor_BD := '192.168.2.40';

    Pasta_BD := ''; //IncludeTrailingPathDelimiter('C:\basedados\');
    Database := Pasta_BD + Database;

  Porta_BD   := '3050';
  Usuario_BD := 'SYSDBA';
  Senha_BD   := 'abrito';

  TFDConnection(Sender).Params.Clear;
  TFDConnection(Sender).Params.Add('DriverID=' + Driver_BD);
  TFDConnection(Sender).Params.Add('Server=' + Servidor_BD);
  TFDConnection(Sender).Params.Add('Port=' + Porta_BD);
  TFDConnection(Sender).Params.Add('Database=' + Database);
  TFDConnection(Sender).Params.Add('User_Name=' + Usuario_BD);
  TFDConnection(Sender).Params.Add('Password=' + Senha_BD);
  TFDConnection(Sender).Params.Add('Protocol=TCPIP');
  //TFDConnection(Sender).Params.Add('CharacterSet=ISO8859_1');
  TFDConnection(Sender).DriverName  := Driver_BD;
  TFDConnection(Sender).LoginPrompt := FALSE;
  with TFDConnection(Sender).FormatOptions do
  begin
    OwnMapRules := True;
    MapRules.Clear;
    with MapRules.Add do
    begin
    SourceDataType := dtAnsiString;
    TargetDataType := dtWideString;
    end;
  end;



  // Server_FDConnection.Params.Add('CharacterSet=ISO8859_1');
  TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
  {$ENDIF}
END;

PROCEDURE TServerMethodDM.Server_FDConnectionError(ASender, AInitiator: TObject; VAR AException: Exception);
BEGIN
  {$IFDEF WINDOWS}
  RestDWForm.memoResp.Lines.Add(AException.Message);
  {$ELSE}

  Writeln(AException.Message);
  {$ENDIF}
END;

END.
