program DWInstalL;

uses
  Forms,
  SVN_Class in 'SVN_Class.pas',
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uFrameLista in 'uFrameLista.pas' {framePacotes: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Instalação do Projeto REST Dataware';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
