Unit uRESTDWMemStringConversions;
{$I uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFDEF FPC}
 {$MODE Delphi}
 {$ASMMode Intel}
{$ENDIF}

Interface
Uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  {$ELSE ~HAS_UNITSCOPE}
  Classes,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase,
  uRESTDWPrototypes;
Type
  EJclStringConversionError = Class(EJclError);
  EJclUnexpectedEOSequenceError = Class (EJclStringConversionError)
  Public
    Constructor Create;
  End;
Type
  TJclStreamGetNextCharFunc = Function(S: TStream; out Ch: UCS4): Boolean;
  TJclStreamSkipCharsFunc = Function(S: TStream; Var NbSeq: SizeInt): Boolean;
  TJclStreamSetNextCharFunc = Function(S: TStream; Ch: UCS4): Boolean;
Function UTF8SetNextChar(Var S: TUTF8String; Var StrPos: SizeInt; Ch: UCS4): Boolean;
Function UTF8SetNextBuffer(Var S: TUTF8String; Var StrPos: SizeInt; Const Buffer: TUCS4Array; Var Start: SizeInt; Count: SizeInt): SizeInt;
Function UTF8SetNextCharToStream(S: TStream; Ch: UCS4): Boolean;
Function UTF8SetNextBufferToStream(S: TStream; Const Buffer: TUCS4Array; Var Start: SizeInt; Count: SizeInt): SizeInt;
Function AnsiSkipChars(Const S: DWString; Var StrPos: SizeInt; Var NbSeq: SizeInt): Boolean;
Function AnsiSkipCharsFromStream(S: TStream; Var NbSeq: SizeInt): Boolean;
Function StringSkipChars(Const S: string; Var StrPos: SizeInt; Var NbSeq: SizeInt): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
// one shot conversions between DWString and others
Function DWStringToUTF16(Const S: DWString): TUTF16String; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
Function UTF16ToAnsiString(Const S: TUTF16String): DWString; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
// one shot conversions between string and others
Function StringToUTF16(Const S: string): TUTF16String; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
Function UTF16ToString(Const S: TUTF16String): string; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
Function TryStringToUTF16(Const S: string; out D: TUTF16String): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
Function TryUTF16ToString(Const S: TUTF16String; out D: string): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
Function UCS4ToUTF8(Const S: TUCS4Array): TUTF8String;
// indexed conversions
Function UTF8CharCount(Const S: TUTF8String): SizeInt;
Function UTF16CharCount(Const S: TUTF16String): SizeInt;
Function UCS2CharCount(Const S: TUCS2String): SizeInt;
Function UCS4CharCount(Const S: TUCS4Array): SizeInt;
// returns False if string is too small
// if UNICODE_SILENT_FAILURE is not defined and an invalid UTFX sequence is detected, an exception is raised
// returns True on success and Value contains UCS4 character that was read
Function UCS4ToWideChar(Value: UCS4): WideChar;
Function WideCharToUCS4(Value: WideChar): UCS4;
Implementation
Uses
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemResources;
Const MB_ERR_INVALID_CHARS = 8;
Constructor EJclUnexpectedEOSequenceError.Create;
Begin
  Inherited CreateRes(@RsEUnexpectedEOSeq);
End;
Function StreamReadByte(S: TStream; out B: Byte): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Begin
  B := 0;
  Result := S.Read(B, SizeOf(B)) = SizeOf(B);
End;
Function StreamWriteByte(S: TStream; B: Byte): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Begin
  Result := S.Write(B, SizeOf(B)) = SizeOf(B);
End;
Function StreamReadWord(S: TStream; out W: Word): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Begin
  W := 0;
  Result := S.Read(W, SizeOf(W)) = SizeOf(W);
End;
Function StreamWriteWord(S: TStream; W: Word): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
Begin
  Result := S.Write(W, SizeOf(W)) = SizeOf(W);
End;
Procedure FlagInvalidSequence(Var StrPos: SizeInt; Increment: SizeInt); overload;
Begin
  {$IFDEF UNICODE_SILENT_FAILURE}
  Inc(StrPos, Increment);
  {$ELSE ~UNICODE_SILENT_FAILURE}
  StrPos := -1;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
End;
Procedure FlagInvalidSequence(out Ch: UCS4); overload;
Begin
  {$IFDEF UNICODE_SILENT_FAILURE}
  Ch := UCS4ReplacementCharacter;
  {$ELSE ~UNICODE_SILENT_FAILURE}
  raise EJclUnexpectedEOSequenceError.Create;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
End;
Procedure FlagInvalidSequence; overload;
Begin
  {$IFNDEF UNICODE_SILENT_FAILURE}
  raise EJclUnexpectedEOSequenceError.Create;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
End;
Function UTF8GetNextCharFromStream(S: TStream; out Ch: UCS4): Boolean;
Var
  B: Byte;
Begin
  Result := StreamReadByte(S,B);
  If Result Then
  Begin
    Ch := UCS4(B);
    Case Ch Of
      $00..$7F: ;
        // 1 byte to read
        // nothing to do
      $C0..$DF:
        Begin
          // 2 bytes to read
          Result := StreamReadByte(S,B);
          If Result Then
          Begin
            If (B and $C0) = $80 Then
              Ch := ((Ch and $1F) shl 6) or (B and $3F)
            Else
              FlagInvalidSequence(Ch);
          End;
        End;
      $E0..$EF:
        Begin
          // 3 bytes to read
          Result := StreamReadByte(S,B);
          If Result Then
          Begin
            If (B and $C0) = $80 Then
            Begin
              Ch := ((Ch and $0F) shl 12) or ((B and $3F) shl 6);
              Result := StreamReadByte(S,B);
              If Result Then
              Begin
                If (B and $C0) = $80 Then
                  Ch := Ch or (B and $3F)
                Else
                  FlagInvalidSequence(Ch);
              End;
            End
            Else
              FlagInvalidSequence(Ch);
          End;
        End;
      $F0..$F7:
        Begin
          // 4 bytes to read
          Result := StreamReadByte(S,B);
          If Result Then
          Begin
            If (B and $C0) = $80 Then
            Begin
              Ch := ((Ch and $07) shl 18) or ((B and $3F) shl 12);
              Result := StreamReadByte(S,B);
              If Result Then
              Begin
                If (B and $C0) = $80 Then
                Begin
                  Ch := Ch or ((B and $3F) shl 6);
                  Result := StreamReadByte(S,B);
                  If Result Then
                  Begin
                    If (B and $C0) = $80 Then
                      Ch := Ch or (B and $3F)
                    Else
                      FlagInvalidSequence(Ch);
                  End;
                End
                Else
                  FlagInvalidSequence(Ch);
              End;
            End
            Else
              FlagInvalidSequence(Ch);
          End;
        End;
      $F8..$FB:
        Begin
          // 5 bytes to read
          Result := StreamReadByte(S,B);
          If Result Then
          Begin
            If (B and $C0) = $80 Then
            Begin
              Ch := ((Ch and $03) shl 24) or ((B and $3F) shl 18);
              Result := StreamReadByte(S,B);
              If Result Then
              Begin
                If (B and $C0) = $80 Then
                Begin
                  Ch := Ch or ((B and $3F) shl 12);
                  Result := StreamReadByte(S,B);
                  If Result Then
                  Begin
                    If (B and $C0) = $80 Then
                    Begin
                      Ch := Ch or ((B and $3F) shl 6);
                      Result := StreamReadByte(S,B);
                      If Result Then
                      Begin
                        If (B and $C0) = $80 Then
                          Ch := Ch or (B and $3F)
                        Else
                          FlagInvalidSequence(Ch);
                      End;
                    End
                    Else
                      FlagInvalidSequence(Ch);
                  End;
                End
                Else
                  FlagInvalidSequence(Ch);
              End;
            End
            Else
              FlagInvalidSequence(Ch);
          End;
        End;
      $FC..$FD:
        Begin
          // 6 bytes to read
          Result := StreamReadByte(S,B);
          If Result Then
          Begin
            If (B and $C0) = $80 Then
            Begin
              Ch := ((Ch and $01) shl 30) or ((B and $3F) shl 24);
              Result := StreamReadByte(S,B);
              If Result Then
              Begin
                If (B and $C0) = $80 Then
                Begin
                  Ch := Ch or ((B and $3F) shl 18);
                  Result := StreamReadByte(S,B);
                  If Result Then
                  Begin
                    If (B and $C0) = $80 Then
                    Begin
                      Ch := Ch or ((B and $3F) shl 12);
                      Result := StreamReadByte(S,B);
                      If Result Then
                      Begin
                        If (B and $C0) = $80 Then
                        Begin
                          Ch := Ch or ((B and $3F) shl 6);
                          Result := StreamReadByte(S,B);
                          If Result Then
                          Begin
                            If (B and $C0) = $80 Then
                              Ch := Ch or (B and $3F)
                            Else
                              FlagInvalidSequence(Ch);
                          End;
                        End
                        Else
                          FlagInvalidSequence(Ch);
                      End;
                    End
                    Else
                      FlagInvalidSequence(Ch);
                  End;
                End
                Else
                  FlagInvalidSequence(Ch);
              End;
            End
            Else
              FlagInvalidSequence(Ch);
          End;
        End;
    Else
      FlagInvalidSequence(Ch);
    End;
  End;
End;
Function UTF8GetNextBufferFromStream(S: TStream; Var Buffer: TUCS4Array; Var Start: SizeInt; Count: SizeInt): SizeInt;
Var
  B: Byte;
  Ch: UCS4;
  ReadSuccess: Boolean;
Begin
  Result := 0;
  ReadSuccess := True;
  While ReadSuccess and (Count > 0) Do
  Begin
    If StreamReadByte(S,B) Then
    Begin
      Ch := UCS4(B);
      Case Ch Of
        $00..$7F: ;
          // 1 byte to read
          // nothing to do
        $C0..$DF:
          Begin
            // 2 bytes to read
            If StreamReadByte(S,B) Then
            Begin
              If (B and $C0) = $80 Then
                Ch := ((Ch and $1F) shl 6) or (B and $3F)
              Else
                FlagInvalidSequence(Ch);
            End
            Else
              ReadSuccess := False;
          End;
        $E0..$EF:
          Begin
            // 3 bytes to read
            If StreamReadByte(S,B) Then
            Begin
              If (B and $C0) = $80 Then
              Begin
                Ch := ((Ch and $0F) shl 12) or ((B and $3F) shl 6);
                If StreamReadByte(S,B) Then
                Begin
                  If (B and $C0) = $80 Then
                    Ch := Ch or (B and $3F)
                  Else
                    FlagInvalidSequence(Ch);
                End
                Else
                  ReadSuccess := False;
              End
              Else
                FlagInvalidSequence(Ch);
            End
            Else
              ReadSuccess := False;
          End;
        $F0..$F7:
          Begin
            // 4 bytes to read
            If StreamReadByte(S,B) Then
            Begin
              If (B and $C0) = $80 Then
              Begin
                Ch := ((Ch and $07) shl 18) or ((B and $3F) shl 12);
                If StreamReadByte(S,B) Then
                Begin
                  If (B and $C0) = $80 Then
                  Begin
                    Ch := Ch or ((B and $3F) shl 6);
                    If StreamReadByte(S,B) Then
                    Begin
                      If (B and $C0) = $80 Then
                        Ch := Ch or (B and $3F)
                      Else
                        FlagInvalidSequence(Ch);
                    End
                    Else
                      ReadSuccess := False;
                  End
                  Else
                    FlagInvalidSequence(Ch);
                End
                Else
                  ReadSuccess := False;
              End
              Else
                FlagInvalidSequence(Ch);
            End
            Else
              ReadSuccess := False;
          End;
        $F8..$FB:
          Begin
            // 5 bytes to read
            If StreamReadByte(S,B) Then
            Begin
              If (B and $C0) = $80 Then
              Begin
                Ch := ((Ch and $03) shl 24) or ((B and $3F) shl 18);
                If StreamReadByte(S,B) Then
                Begin
                  If (B and $C0) = $80 Then
                  Begin
                    Ch := Ch or ((B and $3F) shl 12);
                    If StreamReadByte(S,B) Then
                    Begin
                      If (B and $C0) = $80 Then
                      Begin
                        Ch := Ch or ((B and $3F) shl 6);
                        If StreamReadByte(S,B) Then
                        Begin
                          If (B and $C0) = $80 Then
                            Ch := Ch or (B and $3F)
                          Else
                            FlagInvalidSequence(Ch);
                        End
                        Else
                          ReadSuccess := False;
                      End
                      Else
                        FlagInvalidSequence(Ch);
                    End
                    Else
                      ReadSuccess := False;
                  End
                  Else
                    FlagInvalidSequence(Ch);
                End
                Else
                  ReadSuccess := False;
              End
              Else
                FlagInvalidSequence(Ch);
            End
            Else
              ReadSuccess := False;
          End;
        $FC..$FD:
          Begin
            // 6 bytes to read
            If StreamReadByte(S,B) Then
            Begin
              If (B and $C0) = $80 Then
              Begin
                Ch := ((Ch and $01) shl 30) or ((B and $3F) shl 24);
                If StreamReadByte(S,B) Then
                Begin
                  If (B and $C0) = $80 Then
                  Begin
                    Ch := Ch or ((B and $3F) shl 18);
                    If StreamReadByte(S,B) Then
                    Begin
                      If (B and $C0) = $80 Then
                      Begin
                        Ch := Ch or ((B and $3F) shl 12);
                        If StreamReadByte(S,B) Then
                        Begin
                          If (B and $C0) = $80 Then
                          Begin
                            Ch := Ch or ((B and $3F) shl 6);
                            If StreamReadByte(S,B) Then
                            Begin
                              If (B and $C0) = $80 Then
                                Ch := Ch or (B and $3F)
                              Else
                                FlagInvalidSequence(Ch);
                            End
                            Else
                              ReadSuccess := False;
                          End
                          Else
                            FlagInvalidSequence(Ch);
                        End
                        Else
                          ReadSuccess := False;
                      End
                      Else
                        FlagInvalidSequence(Ch);
                    End
                    Else
                      ReadSuccess := False;
                  End
                  Else
                    FlagInvalidSequence(Ch);
                End
                Else
                  ReadSuccess := False;
              End
              Else
                FlagInvalidSequence(Ch);
            End
            Else
              ReadSuccess := False;
          End
      Else
        FlagInvalidSequence(Ch);
      End;
      If ReadSuccess Then
      Begin
        Buffer[Start] := Ch;
        Inc(Start);
        Inc(Result);
      End;
    End
    Else
      ReadSuccess := False;
    Dec(Count);
  End;
End;
// returns False if String is too small
// if UNICODE_SILENT_FAILURE is not defined StrPos is set to -1 on error (invalid UTF8 sequence)
// StrPos will be incremented by the number of ansi chars that were skipped
// On return, NbSeq contains the number of UTF8 sequences that were skipped
Function UTF8SkipChars(Const S: TUTF8String; Var StrPos: SizeInt; Var NbSeq: SizeInt): Boolean;
Var
  StrLength: SizeInt;
  Ch: UCS4;
  Index: SizeInt;
Begin
  Result := True;
  StrLength := Length(S);
  Index := 0;
  While (Index < NbSeq) and (StrPos > 0) Do
  Begin
    Ch := UCS4(S[StrPos]);
    Case Ch Of
      $00..$7F:
        // 1 byte to skip
        Inc(StrPos);
      $C0..$DF:
        // 2 bytes to skip
        If (StrPos >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) Then
          FlagInvalidSequence(StrPos, 1)
        Else
          Inc(StrPos, 2);
      $E0..$EF:
        // 3 bytes to skip
        If ((StrPos + 1) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) Then
          FlagInvalidSequence(StrPos, 1)
        Else
        If (UCS4(S[StrPos + 2]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 2)
        Else
          Inc(StrPos, 3);
      $F0..$F7:
        // 4 bytes to skip
        If ((StrPos + 2) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) Then
          FlagInvalidSequence(StrPos, 1)
        Else
        If (UCS4(S[StrPos + 2]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 2)
        Else
        If (UCS4(S[StrPos + 3]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 3)
        Else
          Inc(StrPos, 4);
      $F8..$FB:
        // 5 bytes to skip
        If ((StrPos + 3) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) Then
          FlagInvalidSequence(StrPos, 1)
        Else
        If (UCS4(S[StrPos + 2]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 2)
        Else
        If (UCS4(S[StrPos + 3]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 3)
        Else
        If (UCS4(S[StrPos + 4]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 4)
        Else
          Inc(StrPos, 5);
      $FC..$FD:
        // 6 bytes to skip
        If ((StrPos + 4) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) Then
          FlagInvalidSequence(StrPos, 1)
        Else
        If (UCS4(S[StrPos + 2]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 2)
        Else
        If (UCS4(S[StrPos + 3]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 3)
        Else
        If (UCS4(S[StrPos + 4]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 4)
        Else
        If (UCS4(S[StrPos + 5]) and $C0) <> $80 Then
          FlagInvalidSequence(StrPos, 5)
        Else
          Inc(StrPos, 6);
    Else
      FlagInvalidSequence(StrPos, 1);
    End;
    If StrPos <> -1 Then
      Inc(Index);
    If (StrPos > StrLength) and (Index < NbSeq) Then
    Begin
      Result := False;
      Break;
    End;
  End;
  NbSeq := Index;
End;
Function UTF8SkipCharsFromStream(S: TStream; Var NbSeq: SizeInt): Boolean;
Var
  B: Byte;
  Index: SizeInt;
Begin
  Index := 0;
  While (Index < NbSeq) Do
  Begin
    Result := StreamReadByte(S, B);
    If not Result Then
      Break;
    Case B Of
      $00..$7F: ;
        // 1 byte to skip
        // nothing to do
      $C0..$DF:
        // 2 bytes to skip
        Begin
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
        End;
      $E0..$EF:
        // 3 bytes to skip
        Begin
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
        End;
      $F0..$F7:
        // 4 bytes to skip
        Begin
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
        End;
      $F8..$FB:
        // 5 bytes to skip
        Begin
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
        End;
      $FC..$FD:
        // 6 bytes to skip
        Begin
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          If not Result Then
            Break;
          If (B and $C0) <> $80 Then
            FlagInvalidSequence;
        End;
    Else
      FlagInvalidSequence;
    End;
    Inc(Index);
  End;
  Result := Index = NbSeq;
  NbSeq := Index;
End;
// returns False on error:
//    - if an UCS4 character cannot be stored to an UTF-8 string:
//        - if UNICODE_SILENT_FAILURE is defined, ReplacementCharacter is added
//        - if UNICODE_SILENT_FAILURE is not defined, StrPos is set to -1
//    - StrPos > -1 flags string being too small, caller is responsible for allocating space
// StrPos will be incremented by the number of chars that were written
Function UTF8SetNextChar(Var S: TUTF8String; Var StrPos: SizeInt; Ch: UCS4): Boolean;
Var
  StrLength: SizeInt;
Begin
  StrLength := Length(S);
  If Ch <= $7F Then
  Begin
    // 7 bits to store
    Result := (StrPos > 0) and (StrPos <= StrLength);
    If Result Then
    Begin
      PDWString(@S[StrPos])^ := DWChar(Ch);
      Inc(StrPos);
    End;
  End
  Else
  If Ch <= $7FF Then
  Begin
    // 11 bits to store
    Result := (StrPos > 0) and (StrPos < StrLength);
    If Result Then
    Begin
      PDWString(@S[StrPos])^ := DWChar($C0 or (Ch shr 6));  // 5 bits
      PDWString(@S[StrPos + 1])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 2);
    End;
  End
  Else
  If Ch <= $FFFF Then
  Begin
    // 16 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 1));
    If Result Then
    Begin
      PDWString(@S[StrPos])^ := DWChar($E0 or (Ch shr 12)); // 4 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 3);
    End;
  End
  Else
  If Ch <= $1FFFFF Then
  Begin
    // 21 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 2));
    If Result Then
    Begin
      PDWString(@S[StrPos])^ := DWChar($F0 or (Ch shr 18)); // 3 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 3])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 4);
    End;
  End
  Else
  If Ch <= $3FFFFFF Then
  Begin
    // 26 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 2));
    If Result Then
    Begin
      PDWString(@S[StrPos])^ := DWChar($F8 or (Ch shr 24)); // 2 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 4])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 5);
    End;
  End
  Else
  If Ch <= MaximumUCS4 Then
  Begin
    // 31 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 3));
    If Result Then
    Begin
      PDWString(@S[StrPos])^     := DWChar($FC or (Ch shr 30)); // 1 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 24) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 4])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 5])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 6);
    End;
  End
  Else
  Begin
    {$IFDEF UNICODE_SILENT_FAILURE}
    // add ReplacementCharacter
    Result := (StrPos > 0) and (StrPos < (StrLength - 1));
    If Result Then
    Begin
      S[StrPos] := DWChar($E0 or (UCS4ReplacementCharacter shr 12)); // 4 bits
      S[StrPos + 1] := DWChar(((UCS4ReplacementCharacter shr 6) and $3F) or $80); // 6 bits
      S[StrPos + 2] := DWChar((UCS4ReplacementCharacter and $3F) or $80); // 6 bits
      Inc(StrPos, 3);
    End;
    {$ELSE ~UNICODE_SILENT_FAILURE}
    StrPos := -1;
    Result := False;
    {$ENDIF ~UNICODE_SILENT_FAILURE}
  End;
End;
Function UTF8SetNextBuffer(Var S: TUTF8String; Var StrPos: SizeInt; Const Buffer: TUCS4Array; Var Start: SizeInt; Count: SizeInt): SizeInt;
Var
  StrLength: SizeInt;
  Ch: UCS4;
  Success: Boolean;
Begin
  StrLength := Length(S);
  Success := True;
  Result := 0;
  While Success and (Count > 0) Do
  Begin
    Ch := Buffer[Start];
    If Ch <= $7F Then
    Begin
      // 7 bits to store
      If (StrPos > 0) and (StrPos <= StrLength) Then
      Begin
        PDWString(@S[StrPos])^ := DWChar(Ch);
        Inc(StrPos);
      End
      Else
        Success := False;
    End
    Else
    If Ch <= $7FF Then
    Begin
      // 11 bits to store
      If (StrPos > 0) and (StrPos < StrLength) Then
      Begin
        PDWString(@S[StrPos])^ := DWChar($C0 or (Ch shr 6));  // 5 bits
        PDWString(@S[StrPos + 1])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 2);
      End
      Else
        Success := False;
    End
    Else
    If Ch <= $FFFF Then
    Begin
      // 16 bits to store
      If (StrPos > 0) and (StrPos < (StrLength - 1)) Then
      Begin
        PDWString(@S[StrPos])^ := DWChar($E0 or (Ch shr 12)); // 4 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 3);
      End
      Else
        Success := False;
    End
    Else
    If Ch <= $1FFFFF Then
    Begin
      // 21 bits to store
      If (StrPos > 0) and (StrPos < (StrLength - 2)) Then
      Begin
        PDWString(@S[StrPos])^ := DWChar($F0 or (Ch shr 18)); // 3 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 3])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 4);
      End
      Else
        Success := False;
    End
    Else
    If Ch <= $3FFFFFF Then
    Begin
      // 26 bits to store
      If (StrPos > 0) and (StrPos < (StrLength - 2)) Then
      Begin
        PDWString(@S[StrPos])^     := DWChar($F8 or (Ch shr 24)); // 2 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 4])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 5);
      End
      Else
        Success := False;
    End
    Else
    If Ch <= MaximumUCS4 Then
    Begin
      // 31 bits to store
      If (StrPos > 0) and (StrPos < (StrLength - 3)) Then
      Begin
        PDWString(@S[StrPos])^     := DWChar($FC or (Ch shr 30)); // 1 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 24) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 4])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 5])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 6);
      End
      Else
        Success := False;
    End
    Else
    Begin
      {$IFDEF UNICODE_SILENT_FAILURE}
      // add ReplacementCharacter
      If (StrPos > 0) and (StrPos < (StrLength - 1)) Then
      Begin
        S[StrPos] := DWChar($E0 or (UCS4ReplacementCharacter shr 12)); // 4 bits
        S[StrPos + 1] := DWChar(((UCS4ReplacementCharacter shr 6) and $3F) or $80); // 6 bits
        S[StrPos + 2] := DWChar((UCS4ReplacementCharacter and $3F) or $80); // 6 bits
        Inc(StrPos, 3);
      End
      Else
        Success := False;
      {$ELSE ~UNICODE_SILENT_FAILURE}
      StrPos := -1;
      Success := False;
      {$ENDIF ~UNICODE_SILENT_FAILURE}
    End;
    If Success Then
    Begin
      Inc(Start);
      Inc(Result);
    End;
    Dec(Count);
  End;
End;
Function UTF8SetNextCharToStream(S: TStream; Ch: UCS4): Boolean;
Begin
  If Ch <= $7F Then
    // 7 bits to store
    Result := StreamWriteByte(S,Ch)
  Else
  If Ch <= $7FF Then
    // 11 bits to store
    Result := StreamWriteByte(S, $C0 or (Ch shr 6)) and  // 5 bits
              StreamWriteByte(S, (Ch and $3F) or $80)    // 6 bits
  Else
  If Ch <= $FFFF Then
    // 16 bits to store
    Result := StreamWriteByte(S, $E0 or (Ch shr 12))          and // 4 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)             // 6 bits
  Else
  If Ch <= $1FFFFF Then
    // 21 bits to store
    Result := StreamWriteByte(S, $F0 or (Ch shr 18))           and // 3 bits
              StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
  Else
  If Ch <= $3FFFFFF Then
    // 26 bits to store
    Result := StreamWriteByte(S, $F8 or (Ch shr 24))           and // 2 bits
              StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
  Else
  If Ch <= MaximumUCS4 Then
    // 31 bits to store
    Result := StreamWriteByte(S, $FC or (Ch shr 30))           and // 1 bits
              StreamWriteByte(S, ((Ch shr 24) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
  Else
    {$IFDEF UNICODE_SILENT_FAILURE}
    // add ReplacementCharacter
    Result := StreamWriteByte(S, $E0 or (UCS4ReplacementCharacter shr 12))          and // 4 bits
              StreamWriteByte(S, ((UCS4ReplacementCharacter shr 6) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, (UCS4ReplacementCharacter and $3F) or $80); // 6 bits
    {$ELSE ~UNICODE_SILENT_FAILURE}
    Result := False;
    {$ENDIF ~UNICODE_SILENT_FAILURE}
End;
Function UTF8SetNextBufferToStream(S: TStream; Const Buffer: TUCS4Array; Var Start: SizeInt; Count: SizeInt): SizeInt;
Var
  Ch: UCS4;
  Success: Boolean;
Begin
  Result := 0;
  Success := True;
  While Success and (Count > 0) Do
  Begin
    Ch := Buffer[Start];
    If Ch <= $7F Then
      // 7 bits to store
      Success := StreamWriteByte(S,Ch)
    Else
    If Ch <= $7FF Then
      // 11 bits to store
      Success := StreamWriteByte(S, $C0 or (Ch shr 6)) and  // 5 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)    // 6 bits
    Else
    If Ch <= $FFFF Then
      // 16 bits to store
      Success := StreamWriteByte(S, $E0 or (Ch shr 12))          and // 4 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)             // 6 bits
    Else
    If Ch <= $1FFFFF Then
      // 21 bits to store
      Success := StreamWriteByte(S, $F0 or (Ch shr 18))           and // 3 bits
                 StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
    Else
    If Ch <= $3FFFFFF Then
      // 26 bits to store
      Success := StreamWriteByte(S, $F8 or (Ch shr 24))           and // 2 bits
                 StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
    Else
    If Ch <= MaximumUCS4 Then
      // 31 bits to store
      Success := StreamWriteByte(S, $FC or (Ch shr 30))           and // 1 bits
                 StreamWriteByte(S, ((Ch shr 24) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
    Else
      {$IFDEF UNICODE_SILENT_FAILURE}
      // add ReplacementCharacter
      Success := StreamWriteByte(S, $E0 or (UCS4ReplacementCharacter shr 12))          and // 4 bits
                 StreamWriteByte(S, ((UCS4ReplacementCharacter shr 6) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, (UCS4ReplacementCharacter and $3F) or $80); // 6 bits
      {$ELSE ~UNICODE_SILENT_FAILURE}
      Success := False;
      {$ENDIF ~UNICODE_SILENT_FAILURE}
    If Success Then
    Begin
      Inc(Start);
      Inc(Result);
    End;
    Dec(Count);
  End;
End;
// if UNICODE_SILENT_FAILURE is defined, invalid sequences will be replaced by ReplacementCharacter
Function UTF16SkipChars(Const S: TUTF16String; Var StrPos: SizeInt; Var NbSeq: SizeInt): Boolean;
Var
  StrLength, Index: SizeInt;
  Ch: UCS4;
Begin
  Result := True;
  StrLength := Length(S);
  Index := 0;
  If NbSeq >= 0 Then
    While (Index < NbSeq) and (StrPos > 0) Do
    Begin
      Ch := UCS4(S[StrPos]);
      Case Ch Of
        SurrogateHighStart..SurrogateHighEnd:
          // 2 bytes to skip
          If StrPos >= StrLength Then
            FlagInvalidSequence(StrPos, 1)
          Else
          Begin
            Ch := UCS4(S[StrPos + 1]);
            If (Ch < SurrogateLowStart) or (Ch > SurrogateLowEnd) Then
              FlagInvalidSequence(StrPos, 1)
            Else
              Inc(StrPos, 2);
          End;
        SurrogateLowStart..SurrogateLowEnd:
          // error
          FlagInvalidSequence(StrPos, 1);
      Else
        // 1 byte to skip
        Inc(StrPos);
      End;
      If StrPos <> -1 Then
        Inc(Index);
      If (StrPos > StrLength) and (Index < NbSeq) Then
      Begin
        Result := False;
        Break;
      End;
    End
  Else
    While (Index > NbSeq) and (StrPos > 1) Do
    Begin
      Ch := UCS4(S[StrPos - 1]);
      Case Ch Of
        SurrogateHighStart..SurrogateHighEnd:
          // error
          FlagInvalidSequence(StrPos, -1);
        SurrogateLowStart..SurrogateLowEnd:
          // 2 bytes to skip
          If StrPos <= 2 Then
            FlagInvalidSequence(StrPos, -1)
          Else
          Begin
            Ch := UCS4(S[StrPos - 2]);
            If (Ch < SurrogateHighStart) or (Ch > SurrogateHighEnd) Then
              FlagInvalidSequence(StrPos, -1)
            Else
              Dec(StrPos, 2);
          End;
      Else
        // 1 byte to skip
        Dec(StrPos);
      End;
      If StrPos <> -1 Then
        Dec(Index);
      If (StrPos = 1) and (Index > NbSeq) Then
      Begin
        Result := False;
        Break;
      End;
    End;
  NbSeq := Index;
End;
Function UTF16SkipCharsFromStream(S: TStream; Var NbSeq: SizeInt): Boolean;
Var
  Index: SizeInt;
  W: Word;
Begin
  Index := 0;
  While Index < NbSeq Do
  Begin
    Result := StreamReadWord(S, W);
    If not Result Then
      Break;
    Case W Of
      SurrogateHighStart..SurrogateHighEnd:
        // 2 bytes to skip
        Begin
          Result := StreamReadWord(S, W);
          If not Result Then
            Break;
          If (W < SurrogateLowStart) or (W > SurrogateLowEnd) Then
            FlagInvalidSequence;
        End;
      SurrogateLowStart..SurrogateLowEnd:
        // error
        FlagInvalidSequence;
    Else
      // 1 byte to skip
      // nothing to do
    End;
    Inc(Index);
  End;
  Result := Index = NbSeq;
  NbSeq := Index;
End;
Function AnsiSkipChars(Const S: DWString; Var StrPos: SizeInt; Var NbSeq: SizeInt): Boolean;
Var
  StrLen: SizeInt;
Begin
  StrLen := Length(S);
  If StrPos > 0 Then
  Begin
    If StrPos + NbSeq > StrLen Then
    Begin
      NbSeq := StrLen + 1 - StrPos;
      StrPos := StrLen + 1;
      Result := False;
    End
    Else
    Begin
      // NbSeq := NbSeq;
      StrPos := StrLen + NbSeq;
      Result := True;
    End;
  End
  Else
  Begin
    // previous error
    NbSeq := 0;
    // StrPos := -1;
    Result := False;
  End;
End;
Function AnsiSkipCharsFromStream(S: TStream; Var NbSeq: SizeInt): Boolean;
Var
  Index: SizeInt;
  B: Byte;
Begin
  Index := 0;
  While Index < NbSeq Do
  Begin
    Result := StreamReadByte(S, B);
    If not Result Then
      Break;
    Inc(Index);
  End;
  Result := Index = NbSeq;
  NbSeq := Index;
End;
Function StringSkipChars(Const S: string; Var StrPos: SizeInt; Var NbSeq: SizeInt): Boolean;
Begin
  Result := AnsiSkipChars(S, StrPos, NbSeq);
End;
Function DWStringToUTF16(Const S: DWString): TUTF16String;
Begin
  Result := TUTF16String(S);
End;
Function UTF16ToAnsiString(Const S: TUTF16String): DWString;
Begin
  Result := DWString(S);
End;
Function StringToUTF16(Const S: string): TUTF16String;
Begin
  Result := TUTF16String(S);
End;
Function TryStringToUTF16(Const S: string; out D: TUTF16String): Boolean;
Begin
  D := TUTF16String(S);
  Result := True;
End;
Function UTF16ToString(Const S: TUTF16String): string;
Begin
  Result := string(S);
End;
Function TryUTF16ToString(Const S: TUTF16String; out D: string): Boolean;
Begin
  D := string(S);
  Result := True;
End;
Function UCS4ToUTF8(Const S: TUCS4Array): TUTF8String;
Var
  SrcIndex, SrcLength, DestIndex: SizeInt;
Begin
  SrcLength := Length(S);
  If Length(S) = 0 Then
    Result := ''
  Else
  Begin
    SetLength(Result, SrcLength * 3); // assume worst case
    DestIndex := 1;
    For SrcIndex := 0 To SrcLength - 1 Do
    Begin
      UTF8SetNextChar(Result, DestIndex, S[SrcIndex]);
      If DestIndex = -1 Then
        raise EJclUnexpectedEOSequenceError.Create;
    End;
    SetLength(Result, DestIndex - 1); // set to actual length
  End;
End;
Function TryUCS4ToUTF8(Const S: TUCS4Array; out D: TUTF8String): Boolean;
Var
  SrcIndex, SrcLength, DestIndex: SizeInt;
Begin
  SrcLength := Length(S);
  Result := True;
  If Length(S) = 0 Then
    D := ''
  Else
  Begin
    SetLength(D, SrcLength * 3); // assume worst case
    DestIndex := 1;
    For SrcIndex := 0 To SrcLength - 1 Do
    Begin
      UTF8SetNextChar(D, DestIndex, S[SrcIndex]);
      If DestIndex = -1 Then
      Begin
        Result := False;
        Break;
      End;
    End;
    If Result Then
      SetLength(D, DestIndex - 1) // set to actual length
    Else
      D := '';
  End;
End;
Function UTF8CharCount(Const S: TUTF8String): SizeInt;
Var
  StrPos: SizeInt;
Begin
  StrPos := 1;
  Result := Length(S);
  UTF8SkipChars(S, StrPos, Result);
  If StrPos = -1 Then
    raise EJclUnexpectedEOSequenceError.Create;
End;
Function UTF16CharCount(Const S: TUTF16String): SizeInt;
Var
  StrPos: SizeInt;
Begin
  StrPos := 1;
  Result := Length(S);
  UTF16SkipChars(S, StrPos, Result);
  If StrPos = -1 Then
    raise EJclUnexpectedEOSequenceError.Create;
End;
Function UCS2CharCount(Const S: TUCS2String): SizeInt;
Begin
  Result := Length(S);
End;
Function UCS4CharCount(Const S: TUCS4Array): SizeInt;
Begin
  Result := Length(S);
End;
Function UCS4ToWideChar(Value: UCS4): WideChar;
Begin
  If Value <= MaximumUCS2 Then
    Result := WideChar(Value)
  Else
    Result := WideChar(UCS4ReplacementCharacter);
End;
Function WideCharToUCS4(Value: WideChar): UCS4;
Begin
  Result := UCS4(Value);
End;
End.
