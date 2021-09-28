unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uRESTDwProcessThread;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    eConnectionName: TEdit;
    eHost: TEdit;
    ePorta: TEdit;
    Memo1: TMemo;
    RESTDWClientNotification1: TRESTDWClientNotification;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RESTDWClientNotification1BeforeConnect(Sender: TObject);
    procedure RESTDWClientNotification1Connect(Sender: TObject);
    procedure RESTDWClientNotification1Disconnect(Sender: TObject);
    procedure RESTDWClientNotification1ReceiveMessage(Username: String;
      aMessage: String; var Accept: Boolean; var ErrorMessage: String);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  RESTDWClientNotification1.Host := eHost.Text;
  RESTDWClientNotification1.Port := StrToInt(ePorta.Text);
  RESTDWClientNotification1.Connect;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  RESTDWClientNotification1.Disconnect;
end;

procedure TForm1.Button3Click(Sender: TObject);
Var
 vMessage : String;
begin
 vMessage := Inputbox('Insira a MSG para broadcast...', 'Message', '');
 RESTDWClientNotification1.SendMessage(vMessage);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 RESTDWClientNotification1.ConnectionName := eConnectionName.Text;
end;

procedure TForm1.RESTDWClientNotification1BeforeConnect(Sender: TObject);
begin
 Memo1.Lines.Add('Before connect...');
end;

procedure TForm1.RESTDWClientNotification1Connect(Sender: TObject);
begin
 Memo1.Lines.Add('Connected...');
 eConnectionName.Text := RESTDWClientNotification1.ConnectionName;
end;

procedure TForm1.RESTDWClientNotification1Disconnect(Sender: TObject);
begin
 Memo1.Lines.Add('Disconnected...');
end;

procedure TForm1.RESTDWClientNotification1ReceiveMessage(Username: String;
  aMessage: String; var Accept: Boolean; var ErrorMessage: String);
begin
 Memo1.Lines.Add(aMessage);
end;

end.

