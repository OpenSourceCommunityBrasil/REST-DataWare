unit ServerUtils;

{$I uRESTDW.inc}

interface

Uses
  {$IFDEF FPC}
  Classes,  SysUtils
  {$ELSE}
  Classes,  SysUtils,
  StringBuilderUnit, IdURI
  {$ENDIF}, IdGlobal, IdHashMessageDigest, IdHash, uDWConsts, DateUtils;

Type
 TRDWAuthOptionTypes = (rdwOATBasic, rdwOATBearer, rdwOATToken);
 TRDWAuthOption      = (rdwAONone,   rdwAOBasic,   rdwAOBearer,
                        rdwAOToken,  rdwOAuth);
 TRDWTokenType       = (rdwTS,       rdwJWT,       rdwPersonal);
 TRDWAuthOptions     = Set of TRDWAuthOption;
 TRDWCryptType       = (rdwAES256,   rdwHSHA256,   rdwRSA);
 TRDWTokenRequest    = (rdwtHeader,  rdwtRequest);
 {$IFDEF FPC}
  DWInteger       = Longint;
  DWInt64         = Int64;
  DWFloat         = Real;
  DWFieldTypeSize = Longint;
  DWBufferSize    = Longint;
 {$ELSE}
  DWInteger       = Integer;
  DWInt64         = Int64;
  DWFloat         = Real;
  DWFieldTypeSize = Integer;
  DWBufferSize    = Longint;
 {$ENDIF}
 PDWInt64         = ^DWInt64;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    DWString     = String;
    DWWideString = String;
   {$ELSE}
    DWString     = Utf8String;
    DWWideString = Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    DWString     = Utf8String;
    DWWideString = Utf8String;
   {$ELSE}
    DWString     = AnsiString;
    DWWideString = WideString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  DWString     = AnsiString;
  DWWideString = WideString;
 {$ENDIF}

Type
 TDWParamsHeader = Packed Record
  VersionNumber,
  RecordCount,
  ParamsCount    : DWInteger; //new for ver15
  DataSize       : DWInt64; //new for ver15
End;

Type
 TTokenValue = Class
 Private
  vInitRequest,
  vFinalRequest         : TDateTime;
  vServerSignature,
  vTokenHash,
  vToken,
  vSecrets,
  vMD5                  : String;
  vRDWTokenType         : TRDWTokenType;
  vRDWCryptType         : TRDWCryptType;
  vCripto               : TCripto;
  Procedure   SetTokenHash (Token : String);
  Function    ToJSON       : String;
  Function    ToToken      : String;
  Function    GetCryptType : String;
  Function    GetTokenType : String;
  Function    GetHeader    : String;
  Procedure   SetSecrets     (Value : String);
  Procedure   SetFinalRequest(Value : TDateTime);
 Public
  Constructor    Create;
  Destructor     Destroy;Override;
  Class Function GetMD5       (Const Value : String)    : String;
  Class Function ISO8601FromDateTime(Value : TDateTime) : String;
  Class Function DateTimeFromISO8601(Value : String)    : TDateTime;
  Property       TokenType         : TRDWTokenType Read vRDWTokenType      Write vRDWTokenType;
  Property       CryptType         : TRDWCryptType Read vRDWCryptType      Write vRDWCryptType;
  Property       BeginTime         : TDateTime     Read vInitRequest       Write vInitRequest;
  Property       EndTime           : TDateTime     Read vFinalRequest      Write SetFinalRequest;
  Property       Iss               : String        Read vServerSignature   Write vServerSignature;
  Property       Secrets           : String        Read vSecrets           Write SetSecrets;
  Property       TokenHash         : String        Read vTokenHash         Write SetTokenHash;
  Property       Token             : String        Read ToToken;
End;

Type
 TRDWAuthOptionParam = Class(TPersistent)
 Private
  vCustom404TitleMessage,
  vCustom404BodyMessage,
  vCustom404FooterMessage,
  vCustomAuthMessage       : String;
  vAuthDialog              : Boolean;
  vCustomAuthErrorPage     : TStringList;
  Procedure SetCustomAuthErrorPage (Value : TStringList);
 Protected
 Public
//  Procedure   Assign   (Source   : TPersistent);Override;
  Constructor Create;
  Destructor  Destroy;Override;
 Published
  Property AuthDialog              : Boolean     Read vAuthDialog             Write vAuthDialog;
  Property CustomDialogAuthMessage : String      Read vCustomAuthMessage      Write vCustomAuthMessage;
  Property Custom404TitleMessage   : String      Read vCustom404TitleMessage  Write vCustom404TitleMessage;
  Property Custom404BodyMessage    : String      Read vCustom404BodyMessage   Write vCustom404BodyMessage;
  Property Custom404FooterMessage  : String      Read vCustom404FooterMessage Write vCustom404FooterMessage;
  Property CustomAuthErrorPage     : TStringList Read vCustomAuthErrorPage    Write SetCustomAuthErrorPage;
End;

Type
 TRDWAuthTokenParam = Class(TRDWAuthOptionParam)
 Private
  vInitRequest,
  vFinalRequest : TDateTime;
  vServerSignature,
  vSecrets,
  vGetTokenName,
  vTokenName,
  vTokenHash    : String;
  vDWRoutes     : TDWRoutes;
  vLifeCycle    : Integer;
  vRDWTokenType : TRDWTokenType;
  vRDWCryptType : TRDWCryptType;
  Procedure   SetTokenHash   (Token : String);
  Procedure   SetGetTokenName(Value : String);
  Procedure   SetCryptType   (Value : TRDWCryptType);
  Function    GetTokenType   (Value : String) : TRDWTokenType;
  Function    GetCryptType   (Value : String) : TRDWCryptType;
 Protected
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Procedure   Assign   (Source   : TPersistent);Override;
  Function    GetToken (aSecrets : String) : String;  Virtual; Abstract;
  Function    FromToken(Value    : String) : Boolean; Virtual; Abstract;
  Property    BeginTime          : TDateTime    Read vInitRequest     Write vInitRequest;
  Property    EndTime            : TDateTime    Read vFinalRequest    Write vFinalRequest;
  Property    Secrets            : String       Read vSecrets         Write vSecrets;
 Published
  Property    TokenType         : TRDWTokenType Read vRDWTokenType    Write vRDWTokenType;
  Property    CryptType         : TRDWCryptType Read vRDWCryptType    Write SetCryptType;
  Property    Key               : String        Read vTokenName       Write vTokenName;
  Property    GetTokenEvent     : String        Read vGetTokenName    Write SetGetTokenName;
  Property    GetTokenRoutes    : TDWRoutes     Read vDWRoutes        Write vDWRoutes;
  Property    TokenHash         : String        Read vTokenHash       Write SetTokenHash;
  Property    ServerSignature   : String        Read vServerSignature Write vServerSignature;
  Property    LifeCycle         : Integer       Read vLifeCycle       Write vLifeCycle;
End;


Type
 TRDWAuthOptionBasic = Class(TRDWAuthOptionParam)
 Private
  vUserName,
  vPassword : String;
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
 Published
  Property    Username : String Read vUserName Write vUserName;
  Property    Password : String Read vPassword Write vPassword;
End;

Type
 TRDWAuthOAuth = Class(TRDWAuthOptionParam)
 Private
  vRedirectURI,
  vGetTokenName,
  vGrantCodeName,
  vClientID,
  vToken,
  vGrantType,
  vClientSecret : String;
  vAutoBuildHex : Boolean;
  vExpiresin    : TDatetime;
  vRDWTokenType : TRDWAuthOptionTypes;
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   GetGrantCode;
  Procedure   GetGetToken;
 Published
  Property    TokenType      : TRDWAuthOptionTypes Read vRDWTokenType  Write vRDWTokenType;
  Property    AutoBuildHex   : Boolean             Read vAutoBuildHex  Write vAutoBuildHex;
  Property    Token          : String              Read vToken         Write vToken;
  Property    GrantCodeEvent : String              Read vGrantCodeName Write vGrantCodeName;
  Property    GrantType      : String              Read vGrantType     Write vGrantType;
  Property    GetTokenEvent  : String              Read vGetTokenName  Write vGetTokenName;
  Property    ClientID       : String              Read vClientID      Write vClientID;
  Property    ClientSecret   : String              Read vClientSecret  Write vClientSecret;
  Property    RedirectURI    : String              Read vRedirectURI   Write vRedirectURI;
  Property    Expires_in     : TDateTime           Read vExpiresin;
End;

Type
 TRDWAuthOptionBearerClient = Class(TRDWAuthOptionParam)
 Private
  vGetTokenName,
  vSecrets,
  vTokenName,
  vToken           : String;
  vRDWTokenType    : TRDWTokenType;
  vInitRequest,
  vFinalRequest    : TDateTime;
  vAutoRenewToken,
  vAutoGetToken    : Boolean;
  vTokenRequest    : TRDWTokenRequest;
  Procedure ClearToken;
  Procedure SetToken(Value : String);
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   FromToken(TokenValue : String);
 Published
  Property    TokenType        : TRDWTokenType    Read vRDWTokenType    Write vRDWTokenType;
  Property    TokenRequestType : TRDWTokenRequest Read vTokenRequest    Write vTokenRequest;
  Property    GetTokenEvent    : String           Read vGetTokenName    Write vGetTokenName;
  Property    Key               : String          Read vTokenName       Write vTokenName;
  Property    BeginTime        : TDateTime        Read vInitRequest;
  Property    EndTime          : TDateTime        Read vFinalRequest;
  Property    Secrets          : String           Read vSecrets;
  Property    Token            : String           Read vToken           Write SetToken;
  Property    AutoGetToken     : Boolean          Read vAutoGetToken    Write vAutoGetToken;
  Property    AutoRenewToken   : Boolean          Read vAutoRenewToken  Write vAutoRenewToken;
End;

Type
 TRDWAuthOptionTokenClient = Class(TRDWAuthOptionParam)
 Private
  vSecrets,
  vGetTokenName,
  vTokenName,
  vToken           : String;
  vTokenRequest    : TRDWTokenRequest;
  vRDWTokenType    : TRDWTokenType;
  vInitRequest,
  vFinalRequest    : TDateTime;
  vAutoRenewToken,
  vAutoGetToken    : Boolean;
  Procedure ClearToken;
  Procedure SetToken(Value : String);
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   FromToken(TokenValue : String);
 Published
  Property    TokenType        : TRDWTokenType    Read vRDWTokenType    Write vRDWTokenType;
  Property    TokenRequestType : TRDWTokenRequest Read vTokenRequest    Write vTokenRequest;
  Property    GetTokenEvent    : String           Read vGetTokenName    Write vGetTokenName;
  Property    Key              : String           Read vTokenName       Write vTokenName;
  Property    BeginTime        : TDateTime        Read vInitRequest;
  Property    EndTime          : TDateTime        Read vFinalRequest;
  Property    Secrets          : String           Read vSecrets;
  Property    Token            : String           Read vToken           Write SetToken;
  Property    AutoGetToken     : Boolean          Read vAutoGetToken    Write vAutoGetToken;
  Property    AutoRenewToken   : Boolean          Read vAutoRenewToken  Write vAutoRenewToken;
End;

Type
 TRDWAuthOptionBearerServer = Class(TRDWAuthTokenParam)
 Private
 Protected
 Public
  Function    GetToken (aSecrets : String = '') : String;  Override;
  Function    FromToken(Value    : String)      : Boolean; Override;
End;

Type
 TRDWAuthOptionTokenServer = Class(TRDWAuthTokenParam)
 Private
 Protected
 Public
  Function    GetToken(aSecrets  : String = '') : String;  Override;
  Function    FromToken(Value    : String)      : Boolean; Override;
End;

Type
 TRDWServerAuthOptionParams = Class(TPersistent)
 Private
  FOwner                          : TPersistent;
  RDWAuthOptionParam              : TRDWAuthOptionParam;
  RDWAuthOption                   : TRDWAuthOption;
  Procedure   DestroyParam;
  Procedure   SetAuthOption(Value : TRDWAuthOption);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner       : TPersistent);
  Procedure   Assign(Source       : TPersistent); Override;
  Destructor  Destroy;Override;
  Procedure   CopyServerAuthParams(Var Value : TRDWAuthOptionParam);
 Published
  Property AuthorizationOption    : TRDWAuthOption       Read RDWAuthOption      Write SetAuthOption;
  Property OptionParams           : TRDWAuthOptionParam  Read RDWAuthOptionParam Write RDWAuthOptionParam;
End;

Type
 TRDWClientAuthOptionParams = Class(TPersistent)
 Private
  FOwner                          : TPersistent;
  RDWAuthOptionParam              : TRDWAuthOptionParam;
  RDWAuthOption                   : TRDWAuthOption;
  Procedure   DestroyParam;
  Procedure   SetAuthOption(Value : TRDWAuthOption);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner       : TPersistent);
  Procedure   Assign(Source       : TPersistent); Override;
  Destructor  Destroy;Override;
 Published
  Property AuthorizationOption    : TRDWAuthOption       Read RDWAuthOption      Write SetAuthOption;
  Property OptionParams           : TRDWAuthOptionParam  Read RDWAuthOptionParam Write RDWAuthOptionParam;
End;

Type
 TRDWAuthRequest = Class
 Private
  vToken : String;
 Public
  Constructor Create;
  Property Token : String Read vToken Write vToken;
End;

Function GettokenValue(Value : String) : String;
Function GetTokenType (Value : String) : TRDWTokenType;

implementation

Uses uDWJSONTools, uDWConstsCharset, uDWJSONObject, uDWJSONInterface;

Function GetTokenType (Value : String) : TRDWTokenType;
Begin
 Result := rdwTS;
 If Lowercase(Value) = 'jwt' Then
  Result := rdwJWT;
End;

Function GettokenValue(Value : String) : String;
Var
 bJsonValue : TDWJSONObject;
Begin
 Result     := '';
 Try
  bJsonValue := TDWJSONObject.Create(Value);
  If bJsonValue.PairCount > 0 Then
   If Not bJsonValue.PairByName['token'].isnull Then
    Result     := bJsonValue.PairByName['token'].Value;
  FreeAndNil(bJsonValue);
 Except

 End;
End;

Function GetSecretsValue(Value : String) : String;
Var
 bJsonValue : TDWJSONObject;
Begin
 Result     := '';
 Try
  bJsonValue := TDWJSONObject.Create(Value);
  If bJsonValue.PairCount > 0 Then
   If Not bJsonValue.PairByName['secrets'].isnull Then
    Result     := bJsonValue.PairByName['secrets'].Value;
  FreeAndNil(bJsonValue);
 Except

 End;
End;

Class Function TTokenValue.GetMD5(Const Value : String) : String;
Var
 idmd5   :  TIdHashMessageDigest5;
Begin
 idmd5   := TIdHashMessageDigest5.Create;
 Try
  Result := idmd5.HashStringAsHex(Value);
 Finally
  FreeAndNil(idmd5);
 End;
End;

Class Function TTokenValue.ISO8601FromDateTime(Value : TDateTime) : String;
Begin
 Result := FormatDateTime('yyyy-mm-dd"T"hh":"nn":"ss', Value);
End;

Class Function TTokenValue.DateTimeFromISO8601(Value : String)    : TDateTime;
 Function ExtractNum(Value  : String;
                     a, len : Integer) : Integer;
 Begin
  Result := StrToIntDef(Copy(Value, a, len), 0);
 End;
 Function ISO8601StrToTime(Const S : String) : TDateTime;
 Begin
  If (Length(s) >= 8) And
         (s[3] = ':') Then
   Result := EncodeTime(ExtractNum(s, 1, 2),
                        ExtractNum(s, 4, 2),
                        ExtractNum(s, 7, 2), 0)
  Else
   Result := 0.0;
 End;
Var
 year,
 month,
 day   : Integer;
Begin
 If (Length(Value) >= 10)  And
         (Value[5]  = '-') And
         (Value[8]  = '-') Then
  Begin
   year      := ExtractNum(Value, 1, 4);
   month     := ExtractNum(Value, 6, 2);
   day       := ExtractNum(Value, 9, 2);
   If (year   = 0) And
      (month  = 0) And
      (day    = 0) Then
    Result   := 0.0
   Else
    Result   := EncodeDate(year, month, day);
   If (Length(Value) > 10)  And
         (Value[11]  = 'T') Then
    Result   := Result + ISO8601StrToTime(Copy(Value, 12, Length(Value)));
  End
 Else
  Result     := ISO8601StrToTime(Value);
End;

Constructor TTokenValue.Create;
Begin
 vCripto            := TCripto.Create;
 vRDWTokenType      := rdwTS;
 vRDWCryptType      := rdwAES256;
 vToken             := '';
 vServerSignature   := '';
 vSecrets           := '';
 vInitRequest       := 0;
 vFinalRequest      := 0;
End;

Destructor  TTokenValue.Destroy;
Begin
 FreeAndNil(vCripto);
 Inherited;
End;

Function TTokenValue.GetTokenType : String;
Begin
 Result := 'JWT';
 If vRDWTokenType = rdwTS Then
  Result := 'RDWTS'
 Else If vRDWTokenType = rdwPersonal Then
  Result := 'CUSTOM';
End;

Function TTokenValue.GetCryptType : String;
Begin
 Result := 'AES256';
 If vRDWCryptType = rdwHSHA256 Then
  Result := 'HS256'
 Else If vRDWCryptType = rdwRSA Then
  Result := 'RSA';
End;

Procedure TTokenValue.SetFinalRequest(Value : TDateTime);
Begin
 vFinalRequest := Value;
End;

Function TTokenValue.GetHeader : String;
Begin
 Result := Format('{"alg": "%s", "typ": "%s"}', [GetCryptType, GetTokenType]);
End;

Function    TTokenValue.ToToken : String;
Var
 viss,
 vBuildData : String;
Begin
 Result      := ToJSON;
 viss        := '';
 If trim(vServerSignature) <> '' Then
  viss := Format('"iss":"%s", ', [vServerSignature]);
 vBuildData  := '';
 //Por enquanto igual mais no futuro haverá diferenças
 Case vRDWTokenType Of
  rdwTS,
  rdwPersonal : Begin
                 vCripto.Key := vTokenHash;
                 vMD5        := TTokenValue.GetMD5(vSecrets);
                 If vFinalRequest <> 0 Then
                  vBuildData := Format(cValueToken, [viss,
                                                     ISO8601FromDateTime(vFinalRequest),
                                                     ISO8601FromDateTime(vInitRequest),
                                                     EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF FPC}, csUndefined{$ENDIF}), vMD5])
                                                                   {$IFDEF FPC}, csUndefined{$ENDIF})])
                 Else
                  vBuildData := Format(cValueTokenNoLife, [viss,
                                                           ISO8601FromDateTime(vInitRequest),
                                                           EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF FPC}, csUndefined{$ENDIF}), vMD5])
                                                                         {$IFDEF FPC}, csUndefined{$ENDIF})]);
                 Result     := Result + '.' + EncodeStrings(vBuildData{$IFDEF FPC}, csUndefined{$ENDIF});
                 Result     := Format(cTokenStringRDWTS, [Result + '.' + vCripto.Encrypt(Result)]);
                End;
  rdwJWT      : Begin
                 vCripto.Key := vTokenHash;
                 vMD5        := TTokenValue.GetMD5(vSecrets);
                 If vFinalRequest <> 0 Then
                  vBuildData := Format(cValueToken, [viss,
                                                     IntToStr(DateTimeToUnix(vFinalRequest{$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF})),
                                                     IntToStr(DateTimeToUnix(vInitRequest{$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF})),
                                                     EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF FPC}, csUndefined{$ENDIF}), vMD5])
                                                                   {$IFDEF FPC}, csUndefined{$ENDIF})])
                 Else
                  vBuildData := Format(cValueTokenNoLife, [viss,
                                                           IntToStr(DateTimeToUnix(vInitRequest{$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF})),
                                                           EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF FPC}, csUndefined{$ENDIF}), vMD5])
                                                                         {$IFDEF FPC}, csUndefined{$ENDIF})]);
                 Result     := Result + '.' + EncodeStrings(vBuildData{$IFDEF FPC}, csUndefined{$ENDIF});
                 Result     := Format(cTokenStringRDWTS, [Result + '.' + vCripto.Encrypt(Result)]);
                End;
 End;
End;

Function    TTokenValue.ToJSON  : String;
Begin
 Result := '';
 Case vRDWTokenType Of
  rdwTS,
  rdwPersonal : Begin
                 Result := EncodeStrings(GetHeader{$IFDEF FPC}, csUndefined{$ENDIF});
                End;
  rdwJWT      : Begin
                 Result := EncodeStrings(GetHeader{$IFDEF FPC}, csUndefined{$ENDIF});
                End;
 End;
End;

Procedure   TTokenValue.SetSecrets  (Value : String);
Begin
 vSecrets    := Value;
End;

Procedure   TTokenValue.SetTokenHash(Token : String);
Begin
 vTokenHash  := Token;
 vCripto.Key := vTokenHash;
End;

Procedure TRDWAuthOAuth.GetGetToken;
Begin

End;

Procedure TRDWAuthOAuth.GetGrantCode;
Begin

End;

Procedure TRDWAuthOAuth.Assign(Source: TPersistent);
Var
 Src : TRDWAuthOAuth;
Begin
 If Source is TRDWAuthOAuth Then
  Begin
   Src                := TRDWAuthOAuth(Source);
   vAutoBuildHex      := Src.AutoBuildHex;
   vClientID          := Src.ClientID;
   vClientSecret      := Src.ClientSecret;
   vGrantCodeName     := Src.GrantCodeEvent;
   vGetTokenName      := Src.GetTokenEvent;
  End
 Else
  Inherited Assign(Source);
End;

Procedure TRDWAuthOptionBasic.Assign(Source: TPersistent);
Var
 Src : TRDWAuthOptionBasic;
Begin
 If Source is TRDWAuthOptionBasic Then
  Begin
   Src                := TRDWAuthOptionBasic(Source);
   vUserName          := Src.Username;
   vPassword          := Src.Password;
  End
 Else
  Inherited Assign(Source);
End;

Procedure TRDWAuthOptionTokenClient.FromToken(TokenValue : String);
Var
 bJsonValue : TDWJSONObject;
 vHeader,
 vBody      : String;
Begin
 vToken     := TokenValue;
 Try
  vHeader   := Copy(TokenValue, InitStrPos, Pos('.', TokenValue) - 1);
  Delete(TokenValue, InitStrPos, Pos('.', TokenValue));
  vBody     := Copy(TokenValue, InitStrPos, Pos('.', TokenValue) - 1);
  //Read Header
  If Trim(vHeader) <> '' Then
   Begin
    bJsonValue := TDWJSONObject.Create(DecodeStrings(vHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If Not bJsonValue.PairByName['typ'].isnull Then
       vRDWTokenType := GetTokenType(bJsonValue.PairByName['typ'].Value);
     End;
    FreeAndNil(bJsonValue);
   End;
  //Read Body
  If Trim(vBody) <> '' Then
   Begin
    bJsonValue := TDWJSONObject.Create(DecodeStrings(vBody{$IFDEF FPC}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If (Not (bJsonValue.PairByName['iat'].isnull)) And
         (bJsonValue.PairByName['iat'].Value <> '')  Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vInitRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vInitRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
       End;
      If (Not (bJsonValue.PairByName['exp'].isnull)) And
         (bJsonValue.PairByName['exp'].Value <> '') Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vFinalRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vFinalRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
       End;
      If Not bJsonValue.PairByName['secrets'].isnull Then
       vSecrets := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF FPC}, csUndefined{$ENDIF});
     End;
    FreeAndNil(bJsonValue);
   End;
 Except

 End;
End;

Procedure TRDWAuthOptionTokenClient.Assign(Source: TPersistent);
Var
 Src : TRDWAuthOptionTokenClient;
Begin
 If Source is TRDWAuthOptionTokenClient Then
  Begin
   Src           := TRDWAuthOptionTokenClient(Source);
   vToken        := Src.Token;
  End
 Else
  Inherited Assign(Source);
End;

Function  TRDWAuthOptionTokenServer.FromToken(Value : String)    : Boolean;
Var
 vHeader,
 vBody,
 vStringComparer : String;
 vTokenValue     : TTokenValue;
 Function ReadHeader(Value : String) : Boolean;
 Var
  bJsonValue     : TDWJSONObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue    := TDWJSONObject.Create(Value);
   If bJsonValue.PairCount = 2 Then
    Begin
     Result      := (Lowercase(bJsonValue.Pairs[0].Name) = 'alg') And
                    (Lowercase(bJsonValue.Pairs[1].Name) = 'typ');
     If Result Then
      Begin
       vRDWTokenType := GetTokenType(bJsonValue.Pairs[1].Value);
       vRDWCryptType := GetCryptType(bJsonValue.Pairs[0].Value);
      End;
    End;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
 Function ReadBody(Value : String) : Boolean;
 Var
  bJsonValue     : TDWJSONObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue            := TDWJSONObject.Create(Value);
   Result                := Trim(bJsonValue.PairByName['iss'].Name) <> '';
   If Result Then
    Begin
     Result              := vServerSignature = vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
     If Result Then
      Begin
       Result := False;
       vServerSignature  := vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
       Result            := Trim(bJsonValue.PairByName['iat'].Name) <> '';
       If Result Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vInitRequest   := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
         Else
          vInitRequest   := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
        End;
       Result            := Trim(bJsonValue.PairByName['secrets'].Name) <> '';
       If Result Then
        vSecrets         := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF FPC}, csUndefined{$ENDIF});
       If Trim(bJsonValue.PairByName['exp'].Name) <> '' Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vFinalRequest  := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
         Else
          vFinalRequest  := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
         Result          := Now < vFinalRequest;
        End;
      End;
    End
   Else
    Result               := LifeCycle = 0;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
Begin
 vHeader         := '';
 vBody           := '';
 vStringComparer := '';
 Value           := StringReplace(Value, ' ', '+', [rfReplaceAll]); //Remove espaços na Token e add os caracteres "+" em seu lugar
 vHeader         := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vBody           := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vStringComparer := Value;
 Result          := (Trim(vHeader) <> '') And (Trim(vBody) <> '') And (Trim(vStringComparer) <> '');
 If Result Then
  Begin
   Result                   := ReadHeader(DecodeStrings(vHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
   If Result Then
    Begin
     Result                 := False;
     vTokenValue            := TTokenValue.Create;
     Try
      vTokenValue.TokenHash := vTokenHash;
      vTokenValue.CryptType := vRDWCryptType;
      vStringComparer       := vTokenValue.vCripto.Decrypt(vStringComparer);
      Result                := vStringComparer = vHeader + '.' + vBody;
      If Result Then
       Begin
        Result              := False;
        vHeader             := DecodeStrings(vHeader                 {$IFDEF FPC}, csUndefined{$ENDIF});
        vBody               := DecodeStrings(vBody                   {$IFDEF FPC}, csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(vBody)  {$IFDEF FPC}, csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(Secrets){$IFDEF FPC}, csUndefined{$ENDIF});
        Result              := ReadBody(vBody);
       End;
     Finally
      FreeAndNil(vTokenValue);
     End;
    End;
  End;
End;

Function  TRDWAuthOptionTokenServer.GetToken(aSecrets   : String = '') : String;
Var
 vTokenValue : TTokenValue;
Begin
 vTokenValue               := TTokenValue.Create;
 vTokenValue.TokenHash     := vTokenHash;
 vTokenValue.vRDWTokenType := TokenType;
 vTokenValue.CryptType     := vRDWCryptType;
 If Trim(ServerSignature)  <> '' Then
  vTokenValue.Iss          := vTokenValue.vCripto.Encrypt(ServerSignature);
 vTokenValue.Secrets       := aSecrets;
 vTokenValue.BeginTime     := Now;
 If vLifeCycle > 0 Then
  vTokenValue.EndTime      := IncSecond(vTokenValue.BeginTime, vLifeCycle);
 Try
  Result                   := vTokenValue.ToToken;
 Finally
  FreeAndNil(vTokenValue);
 End;
End;

Procedure TRDWAuthOptionBearerClient.FromToken(TokenValue : String);
Var
 bJsonValue : TDWJSONObject;
 vHeader,
 vBody      : String;
Begin
 vToken     := TokenValue;
 Try
  vHeader   := Copy(TokenValue, InitStrPos, Pos('.', TokenValue) - 1);
  Delete(TokenValue, InitStrPos, Pos('.', TokenValue));
  vBody     := Copy(TokenValue, InitStrPos, Pos('.', TokenValue) - 1);
  //Read Header
  If Trim(vHeader) <> '' Then
   Begin
    bJsonValue := TDWJSONObject.Create(DecodeStrings(vHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If Not bJsonValue.PairByName['typ'].isnull Then
       vRDWTokenType := GetTokenType(bJsonValue.PairByName['typ'].Value);
     End;
    FreeAndNil(bJsonValue);
   End;
  //Read Body
  If Trim(vBody) <> '' Then
   Begin
    bJsonValue := TDWJSONObject.Create(DecodeStrings(vBody{$IFDEF FPC}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If Not bJsonValue.PairByName['iat'].isnull Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vInitRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vInitRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
       End;
      If Not bJsonValue.PairByName['exp'].isnull Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vFinalRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vFinalRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
       End;
      If Not bJsonValue.PairByName['secrets'].isnull Then
       vSecrets := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF FPC}, csUndefined{$ENDIF});
     End;
    FreeAndNil(bJsonValue);
   End;
 Except

 End;
End;

Procedure TRDWAuthOptionBearerClient.Assign(Source: TPersistent);
Var
 Src : TRDWAuthOptionBearerClient;
Begin
 If Source is TRDWAuthOptionBearerClient Then
  Begin
   Src           := TRDWAuthOptionBearerClient(Source);
   vToken        := Src.Token;
  End
 Else
  Inherited Assign(Source);
End;

Function  TRDWAuthOptionBearerServer.FromToken(Value    : String)    : Boolean;
Var
 vHeader,
 vBody,
 vStringComparer : String;
 vTokenValue     : TTokenValue;
 Function ReadHeader(Value : String) : Boolean;
 Var
  bJsonValue     : TDWJSONObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue    := TDWJSONObject.Create(Value);
   If bJsonValue.PairCount = 2 Then
    Begin
     Result      := (Lowercase(bJsonValue.Pairs[0].Name) = 'alg') And
                    (Lowercase(bJsonValue.Pairs[1].Name) = 'typ');
     If Result Then
      Begin
       vRDWTokenType := GetTokenType(bJsonValue.Pairs[1].Value);
       vRDWCryptType := GetCryptType(bJsonValue.Pairs[0].Value);
      End;
    End;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
 Function ReadBody(Value : String) : Boolean;
 Var
  bJsonValue     : TDWJSONObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue            := TDWJSONObject.Create(Value);
   Result                := Trim(bJsonValue.PairByName['iss'].Name) <> '';
   If Result Then
    Begin
     Result              := vServerSignature = vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
     If Result Then
      Begin
       Result := False;
       vServerSignature  := vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
       Result            := Trim(bJsonValue.PairByName['iat'].Name) <> '';
       If Result Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vInitRequest   := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
         Else
          vInitRequest   := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
        End;
       Result            := Trim(bJsonValue.PairByName['secrets'].Name) <> '';
       If Result Then
        vSecrets         := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF FPC}, csUndefined{$ENDIF});
       If Trim(bJsonValue.PairByName['exp'].Name) <> '' Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vFinalRequest  := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
         Else
          vFinalRequest  := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ELSE}{$IF (CompilerVersion > 26)}, False{$IFEND}{$ENDIF});
         Result          := Now < vFinalRequest;
        End;
      End;
    End;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
Begin
 vHeader         := '';
 vBody           := '';
 vStringComparer := '';
 vHeader         := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vBody           := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vStringComparer := Value;
 Result          := (Trim(vHeader) <> '') And (Trim(vBody) <> '') And (Trim(vStringComparer) <> '');
 If Result Then
  Begin
   Result                   := ReadHeader(DecodeStrings(vHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
   If Result Then
    Begin
     Result                 := False;
     vTokenValue            := TTokenValue.Create;
     Try
      vTokenValue.TokenHash := vTokenHash;
      vTokenValue.CryptType := vRDWCryptType;
      vStringComparer       := vTokenValue.vCripto.Decrypt(vStringComparer);
      Result                := vStringComparer = vHeader + '.' + vBody;
      If Result Then
       Begin
        Result              := False;
        vHeader             := DecodeStrings(vHeader{$IFDEF FPC}, csUndefined{$ENDIF});
        vBody               := DecodeStrings(vBody{$IFDEF FPC},   csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(vBody)  {$IFDEF FPC}, csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(Secrets){$IFDEF FPC}, csUndefined{$ENDIF});
        Result              := ReadBody(vBody);
       End;
     Finally
      FreeAndNil(vTokenValue);
     End;
    End;
  End;
End;

Function  TRDWAuthOptionBearerServer.GetToken(aSecrets : String = '') : String;
Var
 vTokenValue : TTokenValue;
Begin
 vTokenValue           := TTokenValue.Create;
 vTokenValue.TokenHash := vTokenHash;
 vTokenValue.CryptType := vRDWCryptType;
 If Trim(ServerSignature) <> '' Then
  vTokenValue.Iss      := vTokenValue.vCripto.Encrypt(ServerSignature);
 vTokenValue.Secrets   := aSecrets;
 vTokenValue.BeginTime := Now;
 If vLifeCycle > 0 Then
  vTokenValue.EndTime  := IncSecond(vTokenValue.BeginTime, vLifeCycle);
 Try
  Result               := vTokenValue.ToToken;
 Finally
  FreeAndNil(vTokenValue);
 End;
End;

Destructor TRDWClientAuthOptionParams.Destroy;
Begin
 DestroyParam;
 Inherited;
End;

Procedure   TRDWServerAuthOptionParams.CopyServerAuthParams(Var Value : TRDWAuthOptionParam);
Begin
 If RDWAuthOptionParam is TRDWAuthTokenParam Then
  Begin
   If Value <> Nil Then
    FreeAndNil(Value);
   Value                                     := TRDWAuthTokenParam.Create;
   TRDWAuthTokenParam(Value).TokenType       := TRDWAuthTokenParam(RDWAuthOptionParam).TokenType;
   TRDWAuthTokenParam(Value).CryptType       := TRDWAuthTokenParam(RDWAuthOptionParam).CryptType;
   TRDWAuthTokenParam(Value).GetTokenEvent   := TRDWAuthTokenParam(RDWAuthOptionParam).GetTokenEvent;
   TRDWAuthTokenParam(Value).TokenHash       := TRDWAuthTokenParam(RDWAuthOptionParam).TokenHash;
   TRDWAuthTokenParam(Value).ServerSignature := TRDWAuthTokenParam(RDWAuthOptionParam).ServerSignature;
   TRDWAuthTokenParam(Value).LifeCycle       := TRDWAuthTokenParam(RDWAuthOptionParam).LifeCycle;
   TRDWAuthTokenParam(Value).AuthDialog               := TRDWAuthTokenParam(RDWAuthOptionParam).AuthDialog;
   TRDWAuthTokenParam(Value).Key                      := TRDWAuthTokenParam(RDWAuthOptionParam).Key;
   TRDWAuthTokenParam(Value).CustomDialogAuthMessage  := TRDWAuthTokenParam(RDWAuthOptionParam).CustomDialogAuthMessage;
   TRDWAuthTokenParam(Value).Custom404TitleMessage    := TRDWAuthTokenParam(RDWAuthOptionParam).Custom404TitleMessage;
   TRDWAuthTokenParam(Value).Custom404BodyMessage     := TRDWAuthTokenParam(RDWAuthOptionParam).Custom404BodyMessage;
   TRDWAuthTokenParam(Value).Custom404FooterMessage   := TRDWAuthTokenParam(RDWAuthOptionParam).Custom404FooterMessage;
   TRDWAuthTokenParam(Value).CustomAuthErrorPage.Text := TRDWAuthTokenParam(RDWAuthOptionParam).CustomAuthErrorPage.Text;
  End
 Else If RDWAuthOptionParam is TRDWAuthOptionBasic Then
  Begin
   If Value <> Nil Then
    FreeAndNil(Value);
   Value                                               := TRDWAuthOptionBasic.Create;
   TRDWAuthOptionBasic(Value).Username                 := TRDWAuthOptionBasic(RDWAuthOptionParam).Username;
   TRDWAuthOptionBasic(Value).Password                 := TRDWAuthOptionBasic(RDWAuthOptionParam).Password;
   TRDWAuthOptionBasic(Value).AuthDialog               := TRDWAuthOptionBasic(RDWAuthOptionParam).AuthDialog;
   TRDWAuthOptionBasic(Value).CustomDialogAuthMessage  := TRDWAuthOptionBasic(RDWAuthOptionParam).CustomDialogAuthMessage;
   TRDWAuthOptionBasic(Value).Custom404TitleMessage    := TRDWAuthOptionBasic(RDWAuthOptionParam).Custom404TitleMessage;
   TRDWAuthOptionBasic(Value).Custom404BodyMessage     := TRDWAuthOptionBasic(RDWAuthOptionParam).Custom404BodyMessage;
   TRDWAuthOptionBasic(Value).Custom404FooterMessage   := TRDWAuthOptionBasic(RDWAuthOptionParam).Custom404FooterMessage;
   TRDWAuthOptionBasic(Value).CustomAuthErrorPage.Text := TRDWAuthOptionBasic(RDWAuthOptionParam).CustomAuthErrorPage.Text;
  End;
End;

Destructor TRDWServerAuthOptionParams.Destroy;
Begin
 DestroyParam;
 Inherited;
End;

Procedure TRDWClientAuthOptionParams.Assign(Source: TPersistent);
Var
 Src : TRDWClientAuthOptionParams;
Begin
 If Source is TRDWClientAuthOptionParams Then
  Begin
   Src := TRDWClientAuthOptionParams(Source);
   SetAuthOption(Src.AuthorizationOption);
   Case RDWAuthOption Of
    rdwAOBasic  : Begin
                   TRDWAuthOptionBasic(RDWAuthOptionParam).Username := TRDWAuthOptionBasic(Src.OptionParams).Username;
                   TRDWAuthOptionBasic(RDWAuthOptionParam).Password := TRDWAuthOptionBasic(Src.OptionParams).Password;
                  End;
    rdwAOBearer : Begin
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).TokenType        := TRDWAuthOptionBearerClient(Src.OptionParams).TokenType;
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).TokenRequestType := TRDWAuthOptionBearerClient(Src.OptionParams).TokenRequestType;
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).Token            := TRDWAuthOptionBearerClient(Src.OptionParams).Token;
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).GetTokenEvent    := TRDWAuthOptionBearerClient(Src.OptionParams).GetTokenEvent;
                   // Eloy
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).AutoGetToken     := TRDWAuthOptionBearerClient(Src.OptionParams).AutoGetToken;
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).AutoRenewToken   := TRDWAuthOptionBearerClient(Src.OptionParams).AutoRenewToken;
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).AuthDialog       := TRDWAuthOptionBearerClient(Src.OptionParams).AuthDialog;
                   TRDWAuthOptionBearerClient(RDWAuthOptionParam).Key              := TRDWAuthOptionBearerClient(Src.OptionParams).Key;
                  End;
    rdwAOToken  : Begin
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).TokenType        := TRDWAuthOptionTokenClient(Src.OptionParams).TokenType;
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).TokenRequestType := TRDWAuthOptionTokenClient(Src.OptionParams).TokenRequestType;
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).Token            := TRDWAuthOptionTokenClient(Src.OptionParams).Token;
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).GetTokenEvent    := TRDWAuthOptionTokenClient(Src.OptionParams).GetTokenEvent;
                   // Eloy
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).AutoGetToken     := TRDWAuthOptionTokenClient(Src.OptionParams).AutoGetToken;
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).AutoRenewToken   := TRDWAuthOptionTokenClient(Src.OptionParams).AutoRenewToken;
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).AuthDialog       := TRDWAuthOptionTokenClient(Src.OptionParams).AuthDialog;
                   TRDWAuthOptionTokenClient(RDWAuthOptionParam).Key              := TRDWAuthOptionTokenClient(Src.OptionParams).Key;
                  End;
   End;
  End
 Else
  Inherited Assign(Source);
End;

Procedure TRDWServerAuthOptionParams.Assign(Source: TPersistent);
Var
 Src : TRDWServerAuthOptionParams;
Begin
 If Source is TRDWServerAuthOptionParams Then
  Begin
   Src                := TRDWServerAuthOptionParams(Source);
   SetAuthOption(Src.AuthorizationOption);
   Case RDWAuthOption Of
    rdwAOBasic  : Begin
                   TRDWAuthOptionBasic(RDWAuthOptionParam).Username := TRDWAuthOptionBasic(Src.OptionParams).Username;
                   TRDWAuthOptionBasic(RDWAuthOptionParam).Password := TRDWAuthOptionBasic(Src.OptionParams).Password;
                  End;
    rdwAOBearer : Begin
                   TRDWAuthOptionBearerServer(RDWAuthOptionParam).TokenType       := TRDWAuthOptionBearerServer(Src.OptionParams).TokenType;
                   TRDWAuthOptionBearerServer(RDWAuthOptionParam).CryptType       := TRDWAuthOptionBearerServer(Src.OptionParams).CryptType;
                   TRDWAuthOptionBearerServer(RDWAuthOptionParam).GetTokenEvent   := TRDWAuthOptionBearerServer(Src.OptionParams).GetTokenEvent;
                   TRDWAuthOptionBearerServer(RDWAuthOptionParam).TokenHash       := TRDWAuthOptionBearerServer(Src.OptionParams).TokenHash;
                   TRDWAuthOptionBearerServer(RDWAuthOptionParam).ServerSignature := TRDWAuthOptionBearerServer(Src.OptionParams).ServerSignature;
                   TRDWAuthOptionBearerServer(RDWAuthOptionParam).LifeCycle       := TRDWAuthOptionBearerServer(Src.OptionParams).LifeCycle;
                  End;
    rdwAOToken  : Begin
                   TRDWAuthOptionTokenServer(RDWAuthOptionParam).TokenType       := TRDWAuthOptionTokenServer(Src.OptionParams).TokenType;
                   TRDWAuthOptionTokenServer(RDWAuthOptionParam).CryptType       := TRDWAuthOptionTokenServer(Src.OptionParams).CryptType;
                   TRDWAuthOptionTokenServer(RDWAuthOptionParam).GetTokenEvent   := TRDWAuthOptionTokenServer(Src.OptionParams).GetTokenEvent;
                   TRDWAuthOptionTokenServer(RDWAuthOptionParam).TokenHash       := TRDWAuthOptionTokenServer(Src.OptionParams).TokenHash;
                   TRDWAuthOptionTokenServer(RDWAuthOptionParam).ServerSignature := TRDWAuthOptionTokenServer(Src.OptionParams).ServerSignature;
                   TRDWAuthOptionTokenServer(RDWAuthOptionParam).LifeCycle       := TRDWAuthOptionTokenServer(Src.OptionParams).LifeCycle;
                  End;
   End;
  End
 Else
  Inherited Assign(Source);
End;

Constructor TRDWAuthOAuth.Create;
Begin
 inherited;
 vClientID      := '';
 vClientSecret  := '';
 vToken         := '';
 vRedirectURI   := '';
 vGrantType     := 'client_credentials';
 vGetTokenName  := 'access-token';
 vGrantCodeName := 'authorize';
 vAutoBuildHex  := False;
 vExpiresin     := 0;
 vRDWTokenType  := rdwOATBasic;
End;

Constructor TRDWAuthOptionBasic.Create;
Begin
 inherited;
 vUserName := 'testserver';
 vPassword := vUserName;
End;

Constructor TRDWAuthOptionTokenClient.Create;
Begin
 inherited;
 vToken          := '';
 vRDWTokenType   := rdwTS;
 vTokenRequest   := rdwtHeader;
 vSecrets        := '';
 vGetTokenName   := 'GetToken';
 vTokenName      := 'token';
 vAutoGetToken   := True;
 vAutoRenewToken := True;
 vInitRequest    := 0;
 vFinalRequest   := 0;
End;

Constructor TRDWAuthTokenParam.Create;
Begin
 inherited;
 vTokenHash       := 'RDWTS_HASH0011';
 vServerSignature := 'RESTDWServer01';
 vGetTokenName    := 'GetToken';
 vTokenName       := 'token';
 vLifeCycle       := 1800;//30 Minutos
 vRDWTokenType    := rdwTS;
 vRDWCryptType    := rdwAES256;
 vServerSignature := '';
 vInitRequest     := 0;
 vFinalRequest    := 0;
 vSecrets         := '';
 vDWRoutes        := [crAll];
End;

Procedure TRDWAuthTokenParam.Assign(Source: TPersistent);
Var
 Src : TRDWAuthTokenParam;
Begin
 If Source is TRDWAuthTokenParam Then
  Begin
   Src             := TRDWAuthTokenParam(Source);
   TokenType       := Src.TokenType;
   CryptType       := Src.CryptType;
   GetTokenEvent   := Src.GetTokenEvent;
   TokenHash       := Src.TokenHash;
   ServerSignature := Src.ServerSignature;
   LifeCycle       := Src.LifeCycle;
  End
 Else
  Inherited Assign(Source);
End;

Destructor  TRDWAuthTokenParam.Destroy;
Begin
 Inherited;
End;

Procedure   TRDWAuthTokenParam.SetTokenHash(Token : String);
Begin
 vTokenHash := Token;
End;

Function    TRDWAuthTokenParam.GetTokenType   (Value : String) : TRDWTokenType;
Begin
 Result := rdwTS;
 If Lowercase(Value) = 'jwt' Then
  Result := rdwJWT
 Else If Lowercase(Value) = 'rdwcustom' Then
  Result := rdwPersonal;
End;

Function    TRDWAuthTokenParam.GetCryptType   (Value : String) : TRDWCryptType;
Begin
 Result := rdwAES256;
 If Lowercase(Value) = 'hs256' Then
  Result := rdwHSHA256
 Else If Lowercase(Value) = 'rsa' Then
  Result := rdwRSA;
End;

Procedure   TRDWAuthTokenParam.SetCryptType   (Value : TRDWCryptType);
Begin
 vRDWCryptType := Value;
End;

Procedure   TRDWAuthTokenParam.SetGetTokenName(Value : String);
Begin
 If Length(Value) > 0 Then
  vGetTokenName := Value
 Else
  Raise Exception.Create('Invalid GetTokenName');
End;

Procedure TRDWAuthOptionTokenClient.ClearToken;
Begin
 vSecrets      := '';
 vToken        := '';
 vInitRequest  := 0;
 vFinalRequest := 0;
End;

Procedure TRDWAuthOptionTokenClient.SetToken(Value : String);
Begin
 ClearToken;
 vToken        := Value;
 If vToken <> '' Then
  FromToken(vToken);
End;

Procedure TRDWAuthOptionBearerClient.ClearToken;
Begin
 vSecrets      := '';
 vToken        := '';
 vInitRequest  := 0;
 vFinalRequest := 0;
End;

Procedure TRDWAuthOptionBearerClient.SetToken(Value : String);
Begin
 ClearToken;
 vToken        := Value;
 If vToken <> '' Then
  FromToken(vToken)
End;

Constructor TRDWAuthOptionBearerClient.Create;
Begin
 inherited;
 vRDWTokenType   := rdwTS;
 vTokenRequest   := rdwtHeader;
 vToken          := '';
 vSecrets        := '';
 vGetTokenName   := 'GetToken';
 vTokenName      := 'token';
 vAutoGetToken   := True;
 vAutoRenewToken := True;
 vInitRequest    := 0;
 vFinalRequest   := 0;
End;

Constructor TRDWAuthRequest.Create;
Begin
 vToken := '';
End;

Constructor TRDWClientAuthOptionParams.Create(AOwner: TPersistent);
Begin
 inherited Create;
 FOwner             := AOwner;
 RDWAuthOption      := rdwAONone;
 RDWAuthOptionParam := Nil;
End;

Constructor TRDWServerAuthOptionParams.Create(AOwner: TPersistent);
Begin
 inherited Create;
 FOwner             := AOwner;
 RDWAuthOption      := rdwAONone;
 RDWAuthOptionParam := Nil;
End;

Procedure TRDWClientAuthOptionParams.DestroyParam;
Begin
 {$IFDEF FPC}
 If Not(csDesigning in TComponent(GetOwner).ComponentState) Then
  Begin
   If Assigned(RDWAuthOptionParam) Then
    FreeAndNil(RDWAuthOptionParam);
  End
 Else
  Begin
   If RDWAuthOption = rdwAONone Then
    RDWAuthOptionParam := Nil;
  End;
 {$ELSE}
 If Assigned(RDWAuthOptionParam) Then
  FreeAndNil(RDWAuthOptionParam);
 {$ENDIF}
End;

Procedure TRDWServerAuthOptionParams.DestroyParam;
Begin
 {$IFDEF FPC}
 If Not(csDesigning in TComponent(GetOwner).ComponentState) Then
  Begin
   If Assigned(RDWAuthOptionParam) Then
    FreeAndNil(RDWAuthOptionParam);
  End
 Else
  Begin
   If RDWAuthOption = rdwAONone Then
    RDWAuthOptionParam := Nil;
  End;
 {$ELSE}
 If Assigned(RDWAuthOptionParam) Then
  FreeAndNil(RDWAuthOptionParam);
 {$ENDIF}
End;

Procedure TRDWClientAuthOptionParams.SetAuthOption(Value : TRDWAuthOption);
Begin
 RDWAuthOption := Value;
 DestroyParam;
 Case Value Of
  rdwAOBasic  : RDWAuthOptionParam := TRDWAuthOptionBasic.Create;
  rdwAOBearer : RDWAuthOptionParam := TRDWAuthOptionBearerClient.Create;
  rdwAOToken  : RDWAuthOptionParam := TRDWAuthOptionTokenClient.Create;
  rdwOAuth    : RDWAuthOptionParam := TRDWAuthOAuth.Create;
 End;
End;

Procedure TRDWServerAuthOptionParams.SetAuthOption(Value : TRDWAuthOption);
Begin
 RDWAuthOption := Value;
 DestroyParam;
 Case Value Of
  rdwAOBasic  : RDWAuthOptionParam := TRDWAuthOptionBasic.Create;
  rdwAOBearer : RDWAuthOptionParam := TRDWAuthOptionBearerServer.Create;
  rdwAOToken  : RDWAuthOptionParam := TRDWAuthOptionTokenServer.Create;
  rdwOAuth    : Raise Exception.Create(cNotWorkYet);
 End;
End;

Function TRDWClientAuthOptionParams.GetOwner: TPersistent;
Begin
 Result := FOwner;
End;

Function TRDWServerAuthOptionParams.GetOwner: TPersistent;
Begin
 Result := FOwner;
End;

//{ TRDWAuthOptionParam }
//
//Procedure TRDWAuthOptionParam.Assign(Source: TPersistent);
//Begin
// If Source is TRDWAuthTokenParam Then
//  Begin
//   {$IFNDEF FPC}
//    {$IF Defined(HAS_FMX)}
//     {$IFDEF HAS_UTF8}
//      If Self <> Nil Then
//       Begin
//        Self.DisposeOf;
//        Self := Nil;
//       End;
//     {$ELSE}
//      If Self <> Nil Then
//       FreeAndNil(Self);
//     {$ENDIF}
//    {$ELSE}
//     If Self <> Nil Then
//      Self.Free;
//    {$IFEND}
//   {$ELSE}
//    If Self <> Nil Then
//     FreeAndNil(Self);
//   {$ENDIF}
//   Self                                     := TRDWAuthTokenParam.Create;
//   TRDWAuthTokenParam(Self).TokenType       := TRDWAuthTokenParam(Source).TokenType;
//   TRDWAuthTokenParam(Self).CryptType       := TRDWAuthTokenParam(Source).CryptType;
//   TRDWAuthTokenParam(Self).GetTokenEvent   := TRDWAuthTokenParam(Source).GetTokenEvent;
//   TRDWAuthTokenParam(Self).TokenHash       := TRDWAuthTokenParam(Source).TokenHash;
//   TRDWAuthTokenParam(Self).ServerSignature := TRDWAuthTokenParam(Source).ServerSignature;
//   TRDWAuthTokenParam(Self).LifeCycle       := TRDWAuthTokenParam(Source).LifeCycle;
//  End
// Else If Source is TRDWAuthOptionBasic Then
//  Begin
//   If Self <> Nil Then
//    FreeAndNil(Self);
//   Self                                     := TRDWAuthOptionBasic.Create;
//   TRDWAuthOptionBasic(Self).Username       := TRDWAuthOptionBasic(Source).Username;
//   TRDWAuthOptionBasic(Self).Password       := TRDWAuthOptionBasic(Source).Password;
//  End
// Else
//  Inherited Assign(Source);
//End;

Constructor TRDWAuthOptionParam.Create;
Begin
 vCustomAuthMessage      := 'Protected Space...';
 vCustom404TitleMessage  := '(404) The address you are looking for does not exist';
 vCustom404BodyMessage   := '404';
 vCustom404FooterMessage := 'Take me back to <a href="./">Home REST Dataware';
 vAuthDialog             := True;
 vCustomAuthErrorPage    := TStringList.Create;
End;

Destructor TRDWAuthOptionParam.Destroy;
Begin
 FreeAndNil(vCustomAuthErrorPage);
 Inherited;
End;

Procedure TRDWAuthOptionParam.SetCustomAuthErrorPage(Value: TStringList);
Var
 I : Integer;
Begin
 vCustomAuthErrorPage.Clear;
 For I := 0 To Value.Count -1 do
  vCustomAuthErrorPage.Add(Value[I]);
End;

end.

