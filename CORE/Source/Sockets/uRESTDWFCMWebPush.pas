Unit uRESTDWFCMWebPush;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMTypes,
  uRESTDWFCMCompat;

Type
  TRESTDWWebPush = Class
  Private
    Class Procedure GenerateP256Keys(Out APublicKey,
                                         APrivateKey : String);
    Class Procedure GenerateAuthSecret(Out ASecret : String);
  Public
    Class Procedure Prepare(Const AConfig : TRESTDWFCMConfig;
                            Var ACredentials : TRESTDWFCMCredentials);
  End;

Implementation

Uses
  uRESTDWOpenSslLib;

Class Procedure TRESTDWWebPush.GenerateAuthSecret(Out ASecret : String);
Var
  LSecret : TRESTDWFCMBytes;
Begin
  SetLength(LSecret, 16);
  If RAND_bytes(@LSecret[0], Length(LSecret)) <> 1 Then
    Raise Exception.Create('FCM WebPush: RAND_bytes falhou');
  ASecret := RESTDWFCMBase64URL(LSecret);
End;

Class Procedure TRESTDWWebPush.GenerateP256Keys(Out APublicKey,
                                                    APrivateKey : String);
Var
  LKey       : PEC_KEY;
  LPrivateBN : PBIGNUM;
  LPublic    : TRESTDWFCMBytes;
  LPrivate   : TRESTDWFCMBytes;
  LPtr       : PByte;
  LSize      : Integer;
Begin
  APublicKey := '';
  APrivateKey := '';

  LKey := EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
  If LKey = Nil Then
    Raise Exception.Create('FCM WebPush: EC_KEY_new_by_curve_name falhou');
  Try
    If EC_KEY_generate_key(LKey) <> 1 Then
      Raise Exception.Create('FCM WebPush: EC_KEY_generate_key falhou');

    LSize := i2o_ECPublicKey(LKey, Nil);
    If LSize <= 0 Then
      Raise Exception.Create('FCM WebPush: tamanho da chave publica invalido');
    SetLength(LPublic, LSize);
    LPtr := @LPublic[0];
    If i2o_ECPublicKey(LKey, @LPtr) <> LSize Then
      Raise Exception.Create('FCM WebPush: export da chave publica falhou');

    LPrivateBN := EC_KEY_get0_private_key(LKey);
    If LPrivateBN = Nil Then
      Raise Exception.Create('FCM WebPush: chave privada ausente');
    SetLength(LPrivate, 32);
    FillChar(LPrivate[0], Length(LPrivate), 0);
    LSize := (BN_num_bits(LPrivateBN) + 7) Div 8;

    If LSize > 32 Then
      Raise Exception.Create('FCM WebPush: chave privada P-256 invalida');

    If LSize > 0 Then
      BN_bn2bin(LPrivateBN, @LPrivate[32 - LSize]);

    APublicKey := RESTDWFCMBase64URL(LPublic);
    APrivateKey := RESTDWFCMBase64URL(LPrivate);
  Finally
    EC_KEY_free(LKey);
  End;
End;

Class Procedure TRESTDWWebPush.Prepare(Const AConfig : TRESTDWFCMConfig;
                                       Var ACredentials : TRESTDWFCMCredentials);
Var
  LPublic,
  LPrivate,
  LAuth : TRESTDWFCMBytes;
  LValid : Boolean;
Begin
  LValid := False;

  If (ACredentials.PushPublicKey <> '') And
     (ACredentials.PushPrivateKey <> '') And
     (ACredentials.PushAuth <> '') Then
  Begin
    Try
      LPublic :=
        RESTDWFCMBase64URLDecode(
          ACredentials.PushPublicKey
        );

      LPrivate :=
        RESTDWFCMBase64URLDecode(
          ACredentials.PushPrivateKey
        );

      LAuth :=
        RESTDWFCMBase64URLDecode(
          ACredentials.PushAuth
        );

      LValid :=
        (Length(LPublic) = 65) And
        (LPublic[0] = $04) And
        (Length(LPrivate) = 32) And
        (Length(LAuth) = 16);
    Except
      LValid := False;
    End;
  End;

  If LValid Then
    Exit;

  ACredentials.PushPublicKey := '';
  ACredentials.PushPrivateKey := '';
  ACredentials.PushAuth := '';

  GenerateP256Keys(
    ACredentials.PushPublicKey,
    ACredentials.PushPrivateKey
  );

  GenerateAuthSecret(
    ACredentials.PushAuth
  );
End;

End.
