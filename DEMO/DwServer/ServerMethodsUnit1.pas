// Para Funcionar o Servidor é necessário que todos os Métodos declarados em PUBLIC sejam
//adicionados em seus Projetos.
//Gilberto Rocha da Silva

unit ServerMethodsUnit1;

interface

uses System.SysUtils,         System.Classes,           Datasnap.DSServer,  Datasnap.DSAuth,
     FireDAC.Stan.Intf,       FireDAC.Stan.Option,      FireDAC.Stan.Param,
     FireDAC.Stan.Error,      FireDAC.DatS,             FireDAC.Phys.Intf,  FireDAC.DApt.Intf,
     FireDAC.Stan.Async,      FireDAC.DApt,             FireDAC.UI.Intf,    FireDAC.VCLUI.Wait,
     FireDAC.Stan.Def,        FireDAC.Stan.Pool,        FireDAC.Phys,       Data.DB,
     FireDAC.Comp.Client,     FireDAC.Phys.IBBase,      FireDAC.Phys.IB,    FireDAC.Comp.UI,
     FireDAC.Comp.DataSet,    Data.FireDACJSONReflect,  System.JSON,
     FireDAC.Stan.StorageBin, FireDAC.Stan.StorageJSON, FireDAC.Phys.IBDef,
     WebModuleUnit1,          Vcl.Dialogs,              TypInfo,
     IniFiles,  Vcl.Forms,    uRestPoolerDB, URestPoolerDBMethod, FireDAC.Phys.FBDef, FireDAC.Phys.FB,
     uRestDriverFD;

type
{$METHODINFO ON}
  TServerMethods1 = class(TDataModule)
    FDGUIxWaitCursor1      : TFDGUIxWaitCursor;
    FDStanStorageJSONLink1 : TFDStanStorageJSONLink;
    Server_FDConnection: TFDConnection;
    RESTPoolerDB: TRESTPoolerDB;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    RESTDriverFD1: TRESTDriverFD;
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
{$METHODINFO OFF}

Var
 UserName,
 Password      : String;
 vDatabaseName : String;


implementation

{$R *.dfm}

uses System.StrUtils, System.Generics.Collections, RestDWServerFormU;

procedure TServerMethods1.DataModuleCreate(Sender: TObject);
begin
 UserName := RestDWForm.Username;
 Password := RestDWForm.Password;
 RESTPoolerDB.Active := RestDWForm.cbPoolerState.Checked;
end;

procedure TServerMethods1.Server_FDConnectionBeforeConnect(Sender: TObject);
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
 vDatabaseName := pasta + database;
 TFDConnection(Sender).Params.Clear;
 TFDConnection(Sender).Params.Add('DriverID=FB');
 TFDConnection(Sender).Params.Add('Server='    + Servidor);
 TFDConnection(Sender).Params.Add('Port='      + porta_BD);
 TFDConnection(Sender).Params.Add('Database='  + vDatabaseName);
 TFDConnection(Sender).Params.Add('User_Name=' + usuario_BD);
 TFDConnection(Sender).Params.Add('Password='  + senha_BD);
 TFDConnection(Sender).Params.Add('Protocol=TCPIP');
 //Server_FDConnection.Params.Add('CharacterSet=ISO8859_1');
 TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
end;

end.

