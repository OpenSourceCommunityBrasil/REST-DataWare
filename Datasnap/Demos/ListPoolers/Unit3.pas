unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRestPoolerDB, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TForm3 = class(TForm)
    RESTPoolerList1: TRESTPoolerList;
    ListBox1: TListBox;
    Label3: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    Label2: TLabel;
    Edit4: TEdit;
    Edit5: TEdit;
    Button3: TButton;
    Bevel2: TBevel;
    Label4: TLabel;
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button3Click(Sender: TObject);
begin
 RESTPoolerList1.Active := False;
 RESTPoolerList1.PoolerService := Edit4.Text;
 RESTPoolerList1.PoolerPort    := StrToInt(Edit5.Text);
 RESTPoolerList1.Active := True;
 If RESTPoolerList1.Active Then
  Begin
   ListBox1.Clear;
   If RESTPoolerList1.Poolers <> Nil Then
    If RESTPoolerList1.Poolers.Count > 0 Then
     ListBox1.Items.Assign(RESTPoolerList1.Poolers);
  End;
end;

end.
