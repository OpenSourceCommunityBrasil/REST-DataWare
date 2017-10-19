unit Pop3MainUnit;
{
 Pop3 Server Mainform
 This form just holds an output(Debug) window to monitor the communication
 between a client and this server.

 You can easily connect to using Microsoft Outlook to this server and monitor the progess
 of sending and receiving mails.

  (c)2005
  Jörg Meier (Bob)
  briefe@jmeiersoftware.de
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, Buttons;

type
  TPop3Main = class(TForm)
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Close1: TMenuItem;
    Extra1: TMenuItem;
    Options1: TMenuItem;
    GetSendBtn: TBitBtn;
    CheckTimer: TTimer;
    Panel1: TPanel;
    StartBtn: TButton;
    StopBtn: TButton;
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure CheckTimerTimer(Sender: TObject);
    procedure GetSendBtnClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    Procedure WndProc(var Message:tMessage); Override;
  end;

Const  LogMessageNo = WM_USER+$666;  // We need this for communication
       LogString    = 0;             // for other units with us
       LogInteger   = 1;             //
var
  Pop3Main: TPop3Main;

implementation
Uses MBoxDataModule, ProviderUnit;
{$R *.DFM}

procedure TPop3Main.WndProc(var Message: tMessage);
Var       MyString : PChar;
begin
     If Message.Msg = LogMessageNo then
     begin
          Case Message.WParam of
          LogString  : begin
                            MyString := PChar(Message.LParam);
                            Memo1.Lines.Add(String(MyString));
                            StrDispose(MyString);
                       end;
          LogInteger : begin
                            Memo1.Lines.Add(IntToStr(Message.LParam));
                       end;
          else
          end;
     end
     else begin
          inherited;
     end;
end;

procedure TPop3Main.StartBtnClick(Sender: TObject);
begin
     Memo1.Clear;
     StopBtn.Enabled  := True;
     StartBtn.Enabled := False;

     MBoxDataMod.RunServer; // Local servers
     CheckTimer.Interval := 1000 * 60* StrToInt(ProviderForm.CheckMailTime.Text);
     CheckTimer.Enabled := True;
end;

procedure TPop3Main.StopBtnClick(Sender: TObject);
begin
     StopBtn.Enabled  := False;
     StartBtn.Enabled := True;
     MBoxDataMod.StopServer;
end;

procedure TPop3Main.FormShow(Sender: TObject);
begin
     Self.Caption := 'Pop3 Server';
end;

procedure TPop3Main.Options1Click(Sender: TObject);
begin
     ProviderForm.ShowModal;
end;

procedure TPop3Main.Close1Click(Sender: TObject);
begin
     Close
end;

procedure TPop3Main.CheckTimerTimer(Sender: TObject);
begin
     CheckTimer.Enabled := False;
     try
        MBoxDataMod.GetSendMail;
     Except
           // ignore all Errors
     End;
     CheckTimer.Interval := 60*1000*StrToInt(ProviderForm.CheckMailTime.Text);
     CheckTimer.Enabled  := True;
end;

procedure TPop3Main.GetSendBtnClick(Sender: TObject);
begin
     GetSendBtn.Enabled := False;
     CheckTimerTimer(Sender);
     GetSendBtn.Enabled := True;
end;


end.
