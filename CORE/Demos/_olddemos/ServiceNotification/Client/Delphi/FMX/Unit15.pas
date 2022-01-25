unit Unit15;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, uDWAbout, uRESTDWProcessThread, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, System.Notification;

type
  TForm15 = class(TForm)
    Memo1: TMemo;
    RESTDWClientNotification1: TRESTDWClientNotification;
    ePorta: TEdit;
    eHost: TEdit;
    eConnectionName: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    NotificationCenter1: TNotificationCenter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RESTDWClientNotification1BeforeConnect(Sender: TObject);
    procedure RESTDWClientNotification1Connect(Sender: TObject);
    procedure RESTDWClientNotification1Disconnect(Sender: TObject);
    procedure RESTDWClientNotification1ReceiveMessage(Username,
      aMessage: string; var Accept: Boolean; var ErrorMessage: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form15: TForm15;

implementation

{$R *.fmx}

procedure TForm15.Button1Click(Sender: TObject);
begin
 Memo1.Lines.Clear;
 RESTDWClientNotification1.Host := eHost.Text;
 RESTDWClientNotification1.Port := StrToInt(ePorta.Text);
 RESTDWClientNotification1.Connect;
end;

procedure TForm15.Button2Click(Sender: TObject);
begin
 RESTDWClientNotification1.Disconnect;
end;

procedure TForm15.Button3Click(Sender: TObject);
Var
 vMessage : String;
begin
 InputBox('Insira a MSG para broadcast...', 'Message', '',
          Procedure(const AResult: TModalResult; const AValue: string)
          Begin
           vMessage := aValue;
           RESTDWClientNotification1.SendMessage(vMessage);
          End);
end;

procedure TForm15.Button4Click(Sender: TObject);
begin
 RESTDWClientNotification1.ConnectionName := eConnectionName.Text;
end;

procedure TForm15.RESTDWClientNotification1BeforeConnect(Sender: TObject);
begin
 Memo1.Lines.Add('Before connect...');
end;

procedure TForm15.RESTDWClientNotification1Connect(Sender: TObject);
begin
 Memo1.Lines.Add('Connected...');
 eConnectionName.Text := RESTDWClientNotification1.ConnectionName;
end;

procedure TForm15.RESTDWClientNotification1Disconnect(Sender: TObject);
begin
 Memo1.Lines.Add('Disconnected...');
end;

procedure TForm15.RESTDWClientNotification1ReceiveMessage(Username,
  aMessage: string; var Accept: Boolean; var ErrorMessage: string);
Var
 MyNotification: TNotification;
Begin
 MyNotification := NotificationCenter1.CreateNotification;
 Try
  MyNotification.Number :=1;
  MyNotification.AlertBody := aMessage;
  NotificationCenter1.PresentNotification(MyNotification);
 Finally
  MyNotification.DisposeOf;
 End;
 Memo1.Lines.Add(aMessage);
End;

end.
