unit RestDWServerFormU;

Interface

Uses LCL, LCLIntf, LCLType, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, winsock, uSock, IniFiles, IBConnection, db, uRESTDWBase,
  ServerMethodsUnit1, ComCtrls, MaskEdit, StdCtrls, ExtCtrls, Menus,
  IdComponent, IdBaseComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type

  { TRestDWForm }

  TRestDWForm = class(TForm)
    ButtonStart: TButton;
    ButtonStop: TButton;
    Label8: TLabel;
    Bevel3: TBevel;
    lSeguro: TLabel;
    cbPoolerState: TCheckBox;
    PageControl1: TPageControl;
    tsConfigs: TTabSheet;
    tsLogs: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label12: TLabel;
    Label14: TLabel;
    Label6: TLabel;
    Image1: TImage;
    Label5: TLabel;
    Bevel4: TBevel;
    Label4: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    edPortaDW: TEdit;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    cbAdaptadores: TComboBox;
    edPortaBD: TEdit;
    edUserNameBD: TEdit;
    edPasswordBD: TEdit;
    edPasta: TEdit;
    edBD: TEdit;
    ePrivKeyFile: TEdit;
    eCertFile: TEdit;
    ePrivKeyPass: TMaskEdit;
    ApplicationEvents1: TApplicationProperties;
    ctiPrincipal: TTrayIcon;
    pmMenu: TPopupMenu;
    RestaurarAplicao1: TMenuItem;
    N5: TMenuItem;
    SairdaAplicao1: TMenuItem;
    memoReq: TMemo;
    memoResp: TMemo;
    Label19: TLabel;
    Label18: TLabel;
    RESTServicePooler1: TRESTServicePooler;
    tupdatelogs: TTimer;
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
  ShellApi, uDmService;

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
 FCfgName := StringReplace(ExtractFileName(ParamStr(0) ), '.exe' , '' , [rfReplaceAll]);
 FCfgName := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini' ;
 RESTServicePooler1.ServerMethodClass := TServerMethodDM;
 PageControl1.ActivePage              := tsConfigs;
End;

procedure TRestDWForm.ctiPrincipalClick(Sender: TObject);
begin

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
 ini                     := TIniFile.Create(FCfgName);
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
 ini.Free;
End;

procedure TRestDWForm.StartServer;
begin
 If Not RESTServicePooler1.Active Then
  Begin
   RESTServicePooler1.ServerParams.UserName := edUserNameDW.Text;
   RESTServicePooler1.ServerParams.Password := edPasswordDW.Text;
   RESTServicePooler1.ServicePort           := StrToInt(edPortaDW.Text);
   RESTServicePooler1.SSLPrivateKeyFile     := ePrivKeyFile.Text;
   RESTServicePooler1.SSLPrivateKeyPassword := ePrivKeyPass.Text;
   RESTServicePooler1.SSLCertFile           := eCertFile.Text;
   RESTServicePooler1.Active                := True;
   If Not RESTServicePooler1.Active Then
    Exit;
   PageControl1.ActivePage := tsLogs;
   HideApplication;
   tupdatelogs.Enabled     := True;
  End;
 If RESTServicePooler1.Secure Then
  Begin
   lSeguro.Font.Color := clBlue;
   lSeguro.Caption    := 'Seguro : Sim';
  End
 Else
  Begin
   lSeguro.Font.Color := clRed;
   lSeguro.Caption    := 'Seguro : Não';
  End;
end;

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

