unit FireDAC.Phys.RESTDW;

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
 Fernando Banhos            - Drivers e Datasets.
}

interface

uses
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.DatS,
  FireDAC.Phys,
  FireDAC.Phys.RESTDWBase;

type
  {$IFDEF DELPHI10_3UP}
  [ComponentPlatformsAttribute(pfidWindows or pfidOSX or pfidLinux)]
  {$ENDIF}
  TRESTDWFireDACPhysLink = class(TFDPhysRDWBaseDriverLink)

  end;

{-------------------------------------------------------------------------------}
implementation

uses
  System.Variants, System.SysUtils, System.Generics.Collections, Data.DB,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.Stan.Option, FireDAC.Stan.Util,
  FireDAC.Stan.Consts, FireDAC.Stan.ResStrs, FireDAC.Phys.Intf,
  FireDAC.Phys.SQLGenerator, FireDAC.Phys.RESTDWDef;

type
  TFDPhysRDWDriver = class;

  TFDPhysRDWDriver = class(TFDPhysRDWDriverBase)
  protected
    function InternalCreateConnection(AConnHost: TFDPhysConnectionHost): TFDPhysConnection; override;
    class function GetBaseDriverID: String; override;
    class function GetBaseDriverDesc: String; override;
    class function GetRDBMSKind: TFDRDBMSKind; override;
    class function GetConnectionDefParamsClass: TFDConnectionDefParamsClass; override;
    function GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable; override;
  end;

function TFDPhysRDWDriver.InternalCreateConnection(
  AConnHost: TFDPhysConnectionHost): TFDPhysConnection;
begin
  Result := TFDPhysRDWConnectionBase.Create(Self, AConnHost);
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetBaseDriverID: String;
begin
  Result := S_FD_RDWId;
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetBaseDriverDesc: String;
begin
  Result := 'Rest Dataware';
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetRDBMSKind: TFDRDBMSKind;
begin
  Result := TFDRDBMSKinds.Other;
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetConnectionDefParamsClass: TFDConnectionDefParamsClass;
begin
  Result := TFDPhysRDWConnectionDefParams;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWDriver.GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable;
begin
  Result := inherited GetConnParams(AKeys, AParams);
end;

{-------------------------------------------------------------------------------}
initialization
  {$IFDEF DELPHI10_2UP}
  FDRegisterDriverClass(TFDPhysRDWDriver);
  {$ELSE}
  FDPhysManager().RegisterDriverClass(TFDPhysRDWDriver);
  {$ENDIF}
finalization
  {$IFDEF DELPHI10_2UP}
  FDUnregisterDriverClass(TFDPhysRDWDriver);
  {$ENDIF}

end.
