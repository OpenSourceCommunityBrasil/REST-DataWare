unit uOpenGLDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UObjects3D, OpenGL, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  uDWAbout, uRESTDWPoolerDB, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDWConstsData, Textures;

Const
 vCentroTela   = 42.5;
 CorrectionPos : Real = 0.2;

Type
 TRectSpecial = Array of Record
  Top, Left,
  Width, Height : Integer;
  Texto     : String;
End;

type
  TForm7 = class(TForm)
    tVideoFrame: TTimer;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    procedure tVideoFrameTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
   LinhasPrint        : TStringList;
   vBackGroundDatas3D,
   vListaEmpregados3D : TCube3D; //Formas Basicas
   h_DC               : HDC;   // Global device context
   h_RC               : HGLRC; // OpenGL rendering context
   Angle              : Real;
   texFont            : glUint;
   MyQuadratic        : GLUquadricObj;
   InitializedApp     : Boolean;
   procedure glDraw;
   procedure SetupGL;
   procedure StartGl;
   procedure glInit;
   procedure glResizeWnd(Width, Height : Integer);
   procedure ImprimiLinhasDatas3D;
   Procedure LimpaLinhasData3D;
   Procedure LoadLinhasData3D(DataList : TStringList);
   Procedure IncLinData3D(DataList : TStringList);
   Procedure DecLinData3D(DataList : TStringList);
  public
    { Public declarations }
   Procedure BuildInterface;
  end;

var
  Form7: TForm7;
  vDepthBits     : Integer = 16;
  VMaxLinhasData : Integer = 9;
  AtualLine      : Integer = 0;
  LinhaDataText  : TRectSpecial;
  DataList       : TStringList = Nil;

implementation

{$R *.dfm}

Procedure TForm7.LimpaLinhasData3D;
Var
 I, VMaxLinhas : Integer;
 VTagPri : Boolean;
Begin
 VTagPri  := False;
 AtualLine := 0;
 If (VMaxLinhasData mod 2) = 0 Then
  VMaxLinhasData := VMaxLinhasData -1;
 VMaxLinhas := VMaxLinhasData;
 If (Length(LinhaDataText) = 0) And (VMaxLinhas > -1) Then
  Begin
   SetLength(LinhaDataText, VMaxLinhas);
   VTagPri := True;
  End;
 VMaxLinhas := (VMaxLinhas div 2);
 If VMaxLinhas > 0 Then
 For I := 0 To VMaxLinhasData -1 Do
  Begin
   If VTagPri Then
    Begin
     LinhaDataText[I].Left := 0;
     LinhaDataText[I].Top  := 0;
    End;
   If (VMaxLinhas = I) Then
    LinhaDataText[I].Texto  := '....Sem Dados....'
   Else
    LinhaDataText[I].Texto  := '';
  End;
End;

Procedure TForm7.LoadLinhasData3D(DataList : TStringList);
Var
 I, A, VMaxLinhas : Integer;
Begin
 If DataList.Count = 0 Then Exit;
 If (VMaxLinhasData mod 2) = 0 Then
  VMaxLinhasData := VMaxLinhasData -1;
 VMaxLinhas := VMaxLinhasData;
 VMaxLinhas := (VMaxLinhas div 2);
 If VMaxLinhas > 0 Then
 For I := VMaxLinhasData-1 DownTo 0 Do
  Begin
   If I <= VMaxLinhas Then
    Begin
     If DataList.Count > I Then
      Begin
       If VMaxLinhas >= I Then
        LinhaDataText[VMaxLinhas - I].Texto := DataList[I]
       Else
        LinhaDataText[VMaxLinhas - I].Texto  := '';
      End
     Else
      LinhaDataText[VMaxLinhas - I].Texto  := '';
    End
   Else
    LinhaDataText[I].Texto  := '';
  End;
End;

Procedure TForm7.IncLinData3D(DataList : TStringList);
 Function RetornaAnteriores(Atual, MaxReverso : Integer) : Integer;
 Begin
  Result := 0;
  If Atual > 0 Then
   If Atual >= MaxReverso Then
    Result := Atual - MaxReverso;
 End;
Var
 C, I, A, VMaxLinhas : Integer;
Begin
 If DataList.Count -1 <= AtualLine Then Exit;
 If (VMaxLinhasData mod 2) = 0 Then
  VMaxLinhasData := VMaxLinhasData -1;
 VMaxLinhas := VMaxLinhasData;
 If AtualLine < DataList.Count Then
  Inc(AtualLine);
 VMaxLinhas := (VMaxLinhas div 2);
 If VMaxLinhas > 0 Then
 For I := VMaxLinhasData-1 DownTo 0 Do
  Begin
   A := I + 1;
   If A >= VMaxLinhasData Then
    A := VMaxLinhasData -1;
   LinhaDataText[A].Texto  := LinhaDataText[I].Texto;
   If (I = 0) Then
    Begin
     If AtualLine < DataList.Count Then
      Begin
       If AtualLine + VMaxLinhas >= DataList.Count Then
        LinhaDataText[I].Texto  := ''
       Else
        LinhaDataText[I].Texto := DataList[AtualLine + VMaxLinhas];
      End;
    End
   Else
    LinhaDataText[I].Texto  := LinhaDataText[I -1].Texto;
  End;
End;

Procedure TForm7.DecLinData3D(DataList : TStringList);
 Function RetornaAnteriores(Atual, MaxReverso : Integer) : Integer;
 Begin
  Result := 0;
  If Atual > 0 Then
   If Atual >= MaxReverso Then
    Result := Atual - MaxReverso;
 End;
Var
 C, I, A, VMaxLinhas : Integer;
Begin
 If 0 = AtualLine Then Exit;
 If (VMaxLinhasData mod 2) = 0 Then
  VMaxLinhasData := VMaxLinhasData -1;
 VMaxLinhas := VMaxLinhasData;
 If AtualLine > 0 Then
  Dec(AtualLine);
 VMaxLinhas := (VMaxLinhas div 2);
 If VMaxLinhas > 0 Then
 For I := 0 To VMaxLinhasData-1 Do
  Begin
   A := I - 1;
   If A < 0 Then
    A := 0;
   LinhaDataText[A].Texto  := LinhaDataText[I].Texto;
   If (I = VMaxLinhasData-1) Then
    Begin
     If AtualLine > 0 Then
      Begin
       If AtualLine - VMaxLinhas < 0 Then
        LinhaDataText[I].Texto  := ''
       Else
        LinhaDataText[I].Texto := DataList[AtualLine - VMaxLinhas];
      End;
    End
   Else
    LinhaDataText[I].Texto  := LinhaDataText[I + 1].Texto;
  End;
End;

procedure TForm7.ImprimiLinhasDatas3D;
Var
 vMaxCharAtual,
 I,
 VMaxLinhas,
 VMaxChars  : Integer;
 VTextoOld,
 vTextRight,
 VTempText,
 VTexto     : String;
Begin
 Try
  If LinhasPrint = Nil Then
   LinhasPrint  := TStringList.Create;
  LinhasPrint.Clear;
  If (VMaxLinhasData mod 2) = 0 Then
   VMaxLinhasData := VMaxLinhasData -1;
  VMaxLinhas := VMaxLinhasData;
  If Length(LinhaDataText) = 0 Then
   LimpaLinhasData3D;
  I := 0;
  While I <= Length(LinhaDataText) -1 Do
   Begin
    VMaxChars  := 16;
    vMaxCharAtual := VMaxChars;
    If (I = (VMaxLinhas div 2)) Then
     VTexto := LinhaDataText[I].Texto
    Else
     VTexto := Copy(LinhaDataText[I].Texto, 1, VMaxChars);
    VTexto := StringReplace(StringReplace(StringReplace(StringReplace(
              StringReplace(StringReplace(StringReplace(VTexto, '/', '', [rfReplaceAll]),
                                                  '-', '', [rfReplaceAll]),
                                                  '-', '', [rfReplaceAll]),
                                                  '''', '', [rfReplaceAll]),
                                                  '\', '', [rfReplaceAll]),
                                                  '  ', ' ', [rfReplaceAll]),
                                                  ',', '', [rfReplaceAll]);
    VTextoOld := VTexto;
    VTexto := Copy(VTextoOld, 1, vMaxCharAtual);
    LinhasPrint.Add(VTexto);
    Inc(I);
   End;
 Except
 End;
End;

procedure TForm7.glInit;
Var
 I : Integer;
begin
  glClearColor(0.0, 0.0, 0.0, 0.0); // Black Background
  glShadeModel(GL_SMOOTH);          // Enables Smooth Color Shading
  glClearDepth(1.0);                // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);          // Enable Depth Buffer
  glDepthFunc(GL_LESS);		          // The Type Of Depth Test To Do
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.4);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);//Realy Nice perspective calculations
  Angle :=100;
  MyQuadratic := gluNewQuadric();		          // Create A Pointer To The Quadric Object (Return 0 If No Memory) (NEW)
  gluQuadricNormals(MyQuadratic, GLU_SMOOTH);	// Create Smooth Normals (NEW)
  gluQuadricTexture(MyQuadratic, GL_TRUE);   	// Create Texture Coords (NEW)
end;

procedure TForm7.StartGl;
Var
 PixelFormat : GLuint;         // Settings for the OpenGL rendering
 PixelDepth  : Integer;
 pfd : PIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
begin
 PixelDepth := vDepthBits;
  //Rendering Context initialisieren
 h_DC := GetDC(Self.Handle);
 with pfd do
  begin
   nSize           := SizeOf(PIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
   nVersion        := 1;                    // The version of this data structure
   dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
                      or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
                      or PFD_DOUBLEBUFFER;  // Supports double buffering
   iPixelType      := PFD_TYPE_RGBA;        // RGBA color format
   cColorBits      := PixelDepth;           // OpenGL color depth
   cRedBits        := 0;                    // Number of red bitplanes
   cRedShift       := 0;                    // Shift count for red bitplanes
   cGreenBits      := 0;                    // Number of green bitplanes
   cGreenShift     := 0;                    // Shift count for green bitplanes
   cBlueBits       := 0;                    // Number of blue bitplanes
   cBlueShift      := 0;                    // Shift count for blue bitplanes
   cAlphaBits      := 0;                    // Not supported
   cAlphaShift     := 0;                    // Not supported
   cAccumBits      := 0;                    // No accumulation buffer
   cAccumRedBits   := 0;                    // Number of red bits in a-buffer
   cAccumGreenBits := 0;                    // Number of green bits in a-buffer
   cAccumBlueBits  := 0;                    // Number of blue bits in a-buffer
   cAccumAlphaBits := 0;                    // Number of alpha bits in a-buffer
   cDepthBits      := vDepthBits;           // Specifies the depth of the depth buffer
   cStencilBits    := 0;                    // Turn off stencil buffer
   cAuxBuffers     := 0;                    // Not supported
   iLayerType      := PFD_MAIN_PLANE;       // Ignored
   bReserved       := 0;                    // Number of overlay and underlay planes
   dwLayerMask     := 0;                    // Ignored
   dwVisibleMask   := 0;                    // Transparent color of underlay plane
   dwDamageMask    := 0;                     // Ignored
  end;
 PixelFormat := ChoosePixelFormat(h_DC, @pfd);
 If (PixelFormat = 0) Then
  Begin
   MessageBox(0, 'Impossível de definir esse formato de Pixels', 'Erro...', MB_OK or MB_ICONERROR);
   Exit;
  End;
 If (Not SetPixelFormat(h_DC, PixelFormat, @pfd)) Then
  Begin
   MessageBox(0, 'Impossível de definir esse formato de Pixels', 'Erro...', MB_ICONERROR + MB_OK);
   Halt(100);
  End;
 h_RC := wglCreateContext(h_DC);
 If (h_RC = 0) Then
  Begin
   MessageBox(0, 'O Contexto Renderizador não pode ser criado.', 'Erro...', MB_ICONERROR + MB_OK);
   Halt(100);
  End;
 If (Not wglMakeCurrent(h_DC, h_RC)) Then
  Begin
   MessageBox(0, 'O Contexto Renderizador não pode ser Ativado.', 'Erro...', MB_ICONERROR + MB_OK);
   Halt(100);
  End;
 glResizeWnd(Screen.Width, Screen.Height);
 glInit;
End;

Procedure TForm7.glResizeWnd(Width, Height : Integer);
Begin
 If (Height = 0) then                // prevent divide by zero exception
  Height := 1;
 glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
 glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
 glLoadIdentity();                   // Reset View
 gluPerspective(45.0, Width/Height, 1.0, 100.0);  // Do the perspective calculations. Last value = max clipping depth
 glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
 glLoadIdentity();                   // Reset View
End;

procedure TForm7.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 DataList.Free;
 Release;
end;

procedure TForm7.FormCreate(Sender: TObject);
begin
 InitializedApp := False;
 LinhasPrint    := Nil;
end;

procedure TForm7.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 Case key Of
  vk_down   : IncLinData3D(DataList);
  vk_Up     : DecLinData3D(DataList);
  vk_escape : Close;
 End;
end;

procedure TForm7.FormShow(Sender: TObject);
begin
 BuildInterface;
 tVideoFrame.Enabled := True;
end;

Procedure TForm7.SetupGL;
Begin
 glClearColor(0.0, 0.0, 0.0, 0.0);
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_CULL_FACE);
 glShadeModel(GL_SMOOTH);
 glInit();
End;

Procedure TForm7.glDraw;
Var
 vTempSpeed : TSpeedMatriz;
 Procedure GeraSitua1; //Situação parado
 Var
  A : Integer;
 Begin
  vBackGroundDatas3D.InitSide := 36;
  vTempSpeed.X    := 0.0;//Velocidade Eixo X
  vTempSpeed.Y    := 0.1;//Velocidade Eixo Y
  vTempSpeed.Z    := 0.0;//Velocidade Eixo Y
  vTempSpeed.W    := 0.0;
  vBackGroundDatas3D.Speed  := vTempSpeed;//Velocidade
  vBackGroundDatas3D.DrawCube;
  If Not Assigned(LinhasPrint) Then
   Begin
    LinhasPrint := TStringList.Create;
    DataList    := TStringList.Create;
    RESTDWClientSQL1.Close;
    RESTDWClientSQL1.Open;
    While Not RESTDWClientSQL1.Eof Do
     Begin
      DataList.Add(RESTDWClientSQL1.FindField('Full_Name').AsString);
      RESTDWClientSQL1.Next;
     End;
    RESTDWClientSQL1.Close;
    LimpaLinhasData3D;
    LoadLinhasData3D(DataList);
   End;
  vListaEmpregados3D.TextWrite.Clear;
  ImprimiLinhasDatas3D;
  For A := 0 To LinhasPrint.Count -1 Do
   vListaEmpregados3D.TextWrite.Add(LinhasPrint[A]);
  vListaEmpregados3D.DrawCube;
 End;
Begin
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 GeraSitua1;
 SwapBuffers(h_DC);
End;

procedure TForm7.tVideoFrameTimer(Sender: TObject);
begin
 tVideoFrame.Enabled := False;
 glDraw;
 tVideoFrame.Enabled := True;
end;

Procedure TForm7.BuildInterface;
Var
 I, Z       : Integer;
 vTempSpeed : TSpeedMatriz;
Begin
 if InitializedApp then
  Exit;
 InitializedApp := True;
 SetupGL;
 StartGl;
 LoadTexture(Format('%s%s.tga', [ExtractFilePath(Application.Exename), 'fontlines']), texFont, False);
 If vBackGroundDatas3D = Nil Then
  Begin
   vBackGroundDatas3D   := TCube3D.Create(@h_DC);
   vBackGroundDatas3D.InitSide := 36;
   vBackGroundDatas3D.ImageFile := Format('%s%s.jpg', [ExtractFilePath(Application.Exename), 'rdw']);
   vTempSpeed.X    := 0.0;//Velocidade Eixo X
   vTempSpeed.Y    := 0.2;//Velocidade Eixo Y
   vTempSpeed.Z    := 0.0;//Velocidade Eixo Y
   vTempSpeed.W    := 0.0;
   vBackGroundDatas3D.Speed  := vTempSpeed;//Velocidade
   vBackGroundDatas3D.PosX   := vCentroTela + 0.2;//Centro da Tela
   vBackGroundDatas3D.PosY   := 1.2;//Esquerda
   vBackGroundDatas3D.PosZ   := 1.3;//Tamanho
   vBackGroundDatas3D.Top    := 0.0;//Topo
   vBackGroundDatas3D.Height := 1;
   vBackGroundDatas3D.Width  := 2;
   vBackGroundDatas3D.yAngle := 3;//32; = Centro
   vBackGroundDatas3D.xAngle := 1;//32; = Centro
  End;
 If vListaEmpregados3D = Nil Then
  Begin
   vListaEmpregados3D      := TCube3D.Create(@h_DC);
   vTempSpeed.X    := 0.0;//Velocidade Eixo X
   vTempSpeed.Y    := 0.0;//Velocidade Eixo Y
   vTempSpeed.W    := 0;//Velocidade Eixo Y
   vTempSpeed.Z    := -30.9;
   vListaEmpregados3D.Speed  := vTempSpeed;//Velocidade
   vListaEmpregados3D.PosX   := vBackGroundDatas3D.PosX;//Centro da Tela
   vListaEmpregados3D.PosY   := -0.5;//Esquerda
   vListaEmpregados3D.PosZ   := 0.46;//Tamanho
   vListaEmpregados3D.Top    := 0.0;//Topo
   vListaEmpregados3D.Height := 1.4;
   vListaEmpregados3D.Width  := 1.4;
   vListaEmpregados3D.yAngle := 62;//32; = Centro
   vListaEmpregados3D.xAngle := 1;//32; = Centro
   vListaEmpregados3D.ImageFile := Format('%s%s.jpg', [ExtractFilePath(Application.Exename), 'boxData']);
   vListaEmpregados3D.DrawAlpha := False;
   vListaEmpregados3D.PrintArea := [paDown, paLeft, paUp, paAhead, paBack];
   vListaEmpregados3D.PathsTexturesCube[5] := Format('%s%s.jpg', [ExtractFilePath(Application.Exename), 'mcenter']);
   vListaEmpregados3D.ReloadTexturesCube;
  End;
 glTranslatef(21, 0.0, -39 + (CorrectionPos * -1));
 glRotatef(30, 0.0, -1.1, 0.0);
End;

end.
