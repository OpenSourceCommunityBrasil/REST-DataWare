Unit uDWConsts;

{$I uRESTDW.inc}

Interface

Uses
 uDWConstsCharset, DWDCPcrypt2, DWDCPrijndael, DWDCPsha256, ZLib, //DWDCPtypes,
 {$IFDEF FPC}
  zstream,
  {$IFNDEF LAMW}
   LCL,
  {$ENDIF}
  SysUtils,  DB, Classes, IdGlobal, IdCoderMIME, IdGlobalProtocols, IdMessageCoderMIME, uZlibLaz, base64;
 {$ELSE}
  IdGlobal,  IdCoderMIME, IdGlobalProtocols, IdMessageCoderMIME,
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   System.SysUtils, uZlibLaz, EncdDecd,
   {$IFDEF POSIX}
    Posix.Unistd,
   {$ENDIF}
   Data.DB,  System.Classes;
  {$ELSE}
   SysUtils, uZlibLaz, EncdDecd,
   DB,       Classes;
  {$IFEND}
 {$ENDIF}

Var
 InitStrPos,
 FinalStrPos               : Integer;

Const
 tScriptsDetected          : Array[0..1] of string = ('.map', '.webdwpc');
 cCompressionLevel         = clFastest;
 TDecimalChar              = 'D';
 TNullString               = #0;
 TTagParams                = '<#%s#>';
 TSepParams                = '|xxx|xxx|%';
 TFormdataParamName        = 'content-disposition: form-data; name';
 TValueFormatJSON          = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":[%s]}';
 TDatasetRequestJSON       = '{"SQL":"%s", "PARAMS":"%s", "BinaryRequest":%s, "Metadata":%s, "BinaryCompatibleMode":%s}';
 TMassiveFormatJSON        = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":[%s], ' +
                             '"reflectionchanges":"%s", "sequencename":"%s", "sequencefield":"%s", "mycomptag":"%s", ' +
                             '"mastercomptag":"%s", "mastercompfields":"%s"}';
 TValueDisp                = '{"PARAMS":[%s], "RESULT":[%s]}';
 TValueArrayJSON           = '[%s]';
 TValueFormatJSONValueS    = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s"}';
 TValueFormatJSONValue     = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":%s}';
 TJsonDatasetHeader        = '{"Field":"%s", "Type":"%s", "Primary":"%s", "Required":"%s", "Size":%d, "Precision":%d, "ReadOnly":"%s", "Autogeneration":"%s"}';
 TJsonValueFormat          = '%s';
 TJsonStringValue          = '"%s"';
 cNullvalue                = 'null';
 cTablenameTAG             = 'TABLENAME';
 cUndefined                = 'undefined';
 cRDWDetailField           = 'rdwdetailfield';
 cNullvalueTag             = '"null"';
 cBlanckStringJSON         = '""';
 TSepValueMemString        = '\\';
 TQuotedValueMemString     = '\"';
 TReplyOK                  = '{"MESSAGE":"OK",  "RESULT":"OK"}';
 TReplyNOK                 = '{"MESSAGE":"NOK", "RESULT":"NOK"}';
 TReplyTagError            = '{"MESSAGE":"NOK", "RESULT":"Invalid Access tag..."}';
 TReplyInvalidPooler       = '{"MESSAGE":"NOK", "RESULT":"Invalid Pooler Name..."}';
 TReplyInvalidWelcome      = '{"MESSAGE":"NOK", "RESULT":"Invalid welcomemessage..."}';
 TReplyError               = '{"MESSAGE":"NOK", "RESULT":"%s"}';
 TServerStatusHTML         = '<!DOCTYPE html><html><head><meta charset="UTF-8"/>' +
                             '<title>REST Dataware - CORE</title></head><body>'   +
                             '<h1>REST Dataware - CORE</h1>'                      +
                             '<h2>Server Status - Online</h2></body></html>';
 TServerStatusSynHTML      = '<!DOCTYPE html><html><head><meta charset="UTF-8"/>' +
                             '<title>REST Dataware - CORE - Synopse</title></head><body>'   +
                             '<h1>REST Dataware - CORE</h1>'                      +
                             '<h2>Server Status - Online</h2></body></html>';
 TServerStatusHTMLQX       = '<!DOCTYPE html><html><head><meta charset="UTF-8"/>' +
                             '<title>REST Dataware - CORE - QuickX</title></head><body>'   +
                             '<h1>REST Dataware - CORE</h1>'                      +
                             '<h2>Server Status - Online</h2></body></html>';
 AuthRealm                 = 'WWW-Authenticate: %s realm="%s", %s charset="UTF-8"';
 UrlBase                   = '%s://%s:%d/%s';
 UrlBaseA                  = '%s://%s:%d/%s%s';
 UrlBaseB                  = '%s://%s:%d/%s%s%s';
 ByteBuffer                = 1024 * 8; //8kb
 CompressBuffer            = 1024 * 2;
 UnixDate                  = 0;      {Date1900}
 SecondsInDay              = 86400;  {Number of seconds in a day}
 SecondsInHour             = 3600;   {Number of seconds in an hour}
 SecondsInMinute           = 60;     {Number of seconds in a minute}
 HoursInDay                = 24;     {Number of hours in a day}
 MinutesInHour             = 60;     {Number of minutes in an hour}
 MinutesInDay              = 1440;   {Number of minutes in a day}
 AssyncCommandMSG          = '{"status":"OK", "assyncmsg":"AssyncCommand Executed"}';
 DWDialogoTitulo           = 'DW REST DataWare Components';
 DWSobreTitulo             = 'DW VCL';
 DWSobreDescricao          = 'DW VCL http://www.restdw.com.br/' + sLineBreak +
                             'Components REST DataWare Core' + sLineBreak +
                             'CORE Version';
 DWSobreLicencaStatus      = 'Open Source - Free Version';
 DWVersionINFO             = '1.4.3.';
 DWRelease                 = '2850';
 DwParamsHeaderVersion     = 6;
 DWCodeProject             = 'Cadillacs and Dinosaurs';
 DWVersao                  = DWVersionINFO + DWRelease + '(' + DWCodeProject + ')';
 DWFieldBookmark           = 'DWFIELDBOOKMARK';
 rsLazarusDWPackage        = 'REST Dataware - Tools';
 rsDwRequestDBGName        = 'REST Dataware - Request Debbuger';
 cValueKey                 = '{"serverinforequest":"%s", "inforequest":"%s", "lifecycle":"%s"}';
 cValueKeyToken            = '{"secrets":"%s", "md5":"%s"}';
 cValueToken               = '{%s"exp":"%s", "iat":"%s", "secrets":"%s"}';
 cValueTokenNoLife         = '{%s"iat":"%s", "secrets":"%s"}';
 cTokenStringRDWTS         = '{"token":"%s"}';
 cInvalidBinaryRequest     = 'Invalid Binary Request. Resource unsupported. %s';
 cInvalidEvent             = 'Invalid Event Name';
 cInvalidContextName       = 'Invalid Context Name';
 cInvalidCustomFieldName   = 'Invalid Custom Field Name';
 cInvalidFieldName         = 'Invalid Field Name';
 cInvalidParamName         = 'Invalid Param Name';
 cInvalidDWParam           = 'Invalid DWParam';
 cInvalidDWParams          = 'Invalid DWParams';
 cInvalidPoolerName        = 'Invalid Pooler Name...';
 cInvalidContextRule       = 'Invalid ContextRule Name';
 cServerEventNotFound      = 'ServerEvent not found...';
 cInvalidServerEventName   = 'Invalid ServerEvent name';
 cInvalidDriverConnection  = 'CustomConnection undefined on server driver selected';
 cInvalidRDWServer         = 'Invalid REST Dataware Server...';
 cInvalidConnectionName    = 'Invalid ConnectionName';
 cPoolerNotFound           = 'Pooler not found';
 cRequestRejectedMethods   = 'Request rejected. Acceptable HTTP methods: ';
 cRequestAcceptableMethods = 'Acceptable HTTP methods not defined on server';
 cRequestRejected          = 'The Requested URL was Rejected';
 cInvalidRequest           = 'Invalid request url.';
 cNotWorkYet               = 'It doesn''''t work yet';
 cAuthenticationError      = 'Error : ' + #13 + 'Authentication Error...';
 cInvalidConnection        = 'Invalid connection. The server maybe offline...';
 cInvalidDataToApply       = 'No data to "Applyupdates"...';
 cEmptyDBName              = 'Empty Database Property';
 cErrorDatabaseNotFound    = 'Database not found...';
 cErrorOpenDataset         = 'Error when try open Dataset...';
 cErrorNoFieldsDataset     = 'No Fields to add on Dataset...';
 cExprIncorrect            = 'Incorrectly formed filter expression';
 cExprExpected             = 'Expression expected but %s found';
 cInvalidBufferPosition    = 'Invalid Buffer Position';
 cFieldNotFound            = 'Field ''%s'' not found';
 cInvalidStream            = 'Invalid Stream...';
 cCannotWriteBuffer        = 'Cannot Write Buffer';
 cCannotReadBuffer         = 'Cannot Read Buffer';
 cCreatedToken             = '201 Created';
 cEventNotFound            = 'HTTP/1.1 404 Url Not Found';
 cInvalidAuth              = 'HTTP/1.1 401 Unauthorized';
 cInvalidInternalError     = 'Internal Server Error';
 cInvalidMessageTo         = 'Invalid Sendmessage %s to user %s, error %s';
 cWelcomeUser              = 'Welcome user %s';
 cUserAgent                = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36';
 cParamDetails             = '%s|%s|%d|%d';
 cParamsCount              = 1;
 cServerStream             = 'SERVERSTREAM';
 cUserStream               = 'USERSTREAM';
 cConnectionRename         = 'CONNECTIONRENAME';
 cServerMessage            = 'SERVERMESSAGE';
 cUserMessage              = 'USERMESSAGE';
 cPing                     = 'PING';
 cPong                     = 'PONG';
 cQuit                     = 'QUIT';
 cApplicationJSON          = 'application/json';

 Type
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Defined(HAS_UTF8)}
    TDWString = String;
   {$ELSE}
    TDWString = AnsiString;
   {$IFEND}
  {$ELSE}
   TDWString = AnsiString;
  {$IFEND}
 {$ELSE}
  TDWString = AnsiString;
 {$ENDIF}

Type
 TRESTDWUriOptions     = Class
 Private
  vBaseServer,
  vDataUrl,
  vServerEvent,
  vEventName           : String;
  Procedure SetEventName  (Value : String);
  Procedure SetServerEvent(Value : String);
  Procedure SetBaseServer (Value : String);
  Procedure SetDataUrl    (Value : String);
 Public
  Constructor Create;
  Property BaseServer  : String Read vBaseServer  Write SetBaseServer;
  Property DataUrl     : String Read vDataUrl     Write SetDataUrl;
  Property ServerEvent : String Read vServerEvent Write SetServerEvent;
  Property EventName   : String Read vEventName   Write SetEventName;
End;

Type
 TCripto = Class(TPersistent)
 Private
  vKeyString : String;
  vUseCripto : Boolean;
 Public
  Constructor Create; //Cria o Componente
  Destructor  Destroy; Override;//Destroy a Classe
  Procedure   Assign(Source : TPersistent); Override;
  Function    Encrypt(Value : String) : String;
  Function    Decrypt(Value : String) : String;
 Published
  Property Use : Boolean Read vUseCripto Write vUseCripto;
  Property Key : String  Read vKeyString Write vKeyString;
End;

Type
 TDWRoute         = (crAll, crGet, crPost, crPut, crPatch, crDelete);
 TDWRoutes        = Set of TDWRoute;
 TRequestType     = (rtGet, rtPost, rtPut, rtPatch, rtDelete);
 TResquestMode    = (rtOnlyFields, rtOnlyData, rtJSONAll);
 TJsonMode        = (jmDataware,  jmPureJSON, jmUndefined);
 TMassiveMode     = (mmInactive,  mmBrowse, mmInsert, mmUpdate, mmDelete, mmExec);
 TMassiveSQLMode  = (msqlQuery,   msqlExecute);
 TTypeObject      = (toDataset,   toParam, toMassive,
                     toVariable,  toObject);
 TObjectValue     = (ovUnknown,         ovString,       ovSmallint,         ovInteger,    ovWord,                            // 0..4
                     ovBoolean,         ovFloat,        ovCurrency,         ovBCD,        ovDate,      ovTime,    ovDateTime,// 5..11
                     ovBytes,           ovVarBytes,     ovAutoInc,          ovBlob,       ovMemo,      ovGraphic, ovFmtMemo, //12..18
                     ovParadoxOle,      ovDBaseOle,     ovTypedBinary,      ovCursor,     ovFixedChar, ovWideString,         //19..24
                     ovLargeint,        ovADT, ovArray, ovReference,        ovDataSet,    ovOraBlob,   ovOraClob,            //25..31
                     ovVariant,         ovInterface,    ovIDispatch,        ovGuid,       ovTimeStamp, ovFMTBcd,             //32..37
                     ovFixedWideChar,   ovWideMemo,     ovOraTimeStamp,     ovOraInterval,                                   //38..41
                     ovLongWord,        ovShortint,     ovByte, ovExtended, ovConnection, ovParams,    ovStream,             //42..48
                     ovTimeStampOffset, ovObject,       ovSingle);                                                           //49..51
 TDatasetType     = (dtReflection,      dtFull,         dtDiff);
 {$IFNDEF FPC}
 {$if CompilerVersion > 24}
 Function  GetEncoding              (Avalue             : TEncodeSelect)             : TEncoding;    Overload;
 {$IFEND}
 {$ENDIF}
 Function  GetEncodingID            (Avalue             : TEncodeSelect)             : {$IFNDEF FPC}
                                                                                        {$IF (DEFINED(OLDINDY))}
                                                                                         TIdTextEncoding
                                                                                        {$ELSE}
                                                                                         IIdTextEncoding
                                                                                        {$IFEND}
                                                                                       {$ELSE}
                                                                                        IIdTextEncoding
                                                                                       {$ENDIF};     Overload;
 Function  GetObjectName            (TypeObject         : TTypeObject)            : String;          Overload;
 Function  GetJSONModeName          (TypeObject         : TJsonMode)              : String;          Overload;
 Function  GetJSONModeName          (TypeObject         : String)                 : TJsonMode;       Overload;
 Function  GetObjectName            (TypeObject         : String)                 : TTypeObject;     Overload;
 Function  GetDirectionName         (ObjectDirection    : TObjectDirection)       : String;          Overload;
 Function  GetDirectionName         (ObjectDirection    : String)                 : TObjectDirection;Overload;
 Function  GetBooleanFromString     (Value              : String)                 : Boolean;
 Function  GetStringFromBoolean     (Value              : Boolean)                : String;
 Function  GetValueType             (ObjectValue        : TObjectValue)           : String;          Overload;
 Function  GetValueType             (ObjectValue        : String)                 : TObjectValue;    Overload;
 // criando em 18/02/2020 - Ico Menezes
 Function  GetValueTypeTranslator   (ObjectValue        : String)                 : TObjectValue;
 Function  GetFieldType             (FieldType          : TFieldType)             : String;          Overload;
 Function  GetFieldType             (FieldType          : String)                 : TFieldType;      Overload;
 Function  GetFieldTypeB            (FieldType          : TFieldType)             : String;
 Function  StringToBoolean          (aValue             : String)                 : Boolean;
 Function  BooleanToString          (aValue             : Boolean)                : String;
 Function  StringFloat              (aValue             : String)                 : String;
 Function  MassiveSQLMode           (aValue             : TMassiveSQLMode)        : String;          Overload;
 Function  MassiveSQLMode           (aValue             : String)                 : TMassiveSQLMode; Overload;
 Function  GenerateStringFromStream (Stream             : TStream
                                    {$IFNDEF FPC}{$if CompilerVersion > 21};
                                     AEncoding          : TEncoding{$IFEND}{$ENDIF}) : String;Overload;
 Function  FileToStr                (Const FileName     : String) : String;
 Procedure StrToFile                (Const FileName,
                                     SourceString       : String);
 Function  StreamToHex              (Stream             : TStream;
                                     QQuoted            : Boolean = True)         : String;
 Function  PCharToHex               (Data               : PChar;
                                     Size               : Integer;
                                     QQuoted            : Boolean = True)         : String;
 Procedure HexToPChar               (HexString          : String;
                                     Var Data           : PChar);
 Procedure HexToStream              (Str                : String;
                                     Stream             : TStream);
 Function  StreamToBytes            (Stream             : TMemoryStream)          : tidBytes;
 Procedure CopyStream               (Const Source       : TStream;
                                     Dest               : TStream);
 Function  ZDecompressStreamNew     (Const S            : TStream)                : TStringStream;
 Function  ZDecompressStr           (Const S            : String;
                                     Var Value          : String)                 : Boolean;
 Function  ZDecompressStreamD       (Const S            : TStringStream;
                                     Var Value          : TStringStream)          : Boolean;
 Function  ZCompressStreamNew       (Const s            : String)                 : TStream;
 Function  ZCompressStreamSS        (Const s            : String)                 : TStringStream;
 Function  ZCompressStr             (Const s            : String;
                                     Var Value          : String)                 : Boolean;
 Function  ZCompressStreamD         (S                  : TStringStream;
                                     Var Value          : TStringStream)          : Boolean;
 Function  BytesArrToString         (aValue             : tIdBytes;
                                     IdEncode           : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                         TIdTextEncoding
                                                        {$ELSE}
                                                         IIdTextEncoding
                                                        {$IFEND}
                                                        {$ELSE}
                                                         IIdTextEncoding
                                                        {$ENDIF} = Nil)           : String;
 Function  ObjectValueToFieldType   (TypeObject         : TObjectValue)           : TFieldType;
 Function  FieldTypeToObjectValue   (FieldType          : TFieldType)             : TObjectValue;
 Function  DatasetStateToMassiveType(DatasetState       : TDatasetState)          : TMassiveMode;
 Function  MassiveModeToString      (MassiveMode        : TMassiveMode)           : String;
 Function  StringToMassiveMode      (Value              : String)                 : TMassiveMode;
 Function  DateTimeToUnix           (ConvDate           : TDateTime)              : Int64;
 Function  UnixToDateTime           (USec               : Int64)                  : TDateTime;
 Function  BuildFloatString         (Value              : String)                 : String;
 Function  BuildStringFloat         (Value              : String;
                                     JsonModeD          : TJsonMode = jmDataware;
                                     FloatDecimalFormat : String = '')            : String;
 Function  GetMIMEType              (sFile              : TFileName)              : string;
 Function  Scripttags               (Value              : String)                 : Boolean;
 Function  DWFileExists             (sFile,
                                     BaseFilePath       : String)                 : Boolean;
 Function  SystemProtectFiles       (sFile              : String) : Boolean;
 Function  RequestTypeToRoute       (RequestType        : TRequestType)           : TDWRoute;
 Procedure DeleteStr                (Var Value          : String;
                                     InitPos,
                                     FinalPos           : Integer);
 Function  RandomString             (strLen             : Integer)                : String;
 Function  StrDWLength              (Value              : String)                 : Integer;
 Function  RequestTypeToString      (RequestType        : TRequestType)           : String;
 Function  EncryptSHA256            (Key, Text          : TDWString;
                                     Encrypt            : Boolean)                : String;
 Function  EncodeURIComponent       (Const ASrc         : String)                 : String;
 Function  iif                      (ATest              : Boolean;
                                     Const ATrue        : Integer;
                                     Const AFalse       : Integer)                : Integer;{$IFDEF USE_INLINE}Inline;{$ENDIF}Overload;
 Function  iif                      (ATest              : Boolean;
                                     Const ATrue        : String;
                                     Const AFalse       : String)                 : String; {$IFDEF USE_INLINE}Inline;{$ENDIF}Overload;
 Function  iif                      (ATest              : Boolean;
                                     Const ATrue        : Boolean;
                                     Const AFalse       : Boolean)                : Boolean;{$IFDEF USE_INLINE}Inline;{$ENDIF}Overload;

Var
 DecimalLocal : Char;

implementation

Uses uDWJSONObject, uDWJSONTools;

Function iif(ATest       : Boolean;
             Const ATrue  : Integer;
             Const AFalse : Integer) : Integer;{$IFDEF USE_INLINE}Inline;{$ENDIF}
Begin
 If ATest Then
  Result := ATrue
 Else
  Result := AFalse;
End;

Function iif(ATest        : Boolean;
             Const ATrue  : String;
             Const AFalse : String)  : String;{$IFDEF USE_INLINE}Inline;{$ENDIF}
Begin
 If ATest Then
  Result := ATrue
 Else
  Result := AFalse;
End;

Function iif(ATest        : Boolean;
             Const ATrue  : Boolean;
             Const AFalse : Boolean) : Boolean;{$IFDEF USE_INLINE}Inline;{$ENDIF}
Begin
 If ATest Then
  Result := ATrue
 Else
  Result := AFalse;
End;

Function EncodeURIComponent(Const ASrc: String) : String;
Const
 HexMap : String = '0123456789ABCDEF';
 Function IsSafeChar(ch: Integer): Boolean;
 Begin
  If      (ch >= 48) And (ch <= 57)  Then Result := True // 0-9
  Else If (ch >= 65) And (ch <= 90)  Then Result := True // A-Z
  Else If (ch >= 97) And (ch <= 122) Then Result := True // a-z
  Else If (ch = 33)  Then Result := True // !
  Else If (ch >= 39) And (ch <= 42)  Then Result := True // '()*
  Else If (ch >= 45) And (ch <= 46)  Then Result := True // -.
  Else If (ch = 95)  Then Result := True // _
  Else If (ch = 126) Then Result := True // ~
  Else Result := False;
 End;
Var
 I, J     : Integer;
 ASrcUTF8 : String;
Begin
 Result := '';    {Do not Localize}
 ASrcUTF8 := ASrc;
 // UTF8Encode call not strictly necessary but
 // prevents implicit conversion warning
 I := 1; J := 1;
 SetLength(Result, Length(ASrcUTF8) * 3); // space to %xx encode every byte
 While I <= Length(ASrcUTF8) Do
  Begin
   If IsSafeChar(Ord(ASrcUTF8[I])) then
    Begin
     Result[J] := ASrcUTF8[I];
     Inc(J);
    End
   Else
    Begin
     Result[J] := '%';
     Result[J+1] := HexMap[(Ord(ASrcUTF8[I]) shr 4) + 1];
     Result[J+2] := HexMap[(Ord(ASrcUTF8[I]) and 15) + 1];
     Inc(J,3);
    End;
   Inc(I);
  End;
 SetLength(Result, J-1);
End;

Function EncryptSHA256(Key, Text : TDWString;
                       Encrypt   : Boolean) : String;
Var
 Cipher : TDWDCP_rijndael;
Begin
 Result := '';
 Cipher := TDWDCP_rijndael.Create(Nil);
 Try
  Cipher.InitStr(Key, TDWDCP_sha256);
  If Encrypt Then
   Result := Cipher.EncryptString(Text)
  Else
   Result := Cipher.DecryptString(Text);
 Finally
  Cipher.Burn;
  Cipher.Free;
 End;
End;

Procedure TRESTDWUriOptions.SetBaseServer (Value : String);
Begin
 vBaseServer := Lowercase(Value);
End;

Procedure TRESTDWUriOptions.SetDataUrl    (Value : String);
Begin
 vDataUrl := Lowercase(Value);
End;

Procedure TRESTDWUriOptions.SetServerEvent(Value : String);
Begin
 vServerEvent := Lowercase(Value);
 If vServerEvent <> '' Then
  If vServerEvent[InitStrPos] = '/' then
   Delete(vServerEvent, InitStrPos, 1);
End;

Procedure TRESTDWUriOptions.SetEventName(Value : String);
Begin
 vEventName := Lowercase(Value);
 If vEventName <> '' Then
  If vEventName[InitStrPos] = '/' then
   Delete(vEventName, InitStrPos, 1);
End;

Constructor TRESTDWUriOptions.Create;
Begin
 vBaseServer  := '';
 vDataUrl     := '';
 vServerEvent := '';
 vEventName   := '';
End;

Constructor TCripto.Create;
Begin
 Inherited;
 vKeyString := 'RDWBASEKEY256';
 vUseCripto := False;
End;

Destructor  TCripto.Destroy;
Begin
 Inherited;
End;

Function  TCripto.Encrypt(Value : String) : String;
Var
 vDWString : TDWString;
Begin
 vDWString := Value;
 Result := EncryptSHA256(vKeyString, vDWString, True);
End;

Function  TCripto.Decrypt(Value : String) : String;
Var
 vDWString : TDWString;
Begin
 vDWString := Value;
 Result := EncryptSHA256(vKeyString, vDWString, False);
End;

Procedure TCripto.Assign(Source: TPersistent);
Var
 Src : TCripto;
Begin
 If Source is TCripto Then
  Begin
   Src        := TCripto(Source);
   vKeyString := Src.vKeyString;
   vUseCripto := Src.vUseCripto;
  End
 Else
  Inherited;
End;

Function  RequestTypeToString(RequestType : TRequestType) : String;
Begin
 Result := '';
 case RequestType Of
  rtGet  : Result := 'GET';
  rtPost : Result := 'POST';
  rtPut  : Result := 'PUT';
  rtPatch : Result := 'PATCH';
  rtDelete : Result := 'DELETE';
 End;
End;

Function StrDWLength(Value : String) : Integer;
Begin
 Result := Length(Value);
End;

Procedure DeleteStr(Var Value : String; InitPos, FinalPos : Integer);
Begin
 Delete(Value, InitPos, FinalPos);
End;

Function  RequestTypeToRoute(RequestType  : TRequestType) : TDWRoute;
Begin
 Result    := crAll;
 Case RequestType Of
  rtGet    : Result := crGet;
  rtPost   : Result := crPost;
  rtPut    : Result := crPut;
  rtPatch  : Result := crPatch;
  rtDelete : Result := crDelete;
 End;
End;

Function  DWFileExists(sFile, BaseFilePath : String) : Boolean;
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

Function SystemProtectFiles(sFile : String) : Boolean;
Const
 cProtectFiles : array[0..1] of string = ('\winnt\', '\windows\');
Var
 I : Integer;
Begin
 Result := False;
 For I := 0 to Length(cProtectFiles) -1 Do
  Begin
   Result := Pos(cProtectFiles[I], lowercase(sFile)) > 0;
   If Result Then
    Break;
  End;
End;

Function GetMIMEType(sFile: TFileName) : string;
Var
 aMIMEMap : TIdMIMETable;
Begin
 If (Pos('.HTML', UpperCase(sFile)) > 0) Then
  Result := 'text/html'
 Else If (Pos('.PHP', UpperCase(sFile)) > 0) Then
  Result := 'text/php'
 Else If (Pos('.PNG', UpperCase(sFile)) > 0) Then
  Result := 'image/png'
 Else If (Pos('.BMP', UpperCase(sFile)) > 0) Then
  Result := 'image/bmp'
 Else If (Pos('.ICO', UpperCase(sFile)) > 0) Then
  Result := 'image/ico'
 Else If (Pos('.GIF', UpperCase(sFile)) > 0) Then
  Result := 'image/gif'
 Else If (Pos('.JPG', UpperCase(sFile)) > 0) Then
  Result := 'image/jpg'
 Else If (Pos('.JS',  UpperCase(sFile)) > 0) Then
  Result := 'application/javascript'
 Else If (Pos('.PDF', UpperCase(sFile)) > 0) Then
  Result := 'application/pdf'
 Else If (Pos('.ZIP', UpperCase(sFile)) > 0) Then
  Result := 'application/zip'
 Else If (Pos('.RAR', UpperCase(sFile)) > 0) Then
  Result := 'application/rar'
 Else If (Pos('.CSS', UpperCase(sFile)) > 0) Then
  Result := 'text/css'
 Else
  Begin
   aMIMEMap := TIdMIMETable.Create(true);
   Try
    Result := aMIMEMap.GetFileMIMEType(sFile);
   Finally
    aMIMEMap.Free;
   End;
  End;
End;

Function scripttags(Value: String): Boolean;
var
 I : Integer;
Begin
 Result := False;
 For I := 0 To Length(tScriptsDetected) -1 Do
  Begin
   Result := pos(tScriptsDetected[I], value) > 0;
   If Result Then
    Break;
  End;
End;

Function DateTimeToUnix(ConvDate: TDateTime): Int64;
begin
 Result := Round((ConvDate - UnixDate) * 86400);
end;

Function UnixToDateTime(USec: Int64): TDateTime;
begin
 Result := (USec / 86400) + UnixDate;
end;

Function MassiveModeToString(MassiveMode : TMassiveMode) : String;
Begin
 Case MassiveMode Of
  mmInactive : Result := 'mmInactive';
  mmBrowse   : Result := 'mmBrowse';
  mmInsert   : Result := 'mmInsert';
  mmUpdate   : Result := 'mmUpdate';
  mmDelete   : Result := 'mmDelete';
  mmExec     : Result := 'mmExec';
 End;
End;

Function StringToMassiveMode(Value       : String)       : TMassiveMode;
Begin
 Result  := mmInactive;
 If LowerCase(Value)      = LowerCase('mmBrowse') Then
  Result := mmBrowse
 Else If LowerCase(Value) = LowerCase('mmInsert') Then
  Result := mmInsert
 Else If LowerCase(Value) = LowerCase('mmUpdate') Then
  Result := mmUpdate
 Else If LowerCase(Value) = LowerCase('mmDelete') Then
  Result := mmDelete
 Else If LowerCase(Value) = LowerCase('mmExec') Then
  Result := mmExec;
End;

Function DatasetStateToMassiveType(DatasetState : TDatasetState) : TMassiveMode;
Begin
 Result := mmInactive;
 Case DatasetState Of
  dsInactive : Result := mmInactive;
  dsBrowse   : Result := mmBrowse;
  dsInsert   : Result := mmInsert;
  dsEdit     : Result := mmUpdate;
 End;
End;

Function BytesArrToString(aValue : tIdBytes;IdEncode :  {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                         TIdTextEncoding
                                                        {$ELSE}
                                                         IIdTextEncoding
                                                        {$IFEND}
                                                        {$ELSE}
                                                         IIdTextEncoding
                                                        {$ENDIF} = Nil) : String;
Begin
 Result   := BytesToString(aValue, IdEncode);
End;

Function  ZCompressStreamD(S         : TStringStream;
                           Var Value : TStringStream) : Boolean;
Var
 {$IFDEF FPC}
  Utf8Stream   : TStringStream;
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream   : TStringStream;
  {$ELSE}
   Utf8Stream   : TMemoryStream;
  {$IFEND}
 {$ENDIF}
Begin
 Result := False;
 Try
 {$IFDEF FPC}
  Utf8Stream := TStringStream.Create('');
  Utf8Stream.CopyFrom(S, S.Size);
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
   Utf8Stream.CopyFrom(S, S.Size);
  {$ELSE} // Delphi 2010 pra cima
   Utf8Stream := TMemoryStream.Create;
   Utf8Stream.Write(AnsiString(S.Datastring)[InitStrPos], S.Size);
  {$IFEND} // Delphi 2010 pra cima
 {$ENDIF}
 {$IFNDEF FPC}
  Value := TStringStream.Create('');
 {$ELSE}
  Value := TStringStream.Create('');
 {$ENDIF}
  Try
   ZCompressStream(Utf8Stream, Value, cCompressionLevel);
   Value.Position := 0;
   Result := True;
  Finally

  End;
 Finally
  {$IFNDEF FPC}Utf8Stream.Size := 0;{$ENDIF}
  Utf8Stream.Free;
  If Value.Size = 0 Then
   Begin
    Result := False;
    FreeAndNil(Value);
   End;
 End;
End;

Function ZCompressStreamSS(Const s : String)  : TStringStream;
Var
 {$IFDEF FPC}
  Utf8Stream   : TStringStream;
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream   : TStringStream;
  {$ELSE}
   Utf8Stream   : TMemoryStream;
  {$IFEND}
 {$ENDIF}
Begin
 Try
 {$IFDEF FPC}
  Utf8Stream := TStringStream.Create(S);
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream := TStringStream.Create(S{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  {$ELSE} // Delphi 2010 pra cima
   Utf8Stream := TMemoryStream.Create;
   Utf8Stream.Write(AnsiString(S)[1], Length(AnsiString(S)));
  {$IFEND} // Delphi 2010 pra cima
 {$ENDIF}
 {$IFNDEF FPC}
  Result := TStringStream.Create('');
 {$ELSE}
  Result := TStringStream.Create('');
 {$ENDIF}
  Try
   ZCompressStream(Utf8Stream, Result, cCompressionLevel);
   Result.Position := 0;
  Finally

  End;
 Finally
  {$IFNDEF FPC}Utf8Stream.Size := 0;{$ENDIF}
  Utf8Stream.Free;
  If Result.Size = 0 Then
   FreeAndNil(Result);
 End;
End;

Function ZCompressStreamNew(Const s : String) : TStream;
Var
 {$IFDEF FPC}
  Utf8Stream   : TStringStream;
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream   : TStringStream;
  {$ELSE}
   Utf8Stream   : TMemoryStream;
  {$IFEND}
 {$ENDIF}
Begin
 Try
 {$IFDEF FPC}
  Utf8Stream := TStringStream.Create(S);
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream := TStringStream.Create(S{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  {$ELSE} // Delphi 2010 pra cima
   Utf8Stream := TMemoryStream.Create;
   Utf8Stream.Write(AnsiString(S)[1], Length(AnsiString(S)));
  {$IFEND} // Delphi 2010 pra cima
 {$ENDIF}
 {$IFNDEF FPC}
  Result := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
 {$ELSE}
  Result := TStringStream.Create('');
 {$ENDIF}
  Try
   ZCompressStream(Utf8Stream, Result, cCompressionLevel);
   Result.Position := 0;
  Finally

  End;
 Finally
  {$IFNDEF FPC}Utf8Stream.Size := 0;{$ENDIF}
  Utf8Stream.Free;
  If Result.Size = 0 Then
   FreeAndNil(Result);
 End;
End;

Function ZCompressStr(Const s   : String;
                      Var Value : String) : Boolean;
Var
 {$IFDEF FPC}
  Utf8Stream   : TStringStream;
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream   : TStringStream;
  {$ELSE}
   Utf8Stream   : TMemoryStream;
  {$IFEND}
 {$ENDIF}
Compressed   : TMemoryStream;
Begin
 {$IFDEF FPC}
  Result := False;
  Utf8Stream := TStringStream.Create(S);
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   Utf8Stream := TStringStream.Create(S{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  {$ELSE} // Delphi 2010 pra cima
   Utf8Stream := TMemoryStream.Create;
   Utf8Stream.Write(AnsiString(S)[1], Length(AnsiString(S)));
  {$IFEND} // Delphi 2010 pra cima
 {$ENDIF}
 Try
  Compressed := TMemoryStream.Create;
  Try
    ZCompressStream(Utf8Stream, Compressed, cCompressionLevel);
    Compressed.Position := 0;
   Try
    Value := StreamToHex(Compressed, False);
//    Value := Encodeb64Stream(Compressed{$IFDEF FPC}, csUndefined{$ENDIF});
    Result := True;
   Finally
   End;
  Finally
   {$IFNDEF FPC}
    {$if CompilerVersion > 21}
    {$IFDEF LINUXFMX}
     Compressed := Nil;
    {$ELSE}
    Compressed.Clear;
    {$ENDIF}
    {$IFEND}
    FreeAndNil(Compressed);
   {$ELSE}
   Compressed := Nil;
   {$ENDIF}
  End;
 Finally
  {$IFNDEF FPC}{$if CompilerVersion > 21}Utf8Stream.Clear;{$IFEND}{$ENDIF}
  FreeAndNil(Utf8Stream);
 End;
End;

Function ZDecompressStreamD(Const S   : TStringStream;
                            Var Value : TStringStream) : Boolean;
Var
 Utf8Stream,
 Base64Stream : TStringStream;
 {$IFDEF FPC}
  Encoder     : TBase64DecodingStream;
 {$ENDIF}
Begin
 {$IFDEF FPC}
  Base64Stream := TStringStream.Create('');
  S.Position   := 0;
  Base64Stream.CopyFrom(S, 0);
  Base64Stream.Position   := 0;
 {$ELSE}
  Base64Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  S.Position   := 0;
  Base64Stream.CopyFrom(S, S.Size);
  Base64Stream.Position   := 0;
 {$ENDIF}
 Try
  {$IFDEF FPC}
  Value := TStringStream.Create('');
  {$ELSE}
  Value := TStringStream.Create(''); //{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  {$ENDIF}
  Try
   Try
    {$IFDEF FPC}
     Utf8Stream := TStringStream.Create('');
     HexToStream(Base64Stream.DataString, Utf8Stream);
     Utf8Stream.Position := 0;
     ZDecompressStream(Utf8Stream, Value);
     Value.position := 0;
    {$ELSE}
     Utf8Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
     HexToStream(Base64Stream.DataString, Utf8Stream);
     Utf8Stream.position := 0;
     ZDecompressStream(Utf8Stream, Value);
     Value.Position := 0;
    {$ENDIF}
    Result := True;
   Except
    Result := False;
   End;
  Finally
   {$IFNDEF FPC}Utf8Stream.Size := 0;{$ENDIF}
    FreeAndNil(Utf8Stream);
  End;
 Finally
  {$IFNDEF FPC}Base64Stream.Size := 0;{$ENDIF}
  FreeAndNil(Base64Stream);
 End;
End;

Function ZDecompressStreamNew(Const S   : TStream) : TStringStream;
Begin
 {$IFDEF FPC}
  Result := TStringStream.Create('');
 {$ELSE}
  Result := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
 {$ENDIF}
 S.Position := 0;
 ZDecompressStream(S, Result);
 Result.position := 0;
End;

Function ZDecompressStr(Const S   : String;
                        Var Value : String) : Boolean;
Var
 Utf8Stream,
 Compressed,
 Base64Stream : TStringStream;
 {$IFDEF FPC}
  Encoder     : TBase64DecodingStream;
 {$ENDIF}
Begin
 {$IFDEF FPC}
  Result := False;
  Base64Stream := TStringStream.Create(S);
 {$ELSE}
  Base64Stream := TStringStream.Create(S{$if CompilerVersion > 22}, TEncoding.ANSI{$IFEND});
 {$ENDIF}
 Try
  Compressed := TStringStream.Create('');
  Try
   {$IFDEF FPC}
    Utf8Stream    := TStringStream.Create('');
    Encoder       := TBase64DecodingStream.Create(Base64Stream);
    Utf8Stream.CopyFrom(Encoder, Encoder.Size);
    Utf8Stream.Position := 0;
    FreeAndNil(Encoder);
    Compressed.position := 0;
    ZDecompressStream(Utf8Stream, Compressed);
   {$ELSE}
    Utf8Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
    DecodeStream(Base64Stream, Utf8Stream);
    Utf8Stream.position := 0;
    ZDecompressStream(Utf8Stream, Compressed);
    Compressed.Position := 0;
   {$ENDIF}
   Try
    Value := Compressed.DataString;
    Result := True;
   Finally
    {$IFNDEF FPC}Utf8Stream.Size := 0;{$ENDIF}
    FreeAndNil(Utf8Stream);
   End;
  Finally
   {$IFNDEF FPC}Compressed.Size := 0;{$ENDIF}
   FreeAndNil(Compressed);
  End;
 Finally
  {$IFNDEF FPC}Base64Stream.Size := 0;{$ENDIF}
  FreeAndNil(Base64Stream);
 End;
End;

Function StreamToBytes(Stream : TMemoryStream) : tidBytes;
Begin
 Try
  Stream.Position := 0;
  SetLength  (Result, Stream.Size);
  Stream.Read(Result[0], Stream.Size);
 Finally
 End;
end;

Procedure LimpaLixoHex(Var Value : String);
Begin
 If Length(Value) > 0 Then
  Begin
   If Value[1] = '{' Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[1] = #13 Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[1] = '"' Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[1] = 'L' Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[Length(Value)] = '"' Then
    Delete(Value, Length(Value), 1);
  End;
End;

Procedure HexToPChar(HexString : String;
                     Var Data  : PChar);
Var
 {$IFDEF POSIX} //Android}
 bytes: TBytes;
 {$ENDIF}
 Stream : TMemoryStream;
Begin
 LimpaLixoHex(HexString);
 Stream := TMemoryStream.Create;
 Try
  {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
   SetLength(bytes, Length(HexString) div 2);
   HexToBin(PChar(HexString), 0, bytes, 0, Length(bytes));
   stream.WriteBuffer(bytes[0], length(bytes));
  {$ELSE}
    TMemoryStream(Stream).Size := Length(HexString) Div 2;
    {$IFDEF FPC}
    HexToBin(PChar(HexString), TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
    {$ELSE}
     {$IF CompilerVersion > 21} // Delphi 2010 pra cima
     {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
      SetLength(bytes, Length(HexString) div 2);
      HexToBin(PChar(HexString), 0, bytes, 0, Length(bytes));
      stream.WriteBuffer(bytes[0], length(bytes));
     {$ELSE}
      HexToBin(PWideChar (HexString),   TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
     {$IFEND}
     {$ELSE}
      HexToBin(PChar (HexString),   TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
     {$IFEND}
    {$ENDIF}
  {$IFEND}
  Stream.Position := 0;
 Finally
  Stream.Read(Data, Stream.Size);
  FreeAndNil(Stream);
 End;
End;

Procedure HexToStream(Str    : String;
                      Stream : TStream);
{$IFDEF POSIX} //Android}
var bytes: TBytes;
{$ENDIF}
Begin
 LimpaLixoHex(Str);
 {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
  SetLength(bytes, Length(str) div 2);
  HexToBin(PChar(str), 0, bytes, 0, Length(bytes));
  stream.WriteBuffer(bytes[0], length(bytes));
 {$ELSE}
   TMemoryStream(Stream).Size := Length(Str) Div 2;
   {$IFDEF FPC}
   HexToBin(PChar(Str), TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
   {$ELSE}
    {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
     SetLength(bytes, Length(str) div 2);
     HexToBin(PChar(str), 0, bytes, 0, Length(bytes));
     stream.WriteBuffer(bytes[0], length(bytes));
    {$ELSE}
     HexToBin(PWideChar (Str),   TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
    {$IFEND}
    {$ELSE}
     HexToBin(PChar (Str),   TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
    {$IFEND}
   {$ENDIF}
 {$IFEND}
 Stream.Position := 0;
End;

{$IF Defined(ANDROID) or Defined(LINUX) or Defined(IOS)}
function abbintohexstring(stream: Tstream):string;
var
  s: TStream;
  i: Integer;
  b: Byte;
  hex: String;
begin
  s := stream;
  try
    s.Seek(int64(0), word(soFromBeginning));
    for i:=1 to s.Size do
    begin
      s.Read(b, 1);
      hex := IntToHex(b, 2);
      //.....
      result:=result+hex;
    end;
  finally
    s.Free;
  end;
end;
{$IFend}

Function PCharToHex(Data : PChar; Size : Integer; QQuoted : Boolean = True) : String;
Var
 Stream : TMemoryStream;
{$IFDEF POSIX} //Android}
 bytes, bytes2: TBytes;
{$ENDIF}
Begin
 Stream := TMemoryStream.Create;
 Try
  Stream.Write(Data, Size);
  Stream.Position := 0;
 {$IFNDEF FPC}
  {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
   Result := abbintohexstring(stream);
  {$ELSE}
   {$IFDEF LINUX} // Android}
    Result := abbintohexstring(stream); // BytesToString(bytes2);  // TEncoding.UTF8.GetString(bytes2);
   {$ELSE}
    SetLength     (Result, Stream.Size * 2);
    BinToHex      (TMemoryStream(Stream).Memory, PChar(Result), Stream.Size);
   {$ENDIF}
  {$IFEND}
 {$ELSE}
  SetLength     (Result, Stream.Size * 2);
  BinToHex      (TMemoryStream(Stream).Memory, PChar(Result), Stream.Size);
 {$ENDIF}
 Finally
  FreeAndNil(Stream);
  If QQuoted Then
   Result := '"' + Result + '"';
 End;
End;

Function StreamToHex(Stream  : TStream; QQuoted : Boolean = True) : String;
{$IFDEF POSIX} //Android}
var bytes, bytes2: TBytes;
{$ENDIF}
Begin
 Stream.Position := 0;
 {$IFNDEF FPC}
  {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
   Result := abbintohexstring(stream);
  {$ELSE}
   {$IFDEF LINUX} // Android}
    Result := abbintohexstring(stream); // BytesToString(bytes2);  // TEncoding.UTF8.GetString(bytes2);
   {$ELSE}
    SetLength     (Result, Stream.Size * 2);
    BinToHex      (TMemoryStream(Stream).Memory, PChar(Result), Stream.Size);
   {$ENDIF}
  {$IFEND}
 {$ELSE}
  SetLength     (Result, Stream.Size * 2);
  BinToHex      (TMemoryStream(Stream).Memory, PChar(Result), Stream.Size);
 {$ENDIF}
 If QQuoted Then
  Result := '"' + Result + '"';
End;

Function FileToStr(Const FileName : String):string;
Var
 Stream : TFileStream;
Begin
 Stream:= TFileStream.Create(FileName, fmOpenRead);
 Try
  SetLength(Result, Stream.Size);
  Stream.Position := 0;
  Stream.ReadBuffer(Pointer(Result)^, Stream.Size);
 Finally
  Stream.Free;
 End;
End;

Procedure StrToFile(Const FileName, SourceString : string);
Var
 Stream : TFileStream;
Begin
 If FileExists(FileName) Then
  DeleteFile(FileName);
 Stream:= TFileStream.Create(FileName, fmCreate);
 Try
  Stream.WriteBuffer(Pointer(SourceString)^, Length(SourceString));
 Finally
  Stream.Free;
 End;
End;

Procedure CopyStream(Const Source : TStream;
                           Dest   : TStream);
Var
 BytesRead : Integer;
 Buffer    : PByte;
 Const
  MaxBufSize = $F000;
Begin
 { ** Criando a instância do objeto TMemoryStream para retorno do método ** }
 Dest := TMemoryStream.Create;
 { ** Reposicionando o stream para o seu início ** }
 source.Seek(0, soBeginning);
 source.Position := 0;
 GetMem(Buffer, MaxBufSize);
 { ** Realizando a leitura do stream original, buffer a buffer ** }
 Repeat
  BytesRead := Source.Read(Buffer^, MaxBufSize);
  If BytesRead > 0 then
   Dest.WriteBuffer(Buffer^, BytesRead);
 Until MaxBufSize > BytesRead;
 { ** Reposicionando o stream de retorno para o seu início ** }
 Dest.Seek(0, soBeginning);
End;

Function GenerateStringFromStream(Stream : TStream{$IFNDEF FPC}{$if CompilerVersion > 21}; AEncoding: TEncoding{$IFEND}{$ENDIF}) : String;
Var
 StringStream : TStringStream;
Begin
 StringStream := TStringStream.Create(''{$IFNDEF FPC}{$if CompilerVersion > 21}, AEncoding{$IFEND}{$ENDIF});
 Try
  Stream.Position := 0;
  StringStream.CopyFrom(Stream, Stream.Size);
  Result                := StringStream.DataString;
 Finally
  {$IFNDEF FPC}{$if CompilerVersion > 21}StringStream.Clear;{$IFEND}{$ENDIF}
  StringStream.Free;
 End;
End;
{
Function GenerateStringFromStream(Stream : TStream) : String;
Var
 idBytes : TIdBytes;
Begin
 Try
  SetLength(idBytes, Stream.Size);
  Stream.ReadBuffer(idBytes[0], Stream.Size);
 Finally
 End;
// vResult := PChar(AllocMem((Length(idBytes) * 2) + 1));
 SetLength(Result, Stream.Size * 2);
 BinToHex(@idBytes, PChar(Result), Length(idBytes));
End;
}

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

Function  MassiveSQLMode(aValue : TMassiveSQLMode) : String;
Begin
 Result := 'msUnknow';
 Case aValue Of
  msqlQuery   : Result := 'msqlQuery';
  msqlExecute : Result := 'msqlExecute';
 End;
End;

Function  MassiveSQLMode(aValue : String) : TMassiveSQLMode;
Var
 aData : String;
Begin
 aData := lowercase(aValue);
 If aData = lowercase('msqlQuery') Then
  Result := msqlQuery
 Else If aData = lowercase('msqlExecute') Then
  Result := msqlExecute;
End;

Function StringFloat     (aValue          : String)           : String;
Begin
 Result := StringReplace(aValue, '.', '', [rfReplaceall]);
End;

Function GetStringFromBoolean(Value       : Boolean)          : String;
Begin
 Result := 'false';
 If Value Then
  Result := 'true';
End;

Function GetObjectName   (TypeObject      : TTypeObject)       : String;
Begin
 Result := 'toObject';
 Case TypeObject Of
  toDataset  : Result := 'toDataset';
  toParam    : Result := 'toParam';
  toVariable : Result := 'toVariable';
  toObject   : Result := 'toObject';
  toMassive  : Result := 'toMassive';
 End;
End;

Function GetJSONModeName(TypeObject      : TJsonMode)       : String;
Begin
 Result := 'jmDataware';
 Case TypeObject Of
  jmDataware  : Result := 'jmDataware';
  jmPureJSON  : Result := 'jmPureJSON';
  jmUndefined : Result := 'jmUndefined';
  Else
   Result := 'jmDataware';
 End;
End;

Function FieldTypeToObjectValue(FieldType  : TFieldType)   : TObjectValue;
Begin
 Result := ovUnknown;
 Case FieldType Of
  ftString          : Result := ovString;
  ftSmallint        : Result := ovSmallint;
  ftInteger         : Result := ovInteger;
  ftWord            : Result := ovWord;
  ftBoolean         : Result := ovBoolean;
  ftFloat           : Result := ovFloat;
  ftCurrency        : Result := ovCurrency;
  ftBCD             : Result := ovBCD;
  ftDate            : Result := ovDate;
  ftTime            : Result := ovTime;
  ftDateTime        : Result := ovDateTime;
  ftBytes           : Result := ovBytes;
  ftVarBytes        : Result := ovVarBytes;
  ftAutoInc         : Result := ovAutoInc;
  ftBlob            : Result := ovBlob;
  ftMemo            : Result := ovMemo;
  ftGraphic         : Result := ovGraphic;
  ftFmtMemo         : Result := ovFmtMemo;
  ftParadoxOle      : Result := ovParadoxOle;
  ftDBaseOle        : Result := ovDBaseOle;
  ftTypedBinary     : Result := ovTypedBinary;
  ftCursor          : Result := ovCursor;
  ftFixedChar       : Result := ovFixedChar;
  ftWideString      : Result := ovWideString;
  ftLargeint        : Result := ovLargeint;
  ftADT             : Result := ovADT;
  ftArray           : Result := ovArray;
  ftReference       : Result := ovReference;
  ftDataSet         : Result := ovDataSet;
  ftOraBlob         : Result := ovOraBlob;
  ftOraClob         : Result := ovOraClob;
  ftVariant         : Result := ovVariant;
  ftInterface       : Result := ovInterface;
  ftIDispatch       : Result := ovIDispatch;
  ftGuid            : Result := ovGuid;
  ftTimeStamp       : Result := ovTimeStamp;
  ftFMTBcd          : Result := ovFMTBcd;
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 acima
    ftFixedWideChar   : Result := ovFixedWideChar;
    ftWideMemo        : Result := ovWideMemo;
    ftOraTimeStamp    : Result := ovOraTimeStamp;
    ftOraInterval     : Result := ovOraInterval;
    ftLongWord        : Result := ovLongWord;
    ftShortint        : Result := ovShortint;
    ftByte            : Result := ovByte;
    ftExtended        : Result := ovExtended;
    ftConnection      : Result := ovConnection;
    ftParams          : Result := ovParams;
    ftStream          : Result := ovStream;
    ftTimeStampOffset : Result := ovTimeStampOffset;
    ftObject          : Result := ovObject;
    ftSingle          : Result := ovSingle;
   {$IFEND}
  {$ENDIF}
 End;
End;

Function ObjectValueToFieldType(TypeObject : TObjectValue) : TFieldType;
Begin
 Result := ftUnknown;
 Case TypeObject Of
  ovString          : Result := ftString;
  ovSmallint        : Result := ftSmallint;
  ovInteger         : Result := ftInteger;
  ovWord            : Result := ftWord;
  ovBoolean         : Result := ftBoolean;
  ovFloat           : Result := ftFloat;
  ovCurrency        : Result := ftCurrency;
  ovBCD             : Result := ftBCD;
  ovDate            : Result := ftDate;
  ovTime            : Result := ftTime;
  ovDateTime        : Result := ftDateTime;
  ovBytes           : Result := ftBytes;
  ovVarBytes        : Result := ftVarBytes;
  ovAutoInc         : Result := ftAutoInc;
  ovBlob            : Result := ftBlob;
  ovMemo            : Result := ftMemo;
  ovGraphic         : Result := ftGraphic;
  ovFmtMemo         : Result := ftFmtMemo;
  ovParadoxOle      : Result := ftParadoxOle;
  ovDBaseOle        : Result := ftDBaseOle;
  ovTypedBinary     : Result := ftTypedBinary;
  ovCursor          : Result := ftCursor;
  ovFixedChar       : Result := ftFixedChar;
  ovWideString      : Result := ftWideString;
  ovLargeint        : Result := ftLargeint;
  ovADT             : Result := ftADT;
  ovArray           : Result := ftArray;
  ovReference       : Result := ftReference;
  ovDataSet         : Result := ftDataSet;
  ovOraBlob         : Result := ftOraBlob;
  ovOraClob         : Result := ftOraClob;
  ovVariant         : Result := ftVariant;
  ovInterface       : Result := ftInterface;
  ovIDispatch       : Result := ftIDispatch;
  ovGuid            : Result := ftGuid;
  ovTimeStamp       : Result := ftTimeStamp;
  ovFMTBcd          : Result := ftFMTBcd;
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 acima
    ovFixedWideChar   : Result := ftFixedWideChar;
    ovWideMemo        : Result := ftWideMemo;
    ovOraTimeStamp    : Result := ftOraTimeStamp;
    ovOraInterval     : Result := ftOraInterval;
    ovLongWord        : Result := ftLongWord;
    ovShortint        : Result := ftShortint;
    ovByte            : Result := ftByte;
    ovExtended        : Result := ftExtended;
    ovConnection      : Result := ftConnection;
    ovParams          : Result := ftParams;
    ovStream          : Result := ftStream;
    ovTimeStampOffset : Result := ftTimeStampOffset;
    ovObject          : Result := ftObject;
    ovSingle          : Result := ftSingle;
   {$IFEND}
  {$ENDIF}
 End;
End;

Function GetObjectName   (TypeObject      : String) : TTypeObject;
Var
 vTypeObject : String;
Begin
 Result := toObject;
 vTypeObject := Uppercase(TypeObject);
 If vTypeObject = Uppercase('toObject') Then
  Result := toObject
 Else If vTypeObject = Uppercase('toDataset') Then
  Result := toDataset
 Else If vTypeObject = Uppercase('toParam') Then
  Result := toParam
 Else If vTypeObject = Uppercase('toVariable') Then
  Result := toVariable
 Else If vTypeObject = Uppercase('toMassive') Then
  Result := toMassive;
End;

Function GetJSONModeName   (TypeObject      : String) : TJsonMode;
Var
 vTypeObject : String;
Begin
 Result := jmDataware;
 vTypeObject := Uppercase(TypeObject);
 If vTypeObject = Uppercase('jmDataware') Then
  Result := jmDataware
 Else If vTypeObject = Uppercase('jmPureJSON') Then
  Result := jmPureJSON
 Else If vTypeObject = Uppercase('jmUndefined') Then
  Result := jmUndefined;
End;

Function GetDirectionName(ObjectDirection : TObjectDirection) : String;
Begin
 Result := 'odINOUT';
 Case ObjectDirection Of
  odINOUT : Result := 'odINOUT';
  odIN    : Result := 'odIN';
  odOUT   : Result := 'odOUT';
 End;
End;

Function GetBooleanFromString(Value : String) : Boolean;
Begin
 Result := Uppercase(Value) = 'TRUE';
End;

Function GetDirectionName(ObjectDirection : String) : TObjectDirection;
Var
 vObjectDirection : String;
Begin
 Result := odOUT;
 vObjectDirection := Uppercase(ObjectDirection);
 If vObjectDirection = Uppercase('odINOUT') Then
  Result := odINOUT
 Else If vObjectDirection = Uppercase('odIN') Then
  Result := odIN;
{
 Else If vObjectDirection = Uppercase('odOUT') Then
  Result := odOUT;
}
End;

Function GetValueType    (ObjectValue     : TObjectValue)     : String;
Begin
 Result := 'ovUnknown';
 Case ObjectValue Of
  ovUnknown         : Result := 'ovUnknown';
  ovString          : Result := 'ovString';
  ovSmallint        : Result := 'ovSmallint';
  ovInteger         : Result := 'ovInteger';
  ovWord            : Result := 'ovWord';
  ovBoolean         : Result := 'ovBoolean';
  ovFloat           : Result := 'ovFloat';
  ovCurrency        : Result := 'ovCurrency';
  ovBCD             : Result := 'ovBCD';
  ovDate            : Result := 'ovDate';
  ovTime            : Result := 'ovTime';
  ovDateTime        : Result := 'ovDateTime';
  ovBytes           : Result := 'ovBytes';
  ovVarBytes        : Result := 'ovVarBytes';
  ovAutoInc         : Result := 'ovAutoInc';
  ovBlob            : Result := 'ovBlob';
  ovMemo            : Result := 'ovMemo';
  ovGraphic         : Result := 'ovGraphic';
  ovFmtMemo         : Result := 'ovFmtMemo';
  ovParadoxOle      : Result := 'ovParadoxOle';
  ovDBaseOle        : Result := 'ovDBaseOle';
  ovTypedBinary     : Result := 'ovTypedBinary';
  ovCursor          : Result := 'ovCursor';
  ovFixedChar       : Result := 'ovFixedChar';
  ovWideString      : Result := 'ovWideString';
  ovLargeint        : Result := 'ovLargeint';
  ovADT             : Result := 'ovADT';
  ovArray           : Result := 'ovArray';
  ovReference       : Result := 'ovReference';
  ovDataSet         : Result := 'ovDataSet';
  ovOraBlob         : Result := 'ovOraBlob';
  ovOraClob         : Result := 'ovOraClob';
  ovVariant         : Result := 'ovVariant';
  ovInterface       : Result := 'ovInterface';
  ovIDispatch       : Result := 'ovIDispatch';
  ovGuid            : Result := 'ovGuid';
  ovTimeStamp       : Result := 'ovTimeStamp';
  ovFMTBcd          : Result := 'ovFMTBcd';
  ovFixedWideChar   : Result := 'ovFixedWideChar';
  ovWideMemo        : Result := 'ovWideMemo';
  ovOraTimeStamp    : Result := 'ovOraTimeStamp';
  ovOraInterval     : Result := 'ovOraInterval';
  ovLongWord        : Result := 'ovLongWord';
  ovShortint        : Result := 'ovShortint';
  ovByte            : Result := 'ovByte';
  ovExtended        : Result := 'ovExtended';
  ovConnection      : Result := 'ovConnection';
  ovParams          : Result := 'ovParams';
  ovStream          : Result := 'ovStream';
  ovTimeStampOffset : Result := 'ovTimeStampOffset';
  ovObject          : Result := 'ovObject';
  ovSingle          : Result := 'ovSingle';
 End;
End;

Function GetValueType (ObjectValue : String) : TObjectValue;
Var
 vObjectValue : String;
Begin
 Result := ovSingle;
 vObjectValue := Uppercase(ObjectValue);
 If vObjectValue      = Uppercase('ovUnknown')         Then
  Result := ovUnknown
 Else If vObjectValue = Uppercase('ovString')          Then
  Result := ovString
 Else If vObjectValue = Uppercase('ovSmallint')        Then
  Result := ovSmallint
 Else If vObjectValue = Uppercase('ovInteger')         Then
  Result := ovInteger
 Else If vObjectValue = Uppercase('ovWord')            Then
  Result := ovWord
 Else If vObjectValue = Uppercase('ovBoolean')         Then
  Result := ovBoolean
 Else If vObjectValue = Uppercase('ovFloat')           Then
  Result := ovFloat
 Else If vObjectValue = Uppercase('ovCurrency')        Then
  Result := ovCurrency
 Else If vObjectValue = Uppercase('ovBCD')             Then
  Result := ovBCD
 Else If vObjectValue = Uppercase('ovDate')            Then
  Result := ovDate
 Else If vObjectValue = Uppercase('ovTime')            Then
  Result := ovTime
 Else If vObjectValue = Uppercase('ovDateTime')        Then
  Result := ovDateTime
 Else If vObjectValue = Uppercase('ovBytes')           Then
  Result := ovBytes
 Else If vObjectValue = Uppercase('ovVarBytes')        Then
  Result := ovVarBytes
 Else If vObjectValue = Uppercase('ovAutoInc')         Then
  Result := ovAutoInc
 Else If vObjectValue = Uppercase('ovBlob')            Then
  Result := ovBlob
 Else If vObjectValue = Uppercase('ovMemo')            Then
  Result := ovMemo
 Else If vObjectValue = Uppercase('ovGraphic')         Then
  Result := ovGraphic
 Else If vObjectValue = Uppercase('ovFmtMemo')         Then
  Result := ovFmtMemo
 Else If vObjectValue = Uppercase('ovParadoxOle')      Then
  Result := ovParadoxOle
 Else If vObjectValue = Uppercase('ovDBaseOle')        Then
  Result := ovDBaseOle
 Else If vObjectValue = Uppercase('ovTypedBinary')     Then
  Result := ovTypedBinary
 Else If vObjectValue = Uppercase('ovCursor')          Then
  Result := ovCursor
 Else If vObjectValue = Uppercase('ovFixedChar')       Then
  Result := ovFixedChar
 Else If vObjectValue = Uppercase('ovWideString')      Then
  Result := ovWideString
 Else If vObjectValue = Uppercase('ovLargeint')        Then
  Result := ovLargeint
 Else If vObjectValue = Uppercase('ovADT')             Then
  Result := ovADT
 Else If vObjectValue = Uppercase('ovArray')           Then
  Result := ovArray
 Else If vObjectValue = Uppercase('ovReference')       Then
  Result := ovReference
 Else If vObjectValue = Uppercase('ovDataSet')         Then
  Result := ovDataSet
 Else If vObjectValue = Uppercase('ovOraBlob')         Then
  Result := ovOraBlob
 Else If vObjectValue = Uppercase('ovOraClob')         Then
  Result := ovOraClob
 Else If vObjectValue = Uppercase('ovVariant')         Then
  Result := ovVariant
 Else If vObjectValue = Uppercase('ovInterface')       Then
  Result := ovInterface
 Else If vObjectValue = Uppercase('ovIDispatch')       Then
  Result := ovIDispatch
 Else If vObjectValue = Uppercase('ovGuid')            Then
  Result := ovGuid
 Else If vObjectValue = Uppercase('ovTimeStamp')       Then
  Result := ovTimeStamp
 Else If vObjectValue = Uppercase('ovFMTBcd')          Then
  Result := ovFMTBcd
 Else If vObjectValue = Uppercase('ovFixedWideChar')   Then
  Result := ovFixedWideChar
 Else If vObjectValue = Uppercase('ovWideMemo')        Then
  Result := ovWideMemo
 Else If vObjectValue = Uppercase('ovOraTimeStamp')    Then
  Result := ovOraTimeStamp
 Else If vObjectValue = Uppercase('ovOraInterval')     Then
  Result := ovOraInterval
 Else If vObjectValue = Uppercase('ovLongWord')        Then
  Result := ovLongWord
 Else If vObjectValue = Uppercase('ovShortint')        Then
  Result := ovShortint
 Else If vObjectValue = Uppercase('ovByte')            Then
  Result := ovByte
 Else If vObjectValue = Uppercase('ovExtended')        Then
  Result := ovExtended
 Else If vObjectValue = Uppercase('ovConnection')      Then
  Result := ovConnection
 Else If vObjectValue = Uppercase('ovParams')          Then
  Result := ovParams
 Else If vObjectValue = Uppercase('ovStream')          Then
  Result := ovStream
 Else If vObjectValue = Uppercase('ovTimeStampOffset') Then
  Result := ovTimeStampOffset
 Else If vObjectValue = Uppercase('ovObject')          Then
  Result := ovObject
 Else If vObjectValue = Uppercase('ovSingle')          Then
  Result := ovSingle;
End;

Function GetValueTypeTranslator (ObjectValue : String) : TObjectValue;
Var
 vObjectValue : String;
Begin
 Result := ovString;
 vObjectValue := Uppercase(ObjectValue);
 If vObjectValue      = Uppercase('_Unknown')         Then
  Result := ovUnknown
 Else If vObjectValue = Uppercase('_String')          Then
  Result := ovString
 Else If vObjectValue = Uppercase('_Smallint')        Then
  Result := ovSmallint
 Else If vObjectValue = Uppercase('_Integer')         Then
  Result := ovInteger
 Else If vObjectValue = Uppercase('_Word')            Then
  Result := ovWord
 Else If vObjectValue = Uppercase('_Boolean')         Then
  Result := ovBoolean
 Else If vObjectValue = Uppercase('_Float')           Then
  Result := ovFloat
 Else If vObjectValue = Uppercase('_Currency')        Then
  Result := ovCurrency
 Else If vObjectValue = Uppercase('_BCD')             Then
  Result := ovBCD
 Else If vObjectValue = Uppercase('_Date')            Then
  Result := ovDate
 Else If vObjectValue = Uppercase('_Time')            Then
  Result := ovTime
 Else If vObjectValue = Uppercase('_DateTime')        Then
  Result := ovDateTime
 Else If vObjectValue = Uppercase('_Bytes')           Then
  Result := ovBytes
 Else If vObjectValue = Uppercase('_VarBytes')        Then
  Result := ovVarBytes
 Else If vObjectValue = Uppercase('_AutoInc')         Then
  Result := ovAutoInc
 Else If vObjectValue = Uppercase('_Blob')            Then
  Result := ovBlob
 Else If vObjectValue = Uppercase('_Memo')            Then
  Result := ovMemo
 Else If vObjectValue = Uppercase('_Graphic')         Then
  Result := ovGraphic
 Else If vObjectValue = Uppercase('_FmtMemo')         Then
  Result := ovFmtMemo
 Else If vObjectValue = Uppercase('_ParadoxOle')      Then
  Result := ovParadoxOle
 Else If vObjectValue = Uppercase('_DBaseOle')        Then
  Result := ovDBaseOle
 Else If vObjectValue = Uppercase('_TypedBinary')     Then
  Result := ovTypedBinary
 Else If vObjectValue = Uppercase('_Cursor')          Then
  Result := ovCursor
 Else If vObjectValue = Uppercase('_FixedChar')       Then
  Result := ovFixedChar
 Else If vObjectValue = Uppercase('_WideString')      Then
  Result := ovWideString
 Else If vObjectValue = Uppercase('_Largeint')        Then
  Result := ovLargeint
 Else If vObjectValue = Uppercase('_ADT')             Then
  Result := ovADT
 Else If vObjectValue = Uppercase('-Array')           Then
  Result := ovArray
 Else If vObjectValue = Uppercase('_Reference')       Then
  Result := ovReference
 Else If vObjectValue = Uppercase('_DataSet')         Then
  Result := ovDataSet
 Else If vObjectValue = Uppercase('-OraBlob')         Then
  Result := ovOraBlob
 Else If vObjectValue = Uppercase('_OraClob')         Then
  Result := ovOraClob
 Else If vObjectValue = Uppercase('_Variant')         Then
  Result := ovVariant
 Else If vObjectValue = Uppercase('_Interface')       Then
  Result := ovInterface
 Else If vObjectValue = Uppercase('_IDispatch')       Then
  Result := ovIDispatch
 Else If vObjectValue = Uppercase('_Guid')            Then
  Result := ovGuid
 Else If vObjectValue = Uppercase('_TimeStamp')       Then
  Result := ovTimeStamp
 Else If vObjectValue = Uppercase('_FMTBcd')          Then
  Result := ovFMTBcd
 Else If vObjectValue = Uppercase('_FixedWideChar')   Then
  Result := ovFixedWideChar
 Else If vObjectValue = Uppercase('_WideMemo')        Then
  Result := ovWideMemo
 Else If vObjectValue = Uppercase('_OraTimeStamp')    Then
  Result := ovOraTimeStamp
 Else If vObjectValue = Uppercase('_OraInterval')     Then
  Result := ovOraInterval
 Else If vObjectValue = Uppercase('_LongWord')        Then
  Result := ovLongWord
 Else If vObjectValue = Uppercase('_Shortint')        Then
  Result := ovShortint
 Else If vObjectValue = Uppercase('_Byte')            Then
  Result := ovByte
 Else If vObjectValue = Uppercase('_Extended')        Then
  Result := ovExtended
 Else If vObjectValue = Uppercase('_Connection')      Then
  Result := ovConnection
 Else If vObjectValue = Uppercase('_Params')          Then
  Result := ovParams
 Else If vObjectValue = Uppercase('_Stream')          Then
  Result := ovStream
 Else If vObjectValue = Uppercase('_TimeStampOffset') Then
  Result := ovTimeStampOffset
 Else If vObjectValue = Uppercase('-Object')          Then
  Result := ovObject
 Else If vObjectValue = Uppercase('_Single')          Then
  Result := ovSingle;
End;


Function GetFieldTypeB(FieldType     : TFieldType)     : String;
Begin
 Result := GetFieldType(FieldType);
End;

Function GetFieldType (FieldType     : TFieldType)     : String;
Begin
 Result := 'ftUnknown';
 Case FieldType Of
  ftUnknown         : Result := 'ftUnknown';
  ftString          : Result := 'ftString';
  ftSmallint        : Result := 'ftSmallint';
  ftInteger         : Result := 'ftInteger';
  ftWord            : Result := 'ftWord';
  ftBoolean         : Result := 'ftBoolean';
  ftFloat           : Result := 'ftFloat';
  ftCurrency        : Result := 'ftCurrency';
  ftBCD             : Result := 'ftBCD';
  ftDate            : Result := 'ftDate';
  ftTime            : Result := 'ftTime';
  ftDateTime        : Result := 'ftDateTime';
  ftBytes           : Result := 'ftBytes';
  ftVarBytes        : Result := 'ftVarBytes';
  ftAutoInc         : Result := 'ftAutoInc';
  ftBlob            : Result := 'ftBlob';
  ftMemo            : Result := 'ftMemo';
  ftGraphic         : Result := 'ftGraphic';
  ftFmtMemo         : Result := 'ftFmtMemo';
  ftParadoxOle      : Result := 'ftParadoxOle';
  ftDBaseOle        : Result := 'ftDBaseOle';
  ftTypedBinary     : Result := 'ftTypedBinary';
  ftCursor          : Result := 'ftCursor';
  ftFixedChar       :
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := 'ftFixedChar';
   {$ELSE}
    Result := 'ftString';
   {$IFEND}
  {$ELSE}
   Result := 'ftString';
  {$ENDIF}
  ftWideString      : Result := 'ftString';
  ftLargeint        : Result := 'ftLargeint';
  ftADT             : Result := 'ftADT';
  ftArray           : Result := 'ftArray';
  ftReference       : Result := 'ftReference';
  ftDataSet         : Result := 'ftDataSet';
  ftOraBlob         : Result := 'ftOraBlob';
  ftOraClob         : Result := 'ftOraClob';
  ftVariant         : Result := 'ftVariant';
  ftInterface       : Result := 'ftInterface';
  ftIDispatch       : Result := 'ftIDispatch';
  ftGuid            : Result := 'ftGuid';
  ftTimeStamp       : Result := 'ftTimeStamp';
  ftFMTBcd          : Result := 'ftFMTBcd';
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
    ftSingle          : Result := 'ftSingle';
    ftWideMemo        : Result := 'ftWideMemo';
    ftFixedWideChar   : Result := 'ftFixedWideChar';
    ftOraTimeStamp    : Result := 'ftOraTimeStamp';
    ftOraInterval     : Result := 'ftOraInterval';
    ftLongWord        : Result := 'ftLongWord';
    ftShortint        : Result := 'ftShortint';
    ftExtended        : Result := 'ftFloat';
    ftByte            : Result := 'ftByte';
    ftConnection      : Result := 'ftConnection';
    ftParams          : Result := 'ftParams';
    ftStream          : Result := 'ftBlob';
    ftTimeStampOffset : Result := 'ftTimeStamp';
    ftObject          : Result := 'ftObject';
   {$IFEND}
  {$ELSE}
   ftWideMemo         : Result := 'ftWideMemo';
   ftFixedWideChar    : Result := 'ftFixedWideChar';
  {$ENDIF}
 End;
End;

Function GetFieldType(FieldType : String) : TFieldType;
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
  Result := ftFmtBCD
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
 {$if CompilerVersion < 18} // delphi 7   compatibilidade enter Sever no XE e Client no D7
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
   Result := ftFMTBcd
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
     Result := ftExtended
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

{$IFNDEF FPC}
{$if CompilerVersion > 22}
Function GetEncoding(Avalue  : TEncodeSelect) : TEncoding;
Begin
 Result := TEncoding.utf8;
 Case Avalue of
  esUtf8  : Result := TEncoding.Unicode;
  esANSI  : Result := TEncoding.ANSI;
  esASCII : Result := TEncoding.ASCII;
 End;
End;
{$IFEND}
{$ENDIF}

Function GetEncodingID(Avalue  : TEncodeSelect) :  {$IFNDEF FPC}
                                                    {$IF (DEFINED(OLDINDY))}
                                                     TIdTextEncoding
                                                    {$ELSE}
                                                     IIdTextEncoding
                                                    {$IFEND}
                                                   {$ELSE}
                                                    IIdTextEncoding
                                                   {$ENDIF};
Begin
{$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
 Result := enDefault;
{$ELSE}
 Result := IndyTextEncoding(encIndyDefault);
{$IFEND}
{$ENDIF}
 Case Avalue of
  esUtf8  : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
             Result := enUTF8;
            {$ELSE}
             Result := IndyTextEncoding(encUTF8);
            {$IFEND}
            {$ELSE}
             Result := IndyTextEncoding(encUTF8);
            {$ENDIF}
  esANSI,
  esASCII :  {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
             Result := en8Bit;
            {$ELSE}
             Result := IndyTextEncoding(encASCII);
            {$IFEND}
            {$ELSE}
             Result := IndyTextEncoding(encASCII);
            {$ENDIF}
 End;
End;

Function BuildStringFloat(Value: String; JsonModeD: TJsonMode = jmDataware; FloatDecimalFormat : String = ''): String;
Begin
 {$IFDEF FPC}
  DecimalLocal := DecimalSeparator;
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
  DecimalLocal := FormatSettings.DecimalSeparator;
  {$ELSE}
  DecimalLocal := DecimalSeparator;
  {$IFEND}
 {$ENDIF}
 Case JsonModeD Of
  jmDataware,
  jmUndefined : Result := StringReplace(Value, DecimalLocal, TDecimalChar, [rfReplaceall]);
  jmPureJSON  : Begin
                 If FloatDecimalFormat = '' Then
                  Result := Value
                 Else
                  If DecimalLocal <> FloatDecimalFormat Then
                   Result := StringReplace(Value, DecimalLocal, FloatDecimalFormat, [rfReplaceall])
                  Else
                   Result := Value;
                End;
 End;
End;

Function BuildFloatString(Value : String) : String;
Begin
 {$IFDEF FPC}
 DecimalLocal := DecimalSeparator;
 {$ELSE}
 {$if CompilerVersion > 21} // Delphi 2010 pra cima
 DecimalLocal := FormatSettings.DecimalSeparator;
 {$ELSE}
 DecimalLocal := DecimalSeparator;
 {$IFEND}
 {$ENDIF}
 Result := StringReplace(Value, TDecimalChar, DecimalLocal, [rfReplaceAll]);
End;

Function RandomString(strLen : Integer) : String;
Var
 str : String;
Begin
 Randomize;
 str := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW XYZ';
 Result := '';
 Repeat
  Result := Result + str[Random(Length(str) - FinalStrPos) + 1];
 Until (Length(Result) = strLen)
End;

Procedure InitializeStrings;
{$IFNDEF FPC}
 {$if CompilerVersion > 24} // Delphi 2010 pra cima
 Var
  s : String;
 {$IFEND}
{$ENDIF}
Begin
 {$IFNDEF FPC}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   s := '0';
   If Low(s) = 0 Then
    Begin
     InitStrPos  := 0;
     FinalStrPos := 1;
    End
   Else
    Begin
     InitStrPos  := 1;
     FinalStrPos := 0;
    End;
  {$ELSE}
   InitStrPos  := 1;
   FinalStrPos := 0;
  {$IFEND}
 {$ELSE}
  InitStrPos  := 1;
  FinalStrPos := 0;
 {$ENDIF}
End;

Initialization
 InitializeStrings;

Finalization

end.


