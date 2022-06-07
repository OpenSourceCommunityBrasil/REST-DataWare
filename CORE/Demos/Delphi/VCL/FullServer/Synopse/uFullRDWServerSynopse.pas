unit uFullRDWServerSynopse;

interface

uses
  SynCommons,
  mORMot,
  SynCrtSock,
  mORMotHttpServer,
  UDWJSONObject,
  ServerUtils,
  uDWConsts,
  inifiles,
  uSock,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uDWAbout, uRESTDWSynBase,
  Vcl.ComCtrls, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.AppEvnts;

type
  TRestDWForm = class(TForm)
    RESTDWServiceSynPooler1: TRESTDWServiceSynPooler;
    Panel2: TPanel;
    lSeguro: TLabel;
    ButtonStart: TButton;
    ButtonStop: TButton;
    cbPoolerState: TCheckBox;
    paTopo: TPanel;
    Image2: TImage;
    labSistema: TLabel;
    paPortugues: TPanel;
    Image3: TImage;
    paEspanhol: TPanel;
    Image4: TImage;
    paIngles: TPanel;
    Image5: TImage;
    PageControl1: TPageControl;
    tsConfigs: TTabSheet;
    Panel1: TPanel;
    Label1: TLabel;
    labPorta: TLabel;
    labUsuario: TLabel;
    labSenha: TLabel;
    lbPasta: TLabel;
    labNomeBD: TLabel;
    Label14: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    labConexao: TLabel;
    Label7: TLabel;
    labDBConfig: TLabel;
    labVersao: TLabel;
    Label4: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Panel3: TPanel;
    Image7: TImage;
    Panel4: TPanel;
    Image8: TImage;
    edPortaDW: TEdit;
    cbForceWelcome: TCheckBox;
    edURL: TEdit;
    cbAdaptadores: TComboBox;
    edPortaBD: TEdit;
    edUserNameBD: TEdit;
    edPasswordBD: TEdit;
    edPasta: TEdit;
    edBD: TEdit;
    cbDriver: TComboBox;
    ckUsaURL: TCheckBox;
    EdDataSource: TEdit;
    EdMonitor: TEdit;
    cbOsAuthent: TCheckBox;
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
    tsLogs: TTabSheet;
    Label19: TLabel;
    Label18: TLabel;
    memoReq: TMemo;
    memoResp: TMemo;
    tupdatelogs: TTimer;
    ctiPrincipal: TTrayIcon;
    pmMenu: TPopupMenu;
    RestaurarAplicao1: TMenuItem;
    N5: TMenuItem;
    SairdaAplicao1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure tupdatelogsTimer(Sender: TObject);
    procedure SairdaAplicao1Click(Sender: TObject);
    procedure RestaurarAplicao1Click(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbAuthOptionsChange(Sender: TObject);
    procedure cbDriverCloseUp(Sender: TObject);
    procedure cbAdaptadoresChange(Sender: TObject);
    procedure ctiPrincipalDblClick(Sender: TObject);
    procedure RESTDWServiceSynPooler1LastRequest(Value: string);
    procedure RESTDWServiceSynPooler1LastResponse(Value: string);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
  private
   { Private declarations }
   VLastRequest,
   VLastRequestB,
   VDatabaseName,
   FCfgName,
   VDatabaseIP,
   VUsername,
   VPassword      : String;
   procedure StartServer;
   Function  GetHandleOnTaskBar: THandle;
   procedure ChangeStatusWindow;
   procedure HideApplication;
   Function  OnRequest(Ctxt: THttpServerRequest): cardinal;
  Public
   procedure ShowBalloonTips(IconMessage: Integer = 0; MessageValue: string = '');
   procedure ShowApplication;
   Property  Username     : String Read   VUsername     Write  VUsername;
   Property  Password     : String Read   VPassword     Write  VPassword;
   Property  DatabaseIP   : String Read   VDatabaseIP   Write  VDatabaseIP;
   Property  DatabaseName : String Read   VDatabaseName Write  VDatabaseName;
   procedure Locale_Portugues( pLocale : String );
  End;

var
  RestDWForm: TRestDWForm;

implementation

uses uDmService;

{$R *.dfm}

Function ServerIpIndex(Items: TStrings; ChooseIP: string): Integer;
Var
 I : Integer;
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

procedure TRestDWForm.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
begin
  ButtonStart.Enabled   := Not RESTDWServiceSynPooler1.Active;
  ButtonStop.Enabled    := RESTDWServiceSynPooler1.Active;
  EdPortaDW.Enabled     := ButtonStart.Enabled;
  EdUserNameDW.Enabled  := ButtonStart.Enabled;
  EdPasswordDW.Enabled  := ButtonStart.Enabled;
  CbAdaptadores.Enabled := ButtonStart.Enabled;
  EdPortaBD.Enabled     := ButtonStart.Enabled;
  EdPasta.Enabled       := ButtonStart.Enabled;
  EdBD.Enabled          := ButtonStart.Enabled;
  EdUserNameBD.Enabled  := ButtonStart.Enabled;
  EdPasswordBD.Enabled  := ButtonStart.Enabled;
  EdMonitor.Enabled     := ButtonStart.Enabled;
  EdDataSource.Enabled  := ButtonStart.Enabled;
  cbOsAuthent.Enabled   := ButtonStart.Enabled;
end;

procedure TRestDWForm.ButtonStartClick(Sender: TObject);
var
  Ini: TIniFile;
Begin
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
  Ini.WriteInteger('BancoDados', 'OsAuthent', cbOsAuthent.Checked.ToInteger);
  Ini.WriteString('BancoDados', 'MonitorBy', EdMonitor.Text);
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
begin
  Tupdatelogs.Enabled       := False;
  RESTDWServiceSynPooler1.Active := False;
  PageControl1.ActivePage   := TsConfigs;
  ShowApplication;
end;

procedure TRestDWForm.cbAdaptadoresChange(Sender: TObject);
begin
  VDatabaseIP := Trim(Copy(CbAdaptadores.Text, Pos('-', CbAdaptadores.Text) + 1, 100));
end;

procedure TRestDWForm.cbAuthOptionsChange(Sender: TObject);
begin
 pTokenAuth.Visible := cbAuthOptions.ItemIndex > 1;
 pBasicAuth.Visible := cbAuthOptions.ItemIndex = 1;
end;

procedure TRestDWForm.cbDriverCloseUp(Sender: TObject);
Var
 Ini : TIniFile;
Begin
  Ini                     := TIniFile.Create(FCfgName);
  Try
   CbAdaptadores.ItemIndex := ServerIpIndex(CbAdaptadores.Items,
                                            Ini.ReadString('BancoDados', 'Servidor', '127.0.0.1'));
   EdBD.Text               := Ini.ReadString('BancoDados', 'BD',         'EMPLOYEE.FDB');
   EdPasta.Text            := Ini.ReadString('BancoDados', 'Pasta',      ExtractFilePath(ParamSTR(0)) + '..\');
   EdPortaBD.Text          := Ini.ReadString('BancoDados', 'PortaBD',    '3050');
   EdUserNameBD.Text       := Ini.ReadString('BancoDados', 'UsuarioBD',  'SYSDBA');
   EdPasswordBD.Text       := Ini.ReadString('BancoDados', 'SenhaBD',    'masterkey');
   EdPortaDW.Text          := Ini.ReadString('BancoDados', 'PortaDW',    '8082');
   EdUserNameDW.Text       := Ini.ReadString('BancoDados', 'UsuarioDW',  'testserver');
   EdPasswordDW.Text       := Ini.ReadString('BancoDados', 'SenhaDW',    'testserver');
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
        EdPasswordBD.Text := EmptyStr;
        DatabaseName      := EdBD.Text;
      End;
    2: // MySQL
      Begin

      end;
    3: // PG
      Begin

      end;
    4: // ODBC
      Begin

      End;
   End;
  Finally
   Ini.Free;
  End;
End;

Procedure TRestDWForm.ChangeStatusWindow;
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

procedure TRestDWForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose := Not RESTDWServiceSynPooler1.Active;
 If Not CanClose Then
  Begin
    CanClose := Not Self.Visible;
    If CanClose Then
      CanClose := Application.MessageBox('Você deseja realmente sair do programa ?', 'Pergunta ?', Mb_IconQuestion + Mb_YesNo) = MrYes
    Else
      HideApplication;
  End;
end;

procedure TRestDWForm.FormCreate(Sender: TObject);
begin
 labVersao.Caption := uDWConsts.DWVERSAO;
 FCfgName                             := StringReplace(ExtractFileName(ParamStr(0)), '.exe', '', [RfReplaceAll]);
 FCfgName                             := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini';
 RESTDWServiceSynPooler1.ServerMethodClass := TServerMethodDM;
 RESTDWServiceSynPooler1.RootPath          := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
 PageControl1.ActivePage              := TsConfigs;
end;
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
 cbForceWelcome.Checked   := Ini.ReadInteger('Configs',    'ForceWelcomeAccess', 0) = 1;
 Ini.Free;
End;

Function TRestDWForm.GetHandleOnTaskBar: THandle;
Begin
 {$IFDEF COMPILER11_UP}
 If Application.MainFormOnTaskBar And Assigned(Application.MainForm) Then
  Result := Application.MainForm.Handle
 Else
 {$ENDIF COMPILER11_UP}
  Result := Application.Handle;
End;

procedure TRestDWForm.HideApplication;
begin
  CtiPrincipal.Visible     := True;
  Application.ShowMainForm := False;
  If Self <> Nil Then
    Self.Visible := False;
  Application.Minimize;
  ShowWindow(GetHandleOnTaskBar, SW_HIDE);
  ChangeStatusWindow;
end;

procedure TRestDWForm.Locale_Portugues(pLocale: String);
begin
     if pLocale = 'portugues' then
     begin
        paPortugues.Color   := clWhite;
        paEspanhol.Color    := $002a2a2a;
        paIngles.Color      := $002a2a2a;

        labConexao.Caption  := ' .: CONFIGURAÇÃO DO SERVIDOR';
        labDBConfig.Caption      := ' .: CONFIGURAÇÃO DO BANCO DE DADOS';
//        labSSL.Caption      := ' .: CONFIGURAÇÃO DO SSL';
        //cbxCompressao.Caption := 'Compressão';
     end
     else
     if pLocale = 'ingles' then
      begin
        paPortugues.Color   := $002a2a2a;
        paEspanhol.Color    := $002a2a2a;
        paIngles.Color      := clWhite;
        labConexao.Caption  := ' .: SQL COMMAND';
        labDBConfig.Caption      := ' .: SERVER CONFIGURATION';
//        labSSL.Caption      := ' .: SSL CONFIGURATION';
        //cbxCompressao.Caption := 'Compresión';
      end
     else
     if pLocale = 'espanhol' then
     begin
        paPortugues.Color   := $002a2a2a;
        paEspanhol.Color    := clWhite;
        paIngles.Color      := $002a2a2a;

        labConexao.Caption  := ' .: CONFIGURATIÓN DEL SERVIDOR';
        labDBConfig.Caption      := ' .: CONFIGURATIÓN DEL BANCO DE DADOS';
//        labSSL.Caption      := ' .: CONFIGURATIÓN DEL SSL';

        //cbxCompressao.Caption := 'Compressão';
     end;
end;

Function TRestDWForm.OnRequest(Ctxt: THttpServerRequest): cardinal;
Var

 Params : TDWParams;

Begin

 Result := 200;
 Ctxt.OutContentType := 'text/html; charset=UTF-8';
// Ctxt.URL
 If lowercase(Ctxt.URL) = '/api/servertime' Then
  Begin
   Ctxt.OutContentType := 'application/json';
   Params := TDWParams.Create;
   Params.CreateParam('result', DateToStr(Now));
   Ctxt.OutContent := SockString(Params.ToJSON);
   Params.Free;
  End
 Else
   Ctxt.OutContent := SockString('<!doctype html>' +
                                 '<html>' +
                                 '  <head>' +
                                 '    <title>REST Dataware on Synopse</title>' +
                                 '  </head>' +
                                 '  <body>' +
                                 '    <p>Server Online.</p>' +
                                 '  </body>' +
                                 '</html>');
End;

procedure TRestDWForm.RestaurarAplicao1Click(Sender: TObject);
begin
 ShowApplication;
end;

procedure TRestDWForm.RESTDWServiceSynPooler1LastRequest(Value: string);
begin
 VLastRequest := Value;
end;

procedure TRestDWForm.RESTDWServiceSynPooler1LastResponse(Value: string);
begin
  VLastRequestB := Value;
end;

procedure TRestDWForm.SairdaAplicao1Click(Sender: TObject);
begin
 Close;
end;

procedure TRestDWForm.ShowApplication;
begin
  CtiPrincipal.Visible     := False;
  Application.ShowMainForm := True;
  If Self <> Nil Then
  Begin
    Self.Visible     := True;
    Self.WindowState := WsNormal;
  End;
  ShowWindow(GetHandleOnTaskBar, SW_SHOW);
  ChangeStatusWindow;
end;

procedure TRestDWForm.ShowBalloonTips(IconMessage: Integer;
  MessageValue: string);
begin
  case IconMessage of
    0:
      CtiPrincipal.BalloonFlags := BfInfo;
    1:
      CtiPrincipal.BalloonFlags := BfWarning;
    2:
      CtiPrincipal.BalloonFlags := BfError;
  Else
    CtiPrincipal.BalloonFlags := BfInfo;
  End;
  CtiPrincipal.BalloonTitle := RestDWForm.Caption;
  CtiPrincipal.BalloonHint  := MessageValue;
  CtiPrincipal.ShowBalloonHint;
  Application.ProcessMessages;
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
 If Not RESTDWServiceSynPooler1.Active Then
  Begin
   RESTDWServiceSynPooler1.AuthenticationOptions.AuthorizationOption := GetAuthOption;
   Case RESTDWServiceSynPooler1.AuthenticationOptions.AuthorizationOption Of
    rdwAOBasic : Begin
                  TRDWAuthOptionBasic(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).Username := EdUserNameDW.Text;
                  TRDWAuthOptionBasic(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).Password := EdPasswordDW.Text;
                 End;
    rdwAOBearer,
    rdwAOToken : Begin
                  If RESTDWServiceSynPooler1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
                   Begin
                    TRDWAuthOptionBearerServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).TokenType       := GetTokenType;
                    TRDWAuthOptionBearerServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).GetTokenEvent   := eTokenEvent.Text;
                    //TRDWAuthOptionBearerServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).GetTokenRoutes  := [crPost];
                    TRDWAuthOptionBearerServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).TokenHash       := eTokenHash.Text;
                    TRDWAuthOptionBearerServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).ServerSignature := eServerSignature.Text;
                    TRDWAuthOptionBearerServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).LifeCycle       := StrToInt(eLifeCycle.Text);
                   End
                  Else
                   Begin
                    TRDWAuthOptionTokenServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).TokenType       := GetTokenType;
                    TRDWAuthOptionTokenServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).GetTokenEvent   := eTokenEvent.Text;
                    //TRDWAuthOptionTokenServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).GetTokenRoutes  := [crPost];
                    TRDWAuthOptionTokenServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).TokenHash       := eTokenHash.Text;
                    TRDWAuthOptionTokenServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).ServerSignature := eServerSignature.Text;
                    TRDWAuthOptionTokenServer(RESTDWServiceSynPooler1.AuthenticationOptions.OptionParams).LifeCycle       := StrToInt(eLifeCycle.Text);
                   End;
                 End;
    Else
     RESTDWServiceSynPooler1.AuthenticationOptions.AuthorizationOption := rdwAONone;
   End;
   RESTDWServiceSynPooler1.ServicePort           := StrToInt(EdPortaDW.Text);
   RESTDWServiceSynPooler1.ForceWelcomeAccess    := cbForceWelcome.Checked;
   RESTDWServiceSynPooler1.Active                := True;
   If Not RESTDWServiceSynPooler1.Active Then
     Exit;
   PageControl1.ActivePage := TsLogs;
   HideApplication;
   Tupdatelogs.Enabled := cbUpdateLog.Checked;
  End;
 If RESTDWServiceSynPooler1.UseSSL Then
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

procedure TRestDWForm.tupdatelogsTimer(Sender: TObject);
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

end.
