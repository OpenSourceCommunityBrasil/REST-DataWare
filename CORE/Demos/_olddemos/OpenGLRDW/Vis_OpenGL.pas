// OpenGL Winamp Visulization Plug-in

// Author : Baris AKIN (4/9/2001)
// http://broken.tr8.net
// barisakin@iname.com

// BASE CODE
// J.Frankel        : Vis Plug-in in C++  (1997)
// N.M. Ismail      : Converted from original plug-in VC++ source to Delphi2/3. (1997)
// J. Crawford      : Additional testing and bugfixes.Bundled original C code. (1998)
// Jeff Molofee     : OpenGL code. http://nehe.gamedev.net (2000)
// Fredric Echols   : Optimizing OpenGL code and clean up. (2000)
// Marc Aarts       : Conversion OpenGL C++ code to Delphi. marca@stack.nl (2000)
// Peter De Jaegher : Conversion OpenGL C++ code to Delphi. Perry.dj@glo.be (2000)

// Version: 1.5
// Description: This unit is the basic structure for a WinAMP
//   visualization plug-in with OpenGL.

// Usage: To use the Vis unit, add this unit to the project and
//   customize the routines to your specifications.  Make sure
//   to not change the "TWinAMPVisHeader" and "TWinAMPVisModule"
//   structure for they are used by WinAMP itself.

// Test :
// Compiled with Delphi 4 and running under Winamp 2.5c
// Tested with 4MB graphic card (S3 Trio 2D). 32 MB RAM. PII 233 mhz.
// Everything goes so funny :-)

// Coder note :
// If you add something to this code please don't remove names and declarations shown up.
// Add your name and your work below the declarations.


unit Vis_OpenGL;
{$T+} // typed @ operator

{$R 'texbitmaps.res' 'texbitmaps.rc'}

interface

uses
    Windows, Messages, OpenGL;

//const glu32 = 'glu32.dll';
const opengl32 = 'opengl32.dll';

procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external opengl32;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


const
     VIS_HDRVER =$101;  {WinAMP checks this (for compatibility)}
{ === Structures === }
type
  PWinAMPVisHeader =^TWinAMPVisHeader;
  PWinAMPVisModule =^TWinAMPVisModule;
  TWinAMPVisHeader =record
    Version     :integer; {VIS_HDRVER}
    Description :PChar;   {description of library}
    GetModule   :function(I :integer) :PWinAMPVisModule; cdecl;
                {Gets a module pointer based on i}
  end;
  TWinAMPVisModule =record
    Description  :PChar;   {description of module}
    hWNDParent   :HWND;    {parent window (filled in by WinAMP)}
    hDLLInstance :HINST;   {instance handle to this DLL (filled in by WinAMP)}
    sRate        :integer; {sample rate (filled in by WinAMP)}
    nCh          :integer; {number of channels (filled in by WinAMP)}
    LatencyMs    :integer; {latency from call of RenderFrame to actual drawing}
                           {(WinAMP looks at this value when getting data)}
    DelayMs      :integer; {delay between calls in milliSeconds}
    SpectrumNch  :integer; {number of channels for FFT data}
    WaveformNch  :integer; {number of channels for PCM data}
{The data is filled in according to the respective Nch entry}
    SpectrumData :array[0..1,0..575] of byte;  {0=Left;1=Right}
    WaveformData :array[0..1,0..575] of byte;  {0=Left;1=Right}
    Config       :procedure(This_Mod :PWinAMPVisModule); cdecl;
                 {configuration method}
    Init         :function(This_Mod :PWinAMPVisModule) :integer; cdecl;
                 {Create window, etc.; 0=success}
    Render       :function(This_Mod :PWinAMPVisModule) :integer; cdecl;
                 {1=Plug-in should end; 0=success}
    Quit         :procedure(This_Mod :PWinAMPVisModule); cdecl;
                 {call when done}
    UserData     :pointer; {pointer to user data (optional)}
  end;

const
  // Number Of Particles To Create
  MAX_PARTICLES = 30;

  // Rainbow Of Colors
  colors : array [0..11, 0..2] of GLfloat = (
	(1.0,0.5,0.5),(1.0,0.75,0.5),(1.0,1.0,0.5),(0.75,1.0,0.5),
	(0.5,1.0,0.5),(0.5,1.0,0.75),(0.5,1.0,1.0),(0.5,0.75,1.0),
	(0.5,0.5,1.0),(0.75,0.5,1.0),(1.0,0.5,1.0),(1.0,0.5,0.75));
var
  rainbow : boolean = true;	        // Rainbow Mode?
  rp : boolean;				// R Pressed?
  sp : boolean;                         // Spacebar Pressed?

  slowdown : GLfloat = 2.0;		// Slow Down Particles
  xspeed : GLfloat;                     // Base X Speed (To Allow Keyboard Direction Of Tail)
  yspeed : GLfloat;			// Base Y Speed (To Allow Keyboard Direction Of Tail)
  zoom : GLfloat = -40.0;		// Used To Zoom Out

  col : GLuint;				// Current Color Selection
  delay : GLuint;			// Rainbow Effect Delay


  FontText   : Gluint;
  BrokenTexture : Gluint;
  loop       : integer;



function winampVisGetHeader : PwinampVisHeader; cdecl; export;
const
     szAppName :PChar= 'SimpleVis'; {Our window class}
     config_x  :integer= 50;
     config_y  :integer= 50;

var
  // Dummy window declarations for winamp
  hMainWnd             :HWND;
  memDC                :HDC;
  memBM, oldBM         :HBITMAP;

  // OpenGL Declarations
  h_RC                 : HGLRC;		           // Permanent Rendering Context
  h_DC                 : HDC;                      // Private GDI Device Context
  h_Wnd                : HWND;                     // Holds Our Window Handle
  keys                 : array [0..255] of BOOL;   // Array Used For The Keyboard Routine
  Active               : bool;                     // Window Active Flag
  FullScreen           : bool;                     // Fullscreen Flag
  base                 : GLuint;                   // OpenGL font genList
  Red,Green,Blue       : GLFloat ;                 // Text Color
  SpData,Spdata1       : Array[1..288] of GlFloat; // Spectrum data

  Line1,Line2          : Array[1..288] of GlFloat;
  LineFalloff          : GlFloat;

  Peak1,Peak2          : Array[1..288] of GlFloat;
  PeakFalloff          : GlFloat;

  HelpScreen           : Bool;                     // Help screen Flag
  Flash                : Boolean = false;                     // Flashing background flag
  ilk_bass                                : bool;
  Bassvurdu                               : bool;
  box_z                : GLFloat;
//  texture: array [0..2] of GLuint;    // Storage for 3 textures

function  GetModule(Which :integer) :PWinAMPVisModule; cdecl;
procedure Config(This_Mod : PWinAMPVisModule); cdecl;
function  Init(This_Mod : PWinAMPVisModule) :integer; cdecl;
function  Render2(This_Mod : PWinAMPVisModule) :integer; cdecl;
procedure Quit(This_Mod : PWinAMPVisModule); cdecl;

// Winamp TWinAMPVisHeader
const
     HDR  :TWinAMPVisHeader =
           (Version      :VIS_HDRVER;
            Description  :'BrokeN OpenGL Test Library v1.0.7';
            GetModule    :GetModule);
     Mod2 :TWinAMPVisModule =
           (Description  :'OpenGL Spectrum Analyzer';
            hWNDParent   :0;
            hDLLInstance :0;
            sRate        :0;
            nCh          :0;
            LatencyMs    :0; // Bunu Bilmiom Def: 25 heralde hassaslik felam olsa gerek
            DelayMS      :0; // Bekleeme Def : 25
            SpectrumNch  :2;
            WaveformNch  :0;
            Config       :Config;  // config function
            Init         :Init;    // Plug-in initialization function
            Render       :Render2; // render function
            Quit         :Quit;    // quit function
            UserData     :nil);

implementation
uses setup;




//*************************************************************************
//*******                     OpenGL ROUTINES                       *******
//*************************************************************************


// Build OpenGL Font with system fonts
function StrLen(Str :PChar) :Cardinal; assembler;
asm
  MOV     EDX,EDI
  MOV     EDI,EAX
  MOV     ECX,0FFFFFFFFH
  XOR     AL,AL
  REPNE   SCASB
  MOV     EAX,0FFFFFFFEH
  SUB     EAX,ECX
  MOV     EDI,EDX
end;

procedure BuildBitmapFont;						// Build Our Font Display List
var
  cx : single;							// Holds Our X Character Coord
  cy : single;							// Holds Our Y Character Coord
begin
  base := glGenLists(256);					// Creating 256 Display Lists
  glBindTexture(GL_TEXTURE_2D, fonttext);			// Select Our Font Texture

  for loop := 0 to 255 do 					// Loop Through All 256 Lists
  begin
    cx := (loop mod 16) / 16;					// X Position Of Current Character
    cy := (loop div 16) / 16;					// Y Position Of Current Character

    glNewList(base+loop,GL_COMPILE);				// Start Building A List
    glBegin(GL_QUADS);						// Use A Quad For Each Character
            glTexCoord2f(cx,1-cy-0.0625);			// Texture Coord (Bottom Left)
            glVertex2i(0,0);					// Vertex Coord (Bottom Left)
            glTexCoord2f(cx+0.0625,1-cy-0.0625);	        // Texture Coord (Bottom Right)
            glVertex2i(16,0);					// Vertex Coord (Bottom Right)
            glTexCoord2f(cx+0.0625,1-cy);			// Texture Coord (Top Right)
            glVertex2i(16,16);					// Vertex Coord (Top Right)
            glTexCoord2f(cx,1-cy);				// Texture Coord (Top Left)
            glVertex2i(0,16);					// Vertex Coord (Top Left)
    glEnd();							// Done Building Our Quad (Character)
    glTranslated(10,0,0);					// Move To The Right Of The Character
    glEndList();						// Done Building The Display List
  end;								// Loop Until All 256 Are Built
end;
procedure KillBitmapFont;									// Delete The Font From Memory
begin
  glDeleteLists(base,256);							// Delete All 256 Display Lists
end;
procedure glPrintBitmap(x, y : GLFloat; text : pchar; fontset : GLint);	// Where The Printing Happens
begin
  if (fontset>1) then fontset :=1;

  glBindTexture(GL_TEXTURE_2D, fonttext);			// Select Our Font Texture
  glDisable(GL_DEPTH_TEST);					// Disables Depth Testing
  glMatrixMode(GL_PROJECTION);					// Select The Projection Matrix
  glPushMatrix();						// Store The Projection Matrix
  glLoadIdentity();						// Reset The Projection Matrix
  glOrtho(0,640,0,480,-100,100);				// Set Up An Ortho Screen
  glMatrixMode(GL_MODELVIEW);					// Select The Modelview Matrix
  glPushMatrix();						// Store The Modelview Matrix
  glLoadIdentity();						// Reset The Modelview Matrix
  glTranslated(x,y,0);						// Position The Text (0,0 - Bottom Left)
  glListBase(base-32+(128*fontset));				// Choose The Font Set (0 or 1)
  glCallLists(strlen(text),GL_BYTE,text);			// Write The Text To The Screen
  glMatrixMode(GL_PROJECTION);					// Select The Projection Matrix
  glPopMatrix();						// Restore The Old Projection Matrix
  glMatrixMode(GL_MODELVIEW);					// Select The Modelview Matrix
  glPopMatrix();						// Restore The Old Projection Matrix
  glEnable(GL_DEPTH_TEST);					// Enables Depth Testing
end;



procedure BuildFont;			                // Build Our Bitmap Font
var font: HFONT;                	                // Windows Font ID
begin
  base := glGenLists(96);       	                // Storage For 96 Characters
  font := CreateFont(-15,			       	// Height Of Font
		     0,				       	// Width Of Font
		     0,				       	// Angle Of Escapement
		     0,				       	// Orientation Angle
		     FW_BOLD,	                // Font Weight
		     0,			       	        // Italic
		     0,			       	        // Underline
		     0,			       	        // Strikeout
		     TURKISH_CHARSET,		        // Character Set Identifier
		     OUT_TT_PRECIS,	                // Output Precision
		     CLIP_DEFAULT_PRECIS,	        // Clipping Precision
		     ANTIALIASED_QUALITY,	       	// Output Quality
		     FF_DONTCARE or DEFAULT_PITCH,     	// Family And Pitch
		     'Courier New');		       	// Font Name

  SelectObject(h_DC, font);		       	        // Selects The Font We Want
  wglUseFontBitmaps(h_DC, 32, 96, base);	        // Builds 96 Characters Starting At Character 32

end;
procedure KillFont;     		                // Delete The Font
begin
  glDeleteLists(base, 96); 		                // Delete All 96 Characters
end;

procedure glPrint(text : pchar);	                // Custom GL "Print" Routine
begin
  if (text = '') then   			        // If There's No Text
          Exit;					        // Do Nothing
  glPushAttrib(GL_LIST_BIT);				// Pushes The Display List Bits
  glListBase(base - 32);				// Sets The Base Character to 32
  glCallLists(length(text), GL_UNSIGNED_BYTE, text);	// Draws The Display List Text
  glPopAttrib();										// Pops The Display List Bits
end;


procedure ReSizeGLScene(Width: GLsizei; Height: GLsizei); //Resize And Initialze The GL Window

var
  fWidth, fHeight: GLfloat;

begin
  if (Height=0) then		     // Prevent A Divide By Zero If The Window Is Too Small
     Height:=1;                      // By Making The Height One
  glViewport(0, 0, Width, Height);   // Reset The Current Viewport And Perspective Transformation
  glMatrixMode(GL_PROJECTION);       // Select The Projection Matrix
  glLoadIdentity();                  // Reset The Projection Matrix
  fWidth := width;
  fHeight := height;
  gluPerspective(45.0,fWidth/fHeight,0.1,100.0);// Calculate The Aspect Ratio Of The Window
  glMatrixMode(GL_MODELVIEW);        // Select The Modelview Matrix
  glLoadIdentity                     //Reset The Modelview Matrix
end;

procedure loadTex(name: Integer);
var
  hBm: HBITMAP;
  bm: BITMAP;
begin
  hBm := LoadImage(hInstance, MAKEINTRESOURCE(name), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
  try
    GetObject(hBm, SizeOf(bm), @bm);
    glTexImage2D(GL_TEXTURE_2D, 0, 3, bm.bmWidth, bm.bmHeight, 0, GL_RGB, GL_UNSIGNED_BYTE,bm.bmBits);
  finally
    DeleteObject(hBm);
  end;
end;


function InitGL(This_Mod :PWinAMPVisModule):bool;	// All Setup For OpenGL Goes Here
var loop,x : integer;
begin
  glEnable(GL_TEXTURE_2D);                     // Enable Texture Mapping

  glGenTextures(1, FontText);
  glBindTexture(GL_TEXTURE_2D, Fonttext);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }
  loadTex(1);

  glGenTextures(1, BrokenTexture);
  glBindTexture(GL_TEXTURE_2D, BrokeNTexture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }
  loadTex(2);

  glClearColor(0.0, 0.0, 0.0, 0.5); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do
  glBlendFunc(GL_SRC_ALPHA,GL_ONE);					// Select The Type Of Blending
  glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);	// Really Nice Perspective Calculations
  glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);		// Really Nice Point Smoothing

{  glShadeModel(GL_SMOOTH);			   // Enables Smooth Color Shading
  glClearColor(0.0, 0.0, 0.0, 0.5);		   // Black Background
  glClearDepth(1.0);				   // Depth Buffer Setup
  glDisable(GL_DEPTH_TEST);			       	// Disable Depth Testing
  glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);	// Really Nice Perspective Calculations
  glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);		// Really Nice Point Smoothing
}
  initGL:=true;                                         // Everything went fine


  BuildBitmapFont();                                     // Build OpenGL font
  initGL:=true;                                    // Everything went fine

  BassVurdu := False;
  Ilk_Bass  := False;
  PeakFallOff := 0.04;
  LineFallOff := 0.1;
end;

//** HELP SCREEN
procedure DisplayHelpScreen();
begin
    glEnable(GL_BLEND);
    glColor3f(1,1,1); // White Font Color
    glPrintBitmap(10,450,'UP    : Toggle Volume Up',0);
    glPrintBitmap(10,435,'DOWN  : Toggle Volume Down',0);
    glPrintBitmap(10,420,'LEFT  : Play Previous Song',0);
    glPrintBitmap(10,405,'RIGHT : Play Next Song',0);
    glPrintBitmap(10,390,'F5    : Flashing Background',0);
    glPrintBitmap(10,375,'F3    : Decrease peak falloff speed',0);
    glPrintBitmap(10,360,'F4    : Increase peak falloff speed',0);
    glDisable(GL_BLEND);
{    glRasterPos2f( -1 ,1.30); glPrint('HELP');
    glRasterPos2f( -1 ,1.15); glPrint('-------------------------');
    glRasterPos2f( -1 ,1.00); glPrint('UP    : Toggle Volume Up');
    glRasterPos2f( -1 ,0.85); glPrint('DOWN  : Toggle Volume DOWN');
    glRasterPos2f( -1 ,0.60); glPrint('LEFT  : Play Previous Song');
    glRasterPos2f( -1 ,0.45); glPrint('RIGHT : Play Next Song');
    glRasterPos2f( -1 ,0.30); glPrint('F5    : Flashing Background');}
end;

// All OpenGL rendering code
function DrawGLScene(This_Mod :PWinAMPVisModule):bool;
var
  TotalDataL  : Array[1..288] Of Integer;
  TotalDataR  : Array[1..288] Of Integer;
  a,z         : Integer ;
  x,x1        : GlFloat;
  Ortalama    : GlFloat;
  ToplamBass  : GLFloat;
  SongName    : PChar;
  PlaylistPos : LongInt;
  IsPlaying   : LongInt;

  Original_X_Position,Original_Y_Position : GLFloat;
  Current_X,Current_Y                     : GLFloat;

  loop : integer;
begin

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // Clear The Screen And The Depth Buffer
  glLoadIdentity();		      // Reset The View
  glTranslatef(-1.5,0.0,-6.0);

  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);

  // Translate spectrumData array values to OpenGL metrics
  for a:=1 to 288 do begin
          TotalDataL[a]:=ord(this_mod^.spectrumData[0][a]); // Left
          TotalDataR[a]:=ord(this_mod^.spectrumData[1][a]); // Right
  end;
  For a:=1 To 288 do Begin
      SpData[a]:=TotalDataL[a]  / 30; // Left
      SpData1[a]:=TotalDataR[a] / 30; // Right
      if SpData[a] > 2 then SpData[a]:=2;
      if SpData1[a] > 2 then SpData1[a]:=2;
  End;
  For a:=1 To 288 do Begin
      if Peak1[a] < SpData[a] then Peak1[a]:=SpData[a] else Peak1[a]:=Peak1[a]-PeakFallOff;
      if Peak2[a] < SpData1[a] then Peak2[a]:=SpData1[a] else Peak2[a]:=Peak2[a]-PeakFallOff;
      if Line1[a] < SpData[a] then Line1[a]:=SpData[a] else Line1[a]:=Line1[a]-LineFallOff;
      if Line2[a] < SpData1[a] then Line2[a]:=SpData1[a] else Line2[a]:=Line2[a]-LineFallOff;
  End;




  // BackGround Beat Color
  // Calculates the first 20 values of SpectrumData array
  // and finds average of it. "Ortalama" is average.
     ToplamBass:=0;
     for a:=1 to 20 do begin
         ToplamBass:=ToplamBass + SpData[a];
     end;
     Ortalama := (ToplamBass / 20) / 3;
     if flash then glClearColor(Ortalama, Ortalama, 0, 0.5) else
                   glClearColor(0, 0, 0, 0.5);

    // Draw Left and Right Analyzers , blue and red
    x:=-1.2;
    x1:=1.5;

    for a:=20 to 268 do begin
      // Left analyzer

      glBegin(GL_LINES);
         x:= x + 0.01;
         glColor3f(0.0,0.0,1.0);
         glVertex2f(x, 0.0);glColor3f(0,0,0);
         if line1[a] < 0 then glVertex2f(x,0.01) else glVertex2f(x,Line1[a]);

         glColor3f(0.0,0.0,0.5);
         glVertex2f(x, 0.0);glColor3f(0,0,0.0);
         if line1[a] < 0 then glVertex2f(x,0.01) else glVertex2f(x,-Line1[a]);
      glEnd();

      // Left Peaks
      glBegin(GL_LINES);
         glColor3f(0.0,0.0,1.0);
         if peak1[a] > 0.031 then glVertex2f(x, Peak1[a]-0.03);
         glColor3f(0,0,1);
         glVertex2f(x, Peak1[a]);

//         glColor3f(0.0,0.0,1.0);
//         glVertex2f(x, -Peak1[a]);
//         glColor3f(0.0,0.0,1.0);
//         glVertex2f(x, -(Peak1[a]+0.03));
      glEnd();


      // Right analyzer
      glBegin(GL_LINES);
         x1:= x1 + 0.01;
         glColor3f(1,0.0,0.0);
         glVertex2f(x1, 0.0);glColor3f(0,0,0.0);
         if line2[a] < 0 then glVertex2f(x1,0.01) else glVertex2f(x1,Line2[a]);

         glColor3f(0.5,0.0,0.0);
         glVertex2f(x1, 0.0);glColor3f(0,0,0.0);
         if line2[a] < 0 then glVertex2f(x1,0.01) else glVertex2f(x1,-Line2[a]);
      glEnd();
      // Right Peaks
      glBegin(GL_LINES);
         glColor3f(1,0,0);
         if peak2[a] > 0.031 then glVertex2f(x1, Peak2[a]-0.03);
//         glVertex2f(x1, Peak2[a]-0.03);
         glColor3f(1,0,0);
         glVertex2f(x1, Peak2[a]);
      glEnd();

    end;


    // Display Song Name
    PlaylistPos:= SendMessage(This_Mod^.hWNDParent, WM_USER, 0, 125); // Returns Winamp Playlist position
    SongName := Pointer(SendMessage(This_Mod^.hWNDParent, WM_USER, PlaylistPos, 212)); // Returns Winamp song name by playlistpos

    // Flashing Background
    // If flashing then backgound else song name will flashing
    if flash then glColor3f(1,1,1) else
                  glColor3f(ortalama,ortalama,0);



     //  glRasterPos2f(  1 - ((Length(SongName) div 2) / 15) ,-2.3);

    // Display Song Name
//    glPrint(SongName);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glPrintBitmap(10,10,SongName,1);
    glDisable(GL_BLEND);


    if HelpScreen then DisplayHelpScreen();

    if ortalama > 0.44 then begin
       bassvurdu:=true;
    end;

    if (BassVurdu) and (not ilk_bass) then begin
       Original_X_Position := 1 - ((Length(SongName) div 2) div 15);
       Original_Y_Position := -2.3;
       Current_X := Original_X_Position;
       ilk_bass:=true;
    end;

    if (1 - ((Length(SongName) div 2) / 15)) > Original_X_Position then begin
       BassVurdu:=False;
       ilk_bass:=false;
    end;



  DrawGLScene:=true;
end;


// MAIN WINDOW PROCEDURE
function WndProc(hWnd: HWND;         //Handle For The Window
                 message: UINT;      //Message For This Window
                 wParam: WPARAM;     //Additional Message Information
                 lParam: LPARAM):    //Additional Message Information
                                  LRESULT; stdcall;

begin
  // The WM_SYSCOMMAND Message Is Not In The Case-Loop, Because If It Is, Other Messages
  // Won't Be Handled Anymore(If You Know The Reason, Please Let Me Know...)
  if message=WM_SYSCOMMAND then    //Intercept System Commands
    begin
      case wParam of                         //Check System Calls
        SC_SCREENSAVE,SC_MONITORPOWER:       //Screensaver Trying To Start, Monitor Trying To Enter Powersave?
          begin
            result:=0;                       //Prevent This From Happening
            exit;                            //Exit
          end;
      end;
    end;
  case message of // Tells Windows We Want To Check The Message
    WM_ACTIVATE:
      begin
        if (Hiword(wParam)=0) then  //Check Minimization State
          active:=true              //Program Is Active
        else
          active:=false;            //Program Is No Longer Active
        Result:=0;                  //Return To The Message Loop
      end;
    WM_CLOSE:                       //Did We Get A Close Message
      Begin
        PostQuitMessage(0);         //Send A Quit Message
        result:=0                   //Return To The Message Loop
      end;
    WM_KEYDOWN:                     //Is A Key Being Held Down?
      begin
        keys[wParam] := TRUE;       //If So, Mark It As True
        result:=0;                  //Return To The Message Loop
      end;
    WM_KEYUP:                       //Is A Key Being Released?
      begin
    	keys[wParam] := FALSE;      //If So, Mark It As False
        result:=0;                  //Return To The Message Loop
      end;
    WM_SIZe:                        //Resize The GL Window
      begin
    	ReSizeGLScene(LOWORD(lParam),HIWORD(lParam)); //Loword=Width, Highword=Height
        result:=0;                  //Return To The Message Loop
      end
    else
      //Pass All Unhandled Messages To DefWinProc
      begin
      	Result := DefWindowProc(hWnd, message, wParam, lParam);
      end;
    end;
end;

procedure KillGLWindow(This_Mod :PWinAMPVisModule); //Properly Kill The Window

begin
  if FullScreen then   //Are We In Fullscreen Mode?
    begin
      ChangeDisplaySettings(devmode(nil^),0); //Switch Back To The Desktop
      //showcursor(true);  //Show The Mouse Pointer
    end;

    // This code kills opengL window
    // but something goes wrong and I can't solve the problem
    // if somebody can run it without an error please
    // inform me. barisakin@iname.com

//  if h_rc<>0 then       //Is There A Rendering Context?
//    begin
//      if (not wglMakeCurrent(h_Dc,0)) then   //Are We Able To Release Dc and Rc contexts?
//        MessageBox(0,'Release of DC and RC failed.',' Shutdown Error',MB_OK or MB_ICONERROR);
 //     if (not wglDeleteContext(h_Rc)) then   //Are We Able To Delete The Rc?
 //       begin
 //         MessageBox(0,'Birinci Omadý.',' Shutdown Error',MB_OK or MB_ICONERROR);
 //         h_Rc:=0;                           //Set Rc To Null
 //       end;
 //   end;
 // if (h_Dc=1) and (releaseDC(h_Wnd,h_Dc)<>0) then   //Are We Able To Release The Dc?
 //   begin
 //     MessageBox(0,'Ikinci Olmadi',' Shutdown Error',MB_OK or MB_ICONERROR);
//      h_Dc:=0;                           //Set Dc To Null
//    end;
//  if (h_Wnd<>0) and (not destroywindow(h_Wnd))then   //Are We Able To Destroy The Window?
//    begin
//      MessageBox(0,'Destroy Olmadi.',' Shutdown Error',MB_OK or MB_ICONERROR);
//      h_Wnd:=0;                          //Set hWnd To Null
//    end;

  SelectObject(memDC,oldBM);
  DeleteObject(memDC);
  DeleteObject(memBM);
  DestroyWindow(hMainWnd);    {delete our window}
  Windows.UnregisterClass(szAppName,This_Mod^.hDLLInstance);

end;


function CreateGlWindow(title:Pchar; width,height,bits:integer;FullScreenflag:bool;This_Mod :PWinAMPVisModule):boolean stdcall;
var
  Pixelformat: GLuint;           //Holds The Result After Searching For A Match
  wc:TWndclass;                  //Windows Class Structure
  dwExStyle:dword;               //Extended Window Style
  dwStyle:dword;                 //Window Style
  pfd: pixelformatdescriptor;    //Tells Windows How We Want Things To Be
  dmScreenSettings: Devmode;     //Device Mode
//  h_Instance:hinst;              // Holds The Instance Of The Application
begin
//  h_instance:=getmodulehandle(nil); //Grab An Instance For Our Window
  FullScreen:=FullScreenflag;       //Set The Global Fullscreen Flag

//  FullScreen:=true;
  with wc do
    begin
      style:=CS_HREDRAW or CS_VREDRAW or CS_OWNDC;   //Redraw On Size -- Own DC For Window
      lpfnWndProc:=@WndProc;                         //WndProc Handles The Messages
      cbClsExtra:=0;                                 //No Extra Window Data
      cbWndExtra:=0;                                 //No Extra Window Data
      hInstance:=This_Mod^.hDllInstance;                         //Set The Instance
      hIcon:=0;                //Load The Default Icon
      hCursor:=0;              //Load The Arrow Pointer
      hbrBackground:=0;                              //No BackGround Required For OpenGL
      lpszMenuName:=nil;                             //We Don't Want A Menu
      lpszClassName:='OpenGl';                       //Set The CLass Name
    end;
  if  RegisterClass(wc)=0 then                       //Attempt To Register The Window Class
    begin
      MessageBox(0,'Failed To Register The Window Class.','Error',MB_OK or MB_ICONERROR);
      CreateGLwindow:=false;                         //Return False
      exit;                                          //Exit
    end;
  if FullScreen then                                 //Attempt Fullscreen Mode
    begin
      ZeroMemory( @dmScreenSettings, sizeof(dmScreenSettings) );  //Makes Sure Memory's Available
      with dmScreensettings do
        begin
          dmSize := sizeof(dmScreenSettings);         //Size Of The Devmode Structure
          dmPelsWidth  := width;	              //Selected Screen Width
	  dmPelsHeight := height;                     //Selected Screen Height
          dmBitsPerPel := bits;                       //Selected Bits Per Pixel
          dmFields     := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;
        end;
      //Try To Set The Selected Mode And Get Results. CDS_FullScreen Gets Rid Of The Start Bar
      if (ChangeDisplaySettings(dmScreenSettings, CDS_FullScreen))<>DISP_CHANGE_SUCCESSFUL THEN
        Begin
          if MessageBox(0,'This FullScreen Mode Is Not Supported. Use Windowed Mode Instead?'
                                             ,'BrokeNGL',MB_YESNO or MB_ICONEXCLAMATION)= IDYES then
                FullScreen:=false   //Select The Windowed Mode
          else
            begin
              //Popup A Message Box Letting The User Know The Program Is Closing
              MessageBox(0,'Program Will Now Close.','Error',MB_OK or MB_ICONERROR);
 //             CreateGLWindow:=false;    //Return False
            end;
          end;
    end;
  if FullScreen then  //Check If We're Still In Fullscreen Mode
    begin
      dwExStyle:=WS_EX_APPWINDOW;  //Extended Window Style
      dwStyle:=WS_popup or WS_CLIPSIBLINGS or WS_CLIPCHILDREN; //Window Style
      Showcursor(false);           //Hide Mouse Pointer
    end
  else
    begin
      dwExStyle:=WS_EX_APPWINDOW or WS_EX_TOOLWINDOW;   //Extended Window Style
      dwStyle:=WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN; //Windows Style
    end;
  //Create The Window
  H_wnd:=CreateWindowEx(dwExStyle,                   //Extende Style For The Window
                               'OpenGl',             //Class Name
                               Title,                //Window Title
                               dwStyle,              //Window Style
                               0,0,                  //Window Position
                               width,height,         //Selected Width and Height
                               This_Mod^.hWNDParent, // Parent Window
                               0,                    //No Menu
                               This_Mod^.hDllInstance,            //Instance
                               nil);                 //Don't Pass Anything To WM_CREATE
  if h_Wnd=0 then              //If The Window Creation Failed
    begin
      KillGlWindow(This_Mod);          //Reset The Display
      MessageBox(0,'Window creation error.','Error',MB_OK or MB_ICONEXCLAMATION);
      CreateGLWindow:=false;   //Return False
      exit;
    end;
  with pfd do    //Tells Windows How We Want Things To Be
    begin
      nSize:= SizeOf( PIXELFORMATDESCRIPTOR ); // Size Of This Pixel Format Descriptor
      nVersion:= 1;                            // Version Number (?)
      dwFlags:= PFD_DRAW_TO_WINDOW             // Format Must Support Window
        or PFD_SUPPORT_OPENGL                  // Format Must Support OpenGL
        or PFD_DOUBLEBUFFER;                   // Must Support Double Buffering
      iPixelType:= PFD_TYPE_RGBA;              // Request An RGBA Format
      cColorBits:= bits;                       // Select Our Color Depth
      cRedBits:= 0;                            // Color Bits Ignored
      cRedShift:= 0;
      cGreenBits:= 0;
      cBlueBits:= 0;
      cBlueShift:= 0;
      cAlphaBits:= 0;                          // No Alpha Buffer
      cAlphaShift:= 0;                         // Shift Bit Ignored
      cAccumBits:= 0;                          // No Accumulation Buffer
      cAccumRedBits:= 0;                       // Accumulation Bits Ignored
      cAccumGreenBits:= 0;
      cAccumBlueBits:= 0;
      cAccumAlphaBits:= 0;
      cDepthBits:= 16;                         // 16Bit Z-Buffer (Depth Buffer)
      cStencilBits:= 0;                        // No Stencil Buffer
      cAuxBuffers:= 0;                         // No Auxiliary Buffer
      iLayerType:= PFD_MAIN_PLANE;             // Main Drawing Layer
      bReserved:= 0;                           // Reserved
      dwLayerMask:= 0;                         // Layer Masks Ignored
      dwVisibleMask:= 0;
      dwDamageMask:= 0;
    end;
  h_Dc := GetDC(h_Wnd);                        // Try Getting A Device Context
  if h_Dc=0 then                               // Did We Get Device Context For The Window?
    begin
      KillGLWindow(This_Mod);                          //Reset The Display
      MessageBox(0,'Cant''t create a GL device context.','Error',MB_OK or MB_ICONEXCLAMATION);
      CreateGLWindow:=false;                   //Return False
      exit;
    end;
  PixelFormat := ChoosePixelFormat(h_Dc, @pfd);// Finds The Closest Match To The Pixel Format We Set Above
  if (PixelFormat=0) then                      //Did We Find A Matching Pixelformat?
    begin
      KillGLWindow(This_Mod);                          //Reset The Display
      MessageBox(0,'Cant''t Find A Suitable PixelFormat.','Error',MB_OK or MB_ICONEXCLAMATION);
      CreateGLWindow:=false;                   //Return False
      exit;
    end;
  if (not SetPixelFormat(h_Dc,PixelFormat,@pfd)) then  //Are We Able To Set The Pixelformat?
    begin
      KillGLWindow(This_Mod);                          //Reset The Display
      MessageBox(0,'Cant''t set PixelFormat.','Error',MB_OK or MB_ICONEXCLAMATION);
      CreateGLWindow:=false;                   //Return False
      exit;
    end;
  h_Rc := wglCreateContext(h_Dc);              //Are We Able To Get A Rendering Context?
  if (h_Rc=0) then
    begin
      KillGLWindow(This_Mod);                          //Reset The Display
      MessageBox(0,'Cant''t create a GL rendering context.','Error',MB_OK or MB_ICONEXCLAMATION);
      CreateGLWindow:=false;                   //Return False
      exit;
    end;
  if (not wglMakeCurrent(h_Dc, h_Rc)) then     //Are We Able To Activate The Rendering Context?
    begin
      KillGLWindow(This_Mod);                          //Reset The Display
      MessageBox(0,'Cant''t activate the GL rendering context.','Error',MB_OK or MB_ICONEXCLAMATION);
      CreateGLWindow:=false;                   //Return False
      exit;
    end;
  ShowWindow(h_Wnd,SW_SHOW);       //Show The Window
  SetForegroundWindow(h_Wnd);      //Slightly Higher Priority
  SetFOcus(h_Wnd);                 //Set Keyboard Focus To The Window
  ReSizeGLScene(width,height);     //Set Up Our Perspective Gl Screen
  if (not InitGl(This_Mod)) then   //Can we Initialize The Newley Created GL Window
    begin
      KillGLWindow(This_Mod);      //Reset The Display
      MessageBox(0,'initialization failed.','Error',MB_OK or MB_ICONEXCLAMATION);
      CreateGLWindow:=false;       //Return False
      exit;
    end;
  CreateGLWindow:=true;            //Succes
end;




//*************************************************************************
//*******                     WINAMP ROUTINES                       *******
//*************************************************************************
function  OurMessageBox(Owner :HWND; Msg, Title :string; Style :integer) :integer;
          begin
          Msg := Msg + #0;
          Title := Title + #0;
          Result := MessageBox(Owner,@Msg[1],@Title[1],Style);
          end;

{ === Visualization plug-in methods === }

function  WinAMPVisGetHeader :PWinAMPVisHeader;
begin
  Result := @HDR;  {Return the main header}
end;

function  GetModule(Which :integer) :PwinampVisModule;
begin
  case which of
    0 : Result := @Mod2;
   else Result := nil;
  end;
end;

procedure Config(This_Mod :PWinAMPVisModule);
  var
    eheh : HINST;
begin
     SetupWin(This_Mod.hDLLInstance, eheh)
end; { Config }

function  Init(This_mod :PWinAMPVisModule) :integer;
          var
             width, height :integer;
             wc            :TWndClass;
             r             :TRect;
             wcHandle      :integer;
             _hdc          :HDC;
             _string  :array[0..31] of char;
             INIFile  :array[0..MAX_PATH-1] of char;
             PixelDepth    :integer;
             fullscr     : integer;
begin

// Here is creating a dummy window.
// It is invisible

  width := 288;
  height := 256;
  with wc do
  begin
    wc.style := 0;   {no special style for this class}
    wc.lpfnWndProc := @DefWindowProc;  {Our window procedure}
    wc.cbClsExtra := 0;  {Cleared extra parameters}
    wc.cbWndExtra := 0;  {Extra window data in bytes}
    wc.hInstance := This_Mod^.hDllInstance;  {hInstance of DLL}
    wc.hIcon := 0;  {The special Icon of the window; 0=none}
    wc.hCursor := 0;  {The special Cursor of the window; 0=none}
    wc.hbrBackground := 0; {The background style}
    wc.lpszMenuName := #0; {The menu name (none=#0)}
    wc.lpszClassName := szAppName; {Our window class name}
  end;
  wcHandle := Windows.RegisterClass(wc);
  if wcHandle = 0 then
  begin
    OurMessageBox(This_Mod^.hWNDParent,
                  'Error registering window class',
                  This_Mod^.Description,
                  MB_OK);
    Result:=1;
    exit;
  end;
  hMainWnd := CreateWindowEx(
              WS_EX_TOOLWINDOW or WS_EX_APPWINDOW,
              szAppName,
              This_Mod^.Description,
              WS_VISIBLE,
              config_x, config_y,
              width, height,
              This_Mod^.hWNDParent,
              0,
              This_Mod^.hDLLInstance,
              nil);

  if (hMainWnd = 0) then
  begin
    OurMessageBox(This_Mod^.hWNDParent,
                  'Error creating window',
                  this_mod^.description,
                  MB_OK);
    Result:=1;
    exit;
  end;

  {set our window "user data" to the "This_Mod" pointer}
  SetWindowLong(hMainWnd,GWL_USERDATA,longint(This_Mod));
  GetClientRect(hMainWnd,r);
  SetWindowPos(hMainWnd,0,0,0,width*2-r.right,
               height*2-r.bottom,SWP_NOMOVE or SWP_NOZORDER);
  memDC := CreateCompatibleDC(0);
  memBM := CreateCompatibleBitmap(memDC,width,height);
  oldBM := SelectObject(memDC,memBM);
  ShowWindow(hMainWnd,SW_HIDE);
  _hdc := GetDC(hMainWnd);
  BitBlt(_hdc,0,0,width,height,memDC,0,0,SRCCOPY);
  ReleaseDC(hMainWnd,_hdc);

  // Create OpenGL window and start rendering.
  ConfigGetINI_FN(This_Mod^.hDLLInstance,INIFile);
  width := GetPrivateProfileInt('BrokenGL', 'width', 640, INIFile);
  height := GetPrivateProfileInt('BrokenGL', 'height', 480, INIFile);
  pixeldepth := GetPrivateProfileInt('BrokenGL', 'PixelDepth', 16, INIFile);

  if GetPrivateProfileInt('BrokenGL', 'Fullscreen', 1, INIFile)= 0 then
     Fullscreen:=false else Fullscreen:=true;

   if not CreateGLWindow('BrokenGL Spektrum Alayz - build 1.0.7',width,height,pixeldepth,FullScreen,This_Mod) then //Could We Create The OpenGl Window?
    begin
      KillGLWindow(This_Mod);
      Result := 1;    //Quit If The Window Wasn't Created
      exit;
    end;

  active:=true;                             //The Active Variable Is Set To True By Default
  Result := 0;
end; { Init }


function  Render2(This_Mod : PWinAMPVisModule) :integer;
begin

          // Jump To Prev Song
          if keys[VK_LEFT] then
             SendMessage(This_Mod^.hWNDParent, WM_COMMAND, 40044, 0);
          // Jump To Next Song
          if keys[VK_RIGHT] then
             SendMessage(This_Mod^.hWNDParent, WM_COMMAND, 40048, 0);

          // Toggle Volume Up
          if keys[VK_UP] then
             SendMessage(This_Mod^.hWNDParent, WM_COMMAND, 40058, 0);
          // Toggle Volume Down
          if keys[VK_DOWN] then
             SendMessage(This_Mod^.hWNDParent, WM_COMMAND, 40059, 0);

          // Help Screen
          if keys[VK_F1] then
             if HelpScreen then HelpScreen:=False else HelpScreen:=True;

          if keys[VK_F3] then PeakFallOff:=PeakFallOff -0.003;
          if keys[VK_F4] then PeakFallOff:=PeakFallOff +0.004;

        if keys[VK_F5] then
             if Flash then Flash:=False else Flash:=True;

          if (active and not(DrawGLScene(This_Mod)) or keys[VK_ESCAPE]) then begin
             killGLwindow(This_Mod);
             result:=1;
          end
          else begin
            SwapBuffers(h_Dc);
            Result := 0;
          end;

end; { Render2 }


procedure Quit(This_Mod :PWinAMPVisModule);
begin
  KillGLWindow(This_Mod);
end; { Quit }

end.

