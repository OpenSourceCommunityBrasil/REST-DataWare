unit Unit6;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, uRESTDWPoolerDB, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.DBCtrls, Vcl.ExtDlgs, uDWConstsData;

type
  TForm6 = class(TForm)
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
    DBImage1: TDBImage;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Bevel2: TBevel;
    DBNavigator1: TDBNavigator;
    RESTDWClientSQL1ID: TIntegerField;
    RESTDWClientSQL1BLOBIMAGE: TBlobField;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

procedure TForm6.Button1Click(Sender: TObject);
begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := EHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
 RESTDWDataBase1.Login         := EdUserNameDW.Text;
 RESTDWDataBase1.Password      := EdPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 RESTDWDataBase1.Open;
 RESTDWClientSQL1.Active       := False;
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add('select * from IMAGELIST');
 RESTDWClientSQL1.Active       := True;
end;

procedure TForm6.Button2Click(Sender: TObject);
Var
 vError : String;
begin
 If OpenPictureDialog1.Execute Then
  Begin
   RESTDWDataBase1.Close;
   RESTDWDataBase1.PoolerService := EHost.Text;
   RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
   RESTDWDataBase1.Login         := EdUserNameDW.Text;
   RESTDWDataBase1.Password      := EdPasswordDW.Text;
   RESTDWDataBase1.Compression   := CheckBox1.Checked;
   RESTDWDataBase1.Open;
   RESTDWClientSQL1.Active       := False;
   RESTDWClientSQL1.SQL.Clear;
   RESTDWClientSQL1.SQL.Add('Insert into IMAGELIST (BLOBIMAGE) values (:img)');
   RESTDWClientSQL1.ParamByName('img').LoadFromFile(OpenPictureDialog1.FileName, ftBlob);
   If Not RESTDWClientSQL1.ExecSQL(vError) Then
    Showmessage(vError)
   Else
    Button1.OnClick(Self);
  End;
end;

end.
