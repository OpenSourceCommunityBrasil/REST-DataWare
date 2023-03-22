unit uRESTDWZPlainDriver;

{$I ..\..\Includes\uRESTDW.inc}

{$IFNDEF RESTDWLAZARUS}
  {$I ZDbc.inc}
{$ENDIF}

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

{$IFNDEF ZEOS_DISABLE_RDW}

uses
  {$IFDEF MSEgui}mclasses,{$ENDIF}
  {$IFDEF OLDFPC}ZClasses,{$ENDIF}
  SysUtils, Classes,
  ZCompatibility, ZPlainDriver;

type
  TZRESTDWPlainDriver = class (TZAbstractPlainDriver, IZPlainDriver)
  protected
    function Clone: IZPlainDriver; override;
    procedure LoadCodePages; override;
  public
    constructor Create;
    destructor Destroy; override;
    function GetProtocol: string; override;
    function GetDescription: string; override;
  end;

{$ENDIF ZEOS_DISABLE_RDW}

implementation

{$IFNDEF ZEOS_DISABLE_RDW}

uses ZPlainLoader, ZEncoding, ZClasses, ZMessages, ZFastCode, ZSysUtils;

{ TZRDWPlainDriver }

function TZRESTDWPlainDriver.GetProtocol: string;
begin
  Result := 'restdw';
end;

function TZRESTDWPlainDriver.Clone: IZPlainDriver;
begin
  Result := TZRESTDWPlainDriver.Create;
end;

procedure TZRESTDWPlainDriver.LoadCodePages;
begin
  AddCodePage('UTF-8', 1, ceUTF8, zCP_UTF8, '', 4);
end;

constructor TZRESTDWPlainDriver.Create;
begin
  inherited Create;
  LoadCodePages;
end;

destructor TZRESTDWPlainDriver.Destroy;
begin
  inherited;
end;

function TZRESTDWPlainDriver.GetDescription: string;
begin
  Result := 'Native Plain Driver for RestDataware';
end;

{$ENDIF ZEOS_DISABLE_RDW}

end.

