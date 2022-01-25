unit udm;

interface

uses
  SysUtils, Classes, FMTBcd, DB, Provider, DBClient,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection, uDWConstsData, uRESTDWPoolerDB, JvMemoryDataset,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client
  {DBXpress, SqlExpr}
  ;

type
  Tdm = class(TDataModule)
    DataSource1: TDataSource;
    RESTDWDataBase1: TRESTDWDataBase;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWClientSQL2: TRESTDWClientSQL;
    procedure RESTDWClientSQL1AfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{$R *.dfm}

procedure Tdm.RESTDWClientSQL1AfterScroll(DataSet: TDataSet);
begin
  RESTDWClientSQL2.Close;
  RESTDWClientSQL2.ParamByName('DEPT_NO').ASstring :=  RESTDWClientSQL1.FieldByName('DEPT_NO').AsString;
  RESTDWClientSQL2.open;

end;

end.
