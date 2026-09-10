Unit uRESTDWMemAnsiStrings;

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

{$IFDEF FPC}
 {$MODE Delphi}
 {$ASMMode Intel}
{$ENDIF}

Interface
Uses
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils,
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  Classes, SysUtils,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase, Math, uRESTDWPrototypes;
// Ansi types
Type
  {$IFDEF SUPPORTS_UNICODE}
  TJclAnsiStringList = Class;
  // Codegear should be the one providing this class, in the DWStrings unit.
  // It has been requested in QC 65630 but this was closed as "won't do".
  // So we are providing here a very light implementation that is designed
  // to provide the basics, and in no way be a "copy/paste" of what is in the RTL.
  TJclAnsiStrings = Class(TPersistent)
  Private
    FDelimiter: DWChar;
    FNameValueSeparator: DWChar;
    FStrictDelimiter: Boolean;
    FQuoteChar: DWChar;
    FUpdateCount: Integer;
    Function GetText: DWString;
    Procedure SetText(Const Value: DWString);
    Function ExtractName(Const S: DWString): DWString;
    Function GetName(Index: Integer): DWString;
    Function GetValue(Const Name: DWString): DWString;
    Procedure SetValue(Const Name, Value: DWString);
    Function GetValueFromIndex(Index: Integer): DWString;
    Procedure SetValueFromIndex(Index: Integer; Const Value: DWString);
  Protected
    Procedure AssignTo(Dest: TPersistent); override;
    Procedure Error(Const Msg: string; Data: Integer); overload;
    Procedure Error(Msg: PResStringRec; Data: Integer); overload;
    Function GetString(Index: Integer): DWString; virtual; abstract;
    Procedure SetString(Index: Integer; Const Value: DWString); virtual; abstract;
    Function GetObject(Index: Integer): TObject; virtual; abstract;
    Procedure SetObject(Index: Integer; AObject: TObject); virtual; abstract;
    Function GetCapacity: Integer; virtual;
    Procedure SetCapacity(Const Value: Integer); virtual;
    Function GetCount: Integer; virtual; abstract;
    Function CompareStrings(Const S1, S2: DWString): Integer; virtual;
    Procedure SetUpdateState(Updating: Boolean); virtual;
    property UpdateCount: Integer read FUpdateCount;
  Public
    Constructor Create;
    Procedure Assign(Source: TPersistent); override;
    Function Add(Const S: DWString): Integer; virtual;
    Function AddObject(Const S: DWString; AObject: TObject): Integer; virtual; abstract;
    Procedure AddStrings(Strings: TJclAnsiStrings); virtual;
    Procedure Insert(Index: Integer; Const S: DWString); virtual;
    Procedure InsertObject(Index: Integer; Const S: DWString; AObject: TObject); virtual; abstract;
    Procedure Delete(Index: Integer); virtual; abstract;
    Procedure Clear; virtual; abstract;
    Procedure LoadFromFile(Const FileName: TFileName); virtual;
    Procedure LoadFromStream(Stream: TStream); virtual;
    Procedure SaveToFile(Const FileName: TFileName); virtual;
    Procedure SaveToStream(Stream: TStream); virtual;
    Procedure BeginUpdate;
    Procedure EndUpdate;
    Function IndexOf(Const S: DWString): Integer; virtual;
    Function IndexOfName(Const Name: DWString): Integer; virtual;
    Function IndexOfObject(AObject: TObject): Integer; virtual;
    Procedure Exchange(Index1, Index2: Integer); virtual;
    property Delimiter: DWChar read FDelimiter write FDelimiter;
    property StrictDelimiter: Boolean read FStrictDelimiter write FStrictDelimiter;
    property QuoteChar: DWChar read FQuoteChar write FQuoteChar;
    property Strings[Index: Integer]: DWString read GetString write SetString; default;
    property Objects[Index: Integer]: TObject read GetObject write SetObject;
    property Text: DWString read GetText write SetText;
    property Count: Integer read GetCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Names[Index: Integer]: DWString read GetName;
    property Values[Const Name: DWString]: DWString read GetValue write SetValue;
    property ValueFromIndex[Index: Integer]: DWString read GetValueFromIndex write SetValueFromIndex;
    property NameValueSeparator: DWChar read FNameValueSeparator write FNameValueSeparator;
  End;
  TJclAnsiStringListSortCompare = Function(List: TJclAnsiStringList; Index1, Index2: Integer): Integer;
  TJclAnsiStringObjectHolder = Record
    Str: DWString;
    Obj: TObject;
  End;
  TJclAnsiStringList = Class(TJclAnsiStrings)
  Private
    FStrings: array Of TJclAnsiStringObjectHolder;
    FCount: Integer;
    FDuplicates: TDuplicates;
    FSorted: Boolean;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    Procedure Grow;
    Procedure QuickSort(L, R: Integer; SCompare: TJclAnsiStringListSortCompare);
  Protected
    Procedure AssignTo(Dest: TPersistent); override;
    Function GetString(Index: Integer): DWString; override;
    Function GetObject(Index: Integer): TObject; override;
    Procedure SetObject(Index: Integer; AObject: TObject); override;
    Function GetCapacity: Integer; override;
    Procedure SetCapacity(Const Value: Integer); override;
    Function GetCount: Integer; override;
    Function CompareStrings(Const S1, S2: DWString): Integer; override;
    Procedure SetUpdateState(Updating: Boolean); override;
    Procedure Changed; virtual;
    Procedure Changing; virtual;
  Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure Assign(Source: TPersistent); override;
    Procedure InsertObject(Index: Integer; Const S: DWString; AObject: TObject); override;
    Procedure Delete(Index: Integer); override;
    Function Find(Const S: DWString; Var Index: Integer): Boolean; virtual;
    Procedure Clear; override;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  End;
  {$ELSE ~SUPPORTS_UNICODE}
  TJclAnsiStrings = Classes.TStrings;
  TJclAnsiStringList = Classes.TStringList;
  {$ENDIF ~SUPPORTS_UNICODE}
  TAnsiStrings = TJclAnsiStrings;
  TAnsiStringList = TJclAnsiStringList;
// Exceptions
Type
  EJclAnsiStringError = Class(EJclError);
  EJclAnsiStringListError = Class(EJclAnsiStringError);
// Character constants and sets
Const
  // Misc. often used character definitions
  AnsiNull           = DWChar(#0);
  AnsiSoh            = DWChar(#1);
  AnsiStx            = DWChar(#2);
  AnsiEtx            = DWChar(#3);
  AnsiEot            = DWChar(#4);
  AnsiEnq            = DWChar(#5);
  AnsiAck            = DWChar(#6);
  AnsiBell           = DWChar(#7);
  AnsiBackspace      = DWChar(#8);
  AnsiTab            = DWChar(#9);
  AnsiLineFeed       = DWChar(#10);
  AnsiVerticalTab    = DWChar(#11);
  AnsiFormFeed       = DWChar(#12);
  AnsiCarriageReturn = DWChar(#13);
  AnsiCrLf           = DWString(#13#10);
  AnsiSo             = DWChar(#14);
  AnsiSi             = DWChar(#15);
  AnsiDle            = DWChar(#16);
  AnsiDc1            = DWChar(#17);
  AnsiDc2            = DWChar(#18);
  AnsiDc3            = DWChar(#19);
  AnsiDc4            = DWChar(#20);
  AnsiNak            = DWChar(#21);
  AnsiSyn            = DWChar(#22);
  AnsiEtb            = DWChar(#23);
  AnsiCan            = DWChar(#24);
  AnsiEm             = DWChar(#25);
  AnsiEndOfFile      = DWChar(#26);
  AnsiEscape         = DWChar(#27);
  AnsiFs             = DWChar(#28);
  AnsiGs             = DWChar(#29);
  AnsiRs             = DWChar(#30);
  AnsiUs             = DWChar(#31);
  AnsiSpace          = DWChar(' ');
  AnsiComma          = DWChar(',');
  AnsiBackslash      = DWChar('\');
  AnsiForwardSlash   = DWChar('/');
  AnsiDoubleQuote = DWChar('"');
  AnsiSingleQuote = DWChar('''');
  {$IFDEF MSWINDOWS}
  AnsiLineBreak = AnsiCrLf;
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  AnsiLineBreak = AnsiLineFeed;
  {$ENDIF UNIX}
  AnsiSignMinus = DWChar('-');
  AnsiSignPlus  = DWChar('+');
  // Misc. character sets
  AnsiWhiteSpace             = [AnsiTab, AnsiLineFeed, AnsiVerticalTab,
    AnsiFormFeed, AnsiCarriageReturn, AnsiSpace];
  AnsiSigns                  = [AnsiSignMinus, AnsiSignPlus];
  AnsiUppercaseLetters       = ['A'..'Z'];
  AnsiLowercaseLetters       = ['a'..'z'];
  AnsiLetters                = ['A'..'Z', 'a'..'z'];
  AnsiDecDigits              = ['0'..'9'];
  AnsiOctDigits              = ['0'..'7'];
  AnsiHexDigits              = ['0'..'9', 'A'..'F', 'a'..'f'];
  AnsiValidIdentifierLetters = ['0'..'9', 'A'..'Z', 'a'..'z', '_'];
Const
  // CharType return values
  C1_UPPER  = $0001; // Uppercase
  C1_LOWER  = $0002; // Lowercase
  C1_DIGIT  = $0004; // Decimal digits
  C1_SPACE  = $0008; // Space characters
  C1_PUNCT  = $0010; // Punctuation
  C1_CNTRL  = $0020; // Control characters
  C1_BLANK  = $0040; // Blank characters
  C1_XDIGIT = $0080; // Hexadecimal digits
  C1_ALPHA  = $0100; // Any linguistic character: alphabetic, syllabary, or ideographic
  {$IFDEF MSWINDOWS}
  {$IFDEF SUPPORTS_EXTSYM}
  {$EXTERNALSYM C1_UPPER}
  {$EXTERNALSYM C1_LOWER}
  {$EXTERNALSYM C1_DIGIT}
  {$EXTERNALSYM C1_SPACE}
  {$EXTERNALSYM C1_PUNCT}
  {$EXTERNALSYM C1_CNTRL}
  {$EXTERNALSYM C1_BLANK}
  {$EXTERNALSYM C1_XDIGIT}
  {$EXTERNALSYM C1_ALPHA}
  {$ENDIF SUPPORTS_EXTSYM}
  {$ENDIF MSWINDOWS}
// String Test Routines
Function StrContainsChars(Const S: DWString; Chars: TSysCharSet; CheckAll: Boolean): Boolean;
Function StrIsSubset(Const S: DWString; Const ValidChars: TSysCharSet): Boolean;
Function StrSame(Const S1, S2: DWString): Boolean;
// String Transformation Routines
Function StrCenter(Const S: DWString; L: SizeInt; C: DWChar = ' '): DWString;
Function StrCharPosLower(Const S: DWString; CharPos: SizeInt): DWString;
Function StrCharPosUpper(Const S: DWString; CharPos: SizeInt): DWString;
Function StrDoubleQuote(Const S: DWString): DWString;
Function StrEnsureNoPrefix(Const Prefix, Text: DWString): DWString;
Function StrEnsureNoSuffix(Const Suffix, Text: DWString): DWString;
Function StrEnsurePrefix(Const Prefix, Text: DWString): DWString;
Function StrEnsureSuffix(Const Suffix, Text: DWString): DWString;
Function StrEscapedToString(Const S: DWString): DWString;
Procedure StrMove(Var Dest: DWString; Const Source: DWString; Const ToIndex,
  FromIndex, Count: SizeInt);
Function StrPadLeft(Const S: DWString; Len: SizeInt; C: DWChar = AnsiSpace): DWString;
Function StrPadRight(Const S: DWString; Len: SizeInt; C: DWChar = AnsiSpace): DWString;
Function StrProper(Const S: DWString): DWString;
Function StrQuote(Const S: DWString; C: DWChar): DWString;
Function StrReplaceChar(Const S: DWString; Const Source, Replace: DWChar): DWString;
Function StrReplaceChars(Const S: DWString; Const Chars: TSysCharSet; Replace: DWChar): DWString;
Function StrReplaceButChars(Const S: DWString; Const Chars: TSysCharSet; Replace: DWChar): DWString;
Function StrSingleQuote(Const S: DWString): DWString;
Procedure StrSkipChars(Const S: DWString; Var Index: SizeInt; Const Chars: TSysCharSet); overload;
Function StrStringToEscaped(Const S: DWString): DWString;
Function StrToHex(Const Source: DWString): DWString;
Function StrTrimCharLeft(Const S: DWString; C: DWChar): DWString;
Function StrTrimCharsLeft(Const S: DWString; Const Chars: TSysCharSet): DWString;
Function StrTrimCharRight(Const S: DWString; C: DWChar): DWString;
Function StrTrimCharsRight(Const S: DWString; Const Chars: TSysCharSet): DWString;
Function StrTrimQuotes(Const S: DWString): DWString; overload;
Function StrTrimQuotes(Const S: DWString; QuoteChar: DWChar): DWString; overload;
// String Management
Procedure StrDecRef(Var S: DWString);
Function StrLength(Const S: DWString): Longint;
Function StrRefCount(Const S: DWString): Longint;
Procedure StrResetLength(Var S: DWString);
// String Search and Replace Routines
Function StrCharCount(Const S: DWString; C: DWChar): SizeInt;
Function StrCharsCount(Const S: DWString; Chars: TSysCharSet): SizeInt;
Function StrStrCount(Const S, SubS: DWString): SizeInt;
Function StrCompare(Const S1, S2: DWString; CaseSensitive: Boolean = False): SizeInt;
Function StrCompareRangeEx(Const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean = False): SizeInt;
Function StrCompareRange(Const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean = True): SizeInt;
Function StrRepeatChar(C: DWChar; Count: SizeInt): DWString;
Function StrFind(Const Substr, S: DWString; Const Index: SizeInt = 1): SizeInt;
Function StrHasPrefix(Const S: DWString; Const Prefixes: array Of DWString): Boolean;
Function StrHasSuffix(Const S: DWString; Const Suffixes: array Of DWString): Boolean;
Function StrIHasPrefix(Const S: DWString; Const Prefixes: array Of DWString): Boolean;
Function StrIHasSuffix(Const S: DWString; Const Suffixes: array Of DWString): Boolean;
Function StrIndex(Const S: DWString; Const List: array Of DWString; CaseSensitive: Boolean = False): SizeInt;
Function StrILastPos(Const SubStr, S: DWString): SizeInt;
Function StrIPos(Const SubStr, S: DWString): SizeInt;
Function StrIPrefixIndex(Const S: DWString; Const Prefixes: array Of DWString): SizeInt;
Function StrIsOneOf(Const S: DWString; Const List: array Of DWString): Boolean;
Function StrISuffixIndex(Const S: DWString; Const Suffixes: array Of DWString): SizeInt;
Function StrMatch(Const Substr, S: DWString; Index: SizeInt = 1): SizeInt;
Function StrNIPos(Const S, SubStr: DWString; N: SizeInt): SizeInt;
Function StrNPos(Const S, SubStr: DWString; N: SizeInt): SizeInt;
Function StrPrefixIndex(Const S: DWString; Const Prefixes: array Of DWString): SizeInt;
Function StrSuffixIndex(Const S: DWString; Const Suffixes: array Of DWString): SizeInt;
// String Extraction
// String Extraction
// Returns the String before SubStr
Function StrAfter(Const SubStr, S: DWString): DWString;
/// Returns the DWString after SubStr
Function StrBefore(Const SubStr, S: DWString): DWString;
/// Splits a DWString at SubStr, returns true when SubStr is found, Left contains the
/// DWString before the SubStr and Rigth the DWString behind SubStr
Function StrSplit(Const SubStr, S: DWString;Var Left, Right : DWString): boolean;
/// Returns the DWString between Start and Stop
Function StrBetween(Const S: DWString; Const Start, Stop: DWChar): DWString;
/// Returns the left N characters of the DWString
Function StrChopRight(Const S: DWString; N: SizeInt): DWString;
/// Returns the left Count characters of the DWString
Function StrLeft(Const S: DWString; Count: SizeInt): DWString;
/// Returns the DWString starting from position Start for the Count Characters
Function StrMid(Const S: DWString; Start, Count: SizeInt): DWString;
/// Returns the DWString starting from position N to the end
Function StrRestOf(Const S: DWString; N: SizeInt): DWString;
/// Returns the right Count characters of the DWString
Function StrRight(Const S: DWString; Count: SizeInt): DWString;
// Character Test Routines
Function CharIsDelete(Const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsReturn(Const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsValidIdentifierLetter(Const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsWildcard(Const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharType(Const C: DWChar): Word;
// Character Transformation Routines
Function CharHex(Const C: DWChar): Byte;
Function CharLower(Const C: DWChar): DWChar;
Function CharUpper(Const C: DWChar): DWChar;
Function CharToggleCase(Const C: DWChar): DWChar;
// Character Search and Replace
Function CharPos(Const S: DWString; Const C: DWChar; Const Index: SizeInt = 1): SizeInt;
Function CharLastPos(Const S: DWString; Const C: DWChar; Const Index: SizeInt = 1): SizeInt;
Function CharIPos(Const S: DWString; C: DWChar; Const Index: SizeInt = 1): SizeInt;
// PCharVector
Type
  PAnsiCharVector = ^PAnsiChar;
// MultiSz Routines
Type
  PAnsiMultiSz = PAnsiChar;
Procedure AllocateMultiSz(Var Dest: PAnsiMultiSz; Len: SizeInt);
Procedure FreeMultiSz(Var Dest: PAnsiMultiSz);
Procedure StrIToStrings(S, Sep: DWString; Const List: TJclAnsiStrings; Const AllowEmptyString: Boolean = True);
Procedure StrToStrings(S, Sep: DWString; Const List: TJclAnsiStrings; Const AllowEmptyString: Boolean = True);
Function StringsToStr(Const List: TJclAnsiStrings; Const Sep: DWString; Const AllowEmptyString: Boolean = True): DWString;
Procedure TrimStrings(Const List: TJclAnsiStrings; DeleteIfEmpty: Boolean = True);
Procedure TrimStringsRight(Const List: TJclAnsiStrings; DeleteIfEmpty: Boolean = True);
Procedure TrimStringsLeft(Const List: TJclAnsiStrings; DeleteIfEmpty: Boolean = True);
Function AddStringToStrings(Const S: DWString; Strings: TJclAnsiStrings; Const Unique: Boolean): Boolean;
// Miscellaneous
// (OF) moved to JclSysUtils
//function BooleanToStr(B: Boolean): DWString;
Function FileToString(Const FileName: TFileName): DWString;
Procedure StringToFile(Const FileName: TFileName; Const Contents: DWString; Append: Boolean = False);
Function StrToken(Var S: DWString; Separator: DWChar): DWString;
//procedure StrTokenToStrings(S: DWString; Separator: DWChar; const List: TJclAnsiStrings);Overload;
//procedure StrTokenToStrings(S: string; Separator: Char; const List: TStrings);Overload;
Procedure StrNormIndex(Const StrLen: SizeInt; Var Index: SizeInt; Var Count: SizeInt); overload;
Function ArrayOf(List: TJclAnsiStrings): TDynStringArray; overload;
// internal structures published to make function inlining working
Const
  DWCharCount   = Ord(High(Char)) + 1; // # of chars in one set
  AnsiLoOffset    = DWCharCount * 0;       // offset to lower case chars
  AnsiUpOffset    = DWCharCount * 1;       // offset to upper case chars
  AnsiReOffset    = DWCharCount * 2;       // offset to reverse case chars
  AnsiCaseMapSize = DWCharCount * 3;       // # of chars is a table
Var
  AnsiCaseMap: array [0..AnsiCaseMapSize - 1] Of DWChar; // case mappings
  AnsiCaseMapReady: Boolean = False;         // true if case map exists
  DWCharTypes: array [Char] Of Word;
Implementation
Uses
  {$IFDEF HAS_UNIT_LIBC}
  Libc,
  {$ENDIF HAS_UNIT_LIBC}
  {$IFDEF SUPPORTS_UNICODE}
  {$IFDEF HAS_UNIT_RTLCONSTS}
  {$IFDEF HAS_UNITSCOPE}
  System.RTLConsts,
  {$ELSE ~HAS_UNITSCOPE}
  RtlConsts,
  {$ENDIF}
  {$ENDIF HAS_UNIT_RTLCONSTS}
  {$ENDIF SUPPORTS_UNICODE}
  uRESTDWMemResources, uRESTDWMemStreams,
  uRESTDWMemStringsB;
//=== Internal ===============================================================
Type
  TAnsiStrRec = packed Record
    RefCount: Integer;
    Length: Integer;
  End;
  PAnsiStrRec = ^TAnsiStrRec;
Const
  AnsiStrRecSize  = SizeOf(TAnsiStrRec);     // size of the DWString header rec
Procedure LoadCharTypes;
Var
  CurrChar: DWChar;
  CurrType: Word;
Begin
  For CurrChar := Low(DWChar) To High(DWChar) Do
  Begin
    {$IFDEF MSWINDOWS}
    CurrType := 0;
    GetStringTypeExA(LOCALE_USER_DEFAULT, CT_CTYPE1, @CurrChar, SizeOf(DWChar), CurrType);
    {$DEFINE CHAR_TYPES_INITIALIZED}
    {$ENDIF MSWINDOWS}
    {$IFDEF LINUX}
    CurrType := 0;
    If isupper(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_UPPER;
    If islower(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_LOWER;
    If isdigit(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_DIGIT;
    If isspace(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_SPACE;
    If ispunct(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_PUNCT;
    If iscntrl(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_CNTRL;
    If isblank(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_BLANK;
    If isxdigit(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_XDIGIT;
    If isalpha(Byte(CurrChar)) <> 0 Then
      CurrType := CurrType or C1_ALPHA;
    {$DEFINE CHAR_TYPES_INITIALIZED}
    {$ENDIF LINUX}
    DWCharTypes[CurrChar] := CurrType;
  End;
End;
{$IFDEF SUPPORTS_UNICODE}
//=== { TJclAnsiStrings } ====================================================
Constructor TJclAnsiStrings.Create;
Begin
  Inherited Create;
  FDelimiter := ',';
  FNameValueSeparator := '=';
  FQuoteChar := '"';
  FStrictDelimiter := False;
End;
Procedure TJclAnsiStrings.Assign(Source: TPersistent);
Var
  StringsSource: TStrings;
  I: Integer;
Begin
  If Source is TStrings Then
  Begin
    StringsSource := TStrings(Source);
    BeginUpdate;
    Try
      Clear;
      FDelimiter := DWChar(StringsSource.Delimiter);
      FNameValueSeparator := DWChar(StringsSource.NameValueSeparator);
      For I := 0 To StringsSource.Count - 1 Do
        AddObject(DWString(StringsSource.Strings[I]), StringsSource.Objects[I]);
    Finally
      EndUpdate;
    End;
  End
  Else
    Inherited Assign(Source);
End;
Procedure TJclAnsiStrings.AssignTo(Dest: TPersistent);
Var
  StringsDest: TStrings;
  DWStringsDest: TJclAnsiStrings;
  I: Integer;
Begin
  If Dest is TStrings Then
  Begin
    StringsDest := TStrings(Dest);
    StringsDest.BeginUpdate;
    Try
      StringsDest.Clear;
      StringsDest.Delimiter := Char(Delimiter);
      StringsDest.NameValueSeparator := Char(NameValueSeparator);
      For I := 0 To Count - 1 Do
        StringsDest.AddObject(string(Strings[I]), Objects[I]);
    Finally
      StringsDest.EndUpdate;
    End;
  End
  Else
  If Dest is TJclAnsiStrings Then
  Begin
    DWStringsDest := TJclAnsiStrings(Dest);
    BeginUpdate;
    Try
      DWStringsDest.Clear;
      DWStringsDest.FNameValueSeparator := FNameValueSeparator;
      DWStringsDest.FDelimiter := FDelimiter;
      For I := 0 To Count - 1 Do
        DWStringsDest.AddObject(Strings[I], Objects[I]);
    Finally
      EndUpdate;
    End;
  End
  Else
    Inherited AssignTo(Dest);
End;
Function TJclAnsiStrings.Add(Const S: DWString): Integer;
Begin
  Result := AddObject(S, nil);
End;
Procedure TJclAnsiStrings.AddStrings(Strings: TJclAnsiStrings);
Var
  I: Integer;
Begin
  For I := 0 To Strings.Count - 1 Do
    Add(Strings.Strings[I]);
End;
Procedure TJclAnsiStrings.Error(Const Msg: string; Data: Integer);
Begin
  raise EJclAnsiStringListError.CreateFmt(Msg, [Data]);
End;
Procedure TJclAnsiStrings.Error(Msg: PResStringRec; Data: Integer);
Begin
  Error(LoadResString(Msg), Data);
End;
Function TJclAnsiStrings.CompareStrings(Const S1, S2: DWString): Integer;
Begin
  Result := CompareStr(S1, S2);
End;
Procedure TJclAnsiStrings.SetUpdateState(Updating: Boolean);
Begin
End;
Function TJclAnsiStrings.IndexOf(Const S: DWString): Integer;
Begin
  For Result := 0 To Count - 1 Do
    If CompareStrings(Strings[Result], S) = 0 Then
      Exit;
  Result := -1;
End;
Function TJclAnsiStrings.IndexOfName(Const Name: DWString): Integer;
Var
  P: Integer;
  S: DWString;
Begin
  For Result := 0 To Count - 1 Do
  Begin
    S := Strings[Result];
    P := AnsiPos(NameValueSeparator, S);
    If (P > 0) and (CompareStrings(Copy(S, 1, P - 1), Name) = 0) Then
      Exit;
  End;
  Result := -1;
End;
Function TJclAnsiStrings.IndexOfObject(AObject: TObject): Integer;
Begin
  For Result := 0 To Count - 1 Do
    If Objects[Result] = AObject Then
      Exit;
  Result := -1;
End;
Procedure TJclAnsiStrings.Exchange(Index1, Index2: Integer);
Var
  TempString: DWString;
  TempObject: TObject;
Begin
  BeginUpdate;
  Try
    TempString := Strings[Index1];
    TempObject := Objects[Index1];
    Strings[Index1] := Strings[Index2];
    Objects[Index1] := Objects[Index2];
    Strings[Index2] := TempString;
    Objects[Index2] := TempObject;
  Finally
    EndUpdate;
  End;
End;
Procedure TJclAnsiStrings.Insert(Index: Integer; Const S: DWString);
Begin
  InsertObject(Index, S, nil);
End;
Function TJclAnsiStrings.GetText: DWString;
Var
  I: Integer;
Begin
  Result := '';
  For I := 0 To Count - 2 Do
    Result := Result + Strings[I] + sLineBreak;
  If Count > 0 Then
    Result := Result + Strings[Count - 1] + sLineBreak;
End;
Procedure TJclAnsiStrings.SetText(Const Value: DWString);
Var
  Index, Start, Len: Integer;
  S: DWString;
Begin
  Clear;
  Len := Length(Value);
  Index := 1;
  While Index <= Len Do
  Begin
    Start := Index;
    While (Index <= Len) and not CharIsReturn(Value[Index]) Do
      Inc(Index);
    S := Copy(Value, Start, Index - Start);
    Add(S);
    If (Index <= Len) and (Value[Index] = AnsiCarriageReturn) Then
      Inc(Index);
    If (Index <= Len) and (Value[Index] = AnsiLineFeed) Then
      Inc(Index);
  End;
End;
Function TJclAnsiStrings.GetCapacity: Integer;
Begin
  Result := Count; // Might be overridden in derived classes
End;
Procedure TJclAnsiStrings.SetCapacity(Const Value: Integer);
Begin
  // Nothing at this level
End;
Procedure TJclAnsiStrings.BeginUpdate;
Begin
  If FUpdateCount = 0 Then SetUpdateState(True);
  Inc(FUpdateCount);
End;
Procedure TJclAnsiStrings.EndUpdate;
Begin
  Dec(FUpdateCount);
  If FUpdateCount = 0 Then SetUpdateState(False);
End;
Procedure TJclAnsiStrings.LoadFromFile(Const FileName: TFileName);
Var
  Stream: TStream;
Begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Try
    LoadFromStream(Stream);
  Finally
    Stream.Free;
  End;
End;
Procedure TJclAnsiStrings.LoadFromStream(Stream: TStream);
Var
  Size: Integer;
  S: DWString;
Begin
  BeginUpdate;
  Try
    Size := Stream.Size - Stream.Position;
    System.SetString(S, nil, Size);
    Stream.Read(PAnsiChar(S)^, Size);
    SetText(S);
  Finally
    EndUpdate;
  End;
End;
Procedure TJclAnsiStrings.SaveToFile(Const FileName: TFileName);
Var
  Stream: TStream;
Begin
  Stream := TFileStream.Create(FileName, fmCreate);
  Try
    SaveToStream(Stream);
  Finally
    Stream.Free;
  End;
End;
Procedure TJclAnsiStrings.SaveToStream(Stream: TStream);
Var
  S: DWString;
Begin
  S := GetText;
  Stream.WriteBuffer(PAnsiChar(S)^, Length(S));
End;
Function TJclAnsiStrings.ExtractName(Const S: DWString): DWString;
Var
  P: Integer;
Begin
  Result := S;
  P := AnsiPos(NameValueSeparator, Result);
  If P > 0 Then
    SetLength(Result, P - 1)
  Else
    SetLength(Result, 0);
End;
Function TJclAnsiStrings.GetName(Index: Integer): DWString;
Begin
  Result := ExtractName(Strings[Index]);
End;
Function TJclAnsiStrings.GetValue(Const Name: DWString): DWString;
Var
  I: Integer;
Begin
  I := IndexOfName(Name);
  If I >= 0 Then
    Result := Copy(GetString(I), Length(Name) + 2, MaxInt)
  Else
    Result := '';
End;
Procedure TJclAnsiStrings.SetValue(Const Name, Value: DWString);
Var
  I: Integer;
Begin
  I := IndexOfName(Name);
  If Value <> '' Then
  Begin
    If I < 0 Then
      I := Add('');
    SetString(I, Name + NameValueSeparator + Value);
  End
  Else
  Begin
    If I >= 0 Then
      Delete(I);
  End;
End;
Function TJclAnsiStrings.GetValueFromIndex(Index: Integer): DWString;
Var
  S: DWString;
  P: Integer;
Begin
  If Index >= 0 Then
  Begin
    S := Strings[Index];
    P := AnsiPos(NameValueSeparator, S);
    If P > 0 Then
      Result := Copy(S, P + 1, Length(S) - P)
    Else
      Result := '';
  End
  Else
    Result := '';
End;
Procedure TJclAnsiStrings.SetValueFromIndex(Index: Integer; Const Value: DWString);
Begin
  If Value <> '' Then
  Begin
    If Index < 0 Then
      Index := Add('');
    SetString(Index, Names[Index] + NameValueSeparator + Value);
  End
  Else
  Begin
    If Index >= 0 Then
      Delete(Index);
  End;
End;
//=== { TJclAnsiStringList } =================================================
Constructor TJclAnsiStringList.Create;
Begin
  Inherited Create;
  FCaseSensitive := True;
End;
Destructor TJclAnsiStringList.Destroy;
Begin
  FOnChange := nil;
  FOnChanging := nil;
  Inherited Destroy;
End;
Procedure TJclAnsiStringList.Assign(Source: TPersistent);
Var
  StringListSource: TStringList;
Begin
  If Source is TStringList Then
  Begin
    StringListSource := TStringList(Source);
    FDuplicates := StringListSource.Duplicates;
    FSorted := StringListSource.Sorted;
    FCaseSensitive := StringListSource.CaseSensitive;
  End;
  Inherited Assign(Source);
End;
Procedure TJclAnsiStringList.AssignTo(Dest: TPersistent);
Var
  StringListDest: TStringList;
  DWStringListDest: TJclAnsiStringList;
Begin
  If Dest is TStringList Then
  Begin
    StringListDest := TStringList(Dest);
    StringListDest.Clear; // make following assignments a lot faster
    StringListDest.Duplicates := FDuplicates;
    StringListDest.Sorted := FSorted;
    StringListDest.CaseSensitive := FCaseSensitive;
  End
  Else
  If Dest is TJclAnsiStringList Then
  Begin
    DWStringListDest := TJclAnsiStringList(Dest);
    DWStringListDest.Clear;
    DWStringListDest.FDuplicates := FDuplicates;
    DWStringListDest.FSorted := FSorted;
    DWStringListDest.FCaseSensitive := FCaseSensitive;
  End;
  Inherited AssignTo(Dest);
End;
Function TJclAnsiStringList.CompareStrings(Const S1: DWString; Const S2: DWString): Integer;
Begin
  If FCaseSensitive Then
    Result := CompareStr(S1, S2)
  Else
    Result := CompareText(S1, S2);
End;
Procedure TJclAnsiStringList.SetUpdateState(Updating: Boolean);
Begin
  If Updating Then Changing Else Changed;
End;
Procedure TJclAnsiStringList.Changed;
Begin
  If (FUpdateCount = 0) and Assigned(FOnChange) Then
    FOnChange(Self);
End;
Procedure TJclAnsiStringList.Changing;
Begin
  If (FUpdateCount = 0) and Assigned(FOnChanging) Then
    FOnChanging(Self);
End;
Procedure TJclAnsiStringList.Grow;
Var
  Delta: Integer;
Begin
  If Capacity > 64 Then
    Delta := Capacity div 4
  Else If Capacity > 8 Then
    Delta := 16
  Else
    Delta := 4;
  SetCapacity(Capacity + Delta);
End;
Function TJclAnsiStringList.GetString(Index: Integer): DWString;
Begin
  If (Index < 0) or (Index >= FCount) Then
    Error(@SListIndexError, Index);
  Result := FStrings[Index].Str;
End;
Function TJclAnsiStringList.GetObject(Index: Integer): TObject;
Begin
  If (Index < 0) or (Index >= FCount) Then
    Error(@SListIndexError, Index);
  Result := FStrings[Index].Obj;
End;
Procedure TJclAnsiStringList.SetObject(Index: Integer; AObject: TObject);
Begin
  If (Index < 0) or (Index >= FCount) Then
    Error(@SListIndexError, Index);
  FStrings[Index].Obj := AObject;
End;
Function TJclAnsiStringList.GetCapacity: Integer;
Begin
  Result := Length(FStrings);
End;
Procedure TJclAnsiStringList.SetCapacity(Const Value: Integer);
Begin
  If (Value < FCount) Then
    Error(@SListCapacityError, Value);
  If Value <> Capacity Then
    SetLength(FStrings, Value);
End;
Function TJclAnsiStringList.GetCount: Integer;
Begin
  Result := FCount;
End;
Procedure TJclAnsiStringList.InsertObject(Index: Integer; Const S: DWString; AObject: TObject);
Var
  I: Integer;
Begin
  If Count = Capacity Then
    Grow;
  For I := Count - 1 Downto Index Do
    FStrings[I + 1] := FStrings[I];
  FStrings[Index].Str := S;
  FStrings[Index].Obj := AObject;
  Inc(FCount);
End;
Procedure TJclAnsiStringList.Delete(Index: Integer);
Var
  I: Integer;
Begin
  If (Index < 0) or (Index >= FCount) Then
    Error(@SListIndexError, Index);
  For I := Index To Count - 2 Do
    FStrings[I] := FStrings[I + 1];
    
  FStrings[FCount - 1].Str := '';  // the last string is no longer useful
    
  Dec(FCount);
End;
Procedure TJclAnsiStringList.Clear;
Var
  I: Integer;
Begin
  FCount := 0;
  For I := 0 To Length(FStrings) - 1 Do
  Begin
    FStrings[I].Str := '';
    FStrings[I].Obj := nil;
  End;
End;
Function TJclAnsiStringList.Find(Const S: DWString; Var Index: Integer): Boolean;
Var
  L, H, I, C: Integer;
Begin
  Result := False;
  L := 0;
  H := FCount - 1;
  While L <= H Do
  Begin
    I := (L + H) shr 1;
    C := CompareStrings(FStrings[I].Str, S);
    If C < 0 Then
      L := I + 1
    Else
    Begin
      H := I - 1;
      If C = 0 Then
      Begin
        Result := True;
        If Duplicates <> dupAccept Then
          L := I;
      End;
    End;
  End;
  Index := L;
End;
Function DWStringListCompareStrings(List: TJclAnsiStringList; Index1, Index2: Integer): Integer;
Begin
  Result := List.CompareStrings(List.FStrings[Index1].Str,
                                List.FStrings[Index2].Str);
End;
Procedure TJclAnsiStringList.QuickSort(L, R: Integer; SCompare: TJclAnsiStringListSortCompare);
Var
  I, J, P: Integer;
Begin
  Repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    Repeat
      While SCompare(Self, I, P) < 0 Do
        Inc(I);
      While SCompare(Self, J, P) > 0 Do
        Dec(J);
      If I <= J Then
      Begin
        If I <> J Then
          Exchange(I, J);
        If P = I Then
          P := J
        Else
        If P = J Then
          P := I;
        Inc(I);
        Dec(J);
      End;
    Until I > J;
    If L < J Then
      QuickSort(L, J, SCompare);
    L := I;
  Until I >= R;
End;
{$ENDIF SUPPORTS_UNICODE}
Function StrContainsChars(Const S: DWString; Chars: TSysCharSet; CheckAll: Boolean): Boolean;
Var
  I: SizeInt;
  C: DWChar;
Begin
  Result := Chars = [];
  If not Result Then
  Begin
    If CheckAll Then
    Begin
      For I := 1 To Length(S) Do
      Begin
        PDWString(@C)^ := Char(S[I]);
        If C in Chars Then
        Begin
          Chars := Chars - [C];
          If Chars = [] Then
            Break;
        End;
      End;
      Result := (Chars = []);
    End
    Else
    Begin
      For I := 1 To Length(S) Do
        If S[I] in Chars Then
        Begin
          Result := True;
          Break;
        End;
    End;
  End;
End;
Function StrIsSubset(Const S: DWString; Const ValidChars: TSysCharSet): Boolean;
Var
  I: SizeInt;
Begin
  For I := 1 To Length(S) Do
  Begin
    If not (S[I] in ValidChars) Then
    Begin
      Result := False;
      Exit;
    End;
  End;
  Result := True and (Length(S) > 0);
End;
Function StrSame(Const S1, S2: DWString): Boolean;
Begin
  Result := StrCompare(S1, S2) = 0;
End;
//=== String Transformation Routines =========================================
Function StrCenter(Const S: DWString; L: SizeInt; C: DWChar = ' '): DWString;
Begin
  If Length(S) < L Then
  Begin
    Result := StringOfChar(C, (L - Length(S)) div 2) + S;
    Result := Result + StringOfChar(C, L - Length(Result));
  End
  Else
    Result := S;
End;
Function StrCharPosLower(Const S: DWString; CharPos: SizeInt): DWString;
Begin
  Result := S;
  If (CharPos > 0) and (CharPos <= Length(S)) Then
    PDWString(@Result[CharPos])^ := CharLower(Result[CharPos]);
End;
Function StrCharPosUpper(Const S: DWString; CharPos: SizeInt): DWString;
Begin
  Result := S;
  If (CharPos > 0) and (CharPos <= Length(S)) Then
    PDWString(@Result[CharPos])^ := CharUpper(Result[CharPos]);
End;
Function StrDoubleQuote(Const S: DWString): DWString;
Begin
  Result := AnsiDoubleQuote + S + AnsiDoubleQuote;
End;
Function StrEnsureNoPrefix(Const Prefix, Text: DWString): DWString;
Var
  PrefixLen: SizeInt;
Begin
  PrefixLen := Length(Prefix);
  If Copy(Text, 1, PrefixLen) = Prefix Then
    Result := Copy(Text, PrefixLen + 1, Length(Text))
  Else
    Result := Text;
End;
Function StrEnsureNoSuffix(Const Suffix, Text: DWString): DWString;
Var
  SuffixLen: SizeInt;
  StrLength: SizeInt;
Begin
  SuffixLen := Length(Suffix);
  StrLength := Length(Text);
  If Copy(Text, StrLength - SuffixLen + 1, SuffixLen) = Suffix Then
    Result := Copy(Text, 1, StrLength - SuffixLen)
  Else
    Result := Text;
End;
Function StrEnsurePrefix(Const Prefix, Text: DWString): DWString;
Var
  PrefixLen: SizeInt;
Begin
  PrefixLen := Length(Prefix);
  If Copy(Text, 1, PrefixLen) = Prefix Then
    Result := Text
  Else
    Result := Prefix + Text;
End;
Function StrEnsureSuffix(Const Suffix, Text: DWString): DWString;
Var
  SuffixLen: SizeInt;
Begin
  SuffixLen := Length(Suffix);
  If Copy(Text, Length(Text) - SuffixLen + 1, SuffixLen) = Suffix Then
    Result := Text
  Else
    Result := Text + Suffix;
End;
Function StrEscapedToString(Const S: DWString): DWString;
  Procedure HandleHexEscapeSeq(Const S: DWString; Var I: SizeInt; Len: SizeInt; Var Dest: DWString);
  Const
    HexDigits = DWString('0123456789abcdefABCDEF');
  Var
    StartI, Val, N: SizeInt;
  Begin
    StartI := I;
    N := Pos(S[I + 1], HexDigits) - 1;
    If N < 0 Then
      // '\x' without hex digit following is not escape sequence
      Dest := Dest + '\x'
    Else
    Begin
      Inc(I); // Jump over x
      If N >= 16 Then
        N := N - 6;
      Val := N;
      // Same for second digit
      If I < Len Then
      Begin
        N := Pos(S[I + 1], HexDigits) - 1;
        If N >= 0 Then
        Begin
          Inc(I); // Jump over first digit
          If N >= 16 Then
            N := N - 6;
          Val := Val * 16 + N;
        End;
      End;
      If Val > Ord(High(DWChar)) Then
        raise EJclAnsiStringError.CreateResFmt(@RsNumericConstantTooLarge, [Val, StartI]);
      Dest := Dest + DWChar(Val);
    End;
  End;
  Procedure HandleOctEscapeSeq(Const S: DWString; Var I: SizeInt; Len: SizeInt; Var Dest: DWString);
  Const
    OctDigits = DWString('01234567');
  Var
    StartI, Val, N: SizeInt;
  Begin
    StartI := I;
    // first digit
    Val := Pos(S[I], OctDigits) - 1;
    If I < Len Then
    Begin
      N := Pos(S[I + 1], OctDigits) - 1;
      If N >= 0 Then
      Begin
        Inc(I);
        Val := Val * 8 + N;
      End;
      If I < Len Then
      Begin
        N := Pos(S[I + 1], OctDigits) - 1;
        If N >= 0 Then
        Begin
          Inc(I);
          Val := Val * 8 + N;
        End;
      End;
    End;
    If Val > Ord(High(DWChar)) Then
      raise EJclAnsiStringError.CreateResFmt(@RsNumericConstantTooLarge, [Val, StartI]);
    Dest := Dest + DWChar(Val);
  End;
Var
  I, Len: SizeInt;
Begin
  Result := '';
  I := 1;
  Len := Length(S);
  While I <= Len Do
  Begin
    If not ((S[I] = '\') and (I < Len)) Then
      Result := Result + S[I]
    Else
    Begin
      Inc(I); // Jump over escape character
      Case S[I] Of
        'a':
          Result := Result + AnsiBell;
        'b':
          Result := Result + AnsiBackspace;
        'f':
          Result := Result + AnsiFormFeed;
        'n':
          Result := Result + AnsiLineFeed;
        'r':
          Result := Result + AnsiCarriageReturn;
        't':
          Result := Result + AnsiTab;
        'v':
          Result := Result + AnsiVerticalTab;
        '\':
          Result := Result + '\';
        '"':
          Result := Result + '"';
        '''':
          Result := Result + ''''; // Optionally escaped
        '?':
          Result := Result + '?';  // Optionally escaped
        'x':
          If I < Len Then
            // Start of hex escape sequence
            HandleHexEscapeSeq(S, I, Len, Result)
          Else
            // '\x' at end of DWString is not escape sequence
            Result := Result + '\x';
        '0'..'7':
          // start of octal escape sequence
          HandleOctEscapeSeq(S, I, Len, Result);
      Else
        // no escape sequence
        Result := Result + '\' + S[I];
      End;
    End;
    Inc(I);
  End;
End;
Procedure StrMove(Var Dest: DWString; Const Source: DWString;
  Const ToIndex, FromIndex, Count: SizeInt);
Begin
  // Check strings
  If (Source = '') or (Length(Dest) = 0) Then
    Exit;
  // Check FromIndex
  If (FromIndex <= 0) or (FromIndex > Length(Source)) or
    (ToIndex <= 0) or (ToIndex > Length(Dest)) or
    ((FromIndex + Count - 1) > Length(Source)) or ((ToIndex + Count - 1) > Length(Dest)) Then
    { TODO : Is failure without notice the proper thing to do here? }
    Exit;
  // Move
  Move(Source[FromIndex], Dest[ToIndex], Count);
End;
Function StrPadLeft(Const S: DWString; Len: SizeInt; C: DWChar): DWString;
Var
  L: SizeInt;
Begin
  L := Length(S);
  If L < Len Then
    Result := StringOfChar(C, Len - L) + S
  Else
    Result := S;
End;
Function StrPadRight(Const S: DWString; Len: SizeInt; C: DWChar): DWString;
Var
  L: SizeInt;
Begin
  L := Length(S);
  If L < Len Then
    Result := S + StringOfChar(C, Len - L)
  Else
    Result := S;
End;
Function StrProper(Const S: DWString): DWString;
Begin
  Result := StrLower(S);
  If Result <> '' Then
    Result[1] := UpCase(Result[1]);
End;
Function StrQuote(Const S: DWString; C: DWChar): DWString;
Var
  L: SizeInt;
Begin
  L := Length(S);
  Result := S;
  If L > 0 Then
  Begin
    If PDWString(@Result[1])^ <> C Then
    Begin
      Result := C + Result;
      Inc(L);
    End;
    If PDWString(@Result[L])^ <> C Then
      Result := Result + C;
  End;
End;
Function StrReplaceChar(Const S: DWString; Const Source, Replace: DWChar): DWString;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If PDWString(@Result[I])^ = Source Then
      PDWString(@Result[I])^ := Replace;
End;
Function StrReplaceChars(Const S: DWString; Const Chars: TSysCharSet; Replace: DWChar): DWString;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If Result[I] in Chars Then
      PDWString(@Result[I])^ := Replace;
End;
Function StrReplaceButChars(Const S: DWString; Const Chars: TSysCharSet;
  Replace: DWChar): DWString;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If not (Result[I] in Chars) Then
      PDWString(@Result[I])^ := Replace;
End;
Function StrSingleQuote(Const S: DWString): DWString;
Begin
  Result := AnsiSingleQuote + S + AnsiSingleQuote;
End;
Procedure StrSkipChars(Const S: DWString; Var Index: SizeInt; Const Chars: TSysCharSet);
Begin
  While S[Index] in Chars Do
    Inc(Index);
End;
Function StrStringToEscaped(Const S: DWString): DWString;
Var
  I: SizeInt;
Begin
  Result := '';
  For I := 1 To Length(S) Do
  Begin
    Case S[I] Of
      AnsiBackspace:
        Result := Result + '\b';
      AnsiBell:
        Result := Result + '\a';
      AnsiCarriageReturn:
        Result := Result + '\r';
      AnsiFormFeed:
        Result := Result + '\f';
      AnsiLineFeed:
        Result := Result + '\n';
      AnsiTab:
        Result := Result + '\t';
      AnsiVerticalTab:
        Result := Result + '\v';
      '\':
        Result := Result + '\\';
      '"':
        Result := Result + '\"';
    Else
      // Characters < ' ' are escaped with hex sequence
      If S[I] < #32 Then
        Result := Result + DWString(Format('\x%.2x', [SizeInt(S[I])]))
      Else
        Result := Result + S[I];
    End;
  End;
End;
Function StrToHex(Const Source: DWString): DWString;
Var
  Index: SizeInt;
  C, L, N: SizeInt;
  BL, BH: Byte;
  S: DWString;
Begin
  Result := '';
  If Source <> '' Then
  Begin
    S := Source;
    L := Length(S);
    If Odd(L) Then
    Begin
      S := '0' + S;
      Inc(L);
    End;
    Index := 1;
    SetLength(Result, L div 2);
    C := 1;
    N := 1;
    While C <= L Do
    Begin
      BH := CharHex(S[Index]);
      Inc(Index);
      BL := CharHex(S[Index]);
      Inc(Index);
      Inc(C, 2);
      If (BH = $FF) or (BL = $FF) Then
      Begin
        Result := '';
        Exit;
      End;
      PDWString(@Result[N])^ := DWChar((Cardinal(BH) shl 4) or Cardinal(BL));
      Inc(N);
    End;
  End;
End;
Function StrTrimCharLeft(Const S: DWString; C: DWChar): DWString;
Var
  I, L: SizeInt;
Begin
  I := 1;
  L := Length(S);
  While (I <= L) and (PDWString(@S[I])^ = C) Do
    Inc(I);
  Result := Copy(S, I, L - I + 1);
End;
Function StrTrimCharsLeft(Const S: DWString; Const Chars: TSysCharSet): DWString;
Var
  I, L: SizeInt;
Begin
  I := 1;
  L := Length(S);
  While (I <= L) and (S[I] in Chars) Do
    Inc(I);
  Result := Copy(S, I, L - I + 1);
End;
Function StrTrimCharsRight(Const S: DWString; Const Chars: TSysCharSet): DWString;
Var
  I: SizeInt;
Begin
  I := Length(S);
  While (I >= 1) and (S[I] in Chars) Do
    Dec(I);
  Result := Copy(S, 1, I);
End;
Function StrTrimCharRight(Const S: DWString; C: DWChar): DWString;
Var
  I: SizeInt;
Begin
  I := Length(S);
  While (I >= 1) and (PDWString(@S[I])^ = C) Do
    Dec(I);
  Result := Copy(S, 1, I);
End;
Function StrTrimQuotes(Const S: DWString): DWString;
Var
  First, Last: DWChar;
  L: SizeInt;
Begin
  L := Length(S);
  If L > 1 Then
  Begin
    PDWString(@First)^ := S[1];
    PDWString(@Last)^ := S[L];
    If (First = Last) and ((First = AnsiSingleQuote) or (First = AnsiDoubleQuote)) Then
      Result := Copy(S, 2, L - 2)
    Else
      Result := S;
  End
  Else
    Result := S;
End;
Function StrTrimQuotes(Const S: DWString; QuoteChar: DWChar): DWString;
Var
  First, Last: DWChar;
  L: SizeInt;
Begin
  L := Length(S);
  If L > 1 Then
  Begin
    PDWString(@First)^ := S[1];
    PDWString(@Last)^ := S[L];
    If (First = Last) and (First = QuoteChar) Then
      Result := Copy(S, 2, L - 2)
    Else
      Result := S;
  End
  Else
    Result := S;
End;
Procedure StrDecRef(Var S: DWString);
Var
  P: PAnsiStrRec;
Begin
  P := Pointer(S);
  If P <> nil Then
  Begin
    Dec(P);
    Case P^.RefCount Of
      -1, 0:
        { nothing } ;
      1:
        Begin
          Finalize(S);
          Pointer(S) := nil;
        End;
//    else
//      LockedDec(P^.RefCount);
    End;
  End;
End;
Function StrLength(Const S: DWString): Longint;
Var
  P: PAnsiStrRec;
Begin
  Result := 0;
  P := Pointer(S);
  If P <> nil Then
  Begin
    Dec(P);
    Result := P^.Length and (not $80000000 shr 1);
  End;
End;
Function StrRefCount(Const S: DWString): Longint;
Var
  P: PAnsiStrRec;
Begin
  Result := 0;
  P := Pointer(S);
  If P <> nil Then
  Begin
    Dec(P);
    Result := P^.RefCount;
  End;
End;
Procedure StrResetLength(Var S: DWString);
Var
  I: SizeInt;
Begin
  For I := 0 To Length(S) - 1 Do
    If S[I + 1] = #0 Then
    Begin
      SetLength(S, I);
      Exit;
    End;
End;
//=== String Search and Replace Routines =====================================
Function StrCharCount(Const S: DWString; C: DWChar): SizeInt;
Var
  I: SizeInt;
Begin
  Result := 0;
  For I := 1 To Length(S) Do
    If PDWString(@S[I])^ = C Then
      Inc(Result);
End;
Function StrCharsCount(Const S: DWString; Chars: TSysCharSet): SizeInt;
Var
  I: SizeInt;
Begin
  Result := 0;
  For I := 1 To Length(S) Do
    If S[I] in Chars Then
      Inc(Result);
End;
Function StrStrCount(Const S, SubS: DWString): SizeInt;
Var
  I: SizeInt;
Begin
  Result := 0;
  If (Length(SubS) > Length(S)) or (Length(SubS) = 0) or (Length(S) = 0) Then
    Exit;
  If Length(SubS) = 1 Then
  Begin
    Result := StrCharCount(S, SubS[1]);
    Exit;
  End;
  I := StrSearch(SubS, S, 1);
  If I > 0 Then
    Inc(Result);
  While (I > 0) and (Length(S) > I + Length(SubS)) Do
  Begin
    I := StrSearch(SubS, S, I + 1);
    If I > 0 Then
      Inc(Result);
  End;
End;
(*
{ 1}  Test(StrCompareRange('', '', 1, 5), 0);
{ 2}  Test(StrCompareRange('A', '', 1, 5), -1);
{ 3}  Test(StrCompareRange('AB', '', 1, 5), -1);
{ 4}  Test(StrCompareRange('ABC', '', 1, 5), -1);
{ 5}  Test(StrCompareRange('', 'A', 1, 5), -1);
{ 6}  Test(StrCompareRange('', 'AB',  1, 5), -1);
{ 7}  Test(StrCompareRange('', 'ABC', 1, 5), -1);
{ 8}  Test(StrCompareRange('A', 'a', 1, 5), -2);
{ 9}  Test(StrCompareRange('A', 'a', 1, 1), -32);
{10}  Test(StrCompareRange('aA', 'aB', 1, 1), 0);
{11}  Test(StrCompareRange('aA', 'aB', 1, 2), -1);
{12}  Test(StrCompareRange('aB', 'aA', 1, 2), 1);
{13}  Test(StrCompareRange('aA', 'aa', 1, 2), -32);
{14}  Test(StrCompareRange('aa', 'aA', 1, 2), 32);
{15}  Test(StrCompareRange('', '', 1, 0), 0);
{16}  Test(StrCompareRange('A', 'A', 1, 0), -2);
{17}  Test(StrCompareRange('Aa', 'A', 1, 0), -2);
{18}  Test(StrCompareRange('Aa', 'Aa', 1, 2), 0);
{19}  Test(StrCompareRange('Aa', 'A', 1, 2), 0);
{20}  Test(StrCompareRange('Ba', 'A', 1, 2), 1);
*)
Function StrCompareRangeEx(Const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean): SizeInt;
Var
  Len1, Len2: SizeInt;
  I: SizeInt;
  C1, C2: DWChar;
Begin
  If Pointer(S1) = Pointer(S2) Then
  Begin
    If (Count <= 0) and (S1 <> '') Then
      Result := -2 // no work
    Else
      Result := 0;
  End
  Else
  If (S1 = '') or (S2 = '') Then
    Result := -1 // null string
  Else
  If Count <= 0 Then
    Result := -2 // no work
  Else
  Begin
    Len1 := Length(S1);
    Len2 := Length(S2);
    If (Index - 1) + Count > Len1 Then
      Result := -2
    Else
    Begin
      If (Index - 1) + Count > Len2 Then // strange behaviour, but the assembler code does it
        Count := Len2 - (Index - 1);
      If CaseSensitive Then
      Begin
        For I := 0 To Count - 1 Do
        Begin
          PDWString(@C1)^ := S1[Index + I];
          PDWString(@C2)^ := S2[Index + I];
          If C1 <> C2 Then
          Begin
            Result := Ord(C1) - Ord(C2);
            Exit;
          End;
        End;
      End
      Else
      Begin
        For I := 0 To Count - 1 Do
        Begin
          PDWString(@C1)^ := S1[Index + I];
          PDWString(@C2)^ := S2[Index + I];
          If C1 <> C2 Then
          Begin
            C1 := CharLower(C1);
            C2 := CharLower(C2);
            If C1 <> C2 Then
            Begin
              Result := Ord(C1) - Ord(C2);
              Exit;
            End;
          End;
        End;
      End;
      Result := 0;
    End;
  End;
End;
Function StrCompare(Const S1, S2: DWString; CaseSensitive: Boolean): SizeInt;
Var
  Len1, Len2: SizeInt;
Begin
  If Pointer(S1) = Pointer(S2) Then
    Result := 0
  Else
  Begin
    Len1 := Length(S1);
    Len2 := Length(S2);
    Result := Len1 - Len2;
    If Result = 0 Then
      Result := StrCompareRangeEx(S1, S2, 1, Len1, CaseSensitive);
  End;
End;
Function StrCompareRange(Const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean): SizeInt;
Begin
  Result := StrCompareRangeEx(S1, S2, Index, Count, CaseSensitive);
End;
Function StrRepeatChar(C: DWChar; Count: SizeInt): DWString;
Begin
  SetLength(Result, Count);
  If Count > 0 Then
    FillChar(Result[1], Count, C);
End;
Function StrFind(Const Substr, S: DWString; Const Index: SizeInt): SizeInt;
Var
  pos: SizeInt;
Begin
  If (SubStr <> '') and (S <> '') Then
  Begin
    pos := StrIPos(Substr, Copy(S, Index, Length(S) - Index + 1));
    If pos = 0 Then
      Result := 0
    Else
      Result := Index + Pos - 1;
  End
  Else
    Result := 0;
End;
Function StrHasPrefix(Const S: DWString; Const Prefixes: array Of DWString): Boolean;
Begin
  Result := StrPrefixIndex(S, Prefixes) > -1;
End;
Function StrHasSuffix(Const S: DWString; Const Suffixes: array Of DWString): Boolean;
Begin
  Result := StrSuffixIndex(S, Suffixes) > -1;
End;
Function StrIHasPrefix(Const S: DWString; Const Prefixes: array Of DWString): Boolean;
Begin
  Result := StrIPrefixIndex(S, Prefixes) > -1;
End;
Function StrIHasSuffix(Const S: DWString; Const Suffixes: array Of DWString): Boolean;
Begin
  Result := StrISuffixIndex(S, Suffixes) > -1;
End;
Function StrIndex(Const S: DWString; Const List: array Of DWString; CaseSensitive: Boolean): SizeInt;
Var
  I: SizeInt;
Begin
  Result := -1;
  For I := Low(List) To High(List) Do
  Begin
    If StrCompare(S, List[I], CaseSensitive) = 0 Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;
Function StrILastPos(Const SubStr, S: DWString): SizeInt;
Begin
  Result := StrLastPos(StrUpper(SubStr), StrUpper(S));
End;
Function StrIPos(Const SubStr, S: DWString): SizeInt;
Begin
  Result := Pos(StrUpper(SubStr), StrUpper(S));
End;
Function StrIPrefixIndex(Const S: DWString; Const Prefixes: array Of DWString): SizeInt;
Var
  I: SizeInt;
  Test: DWString;
Begin
  Result := -1;
  For I := Low(Prefixes) To High(Prefixes) Do
  Begin
    Test := StrLeft(S, Length(Prefixes[I]));
    If CompareText(Test, Prefixes[I]) = 0 Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;
Function StrIsOneOf(Const S: DWString; Const List: array Of DWString): Boolean;
Begin
  Result := StrIndex(S, List) > -1;
End;
Function StrISuffixIndex(Const S: DWString; Const Suffixes: array Of DWString): SizeInt;
Var
  I: SizeInt;
  Test: DWString;
Begin
  Result := -1;
  For I := Low(Suffixes) To High(Suffixes) Do
  Begin
    Test := StrRight(S, Length(Suffixes[I]));
    If CompareText(Test, Suffixes[I]) = 0 Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;
// IMPORTANT NOTE: The StrMatch function does currently not work with the Asterix (*)
// (*) acts like (?)
Function StrMatch(Const Substr, S: DWString; Index: SizeInt): SizeInt;
Var
  SI, SubI, SLen, SubLen: SizeInt;
  SubC: DWChar;
Begin
  SLen := Length(S);
  SubLen := Length(Substr);
  Result := 0;
  If (Index > SLen) or (SubLen = 0) Then
    Exit;
  While Index <= SLen Do
  Begin
    SubI := 1;
    SI := Index;
    While (SI <= SLen) and (SubI <= SubLen) Do
    Begin
      PDWString(@SubC)^ := Substr[SubI];
      If (SubC = '*') or (SubC = '?') or (PDWString(@SubC)^ = S[SI]) Then
      Begin
        Inc(SI);
        Inc(SubI);
      End
      Else
        Break;
    End;
    If SubI > SubLen Then
    Begin
      Result := Index;
      Break;
    End;
    Inc(Index);
  End;
End;

Function StrNPos(Const S, SubStr: DWString; N: SizeInt): SizeInt;
Var
  I, P: SizeInt;
Begin
  If N < 1 Then
  Begin
    Result := 0;
    Exit;
  End;
  Result := StrSearch(SubStr, S, 1);
  I := 1;
  While I < N Do
  Begin
    P := StrSearch(SubStr, S, Result + 1);
    If P = 0 Then
    Begin
      Result := 0;
      Break;
    End
    Else
    Begin
      Result := P;
      Inc(I);
    End;
  End;
End;
Function StrNIPos(Const S, SubStr: DWString; N: SizeInt): SizeInt;
Var
  I, P: SizeInt;
Begin
  If N < 1 Then
  Begin
    Result := 0;
    Exit;
  End;
  Result := StrFind(SubStr, S, 1);
  I := 1;
  While I < N Do
  Begin
    P := StrFind(SubStr, S, Result + 1);
    If P = 0 Then
    Begin
      Result := 0;
      Break;
    End
    Else
    Begin
      Result := P;
      Inc(I);
    End;
  End;
End;
Function StrPrefixIndex(Const S: DWString; Const Prefixes: array Of DWString): SizeInt;
Var
  I: SizeInt;
  Test: DWString;
Begin
  Result := -1;
  For I := Low(Prefixes) To High(Prefixes) Do
  Begin
    Test := StrLeft(S, Length(Prefixes[I]));
    If CompareStr(Test, Prefixes[I]) = 0 Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;
Function StrSuffixIndex(Const S: DWString; Const Suffixes: array Of DWString): SizeInt;
Var
  I: SizeInt;
  Test: DWString;
Begin
  Result := -1;
  For I := Low(Suffixes) To High(Suffixes) Do
  Begin
    Test := StrRight(S, Length(Suffixes[I]));
    If CompareStr(Test, Suffixes[I]) = 0 Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;
//=== String Extraction ======================================================
Function StrAfter(Const SubStr, S: DWString): DWString;
Var
  P: SizeInt;
Begin
  P := StrFind(SubStr, S, 1); // StrFind is case-insensitive pos
  If P <= 0 Then
    Result := ''           // substr not found -> nothing after it
  Else
    Result := StrRestOf(S, P + Length(SubStr));
End;
Function StrBefore(Const SubStr, S: DWString): DWString;
Var
  P: SizeInt;
Begin
  P := StrFind(SubStr, S, 1);
  If P <= 0 Then
    Result := S
  Else
    Result := StrLeft(S, P - 1);
End;
Function StrSplit(Const SubStr, S: DWString;Var Left, Right : DWString): boolean;
Var
  P: SizeInt;
Begin
  P := StrFind(SubStr, S, 1);
  Result:= p > 0;
  If Result Then
  Begin
    Left := StrLeft(S, P - 1);
    Right := StrRestOf(S, P + Length(SubStr));
  End
  Else
  Begin
    Left := '';
    Right := '';
  End;
End;
Function StrBetween(Const S: DWString; Const Start, Stop: DWChar): DWString;
Var
  PosStart, PosEnd: SizeInt;
  L: SizeInt;
Begin
  PosStart := Pos(Start, S);
  PosEnd := StrSearch(Stop, S, PosStart + 1);  // PosEnd has to be after PosStart.
  If (PosStart > 0) and (PosEnd > PosStart) Then
  Begin
    L := PosEnd - PosStart;
    Result := Copy(S, PosStart + 1, L - 1);
  End
  Else
    Result := '';
End;
Function StrChopRight(Const S: DWString; N: SizeInt): DWString;
Begin
  Result := Copy(S, 1, Length(S) - N);
End;
Function StrLeft(Const S: DWString; Count: SizeInt): DWString;
Begin
  Result := Copy(S, 1, Count);
End;
Function StrMid(Const S: DWString; Start, Count: SizeInt): DWString;
Begin
  Result := Copy(S, Start, Count);
End;
Function StrRestOf(Const S: DWString; N: SizeInt): DWString;
Begin
  Result := Copy(S, N, (Length(S) - N + 1));
End;
Function StrRight(Const S: DWString; Count: SizeInt): DWString;
Begin
  Result := Copy(S, Length(S) - Count + 1, Count);
End;

Function CharIsDelete(Const C: DWChar): Boolean;
Begin
  Result := (C = #8);
End;

Function CharIsReturn(Const C: DWChar): Boolean;
Begin
  Result := (C = AnsiLineFeed) or (C = AnsiCarriageReturn);
End;
Function CharIsValidIdentifierLetter(Const C: DWChar): Boolean;
Begin
  Case C Of
    '0'..'9', 'A'..'Z', 'a'..'z', '_':
      Result := True;
  Else
    Result := False;
  End;
End;
Function CharIsWildcard(Const C: DWChar): Boolean;
Begin
  Case C Of
    '*', '?':
      Result := True;
  Else
    Result := False;
  End;
End;
Function CharType(Const C: DWChar): Word;
Begin
  Result := DWCharTypes[C];
End;
Function PCharVectorCount(Source: PAnsiCharVector): SizeInt;
Begin
  Result := 0;
  If Source <> nil Then
    While Source^ <> nil Do
  Begin
    Inc(Source);
    Inc(Result);
  End;
End;
//=== Character Transformation Routines ======================================
Function CharHex(Const C: DWChar): Byte;
Begin
  Case C Of
    '0'..'9':
      Result := Ord(C) - Ord('0');
    'a'..'f':
      Result := Ord(C) - Ord('a') + 10;
    'A'..'F':
      Result := Ord(C) - Ord('A') + 10;
  Else
    Result := $FF;
  End;
End;
Function CharLower(Const C: DWChar): DWChar;
Begin
  Result := AnsiCaseMap[Ord(C) + AnsiLoOffset];
End;
Function CharToggleCase(Const C: DWChar): DWChar;
Begin
  Result := AnsiCaseMap[Ord(C) + AnsiReOffset];
End;
Function CharUpper(Const C: DWChar): DWChar;
Begin
  Result := AnsiCaseMap[Ord(C) + AnsiUpOffset];
End;
//=== Character Search and Replace ===========================================
Function CharLastPos(Const S: DWString; Const C: DWChar; Const Index: SizeInt): SizeInt;
Begin
  If (Index > 0) and (Index <= Length(S)) Then
    For Result := Length(S) Downto Index Do
      If PDWString(@S[Result])^ = C Then
        Exit;
  Result := 0;
End;
Function CharPos(Const S: DWString; Const C: DWChar; Const Index: SizeInt): SizeInt;
Begin
  If (Index > 0) and (Index <= Length(S)) Then
    For Result := Index To Length(S) Do
      If PDWString(@S[Result])^ = C Then
        Exit;
  Result := 0;
End;
Function CharIPos(Const S: DWString; C: DWChar; Const Index: SizeInt): SizeInt;
Begin
  If (Index > 0) and (Index <= Length(S)) Then
  Begin
    C := CharUpper(C);
    For Result := Index To Length(S) Do
      If AnsiCaseMap[Ord(S[Result]) + AnsiUpOffset] = C Then
        Exit;
  End;
  Result := 0;
End;
Procedure AllocateMultiSz(Var Dest: PAnsiMultiSz; Len: SizeInt);
Begin
  If Len > 0 Then
    GetMem(Dest, Len * SizeOf(DWChar))
  Else
    Dest := nil;
End;
Procedure FreeMultiSz(Var Dest: PAnsiMultiSz);
Begin
  If Dest <> nil Then
    FreeMem(Dest);
  Dest := nil;
End;
//=== TJclAnsiStrings Manipulation ===============================================
Procedure StrToStrings(S, Sep: DWString; Const List: TJclAnsiStrings; Const AllowEmptyString: Boolean = True);
Var
  I, L: SizeInt;
  Left: DWString;
Begin
  Assert(List <> nil);
  List.BeginUpdate;
  Try
    List.Clear;
    L := Length(Sep);
    I := Pos(Sep, S);
    While I > 0 Do
    Begin
      Left := StrLeft(S, I - 1);
      If (Left <> '') or AllowEmptyString Then
        List.Add(Left);
      Delete(S, 1, I + L - 1);
      I := Pos(Sep, S);
    End;
    If (S <> '') or AllowEmptyString Then
      List.Add(S);  // Ignore empty strings at the end (only if AllowEmptyString = False).
  Finally
    List.EndUpdate;
  End;
End;
Procedure StrIToStrings(S, Sep: DWString; Const List: TJclAnsiStrings; Const AllowEmptyString: Boolean = True);
Var
  I, L: SizeInt;
  LowerCaseStr: DWString;
  Left: DWString;
Begin
  Assert(List <> nil);
  LowerCaseStr := StrLower(S);
  Sep := StrLower(Sep);
  L := Length(Sep);
  I := Pos(Sep, LowerCaseStr);
  List.BeginUpdate;
  Try
    List.Clear;
    While I > 0 Do
    Begin
      Left := StrLeft(S, I - 1);
      If (Left <> '') or AllowEmptyString Then
        List.Add(Left);
      Delete(S, 1, I + L - 1);
      Delete(LowerCaseStr, 1, I + L - 1);
      I := Pos(Sep, LowerCaseStr);
    End;
    If (S <> '') or AllowEmptyString Then
      List.Add(S);  // Ignore empty strings at the end (only if AllowEmptyString = False).
  Finally
    List.EndUpdate;
  End;
End;
Function StringsToStr(Const List: TJclAnsiStrings; Const Sep: DWString;
  Const AllowEmptyString: Boolean): DWString;
Var
  I, L: SizeInt;
Begin
  Result := '';
  For I := 0 To List.Count - 1 Do
  Begin
    If (List[I] <> '') or AllowEmptyString Then
    Begin
      // don't combine these into one addition, somehow it hurts performance
      Result := Result + List[I];
      Result := Result + Sep;
    End;
  End;
  // remove terminating separator
  If List.Count <> 0 Then
  Begin
    L := Length(Sep);
    Delete(Result, Length(Result) - L + 1, L);
  End;
End;
Procedure TrimStrings(Const List: TJclAnsiStrings; DeleteIfEmpty: Boolean);
Var
  I: SizeInt;
Begin
  Assert(List <> nil);
  List.BeginUpdate;
  Try
    For I := List.Count - 1 Downto 0 Do
    Begin
      List[I] := Trim(List[I]);
      If (List[I] = '') and DeleteIfEmpty Then
        List.Delete(I);
    End;
  Finally
    List.EndUpdate;
  End;
End;
Procedure TrimStringsRight(Const List: TJclAnsiStrings; DeleteIfEmpty: Boolean);
Var
  I: SizeInt;
Begin
  Assert(List <> nil);
  List.BeginUpdate;
  Try
    For I := List.Count - 1 Downto 0 Do
    Begin
      List[I] := TrimRight(List[I]);
      If (List[I] = '') and DeleteIfEmpty Then
        List.Delete(I);
    End;
  Finally
    List.EndUpdate;
  End;
End;
Procedure TrimStringsLeft(Const List: TJclAnsiStrings; DeleteIfEmpty: Boolean);
Var
  I: SizeInt;
Begin
  Assert(List <> nil);
  List.BeginUpdate;
  Try
    For I := List.Count - 1 Downto 0 Do
    Begin
      List[I] := TrimLeft(List[I]);
      If (List[I] = '') and DeleteIfEmpty Then
        List.Delete(I);
    End;
  Finally
    List.EndUpdate;
  End;
End;
Function AddStringToStrings(Const S: DWString; Strings: TJclAnsiStrings; Const Unique: Boolean): Boolean;
Begin
  Assert(Strings <> nil);
  Result := Unique and (Strings.IndexOf(S) <> -1);
  If not Result Then
    Result := Strings.Add(S) > -1;
End;
//=== Miscellaneous ==========================================================
Function FileToString(Const FileName: TFileName): DWString;
Var
  FS: TFileStream;
  Len: SizeInt;
Begin
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Try
    Len := FS.Size;
    SetLength(Result, Len);
    If Len > 0 Then
    FS.ReadBuffer(Result[1], Len);
  Finally
    FS.Free;
  End;
End;
Procedure StringToFile(Const FileName: TFileName; Const Contents: DWString; Append: Boolean);
Var
  FS: TFileStream;
  Len: SizeInt;
Begin
  If Append and FileExists(FileName) Then
    FS := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite)
  Else
    FS := TFileStream.Create(FileName, fmCreate);
  Try
    If Append Then
      FS.Seek(0, soEnd);  // faster than .Position := .Size
    Len := Length(Contents);
    If Len > 0 Then
    FS.WriteBuffer(Contents[1], Len);
  Finally
    FS.Free;
  End;
End;
Function StrToken(Var S: DWString; Separator: DWChar): DWString;
Var
  I: SizeInt;
Begin
  I := Pos(Separator, S);
  If I <> 0 Then
  Begin
    Result := Copy(S, 1, I - 1);
    Delete(S, 1, I);
  End
  Else
  Begin
    Result := S;
    S := '';
  End;
End;

//procedure StrTokenToStrings(S: string; Separator: Char; const List: TStrings);
//var
//  Token: string;
//begin
//  Assert(List <> nil);
//  if List = nil then
//    Exit;
//  List.BeginUpdate;
//  try
//    List.Clear;
//    while S <> '' do
//    begin
//      Token := uRESTDWMemStringsB.StrToken(S, Separator);
//      List.Add(Token);
//    end;
//  finally
//    List.EndUpdate;
//  end;
//end;

Procedure StrNormIndex(Const StrLen: SizeInt; Var Index: SizeInt; Var Count: SizeInt); overload;
Begin
  Index := Max(1, Min(Index, StrLen + 1));
  Count := Max(0, Min(Count, StrLen + 1 - Index));
End;
Function ArrayOf(List: TJclAnsiStrings): TDynStringArray;
Var
  I: SizeInt;
Begin
  If List <> nil Then
  Begin
    SetLength(Result, List.Count);
    For I := 0 To List.Count - 1 Do
      Result[I] := string(List[I]);
  End
  Else
    Result := nil;
End;

Initialization
 LoadCharTypes;  // this table first
End.
