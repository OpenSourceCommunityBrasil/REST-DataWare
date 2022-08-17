{*************************************************************************}
{ RDW Wizards components                                                  }
{ para Delphi                                                             }
{                                                                         }
{ Desenvolvido por A. Brito                                               }
{           Email : comercial@abritolda.com                               }
{           Web : http://www.abritolda.com                                }
{                                                                         }
{*************************************************************************}

unit STLWizardreg;

interface

uses
  {$IFNDEF FPC}
   {$if CompilerVersion > 22}
    STLWizard,
   {$ELSE}
    STLWizardOldDelphi,
   {$IFEND}
  {$ENDIF}
  RDWCGIWizard,
  Classes, DesignIntf, ToolsAPI, DesignEditors;

procedure Register;

implementation

procedure Register;
begin
  //RegisterPackageWizard(TSTLApplicationWizard.Create);
  RegisterPackageWizard(TSTLRDWDataModule.Create);
  RegisterPackageWizard(TCGIApplicationWizard.Create);
end;

end.
