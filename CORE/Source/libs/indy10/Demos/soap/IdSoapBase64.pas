unit IdSoapBase64;
{
  why does this unit exist - to solve version and performance problems with
  the indy decoders
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  First written
}

interface

uses
  classes;

function IdSoapBase64Decode(AValue : String) : TMemoryStream;
function IdSoapBase64Encode(AStream : TStream; AWrap : Boolean) : String;

implementation

uses
  IdSoapUtilities,
  SysUtils;

Function Ceiling(rValue : Real) : Int64;
Begin { Function Ceiling }
  Result := Integer(Trunc(rValue));
  If Frac(rValue) > 0 Then
    Inc(Result);
End;  { Function Ceiling }


(*
this code kindly donated to Grahame by Steven Genusa long ago.
*)

{$R-}
const
  Base64Table: array[0..63] of Char =
    ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/');

procedure BuildBase64(OutBuf: pChar; Index: Longint;
  Significant: Integer; Value: Longint);
var
  i: Integer;
begin
  for i := 3 downto Significant do
    begin
    OutBuf[Index +i] := '=';
    Value := Value shr 6;
    end;
  for i := Significant - 1 downto 0 do
    begin
    OutBuf[Index +i] := Base64Table[Value and 63];
    Value := Value shr 6;
    end;
end;

function Base64ToBinary(InBuf, OutBuf: pChar; InLen: Longint): Longint;
{ This routine converts a Base64 encoded stream back to the original
  binary stream. No real error checking is done except to ignore
  unexpected data. For example, only valid Base64 ascii characters
  are acted upon and Pad characters are ignored unless they are the
  last or next-to-last characters in the input buffer. Futhermore,
  any partially decoded data is ignored if the input stream is too
  short to contain 4 Base64 characters. }
var
  Value, InNdx, OutNdx: Longint;
  Count, Pad: Integer;
begin
  Value := 0;
  Count := 0;
  Pad := 0;
  OutNdx := 0;
  for InNdx := 0 to InLen - 1 do
    begin
      begin
      case InBuf[InNdx] of
        'A'..'Z':
          begin
          Value := (Value shl 6) + Longint(Ord(InBuf[InNdx])) - Longint(Ord('A'));
          Inc(Count);
          end;
        'a'..'z':
          begin
          Value := (Value shl 6) + Longint(Ord(InBuf[InNdx])) - Longint(Ord('a')) + Longint(26);
          Inc(Count);
          end;
        '0'..'9': 
          begin
          Value := (Value shl 6) + Longint(Ord(InBuf[InNdx])) - Longint(Ord('0')) + Longint(52);
          Inc(Count);
          end;
        '+': 
          begin
          Value := (Value shl 6) + 62;
          Inc(Count);
          end;
        '/': 
          begin
          Value := (Value shl 6) + 63;
          Inc(Count);
          end;
        '=': 
          begin
          if InNdx >= InLen - 2 then 
            begin
            Value := (Value shl 6);
            Inc(Count);
            Inc(Pad);
            end;
          end;
        end;
      end;
    { If we have decoded 4 characters then we need to build the
      output buffer. If any pad characters were detected then we
      adjust the values first to ensure we only generate as many
      output bytes as there originally were. }
    if Count = 4 then 
      begin
      Count := 3;
      if Pad = 1 then 
        begin {Only 16 bits were originally encoded }
        Value := Value shr 8;
        Count := 2;
        end
      else if Pad = 2 then 
        begin {Only 8 bits were originally encoded }
        Value := Value shr 16;
        Count := 1;
        end;
      for Pad := Count - 1 downto 0 do 
        begin
        OutBuf[OutNdx + Pad] := Chr(Value and 255);
        Value := Value shr 8;
        end;
      Inc(OutNdx, Count);
      Count := 0;
      Pad := 0;
      Value := 0;
      end;
    end;
  Result := OutNdx;
end;


function BinaryToBase64(InBuf, OutBuf: pChar; InLen: Longint; AWrap : Boolean): Longint;
var
  InNdx, OutNdx, Width: Longint;
begin
  InNdx := 0;
  OutNdx := 0;
  Width := 0;
  while InNdx + 3 <= InLen do
    begin
    BuildBase64(OutBuf, OutNdx, 4,
    (Longint(Ord(InBuf[InNdx])) shl 16) +
    (Longint(Ord(InBuf[InNdx + 1])) shl 8) +
      Longint(Ord(InBuf[InNdx + 2])));
    inc(OutNdx, 4);
    inc(Width, 4);
    if (Width = 76) and AWrap then
      begin
      OutBuf[OutNdx + 0] := #13;
      OutBuf[OutNdx + 1] := #10;
      Width := 0;
      inc(OutNdx, 2);
      end;
    InNdx := InNdx + 3;
    end;
  if InLen - InNdx = 2 then
    begin
    BuildBase64(OutBuf, OutNdx, 3,
    (Longint(Ord(InBuf[InNdx])) shl 16) + (Longint(Ord(InBuf[InNdx + 1])) shl 8));
    OutNdx := OutNdx + 4;
    end
  else if InLen - InNdx = 1 then
    begin
    BuildBase64(OutBuf, OutNdx, 2, Longint(Ord(InBuf[InNdx])) shl 16);
    OutNdx := OutNdx + 4;
    end;
  Result := OutNdx;
end;

function IdSoapBase64Encode(AStream : TStream; AWrap : Boolean) : String;
var
  LTemp : Pointer;
  LSize : Integer;
  LStr : TMemoryStream;
begin
  if AStream is TMemoryStream then
    begin
    LStr := AStream as TMemoryStream;
    GetMem(LTemp, Ceiling( (Ceiling(LStr.Size / 3) * 4) * (78/76))); // for wrapping space if we need it
    LSize := BinaryToBase64(PChar(LStr.memory), PChar(LTemp), LStr.Size, AWrap);
    if LSize > 0 then
      begin
      SetLength(result, LSize);
      Move(LTemp^, result[1], LSize);
      end
    else
      begin
      result := '';
      end;
    end
  else
    begin
    // load it all into RAM. First time reviewers are generally suspicious of this approach,
    // as an exorbitant RAM waster - but it will be cloned a couple of times later, so we
    // might as well go for speed
    LStr := TIdMemoryStream.create;
    try
      LStr.CopyFrom(AStream, 0);
      LStr.position := 0;
      result := IdSoapBase64Encode(LStr, AWrap);
    finally
      FreeAndNil(LStr);
    end;
    end;
end;

function IdSoapBase64Decode(AValue : String) : TMemoryStream;
var
  LTemp : Pointer;
  LSize : Integer;
begin
  result := TIdMemoryStream.create;
  if AValue <> '' then
    begin
    GetMem(LTemp, length(AValue));
    LSize := Base64ToBinary(pChar(AValue), pchar(LTemp), length(AValue));
    result.Size := LSize;
    move(LTemp^, result.Memory^, LSize);
    end;
end;

end.


