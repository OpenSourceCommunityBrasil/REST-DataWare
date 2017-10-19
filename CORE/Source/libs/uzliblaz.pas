unit uZlibLaz;

interface

Uses
 SysUtils, Classes, zlib{$IFDEF FPC}, zstream{$ENDIF};

  //Funções de Compressão e descompressão de Stream com ZLib
  Procedure ZCompressStream  (inStream, outStream : TStream);
  Procedure ZDecompressStream(inStream, outStream : TStream);


implementation

Uses
 uDWConsts;

Procedure ZCompressStream  (inStream, outStream : TStream);
Var
 DS        : TCompressionStream;
 Size      : Longint;
Begin
 inStream.Position := 0; // goto start of input stream
 DS := TCompressionstream.Create(clDefault, outStream);
 Try
  Size              := inStream.Size;
  inStream.Position := 0;
  DS.Write(Size, 4); //SizeOf(Size));
  DS.CopyFrom(inStream, inStream.Size);
 Finally
  DS.Free;
 End;
End;


Function ReadDWord(Value : TStream) : Cardinal;
Var
 d    : Cardinal;
Begin
 Value.Position := 0;
 Value.ReadBuffer(d, 4);
 ReadDWord := d;
End;

{$IFDEF FPC}
Procedure ZDecompressStream(inStream, outStream : TStream);
Var
 D : TDecompressionstream;
 B : Array[1..CompressBuffer] of Byte;
 R : Integer;
 Size : Longint;
Begin
 d := TDecompressionstream.Create(inStream);
 d.Read(Size, 4); //SizeOf(Size));
 While True Do
  Begin
   R := d.Read(B, sizeof(B));
   If R <> 0 Then
    outStream.WriteBuffer(B, R)
   Else
    Break;
  End;
 outStream.Position := 0;
 FreeAndNil(d);
End;
{$ELSE}

Procedure ZDecompressStream(inStream, outStream : TStream);
Var
 D    : TDecompressionstream;
 B    : Array[1..CompressBuffer] of Byte;
 R    : Integer;
 Size : Longint;
Begin
 d := TDecompressionstream.Create(inStream);
 d.Read(Size, 4); //SizeOf(Size));
 inStream.Position := SizeOf(Size);
 Try
  Repeat
   If ((Size - outStream.Size) > CompressBuffer) Then
    R := d.Read(B, SizeOf(B))
   Else
    R := d.Read(B, (Size - outStream.Size));
   If R > 0 then
    outStream.Write(B, R);
  Until R < SizeOf(B);
 Finally
  outStream.Position := 0;
  d.Free;
 End;
End;

{$ENDIF}

end.

