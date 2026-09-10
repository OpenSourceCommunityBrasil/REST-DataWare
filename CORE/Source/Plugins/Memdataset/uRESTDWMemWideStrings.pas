Unit uRESTDWMemWideStrings;

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
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  {$IFDEF HAS_UNITSCOPE}
  System.Classes, System.SysUtils,
  {$ELSE ~HAS_UNITSCOPE}
  Classes, SysUtils,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase,
  uRESTDWProtoTypes;
// Exceptions
Type
  EJclWideStringError = Class(EJclError);
Const
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
Type
  {$IFDEF SUPPORTS_UNICODE}
  TJclWideStrings = {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}Classes.TStrings;
  TJclWideStringList = {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}Classes.TStringList;
  {$ELSE ~SUPPORTS_UNICODE}
  TWideFileOptionsType =
   (
    foAnsiFile,  // loads/writes an ANSI file
    foUnicodeLB  // reads/writes BOM_LSB_FIRST/BOM_MSB_FIRST
   );
  TWideFileOptions = set Of TWideFileOptionsType;
  TSearchFlag = (
    sfCaseSensitive,    // match letter case
    sfIgnoreNonSpacing, // ignore non-spacing characters in search
    sfSpaceCompress,    // handle several consecutive white spaces as one white space
                        // (this applies to the pattern as well as the search text)
    sfWholeWordOnly     // match only text at end/start and/or surrounded by white spaces
  );
  TSearchFlags = set Of TSearchFlag;
  TJclWideStrings = Class;
  TJclWideStringList = Class;
  TJclWideStringListSortCompare = Function(List: TJclWideStringList; Index1, Index2: Integer): Integer;
  TJclWideStrings = Class(TPersistent)
  Private
    FDelimiter: Char;
    FQuoteChar: Char;
    FNameValueSeparator: Char;
    FLineSeparator: DWWideString;
    FUpdateCount: Integer;
    Procedure ReadData(Reader: TReader);
    Procedure WriteData(Writer: TWriter);
  Protected
    Procedure DefineProperties(Filer: TFiler); override;
    Function GetP(Index: Integer): PString; virtual; abstract;
    Function Get(Index: Integer): DWWideString;
    Function GetCapacity: Integer; virtual;
    Function GetCount: Integer; virtual; abstract;
    Function GetObject(Index: Integer): TObject; virtual;
    Function GetTextStr: DWWideString; virtual;
    Procedure Put(Index: Integer; Const S: DWWideString); virtual; abstract;
    Procedure PutObject(Index: Integer; AObject: TObject); virtual; abstract;
    Procedure SetCapacity(NewCapacity: Integer); virtual;
    Procedure SetTextStr(Const Value: DWWideString); virtual;
    Procedure SetUpdateState(Updating: Boolean); virtual;
    property UpdateCount: Integer read FUpdateCount;
    Procedure AssignTo(Dest: TPersistent); override;
  Public
    Constructor Create;
    Function Add(Const S: DWWideString): Integer; virtual;
    Function AddObject(Const S: DWWideString; AObject: TObject): Integer; virtual;
    Procedure Append(Const S: DWWideString);
    Procedure AddStrings(Strings: TJclWideStrings); overload; virtual;
    Procedure AddStrings(Strings: TStrings); overload; virtual;
    Procedure Assign(Source: TPersistent); override;
    Function CreateAnsiStringList: TStrings;
    Procedure AddStringsTo(Dest: TStrings); virtual;
    Procedure BeginUpdate;
    Procedure Clear; virtual; abstract;
    Procedure Delete(Index: Integer); virtual; abstract;
    Procedure EndUpdate;
    Function Equals(Strings: TJclWideStrings): Boolean; {$IFDEF RTL200_UP}reintroduce; {$ENDIF RTL200_UP}overload;
    Function Equals(Strings: TStrings): Boolean; {$IFDEF RTL200_UP}reintroduce; {$ENDIF RTL200_UP}overload;
    Procedure Exchange(Index1, Index2: Integer); virtual;
    Function IndexOfObject(AObject: TObject): Integer; virtual;
    Procedure Insert(Index: Integer; Const S: DWWideString); virtual;
    Procedure InsertObject(Index: Integer; Const S: DWWideString;
      AObject: TObject); virtual;
    Procedure Move(CurIndex, NewIndex: Integer); virtual;
    Procedure SaveToFile(Const FileName: TFileName;
      WideFileOptions: TWideFileOptions = []); virtual;
    Procedure SaveToStream(Stream: TStream;
      WideFileOptions: TWideFileOptions = []); virtual;
    Procedure SetText(Text: PDWChar); virtual;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property Delimiter: Char read FDelimiter write FDelimiter;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property QuoteChar: Char read FQuoteChar write FQuoteChar;
    property NameValueSeparator: Char read FNameValueSeparator write FNameValueSeparator;
    property LineSeparator: DWWideString read FLineSeparator write FLineSeparator;
    property PStrings[Index: Integer]: PString read GetP;
    property Strings[Index: Integer]: DWWideString read Get write Put; default;
    property Text: DWWideString read GetTextStr write SetTextStr;
  End;
  // do not replace by JclUnicode.TWideStringList (speed and size issue)
  PWStringItem = ^TWStringItem;
  TWStringItem = Record
    FString: DWWideString;
    FObject: TObject;
  End;
  TJclWideStringList = Class(TJclWideStrings)
  Private
    FList: TList;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
  Protected
    Function GetItem(Index: Integer): PWStringItem;
    Procedure Changed; virtual;
    Procedure Changing; virtual;
    Function GetP(Index: Integer): PString; override;
    Function GetCapacity: Integer; override;
    Function GetCount: Integer; override;
    Function GetObject(Index: Integer): TObject; override;
    Procedure Put(Index: Integer; Const Value: DWWideString); override;
    Procedure PutObject(Index: Integer; AObject: TObject); override;
    Procedure SetCapacity(NewCapacity: Integer); override;
    Procedure SetUpdateState(Updating: Boolean); override;
  Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure Clear; override;
    Procedure Delete(Index: Integer); override;
    Procedure Exchange(Index1, Index2: Integer); override;
    // Find() also works with unsorted lists
    Procedure InsertObject(Index: Integer; Const S: DWWideString;
      AObject: TObject); override;
    Procedure CustomSort(Compare: TJclWideStringListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  End;
  {$ENDIF ~SUPPORTS_UNICODE}
  TWideStringList = TJclWideStringList;
  TWideStrings = TJclWideStrings;
  TJclUnicodeStringList = TJclWideStringList;
  TJclUnicodeStrings = TJclWideStrings;
  // OF deprecated?
  TWStringList = TJclWideStringList;
  TWStrings = TJclWideStrings;
// DWChar functions
Function CharToWideChar(Ch: DWChar): DWChar;
Function DWCharToChar(Ch: DWChar): DWChar;
// PDWChar functions
Procedure MoveWideChar(Const Source; Var Dest; Count: SizeInt);
Function StrEndW(Const Str: PDWChar): PDWChar;
Function StrMoveW(Dest: PDWChar; Const Source: PDWChar; Count: SizeInt): PDWChar;
Function StrCopyW(Dest: PDWChar; Const Source: PDWChar): PDWChar;
Function StrECopyW(Dest: PDWChar; Const Source: PDWChar): PDWChar;
Function StrLCopyW(Dest: PDWChar; Const Source: PDWChar; MaxLen: SizeInt): PDWChar;
Function StrPCopyWW(Dest: PDWChar; Const Source: DWWideString): PDWChar;
Function StrPLCopyWW(Dest: PDWChar; Const Source: DWWideString; MaxLen: SizeInt): PDWChar;
Function StrCatW(Dest: PDWChar; Const Source: PDWChar): PDWChar;
Function StrLCatW(Dest: PDWChar; Const Source: PDWChar; MaxLen: SizeInt): PDWChar;
Function StrScanW(Const Str: PDWChar; Ch: DWChar): PDWChar; overload;
Function StrScanW(Str: PDWChar; Chr: DWChar; StrLen: SizeInt): PDWChar; overload;
Function StrRScanW(Const Str: PDWChar; Chr: DWChar): PDWChar;
Function StrAllocW(WideSize: SizeInt): PDWChar;
Function StrBufSizeW(Const Str: PDWChar): SizeInt;
Procedure StrDisposeW(Str: PDWChar);
Procedure StrDisposeAndNilW(Var Str: PDWChar);
// DWWideString functions
Function WideUpperCase(Const S: DWWideString): DWWideString;
Function WideLowerCase(Const S: DWWideString): DWWideString;
Function TrimW(Const S: DWWideString): DWWideString;
Function TrimLeftW(Const S: DWWideString): DWWideString;
Function TrimRightW(Const S: DWWideString): DWWideString;
Function TrimLeftLengthW(Const S: DWWideString): SizeInt;
Function TrimRightLengthW(Const S: DWWideString): SizeInt;
// MultiSz Routines
Type
  PWideMultiSz = PDWChar;
Procedure AllocateMultiSz(Var Dest: PWideMultiSz; Len: SizeInt);
Procedure FreeMultiSz(Var Dest: PWideMultiSz);
Implementation
Uses
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
  uRESTDWMemResources,
  uRESTDWConsts;
  
Procedure SwapWordByteOrder(P: PDWChar; Len: SizeInt);
Begin
  While Len > 0 Do
  Begin
    Dec(Len);
    P^ := DWChar((Word(P^) shr 8) or (Word(P^) shl 8));
    Inc(P);
  End;
End;
//=== DWChar functions =====================================================
Function CharToWideChar(Ch: DWChar): DWChar;
Var
  WS: DWWideString;
Begin
  WS := DWChar(Ch);
  Result := DWChar(WS[1]);
End;
Function DWCharToChar(Ch: DWChar): DWChar;
Var
  S: DWWideString;
Begin
  S := Ch;
  Result := DWChar(S[1]);
End;
//=== PDWChar functions ====================================================
Procedure MoveWideChar(Const Source; Var Dest; Count: SizeInt);
Begin
  Move(Source, Dest, Count * SizeOf(WideChar));
End;
Function StrAllocW(WideSize: SizeInt): PDWChar;
Begin
  WideSize := SizeOf(WideChar) * WideSize + SizeOf(SizeInt);
  Result := AllocMem(WideSize);
  SizeInt(Pointer(Result)^) := WideSize;
  Inc(Result, SizeOf(SizeInt) div SizeOf(WideChar));
End;
Procedure StrDisposeW(Str: PDWChar);
// releases a string allocated with StrNewW or StrAllocW
Begin
  If Str <> nil Then
  Begin
    Dec(Str, SizeOf(SizeInt) div SizeOf(WideChar));
    FreeMem(Str);
  End;
End;
Procedure StrDisposeAndNilW(Var Str: PDWChar);
Var
  Buff: PDWChar;
Begin
  Buff := Str;
  Str := nil;
  StrDisposeW(Buff);
End;
Const
  // data used to bring UTF-16 coded strings into correct UTF-32 order for correct comparation
  UTF16Fixup: array [0..31] Of Word = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    $2000, $F800, $F800, $F800, $F800
  );
Function StrLCompW(Const Str1, Str2: PDWChar; MaxLen: SizeInt): SizeInt;
// compares strings up to MaxLen code points
// see also StrCompW
Var
  S1, S2: PDWChar;
  C1, C2: Word;
Begin
  If MaxLen > 0 Then
  Begin
    S1 := Str1;
    S2 := Str2;
    Repeat
      C1 := Word(S1^);
      C1 := Word(C1 or UTF16Fixup[C1 shr 11]);
      C2 := Word(S2^);
      C2 := Word(C2 or UTF16Fixup[C2 shr 11]);
      // now C1 and C2 are in UTF-32-compatible order
      { TODO : surrogates take up 2 words and are counted twice here, count them only once }
      Result := SizeInt(C1) - SizeInt(C2);
      Dec(MaxLen);
      If(Result <> 0) or (C1 = 0) or (C2 = 0) or (MaxLen = 0) Then
        Break;
      Inc(S1);
      Inc(S2);
    Until False;
  End
  Else
    Result := 0;
End;
Function StrScanW(Const Str: PDWChar; Ch: DWChar): PDWChar;
Begin
  Result := Str;
  If Result <> nil Then
  Begin
    While (Result^ <> #0) and (Result^ <> Ch) Do
      Inc(Result);
    If (Result^ = #0) and (Ch <> #0) Then
      Result := nil;
  End;
End;
Function StrEndW(Const Str: PDWChar): PDWChar;
Begin
  Result := Str;
  If Result <> nil Then
    While Result^ <> #0 Do
      Inc(Result);
End;
Function StrCopyW(Dest: PDWChar; Const Source: PDWChar): PDWChar;
Var
  Src: PDWChar;
Begin
  Result := Dest;
  If Dest <> nil Then
  Begin
    Src := Source;
    If Src <> nil Then
      While Src^ <> #0 Do
      Begin
        Dest^ := Src^;
        Inc(Src);
        Inc(Dest);
      End;
    Dest^ := #0;
  End;
End;
Function StrECopyW(Dest: PDWChar; Const Source: PDWChar): PDWChar;
Var
  Src: PDWChar;
Begin
  If Dest <> nil Then
  Begin
    Src := Source;
    If Src <> nil Then
      While Src^ <> #0 Do
      Begin
        Dest^ := Src^;
        Inc(Src);
        Inc(Dest);
      End;
    Dest^ := #0;
  End;
  Result := Dest;
End;
Function StrLCopyW(Dest: PDWChar; Const Source: PDWChar; MaxLen: SizeInt): PDWChar;
Var
  Src: PDWChar;
Begin
  Result := Dest;
  If (Dest <> nil) and (MaxLen > 0) Then
  Begin
    Src := Source;
    If Src <> nil Then
      While (MaxLen > 0) and (Src^ <> #0) Do
      Begin
        Dest^ := Src^;
        Inc(Src);
        Inc(Dest);
        Dec(MaxLen);
      End;
    Dest^ := #0;
  End;
End;
Function StrCatW(Dest: PDWChar; Const Source: PDWChar): PDWChar;
Begin
  Result := Dest;
  StrCopyW(StrEndW(Dest), Source);
End;
Function StrLCatW(Dest: PDWChar; Const Source: PDWChar; MaxLen: SizeInt): PDWChar;
Begin
  Result := Dest;
  StrLCopyW(StrEndW(Dest), Source, MaxLen);
End;
Function StrMoveW(Dest: PDWChar; Const Source: PDWChar; Count: SizeInt): PDWChar;
Begin
  Result := Dest;
  If Count > 0 Then
    Move(Source^, Dest^, Count * SizeOf(WideChar));
End;
Function StrPCopyWW(Dest: PDWChar; Const Source: DWWideString): PDWChar;
Begin
  Result := StrLCopyW(Dest, PDWChar(Source), Length(Source));
End;
Function StrPLCopyWW(Dest: PDWChar; Const Source: DWWideString; MaxLen: SizeInt): PDWChar;
Begin
  Result := StrLCopyW(Dest, PDWChar(Source), MaxLen);
End;
Function StrRScanW(Const Str: PDWChar; Chr: DWChar): PDWChar;
Var
  P: PDWChar;
Begin
  Result := nil;
  If Str <> nil Then
  Begin
    P := Str;
    Repeat
      If P^ = Chr Then
        Result := P;
      Inc(P);
    Until P^ = #0;
  End;
End;
// Returns a pointer to first occurrence of a specified character in a string
// or nil if not found.
// Note: this is just a binary search for the specified character and there's no
//       check for a terminating null. Instead at most StrLen characters are
//       searched. This makes this function extremly fast.
//
Function StrScanW(Str: PDWChar; Chr: DWChar; StrLen: SizeInt): PDWChar;
Begin
  Result := Str;
  While StrLen > 0 Do
  Begin
    If Result^ = Chr Then
      Exit;
    Inc(Result);
  End;
  Result := nil;
End;
Function StrBufSizeW(Const Str: PDWChar): SizeInt;
// Returns max number of wide characters that can be stored in a buffer
// allocated by StrAllocW.
Var
  P: PDWChar;
Begin
  If Str <> nil Then
  Begin
    P := Str;
    Dec(P, SizeOf(SizeInt) div SizeOf(WideChar));
    Result := (PSizeInt(P)^ - SizeOf(SizeInt)) div SizeOf(WideChar);
  End
  Else
    Result := 0;
End;

Function TrimW(Const S: DWWideString): DWWideString;
// available from Delphi 7 up
{$IFDEF RTL150_UP}
Begin
  Result := Trim(S);
End;
{$ELSE ~RTL150_UP}
Var
  I, L: SizeInt;
Begin
  L := Length(S);
  I := 1;
  While (I <= L) and (S[I] <= ' ') Do
    Inc(I);
  If I > L Then
    Result := ''
  Else
  Begin
    While S[L] <= ' ' Do
      Dec(L);
    Result := Copy(S, I, L - I + 1);
  End;
End;
{$ENDIF ~RTL150_UP}
Function TrimLeftW(Const S: DWWideString): DWWideString;
// available from Delphi 7 up
{$IFDEF RTL150_UP}
Begin
  Result := TrimLeft(S);
End;
{$ELSE ~RTL150_UP}
Var
  I, L: SizeInt;
Begin
  L := Length(S);
  I := 1;
  While (I <= L) and (S[I] <= ' ') Do
    Inc(I);
  Result := Copy(S, I, Maxint);
End;
{$ENDIF ~RTL150_UP}
Function TrimRightW(Const S: DWWideString): DWWideString;
// available from Delphi 7 up
{$IFDEF RTL150_UP}
Begin
  Result := TrimRight(S);
End;
{$ELSE ~RTL150_UP}
Var
  I: SizeInt;
Begin
  I := Length(S);
  While (I > 0) and (S[I] <= ' ') Do
    Dec(I);
  Result := Copy(S, 1, I);
End;
{$ENDIF ~RTL150_UP}
Function WideUpperCase(Const S: DWWideString): DWWideString;
Begin
  Result := S;
  If Result <> '' Then
    {$IFDEF MSWINDOWS}
    CharUpperBuffW(Pointer(Result), Length(Result));
    {$ELSE ~MSWINDOWS}
    { TODO : Don't cheat here }
    Result := UpperCase(Result);
    {$ENDIF ~MSWINDOWS}
End;
Function WideLowerCase(Const S: DWWideString): DWWideString;
Begin
  Result := S;
  If Result <> '' Then
    {$IFDEF MSWINDOWS}
    CharLowerBuffW(Pointer(Result), Length(Result));
    {$ELSE ~MSWINDOWS}
    { TODO : Don't cheat here }
    Result := LowerCase(Result);
    {$ENDIF ~MSWINDOWS}
End;
Function TrimLeftLengthW(Const S: DWWideString): SizeInt;
Var
  Len: SizeInt;
Begin
  Len := Length(S);
  Result := 1;
  While (Result <= Len) and (S[Result] <= #32) Do
    Inc(Result);
  Result := Len - Result + 1;
End;
Function TrimRightLengthW(Const S: DWWideString): SizeInt;
Begin
  Result := Length(S);
  While (Result > 0) and (S[Result] <= #32) Do
    Dec(Result);
End;
{$IFNDEF SUPPORTS_UNICODE}
//=== { TJclWideStrings } ==========================================================
Constructor TJclWideStrings.Create;
Begin
  Inherited Create;
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
End;
Function TJclWideStrings.Add(Const S: DWWideString): Integer;
Begin
  Result := AddObject(S, nil);
End;
Function TJclWideStrings.AddObject(Const S: DWWideString; AObject: TObject): Integer;
Begin
  Result := Count;
  InsertObject(Result, S, AObject);
End;
Procedure TJclWideStrings.AddStrings(Strings: TJclWideStrings);
Var
  I: Integer;
Begin
  For I := 0 To Strings.Count - 1 Do
    AddObject(Strings.GetP(I)^, Strings.Objects[I]);
End;
Procedure TJclWideStrings.AddStrings(Strings: TStrings);
Var
  I: Integer;
Begin
  For I := 0 To Strings.Count - 1 Do
    AddObject(Strings.Strings[I], Strings.Objects[I]);
End;
Procedure TJclWideStrings.AddStringsTo(Dest: TStrings);
Var
  I: Integer;
Begin
  For I := 0 To Count - 1 Do
    Dest.AddObject(GetP(I)^, Objects[I]);
End;
Procedure TJclWideStrings.Append(Const S: DWWideString);
Begin
  Add(S);
End;
Procedure TJclWideStrings.Assign(Source: TPersistent);
Begin
  If Source is TJclWideStrings Then
  Begin
    BeginUpdate;
    Try
      Clear;
      FDelimiter := TJclWideStrings(Source).FDelimiter;
      FNameValueSeparator := TJclWideStrings(Source).FNameValueSeparator;
      FQuoteChar := TJclWideStrings(Source).FQuoteChar;
      AddStrings(TJclWideStrings(Source));
    Finally
      EndUpdate;
    End;
  End
  Else
  If Source is TStrings Then
  Begin
    BeginUpdate;
    Try
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
    Finally
      EndUpdate;
    End;
  End
  Else
    Inherited Assign(Source);
End;
Procedure TJclWideStrings.AssignTo(Dest: TPersistent);
Var
  I: Integer;
Begin
  If Dest is TStrings Then
  Begin
    TStrings(Dest).BeginUpdate;
    Try
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
      For I := 0 To Count - 1 Do
        TStrings(Dest).AddObject(GetP(I)^, Objects[I]);
    Finally
      TStrings(Dest).EndUpdate;
    End;
  End
  Else
    Inherited AssignTo(Dest);
End;
Procedure TJclWideStrings.BeginUpdate;
Begin
  If FUpdateCount = 0 Then
    SetUpdateState(True);
  Inc(FUpdateCount);
End;
Function TJclWideStrings.CreateAnsiStringList: TStrings;
Var
  I: Integer;
Begin
  Result := TStringList.Create;
  Try
    Result.BeginUpdate;
    For I := 0 To Count - 1 Do
      Result.AddObject(GetP(I)^, Objects[I]);
    Result.EndUpdate;
  Except
    Result.Free;
    raise;
  End;
End;
Procedure TJclWideStrings.DefineProperties(Filer: TFiler);
  Function DoWrite: Boolean;
  Begin
    If Filer.Ancestor <> nil Then
    Begin
      Result := True;
      If Filer.Ancestor is TJclWideStrings Then
        Result := not Equals(TJclWideStrings(Filer.Ancestor))
    End
    Else
      Result := Count > 0;
  End;
Begin
  Filer.DefineProperty('Strings', ReadData, WriteData, DoWrite);
End;
Procedure TJclWideStrings.EndUpdate;
Begin
  Dec(FUpdateCount);
  If FUpdateCount = 0 Then
    SetUpdateState(False);
End;
Function TJclWideStrings.Equals(Strings: TStrings): Boolean;
Var
  I: Integer;
Begin
  Result := False;
  If Strings.Count = Count Then
  Begin
    For I := 0 To Count - 1 Do
      If Strings[I] <> PStrings[I]^ Then
        Exit;
    Result := True;
  End;
End;
Function TJclWideStrings.Equals(Strings: TJclWideStrings): Boolean;
Var
  I: Integer;
Begin
  Result := False;
  If Strings.Count = Count Then
  Begin
    For I := 0 To Count - 1 Do
      If Strings[I] <> PStrings[I]^ Then
        Exit;
    Result := True;
  End;
End;
Procedure TJclWideStrings.Exchange(Index1, Index2: Integer);
Var
  TempObject: TObject;
  TempString: DWWideString;
Begin
  BeginUpdate;
  Try
    TempString := PStrings[Index1]^;
    TempObject := Objects[Index1];
    PStrings[Index1]^ := PStrings[Index2]^;
    Objects[Index1] := Objects[Index2];
    PStrings[Index2]^ := TempString;
    Objects[Index2] := TempObject;
  Finally
    EndUpdate;
  End;
End;
Function TJclWideStrings.Get(Index: Integer): DWWideString;
Begin
  Result := GetP(Index)^;
End;
Function TJclWideStrings.GetCapacity: Integer;
Begin
  Result := Count;
End;
Function TJclWideStrings.GetObject(Index: Integer): TObject;
Begin
  Result := nil;
End;
Function TJclWideStrings.GetTextStr: DWWideString;
Var
  I: Integer;
  Len, LL: Integer;
  P: PDWChar;
  W: PString;
Begin
  Len := 0;
  LL := Length(LineSeparator);
  For I := 0 To Count - 1 Do
    Inc(Len, Length(GetP(I)^) + LL);
  SetLength(Result, Len);
  P := PDWChar(Result);
  For I := 0 To Count - 1 Do
  Begin
    W := GetP(I);
    Len := Length(W^);
    If Len > 0 Then
    Begin
      MoveWideChar(W^[1], P^, Len);
      Inc(P, Len);
    End;
    If LL > 0 Then
    Begin
      MoveWideChar(FLineSeparator[1], P^, LL);
      Inc(P, LL);
    End;
  End;
End;
Function TJclWideStrings.IndexOfObject(AObject: TObject): Integer;
Begin
  For Result := 0 To Count - 1 Do
    If Objects[Result] = AObject Then
      Exit;
  Result := -1;
End;
Procedure TJclWideStrings.Insert(Index: Integer; Const S: DWWideString);
Begin
  InsertObject(Index, S, nil);
End;
Procedure TJclWideStrings.InsertObject(Index: Integer; Const S: DWWideString; AObject: TObject);
Begin
End;
Procedure TJclWideStrings.Move(CurIndex, NewIndex: Integer);
Var
  TempObject: TObject;
  TempString: DWWideString;
Begin
  If CurIndex <> NewIndex Then
  Begin
    BeginUpdate;
    Try
      TempString := GetP(CurIndex)^;
      TempObject := GetObject(CurIndex);
      Delete(CurIndex);
      InsertObject(NewIndex, TempString, TempObject);
    Finally
      EndUpdate;
    End;
  End;
End;
Procedure TJclWideStrings.ReadData(Reader: TReader);
Begin
  BeginUpdate;
  Try
    Clear;
    Reader.ReadListBegin;
    While not Reader.EndOfList Do
      If Reader.NextValue in [vaLString, vaString] Then
        Add(Reader.ReadString)
      Else
        Add(Reader.ReadString);
    Reader.ReadListEnd;
  Finally
    EndUpdate;
  End;
End;
Procedure TJclWideStrings.SaveToFile(Const FileName: TFileName; WideFileOptions: TWideFileOptions = []);
Var
  Stream: TFileStream;
Begin
  Stream := TFileStream.Create(FileName, fmCreate);
  Try
    SaveToStream(Stream, WideFileOptions);
  Finally
    Stream.Free;
  End;
End;
Procedure TJclWideStrings.SaveToStream(Stream: TStream; WideFileOptions: TWideFileOptions = []);
Var
  AnsiS: String;
  WideS: DWWideString;
  WC: DWChar;
Begin
  If foAnsiFile in WideFileOptions Then
  Begin
    AnsiS := String(GetTextStr); // explicit Unicode conversion
    Stream.Write(AnsiS[1], Length(AnsiS) * SizeOf(Char));
  End
  Else
  Begin
    If foUnicodeLB in WideFileOptions Then
    Begin
      WC := BOM_LSB_FIRST;
      Stream.Write(WC, SizeOf(WC));
    End;
    WideS := GetTextStr;
    Stream.Write(WideS[1], Length(WideS) * SizeOf(WideChar));
  End;
End;
Procedure TJclWideStrings.SetCapacity(NewCapacity: Integer);
Begin
End;
Procedure TJclWideStrings.SetText(Text: PDWChar);
Begin
  SetTextStr(DWString(Text^));
End;
Procedure TJclWideStrings.SetTextStr(Const Value: DWWideString);
Var
  P, Start: PDWWideString;
  S: String;
  Len: Integer;
Begin
  BeginUpdate;
  Try
    Clear;
    If Value <> '' Then
    Begin
      P := @Value;
      If P <> nil Then
      Begin
        While P^[InitStrPos] <> DWChar(0) Do
        Begin
          Start := P;
          While True Do
          Begin
            Case P^[InitStrPos] Of
              DWChar(0), DWChar(10), DWChar(13):
                Break;
            End;
            Inc(P);
          End;
          Len := Length(P^) - Length(Start^);
          If Len > 0 Then
          Begin
            SetString(S, PChar(@Start), Len);
            AddObject(S, nil); // consumes most time
          End
          Else
            AddObject('', nil);
          If P^[InitStrPos] = DWChar(13) Then
            Inc(P);
          If P^[InitStrPos] = DWChar(10) Then
            Inc(P);
        End;
      End;
    End;
  Finally
    EndUpdate;
  End;
End;
Procedure TJclWideStrings.SetUpdateState(Updating: Boolean);
Begin
End;
Procedure TJclWideStrings.WriteData(Writer: TWriter);
Var
  I: Integer;
Begin
  Writer.WriteListBegin;
  For I := 0 To Count - 1 Do
     Writer.WriteString(GetP(I)^);
  Writer.WriteListEnd;
End;
//=== { TJclWideStringList } =======================================================
Constructor TJclWideStringList.Create;
Begin
  Inherited Create;
  FList := TList.Create;
End;
Destructor TJclWideStringList.Destroy;
Begin
  FOnChange := nil;
  FOnChanging := nil;
  Inc(FUpdateCount); // do not call unnecessary functions
  Clear;
  FList.Free;
  Inherited Destroy;
End;
Procedure TJclWideStringList.Changed;
Begin
  If Assigned(FOnChange) Then
    FOnChange(Self);
End;
Procedure TJclWideStringList.Changing;
Begin
  If Assigned(FOnChanging) Then
    FOnChanging(Self);
End;
Procedure TJclWideStringList.Clear;
Var
  I: Integer;
  Item: PWStringItem;
Begin
  If FUpdateCount = 0 Then
    Changing;
  For I := 0 To Count - 1 Do
  Begin
    Item := PWStringItem(FList[I]);
    Item.FString := '';
    FreeMem(Item);
  End;
  FList.Clear;
  If FUpdateCount = 0 Then
    Changed;
End;
threadvar
  CustomSortList: TJclWideStringList;
  CustomSortCompare: TJclWideStringListSortCompare;
Function WStringListCustomSort(Item1, Item2: Pointer): Integer;
Begin
  Result := CustomSortCompare(CustomSortList,
    CustomSortList.FList.IndexOf(Item1),
    CustomSortList.FList.IndexOf(Item2));
End;
Procedure TJclWideStringList.CustomSort(Compare: TJclWideStringListSortCompare);
Var
  TempList: TJclWideStringList;
  TempCompare: TJclWideStringListSortCompare;
Begin
  TempList := CustomSortList;
  TempCompare := CustomSortCompare;
  CustomSortList := Self;
  CustomSortCompare := Compare;
  Try
    Changing;
    FList.Sort(WStringListCustomSort);
    Changed;
  Finally
    CustomSortList := TempList;
    CustomSortCompare := TempCompare;
  End;
End;
Procedure TJclWideStringList.Delete(Index: Integer);
Var
  Item: PWStringItem;
Begin
  If FUpdateCount = 0 Then
    Changing;
  Item := PWStringItem(FList[Index]);
  FList.Delete(Index);
  Item.FString := '';
  FreeMem(Item);
  If FUpdateCount = 0 Then
    Changed;
End;
Procedure TJclWideStringList.Exchange(Index1, Index2: Integer);
Begin
  If FUpdateCount = 0 Then
    Changing;
  FList.Exchange(Index1, Index2);
  If FUpdateCount = 0 Then
    Changed;
End;
Function TJclWideStringList.GetCapacity: Integer;
Begin
  Result := FList.Capacity;
End;
Function TJclWideStringList.GetCount: Integer;
Begin
  Result := FList.Count;
End;
Function TJclWideStringList.GetItem(Index: Integer): PWStringItem;
Begin
  Result := FList[Index];
End;
Function TJclWideStringList.GetObject(Index: Integer): TObject;
Begin
  Result := GetItem(Index).FObject;
End;
Function TJclWideStringList.GetP(Index: Integer): PString;
Begin
  Result := Addr(GetItem(Index).FString);
End;
Procedure TJclWideStringList.InsertObject(Index: Integer; Const S: DWWideString;
  AObject: TObject);
Var
  P: PWStringItem;
Begin
  If FUpdateCount = 0 Then
    Changing;
  FList.Insert(Index, nil); // error check
  P := AllocMem(SizeOf(TWStringItem));
  FList[Index] := P;
  Put(Index, S);
  If AObject <> nil Then
    PutObject(Index, AObject);
  If FUpdateCount = 0 Then
    Changed;
End;
Procedure TJclWideStringList.Put(Index: Integer; Const Value: DWWideString);
Begin
  If FUpdateCount = 0 Then
    Changing;
  GetItem(Index).FString := Value;
  If FUpdateCount = 0 Then
    Changed;
End;
Procedure TJclWideStringList.PutObject(Index: Integer; AObject: TObject);
Begin
  If FUpdateCount = 0 Then
    Changing;
  GetItem(Index).FObject := AObject;
  If FUpdateCount = 0 Then
    Changed;
End;
Procedure TJclWideStringList.SetCapacity(NewCapacity: Integer);
Begin
  FList.Capacity := NewCapacity;
End;
Procedure TJclWideStringList.SetUpdateState(Updating: Boolean);
Begin
  If Updating Then
    Changing
  Else
    Changed;
End;
{$ENDIF ~SUPPORTS_UNICODE}
Procedure AllocateMultiSz(Var Dest: PWideMultiSz; Len: SizeInt);
Begin
  If Len > 0 Then
    GetMem(Dest, Len * SizeOf(WideChar))
  Else
    Dest := nil;
End;
Procedure FreeMultiSz(Var Dest: PWideMultiSz);
Begin
  If Dest <> nil Then
    FreeMem(Dest);
  Dest := nil;
End;
{$IFDEF UNITVERSIONING}
Initialization
 RegisterUnitVersion(HInstance, UnitVersioning);
Finalization
 UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
End.
