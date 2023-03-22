unit uRESTDWAuthenticators;

{$I ..\..\Includes\uRESTDW.inc}

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

uses
  Classes, SysUtils, DateUtils,
  uRESTDWConsts, uRESTDWAbout, uRESTDWDataUtils, uRESTDWJSONInterface, uRESTDWTools;

type
  TRESTDWAuthenticatorBase = class(TRESTDWComponent)

  end;

  TRESTDWAuthMessages = class(TPersistent)
  private
    FAuthDialog             : Boolean;
    FCustomDialogAuthMessage: String;
    FCustom404TitleMessage  : String;
    FCustom404BodyMessage   : String;
    FCustom404FooterMessage : String;
    FCustomAuthErrorPage    : TStringList;
    procedure SetCustomAuthErrorPage(AValue: TStringList);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property AuthDialog             : Boolean     read FAuthDialog              write FAuthDialog;
    property CustomDialogAuthMessage: String      read FCustomDialogAuthMessage write FCustomDialogAuthMessage;
    property Custom404TitleMessage  : String      read FCustom404TitleMessage   write FCustom404TitleMessage;
    property Custom404BodyMessage   : String      read FCustom404BodyMessage    write FCustom404BodyMessage;
    property Custom404FooterMessage : String      read FCustom404FooterMessage  write FCustom404FooterMessage;
    property CustomAuthErrorPage    : TStringList read FCustomAuthErrorPage     write SetCustomAuthErrorPage;
  end;

  TRESTDWAuthBasic = class(TRESTDWAuthenticatorBase)
  private
    FPassword: String;
    FUserName: String;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
  end;

  TRESTDWAuthToken = class(TRESTDWAuthenticatorBase)
  private
    FBeginTime       : TDateTime;
    FEndTime         : TDateTime;
    FSecrets         : String;
    FServerSignature : String;
    FTokenType       : TRESTDWTokenType;
    FCryptType       : TRESTDWCryptType;
    FTokenRequestType: TRESTDWTokenRequest;
    FKey             : String;
    FGetTokenEvent   : String;
    FGetTokenRoutes  : TRESTDWRoutes;
    FTokenHash       : String;
    FLifeCycle       : Integer;
    FToken           : String;
    FAutoGetToken    : Boolean;
    FAutoRenewToken  : Boolean;
    procedure ClearToken;
    procedure SetGetTokenEvent(AValue: String);
    procedure SetToken        (AValue: String);
    function  GetTokenType    (AValue: String): TRESTDWTokenType;
    function  GetCryptType    (AValue: String): TRESTDWCryptType;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent);
    procedure FromToken(ATokenValue: String);
    function GetToken(ASecrets: String): String;
    function ValidateToken(AValue: String): Boolean; overload;
  published
    property BeginTime       : TDateTime           read FBeginTime        write FBeginTime;
    property EndTime         : TDateTime           read FEndTime          write FEndTime;
    property Secrets         : String              read FSecrets          write FSecrets;
    property TokenType       : TRESTDWTokenType    read FTokenType        write FTokenType;
    property CryptType       : TRESTDWCryptType    read FCryptType        write FCryptType;
    property TokenRequestType: TRESTDWTokenRequest Read FTokenRequestType write FTokenRequestType;
    property Key             : String              read FKey              write FKey;
    property GetTokenEvent   : String              read FGetTokenEvent    write SetGetTokenEvent;
    property GetTokenRoutes  : TRESTDWRoutes       read FGetTokenRoutes   write FGetTokenRoutes;
    property TokenHash       : String              read FTokenHash        write FTokenHash;
    property ServerSignature : String              read FServerSignature  write FServerSignature;
    property LifeCycle       : Integer             read FLifeCycle        write FLifeCycle;
    property Token           : String              read FToken            write SetToken;
    property AutoGetToken    : Boolean             read FAutoGetToken     write FAutoGetToken;
    property AutoRenewToken  : Boolean             read FAutoRenewToken   write FAutoRenewToken;
  end;

  TRESTDWAuthOAuth = class(TRESTDWAuthenticatorBase)
  private
    FTokenType     : TRESTDWAuthOptionTypes;
    FAutoBuildHex  : Boolean;
    FToken         : String;
    FGrantCodeEvent: String;
    FGrantType     : String;
    FGetTokenEvent : String;
    FClientID      : String;
    FClientSecret  : String;
    FRedirectURI   : String;
    FExpiresIn     : TDatetime;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property TokenType     : TRESTDWAuthOptionTypes read FTokenType       write FTokenType;
    property AutoBuildHex  : Boolean                read FAutoBuildHex    write FAutoBuildHex;
    property Token         : String                 read FToken           write FToken;
    property GrantCodeEvent: String                 read FGrantCodeEvent  write FGrantCodeEvent;
    property GrantType     : String                 read FGrantType       write FGrantType;
    property GetTokenEvent : String                 read FGetTokenEvent   write FGetTokenEvent;
    property ClientID      : String                 read FClientID        write FClientID;
    property ClientSecret  : String                 read FClientSecret    write FClientSecret;
    property RedirectURI   : String                 read FRedirectURI     write FRedirectURI;
    property ExpiresIn    : TDateTime               read FExpiresIn;
  end;

implementation

{ TRESTDWAuthMessages }

constructor TRESTDWAuthMessages.Create;
begin
  FAuthDialog              := True;
  FCustomDialogAuthMessage := 'Protected Space...';
  FCustom404TitleMessage   := '(404) The address you are looking for does not exist';
  FCustom404BodyMessage    := '404';
  FCustom404FooterMessage  := 'Take me back to <a href="./">Home REST Dataware';
  FCustomAuthErrorPage     := TStringList.Create;
end;

destructor TRESTDWAuthMessages.Destroy;
begin
  FreeAndNil(FCustomAuthErrorPage);
  inherited;
end;

procedure TRESTDWAuthMessages.SetCustomAuthErrorPage(AValue: TStringList);
var
  I : Integer;
begin
  FCustomAuthErrorPage.Clear;
  for I := 0 to AValue.Count -1 do
    FCustomAuthErrorPage.Add(AValue[I]);
end;

{ TRESTDWAuthBasic }

constructor TRESTDWAuthBasic.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FUserName := cDefaultBasicAuthUser;
  FPassword := cDefaultBasicAuthPassword;
end;

{ TRESTDWAuthToken }

procedure TRESTDWAuthToken.Assign(ASource: TPersistent);
var
  LSrc : TRESTDWAuthToken;
begin
  if ASource is TRESTDWAuthToken then
  begin
    LSrc            := TRESTDWAuthToken(ASource);
    TokenType       := LSrc.TokenType;
    CryptType       := LSrc.CryptType;
    GetTokenEvent   := LSrc.GetTokenEvent;
    TokenHash       := LSrc.TokenHash;
    ServerSignature := LSrc.ServerSignature;
    LifeCycle       := LSrc.LifeCycle;
  end
  else
    inherited Assign(ASource);
end;

procedure TRESTDWAuthToken.ClearToken;
begin
  FSecrets      := '';
  FToken        := '';
  FBeginTime    := 0;
  FEndTime      := 0;
end;

constructor TRESTDWAuthToken.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FTokenHash        := 'RDWTS_HASH0011';
  FServerSignature  := 'RESTRESTDWServer01';
  FGetTokenEvent    := 'GetToken';
  FKey              := 'token';
  FLifeCycle        := 1800;//30 Minutos
  FTokenType        := rdwTS;
  FCryptType        := rdwAES256;
  FServerSignature  := '';
  FBeginTime        := 0;
  FEndTime          := 0;
  FSecrets          := '';
  FGetTokenRoutes   := [crAll];
  FTokenRequestType := rdwtHeader;
  FToken            := '';
  FSecrets          := '';
  FAutoGetToken     := True;
  FAutoRenewToken   := True;
end;

destructor TRESTDWAuthToken.Destroy;
begin

  inherited;
end;

procedure TRESTDWAuthToken.FromToken(ATokenValue: String);
var
  LJsonValue: TRESTDWJSONInterfaceObject;
  LHeader, LBody: String;
begin
  FToken     := ATokenValue;

  try
    LHeader := Copy(ATokenValue, InitStrPos, Pos('.', ATokenValue) - 1);
    Delete(ATokenValue, InitStrPos, Pos('.', ATokenValue));
    LBody   := Copy(ATokenValue, InitStrPos, Pos('.', ATokenValue) - 1);

    //Read Header
    if Trim(LHeader) <> '' then
    begin
      LJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(LHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));

      if LJsonValue.PairCount > 0 then
      begin
        if not LJsonValue.PairByName['typ'].IsNull then
         FTokenType := GetTokenType(LJsonValue.PairByName['typ'].Value);
      end;

      FreeAndNil(LJsonValue);
    end;

    //Read Body
    if Trim(LBody) <> '' then
    begin
      LJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(LBody{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));

      if LJsonValue.PairCount > 0 then
      begin
        if not LJsonValue.PairByName['iat'].IsNull then
        begin
          if FTokenType = rdwTS then
            FBeginTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['iat'].Value)
          else
            FBeginTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['iat'].Value), False);
        end;

        if not lJsonValue.PairByName['exp'].IsNull then
        begin
          if FTokenType = rdwTS then
            FEndTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['exp'].Value)
          else
            FEndTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['exp'].Value), False);
        end;

        if not LJsonValue.PairByName['secrets'].IsNull Then
          FSecrets := DecodeStrings(LJsonValue.PairByName['secrets'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      end;

      FreeAndNil(LJsonValue);
    end;
  except

  end;
end;

function TRESTDWAuthToken.GetCryptType(AValue: String): TRESTDWCryptType;
begin
  Result := rdwAES256;

  if LowerCase(AValue) = 'hs256' then
    Result := rdwHSHA256
  else if LowerCase(AValue) = 'rsa' then
    Result := rdwRSA;
end;

function TRESTDWAuthToken.GetToken(ASecrets: String): String;
var
  LTokenValue: TTokenValue;
begin
  LTokenValue           := TTokenValue.Create;
  LTokenValue.TokenHash := FTokenHash;
  LTokenValue.TokenType := FTokenType;
  LTokenValue.CryptType := FCryptType;

  if Trim(FServerSignature)  <> '' then
    LTokenValue.Iss := LTokenValue.vCripto.Encrypt(FServerSignature);

  LTokenValue.Secrets   := ASecrets;
  LTokenValue.BeginTime := Now;

  if FLifeCycle > 0 then
    LTokenValue.EndTime := IncSecond(LTokenValue.BeginTime, FLifeCycle);

  try
    Result := LTokenValue.ToToken;
  finally
    FreeAndNil(LTokenValue);
  end;
End;

function TRESTDWAuthToken.GetTokenType(AValue: String): TRESTDWTokenType;
begin
  Result := rdwTS;

  If LowerCase(AValue) = 'jwt' then
    Result := rdwJWT
  else if LowerCase(AValue) = 'rdwcustom' then
    Result := rdwPersonal;
end;

procedure TRESTDWAuthToken.SetGetTokenEvent(AValue: String);
begin
  if Length(AValue) > 0 then
    FGetTokenEvent := AValue
  else
    raise Exception.Create('Invalid GetTokenName');
end;

procedure TRESTDWAuthToken.SetToken(AValue: String);
begin
  ClearToken;
  FToken := AValue;

  if FToken <> '' then
    FromToken(FToken)
end;

function TRESTDWAuthToken.ValidateToken(AValue: String): Boolean;
var
  LHeader, LBody, LStringComparer: String;
  LTokenValue: TTokenValue;

  function ReadHeader(AValue: String): Boolean;
  var
    LJsonValue: TRESTDWJSONInterfaceObject;
  begin
    LJsonValue := Nil;
    Result     := False;

    try
      LJsonValue := TRESTDWJSONInterfaceObject.Create(AValue);

      if LJsonValue.PairCount = 2 then
      begin
        Result := (LowerCase(LJsonValue.Pairs[0].Name) = 'alg') And
                  (LowerCase(LJsonValue.Pairs[1].Name) = 'typ');

        if Result then
        begin
          FTokenType := GetTokenType(LJsonValue.Pairs[1].Value);
          FCryptType := GetCryptType(LJsonValue.Pairs[0].Value);
        end;
      end;
    except

    end;

    if Assigned(LJsonValue) Then
      FreeAndNil(LJsonValue);
  end;

  function ReadBody(AValue: String): Boolean;
  var
    LJsonValue: TRESTDWJSONInterfaceObject;
  begin
    LJsonValue := Nil;
    Result     := False;

    try
      LJsonValue := TRESTDWJSONInterfaceObject.Create(AValue);
      Result     := Trim(LJsonValue.PairByName['iss'].Name) <> '';

      if Result then
      begin
        Result := FServerSignature = LTokenValue.vCripto.Decrypt(LJsonValue.PairByName['iss'].Value);

        if Result then
        begin
          Result            := False;
          FServerSignature  := LTokenValue.vCripto.Decrypt(LJsonValue.PairByName['iss'].Value);
          Result            := Trim(LJsonValue.PairByName['iat'].Name) <> '';

          if Result then
          Begin
            Result := False;

            if FTokenType = rdwTS then
              FBeginTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['iat'].Value)
            else
              FBeginTime   := UnixToDateTime(StrToInt64(LJsonValue.PairByName['iat'].Value), False);
          end;

          Result := Trim(LJsonValue.PairByName['secrets'].Name) <> '';

          if Result then
            FSecrets := DecodeStrings(LJsonValue.PairByName['secrets'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});

          if Trim(LJsonValue.PairByName['exp'].Name) <> '' Then
          begin
            Result := False;

            if FTokenType = rdwTS then
              FEndTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['exp'].Value)
            else
              FEndTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['exp'].Value), False);

            Result := Now < FEndTime;
          end;
        end;
      end
      else
        Result := FLifeCycle = 0;
    except

    end;

    if Assigned(LJsonValue) Then
      FreeAndNil(LJsonValue);
  end;
begin
  LHeader         := '';
  LBody           := '';
  LStringComparer := '';
  AValue          := StringReplace(AValue, ' ', '+', [rfReplaceAll]);
  //Remove espaços na Token e add os caracteres "+" em seu lugar
  LHeader         := Copy(AValue, InitStrPos, Pos('.', AValue) -1);

  Delete(AValue, InitStrPos, Pos('.', AValue));

  LBody := Copy(AValue, InitStrPos, Pos('.', AValue) -1);

  Delete(AValue, InitStrPos, Pos('.', AValue));

  LStringComparer := AValue;
  Result          := (Trim(LHeader) <> '') And (Trim(LBody) <> '') And (Trim(LStringComparer) <> '');

  if Result then
  begin
    Result := ReadHeader(DecodeStrings(LHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));

    if Result then
    begin
      Result      := False;
      LTokenValue := TTokenValue.Create;

      try
        LTokenValue.TokenHash := FTokenHash;
        LTokenValue.CryptType := FCryptType;
        LStringComparer       := LTokenValue.vCripto.Decrypt(LStringComparer);
        Result                := LStringComparer = LHeader + '.' + LBody;

        if Result then
        begin
          Result  := False;
          LHeader := DecodeStrings(LHeader                 {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
          LBody   := DecodeStrings(LBody                   {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
          Secrets := DecodeStrings(GetSecretsValue(LBody)  {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
          Secrets := DecodeStrings(GetSecretsValue(Secrets){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
          Result  := ReadBody(LBody);
        end;
      finally
        FreeAndNil(LTokenValue);
      end;
    end;
  end;
end;

{ TRESTDWAuthOAuth }

constructor TRESTDWAuthOAuth.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FClientID       := '';
  FClientSecret   := '';
  FToken          := '';
  FRedirectURI    := '';
  FGrantType      := 'client_credentials';
  FGetTokenEvent  := 'access-token';
  FGrantCodeEvent := 'authorize';
  FAutoBuildHex   := False;
  FExpiresin      := 0;
  FTokenType      := rdwOATBasic;
end;

end.
