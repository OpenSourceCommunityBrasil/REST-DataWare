unit uRESTDWTools;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

Uses
 {$IFDEF FPC}
 Classes,  SysUtils, uRESTDWBasicTypes, LConvEncoding, lazutf8, Db
 {$ELSE}
 Classes,  SysUtils, uRESTDWBasicTypes, Db
 {$IF Defined(RESTDWFMX)}
  , System.NetEncoding
 {$IFEND}
 {$ENDIF};

 Const
  B64Table      = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

 Function EncodeStrings    (Value     : String
                           {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
 Function DecodeStrings    (Value     : String
                           {$IFDEF FPC};DatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
 Function EncodeStream     (Value     : TStream)        : String;
 Function DecodeStream     (Value     : String)         : TMemoryStream;
 Function BytesToString    (Const bin : TRESTDWBytes)   : String;
 Function StringToBytes    (AStr      : String)         : TRESTDWBytes;
 Function StreamToBytes    (Stream    : TMemoryStream)  : TRESTDWBytes;
 Function StringToFieldType(Const S   : String)         : Integer;
 Function Escape_chars     (s         : String)         : String;
 Function Unescape_chars   (s         : String)         : String;
 Function HexToBookmark    (Value     : String)         : TRESTDWBytes;
 Function BookmarkToHex    (Value     : TRESTDWBytes)   : String;

Implementation

Uses uRESTDWConsts;

Function HexToBookmark(Value : String) : TRESTDWBytes;
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

Function BookmarkToHex(Value : TRESTDWBytes) : String;
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

Function Unescape_chars(s : String) : String;
 Function HexValue(C: Char): Byte;
 Begin
  Case C of
   '0'..'9':  Result := Byte(C) - Byte('0');
   'a'..'f':  Result := (Byte(C) - Byte('a')) + 10;
   'A'..'F':  Result := (Byte(C) - Byte('A')) + 10;
   Else raise Exception.Create('Illegal hexadecimal characters "' + C + '"');
  End;
 End;
Var
 C    : Char;
 I,
 ubuf : Integer;
Begin
 Result := '';
 I := InitStrPos;
 While I <= (Length(S) - FinalStrPos) Do
  Begin
   C := S[I];
   Inc(I);
   If C = '\' then
    Begin
     C := S[I];
     Inc(I);
     Case C of
      'b': Result := Result + #8;
      't': Result := Result + #9;
      'n': Result := Result + #10;
      'f': Result := Result + #12;
      'r': Result := Result + #13;
      'u': Begin
            If Not TryStrToInt('$' + Copy(S, I, 4), ubuf) Then
             Raise Exception.Create(format('Invalid unicode \u%s',[Copy(S, I, 4)]));
            Result := result + WideChar(ubuf);
            Inc(I, 4);
           End;
       Else Result := Result + C;
     End;
    End
   Else Result := Result + C;
  End;
End;

Function Escape_chars(s : String) : String;
Var
 b, c   : Char;
 i, len : Integer;
 sb, t  : String;
 Const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')', ' '];
 Function toHexString(c : char) : String;
 Begin
  Result := IntToHex(ord(c), 2);
 End;
Begin
 c      := #0;
 {$IFDEF FPC}
 b      := #0;
 i      := 0;
 {$ENDIF}
 len    := length(s);
 Result := '';
  //SetLength (s, len+4);
 t      := '';
 sb     := '';
 For  i := InitStrPos to len - FinalStrPos Do
  Begin
   b := c;
   c := s[i];
   Case (c) Of
    '\', '"' : Begin
                sb := sb + '\';
                sb := sb + c;
               End;
    '/' :      Begin
                If (b = '<') Then
                 sb := sb + '\';
                sb := sb + c;
               End;
    #8  :      Begin
                sb := sb + '\b';
               End;
    #9  :      Begin
                sb := sb + '\t';
               End;
    #10 :      Begin
                sb := sb + '\n';
               End;
    #12 :      Begin
                sb := sb + '\f';
               End;
    #13 :      Begin
                sb := sb + '\r';
               End;
    Else       Begin
                If (Not (c in NoConversion)) Then
                 Begin
                    t := '000' + toHexString(c);
                    sb := sb + '\u' + copy (t, Length(t) -3,4);
                 End
                Else
                 sb := sb + c;
               End;
   End;
  End;
 Result := sb;
End;

Function GetFieldTypeB(FieldType : String) : TFieldType;
Var
 vFieldType : String;
Begin
 Result     := ftString;
 vFieldType := Uppercase(FieldType);
 If vFieldType      = Uppercase('ftUnknown')         Then
  Result := ftUnknown
 Else If vFieldType = Uppercase('ftString')          Then
  Result := ftString
 Else If vFieldType = Uppercase('ftSmallint')        Then
  Result := ftSmallint
 Else If vFieldType = Uppercase('ftInteger')         Then
  Result := ftInteger
 Else If vFieldType = Uppercase('ftWord')            Then
  Result := ftWord
 Else If vFieldType = Uppercase('ftBoolean')         Then
  Result := ftBoolean
 Else If vFieldType = Uppercase('ftFloat')           Then
  Result := ftFloat
 Else If vFieldType = Uppercase('ftCurrency')        Then
  Result := ftCurrency
 Else If vFieldType = Uppercase('ftBCD')             Then
  Result := ftFloat
 Else If vFieldType = Uppercase('ftDate')            Then
  Result := ftDate
 Else If vFieldType = Uppercase('ftTime')            Then
  Result := ftTime
 Else If vFieldType = Uppercase('ftDateTime')        Then
  Result := ftDateTime
 Else If vFieldType = Uppercase('ftBytes')           Then
  Result := ftBytes
 Else If vFieldType = Uppercase('ftVarBytes')        Then
  Result := ftVarBytes
 Else If vFieldType = Uppercase('ftAutoInc')         Then
  Result := ftAutoInc
 Else If vFieldType = Uppercase('ftBlob')            Then
  Result := ftBlob
 Else If vFieldType = Uppercase('ftMemo')            Then
  Result := ftMemo
{$IFNDEF FPC}
 {$if CompilerVersion < 21} // delphi 7   compatibilidade enter Sever no XE e Client no D7
 Else If vFieldType = Uppercase('ftWideMemo')        Then
  Result := ftMemo
{$IFEND}
{$ENDIF}
 Else If vFieldType = Uppercase('ftGraphic')         Then
  Result := ftGraphic
 Else If vFieldType = Uppercase('ftFmtMemo')         Then
  Result := ftFmtMemo
 Else If vFieldType = Uppercase('ftParadoxOle')      Then
  Result := ftParadoxOle
 Else If vFieldType = Uppercase('ftDBaseOle')        Then
  Result := ftDBaseOle
 Else If vFieldType = Uppercase('ftTypedBinary')     Then
  Result := ftTypedBinary
 Else If vFieldType = Uppercase('ftCursor')          Then
  Result := ftCursor
 Else If vFieldType = Uppercase('ftFixedChar')       Then
  Result := ftFixedChar
 Else If vFieldType = Uppercase('ftWideString')      Then
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := ftWideString
   {$ELSE}
    Result := ftString
   {$IFEND}
  {$ELSE}
   Result := ftString
  {$ENDIF}
 Else If vFieldType = Uppercase('ftLargeint')        Then
  Result := ftLargeint
 Else If vFieldType = Uppercase('ftADT')             Then
  Result := ftADT
 Else If vFieldType = Uppercase('ftArray')           Then
  Result := ftArray
 Else If vFieldType = Uppercase('ftReference')       Then
  Result := ftReference
 Else If vFieldType = Uppercase('ftDataSet')         Then
  Result := ftDataSet
 Else If vFieldType = Uppercase('ftOraBlob')         Then
  Result := ftOraBlob
 Else If vFieldType = Uppercase('ftOraClob')         Then
  Result := ftOraClob
 Else If vFieldType = Uppercase('ftVariant')         Then
  Result := ftVariant
 Else If vFieldType = Uppercase('ftInterface')       Then
  Result := ftInterface
 Else If vFieldType = Uppercase('ftIDispatch')       Then
  Result := ftIDispatch
 Else If vFieldType = Uppercase('ftGuid')            Then
  Result := ftGuid
 Else If vFieldType = Uppercase('ftTimeStamp')       Then
  Begin
  {$IFNDEF FPC}
   Result := ftTimeStamp;
  {$ELSE}
   Result := ftDateTime;
  {$ENDIF}
  End
 Else If vFieldType = Uppercase('ftSingle')       Then
  Begin
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := ftSingle;
   {$ELSE}
    Result := ftFloat;
   {$IFEND}
  {$ELSE}
   Result := ftFloat;
  {$ENDIF}
  End
 Else If vFieldType = Uppercase('ftFMTBcd')          Then
   Result := ftFloat
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
    Else If vFieldType = Uppercase('ftFixedWideChar')   Then
     Result := ftFixedWideChar
    Else If vFieldType = Uppercase('ftWideMemo')        Then
     Result := ftWideMemo
    Else If vFieldType = Uppercase('ftOraTimeStamp')    Then
     Result := ftOraTimeStamp
    Else If vFieldType = Uppercase('ftOraInterval')     Then
     Result := ftOraInterval
    Else If vFieldType = Uppercase('ftLongWord')        Then
     Result := ftLongWord
    Else If vFieldType = Uppercase('ftShortint')        Then
     Result := ftShortint
    Else If vFieldType = Uppercase('ftByte')            Then
     Result := ftByte
    Else If vFieldType = Uppercase('ftExtended')        Then
     Result := ftFloat
    Else If vFieldType = Uppercase('ftConnection')      Then
     Result := ftConnection
    Else If vFieldType = Uppercase('ftParams')          Then
     Result := ftParams
    Else If vFieldType = Uppercase('ftStream')          Then
     Result := ftStream
    Else If vFieldType = Uppercase('ftTimeStampOffset') Then
     Result := ftTimeStampOffset
    Else If vFieldType = Uppercase('ftObject')          Then
     Result := ftObject
   {$IFEND}
  (* {$if CompilerVersion =15}
   Else If vFieldType = Uppercase('ftWideMemo')   Then
     Result := ftMemo
   {$IFEND}
   *)
   {$ENDIF};
End;

Function StringToFieldType(Const S : String): Integer;
Begin
 If not IdentToInt(S, Result, FieldTypeIdents) then
  Result := Integer(GetFieldTypeB(S))
 Else
  Result := Integer(GetFieldTypeB(S));
 If TFieldType(Result) = ftWideString Then
  Result := Integer(ftString);
End;

Function StreamToBytes(Stream : TMemoryStream) : TRESTDWBytes;
Begin
 Try
  Stream.Position := 0;
  SetLength  (Result, Stream.Size);
  Stream.Read(Result[0], Stream.Size);
 Finally
 End;
end;

Function StringToBytes(AStr : String): TRESTDWBytes;
begin
 SetLength(Result, 0);
 If AStr <> '' Then
  Begin
   {$IF Defined(HAS_UTF8)}
    Result := TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
   {$ELSE}
    {$IFDEF FPC}
     Result := TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
    {$ELSE}
     {$IF CompilerVersion < 25}
      Move(Pointer(@AStr[InitStrPos])^, Result, Length(AStr));
     {$ELSE}
      Result :=  TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
     {$IFEND}
    {$ENDIF}
   {$IFEND}
  End;
end;

Function BytesToString(Const bin : TRESTDWBytes) : String;
Const HexSymbols = '0123456789ABCDEF';
Var
 i : Integer;
Begin
 SetLength(Result, 2*Length(bin));
 For i :=  0 To Length(bin)-1 Do
  Begin
   Result[1 + 2*i + 0] := HexSymbols[1 + bin[i] shr 4];
   Result[1 + 2*i + 1] := HexSymbols[1 + bin[i] and $0F];
  End;
End;

Function EncodeStream (Value : TStream) : String;
Var
 outstream : TStringStream;
Begin
 Result         := '';
 Value.Position := 0;
 If Value.Size > 0 Then
  Begin
   outstream := TStringStream.Create('');
   Try
    outstream.CopyFrom(Value, Value.Size);
    outstream.Position := 0;
    Result := EncodeStrings(outstream.Datastring{$IFDEF FPC}, csUndefined{$ENDIF});
   Finally
    FreeAndNil(outstream);
   End;
  End;
 Value.Position := 0;
End;

Function DecodeStream(Value : String) : TMemoryStream;
Var
 outstream : TStringStream;
Begin
 Result := TMemoryStream.Create;
 outstream := TStringStream.Create(DecodeStrings(Value{$IFDEF FPC}, csUndefined{$ENDIF}));
 Try
  outstream.Position := 0;
  Result.CopyFrom(outstream, outstream.Size);
  Result.Position := 0;
 Finally
  FreeAndNil(outstream);
 End;
End;

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

Function Decode64(const S: string): string;
Var
 sa : String;
{$IF Defined(RESTDWFMX)}
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
   SA := S;
   If Pos(sLineBreak, SA) > 0 Then
    SA := StringReplace(SA, sLineBreak, '', [rfReplaceAll]);
   Result := Base64Decode(SA);
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

Function Base64Encode(const S: string): string;
Var
 InBuf  : array[0..2] of Byte;
 OutBuf : array[0..3] of Char;
 iI     : Integer;
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

Function Encode64(const S: string) : String;
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
   Result := Base64Encode(S);
  {$IFEND}
 {$ENDIF}
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

end.
