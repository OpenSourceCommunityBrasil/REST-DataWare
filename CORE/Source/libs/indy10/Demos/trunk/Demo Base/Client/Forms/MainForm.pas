{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22954: MainForm.pas 
{
{   Rev 1.0    09/10/2003 3:10:44 PM  Jeremy Darling
{ Project Checked into TC for the first time
}
unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, StdCtrls, ClientThread,
  IdAntiFreezeBase, IdAntiFreeze, SyncObjs, ExtCtrls, ComCtrls, IniFiles;

type
  TfrmMain = class(TForm)
    SampleClient: TIdTCPClient;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edHost: TEdit;
    edPort: TEdit;
    Label4: TLabel;
    edThreads: TEdit;
    IdAntiFreeze1: TIdAntiFreeze;
    lblConCons: TLabel;
    lblMaxCons: TLabel;
    lblTotalCons: TLabel;
    lvStatus: TListView;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edPortKeyPress(Sender: TObject; var Key: Char);
    procedure edThreadsKeyPress(Sender: TObject; var Key: Char);
    procedure edThreadsChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SampleClientConnected(Sender: TObject);
    procedure SampleClientDisconnected(Sender: TObject);
    procedure SampleClientWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
  private
    { Private declarations }
    FDefaultCaption   : String;
    fThreads          : TList;
    FClientsConnected : Boolean;
    uiLock            : TCriticalSection;
    CurrentConnections,
    MaxConnections,
    ConnectionsMade   : Integer;
    procedure SetClientsConnected(const Value: Boolean);
    procedure LoadIniSettings;
    procedure WriteIniSettings;
  public
    { Public declarations }
    procedure StartThreads;
    procedure StopThreads;
    property ClientsConnected : Boolean read FClientsConnected write SetClientsConnected;
  end;

var
  frmMain: TfrmMain;
  Ini    : TIniFile;

implementation

{$R *.DFM}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Randomize;
  Ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  LoadIniSettings;
  
  CurrentConnections := 0;
  ConnectionsMade    := 0;
  MaxConnections     := 0;

  lblConCons.Caption := 'Current Concurrent Connections: 0';
  lblMaxCons.Caption := 'Max Concurrent Connections: 0';
  lblTotalCons.Caption := 'Total Connections Made: 0';

  FDefaultCaption := Caption;
  uiLock := TCriticalSection.Create;
  fThreads := TList.Create;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  SampleClient.Host := edHost.Text;
  SampleClient.Port := StrToIntDef(edPort.Text, 8800);
  if ClientsConnected then
    StopThreads
  else
    StartThreads;
end;

procedure TfrmMain.edPortKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0', '1'..'9', #8]) then
    Key := #0;
end;

procedure TfrmMain.edThreadsKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0', '1'..'9', #8]) then
    Key := #0;
end;

procedure TfrmMain.edThreadsChange(Sender: TObject);
begin
  if edThreads.Text = '' then
    edThreads.Text := '0';
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  StopThreads;
  fThreads.Free;
  uiLock.Free;
  WriteIniSettings;
  Ini.Free;
end;

procedure TfrmMain.StartThreads;
var
  i : Integer;
  st: Integer;
begin
  lvStatus.Items.Clear;

  CurrentConnections := 0;
  ConnectionsMade    := 0;
  MaxConnections     := 0;

  lblConCons.Caption := 'Current Concurrent Connections: 0';
  lblMaxCons.Caption := 'Max Concurrent Connections: 0';
  lblTotalCons.Caption := 'Total Connections Made: 0';

  st := StrToIntDef(edThreads.Text, 0);
  if st < 10 then
    st := 10;

  for i := 0 to StrToIntDef(edThreads.Text, 0) -1 do
    begin
      with TClientThread(fThreads[fThreads.Add(TClientThread.Create(true))]) do
        begin
          AssignClient(SampleClient);

          ListItem := lvStatus.Items.Add;
          ListItem.Caption := IntToStr(i);
          ListItem.SubItems.Add('Creating');
          SleepTime := random(st);
          if SleepTime < 5 then
            while SleepTime < 5 do
              SleepTime := random(st);

          uiLock := self.uiLock;

          Client.Tag := Integer(Pointer(TClientThread(fThreads[i])));
          State      := -2;
          Resume;
        end;
    end;

  ClientsConnected := true;
end;

procedure TfrmMain.StopThreads;
begin
  ClientsConnected := false;
  if fThreads.Count > 0 then
    while fThreads.Count > 0 do
      begin
        TClientThread(fThreads[0]).FreeOnTerminate := true;
        TClientThread(fThreads[0]).Terminate;
        fThreads.Delete(0);
      end;
end;

procedure TfrmMain.SampleClientConnected(Sender: TObject);
var
  ct : TClientThread;
begin
  uiLock.Enter;
  try
    ct := Pointer(TIdTCPClient(Sender).Tag);

    ct.State := 0;

    Inc(CurrentConnections);
    Inc(ConnectionsMade);

    lblConCons.Caption := 'Current Concurrent Connections: ' + IntToStr(CurrentConnections);
    if MaxConnections < CurrentConnections then
      begin
        MaxConnections := CurrentConnections;
        lblMaxCons.Caption := 'Max Concurrent Connections: ' + IntToStr(MaxConnections);
      end;
    lblTotalCons.Caption := 'Total Connections Made: ' + IntToStr(ConnectionsMade);

  finally
    uiLock.Leave;
  end;
end;

procedure TfrmMain.SetClientsConnected(const Value: Boolean);
begin
  FClientsConnected := Value;

  if Value then
    Button1.Caption := 'Disconnect'
  else
    Button1.Caption := 'Connect';

  edHost.Enabled := not Value;
  edPort.Enabled := not Value;
  edThreads.Enabled := not Value;
end;

procedure TfrmMain.SampleClientDisconnected(Sender: TObject);
var
  ct : TClientThread;
begin
  uiLock.Enter;
  try
    ct := Pointer(TIdTCPClient(Sender).Tag);

    ct.State := -2;

    Dec(CurrentConnections);
    lblConCons.Caption := 'Current Concurrent Connections: ' + IntToStr(CurrentConnections);
  finally
    uiLock.Leave;
  end;
end;

procedure TfrmMain.SampleClientWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
// Do Nothing
end;

procedure TfrmMain.LoadIniSettings;
begin
  edHost.Text    := Ini.ReadString('Connection', 'Host', edHost.Text);
  edPort.Text    := Ini.ReadString('Connection', 'Port', edPort.Text);
  edThreads.Text := Ini.ReadString('Threads', 'Threads', edThreads.Text);
end;

procedure TfrmMain.WriteIniSettings;
begin
  Ini.WriteString('Connection', 'Host', edHost.Text);
  Ini.WriteString('Connection', 'Port', edPort.Text);
  Ini.WriteString('Threads', 'Threads', edThreads.Text);
end;

end.
