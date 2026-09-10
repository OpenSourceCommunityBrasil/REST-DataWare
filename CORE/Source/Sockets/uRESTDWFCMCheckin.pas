Unit uRESTDWFCMCheckin;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  uRESTDWFCMCompat,
  uRESTDWFCMTransport,
  SysUtils,
      uRESTDWFCMTypes,
  uRESTDWFCMProto;

Type
  TRESTDWGCMCheckin = Class
  Private
    FHTTP : TRESTDWFCMHTTPTransport;

    Function BuildRequest(Const ACredentials : TRESTDWFCMCredentials) : TRESTDWFCMBytes;
    Function ReadFixed64(AStream : TStream) : TRESTDWFCMUInt64;

    Procedure ReadSetting(Const AData : TRESTDWFCMBytes;
                          Var ACredentials : TRESTDWFCMCredentials);

    Procedure ParseResponse(Const AResponse : TRESTDWFCMBytes;
                            Var ACredentials : TRESTDWFCMCredentials);

    Procedure SendCheckin(Var ACredentials : TRESTDWFCMCredentials);
  Public
    Constructor Create(AHTTP : TRESTDWFCMHTTPTransport);
    Destructor Destroy; Override;

    Procedure Execute(Var ACredentials : TRESTDWFCMCredentials);
  End;

Implementation

Constructor TRESTDWGCMCheckin.Create(AHTTP : TRESTDWFCMHTTPTransport);
Begin
  Inherited Create;
  FHTTP := AHTTP;
End;

Destructor TRESTDWGCMCheckin.Destroy;
Begin
  Inherited Destroy;
End;

Function TRESTDWGCMCheckin.BuildRequest(Const ACredentials : TRESTDWFCMCredentials) : TRESTDWFCMBytes;
Var
  LRequestStream : TMemoryStream;
  LCheckinStream : TMemoryStream;
  LChromeStream  : TMemoryStream;
  LCheckinBytes  : TRESTDWFCMBytes;
  LChromeBytes   : TRESTDWFCMBytes;
Begin
  LRequestStream := TMemoryStream.Create;
  LCheckinStream := TMemoryStream.Create;
  LChromeStream := TMemoryStream.Create;
  Try
    { Identidade de protocolo REST Dataware.
      O valor abaixo faz parte somente do wire format usado no check-in.
      Ele e fixo e nao representa nem consulta o SysOp onde o componente
      esta executando. A mesma identidade e usada em Desktop e Mobile. }
    TRESTDWProto.FieldVarInt(LChromeStream, 1, 1);

    TRESTDWProto.FieldString(LChromeStream, 2, '127.0.6533.73');

    { CHANNEL_STABLE = 1 }
    TRESTDWProto.FieldVarInt(LChromeStream, 3, 1);

    SetLength(LChromeBytes, LChromeStream.Size);
    LChromeStream.Position := 0;

    If LChromeStream.Size > 0 Then
      LChromeStream.ReadBuffer(
        LChromeBytes[0],
        LChromeStream.Size
      );

    { Wire device type usado pela identidade de protocolo REST Dataware. }
    TRESTDWProto.FieldVarInt(LCheckinStream, 12, 3);
    TRESTDWProto.FieldBytes(LCheckinStream, 13, LChromeBytes);

    SetLength(LCheckinBytes, LCheckinStream.Size);
    LCheckinStream.Position := 0;

    If LCheckinStream.Size > 0 Then
      LCheckinStream.ReadBuffer(
        LCheckinBytes[0],
        LCheckinStream.Size
      );

    { Wire format do endpoint de check-in utilizado pelo REST Dataware.
      id              = field 2, int64 / varint
      checkin         = field 4
      security_token  = field 13, fixed64
      version         = field 14
      user serial     = field 22 }
    If ACredentials.DeviceID <> 0 Then
      TRESTDWProto.FieldVarInt(
        LRequestStream,
        2,
        TRESTDWFCMUInt64(ACredentials.DeviceID)
      );

    TRESTDWProto.FieldBytes(
      LRequestStream,
      4,
      LCheckinBytes
    );

    If ACredentials.SecurityToken <> 0 Then
      TRESTDWProto.FieldFixed64(
        LRequestStream,
        13,
        ACredentials.SecurityToken
      );

    TRESTDWProto.FieldVarInt(LRequestStream, 14, 3);
    TRESTDWProto.FieldVarInt(LRequestStream, 22, 0);

    SetLength(Result, LRequestStream.Size);
    LRequestStream.Position := 0;

    If LRequestStream.Size > 0 Then
      LRequestStream.ReadBuffer(
        Result[0],
        LRequestStream.Size
      );
  Finally
    LChromeStream.Free;
    LCheckinStream.Free;
    LRequestStream.Free;
  End;
End;

Function TRESTDWGCMCheckin.ReadFixed64(AStream : TStream) : TRESTDWFCMUInt64;
Var
  LBytes : Array[0..7] Of Byte;
  LIndex : Integer;
Begin
  Result := 0;

  AStream.ReadBuffer(
    LBytes[0],
    SizeOf(LBytes)
  );

  For LIndex := 0 To 7 Do
    Result := Result Or
              (TRESTDWFCMUInt64(LBytes[LIndex]) Shl (LIndex * 8));
End;

Procedure TRESTDWGCMCheckin.ReadSetting(Const AData : TRESTDWFCMBytes;
                                        Var ACredentials : TRESTDWFCMCredentials);
Var
  LStream   : TRESTDWFCMBytesStream;
  LKey      : TRESTDWFCMUInt64;
  LField    : TRESTDWFCMUInt64;
  LWireType : TRESTDWFCMUInt64;
  LData     : TRESTDWFCMBytes;
  LName     : String;
  LValue    : String;
Begin
  LName := '';
  LValue := '';

  LStream := TRESTDWFCMBytesStream.Create(AData);
  Try
    While LStream.Position < LStream.Size Do
    Begin
      LKey := TRESTDWProto.ReadVarInt(LStream);
      LField := LKey Shr 3;
      LWireType := LKey And 7;

      Case LWireType Of
        0:
          TRESTDWProto.ReadVarInt(LStream);

        1:
          Begin
            If (LStream.Size - LStream.Position) < 8 Then
              Raise Exception.Create('Checkin protobuf fixed64 truncado');

            LStream.Seek(8, soCurrent);
          End;

        2:
          Begin
            LData := TRESTDWProto.ReadLengthDelimited(LStream);

            If LField = 1 Then
              LName := RESTDWFCMBytesToString(LData)
            Else
            If LField = 2 Then
              LValue := RESTDWFCMBytesToString(LData);
          End;

        5:
          Begin
            If (LStream.Size - LStream.Position) < 4 Then
              Raise Exception.Create('Checkin protobuf fixed32 truncado');

            LStream.Seek(4, soCurrent);
          End;
      Else
        Raise Exception.Create(
          'Setting do Checkin com protobuf inesperado'
        );
      End;
    End;
  Finally
    LStream.Free;
  End;

  If SameText(LName, 'gcm_registration_url') Then
    ACredentials.RegistrationURL := LValue;
End;

Procedure TRESTDWGCMCheckin.ParseResponse(Const AResponse : TRESTDWFCMBytes;
                                          Var ACredentials : TRESTDWFCMCredentials);
Var
  LStream   : TRESTDWFCMBytesStream;
  LData     : TRESTDWFCMBytes;
  LKey      : TRESTDWFCMUInt64;
  LField    : TRESTDWFCMUInt64;
  LWireType : TRESTDWFCMUInt64;
  LValue    : TRESTDWFCMUInt64;
Begin
  LStream := TRESTDWFCMBytesStream.Create(AResponse);
  Try
    While LStream.Position < LStream.Size Do
    Begin
      LKey := TRESTDWProto.ReadVarInt(LStream);
      LField := LKey Shr 3;
      LWireType := LKey And 7;

      Case LWireType Of
        0:
          TRESTDWProto.ReadVarInt(LStream);

        1:
          Begin
            LValue := ReadFixed64(LStream);

            If LField = 7 Then
              ACredentials.DeviceID := LValue
            Else
            If LField = 8 Then
              ACredentials.SecurityToken := LValue;
          End;

        2:
          Begin
            LData := TRESTDWProto.ReadLengthDelimited(LStream);

            If LField = 5 Then
              ReadSetting(
                LData,
                ACredentials
              );
          End;

        5:
          Begin
            If (LStream.Size - LStream.Position) < 4 Then
              Raise Exception.Create('Checkin protobuf fixed32 truncado');

            LStream.Seek(4, soCurrent);
          End;
      Else
        Raise Exception.Create(
          'Checkin protobuf inesperado'
        );
      End;
    End;
  Finally
    LStream.Free;
  End;
End;

Procedure TRESTDWGCMCheckin.SendCheckin(Var ACredentials : TRESTDWFCMCredentials);
Var
  LRequest       : TRESTDWFCMBytes;
  LResponseBytes : TRESTDWFCMBytes;
  LRequestStream : TRESTDWFCMBytesStream;
  LResponse      : TMemoryStream;
  LError         : TMemoryStream;
  LHeaders       : TStringList;
  LCode          : Integer;
Begin
  LRequest := BuildRequest(ACredentials);
  LRequestStream := TRESTDWFCMBytesStream.Create(LRequest);
  LResponse := TMemoryStream.Create;
  LError := TMemoryStream.Create;
  LHeaders := TStringList.Create;
  Try
    LHeaders.Values['Content-Type'] := 'application/x-protobuf';
    LCode := FHTTP.Post('https://android.clients.google.com/checkin',
                        LHeaders,
                        LRequestStream,
                        LResponse,
                        LError);
    If LCode = 401 Then
      Raise Exception.Create('GCM Checkin autenticado recusou DeviceID/SecurityToken');
    If (LCode Div 100) <> 2 Then
      Raise Exception.Create('GCM Checkin HTTP ' + IntToStr(LCode));

    SetLength(LResponseBytes, LResponse.Size);
    LResponse.Position := 0;
    If Length(LResponseBytes) > 0 Then
      LResponse.ReadBuffer(LResponseBytes[0], Length(LResponseBytes));
  Finally
    LHeaders.Free;
    LError.Free;
    LResponse.Free;
    LRequestStream.Free;
  End;

  ParseResponse(LResponseBytes, ACredentials);
  If (ACredentials.DeviceID = 0) Or
     (ACredentials.SecurityToken = 0) Then
    Raise Exception.Create('GCM Checkin nao retornou DeviceID/SecurityToken');
End;

Procedure TRESTDWGCMCheckin.Execute(Var ACredentials : TRESTDWFCMCredentials);
Var
  LBootstrap : Boolean;
Begin
  LBootstrap := (ACredentials.DeviceID = 0) Or
                (ACredentials.SecurityToken = 0);

  If LBootstrap Then
  Begin
    ACredentials.DeviceID := 0;
    ACredentials.SecurityToken := 0;

    { Primeiro check-in: exatamente como Chromium. Ele cria o par
      AndroidID/SecurityToken. Nao repetimos imediatamente um segundo
      check-in autenticado antes do register3. }
    SendCheckin(ACredentials);
  End
  Else
  Begin
    { Credenciais ja persistidas: valida o par existente. }
    SendCheckin(ACredentials);
  End;
End;

End.
