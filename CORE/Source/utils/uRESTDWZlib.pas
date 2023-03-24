unit uRESTDWZlib;

{$I ..\Includes\uRESTDW.inc}

interface

Uses
  {$IFDEF RESTDWLAZARUS}zstream, base64, {$ENDIF}
  SysUtils, Classes, zlib,
  uRESTDWDataUtils, uRESTDWConsts, uRESTDWTools;

// Funções de Compressão e descompressão de Stream com ZLib
Procedure ZCompressStream(inStream, outStream: TStream;
  CompressionLevel: TCompressionLevel = clDefault);
Procedure ZDecompressStream(inStream, outStream: TStream);
Function ZDecompressStreamNew(Const S: TStream): TStream;
Function ZDecompressStr(Const S: String; Var Value: String): Boolean;
Function ZDecompressStreamD(Const S: TStringStream;
  Var Value: TStringStream): Boolean;
Function ZCompressStreamNew(Const S: String): TStream;
Function ZCompressStreamSS(Const S: String): TStringStream;
Function ZCompressStr(Const S: String; Var Value: String): Boolean;
Function ZCompressStreamD(S: TStream; Var Value: TStream): Boolean;

implementation

Procedure ZCompressStream(inStream, outStream: TStream;
  CompressionLevel: TCompressionLevel = clDefault);
Var
  DS: TCompressionStream;
  Size: DWInt64;
Begin
  inStream.Position := 0; // Goto Start of input stream
  DS := TCompressionStream.Create(CompressionLevel, outStream);
  Try
    Size := inStream.Size;
    inStream.Position := 0;
    DS.Write(Size, SizeOf(DWInt64));
    DS.CopyFrom(inStream, inStream.Size);
  Finally
    DS.Free;
  End;
End;

Procedure ZDecompressStream(inStream, outStream: TStream);
Var
  D: TDecompressionstream;
  B: Array [1 .. CompressBuffer] of Byte;
  R: Integer;
  Size: DWInt64;
Begin
  D := TDecompressionstream.Create(inStream);
  D.Read(Size, SizeOf(DWInt64));

  {$IFDEF RESTDWLAZARUS}
  While True Do
  Begin
    R := D.Read(B, SizeOf(B));
    If R <> 0 Then
      outStream.WriteBuffer(B, R)
    Else
      Break;
  End;
  outStream.Position := 0;
  FreeAndNil(D);
  {$ELSE}
  inStream.Position := SizeOf(Size);
  Try
    Repeat
      If ((Size - outStream.Size) > CompressBuffer) Then
        R := D.Read(B, SizeOf(B))
      Else
        R := D.Read(B, (Size - outStream.Size));
      If R > 0 then
        outStream.Write(B, R);
    Until R < SizeOf(B);
  Finally
    outStream.Position := 0;
    D.Free;
  End;
  {$ENDIF}
End;

Function ZCompressStreamD(S: TStream; Var Value: TStream): Boolean;
Var
  Utf8Stream: TStream;
Begin
  Result := False;
  Try
    Utf8Stream := TMemoryStream.Create;
    {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXE4UP)}
    Utf8Stream.CopyFrom(S, S.Size);
    {$ELSE}
    Utf8Stream.Write(AnsiString(TStringStream(S).Datastring)
      [InitStrPos], S.Size);
    {$IFEND}
    Value := TMemoryStream.Create;
    Try
      ZCompressStream(Utf8Stream, Value, cCompressionLevel);
      Value.Position := 0;
      Result := True;
    Finally

    End;
  Finally
    {$IFNDEF RESTDWLAZARUS}Utf8Stream.Size := 0; {$ENDIF}
    Utf8Stream.Free;
    If Value.Size = 0 Then
    Begin
      Result := False;
      Value.Size := 0;
      FreeAndNil(Value);
    End;
  End;
End;

Function ZCompressStreamSS(Const S: String): TStringStream;
Var
  Utf8Stream: TStringStream;
Begin
  {$IF Defined(RESTDWLAZARUS)}
  Utf8Stream := TStringStream.Create(S);
  {$ELSEIF Defined(DELPHIXEUP)}
  Utf8Stream := TStringStream.Create(S, TEncoding.UTF8);
  {$ELSE}
  Utf8Stream := TStringStream.Create('');
  Utf8Stream.Write(AnsiString(S)[1], Length(AnsiString(S)));
  {$IFEND}
  Result := TStringStream.Create(''{$IFDEF DELPHIXEUP}, TEncoding.UTF8{$ENDIF});
  Try
    ZCompressStream(Utf8Stream, Result, cCompressionLevel);
    Result.Position := 0;
  Finally
    {$IFNDEF FPC}Utf8Stream.Size := 0; {$ENDIF}
    Utf8Stream.Free;
    If Result.Size = 0 Then
      FreeAndNil(Result);
  End;
End;

Function ZCompressStreamNew(Const S: String): TStream;
Var
  Utf8Stream: TStream;
Begin

  {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXEUP) OR Defined(RESTDWWINDOWS)}
  Utf8Stream := TMemoryStream.Create;
  Utf8Stream.Write(AnsiString(S)[1], Length(AnsiString(S)));
  {$ELSE}
   {$IF Defined(RESTDWLINUX)}
   Utf8Stream:= Tstringstream.Create(S, TEncoding.UTF8);
   {$ELSE}
  Utf8Stream.Write(S[1], Length(S));
  {$IFEND}
  {$IFEND}
  Result := TMemoryStream.Create;
  Try
    ZCompressStream(Utf8Stream, Result, cCompressionLevel);
    Result.Position := 0;
  Finally
    {$IFNDEF RESTDWLAZARUS}Utf8Stream.Size := 0; {$ENDIF}
    Utf8Stream.Free;
    If Result.Size = 0 Then
      FreeAndNil(Result);
  End;
End;

Function ZCompressStr(Const S: String; Var Value: String): Boolean;
Var
  Utf8Stream: TStringStream;
  Compressed: TMemoryStream;
Begin
  Result := False;
  {$IF Defined(DELPHIXEUP)}
  Utf8Stream := TStringStream.Create(S, TEncoding.UTF8);
  {$ELSEIF Defined(RESTDWLAZARUS)}
  Utf8Stream := TStringStream.Create(S);
  {$ELSE}
  Utf8Stream := TStringStream.Create('');
  Utf8Stream.Write(AnsiString(S)[1], Length(AnsiString(S)));
  {$IFEND}
  Try
    Compressed := TMemoryStream.Create;
    Try
      ZCompressStream(Utf8Stream, Compressed, cCompressionLevel);
      Compressed.Position := 0;
      Try
        Value := StreamToHex(Compressed, False);
        Result := True;
      Finally
      End;
    Finally
      Compressed := nil;
      Compressed.Free;
    End;
  Finally
    {$IFDEF DELPHIXEUP}Utf8Stream.Clear;{$ENDIF}
    FreeAndNil(Utf8Stream);
  End;
End;

Function ZDecompressStreamD(Const S: TStringStream;
  Var Value: TStringStream): Boolean;
Var
  Utf8Stream, Base64Stream: TStringStream;
  {$IFDEF RESTDWLAZARUS}
  Encoder: TBase64DecodingStream;
  {$ENDIF}
Begin
  Base64Stream := TStringStream.Create(''{$IFDEF DELPHIXEUP}, TEncoding.UTF8{$ENDIF});
  S.Position := 0;
  Base64Stream.CopyFrom(S, S.Size);
  Base64Stream.Position := 0;
  Try
    Value := TStringStream.Create(''{$IFDEF DELPHIXEUP}, TEncoding.UTF8{$ENDIF});
    Try
      Try
        Utf8Stream := TStringStream.Create(''{$IFDEF DELPHIXEUP}, TEncoding.UTF8{$ENDIF});
        HexToStream(Base64Stream.Datastring, Utf8Stream);
        Utf8Stream.Position := 0;
        ZDecompressStream(Utf8Stream, Value);
        Value.Position := 0;
        Result := True;
      Except
        Result := False;
      End;
    Finally
      {$IFNDEF RESTDWLAZARUS}Utf8Stream.Size := 0; {$ENDIF}
      FreeAndNil(Utf8Stream);
    End;
  Finally
    {$IFNDEF RESTDWLAZARUS}Base64Stream.Size := 0; {$ENDIF}
    FreeAndNil(Base64Stream);
  End;
End;

Function ZDecompressStreamNew(Const S: TStream): TStream;
Begin
  Result := TMemoryStream.Create;
  S.Position := 0;
  ZDecompressStream(S, Result);
  Result.Position := 0;
End;

Function ZDecompressStr(Const S: String; Var Value: String): Boolean;
Var
  Utf8Stream, Compressed, Base64Stream: TStringStream;
  {$IFDEF RESTDWLAZARUS}
  Encoder: TBase64DecodingStream;
  {$ENDIF}
Begin
  Result := False;
  {$IFDEF DELPHIXEUP}
  Base64Stream := TStringStream.Create(S, TEncoding.ANSI);
  {$ELSE}
  Base64Stream := TStringStream.Create(S);
  {$ENDIF}
  Try
    Compressed := TStringStream.Create('');
    Try
      {$IFDEF RESTDWLAZARUS}
      Utf8Stream := TStringStream.Create('');
      Encoder := TBase64DecodingStream.Create(Base64Stream);
      Utf8Stream.CopyFrom(Encoder, Encoder.Size);
      Utf8Stream.Position := 0;
      FreeAndNil(Encoder);
      Compressed.Position := 0;
      ZDecompressStream(Utf8Stream, Compressed);
      {$ELSE}
      Utf8Stream := TStringStream.Create(''{$IFDEF DELPHIXEUP}, TEncoding.UTF8{$ENDIF});
      ZDecompressStream(Base64Stream, Compressed);
      Compressed.Position := 0;
      {$ENDIF}
      Try
        Value := Compressed.Datastring;
        Result := True;
      Finally
        {$IFNDEF RESTDWLAZARUS}Utf8Stream.Size := 0; {$ENDIF}
        FreeAndNil(Utf8Stream);
      End;
    Finally
      {$IFNDEF RESTDWLAZARUS}Compressed.Size := 0; {$ENDIF}
      FreeAndNil(Compressed);
    End;
  Finally
    {$IFNDEF RESTDWLAZARUS}Base64Stream.Size := 0; {$ENDIF}
    FreeAndNil(Base64Stream);
  End;
End;

end.
