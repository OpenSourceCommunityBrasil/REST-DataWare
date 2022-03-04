unit uZlibLaz;

interface

Uses
 SysUtils, Classes, zlib{$IFDEF FPC}, zstream{$ENDIF};

  //Funções de Compressão e descompressão de Stream com ZLib
  Procedure ZCompressStream  (inStream,
                              outStream        : TStream;
                              CompressionLevel : TCompressionLevel = clDefault);
  Procedure ZDecompressStream(inStream,
                              outStream : TStream);


implementation

Uses
 uRESTDWConsts, DataUtils;

Procedure ZCompressStream  (inStream,
                            outStream        : TStream;
                            CompressionLevel : TCompressionLevel = clDefault);
Var
 DS        : TCompressionStream;
 Size      : DWInt64;
Begin
 inStream.Position := 0; // Goto Start of input stream
 DS := TCompressionstream.Create(CompressionLevel, outStream);
 Try
  Size              := inStream.Size;
  inStream.Position := 0;
  DS.Write(Size, SizeOf(DWInt64));
  DS.CopyFrom(inStream, inStream.Size);
 Finally
  DS.Free;
 End;
End;

{$IFDEF FPC}
Procedure ZDecompressStream(inStream, outStream : TStream);
Var
 D    : TDecompressionstream;
 B    : Array[1..CompressBuffer] of Byte;
 R    : Integer;
 Size : DWInt64;
Begin
 d := TDecompressionstream.Create(inStream);
 d.Read(Size, SizeOf(DWInt64));
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
Procedure ZDecompressStream(inStream,
                            outStream : TStream);
Var
 D    : TDecompressionstream;
 B    : Array[1..CompressBuffer] of Byte;
 R    : Integer;
 Size : DWInt64;
Begin
 d := TDecompressionstream.Create(inStream);
 d.Read(Size, SizeOf(DWInt64));
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

