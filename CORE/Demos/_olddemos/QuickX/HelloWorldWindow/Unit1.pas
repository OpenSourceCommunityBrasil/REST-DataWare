unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDWConsts, uDWJSONObject, uDWJSONTools,  uRESTDWBaseIDQX,
  Vcl.StdCtrls;


type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
   RESTDWServerQXID : TRESTDWServerQXID;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

Procedure Helloworld (Sender                : TObject;
                      RequestHeader         : TStringList;
                      Const Params          : TDWParams;
                      Var   ContentType     : String;
                      Var   Result          : String;
                      Const RequestType     : TRequestType;
                      Var   StatusCode      : Integer;
                      Var   ErrorMessage    : String;
                      Var   OutCustomHeader : TStringList);
Begin
 Case RequestType of
  rtGet    : Begin
              ContentType := 'text/html';
              Result      := '<html><head></head><body><h1>Hello World<h1></body></html>';
             End;
  rtPost   : Result       := '{"json":"Hello World - POST"}';
 End;
End;

Procedure Hellofile  (Sender                : TObject;
                      RequestHeader         : TStringList;
                      Const Params          : TDWParams;
                      Var   ContentType     : String;
                      Const Result          : TMemoryStream;
                      Const RequestType     : TRequestType;
                      Var   StatusCode      : Integer;
                      Var   ErrorMessage    : String;
                      Var   OutCustomHeader : TStringList);
Var
 vStringFile : TStringStream;
 vResultFile : TMemoryStream;
Begin
 vResultFile := TMemoryStream.Create;
 Try
  Case RequestType of
   rtGet    : Begin
               ContentType := 'image/png';
               Result.LoadFromFile(ExtractFilePath(ParamSTR(0)) + '\rdw.png');
              End;
   rtPost   : Begin
               vResultFile.LoadFromFile(ExtractFilePath(ParamSTR(0)) + '\rdw.png');
               Try
                vStringFile := TStringStream.Create(Format('{"fileb64":"%s"}', [Encodeb64Stream(vResultFile)]));
                vStringFile.Position := 0;
                Result.CopyFrom(vStringFile, vStringFile.Size);
                Result.Position := 0;
               Finally
                FreeAndNil(vStringFile);
               End;
              End;
  End;
 Finally
  FreeAndNil(vResultFile);
 End;
End;

procedure TForm1.Button1Click(Sender: TObject);
begin
 RESTDWServerQXID.Bind(9092, False);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 RESTDWServerQXID.Active := False;
 Release;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 RESTDWServerQXID := TRESTDWServerQXID.Create(Nil);
 RESTDWServerQXID.AddUrl('helloworld', [crGet, crPost], Helloworld);
 RESTDWServerQXID.AddUrl('hellofile',  [crGet, crPost], Hellofile);
end;

end.
