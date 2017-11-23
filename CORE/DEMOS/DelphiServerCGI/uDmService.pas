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
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  uDWConsts,
  uConsts;

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
    PROCEDURE ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: STRING; VAR Params: TDWParams; VAR Result: STRING);
    PROCEDURE ServerMethodDataModuleCreate(Sender: TObject);
    PROCEDURE Server_FDConnectionBeforeConnect(Sender: TObject);
    procedure ServerMethodDataModuleMassiveProcess(
      var MassiveDataset: TMassiveDatasetBuffer; var Ignore: Boolean);
  PRIVATE
    { Private declarations }
    FUNCTION ConsultaBanco(VAR Params: TDWParams): STRING; OVERLOAD;
  PUBLIC
    { Public declarations }
  END;

VAR
  ServerMethodDM: TServerMethodDM;

IMPLEMENTATION

{%CLASSGROUP 'Vcl.Controls.TControl'}
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
        JSONValue.LoadFromDataset('sql', FdQuery, EncodedData);
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
  RESTDWPoolerDB1.Active := ActivePooler;
END;

procedure TServerMethodDM.ServerMethodDataModuleMassiveProcess(
  var MassiveDataset: TMassiveDatasetBuffer; var Ignore: Boolean);
begin
{ //Esse código é para manipular o evento nao permitindo que sejam alteradas por massive outras
  //tabelas diferentes de employee e se você alterar o campo last_name no client ele substitui o valor
  //pelo valor setado abaixo
 Ignore := (MassiveDataset.MassiveMode in [mmInsert, mmUpdate, mmDelete]) and
           (lowercase(MassiveDataset.TableName) <> 'employee');
 If Not Ignore Then
  Begin
   If MassiveDataset.MassiveMode = mmUpdate Then
    If MassiveDataset.Fields.FieldByName('last_name') <> Nil Then
     MassiveDataset.Fields.FieldByName('last_name').Value := 'Server Alter';
  End;
 }
end;

PROCEDURE TServerMethodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: STRING; VAR Params: TDWParams; VAR Result: STRING);
VAR
  JSONObject: TJSONObject;
BEGIN
  JSONObject := TJSONObject.Create;
  CASE SendType OF
    SePOST:
      BEGIN
        IF UpperCase(Context) = UpperCase('EMPLOYEE') THEN
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

PROCEDURE TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
BEGIN
  TFDConnection(Sender).Params.Clear;
  TFDConnection(Sender).Params.Add('DriverID=FB');
  TFDConnection(Sender).Params.Add('Server=' + Servidor);
  TFDConnection(Sender).Params.Add('Port=' + IntToStr(Porta_BD));
  TFDConnection(Sender).Params.Add('Database=' + pasta + Database);
  TFDConnection(Sender).Params.Add('User_Name=' + Usuario_BD);
  TFDConnection(Sender).Params.Add('Password=' + Senha_BD);
  TFDConnection(Sender).Params.Add('Protocol=TCPIP');
  TFDConnection(Sender).DriverName  := 'FB';
  TFDConnection(Sender).LoginPrompt := FALSE;
  TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
END;

END.
