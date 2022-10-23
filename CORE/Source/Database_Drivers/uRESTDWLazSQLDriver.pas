unit uRESTDWLazSQLDriver;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
    LResources,
  {$ENDIF}
  Classes, SysUtils, uRESTDWDriverBase, SQLDB, uRESTDWBasicTypes;

const
  rdwLazSQLConnector : array of string = ('mssql','sybase','postgresql','pqconn',
                      'oracle','odbc','mysql','sqlite','firebird','ibconn');

  rdwLazSQLDbType : array of TRESTDWDatabaseType = (dbtMsSQL,dbtUndefined,
                    dbtPostgreSQL,dbtPostgreSQL,dbtOracle,dbtODBC,dbtMySQL,
                    dbtSQLLite,dbtFirebird,dbtFirebird);

  crdwConnectionNotIsLazSQL = 'Componente não é um SQLConnection';

type

  { TRESTDWLazSQLDataset }

  TRESTDWLazSQLDataset = class(TRESTDWDataset)
  public
    procedure SaveToStream(stream : TStream); override;
  end;

  { TRESTDWLazSQLQuery }

  TRESTDWLazSQLQuery = class(TRESTDWQuery)
  private
    FSequence : TSQLSequence;
  protected
    procedure createSequencedField(seqname,field : string); override;
  public
    procedure ExecSQL; override;
    procedure Prepare; override;

    destructor Destroy; override;

    function RowsAffected : Int64; override;
  end;

  { TRESTDWLazSQLDriver }

  TRESTDWLazSQLDriver = class(TRESTDWDriverBase)
  private
    FTransaction : TSQLTransaction;
  protected
    procedure setConnection(AValue: TComponent); override;

    function getConectionType : TRESTDWDatabaseType; override;
  public
    constructor Create(AOwner : TComponent);
    destructor Destroy; override;

    function getQuery : TRESTDWQuery; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;

    function connInTransaction : boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;

    class procedure CreateConnection(const AConnectionDefs  : TConnectionDefs;
                                     var AConnection        : TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWLazSQLDriver]);
end;

{ TRESTDWLazSQLDataset }

procedure TRESTDWLazSQLDataset.SaveToStream(stream: TStream);
var
  qry : TSQLQuery;
begin
  inherited SaveToStream(stream);
  qry := TSQLQuery(Self.Owner);
  qry.SaveToStream(stream);

  stream.Position := 0;
end;

{ TRESTDWLazSQLQuery }

procedure TRESTDWLazSQLQuery.createSequencedField(seqname, field : string);
var
  qry : TSQLQuery;
begin
  if Trim(seqname) = '' then
    Exit;

  qry := TSQLQuery(Self.Owner);
  if FSequence = nil then
    FSequence := TSQLSequence.Create(qry);

  FSequence.SequenceName := seqname;
  FSequence.FieldName := field;

  qry.Sequence := FSequence;
end;

procedure TRESTDWLazSQLQuery.ExecSQL;
var
  qry : TSQLQuery;
begin
  inherited ExecSQL;
  qry := TSQLQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWLazSQLQuery.Prepare;
var
  qry : TSQLQuery;
begin
  inherited Prepare;
  qry := TSQLQuery(Self.Owner);
  qry.Prepare;
end;

destructor TRESTDWLazSQLQuery.Destroy;
begin
  if FSequence <> nil then
    FSequence.Free;
  inherited Destroy;
end;

function TRESTDWLazSQLQuery.RowsAffected: Int64;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

{ TRESTDWLazSQLDriver }

procedure TRESTDWLazSQLDriver.setConnection(AValue: TComponent);
begin
  if (Assigned(AValue)) and (not AValue.InheritsFrom(TSQLConnection)) then
    raise Exception.Create(crdwConnectionNotIsLazSQL);

  if FTransaction <> nil then
    FTransaction.SQLConnection := TSQLConnection(AValue);
  inherited setConnection(AValue);
end;

function TRESTDWLazSQLDriver.getConectionType: TRESTDWDatabaseType;
var
  conn : string;
  i: integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  if Connection is TSQLConnector then
    conn := LowerCase(TSQLConnector(Connection).ConnectorType)
  else
    conn := LowerCase(Connection.ClassName);

  i := 0;
  while i < Length(rdwLazSQLConnector) do begin
    if Pos(rdwLazSQLConnector[i],conn) > 0 then begin
      Result := rdwLazSQLDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

function TRESTDWLazSQLDriver.getQuery : TRESTDWQuery;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery.Create(Self);
  qry.SQLConnection := TSQLConnection(Connection);
  qry.Transaction := FTransaction;

  Result := TRESTDWLazSQLQuery.Create(qry);
end;

procedure TRESTDWLazSQLDriver.Connect;
begin
  if Assigned(Connection) then
    TSQLConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWLazSQLDriver.Disconect;
begin
  if Assigned(Connection) then
    TSQLConnection(Connection).Close;
  inherited Disconect;
end;

 constructor TRESTDWLazSQLDriver.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TSQLTransaction.Create(Self);
  FTransaction.SQLConnection := TSQLConnection(Connection);
end;

destructor TRESTDWLazSQLDriver.Destroy;
begin
  FTransaction.Free;
  inherited Destroy;
end;

function TRESTDWLazSQLDriver.isConnected: boolean;
begin
  Result := inherited isConnected;
  if Assigned(Connection) then
    Result := TSQLConnection(Connection).Connected;
end;

function TRESTDWLazSQLDriver.connInTransaction: boolean;
begin
  Result := FTransaction.Active;
end;

procedure TRESTDWLazSQLDriver.connStartTransaction;
begin
  FTransaction.StartTransaction;
end;

procedure TRESTDWLazSQLDriver.connRollback;
begin
  FTransaction.Rollback;
end;

procedure TRESTDWLazSQLDriver.connCommit;
begin
  FTransaction.Commit;
end;

class procedure TRESTDWLazSQLDriver.CreateConnection(const AConnectionDefs: TConnectionDefs;
                                                     var AConnection: TComponent);
  procedure ServerParamValue(ParamName, Value : String);
  var
    I, vIndex : Integer;
  begin
   for I := 0 To TSQLConnection(AConnection).Params.Count-1 do begin
     if SameText(TSQLConnection(AConnection).Params.Names[I],ParamName) then begin
       vIndex := I;
       Break;
     end;
   end;
   if vIndex = -1 Then
     TSQLConnection(AConnection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Value]))
   else
     TSQLConnection(AConnection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Value]);
  end;
Begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    case AConnectionDefs.DriverType Of
      dbtUndefined  : begin

      end;
      dbtAccess     : begin

      end;
      dbtDbase      : begin

      end;
      dbtFirebird   : begin
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtInterbase  : begin
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtMySQL      : begin
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtSQLLite    : begin
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
      end;
      dbtOracle     : begin

      end;
      dbtMsSQL      : begin
        ServerParamValue('DriverID',  AConnectionDefs.DriverID);
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtODBC       : begin
        ServerParamValue('DataSource', AConnectionDefs.DataSource);
      end;
      dbtParadox    : begin

      end;
      dbtPostgreSQL : begin

      end;
    end;
  end;
end;

{$IFDEF FPC}
initialization
  {$I ../../Packages/Lazarus/Drivers/lazdriver/restdwlazsqldriver.lrs}
{$ENDIF}

end.

