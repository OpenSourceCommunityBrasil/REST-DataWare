unit RestDWServerFormU;

Interface

Uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Winsock,
  USock,
  IniFiles,
  AppEvnts,
  StdCtrls,
  HTTPApp,
  ExtCtrls,
  Mask,
  Menus,
  URESTDWBase,
  ComCtrls,
  DB,
  IdComponent,
  IdBaseComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP, uDWJSONObject, uDWAbout, dwCGIRunner, dwISAPIRunner, jpeg;


type
  TRestDWForm = class(TForm)
    ButtonStart: TButton;
    ButtonStop: TButton;
    Label8: TLabel;
    Bevel3: TBevel;
    LSeguro: TLabel;
    CbPoolerState: TCheckBox;
    PageControl1: TPageControl;
    TsConfigs: TTabSheet;
    TsLogs: TTabSheet;
    MemoReq: TMemo;
    MemoResp: TMemo;
    Label19: TLabel;
    Label18: TLabel;
    RESTDWServiceNotification1: TRESTDWServiceNotification;
    RESTServicePooler1: TRESTServicePooler;
    tupdatelogs: TTimer;
    pmMenu: TPopupMenu;
    RestaurarAplicao1: TMenuItem;
    N5: TMenuItem;
    SairdaAplicao1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Image2: TImage;
    Panel1: TPanel;
    labPorta: TLabel;
    labUsuario: TLabel;
    labSenha: TLabel;
    lbPasta: TLabel;
    labNomeBD: TLabel;
    Label14: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    labConexao: TLabel;
    labDBConfig: TLabel;
    labSSL: TLabel;
    labVersao: TLabel;
    Panel4: TPanel;
    Image8: TImage;
    edURL: TEdit;
    cbAdaptadores: TComboBox;
    edPortaBD: TEdit;
    edUserNameBD: TEdit;
    edPasswordBD: TEdit;
    edPasta: TEdit;
    edBD: TEdit;
    cbDriver: TComboBox;
    ckUsaURL: TCheckBox;
    ePrivKeyFile: TEdit;
    eCertFile: TEdit;
    ePrivKeyPass: TMaskEdit;
    Label1: TLabel;
    Label7: TLabel;
    Label11: TLabel;
    edPortaDW: TEdit;
    cbForceWelcome: TCheckBox;
    cbUpdateLog: TCheckBox;
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
    EdDataSource: TEdit;
    Label4: TLabel;
    EdMonitor: TEdit;
    Label9: TLabel;
    cbOsAuthent: TCheckBox;
    eHostCertFile: TEdit;
    Label10: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CbAdaptadoresChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SairdaAplicao1Click(Sender: TObject);
    procedure RESTServicePooler1LastRequest(Value: string);
    procedure RESTServicePooler1LastResponse(Value: string);
    procedure TupdatelogsTimer(Sender: TObject);
    procedure CbDriverCloseUp(Sender: TObject);
    procedure CkUsaURLClick(Sender: TObject);
  Private
    { Private declarations }
    VLastRequest,
    VLastRequestB,
    VDatabaseName,
    FCfgName,
    VDatabaseIP,
    VUsername,
    VPassword    : string;
    procedure StartServer;
    procedure HideApplication;
    procedure ChangeStatusWindow;
  Public
    { Public declarations }
    Property Username     : String Read   VUsername     Write  VUsername;
    Property Password     : String Read   VPassword     Write  VPassword;
    Property DatabaseIP   : String Read   VDatabaseIP   Write  VDatabaseIP;
    Property DatabaseName : String Read   VDatabaseName Write  VDatabaseName;
  End;

var
  RestDWForm: TRestDWForm;

implementation

{$R *.dfm}

Uses
  ShellApi, ServerUtils, UDmService;

Function ServerIpIndex(Items: TStrings; ChooseIP: string): Integer;
var
  I: Integer;
Begin
  Result := -1;
  For I  := 0 To Items.Count - 1 Do
  Begin
    If Pos(ChooseIP, Items[I]) > 0 Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;

procedure TRestDWForm.ChangeStatusWindow;
Begin
  If Self.Visible Then
    SairdaAplicao1.Caption := 'Minimizar para a bandeja'
  Else
    SairdaAplicao1.Caption := 'Sair da Aplicação';
  Application.ProcessMessages;
End;

procedure TRestDWForm.HideApplication;
Begin
//  CtiPrincipal.Visible     := True;
//  Application.ShowMainForm := False;
  If Self <> Nil Then
    Self.Visible := False;
  Application.Minimize;
//  ShowWindow(GetHandleOnTaskBar, SW_HIDE);
  ChangeStatusWindow;
End;

procedure TRestDWForm.CkUsaURLClick(Sender: TObject);
Begin
  If CkUsaURL.Checked Then
  Begin
    CbAdaptadores.Visible := False;
    EdURL.Visible         := True;
  End
  Else
  Begin
    EdURL.Visible         := False;
    CbAdaptadores.Visible := True;
  End;
End;

procedure TRestDWForm.CbDriverCloseUp(Sender: TObject);
Var
 Ini : TIniFile;
Begin
  Ini                     := TIniFile.Create(FCfgName);
  Try
   CbAdaptadores.ItemIndex := ServerIpIndex(CbAdaptadores.Items, Ini.ReadString('BancoDados', 'Servidor', '127.0.0.1'));
   EdBD.Text               := Ini.ReadString('BancoDados', 'BD', 'EMPLOYEE.FDB');
   EdPasta.Text            := Ini.ReadString('BancoDados', 'Pasta', ExtractFilePath(ParamSTR(0)) + '..\');
   EdPortaBD.Text          := Ini.ReadString('BancoDados', 'PortaBD', '3050');
   EdUserNameBD.Text       := Ini.ReadString('BancoDados', 'UsuarioBD', 'SYSDBA');
   EdPasswordBD.Text       := Ini.ReadString('BancoDados', 'SenhaBD', 'masterkey');
   EdPortaDW.Text          := Ini.ReadString('BancoDados', 'PortaDW', '8082');
   EdUserNameDW.Text       := Ini.ReadString('BancoDados', 'UsuarioDW', 'testserver');
   EdPasswordDW.Text       := Ini.ReadString('BancoDados', 'SenhaDW', 'testserver');
   Case CbDriver.ItemIndex of
    0: // FireBird
      Begin
       LbPasta.Visible         := True;
       EdPasta.Visible         := True;
       DatabaseName            := EdPasta.Text + EdBD.Text;
      End;
    1: // MSSQL
      Begin
        EdBD.Text         := 'seubanco';
        LbPasta.Visible   := False;
        EdPasta.Visible   := False;
        EdPasta.Text      := EmptyStr;
        EdPortaBD.Text    := '1433';
        EdUserNameBD.Text := 'sa';
        EdPasswordBD.Text := EmptyStr;;
        DatabaseName      := EdBD.Text;
      End;
   End;
  Finally
   Ini.Free;
  End;
End;

procedure TRestDWForm.RESTServicePooler1LastRequest(Value: string);
Begin
  VLastRequest := Value;
End;

procedure TRestDWForm.RESTServicePooler1LastResponse(Value: string);
Begin
  VLastRequestB := Value;
End;

procedure TRestDWForm.SairdaAplicao1Click(Sender: TObject);
Begin
  Close;
End;

procedure TRestDWForm.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
Begin
  ButtonStart.Enabled   := Not RESTServicePooler1.Active;
  ButtonStop.Enabled    := RESTServicePooler1.Active;
  EdPortaDW.Enabled     := ButtonStart.Enabled;
  EdUserNameDW.Enabled  := ButtonStart.Enabled;
  EdPasswordDW.Enabled  := ButtonStart.Enabled;
  CbAdaptadores.Enabled := ButtonStart.Enabled;
  EdPortaBD.Enabled     := ButtonStart.Enabled;
  EdPasta.Enabled       := ButtonStart.Enabled;
  EdBD.Enabled          := ButtonStart.Enabled;
  EdUserNameBD.Enabled  := ButtonStart.Enabled;
  EdPasswordBD.Enabled  := ButtonStart.Enabled;
  EPrivKeyFile.Enabled  := ButtonStart.Enabled;
  EPrivKeyPass.Enabled  := ButtonStart.Enabled;
  ECertFile.Enabled     := ButtonStart.Enabled;
End;

procedure TRestDWForm.ButtonStartClick(Sender: TObject);
var
  Ini: TIniFile;
Begin
//  DWCGIRunner1.BaseFiles  := ExtractFilePath(ParamSTR(0));
//  DWCGIRunner1.PHPIniPath := ExtractFilePath(ParamSTR(0)) + 'php5\';
  If FileExists(FCfgName) Then
    DeleteFile(FCfgName);
  Ini := TIniFile.Create(FCfgName);
  If CkUsaURL.Checked Then
  Begin
    Ini.WriteString('BancoDados', 'Servidor', EdURL.Text);
  End
  Else
  Begin
    Ini.WriteString('BancoDados', 'Servidor', CbAdaptadores.Text);
    cbAdaptadores.onChange(cbAdaptadores);
  End;
  Ini.WriteInteger('BancoDados', 'DRIVER', cbDriver.ItemIndex);
  If ckUsaURL.Checked Then
   Ini.WriteInteger('BancoDados', 'USEDNS', 1)
  Else
   Ini.WriteInteger('BancoDados', 'USEDNS', 0);
  If cbUpdateLog.Checked Then
   Ini.WriteInteger('Configs', 'UPDLOG', 1)
  Else
   Ini.WriteInteger('Configs', 'UPDLOG', 0);
  Ini.WriteString('BancoDados', 'BD', EdBD.Text);
  Ini.WriteString('BancoDados', 'Pasta', EdPasta.Text);
  Ini.WriteString('BancoDados', 'PortaBD', EdPortaBD.Text);
  Ini.WriteString('BancoDados', 'PortaDW', EdPortaDW.Text);
  Ini.WriteString('BancoDados', 'UsuarioBD', EdUserNameBD.Text);
  Ini.WriteString('BancoDados', 'SenhaBD', EdPasswordBD.Text);
  Ini.WriteString('BancoDados', 'UsuarioDW', EdUserNameDW.Text);
  Ini.WriteString('BancoDados', 'SenhaDW', EdPasswordDW.Text);
  Ini.WriteString('BancoDados', 'DataSource', EdDataSource.Text);    // ODBC
  Ini.WriteInteger('BancoDados', 'OsAuthent', Integer(cbOsAuthent.Checked));
  Ini.WriteString('BancoDados', 'MonitorBy', EdMonitor.Text);
  Ini.WriteString('SSL', 'PKF', EPrivKeyFile.Text);
  Ini.WriteString('SSL', 'PKP', EPrivKeyPass.Text);
  Ini.WriteString('SSL', 'CF', ECertFile.Text);
  Ini.WriteString('SSL', 'HostCF', eHostCertFile.Text);
  If cbForceWelcome.Checked Then
   Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 1)
  Else
   Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 0);
  Ini.Free;
  VUsername := EdUserNameDW.Text;
  VPassword := EdPasswordDW.Text;
  StartServer;
End;

procedure TRestDWForm.ButtonStopClick(Sender: TObject);
Begin
  Tupdatelogs.Enabled       := False;
  RESTServicePooler1.Active := False;
  PageControl1.ActivePage   := TsConfigs;
End;

procedure TRestDWForm.CbAdaptadoresChange(Sender: TObject);
Begin
  VDatabaseIP := Trim(Copy(CbAdaptadores.Text, Pos('-', CbAdaptadores.Text) + 1, 100));
End;

procedure TRestDWForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Begin
 CanClose := Not RESTServicePooler1.Active;
 If Not CanClose Then
  Begin
   CanClose := Not Self.Visible;
   If CanClose Then
    CanClose := Application.MessageBox('Você deseja realmente sair do programa ?', 'Pergunta ?', Mb_IconQuestion + Mb_YesNo) = MrYes;
  End;
End;

procedure TRestDWForm.FormCreate(Sender: TObject);
Begin
  // define o nome do .ini de acordo c o EXE
  // dessa forma se quiser testar várias instâncias do servidor em
  // portas diferentes os arquivos não irão conflitar
  FCfgName                             := StringReplace(ExtractFileName(ParamStr(0)), '.exe', '', [RfReplaceAll]);
  FCfgName                             := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini';
  RESTServicePooler1.ServerMethodClass := TServerMethodDM;
  PageControl1.ActivePage              := TsConfigs;
End;

procedure TRestDWForm.FormShow(Sender: TObject);
var
  Ini:               TIniFile;
  VTag, I:           Integer;
  ANetInterfaceList: TNetworkInterfaceList;
Begin
 VTag := 0;
 If (GetNetworkInterfaces(ANetInterfaceList)) Then
  Begin
    CbAdaptadores.Items.Clear;
    For I := 0 To High(ANetInterfaceList) Do
    Begin
      CbAdaptadores.Items.Add('Placa #' + IntToStr(I) + ' - ' + ANetInterfaceList[I].AddrIP);
      If (I <= 1) or (Pos('127.0.0.1', ANetInterfaceList[I].AddrIP) > 0) Then
      Begin
        VDatabaseIP := ANetInterfaceList[I].AddrIP;
        VTag        := 1;
      End;
    End;
    CbAdaptadores.ItemIndex := VTag;
  End;
 Ini                     := TIniFile.Create(FCfgName);
 cbDriver.ItemIndex      := Ini.ReadInteger('BancoDados', 'DRIVER', 0);
 ckUsaURL.Checked        := Ini.ReadInteger('BancoDados', 'USEDNS', 0) = 1;
 If ServerIpIndex(CbAdaptadores.Items, Ini.ReadString('BancoDados', 'Servidor', '')) > -1 Then
  CbAdaptadores.ItemIndex := ServerIpIndex(CbAdaptadores.Items, Ini.ReadString('BancoDados', 'Servidor', ''))
 Else
  Begin
   If Ini.ReadString('BancoDados', 'Servidor', '') <> '' Then
    Begin
     cbAdaptadores.Items.Add(Ini.ReadString('BancoDados', 'Servidor', ''));
     cbAdaptadores.ItemIndex := cbAdaptadores.Items.Count -1;
    End;
  End;
 EdBD.Text                := Ini.ReadString('BancoDados',  'BD', 'EMPLOYEE.FDB');
 EdPasta.Text             := Ini.ReadString('BancoDados',  'Pasta', ExtractFilePath(ParamSTR(0)) + '..\');
 EdPortaBD.Text           := Ini.ReadString('BancoDados',  'PortaBD', '3050');
 EdPortaDW.Text           := Ini.ReadString('BancoDados',  'PortaDW', '8082');
 EdUserNameBD.Text        := Ini.ReadString('BancoDados',  'UsuarioBD', 'SYSDBA');
 EdPasswordBD.Text        := Ini.ReadString('BancoDados',  'SenhaBD', 'masterkey');
 EdUserNameDW.Text        := Ini.ReadString('BancoDados',  'UsuarioDW', 'testserver');
 EdPasswordDW.Text        := Ini.ReadString('BancoDados',  'SenhaDW', 'testserver');
 EdMonitor.Text           := Ini.ReadString('BancoDados',  'MonitorBy', 'Remote');  // ICO Menezes
 EdDataSource.Text        := Ini.ReadString('BancoDados',  'DataSource', 'SQL');
 cbOsAuthent.Checked      := Ini.ReadInteger('BancoDados', 'OsAuthent', 0) = 1;
 cbUpdateLog.Checked      := Ini.ReadInteger('Configs',    'UPDLOG', 1) = 1;
 EPrivKeyFile.Text        := Ini.ReadString('SSL',         'PKF', '');
 EPrivKeyPass.Text        := Ini.ReadString('SSL',         'PKP', '');
 ECertFile.Text           := Ini.ReadString('SSL',         'CF', '');
 eHostCertFile.Text       := Ini.ReadString('SSL',         'HostCF', '');
 cbForceWelcome.Checked   := Ini.ReadInteger('Configs',    'ForceWelcomeAccess', 0) = 1;
 Ini.Free;
End;

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
 If Not RESTServicePooler1.Active Then
  Begin
   RESTServicePooler1.AuthenticationOptions.AuthorizationOption := GetAuthOption;
   Case RESTServicePooler1.AuthenticationOptions.AuthorizationOption Of
    rdwAOBasic : Begin
                  TRDWAuthOptionBasic(RESTServicePooler1.AuthenticationOptions.OptionParams).Username := EdUserNameDW.Text;
                  TRDWAuthOptionBasic(RESTServicePooler1.AuthenticationOptions.OptionParams).Password := EdPasswordDW.Text;
                 End;
    rdwAOBearer,
    rdwAOToken : Begin
                  If RESTServicePooler1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
                   Begin
                    TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).TokenType       := GetTokenType;
                    TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).GetTokenEvent   := eTokenEvent.Text;
                    //TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).GetTokenRoutes  := [crPost];
                    TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).TokenHash       := eTokenHash.Text;
                    TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).ServerSignature := eServerSignature.Text;
                    TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).LifeCycle       := StrToInt(eLifeCycle.Text);
                   End
                  Else
                   Begin
                    TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).TokenType       := GetTokenType;
                    TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).GetTokenEvent   := eTokenEvent.Text;
                    //TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).GetTokenRoutes  := [crPost];
                    TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).TokenHash       := eTokenHash.Text;
                    TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).ServerSignature := eServerSignature.Text;
                    TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).LifeCycle       := StrToInt(eLifeCycle.Text);
                   End;
                 End;
    Else
     RESTServicePooler1.AuthenticationOptions.AuthorizationOption := rdwAONone;
   End;
   RESTServicePooler1.ServicePort           := StrToInt(EdPortaDW.Text);
   RESTServicePooler1.SSLPrivateKeyFile     := EPrivKeyFile.Text;
   RESTServicePooler1.SSLPrivateKeyPassword := EPrivKeyPass.Text;
   RESTServicePooler1.SSLCertFile           := ECertFile.Text;
   RESTServicePooler1.SSLRootCertFile       := eHostCertFile.Text;
   RESTServicePooler1.ForceWelcomeAccess    := cbForceWelcome.Checked;
   RESTServicePooler1.Active                := True;
   If Not RESTServicePooler1.Active Then
     Exit;
   PageControl1.ActivePage := TsLogs;
   HideApplication;
   Tupdatelogs.Enabled := cbUpdateLog.Checked;
  End;
 If RESTServicePooler1.Secure Then
  Begin
   LSeguro.Font.Color := ClBlue;
   LSeguro.Caption    := 'Seguro : Sim';
  End
 Else
  Begin
   LSeguro.Font.Color := ClRed;
   LSeguro.Caption    := 'Seguro : Não';
  End;
End;

procedure TRestDWForm.TupdatelogsTimer(Sender: TObject);
var
  VTempLastRequest, VTempLastRequestB: string;
Begin
  Tupdatelogs.Enabled := False;
  Try
    VTempLastRequest  := VLastRequest;
    VTempLastRequestB := VLastRequestB;
    If (VTempLastRequest <> '') Then
    Begin
      If MemoReq.Lines.Count > 0 Then
        If MemoReq.Lines[MemoReq.Lines.Count - 1] = VTempLastRequest Then
          Exit;
      If MemoReq.Lines.Count = 0 Then
        MemoReq.Lines.Add(Copy(VTempLastRequest, 1, 100))
      Else
        MemoReq.Lines[MemoReq.Lines.Count - 1] := Copy(VTempLastRequest, 1, 100);
      If Length(VTempLastRequest) > 1000 Then
        MemoReq.Lines[MemoReq.Lines.Count - 1] := MemoReq.Lines[MemoReq.Lines.Count - 1] + '...';
      If MemoResp.Lines.Count > 0 Then
        If MemoResp.Lines[MemoResp.Lines.Count - 1] = VTempLastRequestB Then
          Exit;
      If MemoResp.Lines.Count = 0 Then
        MemoResp.Lines.Add(Copy(VTempLastRequestB, 1, 100))
      Else
        MemoResp.Lines[MemoResp.Lines.Count - 1] := Copy(VTempLastRequestB, 1, 100);
      If Length(VTempLastRequest) > 1000 Then
        MemoResp.Lines[MemoResp.Lines.Count - 1] := MemoResp.Lines[MemoResp.Lines.Count - 1] + '...';
    End;
  Finally
    Tupdatelogs.Enabled := True;
  End;
End;

End.
