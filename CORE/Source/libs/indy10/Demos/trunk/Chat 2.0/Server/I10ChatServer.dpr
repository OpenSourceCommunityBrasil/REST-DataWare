{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22970: I10ChatServer.dpr 
{
{   Rev 1.0    09/10/2003 3:15:38 PM  Jeremy Darling
{ Project uploaded for the first time
}
program I10ChatServer;

uses
  Forms,
  MainForm in 'Forms\MainForm.pas' {frmMain},
  ChatContextData in 'Units\ChatContextData.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Indy 10 Chat Demo (Server)';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
