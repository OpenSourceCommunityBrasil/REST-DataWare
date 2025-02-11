unit uRESTDW.OpenSsl_11;
{ Helpers that use the OpenSSL library for various security and crypto related tasks }

{$I uRESTDW.inc}

interface

uses
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   uRESTDW.System,
   System.SysUtils,
   System.NetEncoding,
  {$ELSE}
   SysUtils,
  {$IFEND}
  OpenSSL.Api_11,
  uRESTDWProtoTypes;
 {$ELSE}
  uRESTDW.System,
  SysUtils,
  System.NetEncoding,
  OpenSSL.Api_11,
  uRESTDWProtoTypes,
  uRESTDWConsts;
 {$ENDIF}

const
  { Default bits for RSA }
  RSA_KEY_BITS = 2048;

type
  TRESTDWOpenSSLHelper = class
  protected
    class function CertToPEM(const ACertificates: array of PX509; const APrivateKey: PEVP_PKEY;
      out ACertificatePEM, APrivateKeyPEM: TRESTDWBytes): Boolean; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    class function CreateCertRequest(const ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName: String;
      out ARSA: PRSA; out ACertRequest: PX509_REQ; out APrivateKey: PEVP_PKEY): Boolean; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    class function SetRandomSerial(const ACertificate: PX509): Boolean; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    class function CreateKeyPair_CA(const ACertificateCA: PX509; const APrivateKeyCA: PEVP_PKEY;
      const ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName: String;
      const AServerName: String; const AExpiresDays: Integer;
      out ARSA: PRSA; out ACertificate: PX509; out APrivateKey: PEVP_PKEY): Boolean; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}
  public
    { Generates a crypto-safe random buffer of bytes

      Parameters:
        ASize: the length in bytes

      Returns:
        Bytes of random data }
    class function RandomBytes(const ASize: Integer): TRESTDWBytes; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Generates a crypto-safe random string

      Parameters:
        ACharset: a string of approved characters
        ASize: the length in bytes

      Returns:
        String of random data }
    class function RandomString(const ACharset: String; const ASize: Integer): String; overload; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Generates a crypto-safe random string

      Parameters:
        ASize: the length in bytes

      Returns:
        String of random data }
    class function RandomString(const ASize: Integer): String; overload; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Generates a crypto-safe random string of characters only

      Parameters:
        ASize: the length in bytes

      Returns:
        String of random data }
    class function RandomChars(const ASize: Integer): String; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Generates a crypto-safe lowercase random string

      Parameters:
        ASize: the length in bytes

      Returns:
        String of random data }
    class function RandomLowerString(const ASize: Integer): String; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Generates a crypto-safe random string of lowercase characters only

      Parameters:
        ASize: the length in bytes

      Returns:
        String of random data }
    class function RandomLowerChars(const ASize: Integer): String; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Generates a crypto-safe random string of numbers

      Parameters:
        ASize: the length in bytes

      Returns:
        String of random data }
    class function RandomDigits(const ASize: Integer): String; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}
  public
    { Signs data using a private key to produce a signature

      Parameters:
        AData: the data that the signature is based upon
        APrivateKey: the private key
        ASignature: the resulting signature

      Returns:
        True if the signature was created, False otherwise }
    class function Sign_RSASHA256(const AData: TRESTDWBytes; const APrivateKey: TRESTDWBytes;
      out ASignature: TRESTDWBytes): Boolean; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Verifies data using a public key and a signature

      Parameters:
        AData: the data that the signature is based upon
        ASignature: the resulting signature
        APublicKey: the public key

      Returns:
        True if the signature was verified, False otherwise }
    class function Verify_RSASHA256(const AHeader, APayload, ASignature: TRESTDWBytes; const APublicKey: TRESTDWBytes): Boolean;

    { Creates an HMAC SHA256 hash of the provided data

      Parameters:
        AKay: the key value
        AData: the data that the hash is based upon

      Returns:
        String containing the hash of the data and key }
    class function HMAC_SHA256(const AKey, AData: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF}): String; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Creates an HMAC SHA1 hash of the provided data

      Parameters:
        AKay: the key value
        AData: the data that the hash is based upon

      Returns:
        String containing the hash of the data and key }
    class function HMAC_SHA1(const AKey, AData: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF}): TRESTDWBytes; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}
  public
    { Creates a X.509 self-signed certificate

      Parameters:
        ACountry: the country value of the certificate
        AState: the state value of the certificate
        ALocality: the locality value of the certificate
        AOrganization: the org value of the certificate
        AOrgUnit: the org unit value of the certificate
        ACommonName: the common name value of the certificate
        AServerName: the given DNS name for the certificate (optional)
        AExpiresDays: the number of days before the certificate will expire
        ACertificate: the resulting X.509 certificate
        APrivateKey: the resulting private key

      Returns:
        True if the certificate pair was created, False otherwise }
    {$IFDEF FPC}
    Constructor Create;
    {$ENDIF}
    class function CreateSelfSignedCert_X509(const ACountry,
                                             AState,
                                             ALocality,
                                             AOrganization,
                                             AOrgUnit,
                                             ACommonName        : String;
                                             const AServerName  : String;
                                             const AExpiresDays : Integer;
                                             out ACertificate,
                                             APrivateKey        : TRESTDWBytes): Boolean; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}

    { Creates a X.509 certificate signed by the provided CA

      Parameters:
        ACertificateCA: the certificate authority certificate
        APrivateKeyCA: the certificate authority private key
        APassword: the password for the private key (optional)
        ACountry: the country value of the certificate
        AState: the state value of the certificate
        ALocality: the locality value of the certificate
        AOrganization: the org value of the certificate
        AOrgUnit: the org unit value of the certificate
        ACommonName: the common name value of the certificate
        AServerName: the given DNS name for the certificate (optional)
        AExpiresDays: the number of days before the certificate will expire
        ACertificate: the resulting X.509 certificate
        APrivateKey: the resulting private key

      Returns:
        True if the certificate pair was created, False otherwise }
    class function CreateSelfSignedCert_X509CA(const ACertificateCA,
                                               APrivateKeyCA         : TRESTDWBytes;
                                               const APassword       : String;
                                               const ACountry,
                                               AState,
                                               ALocality,
                                               AOrganization,
                                               AOrgUnit,
                                               ACommonName           : String;
                                               const AServerName     : String;
                                               const AExpiresDays    : Integer;
                                               out ACertificate,
                                               APrivateKey: TRESTDWBytes) : Boolean; {$IFNDEF FPC}{$IF CompilerVersion > 21}static;{$IFEND}{$ELSE}static;{$ENDIF}
  end;

implementation

uses
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   System.Classes
  {$ELSE}
   Classes
  {$IFEND}
 {$ELSE}
  Classes
 {$ENDIF},
  uRESTDWTools,
  uRESTDW.BinaryCoding;

{ TRESTDWOpenSSLHelper }

class function TRESTDWOpenSSLHelper.RandomBytes(const ASize: Integer): TRESTDWBytes;
begin
  SetLength(Result, ASize);
  if RAND_bytes(@Result[0], ASize) <> 1 then
    raise Exception.Create('Random generator failed');
end;

class function TRESTDWOpenSSLHelper.RandomString(const ACharset: String; const ASize: Integer): String;
var
  I: Integer;
  Bytes: TRESTDWBytes;
begin
  SetLength(Result, ASize);
  Bytes := RandomBytes(ASize);
  for I := 0 to ASize - 1 do
   {$IFNDEF FPC}
    {$IF CompilerVersion > 21}
     Result[I + Low(String)] := ACharset[Bytes[I] MOD Length(ACharset) + Low(String)];
    {$ELSE}
     Result[I + 1] := ACharset[Bytes[I] MOD Length(ACharset) + 1];
    {$IFEND}
   {$ELSE}
    Result[I + Low(String)] := ACharset[Bytes[I] MOD Length(ACharset) + Low(String)];
   {$ENDIF}
end;

class function TRESTDWOpenSSLHelper.RandomString(const ASize: Integer): String;
const
  ALL_ALPHANUMERIC_CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Result := RandomString(ALL_ALPHANUMERIC_CHARS, ASize);
end;

class function TRESTDWOpenSSLHelper.RandomChars(const ASize: Integer): String;
const
  ALL_ALPHA_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Result := RandomString(ALL_ALPHA_CHARS, ASize);
end;

class function TRESTDWOpenSSLHelper.RandomLowerString(const ASize: Integer): String;
const
  ALL_LOWER_ALPHANUMERIC_CHARS = '0123456789abcdefghijklmnopqrstuvwxyz';
begin
  Result := RandomString(ALL_LOWER_ALPHANUMERIC_CHARS, ASize);
end;

class function TRESTDWOpenSSLHelper.RandomLowerChars(const ASize: Integer): String;
const
  ALL_LOWER_ALPHA_CHARS = 'abcdefghijklmnopqrstuvwxyz';
begin
  Result := RandomString(ALL_LOWER_ALPHA_CHARS, ASize);
end;

class function TRESTDWOpenSSLHelper.RandomDigits(const ASize: Integer): String;
const
  ALL_NUMERIC_CHARS = '0123456789';
begin
  Result := RandomString(ALL_NUMERIC_CHARS, ASize);
end;

class function TRESTDWOpenSSLHelper.Sign_RSASHA256(const AData: TRESTDWBytes; const APrivateKey: TRESTDWBytes;
  out ASignature: TRESTDWBytes): Boolean;
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
          (EVP_DigestSignFinal(Ctx, nil, Size) > 0) then
        begin
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

class function TRESTDWOpenSSLHelper.Verify_RSASHA256(const AHeader, APayload, ASignature: TRESTDWBytes; const APublicKey: TRESTDWBytes): Boolean;
const
  PKCS1_SIGNATURE_PUBKEY: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF} = '-----BEGIN RSA PUBLIC KEY-----';
var
  BIOPublicKey: PBIO;
  RSA: PRSA;
  PublicKey: PEVP_PKEY;
  Ctx: PEVP_MD_CTX;
  SHA256: PEVP_MD;
  Dot: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF};
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

class function TRESTDWOpenSSLHelper.HMAC_SHA256(const AKey, AData: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF}): String;
const
  EVP_MAX_MD_SIZE = 64;
var
  MessageAuthCode: PByte;
  Size: Cardinal;
  Buffer, Text: TRESTDWBytes;
begin
  Size := EVP_MAX_MD_SIZE;
  SetLength(Buffer, Size);
  MessageAuthCode := HMAC(EVP_sha256, @AKey[1], Length(AKey), @AData[1], Length(AData), @Buffer[0], Size);
  if MessageAuthCode <> nil then
   begin
    SetLength(Text, Size * 2);
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      BinToHex(TBytes(Buffer), 0, TBytes(Text), 0, Size);
      Result := TEncoding.UTF8.GetString(Text).ToLower;
     {$ELSE}
      SetLength(Result, Size);
      BinToHex(PChar(Buffer), PChar(Result), Size);
     {$IFEND}
    {$ELSE}
     SetLength(Result, Size);
     BinToHex(PChar(Buffer), PChar(Result), Size);
    {$ENDIF}
   end;
end;

{$IFDEF FPC}
Constructor TRESTDWOpenSSLHelper.Create;
Begin
 Inherited;
End;
{$ENDIF}

class function TRESTDWOpenSSLHelper.HMAC_SHA1(const AKey, AData: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF}): TRESTDWBytes;
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

class function TRESTDWOpenSSLHelper.CertToPEM(const ACertificates: array of PX509; const APrivateKey: PEVP_PKEY;
  out ACertificatePEM, APrivateKeyPEM: TRESTDWBytes): Boolean;
var
  I              : Integer;
  Certificate    : PX509;
  BIOCert,
  BIOPrivateKey  : PBIO;
  DERCert,
  DERPrivateKey,
  FTempBytes,
  FTempBytesB    : TRESTDWBytes;
  Pending,
  Read           : Integer;
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21}
    Base64       : TBase64Encoding;
   {$IFEND}
  {$ENDIF}
begin
  { Write the certificate chain }
  for I := 0 To Length(ACertificates) -1 do
  begin
   Certificate := ACertificates[I];
    BIOCert := BIO_new(BIO_s_mem);
    try
      if i2d_X509_bio(BIOCert, Certificate) <> 1 then
        Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
      Pending := bio_ctrl_pending(BIOCert);
      SetLength(DERCert, Pending);
      Read := BIO_read(BIOCert, {$IFNDEF FPC}DERCert{$ELSE}Pointer(DERCert){$ENDIF}, Pending);
      if Read > 0 then
      begin
        SetLength(DERCert, Read);
        {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
          Base64 := TBase64Encoding.Create{$IFNDEF FPC}(64, #10){$ENDIF};
         {$IFEND}
        {$ENDIF}
        try
         {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
           FTempBytes  := TRESTDWBytes(TEncoding.ANSI.GeTBytes('-----BEGIN CERTIFICATE-----' + #10  +
                                                                Base64.EncodeBytesToString(DERCert) + #10 +
                                                               '-----END CERTIFICATE-----' + #10));

           ACertificatePEM := ACertificatePEM + FTempBytes;
          {$ELSE}
           FTempBytes  := StringToBytes('-----BEGIN CERTIFICATE-----' + #10 +
                                        EncodeStrings(BytesToString(DERCert))
                                        + #10 +
                                        '-----END CERTIFICATE-----' + #10);
           FTempBytesB := ACertificatePEM;
           SetLength(ACertificatePEM, Length(FTempBytesB) + Length(FTempBytes));
           Move(FTempBytesB[0], ACertificatePEM[0],                   Length(FTempBytesB));
           Move(FTempBytes[0],  ACertificatePEM[Length(FTempBytesB)], Length(FTempBytes));
          {$IFEND}
         {$ELSE}
          FTempBytes  := TRESTDWBytes(TEncoding.ANSI.GeTBytes('-----BEGIN CERTIFICATE-----' + #10 +
                                                               EncodeStrings(BytesToString(DERCert), csUndefined)
                                                              + #10 +
                                                              '-----END CERTIFICATE-----' + #10));
          FTempBytesB := ACertificatePEM;
          SetLength(ACertificatePEM, Length(FTempBytesB) + Length(FTempBytes));
          Move(FTempBytesB[0], ACertificatePEM[0],                   Length(FTempBytesB));
          Move(FTempBytes[0],  ACertificatePEM[Length(FTempBytesB)], Length(FTempBytes));
         {$ENDIF}
        finally
         {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
           Base64.Free;
          {$IFEND} 
         {$ENDIF}
        end;
      end;
    finally
      if BIOCert <> nil then
        BIO_free(BIOCert);
    end;
  end;

  { Write the private key }
  BIOPrivateKey := BIO_new(BIO_s_mem);
  try
    if i2d_PrivateKey_bio(BIOPrivateKey, APrivateKey) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    Pending := bio_ctrl_pending(BIOPrivateKey);
    SetLength(DERPrivateKey, Pending);
    Read := BIO_read(BIOPrivateKey, {$IFNDEF FPC}DERPrivateKey{$ELSE}Pointer(DERPrivateKey){$ENDIF}, Pending);
    If Read > 0 Then
     Begin
      SetLength(DERPrivateKey, Read);
      {$IFNDEF FPC}
       {$IF CompilerVersion > 21}
        Base64 := TBase64Encoding.Create{$IFNDEF FPC}(64, #10){$ENDIF};
       {$IFEND}
      {$ENDIF}
      Try
       {$IFNDEF FPC}
        {$IF CompilerVersion > 21}
         FTempBytes  := TRESTDWBytes(TEncoding.ANSI.GetBytes('-----BEGIN RSA PRIVATE KEY-----' + #10 +
                                                              Base64.EncodeBytesToString(DERPrivateKey)
                                                             + #10 +
                                                             '-----END RSA PRIVATE KEY-----' + #10));
         APrivateKeyPEM := APrivateKeyPEM + FTempBytes;
        {$ELSE}
         FTempBytes  := StringToBytes('-----BEGIN RSA PRIVATE KEY-----' + #10 +
                                      EncodeStrings(BytesToString(DERPrivateKey))
                                      + #10 +
                                      '-----END RSA PRIVATE KEY-----' + #10);
         FTempBytesB := APrivateKeyPEM;
         SetLength(APrivateKeyPEM, Length(FTempBytesB) + Length(FTempBytes));
         Move(FTempBytesB[0], APrivateKeyPEM[0],                   Length(FTempBytesB));
         Move(FTempBytes[0],  APrivateKeyPEM[Length(FTempBytesB)], Length(FTempBytes));
        {$IFEND}
       {$ELSE}
        FTempBytes  := TRESTDWBytes(TEncoding.ANSI.GetBytes('-----BEGIN RSA PRIVATE KEY-----' + #10 +
                                                             EncodeStrings(BytesToString(DERPrivateKey), csUndefined)
                                                            + #10 +
                                                            '-----END RSA PRIVATE KEY-----' + #10));
        FTempBytesB := APrivateKeyPEM;
        SetLength(APrivateKeyPEM, Length(FTempBytesB) + Length(FTempBytes));
        Move(FTempBytesB[0], APrivateKeyPEM[0],                   Length(FTempBytesB));
        Move(FTempBytes[0],  APrivateKeyPEM[Length(FTempBytesB)], Length(FTempBytes));
       {$ENDIF}
      Finally
       {$IFNDEF FPC}
        {$IF CompilerVersion > 21}
         Base64.Free;
        {$IFEND}
       {$ENDIF}
      End;
     End;
    Result := True;
  finally
    if BIOPrivateKey <> nil then
      BIO_free(BIOPrivateKey);
  end;
end;

class function TRESTDWOpenSSLHelper.CreateCertRequest(const ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName: String;
  out ARSA: PRSA; out ACertRequest: PX509_REQ; out APrivateKey: PEVP_PKEY): Boolean;
var
  Bignum: PBIGNUM;
  Name: PX509_NAME;
begin
	APrivateKey := EVP_PKEY_new;
  if APrivateKey = nil then
    Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

  ACertRequest := X509_REQ_new;
  if ACertRequest = NIL then
    Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

  Bignum := BN_new;
  if Bignum = nil then
    Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
  try
    if BN_set_word(Bignum, RSA_F4) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    ARSA := RSA_new;
    if ARSA = nil then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    if RSA_generate_key_ex(ARSA, RSA_KEY_BITS, Bignum, nil) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Assign the RSA key pair to the private key }
    if EVP_PKEY_assign(APrivateKey, EVP_PKEY_RSA, ARSA) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Assign the public key for the request from the private key }
    if X509_REQ_set_pubkey(ACertRequest, APrivateKey) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Apply the name for the request }
    Name := X509_REQ_get_subject_name(ACertRequest);
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      X509_NAME_add_entry_by_txt(name, 'C',  MBSTRING_ASC, MarshaledAString(AnsiString(ACountry)),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'ST', MBSTRING_ASC, MarshaledAString(AnsiString(AState)),        -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'L',  MBSTRING_ASC, MarshaledAString(AnsiString(ALocality)),     -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'O',  MBSTRING_ASC, MarshaledAString(AnsiString(AOrganization)), -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'OU', MBSTRING_ASC, MarshaledAString(AnsiString(AOrgUnit)),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'CN', MBSTRING_ASC, MarshaledAString(AnsiString(ACommonName)),   -1, -1, 0);
     {$ELSE}
      X509_NAME_add_entry_by_txt(name, 'C',  MBSTRING_ASC, PAnsiChar(ACountry),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'ST', MBSTRING_ASC, PAnsiChar(AState),        -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'L',  MBSTRING_ASC, PAnsiChar(ALocality),     -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'O',  MBSTRING_ASC, PAnsiChar(AOrganization), -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'OU', MBSTRING_ASC, PAnsiChar(AOrgUnit),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'CN', MBSTRING_ASC, PAnsiChar(ACommonName),   -1, -1, 0);
     {$IFEND}
    {$ELSE}
     X509_NAME_add_entry_by_txt(name, 'C',  MBSTRING_ASC, MarshaledAString(AnsiString(ACountry)),      -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'ST', MBSTRING_ASC, MarshaledAString(AnsiString(AState)),        -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'L',  MBSTRING_ASC, MarshaledAString(AnsiString(ALocality)),     -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'O',  MBSTRING_ASC, MarshaledAString(AnsiString(AOrganization)), -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'OU', MBSTRING_ASC, MarshaledAString(AnsiString(AOrgUnit)),      -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'CN', MBSTRING_ASC, MarshaledAString(AnsiString(ACommonName)),   -1, -1, 0);
    {$ENDIF}
    { Self-sign with SHA1 the request using our new private key }
    if X509_REQ_sign(ACertRequest, APrivateKey, EVP_sha256) = 0 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
    Result := True;
  finally
    if Bignum <> nil then
      BN_free(Bignum);
  end;
end;

class function TRESTDWOpenSSLHelper.SetRandomSerial(const ACertificate: PX509): Boolean;
var
	Buffer: TRESTDWBytes;
	Bignum: PBIGNUM;
  Serial: PASN1_INTEGER;
begin
  { 20 byte random serial number }
  Buffer := TRESTDWOpenSSLHelper.RandomBytes(20);
  Buffer[0] := Buffer[0] AND $7F; // Positive value
  Bignum := BN_new;
  if Bignum = nil then
    Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

  try
    BN_bin2bn({$IFNDEF FPC}Buffer{$ELSE}Pointer(Buffer){$ENDIF}, Length(Buffer), Bignum);
    Serial := ASN1_INTEGER_new;
    if Serial = nil then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
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

class function TRESTDWOpenSSLHelper.CreateKeyPair_CA(const ACertificateCA: PX509; const APrivateKeyCA: PEVP_PKEY;
  const ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName: String;
  const AServerName: String; const AExpiresDays: Integer;
  out ARSA: PRSA; out ACertificate: PX509; out APrivateKey: PEVP_PKEY): Boolean;
var
	CertReq: PX509_REQ;
	CertReqPublicKey: PEVP_PKEY;
  Extension: PX509_EXTENSION;
  ServerName: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF};
  Name: PX509_NAME;
begin
	{ Create the certificate request and private key }
	if not CreateCertRequest(
    ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName,
    ARSA, CertReq, APrivateKey) then
    Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
  try
    { Create a self-signed certificate }
    ACertificate := X509_new;
    if ACertificate = nil then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Set version to X509v3 }
    if X509_set_version(ACertificate, 2) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Set random serial }
    if not SetRandomSerial(ACertificate) then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Set issuer to CA's subject }
    X509_set_issuer_name(ACertificate, X509_get_subject_name(ACertificateCA));

    { Set expiration of the certificate }
    X509_gmtime_adj(X509_get_notBefore(ACertificate), 0);
    X509_gmtime_adj(X509_get_notAfter(ACertificate), 60 * 60 * 24 * AExpiresDays);
    { Use the same subject as the public key for the certificate request }
    Name := X509_REQ_get_subject_name(CertReq);
    if Name = nil then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
    if X509_set_subject_name(ACertificate, Name) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
    CertReqPublicKey := X509_REQ_get_pubkey(CertReq);
    if CertReqPublicKey = nil then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
    try
      X509_set_pubkey(ACertificate, CertReqPublicKey);
    finally
      if CertReqPublicKey <> nil then
        EVP_PKEY_free(CertReqPublicKey);
    end;

    { Set the server name }
    if AServerName <> '' then
    begin
      ServerName := 'DNS:' + AnsiString(AServerName);
      {$IFNDEF FPC}
       {$IF CompilerVersion > 21}
        Extension := X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, MarshaledAString(ServerName));
       {$ELSE}
        Extension := X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, PWideChar(ServerName));
       {$IFEND}
      {$ELSE}
       Extension := X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, MarshaledAString(ServerName));
      {$ENDIF}

      if Extension = nil then
        Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
      try
        X509_add_ext(ACertificate, Extension, -1);
      finally
        X509_EXTENSION_free(Extension);
      end;
    end;

    { Sign our certificate with our CA }
    if X509_sign(ACertificate, APrivateKeyCA, EVP_sha256) = 0 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    Result := True;
  finally
    if CertReq <> nil then
    	X509_REQ_free(CertReq);
  end;
end;

class function TRESTDWOpenSSLHelper.CreateSelfSignedCert_X509(
  const ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName: String;
  const AServerName: String; const AExpiresDays: Integer;
  out ACertificate, APrivateKey: TRESTDWBytes): Boolean;
var
  Certificate: PX509;
  PrivateKey: PEVP_PKEY;
  Name: PX509_NAME;
  RSA: PRSA;
  Bignum: PBIGNUM;
  Extension: PX509_EXTENSION;
  ServerName: {$IFNDEF FPC}{$IF CompilerVersion > 21}RawByteString{$ELSE}AnsiString{$IFEND}{$ELSE}RawByteString{$ENDIF};
begin
  { Create a self-signed certificate }
  Certificate := X509_new;
  if Certificate = nil then
    Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
  try
    { Set version to X509v3 }
    if X509_set_version(Certificate, 2) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Set random serial }
    if not SetRandomSerial(Certificate) then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Set expiration of the certificate }
    X509_gmtime_adj(X509_get_notBefore(Certificate), 0);
    X509_gmtime_adj(X509_get_notAfter(Certificate), 60 * 60 * 24 * AExpiresDays);

    { Apply the name for the request }
    Name := X509_get_subject_name(Certificate);
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      X509_NAME_add_entry_by_txt(name, 'C',  MBSTRING_ASC, MarshaledAString(AnsiString(ACountry)),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'ST', MBSTRING_ASC, MarshaledAString(AnsiString(AState)),        -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'L',  MBSTRING_ASC, MarshaledAString(AnsiString(ALocality)),     -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'O',  MBSTRING_ASC, MarshaledAString(AnsiString(AOrganization)), -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'OU', MBSTRING_ASC, MarshaledAString(AnsiString(AOrgUnit)),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'CN', MBSTRING_ASC, MarshaledAString(AnsiString(ACommonName)),   -1, -1, 0);
     {$ELSE}
      X509_NAME_add_entry_by_txt(name, 'C',  MBSTRING_ASC, PAnsiChar(ACountry),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'ST', MBSTRING_ASC, PAnsiChar(AState),        -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'L',  MBSTRING_ASC, PAnsiChar(ALocality),     -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'O',  MBSTRING_ASC, PAnsiChar(AOrganization), -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'OU', MBSTRING_ASC, PAnsiChar(AOrgUnit),      -1, -1, 0);
      X509_NAME_add_entry_by_txt(name, 'CN', MBSTRING_ASC, PAnsiChar(ACommonName),   -1, -1, 0);
     {$IFEND}
    {$ELSE}
     X509_NAME_add_entry_by_txt(name, 'C',  MBSTRING_ASC, MarshaledAString(AnsiString(ACountry)),      -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'ST', MBSTRING_ASC, MarshaledAString(AnsiString(AState)),        -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'L',  MBSTRING_ASC, MarshaledAString(AnsiString(ALocality)),     -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'O',  MBSTRING_ASC, MarshaledAString(AnsiString(AOrganization)), -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'OU', MBSTRING_ASC, MarshaledAString(AnsiString(AOrgUnit)),      -1, -1, 0);
     X509_NAME_add_entry_by_txt(name, 'CN', MBSTRING_ASC, MarshaledAString(AnsiString(ACommonName)),   -1, -1, 0);
    {$ENDIF}
    { Set issuer to subject }
    if X509_set_issuer_name(Certificate, Name) <> 1 then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

    { Set the server name }
    if AServerName <> '' then
    begin
      ServerName := 'DNS:' + AnsiString(AServerName);
      {$IFNDEF FPC}
       {$IF CompilerVersion > 21}
        Extension := X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, MarshaledAString(ServerName));
       {$ELSE}
        Extension := X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, PWideChar(ServerName));
       {$IFEND}
      {$ELSE}
       Extension := X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, MarshaledAString(ServerName));
      {$ENDIF}
      if Extension = nil then
        Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
      try
        X509_add_ext(Certificate, Extension, -1);
      finally
        X509_EXTENSION_free(Extension);
      end;
    end;

    Bignum := BN_new;
    if Bignum = nil then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
    try
      if BN_set_word(Bignum, RSA_F4) <> 1 then
        Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

      RSA := RSA_new;
      try
        if RSA_generate_key_ex(RSA, RSA_KEY_BITS, Bignum, nil) <> 1 then
          Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

        PrivateKey := EVP_PKEY_new;
        if PrivateKey = nil then
          Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
        try
          { Assign the RSA key pair to the private key }
          if EVP_PKEY_assign(PrivateKey, EVP_PKEY_RSA, RSA) <> 1 then
            Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

          { Assign the public key from the private key }
          if X509_set_pubkey(Certificate, PrivateKey) <> 1 then
            Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

          { Sign with SHA-1 }
          if X509_sign(Certificate, PrivateKey, EVP_sha1) = 0 then
            Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

          { Convert the DER certificate to PEM }
          if not CertToPEM([Certificate], PrivateKey, ACertificate, APrivateKey) then
            Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

          { Owned by another object at this point, so do not free them directly }
          Certificate := nil;
          PrivateKey := nil;

          Result := True;
        finally
          if PrivateKey <> nil then
            EVP_PKEY_free(PrivateKey);
        end;
      finally
        if RSA <> nil then
          RSA_free(RSA);
      end;
    finally
      BN_free(Bignum);
    end;
  finally
    if Certificate <> nil then
      X509_free(Certificate);
  end;
end;

class function TRESTDWOpenSSLHelper.CreateSelfSignedCert_X509CA(const ACertificateCA, APrivateKeyCA: TRESTDWBytes; const APassword: String;
  const ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName: String;
  const AServerName: String; const AExpiresDays: Integer;
  out ACertificate, APrivateKey: TRESTDWBytes): Boolean;
var
  BIOCertCA, BIOPrivateKeyCA: PBIO;
  CertificateCA: PX509;
  PrivateKeyCA: PEVP_PKEY;
  Password: AnsiString;
  Certificate: PX509;
  PrivateKey: PEVP_PKEY;
  RSA: PRSA;
begin
  { Load the CA certificate and private key }
	BIOCertCA := BIO_new_mem_buf(@ACertificateCA[0], Length(ACertificateCA));
	BIOPrivateKeyCA := BIO_new_mem_buf(@APrivateKeyCA[0], Length(APrivateKeyCA));
  try
    CertificateCA := PEM_read_bio_X509(BIOCertCA, nil, nil, nil);
    if not Assigned(CertificateCA) then
      Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
    try
      if APassword <> '' then
      begin
        {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
          Password := MarshaledAString(AnsiString(APassword));
         {$ELSE}
          Password := AnsiString(APassword);
         {$IFEND}
        {$ELSE}
         Password := MarshaledAString(AnsiString(APassword));
        {$ENDIF}

        PrivateKeyCA := PEM_read_bio_PrivateKey(BIOPrivateKeyCA, nil, nil, @Password[1]);
      end
      else
        PrivateKeyCA := PEM_read_bio_PrivateKey(BIOPrivateKeyCA, nil, nil, nil);
      if not Assigned(PrivateKeyCA) then
        Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
      try
        if not CreateKeyPair_CA(CertificateCA, PrivateKeyCA,
          ACountry, AState, ALocality, AOrganization, AOrgUnit, ACommonName,
          AServerName, AExpiresDays,
          RSA, Certificate, PrivateKey) then
          Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};
        try
          { Convert the DER certificate to PEM }
          if not CertToPEM([Certificate], PrivateKey, ACertificate, APrivateKey) then
            Exit{$IFNDEF FPC}{$IF CompilerVersion > 21}(False){$IFEND}{$ELSE}(False){$ENDIF};

          { Owned by another object at this point, so do not free them directly }
          Certificate := nil;
          PrivateKey := nil;

          Result := True;
        finally
          if Certificate <> nil then
	          X509_free(Certificate);
          if PrivateKey <> nil then
	          EVP_PKEY_free(PrivateKey);
          if RSA <> nil then
            RSA_free(RSA);
        end;
      finally
        if PrivateKeyCA <> nil then
	        EVP_PKEY_free(PrivateKeyCA);
      end;
    finally
      if CertificateCA <> nil then
	      X509_free(CertificateCA);
    end;
  finally
    if BIOCertCA <> nil then
      BIO_free(BIOCertCA);
    if BIOPrivateKeyCA <> nil then
      BIO_free(BIOPrivateKeyCA);
  end;
end;

end.
