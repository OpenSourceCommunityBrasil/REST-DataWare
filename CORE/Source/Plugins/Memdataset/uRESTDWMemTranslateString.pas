Unit uRESTDWMemTranslateString;
{$I uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface
Uses
  Classes,
  uRESTDWBasic, uRESTDWMemResources;
Type
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
  TProcessCommandEvent = Procedure(Sender: TObject; Const Command: string;
    Var CommandResult: string; Var Changed: Boolean) Of object;
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32)]
  {$ENDIF RTL230_UP}
  TJvTranslateString = Class(TJvComponent)
  Private
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
    Procedure SetDateFormat(Const Value: string);
    Procedure SetDateTimeFormat(Const Value: string);
    Procedure SetTimeFormat(Const Value: string);
  Public
    Constructor Create(AOwner: TComponent); override;
    Function TranslateString(InString: string; Var Changed: Boolean): string; overload;
    Function TranslateString(InString: string): string; overload;
  Published
    property DateFormat: string read FDateFormat write SetDateFormat;
    property DateSeparator: Char read FDateSeparator write FDateSeparator;
    property DateTimeFormat: string read FDateTimeFormat write SetDateTimeFormat;
    property LeftDelimiter: string read FLeftDelimiter write FLeftDelimiter;
    property RightDelimiter: string read FRightDelimiter write FRightDelimiter;
    property TimeFormat: string read FTimeFormat write SetTimeFormat;
    property TimeSeparator: Char read FTimeSeparator write FTimeSeparator;
    property OnProcessCommand: TProcessCommandEvent read FOnProcessCommand write FOnProcessCommand;
  End;
Implementation
Uses
  {$IFDEF HAS_UNIT_SYSTEM_UITYPES}
  System.UITypes,
  {$ENDIF}
  SysUtils, Types;

Const
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
Constructor TJvTranslateString.Create(AOwner: TComponent);
Begin
  Inherited Create(AOwner);
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
End;
Procedure TJvTranslateString.SetDateFormat(Const Value: string);
Var i : Integer;
Begin
  FDateFormat := Value;
  If DateSeparator = chr(255) Then
    For i := 1 To Length(Value) Do
      If not (Value[i] in ['0'..'9']) Then
      Begin
        DateSeparator:= Value[i];
        Exit;
      End;
End;
Procedure TJvTranslateString.SetDateTimeFormat(Const Value: string);
Begin
  FDateTimeFormat := Value;
End;
Procedure TJvTranslateString.SetTimeFormat(Const Value: string);
Var i : Integer;
Begin
  FTimeFormat := Value;
  If TimeSeparator = chr(255) Then
    For i := 1 To Length(Value) Do
      If not (Value[i] in ['0'..'9']) Then
      Begin
        TimeSeparator:= Value[i];
        Exit;
      End;
End;
Function TJvTranslateString.TranslateString(InString: string): string;
Var
  I, J: Integer;
  Command: string;
  CommandResult: string;
Begin
  Result := '';
  While InString <> '' Do
  Begin
    I := Pos(LeftDelimiter, InString);
    If I = 0 Then
    Begin
      Result := Result + InString;
      InString := '';
    End
    Else
    Begin
      Result := Result + Copy(InString, 1, I-1);
      Delete(InString, 1, i);
      J := Pos(RightDelimiter, InString);
      If J > 0 Then
      Begin
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
      End
      Else
      Begin
        Result := Result + LeftDelimiter + InString;
        InString := '';
      End
    End;
  End;
End;
Function TJvTranslateString.TranslateString(InString: string; Var Changed: Boolean): string;
Var
  I, J: Integer;
  Command: string;
  CommandResult: string;
Begin
  Result := '';
  Changed := False;
  While InString <> '' Do
  Begin
    I := Pos(LeftDelimiter, InString);
    If I = 0 Then
    Begin
      Result := Result + InString;
      InString := '';
    End
    Else
    Begin
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
    End;
  End;
End;
{$IFDEF UNITVERSIONING}
Initialization
 RegisterUnitVersion(HInstance, UnitVersioning);
Finalization
 UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
End.
