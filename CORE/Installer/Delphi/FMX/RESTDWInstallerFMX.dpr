program RESTDWInstallerFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  uRESTDWInstallerFMXWizard in 'uRESTDWInstallerFMXWizard.pas',
  uRESTDWInstallerCore in '..\..\Common\uRESTDWInstallerCore.pas',
  uRESTDWInstallerConfig in '..\..\Common\uRESTDWInstallerConfig.pas',
  uRESTDWDelphiInstall in '..\Common\uRESTDWDelphiInstall.pas';


{$R *.res}

begin
 Application.Initialize;
 Application.CreateForm(TfrmRESTDWInstallerFMX, frmRESTDWInstallerFMX);
 Application.Run;
end.
