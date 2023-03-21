unit uRESTDWZeosPhysLink;

{$I ..\..\Includes\uRESTDW.inc}

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
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

uses
  Classes, SysUtils, ZConnection, ZDbcIntfs, uRESTDWAbout, uRESTDWBasicDB,
  uRESTDWZDbc;

type
  TRESTDWZeosPhysLink = class(TRESTDWComponent)
  private
    FZConnection : TZConnection;
    FDatabase : TRESTDWDatabasebaseBase;
    FProvider : TZServerProvider;
    FOldZeosBeforeConnect : TNotifyEvent;
    procedure setZConnection(const Value: TZConnection);
  protected
    procedure OnRESTDWZeosBeforeConnect(Sender : TObject);
  published
    property ZConnection : TZConnection read FZConnection write setZConnection;
    property Provider : TZServerProvider read FProvider write FProvider;
    property Database : TRESTDWDatabasebaseBase read FDatabase write FDatabase;
  end;

implementation

{ TRESTDWZeosPhysLink }

procedure TRESTDWZeosPhysLink.OnRESTDWZeosBeforeConnect(Sender: TObject);
begin
  if Assigned(FOldZeosBeforeConnect) then
    FOldZeosBeforeConnect(FZConnection);
  TZRESTDWDriver(FZConnection.DbcDriver).Database := FDatabase;
end;

procedure TRESTDWZeosPhysLink.setZConnection(const Value: TZConnection);
begin
  FZConnection := Value;
  FOldZeosBeforeConnect := nil;
  if (FZConnection <> nil) and (ZConnection.Protocol = 'restdw') then begin
    FOldZeosBeforeConnect := FZConnection.BeforeConnect;
    FZConnection.BeforeConnect := {$IFDEF RESTDWLAZARUS}@{$ENDIF}OnRESTDWZeosBeforeConnect;
  end;
end;

end.
