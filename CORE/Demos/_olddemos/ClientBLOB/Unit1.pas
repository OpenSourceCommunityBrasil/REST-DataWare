unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uRESTDWPoolerDB, Data.DB,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.DBCtrls, IdComponent,
  Vcl.Mask, Vcl.Buttons, uDWConstsData, uDWDataset;

type
  TForm5 = class(TForm)
    Label4: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    Label7: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    CheckBox1: TCheckBox;
    edPasswordDW: TEdit;
    Label6: TLabel;
    edUserNameDW: TEdit;
    Label8: TLabel;
    Label1: TLabel;
    Bevel2: TBevel;
    DataSource1: TDataSource;
    ProgressBar1: TProgressBar;
    Button1: TButton;
    DBNavigator1: TDBNavigator;
    Label2: TLabel;
    Label3: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBImage1: TDBImage;
    BitBtn1: TBitBtn;
    Label11: TLabel;
    DBText1: TDBText;
    RESTDWClientSQL1ID_PESSOA: TIntegerField;
    RESTDWClientSQL1NM_LOGIN: TStringField;
    RESTDWClientSQL1DS_SENHA: TStringField;
    RESTDWClientSQL1DS_FOTO: TBlobField;
    RESTDWClientSQL1ID_USUARIO: TIntegerField;
    RESTDWClientSQL1FL_ATIVO: TStringField;
    RESTDWClientSQL1DT_INCLUSAO: TSQLTimeStampField;
    RESTDWClientSQL1DT_ALTERACAO: TSQLTimeStampField;
    RESTDWClientSQL1CALCFIELD: TIntegerField;
    procedure Button1Click(Sender: TObject);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure BitBtn1Click(Sender: TObject);
    procedure RESTDWClientSQL1CalcFields(DataSet: TDataSet);
  private
    { Private declarations }
   FBytesToTransfer : Int64;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.BitBtn1Click(Sender: TObject);
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
 RESTDWClientSQL1.SQL.Add('SELECT * FROM TB_USUARIO WHERE ID_PESSOA = :ID_PESSOA or NM_LOGIN like upper(:NM_LOGIN)');
 RESTDWClientSQL1.ParamByName('ID_PESSOA').AsInteger := 0;
 RESTDWClientSQL1.ParamByName('NM_LOGIN').AsString := '%' + Inputbox('Pesquisa de dados', 'Digite o valor', '') + '%';
 RESTDWClientSQL1.Open;
end;

procedure TForm5.Button1Click(Sender: TObject);
begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := eHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(ePort.Text);
 RESTDWDataBase1.Login         := edUserNameDW.Text;
 RESTDWDataBase1.Password      := edPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 RESTDWDataBase1.Open;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.Open;
end;

procedure TForm5.RESTDWClientSQL1CalcFields(DataSet: TDataSet);
begin
 If RESTDWClientSQL1.Active Then
  RESTDWClientSQL1CALCFIELD.AsInteger := RESTDWClientSQL1.RecNo;
end;

procedure TForm5.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  If FBytesToTransfer = 0 Then // No Update File
   Exit;
  ProgressBar1.Position := AWorkCount;
end;

procedure TForm5.RESTDWDataBase1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
 FBytesToTransfer      := AWorkCountMax;
 ProgressBar1.Max      := FBytesToTransfer;
 ProgressBar1.Position := 0;
end;

procedure TForm5.RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
 ProgressBar1.Position := FBytesToTransfer;
 FBytesToTransfer      := 0;
end;

end.
