unit uRESTDWAuthenticators;

{$I ..\..\Includes\uRESTDW.inc}

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
  Fl�vio Motta               - Member Tester and DEMO Developer.
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

interface

uses
  Classes, SysUtils, DateUtils,
  uRESTDWConsts, uRESTDWAbout,  uRESTDWDataUtils,  uRESTDWJSONInterface,
  uRESTDWTools,  uRESTDWParams, uRESTDWProtoTypes;//, uRESTDW.OpenSsl_11;

Type
 TRESTDWCertOptions = Record
  Country,
  State,
  Locality,
  Organization,
  OrgUnit,
  CommonName,
  ServerName     : String;
  ExpiresDays    : Integer;
End;

Type
 TRESTDWAuthenticatorBase = class(TRESTDWComponent)
 Private
  FAuthDialog : Boolean;
 Public
  Constructor Create(aOwner : TComponent); Override;
  Destructor Destroy; override;
 Published
  Property AuthDialog : Boolean Read FAuthDialog Write FAuthDialog;
 End;

  // Classe Especifica para Autenticacao pelo Server
  TRESTDWServerAuthBase = class(TRESTDWAuthenticatorBase)
  private

  public
    function AuthValidate(ADataModuleRESTDW: TObject;
                          AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername, AAuthPassword: String;
                          ARawHeaders: TStrings; ARequestType: TRequestType; var ADWParams: TRESTDWParams;
                          var AGetToken: Boolean; var ATokenValidate: Boolean; var AToken: String;
                          var AErrorCode: Integer; var AErrorMessage: String; var AAcceptAuth: Boolean): Boolean; virtual; abstract;
  end;

  TRESTDWAuthBasic = class(TRESTDWServerAuthBase)
  private
    FPassword: String;
    FUserName: String;
    procedure PrepareBasicAuth(AAuthenticationString: String; var AAuthUsername, AAuthPassword: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AuthValidate(ADataModuleRESTDW: TObject;
                          AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername, AAuthPassword: String;
                          ARawHeaders: TStrings; ARequestType: TRequestType; var ADWParams: TRESTDWParams;
                          var AGetToken: Boolean; var ATokenValidate: Boolean; var AToken: String;
                          var AErrorCode: Integer; var AErrorMessage: String; var AAcceptAuth: Boolean): Boolean; override;
    function ValidateAuth(AUserName, APassword: string): boolean;
  published
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
  end;

  TRESTDWAuthToken = class(TRESTDWServerAuthBase)
  private
    FBeginTime: TDateTime;
    FEndTime: TDateTime;
    FSecrets: String;
    FServerSignature: String;
    FTokenType: TRESTDWTokenType;
    FCryptType: TRESTDWCryptType;
    FTokenRequestType: TRESTDWTokenRequest;
    FKey: String;
    FGetTokenEvent: String;
    FGetTokenRoutes: TRESTDWRoutes;
    FTokenHash: String;
    FLifeCycle: Integer;
    FToken: String;
    FAutoGetToken: Boolean;
    FAutoRenewToken: Boolean;
    procedure ClearToken;
    procedure SetGetTokenEvent(AValue: String);
    procedure SetToken(AValue: String);
    function GetTokenType(AValue: String): TRESTDWTokenType;
    function GetCryptType(AValue: String): TRESTDWCryptType;
    procedure GenerateToken(ADataModuleRESTDW: TObject; ARequestType: TRequestType;
                             AParams: TRESTDWParams; ARawHeaders: TStrings;
                             AWelcomeMessage, AAccessTag: String;
                             var ATokenValidate: Boolean; var AToken: String;
                             var AGetToken: Boolean; var AErrorCode: Integer;
                             var AErrorMessage: String; var AAcceptAuth: Boolean);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent);
    procedure FromToken(ATokenValue: String);
    function GetToken(ASecrets: String): String;
    function ValidateToken(AValue: String): Boolean; overload;
    function AuthValidate(ADataModuleRESTDW: TObject;
                          AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername, AAuthPassword: String;
                          ARawHeaders: TStrings; ARequestType: TRequestType; var ADWParams: TRESTDWParams;
                          var AGetToken: Boolean; var ATokenValidate: Boolean; var AToken: String;
                          var AErrorCode: Integer; var AErrorMessage: String; var AAcceptAuth: Boolean): Boolean; override;
  published
    property BeginTime: TDateTime read FBeginTime write FBeginTime;
    property EndTime: TDateTime read FEndTime write FEndTime;
    property Secrets: String read FSecrets write FSecrets;
    property TokenType: TRESTDWTokenType read FTokenType write FTokenType;
    property CryptType: TRESTDWCryptType read FCryptType write FCryptType;
    property TokenRequestType: TRESTDWTokenRequest Read FTokenRequestType
      write FTokenRequestType;
    property Key: String read FKey write FKey;
    property GetTokenEvent: String read FGetTokenEvent write SetGetTokenEvent;
    property GetTokenRoutes: TRESTDWRoutes read FGetTokenRoutes
      write FGetTokenRoutes;
    property TokenHash: String read FTokenHash write FTokenHash;
    property ServerSignature: String read FServerSignature
      write FServerSignature;
    property LifeCycle: Integer read FLifeCycle write FLifeCycle;
    property Token: String read FToken write SetToken;
    property AutoGetToken: Boolean read FAutoGetToken write FAutoGetToken;
    property AutoRenewToken: Boolean read FAutoRenewToken write FAutoRenewToken;
  end;

  TRESTDWAuthOAuth = Class(TRESTDWServerAuthBase)
  private
    FTokenType    : TRESTDWAuthOptionTypes;
    FBeginTime,
    FEndTime      : TDateTime;
    FRSASHA256_Validation,
    FServerValidationCert,
    FAutoBuildHex : Boolean;
    FLifeCycle    : Integer;
    FToken,
    FGrantCodeEvent,
    FGrantType,
    FGetTokenEvent,
    FHeader,
    FPayLoad,
    FSignature,
    FPublicKey,
    FPrivateKey,
    FRedirectURI  : String;
  public
    Constructor Create                   (aOwner             : TComponent);             Override;
    Function    CreateSelfSignedCert_X509(CertOptions        : TRESTDWCertOptions;
                                          Var Certificate,
                                          PrivateKey         : TRESTDWBytes) : Boolean;
    Function    AuthValidate             (ADataModuleRESTDW  : TObject;
                                          AUrlToExec,
                                          AWelcomeMessage,
                                          AAccessTag,
                                          AAuthUsername,
                                          AAuthPassword      : String;
                                          ARawHeaders        : TStrings;
                                          ARequestType       : TRequestType;
                                          Var ADWParams      : TRESTDWParams;
                                          Var AGetToken      : Boolean;
                                          Var ATokenValidate : Boolean;
                                          Var AToken         : String;
                                          Var AErrorCode     : Integer;
                                          Var AErrorMessage  : String;
                                          Var AAcceptAuth    : Boolean)      : Boolean; Override;
  published
    Property TokenType            : TRESTDWAuthOptionTypes Read FTokenType            Write FTokenType;
    Property AutoBuildHex         : Boolean                Read FAutoBuildHex         Write FAutoBuildHex;
    Property RSASHA256_Validation : Boolean                Read FRSASHA256_Validation Write FRSASHA256_Validation;
    Property LifeCycle            : Integer                Read FLifeCycle            Write FLifeCycle;
    Property BeginTime            : TDateTime              Read FBeginTime            Write FBeginTime; //iat
    Property EndTime              : TDateTime              Read FEndTime              Write FEndTime;//exp
    Property ServerValidationCert : Boolean                Read FServerValidationCert Write FServerValidationCert;
    Property Token                : String                 Read FToken                Write FToken;
    Property GrantCodeEvent       : String                 Read FGrantCodeEvent       Write FGrantCodeEvent;
    Property GrantType            : String                 Read FGrantType            Write FGrantType;
    Property GetTokenEvent        : String                 Read FGetTokenEvent        Write FGetTokenEvent;
    Property Header               : String                 Read FHeader;
    Property PayLoad              : String                 Read FPayLoad              Write FPayLoad;
    Property Signature            : String                 Read FSignature            Write FSignature;
    Property PublicKey            : String                 Read FPublicKey            Write FPublicKey;
    Property PrivateKey           : String                 Read FPrivateKey           Write FPrivateKey;
    Property RedirectURI          : String                 Read FRedirectURI          Write FRedirectURI;
  end;

  TOnUserBasicAuth = Procedure(Welcomemsg, AccessTag,
                               Username, Password : String;
                               Var Params         : TRESTDWParams;
                               Var ErrorCode      : Integer;
                               Var ErrorMessage   : String;
                               Var Accept         : Boolean) Of Object;

  TOnGetToken      = Procedure(Welcomemsg,
                               AccessTag        : String;
                               Params           : TRESTDWParams;
                               AuthOptions      : TRESTDWAuthToken;
                               Var ErrorCode    : Integer;
                               Var ErrorMessage : String;
                               Var TokenID      : String;
                               Var Accept       : Boolean) Of Object;

  TOnUserTokenAuth = Procedure(Welcomemsg,
                             AccessTag          : String;
                             Params             : TRESTDWParams;
                             AuthOptions        : TRESTDWAuthToken;
                             Var ErrorCode      : Integer;
                             Var ErrorMessage   : String;
                             Var TokenID        : String;
                             Var Accept         : Boolean) Of Object;
  TUserBasicAuth  = Procedure(Welcomemsg, AccessTag,
                              Username, Password : String;
                              Var Params         : TRESTDWParams;
                              Var ErrorCode      : Integer;
                              Var ErrorMessage   : String;
                              Var Accept         : Boolean) Of Object;
  TUserTokenAuth  = Procedure(Welcomemsg,
                              AccessTag          : String;
                              Params             : TRESTDWParams;
                              AuthOptions        : TRESTDWAuthToken;
                              Var ErrorCode      : Integer;
                              Var ErrorMessage   : String;
                              Var TokenID        : String;
                              Var Accept         : Boolean) Of Object;
  TOnRenewToken   = Procedure of Object;


implementation

uses
  uRESTDWDatamodule, uRESTDWServerMethodClass;

{ TRESTDWAuthBasic }

function TRESTDWAuthBasic.AuthValidate(ADataModuleRESTDW : TObject; 
                                      AUrlToExec,
                                      AWelcomeMessage, 
                                      AAccessTag, 
                                      AAuthUsername, 
                                      AAuthPassword      : String;
                                      ARawHeaders        : TStrings; 
                                      ARequestType       : TRequestType;
                                      Var ADWParams      : TRESTDWParams; 
                                      Var AGetToken, 
                                      ATokenValidate     : Boolean;
                                      Var AToken         : String; 
                                      Var AErrorCode     : Integer; 
                                      Var AErrorMessage  : String;
                                      Var AAcceptAuth    : Boolean) : Boolean;
Var
 LAuthenticationString : String;
begin
  LAuthenticationString := DecodeStrings(StringReplace(ARawHeaders.Values['Authorization'], 'Basic ', '', [rfReplaceAll]){$IFDEF FPC}, csUndefined{$ENDIF});
  if (LAuthenticationString <> '') and ((AAuthUsername = '') and (AAuthPassword = '')) then
    Self.PrepareBasicAuth(LAuthenticationString, AAuthUsername, AAuthPassword);
   {$IFNDEF RESTDWLAZARUS}
    {$IFNDEF FPC}
    If (ADataModuleRESTDW.InheritsFrom(TServerMethodDatamodule))  Or
       (ADataModuleRESTDW           Is TServerMethodDatamodule)   Then
     Begin
      If Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth) then
       TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth(AWelcomeMessage, AAccessTag, AAuthUsername,
                                                                  AAuthPassword, ADWParams, AErrorCode, AErrorMessage, AAcceptAuth)
      Else
       AAcceptAuth := Self.ValidateAuth(AAuthUsername, AAuthPassword);
     End
    Else If (ADataModuleRESTDW.InheritsFrom(TServerBaseMethodClass))   Or
            (ADataModuleRESTDW           Is TServerBaseMethodClass)    Then
     Begin
      If Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnUserBasicAuth) then
       TServerBaseMethodClass(ADataModuleRESTDW).OnUserBasicAuth(AWelcomeMessage, AAccessTag, AAuthUsername,
                                                                 AAuthPassword, ADWParams, AErrorCode, AErrorMessage, AAcceptAuth)
      Else
       AAcceptAuth := Self.ValidateAuth(AAuthUsername, AAuthPassword);
     End;
    {$ELSE}
     If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
        (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
      Begin
       If Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth) then
        TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth(AWelcomeMessage, AAccessTag, AAuthUsername,
                                                                   AAuthPassword, ADWParams, AErrorCode, AErrorMessage, AAcceptAuth)
       Else
        AAcceptAuth := Self.ValidateAuth(AAuthUsername, AAuthPassword);
      End   
     Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
             (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
      Begin
       If Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnUserBasicAuth) then
        TServerBaseMethodClass(ADataModuleRESTDW).OnUserBasicAuth(AWelcomeMessage, AAccessTag, AAuthUsername,
                                                                  AAuthPassword, ADWParams, AErrorCode, AErrorMessage, AAcceptAuth)
       Else
        AAcceptAuth := Self.ValidateAuth(AAuthUsername, AAuthPassword);
      End;
    {$ENDIF}
  {$ELSE}
   If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
      (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
    Begin
     If Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth) then
      TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth(AWelcomeMessage, AAccessTag, AAuthUsername,
                                                                 AAuthPassword, ADWParams, AErrorCode, AErrorMessage, AAcceptAuth)
     Else
      AAcceptAuth := Self.ValidateAuth(AAuthUsername, AAuthPassword);
    End
   Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
           (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
    Begin
     If Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnUserBasicAuth) then
      TServerBaseMethodClass(ADataModuleRESTDW).OnUserBasicAuth(AWelcomeMessage, AAccessTag, AAuthUsername,
                                                                AAuthPassword, ADWParams, AErrorCode, AErrorMessage, AAcceptAuth)
     Else
      AAcceptAuth := Self.ValidateAuth(AAuthUsername, AAuthPassword);   
    End;
  {$ENDIF}
  Result := AAcceptAuth;
End;

constructor TRESTDWAuthBasic.Create(aOwner: TComponent);
begin
  inherited;
  FUserName := cDefaultBasicAuthUser;
  FPassword := cDefaultBasicAuthPassword;
end;

destructor TRESTDWAuthBasic.Destroy;
begin
  inherited;
end;

procedure TRESTDWAuthBasic.PrepareBasicAuth(AAuthenticationString: String;
  var AAuthUsername, AAuthPassword: String);
begin
  AAuthUsername := Copy(AAuthenticationString, InitStrPos, Pos(':', AAuthenticationString) -1);
  Delete(AAuthenticationString, InitStrPos, Pos(':', AAuthenticationString));
  AAuthPassword := AAuthenticationString;
end;

function TRESTDWAuthBasic.ValidateAuth(aUserName, aPassword: string): boolean;
begin
  Result := (aUserName = UserName) and (aPassword = Password)
end;

{ TRESTDWAuthToken }

procedure TRESTDWAuthToken.Assign(ASource: TPersistent);
var
  LSrc: TRESTDWAuthToken;
begin
  if ASource is TRESTDWAuthToken then
  begin
    LSrc := TRESTDWAuthToken(ASource);
    TokenType := LSrc.TokenType;
    CryptType := LSrc.CryptType;
    GetTokenEvent := LSrc.GetTokenEvent;
    TokenHash := LSrc.TokenHash;
    ServerSignature := LSrc.ServerSignature;
    LifeCycle := LSrc.LifeCycle;
  end
  else
    inherited Assign(ASource);
end;

Function TRESTDWAuthToken.AuthValidate(ADataModuleRESTDW : TObject; 
                                       AUrlToExec,
                                       AWelcomeMessage, 
                                       AAccessTag, 
                                       AAuthUsername, 
                                       AAuthPassword     : String;
                                       ARawHeaders       : TStrings; 
                                       ARequestType      : TRequestType;
                                       Var ADWParams     : TRESTDWParams; 
                                       Var AGetToken, 
                                       ATokenValidate    : Boolean;
                                       Var AToken        : String; 
                                       Var AErrorCode    : Integer; 
                                       Var AErrorMessage : String;
                                       Var AAcceptAuth   : Boolean) : Boolean;
Var
 LUrlToken, 
 LToken,
 LTokenOrig      : String;
 LAuthTokenParam : TRESTDWAuthToken;
Begin
  // Se for o Evento Get Token
 LUrlToken := LowerCase(AUrlToExec);
 If Copy(LUrlToken, InitStrPos, 1) = '/' then
  Delete(LUrlToken, InitStrPos, 1);
 If LUrlToken = LowerCase(Self.GetTokenEvent) then
  Begin
   Self.GenerateToken(ADataModuleRESTDW, ARequestType, ADWParams, ARawHeaders,
                      AWelcomeMessage,   AAccessTag,   ATokenValidate,
                      AToken, AGetToken, AErrorCode,   AErrorMessage, AAcceptAuth);
    Exit;
  End;
 // Se for Validar o Token
 AErrorCode      := 401;
 AErrorMessage   := cInvalidAuth;
 ATokenValidate  := True;
 LTokenOrig      := AToken;
 LAuthTokenParam := TRESTDWAuthToken.Create(self);
 Try
  LAuthTokenParam.Assign(Self);
  If ADWParams.ItemsString[Self.Key] <> Nil Then
   AToken := ADWParams.ItemsString[Self.Key].AsString
  Else
   Begin
    If Trim(AToken)  = '' Then
     AToken := ARawHeaders.Values['Authorization'];
    If Trim(AToken) <> '' Then
     Begin
      LToken := GetTokenString(AToken);
      If LToken = '' Then
       LToken := GetBearerString(AToken);
      If LToken = '' Then
       LToken := LTokenOrig;
      AToken := LToken;
     End;
   End;
  If Not LAuthTokenParam.ValidateToken(AToken) Then
   Begin
    AAcceptAuth := False;
    Exit;
   End
  Else
   ATokenValidate := False;
   {$IFNDEF RESTDWLAZARUS}
    {$IFNDEF FPC}
    If (ADataModuleRESTDW.InheritsFrom(TServerMethodDatamodule))  Or
       (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
     Begin
      If Assigned(TServerMethodDatamodule(ADataModuleRESTDW).OnUserTokenAuth) Then
       Begin
        TServerMethodDatamodule(ADataModuleRESTDW).OnUserTokenAuth(AWelcomeMessage, AAccessTag, ADWParams,
                                                                   TRESTDWAuthToken(LAuthTokenParam),
                                                                   AErrorCode, AErrorMessage, AToken, AAcceptAuth);
        ATokenValidate := Not(AAcceptAuth);
       End;
     End
    Else If (ADataModuleRESTDW.InheritsFrom(TServerBaseMethodClass))   Or
            (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
     Begin
      If Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnUserTokenAuth) Then
       Begin
        TServerBaseMethodClass(ADataModuleRESTDW).OnUserTokenAuth(AWelcomeMessage, AAccessTag, ADWParams,
                                                                  TRESTDWAuthToken(LAuthTokenParam),
                                                                  AErrorCode, AErrorMessage, AToken, AAcceptAuth);
        ATokenValidate := Not(AAcceptAuth);
       End;
     End;
    {$ELSE}
     If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
        (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
      Begin
       If Assigned(TServerMethodDatamodule(ADataModuleRESTDW).OnUserTokenAuth) Then
        Begin
         TServerMethodDatamodule(ADataModuleRESTDW).OnUserTokenAuth(AWelcomeMessage, AAccessTag, ADWParams,
                                                                    TRESTDWAuthToken(LAuthTokenParam),
                                                                    AErrorCode, AErrorMessage, AToken, AAcceptAuth);
         ATokenValidate := Not(AAcceptAuth);
        End;
      End   
     Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
             (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
      Begin
       If Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnUserTokenAuth) Then
        Begin
         TServerBaseMethodClass(ADataModuleRESTDW).OnUserTokenAuth(AWelcomeMessage, AAccessTag, ADWParams,
                                                                   TRESTDWAuthToken(LAuthTokenParam),
                                                                   AErrorCode, AErrorMessage, AToken, AAcceptAuth);
         ATokenValidate := Not(AAcceptAuth);
        End;     
      End;
    {$ENDIF}
  {$ELSE}
   If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
      (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
    Begin
     If Assigned(TServerMethodDatamodule(ADataModuleRESTDW).OnUserTokenAuth) Then
      Begin
       TServerMethodDatamodule(ADataModuleRESTDW).OnUserTokenAuth(AWelcomeMessage, AAccessTag, ADWParams,
                                                                 TRESTDWAuthToken(LAuthTokenParam),
                                                                 AErrorCode, AErrorMessage, AToken, AAcceptAuth);
       ATokenValidate := Not(AAcceptAuth);
      End;        
    End
   Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
           (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
    Begin
     If Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnUserTokenAuth) Then
      Begin
       TServerBaseMethodClass(ADataModuleRESTDW).OnUserTokenAuth(AWelcomeMessage, AAccessTag, ADWParams,
                                                                 TRESTDWAuthToken(LAuthTokenParam),
                                                                 AErrorCode, AErrorMessage, AToken, AAcceptAuth);
       ATokenValidate := Not(AAcceptAuth);
      End;        
    End;
  {$ENDIF}
  Result := AAcceptAuth;
 Finally
  If Assigned(LAuthTokenParam) Then
   FreeAndNil(LAuthTokenParam);
 End;
end;

procedure TRESTDWAuthToken.ClearToken;
begin
  FSecrets := '';
  FToken := '';
  FBeginTime := 0;
  FEndTime := 0;
end;

constructor TRESTDWAuthToken.Create(aOwner: TComponent);
begin
  inherited;
  FTokenHash := 'RDWTS_HASH0011';
  FServerSignature := 'RESTDWServer01';
  FGetTokenEvent := 'GetToken';
  FKey := 'token';
  FLifeCycle := 1800; // 30 Minutos
  FTokenType := rdwJWT;
  FCryptType := rdwHSHA256;
  FServerSignature := '';
  FBeginTime := 0;
  FEndTime := 0;
  FSecrets := '';
  FGetTokenRoutes := TRESTDWRoutes.Create;
  FGetTokenRoutes.Post.Active := True;// [crPost];
  FTokenRequestType := rdwtHeader;
  FToken := '';
  FSecrets := '';
  FAutoGetToken := True;
  FAutoRenewToken := True;
  FGetTokenRoutes.All.Active := True;
end;

destructor TRESTDWAuthToken.Destroy;
begin
  FGetTokenRoutes.Free;
  inherited;
end;

procedure TRESTDWAuthToken.FromToken(ATokenValue: String);
Var
 LJsonValue : TRESTDWJSONInterfaceObject;
 LHeader, 
 LBody      : String;
Begin
 FToken := ATokenValue;
 Try
  LHeader := Copy(ATokenValue, InitStrPos, Pos('.', ATokenValue) - 1);
  Delete(ATokenValue, InitStrPos, Pos('.', ATokenValue));
  LBody := Copy(ATokenValue, InitStrPos, Pos('.', ATokenValue) - 1);
  // Read Header
  If Trim(LHeader) <> '' Then
   Begin
    LJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(LHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
    Try
     If LJsonValue.PairCount > 0 Then
      Begin
       If Not LJsonValue.PairByName['typ'].IsNull Then
        FTokenType := GetTokenType(LJsonValue.PairByName['typ'].Value);
      End;
    Finally
     If Assigned(LJsonValue) Then
      FreeAndNil(LJsonValue);
    End;
   End;
   // Read Body
   If Trim(LBody) <> '' Then
    Begin
     LJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(LBody{$IFDEF FPC}, csUndefined{$ENDIF}));
     Try
      If LJsonValue.PairCount > 0 Then
       Begin
        If Not LJsonValue.PairByName['iat'].IsNull Then
         Begin
          If FTokenType = rdwTS Then
           FBeginTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['iat'].Value)
          Else
           FBeginTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['iat'].Value), False);
         End;
        If Not LJsonValue.PairByName['exp'].IsNull Then
         Begin
          If FTokenType = rdwTS Then
           FEndTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['exp'].Value)
          Else
           FEndTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['exp'].Value), False);
         End;
        If Not LJsonValue.PairByName['secrets'].IsNull Then
         FSecrets := DecodeStrings(LJsonValue.PairByName['secrets'].Value{$IFDEF FPC}, csUndefined{$ENDIF});
       End;
     Finally
      If Assigned(LJsonValue) Then
       FreeAndNil(LJsonValue);
     End;
    End;
 Except

 End;
End;

procedure TRESTDWAuthToken.GenerateToken(ADataModuleRESTDW : TObject;
                                        ARequestType       : TRequestType; 
                                        AParams            : TRESTDWParams; 
                                        ARawHeaders        : TStrings;
                                        AWelcomeMessage, 
                                        AAccessTag         : String; 
                                        Var ATokenValidate : Boolean; 
                                        Var AToken         : String;
                                        Var AGetToken      : Boolean; 
                                        Var AErrorCode     : Integer; 
                                        Var AErrorMessage  : String;
                                        Var AAcceptAuth    : Boolean);
Var
 LAuthTokenParam : TRESTDWAuthToken;
 LParams         : TRESTDWParams;
 vHaveGetToken   : Boolean;
Begin
 AGetToken     := True;
 vHaveGetToken := False;
 AErrorCode    := 404;
 AErrorMessage := cEventNotFound;
 If (Self.GetTokenRoutes.RouteIsActive(ARequestType)) Or
    (Self.GetTokenRoutes.RouteIsActive(rtAll))        Then
  Begin
   {$IFNDEF RESTDWLAZARUS}
    {$IFNDEF FPC}
     If (ADataModuleRESTDW.InheritsFrom(TServerMethodDatamodule))  Or
       (ADataModuleRESTDW           Is TServerMethodDatamodule)   Then
      vHaveGetToken := Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnGetToken)
     Else If (ADataModuleRESTDW.InheritsFrom(TServerBaseMethodClass))   Or
             (ADataModuleRESTDW           Is TServerBaseMethodClass)    Then
      vHaveGetToken := Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken);
    {$ELSE}
     If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
        (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
      vHaveGetToken := Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnGetToken)
     Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
             (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
      vHaveGetToken := Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken);
    {$ENDIF}
   {$ELSE}
    If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
       (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
     vHaveGetToken := Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnGetToken)
    Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
            (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
     vHaveGetToken := Assigned(TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken);
   {$ENDIF}
   If vHaveGetToken Then
    Begin
     ATokenValidate := True;
     LAuthTokenParam := TRESTDWAuthToken.Create(Self);
     Try
      LAuthTokenParam.Assign(Self);
//      {$IFNDEF RESTDWLAZARUS}
      If Trim(AToken) = '' Then
       AToken := ARawHeaders.Values['Authorization'];
//      {$ENDIF}
       {$IFNDEF RESTDWLAZARUS}
        {$IFNDEF FPC}
        If (ADataModuleRESTDW.InheritsFrom(TServerMethodDatamodule))  Or
           (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
         Begin
          If AParams.ItemsString['RDWParams'] <> Nil Then
           Begin
            LParams := TRESTDWParams.Create;
            LParams.FromJSON(AParams.ItemsString['RDWParams'].Value);
            TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    LParams, LAuthTokenParam,
                                                                  AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
            FreeAndNil(LParams);
           End
          Else
           TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    AParams, LAuthTokenParam,
                                                                 AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
         End
        Else If (ADataModuleRESTDW.InheritsFrom(TServerBaseMethodClass))   Or
                (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
         Begin
          If AParams.ItemsString['RDWParams'] <> Nil Then
           Begin
            LParams := TRESTDWParams.Create;
            LParams.FromJSON(AParams.ItemsString['RDWParams'].Value);
            TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    LParams, LAuthTokenParam,
                                                                 AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
            FreeAndNil(LParams);
           End
          Else
           TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    AParams, LAuthTokenParam,
                                                                AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
         End;
        {$ELSE}
         If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
            (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
          Begin
           If AParams.ItemsString['RDWParams'] <> Nil Then
            Begin
             LParams := TRESTDWParams.Create;
             LParams.FromJSON(AParams.ItemsString['RDWParams'].AsString);
             TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    LParams, LAuthTokenParam,
                                                                   AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
             FreeAndNil(LParams);
            End
           Else
            TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    AParams, LAuthTokenParam,
                                                                  AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
          End   
         Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
                 (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
          Begin
           If AParams.ItemsString['RDWParams'] <> Nil Then
            Begin
             LParams := TRESTDWParams.Create;
             LParams.FromJSON(AParams.ItemsString['RDWParams'].AsString);
             TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    LParams, LAuthTokenParam,
                                                                  AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
             FreeAndNil(LParams);
            End
           Else
            TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    AParams, LAuthTokenParam,
                                                                 AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
          End;
        {$ENDIF}
      {$ELSE}
       If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerMethodDatamodule))  Or
          (ADataModuleRESTDW            Is TServerMethodDatamodule)   Then
        Begin
         If AParams.ItemsString['RDWParams'] <> Nil Then
          Begin
           LParams := TRESTDWParams.Create;
           LParams.FromJSON(AParams.ItemsString['RDWParams'].Value);
           TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    LParams, LAuthTokenParam,
                                                                 AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
           FreeAndNil(LParams);
          End
         Else
          TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    AParams, LAuthTokenParam,
                                                                AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
        End
       Else If (ADataModuleRESTDW.ClassType.InheritsFrom(TServerBaseMethodClass))   Or
               (ADataModuleRESTDW            Is TServerBaseMethodClass)    Then
        Begin
         If AParams.ItemsString['RDWParams'] <> Nil Then
          Begin
           LParams := TRESTDWParams.Create;
           LParams.FromJSON(AParams.ItemsString['RDWParams'].Value);
           TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    LParams, LAuthTokenParam,
                                                                AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
           FreeAndNil(LParams);
          End
         Else
          TServerBaseMethodClass(ADataModuleRESTDW).OnGetToken(AWelcomeMessage, AAccessTag,    AParams, LAuthTokenParam,
                                                               AErrorCode,      AErrorMessage, AToken,  AAcceptAuth);
        End;
      {$ENDIF}
     Finally
      FreeAndNil(LAuthTokenParam);
     End;
    End;
  End;
End;

Function TRESTDWAuthToken.GetCryptType(AValue : String) : TRESTDWCryptType;
Begin
 Result := rdwAES256;
 If LowerCase(AValue)      = 'hs256' Then
  Result := rdwHSHA256
 Else If LowerCase(AValue) = 'rsa'   Then
  Result := rdwRSA;
End;

Function TRESTDWAuthToken.GetToken(ASecrets : String): String;
Var
 LTokenValue : TTokenValue;
Begin
 LTokenValue := TTokenValue.Create;
 Try
  LTokenValue.TokenHash := FTokenHash;
  LTokenValue.TokenType := FTokenType;
  LTokenValue.CryptType := FCryptType;
  If Trim(FServerSignature) <> '' Then
   LTokenValue.Iss := LTokenValue.vCripto.Encrypt(FServerSignature);
  LTokenValue.Secrets := ASecrets;
  LTokenValue.BeginTime := Now;
  If FLifeCycle > 0 Then
   LTokenValue.EndTime := IncSecond(LTokenValue.BeginTime, FLifeCycle);
  Result := LTokenValue.ToToken;
 Finally
  FreeAndNil(LTokenValue);
 End;
End;

Function TRESTDWAuthToken.GetTokenType(AValue : String): TRESTDWTokenType;
Begin
 Result := rdwTS;
 If LowerCase(AValue) = 'jwt' then
  Result := rdwJWT
 Else if LowerCase(AValue) = 'rdwcustom' then
  Result := rdwPersonal;
End;

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

Function TRESTDWAuthToken.ValidateToken(AValue : String) : Boolean;
Var
 LHeader, 
 LBody, 
 LStringComparer : String;
 LTokenValue     : TTokenValue;
 Function ReadHeader(AValue: String): Boolean;
 Var
  LJsonValue : TRESTDWJSONInterfaceObject;
 Begin
  LJsonValue := Nil;
  Result := False;
  Try
   LJsonValue := TRESTDWJSONInterfaceObject.Create(AValue);
   Try
    If LJsonValue.PairCount = 2 Then
     Begin
      Result := (LowerCase(LJsonValue.Pairs[0].Name) = 'alg') And            
                (LowerCase(LJsonValue.Pairs[1].Name) = 'typ');
      If Result Then
       Begin
        FTokenType := GetTokenType(LJsonValue.Pairs[1].Value);
        FCryptType := GetCryptType(LJsonValue.Pairs[0].Value);
       End;
     End;
    Finally
     If Assigned(LJsonValue) Then
      FreeAndNil(LJsonValue);
    End;
  Except

  End;
 End;
 Function ReadBody(AValue : String): Boolean;
 Var
  LJsonValue : TRESTDWJSONInterfaceObject;
 Begin
  LJsonValue := Nil;
  Result := False;
  LJsonValue := TRESTDWJSONInterfaceObject.Create(AValue);
  Try
   Result := Trim(LJsonValue.PairByName['iss'].Name) <> '';
   If Result Then
    Begin
     Result := FServerSignature = LTokenValue.vCripto.Decrypt(LJsonValue.PairByName['iss'].Value);
     If Result Then
      Begin
       Result           := False;
       FServerSignature := LTokenValue.vCripto.Decrypt(LJsonValue.PairByName['iss'].Value);
       Result           := Trim(LJsonValue.PairByName['iat'].Name) <> '';
       If Result Then
        Begin
         Result := False;
         If FTokenType = rdwTS Then
          FBeginTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['iat'].Value)
         Else
          FBeginTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['iat'].Value), False);
        End;
       Result := Trim(LJsonValue.PairByName['secrets'].Name) <> '';
       If Result Then
        FSecrets := DecodeStrings(LJsonValue.PairByName['secrets'].Value{$IFDEF FPC}, csUndefined{$ENDIF});
       If Trim(LJsonValue.PairByName['exp'].Name) <> '' Then
        Begin
         Result := False;
         If FTokenType = rdwTS Then
          FEndTime := TTokenValue.DateTimeFromISO8601(LJsonValue.PairByName['exp'].Value)
         Else
          FEndTime := UnixToDateTime(StrToInt64(LJsonValue.PairByName['exp'].Value), False);
         Result := Now < FEndTime;
        End;
      End;
    End
   Else
    Result := FLifeCycle = 0;
  Finally
   If Assigned(LJsonValue) Then
    FreeAndNil(LJsonValue);
  End;
 End;
Begin
 LHeader := '';
 LBody := '';
 LStringComparer := '';
 AValue := StringReplace(AValue, ' ', '+', [rfReplaceAll]);
  // Remove espa�os na Token e add os caracteres "+" em seu lugar
 LHeader := Copy(AValue, InitStrPos, Pos('.', AValue) - 1);
 Delete(AValue, InitStrPos, Pos('.', AValue));
 LBody := Copy(AValue, InitStrPos, Pos('.', AValue) - 1);
 Delete(AValue, InitStrPos, Pos('.', AValue));
 LStringComparer := AValue;
 Result := (Trim(LHeader) <> '') And (Trim(LBody) <> '') And
           (Trim(LStringComparer) <> '');
 If Result Then
  Begin
   Result := ReadHeader(DecodeStrings(LHeader{$IFDEF FPC}, csUndefined{$ENDIF}));
   If Result then
    Begin
     Result := False;
     LTokenValue := TTokenValue.Create;
     Try
      LTokenValue.TokenHash := FTokenHash;
      LTokenValue.CryptType := FCryptType;
      LStringComparer       := LTokenValue.vCripto.Decrypt(LStringComparer);
      Result := LStringComparer = LHeader + '.' + LBody;
      If Result Then
       Begin
        Result := False;
        LHeader := DecodeStrings(LHeader{$IFDEF FPC}, csUndefined{$ENDIF});
        LBody   := DecodeStrings(LBody{$IFDEF FPC},   csUndefined{$ENDIF});
        Secrets := DecodeStrings(GetSecretsValue(LBody){$IFDEF FPC},   csUndefined{$ENDIF});
        Secrets := DecodeStrings(GetSecretsValue(Secrets){$IFDEF FPC}, csUndefined{$ENDIF});
        Result := ReadBody(LBody);
       End;
     Finally
      FreeAndNil(LTokenValue);
     End;
    End;
  End;
End;

{ TRESTDWAuthOAuth }

Function TRESTDWAuthOAuth.CreateSelfSignedCert_X509(CertOptions      : TRESTDWCertOptions;
                                                    Var Certificate,
                                                    PrivateKey       : TRESTDWBytes) : Boolean;
begin
// Result := TRESTDWOpenSSLHelper.CreateSelfSignedCert_X509(CertOptions.Country,
//                                                          CertOptions.State,
//                                                          CertOptions.Locality,
//                                                          CertOptions.Organization,
//                                                          CertOptions.OrgUnit,
//                                                          CertOptions.CommonName,
//                                                          CertOptions.ServerName,
//                                                          CertOptions.ExpiresDays,
//                                                          Certificate, PrivateKey);
End;

Function TRESTDWAuthOAuth.AuthValidate(ADataModuleRESTDW : TObject;
                                       AUrlToExec,
                                       AWelcomeMessage, 
                                       AAccessTag, 
                                       AAuthUsername, 
                                       AAuthPassword     : String;
                                       ARawHeaders       : TStrings; 
                                       ARequestType      : TRequestType;
                                       Var ADWParams     : TRESTDWParams; 
                                       Var AGetToken, 
                                       ATokenValidate    : Boolean;
                                       Var AToken        : String; 
                                       Var AErrorCode    : Integer; 
                                       Var AErrorMessage : String;
                                       Var AAcceptAuth   : Boolean) : Boolean;
Begin
 AAcceptAuth := False;
 Result := False;
 Raise Exception.Create(cErrorOAuthNotImplenented);
End;

Constructor TRESTDWAuthOAuth.Create(aOwner: TComponent);
Begin
 Inherited;
 FRSASHA256_Validation := True;
 FServerValidationCert := True;
 FToken                := '';
 FRedirectURI          := '';
 FGrantType            := 'client_credentials';
 FGetTokenEvent        := 'access-token';
 FGrantCodeEvent       := 'authorize';
 FHeader               := '{"alg": "RS256", "typ": "JWT"}';
 FLifeCycle            := 1800; // 30 Minutos
 FPayLoad              := '';
 FSignature            := '';
 FPublicKey            := '';
 FPrivateKey           := '';
 FRedirectURI          := '';
 FBeginTime            := 0;
 FEndTime              := 0;
 FAutoBuildHex         := False;
 FTokenType            := rdwOATBasic;
End;

{ TRESTDWAuthenticatorBase }

Constructor TRESTDWAuthenticatorBase.Create(aOwner: TComponent);
Begin
 Inherited;
 FAuthDialog := True;
End;

Destructor TRESTDWAuthenticatorBase.Destroy;
Begin
 Inherited;
End;

End.
