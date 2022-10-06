program RESTDWInstalador;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  uconsts in 'src\funcoes\uconsts.pas',
  uprincipal in 'src\telas\uprincipal.pas';

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  //Application.CreateForm(TfPrincipal, fPrincipal);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

