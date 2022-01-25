unit gfx;

//  Graphic Engine for Coders Games
//  Copyright by Coders Group '2000
//  http://coders.shnet.pl/klub/
//  Code: Sulek       sulek@shnet.pl
//  English version of unit !
//  Please leave information about the author even if you change something

interface

uses DXDraws, Graphics;


function CanDraw(Screen: TDXDraw): boolean;                               // checking if we could draw
procedure PreparePalette(var Screen: TDXDraw; Images: TDXImageList);      // preparing palette
procedure ClearScreen(var Screen: TDXDraw; Color: TColor= clBlack);       // clearing screen
procedure ReleaseToScreen(var Screen: TDXDraw);                           // releasing surface to screen

procedure SetText(var Screen:TDXDraw; Style: TBrushStyle;
                  Color: TColor; Size: integer);                          // sets text attributes
procedure PutText(var Screen: TDXDraw; x,y, FontSize : integer; fontname, text: string;aFontColor : TColor);       // put text on screen

procedure DrawObject(Images: TDXImageList;
                     number: byte; x,y: word);                            // draw bitmap on surface

procedure DrawRotateObject(Images: TDXImageList;
                           number: byte; x,y,sx,sy: word; Angle:integer); // Rotate draw;


implementation

uses Windows,  { do niektorych operacji z funckcji Utworz Kolor }
     DXClass,  { Dd funkcji Min w FadeOut i In}
     DIB,      { Do procedury FadeOut}
     Controls; { TMouseButton}


function CanDraw(Screen: TDXDraw): boolean;
begin
  if Screen.CanDraw then Result:= True else
  begin                  { Jezeli nie mozna rysowac }
    Result:= False;
//    WyswietlBlad('Obiekt DXDraw nie jest gotowy do rysowania');
  end;
end;



procedure PreparePalette(var Screen: TDXDraw; Images: TDXImageList);
begin
  Images.Items.MakeColorTable;
  Screen.ColorTable := Images.Items.ColorTable;
  Screen.DefColorTable := Images.Items.ColorTable;
end;

procedure ClearScreen(var Screen: TDXDraw; Color: TColor= clBlack);
begin
  Screen.Surface.Fill(Color);     // fill surface
end;

procedure ReleaseToScreen(var Screen: TDXDraw);
begin
//  Screen.Surface.Canvas.Release;  { it's recommend because system might go down }
  Screen.Flip;                    { content od surface goes to screen     }
end;


procedure SetText(var Screen:TDXDraw; Style: TBrushStyle; Color: TColor; Size: integer);
begin
 With Screen.Surface.Canvas do
  Begin
   Brush.Style := Style;
   Font.Color := Color;
   Font.Size := Size;
   Release;  { it's recommend because system might go down }
  End;
end;

procedure PutText(var Screen: TDXDraw; x, y, FontSize : integer; fontname, text: string;aFontColor : TColor);  { print text at coordinate x,y }
Var
 VTempFont : String;
 VTempFontSize : Integer;
 vFontColor    : TColor;
begin
  with Screen.Surface.Canvas do
   Begin
    VTempFont     := Font.Name;
    VTempFontSize := Font.Size;
    vFontColor    := Font.Color;
    Brush.Style   := bsClear;
    Font.Color    := clWhite;
    If fontname <> '' Then
     Font.Name := fontname;
    If FontSize > 0 Then
     Font.Size := FontSize;
    If aFontColor > 0 Then
     Font.Color := aFontColor;
    TextOut(x, y, text);
    If fontname <> '' Then
     Font.Name  := VTempFont;
    If FontSize > 0 Then
     Font.Size := VTempFontSize;
    If vFontColor > 0 Then
     Font.Color := vFontColor;
    Release;
   End;
end;


procedure DrawObject(Images: TDXImageList;number: byte; x,y: word);
begin
  Images.Items[number].Draw(images.dxdraw.surface, x, y, 0);
end;

procedure DrawRotateObject(Images: TDXImageList;number: byte; x,y,sx,sy: word; angle:integer);
begin
  Images.Items[number].Drawrotate(images.dxdraw.surface, x, y,sx,sy, 0, 0.5, 0.5, angle);
end;

end.
