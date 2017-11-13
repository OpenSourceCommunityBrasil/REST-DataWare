unit UDmLstBaseMov;

interface

uses
  SysUtils, Classes, UDmLstBase, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uDWConstsData, uRESTDWPoolerDB;

type
  TDmLstBaseMov = class(TDmLstBase)
    dsCadItem: TDataSource;
    dsLstItem: TDataSource;
    qryCadItem: TRESTDWClientSQL;
    qryLstItem: TRESTDWClientSQL;
  private
    { Private declarations }
  public
    { Public declarations }
    CampoChaveItem, TabelaItem, TabelaItemInc: string;
    AutoIncItem: Boolean;

    procedure CarregaSql(Tabela: string; intTipo: Integer); override;
  end;

//function DmLstBaseMov: TDmLstBaseMov;

implementation

{$R *.dfm}

uses
  {UniGUIVars, uniGUIMainModule,} MainModule, USQL;

//function DmLstBaseMov: TDmLstBaseMov;
//begin
//  Result := TDmLstBaseMov(UniMainModule.GetModuleInstance(TDmLstBaseMov));
//end;

//initialization
//  RegisterModuleClass(TDmLstBaseMov);

{ TDmLstBaseMov }

procedure TDmLstBaseMov.CarregaSql(Tabela: string; intTipo: Integer);
begin
  inherited;

  if intTipo = 3 then
  begin
    qryCadItem.SQL.Clear;
    qryCadItem.SQL.Add(TSql.getSql(Tabela, intTipo));
  end;
  if intTipo = 4 then
  begin
    qryLstItem.SQL.Clear;
    qryLstItem.SQL.Add(TSql.getSql(Tabela, intTipo));
  end;
end;

end.
