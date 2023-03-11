unit fbImage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  lcltype, IntfGraphics, StdCtrls, FPimage;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1 : TBitBtn;
    imgOriginal : TImage;
    Image2 : TImage;
    rbBaixo : TRadioButton;
    rbCima : TRadioButton;
    Timer1 : TTimer;
    procedure BitBtn1Click(Sender : TObject);
    procedure Timer1Timer(Sender : TObject);
  private
    FPorc : integer;
    procedure pintaImagemBaixoCima(porc : double);
    procedure pintaImagemCimaBaixo(porc : double);
  public

  end;

var
  Form1 : TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BitBtn1Click(Sender : TObject);
begin
  FPorc := 0;
  Timer1.Enabled := True;
end;

procedure TForm1.Timer1Timer(Sender : TObject);
begin
  Timer1.Enabled := False;
  if rbCima.Checked then
    pintaImagemCimaBaixo(FPorc)
  else
    pintaImagemBaixoCima(FPorc);
  if FPorc < 100 then begin
    FPorc := FPorc + 1;
    Timer1.Enabled := True;
  end;
end;

procedure TForm1.pintaImagemBaixoCima(porc : double);
var
  i,j : integer;
  png1 : TPortableNetworkGraphic;
  png2 : TPortableNetworkGraphic;
  Opacity : Byte;
  t: TLazIntfImage;
  col:TFPColor;
  hporc : integer;
begin
  png1 := TPortableNetworkGraphic.Create;
  png1.Assign(imgOriginal.Picture.Graphic);

  png2 := TPortableNetworkGraphic.Create;
  png2.Width := png1.Width;
  png2.Height := png1.Height;
  png2.PixelFormat := pf32bit;
  Opacity := 220;

  t := png1.CreateIntfImage;

  hporc := Trunc(porc * t.Height / 100);
  hporc := t.Height - hporc;

  for I := 0 to t.Height-1 do begin
    for J := 0 to t.Width-1 do begin
      col := t.Colors[j,i];
      if i <= hporc then begin
        col.Red   := (col.Red * Opacity) div $FF;
        col.Green := (col.Green * Opacity) div $FF;
        col.Blue  := (col.Blue * Opacity) div $FF;
      end;
      t.Colors[j,i] := col;
    end;
  end;
  png2.LoadFromIntfImage(t);
  Image2.Picture.Assign(png2);

  png1.Free;
  png2.Free;
end;

procedure TForm1.pintaImagemCimaBaixo(porc : double);
var
  i,j : integer;
  png1 : TPortableNetworkGraphic;
  png2 : TPortableNetworkGraphic;
  Opacity : Byte;
  t: TLazIntfImage;
  col:TFPColor;
  hporc : integer;
begin
  png1 := TPortableNetworkGraphic.Create;
  png1.Assign(imgOriginal.Picture.Graphic);

  png2 := TPortableNetworkGraphic.Create;
  png2.Width := png1.Width;
  png2.Height := png1.Height;
  png2.PixelFormat := pf32bit;
  Opacity := 220;

  t := png1.CreateIntfImage;

  hporc := Trunc(porc * t.Height / 100);

  for I := 0 to t.Height-1 do begin
    for J := 0 to t.Width-1 do begin
      col := t.Colors[j,i];
      if i >= hporc then begin
        col.Red   := (col.Red * Opacity) div $FF;
        col.Green := (col.Green * Opacity) div $FF;
        col.Blue  := (col.Blue * Opacity) div $FF;
      end;
      t.Colors[j,i] := col;
    end;
  end;
  png2.LoadFromIntfImage(t);
  Image2.Picture.Assign(png2);

  png1.Free;
  png2.Free;
end;


end.

