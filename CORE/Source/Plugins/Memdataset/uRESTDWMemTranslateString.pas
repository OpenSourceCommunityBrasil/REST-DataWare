unit uRESTDWMemTranslateString;
{$I ..\..\Source\Includes\uRESTDWPlataform.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface
uses
  Classes,
  uRESTDWMemComponentBase, uRESTDWMemResources;
type
  /// This component is for string-replacement. All replacements are based on
  /// delimiter-encapsulated words. The delimiters can be freely defined. The default
  /// is : "%"
  ///
  /// The following replacements are defined:
  /// APPL_NAME : Name of the application out of the File-Version-Information
  /// COMPANY_NAME : Name of the company of the application out of the File-Version-Information
  /// DATE : Current Date
  /// TIME : Current Time
  /// DATETIME : Current Date/Time
  /// EXENAME : Filename of the application
  /// FILENAME : Filename of the application without extention
  /// FULLDIREXE : Directory of the application exe file
  /// FORMNAME : Name of the current form
  /// FORMCAPTION : Caption of the current form
  /// FILEVERSION : Version of the application file out of the File-Version-Information
  /// PRODUCTVERSION : Product version of the application out of the File-Version-Information
  /// SCREENSIZE : Size of the screen in format widthxheight
  /// DESKTOPSIZE : Size of the desktop in format widthxheight
  TProcessCommandEvent = procedure(Sender: TObject; const Command: string;
    var CommandResult: string; var Changed: Boolean) of object;
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32)]
  {$ENDIF RTL230_UP}
  TJvTranslateString = class(TJvComponent)
  private
    FAppNameHandled: Boolean;
    FAppName: string;
    FCompanyNameHandled: Boolean;
    FCompanyName: string;
    FFileVersionHandled: Boolean;
    FFileVersion: string;
    FProductVersionHandled: Boolean;
    FProductVersion: string;
    FDateFormat: string;
    FDateSeparator: Char;
    FTimeSeparator: Char;
    FDateTimeFormat: string;
    FLeftDelimiter: string;
    FRightDelimiter: string;
    FTimeFormat: string;
    FOnProcessCommand: TProcessCommandEvent;
    procedure SetDateFormat(const Value: string);
    procedure SetDateTimeFormat(const Value: string);
    procedure SetTimeFormat(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    function TranslateString(InString: string; var Changed: Boolean): string; overload;
    function TranslateString(InString: string): string; overload;
  published
    property DateFormat: string read FDateFormat write SetDateFormat;
    property DateSeparator: Char read FDateSeparator write FDateSeparator;
    property DateTimeFormat: string read FDateTimeFormat write SetDateTimeFormat;
    property LeftDelimiter: string read FLeftDelimiter write FLeftDelimiter;
    property RightDelimiter: string read FRightDelimiter write FRightDelimiter;
    property TimeFormat: string read FTimeFormat write SetTimeFormat;
    property TimeSeparator: Char read FTimeSeparator write FTimeSeparator;
    property OnProcessCommand: TProcessCommandEvent read FOnProcessCommand write FOnProcessCommand;
  end;
implementation
uses
  {$IFDEF HAS_UNIT_SYSTEM_UITYPES}
  System.UITypes,
  {$ENDIF}
  SysUtils, Types;

const
  cAppNameMask = 'APPL_NAME';
  cCompanyNameMask = 'COMPANY_NAME';
  cDateMask = 'DATE';
  cTimeMask = 'TIME';
  cDateTimeMask = 'DATETIME';
  cExeNameMask = 'EXENAME';
  cFileNameMask = 'FILENAME';
  cFullDirExeMask = 'FULLDIREXE';
  cFormNameMask = 'FORMNAME';
  cFormCaptionMask = 'FORMCAPTION';
  cFileVersionMask = 'FILEVERSION';
  cProductVersionMask = 'PRODUCTVERSION';
  cScreenSizeMask = 'SCREENSIZE';
  cDesktopSizeMask = 'DESKTOPSIZE';
  cDefaultAppName = 'MyJVCLApplication';
  cDefaultCompanyName = 'MyCompany';
  cDefaultVersion = '0.0.0.0';
constructor TJvTranslateString.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAppNameHandled := False;
  FCompanyNameHandled := False;
  FLeftDelimiter := '%';
  FRightDelimiter := '%';
  FDateFormat := 'dd_mm_yyyy';
  FTimeFormat := 'hh_nn_ss';
  FDateTimeFormat := 'dd_mm_yyyy hh_nn_ss';
  FDateSeparator := chr(255);
  FTimeSeparator := chr(255);
  FProductVersionHandled := False;
  FFileVersionHandled := False;
end;
procedure TJvTranslateString.SetDateFormat(const Value: string);
var i : Integer;
begin
  FDateFormat := Value;
  if DateSeparator = chr(255) then
    for i := 1 to Length(Value) do
      if not CharInSet(Value[i],['0'..'9']) then
      begin
        DateSeparator:= Value[i];
        Exit;
      end;
end;
procedure TJvTranslateString.SetDateTimeFormat(const Value: string);
begin
  FDateTimeFormat := Value;
end;
procedure TJvTranslateString.SetTimeFormat(const Value: string);
var i : Integer;
begin
  FTimeFormat := Value;
  if TimeSeparator = chr(255) then
    for i := 1 to Length(Value) do
      if not CharInSet(Value[i],['0'..'9']) then
      begin
        TimeSeparator:= Value[i];
        Exit;
      end;
end;
function TJvTranslateString.TranslateString(InString: string): string;
var
  I, J: Integer;
  Command: string;
  CommandResult: string;
begin
  Result := '';
  while InString <> '' do
  begin
    I := Pos(LeftDelimiter, InString);
    if I = 0 then
    begin
      Result := Result + InString;
      InString := '';
    end
    else
    begin
      Result := Result + Copy(InString, 1, I-1);
      Delete(InString, 1, i);
      J := Pos(RightDelimiter, InString);
      if J > 0 then
      begin
        Command := Copy(InString, 1, J-1);
        //TODO XyberX
//        if ProcessCommand(Command, CommandResult) then
//        begin
//          Result := Result + CommandResult;
//          Delete(InString, 1, J);
//        end
//        else
//        begin
          Result := Result + Copy(InString, 1, J-1);
          Delete(InString, 1, J-1);
//        end;
      end
      else
      begin
        Result := Result + LeftDelimiter + InString;
        InString := '';
      end
    end;
  end;
end;
function TJvTranslateString.TranslateString(InString: string; var Changed: Boolean): string;
var
  I, J: Integer;
  Command: string;
  CommandResult: string;
begin
  Result := '';
  Changed := False;
  while InString <> '' do
  begin
    I := Pos(LeftDelimiter, InString);
    if I = 0 then
    begin
      Result := Result + InString;
      InString := '';
    end
    else
    begin
      Result := Result + Copy(InString, 1, I-1);
      Delete(InString, 1, I);
      J := Pos(RightDelimiter, InString);
      Command := Copy(InString, 1, J-1);
      //TODO XyberX
//      if ProcessCommand(Command, CommandResult) then
//      begin
//        Result := Result + CommandResult;
//        Delete(InString, 1, J);
//        Changed := True;
//      end
//      else
//      begin
        Result := Result + Copy(InString, 1, J-1);
        Delete(InString, 1, J-1);
//      end;
    end;
  end;
end;
{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);
finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
end.
