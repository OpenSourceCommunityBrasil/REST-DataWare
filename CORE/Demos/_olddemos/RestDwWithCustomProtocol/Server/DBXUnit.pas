unit DBXUnit;

interface

uses
  SysUtils, Classes, ServerDataModuleUnit,
  Forms, FMTBcd, SqlExpr, DB, Data.DBXFirebird;

type
  TDBX = class(TServerDataModule)
    DBConnection: TSQLConnection;
    Query: TSQLQuery;
    procedure FDConnectionBeforeConnect(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    TransactionDesc: TTransactionDesc;
    procedure Prepare(SQL: string; Params: TParams = nil);

  public
    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;
    function ExecuteQuery(SQL: string; Params: TParams = nil): TDataSet; override;
    procedure ExecuteCommand(SQL: string; Params: TParams = nil); override;
    procedure AfterConstruction; override;
  end;

var
  DBX: TDBX;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

procedure TDBX.AfterConstruction;
begin
  inherited;
  TransactionDesc.TransactionID := 1;
end;

procedure TDBX.CommitTransaction;
begin
  inherited;
  DBConnection.Commit(TransactionDesc);
end;

procedure TDBX.DataModuleCreate(Sender: TObject);
var
  sDataBase: string;
begin
  inherited;
//  sDataBase := ExtractFilePath(Application.ExeName) + 'EMPLOYEE.FDB';
//  DBConnection.Params.Values['DataBase'] := sDataBase;
end;

procedure TDBX.DataModuleDestroy(Sender: TObject);
begin
  Query.Close;
  DBConnection.Close;
  inherited;
end;

procedure TDBX.ExecuteCommand(SQL: string; Params: TParams);
begin
  Prepare(SQL, Params);
  Query.ExecSQL;
end;

function TDBX.ExecuteQuery(SQL: string; Params: TParams): TDataSet;
begin
  Prepare(SQL, Params);
  Query.Open;
  Result := Query;
end;

procedure TDBX.FDConnectionBeforeConnect(Sender: TObject);
begin
  inherited;
  if DataBaseParams.Text <> '' then begin
    if DataBaseIndex = 1 { FIREBIRD } then begin
      DBConnection.DriverName := 'FB';
    end;
    DBConnection.Params.Text := DataBaseParams.Text;
  end;
end;

procedure TDBX.Prepare(SQL: string; Params: TParams);
var
  I: Integer;
begin
  if not DBConnection.Connected then
    DBConnection.Connected := True;
  Query.Close;
  Query.SQL.Text := SQL;
  if Params <> nil then begin
    for I := 0 to Params.Count - 1 do begin
      Query.Params[I].Value := Params[I].Value;
    end;
  end;
end;

procedure TDBX.RollbackTransaction;
begin
  inherited;
  DBConnection.Rollback(TransactionDesc);
end;

procedure TDBX.StartTransaction;
begin
  inherited;
  DBConnection.StartTransaction(TransactionDesc);
end;

end.
