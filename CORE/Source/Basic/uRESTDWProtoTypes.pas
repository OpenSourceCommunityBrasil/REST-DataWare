unit uRESTDWProtoTypes;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

uses
  {$IFNDEF FPC}
   {$if CompilerVersion < 24}DbTables,{$IFEND}
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
  {$IFDEF COMPILER10_UP}
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
  {$IFDEF COMPILER14_UP}
  dwftLongWord        = Integer(DB.ftLongWord); //42
  dwftShortint        = Integer(DB.ftShortint); //43
  dwftByte            = Integer(DB.ftByte); //44
  dwftExtended        = Integer(DB.ftExtended); //45
  dwftStream          = Integer(DB.ftStream); //48
  dwftTimeStampOffset = Integer(DB.ftTimeStampOffset); //49
  dwftSingle          = Integer(DB.ftSingle); //51
  {$ELSE}
  dwftLongWord        = Integer(42);
  dwftShortint        = Integer(43);
  dwftByte            = Integer(44);
  dwftExtended        = Integer(45);
  dwftStream          = Integer(48);
  dwftTimeStampOffset = Integer(49);
  dwftSingle          = Integer(51);
  {$ENDIF}

  {Unsupported types}
  dwftUnknown         = Integer(DB.ftUnknown);
  dwftCursor          = Integer(DB.ftCursor);
  dwftADT             = Integer(DB.ftADT);
  dwftArray           = Integer(DB.ftArray);
  dwftReference       = Integer(DB.ftReference);
  dwftDataSet         = Integer(DB.ftDataSet);
  {Unknown newest types for support in future}

  {$IFDEF COMPILER14_UP}
  dwftConnection      = Integer(DB.ftConnection); //46
  dwftParams          = Integer(DB.ftParams); //47
  dwftObject          = Integer(DB.ftObject); //50
  {$ENDIF}
  {$IFDEF REGION}{$ENDREGION}{$ENDIF}
 {$IFDEF COMPILER10_UP}
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

 Type
 {$IFDEF FPC}
  DWInteger       = Longint;
  DWInt16         = Integer;
  DWInt64         = Int64;
  DWInt32         = Int32;
  DWFloat         = Real;
  DWFieldTypeSize = Longint;
  DWBufferSize    = Longint;
  DWUInt16        = Word;
  DWUInt32        = LongWord;
 {$ELSE}
  DWInteger       = Integer;
  DWInt16         = Integer;
  DWInt64         = Int64;
  DWInt32         = Longint;
  DWFloat         = Real;
  DWFieldTypeSize = Integer;
  DWBufferSize    = Longint;
  DWUInt16        = Word;
  DWUInt32        = LongWord;
 {$ENDIF}
 DWInt8           = Integer;
 DWUInt8          = DWInt8;
 PDWInt32         = ^DWInt32;
 PDWInt64         = ^DWInt64;
 PDWUInt32        = ^DWInt32;
 PDWUInt16        = ^DWUInt16;
 PDWInt16         = ^DWUInt16;
 {$IFDEF FPC}
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
    {$NODEFINE UInt64}
    TRESTDWUInt64 = QWord;
    {$ELSE}
    Type
     UInt64 = Int64;
     TRESTDWUInt64 = UInt64;
    {$NODEFINE UInt64}
   {$ENDIF}
 {$ENDIF}
 TRESTDWIPv6Address = Array [0..7] Of DWUInt16;
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
  DWChar       = Char;
 {$ENDIF}
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
 TSendEvent                  = (seGET,       sePOST,
                                sePUT,       seDELETE,
                                sePatch);
 TTypeRequest                = (trHttp,      trHttps);
 TDatasetEvents              = Procedure (DataSet : TDataSet) Of Object;
 TRESTDwSessionData          = Class(TCollectionItem);
 TRESTDWDatabaseType         = (dbtUndefined, dbtAccess, dbtDbase, dbtFirebird, dbtInterbase, dbtMySQL,
                                dbtSQLLite,   dbtOracle, dbtMsSQL, dbtODBC,     dbtParadox,  dbtPostgreSQL,
                                dbtAdo);
 TWideChars                  = Array of WideChar;
 TRESTDWBytes                = Array of Byte;
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

implementation

end.