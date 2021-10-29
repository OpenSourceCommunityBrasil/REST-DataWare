unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRESTDWSerialize, Vcl.StdCtrls;

 Type
  TObjeto1 = Class(TBaseClass)
  Private
   bString   : String;
   bInteiro  : Integer;
   bFloat    : Real;
   bSimNao   : Boolean;
   bDateTime : TDateTime;
   bStream   : TMemoryStream;
  Public
   Destructor Destroy;Override;
  Published
   Property Nome      : String        Read bString   Write bString;
   Property Idade     : Integer       Read bInteiro  Write bInteiro;
   Property Valor     : Real          Read bFloat    Write bFloat;
   Property DataAtual : TDateTime     Read bDateTime Write bDateTime;
   Property SimNao    : Boolean       Read bSimNao   Write bSimNao;
   Property Arquivo   : TMemoryStream Read bStream   Write bStream;
 End;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses uRESTDWDataJSON, uDWJSONTools;

{$R *.dfm}

Destructor TObjeto1.Destroy;
Begin
 If Assigned(bStream) Then
  FreeAndNil(bStream);
 Inherited;
End;

procedure TForm1.Button1Click(Sender: TObject);
Var
 JSONObject    : TRESTDWJSONObject;
 vObjeto1      : TObjeto1;
 aMemStream    : TMemoryStream;
begin
 JSONObject := TRESTDWJSONObject.Create;
 aMemStream := TMemoryStream.Create;
 Try
  JSONObject.Add        ('Nome',   'aaa');
  JSONObject.Add        ('Idade',  1);
  JSONObject.AddFloat   ('Valor',    3.2);
  JSONObject.AddDateTime('DataAtual', Now);
  JSONObject.Add        ('SimNao',  True);
  aMemStream.LoadFromFile('c:\temp\ProxyName.ini');
  JSONObject.Add        ('Arquivo', aMemStream);
  vObjeto1   := TObjeto1(TRESTDWJSONSerializer.JSONtoObject(JSONObject.ToJSON, TObjeto1));
  Memo1.lines.Clear;
  Memo1.lines.Add(Format('Nome=%s',      [vObjeto1.Nome]));
  Memo1.lines.Add(Format('Idade=%d',     [vObjeto1.Idade]));
  Memo1.lines.Add(Format('Valor=%s',     [FloatToStr   (vObjeto1.Valor)]));
  Memo1.lines.Add(Format('DataAtual=%s', [DateTimeToStr(vObjeto1.DataAtual)]));
  Memo1.lines.Add(Format('SimNao=%s',    [BoolToStr    (vObjeto1.SimNao)]));
  Memo1.lines.Add(Format('Arquivo=%s',   [Encodeb64Stream(vObjeto1.Arquivo)]));
 Finally
  FreeAndNil(JSONObject);
  FreeAndNil(vObjeto1);
 End;
end;

end.
