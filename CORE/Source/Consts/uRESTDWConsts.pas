Unit uRESTDWConsts;

{$I ..\..\Source\Includes\uRESTDW.inc}

{
  REST Dataware.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFNDEF RESTDWLAZARUS}
 {$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
 {$ENDIF}
{$ENDIF}

Interface

Uses
 {$IFDEF FPC}
  {$IFDEF RESTDWLAZARUS}
   {$IFNDEF RESTDWLAMW}LCL,{$ENDIF}
  {$ENDIF}
  zstream, base64,
 {$ELSE}
  {$IFDEF POSIX}Posix.Unistd,{$ENDIF}
 {$ENDIF}
 SysUtils, DB, Classes,
 zlib, DWDCPrijndael, DWDCPsha256;

Type
 TEncodeSelect          = (esASCII, esUtf8, esANSI);
 TRESTDWAuthOptionTypes = (rdwOATBasic, rdwOATBearer, rdwOATToken);
 TRESTDWAuthOption      = (rdwAONone,   rdwAOBasic,   rdwAOBearer,
                           rdwAOToken,  rdwOAuth);
 TRESTDWTokenType       = (rdwTS,       rdwJWT,       rdwPersonal);
 TRESTDWAuthOptions     = Set of TRESTDWAuthOption;
 TRESTDWCryptType       = (rdwAES256,   rdwHSHA256,   rdwRSA);
 TRESTDWTokenRequest    = (rdwtHeader,  rdwtRequest);

Const
 tScriptsDetected : Array [0..1] of string = ('.map', '.webdwpc');
 TSpecialChars    : Array [0..7] Of Char   = ('\', '"', '/', #8, #9, #10, #12, #13);
 wdays            : Array [1..7] Of String = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'); {do not localize}
 monthnames       : Array [1..12] Of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', {do not localize}
                                               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'); {do not localize}
 GOffsetFromUTC   : TDateTime = 0{$IFDEF HAS_DEPRECATED}deprecated{$ENDIF};

 // controle de versão
 RESTDWVersionINFO               = 'v2.1.0-';
 RESTDWRelease                   = '3857';
 RESTDWCodeProject               = 'Galaga - SourceForge';
 RESTDWVersao                    = RESTDWVersionINFO + RESTDWRelease + '(' + RESTDWCodeProject + ')';
 RESTDWDialogoTitulo             = 'REST DataWare Components ' + RESTDWVersao;
 RESTDWSobreTitulo               = 'REST DataWare '+ RESTDWVersao;
 RESTDWSobreDescricao            = 'https://github.com/OpenSourceCommunityBrasil/REST-DataWare' + sLineBreak +
                                   'Components REST Dataware';
 RESTDWSobreLicencaStatus        = 'Open Source - Free Version';
 RESTDWParamsHeaderVersion       = 6;
 SNotEditing                     = 'Not in Edit mode';
 cRestDWNull                     = #1#1; //Null de Binarios dataset
 ByteBuffer                      = 1024 * 8; //8kb
 CompressBuffer                  = 1024 * 2;
 HoursInDay                      = 24;     {Number of hours in a day}
 LazDigitsSize                   = 6;
 MaxFloatLaz                     = 15;
 MAXSHORT                        = 32767;
 MinutesInDay                    = 1440;   {Number of minutes in a day}
 MinutesInHour                   = 60;     {Number of minutes in an hour}
 SecondsInDay                    = 86400;  {Number of seconds in a day}
 SecondsInHour                   = 3600;   {Number of seconds in an hour}
 SecondsInMinute                 = 60;     {Number of seconds in a minute}
 UnixDate                        = 25569;  {Date1900}
 AssyncCommandMSG                = '{"status":"OK", "assyncmsg":"AssyncCommand Executed"}';
 cApplicationJSON                = 'application/json';
 cAuthenticationError            = 'Error : ' + #13 + 'Authentication Error...';
 cAuthRealm                      = 'WWW-Authenticate: %s realm="%s", %s charset="UTF-8"';
 cBlankStringJSON                = '""';
 cCompressionLevel               = clFastest;
 cCannotReadBuffer               = 'Cannot Read Buffer';
 cCannotWriteBuffer              = 'Cannot Write Buffer';
 cConnectionRename               = 'CONNECTIONRENAME';
 cContentTypeFormUrl             = 'application/x-www-form-urlencoded';
 cContentTypeMultiPart           = 'multipart/form-data';
 cCORSPreflightCODE              = 200;
 cCreatedToken                   = '201 Created';
 cDefaultAccept                  = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
 cDefaultContext                 = 'text/html';
 cDefaultBasicAuthUser           = 'testserver';
 cDefaultBasicAuthPassword       = 'testserver';
 cDefaultContentType             = 'application/json';
 cDefaultContentEncoding         = 'gzip, identity';
 cEmptyDBName                    = 'Empty Database Property';
 cInvalidJSON                    = 'Invalid JSON Object/Array';
 cErrorDatabaseNotFound          = 'Database not found...';
 cErrorDataSetNotDefined         = 'Dataset not defined...';
 cErrorDriverNotSet              = 'Selected pooler does not have a driver set';
 cErrorInvalidFieldBlobValue     = 'Field "%s" Value %s is not a ''Blob'' Value';
 cErrorInvalidFieldDateTimeValue = 'Field "%s" Value %s is not a ''DateTime'' Value';
 cErrorInvalidFieldFloatValue    = 'Field "%s" Value %s is not a ''Real'' Value';
 cErrorInvalidFieldStringValue   = 'Field "%s" Value %s is not a ''String'' Value';
 cErrorInvalidJSONData           = 'Invalid JSON Data...';
 cErrorNoFieldsDataset           = 'No Fields to add on Dataset...';
 cErrorOpenDataset               = 'Error when trying to open Dataset...';
 cErrorParsingJSON               = 'Error on parsing JSON Data...';
 cErrorWriteDataSetNullValue     = 'Cannot write this register.' + #13 + 'Result value is null.';
 cEventNotFound                  = 'HTTP/1.1 404 Url Not Found';
 cExprExpected                   = 'Expression expected but %s found';
 cExprIncorrect                  = 'Incorrectly formed filter expression';
 cFieldNotFound                  = 'Field ''%s'' not found';
 cInvalidAccessTag               = 'Invalid Access tag...';
 cInvalidAuth                    = 'HTTP/1.1 401 Unauthorized';
 cInvalidBlankPooler             = 'Invalid Pooler Name: Pooler field is blank';
 cInvalidBinaryRequest           = 'Invalid Binary Request. Resource unsupported. %s';
 cInvalidBufferPosition          = 'Invalid Buffer Position';
 cInvalidConnection              = 'Invalid connection. The server maybe offline...';
 cInvalidConnectionName          = 'Invalid ConnectionName';
 cInvalidContextName             = 'Invalid Context Name';
 cInvalidContextRule             = 'Invalid ContextRule Name';
 cInvalidCustomFieldName         = 'Invalid Custom Field Name';
 cInvalidDataContext             = 'Invalid Data Context';
 cInvalidDataToApply             = 'No data to "Applyupdates"...';
 cInvalidDriverConnection        = 'CustomConnection undefined on server driver selected';
 cInvalidDWParam                 = 'Invalid RESTDWParam';
 cInvalidDWParams                = 'Invalid RESTDWParams';
 cInvalidEvent                   = 'Invalid Event Name';
 cInvalidFieldName               = 'Invalid Field Name';
 cInvalidInternalError           = 'Internal Server Error';
 cInvalidMessageTo               = 'Invalid Sendmessage %s to user %s, error %s';
 cInvalidParamName               = 'Invalid Param Name';
 cInvalidPoolerName              = 'Invalid Pooler Name...';
 cInvalidRDWServer               = 'Invalid REST Dataware Server...';
 cInvalidRequest                 = 'Invalid request url.';
 cInvalidServerEventName         = 'Invalid ServerEvent name';
 cInvalidStream                  = 'Invalid Stream...';
 cInvalidVirtualMethod           = 'Invalid Virtual Method: %s, proper override method class needed';
 cInvalidWelcomeMessage          = 'Invalid WelcomeMessage param...';
 cIOHandler_MaxCapturedLines     = -1;
 cMaxLineLengthDefault           = 16 * 1024;
 cMessagePartCreate              = 'MessagePart can not be created. Use descendant classes.';
 cMessageDecoderNotFound         = 'Decoder not found';
 cMessageEncoderNotFound         = 'Encoder not found';
 cMethodNotImplemented           = 'Method not implemented...';
 cMIMETypeEmpty                  = 'Mimetype is Empty...';
 cMIMETypeAlreadyExists          = 'Mimetype Already Exists...';
 cMultipleServerEvents           = 'There is more than one ServerEvent.'+ sLineBreak +
                                   'Choose the desired ServerEvent in the ServerEventName property.';
 cNameValueSeparator             = ':';
 cNotWorkYet                     = 'It doesn''''t work yet';
 cNullvalue                      = 'null';
 cNullvalueTag                   = '"null"';
 cParamDetails                   = '%s|%s|%d|%d';
 cParamNotFound                  = 'Param %s not found...';
 cParamsCount                    = 1;
 cPing                           = 'PING';
 cPoolerNotFound                 = 'Pooler not found';
 cPong                           = 'PONG';
 cQuit                           = 'QUIT';
 cRDWDetailField                 = 'rdwdetailfield';
 cRecvBufferSizeDefault          = 32 * 1024;
 cRequestRejectedMethods         = 'Request rejected. Acceptable HTTP methods: ';
 cRequestAcceptableMethods       = 'Acceptable HTTP methods not defined on server';
 cRequestRejected                = 'The request URL was rejected';
 cSendBufferSizeDefault          = 32 * 1024;
 cServerEventNotFound            = 'ServerEvent not found...';
 cServerMethodClassNotAssigned   = 'Property ServerMethodClass not assigned';
 cServerMessage                  = 'SERVERMESSAGE';
 cServerStatusHTML               = '<!DOCTYPE html><html><head><meta charset="UTF-8"/>' +
                                   '<title>REST Dataware '+ RESTDWVersao +
                                   '</title></head><body>'+
                                   '<h2>Server Status - Online</h2>'+
                                   '<h3>Data Engine - %s</h3></body></html>';
 cServerStream                   = 'SERVERSTREAM';
 cSetPhysicDriver                = 'A PhysicDriver is needed to work';
 cStreamReadError                = 'Stream Error %s %s';
 cTablenameTAG                   = 'TABLENAME';
 cTimeoutDefault                 = -1;
 cTokenStringRDWTS               = '{"token":"%s"}';
 cUndefined                      = 'undefined';
 cUserAgent                      = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36';
 cUserMessage                    = 'USERMESSAGE';
 cUserStream                     = 'USERSTREAM';
 cValueKey                       = '{"serverinforequest":"%s", "inforequest":"%s", "lifecycle":"%s"}';
 cValueKeyToken                  = '{"secrets":"%s", "md5":"%s"}';
 cValueToken                     = '{%s"exp":"%s", "iat":"%s", "secrets":"%s"}';
 cValueTokenNoLife               = '{%s"iat":"%s", "secrets":"%s"}';
 cWelcomeUser                    = 'Welcome user %s';
 RESTDWFieldBookmark             = 'DWFIELDBOOKMARK';
 rsLazarusDWPackage              = 'REST Dataware - Tools';
 rsDwRequestDBGName              = 'REST Dataware - Request Debbuger';
 SCorruptedFileHeader            = 'Corrupted File Header';
 SCorruptedDefinitions           = 'Corrupted Table Definitions, or Illegal Login';
 TDatasetRequestJSON             = '{"SQL":"%s", "PARAMS":"%s", "BinaryRequest":%s, "Metadata":%s, "BinaryCompatibleMode":%s}';
 TDecimalChar                    = 'D';
 TFormdataParamName              = 'content-disposition: form-data; name';
 TJsonDatasetHeader              = '{"Field":"%s", "Type":"%s", "Primary":"%s", "Required":"%s", "Size":%d, "Precision":%d, "ReadOnly":"%s", "Autogeneration":"%s"}';
 TJsonStringValue                = '"%s"';
 TJsonValueFormat                = '%s';
 TMassiveFormatJSON              = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":[%s], ' +
                                   '"reflectionchanges":"%s", "sequencename":"%s", "sequencefield":"%s", "mycomptag":"%s", ' +
                                   '"mastercomptag":"%s", "mastercompfields":"%s"}';
 TNullString                     = #0;
 TQuotedValueMemString           = '\"';
 TReplyError                     = '{"MESSAGE":"ERROR", "RESULT":"%s"}';
 TReplyInvalidPooler             = '{"MESSAGE":"ERROR", "RESULT":"Invalid Pooler Name..."}';
 TReplyInvalidWelcome            = '{"MESSAGE":"ERROR", "RESULT":"Invalid welcomemessage..."}';
 TReplyNOK                       = '{"MESSAGE":"FAIL", "RESULT":"FAIL"}';
 TReplyOK                        = '{"MESSAGE":"OK",  "RESULT":"OK"}';
 TReplyTagError                  = '{"MESSAGE":"ERROR", "RESULT":"Invalid Access tag..."}';
// TServerStatusHTMLQX             = '<!DOCTYPE html><html><head><meta charset="UTF-8"/>' +
//                                   '<title>REST Dataware - QuickX</title></head><body>'   +
//                                   '<h1>REST Dataware</h1>'                      +
//                                   '<h2>Server Status - Online</h2></body></html>';
 TSepParams                      = '|xxx|xxx|%';
 TSepValueMemString              = '\\';
 TTagParams                      = '<#%s#>';
 TValueArrayJSON                 = '[%s]';
 TValueDisp                      = '{"PARAMS":[%s], "RESULT":[%s]}';
 TValueFormatJSON                = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":[%s]}';
 TValueFormatJSONValue           = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":%s}';
 TValueFormatJSONValueS          = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s"}';
 UrlBase                         = '%s://%s:%d/%s';
 UrlBaseA                        = '%s://%s:%d%s';
 cBaseRedirect                   = '127.0.0.1';
 Resourcestring
 cBufferIsEmpty                  = 'No bytes in buffer.';
 cBufferRangeError               = 'Index out of bounds.';
 sNoMapString                    = 'No mapping for the Unicode character exists in the target multi-byte code page';
 cBufferMissingTerminator        = 'Buffer terminator must be specified.';
 cBufferInvalidStartPos          = 'Buffer start position is invalid.';
 cCapacityTooSmall               = 'Capacity cannot be smaller than Size.';
 cCharIndexOutOfBounds           = 'Character index out of bounds (%d)';
 cFailedTimeZoneInfo             = 'Failed attempting to retrieve time zone information.';
 cHeaderEncodeError              = 'Could not encode header data using charset "%s"';
 cHeaderDecodeError              = 'Could not decode header data using charset "%s"';
 cInvalidCharCount               = 'Invalid count (%d)';
 cInvalidDestinationIndex        = 'Invalid destination index (%d)';
 cInvalidDestinationArray        = 'Invalid destination array';
 cInvalidSourceArray             = 'Invalid source array';
 cIOHandlerCannotChange          = 'Cannot change a connected IOHandler.';
 cIOHandlerTypeNotInstalled      = 'No IOHandler of type %s is installed.';
 cMessageCannotLoad              = 'Cannot load message from file %s';
 cMessageErrorAttachmentBlocked  = 'Attachment %s is blocked.';
 cMessageErrorSavingAttachment   = 'Error saving attachment.';
 cNotEnoughDataInBuffer          = 'Not enough data in buffer. (%d/%d)';
 cTooMuchDataInBuffer            = 'Too much data in buffer.';
 cReadLnWaitMaxAttemptsExceeded  = 'Max line read attempts exceeded.';
 cReadTimeout                    = 'Read timed out.';
 cErrorOAuthNotImplenented       = 'OAuth authentication is not implemented';

Type
  {$IF DEFINED(HAS_FMX) OR DEFINED(HAS_UTF8)}
    TRESTDWString = String;
  {$ELSE}
    TRESTDWString = AnsiString;
  {$IFEND}

 TDatabaseCharSet     = (csUndefined, csWin1250, csWin1251, csWin1252,
                         csWin1253,   csWin1254, csWin1255, csWin1256,
                         csWin1257,   csWin1258, csUTF8, csISO_8859_1,
                         csISO_8859_2);
 TDataMode            = (dmDataware,  dmRAW);
 TDatasetType         = (dtReflection, dtFull, dtDiff);
 TMassiveMode         = (mmInactive,  mmBrowse, mmInsert, mmUpdate, mmDelete, mmExec);
 TMassiveSQLMode      = (msqlQuery,   msqlExecute);
 TObjectDirection     = (odIN, odOUT, odINOUT);
 TObjectValue         = (ovUnknown,         ovString,       ovSmallint,         ovInteger,    ovWord,                            // 0..4
                         ovBoolean,         ovFloat,        ovCurrency,         ovBCD,        ovDate,      ovTime,    ovDateTime,// 5..11
                         ovBytes,           ovVarBytes,     ovAutoInc,          ovBlob,       ovMemo,      ovGraphic, ovFmtMemo, //12..18
                         ovParadoxOle,      ovDBaseOle,     ovTypedBinary,      ovCursor,     ovFixedChar, ovWideString,         //19..24
                         ovLargeint,        ovADT, ovArray, ovReference,        ovDataSet,    ovOraBlob,   ovOraClob,            //25..31
                         ovVariant,         ovInterface,    ovIDispatch,        ovGuid,       ovTimeStamp, ovFMTBcd,             //32..37
                         ovFixedWideChar,   ovWideMemo,     ovOraTimeStamp,     ovOraInterval,                                   //38..41
                         ovLongWord,        ovShortint,     ovByte, ovExtended, ovConnection, ovParams,    ovStream,             //42..48
                         ovTimeStampOffset, ovObject,       ovSingle);                                                           //49..51
 TRequestMode         = (rtOnlyFields, rtOnlyData, rtJSONAll);
 TRequestType         = (rtGet, rtPost, rtPut, rtPatch, rtDelete, rtOption, rtAll);
 TRESTDWIPVersion     = (Id_IPv4, Id_IPv6);
 TRESTDWJSONType      = (TRESTDWJSONObjectType, TRESTDWJSONArrayType);
 TRESTDWJSONTypes     = Set of TRESTDWJSONType;
 TRESTDWMaxLineAction = (maException, maSplit);
 TRESTDWOSType        = (otUnknown, otUnix, otWindows, otDotNet);
 TRESTDWSSLVersion    = (sslvSSLv2, sslvSSLv23,  sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2);
 TRESTDWSSLVersions   = set of TRESTDWSSLVersion;
 TTypeObject          = (toDataset,   toParam, toMassive, toVariable,  toObject);
 TCaseType            = (ctNone,      ctUpperCase,        ctLowerCase, ctCamelCase);
 TRESTDWRouteData     = (crAll, crGet, crPost, crPut, crPatch, crDelete, crOption);

Type
 TRESTDWChangeActive  = Procedure(aActive    : Boolean;
                                  aRouteData : TRESTDWRouteData) Of Object;
 TRESTDWRoute = Class(TPersistent)
 Private
  vLoadRoute         : TRESTDWRouteData;
  vActive,
  vNeedAuthorization : Boolean;
  vOnChangeActive    : TRESTDWChangeActive;
  Procedure SetActive(aActive : Boolean);
 Public
  Constructor Create(aMethod : TRESTDWRouteData);
  Destructor  Destroy;
  Property    Method         : TRESTDWRouteData    Read vLoadRoute;
  Property OnChangeActive    : TRESTDWChangeActive Read vOnChangeActive    Write vOnChangeActive;
 Published
  Property Active            : Boolean             Read vActive            Write SetActive;
  Property NeedAuthorization : Boolean             Read vNeedAuthorization Write vNeedAuthorization;
End;
 TRESTDWRoutes = Class(TPersistent)
 Private
  vRouteAll,
  vRouteGet,
  vRoutePost,
  vRoutePut,
  vRoutePatch,
  vRouteDelete,
  vRouteOption               : TRESTDWRoute;
  Procedure ChangeActive(aActive    : Boolean;
                         aRouteData : TRESTDWRouteData);
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Function    RouteIsActive         (RequestType       : TRequestType) : Boolean;
  Function    RouteNeedAuthorization(RequestType       : TRequestType) : Boolean;
 Published
  Property All    : TRESTDWRoute Read vRouteAll    Write vRouteAll;
  Property Get    : TRESTDWRoute Read vRouteGet    Write vRouteGet;
  Property Post   : TRESTDWRoute Read vRoutePost   Write vRoutePost;
  Property Put    : TRESTDWRoute Read vRoutePut    Write vRoutePut;
  Property Patch  : TRESTDWRoute Read vRoutePatch  Write vRoutePatch;
  Property Delete : TRESTDWRoute Read vRouteDelete Write vRouteDelete;
  Property Option : TRESTDWRoute Read vRouteOption Write vRouteOption;
 End;


Var
 InitStrPos,
 FinalStrPos                : Integer;
 DecimalLocal : Char;

implementation

{ TRESTDWRoute }

Constructor TRESTDWRoute.Create(aMethod : TRESTDWRouteData);
Begin
 vNeedAuthorization := False;
 vLoadRoute         := aMethod;
 vActive            := aMethod = crAll;
End;

Destructor TRESTDWRoute.Destroy;
Begin
End;

Procedure TRESTDWRoute.SetActive(aActive : Boolean);
Begin
 vActive := aActive;
 If Assigned(vOnChangeActive) Then
  vOnChangeActive(vActive, vLoadRoute);
End;

Procedure TRESTDWRoutes.ChangeActive(aActive    : Boolean;
                                     aRouteData : TRESTDWRouteData);
Begin
 If (aActive)            And
    (aRouteData = crAll) Then
  Begin
   vRouteGet.vActive    := Not aActive;
   vRoutePost.vActive   := vRouteGet.vActive;
   vRoutePut.vActive    := vRouteGet.vActive;
   vRoutePatch.vActive  := vRouteGet.vActive;
   vRouteDelete.vActive := vRouteGet.vActive;
   vRouteOption.vActive := vRouteGet.vActive;
  End
 Else If (aActive) Then
  vRouteAll.vActive := Not aActive;
End;

Constructor TRESTDWRoutes.Create;
Begin
 vRouteAll                   := TRESTDWRoute.Create(crAll);
 vRouteGet                   := TRESTDWRoute.Create(crGet);
 vRoutePost                  := TRESTDWRoute.Create(crPost);
 vRoutePut                   := TRESTDWRoute.Create(crPut);
 vRoutePatch                 := TRESTDWRoute.Create(crPatch);
 vRouteDelete                := TRESTDWRoute.Create(crDelete);
 vRouteOption                := TRESTDWRoute.Create(crOption);
 {$IFDEF FPC}
  vRouteAll.OnChangeActive   := @ChangeActive;
 {$ELSE}
  vRouteAll.OnChangeActive   := ChangeActive;
 {$ENDIF}
 {$IFDEF FPC}
  vRouteGet.OnChangeActive   := @ChangeActive;
 {$ELSE}
  vRouteGet.OnChangeActive   := ChangeActive;
 {$ENDIF}
 {$IFDEF FPC}
  vRoutePost.OnChangeActive  := @ChangeActive;
 {$ELSE}
  vRoutePost.OnChangeActive  := ChangeActive;
 {$ENDIF}
 {$IFDEF FPC}
  vRoutePut.OnChangeActive   := @ChangeActive;
 {$ELSE}
  vRoutePut.OnChangeActive   := ChangeActive;
 {$ENDIF}
 {$IFDEF FPC}
  vRoutePatch.OnChangeActive := @ChangeActive;
 {$ELSE}
  vRoutePatch.OnChangeActive := ChangeActive;
 {$ENDIF}
 {$IFDEF FPC}
  vRouteDelete.OnChangeActive := @ChangeActive;
 {$ELSE}
  vRouteDelete.OnChangeActive := ChangeActive;
 {$ENDIF}
 {$IFDEF FPC}
  vRouteOption.OnChangeActive := @ChangeActive;
 {$ELSE}
  vRouteOption.OnChangeActive := ChangeActive;
 {$ENDIF}
 vRouteAll.Active            := True;
End;

Destructor TRESTDWRoutes.Destroy;
Begin
 FreeAndNil(vRouteAll);
 FreeAndNil(vRouteGet);
 FreeAndNil(vRoutePost);
 FreeAndNil(vRoutePut);
 FreeAndNil(vRoutePatch);
 FreeAndNil(vRouteDelete);
 FreeAndNil(vRouteOption);
End;

Function TRESTDWRoutes.RouteIsActive(RequestType: TRequestType) : Boolean;
Begin
 Result := False;
 Case RequestType Of
  rtGet    : Result := (vRouteGet.vActive)    Or (vRouteAll.vActive);
  rtPost   : Result := (vRoutePost.vActive)   Or (vRouteAll.vActive);
  rtPut    : Result := (vRoutePut.vActive)    Or (vRouteAll.vActive);
  rtPatch  : Result := (vRoutePatch.vActive)  Or (vRouteAll.vActive);
  rtDelete : Result := (vRouteDelete.vActive) Or (vRouteAll.vActive);
  rtOption : Result := (vRouteOption.vActive) Or (vRouteAll.vActive);
 End;
End;

Function TRESTDWRoutes.RouteNeedAuthorization(RequestType : TRequestType) : Boolean;
Begin
 Result := False;
 Case RequestType Of
  rtGet    : Result := ((vRouteGet.vActive)   And (vRouteGet.vNeedAuthorization))   Or
                       ((vRouteAll.vActive)   And (vRouteAll.vNeedAuthorization));
  rtPost   : Result := (vRoutePost.vActive)   And (vRoutePost.vNeedAuthorization)   Or
                       ((vRouteAll.vActive)   And (vRouteAll.vNeedAuthorization));
  rtPut    : Result := (vRoutePut.vActive)    And (vRoutePut.vNeedAuthorization)    Or
                       ((vRouteAll.vActive)   And (vRouteAll.vNeedAuthorization));
  rtPatch  : Result := (vRoutePatch.vActive)  And (vRoutePatch.vNeedAuthorization)  Or
                       ((vRouteAll.vActive)   And (vRouteAll.vNeedAuthorization));
  rtDelete : Result := (vRouteDelete.vActive) And (vRouteDelete.vNeedAuthorization) Or
                       ((vRouteAll.vActive)   And (vRouteAll.vNeedAuthorization));
  rtOption : Result := (vRouteOption.vActive) And (vRouteOption.vNeedAuthorization) Or
                       ((vRouteAll.vActive)   And (vRouteAll.vNeedAuthorization));
 End;
End;

end.
