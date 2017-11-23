unit UDmLstTransportadora;

interface

uses
  SysUtils, Classes, UDmLstBase, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, ACBrSocket, ACBrCEP, ACBrBase, ACBrValidador,
  uDWConstsData, uRESTDWPoolerDB;

type
  TDmLstTransportadora = class(TDmLstBase)
    ACBrValidador1: TACBrValidador;
    ACBrCEP2: TACBrCEP;
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function DmLstTransportadora: TDmLstTransportadora;

var
  DmTransportadora: TDmLstTransportadora;

implementation

{$R *.dfm}

uses
  {UniGUIVars, uniGUIMainModule,} MainModule;

function DmLstTransportadora: TDmLstTransportadora;
begin
  //Result := TDmLstTransportadora(UniMainModule.GetModuleInstance(TDmLstTransportadora));
  if not Assigned(DmTransportadora) then
  begin
    Result := TDmLstTransportadora.Create(nil);
    DmTransportadora := Result;
  end
  else
  begin
    Result := DmTransportadora;
  end;

  with Result do
  begin
    Tabela := 'TRANSPORTADORA';
    CampoChave := 'ID';
    titulo := 'Transportadora';
    TabelaInc := 'TRANSPORTADORA';

    qryCadbase.UpdateTableName := Tabela;

    CarregaSql(Tabela, 1);
    CarregaSql(Tabela, 2);

    CampoEmpresa := '';
  end;
end;

//initialization
//  RegisterModuleClass(TDmLstTransportadora);

procedure TDmLstTransportadora.DataModuleDestroy(Sender: TObject);
begin
  inherited;
  DmTransportadora := nil;
end;

end.
