//----------------------------------------------------------------------------
//
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://home.global.co.za/~jhorn
// Version     : 1.01
// Date        : 1 May 2001
// Description : A unit that used with OpenGL projects to load BMP, JPG and TGA
//               files from the disk or a resource file.
// Usage       : LoadTexture(Filename, TextureName, LoadFromResource);
//
//               eg : LoadTexture('logo.jpg', LogoTex, TRUE);
//                    will load a JPG texture from the resource included
//                    with the EXE. File has to be loaded into the Resource
//                    using this format  "logo JPEG logo.jpg"
//
//----------------------------------------------------------------------------
unit Textures;

interface

uses
  Windows, OpenGL, Graphics, Classes, JPEG, SysUtils;

function LoadTexture(Filename: String; var Texture: GLuint; LoadFromRes : Boolean): Boolean;

implementation

function gluBuild2DMipmaps(Target: GLenum; Components, Width, Height: GLint; Format, atype: GLenum; Data: Pointer): GLint; stdcall; external glu32;
procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external opengl32;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


{------------------------------------------------------------------}
{  Create the Texture                                              }
{------------------------------------------------------------------}
function CreateTexture(Width, Height, Format : Word; pData : Pointer) : Integer;
var
  Texture : GLuint;
begin
  glGenTextures(1, Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}
//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  {Texture does NOT blend with object background}

  { Select a filtering type. BiLinear filtering produces very good results with little performance impact
    GL_NEAREST               - Basic texture (grainy looking texture)
    GL_LINEAR                - BiLinear filtering
    GL_LINEAR_MIPMAP_NEAREST - Basic mipmapped texture
    GL_LINEAR_MIPMAP_LINEAR  - BiLinear Mipmapped texture
  }  

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }

  if Format = GL_RGBA then
    gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, pData)
  else
    gluBuild2DMipmaps(GL_TEXTURE_2D, 3, Width, Height, GL_RGB, GL_UNSIGNED_BYTE, pData);
//  glTexImage2D(GL_TEXTURE_2D, 0, 3, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);  // Use when not wanting mipmaps to be built by openGL

  result :=Texture;
end;


{------------------------------------------------------------------}
{  Load BMP textures                                               }
{------------------------------------------------------------------}
function LoadBMPTexture(Filename: String; var Texture : GLuint; LoadFromResource : Boolean) : Boolean;
var
  FileHeader: BITMAPFILEHEADER;
  InfoHeader: BITMAPINFOHEADER;
  Palette: array of RGBQUAD;
  BitmapFile: THandle;
  BitmapLength: LongWord;
  PaletteLength: LongWord;
  ReadBytes: LongWord;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;
  I : Integer;
  Width, Height : Integer;
  pData : Pointer;

  // used for loading from resource
  ResStream : TResourceStream;
begin
  result :=FALSE;

  if LoadFromResource then // Load from resource
  begin
    try
      ResStream := TResourceStream.Create(hInstance, PChar(copy(Filename, 1, Pos('.', Filename)-1)), 'BMP');
      ResStream.ReadBuffer(FileHeader, SizeOf(FileHeader));  // FileHeader
      ResStream.ReadBuffer(InfoHeader, SizeOf(InfoHeader));  // InfoHeader
      PaletteLength := InfoHeader.biClrUsed;
      SetLength(Palette, PaletteLength);
      ResStream.ReadBuffer(Palette, PaletteLength);          // Palette

      Width := InfoHeader.biWidth;
      Height := InfoHeader.biHeight;

      BitmapLength := InfoHeader.biSizeImage;
      if BitmapLength = 0 then
        BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

      GetMem(pData, BitmapLength);
      ResStream.ReadBuffer(pData^, BitmapLength);            // Bitmap Data
      ResStream.Free;
    except on
      EResNotFound do
      begin
        MessageBox(0, PChar('File not found in resource - ' + Filename), PChar('BMP Texture'), MB_OK);
        Exit;
      end
      else
      begin
        MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
        Exit;
      end;
    end;
  end
  else
  begin   // Load image from file
   Try
    BitmapFile := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
    if (BitmapFile = INVALID_HANDLE_VALUE) then begin
      MessageBox(0, PChar('Error opening ' + Filename), PChar('BMP Unit'), MB_OK);
      Exit;
    end;

    // Get header information
    ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
    ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);

    // Get palette
    PaletteLength := InfoHeader.biClrUsed;
    SetLength(Palette, PaletteLength);
    ReadFile(BitmapFile, Palette, PaletteLength, ReadBytes, nil);
    if (ReadBytes <> PaletteLength) then begin
      MessageBox(0, PChar('Error reading palette'), PChar('BMP Unit'), MB_OK);
      Exit;
    end;

    Width  := InfoHeader.biWidth;
    Height := InfoHeader.biHeight;
    BitmapLength := InfoHeader.biSizeImage;
    if BitmapLength = 0 then
      BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

    // Get the actual pixel data
    GetMem(pData, BitmapLength);
    ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes, nil);
    if (ReadBytes <> BitmapLength) then begin
      MessageBox(0, PChar('Error reading bitmap data'), PChar('BMP Unit'), MB_OK);
      Exit;
    end;
    CloseHandle(BitmapFile);
   Except

   End;
  end;
  Try
  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  for I :=0 to Width * Height - 1 do
  begin
   Front := Pointer(Integer(pData) + I*3);
   Back := Pointer(Integer(pData) + I*3 + 2);
   Temp := Front^;
   Front^ := Back^;
   Back^ := Temp;
  end;
   Texture :=CreateTexture(Width, Height, GL_RGB, pData);
   FreeMem(pData);
   result :=TRUE;
  Except
   FreeMem(pData);
   result :=TRUE;
  End;
end;


{------------------------------------------------------------------}
{  Load JPEG textures                                              }
{------------------------------------------------------------------}
Function LoadJPGTexture(Filename: String; var Texture: GLuint; LoadFromResource : Boolean) : Boolean;
Var
  Data : Array of LongWord;
  W, Width : Integer;
  H, Height : Integer;
  BMP : TBitmap;
  JPG : TJPEGImage;
  C : LongWord;
  Line : ^LongWord;
  ResStream : TResourceStream;      // used for loading from resource
begin
  Result := False;
  JPG    := TJPEGImage.Create;
  If LoadFromResource Then // Load from resource
   Begin
    Try
      ResStream := TResourceStream.Create(hInstance, PChar(copy(Filename, 1, Pos('.', Filename)-1)), 'JPEG');
      JPG.LoadFromStream(ResStream);
      ResStream.Free;
    Except on
      EResNotFound do
      Begin
        ResStream.Free;
        JPG.Free;
//        MessageBox(0, PChar('File not found in resource - ' + Filename), PChar('JPG Texture'), MB_OK);
        Exit;
      End
     Else
      Begin
        ResStream.Free;
        JPG.Free;
//        MessageBox(0, PChar('Couldn''t load JPG Resource - "'+ Filename +'"'), PChar('BMP Unit'), MB_OK);
        Exit;
      End;
    End;
   End
  Else
   Begin
    Try
      JPG.LoadFromFile(Filename);
    Except
      JPG.Free;
//      MessageBox(0, PChar('Couldn''t load JPG - "'+ Filename +'"'), PChar('BMP Unit'), MB_OK);
      Exit;
    End;
   End;
  // Create Bitmap
  BMP := TBitmap.Create;
  BMP.pixelformat := pf32bit;
  BMP.Width  := JPG.Width;
  BMP.Height := JPG.Height;
  BMP.canvas.draw(0, 0, JPG); // Copy the JPEG onto the Bitmap
  JPG.free;
  //  BMP.SaveToFile('D:\test.bmp');
  Width  := BMP.Width;
  Height := BMP.Height;
  SetLength(Data, Width * Height);
  For H := 0 To Height -1 Do
   Begin
    Line := BMP.scanline[Height -H -1];   // flip JPEG
    For W := 0 To Width -1 Do
     Begin
      c := Line^ and $FFFFFF; // Need to do a color swap
      Data[W+(H*Width)] := (((c and $FF) shl 16)+(c shr 16)+(c and $FF00)) or $FF000000;  // 4 channel.
      Inc(Line);
     End;
   End;
  BMP.free;
  Texture := CreateTexture(Width, Height, GL_RGBA, addr(Data[0]));
  Result  := True;
end;


{------------------------------------------------------------------}
{  Loads 24 and 32bpp (alpha channel) TGA textures                 }
{------------------------------------------------------------------}
function LoadTGATexture(Filename: String; var Texture: GLuint; LoadFromResource : Boolean): Boolean;
var
  TGAHeader : packed record   // Header type for TGA images
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array[0..4] of Byte;
    OrigX  : Array [0..1] of Byte;
    OrigY  : Array [0..1] of Byte;
    Width  : Array [0..1] of Byte;
    Height : Array [0..1] of Byte;
    BPP    : Byte;
    ImageInfo : Byte;
  end;
  TGAFile   : File;
  bytesRead : Integer;
  image     : Pointer;    {or PRGBTRIPLE}
  CompImage : Pointer;
  Width, Height : Integer;
  ColorDepth    : Integer;
  ImageSize     : Integer;
  BufferIndex : Integer;
  currentByte : Integer;
  CurrentPixel : Integer;
  I : Integer;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;

  ResStream : TResourceStream;      // used for loading from resource

  // Copy a pixel from source to dest and Swap the RGB color values
  procedure CopySwapPixel(const Source, Destination : Pointer);
  asm
    push ebx
    mov bl,[eax+0]
    mov bh,[eax+1]
    mov [edx+2],bl
    mov [edx+1],bh
    mov bl,[eax+2]
    mov bh,[eax+3]
    mov [edx+0],bl
    mov [edx+3],bh
    pop ebx
  end;

begin
  result :=FALSE;
  GetMem(Image, 0);
  if LoadFromResource then // Load from resource
  begin
    try
      ResStream := TResourceStream.Create(hInstance, PChar(copy(Filename, 1, Pos('.', Filename)-1)), 'TGA');
      ResStream.ReadBuffer(TGAHeader, SizeOf(TGAHeader));  // FileHeader
      result :=TRUE;
    except on
      EResNotFound do
      begin
        MessageBox(0, PChar('File not found in resource - ' + Filename), PChar('TGA Texture'), MB_OK);
        Exit;
      end
      else
      begin
        MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
        Exit;
      end;
    end;
  end
  else
  begin
    if FileExists(Filename) then
    begin
      AssignFile(TGAFile, Filename);
      Reset(TGAFile, 1);

      // Read in the bitmap file header
      BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));
      result :=TRUE;
    end
    else
    begin
      MessageBox(0, PChar('File not found  - ' + Filename), PChar('TGA Texture'), MB_OK);
      Exit;
    end;
  end;

  if Result = TRUE then
  begin
    Result :=FALSE;

    // Only support uncompressed images
    if (TGAHeader.ImageType <> 2) And  { TGA_RGB }
       (TGAHeader.ImageType <> 10) then  { Compressed RGB }
    begin
      Result := False;
      CloseFile(tgaFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Compressed TGA files not supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
    end;

    // Don't support colormapped files
    if TGAHeader.ColorMapType <> 0 then
    begin
      Result := False;
      CloseFile(TGAFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Colormapped TGA files not supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
    end;

    // Get the width, height, and color depth
    Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
    Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
    ColorDepth := TGAHeader.BPP;
    ImageSize  := Width*Height*(ColorDepth div 8);

    if ColorDepth < 24 then
    begin
      Result := False;
      CloseFile(TGAFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 bit TGA files supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
    end;

    GetMem(Image, ImageSize);

    if TGAHeader.ImageType = 2 then   // Standard 24, 32 bit TGA file
    begin
      if LoadFromResource then // Load from resource
      begin
        try
          ResStream.ReadBuffer(Image^, ImageSize);
          ResStream.Free;
        except
          MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
          Exit;
        end;
      end
      else         // Read in the image from file
      begin
        BlockRead(TGAFile, image^, ImageSize, bytesRead);
        if bytesRead <> ImageSize then
        begin
          Result := False;
          CloseFile(TGAFile);
          MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
          Exit;
        end
      end;

      // TGAs are stored BGR and not RGB, so swap the R and B bytes.
      // 32 bit TGA files have alpha channel and gets loaded differently
      if TGAHeader.BPP = 24 then
      begin
        for I :=0 to Width * Height - 1 do
        begin
          Front := Pointer(Integer(Image) + I*3);
          Back := Pointer(Integer(Image) + I*3 + 2);
          Temp := Front^;
          Front^ := Back^;
          Back^ := Temp;
        end;
        Texture :=CreateTexture(Width, Height, GL_RGB, Image);
      end
      else
      begin
        for I :=0 to Width * Height - 1 do
        begin
          Front := Pointer(Integer(Image) + I*4);
          Back := Pointer(Integer(Image) + I*4 + 2);
          Temp := Front^;
          Front^ := Back^;
          Back^ := Temp;
        end;
        Texture :=CreateTexture(Width, Height, GL_RGBA, Image);
      end;
    end;

    // Compressed 24, 32 bit TGA files
    if TGAHeader.ImageType = 10 then
    begin
      ColorDepth :=ColorDepth DIV 8;
      CurrentByte :=0;
      CurrentPixel :=0;
      BufferIndex :=0;

      if LoadFromResource then // Load from resource
      begin
        try
          GetMem(CompImage, ResStream.Size-sizeOf(TGAHeader));
          ResStream.ReadBuffer(CompImage^, ResStream.Size-sizeOf(TGAHeader));   // load compressed date into memory
          ResStream.Free;
        except
          MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
          Exit;
        end;
      end
      else
      begin
        GetMem(CompImage, FileSize(TGAFile)-sizeOf(TGAHeader));
        BlockRead(TGAFile, CompImage^, FileSize(TGAFile)-sizeOf(TGAHeader), BytesRead);   // load compressed data into memory
        if bytesRead <> FileSize(TGAFile)-sizeOf(TGAHeader) then
        begin
          Result := False;
          CloseFile(TGAFile);
          MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
          Exit;
        end
      end;

      // Extract pixel information from compressed data
      repeat
        Front := Pointer(Integer(CompImage) + BufferIndex);
        Inc(BufferIndex);
        if Front^ < 128 then
        begin
          For I := 0 to Front^ do
          begin
            CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex+I*ColorDepth), Pointer(Integer(image)+CurrentByte));
            CurrentByte := CurrentByte + ColorDepth;
            inc(CurrentPixel);
          end;
          BufferIndex :=BufferIndex + (Front^+1)*ColorDepth
        end
        else
        begin
          For I := 0 to Front^ -128 do
          begin
            CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex), Pointer(Integer(image)+CurrentByte));
            CurrentByte := CurrentByte + ColorDepth;
            inc(CurrentPixel);
          end;
          BufferIndex :=BufferIndex + ColorDepth
        end;
      until CurrentPixel >= Width*Height;

      if ColorDepth = 3 then
        Texture :=CreateTexture(Width, Height, GL_RGB, Image)
      else
        Texture :=CreateTexture(Width, Height, GL_RGBA, Image);
    end;

    Result :=TRUE;
    FreeMem(Image);
  end;
end;


{------------------------------------------------------------------}
{  Determines file type and sends to correct function              }
{------------------------------------------------------------------}
function LoadTexture(Filename: String; var Texture : GLuint; LoadFromRes : Boolean) : Boolean;
begin
 If FileExists(filename) Then
  Begin
   if copy(filename, length(filename)-3, 4) = '.bmp' then
    LoadBMPTexture(Filename, Texture, LoadFromRes);
   if copy(filename, length(filename)-3, 4) = '.jpg' then
    LoadJPGTexture(Filename, Texture, LoadFromRes);
   if copy(filename, length(filename)-3, 4) = '.tga' then
    LoadTGATexture(Filename, Texture, LoadFromRes);
  End;  
end;


end.
