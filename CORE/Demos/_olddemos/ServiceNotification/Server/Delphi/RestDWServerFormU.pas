unit RestDWServerFormU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, Vcl.ComCtrls, uDWConsts, Vcl.Buttons,
  uDWAbout, uRESTDWBase, ServerUtils, IniFiles, Vcl.Menus, IdBaseComponent,
  IdComponent, IdServerIOHandler, IdServerIOHandlerSocket,
  IdServerIOHandlerStack, IdAntiFreezeBase, Vcl.IdAntiFreeze;

type
  TRestDWForm = class(TForm)
    Label8: TLabel;
    PageControl1: TPageControl;
    tsConfigs: TTabSheet;
    Panel1: TPanel;
    Label1: TLabel;
    Label6: TLabel;
    labConexao: TLabel;
    Label7: TLabel;
    labDBConfig: TLabel;
    labVersao: TLabel;
    Label11: TLabel;
    Panel3: TPanel;
    Image7: TImage;
    Panel4: TPanel;
    Image8: TImage;
    edPortaDW: TEdit;
    cbForceWelcome: TCheckBox;
    pBasicAuth: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    cbAuthOptions: TComboBox;
    pTokenAuth: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    Label21: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    cbTokenType: TComboBox;
    eTokenEvent: TEdit;
    eLifeCycle: TEdit;
    eServerSignature: TEdit;
    eTokenHash: TEdit;
    tsLogs: TTabSheet;
    Label18: TLabel;
    memoReq: TMemo;
    paTopo: TPanel;
    Image2: TImage;
    labSistema: TLabel;
    paPortugues: TPanel;
    Image3: TImage;
    paEspanhol: TPanel;
    Image4: TImage;
    paIngles: TPanel;
    Image5: TImage;
    lbConnections: TListBox;
    Panel2: TPanel;
    ButtonStart: TButton;
    ButtonStop: TButton;
    sbKick: TSpeedButton;
    sbBroadcast: TSpeedButton;
    RESTDWServiceNotification1: TRESTDWServiceNotification;
    ctiPrincipal: TTrayIcon;
    tupdatelogs: TTimer;
    pmMenu: TPopupMenu;
    RestaurarAplicao1: TMenuItem;
    N5: TMenuItem;
    SairdaAplicao1: TMenuItem;
    cbUpdateLog: TCheckBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure cbAuthOptionsChange(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure RestaurarAplicao1Click(Sender: TObject);
    procedure SairdaAplicao1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ctiPrincipalDblClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure RESTDWServiceNotification1LastRequest(Sender: TRESTDwSessionData;
      Value: string);
    procedure RESTDWServiceNotification1Connect(
      const Sender: TRESTDwSessionData);
    procedure RESTDWServiceNotification1Disconnect(
      const Sender: TRESTDwSessionData);
    procedure sbKickClick(Sender: TObject);
    procedure sbBroadcastClick(Sender: TObject);
    procedure RESTDWServiceNotification1ReceiveMessage(
      Sender: TRESTDwSessionData; Value: string);
    procedure RESTDWServiceNotification1ConnectionRename(
      Sender: TRESTDwSessionData; OldConnectionName, NewConnectionName: string);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
   FCfgName : String;
   Procedure StartServer;
   procedure HideApplication;
   Function  GetHandleOnTaskBar: THandle;
   procedure ChangeStatusWindow;
   procedure ShowApplication;
   procedure StatusButtons;
    function ConnectionIndex(Value : String) : Integer;
  public
    { Public declarations }
  end;

var
  RestDWForm: TRestDWForm;

implementation

{$R *.dfm}

procedure TRestDWForm.ShowApplication;
Begin
  CtiPrincipal.Visible     := False;
  Application.ShowMainForm := True;
  If Self <> Nil Then
  Begin
    Self.Visible     := True;
    Self.WindowState := WsNormal;
  End;
  ShowWindow(GetHandleOnTaskBar, SW_SHOW);
  ChangeStatusWindow;
End;

procedure TRestDWForm.SpeedButton1Click(Sender: TObject);
Var
 vErrorMessage,
 vMessage : String;
begin
 If lbConnections.ItemIndex > -1 Then
  Begin
   vMessage := Inputbox('Insira a MSG para envio...', 'Message', '');
   RESTDWServiceNotification1.Sendmessage(lbConnections.Items[lbConnections.ItemIndex], vMessage, vErrorMessage);
   If vErrorMessage <> '' Then
    memoReq.Lines.Add(Format('Error send message to %s. Error message : %s', [lbConnections.Items[lbConnections.ItemIndex], vErrorMessage]));
  End;
end;

procedure TRestDWForm.SpeedButton2Click(Sender: TObject);
begin
  RESTDWServiceNotification1.Kickall;
end;

Function TRestDWForm.GetHandleOnTaskBar: THandle;
Begin
 {$IFDEF COMPILER11_UP}
 If Application.MainFormOnTaskBar And Assigned(Application.MainForm) Then
  Result := Application.MainForm.Handle
 Else
 {$ENDIF COMPILER11_UP}
  Result := Application.Handle;
End;

procedure TRestDWForm.ChangeStatusWindow;
Begin
  If Self.Visible Then
    SairdaAplicao1.Caption := 'Minimizar para a bandeja'
  Else
    SairdaAplicao1.Caption := 'Sair da Aplicação';
  Application.ProcessMessages;
End;

procedure TRestDWForm.ctiPrincipalDblClick(Sender: TObject);
begin
  ShowApplication;
end;

procedure TRestDWForm.HideApplication;
Begin
  CtiPrincipal.Visible     := True;
  Application.ShowMainForm := False;
  If Self <> Nil Then
    Self.Visible := False;
  Application.Minimize;
  ShowWindow(GetHandleOnTaskBar, SW_HIDE);
  ChangeStatusWindow;
End;

procedure TRestDWForm.StatusButtons;
Begin
 ButtonStop.Enabled  := RESTDWServiceNotification1.Active;
 ButtonStart.Enabled := Not ButtonStop.Enabled;
End;

procedure TRestDWForm.RestaurarAplicao1Click(Sender: TObject);
begin
  ShowApplication;
end;

procedure TRestDWForm.RESTDWServiceNotification1Connect(
  const Sender: TRESTDwSessionData);
begin
 lbConnections.Items.Add(TRESTDwSession(Sender).Connection);
end;

procedure TRestDWForm.RESTDWServiceNotification1ConnectionRename(
  Sender: TRESTDwSessionData; OldConnectionName, NewConnectionName: string);
Var
 vConnIndex : Integer;
begin
 vConnIndex := ConnectionIndex(OldConnectionName);
 If vConnIndex > -1 Then
  lbConnections.Items[vConnIndex] := NewConnectionName;
end;

Function TRestDWForm.ConnectionIndex(Value : String) : Integer;
Var
 I : Integer;
Begin
 Result := -1;
 For I := lbConnections.Items.Count -1 Downto 0 Do
  Begin
   If lbConnections.Items[I] = Value Then
    Begin
     Result := I;
     Break;
    End;
  End;
End;

procedure TRestDWForm.RESTDWServiceNotification1Disconnect(
  const Sender: TRESTDwSessionData);
Var
 I : Integer;
begin
 I := ConnectionIndex(TRESTDwSession(Sender).Connection);
 If I > -1 Then
  lbConnections.Items.Delete(I);
end;

procedure TRestDWForm.RESTDWServiceNotification1LastRequest(
  Sender: TRESTDwSessionData; Value: string);
begin
 If cbUpdateLog.Checked Then
  memoReq.Lines.Add(TRESTDwSession(Sender).Connection + ': ' + Value);
end;

procedure TRestDWForm.RESTDWServiceNotification1ReceiveMessage(
  Sender: TRESTDwSessionData; Value: string);
begin
 memoReq.Lines.Add(Format('User %s, Message %s', [TRESTDwSession(Sender).Connection,
                                                  Value]));
end;

procedure TRestDWForm.SairdaAplicao1Click(Sender: TObject);
begin
  Close;
end;

procedure TRestDWForm.sbBroadcastClick(Sender: TObject);
Var
 vMessage : String;
begin
 vMessage := Inputbox('Insira a MSG para broadcast...', 'Message', '');
 RESTDWServiceNotification1.BroadcastMessage(vMessage);
end;

procedure TRestDWForm.sbKickClick(Sender: TObject);
begin
 If lbConnections.ItemIndex > -1 Then
  RESTDWServiceNotification1.Kickuser(lbConnections.Items[lbConnections.ItemIndex]);
end;

procedure TRestDWForm.StartServer;
 Function GetAuthOption : TRDWAuthOption;
 Begin
  Case cbAuthOptions.ItemIndex Of
   0 : Result := rdwAONone;
   1 : Result := rdwAOBasic;
   2 : Result := rdwAOBearer;
   3 : Result := rdwAOToken;
  End;
 End;
 Function GetTokenType : TRDWTokenType;
 Begin
  Case cbTokenType.ItemIndex Of
   0 : Result := rdwTS;
   1 : Result := rdwJWT;
  End;
 End;
Begin
 If Not RESTDWServiceNotification1.Active Then
  Begin
   RESTDWServiceNotification1.AuthenticationOptions.AuthorizationOption := GetAuthOption;
   Case RESTDWServiceNotification1.AuthenticationOptions.AuthorizationOption Of
    rdwAOBasic : Begin
                  TRDWAuthOptionBasic(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).Username := EdUserNameDW.Text;
                  TRDWAuthOptionBasic(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).Password := EdPasswordDW.Text;
                 End;
    rdwAOBearer,
    rdwAOToken : Begin
                  If RESTDWServiceNotification1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
                   Begin
                    TRDWAuthOptionBearerServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).TokenType       := GetTokenType;
                    TRDWAuthOptionBearerServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).GetTokenEvent   := eTokenEvent.Text;
                    TRDWAuthOptionBearerServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).TokenHash       := eTokenHash.Text;
                    TRDWAuthOptionBearerServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).ServerSignature := eServerSignature.Text;
                    TRDWAuthOptionBearerServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).LifeCycle       := StrToInt(eLifeCycle.Text);
                   End
                  Else
                   Begin
                    TRDWAuthOptionTokenServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).TokenType       := GetTokenType;
                    TRDWAuthOptionTokenServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).GetTokenEvent   := eTokenEvent.Text;
                    TRDWAuthOptionTokenServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).TokenHash       := eTokenHash.Text;
                    TRDWAuthOptionTokenServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).ServerSignature := eServerSignature.Text;
                    TRDWAuthOptionTokenServer(RESTDWServiceNotification1.AuthenticationOptions.OptionParams).LifeCycle       := StrToInt(eLifeCycle.Text);
                   End;
                 End;
    Else
     RESTDWServiceNotification1.AuthenticationOptions.AuthorizationOption := rdwAONone;
   End;
   RESTDWServiceNotification1.ServicePort           := StrToInt(EdPortaDW.Text);
   RESTDWServiceNotification1.ForceWelcomeAccess    := cbForceWelcome.Checked;
   RESTDWServiceNotification1.Active                := True;
   If Not RESTDWServiceNotification1.Active Then
     Exit;
   PageControl1.ActivePage := TsLogs;
   HideApplication;
   Tupdatelogs.Enabled := cbUpdateLog.Checked;
   StatusButtons;
  End;
End;

procedure TRestDWForm.ButtonStartClick(Sender: TObject);
var
  Ini: TIniFile;
Begin
  If FileExists(FCfgName) Then
    DeleteFile(FCfgName);
  Ini := TIniFile.Create(FCfgName);
  If cbForceWelcome.Checked Then
   Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 1)
  Else
   Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 0);
  Ini.Free;
  StartServer;
End;

procedure TRestDWForm.ButtonStopClick(Sender: TObject);
begin
 Tupdatelogs.Enabled       := False;
 RESTDWServiceNotification1.Active := False;
 lbConnections.Clear;
 memoReq.Lines.Clear;
 StatusButtons;
 PageControl1.ActivePage   := TsConfigs;
 ShowApplication;
end;

procedure TRestDWForm.cbAuthOptionsChange(Sender: TObject);
begin
 pTokenAuth.Visible := cbAuthOptions.ItemIndex > 1;
 pBasicAuth.Visible := cbAuthOptions.ItemIndex = 1;
end;

procedure TRestDWForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := Not RESTDWServiceNotification1.Active;
 If Not CanClose Then
  Begin
   CanClose := Not Self.Visible;
   If CanClose Then
    CanClose := Application.MessageBox('Você deseja realmente sair do programa ?', 'Pergunta ?', Mb_IconQuestion + Mb_YesNo) = MrYes
   Else
    HideApplication;
   If CanClose Then
    RESTDWServiceNotification1.Active := False;
  End;
end;

procedure TRestDWForm.FormCreate(Sender: TObject);
begin
 labVersao.Caption := uDWConsts.DWVERSAO;
 FCfgName          := StringReplace(ExtractFileName(ParamStr(0)), '.exe', '', [RfReplaceAll]);
 FCfgName          := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini';
 PageControl1.ActivePage := TsConfigs;
end;

end.
