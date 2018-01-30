UNIT uDmService;

INTERFACE

USES
  SysUtils,
  Classes,
  SysTypes,
  UDWDatamodule,
  System.JSON,
  UDWJSONObject,
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
  URestDWDriverFD,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL, FireDAC.FMXUI.Wait;

TYPE
  TServerMethodDM = CLASS(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    Server_FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
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

uses
  UnGeral;

{%CLASSGROUP 'FMX.Controls.TControl'}
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

      FdQuery := TFDQuery.Create(NIL);
      TRY
        FdQuery.Connection := Server_FDConnection;
        FdQuery.SQL.Add(VSQL);
        JSONValue.LoadFromDataset('sql', FdQuery, FrmGeral.CbEncode.isChecked);
        Result := JSONValue.ToJSON;
      FINALLY
        JSONValue.Free;
        FdQuery.Free;
      END;
    END;
  END;
END;

PROCEDURE TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
BEGIN
  RESTDWPoolerDB1.Active := FrmGeral.CbPoolerState.IsChecked;
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
  FrmGeral.EdBD.Text := Welcomemsg;
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
 database:= FrmGeral.EdBD.Text;

   Servidor_BD := FrmGeral.edIP.text;



  Porta_BD   := FrmGeral.EdPortaBD.Text;
  Usuario_BD := FrmGeral.EdUserNameBD.Text;
  Senha_BD   := FrmGeral.EdPasswordBD.Text;

  TFDConnection(Sender).Params.Clear;
  TFDConnection(Sender).Params.Add('DriverID=FB');
  TFDConnection(Sender).Params.Add('Server=' + Servidor_BD);
  TFDConnection(Sender).Params.Add('Port=' + Porta_BD);
  TFDConnection(Sender).Params.Add('Database=' + Database);
  TFDConnection(Sender).Params.Add('User_Name=' + Usuario_BD);
  TFDConnection(Sender).Params.Add('Password=' + Senha_BD);
  TFDConnection(Sender).Params.Add('Protocol=TCPIP');
  TFDConnection(Sender).DriverName  := 'FB'; //Driver_BD;
  TFDConnection(Sender).LoginPrompt := FALSE;
  // Server_FDConnection.Params.Add('CharacterSet=ISO8859_1');
  TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
END;

PROCEDURE TServerMethodDM.Server_FDConnectionError(ASender, AInitiator: TObject; VAR AException: Exception);
BEGIN
  FrmGeral.memoResp.Lines.Add(AException.Message);
END;

END.
