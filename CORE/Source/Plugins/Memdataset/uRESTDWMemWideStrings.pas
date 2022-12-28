unit uRESTDWMemWideStrings;

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
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  {$IFDEF HAS_UNITSCOPE}
  System.Classes, System.SysUtils,
  {$ELSE ~HAS_UNITSCOPE}
  Classes, SysUtils,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase;
// Exceptions
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
    DWChar       = Char;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  DWString     = AnsiString;
  DWWideString = WideString;
  DWChar       = Char;
 {$ENDIF}
  PDWChar      = ^DWChar;
  EJclWideStringError = class(EJclError);
const
  // definitions of often used characters:
  // Note: Use them only for tests of a certain character not to determine character
  //       classes (like white spaces) as in Unicode are often many code points defined
  //       being in a certain class. Hence your best option is to use the various
  //       UnicodeIs* functions.
  WideNull               = DWChar(#0);
  WideTabulator          = DWChar(#9);
  WideSpace              = DWChar(#32);
  // logical line breaks
  WideLF                 = DWChar(#10);
  WideLineFeed           = DWChar(#10);
  WideVerticalTab        = DWChar(#11);
  WideFormFeed           = DWChar(#12);
  WideCR                 = DWChar(#13);
  WideCarriageReturn     = DWChar(#13);
  WideCRLF               = DWWideString(#13#10);
  WideLineSeparator      = DWChar($2028);
  WideParagraphSeparator = DWChar($2029);
  {$IFDEF MSWINDOWS}
  WideLineBreak = WideCRLF;
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  WideLineBreak = WideLineFeed;
  {$ENDIF UNIX}
  BOM_LSB_FIRST = DWChar($FEFF);
  BOM_MSB_FIRST = DWChar($FFFE);
type
  {$IFDEF SUPPORTS_UNICODE}
  TJclWideStrings = {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}Classes.TStrings;
  TJclWideStringList = {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}Classes.TStringList;
  {$ELSE ~SUPPORTS_UNICODE}
  TWideFileOptionsType =
   (
    foAnsiFile,  // loads/writes an ANSI file
    foUnicodeLB  // reads/writes BOM_LSB_FIRST/BOM_MSB_FIRST
   );
  TWideFileOptions = set of TWideFileOptionsType;
  TSearchFlag = (
    sfCaseSensitive,    // match letter case
    sfIgnoreNonSpacing, // ignore non-spacing characters in search
    sfSpaceCompress,    // handle several consecutive white spaces as one white space
                        // (this applies to the pattern as well as the search text)
    sfWholeWordOnly     // match only text at end/start and/or surrounded by white spaces
  );
  TSearchFlags = set of TSearchFlag;
  TJclWideStrings = class;
  TJclWideStringList = class;
  TJclWideStringListSortCompare = function(List: TJclWideStringList; Index1, Index2: Integer): Integer;
  TJclWideStrings = class(TPersistent)
  private
    FDelimiter: DWChar;
    FQuoteChar: DWChar;
    FNameValueSeparator: DWChar;
    FLineSeparator: DWWideString;
    FUpdateCount: Integer;
    function GetCommaText: DWWideString;
    function GetDelimitedText: DWWideString;
    function GetName(Index: Integer): DWWideString;
    function GetValue(const Name: DWWideString): DWWideString;
    procedure ReadData(Reader: TReader);
    procedure SetCommaText(const Value: DWWideString);
    procedure SetDelimitedText(const Value: DWWideString);
    procedure SetValue(const Name, Value: DWWideString);
    procedure WriteData(Writer: TWriter);
    function GetValueFromIndex(Index: Integer): DWWideString;
    procedure SetValueFromIndex(Index: Integer; const Value: DWWideString);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function ExtractName(const S: DWWideString): DWWideString;
    function GetP(Index: Integer): PWideString; virtual; abstract;
    function Get(Index: Integer): DWWideString;
    function GetCapacity: Integer; virtual;
    function GetCount: Integer; virtual; abstract;
    function GetObject(Index: Integer): TObject; virtual;
    function GetTextStr: DWWideString; virtual;
    procedure Put(Index: Integer; const S: DWWideString); virtual; abstract;
    procedure PutObject(Index: Integer; AObject: TObject); virtual; abstract;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure SetTextStr(const Value: DWWideString); virtual;
    procedure SetUpdateState(Updating: Boolean); virtual;
    property UpdateCount: Integer read FUpdateCount;
    function CompareStrings(const S1, S2: DWWideString): Integer; virtual;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    function Add(const S: DWWideString): Integer; virtual;
    function AddObject(const S: DWWideString; AObject: TObject): Integer; virtual;
    procedure Append(const S: DWWideString);
    procedure AddStrings(Strings: TJclWideStrings); overload; virtual;
    procedure AddStrings(Strings: TStrings); overload; virtual;
    procedure Assign(Source: TPersistent); override;
    function CreateAnsiStringList: TStrings;
    procedure AddStringsTo(Dest: TStrings); virtual;
    procedure BeginUpdate;
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure EndUpdate;
    function Equals(Strings: TJclWideStrings): Boolean; {$IFDEF RTL200_UP}reintroduce; {$ENDIF RTL200_UP}overload;
    function Equals(Strings: TStrings): Boolean; {$IFDEF RTL200_UP}reintroduce; {$ENDIF RTL200_UP}overload;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function GetText: PDWChar; virtual;
    function IndexOf(const S: DWWideString): Integer; virtual;
    function IndexOfName(const Name: DWWideString): Integer; virtual;
    function IndexOfObject(AObject: TObject): Integer; virtual;
    procedure Insert(Index: Integer; const S: DWWideString); virtual;
    procedure InsertObject(Index: Integer; const S: DWWideString;
      AObject: TObject); virtual;
    procedure LoadFromFile(const FileName: TFileName;
      WideFileOptions: TWideFileOptions = []); virtual;
    procedure LoadFromStream(Stream: TStream;
      WideFileOptions: TWideFileOptions = []); virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure SaveToFile(const FileName: TFileName;
      WideFileOptions: TWideFileOptions = []); virtual;
    procedure SaveToStream(Stream: TStream;
      WideFileOptions: TWideFileOptions = []); virtual;
    procedure SetText(Text: PDWChar); virtual;
    function GetDelimitedTextEx(ADelimiter, AQuoteChar: DWChar): DWWideString;
    procedure SetDelimitedTextEx(ADelimiter, AQuoteChar: DWChar; const Value: DWWideString);
    property Capacity: Integer read GetCapacity write SetCapacity;
    property CommaText: DWWideString read GetCommaText write SetCommaText;
    property Count: Integer read GetCount;
    property Delimiter: DWChar read FDelimiter write FDelimiter;
    property DelimitedText: DWWideString read GetDelimitedText write SetDelimitedText;
    property Names[Index: Integer]: DWWideString read GetName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property QuoteChar: DWChar read FQuoteChar write FQuoteChar;
    property Values[const Name: DWWideString]: DWWideString read GetValue write SetValue;
    property ValueFromIndex[Index: Integer]: DWWideString read GetValueFromIndex write SetValueFromIndex;
    property NameValueSeparator: DWChar read FNameValueSeparator write FNameValueSeparator;
    property LineSeparator: DWWideString read FLineSeparator write FLineSeparator;
    property PStrings[Index: Integer]: PWideString read GetP;
    property Strings[Index: Integer]: DWWideString read Get write Put; default;
    property Text: DWWideString read GetTextStr write SetTextStr;
  end;
  // do not replace by JclUnicode.TWideStringList (speed and size issue)
  PWStringItem = ^TWStringItem;
  TWStringItem = record
    FString: DWWideString;
    FObject: TObject;
  end;
  TJclWideStringList = class(TJclWideStrings)
  private
    FList: TList;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure SetSorted(Value: Boolean);
    procedure SetCaseSensitive(const Value: Boolean);
  protected
    function GetItem(Index: Integer): PWStringItem;
    procedure Changed; virtual;
    procedure Changing; virtual;
    function GetP(Index: Integer): PWideString; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const Value: DWWideString); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
    function CompareStrings(const S1, S2: DWWideString): Integer; override;
  public
    constructor Create;
    destructor Destroy; override;
    function AddObject(const S: DWWideString; AObject: TObject): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const S: DWWideString; var Index: Integer): Boolean; virtual;
    // Find() also works with unsorted lists
    function IndexOf(const S: DWWideString): Integer; override;
    procedure InsertObject(Index: Integer; const S: DWWideString;
      AObject: TObject); override;
    procedure Sort; virtual;
    procedure CustomSort(Compare: TJclWideStringListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  end;
  {$ENDIF ~SUPPORTS_UNICODE}
  TWideStringList = TJclWideStringList;
  TWideStrings = TJclWideStrings;
  TJclUnicodeStringList = TJclWideStringList;
  TJclUnicodeStrings = TJclWideStrings;
  // OF deprecated?
  TWStringList = TJclWideStringList;
  TWStrings = TJclWideStrings;
// DWChar functions
function CharToWideChar(Ch: DWChar): DWChar;
function DWCharToChar(Ch: DWChar): DWChar;
// PDWChar functions
procedure MoveWideChar(const Source; var Dest; Count: SizeInt);
function StrEndW(const Str: PDWChar): PDWChar;
function StrMoveW(Dest: PDWChar; const Source: PDWChar; Count: SizeInt): PDWChar;
function StrCopyW(Dest: PDWChar; const Source: PDWChar): PDWChar;
function StrECopyW(Dest: PDWChar; const Source: PDWChar): PDWChar;
function StrLCopyW(Dest: PDWChar; const Source: PDWChar; MaxLen: SizeInt): PDWChar;
function StrPCopyWW(Dest: PDWChar; const Source: DWWideString): PDWChar;
function StrPLCopyWW(Dest: PDWChar; const Source: DWWideString; MaxLen: SizeInt): PDWChar;
function StrCatW(Dest: PDWChar; const Source: PDWChar): PDWChar;
function StrLCatW(Dest: PDWChar; const Source: PDWChar; MaxLen: SizeInt): PDWChar;
function StrScanW(const Str: PDWChar; Ch: DWChar): PDWChar; overload;
function StrScanW(Str: PDWChar; Chr: DWChar; StrLen: SizeInt): PDWChar; overload;
function StrRScanW(const Str: PDWChar; Chr: DWChar): PDWChar;
function StrAllocW(WideSize: SizeInt): PDWChar;
function StrBufSizeW(const Str: PDWChar): SizeInt;
procedure StrDisposeW(Str: PDWChar);
procedure StrDisposeAndNilW(var Str: PDWChar);
// DWWideString functions
function WideCompareText(const S1, S2: DWWideString): SizeInt;
function WideUpperCase(const S: DWWideString): DWWideString;
function WideLowerCase(const S: DWWideString): DWWideString;
function TrimW(const S: DWWideString): DWWideString;
function TrimLeftW(const S: DWWideString): DWWideString;
function TrimRightW(const S: DWWideString): DWWideString;
function TrimLeftLengthW(const S: DWWideString): SizeInt;
function TrimRightLengthW(const S: DWWideString): SizeInt;
// MultiSz Routines
type
  PWideMultiSz = PDWChar;
procedure AllocateMultiSz(var Dest: PWideMultiSz; Len: SizeInt);
procedure FreeMultiSz(var Dest: PWideMultiSz);
implementation
uses
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF HAS_UNIT_RTLCONSTS}
  System.RTLConsts,
  {$ENDIF HAS_UNIT_RTLCONSTS}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.Math,
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF HAS_UNIT_RTLCONSTS}
  RTLConsts,
  {$ENDIF HAS_UNIT_RTLCONSTS}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  Math,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemUnicode,
  uRESTDWMemResources;
procedure SwapWordByteOrder(P: PDWChar; Len: SizeInt);
begin
  while Len > 0 do
  begin
    Dec(Len);
    P^ := DWChar((Word(P^) shr 8) or (Word(P^) shl 8));
    Inc(P);
  end;
end;
//=== DWChar functions =====================================================
function CharToWideChar(Ch: DWChar): DWChar;
var
  WS: DWWideString;
begin
  WS := DWChar(Ch);
  Result := WS[1];
end;
function DWCharToChar(Ch: DWChar): DWChar;
var
  S: DWWideString;
begin
  S := Ch;
  Result := DWChar(S[1]);
end;
//=== PDWChar functions ====================================================
procedure MoveWideChar(const Source; var Dest; Count: SizeInt);
begin
  Move(Source, Dest, Count * SizeOf(WideChar));
end;
function StrAllocW(WideSize: SizeInt): PDWChar;
begin
  WideSize := SizeOf(WideChar) * WideSize + SizeOf(SizeInt);
  Result := AllocMem(WideSize);
  SizeInt(Pointer(Result)^) := WideSize;
  Inc(Result, SizeOf(SizeInt) div SizeOf(WideChar));
end;
procedure StrDisposeW(Str: PDWChar);
// releases a string allocated with StrNewW or StrAllocW
begin
  if Str <> nil then
  begin
    Dec(Str, SizeOf(SizeInt) div SizeOf(WideChar));
    FreeMem(Str);
  end;
end;
procedure StrDisposeAndNilW(var Str: PDWChar);
var
  Buff: PDWChar;
begin
  Buff := Str;
  Str := nil;
  StrDisposeW(Buff);
end;
const
  // data used to bring UTF-16 coded strings into correct UTF-32 order for correct comparation
  UTF16Fixup: array [0..31] of Word = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    $2000, $F800, $F800, $F800, $F800
  );
function StrLCompW(const Str1, Str2: PDWChar; MaxLen: SizeInt): SizeInt;
// compares strings up to MaxLen code points
// see also StrCompW
var
  S1, S2: PDWChar;
  C1, C2: Word;
begin
  if MaxLen > 0 then
  begin
    S1 := Str1;
    S2 := Str2;
    repeat
      C1 := Word(S1^);
      C1 := Word(C1 or UTF16Fixup[C1 shr 11]);
      C2 := Word(S2^);
      C2 := Word(C2 or UTF16Fixup[C2 shr 11]);
      // now C1 and C2 are in UTF-32-compatible order
      { TODO : surrogates take up 2 words and are counted twice here, count them only once }
      Result := SizeInt(C1) - SizeInt(C2);
      Dec(MaxLen);
      if(Result <> 0) or (C1 = 0) or (C2 = 0) or (MaxLen = 0) then
        Break;
      Inc(S1);
      Inc(S2);
    until False;
  end
  else
    Result := 0;
end;
function StrScanW(const Str: PDWChar; Ch: DWChar): PDWChar;
begin
  Result := Str;
  if Result <> nil then
  begin
    while (Result^ <> #0) and (Result^ <> Ch) do
      Inc(Result);
    if (Result^ = #0) and (Ch <> #0) then
      Result := nil;
  end;
end;
function StrEndW(const Str: PDWChar): PDWChar;
begin
  Result := Str;
  if Result <> nil then
    while Result^ <> #0 do
      Inc(Result);
end;
function StrCopyW(Dest: PDWChar; const Source: PDWChar): PDWChar;
var
  Src: PDWChar;
begin
  Result := Dest;
  if Dest <> nil then
  begin
    Src := Source;
    if Src <> nil then
      while Src^ <> #0 do
      begin
        Dest^ := Src^;
        Inc(Src);
        Inc(Dest);
      end;
    Dest^ := #0;
  end;
end;
function StrECopyW(Dest: PDWChar; const Source: PDWChar): PDWChar;
var
  Src: PDWChar;
begin
  if Dest <> nil then
  begin
    Src := Source;
    if Src <> nil then
      while Src^ <> #0 do
      begin
        Dest^ := Src^;
        Inc(Src);
        Inc(Dest);
      end;
    Dest^ := #0;
  end;
  Result := Dest;
end;
function StrLCopyW(Dest: PDWChar; const Source: PDWChar; MaxLen: SizeInt): PDWChar;
var
  Src: PDWChar;
begin
  Result := Dest;
  if (Dest <> nil) and (MaxLen > 0) then
  begin
    Src := Source;
    if Src <> nil then
      while (MaxLen > 0) and (Src^ <> #0) do
      begin
        Dest^ := Src^;
        Inc(Src);
        Inc(Dest);
        Dec(MaxLen);
      end;
    Dest^ := #0;
  end;
end;
function StrCatW(Dest: PDWChar; const Source: PDWChar): PDWChar;
begin
  Result := Dest;
  StrCopyW(StrEndW(Dest), Source);
end;
function StrLCatW(Dest: PDWChar; const Source: PDWChar; MaxLen: SizeInt): PDWChar;
begin
  Result := Dest;
  StrLCopyW(StrEndW(Dest), Source, MaxLen);
end;
function StrMoveW(Dest: PDWChar; const Source: PDWChar; Count: SizeInt): PDWChar;
begin
  Result := Dest;
  if Count > 0 then
    Move(Source^, Dest^, Count * SizeOf(WideChar));
end;
function StrPCopyWW(Dest: PDWChar; const Source: DWWideString): PDWChar;
begin
  Result := StrLCopyW(Dest, PDWChar(Source), Length(Source));
end;
function StrPLCopyWW(Dest: PDWChar; const Source: DWWideString; MaxLen: SizeInt): PDWChar;
begin
  Result := StrLCopyW(Dest, PDWChar(Source), MaxLen);
end;
function StrRScanW(const Str: PDWChar; Chr: DWChar): PDWChar;
var
  P: PDWChar;
begin
  Result := nil;
  if Str <> nil then
  begin
    P := Str;
    repeat
      if P^ = Chr then
        Result := P;
      Inc(P);
    until P^ = #0;
  end;
end;
// Returns a pointer to first occurrence of a specified character in a string
// or nil if not found.
// Note: this is just a binary search for the specified character and there's no
//       check for a terminating null. Instead at most StrLen characters are
//       searched. This makes this function extremly fast.
//
function StrScanW(Str: PDWChar; Chr: DWChar; StrLen: SizeInt): PDWChar;
begin
  Result := Str;
  while StrLen > 0 do
  begin
    if Result^ = Chr then
      Exit;
    Inc(Result);
  end;
  Result := nil;
end;
function StrBufSizeW(const Str: PDWChar): SizeInt;
// Returns max number of wide characters that can be stored in a buffer
// allocated by StrAllocW.
var
  P: PDWChar;
begin
  if Str <> nil then
  begin
    P := Str;
    Dec(P, SizeOf(SizeInt) div SizeOf(WideChar));
    Result := (PSizeInt(P)^ - SizeOf(SizeInt)) div SizeOf(WideChar);
  end
  else
    Result := 0;
end;

function TrimW(const S: DWWideString): DWWideString;
// available from Delphi 7 up
{$IFDEF RTL150_UP}
begin
  Result := Trim(S);
end;
{$ELSE ~RTL150_UP}
var
  I, L: SizeInt;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do
    Inc(I);
  if I > L then
    Result := ''
  else
  begin
    while S[L] <= ' ' do
      Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;
{$ENDIF ~RTL150_UP}
function TrimLeftW(const S: DWWideString): DWWideString;
// available from Delphi 7 up
{$IFDEF RTL150_UP}
begin
  Result := TrimLeft(S);
end;
{$ELSE ~RTL150_UP}
var
  I, L: SizeInt;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do
    Inc(I);
  Result := Copy(S, I, Maxint);
end;
{$ENDIF ~RTL150_UP}
function TrimRightW(const S: DWWideString): DWWideString;
// available from Delphi 7 up
{$IFDEF RTL150_UP}
begin
  Result := TrimRight(S);
end;
{$ELSE ~RTL150_UP}
var
  I: SizeInt;
begin
  I := Length(S);
  while (I > 0) and (S[I] <= ' ') do
    Dec(I);
  Result := Copy(S, 1, I);
end;
{$ENDIF ~RTL150_UP}
function WideCompareText(const S1, S2: DWWideString): SizeInt;
begin
  {$IFDEF MSWINDOWS}
  if Win32Platform = VER_PLATFORM_WIN32_WINDOWS then
    Result := AnsiCompareText(string(S1), string(S2))
  else
    Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
                             PChar(S1), Length(S1), PChar(S2), Length(S2)) - 2;
  {$ELSE ~MSWINDOWS}
  { TODO : Don't cheat here }
  Result := CompareText(S1, S2);
  {$ENDIF MSWINDOWS}
end;
function WideUpperCase(const S: DWWideString): DWWideString;
begin
  Result := S;
  if Result <> '' then
    {$IFDEF MSWINDOWS}
    CharUpperBuffW(Pointer(Result), Length(Result));
    {$ELSE ~MSWINDOWS}
    { TODO : Don't cheat here }
    Result := UpperCase(Result);
    {$ENDIF ~MSWINDOWS}
end;
function WideLowerCase(const S: DWWideString): DWWideString;
begin
  Result := S;
  if Result <> '' then
    {$IFDEF MSWINDOWS}
    CharLowerBuffW(Pointer(Result), Length(Result));
    {$ELSE ~MSWINDOWS}
    { TODO : Don't cheat here }
    Result := LowerCase(Result);
    {$ENDIF ~MSWINDOWS}
end;
function TrimLeftLengthW(const S: DWWideString): SizeInt;
var
  Len: SizeInt;
begin
  Len := Length(S);
  Result := 1;
  while (Result <= Len) and (S[Result] <= #32) do
    Inc(Result);
  Result := Len - Result + 1;
end;
function TrimRightLengthW(const S: DWWideString): SizeInt;
begin
  Result := Length(S);
  while (Result > 0) and (S[Result] <= #32) do
    Dec(Result);
end;
{$IFNDEF SUPPORTS_UNICODE}
//=== { TJclWideStrings } ==========================================================
constructor TJclWideStrings.Create;
begin
  inherited Create;
  // FLineSeparator := DWChar($2028);
  {$IFDEF MSWINDOWS}
  FLineSeparator := DWChar(13) + '' + DWChar(10); // compiler wants it this way
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  FLineSeparator := DWChar(10);
  {$ENDIF UNIX}
  FNameValueSeparator := '=';
  FDelimiter := ',';
  FQuoteChar := '"';
end;
function TJclWideStrings.Add(const S: DWWideString): Integer;
begin
  Result := AddObject(S, nil);
end;
function TJclWideStrings.AddObject(const S: DWWideString; AObject: TObject): Integer;
begin
  Result := Count;
  InsertObject(Result, S, AObject);
end;
procedure TJclWideStrings.AddStrings(Strings: TJclWideStrings);
var
  I: Integer;
begin
  for I := 0 to Strings.Count - 1 do
    AddObject(Strings.GetP(I)^, Strings.Objects[I]);
end;
procedure TJclWideStrings.AddStrings(Strings: TStrings);
var
  I: Integer;
begin
  for I := 0 to Strings.Count - 1 do
    AddObject(Strings.Strings[I], Strings.Objects[I]);
end;
procedure TJclWideStrings.AddStringsTo(Dest: TStrings);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Dest.AddObject(GetP(I)^, Objects[I]);
end;
procedure TJclWideStrings.Append(const S: DWWideString);
begin
  Add(S);
end;
procedure TJclWideStrings.Assign(Source: TPersistent);
begin
  if Source is TJclWideStrings then
  begin
    BeginUpdate;
    try
      Clear;
      FDelimiter := TJclWideStrings(Source).FDelimiter;
      FNameValueSeparator := TJclWideStrings(Source).FNameValueSeparator;
      FQuoteChar := TJclWideStrings(Source).FQuoteChar;
      AddStrings(TJclWideStrings(Source));
    finally
      EndUpdate;
    end;
  end
  else
  if Source is TStrings then
  begin
    BeginUpdate;
    try
      Clear;
      {$IFDEF RTL190_UP}
      FNameValueSeparator := TStrings(Source).NameValueSeparator;
      FQuoteChar := TStrings(Source).QuoteChar;
      FDelimiter := TStrings(Source).Delimiter;
      {$ELSE ~RTL190_UP}
      {$IFDEF RTL150_UP}
      FNameValueSeparator := CharToWideChar(TStrings(Source).NameValueSeparator);
      {$ENDIF RTL150_UP}
      FQuoteChar := CharToWideChar(TStrings(Source).QuoteChar);
      FDelimiter := CharToWideChar(TStrings(Source).Delimiter);
      {$ENDIF ~RTL190_UP}
      AddStrings(TStrings(Source));
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;
procedure TJclWideStrings.AssignTo(Dest: TPersistent);
var
  I: Integer;
begin
  if Dest is TStrings then
  begin
    TStrings(Dest).BeginUpdate;
    try
      TStrings(Dest).Clear;
      {$IFDEF RTL190_UP}
      TStrings(Dest).NameValueSeparator := NameValueSeparator;
      TStrings(Dest).QuoteChar := QuoteChar;
      TStrings(Dest).Delimiter := Delimiter;
      {$ELSE ~RTL190_UP}
      {$IFDEF RTL150_UP}
      TStrings(Dest).NameValueSeparator := DWCharToChar(NameValueSeparator);
      {$ENDIF RTL150_UP}
      TStrings(Dest).QuoteChar := DWCharToChar(QuoteChar);
      TStrings(Dest).Delimiter := DWCharToChar(Delimiter);
      {$ENDIF ~RTL190_UP}
      for I := 0 to Count - 1 do
        TStrings(Dest).AddObject(GetP(I)^, Objects[I]);
    finally
      TStrings(Dest).EndUpdate;
    end;
  end
  else
    inherited AssignTo(Dest);
end;
procedure TJclWideStrings.BeginUpdate;
begin
  if FUpdateCount = 0 then
    SetUpdateState(True);
  Inc(FUpdateCount);
end;
function TJclWideStrings.CompareStrings(const S1, S2: DWWideString): Integer;
begin
  Result := WideCompareText(S1, S2);
end;
function TJclWideStrings.CreateAnsiStringList: TStrings;
var
  I: Integer;
begin
  Result := TStringList.Create;
  try
    Result.BeginUpdate;
    for I := 0 to Count - 1 do
      Result.AddObject(GetP(I)^, Objects[I]);
    Result.EndUpdate;
  except
    Result.Free;
    raise;
  end;
end;
procedure TJclWideStrings.DefineProperties(Filer: TFiler);
  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
    begin
      Result := True;
      if Filer.Ancestor is TJclWideStrings then
        Result := not Equals(TJclWideStrings(Filer.Ancestor))
    end
    else
      Result := Count > 0;
  end;
begin
  Filer.DefineProperty('Strings', ReadData, WriteData, DoWrite);
end;
procedure TJclWideStrings.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    SetUpdateState(False);
end;
function TJclWideStrings.Equals(Strings: TStrings): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Strings.Count = Count then
  begin
    for I := 0 to Count - 1 do
      if Strings[I] <> PStrings[I]^ then
        Exit;
    Result := True;
  end;
end;
function TJclWideStrings.Equals(Strings: TJclWideStrings): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Strings.Count = Count then
  begin
    for I := 0 to Count - 1 do
      if Strings[I] <> PStrings[I]^ then
        Exit;
    Result := True;
  end;
end;
procedure TJclWideStrings.Exchange(Index1, Index2: Integer);
var
  TempObject: TObject;
  TempString: DWWideString;
begin
  BeginUpdate;
  try
    TempString := PStrings[Index1]^;
    TempObject := Objects[Index1];
    PStrings[Index1]^ := PStrings[Index2]^;
    Objects[Index1] := Objects[Index2];
    PStrings[Index2]^ := TempString;
    Objects[Index2] := TempObject;
  finally
    EndUpdate;
  end;
end;
function TJclWideStrings.ExtractName(const S: DWWideString): DWWideString;
var
  Index: Integer;
begin
  Result := S;
  Index := WidePos(NameValueSeparator, Result);
  if Index <> 0 then
    SetLength(Result, Index - 1)
  else
    SetLength(Result, 0);
end;
function TJclWideStrings.Get(Index: Integer): DWWideString;
begin
  Result := GetP(Index)^;
end;
function TJclWideStrings.GetCapacity: Integer;
begin
  Result := Count;
end;
function TJclWideStrings.GetCommaText: DWWideString;
begin
  Result := GetDelimitedTextEx(',', '"');
end;
function TJclWideStrings.GetDelimitedText: DWWideString;
begin
  Result := GetDelimitedTextEx(FDelimiter, FQuoteChar);
end;
function TJclWideStrings.GetDelimitedTextEx(ADelimiter, AQuoteChar: DWChar): DWWideString;
var
  S: DWWideString;
  P: PDWChar;
  I, Num: Integer;
begin
  Num := GetCount;
  if (Num = 1) and (GetP(0)^ = '') then
    Result := AQuoteChar + '' + AQuoteChar // Compiler wants it this way
  else
  begin
    Result := '';
    for I := 0 to Count - 1 do
    begin
      S := GetP(I)^;
      P := PDWChar(S);
      while True do
      begin
        case P[0] of
          DWChar(0)..WideChar(32):
            Inc(P);
        else
          if (P[0] = AQuoteChar) or (P[0] = ADelimiter) then
            Inc(P)
          else
            Break;
        end;
      end;
      if P[0] <> DWChar(0) then
        S := WideQuotedStr(S, AQuoteChar);
      Result := Result + S + ADelimiter;
    end;
    System.Delete(Result, Length(Result), 1);
  end;
end;
function TJclWideStrings.GetName(Index: Integer): DWWideString;
var
  I: Integer;
begin
  Result := GetP(Index)^;
  I := WidePos(FNameValueSeparator, Result);
  if I > 0 then
    SetLength(Result, I - 1);
end;
function TJclWideStrings.GetObject(Index: Integer): TObject;
begin
  Result := nil;
end;
function TJclWideStrings.GetText: PDWChar;
begin
  Result := StrNewW(GetTextStr);
end;
function TJclWideStrings.GetTextStr: DWWideString;
var
  I: Integer;
  Len, LL: Integer;
  P: PDWChar;
  W: PWideString;
begin
  Len := 0;
  LL := Length(LineSeparator);
  for I := 0 to Count - 1 do
    Inc(Len, Length(GetP(I)^) + LL);
  SetLength(Result, Len);
  P := PDWChar(Result);
  for I := 0 to Count - 1 do
  begin
    W := GetP(I);
    Len := Length(W^);
    if Len > 0 then
    begin
      MoveWideChar(W^[1], P[0], Len);
      Inc(P, Len);
    end;
    if LL > 0 then
    begin
      MoveWideChar(FLineSeparator[1], P[0], LL);
      Inc(P, LL);
    end;
  end;
end;
function TJclWideStrings.GetValue(const Name: DWWideString): DWWideString;
var
  Idx: Integer;
begin
  Idx := IndexOfName(Name);
  if Idx >= 0 then
    Result := GetValueFromIndex(Idx)
  else
    Result := '';
end;
function TJclWideStrings.GetValueFromIndex(Index: Integer): DWWideString;
var
  I: Integer;
begin
  Result := GetP(Index)^;
  I := WidePos(FNameValueSeparator, Result);
  if I > 0 then
    System.Delete(Result, 1, I)
  else
    Result := '';
end;
function TJclWideStrings.IndexOf(const S: DWWideString): Integer;
begin
  for Result := 0 to Count - 1 do
    if CompareStrings(GetP(Result)^, S) = 0 then
      Exit;
  Result := -1;
end;
function TJclWideStrings.IndexOfName(const Name: DWWideString): Integer;
begin
  for Result := 0 to Count - 1 do
    if CompareStrings(Names[Result], Name) = 0 then
      Exit;
  Result := -1;
end;
function TJclWideStrings.IndexOfObject(AObject: TObject): Integer;
begin
  for Result := 0 to Count - 1 do
    if Objects[Result] = AObject then
      Exit;
  Result := -1;
end;
procedure TJclWideStrings.Insert(Index: Integer; const S: DWWideString);
begin
  InsertObject(Index, S, nil);
end;
procedure TJclWideStrings.InsertObject(Index: Integer; const S: DWWideString; AObject: TObject);
begin
end;
procedure TJclWideStrings.LoadFromFile(const FileName: TFileName;
  WideFileOptions: TWideFileOptions = []);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream, WideFileOptions);
  finally
    Stream.Free;
  end;
end;
procedure TJclWideStrings.LoadFromStream(Stream: TStream;
  WideFileOptions: TWideFileOptions = []);
var
  AnsiS: AnsiString;
  WideS: DWWideString;
  WC: DWChar;
begin
  BeginUpdate;
  try
    Clear;
    WC := #0;
    Stream.Read(WC, SizeOf(WC));
    if (foAnsiFile in WideFileOptions) and (Hi(Word(WC)) <> 0) and (WC <> BOM_LSB_FIRST) and (WC <> BOM_MSB_FIRST) then
    begin
      Stream.Seek(-SizeOf(WC), soFromCurrent);
      SetLength(AnsiS, (Stream.Size - Stream.Position) div SizeOf(AnsiChar));
      Stream.Read(AnsiS[1], Length(AnsiS) * SizeOf(AnsiChar));
      SetTextStr(WideString(AnsiS)); // explicit Unicode conversion
    end
    else
    begin
      if (WC <> BOM_LSB_FIRST) and (WC <> BOM_MSB_FIRST) then
        Stream.Seek(-SizeOf(WC), soFromCurrent);
      SetLength(WideS, (Stream.Size - Stream.Position + 1) div SizeOf(WideChar));
      Stream.Read(WideS[1], Length(WideS) * SizeOf(WideChar));
      if WC = BOM_MSB_FIRST then
        SwapWordByteOrder(PWideChar(WideS), Length(WideS));
      SetTextStr(WideS);
    end;
  finally
    EndUpdate;
  end;
end;
procedure TJclWideStrings.Move(CurIndex, NewIndex: Integer);
var
  TempObject: TObject;
  TempString: DWWideString;
begin
  if CurIndex <> NewIndex then
  begin
    BeginUpdate;
    try
      TempString := GetP(CurIndex)^;
      TempObject := GetObject(CurIndex);
      Delete(CurIndex);
      InsertObject(NewIndex, TempString, TempObject);
    finally
      EndUpdate;
    end;
  end;
end;
procedure TJclWideStrings.ReadData(Reader: TReader);
begin
  BeginUpdate;
  try
    Clear;
    Reader.ReadListBegin;
    while not Reader.EndOfList do
      if Reader.NextValue in [vaLString, vaString] then
        Add(Reader.ReadString)
      else
        Add(Reader.ReadWideString);
    Reader.ReadListEnd;
  finally
    EndUpdate;
  end;
end;
procedure TJclWideStrings.SaveToFile(const FileName: TFileName; WideFileOptions: TWideFileOptions = []);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream, WideFileOptions);
  finally
    Stream.Free;
  end;
end;
procedure TJclWideStrings.SaveToStream(Stream: TStream; WideFileOptions: TWideFileOptions = []);
var
  AnsiS: AnsiString;
  WideS: DWWideString;
  WC: DWChar;
begin
  if foAnsiFile in WideFileOptions then
  begin
    AnsiS := AnsiString(GetTextStr); // explicit Unicode conversion
    Stream.Write(AnsiS[1], Length(AnsiS) * SizeOf(AnsiChar));
  end
  else
  begin
    if foUnicodeLB in WideFileOptions then
    begin
      WC := BOM_LSB_FIRST;
      Stream.Write(WC, SizeOf(WC));
    end;
    WideS := GetTextStr;
    Stream.Write(WideS[1], Length(WideS) * SizeOf(WideChar));
  end;
end;
procedure TJclWideStrings.SetCapacity(NewCapacity: Integer);
begin
end;
procedure TJclWideStrings.SetCommaText(const Value: DWWideString);
begin
  SetDelimitedTextEx(',', '"', Value);
end;
procedure TJclWideStrings.SetDelimitedText(const Value: DWWideString);
begin
  SetDelimitedTextEx(Delimiter, QuoteChar, Value);
end;
procedure TJclWideStrings.SetDelimitedTextEx(ADelimiter, AQuoteChar: DWChar;
  const Value: DWWideString);
var
  P, P1: PDWChar;
  S: DWWideString;
  procedure IgnoreWhiteSpace(var P: PDWChar);
  begin
    while True do
      case P^ of
        DWChar(1)..WideChar(32):
          Inc(P);
      else
        Break;
      end;
  end;
begin
  BeginUpdate;
  try
    Clear;
    P := PDWChar(Value);
    IgnoreWhiteSpace(P);
    while P[0] <> DWChar(0) do
    begin
      if P[0] = AQuoteChar then
        S := WideExtractQuotedStr(P, AQuoteChar)
      else
      begin
        P1 := P;
        while (P[0] > DWChar(32)) and (P[0] <> ADelimiter) do
          Inc(P);
        SetString(S, P1, P - P1);
      end;
      Add(S);
      IgnoreWhiteSpace(P);
      if P[0] = ADelimiter then
      begin
        Inc(P);
        IgnoreWhiteSpace(P);
      end;
    end;
  finally
    EndUpdate;
  end;
end;
procedure TJclWideStrings.SetText(Text: PDWChar);
begin
  SetTextStr(Text);
end;
procedure TJclWideStrings.SetTextStr(const Value: DWWideString);
var
  P, Start: PDWChar;
  S: DWWideString;
  Len: Integer;
begin
  BeginUpdate;
  try
    Clear;
    if Value <> '' then
    begin
      P := PDWChar(Value);
      if P <> nil then
      begin
        while P[0] <> DWChar(0) do
        begin
          Start := P;
          while True do
          begin
            case P[0] of
              DWChar(0), DWChar(10), DWChar(13):
                Break;
            end;
            Inc(P);
          end;
          Len := P - Start;
          if Len > 0 then
          begin
            SetString(S, Start, Len);
            AddObject(S, nil); // consumes most time
          end
          else
            AddObject('', nil);
          if P[0] = DWChar(13) then
            Inc(P);
          if P[0] = DWChar(10) then
            Inc(P);
        end;
      end;
    end;
  finally
    EndUpdate;
  end;
end;
procedure TJclWideStrings.SetUpdateState(Updating: Boolean);
begin
end;
procedure TJclWideStrings.SetValue(const Name, Value: DWWideString);
var
  Idx: Integer;
begin
  Idx := IndexOfName(Name);
  if Idx >= 0 then
    SetValueFromIndex(Idx, Value)
  else
  if Value <> '' then
    Add(Name + NameValueSeparator + Value);
end;
procedure TJclWideStrings.SetValueFromIndex(Index: Integer; const Value: DWWideString);
var
  S: DWWideString;
  I: Integer;
begin
  if Value = '' then
    Delete(Index)
  else
  begin
    if Index < 0 then
      Index := Add('');
    S := GetP(Index)^;
    I := WidePos(NameValueSeparator, S);
    if I > 0 then
      System.Delete(S, I, MaxInt);
    S := S + NameValueSeparator + Value;
    Put(Index, S);
  end;
end;
procedure TJclWideStrings.WriteData(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do
     Writer.WriteWideString(GetP(I)^);
  Writer.WriteListEnd;
end;
//=== { TJclWideStringList } =======================================================
constructor TJclWideStringList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;
destructor TJclWideStringList.Destroy;
begin
  FOnChange := nil;
  FOnChanging := nil;
  Inc(FUpdateCount); // do not call unnecessary functions
  Clear;
  FList.Free;
  inherited Destroy;
end;
function TJclWideStringList.AddObject(const S: DWWideString; AObject: TObject): Integer;
begin
  if not Sorted then
    Result := Count
  else
  if Find(S, Result) then
    case Duplicates of
      dupIgnore:
        Exit;
      dupError:
        raise EListError.CreateRes(@SDuplicateString);
    end;
  InsertObject(Result, S, AObject);
end;
procedure TJclWideStringList.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;
procedure TJclWideStringList.Changing;
begin
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;
procedure TJclWideStringList.Clear;
var
  I: Integer;
  Item: PWStringItem;
begin
  if FUpdateCount = 0 then
    Changing;
  for I := 0 to Count - 1 do
  begin
    Item := PWStringItem(FList[I]);
    Item.FString := '';
    FreeMem(Item);
  end;
  FList.Clear;
  if FUpdateCount = 0 then
    Changed;
end;
function TJclWideStringList.CompareStrings(const S1, S2: DWWideString): Integer;
begin
  if CaseSensitive then
    Result := WideCompareStr(S1, S2)
  else
    Result := WideCompareText(S1, S2);
end;
threadvar
  CustomSortList: TJclWideStringList;
  CustomSortCompare: TJclWideStringListSortCompare;
function WStringListCustomSort(Item1, Item2: Pointer): Integer;
begin
  Result := CustomSortCompare(CustomSortList,
    CustomSortList.FList.IndexOf(Item1),
    CustomSortList.FList.IndexOf(Item2));
end;
procedure TJclWideStringList.CustomSort(Compare: TJclWideStringListSortCompare);
var
  TempList: TJclWideStringList;
  TempCompare: TJclWideStringListSortCompare;
begin
  TempList := CustomSortList;
  TempCompare := CustomSortCompare;
  CustomSortList := Self;
  CustomSortCompare := Compare;
  try
    Changing;
    FList.Sort(WStringListCustomSort);
    Changed;
  finally
    CustomSortList := TempList;
    CustomSortCompare := TempCompare;
  end;
end;
procedure TJclWideStringList.Delete(Index: Integer);
var
  Item: PWStringItem;
begin
  if FUpdateCount = 0 then
    Changing;
  Item := PWStringItem(FList[Index]);
  FList.Delete(Index);
  Item.FString := '';
  FreeMem(Item);
  if FUpdateCount = 0 then
    Changed;
end;
procedure TJclWideStringList.Exchange(Index1, Index2: Integer);
begin
  if FUpdateCount = 0 then
    Changing;
  FList.Exchange(Index1, Index2);
  if FUpdateCount = 0 then
    Changed;
end;
function TJclWideStringList.Find(const S: DWWideString; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  if Sorted then
  begin
    L := 0;
    H := Count - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := CompareStrings(GetItem(I).FString, S);
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
  end
  else
  begin
    Index := IndexOf(S);
    Result := Index <> -1;
  end;
end;
function TJclWideStringList.GetCapacity: Integer;
begin
  Result := FList.Capacity;
end;
function TJclWideStringList.GetCount: Integer;
begin
  Result := FList.Count;
end;
function TJclWideStringList.GetItem(Index: Integer): PWStringItem;
begin
  Result := FList[Index];
end;
function TJclWideStringList.GetObject(Index: Integer): TObject;
begin
  Result := GetItem(Index).FObject;
end;
function TJclWideStringList.GetP(Index: Integer): PWideString;
begin
  Result := Addr(GetItem(Index).FString);
end;
function TJclWideStringList.IndexOf(const S: DWWideString): Integer;
begin
  if Sorted then
  begin
    Result := -1;
    if not Find(S, Result) then
      Result := -1;
  end
  else
  begin
    for Result := 0 to Count - 1 do
      if CompareStrings(GetItem(Result).FString, S) = 0 then
        Exit;
    Result := -1;
  end;
end;
procedure TJclWideStringList.InsertObject(Index: Integer; const S: DWWideString;
  AObject: TObject);
var
  P: PWStringItem;
begin
  if FUpdateCount = 0 then
    Changing;
  FList.Insert(Index, nil); // error check
  P := AllocMem(SizeOf(TWStringItem));
  FList[Index] := P;
  Put(Index, S);
  if AObject <> nil then
    PutObject(Index, AObject);
  if FUpdateCount = 0 then
    Changed;
end;
procedure TJclWideStringList.Put(Index: Integer; const Value: DWWideString);
begin
  if FUpdateCount = 0 then
    Changing;
  GetItem(Index).FString := Value;
  if FUpdateCount = 0 then
    Changed;
end;
procedure TJclWideStringList.PutObject(Index: Integer; AObject: TObject);
begin
  if FUpdateCount = 0 then
    Changing;
  GetItem(Index).FObject := AObject;
  if FUpdateCount = 0 then
    Changed;
end;
procedure TJclWideStringList.SetCapacity(NewCapacity: Integer);
begin
  FList.Capacity := NewCapacity;
end;
procedure TJclWideStringList.SetCaseSensitive(const Value: Boolean);
begin
  if Value <> FCaseSensitive then
  begin
    FCaseSensitive := Value;
    if Sorted then
    begin
      Sorted := False;
      Sorted := True; // re-sort
    end;
  end;
end;
procedure TJclWideStringList.SetSorted(Value: Boolean);
begin
  if Value <> FSorted then
  begin
    FSorted := Value;
    if FSorted then
    begin
      FSorted := False;
      Sort;
      FSorted := True;
    end;
  end;
end;
procedure TJclWideStringList.SetUpdateState(Updating: Boolean);
begin
  if Updating then
    Changing
  else
    Changed;
end;
function DefaultSort(List: TJclWideStringList; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareStrings(List.GetItem(Index1).FString, List.GetItem(Index2).FString);
end;
procedure TJclWideStringList.Sort;
begin
  if not Sorted then
    CustomSort(DefaultSort);
end;
{$ENDIF ~SUPPORTS_UNICODE}
procedure AllocateMultiSz(var Dest: PWideMultiSz; Len: SizeInt);
begin
  if Len > 0 then
    GetMem(Dest, Len * SizeOf(WideChar))
  else
    Dest := nil;
end;
procedure FreeMultiSz(var Dest: PWideMultiSz);
begin
  if Dest <> nil then
    FreeMem(Dest);
  Dest := nil;
end;
{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);
finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
end.
