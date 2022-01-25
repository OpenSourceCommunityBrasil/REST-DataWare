unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, uDWDataset, uDWConstsData,
  uRESTDWPoolerDB, uDWResponseTranslator, uDWAbout, Vcl.StdCtrls;

type
  TForm10 = class(TForm)
    DWClientREST1: TDWClientREST;
    eOrigem: TEdit;
    eDestino: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form10: TForm10;

implementation

{$R *.dfm}

procedure TForm10.Button1Click(Sender: TObject);
Var
 aURL : String;
 AResponse : TStringStream;
begin
 AResponse := TStringStream.Create;
 Memo1.Lines.Clear;
 Try
  aURL := 'http://maps.googleapis.com/maps/api/distancematrix/';
  aURL := aURL + Format('json?origins=%s&destinations=%s&mode=driving&language=pt-BR&key=',
                        [StringReplace(StringReplace(eOrigem.Text,  ' ', '+', [rfReplaceAll]), '-', '+', [rfReplaceAll]),
                         StringReplace(StringReplace(eDestino.Text, ' ', '+', [rfReplaceAll]), '-', '+', [rfReplaceAll])]);
  DWClientREST1.Get(aURL, Nil, AResponse);

 Finally
  Memo1.Lines.Add(AResponse.DataString);
  FreeAndNil(AResponse);
 End;
end;

end.
