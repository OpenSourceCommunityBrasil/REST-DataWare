program ClienteFMX;

uses
  System.StartUpCopy,
  System.IoUtils,
  FMX.Forms,
  IdSSLOpenSSLHeaders,
  {$IFDEF IOS}
  IdSSLOpenSSLHeaders_Static,
  {$ENDIF }
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF ANDROID}
  IdOpenSSLSetLibPath(TPath.GetDocumentsPath);
  {$ENDIF}
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
