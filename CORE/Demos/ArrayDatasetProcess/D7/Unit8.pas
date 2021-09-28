unit Unit8;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls,
  uRESTDWPoolerDB, StdCtrls, DB, Grids, DBGrids,
  uDWConstsData, uDWMassiveBuffer,
  uDWDataset, uDWAbout, jpeg;

type
  TfPrincipal = class(TForm)
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    Label7: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    CheckBox1: TCheckBox;
    chkhttps: TCheckBox;
    RESTDWDataBase1: TRESTDWDataBase;
    Image1: TImage;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Button1: TButton;
    Button2: TButton;
    Bevel2: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    rdwSQLStringTable: TRESTDWClientSQL;
    dsSQLStringTable: TDataSource;
    dsSQLEmployee: TDataSource;
    rdwSQLEmployee: TRESTDWClientSQL;
    DWMassiveCache1: TDWMassiveCache;
    rdwSQLEmployeeEMP_NO: TSmallintField;
    rdwSQLEmployeeFIRST_NAME: TStringField;
    rdwSQLEmployeeLAST_NAME: TStringField;
    rdwSQLEmployeePHONE_EXT: TStringField;
    rdwSQLEmployeeHIRE_DATE: TSQLTimeStampField;
    rdwSQLEmployeeDEPT_NO: TStringField;
    rdwSQLEmployeeJOB_CODE: TStringField;
    rdwSQLEmployeeJOB_GRADE: TSmallintField;
    rdwSQLEmployeeJOB_COUNTRY: TStringField;
    rdwSQLEmployeeSALARY: TFloatField;
    rdwSQLEmployeeFULL_NAME: TStringField;
    rdwSQLStringTableID: TStringField;
    rdwSQLStringTableDESC: TStringField;
    DWMassiveSQLCache1: TDWMassiveSQLCache;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.dfm}

procedure TfPrincipal.Button1Click(Sender: TObject);
Var
 vError        : Boolean;
 vMessageError : String;
begin
 DWMassiveCache1.Clear;
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := EHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
 RESTDWDataBase1.Login         := EdUserNameDW.Text;
 RESTDWDataBase1.Password      := EdPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 If chkhttps.Checked then
  RESTDWDataBase1.TypeRequest  := trHttps
 Else
  RESTDWDataBase1.TypeRequest  := trHttp;
 RESTDWDataBase1.Open;
 RESTDWDataBase1.OpenDatasets([rdwSQLStringTable, rdwSQLEmployee], vError, vMessageError);
 If vError Then
  Showmessage(vMessageError);
end;

procedure TfPrincipal.Button2Click(Sender: TObject);
Var
 vError        : Boolean;
 vMessageError : String;
begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := EHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
 RESTDWDataBase1.Login         := EdUserNameDW.Text;
 RESTDWDataBase1.Password      := EdPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 If chkhttps.Checked then
  RESTDWDataBase1.TypeRequest  := trHttps
 Else
  RESTDWDataBase1.TypeRequest  := trHttp;
 RESTDWDataBase1.Open;
 RESTDWDataBase1.ApplyUpdates(DWMassiveCache1, vError, vMessageError);
 If vError Then
  Showmessage(vMessageError);
end;

end.
