Unit uRESTDWFCMCrypto;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMCompat;

Type
  TRESTDWWebPushCrypto = Class
  Private
    Class Function HMACSHA256(Const AKey,
                                    AData : TRESTDWFCMBytes) : TRESTDWFCMBytes;
    Class Function HKDF(Const AIKM,
                              ASalt,
                              AInfo : TRESTDWFCMBytes;
                        ALength : Integer) : TRESTDWFCMBytes;
    Class Function ECDHSecret(Const APrivateRaw,
                                    APeerPublicRaw : TRESTDWFCMBytes) : TRESTDWFCMBytes;
    Class Function AESGCMDecrypt(Const AKey,
                                      ANonce,
                                      ACipherAndTag : TRESTDWFCMBytes) : TRESTDWFCMBytes;
    Class Function Concat(Const A,
                                B : TRESTDWFCMBytes) : TRESTDWFCMBytes; Overload;
    Class Function Concat(Const A,
                                B,
                                C : TRESTDWFCMBytes) : TRESTDWFCMBytes; Overload;
    Class Function BytesOf(Const S : AnsiString) : TRESTDWFCMBytes;
    Class Function BuildContext(Const AReceiverPublic,
                                      ASenderPublic : TRESTDWFCMBytes) : TRESTDWFCMBytes;
    Class Function ParseHeaderParam(Const AHeader,
                                          AName : String) : String;
    Class Function ParseRecordSize(Const AEncryptionHeader : String) : Integer;
    Class Function NonceForCounter(Const ABaseNonce : TRESTDWFCMBytes;
                                   ACounter : TRESTDWFCMUInt64) : TRESTDWFCMBytes;
  Public
    Class Function DecryptAESGCM(Const APrivateKeyB64,
                                      APublicKeyB64,
                                      AAuthB64,
                                      ACryptoKeyHeader,
                                      AEncryptionHeader : String;
                                Const ARawData : TRESTDWFCMBytes) : TRESTDWFCMBytes;
  End;

Implementation

Uses
  uRESTDWOpenSslLib;

Class Function TRESTDWWebPushCrypto.BytesOf(Const S : AnsiString) : TRESTDWFCMBytes;
Begin
  SetLength(Result, Length(S));
  If Length(S) > 0 Then
    Move(S[1], Result[0], Length(S));
End;

Class Function TRESTDWWebPushCrypto.Concat(Const A,
                                                 B : TRESTDWFCMBytes) : TRESTDWFCMBytes;
Begin
  SetLength(Result, Length(A) + Length(B));
  If Length(A) > 0 Then
    Move(A[0], Result[0], Length(A));
  If Length(B) > 0 Then
    Move(B[0], Result[Length(A)], Length(B));
End;

Class Function TRESTDWWebPushCrypto.Concat(Const A,
                                                 B,
                                                 C : TRESTDWFCMBytes) : TRESTDWFCMBytes;
Begin
  Result := Concat(Concat(A, B), C);
End;

Class Function TRESTDWWebPushCrypto.HMACSHA256(Const AKey,
                                                     AData : TRESTDWFCMBytes) : TRESTDWFCMBytes;
Var
  LSize : Cardinal;
  LKeyPtr,
  LDataPtr : Pointer;
Begin
  SetLength(Result, 32);
  LSize := 0;
  If Length(AKey) > 0 Then
    LKeyPtr := @AKey[0]
  Else
    LKeyPtr := Nil;
  If Length(AData) > 0 Then
    LDataPtr := @AData[0]
  Else
    LDataPtr := Nil;
  If HMAC(EVP_sha256, LKeyPtr, Length(AKey), PByte(LDataPtr), Length(AData),
          @Result[0], LSize) = Nil Then
    Raise Exception.Create('FCM HMAC-SHA256 falhou');
  SetLength(Result, LSize);
End;

Class Function TRESTDWWebPushCrypto.HKDF(Const AIKM,
                                               ASalt,
                                               AInfo : TRESTDWFCMBytes;
                                         ALength : Integer) : TRESTDWFCMBytes;
Var
  LPRK,
  LT,
  LInput : TRESTDWFCMBytes;
Begin
  If ALength <= 0 Then
  Begin
    SetLength(Result, 0);
    Exit;
  End;
  If ALength > 32 Then
    Raise Exception.Create('FCM HKDF: comprimento acima de 32 nao suportado');

  LPRK := HMACSHA256(ASalt, AIKM);
  SetLength(LInput, Length(AInfo) + 1);
  If Length(AInfo) > 0 Then
    Move(AInfo[0], LInput[0], Length(AInfo));
  LInput[High(LInput)] := 1;
  LT := HMACSHA256(LPRK, LInput);
  SetLength(Result, ALength);
  Move(LT[0], Result[0], ALength);
End;

Class Function TRESTDWWebPushCrypto.ECDHSecret(Const APrivateRaw,
                                                     APeerPublicRaw : TRESTDWFCMBytes) : TRESTDWFCMBytes;
Var
  LKey       : PEC_KEY;
  LGroup     : PEC_GROUP;
  LPrivateBN : PBIGNUM;
  LOwnPublic,
  LPeerPoint : PEC_POINT;
  LSize      : Integer;
Begin
  If Length(APrivateRaw) <> 32 Then
    Raise Exception.Create('FCM ECDH: chave privada P-256 invalida');
  If (Length(APeerPublicRaw) <> 65) Or (APeerPublicRaw[0] <> $04) Then
    Raise Exception.Create('FCM ECDH: chave publica remota invalida');

  LKey := EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
  If LKey = Nil Then
    Raise Exception.Create('FCM ECDH: EC_KEY_new_by_curve_name falhou');
  Try
    LGroup := EC_KEY_get0_group(LKey);
    LPrivateBN := BN_bin2bn(@APrivateRaw[0], Length(APrivateRaw), Nil);
    If LPrivateBN = Nil Then
      Raise Exception.Create('FCM ECDH: BN_bin2bn falhou');
    Try
      If EC_KEY_set_private_key(LKey, LPrivateBN) <> 1 Then
        Raise Exception.Create('FCM ECDH: set private falhou');

      LOwnPublic := EC_POINT_new(LGroup);
      If LOwnPublic = Nil Then
        Raise Exception.Create('FCM ECDH: EC_POINT_new falhou');
      Try
        If EC_POINT_mul(LGroup, LOwnPublic, LPrivateBN, Nil, Nil, Nil) <> 1 Then
          Raise Exception.Create('FCM ECDH: public point falhou');
        If EC_KEY_set_public_key(LKey, LOwnPublic) <> 1 Then
          Raise Exception.Create('FCM ECDH: set public falhou');
      Finally
        EC_POINT_free(LOwnPublic);
      End;

      LPeerPoint := EC_POINT_new(LGroup);
      If LPeerPoint = Nil Then
        Raise Exception.Create('FCM ECDH: peer point falhou');
      Try
        If EC_POINT_oct2point(LGroup, LPeerPoint, @APeerPublicRaw[0],
                             Length(APeerPublicRaw), Nil) <> 1 Then
          Raise Exception.Create('FCM ECDH: chave publica remota invalida');
        SetLength(Result, 32);
        LSize := ECDH_compute_key(@Result[0], Length(Result), LPeerPoint, LKey, Nil);
        If LSize <= 0 Then
          Raise Exception.Create('FCM ECDH_compute_key falhou');
        SetLength(Result, LSize);
      Finally
        EC_POINT_free(LPeerPoint);
      End;
    Finally
      BN_free(LPrivateBN);
    End;
  Finally
    EC_KEY_free(LKey);
  End;
End;

Class Function TRESTDWWebPushCrypto.AESGCMDecrypt(Const AKey,
                                                       ANonce,
                                                       ACipherAndTag : TRESTDWFCMBytes) : TRESTDWFCMBytes;
Var
  LCtx : PEVP_CIPHER_CTX;
  LCipher,
  LTag : TRESTDWFCMBytes;
  LLen,
  LFinal,
  LOut : Integer;
Begin
  If Length(ACipherAndTag) < 16 Then
    Raise Exception.Create('FCM AES-GCM: ciphertext curto');
  SetLength(LCipher, Length(ACipherAndTag) - 16);
  SetLength(LTag, 16);
  If Length(LCipher) > 0 Then
    Move(ACipherAndTag[0], LCipher[0], Length(LCipher));
  Move(ACipherAndTag[Length(LCipher)], LTag[0], 16);

  LCtx := EVP_CIPHER_CTX_new;
  If LCtx = Nil Then
    Raise Exception.Create('FCM AES-GCM: contexto invalido');
  Try
    If EVP_DecryptInit_ex(LCtx, EVP_aes_128_gcm, Nil, Nil, Nil) <> 1 Then
      Raise Exception.Create('FCM AES-GCM: init falhou');
    If EVP_CIPHER_CTX_ctrl(LCtx, EVP_CTRL_GCM_SET_IVLEN, Length(ANonce), Nil) <> 1 Then
      Raise Exception.Create('FCM AES-GCM: nonce invalido');
    If EVP_DecryptInit_ex(LCtx, Nil, Nil, @AKey[0], @ANonce[0]) <> 1 Then
      Raise Exception.Create('FCM AES-GCM: key init falhou');

    SetLength(Result, Length(LCipher) + 16);
    LOut := 0;
    If Length(LCipher) > 0 Then
    Begin
      LLen := 0;
      If EVP_DecryptUpdate(LCtx, @Result[0], @LLen, @LCipher[0], Length(LCipher)) <> 1 Then
        Raise Exception.Create('FCM AES-GCM: decrypt falhou');
      LOut := LLen;
    End;

    If EVP_CIPHER_CTX_ctrl(LCtx, EVP_CTRL_GCM_SET_TAG, Length(LTag), @LTag[0]) <> 1 Then
      Raise Exception.Create('FCM AES-GCM: tag invalida');
    LFinal := 0;
    If EVP_DecryptFinal_ex(LCtx, @Result[LOut], @LFinal) <> 1 Then
      Raise Exception.Create('FCM AES-GCM: autenticacao falhou');
    Inc(LOut, LFinal);
    SetLength(Result, LOut);
  Finally
    EVP_CIPHER_CTX_free(LCtx);
  End;
End;

Class Function TRESTDWWebPushCrypto.BuildContext(Const AReceiverPublic,
                                                       ASenderPublic : TRESTDWFCMBytes) : TRESTDWFCMBytes;
Var
  LPrefix : TRESTDWFCMBytes;
  P       : Integer;
  L       : Word;
Begin
  LPrefix := BytesOf('P-256'#0);
  SetLength(Result, Length(LPrefix) + 2 + Length(AReceiverPublic) + 2 + Length(ASenderPublic));
  P := 0;
  If Length(LPrefix) > 0 Then
  Begin
    Move(LPrefix[0], Result[P], Length(LPrefix));
    Inc(P, Length(LPrefix));
  End;
  L := Length(AReceiverPublic);
  Result[P] := Byte(L Shr 8);
  Result[P + 1] := Byte(L);
  Inc(P, 2);
  Move(AReceiverPublic[0], Result[P], Length(AReceiverPublic));
  Inc(P, Length(AReceiverPublic));
  L := Length(ASenderPublic);
  Result[P] := Byte(L Shr 8);
  Result[P + 1] := Byte(L);
  Inc(P, 2);
  Move(ASenderPublic[0], Result[P], Length(ASenderPublic));
End;

Class Function TRESTDWWebPushCrypto.ParseHeaderParam(Const AHeader,
                                                           AName : String) : String;
Var
  S,
  LPart,
  LName : String;
  P,
  LSep,
  LSemi,
  LComma : Integer;
Begin
  Result := '';
  LName := LowerCase(AName) + '=';
  S := AHeader;
  While S <> '' Do
  Begin
    LSemi := Pos(';', S);
    LComma := Pos(',', S);
    If (LSemi > 0) And (LComma > 0) Then
    Begin
      If LSemi < LComma Then
        LSep := LSemi
      Else
        LSep := LComma;
    End
    Else
    If LSemi > 0 Then
      LSep := LSemi
    Else
      LSep := LComma;

    If LSep > 0 Then
    Begin
      LPart := Trim(Copy(S, 1, LSep - 1));
      Delete(S, 1, LSep);
    End
    Else
    Begin
      LPart := Trim(S);
      S := '';
    End;

    P := Pos(LName, LowerCase(LPart));
    If P = 1 Then
    Begin
      Result := Copy(LPart, Length(LName) + 1, MaxInt);
      Exit;
    End;
  End;
End;

Class Function TRESTDWWebPushCrypto.ParseRecordSize(Const AEncryptionHeader : String) : Integer;
Var
  S : String;
Begin
  S := ParseHeaderParam(AEncryptionHeader, 'rs');
  If S = '' Then
    Result := 4096
  Else
    Result := StrToIntDef(S, 4096);
  If Result < 3 Then
    Result := 4096;
End;

Class Function TRESTDWWebPushCrypto.NonceForCounter(Const ABaseNonce : TRESTDWFCMBytes;
                                                    ACounter : TRESTDWFCMUInt64) : TRESTDWFCMBytes;
Var
  I : Integer;
Begin
  Result := Copy(ABaseNonce, 0, Length(ABaseNonce));
  If Length(Result) <> 12 Then
    Raise Exception.Create('FCM nonce base invalido');
  For I := 0 To 7 Do
    Result[11 - I] := Result[11 - I] Xor Byte(ACounter Shr (I * 8));
End;

Class Function TRESTDWWebPushCrypto.DecryptAESGCM(Const APrivateKeyB64,
                                                        APublicKeyB64,
                                                        AAuthB64,
                                                        ACryptoKeyHeader,
                                                        AEncryptionHeader : String;
                                                  Const ARawData : TRESTDWFCMBytes) : TRESTDWFCMBytes;
Var
  LSenderKey,
  LSaltText : String;
  LPrivate,
  LReceiverPublic,
  LSenderPublic,
  LAuth,
  LSalt,
  LShared,
  LContext,
  LAuthInfo,
  LSecret,
  LKeyInfo,
  LNonceInfo,
  LKey,
  LNonce,
  LEncrypted,
  LPlain,
  LOne : TRESTDWFCMBytes;
  LChunk,
  LRecordSize,
  LPosition,
  LTake,
  LPadding,
  I : Integer;
  LCounter : TRESTDWFCMUInt64;
Begin
  LSenderKey := ParseHeaderParam(ACryptoKeyHeader, 'dh');
  LSaltText := ParseHeaderParam(AEncryptionHeader, 'salt');
  If LSenderKey = '' Then
    Raise Exception.Create('FCM crypto-key/dh ausente');
  If LSaltText = '' Then
    Raise Exception.Create('FCM encryption/salt ausente');

  LPrivate := RESTDWFCMBase64URLDecode(APrivateKeyB64);
  LReceiverPublic := RESTDWFCMBase64URLDecode(APublicKeyB64);
  LSenderPublic := RESTDWFCMBase64URLDecode(LSenderKey);
  LAuth := RESTDWFCMBase64URLDecode(AAuthB64);
  LSalt := RESTDWFCMBase64URLDecode(LSaltText);
  If Length(LSalt) <> 16 Then
    Raise Exception.Create('FCM salt invalido');

  LShared := ECDHSecret(LPrivate, LSenderPublic);
  LContext := BuildContext(LReceiverPublic, LSenderPublic);
  LAuthInfo := BytesOf('Content-Encoding: auth'#0);
  LSecret := HKDF(LShared, LAuth, LAuthInfo, 32);
  LKeyInfo := Concat(BytesOf('Content-Encoding: aesgcm'#0), LContext);
  LNonceInfo := Concat(BytesOf('Content-Encoding: nonce'#0), LContext);
  LKey := HKDF(LSecret, LSalt, LKeyInfo, 16);
  LNonce := HKDF(LSecret, LSalt, LNonceInfo, 12);

  LRecordSize := ParseRecordSize(AEncryptionHeader);
  LChunk := LRecordSize + 16;
  LPosition := 0;
  LCounter := 0;
  SetLength(Result, 0);

  While LPosition < Length(ARawData) Do
  Begin
    LTake := LChunk;
    If LPosition + LTake > Length(ARawData) Then
      LTake := Length(ARawData) - LPosition;
    SetLength(LEncrypted, LTake);
    Move(ARawData[LPosition], LEncrypted[0], LTake);
    LPlain := AESGCMDecrypt(LKey, NonceForCounter(LNonce, LCounter), LEncrypted);
    If Length(LPlain) < 2 Then
      Raise Exception.Create('FCM payload sem padding');
    LPadding := (Integer(LPlain[0]) Shl 8) Or Integer(LPlain[1]);
    If 2 + LPadding > Length(LPlain) Then
      Raise Exception.Create('FCM padding invalido');
    For I := 0 To LPadding - 1 Do
      If LPlain[2 + I] <> 0 Then
        Raise Exception.Create('FCM padding nao-zero');
    SetLength(LOne, Length(LPlain) - 2 - LPadding);
    If Length(LOne) > 0 Then
      Move(LPlain[2 + LPadding], LOne[0], Length(LOne));
    Result := Concat(Result, LOne);
    Inc(LPosition, LTake);
    Inc(LCounter);
  End;
End;

End.
