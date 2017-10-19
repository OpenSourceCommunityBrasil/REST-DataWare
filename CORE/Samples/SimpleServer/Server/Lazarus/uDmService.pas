unit uDmService;

interface

uses
  SysUtils, Classes, IBConnection, sqldb, SysTypes, uDWDatamodule,
  uDWJSONObject, Dialogs, ServerUtils, uDWConsts, uDWConstsData,
  RestDWServerFormU, uRESTDWPoolerDB, uRestDWLazDriver;


type

  { TServerMethodDM }

  TServerMethodDM = class(TServerMethodDataModule)
    RESTDWDriverFD1: TRESTDWLazDriver;
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    Server_FDConnection: TIBConnection;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleWelcomeMessage(Welcomemsg: String);
    procedure ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
      Context: string; var Params: TDWParams; var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
  private
    { Private declarations }
   Function ConsultaBanco(Var Params : TDWParams) : String;Overload;
  public
    { Public declarations }
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.lfm}

Function TServerMethodDM.ConsultaBanco(Var Params : TDWParams) : String;
Var
 vSQL      : String;
 JSONValue : TJSONValue;
 fdQuery   : TSQLQuery;
Begin
 If Params.ItemsString['SQL'] <> Nil Then
  Begin
   JSONValue          := TJSONValue.Create;
   If Params.ItemsString['SQL'].value <> '' Then
    Begin
     If Params.ItemsString['TESTPARAM'] <> Nil Then
      Params.ItemsString['TESTPARAM'].SetValue('OK, OK');
     vSQL      := Params.ItemsString['SQL'].value;
     fdQuery   := TSQLQuery.Create(Nil);
     Try
      fdQuery.DataBase := Server_FDConnection;
      fdQuery.SQL.Add(vSQL);
      JSONValue.LoadFromDataset('sql', fdQuery, RestDWForm.cbEncode.Checked);
      Result             := JSONValue.ToJSON;
     Finally
      JSONValue.Free;
      fdQuery.Free;
     End;
    End;
  End;
End;

procedure TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
begin
 RESTDWPoolerDB1.Active := RestDWForm.cbPoolerState.Checked;
end;

procedure TServerMethodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent;
  Context: string; var Params: TDWParams; var Result: string);
Begin
 Case SendType Of
  sePOST   :
   Begin
    If UpperCase(Context) = Uppercase('ConsultaBanco') Then
     Result := ConsultaBanco(Params)
    Else
     Result := '{(''STATUS'',   ''NOK''), (''MENSAGEM'', ''Método não encontrado'')}';
   End;
 End;
End;

procedure TServerMethodDM.DataModuleWelcomeMessage(Welcomemsg: String);
begin
 RestDWForm.edBD.Text := Welcomemsg;
end;

procedure TServerMethodDM.Server_FDConnectionBeforeConnect(Sender: TObject);
Var
 porta_BD,
 servidor,
 database,
 pasta,
 usuario_BD,
 senha_BD      : String;
Begin
 servidor      := RestDWForm.DatabaseIP;
 database      := RestDWForm.edBD.Text;
 pasta         := IncludeTrailingPathDelimiter(RestDWForm.edPasta.Text);
 porta_BD      := RestDWForm.edPortaBD.Text;
 usuario_BD    := RestDWForm.edUserNameBD.Text;
 senha_BD      := RestDWForm.edPasswordBD.Text;
 RestDWForm.DatabaseName := pasta + database;
 TIBConnection(Sender).HostName     := Servidor;
 TIBConnection(Sender).DatabaseName := RestDWForm.DatabaseName;
 TIBConnection(Sender).UserName     := usuario_BD;
 TIBConnection(Sender).Password     := senha_BD;
end;

end.
