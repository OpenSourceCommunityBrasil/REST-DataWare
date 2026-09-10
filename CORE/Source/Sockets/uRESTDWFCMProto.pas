Unit uRESTDWFCMProto;

interface

{$I uRESTDW.inc}

uses
  Classes,
  uRESTDWFCMCompat,
  SysUtils;

type
  TRESTDWProto = class
  public
    Class Procedure WriteVarInt(AStream : TStream; AValue : TRESTDWFCMUInt64);

    Class Function ReadVarInt(AStream : TStream) : TRESTDWFCMUInt64;

    Class Procedure FieldVarInt(AStream : TStream; AField : Integer; AValue : TRESTDWFCMUInt64);
    Class Procedure FieldFixed64(AStream : TStream; AField : Integer; AValue : TRESTDWFCMUInt64);

    Class Procedure FieldBool(AStream : TStream; AField : Integer; AValue : Boolean);

    Class Procedure FieldString(AStream : TStream; AField : Integer; Const AValue : String);

    Class Procedure FieldBytes(AStream : TStream; AField : Integer; Const AValue : TRESTDWFCMBytes);

    Class Function ReadLengthDelimited(AStream : TStream) : TRESTDWFCMBytes;

    Class Function FindStringField(Const AData : TRESTDWFCMBytes; AField : Integer) : String;
  end;

implementation

class procedure TRESTDWProto.WriteVarInt(
  AStream: TStream;
  AValue: TRESTDWFCMUInt64
);
var
  LByte: Byte;
begin
  repeat
    LByte := Byte(AValue and $7F);
    AValue := AValue shr 7;

    if AValue <> 0 then
      LByte := LByte or $80;

    AStream.WriteBuffer(LByte, 1);
  until AValue = 0;
end;

class function TRESTDWProto.ReadVarInt(
  AStream: TStream
): TRESTDWFCMUInt64;
var
  LByte: Byte;
  LShift: Integer;
begin
  Result := 0;
  LShift := 0;

  repeat
    AStream.ReadBuffer(LByte, 1);

    If (LShift = 63) And
       ((LByte And $FE) <> 0) Then
      Raise Exception.Create('Protobuf varint excede UInt64');

    Result :=
      Result Or
      (TRESTDWFCMUInt64(LByte And $7F) Shl LShift);

    If (LByte And $80) = 0 Then
      Break;

    Inc(LShift, 7);

    If LShift > 63 Then
      Raise Exception.Create('Protobuf varint invalido');
  until False;
end;

class procedure TRESTDWProto.FieldVarInt(
  AStream: TStream;
  AField: Integer;
  AValue: TRESTDWFCMUInt64
);
begin
  WriteVarInt(AStream, TRESTDWFCMUInt64(AField shl 3));
  WriteVarInt(AStream, AValue);
end;

Class Procedure TRESTDWProto.FieldFixed64(AStream : TStream;
                                          AField : Integer;
                                          AValue : TRESTDWFCMUInt64);
Var
  LBytes : Array[0..7] Of Byte;
  LIndex : Integer;
Begin
  WriteVarInt(
    AStream,
    TRESTDWFCMUInt64((AField Shl 3) Or 1)
  );

  For LIndex := 0 To 7 Do
    LBytes[LIndex] := Byte(
      (AValue Shr (LIndex * 8)) And $FF
    );

  AStream.WriteBuffer(
    LBytes[0],
    SizeOf(LBytes)
  );
End;


class procedure TRESTDWProto.FieldBool(
  AStream: TStream;
  AField: Integer;
  AValue: Boolean
);
begin
  if AValue then
    FieldVarInt(AStream, AField, 1)
  else
    FieldVarInt(AStream, AField, 0);
end;

class procedure TRESTDWProto.FieldString(
  AStream: TStream;
  AField: Integer;
  const AValue: string
);
var
  LBytes: TRESTDWFCMBytes;
begin
  LBytes := RESTDWFCMStringToBytes(AValue);
  FieldBytes(AStream, AField, LBytes);
end;

class procedure TRESTDWProto.FieldBytes(
  AStream: TStream;
  AField: Integer;
  const AValue: TRESTDWFCMBytes
);
begin
  WriteVarInt(AStream, TRESTDWFCMUInt64((AField shl 3) or 2));
  WriteVarInt(AStream, Length(AValue));

  if Length(AValue) > 0 then
    AStream.WriteBuffer(AValue[0], Length(AValue));
end;

class function TRESTDWProto.ReadLengthDelimited(
  AStream: TStream
): TRESTDWFCMBytes;
var
  LLength: TRESTDWFCMUInt64;
begin
  LLength := ReadVarInt(AStream);

  If LLength > TRESTDWFCMUInt64(MaxInt) Then
    Raise Exception.Create('Protobuf length excede Integer');

  If LLength > TRESTDWFCMUInt64(AStream.Size - AStream.Position) Then
    Raise Exception.Create('Protobuf length excede o stream');

  SetLength(Result, Integer(LLength));

  If LLength > 0 Then
    AStream.ReadBuffer(Result[0], Integer(LLength));
end;

class function TRESTDWProto.FindStringField(
  const AData: TRESTDWFCMBytes;
  AField: Integer
): string;
var
  LStream: TRESTDWFCMBytesStream;
  LKey: TRESTDWFCMUInt64;
  LWireType: TRESTDWFCMUInt64;
  LField: TRESTDWFCMUInt64;
  LBytes: TRESTDWFCMBytes;
begin
  Result := '';
  LStream := TRESTDWFCMBytesStream.Create(AData);
  try
    while LStream.Position < LStream.Size do
    begin
      LKey := ReadVarInt(LStream);
      LWireType := LKey and 7;
      LField := LKey shr 3;

      case LWireType of
        0:
          ReadVarInt(LStream);

        1:
          Begin
            If (LStream.Size - LStream.Position) < 8 Then
              Raise Exception.Create('Protobuf fixed64 truncado');
            LStream.Seek(8, soCurrent);
          End;

        2:
          begin
            LBytes := ReadLengthDelimited(LStream);
            if LField = TRESTDWFCMUInt64(AField) then
            begin
              Result := RESTDWFCMBytesToString(LBytes);
              Exit;
            end;
          end;

        5:
          Begin
            If (LStream.Size - LStream.Position) < 4 Then
              Raise Exception.Create('Protobuf fixed32 truncado');
            LStream.Seek(4, soCurrent);
          End;
      else
        raise Exception.Create('Wire type protobuf nao suportado');
      end;
    end;
  finally
    LStream.Free;
  end;
end;

end.
