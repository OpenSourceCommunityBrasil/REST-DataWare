{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22929: ServerBase.dpr 
{
{   Rev 1.0    09/10/2003 3:07:16 PM  Jeremy Darling
{ Project Checked into TC for the first time
}
program ServerBase;

uses
  Forms,
  MainForm in 'Forms\MainForm.pas' {frmMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Demo Base (Server)';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
