unit uRESTDWFireDACDriver;

interface

uses
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.StorageBin,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, DB;

const
  rdwFireDACDrivers : array of string = ['ads','asa','db2','ds','fb','ib',
                      'iblite','infx','mongo','msacc','mssql','mysql','odbc',
                      'ora','pg','sqlite','tdata','tdbx'];

  rdwFireDACDbType : array of TRESTDWDatabaseType = [dbtUndefined,dbtUndefined,
                     dbtDbase,dbtUndefined,dbtFirebird,dbtInterbase,dbtInterbase,
                     dbtUndefined,dbtUndefined,dbtUndefined,dbtMsSQL,dbtMySQL,
                     dbtODBC,dbtOracle,dbtPostgreSQL,dbtSQLLite,dbtUndefined,
                     dbtUndefined];

  crdwConnectionNotFireDAC = 'Componente não é um FireDACConnection';

type
  { TRESTDWFireDACDataset }

  TRESTDWFireDACDataset = class(TRESTDWDataset)
  public
    procedure SaveToStream(stream : TStream); override;
  end;

  { TRESTDWFireDACStoreProc }

  TRESTDWFireDACStoreProc = class(TRESTDWStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWFireDACQuery }

  TRESTDWFireDACQuery = class(TRESTDWQuery)
  protected
    procedure createSequencedField(seqname,field : string); override;
  public
    procedure ExecSQL; override;
    procedure Prepare; override;

    function RowsAffected : Int64; override;
  end;

  { TRESTDWFireDACDriver }

  TRESTDWFireDACDriver = class(TRESTDWDriverBase)
  private
    function isAutoCommit : boolean;
  protected
    procedure setConnection(AValue: TComponent); override;
    function getConectionType : TRESTDWDatabaseType; override;
  public
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

    class procedure CreateConnection(const AConnectionDefs  : TConnectionDefs;
                                     var AConnection        : TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWFireDACDriver]);
end;

{ TRESTDWFireDACStoreProc }

procedure TRESTDWFireDACStoreProc.ExecProc;
var
  qry : TFDStoredProc;
begin
  inherited ExecProc;
  qry := TFDStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWFireDACStoreProc.Prepare;
var
  qry : TFDStoredProc;
begin
  inherited Prepare;
  qry := TFDStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWFireDACDataset }

procedure TRESTDWFireDACDataset.SaveToStream(stream : TStream);
var
  qry : TFDDataset;
begin
  inherited SaveToStream(stream);
  qry := TFDDataset(Self.Owner);
  qry.SaveToStream(stream, sfBinary);

  stream.Position := 0;
end;

{ TRESTDWFireDACDriver }

function TRESTDWFireDACDriver.isAutoCommit: boolean;
begin
  Result := False;
  {$IF CompilerVersion >= 30}
    if Assigned(Connection) then
      Result := TFDConnection(Connection).UpdateOptions.AutoCommitUpdates;
  {$IFEND}
end;

procedure TRESTDWFireDACDriver.setConnection(AValue: TComponent);
begin
  if (Assigned(AValue)) and (not AValue.InheritsFrom(TFDConnection)) then
    raise Exception.Create(crdwConnectionNotFireDAC);
  inherited setConnection(AValue);
end;

function TRESTDWFireDACDriver.getConectionType: TRESTDWDatabaseType;
var
  conn : string;
  i: integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  conn := LowerCase(TFDConnection(Connection).DriverName);

  i := 0;
  while i < Length(rdwFireDACDrivers) do begin
    if Pos(rdwFireDACDrivers[i],conn) > 0 then begin
      Result := rdwFireDACDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

function TRESTDWFireDACDriver.getQuery: TRESTDWQuery;
var
  qry : TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  qry.Connection := TFDConnection(Connection);
  qry.FormatOptions.StrsTrim       := StrsTrim;
  qry.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  qry.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  qry.ResourceOptions.ParamCreate  := True;
  qry.ResourceOptions.StoreItems   := [siMeta,siData,siDelta];
  qry.FetchOptions.Mode            := fmAll;

  Result := TRESTDWFireDACQuery.Create(qry);
end;

function TRESTDWFireDACDriver.getTable : TRESTDWTable;
var
  qry : TFDTable;
begin
  qry := TFDTable.Create(Self);
  qry.FetchOptions.RowsetSize := -1;
  qry.Connection := TFDConnection(Connection);
  qry.CachedUpdates := False;

  Result := TRESTDWTable.Create(qry);
end;

function TRESTDWFireDACDriver.getStoreProc : TRESTDWStoreProc;
var
  qry : TFDStoredProc;
begin
  qry := TFDStoredProc.Create(Self);
  qry.Connection := TFDConnection(Connection);
  qry.FormatOptions.StrsTrim       := StrsTrim;
  qry.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  qry.FormatOptions.StrsTrim2Len   := StrsTrim2Len;

  Result := TRESTDWFireDACStoreProc.Create(qry);
end;

procedure TRESTDWFireDACDriver.Connect;
begin
  if Assigned(Connection) then
    TFDConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWFireDACDriver.Disconect;
begin
  if Assigned(Connection) then
    TFDConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWFireDACDriver.isConnected: boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TFDConnection(Connection).Connected;
end;

function TRESTDWFireDACDriver.connInTransaction: boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TFDConnection(Connection).InTransaction;
end;

procedure TRESTDWFireDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) and (not isAutoCommit) then
    TFDConnection(Connection).StartTransaction;
end;

procedure TRESTDWFireDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) and (not isAutoCommit) then
    TFDConnection(Connection).Rollback;
end;

procedure TRESTDWFireDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) and (not isAutoCommit) then
    TFDConnection(Connection).Commit;
end;

class procedure TRESTDWFireDACDriver.CreateConnection(
   const AConnectionDefs : TConnectionDefs; var AConnection : TComponent);

  procedure ServerParamValue(ParamName, Value : String);
  var
    I, vIndex : Integer;
  begin
   vIndex := -1;
   for I := 0 To TFDConnection(AConnection).Params.Count-1 do begin
     if SameText(TFDConnection(AConnection).Params.Names[I],ParamName) then begin
       vIndex := I;
       Break;
     end;
   end;
   if vIndex = -1 Then
     TFDConnection(AConnection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Value]))
   else
     TFDConnection(AConnection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Value]);
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
        ServerParamValue('DriverID',  'FB');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtInterbase  : begin
        ServerParamValue('DriverID',  'IB');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtMySQL      : begin
        ServerParamValue('DriverID',  'MySQL');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtSQLLite    : begin
        ServerParamValue('DriverID',  'SQLite');
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtOracle     : begin

      end;
      dbtMsSQL      : begin
        ServerParamValue('DriverID',  'MsSQL');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtODBC       : begin
        ServerParamValue('DriverID',  'ODBC');
        ServerParamValue('DataSource', AConnectionDefs.DataSource);
      end;
      dbtParadox    : begin

      end;
      dbtPostgreSQL : begin
        ServerParamValue('DriverID',  'PQ');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
    end;
  end;
end;

{ TRESTDWFireDACQuery }

procedure TRESTDWFireDACQuery.createSequencedField(seqname, field : string);
var
  qry : TFDQuery;
  fd : TField;
begin
  qry := TFDQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWFireDACQuery.ExecSQL;
var
  qry : TFDQuery;
begin
  inherited ExecSQL;
  qry := TFDQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWFireDACQuery.Prepare;
var
  qry : TFDQuery;
begin
  inherited Prepare;
  qry := TFDQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWFireDACQuery.RowsAffected: Int64;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

end.

