{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  57996: ImapDemo.dpr 
{
{   Rev 1.0    13/04/2004 22:30:56  CCostelloe
{ Basic demo including deleting files.
}
program ImapDemo;

uses
  Forms,
  ImapDemo1 in 'ImapDemo1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
