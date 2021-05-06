unit formMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uDWJSONObject, uLkJSON,
  DB, Grids, DBGrids, uRESTDWBase, uDWJSONTools, uDWConsts, idComponent,
  ExtCtrls, acPNG, DBClient, uRESTDWPoolerDB, JvMemoryDataset, ComCtrls,
  uDWConstsData;

type

  { TForm2 }

  TForm2 = class(TForm)
    eHost: TEdit;
    ePort: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    Label7: TLabel;
    edPasswordDW: TEdit;
    Label6: TLabel;
    edUserNameDW: TEdit;
    Label8: TLabel;
    Bevel2: TBevel;
    Label1: TLabel;
    Bevel3: TBevel;
    Label2: TLabel;
    DBGrid1: TDBGrid;
    mComando: TMemo;
    Button1: TButton;
    CheckBox1: TCheckBox;
    RESTDWDataBase1: TRESTDWDataBase;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DataSource1: TDataSource;
    Button2: TButton;
    ProgressBar1: TProgressBar;
    Button4: TButton;
    RESTDWClientSQL1EMP_NO: TSmallintField;
    RESTDWClientSQL1FIRST_NAME: TStringField;
    RESTDWClientSQL1LAST_NAME: TStringField;
    RESTDWClientSQL1PHONE_EXT: TStringField;
    RESTDWClientSQL1HIRE_DATE: TSQLTimeStampField;
    RESTDWClientSQL1DEPT_NO: TStringField;
    RESTDWClientSQL1JOB_CODE: TStringField;
    RESTDWClientSQL1JOB_GRADE: TSmallintField;
    RESTDWClientSQL1JOB_COUNTRY: TStringField;
    RESTDWClientSQL1SALARY: TFloatField;
    RESTDWClientSQL1FULL_NAME: TStringField;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RESTDWDataBase1WorkBegin(ASender: TObject;
      AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject;
      AWorkMode: TWorkMode);
    procedure Button4Click(Sender: TObject);
    procedure RESTDWClientSQL1AfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
   FBytesToTransfer : Int64;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := eHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(ePort.Text);
 RESTDWDataBase1.Login         := edUserNameDW.Text;
 RESTDWDataBase1.Password      := edPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 RESTDWDataBase1.Open;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add(mComando.Text);
 RESTDWClientSQL1.Open;
end;

procedure TForm2.Button2Click(Sender: TObject);
Var
 vError : String;
begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := eHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(ePort.Text);
 RESTDWDataBase1.Login         := edUserNameDW.Text;
 RESTDWDataBase1.Password      := edPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 RESTDWDataBase1.Open;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add(mComando.Text);
 If Not RESTDWClientSQL1.ExecSQL(vError) Then
  Application.MessageBox(PChar('Erro executando o comando ' + RESTDWClientSQL1.SQL.Text),
                         'Erro...', mb_iconerror + mb_ok)
 Else
  Application.MessageBox('Comando executado com sucesso...',
                         'Informação !!!', mb_iconinformation + mb_ok);
end;

procedure TForm2.RESTDWDataBase1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
 FBytesToTransfer      := AWorkCountMax;
 ProgressBar1.Max      := FBytesToTransfer;
 ProgressBar1.Position := 0;
end;

procedure TForm2.RESTDWDataBase1Work(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  If FBytesToTransfer = 0 Then // No Update File
   Exit;
  ProgressBar1.Position := AWorkCount;
end;

procedure TForm2.RESTDWDataBase1WorkEnd(ASender: TObject;
  AWorkMode: TWorkMode);
begin
 ProgressBar1.Position := FBytesToTransfer;
 FBytesToTransfer      := 0;
end;

procedure TForm2.Button4Click(Sender: TObject);
Var
 vError : String;
begin
 If Not RESTDWClientSQL1.ApplyUpdates(vError) Then
  MessageDlg(vError, mtError, [mbOK], 0);
end;

procedure TForm2.RESTDWClientSQL1AfterInsert(DataSet: TDataSet);
begin
// RESTDWClientSQL1HIRE_DATE.AsDateTime := Now;
end;

end.
