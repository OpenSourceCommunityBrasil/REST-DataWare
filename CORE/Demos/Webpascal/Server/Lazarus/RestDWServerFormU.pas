unit RestDWServerFormU;

Interface

Uses LCL, LCLIntf, LCLType, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uSock, IniFiles, IBConnection, db, uRESTDWBase,
  ComCtrls, MaskEdit, StdCtrls, ExtCtrls, Menus,
  IdComponent, IdBaseComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type

  { TRestDWForm }

  TRestDWForm = class(TForm)
    Bevel3: TBevel;
    ButtonStart: TButton;
    ButtonStop: TButton;
    cbAdaptadores: TComboBox;
    cbAuthOptions: TComboBox;
    cbDriver: TComboBox;
    cbForceWelcome: TCheckBox;
    cbPoolerState: TCheckBox;
    cbTokenType: TComboBox;
    cbUpdateLog: TCheckBox;
    ckUsaURL: TCheckBox;
    ctiPrincipal: TTrayIcon;
    eCertFile: TEdit;
    edBD: TEdit;
    edPasswordBD: TEdit;
    edPasswordDW: TEdit;
    edPasswordDW1: TEdit;
    edPasta: TEdit;
    edPortaBD: TEdit;
    edPortaDW: TEdit;
    edURL: TEdit;
    edUserNameBD: TEdit;
    edUserNameDW: TEdit;
    edUserNameDW1: TEdit;
    eHostCertFile: TEdit;
    eLifeCycle: TEdit;
    ePrivKeyFile: TEdit;
    ePrivKeyPass: TMaskEdit;
    eServerSignature: TEdit;
    eTokenEvent: TEdit;
    eTokenHash: TEdit;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image8: TImage;
    labConexao: TLabel;
    labDBConfig: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    labNomeBD: TLabel;
    labPorta: TLabel;
    labSenha: TLabel;
    labSistema: TLabel;
    labSSL: TLabel;
    labUsuario: TLabel;
    labVersao: TLabel;
    lbPasta: TLabel;
    lSeguro: TLabel;
    memoReq: TMemo;
    memoResp: TMemo;
    N5: TMenuItem;
    paEspanhol: TPanel;
    PageControl1: TPageControl;
    paIngles: TPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    paPortugues: TPanel;
    paTopo: TPanel;
    pBasicAuth: TPanel;
    pBasicAuth1: TPanel;
    pmMenu: TPopupMenu;
    pTokenAuth: TPanel;
    RestaurarAplicao1: TMenuItem;
    RESTDWServiceNotification1: TRESTDWServiceNotification;
    RESTServicePooler1: TRESTServicePooler;
    SairdaAplicao1: TMenuItem;
    tsConfigs: TTabSheet;
    tsLogs: TTabSheet;
    tupdatelogs: TTimer;
    procedure cbAuthOptionsChange(Sender: TObject);
    procedure cbDriverCloseUp(Sender: TObject);
    procedure ctiPrincipalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbAdaptadoresChange(Sender: TObject);
    procedure ctiPrincipalDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SairdaAplicao1Click(Sender: TObject);
    procedure RestaurarAplicao1Click(Sender: TObject);
    procedure RESTServicePooler1LastRequest(Value: string);
    procedure RESTServicePooler1LastResponse(Value: string);
    procedure tupdatelogsTimer(Sender: TObject);
  Private
   {Private declarations}
   vLastRequest,
   vLastRequestB,
   vDatabaseName,
   FCfgName,
   vDatabaseIP,
   vUsername,
   vPassword  : String;
   Procedure StartServer;
   Function  GetHandleOnTaskBar : THandle;
   Procedure ChangeStatusWindow;
   Procedure HideApplication;
  Public
   {Public declarations}
   Procedure ShowBalloonTips(IconMessage : Integer = 0; MessageValue : String = '');
   Procedure ShowApplication;
   Property  Username     : String Read vUsername     Write vUsername;
   Property  Password     : String Read vPassword     Write vPassword;
   Property  DatabaseIP   : String Read vDatabaseIP   Write vDatabaseIP;
   Property  DatabaseName : String Read vDatabaseName Write vDatabaseName;
  End;

var
  RestDWForm : TRestDWForm;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

uses
 {$IFNDEF FPC}ShellApi,{$ENDIF}ServerUtils, uDWConsts, uDmService;

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

Function TRestDWForm.GetHandleOnTaskBar : THandle;
Begin
 {$IFDEF COMPILER11_UP}
 If Application.MainFormOnTaskBar And Assigned(Application.MainForm) Then
  Result := Application.MainForm.Handle
 Else
 {$ENDIF COMPILER11_UP}
  Result := Application.MainForm.Handle
End;

Procedure TRestDWForm.ChangeStatusWindow;
Begin
 if Self.Visible then
  SairdaAplicao1.Caption := 'Minimizar para a bandeja'
 Else
  SairdaAplicao1.Caption := 'Sair da Aplicação';
 Application.ProcessMessages;
End;

procedure TRestDWForm.ctiPrincipalDblClick(Sender: TObject);
begin
 ShowApplication;
end;

Procedure TRestDWForm.HideApplication;
Begin
 ctiPrincipal.Visible := True;
 Application.ShowMainForm := False;
 If Self <> Nil Then
  Self.Visible := False;
 Application.Minimize;
 ShowWindow(GetHandleOnTaskBar, 0);
 ChangeStatusWindow;
End;

procedure TRestDWForm.RestaurarAplicao1Click(Sender: TObject);
begin
 ShowApplication;
end;

procedure TRestDWForm.RESTServicePooler1LastRequest(Value: string);
begin
 vLastRequest := Value;
end;

procedure TRestDWForm.RESTServicePooler1LastResponse(Value: string);
begin
 vLastRequestB := Value;
end;

procedure TRestDWForm.SairdaAplicao1Click(Sender: TObject);
begin
 Close;
end;

Procedure TRestDWForm.ShowApplication;
Begin
 ctiPrincipal.Visible := False;
 Application.ShowMainForm    := True;
 If Self <> Nil Then
  Begin
   Self.Visible     := True;
   Self.WindowState := wsNormal;
  End;
 ShowWindow(GetHandleOnTaskBar, 5);
 ChangeStatusWindow;
End;

Procedure TRestDWForm.ShowBalloonTips(IconMessage : Integer = 0; MessageValue : String = '');
Begin
 Case IconMessage Of
  0 : ctiPrincipal.BalloonFlags := bfInfo;
  1 : ctiPrincipal.BalloonFlags := bfWarning;
  2 : ctiPrincipal.BalloonFlags := bfError;
  Else
   ctiPrincipal.BalloonFlags := bfInfo;
 End;
 ctiPrincipal.BalloonTitle := RestDWForm.Caption;
 ctiPrincipal.BalloonHint  := MessageValue;
 ctiPrincipal.ShowBalloonHint;
 Application.ProcessMessages;
End;

Procedure TRestDWForm.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
Begin
 ButtonStart.Enabled   := Not RESTServicePooler1.Active;
 ButtonStop.Enabled    := RESTServicePooler1.Active;
 edPortaDW.Enabled     := ButtonStart.Enabled;
 edUserNameDW.Enabled  := ButtonStart.Enabled;
 edPasswordDW.Enabled  := ButtonStart.Enabled;
 cbAdaptadores.Enabled := ButtonStart.Enabled;
 edPortaBD.Enabled     := ButtonStart.Enabled;
 edPasta.Enabled       := ButtonStart.Enabled;
 edBD.Enabled          := ButtonStart.Enabled;
 edUserNameBD.Enabled  := ButtonStart.Enabled;
 edPasswordBD.Enabled  := ButtonStart.Enabled;
 ePrivKeyFile.Enabled  := ButtonStart.Enabled;
 ePrivKeyPass.Enabled  := ButtonStart.Enabled;
 eCertFile.Enabled     := ButtonStart.Enabled;
End;

procedure TRestDWForm.ButtonStartClick(Sender: TObject);
Var
 ini       : TIniFile;
Begin
 If FileExists(FCfgName) Then
  DeleteFile(FCfgName);
 ini       := TIniFile.Create(FCfgName);
 ini.WriteString('BancoDados', 'Servidor',  cbAdaptadores.Text);//  '127.0.0.1');
 ini.WriteString('BancoDados', 'BD',        edBD.Text);
 ini.WriteString('BancoDados', 'Pasta',     edPasta.Text);
 ini.WriteString('BancoDados', 'PortaDB',   edPortaBD.Text);
 ini.WriteString('BancoDados', 'PortaDW',   edPortaDW.Text);
 ini.WriteString('BancoDados', 'UsuarioBD', edUserNameBD.Text);
 ini.WriteString('BancoDados', 'SenhaBD',   edPasswordBD.Text);
 ini.WriteString('BancoDados', 'UsuarioDW', edUserNameDW.Text);
 ini.WriteString('BancoDados', 'SenhaDW',   edPasswordDW.Text);
 ini.WriteString('SSL',        'PKF',       ePrivKeyFile.Text);
 ini.WriteString('SSL',        'PKP',       ePrivKeyPass.Text);
 ini.WriteString('SSL',        'CF',        eCertFile.Text);
 If cbForceWelcome.Checked Then
  Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 1)
 Else
  Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 0);
 If cbUpdateLog.Checked Then
  Ini.WriteInteger('Configs', 'UPDLOG', 1)
 Else
  Ini.WriteInteger('Configs', 'UPDLOG', 0);
 ini.Free;
 vUsername := edUserNameDW.Text;
 vPassword := edPasswordDW.Text;
 StartServer;
End;

procedure TRestDWForm.ButtonStopClick(Sender: TObject);
begin
 tupdatelogs.Enabled       := False;
 RESTServicePooler1.Active := False;
 PageControl1.ActivePage := tsConfigs;
 ShowApplication;
end;

Procedure TRestDWForm.cbAdaptadoresChange(Sender: TObject);
Begin
 vDatabaseIP := Trim(Copy(cbAdaptadores.Text, Pos('-' , cbAdaptadores.Text ) + 1 , 100));
End;

procedure TRestDWForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := Not RESTServicePooler1.Active;
 If Not CanClose Then
  Begin
   CanClose := Not Self.Visible;
   If CanClose Then
    CanClose := Application.MessageBox('Você deseja realmente sair do programa ?',
                                       'Pergunta ?', mb_IconQuestion + mb_YesNo) = mrYes
   Else
    HideApplication;
  End;
end;

Procedure TRestDWForm.FormCreate(Sender: TObject);
Begin
 // define o nome do .ini de acordo c o EXE
 // dessa forma se quiser testar várias instâncias do servidor em
 // portas diferentes os arquivos não irão conflitar
 labVersao.Caption := uDWConsts.DWVERSAO;
 FCfgName := StringReplace(ExtractFileName(ParamStr(0) ), '.exe' , '' , [rfReplaceAll]);
 FCfgName := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini' ;
 RESTServicePooler1.ServerMethodClass := TServerMethodDM;
 PageControl1.ActivePage              := tsConfigs;
End;

procedure TRestDWForm.ctiPrincipalClick(Sender: TObject);
begin

end;

procedure TRestDWForm.cbDriverCloseUp(Sender: TObject);
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

procedure TRestDWForm.cbAuthOptionsChange(Sender: TObject);
begin
 pTokenAuth.Visible := cbAuthOptions.ItemIndex > 1;
 pBasicAuth.Visible := cbAuthOptions.ItemIndex = 1;
end;

procedure TRestDWForm.FormShow(Sender: TObject);
Var
 ini               : TIniFile;
 vTag, i           : Integer;
 aNetInterfaceList : tNetworkInterfaceList;
 Function ServerIpIndex(Items : TStrings; ChooseIP : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Items.Count -1 Do
   Begin
    If Pos(ChooseIP, Items[I]) > 0 Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
 vTag := 0;
 If (GetNetworkInterfaces(aNetInterfaceList)) THen
  Begin
   cbAdaptadores.Items.Clear;
   For i := 0 to High (aNetInterfaceList) do
    Begin
     cbAdaptadores.Items.Add( 'Placa #' + IntToStr( i ) + ' - ' + aNetInterfaceList[i].AddrIP);
     If ( i <= 1 ) or ( Pos( '127.0.0.1' , aNetInterfaceList[i].AddrIP ) > 0 ) then
      Begin
       vDatabaseIP := aNetInterfaceList[i].AddrIP;
       vTag        := 1;
      End;
    End;
   cbAdaptadores.ItemIndex := vTag;
  End;
 If cbAdaptadores.Items.Count > 0 Then
  Begin
   vTag        := 0;
   vDatabaseIP := aNetInterfaceList[vTag].AddrIP;
   cbAdaptadores.ItemIndex := vTag;
  End;
 ini                     := TIniFile.Create(FCfgName);
 cbDriver.ItemIndex      := Ini.ReadInteger('BancoDados', 'DRIVER', 0);
 cbAdaptadores.ItemIndex := ServerIpIndex(cbAdaptadores.Items,
                            ini.ReadString('BancoDados', 'Servidor',  '127.0.0.1'));
 edBD.Text               := ini.ReadString('BancoDados', 'BD',        'EMPLOYEE.FDB');
 edPasta.Text            := ini.ReadString('BancoDados', 'Pasta',     ExtractFilePath(ParamSTR(0)) + '..\');
 edPortaBD.Text          := ini.ReadString('BancoDados', 'PortaBD',   '3050');
 edPortaDW.Text          := ini.ReadString('BancoDados', 'PortaDW',   '8082' );
 edUserNameBD.Text       := ini.ReadString('BancoDados', 'UsuarioBD', 'SYSDBA');
 edPasswordBD.Text       := ini.ReadString('BancoDados', 'SenhaBD',   'masterkey');
 edUserNameDW.Text       := ini.ReadString('BancoDados', 'UsuarioDW', 'testserver');
 edPasswordDW.Text       := ini.ReadString('BancoDados', 'SenhaDW',   'testserver');
 ePrivKeyFile.Text       := ini.ReadString('SSL',        'PKF',       '');
 ePrivKeyPass.Text       := ini.ReadString('SSL',        'PKP',       '');
 eCertFile.Text          := ini.ReadString('SSL',        'CF',        '');
 cbForceWelcome.Checked   := Ini.ReadInteger('Configs', 'ForceWelcomeAccess', 0) = 1;
 cbUpdateLog.Checked      := Ini.ReadInteger('Configs', 'UPDLOG', 1) = 1;
 ini.Free;
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
                   TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).TokenHash       := eTokenHash.Text;
                   TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).ServerSignature := eServerSignature.Text;
                   TRDWAuthOptionBearerServer(RESTServicePooler1.AuthenticationOptions.OptionParams).LifeCycle       := StrToInt(eLifeCycle.Text);
                  End
                 Else
                  Begin
                   TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).TokenType       := GetTokenType;
                   TRDWAuthOptionTokenServer(RESTServicePooler1.AuthenticationOptions.OptionParams).GetTokenEvent   := eTokenEvent.Text;
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

procedure TRestDWForm.tupdatelogsTimer(Sender: TObject);
Var
 vTempLastRequest,
 vTempLastRequestB : String;
begin
 tupdatelogs.Enabled := False;
 Try
  vTempLastRequest  := vLastRequest;
  vTempLastRequestB := vLastRequestB;
  If (vTempLastRequest <> '') Then
   Begin
    If memoReq.Lines.Count > 0 Then
     If memoReq.Lines[memoReq.Lines.Count -1] = vTempLastRequest Then
      Exit;
    If memoReq.Lines.Count = 0 Then
     memoReq.Lines.Add(Copy(vTempLastRequest, 1, 100))
    Else
     memoReq.Lines[memoReq.Lines.Count -1] := Copy(vTempLastRequest, 1, 100);
    If Length(vTempLastRequest) > 1000 Then
     memoReq.Lines[memoReq.Lines.Count -1] := memoReq.Lines[memoReq.Lines.Count -1] + '...';
    If memoResp.Lines.Count > 0 Then
     If memoResp.Lines[memoResp.Lines.Count -1] = vTempLastRequestB Then
      Exit;
    If memoResp.Lines.Count = 0 Then
     memoResp.Lines.Add(Copy(vTempLastRequestB, 1, 100))
    Else
     memoResp.Lines[memoResp.Lines.Count -1] := Copy(vTempLastRequestB, 1, 100);
    If Length(vTempLastRequest) > 1000 Then
     memoResp.Lines[memoResp.Lines.Count -1] := memoResp.Lines[memoResp.Lines.Count -1] + '...';
   End;
 Finally
  tupdatelogs.Enabled := True;
 End;
end;

end.

