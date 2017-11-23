// Criada originalmente por : Gilberto Rocha da Silva
// Atualizada por : Alexandre Abade e Gilberto Rocha da Silva

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
     Vcl.Forms, uRestPoolerDB,URestPoolerDBMethod, FireDAC.Phys.FBDef,
     FireDAC.Phys.FB,         Web.WebReq, uConsts, uRestDriverFD;

type
{$METHODINFO ON}
  TServerMethods1 = class(TDataModule)
    FDGUIxWaitCursor1      : TFDGUIxWaitCursor;
    FDPhysIBDriverLink1    : TFDPhysIBDriverLink;
    FDStanStorageJSONLink1 : TFDStanStorageJSONLink;
    FDConnectionEMPLOYEE   : TFDConnection;
    RESTPoolerDB: TRESTPoolerDB;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    RESTDriverFD1: TRESTDriverFD;
    procedure FDConnectionEMPLOYEEBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
{$METHODINFO OFF}

Var
 UserName,
 Password : String;

implementation

{$R *.dfm}

uses System.StrUtils, System.Generics.Collections, uWebModuleMethod;

procedure TServerMethods1.DataModuleCreate(Sender: TObject);
Begin
 Inherited;
 UserName := vUsername;
 Password := vPassword;
End;

procedure TServerMethods1.FDConnectionEMPLOYEEBeforeConnect(Sender: TObject);
begin
 FDConnectionEMPLOYEE.Params.Clear;
 FDConnectionEMPLOYEE.Params.Add('DriverID=FB');
 FDConnectionEMPLOYEE.Params.Add('Database=127.0.0.1:' + ExtractFilePath(ParamSTR(0)) + '..\EMPLOYEE.FDB');
 FDConnectionEMPLOYEE.Params.Add('User_Name=sysdba');
 FDConnectionEMPLOYEE.Params.Add('password=masterkey');
 FDConnectionEMPLOYEE.UpdateOptions.CountUpdatedRecords := False;
end;

end.

