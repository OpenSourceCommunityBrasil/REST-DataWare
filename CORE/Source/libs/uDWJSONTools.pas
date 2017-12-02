unit uDWJSONTools;

interface

Uses
  {$IFDEF FPC}
   SysUtils, Classes, uDWConsts, IdGlobal, IdCoderMIME, uDWConstsData, IdHashMessageDigest, base64, LConvEncoding;
  {$ELSE}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    System.SysUtils, ServerUtils, System.Classes, IdGlobal, IdCoderMIME, uDWConsts, uDWConstsData, IdHashMessageDigest;
   {$ELSE}
    SysUtils, ServerUtils, Classes, IdGlobal, IdCoderMIME, uDWConsts, uDWConstsData, IdHashMessageDigest, EncdDecd;
   {$IFEND}
  {$ENDIF}

Const
 ReTablebase64 = #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$3E + #$40
               + #$40 + #$40 + #$3F + #$34 + #$35 + #$36 + #$37 + #$38 + #$39 + #$3A + #$3B + #$3C
               + #$3D + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$00 + #$01 + #$02 + #$03
               + #$04 + #$05 + #$06 + #$07 + #$08 + #$09 + #$0A + #$0B + #$0C + #$0D + #$0E + #$0F
               + #$10 + #$11 + #$12 + #$13 + #$14 + #$15 + #$16 + #$17 + #$18 + #$19 + #$40 + #$40
               + #$40 + #$40 + #$40 + #$40 + #$1A + #$1B + #$1C + #$1D + #$1E + #$1F + #$20 + #$21
               + #$22 + #$23 + #$24 + #$25 + #$26 + #$27 + #$28 + #$29 + #$2A + #$2B + #$2C + #$2D
               + #$2E + #$2F + #$30 + #$31 + #$32 + #$33 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40;
 TableBase64   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';


Function  GetPairJSON  (Status      : Integer;
                        MessageText : String;
                        Encoding    : TEncodeSelect = esUtf8) : String;Overload;
Function  GetPairJSON  (Tag,
                        MessageText : String;
                        Encoding    : TEncodeSelect = esUtf8) : String;Overload;
{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
  Function  DecodeBase64 (Const Value : String)             : String;
  Function  EncodeBase64 (Const Value : String)             : String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
  Function  DecodeBase64 (Const Value : String)             : String;
  Function  EncodeBase64 (Const Value : String)             : String;
{$ELSE}
  Function  DecodeBase64 (Const Value : AnsiString
                          {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : AnsiString;
  Function  EncodeBase64 (Const Value : AnsiString
                          {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF})             : AnsiString;
{$IFEND}
{$IFEND}
Function  EncodeStrings(Value       : String
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF})                 : String;
Function  DecodeStrings(Value       : String
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF})                 : String;
Function  EncodeBytes  (Value : String{$IFNDEF FPC}{$if CompilerVersion > 21}
                                      ;Encoding : TEncoding {$IFEND}{$ENDIF}) : TIdBytes;
Procedure HexStringToStream(Value : String; Var BinaryStream : TStringStream);
Function  StreamToHex(Value : TStream) : String;

Implementation

Uses SysTypes;

{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Function Decode4to3Ex(const Value, Table: String): String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
Function Decode4to3Ex(const Value, Table: String): String;
{$ELSE}
Function Decode4to3Ex(const Value, Table: AnsiString): AnsiString;
{$IFEND}
{$IFEND}
Var
 p,  x, y,
 lv, d, dl : Integer;
 c         : Byte;
Begin
 lv := Length(Value);
 SetLength(Result, lv);
 x := 1;
 dl := 4;
 d := 0;
 p := 1;
 While x <= lv Do
  Begin
   y := Ord(Value[x]);
   If y In [33..127] Then
    c := Ord(Table[y - 32])
   Else
    c := 64;
   Inc(x);
   If c > 63 Then
    Continue;
   d := (d shl 6) or c;
   dec(dl);
   If dl <> 0 Then
    Continue;
   {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
   Result[p] := Char((d shr 16) and $ff);
   Inc(p);
   Result[p] := Char((d shr 8) and $ff);
   Inc(p);
   Result[p] := Char(d and $ff);
   {$ELSE}
   {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
   Result[p] := Char((d shr 16) and $ff);
   Inc(p);
   Result[p] := Char((d shr 8) and $ff);
   Inc(p);
   Result[p] := Char(d and $ff);
   {$ELSE}
   Result[p] := AnsiChar((d shr 16) and $ff);
   Inc(p);
   Result[p] := AnsiChar((d shr 8) and $ff);
   Inc(p);
   Result[p] := AnsiChar(d and $ff);
   {$IFEND}
   {$IFEND}
   Inc(p);
   d := 0;
   dl := 4;
  End;
 Case dl Of
  1 : Begin
       d := d shr 2;
       {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
       Result[p] := Char((d shr 8) and $ff);
       Inc(p);
       Result[p] := Char(d and $ff);
       Inc(p);
       {$ELSE}
       {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
       Result[p] := Char((d shr 8) and $ff);
       Inc(p);
       Result[p] := Char(d and $ff);
       Inc(p);
       {$ELSE}
       Result[p] := AnsiChar((d shr 8) and $ff);
       Inc(p);
       Result[p] := AnsiChar(d and $ff);
       Inc(p);
       {$IFEND}
       {$IFEND}
      End;
  2 : Begin
       d := d shr 4;
       {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
        Result[p] := Char(d and $ff);
        Inc(p);
       {$ELSE}
       {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
        Result[p] := Char(d and $ff);
        Inc(p);
       {$ELSE}
        Result[p] := AnsiChar(d and $ff);
       Inc(p);
       {$IFEND}
       {$IFEND}
      End;
 End;
 SetLength(Result, p - 1);
End;

{$IFDEF FPC}
Function EncodeStringBase64(Const s : String):String;
Var
 outstream : TStringStream;
 encoder   : TBase64EncodingStream;
Begin
 If Length(s) > 0 Then
  Begin
   outstream := TStringStream.Create('');
   Try
    encoder := TBase64EncodingStream.Create(outstream);
    Try
     encoder.write(s[1], length(s));
    Finally
     encoder.free;
    End;
    outstream.position:=0;
    Result := outstream.readstring(outstream.size);
   Finally
    outstream.free;
   End;
  End
 Else
  Result := '';
End;
{$ENDIF}

Function Encode64(const S: string; const ByteEncoding: IIdTextEncoding = nil): string;
Begin
 {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
  Result := TIdEncoderMIME.EncodeString(S, IndyTextEncoding_utf8);
 {$ELSE}
  {$IFDEF FPC}
   Result := EncodeStringBase64(S);
  {$ELSE}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := TIdEncoderMIME.EncodeString(S, IndyTextEncoding_utf8);
   {$ELSE}
    Result := TIdEncoderMIME.EncodeString(S, IndyTextEncoding_ASCII);
   {$IFEND}
  {$ENDIF}
 {$IFEND}
End;

{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Function Encode3to4(Const Value, Table : String) : String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
Function Encode3to4(Const Value, Table : String) : String;
{$ELSE}
Function Encode3to4(Const Value, Table : AnsiString) : AnsiString;
{$IFEND}
{$IFEND}
Begin
 Result := Encode64(Value);
End;

{$IFDEF FPC}
Function DecodeStringBase64(Const s : String) : String;
Var
 instream,
 outstream : TStringStream;
 decoder   : TBase64DecodingStream;
Begin
 If s <> '' Then
  Begin
   instream := TStringStream.Create(s);
   Try
    outstream:=TStringStream.Create('');
    Try
     decoder := TBase64DecodingStream.create(instream,bdmmime);
     Try
      If decoder.size > 0 Then
       Begin
        outstream.CopyFrom(decoder, decoder.size);
        outstream.position:=0;
        Result := outstream.Readstring(outstream.size);
       End;
     Finally
      decoder.free;
     End;
    Finally
     outstream.free;
    End;
   Finally
    instream.free;
   End;
  End
 Else
  Result := '';
End;
{$ENDIF}

Function Decode64(const S: string; const ByteEncoding: IIdTextEncoding = nil): string;
Begin
 {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
  Result := UTF8Decode(TIdDecoderMIME.DecodeString(S, IndyTextEncoding_utf8));
 {$ELSE}
  {$IFDEF FPC}
   Result := DecodeStringBase64(S);
  {$ELSE}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := TIdDecoderMIME.DecodeString(S, IndyTextEncoding_utf8);
   {$ELSE}
    Result := UTF8Decode(TIdDecoderMIME.DecodeString(S, IndyTextEncoding_ASCII));
   {$IFEND}
  {$ENDIF}
 {$IFEND}
End;

{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Function DecodeBase64(Const Value : String) : String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
  Function  DecodeBase64 (Const Value : String)             : String;
{$ELSE}
  Function DecodeBase64(Const Value : AnsiString
                       {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : AnsiString;
  {$IFEND}
{$IFEND}
Var
 vValue : String;
Begin
 vValue := Decode64(Value);
 {$IFDEF FPC}
 Case DatabaseCharSet Of
   csWin1250 : vValue := CP1250ToUTF8(vValue);
   csWin1251 : vValue := CP1251ToUTF8(vValue);
   csWin1252 : vValue := CP1252ToUTF8(vValue);
   csWin1253 : vValue := CP1253ToUTF8(vValue);
   csWin1254 : vValue := CP1254ToUTF8(vValue);
   csWin1255 : vValue := CP1255ToUTF8(vValue);
   csWin1256 : vValue := CP1256ToUTF8(vValue);
   csWin1257 : vValue := CP1257ToUTF8(vValue);
   csWin1258 : vValue := CP1258ToUTF8(vValue);
 End;
 {$ENDIF}
 Result := vValue;
End;

{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Function EncodeBase64(Const Value : String) : String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
Function EncodeBase64(Const Value : String) : String;
{$ELSE}
  Function EncodeBase64(Const Value : AnsiString
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : AnsiString;
{$IFEND}
{$IFEND}
Var
 vValue : String;
Begin
 vValue := Value;
 {$IFDEF FPC}
 Case DatabaseCharSet Of
   csWin1250 : vValue := CP1250ToUTF8(vValue);
   csWin1251 : vValue := CP1251ToUTF8(vValue);
   csWin1252 : vValue := CP1252ToUTF8(vValue);
   csWin1253 : vValue := CP1253ToUTF8(vValue);
   csWin1254 : vValue := CP1254ToUTF8(vValue);
   csWin1255 : vValue := CP1255ToUTF8(vValue);
   csWin1256 : vValue := CP1256ToUTF8(vValue);
   csWin1257 : vValue := CP1257ToUTF8(vValue);
   csWin1258 : vValue := CP1258ToUTF8(vValue);
 End;
 {$ENDIF}
 Result := Encode64(vValue);
End;

Function EncodeBytes(Value : String{$IFNDEF FPC}{$if CompilerVersion > 21}; Encoding : TEncoding{$IFEND}{$ENDIF}) : TIdBytes;
Var
 Encoder: TIdEncoderMIME;
Begin
 Encoder := TIdEncoderMIME.Create(nil);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   Result := ToBytes(Encoder.Encode(Value, IndyTextEncoding_ASCII));
  {$ELSE}
   Result := ToBytes(Encoder.Encode(Value{$if CompilerVersion > 21}, IndyTextEncoding(Encoding){$IFEND}));
  {$IFEND}
 {$ELSE}
  Result := ToBytes(Encoder.Encode(Value));
 {$ENDIF}
 Encoder.Free;
End;

Function HexStringToString(Value : String) : String;
Var
 BinaryStream : TStringStream;
 {$IFDEF POSIX} // Android}
  bytes: TBytes;
 {$ENDIF}
Begin
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   BinaryStream := TStringStream.Create('', TEncoding.ANSI);
  {$ELSE}
   BinaryStream := TStringStream.Create('');
  {$IFEND}
 {$ELSE}
  BinaryStream := TStringStream.Create('');
 {$ENDIF}
 Try
  BinaryStream.Size := Length(Value) div 2;
  If BinaryStream.Size > 0 Then
   Begin
     {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
      SetLength(bytes, Length(value) div 2);
      HexToBin(PWideChar(value), 0, bytes, 0, Length(bytes));
      Result:= TEncoding.UTF8.GetString(bytes);
     {$ELSE}
     {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
      SetLength(bytes, Length(value) div 2);
      HexToBin(PWideChar(value), 0, bytes, 0, Length(bytes));
      Result:= TEncoding.UTF8.GetString(bytes);
     {$ELSE}
      HexToBin(PChar(Value), TMemoryStream(BinaryStream).Memory, BinaryStream.Size);
      Result := BinaryStream.DataString;
    {$IFEND}
    {$IFEND}
   End;
 Finally
  BinaryStream.Free;
 End;
End;

Procedure HexStringToStream(Value : String; Var BinaryStream : TStringStream);
{$IFDEF POSIX} //Android}
var bytes: TBytes;
{$ENDIF}
Begin
 Try
  If Not Assigned(BinaryStream) Then
   Begin
   {$IFDEF FPC}
    BinaryStream := TStringStream.Create('');
   {$ELSE}
    {$IF CompilerVersion > 21}
     BinaryStream := TStringStream.Create;
    {$ELSE}
     BinaryStream := TStringStream.Create('');
    {$IFEND}
   {$ENDIF}
   End;
   {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
    SetLength(bytes, Length(value) div 2);
    HexToBin(PWideChar(value), 0, bytes, 0, Length(bytes));
    BinaryStream.write(bytes,length(bytes));
   {$ELSE}
   {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
    SetLength(bytes, Length(value) div 2);
    HexToBin(PWideChar(value), 0, bytes, 0, Length(bytes));
    BinaryStream.write(bytes,length(bytes));
   {$ELSE}
    BinaryStream.Size := Length(Value) div 2;
    If BinaryStream.Size > 0 Then
    HexToBin(PChar(Value), TMemoryStream(BinaryStream).Memory, BinaryStream.Size);
   {$IFEND}
   {$IFEND}
 Except
 End;
End;

Function StringToHex(Value : String) : String;
Var
 BinaryStream : TStringStream;
 {$IFDEF POSIX}
  bytes: TBytes;
 {$ENDIF}
Begin
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
   BinaryStream := TStringStream.Create(String(Utf8Encode(Value)), TEncoding.ANSI);
   {$ELSE}
   {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
   BinaryStream := TStringStream.Create(String(Utf8Encode(Value)), TEncoding.ANSI);
   {$ELSE}
   BinaryStream := TStringStream.Create(AnsiString(Utf8Encode(Value)), TEncoding.ANSI);
   {$IFEND}
   {$IFEND}
  {$ELSE}
   BinaryStream := TStringStream.Create(Value);
  {$IFEND}
 {$ELSE}
  BinaryStream := TStringStream.Create(Value);
 {$ENDIF}
 Try
  BinaryStream.Position := 0;
  SetLength(Result, BinaryStream.Size * 2);
  {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
   SetLength(bytes, Length(value) div 2);
   HexToBin(PwideChar(value), 0, bytes, 0, Length(bytes));
   Result:= TEncoding.UTF8.GetString(bytes);
  {$ELSE}
  {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
   SetLength(bytes, Length(value) div 2);
   HexToBin(PwideChar(value), 0, bytes, 0, Length(bytes));
   Result:= TEncoding.UTF8.GetString(bytes);
  {$ELSE}
   BinToHex(TMemoryStream(BinaryStream).Memory, PChar(Result), BinaryStream.Size);
  {$IFEND}
  {$IFEND}
 Finally
  BinaryStream.Free;
 End;
End;

{$IF Defined(ANDROID) or Defined(LINUX) or Defined(IOS)}
function abbintohexstring(stream: Tstream):string;
var
  s: TStream;
  i: Integer;
  b: Byte;
  hex: String;
begin
  s := stream;
  try
    s.Seek(int64(0), word(soFromBeginning));
    for i:=1 to s.Size do
    begin
      s.Read(b, 1);
      hex := IntToHex(b, 2);
      //.....
      result:=result+hex;
    end;
  finally
    s.Free;
  end;
end;
{$IFend}

Function StreamToHex(Value : TStream) : String;
{.$IFDEF POSIX} //Android}
//var bytes: TBytes;
//i: Integer;
//b: Byte;
//hex: String;
{//$ENDIF}
Begin
 Try
  TMemoryStream(Value).Position := 0;
  {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
    result:=abbintohexstring(value);

 {  SetLength(bytes, TMemoryStream(Value).Size * 2);
   HexToBin(PwideChar(value), 0, bytes, 0, Length(bytes));
   Result:= TEncoding.UTF8.GetString(bytes);}
  {$ELSE}
  {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
   //SetLength(bytes, TMemoryStream(Value).Size * 2);
   //HexToBin(PwideChar(value), 0, bytes, 0, Length(bytes));
   //Result:= TEncoding.UTF8.GetString(bytes);
   result:=abbintohexstring(value);
  {$ELSE}
  SetLength(Result, TMemoryStream(Value).Size * 2);
  BinToHex(TMemoryStream(Value).Memory, PChar(Result), Value.Size);
  {$IFEND}
  {$IFEND}
 Except
 End;
End;

Function EncodeStrings(Value : String
                      {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
Begin
 Result := '';
 If Value = '' Then
  Exit;
{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
 Result := Encode64(Value); //TIdencoderMIME.EncodeString(Value, nil);
{$ELSE}
 Result := EncodeBase64(Value{$IFDEF FPC}, DatabaseCharSet{$ENDIF});
{$IFEND}
End;

Function DecodeStrings(Value : String
                       {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
Begin
 {$IFDEF FPC}
  Result := DecodeBase64(Value, DatabaseCharSet);
 {$ELSE}
 {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
  Result := Decode64(Value); //TIdencoderMIME.EncodeString(Value, nil);
 {$ELSE}
  Result := DecodeBase64(Value);
  {$IFEND}
 {$ENDIF}
End;

Function GetPairJSON(Tag,
                     MessageText : String;
                     Encoding    : TEncodeSelect = esUtf8) : String;
Var
 WSResult : TResultErro;
Begin
 WSResult.STATUS      := Tag;
 WSResult.MessageText := MessageText;
 Result               := EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF FPC}, csUndefined{$ENDIF});
End;

Function GetPairJSON(Status      : Integer;
                     MessageText : String;
                     Encoding    : TEncodeSelect = esUtf8) : String;
Var
 WSResult : TResultErro;
Begin
 WSResult.STATUS      := IntToStr(Status);
 WSResult.MessageText := MessageText;
 Result               := EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF FPC}, csUndefined{$ENDIF});
End;

end.
