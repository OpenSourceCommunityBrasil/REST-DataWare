unit uRESTDWMyDACDriver;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
    LResources,
  {$ENDIF}
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes, MyClasses, MyAccess,
  MyScript, DADump, MyDump, VirtualTable, MemDS, DBAccess, DB, uRESTDWMemtable;

const
  crdwConnectionNotIsMyDAC = 'Componente não é um MyConnection';

type
  { TRESTDWMyDACDataset }

  TRESTDWMyDACDataset = class(TRESTDWDataset)
  public
    procedure SaveToStream(stream : TStream); override;
  end;

  { TRESTDWMyDACStoreProc }

  TRESTDWMyDACStoreProc = class(TRESTDWStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWMyDACQuery }

  TRESTDWMyDACQuery = class(TRESTDWQuery)
  protected
    procedure createSequencedField(seqname,field : string); override;
  public
    procedure ExecSQL; override;
    procedure Prepare; override;

    function RowsAffected : Int64; override;
  end;

  { TRESTDWMyDACDriver }

  TRESTDWMyDACDriver = class(TRESTDWDriverBase)
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

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  published

  end;

procedure Register;

implementation

{$IFNDEF FPC}
 {$if CompilerVersion < 23}
  {$R .\RESTDWMyDACDriver.dcr}
 {$IFEND}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWMyDACDriver]);
end;

{ TRESTDWMyDACStoreProc }

procedure TRESTDWMyDACStoreProc.ExecProc;
var
  qry : TMyStoredProc;
begin
  inherited ExecProc;
  qry := TMyStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWMyDACStoreProc.Prepare;
var
  qry : TMyStoredProc;
begin
  inherited Prepare;
  qry := TMyStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWMyDACDataset }

procedure TRESTDWMyDACDataset.SaveToStream(stream : TStream);
var
  vDWMemtable : TRESTDWMemtable;
  qry : TCustomMyDataSet;
begin
  inherited SaveToStream(stream);
  qry := TCustomMyDataSet(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(Nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(vDWMemtable);
  end;
end;

 { TRESTDWMyDACDriver }

procedure TRESTDWMyDACDriver.setConnection(AValue : TComponent);
begin
  if (Assigned(AValue)) and (not AValue.InheritsFrom(TMyConnection)) then
    raise Exception.Create(crdwConnectionNotIsMyDAC);
  inherited setConnection(AValue);
end;

function TRESTDWMyDACDriver.getConectionType : TRESTDWDatabaseType;
begin
  Result := inherited getConectionType;
end;

function TRESTDWMyDACDriver.getQuery : TRESTDWQuery;
var
  qry : TMyQuery;
begin
  qry := TMyQuery.Create(Self);
  qry.Connection := TMyConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;

  Result := TRESTDWMyDACQuery.Create(qry);
end;

function TRESTDWMyDACDriver.getTable : TRESTDWTable;
var
  qry : TMyTable;
begin
  qry := TMyTable.Create(Self);
  qry.Connection := TMyConnection(Connection);

  Result := TRESTDWTable.Create(qry);
end;

function TRESTDWMyDACDriver.getStoreProc : TRESTDWStoreProc;
var
  qry : TMyStoredProc;
begin
  qry := TMyStoredProc.Create(Self);
  qry.Connection := TMyConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;

  Result := TRESTDWMyDACStoreProc.Create(qry);
end;

procedure TRESTDWMyDACDriver.Connect;
begin
  if Assigned(Connection) then
    TMyConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWMyDACDriver.Disconect;
begin
  if Assigned(Connection) then
    TMyConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWMyDACDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TMyConnection(Connection).Connected;
end;

function TRESTDWMyDACDriver.connInTransaction : boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TMyConnection(Connection).InTransaction;
end;

procedure TRESTDWMyDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) then
    TMyConnection(Connection).StartTransaction;
end;

procedure TRESTDWMyDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    TMyConnection(Connection).Rollback;
end;

procedure TRESTDWMyDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    TMyConnection(Connection).Commit;
end;

class procedure TRESTDWMyDACDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                     var AConnection : TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
end;

{ TRESTDWMyDACQuery }

procedure TRESTDWMyDACQuery.createSequencedField(seqname, field : string);
var
  qry : TMyQuery;
  fd : TField;
begin
  qry := TMyQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWMyDACQuery.ExecSQL;
var
  qry : TMyQuery;
begin
  inherited ExecSQL;
  qry := TMyQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWMyDACQuery.Prepare;
var
  qry : TMyQuery;
begin
  inherited Prepare;
  qry := TMyQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWMyDACQuery.RowsAffected : Int64;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

{$IFDEF FPC}
initialization
  {$I ../../Packages/Lazarus/Drivers/MyDAC/restdwMyDACdriver.lrs}
{$ENDIF}

end.

