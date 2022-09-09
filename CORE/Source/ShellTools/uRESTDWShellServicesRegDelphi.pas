unit uRESTDWShellServicesRegDelphi;

{$I ..\..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
  de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
  Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
  de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  A. Brito                   - Admin - Administrador do desenvolvimento.
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
  Flávio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}


interface

uses
  {$IFDEF FPC}
    StdCtrls, ComCtrls, ExtCtrls, DBCtrls, DBGrids, Dialogs, Controls, Variants, TypInfo, uRESTDWShellServices,
    LResources, LazFileUtils, SysUtils, FormEditingIntf, PropEdits, lazideintf, ProjectIntf, ComponentEditors, Classes, fpWeb;
  {$ELSE}
   Windows, SysUtils, Variants, StrEdit, TypInfo, uRESTDWShellServicesDelphi,
   RTLConsts,
   {$IFDEF COMPILER16_UP}
   UITypes,
   {$ENDIF}
   {$if CompilerVersion > 22}
    ToolsApi, DesignWindows, DesignEditors, DBReg, DSDesign,
    DesignIntf, ExptIntf, Classes, Db, ColnEdit;
   {$ELSE}
    ToolsApi, DesignWindows, DesignEditors, DBReg, DesignIntf,
    Classes, Db, DbTables, DSDesign, ColnEdit;
   {$IFEND}
  {$ENDIF}

Procedure Register;

Implementation

{$IFNDEF FPC}
 {$if CompilerVersion < 23}
  {$R .\RESTDWShellServicesDesign.dcr}
 {$IFEND}
{$ENDIF}

uses uRESTDWCharset{$IFDEF FPC}, utemplateproglaz{$ENDIF};

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Service',     [TRESTDWShellService]);
 UnlistPublishedProperty(TRESTDWShellService,  'Active');
 UnlistPublishedProperty(TRESTDWShellService,  'ServicePort');
 UnlistPublishedProperty(TRESTDWShellService,  'RequestTimeOut');
End;

{$IFDEF FPC}
 Procedure UnlistPublishedProperty (ComponentClass:TPersistentClass; const PropertyName:String);
 var
   pi :PPropInfo;
 begin
   pi := TypInfo.GetPropInfo (ComponentClass, PropertyName);
   if (pi <> nil) then
     RegisterPropertyEditor (pi^.PropType, ComponentClass, PropertyName, PropEdits.THiddenPropertyEditor);
 end;
{$ENDIF}

initialization

Finalization

end.
