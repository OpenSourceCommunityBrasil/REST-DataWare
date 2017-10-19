{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16676: IdSoapAbout.pas 
{
{   Rev 1.0    25/2/2003 14:02:06  GGrieve
}
{
Version History:
  06-Aug 2002   Grahame Grieve                  First implemented
}

unit IdSoapAbout;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TIndySoapToolsAbout = class(TForm)
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  IndySoapToolsAbout: TIndySoapToolsAbout;

implementation

{$R *.DFM}

uses
  IdSoapConsts;

procedure TIndySoapToolsAbout.FormCreate(Sender: TObject);
begin
  Label2.Caption := 'Version '+ID_SOAP_VERSION;
end;

end.
 
