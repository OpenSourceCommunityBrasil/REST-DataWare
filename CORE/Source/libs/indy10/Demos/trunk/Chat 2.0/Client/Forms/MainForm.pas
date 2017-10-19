{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22991: MainForm.pas 
{
{   Rev 1.0    09/10/2003 3:17:42 PM  Jeremy Darling
{ Project uploaded for the first time
}
{-----------------------------------------------------------------------------
 Demo Name: fMain
 Author:    Allen O'Neill
 Purpose:   Basic TCP client demo
 History:
 Date:      13/07/2002 00:55:23
-----------------------------------------------------------------------------

  Notes:

  Demonstrates the following functions:

  (1) ReadLn, WriteLn, ReadInteger
  (2) Using the OnConnect and OnDisconnect events

}


unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdTelnet;

type
  TfrmMain = class(TForm)
    Label2: TLabel;
    edHost: TEdit;
    Label3: TLabel;
    edPort: TEdit;
    btnConnect: TButton;
    Bevel1: TBevel;
    memMsgs: TMemo;
    Panel1: TPanel;
    edMsg: TEdit;
    Client: TIdTCPClient;
    Timer1: TTimer;
    procedure btnConnectClick(Sender: TObject);
    procedure ClientConnect(Sender: TObject);
    procedure ClientDisconnect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edMsgKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure ClientConnected(Sender: TObject);
    procedure ClientDisconnected(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnConnectClick(Sender: TObject);
begin
  if Client.Connected then
    Client.Disconnect
  else
    begin
      Client.Host := edHost.Text;
      Client.Port := StrToIntDef(edPort.Text, 8800);
      edPort.Text := IntToStr(Client.Port);
      memMsgs.Lines.Clear;
      Client.Connect;
    end;
end;

procedure TfrmMain.ClientConnect(Sender: TObject);
begin
  edPort.Enabled := false;
  edHost.Enabled := false;
  btnConnect.Caption := 'Disconnect';
end;

procedure TfrmMain.ClientDisconnect(Sender: TObject);
begin
  edPort.Enabled := true;
  edHost.Enabled := true;
  btnConnect.Caption := 'Connect';
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  memMsgs.Align := alClient;
  memMsgs.Lines.Clear;
  edMsg.Text := '';
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Client.Disconnect;
  CanClose := not Client.Connected;
end;

procedure TfrmMain.edMsgKeyPress(Sender: TObject; var Key: Char);
var
  s : String;
begin
  if Key = #13 then
    begin
      s := edMsg.Text + #10#13;
      Key := #0;
      edMsg.Text := '';
      Client.IOHandler.WriteBuffer(s[1], Length(s));
    end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
  i : integer;
  s : String;
begin
  if not Client.Connected then
    exit;

  I := Client.IOHandler.Buffer.Size;
  if I > 0 then
    begin
      SetLength(s, i);
      Client.IOHandler.ReadBuffer(s[1], i);
      memMsgs.Lines.add(Copy(s, 1, Length(s) -2));
    end;
end;

procedure TfrmMain.ClientConnected(Sender: TObject);
begin
  btnConnect.Caption := 'Disconnect';
end;

procedure TfrmMain.ClientDisconnected(Sender: TObject);
begin
  btnConnect.Caption := 'Connect';
end;

end.
