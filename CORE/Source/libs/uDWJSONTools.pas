unit uDWJSONTools;

{$I uRESTDW.inc}

interface

Uses
  {$IFDEF FPC}
   SysUtils, Classes, uDWConsts, IdGlobal, IdCoderMIME, uDWConstsCharset, IdHashMessageDigest, base64, LConvEncoding, lazutf8, DB;
  {$ELSE}
   {$if CompilerVersion > 22} // Delphi 2010 pra cima
    System.SysUtils, ServerUtils, System.Classes, {$IF Defined(HAS_FMX)}System.NetEncoding, {$IFEND}
    IdGlobal, IdCoderMIME, uDWConsts, uDWConstsCharset, IdHashMessageDigest, DB;
   {$ELSE}
    SysUtils, ServerUtils, Classes, IdGlobal, IdCoderMIME, uDWConsts, uDWConstsCharset, IdHashMessageDigest, EncdDecd, DB;
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
 B64Table      = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

Type
 TByteArr = Array Of Byte;


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
  Function  DecodeBase64 (Const Value : String
                          {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
  Function  EncodeBase64 (Const Value : String
                          {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
{$IFEND}
{$IFEND}
Function  EncodeStrings(Value       : String
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF})                 : String;
Function  aEncodeStrings(Value       : String
                         {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF})                : String;
Function  DecodeStrings(Value       : String
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF})                 : String;

Function  Encodeb64Stream(Value       : TStream)     : String;
Function  Decodeb64Stream(Value       : String)      : TMemoryStream;


Function  EncodeBytes  (Value : String{$IFNDEF FPC}{$if CompilerVersion > 21}
                                      ;Encoding : TEncoding {$IFEND}{$ENDIF}) : TIdBytes;
Function HexStringToString(Value : String) : String;

Procedure HexStringToStream(Value : String; Var BinaryStream : TStringStream);
Function  BookmarkToHex(Value : TByteArr) : String;
Function  HexToBookmark(Value : String)   : TByteArr;
Function  StreamToHex(const Value : TStream) : String;
{$IFDEF FPC}
Function  GetStringUnicode(Value : String) : String;
Function  GetStringEncode (Value : String; DatabaseCharSet : TDatabaseCharSet) : String;
Function  GetStringDecode (Value : String; DatabaseCharSet : TDatabaseCharSet) : String;
{$ENDIF}

Implementation

Uses SysTypes;

Function Base64Encode(const S: string): string;
var
  InBuf : array[0..2] of Byte;
  OutBuf: array[0..3] of Char;
  iI : Integer;
begin
  SetLength(Result, ((Length(S) + 2) div 3) * 4);
  for iI := 1 to ((Length(S) + 2) div 3) do begin
    if Length(S) < (iI * 3) then
      Move(S[(iI - 1) * 3 + 1], InBuf, Length(S) - (iI - 1) * 3)
    else
      Move(S[(iI - 1) * 3 + 1], InBuf, 3);
    OutBuf[0] := B64Table[((InBuf[0] and $FC) shr 2) + 1];
    OutBuf[1] := B64Table[(((InBuf[0] and $3) shl 4) or ((InBuf[1] and $F0) shr 4)) + 1];
    OutBuf[2] := B64Table[(((InBuf[1] and $F) shl 2) or ((InBuf[2] and $C0) shr 6)) + 1];
    OutBuf[3] := B64Table[(InBuf[2] and $3F) + 1];
    Move(OutBuf, Result[(iI - 1) * 4 + 1], 4);
  end;
  if Length(S) mod 3 = 1 then begin
    Result[Length(Result) - 1] := '=';
    Result[Length(Result)] := '=';
  end else if Length(S) mod 3 = 2 then
    Result[Length(Result)] := '=';
end;

Function Base64Decode(const S: string): string;
Var
 OutBuf : array[0..2] of Byte;
 InBuf  : array[0..3] of Byte;
 iI,
 iJ     : Integer;
 sa     : String;
Begin
 sa := Trim(StringReplace(S, '#$D#$A', '', [rfReplaceAll, rfIgnoreCase]));
 If Length(sa) Mod 4 <> 0 Then
  Raise Exception.Create('Base64: Incorrect string format');
 SetLength(Result, ((Length(sa) div 4) - 1) * 3);
 For iI := 1 to (Length(sa) div 4) - 1 Do
  Begin
   Move(sa[(iI - 1) * 4 + 1], InBuf, 4);
    for iJ := 0 to 3 do
      case InBuf[iJ] of
        43: InBuf[iJ] := 62;
        48..57: Inc(InBuf[iJ], 4);
        65..90: Dec(InBuf[iJ], 65);
        97..122: Dec(InBuf[iJ], 71);
      else
        InBuf[iJ] := 63;
      end;
    OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $3);
    OutBuf[1] := (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $F);
    OutBuf[2] := (InBuf[2] shl 6) or (InBuf[3] and $3F);
    Move(OutBuf, Result[(iI - 1) * 3 + 1], 3);
  End;
 If Length(sa) <> 0 Then
  Begin
    Move(sa[Length(sa) - 3], InBuf, 4);
    if InBuf[2] = 61 then begin
      for iJ := 0 to 1 do
        case InBuf[iJ] of
          43: InBuf[iJ] := 62;
          48..57: Inc(InBuf[iJ], 4);
          65..90: Dec(InBuf[iJ], 65);
          97..122: Dec(InBuf[iJ], 71);
        else
          InBuf[iJ] := 63;
        end;
      OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $3);
      Result := Result + Char(OutBuf[0]);
    end else if InBuf[3] = 61 then begin
      for iJ := 0 to 2 do
        case InBuf[iJ] of
          43: InBuf[iJ] := 62;
          48..57: Inc(InBuf[iJ], 4);
          65..90: Dec(InBuf[iJ], 65);
          97..122: Dec(InBuf[iJ], 71);
        else
          InBuf[iJ] := 63;
        end;
      OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $3);
      OutBuf[1] := (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $F);
      Result := Result + Char(OutBuf[0]) + Char(OutBuf[1]);
    end else begin
      for iJ := 0 to 3 do
        case InBuf[iJ] of
          43: InBuf[iJ] := 62;
          48..57: Inc(InBuf[iJ], 4);
          65..90: Dec(InBuf[iJ], 65);
          97..122: Dec(InBuf[iJ], 71);
        else
          InBuf[iJ] := 63;
        end;
      OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $3);
      OutBuf[1] := (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $F);
      OutBuf[2] := (InBuf[2] shl 6) or (InBuf[3] and $3F);
      Result := Result + Char(OutBuf[0]) + Char(OutBuf[1]) + Char(OutBuf[2]);
    end;
  End;
End;

{$IFDEF FPC}
Function  GetStringUnicode(Value : String) : String;
Var
 Unicode,
 Charlen : Integer;
 P       : PChar;
Begin
 P := PChar(Value);
 Result := '';
 Repeat
  Unicode := UTF8CharacterToUnicode(P, Charlen);
  Result  := Result + UTF8Copy(p, 1, 1);
  Inc(P, Charlen);
 Until (Charlen = 0) or (Unicode = 0);
 Result := P;
End;

Function  GetStringEncode(Value : String;DatabaseCharSet : TDatabaseCharSet) : String;
Begin
 Result := Value;
 Case DatabaseCharSet Of
   csWin1250    : Result := CP1250ToUTF8(Value);
   csWin1251    : Result := CP1251ToUTF8(Value);
   csWin1252    : Result := CP1252ToUTF8(Value);
   csWin1253    : Result := CP1253ToUTF8(Value);
   csWin1254    : Result := CP1254ToUTF8(Value);
   csWin1255    : Result := CP1255ToUTF8(Value);
   csWin1256    : Result := CP1256ToUTF8(Value);
   csWin1257    : Result := CP1257ToUTF8(Value);
   csWin1258    : Result := CP1258ToUTF8(Value);
   csUTF8       : Result := UTF8ToUTF8BOM(Value);
   csISO_8859_1 : Result := ISO_8859_1ToUTF8(Value);
   csISO_8859_2 : Result := ISO_8859_2ToUTF8(Value);
 End;
End;

Function  GetStringDecode(Value : String;DatabaseCharSet : TDatabaseCharSet) : String;
Begin
 Result := Value;
 Case DatabaseCharSet Of
   csWin1250    : Result := UTF8ToCP1250(Value);
   csWin1251    : Result := UTF8ToCP1251(Value);
   csWin1252    : Result := UTF8ToCP1252(Value);
   csWin1253    : Result := UTF8ToCP1253(Value);
   csWin1254    : Result := UTF8ToCP1254(Value);
   csWin1255    : Result := UTF8ToCP1255(Value);
   csWin1256    : Result := UTF8ToCP1256(Value);
   csWin1257    : Result := UTF8ToCP1257(Value);
   csWin1258    : Result := UTF8ToCP1258(Value);
   csUTF8       : Result := UTF8BOMToUTF8(Value);
   csISO_8859_1 : Result := UTF8ToISO_8859_1(Value);
   csISO_8859_2 : Result := UTF8ToISO_8859_2(Value);
 End;
End;
{$ENDIF}

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

Function Encode64(const S: string; const ByteEncoding: {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                        TIdTextEncoding
                                                       {$ELSE}
                                                        IIdTextEncoding
                                                       {$IFEND}
                                                       {$ELSE}
                                                        IIdTextEncoding
                                                       {$ENDIF} = nil): string;
Var
 sa : String;
{$IFNDEF FPC}
{$IF Defined(ANDROID) OR Defined(IOS)}
 ne : TBase64Encoding;
{$IFEND}
{$ENDIF}
Begin
 {$IFDEF FPC}
  Result := Base64Encode(S);
 {$ELSE}
  {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
   ne := TBase64Encoding.Create(-1);
   Result := ne.Encode(S);
   ne.Free;
  {$ELSE}
   Result := TIdEncoderMIME.EncodeString(S {$IFNDEF FPC},
                                               {$IF Defined(OldIndy)}TIdTextEncoding.Default
                                               {$ELSE}
                                                {$IF (CompilerVersion > 18)}
                                                 IndyTextEncoding_utf8
                                                {$ELSE IF (CompilerVersion > 25)}
                                                 IndyUTF8Encoding
                                                {$IFEND}
                                               {$IFEND}
                                              {$ENDIF});
  {$IFEND}
 {$ENDIF}
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

Function Decode64(const S: string; const ByteEncoding: {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                        TIdTextEncoding
                                                       {$ELSE}
                                                        IIdTextEncoding
                                                       {$IFEND}
                                                       {$ELSE}
                                                        IIdTextEncoding
                                                       {$ENDIF} = nil): string;
Var
 sa : String;
{$IF Defined(ANDROID) OR Defined(IOS)}
 ne : TBase64Encoding;
{$IFEND}
Begin
 {$IFDEF FPC}
  Result := DecodeStringBase64(S);
 {$ELSE}
  {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
   //Result := TNetEncoding.Base64.Decode(S);//UTF8Decode(TIdDecoderMIME.DecodeString(S, IndyTextEncoding_utf8));
   ne := TBase64Encoding.Create(-1);
   Result := ne.Decode(S);
   ne.Free;
  {$ELSE}
   {$IF (CompilerVersion > 19)}
     Result := TIdDecoderMIME.DecodeString(S{$IFNDEF FPC}
                                             {$IF Defined(OldIndy)}
                                             {$ELSE}
                                              {$IF (CompilerVersion > 19)}
                                               , IndyTextEncoding_utf8
                                              {$ELSE IF (CompilerVersion > 22)}
                                               , IndyUTF8Encoding
                                              {$IFEND}
                                             {$IFEND}
                                            {$ENDIF});

  {$ELSE}
   SA := S;
   If Pos(sLineBreak, SA) > 0 Then
    SA := StringReplace(SA, sLineBreak, '', [rfReplaceAll]);
   Result := Base64Decode(SA);
  {$IFEND}
 {$IFEND}
 {$ENDIF}
End;

{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Function DecodeBase64(Const Value : String) : String;
{$ELSE}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
  Function  DecodeBase64 (Const Value : String)             : String;
{$ELSE}
  Function DecodeBase64(Const Value : String
                       {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
  {$IFEND}
{$IFEND}
Var
 vValue : String;
Begin
 vValue := Decode64(Value);
 {$IFDEF FPC}
 Case DatabaseCharSet Of
   csWin1250    : vValue := CP1250ToUTF8(vValue);
   csWin1251    : vValue := CP1251ToUTF8(vValue);
   csWin1252    : vValue := CP1252ToUTF8(vValue);
   csWin1253    : vValue := CP1253ToUTF8(vValue);
   csWin1254    : vValue := CP1254ToUTF8(vValue);
   csWin1255    : vValue := CP1255ToUTF8(vValue);
   csWin1256    : vValue := CP1256ToUTF8(vValue);
   csWin1257    : vValue := CP1257ToUTF8(vValue);
   csWin1258    : vValue := CP1258ToUTF8(vValue);
   csUTF8       : vValue := UTF8ToUTF8BOM(vValue);
   csISO_8859_1 : vValue := ISO_8859_1ToUTF8(vValue);
   csISO_8859_2 : vValue := ISO_8859_2ToUTF8(vValue);
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
  Function EncodeBase64(Const Value : String
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
{$IFEND}
{$IFEND}
Var
 vValue : String;
Begin
 vValue := Value;
 {$IFDEF FPC}
 Case DatabaseCharSet Of
   csWin1250    : vValue := CP1250ToUTF8(vValue);
   csWin1251    : vValue := CP1251ToUTF8(vValue);
   csWin1252    : vValue := CP1252ToUTF8(vValue);
   csWin1253    : vValue := CP1253ToUTF8(vValue);
   csWin1254    : vValue := CP1254ToUTF8(vValue);
   csWin1255    : vValue := CP1255ToUTF8(vValue);
   csWin1256    : vValue := CP1256ToUTF8(vValue);
   csWin1257    : vValue := CP1257ToUTF8(vValue);
   csWin1258    : vValue := CP1258ToUTF8(vValue);
   csUTF8       : vValue := UTF8ToUTF8BOM(vValue);
   csISO_8859_1 : vValue := ISO_8859_1ToUTF8(vValue);
   csISO_8859_2 : vValue := ISO_8859_2ToUTF8(vValue);
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
  {$if CompilerVersion > 22}
   Result := ToBytes(Encoder.Encode(Value, {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
                                            IndyASCIIEncoding
                                           {$ELSE}
                                            IndyTextEncoding_ASCII
                                           {$IFEND}
                                           {$ENDIF}));
  {$ELSE}
   Result := ToBytes(Encoder.Encode(Value{$if CompilerVersion > 22}, IndyTextEncoding(Encoding){$IFEND}));
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
  {$if CompilerVersion > 22}
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
Var
 bytes: TBytes;
{$ENDIF}
Begin
 {$IFDEF FPC}
 BinaryStream := Nil;
 {$ENDIF}
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
  raise Exception.Create('Invalid Hexa Stream...');
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
  {$if CompilerVersion > 22}
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
  FreeAndNil(BinaryStream);
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


Function BookmarkToHex(Value : TByteArr) : String;
{$IFDEF POSIX}
Var
 bytes: TBytes;
{$ENDIF}
Begin
 Result := '';
 If Length(Value) > 0 Then
  Begin
   SetLength(Result, Length(Value) * SizeOf(Char));
   {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
    SetLength(bytes, Length(value) div 2);
    HexToBin(PwideChar(value), 0, bytes, 0, Length(bytes));
    Result := TEncoding.UTF8.GetString(bytes);
   {$ELSE}
    {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
     SetLength(bytes, Length(value) div 2);
     HexToBin(PwideChar(value), 0, bytes, 0, Length(bytes));
     Result := TEncoding.UTF8.GetString(bytes);
    {$ELSE}
     BinToHex(PAnsiChar(Value), PChar(Result), Length(Value));
    {$IFEND}
   {$IFEND}
  End;
End;

Function HexToBookmark(Value : String) : TByteArr;
{$IFDEF POSIX} //Android
Var
 bytes: TBytes;
{$ENDIF}
begin
 SetLength(Result, 0);
 If Trim(Value) = '' Then
  Exit;
 SetLength(Result, Length(Value) div SizeOf(Char));
 {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
  HexToBin(PWideChar(value), 0, TBytes(Result), 0, Length(Result));
 {$ELSE}
  {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
   HexToBin(PWideChar(value), Result, Length(Result));
  {$ELSE}
   HexToBin(PChar(Value), PAnsiChar(Result), Length(Result));
  {$IFEND}
 {$IFEND}
End;

Function StreamToHex(const Value : TStream) : String;
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
   If TMemoryStream(Value).Size > 0 Then
    Begin
     SetLength(Result, TMemoryStream(Value).Size * 2);
     BinToHex(TMemoryStream(Value).Memory, PChar(Result), Value.Size);
    End;
  {$IFEND}
  {$IFEND}
 Except
 End;
End;

Function  Encodeb64Stream(Value       : TStream) : String;
{$IFNDEF FPC}
  {$IF DEFINED(OLDINDY)}
  Var
   vBuffer : TidBytes;
  {$IFEND}
{$ENDIF}
Begin
 Value.Position := 0;
 Result         := '';
 If Value.Size > 0 Then
  Begin
  {$IFDEF FPC}
   Result := TIdEncoderMIME.EncodeStream(Value);
  {$ELSE}
   {$IF DEFINED(OLDINDY)}
    Value.Position := 0;
    SetLength(vBuffer, Value.Size);
 //   {Wesley - Esse código não funciona com OldVersão 10.5.8. Da erro em runtime
 //    Value.Read(vBuffer, Value.Size);
 //    Result := TIdEncoderMIME.EncodeBytes(vBuffer);
 //   }
 //   //Esse Funciona. Tem que ver quem fez e pra que versão de indy fez a alteração. Vou colocar um try..except para evitar problemas
 //   Try
 //    Result := TIdEncoderMIME.EncodeStream(Value);
 //   Except
    Value.Read(vBuffer, Value.Size);
    Result := TIdEncoderMIME.EncodeBytes(vBuffer);
 //   End;
   {$ELSE}
    Result := TIdEncoderMIME.EncodeStream(Value);
   {$IFEND}
  {$ENDIF}
  End;
 Value.Position := 0;
End;

Function  aEncodeStrings(Value : String
                        {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
Begin
 Result := EncodeStrings(Value{$IFDEF FPC}, DatabaseCharSet{$ENDIF});
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

Function  Decodeb64Stream(Value : String) : TMemoryStream;
{$IFNDEF FPC}
  {$IF DEFINED(OLDINDY)}
  Var
   vBuffer : TidBytes;
  {$IFEND}
{$ENDIF}
Begin
 Result := TMemoryStream.Create;
 {$IFDEF FPC}
  TIdDecoderMIME.DecodeStream(Value, Result);
//  Result.SaveToFile('temp.dat');
 {$ELSE}
  {$IF DEFINED(OLDINDY)}
   vBuffer := TIdDecoderMIME.DecodeBytes(Value);
   If Length(vBuffer) > 0 Then
    Begin
//     Try
//      TIdDecoderMIME.DecodeStream(Value, Result);
//     Except
     Result.WriteBuffer(vBuffer, Length(vBuffer));
//     End;
    End;
  {$ELSE}
   TIdDecoderMIME.DecodeStream(Value, Result);
  {$IFEND}
  Result.Position := 0;
 {$ENDIF}
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
 Result               := TServerUtils.Result2JSON(WSResult); //EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF FPC}, csUndefined{$ENDIF});
End;

Function GetPairJSON(Status      : Integer;
                     MessageText : String;
                     Encoding    : TEncodeSelect = esUtf8) : String;
Var
 WSResult : TResultErro;
Begin
 WSResult.STATUS      := IntToStr(Status);
 WSResult.MessageText := MessageText;
 Result               := TServerUtils.Result2JSON(WSResult); //EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF FPC}, csUndefined{$ENDIF});
End;

end.


