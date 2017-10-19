unit srvModBaseDados;

interface

uses
  System.SysUtils,         System.Classes,           Datasnap.DSServer,  Datasnap.DSAuth,
     FireDAC.Stan.Intf,       FireDAC.Stan.Option,      FireDAC.Stan.Param,
     FireDAC.Stan.Error,      FireDAC.DatS,             FireDAC.Phys.Intf,  FireDAC.DApt.Intf,
     FireDAC.Stan.Async,      FireDAC.DApt,             FireDAC.UI.Intf,    FireDAC.VCLUI.Wait,
     FireDAC.Stan.Def,        FireDAC.Stan.Pool,        FireDAC.Phys,       Data.DB,
     FireDAC.Comp.Client,     FireDAC.Phys.IBBase,      FireDAC.Phys.IB,    FireDAC.Comp.UI,
     FireDAC.Comp.DataSet,    Data.FireDACJSONReflect,  System.JSON,
     FireDAC.Stan.StorageBin, FireDAC.Stan.StorageJSON, FireDAC.Phys.IBDef,
     Vcl.Dialogs,        Vcl.Forms,System.TypInfo,
     FireDAC.Phys.PG, FireDAC.Phys.PGDef, Datasnap.Provider, Datasnap.DBClient,
     uRestPoolerDB, URestPoolerDBMethod, FireDAC.Phys.FB, FireDAC.Phys.FBDef, uConsts;

type
{$METHODINFO ON}
  TDSServerModuleBaseDados = class(TDataModule)
    RESTPoolerDB: TRESTPoolerDB;
    Server_FDConnection: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
{$METHODINFO OFF}
var
  DSServerModuleBaseDados: TDSServerModuleBaseDados;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses Server.Containner;

{$R *.dfm}

{ TDSServerModuleBaseDados }

procedure TDSServerModuleBaseDados.Server_FDConnectionBeforeConnect(
  Sender: TObject);
begin
 TFDConnection(Sender).Params.Clear;
 TFDConnection(Sender).Params.Add('DriverID=FB');
 TFDConnection(Sender).Params.Add('Server='    + Servidor);
 TFDConnection(Sender).Params.Add('Port='      + IntToStr(porta_BD));
 TFDConnection(Sender).Params.Add('Database='  + pasta + database);
 TFDConnection(Sender).Params.Add('User_Name=' + usuario_BD);
 TFDConnection(Sender).Params.Add('Password='  + senha_BD);
 TFDConnection(Sender).Params.Add('Protocol=TCPIP');
 //Server_FDConnection.Params.Add('CharacterSet=ISO8859_1');
 TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
end;

End.
