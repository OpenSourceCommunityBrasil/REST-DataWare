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
  QuoteSpecials : Array[TQuotingType] Of String = ('', '()<>@,;:\"./', '()<>@,;:\"/[]?=', '()<>@,;:\"/[]?={} '#9);
  LF            = #10;
  CR            = #13;

 Function  EncodeStrings          (Value              : String
                                  {$IFDEF FPC};DatabaseCharSet          : TDatabaseCharSet{$ENDIF}) : String;
 Function  DecodeStrings          (Value              : String
                                  {$IFDEF FPC};DatabaseCharSet          : TDatabaseCharSet{$ENDIF}) : String;
 Function  EncodeStream           (Value              : TStream)        : String;
 Function  DecodeStream           (Value              : String)         : TMemoryStream;
 Function  BytesToString          (Const bin          : TRESTDWBytes)   : String;Overload;
 Function  BytesToString          (Const AValue       : TRESTDWBytes;
                                   Const AStartIndex  : Integer;
                                   Const ALength      : Integer = -1)   : String;Overload;
 Function  restdwLength           (Const ABuffer      : String;
                                   Const ALength      : Integer = -1;
                                   Const AIndex       : Integer = 1)    : Integer;Overload;
 Function  restdwLength           (Const ABuffer      : TRESTDWBytes;
                                   Const ALength      : Integer = -1;
                                   Const AIndex       : Integer = 0)    : Integer;Overload;
 Function  StringToBytes          (AStr               : String)         : TRESTDWBytes;
 Function  StreamToBytes          (Stream             : TMemoryStream)  : TRESTDWBytes;
 Function  StringToFieldType      (Const S            : String)         : Integer;
 Function  Escape_chars           (s                  : String)         : String;
 Function  Unescape_chars         (s                  : String)         : String;
 Function  HexToBookmark          (Value              : String)         : TRESTDWBytes;
 Function  BookmarkToHex          (Value              : TRESTDWBytes)   : String;
 Procedure CopyStringList         (Const Source,
                                   Dest               : TStringList);
 Function  RemoveBackslashCommands(Value              : String)          : String;
 Function  RESTDWFileExists       (sFile,
                                   BaseFilePath       : String)          : Boolean;
 Function  TravertalPathFind      (Value              : String)          : Boolean;
 Function  GetEventName           (Value              : String)          : String;
 Function  ExtractHeaderSubItem   (Const AHeaderLine,
                                   ASubItem           : String;
                                   QuotingType        : TQuotingType)    : String;
 Function  ReadLnFromStream       (AStream            : TStream;
                                   Var VLine          : String;
                                   AMaxLineLength     : Integer = -1)    : Boolean; Overload;
 Function  ReadLnFromStream       (AStream            : TStream;
                                   AMaxLineLength     : Integer = -1;
                                   AExceptionIfEOF    : Boolean = False) : String; Overload;

Implementation

Uses uRESTDWConsts;

Function ReadLnFromStream(AStream        : TStream;
                          Var VLine      : String;
                          AMaxLineLength : Integer = -1) : Boolean;
Const
 LBUFMAXSIZE = 2048;
Var
 LStringLen,
 LResultLen,
 LBufSize       : Integer;
 LBuf,
 LLine          : TRESTDWBytes;
 LStrmPos,
 LStrmSize      : TRESTDWStreamSize;
 LCrEncountered : Boolean;
 Function FindEOL(Const ABuf         : TRESTDWBytes;
                  Var VLineBufSize   : Integer;
                  Var VCrEncountered : Boolean) : Integer;
 Var
  i : Integer;
 Begin
  Result := VLineBufSize; //EOL not found => use all
  i := 0;
  While i < VLineBufSize Do
   Begin
    Case ABuf[i] Of
     Ord(LF) :
      Begin
       Result         := i;
       VCrEncountered := True;
       VLineBufSize   := i+1;
       Break;
      End;
     Ord(CR) :
      Begin
       Result := i;
       VCrEncountered := True;
       Inc(i);
       If (i < VLineBufSize)  And
          (ABuf[i] = Ord(LF)) Then
        VLineBufSize := i+1
       Else
        VLineBufSize := i;
       Break;
      End;
    End;
    Inc(i);
   End;
 End;
 Function ReadBytes(Const AStream : TStream;
                    Var   VBytes  : TRESTDWBytes;
                    Const ACount,
                    AOffset       : Integer) : Integer;
 Var
  LActual : Integer;
 Begin
  Assert(AStream <> Nil);
  Result := 0;
  If VBytes = Nil Then
   SetLength(VBytes, 0);
  LActual := ACount;
  If LActual < 0 Then
   LActual := AStream.Size - AStream.Position;
  If LActual = 0 Then Exit;
  If Length(VBytes) < (AOffset+LActual) Then
   SetLength(VBytes, AOffset+LActual);
  Assert(VBytes <> nil);
  Result := AStream.Read(VBytes[AOffset], LActual);
 End;
 Function restdwMin(Const AValueOne,
                    AValueTwo        : Int64) : Int64;
 Begin
  If AValueOne > AValueTwo Then
   Result := AValueTwo
  Else
  Result := AValueOne;
 End;
 Procedure CopyRESTDWBytes(Const ASource      : TRESTDWBytes;
                           Const ASourceIndex : Integer;
                           Var VDest          : TRESTDWBytes;
                           Const ADestIndex,
                           ALength            : Integer);
 Begin
  Assert(ASourceIndex >= 0);
  Assert((ASourceIndex+ALength) <= Length(ASource));
  Move  (ASource[ASourceIndex], VDest[ADestIndex], ALength);
 End;
Begin
 Assert(AStream <> Nil);
 VLine := '';
 SetLength(LLine, 0);
 If AMaxLineLength < 0 Then
  AMaxLineLength := MaxInt;
 LStrmPos := AStream.Position;
 LStrmSize := AStream.Size;
 If LStrmPos >= LStrmSize Then
  Begin
   Result := False;
   Exit;
  End;
 SetLength(LBuf, LBUFMAXSIZE);
 LCrEncountered := False;
 Repeat
  LBufSize := ReadBytes(AStream, LBuf, restdwMin(LStrmSize - LStrmPos, LBUFMAXSIZE), 0);
  If LBufSize < 1 Then
   Break;
  LStringLen := FindEOL(LBuf, LBufSize, LCrEncountered);
  Inc(LStrmPos, LBufSize);
  LResultLen := Length(VLine);
  If (LResultLen + LStringLen) > AMaxLineLength Then
   Begin
    LStringLen := AMaxLineLength - LResultLen;
    LCrEncountered := True;
    Dec(LStrmPos, LBufSize);
    Inc(LStrmPos, LStringLen);
   End;
  If LStringLen > 0 Then
   Begin
    LBufSize := Length(LLine);
    SetLength(LLine, LBufSize+LStringLen);
    CopyRESTDWBytes(LBuf, 0, LLine, LBufSize, LStringLen);
   End;
 Until (LStrmPos >= LStrmSize) or LCrEncountered;
 AStream.Position := LStrmPos;
 VLine := BytesToString(LLine, 0, -1);
 Result := True;
End;

Function restdwPos(Const Substr, S : String) : Integer;
Begin
 Result := Pos(Substr, S);
End;

Function restdwMax(Const AValueOne,
                   AValueTwo        : Int64) : Int64;
Begin
 If AValueOne < AValueTwo Then
  Result := AValueTwo
 Else
  Result := AValueOne;
End;

Function restdwMin(Const AValueOne,
                   AValueTwo        : Int64) : Int64;
Begin
 If AValueOne > AValueTwo Then
  Result := AValueTwo
 Else
 Result := AValueOne;
End;

Function restdwLength(Const ABuffer : String;
                      Const ALength : Integer = -1;
                      Const AIndex  : Integer = 1) : Integer;
Var
 LAvailable: Integer;
Begin
 Assert(AIndex >= 1);
 LAvailable := restdwMax(Length(ABuffer)-AIndex+1, 0);
 If ALength < 0 Then
  Result := LAvailable
 Else
  Result := restdwMin(LAvailable, ALength);
End;

Function restdwLength(Const ABuffer : TRESTDWBytes;
                      Const ALength : Integer = -1;
                      Const AIndex  : Integer = 0) : Integer;
Var
 LAvailable : Integer;
Begin
 Assert(AIndex >= 0);
 LAvailable := restdwMax(Length(ABuffer)-AIndex, 0);
 If ALength < 0 Then
  Result := LAvailable
 Else
  Result := restdwMin(LAvailable, ALength);
End;

Function restdwValueFromIndex(AStrings     : TStrings;
                              Const AIndex : Integer)  : String;
Var
 LTmp : String;
 LPos : Integer;
Begin
 Result := '';
 If AIndex >= 0 Then
  Begin
   LTmp := AStrings.Strings[AIndex];
   LPos := Pos('=', LTmp); {do not localize}
   If LPos > 0 Then
    Begin
     Result := Copy(LTmp, LPos+1, MaxInt);
     Exit;
    End;
  End;
End;

Function Fetch(Var AInput           : String;
               Const ADelim         : String  = '';
               Const ADelete        : Boolean = True;
               Const ACaseSensitive : Boolean = True) : String;{$IFDEF USE_INLINE}Inline;{$ENDIF}
Var
 LPos : Integer;
 Function FetchCaseInsensitive(Var AInput    : String;
                               Const ADelim  : String;
                               Const ADelete : Boolean) : String;
 Var
  LPos : Integer;
 Begin
  If ADelim = #0 Then
   LPos := Pos(ADelim, AInput)
  Else
   LPos := restdwPos(UpperCase(ADelim), UpperCase(AInput));
  If LPos = 0 Then
   Begin
    Result := AInput;
    if ADelete Then
     AInput := '';
   End
  Else
   Begin
    Result := Copy(AInput, 1, LPos - 1);
    If ADelete Then
     AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
   End;
 End;
Begin
 If ACaseSensitive Then
  Begin
   If ADelim = #0 Then
    LPos := Pos(ADelim, AInput)
   Else
    LPos := restdwPos(ADelim, AInput);
   If LPos = 0 Then
    Begin
     Result := AInput;
     If ADelete Then
      AInput := '';    {Do not Localize}
    End
   Else
    Begin
     Result := Copy(AInput, 1, LPos - 1);
     If ADelete Then
      AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
    End;
  End
 Else
  Result := FetchCaseInsensitive(AInput, ADelim, ADelete);
End;

Procedure SplitHeaderSubItems(AHeaderLine : String;
                              AItems      : TStrings;
                              QuotingType : TQuotingType);
Var
 LName,
 LValue,
 LSep    : String;
 LQuoted : Boolean;
 I       : Integer;
 Function TextStartsWith(Const S , SubS : String) : Boolean;
 Var
  LLen  : Integer;
  P1,
  P2    : PChar;
 Begin
  LLen := Length(SubS);
  Result := LLen <= Length(S);
  If Result then
   Begin
    P1 := PChar(S);
    P2 := PChar(SubS);
    Result := AnsiCompareText(Copy(S, 1, LLen), SubS) = 0;
   End;
 End;
 Function FetchQuotedString(Var vHeaderLine : String) : String;
 Begin
  Result := '';
  Delete(VHeaderLine, 1, 1);
  I := 1;
  While I <= Length(VHeaderLine) Do
   Begin
    If vHeaderLine[I] = '\' Then
     Begin
      If I < Length(VHeaderLine) Then
       Delete(VHeaderLine, I, 1);
     End
    Else If VHeaderLine[I] = '"' Then
     Begin
      Result := Copy(VHeaderLine, 1, I-1);
      VHeaderLine := Copy(VHeaderLine, I+1, MaxInt);
      Break;
     End;
    Inc(I);
   End;
  Fetch(VHeaderLine, ';');
 End;
 Function FindFirstOf(Const AFind,
                      AText           : String;
                      Const ALength   : Integer = -1;
                      Const AStartPos : Integer = 1) : Integer;
 Var
  I,
  LLength,
  LPos     : Integer;
 Begin
  Result := 0;
  If Length(AFind) > 0 then begin
    LLength := restdwLength(AText, ALength, AStartPos);
    if LLength > 0 then begin
      for I := 0 to LLength-1 do begin
        LPos := AStartPos + I;
        if restdwPos(AText[LPos], AFind) <> 0 then begin
          Result := LPos;
          Exit;
        end;
      end;
    end;
  end;
 End;

 Function CharRange(Const AMin,
                    AMax         : Char;
                    QuotingType  : TQuotingType) : String;
 Var
  I : Char;
 Begin
  SetLength(Result, Ord(AMax) - Ord(AMin) + 1);
  For i := AMin to AMax Do
   Result[Ord(i) - Ord(AMin) + 1] := i;
 End;
Begin
  Fetch(AHeaderLine, ';'); {do not localize}
  LSep := CharRange(#0, #32, QuotingType) + QuoteSpecials[QuotingType] + #127;
  while AHeaderLine <> '' do
  begin
    AHeaderLine := TrimLeft(AHeaderLine);
    if AHeaderLine = '' then begin
      Exit;
    end;
    LName := Trim(Fetch(AHeaderLine, '=')); {do not localize}
    AHeaderLine := TrimLeft(AHeaderLine);
    LQuoted := TextStartsWith(AHeaderLine, '"'); {do not localize}
    if LQuoted then
    begin
      LValue := FetchQuotedString(AHeaderLine);
    end else begin
      I := FindFirstOf(LSep, AHeaderLine);
      if I <> 0 then
      begin
        LValue := Copy(AHeaderLine, 1, I-1);
        if AHeaderLine[I] = ';' then begin {do not localize}
          Inc(I);
        end;
        Delete(AHeaderLine, 1, I-1);
      end else begin
        LValue := AHeaderLine;
        AHeaderLine := '';
      end;
    end;
    if (LName <> '') and ((LValue <> '') or LQuoted) then begin
      {$IFDEF USE_OBJECT_ARC}
      AItems.Add(TIdHeaderNameValueItem.Create(LName, LValue, LQuoted));
      {$ELSE}
      AItems.AddObject(LName + '=' + LValue, TObject(LQuoted));
      {$ENDIF}
    end;
  end;
end;

Function TextIsSame(Const A1, A2 : String) : Boolean;
Begin
 {$IFDEF DOTNET}
  Result := System.String.Compare(A1, A2, True) = 0;
 {$ELSE}
  Result := AnsiCompareText(A1, A2) = 0;
 {$ENDIF}
End;

Function InternalrestdwIndexOfName(AStrings             : TStrings;
                                   Const AStr           : String;
                                   Const ACaseSensitive : Boolean = False) : Integer;
Var
 I : Integer;
Begin
 Result := -1;
 For I := 0 To AStrings.Count - 1 Do
  Begin
   If ACaseSensitive Then
    Begin
     If AStrings.Names[I] = AStr Then
      Begin
       Result := I;
       Exit;
      End;
    End
   Else
    Begin
     If TextIsSame(AStrings.Names[I], AStr) Then
      Begin
       Result := I;
       Exit;
      End;
    End;
  End;
End;

Function restdwIndexOfName(AStrings             : TStrings;
                           Const AStr           : String;
                           Const ACaseSensitive : Boolean = False) : Integer;
Begin
 Result := InternalrestdwIndexOfName(AStrings, AStr, ACaseSensitive);
End;

Function ExtractHeaderSubItem(Const AHeaderLine,
                              ASubItem           : String;
                              QuotingType        : TQuotingType) : String;
Var
 LItems  : TStringList;
 I       : Integer;
Begin
 Result := '';
 LItems := TStringList.Create;
 Try
  SplitHeaderSubItems(AHeaderLine, LItems, QuotingType);
  I := restdwIndexOfName(LItems, ASubItem);
  If I <> -1 Then
  Result := restdwValueFromIndex(LItems, I);
 Finally
  LItems.Free;
 End;
End;

Function ReadLnFromStream(AStream         : TStream;
                          AMaxLineLength  : Integer = -1;
                          AExceptionIfEOF : Boolean = False) : String; overload;
Begin
 If (Not ReadLnFromStream(AStream, Result, AMaxLineLength)) and AExceptionIfEOF then
  Raise Exception.Create(Format(cStreamReadError, ['ReadLnFromStream', AStream.Position]));
end;

Function RemoveBackslashCommands(Value : String) : String;
Begin
 Result := StringReplace(Value, '../', '', [rfReplaceAll]);
 Result := StringReplace(Result, '..\', '', [rfReplaceAll]);
End;

Function TravertalPathFind(Value : String) : Boolean;
Begin
 Result := Pos('../', Value) > 0;
 If Not Result Then
  Result := Pos('..\', Value) > 0;
End;

Function GetEventName  (Value : String) : String;
Begin
 Result := Value;
 If Pos('.', Result) > 0 Then
  Result := Copy(Result, Pos('.', Result) + 1, Length(Result));
End;

Function RESTDWFileExists(sFile, BaseFilePath : String) : Boolean;
Var
 vTempFilename : String;
Begin
 vTempFilename := sFile;
 Result        := (Pos('.', vTempFilename) > 0);
 If Result Then
  Begin
   Result := FileExists(vTempFilename);
   If Not Result Then
    Result := FileExists(BaseFilePath + vTempFilename);
  End;
End;

Procedure CopyStringList(Const Source, Dest : TStringList);
Var
 I : Integer;
Begin
 If Assigned(Source) And Assigned(Dest) Then
  For I := 0 To Source.Count -1 Do
   Dest.Add(Source[I]);
End;

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

Function BytesToString(Const AValue      : TRESTDWBytes;
                       Const AStartIndex : Integer;
                       Const ALength: Integer = -1)      : String;
Var
 LLength : Integer;
 LBytes  : TRESTDWBytes;
Begin
 {$IFDEF STRING_IS_ANSI}
  LBytes := nil; // keep the compiler happy
 {$ENDIF}
 LLength := restdwLength(AValue, ALength, AStartIndex);
 If LLength > 0 Then
  Begin
   If (AStartIndex = 0)          And
      (LLength = Length(AValue)) Then
    LBytes := AValue
   Else
    LBytes := Copy(AValue, AStartIndex, LLength);
   SetString(Result, PAnsiChar(LBytes), Length(LBytes));
  End;
 Result := '';
End;

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
