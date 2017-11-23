unit MainModule;

interface

uses
  uniGUIMainModule, SysUtils, Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Phys.IBBase,
  Data.DB, FireDAC.Comp.Client, uniGUIBaseClasses, uniGUIClasses, uniImageList,
  uRestPoolerDB, uRESTDWPoolerDB;

type
  TUniMainModule = class(TUniGUIMainModule)
    conConexao: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    img_32: TUniImageList;
    RESTConexao: TRESTDWDataBase;
    procedure RESTConexaoConnection(Sucess: Boolean; const Error: string);
  private
    { Private declarations }
  public
    { Public declarations }
    ID_EMPRESA: Integer;
    strResultadoTesteConexao: string;
    procedure TestaConexao;
  end;

function UniMainModule: TUniMainModule;

implementation

{$R *.dfm}

uses
  UniGUIVars, ServerModule, uniGUIApplication, System.IniFiles, IWSystem;

function UniMainModule: TUniMainModule;
begin
  Result := TUniMainModule(UniApplication.UniMainModule)
end;

procedure TUniMainModule.RESTConexaoConnection(Sucess: Boolean;
  const Error: string);
begin
  strResultadoTesteConexao := Error;
end;

procedure TUniMainModule.TestaConexao;
begin
  strResultadoTesteConexao := '';
  RESTConexao.Active := True;
end;

initialization
  RegisterMainModuleClass(TUniMainModule);
end.
