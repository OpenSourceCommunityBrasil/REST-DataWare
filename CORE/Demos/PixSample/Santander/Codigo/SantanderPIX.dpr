program SantanderPIX;

uses
  Vcl.Forms,
  PIX_Tela in 'PIX_Tela.pas' {frmPIX_Tela};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPIX_Tela, frmPIX_Tela);
  Application.Run;
end.
