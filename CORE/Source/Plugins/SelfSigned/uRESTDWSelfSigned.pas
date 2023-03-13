unit uRESTDWSelfSigned;

{$I ..\..\..\Source\Includes\uRESTDW.inc}

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
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

{ Helpers that use the OpenSSL library for various security and crypto related tasks }
{ Testado com OpenSSL 1.1}
{ https://github.com/grijjy/DelphiOpenSsl}

interface

uses
  Classes,
  SysUtils,
  uRESTDWBasic,
  uRESTDWConsts,
  uRESTDWTools,
  uRESTDWSelfSignedMacros,
  uRESTDWOpenSslLib;

type
  TSslDigest = (
      Digest_md5,
      Digest_mdc2,
      Digest_sha1,
      Digest_sha224,
      Digest_sha256,
      Digest_sha384,
      Digest_sha512,
      Digest_ripemd160,
      Digest_sha3_224,
      Digest_sha3_256,
      Digest_sha3_384,
      Digest_sha3_512,
      Digest_shake128,
      Digest_shake256,
      Digest_None);

  TSslPrivKeyType = (
      PrivKeyRsa1024,   { level 1 - 80 bits  }
      PrivKeyRsa2048,   { level 2 - 112 bits }
      PrivKeyRsa3072,   { level 3 - 128 bits }
      PrivKeyRsa4096,   { level 3 - 128 bits }
      PrivKeyRsa7680,   { level 4 - 192 bits }
      PrivKeyRsa15360,  { level 5 - 256 bits }
      PrivKeyECsecp256, { level 3 - 128 bits secp256r1 }
      PrivKeyECsecp384, { level 4 - 192 bits }
      PrivKeyECsecp512, { level 5 - 256 bits }
      PrivKeyEd25519,   { level 3 - 128 bits }
      PrivKeyRsaPss2048,   { level 2 - 112 bits }
      PrivKeyRsaPss3072,   { level 3 - 128 bits }
      PrivKeyRsaPss4096,   { level 3 - 128 bits }
      PrivKeyRsaPss7680,   { level 4 - 192 bits }
      PrivKeyRsaPss15360,  { level 5 - 256 bits }
      PrivKeyECsecp256k);  { level 3 - 128 bits secp256k1 }

  TSslPrivKeyCipher = (
       PrivKeyEncNone,
       PrivKeyEncTripleDES,
       PrivKeyEncIDEA,
       PrivKeyEncAES128,
       PrivKeyEncAES192,
       PrivKeyEncAES256);

  TSslCipher = (
      Cipher_none,
      Cipher_aes_128_cbc,
      Cipher_aes_128_cfb,
      Cipher_aes_128_ecb,
      Cipher_aes_128_ofb,
      Cipher_aes_128_gcm,
      Cipher_aes_128_ocb,
      Cipher_aes_128_ccm,
      Cipher_aes_192_cbc,
      Cipher_aes_192_cfb,
      Cipher_aes_192_ecb,
      Cipher_aes_192_ofb,
      Cipher_aes_192_gcm,
      Cipher_aes_192_ocb,
      Cipher_aes_192_ccm,
      Cipher_aes_256_cbc,    { used for PKC12 }
      Cipher_aes_256_cfb,
      Cipher_aes_256_ecb,
      Cipher_aes_256_ofb,
      Cipher_aes_256_gcm,
      Cipher_aes_256_ocb,
      Cipher_aes_256_ccm,
      Cipher_bf_cbc,        { blowfish needs key length set, 128, 192 or 256 }
      Cipher_bf_cfb64,
      Cipher_bf_ecb,
      Cipher_bf_ofb,
      Cipher_chacha20,      { chacha20 fixed 256 key }
      Cipher_des_ede3_cbc,
      Cipher_des_ede3_cfb64,
      Cipher_des_ede3_ecb,
      Cipher_des_ede3_ofb,
      Cipher_idea_cbc,      { IDEA fixed 128 key }
      Cipher_idea_cfb64,
      Cipher_idea_ecb,
      Cipher_idea_ofb);
  Type
  { TRESTDWSelfSigned }
  TRESTDWSelfSigned = class(TRESTDWSelfSignedBase)
  private
    FCertificate: PX509;
    FPrivateKey: PEVP_PKEY;

    FPrivateKeyType : TSslPrivKeyType;
    FCertDigest : TSslDigest;

    FOpenSSLVersion : Cardinal;
    FLastSslError : Cardinal;
    FLastSslErrMsg : string;

    FCountry : string;
    FState : string;
    FLocality : string;
    FOrganization : string;
    FOrgUnit : string;
    FCommonName: string;
    FServerName: string;
    FEmail : string;
    FExpiresDays: integer;

    FOnKeyProgress : TNotifyEvent;
  protected
    function SetRandomSerial(const ACertificate: PX509): Boolean;
  protected
    function RandomBytes(const ASize: Integer): TBytes;
    function RandomString(const ACharset: String; const ASize: Integer): String; overload;
    function RandomString(const ASize: Integer): String; overload;
    function RandomChars(const ASize: Integer): String;
    function RandomLowerString(const ASize: Integer): String;
    function RandomLowerChars(const ASize: Integer): String;
    function RandomDigits(const ASize: Integer): String;
  protected
    function Sign_RSASHA256(const AData: TBytes; const APrivateKey: TBytes; out ASignature: TBytes): Boolean;
    function Verify_RSASHA256(const AHeader, APayload, ASignature: TBytes; const APublicKey: TBytes): Boolean;
    function HMAC_SHA256(const AKey, AData: RawByteString): String;
    function HMAC_SHA1(const AKey, AData: RawByteString): TBytes;
  protected
    procedure RaiseSslError(CustomMsg : string);
    function LastOpenSslErrMsg(Dump: Boolean): string;
    function SslGetEVPDigest(Digest: TSslDigest): PEVP_MD;
    function SslGetEVPCipher(Cipher: TSslCipher): PEVP_CIPHER;
    procedure DoKeyPair;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    procedure ClearCerts;
    function CreateSelfSignedCert : Boolean;

    procedure SavePrivateKeyToPemFile(filename : string; password : string = ''; keytype: TSslPrivKeyCipher = PrivKeyEncNone);
    procedure SavePrivateKeyToPemStream(var stream : TStream; password : string = ''; keytype: TSslPrivKeyCipher = PrivKeyEncNone);

    procedure SaveCertToPemFile(filename : string);
    procedure SaveCertToPemStream(var stream : TStream);
  published
    property Country : string read FCountry write FCountry;
    property State : string read FState write FState;
    property Locality : string read FLocality write FLocality;
    property Organization : string read FOrganization write FOrganization;
    property OrgUnit : string read FOrgUnit write FOrgUnit;
    property CommonName: string read FCommonName write FCommonName;
    property Email: string read FEmail write FEmail;
    property ServerName: string read FServerName write FServerName;
    property ExpiresDays: integer read FExpiresDays write FExpiresDays;

    property PrivateKeyType : TSslPrivKeyType read FPrivateKeyType write FPrivateKeyType;
    property CertDigest : TSslDigest read FCertDigest write FCertDigest;

    property OnKeyProgress : TNotifyEvent read FOnKeyProgress write FOnKeyProgress;
  end;

implementation

const
  SslPrivKeyEvpCipher: array[TSslPrivKeyCipher] of TSslCipher = (
    Cipher_none,
    Cipher_des_ede3_cbc,
    Cipher_idea_cbc,
    Cipher_aes_128_cbc,
    Cipher_aes_192_cbc,
    Cipher_aes_256_cbc
  );

resourcestring
  eossl_randfail         = 'Random generator failed';
  eossl_loadcheckversion = 'Error loading OpenSSL, check version';
  eossl_noerrors         = 'No error returned';
  eossl_unknownpkeytype  = 'Unknown Private Key Type';
  eossl_createnewkeyinfo = 'Failed to create new %s key';
  eossl_failinitkeyinfo  = 'Failed to init %s keygen';
  eossl_failsetrsabits   = 'Failed to set RSA bits';
  eossl_failseteccurve   = 'Failed to set EC curve';
  eossl_failgenkeyinfo   = 'Failed to generate %s key';
  eossl_failcreatekey    = 'Failed to create new %s key, empty';
  eossl_errorsavepem     = 'Error to Save PEM Stream (%s)';

{ TRESTDWSelfSigned }

function TRESTDWSelfSigned.RandomBytes(const ASize: Integer): TBytes;
begin
  SetLength(Result, ASize);
  if RAND_bytes(@Result[0], ASize) <> 1 then
    raise Exception.Create(eossl_randfail);
end;

function TRESTDWSelfSigned.RandomString(const ACharset: String; const ASize: Integer): String;
var
  I: Integer;
  Bytes: TBytes;
begin
  SetLength(Result, ASize);
  Bytes := RandomBytes(ASize);
  {$IF (Defined(FPC)) or (CompilerVersion > 21)}
    for I := 0 to ASize - 1 do
      Result[I + Low(String)] := ACharset[Bytes[I] MOD Length(ACharset) + Low(String)];
  {$ELSE}
    for I := 0 to ASize - 1 do
      Result[I + 1] := ACharset[Bytes[I] MOD Length(ACharset) + 1];
  {$IFEND}
end;

function TRESTDWSelfSigned.RandomString(const ASize: Integer): String;
const
  ALL_ALPHANUMERIC_CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Result := RandomString(ALL_ALPHANUMERIC_CHARS, ASize);
end;

function TRESTDWSelfSigned.RandomChars(const ASize: Integer): String;
const
  ALL_ALPHA_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Result := RandomString(ALL_ALPHA_CHARS, ASize);
end;

function TRESTDWSelfSigned.RandomLowerString(const ASize: Integer): String;
const
  ALL_LOWER_ALPHANUMERIC_CHARS = '0123456789abcdefghijklmnopqrstuvwxyz';
begin
  Result := RandomString(ALL_LOWER_ALPHANUMERIC_CHARS, ASize);
end;

function TRESTDWSelfSigned.RandomLowerChars(const ASize: Integer): String;
const
  ALL_LOWER_ALPHA_CHARS = 'abcdefghijklmnopqrstuvwxyz';
begin
  Result := RandomString(ALL_LOWER_ALPHA_CHARS, ASize);
end;

function TRESTDWSelfSigned.RandomDigits(const ASize: Integer): String;
const
  ALL_NUMERIC_CHARS = '0123456789';
begin
  Result := RandomString(ALL_NUMERIC_CHARS, ASize);
end;

function TRESTDWSelfSigned.Sign_RSASHA256(const AData: TBytes; const APrivateKey: TBytes;
  out ASignature: TBytes): Boolean;
var
  BIOPrivateKey: PBIO;
  PrivateKey: PEVP_PKEY;
  Ctx: PEVP_MD_CTX;
  SHA256: PEVP_MD;
  Size: NativeUInt;
begin
  BIOPrivateKey := BIO_new_mem_buf(@APrivateKey[0], Length(APrivateKey));
  try
    PrivateKey := PEM_read_bio_PrivateKey(BIOPrivateKey, nil, nil, nil);
    try
      Ctx := EVP_MD_CTX_create;
      try
        SHA256 := EVP_sha256;
        if (EVP_DigestSignInit(Ctx, nil, SHA256, nil, PrivateKey) > 0) and
          (EVP_DigestUpdate(Ctx, @AData[0], Length(AData)) > 0) and
          (EVP_DigestSignFinal(Ctx, nil, Size) > 0) then begin
          SetLength(ASignature, Size);
          Result := EVP_DigestSignFinal(Ctx, @ASignature[0], Size) > 0;
        end
        else
          Result := False;
      finally
        EVP_MD_CTX_destroy(Ctx);
      end;
    finally
      EVP_PKEY_free(PrivateKey);
    end;
  finally
    BIO_free(BIOPrivateKey);
  end;
end;

function EVP_DigestVerifyUpdate(a : PEVP_MD_CTX; b : Pointer; c : NativeInt) : NativeInt;
begin
  Result := EVP_DigestUpdate(a,b,NativeInt(c));
end;

function TRESTDWSelfSigned.Verify_RSASHA256(const AHeader, APayload, ASignature: TBytes; const APublicKey: TBytes): Boolean;
const
  PKCS1_SIGNATURE_PUBKEY: RawByteString = '-----BEGIN RSA PUBLIC KEY-----';
var
  BIOPublicKey: PBIO;
  RSA: PRSA;
  PublicKey: PEVP_PKEY;
  Ctx: PEVP_MD_CTX;
  SHA256: PEVP_MD;
  Dot: RawByteString;
begin
  Dot := '.';

  BIOPublicKey := BIO_new(BIO_s_mem);
  BIO_write(BIOPublicKey, @APublicKey[0], Length(APublicKey));

  try
    if CompareMem(@PKCS1_SIGNATURE_PUBKEY[1], @APublicKey[0], Length(PKCS1_SIGNATURE_PUBKEY)) then
      RSA := PEM_read_bio_RSAPublicKey(BIOPublicKey, nil, nil, nil)
    else
      RSA := PEM_read_bio_RSA_PUBKEY(BIOPublicKey, nil, nil, nil);

    PublicKey := EVP_PKEY_new;
    if EVP_PKEY_assign(PublicKey, EVP_PKEY_RSA, RSA) <> 1 then
      raise Exception.Create('[RSA] Unable to extract public key');
    try
      Ctx := EVP_MD_CTX_create;
      try
        SHA256 := EVP_sha256;

        if (EVP_DigestVerifyInit(Ctx, nil, SHA256, nil, PublicKey) <> 1) then
          raise Exception.Create('1');

        if (EVP_DigestUpdate(Ctx, @AHeader[0], Length(AHeader)) <> 1) then
          raise Exception.Create('2');

        if (EVP_DigestUpdate(Ctx, @Dot[1], 1) <> 1) then
          raise Exception.Create('3');

        if (EVP_DigestUpdate(Ctx, @APayload[0], Length(APayload)) <> 1) then
          raise Exception.Create('4');

        Result := (EVP_DigestVerifyFinal(Ctx, @ASignature[0], Length(ASignature)) = 1);
      finally
        EVP_MD_CTX_destroy(Ctx);
      end;
    finally
      EVP_PKEY_free(RSA);
    end;
  finally
	  BIO_free(BIOPublicKey);
  end;
end;

{$IF (NOT Defined(FPC)) AND (CompilerVersion > 21)}
  function TRESTDWSelfSigned.HMAC_SHA256(const AKey, AData: RawByteString): String;
  const
    EVP_MAX_MD_SIZE = 64;
  var
    MessageAuthCode: PByte;
    Size: Cardinal;
    Buffer, Text: TBytes;
  begin
    Size := EVP_MAX_MD_SIZE;
    SetLength(Buffer, Size);
    MessageAuthCode := HMAC(EVP_sha256, @AKey[1], Length(AKey), @AData[1], Length(AData), @Buffer[0], Size);
    if MessageAuthCode <> nil then
    begin
      SetLength(Text, Size * 2);
      BinToHex(Buffer, 0, Text, 0, Size);
      Result := TEncoding.UTF8.GetString(Text).ToLower;
    end;
  end;
{$ELSE}
  function TRESTDWSelfSigned.HMAC_SHA256(const AKey, AData: RawByteString): String;
  begin
    Result := EncryptSHA256(AKey,AData,True);
  end;
{$IFEND}

function TRESTDWSelfSigned.HMAC_SHA1(const AKey, AData: RawByteString): TBytes;
const
  EVP_MAX_MD_SIZE = 20;
var
  MessageAuthCode: PByte;
  Size: Cardinal;
begin
  Size := EVP_MAX_MD_SIZE;
  SetLength(Result, Size);
  MessageAuthCode := HMAC(EVP_sha1, @AKey[1], Length(AKey), @AData[1], Length(AData), @Result[0], Size);
  if MessageAuthCode <> nil then
    SetLength(Result, Size);
end;

procedure TRESTDWSelfSigned.RaiseSslError(CustomMsg : string);
begin
  FLastSslError := ERR_peek_error();
  FLastSslErrMsg := String(LastOpenSslErrMsg(False));
  if Length(CustomMsg) > 0 then
    FLastSslErrMsg := CustomMsg + ' - ' + FLastSslErrMsg;
  raise Exception.Create(#13#10 + FLastSslErrMsg + #13#10)
end;

function TRESTDWSelfSigned.LastOpenSslErrMsg(Dump : Boolean) : string;
var
  ErrMsg  : AnsiString;
  ErrCode : Integer;
begin
  if @ERR_get_error = nil then begin
    Result := eossl_loadcheckversion;
    Exit;
  end;

  ErrCode := ERR_get_error();
  if ErrCode = 0 then begin
    Result := eossl_noerrors;
    Exit;
  end;

  SetLength(Result, 120);
  ERR_error_string_n(ErrCode, PAnsiChar(Result), Length(Result));
  SetLength(Result, StrLen(PAnsiChar(Result)));
  if Dump then begin
    ErrCode := ERR_get_error();
    while ErrCode <> 0 do begin
      SetLength(ErrMsg, 120);
      ERR_error_string_n(ErrCode, PAnsiChar(ErrMsg), Length(ErrMsg));
      SetLength(ErrMsg, StrLen(PAnsiChar(ErrMsg)));
      Result := Result + sLineBreak + ErrMsg;
      ErrCode := ERR_get_error();
    end;
  end;
end;

procedure TRESTDWSelfSigned.DoKeyPair;
var
  Bits, KeyNid, CurveNid: Integer;
  Pctx: PEVP_PKEY_CTX;
  KeyInfo: string;
begin
  { note private keys can use DSA, but this is now obsolete }
  if Assigned(FPrivateKey) then
    EVP_PKEY_free(FPrivateKey);

  FPrivateKey := nil;

  CurveNid := 0;
  Bits := 0;
  if (FPrivateKeyType >= PrivKeyRsa1024) and (FPrivateKeyType <= PrivKeyRsa15360) then begin
    KeyNid := EVP_PKEY_RSA;
    KeyInfo := 'RSA';
    Bits := 2048;
    case FPrivateKeyType of
      PrivKeyRsa1024  : Bits := 1024;
      PrivKeyRsa2048  : Bits := 2048;
      PrivKeyRsa3072  : Bits := 3072;
      PrivKeyRsa4096  : Bits := 4096;
      PrivKeyRsa7680  : Bits := 7680;
      PrivKeyRsa15360 : Bits := 15360;
    end;
  end
  else if (FPrivateKeyType = PrivKeyEd25519) then begin
    KeyNid := EVP_PKEY_ED25519;
    KeyInfo := 'ED25519';
  end
  else if (FPrivateKeyType >= PrivKeyRsaPss2048) and (FPrivateKeyType <= PrivKeyRsaPss15360) then begin
    KeyNid := EVP_PKEY_RSA_PSS;
    KeyInfo := 'RSA-PSS';
    Bits := 2048;
    case FPrivateKeyType of
      PrivKeyRsaPss2048  : Bits := 2048;
      PrivKeyRsaPss3072  : Bits := 3072;
      PrivKeyRsaPss4096  : Bits := 4096;
      PrivKeyRsaPss7680  : Bits := 7680;
      PrivKeyRsaPss15360 : Bits := 15360;
    end;
  end
  else if (FPrivateKeyType >= PrivKeyECsecp256) and (FPrivateKeyType <= PrivKeyECsecp512) then begin
    KeyNid := EVP_PKEY_EC;
    KeyInfo := 'EC';
    CurveNid := NID_X9_62_prime256v1;
    case FPrivateKeyType of
      PrivKeyECsecp256  : CurveNid := NID_X9_62_prime256v1;
      PrivKeyECsecp384  : CurveNid := NID_secp384r1;
      PrivKeyECsecp512  : CurveNid := NID_secp521r1;
      PrivKeyECsecp256k : CurveNid := NID_secp256k1;
    end;
  end
  else begin
    RaiseSslError(eossl_unknownpkeytype);  { V8.64 need an error }
    Exit;
  end;

  { initialise context for private keys }
  Pctx := EVP_PKEY_CTX_new_id(KeyNid, nil);
  if not Assigned(Pctx) then
    RaiseSslError(Format(eossl_createnewkeyinfo,[KeyInfo]));

  if EVP_PKEY_keygen_init(Pctx) = 0 then
    RaiseSslError(Format(eossl_failinitkeyinfo,[KeyInfo]));

  if (KeyNid = EVP_PKEY_RSA) or (KeyNid = EVP_PKEY_RSA_PSS) then begin
    if (Bits > 0) and (EVP_PKEY_CTX_set_rsa_keygen_bits(Pctx, Bits) = 0) then
      RaiseSslError(eossl_failsetrsabits);
  end;

  if (CurveNid > 0) and (EVP_PKEY_CTX_set_ec_paramgen_curve_nid(Pctx, CurveNid) = 0) then
    RaiseSslError(eossl_failseteccurve);

  if (KeyNid = EVP_PKEY_RSA_PSS) then begin
    // pending - various macros to restrict digests, MGF1 and minimum salt length
    // EVP_PKEY_CTX_set_rsa_pss_keygen_md
    // EVP_PKEY_CTX_set_rsa_pss_saltlen
    // EVP_PKEY_CTX_set_rsa_pss_keygen_mgf1_md
  end;


  { progress callback, really only needed for slow RSA }
  EVP_PKEY_CTX_set_app_data(Pctx, Self);
  EVP_PKEY_CTX_set_cb(Pctx, @EVPPKEYCBcallFunc);

  { generate private key pair }
  if EVP_PKEY_keygen(Pctx, @FPrivateKey) = 0 then
    RaiseSslError(Format(eossl_failgenkeyinfo,[KeyInfo]));
  if not Assigned(FPrivateKey) then
    RaiseSslError(Format(eossl_failcreatekey,[KeyInfo]));

  FPrivateKey := EVP_PKEY_dup(FPrivateKey);
//  SetPrivateKey(FPrivateKey);
  EVP_PKEY_CTX_free(Pctx);
end;

function TRESTDWSelfSigned.SslGetEVPDigest(Digest : TSslDigest) : PEVP_MD;
begin
  case Digest of
    Digest_md5       : Result := EVP_md5();
    Digest_mdc2      : Result := EVP_mdc2();
    Digest_sha1      : Result := EVP_sha1();
    Digest_sha224    : Result := EVP_sha224();
    Digest_sha256    : Result := EVP_sha256();
    Digest_sha384    : Result := EVP_sha384();
    Digest_sha512    : Result := EVP_sha512();
    Digest_ripemd160 : Result := EVP_ripemd160();
    else               Result := Nil;
  end;
  if Assigned(result) then
    Exit;

  case Digest of
    Digest_sha3_224  : Result := EVP_sha3_224();
    Digest_sha3_256  : Result := EVP_sha3_256();
    Digest_sha3_384  : Result := EVP_sha3_384();
    Digest_sha3_512  : Result := EVP_sha3_512();
    Digest_shake128  : Result := EVP_shake128();
    Digest_shake256  : Result := EVP_shake256();
  end;
end;

function TRESTDWSelfSigned.SslGetEVPCipher(Cipher : TSslCipher) : PEVP_CIPHER;
begin
  Result := EVP_enc_null;
  case Cipher of
    Cipher_none           : Result := EVP_enc_null();
    Cipher_aes_128_cbc    : Result := EVP_aes_128_cbc();
    Cipher_aes_128_cfb    : Result := EVP_aes_128_cfb128();
    Cipher_aes_128_ecb    : Result := EVP_aes_128_ecb();
    Cipher_aes_128_ofb    : Result := EVP_aes_128_ofb();
    Cipher_aes_128_gcm    : Result := EVP_aes_128_gcm();
    Cipher_aes_128_ocb    : Result := EVP_aes_128_ocb();
    Cipher_aes_128_ccm    : Result := EVP_aes_128_ccm();
    Cipher_aes_192_cbc    : Result := EVP_aes_192_cbc();
    Cipher_aes_192_cfb    : Result := EVP_aes_192_cfb128();
    Cipher_aes_192_ecb    : Result := EVP_aes_192_ecb();
    Cipher_aes_192_ofb    : Result := EVP_aes_192_ofb();
    Cipher_aes_192_gcm    : Result := EVP_aes_192_gcm();
    Cipher_aes_192_ocb    : Result := EVP_aes_192_ocb();
    Cipher_aes_192_ccm    : Result := EVP_aes_192_ccm();
    Cipher_aes_256_cbc    : Result := EVP_aes_256_cbc();
    Cipher_aes_256_cfb    : Result := EVP_aes_256_cfb128();
    Cipher_aes_256_ecb    : Result := EVP_aes_256_ecb();
    Cipher_aes_256_ofb    : Result := EVP_aes_256_ofb();
    Cipher_aes_256_gcm    : Result := EVP_aes_256_gcm();
    Cipher_aes_256_ocb    : Result := EVP_aes_256_ocb();
    Cipher_aes_256_ccm    : Result := EVP_aes_256_ccm();
    Cipher_bf_cbc         : Result := EVP_bf_cbc();       { blowfish needs key length set }
    Cipher_bf_cfb64       : Result := EVP_bf_cfb64();
    Cipher_bf_ecb         : Result := EVP_bf_ecb();
    Cipher_bf_ofb         : Result := EVP_bf_ofb();
    Cipher_chacha20       : Result := EVP_chacha20();
    Cipher_des_ede3_cbc   : Result := EVP_des_ede3_cbc();
    Cipher_des_ede3_cfb64 : Result := EVP_des_ede3_cfb64();
    Cipher_des_ede3_ecb   : Result := EVP_des_ede3_ecb();
    Cipher_des_ede3_ofb   : Result := EVP_des_ede3_ofb();
    Cipher_idea_cbc       : Result := EVP_idea_cbc();
    Cipher_idea_cfb64     : Result := EVP_idea_cfb64();
    Cipher_idea_ecb       : Result := EVP_idea_ecb();
    Cipher_idea_ofb       : Result := EVP_idea_ofb();
  end;
end;

constructor TRESTDWSelfSigned.Create(AOwner: TComponent);
begin
  inherited;

  FCertificate := nil;
  FPrivateKey := nil;

  if (LoadCrypto) and (LoadSSL) then
    FOpenSSLVersion := OpenSSL_version_num();
end;

destructor TRESTDWSelfSigned.Destroy;
begin
  ClearCerts;
  
  UnloadCrypto;
  UnloadSSL;  
  
  inherited Destroy;
end;

procedure TRESTDWSelfSigned.ClearCerts;
begin
  if FPrivateKey <> nil then
    EVP_PKEY_free(FPrivateKey);

  if FCertificate <> nil then
    X509_free(FCertificate);
end;

function TRESTDWSelfSigned.SetRandomSerial(const ACertificate: PX509): Boolean;
var
  Buffer: TBytes;
  Bignum: PBIGNUM;
  Serial: PASN1_INTEGER;
begin
  { 20 byte random serial number }
  Buffer := RandomBytes(20);
  Buffer[0] := Buffer[0] AND $7F; // Positive value

  Bignum := BN_new();
  if Bignum = nil then begin
    Result := False;
    Exit;
  end;

  try
    BN_bin2bn(Pointer(Buffer), Length(Buffer), Bignum);
    Serial := ASN1_INTEGER_new();
    if Serial = nil then begin
      Result := False;
      Exit;
    end;
    
    try
      { Set the serial number }
      BN_to_ASN1_INTEGER(Bignum, Serial);
      X509_set_serialNumber(ACertificate, Serial);

      Result := True;
    finally
      if Serial <> nil then
        ASN1_INTEGER_free(Serial);
    end;
  finally
    if Bignum <> nil then
      BN_free(Bignum);
  end;
end;

function TRESTDWSelfSigned.CreateSelfSignedCert : Boolean;
var
  AName: PX509_NAME;
  Extension: PX509_EXTENSION;
  AServerName: RawByteString;
begin
  if (not LoadCrypto) or (not LoadSSL) then
    Exit;

  ClearCerts;

  { Create a self-signed certificate }
  FCertificate := X509_new();
  if FCertificate = nil then begin
    Result := False;
    Exit;
  end;

  try
    { Set version to X509v3 }
    if X509_set_version(FCertificate, 2) <> 1 then begin
      Result := False;
      Exit;
    end;

    { Set random serial }
    if not SetRandomSerial(FCertificate) then begin
      Result := False;
      Exit;
    end;

    { Set expiration of the certificate }
    X509_gmtime_adj(X509_get_notBefore(FCertificate), 0);
    X509_gmtime_adj(X509_get_notAfter(FCertificate), 60 * 60 * 24 * FExpiresDays);

    { Apply the name for the request }
    AName := X509_get_subject_name(FCertificate);
    X509_NAME_add_entry_by_txt(AName, 'C', MBSTRING_ASC, PAnsiChar(FCountry), -1, -1, 0);
    X509_NAME_add_entry_by_txt(AName, 'ST', MBSTRING_ASC, PAnsiChar(FState), -1, -1, 0);
    X509_NAME_add_entry_by_txt(AName, 'L', MBSTRING_ASC, PAnsiChar(FLocality), -1, -1, 0);
    X509_NAME_add_entry_by_txt(AName, 'O', MBSTRING_ASC, PAnsiChar(FOrganization), -1, -1, 0);
    X509_NAME_add_entry_by_txt(AName, 'OU', MBSTRING_ASC, PAnsiChar(FOrgUnit), -1, -1, 0);
    X509_NAME_add_entry_by_txt(AName, 'CN', MBSTRING_ASC, PAnsiChar(FCommonName), -1, -1, 0);

    if Length(FEmail) > 0 then begin
      X509_NAME_add_entry_by_NID(AName, NID_pkcs9_emailAddress,
                                 MBSTRING_ASC, PAnsiChar((FEmail)), -1, -1, 0);
    end;

    { Set issuer to subject }
    if X509_set_issuer_name(FCertificate, AName) <> 1 then begin
      Result := False;
      Exit;
    end;

    { Set the server name }
    if FServerName <> '' then  begin
      AServerName := 'DNS:' + AnsiString(FServerName);
      Extension := X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, PAnsiChar(AServerName));
      if Extension = nil then begin
        Result := False;
        Exit;
      end;
      try
        X509_add_ext(FCertificate, Extension, -1);
      finally
        X509_EXTENSION_free(Extension);
      end;
    end;

    DoKeyPair;

    if FPrivateKey = nil then begin
      Result := False;
      Exit;
    end;

    try
      { Assign the public key from the private key }
      if X509_set_pubkey(FCertificate, FPrivateKey) <> 1 then begin
        Result := False;
        Exit;
      end;

      { V8.51 no digest for EVP_PKEY_ED25519 }
      if EVP_PKEY_base_id(FPrivateKey) = EVP_PKEY_ED25519 then begin
        if X509_sign(FCertificate, FPrivateKey, nil) = 0 then begin
          Result := False;
          Exit;
        end;
      end
      else begin
        if X509_sign(FCertificate, FPrivateKey, SslGetEVPDigest(FCertDigest)) <= 0 then begin
          Result := False;
          Exit;
        end;
      end;

      Result := True;
    finally

    end;
  finally

  end;
end;

procedure TRESTDWSelfSigned.SavePrivateKeyToPemFile(filename : string; password : string; keytype : TSslPrivKeyCipher);
var
  fs : TFileStream;
begin
  fs := TFileStream.Create(filename,fmCreate);
  try
    SavePrivateKeyToPemStream(TStream(fs),password,keytype);
  finally
    fs.Free;
  end;
end;

procedure TRESTDWSelfSigned.SavePrivateKeyToPemStream(var stream : TStream; password : string; keytype : TSslPrivKeyCipher);
var
  BIOPrivateKey: PBIO;
  DERPrivateKey: TBytes;
  Pending, Read: Integer;
  PPassWord : PAnsiChar;
  bOk : boolean;
  cipher1 : TSslCipher;
  cipher2 : PEVP_CIPHER;
begin
  if (not LoadCrypto) or (not LoadSSL) then
    Exit;

  stream.Size := 0;

  { Write the private key }
  cipher1 := SslPrivKeyEvpCipher[keytype];
  cipher2 := SslGetEVPCipher(cipher1);

  BIOPrivateKey := BIO_new(BIO_s_mem());
  try
    PPassWord := nil;
    if (password <> '') and (keytype <> PrivKeyEncNone) then begin
      PPassWord := PAnsiChar(Password);
      bOk := PEM_write_bio_PKCS8PrivateKey(BIOPrivateKey,FPrivateKey,cipher2,@PPassWord[0],Length(password),nil,nil) = 1;
    end
    else begin
      bOk := PEM_write_bio_PKCS8PrivateKey(BIOPrivateKey,FPrivateKey,nil,nil,0,nil,nil) = 1;
    end;

    if bOk then begin
      Pending := bio_ctrl_pending(BIOPrivateKey);
      SetLength(DERPrivateKey, Pending);
      Read := BIO_read(BIOPrivateKey, Pointer(DERPrivateKey), Pending);
      if Read > 0 then begin
        SetLength(DERPrivateKey, Read);
        stream.Write(DERPrivateKey[0],Read);
      end;
    end
    else begin
      RaiseSslError(Format(eossl_errorsavepem,['PrivateKey']));
    end;
  finally
    if BIOPrivateKey <> nil then
      BIO_free(BIOPrivateKey);
  end;
end;

procedure TRESTDWSelfSigned.SaveCertToPemFile(filename : string);
var
  fs : TFileStream;
begin
  fs := TFileStream.Create(filename,fmCreate);
  try
    SaveCertToPemStream(TStream(fs));
  finally
    fs.Free;
  end;
end;

procedure TRESTDWSelfSigned.SaveCertToPemStream(var stream : TStream);
var
  BIOCert : PBIO;
  DERCert : TBytes;
  Pending, Read: Integer;
  bOk : boolean;
begin
  stream.Size := 0;

  { Write the certificate chain }
  BIOCert := BIO_new(BIO_s_mem());
  try
    bOk := True;
    if PEM_write_bio_X509(BIOCert,FCertificate) <> 1 then
      bOk := False;

    if bOk then begin
      Pending := bio_ctrl_pending(BIOCert);
      SetLength(DERCert, Pending);
      Read := BIO_read(BIOCert, Pointer(DERCert), Pending);
      if Read > 0 then begin
        SetLength(DERCert, Read);
        stream.Write(DERCert[0],Read);
      end;
    end
    else begin
      RaiseSslError(Format(eossl_errorsavepem,['Certificate']));
    end;
  finally
    if BIOCert <> nil then
      BIO_free(BIOCert);
  end;
end;

end.
