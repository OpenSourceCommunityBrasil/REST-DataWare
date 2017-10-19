unit Unit1;

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uRESTDWPoolerDB, DB,
  ExtCtrls, ComCtrls, DBCtrls, MaskEdit, Buttons, IdComponent;

type

  { TForm5 }

  TForm5 = class(TForm)
    BitBtn1: TBitBtn;
    DBImage1: TDBImage;
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
    RESTDWClientSQL1ID_PESSOA: TIntegerField;
    RESTDWClientSQL1NM_LOGIN: TStringField;
    RESTDWClientSQL1DS_SENHA: TStringField;
    RESTDWClientSQL1DS_FOTO: TBlobField;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  private
    { Private declarations }
   FBytesToTransfer : Int64;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

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
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add('SELECT * FROM TB_USUARIO');
 RESTDWClientSQL1.Open;
end;

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
