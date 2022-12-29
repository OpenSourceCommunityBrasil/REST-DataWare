unit uRESTDWMemAnsiStrings;

{$I ..\..\Includes\uRESTDWPlataform.inc}
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

{$IFDEF FPC}
 {$MODE Delphi}
 {$ASMMode Intel}
{$ENDIF}

interface
uses
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
  uRESTDWMemBase, Math;
// Ansi types
type
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    DWString     = String;
    DWWideString = WideString;
    DWChar       = Char;
   {$ELSE}
    DWString     = Utf8String;
    DWWideString = WideString;
    DWChar       = Utf8Char;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    DWString     = Utf8String;
    DWWideString = Utf8String;
    DWChar       = Utf8Char;
   {$ELSE}
    DWString     = AnsiString;
    DWWideString = WideString;
    DWChar       = AnsiChar;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  DWString     = AnsiString;
  DWWideString = WideString;
  DWChar       = AnsiChar;
 {$ENDIF}
  {$IFDEF SUPPORTS_UNICODE}
  TJclAnsiStringList = class;
  // Codegear should be the one providing this class, in the DWStrings unit.
  // It has been requested in QC 65630 but this was closed as "won't do".
  // So we are providing here a very light implementation that is designed
  // to provide the basics, and in no way be a "copy/paste" of what is in the RTL.
  TJclAnsiStrings = class(TPersistent)
  private
    FDelimiter: DWChar;
    FNameValueSeparator: DWChar;
    FStrictDelimiter: Boolean;
    FQuoteChar: DWChar;
    FUpdateCount: Integer;
    function GetText: DWString;
    procedure SetText(const Value: DWString);
    function ExtractName(const S: DWString): DWString;
    function GetName(Index: Integer): DWString;
    function GetValue(const Name: DWString): DWString;
    procedure SetValue(const Name, Value: DWString);
    function GetValueFromIndex(Index: Integer): DWString;
    procedure SetValueFromIndex(Index: Integer; const Value: DWString);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure Error(const Msg: string; Data: Integer); overload;
    procedure Error(Msg: PResStringRec; Data: Integer); overload;
    function GetString(Index: Integer): DWString; virtual; abstract;
    procedure SetString(Index: Integer; const Value: DWString); virtual; abstract;
    function GetObject(Index: Integer): TObject; virtual; abstract;
    procedure SetObject(Index: Integer; AObject: TObject); virtual; abstract;
    function GetCapacity: Integer; virtual;
    procedure SetCapacity(const Value: Integer); virtual;
    function GetCount: Integer; virtual; abstract;
    function CompareStrings(const S1, S2: DWString): Integer; virtual;
    procedure SetUpdateState(Updating: Boolean); virtual;
    property UpdateCount: Integer read FUpdateCount;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function Add(const S: DWString): Integer; virtual;
    function AddObject(const S: DWString; AObject: TObject): Integer; virtual; abstract;
    procedure AddStrings(Strings: TJclAnsiStrings); virtual;
    procedure Insert(Index: Integer; const S: DWString); virtual;
    procedure InsertObject(Index: Integer; const S: DWString; AObject: TObject); virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure Clear; virtual; abstract;
    procedure LoadFromFile(const FileName: TFileName); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToFile(const FileName: TFileName); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure BeginUpdate;
    procedure EndUpdate;
    function IndexOf(const S: DWString): Integer; virtual;
    function IndexOfName(const Name: DWString): Integer; virtual;
    function IndexOfObject(AObject: TObject): Integer; virtual;
    procedure Exchange(Index1, Index2: Integer); virtual;
    property Delimiter: DWChar read FDelimiter write FDelimiter;
    property StrictDelimiter: Boolean read FStrictDelimiter write FStrictDelimiter;
    property QuoteChar: DWChar read FQuoteChar write FQuoteChar;
    property Strings[Index: Integer]: DWString read GetString write SetString; default;
    property Objects[Index: Integer]: TObject read GetObject write SetObject;
    property Text: DWString read GetText write SetText;
    property Count: Integer read GetCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Names[Index: Integer]: DWString read GetName;
    property Values[const Name: DWString]: DWString read GetValue write SetValue;
    property ValueFromIndex[Index: Integer]: DWString read GetValueFromIndex write SetValueFromIndex;
    property NameValueSeparator: DWChar read FNameValueSeparator write FNameValueSeparator;
  end;
  TJclAnsiStringListSortCompare = function(List: TJclAnsiStringList; Index1, Index2: Integer): Integer;
  TJclAnsiStringObjectHolder = record
    Str: DWString;
    Obj: TObject;
  end;
  TJclAnsiStringList = class(TJclAnsiStrings)
  private
    FStrings: array of TJclAnsiStringObjectHolder;
    FCount: Integer;
    FDuplicates: TDuplicates;
    FSorted: Boolean;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure Grow;
    procedure QuickSort(L, R: Integer; SCompare: TJclAnsiStringListSortCompare);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function GetString(Index: Integer): DWString; override;
    function GetObject(Index: Integer): TObject; override;
    procedure SetObject(Index: Integer; AObject: TObject); override;
    function GetCapacity: Integer; override;
    procedure SetCapacity(const Value: Integer); override;
    function GetCount: Integer; override;
    function CompareStrings(const S1, S2: DWString): Integer; override;
    procedure SetUpdateState(Updating: Boolean); override;
    procedure Changed; virtual;
    procedure Changing; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure InsertObject(Index: Integer; const S: DWString; AObject: TObject); override;
    procedure Delete(Index: Integer); override;
    function Find(const S: DWString; var Index: Integer): Boolean; virtual;
    procedure Clear; override;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  end;
  {$ELSE ~SUPPORTS_UNICODE}
  TJclAnsiStrings = Classes.TStrings;
  TJclAnsiStringList = Classes.TStringList;
  {$ENDIF ~SUPPORTS_UNICODE}
  TAnsiStrings = TJclAnsiStrings;
  TAnsiStringList = TJclAnsiStringList;
// Exceptions
type
  EJclAnsiStringError = class(EJclError);
  EJclAnsiStringListError = class(EJclAnsiStringError);
// Character constants and sets
const
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
const
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
function StrContainsChars(const S: DWString; Chars: TSysCharSet; CheckAll: Boolean): Boolean;
function StrIsSubset(const S: DWString; const ValidChars: TSysCharSet): Boolean;
function StrSame(const S1, S2: DWString): Boolean;
// String Transformation Routines
function StrCenter(const S: DWString; L: SizeInt; C: DWChar = ' '): DWString;
function StrCharPosLower(const S: DWString; CharPos: SizeInt): DWString;
function StrCharPosUpper(const S: DWString; CharPos: SizeInt): DWString;
function StrDoubleQuote(const S: DWString): DWString;
function StrEnsureNoPrefix(const Prefix, Text: DWString): DWString;
function StrEnsureNoSuffix(const Suffix, Text: DWString): DWString;
function StrEnsurePrefix(const Prefix, Text: DWString): DWString;
function StrEnsureSuffix(const Suffix, Text: DWString): DWString;
function StrEscapedToString(const S: DWString): DWString;
procedure StrMove(var Dest: DWString; const Source: DWString; const ToIndex,
  FromIndex, Count: SizeInt);
function StrPadLeft(const S: DWString; Len: SizeInt; C: DWChar = AnsiSpace): DWString;
function StrPadRight(const S: DWString; Len: SizeInt; C: DWChar = AnsiSpace): DWString;
function StrProper(const S: DWString): DWString;
function StrQuote(const S: DWString; C: DWChar): DWString;
function StrReplaceChar(const S: DWString; const Source, Replace: DWChar): DWString;
function StrReplaceChars(const S: DWString; const Chars: TSysCharSet; Replace: DWChar): DWString;
function StrReplaceButChars(const S: DWString; const Chars: TSysCharSet; Replace: DWChar): DWString;
function StrSingleQuote(const S: DWString): DWString;
procedure StrSkipChars(const S: DWString; var Index: SizeInt; const Chars: TSysCharSet); overload;
function StrStringToEscaped(const S: DWString): DWString;
function StrToHex(const Source: DWString): DWString;
function StrTrimCharLeft(const S: DWString; C: DWChar): DWString;
function StrTrimCharsLeft(const S: DWString; const Chars: TSysCharSet): DWString;
function StrTrimCharRight(const S: DWString; C: DWChar): DWString;
function StrTrimCharsRight(const S: DWString; const Chars: TSysCharSet): DWString;
function StrTrimQuotes(const S: DWString): DWString; overload;
function StrTrimQuotes(const S: DWString; QuoteChar: DWChar): DWString; overload;
// String Management
procedure StrDecRef(var S: DWString);
function StrLength(const S: DWString): Longint;
function StrRefCount(const S: DWString): Longint;
procedure StrResetLength(var S: DWString);
// String Search and Replace Routines
function StrCharCount(const S: DWString; C: DWChar): SizeInt;
function StrCharsCount(const S: DWString; Chars: TSysCharSet): SizeInt;
function StrStrCount(const S, SubS: DWString): SizeInt;
function StrCompare(const S1, S2: DWString; CaseSensitive: Boolean = False): SizeInt;
function StrCompareRangeEx(const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean = False): SizeInt;
function StrCompareRange(const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean = True): SizeInt;
function StrRepeatChar(C: DWChar; Count: SizeInt): DWString;
function StrFind(const Substr, S: DWString; const Index: SizeInt = 1): SizeInt;
function StrHasPrefix(const S: DWString; const Prefixes: array of DWString): Boolean;
function StrHasSuffix(const S: DWString; const Suffixes: array of DWString): Boolean;
function StrIHasPrefix(const S: DWString; const Prefixes: array of DWString): Boolean;
function StrIHasSuffix(const S: DWString; const Suffixes: array of DWString): Boolean;
function StrIndex(const S: DWString; const List: array of DWString; CaseSensitive: Boolean = False): SizeInt;
function StrILastPos(const SubStr, S: DWString): SizeInt;
function StrIPos(const SubStr, S: DWString): SizeInt;
function StrIPrefixIndex(const S: DWString; const Prefixes: array of DWString): SizeInt;
function StrIsOneOf(const S: DWString; const List: array of DWString): Boolean;
function StrISuffixIndex(const S: DWString; const Suffixes: array of DWString): SizeInt;
function StrMatch(const Substr, S: DWString; Index: SizeInt = 1): SizeInt;
function StrNIPos(const S, SubStr: DWString; N: SizeInt): SizeInt;
function StrNPos(const S, SubStr: DWString; N: SizeInt): SizeInt;
function StrPrefixIndex(const S: DWString; const Prefixes: array of DWString): SizeInt;
function StrSuffixIndex(const S: DWString; const Suffixes: array of DWString): SizeInt;
// String Extraction
// String Extraction
// Returns the String before SubStr
function StrAfter(const SubStr, S: DWString): DWString;
/// Returns the DWString after SubStr
function StrBefore(const SubStr, S: DWString): DWString;
/// Splits a DWString at SubStr, returns true when SubStr is found, Left contains the
/// DWString before the SubStr and Rigth the DWString behind SubStr
function StrSplit(const SubStr, S: DWString;var Left, Right : DWString): boolean;
/// Returns the DWString between Start and Stop
function StrBetween(const S: DWString; const Start, Stop: DWChar): DWString;
/// Returns the left N characters of the DWString
function StrChopRight(const S: DWString; N: SizeInt): DWString;
/// Returns the left Count characters of the DWString
function StrLeft(const S: DWString; Count: SizeInt): DWString;
/// Returns the DWString starting from position Start for the Count Characters
function StrMid(const S: DWString; Start, Count: SizeInt): DWString;
/// Returns the DWString starting from position N to the end
function StrRestOf(const S: DWString; N: SizeInt): DWString;
/// Returns the right Count characters of the DWString
function StrRight(const S: DWString; Count: SizeInt): DWString;
// Character Test Routines
function CharIsDelete(const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function CharIsReturn(const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function CharIsValidIdentifierLetter(const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function CharIsWildcard(const C: DWChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function CharType(const C: DWChar): Word;
// Character Transformation Routines
function CharHex(const C: DWChar): Byte;
function CharLower(const C: DWChar): DWChar;
function CharUpper(const C: DWChar): DWChar;
function CharToggleCase(const C: DWChar): DWChar;
// Character Search and Replace
function CharPos(const S: DWString; const C: DWChar; const Index: SizeInt = 1): SizeInt;
function CharLastPos(const S: DWString; const C: DWChar; const Index: SizeInt = 1): SizeInt;
function CharIPos(const S: DWString; C: DWChar; const Index: SizeInt = 1): SizeInt;
// PCharVector
type
  PAnsiCharVector = ^PAnsiChar;
// MultiSz Routines
type
  PAnsiMultiSz = PAnsiChar;
procedure AllocateMultiSz(var Dest: PAnsiMultiSz; Len: SizeInt);
procedure FreeMultiSz(var Dest: PAnsiMultiSz);
procedure StrIToStrings(S, Sep: DWString; const List: TJclAnsiStrings; const AllowEmptyString: Boolean = True);
procedure StrToStrings(S, Sep: DWString; const List: TJclAnsiStrings; const AllowEmptyString: Boolean = True);
function StringsToStr(const List: TJclAnsiStrings; const Sep: DWString; const AllowEmptyString: Boolean = True): DWString;
procedure TrimStrings(const List: TJclAnsiStrings; DeleteIfEmpty: Boolean = True);
procedure TrimStringsRight(const List: TJclAnsiStrings; DeleteIfEmpty: Boolean = True);
procedure TrimStringsLeft(const List: TJclAnsiStrings; DeleteIfEmpty: Boolean = True);
function AddStringToStrings(const S: DWString; Strings: TJclAnsiStrings; const Unique: Boolean): Boolean;
// Miscellaneous
// (OF) moved to JclSysUtils
//function BooleanToStr(B: Boolean): DWString;
function FileToString(const FileName: TFileName): DWString;
procedure StringToFile(const FileName: TFileName; const Contents: DWString; Append: Boolean = False);
function StrToken(var S: DWString; Separator: DWChar): DWString;
//procedure StrTokenToStrings(S: DWString; Separator: DWChar; const List: TJclAnsiStrings);Overload;
//procedure StrTokenToStrings(S: string; Separator: Char; const List: TStrings);Overload;
procedure StrNormIndex(const StrLen: SizeInt; var Index: SizeInt; var Count: SizeInt); overload;
function ArrayOf(List: TJclAnsiStrings): TDynStringArray; overload;
// internal structures published to make function inlining working
const
  DWCharCount   = Ord(High(Char)) + 1; // # of chars in one set
  AnsiLoOffset    = DWCharCount * 0;       // offset to lower case chars
  AnsiUpOffset    = DWCharCount * 1;       // offset to upper case chars
  AnsiReOffset    = DWCharCount * 2;       // offset to reverse case chars
  AnsiCaseMapSize = DWCharCount * 3;       // # of chars is a table
var
  AnsiCaseMap: array [0..AnsiCaseMapSize - 1] of DWChar; // case mappings
  AnsiCaseMapReady: Boolean = False;         // true if case map exists
  DWCharTypes: array [Char] of Word;
implementation
uses
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
  uRESTDWMemStringsB, uRESTDWBasicTypes;
//=== Internal ===============================================================
type
  TAnsiStrRec = packed record
    RefCount: Integer;
    Length: Integer;
  end;
  PAnsiStrRec = ^TAnsiStrRec;
const
  AnsiStrRecSize  = SizeOf(TAnsiStrRec);     // size of the DWString header rec
procedure LoadCharTypes;
var
  CurrChar: DWChar;
  CurrType: Word;
begin
  for CurrChar := Low(DWChar) to High(DWChar) do
  begin
    {$IFDEF MSWINDOWS}
    CurrType := 0;
    GetStringTypeExA(LOCALE_USER_DEFAULT, CT_CTYPE1, @CurrChar, SizeOf(DWChar), CurrType);
    {$DEFINE CHAR_TYPES_INITIALIZED}
    {$ENDIF MSWINDOWS}
    {$IFDEF LINUX}
    CurrType := 0;
    if isupper(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_UPPER;
    if islower(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_LOWER;
    if isdigit(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_DIGIT;
    if isspace(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_SPACE;
    if ispunct(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_PUNCT;
    if iscntrl(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_CNTRL;
    if isblank(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_BLANK;
    if isxdigit(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_XDIGIT;
    if isalpha(Byte(CurrChar)) <> 0 then
      CurrType := CurrType or C1_ALPHA;
    {$DEFINE CHAR_TYPES_INITIALIZED}
    {$ENDIF LINUX}
    DWCharTypes[CurrChar] := CurrType;
  end;
end;
{$IFDEF SUPPORTS_UNICODE}
//=== { TJclAnsiStrings } ====================================================
constructor TJclAnsiStrings.Create;
begin
  inherited Create;
  FDelimiter := ',';
  FNameValueSeparator := '=';
  FQuoteChar := '"';
  FStrictDelimiter := False;
end;
procedure TJclAnsiStrings.Assign(Source: TPersistent);
var
  StringsSource: TStrings;
  I: Integer;
begin
  if Source is TStrings then
  begin
    StringsSource := TStrings(Source);
    BeginUpdate;
    try
      Clear;
      FDelimiter := DWChar(StringsSource.Delimiter);
      FNameValueSeparator := DWChar(StringsSource.NameValueSeparator);
      for I := 0 to StringsSource.Count - 1 do
        AddObject(DWString(StringsSource.Strings[I]), StringsSource.Objects[I]);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;
procedure TJclAnsiStrings.AssignTo(Dest: TPersistent);
var
  StringsDest: TStrings;
  DWStringsDest: TJclAnsiStrings;
  I: Integer;
begin
  if Dest is TStrings then
  begin
    StringsDest := TStrings(Dest);
    StringsDest.BeginUpdate;
    try
      StringsDest.Clear;
      StringsDest.Delimiter := Char(Delimiter);
      StringsDest.NameValueSeparator := Char(NameValueSeparator);
      for I := 0 to Count - 1 do
        StringsDest.AddObject(string(Strings[I]), Objects[I]);
    finally
      StringsDest.EndUpdate;
    end;
  end
  else
  if Dest is TJclAnsiStrings then
  begin
    DWStringsDest := TJclAnsiStrings(Dest);
    BeginUpdate;
    try
      DWStringsDest.Clear;
      DWStringsDest.FNameValueSeparator := FNameValueSeparator;
      DWStringsDest.FDelimiter := FDelimiter;
      for I := 0 to Count - 1 do
        DWStringsDest.AddObject(Strings[I], Objects[I]);
    finally
      EndUpdate;
    end;
  end
  else
    inherited AssignTo(Dest);
end;
function TJclAnsiStrings.Add(const S: DWString): Integer;
begin
  Result := AddObject(S, nil);
end;
procedure TJclAnsiStrings.AddStrings(Strings: TJclAnsiStrings);
var
  I: Integer;
begin
  for I := 0 to Strings.Count - 1 do
    Add(Strings.Strings[I]);
end;
procedure TJclAnsiStrings.Error(const Msg: string; Data: Integer);
begin
  raise EJclAnsiStringListError.CreateFmt(Msg, [Data]);
end;
procedure TJclAnsiStrings.Error(Msg: PResStringRec; Data: Integer);
begin
  Error(LoadResString(Msg), Data);
end;
function TJclAnsiStrings.CompareStrings(const S1, S2: DWString): Integer;
begin
  Result := CompareStr(S1, S2);
end;
procedure TJclAnsiStrings.SetUpdateState(Updating: Boolean);
begin
end;
function TJclAnsiStrings.IndexOf(const S: DWString): Integer;
begin
  for Result := 0 to Count - 1 do
    if CompareStrings(Strings[Result], S) = 0 then
      Exit;
  Result := -1;
end;
function TJclAnsiStrings.IndexOfName(const Name: DWString): Integer;
var
  P: Integer;
  S: DWString;
begin
  for Result := 0 to Count - 1 do
  begin
    S := Strings[Result];
    P := AnsiPos(NameValueSeparator, S);
    if (P > 0) and (CompareStrings(Copy(S, 1, P - 1), Name) = 0) then
      Exit;
  end;
  Result := -1;
end;
function TJclAnsiStrings.IndexOfObject(AObject: TObject): Integer;
begin
  for Result := 0 to Count - 1 do
    if Objects[Result] = AObject then
      Exit;
  Result := -1;
end;
procedure TJclAnsiStrings.Exchange(Index1, Index2: Integer);
var
  TempString: DWString;
  TempObject: TObject;
begin
  BeginUpdate;
  try
    TempString := Strings[Index1];
    TempObject := Objects[Index1];
    Strings[Index1] := Strings[Index2];
    Objects[Index1] := Objects[Index2];
    Strings[Index2] := TempString;
    Objects[Index2] := TempObject;
  finally
    EndUpdate;
  end;
end;
procedure TJclAnsiStrings.Insert(Index: Integer; const S: DWString);
begin
  InsertObject(Index, S, nil);
end;
function TJclAnsiStrings.GetText: DWString;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 2 do
    Result := Result + Strings[I] + sLineBreak;
  if Count > 0 then
    Result := Result + Strings[Count - 1] + sLineBreak;
end;
procedure TJclAnsiStrings.SetText(const Value: DWString);
var
  Index, Start, Len: Integer;
  S: DWString;
begin
  Clear;
  Len := Length(Value);
  Index := 1;
  while Index <= Len do
  begin
    Start := Index;
    while (Index <= Len) and not CharIsReturn(Value[Index]) do
      Inc(Index);
    S := Copy(Value, Start, Index - Start);
    Add(S);
    if (Index <= Len) and (Value[Index] = AnsiCarriageReturn) then
      Inc(Index);
    if (Index <= Len) and (Value[Index] = AnsiLineFeed) then
      Inc(Index);
  end;
end;
function TJclAnsiStrings.GetCapacity: Integer;
begin
  Result := Count; // Might be overridden in derived classes
end;
procedure TJclAnsiStrings.SetCapacity(const Value: Integer);
begin
  // Nothing at this level
end;
procedure TJclAnsiStrings.BeginUpdate;
begin
  if FUpdateCount = 0 then SetUpdateState(True);
  Inc(FUpdateCount);
end;
procedure TJclAnsiStrings.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then SetUpdateState(False);
end;
procedure TJclAnsiStrings.LoadFromFile(const FileName: TFileName);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;
procedure TJclAnsiStrings.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  S: DWString;
begin
  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    System.SetString(S, nil, Size);
    Stream.Read(PAnsiChar(S)^, Size);
    SetText(S);
  finally
    EndUpdate;
  end;
end;
procedure TJclAnsiStrings.SaveToFile(const FileName: TFileName);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;
procedure TJclAnsiStrings.SaveToStream(Stream: TStream);
var
  S: DWString;
begin
  S := GetText;
  Stream.WriteBuffer(PAnsiChar(S)^, Length(S));
end;
function TJclAnsiStrings.ExtractName(const S: DWString): DWString;
var
  P: Integer;
begin
  Result := S;
  P := AnsiPos(NameValueSeparator, Result);
  if P > 0 then
    SetLength(Result, P - 1)
  else
    SetLength(Result, 0);
end;
function TJclAnsiStrings.GetName(Index: Integer): DWString;
begin
  Result := ExtractName(Strings[Index]);
end;
function TJclAnsiStrings.GetValue(const Name: DWString): DWString;
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if I >= 0 then
    Result := Copy(GetString(I), Length(Name) + 2, MaxInt)
  else
    Result := '';
end;
procedure TJclAnsiStrings.SetValue(const Name, Value: DWString);
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if Value <> '' then
  begin
    if I < 0 then
      I := Add('');
    SetString(I, Name + NameValueSeparator + Value);
  end
  else
  begin
    if I >= 0 then
      Delete(I);
  end;
end;
function TJclAnsiStrings.GetValueFromIndex(Index: Integer): DWString;
var
  S: DWString;
  P: Integer;
begin
  if Index >= 0 then
  begin
    S := Strings[Index];
    P := AnsiPos(NameValueSeparator, S);
    if P > 0 then
      Result := Copy(S, P + 1, Length(S) - P)
    else
      Result := '';
  end
  else
    Result := '';
end;
procedure TJclAnsiStrings.SetValueFromIndex(Index: Integer; const Value: DWString);
begin
  if Value <> '' then
  begin
    if Index < 0 then
      Index := Add('');
    SetString(Index, Names[Index] + NameValueSeparator + Value);
  end
  else
  begin
    if Index >= 0 then
      Delete(Index);
  end;
end;
//=== { TJclAnsiStringList } =================================================
constructor TJclAnsiStringList.Create;
begin
  inherited Create;
  FCaseSensitive := True;
end;
destructor TJclAnsiStringList.Destroy;
begin
  FOnChange := nil;
  FOnChanging := nil;
  inherited Destroy;
end;
procedure TJclAnsiStringList.Assign(Source: TPersistent);
var
  StringListSource: TStringList;
begin
  if Source is TStringList then
  begin
    StringListSource := TStringList(Source);
    FDuplicates := StringListSource.Duplicates;
    FSorted := StringListSource.Sorted;
    FCaseSensitive := StringListSource.CaseSensitive;
  end;
  inherited Assign(Source);
end;
procedure TJclAnsiStringList.AssignTo(Dest: TPersistent);
var
  StringListDest: TStringList;
  DWStringListDest: TJclAnsiStringList;
begin
  if Dest is TStringList then
  begin
    StringListDest := TStringList(Dest);
    StringListDest.Clear; // make following assignments a lot faster
    StringListDest.Duplicates := FDuplicates;
    StringListDest.Sorted := FSorted;
    StringListDest.CaseSensitive := FCaseSensitive;
  end
  else
  if Dest is TJclAnsiStringList then
  begin
    DWStringListDest := TJclAnsiStringList(Dest);
    DWStringListDest.Clear;
    DWStringListDest.FDuplicates := FDuplicates;
    DWStringListDest.FSorted := FSorted;
    DWStringListDest.FCaseSensitive := FCaseSensitive;
  end;
  inherited AssignTo(Dest);
end;
function TJclAnsiStringList.CompareStrings(const S1: DWString; const S2: DWString): Integer;
begin
  if FCaseSensitive then
    Result := CompareStr(S1, S2)
  else
    Result := CompareText(S1, S2);
end;
procedure TJclAnsiStringList.SetUpdateState(Updating: Boolean);
begin
  if Updating then Changing else Changed;
end;
procedure TJclAnsiStringList.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then
    FOnChange(Self);
end;
procedure TJclAnsiStringList.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;
procedure TJclAnsiStringList.Grow;
var
  Delta: Integer;
begin
  if Capacity > 64 then
    Delta := Capacity div 4
  else if Capacity > 8 then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(Capacity + Delta);
end;
function TJclAnsiStringList.GetString(Index: Integer): DWString;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Result := FStrings[Index].Str;
end;
function TJclAnsiStringList.GetObject(Index: Integer): TObject;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Result := FStrings[Index].Obj;
end;
procedure TJclAnsiStringList.SetObject(Index: Integer; AObject: TObject);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  FStrings[Index].Obj := AObject;
end;
function TJclAnsiStringList.GetCapacity: Integer;
begin
  Result := Length(FStrings);
end;
procedure TJclAnsiStringList.SetCapacity(const Value: Integer);
begin
  if (Value < FCount) then
    Error(@SListCapacityError, Value);
  if Value <> Capacity then
    SetLength(FStrings, Value);
end;
function TJclAnsiStringList.GetCount: Integer;
begin
  Result := FCount;
end;
procedure TJclAnsiStringList.InsertObject(Index: Integer; const S: DWString; AObject: TObject);
var
  I: Integer;
begin
  if Count = Capacity then
    Grow;
  for I := Count - 1 downto Index do
    FStrings[I + 1] := FStrings[I];
  FStrings[Index].Str := S;
  FStrings[Index].Obj := AObject;
  Inc(FCount);
end;
procedure TJclAnsiStringList.Delete(Index: Integer);
var
  I: Integer;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  for I := Index to Count - 2 do
    FStrings[I] := FStrings[I + 1];
    
  FStrings[FCount - 1].Str := '';  // the last string is no longer useful
    
  Dec(FCount);
end;
procedure TJclAnsiStringList.Clear;
var
  I: Integer;
begin
  FCount := 0;
  for I := 0 to Length(FStrings) - 1 do
  begin
    FStrings[I].Str := '';
    FStrings[I].Obj := nil;
  end;
end;
function TJclAnsiStringList.Find(const S: DWString; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareStrings(FStrings[I].Str, S);
    if C < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        if Duplicates <> dupAccept then
          L := I;
      end;
    end;
  end;
  Index := L;
end;
function DWStringListCompareStrings(List: TJclAnsiStringList; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareStrings(List.FStrings[Index1].Str,
                                List.FStrings[Index2].Str);
end;
procedure TJclAnsiStringList.QuickSort(L, R: Integer; SCompare: TJclAnsiStringListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do
        Inc(I);
      while SCompare(Self, J, P) > 0 do
        Dec(J);
      if I <= J then
      begin
        if I <> J then
          Exchange(I, J);
        if P = I then
          P := J
        else
        if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;
{$ENDIF SUPPORTS_UNICODE}
function StrContainsChars(const S: DWString; Chars: TSysCharSet; CheckAll: Boolean): Boolean;
var
  I: SizeInt;
  C: DWChar;
begin
  Result := Chars = [];
  if not Result then
  begin
    if CheckAll then
    begin
      for I := 1 to Length(S) do
      begin
        PDWString(@C)^ := Char(S[I]);
        if C in Chars then
        begin
          Chars := Chars - [C];
          if Chars = [] then
            Break;
        end;
      end;
      Result := (Chars = []);
    end
    else
    begin
      for I := 1 to Length(S) do
        if S[I] in Chars then
        begin
          Result := True;
          Break;
        end;
    end;
  end;
end;
function StrIsSubset(const S: DWString; const ValidChars: TSysCharSet): Boolean;
var
  I: SizeInt;
begin
  for I := 1 to Length(S) do
  begin
    if not (S[I] in ValidChars) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True and (Length(S) > 0);
end;
function StrSame(const S1, S2: DWString): Boolean;
begin
  Result := StrCompare(S1, S2) = 0;
end;
//=== String Transformation Routines =========================================
function StrCenter(const S: DWString; L: SizeInt; C: DWChar = ' '): DWString;
begin
  if Length(S) < L then
  begin
    Result := StringOfChar(C, (L - Length(S)) div 2) + S;
    Result := Result + StringOfChar(C, L - Length(Result));
  end
  else
    Result := S;
end;
function StrCharPosLower(const S: DWString; CharPos: SizeInt): DWString;
begin
  Result := S;
  if (CharPos > 0) and (CharPos <= Length(S)) then
    PDWString(@Result[CharPos])^ := CharLower(Result[CharPos]);
end;
function StrCharPosUpper(const S: DWString; CharPos: SizeInt): DWString;
begin
  Result := S;
  if (CharPos > 0) and (CharPos <= Length(S)) then
    PDWString(@Result[CharPos])^ := CharUpper(Result[CharPos]);
end;
function StrDoubleQuote(const S: DWString): DWString;
begin
  Result := AnsiDoubleQuote + S + AnsiDoubleQuote;
end;
function StrEnsureNoPrefix(const Prefix, Text: DWString): DWString;
var
  PrefixLen: SizeInt;
begin
  PrefixLen := Length(Prefix);
  if Copy(Text, 1, PrefixLen) = Prefix then
    Result := Copy(Text, PrefixLen + 1, Length(Text))
  else
    Result := Text;
end;
function StrEnsureNoSuffix(const Suffix, Text: DWString): DWString;
var
  SuffixLen: SizeInt;
  StrLength: SizeInt;
begin
  SuffixLen := Length(Suffix);
  StrLength := Length(Text);
  if Copy(Text, StrLength - SuffixLen + 1, SuffixLen) = Suffix then
    Result := Copy(Text, 1, StrLength - SuffixLen)
  else
    Result := Text;
end;
function StrEnsurePrefix(const Prefix, Text: DWString): DWString;
var
  PrefixLen: SizeInt;
begin
  PrefixLen := Length(Prefix);
  if Copy(Text, 1, PrefixLen) = Prefix then
    Result := Text
  else
    Result := Prefix + Text;
end;
function StrEnsureSuffix(const Suffix, Text: DWString): DWString;
var
  SuffixLen: SizeInt;
begin
  SuffixLen := Length(Suffix);
  if Copy(Text, Length(Text) - SuffixLen + 1, SuffixLen) = Suffix then
    Result := Text
  else
    Result := Text + Suffix;
end;
function StrEscapedToString(const S: DWString): DWString;
  procedure HandleHexEscapeSeq(const S: DWString; var I: SizeInt; Len: SizeInt; var Dest: DWString);
  const
    HexDigits = DWString('0123456789abcdefABCDEF');
  var
    StartI, Val, N: SizeInt;
  begin
    StartI := I;
    N := Pos(S[I + 1], HexDigits) - 1;
    if N < 0 then
      // '\x' without hex digit following is not escape sequence
      Dest := Dest + '\x'
    else
    begin
      Inc(I); // Jump over x
      if N >= 16 then
        N := N - 6;
      Val := N;
      // Same for second digit
      if I < Len then
      begin
        N := Pos(S[I + 1], HexDigits) - 1;
        if N >= 0 then
        begin
          Inc(I); // Jump over first digit
          if N >= 16 then
            N := N - 6;
          Val := Val * 16 + N;
        end;
      end;
      if Val > Ord(High(DWChar)) then
        raise EJclAnsiStringError.CreateResFmt(@RsNumericConstantTooLarge, [Val, StartI]);
      Dest := Dest + DWChar(Val);
    end;
  end;
  procedure HandleOctEscapeSeq(const S: DWString; var I: SizeInt; Len: SizeInt; var Dest: DWString);
  const
    OctDigits = DWString('01234567');
  var
    StartI, Val, N: SizeInt;
  begin
    StartI := I;
    // first digit
    Val := Pos(S[I], OctDigits) - 1;
    if I < Len then
    begin
      N := Pos(S[I + 1], OctDigits) - 1;
      if N >= 0 then
      begin
        Inc(I);
        Val := Val * 8 + N;
      end;
      if I < Len then
      begin
        N := Pos(S[I + 1], OctDigits) - 1;
        if N >= 0 then
        begin
          Inc(I);
          Val := Val * 8 + N;
        end;
      end;
    end;
    if Val > Ord(High(DWChar)) then
      raise EJclAnsiStringError.CreateResFmt(@RsNumericConstantTooLarge, [Val, StartI]);
    Dest := Dest + DWChar(Val);
  end;
var
  I, Len: SizeInt;
begin
  Result := '';
  I := 1;
  Len := Length(S);
  while I <= Len do
  begin
    if not ((S[I] = '\') and (I < Len)) then
      Result := Result + S[I]
    else
    begin
      Inc(I); // Jump over escape character
      case S[I] of
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
          if I < Len then
            // Start of hex escape sequence
            HandleHexEscapeSeq(S, I, Len, Result)
          else
            // '\x' at end of DWString is not escape sequence
            Result := Result + '\x';
        '0'..'7':
          // start of octal escape sequence
          HandleOctEscapeSeq(S, I, Len, Result);
      else
        // no escape sequence
        Result := Result + '\' + S[I];
      end;
    end;
    Inc(I);
  end;
end;
procedure StrMove(var Dest: DWString; const Source: DWString;
  const ToIndex, FromIndex, Count: SizeInt);
begin
  // Check strings
  if (Source = '') or (Length(Dest) = 0) then
    Exit;
  // Check FromIndex
  if (FromIndex <= 0) or (FromIndex > Length(Source)) or
    (ToIndex <= 0) or (ToIndex > Length(Dest)) or
    ((FromIndex + Count - 1) > Length(Source)) or ((ToIndex + Count - 1) > Length(Dest)) then
    { TODO : Is failure without notice the proper thing to do here? }
    Exit;
  // Move
  Move(Source[FromIndex], Dest[ToIndex], Count);
end;
function StrPadLeft(const S: DWString; Len: SizeInt; C: DWChar): DWString;
var
  L: SizeInt;
begin
  L := Length(S);
  if L < Len then
    Result := StringOfChar(C, Len - L) + S
  else
    Result := S;
end;
function StrPadRight(const S: DWString; Len: SizeInt; C: DWChar): DWString;
var
  L: SizeInt;
begin
  L := Length(S);
  if L < Len then
    Result := S + StringOfChar(C, Len - L)
  else
    Result := S;
end;
function StrProper(const S: DWString): DWString;
begin
  Result := StrLower(S);
  if Result <> '' then
    Result[1] := UpCase(Result[1]);
end;
function StrQuote(const S: DWString; C: DWChar): DWString;
var
  L: SizeInt;
begin
  L := Length(S);
  Result := S;
  if L > 0 then
  begin
    if PDWString(@Result[1])^ <> C then
    begin
      Result := C + Result;
      Inc(L);
    end;
    if PDWString(@Result[L])^ <> C then
      Result := Result + C;
  end;
end;
function StrReplaceChar(const S: DWString; const Source, Replace: DWChar): DWString;
var
  I: SizeInt;
begin
  Result := S;
  for I := 1 to Length(S) do
    if PDWString(@Result[I])^ = Source then
      PDWString(@Result[I])^ := Replace;
end;
function StrReplaceChars(const S: DWString; const Chars: TSysCharSet; Replace: DWChar): DWString;
var
  I: SizeInt;
begin
  Result := S;
  for I := 1 to Length(S) do
    if Result[I] in Chars then
      PDWString(@Result[I])^ := Replace;
end;
function StrReplaceButChars(const S: DWString; const Chars: TSysCharSet;
  Replace: DWChar): DWString;
var
  I: SizeInt;
begin
  Result := S;
  for I := 1 to Length(S) do
    if not (Result[I] in Chars) then
      PDWString(@Result[I])^ := Replace;
end;
function StrSingleQuote(const S: DWString): DWString;
begin
  Result := AnsiSingleQuote + S + AnsiSingleQuote;
end;
procedure StrSkipChars(const S: DWString; var Index: SizeInt; const Chars: TSysCharSet);
begin
  while S[Index] in Chars do
    Inc(Index);
end;
function StrStringToEscaped(const S: DWString): DWString;
var
  I: SizeInt;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    case S[I] of
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
    else
      // Characters < ' ' are escaped with hex sequence
      if S[I] < #32 then
        Result := Result + DWString(Format('\x%.2x', [SizeInt(S[I])]))
      else
        Result := Result + S[I];
    end;
  end;
end;
function StrToHex(const Source: DWString): DWString;
var
  Index: SizeInt;
  C, L, N: SizeInt;
  BL, BH: Byte;
  S: DWString;
begin
  Result := '';
  if Source <> '' then
  begin
    S := Source;
    L := Length(S);
    if Odd(L) then
    begin
      S := '0' + S;
      Inc(L);
    end;
    Index := 1;
    SetLength(Result, L div 2);
    C := 1;
    N := 1;
    while C <= L do
    begin
      BH := CharHex(S[Index]);
      Inc(Index);
      BL := CharHex(S[Index]);
      Inc(Index);
      Inc(C, 2);
      if (BH = $FF) or (BL = $FF) then
      begin
        Result := '';
        Exit;
      end;
      PDWString(@Result[N])^ := DWChar((Cardinal(BH) shl 4) or Cardinal(BL));
      Inc(N);
    end;
  end;
end;
function StrTrimCharLeft(const S: DWString; C: DWChar): DWString;
var
  I, L: SizeInt;
begin
  I := 1;
  L := Length(S);
  while (I <= L) and (PDWString(@S[I])^ = C) do
    Inc(I);
  Result := Copy(S, I, L - I + 1);
end;
function StrTrimCharsLeft(const S: DWString; const Chars: TSysCharSet): DWString;
var
  I, L: SizeInt;
begin
  I := 1;
  L := Length(S);
  while (I <= L) and (S[I] in Chars) do
    Inc(I);
  Result := Copy(S, I, L - I + 1);
end;
function StrTrimCharsRight(const S: DWString; const Chars: TSysCharSet): DWString;
var
  I: SizeInt;
begin
  I := Length(S);
  while (I >= 1) and (S[I] in Chars) do
    Dec(I);
  Result := Copy(S, 1, I);
end;
function StrTrimCharRight(const S: DWString; C: DWChar): DWString;
var
  I: SizeInt;
begin
  I := Length(S);
  while (I >= 1) and (PDWString(@S[I])^ = C) do
    Dec(I);
  Result := Copy(S, 1, I);
end;
function StrTrimQuotes(const S: DWString): DWString;
var
  First, Last: DWChar;
  L: SizeInt;
begin
  L := Length(S);
  if L > 1 then
  begin
    PDWString(@First)^ := S[1];
    PDWString(@Last)^ := S[L];
    if (First = Last) and ((First = AnsiSingleQuote) or (First = AnsiDoubleQuote)) then
      Result := Copy(S, 2, L - 2)
    else
      Result := S;
  end
  else
    Result := S;
end;
function StrTrimQuotes(const S: DWString; QuoteChar: DWChar): DWString;
var
  First, Last: DWChar;
  L: SizeInt;
begin
  L := Length(S);
  if L > 1 then
  begin
    PDWString(@First)^ := S[1];
    PDWString(@Last)^ := S[L];
    if (First = Last) and (First = QuoteChar) then
      Result := Copy(S, 2, L - 2)
    else
      Result := S;
  end
  else
    Result := S;
end;
procedure StrDecRef(var S: DWString);
var
  P: PAnsiStrRec;
begin
  P := Pointer(S);
  if P <> nil then
  begin
    Dec(P);
    case P^.RefCount of
      -1, 0:
        { nothing } ;
      1:
        begin
          Finalize(S);
          Pointer(S) := nil;
        end;
//    else
//      LockedDec(P^.RefCount);
    end;
  end;
end;
function StrLength(const S: DWString): Longint;
var
  P: PAnsiStrRec;
begin
  Result := 0;
  P := Pointer(S);
  if P <> nil then
  begin
    Dec(P);
    Result := P^.Length and (not $80000000 shr 1);
  end;
end;
function StrRefCount(const S: DWString): Longint;
var
  P: PAnsiStrRec;
begin
  Result := 0;
  P := Pointer(S);
  if P <> nil then
  begin
    Dec(P);
    Result := P^.RefCount;
  end;
end;
procedure StrResetLength(var S: DWString);
var
  I: SizeInt;
begin
  for I := 0 to Length(S) - 1 do
    if S[I + 1] = #0 then
    begin
      SetLength(S, I);
      Exit;
    end;
end;
//=== String Search and Replace Routines =====================================
function StrCharCount(const S: DWString; C: DWChar): SizeInt;
var
  I: SizeInt;
begin
  Result := 0;
  for I := 1 to Length(S) do
    if PDWString(@S[I])^ = C then
      Inc(Result);
end;
function StrCharsCount(const S: DWString; Chars: TSysCharSet): SizeInt;
var
  I: SizeInt;
begin
  Result := 0;
  for I := 1 to Length(S) do
    if S[I] in Chars then
      Inc(Result);
end;
function StrStrCount(const S, SubS: DWString): SizeInt;
var
  I: SizeInt;
begin
  Result := 0;
  if (Length(SubS) > Length(S)) or (Length(SubS) = 0) or (Length(S) = 0) then
    Exit;
  if Length(SubS) = 1 then
  begin
    Result := StrCharCount(S, SubS[1]);
    Exit;
  end;
  I := StrSearch(SubS, S, 1);
  if I > 0 then
    Inc(Result);
  while (I > 0) and (Length(S) > I + Length(SubS)) do
  begin
    I := StrSearch(SubS, S, I + 1);
    if I > 0 then
      Inc(Result);
  end;
end;
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
function StrCompareRangeEx(const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean): SizeInt;
var
  Len1, Len2: SizeInt;
  I: SizeInt;
  C1, C2: DWChar;
begin
  if Pointer(S1) = Pointer(S2) then
  begin
    if (Count <= 0) and (S1 <> '') then
      Result := -2 // no work
    else
      Result := 0;
  end
  else
  if (S1 = '') or (S2 = '') then
    Result := -1 // null string
  else
  if Count <= 0 then
    Result := -2 // no work
  else
  begin
    Len1 := Length(S1);
    Len2 := Length(S2);
    if (Index - 1) + Count > Len1 then
      Result := -2
    else
    begin
      if (Index - 1) + Count > Len2 then // strange behaviour, but the assembler code does it
        Count := Len2 - (Index - 1);
      if CaseSensitive then
      begin
        for I := 0 to Count - 1 do
        begin
          PDWString(@C1)^ := S1[Index + I];
          PDWString(@C2)^ := S2[Index + I];
          if C1 <> C2 then
          begin
            Result := Ord(C1) - Ord(C2);
            Exit;
          end;
        end;
      end
      else
      begin
        for I := 0 to Count - 1 do
        begin
          PDWString(@C1)^ := S1[Index + I];
          PDWString(@C2)^ := S2[Index + I];
          if C1 <> C2 then
          begin
            C1 := CharLower(C1);
            C2 := CharLower(C2);
            if C1 <> C2 then
            begin
              Result := Ord(C1) - Ord(C2);
              Exit;
            end;
          end;
        end;
      end;
      Result := 0;
    end;
  end;
end;
function StrCompare(const S1, S2: DWString; CaseSensitive: Boolean): SizeInt;
var
  Len1, Len2: SizeInt;
begin
  if Pointer(S1) = Pointer(S2) then
    Result := 0
  else
  begin
    Len1 := Length(S1);
    Len2 := Length(S2);
    Result := Len1 - Len2;
    if Result = 0 then
      Result := StrCompareRangeEx(S1, S2, 1, Len1, CaseSensitive);
  end;
end;
function StrCompareRange(const S1, S2: DWString; Index, Count: SizeInt; CaseSensitive: Boolean): SizeInt;
begin
  Result := StrCompareRangeEx(S1, S2, Index, Count, CaseSensitive);
end;
function StrRepeatChar(C: DWChar; Count: SizeInt): DWString;
begin
  SetLength(Result, Count);
  if Count > 0 then
    FillChar(Result[1], Count, C);
end;
function StrFind(const Substr, S: DWString; const Index: SizeInt): SizeInt;
var
  pos: SizeInt;
begin
  if (SubStr <> '') and (S <> '') then
  begin
    pos := StrIPos(Substr, Copy(S, Index, Length(S) - Index + 1));
    if pos = 0 then
      Result := 0
    else
      Result := Index + Pos - 1;
  end
  else
    Result := 0;
end;
function StrHasPrefix(const S: DWString; const Prefixes: array of DWString): Boolean;
begin
  Result := StrPrefixIndex(S, Prefixes) > -1;
end;
function StrHasSuffix(const S: DWString; const Suffixes: array of DWString): Boolean;
begin
  Result := StrSuffixIndex(S, Suffixes) > -1;
end;
function StrIHasPrefix(const S: DWString; const Prefixes: array of DWString): Boolean;
begin
  Result := StrIPrefixIndex(S, Prefixes) > -1;
end;
function StrIHasSuffix(const S: DWString; const Suffixes: array of DWString): Boolean;
begin
  Result := StrISuffixIndex(S, Suffixes) > -1;
end;
function StrIndex(const S: DWString; const List: array of DWString; CaseSensitive: Boolean): SizeInt;
var
  I: SizeInt;
begin
  Result := -1;
  for I := Low(List) to High(List) do
  begin
    if StrCompare(S, List[I], CaseSensitive) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;
function StrILastPos(const SubStr, S: DWString): SizeInt;
begin
  Result := StrLastPos(StrUpper(SubStr), StrUpper(S));
end;
function StrIPos(const SubStr, S: DWString): SizeInt;
begin
  Result := Pos(StrUpper(SubStr), StrUpper(S));
end;
function StrIPrefixIndex(const S: DWString; const Prefixes: array of DWString): SizeInt;
var
  I: SizeInt;
  Test: DWString;
begin
  Result := -1;
  for I := Low(Prefixes) to High(Prefixes) do
  begin
    Test := StrLeft(S, Length(Prefixes[I]));
    if CompareText(Test, Prefixes[I]) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;
function StrIsOneOf(const S: DWString; const List: array of DWString): Boolean;
begin
  Result := StrIndex(S, List) > -1;
end;
function StrISuffixIndex(const S: DWString; const Suffixes: array of DWString): SizeInt;
var
  I: SizeInt;
  Test: DWString;
begin
  Result := -1;
  for I := Low(Suffixes) to High(Suffixes) do
  begin
    Test := StrRight(S, Length(Suffixes[I]));
    if CompareText(Test, Suffixes[I]) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;
// IMPORTANT NOTE: The StrMatch function does currently not work with the Asterix (*)
// (*) acts like (?)
function StrMatch(const Substr, S: DWString; Index: SizeInt): SizeInt;
var
  SI, SubI, SLen, SubLen: SizeInt;
  SubC: DWChar;
begin
  SLen := Length(S);
  SubLen := Length(Substr);
  Result := 0;
  if (Index > SLen) or (SubLen = 0) then
    Exit;
  while Index <= SLen do
  begin
    SubI := 1;
    SI := Index;
    while (SI <= SLen) and (SubI <= SubLen) do
    begin
      PDWString(@SubC)^ := Substr[SubI];
      if (SubC = '*') or (SubC = '?') or (PDWString(@SubC)^ = S[SI]) then
      begin
        Inc(SI);
        Inc(SubI);
      end
      else
        Break;
    end;
    if SubI > SubLen then
    begin
      Result := Index;
      Break;
    end;
    Inc(Index);
  end;
end;

function StrNPos(const S, SubStr: DWString; N: SizeInt): SizeInt;
var
  I, P: SizeInt;
begin
  if N < 1 then
  begin
    Result := 0;
    Exit;
  end;
  Result := StrSearch(SubStr, S, 1);
  I := 1;
  while I < N do
  begin
    P := StrSearch(SubStr, S, Result + 1);
    if P = 0 then
    begin
      Result := 0;
      Break;
    end
    else
    begin
      Result := P;
      Inc(I);
    end;
  end;
end;
function StrNIPos(const S, SubStr: DWString; N: SizeInt): SizeInt;
var
  I, P: SizeInt;
begin
  if N < 1 then
  begin
    Result := 0;
    Exit;
  end;
  Result := StrFind(SubStr, S, 1);
  I := 1;
  while I < N do
  begin
    P := StrFind(SubStr, S, Result + 1);
    if P = 0 then
    begin
      Result := 0;
      Break;
    end
    else
    begin
      Result := P;
      Inc(I);
    end;
  end;
end;
function StrPrefixIndex(const S: DWString; const Prefixes: array of DWString): SizeInt;
var
  I: SizeInt;
  Test: DWString;
begin
  Result := -1;
  for I := Low(Prefixes) to High(Prefixes) do
  begin
    Test := StrLeft(S, Length(Prefixes[I]));
    if CompareStr(Test, Prefixes[I]) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;
function StrSuffixIndex(const S: DWString; const Suffixes: array of DWString): SizeInt;
var
  I: SizeInt;
  Test: DWString;
begin
  Result := -1;
  for I := Low(Suffixes) to High(Suffixes) do
  begin
    Test := StrRight(S, Length(Suffixes[I]));
    if CompareStr(Test, Suffixes[I]) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;
//=== String Extraction ======================================================
function StrAfter(const SubStr, S: DWString): DWString;
var
  P: SizeInt;
begin
  P := StrFind(SubStr, S, 1); // StrFind is case-insensitive pos
  if P <= 0 then
    Result := ''           // substr not found -> nothing after it
  else
    Result := StrRestOf(S, P + Length(SubStr));
end;
function StrBefore(const SubStr, S: DWString): DWString;
var
  P: SizeInt;
begin
  P := StrFind(SubStr, S, 1);
  if P <= 0 then
    Result := S
  else
    Result := StrLeft(S, P - 1);
end;
function StrSplit(const SubStr, S: DWString;var Left, Right : DWString): boolean;
var
  P: SizeInt;
begin
  P := StrFind(SubStr, S, 1);
  Result:= p > 0;
  if Result then
  begin
    Left := StrLeft(S, P - 1);
    Right := StrRestOf(S, P + Length(SubStr));
  end
  else
  begin
    Left := '';
    Right := '';
  end;
end;
function StrBetween(const S: DWString; const Start, Stop: DWChar): DWString;
var
  PosStart, PosEnd: SizeInt;
  L: SizeInt;
begin
  PosStart := Pos(Start, S);
  PosEnd := StrSearch(Stop, S, PosStart + 1);  // PosEnd has to be after PosStart.
  if (PosStart > 0) and (PosEnd > PosStart) then
  begin
    L := PosEnd - PosStart;
    Result := Copy(S, PosStart + 1, L - 1);
  end
  else
    Result := '';
end;
function StrChopRight(const S: DWString; N: SizeInt): DWString;
begin
  Result := Copy(S, 1, Length(S) - N);
end;
function StrLeft(const S: DWString; Count: SizeInt): DWString;
begin
  Result := Copy(S, 1, Count);
end;
function StrMid(const S: DWString; Start, Count: SizeInt): DWString;
begin
  Result := Copy(S, Start, Count);
end;
function StrRestOf(const S: DWString; N: SizeInt): DWString;
begin
  Result := Copy(S, N, (Length(S) - N + 1));
end;
function StrRight(const S: DWString; Count: SizeInt): DWString;
begin
  Result := Copy(S, Length(S) - Count + 1, Count);
end;

function CharIsDelete(const C: DWChar): Boolean;
begin
  Result := (C = #8);
end;

function CharIsReturn(const C: DWChar): Boolean;
begin
  Result := (C = AnsiLineFeed) or (C = AnsiCarriageReturn);
end;
function CharIsValidIdentifierLetter(const C: DWChar): Boolean;
begin
  case C of
    '0'..'9', 'A'..'Z', 'a'..'z', '_':
      Result := True;
  else
    Result := False;
  end;
end;
function CharIsWildcard(const C: DWChar): Boolean;
begin
  case C of
    '*', '?':
      Result := True;
  else
    Result := False;
  end;
end;
function CharType(const C: DWChar): Word;
begin
  Result := DWCharTypes[C];
end;
function PCharVectorCount(Source: PAnsiCharVector): SizeInt;
begin
  Result := 0;
  if Source <> nil then
    while Source^ <> nil do
  begin
    Inc(Source);
    Inc(Result);
  end;
end;
//=== Character Transformation Routines ======================================
function CharHex(const C: DWChar): Byte;
begin
  case C of
    '0'..'9':
      Result := Ord(C) - Ord('0');
    'a'..'f':
      Result := Ord(C) - Ord('a') + 10;
    'A'..'F':
      Result := Ord(C) - Ord('A') + 10;
  else
    Result := $FF;
  end;
end;
function CharLower(const C: DWChar): DWChar;
begin
  Result := AnsiCaseMap[Ord(C) + AnsiLoOffset];
end;
function CharToggleCase(const C: DWChar): DWChar;
begin
  Result := AnsiCaseMap[Ord(C) + AnsiReOffset];
end;
function CharUpper(const C: DWChar): DWChar;
begin
  Result := AnsiCaseMap[Ord(C) + AnsiUpOffset];
end;
//=== Character Search and Replace ===========================================
function CharLastPos(const S: DWString; const C: DWChar; const Index: SizeInt): SizeInt;
begin
  if (Index > 0) and (Index <= Length(S)) then
    for Result := Length(S) downto Index do
      if PDWString(@S[Result])^ = C then
        Exit;
  Result := 0;
end;
function CharPos(const S: DWString; const C: DWChar; const Index: SizeInt): SizeInt;
begin
  if (Index > 0) and (Index <= Length(S)) then
    for Result := Index to Length(S) do
      if PDWString(@S[Result])^ = C then
        Exit;
  Result := 0;
end;
function CharIPos(const S: DWString; C: DWChar; const Index: SizeInt): SizeInt;
begin
  if (Index > 0) and (Index <= Length(S)) then
  begin
    C := CharUpper(C);
    for Result := Index to Length(S) do
      if AnsiCaseMap[Ord(S[Result]) + AnsiUpOffset] = C then
        Exit;
  end;
  Result := 0;
end;
procedure AllocateMultiSz(var Dest: PAnsiMultiSz; Len: SizeInt);
begin
  if Len > 0 then
    GetMem(Dest, Len * SizeOf(DWChar))
  else
    Dest := nil;
end;
procedure FreeMultiSz(var Dest: PAnsiMultiSz);
begin
  if Dest <> nil then
    FreeMem(Dest);
  Dest := nil;
end;
//=== TJclAnsiStrings Manipulation ===============================================
procedure StrToStrings(S, Sep: DWString; const List: TJclAnsiStrings; const AllowEmptyString: Boolean = True);
var
  I, L: SizeInt;
  Left: DWString;
begin
  Assert(List <> nil);
  List.BeginUpdate;
  try
    List.Clear;
    L := Length(Sep);
    I := Pos(Sep, S);
    while I > 0 do
    begin
      Left := StrLeft(S, I - 1);
      if (Left <> '') or AllowEmptyString then
        List.Add(Left);
      Delete(S, 1, I + L - 1);
      I := Pos(Sep, S);
    end;
    if (S <> '') or AllowEmptyString then
      List.Add(S);  // Ignore empty strings at the end (only if AllowEmptyString = False).
  finally
    List.EndUpdate;
  end;
end;
procedure StrIToStrings(S, Sep: DWString; const List: TJclAnsiStrings; const AllowEmptyString: Boolean = True);
var
  I, L: SizeInt;
  LowerCaseStr: DWString;
  Left: DWString;
begin
  Assert(List <> nil);
  LowerCaseStr := StrLower(S);
  Sep := StrLower(Sep);
  L := Length(Sep);
  I := Pos(Sep, LowerCaseStr);
  List.BeginUpdate;
  try
    List.Clear;
    while I > 0 do
    begin
      Left := StrLeft(S, I - 1);
      if (Left <> '') or AllowEmptyString then
        List.Add(Left);
      Delete(S, 1, I + L - 1);
      Delete(LowerCaseStr, 1, I + L - 1);
      I := Pos(Sep, LowerCaseStr);
    end;
    if (S <> '') or AllowEmptyString then
      List.Add(S);  // Ignore empty strings at the end (only if AllowEmptyString = False).
  finally
    List.EndUpdate;
  end;
end;
function StringsToStr(const List: TJclAnsiStrings; const Sep: DWString;
  const AllowEmptyString: Boolean): DWString;
var
  I, L: SizeInt;
begin
  Result := '';
  for I := 0 to List.Count - 1 do
  begin
    if (List[I] <> '') or AllowEmptyString then
    begin
      // don't combine these into one addition, somehow it hurts performance
      Result := Result + List[I];
      Result := Result + Sep;
    end;
  end;
  // remove terminating separator
  if List.Count <> 0 then
  begin
    L := Length(Sep);
    Delete(Result, Length(Result) - L + 1, L);
  end;
end;
procedure TrimStrings(const List: TJclAnsiStrings; DeleteIfEmpty: Boolean);
var
  I: SizeInt;
begin
  Assert(List <> nil);
  List.BeginUpdate;
  try
    for I := List.Count - 1 downto 0 do
    begin
      List[I] := Trim(List[I]);
      if (List[I] = '') and DeleteIfEmpty then
        List.Delete(I);
    end;
  finally
    List.EndUpdate;
  end;
end;
procedure TrimStringsRight(const List: TJclAnsiStrings; DeleteIfEmpty: Boolean);
var
  I: SizeInt;
begin
  Assert(List <> nil);
  List.BeginUpdate;
  try
    for I := List.Count - 1 downto 0 do
    begin
      List[I] := TrimRight(List[I]);
      if (List[I] = '') and DeleteIfEmpty then
        List.Delete(I);
    end;
  finally
    List.EndUpdate;
  end;
end;
procedure TrimStringsLeft(const List: TJclAnsiStrings; DeleteIfEmpty: Boolean);
var
  I: SizeInt;
begin
  Assert(List <> nil);
  List.BeginUpdate;
  try
    for I := List.Count - 1 downto 0 do
    begin
      List[I] := TrimLeft(List[I]);
      if (List[I] = '') and DeleteIfEmpty then
        List.Delete(I);
    end;
  finally
    List.EndUpdate;
  end;
end;
function AddStringToStrings(const S: DWString; Strings: TJclAnsiStrings; const Unique: Boolean): Boolean;
begin
  Assert(Strings <> nil);
  Result := Unique and (Strings.IndexOf(S) <> -1);
  if not Result then
    Result := Strings.Add(S) > -1;
end;
//=== Miscellaneous ==========================================================
function FileToString(const FileName: TFileName): DWString;
var
  FS: TFileStream;
  Len: SizeInt;
begin
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Len := FS.Size;
    SetLength(Result, Len);
    if Len > 0 then
    FS.ReadBuffer(Result[1], Len);
  finally
    FS.Free;
  end;
end;
procedure StringToFile(const FileName: TFileName; const Contents: DWString; Append: Boolean);
var
  FS: TFileStream;
  Len: SizeInt;
begin
  if Append and FileExists(FileName) then
    FS := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite)
  else
    FS := TFileStream.Create(FileName, fmCreate);
  try
    if Append then
      FS.Seek(0, soEnd);  // faster than .Position := .Size
    Len := Length(Contents);
    if Len > 0 then
    FS.WriteBuffer(Contents[1], Len);
  finally
    FS.Free;
  end;
end;
function StrToken(var S: DWString; Separator: DWChar): DWString;
var
  I: SizeInt;
begin
  I := Pos(Separator, S);
  if I <> 0 then
  begin
    Result := Copy(S, 1, I - 1);
    Delete(S, 1, I);
  end
  else
  begin
    Result := S;
    S := '';
  end;
end;

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

procedure StrNormIndex(const StrLen: SizeInt; var Index: SizeInt; var Count: SizeInt); overload;
begin
  Index := Max(1, Min(Index, StrLen + 1));
  Count := Max(0, Min(Count, StrLen + 1 - Index));
end;
function ArrayOf(List: TJclAnsiStrings): TDynStringArray;
var
  I: SizeInt;
begin
  if List <> nil then
  begin
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := string(List[I]);
  end
  else
    Result := nil;
end;

initialization
  LoadCharTypes;  // this table first
End.
