{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22983: I10ChatClient.dpr 
{
{   Rev 1.0    09/10/2003 3:17:12 PM  Jeremy Darling
{ Project uploaded for the first time
}
program I10ChatClient;

uses
  Forms,
  MainForm in 'Forms\MainForm.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
