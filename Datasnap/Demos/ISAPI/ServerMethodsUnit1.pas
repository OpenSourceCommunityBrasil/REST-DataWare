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
     WebModuleUnit1,          TypInfo,                  uRestPoolerDB,      uConsts,
     URestPoolerDBMethod, uRestDriverFD;

type
{$METHODINFO ON}
  TServerMethods1 = class(TDataModule)
    FDGUIxWaitCursor1      : TFDGUIxWaitCursor;
    FDPhysIBDriverLink1    : TFDPhysIBDriverLink;
    FDStanStorageJSONLink1 : TFDStanStorageJSONLink;
    FDConnectionEMPLOYEE   : TFDConnection;
    RESTPoolerDB: TRESTPoolerDB;
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

uses System.StrUtils, System.Generics.Collections;

procedure TServerMethods1.DataModuleCreate(Sender: TObject);
begin
 UserName := vUsername;
 Password := vPassword;
end;

procedure TServerMethods1.FDConnectionEMPLOYEEBeforeConnect(Sender: TObject);
begin
 FDConnectionEMPLOYEE.Params.Clear;
 FDConnectionEMPLOYEE.Params.Add('DriverID=IB');
 FDConnectionEMPLOYEE.Params.Add('Database=localhost:' + ExtractFilePath(ParamSTR(0)) + 'EMPLOYEE.GDB');
 FDConnectionEMPLOYEE.Params.Add('User_Name=sysdba');
 FDConnectionEMPLOYEE.Params.Add('password=masterkey');
 FDConnectionEMPLOYEE.UpdateOptions.CountUpdatedRecords := False;
end;

end.

