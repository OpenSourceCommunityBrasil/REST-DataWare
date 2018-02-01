program ClientTeste;

uses
  Vcl.Forms,
  MainFormUnit in 'MainFormUnit.pas' {Form1},
  Protocol in '..\Protocol.pas',
  RequestFrameUnit in 'RequestFrameUnit.pas' {RequestFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
