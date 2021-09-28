unit Globals;

interface

Uses Windows, OpenGL, Textures;


const INTRO_START  = 0;
      INTRO_TUNNEL = 33150;
      FETUS_START  = 36650;
      FETUS_ROOM_START = 51000;
      TUNNEL_START = 65200;
      BLOB_START   = 79700;
      METABALL_START = 93700;
      TENTACLE_START = 122000;
      DEMO_END = 171000;


//--- Textures ---//
var ProgressTex   : glUint;               // Loading Stage
    DemoNameTex   : glUint;               // Intro
    PowerLines    : glUint;               // Intro
    IntroZoom     : glUint;               // Intro

    MetalFrame    : glUint;               // fetus
    BioHazard     : glUint;               // fetus
    ChildTexture  : glUint;               // fetus
    Static        : glUint;               // fetus
    FetusBG       : glUint;               // fetus

    Floor         : glUint;               // fetus room
    Walls         : glUint;               // fetus room
    WallTrim      : glUint;               // fetus room
    Ceiling       : glUint;               // fetus room
    EnergyPod     : glUint;               // fetus room
    EnergyGlow    : glUint;               // fetus room

    TunnelTex     : glUint;               // Tunnel Textures
    FireTex       : glUint;               // Tunnel Textures
    BlobTex       : glUint;               // Blob

    WhiteTex      : glUint;               // fade between scenes

    EnviroTex     : glUint;               // Metaballs Enviromap
    MBallsBgTex   : Array[0..3] of glUint;// Metaballs Background

    TentacleTex   : glUint;               // tentacles
    TitlesTex     : glUint;               // titles
    BioHazard2    : glUint;               // biohazard texture
    optimizeTex   : glUint;


//--- Other Global variables ---//
var ElapsedTime : Integer;                // Elapsed time between frames
    Stage : Integer;                      // Stage the demo is at.

type TNormal = record
       X, Y, Z : glFloat;             // X, Y, Z coordinates
     end;
     TVertex = record
       X, Y, Z : glFloat;             // X, Y, Z coordinates
     end;
     TTexCoord = record
       U, V : glFloat;                // U and V Texture coordinates
     end;

  procedure ShowLoading;
  procedure Init;                           // Procedure that load texures and objects
  function  ArcTan(X, Y : glFloat) : glFloat;
  procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

implementation



{------------------------------------------------------------------}
{  LOADING STAGE : Load all textures and objects.                  }
{------------------------------------------------------------------}
procedure LoadDemoTextures;
begin
  LoadTexture('Powerlines.jpg', PowerLines, TRUE);             // Intro
  LoadTexture('Demoname.jpg',  DemoNameTex, TRUE);
  LoadTexture('IntroZoom.jpg',  introzoom, TRUE);

  LoadTexture('metalGlassFrame.jpg',   MetalFrame, TRUE);      // Child
  LoadTexture('BioHazard.jpg', Biohazard, TRUE);
  LoadTexture('Child.jpg',     ChildTexture, TRUE);
  LoadTexture('FetusBackground.jpg', FetusBG, TRUE);
  LoadTexture('Static.jpg', Static, TRUE);
  LoadTexture('Floor.jpg',  Floor, TRUE);
  LoadTexture('Walls.jpg',  Walls, TRUE);
  LoadTexture('WallTrim.jpg',   WallTrim, TRUE);
  LoadTexture('Ceiling.jpg',    Ceiling, TRUE);
  LoadTexture('EnergyPod.jpg',  EnergyPod, TRUE);
  LoadTexture('EnergyGlow.jpg', EnergyGlow, TRUE);

  LoadTexture('bluetunnel.jpg',  TunnelTex, TRUE);          // Blob Textures
  LoadTexture('fire.jpg',   FireTex, TRUE);
  LoadTexture('blob.jpg',   BlobTex, TRUE);
  LoadTexture('white.bmp',  WhiteTex, TRUE);

  LoadTexture('Metaballs_bg1.jpg', MBallsBgTex[0], TRUE);   // Metaballs
  LoadTexture('Metaballs_bg2.jpg', MBallsBgTex[1], TRUE);
  LoadTexture('Metaballs_bg3.jpg', MBallsBgTex[2], TRUE);
  LoadTexture('Metaballs_bg4.jpg', MBallsBgTex[3], TRUE);
  LoadTexture('chrome.bmp',    EnviroTex, TRUE);

  LoadTexture('tentacles.bmp', TentacleTex, TRUE);          // Tentacles
  LoadTexture('Biohazard2.jpg', Biohazard2, TRUE);
  LoadTexture('Optimize2001.jpg', OptimizeTex, TRUE);
  LoadTexture('titles.jpg', TitlesTex, TRUE);
end;


{------------------------------------------------------------------}
{  Function to do an arctan                                        }
{------------------------------------------------------------------}
function ArcTan(X, Y : glFloat) : glFloat;
asm
  FLD     Y
  FLD     X
  FPATAN
  FWAIT
end;


{----------------------------------------------------------}
{  Initialise Demo. Loads textures and creates objects     }
{----------------------------------------------------------}
procedure ShowLoading;
begin
  glTranslatef(0.0,0.0,-4);

  // Background image
  LoadTexture('LoadingTextures.jpg', ProgressTex, TRUE);
  glBindTexture(GL_TEXTURE_2D, ProgressTex);
  glBegin(GL_QUADS);
    glTexCoord2f(0, 0); glVertex3f(-1,-1, 0);
    glTexCoord2f(1, 0); glVertex3f( 1,-1, 0);
    glTexCoord2f(1, 1); glVertex3f( 1, 1, 0);
    glTexCoord2f(0, 1); glVertex3f(-1, 1, 0);
  glEnd();

  ElapsedTime :=0;
  Inc(Stage);
end;


{----------------------------------------------------------}
{  Initialise Demo. Loads textures and creates objects     }
{----------------------------------------------------------}
procedure Init;
begin
  glTranslatef(0.0,0.0,-10);

  // Background image
  glBindTexture(GL_TEXTURE_2D, ProgressTex);
  glBegin(GL_QUADS);
    glTexCoord2f(0, 0); glVertex3f(-1,-1, 0);
    glTexCoord2f(1, 0); glVertex3f( 1,-1, 0);
    glTexCoord2f(1, 1); glVertex3f( 1, 1, 0);
    glTexCoord2f(0, 1); glVertex3f(-1, 1, 0);
  glEnd();

  LoadDemoTextures;

  ElapsedTime :=0;
  Inc(Stage);
end;

end.

