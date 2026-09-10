program RESTDWInstallerVCL;

uses
  Forms,
  uRESTDWInstallerVCLWizard in 'uRESTDWInstallerVCLWizard.pas',
  uRESTDWInstallerCore in '..\..\Common\uRESTDWInstallerCore.pas',
  uRESTDWInstallerConfig in '..\..\Common\uRESTDWInstallerConfig.pas',
  uRESTDWDelphiInstall in '..\Common\uRESTDWDelphiInstall.pas';


{$R *.res}

begin
 Application.Initialize;
 Application.Title := 'REST Dataware Installer';
 Application.CreateForm(TfrmRESTDWInstallerVCL, frmRESTDWInstallerVCL);
 Application.Run;
end.
