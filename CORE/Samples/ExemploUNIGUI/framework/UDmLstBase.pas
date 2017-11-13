unit UDmLstBase;

interface

uses
  SysUtils, Classes, UDmBase, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, uDWConstsData,
  uRESTDWPoolerDB;

type
  TDmLstBase = class(TDmBase)
    MemtblLogCampos: TFDMemTable;
    MemtblLogCamposcampo: TStringField;
    MemtblLogCamposvalor: TStringField;
    MemtblLogCamposmensagem: TStringField;
    dsCadBase: TDataSource;
    dsLstBase: TDataSource;
    qryCadbase: TRESTDWClientSQL;
    qryLstbase: TRESTDWClientSQL;
  private
    { Private declarations }
  public
    { Public declarations }
    Tabela, CampoChave, titulo, TabelaInc, CampoEmpresa : string;
    AutoInc: Boolean;
    procedure CarregaSql(Tabela: string; intTipo: Integer); virtual;
  end;

//function DmLstBase: TDmLstBase;

implementation

{$R *.dfm}

uses
  {UniGUIVars, uniGUIMainModule,} MainModule, USQL;

//function DmLstBase: TDmLstBase;
//begin
//  Result := TDmLstBase(UniMainModule.GetModuleInstance(TDmLstBase));
//end;

{ TDmLstBase }

procedure TDmLstBase.CarregaSql(Tabela: string; intTipo: Integer);
begin
  if intTipo = 1 then
  begin
    qryCadbase.SQL.Clear;
    qryCadbase.SQL.Add(TSql.getSql(Tabela, intTipo));
  end;
  if intTipo = 2 then
  begin
    qryLstbase.SQL.Clear;
    qryLstbase.SQL.Add(TSql.getSql(Tabela, intTipo));
  end;
end;

//initialization
//  RegisterModuleClass(TDmLstBase);

end.
