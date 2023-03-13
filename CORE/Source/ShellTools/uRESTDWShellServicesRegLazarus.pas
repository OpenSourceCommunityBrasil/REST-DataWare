unit uRESTDWShellServicesRegLazarus;

{$I ..\Includes\uRESTDW.inc}

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
    StdCtrls, ComCtrls, Forms, ExtCtrls, DBCtrls, DBGrids, Dialogs, Controls,
    Variants, TypInfo, SysUtils, FormEditingIntf, PropEdits, lazideintf,
    LResources, LazFileUtils, ProjectIntf, ComponentEditors, Classes, fpWeb,
    uRESTDWShellServicesLazarus, uRESTDWAbout;

Type
 TRESTDWAboutDialogProperty = class(TClassPropertyEditor)
Public
 Procedure Edit; override;
 Function  GetAttributes : TPropertyAttributes; Override;
 Function  GetValue      : String;              Override;
End;

Procedure Register;

Implementation

uses uRESTDWConsts, utemplateproglaz;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Service', [TRESTDWShellService]);
 RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfo),   Nil, 'AboutInfo', TRESTDWAboutDialogProperty);
End;

 Procedure UnlistPublishedProperty (ComponentClass:TPersistentClass; const PropertyName:String);
 var
   pi :PPropInfo;
 begin
   pi := TypInfo.GetPropInfo (ComponentClass, PropertyName);
   if (pi <> nil) then
     RegisterPropertyEditor (pi^.PropType, ComponentClass, PropertyName, PropEdits.THiddenPropertyEditor);
 end;

Procedure TRESTDWAboutDialogProperty.Edit;
Begin
 RESTDWAboutDialog;
End;

Function TRESTDWAboutDialogProperty.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadOnly];
End;

Function TRESTDWAboutDialogProperty.GetValue: String;
Begin
 Result := 'Version : '+ RESTDWVERSAO;
End;

initialization
{$I RESTDWShellservices.lrs}
 UnlistPublishedProperty(TRESTDWShellService,  'Active');
 UnlistPublishedProperty(TRESTDWShellService,  'ServicePort');
 UnlistPublishedProperty(TRESTDWShellService,  'RequestTimeOut');

Finalization

end.
