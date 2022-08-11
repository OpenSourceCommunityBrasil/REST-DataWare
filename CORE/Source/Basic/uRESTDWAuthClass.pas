unit uRESTDWAuthClass;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
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
  Classes,  SysUtils,
  {$ELSE}
  Classes,  SysUtils,
  StringBuilderUnit,
  {$ENDIF}
  DateUtils,
  uRESTDWTools, uRESTDWConsts, uRESTDWBasicTypes, uRESTDWEncodeClass, uRESTDWCharset,
  uRESTDWDataUtils;

Type
 TRESTDWAuthOptionTypes = (rdwOATBasic, rdwOATBearer, rdwOATToken);
 TRESTDWAuthOption      = (rdwAONone,   rdwAOBasic,   rdwAOBearer,
                        rdwAOToken,  rdwOAuth);
 TRESTDWTokenType       = (rdwTS,       rdwJWT,       rdwPersonal);
 TRESTDWAuthOptions     = Set of TRESTDWAuthOption;
 TRESTDWCryptType       = (rdwAES256,   rdwHSHA256,   rdwRSA);
 TRESTDWTokenRequest    = (rdwtHeader,  rdwtRequest);

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
  vRDWTokenType         : TRESTDWTokenType;
  vRDWCryptType         : TRESTDWCryptType;
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
  Property       TokenType         : TRESTDWTokenType Read vRDWTokenType      Write vRDWTokenType;
  Property       CryptType         : TRESTDWCryptType Read vRDWCryptType      Write vRDWCryptType;
  Property       BeginTime         : TDateTime        Read vInitRequest       Write vInitRequest;
  Property       EndTime           : TDateTime        Read vFinalRequest      Write SetFinalRequest;
  Property       Iss               : String           Read vServerSignature   Write vServerSignature;
  Property       Secrets           : String           Read vSecrets           Write SetSecrets;
  Property       TokenHash         : String           Read vTokenHash         Write SetTokenHash;
  Property       Token             : String           Read ToToken;
End;

Type

 { TRESTDWAuthOptionParam }

 TRESTDWAuthOptionParam = Class(TPersistent)
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

 { TRESTDWAuthTokenParam }

 TRESTDWAuthTokenParam = Class(TRESTDWAuthOptionParam)
 Private
  vInitRequest,
  vFinalRequest : TDateTime;
  vServerSignature,
  vSecrets,
  vGetTokenName,
  vTokenName,
  vTokenHash    : String;
  vDWRoutes     : TRESTDWRoutes;
  vLifeCycle    : Integer;
  vRDWTokenType : TRESTDWTokenType;
  vRDWCryptType : TRESTDWCryptType;
  Procedure   SetTokenHash   (Token : String);
  Procedure   SetGetTokenName(Value : String);
  Procedure   SetCryptType   (Value : TRESTDWCryptType);
  Function    GetTokenType   (Value : String) : TRESTDWTokenType;
  Function    GetCryptType   (Value : String) : TRESTDWCryptType;
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
  Property    TokenType         : TRESTDWTokenType Read vRDWTokenType    Write vRDWTokenType;
  Property    CryptType         : TRESTDWCryptType Read vRDWCryptType    Write SetCryptType;
  Property    Key               : String        Read vTokenName       Write vTokenName;
  Property    GetTokenEvent     : String        Read vGetTokenName    Write SetGetTokenName;
  Property    GetTokenRoutes    : TRESTDWRoutes     Read vDWRoutes        Write vDWRoutes;
  Property    TokenHash         : String        Read vTokenHash       Write SetTokenHash;
  Property    ServerSignature   : String        Read vServerSignature Write vServerSignature;
  Property    LifeCycle         : Integer       Read vLifeCycle       Write vLifeCycle;
End;


Type

 { TRESTDWAuthOptionBasic }

 TRESTDWAuthOptionBasic = Class(TRESTDWAuthOptionParam)
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

 { TRESTDWAuthOAuth }

 TRESTDWAuthOAuth = Class(TRESTDWAuthOptionParam)
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
  vRDWTokenType : TRESTDWAuthOptionTypes;
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   GetGrantCode;
  Procedure   GetGetToken;
 Published
  Property    TokenType      : TRESTDWAuthOptionTypes Read vRDWTokenType  Write vRDWTokenType;
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

 { TRESTDWAuthOptionBearerClient }

 TRESTDWAuthOptionBearerClient = Class(TRESTDWAuthOptionParam)
 Private
  vGetTokenName,
  vSecrets,
  vTokenName,
  vToken           : String;
  vRDWTokenType    : TRESTDWTokenType;
  vInitRequest,
  vFinalRequest    : TDateTime;
  vAutoRenewToken,
  vAutoGetToken    : Boolean;
  vTokenRequest    : TRESTDWTokenRequest;
  Procedure ClearToken;
  Procedure SetToken(Value : String);
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   FromToken(TokenValue : String);
 Published
  Property    TokenType        : TRESTDWTokenType    Read vRDWTokenType    Write vRDWTokenType;
  Property    TokenRequestType : TRESTDWTokenRequest Read vTokenRequest    Write vTokenRequest;
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

 { TRESTDWAuthOptionTokenClient }

 TRESTDWAuthOptionTokenClient = Class(TRESTDWAuthOptionParam)
 Private
  vSecrets,
  vGetTokenName,
  vTokenName,
  vToken           : String;
  vTokenRequest    : TRESTDWTokenRequest;
  vRDWTokenType    : TRESTDWTokenType;
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
  Property    TokenType        : TRESTDWTokenType    Read vRDWTokenType    Write vRDWTokenType;
  Property    TokenRequestType : TRESTDWTokenRequest Read vTokenRequest    Write vTokenRequest;
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

 { TRESTDWAuthOptionBearerServer }

 TRESTDWAuthOptionBearerServer = Class(TRESTDWAuthTokenParam)
 Private
 Protected
 Public
  Function    GetToken (aSecrets : String = '') : String;  Override;
  Function    FromToken(Value    : String)      : Boolean; Override;
End;

Type
 TRESTDWAuthOptionTokenServer = Class(TRESTDWAuthTokenParam)
 Private
 Protected
 Public
  Function    GetToken(aSecrets  : String = '') : String;  Override;
  Function    FromToken(Value    : String)      : Boolean; Override;
End;

Type

 { TRESTDWServerAuthOptionParams }

 TRESTDWServerAuthOptionParams = Class(TPersistent)
 Private
  FOwner                          : TPersistent;
  RDWAuthOptionParam              : TRESTDWAuthOptionParam;
  RDWAuthOption                   : TRESTDWAuthOption;
  Procedure   DestroyParam;
  Procedure   SetAuthOption(Value : TRESTDWAuthOption);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner       : TPersistent);
  Procedure   Assign(Source       : TPersistent); Override;
  Destructor  Destroy;Override;
  Procedure   CopyServerAuthParams(Var Value : TRESTDWAuthOptionParam);
 Published
  Property AuthorizationOption    : TRESTDWAuthOption       Read RDWAuthOption      Write SetAuthOption;
  Property OptionParams           : TRESTDWAuthOptionParam  Read RDWAuthOptionParam Write RDWAuthOptionParam;
End;

Type

 { TRESTDWClientAuthOptionParams }

 TRESTDWClientAuthOptionParams = Class(TPersistent)
 Private
  FOwner                          : TPersistent;
  RDWAuthOptionParam              : TRESTDWAuthOptionParam;
  RDWAuthOption                   : TRESTDWAuthOption;
  Procedure   DestroyParam;
  Procedure   SetAuthOption(Value : TRESTDWAuthOption);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner       : TPersistent);
  Procedure   Assign(Source       : TPersistent); Override;
  Destructor  Destroy;Override;
 Published
  Property AuthorizationOption    : TRESTDWAuthOption       Read RDWAuthOption      Write SetAuthOption;
  Property OptionParams           : TRESTDWAuthOptionParam  Read RDWAuthOptionParam Write RDWAuthOptionParam;
End;

Type

 { TRESTDWAuthRequest }

 TRESTDWAuthRequest = Class
 Private
  vToken : String;
 Public
  Constructor Create;
  Property Token : String Read vToken Write vToken;
End;

Function GettokenValue  (Value      : String) : String;
Function GetTokenType   (Value      : String) : TRESTDWTokenType;

implementation

Uses uRESTDWMD5, uRESTDWJSONInterface;

function GettokenValue(Value: String): String;
begin

end;

function GetTokenType(Value: String): TRESTDWTokenType;
begin

end;

{ TRESTDWServerAuthOptionParams }

procedure TRESTDWServerAuthOptionParams.DestroyParam;
begin

end;

procedure TRESTDWServerAuthOptionParams.SetAuthOption(Value: TRESTDWAuthOption);
begin

end;

function TRESTDWServerAuthOptionParams.GetOwner: TPersistent;
begin
  Result := inherited GetOwner;
end;

constructor TRESTDWServerAuthOptionParams.Create(AOwner: TPersistent);
begin

end;

procedure TRESTDWServerAuthOptionParams.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

destructor TRESTDWServerAuthOptionParams.Destroy;
begin
  inherited Destroy;
end;

procedure TRESTDWServerAuthOptionParams.CopyServerAuthParams(var
  Value: TRESTDWAuthOptionParam);
begin

end;

{ TRESTDWAuthOptionBearerServer }

function TRESTDWAuthOptionBearerServer.GetToken(aSecrets: String): String;
begin

end;

function TRESTDWAuthOptionBearerServer.FromToken(Value: String): Boolean;
begin

end;

{ TRESTDWClientAuthOptionParams }

procedure TRESTDWClientAuthOptionParams.DestroyParam;
begin

end;

procedure TRESTDWClientAuthOptionParams.SetAuthOption(Value: TRESTDWAuthOption);
begin

end;

function TRESTDWClientAuthOptionParams.GetOwner: TPersistent;
begin
  Result := inherited GetOwner;
end;

constructor TRESTDWClientAuthOptionParams.Create(AOwner: TPersistent);
begin

end;

procedure TRESTDWClientAuthOptionParams.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

destructor TRESTDWClientAuthOptionParams.Destroy;
begin
  inherited Destroy;
end;

{ TRESTDWAuthRequest }

constructor TRESTDWAuthRequest.Create;
begin

end;

{ TRESTDWAuthTokenParam }

procedure TRESTDWAuthTokenParam.SetTokenHash(Token: String);
begin

end;

procedure TRESTDWAuthTokenParam.SetGetTokenName(Value: String);
begin

end;

procedure TRESTDWAuthTokenParam.SetCryptType(Value: TRESTDWCryptType);
begin

end;

function TRESTDWAuthTokenParam.GetTokenType(Value: String): TRESTDWTokenType;
begin

end;

function TRESTDWAuthTokenParam.GetCryptType(Value: String): TRESTDWCryptType;
begin

end;

constructor TRESTDWAuthTokenParam.Create;
begin

end;

destructor TRESTDWAuthTokenParam.Destroy;
begin
  inherited Destroy;
end;

procedure TRESTDWAuthTokenParam.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

{ TRESTDWAuthOptionParam }

procedure TRESTDWAuthOptionParam.SetCustomAuthErrorPage(Value: TStringList);
begin

end;

constructor TRESTDWAuthOptionParam.Create;
begin

end;

destructor TRESTDWAuthOptionParam.Destroy;
begin
  inherited Destroy;
end;

Class Function TTokenValue.GetMD5(Const Value : String) : String;
Begin
 Try
  Result := MD5DigestToStr(MD5String(Value));
 Finally
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

procedure TRESTDWAuthOAuth.GetGetToken;
Begin

End;

procedure TRESTDWAuthOAuth.GetGrantCode;
Begin

End;

constructor TRESTDWAuthOAuth.Create;
begin

end;

procedure TRESTDWAuthOAuth.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthOAuth;
Begin
 If Source is TRESTDWAuthOAuth Then
  Begin
   Src                := TRESTDWAuthOAuth(Source);
   vAutoBuildHex      := Src.AutoBuildHex;
   vClientID          := Src.ClientID;
   vClientSecret      := Src.ClientSecret;
   vGrantCodeName     := Src.GrantCodeEvent;
   vGetTokenName      := Src.GetTokenEvent;
  End
 Else
  Inherited Assign(Source);
End;

constructor TRESTDWAuthOptionBasic.Create;
begin

end;

procedure TRESTDWAuthOptionBasic.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthOptionBasic;
Begin
 If Source is TRESTDWAuthOptionBasic Then
  Begin
   Src                := TRESTDWAuthOptionBasic(Source);
   vUserName          := Src.Username;
   vPassword          := Src.Password;
  End
 Else
  Inherited Assign(Source);
End;

procedure TRESTDWAuthOptionTokenClient.FromToken(TokenValue: String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
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
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
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
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vBody{$IFDEF FPC}, csUndefined{$ENDIF}));
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

procedure TRESTDWAuthOptionTokenClient.ClearToken;
begin

end;

procedure TRESTDWAuthOptionTokenClient.SetToken(Value: String);
begin

end;

constructor TRESTDWAuthOptionTokenClient.Create;
begin

end;

procedure TRESTDWAuthOptionTokenClient.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthOptionTokenClient;
Begin
 If Source is TRESTDWAuthOptionTokenClient Then
  Begin
   Src           := TRESTDWAuthOptionTokenClient(Source);
   vToken        := Src.Token;
  End
 Else
  Inherited Assign(Source);
End;

Function  TRESTDWAuthOptionTokenServer.FromToken(Value : String)    : Boolean;
Var
 vHeader,
 vBody,
 vStringComparer : String;
 vTokenValue     : TTokenValue;
 Function ReadHeader(Value : String) : Boolean;
 Var
  bJsonValue     : TRESTDWJSONInterfaceObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue    := TRESTDWJSONInterfaceObject.Create(Value);
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
  bJsonValue     : TRESTDWJSONInterfaceObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue            := TRESTDWJSONInterfaceObject.Create(Value);
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

Function  TRESTDWAuthOptionTokenServer.GetToken(aSecrets   : String = '') : String;
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

procedure TRESTDWAuthOptionBearerClient.ClearToken;
begin

end;

procedure TRESTDWAuthOptionBearerClient.SetToken(Value: String);
begin

end;

constructor TRESTDWAuthOptionBearerClient.Create;
begin

end;

procedure TRESTDWAuthOptionBearerClient.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

procedure TRESTDWAuthOptionBearerClient.FromToken(TokenValue: String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
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
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
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
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vBody{$IFDEF FPC}, csUndefined{$ENDIF}));
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

end.
