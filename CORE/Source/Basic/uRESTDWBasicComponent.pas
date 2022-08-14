unit uRESTDWBasicComponent;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

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
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

Uses {$IFDEF FPC}
      SysUtils, Classes
     {$ELSE}
      {$IF CompilerVersion <= 22}
       SysUtils, Classes
      {$ELSE}
       System.SysUtils, System.Classes
      {$IFEND}
     {$ENDIF};

Type
 TRESTDWAboutInfo = (RESTDWAbout);
 TRESTDWComponent = Class(TComponent)
 Private
  fsAbout : TRESTDWAboutInfo;
  Function GetVersionInfo : String;
 Public
  Property VersionInfo : String Read GetVersionInfo;
 Published
  Property AboutInfo : TRESTDWAboutInfo Read fsAbout Write fsAbout Stored False;
 End;

implementation

uses uRESTDWConsts;

Function TRESTDWComponent.GetVersionInfo : String;
Begin
 Result := Format('%s%s', [RESTDWVersionINFO, RESTDWRelease]);
End;

end.
