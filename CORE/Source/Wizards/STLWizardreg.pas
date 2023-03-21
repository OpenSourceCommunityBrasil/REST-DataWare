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

{$I ..\Includes\uRESTDW.inc}

interface

uses
   {$IFDEF DELPHIXE2UP}
    STLWizard,
   {$ELSE}
    STLWizardOldDelphi,
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
