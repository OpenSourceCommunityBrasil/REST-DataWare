{ ****************************************************************************** }
{ Projeto: Componentes DW }
{ Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
{ mentos de Automação Comercial utilizados no Brasil }
{ }
{ Direitos Autorais Reservados (c) 2009   Isaque Pinheiro }
{ }
{ Colaboradores nesse arquivo: }
{ }
{ Você pode obter a última versão desse arquivo na pagina do  Projeto DW }
{ Componentes localizado em      http://www.sourceforge.net/projects/DW }
{ }
{ Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
{ sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela }
{ Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
{ qualquer versão posterior. }
{ }
{ Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM }
{ NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU }
{ ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor }
{ do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT) }
{ }
{ Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto }
{ com esta biblioteca; se não, escreva para a Free Software Foundation, Inc., }
{ no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA. }
{ Você também pode obter uma copia da licença em: }
{ http://www.opensource.org/licenses/lgpl-license.php }
{ }
{ Daniel Simões de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br }
{ Praça Anita Costa, 34 - Tatuí - SP - 18270-410 }
{ }
{ ****************************************************************************** }

{ ******************************************************************************
  |* Historico
  |*
  |* 29/03/2012: Isaque Pinheiro / Régys Borges da Silveira
  |*  - Criação e distribuição da Primeira Versao
  ******************************************************************************* }
unit uPrincipal;

interface

USES
  JclIDEUtils,
  JclCompilerUtils,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  StdCtrls,
  ExtCtrls,
  Buttons,
  Pngimage,
  ShlObj,
  UFrameLista,
  IOUtils,
  Types,
  JvComponentBase,
  JvCreateProcess,
  JvExControls,
  JvAnimatedImage,
  JvGIFCtrl,
  JvWizard,
  JvWizardRouteMapNodes,
  CheckLst;

type
  TDestino = (TdSystem, TdDelphi, TdNone);

  TfrmPrincipal = class(TForm)
    WizPrincipal: TJvWizard;
    WizMapa: TJvWizardRouteMapNodes;
    WizPgConfiguracao: TJvWizardInteriorPage;
    WizPgObterFontes: TJvWizardInteriorPage;
    WizPgInstalacao: TJvWizardInteriorPage;
    WizPgFinalizar: TJvWizardInteriorPage;
    WizPgInicio: TJvWizardWelcomePage;
    Label4: TLabel;
    Label5: TLabel;
    EdtDelphiVersion: TComboBox;
    EdtPlatform: TComboBox;
    Label2: TLabel;
    EdtDirDestino: TEdit;
    Label1: TLabel;
    EdtURL: TEdit;
    LblInfoObterFontes: TLabel;
    LstMsgInstalacao: TListBox;
    PnlTopo: TPanel;
    Label9: TLabel;
    BtnSelecDirInstall: TSpeedButton;
    PgbInstalacao: TProgressBar;
    Label10: TLabel;
    BtnSVNCheckoutUpdate: TSpeedButton;
    BtnInstalarDW: TSpeedButton;
    CkbFecharTortoise: TCheckBox;
    BtnVisualizarLogCompilacao: TSpeedButton;
    PnlInfoCompilador: TPanel;
    WizPgPacotes: TJvWizardInteriorPage;
    FrameDpk: TframePacotes;
    LbInfo: TListBox;
    BtnWCInfo: TButton;
    JvCreateProcess1: TJvCreateProcess;
    ClbDelphiVersion: TCheckListBox;
    Label23: TLabel;
    Label27: TLabel;
    Label26: TLabel;
    ImgLogomarca: TImage;
    Label6: TLabel;
    Label20: TLabel;
    Label28: TLabel;
    Label19: TLabel;
    LblUrlDW1: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label21: TLabel;
    LblUrlForum1: TLabel;
    Label12: TLabel;
    Label11: TLabel;
    ChkDeixarSomenteLIB: TCheckBox;
    CkbRemoverArquivosAntigos: TCheckBox;
    CkUseJEDI: TCheckBox;
    CkUseFireDAC: TCheckBox;
    CkUseKBMemTable: TCheckBox;
    Label3: TLabel;
    Label18: TLabel;
    Label14: TLabel;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EdtDelphiVersionChange(Sender: TObject);
    procedure WizPgInicioNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure URLClick(Sender: TObject);
    procedure BtnSelecDirInstallClick(Sender: TObject);
    procedure WizPrincipalCancelButtonClick(Sender: TObject);
    procedure WizPrincipalFinishButtonClick(Sender: TObject);
    procedure WizPgConfiguracaoNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure BtnSVNCheckoutUpdateClick(Sender: TObject);
    procedure WizPgObterFontesEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure BtnInstalarDWClick(Sender: TObject);
    procedure WizPgObterFontesNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure WizPgInstalacaoNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure BtnVisualizarLogCompilacaoClick(Sender: TObject);
    procedure WizPgInstalacaoEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure BtnWCInfoClick(Sender: TObject);
    procedure ClbDelphiVersionClick(Sender: TObject);
    procedure WriteToTXT(const ArqTXT: STRING; ABinaryString: AnsiString; const AppendIfExists: Boolean = True; const AddLineBreak: Boolean = True);
    procedure CkUseJEDIClick(Sender: TObject);
    procedure CkUseFireDACClick(Sender: TObject);
    procedure CkUseKBMemTableClick(Sender: TObject);
  private
    FCountErros: Integer;
    ODW:         TJclBorRADToolInstallations;
    IVersion:    Integer;
    TPlatform:   TJclBDSPlatform;
    SDirRoot:    STRING;
    SDirLibrary: STRING;
    SDirPackage: STRING;
    PastaDW:     STRING;
    SDestino:    TDestino;
    SPathBin:    STRING;
    procedure BeforeExecute(Sender: TJclBorlandCommandLineTool);
    procedure AddLibrarySearchPath;
    procedure OutputCallLine(const Text: STRING);
    procedure SetPlatformSelected;
    function IsCheckOutJaFeito(const ADiretorio: STRING): Boolean;
    procedure CreateDirectoryLibrarysNotExist;
    procedure GravarConfiguracoes;
    procedure LerConfiguracoes;
    function PathApp: STRING;
    function PathArquivoIni: STRING;
    function PathArquivoLog: STRING;
    procedure InstalarCapicom;
    function PathSystem: STRING;
    function RegistrarActiveXServer(const AServerLocation: STRING; const ARegister: Boolean): Boolean;
    procedure CopiarArquivoTo(ADestino: TDestino; const ANomeArquivo: STRING);
    procedure ExtrairDiretorioPacote(NomePacote: STRING);
    procedure AddLibraryPathToDelphiPath(const APath, AProcurarRemover: STRING);
    procedure FindDirs(ADirRoot: STRING; BAdicionar: Boolean = True);
    procedure DeixarSomenteLib;
    procedure RemoverArquivosAntigosDoDisco;
    procedure RemoverDiretoriosEPacotesAntigos;
    function RunAsAdminAndWaitForCompletion(HWnd: HWND; Filename: STRING): Boolean;
    procedure GetDriveLetters(AList: TStrings);
    procedure MostraDadosVersao;
    function GetPathDWInc: TFileName;
  public

  end;

var
  FrmPrincipal: TfrmPrincipal;

implementation

USES
  SVN_Class,
  FileCtrl,
  ShellApi,
  IniFiles,
  StrUtils,
  Math,
  Registry;

{$R *.dfm}

function TfrmPrincipal.RunAsAdminAndWaitForCompletion(HWnd: HWND; Filename: STRING): Boolean;
{
  See Step 3: Redesign for UAC Compatibility (UAC)
  http://msdn.microsoft.com/en-us/library/bb756922.aspx
}
var
  Sei:      TShellExecuteInfo;
  ExitCode: DWORD;
begin
  ZeroMemory(@Sei, SizeOf(Sei));
  Sei.CbSize       := SizeOf(TShellExecuteInfo);
  Sei.Wnd          := Hwnd;
  Sei.FMask        := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
  Sei.LpVerb       := PWideChar('runas');
  Sei.LpFile       := PWideChar(Filename);
  Sei.LpParameters := PWideChar('');
  Sei.NShow        := SW_HIDE;

  if ShellExecuteEx(@Sei) then
  begin
    repeat
      Application.ProcessMessages;
      GetExitCodeProcess(Sei.HProcess, ExitCode);
    until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
  end;
end;

procedure TfrmPrincipal.ExtrairDiretorioPacote(NomePacote: STRING);

procedure FindDirPackage(SDir, SPacote: STRING);
var
  ODirList: TSearchRec;
  IRet:     Integer;
  SDirDpk:  STRING;
begin
  SDir := IncludeTrailingPathDelimiter(SDir);
  if not DirectoryExists(SDir) then
    Exit;

  if SysUtils.FindFirst(SDir + '*.*', FaAnyFile, ODirList) = 0 then
  begin
    try
      repeat

        if (ODirList.Name = '.') or (ODirList.Name = '..') or (ODirList.Name = '__history') or (ODirList.Name = '__recovery') then
          Continue;

        // if oDirList.Attr = faDirectory then
        if DirectoryExists(SDir + ODirList.Name) then
          FindDirPackage(SDir + ODirList.Name, SPacote)
        else
        begin
          if UpperCase(ODirList.Name) = UpperCase(SPacote) then
            SDirPackage := IncludeTrailingPathDelimiter(SDir);
        end;

      until SysUtils.FindNext(ODirList) <> 0;
    finally
      SysUtils.FindClose(ODirList);
    end;
  end;
end;

begin
  SDirPackage := '';
  if NomePacote = 'RestEasyObjects.dpk' then
  begin
    FindDirPackage(IncludeTrailingPathDelimiter(SDirRoot), NomePacote);
  end;
  if NomePacote = 'RESTDriverFD.dpk' then
  begin
    FindDirPackage(IncludeTrailingPathDelimiter(SDirRoot) + 'Connectors\FireDAC', NomePacote);
  end;
  if NomePacote = 'RESTDriverZEOS.dpk' then
  begin
    FindDirPackage(IncludeTrailingPathDelimiter(SDirRoot) + 'Connectors\ZEOS', NomePacote);
  end;
  if NomePacote = 'RESTDriverUniDAC.dpk' then
  begin
    FindDirPackage(IncludeTrailingPathDelimiter(SDirRoot) + 'Connectors\UniDAC', NomePacote);
  end;

  if NomePacote = 'RestDatawareCORE.dpk' then
  begin
    FindDirPackage(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Packages\Delphi\' + PastaDW, NomePacote);
  end;
  if NomePacote = 'RESTDWDriverFD.dpk' then
  begin
    FindDirPackage(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\Connectors\FireDAC\Package\', NomePacote);
  end;

  // Original
  // FindDirPackage(IncludeTrailingPathDelimiter(SDirRoot) + 'Pacotes\Delphi', NomePacote);
end;

// retornar o path do aplicativo
function TfrmPrincipal.PathApp: STRING;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

// retornar o caminho completo para o arquivo .ini de configurações
function TfrmPrincipal.PathArquivoIni: STRING;
var
  NomeApp: STRING;
begin
  NomeApp := ExtractFileName(ParamStr(0));
  Result  := PathApp + ChangeFileExt(NomeApp, '.ini');
end;

// retornar o caminho completo para o arquivo de logs
function TfrmPrincipal.PathArquivoLog: STRING;
begin
  Result := PathApp + 'log_' + StringReplace(EdtDelphiVersion.Text, ' ', '_', [RfReplaceAll]) + '.txt';
end;

// verificar se no caminho informado já existe o .svn indicando que o
// checkout já foi feito no diretorio
function TfrmPrincipal.IsCheckOutJaFeito(const ADiretorio: STRING): Boolean;
begin
  Result := DirectoryExists(IncludeTrailingPathDelimiter(ADiretorio) + '.svn')
end;

// retorna o diretório de sistema atual
function TfrmPrincipal.PathSystem: STRING;
var
  StrTmp:     array [0 .. MAX_PATH] of Char;
  DirWindows: STRING;
const
  SYS_64 = 'SysWOW64';
  SYS_32 = 'System32';
begin
  Result := '';

  // SetLength(strTmp, MAX_PATH);
  if Windows.GetWindowsDirectory(StrTmp, MAX_PATH) > 0 then
  begin
    DirWindows := Trim(StrPas(StrTmp));
    DirWindows := IncludeTrailingPathDelimiter(DirWindows);

    if DirectoryExists(DirWindows + SYS_64) then
      Result := DirWindows + SYS_64
    else if DirectoryExists(DirWindows + SYS_32) then
      Result := DirWindows + SYS_32
    else
      raise EFileNotFoundException.Create('Diretório de sistema não encontrado.');
  end
  else
    raise EFileNotFoundException.Create('Ocorreu um erro ao tentar obter o diretório do windows.');
end;

function TfrmPrincipal.RegistrarActiveXServer(const AServerLocation: STRING; const ARegister: Boolean): Boolean;
var
  ServerDllRegisterServer:   function: HResult; stdcall;
  ServerDllUnregisterServer: function: HResult; stdcall;
  ServerHandle:              THandle;

procedure UnloadServerFunctions;
begin
  @ServerDllRegisterServer   := nil;
  @ServerDllUnregisterServer := nil;
  FreeLibrary(ServerHandle);
end;

function LoadServerFunctions: Boolean;
begin
  Result       := False;
  ServerHandle := SafeLoadLibrary(AServerLocation);

  if (ServerHandle <> 0) then
  begin
    @ServerDllRegisterServer   := GetProcAddress(ServerHandle, 'DllRegisterServer');
    @ServerDllUnregisterServer := GetProcAddress(ServerHandle, 'DllUnregisterServer');

    if (@ServerDllRegisterServer = nil) or (@ServerDllUnregisterServer = nil) then
      UnloadServerFunctions
    else
      Result := True;
  end;
end;

begin
  Result := False;
  try
    if LoadServerFunctions then
      try
        if ARegister then
          Result := ServerDllRegisterServer = S_OK
        else
          Result := ServerDllUnregisterServer = S_OK;
      finally
        UnloadServerFunctions;
      end;
  except
  end;
end;

procedure TfrmPrincipal.CopiarArquivoTo(ADestino: TDestino; const ANomeArquivo: STRING);
var
  PathOrigem:  STRING;
  PathDestino: STRING;
  DirSystem:   STRING;
  DirDW:       STRING;
begin
  case ADestino of
    TdSystem:
      DirSystem := Trim(PathSystem);
    TdDelphi:
      DirSystem := SPathBin;
  end;

  DirDW := IncludeTrailingPathDelimiter(EdtDirDestino.Text);

  if DirSystem <> EmptyStr then
    DirSystem := IncludeTrailingPathDelimiter(DirSystem)
  else
    raise EFileNotFoundException.Create('Diretório de sistema não encontrado.');

  PathOrigem  := DirDW + 'DLLs\' + ANomeArquivo;
  PathDestino := DirSystem + ExtractFileName(ANomeArquivo);

  if FileExists(PathOrigem) and not(FileExists(PathDestino)) then
  begin
    if not CopyFile(PWideChar(PathOrigem), PWideChar(PathDestino), True) then
    begin
      raise EFilerError.CreateFmt('Ocorreu o seguinte erro ao tentar copiar o arquivo "%s": %d - %s', [ANomeArquivo, GetLastError, SysErrorMessage(GetLastError)]);
    end;
  end;
end;

// copia as dlls da pasta capcom para a pasta escolhida pelo usuario e registra a dll
procedure TfrmPrincipal.InstalarCapicom;
begin
  if SDestino <> TdNone then
  begin
    CopiarArquivoTo(SDestino, 'Capicom\capicom.dll');
    CopiarArquivoTo(SDestino, 'Capicom\msxml5.dll');
    CopiarArquivoTo(SDestino, 'Capicom\msxml5r.dll');

    if SDestino = TdDelphi then
    begin
      RegistrarActiveXServer(SPathBin + 'capicom.dll', True);
      RegistrarActiveXServer(SPathBin + 'msxml5.dll', True);
    end
    else
    begin
      RegistrarActiveXServer('capicom.dll', True);
      RegistrarActiveXServer('msxml5.dll', True);
    end;
  end;
end;

// ler o arquivo .ini de configurações e setar os campos com os valores lidos
procedure TfrmPrincipal.LerConfiguracoes;
var
  ArqIni: TIniFile;
  I:      Integer;
begin
  ArqIni := TIniFile.Create(PathArquivoIni);
  try
    EdtDirDestino.Text    := ArqIni.ReadString('CONFIG', 'DiretorioInstalacao', ExtractFilePath(ParamStr(0)));
    EdtPlatform.ItemIndex := EdtPlatform.Items.IndexOf('Win32'); // edtPlatform.Items.IndexOf(ArqIni.ReadString('CONFIG', 'Plataforma', 'Win32'));
    // edtDelphiVersion.ItemIndex  := edtDelphiVersion.Items.IndexOf(ArqIni.ReadString('CONFIG', 'DelphiVersao', ''));
    CkbFecharTortoise.Checked   := ArqIni.ReadBool('CONFIG', 'FecharTortoise', True);
    ChkDeixarSomenteLIB.Checked := ArqIni.ReadBool('CONFIG', 'DexarSomenteLib', False);

    if Trim(EdtDelphiVersion.Text) = '' then
      EdtDelphiVersion.ItemIndex := 0;

    EdtDelphiVersionChange(EdtDelphiVersion);

    for I                         := 0 to FrameDpk.Pacotes.Count - 1 do
      FrameDpk.Pacotes[I].Checked := ArqIni.ReadBool('PACOTES', FrameDpk.Pacotes[I].Caption, False);
  finally
    ArqIni.Free;
  end;
end;

procedure TfrmPrincipal.MostraDadosVersao;
begin
  // mostrar ao usuário as informações de compilação
  LbInfo.Clear;
  with LbInfo.Items do
  begin
    Clear;
    Add(EdtDelphiVersion.Text + ' ' + EdtPlatform.Text);
    Add('Dir. Instalação  : ' + EdtDirDestino.Text);
    Add('Dir. Bibliotecas : ' + SDirLibrary);
  end;
end;

// gravar as configurações efetuadas pelo usuário
procedure TfrmPrincipal.GravarConfiguracoes;
var
  ArqIni: TIniFile;
  I:      Integer;
begin
  ArqIni := TIniFile.Create(PathArquivoIni);
  try
    ArqIni.WriteString('CONFIG', 'DiretorioInstalacao', EdtDirDestino.Text);
    // ArqIni.WriteString('CONFIG', 'DelphiVersao', edtDelphiVersion.Text);
    ArqIni.WriteString('CONFIG', 'Plataforma', EdtPlatform.Text);
    ArqIni.WriteBool('CONFIG', 'FecharTortoise', CkbFecharTortoise.Checked);
    ArqIni.WriteBool('CONFIG', 'DexarSomenteLib', ChkDeixarSomenteLIB.Checked);

    for I := 0 to FrameDpk.Pacotes.Count - 1 do
      ArqIni.WriteBool('PACOTES', FrameDpk.Pacotes[I].Caption, FrameDpk.Pacotes[I].Checked);
  finally
    ArqIni.Free;
  end;
end;

// criação dos diretórios necessários
procedure TfrmPrincipal.CreateDirectoryLibrarysNotExist;
begin
  // Checa se existe diretório da plataforma
  if not DirectoryExists(SDirLibrary) then
    ForceDirectories(SDirLibrary);
  if not DirectoryExists(SDirLibrary + '\Debug') then
    ForceDirectories(SDirLibrary + '\Debug');
end;

procedure TfrmPrincipal.DeixarSomenteLib;
procedure Copiar(const Extensao: STRING);
var
  ListArquivos: TStringDynArray;
  Arquivo:      STRING;
  I:            Integer;
begin
  ListArquivos := TDirectory.GetFiles(IncludeTrailingPathDelimiter(SDirRoot) + 'Fontes', Extensao, TSearchOption.SoAllDirectories);
  for I        := Low(ListArquivos) to High(ListArquivos) do
  begin
    Arquivo := ExtractFileName(ListArquivos[I]);
    CopyFile(PWideChar(ListArquivos[I]), PWideChar(IncludeTrailingPathDelimiter(SDirLibrary) + Arquivo), False);
  end;
end;

begin
  // remover os path com o segundo parametro
  //
  FindDirs(IncludeTrailingPathDelimiter(SDirRoot));
  Copiar('*.dcr');
  Copiar('*.res');
  Copiar('*.dfm');
  Copiar('*.ini');
  Copiar('*.inc');
  FindDirs(IncludeTrailingPathDelimiter(SDirRoot) + 'Connectors\FireDAC');
  Copiar('*.dcr');
  Copiar('*.res');
  Copiar('*.dfm');
  Copiar('*.ini');
  Copiar('*.inc');
  FindDirs(IncludeTrailingPathDelimiter(SDirRoot) + 'Connectors\ZEOS');
  Copiar('*.dcr');
  Copiar('*.res');
  Copiar('*.dfm');
  Copiar('*.ini');
  Copiar('*.inc');
  FindDirs(IncludeTrailingPathDelimiter(SDirRoot) + 'Connectors\UniDAC');
  Copiar('*.dcr');
  Copiar('*.res');
  Copiar('*.dfm');
  Copiar('*.ini');
  Copiar('*.inc');
  FindDirs(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Packages\Delphi');
  Copiar('*.dcr');
  Copiar('*.res');
  Copiar('*.dfm');
  Copiar('*.ini');
  Copiar('*.inc');
  FindDirs(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\Connectors\FireDAC\Package');
  Copiar('*.dcr');
  Copiar('*.res');
  Copiar('*.dfm');
  Copiar('*.ini');
  Copiar('*.inc');
  //
  // original -> FindDirs(IncludeTrailingPathDelimiter(SDirRoot) + 'Fontes', False);
  //
  // Copiar('*.dcr');
  // Copiar('*.res');
  // Copiar('*.dfm');
  // Copiar('*.ini');
  // Copiar('*.inc');
end;

procedure TfrmPrincipal.AddLibraryPathToDelphiPath(const APath: STRING; const AProcurarRemover: STRING);
const
  Cs: PChar = 'Environment Variables';
var
  LParam, WParam: Integer;
  AResult:        Cardinal;
  ListaPaths:     TStringList;
  I:              Integer;
  PathsAtuais:    STRING;
  PathFonte:      STRING;
begin
  with ODW.Installations[IVersion] do
  begin
    // tentar ler o path configurado na ide do delphi, se não existir ler
    // a atual para complementar e fazer o override
    PathsAtuais := Trim(EnvironmentVariables.Values['PATH']);
    if PathsAtuais = '' then
      PathsAtuais := GetEnvironmentVariable('PATH');

    // manipular as strings
    ListaPaths := TStringList.Create;
    try
      ListaPaths.Clear;
      ListaPaths.Delimiter       := ';';
      ListaPaths.StrictDelimiter := True;
      ListaPaths.DelimitedText   := PathsAtuais;

      // verificar se existe algo do DW e remover do environment variable PATH do delphi
      if Trim(AProcurarRemover) <> '' then
      begin
        for I := ListaPaths.Count - 1 downto 0 do
        begin
          if Pos(AnsiUpperCase(AProcurarRemover), AnsiUpperCase(ListaPaths[I])) > 0 then
            ListaPaths.Delete(I);
        end;
      end;

      // adicionar o path
      ListaPaths.Add(APath);

      // escrever a variavel no override da ide
      ConfigData.WriteString(Cs, 'PATH', ListaPaths.DelimitedText);

      // enviar um broadcast de atualização para o windows
      WParam := 0;
      LParam := LongInt(Cs);
      SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, WParam, LParam, SMTO_NORMAL, 4000, AResult);
      if AResult <> 0 then
        raise Exception.Create('Ocorreu um erro ao tentar configurar o path: ' + SysErrorMessage(AResult));
    finally
      ListaPaths.Free;
    end;
  end;
end;

procedure TfrmPrincipal.FindDirs(ADirRoot: STRING; BAdicionar: Boolean = True);
var
  ODirList: TSearchRec;

function EProibido(const ADir: STRING): Boolean;
const
  LISTA_PROIBIDOS: array [0 .. 5] of STRING = ('quick', 'rave', 'laz', 'VerificarNecessidade', '__history', '__recovery');
var
  Str: STRING;
begin
  Result := False;
  for Str in LISTA_PROIBIDOS do
  begin
    Result := Pos(AnsiUpperCase(Str), AnsiUpperCase(ADir)) > 0;
    if Result then
      Break;
  end;
end;

begin
  ADirRoot := IncludeTrailingPathDelimiter(ADirRoot);

  if FindFirst(ADirRoot + '*.*', FaDirectory, ODirList) = 0 then
  begin
    try
      repeat
        if ((ODirList.Attr and FaDirectory) <> 0) and (ODirList.Name <> '.') and (ODirList.Name <> '..') and (not EProibido(ODirList.Name)) then
        begin
          with ODW.Installations[IVersion] do
          begin
            if BAdicionar then
            begin
              AddToLibrarySearchPath(ADirRoot + ODirList.Name, TPlatform);
              AddToLibraryBrowsingPath(ADirRoot + ODirList.Name, TPlatform);
            end
            else
              RemoveFromLibrarySearchPath(ADirRoot + ODirList.Name, TPlatform);
          end;
          // -- Procura subpastas
          FindDirs(ADirRoot + ODirList.Name, BAdicionar);
        end;
      until FindNext(ODirList) <> 0;
    finally
      SysUtils.FindClose(ODirList)
    end;
  end;
end;

// adicionar o paths ao library path do delphi
procedure TfrmPrincipal.AddLibrarySearchPath;
begin
  with ODW.Installations[IVersion] do
  begin
    // DATASNAP - incluir o path raiz por causa da localização do pacote
    if FrameDpk.RestEasyObjects_dpk.Checked then
    begin
      AddToLibrarySearchPath(SDirRoot, TPlatform); // arquivos do projeto ou global (*.pas contidos na uses Library (DCUs) é para qualquer projeto Search apenas para o pacote (PASs))
      AddToLibrarySearchPath(SDirLibrary, TPlatform); // arquivos do projeto ou global (*.pas contidos na uses Library (DCUs) é para qualquer projeto Search apenas para o pacote (PASs))
      AddToLibrarySearchPath(SDirLibrary, TPlatform); // arquivos do projeto ou global (*.pas contidos na uses Library (DCUs) é para qualquer projeto Search apenas para o pacote (PASs))
      AddToLibraryBrowsingPath(SDirLibrary, TPlatform); // Arquivos que devem ser usados sem ser compilados
      AddToDebugDCUPath(SDirLibrary + '\Debug', TPlatform);
    end;

    // CORE
    if FrameDpk.RestEasyObjects_dpk.Checked then
    begin
      FindDirs(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Packages\Delphi\' + PastaDW + '\RestEasyObjects.dpk', True);
      with ODW.Installations[IVersion] do
      begin
        AddToLibrarySearchPath(SDirLibrary, TPlatform); // arquivos do projeto ou global (*.pas contidos na uses Library (DCUs) é para qualquer projeto Search apenas para o pacote (PASs))

        AddToLibrarySearchPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source', TPlatform);
        AddToLibraryBrowsingPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source', TPlatform);

        AddToLibrarySearchPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\DmDados', TPlatform);
        AddToLibraryBrowsingPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\DmDados', TPlatform);

        AddToLibrarySearchPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\libs', TPlatform);
        AddToLibraryBrowsingPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\libs', TPlatform);

        AddToLibrarySearchPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\libs\JSON', TPlatform);
        AddToLibraryBrowsingPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\libs\JSON', TPlatform);

        AddToDebugDCUPath(SDirLibrary + '\Debug', TPlatform);
      end;
    end;
    // Conectores CORE
    if FrameDpk.RestEasyObjects_dpk.Checked then
    begin
      AddToLibrarySearchPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\Connectors\FireDAC', TPlatform);
      AddToLibraryBrowsingPath(IncludeTrailingPathDelimiter(SDirRoot) + 'CORE\Source\Connectors\FireDAC', TPlatform);
    end;
  end;

  LstMsgInstalacao.Items.Add('Adicionar à library path ao path do Windows: ' + SDirLibrary);
  AddLibraryPathToDelphiPath(SDirLibrary, 'DW');
end;

// setar a plataforma de compilação
procedure TfrmPrincipal.SetPlatformSelected;
var
  SVersao: STRING;
  STipo:   STRING;
begin
  IVersion := EdtDelphiVersion.ItemIndex;
  SVersao  := AnsiUpperCase(ODW.Installations[IVersion].VersionNumberStr);
  SDirRoot := IncludeTrailingPathDelimiter(EdtDirDestino.Text);

  STipo := 'Lib\Delphi\';

  if EdtPlatform.ItemIndex = 0 then // Win32
  begin
    TPlatform   := BpWin32;
    SDirLibrary := SDirRoot + STipo + 'Lib' + SVersao;
  end
  else if EdtPlatform.ItemIndex = 1 then // Win64
  begin
    TPlatform   := BpWin64;
    SDirLibrary := SDirRoot + STipo + 'Lib' + SVersao + 'x64';
  end;
end;

// Evento disparado a cada ação do instalador
procedure TfrmPrincipal.OutputCallLine(const Text: STRING);
begin
  // remover a warnings de conversão de string (delphi 2010 em diante)
  // as diretivas -W e -H não removem estas mensagens
  if (Pos('Warning: W1057', Text) <= 0) and ((Pos('Warning: W1058', Text) <= 0)) then
    WriteToTXT(PathArquivoLog, Text);
end;

// evento para setar os parâmetros do compilador antes de compilar
procedure TfrmPrincipal.BeforeExecute(Sender: TJclBorlandCommandLineTool);
begin
  // limpar os parâmetros do compilador
  Sender.Options.Clear;

  // não utilizar o dcc32.cfg
  if ODW.Installations[IVersion].SupportsNoConfig then
    Sender.Options.Add('--no-config');

  // -B = Build all units
  Sender.Options.Add('-B');
  // O+ = Optimization
  Sender.Options.Add('-$O-');
  // W- = Generate stack frames
  Sender.Options.Add('-$W+');
  // Y+ = Symbol reference info
  Sender.Options.Add('-$Y-');
  // -M = Make modified units
  Sender.Options.Add('-M');
  // -Q = Quiet compile
  Sender.Options.Add('-Q');
  // não mostrar warnings
  Sender.Options.Add('-H-');
  // não mostrar hints
  Sender.Options.Add('-W-');
  // -D<syms> = Define conditionals
  Sender.Options.Add('-DRELEASE');
  // -U<paths> = Unit directories
  Sender.AddPathOption('U', ODW.Installations[IVersion].LibFolderName[TPlatform]);
  Sender.AddPathOption('U', ODW.Installations[IVersion].LibrarySearchPath[TPlatform]);
  Sender.AddPathOption('U', SDirLibrary);
  // -I<paths> = Include directories
  Sender.AddPathOption('I', ODW.Installations[IVersion].LibrarySearchPath[TPlatform]);
  // -R<paths> = Resource directories
  Sender.AddPathOption('R', ODW.Installations[IVersion].LibrarySearchPath[TPlatform]);
  // -N0<path> = unit .dcu output directory
  Sender.AddPathOption('N0', SDirLibrary);
  Sender.AddPathOption('LE', SDirLibrary);
  Sender.AddPathOption('LN', SDirLibrary);

  with ODW.Installations[IVersion] do
  begin
    // -- Path de outros componentespara necessários
    // Sender.AddPathOption('U', ODW.Installations[IVersion].RootDir + 'caminho da lib do pacote');
    // -- Na versão XE2 por motivo da nova tecnologia FireMonkey, deve-se adicionar
    // -- os prefixos dos nomes, para identificar se será compilado para VCL ou FMX
    if VersionNumberStr = 'd16' then
      Sender.Options.Add('-NSData.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win');
    if MatchText(VersionNumberStr, ['d17', 'd18', 'd19', 'd20', 'd21', 'd22', 'd23', 'd24', 'd25']) then
      Sender.Options.Add('-NSWinapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Xml;Data;Datasnap;Web;Soap;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell');
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  IFor: Integer;
begin
  IVersion    := -1;
  SDirRoot    := '';
  SDirLibrary := '';
  SDirPackage := '';
  PastaDW     := '';

  ODW := TJclBorRADToolInstallations.Create;

  // popular o combobox de versões do delphi instaladas na máquina
  for IFor := 0 to ODW.Count - 1 do
  begin
    if ODW.Installations[IFor].VersionNumberStr = 'd3' then
      EdtDelphiVersion.Items.Add('Delphi 3')
    else if ODW.Installations[IFor].VersionNumberStr = 'd4' then
      EdtDelphiVersion.Items.Add('Delphi 4')
    else if ODW.Installations[IFor].VersionNumberStr = 'd5' then
      EdtDelphiVersion.Items.Add('Delphi 5')
    else if ODW.Installations[IFor].VersionNumberStr = 'd6' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 6');
      PastaDW := ODW.Installations[IFor].VersionNumberStr;
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd7' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 7');
      PastaDW := ODW.Installations[IFor].VersionNumberStr;
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd9' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 2005');
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd10' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 2006');
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd11' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 2007');
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd12' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 2009');
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd14' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 2010');
      PastaDW := 'D2010';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd15' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE');
      PastaDW := 'XE';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd16' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE2');
      PastaDW := 'XE2';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd17' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE3');
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd18' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE4');
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd19' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE5');
      PastaDW := 'XE5';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd20' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE6');
      PastaDW := 'XE6';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd21' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE7');
      PastaDW := 'XE7';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd22' then
    begin
      EdtDelphiVersion.Items.Add('Delphi XE8');
      PastaDW := 'XE8';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd23' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 10 Seattle');
      PastaDW := 'Seattle';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd24' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 10.1 Berlin');
      PastaDW := 'Berlin';
    end
    else if ODW.Installations[IFor].VersionNumberStr = 'd25' then
    begin
      EdtDelphiVersion.Items.Add('Delphi 10.2 Tokyo');
      PastaDW := 'Tokyo';
    end;

    // -- Evento disparado antes de iniciar a execução do processo.
    ODW.Installations[IFor].DCC32.OnBeforeExecute := BeforeExecute;

    // -- Evento para saidas de mensagens.
    ODW.Installations[IFor].OutputCallback := OutputCallLine;
  end;
  ClbDelphiVersion.Items.Text := EdtDelphiVersion.Items.Text;

  if EdtDelphiVersion.Items.Count > 0 then
  begin
    EdtDelphiVersion.ItemIndex := 0;
    IVersion                   := 0;
  end;

  LerConfiguracoes;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ODW.Free;
end;

procedure TfrmPrincipal.RemoverDiretoriosEPacotesAntigos;
var
  ListaPaths: TStringList;
  I:          Integer;
begin
  ListaPaths := TStringList.Create;
  try
    ListaPaths.StrictDelimiter := True;
    ListaPaths.Delimiter       := ';';
    with ODW.Installations[IVersion] do
    begin
      // remover do search path
      ListaPaths.Clear;
      ListaPaths.DelimitedText := RawLibrarySearchPath[TPlatform];
      for I                    := ListaPaths.Count - 1 downto 0 do
      begin
        if Pos('DW', AnsiUpperCase(ListaPaths[I])) > 0 then
          ListaPaths.Delete(I);
      end;
      RawLibrarySearchPath[TPlatform] := ListaPaths.DelimitedText;
      // remover do browse path
      ListaPaths.Clear;
      ListaPaths.DelimitedText := RawLibraryBrowsingPath[TPlatform];
      for I                    := ListaPaths.Count - 1 downto 0 do
      begin
        if Pos('DW', AnsiUpperCase(ListaPaths[I])) > 0 then
          ListaPaths.Delete(I);
      end;
      RawLibraryBrowsingPath[TPlatform] := ListaPaths.DelimitedText;
      // remover do Debug DCU path
      ListaPaths.Clear;
      ListaPaths.DelimitedText := RawDebugDCUPath[TPlatform];
      for I                    := ListaPaths.Count - 1 downto 0 do
      begin
        if Pos('DW', AnsiUpperCase(ListaPaths[I])) > 0 then
          ListaPaths.Delete(I);
      end;
      RawDebugDCUPath[TPlatform] := ListaPaths.DelimitedText;
      // remover pacotes antigos
      for I := IdePackages.Count - 1 downto 0 do
      begin
        if Pos('DW', AnsiUpperCase(IdePackages.PackageFileNames[I])) > 0 then
          IdePackages.RemovePackage(IdePackages.PackageFileNames[I]);
      end;
    end;
  finally
    ListaPaths.Free;
  end;
end;

procedure TfrmPrincipal.GetDriveLetters(AList: TStrings);
var
  VDrivesSize: Cardinal;
  VDrives:     array [0 .. 128] of Char;
  VDrive:      PChar;
  VDriveType:  Cardinal;
begin
  AList.BeginUpdate;
  try
    // clear the list from possible leftover from prior operations
    AList.Clear;
    VDrivesSize := GetLogicalDriveStrings(SizeOf(VDrives), VDrives);
    if VDrivesSize = 0 then
      Exit;

    VDrive := VDrives;
    while VDrive^ <> #0 do
    begin
      // adicionar somente drives fixos
      VDriveType := GetDriveType(VDrive);
      if VDriveType = DRIVE_FIXED then
        AList.Add(StrPas(VDrive));

      Inc(VDrive, SizeOf(VDrive));
    end;
  finally
    AList.EndUpdate;
  end;
end;

procedure TfrmPrincipal.RemoverArquivosAntigosDoDisco;
var
  PathBat:         STRING;
  DriverList:      TStringList;
  ConteudoArquivo: STRING;
  I:               Integer;
begin
  PathBat := ExtractFilePath(ParamStr(0)) + 'apagarDW.bat';

  // listar driver para montar o ConteudoArquivo
  DriverList := TStringList.Create;
  try
    GetDriveLetters(DriverList);
    ConteudoArquivo := '@echo off' + SLineBreak;
    for I           := 0 to DriverList.Count - 1 do
    begin
      ConteudoArquivo := ConteudoArquivo + StringReplace(DriverList[I], '\', '', []) + SLineBreak;
      ConteudoArquivo := ConteudoArquivo + 'cd\' + SLineBreak;
      ConteudoArquivo := ConteudoArquivo + 'del RestEasyObjects*.dcp RestEasyObjects*.bpl RestEasyObjects*.bpi RestEasyObjects*.lib RestEasyObjects*.hpp /s' + SLineBreak;
      ConteudoArquivo := ConteudoArquivo + SLineBreak;
    end;

    WriteToTXT(PathBat, ConteudoArquivo, False);
  finally
    DriverList.Free;
  end;

  RunAsAdminAndWaitForCompletion(Handle, PathBat);
end;

function TfrmPrincipal.GetPathDWInc: TFileName;
begin
  Result := IncludeTrailingPathDelimiter(EdtDirDestino.Text) + 'CORE\Source\uRESTDW.inc';
end;

// botão de compilação e instalação dos pacotes selecionados no treeview
procedure TfrmPrincipal.BtnInstalarDWClick(Sender: TObject);
var
  IDpk:       Integer;
  BRunOnly:   Boolean;
  NomePacote: STRING;
  Cabecalho:  STRING;
  IListaVer:  Integer;

procedure Logar(const AString: STRING);
begin
  LstMsgInstalacao.Items.Add(AString);
  LstMsgInstalacao.ItemIndex := LstMsgInstalacao.Count - 1;
  Application.ProcessMessages;

  WriteToTXT(PathArquivoLog, AString);
end;

procedure MostrarMensagemInstalado(const AMensagem: STRING; const AErro: STRING = '');
var
  Msg: STRING;
begin

  if Trim(AErro) = EmptyStr then
  begin
    case SDestino of
      TdSystem:
        Msg := Format(AMensagem + ' em "%s"', [PathSystem]);
      TdDelphi:
        Msg := Format(AMensagem + ' em "%s"', [SPathBin]);
      TdNone:
        Msg := 'Tipo de destino "nenhum" não aceito!';
    end;
  end
  else
  begin
    Inc(FCountErros);

    case SDestino of
      TdSystem:
        Msg := Format(AMensagem + ' em "%s": "%s"', [PathSystem, AErro]);
      TdDelphi:
        Msg := Format(AMensagem + ' em "%s": "%s"', [SPathBin, AErro]);
      TdNone:
        Msg := 'Tipo de destino "nenhum" não aceito!';
    end;
  end;

  WriteToTXT(PathArquivoLog, '');
  Logar(Msg);
end;

procedure IncrementaBarraProgresso;
begin
  PgbInstalacao.Position := PgbInstalacao.Position + 1;
  Application.ProcessMessages;
end;

procedure DesligarDefineDWInc(const ADefineName: STRING; const ADesligar: Boolean);
var
  F: TStringList;
  I: Integer;
begin
  F := TStringList.Create;
  try
    F.LoadFromFile(GetPathDWInc);
    for I := 0 to F.Count - 1 do
    begin
      if Pos(ADefineName.ToUpper, F[I].ToUpper) > 0 then
      begin
        if ADesligar then
        begin
          F[I] := '{.$DEFINE ' + ADefineName + '}';
        end
        else
        begin
          F[I] := '{$DEFINE ' + ADefineName + '}';
        end;

        Break;
      end;
    end;
    F.SaveToFile(GetPathDWInc);
  finally
    F.Free;
  end;
end;

begin
  DesligarDefineDWInc('RESTKBMMEMTABLE', (not CkUseKBMemTable.Checked));
  DesligarDefineDWInc('RESJEDI', (not CkUseJEDI.Checked));
  DesligarDefineDWInc('RESTFDMEMTABLE', (not CkUseFireDAC.Checked));

  for IListaVer := 0 to ClbDelphiVersion.Count - 1 do
  begin
    // Instalar nas versões marcadas, permitindo várias versões do Delphi.
    if ClbDelphiVersion.Checked[IListaVer] then
    begin
      LstMsgInstalacao.Clear;
      PgbInstalacao.Position := 0;

      // Define a versão marcada no combobox.
      EdtDelphiVersion.ItemIndex := IListaVer;
      EdtDelphiVersionChange(EdtDelphiVersion);

      // define dados da plataforna selecionada
      SetPlatformSelected;

      // mostra na tela os dados da versão a ser instalada
      MostraDadosVersao();

      FCountErros := 0;

      BtnInstalarDW.Enabled := False;
      WizPgInstalacao.EnableButton(BkNext, False);
      WizPgInstalacao.EnableButton(BkBack, False);
      WizPgInstalacao.EnableButton(TJvWizardButtonKind(BkCancel), False);
      try
        Cabecalho := 'Caminho: ' + EdtDirDestino.Text + SLineBreak + 'Versão do delphi: ' + EdtDelphiVersion.Text + ' (' + IntToStr(IVersion) + ')' + SLineBreak + 'Plataforma: ' + EdtPlatform.Text + '(' + IntToStr(Integer(TPlatform)) + ')' + SLineBreak +
          StringOfChar('=', 80);

        // limpar o log
        LstMsgInstalacao.Clear;
        WriteToTXT(PathArquivoLog, Cabecalho, False);

        // setar barra de progresso
        PgbInstalacao.Position := 0;
        PgbInstalacao.Max      := (FrameDpk.Pacotes.Count * 2) + 6;

        // *************************************************************************
        // removendo arquivos antigos se configurado
        // *************************************************************************
        if CkbRemoverArquivosAntigos.Checked then
        begin
          if Application.MessageBox('você optou por limpar arquivos antigos do DW do seu computador, essa ação pode demorar vários minutos, deseja realmente continuar com está ação?', 'Limpar', MB_YESNO + MB_DEFBUTTON2) = ID_YES then
          begin
            Logar('Removendo arquivos antigos do disco...');
            RemoverArquivosAntigosDoDisco;
          end;
        end;
        IncrementaBarraProgresso;

        // *************************************************************************
        // Cria diretório de biblioteca da versão do delphi selecionada,
        // só será criado se não existir
        // *************************************************************************
        Logar('Criando diretórios de bibliotecas...');
        CreateDirectoryLibrarysNotExist;
        IncrementaBarraProgresso;

        // *************************************************************************
        // remover paths do delphi
        // *************************************************************************
        Logar('Removendo diretorios e pacotes antigos instalados...');
        RemoverDiretoriosEPacotesAntigos;
        IncrementaBarraProgresso;

        // *************************************************************************
        // Adiciona os paths dos fontes na versão do delphi selecionada
        // *************************************************************************
        Logar('Adicionando Library Paths...');
        AddLibrarySearchPath;
        IncrementaBarraProgresso;

        // *************************************************************************
        // compilar os pacotes primeiramente
        // *************************************************************************
        Logar('');
        Logar('COMPILANDO OS PACOTES...');
        for IDpk := 0 to FrameDpk.Pacotes.Count - 1 do
        begin
          NomePacote := FrameDpk.Pacotes[IDpk].Caption;

          // Busca diretório do pacote
          ExtrairDiretorioPacote(NomePacote);

          if (IsDelphiPackage(NomePacote)) and (FrameDpk.Pacotes[IDpk].Checked) then
          begin
            WriteToTXT(PathArquivoLog, '');

            if ODW.Installations[IVersion].CompilePackage(SDirPackage + NomePacote, SDirLibrary, SDirLibrary) then
              Logar(Format('Pacote "%s" compilado com sucesso.', [NomePacote]))
            else
            begin
              Inc(FCountErros);
              Logar(Format('Erro ao compilar o pacote "%s".', [NomePacote]));
              // parar no primeiro erro para evitar de compilar outros pacotes que
              // precisam do pacote que deu erro
              Break
            end;
          end;

          IncrementaBarraProgresso;
        end;

        // *************************************************************************
        // instalar os pacotes somente se não ocorreu erro na compilação e plataforma for Win32
        // *************************************************************************
        if (EdtPlatform.ItemIndex = 0) then
        begin
          if (FCountErros <= 0) then
          begin
            Logar('');
            Logar('INSTALANDO OS PACOTES...');

            for IDpk := 0 to FrameDpk.Pacotes.Count - 1 do
            begin
              NomePacote := FrameDpk.Pacotes[IDpk].Caption;

              // Busca diretório do pacote
              ExtrairDiretorioPacote(NomePacote);
              if (IsDelphiPackage(NomePacote)) and (FrameDpk.Pacotes[IDpk].Checked) then
              begin
                // instalar somente os pacotes de designtime
                GetDPKFileInfo(SDirPackage + NomePacote, BRunOnly);
                if not BRunOnly then
                begin
                  // se o pacote estiver marcado instalar, senão desinstalar
                  if FrameDpk.Pacotes[IDpk].Checked then
                  begin
                    WriteToTXT(PathArquivoLog, '');
                    if ODW.Installations[IVersion].InstallPackage(SDirPackage + NomePacote, SDirLibrary, SDirLibrary) then
                      Logar(Format('Pacote "%s" instalado com sucesso.', [NomePacote]))
                    else
                    begin
                      Inc(FCountErros);
                      Logar(Format('Ocorreu um erro ao instalar o pacote "%s".', [NomePacote]));
                      Break;
                    end;
                  end
                  else
                  begin
                    // WriteToTXT(PathArquivoLog, '');
                    // if ODW.Installations[IVersion].UninstallPackage(SDirPackage + NomePacote, SDirLibrary, SDirLibrary) then
                    // Logar(Format('Pacote "%s" removido com sucesso...', [NomePacote]));
                  end;
                end;
              end;

              IncrementaBarraProgresso;
            end;
          end
          else
          begin
            Logar('');
            Logar('Abortando... Ocorreram erros na compilação dos pacotes.');
          end;
        end
        else
        begin
          Logar('');
          Logar('Para a plataforma de 64 bits os pacotes são somente compilados.');
        end;

        if FCountErros > 0 then
        begin
          if Application.MessageBox(PWideChar('Ocorreram erros durante o processo de instalação, ' + SLineBreak + 'para maiores informações verifique o arquivo de log gerado.' + SLineBreak + SLineBreak + 'Deseja visualizar o arquivo de log gerado?'),
            'Instalação', MB_ICONQUESTION + MB_YESNO) = ID_YES then
          begin
            BtnVisualizarLogCompilacao.Click;
            Break
          end;
        end;

        // *************************************************************************
        // não instalar outros requisitos se ocorreu erro anteriormente
        // *************************************************************************
        if FCountErros <= 0 then
        begin
          Logar('');
          Logar('INSTALANDO OUTROS REQUISITOS...');

          // *************************************************************************
          // deixar somente a pasta lib se for configurado assim
          // *************************************************************************
          if ChkDeixarSomenteLIB.Checked then
          begin
            try
              DeixarSomenteLib;

              MostrarMensagemInstalado('Limpeza library path com sucesso');
              MostrarMensagemInstalado('Copia dos arquivos necessário.');
            except
              on E: Exception do
              begin
                MostrarMensagemInstalado('Ocorreu erro ao limpas os path e copiar arquivos' + SLineBreak + E.Message)
              end;
            end;
          end;
        end;
      finally
        BtnInstalarDW.Enabled := True;
        WizPgInstalacao.EnableButton(BkBack, True);
        WizPgInstalacao.EnableButton(BkNext, FCountErros = 0);
        WizPgInstalacao.EnableButton(TJvWizardButtonKind(BkCancel), True);
      end;
    end;
  end;

  if FCountErros = 0 then
  begin
    Application.MessageBox(PWideChar('Pacotes compilados e instalados com sucesso! ' + SLineBreak + 'Clique em "Próximo" para finalizar a instalação.'), 'Instalação', MB_ICONINFORMATION + MB_OK);
  end;

end;

// chama a caixa de dialogo para selecionar o diretório de instalação
// seria bom que a caixa fosse aquele que possui o botão de criar pasta
procedure TfrmPrincipal.BtnSelecDirInstallClick(Sender: TObject);
var
  Dir: STRING;
begin
  if SelectDirectory('Selecione o diretório de instalação', '', Dir, [SdNewFolder, SdNewUI, SdValidateDir]) then
    EdtDirDestino.Text := Dir;
end;

// quando trocar a versão verificar se libera ou não o combo
// da plataforma de compilação
procedure TfrmPrincipal.ClbDelphiVersionClick(Sender: TObject);
begin
  if MatchText(ODW.Installations[ClbDelphiVersion.ItemIndex].VersionNumberStr, ['d3', 'd4', 'd5']) then
  begin
    Application.MessageBox('Versão do delphi não suportada pelo REST Dataware.', 'Erro.', MB_OK + MB_ICONERROR);
  end;
end;

procedure TfrmPrincipal.EdtDelphiVersionChange(Sender: TObject);
begin
  IVersion := EdtDelphiVersion.ItemIndex;
  SPathBin := IncludeTrailingPathDelimiter(ODW.Installations[IVersion].BinFolderName);
  // -- Plataforma só habilita para Delphi XE2
  // -- Desabilita para versão diferente de Delphi XE2
  // edtPlatform.Enabled := oDW.Installations[iVersion].VersionNumber >= 9;
  // if oDW.Installations[iVersion].VersionNumber < 9 then
  EdtPlatform.ItemIndex := 0;
end;

// quando clicar em alguma das urls chamar o link mostrado no caption
procedure TfrmPrincipal.URLClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PWideChar(TLabel(Sender).Caption), '', '', 1);
end;

procedure TfrmPrincipal.WizPgInicioNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  // Verificar se o delphi está aberto
  {$IFNDEF DEBUG}
  if ODW.AnyInstanceRunning then
  begin
    Stop := True;
    Application.MessageBox('Feche a IDE do delphi antes de continuar.', PWideChar(Application.Title), MB_ICONERROR + MB_OK);
  end;
  {$ENDIF}
  // Verificar se o tortoise está instalado, se não estiver, não mostrar a aba de atualização
  // o usuário deve utilizar software proprio e fazer manualmente
  // pedido do forum
  WizPgObterFontes.Visible := TSVN_Class.SVNInstalled;
end;

procedure TfrmPrincipal.WizPgInstalacaoEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var
  IFor: Integer;
begin
  // para 64 bit somente compilar
  if TPlatform = BpWin32 then // Win32
    BtnInstalarDW.Caption := 'Instalar'
  else // win64
    BtnInstalarDW.Caption := 'Compilar';

  LbInfo.Clear;
  for IFor := 0 to ClbDelphiVersion.Count - 1 do
  begin
    // Só pega os dados da 1a versão selecionada, para mostrar na tela qual vai iniciar
    if ClbDelphiVersion.Checked[IFor] then
    begin
      LbInfo.Items.Add('Instalar : ' + ClbDelphiVersion.Items[Ifor] + ' ' + EdtPlatform.Text);
    end;
  end;
end;

procedure TfrmPrincipal.WizPgInstalacaoNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if (LstMsgInstalacao.Count <= 0) then
  begin
    Stop := True;
    Application.MessageBox('Clique no botão instalar antes de continuar.', 'Erro.', MB_OK + MB_ICONERROR);
  end;

  if (FCountErros > 0) then
  begin
    Stop := True;
    Application.MessageBox('Ocorreram erros durante a compilação e instalação dos pacotes, verifique.', 'Erro.', MB_OK + MB_ICONERROR);
  end;
end;

procedure TfrmPrincipal.WizPgConfiguracaoNextButtonClick(Sender: TObject; var Stop: Boolean);
var
  IFor: Integer;
  BChk: Boolean;
begin
  BChk     := False;
  for IFor := 0 to ClbDelphiVersion.Count - 1 do
  begin
    if ClbDelphiVersion.Checked[IFor] then
      BChk := True;
  end;

  if not BChk then
  begin
    Stop := True;
    ClbDelphiVersion.SetFocus;
    Application.MessageBox('Para continuar escolha a versão do Delphi para a qual deseja instalar o DW.', 'Erro.', MB_OK + MB_ICONERROR);
  end;

  // verificar se foi informado o diretório
  if Trim(EdtDirDestino.Text) = EmptyStr then
  begin
    Stop := True;
    EdtDirDestino.SetFocus;
    Application.MessageBox('Diretório de instalação não foi informado.', 'Erro.', MB_OK + MB_ICONERROR);
  end;

  // prevenir plataforma em branco
  if Trim(EdtPlatform.Text) = '' then
  begin
    Stop := True;
    EdtPlatform.SetFocus;
    Application.MessageBox('Plataforma de compilação não foi informada.', 'Erro.', MB_OK + MB_ICONERROR);
  end;

  // Gravar as configurações em um .ini para utilizar depois
  GravarConfiguracoes;
end;

procedure TfrmPrincipal.WizPgObterFontesEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  // verificar se o checkout já foi feito se sim, atualizar
  // se não fazer o checkout
  if IsCheckOutJaFeito(EdtDirDestino.Text) then
  begin
    LblInfoObterFontes.Caption   := 'Clique em "Atualizar" para efetuar a atualização do repositório DW.';
    BtnSVNCheckoutUpdate.Caption := 'Atualizar...';
    BtnSVNCheckoutUpdate.Tag     := -1;
  end
  else
  begin
    LblInfoObterFontes.Caption   := 'Clique em "Download" para efetuar o download do repositório DW.';
    BtnSVNCheckoutUpdate.Caption := 'Download...';
    BtnSVNCheckoutUpdate.Tag     := 1;
  end;
end;

procedure TfrmPrincipal.BtnSVNCheckoutUpdateClick(Sender: TObject);
begin
  // chamar o método de update ou checkout conforme a necessidade
  if TButton(Sender).Tag > 0 then
  begin
    // criar o diretório onde será baixado o repositório
    if not SysUtils.DirectoryExists(EdtDirDestino.Text) then
    begin
      if not SysUtils.ForceDirectories(EdtDirDestino.Text) then
      begin
        raise EDirectoryNotFoundException.Create('Ocorreu o seguinte erro ao criar o diretório' + SLineBreak + SysErrorMessage(GetLastError));
      end;
    end;

    // checkout
    TSVN_Class.SVNTortoise_CheckOut(EdtURL.Text, EdtDirDestino.Text, CkbFecharTortoise.Checked);
  end
  else
  begin
    // update
    TSVN_Class.SVNTortoise_Update(EdtDirDestino.Text, CkbFecharTortoise.Checked);
  end;
end;

procedure TfrmPrincipal.BtnVisualizarLogCompilacaoClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PWideChar(PathArquivoLog), '', '', 1);
end;

procedure TfrmPrincipal.BtnWCInfoClick(Sender: TObject);
begin
  // capturar informações da última revisão
  TSVN_Class.GetRevision(EdtDirDestino.Text);
  ShowMessage('Última Revisão: ' + TSVN_Class.WCInfo.Revision + SLineBreak + 'Autor: ' + TSVN_Class.WCInfo.Author + SLineBreak + 'Data: ' + TSVN_Class.WCInfo.Date);
end;

procedure TfrmPrincipal.CkUseFireDACClick(Sender: TObject);
begin
  CkUseJEDI.Checked       := False;
  CkUseKBMemTable.Checked := False;
end;

procedure TfrmPrincipal.CkUseJEDIClick(Sender: TObject);
begin
  CkUseFireDAC.Checked    := False;
  CkUseKBMemTable.Checked := False;
end;

procedure TfrmPrincipal.CkUseKBMemTableClick(Sender: TObject);
begin
  CkUseJEDI.Checked    := False;
  CkUseFireDAC.Checked := False;
end;

procedure TfrmPrincipal.WizPgObterFontesNextButtonClick(Sender: TObject; var Stop: Boolean);
var
  I:          Integer;
  NomePacote: STRING;
begin
  GravarConfiguracoes;

  // verificar se os pacotes existem antes de seguir para o próximo paso
  for I := 0 to FrameDpk.Pacotes.Count - 1 do
  begin
    if FrameDpk.Pacotes[I].Checked then
    begin
      SDirRoot   := IncludeTrailingPathDelimiter(EdtDirDestino.Text);
      NomePacote := FrameDpk.Pacotes[I].Caption;

      ExtrairDiretorioPacote(NomePacote);
      if Trim(SDirPackage) = '' then
        raise Exception.Create('Não foi possível retornar o diretório do pacote : ' + NomePacote);

      if IsDelphiPackage(NomePacote) then
      begin
        if not FileExists(IncludeTrailingPathDelimiter(SDirPackage) + NomePacote) then
        begin
          Stop := True;
          Application.MessageBox(PWideChar(Format('Pacote "%s" não encontrado, efetue novamente o download do repositório', [NomePacote])), 'Erro.', MB_ICONERROR + MB_OK);
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmPrincipal.WizPrincipalCancelButtonClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja realmente cancelar a instalação?', 'Fechar', MB_ICONQUESTION + MB_YESNO) = ID_YES then
  begin
    Self.Close;
  end;
end;

procedure TfrmPrincipal.WizPrincipalFinishButtonClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmPrincipal.WriteToTXT(const ArqTXT: STRING; ABinaryString: AnsiString; const AppendIfExists, AddLineBreak: Boolean);
var
  FS:        TFileStream;
  LineBreak: AnsiString;
begin
  FS := TFileStream.Create(ArqTXT, IfThen(AppendIfExists and FileExists(ArqTXT), Integer(FmOpenReadWrite), Integer(FmCreate)) or FmShareDenyWrite);
  try
    FS.Seek(0, SoFromEnd); // vai para EOF
    FS.Write(Pointer(ABinaryString)^, Length(ABinaryString));

    if AddLineBreak then
    begin
      LineBreak := SLineBreak;
      FS.Write(Pointer(LineBreak)^, Length(LineBreak));
    end;
  finally
    FS.Free;
  end;
end;

end.
