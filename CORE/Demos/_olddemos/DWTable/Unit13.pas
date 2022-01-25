unit Unit13;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.DateUtils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDWConsts, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, uDWAbout, uRESTDWPoolerDB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uDWConstsData, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  ServerUtils, Vcl.ComCtrls, IdComponent, uDWMassiveBuffer, uDWJSONObject;

type
  TForm13 = class(TForm)
    labHost: TLabel;
    labPorta: TLabel;
    labAcesso: TLabel;
    labWelcome: TLabel;
    labExtras: TLabel;
    labConexao: TLabel;
    Label11: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    cbxCompressao: TCheckBox;
    chkhttps: TCheckBox;
    eAccesstag: TEdit;
    eWelcomemessage: TEdit;
    paTopo: TPanel;
    Image1: TImage;
    labSistema: TLabel;
    paPortugues: TPanel;
    Image3: TImage;
    paEspanhol: TPanel;
    Image4: TImage;
    paIngles: TPanel;
    Image2: TImage;
    cbBinaryRequest: TCheckBox;
    cbUseCripto: TCheckBox;
    cbBinaryCompatible: TCheckBox;
    cbAuthOptions: TComboBox;
    pBasicAuth: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    pTokenAuth: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    lTokenBegin: TLabel;
    lTokenEnd: TLabel;
    Label21: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    eTokenID: TEdit;
    EdPasswordAuth: TEdit;
    EdUserNameAuth: TEdit;
    Button2: TButton;
    labResult: TLabel;
    labRepsonse: TLabel;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    btnApply: TButton;
    btnOpen: TButton;
    DataSource1: TDataSource;
    RESTDWTable1: TRESTDWTable;
    RESTDWDataBase1: TRESTDWDataBase;
    eUpdateTableName: TEdit;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    DWMassiveCache1: TDWMassiveCache;
    StatusBar1: TStatusBar;
    labVersao: TLabel;
    procedure cbAuthOptionsChange(Sender: TObject);
    procedure cbUseCriptoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure RESTDWDataBase1Connection(Sucess: Boolean; const Error: string);
    procedure RESTDWDataBase1BeforeConnect(Sender: TComponent);
    procedure RESTDWDataBase1BeforeGetToken(Welcomemsg, AccessTag: string;
      Params: TDWParams);
    procedure RESTDWDataBase1FailOverError(
      ConnectionServer: TRESTDWConnectionServer; MessageError: string);
    procedure RESTDWDataBase1FailOverExecute(
      ConnectionServer: TRESTDWConnectionServer);
    procedure RESTDWDataBase1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure btnApplyClick(Sender: TObject);
  private
    { Private declarations }
   vSecresString    : String;
   FBytesToTransfer : Int64;
   Procedure SetKeys;
   Procedure SetLoginOptions;
   Procedure GetLoginOptionsDatabase;
   Procedure Locale_Portugues( pLocale : String );
  public
    { Public declarations }
   Function  GetSecret : String;
   Property SecresString : String Read vSecresString;
  end;

var
  Form13: TForm13;

implementation

Uses uDWPoolerMethod;
{$R *.dfm}

Procedure TForm13.GetLoginOptionsDatabase;
Begin
 If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     eTokenID.Text       := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets;
    End
   Else
    Begin
     eTokenID.Text       := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets;
    End;
  End;
End;

Procedure TForm13.Locale_Portugues( pLocale : String );
Begin
 If pLocale = 'portugues'     Then
  Begin
   paPortugues.Color     := clWhite;
   paEspanhol.Color      := $002a2a2a;
   paIngles.Color        := $002a2a2a;
   labConexao.Caption    := ' .: CONFIGURAÇÃO DO SERVIDOR';
   labRepsonse.Caption   := ' .: RESPOSTA DO SERVIDOR';
   labResult.Caption     := ' .: RESULTADO DA CONSULTA SQL';
   cbxCompressao.Caption := 'Compressão';
  End
 Else If pLocale = 'ingles'   Then
  Begin
   paPortugues.Color     := $002a2a2a;
   paEspanhol.Color      := $002a2a2a;
   paIngles.Color        := clWhite;
   labConexao.Caption    := ' .: TABLE COMMAND';
   labRepsonse.Caption   := ' .: TABLE RESULT';
   labResult.Caption     := ' .: TABLE RESULT';
   cbxCompressao.Caption := 'Compresión';
  End
 Else If pLocale = 'espanhol' Then
  Begin
   paPortugues.Color     := $002a2a2a;
   paEspanhol.Color      := clWhite;
   paIngles.Color        := $002a2a2a;
   labConexao.Caption    := ' .: CONFIGURATIÓN DEL SERVIDOR';
   labRepsonse.Caption   := ' .: RESPUESTA DEL SERVIDOR';
   labResult.Caption     := ' .: RESULTADO DE LA CONSULTA DE SQL';
   cbxCompressao.Caption := 'Compressão';
  End;
End;

procedure TForm13.RESTDWDataBase1BeforeConnect(Sender: TComponent);
begin
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add('**********');
 Memo1.Lines.Add(' ');
end;

procedure TForm13.RESTDWDataBase1BeforeGetToken(Welcomemsg, AccessTag: string;
  Params: TDWParams);
begin
 Params.Createparam('username', EdUserNameAuth.Text);
 Params.Createparam('password', EdPasswordAuth.Text);
end;

procedure TForm13.RESTDWDataBase1Connection(Sucess: Boolean;
  const Error: string);
begin
 If Sucess Then
  Begin
   Memo1.Lines.Add(DateTimeToStr(Now) + ' - Database conectado com sucesso.');
   GetLoginOptionsDatabase;
  End
 Else
  Memo1.Lines.Add(DateTimeToStr(Now) + ' - Falha de conexão ao Database: ' + Error);
end;

procedure TForm13.RESTDWDataBase1FailOverError(
  ConnectionServer: TRESTDWConnectionServer; MessageError: string);
begin
 Memo1.Lines.Add(Format('FailOver Error(Server %s) : ', [ConnectionServer.Name, MessageError]));
end;

procedure TForm13.RESTDWDataBase1FailOverExecute(
  ConnectionServer: TRESTDWConnectionServer);
begin
 Memo1.Lines.Add('Executando FailOver Servidor : ' + ConnectionServer.Name);
end;

procedure TForm13.RESTDWDataBase1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
 If Self = Nil Then
  Exit;
 Case AStatus Of
   hsResolving:
    Begin
     StatusBar1.Panels[0].Text := 'hsResolving...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
   hsConnecting:
    Begin
     StatusBar1.Panels[0].Text := 'hsConnecting...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
   hsConnected:
    Begin
     StatusBar1.Panels[0].Text := 'hsConnected...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
   hsDisconnecting:
    Begin
     If StatusBar1.Panels.count > 0 Then
      StatusBar1.Panels[0].Text := 'hsDisconnecting...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
   hsDisconnected:
    Begin
     StatusBar1.Panels[0].Text := 'hsDisconnected...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
   hsStatusText:
    Begin
     StatusBar1.Panels[0].Text := 'hsStatusText...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
  // These are to eliminate the TIdFTPStatus and the coresponding event These can be use din the other protocols to.
   ftpTransfer:
    Begin
     StatusBar1.Panels[0].Text := 'ftpTransfer...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
   ftpReady:
    Begin
     StatusBar1.Panels[0].Text := 'ftpReady...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
   ftpAborted:
    Begin
     StatusBar1.Panels[0].Text := 'ftpAborted...';
     Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
    End;
  End;
end;

procedure TForm13.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
 If FBytesToTransfer = 0 Then // No Update File
  Exit;
 ProgressBar1.Position := AWorkCount;
 ProgressBar1.Update;
end;

procedure TForm13.RESTDWDataBase1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
 FBytesToTransfer      := AWorkCountMax;
 ProgressBar1.Max      := FBytesToTransfer;
 ProgressBar1.Position := 0;
 ProgressBar1.Update;
end;

procedure TForm13.RESTDWDataBase1WorkEnd(ASender: TObject;
  AWorkMode: TWorkMode);
begin
 ProgressBar1.Position := FBytesToTransfer;
 Application.ProcessMessages;
 FBytesToTransfer := 0;
end;

Function  TForm13.GetSecret : String;
Begin
 Result := '';
 If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Result := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets
   Else
    Result := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets;
  End;
End;

Procedure TForm13.SetKeys;
Var
 I          : Integer;
 vKeyFields : TStringList;
Begin
 vKeyFields := TStringList.Create;
 Try
  If Trim(eUpdateTableName.Text) <> '' Then
   Begin
    RESTDWDataBase1.GetKeyFieldNames(Trim(eUpdateTableName.Text), vKeyFields);
    RESTDWDataBase1.PoolerList;
   End;
  For I := 0 To vKeyFields.Count -1 Do
   RESTDWTable1.FindField(vKeyFields[I]).ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
 Finally
  FreeAndNil(vKeyFields);
 End;
End;

Procedure TForm13.SetLoginOptions;
Begin
  Case cbAuthOptions.ItemIndex Of
   0 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAONone;
   1 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
   2 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBearer;
   3 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOToken;
  End;
 If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType := rdwtRequest;
     TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
    End
   Else
    Begin
     TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType := rdwtRequest;
     TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
    End;
  End
 Else If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBasic Then
  Begin
   TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username := edUserNameDW.Text;
   TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password := edPasswordDW.Text;
  End;
End;

procedure TForm13.btnApplyClick(Sender: TObject);
Var
 vResultError : Boolean;
 vError : String;
Begin
 vResultError := False;
 SetLoginOptions;
 If RESTDWTable1.MassiveCache <> Nil Then
  Begin
   If DWMassiveCache1.MassiveCount > 0 Then
    RESTDWTable1.DataBase.ApplyUpdates(DWMassiveCache1, vResultError, vError);
   If vResultError Then
    MessageDlg(vError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  End
 Else
  Begin
   If Not RESTDWTable1.ApplyUpdates(vError) Then
    MessageDlg(vError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  End;
End;

procedure TForm13.btnOpenClick(Sender: TObject);
Var
 INICIO,
 FIM        : TDateTime;
 I          : Integer;
 vKeyFields : TStringList;
Begin
 RESTDWDataBase1.Active            := False;
 If Not RESTDWDataBase1.Active Then
  Begin
   RESTDWDataBase1.PoolerService   := EHost.Text;
   RESTDWDataBase1.PoolerPort      := StrToInt(EPort.Text);
   SetLoginOptions;
   RESTDWDataBase1.Compression     := cbxCompressao.Checked;
   RESTDWDataBase1.AccessTag       := eAccesstag.Text;
   RESTDWDataBase1.WelcomeMessage  := eWelcomemessage.Text;
   If chkhttps.Checked Then
    RESTDWDataBase1.TypeRequest    := TTyperequest.trHttps
   Else
    RESTDWDataBase1.TypeRequest    := TTyperequest.trHttp;
  End;
 INICIO                            := Now;
 DataSource1.DataSet               := RESTDWTable1;
 RESTDWTable1.Close;
 RESTDWTable1.TableName            := Trim(eUpdateTableName.Text);
 Try
  RESTDWTable1.Active          := True;
  If RESTDWTable1.Active Then
   Setkeys;
 Except
  On E: Exception Do
   Begin
    Raise Exception.Create('Erro ao executar a consulta: ' + sLineBreak + E.Message);
   End;
 End;
 FIM := Now;
 EHost.Text            := RESTDWDataBase1.PoolerService;
 EPort.Text            := IntToStr(RESTDWDataBase1.PoolerPort);
 cbxCompressao.Checked := RESTDWDataBase1.Compression;
 eAccesstag.Text       := RESTDWDataBase1.AccessTag;
 eWelcomemessage.Text  := RESTDWDataBase1.WelcomeMessage;
 If RESTDWTable1.FindField('FULL_NAME') <> Nil Then
  RESTDWTable1.FindField('FULL_NAME').ProviderFlags := [];
 If RESTDWTable1.FindField('UF') <> Nil Then
  RESTDWTable1.FindField('UF').ProviderFlags       := [];
 If RESTDWTable1.Active Then
  Showmessage(IntToStr(RESTDWTable1.Recordcount) + ' registro(s) recebido(s) em ' + IntToStr(MilliSecondsBetween(FIM, INICIO)) + ' Milis.');
End;

procedure TForm13.cbAuthOptionsChange(Sender: TObject);
begin
 pTokenAuth.Visible := cbAuthOptions.ItemIndex > 1;
 pBasicAuth.Visible := cbAuthOptions.ItemIndex = 1;
end;

procedure TForm13.cbUseCriptoClick(Sender: TObject);
begin
 RESTDWDataBase1.CriptOptions.Use   := cbUseCripto.Checked;
end;

procedure TForm13.FormCreate(Sender: TObject);
begin
 Memo1.Lines.Clear;
 labVersao.Caption := DWVERSAO;
end;

end.
