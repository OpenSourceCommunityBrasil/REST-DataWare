{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22939: MainForm.pas 
{
{   Rev 1.0    09/10/2003 3:08:58 PM  Jeremy Darling
{ Project Checked into TC for the first time
}
{***************************************************************
* Project : <This is the name of your project>
* Unit Name: <This is the name of this unit>
* Purpose : <This is a description of the project>
* Author : <Your Name>
* Date : <Date submitted to indy demo team>
* Other Info : <Anything else>
* History :
*           <History list>
****************************************************************}

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IdBaseComponent, IdComponent, IdTCPServer, IdContext, StdCtrls, IdScheduler,
  IdSchedulerOfThread, IdSchedulerOfThreadDefault, CheckLst, ComCtrls, ExtCtrls,
  IdDsnCoreResourceStrings, IdStack, IdSocketHandle, ShellAPI, IdGlobal,
  IniFiles, IdAntiFreezeBase, IdAntiFreeze, IdCustomTCPServer, IdStackWindows,
  IdCustomHTTPServer, IdHTTPServer;

type
  TfrmMain = class(TForm)
    pnlButtonBar: TPanel;
    pcMain: TPageControl;
    tsSettings: TTabSheet;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbIPs: TCheckListBox;
    cbPorts: TComboBox;
    edPort: TEdit;
    tsProcessLog: TTabSheet;
    lbProcesses: TListBox;
    btnStartStop: TButton;
    IdAntiFreeze1: TIdAntiFreeze;
    IdSchedulerOfThreadDefault1: TIdSchedulerOfThreadDefault;
    Server: TIdHTTPServer;
    Label1: TLabel;
    edServerRoot: TEdit;
    procedure btnStartStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbProcessesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ServerStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: String);
    procedure ServerException(AContext: TIdContext; AException: Exception);
    procedure FormActivate(Sender: TObject);
    procedure ServerExecute(AContext: TIdContext);
    procedure ServerConnect(AContext: TIdContext);
    procedure ServerDisconnect(AContext: TIdContext);
    procedure edPortKeyPress(Sender: TObject; var Key: Char);
    procedure ServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
  private
    { Private declarations }
    function CheckStartOk : Boolean;

    function StartServer : Boolean;
    function StopServer  : Boolean;

    procedure PopulateIPAddresses;
    function PortDescription(const PortNumber: integer): string;

    procedure LoadDefaultValues;
    procedure SaveDefaultValues;

    procedure CheckOptions;
    function GetServerOnline: Boolean;

    function InternalServerBeforeStart : Boolean;
    procedure InternalServerAfterStart;

    function InternalServerBeforeStop : Boolean;
    procedure InternalServerAfterStop;

    procedure Log(Msg : String; Color : TColor = clBlack);
    procedure SetControls;
  public
    { Public declarations }
    property ServerOnline : Boolean read GetServerOnline;
  end;

var
  frmMain : TfrmMain;
  Ini     : TIniFile;
  
implementation

{$R *.DFM}

procedure TfrmMain.btnStartStopClick(Sender: TObject);
begin
// This procedure should never change.
  if ServerOnline then
    StopServer
  else
    StartServer;
end;

function TfrmMain.CheckStartOk: Boolean;
var
  i, c : Integer;
begin
// This section should stay the same, add your new code below
  i := 0;
  for c := 0 to lbIPs.Items.Count -1 do
    begin
      if lbIPs.Checked[c] then
        inc(i);
    end;
  result := i > 0;
  if not result then
    begin
      Log('Can''t start server until you select at least one IP to bind to.', clRed);
      MessageDlg('Can''t start server until you select at least one IP to bind to.', mtError, [mbOK], 0);
    end;
// Add your code after this comment
end;

procedure TfrmMain.PopulateIPAddresses;
var
  i : integer;
begin
// Again this section should not change
  with lbIPs do
    begin
      Clear;
      Items := GStack.LocalAddresses;
      Items.Insert(0, '127.0.0.1');
    end;
  try
    cbPorts.Items.Add(RSBindingAny);
    cbPorts.Items.BeginUpdate;
    for i := 0 to IdPorts.Count - 1 do
      cbPorts.Items.Add(PortDescription(Integer(IdPorts[i])));
  finally
    cbPorts.Items.EndUpdate;
  end;
end;

function TfrmMain.PortDescription(const PortNumber: integer): string;
begin
// Guess what more code that shouldn't change
  with TIdStackWindows(GStack).WSGetServByPort(PortNumber) do
    try
      if PortNumber = 0 then
        begin
          Result := Format('%d: %s', [PortNumber, RSBindingAny]);
        end
      else
        begin
          Result := '';    {Do not Localize}
          if Count > 0 then
            begin
              Result := Format('%d: %s', [PortNumber, CommaText]);    {Do not Localize}
            end;
        end;
    finally
      Free;
    end;
end;

function TfrmMain.StartServer: Boolean;
var
  Binding : TIdSocketHandle;
  i : integer;
  SL : TStringList;
begin
// This code starts the server up and posts back information about
// the server starting up.
// You should place your pre and post startup code in InternalServerBeforeStart
// and InternalServerAfterStart accordingly.
  Result := false;
  if not CheckStartOk then
    exit;

  SL := TStringList.Create;

  if not StopServer then
    begin
      Log( 'Error stopping server', clRed );
      Result := false;
      exit;
    end;

  Server.Bindings.Clear; // bindings cannot be cleared until TServer is inactive
  try
    try
      Server.DefaultPort := StrToInt(edPort.Text);
      for i := 0 to lbIPs.Items.Count - 1 do
        if lbIPs.Checked[i] then
          begin
            Binding := Server.Bindings.Add;
            Binding.IP := lbIPs.Items.Strings[i];
            Binding.Port := StrToInt( edPort.Text );
            Log( 'Server bound to IP ' + Binding.IP + ' on port ' + edPort.Text );
          end;

      if InternalServerBeforeStart then
        begin
          Server.Active := true;
          result := Server.Active;

          InternalServerAfterStart;
          if ServerOnline then
            begin
              Log( 'Server started', clGreen );
              btnStartStop.Caption := 'Stop Server';
              SetControls;
            end;
        end;
    except
      on E : Exception do
        begin
          Log( 'Server not started', clRed );
          Log( E.Message, clRed );
          Result := false;
        end;
    end;
  finally
    FreeAndNil( SL );
  end;
end;

function TfrmMain.StopServer: Boolean;
var
  b : Boolean;
begin
// This code stops the server and posts back information about
// the server shutting down.
// You should place your pre and post shutdown code in InternalServerBeforeStop
// and InternalServerAfterStop accordingly.

  Result := false;

  b := Server.Active;

  if InternalServerBeforeStop then
    begin
      Server.Active := false;
      Server.Bindings.Clear;
      Result := not Server.Active;

      if result then
        begin
          if b then
            Log( 'Server stopped', clGreen );
        end
      else
        begin
          Log( 'Server not stopped', clRed );
        end;

      InternalServerAfterStop;
      btnStartStop.Caption := 'Start Server';
      SetControls;
    end
  else
    Log( 'Server not stopped', clRed );
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
// Initialization routines.  You should find the appropriate procedure
// to initialize your stuff below.  The form create should hardly ever
// need to be changed.
  Ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  pcMain.ActivePageIndex := 0;
  pcMain.Align  := alClient;
  PopulateIPAddresses;
  StopServer;
  LoadDefaultValues;
  CheckOptions;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
// If you created anything in form create or in one of the other
// initialization routines then get rid of it here.
  StopServer;
  SaveDefaultValues;
  Ini.Free;
end;

procedure TfrmMain.LoadDefaultValues;
var
  i, c : Integer;
  s    : String;
begin
// This is were you get the chance to load values from the global
// Ini file.  The section for ports and IP's has been added in here
// for you by default.
  edPort.Text := Ini.ReadString('Settings', 'Port', edPort.Text);
  c := Ini.ReadInteger('Settings', 'IPs', 0);
  for i := 1 to c do
    begin
      s := Ini.ReadString('Settings', 'IP' + IntToStr(i), '');
      if lbIPs.Items.IndexOf(s) > -1 then
        lbIPs.Checked[lbIPs.Items.IndexOf(s)] := true;
    end;
  edServerRoot.Text := Ini.ReadString('Settings', 'ServerRoot', ExtractFilePath(ParamStr(0)) + 'Docs');
end;

procedure TfrmMain.SaveDefaultValues;
var
  i, c : Integer;
begin
// This is were you get the chance to save values to the global
// Ini file.  The section for ports and IP's has been added in here
// for you by default.
  Ini.WriteString('Settings', 'Port', edPort.Text);
  c := 0;
  for i := 0 to lbIPs.Items.Count -1 do
    if lbIPs.Checked[i] then
      begin
        inc(c);
        Ini.WriteString('Settings', 'IP' + IntToStr(c), lbIPs.Items[i]);
      end;
  Ini.WriteInteger('Settings', 'IPs', c);
  Ini.WriteInteger('Placement', 'Top', Top);
  Ini.WriteInteger('Placement', 'Left', Left);
end;

procedure TfrmMain.CheckOptions;
var
  i   : Integer;
  opt : string;
  bDoAutoStart : Boolean;

  function OptName : String;
  begin
    if pos('=', opt) > 0 then
      begin
        result := copy(opt, 1, pos('=', opt) - 1);
        if result[1] in ['-', '/', '\'] then
          result := copy(result, 2, length(result));
      end
    else
      result := opt;
  end;

  function OptValue : String;
  begin
    if pos('=', opt) > 0 then
      result := copy(opt, pos('=', opt) + 1, length(opt))
    else
      result := opt;
  end;
begin
// The check options procedure should be used to check commandline options
// if you wish to support command line options then please add it here.
// By default port and autostart are supported.
  bDoAutoStart := false;
  for i := 1 to ParamCount do
    begin
      opt := LowerCase(ParamStr(i));

      if OptName = 'port' then
        edPort.Text := OptValue;

      if OptName = 'autostart' then
        bDoAutoStart := true;
    end;
    
  if bDoAutoStart then
    StartServer;
end;

function TfrmMain.GetServerOnline: Boolean;
begin
// Just a faster way then checking server.active for some
  result := Server.Active;
end;

procedure TfrmMain.lbProcessesDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
// This draws the items in the Process Log in colors to allow quick
// visual inspection
  with Control as TListBox do
  begin
    Canvas.Brush.Color := Color;

    Canvas.FillRect(Rect); 
    Canvas.Font.Color := TColor(Items.Objects[Index]);
    Canvas.TextOut(Rect.Left + 2, Rect.Top, Items[Index]);
  end;
end;

procedure TfrmMain.Log(Msg: String; Color: TColor);
begin
// Simply adds a new item to the process log and then makes it the
// currently selected item.
  lbProcesses.Items.AddObject(Msg, Pointer(Color));
  lbProcesses.ItemIndex := lbProcesses.Items.Count -1;
end;

procedure TfrmMain.ServerStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: String);
begin
// Logs any ServerStatus messages to the Process Log
  Log(AStatusText);
end;

procedure TfrmMain.ServerException(AContext: TIdContext;
  AException: Exception);
begin
// Logs any server exceptions to the Process Log
  Log(AException.Message, clRed);
end;

function TfrmMain.InternalServerBeforeStart: Boolean;
begin
  // Preform your startup code here.  If you do not wish the server to start
  // then simply return false from this function and report back the proper
  // error by calling Log(YourMessage, clRed);
  result := true;
end;

procedure TfrmMain.InternalServerAfterStart;
begin
// Your code should go here.  At this point the server is active.
// So if you need to stop it then you should call StopServer
// or for a hard halt call Server.Active := false;
end;

procedure TfrmMain.InternalServerAfterStop;
begin
// Your code should go here.  At this point the server has been stoped.
// So if you need to start it then you should call StartServer
// or for a force start call Server.Active := true;
end;

function TfrmMain.InternalServerBeforeStop: Boolean;
begin
  // Preform your shutdown code here.  If you do not wish the server to stop
  // then simply return false from this function and report back the proper
  // error by calling Log(YourMessage, clRed);
  Result := true;
end;

procedure TfrmMain.SetControls;
begin
// Sets up the UI controls to either be enabled or disabled based upon
// the current server state.  See below for examples.
  lbIPs.Enabled   := not ServerOnline;
  edPort.Enabled  := not ServerOnline;
  cbPorts.Enabled := not ServerOnline;
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  Top := Ini.ReadInteger('Placement', 'Top', Top);
  Left:= Ini.ReadInteger('Placement', 'Left', Left);
end;

procedure TfrmMain.ServerExecute(AContext: TIdContext);
begin
// Your stuff for OnExecute goes here.

end;

procedure TfrmMain.ServerConnect(AContext: TIdContext);
begin
  Log('Client connection established from ip: ' + AContext.Connection.Socket.Host, clBlue);
end;

procedure TfrmMain.ServerDisconnect(AContext: TIdContext);
begin
  Log('Client connection removed from ip: ' + AContext.Connection.Socket.Host, clBlue);
end;

procedure TfrmMain.edPortKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0', '1'..'9', #8]) then
    Key := #0;
end;

procedure TfrmMain.ServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  rPage : String;
begin
  Log('Serving: ' + ARequestInfo.Document + ' to ' + AContext.Connection.Socket.Host, clBlue);
  if (ARequestInfo.Document <> '') and
     (ARequestInfo.Document <> '/') and
     (ARequestInfo.Document <> '\') then
    rPage := Copy(ARequestInfo.Document, 2, Length(ARequestInfo.Document))
  else
    rPage := 'Index.htm';
  rPage := StringReplace(rPage, '/', '\',[rfReplaceAll, rfIgnoreCase]);
  rPage := IncludeTrailingBackslash(edServerRoot.Text) + rPage;
  if FileExists(rPage) then
    AResponseInfo.ServeFile(AContext, rPage)
  else
    AResponseInfo.ContentText := '<H1>ERROR</H1>File not found: '+ARequestInfo.Document;
end;

end.
