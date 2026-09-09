Unit uRESTDWFCMMCS;

interface

{$I uRESTDW.inc}

uses
  Classes,
  uRESTDWFCMCompat,
  uRESTDWFCMTransport,
  SysUtils,
          uRESTDWFCMTypes,
  uRESTDWFCMProto,
  uRESTDWFCMCrypto;

type
  TRESTDWMCSDataEvent = procedure(Sender: TObject;
    const APersistentID, AMessageData, ARaw: string) of object;

  TRESTDWMCSClient = class
  private
    FTransport : TRESTDWFCMStreamTransport;
    FCredentials: TRESTDWFCMCredentials;
    FOnData: TRESTDWMCSDataEvent;
    FStop: Boolean;
    FStreamID: Integer;
    FLastStreamIDReported: Integer;

    function BuildLogin: TRESTDWFCMBytes;
    function BuildHeartbeatAck: TRESTDWFCMBytes;
    Function BuildSelectiveAck(Const APersistentID : String) : TRESTDWFCMBytes;
    function ReadVarIntIO: TRESTDWFCMUInt64;

    procedure SendFrame(ATag: Byte;
      const AData: TRESTDWFCMBytes;
      AIncludeVersion: Boolean = False);

    function ParseLoginResponseError(const AData: TRESTDWFCMBytes): string;
    procedure ParseDataMessage(const AData: TRESTDWFCMBytes);
  public
    Constructor Create(Const ACredentials : TRESTDWFCMCredentials;
                       ATransport   : TRESTDWFCMStreamTransport);
    destructor Destroy; override;

    procedure Connect;
    procedure Run;
    Procedure Stop;
    Procedure Ack(Const APersistentID : String);

    property OnData: TRESTDWMCSDataEvent read FOnData write FOnData;
  end;

implementation

Constructor TRESTDWMCSClient.Create(Const ACredentials : TRESTDWFCMCredentials;
                                      ATransport   : TRESTDWFCMStreamTransport);
Begin
  Inherited Create;
  FCredentials := ACredentials;
  FTransport := ATransport;
  FStop := False;
  FStreamID := 0;
  FLastStreamIDReported := -1;
End;

Destructor TRESTDWMCSClient.Destroy;
Begin
  Stop;
  Inherited Destroy;
End;

function TRESTDWMCSClient.BuildLogin: TRESTDWFCMBytes;
var
  LStream: TMemoryStream;
  LSettingsStream: TMemoryStream;
  LBytes: TRESTDWFCMBytes;
  LDeviceID: string;
  LHexID: string;
begin
  LDeviceID := RESTDWFCMUIntToStr(FCredentials.DeviceID);
  LHexID := LowerCase(IntToHex(Int64(FCredentials.DeviceID), 1));

  LStream := TMemoryStream.Create;
  LSettingsStream := TMemoryStream.Create;
  try
    TRESTDWProto.FieldString(
      LStream,
      1,
      'chrome-63.0.3234.0'
    );

    TRESTDWProto.FieldString(
      LStream,
      2,
      'mcs.android.com'
    );

    TRESTDWProto.FieldString(
      LStream,
      3,
      LDeviceID
    );

    TRESTDWProto.FieldString(
      LStream,
      4,
      LDeviceID
    );

    TRESTDWProto.FieldString(
      LStream,
      5,
      RESTDWFCMUIntToStr(FCredentials.SecurityToken)
    );

    TRESTDWProto.FieldString(
      LStream,
      6,
      'android-' + LHexID
    );

    TRESTDWProto.FieldString(
      LSettingsStream,
      1,
      'new_vc'
    );

    TRESTDWProto.FieldString(
      LSettingsStream,
      2,
      '1'
    );

    SetLength(LBytes, LSettingsStream.Size);
    LSettingsStream.Position := 0;

    if LSettingsStream.Size > 0 then
      LSettingsStream.ReadBuffer(
        LBytes[0],
        LSettingsStream.Size
      );

    TRESTDWProto.FieldBytes(LStream, 8, LBytes);

    { LoginRequest exatamente conforme BuildLoginRequest do Chromium.
      Nao enviar last_rmq_id/account_id em uma sessao nova. }

    { adaptive_heartbeat = false - field 12 }
    TRESTDWProto.FieldBool(LStream, 12, False);

    { use_rmq2 = true - field 14 }
    TRESTDWProto.FieldBool(LStream, 14, True);

    { auth_service = ANDROID_ID = 2 - field 16 }
    TRESTDWProto.FieldVarInt(LStream, 16, 2);

    { network_type = WIFI = 1 - field 17 }
    TRESTDWProto.FieldVarInt(LStream, 17, 1);

    SetLength(Result, LStream.Size);
    LStream.Position := 0;

    if LStream.Size > 0 then
      LStream.ReadBuffer(Result[0], LStream.Size);
  finally
    LSettingsStream.Free;
    LStream.Free;
  end;
end;

function TRESTDWMCSClient.BuildHeartbeatAck: TRESTDWFCMBytes;
var
  LStream: TMemoryStream;
begin
  LStream := TMemoryStream.Create;
  try
    if FStreamID > FLastStreamIDReported then
    begin
      TRESTDWProto.FieldVarInt(
        LStream,
        2,
        TRESTDWFCMUInt64(FStreamID)
      );

      FLastStreamIDReported := FStreamID;
    end;

    SetLength(Result, LStream.Size);
    LStream.Position := 0;

    if LStream.Size > 0 then
      LStream.ReadBuffer(
        Result[0],
        LStream.Size
      );
  finally
    LStream.Free;
  end;
end;

Function TRESTDWMCSClient.BuildSelectiveAck(Const APersistentID : String) : TRESTDWFCMBytes;
Var
  LIQStream        : TMemoryStream;
  LExtensionStream : TMemoryStream;
  LAckStream       : TMemoryStream;
  LAckData         : TRESTDWFCMBytes;
  LExtensionData   : TRESTDWFCMBytes;
Begin
  LIQStream        := TMemoryStream.Create;
  LExtensionStream := TMemoryStream.Create;
  LAckStream       := TMemoryStream.Create;
  Try
    TRESTDWProto.FieldString(LAckStream,
                             1,
                             APersistentID);

    SetLength(LAckData, LAckStream.Size);
    LAckStream.Position := 0;
    If LAckStream.Size > 0 Then
      LAckStream.ReadBuffer(LAckData[0],
                            LAckStream.Size);

    TRESTDWProto.FieldVarInt(LExtensionStream,
                             1,
                             12);
    TRESTDWProto.FieldBytes(LExtensionStream,
                            2,
                            LAckData);

    SetLength(LExtensionData, LExtensionStream.Size);
    LExtensionStream.Position := 0;
    If LExtensionStream.Size > 0 Then
      LExtensionStream.ReadBuffer(LExtensionData[0],
                                  LExtensionStream.Size);

    TRESTDWProto.FieldVarInt(LIQStream,
                             2,
                             1);
    TRESTDWProto.FieldString(LIQStream,
                             3,
                             '');
    TRESTDWProto.FieldBytes(LIQStream,
                            7,
                            LExtensionData);

    SetLength(Result, LIQStream.Size);
    LIQStream.Position := 0;
    If LIQStream.Size > 0 Then
      LIQStream.ReadBuffer(Result[0],
                           LIQStream.Size);
  Finally
    LAckStream.Free;
    LExtensionStream.Free;
    LIQStream.Free;
  End;
End;


procedure TRESTDWMCSClient.SendFrame(
  ATag: Byte;
  const AData: TRESTDWFCMBytes;
  AIncludeVersion: Boolean);
var
  LStream: TMemoryStream;
  LVersion: Byte;
begin
  LStream := TMemoryStream.Create;
  try
    if AIncludeVersion then
    begin
      LVersion := 41;
      LStream.WriteBuffer(LVersion, 1);
    end;

    LStream.WriteBuffer(ATag, 1);
    TRESTDWProto.WriteVarInt(
      LStream,
      Length(AData)
    );

    if Length(AData) > 0 then
      LStream.WriteBuffer(
        AData[0],
        Length(AData)
      );

    LStream.Position := 0;
    If LStream.Size > 0 Then
      FTransport.WriteBuffer(LStream.Memory^, LStream.Size);
  finally
    LStream.Free;
  end;
end;

function TRESTDWMCSClient.ReadVarIntIO: TRESTDWFCMUInt64;
var
  LByte: Byte;
  LShift: Integer;
begin
  Result := 0;
  LShift := 0;

  repeat
    LByte := FTransport.ReadByte;

    If (LShift = 63) And
       ((LByte And $FE) <> 0) Then
      Raise Exception.Create(
        'MCS varint excede UInt64'
      );

    Result :=
      Result Or
      (TRESTDWFCMUInt64(LByte And $7F) Shl LShift);

    If (LByte And $80) = 0 Then
      Break;

    Inc(LShift, 7);

    If LShift > 63 Then
      Raise Exception.Create(
        'MCS varint invalido'
      );
  until False;
end;

procedure TRESTDWMCSClient.Connect;
var
  LLogin: TRESTDWFCMBytes;
begin
  FStop := False;
  FStreamID := 0;
  FLastStreamIDReported := -1;

  FTransport.Connect('mtalk.google.com', 5228);

  LLogin := BuildLogin;
  SendFrame(
    2,
    LLogin,
    True
  );
end;

function TRESTDWMCSClient.ParseLoginResponseError(const AData: TRESTDWFCMBytes): string;
var
  S, E: TRESTDWFCMBytesStream;
  K, F, W, EK, EF, EW, Code: TRESTDWFCMUInt64;
  B: TRESTDWFCMBytes;
  Msg, Typ: string;
begin
  Result := '';
  S := TRESTDWFCMBytesStream.Create(AData);
  try
    while S.Position < S.Size do
    begin
      K := TRESTDWProto.ReadVarInt(S);
      F := K shr 3;
      W := K and 7;
      if W = 2 then
      begin
        B := TRESTDWProto.ReadLengthDelimited(S);
        if F = 3 then
        begin
          Code := 0; Msg := ''; Typ := '';
          E := TRESTDWFCMBytesStream.Create(B);
          try
            while E.Position < E.Size do
            begin
              EK := TRESTDWProto.ReadVarInt(E);
              EF := EK shr 3;
              EW := EK and 7;
              if EW = 0 then
              begin
                if EF = 1 then Code := TRESTDWProto.ReadVarInt(E)
                else TRESTDWProto.ReadVarInt(E);
              end
              else if EW = 2 then
              begin
                B := TRESTDWProto.ReadLengthDelimited(E);
                if EF = 2 then Msg := RESTDWFCMBytesToString(B)
                else if EF = 3 then Typ := RESTDWFCMBytesToString(B);
              end
              else if EW = 1 then
              begin
                If (E.Size - E.Position) < 8 Then
                  Raise Exception.Create('MCS login fixed64 truncado');
                E.Seek(8, soCurrent);
              end
              else if EW = 5 then
              begin
                If (E.Size - E.Position) < 4 Then
                  Raise Exception.Create('MCS login fixed32 truncado');
                E.Seek(4, soCurrent);
              end
              else Break;
            end;
          finally
            E.Free;
          end;
          Result := Format('MCS login recusado code=%d type=%s message=%s',
            [Code, Typ, Msg]);
          Exit;
        end;
      end
      else if W = 0 then TRESTDWProto.ReadVarInt(S)
      else if W = 1 then
      begin
        If (S.Size - S.Position) < 8 Then
          Raise Exception.Create('MCS login fixed64 truncado');
        S.Seek(8, soCurrent);
      end
      else if W = 5 then
      begin
        If (S.Size - S.Position) < 4 Then
          Raise Exception.Create('MCS login fixed32 truncado');
        S.Seek(4, soCurrent);
      end
      else Break;
    end;
  finally
    S.Free;
  end;
end;

procedure TRESTDWMCSClient.ParseDataMessage(
  const AData: TRESTDWFCMBytes);
var
  LStream: TRESTDWFCMBytesStream;
  LSubStream: TRESTDWFCMBytesStream;
  LKey, LField, LWireType: TRESTDWFCMUInt64;
  LSubKey, LSubField, LSubWireType: TRESTDWFCMUInt64;
  LBytes, LRawData, LDecrypted: TRESTDWFCMBytes;
  LKeyName, LValue: string;
  LPersistentID, LMessageData, LRaw: string;
  LCryptoKey, LEncryption, LDecryptedText, LTrimmedText: string;
begin
  LPersistentID := '';
  LMessageData := '';
  LRaw := '';
  LCryptoKey := '';
  LEncryption := '';
  SetLength(LRawData, 0);

  LStream := TRESTDWFCMBytesStream.Create(AData);
  try
    while LStream.Position < LStream.Size do
    begin
      LKey := TRESTDWProto.ReadVarInt(LStream);
      LField := LKey shr 3;
      LWireType := LKey and 7;
      case LWireType of
        0: TRESTDWProto.ReadVarInt(LStream);
        1:
          Begin
            If (LStream.Size - LStream.Position) < 8 Then
              Raise Exception.Create('MCS data fixed64 truncado');
            LStream.Seek(8, soCurrent);
          End;
        2:
          begin
            LBytes := TRESTDWProto.ReadLengthDelimited(LStream);
            if LField = 7 then
            begin
              LSubStream := TRESTDWFCMBytesStream.Create(LBytes);
              try
                LKeyName := '';
                LValue := '';
                while LSubStream.Position < LSubStream.Size do
                begin
                  LSubKey := TRESTDWProto.ReadVarInt(LSubStream);
                  LSubField := LSubKey shr 3;
                  LSubWireType := LSubKey and 7;
                  if LSubWireType = 2 then
                  begin
                    LBytes := TRESTDWProto.ReadLengthDelimited(LSubStream);
                    if LSubField = 1 then LKeyName := RESTDWFCMBytesToString(LBytes)
                    else if LSubField = 2 then LValue := RESTDWFCMBytesToString(LBytes);
                  end
                  else if LSubWireType = 0 then TRESTDWProto.ReadVarInt(LSubStream)
                  else if LSubWireType = 1 then
                  begin
                    If (LSubStream.Size - LSubStream.Position) < 8 Then
                      Raise Exception.Create('MCS app_data fixed64 truncado');
                    LSubStream.Seek(8, soCurrent);
                  end
                  else if LSubWireType = 5 then
                  begin
                    If (LSubStream.Size - LSubStream.Position) < 4 Then
                      Raise Exception.Create('MCS app_data fixed32 truncado');
                    LSubStream.Seek(4, soCurrent);
                  end
                  else Break;
                end;

                if SameText(LKeyName, 'messagedata') then LMessageData := LValue;
                if SameText(LKeyName, 'crypto-key') then LCryptoKey := LValue;
                if SameText(LKeyName, 'encryption') then LEncryption := LValue;

                if LRaw <> '' then LRaw := LRaw + ',';
                LRaw := LRaw + '"' + StringReplace(LKeyName, '"', '\"', [rfReplaceAll]) +
                  '":"' + StringReplace(LValue, '"', '\"', [rfReplaceAll]) + '"';
              finally
                LSubStream.Free;
              end;
            end
            else if LField = 9 then
              LPersistentID := RESTDWFCMBytesToString(LBytes)
            else if LField = 21 then
              LRawData := Copy(LBytes, 0, Length(LBytes));
          end;
        5:
          Begin
            If (LStream.Size - LStream.Position) < 4 Then
              Raise Exception.Create('MCS data fixed32 truncado');
            LStream.Seek(4, soCurrent);
          End;
      else
        raise Exception.Create('MCS wire type inesperado');
      end;
    end;
  finally
    LStream.Free;
  end;

  LRaw := '{' + LRaw + '}';

  { Tokens obtidos pela API fcmregistrations sao WebPush. Nesse fluxo o
    DataMessageStanza traz crypto-key/encryption em app_data e o payload real
    criptografado em raw_data (protobuf field 21). }
  if (LMessageData = '') and (Length(LRawData) > 0) and
     (LCryptoKey <> '') and (LEncryption <> '') then
  begin
    LDecrypted := TRESTDWWebPushCrypto.DecryptAESGCM(
      FCredentials.PushPrivateKey,
      FCredentials.PushPublicKey,
      FCredentials.PushAuth,
      LCryptoKey,
      LEncryption,
      LRawData
    );
    LDecryptedText := RESTDWFCMBytesToString(LDecrypted);
    LRaw := LDecryptedText;
    LMessageData := RESTDWFCMJSONValue(LDecryptedText, 'messagedata');

    { Mantem compatibilidade caso algum emissor mande apenas texto no payload. }
    LTrimmedText := Trim(LDecryptedText);
    If (LMessageData = '') And
       (LTrimmedText <> '') And
       (LTrimmedText[1] <> '{') Then
      LMessageData := LDecryptedText;
  end;

  If Assigned(FOnData) Then
    FOnData(Self,
            LPersistentID,
            LMessageData,
            LRaw);
end;

Procedure TRESTDWMCSClient.Ack(Const APersistentID : String);
Var
  LSelectiveAck : TRESTDWFCMBytes;
Begin
  If APersistentID = '' Then
    Exit;
  LSelectiveAck := BuildSelectiveAck(APersistentID);
  SendFrame(7, LSelectiveAck, False);
End;

procedure TRESTDWMCSClient.Run;
var
  LVersion: Byte;
  LTag: Byte;
  LLength: TRESTDWFCMUInt64;
  LData: TRESTDWFCMBytes;
  LFirstFrame: Boolean;
  LAck: TRESTDWFCMBytes;
  LRaw: string;
begin
  LFirstFrame := True;

  While (Not FStop) And FTransport.Connected Do
  begin
    if LFirstFrame then
    begin
      LVersion := FTransport.ReadByte;

      if LVersion <> 41 then
        raise Exception.CreateFmt(
          'MCS versao %d inesperada',
          [LVersion]
        );

      LFirstFrame := False;
    end;

    LTag := FTransport.ReadByte;
    LLength := ReadVarIntIO;

    { Protege contra frame corrompido/malicioso e contra overflow
      na conversao UInt64 -> Integer em compiladores antigos. }
    If LLength > 16 * 1024 * 1024 Then
      Raise Exception.Create(
        'MCS frame acima do limite de 16 MB'
      );

    SetLength(LData, Integer(LLength));

    if LLength > 0 then
    begin
      FTransport.ReadBuffer(LData[0], Integer(LLength));
    end;

    Inc(FStreamID);

    case LTag of
      0:
        begin
          LAck := BuildHeartbeatAck;
          SendFrame(
            1,
            LAck,
            False
          );
        end;

      1:
        ;

      3:
        begin
          LRaw := ParseLoginResponseError(LData);
          if LRaw <> '' then
            raise Exception.Create(LRaw);
        end;

      4:
        FStop := True;

      7:
        ;

      8:
        ParseDataMessage(LData);
    end;
  end;
end;

procedure TRESTDWMCSClient.Stop;
begin
  FStop := True;

  If FTransport.Connected Then
    FTransport.Disconnect;
end;

end.
