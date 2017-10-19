{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  23000: IndyFTP.dpr 
{
{   Rev 1.1    09/11/2003 3:20:50 PM  Jeremy Darling
{ Completed Log Color customization.
}
{
{   Rev 1.0    09/11/2003 12:48:56 PM  Jeremy Darling
{ Project Added to TC
}
program IndyFTP;

uses
  Forms,
  MainForm in 'Forms\MainForm.pas' {frmMain},
  FTPSiteInfo in 'Units\FTPSiteInfo.pas',
  ConfigureSiteForm in 'Forms\ConfigureSiteForm.pas' {frmConfigureSite},
  ConfigureApplicationForm in 'Forms\ConfigureApplicationForm.pas' {frmConfigureApplication},
  ApplicationConfiguration in 'Units\ApplicationConfiguration.pas',
  AboutForm in 'Forms\AboutForm.pas' {frmAbout};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
