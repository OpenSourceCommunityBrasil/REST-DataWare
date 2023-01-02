unit uRESTDWMemStringConversions;
{$I ..\..\Includes\uRESTDWPlataform.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFDEF FPC}
 {$MODE Delphi}
 {$ASMMode Intel}
{$ENDIF}

interface
uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  {$ELSE ~HAS_UNITSCOPE}
  Classes,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase,
  uRESTDWPrototypes;
type
  EJclStringConversionError = class(EJclError);
  EJclUnexpectedEOSequenceError = class (EJclStringConversionError)
  public
    constructor Create;
  end;
type
  TJclStreamGetNextCharFunc = function(S: TStream; out Ch: UCS4): Boolean;
  TJclStreamSkipCharsFunc = function(S: TStream; var NbSeq: SizeInt): Boolean;
  TJclStreamSetNextCharFunc = function(S: TStream; Ch: UCS4): Boolean;
function UTF8SetNextChar(var S: TUTF8String; var StrPos: SizeInt; Ch: UCS4): Boolean;
function UTF8SetNextBuffer(var S: TUTF8String; var StrPos: SizeInt; const Buffer: TUCS4Array; var Start: SizeInt; Count: SizeInt): SizeInt;
function UTF8SetNextCharToStream(S: TStream; Ch: UCS4): Boolean;
function UTF8SetNextBufferToStream(S: TStream; const Buffer: TUCS4Array; var Start: SizeInt; Count: SizeInt): SizeInt;
function AnsiSkipChars(const S: DWString; var StrPos: SizeInt; var NbSeq: SizeInt): Boolean;
function AnsiSkipCharsFromStream(S: TStream; var NbSeq: SizeInt): Boolean;
function StringSkipChars(const S: string; var StrPos: SizeInt; var NbSeq: SizeInt): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
// one shot conversions between DWString and others
function DWStringToUTF16(const S: DWString): TUTF16String; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function UTF16ToAnsiString(const S: TUTF16String): DWString; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
// one shot conversions between string and others
function StringToUTF16(const S: string): TUTF16String; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function UTF16ToString(const S: TUTF16String): string; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function TryStringToUTF16(const S: string; out D: TUTF16String): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function TryUTF16ToString(const S: TUTF16String; out D: string): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function UCS4ToUTF8(const S: TUCS4Array): TUTF8String;
// indexed conversions
function UTF8CharCount(const S: TUTF8String): SizeInt;
function UTF16CharCount(const S: TUTF16String): SizeInt;
function UCS2CharCount(const S: TUCS2String): SizeInt;
function UCS4CharCount(const S: TUCS4Array): SizeInt;
// returns False if string is too small
// if UNICODE_SILENT_FAILURE is not defined and an invalid UTFX sequence is detected, an exception is raised
// returns True on success and Value contains UCS4 character that was read
function UCS4ToWideChar(Value: UCS4): WideChar;
function WideCharToUCS4(Value: WideChar): UCS4;
implementation
uses
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
const MB_ERR_INVALID_CHARS = 8;
constructor EJclUnexpectedEOSequenceError.Create;
begin
  inherited CreateRes(@RsEUnexpectedEOSeq);
end;
function StreamReadByte(S: TStream; out B: Byte): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  B := 0;
  Result := S.Read(B, SizeOf(B)) = SizeOf(B);
end;
function StreamWriteByte(S: TStream; B: Byte): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  Result := S.Write(B, SizeOf(B)) = SizeOf(B);
end;
function StreamReadWord(S: TStream; out W: Word): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  W := 0;
  Result := S.Read(W, SizeOf(W)) = SizeOf(W);
end;
function StreamWriteWord(S: TStream; W: Word): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  Result := S.Write(W, SizeOf(W)) = SizeOf(W);
end;
procedure FlagInvalidSequence(var StrPos: SizeInt; Increment: SizeInt); overload;
begin
  {$IFDEF UNICODE_SILENT_FAILURE}
  Inc(StrPos, Increment);
  {$ELSE ~UNICODE_SILENT_FAILURE}
  StrPos := -1;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
end;
procedure FlagInvalidSequence(out Ch: UCS4); overload;
begin
  {$IFDEF UNICODE_SILENT_FAILURE}
  Ch := UCS4ReplacementCharacter;
  {$ELSE ~UNICODE_SILENT_FAILURE}
  raise EJclUnexpectedEOSequenceError.Create;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
end;
procedure FlagInvalidSequence; overload;
begin
  {$IFNDEF UNICODE_SILENT_FAILURE}
  raise EJclUnexpectedEOSequenceError.Create;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
end;
function UTF8GetNextCharFromStream(S: TStream; out Ch: UCS4): Boolean;
var
  B: Byte;
begin
  Result := StreamReadByte(S,B);
  if Result then
  begin
    Ch := UCS4(B);
    case Ch of
      $00..$7F: ;
        // 1 byte to read
        // nothing to do
      $C0..$DF:
        begin
          // 2 bytes to read
          Result := StreamReadByte(S,B);
          if Result then
          begin
            if (B and $C0) = $80 then
              Ch := ((Ch and $1F) shl 6) or (B and $3F)
            else
              FlagInvalidSequence(Ch);
          end;
        end;
      $E0..$EF:
        begin
          // 3 bytes to read
          Result := StreamReadByte(S,B);
          if Result then
          begin
            if (B and $C0) = $80 then
            begin
              Ch := ((Ch and $0F) shl 12) or ((B and $3F) shl 6);
              Result := StreamReadByte(S,B);
              if Result then
              begin
                if (B and $C0) = $80 then
                  Ch := Ch or (B and $3F)
                else
                  FlagInvalidSequence(Ch);
              end;
            end
            else
              FlagInvalidSequence(Ch);
          end;
        end;
      $F0..$F7:
        begin
          // 4 bytes to read
          Result := StreamReadByte(S,B);
          if Result then
          begin
            if (B and $C0) = $80 then
            begin
              Ch := ((Ch and $07) shl 18) or ((B and $3F) shl 12);
              Result := StreamReadByte(S,B);
              if Result then
              begin
                if (B and $C0) = $80 then
                begin
                  Ch := Ch or ((B and $3F) shl 6);
                  Result := StreamReadByte(S,B);
                  if Result then
                  begin
                    if (B and $C0) = $80 then
                      Ch := Ch or (B and $3F)
                    else
                      FlagInvalidSequence(Ch);
                  end;
                end
                else
                  FlagInvalidSequence(Ch);
              end;
            end
            else
              FlagInvalidSequence(Ch);
          end;
        end;
      $F8..$FB:
        begin
          // 5 bytes to read
          Result := StreamReadByte(S,B);
          if Result then
          begin
            if (B and $C0) = $80 then
            begin
              Ch := ((Ch and $03) shl 24) or ((B and $3F) shl 18);
              Result := StreamReadByte(S,B);
              if Result then
              begin
                if (B and $C0) = $80 then
                begin
                  Ch := Ch or ((B and $3F) shl 12);
                  Result := StreamReadByte(S,B);
                  if Result then
                  begin
                    if (B and $C0) = $80 then
                    begin
                      Ch := Ch or ((B and $3F) shl 6);
                      Result := StreamReadByte(S,B);
                      if Result then
                      begin
                        if (B and $C0) = $80 then
                          Ch := Ch or (B and $3F)
                        else
                          FlagInvalidSequence(Ch);
                      end;
                    end
                    else
                      FlagInvalidSequence(Ch);
                  end;
                end
                else
                  FlagInvalidSequence(Ch);
              end;
            end
            else
              FlagInvalidSequence(Ch);
          end;
        end;
      $FC..$FD:
        begin
          // 6 bytes to read
          Result := StreamReadByte(S,B);
          if Result then
          begin
            if (B and $C0) = $80 then
            begin
              Ch := ((Ch and $01) shl 30) or ((B and $3F) shl 24);
              Result := StreamReadByte(S,B);
              if Result then
              begin
                if (B and $C0) = $80 then
                begin
                  Ch := Ch or ((B and $3F) shl 18);
                  Result := StreamReadByte(S,B);
                  if Result then
                  begin
                    if (B and $C0) = $80 then
                    begin
                      Ch := Ch or ((B and $3F) shl 12);
                      Result := StreamReadByte(S,B);
                      if Result then
                      begin
                        if (B and $C0) = $80 then
                        begin
                          Ch := Ch or ((B and $3F) shl 6);
                          Result := StreamReadByte(S,B);
                          if Result then
                          begin
                            if (B and $C0) = $80 then
                              Ch := Ch or (B and $3F)
                            else
                              FlagInvalidSequence(Ch);
                          end;
                        end
                        else
                          FlagInvalidSequence(Ch);
                      end;
                    end
                    else
                      FlagInvalidSequence(Ch);
                  end;
                end
                else
                  FlagInvalidSequence(Ch);
              end;
            end
            else
              FlagInvalidSequence(Ch);
          end;
        end;
    else
      FlagInvalidSequence(Ch);
    end;
  end;
end;
function UTF8GetNextBufferFromStream(S: TStream; var Buffer: TUCS4Array; var Start: SizeInt; Count: SizeInt): SizeInt;
var
  B: Byte;
  Ch: UCS4;
  ReadSuccess: Boolean;
begin
  Result := 0;
  ReadSuccess := True;
  while ReadSuccess and (Count > 0) do
  begin
    if StreamReadByte(S,B) then
    begin
      Ch := UCS4(B);
      case Ch of
        $00..$7F: ;
          // 1 byte to read
          // nothing to do
        $C0..$DF:
          begin
            // 2 bytes to read
            if StreamReadByte(S,B) then
            begin
              if (B and $C0) = $80 then
                Ch := ((Ch and $1F) shl 6) or (B and $3F)
              else
                FlagInvalidSequence(Ch);
            end
            else
              ReadSuccess := False;
          end;
        $E0..$EF:
          begin
            // 3 bytes to read
            if StreamReadByte(S,B) then
            begin
              if (B and $C0) = $80 then
              begin
                Ch := ((Ch and $0F) shl 12) or ((B and $3F) shl 6);
                if StreamReadByte(S,B) then
                begin
                  if (B and $C0) = $80 then
                    Ch := Ch or (B and $3F)
                  else
                    FlagInvalidSequence(Ch);
                end
                else
                  ReadSuccess := False;
              end
              else
                FlagInvalidSequence(Ch);
            end
            else
              ReadSuccess := False;
          end;
        $F0..$F7:
          begin
            // 4 bytes to read
            if StreamReadByte(S,B) then
            begin
              if (B and $C0) = $80 then
              begin
                Ch := ((Ch and $07) shl 18) or ((B and $3F) shl 12);
                if StreamReadByte(S,B) then
                begin
                  if (B and $C0) = $80 then
                  begin
                    Ch := Ch or ((B and $3F) shl 6);
                    if StreamReadByte(S,B) then
                    begin
                      if (B and $C0) = $80 then
                        Ch := Ch or (B and $3F)
                      else
                        FlagInvalidSequence(Ch);
                    end
                    else
                      ReadSuccess := False;
                  end
                  else
                    FlagInvalidSequence(Ch);
                end
                else
                  ReadSuccess := False;
              end
              else
                FlagInvalidSequence(Ch);
            end
            else
              ReadSuccess := False;
          end;
        $F8..$FB:
          begin
            // 5 bytes to read
            if StreamReadByte(S,B) then
            begin
              if (B and $C0) = $80 then
              begin
                Ch := ((Ch and $03) shl 24) or ((B and $3F) shl 18);
                if StreamReadByte(S,B) then
                begin
                  if (B and $C0) = $80 then
                  begin
                    Ch := Ch or ((B and $3F) shl 12);
                    if StreamReadByte(S,B) then
                    begin
                      if (B and $C0) = $80 then
                      begin
                        Ch := Ch or ((B and $3F) shl 6);
                        if StreamReadByte(S,B) then
                        begin
                          if (B and $C0) = $80 then
                            Ch := Ch or (B and $3F)
                          else
                            FlagInvalidSequence(Ch);
                        end
                        else
                          ReadSuccess := False;
                      end
                      else
                        FlagInvalidSequence(Ch);
                    end
                    else
                      ReadSuccess := False;
                  end
                  else
                    FlagInvalidSequence(Ch);
                end
                else
                  ReadSuccess := False;
              end
              else
                FlagInvalidSequence(Ch);
            end
            else
              ReadSuccess := False;
          end;
        $FC..$FD:
          begin
            // 6 bytes to read
            if StreamReadByte(S,B) then
            begin
              if (B and $C0) = $80 then
              begin
                Ch := ((Ch and $01) shl 30) or ((B and $3F) shl 24);
                if StreamReadByte(S,B) then
                begin
                  if (B and $C0) = $80 then
                  begin
                    Ch := Ch or ((B and $3F) shl 18);
                    if StreamReadByte(S,B) then
                    begin
                      if (B and $C0) = $80 then
                      begin
                        Ch := Ch or ((B and $3F) shl 12);
                        if StreamReadByte(S,B) then
                        begin
                          if (B and $C0) = $80 then
                          begin
                            Ch := Ch or ((B and $3F) shl 6);
                            if StreamReadByte(S,B) then
                            begin
                              if (B and $C0) = $80 then
                                Ch := Ch or (B and $3F)
                              else
                                FlagInvalidSequence(Ch);
                            end
                            else
                              ReadSuccess := False;
                          end
                          else
                            FlagInvalidSequence(Ch);
                        end
                        else
                          ReadSuccess := False;
                      end
                      else
                        FlagInvalidSequence(Ch);
                    end
                    else
                      ReadSuccess := False;
                  end
                  else
                    FlagInvalidSequence(Ch);
                end
                else
                  ReadSuccess := False;
              end
              else
                FlagInvalidSequence(Ch);
            end
            else
              ReadSuccess := False;
          end
      else
        FlagInvalidSequence(Ch);
      end;
      if ReadSuccess then
      begin
        Buffer[Start] := Ch;
        Inc(Start);
        Inc(Result);
      end;
    end
    else
      ReadSuccess := False;
    Dec(Count);
  end;
end;
// returns False if String is too small
// if UNICODE_SILENT_FAILURE is not defined StrPos is set to -1 on error (invalid UTF8 sequence)
// StrPos will be incremented by the number of ansi chars that were skipped
// On return, NbSeq contains the number of UTF8 sequences that were skipped
function UTF8SkipChars(const S: TUTF8String; var StrPos: SizeInt; var NbSeq: SizeInt): Boolean;
var
  StrLength: SizeInt;
  Ch: UCS4;
  Index: SizeInt;
begin
  Result := True;
  StrLength := Length(S);
  Index := 0;
  while (Index < NbSeq) and (StrPos > 0) do
  begin
    Ch := UCS4(S[StrPos]);
    case Ch of
      $00..$7F:
        // 1 byte to skip
        Inc(StrPos);
      $C0..$DF:
        // 2 bytes to skip
        if (StrPos >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) then
          FlagInvalidSequence(StrPos, 1)
        else
          Inc(StrPos, 2);
      $E0..$EF:
        // 3 bytes to skip
        if ((StrPos + 1) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) then
          FlagInvalidSequence(StrPos, 1)
        else
        if (UCS4(S[StrPos + 2]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 2)
        else
          Inc(StrPos, 3);
      $F0..$F7:
        // 4 bytes to skip
        if ((StrPos + 2) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) then
          FlagInvalidSequence(StrPos, 1)
        else
        if (UCS4(S[StrPos + 2]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 2)
        else
        if (UCS4(S[StrPos + 3]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 3)
        else
          Inc(StrPos, 4);
      $F8..$FB:
        // 5 bytes to skip
        if ((StrPos + 3) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) then
          FlagInvalidSequence(StrPos, 1)
        else
        if (UCS4(S[StrPos + 2]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 2)
        else
        if (UCS4(S[StrPos + 3]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 3)
        else
        if (UCS4(S[StrPos + 4]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 4)
        else
          Inc(StrPos, 5);
      $FC..$FD:
        // 6 bytes to skip
        if ((StrPos + 4) >= StrLength) or ((UCS4(S[StrPos + 1]) and $C0) <> $80) then
          FlagInvalidSequence(StrPos, 1)
        else
        if (UCS4(S[StrPos + 2]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 2)
        else
        if (UCS4(S[StrPos + 3]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 3)
        else
        if (UCS4(S[StrPos + 4]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 4)
        else
        if (UCS4(S[StrPos + 5]) and $C0) <> $80 then
          FlagInvalidSequence(StrPos, 5)
        else
          Inc(StrPos, 6);
    else
      FlagInvalidSequence(StrPos, 1);
    end;
    if StrPos <> -1 then
      Inc(Index);
    if (StrPos > StrLength) and (Index < NbSeq) then
    begin
      Result := False;
      Break;
    end;
  end;
  NbSeq := Index;
end;
function UTF8SkipCharsFromStream(S: TStream; var NbSeq: SizeInt): Boolean;
var
  B: Byte;
  Index: SizeInt;
begin
  Index := 0;
  while (Index < NbSeq) do
  begin
    Result := StreamReadByte(S, B);
    if not Result then
      Break;
    case B of
      $00..$7F: ;
        // 1 byte to skip
        // nothing to do
      $C0..$DF:
        // 2 bytes to skip
        begin
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
        end;
      $E0..$EF:
        // 3 bytes to skip
        begin
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
        end;
      $F0..$F7:
        // 4 bytes to skip
        begin
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
        end;
      $F8..$FB:
        // 5 bytes to skip
        begin
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
        end;
      $FC..$FD:
        // 6 bytes to skip
        begin
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
          Result := StreamReadByte(S, B);
          if not Result then
            Break;
          if (B and $C0) <> $80 then
            FlagInvalidSequence;
        end;
    else
      FlagInvalidSequence;
    end;
    Inc(Index);
  end;
  Result := Index = NbSeq;
  NbSeq := Index;
end;
// returns False on error:
//    - if an UCS4 character cannot be stored to an UTF-8 string:
//        - if UNICODE_SILENT_FAILURE is defined, ReplacementCharacter is added
//        - if UNICODE_SILENT_FAILURE is not defined, StrPos is set to -1
//    - StrPos > -1 flags string being too small, caller is responsible for allocating space
// StrPos will be incremented by the number of chars that were written
function UTF8SetNextChar(var S: TUTF8String; var StrPos: SizeInt; Ch: UCS4): Boolean;
var
  StrLength: SizeInt;
begin
  StrLength := Length(S);
  if Ch <= $7F then
  begin
    // 7 bits to store
    Result := (StrPos > 0) and (StrPos <= StrLength);
    if Result then
    begin
      PDWString(@S[StrPos])^ := DWChar(Ch);
      Inc(StrPos);
    end;
  end
  else
  if Ch <= $7FF then
  begin
    // 11 bits to store
    Result := (StrPos > 0) and (StrPos < StrLength);
    if Result then
    begin
      PDWString(@S[StrPos])^ := DWChar($C0 or (Ch shr 6));  // 5 bits
      PDWString(@S[StrPos + 1])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 2);
    end;
  end
  else
  if Ch <= $FFFF then
  begin
    // 16 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 1));
    if Result then
    begin
      PDWString(@S[StrPos])^ := DWChar($E0 or (Ch shr 12)); // 4 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 3);
    end;
  end
  else
  if Ch <= $1FFFFF then
  begin
    // 21 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 2));
    if Result then
    begin
      PDWString(@S[StrPos])^ := DWChar($F0 or (Ch shr 18)); // 3 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 3])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 4);
    end;
  end
  else
  if Ch <= $3FFFFFF then
  begin
    // 26 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 2));
    if Result then
    begin
      PDWString(@S[StrPos])^ := DWChar($F8 or (Ch shr 24)); // 2 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 4])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 5);
    end;
  end
  else
  if Ch <= MaximumUCS4 then
  begin
    // 31 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 3));
    if Result then
    begin
      PDWString(@S[StrPos])^     := DWChar($FC or (Ch shr 30)); // 1 bits
      PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 24) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 4])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
      PDWString(@S[StrPos + 5])^ := DWChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 6);
    end;
  end
  else
  begin
    {$IFDEF UNICODE_SILENT_FAILURE}
    // add ReplacementCharacter
    Result := (StrPos > 0) and (StrPos < (StrLength - 1));
    if Result then
    begin
      S[StrPos] := DWChar($E0 or (UCS4ReplacementCharacter shr 12)); // 4 bits
      S[StrPos + 1] := DWChar(((UCS4ReplacementCharacter shr 6) and $3F) or $80); // 6 bits
      S[StrPos + 2] := DWChar((UCS4ReplacementCharacter and $3F) or $80); // 6 bits
      Inc(StrPos, 3);
    end;
    {$ELSE ~UNICODE_SILENT_FAILURE}
    StrPos := -1;
    Result := False;
    {$ENDIF ~UNICODE_SILENT_FAILURE}
  end;
end;
function UTF8SetNextBuffer(var S: TUTF8String; var StrPos: SizeInt; const Buffer: TUCS4Array; var Start: SizeInt; Count: SizeInt): SizeInt;
var
  StrLength: SizeInt;
  Ch: UCS4;
  Success: Boolean;
begin
  StrLength := Length(S);
  Success := True;
  Result := 0;
  while Success and (Count > 0) do
  begin
    Ch := Buffer[Start];
    if Ch <= $7F then
    begin
      // 7 bits to store
      if (StrPos > 0) and (StrPos <= StrLength) then
      begin
        PDWString(@S[StrPos])^ := DWChar(Ch);
        Inc(StrPos);
      end
      else
        Success := False;
    end
    else
    if Ch <= $7FF then
    begin
      // 11 bits to store
      if (StrPos > 0) and (StrPos < StrLength) then
      begin
        PDWString(@S[StrPos])^ := DWChar($C0 or (Ch shr 6));  // 5 bits
        PDWString(@S[StrPos + 1])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 2);
      end
      else
        Success := False;
    end
    else
    if Ch <= $FFFF then
    begin
      // 16 bits to store
      if (StrPos > 0) and (StrPos < (StrLength - 1)) then
      begin
        PDWString(@S[StrPos])^ := DWChar($E0 or (Ch shr 12)); // 4 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 3);
      end
      else
        Success := False;
    end
    else
    if Ch <= $1FFFFF then
    begin
      // 21 bits to store
      if (StrPos > 0) and (StrPos < (StrLength - 2)) then
      begin
        PDWString(@S[StrPos])^ := DWChar($F0 or (Ch shr 18)); // 3 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 3])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 4);
      end
      else
        Success := False;
    end
    else
    if Ch <= $3FFFFFF then
    begin
      // 26 bits to store
      if (StrPos > 0) and (StrPos < (StrLength - 2)) then
      begin
        PDWString(@S[StrPos])^     := DWChar($F8 or (Ch shr 24)); // 2 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 4])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 5);
      end
      else
        Success := False;
    end
    else
    if Ch <= MaximumUCS4 then
    begin
      // 31 bits to store
      if (StrPos > 0) and (StrPos < (StrLength - 3)) then
      begin
        PDWString(@S[StrPos])^     := DWChar($FC or (Ch shr 30)); // 1 bits
        PDWString(@S[StrPos + 1])^ := DWChar(((Ch shr 24) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 2])^ := DWChar(((Ch shr 18) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 3])^ := DWChar(((Ch shr 12) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 4])^ := DWChar(((Ch shr 6) and $3F) or $80); // 6 bits
        PDWString(@S[StrPos + 5])^ := DWChar((Ch and $3F) or $80); // 6 bits
        Inc(StrPos, 6);
      end
      else
        Success := False;
    end
    else
    begin
      {$IFDEF UNICODE_SILENT_FAILURE}
      // add ReplacementCharacter
      if (StrPos > 0) and (StrPos < (StrLength - 1)) then
      begin
        S[StrPos] := DWChar($E0 or (UCS4ReplacementCharacter shr 12)); // 4 bits
        S[StrPos + 1] := DWChar(((UCS4ReplacementCharacter shr 6) and $3F) or $80); // 6 bits
        S[StrPos + 2] := DWChar((UCS4ReplacementCharacter and $3F) or $80); // 6 bits
        Inc(StrPos, 3);
      end
      else
        Success := False;
      {$ELSE ~UNICODE_SILENT_FAILURE}
      StrPos := -1;
      Success := False;
      {$ENDIF ~UNICODE_SILENT_FAILURE}
    end;
    if Success then
    begin
      Inc(Start);
      Inc(Result);
    end;
    Dec(Count);
  end;
end;
function UTF8SetNextCharToStream(S: TStream; Ch: UCS4): Boolean;
begin
  if Ch <= $7F then
    // 7 bits to store
    Result := StreamWriteByte(S,Ch)
  else
  if Ch <= $7FF then
    // 11 bits to store
    Result := StreamWriteByte(S, $C0 or (Ch shr 6)) and  // 5 bits
              StreamWriteByte(S, (Ch and $3F) or $80)    // 6 bits
  else
  if Ch <= $FFFF then
    // 16 bits to store
    Result := StreamWriteByte(S, $E0 or (Ch shr 12))          and // 4 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)             // 6 bits
  else
  if Ch <= $1FFFFF then
    // 21 bits to store
    Result := StreamWriteByte(S, $F0 or (Ch shr 18))           and // 3 bits
              StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
  else
  if Ch <= $3FFFFFF then
    // 26 bits to store
    Result := StreamWriteByte(S, $F8 or (Ch shr 24))           and // 2 bits
              StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
  else
  if Ch <= MaximumUCS4 then
    // 31 bits to store
    Result := StreamWriteByte(S, $FC or (Ch shr 30))           and // 1 bits
              StreamWriteByte(S, ((Ch shr 24) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
              StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
  else
    {$IFDEF UNICODE_SILENT_FAILURE}
    // add ReplacementCharacter
    Result := StreamWriteByte(S, $E0 or (UCS4ReplacementCharacter shr 12))          and // 4 bits
              StreamWriteByte(S, ((UCS4ReplacementCharacter shr 6) and $3F) or $80) and // 6 bits
              StreamWriteByte(S, (UCS4ReplacementCharacter and $3F) or $80); // 6 bits
    {$ELSE ~UNICODE_SILENT_FAILURE}
    Result := False;
    {$ENDIF ~UNICODE_SILENT_FAILURE}
end;
function UTF8SetNextBufferToStream(S: TStream; const Buffer: TUCS4Array; var Start: SizeInt; Count: SizeInt): SizeInt;
var
  Ch: UCS4;
  Success: Boolean;
begin
  Result := 0;
  Success := True;
  while Success and (Count > 0) do
  begin
    Ch := Buffer[Start];
    if Ch <= $7F then
      // 7 bits to store
      Success := StreamWriteByte(S,Ch)
    else
    if Ch <= $7FF then
      // 11 bits to store
      Success := StreamWriteByte(S, $C0 or (Ch shr 6)) and  // 5 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)    // 6 bits
    else
    if Ch <= $FFFF then
      // 16 bits to store
      Success := StreamWriteByte(S, $E0 or (Ch shr 12))          and // 4 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)             // 6 bits
    else
    if Ch <= $1FFFFF then
      // 21 bits to store
      Success := StreamWriteByte(S, $F0 or (Ch shr 18))           and // 3 bits
                 StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
    else
    if Ch <= $3FFFFFF then
      // 26 bits to store
      Success := StreamWriteByte(S, $F8 or (Ch shr 24))           and // 2 bits
                 StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
    else
    if Ch <= MaximumUCS4 then
      // 31 bits to store
      Success := StreamWriteByte(S, $FC or (Ch shr 30))           and // 1 bits
                 StreamWriteByte(S, ((Ch shr 24) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 18) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 12) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, ((Ch shr 6) and $3F) or $80)  and // 6 bits
                 StreamWriteByte(S, (Ch and $3F) or $80)              // 6 bits
    else
      {$IFDEF UNICODE_SILENT_FAILURE}
      // add ReplacementCharacter
      Success := StreamWriteByte(S, $E0 or (UCS4ReplacementCharacter shr 12))          and // 4 bits
                 StreamWriteByte(S, ((UCS4ReplacementCharacter shr 6) and $3F) or $80) and // 6 bits
                 StreamWriteByte(S, (UCS4ReplacementCharacter and $3F) or $80); // 6 bits
      {$ELSE ~UNICODE_SILENT_FAILURE}
      Success := False;
      {$ENDIF ~UNICODE_SILENT_FAILURE}
    if Success then
    begin
      Inc(Start);
      Inc(Result);
    end;
    Dec(Count);
  end;
end;
// if UNICODE_SILENT_FAILURE is defined, invalid sequences will be replaced by ReplacementCharacter
function UTF16SkipChars(const S: TUTF16String; var StrPos: SizeInt; var NbSeq: SizeInt): Boolean;
var
  StrLength, Index: SizeInt;
  Ch: UCS4;
begin
  Result := True;
  StrLength := Length(S);
  Index := 0;
  if NbSeq >= 0 then
    while (Index < NbSeq) and (StrPos > 0) do
    begin
      Ch := UCS4(S[StrPos]);
      case Ch of
        SurrogateHighStart..SurrogateHighEnd:
          // 2 bytes to skip
          if StrPos >= StrLength then
            FlagInvalidSequence(StrPos, 1)
          else
          begin
            Ch := UCS4(S[StrPos + 1]);
            if (Ch < SurrogateLowStart) or (Ch > SurrogateLowEnd) then
              FlagInvalidSequence(StrPos, 1)
            else
              Inc(StrPos, 2);
          end;
        SurrogateLowStart..SurrogateLowEnd:
          // error
          FlagInvalidSequence(StrPos, 1);
      else
        // 1 byte to skip
        Inc(StrPos);
      end;
      if StrPos <> -1 then
        Inc(Index);
      if (StrPos > StrLength) and (Index < NbSeq) then
      begin
        Result := False;
        Break;
      end;
    end
  else
    while (Index > NbSeq) and (StrPos > 1) do
    begin
      Ch := UCS4(S[StrPos - 1]);
      case Ch of
        SurrogateHighStart..SurrogateHighEnd:
          // error
          FlagInvalidSequence(StrPos, -1);
        SurrogateLowStart..SurrogateLowEnd:
          // 2 bytes to skip
          if StrPos <= 2 then
            FlagInvalidSequence(StrPos, -1)
          else
          begin
            Ch := UCS4(S[StrPos - 2]);
            if (Ch < SurrogateHighStart) or (Ch > SurrogateHighEnd) then
              FlagInvalidSequence(StrPos, -1)
            else
              Dec(StrPos, 2);
          end;
      else
        // 1 byte to skip
        Dec(StrPos);
      end;
      if StrPos <> -1 then
        Dec(Index);
      if (StrPos = 1) and (Index > NbSeq) then
      begin
        Result := False;
        Break;
      end;
    end;
  NbSeq := Index;
end;
function UTF16SkipCharsFromStream(S: TStream; var NbSeq: SizeInt): Boolean;
var
  Index: SizeInt;
  W: Word;
begin
  Index := 0;
  while Index < NbSeq do
  begin
    Result := StreamReadWord(S, W);
    if not Result then
      Break;
    case W of
      SurrogateHighStart..SurrogateHighEnd:
        // 2 bytes to skip
        begin
          Result := StreamReadWord(S, W);
          if not Result then
            Break;
          if (W < SurrogateLowStart) or (W > SurrogateLowEnd) then
            FlagInvalidSequence;
        end;
      SurrogateLowStart..SurrogateLowEnd:
        // error
        FlagInvalidSequence;
    else
      // 1 byte to skip
      // nothing to do
    end;
    Inc(Index);
  end;
  Result := Index = NbSeq;
  NbSeq := Index;
end;
function AnsiSkipChars(const S: DWString; var StrPos: SizeInt; var NbSeq: SizeInt): Boolean;
var
  StrLen: SizeInt;
begin
  StrLen := Length(S);
  if StrPos > 0 then
  begin
    if StrPos + NbSeq > StrLen then
    begin
      NbSeq := StrLen + 1 - StrPos;
      StrPos := StrLen + 1;
      Result := False;
    end
    else
    begin
      // NbSeq := NbSeq;
      StrPos := StrLen + NbSeq;
      Result := True;
    end;
  end
  else
  begin
    // previous error
    NbSeq := 0;
    // StrPos := -1;
    Result := False;
  end;
end;
function AnsiSkipCharsFromStream(S: TStream; var NbSeq: SizeInt): Boolean;
var
  Index: SizeInt;
  B: Byte;
begin
  Index := 0;
  while Index < NbSeq do
  begin
    Result := StreamReadByte(S, B);
    if not Result then
      Break;
    Inc(Index);
  end;
  Result := Index = NbSeq;
  NbSeq := Index;
end;
function StringSkipChars(const S: string; var StrPos: SizeInt; var NbSeq: SizeInt): Boolean;
begin
  Result := AnsiSkipChars(S, StrPos, NbSeq);
end;
function DWStringToUTF16(const S: DWString): TUTF16String;
begin
  Result := TUTF16String(S);
end;
function UTF16ToAnsiString(const S: TUTF16String): DWString;
begin
  Result := DWString(S);
end;
function StringToUTF16(const S: string): TUTF16String;
begin
  Result := TUTF16String(S);
end;
function TryStringToUTF16(const S: string; out D: TUTF16String): Boolean;
begin
  D := TUTF16String(S);
  Result := True;
end;
function UTF16ToString(const S: TUTF16String): string;
begin
  Result := string(S);
end;
function TryUTF16ToString(const S: TUTF16String; out D: string): Boolean;
begin
  D := string(S);
  Result := True;
end;
function UCS4ToUTF8(const S: TUCS4Array): TUTF8String;
var
  SrcIndex, SrcLength, DestIndex: SizeInt;
begin
  SrcLength := Length(S);
  if Length(S) = 0 then
    Result := ''
  else
  begin
    SetLength(Result, SrcLength * 3); // assume worst case
    DestIndex := 1;
    for SrcIndex := 0 to SrcLength - 1 do
    begin
      UTF8SetNextChar(Result, DestIndex, S[SrcIndex]);
      if DestIndex = -1 then
        raise EJclUnexpectedEOSequenceError.Create;
    end;
    SetLength(Result, DestIndex - 1); // set to actual length
  end;
end;
function TryUCS4ToUTF8(const S: TUCS4Array; out D: TUTF8String): Boolean;
var
  SrcIndex, SrcLength, DestIndex: SizeInt;
begin
  SrcLength := Length(S);
  Result := True;
  if Length(S) = 0 then
    D := ''
  else
  begin
    SetLength(D, SrcLength * 3); // assume worst case
    DestIndex := 1;
    for SrcIndex := 0 to SrcLength - 1 do
    begin
      UTF8SetNextChar(D, DestIndex, S[SrcIndex]);
      if DestIndex = -1 then
      begin
        Result := False;
        Break;
      end;
    end;
    if Result then
      SetLength(D, DestIndex - 1) // set to actual length
    else
      D := '';
  end;
end;
function UTF8CharCount(const S: TUTF8String): SizeInt;
var
  StrPos: SizeInt;
begin
  StrPos := 1;
  Result := Length(S);
  UTF8SkipChars(S, StrPos, Result);
  if StrPos = -1 then
    raise EJclUnexpectedEOSequenceError.Create;
end;
function UTF16CharCount(const S: TUTF16String): SizeInt;
var
  StrPos: SizeInt;
begin
  StrPos := 1;
  Result := Length(S);
  UTF16SkipChars(S, StrPos, Result);
  if StrPos = -1 then
    raise EJclUnexpectedEOSequenceError.Create;
end;
function UCS2CharCount(const S: TUCS2String): SizeInt;
begin
  Result := Length(S);
end;
function UCS4CharCount(const S: TUCS4Array): SizeInt;
begin
  Result := Length(S);
end;
function UCS4ToWideChar(Value: UCS4): WideChar;
begin
  if Value <= MaximumUCS2 then
    Result := WideChar(Value)
  else
    Result := WideChar(UCS4ReplacementCharacter);
end;
function WideCharToUCS4(Value: WideChar): UCS4;
begin
  Result := UCS4(Value);
end;
end.
