unit uRESTDWHTTPServer;

interface

{$I Synopse.inc}
// define HASINLINE CPU32 CPU64

Uses
  SysUtils, SynCommons, SynCrtSock, mORMot,
  mORMotHttpServer, uRESTDWAssets;

Type
  TRESTDWOption       = (rdwSAllowCrossOrigin,            rdwSAllowCrossOriginImages,          rdwSAllowCrossOriginFonts,
                         rdwSAllowCrossOriginTiming,      rdwSDelegateBadRequestTo404,         rdwSDelegateUnauthorizedTo404,
                         rdwSDelegateForbiddenTo404,      rdwSDelegateNotFoundTo404,           rdwSDelegateNotAllowedTo404,
                         rdwSDelegateNotAcceptableTo404,  rdwSSetXUACompatible,                rdwSForceMIMEType,
                         rdwSForceTextUTF8Charset,        rdwSForceUTF8Charset,                rdwSForceHTTPS,
                         rdwSForceHTTPSExceptLetsEncrypt, rdwSSetXFrameOptions,                rdwSDelegateHidden,
                         rdwSDelegateBlocked,             rdwSPreventMIMESniffing,             rdwSEnableXSSFilter,
                         rdwSEnableReferrerPolicy,        rdwSDisableTRACEMethod,              rdwSDeleteXPoweredBy,
                         rdwSFixMangledAcceptEncoding,    rdwSForceGZipHeader,                 rdwSSetCachePublic,
                         rdwSSetCachePrivate,             rdwSSetCacheNoTransform,             rdwSSetCacheNoCache,
                         rdwSSetCacheNoStore,             rdwSSetCacheMustRevalidate,          rdwSSetCacheMaxAge,
                         rdwSEnableCacheByETag,           rdwSEnableCacheByLastModified,       rdwSSetExpires,
                         rdwSEnableCacheBusting,          rdwSEnableCacheBustingBeforeExt,     rdwSDelegateRootToIndex,
                         rdwSDeleteServerInternalState,   rdwSDelegateIndexToInheritedDefault, rdwSDelegate404ToInherited_404,
                         rdwSVaryAcceptEncoding);
  TRESTDWOptions      = Set Of TRESTDWOption;
  TWWWRewrite         = (wwwOff, wwwSuppress, wwwForce);
  TStrictSSL          = (strictSSLOff, strictSSLOn, strictSSLIncludeSubDomains, strictSSLIncludeSubDomainsPreload);
  TDNSPrefetchControl = (dnsPrefetchNone, dnsPrefetchOff, dnsPrefetchOn);

Type
  TRESTDWHTTPServer = class(TSQLHttpServer)
  Protected
    FAssets: TAssets;
    FOptions: TRESTDWOptions;
    FContentSecurityPolicy: SockString;
    FContentSecurityPolicyReportOnly: SockString;
    FStrictSSL: TStrictSSL;
    FReferrerPolicy: SockString;
    FReferrerPolicyContentTypes: SockString;
    FReferrerPolicyContentTypesUpArray: TSockStringDynArray;
    FWWWRewrite: TWWWRewrite;
    FDNSPrefetchControl: TDNSPrefetchControl;
    FDNSPrefetchControlContentTypes: SockString;
    FDNSPrefetchControlContentTypesUpArray: TSockStringDynArray;
    FFileTypesImage: SockString;
    FFileTypesImageUpArray: TSockStringDynArray;
    FFileTypesFont: SockString;
    FFileTypesFontUpArray: TSockStringDynArray;
    FForceMIMETypesValues: TSynNameValue;
    FFileTypesRequiredCharSet: SockString;
    FFileTypesRequiredCharSetUpArray: TSockStringDynArray;
    FFileTypesBlocked: SockString;
    FFileTypesBlockedUpArray: TSockStringDynArray;
    FMangledEncodingHeaders: SockString;
    FMangledEncodingHeadersUpArray: TSockStringDynArray;
    FMangledEncodingHeaderValues: SockString;
    FMangledEncodingHeaderValuesUpArray: TSockStringDynArray;
    FFileTypesForceGZipHeader: SockString;
    FFileTypesForceGZipHeaderUpArray: TSockStringDynArray;
    FExpires: SockString;
    FExpiresDefault: PtrInt;
    FExpiresValues: TSynNameValue;
    FStaticRoot: TFileName;
    FCustomOptions: TSynNameValue;
    FCustomOptionPrefixes: TSynNameValue;
    Procedure Init; virtual;
    Procedure SplitURL(Const URL : SockString;
                       Var Path,
                       ExtUp     : SockString;
                       Const EnableCacheBusting,
                       EnableCacheBustingBeforeExt : Boolean);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure UpArrayFromCSV(Const CSV       : SockString;
                             Var Values      : TSockStringDynArray;
                             Const PrefixUp  : SockString = '';
                             Const PostfixUp : SockString = '';
                             Const Sep       : AnsiChar   = ',');{$IFDEF HASINLINE}Inline; {$ENDIF}
    Function InArray        (Const UpValue   : SockString;
                             Const UpValues  : TSockStringDynArray): Boolean;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function ExtractCustomHeader(Const Headers,
                                 NameUp      : SockString;
                                 Out Value   : SockString) : SockString;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function GetCustomHeader(Const Headers   : SockString;
                             Const NameUp    : SockString) : SockString;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure AddCustomHeader(Context        : THttpServerRequest;
                              Const Name,
                              Value          : SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function DeleteCustomHeader(Context      : THttpServerRequest;
                                Const NameUp : SockString): SockString;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure GetAcceptedEncodings(Context   : THttpServerRequest;
                                   Const FixMangled : Boolean;
                                   Var GZipAccepted,
                                   RESTDWAccepted   : Boolean);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function WasModified       (Context      : THttpServerRequest;
                                Asset        : PAsset;
                                Const Encoding : TAssetEncoding;
                                Const CheckETag,
                                CheckModified  : Boolean): Boolean;
    Function ExpiresToSecs     (Const Value    : RawUTF8): PtrInt;{$IFNDEF VER180}{$IFDEF HASINLINE}Inline;{$ENDIF}{$ENDIF}
    Function GetExpires        (Const ContentTypeUp: SockString): PtrInt;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function GetContentTypeUp  (Const Value        : SockString): SockString;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function FindCustomOptions (Const URLPath      : RawUTF8;
                                Const Default      : TRESTDWOptions) : TRESTDWOptions;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function ContainsHiddenExceptWellKnown(Const Path: SockString): Boolean;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Function IsBlockedPathOrExt(Const Path, ExtUp: SockString): Boolean;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure InitForceMIMETypesValues;{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetReferrerPolicyContentTypes(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetDNSPrefetchControlContentTypes(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetFileTypesImage(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetFileTypesFont (Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetFileTypesRequiredCharSet(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetFileTypesBlocked(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetMangledEncodingHeaders(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetMangledEncodingHeaderValues(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetFileTypesForceGZipHeader(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
    Procedure SetExpires(Const Value: SockString);{$IFDEF HASINLINE}Inline;{$ENDIF}
  Protected
    Function Request(Context: THttpServerRequest): Cardinal; override;
  Private
   fOnRequest : TOnHttpServerRequest;
  Public
   Constructor Create(Const aPort           : AnsiString;
                      Const aServers        : Array Of TSQLRestServer;
                      Const aDomainName     : AnsiString = '+';
                      aHttpServerKind       : TSQLHttpServerOptions = HTTP_DEFAULT_MODE;
                      ServerThreadPoolCount : Integer = 32;
                      aHttpServerSecurity   : TSQLHttpServerSecurity = secNone;
                      Const aAdditionalURL  : AnsiString = '';
                      Const aQueueName      : SynUnicode = '');Overload;
   Constructor Create(Const aPort           : AnsiString;
                      aServer               : TSQLRestServer;
                      Const aDomainName     : AnsiString = '+';
                      aHttpServerKind       : TSQLHttpServerOptions = HTTP_DEFAULT_MODE;
                      aRestAccessRights     : PSQLAccessRights = nil;
                      ServerThreadPoolCount : Integer = 32;
                      aHttpServerSecurity   : TSQLHttpServerSecurity = secNone;
                      Const aAdditionalURL  : AnsiString = '';
                      Const aQueueName      : SynUnicode = '');Overload;
   Constructor Create(aServer               : TSQLRestServer;
                      aDefinition           : TSQLHttpServerDefinition);Overload;
  Public
   Procedure LoadFromResource     (Const ResName            : String);{$IFDEF HASINLINE}Inline;{$ENDIF}
   Procedure RegisterCustomOptions(Const URLPath            : RawUTF8;
                                   Const CustomOptions      : TRESTDWOptions);Overload;{$IFDEF HASINLINE}Inline;{$ENDIF}
   Procedure RegisterCustomOptions(Const URLParts           : TRawUTF8DynArray;
                                   CustomOptions            : TRESTDWOptions);Overload;{$IFDEF HASINLINE}Inline;{$ENDIF}
   Procedure SetOnRequest         (Const aRequest           : TOnHttpServerRequest);
   Procedure UnregisterCustomOptions(Const URLPath          : RawUTF8);Overload;{$IFDEF HASINLINE}Inline;{$ENDIF}
   Procedure UnregisterCustomOptions(Const URLPaths         : TRawUTF8DynArray);Overload;{$IFDEF HASINLINE}Inline;{$ENDIF}
   Procedure SetForceMIMETypes      (Const ExtMIMETypePairs : TRawUTF8DynArray);{$IFDEF HASINLINE}Inline;{$ENDIF}
   Property  StaticRoot                    : TFileName            Read FStaticRoot                      Write FStaticRoot;
   Property  Options                       : TRESTDWOptions       Read FOptions                         Write FOptions;
   Property StrictSSL                      : TStrictSSL           Read FStrictSSL                       Write FStrictSSL;
   Property WWWRewrite                     : TWWWRewrite          Read FWWWRewrite                      Write FWWWRewrite;
   Property DNSPrefetchControl             : TDNSPrefetchControl  Read FDNSPrefetchControl              Write FDNSPrefetchControl;
   Property DNSPrefetchControlContentTypes : SockString           Read FDNSPrefetchControlContentTypes  Write SetDNSPrefetchControlContentTypes;
   Property ContentSecurityPolicy          : SockString           Read FContentSecurityPolicy           Write FContentSecurityPolicy;
   Property ContentSecurityPolicyReportOnly: SockString           Read FContentSecurityPolicyReportOnly Write FContentSecurityPolicyReportOnly;
   Property ReferrerPolicy                 : SockString           Read FReferrerPolicy                  Write FReferrerPolicy;
   Property ReferrerPolicyContentTypes     : SockString           Read FReferrerPolicyContentTypes      Write SetReferrerPolicyContentTypes;
   Property FileTypesImage                 : SockString           Read FFileTypesImage                  Write SetFileTypesImage;
   Property FileTypesFont                  : SockString           Read FFileTypesFont                   Write SetFileTypesFont;
   Property FileTypesRequiredCharSet       : SockString           Read FFileTypesRequiredCharSet        Write SetFileTypesRequiredCharSet;
   Property FileTypesForceGZipHeader       : SockString           Read FFileTypesForceGZipHeader        Write SetFileTypesForceGZipHeader;
   Property FileTypesBlocked               : SockString           Read FFileTypesBlocked                Write SetFileTypesBlocked;
   Property MangledEncodingHeaders         : SockString           Read FMangledEncodingHeaders          Write SetMangledEncodingHeaders;
   Property MangledEncodingHeaderValues    : SockString           Read FMangledEncodingHeaderValues     Write SetMangledEncodingHeaderValues;
   Property Expires                        : SockString           Read FExpires                         Write SetExpires;
   Property OnRequest                      : TOnHttpServerRequest Read fOnRequest                       Write SetOnRequest;
  End;

Const
  DEFAULT_RESTDW_OPTIONS : TRESTDWOptions = [rdwSAllowCrossOriginImages,    rdwSAllowCrossOriginFonts,      rdwSDelegateBadRequestTo404,
                                             rdwSDelegateUnauthorizedTo404, rdwSDelegateForbiddenTo404,     rdwSDelegateNotFoundTo404,
                                             rdwSDelegateNotAllowedTo404,   rdwSDelegateNotAcceptableTo404, rdwSSetXUACompatible,
                                             rdwSForceMIMEType,             rdwSForceTextUTF8Charset,       rdwSForceUTF8Charset,
                                             rdwSDelegateHidden,            rdwSDelegateBlocked,            rdwSPreventMIMESniffing,
                                             rdwSDeleteXPoweredBy,          rdwSFixMangledAcceptEncoding,   rdwSForceGZipHeader,
                                             rdwSSetCachePublic,            rdwSSetCacheMaxAge,             rdwSEnableCacheByLastModified,
                                             rdwSSetExpires,                rdwSDelegateRootToIndex,        rdwSDeleteServerInternalState,
                                             rdwSVaryAcceptEncoding];
  DEFAULT_WWW_REWRITE          : TWWWRewrite         = wwwSuppress;
  DEFAULT_STRICT_SLL           : TStrictSSL          = strictSSLOff;
  DEFAULT_DNS_PREFETCH_CONTROL : TDNSPrefetchControl = dnsPrefetchOn;
  DEFAULT_DNS_PREFETCH_CONTROL_CONTENT_TYPES         = 'text/css,text/html,text/javascript';
  DEFAULT_CONTENT_SECURITY_POLICY : SockString       = '';
  DEFAULT_CONTENT_SECURITY_POLICY_REPORT_ONLY : SockString = '';
  CONTENT_SECURITY_POLICY_STRICT        = 'default-src ''self''; base-uri ''none''; form-action ''self''; ' +
                                          'frame-ancestors ''none''; upgrade-insecure-requests';
  DEFAULT_REFERRER_POLICY : SockString  = 'strict-origin-when-cross-origin';
  DEFAULT_REFERRER_POLICY_CONTENT_TYPES = 'text/css,text/html,text/javascript,application/pdf,application/xml';
  DEFAULT_FILE_TYPES_IMAGE              = 'bmp,cur,gif,ico,jpg,jpeg,png,apng,svg,svgz,webp';
  DEFAULT_FILE_TYPES_FONT               = 'eot,otf,ttc,ttf,woff,woff2';
  DEFAULT_FILE_TYPES_REQUIRED_CHARSET   = 'appcache,bbaw,css,htc,ics,js,json,manifest,map,markdown,md,mjs,' +
                                          'topojson,vtt,vcard,vcf,webmanifest,xloc';
  DEFAULT_FILE_TYPES_FORCE_GZIP_HEADER  = 'svgz';
  DEFAULT_FILE_TYPES_BLOCKED            = 'bak,conf,dist,fla,inc,ini,log,orig,psd,sh,sql,swo,swp';
  DEFAULT_MANGLED_ENCODING_HEADERS      = 'Accept-EncodXng,X-cept-Encoding,XXXXXXXXXXXXXXX,~~~~~~~~~~~~~~~,' +
                                          '---------------';
  DEFAULT_MANGLED_ENCODING_HEADER_VALUES = 'gzip|deflate|gzip,deflate|' +
                                           'deflate,gzip|XXXX|XXXXX|XXXXXX|XXXXXXX|XXXXXXXX|XXXXXXXXX|XXXXXXXXXX|' +
                                           'XXXXXXXXXXX|XXXXXXXXXXXX|XXXXXXXXXXXXX|~~~~|~~~~~|~~~~~~|~~~~~~~|' +
                                           '~~~~~~~~|~~~~~~~~~|~~~~~~~~~~|~~~~~~~~~~~|~~~~~~~~~~~~|~~~~~~~~~~~~~|' +
                                           '----|-----|------|-------|--------|---------|----------|-----------|' +
                                           '------------|-------------';
  DEFAULT_EXPIRES = '*=1m'#10 +
                    'text/css=1y'#10 +
                    'application/atom+xml=1h'#10 +
                    'application/rdf+xml=1h'#10 +
                    'application/rss+xml=1h'#10 +
                    'application/json=0s'#10 +
                    'application/ld+json=0s'#10 +
                    'application/schema+json=0s'#10 +
                    'application/geo+json=0s'#10 +
                    'application/xml=0s'#10 +
                    'text/calendar=0s'#10 +
                    'text/xml=0s'#10 +
                    'image/vnd.microsoft.icon=1w'#10 +
                    'image/x-icon=1w'#10 +
                    'text/html=0s'#10 +
                    'application/javascript=1y'#10 +
                    'application/x-javascript=1y'#10 +
                    'text/javascript=1y'#10 +
                    'application/manifest+json=1w'#10 +
                    'application/x-web-app-manifest+json=0s'#10 +
                    'text/cache-manifest=0s'#10 +
                    'text/markdown=0s'#10 +
                    'audio/ogg=1m'#10 +
                    'image/apng=1m'#10 +
                    'image/bmp=1m'#10 +
                    'image/gif=1m'#10 +
                    'image/jpeg=1m'#10 +
                    'image/png=1m'#10 +
                    'image/svg+xml=1m'#10 +
                    'image/webp=1m'#10 +
                    'video/mp4=1m'#10 +
                    'video/ogg=1m'#10 +
                    'video/webm=1m'#10 +
                    'application/wasm=1y'#10 +
                    'font/collection=1m'#10 +
                    'application/vnd.ms-fontobject=1m'#10 +
                    'font/eot=1m'#10 +
                    'font/opentype=1m'#10 +
                    'font/otf=1m'#10 +
                    'application/x-font-ttf=1m'#10 +
                    'font/ttf=1m'#10 +
                    'application/font-woff=1m'#10 +
                    'application/x-font-woff=1m'#10 +
                    'font/woff=1m'#10 +
                    'application/font-woff2=1m'#10 +
                    'application/woff2=1m'#10 +
                    'text/x-cross-domain-policy=1w'#10 +'';

Implementation

{$IF DEFINED(FPC) OR (CompilerVersion < 20)}
Const
 HoursPerDay = 24;
 MinsPerHour = 60;
 SecsPerMin  = 60;
 MinsPerDay  = HoursPerDay * MinsPerHour;
 SecsPerDay  = MinsPerDay * SecsPerMin;
 SecsPerHour = SecsPerMin * MinsPerHour;
{$IFEND}

Function IdemPCharUp(P : PByteArray; Up: PByte): Boolean;{$IFDEF HASINLINE}Inline;{$ENDIF}
Var
 U : Byte;
Begin
 If P = Nil Then
  Begin
   Result := False;
   Exit;
  End
 Else If Up = Nil Then
  Begin
   Result := True;
   Exit
  End
 Else
  Begin
   Dec(PtrUInt(P), PtrUInt(Up));
   Repeat
    U := Up^;
    If U = 0 Then Break;
    If PByteArray(@NormToUpper)[P[PtrUInt(Up)]] <> U Then
     Begin
      Result := False;
      Exit;
     End;
    Inc(Up);
   Until False;
   Result := True;
  End;
End;

Function TrimCopy(Const S : SockString;
                  Start,
                  Count   : PtrInt): SockString;{$IFDEF HASINLINE}Inline;{$ENDIF}
Var
 L : PtrInt;
Begin
 If Count <= 0 Then
  Begin
   Result := '';
   Exit;
  End;
 If Start <= 0 Then
  Start := 1;
 L := Length(S);
 While (Start <= L) And (S[Start] <= ' ') Do
  Begin
   Inc(Start);
   Dec(Count);
  End;
 Dec(Start);
 Dec(L, Start);
 If Count < L Then
  L := Count;
 While L > 0 Do
  Begin
   If S[Start + L] <= ' ' Then
    Dec(L)
   Else
    Break;
  End;
 If L > 0 Then
  SetString(Result, PAnsiChar(@PByteArray(S)[Start]), L)
 Else
  Result := '';
End;

Procedure TRESTDWHTTPServer.AddCustomHeader(Context    : THttpServerRequest;
                                            Const Name,
                                            Value      : SockString);
Begin
 If Context.OutCustomHeaders <> '' Then
  Context.OutCustomHeaders := FormatUTF8('%'#$D#$A'%: %', [Context.OutCustomHeaders, Name, Value])
 Else
  Context.OutCustomHeaders := FormatUTF8('%: %', [Name, Value])
End;

Function TRESTDWHTTPServer.DeleteCustomHeader(Context      : THttpServerRequest;
                                              Const NameUp : SockString) : SockString;
Begin
 Context.OutCustomHeaders := ExtractCustomHeader(Context.OutCustomHeaders, NameUp, Result);
End;

Function TRESTDWHTTPServer.ExpiresToSecs(Const Value: RawUTF8): PtrInt;
Const
 SecsPerWeek = 7 * SecsPerDay;
 SecsPerMonth = 2629746; // SecsPerDay * 365.2425 / 12
 SecsPerYear = 12 * SecsPerMonth;
Var
 P   : PUTF8Char;
 Len : Integer;
Begin
 If Value = '' Then
  Begin
   Result := 0;
   Exit;
  End;
 P := Pointer(Value);
 Len := Length(Value);
 Case Value[Len] Of
  'S', 's': Result := GetInteger(P, P + Len);
  'H', 'h': Result := SecsPerHour  * GetInteger(P, P + Len);
  'D', 'd': Result := SecsPerDay   * GetInteger(P, P + Len);
  'W', 'w': Result := SecsPerWeek  * GetInteger(P, P + Len);
  'M', 'm': Result := SecsPerMonth * GetInteger(P, P + Len);
  'Y', 'y': Result := SecsPerYear  * GetInteger(P, P + Len);
  Else
   Result := GetInteger(P, P + Len + 1);
 End;
End;

Function TRESTDWHTTPServer.ExtractCustomHeader(Const Headers,
                                               NameUp         : SockString;
                                               Out Value      : SockString) : SockString;
Var
 I, J, K: PtrInt;
Begin
 Result := Headers;
 If (Result = '') or (NameUp = '') Then Exit;
 I := 1;
 Repeat
  K := Length(Result) + 1;
  For J := I To K - 1 Do
   Begin
    If Result[J] < ' ' Then
     Begin
      K := J;
      Break;
     End;
   End;
  If IdemPCharUp(@PByteArray(Result)[I - 1], Pointer(NameUp)) Then
   Begin
    J := I;
    Inc(I, Length(NameUp));
    Value := TrimCopy(Result, I, K - I);
    While True Do
     Begin
      If (Result[K] = #0) or (Result[K] >= ' ') Then
       Break
      Else
       Inc(K);
     End;
    Delete(Result, J, K - J);
    Exit;
   End;
  I := K;
  While Result[I] < ' ' Do
   Begin
    If Result[I] = #0 Then
     Exit
    Else
     Inc(I);
   End;
 Until False;
End;

Function TRESTDWHTTPServer.InArray(Const UpValue  : SockString;
                                   Const UpValues : TSockStringDynArray) : Boolean;
Begin
 Result := FastFindPUTF8CharSorted(Pointer(UpValues), High(UpValues), Pointer(UpValue)) >= 0;
End;

Function TRESTDWHTTPServer.FindCustomOptions(Const URLPath : RawUTF8;
                                             Const Default : TRESTDWOptions) : TRESTDWOptions;
Var
 Index : Integer;
 Function FindPrefix(Const Prefixes : TSynNameValue;
                     Const UpperURL : RawUTF8) : Integer;{$IFDEF HASINLINE}Inline;{$ENDIF}
 Begin
  For Result := 0 To Prefixes.Count - 1 Do
   If IdemPChar(Pointer(UpperURL), Pointer(Prefixes.List[Result].Name)) Then
    Exit;
  Result := -1;
 End;
 Function StrToOptions(Const Str: RawUTF8): TRESTDWOptions;{$IFDEF HASINLINE}Inline;{$ENDIF}
 Begin
  MoveFast(Str[1], Result, SizeOf(Result));
 End;
Begin
 Index := FCustomOptions.Find(URLPath);
 If Index >= 0 Then
  Begin
   Result := StrToOptions(FCustomOptions.List[Index].Value);
   Exit;
  End;
 Index := FindPrefix(FCustomOptionPrefixes, UpperCase(URLPath));
 If Index >= 0 Then
  Begin
   Result := StrToOptions(FCustomOptionPrefixes.List[Index].Value);
   Exit;
  End;
 Result := Default;
End;

Function TRESTDWHTTPServer.GetExpires(Const ContentTypeUp: SockString): PtrInt;
Begin
 Result := FExpiresValues.Find(ContentTypeUp);
 If Result >= 0 Then
  Result := FExpiresValues.List[Result].Tag
 Else
  Result := FExpiresDefault;
End;

Function TRESTDWHTTPServer.GetContentTypeUp(Const Value: SockString): SockString;
Var
 Index, Len: Integer;
 Found: Boolean;
Begin
 If Value = '' Then
  Begin
   Result := '';
   Exit;
  End;
 Found := False;
 Len := Length(Value);
 For Index := 1 To Len Do
  Begin
   If Value[Index] = ';' Then
    Begin
     Len := Index - 1;
     SetString(Result, PAnsiChar(Pointer(Value)), Len);
     Found := True;
     Break;
    End;
  End;
 If Not Found Then
  SetString(Result, PAnsiChar(Pointer(Value)), Len);
 For Index := 0 To Len - 1 Do
  Begin
   If PByteArray(Result)[Index] in [Ord('a')..Ord('z')] Then
    Dec(PByteArray(Result)[Index], $20);
  End;
End;

Function TRESTDWHTTPServer.GetCustomHeader(Const Headers,
                                           NameUp         : SockString) : SockString;
Var
 I, J, K: PtrInt;
Begin
 Result := '';
 If (Headers = '') or (NameUp = '') Then Exit;
 I := 1;
 Repeat
  K := Length(Headers) + 1;
  For J := I To K - 1 Do
   Begin
    If Headers[J] < ' ' Then
     Begin
      K := J;
      Break;
     End;
   End;
  If IdemPCharUp(@PByteArray(Headers)[I - 1], Pointer(NameUp)) Then
   Begin
    Inc(I, Length(NameUp));
    Result := TrimCopy(Headers, I, K - I);
    Exit;
   End;
  I := K;
  While Headers[I] < ' ' Do
   Begin
    If Headers[I] = #0 Then
     Exit
    Else
     Inc(I);
   End;
 Until False;
End;

Function TRESTDWHTTPServer.ContainsHiddenExceptWellKnown(Const Path: SockString): Boolean;
  Function HiddenPos(Const Path  : SockString;
                     Const Index : Integer = 1) : Integer;{$IFDEF HASINLINE}Inline;{$ENDIF}
  Begin
   For Result := Index To Length(Path) - 1 Do
    If (Path[Result] = '/') and (Path[Result + 1] = '.') Then Exit;
   Result := 0;
  End;
Begin
 If Path = '' Then
  Begin
   Result := False;
   Exit;
  End;
 If IdemPCharUp(Pointer(Path), Pointer(PAnsiChar('.WELL-KNOWN/'))) and
    (HiddenPos(Path, 12) = 0) Then
  Begin
   Result := False;
   Exit;
  End;
 If IdemPCharUp(Pointer(Path), Pointer(PAnsiChar('/.WELL-KNOWN/'))) and
    (HiddenPos(Path, 13) = 0) Then
  Begin
   Result := False;
   Exit;
  End;
 Result := (Path[1] = '.') or (HiddenPos(Path) > 0);
End;

Constructor TRESTDWHTTPServer.Create(aServer     : TSQLRestServer;
                                     aDefinition : TSQLHttpServerDefinition);
Begin
 Inherited Create(aServer, aDefinition);
 Init;
End;

Constructor TRESTDWHTTPServer.Create(Const aPort           : AnsiString;
                                     Const aServers        : Array Of TSQLRestServer;
                                     Const aDomainName     : AnsiString;
                                     aHttpServerKind       : TSQLHttpServerOptions;
                                     ServerThreadPoolCount : Integer;
                                     aHttpServerSecurity   : TSQLHttpServerSecurity; Const aAdditionalURL: AnsiString;
                                     Const aQueueName      : SynUnicode);
Begin
 Inherited Create(aPort, aServers, aDomainName, aHttpServerKind,
                  ServerThreadPoolCount, aHttpServerSecurity, aAdditionalURL, aQueueName);
 Init;
End;

Constructor TRESTDWHTTPServer.Create(Const aPort           : AnsiString;
                                     aServer               : TSQLRestServer;
                                     Const aDomainName     : AnsiString;
                                     aHttpServerKind       : TSQLHttpServerOptions;
                                     aRestAccessRights     : PSQLAccessRights;
                                     ServerThreadPoolCount : Integer;
                                     aHttpServerSecurity   : TSQLHttpServerSecurity;
                                     Const aAdditionalURL  : AnsiString;
                                     Const aQueueName      : SynUnicode);
Begin
 Inherited Create(aPort, aServer, aDomainName, aHttpServerKind,
                  aRestAccessRights, ServerThreadPoolCount, aHttpServerSecurity,
                  aAdditionalURL, aQueueName);
 Init;
End;

Procedure TRESTDWHTTPServer.Init;
Begin
 FAssets.Init;
 FOptions                         := DEFAULT_RESTDW_OPTIONS;
 FContentSecurityPolicy           := DEFAULT_CONTENT_SECURITY_POLICY;
 FContentSecurityPolicyReportOnly := DEFAULT_CONTENT_SECURITY_POLICY_REPORT_ONLY;
 FStrictSSL                       := DEFAULT_STRICT_SLL;
 FReferrerPolicy                  := DEFAULT_REFERRER_POLICY;
 SetReferrerPolicyContentTypes(DEFAULT_REFERRER_POLICY_CONTENT_TYPES);
 FWWWRewrite                      := DEFAULT_WWW_REWRITE;
 FDNSPrefetchControl              := DEFAULT_DNS_PREFETCH_CONTROL;
 SetDNSPrefetchControlContentTypes(DEFAULT_DNS_PREFETCH_CONTROL_CONTENT_TYPES);
 SetFileTypesImage(DEFAULT_FILE_TYPES_IMAGE);
 SetFileTypesFont(DEFAULT_FILE_TYPES_FONT);
 SetFileTypesRequiredCharSet(DEFAULT_FILE_TYPES_REQUIRED_CHARSET);
 SetFileTypesBlocked(DEFAULT_FILE_TYPES_BLOCKED);
 SetMangledEncodingHeaders(DEFAULT_MANGLED_ENCODING_HEADERS);
 SetMangledEncodingHeaderValues(DEFAULT_MANGLED_ENCODING_HEADER_VALUES);
 SetFileTypesForceGZipHeader(DEFAULT_FILE_TYPES_FORCE_GZIP_HEADER);
 SetExpires(DEFAULT_EXPIRES);
 FCustomOptions.Init(False);
 FCustomOptionPrefixes.Init(False);
 InitForceMIMETypesValues;
End;

Procedure TRESTDWHTTPServer.InitForceMIMETypesValues;
Var
 Index : Integer;
Begin
 FForceMIMETypesValues.Init(False);
 For Index := 0 To Length(MIME_TYPES_FILE_EXTENSIONS) shr 1 - 1 Do
  FForceMIMETypesValues.Add(MIME_TYPES_FILE_EXTENSIONS[Index shl 1 + 1], MIME_TYPES_FILE_EXTENSIONS[Index shl 1]);
End;

Function TRESTDWHTTPServer.IsBlockedPathOrExt(Const Path, ExtUp: SockString): Boolean;
Begin
 Result := InArray(ExtUp, FFileTypesBlockedUpArray) or ((Path <> '') And
                  (PByteArray(Path)[Length(Path) - 1] in [Ord('~'), Ord('#')]));
End;

Function TRESTDWHTTPServer.WasModified(Context        : THttpServerRequest;
                                       Asset          : PAsset;
                                       Const Encoding : TAssetEncoding;
                                       Const CheckETag,
                                       CheckModified  : Boolean) : Boolean;
Const
 SERVER_HASH: RawUTF8 = '"00000000"';
Var
 ClientHash,
 ServerHash,
 ClientModified,
 ServerModified: RawUTF8;
Begin
 Result := Not (CheckETag or CheckModified);
 If Not Result And CheckETag Then
  Begin
   FastSetString(ServerHash, PRawUTF8(SERVER_HASH), Length(SERVER_HASH));
   If Encoding = aeIdentity Then
    BinToHexDisplay(@Asset.ContentHash, Pointer(@ServerHash[2]), SizeOf(Cardinal))
   Else If Encoding = aeGZip Then
    BinToHexDisplay(@Asset.GZipHash, Pointer(@ServerHash[2]), SizeOf(Cardinal))
   Else If Encoding = aeRESTDW Then
    BinToHexDisplay(@Asset.RESTDWHash, Pointer(@ServerHash[2]), SizeOf(Cardinal));
   ClientHash := GetCustomHeader(Context.InHeaders, 'IF-NONE-MATCH:');
   Result := ClientHash <> ServerHash;
   If Result Then
    Context.OutCustomHeaders := FormatUTF8('%ETag: %'#$D#$A, [Context.OutCustomHeaders, ServerHash]);
  End;
 If Not Result And CheckModified Then
  Begin
   ServerModified := DateTimeToHTTPDate(Asset.Timestamp);
   ClientModified := GetCustomHeader(Context.InHeaders, 'IF-MODIFIED-SINCE:');
   Result := (ClientModified = '') Or (StrIComp(Pointer(ClientModified), Pointer(ServerModified)) <> 0);
   If Result Then
    Context.OutCustomHeaders := FormatUTF8('%Last-Modified: %'#$D#$A, [Context.OutCustomHeaders, ServerModified]);
  End;
End;

Procedure TRESTDWHTTPServer.GetAcceptedEncodings(Context          : THttpServerRequest;
                                                 Const FixMangled : Boolean;
                                                 Var GZipAccepted,
                                                 RESTDWAccepted   : Boolean);
Var
 AcceptEncoding : RawUTF8;
 Index          : Integer;
Begin
 AcceptEncoding := GetCustomHeader(Context.InHeaders, 'ACCEPT-ENCODING:');
 UpperCaseSelf(AcceptEncoding);
 GZipAccepted := PosEx('GZIP', AcceptEncoding) > 0;
 RESTDWAccepted := PosEx('BR', AcceptEncoding) > 0;
 If GZipAccepted Or RESTDWAccepted Or Not FixMangled Then Exit;
 For Index := Low(FMangledEncodingHeadersUpArray) To High(FMangledEncodingHeadersUpArray) Do
  Begin
   AcceptEncoding := GetCustomHeader(Context.InHeaders, FMangledEncodingHeadersUpArray[Index]);
   If AcceptEncoding = '' Then Continue;
   UpperCaseSelf(AcceptEncoding);
   GZipAccepted := InArray(AcceptEncoding, FMangledEncodingHeaderValuesUpArray);
   If GZipAccepted Then Break;
  End;
End;

Procedure TRESTDWHTTPServer.LoadFromResource(Const ResName: string);
Begin
 FAssets.LoadFromResource(ResName);
End;

Procedure TRESTDWHTTPServer.RegisterCustomOptions(Const URLPath       : RawUTF8;
                                                  Const CustomOptions : TRESTDWOptions);
  Function GetOptionsValue(Const CustomOptions: TRESTDWOptions): RawUTF8;{$IFDEF HASINLINE}Inline;{$ENDIF}
  Begin
   SetLength(Result, SizeOf(CustomOptions));
   MoveFast(CustomOptions, Result[1], SizeOf(CustomOptions));
  End;
Begin
 If Copy(URLPath, Length(URLPath), 1) = '*' Then
  FCustomOptionPrefixes.Add(UpperCase(Copy(URLPath, 1, Length(URLPath) - 1)), GetOptionsValue(CustomOptions))
 Else
  FCustomOptions.Add(URLPath, GetOptionsValue(CustomOptions));
End;

Procedure TRESTDWHTTPServer.SetOnRequest(Const aRequest: TOnHttpServerRequest);
Begin
 fOnRequest := aRequest;
End;

Procedure TRESTDWHTTPServer.RegisterCustomOptions(Const URLParts : TRawUTF8DynArray;
                                                  CustomOptions  : TRESTDWOptions);
Var
 Index: Integer;
Begin
 For Index := Low(URLParts) To High(URLParts) Do
  RegisterCustomOptions(URLParts[Index], CustomOptions);
End;

Function TRESTDWHTTPServer.Request(Context: THttpServerRequest): Cardinal;
Const
 HTTPS                         : Array[Boolean] Of SockString = ('http://', 'https://');
 LETS_ENCRYPT_WELL_KNOWN_PATHS : Array[0..2]    Of PAnsiChar  = ('/.WELL-KNOWN/ACME-CHALLENGE/',
                                                                 '/.WELL-KNOWN/CPANEL-DCV/',
                                                                 '/.WELL-KNOWN/PKI-VALIDATION/');
 CACHE_NO_TRANSFORM            : ShortString                  = ', no-transform';
 CACHE_PUBLIC                  : ShortString                  = ', public';
 CACHE_PRIVATE                 : ShortString                  = ', private';
 CAHCE_NO_CACHE                : ShortString                  = ', no-cache';
 CACHE_NO_STORE                : ShortString                  = ', no-store';
 CACHE_MUST_REVALIDATE         : ShortString                  = ', must-revalidate';
 CACHE_MAX_AGE                 : ShortString                  = ', max-age=';
Var
 Asset: PAsset;
 AssetEncoding      : TAssetEncoding;
 LOptions           : TRESTDWOptions;
 AcceptedEncodingsDefined,
 GZipAccepted,
 RESTDWAccepted,
 OriginExists,
 CORSEnabled        : Boolean;
 Path,
 PathLowerCased,
 ExtUp,
 Host,
 ContentTypeUp,
 ForcedContentType,
 CacheControl       : SockString;
 CacheControlBuffer : Array[0..127] Of Byte;
 IntBuffer          : Array[0..23] Of AnsiChar;
 Len,
 Expires            : PtrInt;
 ExpiresDefined     : Boolean;
 Vary               : RawUTF8;
 P, PInt            : PAnsiChar;
Begin
 SplitURL(Context.URL, Path, ExtUp, rdwSEnableCacheBusting in FOptions, rdwSEnableCacheBustingBeforeExt in FOptions);
 LOptions := FindCustomOptions(Path, FOptions);
 If StrIComp(Pointer(Context.Method), PAnsiChar('GET')) = 0 Then
  Begin
   Asset := FAssets.Find(Path);
   If Asset = Nil Then
    Begin
     PathLowerCased := LowerCase(Path);
     If PathLowerCased <> Path Then
      Begin
       Asset := FAssets.Find(PathLowerCased);
       If RedirectServerRootUriForExactCase And (Asset <> Nil) Then
        Begin
         Host := GetCustomHeader(Context.InHeaders, 'HOST:');
         If Host <> '' Then
          Begin
           AddCustomHeader(Context, 'Location', FormatUTF8('%%%', [HTTPS[Context.UseSSL], Host, PathLowerCased]));
           Result := HTTP_MOVEDPERMANENTLY;
           Exit;
          End;
        End;
      End;
    End;
  End
 Else
  Asset := Nil;
 GZipAccepted := False;
 RESTDWAccepted := False;
 AssetEncoding := aeIdentity;
 AcceptedEncodingsDefined := False;
 If Asset = Nil Then
  Begin
   If (rdwSDisableTRACEMethod in LOptions) And
      (StrIComp(Pointer(Context.Method), PAnsiChar('TRACE')) = 0) Then
    Result := HTTP_NOTALLOWED
   Else
    Begin
     Inherited Request(Context);
     Result        := HTTP_SUCCESS;
     ContentTypeUp := GetContentTypeUp(Context.OutContentType);
    End;
  End
 Else
  Begin
   GetAcceptedEncodings(Context, rdwSFixMangledAcceptEncoding in LOptions, GZipAccepted, RESTDWAccepted);
   AcceptedEncodingsDefined := True;
   If Asset.RESTDWExists And RESTDWAccepted Then
    AssetEncoding := aeRESTDW
   Else If Asset.GZipExists And GZipAccepted Then
    AssetEncoding := aeGZip;
   If Not WasModified(Context, Asset, AssetEncoding,
                      rdwSEnableCacheByETag         In LOptions,
                      rdwSEnableCacheByLastModified In LOptions) Then
    Begin
     Result := HTTP_NOTMODIFIED;
     Exit;
    End;
   Context.OutContentType := Asset.ContentType;
   ContentTypeUp := GetContentTypeUp(Asset.ContentType);
   If AssetEncoding = aeGZip Then
    Begin
     AddCustomHeader(Context, 'Content-Encoding', 'gzip');
     Context.OutContent := Asset.GZipContent;
    End
   Else If AssetEncoding = aeRESTDW Then
    Begin
     AddCustomHeader(Context, 'Content-Encoding', 'br');
     Context.OutContent := Asset.RESTDWContent;
    End
   Else
    Context.OutContent := Asset.Content;
   Result := HTTP_SUCCESS;
  End;
  If ((Result = HTTP_BADREQUEST)        And (rdwSDelegateBadRequestTo404 in LOptions))    Or
     ((Result = HTTP_UNAUTHORIZED)      And (rdwSDelegateUnauthorizedTo404 in LOptions))  Or
     ((Result = HTTP_FORBIDDEN)         And (rdwSDelegateForbiddenTo404 in LOptions))     Or
     ((Result = HTTP_NOTFOUND)          And (rdwSDelegateNotFoundTo404 in LOptions))      Or
     ((Result = HTTP_NOTALLOWED)        And (rdwSDelegateNotAllowedTo404 in LOptions))    Or
     ((Result = HTTP_NOTACCEPTABLE)     And (rdwSDelegateNotAcceptableTo404 in LOptions)) Or
     ((rdwSDelegateHidden in LOptions)  And ContainsHiddenExceptWellKnown(Path))          Or
     ((rdwSDelegateBlocked in LOptions) And (IsBlockedPathOrExt(Path, ExtUp)))            Then
  Begin
   If rdwSDelegate404ToInherited_404 in LOptions Then
    Begin
     With Context Do
      Prepare('/404', Method, InHeaders, InContent, InContentType, RemoteIP, UseSSL);
     Result := Inherited Request(Context);
     ContentTypeUp := GetContentTypeUp(Context.OutContentType);
     If Result = HTTP_SUCCESS Then
      Result := HTTP_NOTFOUND;
    End
   Else
    Begin
     With Context Do
      Prepare('/404.html', Method, InHeaders, InContent, InContentType, RemoteIP, UseSSL);
     Asset := FAssets.Find('/404.html');
     If Asset <> Nil Then
      Begin
       Context.OutContentType := Asset.ContentType;
       ContentTypeUp := GetContentTypeUp(Asset.ContentType);
       If Not AcceptedEncodingsDefined Then
        GetAcceptedEncodings(Context, rdwSFixMangledAcceptEncoding in LOptions, GZipAccepted, RESTDWAccepted);
       If Asset.RESTDWExists And RESTDWAccepted Then
        AssetEncoding := aeRESTDW
       Else If Asset.GZipExists And GZipAccepted Then
        AssetEncoding := aeGZip
       Else
        AssetEncoding := aeIdentity;
       DeleteCustomHeader(Context, 'CONTENT-ENCODING:');
       If AssetEncoding = aeGZip Then
        Begin
         AddCustomHeader(Context, 'Content-Encoding', 'gzip');
         Context.OutContent := Asset.GZipContent;
        End
       Else If AssetEncoding = aeRESTDW Then
        Begin
         AddCustomHeader(Context, 'Content-Encoding', 'br');
         Context.OutContent := Asset.RESTDWContent;
        End
       Else
        Context.OutContent := Asset.Content;
       Result := HTTP_NOTFOUND;
       ExtUp := '.HTML';
      End;
    End;
  End;
 If rdwSForceMIMEType in LOptions Then
  Begin
   ForcedContentType := FForceMIMETypesValues.Value(ExtUp, #0);
   If ForcedContentType <> #0 Then
    Begin
     Context.OutContentType := ForcedContentType;
     ContentTypeUp := GetContentTypeUp(ForcedContentType);
    End;
  End;
 If (rdwSForceGZipHeader in LOptions) And (AssetEncoding = aeIdentity) And
     InArray(ExtUp, FFileTypesForceGZipHeaderUpArray) Then
  AddCustomHeader(Context, 'Content-Encoding', 'gzip');
 If rdwSForceTextUTF8Charset in LOptions Then
  Begin
   If Context.OutContentType = 'text/html' Then
    Context.OutContentType := 'text/html; charset=UTF-8'
   Else If Context.OutContentType = 'text/plain' Then
    Context.OutContentType := 'text/plain; charset=UTF-8';
  End;
 If (rdwSForceUTF8Charset in LOptions) And
     InArray(ExtUp, FFileTypesRequiredCharSetUpArray) Then
  Begin
   If PosEx('charset', LowerCase(Context.OutContentType)) = 0 Then
    Context.OutContentType := Context.OutContentType + '; charset=UTF-8';
  End;
 CORSEnabled := False;
 OriginExists := GetCustomHeader(Context.InHeaders, 'ORIGIN:') <> '';
 If rdwSAllowCrossOrigin in LOptions Then
  Begin
   If OriginExists Then
    Begin
     AddCustomHeader(Context, 'Access-Control-Allow-Origin', '*');
     CORSEnabled := True;
    End;
  End;
 If Not CORSEnabled And (rdwSAllowCrossOriginImages in LOptions) Then
  Begin
   If OriginExists And InArray(ExtUp, FFileTypesImageUpArray) Then
    Begin
     AddCustomHeader(Context, 'Access-Control-Allow-Origin', '*');
     CORSEnabled := True;
    End;
  End;
 If Not CORSEnabled And (rdwSAllowCrossOriginFonts in LOptions) Then
  If OriginExists And InArray(ExtUp, FFileTypesFontUpArray) Then
   AddCustomHeader(Context, 'Access-Control-Allow-Origin', '*');
 If rdwSAllowCrossOriginTiming in LOptions Then
  AddCustomHeader(Context, 'Timing-Allow-Origin', '*');
 If IdemPCharUp(Pointer(ContentTypeUp), Pointer(PAnsiChar('TEXT/HTML'))) Then
  Begin
   If (rdwSSetXUACompatible in LOptions) Then
    AddCustomHeader(Context, 'X-UA-Compatible', 'IE=edge');
   If (rdwSSetXFrameOptions in LOptions) Then
    AddCustomHeader(Context, 'X-Frame-Options', 'DENY');
   If (FContentSecurityPolicy <> '') Then
    AddCustomHeader(Context, 'Content-Security-Policy', FContentSecurityPolicy);
   If (FContentSecurityPolicyReportOnly <> '') Then
    AddCustomHeader(Context, 'Content-Security-Policy-Report-Only', FContentSecurityPolicyReportOnly);
   If (rdwSEnableXSSFilter in LOptions) Then
    AddCustomHeader(Context, 'X-XSS-Protection', '1; mode=block');
  End;
 If Context.UseSSL Then
  If FStrictSSL = strictSSLOn Then
   AddCustomHeader(Context, 'Strict-Transport-Security', 'max-age=31536000')
  Else If FStrictSSL = strictSSLIncludeSubDomains Then
   AddCustomHeader(Context, 'Strict-Transport-Security', 'max-age=31536000; includeSubDomains')
  Else If FStrictSSL = strictSSLIncludeSubDomainsPreload Then
   AddCustomHeader(Context, 'Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
  If rdwSPreventMIMESniffing in LOptions Then
   AddCustomHeader(Context, 'X-Content-Type-Options', 'nosniff');
  If (rdwSEnableReferrerPolicy in LOptions) And
      InArray(ContentTypeUp, FReferrerPolicyContentTypesUpArray) Then
   AddCustomHeader(Context, 'Referrer-Policy', FReferrerPolicy);
  If rdwSDeleteXPoweredBy in LOptions Then
   DeleteCustomHeader(Context, 'X-POWERED-BY:');
  Expires := 0;
  ExpiresDefined := False;
  If [rdwSSetCacheNoTransform, rdwSSetCachePublic,  rdwSSetCachePrivate,
      rdwSSetCacheNoCache,     rdwSSetCacheNoStore, rdwSSetCacheMustRevalidate,
      rdwSSetCacheMaxAge] * LOptions <> [] Then
   Begin
    CacheControl := DeleteCustomHeader(Context, 'CACHE-CONTROL:');
    P := @CacheControlBuffer[0];
    If rdwSSetCacheNoTransform in LOptions Then
     Begin
      Move(Pointer(@CACHE_NO_TRANSFORM[1])^, P^, Length(CACHE_NO_TRANSFORM));
      Inc(P, Length(CACHE_NO_TRANSFORM));
     End;
    If rdwSSetCachePublic in LOptions Then
     Begin
      Move(Pointer(@CACHE_PUBLIC[1])^, P^, Length(CACHE_PUBLIC));
      Inc(P, Length(CACHE_PUBLIC));
     End;
    If rdwSSetCachePrivate in LOptions Then
     Begin
      Move(Pointer(@CACHE_PRIVATE[1])^, P^, Length(CACHE_PRIVATE));
      Inc(P, Length(CACHE_PRIVATE));
     End;
    If rdwSSetCacheNoCache in LOptions Then
     Begin
      Move(Pointer(@CAHCE_NO_CACHE[1])^, P^, Length(CAHCE_NO_CACHE));
      Inc(P, Length(CAHCE_NO_CACHE));
     End;
    If rdwSSetCacheNoStore in LOptions Then
     Begin
      Move(Pointer(@CACHE_NO_STORE[1])^, P^, Length(CACHE_NO_STORE));
      Inc(P, Length(CACHE_NO_STORE));
     End;
    If rdwSSetCacheMustRevalidate in LOptions Then
     Begin
      Move(Pointer(@CACHE_MUST_REVALIDATE[1])^, P^, Length(CACHE_MUST_REVALIDATE));
      Inc(P, Length(CACHE_MUST_REVALIDATE));
     End;
    If rdwSSetCacheMaxAge in LOptions Then
     Begin
      Move(Pointer(@CACHE_MAX_AGE[1])^, P^, Length(CACHE_MAX_AGE));
      Inc(P, Length(CACHE_MAX_AGE));
      Expires := GetExpires(ContentTypeUp);
      ExpiresDefined := True;
      PInt := StrInt32(@IntBuffer[23], Expires);
      Len := @IntBuffer[23] - PInt;
      Move(PInt^, P^, Len);
      Inc(P, Len);
     End;
    Len := P - @CacheControlBuffer[0];
    If CacheControl <> '' Then
     Begin
      SetLength(CacheControl, Length(CacheControl) + Len);
      Move(CacheControlBuffer[0], PAnsiChar(PAnsiChar(Pointer(CacheControl)) + Length(CacheControl) - Len)^, Len);
     End
    Else
     SetString(CacheControl, PAnsiChar(@CacheControlBuffer[2]), Len - 2);
    AddCustomHeader(Context, 'Cache-Control', CacheControl);
   End;
  If rdwSSetExpires in LOptions Then
   Begin
    If Not ExpiresDefined Then
     Expires := GetExpires(ContentTypeUp);
    AddCustomHeader(Context, 'Expires', DateTimeToHTTPDate(NowUTC + Expires / SecsPerDay));
   End;
  If rdwSDeleteServerInternalState in LOptions Then
   DeleteCustomHeader(Context, 'SERVER-INTERNALSTATE:');
  If (rdwSVaryAcceptEncoding In LOptions)      And
      ((Asset = Nil)         Or (Asset <> Nil) And
      (Asset.GZipExists      Or Asset.RESTDWExists)) Then
   Begin
    Vary := DeleteCustomHeader(Context, 'VARY:');
    If Vary <> '' Then
     Vary := Vary + ', Accept-Encoding'
    Else
     Vary := 'Accept-Encoding';
    AddCustomHeader(Context, 'Vary', Vary);
   End;
  If (FDNSPrefetchControl <> dnsPrefetchNone) And
      InArray(ContentTypeUp, FDNSPrefetchControlContentTypesUpArray) Then
   If FDNSPrefetchControl = dnsPrefetchOn Then
    AddCustomHeader(Context, 'X-DNS-Prefetch-Control', 'on')
   Else
    AddCustomHeader(Context, 'X-DNS-Prefetch-Control', 'off');
  If (Asset <> Nil) And (FStaticRoot <> '') Then
   Begin
    AddCustomHeader(Context, 'Content-Type', Context.OutContentType);
    Context.OutContentType := HTTP_RESP_STATICFILE;
    Context.OutContent     := SockString(Asset.SaveToFile(FStaticRoot, AssetEncoding));
   End;
  If Assigned(fOnRequest) Then
   Result := fOnRequest(Context);
End;

Procedure TRESTDWHTTPServer.SetDNSPrefetchControlContentTypes(Const Value: SockString);
Begin
 If FDNSPrefetchControlContentTypes <> Value Then
  Begin
   FDNSPrefetchControlContentTypes := Value;
   UpArrayFromCSV(Value, FDNSPrefetchControlContentTypesUpArray);
  End;
End;

Procedure TRESTDWHTTPServer.SetExpires(Const Value: SockString);
Var
  Index: Integer;
Begin
 If FExpires <> Value Then
  Begin
   FExpires := Value;
   FExpiresValues.InitFromCSV(Pointer(Value));
   For Index := 0 To FExpiresValues.Count - 1 Do
    Begin
     With FExpiresValues.List[Index] Do
      Tag := ExpiresToSecs(Value);
    End;
   Index := FExpiresValues.Find('*');
   If Index >= 0 Then
    FExpiresDefault := FExpiresValues.List[Index].Tag
   Else
    FExpiresDefault := 0;
  End;
End;

Procedure TRESTDWHTTPServer.SetFileTypesBlocked(Const Value: SockString);
Begin
 If FFileTypesBlocked <> Value Then
  Begin
   FFileTypesBlocked := Value;
   UpArrayFromCSV(Value, FFileTypesBlockedUpArray, '.');
  End;
End;

Procedure TRESTDWHTTPServer.SetFileTypesFont(Const Value: SockString);
Begin
 If FFileTypesFont <> Value Then
  Begin
   FFileTypesFont := Value;
   UpArrayFromCSV(Value, FFileTypesFontUpArray, '.');
  End;
End;

Procedure TRESTDWHTTPServer.SetFileTypesForceGZipHeader(
  Const Value: SockString);
Begin
 If FFileTypesForceGZipHeader <> Value Then
  Begin
   FFileTypesForceGZipHeader := Value;
   UpArrayFromCSV(Value, FFileTypesForceGZipHeaderUpArray, '.');
  End;
End;

Procedure TRESTDWHTTPServer.SetFileTypesImage(Const Value: SockString);
Begin
 If FFileTypesImage <> Value Then
  Begin
   FFileTypesImage := Value;
   UpArrayFromCSV(Value, FFileTypesImageUpArray, '.');
  End;
End;

Procedure TRESTDWHTTPServer.SetFileTypesRequiredCharSet(Const Value: SockString);
Begin
 If FFileTypesRequiredCharSet <> Value Then
  Begin
   FFileTypesRequiredCharSet := Value;
   UpArrayFromCSV(Value, FFileTypesRequiredCharSetUpArray, '.');
  End;
End;

Procedure TRESTDWHTTPServer.SetForceMIMETypes(Const ExtMIMETypePairs: TRawUTF8DynArray);
Var
 Index : Integer;
Begin
 FForceMIMETypesValues.Init(False);
 For Index := 0 To Length(MIME_TYPES_FILE_EXTENSIONS) shr 1 - 1 Do
  FForceMIMETypesValues.Add(MIME_TYPES_FILE_EXTENSIONS[Index shl 1 + 1], MIME_TYPES_FILE_EXTENSIONS[Index shl 1]);
End;

Procedure TRESTDWHTTPServer.SetMangledEncodingHeaders(Const Value: SockString);
Begin
 If FMangledEncodingHeaders <> Value Then
  Begin
   FMangledEncodingHeaders := Value;
   UpArrayFromCSV(Value, FMangledEncodingHeadersUpArray, '', ': ');
  End;
End;

Procedure TRESTDWHTTPServer.SetMangledEncodingHeaderValues(Const Value: SockString);
Begin
 If FMangledEncodingHeaderValues <> Value Then
  Begin
   FMangledEncodingHeaderValues := Value;
   UpArrayFromCSV(Value, FMangledEncodingHeaderValuesUpArray, '', '', '|');
  End;
End;

Procedure TRESTDWHTTPServer.SetReferrerPolicyContentTypes(Const Value: SockString);
Begin
 If FReferrerPolicyContentTypes <> Value Then
  Begin
   FReferrerPolicyContentTypes := Value;
   UpArrayFromCSV(Value, FReferrerPolicyContentTypesUpArray);
  End;
End;

Procedure TRESTDWHTTPServer.SplitURL(Const URL                   : SockString;
                                     Var Path,
                                     ExtUp                       : SockString;
                                     Const EnableCacheBusting,
                                     EnableCacheBustingBeforeExt : Boolean);
Var
 Index,
 Len,
 ExtPos,
 QueryOrFragmentPos : Integer;
Begin
 If URL = '' Then
  Begin
   Path := '';
   ExtUp := '';
   Exit;
  End;
 Len := Length(URL);
 ExtPos := 0;
 QueryOrFragmentPos := 0;
 For Index := 1 To Len Do
  Begin
   If QueryOrFragmentPos = 0 Then
    Begin
      Case URL[Index] Of
        '/'      : ExtPos := 0;
        '.'      : ExtPos := Index;
        '?', '#' : Begin
                    QueryOrFragmentPos := Index;
                    Break;
                   End;
      End;
    End;
  End;
 If EnableCacheBusting And (QueryOrFragmentPos > 0) Then
  SetString(Path, PAnsiChar(PByteArray(URL)), QueryOrFragmentPos - 1)
 Else
  Path := URL;
 If ExtPos > 0 Then
  Begin
   If QueryOrFragmentPos > 0 Then
    SetString(ExtUp, PAnsiChar(@PByteArray(URL)[ExtPos - 1]), QueryOrFragmentPos - ExtPos + 1)
   Else
    SetString(ExtUp, PAnsiChar(@PByteArray(URL)[ExtPos - 1]), Len - ExtPos + 1);
   For Index := 0 To Length(ExtUp) - 1 Do
    Begin
     If PByteArray(ExtUp)[Index] in [Ord('a')..Ord('z')] Then
      Dec(PByteArray(ExtUp)[Index], $20);
    End;
  End
 Else
  ExtUp := '';
 If EnableCacheBustingBeforeExt And (ExtPos > 0) Then
  Begin
   For Index := ExtPos - 1 Downto 1 Do
    Begin
      Case URL[Index] Of
        '/' : Break;
        '.' : Begin
               Delete(Path, Index, ExtPos - Index);
               Break;
              End;
      End;
    End;
  End;
End;

Procedure TRESTDWHTTPServer.UnregisterCustomOptions(Const URLPath: RawUTF8);
Begin
 If Copy(URLPath, Length(URLPath), 1) = '*' Then
  FCustomOptionPrefixes.Delete(UpperCase(Copy(URLPath, 1, Length(URLPath) - 1)))
 Else
  FCustomOptions.Delete(URLPath);
End;

Procedure TRESTDWHTTPServer.UnregisterCustomOptions(Const URLPaths: TRawUTF8DynArray);
Var
 Index : Integer;
Begin
 For Index := Low(URLPaths) To High(URLPaths) Do
  UnregisterCustomOptions(URLPaths[Index]);
End;

Procedure TRESTDWHTTPServer.UpArrayFromCSV(Const CSV       : SockString;
                                           Var Values      : TSockStringDynArray;
                                           Const PrefixUp,
                                           PostfixUp       : SockString;
                                           Const Sep       : AnsiChar);
Var
 Index,
 DeduplicateIndex,
 Count             : Integer;
 ArrayDA           : TDynArray;
 P                 : PUTF8Char;
 Value             : RawUTF8;
Begin
 If CSV = '' Then
  Begin
   Values := Nil;
   Exit;
  End;
 ArrayDA.Init(TypeInfo(TRawUTF8DynArray), Values, @Count);
 P := Pointer(CSV);
 While P <> Nil Do
  Begin
   GetNextItem(P, Sep, Value);
   If Value <> '' Then
    Begin
     UpperCaseSelf(Value);
     If (PrefixUp <> '') And (PostfixUp <> '') Then
      Value := FormatUTF8('%%%', [PrefixUp, Value, PostfixUp])
     Else If PrefixUp <> '' Then
      Value := FormatUTF8('%%', [PrefixUp, Value])
     Else If PostfixUp <> '' Then
      Value := FormatUTF8('%%', [Value, PostfixUp]);
     ArrayDA.Add(Value);
    End;
  End;
 If Count <= 1 Then
  SetLength(Values, Count)
 Else
  Begin
   ArrayDA.Sort(SortDynArrayPUTF8Char);
   DeduplicateIndex := 0;
   For Index := 1 To Count - 1 Do
    Begin
     If Values[DeduplicateIndex] <> Values[Index] Then
      Begin
        Inc(DeduplicateIndex);
        If DeduplicateIndex <> Index Then
          Values[DeduplicateIndex] := Values[Index];
      End;
    End;
   SetLength(Values, DeduplicateIndex + 1);
  End;
End;

End.
