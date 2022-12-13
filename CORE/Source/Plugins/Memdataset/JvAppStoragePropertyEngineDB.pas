unit JvAppStoragePropertyEngineDB;

{$I ..\..\CORE\Source\Includes\uRESTDWPlataform.inc}

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


procedure RegisterAppStoragePropertyEngines;

implementation

uses
  Classes, DBGrids,
  JvJCLUtils, JvAppStorage;

type
  TJvAppStoragePropertyDBGridColumnsEngine = class(TJvAppStoragePropertyBaseEngine)
  public
    function Supports(AObject: TObject; AProperty: TObject): Boolean; override;
    procedure ReadProperty(AStorage: TJvCustomAppStorage; const APath: string; AObject: TObject; AProperty: TObject; const Recursive,
      ClearFirst: Boolean; const IgnoreProperties: TStrings = nil); override;
    procedure WriteProperty(AStorage: TJvCustomAppStorage; const APath: string; AObject: TObject; AProperty: TObject; const
      Recursive: Boolean; const IgnoreProperties: TStrings = nil); override;
  end;

//=== { TJvAppStoragePropertyDBGridColumnsEngine } ===========================

function TJvAppStoragePropertyDBGridColumnsEngine.Supports(AObject: TObject; AProperty: TObject): Boolean;
begin
  Result := Assigned(AProperty) and (AProperty is TDBGridColumns);
end;

type
  TAccessCustomDBGrid = class(TCustomDBGrid);

procedure TJvAppStoragePropertyDBGridColumnsEngine.ReadProperty(AStorage: TJvCustomAppStorage; const APath: string; AObject:
  TObject; AProperty: TObject; const Recursive, ClearFirst: Boolean; const IgnoreProperties: TStrings = nil);
begin
  if Assigned(AObject) and (AObject is TCustomDBGrid) then
    TAccessCustomDBGrid(AObject).BeginLayout;
  try
    if Assigned(AProperty) and (AProperty is TDBGridColumns) then
      AStorage.ReadCollection(APath, TCollection(AProperty), ClearFirst);
  finally
    if Assigned(AObject) and (AObject is TCustomDBGrid) then
      TAccessCustomDBGrid(AObject).EndLayout;
  end;
end;

procedure TJvAppStoragePropertyDBGridColumnsEngine.WriteProperty(AStorage: TJvCustomAppStorage; const APath: string; AObject:
  TObject; AProperty: TObject; const Recursive: Boolean; const IgnoreProperties: TStrings = nil);
begin
  if Assigned(AProperty) and (AProperty is TDBGridColumns) then
    AStorage.WriteCollection(APath, TCollection(AProperty));
end;

//=== Global =================================================================

procedure RegisterAppStoragePropertyEngines;
begin
  RegisterAppStoragePropertyEngine(TJvAppStoragePropertyDBGridColumnsEngine);
end;

procedure UnregisterAppStoragePropertyEngines;
begin
  UnregisterAppStoragePropertyEngine(TJvAppStoragePropertyDBGridColumnsEngine);
end;

initialization
  RegisterAppStoragePropertyEngines;

finalization
  UnregisterAppStoragePropertyEngines;

end.
