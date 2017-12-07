unit Unit9;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, uRESTDWPoolerDB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDWConstsData, Vcl.Grids, Vcl.DBGrids, uDWMassiveBuffer, Vcl.DBCtrls;

type
  TForm9 = class(TForm)
    Label7: TLabel;
    Bevel1: TBevel;
    Label4: TLabel;
    eHost: TEdit;
    Label8: TLabel;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    Label6: TLabel;
    ePort: TEdit;
    Label5: TLabel;
    CheckBox1: TCheckBox;
    Image1: TImage;
    Button1: TButton;
    Button4: TButton;
    RESTDWDataBase1: TRESTDWDataBase;
    dwSQLEmployee: TRESTDWClientSQL;
    dwSQLEmployeeEMP_NO: TSmallintField;
    dwSQLEmployeeFULL_NAME: TStringField;
    dwSQLVendas: TRESTDWClientSQL;
    dwSQLItems: TRESTDWClientSQL;
    dsEmployee: TDataSource;
    dsItems: TDataSource;
    dsVendas: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DWMassiveCache1: TDWMassiveCache;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    dwSQLItemsID_ITEMS: TSmallintField;
    dwSQLItemsID_VENDA: TIntegerField;
    dwSQLItemsPRODUTO: TStringField;
    dwSQLItemsVALOR: TFloatField;
    dwSQLVendasID_VENDA: TIntegerField;
    dwSQLVendasEMP_NO: TSmallintField;
    dwSQLVendasDATA: TSQLTimeStampField;
    dwSQLVendasTOTAL: TFloatField;
    dwSQLVendasEMPLOYEE: TStringField;
    procedure Button1Click(Sender: TObject);
    procedure dwSQLVendasAfterInsert(DataSet: TDataSet);
    procedure Button4Click(Sender: TObject);
    procedure dwSQLItemsAfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

{$R *.dfm}

procedure TForm9.Button1Click(Sender: TObject);
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
 RESTDWDataBase1.Open;
 RESTDWDataBase1.OpenDatasets([dwSQLEmployee, dwSQLVendas], vError, vMessageError);
 If vError Then
  Showmessage(vMessageError);
end;

procedure TForm9.Button4Click(Sender: TObject);
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
 RESTDWDataBase1.Open;
 RESTDWDataBase1.ApplyUpdates(DWMassiveCache1, vError, vMessageError);
 If vError Then
  Showmessage(vMessageError);
end;

procedure TForm9.dwSQLItemsAfterInsert(DataSet: TDataSet);
begin
 dwSQLItemsID_ITEMS.AsInteger     := -1;
 dwSQLItemsVALOR.AsCurrency := 0;
end;

procedure TForm9.dwSQLVendasAfterInsert(DataSet: TDataSet);
begin
 dwSQLVendasDATA.AsDateTime  := Date;
 dwSQLVendasTOTAL.AsCurrency := 0;
 dwSQLVendasID_VENDA.AsInteger     := -1;
end;

end.
