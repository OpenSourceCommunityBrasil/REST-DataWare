program BufferDB;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {fGenFile};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfGenFile, fGenFile);
  Application.Run;
end.
