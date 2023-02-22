unit uRESTDWZDbc;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit
uses
  {$IFNDEF FPC} ZURL, {$ENDIF}
  Classes, SysUtils,
  ZDbcIntfs, ZDbcLogging, ZTokenizer, ZPlainDriver, ZGenericSqlAnalyser,
  ZCompatibility, uRESTDWZPlainDriver, ZDbcConnection, uRESTDWBasicDB;

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

  {$IFDEF ZEOS80UP}
  { TZRESTDWConnection }
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

    procedure Commit;
    procedure Rollback;
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
    raise Exception.Create('Error Message');

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
