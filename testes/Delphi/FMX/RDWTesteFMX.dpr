program RDWTesteFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'src\Telas\uPrincipal.pas' {fPrincipal},
  uRESTDAO in 'src\DAO\uRESTDAO.pas',
  uRDWDBWareDAO in 'src\DAO\uRDWDBWareDAO.pas',
  uRDWRESTDAO in 'src\DAO\uRDWRESTDAO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
