unit uRESTDWZDbc;

{$I ..\..\Includes\uRESTDW.inc}
{$IFNDEF FPC}
  {$I ZDbc.inc}
{$ELSE}
  {$MODE DELPHI}
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

{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit
uses
  {$IFNDEF ZEOS80UP}ZURL,{$ENDIF}
  Classes, SysUtils,
  ZDbcIntfs, ZDbcLogging, ZTokenizer, ZPlainDriver, ZGenericSqlAnalyser,
  ZCompatibility, ZDbcConnection,
  uRESTDWZPlainDriver, uRESTDWBasicDB, uRESTDWConsts;

type
  TZRESTDWDriver = class(TZAbstractDriver)
  private
    FDatabase : TRESTDWDatabasebaseBase;
  public
    constructor Create; override;
    function Connect(const Url: TZURL): IZConnection; override;
    function GetMajorVersion: Integer; override;
    function GetMinorVersion: Integer; override;

    function GetTokenizer: IZTokenizer; override;
    function GetStatementAnalyser: IZStatementAnalyser; override;

    property Database : TRESTDWDatabasebaseBase read FDatabase write FDatabase;
  end;

  IZRESTDWConnection = interface (IZConnection)
    ['{A4B797A9-7CF7-4DE9-A5BB-693DD32D07D3}']
    function GetPlainDriver : IZPlainDriver;
    function GetDatabase : TRESTDWDatabasebaseBase;
  end;

  { TZRESTDWConnection }
  {$IFDEF ZEOS80UP}
    TZRESTDWConnection = class(TZAbstractSingleTxnConnection, IZConnection,
         IZRESTDWConnection, IZTransaction)
  {$ELSE}
    TZRESTDWConnection = class(TZAbstractConnection, IZRESTDWConnection)
  {$ENDIF}
  private
    FCatalog: string;
    FPlainDriver: TZRESTDWPlainDriver;
  protected
    procedure InternalClose; override;
    {$IFNDEF ZEOS80UP}
      procedure InternalCreate; override;
    {$ENDIF}
  public
    function GetPlainDriver: IZPlainDriver;

    procedure Commit; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    procedure Rollback; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function StartTransaction: Integer;

    {$IFDEF ZEOS80UP}
      function CreateStatementWithParams(Info: TStrings): IZStatement;
      function PrepareStatementWithParams(const SQL: string; Info: TStrings):
        IZPreparedStatement;
      function PrepareCallWithParams(const Name: String; Params: TStrings):
        IZCallableStatement;
      procedure AfterConstruction; override;
    {$ELSE}
      function CreateRegularStatement(Info: TStrings): IZStatement; override;
      function CreatePreparedStatement(const SQL: string; Info: TStrings):
        IZPreparedStatement; override;
    {$ENDIF}

    function GetTokenizer: IZTokenizer;
    function GetStatementAnalyser: IZStatementAnalyser;
    function GetDatabase : TRESTDWDatabasebaseBase;

    function GetServerProvider: TZServerProvider; override;

    procedure Open; override;
  end;

var
  RDWDriver: IZDriver;

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit
implementation
{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit

uses
  {$IFDEF ZEOS80UP}
    ZExceptions,
  {$ENDIF}
  ZSysUtils, ZFastCode, ZEncoding, ZMessages, uRESTDWZDbcStatement,
  uRESTDWZToken, uRESTDWZAnalyser, uRESTDWZDbcMetadata
  {$IFDEF WITH_UNITANSISTRINGS}, AnsiStrings{$ENDIF};

{ TZRESTDWDriver }

constructor TZRESTDWDriver.Create;
begin
  inherited Create;
  AddSupportedProtocol(AddPlainDriverToCache(TZRESTDWPlainDriver.Create, 'restdw'));
end;

function TZRESTDWDriver.GetMajorVersion: Integer;
begin
  Result := 1;
end;

function TZRESTDWDriver.GetMinorVersion: Integer;
begin
  Result := 0;
end;

function TZRESTDWDriver.GetStatementAnalyser: IZStatementAnalyser;
begin
  Result := TZRESTDWStatementAnalyser.Create;
end;

function TZRESTDWDriver.GetTokenizer: IZTokenizer;
begin
  Result := TZRESTDWTokenizer.Create;
end;

function TZRESTDWDriver.Connect(const Url: TZURL): IZConnection;
begin
  Result := TZRESTDWConnection.Create(Url);
end;

{ TZRESTDWConnection }

{$IFDEF ZEOS80UP}
procedure TZRESTDWConnection.AfterConstruction;
begin
  FPlainDriver := PlainDriver.GetInstance as TZRESTDWPlainDriver;
  FMetadata := TZRESTDWDatabaseMetadata.Create(Self, Url);
  inherited AfterConstruction;
end;
{$ENDIF}

procedure TZRESTDWConnection.Commit;
begin

end;

{$IFNDEF ZEOS80UP}
  function TZRESTDWConnection.CreatePreparedStatement(const SQL: string;
    Info: TStrings): IZPreparedStatement;
  begin
    if IsClosed then
      Open;

    Result := TZAbstractRESTDWPreparedStatement.Create(Self,SQL,Info);
  end;
{$ENDIF}

{$IFNDEF ZEOS80UP}
  function TZRESTDWConnection.CreateRegularStatement(Info: TStrings): IZStatement;
  begin
    if IsClosed then
      Open;

    Result := TZRESTDWStatement.Create(Self, Info);
  end;
{$ENDIF}

{$IFDEF ZEOS80UP}
  function TZRESTDWConnection.CreateStatementWithParams(Info: TStrings): IZStatement;
  begin
    if IsClosed then
      Open;

    Result := TZRESTDWStatement.Create(Self, Info);
  end;
{$ENDIF}

function TZRESTDWConnection.GetPlainDriver: IZPlainDriver;
begin
  {$IFNDEF ZEOS80UP}
    if FPlainDriver = nil then
      FPlainDriver := PlainDriver as TZRESTDWPlainDriver;
  {$ENDIF}

  Result := FPlainDriver;
end;

function TZRESTDWConnection.GetServerProvider: TZServerProvider;
begin
  Result := spUnknown;
end;

function TZRESTDWConnection.GetStatementAnalyser: IZStatementAnalyser;
begin
  Result := TZRESTDWStatementAnalyser.Create;
end;

function TZRESTDWConnection.GetDatabase : TRESTDWDatabasebaseBase;
begin
  Result := TZRESTDWDriver(GetDriver).Database;
end;

function TZRESTDWConnection.GetTokenizer: IZTokenizer;
begin
  Result := TZRESTDWTokenizer.Create;
end;

procedure TZRESTDWConnection.InternalClose;
var
  vDatabase : TRESTDWDatabasebaseBase;
begin
  vDatabase := GetDatabase;
  if vDatabase <> nil then
    vDatabase.Close;
  inherited;
end;

{$IFNDEF ZEOS80UP}
  procedure TZRESTDWConnection.InternalCreate;
  begin
    FMetadata := TZRESTDWDatabaseMetadata.Create(Self, Url);
    inherited;
  end;
{$ENDIF}

procedure TZRESTDWConnection.Open;
var
  vDatabase : TRESTDWDatabasebaseBase;
begin
  vDatabase := GetDatabase;
  if vDatabase = nil then
    raise Exception.Create(cErrorDatabaseNotFound);

  vDatabase.Active := True;
  inherited;
end;

{$IFDEF ZEOS80UP}
  function TZRESTDWConnection.PrepareCallWithParams(const Name: String;
    Params: TStrings): IZCallableStatement;
  begin
    // StoreProcedure - TODO ???
    Raise EZUnsupportedException.Create(SUnsupportedOperation);
  end;
{$ENDIF}

{$IFDEF ZEOS80UP}
  function TZRESTDWConnection.PrepareStatementWithParams(const SQL: string;
    Info: TStrings): IZPreparedStatement;
  begin
    if IsClosed then
      Open;
    Result := TZRESTDWPreparedStatement.Create(Self, SQL, Info);
  end;
{$ENDIF}

procedure TZRESTDWConnection.Rollback;
begin

end;

function TZRESTDWConnection.StartTransaction: Integer;
begin

end;

initialization
  RDWDriver := TZRESTDWDriver.Create;
  DriverManager.RegisterDriver(RDWDriver);

finalization
  if DriverManager <> nil then
    DriverManager.DeregisterDriver(RDWDriver);
  RDWDriver := nil;

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit

end.
