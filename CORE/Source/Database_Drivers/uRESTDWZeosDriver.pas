unit uRESTDWZeosDriver;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
    LResources,
  {$ENDIF}
  Classes, SysUtils, uRESTDWDriverBase, ZConnection, uRESTDWBasicTypes,
  ZDataset, ZSequence, ZDbcIntfs, ZAbstractRODataset, uRESTDWDataset,
  ZAbstractDataset, ZStoredProcedure;

const
  {$IFDEF FPC}
    rdwZeosProtocols : array of string = ('ado','asa','asa_capi','firebird',
                      'interbase','mssql','mysql','odbc_a','odbc_w','oledb',
                      'oracle','pooled','postgresql','sqlite','sybase',
                      'webserviceproxy');

    rdwZeosDbType : array of TRESTDWDatabaseType = (dbtAdo,dbtUndefined,
                   dbtUndefined,dbtFirebird,dbtInterbase,dbtMsSQL,dbtMySQL,
                   dbtODBC,dbtODBC,dbtUndefined,dbtOracle,dbtUndefined,
                   dbtPostgreSQL,dbtSQLLite,dbtUndefined,dbtUndefined);
  {$ELSE}
    rdwZeosProtocols : array of string = ['ado','asa','asa_capi','firebird',
                      'interbase','mssql','mysql','odbc_a','odbc_w','oledb',
                      'oracle','pooled','postgresql','sqlite','sybase',
                      'webserviceproxy'];

    rdwZeosDbType : array of TRESTDWDatabaseType = [dbtAdo,dbtUndefined,
                   dbtUndefined,dbtFirebird,dbtInterbase,dbtMsSQL,dbtMySQL,
                   dbtODBC,dbtODBC,dbtUndefined,dbtOracle,dbtUndefined,
                   dbtPostgreSQL,dbtSQLLite,dbtUndefined,dbtUndefined];
  {$ENDIF}

  crdwConnectionNotZeos = 'Componente não é um ZeosConnection';

type
  { TRESTDWZeosDataset }

  TRESTDWZeosDataset = class(TRESTDWDataset)
  public
    procedure SaveToStream(stream : TStream); override;
  end;

  { TRESTDWZeosStoreProc }

  TRESTDWZeosStoreProc = class(TRESTDWStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWZeosQuery }

  TRESTDWZeosQuery = class(TRESTDWQuery)
  private
    FSequence : TZSequence;
  protected
    procedure createSequencedField(seqname, field : string); override;
  public
    procedure ExecSQL; override;
    procedure Prepare; override;

    destructor Destroy; override;

    function RowsAffected : Int64; override;
  end;

  { TRESTDWZeosDriver }

  TRESTDWZeosDriver = class(TRESTDWDriverBase)
  private
    FTransaction : TZTransaction;
  protected
    procedure setConnection(AValue: TComponent); override;

    function getConectionType : TRESTDWDatabaseType; override;
  public
    constructor Create(AOwner : TComponent);
    destructor Destroy; override;

    function getQuery : TRESTDWQuery; override;
    function getTable : TRESTDWTable; override;
    function getStoreProc : TRESTDWStoreProc; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;
    function connInTransaction : boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  published

  end;

procedure Register;

implementation

{$IFNDEF FPC}
 {$if CompilerVersion < 23}
  {$R .\RESTDWZeosDriver.dcr}
 {$IFEND}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWZeosDriver]);
end;

{ TRESTDWZeosStoreProc }

procedure TRESTDWZeosStoreProc.ExecProc;
var
  qry : TZStoredProc;
begin
  inherited ExecProc;
  qry := TZStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWZeosStoreProc.Prepare;
var
  qry : TZStoredProc;
begin
  inherited Prepare;
  qry := TZStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWZeosDataset }

procedure TRESTDWZeosDataset.SaveToStream(stream: TStream);
var
  vDWMemtable : TRESTDWMemtable;
  qry : TZAbstractRWTxnUpdateObjDataSet;
begin
  inherited SaveToStream(stream);
  qry := TZAbstractRWTxnUpdateObjDataSet(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(Nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(vDWMemtable);
  End;
end;

{ TRESTDWZeosDriver }

procedure TRESTDWZeosDriver.setConnection(AValue: TComponent);
begin
  if (Assigned(AValue)) and (not AValue.InheritsFrom(TZConnection)) then
    raise Exception.Create(crdwConnectionNotZeos);

  if FTransaction <> nil then
    FTransaction.Connection := TZConnection(AValue);
  inherited setConnection(AValue);
end;

function TRESTDWZeosDriver.getConectionType: TRESTDWDatabaseType;
var
  prot : string;
  i : integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  prot := LowerCase(TZConnection(Connection).Protocol);

  i := 0;
  while i < Length(rdwZeosProtocols) do begin
    if Pos(rdwZeosProtocols[i],prot) > 0 then begin
      Result := rdwZeosDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

constructor TRESTDWZeosDriver.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TZTransaction.Create(Self);
  FTransaction.Connection := TZConnection(Connection);
end;

destructor TRESTDWZeosDriver.Destroy;
begin
  FTransaction.Free;
  inherited Destroy;
end;

function TRESTDWZeosDriver.getQuery: TRESTDWQuery;
var
  qry : TZQuery;
begin
  qry := TZQuery.Create(Self);
  qry.Connection := TZConnection(Connection);
  qry.Transaction := FTransaction;

  Result := TRESTDWZeosQuery.Create(qry);
end;

function TRESTDWZeosDriver.getTable : TRESTDWTable;
var
  qry : TZTable;
begin
  qry := TZTable.Create(Self);
  qry.Connection := TZConnection(Connection);
  qry.Transaction := FTransaction;

  Result := TRESTDWTable.Create(qry);
end;

function TRESTDWZeosDriver.getStoreProc : TRESTDWStoreProc;
var
  qry : TZStoredProc;
begin
  qry := TZStoredProc.Create(Self);
  qry.Connection := TZConnection(Connection);

  Result := TRESTDWZeosStoreProc.Create(qry);
end;

procedure TRESTDWZeosDriver.Connect;
begin
  if Assigned(Connection) then
    TZConnection(Connection).Connect;
  inherited Connect;
end;

procedure TRESTDWZeosDriver.Disconect;
begin
  if Assigned(Connection) then
    TZConnection(Connection).Disconnect;
  inherited Disconect;
end;

function TRESTDWZeosDriver.isConnected: boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TZConnection(Connection).Connected;
end;

function TRESTDWZeosDriver.connInTransaction: boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TZConnection(Connection).InTransaction;
end;

procedure TRESTDWZeosDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) then
    TZConnection(Connection).StartTransaction;
end;

procedure TRESTDWZeosDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    TZConnection(Connection).Rollback;
end;

procedure TRESTDWZeosDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    TZConnection(Connection).Commit;
end;

class procedure TRESTDWZeosDriver.CreateConnection(
  const AConnectionDefs: TConnectionDefs; var AConnection: TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    case AConnectionDefs.DriverType Of
      dbtUndefined  : TZConnection(AConnection).Protocol := '';
      dbtAccess     : TZConnection(AConnection).Protocol := '';
      dbtDbase      : TZConnection(AConnection).Protocol := '';
      dbtParadox    : TZConnection(AConnection).Protocol := '';
      dbtFirebird   : TZConnection(AConnection).Protocol := 'firebird';
      dbtInterbase  : TZConnection(AConnection).Protocol := 'interbase';
      dbtMySQL      : TZConnection(AConnection).Protocol := 'mysql';
      dbtSQLLite    : TZConnection(AConnection).Protocol := 'sqlite';
      dbtOracle     : TZConnection(AConnection).Protocol := 'oracle';
      dbtMsSQL      : TZConnection(AConnection).Protocol := 'mssql';
      dbtODBC       : TZConnection(AConnection).Protocol := 'odbc_a';
      dbtPostgreSQL : TZConnection(AConnection).Protocol := 'postgresql';
      dbtAdo        : TZConnection(AConnection).Protocol := 'ado';
    end;
  end;

  with TZConnection(AConnection) do begin
    HostName := AConnectionDefs.HostName;
    Database := AConnectionDefs.DatabaseName;
    User     := AConnectionDefs.Username;
    Password := AConnectionDefs.Password;
    Port     := AConnectionDefs.DBPort;
  end;
end;

{ TRESTDWZeosQuery }

procedure TRESTDWZeosQuery.createSequencedField(seqname, field : string);
var
  qry : TZQuery;
begin
  if Trim(seqname) = '' then
    Exit;

  if FSequence = nil then
    FSequence := TZSequence.Create(Self);

  qry := TZQuery(Self.Owner);

  FSequence.SequenceName := seqname;

  qry.Sequence := FSequence;
  qry.SequenceField := field;
end;

procedure TRESTDWZeosQuery.ExecSQL;
var
  qry : TZQuery;
begin
  inherited ExecSQL;
  qry := TZQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWZeosQuery.Prepare;
var
  qry : TZQuery;
begin
  inherited Prepare;
  qry := TZQuery(Self.Owner);
  qry.Prepare;
end;

destructor TRESTDWZeosQuery.Destroy;
begin
  if FSequence <> nil then
    FSequence.Free;
  inherited Destroy;
end;

function TRESTDWZeosQuery.RowsAffected: Int64;
var
  qry : TZQuery;
begin
  inherited Prepare;
  qry := TZQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

{$IFDEF FPC}
initialization
  {$I ../../Packages/Lazarus/Drivers/zeos/restdwzeosdriver.lrs}
{$ENDIF}

end.

