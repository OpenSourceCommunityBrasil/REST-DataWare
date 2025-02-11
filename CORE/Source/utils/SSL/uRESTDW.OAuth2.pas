unit uRESTDW.OAuth2;
{ Routines for handling OAuth2 and JSON Web Tokens }

{ Note: Currently only supports RS256 }

{$INCLUDE 'uRESTDW.inc'}

interface

uses
 {$IFNDEF FPC}
  System.SysUtils,
  System.NetEncoding,
 {$ELSE}
  SysUtils,
 {$ENDIF}
 uRESTDWProtoTypes;

const
  { Headers for algorithms }
  JWT_RS256 = '{"alg":"RS256","typ":"JWT"}';

type
  { OAuth/2 header }
  TRESTDWOAuth2Header = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  private
    FAlg: String;
    FTyp: String;
  public
    { Initialize the header parameters }
    procedure Initialize;

    { Decodes json web token header as json }
    function FromJson(const AHeader: TBytes): Boolean;

    { Returns a Json string of the header }
    function ToJson: String;
  public
    { Signature algorithm }
    property Alg: String read FAlg write FAlg;

    { Token type  }
    property Typ: String read FTyp write FTyp;
  end;

  { OAuth/2 claim set }
  TRESTDWOAuth2ClaimSet = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  private
    FIss: String;
    FSub: String;
    FAud: String;
    FExp: TDateTime;
    FIat: TDateTime;
  public
    { Initialize the claim set parameters }
    procedure Initialize;

    { Decodes json web token payload as json }
    function FromJson(const APayload: TBytes): Boolean;

    { Returns a Json string of the claim set }
    function ToJson(const AExpiresInSec: Integer): String;
  public
    { The issuer of the claim }
    property Iss: String read FIss write FIss;

    { The subject claim (sub) normally describes to whom or to which application the JWT is issued }
    property Sub: String read FSub write FSub;

    { The audience (aud) identifies the authorization server as an intended audience }
    property Aud: String read FAud write FAud;

    { The expiration time (exp) of the JWT }
    property Exp: TDateTime read FExp write FExp;

    { The issued at claim (iat) can be used to store the time at which the JWT is created }
    property Iat: TDateTime read FIat write FIat;
  end;

type
  { JSON Web Token }
  TRESTDWJWT = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  private
    FHeader: TRESTDWBytes;
    FPayload: TRESTDWBytes;
    FSignature: TRESTDWBytes;
  public
   {$IFDEF FPC}Constructor Create;{$ENDIF}
   { Initializes the token with the provided header

      Parameters:
        AHeader: the header for the token }
    procedure Initialize(const AHeader: String); overload;

    { Initializes the token with the provided header and payload

      Parameters:
        AHeader: the header for the token
        APayload: the data payload for the token }
    procedure Initialize(const AHeader, APayload: String); overload;

    { Decodes a json web token into the header, payload and signature parts

      Parameters:
        AJsonWebToken: the encoded token

      Returns:
        True if the token was decoded, False otherwise }
    function Decode(const AJsonWebToken: String): Boolean;

    { Signs the json web token using the provided private key or secret

      Parameters:
        APrivateKey: the private key or secret
        AJsonWebToken: the encoded and signed token

      Returns:
        True if the token was successfully signed along with the resulting token, False otherwise }
    function Sign(const APrivateKey: TRESTDWBytes; out AJsonWebToken: String): Boolean;

    { Verifies the token was signed with the provided private key

      Parameters:
        AData: the data that was signed
        ASignature: the signature for the data
        APrivateKey: the private key or secret

      Returns:
        True if the token signature was verified, False otherwise }
    function VerifyWithPrivateKey(const AData, ASignature: TRESTDWBytes; const APrivateKey: TRESTDWBytes): Boolean; overload;

    { Verifies the token was signed with the provided private key

      Parameters:
        AJsonWebToken: the encoded token
        APrivateKey: the private key or secret

      Returns:
        True if the token signature was verified, False otherwise }
    function VerifyWithPrivateKey(const AJsonWebToken: String; const APrivateKey: TRESTDWBytes): Boolean; overload;

    { Verifies the token was signed with the provided private key

      Parameters:
        APrivateKey: the private key or secret

      Returns:
        True if the token signature was verified, False otherwise }
    function VerifyWithPrivateKey(const APrivateKey: TRESTDWBytes): Boolean; overload;

    { Verifies the token was signed with a private key associated with the provided public key

      Parameters:
        AJsonWebToken: the encoded token
        APublicKey: the public key

      Returns:
        True if the token signature was verified, False otherwise

      Note: The public key can be in the form of a PEM formatted RSA PUBLIC KEY or CERTIFICATE }
    function VerifyWithPublicKey(const AJsonWebToken: String; const APublicKey: TRESTDWBytes): Boolean;
  public
    { Web token header }
    property Header: TRESTDWBytes read FHeader write FHeader;

    { Web token data payload }
    property Payload: TRESTDWBytes read FPayload write FPayload;

    { Signature for the token }
    property Signature: TRESTDWBytes read FSignature write FSignature;
  end;

implementation

uses
 {$IFNDEF FPC}
  System.DateUtils,
 {$ELSE}
  DateUtils,
  uRESTDWConsts,
 {$ENDIF}
 uRESTDWTools,
 uRESTDW.BinaryCoding,
 uRESTDW.OpenSsl_11,
 uRESTDW.Bson;

{ Helpers }

{ Decode Base64 encoded string - Base64url RFC 4648 }
function Base64UrlDecode(const AEncodedString: String): TBytes;
Var
 S : String;
begin
  S := AEncodedString;
  S := S + StringOfChar('=', (4 - Length(AEncodedString) mod 4) mod 4);
  S := S.Replace('-', '+', [rfReplaceAll]).Replace('_', '/', [rfReplaceAll]);
  Result      := TBytes(StringToBytes(DecodeStrings(S{$IFDEF FPC}, csUndefined{$ENDIF})));
end;

{ Encode Base64 bytes - Base64url RFC 4648 }
function Base64UrlEncode(const ADecodedBytes: TBytes): String;
var
  S : String;
begin
  {$IFNDEF FPC}
   S := Base64Encode(BytesToString(TRESTDWBytes(ADecodedBytes)));
  {$ELSE}
   S := EncodeStrings(BytesToString(TRESTDWBytes(ADecodedBytes)){$IFDEF FPC}, csUndefined{$ENDIF});
  {$ENDIF}
  S := S.Replace(#13#10, '', [rfReplaceAll])
    .Replace(#13, '', [rfReplaceAll])
    .Replace(#10, '', [rfReplaceAll])
    .TrimRight(['='])
    .Replace('+', '-', [rfReplaceAll])
    .Replace('/', '_', [rfReplaceAll]);
  Result := S;
end;

{ TRESTDWOAuth2Header }

procedure TRESTDWOAuth2Header.Initialize;
begin
  FAlg := 'RS256';
  FTyp := 'JWT';
end;

function TRESTDWOAuth2Header.FromJson(const AHeader: TBytes): Boolean;
var
 BsonDoc: TRESTDWBsonDocument;
 {$IFDEF FPC}
  BsonValue : TRESTDWBsonValue;
 {$ENDIF}
begin
  try
    BsonDoc := TRESTDWBsonDocument.Load(AHeader);
    {$IFNDEF FPC}
    FAlg := BsonDoc['alg'];
    FTyp := BsonDoc['typ'];
    {$ELSE}
     BsonValue := TRESTDWBsonValue.Implicit('RS256');
     FAlg := BsonDoc.Get('alg', BsonValue).ToString;
     BsonValue := TRESTDWBsonValue.Implicit('JWT');
     FTyp := BsonDoc.Get('typ', BsonValue).ToString;
    {$ENDIF}
    Result := True;
  except
    on e: exception do
      Result := False;
  end;
end;

function TRESTDWOAuth2Header.ToJson: String;
var
  BsonDoc: TRESTDWBsonDocument;
  {$IFDEF FPC}
   BsonValue : TRESTDWBsonValue;
  {$ENDIF}
begin
  BsonDoc := TRESTDWBsonDocument.Create;
  {$IFNDEF FPC}
  BsonDoc['alg'] := FAlg;
  BsonDoc['typ'] := FTyp;
  {$ELSE}
   BsonDoc.Add('RS256', TRESTDWBsonValue.Implicit(FAlg));
   BsonDoc.Add('typ',   TRESTDWBsonValue.Implicit(FTyp));
  {$ENDIF}
  Result := BsonDoc.ToJson;
end;

{ TRESTDWOAuth2ClaimSet }

procedure TRESTDWOAuth2ClaimSet.Initialize;
begin

end;

function TRESTDWOAuth2ClaimSet.FromJson(const APayload: TBytes): Boolean;
var
  BsonDoc: TRESTDWBsonDocument;
  {$IFDEF FPC}
   BsonValue : TRESTDWBsonValue;
  {$ENDIF}
begin
  try
    BsonDoc := TRESTDWBsonDocument.Load(APayload);
    {$IFNDEF FPC}
     FIss := BsonDoc['iss'];
     FSub := BsonDoc['sub'];
     FAud := BsonDoc['aud'];
     FExp := BsonDoc['exp'];
     FIat := BsonDoc['iat'];
    {$ELSE}
     BsonValue := TRESTDWBsonValue.Implicit('');
     FIss := BsonDoc.Get('iss', BsonValue).ToString;
     FSub := BsonDoc.Get('sub', BsonValue).ToString;
     FAud := BsonDoc.Get('aud', BsonValue).ToString;
     FExp := BsonDoc.Get('exp', BsonValue).ToLocalTime;
     FIat := BsonDoc.Get('iat', BsonValue).ToLocalTime;
    {$ENDIF}
    Result := True;
  except
    on e: exception do
      Result := False;
  end;
end;

function TRESTDWOAuth2ClaimSet.ToJson(const AExpiresInSec: Integer): String;
var
  BsonDoc: TRESTDWBsonDocument;
  {$IFDEF FPC}
   BsonValue : TRESTDWBsonValue;
  {$ENDIF}
begin
  BsonDoc := TRESTDWBsonDocument.Create;
  {$IFNDEF FPC}
   BsonDoc['iss'] := FIss;
   BsonDoc['sub'] := FSub;
   BsonDoc['aud'] := FAud;
   BsonDoc['exp'] := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(IncSecond(FIat, AExpiresInSec)));
   BsonDoc['iat'] := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(FIat));
  {$ELSE}
   BsonDoc.Add('iss', TRESTDWBsonValue.Implicit(FIss));
   BsonDoc.Add('sub', TRESTDWBsonValue.Implicit(FSub));
   BsonDoc.Add('aud', TRESTDWBsonValue.Implicit(FAud));
   BsonDoc.Add('exp', TRESTDWBsonValue.Implicit(DateTimeToUnix(LocalTimeToUniversal(IncSecond(FIat, AExpiresInSec)))));
   BsonDoc.Add('iat', TRESTDWBsonValue.Implicit(DateTimeToUnix(LocalTimeToUniversal(FIat))));
  {$ENDIF}
  Result := BsonDoc.ToJson;
end;

{ TRESTDWJWT }

{$IFDEF FPC}
Constructor TRESTDWJWT.Create;
Begin
 Inherited;
end;
{$ENDIF}

procedure TRESTDWJWT.Initialize(const AHeader: String);
begin
//  {$IFDEF FPC}
//   Self := TRESTDWJWT.Create;
//  {$ENDIF}
  FHeader := TRESTDWBytes(TEncoding.UTF8.GetBytes(AHeader));
end;

procedure TRESTDWJWT.Initialize(const AHeader, APayload: String);
begin
  //  {$IFDEF FPC}
  //   Self := TRESTDWJWT.Create;
  //  {$ENDIF}
  {$IFNDEF FPC}
   FHeader  := TRESTDWBytes(TEncoding.UTF8.GetBytes(AHeader));
   FPayload := TRESTDWBytes(TEncoding.UTF8.GetBytes(APayload));
  {$ELSE}
   FHeader  := StringToBytes(AHeader);
   FPayload := StringToBytes(APayload);
  {$ENDIF}
end;

function TRESTDWJWT.Decode(const AJsonWebToken: String): Boolean;
var
 {$IFNDEF FPC}
  Parts: TArray<String>;
 {$ELSE}
  Parts: Array of String;
 {$ENDIF}
begin
  { Must contain 3 parts }
  Parts := AJsonWebToken.Split(['.']);
  if Length(Parts) < 3 then
    Exit(False);

  FHeader    := TRESTDWBytes(Base64UrlDecode(Parts[0]));
  FPayload   := TRESTDWBytes(Base64UrlDecode(Parts[1]));
  FSignature := TRESTDWBytes(Base64UrlDecode(Parts[2]));
  Result     := True;
end;

function TRESTDWJWT.Sign(const APrivateKey: TRESTDWBytes; out AJsonWebToken: String): Boolean;
var
  Data : String;
begin
  Data := Base64UrlEncode(TBytes(FHeader)) + '.' + Base64UrlEncode(TBytes(FPayload));
  if not TRESTDWOpenSSLHelper.Sign_RSASHA256(StringToBytes(EncodeStrings(Data{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})), APrivateKey, FSignature) then
    Exit(False);

  AJsonWebToken := Data + '.' + Base64UrlEncode(TBytes(FSignature));
  Result := True;
end;

function TRESTDWJWT.VerifyWithPrivateKey(const AData, ASignature: TRESTDWBytes; const APrivateKey: TRESTDWBytes): Boolean;
var
  bSignature: TRESTDWBytes;
begin
  if TRESTDWOpenSSLHelper.Sign_RSASHA256(AData, APrivateKey, bSignature) then
    Result := (BytesToString(bSignature) = BytesToString(ASignature))
  else
    Result := False;
end;

function TRESTDWJWT.VerifyWithPrivateKey(const AJsonWebToken: String; const APrivateKey: TRESTDWBytes): Boolean;
var
  {$IFNDEF FPC}
   Parts: TArray<String>;
  {$ELSE}
   Parts: Array of String;
  {$ENDIF}
  Data, bSignature: TRESTDWBytes;
begin
  { Must contain 3 parts }
  Parts := AJsonWebToken.Split(['.']);
  if Length(Parts) < 3 then
    Exit(False);

  Data := TRESTDWBytes(TEncoding.Utf8.GetBytes(Parts[0] + '.' + Parts[1]));
  bSignature := TRESTDWBytes(Base64UrlDecode(Parts[2]));
  Result := VerifyWithPrivateKey(Data, bSignature, TRESTDWBytes(APrivateKey));
end;

function TRESTDWJWT.VerifyWithPrivateKey(const APrivateKey: TRESTDWBytes): Boolean;
var
  Data: String;
begin
  Data := Base64UrlEncode(TBytes(FHeader)) + '.' + Base64UrlEncode(TBytes(FPayload));
  Result := VerifyWithPrivateKey(TRESTDWBytes(TEncoding.Utf8.GetBytes(Data)), FSignature, TRESTDWBytes(APrivateKey));
end;

function TRESTDWJWT.VerifyWithPublicKey(const AJsonWebToken: String; const APublicKey: TRESTDWBytes): Boolean;
var
  {$IFNDEF FPC}
   Parts: TArray<String>;
  {$ELSE}
   Parts: Array of String;
  {$ENDIF}
  bHeader, bPayload: TRESTDWBytes;
  bSignature: TRESTDWBytes;
begin
  { Must contain 3 parts }
  Parts := AJsonWebToken.Split(['.']);
  if Length(Parts) < 3 then
    Exit(False);

  bHeader := TRESTDWBytes(TEncoding.UTF8.GetBytes(Parts[0]));
  bPayload := TRESTDWBytes(TEncoding.UTF8.GetBytes(Parts[1]));
  bSignature := TRESTDWBytes(Base64UrlDecode(Parts[2]));
  Result := TRESTDWOpenSSLHelper.Verify_RSASHA256(bHeader, bPayload, bSignature, APublicKey);
end;

end.
