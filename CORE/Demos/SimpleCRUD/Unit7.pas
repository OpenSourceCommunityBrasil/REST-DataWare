unit Unit7;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, uRESTDWPoolerDB, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uDWConstsData, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.DBCtrls, Vcl.Buttons, Vcl.Mask, Vcl.ExtDlgs;

type
  TForm7 = class(TForm)
    Label4: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    Label7: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    CheckBox1: TCheckBox;
    DataSource1: TDataSource;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    GroupBox1: TGroupBox;
    DBNavigator1: TDBNavigator;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    RESTDWClientSQL1ID: TIntegerField;
    RESTDWClientSQL1BLOBIMAGE: TBlobField;
    RESTDWClientSQL1DESCRICAO: TStringField;
    DBImage1: TDBImage;
    DBText1: TDBText;
    DBEdit1: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpeedButton3: TSpeedButton;
    OpenPictureDialog1: TOpenPictureDialog;
    SpeedButton4: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;

implementation

{$R *.dfm}

procedure TForm7.SpeedButton1Click(Sender: TObject);
Begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := EHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
 RESTDWDataBase1.Login         := EdUserNameDW.Text;
 RESTDWDataBase1.Password      := EdPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 RESTDWDataBase1.Open;
 DataSource1.DataSet     := RESTDWClientSQL1;
 RESTDWClientSQL1.Active := False;
 Try
  RESTDWClientSQL1.Open;
 Except
  On E: Exception Do
   Begin
    Raise Exception.Create('Erro ao executar a consulta: ' + sLineBreak + E.Message);
   End;
 End;
End;

procedure TForm7.SpeedButton2Click(Sender: TObject);
Var
 vError : String;
Begin
 If Not RESTDWClientSQL1.ApplyUpdates(vError) Then
  MessageDlg(vError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
End;

procedure TForm7.SpeedButton3Click(Sender: TObject);
begin
 If OpenPictureDialog1.Execute Then
  Begin
   If Not(RESTDWClientSQL1.State in [dsEdit, dsInsert]) Then
    RESTDWClientSQL1.Edit;
   TBlobField(RESTDWClientSQL1BLOBIMAGE).LoadFromFile(OpenPictureDialog1.FileName);
  End;
end;

procedure TForm7.SpeedButton4Click(Sender: TObject);
begin
 If Not(RESTDWClientSQL1.State in [dsEdit, dsInsert]) Then
  RESTDWClientSQL1.Edit;
 RESTDWClientSQL1BLOBIMAGE.Clear;
end;

end.
