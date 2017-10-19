program EmilPop3;

uses
  Forms,
  Pop3MainUnit in 'Pop3MainUnit.pas' {Pop3Main},
  MBoxDataModule in 'MBoxDataModule.pas' {MBoxDataMod: TDataModule},
  ProviderUnit in 'ProviderUnit.pas' {ProviderForm},
  Ras in 'Ras.pas',
  Pop3DBModule in 'Pop3DBModule.pas' {Pop3DBMod: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'MailServer';
  Application.CreateForm(TPop3Main, Pop3Main);
  Application.CreateForm(TMBoxDataMod, MBoxDataMod);
  Application.CreateForm(TProviderForm, ProviderForm);
  Application.CreateForm(TPop3DBMod, Pop3DBMod);
  Application.Run;
end.
