unit Unit8;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  uRESTDWPoolerDB, Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uDWConstsData;

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
    rdwSQLStringTableID: TStringField;
    rdwSQLStringTableDESC: TStringField;
    dsSQLStringTable: TDataSource;
    dsSQLEmployee: TDataSource;
    rdwSQLEmployee: TRESTDWClientSQL;
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
 RESTDWDataBase1.OpenDatasets([rdwSQLStringTable, rdwSQLEmployee], vError, vMessageError);
 If vError Then
  Showmessage(vMessageError);
end;

procedure TfPrincipal.Button2Click(Sender: TObject);
Var
 vError        : Boolean;
 vMessageError : String;
begin
 RESTDWDataBase1.ApplyUpdates([rdwSQLStringTable, rdwSQLEmployee], vError, vMessageError);
 If vError Then
  Showmessage(vMessageError);
end;

end.
