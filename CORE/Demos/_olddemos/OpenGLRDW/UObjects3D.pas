unit UObjects3D;

interface

uses
  Windows,
  Forms,
  Messages,
  Classes,
  OpenGL,
  ShellAPI,
  Sysutils,
  Graphics,
  Textures,
  VFW;

Const
 GridSize = 63;

Type
 TGLCoord = Record
  X, Y, Z : glFloat;
End;

Type
 TPrintArea = Set of (paDown, paUp, paLeft, paRight, paAhead, paBack);

Type
 TPathsTexturesCube = Array [0..5] of String;

Type
 TTexturesCube = Array [0..5] of glUint;

Type
 TFontSize = Record
   fBoxX, fBoxY : single;
End;

 TRGB = array[0..2] of byte;

Type
 TSpeedMatriz = Record
  X, Y, R, W, Z  : glFloat;
End;

Type
 THDC = ^HDC;

Type
 TText3D = class
  Private
  Protected
   // User vaiables
   vMaxChars       : Integer;
   vTextureFile,
   vFontName       : String;
   h_DC            : THDC;
   vWidth,
   vHeight,
   vLeft,
   vTop            : glFloat;
   vRotate         : Boolean;
   gFontSizes      : array[0..1023] of TFontSize;    // Buffer for character size information
   gFontList       : integer;                        // Handle to character display lists
   gTexture        : array[0..127, 0..127] of TRGB;  // Texture data
   gTextureHandle  : glUint;                         // Handle to OpenGL texture
   vLines          : TStringList;
   Function  CreateTexture(pWidth, pHeight: integer; pData: pointer): glUint;
   procedure glWrite3D(pText: string; pX, pY, pZ: single; pCenter: boolean);
   procedure CreateFont;
  Public
   vMaxRotate,
   xAngle,
   yAngle,
   zAngle          : glFloat;
   Constructor Create(vh_DC : THDC);
   Destructor  Destroy;
   procedure   DrawText;
   Property Rotate    : Boolean      Read vRotate     Write vRotate;
   Property Width     : glFloat      Read vWidth      Write vWidth;
   Property Height    : glFloat      Read vHeight     Write vHeight;
   Property FontName  : String       Read vFontName   Write vFontName;
   Property MaxChars  : Integer      Read vMaxChars   Write vMaxChars;
   Property Left      : glFloat      Read vLeft       Write vLeft;
   Property Top       : glFloat      Read vTop        Write vTop;
   Property Lines     : TStringList  Read vLines      Write vLines;
End;

Type
 TCube3D = class
  Private
   // User vaiables
   vTempAviFile,
   TextureFile : String;
   vVideoOpen : Boolean;
   // Textures
   VidTexture : glUint;
   // User vaiables
   AVIFile    : PAviFile;
   AVIStream  : PAviStream;
   AVIInfo    : TAVIFileInfo;
   StreamInfo : TAVIStreamInfo;
   ActiveFrame : Integer;
   AVIStart    : DWord;          // time avi started playing
   AVILength   : DWord;          // max length in milliseconds of the AVI
   FrameData   : Pointer;        // Pointer for the frame data
   GetFramePointer : Pointer;
  Protected
   //Textura
   TextureTex,
   //Textura Font
   texFont : glUint;
   // User vaiables
   vTop,
   vEixoZ,
   vWidth,
   vHeight,
   g_TextScroller,
   x, y, z  : glFloat;
   vSpeed : TSpeedMatriz;
   vDrawWater : Boolean;
   h_RC   : HGLRC;                    // OpenGL rendering context
   vMaxLines,
   ElapsedTime,             // Elapsed time between frames
   ElapsedTime2  : Integer;
   WaterTexture  : glUint;
   RainInterval  : Integer;
   DrawWedge,
   vDrawAlpha : Boolean;
   keys      : Array[0..255] of Boolean;   // Holds keystrokes
   h_DC      : THDC;
   // User vaiables
   MyQuadratic : gluQuadricObj;
   ReflectMirrorTex : GLuint;
   Position  : Array[0..GridSize, 0..GridSize] of glFloat;
   Velocity  : Array[0..GridSize, 0..GridSize] of glFloat;
   Viscosity : glFloat;
   VTextWrite : TStringList;
   Vertex : Array[0..GridSize, 0..GridSize] of TglCoord;
   Normals:array [0..GridSize, 0..GridSize] of TglCoord;
   vTypeDirections : TPrintArea;
   vTempPathsTexturesCube : TPathsTexturesCube;
   vInitSide : Real;
   Procedure OpenImage(FileToOpen :String);
   Procedure GravaSpeed(Speed : TSpeedMatriz);
   Function  LeSpeed : TSpeedMatriz;
   Function  LeX     : glFloat;
   Procedure GravaX(Value : glFloat);
   Function  LeY     : glFloat;
   Procedure GravaY(Value : glFloat);
   Function  LeZ     : glFloat;
   Procedure GravaZ(Value : glFloat);
   procedure glImgWrite(strText : string);
   Procedure PaintDrawWater;
   procedure CreateRainDrop;
   function  CreateTexture(Width, Height : Integer; pData : Pointer) : glUint;
   procedure OpenAVI(filename : String);
   procedure CloseAVI;
   procedure GetAVIFrame;
  Public
   xAngle,
   yAngle  : glFloat;
   PathsTexturesCube : TPathsTexturesCube;
   TexturesCube      : TTexturesCube;
   Procedure   ReloadTexturesCube;
   Procedure   DrawCube;
   Constructor Create(vh_DC : THDC);
   Destructor  Destroy;
   Property ImageFile   : String       Read TextureFile   Write OpenImage;
   Property AviFilePlay : String       Read vTempAviFile  Write OpenAVI;
   Property Top         : glFloat      Read vTop          Write vTop;
   Property PosX        : glFloat      Read LeX           Write GravaX;
   Property PosY        : glFloat      Read LeY           Write GravaY;
   Property PosZ        : glFloat      Read LeZ           Write GravaZ;
   Property EixoZ       : glFloat      Read vEixoZ        Write vEixoZ;
   Property Width       : glFloat      Read vWidth        Write vWidth;
   Property Height      : glFloat      Read vHeight       Write vHeight;
   Property Speed       : TSpeedMatriz Read LeSpeed       Write GravaSpeed;
   Property DrawWater   : Boolean      Read vDrawWater    Write vDrawWater;
   Property DrawAlpha   : Boolean      Read vDrawAlpha    Write vDrawAlpha;
   Property TextWrite   : TStringList  Read vTextWrite    Write vTextWrite;
   Property MaxLines    : Integer      Read vMaxLines     Write vMaxLines;
   Property PrintArea   : TPrintArea   Read vTypeDirections Write vTypeDirections;
   Property InitSide    : Real         Read vInitSide       Write vInitSide;
End;

Type
 TSprite3D = class
  Private
   vInitSide : Real;
   vVideoOpen : Boolean;
   // Textures
   VidTexture : glUint;
   // User vaiables
   AVIFile    : PAviFile;
   AVIStream  : PAviStream;
   AVIInfo    : TAVIFileInfo;
   StreamInfo : TAVIStreamInfo;
   ActiveFrame : Integer;
   AVIStart    : DWord;          // time avi started playing
   AVILength   : DWord;          // max length in milliseconds of the AVI
   FrameData   : Pointer;        // Pointer for the frame data
   GetFramePointer : Pointer;
  Protected
   // User vaiables
   vTempAviFile,
   TextureFile   : String;
   //Textura
   TextureTex    : glUint;
   // User vaiables
   vTop,
   vEixoZ,
   vWidth,
   vHeight,
   x, y, z  : glFloat;
   vSpeed : TSpeedMatriz;
   h_DC      : THDC;
   h_RC   : HGLRC;                    // OpenGL rendering context
   ElapsedTime,             // Elapsed time between frames
   ElapsedTime2 : Integer;
   vDrawAlpha : Boolean;
   Procedure OpenImage(FileToOpen :String);
   Procedure GravaSpeed(Speed : TSpeedMatriz);
   Function  LeSpeed : TSpeedMatriz;
   Function  LeX     : glFloat;
   Procedure GravaX(Value : glFloat);
   Function  LeY     : glFloat;
   Procedure GravaY(Value : glFloat);
   Function  LeZ     : glFloat;
   Procedure GravaZ(Value : glFloat);
   function  CreateTexture(Width, Height : Integer; pData : Pointer) : glUint;
   procedure OpenAVI(filename : String);
   procedure CloseAVI;
   procedure GetAVIFrame;
  Public
   xAngle,
   yAngle      : glFloat;
   Procedure   DrawSprite;
   Constructor Create(vh_DC : THDC);
   Destructor  Destroy;
   Property ImageFile : String       Read TextureFile   Write OpenImage;
   Property AviFilePlay : String     Read vTempAviFile  Write OpenAVI;
   Property Top       : glFloat      Read vTop          Write vTop;
   Property PosX      : glFloat      Read LeX           Write GravaX;
   Property PosY      : glFloat      Read LeY           Write GravaY;
   Property PosZ      : glFloat      Read LeZ           Write GravaZ;
   Property EixoZ     : glFloat      Read vEixoZ        Write vEixoZ;
   Property Width     : glFloat      Read vWidth        Write vWidth;
   Property Height    : glFloat      Read vHeight       Write vHeight;
   Property Speed     : TSpeedMatriz Read LeSpeed       Write GravaSpeed;
   Property DrawAlpha : Boolean      Read vDrawAlpha    Write vDrawAlpha;
   Property InitSide  : Real         Read vInitSide     Write vInitSide;
End;

Var
 gGlobalAmbient  : array[0..3] of glFloat = (1.0, 1.0, 1.0, 1.0); // Set Ambient Lighting
 gLight0Pos      : array[0..3] of glFloat = (0.0, 5.0, 0.0, 1.0); // Position for Light0
 gLight0Ambient  : array[0..3] of glFloat = (0.2, 0.2, 0.2, 1.0); // Ambient setting for light0
 gLight0Diffuse  : array[0..3] of glFloat = (1.0, 1.0, 1.0, 1.0); // Diffuse setting for Light0
 gLight0Specular : array[0..3] of glFloat = (0.8, 0.8, 0.8, 1.0); // Specular lighting for Light0
 gLModelAmbient  : array[0..3] of glFloat = (1.0, 1.0, 1.0, 1.0); // And More Ambient Light

implementation

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;
procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external opengl32;
procedure glTexSubImage2D(target, level: GLenum; xoffset, yoffset : GLint; width, height : GLsizei; format, _type : glEnum; pixels : Pointer); stdcall; external opengl32 name 'glTexSubImage2D';


Function InsertSP(Texto : String; Quantidade : Integer) : String;
Var
 I : Integer;
Begin
 Result := Texto;
 For I := Length(Result) To Quantidade Do
  Insert(' ', Result, Length(Result) + 1);
End;

Destructor  TSprite3D.Destroy;
Begin

End;

function TCube3D.CreateTexture(Width, Height : Integer; pData : Pointer) : glUint;
begin
 glGenTextures(1, result);
 glBindTexture(GL_TEXTURE_2D, result);
 glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }
 glTexImage2D(GL_TEXTURE_2D, 0, 3, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);
end;

procedure TCube3D.OpenAVI(filename : String);
begin
  vTempAviFile := '';
  If (filename = '') And (vVideoOpen) Then
   CloseAVI;
  AVIFileInit;
 If (AVIFileOpen(AviFile, PAnsiChar(FileName), OF_READ or OF_SHARE_DENY_WRITE, nil) = 0) And (filename <> '') then
  Begin
   vTempAviFile := filename;
   vVideoOpen   := True;
   AVIFileInfo(AVIFile, @AVIInfo, SizeOf(AviInfo));
   AVIStreamOpenFromFile(AVIStream, PAnsiChar(FileName), streamtypeVIDEO, 0, OF_READ, nil);
   AVIStreamInfo(AVIStream, @StreamInfo, SizeOf(StreamInfo));
   AVILength :=AVIStreamLengthTime(AVIStream);
   GetMem(FrameData, AVIInfo.dwWidth*AVIInfo.dwHeight*3);        // Allocate a buffer for the bitmap data.
   GetFramePointer :=AVIStreamGetFrameOpen(AVIStream, nil);						// Create The PGETFRAME	Using Our Request Mode
   VidTexture := CreateTexture(AviInfo.dwWidth, AviInfo.dwHeight, FrameData);      // Create a texture object.
  End
 Else If (filename <> '') Then
  MessageBox(0, 'Falha ao abrir o Stream AVI...', 'Erro...', MB_OK OR  MB_ICONERROR);
end;

{------------------------------------------------------------------}
{  Close the AVI video stream                                      }
{------------------------------------------------------------------}
procedure TCube3D.CloseAVI;
begin
  AVIStreamRelease(AVIStream);
  AVIFileClose(AVIFile);
  AVIFileExit;
  vVideoOpen   := False;
end;

procedure SwapRGB(data : Pointer; size : Integer);
asm
  mov ebx, eax    // data
  mov ecx, edx    // Size

@@loop :
  mov al,[ebx+0]  // Red  // Loads Value At ebx Into al
  mov ah,[ebx+2]  // Blue // Loads Value At ebx+2 Into ah
  mov [ebx+2],al  // Stores Value In al At ebx+2
  mov [ebx+0],ah  // Stores Value In ah At ebx

  add ebx,3 // Moves Through The Data By 3 Bytes
  dec ecx   // Decreases Our Loop Counter
  jnz @@loop
end;

{------------------------------------------------------------------}
{  Get the next frame of the AVI video clip                        }
{------------------------------------------------------------------}
procedure TCube3D.GetAVIFrame;
var
 Frame : Integer;
 AVIElapsedTime : DWord;
 vtemph_DC : HDC;
 BMP : ^TBITMAPINFOHEADER;
begin
  // Get the elapsed time. If the elapsed time is longer than the
  // video clip, then reset the elapsed time and video start
  AVIElapsedTime :=GetTickCount() - AVIStart;
  if AVIElapsedTime > AVILength then
  begin
    AVIStart :=GetTickCount();
    AVIElapsedTime :=0;
  end;

  // Get the next frame based on the elaped time
  Frame :=AVIStreamTimeToSample(AVIStream, AVIElapsedTime);
  if Frame <> ActiveFrame then
  begin
    ActiveFrame :=Frame;
{    // use this for uncompressed video ONLY
    AVIStreamRead(AviStream, Frame, 1, FrameData, AviInfo.dwWidth*AviInfo.dwHeight*3, nil, nil);
}
    // use this for compressed video
    BMP := AVIStreamGetFrame(GetFramePointer, frame);
    FrameData := Pointer(Cardinal(BMP) + BMP.biSize + BMP.biClrUsed*sizeof(RGBQUAD));
    // the drawdib function will uncompress the framedata as it tries to copy the BMP
    vtemph_DC := H_DC^;
//    DrawDibDraw(0, vtemph_DC, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, @BMP, FrameData, 0, 0, AVIInfo.dwWidth, AVIInfo.dwHeight, 0);   	// Convert Data To Requested Bitmap Format
    DrawDibDraw(0, vtemph_DC, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, @BMP, FrameData, 0, 0, AVIInfo.dwWidth, AVIInfo.dwHeight, 0);   	// Convert Data To Requested Bitmap Format
{    // use this for uncompressed video ONLY
//    SwapRGB(FrameData, AviInfo.dwWidth * AviInfo.dwHeight);  // Swap the BGR image to a RGB image
//    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
}
  end;
end;

function TSprite3D.CreateTexture(Width, Height : Integer; pData : Pointer) : glUint;
begin
 glGenTextures(1, result);
 glBindTexture(GL_TEXTURE_2D, result);
 glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }
 glTexImage2D(GL_TEXTURE_2D, 0, 3, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);
end;

procedure TSprite3D.OpenAVI(filename : String);
begin
  vTempAviFile := '';
  If (filename = '') And (vVideoOpen) Then
   CloseAVI;
  AVIFileInit;
 If (AVIFileOpen(AviFile, PAnsiChar(FileName), OF_READ or OF_SHARE_DENY_WRITE, nil) = 0) And (filename <> '') then
  Begin
   vTempAviFile := filename;
   vVideoOpen   := True;
   AVIFileInfo(AVIFile, @AVIInfo, SizeOf(AviInfo));
   AVIStreamOpenFromFile(AVIStream, PAnsiChar(FileName), streamtypeVIDEO, 0, OF_READ, nil);
   AVIStreamInfo(AVIStream, @StreamInfo, SizeOf(StreamInfo));
   AVILength :=AVIStreamLengthTime(AVIStream);
   GetMem(FrameData, AVIInfo.dwWidth*AVIInfo.dwHeight*3);        // Allocate a buffer for the bitmap data.
   GetFramePointer :=AVIStreamGetFrameOpen(AVIStream, nil);						// Create The PGETFRAME	Using Our Request Mode
   VidTexture := CreateTexture(AviInfo.dwWidth, AviInfo.dwHeight, FrameData);      // Create a texture object.
  End
 Else If (filename <> '') Then
  MessageBox(0, 'Falha ao abrir o Stream AVI...', 'Erro...', MB_OK OR  MB_ICONERROR);
end;

{------------------------------------------------------------------}
{  Close the AVI video stream                                      }
{------------------------------------------------------------------}
procedure TSprite3D.CloseAVI;
begin
  AVIStreamRelease(AVIStream);
  AVIFileClose(AVIFile);
  AVIFileExit;
  vVideoOpen   := False;
end;

{------------------------------------------------------------------}
{  Get the next frame of the AVI video clip                        }
{------------------------------------------------------------------}
procedure TSprite3D.GetAVIFrame;
var
 Frame : Integer;
 AVIElapsedTime : DWord;
 vtemph_DC : HDC;
 BMP : ^TBITMAPINFOHEADER;
begin
  // Get the elapsed time. If the elapsed time is longer than the
  // video clip, then reset the elapsed time and video start
  AVIElapsedTime :=GetTickCount() - AVIStart;
  if AVIElapsedTime > AVILength then
  begin
    AVIStart :=GetTickCount();
    AVIElapsedTime :=0;
  end;

  // Get the next frame based on the elaped time
  Frame :=AVIStreamTimeToSample(AVIStream, AVIElapsedTime);
  if Frame <> ActiveFrame then
  begin
    ActiveFrame := Frame;
{    // use this for uncompressed video ONLY
    AVIStreamRead(AviStream, Frame, 1, FrameData, AviInfo.dwWidth*AviInfo.dwHeight*3, nil, nil);
}
    // use this for compressed video
    BMP := AVIStreamGetFrame(GetFramePointer, frame);
    FrameData := Pointer(Cardinal(BMP) + BMP.biSize + BMP.biClrUsed*sizeof(RGBQUAD));
    vtemph_DC := H_DC^;
    // the drawdib function will uncompress the framedata as it tries to copy the BMP
    DrawDibDraw(0, vtemph_DC, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, @BMP, FrameData, 0, 0, AVIInfo.dwWidth, AVIInfo.dwHeight, 0);   	// Convert Data To Requested Bitmap Format
{    // use this for uncompressed video ONLY
//    SwapRGB(FrameData, AviInfo.dwWidth * AviInfo.dwHeight);  // Swap the BGR image to a RGB image
//    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
}
  end;
end;

Constructor TSprite3D.Create(vh_DC : THDC);
Var
 J, I : Integer;
Begin
 vSpeed.X := 0.1;   // start with some movement
 vSpeed.Y := 0.0;
 vSpeed.R := 0;
 vSpeed.Z := 0;
 vSpeed.W := 0;
 h_DC     := vh_DC;
 X        := 0.0;
 Y        := 0.0;
 Z        := 0.0;
 vTop     := 0.0;
 vEixoZ   := 1.3;
 glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);    // Realy Nice perspective calculations
 glEnable(GL_TEXTURE_2D);               // Enable Texture Mapping
 vDrawAlpha := False;
 Randomize;
 glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
 glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
 glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do
 glBlendFunc(GL_SRC_COLOR, GL_ONE);
End;

Procedure TSprite3D.DrawSprite;
Var
  DemoStart, LastTime : DWord;
  vMaxD, I : Integer;
  VAtuaTop : glFloat;
Begin
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);
//  SwapBuffers(h_DC^);
  ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
  ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement
// Grava a matriz de Dados
  glpushMatrix();
//Gera o Eixo das cameras
  glTranslatef(PosY, Top, PosX);
  glScalef(vWidth, vHeight, EixoZ);

  {--- There are two types of movement. Select the type you want to use ---}
  { For movement that requires used input use ... }
  If (vSpeed.Z <> 0) And (yAngle = 0) Then
   yAngle := vSpeed.Z;
  If (vSpeed.W <> 0) And (xAngle = 0)  Then
   xAngle := vSpeed.W;
  glRotatef(xAngle, 1, 0, 0);
  glRotatef(yAngle+ InitSide, 0, 1, 0);
  If vSpeed.R <> 0 Then
   glTranslatef(0, 0, vSpeed.R);
//   glRotatef(, 0, 0, 0);
  { For movement that requires a constant speed on all machines use ... }
//   glRotatef(ElapsedTime/20, 1, 0, 0);
//   glRotatef(ElapsedTime/30, 0, 1, 0);
  If vDrawAlpha Then
   Begin
//    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glEnable(GL_ALPHA_TEST);
   End;
  If AviFilePlay = '' Then
   Begin
    glClear(GL_TEXTURE_2D);    // Clear The Screen 2D
    glBindTexture(GL_TEXTURE_2D, TextureTex); // Bind the Texture to the object
   End 
  Else
   Begin
    GetAVIFrame;
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
   End;
  If vDrawAlpha Then
   glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  //Inicializa a Pintura do Objeto
  glBegin(GL_QUADS);
  glNormal3f( 0.0, 0.0, PosZ);
  glTexCoord2f(0.0, 0.0);
  glVertex3f(PosZ * -1, PosZ * -1,  PosZ);
  glTexCoord2f(1.0, 0.0);
  glVertex3f( PosZ, PosZ * -1,  PosZ);
  glTexCoord2f(1.0, 1.0);
  glVertex3f( PosZ,  PosZ,  PosZ);
  glTexCoord2f(0.0, 1.0);
  glVertex3f(PosZ * -1,  PosZ,  PosZ);
  //Finaliza a Pintura do Objeto
  glEnd();
  glPopMatrix();
  If vDrawAlpha Then
   Begin
    glDisable(GL_BLEND);
    glDisable(GL_ALPHA_TEST);
   End;
  xAngle :=xAngle + vSpeed.X;
  yAngle :=yAngle + vSpeed.Y;
End;

Function  TSprite3D.LeX : glFloat;
Begin
 Result := X;
End;

Procedure TSprite3D.GravaX(Value : glFloat);
Begin
 X := Value;
End;

Function  TSprite3D.LeY     : glFloat;
Begin
 Result := Y;
End;

Procedure TSprite3D.GravaY(Value : glFloat);
Begin
 Y := Value;
End;

Function  TSprite3D.LeZ     : glFloat;
Begin
 Result := Z;
End;

Procedure TSprite3D.GravaZ(Value : glFloat);
Begin
 Z := Value;
End;

Function  TSprite3D.LeSpeed : TSpeedMatriz;
Begin
 Result := vSpeed;
End;

Procedure TSprite3D.GravaSpeed(Speed : TSpeedMatriz);
Begin
 vSpeed.X := Speed.X;
 vSpeed.Y := Speed.Y;
 vSpeed.Z := Speed.Z;
 vSpeed.W := Speed.W;
 vSpeed.R := Speed.R;
End;

Procedure TSprite3D.OpenImage(FileToOpen :String);
Var
 VFileHandle : Integer;
Begin
 If TextureFile <> FileToOpen then
  Begin
   glEnable(GL_TEXTURE_2D);                     // Enable Texture Mapping
   glClear(GL_TEXTURE_2D);
   Try
    LoadTexture(FileToOpen, TextureTex, False);    // Load the Texture
   Except
   End;
  End;
 TextureFile := FileToOpen;
End;

procedure TText3D.CreateFont;
var
  bFont : HFONT;
  lFont : TFont;
begin
  lFont:= TFont.Create;
  lFont.Name:= vFontName;                  // Set the font name for the windows font
  lFont.Size := 10;
  bFont := lFont.Handle;
  SelectObject(h_DC^, bFont);      // Select font device context

  // Create display lists for each character in the font:
  gFontList:= glGenLists(256);
  wglUseFontOutlines(h_DC^,               // Device context of font -source-
                     0,                  // First character
                     255,                // Number of characters
                     gFontList,          // Handle of font display lists
                     0.0,                // This is the sampling tolerance. Higher values create less detailed outlines.
                     0.2,                // This is the extrusion depth.
                     WGL_FONT_POLYGONS,  // What kind of output? You can also use WGL_FONT_LINES
                     @gFontSizes);       // Array to store info about character sizes
  lFont.Free;
end; { glCreateFont }

procedure TText3D.DrawText;
Var
 I : Integer;
begin
 For I := 0 To vLines.Count -1 Do
  glWrite3D(vLines[I],  vLeft, vTop, xAngle, False);
//  glWrite3D(vLines[I],  vLeft, ((vTop) * (I + 1)), xAngle, False);
end; { glDraw }

procedure TText3D.glWrite3D(pText: string; pX, pY, pZ: single; pCenter: boolean);
var
  i  : integer;
  lX : single;
begin
  // Check empty string...
  if (pText = '') then Exit;

  lX:= pX;

  if pCenter then
  begin
    // Calculate the half width of the text...
    for i:= 1 to Length(pText) do
     lX:= lX - gFontSizes[Ord(pText[i])].fBoxX;
  end;

  glPushMatrix();

  // Center the text...
  glTranslatef(lX, pY, pZ);

  glScalef(vWidth, vHeight, 0.1);
  If Rotate Then
   Begin
    If Sin(GetTickCount() / 1000) * zAngle < vMaxRotate Then
     glRotatef(xAngle, yAngle, 15.0, Sin(GetTickCount() / 1000) * zAngle)
    Else
     glRotatef(xAngle, yAngle, 15.0, vMaxRotate);
   End
  Else
   glRotatef(xAngle, yAngle, 15.0, zAngle);   // Rotate arount Y
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, gTextureHandle);

  // Enable texture genarate...
  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);

  // Set the texture genarate mode, creates the texture coordinates...
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);

  // Set the font list...
  glListBase(gFontList);

  glCallLists(Length(pText),      // Length of the string
              GL_UNSIGNED_BYTE,   // Chars, one byte each
              @pText[1]);         // Pointer to the first char of the string

  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);

  glPopMatrix();
end; { glWrite3D }

Function TText3D.CreateTexture(pWidth, pHeight: integer; pData: pointer): glUint;
begin
  glGenTextures(1, Result);
  glBindTexture(GL_TEXTURE_2D, Result);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, 3, pWidth, pHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);
end; { CreateTexture }

Constructor TText3D.Create(vh_DC : THDC);
Begin
 vLines := TStringList.Create;
 vFontName := 'ARIAL';
 vTextureFile := 'fonttext';
 h_DC   := vh_DC;
 zAngle := 42.0;
 vTop   := 0.10;
 vMaxChars := 20;
 vRotate   := False;
 // Create a texture with 16 red and white rectangles...
 LoadTexture(Format('%sskin\3d\model\multicenter\%s.jpg', [ExtractFilePath(Application.Exename), 'fonttext']),
             gTextureHandle, False);    // Load the Texture
 CreateFont;
End;

Destructor  TText3D.Destroy;
Begin

End;

Procedure TCube3D.ReloadTexturesCube;
 Function TestaLoad(Var Loadpaths, ComparePaths : TPathsTexturesCube) : Boolean;
 Var
  I : Integer;
 Begin
  Result := False;
  For I := 0 To Length(PathsTexturesCube) -1 Do
   Begin
    Result := Loadpaths[I] = ComparePaths[I];
    If Not Result Then
     Break;
   End;
  If Not Result Then
   For I := 0 To Length(PathsTexturesCube) -1 Do
    Begin
     ComparePaths[I] := Loadpaths[I];
    End;
 End;
Var
 I : Integer;
Begin
 If Not TestaLoad(PathsTexturesCube, vTempPathsTexturesCube) Then
  Begin
   For I := 0 To Length(PathsTexturesCube) -1 Do
    Begin
     If PathsTexturesCube[I] <> '' Then
      LoadTexture(PathsTexturesCube[I], TexturesCube[I], False);
    End;
  End;
End;

procedure TCube3D.glImgWrite(strText : string);
var I, intAsciiCode : integer;
    imgcharWidth : GLfloat;
    imgcharPosX : GLfloat;
begin
  imgcharWidth := 1.0/65.993;
  strText := UpperCase(strText);
  glpushMatrix();
  for I := 1 to length(strText) do
  begin
    if ord(strText[I]) > 31 then //only handle 66 chars
    begin
      intAsciiCode := ord(strText[I]) - 32;
      imgcharPosX := length(strText)/2*0.08-length(strText)*0.08 + (i-1) * 0.08; // Find the character position from the origin [0.0 , 0.0 , 0.0]  to center the text
      glBegin(GL_QUADS);

        glTexCoord2f(imgcharWidth*intAsciiCode, 0.0);
        glVertex3f(-0.04+imgcharPosX, -0.04,  0.0);

        glTexCoord2f(imgcharWidth*intAsciiCode+imgcharWidth, 0.0);
        glVertex3f( 0.04+imgcharPosX, -0.04,  0.0);

        glTexCoord2f(imgcharWidth*intAsciiCode+imgcharWidth, 1.0);
        glVertex3f( 0.04+imgcharPosX,  0.04,  0.0);

        glTexCoord2f(imgcharWidth*intAsciiCode, 1.0);
        glVertex3f(-0.04+imgcharPosX,  0.04,  0.0);
      glEnd;
    end;
  end;
  glpopMatrix();
end;

Function  TCube3D.LeX : glFloat;
Begin
 Result := X;
End;

Procedure TCube3D.GravaX(Value : glFloat);
Begin
 X := Value;
End;

Function  TCube3D.LeY     : glFloat;
Begin
 Result := Y;
End;

Procedure TCube3D.GravaY(Value : glFloat);
Begin
 Y := Value;
End;

Function  TCube3D.LeZ     : glFloat;
Begin
 Result := Z;
End;

Procedure TCube3D.GravaZ(Value : glFloat);
Begin
 Z := Value;
End;

Function  TCube3D.LeSpeed : TSpeedMatriz;
Begin
 Result := vSpeed;
End;

Procedure TCube3D.GravaSpeed(Speed : TSpeedMatriz);
Begin
 vSpeed.X := Speed.X;
 vSpeed.Y := Speed.Y;
 vSpeed.Z := Speed.Z;
 vSpeed.W := Speed.W;
End;

Procedure TCube3D.OpenImage(FileToOpen :String);
Var
 VFileHandle : Integer;
Begin
 If (TextureFile <> FileToOpen) then
  Begin
   glEnable(GL_TEXTURE_2D);                     // Enable Texture Mapping
   glClear(GL_TEXTURE_2D);
   Try
    If FileToOpen <> '' Then
     LoadTexture(FileToOpen, TextureTex, False);    // Load the Texture
   Except
   End;
  End;
 TextureFile := FileToOpen;
End;

procedure TCube3D.CreateRainDrop;
begin
  Velocity[random(GridSize-4)+2, random(GridSize-4)+2] :=1060;
end;

procedure TCube3D.PaintDrawWater;
Var
 I, J : Integer;
 VectLength : glFloat;
 Speed : glFloat;
begin
  Speed :=ElapsedTime - ElapsedTime2;
  Speed :=Speed/7;
  CreateRainDrop;
  // Calculate new velocity
  For I :=2 to GridSize-2 do
    For J :=2 to GridSize-2 do
      Velocity[I, J] := Velocity[I, J] + (Position[I, J] -
              (4*(Position[I-1,J] + Position[I+1,J] + Position[I,J-1] + Position[I,J+1]) +  // left, right, above, below
              Position[I-1,J-1] + Position[I+1,J-1] + Position[I-1,J+1] + Position[I+1,J+1])/25) / 7;  // diagonally across

  // Calculate the new ripple positions
  For I:=2 to GridSize-2 do
    For J:=2 to GridSize-2 do
    Begin
      Position[I, J] := Position[I, J] - Velocity[I,J]*Speed;
      Velocity[I, J] := Velocity[I, J] * Viscosity;
    End;

  // Calculate the new vertex coordinates
  For I :=0 to GridSize do
    For J :=0 to GridSize do
    begin
      Vertex[I, J].X :=(I - GridSize/2)/GridSize*2;
      Vertex[I, J].Y :=(Position[I, J]/Speed / 1024)/GridSize*2;
      Vertex[I, J].Z :=(J - GridSize/2)/GridSize*2;
    end;

  // Calculate the new vertex normals.
  // Do this by using the points to each side to get the right angle
  For I :=0 to GridSize do
  begin
    For J :=0 to GridSize do
    begin
      If (I > 0) and (J > 0) and (I < GridSize) and (J < GridSize) then
      begin
        with Normals[I, J] do
        begin
          X := Position[I+1, J] - Position[I-1,J];
          Y := -2048;
          Z := Position[I, J+1] - Position[I, J-1];

          VectLength :=sqrt(x*x + y*y + z*z);
          if VectLength <> 0 then
          begin
            X :=X/VectLength;
            Y :=Y/VectLength;
            Z :=Z/VectLength;
          end;
        end;
      end
      else
      begin
        Normals[I, J].X := 0;
        Normals[I, J].Y := 1;
        Normals[I, J].Z := 0;
      end;
    end;
  end;

  // Draw the water texture
  glBindTexture(GL_TEXTURE_2D, WaterTexture);
  For J :=0 to GridSize-1 do
  begin
    glpushMatrix();
    glFrontFace(GL_CW);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glDepthFunc(GL_LESS);
//    glColor3f(J/100,J/100,J/100);
    glBegin(GL_QUAD_STRIP);
      for I :=0 to GridSize do
      begin
        glNormal3fv(@Normals[I, J+1]);
//        glTexCoord2f(I/GridSize, (J+1)/GridSize);
        glVertex3fv(@Vertex[I, J+1]);
        glNormal3fv(@Normals[I, J]);
//        glTexCoord2f(I/GridSize, J/GridSize);
        glVertex3fv(@Vertex[I, J]);
      end;
    glEnd;
    glpopMatrix();
  end;
  ElapsedTime2 :=ElapsedTime;
end;

Constructor TCube3D.Create(vh_DC : THDC);
Var
 J, I : Integer;
Begin
 vSpeed.X := 0.1;   // start with some movement
 vSpeed.Y := 0.2;
 vSpeed.Z := 0;
 vSpeed.W := 0;
 h_DC     := vh_DC;
 X        := 0.0;
 Y        := 0.0;
 Z        := 0.0;
 vTop     := 0.0;
 vEixoZ   := 1.35;
 vMaxLines := 8;
 g_TextScroller := 0;
 VTextWrite := TStringList.Create;
 glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);    // Realy Nice perspective calculations
 glEnable(GL_TEXTURE_2D);               // Enable Texture Mapping
 LoadTexture(Format('%sskin\3d\model\multicenter\%s.bmp', [ExtractFilePath(Application.Exename), 'reflection']),
             WaterTexture, False);    // Load the Texture

 LoadTexture(Format('%s%s.tga', [ExtractFilePath(Application.Exename), 'fontlines']), texFont, False);
  // enable spherical environment maping
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

  Viscosity :=0.96;
  For I :=0 to GridSize do
  begin
    For J :=0 to GridSize do
    begin
      Position[I, J] :=0;
      Velocity[I, J] :=0;
    end;
  end;
  vTypeDirections := [paDown, paUp, paLeft, paRight, paAhead, paBack];
  // Initializes the rain drop timer
  RainInterval :=1000;
//  SetTimer(Self.h_RC, RAIN_TIMER, RainInterval, nil);

  DrawWedge :=True;
  vDrawAlpha := False;
  Randomize;
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do
  glBlendFunc(GL_SRC_COLOR, GL_ONE);
//  xAngle :=32;
//  yAngle :=30;
End;

Destructor TCube3D.Destroy;
Begin
 Self := Nil;
 Inherited Destroy;
End;

Procedure TCube3D.DrawCube;
Var
  DemoStart, LastTime : DWord;
  vMaxD, I : Integer;
  VAtuaTop : glFloat;
Begin
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);
//  SwapBuffers(h_DC^);
//  ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
  ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement
// Grava a matriz de Dados
  glpushMatrix();
//Gera o Eixo das cameras
  glTranslatef(PosY, Top, PosX);
  glScalef(vWidth, vHeight, EixoZ);

  {--- There are two types of movement. Select the type you want to use ---}
  { For movement that requires used input use ... }
  If vSpeed.Z <> 0.0 Then
   yAngle := vSpeed.Z;
  If vSpeed.W <> 0.0 Then
   xAngle := vSpeed.W;
  glRotatef(xAngle, 1, 0, 0);
  glRotatef(yAngle+ InitSide, 0, 1, 0);
  { For movement that requires a constant speed on all machines use ... }
//   glRotatef(ElapsedTime/20, 1, 0, 0);
//   glRotatef(ElapsedTime/30, 0, 1, 0);
  If vDrawAlpha Then
   Begin
//    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glEnable(GL_ALPHA_TEST);
   End;
  If AviFilePlay = '' Then
   Begin
    glClear(GL_TEXTURE_2D);    // Clear The Screen 2D
    If PathsTexturesCube[0] <> '' Then
     glBindTexture(GL_TEXTURE_2D, TexturesCube[0])
    Else
     glBindTexture(GL_TEXTURE_2D, TextureTex);  // Bind the Texture to the object
   End
  Else
   Begin
    GetAVIFrame;
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
   End;
//   glBindTexture(GL_TEXTURE_2D, VidTexture);
  If paAhead In vTypeDirections Then
   Begin
    If vDrawAlpha Then
     glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    //Inicializa a Pintura do Objeto
    glBegin(GL_QUADS);
    // Front Face
  //  glNormal3f( 0.0, 0.0, 1.0);
    glNormal3f( 0.0, 0.0, PosZ);
    glTexCoord2f(0.0, 0.0);
    glVertex3f(PosZ * -1, PosZ * -1,  PosZ);
    glTexCoord2f(1.0, 0.0);
    glVertex3f( PosZ, PosZ * -1,  PosZ);
    glTexCoord2f(1.0, 1.0);
    glVertex3f( PosZ,  PosZ,  PosZ);
    glTexCoord2f(0.0, 1.0);
    glVertex3f(PosZ * -1,  PosZ,  PosZ);
    //Finaliza a Pintura do Objeto
    glEnd();
   End;
  If paBack In vTypeDirections Then
   Begin
    If vDrawAlpha Then
     glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    If AviFilePlay = '' Then
     Begin
      If PathsTexturesCube[1] <> '' Then
       glBindTexture(GL_TEXTURE_2D, TexturesCube[1])
      Else
       glBindTexture(GL_TEXTURE_2D, TextureTex);  // Bind the Texture to the object
     End
    Else
     glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
    //Inicializa a Pintura do Objeto
    glBegin(GL_QUADS);
    // Back Face
  //  glNormal3f( 0.0, 0.0,-1.0);
    glNormal3f( 0.0, 0.0, PosZ * -1);
    glTexCoord2f(1.0, 0.0);
    glVertex3f(PosZ * -1, PosZ * -1, PosZ * -1);
    glTexCoord2f(1.0, 1.0);
    glVertex3f(PosZ * -1,  PosZ, PosZ * -1);
    glTexCoord2f(0.0, 1.0);
    glVertex3f( PosZ,  PosZ, PosZ * -1);
    glTexCoord2f(0.0, 0.0);
    glVertex3f( PosZ, PosZ * -1, PosZ * -1);
    //Finaliza a Pintura do Objeto
    glEnd();
   End;
  If paUp In vTypeDirections Then
   Begin
    If vDrawAlpha Then
     glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    If AviFilePlay = '' Then
     Begin
      If PathsTexturesCube[2] <> '' Then
       glBindTexture(GL_TEXTURE_2D, TexturesCube[2])
      Else
       glBindTexture(GL_TEXTURE_2D, TextureTex);  // Bind the Texture to the object
     End
    Else
     glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
    //Inicializa a Pintura do Objeto
    glBegin(GL_QUADS);
    // Top Face
    glNormal3f( 0.0, 1.0, 0.0);
    glTexCoord2f(0.0, 1.0);
    glVertex3f(PosZ * -1,  PosZ, PosZ * -1);
    glTexCoord2f(0.0, 0.0);
    glVertex3f(PosZ * -1,  PosZ,  PosZ);
    glTexCoord2f(1.0, 0.0);
    glVertex3f(PosZ,  PosZ,  PosZ);
    glTexCoord2f(1.0, 1.0);
    glVertex3f( PosZ,  PosZ, PosZ * -1);
    //Finaliza a Pintura do Objeto
    glEnd();
   End;
  If paDown In vTypeDirections Then
   Begin
    If vDrawAlpha Then
     glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    If AviFilePlay = '' Then
     Begin
      If PathsTexturesCube[3] <> '' Then
       glBindTexture(GL_TEXTURE_2D, TexturesCube[3])
      Else
       glBindTexture(GL_TEXTURE_2D, TextureTex);  // Bind the Texture to the object
     End
    Else
     glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
    //Inicializa a Pintura do Objeto
    glBegin(GL_QUADS);
    // Bottom Face
    glNormal3f( 0.0,-1.0, 0.0);
    glTexCoord2f(1.0, 1.0);
    glVertex3f(PosZ * -1, PosZ * -1, PosZ * -1);
    glTexCoord2f(0.0, 1.0);
    glVertex3f( PosZ, PosZ * -1, PosZ * -1);
    glTexCoord2f(0.0, 0.0);
    glVertex3f( PosZ, PosZ * -1,  PosZ);
    glTexCoord2f(1.0, 0.0);
    glVertex3f(PosZ * -1, PosZ * -1,  PosZ);
    //Finaliza a Pintura do Objeto
    glEnd();
   End;
  If paRight In vTypeDirections Then
   Begin
    If vDrawAlpha Then
     glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    If AviFilePlay = '' Then
     Begin
      If PathsTexturesCube[4] <> '' Then
       glBindTexture(GL_TEXTURE_2D, TexturesCube[4])
      Else
       glBindTexture(GL_TEXTURE_2D, TextureTex);  // Bind the Texture to the object
     End
    Else
     glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
    //Inicializa a Pintura do Objeto
    glBegin(GL_QUADS);
    // Right face
    glNormal3f( 1.0, 0.0, 0.0);
    glTexCoord2f(1.0, 0.0);
    glVertex3f( PosZ, PosZ * -1, PosZ * -1);
    glTexCoord2f(1.0, 1.0);
    glVertex3f(PosZ,  PosZ, PosZ * -1);
    glTexCoord2f(0.0, 1.0);
    glVertex3f(PosZ,  PosZ,  PosZ);
    glTexCoord2f(0.0, 0.0);
    glVertex3f(PosZ, PosZ * -1,  PosZ);
    //Finaliza a Pintura do Objeto
    glEnd();
   End;
  If paLeft In vTypeDirections Then
   Begin
    If vDrawAlpha Then
     glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    If AviFilePlay = '' Then
     Begin
      If PathsTexturesCube[5] <> '' Then
       glBindTexture(GL_TEXTURE_2D, TexturesCube[5])
      Else
       glBindTexture(GL_TEXTURE_2D, TextureTex);  // Bind the Texture to the object
     End
    Else
     glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, AviInfo.dwWidth, AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Framedata);
    //Inicializa a Pintura do Objeto
    glBegin(GL_QUADS);
    // Left Face
    glNormal3f(-1.0, 0.0, 0.0);
    glTexCoord2f(0.0, 0.0);
    glVertex3f(PosZ * -1, PosZ * -1, PosZ * -1);
    glTexCoord2f(1.0, 0.0);
    glVertex3f(PosZ * -1, PosZ * -1,  PosZ);
    glTexCoord2f(1.0, 1.0);
    glVertex3f(PosZ * -1,  PosZ,  PosZ);
    glTexCoord2f(0.0, 1.0);
    glVertex3f(PosZ * -1,  PosZ, PosZ * -1);
    //Finaliza a Pintura do Objeto
    glEnd();
   End;
  glPopMatrix();
  If vDrawAlpha Then
   Begin
    glDisable(GL_BLEND);
    glDisable(GL_ALPHA_TEST);
    glEnable(GL_DEPTH_TEST);
   End;
  If vDrawWater Then
   Begin
//    glColor3f(0.85, 1, 0.85);
    If vDrawAlpha Then
     glDisable(GL_BLEND);
    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
//  DrawWater;
    PaintDrawWater;
   End;
  xAngle :=xAngle + vSpeed.X;
  yAngle :=yAngle + vSpeed.Y;
  If VTextWrite.Count > 0 Then
   Begin
    glPushMatrix();
    VAtuaTop :=  0.5;
    glEnable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, texFont);  // Bind the Texture to the object
    glTranslatef(PosY + 0.59, VAtuaTop, PosX + 0.3);
    glScalef(vWidth - 0.9, vHeight - 0.2, 1);
    glRotatef(41, -0.3, 30.0, 1);   // Rotate arount Y
    If VTextWrite.Count >= vMaxLines Then
     vMaxD := 7
    Else If VTextWrite.Count > 0 Then
     vMaxD := VTextWrite.Count -1
    Else
     vMaxD := 0;
    If vMaxD > 0 Then
    For I := 0 To vMaxD Do
     Begin
      If I > 0 Then
       glTranslatef(0, -0.12, 0);
      glImgWrite(InsertSP(Copy(VTextWrite[I], 1, 19), 19));
     End;
    glPopMatrix();
   End;
End;

end.
