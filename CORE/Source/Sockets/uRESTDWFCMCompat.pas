Unit uRESTDWFCMCompat;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  {$IFDEF RESTDWWINDOWS}
  Windows,
  {$ELSE}
    {$IFDEF FPC}
    DateUtils,
    {$ELSE}
      {$IFDEF DELPHI2010UP}
      DateUtils,
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
  uRESTDWProtoTypes,
  uRESTDWTools;

Type
  TRESTDWFCMBytes = TRESTDWBytes;
  TRESTDWFCMUInt64 = TRESTDWUInt64;

  TRESTDWFCMBytesStream = Class(TMemoryStream)
  Public
    Constructor Create(Const AData : TRESTDWFCMBytes);
  End;

  TRESTDWFCMUTF8Stream = Class(TMemoryStream)
  Public
    Constructor Create(Const AValue : String);
    Function AsString : String;
  End;

Function RESTDWFCMBytesToString(Const AData : TRESTDWFCMBytes) : String;
Function RESTDWFCMStringToBytes(Const AValue : String) : TRESTDWFCMBytes;

Function RESTDWFCMBase64URL(Const AData : TRESTDWFCMBytes) : String;
Function RESTDWFCMBase64URLDecode(Const AValue : String) : TRESTDWFCMBytes;

Function RESTDWFCMJSONValue(Const AJSON,
                                  AName : String) : String;

Function RESTDWFCMURLEncode(Const AValue : String) : String;

Function RESTDWFCMUIntToStr(AValue : TRESTDWFCMUInt64) : String;

Function RESTDWFCMStrToUInt64Def(Const AValue : String;
                                 ADefault      : TRESTDWFCMUInt64) : TRESTDWFCMUInt64;

Function RESTDWFCMUnixNow : Int64;

Function RESTDWFCMPtrOffset(APointer : Pointer;
                            AOffset  : Integer) : Pointer;
Procedure RESTDWFCMWriteUTF8(AStream : TStream;
                             Const AValue : String);
Procedure RESTDWFCMSleep(AMilliseconds : Cardinal);

Implementation

Constructor TRESTDWFCMUTF8Stream.Create(Const AValue : String);
Var
  LUTF8 : UTF8String;
Begin
  Inherited Create;

  LUTF8 := UTF8Encode(AValue);

  If Length(LUTF8) > 0 Then
    WriteBuffer(
      LUTF8[1],
      Length(LUTF8)
    );

  Position := 0;
End;

Function TRESTDWFCMUTF8Stream.AsString : String;
Var
  LUTF8 : UTF8String;
Begin
  SetLength(LUTF8, Size);

  Position := 0;

  If Size > 0 Then
    ReadBuffer(
      LUTF8[1],
      Size
    );

  {$IFDEF DELPHI2009UP}
  Result := UTF8ToString(LUTF8);
  {$ELSE}
    {$IFDEF FPC}
    Result := UTF8ToString(LUTF8);
    {$ELSE}
    Result := String(UTF8Decode(LUTF8));
    {$ENDIF}
  {$ENDIF}

  Position := 0;
End;

Constructor TRESTDWFCMBytesStream.Create(Const AData : TRESTDWFCMBytes);
Begin
  Inherited Create;

  If Length(AData) > 0 Then
    WriteBuffer(
      AData[0],
      Length(AData)
    );

  Position := 0;
End;

Function RESTDWFCMBytesToString(Const AData : TRESTDWFCMBytes) : String;
Var
  I     : Integer;
  LUTF8 : UTF8String;
Begin
  SetLength(LUTF8, Length(AData));

  For I := 0 To Length(AData) - 1 Do
    LUTF8[I + 1] := AnsiChar(AData[I]);

  {$IFDEF DELPHI2009UP}
  Result := UTF8ToString(LUTF8);
  {$ELSE}
    {$IFDEF FPC}
    Result := UTF8ToString(LUTF8);
    {$ELSE}
    Result := String(UTF8Decode(LUTF8));
    {$ENDIF}
  {$ENDIF}
End;

Function RESTDWFCMStringToBytes(Const AValue : String) : TRESTDWFCMBytes;
Var
  I     : Integer;
  LUTF8 : UTF8String;
Begin
  {$IFDEF DELPHI2009UP}
  LUTF8 := UTF8Encode(AValue);
  {$ELSE}
    {$IFDEF FPC}
    LUTF8 := UTF8Encode(AValue);
    {$ELSE}
    LUTF8 := UTF8Encode(WideString(AValue));
    {$ENDIF}
  {$ENDIF}

  SetLength(Result, Length(LUTF8));

  For I := 1 To Length(LUTF8) Do
    Result[I - 1] := Byte(LUTF8[I]);
End;

Function RESTDWFCMBase64URL(Const AData : TRESTDWFCMBytes) : String;
Const
  CTable : String =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
Var
  I,
  LRemaining : Integer;
  B0,
  B1,
  B2 : Byte;
Begin
  Result := '';
  I := 0;

  While I < Length(AData) Do
  Begin
    LRemaining := Length(AData) - I;

    B0 := AData[I];

    If LRemaining > 1 Then
      B1 := AData[I + 1]
    Else
      B1 := 0;

    If LRemaining > 2 Then
      B2 := AData[I + 2]
    Else
      B2 := 0;

    Result :=
      Result +
      CTable[(B0 Shr 2) + 1] +
      CTable[(((B0 And $03) Shl 4) Or (B1 Shr 4)) + 1];

    If LRemaining > 1 Then
      Result :=
        Result +
        CTable[(((B1 And $0F) Shl 2) Or (B2 Shr 6)) + 1];

    If LRemaining > 2 Then
      Result :=
        Result +
        CTable[(B2 And $3F) + 1];

    Inc(I, 3);
  End;
End;

Function RESTDWFCMBase64URLDecode(Const AValue : String) : TRESTDWFCMBytes;

  Function DecodeChar(AChar : Char) : Integer;
  Begin
    If (AChar >= 'A') And (AChar <= 'Z') Then
      Result := Ord(AChar) - Ord('A')
    Else
    If (AChar >= 'a') And (AChar <= 'z') Then
      Result := Ord(AChar) - Ord('a') + 26
    Else
    If (AChar >= '0') And (AChar <= '9') Then
      Result := Ord(AChar) - Ord('0') + 52
    Else
    If (AChar = '-') Or (AChar = '+') Then
      Result := 62
    Else
    If (AChar = '_') Or (AChar = '/') Then
      Result := 63
    Else
      Result := -1;
  End;

Var
  S : String;
  I,
  LOut,
  LCount,
  V0,
  V1,
  V2,
  V3 : Integer;
Begin
  S := Trim(AValue);

  While (Length(S) > 0) And
        (S[Length(S)] = '=') Do
    Delete(S, Length(S), 1);

  If (Length(S) Mod 4) = 1 Then
    Raise Exception.Create('FCM Base64URL invalido');

  SetLength(Result, ((Length(S) * 3) Div 4) + 3);

  I := 1;
  LOut := 0;

  While I <= Length(S) Do
  Begin
    LCount := Length(S) - I + 1;

    V0 := DecodeChar(S[I]);

    If LCount > 1 Then
      V1 := DecodeChar(S[I + 1])
    Else
      V1 := -1;

    If LCount > 2 Then
      V2 := DecodeChar(S[I + 2])
    Else
      V2 := -1;

    If LCount > 3 Then
      V3 := DecodeChar(S[I + 3])
    Else
      V3 := -1;

    If (V0 < 0) Or (V1 < 0) Then
      Raise Exception.Create('FCM Base64URL invalido');

    Result[LOut] := Byte((V0 Shl 2) Or (V1 Shr 4));
    Inc(LOut);

    If LCount > 2 Then
    Begin
      If V2 < 0 Then
        Raise Exception.Create('FCM Base64URL invalido');

      Result[LOut] :=
        Byte(
          ((V1 And $0F) Shl 4) Or
          (V2 Shr 2)
        );
      Inc(LOut);
    End;

    If LCount > 3 Then
    Begin
      If V3 < 0 Then
        Raise Exception.Create('FCM Base64URL invalido');

      Result[LOut] :=
        Byte(
          ((V2 And $03) Shl 6) Or
          V3
        );
      Inc(LOut);
    End;

    Inc(I, 4);
  End;

  SetLength(Result, LOut);
End;

Function RESTDWFCMJSONValue(Const AJSON,
                                  AName : String) : String;
Var
  I,
  LStart,
  LNameStart : Integer;
  LKey : String;
  LEscaped : Boolean;
Begin
  Result := '';
  I := 1;

  While I <= Length(AJSON) Do
  Begin
    If AJSON[I] <> '"' Then
    Begin
      Inc(I);
      Continue;
    End;

    Inc(I);
    LNameStart := I;
    LEscaped := False;

    While I <= Length(AJSON) Do
    Begin
      If AJSON[I] = '\' Then
      Begin
        LEscaped := Not LEscaped;
        Inc(I);
        Continue;
      End;

      If (AJSON[I] = '"') And
         Not LEscaped Then
        Break;

      LEscaped := False;
      Inc(I);
    End;

    If I > Length(AJSON) Then
      Exit;

    LKey := Copy(AJSON, LNameStart, I - LNameStart);
    Inc(I);

    While (I <= Length(AJSON)) And
          (AJSON[I] <= ' ') Do
      Inc(I);

    If (I > Length(AJSON)) Or
       (AJSON[I] <> ':') Then
      Continue;

    Inc(I);

    While (I <= Length(AJSON)) And
          (AJSON[I] <= ' ') Do
      Inc(I);

    If Not SameText(LKey, AName) Then
      Continue;

    If I > Length(AJSON) Then
      Exit;

    If AJSON[I] = '"' Then
    Begin
      Inc(I);
      LStart := I;
      LEscaped := False;

      While I <= Length(AJSON) Do
      Begin
        If AJSON[I] = '\' Then
        Begin
          LEscaped := Not LEscaped;
          Inc(I);
          Continue;
        End;

        If (AJSON[I] = '"') And
           Not LEscaped Then
          Break;

        LEscaped := False;
        Inc(I);
      End;

      Result := Copy(AJSON, LStart, I - LStart);
      Exit;
    End;

    LStart := I;

    While (I <= Length(AJSON)) And
          (AJSON[I] <> ',') And
          (AJSON[I] <> '}') And
          (AJSON[I] <> ']') Do
      Inc(I);

    Result := Trim(Copy(AJSON, LStart, I - LStart));
    Exit;
  End;
End;

Function RESTDWFCMURLEncode(Const AValue : String) : String;
Const
  CHex : String = '0123456789ABCDEF';
Var
  I : Integer;
  C : Byte;
  LBytes : TRESTDWFCMBytes;
Begin
  Result := '';
  LBytes := RESTDWFCMStringToBytes(AValue);

  For I := 0 To Length(LBytes) - 1 Do
  Begin
    C := LBytes[I];

    If ((C >= Ord('a')) And
        (C <= Ord('z'))) Or
       ((C >= Ord('A')) And
        (C <= Ord('Z'))) Or
       ((C >= Ord('0')) And
        (C <= Ord('9'))) Or
       (C = Ord('-')) Or
       (C = Ord('_')) Or
       (C = Ord('.')) Or
       (C = Ord('~')) Then
      Result := Result + Char(C)
    Else
      Result :=
        Result +
        '%' +
        CHex[(C Shr 4) + 1] +
        CHex[(C And $0F) + 1];
  End;
End;

Function RESTDWFCMUIntToStr(AValue : TRESTDWFCMUInt64) : String;
Var
  LDigit : Byte;
Begin
  If AValue = 0 Then
  Begin
    Result := '0';
    Exit;
  End;

  Result := '';

  While AValue > 0 Do
  Begin
    LDigit := AValue Mod 10;

    Result :=
      Char(Ord('0') + LDigit) +
      Result;

    AValue := AValue Div 10;
  End;
End;

Function RESTDWFCMStrToUInt64Def(Const AValue : String;
                                 ADefault      : TRESTDWFCMUInt64) : TRESTDWFCMUInt64;
Var
  I      : Integer;
  LDigit : Integer;
  LValue : TRESTDWFCMUInt64;
Begin
  If AValue = '' Then
  Begin
    Result := ADefault;
    Exit;
  End;

  LValue := 0;

  For I := 1 To Length(AValue) Do
  Begin
    If (AValue[I] < '0') Or
       (AValue[I] > '9') Then
    Begin
      Result := ADefault;
      Exit;
    End;

    LDigit :=
      Ord(AValue[I]) -
      Ord('0');

    LValue :=
      (LValue * 10) +
      TRESTDWFCMUInt64(LDigit);
  End;

  Result := LValue;
End;

Function RESTDWFCMUnixNow : Int64;
Var
  LUTC : TDateTime;
{$IFDEF RESTDWWINDOWS}
  LSystemTime : TSystemTime;
{$ENDIF}
Begin
  {$IFDEF RESTDWWINDOWS}
  GetSystemTime(LSystemTime);

  LUTC :=
    EncodeDate(
      LSystemTime.wYear,
      LSystemTime.wMonth,
      LSystemTime.wDay
    ) +
    EncodeTime(
      LSystemTime.wHour,
      LSystemTime.wMinute,
      LSystemTime.wSecond,
      LSystemTime.wMilliseconds
    );
  {$ELSE}
    {$IFDEF FPC}
    LUTC :=
      LocalTimeToUniversal(
        Now
      );
    {$ELSE}
      {$IFDEF DELPHI2010UP}
      LUTC :=
        TTimeZone.Local.ToUniversalTime(
          Now
        );
      {$ELSE}
      LUTC := Now;
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  Result :=
    Trunc(
      (LUTC -
       EncodeDate(1970, 1, 1)) *
      86400
    );
End;

Procedure RESTDWFCMSleep(AMilliseconds : Cardinal);
Begin
  {$IFDEF RESTDWWINDOWS}
  Windows.Sleep(AMilliseconds);
  {$ELSE}
  Sleep(AMilliseconds);
  {$ENDIF}
End;

Procedure RESTDWFCMWriteUTF8(AStream : TStream;
                             Const AValue : String);
Var
  LBytes : TRESTDWFCMBytes;
Begin
  If AStream = Nil Then
    Exit;

  LBytes := RESTDWFCMStringToBytes(AValue);

  If Length(LBytes) > 0 Then
    AStream.WriteBuffer(
      LBytes[0],
      Length(LBytes)
    );
End;

Function RESTDWFCMPtrOffset(APointer : Pointer;
                            AOffset  : Integer) : Pointer;
Begin
  {$IFDEF CPU64}
  Result :=
    Pointer(
      NativeUInt(APointer) +
      NativeUInt(AOffset)
    );
  {$ELSE}
  Result :=
    Pointer(
      Cardinal(APointer) +
      Cardinal(AOffset)
    );
  {$ENDIF}
End;

End.
