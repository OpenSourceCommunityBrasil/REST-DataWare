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
  System.Classes, System.SysUtils, uRESTDWConsts, uRESTDWAbout, uRESTDWDataUtils,
  uRESTDWJSONInterface, uRESTDWTools;

type
  TRESTDWAuthenticatorBase = class(TRESTDWComponent)

  end;

  TRESTDWAuthMessages = class(TComponent)
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
    constructor Create;
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
    constructor Create;
    destructor Destroy; override;
    procedure FromToken(ATokenValue: String);
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
    constructor Create;
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

constructor TRESTDWAuthBasic.Create;
begin
  FUserName := cDefaultBasicAuthUser;
  FPassword := cDefaultBasicAuthPassword;
end;

{ TRESTDWAuthToken }

procedure TRESTDWAuthToken.ClearToken;
begin
  FSecrets      := '';
  FToken        := '';
  FBeginTime    := 0;
  FEndTime      := 0;
end;

constructor TRESTDWAuthToken.Create;
begin
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
      LJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(LHeader{$IFDEF FPC}, csUndefined{$ENDIF}));

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
      LJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(LBody{$IFDEF FPC}, csUndefined{$ENDIF}));

      if LJsonValue.PairCount > 0 then
      begin
        if not LJsonValue.PairByName['iat'].IsNull then
        begin
          if FTokenType = rdwTS then
            FBeginTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['iat'].Value)
          else if FTokenType = rdwJWT then
            FBeginTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['iat'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ENDIF});
        end;

        if not lJsonValue.PairByName['exp'].IsNull then
        begin
          if FTokenType = rdwTS then
            FEndTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['exp'].Value)
          else if FTokenType = rdwJWT Then
            FEndTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['exp'].Value){$IFDEF FPC}{$IFDEF LCL_FULLVERSION >= 2010000}, False{$ENDIF}{$ENDIF});
        end;

        if not LJsonValue.PairByName['secrets'].IsNull Then
          FSecrets := DecodeStrings(LJsonValue.PairByName['secrets'].Value{$IFDEF FPC}, csUndefined{$ENDIF});
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

{ TRESTDWAuthOAuth }

constructor TRESTDWAuthOAuth.Create;
begin
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
