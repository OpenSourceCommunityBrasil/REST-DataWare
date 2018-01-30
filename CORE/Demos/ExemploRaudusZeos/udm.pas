unit udm;

interface

uses
  SysUtils, Classes, FMTBcd, DB, Provider, DBClient,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection
  {DBXpress, SqlExpr}
  ;

type
  Tdm = class(TDataModule)
    sqlDb: TZConnection;
    ZQuery1: TZQuery;
    ZQuery2: TZQuery;
    ZQuery1DEPT_NO: TWideStringField;
    ZQuery1DEPARTMENT: TWideStringField;
    ZQuery2EMP_NO: TSmallintField;
    ZQuery2FIRST_NAME: TWideStringField;
    ZQuery2LAST_NAME: TWideStringField;
    ZQuery2PHONE_EXT: TWideStringField;
    ZQuery2HIRE_DATE: TDateTimeField;
    ZQuery2DEPT_NO: TWideStringField;
    ZQuery2SALARY: TFloatField;
    DataSource1: TDataSource;
    procedure DataModuleDestroy(Sender: TObject);
    procedure ZQuery1AfterScroll(DataSet: TDataSet);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{$R *.dfm}

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  {sqlDb.Connected :=true;
  ZQuery1.Active:=True;
  ZQuery2.Active:=True;
  }
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
 { ZQuery2.Active:=false;
  ZQuery1.Active:=false;
  sqlDb.Connected :=false;
}
end;

procedure Tdm.ZQuery1AfterScroll(DataSet: TDataSet);
begin
  ZQuery2.Close;
  ZQuery2.ParamByName('DEPT_NO').AsInteger :=  ZQuery1.FieldByName('DEPT_NO').AsInteger;
  ZQuery2.open;

end;

end.
