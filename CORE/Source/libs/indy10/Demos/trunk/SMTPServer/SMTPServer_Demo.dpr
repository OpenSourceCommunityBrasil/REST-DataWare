{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  108526: SMTPServer_Demo.dpr 
{
{   Rev 1.0    14/08/2004 12:29:18  ANeillans
{ Initial Checkin
}
{
{   Rev 1.0    12/09/2003 21:41:36  ANeillans
{ Initial Checking.
{ Verified with Indy 9 and D7
}
program SMTPServer_Demo;

uses
  {$IFDEF Linux}
  QForms,
  {$ELSE}
  Forms,
  {$ENDIF}
  Main in 'Main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
