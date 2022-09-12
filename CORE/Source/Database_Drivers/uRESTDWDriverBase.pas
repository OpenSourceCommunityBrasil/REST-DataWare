unit uRESTDWDriverBase;

interface

uses
  Classes,
  uRESTDWBasic;

type
  TRESTDWDriverBase = class(TRESTDWDriver)
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);
  Public
    Function ApplyUpdates(Massive, SQL: String; Params: TRESTDWParams;
      Var Error: Boolean; Var MessageError: String; Var RowsAffected: Integer)
      : TJSONValue;
    Function ApplyUpdatesTB(Massive: String; Params: TRESTDWParams;
      Var Error: Boolean; Var MessageError: String; Var RowsAffected: Integer)
      : TJSONValue;
    Function ApplyUpdates_MassiveCache(MassiveCache: String; Var Error: Boolean;
      Var MessageError: String): TJSONValue;
    Procedure Close;
    Function ConnectionSet: Boolean;
    Function ExecuteCommand(SQL: String; Var Error: Boolean;
      Var MessageError: String; Var BinaryBlob: TMemoryStream;
      Var RowsAffected: Integer; Execute: Boolean = False;
      BinaryEvent: Boolean = False; MetaData: Boolean = False;
      BinaryCompatibleMode: Boolean = False): String; Overload;
    Function ExecuteCommand(SQL: String; Params: TRESTDWParams;
      Var Error: Boolean; Var MessageError: String;
      Var BinaryBlob: TMemoryStream; Var RowsAffected: Integer;
      Execute: Boolean = False; BinaryEvent: Boolean = False;
      MetaData: Boolean = False; BinaryCompatibleMode: Boolean = False)
      : String; Overload;
    Function ExecuteCommandTB(Tablename: String; Var Error: Boolean;
      Var MessageError: String; Var BinaryBlob: TMemoryStream;
      Var RowsAffected: Integer; BinaryEvent: Boolean = False;
      MetaData: Boolean = False; BinaryCompatibleMode: Boolean = False)
      : String; Overload;
    Function ExecuteCommandTB(Tablename: String; Params: TRESTDWParams;
      Var Error: Boolean; Var MessageError: String;
      Var BinaryBlob: TMemoryStream; Var RowsAffected: Integer;
      BinaryEvent: Boolean = False; MetaData: Boolean = False;
      BinaryCompatibleMode: Boolean = False): String; Overload;
    Procedure ExecuteProcedure(ProcName: String; Params: TRESTDWParams;
      Var Error: Boolean; Var MessageError: String);
    Procedure ExecuteProcedurePure(ProcName: String; Var Error: Boolean;
      Var MessageError: String);
    Procedure GetFieldNames(Tablename: String; Var FieldNames: TStringList;
      Var Error: Boolean; Var MessageError: String);
    Function GetGenID(Query: TComponent; GenName: String): Integer;
    Procedure GetKeyFieldNames(Tablename: String; Var FieldNames: TStringList;
      Var Error: Boolean; Var MessageError: String);
    Procedure GetProcNames(Var ProcNames: TStringList; Var Error: Boolean;
      Var MessageError: String);
    Procedure GetProcParams(ProcName: String; Var ParamNames: TStringList;
      Var Error: Boolean; Var MessageError: String);
    Procedure GetTableNames(Var TableNames: TStringList; Var Error: Boolean;
      Var MessageError: String);
    Function InsertMySQLReturnID(SQL: String; Var Error: Boolean;
      Var MessageError: String): Integer; Overload;
    Function InsertMySQLReturnID(SQL: String; Params: TRESTDWParams;
      Var Error: Boolean; Var MessageError: String): Integer; Overload;
    Function OpenDatasets(DatasetsLine: String; Var Error: Boolean;
      Var MessageError: String; Var BinaryBlob: TMemoryStream): TJSONValue;
    Procedure PrepareConnection(Var ConnectionDefs: TConnectionDefs);
    Function ProcessMassiveSQLCache(MassiveSQLCache: String; Var Error: Boolean;
      Var MessageError: String): TJSONValue;
    Class Procedure CreateConnection(Const ConnectionDefs: TConnectionDefs;
      Var Connection: TObject);
  end;

implementation

{ TRESTDWDriverBase }

function TRESTDWDriverBase.ApplyUpdates(Massive, SQL: String;
  Params: TRESTDWParams; var Error: Boolean; var MessageError: String;
  var RowsAffected: Integer): TJSONValue;
begin

end;

function TRESTDWDriverBase.ApplyUpdatesTB(Massive: String;
  Params: TRESTDWParams; var Error: Boolean; var MessageError: String;
  var RowsAffected: Integer): TJSONValue;
begin

end;

function TRESTDWDriverBase.ApplyUpdates_MassiveCache(MassiveCache: String;
  var Error: Boolean; var MessageError: String): TJSONValue;
begin

end;

procedure TRESTDWDriverBase.Close;
begin

end;

function TRESTDWDriverBase.ConnectionSet: Boolean;
begin

end;

class procedure TRESTDWDriverBase.CreateConnection(const ConnectionDefs
  : TConnectionDefs; var Connection: TObject);
  Procedure ServerParamValue(ParamName, Value: String);
  Var
    I, vIndex: Integer;
    vFound: Boolean;
  Begin
    vFound := False;
    vIndex := -1;
    For I := 0 To Connection.Params.Count - 1 Do
    Begin
      If Lowercase(Connection.Params.Names[I]) = Lowercase(ParamName) Then
      Begin
        vFound := True;
        vIndex := I;
        Break;
      End;
    End;
    If Not(vFound) Then
      Connection.Params.Add(Format('%s=%s', [Lowercase(ParamName),
        Lowercase(Value)]))
    Else
      Connection.Params[vIndex] :=
        Format('%s=%s', [Lowercase(ParamName), Lowercase(Value)]);
  End;

begin
  inherited;
end;

function TRESTDWDriverBase.ExecuteCommand(SQL: String; Params: TRESTDWParams;
  var Error: Boolean; var MessageError: String; var BinaryBlob: TMemoryStream;
  var RowsAffected: Integer; Execute, BinaryEvent, MetaData,
  BinaryCompatibleMode: Boolean): String;
begin

end;

function TRESTDWDriverBase.ExecuteCommand(SQL: String; var Error: Boolean;
  var MessageError: String; var BinaryBlob: TMemoryStream;
  var RowsAffected: Integer; Execute, BinaryEvent, MetaData,
  BinaryCompatibleMode: Boolean): String;
begin

end;

function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
  var Error: Boolean; var MessageError: String; var BinaryBlob: TMemoryStream;
  var RowsAffected: Integer; BinaryEvent, MetaData, BinaryCompatibleMode
  : Boolean): String;
begin

end;

function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
  Params: TRESTDWParams; var Error: Boolean; var MessageError: String;
  var BinaryBlob: TMemoryStream; var RowsAffected: Integer;
  BinaryEvent, MetaData, BinaryCompatibleMode: Boolean): String;
begin

end;

procedure TRESTDWDriverBase.ExecuteProcedure(ProcName: String;
  Params: TRESTDWParams; var Error: Boolean; var MessageError: String);
begin

end;

procedure TRESTDWDriverBase.ExecuteProcedurePure(ProcName: String;
  var Error: Boolean; var MessageError: String);
begin

end;

procedure TRESTDWDriverBase.GetFieldNames(Tablename: String;
  var FieldNames: TStringList; var Error: Boolean; var MessageError: String);
begin

end;

function TRESTDWDriverBase.GetGenID(Query: TComponent; GenName: String)
  : Integer;
begin

end;

procedure TRESTDWDriverBase.GetKeyFieldNames(Tablename: String;
  var FieldNames: TStringList; var Error: Boolean; var MessageError: String);
begin

end;

procedure TRESTDWDriverBase.GetProcNames(var ProcNames: TStringList;
  var Error: Boolean; var MessageError: String);
begin

end;

procedure TRESTDWDriverBase.GetProcParams(ProcName: String;
  var ParamNames: TStringList; var Error: Boolean; var MessageError: String);
begin

end;

procedure TRESTDWDriverBase.GetTableNames(var TableNames: TStringList;
  var Error: Boolean; var MessageError: String);
begin

end;

function TRESTDWDriverBase.InsertMySQLReturnID(SQL: String; var Error: Boolean;
  var MessageError: String): Integer;
begin

end;

function TRESTDWDriverBase.InsertMySQLReturnID(SQL: String;
  Params: TRESTDWParams; var Error: Boolean; var MessageError: String): Integer;
begin

end;

procedure TRESTDWDriverBase.Notification(AComponent: TComponent;
  Operation: TOperation);
begin

end;

function TRESTDWDriverBase.OpenDatasets(DatasetsLine: String;
  var Error: Boolean; var MessageError: String; var BinaryBlob: TMemoryStream)
  : TJSONValue;
begin

end;

procedure TRESTDWDriverBase.PrepareConnection(var ConnectionDefs
  : TConnectionDefs);
begin

end;

function TRESTDWDriverBase.ProcessMassiveSQLCache(MassiveSQLCache: String;
  var Error: Boolean; var MessageError: String): TJSONValue;
begin

end;

end.
