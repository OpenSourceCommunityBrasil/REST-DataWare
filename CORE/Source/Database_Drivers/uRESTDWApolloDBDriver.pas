unit uRESTDWApolloDBDriver;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes,
  apWin, ApConn, apoQSet, apCommon;

const
  crdwConnectionNotApolloDB = 'Componente não é um ApolloDBConnection';


type
  { TRESTDWApolloDBQuery }

  TRESTDWApolloDBQuery = class(TRESTDWQuery)
  public
    procedure ExecSQL; override;
    procedure Prepare; override;

    function RowsAffected : Int64; override;

    function createTransaction : TRESTDWTransaction; override;
  end;

  { TRESTDWApolloDBDriver }

  TRESTDWApolloDBDriver = class(TRESTDWDriverBase)
  private
    FDatabaseName : string;
    FPassword : string;
    FTableType : TApolloTableType;
  protected
    procedure setConnection(AValue: TComponent); override;
  public
    function getQuery : TRESTDWQuery; override;
    function getTable : TRESTDWTable; override;
    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  published
    property DatabaseName : String            read FDatabaseName Write FDatabaseName;
    property Password     : String            read FPassword     Write FPassword;
    property TableType    : TApolloTableType  read FTableType    Write FTableType;
  end;


implementation

 { TRESTDWApolloDBDriver }

procedure TRESTDWApolloDBDriver.setConnection(AValue : TComponent);
begin
  if (Assigned(AValue)) and (not AValue.InheritsFrom(TApolloConnection)) then
    raise Exception.Create(crdwConnectionNotApolloDB);
  inherited setConnection(AValue);
end;

function TRESTDWApolloDBDriver.getQuery : TRESTDWQuery;
var
  qry : TMyQuery;
begin
  qry := TMyQuery.Create(Self);
//  qry.Connection := TApolloConnection(Connection);
  qry.DatabaseName := FDatabaseName;
  qry.TableType    := FTableType;
  qry.Password     := FPassword;

  Result := TRESTDWApolloDBQuery.Create(qry);
end;

function TRESTDWApolloDBDriver.getTable : TRESTDWTable;
var
  qry : TApolloTable;
begin
  qry := TApolloTable.Create(Self);
//  qry.Connection := TApolloConnection(Connection);
  qry.DatabaseName := FDatabaseName;
  qry.TableType    := FTableType;
  qry.Password     := FPassword;

  Result := TRESTDWTable.Create(qry);
end;

procedure TRESTDWApolloDBDriver.Connect;
begin
  if Assigned(Connection) then
    TApolloConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWApolloDBDriver.Disconect;
begin
  if Assigned(Connection) then
    TMyConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWApolloDBDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TApolloConnection(Connection).Connected;
end;

class procedure TRESTDWApolloDBDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                     var AConnection : TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
end;

{ TRESTDWApolloDBQuery }

procedure TRESTDWApolloDBQuery.ExecSQL;
var
  qry : TApolloQuery;
begin
  inherited ExecSQL;
  qry := TApolloQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWApolloDBQuery.Prepare;
var
  qry : TApolloQuery;
begin
  inherited Prepare;
  qry := TApolloQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWApolloDBQuery.RowsAffected : Int64;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := -1; //qry.RowsAffected;
end;

function TRESTDWApolloDBQuery.createTransaction : TRESTDWTransaction;
begin
  Result := TRESTDWTransaction.Create(nil);
end;

end.

