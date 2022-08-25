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
  uPrincipal in 'src\telas\uprincipal.pas' {fPrincipal},
  ufrIDEItem in 'src\telas\frames\ufrideitem.pas', unit1, unit2 {frIDEItem}
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.

