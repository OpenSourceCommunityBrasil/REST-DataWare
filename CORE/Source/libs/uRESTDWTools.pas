unit uRESTDWTools;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

Uses
 {$IFDEF FPC}
 Classes,  SysUtils, uRESTDWBasicTypes, LConvEncoding, lazutf8, Db
 {$ELSE}
 Classes,  SysUtils, uRESTDWBasicTypes, Db, EncdDecd
 {$IF Defined(RESTDWFMX)}
  , System.NetEncoding
 {$IFEND}
 {$ENDIF},
 uRESTDWEncodeClass;

 Const
  B64Table      = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  QuoteSpecials : Array[TRESTDWHeaderQuotingType] Of String = ('', '()<>@,;:\"./', '()<>@,;:\"/[]?=', '()<>@,;:\"/[]?={} '#9);
  LF            = #10;
  CR            = #13;
  EOL           = CR + LF;
  CHAR0         = #0;
  BACKSPACE     = #8;
  TAB           = #9;
  CHAR32        = #32;
  LWS           = TAB + CHAR32;

 Function  EncodeStrings          (Value                : String
                                  {$IFDEF FPC};DatabaseCharSet             : TDatabaseCharSet{$ENDIF}) : String;
 Function  DecodeStrings          (Value                : String
                                  {$IFDEF FPC};DatabaseCharSet             : TDatabaseCharSet{$ENDIF}) : String;
 Function  EncodeStream           (Value                : TStream)         : String;
 Function  DecodeStream           (Value                : String)          : TMemoryStream;
 Function  BytesToString          (Const bin            : TRESTDWBytes)    : String;Overload;
 Function  BytesToString          (Const AValue         : TRESTDWBytes;
                                   Const AStartIndex    : Integer;
                                   Const ALength        : Integer = -1)    : String;Overload;
 Function  restdwLength           (Const ABuffer        : String;
                                   Const ALength        : Integer = -1;
                                   Const AIndex         : Integer = 1)     : Integer;Overload;
 Function  restdwLength           (Const ABuffer        : TRESTDWBytes;
                                   Const ALength        : Integer = -1;
                                   Const AIndex         : Integer = 0)     : Integer;Overload;
 Function  restdwLength           (Const ABuffer        : TStream;
                                   Const ALength        : TRESTDWStreamSize = -1) : TRESTDWStreamSize;Overload;
 Function  restdwMax              (Const AValueOne,
                                   AValueTwo            : Int64)           : Int64;
 Function  restdwMin              (Const AValueOne,
                                   AValueTwo            : Int64)           : Int64;
 Function  StringToBytes          (AStr                 : String)          : TRESTDWBytes;
 Function  StreamToBytes          (Stream               : TMemoryStream)   : TRESTDWBytes;
 Function  StringToFieldType      (Const S              : String)          : Integer;
 Function  Escape_chars           (s                    : String)          : String;
 Function  Unescape_chars         (s                    : String)          : String;
 Function  HexToBookmark          (Value                : String)          : TRESTDWBytes;
 Function  BookmarkToHex          (Value                : TRESTDWBytes)    : String;
 Procedure CopyStringList         (Const Source,
                                   Dest                 : TStringList);
 Function  RemoveBackslashCommands(Value                : String)          : String;
 Function  RESTDWFileExists       (sFile,
                                   BaseFilePath         : String)          : Boolean;
 Function  TravertalPathFind      (Value                : String)          : Boolean;
 Function  GetEventName           (Value                : String)          : String;
 Function  ExtractHeaderSubItem   (Const AHeaderLine,
                                   ASubItem             : String;
                                   QuotingType          : TRESTDWHeaderQuotingType) : String;
 Function  ReadLnFromStream       (AStream              : TStream;
                                   Var VLine            : String;
                                   AMaxLineLength       : Integer = -1)    : Boolean; Overload;
 Function  ReadLnFromStream       (AStream              : TStream;
                                   AMaxLineLength       : Integer = -1;
                                   AExceptionIfEOF      : Boolean = False) : String;  Overload;
 Function  ValueFromIndex         (AStrings             : TStrings;
                                   Const AIndex         : Integer)         : String;
 Function  restdwValueFromIndex   (AStrings             : TStrings;
                                   Const AIndex         : Integer)         : String;
 Function  iif                    (ATest                : Boolean;
                                   Const ATrue          : Integer;
                                   Const AFalse         : Integer)         : Integer;{$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  CharRange              (Const AMin,
                                   AMax                 : Char)            : String;
 Function  CharIsInSet            (Const AString        : String;
                                   Const ACharPos       : Integer;
                                   Const ASet           : String)          : Boolean;{$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  ExtractHeaderItem      (Const AHeaderLine    : String)          : String;
 Function  TextIsSame             (Const A1, A2         : String)          : Boolean;{$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  WrapText               (Const ALine,
                                   ABreakStr,
                                   ABreakChars          : String;
                                   MaxCol               : Integer)         : String;
 Function  Fetch                  (Var AInput           : String;
                                   Const ADelim         : String  = '';
                                   Const ADelete        : Boolean = True;
                                   Const ACaseSensitive : Boolean = True)  : String; {$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  InternalAnsiPos        (Const Substr, S      : String)          : Integer;{$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  PosInStrArray          (Const SearchStr      : String;
                                   Const Contents       : Array Of String;
                                   Const CaseSensitive  : Boolean = True)  : Integer;
 Function  ReplaceHeaderSubItem   (Const AHeaderLine,
                                   ASubItem,
                                   AValue               : String;
                                   AQuoteType           : TRESTDWHeaderQuotingType) : String; Overload;
 Function  ReplaceHeaderSubItem   (Const AHeaderLine,
                                   ASubItem,
                                   AValue               : String;
                                   Var VOld             : String;
                                   AQuoteType           : TRESTDWHeaderQuotingType) : String; Overload;
 Procedure SplitHeaderSubItems    (AHeaderLine          : String;
                                   AItems               : TStrings;
                                   AQuoteType           : TRESTDWHeaderQuotingType);
 Function  TextStartsWith         (Const S, SubS        : String)                   : Boolean;
 Function  TextEndsWith           (Const S, SubS        : String)                   : Boolean;
 Function  Max                    (Const AValueOne,
                                   AValueTwo            : Int64)                    : Int64;  {$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  Min                    (Const AValueOne,
                                   AValueTwo            : Int64)                    : Int64;  {$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  RawToBytes             (Const AValue         : String;
                                   Const ASize          : Integer)                  : TRESTDWBytes;
 Procedure CopyBytes              (Const ASource        : TRESTDWBytes;
                                   Const ASourceIndex   : Integer;
                                   Var   VDest          : TRESTDWBytes;
                                   Const ADestIndex     : Integer;
                                   Const ALength        : Integer);
 Function  ByteIsInSet            (Const ABytes         : TRESTDWBytes;
                                   Const AIndex         : Integer;
                                   Const ASet           : TRESTDWBytes)             : Boolean;{$IFDEF USE_INLINE}Inline;{$ENDIF}
 Function  ToBytes                (Const AValue         : String)                   : TRESTDWBytes; Overload;
 Function  ToBytes                (Const AValue         : Char)                     : TRESTDWBytes; Overload;
 Function  ToBytes                (Const AValue         : String;
                                   Const ALength        : Integer;
                                   Const AIndex         : Integer = 1)              : TRESTDWBytes; Overload;
 Function  ToBytes                (Const AValue         : TRESTDWBytes;
                                   Const ASize          : Integer;
                                   Const AIndex         : Integer = 0)              : TRESTDWBytes; Overload;
 Function  GetBytes               (Const AChars         : PDWWideChar;
                                   ACharCount           : Integer)                  : TRESTDWBytes; Overload;
 Function  GetBytes               (Const AChars         : PDWWideChar;
                                   ACharCount           : Integer;
                                   ABytes               : PByte;
                                   AByteCount           : Integer)                  : Integer;      Overload;
 Function  GetBytes               (Const AChars         : TRESTDWWideChars;
                                   ACharIndex,
                                   ACharCount           : Integer;
                                   Var VBytes           : TRESTDWBytes;
                                   AByteIndex           : Integer)                  : Integer;      Overload;
 Function  GetBytes               (Const AChars         : PDWWideChar;
                                   ACharCount           : Integer;
                                   Var VBytes           : TRESTDWBytes;
                                   AByteIndex           : Integer)                  : Integer;      Overload;
 Function  GetBytes               (Const AChars         : String)                   : TRESTDWBytes; {$IFDEF USE_INLINE}Inline;{$ENDIF}Overload;
 Function  GetChars               (Const ABytes         : TRESTDWBytes;
                                   AByteIndex,
                                   AByteCount           : Integer)                  : TRESTDWWideChars;Overload;
 Function  GetChars               (Const ABytes         : TRESTDWBytes)             : TRESTDWWideChars;Overload;
 Function  GetChars               (Const ABytes         : PByte;
                                   AByteCount           : Integer)                  : TRESTDWWideChars;Overload;
 Function  GetChars               (Const ABytes         : TRESTDWBytes;
                                   AByteIndex,
                                   AByteCount           : Integer;
                                   Var VChars           : TRESTDWWideChars;
                                   ACharIndex           : Integer)                  : Integer;Overload;
 Function  GetChars               (Const ABytes         : PByte;
                                   AByteCount           : Integer;
                                   Var VChars           : TRESTDWWideChars;
                                   ACharIndex           : Integer)                  : Integer;Overload;
 Function  GetChars               (Const ABytes         : PByte;
                                   AByteCount           : Integer;
                                   AChars               : PDWWideChar;
                                   ACharCount           : Integer)                  : Integer;Overload;
 Function  GetCharCount           (Const ABytes         : TRESTDWBytes;
                                   AByteIndex,
                                   AByteCount           : Integer)                  : Integer;Overload;
 Function  GetCharCount           (Const ABytes         : PByte;
                                   AByteCount           : Integer)                  : Integer;Overload;
 Function  ValidateBytes          (Const ABytes         : TRESTDWBytes;
                                   AByteIndex,
                                   AByteCount,
                                   ANeeded              : Integer)                  : PByte;Overload;
 Function  ValidateBytes          (Const ABytes         : TRESTDWBytes;
                                   AByteIndex,
                                   AByteCount           : Integer)                  : PByte;Overload;
 Function  ReadBytesFromStream    (Const AStream        : TStream;
                                   Var   ABytes         : TRESTDWBytes;
                                   Const Count          : TRESTDWStreamSize;
                                   Const AIndex         : Integer = 0)              : TRESTDWStreamSize;
 Procedure WriteBytesToStream     (Const AStream        : TStream;
                                   Const ABytes         : TRESTDWBytes;
                                   Const ASize          : Integer = -1;
                                   Const AIndex         : Integer = 0);
 Procedure StringToStream         (AStream              : TStream;
                                   Const AStr           : String);
 procedure WriteStringToStream    (AStream              : TStream;
                                   Const AStr           : String;
                                   Const ALength        : Integer = -1;
                                   Const AIndex         : Integer = 1);Overload;
 Function  ReadStringFromStream   (AStream              : TStream;
                                   ASize                : Integer = -1) : String; Overload;
 Procedure AppendBytes            (Var VBytes           : TRESTDWBytes;
                                   Const AToAdd         : TRESTDWBytes;
                                   Const AIndex         : Integer = 0;
                                   Const ALength        : Integer = -1);
 Procedure InsertBytes            (Var VBytes           : TRESTDWBytes;
                                   Const ADestIndex     : Integer;
                                   Const ASource        : TRESTDWBytes;
                                   Const ASourceIndex   : Integer = 0);
 Procedure InsertByte             (Var VBytes           : TRESTDWBytes;
                                   Const AByte          : Byte;
                                   Const AIndex         : Integer);
 Function  ByteIndex              (Const AByte          : Byte;
                                   Const ABytes         : TRESTDWBytes;
                                   Const AStartIndex    : Integer = 0) : Integer;
 Function  ByteToHex              (Const AByte          : Byte)        : String;
 Procedure RemoveBytes            (Var   VBytes         : TRESTDWBytes;
                                   Const ACount         : Integer;
                                   Const AIndex         : Integer = 0);
 Procedure ExpandBytes            (Var VBytes           : TRESTDWBytes;
                                   Const AIndex         : Integer;
                                   Const ACount         : Integer;
                                   Const AFillByte      : Byte = 0);
 Procedure AppendByte             (Var   VBytes         : TRESTDWBytes;
                                   Const AByte          : Byte);
 Function  ByteIsInEOL            (Const ABytes         : TRESTDWBytes;
                                   Const AIndex         : Integer)                  : Boolean;
 Function  GetByteCount           (Const AChars         : TRESTDWWideChars)         : Integer;Overload;
 Function  GetByteCount           (Const AChars         : TRESTDWWideChars;
                                   ACharIndex,
                                   ACharCount           : Integer)                  : Integer;Overload;
 Function  GetByteCount           (Const AChars         : PDWWideChar;
                                   ACharCount           : Integer)                  : Integer;Overload;
 Function  IsHeaderMediaType      (Const AHeaderLine,
                                   AMediaType           : String)                   : Boolean;
 Function  MediaTypeMatches       (Const AValue,
                                   AMediaType           : String)                   : Boolean;
 Function  PosRDW                 (Const ASubStr,
                                   AStr                 : String;
                                   AStartPos            : DWInt32): DWInt32;
 Function  RDWStrToInt            (Const S              : String;
                                   ADefault             : Integer = 0) : Integer;{$IFDEF USE_INLINE}inline;{$ENDIF}
 Procedure RDWDelete              (Var s                : String;
                                   AOffset,
                                   ACount               : Integer);
 Function  FindFirstNotOf         (Const AFind,
                                   AText                : String;
                                   Const ALength        : Integer = -1;
                                   Const AStartPos      : Integer = 1)     : Integer;
 Function  FindFirstOf            (Const AFind,
                                   AText                : String;
                                   Const ALength        : Integer = -1;
                                   Const AStartPos      : Integer = 1)     : Integer;
 Function  BytesToStringRaw       (Const AValue         : TRESTDWBytes)    : String; Overload;{$IFDEF USE_INLINE}inline;{$ENDIF}
 Function  BytesToStringRaw       (Const AValue         : TRESTDWBytes;
                                   Const AStartIndex    : Integer;
                                   Const ALength        : Integer = -1)    : String; Overload;
 Function  IsHeaderMediaTypes     (Const AHeaderLine    : String;
                                   Const AMediaTypes    : Array Of String) : Boolean;
 Function  IsHeaderValue          (Const AHeaderLine    : String;
                                   Const AValue         : String)          : Boolean;
 Function  GetMIMEDefaultFileExt  (Const MIMEType       : String)          : TFileName;
 Function  GetMIMETypeFromFile    (Const AFile          : TFileName)       : String;
 Function  GetUniqueFileName      (Const APath,
                                   APrefix,
                                   AExt                 : String)          : String;
 Function  MakeTempFilename       (Const APath          : TFileName = '')  : TFileName;
 Function  CopyFileTo             (Const Source,
                                   Destination          : TFileName)       : Boolean;
 Function  OffsetFromUTC                                : TDateTime;
 Function  UTCOffsetToStr         (Const AOffset        : TDateTime;
                                   Const AUseGMTStr     : Boolean = False) : String;
 Function  LocalDateTimeToGMT     (Const Value          : TDateTime;
                                   Const AUseGMTStr     : Boolean = False) : String;
 Function  GMTToLocalDateTime     (S                    : String)          : TDateTime;
 Function  RawStrInternetToDateTime(Var Value           : String;
                                    Var VDateTime       : TDateTime)       : Boolean;
 Function  IsNumeric              (Const AChar          : Char)            : Boolean; Overload;
 Function  IsNumeric              (Const AString        : String;
                                   Const ALength        : Integer;
                                   Const AIndex         : Integer = 1)     : Boolean; Overload;
 Function  restdwPos              (Const Substr,
                                   S                    : String)          : Integer;
 Function  RemoveHeaderEntry      (Const AHeader,
                                   AEntry               : String;
                                   AQuoteType           : TRESTDWHeaderQuotingType) : String; Overload;
 Function  RemoveHeaderEntry      (Const AHeader,
                                   AEntry               : String;
                                   Var VOld             : String;
                                   AQuoteType           : TRESTDWHeaderQuotingType) : String; overload;
 Function  BytesToInt16           (Const AValue         : TRESTDWBytes;
                                   Const AIndex         : Integer = 0) : DWInt32;
 Function  BytesToInt32           (Const AValue         : TRESTDWBytes;
                                   Const AIndex         : Integer = 0) : DWInt32;
 Function  BytesToInt64           (Const AValue         : TRESTDWBytes;
                                   Const AIndex         : Integer = 0) : DWInt64;
 Procedure DeleteInvalidChar      (Var   Value          : String);
 Function  BooleanToString        (aValue               : Boolean) : String;
 Function  StringToBoolean        (aValue               : String)  : Boolean;
 Procedure CopyRDWString          (Const ASource        : String;
                                   Var VDest            : TRESTDWBytes;
                                   Const ADestIndex     : Integer;
                                   Const ALength        : Integer = -1);Overload;
 Procedure CopyRDWString          (Const ASource        : String;
                                   Const ASourceIndex   : Integer;
                                   Var VDest            : TRESTDWBytes;
                                   Const ADestIndex     : Integer;
                                   Const ALength        : Integer = -1);Overload;
 Function  GetTokenString         (Value                : String) : String;
 Function  GetBearerString        (Value                : String) : String;
 Function  GetPairJSONStr         (Status,
                                   MessageText          : String;
                                   Encoding             : TEncodeSelect = esUtf8) : String;
 Function  GetPairJSONInt         (Status               : Integer;
                                   MessageText          : String;
                                   Encoding             : TEncodeSelect = esUtf8) : String;

Implementation

Uses uRESTDWConsts, uRESTDWBase64, uRESTDWException{$IFNDEF HAS_FMX}, Windows{$ENDIF};

Function restdwMin(Const AValueOne,
                   AValueTwo        : Int64) : Int64;
Begin
 If AValueOne > AValueTwo Then
  Result := AValueTwo
 Else
  Result := AValueOne;
End;

Procedure AppendByte(Var VBytes: TRESTDWBytes;
                     Const AByte: Byte);
Var
 LOldLen: Integer;
Begin
 LOldLen := restdwLength(VBytes);
 SetLength(VBytes, LOldLen + 1);
 VBytes[LOldLen] := AByte;
End;

Function Result2JSON(wsResult: TResultErro): String;
Begin
 Result := '{"STATUS":"' + wsResult.Status + '","MENSSAGE":"' + wsResult.MessageText + '"}';
End;

Function GetPairJSONInt(Status      : Integer;
                        MessageText : String;
                        Encoding    : TEncodeSelect = esUtf8) : String;
Var
 WSResult : TResultErro;
Begin
 WSResult.STATUS      := IntToStr(Status);
 WSResult.MessageText := MessageText;
 Result               := Result2JSON(WSResult); //EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF FPC}, csUndefined{$ENDIF});
End;

Function GetPairJSONStr(Status,
                        MessageText : String;
                        Encoding    : TEncodeSelect = esUtf8) : String;
Var
 WSResult : TResultErro;
Begin
 WSResult.STATUS      := Status;
 WSResult.MessageText := MessageText;
 Result               := Result2JSON(WSResult); //EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF FPC}, csUndefined{$ENDIF});
End;

Function BytesToInt16(Const AValue : TRESTDWBytes;
                      Const AIndex : Integer = 0): DWInt32;{$IFDEF USE_INLINE}inline;{$ENDIF}
Begin
 Assert(Length(AValue) >= (AIndex+SizeOf(DWInt32)));
 Result := PDWInt32(@AValue[AIndex])^;
End;

Function BytesToInt32(Const AValue : TRESTDWBytes;
                      Const AIndex : Integer = 0) : DWInt32;{$IFDEF USE_INLINE}inline;{$ENDIF}
Begin
 Assert(Length(AValue) >= (AIndex+SizeOf(DWInt32)));
 Result := PDWInt32(@AValue[AIndex])^;
End;

Function BytesToInt64(Const AValue : TRESTDWBytes;
                      Const AIndex : Integer = 0) : DWInt64;{$IFDEF USE_INLINE}inline;{$ENDIF}
Begin
 Assert(Length(AValue) >= (AIndex+SizeOf(DWInt64)));
 Result := PDWInt64(@AValue[AIndex])^;
End;

Function RemoveHeaderEntry(Const AHeader,
                           AEntry         : String;
                           AQuoteType     : TRESTDWHeaderQuotingType) : String;
Begin
 Result := ReplaceHeaderSubItem(AHeader, AEntry, '', AQuoteType);
End;

Function RemoveHeaderEntry(Const AHeader,
                           AEntry         : String;
                           Var VOld       : String;
                           AQuoteType     : TRESTDWHeaderQuotingType) : String;
Begin
 Result := ReplaceHeaderSubItem(AHeader, AEntry, '', VOld, AQuoteType);
End;

Function MediaTypeMatches(Const AValue,
                          AMediaType    : String) : Boolean;
Begin
 If Pos('/', AMediaType) > 0 Then
  Result := TextIsSame(AValue, AMediaType)
 Else
  Result := TextStartsWith(AValue, AMediaType + '/'); {do not localize}
End;

Function MakeTempFilename(Const APath : TFileName = '') : TFileName;
{$IFNDEF FPC}
Var
 lPath,
 lExt: TFileName;
{$ENDIF}
Begin
 {$IFDEF FPC}
  Result := GetTempFileName(APath, 'restdw'); {Do not Localize}
 {$ELSE}
  lPath := APath;
  lExt := {$IFDEF UNIX}''{$ELSE}'.tmp'{$ENDIF}; {Do not Localize}
  {$IFDEF WINDOWS}
  If lPath = '' Then
   lPath := GTempPath;
  {$ELSE}
   {$IFDEF HAS_IOUtils_TPath}
    If lPath = '' Then
     lPath := {$IFDEF VCL_XE2_OR_ABOVE}System.{$ENDIF}IOUtils.TPath.GetTempPath;
   {$ENDIF}
  {$ENDIF}
  Result := GetUniqueFilename(lPath, 'restdw', lExt);
 {$ENDIF}
End;

Function CopyFileTo(Const Source,
                    Destination : TFileName): Boolean;
Begin
 Result := CopyFile(PChar(Source), PChar(Destination), False);
End;

Function GetUniqueFileName(Const APath,
                           APrefix,
                           AExt         : String) : String;
Var
 {$IFDEF FPC}
 LPrefix: string;
 {$ELSE}
 LNamePart : Integer;
 LFQE,
 LFName    : String;
 {$ENDIF}
Begin
 {$IFDEF FPC}
  LPrefix := APrefix;
  If LPrefix = '' Then
   LPrefix := 'restdw'; {Do not localize}
  Result := GetTempFileName(APath, LPrefix);
  {$ELSE}
  LFQE := AExt;
  If LFQE <> '' Then
   Begin
    If LFQE[1] <> '.' Then
     LFQE := '.' + LFQE;
   End;
  If APath <> '' Then
   Begin
    If Not DirectoryExists(APath) Then
     LFName := APrefix
    Else
     LFName := IncludeTrailingPathDelimiter(APath) + APrefix;
   End
  Else
   LFName := APrefix;
  LNamePart := Random(99999);
  Repeat
   Result := LFName + IntToHex(LNamePart, 8) + LFQE;
   If Not FileExists(Result) Then
    Break;
   Inc(LNamePart);
  Until False;
  {$ENDIF}
End;

Function IsHeaderMediaType(Const AHeaderLine,
                           AMediaType         : String): Boolean;
Begin
 Result := MediaTypeMatches(ExtractHeaderItem(AHeaderLine), AMediaType);
End;

Function IsHeaderMediaTypes(Const AHeaderLine : String;
                            Const AMediaTypes : Array Of String) : Boolean;
Var
 LHeader : String;
 I       : Integer;
Begin
 Result := False;
 LHeader := ExtractHeaderItem(AHeaderLine);
 For I := Low(AMediaTypes) To High(AMediaTypes) Do
  Begin
   If MediaTypeMatches(LHeader, AMediaTypes[I]) Then
    Begin
     Result := True;
     Exit;
    End;
  End;
End;

Function GetMIMETypeFromFile(Const AFile : TFileName) : String;
Var
 MIMEMap: TMIMETable;
Begin
 MIMEMap := TMimeTable.Create(True);
 Try
  Result := MIMEMap.GetFileMIMEType(AFile);
 Finally
  MIMEMap.Free;
 End;
End;

Function GetMIMEDefaultFileExt(Const MIMEType : String): TFileName;
Var
 MIMEMap : TMIMETable;
Begin
 MIMEMap := TMimeTable.Create(True);
 Try
  Result := MIMEMap.GetDefaultFileExt(MIMEType);
 Finally
  MIMEMap.Free;
 End;
End;

Function FindFirstNotOf(Const AFind,
                        AText           : String;
                        Const ALength   : Integer = -1;
                        Const AStartPos : Integer = 1)  : Integer;
Var
 I,
 LLength,
 LPos     : Integer;
Begin
 Result := 0;
 LLength := restdwLength(AText, ALength, AStartPos);
 If LLength > 0 Then
  Begin
   If Length(AFind) = 0 Then
    Begin
     Result := AStartPos;
     Exit;
    End;
   For I := 0 To LLength-1 Do
    Begin
     LPos := AStartPos + I;
     If InternalAnsiPos(AText[LPos], AFind) = 0 Then
      Begin
       Result := LPos;
       Exit;
      End;
    End;
  End;
End;

Function FindFirstOf(Const AFind,
                     AText           : String;
                     Const ALength   : Integer = -1;
                     Const AStartPos : Integer = 1) : Integer;
Var
 I,
 LLength,
 LPos     : Integer;
Begin
 Result := 0;
 If Length(AFind) > 0 Then
  Begin
   LLength := restdwLength(AText, ALength, AStartPos);
   If LLength > 0 Then
    Begin
     For I := 0 To LLength-1 Do
      Begin
       LPos := AStartPos + I;
       If InternalAnsiPos(AText[LPos], AFind) <> 0 Then
        Begin
         Result := LPos;
         Exit;
        End;
      End;
    End;
  End;
End;

Function OffsetFromUTC : TDateTime;
{$IFDEF WINDOWS}
Var
 iBias: Integer;
 tmez: TTimeZoneInformation;
{$ENDIF}
{$IFDEF UNIX}
 {$IFDEF USE_VCL_POSIX}
Var
 T  : Time_t;
 TV : TimeVal;
 UT : tm;
 {$ENDIF}
 {$IFDEF USE_BASEUNIX}
Var
 timeval: TTimeVal;
 timezone: TTimeZone;
 {$ENDIF}
{$ENDIF}
Begin
 {$IFDEF UNIX}
    {$IFDEF USE_VCL_POSIX}
  gettimeofday(TV, nil);
  T := TV.tv_sec;
  localtime_r(T, UT);
  Result := UT.tm_gmtoff / 60 / 60 / 24;
    {$ELSE}
      {$IFDEF USE_BASEUNIX}
  fpGetTimeOfDay (@TimeVal, @TimeZone);
  Result := -1 * (timezone.tz_minuteswest / 60 / 24)
      {$ELSE}
  Result := GOffsetFromUTC;
      {$ENDIF}
    {$ENDIF}
  {$ELSE}
      {$IFDEF WINDOWS}
  case GetTimeZoneInformation({$IFDEF WINCE}@{$ENDIF}tmez) of
    TIME_ZONE_ID_INVALID  :
      Raise eRESTDWFailedToRetreiveTimeZoneInfo.Create(cFailedTimeZoneInfo);
    TIME_ZONE_ID_UNKNOWN  :
       iBias := tmez.Bias;
    TIME_ZONE_ID_DAYLIGHT : begin
      iBias := tmez.Bias;
      if tmez.DaylightDate.wMonth <> 0 then begin
        iBias := iBias + tmez.DaylightBias;
      end;
    end;
    TIME_ZONE_ID_STANDARD : begin
      iBias := tmez.Bias;
      if tmez.StandardDate.wMonth <> 0 then begin
        iBias := iBias + tmez.StandardBias;
      end;
    end
   Else
    Raise eRESTDWFailedToRetreiveTimeZoneInfo.Create(cFailedTimeZoneInfo);
  End;
  {We use ABS because EncodeTime will only accept positive values}
  Result := EncodeTime(Abs(iBias) div 60, Abs(iBias) mod 60, 0, 0);
  {The GetTimeZone function returns values oriented towards converting
   a GMT time into a local time.  We wish to do the opposite by returning
   the difference between the local time and GMT.  So I just make a positive
   value negative and leave a negative value as positive}
  if iBias > 0 then begin
    Result := 0.0 - Result;
  end;
      {$ELSE}
  Result := GOffsetFromUTC;
      {$ENDIF}
    {$ENDIF}
End;

Function UTCOffsetToStr(Const AOffset    : TDateTime;
                        Const AUseGMTStr : Boolean = False) : String;
Var
 AHour,
 AMin,
 ASec,
 AMSec : Word;
Begin
 If (AOffset = 0.0) And AUseGMTStr Then
  Result := 'GMT'
 Else
  Begin
   DecodeTime(AOffset, AHour, AMin, ASec, AMSec);
   Result := Format(' %0.2d%0.2d', [AHour, AMin]); {do not localize}
   If AOffset < 0.0 Then
    Result[1] := '-'
   Else
    Result[1] := '+';  {do not localize}
  End;
End;

Function LocalDateTimeToGMT(Const Value      : TDateTime;
                            Const AUseGMTStr : Boolean = False) : String;
Var
 wDay,
 wMonth,
 wYear   : Word;
Begin
 DecodeDate(Value, wYear, wMonth, wDay);
 Result := Format('%s, %d %s %d %s %s',    {do not localize}
                  [wdays[DayOfWeek(Value)], wDay, monthnames[wMonth],
                   wYear, FormatDateTime('HH":"nn":"ss', Value), {do not localize}
                   UTCOffsetToStr(OffsetFromUTC, AUseGMTStr)]);
End;

Function RDWStrToInt(Const S  : String;
                     ADefault : Integer = 0) : Integer;
                     {$IFDEF USE_INLINE}inline;{$ENDIF}
Begin
 Result := StrToIntDef(Trim(S), ADefault);
End;

Function PosRDW(Const ASubStr,
                AStr          : String;
                AStartPos     : DWInt32) : DWInt32;
 Function FindStr(ALStartPos,
                  EndPos      : DWUInt32;
                  StartChar   : Char;
                  Const ALStr : String) : DWUInt32;
  Begin
   For Result := ALStartPos To EndPos Do
    Begin
     If ALStr[Result] = StartChar Then
      Exit;
    End;
   Result := 0;
  End;
 Function FindNextStr(ALStartPos, EndPos: DWUInt32; const ALStr, ALSubStr: string): DWUInt32;
 Begin
  For Result := ALStartPos + 1 To EndPos Do
   Begin
    If ALStr[Result] <> ALSubStr[Result - ALStartPos + 1] Then
     Exit;
   End;
  Result := 0;
 End;
Var
 StartChar : Char;
 LenSubStr,
 LenStr,
 EndPos    : DWUInt32;
Begin
 If AStartPos = 0 Then
  AStartPos := 1;
 Result := 0;
 LenSubStr := Length(ASubStr);
 LenStr := Length(AStr);
 If (LenSubStr = 0) Or
    (AStr = '')     Or
    (LenSubStr > (LenStr - (AStartPos - 1))) Then
  Exit;
 StartChar := ASubStr[1];
 EndPos := LenStr - LenSubStr + 1;
 If LenSubStr = 1 Then
  Result := FindStr(AStartPos, EndPos, StartChar, AStr)
 Else
  Begin
   Repeat
    Result := FindStr(AStartPos, EndPos, StartChar, AStr);
    If Result = 0 Then
     Break;
    AStartPos := Result;
    Result := FindNextStr(Result, AStartPos + LenSubStr - 1, AStr, ASubStr);
    If Result = 0 Then
     Begin
      Result := AStartPos;
      Exit;
     End;
    Inc(AStartPos);
   Until False;
  End;
End;

Function ValidateBytes(Const ABytes : TRESTDWBytes;
                       AByteIndex,
                       AByteCount   : Integer) : PByte;
Var
 Len : Integer;
Begin
 Len := Length(ABytes);
 If (AByteIndex < 0)    Or
    (AByteIndex >= Len) Then
  Raise Exception.CreateResFmt(PResStringRec(@cInvalidDestinationIndex), [AByteIndex]);
 If (Len - AByteIndex) < AByteCount Then
  Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
 If AByteCount > 0 Then
  Result := @ABytes[AByteIndex]
 Else
  Result := nil;
End;

Function ValidateBytes(Const ABytes : TRESTDWBytes;
                       AByteIndex,
                       AByteCount,
                       ANeeded      : Integer) : PByte;
Var
 Len : Integer;
Begin
 Len := Length(ABytes);
 If (AByteIndex < 0)    Or
    (AByteIndex >= Len) Then
  Raise Exception.CreateResFmt(PResStringRec(@cInvalidDestinationIndex), [AByteIndex]);
 If (Len - AByteIndex) < ANeeded Then
  Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
 If AByteCount > 0 Then
  Result := @ABytes[AByteIndex]
 Else
  Result := Nil;
End;

Function ValidateChars(Const AChars : TRESTDWWideChars;
                       ACharIndex,
                       ACharCount   : Integer) : PDWWideChar;
Var
 Len : Integer;
Begin
 Len := Length(String(AChars));
 If (ACharIndex < 0) Or (ACharIndex >= Len) Then
  Raise Exception.CreateResFmt(PResStringRec(@cCharIndexOutOfBounds), [ACharIndex]);
 If ACharCount < 0 Then
  Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount), [ACharCount]);
 If (Len - ACharIndex) < ACharCount Then
  Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount), [ACharCount]);
 If ACharCount > 0 Then
  Result := @AChars[ACharIndex]
 Else
  Result := nil;
End;

Function BytesToStringRaw(Const AValue: TRESTDWBytes) : String; Overload;{$IFDEF USE_INLINE}inline;{$ENDIF}
Begin
 Result := BytesToStringRaw(AValue, 0, -1);
End;

Function BytesToStringRaw(Const AValue      : TRESTDWBytes;
                          Const AStartIndex : Integer;
                          Const ALength     : Integer = -1) : String;
Var
 LLength : Integer;
Begin
 LLength := restdwLength(AValue, ALength, AStartIndex);
 If LLength > 0 Then
  SetString(Result, PAnsiChar(@AValue[AStartIndex]), LLength)
 Else
  Result := '';
End;

Function GetByteCount(Const AChars : PDWWideChar;
                      ACharCount   : Integer) : Integer;
Begin
 Result := ACharCount * SizeOf(WideChar);
End;

Function GetCharCount(Const ABytes: PByte; AByteCount: Integer): Integer;
Begin
 Result := AByteCount Div SizeOf(WideChar);
End;

Function GetByteCount(Const AChars : TRESTDWWideChars) : Integer;
begin
 If AChars <> Nil Then
  Result := GetByteCount(PDWWideChar(AChars), Length(String(AChars)))
 Else
  Result := 0;
End;

Function GetByteCount(Const AChars : TRESTDWWideChars;
                      ACharIndex,
                      ACharCount   : Integer): Integer;
Var
 LChars : PDWWideChar;
Begin
 LChars := ValidateChars(AChars, ACharIndex, ACharCount);
 If LChars <> Nil Then
  Result := GetByteCount(LChars, ACharCount)
 Else
  Result := 0;
End;

Function GetBytes(Const AChars : String) : TRESTDWBytes;{$IFDEF USE_INLINE}Inline;{$ENDIF}
Var
 Len : Integer;
Begin
 Result := nil;
 Len    := Length(AChars);
 If Len > 0 Then
  Begin
   SetLength(Result, Len);
   GetBytes(PDWWideChar(AChars), Len, PByte(Result), Len);
  End;
End;

Function GetBytes(Const AChars : PDWWideChar;
                  ACharCount   : Integer): TRESTDWBytes;
Var
 Len : Integer;
Begin
 Result := nil;
 Len    := GetByteCount(AChars, ACharCount);
 If Len > 0 Then
  Begin
   SetLength(Result, Len);
   GetBytes(AChars, ACharCount, PByte(Result), Len);
  End;
End;

Function GetBytes(Const AChars : PDWWideChar;
                  ACharCount   : Integer;
                  ABytes       : PByte;
                  AByteCount   : Integer) : Integer;
Var
 P : PDWWideChar;
 i : Integer;
Begin
 P := AChars;
 Result := restdwMin(ACharCount, AByteCount);
 For i := 1 To Result Do
  Begin
   If DWUInt16(P^) > $007F Then
    ABytes^ := Byte(Ord('?'))
   Else
    ABytes^ := Byte(P^);
   Inc(P);
   Inc(ABytes);
  End;
End;

Function GetChars(Const ABytes : TRESTDWBytes): TRESTDWWideChars;
Begin
 If ABytes <> Nil Then
  Result := GetChars(PByte(ABytes), Length(ABytes))
 Else
  Result := nil;
End;

Function GetCharCount(Const ABytes : TRESTDWBytes;
                      AByteIndex,
                      AByteCount   : Integer) : Integer;
Var
 LBytes : PByte;
Begin
 LBytes := ValidateBytes(ABytes, AByteIndex, AByteCount);
 If LBytes <> Nil Then
  Result := GetCharCount(LBytes, AByteCount)
 Else
  Result := 0;
End;

Function GetChars(Const ABytes : TRESTDWBytes;
                  AByteIndex,
                  AByteCount   : Integer) : TRESTDWWideChars;
Var
 Len : Integer;
Begin
 Result := Nil;
 Len    := GetCharCount(ABytes, AByteIndex, AByteCount);
 If Len > 0 Then
  Begin
   SetLength(Result, Len);
   GetChars(@ABytes[AByteIndex], AByteCount, Result, Len);
  End;
End;

Function GetChars(Const ABytes : TRESTDWBytes;
                  AByteIndex,
                  AByteCount   : Integer;
                  Var VChars   : TRESTDWWideChars;
                  ACharIndex   : Integer) : Integer;
Var
 LBytes : PByte;
Begin
 LBytes := ValidateBytes(ABytes, AByteIndex, AByteCount);
 If LBytes <> Nil Then
  Result := GetChars(LBytes, AByteCount, VChars, ACharIndex)
 Else
  Result := 0;
End;

Function GetChars(Const ABytes : PByte;
                  AByteCount   : Integer): TRESTDWWideChars;
Var
 Len : Integer;
Begin
 Len := GetCharCount(ABytes, AByteCount);
 If Len > 0 Then
  Begin
   SetLength(Result, Len);
   GetChars(ABytes, AByteCount, Result, Len);
  End;
End;

Function GetChars(Const ABytes : PByte;
                  AByteCount   : Integer;
                  Var VChars   : TRESTDWWideChars;
                  ACharIndex   : Integer): Integer;
Var
 LCharCount : Integer;
Begin
 If (ABytes     = Nil) And
    (AByteCount <> 0)  Then
  Raise Exception.CreateRes(PResStringRec(@cInvalidSourceArray));
 If AByteCount  < 0    Then
  Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount), [AByteCount]);
 If (ACharIndex < 0)   Or
    (ACharIndex > Length(VChars)) Then
  Raise Exception.CreateResFmt(PResStringRec(@cInvalidDestinationIndex), [ACharIndex]);
 LCharCount := GetCharCount(ABytes, AByteCount);
 If LCharCount > 0 Then
  Begin
   If (ACharIndex + LCharCount) > Length(VChars) Then
    Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
   Result := GetChars(ABytes, AByteCount, @VChars[ACharIndex], LCharCount);
  End
 Else
  Result := 0;
End;

Function GetChars(Const ABytes : PByte;
                  AByteCount   : Integer;
                  AChars       : PDWWideChar;
                  ACharCount   : Integer): Integer;
Var
 P : PByte;
 i : Integer;
Begin
 P := ABytes;
 Result := restdwMin(ACharCount, AByteCount);
 For i := 1 To Result Do
  Begin
   If P^ > $7F Then
    DWUInt16(AChars^) := $FFFD
   Else
    DWUInt16(AChars^) := P^;
   Inc(AChars);
   Inc(P);
  End;
End;

Procedure CopyRDWString(Const ASource    : String;
                        Var VDest        : TRESTDWBytes;
                        Const ADestIndex : Integer;
                        Const ALength    : Integer = -1);{$IFDEF USE_INLINE}inline;{$ENDIF}
Begin
 CopyRDWString(ASource, 1, VDest, ADestIndex, ALength);
End;

Procedure CopyRDWString(Const ASource      : String;
                        Const ASourceIndex : Integer;
                        Var VDest          : TRESTDWBytes;
                        Const ADestIndex   : Integer;
                        Const ALength      : Integer = -1);{$IFDEF USE_INLINE}inline;{$ENDIF}
Var
 LLength : Integer;
 LTmp    : TRESTDWWideChars;
Begin
 LTmp := nil; // keep the compiler happy
 LLength := restdwLength(ASource, ALength, ASourceIndex);
 If LLength > 0 Then
   LTmp := GetChars(RawToBytes(ASource[ASourceIndex], LLength)); // convert to Unicode
 GetBytes(LTmp, 0, Length(LTmp), VDest, ADestIndex);
End;

Function GetTokenString(Value : String) : String;
Var
 vPos : Integer;
Begin
 Result := '';
 vPos   := Pos('token=', Lowercase(Value));
 If vPos > 0 Then
  vPos  := vPos + Length('token=')
 Else
  Begin
   vPos := Pos('basic ', Lowercase(Value));
   If vPos > 0 Then
    vPos := vPos + Length('basic ');
  End;
 If vPos > 0 Then
  Result := Trim(Copy(Value, vPos, Length(Value)));
 If Trim(Result) <> '' Then
  Result := StringReplace(Result, '"', '', [rfReplaceAll]);
End;

Function GetBearerString(Value : String) : String;
Var
 vPos : Integer;
Begin
 Result := '';
 vPos   := Pos('bearer', Lowercase(Value));
 If vPos > 0 Then
  vPos  := vPos + Length('bearer');
 If vPos > 0 Then
  Result := Trim(Copy(Value, vPos, Length(Value)));
 If Trim(Result) <> '' Then
  Result := StringReplace(Result, '"', '', [rfReplaceAll]);
End;

Function GetBytes(Const AChars : PDWWideChar;
                  ACharCount   : Integer;
                  Var VBytes   : TRESTDWBytes;
                  AByteIndex   : Integer) : Integer;
Var
 Len,
 LByteCount : Integer;
 LBytes     : PByte;
Begin
 If (AChars     =  Nil) And
    (ACharCount <> 0)   Then
  Raise Exception.CreateRes(PResStringRec(@cInvalidSourceArray));
 If (VBytes     = Nil)  And
    (ACharCount <> 0)   Then
  Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
 If ACharCount < 0      Then
  Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount), [ACharCount]);
 Len        := Length(VBytes);
 LByteCount := GetByteCount(AChars, ACharCount);
 LBytes     := ValidateBytes(VBytes, AByteIndex, Len, LByteCount);
 Dec(Len, AByteIndex);
 If (ACharCount > 0)    And
    (Len > 0)           Then
  Result := GetBytes(AChars, ACharCount, LBytes, LByteCount)
 Else
  Result := 0;
End;

Function GetBytes(Const AChars : TRESTDWWideChars;
                  ACharIndex,
                  ACharCount   : Integer;
                  Var VBytes   : TRESTDWBytes;
                  AByteIndex   : Integer) : Integer;
Begin
 Result := GetBytes(ValidateChars(AChars, ACharIndex, ACharCount),
                    ACharCount, VBytes, AByteIndex);
End;

Function ByteToHex(Const AByte : Byte) : String;
                  {$IFDEF USE_INLINE} Inline;{$ENDIF}
Begin
 SetLength(Result, 2);
 Result[1] := RESTDWHexDigits[(AByte And $F0) Shr 4];
 Result[2] := RESTDWHexDigits[AByte  And $F];
End;

Procedure ExpandBytes(Var VBytes      : TRESTDWBytes;
                      Const AIndex    : Integer;
                      Const ACount    : Integer;
                      Const AFillByte : Byte = 0);
Var
 I : Integer;
Begin
 If ACount > 0 Then
  Begin
   If AIndex <> restdwLength(VBytes) Then
    Begin
     Assert(AIndex >= 0);
     Assert(AIndex < restdwLength(VBytes));
    End;
   SetLength(VBytes, restdwLength(VBytes) + ACount);
   For I := restdwLength(VBytes)-1 Downto AIndex + ACount Do
    VBytes[I] := VBytes[I-ACount];
   For I := AIndex To AIndex+ACount-1 Do
    VBytes[I] := AFillByte;
  End;
End;

Procedure InsertBytes(Var VBytes         : TRESTDWBytes;
                      Const ADestIndex   : Integer;
                      Const ASource      : TRESTDWBytes;
                      Const ASourceIndex : Integer = 0);
Var
 LAddLen : Integer;
Begin
 LAddLen := restdwLength(ASource, -1, ASourceIndex);
 If LAddLen > 0 Then
  Begin
   ExpandBytes(VBytes, ADestIndex, LAddLen);
   CopyBytes(ASource, ASourceIndex, VBytes, ADestIndex, LAddLen);
  End;
End;

Procedure InsertByte(Var VBytes   : TRESTDWBytes;
                     Const AByte  : Byte;
                     Const AIndex : Integer);
                     {$IFDEF USE_INLINE}Inline;{$ENDIF}
Begin
 ExpandBytes(VBytes, AIndex, 1, AByte);
End;

Procedure RemoveBytes(Var VBytes   : TRESTDWBytes;
                      Const ACount : Integer;
                      Const AIndex : Integer = 0);
Var
 I,
 LActual : Integer;
Begin
 Assert(AIndex >= 0);
 LActual := restdwMin(restdwLength(VBytes) - AIndex, ACount);
 If LActual > 0 Then
  Begin
   If (AIndex + LActual) < restdwLength(VBytes) Then
    Begin
     For I := AIndex To restdwLength(VBytes)-LActual-1 Do
      VBytes[I] := VBytes[I+LActual];
    End;
   SetLength(VBytes, restdwLength(VBytes) - LActual);
  End;
End;

Function ByteIndex(Const AByte       : Byte;
                   Const ABytes      : TRESTDWBytes;
                   Const AStartIndex : Integer = 0) : Integer;
Var
 I : Integer;
Begin
 Result := -1;
 For I := AStartIndex To restdwLength(ABytes) -1 Do
  Begin
   If ABytes[I] = AByte Then
    Begin
     Result := I;
     Exit;
    End;
  End;
End;

Function ByterdwInSet(Const ABytes : TRESTDWBytes;
                      Const AIndex : Integer;
                      Const ASet   : TRESTDWBytes) : Integer;
                     {$IFDEF USE_INLINE}Inline;{$ENDIF}
Begin
 If AIndex < 0 Then
  Raise eRESTDWException.Create('Invalid AIndex'); {do not localize}
 If AIndex < restdwLength(ABytes) Then
  Result := ByteIndex(ABytes[AIndex], ASet)
 Else
  Result := -1;
End;

Function ByteIsInSet(Const ABytes : TRESTDWBytes;
                     Const AIndex : Integer;
                     Const ASet   : TRESTDWBytes) : Boolean;
                    {$IFDEF USE_INLINE}Inline;{$ENDIF}
Begin
 Result := ByterdwInSet(ABytes, AIndex, ASet) > -1;
End;

Function ByteIsInEOL(Const ABytes : TRESTDWBytes;
                     Const AIndex : Integer) : Boolean;
Var
 LSet : TRESTDWBytes;
Begin
 SetLength(LSet, 2);
 LSet[0] := 13;
 LSet[1] := 10;
 Result := ByteIsInSet(ABytes, AIndex, LSet);
End;

Procedure AppendBytes(Var VBytes    : TRESTDWBytes;
                      Const AToAdd  : TRESTDWBytes;
                      Const AIndex  : Integer = 0;
                      Const ALength : Integer = -1);
Var
 LOldLen,
 LAddLen : Integer;
Begin
 LAddLen := restdwLength(AToAdd, ALength, AIndex);
 If LAddLen > 0 Then
  Begin
   LOldLen := restdwLength(VBytes);
   SetLength(VBytes, LOldLen + LAddLen);
   CopyBytes(AToAdd, AIndex, VBytes, LOldLen, LAddLen);
  End;
End;

Function IsHeaderValue(Const AHeaderLine : String;
                       Const AValue      : String) : Boolean;
Begin
 Result := TextIsSame(ExtractHeaderItem(AHeaderLine), AValue);
End;

Function ReadStringFromStream(AStream : TStream;
                              ASize   : Integer = -1) : String;
Var
 LBytes : TRESTDWBytes;
Begin
 ASize  := TRESTDWStreamHelper.ReadBytes(AStream, LBytes, ASize);
 Result := BytesToString(LBytes, 0, ASize);
End;

Procedure StringToStream(AStream    : TStream;
                         Const AStr : String);{$IFDEF USE_INLINE}Inline;{$ENDIF}
Begin
 WriteStringToStream(AStream, AStr, -1, 1);
End;

procedure WriteStringToStream(AStream       : TStream;
                              Const AStr    : String;
                              Const ALength : Integer = -1;
                              Const AIndex  : Integer = 1);
Var
 LLength : Integer;
 LBytes  : TRESTDWBytes;
Begin
 LBytes := nil;
 LLength := restdwLength(AStr, ALength, AIndex);
 If LLength > 0 Then
  Begin
   LBytes := ToBytes(AStr, LLength, AIndex);
   TRESTDWStreamHelper.Write(AStream, LBytes);
  End;
End;

Function ReadBytesFromStream(Const AStream : TStream;
                             Var   ABytes  : TRESTDWBytes;
                             Const Count   : TRESTDWStreamSize;
                             Const AIndex  : Integer = 0) : TRESTDWStreamSize;
Begin
 Result := TRESTDWStreamHelper.ReadBytes(AStream, ABytes, Count, AIndex);
End;

Procedure WriteBytesToStream(Const AStream : TStream;
                             Const ABytes  : TRESTDWBytes;
                             Const ASize   : Integer = -1;
                             Const AIndex  : Integer = 0);
Begin
 TRESTDWStreamHelper.Write(AStream, ABytes, ASize, AIndex);
End;

Procedure CopyBytes(Const ASource      : TRESTDWBytes;
                    Const ASourceIndex : Integer;
                    Var   VDest        : TRESTDWBytes;
                    Const ADestIndex   : Integer;
                    Const ALength      : Integer);
Begin
 Assert(ASourceIndex >= 0);
 Assert((ASourceIndex+ALength) <= restdwLength(ASource));
 Move(ASource[ASourceIndex], VDest[ADestIndex], ALength);
End;

Function RawToBytes(Const AValue : String;
                    Const ASize  : Integer) : TRESTDWBytes;
Var
 vSizeChar : Integer;
 vString   : String;
Begin
 vSizeChar := 1;
 If SizeOf(WideChar) > 1 Then
  vSizeChar := 2;
// SetLength(Result, ASize * vSizeChar);
 SetLength(Result, ASize);
 If ASize > 0 Then
  Begin
//   If vSizeChar = 2 Then
//    Move(AValue[InitStrPos], PRESTDWBytes(Result)^, Length(Result))
//   Else
    Move(AnsiString(AValue)[InitStrPos], PRESTDWBytes(Result)^, Length(Result));
  End;
//  Move(PAnsiChar(AValue)^, PRESTDWBytes(Result)^, ASize);
End;

Function ToBytes(Const AValue : String) : TRESTDWBytes;
Begin
 Result := ToBytes(AValue, -1, 1);
End;

Function ToBytes(Const AValue  : String;
                 Const ALength : Integer;
                 Const AIndex  : Integer = 1) : TRESTDWBytes;
Var
 LLength: Integer;
 LBytes: TRESTDWBytes;
Begin
 {$IFDEF STRING_IS_ANSI}
  LBytes := nil; // keep the compiler happy
 {$ENDIF}
 LLength := restdwLength(AValue, ALength, AIndex);
 If LLength > 0 Then
  Result := RawToBytes(AValue, LLength)
 Else
  SetLength(Result, 0);
End;

Function ToBytes(Const AValue : Char) : TRESTDWBytes;
Var
 LBytes : TRESTDWBytes;
Begin
 LBytes := RawToBytes(AValue, 1);
 Result := LBytes;
End;

Function ToBytes(Const AValue : TRESTDWBytes;
                 Const ASize  : Integer;
                 Const AIndex : Integer = 0) : TRESTDWBytes;
Var
 LSize : Integer;
Begin
 LSize := restdwLength(AValue, ASize, AIndex);
 SetLength(Result, LSize);
 If LSize > 0 Then
  CopyBytes(AValue, AIndex, Result, 0, LSize);
End;


Function InternalrestdwIndexOfName(AStrings             : TStrings;
                                   Const AStr           : String;
                                   Const ACaseSensitive : Boolean = False) : Integer;
Var
 I : Integer;
Begin
 Result := -1;
 For I := 0 To AStrings.Count - 1 Do
  Begin
   If ACaseSensitive Then
    Begin
     If AStrings.Names[I] = AStr Then
      Begin
       Result := I;
       Exit;
      End;
    End
   Else
    Begin
     If TextIsSame(AStrings.Names[I], AStr) Then
      Begin
       Result := I;
       Exit;
      End;
    End;
  End;
End;

Function restdwIndexOfName(AStrings             : TStrings;
                           Const AStr           : String;
                           Const ACaseSensitive : Boolean = False) : Integer;
Begin
 Result := InternalrestdwIndexOfName(AStrings, AStr, ACaseSensitive);
End;

Function ExtractHeaderItem(Const AHeaderLine : String) : String;
Var
 s : string;
Begin
 s      := AHeaderLine;
 Result := Trim(Fetch(s, ';'));
End;

Function CharRange(Const AMin, AMax : Char) : String;
Var
 i : Char;
Begin
 SetLength(Result, Ord(AMax) - Ord(AMin) + 1);
 For i := AMin To AMax Do
  Result[Ord(i) - Ord(AMin) + 1] := i;
End;

Function TextStartsWith(Const S, SubS : String) : Boolean;
Var
 LLen : Integer;
 P1,
 P2   : PChar;
Begin
 LLen   := Length(SubS);
 Result := LLen <= Length(S);
 If Result Then
  Begin
   P1 := PChar(S);
   P2 := PChar(SubS);
   Result := AnsiCompareText(Copy(S, 1, LLen), SubS) = 0;
  End;
End;

Function TextEndsWith(Const S, SubS : String) : Boolean;
Var
 LLen : Integer;
 P1,
 P2   : PChar;
Begin
 LLen := Length(SubS);
 Result := LLen <= Length(S);
 If Result Then
  Begin
   P1 := PChar(S);
   P2 := PChar(SubS);
   Result := AnsiCompareText(Copy(S, Length(S)-LLen+1, LLen), SubS) = 0;
  End;
End;

Function Max(Const AValueOne,
             AValueTwo        : Int64) : Int64;
Begin
 If AValueOne < AValueTwo Then
  Result := AValueTwo
 Else
  Result := AValueOne;
End;

Function Min(Const AValueOne,
             AValueTwo        : Int64) : Int64;{$IFDEF USE_INLINE}inline;{$ENDIF}
Begin
 If AValueOne > AValueTwo Then
  Result := AValueTwo
 Else
  Result := AValueOne;
End;

Procedure SplitHeaderSubItems(AHeaderLine : String;
                              AItems      : TStrings;
                              AQuoteType  : TRESTDWHeaderQuotingType);
Var
 LName,
 LValue,
 LSep    : String;
 LQuoted : Boolean;
 I       : Integer;
 Function FetchQuotedString(Var VHeaderLine : String) : String;
 Begin
  Result := '';
  Delete(VHeaderLine, 1, 1);
  I := 1;
  While I <= Length(VHeaderLine) Do
   Begin
    If VHeaderLine[I] = '\' Then
     Begin
      If I < Length(VHeaderLine) Then
       Delete(VHeaderLine, I, 1);
     End
    Else If VHeaderLine[I] = '"' Then
     Begin
      Result := Copy(VHeaderLine, 1, I-1);
      VHeaderLine := Copy(VHeaderLine, I+1, MaxInt);
      Break;
     End;
    Inc(I);
   End;
  Fetch(VHeaderLine, ';');
 End;
Begin
 Fetch(AHeaderLine, ';');
 LSep := CharRange(#0, #32) + QuoteSpecials[AQuoteType] + #127;
 While AHeaderLine <> '' Do
  Begin
   AHeaderLine := TrimLeft(AHeaderLine);
   If AHeaderLine = '' Then
    Exit;
   LName := Trim(Fetch(AHeaderLine, '=')); {do not localize}
   AHeaderLine := TrimLeft(AHeaderLine);
   LQuoted := TextStartsWith(AHeaderLine, '"'); {do not localize}
   If LQuoted Then
    LValue := FetchQuotedString(AHeaderLine)
   Else
    Begin
     I := FindFirstOf(LSep, AHeaderLine);
     If I <> 0 Then
      Begin
       LValue := Copy(AHeaderLine, 1, I-1);
       If AHeaderLine[I] = ';' Then
        Inc(I);
       Delete(AHeaderLine, 1, I-1);
      End
     Else
      Begin
       LValue := AHeaderLine;
       AHeaderLine := '';
      End;
    End;
   If (LName <> '')   And
      ((LValue <> '') Or   LQuoted) Then
    AItems.AddObject(LName + '=' + LValue, TObject(LQuoted));
  End;
End;

Function StrToDay(Const ADay : String) : Byte;
Begin
 Result := Succ(PosInStrArray(ADay,['SUN','MON','TUE','WED','THU','FRI','SAT'],False));
End;

Function StrToMonth(Const AMonth : String) : Byte;
Const
 Months : Array[0..7] Of Array[1..12] Of String = (('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'),
                                                   ('',    '',    '',    '',    '',   'JUNE','JULY', '',   'SEPT', '',    '',    ''),
                                                   ('',    '',    'MRZ', '',    'MAI', '',    '',    '',    '',    'OKT', '',    'DEZ'),
                                                   ('ENO', 'FBRO','MZO', 'AB',  '',    '',    '',    'AGTO','SBRE','OBRE','NBRE','DBRE'),
                                                   ('',    '',    'MRT', '',    'MEI', '',    '',    '',    '',    'OKT', '',    ''),
                                                   ('JANV','F'+Char($C9)+'V', 'MARS','AVR', 'MAI', 'JUIN','JUIL','AO'+Char($DB), 'SEPT','',    '',    'D'+Char($C9)+'C'),
                                                   ('',    'F'+Char($C9)+'VR','',    '',    '',    '',    'JUI',    'AO'+Char($DB)+'T','',    '',    '',    ''),
                                                   ('',    '',     '',   '', 'MAJ',    '',    '',       '',     'AVG',    '',    '',  ''));
Var
 I : Integer;
Begin
 If AMonth <> '' Then
  Begin
   For i := Low(Months) To High(Months) Do
    Begin
     For Result := Low(Months[i]) To High(Months[i]) Do
      Begin
       If TextIsSame(AMonth, Months[i][Result]) Then
        Exit;
      End;
    End;
  End;
 Result := 0;
End;

Function IsNumeric(Const AString : String;
                   Const ALength : Integer;
                   Const AIndex  : Integer = 1) : Boolean;
Var
 I,
 LLen : Integer;
Begin
 Result := False;
 LLen := restdwLength(AString, ALength, AIndex);
 If LLen > 0 Then
  Begin
   For I := 0 To LLen-1 Do
    Begin
     If Not IsNumeric(AString[AIndex+i]) Then
      Exit;
    End;
   Result := True;
  End;
End;

Function IsNumeric(Const AChar : Char) : Boolean;
Begin
 Result := (AChar >= '0') And
           (AChar <= '9'); {Do not Localize}
End;

Function CharEquals(Const AString  : String;
                    Const ACharPos : Integer;
                    Const AValue   : Char) : Boolean;
Begin
 If ACharPos < 1 Then
  Raise eRESTDWException.Create('Invalid ACharPos');{ do not localize }
 Result := ACharPos <= Length(AString);
 If Result Then
  Result := AString[ACharPos] = AValue;
End;

Function RawStrInternetToDateTime(Var Value     : String;
                                  Var VDateTime : TDateTime) : Boolean;
Var
 I      : Integer;
 Dt,
 Mo,
 Yr,
 Ho,
 Min,
 Sec,
 MSec   : Word;
 sYear,
 sTime,
 sDelim : String;
 LAM,
 LPM    : Boolean;
 Procedure ParseDayOfMonth;
 Begin
  Dt := RDWStrToInt(Fetch(Value, sDelim), 1);
  Value := TrimLeft(Value);
 End;
 Procedure ParseMonth;
 Begin
  Mo := StrToMonth(Fetch (Value, sDelim));
  Value := TrimLeft(Value);
 End;
 Function ParseISO8601: Boolean;
 Var
  S       : String;
  Len,
  Offset,
  Found   : Integer;
 Begin
  Result := False;
  S := Value;
  Len := Length(S);
  If Not IsNumeric(S, 4) Then
   Exit;
  Dt     := 1;
  Mo     := 1;
  Ho     := 0;
  Min    := 0;
  Sec    := 0;
  MSec   := 0;
  Yr     := RDWStrToInt( Copy(S, 1, 4) );
  Offset := 5;
  If Offset <= Len Then
   Begin
    If (Not CharEquals(S, Offset, '-')) Or
       (Not IsNumeric (S, 2, Offset+1)) Then
     Exit;
    Mo := RDWStrToInt( Copy(S, Offset+1, 2) );
    Inc(Offset, 3);
    If Offset <= Len Then
     Begin
      If (Not CharEquals(S, Offset, '-')) Or {Do not Localize}
         (Not IsNumeric(S, 2, Offset+1))  Then
       Exit;
      Dt := RDWStrToInt( Copy(S, Offset+1, 2) );
      Inc(Offset, 3);
      If Offset <= Len Then
       Begin
        If (Not CharEquals(S, Offset, 'T'))   Or     {Do not Localize}
           (Not IsNumeric(S, 2, Offset+1))    Or
           (Not CharEquals(S, Offset+3, ':')) Then   {Do not Localize}
         Exit;
        Ho := RDWStrToInt( Copy(S, Offset+1, 2) );
        Inc(Offset, 4);
        If Not IsNumeric(S, 2, Offset) Then
         Exit;
        Min := RDWStrToInt( Copy(S, Offset, 2) );
        Inc(Offset, 2);
        If Offset > Len Then
         Exit;
        If CharEquals(S, Offset, ':') Then {Do not Localize}
         Begin
          If Not IsNumeric(S, 2, Offset+1) Then
           Exit;
          Sec := RDWStrToInt( Copy(S, Offset+1, 2) );
          Inc(Offset, 3);
          If Offset > Len Then
           Exit;
          If CharEquals(S, Offset, '.') Then {Do not Localize}
           Begin
            Found := FindFirstNotOf('0123456789', S, -1, Offset+1); {Do not Localize}
            If Found = 0 Then
             Exit;
            MSec := RDWStrToInt( Copy(S, Offset+1, Found-Offset-1) );
            Inc(Offset, Found-Offset+1);
           End;
         End;
       End;
     End;
   End;
  VDateTime := EncodeDate(Yr, Mo, Dt) + EncodeTime(Ho, Min, Sec, MSec);
  Value := Copy(S, Offset, MaxInt);
  Result := True;
 End;
Begin
 Result := False;
 VDateTime := 0.0;
 Value := Trim(Value);
 If Length(Value) = 0 Then
  Exit;
 Try
  If ParseISO8601 Then
   Begin
    Result := True;
    Exit;
   End;
  If StrToDay(Copy(Value, 1, 3)) > 0 Then
   Begin
    If CharEquals(Value, 4, ',')      And
      (Not CharEquals(Value, 5, ' ')) Then
     Insert(' ', Value, 5);
    Fetch(Value);
    Value := TrimLeft(Value);
   End;
  i := InternalAnsiPos('-', Value);    {Do not Localize}
  If (i > 1) And
     (i < InternalAnsiPos(' ', Value)) Then
   sDelim := '-'
  Else
   sDelim := ' ';    {Do not Localize}
  If StrToMonth(Fetch(Value, sDelim, False)) > 0 Then
   Begin
    ParseMonth;
    ParseDayOfMonth;
   End
  Else
   Begin
    ParseDayOfMonth;
    ParseMonth;
   End;
  sYear := Fetch(Value);
  Yr    := RDWStrToInt(sYear, High(Word));
  If Yr = High(Word) Then
   Begin // Is sTime valid Integer?
    sTime := sYear;
    sYear := Fetch(Value);
    Value := TrimRight(sTime + ' ' + Value);
    Yr    := RDWStrToInt(sYear);
   End;
  If Length(sYear) = 2 Then
   Begin
    If (Yr <= 49) Then
     Inc(Yr, 2000)
    Else If (Yr >= 50) And
            (Yr <= 99) Then
     Inc(Yr, 1900);
   End
  Else If Length(sYear) = 3 Then
   Inc(Yr, 1900);
  VDateTime := EncodeDate(Yr, Mo, Dt);
  If InternalAnsiPos('AM', Value) > 0 Then
   Begin{do not localize}
    LAM := True;
    LPM := False;
    Value := Fetch(Value, 'AM');  {do not localize}
   End
  Else If InternalAnsiPos('PM', Value) > 0 Then
   Begin {do not localize}
    LAM := False;
    LPM := True;
    Value := Fetch(Value, 'PM');  {do not localize}
   End
  Else
   Begin
    LAM := False;
    LPM := False;
   End;
  i := InternalAnsiPos('.', Value);       {do not localize}
  If (i > 0) And
     (i < InternalAnsiPos(' ', Value)) Then
   sDelim := '.'                {do not localize}
  Else
   sDelim := ':';                {do not localize}
  i := InternalAnsiPos(sDelim, Value);
  If i > 0 Then
   Begin
    sTime := Fetch(Value, ' ');  {do not localize}
    Ho    := RDWStrToInt( Fetch(sTime, sDelim), 0);
    Min   := RDWStrToInt( Fetch(sTime, sDelim), 0);
    Sec   := RDWStrToInt( Fetch(sTime), 0);
    MSec  := 0;
    Value := TrimLeft(Value);
    If LAM Then
     Begin
      If Ho = 12 Then
       Ho := 0;
     End
    Else If LPM Then
     Begin
      If Ho < 12 Then
       Inc(Ho, 12);
     End;
    VDateTime := VDateTime + EncodeTime(Ho, Min, Sec, MSec);
   End;
  Value := TrimLeft(Value);
  Result := True;
 Except
  VDateTime := 0.0;
  Result := False;
 End;
End;

Procedure RDWDelete(Var s    : String;
                    AOffset,
                    ACount   : Integer);
Begin
 Delete(s, AOffset, ACount);
End;

Function TimeZoneToGmtOffsetStr(Const ATimeZone : String) : String;
Type
 TimeZoneOffset = Record
  TimeZone,
  Offset: String;
End;
Const
 cTimeZones : Array[0..90] Of TimeZoneOffset = ((TimeZone:'A';    Offset:'+0100'), // Alpha Time Zone - Military                             {do not localize}
                                                (TimeZone:'ACDT'; Offset:'+1030'), // Australian Central Daylight Time                       {do not localize}
                                                (TimeZone:'ACST'; Offset:'+0930'), // Australian Central Standard Time                       {do not localize}
                                                (TimeZone:'ADT';  Offset:'-0300'), // Atlantic Daylight Time - North America                 {do not localize}
                                                (TimeZone:'AEDT'; Offset:'+1100'), // Australian Eastern Daylight Time                       {do not localize}
                                                (TimeZone:'AEST'; Offset:'+1000'), // Australian Eastern Standard Time                       {do not localize}
                                                (TimeZone:'AKDT'; Offset:'-0800'), // Alaska Daylight Time                                   {do not localize}
                                                (TimeZone:'AKST'; Offset:'-0900'), // Alaska Standard Time                                   {do not localize}
                                                (TimeZone:'AST';  Offset:'-0400'), // Atlantic Standard Time - North America                 {do not localize}
                                                (TimeZone:'AWDT'; Offset:'+0900'), // Australian Western Daylight Time                       {do not localize}
                                                (TimeZone:'AWST'; Offset:'+0800'), // Australian Western Standard Time                       {do not localize}
                                                (TimeZone:'B';    Offset:'+0200'), // Bravo Time Zone - Military                             {do not localize}
                                                (TimeZone:'BST';  Offset:'+0100'), // British Summer Time - Europe                           {do not localize}
                                                (TimeZone:'C';    Offset:'+0300'), // Charlie Time Zone - Military                           {do not localize}
                                                (TimeZone:'CDT';  Offset:'+1030'), // Central Daylight Time - Australia                      {do not localize}
                                                (TimeZone:'CDT';  Offset:'-0500'), // Central Daylight Time - North America                  {do not localize}
                                                (TimeZone:'CEDT'; Offset:'+0200'), // Central European Daylight Time                         {do not localize}
                                                (TimeZone:'CEST'; Offset:'+0200'), // Central European Summer Time                           {do not localize}
                                                (TimeZone:'CET';  Offset:'+0100'), // Central European Time                                  {do not localize}
                                                (TimeZone:'CST';  Offset:'+1030'), // Central Summer Time - Australia                        {do not localize}
                                                (TimeZone:'CST';  Offset:'+0930'), // Central Standard Time - Australia                      {do not localize}
                                                (TimeZone:'CST';  Offset:'-0600'), // Central Standard Time - North America                  {do not localize}
                                                (TimeZone:'CXT';  Offset:'+0700'), // Christmas Island Time - Australia                      {do not localize}
                                                (TimeZone:'D';    Offset:'+0400'), // Delta Time Zone - Military                             {do not localize}
                                                (TimeZone:'E';    Offset:'+0500'), // Echo Time Zone - Military                              {do not localize}
                                                (TimeZone:'EDT';  Offset:'+1100'), // Eastern Daylight Time - Australia                      {do not localize}
                                                (TimeZone:'EDT';  Offset:'-0400'), // Eastern Daylight Time - North America                  {do not localize}
                                                (TimeZone:'EEDT'; Offset:'+0300'), // Eastern European Daylight Time                         {do not localize}
                                                (TimeZone:'EEST'; Offset:'+0300'), // Eastern European Summer Time                           {do not localize}
                                                (TimeZone:'EET';  Offset:'+0200'), // Eastern European Time                                  {do not localize}
                                                (TimeZone:'EST';  Offset:'+1100'), // Eastern Summer Time - Australia                        {do not localize}
                                                (TimeZone:'EST';  Offset:'+1000'), // Eastern Standard Time - Australia                      {do not localize}
                                                (TimeZone:'EST';  Offset:'-0500'), // Eastern Standard Time - North America                  {do not localize}
                                                (TimeZone:'F';    Offset:'+0600'), // Foxtrot Time Zone - Military                           {do not localize}
                                                (TimeZone:'G';    Offset:'+0700'), // Golf Time Zone - Military                              {do not localize}
                                                (TimeZone:'GMT';  Offset:'+0000'), // Greenwich Mean Time - Europe                           {do not localize}
                                                (TimeZone:'H';    Offset:'+0800'), // Hotel Time Zone - Military                             {do not localize}
                                                (TimeZone:'HAA';  Offset:'-0300'), // Heure Avancée de l'Atlantique - North America          {do not localize}
                                                (TimeZone:'HAC';  Offset:'-0500'), // Heure Avancée du Centre - North America                {do not localize}
                                                (TimeZone:'HADT'; Offset:'-0900'), // Hawaii-Aleutian Daylight Time - North America          {do not localize}
                                                (TimeZone:'HAE';  Offset:'-0400'), // Heure Avancée de l'Est - North America                 {do not localize}
                                                (TimeZone:'HAP';  Offset:'-0700'), // Heure Avancée du Pacifique - North America             {do not localize}
                                                (TimeZone:'HAR';  Offset:'-0600'), // Heure Avancée des Rocheuses - North America            {do not localize}
                                                (TimeZone:'HAST'; Offset:'-1000'), // Hawaii-Aleutian Standard Time - North America          {do not localize}
                                                (TimeZone:'HAT';  Offset:'-0230'), // Heure Avancée de Terre-Neuve - North America           {do not localize}
                                                (TimeZone:'HAY';  Offset:'-0800'), // Heure Avancée du Yukon - North America                 {do not localize}
                                                (TimeZone:'HNA';  Offset:'-0400'), // Heure Normale de l'Atlantique - North America          {do not localize}
                                                (TimeZone:'HNC';  Offset:'-0600'), // Heure Normale du Centre - North America                {do not localize}
                                                (TimeZone:'HNE';  Offset:'-0500'), // Heure Normale de l'Est - North America                 {do not localize}
                                                (TimeZone:'HNP';  Offset:'-0800'), // Heure Normale du Pacifique - North America             {do not localize}
                                                (TimeZone:'HNR';  Offset:'-0700'), // Heure Normale des Rocheuses - North America            {do not localize}
                                                (TimeZone:'HNT';  Offset:'-0330'), // Heure Normale de Terre-Neuve - North America           {do not localize}
                                                (TimeZone:'HNY';  Offset:'-0900'), // Heure Normale du Yukon - North America                 {do not localize}
                                                (TimeZone:'I';    Offset:'+0900'), // India Time Zone - Military                             {do not localize}
                                                (TimeZone:'IST';  Offset:'+0100'), // Irish Summer Time - Europe                             {do not localize}
                                                (TimeZone:'K';    Offset:'+1000'), // Kilo Time Zone - Military                              {do not localize}
                                                (TimeZone:'L';    Offset:'+1100'), // Lima Time Zone - Military                              {do not localize}
                                                (TimeZone:'M';    Offset:'+1200'), // Mike Time Zone - Military                              {do not localize}
                                                (TimeZone:'MDT';  Offset:'-0600'), // Mountain Daylight Time - North America                 {do not localize}
                                                (TimeZone:'MEHSZ';Offset:'+0300'), // Mitteleuropäische Hochsommerzeit - Europe              {do not localize}
                                                (TimeZone:'MESZ'; Offset:'+0200'), // Mitteleuroäische Sommerzeit - Europe                   {do not localize}
                                                (TimeZone:'MEZ';  Offset:'+0100'), // Mitteleuropäische Zeit - Europe                        {do not localize}
                                                (TimeZone:'MSD';  Offset:'+0400'), // Moscow Daylight Time - Europe                          {do not localize}
                                                (TimeZone:'MSK';  Offset:'+0300'), // Moscow Standard Time - Europe                          {do not localize}
                                                (TimeZone:'MST';  Offset:'-0700'), // Mountain Standard Time - North America                 {do not localize}
                                                (TimeZone:'N';    Offset:'-0100'), // November Time Zone - Military                          {do not localize}
                                                (TimeZone:'NDT';  Offset:'-0230'), // Newfoundland Daylight Time - North America             {do not localize}
                                                (TimeZone:'NFT';  Offset:'+1130'), // Norfolk (Island), Time - Australia                     {do not localize}
                                                (TimeZone:'NST';  Offset:'-0330'), // Newfoundland Standard Time - North America             {do not localize}
                                                (TimeZone:'O';    Offset:'-0200'), // Oscar Time Zone - Military                             {do not localize}
                                                (TimeZone:'P';    Offset:'-0300'), // Papa Time Zone - Military                              {do not localize}
                                                (TimeZone:'PDT';  Offset:'-0700'), // Pacific Daylight Time - North America                  {do not localize}
                                                (TimeZone:'PST';  Offset:'-0800'), // Pacific Standard Time - North America                  {do not localize}
                                                (TimeZone:'Q';    Offset:'-0400'), // Quebec Time Zone - Military                            {do not localize}
                                                (TimeZone:'R';    Offset:'-0500'), // Romeo Time Zone - Military                             {do not localize}
                                                (TimeZone:'S';    Offset:'-0600'), // Sierra Time Zone - Military                            {do not localize}
                                                (TimeZone:'T';    Offset:'-0700'), // Tango Time Zone - Military                             {do not localize}
                                                (TimeZone:'U';    Offset:'-0800'), // Uniform Time Zone - Military                           {do not localize}
                                                (TimeZone:'UT';   Offset:'+0000'), // Universal Time - Europe                                {do not localize}
                                                (TimeZone:'UTC';  Offset:'+0000'), // Coordinated Universal Time - Europe                    {do not localize}
                                                (TimeZone:'V';    Offset:'-0900'), // Victor Time Zone - Military                            {do not localize}
                                                (TimeZone:'W';    Offset:'-1000'), // Whiskey Time Zone - Military                           {do not localize}
                                                (TimeZone:'WDT';  Offset:'+0900'), // Western Daylight Time - Australia                      {do not localize}
                                                (TimeZone:'WEDT'; Offset:'+0100'), // Western European Daylight Time - Europe                {do not localize}
                                                (TimeZone:'WEST'; Offset:'+0100'), // Western European Summer Time - Europe                  {do not localize}
                                                (TimeZone:'WET';  Offset:'+0000'), // Western European Time - Europe                         {do not localize}
                                                (TimeZone:'WST';  Offset:'+0900'), // Western Summer Time - Australia                        {do not localize}
                                                (TimeZone:'WST';  Offset:'+0800'), // Western Standard Time - Australia                      {do not localize}
                                                (TimeZone:'X';    Offset:'-1100'), // X-ray Time Zone - Military                             {do not localize}
                                                (TimeZone:'Y';    Offset:'-1200'), // Yankee Time Zone - Military                            {do not localize}
                                                (TimeZone:'Z';    Offset:'+0000')  // Zulu Time Zone - Military                              {do not localize}
                                                );
Var
 I : Integer;
Begin
 For I := Low(cTimeZones) To High(cTimeZones) Do
  Begin
   If TextIsSame(ATimeZone, cTimeZones[I].TimeZone) Then
    Begin
     Result := cTimeZones[I].Offset;
     Exit;
    End;
  End;
 Result := '-0000' {do not localize}
End;

Function GmtOffsetStrToDateTime(Const S : String) : TDateTime;
Var
 sTmp : String;
Begin
 Result := 0.0;
 sTmp   := Trim(S);
 sTmp   := Fetch(sTmp);
 If Length(sTmp) > 0 Then
  Begin
   If not CharIsInSet(sTmp, 1, '-+') Then
    sTmp := TimeZoneToGmtOffsetStr(sTmp)
   Else
    Begin
     If Length(sTmp) = 6 Then
      Begin
       If CharEquals(sTmp, 4, ':') Then
        RDWDelete(sTmp, 4, 1);
      End
     Else If Length(sTmp) = 3 Then
      sTmp := sTmp + '00';
     If (Length(sTmp) <> 5)         Or
        (Not IsNumeric(sTmp, 2, 2)) Or
        (Not IsNumeric(sTmp, 2, 4)) Then
      Exit;
    End;
   Try
    Result := EncodeTime(RDWStrToInt(Copy(sTmp, 2, 2)), RDWStrToInt(Copy(sTmp, 4, 2)), 0, 0);
    If CharEquals(sTmp, 1, '-') Then
     Result := -Result;
   Except
    Result := 0.0;
   End;
  End;
End;

Function GMTToLocalDateTime(S : String) : TDateTime;
Var
 DateTimeOffset : TDateTime;
Begin
 If RawStrInternetToDateTime(S, Result) Then
  Begin
   DateTimeOffset := GmtOffsetStrToDateTime(S);
   Result := Result - DateTimeOffset + OffsetFromUTC;
  End;
End;

Function ReplaceHeaderSubItem(Const AHeaderLine,
                              ASubItem,
                              AValue             : String;
                              AQuoteType         : TRESTDWHeaderQuotingType) : String;
Var
 LOld : String;
Begin
 Result := ReplaceHeaderSubItem(AHeaderLine, ASubItem, AValue, LOld, AQuoteType);
End;

Function ReplaceHeaderSubItem(Const AHeaderLine,
                              ASubItem,
                              AValue            : String;
                              Var VOld          : String;
                              AQuoteType        : TRESTDWHeaderQuotingType) : String;
Var
 LItems : TStringList;
 I      : Integer;
 LValue : string;
 Function QuoteString(Const S            : String;
                      Const AForceQuotes : Boolean) : String;
 Var
  I            : Integer;
  LAddQuotes   : Boolean;
  LNeedQuotes,
  LNeedEscape  : String;
 Begin
  Result := '';
  If Length(S) = 0 Then
   Exit;
  LAddQuotes  := AForceQuotes;
  LNeedQuotes := CharRange(#0, #32) + QuoteSpecials[AQuoteType] + #127;
  LNeedEscape := '"\';
  If AQuoteType In [QuoteRFC822, QuoteMIME] Then
   LNeedEscape := LNeedEscape + CR;
  For I := 1 To Length(S) Do
   Begin
    If CharIsInSet(S, I, LNeedEscape) Then
     Begin
      LAddQuotes := True;
      Result := Result + '\';
     End
    Else If CharIsInSet(S, I, LNeedQuotes) Then
     LAddQuotes := True;
    Result := Result + S[I];
    If LAddQuotes Then
     Result := '"' + Result + '"';
   End;
 End;
Begin
 Result := '';
 LItems := TStringList.Create;
 Try
  SplitHeaderSubItems(AHeaderLine, LItems, AQuoteType);
  {$IFDEF HAS_TStringList_CaseSensitive}
   LItems.CaseSensitive := False;
  {$ENDIF}
  I := InternalrestdwIndexOfName(LItems, ASubItem);
  If I >= 0 Then
   Begin
    VOld := LItems.Strings[I];
    Fetch(VOld, '=');
   End
  Else
   VOld := '';
  LValue := Trim(AValue);
  If LValue <> '' Then
   Begin
    If I < 0 Then
     LItems.Add(ASubItem + '=' + LValue)
    Else
     LItems.Strings[I] := ASubItem + '=' + LValue;
   End
  Else If I < 0 Then
   Begin
    Result := AHeaderLine;
    Exit;
   End
  Else
   LItems.Delete(I);
  Result := ExtractHeaderItem(AHeaderLine);
  If Result <> '' Then
   Begin
    For I := 0 To LItems.Count -1 Do
     Result := Result + '; ' + LItems.Names[I] + '=' + QuoteString(ValueFromIndex(LItems, I), Boolean(LItems.Objects[I])); {do not localize}
   End;
 Finally
  LItems.Free;
 End;
End;

Function PosInStrArray(Const SearchStr     : String;
                       Const Contents      : Array Of String;
                       Const CaseSensitive : Boolean = True) : Integer;
Begin
 For Result := Low(Contents) To High(Contents) Do
  Begin
   If CaseSensitive Then
    Begin
     If SearchStr = Contents[Result] Then
      Exit;
    End
   Else
    Begin
     If TextIsSame(SearchStr, Contents[Result]) Then
      Exit;
    End;
  End;
 Result := -1;
End;

Function InternalAnsiPos(Const Substr, S : String) : Integer;
Begin
 Result := SysUtils.AnsiPos(Substr, S);
End;

Function iif(ATest        : Boolean;
             Const ATrue  : Integer;
             Const AFalse : Integer) : Integer;
Begin
 If ATest Then Result := ATrue
 Else          Result := AFalse;
End;

Function TextIsSame(Const A1, A2 : String) : Boolean;
Begin
 Result := AnsiCompareText(A1, A2) = 0;
End;

Function CharPosInSet(Const AString  : String;
                      Const ACharPos : Integer;
                      Const ASet     : String) : Integer;
Var
 LChar : Char;
 I     : Integer;
Begin
 Result := 0;
 If ACharPos < 1 Then
  Raise eRESTDWException.Create('Invalid ACharPos');
 If ACharPos <= Length(AString) Then
  Begin
   LChar := AString[ACharPos];
   For I := 1 To Length(ASet) Do
    Begin
     If ASet[I] = LChar Then
      Begin
       Result := I;
       Exit;
      End;
    End;
  End;
End;

Function CharIsInSet(Const AString  : String;
                     Const ACharPos : Integer;
                     Const ASet     : String) : Boolean;
Begin
 Result := CharPosInSet(AString, ACharPos, ASet) > 0;
End;

Function ValueFromIndex(AStrings     : TStrings;
                        Const AIndex : Integer)  : String;
Var
 LTmp : String;
 LPos : Integer;
Begin
 Result := '';
 If AIndex >= 0 Then
  Begin
   LTmp := AStrings.Strings[AIndex];
   LPos := Pos('=', LTmp);
   If LPos > 0 Then
    Begin
     Result := Copy(LTmp, LPos+1, MaxInt);
     Exit;
    End;
 End;
End;

Function ReadLnFromStream(AStream        : TStream;
                          Var VLine      : String;
                          AMaxLineLength : Integer = -1) : Boolean;
Const
 LBUFMAXSIZE = 2048;
Var
 LStringLen,
 LResultLen,
 LBufSize       : Integer;
 LBuf,
 LLine          : TRESTDWBytes;
 LStrmPos,
 LStrmSize      : TRESTDWStreamSize;
 LCrEncountered : Boolean;
 Function FindEOL(Const ABuf         : TRESTDWBytes;
                  Var VLineBufSize   : Integer;
                  Var VCrEncountered : Boolean) : Integer;
 Var
  i : Integer;
 Begin
  Result := VLineBufSize; //EOL not found => use all
  i := 0;
  While i < VLineBufSize Do
   Begin
    Case ABuf[i] Of
     Ord(LF) :
      Begin
       Result         := i;
       VCrEncountered := True;
       VLineBufSize   := i+1;
       Break;
      End;
     Ord(CR) :
      Begin
       Result := i;
       VCrEncountered := True;
       Inc(i);
       If (i < VLineBufSize)  And
          (ABuf[i] = Ord(LF)) Then
        VLineBufSize := i+1
       Else
        VLineBufSize := i;
       Break;
      End;
    End;
    Inc(i);
   End;
 End;
 Function ReadBytes(Const AStream : TStream;
                    Var   VBytes  : TRESTDWBytes;
                    Const ACount,
                    AOffset       : Integer) : Integer;
 Var
  LActual : Integer;
 Begin
  Assert(AStream <> Nil);
  Result := 0;
  If VBytes = Nil Then
   SetLength(VBytes, 0);
  LActual := ACount;
  If LActual < 0 Then
   LActual := AStream.Size - AStream.Position;
  If LActual = 0 Then Exit;
  If restdwLength(VBytes) < (AOffset+LActual) Then
   SetLength(VBytes, AOffset+LActual);
  Assert(VBytes <> nil);
  Result := AStream.Read(VBytes[AOffset], LActual);
 End;
 Procedure CopyRESTDWBytes(Const ASource      : TRESTDWBytes;
                           Const ASourceIndex : Integer;
                           Var VDest          : TRESTDWBytes;
                           Const ADestIndex,
                           ALength            : Integer);
 Begin
  Assert(ASourceIndex >= 0);
  Assert((ASourceIndex+ALength) <= restdwLength(ASource));
  Move  (ASource[ASourceIndex], VDest[ADestIndex], ALength);
 End;
Begin
 Assert(AStream <> Nil);
 VLine := '';
 SetLength(LLine, 0);
 If AMaxLineLength < 0 Then
  AMaxLineLength := MaxInt;
 LStrmPos := AStream.Position;
 LStrmSize := AStream.Size;
 If LStrmPos >= LStrmSize Then
  Begin
   Result := False;
   Exit;
  End;
 SetLength(LBuf, LBUFMAXSIZE);
 LCrEncountered := False;
 Repeat
  LBufSize := ReadBytes(AStream, LBuf, restdwMin(LStrmSize - LStrmPos, LBUFMAXSIZE), 0);
  If LBufSize < 1 Then
   Break;
  LStringLen := FindEOL(LBuf, LBufSize, LCrEncountered);
  Inc(LStrmPos, LBufSize);
  LResultLen := Length(VLine);
  If (LResultLen + LStringLen) > AMaxLineLength Then
   Begin
    LStringLen := AMaxLineLength - LResultLen;
    LCrEncountered := True;
    Dec(LStrmPos, LBufSize);
    Inc(LStrmPos, LStringLen);
   End;
  If LStringLen > 0 Then
   Begin
    LBufSize := restdwLength(LLine);
    SetLength(LLine, LBufSize+LStringLen);
    CopyRESTDWBytes(LBuf, 0, LLine, LBufSize, LStringLen);
   End;
 Until (LStrmPos >= LStrmSize) or LCrEncountered;
 AStream.Position := LStrmPos;
 VLine := BytesToString(LLine, 0, -1);
 Result := True;
End;

Function restdwPos(Const Substr, S : String) : Integer;
Begin
 Result := Pos(Substr, S);
End;

Function restdwMax(Const AValueOne,
                   AValueTwo        : Int64) : Int64;
Begin
 If AValueOne < AValueTwo Then
  Result := AValueTwo
 Else
  Result := AValueOne;
End;

Function restdwLength(Const ABuffer : String;
                      Const ALength : Integer = -1;
                      Const AIndex  : Integer = 1) : Integer;
Var
 LAvailable: Integer;
Begin
 Assert(AIndex >= 1);
 LAvailable := restdwMax(Length(ABuffer)-AIndex+1, 0);
 If ALength < 0 Then
  Result := LAvailable
 Else
  Result := restdwMin(LAvailable, ALength);
End;

Function restdwLength(Const ABuffer : TRESTDWBytes;
                      Const ALength : Integer = -1;
                      Const AIndex  : Integer = 0) : Integer;
                      {$IFDEF USE_INLINE}Inline;{$ENDIF}
Var
 LAvailable : Integer;
Begin
 Assert(AIndex >= 0);
 LAvailable := restdwMax(Length(ABuffer)-AIndex, 0);
 If ALength < 0 Then
  Result := LAvailable
 Else
  Result := restdwMin(LAvailable, ALength);
End;

Function restdwLength(Const ABuffer : TStream;
                      Const ALength : TRESTDWStreamSize = -1): TRESTDWStreamSize;
                      {$IFDEF USE_INLINE}inline;{$ENDIF}
Var
 LAvailable : TRESTDWStreamSize;
Begin
 LAvailable := restdwMax(ABuffer.Size - ABuffer.Position, 0);
 If ALength < 0 Then
  Result := LAvailable
 Else
  Result := restdwMin(LAvailable, ALength);
End;

Function Fetch(Var AInput           : String;
               Const ADelim         : String  = '';
               Const ADelete        : Boolean = True;
               Const ACaseSensitive : Boolean = True) : String;{$IFDEF USE_INLINE}Inline;{$ENDIF}
Var
 LPos : Integer;
 Function FetchCaseInsensitive(Var AInput    : String;
                               Const ADelim  : String;
                               Const ADelete : Boolean) : String;
 Var
  LPos : Integer;
 Begin
  If ADelim = #0 Then
   LPos := Pos(ADelim, AInput)
  Else
   LPos := restdwPos(UpperCase(ADelim), UpperCase(AInput));
  If LPos = 0 Then
   Begin
    Result := AInput;
    if ADelete Then
     AInput := '';
   End
  Else
   Begin
    Result := Copy(AInput, 1, LPos - 1);
    If ADelete Then
     AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
   End;
 End;
Begin
 If ACaseSensitive Then
  Begin
   If ADelim = #0 Then
    LPos := Pos(ADelim, AInput)
   Else
    LPos := restdwPos(ADelim, AInput);
   If LPos = 0 Then
    Begin
     Result := AInput;
     If ADelete Then
      AInput := '';    {Do not Localize}
    End
   Else
    Begin
     Result := Copy(AInput, 1, LPos - 1);
     If ADelete Then
      AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
    End;
  End
 Else
  Result := FetchCaseInsensitive(AInput, ADelim, ADelete);
End;

Function restdwValueFromIndex(AStrings     : TStrings;
                              Const AIndex : Integer) : String;
Begin
 Result := ValueFromIndex(AStrings, AIndex);
End;

Procedure DeleteInvalidChar(Var Value : String);
Begin
 If Length(Value) > 0 Then
  If Value[InitStrPos] <> '{' then
   Delete(Value, 1, 1);
 If Length(Value) > 0 Then
  If Value[Length(Value) - FinalStrPos] <> '{' then
   Delete(Value, Length(Value), 1);
End;

Function StringToBoolean(aValue : String) : Boolean;
Begin
 Result := lowercase(trim(aValue)) = 'true';
End;

Function BooleanToString(aValue : Boolean) : String;
Begin
 If aValue Then
  Result := 'true'
 Else
  Result := 'false';
End;

Function ExtractHeaderSubItem(Const AHeaderLine,
                              ASubItem           : String;
                              QuotingType        : TRESTDWHeaderQuotingType) : String;
Var
 LItems  : TStringList;
 I       : Integer;
Begin
 Result := '';
 LItems := TStringList.Create;
 Try
  SplitHeaderSubItems(AHeaderLine, LItems, QuotingType);
  I := restdwIndexOfName(LItems, ASubItem);
  If I <> -1 Then
   Result := restdwValueFromIndex(LItems, I);
 Finally
  LItems.Free;
 End;
End;

Function ReadLnFromStream(AStream         : TStream;
                          AMaxLineLength  : Integer = -1;
                          AExceptionIfEOF : Boolean = False) : String; overload;
Begin
 If (Not ReadLnFromStream(AStream, Result, AMaxLineLength)) and AExceptionIfEOF then
  Raise Exception.Create(Format(cStreamReadError, ['ReadLnFromStream', AStream.Position]));
end;

Function RemoveBackslashCommands(Value : String) : String;
Begin
 Result := StringReplace(Value, '../', '', [rfReplaceAll]);
 Result := StringReplace(Result, '..\', '', [rfReplaceAll]);
End;

Function TravertalPathFind(Value : String) : Boolean;
Begin
 Result := Pos('../', Value) > 0;
 If Not Result Then
  Result := Pos('..\', Value) > 0;
End;

Function GetEventName  (Value : String) : String;
Begin
 Result := Value;
 If Pos('.', Result) > 0 Then
  Result := Copy(Result, Pos('.', Result) + 1, Length(Result));
End;

Function RESTDWFileExists(sFile, BaseFilePath : String) : Boolean;
Var
 vTempFilename : String;
Begin
 vTempFilename := sFile;
 Result        := (Pos('.', vTempFilename) > 0);
 If Result Then
  Begin
   Result := FileExists(vTempFilename);
   If Not Result Then
    Result := FileExists(BaseFilePath + vTempFilename);
  End;
End;

Procedure CopyStringList(Const Source, Dest : TStringList);
Var
 I : Integer;
Begin
 If Assigned(Source) And Assigned(Dest) Then
  For I := 0 To Source.Count -1 Do
   Dest.Add(Source[I]);
End;

Function HexToBookmark(Value : String) : TRESTDWBytes;
{$IFDEF POSIX} //Android
Var
 bytes: TRESTDWBytes;
{$ENDIF}
begin
 SetLength(Result, 0);
 If Trim(Value) = '' Then
  Exit;
 SetLength(Result, Length(Value) div SizeOf(Char));
 {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
  HexToBin(PWideChar(value), 0, TBytes(Result), 0, restdwLength(Result));
 {$ELSE}
  {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
   HexToBin(PWideChar(value), Result, restdwLength(Result));
  {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    HexToBin(PChar(Value), Result, restdwLength(Result));
   {$ELSE}
    HexToBin(PChar(Value), @Result, restdwLength(Result));
   {$IFEND}
  {$IFEND}
 {$IFEND}
End;

Function BookmarkToHex(Value : TRESTDWBytes) : String;
{$IFDEF POSIX}
Var
 bytes: TBytes;
{$ENDIF}
Begin
 Result := '';
 If restdwLength(Value) > 0 Then
  Begin
   SetLength(Result, restdwLength(Value) * SizeOf(Char));
   {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
    SetLength(bytes, restdwLength(value) div 2);
    HexToBin(PwideChar(value), 0, bytes, 0, restdwLength(bytes));
    Result := TEncoding.UTF8.GetString(bytes);
   {$ELSE}
    {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
     SetLength(bytes, restdwLength(value) div 2);
     HexToBin(PwideChar(value), 0, bytes, 0, Length(bytes));
     Result := TEncoding.UTF8.GetString(bytes);
    {$ELSE}
     BinToHex(PAnsiChar(Value), PChar(Result), restdwLength(Value));
    {$IFEND}
   {$IFEND}
  End;
End;

Function Unescape_chars(s : String) : String;
 Function HexValue(C: Char): Byte;
 Begin
  Case C of
   '0'..'9':  Result := Byte(C) - Byte('0');
   'a'..'f':  Result := (Byte(C) - Byte('a')) + 10;
   'A'..'F':  Result := (Byte(C) - Byte('A')) + 10;
   Else raise Exception.Create('Illegal hexadecimal characters "' + C + '"');
  End;
 End;
Var
 C    : Char;
 I,
 ubuf : Integer;
Begin
 Result := '';
 I := InitStrPos;
 While I <= (Length(S) - FinalStrPos) Do
  Begin
   C := S[I];
   Inc(I);
   If C = '\' then
    Begin
     C := S[I];
     Inc(I);
     Case C of
      'b': Result := Result + #8;
      't': Result := Result + #9;
      'n': Result := Result + #10;
      'f': Result := Result + #12;
      'r': Result := Result + #13;
      'u': Begin
            If Not TryStrToInt('$' + Copy(S, I, 4), ubuf) Then
             Raise Exception.Create(format('Invalid unicode \u%s',[Copy(S, I, 4)]));
            Result := result + WideChar(ubuf);
            Inc(I, 4);
           End;
       Else Result := Result + C;
     End;
    End
   Else Result := Result + C;
  End;
End;

Function Escape_chars(s : String) : String;
Var
 b, c   : Char;
 i, len : Integer;
 sb, t  : String;
 Const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')', ' '];
 Function toHexString(c : char) : String;
 Begin
  Result := IntToHex(ord(c), 2);
 End;
Begin
 c      := #0;
 {$IFDEF FPC}
 b      := #0;
 i      := 0;
 {$ENDIF}
 len    := length(s);
 Result := '';
  //SetLength (s, len+4);
 t      := '';
 sb     := '';
 For  i := InitStrPos to len - FinalStrPos Do
  Begin
   b := c;
   c := s[i];
   Case (c) Of
    '\', '"' : Begin
                sb := sb + '\';
                sb := sb + c;
               End;
    '/' :      Begin
                If (b = '<') Then
                 sb := sb + '\';
                sb := sb + c;
               End;
    #8  :      Begin
                sb := sb + '\b';
               End;
    #9  :      Begin
                sb := sb + '\t';
               End;
    #10 :      Begin
                sb := sb + '\n';
               End;
    #12 :      Begin
                sb := sb + '\f';
               End;
    #13 :      Begin
                sb := sb + '\r';
               End;
    Else       Begin
                If (Not (c in NoConversion)) Then
                 Begin
                    t := '000' + toHexString(c);
                    sb := sb + '\u' + copy (t, Length(t) -3,4);
                 End
                Else
                 sb := sb + c;
               End;
   End;
  End;
 Result := sb;
End;

Function GetFieldTypeB(FieldType : String) : TFieldType;
Var
 vFieldType : String;
Begin
 Result     := ftString;
 vFieldType := Uppercase(FieldType);
 If vFieldType      = Uppercase('ftUnknown')         Then
  Result := ftUnknown
 Else If vFieldType = Uppercase('ftString')          Then
  Result := ftString
 Else If vFieldType = Uppercase('ftSmallint')        Then
  Result := ftSmallint
 Else If vFieldType = Uppercase('ftInteger')         Then
  Result := ftInteger
 Else If vFieldType = Uppercase('ftWord')            Then
  Result := ftWord
 Else If vFieldType = Uppercase('ftBoolean')         Then
  Result := ftBoolean
 Else If vFieldType = Uppercase('ftFloat')           Then
  Result := ftFloat
 Else If vFieldType = Uppercase('ftCurrency')        Then
  Result := ftCurrency
 Else If vFieldType = Uppercase('ftBCD')             Then
  Result := ftFloat
 Else If vFieldType = Uppercase('ftDate')            Then
  Result := ftDate
 Else If vFieldType = Uppercase('ftTime')            Then
  Result := ftTime
 Else If vFieldType = Uppercase('ftDateTime')        Then
  Result := ftDateTime
 Else If vFieldType = Uppercase('ftBytes')           Then
  Result := ftBytes
 Else If vFieldType = Uppercase('ftVarBytes')        Then
  Result := ftVarBytes
 Else If vFieldType = Uppercase('ftAutoInc')         Then
  Result := ftAutoInc
 Else If vFieldType = Uppercase('ftBlob')            Then
  Result := ftBlob
 Else If vFieldType = Uppercase('ftMemo')            Then
  Result := ftMemo
{$IFNDEF FPC}
 {$if CompilerVersion < 21} // delphi 7   compatibilidade enter Sever no XE e Client no D7
 Else If vFieldType = Uppercase('ftWideMemo')        Then
  Result := ftMemo
{$IFEND}
{$ENDIF}
 Else If vFieldType = Uppercase('ftGraphic')         Then
  Result := ftGraphic
 Else If vFieldType = Uppercase('ftFmtMemo')         Then
  Result := ftFmtMemo
 Else If vFieldType = Uppercase('ftParadoxOle')      Then
  Result := ftParadoxOle
 Else If vFieldType = Uppercase('ftDBaseOle')        Then
  Result := ftDBaseOle
 Else If vFieldType = Uppercase('ftTypedBinary')     Then
  Result := ftTypedBinary
 Else If vFieldType = Uppercase('ftCursor')          Then
  Result := ftCursor
 Else If vFieldType = Uppercase('ftFixedChar')       Then
  Result := ftFixedChar
 Else If vFieldType = Uppercase('ftWideString')      Then
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := ftWideString
   {$ELSE}
    Result := ftString
   {$IFEND}
  {$ELSE}
   Result := ftString
  {$ENDIF}
 Else If vFieldType = Uppercase('ftLargeint')        Then
  Result := ftLargeint
 Else If vFieldType = Uppercase('ftADT')             Then
  Result := ftADT
 Else If vFieldType = Uppercase('ftArray')           Then
  Result := ftArray
 Else If vFieldType = Uppercase('ftReference')       Then
  Result := ftReference
 Else If vFieldType = Uppercase('ftDataSet')         Then
  Result := ftDataSet
 Else If vFieldType = Uppercase('ftOraBlob')         Then
  Result := ftOraBlob
 Else If vFieldType = Uppercase('ftOraClob')         Then
  Result := ftOraClob
 Else If vFieldType = Uppercase('ftVariant')         Then
  Result := ftVariant
 Else If vFieldType = Uppercase('ftInterface')       Then
  Result := ftInterface
 Else If vFieldType = Uppercase('ftIDispatch')       Then
  Result := ftIDispatch
 Else If vFieldType = Uppercase('ftGuid')            Then
  Result := ftGuid
 Else If vFieldType = Uppercase('ftTimeStamp')       Then
  Begin
  {$IFNDEF FPC}
   Result := ftTimeStamp;
  {$ELSE}
   Result := ftDateTime;
  {$ENDIF}
  End
 Else If vFieldType = Uppercase('ftSingle')       Then
  Begin
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := ftSingle;
   {$ELSE}
    Result := ftFloat;
   {$IFEND}
  {$ELSE}
   Result := ftFloat;
  {$ENDIF}
  End
 Else If vFieldType = Uppercase('ftFMTBcd')          Then
   Result := ftFloat
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
    Else If vFieldType = Uppercase('ftFixedWideChar')   Then
     Result := ftFixedWideChar
    Else If vFieldType = Uppercase('ftWideMemo')        Then
     Result := ftWideMemo
    Else If vFieldType = Uppercase('ftOraTimeStamp')    Then
     Result := ftOraTimeStamp
    Else If vFieldType = Uppercase('ftOraInterval')     Then
     Result := ftOraInterval
    Else If vFieldType = Uppercase('ftLongWord')        Then
     Result := ftLongWord
    Else If vFieldType = Uppercase('ftShortint')        Then
     Result := ftShortint
    Else If vFieldType = Uppercase('ftByte')            Then
     Result := ftByte
    Else If vFieldType = Uppercase('ftExtended')        Then
     Result := ftFloat
    Else If vFieldType = Uppercase('ftConnection')      Then
     Result := ftConnection
    Else If vFieldType = Uppercase('ftParams')          Then
     Result := ftParams
    Else If vFieldType = Uppercase('ftStream')          Then
     Result := ftStream
    Else If vFieldType = Uppercase('ftTimeStampOffset') Then
     Result := ftTimeStampOffset
    Else If vFieldType = Uppercase('ftObject')          Then
     Result := ftObject
   {$IFEND}
  (* {$if CompilerVersion =15}
   Else If vFieldType = Uppercase('ftWideMemo')   Then
     Result := ftMemo
   {$IFEND}
   *)
   {$ENDIF};
End;

Function StringToFieldType(Const S : String): Integer;
Begin
 If not IdentToInt(S, Result, FieldTypeIdents) then
  Result := Integer(GetFieldTypeB(S))
 Else
  Result := Integer(GetFieldTypeB(S));
 If TFieldType(Result) = ftWideString Then
  Result := Integer(ftString);
End;

Function StreamToBytes(Stream : TMemoryStream) : TRESTDWBytes;
Begin
 Try
  Stream.Position := 0;
  SetLength  (Result, Stream.Size);
  Stream.Read(Result[0], Stream.Size);
 Finally
 End;
end;

Function StringToBytes(AStr : String): TRESTDWBytes;
begin
 SetLength(Result, 0);
 If AStr <> '' Then
  Begin
   {$IF Defined(HAS_UTF8)}
    Result := TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
   {$ELSE}
    {$IFDEF FPC}
     Result := TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
    {$ELSE}
     {$IF CompilerVersion < 25}
      Move(Pointer(@AStr[InitStrPos])^, Result, Length(AStr));
     {$ELSE}
      Result :=  TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
     {$IFEND}
    {$ENDIF}
   {$IFEND}
  End;
end;

Function BytesToString(Const AValue      : TRESTDWBytes;
                       Const AStartIndex : Integer;
                       Const ALength: Integer = -1)      : String;
Var
 LLength : Integer;
 LBytes  : TRESTDWBytes;
Begin
 Result := '';
 {$IFDEF STRING_IS_ANSI}
  LBytes := nil; // keep the compiler happy
 {$ENDIF}
 LLength := restdwLength(AValue, ALength, AStartIndex);
 If LLength > 0 Then
  Begin
   If (AStartIndex = 0)          And
      (LLength = restdwLength(AValue)) Then
    LBytes := AValue
   Else
    LBytes := Copy(AValue, AStartIndex, LLength);
   SetString(Result, PAnsiChar(LBytes), restdwLength(LBytes));
  End;
End;

Function BytesToString(Const bin : TRESTDWBytes) : String;
Var
 I : Integer;
Begin
//Const HexSymbols = '0123456789ABCDEF';
//Var
// i,
// vSize : Integer;
//Begin
// vSize := restdwLength(bin);
// SetLength(Result, 2 * vSize);
// For i :=  0 To vSize-1 Do
//  Begin
//   Result[1 + 2*i + 0] := HexSymbols[1 + bin[i] shr 4];
//   Result[1 + 2*i + 1] := HexSymbols[1 + bin[i] and $0F];
//  End;
//End;
// Move(bin[0], Result, Length(bin));
 I := restdwLength(bin);
 If I > 0 Then
  SetString(Result, PAnsiChar(bin), I);
End;

Function EncodeStream (Value : TStream) : String;
Var
 outstream : TStringStream;
Begin
 Result         := '';
 Value.Position := 0;
 If Value.Size > 0 Then
  Begin
   outstream := TStringStream.Create('');
   Try
    outstream.CopyFrom(Value, Value.Size);
    outstream.Position := 0;
    Result := EncodeStrings(outstream.Datastring{$IFDEF FPC}, csUndefined{$ENDIF});
   Finally
    FreeAndNil(outstream);
   End;
  End;
 Value.Position := 0;
End;

Function DecodeStream(Value : String) : TMemoryStream;
Var
 outstream : TStringStream;
Begin
 Result := TMemoryStream.Create;
 outstream := TStringStream.Create(DecodeStrings(Value{$IFDEF FPC}, csUndefined{$ENDIF}));
 Try
  outstream.Position := 0;
  Result.CopyFrom(outstream, outstream.Size);
  Result.Position := 0;
 Finally
  FreeAndNil(outstream);
 End;
End;

Function Base64Decode(const AInput : String) : TRESTDWBytes;
Begin
 Result := TRESTDWBase64.Decode(ToBytes(AInput));
End;

Function Decode64(const S: string): string;
Var
 sa : String;
{$IF Defined(RESTDWFMX)}
 ne : TBase64Encoding;
{$IFEND}
Begin
 {$IFDEF FPC}
  Result := DecodeStringBase64(S);
 {$ELSE}
  {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
   //Result := TNetEncoding.Base64.Decode(S);//UTF8Decode(TIdDecoderMIME.DecodeString(S, IndyTextEncoding_utf8));
   ne := TBase64Encoding.Create(-1);
   Result := ne.Decode(S);
   ne.Free;
  {$ELSE}
   SA := S;
   If Pos(sLineBreak, SA) > 0 Then
    SA := StringReplace(SA, sLineBreak, '', [rfReplaceAll]);
   Result := BytesToString(Base64Decode(SA));
  {$IFEND}
 {$ENDIF}
End;

{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Function DecodeBase64(Const Value : String) : String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
  Function  DecodeBase64 (Const Value : String)             : String;
{$ELSE}
  Function DecodeBase64(Const Value : String
                       {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
  {$IFEND}
{$IFEND}
Var
 vValue : String;
Begin
 vValue := Decode64(Value);
 {$IFDEF FPC}
 Case DatabaseCharSet Of
   csWin1250    : vValue := CP1250ToUTF8(vValue);
   csWin1251    : vValue := CP1251ToUTF8(vValue);
   csWin1252    : vValue := CP1252ToUTF8(vValue);
   csWin1253    : vValue := CP1253ToUTF8(vValue);
   csWin1254    : vValue := CP1254ToUTF8(vValue);
   csWin1255    : vValue := CP1255ToUTF8(vValue);
   csWin1256    : vValue := CP1256ToUTF8(vValue);
   csWin1257    : vValue := CP1257ToUTF8(vValue);
   csWin1258    : vValue := CP1258ToUTF8(vValue);
   csUTF8       : vValue := UTF8ToUTF8BOM(vValue);
   csISO_8859_1 : vValue := ISO_8859_1ToUTF8(vValue);
   csISO_8859_2 : vValue := ISO_8859_2ToUTF8(vValue);
 End;
 {$ENDIF}
 Result := vValue;
End;

Function Base64Encode(Const S : String): String;
 Function Encode_Byte(b: Byte): char;
 Const
  Base64Code: String[64] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
 Begin
  Result := Char(Base64Code[(b and $3F)+1]);
 End;
var
  i: Integer;
Begin
 i := 1;
 Result := '';
 While i <= Length(S) do
  Begin
   Result := Result + Encode_Byte(Byte(S[i]) shr 2);
   Result := Result + Encode_Byte((Byte(S[i]) shl 4) or (Byte(S[i+1]) shr 4));
   If i+1 <= Length(S) Then
    Result := Result + Encode_Byte((Byte(S[i+1]) shl 2) or (Byte(S[i+2]) shr 6))
   Else
    Result := Result + '=';
   If i+2 <= Length(S) Then
    Result := Result + Encode_Byte(Byte(S[i+2]))
   Else
    Result := Result + '=';
   Inc(i, 3);
  End;
End;

{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Function EncodeBase64(Const Value : String) : String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
Function EncodeBase64(Const Value : String) : String;
{$ELSE}
  Function EncodeBase64(Const Value : String
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
{$IFEND}
{$IFEND}
Var
 vValue : String;
Begin
 vValue := Value;
 {$IFDEF FPC}
 Case DatabaseCharSet Of
   csWin1250    : vValue := CP1250ToUTF8(vValue);
   csWin1251    : vValue := CP1251ToUTF8(vValue);
   csWin1252    : vValue := CP1252ToUTF8(vValue);
   csWin1253    : vValue := CP1253ToUTF8(vValue);
   csWin1254    : vValue := CP1254ToUTF8(vValue);
   csWin1255    : vValue := CP1255ToUTF8(vValue);
   csWin1256    : vValue := CP1256ToUTF8(vValue);
   csWin1257    : vValue := CP1257ToUTF8(vValue);
   csWin1258    : vValue := CP1258ToUTF8(vValue);
   csUTF8       : vValue := UTF8ToUTF8BOM(vValue);
   csISO_8859_1 : vValue := ISO_8859_1ToUTF8(vValue);
   csISO_8859_2 : vValue := ISO_8859_2ToUTF8(vValue);
 End;
 {$ENDIF}
 Result := Base64Encode(vValue);
End;

Function EncodeStrings(Value : String
                      {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
Begin
 Result := '';
 If Value = '' Then
  Exit;
{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
 Result := Encode64(Value); //TIdencoderMIME.EncodeString(Value, nil);
{$ELSE}
 Result := EncodeBase64(Value{$IFDEF FPC}, DatabaseCharSet{$ENDIF});
{$IFEND}
End;

Function DecodeStrings(Value : String
                       {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
Begin
 {$IFDEF FPC}
  Result := DecodeBase64(Value, DatabaseCharSet);
 {$ELSE}
 {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
  Result := Decode64(Value); //TIdencoderMIME.EncodeString(Value, nil);
 {$ELSE}
  Result := DecodeBase64(Value);
  {$IFEND}
 {$ENDIF}
End;

Function WrapText(Const ALine,
                  ABreakStr,
                  ABreakChars  : String;
                  MaxCol       : Integer) : String;
Const
 QuoteChars     = '"';
Var
 LCol,
 LPos,
 LLinePos,
 LLineLen,
 LBreakLen,
 LBreakPos      : Integer;
 LQuoteChar,
 LCurChar       : Char;
 LExistingBreak : Boolean;
Begin
 LCol           := 1;
 LPos           := 1;
 LLinePos       := 1;
 LBreakPos      := 0;
 LQuoteChar     := ' ';
 LExistingBreak := False;
 LLineLen       := Length(ALine);
 LBreakLen      := Length(ABreakStr);
 Result         := '';
 While LPos <= LLineLen Do
  Begin
   LCurChar := ALine[LPos];
   {$IFDEF STRING_IS_ANSI}
   If IsLeadChar(LCurChar) Then
    Begin
     Inc(LPos);
     Inc(LCol);
    End
   Else
    Begin
    {$ENDIF}
     If LCurChar = ABreakStr[1] Then
      Begin
       If LQuoteChar = ' ' Then
        Begin   {Do not Localize}
         LExistingBreak := TextIsSame(ABreakStr, Copy(ALine, LPos, LBreakLen));
         If LExistingBreak Then
          Begin
           Inc(LPos, LBreakLen-1);
           LBreakPos := LPos;
          End;
        End
      End
     Else
      Begin
       If CharIsInSet(LCurChar, 1, ABreakChars) Then
        Begin
         If LQuoteChar = ' ' Then
          LBreakPos := LPos;
        End
       Else
        Begin // if CurChar in BreakChars then
         If CharIsInSet(LCurChar, 1, QuoteChars) Then
          Begin
           If LCurChar = LQuoteChar Then
            LQuoteChar := ' '
           Else
            Begin
             If LQuoteChar = ' ' Then
              LQuoteChar := LCurChar;
            End;
          End;
        End;
      End;
    {$IFDEF STRING_IS_ANSI}
    End;
    {$ENDIF}
    Inc(LPos);
    Inc(LCol);
    If Not (CharIsInSet(LQuoteChar, 1, QuoteChars)) And
           (LExistingBreak Or ((LCol > MaxCol)      And
           (LBreakPos > LLinePos)))                 Then
     Begin
      LCol := LPos - LBreakPos;
      Result := Result + Copy(ALine, LLinePos, LBreakPos - LLinePos + 1);
      If Not (CharIsInSet(LCurChar, 1, QuoteChars)) Then
       Begin
        While (LPos <= LLineLen) And
              (CharIsInSet(ALine, LPos, ABreakChars + #13+#10)) Do
         Inc(LPos);
        If Not LExistingBreak    And
          (LPos < LLineLen)      Then
         Result := Result + ABreakStr;
       End;
      Inc(LBreakPos);
      LLinePos := LBreakPos;
      LExistingBreak := False;
     End;
  End;
 Result := Result + Copy(ALine, LLinePos, MaxInt);
End;

End.
