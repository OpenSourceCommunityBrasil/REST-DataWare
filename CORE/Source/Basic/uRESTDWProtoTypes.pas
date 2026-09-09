unit uRESTDWProtoTypes;

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

interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

uses
  {$IFNDEF FPC}
   {$IFNDEF DELPHI2010UP}
    DbTables,
   {$ENDIF}
  {$ENDIF}
  SysUtils,  Classes, Db, FMTBcd;
 Const
  dwftColor       = Integer(255);
  RESTDWHexPrefix = '0x';
{Supported types}
  dwftString          = Integer(DB.ftString);
  dwftSmallint        = Integer(DB.ftSmallint);
  dwftInteger         = Integer(DB.ftInteger);
  dwftWord            = Integer(DB.ftWord);
  dwftBoolean         = Integer(DB.ftBoolean);
  dwftFloat           = Integer(DB.ftFloat);
  dwftCurrency        = Integer(DB.ftCurrency);
  dwftBCD             = Integer(DB.ftBCD);
  dwftDate            = Integer(DB.ftDate);
  dwftTime            = Integer(DB.ftTime);
  dwftDateTime        = Integer(DB.ftDateTime);
  dwftBytes           = Integer(DB.ftBytes);
  dwftVarBytes        = Integer(DB.ftVarBytes);
  dwftAutoInc         = Integer(DB.ftAutoInc);
  dwftBlob            = Integer(DB.ftBlob);
  dwftMemo            = Integer(DB.ftMemo);
  dwftGraphic         = Integer(DB.ftGraphic);
  dwftFmtMemo         = Integer(DB.ftFmtMemo);
  dwftParadoxOle      = Integer(DB.ftParadoxOle);
  dwftDBaseOle        = Integer(DB.ftDBaseOle);
  dwftTypedBinary     = Integer(DB.ftTypedBinary);
  dwftFixedChar       = Integer(DB.ftFixedChar);
  dwftWideString      = Integer(DB.ftWideString);
  dwftLargeint        = Integer(DB.ftLargeint);
  dwftOraBlob         = Integer(DB.ftOraBlob);
  dwftOraClob         = Integer(DB.ftOraClob);
  dwftVariant         = Integer(DB.ftVariant);
  dwftInterface       = Integer(DB.ftInterface);
  dwftIDispatch       = Integer(DB.ftIDispatch);
  dwftGuid            = Integer(DB.ftGuid);
  dwftTimeStamp       = Integer(DB.ftTimeStamp);
  dwftFMTBcd          = Integer(DB.ftFMTBcd);
  dwftSingle          = Integer(DB.ftFloat);
  {$IFDEF DELPHI2006UP}
  dwftFixedWideChar   = Integer(DB.ftFixedWideChar);
  dwftWideMemo        = Integer(DB.ftWideMemo);
  dwftOraTimeStamp    = Integer(DB.ftOraTimeStamp);
  dwftOraInterval     = Integer(DB.ftOraInterval);
  {$ELSE}
  dwftFixedWideChar   = Integer(38);
  dwftWideMemo        = Integer(39);
  dwftOraTimeStamp    = Integer(40);
  dwftOraInterval     = Integer(41);
  {$ENDIF}
  {$IFDEF DELPHI2010UP}
  dwftLongWord        = Integer(DB.ftLongWord); //42
  dwftShortint        = Integer(DB.ftShortint); //43
  dwftByte            = Integer(DB.ftByte); //44
  dwftExtended        = Integer(DB.ftExtended); //45
  dwftStream          = Integer(DB.ftStream); //48
  dwftTimeStampOffset = Integer(DB.ftTimeStampOffset); //49
  {$ELSE}
  dwftLongWord        = Integer(42);
  dwftShortint        = Integer(43);
  dwftByte            = Integer(44);
  {$IFDEF FPC}
  dwftExtended        = Integer(45);
  {$ELSE}
  dwftExtended        = Integer(ftFMTBcd);
  {$ENDIF}
  dwftStream          = Integer(48);
  dwftTimeStampOffset = Integer(49);
//  dwftSingle          = Integer(51);
  {$ENDIF}
  {Unsupported types}
  dwftUnknown         = Integer(DB.ftUnknown);
  dwftCursor          = Integer(DB.ftCursor);
  dwftADT             = Integer(DB.ftADT);
  dwftArray           = Integer(DB.ftArray);
  dwftReference       = Integer(DB.ftReference);
  dwftDataSet         = Integer(DB.ftDataSet);
  {Unknown newest types for support in future}
  {$IFDEF DELPHI2010UP}
  dwftConnection      = Integer(DB.ftConnection); //46
  dwftParams          = Integer(DB.ftParams); //47
  dwftObject          = Integer(DB.ftObject); //50
  {$ENDIF}
 {$IFDEF DELPHI2006UP}
  FieldTypeIdents : Array[dwftColor..dwftColor] Of TIdentMapEntry = ((Value: dwftColor; Name: 'ftColor'));
 {$ELSE}
  FieldTypeIdents : Array[0..7]                 Of TIdentMapEntry = ((Value: dwftTimeStampOffset; Name: 'ftTimeStampOffset'),
                                                                     (Value: dwftStream;          Name: 'ftStream'),
                                                                     (Value: dwftSingle;          Name: 'ftSingle'),
                                                                     (Value: dwftExtended;        Name: 'ftExtended'),
                                                                     (Value: dwftByte;            Name: 'ftByte'),
                                                                     (Value: dwftShortint;        Name: 'ftShortint'),
                                                                     (Value: dwftLongWord;        Name: 'ftLongWord'),
                                                                     (Value: dwftColor;           Name: 'ftColor'));
 {$ENDIF}

  FieldGroupChar: set of 0..255 = [dwftFixedChar, dwftString];
  FieldGroupWideChar: set of 0..255 = [dwftFixedWideChar, dwftWideString];
  FieldGroupStream: set of 0..255 = [dwftStream, dwftBlob, dwftBytes, dwftWideMemo, dwftMemo, dwftFMTMemo];
  FieldGroupInt: set of 0..255 = [dwftByte, dwftShortint, dwftSmallint, dwftWord, dwftInteger];
  FieldGroupCardinal: set of 0..255 = [dwftLongWord];
  //  LongWord is 4 bytes unassigned on Windows 64bits and all 32bits platforms,
  // but 8 bytes unassigned for all 64bits platforms except Windows 64bits.
  //  We are setting LongWord as Cardinal (4 bytes unassigned for all platforms)
  // to avoid buffer overflows in cross-platform binary exchange.
  FieldGroupInt64: set of 0..255 = [dwftAutoInc, dwftLargeint];
  // AutoInc Should be Int64 to accept BIGINT primary keys.
  FieldGroupFloat: set of 0..255 = [dwftFloat, dwftOraTimeStamp];
  FieldGroupDateTime: set of 0..255 = [dwftDate, dwftTime, dwftDateTime];
  FieldGroupTimeStampOffSet: set of 0..255 = [dwftTimeStampOffset];
  FieldGroupTimeStamp: set of 0..255 = [dwftTimeStamp];
  FieldGroupBoolean: set of 0..255 = [dwftBoolean];
  FieldGroupSingle: set of 0..255 = [dwftSingle];
  FieldGroupExtended: set of 0..255 = [dwftExtended];
  //  Extended is 8 bytes assigned on Windows 64bits, 10 bytes assignbed on
  // Windows 32 bits and 16 bytes assigned on all other platforms.
  //  We are setting Extended as Double (8 bytes assigned for all platforms)
  // to avoid buffer overflows in cross-platform binary exchange.
  FieldGroupCurrency: set of 0..255 = [dwftCurrency];
  FieldGroupBCD: set of 0..255 = [dwftBCD, dwftFMTBcd];
  FieldGroupVariant: set of 0..255 = [dwftVariant];
  FieldGroupGUID: set of 0..255 = [dwftGUID];
Type
 {$IFDEF RESTDWLAZARUS}
  DWSmallint      = Smallint;
  DWInteger       = Longint;
  DWLongint       = Largeint;
  DWInt16         = Integer;
  DWInt64         = Int64;
  DWInt32         = Int32;
  DWFloat         = Real;
  DWSingle        = Single;
  DWDouble        = Double;
  DWLongDouble    = Extended;
  DWWord          = Word;
  DWCurrency      = Currency;
  DWCardinal      = Cardinal;
  DWFieldTypeSize = Longint;
  DWBufferSize    = Longint;
  DWUInt16        = Word;
  DWUInt32        = LongWord;
  DWBCD           = TBCD;
 {$ELSE}
  DWSmallint      = Smallint;
  DWInteger       = Integer;
  DWInt16         = Integer;
  DWInt64         = Int64;
  DWInt32         = Longint;
  DWLongint       = Longint;
  DWFloat         = Real;
  DWSingle        = Single;
  DWDouble        = Double;
  DWLongDouble    = Extended;
  DWWord          = Word;
  DWCurrency      = Currency;
  DWCardinal      = Cardinal;
  DWFieldTypeSize = Integer;
  DWBufferSize    = Integer;
  DWUInt16        = Word;
  DWUInt32        = LongWord;
  DWBCD           = TBCD;
 {$ENDIF}
 DWInt8           = Integer;
 DWUInt8          = DWInt8;
 PDWInt32         = ^DWInt32;
 PDWInt64         = ^DWInt64;
 PDWUInt32        = ^DWInt32;
 PDWUInt16        = ^DWUInt16;
 PDWInt16         = ^DWUInt16;
 {$IFDEF RESTDWLAZARUS}
  TCharSet = Set Of AnsiChar;
 {$ELSE}
  {$IFNDEF NEXTGEN}
   TCharSet = Set Of AnsiChar;
  {$ELSE}
   TCharSet = Set Of Char;
  {$ENDIF}
 {$ENDIF}
 {$IFDEF HAS_UInt64}
  {$DEFINE UInt64_IS_NATIVE}
  {$IFNDEF BROKEN_UINT64_HPPEMIT}
  Type
   TRESTDWUInt64 = UInt64;
  {$ENDIF}
 {$ELSE}
  {$IFDEF HAS_QWord}
   {$DEFINE UInt64_IS_NATIVE}
   Type
    UInt64 = QWord;
    {$UNDEF UInt64}
    TRESTDWUInt64 = QWord;
    {$ELSE}
    Type
     UInt64 = Int64;
     TRESTDWUInt64 = UInt64;
    {$UNDEF UInt64}
   {$ENDIF}
 {$ENDIF}
 TRESTDWIPv6Address = Array [0..7] Of DWUInt16;
  {$IF (Defined(DELPHIXE5UP)) AND (NOT Defined(DELPHI10_0UP)) AND (NOT Defined(RESTDWLAZARUS))}
   {$IFDEF RESTDWFMX}
    DWString     = String;
    DWWideString = WideString;
    DWChar       = Char;
   {$ELSE}
    DWString     = Utf8String;
    DWWideString = WideString;
    DWChar       = Utf8Char;
   {$ENDIF}
  {$ELSEIF NOT Defined(RESTDWLAZARUS)}
   {$IFDEF RESTDWFMX}
    DWString     = Utf8String;
    {$IF Defined (DELPHI11UP)}
    DWWideString = Widestring;
    {$Else}
    DWWideString = UnicodeString;
    {$IFEND}
    DWChar       = Utf8Char;
   {$ELSE}
    DWString     = AnsiString;
    DWWideString = WideString;
    DWChar       = AnsiChar;
   {$ENDIF}
  {$ELSE}
   DWString     = AnsiString;
   DWWideString = WideString;
   DWChar       = Char;
  {$IFEND}
 DWWideChar    = WideChar;
 TRESTDWWideChars = Array Of DWWideChar;
 PDWChar       = ^DWChar;
 PDWWideChar   = ^DWWideChar;
 PDWWideString = ^DWWideString;
 PDWString     = ^DWString;
 PArrayData    = ^TArrayData;
 TArrayData    = Array of Variant;
 TRESTDWHeaderQuotingType    = (QuotePlain, QuoteRFC822, QuoteMIME, QuoteHTTP);
 TRESTDWMessageCoderPartType = (mcptText, mcptAttachment, mcptIgnore, mcptEOF);
 RESTDWArrayError            = Class (Exception);
 RESTDWTableError            = Class (Exception);
 RESTDWDatabaseError         = Class (Exception);
 TConnStatus                 = (hsResolving, hsConnecting, hsConnected,
                                hsDisconnecting, hsDisconnected, hsStatusText);
 TRESTDWClientStage          = (csNone, csLoggedIn, csRejected);
 TDataAttributes             = Set of (dwCalcField,    dwNotNull, dwLookup,
                                       dwInternalCalc, dwAggregate);
 TSendEvent                  = (seGET, sePOST, sePUT, seDELETE, sePatch);
 TTypeRequest                = (trHttp, trHttps);
 TDatasetEvents              = Procedure (DataSet : TDataSet) Of Object;
 TRESTDwSessionData          = Class(TCollectionItem);
 TRESTDWDatabaseType         = (dbtUndefined, dbtAccess, dbtDbase, dbtFirebird, dbtInterbase, dbtMySQL,
                                dbtSQLLite,   dbtOracle, dbtMsSQL, dbtODBC,     dbtParadox,  dbtPostgreSQL,
                                dbtAdo);
 TWideChars                  = Array of WideChar;
 TRESTDWBytes                = Array of Byte;
 TRESTDWArrayOfChar          = Array of Char;
 PRESTDWBytes                = ^TRESTDWBytes;
 TOnWriterProcess            = Procedure(DataSet               : TDataSet;
                                         RecNo, RecordCount    : Integer;
                                         Var AbortProcess      : Boolean) Of Object;
 Type
  TWorkMode = (wmRead, wmWrite);
  TWorkInfo = Record
   Current,
   Max     : Int64;
   Level   : Integer;
 End;
 {$IFDEF STREAM_SIZE_64}
  TRESTDWStreamSize = Int64;
 {$ELSE}
  TRESTDWStreamSize = DWInt32;
 {$ENDIF}

const
 RESTDW_NATIVE_SIGNATURE_0 = Ord('R');
 RESTDW_NATIVE_SIGNATURE_1 = Ord('E');
 RESTDW_NATIVE_SIGNATURE_2 = Ord('S');
 RESTDW_NATIVE_SIGNATURE_3 = Ord('T');
 RESTDW_NATIVE_SIGNATURE_4 = Ord('D');
 RESTDW_NATIVE_SIGNATURE_5 = Ord('W');
 RESTDW_NATIVE_FORMAT       = Ord('N');
 RESTDW_NATIVE_VERSION      = 2;
 RESTDW_NATIVE_NULL_SIZE    = -1;
 RESTDW_NATIVE_FLAG_COMPRESSED = 1;

 RESTDW_COMPILER_OLDDELPHI = Ord('O');
 RESTDW_COMPILER_NEWDELPHI = Ord('N');
 RESTDW_COMPILER_LAZARUS   = Ord('L');
 RESTDW_COMPILER_FPC       = Ord('F');

 RESTDW_ARCH_UNKNOWN       = 0;
 RESTDW_ARCH_32            = 32;
 RESTDW_ARCH_64            = 64;

 RESTDW_PLATFORM_UNKNOWN   = 0;
 RESTDW_PLATFORM_WINDOWS   = 1;
 RESTDW_PLATFORM_LINUX     = 2;
 RESTDW_PLATFORM_MACOS     = 3;
 RESTDW_PLATFORM_FREEBSD   = 4;
 RESTDW_PLATFORM_ANDROID   = 5;
 RESTDW_PLATFORM_IOS       = 6;

 RESTDW_TYPE_UNKNOWN       = 0;
 RESTDW_TYPE_STRING        = 1;
 RESTDW_TYPE_SMALLINT      = 2;
 RESTDW_TYPE_INTEGER       = 3;
 RESTDW_TYPE_WORD          = 4;
 RESTDW_TYPE_BOOLEAN       = 5;
 RESTDW_TYPE_FLOAT         = 6;
 RESTDW_TYPE_CURRENCY      = 7;
 RESTDW_TYPE_BCD           = 8;
 RESTDW_TYPE_DATE          = 9;
 RESTDW_TYPE_TIME          = 10;
 RESTDW_TYPE_DATETIME      = 11;
 RESTDW_TYPE_BYTES         = 12;
 RESTDW_TYPE_VARBYTES      = 13;
 RESTDW_TYPE_AUTOINC       = 14;
 RESTDW_TYPE_BLOB          = 15;
 RESTDW_TYPE_MEMO          = 16;
 RESTDW_TYPE_GRAPHIC       = 17;
 RESTDW_TYPE_FMTMEMO       = 18;
 RESTDW_TYPE_PARADOXOLE    = 19;
 RESTDW_TYPE_DBASEOLE      = 20;
 RESTDW_TYPE_TYPEDBINARY   = 21;
 RESTDW_TYPE_CURSOR        = 22;
 RESTDW_TYPE_FIXEDCHAR     = 23;
 RESTDW_TYPE_WIDESTRING    = 24;
 RESTDW_TYPE_LARGEINT      = 25;
 RESTDW_TYPE_ADT           = 26;
 RESTDW_TYPE_ARRAY         = 27;
 RESTDW_TYPE_REFERENCE     = 28;
 RESTDW_TYPE_DATASET       = 29;
 RESTDW_TYPE_ORABLOB       = 30;
 RESTDW_TYPE_ORACLOB       = 31;
 RESTDW_TYPE_VARIANT       = 32;
 RESTDW_TYPE_INTERFACE     = 33;
 RESTDW_TYPE_IDISPATCH     = 34;
 RESTDW_TYPE_GUID          = 35;
 RESTDW_TYPE_TIMESTAMP     = 36;
 RESTDW_TYPE_FMTBCD        = 37;
 RESTDW_TYPE_FIXEDWIDECHAR = 38;
 RESTDW_TYPE_WIDEMEMO      = 39;
 RESTDW_TYPE_ORATIMESTAMP  = 40;
 RESTDW_TYPE_ORAINTERVAL   = 41;
 RESTDW_TYPE_LONGWORD      = 42;
 RESTDW_TYPE_SHORTINT      = 43;
 RESTDW_TYPE_BYTE          = 44;
 RESTDW_TYPE_EXTENDED      = 45;
 RESTDW_TYPE_SINGLE        = 46;
 RESTDW_TYPE_TIMESTAMPOS   = 47;

Type
 TRESTDWNativeHeader = Packed Record
  Signature    : Array[0..5] Of Byte;
  FormatType   : Byte;
  Version      : Byte;
  CompilerType : Byte;
  PlatformType : Byte;
  Architecture : Byte;
  Flags        : Byte;
 End;

 TRESTDWNativeValueHeader = Packed Record
  DataType : Byte;
  DataSize : Longint;
 End;

Function RESTDWNativeCompilerType : Byte;
Function RESTDWNativePlatformType : Byte;
Function RESTDWNativeArchitecture : Byte;
Function RESTDWNativeDataType(AFieldType : TFieldType) : Byte;
Procedure RESTDWInitNativeHeader(Var AHeader : TRESTDWNativeHeader);
Function RESTDWIsNativeHeader(Const AHeader : TRESTDWNativeHeader) : Boolean;
Function RESTDWNativeHeaderCompatible(Const AHeader : TRESTDWNativeHeader) : Boolean;
Function RESTDWStreamHasNativeHeader(AStream : TStream) : Boolean;
Procedure RESTDWWriteNativePayload(ASource, ADest : TStream; ACompress : Boolean);
Function RESTDWReadNativePayload(ASource, ADest : TStream; Var AHeader : TRESTDWNativeHeader) : Boolean;

implementation

Uses
 uRESTDWZlib;

Function RESTDWNativeCompilerType : Byte;
Begin
 {$IFDEF RESTDWLAZARUS}
 Result := RESTDW_COMPILER_LAZARUS;
 {$ELSE}
  {$IFDEF FPC}
  Result := RESTDW_COMPILER_FPC;
  {$ELSE}
   {$IFDEF DELPHI2009UP}
   Result := RESTDW_COMPILER_NEWDELPHI;
   {$ELSE}
   Result := RESTDW_COMPILER_OLDDELPHI;
   {$ENDIF}
  {$ENDIF}
 {$ENDIF}
End;

Function RESTDWNativePlatformType : Byte;
Begin
 Result := RESTDW_PLATFORM_UNKNOWN;
 {$IFDEF RESTDWWINDOWS}
 Result := RESTDW_PLATFORM_WINDOWS;
 {$ENDIF}
 {$IFDEF RESTDWLINUX}
 Result := RESTDW_PLATFORM_LINUX;
 {$ENDIF}
 {$IFDEF RESTDWMACOS}
 Result := RESTDW_PLATFORM_MACOS;
 {$ENDIF}
 {$IFDEF RESTDWFREEBSD}
 Result := RESTDW_PLATFORM_FREEBSD;
 {$ENDIF}
 {$IFDEF RESTDWANDROID}
 Result := RESTDW_PLATFORM_ANDROID;
 {$ENDIF}
 {$IFDEF RESTDWIOS}
 Result := RESTDW_PLATFORM_IOS;
 {$ENDIF}
End;

Function RESTDWNativeArchitecture : Byte;
Begin
 {$IFDEF CPU64}
 Result := RESTDW_ARCH_64;
 {$ELSE}
  {$IFDEF CPUX64}
  Result := RESTDW_ARCH_64;
  {$ELSE}
  Result := RESTDW_ARCH_32;
  {$ENDIF}
 {$ENDIF}
End;

Function RESTDWNativeDataType(AFieldType : TFieldType) : Byte;
Begin
 Case Integer(AFieldType) Of
  dwftString        : Result := RESTDW_TYPE_STRING;
  dwftSmallint      : Result := RESTDW_TYPE_SMALLINT;
  dwftInteger       : Result := RESTDW_TYPE_INTEGER;
  dwftWord          : Result := RESTDW_TYPE_WORD;
  dwftBoolean       : Result := RESTDW_TYPE_BOOLEAN;
  dwftFloat         : Result := RESTDW_TYPE_FLOAT;
  dwftCurrency      : Result := RESTDW_TYPE_CURRENCY;
  dwftBCD           : Result := RESTDW_TYPE_BCD;
  dwftDate          : Result := RESTDW_TYPE_DATE;
  dwftTime          : Result := RESTDW_TYPE_TIME;
  dwftDateTime      : Result := RESTDW_TYPE_DATETIME;
  dwftBytes         : Result := RESTDW_TYPE_BYTES;
  dwftVarBytes      : Result := RESTDW_TYPE_VARBYTES;
  dwftAutoInc       : Result := RESTDW_TYPE_AUTOINC;
  dwftBlob          : Result := RESTDW_TYPE_BLOB;
  dwftMemo          : Result := RESTDW_TYPE_MEMO;
  dwftGraphic       : Result := RESTDW_TYPE_GRAPHIC;
  dwftFmtMemo       : Result := RESTDW_TYPE_FMTMEMO;
  dwftParadoxOle    : Result := RESTDW_TYPE_PARADOXOLE;
  dwftDBaseOle      : Result := RESTDW_TYPE_DBASEOLE;
  dwftTypedBinary   : Result := RESTDW_TYPE_TYPEDBINARY;
  dwftFixedChar     : Result := RESTDW_TYPE_FIXEDCHAR;
  dwftWideString    : Result := RESTDW_TYPE_WIDESTRING;
  dwftLargeint      : Result := RESTDW_TYPE_LARGEINT;
  dwftOraBlob       : Result := RESTDW_TYPE_ORABLOB;
  dwftOraClob       : Result := RESTDW_TYPE_ORACLOB;
  dwftVariant       : Result := RESTDW_TYPE_VARIANT;
  dwftInterface     : Result := RESTDW_TYPE_INTERFACE;
  dwftIDispatch     : Result := RESTDW_TYPE_IDISPATCH;
  dwftGuid          : Result := RESTDW_TYPE_GUID;
  dwftTimeStamp     : Result := RESTDW_TYPE_TIMESTAMP;
  dwftFMTBcd        : Result := RESTDW_TYPE_FMTBCD;
  dwftFixedWideChar : Result := RESTDW_TYPE_FIXEDWIDECHAR;
  dwftWideMemo      : Result := RESTDW_TYPE_WIDEMEMO;
  dwftOraTimeStamp  : Result := RESTDW_TYPE_ORATIMESTAMP;
  dwftOraInterval   : Result := RESTDW_TYPE_ORAINTERVAL;
  dwftLongWord      : Result := RESTDW_TYPE_LONGWORD;
  dwftShortint      : Result := RESTDW_TYPE_SHORTINT;
  dwftByte          : Result := RESTDW_TYPE_BYTE;
  {$IFDEF DELPHI2010UP}
  dwftExtended      : Result := RESTDW_TYPE_EXTENDED;
  {$ENDIF}
  dwftTimeStampOffset : Result := RESTDW_TYPE_TIMESTAMPOS;
 Else
  Result := RESTDW_TYPE_UNKNOWN;
 End;
End;

Procedure RESTDWInitNativeHeader(Var AHeader : TRESTDWNativeHeader);
Begin
 FillChar(AHeader, SizeOf(AHeader), 0);
 AHeader.Signature[0] := RESTDW_NATIVE_SIGNATURE_0;
 AHeader.Signature[1] := RESTDW_NATIVE_SIGNATURE_1;
 AHeader.Signature[2] := RESTDW_NATIVE_SIGNATURE_2;
 AHeader.Signature[3] := RESTDW_NATIVE_SIGNATURE_3;
 AHeader.Signature[4] := RESTDW_NATIVE_SIGNATURE_4;
 AHeader.Signature[5] := RESTDW_NATIVE_SIGNATURE_5;
 AHeader.FormatType   := RESTDW_NATIVE_FORMAT;
 AHeader.Version      := RESTDW_NATIVE_VERSION;
 AHeader.CompilerType := RESTDWNativeCompilerType;
 AHeader.PlatformType := RESTDWNativePlatformType;
 AHeader.Architecture := RESTDWNativeArchitecture;
End;

Function RESTDWIsNativeHeader(Const AHeader : TRESTDWNativeHeader) : Boolean;
Begin
 Result := (AHeader.Signature[0] = RESTDW_NATIVE_SIGNATURE_0) And
           (AHeader.Signature[1] = RESTDW_NATIVE_SIGNATURE_1) And
           (AHeader.Signature[2] = RESTDW_NATIVE_SIGNATURE_2) And
           (AHeader.Signature[3] = RESTDW_NATIVE_SIGNATURE_3) And
           (AHeader.Signature[4] = RESTDW_NATIVE_SIGNATURE_4) And
           (AHeader.Signature[5] = RESTDW_NATIVE_SIGNATURE_5) And
           (AHeader.FormatType = RESTDW_NATIVE_FORMAT) And
           (AHeader.Version = RESTDW_NATIVE_VERSION);
End;

Function RESTDWNativeHeaderCompatible(Const AHeader : TRESTDWNativeHeader) : Boolean;
Begin
 Result := RESTDWIsNativeHeader(AHeader) And
           (AHeader.CompilerType = RESTDWNativeCompilerType) And
           (AHeader.PlatformType = RESTDWNativePlatformType) And
           (AHeader.Architecture = RESTDWNativeArchitecture);
End;

Function RESTDWStreamHasNativeHeader(AStream : TStream) : Boolean;
Var
 LHeader : TRESTDWNativeHeader;
 LPos    : Int64;
Begin
 Result := False;
 If (AStream = Nil) Or (AStream.Size < SizeOf(LHeader)) Then
  Exit;
 LPos := AStream.Position;
 Try
  AStream.Position := 0;
  If AStream.Read(LHeader, SizeOf(LHeader)) = SizeOf(LHeader) Then
   Result := RESTDWIsNativeHeader(LHeader);
 Finally
  AStream.Position := LPos;
 End;
End;

Procedure RESTDWWriteNativePayload(ASource, ADest : TStream; ACompress : Boolean);
Var
 LHeader : TRESTDWNativeHeader;
 LTemp   : TMemoryStream;
Begin
 If (ASource = Nil) Or (ADest = Nil) Then
  Exit;
 RESTDWInitNativeHeader(LHeader);
 If ACompress Then
  LHeader.Flags := LHeader.Flags Or RESTDW_NATIVE_FLAG_COMPRESSED;
 ADest.Size := 0;
 ADest.Position := 0;
 ADest.WriteBuffer(LHeader, SizeOf(LHeader));
 ASource.Position := 0;
 If ACompress Then
  Begin
   LTemp := TMemoryStream.Create;
   Try
    ZCompressStream(ASource, LTemp);
    LTemp.Position := 0;
    ADest.CopyFrom(LTemp, LTemp.Size);
   Finally
    LTemp.Free;
   End;
  End
 Else
  ADest.CopyFrom(ASource, ASource.Size);
 ADest.Position := 0;
End;

Function RESTDWReadNativePayload(ASource, ADest : TStream; Var AHeader : TRESTDWNativeHeader) : Boolean;
Var
 LTemp : TMemoryStream;
Begin
 Result := False;
 If (ASource = Nil) Or (ADest = Nil) Or (ASource.Size < SizeOf(AHeader)) Then
  Exit;
 ASource.Position := 0;
 If ASource.Read(AHeader, SizeOf(AHeader)) <> SizeOf(AHeader) Then
  Exit;
 If Not RESTDWIsNativeHeader(AHeader) Then
  Begin
   ASource.Position := 0;
   Exit;
  End;
 ADest.Size := 0;
 If (AHeader.Flags And RESTDW_NATIVE_FLAG_COMPRESSED) <> 0 Then
  Begin
   LTemp := TMemoryStream.Create;
   Try
    LTemp.CopyFrom(ASource, ASource.Size - ASource.Position);
    LTemp.Position := 0;
    ZDecompressStream(LTemp, ADest);
   Finally
    LTemp.Free;
   End;
  End
 Else
  ADest.CopyFrom(ASource, ASource.Size - ASource.Position);
 ADest.Position := 0;
 Result := True;
End;

end.

