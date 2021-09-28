unit Unit14;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent,
  IdTCPConnection, IdGlobal, IdTCPClient, Vcl.StdCtrls, uRESTDwProcessThread,
  uDWAbout;

type
  TForm14 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ePorta: TEdit;
    eHost: TEdit;
    Memo1: TMemo;
    Button3: TButton;
    RESTDWClientNotification1: TRESTDWClientNotification;
    eConnectionName: TEdit;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RESTDWClientNotification1ReceiveMessage(Username,
      aMessage: string; var Accept: Boolean; var ErrorMessage: string);
    procedure RESTDWClientNotification1Connect(Sender: TObject);
    procedure RESTDWClientNotification1Disconnect(Sender: TObject);
    procedure RESTDWClientNotification1BeforeConnect(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form14: TForm14;

implementation

{$R *.dfm}

procedure TForm14.Button1Click(Sender: TObject);
begin
 Memo1.Lines.Clear;
 RESTDWClientNotification1.Host := eHost.Text;
 RESTDWClientNotification1.Port := StrToInt(ePorta.Text);
 RESTDWClientNotification1.ConnectionName := eConnectionName.Text;
 RESTDWClientNotification1.Connect;
end;

procedure TForm14.Button2Click(Sender: TObject);
begin
 RESTDWClientNotification1.Disconnect;
end;

procedure TForm14.Button3Click(Sender: TObject);
Var
 vMessage : String;
begin
 vMessage := Inputbox('Insira a MSG para broadcast...', 'Message', '');
 RESTDWClientNotification1.SendMessage(vMessage);
end;

procedure TForm14.Button4Click(Sender: TObject);
begin
 RESTDWClientNotification1.ConnectionName := eConnectionName.Text;
end;

procedure TForm14.Button5Click(Sender: TObject);
Var
 vUsername,
 vMessage : String;
begin
 vUsername := Inputbox('Qual o usuário da msg?', 'Username', '');
 vMessage := Inputbox('Insira a MSG para Envio...', 'Message', '');
 RESTDWClientNotification1.SendMessage(vUsername, vMessage);
end;

procedure TForm14.Button6Click(Sender: TObject);
Var
 vFile : TFileStream;
begin
 If OpenDialog1.Execute Then
  Begin
   vFile := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
   Try
    vFile.Position := 0;
    RESTDWClientNotification1.SendStream(vFile);
   Finally
    FreeAndNil(vFile);
   End;
  End;
end;

procedure TForm14.Button7Click(Sender: TObject);
Var
 vUsername : String;
 vFile     : TFileStream;
begin
 vUsername := Inputbox('Qual o usuário da msg?', 'Username', '');
 If OpenDialog1.Execute Then
  Begin
   vFile := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
   Try
    vFile.Position := 0;
    RESTDWClientNotification1.SendStream(vUsername, vFile);
   Finally
    FreeAndNil(vFile);
   End;
  End;
end;

procedure TForm14.RESTDWClientNotification1BeforeConnect(Sender: TObject);
begin
 Memo1.Lines.Add('Before connect...');
end;

procedure TForm14.RESTDWClientNotification1Connect(Sender: TObject);
begin
 Memo1.Lines.Add('Connected...');
 eConnectionName.Text := RESTDWClientNotification1.ConnectionName;
end;

procedure TForm14.RESTDWClientNotification1Disconnect(Sender: TObject);
begin
 Memo1.Lines.Add('Disconnected...');
end;

procedure TForm14.RESTDWClientNotification1ReceiveMessage(Username,
  aMessage: string; var Accept: Boolean; var ErrorMessage: string);
begin
 Memo1.Lines.Add(aMessage);
end;

end.
