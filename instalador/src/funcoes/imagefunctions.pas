unit imagefunctions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IntfGraphics, FPimage, ExtCtrls, Graphics, Forms;

type
  TImageAnimDirection = (iadUP, iadDOWN);

  { TImgUtils }

  TImgUtils = class
  private
    FPorc: integer;
  public
    procedure pintaImagemBaixoCima(aImage: TImage; aProgress: double);
    procedure pintaImagemCimaBaixo(aImage: TImage; aProgress: double);
    procedure AnimaImagemFade(aImage: TImage; aOpacity: byte;
      aDuracao: single = 2.0; aDirecao: TImageAnimDirection = iadUP);
  published
  end;

implementation

{ TImgUtils }

procedure TImgUtils.pintaImagemBaixoCima(aImage: TImage; aProgress: double);
var
  i, j, hporc: integer;
  png1, png2: TPortableNetworkGraphic;
  Opacity: byte;
  t: TLazIntfImage;
  col: TFPColor;
begin
  png1 := TPortableNetworkGraphic.Create;
  png1.Assign(aImage.Picture.Graphic);

  png2 := TPortableNetworkGraphic.Create;
  png2.Width := png1.Width;
  png2.Height := png1.Height;
  png2.PixelFormat := pf32bit;
  Opacity := 220;

  try
    t := png1.CreateIntfImage;

    hporc := Trunc(aProgress * t.Height / 100);
    hporc := t.Height - hporc;

    for I := 0 to t.Height - 1 do
      for J := 0 to t.Width - 1 do
      begin
        col := t.Colors[j, i];
        if i <= hporc then
        begin
          col.Red := (col.Red * Opacity) div $FF;
          col.Green := (col.Green * Opacity) div $FF;
          col.Blue := (col.Blue * Opacity) div $FF;
        end;
        t.Colors[j, i] := col;
      end;
    png2.LoadFromIntfImage(t);
    aImage.Picture.Assign(png2);
  finally

    png1.Free;
    png2.Free;
  end;
end;

procedure TImgUtils.pintaImagemCimaBaixo(aImage: TImage; aProgress: double);
var
  i, j, hporc: integer;
  png1, png2: TPortableNetworkGraphic;
  Opacity: byte;
  t: TLazIntfImage;
  col: TFPColor;
begin
  png1 := TPortableNetworkGraphic.Create;
  png1.Assign(aImage.Picture.Graphic);

  png2 := TPortableNetworkGraphic.Create;
  png2.Width := png1.Width;
  png2.Height := png1.Height;
  png2.PixelFormat := pf32bit;
  Opacity := 225;

  try
    t := png1.CreateIntfImage;

    hporc := Trunc(aProgress * t.Height / 100);

    for I := 0 to t.Height - 1 do
      for J := 0 to t.Width - 1 do
      begin
        col := t.Colors[j, i];
        if i >= hporc then
        begin
          col.Red := (col.Red * Opacity) div $FF;
          col.Green := (col.Green * Opacity) div $FF;
          col.Blue := (col.Blue * Opacity) div $FF;
        end;
        t.Colors[j, i] := col;
      end;
    png2.LoadFromIntfImage(t);
    aImage.Picture.Assign(png2);
  finally
    png1.Free;
    png2.Free;
  end;
end;

procedure TImgUtils.AnimaImagemFade(aImage: TImage; aOpacity: byte;
  aDuracao: single; aDirecao: TImageAnimDirection);
var
  i, j, hporc, aprogress: integer;
  png1, png2: TPortableNetworkGraphic;
  t: TLazIntfImage;
  col: TFPColor;
begin
  png1 := TPortableNetworkGraphic.Create;
  png1.Assign(aImage.Picture.Graphic);

  png2 := TPortableNetworkGraphic.Create;
  png2.Width := png1.Width;
  png2.Height := png1.Height;
  png2.PixelFormat := pf32bit;

  aprogress := 1;
  t := png1.CreateIntfImage;
  try
    while aprogress < t.Height -1 do
    begin
      hporc := Trunc(aProgress * t.Height / 100);
      if aDirecao = iadUP then
        hporc := t.Height - hporc;

      for I := 0 to hporc - 1 do
        for J := 0 to t.Width - 1 do
        begin
          col := t.Colors[j, i];
          col.Red := (col.Red * aOpacity) div $FF;
          col.Green := (col.Green * aOpacity) div $FF;
          col.Blue := (col.Blue * aOpacity) div $FF;
          t.Colors[j, i] := col;
        end;
      png2.LoadFromIntfImage(t);
      aImage.Picture.Assign(png2);
      Application.ProcessMessages;
      Sleep(1);
      Inc(aprogress);
    end;
  finally
    t.Free;
    png1.Free;
    png2.Free;
  end;
end;

end.
