{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  115826: TimeSync.dpr }
{
    Rev 1.0    2/11/2005 1:52:22 AM  DSiders
  Initial checkin.
}
program TimeSync;

uses
  Forms,
  TimeSyncMain in 'TimeSyncMain.pas' {FormTimeSync};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TimeSync';
  Application.CreateForm(TFormTimeSync, FormTimeSync);
  Application.Run;
end.
