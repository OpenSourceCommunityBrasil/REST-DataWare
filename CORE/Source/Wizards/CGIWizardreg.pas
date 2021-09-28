{*************************************************************************}
{ RDW Wizards components                                                  }
{ para Delphi                                                             }
{                                                                         }
{ Desenvolvido por A. Brito                                               }
{           Email : comercial@abritolda.com                               }
{           Web : http://www.abritolda.com                                }
{                                                                         }
{*************************************************************************}

unit CGIWizardreg;

interface

uses
  {$IFNDEF FPC}
   {$if CompilerVersion > 22}
    RDWCGIWizard,
   {$ELSE}
    RDWCGIWizard,
   {$IFEND}
  {$ENDIF}
  Classes, DesignIntf, ToolsAPI, DesignEditors;

procedure Register;

implementation

procedure Register;
begin
  RegisterPackageWizard(TCGIApplicationWizard.Create);
end;

end.
