unit Unit3;

interface

uses
  Windows, Forms, Messages, SysUtils, Variants, Classes, Graphics, uRESTDWPoolerDB, StdCtrls,
  Controls, ExtCtrls, acPNG;

type
  TForm3 = class(TForm)
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
    RESTDWPoolerList1: TRESTDWPoolerList;
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
 RESTDWPoolerList1.Active        := False;
 RESTDWPoolerList1.PoolerService := Edit4.Text;
 RESTDWPoolerList1.PoolerPort    := StrToInt(Edit5.Text);
 RESTDWPoolerList1.Login         := 'testserver';
 RESTDWPoolerList1.Password      := 'testserver';
 RESTDWPoolerList1.Active        := True;
 If RESTDWPoolerList1.Active Then
  Begin
   ListBox1.Clear;
   If RESTDWPoolerList1.Poolers <> Nil Then
    If RESTDWPoolerList1.Poolers.Count > 0 Then
     ListBox1.Items.Assign(RESTDWPoolerList1.Poolers);
  End;
end;

end.
