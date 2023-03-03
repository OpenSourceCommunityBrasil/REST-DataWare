unit utesteanim;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfTesteAnim }

  TfTesteAnim = class(TForm)
    Button1: TButton;
    ImageList1: TImageList;
    imFundo: TImage;
    imOverlay: TImage;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private

  public

  end;

var
  fTesteAnim: TfTesteAnim;

implementation

{$R *.lfm}

{ TfTesteAnim }

procedure TfTesteAnim.Button1Click(Sender: TObject);
begin
  imOverlay.Height := imFundo.Height;
  imOverlay.Width := imFundo.Width;
  imOverlay.Left := imFundo.Left;
  imOverlay.Top := imFundo.Top;
  ImageList1.GetBitmap(3, imFundo.Picture.Bitmap);
  ImageList1.GetBitmap(2, imOverlay.Picture.Bitmap);
  timer2.Enabled := False;
  Timer1.Enabled := True;
end;

procedure TfTesteAnim.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  Self.Free;
end;

procedure TfTesteAnim.FormCreate(Sender: TObject);
begin
  Timer1.Enabled := False;
  Timer2.Enabled := False;
end;

procedure TfTesteAnim.Timer1Timer(Sender: TObject);
begin
  if imOverlay.Height > 0 then
    imOverlay.Height := imOverlay.Height - 1
  else
  begin
    ImageList1.GetBitmap(1, imFundo.Picture.Bitmap);
    ImageList1.GetBitmap(0, imOverlay.Picture.Bitmap);
    imOverlay.Height := 0;
    timer2.Enabled := True;
    Timer1.Enabled := False;
  end;
end;

procedure TfTesteAnim.Timer2Timer(Sender: TObject);
begin
  if imOverlay.Height < imFundo.Height then
    imOverlay.Height := imOverlay.Height + 1
  else
  begin
    Timer2.Enabled := False;
  end;
end;

end.
