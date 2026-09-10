Unit uRESTDWMemStringsB;
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
  {$IFDEF UNICODE_RTL_DATABASE}
  System.Character,
  {$ENDIF UNICODE_RTL_DATABASE}
  System.Classes, System.SysUtils,
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  {$IFDEF UNICODE_RTL_DATABASE}
  Character,
  {$ENDIF UNICODE_RTL_DATABASE}
  Classes, SysUtils,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemAnsiStrings,
  uRESTDWMemWideStrings,
  uRESTDWMemBase, Math,
  uRESTDWPrototypes;
// Exceptions
Type
  EJclStringError = Class(EJclError);
// Character constants and sets
Const
  // Misc. often used character definitions
  NativeNull = Char(#0);
  NativeSoh = Char(#1);
  NativeStx = Char(#2);
  NativeEtx = Char(#3);
  NativeEot = Char(#4);
  NativeEnq = Char(#5);
  NativeAck = Char(#6);
  NativeBell = Char(#7);
  NativeBackspace = Char(#8);
  NativeTab = Char(#9);
  NativeLineFeed = uRESTDWMemBase.NativeLineFeed;
  NativeVerticalTab = Char(#11);
  NativeFormFeed = Char(#12);
  NativeCarriageReturn = uRESTDWMemBase.NativeCarriageReturn;
  NativeCrLf = uRESTDWMemBase.NativeCrLf;
  NativeSo = Char(#14);
  NativeSi = Char(#15);
  NativeDle = Char(#16);
  NativeDc1 = Char(#17);
  NativeDc2 = Char(#18);
  NativeDc3 = Char(#19);
  NativeDc4 = Char(#20);
  NativeNak = Char(#21);
  NativeSyn = Char(#22);
  NativeEtb = Char(#23);
  NativeCan = Char(#24);
  NativeEm = Char(#25);
  NativeEndOfFile = Char(#26);
  NativeEscape = Char(#27);
  NativeFs = Char(#28);
  NativeGs = Char(#29);
  NativeRs = Char(#30);
  NativeUs = Char(#31);
  NativeSpace = Char(' ');
  NativeComma = Char(',');
  NativeBackslash = Char('\');
  NativeForwardSlash = Char('/');
  NativeDoubleQuote = Char('"');
  NativeSingleQuote = Char('''');
  NativeLineBreak = sLineBreak;
Const
  // CharType return values
  C1_UPPER = $0001; // Uppercase
  C1_LOWER = $0002; // Lowercase
  C1_DIGIT = $0004; // Decimal digits
  C1_SPACE = $0008; // Space characters
  C1_PUNCT = $0010; // Punctuation
  C1_CNTRL = $0020; // Control characters
  C1_BLANK = $0040; // Blank characters
  C1_XDIGIT = $0080; // Hexadecimal digits
  C1_ALPHA = $0100; // Any linguistic character: alphabetic, syllabary, or ideographic
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
Type
  TCharValidator = Function(Const C: Char): Boolean;
Function ArrayContainsChar(Const Chars: array Of Char; Const C: Char): Boolean; overload;
Function ArrayContainsChar(Const Chars: array Of Char; Const C: Char; out Index: SizeInt): Boolean; overload;
// String Test Routines
Function StrIsAlpha(Const S: string): Boolean;
Function StrIsAlphaNum(Const S: string): Boolean;
Function StrIsAlphaNumUnderscore(Const S: string): Boolean;
Function StrContainsChars(Const S: string; Const Chars: TCharValidator; CheckAll: Boolean): Boolean; overload;
Function StrContainsChars(Const S: string; Const Chars: array Of Char; CheckAll: Boolean): Boolean; overload;
Function StrConsistsOfNumberChars(Const S: string): Boolean;
Function StrIsDigit(Const S: string): Boolean;
Function StrIsSubset(Const S: string; Const ValidChars: TCharValidator): Boolean; overload;
Function StrIsSubset(Const S: string; Const ValidChars: array Of Char): Boolean; overload;
Function StrSame(Const S1, S2: string; CaseSensitive: Boolean = False): Boolean;
// String Transformation Routines
Function StrCenter(Const S: string; L: SizeInt; C: Char = ' '): string;
Function StrCharPosLower(Const S: string; CharPos: SizeInt): string;
Function StrCharPosUpper(Const S: string; CharPos: SizeInt): string;
Function StrDoubleQuote(Const S: string): string;
Function StrEnsureNoPrefix(Const Prefix, Text: string): string;
Function StrEnsureNoSuffix(Const Suffix, Text: string): string;
Function StrEnsurePrefix(Const Prefix, Text: string): string;
Function StrEnsureSuffix(Const Suffix, Text: string): string;
Function StrEscapedToString(Const S: string): string;
Function StrLower(Const S: string): string;
Procedure StrLowerInPlace(Var S: string);
Procedure StrLowerBuff(S: PChar);
Procedure StrMove(Var Dest: string; Const Source: string; Const ToIndex,
  FromIndex, Count: SizeInt);
Function StrPadLeft(Const S: string; Len: SizeInt; C: Char = NativeSpace): string;
Function StrPadRight(Const S: string; Len: SizeInt; C: Char = NativeSpace): string;
Function StrProper(Const S: string): string;
Procedure StrProperBuff(S: PChar);
Function StrQuote(Const S: string; C: Char): string;
Function StrRemoveChars(Const S: string; Const Chars: TCharValidator): string; overload;
Function StrRemoveChars(Const S: string; Const Chars: array Of Char): string; overload;
Function StrRemoveLeadingChars(Const S: string; Const Chars: TCharValidator): string; overload;
Function StrRemoveLeadingChars(Const S: string; Const Chars: array Of Char): string; overload;
Function StrRemoveEndChars(Const S: string; Const Chars: TCharValidator): string; overload;
Function StrRemoveEndChars(Const S: string; Const Chars: array Of Char): string; overload;
Function StrKeepChars(Const S: string; Const Chars: TCharValidator): string; overload;
Function StrKeepChars(Const S: string; Const Chars: array Of Char): string; overload;
Procedure StrReplace(Var S: string; Const Search, Replace: string; Flags: TReplaceFlags = []);
Function StrReplaceChar(Const S: string; Const Source, Replace: Char): string;
Function StrReplaceChars(Const S: string; Const Chars: TCharValidator; Replace: Char): string; overload;
Function StrReplaceChars(Const S: string; Const Chars: array Of Char; Replace: Char): string; overload;
Function StrReplaceButChars(Const S: string; Const Chars: TCharValidator; Replace: Char): string; overload;
Function StrReplaceButChars(Const S: string; Const Chars: array Of Char; Replace: Char): string; overload;
Function StrRepeat(Const S: string; Count: SizeInt): string;
Function StrReverse(Const S: string): string;
Procedure StrReverseInPlace(Var S: string);
Function StrSingleQuote(Const S: string): string;
Procedure StrSkipChars(Var S: PChar; Const Chars: TCharValidator); overload;
Procedure StrSkipChars(Var S: PChar; Const Chars: array Of Char); overload;
Procedure StrSkipChars(Const S: string; Var Index: SizeInt; Const Chars: TCharValidator); overload;
Procedure StrSkipChars(Const S: string; Var Index: SizeInt; Const Chars: array Of Char); overload;
Function StrSmartCase(Const S: string; Const Delimiters: TCharValidator): string; overload;
Function StrSmartCase(Const S: string; Const Delimiters: array Of Char): string; overload;
Function StrStringToEscaped(Const S: string): string;
Function StrStripNonNumberChars(Const S: string): string;
Function StrToHex(Const Source: string): string;
Function StrTrimCharLeft(Const S: string; C: Char): string;
Function StrTrimCharsLeft(Const S: string; Const Chars: TCharValidator): string; overload;
Function StrTrimCharsLeft(Const S: string; Const Chars: array Of Char): string; overload;
Function StrTrimCharRight(Const S: string; C: Char): string;
Function StrTrimCharsRight(Const S: string; Const Chars: TCharValidator): string; overload;
Function StrTrimCharsRight(Const S: string; Const Chars: array Of Char): string; overload;
Function StrTrimQuotes(Const S: string): string;
Function StrUpper(Const S: string): string;
Procedure StrUpperInPlace(Var S: string);
Procedure StrUpperBuff(S: PChar);
// String Management
Procedure StrAddRef(Var S: string);
Procedure StrDecRef(Var S: string);
Function StrLength(Const S: string): SizeInt;
Function StrRefCount(Const S: string): SizeInt;
// String Search and Replace Routines
Function StrCharCount(Const S: string; C: Char): SizeInt; overload;
Function StrCharsCount(Const S: string; Const Chars: TCharValidator): SizeInt; overload;
Function StrCharsCount(Const S: string; Const Chars: array Of Char): SizeInt; overload;
Function StrStrCount(Const S, SubS: string): SizeInt;
Function StrCompare(Const S1, S2: string; CaseSensitive: Boolean = False): SizeInt;
Function StrCompareRange(Const S1, S2: string; Index, Count: SizeInt; CaseSensitive: Boolean = True): SizeInt;
Function StrCompareRangeEx(Const S1, S2: string; Index, Count: SizeInt; CaseSensitive: Boolean): SizeInt;
Procedure StrFillChar(Var S; Count: SizeInt; C: Char);
Function StrRepeatChar(C: Char; Count: SizeInt): string;
Function StrFind(Const Substr, S: string; Const Index: SizeInt = 1): SizeInt;
Function StrHasPrefix(Const S: string; Const Prefixes: array Of string): Boolean;
Function StrHasSuffix(Const S: string; Const Suffixes: array Of string): Boolean;
Function StrIndex(Const S: string; Const List: array Of string; CaseSensitive: Boolean = False): SizeInt;
Function StrIHasPrefix(Const S: string; Const Prefixes: array Of string): Boolean;
Function StrIHasSuffix(Const S: string; Const Suffixes: array Of string): Boolean;
Function StrILastPos(Const SubStr, S: string): SizeInt;
Function StrIPos(Const SubStr, S: string): SizeInt;
Function StrIPrefixIndex(Const S: string; Const Prefixes: array Of string): SizeInt;
Function StrIsOneOf(Const S: string; Const List: array Of string): Boolean;
Function StrISuffixIndex(Const S: string; Const Suffixes: array Of string): SizeInt;
Function StrLastPos(Const SubStr, S: string): SizeInt;
Function StrMatch(Const Substr, S: string; Index: SizeInt = 1): SizeInt;
Function StrMatches(Const Substr, S: string; Const Index: SizeInt = 1): Boolean;
Function StrNIPos(Const S, SubStr: string; N: SizeInt): SizeInt;
Function StrNPos(Const S, SubStr: string; N: SizeInt): SizeInt;
Function StrPrefixIndex(Const S: string; Const Prefixes: array Of string): SizeInt;
Function StrSearch(Const Substr, S: string; Const Index: SizeInt = 1): SizeInt;
Function StrSuffixIndex(Const S: string; Const Suffixes: array Of string): SizeInt;
// String Extraction
/// Returns the string after SubStr
Function StrAfter(Const SubStr, S: string): string;
/// Returns the String before SubStr
Function StrBefore(Const SubStr, S: string): string;
/// Splits a string at SubStr, returns true when SubStr is found, Left contains the
/// string before the SubStr and Right the string behind SubStr
Function StrSplit(Const SubStr, S: string;Var Left, Right : string): boolean;
/// Returns the string between Start and Stop
Function StrBetween(Const S: string; Const Start, Stop: Char): string;
/// Returns all but rightmost N characters of the string
Function StrChopRight(Const S: string; N: SizeInt): string;{$IFDEF SUPPORTS_INLINE} {$IFDEF COMPILER16_UP} inline; {$ENDIF} {$ENDIF}
/// Returns the left Count characters of the string
Function StrLeft(Const S: string; Count: SizeInt): string; {$IFDEF SUPPORTS_INLINE} {$IFDEF COMPILER16_UP} inline; {$ENDIF} {$ENDIF}
/// Returns the string starting from position Start for the Count Characters
Function StrMid(Const S: string; Start, Count: SizeInt): string; {$IFDEF SUPPORTS_INLINE} {$IFDEF COMPILER16_UP} inline; {$ENDIF} {$ENDIF}
/// Returns the string starting from position N to the end
Function StrRestOf(Const S: string; N: SizeInt): string;{$IFDEF SUPPORTS_INLINE} {$IFDEF COMPILER16_UP} inline; {$ENDIF} {$ENDIF}
/// Returns the right Count characters of the string
Function StrRight(Const S: string; Count: SizeInt): string;{$IFDEF SUPPORTS_INLINE} {$IFDEF COMPILER16_UP} inline; {$ENDIF} {$ENDIF}
// Character Test Routines
Function CharEqualNoCase(Const C1, C2: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsAlpha(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsAlphaNum(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsBlank(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsControl(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsDelete(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsDigit(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsFracDigit(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsHexDigit(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsLower(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsNumberChar(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} {$IFDEF COMPILER16_UP} inline; {$ENDIF} {$ENDIF}
Function CharIsNumber(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} {$IFDEF COMPILER16_UP} inline; {$ENDIF} {$ENDIF}
Function CharIsPrintable(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsPunctuation(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsReturn(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsSpace(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsUpper(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsValidIdentifierLetter(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsWhiteSpace(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharIsWildcard(Const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharType(Const C: Char): Word;
// Character Transformation Routines
Function CharHex(Const C: Char): Byte;
Function CharLower(Const C: Char): Char; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharUpper(Const C: Char): Char; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Function CharToggleCase(Const C: Char): Char;
// Character Search and Replace
Function CharPos(Const S: string; Const C: Char; Const Index: SizeInt = 1): SizeInt;
Function CharLastPos(Const S: string; Const C: Char; Const Index: SizeInt = 1): SizeInt;
Function CharIPos(Const S: string; C: Char; Const Index: SizeInt = 1): SizeInt;
Function CharReplace(Var S: string; Const Search, Replace: Char): SizeInt;
// PCharVector
Type
  PCharVector = ^PChar;
Function StringsToPCharVector(Var Dest: PCharVector; Const Source: TStrings): PCharVector;
Function PCharVectorCount(Source: PCharVector): SizeInt;
Procedure PCharVectorToStrings(Const Dest: TStrings; Source: PCharVector);
Procedure FreePCharVector(Var Dest: PCharVector);
// MultiSz Routines
Type
  PMultiSz = PChar;
  PAnsiMultiSz = uRESTDWMemAnsiStrings.PAnsiMultiSz;
  PWideMultiSz = uRESTDWMemWideStrings.PWideMultiSz;
  TAnsiStrings = uRESTDWMemAnsiStrings.TJclAnsiStrings;
  TWideStrings = uRESTDWMemWideStrings.TJclWideStrings;
  TAnsiStringList = uRESTDWMemAnsiStrings.TJclAnsiStringList;
  TWideStringList = uRESTDWMemWideStrings.TJclWideStringList;
Function StringsToMultiSz(Var Dest: PMultiSz; Const Source: TStrings): PMultiSz;
Procedure MultiSzToStrings(Const Dest: TStrings; Const Source: PMultiSz);
Function MultiSzLength(Const Source: PMultiSz): SizeInt;
Procedure AllocateMultiSz(Var Dest: PMultiSz; Len: SizeInt);
Procedure FreeMultiSz(Var Dest: PMultiSz);
Function MultiSzDup(Const Source: PMultiSz): PMultiSz;
 {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Procedure AllocateAnsiMultiSz(Var Dest: PAnsiMultiSz; Len: SizeInt); {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Procedure FreeAnsiMultiSz(Var Dest: PAnsiMultiSz); {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Procedure AllocateWideMultiSz(Var Dest: PWideMultiSz; Len: SizeInt); {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Procedure FreeWideMultiSz(Var Dest: PWideMultiSz); {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
// TStrings Manipulation
Procedure StrIToStrings(S, Sep: string; Const List: TStrings; Const AllowEmptyString: Boolean = True);
Procedure StrToStrings(S, Sep: string; Const List: TStrings; Const AllowEmptyString: Boolean = True);
Function StringsToStr(Const List: TStrings; Const Sep: string; Const AllowEmptyString: Boolean = True): string; overload;
Function StringsToStr(Const List: TStrings; Const Sep: string; Const NumberOfItems: SizeInt; Const AllowEmptyString:
    Boolean = True): string; overload;
Procedure TrimStrings(Const List: TStrings; DeleteIfEmpty: Boolean = True);
Procedure TrimStringsRight(Const List: TStrings; DeleteIfEmpty: Boolean = True);
Procedure TrimStringsLeft(Const List: TStrings; DeleteIfEmpty: Boolean = True);
Function AddStringToStrings(Const S: string; Strings: TStrings; Const Unique: Boolean): Boolean;
// Miscellaneous
// (OF) moved to JclSysUtils
// function BooleanToStr(B: Boolean): string;
 // DWString here because it is binary data
Function FileToString(Const FileName: string): {$IFDEF COMPILER12_UP}RawByteString{$ELSE}DWString{$ENDIF};
Procedure StringToFile(Const FileName: string; Const Contents: {$IFDEF COMPILER12_UP}RawByteString{$ELSE}DWString{$ENDIF};
  Append: Boolean = False);
Function StrToken(Var S: string; Separator: Char): string;
Procedure StrTokens(Const S: string; Const List: TStrings);
Procedure StrTokenToStrings(S: string; Separator: Char; Const List: TStrings);
Function StrWord(Const S: string; Var Index: SizeInt; out Word: string): Boolean; overload;
Function StrWord(Var S: PChar; out Word: string): Boolean; overload;
Function StrIdent(Const S: string; Var Index: SizeInt; out Ident: string): Boolean; overload;
Function StrIdent(Var S: PChar; out Ident: string): Boolean; overload;
Function StrToFloatSafe(Const S: string): Float;
Function StrToIntSafe(Const S: string): Integer;
Procedure StrNormIndex(Const StrLen: SizeInt; Var Index: SizeInt; Var Count: SizeInt); overload;
Function ArrayOf(List: TStrings): TDynStringArray; overload;
Type
  FormatException = Class(EJclError);
  ArgumentException = Class(EJclError);
  ArgumentNullException = Class(EJclError);
  ArgumentOutOfRangeException = Class(EJclError);
  IToString = Interface
    ['{C4ABABB4-1029-46E7-B5FA-99800F130C05}']
    Function ToString: string;
  End;
  TCharDynArray = array Of Char;
  // The TStringBuilder class is a Delphi implementation of the .NET
  // System.Text.StringBuilder.
  // It is zero based and the methods that have a TObject argument (Append, Insert,
  // AppendFormat) are limited to IToString implementors or Delphi 2009+ RTL.
  // This class is not threadsafe. Any instance of TStringBuilder should not
  // be used in different threads at the same time.
  TJclStringBuilder = Class(TInterfacedObject, IToString)
  Private
    FChars: TCharDynArray;
    FLength: SizeInt;
    FMaxCapacity: SizeInt;
    Function GetCapacity: SizeInt;
    Procedure SetCapacity(Const Value: SizeInt);
    Function GetChars(Index: SizeInt): Char;
    Procedure SetChars(Index: SizeInt; Const Value: Char);
    Procedure Set_Length(Const Value: SizeInt);
  Protected
    Function AppendPChar(Value: PChar; Count: SizeInt; RepeatCount: SizeInt = 1): TJclStringBuilder;
    Function InsertPChar(Index: SizeInt; Value: PChar; Count: SizeInt; RepeatCount: SizeInt = 1): TJclStringBuilder;
  Public
    Constructor Create(Const Value: string; Capacity: SizeInt = 16); overload;
    Constructor Create(Capacity: SizeInt = 16; MaxCapacity: SizeInt = MaxInt); overload;
    Constructor Create(Const Value: string; StartIndex, Length, Capacity: SizeInt); overload;
    Function Append(Const Value: string): TJclStringBuilder; overload;
    Function Append(Const Value: string; StartIndex, Length: SizeInt): TJclStringBuilder; overload;
    Function Append(Value: Boolean): TJclStringBuilder; overload;
    Function Append(Value: Char; RepeatCount: SizeInt = 1): TJclStringBuilder; overload;
    Function Append(Const Value: array Of Char): TJclStringBuilder; overload;
    Function Append(Const Value: array Of Char; StartIndex, Length: SizeInt): TJclStringBuilder; overload;
    Function Append(Value: Cardinal): TJclStringBuilder; overload;
    Function Append(Value: Integer): TJclStringBuilder; overload;
    Function Append(Value: Double): TJclStringBuilder; overload;
    Function Append(Value: Int64): TJclStringBuilder; overload;
    Function Append(Obj: TObject): TJclStringBuilder; overload;
    Function AppendFormat(Const Fmt: string; Const Args: array Of Const): TJclStringBuilder; overload;
    Function AppendFormat(Const Fmt: string; Arg0: Variant): TJclStringBuilder; overload;
    Function AppendFormat(Const Fmt: string; Arg0, Arg1: Variant): TJclStringBuilder; overload;
    Function AppendFormat(Const Fmt: string; Arg0, Arg1, Arg2: Variant): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Const Value: string; Count: SizeInt = 1): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Value: Boolean): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Const Value: array Of Char): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Const Value: array Of Char; StartIndex, Length: SizeInt): TJclStringBuilder;
      overload;
    Function Insert(Index: SizeInt; Value: Cardinal): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Value: Integer): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Value: Double): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Value: Int64): TJclStringBuilder; overload;
    Function Insert(Index: SizeInt; Obj: TObject): TJclStringBuilder; overload;
    Function Replace(OldChar, NewChar: Char; StartIndex: SizeInt = 0; Count: SizeInt = -1): TJclStringBuilder;
      overload;
    Function Replace(OldValue, NewValue: string; StartIndex: SizeInt = 0; Count: SizeInt = -1): TJclStringBuilder;
      overload;
    Function Remove(StartIndex, Length: SizeInt): TJclStringBuilder;
    Function EnsureCapacity(Capacity: SizeInt): SizeInt;
    Procedure Clear;
    { IToString }
    Function ToString: string; {$IFDEF RTL200_UP} override; {$ENDIF RTL200_UP}
    property __Chars__[Index: SizeInt]: Char read GetChars write SetChars; default;
    property Chars: TCharDynArray read FChars;
    property Length: SizeInt read FLength write Set_Length;
    property Capacity: SizeInt read GetCapacity write SetCapacity;
    property MaxCapacity: SizeInt read FMaxCapacity;
  End;
  {$IFDEF RTL200_UP}
  TStringBuilder = {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.TStringBuilder;
  {$ELSE ~RTL200_UP}
  TStringBuilder = TJclStringBuilder;
  {$ENDIF ~RTL200_UP}
// DotNetFormat() uses the .NET format style: "{argX}"
Function DotNetFormat(Const Fmt: string; Const Args: array Of Const): string; overload;
Function DotNetFormat(Const Fmt: string; Const Arg0: Variant): string; overload;
Function DotNetFormat(Const Fmt: string; Const Arg0, Arg1: Variant): string; overload;
Function DotNetFormat(Const Fmt: string; Const Arg0, Arg1, Arg2: Variant): string; overload;
// TJclTabSet
Type
  TJclTabSet = Class (TInterfacedObject, IToString)
  Private
    FData: TObject;
    Function GetCount: SizeInt;
    Function GetStops(Index: SizeInt): SizeInt;
    Function GetTabWidth: SizeInt;
    Function GetZeroBased: Boolean;
    Procedure SetStops(Index, Value: SizeInt);
    Procedure SetTabWidth(Value: SizeInt);
    Procedure SetZeroBased(Value: Boolean);
  Protected
    Function FindStop(Column: SizeInt): SizeInt;
    Function InternalTabStops: TDynSizeIntArray;
    Function InternalTabWidth: SizeInt;
    Procedure RemoveAt(Index: SizeInt);
  Public
    Constructor Create; overload;
    Constructor Create(Data: TObject); overload;
    Constructor Create(TabWidth: SizeInt); overload;
    Constructor Create(Const Tabstops: array Of SizeInt; ZeroBased: Boolean); overload;
    Constructor Create(Const Tabstops: array Of SizeInt; ZeroBased: Boolean; TabWidth: SizeInt); overload;
    Destructor Destroy; override;
    // cloning and referencing
    Function Clone: TJclTabSet;
    Function NewReference: TJclTabSet;
    // Tab stops manipulation
    Function Add(Column: SizeInt): SizeInt;
    Function Delete(Column: SizeInt): SizeInt;
    // Usage
    Function Expand(Const S: string): string; overload;
    Function Expand(Const S: string; Column: SizeInt): string; overload;
    Procedure OptimalFillInfo(StartColumn, TargetColumn: SizeInt; out TabsNeeded, SpacesNeeded: SizeInt);
    Function Optimize(Const S: string): string; overload;
    Function Optimize(Const S: string; Column: SizeInt): string; overload;
    Function StartColumn: SizeInt;
    Function TabFrom(Column: SizeInt): SizeInt;
    Function UpdatePosition(Const S: string): SizeInt; overload;
    Function UpdatePosition(Const S: string; Column: SizeInt): SizeInt; overload;
    Function UpdatePosition(Const S: string; Var Column, Line: SizeInt): SizeInt; overload;
    { IToString }
    Function ToString: string; overload; {$IFDEF RTL200_UP} override; {$ENDIF RTL200_UP}
    // Conversions
    Function ToString(FormattingOptions: SizeInt): string; {$IFDEF RTL200_UP} reintroduce; {$ENDIF RTL200_UP} overload;
    Class Function FromString(Const S: string): TJclTabSet; {$IFDEF SUPPORTS_STATIC} static; {$ENDIF SUPPORTS_STATIC}
    // Properties
    property ActualTabWidth: SizeInt read InternalTabWidth;
    property Count: SizeInt read GetCount;
    property TabStops[Index: SizeInt]: SizeInt read GetStops write SetStops; default;
    property TabWidth: SizeInt read GetTabWidth write SetTabWidth;
    property ZeroBased: Boolean read GetZeroBased write SetZeroBased;
  End;
// Formatting constants
Const
  TabSetFormatting_SurroundStopsWithBrackets = 1;
  TabSetFormatting_EmptyBracketsIfNoStops = 2;
  TabSetFormatting_NoTabStops = 4;
  TabSetFormatting_NoTabWidth = 8;
  TabSetFormatting_AutoTabWidth = 16;
  // common combinations
  TabSetFormatting_Default = 0;
  TabSetFormatting_AlwaysUseBrackets = TabSetFormatting_SurroundStopsWithBrackets or
    TabSetFormatting_EmptyBracketsIfNoStops;
  TabSetFormatting_Full = TabSetFormatting_AlwaysUseBrackets or TabSetFormatting_AutoTabWidth;
  // aliases
  TabSetFormatting_StopsOnly = TabSetFormatting_NoTabWidth;
  TabSetFormatting_TabWidthOnly = TabSetFormatting_NoTabStops;
  TabSetFormatting_StopsWithoutBracketsAndTabWidth = TabSetFormatting_Default;
// Tab expansion routines
Function StrExpandTabs(S: string): string; {$IFDEF SUPPORTS_INLINE}inline; {$ENDIF} overload;
Function StrExpandTabs(S: string; TabWidth: SizeInt): string; {$IFDEF SUPPORTS_INLINE}inline; {$ENDIF} overload;
Function StrExpandTabs(S: string; TabSet: TJclTabSet): string; {$IFDEF SUPPORTS_INLINE}inline; {$ENDIF} overload;
// Tab optimization routines
Function StrOptimizeTabs(S: string): string; {$IFDEF SUPPORTS_INLINE}inline; {$ENDIF} overload;
Function StrOptimizeTabs(S: string; TabWidth: SizeInt): string; {$IFDEF SUPPORTS_INLINE}inline; {$ENDIF} overload;
Function StrOptimizeTabs(S: string; TabSet: TJclTabSet): string; {$IFDEF SUPPORTS_INLINE}inline; {$ENDIF} overload;
// move to JclBase?
Type
  NullReferenceException = Class(EJclError)
  Public
    Constructor Create; overload;
  End;
Procedure StrResetLength(Var S: DWString); overload;
// natural comparison functions
{$IFNDEF UNICODE_RTL_DATABASE}
// internal structures published to make function inlining working
Const
  MaxStrCharCount = Ord(High(Char)) + 1;       // # of chars in one set
  StrLoOffset = MaxStrCharCount * 0;       // offset to lower case chars
  StrUpOffset = MaxStrCharCount * 1;       // offset to upper case chars
  StrReOffset = MaxStrCharCount * 2;       // offset to reverse case chars
  StrCaseMapSize = MaxStrCharCount * 3;       // # of chars is a table
Var
  StrCaseMap: array [0..StrCaseMapSize - 1] Of Char; // case mappings
  StrCaseMapReady: Boolean = False;         // true if case map exists
  StrCharTypes: array [Char] Of Word;
{$ENDIF ~UNICODE_RTL_DATABASE}
Implementation
Uses
  {$IFDEF HAS_UNIT_LIBC}
  Libc,
  {$ENDIF HAS_UNIT_LIBC}
  {$IFDEF SUPPORTS_UNICODE}
  {$IFDEF HAS_UNITSCOPE}
  System.StrUtils,
  {$ELSE ~HAS_UNITSCOPE}
  StrUtils,
  {$ENDIF ~HAS_UNITSCOPE}
  {$ENDIF SUPPORTS_UNICODE}
  uRESTDWMemResources, uRESTDWMemStreams, uRESTDWBasicTypes;
//=== Internal ===============================================================
Type
  TStrRec = packed Record
    RefCount: Integer;
    Length: Integer;
  End;
  PStrRec = ^TStrRec;
{$IFNDEF UNICODE_RTL_DATABASE}
Procedure LoadCharTypes;
Var
  CurrChar: Char;
  CurrType: Word;
Begin
  For CurrChar := Low(CurrChar) To High(CurrChar) Do
  Begin
    {$IFDEF MSWINDOWS}
    CurrType := 0;
    GetStringTypeEx(LOCALE_USER_DEFAULT, CT_CTYPE1, @CurrChar, 1, CurrType);
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
    StrCharTypes[CurrChar] := CurrType;
  End;
End;
Procedure LoadCaseMap;
Var
  CurrChar, UpCaseChar, LoCaseChar, ReCaseChar: Char;
Begin
  If not StrCaseMapReady Then
  Begin
    For CurrChar := Low(Char) To High(Char) Do
    Begin
      {$IFDEF MSWINDOWS}
      LoCaseChar := CurrChar;
      UpCaseChar := CurrChar;
      {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.CharLowerBuff(@LoCaseChar, 1);
      {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.CharUpperBuff(@UpCaseChar, 1);
      {$DEFINE CASE_MAP_INITIALIZED}
      {$ENDIF MSWINDOWS}
      {$IFDEF LINUX}
      LoCaseChar := Char(tolower(Byte(CurrChar)));
      UpCaseChar := Char(toupper(Byte(CurrChar)));
      {$DEFINE CASE_MAP_INITIALIZED}
      {$ENDIF LINUX}
      If CharIsUpper(CurrChar) Then
        ReCaseChar := LoCaseChar
      Else
      If CharIsLower(CurrChar) Then
        ReCaseChar := UpCaseChar
      Else
        ReCaseChar := CurrChar;
      StrCaseMap[Ord(CurrChar) + StrLoOffset] := LoCaseChar;
      StrCaseMap[Ord(CurrChar) + StrUpOffset] := UpCaseChar;
      StrCaseMap[Ord(CurrChar) + StrReOffset] := ReCaseChar;
    End;
    StrCaseMapReady := True;
  End;
End;
// Uppercases or Lowercases a give string depending on the
// passed offset. (UpOffset or LoOffset)
Procedure StrCase(Var Str: string; Const Offset: SizeInt);
Var
  P: PChar;
  I, L: SizeInt;
Begin
  L := Length(Str);
  If L > 0 Then
  Begin
    UniqueString(Str);
    P := PChar(Str);
    For I := 1 To L Do
    Begin
      P^ := StrCaseMap[Offset + Ord(P^)];
      Inc(P);
    End;
  End;
End;
// Internal utility function
// Uppercases or Lowercases a give null terminated string depending on the
// passed offset. (UpOffset or LoOffset)
Procedure StrCaseBuff(S: PChar; Const Offset: SizeInt);
Var
  C: Char;
Begin
  If S <> nil Then
  Begin
    Repeat
      C := S^;
      S^ := StrCaseMap[Offset + Ord(C)];
      Inc(S);
    Until C = #0;
  End;
End;
{$ENDIF ~UNICODE_RTL_DATABASE}
Function StrEndW(Str: PWideChar): PWideChar;
Begin
  Result := Str;
  While Result^ <> #0 Do
    Inc(Result);
End;
Function ArrayContainsChar(Const Chars: array Of Char; Const C: Char): Boolean;
Var
  idx: SizeInt;
Begin
  Result := ArrayContainsChar(Chars, C, idx);
End;
Function ArrayContainsChar(Const Chars: array Of Char; Const C: Char; out Index: SizeInt): Boolean;
{ optimized version for sorted arrays
var
  I, L, H: SizeInt;
begin
  L := Low(Chars);
  H := High(Chars);
  while L <= H do
  begin
    I := (L + H) div 2;
    if C = Chars[I] then
    begin
      Result := True;
      Exit;
    end
    else
    if C < Chars[I] then
      H := I - 1
    else
      // C > Chars[I]
      L := I + 1;
  end;
  Result := False;
end;}
Begin
  Index := High(Chars);
  While (Index >= Low(Chars)) and (Chars[Index] <> C) Do
    Dec(Index);
  Result := Index >= Low(Chars);
End;
// String Test Routines
Function StrIsAlpha(Const S: string): Boolean;
Var
  I: SizeInt;
Begin
  Result := S <> '';
  For I := 1 To Length(S) Do
  Begin
    If not CharIsAlpha(S[I]) Then
    Begin
      Result := False;
      Exit;
    End;
  End;
End;
Function StrIsAlphaNum(Const S: string): Boolean;
Var
  I: SizeInt;
Begin
  Result := S <> '';
  For I := 1 To Length(S) Do
  Begin
    If not CharIsAlphaNum(S[I]) Then
    Begin
      Result := False;
      Exit;
    End;
  End;
End;
Function StrConsistsofNumberChars(Const S: string): Boolean;
Var
  I: SizeInt;
Begin
  Result := S <> '';
  For I := 1 To Length(S) Do
  Begin
    If not CharIsNumberChar(S[I]) Then
    Begin
      Result := False;
      Exit;
    End;
  End;
End;
Function StrContainsChars(Const S: string; Const Chars: TCharValidator; CheckAll: Boolean): Boolean;
Var
  I: SizeInt;
Begin
  Result := False;
  If CheckAll Then
  Begin
    // this will not work with the current definition of the validator. The validator would need to check each character
    // it requires against the string (which is currently not provided to the Validator). The current implementation of
    // CheckAll will check if all characters in S will be accepted by the provided Validator, which is wrong and incon-
    // sistent with the documentation and the array-based overload.
    For I := 1 To Length(S) Do
    Begin
      Result := Chars(S[I]);
      If not Result Then
        Break;
    End;
  End
  Else
  Begin
    For I := 1 To Length(S) Do
    Begin
      Result := Chars(S[I]);
      If Result Then
        Break;
    End;
  End;
End;
Function StrContainsChars(Const S: string; Const Chars: array Of Char; CheckAll: Boolean): Boolean;
Var
  I: SizeInt;
Begin
  If CheckAll Then
  Begin
    Result := True;
    I := High(Chars);
    While (I >= 0) and Result Do
    Begin
      Result := CharPos(S, Chars[I]) > 0;
      Dec(I);
    End;
  End
  Else
  Begin
    Result := False;
    For I := 1 To Length(S) Do
    Begin
      Result := ArrayContainsChar(Chars, S[I]);
      If Result Then
        Break;
    End;
  End;
End;
Function StrIsAlphaNumUnderscore(Const S: string): Boolean;
Var
  I: SizeInt;
  C: Char;
Begin
  For I := 1 To Length(S) Do
  Begin
    C := S[I];
    If not (CharIsAlphaNum(C) or (C = '_')) Then
    Begin
      Result := False;
      Exit;
    End;
  End;
  Result := Length(S) > 0;
End;
Function StrIsDigit(Const S: string): Boolean;
Var
  I: SizeInt;
Begin
  Result := S <> '';
  For I := 1 To Length(S) Do
  Begin
    If not CharIsDigit(S[I]) Then
    Begin
      Result := False;
      Exit;
    End;
  End;
End;
Function StrIsSubset(Const S: string; Const ValidChars: TCharValidator): Boolean;
Var
  I: SizeInt;
Begin
  For I := 1 To Length(S) Do
  Begin
    Result := ValidChars(S[I]);
    If not Result Then
      Exit;
  End;
  Result := Length(S) > 0;
End;
Function StrIsSubset(Const S: string; Const ValidChars: array Of Char): Boolean;
Var
  I: SizeInt;
Begin
  For I := 1 To Length(S) Do
  Begin
    Result := ArrayContainsChar(ValidChars, S[I]);
    If not Result Then
      Exit;
  End;
  Result := Length(S) > 0;
End;
Function StrSame(Const S1, S2: string; CaseSensitive: Boolean): Boolean;
Begin
  Result := StrCompare(S1, S2, CaseSensitive) = 0;
End;
//=== String Transformation Routines =========================================
Function StrCenter(Const S: string; L: SizeInt; C: Char = ' '): string;
Begin
  If Length(S) < L Then
  Begin
    Result := StringOfChar(C, (L - Length(S)) div 2) + S;
    Result := Result + StringOfChar(C, L - Length(Result));
  End
  Else
    Result := S;
End;
Function StrCharPosLower(Const S: string; CharPos: SizeInt): string;
Begin
  Result := S;
  If (CharPos > 0) and (CharPos <= Length(S)) Then
    Result[CharPos] := CharLower(Result[CharPos]);
End;
Function StrCharPosUpper(Const S: string; CharPos: SizeInt): string;
Begin
  Result := S;
  If (CharPos > 0) and (CharPos <= Length(S)) Then
    Result[CharPos] := CharUpper(Result[CharPos]);
End;
Function StrDoubleQuote(Const S: string): string;
Begin
  Result := NativeDoubleQuote + S + NativeDoubleQuote;
End;
Function StrEnsureNoPrefix(Const Prefix, Text: string): string;
Var
  PrefixLen: SizeInt;
Begin
  PrefixLen := Length(Prefix);
  If Copy(Text, 1, PrefixLen) = Prefix Then
    Result := Copy(Text, PrefixLen + 1, Length(Text))
  Else
    Result := Text;
End;
Function StrEnsureNoSuffix(Const Suffix, Text: string): string;
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
Function StrEnsurePrefix(Const Prefix, Text: string): string;
Var
  PrefixLen: SizeInt;
Begin
  PrefixLen := Length(Prefix);
  If Copy(Text, 1, PrefixLen) = Prefix Then
    Result := Text
  Else
    Result := Prefix + Text;
End;
Function StrEnsureSuffix(Const Suffix, Text: string): string;
Var
  SuffixLen: SizeInt;
Begin
  SuffixLen := Length(Suffix);
  If Copy(Text, Length(Text) - SuffixLen + 1, SuffixLen) = Suffix Then
    Result := Text
  Else
    Result := Text + Suffix;
End;
Function StrEscapedToString(Const S: string): string;
  Procedure HandleHexEscapeSeq(Const S: string; Var I: SizeInt; Len: SizeInt; Var Dest: string);
  Const
    HexDigits = string('0123456789abcdefABCDEF');
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
      If Val > Ord(High(Char)) Then
        raise EJclStringError.CreateResFmt(@RsNumericConstantTooLarge, [Val, StartI]);
      Dest := Dest + Char(Val);
    End;
  End;
  Procedure HandleOctEscapeSeq(Const S: string; Var I: SizeInt; Len: SizeInt; Var Dest: string);
  Const
    OctDigits = string('01234567');
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
    If Val > Ord(High(Char)) Then
      raise EJclStringError.CreateResFmt(@RsNumericConstantTooLarge, [Val, StartI]);
    Dest := Dest + Char(Val);
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
          Result := Result + NativeBell;
        'b':
          Result := Result + NativeBackspace;
        'f':
          Result := Result + NativeFormFeed;
        'n':
          Result := Result + NativeLineFeed;
        'r':
          Result := Result + NativeCarriageReturn;
        't':
          Result := Result + NativeTab;
        'v':
          Result := Result + NativeVerticalTab;
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
            // '\x' at end of string is not escape sequence
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
Function StrLower(Const S: string): string;
Begin
  Result := S;
  StrLowerInPlace(Result);
End;
Procedure StrLowerInPlace(Var S: string);
{$IFDEF UNICODE_RTL_DATABASE}
Var
  P: PChar;
  I, L: SizeInt;
Begin
  L := Length(S);
  If L > 0 Then
  Begin
    UniqueString(S);
    P := PChar(S);
    For I := 1 To L Do
    Begin
      P^ := TCharacter.ToLower(P^);
      Inc(P);
    End;
  End;
End;
{$ELSE ~UNICODE_RTL_DATABASE}
Begin
  StrCase(S, StrLoOffset);
End;
{$ENDIF ~UNICODE_RTL_DATABASE}
Procedure StrLowerBuff(S: PChar);
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  If S <> nil Then
  Begin
    Repeat
      S^ := TCharacter.ToLower(S^);
      Inc(S);
    Until S^ = #0;
  End;
  {$ELSE ~UNICODE_RTL_DATABASE}
  StrCaseBuff(S, StrLoOffset);
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Procedure StrMove(Var Dest: string; Const Source: string;
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
  Move(Source[FromIndex], Dest[ToIndex], Count * SizeOf(Char));
End;
Function StrPadLeft(Const S: string; Len: SizeInt; C: Char): string;
Var
  L: SizeInt;
Begin
  L := Length(S);
  If L < Len Then
    Result := StringOfChar(C, Len - L) + S
  Else
    Result := S;
End;
Function StrPadRight(Const S: string; Len: SizeInt; C: Char): string;
Var
  L: SizeInt;
Begin
  L := Length(S);
  If L < Len Then
    Result := S + StringOfChar(C, Len - L)
  Else
    Result := S;
End;
Function StrProper(Const S: string): string;
Begin
  Result := StrLower(S);
  If Result <> '' Then
    Result[1] := UpCase(Result[1]);
End;
Procedure StrProperBuff(S: PChar);
Begin
  If (S <> nil) and (S^ <> #0) Then
  Begin
    StrLowerBuff(S);
    S^ := CharUpper(S^);
  End;
End;
Function StrQuote(Const S: string; C: Char): string;
Var
  L: SizeInt;
Begin
  L := Length(S);
  Result := S;
  If L > 0 Then
  Begin
    If Result[1] <> C Then
    Begin
      Result := C + Result;
      Inc(L);
    End;
    If Result[L] <> C Then
      Result := Result + C;
  End;
End;
Function StrRemoveChars(Const S: string; Const Chars: TCharValidator): string;
Var
  Source, Dest: PChar;
  Len, Index:   SizeInt;
Begin
  Len := Length(S);
  SetLength(Result, Len);
  UniqueString(Result);
  Source := PChar(S);
  Dest := PChar(Result);
  For Index := 0 To Len - 1 Do
  Begin
    If not Chars(Source^) Then
    Begin
      Dest^ := Source^;
      Inc(Dest);
    End;
    Inc(Source);
  End;
  SetLength(Result, Dest - PChar(Result));
End;
Function StrRemoveChars(Const S: string; Const Chars: array Of Char): string;
Var
  Source, Dest: PChar;
  Len, Index:   SizeInt;
Begin
  Len := Length(S);
  SetLength(Result, Len);
  UniqueString(Result);
  Source := PChar(S);
  Dest := PChar(Result);
  For Index := 0 To Len - 1 Do
  Begin
    If not ArrayContainsChar(Chars, Source^) Then
    Begin
      Dest^ := Source^;
      Inc(Dest);
    End;
    Inc(Source);
  End;
  SetLength(Result, Dest - PChar(Result));
End;
Function StrRemoveLeadingChars(Const S: string; Const Chars: TCharValidator): string;
Var
  Len : SizeInt;
  I: SizeInt;
Begin
  Len := Length(S);
  I := 1;
  While (I <= Len) and Chars(s[I]) Do
    Inc(I);
  Result := Copy (s, I, Len-I+1);
End;
Function StrRemoveLeadingChars(Const S: string; Const Chars: array Of Char): string;
Var
  Len : SizeInt;
  I: SizeInt;
Begin
  Len := Length(S);
  I := 1;
  While (I <= Len) and ArrayContainsChar(Chars, s[I]) Do
    Inc(I);
  Result := Copy (s, I, Len-I+1);
End;
Function StrRemoveEndChars(Const S: string; Const Chars: TCharValidator): string;
Var
  Len :   SizeInt;
Begin
  Len := Length(S);
  While (Len > 0) and Chars(s[Len]) Do
    Dec(Len);
  Result := Copy (s, 1, Len);
End;
Function StrRemoveEndChars(Const S: string; Const Chars: array Of Char): string;
Var
  Len :   SizeInt;
Begin
  Len := Length(S);
  While (Len > 0) and ArrayContainsChar(Chars, s[Len]) Do
    Dec(Len);
  Result := Copy (s, 1, Len);
End;
Function StrKeepChars(Const S: string; Const Chars: TCharValidator): string;
Var
  Source, Dest: PChar;
  Len, Index:   SizeInt;
Begin
  Len := Length(S);
  SetLength(Result, Len);
  UniqueString(Result);
  Source := PChar(S);
  Dest := PChar(Result);
  For Index := 0 To Len - 1 Do
  Begin
    If Chars(Source^) Then
    Begin
      Dest^ := Source^;
      Inc(Dest);
    End;
    Inc(Source);
  End;
  SetLength(Result, Dest - PChar(Result));
End;
Function StrKeepChars(Const S: string; Const Chars: array Of Char): string;
Var
  Source, Dest: PChar;
  Len, Index:   SizeInt;
Begin
  Len := Length(S);
  SetLength(Result, Len);
  UniqueString(Result);
  Source := PChar(S);
  Dest := PChar(Result);
  For Index := 0 To Len - 1 Do
  Begin
    If ArrayContainsChar(Chars, Source^) Then
    Begin
      Dest^ := Source^;
      Inc(Dest);
    End;
    Inc(Source);
  End;
  SetLength(Result, Dest - PChar(Result));
End;
Function StrRepeat(Const S: string; Count: SizeInt): string;
Var
  Len, Index: SizeInt;
  Dest, Source: PChar;
Begin
  Len := Length(S);
  SetLength(Result, Count * Len);
  Dest := PChar(Result);
  Source := PChar(S);
  If Dest <> nil Then
    For Index := 0 To Count - 1 Do
    Begin
      Move(Source^, Dest^, Len * SizeOf(Char));
      Inc(Dest, Len);
    End;
End;
Procedure StrReplace(Var S: string; Const Search, Replace: string; Flags: TReplaceFlags);
Var
  SearchStr: string;
  ResultStr: string; { result string }
  SourcePtr: PChar;      { pointer into S of character under examination }
  SourceMatchPtr: PChar; { pointers into S and Search when first character has }
  SearchMatchPtr: PChar; { been matched and we're probing for a complete match }
  ResultPtr: PChar;      { pointer into Result of character being written }
  ResultIndex,
  SearchLength,          { length of search string }
  ReplaceLength,         { length of replace string }
  BufferLength,          { length of temporary result buffer }
  ResultLength: SizeInt; { length of result string }
  C: Char;               { first character of search string }
  IgnoreCase: Boolean;
Begin
  If Search = '' Then
  Begin
    If S = '' Then
    Begin
      S := Replace;
      Exit;
    End
    Else
      raise EJclStringError.CreateRes(@RsBlankSearchString);
  End;
  If S <> '' Then
  Begin
    IgnoreCase := rfIgnoreCase in Flags;
    If IgnoreCase Then
      SearchStr := StrUpper(Search)
    Else
      SearchStr := Search;
    { avoid having to call Length() within the loop }
    SearchLength := Length(Search);
    ReplaceLength := Length(Replace);
    ResultLength := Length(S);
    BufferLength := ResultLength;
    SetLength(ResultStr, BufferLength);
    { get pointers to begin of source and result }
    ResultPtr := PChar(ResultStr);
    SourcePtr := PChar(S);
    C := SearchStr[1];
    { while we haven't reached the end of the string }
    While True Do
    Begin
      { copy characters until we find the first character of the search string }
      If IgnoreCase Then
        While (CharUpper(SourcePtr^) <> C) and (SourcePtr^ <> #0) Do
        Begin
          ResultPtr^ := SourcePtr^;
          Inc(ResultPtr);
          Inc(SourcePtr);
        End
      Else
        While (SourcePtr^ <> C) and (SourcePtr^ <> #0) Do
        Begin
          ResultPtr^ := SourcePtr^;
          Inc(ResultPtr);
          Inc(SourcePtr);
        End;
      { did we find that first character or did we hit the end of the string? }
      If SourcePtr^ = #0 Then
        Break
      Else
      Begin
        { continue comparing, +1 because first character was matched already }
        SourceMatchPtr := SourcePtr + 1;
        SearchMatchPtr := PChar(SearchStr) + 1;
        If IgnoreCase Then
          While (CharUpper(SourceMatchPtr^) = SearchMatchPtr^) and (SearchMatchPtr^ <> #0) Do
          Begin
            Inc(SourceMatchPtr);
            Inc(SearchMatchPtr);
          End
        Else
          While (SourceMatchPtr^ = SearchMatchPtr^) and (SearchMatchPtr^ <> #0) Do
          Begin
            Inc(SourceMatchPtr);
            Inc(SearchMatchPtr);
          End;
        { did we find a complete match? }
        If SearchMatchPtr^ = #0 Then
        Begin
          // keep track of result length
          Inc(ResultLength, ReplaceLength - SearchLength);
          If ReplaceLength > 0 Then
          Begin
            // increase buffer size if required
            If ResultLength > BufferLength Then
            Begin
              BufferLength := ResultLength * 2;
              ResultIndex := ResultPtr - PChar(ResultStr) + 1;
              SetLength(ResultStr, BufferLength);
              ResultPtr := @ResultStr[ResultIndex];
            End;
            { append replace to result and move past the search string in source }
            Move((@Replace[1])^, ResultPtr^, ReplaceLength * SizeOf(Char));
          End;
          Inc(SourcePtr, SearchLength);
          Inc(ResultPtr, ReplaceLength);
          { replace all instances or just one? }
          If not (rfReplaceAll in Flags) Then
          Begin
            { just one, copy until end of source and break out of loop }
            While SourcePtr^ <> #0 Do
            Begin
              ResultPtr^ := SourcePtr^;
              Inc(ResultPtr);
              Inc(SourcePtr);
            End;
            Break;
          End;
        End
        Else
        Begin
          { copy current character and start over with the next }
          ResultPtr^ := SourcePtr^;
          Inc(ResultPtr);
          Inc(SourcePtr);
        End;
      End;
    End;
    { set result length and copy result into S }
    SetLength(ResultStr, ResultLength);
    S := ResultStr;
  End;
End;
Function StrReplaceChar(Const S: string; Const Source, Replace: Char): string;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If Result[I] = Source Then
      Result[I] := Replace;
End;
Function StrReplaceChars(Const S: string; Const Chars: TCharValidator; Replace: Char): string;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If Chars(Result[I]) Then
      Result[I] := Replace;
End;
Function StrReplaceChars(Const S: string; Const Chars: array Of Char; Replace: Char): string;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If ArrayContainsChar(Chars, Result[I]) Then
      Result[I] := Replace;
End;
Function StrReplaceButChars(Const S: string; Const Chars: TCharValidator;
  Replace: Char): string;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If not Chars(Result[I]) Then
      Result[I] := Replace;
End;
Function StrReplaceButChars(Const S: string; Const Chars: array Of Char; Replace: Char): string;
Var
  I: SizeInt;
Begin
  Result := S;
  For I := 1 To Length(S) Do
    If not ArrayContainsChar(Chars, Result[I]) Then
      Result[I] := Replace;
End;
Function StrReverse(Const S: string): string;
Begin
  Result := S;
  StrReverseInplace(Result);
End;
Procedure StrReverseInPlace(Var S: string);
{ TODO -oahuser : Warning: This is dangerous for unicode surrogates }
Var
  P1, P2: PChar;
  C: Char;
Begin
  UniqueString(S);
  P1 := PChar(S);
  P2 := P1 + (Length(S) - 1);
  While P1 < P2 Do
  Begin
    C := P1^;
    P1^ := P2^;
    P2^ := C;
    Inc(P1);
    Dec(P2);
  End;
End;
Function StrSingleQuote(Const S: string): string;
Begin
  Result := NativeSingleQuote + S + NativeSingleQuote;
End;
Procedure StrSkipChars(Var S: PChar; Const Chars: TCharValidator);
Begin
  While Chars(S^) Do
    Inc(S);
End;
Procedure StrSkipChars(Var S: PChar; Const Chars: array Of Char);
Begin
  While ArrayContainsChar(Chars, S^) Do
    Inc(S);
End;
Procedure StrSkipChars(Const S: string; Var Index: SizeInt; Const Chars: TCharValidator);
Begin
  While Chars(S[Index]) Do
    Inc(Index);
End;
Procedure StrSkipChars(Const S: string; Var Index: SizeInt; Const Chars: array Of Char);
Begin
  While ArrayContainsChar(Chars, S[Index]) Do
    Inc(Index);
End;
Function StrSmartCase(Const S: string; Const Delimiters: TCharValidator): string;
Var
  Source, Dest: PChar;
  Index, Len:   SizeInt;
  InternalDelimiters: TCharValidator;
Begin
  Result := '';
  If Assigned(Delimiters) Then
    InternalDelimiters := Delimiters
  Else
    InternalDelimiters := CharIsSpace;
  If S <> '' Then
  Begin
    Result := S;
    UniqueString(Result);
    Len := Length(S);
    Source := PChar(S);
    Dest := PChar(Result);
    Inc(Dest);
    For Index := 2 To Len Do
    Begin
      If InternalDelimiters(Source^) and not InternalDelimiters(Dest^) Then
        Dest^ := CharUpper(Dest^);
      Inc(Dest);
      Inc(Source);
    End;
    Result[1] := CharUpper(Result[1]);
  End;
End;
Function StrSmartCase(Const S: string; Const Delimiters: array Of Char): string;
Var
  Source, Dest: PChar;
  Index, Len:   SizeInt;
Begin
  Result := '';
  If S <> '' Then
  Begin
    Result := S;
    UniqueString(Result);
    Len := Length(S);
    Source := PChar(S);
    Dest := PChar(Result);
    Inc(Dest);
    For Index := 2 To Len Do
    Begin
      If ArrayContainsChar(Delimiters, Source^) and not ArrayContainsChar(Delimiters, Dest^) Then
        Dest^ := CharUpper(Dest^);
      Inc(Dest);
      Inc(Source);
    End;
    Result[1] := CharUpper(Result[1]);
  End;
End;
Function StrStringToEscaped(Const S: string): string;
Var
  I: SizeInt;
Begin
  Result := '';
  For I := 1 To Length(S) Do
  Begin
    Case S[I] Of
      NativeBackspace:
        Result := Result + '\b';
      NativeBell:
        Result := Result + '\a';
      NativeCarriageReturn:
        Result := Result + '\r';
      NAtiveFormFeed:
        Result := Result + '\f';
      NativeLineFeed:
        Result := Result + '\n';
      NativeTab:
        Result := Result + '\t';
      NativeVerticalTab:
        Result := Result + '\v';
      NativeBackSlash:
        Result := Result + '\\';
      NativeDoubleQuote:
        Result := Result + '\"';
    Else
      // Characters < ' ' are escaped with hex sequence
      If S[I] < #32 Then
        Result := Result + Format('\x%.2x', [SizeInt(S[I])])
      Else
        Result := Result + S[I];
    End;
  End;
End;
Function StrStripNonNumberChars(Const S: string): string;
Var
  I: SizeInt;
  C: Char;
Begin
  Result := '';
  For I := 1 To Length(S) Do
  Begin
    C := S[I];
    If CharIsNumberChar(C) Then
      Result := Result + C;
  End;
End;
Function StrToHex(Const Source: string): string;
Var
  Index: SizeInt;
  C, L, N: SizeInt;
  BL, BH: Byte;
  S:     string;
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
      Result[N] := Char((BH shl 4) or BL);
      Inc(N);
    End;
  End;
End;
Function StrTrimCharLeft(Const S: string; C: Char): string;
Var
  I, L: SizeInt;
Begin
  I := 1;
  L := Length(S);
  While (I <= L) and (S[I] = C) Do
    Inc(I);
  Result := Copy(S, I, L - I + 1);
End;
Function StrTrimCharsLeft(Const S: string; Const Chars: TCharValidator): string;
Var
  I, L: SizeInt;
Begin
  I := 1;
  L := Length(S);
  While (I <= L) and Chars(S[I]) Do
    Inc(I);
  Result := Copy(S, I, L - I + 1);
End;
Function StrTrimCharsLeft(Const S: string; Const Chars: array Of Char): string;
Var
  I, L: SizeInt;
Begin
  I := 1;
  L := Length(S);
  While (I <= L) and ArrayContainsChar(Chars, S[I]) Do
    Inc(I);
  Result := Copy(S, I, L - I + 1);
End;
Function StrTrimCharRight(Const S: string; C: Char): string;
Var
  I: SizeInt;
Begin
  I := Length(S);
  While (I >= 1) and (S[I] = C) Do
    Dec(I);
  Result := Copy(S, 1, I);
End;
Function StrTrimCharsRight(Const S: string; Const Chars: TCharValidator): string;
Var
  I: SizeInt;
Begin
  I := Length(S);
  While (I >= 1) and Chars(S[I]) Do
    Dec(I);
  Result := Copy(S, 1, I);
End;
Function StrTrimCharsRight(Const S: string; Const Chars: array Of Char): string;
Var
  I: SizeInt;
Begin
  I := Length(S);
  While (I >= 1) and ArrayContainsChar(Chars, S[I]) Do
    Dec(I);
  Result := Copy(S, 1, I);
End;
Function StrTrimQuotes(Const S: string): string;
Var
  First, Last: Char;
  L: SizeInt;
Begin
  L := Length(S);
  If L > 1 Then
  Begin
    First := S[1];
    Last := S[L];
    If (First = Last) and ((First = NativeSingleQuote) or (First = NativeDoubleQuote)) Then
      Result := Copy(S, 2, L - 2)
    Else
      Result := S;
  End
  Else
    Result := S;
End;
Function StrUpper(Const S: string): string;
Begin
  Result := S;
  StrUpperInPlace(Result);
End;
Procedure StrUpperInPlace(Var S: string);
{$IFDEF UNICODE_RTL_DATABASE}
Var
  P: PChar;
  I, L: SizeInt;
Begin
  L := Length(S);
  If L > 0 Then
  Begin
    UniqueString(S);
    P := PChar(S);
    For I := 1 To L Do
    Begin
      P^ := TCharacter.ToUpper(P^);
      Inc(P);
    End;
  End;
End;
{$ELSE ~UNICODE_RTL_DATABASE}
Begin
  StrCase(S, StrUpOffset);
End;
{$ENDIF ~UNICODE_RTL_DATABASE}
Procedure StrUpperBuff(S: PChar);
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  If S <> nil Then
  Begin
    Repeat
      S^ := TCharacter.ToUpper(S^);
      Inc(S);
    Until S^ = #0;
  End;
  {$ELSE ~UNICODE_RTL_DATABASE}
  StrCaseBuff(S, StrUpOffset);
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
//=== String Management ======================================================
Procedure StrAddRef(Var S: string);
Var
  P: PStrRec;
Begin
  P := Pointer(S);
  If P <> nil Then
  Begin
    Dec(P);
    If P^.RefCount = -1 Then
      UniqueString(S);
  End;
End;
Procedure StrDecRef(Var S: string);
Var
  P: PStrRec;
Begin
  P := Pointer(S);
  If P <> nil Then
  Begin
    Dec(P);
    Case P^.RefCount Of
      -1, 0: { nothing } ;
      1:
        Begin
          Finalize(S);
          Pointer(S) := nil;
        End;
    End;
  End;
End;
Function StrLength(Const S: string): SizeInt;
Var
  P: PStrRec;
Begin
  Result := 0;
  P := Pointer(S);
  If P <> nil Then
  Begin
    Dec(P);
    Result := P^.Length and (not $80000000 shr 1);
  End;
End;
Function StrRefCount(Const S: string): SizeInt;
Var
  P: PStrRec;
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
Function StrCharCount(Const S: string; C: Char): SizeInt;
Var
  I: SizeInt;
Begin
  Result := 0;
  For I := 1 To Length(S) Do
    If S[I] = C Then
      Inc(Result);
End;
Function StrCharsCount(Const S: string; Const Chars: TCharValidator): SizeInt;
Var
  I: SizeInt;
Begin
  Result := 0;
  For I := 1 To Length(S) Do
    If Chars(S[I]) Then
      Inc(Result);
End;
Function StrCharsCount(Const S: string; Const Chars: array Of Char): SizeInt;
Var
  I: SizeInt;
Begin
  Result := 0;
  For I := 1 To Length(S) Do
    If ArrayContainsChar(Chars, S[I]) Then
      Inc(Result);
End;
Function StrStrCount(Const S, SubS: string): SizeInt;
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
Function StrCompareRangeEx(Const S1, S2: string; Index, Count: SizeInt; CaseSensitive: Boolean): SizeInt;
Var
  Len1, Len2: SizeInt;
  I: SizeInt;
  C1, C2: Char;
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
          C1 := S1[Index + I];
          C2 := S2[Index + I];
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
          C1 := S1[Index + I];
          C2 := S2[Index + I];
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
Function StrCompare(Const S1, S2: string; CaseSensitive: Boolean): SizeInt;
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
Function StrCompareRange(Const S1, S2: string; Index, Count: SizeInt; CaseSensitive: Boolean): SizeInt;
Begin
  Result := StrCompareRangeEx(S1, S2, Index, Count, CaseSensitive);
End;
Procedure StrFillChar(Var S; Count: SizeInt; C: Char);
Begin
  If Count > 0 Then
    FillChar(S, Count, C);
End;
Function StrRepeatChar(C: Char; Count: SizeInt): string;
Begin
  SetLength(Result, Count);
  If Count > 0 Then
    StrFillChar(Result[1], Count, C);
End;
Function StrFind(Const Substr, S: string; Const Index: SizeInt): SizeInt;
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
Function StrHasPrefix(Const S: string; Const Prefixes: array Of string): Boolean;
Begin
  Result := StrPrefixIndex(S, Prefixes) > -1;
End;
Function StrHasSuffix(Const S: string; Const Suffixes: array Of string): Boolean;
Begin
  Result := StrSuffixIndex(S, Suffixes) > -1;
End;
Function StrIndex(Const S: string; Const List: array Of string; CaseSensitive: Boolean): SizeInt;
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
Function StrIHasPrefix(Const S: string; Const Prefixes: array Of string): Boolean;
Begin
  Result := StrIPrefixIndex(S, Prefixes) > -1;
End;
Function StrIHasSuffix(Const S: string; Const Suffixes: array Of string): Boolean;
Begin
  Result := StrISuffixIndex(S, Suffixes) > -1;
End;
Function StrILastPos(Const SubStr, S: string): SizeInt;
Begin
  Result := StrLastPos(StrUpper(SubStr), StrUpper(S));
End;
Function StrIPos(Const SubStr, S: string): SizeInt;
Begin
  Result := Pos(StrUpper(SubStr), StrUpper(S));
End;
Function StrIPrefixIndex(Const S: string; Const Prefixes: array Of string): SizeInt;
Var
  I: SizeInt;
  Test: string;
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
Function StrIsOneOf(Const S: string; Const List: array Of string): Boolean;
Begin
  Result := StrIndex(S, List) > -1;
End;
Function StrISuffixIndex(Const S: string; Const Suffixes: array Of string): SizeInt;
Var
  I: SizeInt;
  Test: string;
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
Function StrLastPos(Const SubStr, S: string): SizeInt;
Var
  Last, Current: PChar;
Begin
  Result := 0;
  Last := nil;
  Current := PChar(S);
  While (Current <> nil) and (Current^ <> #0) Do
  Begin
    Current := StrPos(PChar(Current), PChar(SubStr));
    If Current <> nil Then
    Begin
      Last := Current;
      Inc(Current);
    End;
  End;
  If Last <> nil Then
    Result := Abs(PChar(S) - Last) + 1;
End;
// IMPORTANT NOTE: The StrMatch function does currently not work with the Asterix (*)
// (*) acts like (?)
Function StrMatch(Const Substr, S: string; Index: SizeInt): SizeInt;
Var
  SI, SubI, SLen, SubLen: SizeInt;
  SubC: Char;
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
      SubC := Substr[SubI];
      If (SubC = '*') or (SubC = '?') or (SubC = S[SI]) Then
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
// Derived from "Like" by Michael Winter
Function StrMatches(Const Substr, S: string; Const Index: SizeInt): Boolean;
Var
  StringPtr: PChar;
  PatternPtr: PChar;
  StringRes: PChar;
  PatternRes: PChar;
Begin
  If SubStr = '' Then
    raise EJclStringError.CreateRes(@RsBlankSearchString);
  Result := SubStr = '*';
  If Result or (S = '') Then
    Exit;
  If (Index <= 0) or (Index > Length(S)) Then
    raise EJclStringError.CreateRes(@RsArgumentOutOfRange);
  StringPtr := PChar(@S[Index]);
  PatternPtr := PChar(SubStr);
  StringRes := nil;
  PatternRes := nil;
  Repeat
    Repeat
      Case PatternPtr^ Of
        #0:
        Begin
          Result := StringPtr^ = #0;
          If Result or (StringRes = nil) or (PatternRes = nil) Then
            Exit;
          StringPtr := StringRes;
          PatternPtr := PatternRes;
          Break;
        End;
        '*':
        Begin
          Inc(PatternPtr);
          PatternRes := PatternPtr;
          Break;
        End;
        '?':
        Begin
          If StringPtr^ = #0 Then
            Exit;
          Inc(StringPtr);
          Inc(PatternPtr);
        End;
      Else
      Begin
        If StringPtr^ = #0 Then
          Exit;
        If StringPtr^ <> PatternPtr^ Then
        Begin
          If (StringRes = nil) or (PatternRes = nil) Then
            Exit;
          StringPtr := StringRes;
          PatternPtr := PatternRes;
          Break;
        End
        Else
        Begin
          Inc(StringPtr);
          Inc(PatternPtr);
        End;
      End;
      End;
    Until False;
    Repeat
      Case PatternPtr^ Of
        #0:
        Begin
          Result := True;
          Exit;
        End;
        '*':
        Begin
          Inc(PatternPtr);
          PatternRes := PatternPtr;
        End;
        '?':
        Begin
          If StringPtr^ = #0 Then
            Exit;
          Inc(StringPtr);
          Inc(PatternPtr);
        End;
      Else
      Begin
        Repeat
          If StringPtr^ = #0 Then
            Exit;
          If StringPtr^ = PatternPtr^ Then
            Break;
          Inc(StringPtr);
        Until False;
        Inc(StringPtr);
        StringRes := StringPtr;
        Inc(PatternPtr);
        Break;
      End;
      End;
    Until False;
  Until False;
End;
Function StrNPos(Const S, SubStr: string; N: SizeInt): SizeInt;
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
Function StrNIPos(Const S, SubStr: string; N: SizeInt): SizeInt;
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
Function StrPrefixIndex(Const S: string; Const Prefixes: array Of string): SizeInt;
Var
  I: SizeInt;
  Test: string;
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
Function StrSearch(Const Substr, S: string; Const Index: SizeInt): SizeInt;
Var
  SP, SPI, SubP: PChar;
  SLen: SizeInt;
Begin
  SLen := Length(S);
  If Index <= SLen Then
  Begin
    SP := PChar(S);
    SubP := PChar(Substr);
    SPI := SP;
    Inc(SPI, Index);
    Dec(SPI);
    SPI := StrPos(SPI, SubP);
    If SPI <> nil Then
      Result := SPI - SP + 1
    Else
      Result := 0;
  End
  Else
    Result := 0;
End;
Function StrSuffixIndex(Const S: string; Const Suffixes: array Of string): SizeInt;
Var
  I: SizeInt;
  Test: string;
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
Function StrAfter(Const SubStr, S: string): string;
Var
  P: SizeInt;
Begin
  P := StrFind(SubStr, S, 1); // StrFind is case-insensitive pos
  If P <= 0 Then
    Result := ''           // substr not found -> nothing after it
  Else
    Result := StrRestOf(S, P + Length(SubStr));
End;
Function StrBefore(Const SubStr, S: string): string;
Var
  P: SizeInt;
Begin
  P := StrFind(SubStr, S, 1);
  If P <= 0 Then
    Result := S
  Else
    Result := StrLeft(S, P - 1);
End;
Function StrSplit(Const SubStr, S: string;Var Left, Right : string): boolean;
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
Function StrBetween(Const S: string; Const Start, Stop: Char): string;
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
Function StrChopRight(Const S: string; N: SizeInt): string;
Begin
  Result := Copy(S, 1, Length(S) - N);
End;
Function StrLeft(Const S: string; Count: SizeInt): string;
Begin
  Result := Copy(S, 1, Count);
End;
Function StrMid(Const S: string; Start, Count: SizeInt): string;
Begin
  Result := Copy(S, Start, Count);
End;
Function StrRestOf(Const S: string; N: SizeInt): string;
Begin
  Result := Copy(S, N, (Length(S) - N + 1));
End;
Function StrRight(Const S: string; Count: SizeInt): string;
Begin
  Result := Copy(S, Length(S) - Count + 1, Count);
End;
//=== Character (do we have it ;) ============================================
Function CharEqualNoCase(Const C1, C2: Char): Boolean;
Begin
  //if they are not equal chars, may be same letter different case
  Result := (C1 = C2) or
    (CharIsAlpha(C1) and CharIsAlpha(C2) and (CharLower(C1) = CharLower(C2)));
End;

Function CharIsAlpha(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsLetter(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := (StrCharTypes[C] and C1_ALPHA) <> 0;
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsAlphaNum(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsLetterOrDigit(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := ((StrCharTypes[C] and C1_ALPHA) <> 0) or ((StrCharTypes[C] and C1_DIGIT) <> 0);
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsBlank(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  //http://blogs.msdn.com/b/michkap/archive/2007/06/11/3230072.aspx
  Result := (C = ' ') or (C = #$0009) or (C = #$00A0) or (C = #$3000);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := ((StrCharTypes[C] and C1_BLANK) <> 0);
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsControl(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsControl(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := (StrCharTypes[C] and C1_CNTRL) <> 0;
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsDelete(Const C: Char): Boolean;
Begin
  Result := (C = #8);
End;
Function CharIsDigit(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsDigit(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := (StrCharTypes[C] and C1_DIGIT) <> 0;
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsFracDigit(Const C: Char): Boolean;
Begin
  Result := (C = '.') or CharIsDigit(C);
End;
Function CharIsHexDigit(Const C: Char): Boolean;
Begin
  Case C Of
    'A'..'F',
    'a'..'f':
      Result := True;
  Else
    Result := CharIsDigit(C);
  End;
End;
Function CharIsLower(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsLower(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := (StrCharTypes[C] and C1_LOWER) <> 0;
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsNumberChar(Const C: Char): Boolean;
Begin
  Result := CharIsDigit(C) or (C = '+') or (C = '-') or (C = RESTDWDecimalSeparator);
End;
Function CharIsNumber(Const C: Char): Boolean;
Begin
  Result := CharIsDigit(C) or (C = RESTDWDecimalSeparator);
End;
Function CharIsPrintable(Const C: Char): Boolean;
Begin
  Result := not CharIsControl(C);
End;
Function CharIsPunctuation(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsPunctuation(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := ((StrCharTypes[C] and C1_PUNCT) <> 0);
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsReturn(Const C: Char): Boolean;
Begin
  Result := (C = NativeLineFeed) or (C = NativeCarriageReturn);
End;
Function CharIsSpace(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsWhiteSpace(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := (StrCharTypes[C] and C1_SPACE) <> 0;
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsUpper(Const C: Char): Boolean;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsUpper(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := (StrCharTypes[C] and C1_UPPER) <> 0;
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharIsValidIdentifierLetter(Const C: Char): Boolean;
Begin
  Case C Of
    {$IFDEF SUPPORTS_UNICODE}
    // from XML specifications
    #$00C0..#$00D6, #$00D8..#$00F6, #$00F8..#$02FF, #$0370..#$037D,
    #$037F..#$1FFF, #$200C..#$200D, #$2070..#$218F, #$2C00..#$2FEF,
    #$3001..#$D7FF, #$F900..#$FDCF, #$FDF0..#$FFFD, // #$10000..#$EFFFF, howto match surrogate pairs?
    #$00B7, #$0300..#$036F, #$203F..#$2040,
    {$ENDIF SUPPORTS_UNICODE}
    '0'..'9', 'A'..'Z', 'a'..'z', '_':
      Result := True;
  Else
    Result := False;
  End;
End;
Function CharIsWhiteSpace(Const C: Char): Boolean;
Begin
  Case C Of
    NativeTab,
    NativeLineFeed,
    NativeVerticalTab,
    NativeFormFeed,
    NativeCarriageReturn,
    NativeSpace:
      Result := True;
  Else
    Result := False;
  End;
End;
Function CharIsWildcard(Const C: Char): Boolean;
Begin
  Case C Of
    '*', '?':
      Result := True;
  Else
    Result := False;
  End;
End;
Function CharType(Const C: Char): Word;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  GetStringTypeEx(LOCALE_USER_DEFAULT, CT_CTYPE1, @C, 1, Result);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := StrCharTypes[C];
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
//=== PCharVector ============================================================
Function StringsToPCharVector(Var Dest: PCharVector; Const Source: TStrings): PCharVector;
Var
  I: SizeInt;
  S: string;
  List: array Of PChar;
Begin
  Assert(Source <> nil);
  Dest := AllocMem((Source.Count + SizeOf(Char)) * SizeOf(PChar));
  SetLength(List, Source.Count + SizeOf(Char));
  For I := 0 To Source.Count - 1 Do
  Begin
    S := Source[I];
    List[I] := StrAlloc(Length(S) + SizeOf(Char));
    StrPCopy(List[I], S);
  End;
  List[Source.Count] := nil;
  Move(List[0], Dest^, (Source.Count + 1) * SizeOf(PChar));
  Result := Dest;
End;
Function PCharVectorCount(Source: PCharVector): SizeInt;
Begin
  Result := 0;
  If Source <> nil Then
  Begin
    While Source^ <> nil Do
    Begin
      Inc(Source);
      Inc(Result);
    End;
  End;
End;
Procedure PCharVectorToStrings(Const Dest: TStrings; Source: PCharVector);
Var
  I, Count: SizeInt;
  List:     array Of PChar;
Begin
  Assert(Dest <> nil);
  If Source <> nil Then
  Begin
    Count := PCharVectorCount(Source);
    SetLength(List, Count);
    Move(Source^, List[0], Count * SizeOf(PChar));
    Dest.BeginUpdate;
    Try
      Dest.Clear;
      For I := 0 To Count - 1 Do
        Dest.Add(List[I]);
    Finally
      Dest.EndUpdate;
    End;
  End;
End;
Procedure FreePCharVector(Var Dest: PCharVector);
Var
  I, Count: SizeInt;
  List:     array Of PChar;
Begin
  If Dest <> nil Then
  Begin
    Count := PCharVectorCount(Dest);
    SetLength(List, Count);
    Move(Dest^, List[0], Count * SizeOf(PChar));
    For I := 0 To Count - 1 Do
      StrDispose(List[I]);
    FreeMem(Dest, (Count + 1) * SizeOf(PChar));
    Dest := nil;
  End;
End;
//=== Character Transformation Routines ======================================
Function CharHex(Const C: Char): Byte;
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
Function CharLower(Const C: Char): Char;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.ToLower(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := StrCaseMap[Ord(C) + StrLoOffset];
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharToggleCase(Const C: Char): Char;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  If CharIsLower(C) Then
    Result := CharUpper(C)
  Else If CharIsUpper(C) Then
    Result := CharLower(C)
  Else
    Result := C;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := StrCaseMap[Ord(C) + StrReOffset];
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
Function CharUpper(Const C: Char): Char;
Begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.ToUpper(C);
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := StrCaseMap[Ord(C) + StrUpOffset];
  {$ENDIF ~UNICODE_RTL_DATABASE}
End;
//=== Character Search and Replace ===========================================
Function CharLastPos(Const S: string; Const C: Char; Const Index: SizeInt): SizeInt;
Begin
  If (Index > 0) and (Index <= Length(S)) Then
  Begin
    For Result := Length(S) Downto Index Do
      If S[Result] = C Then
        Exit;
  End;
  Result := 0;
End;
Function CharPos(Const S: string; Const C: Char; Const Index: SizeInt): SizeInt;
Begin
  If (Index > 0) and (Index <= Length(S)) Then
  Begin
    For Result := Index To Length(S) Do
      If S[Result] = C Then
        Exit;
  End;
  Result := 0;
End;
Function CharIPos(Const S: string; C: Char; Const Index: SizeInt): SizeInt;
Begin
  If (Index > 0) and (Index <= Length(S)) Then
  Begin
    C := CharUpper(C);
    For Result := Index To Length(S) Do
      If CharUpper(S[Result]) = C Then
        Exit;
  End;
  Result := 0;
End;
Function CharReplace(Var S: string; Const Search, Replace: Char): SizeInt;
Var
  P: PChar;
  Index, Len: SizeInt;
Begin
  Result := 0;
  If Search <> Replace Then
  Begin
    UniqueString(S);
    P := PChar(S);
    Len := Length(S);
    For Index := 0 To Len - 1 Do
    Begin
      If P^ = Search Then
      Begin
        P^ := Replace;
        Inc(Result);
      End;
      Inc(P);
    End;
  End;
End;
//=== MultiSz ================================================================
Function StringsToMultiSz(Var Dest: PMultiSz; Const Source: TStrings): PMultiSz;
Var
  I, TotalLength: SizeInt;
  P: PMultiSz;
Begin
  Assert(Source <> nil);
  TotalLength := 1;
  For I := 0 To Source.Count - 1 Do
    If Source[I] = '' Then
      raise EJclStringError.CreateRes(@RsInvalidEmptyStringItem)
    Else
      Inc(TotalLength, StrLen(PChar(Source[I])) + 1);
  AllocateMultiSz(Dest, TotalLength);
  P := Dest;
  For I := 0 To Source.Count - 1 Do
  Begin
    P := StrECopy(P, PChar(Source[I]));
    Inc(P);
  End;
  P^ := #0;
  Result := Dest;
End;
Procedure MultiSzToStrings(Const Dest: TStrings; Const Source: PMultiSz);
Var
  P: PMultiSz;
Begin
  Assert(Dest <> nil);
  Dest.BeginUpdate;
  Try
    Dest.Clear;
    If Source <> nil Then
    Begin
      P := Source;
      While P^ <> #0 Do
      Begin
        Dest.Add(P);
        P := StrEnd(P);
        Inc(P);
      End;
    End;
  Finally
    Dest.EndUpdate;
  End;
End;
Function MultiSzLength(Const Source: PMultiSz): SizeInt;
Var
  P: PMultiSz;
Begin
  Result := 0;
  If Source <> nil Then
  Begin
    P := Source;
    Repeat
      Inc(Result, StrLen(P) + 1);
      P := StrEnd(P);
      Inc(P);
    Until P^ = #0;
    Inc(Result);
  End;
End;
Procedure AllocateMultiSz(Var Dest: PMultiSz; Len: SizeInt);
Begin
  If Len > 0 Then
    GetMem(Dest, Len * SizeOf(Char))
  Else
    Dest := nil;
End;
Procedure FreeMultiSz(Var Dest: PMultiSz);
Begin
  If Dest <> nil Then
    FreeMem(Dest);
  Dest := nil;
End;
Function MultiSzDup(Const Source: PMultiSz): PMultiSz;
Var
  Len: SizeInt;
Begin
  If Source <> nil Then
  Begin
    Len := MultiSzLength(Source);
    Result := nil;
    AllocateMultiSz(Result, Len);
    Move(Source^, Result^, Len * SizeOf(Char));
  End
  Else
    Result := nil;
End;
Procedure AllocateAnsiMultiSz(Var Dest: PAnsiMultiSz; Len: SizeInt);
Begin
  uRESTDWMemAnsiStrings.AllocateMultiSz(Dest, Len);
End;
Procedure FreeAnsiMultiSz(Var Dest: PAnsiMultiSz);
Begin
  uRESTDWMemAnsiStrings.FreeMultiSz(Dest);
End;
Procedure AllocateWideMultiSz(Var Dest: PWideMultiSz; Len: SizeInt);
Begin
  uRESTDWMemWideStrings.AllocateMultiSz(Dest, Len);
End;
Procedure FreeWideMultiSz(Var Dest: PWideMultiSz);
Begin
  uRESTDWMemWideStrings.FreeMultiSz(Dest);
End;
//=== TStrings Manipulation ==================================================
Procedure StrToStrings(S, Sep: string; Const List: TStrings; Const AllowEmptyString: Boolean = True);
Var
  I, L: SizeInt;
  Left: string;
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
Procedure StrIToStrings(S, Sep: string; Const List: TStrings; Const AllowEmptyString: Boolean = True);
Var
  I, L: SizeInt;
  LowerCaseStr: string;
  Left: string;
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
Function StringsToStr(Const List: TStrings; Const Sep: string; Const AllowEmptyString: Boolean = True): string;
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
  If List.Count > 0 Then
  Begin
    L := Length(Sep);
    Delete(Result, Length(Result) - L + 1, L);
  End;
End;
Function StringsToStr(Const List: TStrings; Const Sep: string; Const NumberOfItems: SizeInt; Const AllowEmptyString:
    Boolean = True): string;
Var
  I, L, N: SizeInt;
Begin
  Result := '';
  If List.Count > NumberOfItems Then
    N := NumberOfItems
  Else
    N := List.Count;
  For I := 0 To N - 1 Do
  Begin
    If (List[I] <> '') or AllowEmptyString Then
    Begin
      // don't combine these into one addition, somehow it hurts performance
      Result := Result + List[I];
      Result := Result + Sep;
    End;
  End;
  // remove terminating separator
  If N > 0 Then
  Begin
    L := Length(Sep);
    Delete(Result, Length(Result) - L + 1, L);
  End;
End;
Procedure TrimStrings(Const List: TStrings; DeleteIfEmpty: Boolean);
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
Procedure TrimStringsRight(Const List: TStrings; DeleteIfEmpty: Boolean);
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
Procedure TrimStringsLeft(Const List: TStrings; DeleteIfEmpty: Boolean);
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
Function AddStringToStrings(Const S: string; Strings: TStrings; Const Unique: Boolean): Boolean;
Begin
  Assert(Strings <> nil);
  Result := Unique and (Strings.IndexOf(S) <> -1);
  If not Result Then
    Result := Strings.Add(S) > -1;
End;
//=== Miscellaneous ==========================================================
Function FileToString(Const FileName: string): {$IFDEF COMPILER12_UP}RawByteString{$ELSE}DWString{$ENDIF};
Var
  fs: TFileStream;
  Len: SizeInt;
Begin
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Try
    Len := fs.Size;
    SetLength(Result, Len);
    If Len > 0 Then
      fs.ReadBuffer(Result[1], Len);
  Finally
    fs.Free;
  End;
End;
Procedure StringToFile(Const FileName: string; Const Contents: {$IFDEF COMPILER12_UP}RawByteString{$ELSE}DWString{$ENDIF};
  Append: Boolean);
Var
  FS: TFileStream;
  Len: SizeInt;
Begin
  If Append and FileExists(filename) Then
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
Function StrToken(Var S: string; Separator: Char): string;
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
Procedure StrTokens(Const S: string; Const List: TStrings);
Var
  Start: PChar;
  Token: string;
  Done:  Boolean;
Begin
  Assert(List <> nil);
  If List = nil Then
    Exit;
  List.BeginUpdate;
  Try
    List.Clear;
    Start := Pointer(S);
    Repeat
      Done := StrWord(Start, Token);
      If Token <> '' Then
        List.Add(Token);
    Until Done;
  Finally
    List.EndUpdate;
  End;
End;
Function StrWord(Const S: string; Var Index: SizeInt; out Word: string): Boolean;
Var
  Start: SizeInt;
  C: Char;
Begin
  Word := '';
  If (S = '') Then
  Begin
    Result := True;
    Exit;
  End;
  Start := Index;
  Result := False;
  While True Do
  Begin
    C := S[Index];
    Case C Of
      #0:
        Begin
          If Start <> 0 Then
            Word := Copy(S, Start, Index - Start);
          Result := True;
          Exit;
        End;
      NativeSpace, NativeLineFeed, NativeCarriageReturn:
        Begin
          If Start <> 0 Then
          Begin
            Word := Copy(S, Start, Index - Start);
            Exit;
          End
          Else
          Begin
            While CharIsWhiteSpace(C) Do
            Begin
              Inc(Index);
              C := S[Index];
            End;
          End;
        End;
    Else
      If Start = 0 Then
        Start := Index;
      Inc(Index);
    End;
  End;
End;
Function StrWord(Var S: PChar; out Word: string): Boolean;
Var
  Start: PChar;
Begin
  Word := '';
  If S = nil Then
  Begin
    Result := True;
    Exit;
  End;
  Start := nil;
  Result := False;
  While True Do
  Begin
    Case S^ Of
      #0:
      Begin
        If Start <> nil Then
          SetString(Word, Start, S - Start);
        Result := True;
        Exit;
      End;
      NativeSpace, NativeLineFeed, NativeCarriageReturn:
      Begin
        If Start <> nil Then
        Begin
          SetString(Word, Start, S - Start);
          Exit;
        End
        Else
          While CharIsWhiteSpace(S^) Do
            Inc(S);
      End;
    Else
      If Start = nil Then
        Start := S;
      Inc(S);
    End;
  End;
End;
Function StrIdent(Const S: string; Var Index: SizeInt; out Ident: string): Boolean;
Var
  Start: SizeInt;
  C: Char;
Begin
  Ident := '';
  If (S = '') Then
  Begin
    Result := True;
    Exit;
  End;
  Start := Index;
  Result := False;
  While True Do
  Begin
    C := S[Index];
    If CharIsValidIdentifierLetter(C) Then
    Begin
      If Start = 0 Then
        Start := Index;
    End
    Else
    If C = #0 Then
    Begin
      If Start <> 0 Then
        Ident := Copy(S, Start, Index - Start);
      Result := True;
      Exit;
    End
    Else
    Begin
      If Start <> 0 Then
      Begin
        Ident := Copy(S, Start, Index - Start);
        Exit;
      End;
    End;
    Inc(Index);
  End;
End;
Function StrIdent(Var S: PChar; out Ident: string): Boolean;
Var
  Start: PChar;
  C: Char;
Begin
  Ident := '';
  If S = nil Then
  Begin
    Result := True;
    Exit;
  End;
  Start := nil;
  Result := False;
  While True Do
  Begin
    C := S^;
    If CharIsValidIdentifierLetter(C) Then
    Begin
      If Start = nil Then
        Start := S;
    End
    Else
    If C = #0 Then
    Begin
      If Start <> nil Then
        SetString(Ident, Start, S - Start);
      Result := True;
      Exit;
    End
    Else
    Begin
      If Start <> nil Then
      Begin
        SetString(Ident, Start, S - Start);
        Exit;
      End
    End;
    Inc(S);
  End;
End;
Procedure StrTokenToStrings(S: string; Separator: Char; Const List: TStrings);
Var
  Token: string;
Begin
  Assert(List <> nil);
  If List = nil Then
    Exit;
  List.BeginUpdate;
  Try
    List.Clear;
    While S <> '' Do
    Begin
      Token := StrToken(S, Separator);
      List.Add(Token);
    End;
  Finally
    List.EndUpdate;
  End;
End;
Function StrToFloatSafe(Const S: string): Float;
Var
  Temp: string;
  I, J, K: SizeInt;
  SwapSeparators, IsNegative: Boolean;
  DecSep, ThouSep, C: Char;
Begin
  DecSep := {$IFDEF RTL220_UP}FormatSettings.{$ENDIF}DecimalSeparator;
  ThouSep := {$IFDEF RTL220_UP}FormatSettings.{$ENDIF}ThousandSeparator;
  Temp := S;
  SwapSeparators := False;
  IsNegative := False;
  J := 0;
  For I := 1 To Length(Temp) Do
  Begin
    C := Temp[I];
    If C = '-' Then
      IsNegative := not IsNegative
    Else
    If (C <> ' ') and (C <> '(') and (C <> '+') Then
    Begin
        // if it appears prior to any digit, it has to be a decimal separator
      SwapSeparators := Temp[I] = ThouSep;
      J := I;
      Break;
    End;
  End;
  If not SwapSeparators Then
  Begin
    K := CharPos(Temp, DecSep);
    SwapSeparators :=
      // if it appears prior to any digit, it has to be a decimal separator
      (K > J) and
      // if it appears multiple times, it has to be a thousand separator
      ((StrCharCount(Temp, DecSep) > 1) or
      // we assume (consistent with Windows Platform SDK documentation),
      // that thousand separators appear only to the left of the decimal
      (K < CharPos(Temp, ThouSep)));
  End;
  If SwapSeparators Then
  Begin
    // assume a numerical string from a different locale,
    // where DecimalSeparator and ThousandSeparator are exchanged
    For I := 1 To Length(Temp) Do
      If Temp[I] = DecSep Then
        Temp[I] := ThouSep
      Else
      If Temp[I] = ThouSep Then
        Temp[I] := DecSep;
  End;
  Temp := StrKeepChars(Temp, CharIsNumber);
  If Length(Temp) > 0 Then
  Begin
    If Temp[1] = DecSep Then
      Temp := '0' + Temp;
    If Temp[Length(Temp)] = DecSep Then
      Temp := Temp + '0';
    Result := StrToFloat(Temp);
    If IsNegative Then
      Result := -Result;
  End
  Else
    Result := 0.0;
End;
Function StrToIntSafe(Const S: string): Integer;
Begin
  Result := Trunc(StrToFloatSafe(S));
End;
Procedure StrNormIndex(Const StrLen: SizeInt; Var Index: SizeInt; Var Count: SizeInt); overload;
Begin
  Index := Max(1, Min(Index, StrLen + 1));
  Count := Max(0, Min(Count, StrLen + 1 - Index));
End;
Function ArrayOf(List: TStrings): TDynStringArray;
Var
  I: SizeInt;
Begin
  If List <> nil Then
  Begin
    SetLength(Result, List.Count);
    For I := 0 To List.Count - 1 Do
      Result[I] := List[I];
  End
  Else
    Result := nil;
End;
Const
  BoolToStr: array [Boolean] Of string = ('false', 'true');
Type
  TInterfacedObjectAccess = Class(TInterfacedObject);
Procedure MoveChar(Const Source; Var Dest; Count: SizeInt);
Begin
  If Count > 0 Then
    Move(Source, Dest, Count * SizeOf(Char));
End;
Function DotNetFormat(Const Fmt: string; Const Arg0: Variant): string;
Begin
  Result := DotNetFormat(Fmt, [Arg0]);
End;
Function DotNetFormat(Const Fmt: string; Const Arg0, Arg1: Variant): string;
Begin
  Result := DotNetFormat(Fmt, [Arg0, Arg1]);
End;
Function DotNetFormat(Const Fmt: string; Const Arg0, Arg1, Arg2: Variant): string;
Begin
  Result := DotNetFormat(Fmt, [Arg0, Arg1, Arg2]);
End;
Function DotNetFormat(Const Fmt: string; Const Args: array Of Const): string;
Var
  F, P: PChar;
  Len, Capacity, Count: SizeInt;
  Index: SizeInt;
  ErrorCode: Integer;
  S: string;
  Procedure Grow(Count: SizeInt);
  Begin
    If Len + Count > Capacity Then
    Begin
      Capacity := Capacity * 5 div 3 + Count;
      SetLength(Result, Capacity);
    End;
  End;
  Function InheritsFrom(AClass: TClass; Const ClassName: string): Boolean;
  Begin
    Result := True;
    While AClass <> nil Do
    Begin
      If CompareText(AClass.ClassName, ClassName) = 0 Then
        Exit;
      AClass := AClass.ClassParent;
    End;
    Result := False;
  End;
  Function GetStringOf(Const V: TVarData; Index: SizeInt): string; overload;
  Begin
    Case V.VType Of
      varEmpty, varNull:
        raise ArgumentNullException.CreateRes(@RsArgumentIsNull);
      varSmallInt:
        Result := IntToStr(V.VSmallInt);
      varInteger:
        Result := IntToStr(V.VInteger);
      varSingle:
        Result := FloatToStr(V.VSingle);
      varDouble:
        Result := FloatToStr(V.VDouble);
      varCurrency:
        Result := CurrToStr(V.VCurrency);
      varDate:
        Result := DateTimeToStr(V.VDate);
      varOleStr:
        Result := V.VOleStr;
      varBoolean:
        Result := BoolToStr[V.VBoolean <> False];
      varByte:
        Result := IntToStr(V.VByte);
      varWord:
        Result := IntToStr(V.VWord);
      varShortInt:
        Result := IntToStr(V.VShortInt);
      varLongWord:
        Result := IntToStr(V.VLongWord);
      varInt64:
        Result := IntToStr(V.VInt64);
      varString:
        Result := string(V.VString);
      {$IFDEF SUPPORTS_UNICODE_STRING}
      varUString:
        Result := string(V.VUString);
      {$ENDIF SUPPORTS_UNICODE_STRING}
      {varArray,
      varDispatch,
      varError,
      varUnknown,
      varAny,
      varByRef:}
    Else
      raise ArgumentNullException.CreateResFmt(@RsDotNetFormatArgumentNotSupported, [Index]);
    End;
  End;
  Function GetStringOf(Index: SizeInt): string; overload;
  Var
    V: TVarRec;
    Intf: IToString;
  Begin
    V := Args[Index];
    If (V.VInteger = 0) and
      (V.VType in [vtExtended, vtString, vtObject, vtClass, vtCurrency,
      vtInterface, vtInt64]) Then
      raise ArgumentNullException.CreateResFmt(@RsArgumentIsNull, [Index]);
    Case V.VType Of
      vtInteger:
        Result := IntToStr(V.VInteger);
      vtBoolean:
        Result := BoolToStr[V.VBoolean];
      vtChar:
        Result := string(DWString(V.VChar));
      vtExtended:
        Result := FloatToStr(V.VExtended^);
      vtString:
        Result := {$IFDEF NEXTGEN}String(V.VWideString^);{$ELSE}String(V.VString^);{$ENDIF}
      vtPointer:
        Result := IntToHex(TJclAddr(V.VPointer), 8);
      vtPChar:
        Result := string(DWString(V.VPChar));
                 //TODO XyberX
      vtObject:  Begin
                 End;
      vtClass:
        Result := V.VClass.ClassName;
      vtWideChar:
        Result := V.VWideChar;
      vtPWideChar:
        Result := V.VPWideChar;
      vtAnsiString:
        Result := string(V.VAnsiString);
      vtCurrency:
        Result := CurrToStr(V.VCurrency^);
      vtVariant:
        Result := GetStringOf(TVarData(V.VVariant^), Index);
      vtInterface:
        If IInterface(V.VInterface).QueryInterface(IToString, Intf) = 0 Then
          Result := IToString(Intf).ToString
        Else
          raise ArgumentNullException.CreateResFmt(@RsDotNetFormatArgumentNotSupported, [Index]);
      vtWideString:
        Result := DWWideString(V.VWideString);
      vtInt64:
        Result := IntToStr(V.VInt64^);
      {$IFDEF SUPPORTS_UNICODE_STRING}
      vtUnicodeString:
        Result := UnicodeString(V.VUnicodeString);
      {$ENDIF SUPPORTS_UNICODE_STRING}
    Else
      raise ArgumentNullException.CreateResFmt(@RsDotNetFormatArgumentNotSupported, [Index]);
    End;
  End;
Begin
  If Length(Args) = 0 Then
  Begin
    Result := Fmt;
    Exit;
  End;
  Len := 0;
  Capacity := Length(Fmt);
  SetLength(Result, Capacity);
  If Capacity = 0 Then
    raise ArgumentNullException.CreateRes(@RsDotNetFormatNullFormat);
  P := Pointer(Fmt);
  F := P;
  While True Do
  Begin
    If (P[0] = #0) or (P[0] = '{') Then
    Begin
      Count := P - F;
      Inc(P);
      If (P[-1] <> #0) and (P[0] = '{') Then
        Inc(Count); // include '{'
      If Count > 0 Then
      Begin
        Grow(Count);
        MoveChar(F[0], Result[Len + 1], Count);
        Inc(Len, Count);
      End;
      If P[-1] = #0 Then
        Break;
      If P[0] <> '{' Then
      Begin
        F := P;
        Inc(P);
        While (P[0] <> #0) and (P[0] <> '}') Do
          Inc(P);
        SetString(S, F, P - F);
        Val(S, Index, ErrorCode);
        If ErrorCode <> 0 Then
          raise FormatException.CreateRes(@RsFormatException);
        If (Index < 0) or (Index > High(Args)) Then
          raise FormatException.CreateRes(@RsFormatException);
        S := GetStringOf(Index);
        If S <> '' Then
        Begin
          Grow(Length(S));
          MoveChar(S[1], Result[Len + 1], Length(S));
          Inc(Len, Length(S));
        End;
        If P[0] = #0 Then
          Break;
      End;
      F := P + 1;
    End
    Else
    If (P[0] = '}') and (P[1] = '}') Then
    Begin
      Count := P - F + 1;
      Inc(P); // skip next '}'
      Grow(Count);
      MoveChar(F[0], Result[Len + 1], Count);
      Inc(Len, Count);
      F := P + 1;
    End;
    Inc(P);
  End;
  SetLength(Result, Len);
End;
//=== { TJclStringBuilder } =====================================================
Constructor TJclStringBuilder.Create(Capacity: SizeInt; MaxCapacity: SizeInt);
Begin
  Inherited Create;
  SetLength(FChars, Capacity);
  FMaxCapacity := MaxCapacity;
End;
Constructor TJclStringBuilder.Create(Const Value: string; Capacity: SizeInt);
Begin
  Create(Capacity);
  Append(Value);
End;
Constructor TJclStringBuilder.Create(Const Value: string; StartIndex, Length, Capacity: SizeInt);
Begin
  Create(Capacity);
  Append(Value, StartIndex + 1, Length);
End;
Function TJclStringBuilder.ToString: string;
Begin
  If FLength > 0 Then
    SetString(Result, PChar(@FChars[0]), FLength)
  Else
    Result := '';
End;
Function TJclStringBuilder.EnsureCapacity(Capacity: SizeInt): SizeInt;
Begin
  If System.Length(FChars) < Capacity Then
    SetCapacity(Capacity);
  Result := System.Length(FChars);
End;
Procedure TJclStringBuilder.Clear;
Begin
  Length := 0;
End;
Procedure TJclStringBuilder.SetCapacity(Const Value: SizeInt);
Begin
  If Value <> System.Length(FChars) Then
  Begin
    SetLength(FChars, Value);
    If Value < FLength Then
      FLength := Value;
  End;
End;
Function TJclStringBuilder.GetChars(Index: SizeInt): Char;
Begin
  Result := FChars[Index];
End;
Procedure TJclStringBuilder.SetChars(Index: SizeInt; Const Value: Char);
Begin
  FChars[Index] := Value;
End;
Procedure TJclStringBuilder.Set_Length(Const Value: SizeInt);
Begin
  FLength := Value;
End;
Function TJclStringBuilder.GetCapacity: SizeInt;
Begin
  Result := System.Length(FChars);
End;
Function TJclStringBuilder.AppendPChar(Value: PChar; Count: SizeInt; RepeatCount: SizeInt): TJclStringBuilder;
Var
  Capacity: SizeInt;
Begin
  If (Count > 0) and (RepeatCount > 0) Then
  Begin
    Repeat
      Capacity := System.Length(FChars);
      If Capacity + Count > MaxCapacity Then
        raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
      If Capacity < FLength + Count Then
        SetLength(FChars, Capacity * 5 div 3 + Count);
      If Count = 1 Then
        FChars[FLength] := Value[0]
      Else
        MoveChar(Value[0], FChars[FLength], Count);
      Inc(FLength, Count);
      Dec(RepeatCount);
    Until RepeatCount <= 0;
  End;
  Result := Self;
End;
Function TJclStringBuilder.InsertPChar(Index: SizeInt; Value: PChar; Count,
  RepeatCount: SizeInt): TJclStringBuilder;
Var
  Capacity: SizeInt;
Begin
  If (Index < 0) or (Index > FLength) Then
    raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
  If Index = FLength Then
    AppendPChar(Value, Count, RepeatCount)
  Else
  If (Count > 0) and (RepeatCount > 0) Then
  Begin
    Repeat
      Capacity := System.Length(FChars);
      If Capacity + Count > MaxCapacity Then
        raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
      If Capacity < FLength + Count Then
        SetLength(FChars, Capacity * 5 div 3 + Count);
      MoveChar(FChars[Index], FChars[Index + Count], FLength - Index);
      If Count = 1 Then
        FChars[Index] := Value[0]
      Else
        MoveChar(Value[0], FChars[Index], Count);
      Inc(FLength, Count);
      Dec(RepeatCount);
      Inc(Index, Count); // little optimization
    Until RepeatCount <= 0;
  End;
  Result := Self;
End;
Function TJclStringBuilder.Append(Const Value: array Of Char): TJclStringBuilder;
Var
  Len: SizeInt;
Begin
  Len := System.Length(Value);
  If Len > 0 Then
    AppendPChar(@Value[0], Len);
  Result := Self;
End;
Function TJclStringBuilder.Append(Const Value: array Of Char; StartIndex, Length: SizeInt): TJclStringBuilder;
Var
  Len: SizeInt;
Begin
  Len := System.Length(Value);
  If (Length > 0) and (StartIndex < Len) Then
  Begin
    If StartIndex + Length > Len Then
      Length := Len - StartIndex;
    AppendPChar(PChar(@Value[0]) + StartIndex, Length);
  End;
  Result := Self;
End;
Function TJclStringBuilder.Append(Value: Char; RepeatCount: SizeInt = 1): TJclStringBuilder;
Begin
  Result := AppendPChar(@Value, 1, RepeatCount);
End;
Function TJclStringBuilder.Append(Const Value: string): TJclStringBuilder;
Var
  Len: SizeInt;
Begin
  Len := System.Length(Value);
  If Len > 0 Then
    AppendPChar(Pointer(Value), Len);
  Result := Self;
End;
Function TJclStringBuilder.Append(Const Value: string; StartIndex, Length: SizeInt): TJclStringBuilder;
Var
  Len: SizeInt;
Begin
  Len := System.Length(Value);
  If (Length > 0) and (StartIndex < Len) Then
  Begin
    If StartIndex + Length > Len Then
      Length := Len - StartIndex;
    AppendPChar(PChar(Pointer(Value)) + StartIndex, Length);
  End;
  Result := Self;
End;
Function TJclStringBuilder.Append(Value: Boolean): TJclStringBuilder;
Begin
  Result := Append(BoolToStr[Value]);
End;
Function TJclStringBuilder.Append(Value: Cardinal): TJclStringBuilder;
Begin
  Result := Append(IntToStr(Value));
End;
Function TJclStringBuilder.Append(Value: Integer): TJclStringBuilder;
Begin
  Result := Append(IntToStr(Value));
End;
Function TJclStringBuilder.Append(Value: Double): TJclStringBuilder;
Begin
  Result := Append(FloatToStr(Value));
End;
Function TJclStringBuilder.Append(Value: Int64): TJclStringBuilder;
Begin
  Result := Append(IntToStr(Value));
End;
Function TJclStringBuilder.Append(Obj: TObject): TJclStringBuilder;
Begin
  Result := Append(DotNetFormat('{0}', [Obj]));
End;
Function TJclStringBuilder.AppendFormat(Const Fmt: string; Arg0: Variant): TJclStringBuilder;
Begin
  Result := Append(DotNetFormat(Fmt, [Arg0]));
End;
Function TJclStringBuilder.AppendFormat(Const Fmt: string; Arg0, Arg1: Variant): TJclStringBuilder;
Begin
  Result := Append(DotNetFormat(Fmt, [Arg0, Arg1]));
End;
Function TJclStringBuilder.AppendFormat(Const Fmt: string; Arg0, Arg1, Arg2: Variant): TJclStringBuilder;
Begin
  Result := Append(DotNetFormat(Fmt, [Arg0, Arg1, Arg2]));
End;
Function TJclStringBuilder.AppendFormat(Const Fmt: string; Const Args: array Of Const): TJclStringBuilder;
Begin
  Result := Append(DotNetFormat(Fmt, Args));
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Const Value: array Of Char): TJclStringBuilder;
Var
  Len: SizeInt;
Begin
  Len := System.Length(Value);
  If Len > 0 Then
    InsertPChar(Index, @Value[0], Len);
  Result := Self;
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Const Value: string; Count: SizeInt): TJclStringBuilder;
Var
  Len: SizeInt;
Begin
  Len := System.Length(Value);
  If Len > 0 Then
    InsertPChar(Index, Pointer(Value), Len, Count);
  Result := Self;
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Value: Boolean): TJclStringBuilder;
Begin
  Result := Insert(Index, BoolToStr[Value]);
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Const Value: array Of Char;
  StartIndex, Length: SizeInt): TJclStringBuilder;
Var
  Len: SizeInt;
Begin
  Len := System.Length(Value);
  If (Length > 0) and (StartIndex < Len) Then
  Begin
    If StartIndex + Length > Len Then
      Length := Len - StartIndex;
    InsertPChar(Index, PChar(@Value[0]) + StartIndex, Length);
  End;
  Result := Self;
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Value: Double): TJclStringBuilder;
Begin
  Result := Insert(Index, FloatToStr(Value));
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Value: Int64): TJclStringBuilder;
Begin
  Result := Insert(Index, IntToStr(Value));
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Value: Cardinal): TJclStringBuilder;
Begin
  Result := Insert(Index, IntToStr(Value));
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Value: Integer): TJclStringBuilder;
Begin
  Result := Insert(Index, IntToStr(Value));
End;
Function TJclStringBuilder.Insert(Index: SizeInt; Obj: TObject): TJclStringBuilder;
Begin
  Result := Insert(Index, DotNetFormat('{0}', [Obj]));
End;
Function TJclStringBuilder.Remove(StartIndex, Length: SizeInt): TJclStringBuilder;
Begin
  If (StartIndex < 0) or (Length < 0) or (StartIndex + Length >= FLength) Then
    raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
  If Length > 0 Then
  Begin
    MoveChar(FChars[StartIndex + Length], FChars[StartIndex], FLength - (StartIndex + Length));
    Dec(FLength, Length);
  End;
  Result := Self;
End;
Function TJclStringBuilder.Replace(OldChar, NewChar: Char; StartIndex,
  Count: SizeInt): TJclStringBuilder;
Var
  I: SizeInt;
Begin
  If Count = -1 Then
    Count := FLength;
  If (StartIndex < 0) or (Count < 0) or (StartIndex + Count > FLength) Then
    raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
  If (Count > 0) and (OldChar <> NewChar) Then
  Begin
    For I := StartIndex To StartIndex + Length - 1 Do
      If FChars[I] = OldChar Then
        FChars[I] := NewChar;
  End;
  Result := Self;
End;
Function TJclStringBuilder.Replace(OldValue, NewValue: string; StartIndex, Count: SizeInt): TJclStringBuilder;
Var
  I: SizeInt;
  Offset: SizeInt;
  NewLen, OldLen, Capacity: SizeInt;
Begin
  If Count = -1 Then
    Count := FLength;
  If (StartIndex < 0) or (Count < 0) or (StartIndex + Count > FLength) Then
    raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
  If OldValue = '' Then
    raise ArgumentException.CreateResFmt(@RsArgumentIsNull, [0]);
  If (Count > 0) and (OldValue <> NewValue) Then
  Begin
    OldLen := System.Length(OldValue);
    NewLen := System.Length(NewValue);
    Offset := NewLen - OldLen;
    Capacity := System.Length(FChars);
    For I := StartIndex To StartIndex + Length - 1 Do
      If FChars[I] = OldValue[1] Then
      Begin
        If OldLen > 1 Then
          If StrLComp(@FChars[I + 1], PChar(OldValue) + 1, OldLen - 1) <> 0 Then
            Continue;
        If Offset <> 0 Then
        Begin
          If FLength - OldLen + NewLen > MaxCurrency Then
            raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
          If Capacity < FLength + Offset Then
          Begin
            Capacity := Capacity * 5 div 3 + Offset;
            SetLength(FChars, Capacity);
          End;
          If Offset < 0 Then
            MoveChar(FChars[I - Offset], FChars[I], FLength - I)
          Else
            MoveChar(FChars[I + OldLen], FChars[I + OldLen + Offset], FLength - OldLen - I);
          Inc(FLength, Offset);
        End;
        If NewLen > 0 Then
        Begin
          If (OldLen = 1) and (NewLen = 1) Then
            FChars[I] := NewValue[1]
          Else
            MoveChar(NewValue[1], FChars[I], NewLen);
        End;
      End;
  End;
  Result := Self;
End;
Function StrExpandTabs(S: string): string;
Begin
  // use an empty tab set, which will default to a tab width of 2
  Result := TJclTabSet(nil).Expand(s);
End;
Function StrExpandTabs(S: string; TabWidth: SizeInt): string;
Var
  TabSet: TJclTabSet;
Begin
  // create a tab set with no tab stops and the given tab width
  TabSet := TJclTabSet.Create(TabWidth);
  Try
    Result := TabSet.Expand(S);
  Finally
    TabSet.Free;
  End;
End;
Function StrExpandTabs(S: string; TabSet: TJclTabSet): string;
Begin
  // use the provided tab set to perform the expansion
  Result := TabSet.Expand(S);
End;
Function StrOptimizeTabs(S: string): string;
Begin
  // use an empty tab set, which will default to a tab width of 2
  Result := TJclTabSet(nil).Optimize(s);
End;
Function StrOptimizeTabs(S: string; TabWidth: SizeInt): string;
Var
  TabSet: TJclTabSet;
Begin
  // create a tab set with no tab stops and the given tab width
  TabSet := TJclTabSet.Create(TabWidth);
  Try
    Result := TabSet.Optimize(S);
  Finally
    TabSet.Free;
  End;
End;
Function StrOptimizeTabs(S: string; TabSet: TJclTabSet): string;
Begin
  // use the provided tab set to perform the optimization
  Result := TabSet.Optimize(S);
End;
// === { TTabSetData } ===================================================
Type
  TTabSetData = Class
  Public
    FStops: TDynSizeIntArray;
    FRealWidth: SizeInt;
    FRefCount: SizeInt;
    FWidth: SizeInt;
    FZeroBased: Boolean;
    Constructor Create(TabStops: array Of SizeInt; ZeroBased: Boolean; TabWidth: SizeInt);
    Function Add(Column: SizeInt): SizeInt;
    Function AddRef: SizeInt;
    Procedure CalcRealWidth;
    Function FindStop(Column: SizeInt): SizeInt;
    Function ReleaseRef: SizeInt;
    Procedure RemoveAt(Index: SizeInt);
    Procedure SetStops(Index, Value: SizeInt);
  End;
Constructor TTabSetData.Create(TabStops: array Of SizeInt; ZeroBased: Boolean; TabWidth: SizeInt);
Var
  idx: SizeInt;
Begin
  Inherited Create;
  FRefCount := 1;
  For idx := 0 To High(Tabstops) Do
    Add(Tabstops[idx]);
  FWidth := TabWidth;
  FZeroBased := ZeroBased;
  CalcRealWidth;
End;
Function TTabSetData.Add(Column: SizeInt): SizeInt;
Var
  I: SizeInt;
Begin
  If Column < Ord(FZeroBased) Then
    raise ArgumentOutOfRangeException.Create('Column');
  Result := FindStop(Column);
  If Result < 0 Then
  Begin
    // the column doesn't exist; invert the result of FindStop to get the correct index position
    Result := not Result;
    // increase the tab stop array
    SetLength(FStops, Length(FStops) + 1);
    // shift rooms after the insert position
    For I := High(FStops) - 1 Downto Result Do
      FStops[I + 1] := FStops[I];
    // add the tab stop at the correct location
    FStops[Result] := Column;
    CalcRealWidth;
  End
  Else
  Begin
    raise EJclStringError.CreateRes(@RsTabs_DuplicatesNotAllowed);
  End;
End;
Function TTabSetData.AddRef: SizeInt;
Begin
End;
Procedure TTabSetData.CalcRealWidth;
Begin
  If FWidth < 1 Then
  Begin
    If Length(FStops) > 1 Then
      FRealWidth := FStops[High(FStops)] - FStops[Pred(High(FStops))]
    Else
    If Length(FStops) = 1 Then
      FRealWidth := FStops[0]
    Else
      FRealWidth := 2;
  End
  Else
    FRealWidth := FWidth;
End;
Function TTabSetData.FindStop(Column: SizeInt): SizeInt;
Begin
  Result := High(FStops);
  While (Result >= 0) and (FStops[Result] > Column) Do
    Dec(Result);
  If (Result >= 0) and (FStops[Result] <> Column) Then
    Result := not Succ(Result);
End;
Function TTabSetData.ReleaseRef: SizeInt;
Begin
End;
Procedure TTabSetData.RemoveAt(Index: SizeInt);
Var
  I: SizeInt;
Begin
  For I := Index To High(FStops) - 1 Do
    FStops[I] := FStops[I + 1];
  SetLength(FStops, High(FStops));
  CalcRealWidth;
End;
Procedure TTabSetData.SetStops(Index, Value: SizeInt);
Var
  temp: SizeInt;
Begin
  If (Index < 0) or (Index >= Length(FStops)) Then
  Begin
    raise ArgumentOutOfRangeException.CreateRes(@RsArgumentOutOfRange);
  End
  Else
  Begin
    temp := FindStop(Value);
    If temp < 0 Then
    Begin
      // remove existing tab stop...
      RemoveAt(Index);
      // now add the new tab stop
      Add(Value);
    End
    Else
    If temp <> Index Then
    Begin
      // new tab stop already present at another index
      raise EJclStringError.CreateRes(@RsTabs_DuplicatesNotAllowed);
    End;
  End;
End;
//=== { TJclTabSet } =====================================================
Constructor TJclTabSet.Create;
Begin
  // no tab stops, tab width set to auto
  Create([], True, 0);
End;
Constructor TJclTabSet.Create(TabWidth: SizeInt);
Begin
  // no tab stops, specified tab width
  Create([], True, TabWidth);
End;
Constructor TJclTabSet.Create(Const Tabstops: array Of SizeInt; ZeroBased: Boolean);
Begin
  // specified tab stops, tab width equal to distance between last two tab stops
  Create(Tabstops, ZeroBased, 0);
End;
Constructor TJclTabSet.Create(Const Tabstops: array Of SizeInt; ZeroBased: Boolean; TabWidth: SizeInt);
Begin
  Inherited Create;
  FData := TTabSetData.Create(Tabstops, ZeroBased, TabWidth);
End;
Constructor TJclTabSet.Create(Data: TObject);
Begin
  Inherited Create;
  // add a reference to the data
  TTabSetData(Data).AddRef;
  // assign the data to this instance
  FData := TTabSetData(Data);
End;
Destructor TJclTabSet.Destroy;
Begin
  // release the reference to the tab set data
  TTabSetData(FData).ReleaseRef;
  // make sure we won't accidentally refer to it later, just in case something goes wrong during destruction
  FData := nil;
  // really destroy the instance
  Inherited Destroy;
End;
Function TJclTabSet.Add(Column: SizeInt): SizeInt;
Begin
  If Self = nil Then
    raise NullReferenceException.Create;
  Result := TTabSetData(FData).Add(Column);
End;
Function TJclTabSet.Clone: TJclTabSet;
Begin
  If Self <> nil Then
    Result := TJclTabSet.Create(TTabSetData(FData).FStops, TTabSetData(FData).FZeroBased, TTabSetData(FData).FWidth)
  Else
    Result := nil;
End;
Function TJclTabSet.Delete(Column: SizeInt): SizeInt;
Begin
  Result := TTabSetData(FData).FindStop(Column);
  If Result >= 0 Then
    TTabSetData(FData).RemoveAt(Result);
End;
Function TJclTabSet.Expand(Const S: string): string;
Begin
  Result := Expand(s, StartColumn);
End;
Function TJclTabSet.Expand(Const S: string; Column: SizeInt): string;
Var
  sb: TJclStringBuilder;
  head: PChar;
  cur: PChar;
Begin
  If Column < StartColumn Then
    raise ArgumentOutOfRangeException.Create('Column');
  sb := TJclStringBuilder.Create(Length(S));
  Try
    cur := PChar(S);
    While cur^ <> #0 Do
    Begin
      head := cur;
      While (cur^ <> #0) and (cur^ <> #9) Do
      Begin
        If CharIsReturn(cur^) Then
          Column := StartColumn
        Else
          Inc(Column);
        Inc(cur);
      End;
      If cur > head Then
        sb.Append(head, 0, cur - head);
      If cur^ = #9 Then
      Begin
        sb.Append(' ', TabFrom(Column) - Column);
        Column := TabFrom(Column);
        Inc(cur);
      End;
    End;
    Result := sb.ToString;
  Finally
    sb.Free;
  End;
End;
Function TJclTabSet.FindStop(Column: SizeInt): SizeInt;
Begin
  If Self <> nil Then
    Result := TTabSetData(FData).FindStop(Column)
  Else
    Result := -1;
End;
Class Function TJclTabSet.FromString(Const S: string): TJclTabSet;
Var
  cur: PChar;
  Function ParseNumber: Integer;
  Var
    head: PChar;
  Begin
    StrSkipChars(cur, CharIsWhiteSpace);
    head := cur;
    While CharIsDigit(cur^) Do
      Inc(cur);
    Result := -1;
    If (cur <= head) or not TryStrToInt(Copy(head, 1, cur - head), Result) Then
      Result := -1;
  End;
  Procedure ParseStops;
  Var
    openBracket, hadComma: Boolean;
    num: SizeInt;
  Begin
    StrSkipChars(cur, CharIsWhiteSpace);
    openBracket := cur^ = '[';
    hadComma := False;
    If openBracket Then
      Inc(cur);
    Repeat
      num := ParseNumber;
      If (num < 0) and hadComma Then
        raise EJclStringError.CreateRes(@RsTabs_StopExpected)
      Else
      If num >= 0 Then
        Result.Add(num);
      StrSkipChars(cur, CharIsWhiteSpace);
      hadComma := cur^ = ',';
      If hadComma Then
        Inc(cur);
    Until (cur^ = #0) or (cur^ = '+') or (cur^ = ']');
    If hadComma Then
      raise EJclStringError.CreateRes(@RsTabs_StopExpected)
    Else
    If openBracket and (cur^ <> ']') Then
      raise EJclStringError.CreateRes(@RsTabs_CloseBracketExpected);
  End;
  Procedure ParseTabWidth;
  Var
    num: SizeInt;
  Begin
    StrSkipChars(cur, CharIsWhiteSpace);
    If cur^ = '+' Then
    Begin
      Inc(cur);
      StrSkipChars(cur, CharIsWhiteSpace);
      num := ParseNumber;
      If (num < 0) Then
        raise EJclStringError.CreateRes(@RsTabs_TabWidthExpected)
      Else
        Result.TabWidth := num;
    End;
  End;
  Procedure ParseZeroBasedFlag;
  Begin
    StrSkipChars(cur, CharIsWhiteSpace);
    If cur^ = '0' Then
    Begin
      Inc(cur);
      If CharIsWhiteSpace(cur^) or (cur^ = #0) or (cur^ = '[') Then
      Begin
        Result.ZeroBased := True;
        StrSkipChars(cur, CharIsWhiteSpace);
      End
      Else
        Dec(cur);
    End;
  End;
Begin
  Result := TJclTabSet.Create;
  Try
    Result.ZeroBased := False;
    cur := PChar(S);
    ParseZeroBasedFlag;
    ParseStops;
    ParseTabWidth;
  Except
    // clean up the partially complete instance (to avoid memory leaks)...
    Result.Free;
    // ... and re-raise the exception
    raise;
  End;
End;
Function TJclTabSet.GetCount: SizeInt;
Begin
  If Self <> nil Then
    Result := Length(TTabSetData(FData).FStops)
  Else
    Result := 0;
End;
Function TJclTabSet.GetStops(Index: SizeInt): SizeInt;
Begin
  If Self <> nil Then
  Begin
    If (Index < 0) or (Index >= Length(TTabSetData(FData).FStops)) Then
    Begin
      raise EJclStringError.CreateRes(@RsArgumentOutOfRange);
    End
    Else
      Result := TTabSetData(FData).FStops[Index];
  End
  Else
  Begin
    raise EJclStringError.CreateRes(@RsArgumentOutOfRange);
  End;
End;
Function TJclTabSet.GetTabWidth: SizeInt;
Begin
  If Self <> nil Then
    Result := TTabSetData(FData).FWidth
  Else
    Result := 0;
End;
Function TJclTabSet.GetZeroBased: Boolean;
Begin
  Result := (Self = nil) or TTabSetData(FData).FZeroBased;
End;
Procedure TJclTabSet.OptimalFillInfo(StartColumn, TargetColumn: SizeInt; out TabsNeeded, SpacesNeeded: SizeInt);
Var
  nextTab: SizeInt;
Begin
  If StartColumn < Self.StartColumn Then  // starting column less than 1 or 0 (depending on ZeroBased state)
    raise ArgumentOutOfRangeException.Create('StartColumn');
  If (TargetColumn < StartColumn) Then    // target lies before the starting column
    raise ArgumentOutOfRangeException.Create('TargetColumn');
  TabsNeeded := 0;
  Repeat
    nextTab := TabFrom(StartColumn);
    If nextTab <= TargetColumn Then
    Begin
      Inc(TabsNeeded);
      StartColumn := nextTab;
    End;
  Until nextTab > TargetColumn;
  SpacesNeeded := TargetColumn - StartColumn;
End;
Function TJclTabSet.Optimize(Const S: string): string;
Begin
  Result := Optimize(S, StartColumn);
End;
Function TJclTabSet.Optimize(Const S: string; Column: SizeInt): string;
Var
  sb: TJclStringBuilder;
  head: PChar;
  cur: PChar;
  tgt: SizeInt;
  Procedure AppendOptimalWhiteSpace(Target: SizeInt);
  Var
    tabCount: SizeInt;
    spaceCount: SizeInt;
  Begin
    If cur > head Then
    Begin
      OptimalFillInfo(Column, Target, tabCount, spaceCount);
      If tabCount > 0 Then
        sb.Append(#9, tabCount);
      If spaceCount > 0 Then
        sb.Append(' ', spaceCount);
    End;
  End;
Begin
  If Column < StartColumn Then
    raise ArgumentOutOfRangeException.Create('Column');
  sb := TJclStringBuilder.Create(Length(S));
  Try
    cur := PChar(s);
    While cur^ <> #0 Do
    Begin
      // locate first whitespace character
      head := cur;
      While (cur^ <> #0) and not CharIsWhiteSpace(cur^) Do
        Inc(cur);
      // output non whitespace characters
      If cur > head Then
        sb.Append(head, 0, cur - head);
      // advance column
      Inc(Column, cur - head);
      // initialize target column indexer
      tgt := Column;
      // locate end of whitespace sequence
      While CharIsWhiteSpace(cur^) Do
      Begin
        If CharIsReturn(cur^) Then
        Begin
          // append optimized whitespace sequence...
          AppendOptimalWhiteSpace(tgt);
          // ...set the column back to the start of the line...
          Column := StartColumn;
          // ...reset target column indexer...
          tgt := Column;
          // ...add the line break character...
          sb.Append(cur^);
        End
        Else
        If cur^ = #9 Then
          tgt := TabFrom(tgt)       // expand the tab
        Else
          Inc(tgt);                 // a normal whitespace; taking up 1 column
        Inc(cur);
      End;
      AppendOptimalWhiteSpace(tgt); // append optimized whitespace sequence...
      Column := tgt;                // ...and memorize the column for the next iteration
    End;
    Result := sb.ToString;          // convert result to a string
  Finally
    sb.Free;
  End;
End;
Procedure TJclTabSet.RemoveAt(Index: SizeInt);
Begin
  If Self <> nil Then
    TTabSetData(FData).RemoveAt(Index)
  Else
    raise NullReferenceException.Create;
End;
Procedure TJclTabSet.SetStops(Index, Value: SizeInt);
Begin
  If Self <> nil Then
    TTabSetData(FData).SetStops(Index, Value)
  Else
    raise NullReferenceException.Create;
End;
Procedure TJclTabSet.SetTabWidth(Value: SizeInt);
Begin
  If Self <> nil Then
  Begin
    TTabSetData(FData).FWidth := Value;
    TTabSetData(FData).CalcRealWidth;
  End
  Else
    raise NullReferenceException.Create;
End;
Procedure TJclTabSet.SetZeroBased(Value: Boolean);
Var
  shift: SizeInt;
  idx:   SizeInt;
Begin
  If Self <> nil Then
  Begin
    If Value <> TTabSetData(FData).FZeroBased Then
    Begin
      TTabSetData(FData).FZeroBased := Value;
      If Value Then
        shift := -1
      Else
        shift := 1;
      For idx := 0 To High(TTabSetData(FData).FStops) Do
        TTabSetData(FData).FStops[idx] := TTabSetData(FData).FStops[idx] + shift;
    End;
  End
  Else
    raise NullReferenceException.Create;
End;
Function TJclTabSet.InternalTabStops: TDynSizeIntArray;
Begin
  If Self <> nil Then
    Result := TTabSetData(FData).FStops
  Else
    Result := nil;
End;
Function TJclTabSet.InternalTabWidth: SizeInt;
Begin
  If Self <> nil Then
    Result := TTabSetData(FData).FRealWidth
  Else
    Result := 2;
End;
Function TJclTabSet.NewReference: TJclTabSet;
Begin
  If Self <> nil Then
    Result := TJclTabSet.Create(FData)
  Else
    Result := nil;
End;
Function TJclTabSet.StartColumn: SizeInt;
Begin
  If GetZeroBased Then
    Result := 0
  Else
    Result := 1;
End;
Function TJclTabSet.TabFrom(Column: SizeInt): SizeInt;
Begin
  If Column < StartColumn Then
    raise ArgumentOutOfRangeException.Create('Column');
  Result := FindStop(Column);
  If Result < 0 Then
    Result := not Result
  Else
    Inc(Result);
  If Result >= GetCount Then
  Begin
    If GetCount > 0 Then
      Result := TTabSetData(FData).FStops[High(TTabSetData(FData).FStops)]
    Else
      Result := StartColumn;
    While Result <= Column Do
      Inc(Result, ActualTabWidth);
  End
  Else
    Result := TTabSetData(FData).FStops[Result];
End;
Function TJclTabSet.ToString: string;
Begin
  Result := ToString(TabSetFormatting_Full);
End;
Function TJclTabSet.ToString(FormattingOptions: SizeInt): string;
Var
  sb: TJclStringBuilder;
  idx: SizeInt;
  Function WantBrackets: Boolean;
  Begin
    Result := (TabSetFormatting_SurroundStopsWithBrackets and FormattingOptions) <> 0;
  End;
  Function EmptyBrackets: Boolean;
  Begin
    Result := (TabSetFormatting_EmptyBracketsIfNoStops and FormattingOptions) <> 0;
  End;
  Function IncludeAutoWidth: Boolean;
  Begin
    Result := (TabSetFormatting_AutoTabWidth and FormattingOptions) <> 0;
  End;
  Function IncludeTabWidth: Boolean;
  Begin
    Result := (TabSetFormatting_NoTabWidth and FormattingOptions) = 0;
  End;
  Function IncludeStops: Boolean;
  Begin
    Result := (TabSetFormatting_NoTabStops and FormattingOptions) = 0;
  End;
Begin
  sb := TJclStringBuilder.Create;
  Try
    // output the fixed tabulation positions if requested...
    If IncludeStops Then
    Begin
      // output each individual tabulation position
      For idx := 0 To GetCount - 1 Do
      Begin
        sb.Append(TabStops[idx]);
        sb.Append(',');
      End;
      // remove the final comma if any tabulation positions where outputted
      If sb.Length <> 0 Then
        sb.Remove(sb.Length - 1, 1);
      // bracket the tabulation positions if requested
      If WantBrackets and (EmptyBrackets or (sb.Length > 0)) Then
      Begin
        sb.Insert(0, '[');
        sb.Append(']');
      End;
    End;
    // output the tab width if requested....
    If IncludeTabWidth and (IncludeAutoWidth or (TabWidth > 0)) Then
    Begin
      // separate the tab width from any outputted tabulation positions with a whitespace
      If sb.Length > 0 Then
        sb.Append(' ');
      // flag tab width
      sb.Append('+');
      // finally, output the tab width
      sb.Append(ActualTabWidth);
    End;
    // flag zero-based tabset by outputting a 0 (zero) as the first character.
    If ZeroBased Then
      sb.Insert(0, string('0 '));
    Result := StrTrimCharRight(sb.ToString, ' ');
  Finally
    sb.Free;
  End;
End;
Function TJclTabSet.UpdatePosition(Const S: string): SizeInt;
Var
  Line: SizeInt;
Begin
  Result := StartColumn;
  Line := -1;
  UpdatePosition(S, Result, Line);
End;
Function TJclTabSet.UpdatePosition(Const S: string; Column: SizeInt): SizeInt;
Var
  Line: SizeInt;
Begin
  If Column < StartColumn Then
    raise ArgumentOutOfRangeException.Create('Column');
  Result := Column;
  Line := -1;
  UpdatePosition(S, Result, Line);
End;
Function TJclTabSet.UpdatePosition(Const S: string; Var Column, Line: SizeInt): SizeInt;
Var
  prevChar: Char;
  cur:      PChar;
Begin
  If Column < StartColumn Then
    raise ArgumentOutOfRangeException.Create('Column');
  // initialize loop
  cur := PChar(S);
  // iterate until end of string (the Null-character)
  While cur^ <> #0 Do
  Begin
    // check for line-breaking characters
    If CharIsReturn(cur^) Then
    Begin
      // Column moves back all the way to the left
      Column := StartColumn;
      // If this is the first line-break character or the same line-break character, increment the Line parameter
      Inc(Line);
      // check if it's the first of a two-character line-break
      prevChar := cur^;
      Inc(cur);
      // if it isn't a two-character line-break, undo the previous advancement
      If (cur^ = prevChar) or not CharIsReturn(cur^) Then
        Dec(cur);
    End
    Else // check for tab character and expand it
    If cur^ = #9 Then
      Column := TabFrom(Column)
    Else // a normal character; increment column
      Inc(Column);
    // advance pointer
    Inc(cur);
  End;
  // set the result to the newly calculated column
  Result := Column;
End;
//=== { NullReferenceException } =============================================
Constructor NullReferenceException.Create;
Begin
  CreateRes(@RsArg_NullReferenceException);
End;
Function CompareNatural(Const S1, S2: string; CaseInsensitive: Boolean): SizeInt;
Var
  Cur1, Len1,
  Cur2, Len2: SizeInt;
  Function IsRealNumberChar(ch: Char): Boolean;
  Begin
    Result := ((ch >= '0') and (ch <= '9')) or (ch = '-') or (ch = '+');
  End;
  Procedure NumberCompare;
  Var
    IsReallyNumber: Boolean;
    FirstDiffBreaks: Boolean;
    Val1, Val2:     SizeInt;
  Begin
    Result := 0;
    IsReallyNumber := False;
    // count leading spaces in S1
    While (Cur1 <= Len1) and CharIsWhiteSpace(S1[Cur1]) Do
    Begin
      Dec(Result);
      Inc(Cur1);
    End;
    // count leading spaces in S2 (canceling them out against the ones in S1)
    While (Cur2 <= Len2) and CharIsWhiteSpace(S2[Cur2]) Do
    Begin
      Inc(Result);
      Inc(Cur2);
    End;
    // if spaces match, or both strings are actually followed by a numeric character, continue the checks
    If (Result = 0) or ((Cur1 <= Len1) and CharIsNumberChar(S1[Cur1]) and (Cur2 <= Len2) and CharIsNumberChar(S2[Cur2])) Then
    Begin
      // Check signed number
      If (Cur1 <= Len1) and (S1[Cur1] = '-') and ((Cur2 > Len2) or (S2[Cur2] <> '-')) Then
        Result := 1
      Else
      If (Cur2 <= Len2) and (S2[Cur2] = '-') and ((Cur1 > Len1) or (S1[Cur1] <> '-')) Then
        Result := -1
      Else
        Result := 0;
      If (Cur1 <= Len1) and ((S1[Cur1] = '-') or (S1[Cur1] = '+')) Then
        Inc(Cur1);
      If (Cur2 <= Len2) and ((S2[Cur2] = '-') or (S2[Cur2] = '+')) Then
        Inc(Cur2);
      FirstDiffBreaks := (Cur1 <= Len1) and (S1[Cur1] = '0') or (Cur2 <= Len2) and (S2[Cur2] = '0');
      While (Cur1 <= Len1) and CharIsDigit(S1[Cur1]) and (Cur2 <= Len2) and CharIsDigit(S2[Cur2]) Do
      Begin
        IsReallyNumber := True;
        Val1 := StrToInt(S1[Cur1]);
        Val2 := StrToInt(S2[Cur2]);
        If (Result = 0) and (Val1 < Val2) Then
          Result := -1
        Else
        If (Result = 0) and (Val1 > Val2) Then
          Result := 1;
        If FirstDiffBreaks and (Result <> 0) Then
          Break;
        Inc(Cur1);
        Inc(Cur2);
      End;
      If IsReallyNumber Then
      Begin
        If not FirstDiffBreaks Then
        Begin
          If (Cur1 <= Len1) and CharIsDigit(S1[Cur1]) Then
            Result := 1
          Else
          If (Cur2 <= Len2) and CharIsDigit(S2[Cur2]) Then
            Result := -1;
        End;
      End;
    End;
  End;
  Procedure SetByCompareLength;
  Var
    Remain1: SizeInt;
    Remain2: SizeInt;
  Begin
    // base result on relative compare length (spaces could be ignored, so even if S1 is longer than S2, they could be
    // completely equal, or S2 could be longer)
    Remain1 := Len1 - Cur1 + 1;
    Remain2 := Len2 - Cur2 + 1;
    If Remain1 < 0 Then
      Remain1 := 0;
    If Remain2 < 0 Then
      Remain2 := 0;
    If Remain1 < Remain2 Then
      Result := -1
    Else
    If Remain1 > Remain2 Then
      Result := 1;
  End;
Begin
  Cur1 := 1;
  Len1 := Length(S1);
  Cur2 := 1;
  Len2 := Length(S2);
  Result := 0;
  While (Result = 0) Do
  Begin
    If (Cur1 > Len1) or (Cur2 > Len2) Then
    Begin
      SetByCompareLength;
      Break;
    End
    Else
    If (Cur1 <= Len1) and (Cur2 > Len2) Then
      Result := 1
    Else
    If (S1[Cur1] = '-') and IsRealNumberChar(S2[Cur2]) and (S2[Cur2] <> '-') Then
      Result := -1
    Else
    If (S2[Cur2] = '-') and IsRealNumberChar(S1[Cur1]) and (S1[Cur1] <> '-') Then
      Result := 1
    Else
    If (IsRealNumberChar(S1[Cur1]) or CharIsWhiteSpace(S1[Cur1])) and (IsRealNumberChar(S2[Cur2]) or CharIsWhiteSpace(S2[Cur2])) Then
      NumberCompare
    Else
    Begin
      If CaseInsensitive Then
        Result := StrLIComp(PChar(@S1[Cur1]), PChar(@S2[Cur2]), 1)
      Else
        Result := StrLComp(PChar(@S1[Cur1]), PChar(@S2[Cur2]), 1);
      Inc(Cur1);
      Inc(Cur2);
    End;
  End;
End;

Initialization
{$IFNDEF UNICODE_RTL_DATABASE}
 LoadCharTypes;  // this table first
 LoadCaseMap;    // or this function does not work
{$ENDIF ~UNICODE_RTL_DATABASE}
End.
