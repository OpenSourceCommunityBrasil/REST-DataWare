unit uDmService;

interface

uses
  SysUtils, Classes, SysTypes, UDWDatamodule, System.JSON, UDWJSONObject,
  Dialogs, ServerUtils, UDWConsts, FireDAC.Dapt, UDWConstsData, FireDAC.Phys.FBDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.UI, FireDAC.Phys.IBBase, FireDAC.Stan.StorageJSON,
  RestDWServerFormU, URESTDWPoolerDB, URestDWDriverFD, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, frxClass, frxExportPDF;

type
  TServerMethodDM = class(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    Server_FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    frxReport1: TfrxReport;
    frxPDFExport1: TfrxPDFExport;
    procedure ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: string; var Params: TDWParams; var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
    procedure ServerMethodDataModuleWelcomeMessage(Welcomemsg: string);
    procedure Server_FDConnectionError(ASender, AInitiator: TObject; var AException: Exception);
    function DownloadFile(var Params: TDWParams): string; overload;
  private
    { Private declarations }
    function ConsultaBanco(var Params: TDWParams): string; overload;
    function GerarPDF: TmemoryStream;
  public
    { Public declarations }
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
function TServerMethodDM.GerarPDF: TmemoryStream;
begin

  result:= Tmemorystream.Create;
  try
  frxPDFExport1.Stream :=       result;
  frxPDFExport1.ShowDialog      := False;
  frxPDFExport1.ShowProgress    := False;
  frxPDFExport1.OverwritePrompt := False;

  frxReport1.PrepareReport(true);
  frxReport1.Export(frxPDFExport1);
  finally
    //frxPDFExport1.Stream := NIL;
  end;

end;

function TServerMethodDM.ConsultaBanco(var Params: TDWParams): string;
var
  VSQL: string;
  JSONValue: TJSONValue;
  FdQuery: TFDQuery;
begin
  if Params.ItemsString['SQL'] <> NIL then
  begin
    JSONValue := UDWJSONObject.TJSONValue.Create;
    JSONValue.Encoding := GetEncoding(Encoding);
    if Params.ItemsString['SQL'].Value <> '' then
    begin
      if Params.ItemsString['TESTPARAM'] <> NIL then
        Params.ItemsString['TESTPARAM'].SetValue('OK, OK');
      VSQL := Params.ItemsString['SQL'].Value;
      {$IFDEF FPC}
      {$ELSE}
      FdQuery := TFDQuery.Create(NIL);
      try
        FdQuery.Connection := Server_FDConnection;
        FdQuery.SQL.Add(VSQL);
        JSONValue.LoadFromDataset('sql', FdQuery, RestDWForm.CbEncode.Checked);
        Result := JSONValue.ToJSON;
      finally
        JSONValue.Free;
        FdQuery.Free;
      end;
      {$ENDIF}
    end;
  end;
end;

function TServerMethodDM.DownloadFile(var Params: TDWParams): string;
var
  JSONValue: TJSONValue;
  vFile: TMemoryStream;
  vFileExport: TStringStream;
begin
  if (Params.ItemsString['Relatorio'] <> Nil) then
  begin
    JSONValue := TJSONValue.Create;
    JSONValue.Encoding := Params.Encoding;
    JSONValue.ObjectValue := ovBlob;
      try
          //vFile := TMemoryStream.Create;
          try
            vFile:=GerarPDF;
            vFile.Position := 0;
          except

          end;
          JSONValue.LoadFromStream(vFile);
          Result := JSONValue.ToJSON;
      finally
        FreeAndNil(vFile);
        FreeAndNil(JSONValue);
      end;
  end;
end;

procedure TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
begin
  RESTDWPoolerDB1.Active := RestDWForm.CbPoolerState.Checked;
end;

procedure TServerMethodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: string; var Params: TDWParams; var Result: string);
var
  JSONObject: TJSONObject;
begin
  JSONObject := TJSONObject.Create;
  case SendType of
    SePOST:
      begin
        if UpperCase(Context) = UpperCase('ConsultaBanco') then
          Result := ConsultaBanco(Params)
        else if UpperCase(Context) = Uppercase('RELATORIOA') then
          Result := DownloadFile(Params)
        else
        begin
          JSONObject.AddPair(TJSONPair.Create('STATUS', 'NOK'));
          JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Método não encontrado'));
          Result := JSONObject.ToJSON;
        end;
      end;
  end;
  JSONObject.Free;
end;

procedure TServerMethodDM.ServerMethodDataModuleWelcomeMessage(Welcomemsg: string);
begin
  RestDWForm.EdBD.Text := Welcomemsg;
end;

procedure TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
var
  Driver_BD: string;
  Porta_BD: string;
  Servidor_BD: string;
  DataBase: string;
  Pasta_BD: string;
  Usuario_BD: string;
  Senha_BD: string;
begin
  DataBase := RestDWForm.EdBD.Text;

  Driver_BD := RestDWForm.CbDriver.Text;
  if RestDWForm.CkUsaURL.Checked then
  begin
    Servidor_BD := RestDWForm.EdURL.Text;
  end
  else
  begin
    Servidor_BD := RestDWForm.DatabaseIP;
  end;

  case RestDWForm.CbDriver.ItemIndex of
    0: // FireBird
      begin
        Pasta_BD := IncludeTrailingPathDelimiter(RestDWForm.EdPasta.Text);
        DataBase := RestDWForm.edBD.Text;
        DataBase := Pasta_BD + DataBase;
      end;
    1: // MSSQL
      begin
        DataBase := RestDWForm.EdBD.Text;
      end;
  end;

  Porta_BD := RestDWForm.EdPortaBD.Text;
  Usuario_BD := RestDWForm.EdUserNameBD.Text;
  Senha_BD := RestDWForm.EdPasswordBD.Text;

  TFDConnection(Sender).Params.Clear;
  TFDConnection(Sender).Params.Add('DriverID=' + Driver_BD);
  TFDConnection(Sender).Params.Add('Server=' + Servidor_BD);
  TFDConnection(Sender).Params.Add('Port=' + Porta_BD);
  TFDConnection(Sender).Params.Add('Database=' + DataBase);
  TFDConnection(Sender).Params.Add('User_Name=' + Usuario_BD);
  TFDConnection(Sender).Params.Add('Password=' + Senha_BD);
  TFDConnection(Sender).Params.Add('Protocol=TCPIP');
  TFDConnection(Sender).DriverName := Driver_BD;
  TFDConnection(Sender).LoginPrompt := FALSE;
  TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
end;

procedure TServerMethodDM.Server_FDConnectionError(ASender, AInitiator: TObject; var AException: Exception);
begin
  RestDWForm.memoResp.Lines.Add(AException.Message);
end;

end.

