Unit formMain;

{$I uRESTDW.inc}

Interface

Uses
  DateUtils,      Windows,     Messages,      SysUtils,  Variants,  Classes, Graphics,   Controls,
  Forms,          Dialogs,     StdCtrls,      UDWJSONObject,   DB,  Grids,   DBGrids,    URESTDWBase,
  UDWJSONTools,   UDWConsts,   Vcl.ExtCtrls,  Vcl.Imaging.Pngimage, URESTDWPoolerDB,     Vcl.ComCtrls,
  System.UITypes, IdComponent, uDWConstsData, uDWConstsCharset, System.Actions,       Vcl.ActnList,        uRESTDWServerEvents,
  uDWDataset,     uDWAbout,    Vcl.Buttons,   Vcl.Imaging.jpeg,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, ServerUtils, uDWMassiveBuffer;

 Type
  TForm2 = Class(TForm)
   EHost             : TEdit;
   EPort             : TEdit;
   labHost           : TLabel;
   labPorta          : TLabel;
   DataSource1       : TDataSource;
   labResult         : TLabel;
   DBGrid1           : TDBGrid;
   MComando          : TMemo;
   btnOpen           : TButton;
   cbxCompressao     : TCheckBox;
   RESTDWDataBase1   : TRESTDWDataBase;
   btnExecute        : TButton;
   ProgressBar1      : TProgressBar;
   btnGet            : TButton;
   StatusBar1        : TStatusBar;
   Memo1             : TMemo;
   btnApply          : TButton;
   chkhttps          : TCheckBox;
   btnMassive        : TButton;
   ActionList1       : TActionList;
   DWClientEvents1   : TDWClientEvents;
   RESTClientPooler1 : TRESTClientPooler;
   btnServerTime     : TButton;
   eAccesstag        : TEdit;
   labAcesso         : TLabel;
   eWelcomemessage   : TEdit;
   labWelcome        : TLabel;
   labExtras         : TLabel;
   paTopo            : TPanel;
   labSistema        : TLabel;
   labSql            : TLabel;
   labRepsonse       : TLabel;
   labConexao        : TLabel;
   paPortugues       : TPanel;
   Image3            : TImage;
   paEspanhol        : TPanel;
   Image4            : TImage;
   paIngles          : TPanel;
   Image2            : TImage;
   Image1            : TImage;
   labVersao         : TLabel;
    Button1: TButton;
    cbBinaryRequest: TCheckBox;
    cbUseCripto: TCheckBox;
    cbBinaryCompatible: TCheckBox;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DWMassiveCache1: TDWMassiveCache;
    eUpdateTableName: TEdit;
    Label1: TLabel;
    Label11: TLabel;
    pTokenAuth: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    lTokenBegin: TLabel;
    lTokenEnd: TLabel;
    Label21: TLabel;
    eTokenID: TEdit;
    cbAuthOptions: TComboBox;
    pBasicAuth: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    EdPasswordAuth: TEdit;
    Label4: TLabel;
    EdUserNameAuth: TEdit;
    Label5: TLabel;
    Button2: TButton;
    cbThreadrequest: TCheckBox;
   Procedure btnOpenClick            (Sender            : TObject);
   Procedure btnExecuteClick         (Sender            : TObject);
   Procedure RESTDWDataBase1WorkBegin(ASender           : TObject;
                                      AWorkMode         : TWorkMode;
                                      AWorkCountMax     : Int64);
   Procedure RESTDWDataBase1Work     (ASender           : TObject;
                                      AWorkMode         : TWorkMode;
                                      AWorkCount        : Int64);
   Procedure RESTDWDataBase1WorkEnd  (ASender           : TObject;
                                      AWorkMode         : TWorkMode);
   Procedure RESTDWDataBase1Status   (ASender           : TObject;
                                      Const AStatus     : TIdStatus;
                                      Const AStatusText : String);
   Procedure FormCreate              (Sender            : TObject);
   Procedure RESTDWDataBase1Connection   (Sucess        : Boolean;
                                          Const Error   : String);
   Procedure RESTDWDataBase1BeforeConnect(Sender        : TComponent);
   Procedure btnApplyClick               (Sender        : TObject);
   Procedure btnMassiveClick             (Sender        : TObject);
   Procedure btnServerTimeClick          (Sender        : TObject);
   Procedure btnGetClick                 (Sender        : TObject);
   Procedure Image3Click                 (Sender        : TObject);
   Procedure Image4Click                 (Sender        : TObject);
   Procedure Image2Click                 (Sender        : TObject);
    procedure Button1Click(Sender: TObject);
    procedure RESTDWDataBase1FailOverExecute(
      ConnectionServer: TRESTDWConnectionServer);
    procedure RESTDWDataBase1FailOverError(
      ConnectionServer: TRESTDWConnectionServer; MessageError: string);
    procedure cbUseCriptoClick(Sender: TObject);
    procedure RESTDWClientSQL1WriterProcess(DataSet: TDataSet; RecNo,
      RecordCount: Integer; var AbortProcess: Boolean);
    procedure RESTClientPooler1BeforeGetToken(Welcomemsg, AccessTag: string;
      Params: TDWParams);
    procedure RESTDWDataBase1BeforeGetToken(Welcomemsg, AccessTag: string;
      Params: TDWParams);
    procedure cbAuthOptionsChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RESTDWTable1WriterProcess(DataSet: TDataSet; RecNo,
      RecordCount: Integer; var AbortProcess: Boolean);
 Private
  { Private declarations }
  vSecresString    : String;
  FBytesToTransfer : Int64;
  Procedure SetLoginOptions;
  Procedure GetLoginOptionsDatabase;
  Procedure GetLoginOptionsClientPooler;
  Function  GetSecret : String;
  Procedure SetKeys;
 Public
  { Public declarations }
  Procedure Locale_Portugues(pLocale : String);
  Property SecresString : String Read vSecresString;
 End;

Var
 Form2: TForm2;

Implementation

Uses uDWPoolerMethod;
{$R *.dfm}

Procedure TForm2.SetKeys;
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
   RESTDWClientSQL1.FindField(vKeyFields[I]).ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
 Finally
  FreeAndNil(vKeyFields);
 End;
End;

Procedure TForm2.btnOpenClick(Sender: TObject);
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
 DataSource1.DataSet               := RESTDWClientSQL1;
 RESTDWClientSQL1.BinaryRequest    := cbBinaryRequest.Checked;
 RESTDWClientSQL1.BinaryCompatibleMode := cbBinaryCompatible.Checked;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add(MComando.Text);
 RESTDWClientSQL1.UpdateTableName  := Trim(eUpdateTableName.Text);
 RESTDWClientSQL1.ThreadRequest    := cbThreadrequest.Checked;
 Try
  RESTDWClientSQL1.Active          := True;
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
 If RESTDWClientSQL1.FindField('FULL_NAME') <> Nil Then
  RESTDWClientSQL1.FindField('FULL_NAME').ProviderFlags := [];
 If RESTDWClientSQL1.FindField('UF') <> Nil Then
  RESTDWClientSQL1.FindField('UF').ProviderFlags       := [];
 If RESTDWClientSQL1.Active Then
  Showmessage(IntToStr(RESTDWClientSQL1.Recordcount) + ' registro(s) recebido(s) em ' + IntToStr(MilliSecondsBetween(FIM, INICIO)) + ' Milis.');
End;

Procedure TForm2.btnExecuteClick(Sender: TObject);
Var
 vErrorResult : Boolean;
 VError : String;
Begin
 RESTDWDataBase1.Close;
 If Not RESTDWDataBase1.Active Then
  Begin
   RESTDWDataBase1.PoolerService  := EHost.Text;
   RESTDWDataBase1.PoolerPort     := StrToInt(EPort.Text);
   SetLoginOptions;
   RESTDWDataBase1.Compression    := cbxCompressao.Checked;
   RESTDWDataBase1.AccessTag      := eAccesstag.Text;
   RESTDWDataBase1.WelcomeMessage := eWelcomemessage.Text;
   If chkhttps.Checked Then
    RESTDWDataBase1.TypeRequest   := TTyperequest.trHttps
   Else
    RESTDWDataBase1.TypeRequest   := TTyperequest.trHttp;
   RESTDWDataBase1.Open;
  End;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add(MComando.Text);
 If RESTDWClientSQL1.MassiveType = mtMassiveCache Then
  Begin
   If Not RESTDWClientSQL1.ExecSQL(VError) Then
    Application.MessageBox(PChar('Erro executando o comando ' + RESTDWClientSQL1.SQL.Text), 'Erro...', Mb_IconError + Mb_Ok)
   Else
    Application.MessageBox(PChar(Format('Comando executado com sucesso...Linhas Afetadas %d', [RESTDWClientSQL1.RowsAffected])), 'Informação !!!', Mb_iconinformation + Mb_Ok);
  End
 Else
  Begin
   RESTDWClientSQL1.ExecSQL;
   RESTDWDataBase1.ApplyUpdates(DWMassiveCache1, vErrorResult, vError); // RESTDWClientSQL1.ApplyUpdates;
  End;
 RESTDWClientSQL1.Active := Not RESTDWClientSQL1.Active;
 If RESTDWClientSQL1.Active Then
  Setkeys;
End;

Procedure TForm2.btnGetClick(Sender: TObject);
Var
 dwParams       : TDWParams;
 vErrorMessage,
 vNativeResult  : String;
Begin
 RESTClientPooler1.Host            := EHost.Text;
 RESTClientPooler1.Port            := StrToInt(EPort.Text);
 SetLoginOptions;
 RESTClientPooler1.DataCompression := cbxCompressao.Checked;
 RESTClientPooler1.AccessTag       := eAccesstag.Text;
 RESTClientPooler1.WelcomeMessage  := eWelcomemessage.Text;
 If chkhttps.Checked then
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttps
 Else
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttp;
 DWClientEvents1.CreateDWParams('getemployee', dwParams);
 DWClientEvents1.SendEvent('getemployee', dwParams, vErrorMessage, vNativeResult);
 If RESTClientPooler1.BinaryRequest then
  Begin
   If vErrorMessage <> '' Then
    Showmessage(vErrorMessage)
   Else
    Begin
     GetLoginOptionsClientPooler;
     Showmessage(dwParams.ItemsString['result'].AsString);
    End;
  End
 Else
  Begin
   If vNativeResult <> '' Then
    Begin
     GetLoginOptionsClientPooler;
     Showmessage(vNativeResult);
    End
   Else
    Showmessage(vErrorMessage);
  End;
 dwParams.Free;
End;

Procedure TForm2.btnApplyClick(Sender: TObject);
Var
 vResultError : Boolean;
 vError : String;
Begin
 vResultError := False;
 SetLoginOptions;
 If RESTDWClientSQL1.MassiveCache <> Nil Then
  Begin
   If DWMassiveCache1.MassiveCount > 0 Then
    RESTDWClientSQL1.DataBase.ApplyUpdates(DWMassiveCache1, vResultError, vError);
   If vResultError Then
    MessageDlg(vError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  End
 Else
  Begin
   If Not RESTDWClientSQL1.ApplyUpdates(vError) Then
    MessageDlg(vError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  End;
End;

Procedure TForm2.btnMassiveClick(Sender: TObject);
Begin
 If RESTDWClientSQL1.MassiveCount > 0 Then
  Showmessage(RESTDWClientSQL1.MassiveToJSON);
End;

Procedure TForm2.btnServerTimeClick(Sender: TObject);
Var
 dwParams      : TDWParams;
 vNativeResult,
 vErrorMessage : String;
Begin
 RESTClientPooler1.Host            := EHost.Text;
 RESTClientPooler1.Port            := StrToInt(EPort.Text);
 SetLoginOptions;
 RESTClientPooler1.DataCompression := cbxCompressao.Checked;
 RESTClientPooler1.AccessTag       := eAccesstag.Text;
 RESTClientPooler1.WelcomeMessage  := eWelcomemessage.Text;
 RESTClientPooler1.BinaryRequest   := cbBinaryRequest.Checked;
 If chkhttps.Checked then
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttps
 Else
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttp;
 DWClientEvents1.CreateDWParams('servertime', dwParams);
 DWClientEvents1.SendEvent('servertime', dwParams, vErrorMessage, vNativeResult);
 If vErrorMessage = '' Then
  Begin
   GetLoginOptionsClientPooler;
   If dwParams.ItemsString['result'] <> Nil Then
    Begin
     If dwParams.ItemsString['result'].AsString <> '' Then
      Showmessage('Server Date/Time is : ' + DateTimeToStr(dwParams.ItemsString['result'].Value))
     Else
      Showmessage(vErrorMessage);
    End
   Else
    Begin
     If vNativeResult <> '' Then
      Begin
       If vNativeResult <> '' Then
        Showmessage(vNativeResult)
       Else
        Showmessage(vErrorMessage);
      End;
    End;
  End
 Else
  Showmessage(vErrorMessage);
 dwParams.Free;
End;

procedure TForm2.Button1Click(Sender: TObject);
Var
 vErrorMessage : String;
 dwParams      : TdwParams;
Begin
 dwParams      := Nil;
 RESTClientPooler1.Host            := EHost.Text;
 RESTClientPooler1.Port            := StrToInt(EPort.Text);
 SetLoginOptions;
 RESTClientPooler1.DataCompression := cbxCompressao.Checked;
 RESTClientPooler1.AccessTag       := eAccesstag.Text;
 RESTClientPooler1.WelcomeMessage  := eWelcomemessage.Text;
 If chkhttps.Checked then
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttps
 Else
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttp;
 DWClientEvents1.SendEvent('assyncevent', dwParams, vErrorMessage, sePOST, True);
 If vErrorMessage = '' Then
  Begin
   GetLoginOptionsClientPooler;
   Showmessage('Assyncevent Executed...');
  End
 Else
  Showmessage(vErrorMessage);
End;

procedure TForm2.Button2Click(Sender: TObject);
begin
 Showmessage(SecresString);
end;

procedure TForm2.cbAuthOptionsChange(Sender: TObject);
begin
 pTokenAuth.Visible := cbAuthOptions.ItemIndex > 1;
 pBasicAuth.Visible := cbAuthOptions.ItemIndex = 1;
end;

procedure TForm2.cbUseCriptoClick(Sender: TObject);
begin
 RESTDWDataBase1.CriptOptions.Use   := cbUseCripto.Checked;
 RESTClientPooler1.CriptOptions.Use := RESTDWDataBase1.CriptOptions.Use;
end;

Procedure TForm2.FormCreate(Sender: TObject);
Begin
// RESTDWDataBase1.FailOverConnections[0].GetPoolerList;
 Memo1.Lines.Clear;
 labVersao.Caption := uDWConsts.DWVERSAO;
End;

Procedure TForm2.Image2Click(Sender: TObject);
Begin
 Locale_Portugues('ingles');
End;

Procedure TForm2.Image3Click(Sender: TObject);
Begin
 Locale_Portugues('portugues');
End;

Procedure TForm2.Image4Click(Sender: TObject);
Begin
 Locale_Portugues('espanhol');
End;

Procedure TForm2.SetLoginOptions;
Begin
  Case cbAuthOptions.ItemIndex Of
   0 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAONone;
   1 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
   2 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBearer;
   3 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOToken;
  End;
 RESTClientPooler1.AuthenticationOptions.AuthorizationOption := RESTDWDataBase1.AuthenticationOptions.AuthorizationOption;
 If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType := rdwtRequest;
     TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
     TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).TokenRequestType := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType;
     TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
    End
   Else
    Begin
     TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType := rdwtRequest;
     TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
     TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).TokenRequestType := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType;
     TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
    End;
  End
 Else If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBasic Then
  Begin
   TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username := edUserNameDW.Text;
   TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password := edPasswordDW.Text;
   TRDWAuthOptionBasic(RESTClientPooler1.AuthenticationOptions.OptionParams).Username := TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username;
   TRDWAuthOptionBasic(RESTClientPooler1.AuthenticationOptions.OptionParams).Password := TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password;
  End;
End;

Procedure TForm2.GetLoginOptionsDatabase;
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

Procedure TForm2.GetLoginOptionsClientPooler;
Begin
 If RESTClientPooler1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTClientPooler1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     eTokenID.Text       := TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Secrets;
    End
   Else
    Begin
     eTokenID.Text       := TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Secrets;
    End;
  End;
End;

Function  TForm2.GetSecret : String;
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

Procedure TForm2.Locale_Portugues( pLocale : String );
Begin
 If pLocale = 'portugues'     Then
  Begin
   paPortugues.Color     := clWhite;
   paEspanhol.Color      := $002a2a2a;
   paIngles.Color        := $002a2a2a;
   labConexao.Caption    := ' .: CONFIGURAÇÃO DO SERVIDOR';
   labSql.Caption        := ' .: COMANDO SQL';
   labRepsonse.Caption   := ' .: RESPOSTA DO SERVIDOR';
   labResult.Caption     := ' .: RESULTADO DA CONSULTA SQL';
   cbxCompressao.Caption := 'Compressão';
  End
 Else If pLocale = 'ingles'   Then
  Begin
   paPortugues.Color     := $002a2a2a;
   paEspanhol.Color      := $002a2a2a;
   paIngles.Color        := clWhite;
   labConexao.Caption    := ' .: SQL COMMAND';
   labSql.Caption        := ' .: SERVER CONFIGURATION';
   labRepsonse.Caption   := ' .: SQL QUERY RESULT';
   labResult.Caption     := ' .: SQL QUERY RESULT';
   cbxCompressao.Caption := 'Compresión';
  End
 Else If pLocale = 'espanhol' Then
  Begin
   paPortugues.Color     := $002a2a2a;
   paEspanhol.Color      := clWhite;
   paIngles.Color        := $002a2a2a;
   labConexao.Caption    := ' .: CONFIGURATIÓN DEL SERVIDOR';
   labSql.Caption        := ' .: COMANDO SQL';
   labRepsonse.Caption   := ' .: RESPUESTA DEL SERVIDOR';
   labResult.Caption     := ' .: RESULTADO DE LA CONSULTA DE SQL';
   cbxCompressao.Caption := 'Compressão';
  End;
End;

procedure TForm2.RESTClientPooler1BeforeGetToken(Welcomemsg, AccessTag: string;
  Params: TDWParams);
begin
 Params.Createparam('username', EdUserNameAuth.Text);
 Params.Createparam('password', EdPasswordAuth.Text);
end;

procedure TForm2.RESTDWClientSQL1WriterProcess(DataSet: TDataSet; RecNo,
  RecordCount: Integer; var AbortProcess: Boolean);
begin
 If Assigned(ProgressBar1) Then
  Begin
   ProgressBar1.Min      := 0;
   ProgressBar1.Position := RecNo;
   ProgressBar1.Max      := RecordCount;
  End;
end;

Procedure TForm2.RESTDWDataBase1BeforeConnect(Sender: TComponent);
Begin
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add('**********');
 Memo1.Lines.Add(' ');
End;

procedure TForm2.RESTDWDataBase1BeforeGetToken(Welcomemsg, AccessTag: string;
  Params: TDWParams);
begin
 Params.Createparam('username', EdUserNameAuth.Text);
 Params.Createparam('password', EdPasswordAuth.Text);
end;

Procedure TForm2.RESTDWDataBase1Connection(Sucess: Boolean; Const Error: String);
Begin
 If Sucess Then
  Begin
   Memo1.Lines.Add(DateTimeToStr(Now) + ' - Database conectado com sucesso.');
   GetLoginOptionsDatabase;
  End
 Else
  Memo1.Lines.Add(DateTimeToStr(Now) + ' - Falha de conexão ao Database: ' + Error);
End;

procedure TForm2.RESTDWDataBase1FailOverError(
  ConnectionServer: TRESTDWConnectionServer; MessageError: string);
begin
 Memo1.Lines.Add(Format('FailOver Error(Server %s) : ', [ConnectionServer.Name, MessageError]));
end;

procedure TForm2.RESTDWDataBase1FailOverExecute(
  ConnectionServer: TRESTDWConnectionServer);
begin
 Memo1.Lines.Add('Executando FailOver Servidor : ' + ConnectionServer.Name);
end;

Procedure TForm2.RESTDWDataBase1Status(ASender: TObject; Const AStatus: TIdStatus; Const AStatusText: String);
Begin
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
End;

Procedure TForm2.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
Begin
 If Assigned(ProgressBar1) Then
  Begin
   If FBytesToTransfer = 0 Then // No Update File
    Exit;
   ProgressBar1.Position := AWorkCount;
   ProgressBar1.Update;
  End;
End;

Procedure TForm2.RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
Begin
 If Assigned(ProgressBar1) Then
  Begin
   FBytesToTransfer      := AWorkCountMax;
   ProgressBar1.Max      := FBytesToTransfer;
   ProgressBar1.Position := 0;
   ProgressBar1.Update;
  End;
End;

Procedure TForm2.RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
Begin
 If Assigned(ProgressBar1) Then
  Begin
   ProgressBar1.Position := FBytesToTransfer;
   Application.ProcessMessages;
   FBytesToTransfer := 0;
  End;
End;

procedure TForm2.RESTDWTable1WriterProcess(DataSet: TDataSet; RecNo,
  RecordCount: Integer; var AbortProcess: Boolean);
begin
 If Assigned(ProgressBar1) Then
  Begin
   ProgressBar1.Min      := 0;
   ProgressBar1.Position := RecNo;
   ProgressBar1.Max      := RecordCount;
  End;
end;

End.
