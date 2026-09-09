Unit uRESTDWMemBase;
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
  uRESTDWMemConsts,
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.SysUtils
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils
  {$ENDIF ~HAS_UNITSCOPE},
  uRESTDWProtoTypes;
// Version
Const
  {$IFDEF UNIX}
  // renamed to DirDelimiter
  // PathSeparator    = '/';
  DirDelimiter = '/';
  DirSeparator = ':';
  {$ENDIF UNIX}
  {$IFDEF MSWINDOWS}
  PathDevicePrefix = '\\.\';
  // renamed to DirDelimiter
  // PathSeparator    = '\';
  DirDelimiter = '\';
  DirSeparator = ';';
  PathUncPrefix    = '\\';
  {$ENDIF MSWINDOWS}
  JclVersionMajor   = 2;    // 0=pre-release|beta/1, 2, ...=final
  JclVersionMinor   = 8;    // Fifth minor release since JCL 1.90
  JclVersionRelease = 0;    // 0: pre-release|beta/ 1: release
  JclVersionBuild   = 5677; // build number, days since march 1, 2000
  JclVersion = (JclVersionMajor shl 24) or (JclVersionMinor shl 16) or
    (JclVersionRelease shl 15) or (JclVersionBuild shl 0);
// EJclError
Type
  EJclError = Class(Exception);
// EJclInternalError
Type
  EJclInternalError = Class(EJclError);
// Types
Type
 {$IFDEF FPC}
  Float  = Single;
 {$ELSE}
  Float = Single;
 {$ENDIF}
 PFloat = ^Float;
Type
  {$IFDEF FPC}
   Largeint = Int64;
   SizeInt  = Integer;
  {$ELSE}
   SizeInt = Integer;
   PSizeInt = ^SizeInt;
   PPointer = ^Pointer;
   PByte = System.PByte;
   Int8 = ShortInt;
   Int16 = Smallint;
   Int32 = Integer;
   UInt8 = Byte;
   UInt16 = Word;
   UInt32 = LongWord;
   PCardinal = ^Cardinal;
   {$IFNDEF COMPILER7_UP}
    UInt64 = Int64;
   {$ENDIF ~COMPILER7_UP}
    PAnsiChar = ^DWString;
    PWideChar = System.PWideChar;
    PPWideChar = ^PWideChar;
    PPAnsiChar = ^PAnsiChar;
    PInt64 = Type System.PInt64;
   {$ENDIF}
  PPInt64 = ^PInt64;
  PPPAnsiChar = ^PPAnsiChar;
{$IFNDEF FPC}
Type
  PLargeInteger = ^TLargeInteger;
  TLargeInteger = Int64;
{$ENDIF ~FPC}
{$IFNDEF COMPILER11_UP}
Type
  TBytes = array Of Byte;
{$ENDIF ~COMPILER11_UP}
// Redefinition of PByteArray to avoid range check exceptions.
Type
  TJclByteArray = array [0..MaxInt div SizeOf(Byte) - 1] Of Byte;
  PJclByteArray = ^TJclByteArray;
  TJclBytes = Pointer; // under .NET System.pas: TBytes = array of Byte;
// Redefinition of ULARGE_INTEGER to relieve dependency on Windows.pas
Type
  {$IFNDEF FPC}
  PULARGE_INTEGER = ^ULARGE_INTEGER;
  {$EXTERNALSYM PULARGE_INTEGER}
  ULARGE_INTEGER = Record
    Case Integer Of
    0:
     (LowPart: LongWord;
      HighPart: LongWord);
    1:
     (QuadPart: Int64);
  End;
  {$EXTERNALSYM ULARGE_INTEGER}
  {$ENDIF ~FPC}
  TJclULargeInteger = ULARGE_INTEGER;
  PJclULargeInteger = PULARGE_INTEGER;
  {$IFNDEF COMPILER16_UP}
  LONG = Longint;
  {$EXTERNALSYM LONG}
  {$ENDIF ~COMPILER16_UP}
// Dynamic Array support
Type
  TDynByteArray          = array Of Byte;
  TDynShortIntArray      = array Of Shortint;
  TDynWordArray          = array Of Word;
  TDynSmallIntArray      = array Of Smallint;
  TDynLongIntArray       = array Of Longint;
  TDynInt64Array         = array Of Int64;
  TDynCardinalArray      = array Of Cardinal;
  TDynIntegerArray       = array Of Integer;
  TDynSizeIntArray       = array Of SizeInt;
  TDynExtendedArray      = array Of Extended;
  TDynDoubleArray        = array Of Double;
  TDynSingleArray        = array Of Single;
  TDynFloatArray         = array Of Float;
  TDynPointerArray       = array Of Pointer;
  TDynStringArray        = array Of string;
  TDynAnsiStringArray    = array Of DwString;
  TDynWideStringArray    = array Of DwWideString;
  {$IFDEF SUPPORTS_UNICODE_STRING}
  TDynUnicodeStringArray = array Of UnicodeString;
  {$ENDIF SUPPORTS_UNICODE_STRING}
  TDynIInterfaceArray    = array Of IInterface;
  TDynObjectArray        = array Of TObject;
  TDynCharArray       = array Of Char;
  TDynAnsiCharArray   = array Of DwChar;
  TDynWideCharArray   = array Of WideChar;
// Cross-Platform Compatibility
Const
  // line delimiters for a version of Delphi/C++Builder
  NativeLineFeed       = Char(#10);
  NativeCarriageReturn = Char(#13);
  NativeCrLf           = string(#13#10);
  // default line break for a version of Delphi on a platform
  {$IFDEF MSWINDOWS}
  NativeLineBreak      = NativeCrLf;
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  NativeLineBreak      = NativeLineFeed;
  {$ENDIF UNIX}
  HexPrefixPascal = string('$');
  HexPrefixC      = string('0x');
  HexDigitFmt32   = string('%.8x');
  HexDigitFmt64   = string('%.16x');
  HexPrefix       = HexPrefixPascal;
  {$IFDEF FPC}
   {$IFDEF CPU32}
   HexDigitFmt     = HexDigitFmt32;
   {$ENDIF CPU32}
   {$IFDEF CPU64}
   HexDigitFmt     = HexDigitFmt64;
   {$ENDIF CPU64}
  {$ELSE}
   {$IF Defined(CPUX32)}
   HexDigitFmt     = HexDigitFmt32;
   {$ELSEIF CPUX64}
   HexDigitFmt     = HexDigitFmt64;
   {$ELSE}
    HexDigitFmt     = HexDigitFmt32;
   {$IFEND}
  {$ENDIF}
  HexFmt = HexPrefix + HexDigitFmt;
Const
  BOM_UTF16_LSB: array [0..1] Of Byte = ($FF,$FE);
  BOM_UTF16_MSB: array [0..1] Of Byte = ($FE,$FF);
  BOM_UTF8: array [0..2] Of Byte = ($EF,$BB,$BF);
  BOM_UTF32_LSB: array [0..3] Of Byte = ($FF,$FE,$00,$00);
  BOM_UTF32_MSB: array [0..3] Of Byte = ($00,$00,$FE,$FF);
//  BOM_UTF7_1: array [0..3] of Byte = ($2B,$2F,$76,$38);
//  BOM_UTF7_2: array [0..3] of Byte = ($2B,$2F,$76,$39);
//  BOM_UTF7_3: array [0..3] of Byte = ($2B,$2F,$76,$2B);
//  BOM_UTF7_4: array [0..3] of Byte = ($2B,$2F,$76,$2F);
//  BOM_UTF7_5: array [0..3] of Byte = ($2B,$2F,$76,$38,$2D);
Type
  // Unicode transformation formats (UTF) data types
  PUTF7 = ^UTF7;
  UTF7 = DwChar;
  PUTF8 = ^UTF8;
  UTF8 = DwChar;
  PUTF16 = ^UTF16;
  UTF16 = WideChar;
  PUTF32 = ^UTF32;
  UTF32 = Cardinal;
  // UTF conversion schemes (UCS) data types
  PUCS4 = ^UCS4;
  UCS4 = Cardinal;
  PUCS2 = PDWChar;
  UCS2 = WideChar;
  TUCS2Array = array Of UCS2;
  TUCS4Array = array Of UCS4;
  // string types
  TUTF8String = DwString;
  {$IFDEF SUPPORTS_UNICODE_STRING}
  TUTF16String = UnicodeString;
  TUCS2String = UnicodeString;
  {$ELSE}
  TUTF16String = DWWideString;
  TUCS2String = DWWideString;
  {$ENDIF SUPPORTS_UNICODE_STRING}
Var
  AnsiReplacementCharacter: DwChar;
Const
  UCS4ReplacementCharacter: UCS4 = $0000FFFD;
  MaximumUCS2: UCS4 = $0000FFFF;
  MaximumUTF16: UCS4 = $0010FFFF;
  MaximumUCS4: UCS4 = $7FFFFFFF;
  SurrogateHighStart = UCS4($D800);
  SurrogateHighEnd = UCS4($DBFF);
  SurrogateLowStart = UCS4($DC00);
  SurrogateLowEnd = UCS4($DFFF);
// basic set types
Type
  TSetOfAnsiChar = set Of DwChar;
{$IFNDEF HAS_FMX}
Procedure RaiseLastOSError;
{$ENDIF ~HAS_FMX}
{$IFNDEF RTL230_UP}
Procedure CheckOSError(ErrorCode: Cardinal);
{$ENDIF RTL230_UP}
Procedure MoveChar(Const Source: string; FromIndex: SizeInt;
  Var Dest: string; ToIndex, Count: SizeInt); overload; // Index: 0..n-1
Function AnsiByteArrayStringLen(Data: TBytes): SizeInt;
Function StringToAnsiByteArray(Const S: string): TBytes;
Function AnsiByteArrayToString(Const Data: TBytes; Count: SizeInt): string;
Function BytesOf(Const Value: DWString): TBytes; overload;
{$IFNDEF FPC}
{$IFNDEF COMPILER11_UP}
Type // Definitions for 32 Bit Compilers
  // From BaseTsd.h
  INT_PTR = Integer;
  {$EXTERNALSYM INT_PTR}
  LONG_PTR = Longint;
  {$EXTERNALSYM LONG_PTR}
  UINT_PTR = Cardinal;
  {$EXTERNALSYM UINT_PTR}
  ULONG_PTR = LongWord;
  {$EXTERNALSYM DWORD_PTR}
{$ENDIF ~COMPILER11_UP}
Type
  DWORD_PTR  = LongWord;
  PDWORD_PTR = ^DWORD_PTR;
  {$EXTERNALSYM PDWORD_PTR}
{$ENDIF ~FPC}
Type
  TJclAddr32 = Cardinal;
  {$IFDEF FPC}
   TJclAddr64 = QWord;
   {$IFDEF CPU32}
   TJclAddr = Cardinal;
   {$ENDIF CPU32}
   {$IFDEF CPU64}
   TJclAddr = QWord;
   {$ENDIF CPU64}
  {$ELSE}
   TJclAddr64 = Int64;
   {$IF Defined(CPUX32)}
    TJclAddr = TJclAddr32;
   {$ELSEIF CPUX64}
    TJclAddr = TJclAddr64;
   {$ELSE}
    TJclAddr = TJclAddr32;
   {$IFEND}
  {$ENDIF}
  PJclAddr = ^TJclAddr;
  EJclAddr64Exception = Class(EJclError);
Function Addr64ToAddr32(Const Value: TJclAddr64): TJclAddr32;
Function Addr32ToAddr64(Const Value: TJclAddr32): TJclAddr64;
{$IFDEF FPC}
Type
  HWND = Type Windows.HWND;
{$ENDIF FPC}
 {$IFDEF SUPPORTS_GENERICS}
//DOM-IGNORE-BEGIN
Type
  TCompare<T> = Function(Const Obj1, Obj2: T): Integer;
  TEqualityCompare<T> = Function(Const Obj1, Obj2: T): Boolean;
  THashConvert<T> = Function(Const AItem: T): Integer;
  IEqualityComparer<T> = Interface
    Function Equals(A, B: T): Boolean;
    Function GetHashCode(Obj: T): Integer;
  End;
  TEquatable<T: Class> = Class(TInterfacedObject, IEquatable<T>, IEqualityComparer<T>)
  Public
    { IEquatable<T> }
    Function TestEquals(Other: T): Boolean; overload;
    Function IEquatable<T>.Equals = TestEquals;
    { IEqualityComparer<T> }
    Function TestEquals(A, B: T): Boolean; overload;
    Function IEqualityComparer<T>.Equals = TestEquals;
    Function GetHashCode2(Obj: T): Integer;
    Function IEqualityComparer<T>.GetHashCode = GetHashCode2;
  End;
//DOM-IGNORE-END
{$ENDIF SUPPORTS_GENERICS}
Const
  {$IFDEF SUPPORTS_UNICODE}
  AWSuffix = 'W';
  {$ELSE ~SUPPORTS_UNICODE}
  AWSuffix = 'A';
  {$ENDIF ~SUPPORTS_UNICODE}
{$IFDEF FPC}
// FPC emits a lot of warning because the first parameter of its internal
// GetMem is a var parameter, which is not initialized before the call to GetMem
Procedure GetMem(out P; Size: Longint);
{$ENDIF FPC}

Implementation

Uses
  uRESTDWMemResources;

{$IFDEF MSWINDOWS}
Function IsDirectory(Const FileName: string): Boolean;
Var
  R: DWORD;
Begin
  R := GetFileAttributes(PChar(FileName));
  Result := (R <> DWORD(-1)) and ((R and FILE_ATTRIBUTE_DIRECTORY) <> 0);
End;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
Function IsDirectory(Const FileName: string; ResolveSymLinks: Boolean): Boolean;
Var
  Buf: TStatBuf64;
Begin
  Result := False;
  If GetFileStatus(FileName, Buf, ResolveSymLinks) = 0 Then
    Result := S_ISDIR(Buf.st_mode);
End;
{$ENDIF UNIX}

Procedure MoveChar(Const Source: string; FromIndex: SizeInt;
  Var Dest: string; ToIndex, Count: SizeInt);
Begin
  Move(Source[FromIndex + 1], Dest[ToIndex + 1], Count * SizeOf(Char));
End;
Function AnsiByteArrayStringLen(Data: TBytes): SizeInt;
Var
  I: SizeInt;
Begin
  Result := Length(Data);
  For I := 0 To Result - 1 Do
    If Data[I] = 0 Then
    Begin
      Result := I + 1;
      Break;
    End;
End;
Function StringToAnsiByteArray(Const S: string): TBytes;
Var
  I: SizeInt;
  AnsiS: DWString;
Begin
  AnsiS := DWString(S); // convert to DWString
  SetLength(Result, Length(AnsiS));
  For I := 0 To High(Result) Do
    Result[I] := Byte(AnsiS[I + 1]);
End;
Function AnsiByteArrayToString(Const Data: TBytes; Count: SizeInt): string;
Var
  I: SizeInt;
  AnsiS: DWString;
Begin
  If Length(Data) < Count Then
    Count := Length(Data);
  SetLength(AnsiS, Count);
  For I := 0 To Length(AnsiS) - 1 Do
    PDWChar(@AnsiS[I + 1])^ := DWChar(Data[I]);
  Result := string(AnsiS); // convert to System.String
End;
Function BytesOf(Const Value: DWString): TBytes;
Begin
  SetLength(Result, Length(Value));
  If Value <> '' Then
    Move(Pointer(Value)^, Result[0], Length(Value));
End;
Function StringOf(Const Bytes: array Of Byte): DWString;
Begin
  If Length(Bytes) > 0 Then
  Begin
    SetLength(Result, Length(Bytes));
    Move(Bytes[0], Pointer(Result)^, Length(Bytes));
  End
  Else
    Result := '';
End;
// Cross Platform Compatibility
{$IFNDEF HAS_FMX}
Procedure RaiseLastOSError;
Begin
{$IFDEF MSWINDOWS}
  RaiseLastWin32Error;
{$ENDIF}
End;
{$ENDIF ~HAS_FMX}
{$IFNDEF RTL230_UP}
Procedure CheckOSError(ErrorCode: Cardinal);
Begin
  If ErrorCode <> ERROR_SUCCESS Then
    {$IFDEF RTL170_UP}
    RaiseLastOSError(ErrorCode);
    {$ELSE ~RTL170_UP}
    RaiseLastOSError;
    {$ENDIF ~RTL170_UP}
End;
{$ENDIF RTL230_UP}
{$OVERFLOWCHECKS OFF}
Function Addr64ToAddr32(Const Value: TJclAddr64): TJclAddr32;
Begin
  If (Value shr 32) = 0 Then
    Result := Value
  Else
    raise EJclAddr64Exception.CreateResFmt(@RsCantConvertAddr64, [HexPrefix, Value]);
End;
Function Addr32ToAddr64(Const Value: TJclAddr32): TJclAddr64;
Begin
  Result := Value;
End;
{$IFDEF OVERFLOWCHECKS_ON}
{$OVERFLOWCHECKS ON}
{$ENDIF OVERFLOWCHECKS_ON}
{$IFDEF SUPPORTS_GENERICS}
//DOM-IGNORE-BEGIN
//=== { TEquatable<T> } ======================================================
Function TEquatable<T>.TestEquals(Other: T): Boolean;
Begin
  If Other = nil Then
    Result := False
  Else
    Result := GetHashCode = Other.GetHashCode;
End;
Function TEquatable<T>.TestEquals(A, B: T): Boolean;
Begin
  If A = nil Then
    Result := B = nil
  Else
  If B = nil Then
    Result := False
  Else
    Result := A.GetHashCode = B.GetHashCode;
End;
Function TEquatable<T>.GetHashCode2(Obj: T): Integer;
Begin
  If Obj = nil Then
    Result := 0
  Else
    Result := Obj.GetHashCode;
End;
//DOM-IGNORE-END
{$ENDIF SUPPORTS_GENERICS}
Procedure LoadAnsiReplacementCharacter;
{$IFDEF MSWINDOWS}
Var
  CpInfo: TCpInfo;
Begin
  CpInfo.MaxCharSize := 0;
  If GetCPInfo(CP_ACP, CpInfo) Then
    AnsiReplacementCharacter := DWChar(Chr(CpInfo.DefaultChar[0]))
  Else
    raise EJclInternalError.CreateRes(@RsEReplacementChar);
End;
{$ELSE ~MSWINDOWS}
Begin
  AnsiReplacementCharacter := '?';
End;
{$ENDIF ~MSWINDOWS}
{$IFDEF FPC}
// FPC emits a lot of warning because the first parameter of its internal
// GetMem is a var parameter, which is not initialized before the call to GetMem
Procedure GetMem(out P; Size: Longint);
Begin
  Pointer(P) := nil;
  GetMem(Pointer(P), Size);
End;
{$ENDIF FPC}
Initialization
 LoadAnsiReplacementCharacter;
{$IFDEF UNITVERSIONING}
 RegisterUnitVersion(HInstance, UnitVersioning);
{$ENDIF UNITVERSIONING}
Finalization
{$IFDEF UNITVERSIONING}
 UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
End.
