unit uRESTDWDriverBase;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, TypInfo, uRESTDWComponentBase, DB, uRESTDWParams,
  uRESTDWEncodeClass, uRESTDWCharset, uRESTDWComponentEvents,
  uRESTDWMassiveBuffer, uRESTDWJSONInterface, uRESTDWConsts,
  uRESTDWDataModule, uRESTDWBasicTypes, uRESTDWTools,
  uRESTDWBufferBase, Variants;

type
  TRESTDWDatabaseInfo = record
    rdwDatabaseName : string;
    rdwDatabaseMajorVersion : integer;
    rdwDatabaseMinorVersion : integer;
    rdwDatabaseSubVersion   : integer;
  end;

  TRESTDWQuery = class;

  { TRESTDWDataset }

  TRESTDWDataset = class(TComponent)
  protected
    function getFields: TFields; virtual;
    function getParams: TParams; virtual;
    procedure createSequencedField(seqname, field : string); virtual;
  public
    procedure Close; virtual;
    procedure Open; virtual;
    procedure Insert; virtual;
    procedure Edit; virtual;
    procedure Post; virtual;
    procedure Delete; virtual;
    procedure Next; virtual;

    procedure Prepare; virtual;
    procedure ExecSQL; virtual;
    procedure FetchAll; virtual;
    procedure SaveToStream(stream : TStream); virtual;

    function Eof : boolean; virtual;

    function RecNo : int64; virtual;
    function RecordCount : int64; virtual;
    function ParamCount: integer; virtual;
    function ParamByName(param : string) : TParam; virtual;
    function FieldByName(field : string) : TField; virtual;
    function FindField(field : string) : TField; virtual;

    function RDWDataTypeFieldName(field : string) : Byte; virtual;
    function RDWDataTypeParamName(param : string) : Byte; virtual;
    function GetParamIndex(param : string) : integer; virtual;
  published
    property Params : TParams read getParams;
    property Fields : TFields read getFields;
  end;

  { TRESTDWStoreProc }

  TRESTDWStoreProc = class(TRESTDWDataset)
  protected
    function getStoredProcName : string;
    procedure setStoredProcName(AValue : string);
  public
    procedure ExecProc; virtual;
  published
    property StoredProcName : string read getStoredProcName write setStoredProcName;
  end;

  { TRESTDWTable }

  TRESTDWTable = class(TRESTDWDataset)
  private
    function getFilter: string; virtual;
    function getFiltered: boolean; virtual;
    function getTableName: string; virtual;
    procedure setFilter(AValue: string); virtual;
    procedure setFiltered(AValue: boolean); virtual;
    procedure setTableName(AValue: string); virtual;
  public

  published
    property Filter : string read getFilter write setFilter;
    property Filtered : boolean read getFiltered write setFiltered;
    property TableName : string read getTableName write setTableName;
  end;

  { TRESTDWQuery }

  TRESTDWQuery = class(TRESTDWDataset)
  private
    function getSQL: TStrings; virtual;
  public
    function RowsAffected : Int64; virtual;
    function GetInsertID : int64; virtual;
  published
    property SQL : TStrings read getSQL;
  end;

  { TRESTDWDriverBase }

  TRESTDWDriverBase = class(TRESTDWComponent)
  private
    FConnection : TComponent;

    vStrsTrim,
    vStrsEmpty2Null,
    vStrsTrim2Len,
    vEncodeStrings,
    vCompression         : Boolean;
    vEncoding            : TEncodeSelect;
    vCommitRecords       : Integer;
    {$IFDEF FPC}
    vDatabaseCharSet     : TDatabaseCharSet;
    {$ENDIF}
    vParamCreate         : Boolean;
    vOnPrepareConnection : TOnPrepareConnection;
    vOnTableBeforeOpen   : TOnTableBeforeOpen;
    vOnQueryBeforeOpen   : TOnQueryBeforeOpen;
    vOnQueryException    : TOnQueryException;
  protected
    procedure setConnection(AValue: TComponent); virtual;

    function isConnected : boolean; virtual;

    function connInTransaction : boolean; virtual;
    procedure connStartTransaction; virtual;
    procedure connRollback; virtual;
    procedure connCommit; virtual;

    function isMinimumVersion(major,minor,sub : integer) : boolean; overload;
    function isMinimumVersion(major,minor : integer) : boolean; overload;
  public
    function getConectionType : TRESTDWDatabaseType; virtual;
    function getDatabaseInfo : TRESTDWDatabaseInfo; virtual;
    function getQuery : TRESTDWQuery; virtual;
    function getTable : TRESTDWTable; virtual;
    function getStoreProc : TRESTDWStoreProc; virtual;

    procedure Connect; virtual;
    procedure Disconect; virtual;

    function ConnectionSet : Boolean; virtual;

    function GetGenID(Query : TRESTDWQuery; GenName : string; valor : integer = 1): integer; overload;virtual;
    function GetGenID(GenName : string; valor : integer = 1): integer; overload; virtual;

    function ApplyUpdates(MassiveStream    : TStream;
                          SQL              : string;
                          Params           : TRESTDWParams;
                          var Error        : boolean;
                          var MessageError : string;
                          var RowsAffected : integer) : TJSONValue; overload;virtual;
    function ApplyUpdates(Massive,
                          SQL              : string;
                          Params           : TRESTDWParams;
                          var Error        : Boolean;
                          var MessageError : string;
                          var RowsAffected : Integer) : TJSONValue; overload;virtual;

    function ApplyUpdatesTB(MassiveStream         : TStream;
                            SQL                   : String;
                            Params                : TRESTDWParams;
                            var Error             : Boolean;
                            var MessageError      : String;
                            var RowsAffected      : Integer) : TJSONValue; overload;virtual;
    Function ApplyUpdatesTB(Massive               : String;
                            Params                : TRESTDWParams;
                            var Error             : Boolean;
                            var MessageError      : String;
                            var RowsAffected      : Integer) : TJSONValue; overload;virtual;

    function ApplyUpdates_MassiveCache(MassiveCache     : string;
                                       var Error        : boolean;
                                       var MessageError : string) : TJSONValue; virtual;
    Function ApplyUpdates_MassiveCacheTB(MassiveCache          : String;
                                         Var Error             : Boolean;
                                         Var MessageError      : String) : TJSONValue; virtual;
    function ExecuteCommand(SQL                  : String;
                            var Error            : Boolean;
                            var MessageError     : String;
                            var BinaryBlob       : TMemoryStream;
                            var RowsAffected     : Integer;
                            Execute              : Boolean = False;
                            BinaryEvent          : Boolean = False;
                            MetaData             : Boolean = False;
                            BinaryCompatibleMode : Boolean = False) : string;overload;virtual;
    function ExecuteCommand(SQL                  : String;
                            Params               : TRESTDWParams;
                            var Error            : Boolean;
                            var MessageError     : String;
                            var BinaryBlob       : TMemoryStream;
                            var RowsAffected     : Integer;
                            Execute              : Boolean = False;
                            BinaryEvent          : Boolean = False;
                            MetaData             : Boolean = False;
                            BinaryCompatibleMode : Boolean = False) : string;overload;virtual;
    function ExecuteCommandTB(Tablename             : String;
                              var Error             : Boolean;
                              var MessageError      : String;
                              var BinaryBlob        : TMemoryStream;
                              var RowsAffected      : Integer;
                              BinaryEvent           : Boolean = False;
                              MetaData              : Boolean = False;
                              BinaryCompatibleMode  : Boolean = False) : String; overload;virtual;
    function ExecuteCommandTB(Tablename             : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var BinaryBlob        : TMemoryStream;
                              Var RowsAffected      : Integer;
                              BinaryEvent           : Boolean = False;
                              MetaData              : Boolean = False;
                              BinaryCompatibleMode  : Boolean = False) : String; overload;virtual;
    procedure ExecuteProcedure(ProcName              : String;
                               Params                : TRESTDWParams;
                               var Error             : Boolean;
                               var MessageError      : String); virtual;
    procedure ExecuteProcedurePure(ProcName              : String;
                                   var Error             : Boolean;
                                   var MessageError      : String); virtual;

    procedure GetTableNames(var TableNames        : TStringList;
                            var Error             : Boolean;
                            var MessageError      : String); virtual;
    procedure GetFieldNames(TableName             : String;
                            var FieldNames        : TStringList;
                            var Error             : Boolean;
                            var MessageError      : String); virtual;
    procedure GetKeyFieldNames(TableName             : String;
                               var FieldNames        : TStringList;
                               var Error             : Boolean;
                               var MessageError      : String); virtual;
    procedure GetProcNames(var ProcNames         : TStringList;
                           var Error             : Boolean;
                           var MessageError      : String); virtual;
    procedure GetProcParams(ProcName              : String;
                            var ParamNames        : TStringList;
                            var Error             : Boolean;
                            var MessageError      : String); virtual;
    function InsertMySQLReturnID(SQL                  : String;
                                 var Error            : Boolean;
                                 var MessageError     : String) : integer;overload;virtual;
    function InsertMySQLReturnID(SQL                  : String;
                                 Params               : TRESTDWParams;
                                 var Error            : Boolean;
                                 var MessageError     : String) : integer;overload;virtual;
    function OpenDatasets(DatasetsLine          : String;
                          var Error             : Boolean;
                          var MessageError      : String;
                          var BinaryBlob        : TMemoryStream) : TJSONValue; overload;virtual;
    function OpenDatasets(DatapackStream        : TStream;
                          Var Error             : Boolean;
                          Var MessageError      : String;
                          Var BinaryBlob        : TMemoryStream;
                          aBinaryEvent          : Boolean = False;
                          aBinaryCompatibleMode : Boolean = False) : TStream; overload;virtual;

    class procedure CreateConnection(const AConnectionDefs  : TConnectionDefs;
                                     var AConnection        : TComponent); virtual;
    procedure PrepareConnection(var AConnectionDefs : TConnectionDefs);virtual;

    function ProcessMassiveSQLCache(MassiveSQLCache  : string;
                                    var Error        : Boolean;
                                    var MessageError : string) : TJSONValue; virtual;


    // base
    procedure BuildDatasetLine(var Query      : TRESTDWDataset;
                               Massivedataset : TMassivedatasetBuffer;
                               MassiveCache   : Boolean = False);
  published
    property Connection          : TComponent           read FConnection            write setConnection;

    property StrsTrim            : Boolean              read vStrsTrim              write vStrsTrim;
    property StrsEmpty2Null      : Boolean              read vStrsEmpty2Null        write vStrsEmpty2Null;
    property StrsTrim2Len        : Boolean              read vStrsTrim2Len          write vStrsTrim2Len;
    property Compression         : Boolean              read vCompression           write vCompression;
    property EncodeStringsJSON   : Boolean              read vEncodeStrings         write vEncodeStrings;
    property Encoding            : TEncodeSelect        read vEncoding              write vEncoding;
    property ParamCreate         : Boolean              read vParamCreate           write vParamCreate;
   {$IFDEF FPC}
     property DatabaseCharSet     : TDatabaseCharSet    read vDatabaseCharSet       write vDatabaseCharSet;
   {$ENDIF}
    property CommitRecords       : Integer              read vCommitRecords         write vCommitRecords;
    property OnPrepareConnection : TOnPrepareConnection read vOnPrepareConnection   write vOnPrepareConnection;
    property OnTableBeforeOpen   : TOnTableBeforeOpen   read vOnTableBeforeOpen     write vOnTableBeforeOpen;
    property OnQueryBeforeOpen   : TOnQueryBeforeOpen   read vOnQueryBeforeOpen     write vOnQueryBeforeOpen;
    property OnQueryException    : TOnQueryException    read vOnQueryException      write vOnQueryException;
  end;

implementation

uses
  uRESTDWBasicDB;

{ TRESTDWStoreProc }

function TRESTDWStoreProc.getStoredProcName : string;
begin
 try
   Result := GetStrProp(Self.Owner,'StoredProcName');
 except
   Result := '';
 end;
end;

procedure TRESTDWStoreProc.setStoredProcName(AValue : string);
begin
 try
   SetStrProp(Self.Owner,'Filter',AValue);
 except

 end;
end;

procedure TRESTDWStoreProc.ExecProc;
begin

end;

{ TRESTDWDataset }

function TRESTDWDataset.getFields: TFields;
begin
  Result := TDataSet(Self.Owner).Fields;
end;

function TRESTDWDataset.getParams: TParams;
begin
  try
    Result := TParams(GetObjectProp(Self.Owner,'Params'));
  except
    Result := nil;
  end;
end;

procedure TRESTDWDataset.createSequencedField(seqname, field : string);
begin

end;

procedure TRESTDWDataset.Close;
begin
  TDataSet(Self.Owner).Close;
end;

procedure TRESTDWDataset.Open;
begin
  TDataSet(Self.Owner).Open;
end;

procedure TRESTDWDataset.Insert;
begin
  TDataSet(Self.Owner).Insert;
end;

procedure TRESTDWDataset.Edit;
begin
  TDataSet(Self.Owner).Edit;
end;

procedure TRESTDWDataset.Post;
begin
  TDataSet(Self.Owner).Post;
end;

procedure TRESTDWDataset.Delete;
begin
  TDataSet(Self.Owner).Delete;
end;

procedure TRESTDWDataset.Next;
begin
  TDataSet(Self.Owner).Next;
end;

procedure TRESTDWDataset.Prepare;
begin

end;

procedure TRESTDWDataset.ExecSQL;
begin

end;

procedure TRESTDWDataset.FetchAll;
begin

end;

procedure TRESTDWDataset.SaveToStream(stream: TStream);
begin

end;

function TRESTDWDataset.Eof: boolean;
begin
  Result := TDataSet(Self.Owner).EOF;
end;

function TRESTDWDataset.RecNo: int64;
begin
  Result := TDataSet(Self.Owner).RecNo;
end;

function TRESTDWDataset.RecordCount: int64;
begin
  Result := -1;
end;

function TRESTDWDataset.ParamCount: integer;
begin
  try
    Result := Params.Count;
  except
    Result := -1;
  end;
end;

function TRESTDWDataset.ParamByName(param: string): TParam;
begin
  try
    Result := Params.FindParam(param);
  except
    Result := nil;
  end;
end;

function TRESTDWDataset.FieldByName(field: string): TField;
begin
  Result := TDataSet(Self.Owner).FieldByName(field);
end;

function TRESTDWDataset.FindField(field: string): TField;
begin
  Result := TDataSet(Self.Owner).FindField(field);
end;

function TRESTDWDataset.RDWDataTypeFieldName(field : string) : Byte;
var
  vDType : TFieldType;
begin
  vDType := FieldByName(field).DataType;
  Result := FieldTypeToDWFieldType(vDType);
end;

function TRESTDWDataset.RDWDataTypeParamName(param : string) : Byte;
var
  vDType : TFieldType;
begin
  try
    vDType := ParamByName(param).DataType;
  except
    vDType := ftUnknown;
  end;
  Result := FieldTypeToDWFieldType(vDType);
end;

function TRESTDWDataset.GetParamIndex(param: string): integer;
var
  prm : TParam;
begin
  try
    prm := Params.FindParam(param);
    Result := prm.Index;
  except
    Result := -1;
  end;
end;

{ TRESTDWTable }

function TRESTDWTable.getFilter: string;
begin
  try
    Result := GetStrProp(Self.Owner,'Filter');
  except
    Result := '';
  end;
end;

function TRESTDWTable.getFiltered: boolean;
begin
  try
    Result := Boolean(GetPropValue(Self.Owner,'Filtered'));
  except
    Result := False;
  end;
end;

function TRESTDWTable.getTableName: string;
begin
  try
    Result := GetStrProp(Self.Owner,'TableName');
  except
    Result := '';
  end;
end;

procedure TRESTDWTable.setFilter(AValue: string);
begin
  try
    SetStrProp(Self.Owner,'Filter',AValue);
  except

  end;
end;

procedure TRESTDWTable.setFiltered(AValue: boolean);
begin
  try
    SetPropValue(Self.Owner,'Filtered',AValue);
  except

  end;
end;

procedure TRESTDWTable.setTableName(AValue: string);
begin

end;

{ TRESTDWQuery }

function TRESTDWQuery.getSQL: TStrings;
begin
  try
    Result := TStrings(GetObjectProp(Self.Owner,'SQL'));
  except
    Result := nil;
  end;
end;

function TRESTDWQuery.RowsAffected: Int64;
begin
  Result := -1;
end;

function TRESTDWQuery.GetInsertID: int64;
var
  drv : TRESTDWDriverBase;
begin
  Result := -1;

  drv := TRESTDWDriverBase(Self.Owner);

  try
    if drv.getConectionType = dbtMySQL then begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT LAST_INSERT_ID() ID');
      Open;

      Result := Fields[0].AsLargeInt;
    end;
  except
    Result := -1;
  end;
end;

{ TRESTDWDriverBase }

function TRESTDWDriverBase.getConectionType: TRESTDWDatabaseType;
begin
  Result := dbtUndefined;
end;

function TRESTDWDriverBase.getDatabaseInfo: TRESTDWDatabaseInfo;
var
  connType: TRESTDWDatabaseType;
  qry : TRESTDWQuery;
  iAux1 : integer;
  sAux1, sVersion : string;
  lst : TStringList;
begin
  Result.rdwDatabaseName := '';
  Result.rdwDatabaseMajorVersion := 0;
  Result.rdwDatabaseMinorVersion := 0;
  Result.rdwDatabaseSubVersion := 0;

  // rdwDatabaseName foi definido para possiveis subversoes
  // ex: no MySQL temos o MariaDB
  // ex: no Firebird temos a versao HQBird

  sVersion := '';

  connType := getConectionType;
  lst := TStringList.Create;
  qry := getQuery;
  try
    if connType = dbtFirebird then begin
      Result.rdwDatabaseName := 'firebird';
      Result.rdwDatabaseMajorVersion := 1;
      Result.rdwDatabaseMinorVersion := 5;
      Result.rdwDatabaseSubVersion   := 0;
      try
        qry.SQL.Add('select rdb$get_context(''SYSTEM'',''ENGINE_VERSION'')');
        qry.SQL.Add('from rdb$database');
        qry.Open;

        sVersion := qry.Fields[0].AsString;
      except

      end;
    end
    else if connType = dbtInterbase then begin
      Result.rdwDatabaseName := 'interbase';
      Result.rdwDatabaseMajorVersion := 6;
      Result.rdwDatabaseMinorVersion := 0;
      Result.rdwDatabaseSubVersion   := 0;
      try
        qry.SQL.Add('select rdb$get_context(''SYSTEM'',''ENGINE_VERSION'')');
        qry.SQL.Add('from rdb$database');
        qry.Open;

        sVersion := qry.Fields[0].AsString;
      except

      end;
    end
    else if connType = dbtMySQL then begin
      Result.rdwDatabaseName := 'mysql';
      Result.rdwDatabaseMajorVersion := 3;
      Result.rdwDatabaseMinorVersion := 0;
      Result.rdwDatabaseSubVersion   := 0;

      try
        qry.SQL.Add('SHOW VARIABLES LIKE ''%version%''');
        qry.Open;

        while not qry.Eof do begin
          sAux1 := qry.FieldByName('variable_name').AsString;
          if SameText(sAux1,'innodb_version') then begin
            sVersion := qry.FieldByName('value').AsString;
          end
          else if SameText(sAux1,'version') then begin
            sAux1 := qry.FieldByName('value').AsString;
            if Pos('mariadb',LowerCase(sAux1)) > 0 then
              Result.rdwDatabaseName := 'mariadb';

            iAux1 := 1;
            while iAux1 <= Length(sAux1) do begin
              if not (sAux1[iAux1] in ['0'..'9','.']) then
                Delete(sAux1,iAux1,1)
              else
                iAux1 := iAux1 + 1;
            end;

            sVersion := sAux1;
          end
          else if SameText(sAux1,'version_comment') then begin
            sAux1 := qry.FieldByName('value').AsString;
            if Pos('mariadb',LowerCase(sAux1)) > 0 then
              Result.rdwDatabaseName := 'mariadb';
          end;
          qry.Next;
        end;
      except

      end;
    end
    else if connType = dbtPostgreSQL then begin
      Result.rdwDatabaseName := 'postgresql';
      Result.rdwDatabaseMajorVersion := 7;
      Result.rdwDatabaseMinorVersion := 0;
      Result.rdwDatabaseSubVersion   := 0;

      try
        qry.SQL.Add('SELECT version()');
        qry.Open;

        sAux1 := qry.Fields[0].AsString;
        iAux1 := Pos('.',sAux1);
        while (iAux1 > 0) and (sAux1[iAux1] <> ' ') do
          iAux1 := iAux1 - 1;

        if iAux1 > 0 then
          Delete(sAux1,1,iAux1);

        sAux1 := Trim(sAux1);

        iAux1 := 1;
        while (iAux1 <= Length(sAux1)) and (sAux1[iAux1] in ['0'..'9','.']) do begin
          sVersion := sVersion + sAux1[iAux1];
          iAux1 := iAux1 + 1;
        end;
      except

      end;

      if sVersion = '' then begin
       try
          qry.SQL.Add('SHOW server_version');
          qry.Open;

          sVersion := qry.Fields[0].AsString;
        except

        end;
      end;
    end
    else if connType = dbtSQLLite then begin
      Result.rdwDatabaseName := 'sqlite';
      Result.rdwDatabaseMajorVersion := 1;
      Result.rdwDatabaseMinorVersion := 0;
      Result.rdwDatabaseSubVersion   := 0;
      try
        qry.SQL.Add('select sqlite_version()');
        qry.Open;

        sVersion := qry.Fields[0].AsString;
      except

      end;
    end
    else if connType = dbtOracle then begin
      Result.rdwDatabaseName := 'oracle';
      Result.rdwDatabaseMajorVersion := 0;
      Result.rdwDatabaseMinorVersion := 0;
      Result.rdwDatabaseSubVersion   := 0;
      try
        qry.SQL.Add('SELECT * FROM v$version');
        qry.SQL.Add('WHERE banner LIKE ''Oracle%''');
        qry.Open;

        sAux1 := qry.Fields[0].AsString;
        repeat
          iAux1 := Pos(' ',sAux1);
          if iAux1 > 0 then begin
            if Pos('.',Copy(sAux1,1,iAux1-1)) > 0 then begin
              sVersion := Copy(sAux1,1,iAux1-1);
              Break;
            end;
            Delete(sVersion,1,iAux1);
          end;
        until iAux1 = 0;
      except

      end;
    end
    else if connType = dbtMsSQL then begin
      Result.rdwDatabaseName := 'mssql';
      Result.rdwDatabaseMajorVersion := 0;
      Result.rdwDatabaseMinorVersion := 0;
      Result.rdwDatabaseSubVersion   := 0;
      try
        qry.SQL.Add('select @@VERSION');
        qry.Open;

        sAux1 := qry.Fields[0].AsString;
        repeat
          iAux1 := Pos(' ',sAux1);
          if iAux1 > 0 then begin
            if Pos('.',Copy(sAux1,1,iAux1-1)) > 0 then begin
              sVersion := Copy(sAux1,1,iAux1-1);
              Break;
            end;
            Delete(sVersion,1,iAux1);
          end;
        until iAux1 = 0;
      except

      end;
    end;

    if sVersion <> '' then begin
      repeat
        iAux1 := Pos('.',sVersion);
        if iAux1 > 0 then begin
          lst.Add(Copy(sVersion,1,iAux1-1));
          Delete(sVersion,1,iAux1);
        end;
      until iAux1 = 0;

      if lst.Count > 0 then
        Result.rdwDatabaseMajorVersion := StrToInt(lst.Strings[0]);
      if lst.Count > 1 then
        Result.rdwDatabaseMinorVersion := StrToInt(lst.Strings[1]);
      if lst.Count > 2 then
        Result.rdwDatabaseSubVersion := StrToInt(lst.Strings[2]);
    end;
  finally
    FreeAndNil(qry);
    FreeAndNil(lst);
  end;
end;

function TRESTDWDriverBase.getQuery: TRESTDWQuery;
begin
  Result := nil;
end;

function TRESTDWDriverBase.getTable: TRESTDWTable;
begin
  Result := nil;
end;

function TRESTDWDriverBase.getStoreProc : TRESTDWStoreProc;
begin
  Result := nil;
end;

function TRESTDWDriverBase.isConnected: boolean;
begin
  Result := False;
end;

function TRESTDWDriverBase.connInTransaction: boolean;
begin
  Result := False
end;

procedure TRESTDWDriverBase.connStartTransaction;
begin

end;

procedure TRESTDWDriverBase.connRollback;
begin

end;

procedure TRESTDWDriverBase.connCommit;
begin

end;

function TRESTDWDriverBase.isMinimumVersion(major, minor, sub: integer): boolean;
var
  info : TRESTDWDatabaseInfo;
begin
  info := getDatabaseInfo;
  Result := (info.rdwDatabaseMajorVersion >= major) and
            (info.rdwDatabaseMinorVersion >= minor) and
            (info.rdwDatabaseMinorVersion >= sub);
end;

function TRESTDWDriverBase.isMinimumVersion(major, minor: integer): boolean;
begin
  Result := isMinimumVersion(major,minor,0);
end;

procedure TRESTDWDriverBase.setConnection(AValue: TComponent);
begin
  if FConnection = AValue then
    Exit;

  Disconect;
  FConnection := AValue;
end;

procedure TRESTDWDriverBase.Connect;
begin

end;

procedure TRESTDWDriverBase.Disconect;
begin

end;

function TRESTDWDriverBase.ConnectionSet: Boolean;
begin
  Result := Assigned(FConnection);
end;

function TRESTDWDriverBase.GetGenID(Query: TRESTDWQuery;
                                    GenName: string; valor: integer): integer;
var
  connType : TRESTDWDatabaseType;
begin
  Result := -1;
  connType := getConectionType;
  with Query do begin
    Close;
    SQL.Clear;
    if connType = dbtFirebird then begin
      SQL.Add('select gen_id('+QuotedStr(GenName)+','+IntToStr(valor)+')');
      SQL.Add('from rdb$database');
      Open;

      Result := Query.Fields[0].AsInteger;
    end
    else if connType = dbtMySQL then begin
      SQL.Add('show table status where name = '+QuotedStr(GenName));
      Open;

      Result := valor + Query.FieldByName('auto_increment').AsInteger;

      if valor <> 0 then begin
        SQL.Clear;
        SQL.Add('alter table '+GenName+' auto_increment='+IntToStr(Result));
        ExecSQL;
      end;
    end
    else if connType = dbtSQLLite then begin
      SQL.Add('create table if not exist sqlite_sequence(name,seq)');
      ExecSQL;

      SQL.Clear;
      SQL.Add('select seq from sqlite_sequence');
      SQL.Add('where name = '+QuotedStr(GenName));
      Open;

      Result := valor + Query.Fields[0].AsInteger;

      if valor <> 0 then begin
        SQL.Clear;
        SQL.Add('insert or replace into sqlite_sequence(name,seq)');
        SQL.Add('values('+QuotedStr(GenName)+','+IntToStr(Result)+')');
        ExecSQL;
      end;
    end
    else if connType = dbtPostgreSQL then begin
      SQL.Add('select currval('+QuotedStr(GenName)+')');
      Open;

      try
        if valor <> 0 then begin
          SQL.Clear;
          SQL.Add('select nextval('+QuotedStr(GenName)+')');
          Open;
        end;
      except
        SQL.Clear;
        SQL.Add('select nextval('+QuotedStr(GenName)+')');
        Open;
      end;

      Result := Query.Fields[0].AsInteger;
    end;
  end;
end;

function TRESTDWDriverBase.GetGenID(GenName: string; valor: integer): integer;
var
  qry : TRESTDWQuery;
begin
  qry := getQuery;
  try
    Result := GetGenID(qry,GenName,valor);
  finally
    FreeAndNil(qry);
  end;
end;

function TRESTDWDriverBase.ApplyUpdates(MassiveStream: TStream;
                                        SQL: string;
                                        Params: TRESTDWParams;
                                        var Error: boolean;
                                        var MessageError: string;
                                        var RowsAffected: integer): TJSONValue;
Var
 vTempQuery     : TRESTDWQuery;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
 vMassiveLine   : Boolean;

  Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vTempValue,
  vStringFloat,
  vReflectionLine,
  vReflectionLines : String;
  vFieldType       : TFieldType;
  MassiveField     : TMassiveField;
  vFieldChanged    : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  vFieldChanged     := False;
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]']);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                          (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                        vFieldChanged     := True
                                       Else
                                        Begin
                                         If (Not MassiveField.IsNull) Then
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value)
                                         Else
                                          vFieldChanged    := Not(Query.Fields[I].IsNull);
                                        End;
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        If Assigned(vStringStream) Then
                                         FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (Not MassiveField.IsNull) Then
                                       Begin
                                        If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                   IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                     IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                                       End;
                                     End;
           {$IFNDEF FPC}
             {$IF CompilerVersion >= 21}
                ftSingle,
                ftExtended,
             {$IFEND}
           {$ENDIF}
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd : Begin
                                       vStringFloat  := Query.Fields[I].AsString;
                                       If (Trim(vStringFloat) <> '') Then
                                        vStringFloat := BuildStringFloat(vStringFloat)
                                       Else
                                        vStringFloat := cNullvalue;
                                       If (MassiveField.Modified) Then
                                        vStringFloat := BuildStringFloat(MassiveField.Value);
                                       If vReflectionLine = '' Then
                                        vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                       Else
                                        vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                      End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               vTempValue := Query.Fields[I].AsString;
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                             EncodeStream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 EncodeStream(vStringStream)]); // StreamToHex(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                If Assigned(vStringStream) Then
                 FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : TStream; Var Query : TRESTDWQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TRESTDWQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X                 : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
    vTempValue        : String;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 21}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 21}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat, ftCurrency, ftBCD,ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                            ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                            ftString,    ftWideString,
                            ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 21}
                                     , ftWideMemo
                                    {$IFEND}
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
          Else
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
         End;
       End
      Else
       Begin
        If Query.Params[I].DataType in [ftUnknown] Then
         Begin
          If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
           Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
          Else
           Query.Params[I].DataType := ftString;
         End;
        If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd {$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle{$IFEND}{$ENDIF} ] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
            Try
             MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
             If vStringStream <> Nil Then
              Begin
               vStringStream.Position := 0;
               Query.Params[I].LoadFromStream(vStringStream, ftBlob);
              End
             Else
              Query.Params[I].Clear;
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Query.Params[I].Clear;
         End
        Else
         Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' Where %s'])
                Else
                 vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                        (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                        (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                       (MassiveDataset.Fields.Items[I].ReadOnly))          And
                       (Not(MassiveDataset.ReflectChanges)))               Or
                      ((MassiveDataset.ReflectChanges) And
                       (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                    Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                  If MassiveDataset.ReflectChanges Then
                   Begin
                    If MassiveDataset.Fields.Items[I].KeyField Then
                     If vParamsSQL = '' Then
                      vParamsSQL := MassiveDataset.Fields.Items[I].FieldName + ' is null '
                     Else
                      vParamsSQL  := vParamsSQL + ' and ' + MassiveDataset.Fields.Items[I].FieldName + ' is null ';
                   End;
                 End;
                If MassiveDataset.ReflectChanges Then
                 Begin
                  If (vParamsSQL = '') And
                     (MassiveDataset.AtualRec.MassiveMode <> mmInsert) Then
                   Begin
                    Raise Exception.Create(PChar(Format('Invalid insert, table %s no have keys defined to use in Reflect Changes...', [MassiveDataset.TableName])));
                    Exit;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vFields  := '';
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' %s'])
                Else
                 vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                If Not MassiveDataset.ReflectChanges Then
                 Begin
                  For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If vFields = '' Then
                       vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End
                Else
                 Begin
                  For I := 0 To MassiveDataset.Fields.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                        Continue;
                      If vFields = '' Then
                       vFields     := MassiveDataset.Fields.Items[I].FieldName//MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName //MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
    mmExec   : vLineSQL := MassiveDataset.Dataexec.Text;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   If (MassiveDataset.ReflectChanges) And
      (Not(MassiveDataset.MassiveMode in [mmDelete, mmExec])) Then
    Begin
     If MassiveDataset.MassiveMode = mmUpdate Then
      SetUpdateBuffer(True);
     Query.Open;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
          Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query.Owner));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query.Owner));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     For I := 0 To Query.ParamCount -1 Do
      Begin
       If MassiveDataset.MassiveMode = mmExec Then
        Begin
         If MassiveDataset.Params.ItemsString[Query.Params[I].Name] <> Nil Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue);
           If MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd {$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull))  Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                   Begin
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(TStream(vStringStream));
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End;
        End
       Else
        Begin
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
           If Not MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End
               Else  If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd {$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull))     Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                   Begin
                    MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  If Assigned(vStringStream) Then
                   FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End
         Else
          Begin
           If I = 0 Then
            SetUpdateBuffer;
          End;
        End;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Result         := False;
  Try
   MassiveDataset.LoadFromStream(Massive);
   MassiveDataset.First;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
      TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
    End;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If Not connInTransaction Then
      Begin
         connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Query.SQL.Clear;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      If (Not (MassiveDataset.ReflectChanges))     Or
         ((MassiveDataset.ReflectChanges)          And
          (MassiveDataset.MassiveMode in [mmExec, mmDelete])) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
          connRollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If connInTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
            connCommit;
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
           End;
         End;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If connInTransaction Then
            connRollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If connInTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
         connCommit;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
       End;
     End;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If connInTransaction Then
        connRollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
   FreeAndNil(MassiveDataset);
   Query.SQL.Clear;
  End;
 End;
Begin
 Inherited;
 Try
  Result     := Nil;
  Error      := False;
  vStringStream := Nil;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If not isConnected Then
    Connect;

  vTempQuery.SQL.Clear;
  vResultReflection := '';
  If LoadMassive(MassiveStream, vTempQuery) Then
   Begin
    If (SQL <> '') And (vResultReflection = '') Then
     Begin
      Try
       vTempQuery.SQL.Clear;
       vTempQuery.SQL.Add(SQL);
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.ParamCount > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A          := vTempQuery.GetParamIndex(vParamName);
             If A > -1 Then
              Begin
               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}]    Then
                Begin
                 If vTempQuery.Params[A].DataType In [ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}] Then
                  vTempQuery.Params[A].Value := Params[I].Value
                 Else
                  Begin
                   If vTempQuery.Params[A].Size > 0 Then
                    vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
                   Else
                    vTempQuery.Params[A].Value := Params[I].Value;
                  End;
                End
               Else
                Begin
                 If vTempQuery.Params[A].DataType in [ftUnknown] Then
                  Begin
                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
                    vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
                   Else
                    vTempQuery.Params[A].DataType := ftString;
                  End;
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                      vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType = ftDate Then
                      vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
                     Else If vTempQuery.Params[A].DataType = ftTime Then
                      vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
                     Else
                      vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   If Not Assigned(vStringStream) Then
                    vStringStream  := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(TStream(vStringStream));
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                   Finally
                    If Assigned(vStringStream) Then
                     FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Params[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Error         := False;

       if not vStateResource then
          Disconect;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          Result.SetValue(GetPairJSONStr('NOK', MessageError));
          If connInTransaction Then
           connRollback;
         Except
         End;
         Disconect;
        End;
      End;
     End
    Else If (vResultReflection <> '') Then
     Begin
      If Result = Nil Then
       Result         := TJSONValue.Create;
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
     End;
   End;
 Finally
  FreeAndNil(BufferBase);
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
 End;
end;

function TRESTDWDriverBase.ApplyUpdates(Massive,SQL: string;
                                        Params: TRESTDWParams;
                                        var Error: Boolean;
                                        var MessageError: string;
                                        var RowsAffected: Integer): TJSONValue;
Var
 vTempQuery     : TRESTDWQuery;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
 vMassiveLine   : Boolean;

 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vTempValue,
  vStringFloat,
  vReflectionLine,
  vReflectionLines : String;
  vFieldType       : TFieldType;
  MassiveField     : TMassiveField;
  vFieldChanged    : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  vFieldChanged     := False;
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]']);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                          (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                        vFieldChanged     := True
                                       Else
                                        Begin
                                         If (Not MassiveField.IsNull) Then
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value)
                                         Else
                                          vFieldChanged    := Not(Query.Fields[I].IsNull);
                                        End;
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        If Assigned(vStringStream) Then
                                         FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (Not MassiveField.IsNull) Then
                                       Begin
                                        If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                   IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                     IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                                       End;
                                     End;
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},
                                 ftSingle,
                                 ftExtended{$IFEND}{$ENDIF} : Begin
                                       vStringFloat  := Query.Fields[I].AsString;
                                       If (Trim(vStringFloat) <> '') Then
                                        vStringFloat := BuildStringFloat(vStringFloat)
                                       Else
                                        vStringFloat := cNullvalue;
                                       If (MassiveField.Modified) Then
                                        vStringFloat := BuildStringFloat(MassiveField.Value);
                                       If vReflectionLine = '' Then
                                        vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                       Else
                                        vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                      End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               vTempValue := Query.Fields[I].AsString;
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                             EncodeStream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 EncodeStream(vStringStream)]); // StreamToHex(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                If Assigned(vStringStream) Then
                 FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TRESTDWQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TRESTDWQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X                 : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
    vTempValue        : String;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 21}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 21}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD,ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                            ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                            ftString,    ftWideString,
                            ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 21}
                                     , ftWideMemo
                                    {$IFEND}
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
          Else
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
         End;
       End
      Else
       Begin
        If Query.Params[I].DataType in [ftUnknown] Then
         Begin
          If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
           Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
          Else
           Query.Params[I].DataType := ftString;
         End;
        If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
            Try
             MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
             If vStringStream <> Nil Then
              Begin
               vStringStream.Position := 0;
               Query.Params[I].LoadFromStream(vStringStream, ftBlob);
              End
             Else
              Query.Params[I].Clear;
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Query.Params[I].Clear;
         End
        Else
         Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' Where %s'])
                Else
                 vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                        (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                        (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                       (MassiveDataset.Fields.Items[I].ReadOnly))          And
                       (Not(MassiveDataset.ReflectChanges)))               Or
                      ((MassiveDataset.ReflectChanges) And
                       (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                    Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                  If MassiveDataset.ReflectChanges Then
                   Begin
                    If MassiveDataset.Fields.Items[I].KeyField Then
                     If vParamsSQL = '' Then
                      vParamsSQL := MassiveDataset.Fields.Items[I].FieldName + ' is null '
                     Else
                      vParamsSQL  := vParamsSQL + ' and ' + MassiveDataset.Fields.Items[I].FieldName + ' is null ';
                   End;
                 End;
                If MassiveDataset.ReflectChanges Then
                 Begin
                  If (vParamsSQL = '') And
                     (MassiveDataset.AtualRec.MassiveMode <> mmInsert) Then
                   Begin
                    Raise Exception.Create(PChar(Format('Invalid insert, table %s no have keys defined to use in Reflect Changes...', [MassiveDataset.TableName])));
                    Exit;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vFields  := '';
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' %s'])
                Else
                 vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                If Not MassiveDataset.ReflectChanges Then
                 Begin
                  For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If vFields = '' Then
                       vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End
                Else
                 Begin
                  For I := 0 To MassiveDataset.Fields.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                        Continue;
                      If vFields = '' Then
                       vFields     := MassiveDataset.Fields.Items[I].FieldName//MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName //MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
    mmExec   : vLineSQL := MassiveDataset.Dataexec.Text;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   If (MassiveDataset.ReflectChanges) And
      (Not(MassiveDataset.MassiveMode in [mmDelete, mmExec])) Then
    Begin
     If MassiveDataset.MassiveMode = mmUpdate Then
      SetUpdateBuffer(True);
     Query.Open;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query.Owner));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query.Owner));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     For I := 0 To Query.ParamCount -1 Do
      Begin
       If MassiveDataset.MassiveMode = mmExec Then
        Begin
         If MassiveDataset.Params.ItemsString[Query.Params[I].Name] <> Nil Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue);
           If MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull))  Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                   Begin
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(TStream(vStringStream));
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End;
        End
       Else
        Begin
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
           If Not MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End
               Else  If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull))     Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                   Begin
                    MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  If Assigned(vStringStream) Then
                   FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End
         Else
          Begin
           If I = 0 Then
            SetUpdateBuffer;
          End;
        End;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Result         := False;
  Try
   MassiveDataset.FromJSON(Massive);
   MassiveDataset.First;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
      TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
    End;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If Not connInTransaction Then
      Begin
       connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Query.SQL.Clear;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      If (Not (MassiveDataset.ReflectChanges))     Or
         ((MassiveDataset.ReflectChanges)          And
          (MassiveDataset.MassiveMode in [mmExec, mmDelete])) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
          connRollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If connInTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
           connCommit;
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
           End;
         End;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If connInTransaction Then
            connRollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If connInTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
       connCommit;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
       End;
     End;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If connInTransaction Then
        connRollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
   FreeAndNil(MassiveDataset);
   Query.SQL.Clear;
  End;
 End;
Begin
 Inherited;
 Try
  Result     := Nil;
  Error      := False;
  vStringStream := Nil;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If Not vStateResource Then
    connCommit;
  vTempQuery.SQL.Clear;
  vResultReflection := '';
  If LoadMassive(Massive, vTempQuery) Then
   Begin
    If (SQL <> '') And (vResultReflection = '') Then
     Begin
      Try
       vTempQuery.SQL.Clear;
       vTempQuery.SQL.Add(SQL);
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.ParamCount > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A          := vTempQuery.GetParamIndex(vParamName);
             If A > -1 Then
              Begin
               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}]    Then
                Begin
                 If vTempQuery.Params[A].DataType In [ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}] Then
                  vTempQuery.Params[A].Value := Params[I].Value
                 Else
                  Begin
                   If vTempQuery.Params[A].Size > 0 Then
                    vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
                   Else
                    vTempQuery.Params[A].Value := Params[I].Value;
                  End;
                End
               Else
                Begin
                 If vTempQuery.Params[A].DataType in [ftUnknown] Then
                  Begin
                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
                    vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
                   Else
                    vTempQuery.Params[A].DataType := ftString;
                  End;
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                      vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType = ftDate Then
                      vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
                     Else If vTempQuery.Params[A].DataType = ftTime Then
                      vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
                     Else
                      vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
//                     vTempQuery.Params[A].AsDateTime  := Params[I].AsDateTime
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   If Not Assigned(vStringStream) Then
                    vStringStream  := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(TStream(vStringStream));
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                   Finally
                    If Assigned(vStringStream) Then
                     FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Params[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Error         := False;
       if not vStateResource then
         Disconect
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          Result.SetValue(GetPairJSONStr('NOK', MessageError));
          If connInTransaction Then
            connRollback;
         Except
         End;
         Disconect;
        End;
      End;
     End
    Else If (vResultReflection <> '') Then
     Begin
      If Result = Nil Then
       Result         := TJSONValue.Create;
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
 End;
end;

function TRESTDWDriverBase.ApplyUpdatesTB(MassiveStream: TStream;
                                          SQL: String;
                                          Params: TRESTDWParams;
                                          var Error: Boolean;
                                          var MessageError: String;
                                          var RowsAffected: Integer): TJSONValue;
var
  StrMassive : string;
begin
  SetLength(StrMassive,MassiveStream.Size);
  MassiveStream.Read(StrMassive[InitStrPos],MassiveStream.Size);
  Result := ApplyUpdatesTB(StrMassive,Params,Error,MessageError,RowsAffected);
end;

function TRESTDWDriverBase.ApplyUpdatesTB(Massive: String;
                                          Params: TRESTDWParams;
                                          var Error: Boolean;
                                          var MessageError: String;
                                          var RowsAffected: Integer): TJSONValue;
Var
 vTempQuery     : TRESTDWTable;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vMassiveLine   : Boolean;
 vValueKeys     : TRESTDWValueKeys;
 vDataSet       : TDataSet;

 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vTempValue,
  vStringFloat,
  vReflectionLine,
  vReflectionLines : String;
  vFieldType       : TFieldType;
  MassiveField     : TMassiveField;
  vFieldChanged    : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  {$IFDEF FPC}
  vFieldChanged     := False;
  {$ENDIF}
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]']);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (Not MassiveField.IsNull) Then
                                        Begin
                                         If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                            (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                          vFieldChanged     := True
                                         Else
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value);
                                        End
                                       Else
                                        vFieldChanged    := Not(Query.Fields[I].IsNull);
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (Not MassiveField.IsNull) Then
                                       Begin
                                        If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                   IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                     IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                                       End;
                                     End;
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22},
                                 ftSingle,
                                 ftExtended
                                 {$IFEND}
                                 {$ENDIF} : Begin
                                             vStringFloat  := Query.Fields[I].AsString;
                                             If (Trim(vStringFloat) <> '') Then
                                              vStringFloat := BuildStringFloat(vStringFloat)
                                             Else
                                              vStringFloat := cNullvalue;
                                             If (MassiveField.Modified) Then
                                              vStringFloat := BuildStringFloat(MassiveField.Value);
                                             If vReflectionLine = '' Then
                                              vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                             Else
                                              vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                            End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               vTempValue := Query.Fields[I].AsString;
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                             EncodeStream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 EncodeStream(vStringStream)]); // StreamToHex(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TRESTDWTable) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;

  Procedure PrepareData(Var Query      : TRESTDWTable;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLocate    : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 22}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                               {$ELSE}
                                                                               , ftWideMemo
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Begin
             Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
             Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size);
            end
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                         ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                         ftString,    ftWideString,
                         ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 22}
                                     , ftWideMemo
                                    {$IFEND}
                                    {$ELSE}
                                    , ftWideMemo
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
         Begin
          If Query.Fields[I].Size > 0 Then
           Begin
            Query.Fields[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value, 1, Query.Fields[I].Size);
           End
          Else
           Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
         End;
       End
      Else
       Begin
        If Query.Fields[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Begin
            If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
             Query.Fields[I]{$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value)
            Else
             Query.Fields[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
           End
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value))
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value
          Else
           Query.Fields[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
           If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).SaveToStream(vStringStream);
              If vStringStream <> Nil Then
               Begin
                vStringStream.Position := 0;
                TBlobField(Query.Fields[I]).LoadFromStream(vStringStream);
               End
              Else
               Query.Fields[I].Clear;
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.Fields[I].Clear;
         End
        Else
         Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.Filter    := '';
   Query.Filtered  := False;
   Query.TableName := MassiveDataset.TableName;
   vLocate         := '';
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vLocate := '1=0';
               End;
    mmUpdate,
    mmDelete : Begin
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If MassiveDataset.MassiveMode = mmUpdate Then
                    Begin
                     If I = 0 Then
                      vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value])
                     Else
                      vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value]);
                    End
                   Else
                    Begin
                     If I = 0 Then
                      vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I +1].Value])
                     Else
                      vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I +1].Value]);
                    End;
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
               End;
   End;
   Query.Filter    := vLocate;
   Query.Filtered  := True;
   //Params
   If (MassiveDataset.MassiveMode <> mmDelete) Then
    Begin
     If Assigned(Self.OnTableBeforeOpen) Then
      Self.OnTableBeforeOpen(vDataSet, Params, MassiveDataset.TableName);
     Query.Open;
     Query.FetchAll;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
          End;
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Begin
                             Query.Post;
//                             Query.RefreshCurrentRow(true);
//                             Query.Resync([rmExact, rmCenter]);
                            End;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     Query.Open;
     Query.Delete;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Result         := False;
  Try
   MassiveDataset.FromJSON(Massive);
   MassiveDataset.First;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
      TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
    End;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If not connInTransaction Then Begin
       connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Query.Close;
     Query.Filter := '';
     Query.Filtered := False;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      If (Not (MassiveDataset.ReflectChanges))     Or
         ((MassiveDataset.ReflectChanges)          And
          (MassiveDataset.MassiveMode in [mmExec])) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
          connRollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If connInTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
           connCommit;
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
           End;
         End;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If connInTransaction Then
            connRollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If connInTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
         connCommit;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
       End;
     End;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If connInTransaction Then
        connRollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
   FreeAndNil(MassiveDataset);
   Query.Filter := '';
   Query.Filtered := False;
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Try
  Result         := Nil;
  Error          := False;
  vStringStream  := Nil;
  vTempQuery     := getTable;
  vDataSet       := TDataSet(vTempQuery.Owner);
  vValueKeys     := TRESTDWValueKeys.Create;
  If Not isConnected Then
   Connect;
  vTempQuery.Filter       := '';
  vResultReflection := '';
  If LoadMassive(Massive, vTempQuery) Then
   Begin
    If (vResultReflection = '') Then
     Begin
      Try
       vTempQuery.Filter   := '';
       vTempQuery.Filtered := False;
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.Fields.Count > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A := vTempQuery.GetParamIndex(vParamName);
             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
              Begin
               If vTempQuery.Fields[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                              {$IF CompilerVersion > 22}
                                                               , ftWideMemo
                                                              {$IFEND}
                                                              {$ELSE}
                                                              , ftWideMemo
                                                            {$ENDIF}]    Then
                Begin
                 If vTempQuery.Fields[A].Size > 0 Then
                  Begin
//                   vTempQuery.Fields[A].DataType := ftString;
                   vTempQuery.Fields[A].Value := Copy(Params[I].Value, 1, vTempQuery.Fields[A].Size);
                  End
                 Else
                  vTempQuery.Fields[A].Value := Params[I].Value;
                End
               Else
                Begin
//                 If vTempQuery.Fields[A].DataType in [ftUnknown] Then
//                  Begin
//                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
//                    vTempQuery.Fields[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
//                   Else
//                    vTempQuery.Fields[A].DataType := ftString;
//                  End;
                 If vTempQuery.Fields[A].DataType in [ftInteger, ftSmallInt, ftWord{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}, ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Fields[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                      Begin
                       {$IFNDEF FPC}
                        {$IF CompilerVersion > 22}vTempQuery.Fields[A].AsLargeInt := StrToInt64(Params[I].Value);
                        {$ELSE}vTempQuery.Fields[A].AsInteger                     := StrToInt64(Params[I].Value);
                        {$IFEND}
                       {$ELSE}
                        vTempQuery.Fields[A].AsLargeInt := StrToInt64(Params[I].Value);
                       {$ENDIF}
                      End
                     Else
                      vTempQuery.Fields[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Fields[A].Clear;
                  End
                 Else If vTempQuery.Fields[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Fields[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Fields[A].Clear;
                  End
                 Else If vTempQuery.Fields[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Fields[A].AsDateTime := Params[I].AsDateTime
                   Else
                    vTempQuery.Fields[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Fields[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   If Not Assigned(vStringStream) Then
                    vStringStream  := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(vStringStream);
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     TBlobField(vTempQuery.Fields[A]).LoadFromStream(vStringStream);
                   Finally
                    If Assigned(vStringStream) Then
                     FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Fields[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       vTempQuery.FetchAll;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       {$IFDEF FPC}
        Result.DatabaseCharSet := DatabaseCharSet;
       {$ENDIF}
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Error         := False;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          {$IFDEF FPC}
           Result.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          Result.SetValue(GetPairJSONStr('NOK', MessageError));
          connRollback;
         Except
         End;
        End;
      End;
     End
    Else If (vResultReflection <> '') Then
     Begin
      If Result = Nil Then
       Result         := TJSONValue.Create;
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      {$IFDEF FPC}
       Result.DatabaseCharSet := DatabaseCharSet;
      {$ENDIF}
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RecordCount;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
  FreeAndNil(vValueKeys);
 End;
end;

function TRESTDWDriverBase.ApplyUpdates_MassiveCache(MassiveCache: string;
                                                     var Error: boolean;
                                                     var MessageError: string): TJSONValue;
Var
 vTempQuery        : TRESTDWQuery;
 vStringStream     : TMemoryStream;
 bPrimaryKeys      : TStringList;
 vFieldType        : TFieldType;
 vStateResource,
 vMassiveLine      : Boolean;
 vResultReflection : String;

 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vStringFloat,
  vTempValue,
  vReflectionLine,
  vReflectionLines  : String;
  vFieldType        : TFieldType;
  MassiveField      : TMassiveField;
  MassiveReplyValue : TMassiveReplyValue;
  vFieldChanged     : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  vFieldChanged     := False;
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s, "mycomptag":"%s"}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]', MassiveDataset.MyCompTag]);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                          (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                        vFieldChanged     := True
                                       Else
                                        Begin
                                         If (Not MassiveField.IsNull) Then
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value)
                                         Else
                                          vFieldChanged    := Not(Query.Fields[I].IsNull);
                                        End;
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        If Assigned(vStringStream) Then
                                         FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          MassiveReplyValue := MassiveDataset.MassiveReply.GetReplyValue(MassiveDataset.MyCompTag, Query.Fields[I].FieldName, MassiveField.Value);
          If MassiveField.KeyField Then
           Begin
            If MassiveReplyValue = Nil Then
             MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, MassiveField.Value, Query.Fields[I].AsString)
            Else
             MassiveDataset.MassiveReply.UpdateBufferValue(MassiveDataset.MyCompTag, Query.Fields[I].FieldName, MassiveField.Value, Query.Fields[I].AsString);
           End;
          vTempValue := Query.Fields[I].AsString;
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (vTempValue <> cNullvalue) And (vTempValue <> '') Or (MassiveField.Modified) Then
                                       Begin
                                        If (StrToDateTime(vTempValue) <> MassiveField.Value) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(vTempValue)));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                     vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                                         vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                                       cNullvalue]);
                                       End;
                                     End;
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},
                                 ftSingle,
                                 ftExtended{$IFEND}{$ENDIF} : Begin
                                       vStringFloat  := Query.Fields[I].AsString;
                                       If (Trim(vStringFloat) <> '') Then
                                        vStringFloat := BuildStringFloat(vStringFloat)
                                       Else
                                        vStringFloat := cNullvalue;
                                       If (MassiveField.Modified) Then
                                        vStringFloat := BuildStringFloat(MassiveField.Value);
                                       If vReflectionLine = '' Then
                                        vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                       Else
                                        vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                      End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, EncodeStream(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, EncodeStream(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                If Assigned(vStringStream) then
                 FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TRESTDWQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, X           : Integer;
  bJsonValueB    : TRESTDWJSONInterfaceBase;
  bJsonValue     : TRESTDWJSONInterfaceObject;
  bJsonArray     : TRESTDWJSONInterfaceArray;
  Procedure PrepareData(Var Query      : TRESTDWQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
    vTempValue        : String;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 21}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 21}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD,ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                            ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                            ftString,    ftWideString,
                            ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 21}
                                     , ftWideMemo
                                    {$IFEND}
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
          Else
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
         End;
       End
      Else
       Begin
        If Query.Params[I].DataType in [ftUnknown] Then
         Begin
          If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
           Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
          Else
           Query.Params[I].DataType := ftString;
         End;
        If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsDateTime  := StrToDateTime(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
          Else
           Query.Params[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
           If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
              If vStringStream <> Nil Then
               Begin
                vStringStream.Position := 0;
                Query.Params[I].LoadFromStream(vStringStream, ftBlob);
               End
              Else
               Query.Params[I].Clear;
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.Params[I].Clear;
         End
        Else
         Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' Where %s'])
                Else
                 vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                        (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                        (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                       (MassiveDataset.Fields.Items[I].ReadOnly))          And
                       (Not(MassiveDataset.ReflectChanges)))               Or
                      ((MassiveDataset.ReflectChanges) And
                       (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                    Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                  If MassiveDataset.ReflectChanges Then
                   Begin
                    If MassiveDataset.Fields.Items[I].KeyField Then
                     If vParamsSQL = '' Then
                      vParamsSQL := MassiveDataset.Fields.Items[I].FieldName + ' is null '
                     Else
                      vParamsSQL  := vParamsSQL + ' and ' + MassiveDataset.Fields.Items[I].FieldName + ' is null ';
                   End;
                 End;
                If MassiveDataset.ReflectChanges Then
                 Begin
                  If vParamsSQL = '' Then
                   Begin
                    Raise Exception.Create(PChar(Format('Invalid insert, table %s no have keys defined to use in Reflect Changes...', [MassiveDataset.TableName])));
                    Exit;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vFields  := '';
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' %s'])
                Else
                 vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                If Not MassiveDataset.ReflectChanges Then
                 Begin
                  For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If vFields = '' Then
                       vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End
                Else
                 Begin
                  For I := 0 To MassiveDataset.Fields.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                        Continue;
                      If vFields = '' Then
                       vFields     := MassiveDataset.Fields.Items[I].FieldName//MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName //MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
    mmExec   : vLineSQL := MassiveDataset.Dataexec.Text;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   If (MassiveDataset.ReflectChanges) And
      (Not(MassiveDataset.MassiveMode in [mmDelete, mmExec])) Then
    Begin
     If MassiveDataset.MassiveMode = mmUpdate Then
      SetUpdateBuffer(True);
     Query.Open;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset, True);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query.Owner));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     For I := 0 To Query.ParamCount -1 Do
      Begin
       If MassiveDataset.MassiveMode = mmExec Then
        Begin
         If MassiveDataset.Params.ItemsString[Query.Params[I].Name] <> Nil Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue);
           If MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull))  Then
                  Query.Params[I].AsDateTime  := StrToDateTime(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                   Begin
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(TStream(vStringStream));
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End;
        End
       Else
        Begin
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
           If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull))  Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                   Begin
                    MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End
         Else
          Begin
           If I = 0 Then
            SetUpdateBuffer;
          End;
        End;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  bJsonValue     := TRESTDWJSONInterfaceObject.Create(MassiveCache);
  bJsonArray     := TRESTDWJSONInterfaceArray(bJsonValue);
  Result         := False;
  Try
   For x := 0 To bJsonArray.ElementCount -1 Do
    Begin
     bJsonValueB := bJsonArray.GetObject(X);//bJsonArray.get(X);
     If not connInTransaction Then
      Begin
       connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Try
      MassiveDataset.FromJSON(TRESTDWJSONInterfaceObject(bJsonValueB).ToJSON);
      MassiveDataset.First;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
         TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
       End;
      For A := 1 To MassiveDataset.RecordCount Do
       Begin
        Query.SQL.Clear;
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          vMassiveLine := False;
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
           Begin
            TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
            If vMassiveLine Then
             Begin
              MassiveDataset.Next;
              Continue;
             End;
           End;
         End;
        PrepareData(Query, MassiveDataset, Error, MessageError);
        Try
         If (Not (MassiveDataset.ReflectChanges))     Or
            ((MassiveDataset.ReflectChanges)          And
            (MassiveDataset.MassiveMode in [mmExec, mmDelete])) Then
          Begin
           Query.ExecSQL;

           // Inclusão do método de after massive line process
           If (Self.Owner.ClassType = TServerMethodDatamodule) Or
             (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
             TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query));
           End;
         End;
        Except
         On E : Exception do
          Begin
           Error  := True;
           Result := False;
           If connInTransaction Then
             connRollback;
           MessageError := E.Message;
           Exit;
          End;
        End;
        MassiveDataset.Next;
       End;
     Finally
      Query.SQL.Clear;
      FreeAndNil(bJsonValueB);
     End;
    End;
   If Not Error Then
    Begin
     Try
      Result        := True;
      If connInTransaction Then
       Begin
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
           TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
         End;
         connCommit;
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
           TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
         End;
       End;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
           connRollback;
        MessageError := E.Message;
       End;
     End;
    End;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
  Finally
   FreeAndNil(bJsonValue);
   FreeAndNil(MassiveDataset);
  End;
 End;
Begin
 Inherited;
 vResultReflection := '';
 Result     := Nil;
 vStringStream := Nil;
 Try
  Error      := False;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If Not vStateResource Then
    Connect;
  vTempQuery.SQL.Clear;
  LoadMassive(MassiveCache, vTempQuery);
  If Result = Nil Then
   Result         := TJSONValue.Create;
  If (vResultReflection <> '') Then
   Begin
    Result.Encoding := Encoding;
    Result.Encoded  := EncodeStringsJSON;
    Result.SetValue('[' + vResultReflection + ']');
    Error         := False;
   End
  Else
   Result.SetValue('[]');
  If Not vStateResource Then
    Disconect;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
end;

function TRESTDWDriverBase.ApplyUpdates_MassiveCacheTB(MassiveCache: String;
                                                       var Error: Boolean;
                                                       var MessageError: String): TJSONValue;
begin

end;

function TRESTDWDriverBase.ProcessMassiveSQLCache(MassiveSQLCache: string;
                                                  var Error: Boolean;
                                                  var MessageError: string): TJSONValue;
Var
 vTempQuery        : TRESTDWQuery;
 vStringStream     : TMemoryStream;
 vStateResource    : Boolean;
 vResultReflection : String;

 Function LoadMassive(Massive : String; Var Query : TRESTDWQuery) : Boolean;
 Var
  X, A, I         : Integer;
  vMassiveSQLMode : TMassiveSQLMode;
  vSQL,
  vParamsString,
  vBookmark,
  vParamName      : String;
  vBinaryRequest  : Boolean;
  vDWParams       : TRESTDWParams;
  bJsonValueB     : TRESTDWJSONInterfaceBase;
  bJsonValue      : TRESTDWJSONInterfaceObject;
  bJsonArray      : TRESTDWJSONInterfaceArray;
 Begin
  bJsonValue     := TRESTDWJSONInterfaceObject.Create(MassiveSQLCache);
  bJsonArray     := TRESTDWJSONInterfaceArray(bJsonValue);
  Result         := False;
  Try
   For X := 0 To bJsonArray.ElementCount -1 Do
    Begin
     bJsonValueB := bJsonArray.GetObject(X);//bJsonArray.get(X);
     If Not connInTransaction Then
       connStartTransaction;
     vDWParams          := TRESTDWParams.Create;
     vDWParams.Encoding := Encoding;
     Try
      vMassiveSQLMode := MassiveSQLMode(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[0].Value);
      vSQL            := StringReplace(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}), #$B, ' ', [rfReplaceAll]);
      vParamsString   := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[2].Value{$IFDEF FPC}, csUndefined{$ENDIF});
      vBookmark       := TRESTDWJSONInterfaceObject(bJsonValueB).pairs[3].Value;
      vBinaryRequest  := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[4].Value);
      If Not vBinaryRequest Then
       vDWParams.FromJSON(vParamsString)
      Else
       vDWParams.FromJSON(vParamsString, vBinaryRequest);
      Query.Close;
      Case vMassiveSQLMode Of
       msqlQuery    :; //TODO
       msqlExecute  : Begin
                       Query.SQL.Text := vSQL;
                       If vDWParams.Count > 0 Then
                        Begin
                           Try
                           // vTempQuery.Prepare;
                           Except
                           End;
                           For I := 0 To vDWParams.Count -1 Do
                            Begin
                             If vTempQuery.ParamCount > I Then
                              Begin
                               vParamName := Copy(StringReplace(vDWParams[I].ParamName, ',', '', []), 1, Length(vDWParams[I].ParamName));
                               A          := vTempQuery.GetParamIndex(vParamName);
                               If A > -1 Then
                                Begin
                                 If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       {$IF CompilerVersion > 22}{$IFEND}DB.ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString]    Then
                                  Begin
                                   if not vDWParams[I].IsNull then begin
                                     If vTempQuery.Params[A].Size > 0 Then
                                      vTempQuery.Params[A].Value := Copy(vDWParams[I].Value, 1, vTempQuery.Params[A].Size)
                                     Else
                                      vTempQuery.Params[A].Value := vDWParams[I].Value;
                                   end
                                   else begin
                                     vTempQuery.Params[A].Clear;
                                   end;
                                  End
                                 Else
                                  Begin
                                   If vTempQuery.Params[A].DataType in [ftUnknown] Then
                                    Begin
                                     If Not (ObjectValueToFieldType(vDWParams[I].ObjectValue) in [ftUnknown]) Then
                                      vTempQuery.Params[A].DataType := ObjectValueToFieldType(vDWParams[I].ObjectValue)
                                     Else
                                      vTempQuery.Params[A].DataType := ftString;
                                    End;
                                   If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                                    Begin
                                     If (Not (vDWParams[I].isNull)) Then
                                      Begin
                                       If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                                        vTempQuery.Params[A].AsLargeInt := StrToInt64(vDWParams[I].Value)
                                       Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                                        vTempQuery.Params[A].AsSmallInt := StrToInt(vDWParams[I].Value)
                                       Else
                                        vTempQuery.Params[A].AsInteger  := StrToInt(vDWParams[I].Value);
                                      End
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End
                                   Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle {$IFEND}{$ENDIF}] Then
                                    Begin
                                     If (Not (vDWParams[I].IsNull)) Then
                                      vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(vDWParams[I].Value))
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End
                                   Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                                    Begin
                                     If (Not (vDWParams[I].IsNull)) Then
                                      Begin
                                       If vTempQuery.Params[A].DataType = ftDate Then
                                        vTempQuery.Params[A].AsDate     := vDWParams[I].AsDateTime
                                       Else If vTempQuery.Params[A].DataType = ftTime Then
                                        vTempQuery.Params[A].AsTime     := vDWParams[I].AsDateTime
                                       Else
                                        vTempQuery.Params[A].AsDateTime := vDWParams[I].AsDateTime;
                                      End
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End  //Tratar Blobs de Parametros...
                                   Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                             ftGraphic, ftOraBlob, ftOraClob] Then
                                    Begin
                                     If Not Assigned(vStringStream) Then
                                      vStringStream  := TMemoryStream.Create;
                                     Try
                                      vDWParams[I].SaveToStream(TStream(vStringStream));
                                      vStringStream.Position := 0;
                                      If vStringStream.Size > 0 Then
                                       vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                                     Finally
                                      If Assigned(vStringStream) Then
                                       FreeAndNil(vStringStream);
                                     End;
                                    End
                                   Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                             ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                             ftString,    ftWideString,
                                                                             ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                                     {$IF CompilerVersion > 21}
                                                                                     , ftWideMemo
                                                                                     {$IFEND}
                                                                                    {$ENDIF}]    Then
                                    Begin
                                     if not vDWParams[I].IsNull then
                                      vTempQuery.Params[A].AsString := vDWParams[I].Value
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End
                                   Else
                                    vTempQuery.Params[A].Value    := vDWParams[I].Value;
                                  End;
                                End;
                              End
                             Else
                              Break;
                            End;
                        End;
                       Query.ExecSQL;
                      End;
      End;
     Finally
      Query.SQL.Clear;
      FreeAndNil(bJsonValueB);
      FreeAndNil(vDWParams);
     End;
    End;
   If Not Error Then
    Begin
     Try
      Result        := True;
      If connInTransaction Then
       Begin
        connCommit;
       End;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
         connRollback;
        MessageError := E.Message;
       End;
     End;
    End;
  Finally
   FreeAndNil(bJsonValue);
  End;
 End;
Begin
 Inherited;
 vResultReflection := '';
 Result     := Nil;
 vStringStream := Nil;
 Try
  Error      := False;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  vTempQuery.SQL.Clear;
  LoadMassive(MassiveSQLCache, vTempQuery);
  If Result = Nil Then
   Result         := TJSONValue.Create;
  If (vResultReflection <> '') Then
   Begin
    Result.Encoding := Encoding;
    Result.Encoded  := EncodeStringsJSON;
    Result.SetValue('[' + vResultReflection + ']');
    Error         := False;
   End
  Else
   Result.SetValue('[]');
  If Not vStateResource Then
   Disconect;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
end;

function TRESTDWDriverBase.ExecuteCommand(SQL: String;
                                          var Error: Boolean;
                                          var MessageError: String;
                                          var BinaryBlob: TMemoryStream;
                                          var RowsAffected: Integer;
                                          Execute: Boolean;
                                          BinaryEvent: Boolean;
                                          MetaData: Boolean;
                                          BinaryCompatibleMode: Boolean): string;
begin
  Result := ExecuteCommand(SQL,nil,Error,MessageError,BinaryBlob,RowsAffected,
                           Execute,BinaryEvent,MetaData,BinaryCompatibleMode);
end;

function TRESTDWDriverBase.ExecuteCommand(SQL: String;
                                          Params: TRESTDWParams;
                                          var Error: Boolean;
                                          var MessageError: String;
                                          var BinaryBlob: TMemoryStream;
                                          var RowsAffected: Integer;
                                          Execute: Boolean;
                                          BinaryEvent: Boolean;
                                          MetaData: Boolean;
                                          BinaryCompatibleMode: Boolean): string;
Var
 vTempQuery     : TRESTDWQuery;
 vDataSet       : TDataSet;
 A, I           : Integer;
 vParamName     : String;
 vStateResource : Boolean;
 vStringStream  : TMemoryStream;
 aResult        : TJSONValue;
Begin
 Inherited;
 Error  := False;
 Result := '';
 vStringStream := Nil;
 aResult := TJSONValue.Create;
 vTempQuery := getQuery;
 vDataSet := TDataSet(vTempQuery.Owner);
 Try
  vStateResource := isConnected;
  If Not isConnected Then
    Connect;

  If Not connInTransaction Then
    connStartTransaction;

  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Params <> Nil Then
   Begin
    Try
      vTempQuery.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If (vTempQuery.ParamCount > I) And (Not (Params[I].IsNull)) Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := vTempQuery.GetParamIndex(vParamName);
        If A > -1 Then
         Begin
          If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                ftString,    ftWideString]    Then
           Begin
            If vTempQuery.Params[A].Size > 0 Then
             vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
            Else
             vTempQuery.Params[A].Value := Params[I].Value;
           End
          Else
           Begin
            If vTempQuery.Params[A].DataType in [ftUnknown] Then
             Begin
              If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
               vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
              Else
               vTempQuery.Params[A].DataType := ftString;
             End;
            If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               Begin
                If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                 vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                 vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                Else
                 vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
               End
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle {$IFEND}{$ENDIF}] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               Begin
                If vTempQuery.Params[A].DataType = ftDate Then
                 vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
                Else If vTempQuery.Params[A].DataType = ftTime Then
                 vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
                Else
                 vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
                vTempQuery.Params[A].AsDateTime  := Params[I].AsDateTime
               End
              Else
               vTempQuery.Params[A].Clear;
             End  //Tratar Blobs de Parametros...
            Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                      ftGraphic, ftOraBlob, ftOraClob] Then
             Begin
              If (Not (Params[I].IsNull)) Then
              Begin
              If Not Assigned(vStringStream) Then
               vStringStream  := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(TStream(vStringStream));
               vStringStream.Position := 0;
               If vStringStream.Size > 0 Then
                vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
              Finally
               If Assigned(vStringStream) Then
                FreeAndNil(vStringStream);
              End;
             End
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                      ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                      ftString,    ftWideString,
                                                      ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                              {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                              {$IFEND}
                                                             {$ENDIF}]    Then
             Begin
              If (Trim(Params[I].Value) <> '') Then
               vTempQuery.Params[A].AsString := Params[I].Value
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [ftGuid] Then
             Begin
              If (Not (Params[I].IsNull)) Then
                vTempQuery.Params[A].Value := Variant(StringToGUID(Params[I].AsString))
              Else
                vTempQuery.Params[A].Clear;
             End
            Else
             vTempQuery.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else If (vTempQuery.ParamCount <= I) Then
       Break;
     End;
   End;
  If Not Execute Then
   Begin
   If Assigned(Self.OnQueryBeforeOpen) Then
     Self.OnQueryBeforeOpen(vDataSet, Params);
    If Not(BinaryCompatibleMode) Then
     Begin
      vTempQuery.Open;
      vTempQuery.FetchAll;
     End;
     If connInTransaction Then
       connCommit;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
    aResult.Encoding := Encoding;
    Try
     If Not BinaryEvent Then
      Begin
       aResult.Utf8SpecialChars := True;
       aResult.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Result := aResult.ToJSON;
      End
     Else If Not BinaryCompatibleMode Then
      Begin
       If Not Assigned(BinaryBlob) Then
        BinaryBlob := TMemoryStream.Create;
       Try
        vTempQuery.SaveToStream(BinaryBlob);
        BinaryBlob.Position := 0;
       Finally
       End;
      End
     Else
      TRESTDWClientSQLBase.SaveToStream(TDataSet(vTempQuery.Owner), BinaryBlob);
    Finally
    End;
   End
  Else
   Begin
    If Assigned(Self.OnQueryBeforeOpen) Then
      Self.OnQueryBeforeOpen(vDataSet, Params);
    vTempQuery.ExecSQL;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
     If connInTransaction Then
       connCommit;;
    aResult.SetValue('COMMANDOK');
    Result := aResult.ToJSON;
   End;
   if not vStateResource then
     Disconect
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     If aResult = Nil Then
      aResult := TJSONValue.Create;
     aResult.Encoded := True;
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result := aResult.ToJSON;
     If connInTransaction Then
       connRollback;

     If Assigned(Self.OnQueryException) Then
      Self.OnQueryException(vDataSet, Params, E.Message);
    Except
    End;
    Disconect;
   End;
 End;
 FreeAndNil(aResult);
 RowsAffected := vTempQuery.RowsAffected;
 vTempQuery.Close;
 vTempQuery.Free;
end;

function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
                                            var Error: Boolean;
                                            var MessageError: String;
                                            var BinaryBlob: TMemoryStream;
                                            var RowsAffected: Integer;
                                            BinaryEvent: Boolean;
                                            MetaData: Boolean;
                                            BinaryCompatibleMode: Boolean): String;
begin
  ExecuteCommandTB(Tablename,nil,Error,MessageError,BinaryBlob,RowsAffected,
                   BinaryEvent,MetaData,BinaryCompatibleMode);
end;

function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
                                            Params: TRESTDWParams;
                                            var Error: Boolean;
                                            var MessageError: String;
                                            var BinaryBlob: TMemoryStream;
                                            var RowsAffected: Integer;
                                            BinaryEvent: Boolean; MetaData: Boolean;
                                            BinaryCompatibleMode: Boolean): String;
var
  vTempQuery     : TRESTDWTable;
  vDataset       : TDataset;
  aResult        : TJSONValue;
  vStateResource : Boolean;
begin
  {$IFNDEF FPC}Inherited;{$ENDIF}
  Error  := False;
  aResult := TJSONValue.Create;
  vTempQuery := getTable;
  vDataset := TDataset(vTempQuery.Owner);
  try
    vStateResource := isConnected;
    if not vStateResource then
      Connect;

    vTempQuery.TableName    := TableName;
    if Assigned(Self.OnTableBeforeOpen) then
      Self.OnTableBeforeOpen(vDataset, Params, TableName);

    vTempQuery.Open;

    if aResult = nil Then
      aResult := TJSONValue.Create;

    aResult.Encoded         := EncodeStringsJSON;
    aResult.Encoding        := Encoding;
    {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
    {$ENDIF}
    try
      if Not BinaryEvent then begin
        aResult.Utf8SpecialChars := True;
        aResult.LoadFromDataset('RESULTDATA', TDataset(vTempQuery.Owner), EncodeStringsJSON);
        Result := aResult.ToJson;
      end
      else if not BinaryCompatibleMode then begin
        if not Assigned(BinaryBlob) then
          BinaryBlob := TMemoryStream.Create;
        try
          vTempQuery.SaveToStream(BinaryBlob);
          BinaryBlob.Position := 0;
        finally

        end;
      end
      else
        TRESTDWClientSQLBase.SaveToStream(TDataset(vTempQuery.Owner), BinaryBlob);

      if not vStateResource then
        Connect;

      if not vStateResource then
        Disconect;
    finally
      FreeAndNil(aResult);
    end;
  except
    on E : Exception do begin
      try
        Error                   := True;
        MessageError            := E.Message;
        if aResult = Nil then
          aResult := TJSONValue.Create;

        aResult.Encoded         := True;
        aResult.Encoding        := Encoding;
        {$IFDEF FPC}
          aResult.DatabaseCharSet := DatabaseCharSet;
        {$ENDIF}
        aResult.SetValue(GetPairJSONStr('NOK', MessageError));
        Result := aResult.ToJson;

        FreeAndNil(aResult);
        connRollback;
        Disconect;
      except

      end;
   end;
 end;

 vTempQuery.Close;
 vTempQuery.Free;
end;

procedure TRESTDWDriverBase.ExecuteProcedure(ProcName: String;
                                             Params: TRESTDWParams;
                                             var Error: Boolean;
                                             var MessageError: String);
var
  A, I            : Integer;
  vParamName      : String;
  vStateResource  : Boolean;
  vTempStoredProc : TRESTDWStoreProc;
begin
  inherited;
  Error  := False;
  vTempStoredProc := getStoreProc;
  vStateResource := isConnected;
  if not vStateResource Then
    Connect;

  if not connInTransaction then
    connStartTransaction;

  try
    vTempStoredProc.StoredProcName := ProcName;
    if Params <> Nil then begin
      try
        vTempStoredProc.Prepare;
      except

      end;

      for I := 0 To Params.Count -1 do begin
        if vTempStoredProc.ParamCount > I then begin
          vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
          A          := vTempStoredProc.GetParamIndex(vParamName);
          if A > -1 then begin
            if vTempStoredProc.Params[A].DataType in [ftFixedChar,ftFixedWideChar,ftString,ftWideString] then begin
              if vTempStoredProc.Params[A].Size > 0 then
                vTempStoredProc.Params[A].Value := Copy(Params[I].Value, 1, vTempStoredProc.Params[A].Size)
              else
                vTempStoredProc.Params[A].Value := Params[I].Value;
            end
            else begin
              if vTempStoredProc.Params[A].DataType in [ftUnknown] Then
                 vTempStoredProc.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue);
              vTempStoredProc.Params[A].Value    := Params[I].Value;
            end;
          end;
        end
        else
          Break;
      end;
    end;
    vTempStoredProc.ExecProc;

    connCommit;

    if not vStateResource Then
      Disconect;
  except
    on E : Exception do begin
      try
        if connInTransaction Then
          connRollback;
      except

      end;
      Error := True;
      MessageError := E.Message;
      Disconect;
   end;
 end;
 vTempStoredProc.Free;
end;

procedure TRESTDWDriverBase.ExecuteProcedurePure(ProcName: String;
                                                 var Error: Boolean;
                                                 var MessageError: String);
begin
  ExecuteProcedure(ProcName,nil,Error,MessageError);
end;

procedure TRESTDWDriverBase.GetTableNames(var TableNames: TStringList;
                                          var Error: Boolean;
                                          var MessageError: String);
var
  vStateResource : Boolean;
  connType : TRESTDWDatabaseType;
  qry : TRESTDWQuery;
  vSchema : string;
  fdPos : integer;
begin
  if not Assigned(TableNames) then
    TableNames := TStringList.Create;

  vSchema := '';
{
  if Pos('.', vTable) > 0 then begin
    vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
    Delete(vTable, InitStrPos, Pos('.', vTable));
  end;
}
  connType := getConectionType;
  try
    vStateResource := isConnected;
    if not vStateResource Then
      Connect;

    fdPos := 0;
    qry := getQuery;
    try
      if connType = dbtFirebird then begin
        qry.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS');
        qry.SQL.Add('ORDER BY RDB$RELATION_NAME');
        qry.Open;
      end
      else if connType = dbtInterbase then begin
        qry.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS');
        qry.SQL.Add('ORDER BY RDB$RELATION_NAME');
        qry.Open;
      end
      else if connType = dbtMySQL then begin
        qry.SQL.Add('SHOW TABLES');
        qry.Open;
      end
      else if connType = dbtPostgreSQL then begin
        qry.SQL.Add('SELECT N.NSPNAME || ''.'' || C.RELNAME');
        qry.SQL.Add('FROM PG_CATALOG.PG_CLASS C');
        qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = C.RELNAMESPACE');
        qry.SQL.Add('WHERE C.RELKIND = ''r'' and N.NSPNAME <> ''information_schema'' and ');
        qry.SQL.Add('      N.NSPNAME <> ''pg_catalog'' and N.NSPNAME <> ''dbo'' and ');
        qry.SQL.Add('      N.NSPNAME <> ''sys'' and SUBSTR(C.RELNAME, 1, 3) <> ''pg_'' and');
        if vSchema <> '' then
          qry.SQL.Add(' and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
        qry.Open;
      end
      else if connType = dbtSQLLite then begin
        qry.SQL.Add('SELECT name FROM sqlite_master');
        qry.SQL.Add('WHERE type=''table''');
        qry.Open;
      end
      else if connType = dbtMsSQL then begin
        qry.SQL.Add('select concat(user_name(uid),''.'',name)');
        qry.SQL.Add('from sysobjects');
        qry.SQL.Add('where type in (''U'',''V'')');
        qry.Open;
      end
      else if connType = dbtOracle then begin
        qry.SQL.Add('SELECT sys_context(''userenv'',''current_schema'') || ''.'' || table_name');
        qry.SQL.Add('FROM USER_CATALOG');
        qry.SQL.Add('WHERE TABLE_TYPE <> ''SEQUENCE''');
        qry.Open;
      end;

      while not qry.Eof do begin
        TableNames.Add(qry.Fields[fdPos].AsString);
        qry.Next;
      end;
    finally
      FreeAndNil(qry);
    end;

    if not vStateResource Then
      Disconect;
  except
    on E : Exception do begin
      Error          := True;
      MessageError   := E.Message;
      Disconect;
    end;
  end;
end;

procedure TRESTDWDriverBase.GetFieldNames(TableName: String;
                                          var FieldNames: TStringList;
                                          var Error: Boolean;
                                          var MessageError: String);
var
  vStateResource : Boolean;
  connType : TRESTDWDatabaseType;
  qry : TRESTDWQuery;
  vTable,vSchema : string;
  fPos : integer;
begin
  if not Assigned(FieldNames) then
    FieldNames := TStringList.Create;

  vSchema := '';
  vTable := TableName;
  if Pos('.', vTable) > 0 then begin
    vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
    Delete(vTable, InitStrPos, Pos('.', vTable));
  end;

  connType := getConectionType;
  try
    vStateResource := isConnected;
    if not vStateResource Then
      Connect;

    fPos := 0;

    qry := getQuery;
    try
      if connType = dbtFirebird then begin
        qry.SQL.Add('SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS ');
        qry.SQL.Add('WHERE RDB$RELATION_NAME='+QuotedStr(UpperCase(vTable)));
        qry.Open;
      end
      else if connType = dbtInterbase then begin
        qry.SQL.Add('SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS ');
        qry.SQL.Add('WHERE RDB$RELATION_NAME='+QuotedStr(UpperCase(vTable)));
        qry.Open;
      end
      else if connType = dbtMySQL then begin
        qry.SQL.Add('SHOW COLUMNS FROM '+vTable);
        qry.Open;
      end
      else if connType = dbtPostgreSQL then begin
        qry.SQL.Add('SELECT A.ATTNAME');
        qry.SQL.Add('FROM PG_CATALOG.PG_CLASS C');
        qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = C.RELNAMESPACE');
        qry.SQL.Add('INNER JOIN PG_CATALOG.PG_ATTRIBUTE A ON A.ATTRELID = C.OID');
        qry.SQL.Add('WHERE A.ATTNUM > 0 AND NOT A.ATTISDROPPED AND');
        qry.SQL.Add('      lower(C.RELNAME) = '+QuotedStr(LowerCase(vTable)));
        if vSchema <> '' then
          qry.SQL.Add('    and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
        qry.Open;
      end
      else if connType = dbtSQLLite then begin
        fPos := 1;
        qry.SQL.Add('PRAGMA table_info('+vTable+')');
        qry.Open;
      end
      else if connType = dbtMsSQL then begin
        qry.SQL.Add('select c.name');
        qry.SQL.Add('from syscolumns c');
        qry.SQL.Add('join sysobjects o on c.id=o.id');
        qry.SQL.Add('where c.id=object_id('+QuotedStr(vTable)+')');
        if vSchema <> '' then
          qry.SQL.Add('      and user_name(o.uid) = '+QuotedStr(vSchema));
        qry.Open;
      end
      else if connType = dbtOracle then begin
        qry.SQL.Add('SELECT COLUMN_NAME');
        qry.SQL.Add('FROM ALL_TAB_COLUMNS');
        qry.SQL.Add('WHERE upper(TABLE_NAME) = '+QuotedStr(UpperCase(vTable)));
        if vSchema <> '' then
          qry.SQL.Add('      and upper(OWNER) = '+QuotedStr(UpperCase(vSchema)));
        qry.Open;
      end;

      while not qry.Eof do begin
        FieldNames.Add(qry.Fields[fPos].AsString);
        qry.Next;
      end;
    finally
      FreeAndNil(qry);
    end;

    if not vStateResource Then
      Disconect;
  except
    on E : Exception do begin
      Error          := True;
      MessageError   := E.Message;
      Disconect;
    end;
  end;
end;

procedure TRESTDWDriverBase.GetKeyFieldNames(TableName: String;
                                             var FieldNames: TStringList;
                                             var Error: Boolean;
                                             var MessageError: String);
var
  vStateResource : Boolean;
  connType : TRESTDWDatabaseType;
  qry : TRESTDWQuery;
  vTable,vSchema : string;
begin
  if not Assigned(FieldNames) then
    FieldNames := TStringList.Create;

  vSchema := '';
  vTable := TableName;
  if Pos('.', vTable) > 0 then begin
    vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
    Delete(vTable, InitStrPos, Pos('.', vTable));
  end;

  connType := getConectionType;
  try
    vStateResource := isConnected;
    if not vStateResource Then
      Connect;

    qry := getQuery;
    try
      if connType = dbtFirebird then begin
        qry.SQL.Add('SELECT S.RDB$FIELD_NAME');
        qry.SQL.Add('FROM RDB$RELATION_CONSTRAINTS C, RDB$INDEX_SEGMENTS S');
        qry.SQL.Add('WHERE C.RDB$RELATION_NAME = '+QuotedStr(AnsiUpperCase(vTable))+' AND');
        qry.SQL.Add('      C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' AND');
        qry.SQL.Add('      S.RDB$INDEX_NAME = C.RDB$INDEX_NAME');
        qry.Open;

        while not qry.Eof do begin
          FieldNames.Add(qry.FieldByName('RDB$FIELD_NAME').AsString);
          qry.Next;
        end;
      end
      else if connType = dbtInterbase then begin
        qry.SQL.Add('SELECT S.RDB$FIELD_NAME');
        qry.SQL.Add('FROM RDB$RELATION_CONSTRAINTS C, RDB$INDEX_SEGMENTS S');
        qry.SQL.Add('WHERE C.RDB$RELATION_NAME = '+QuotedStr(AnsiUpperCase(vTable))+' AND');
        qry.SQL.Add('      C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' AND');
        qry.SQL.Add('      S.RDB$INDEX_NAME = C.RDB$INDEX_NAME');
        qry.Open;

        while not qry.Eof do begin
          FieldNames.Add(qry.FieldByName('RDB$FIELD_NAME').AsString);
          qry.Next;
        end;
      end
      else if connType = dbtMySQL then begin
        qry.SQL.Add('SHOW INDEX FROM '+vTable);
        qry.Open;

        while not qry.Eof do begin
          if (Pos('PRIMARY',UpperCase(qry.FieldByName('KEY_NAME').AsString)) > 0) then
            FieldNames.Add(qry.FieldByName('COLUMN_NAME').AsString);
          qry.Next;
        end;
      end
      else if connType = dbtPostgreSQL then begin
        qry.SQL.Add('SELECT A.ATTNAME');
        qry.SQL.Add('FROM PG_CATALOG.PG_INDEX I');
        qry.SQL.Add('INNER JOIN PG_CATALOG.PG_CLASS TC ON TC.OID = I.INDRELID');
        qry.SQL.Add('INNER JOIN PG_CATALOG.PG_CLASS IC ON IC.OID = I.INDEXRELID');
        qry.SQL.Add('INNER JOIN PG_CATALOG.PG_ATTRIBUTE A ON A.ATTRELID = I.INDRELID AND');
        qry.SQL.Add('           A.ATTNUM = ANY(I.INDKEY)');
        qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = TC.RELNAMESPACE');
        qry.SQL.Add('WHERE lower(TC.RELNAME) = '+QuotedStr(LowerCase(vTable))+' and ');
        qry.SQL.Add('      I.INDISPRIMARY ');
        if vSchema <> '' then
          qry.SQL.Add('  AND lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
        qry.Open;

        while not qry.Eof do begin
          FieldNames.Add(qry.FieldByName('ATTNAME').AsString);
          qry.Next;
        end;
      end
      else if connType = dbtSQLLite then begin
        qry.SQL.Add('PRAGMA table_info('+vTable+')');
        qry.Open;

        while not qry.Eof do begin
          if qry.FieldByName('pk').AsInteger > 0 then
            FieldNames.Add(qry.FieldByName('name').AsString);
          qry.Next;
        end;
      end;
    finally
      FreeAndNil(qry);
    end;

    if not vStateResource Then
      Disconect;
  except
    on E : Exception do begin
      Error          := True;
      MessageError   := E.Message;
      Disconect;
    end;
  end;
end;

procedure TRESTDWDriverBase.GetProcNames(var ProcNames: TStringList;
                                         var Error: Boolean;
                                         var MessageError: String);
var
  vStateResource : Boolean;
  connType : TRESTDWDatabaseType;
  qry : TRESTDWQuery;
  vSchema : string;
  fPos : integer;
begin
  if not Assigned(ProcNames) then
    ProcNames := TStringList.Create;

  vSchema := '';

  connType := getConectionType;
  try
    vStateResource := isConnected;
    if not vStateResource Then
      Connect;

    fPos := 0;

    qry := getQuery;
    try
      if connType = dbtFirebird then begin
        qry.SQL.Add('SELECT RDB$PROCEDURE_NAME FROM RDB$PROCEDURES');
        qry.Open;
      end
      else if connType = dbtInterbase then begin
        qry.SQL.Add('SELECT RDB$PROCEDURE_NAME FROM RDB$PROCEDURES');
        qry.Open;
      end
      else if connType = dbtMySQL then begin
        fPos := 1; // coluna name
        qry.SQL.Add('SHOW PROCEDURE STATUS');
        qry.SQL.Add('WHERE db = DATABASE() AND type = ''PROCEDURE''');
        qry.Open;
      end
      else if connType = dbtPostgreSQL then begin
        qry.SQL.Add('SELECT N.NSPNAME || ''.'' || P.PRONAME FROM PG_CATALOG.PG_PROC P');
        qry.SQL.ADD('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = P.PRONAMESPACE');
        qry.SQL.Add('WHERE P.PROARGNAMES IS NOT NULL');
        if vSchema <> '' then
          qry.SQL.Add('    and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
        qry.Open;
      end
      else if connType = dbtSQLLite then begin
        // nao existe procedures
      end
      else if connType = dbtMsSQL then begin
        qry.SQL.Add('select concat(user_name(uid),''.'',name)');
        qry.SQL.Add('from sysobjects');
        qry.SQL.Add('where type in (''P'',''FN'',''IF'',''TF'')');
        qry.Open;
      end
      else if connType = dbtOracle then begin
        qry.SQL.Add('SELECT case ');
        qry.SQL.Add('         when PROCEDURE_NAME is null then OBJECT_NAME');
        qry.SQL.Add('              ELSE OBJECT_NAME || ''.'' || PROCEDURE_NAME');
        qry.SQL.Add('       end AS procedure_name');
        qry.SQL.Add('FROM USER_PROCEDURES');
        qry.Open;
      end;

      while not qry.Eof do begin
        ProcNames.Add(qry.Fields[fPos].AsString);
        qry.Next;
      end;
    finally
      FreeAndNil(qry);
    end;

    if not vStateResource Then
      Disconect;
  except
    on E : Exception do begin
      Error          := True;
      MessageError   := E.Message;
      Disconect;
    end;
  end;
end;

procedure TRESTDWDriverBase.GetProcParams(ProcName: String;
                                          var ParamNames: TStringList;
                                          var Error: Boolean;
                                          var MessageError: String);
var
  vStateResource : Boolean;
  connType : TRESTDWDatabaseType;
  qry : TRESTDWQuery;
  vProc,vSchema : string;

  vFieldType : string;
  vSize, vPrecision : integer;

  procedure convertFB_IBTypes;
  begin
    vFieldType := 'ftUnknown';
    vSize := 0;
    vPrecision := 0;
    case qry.FieldByName('rdb$field_type').AsInteger of
      007 : begin
            vFieldType := 'ftSmallint';
            if qry.FieldByName('rdb$field_sub_type').AsInteger > 0 then
              vFieldType := 'ftFloat';
      end;
      008 : begin
            vFieldType := 'ftInteger';
            if qry.FieldByName('rdb$field_sub_type').AsInteger > 0 then
              vFieldType := 'ftFloat';
      end;
      009 : vFieldType := 'ftLargeint';
      010 : vFieldType := 'ftFloat';
      011 : vFieldType := 'ftFloat';
      012 : vFieldType := 'ftDateTime';
      013 : vFieldType := 'ftTime';
      014 : vFieldType := 'ftFixedChar';
      016 : begin
            vFieldType := 'ftLargeint';
            if qry.FieldByName('rdb$field_sub_type').AsInteger > 0 then
              vFieldType := 'ftFloat';
      end;
      027 : vFieldType := 'ftFloat';
      035 : vFieldType := 'ftTimeStamp';
      037 : vFieldType := 'ftString';
      040 : vFieldType := 'ftString';
      261 : begin
        vFieldType := 'ftBlob';
        if qry.FieldByName('rdb$field_sub_type').AsInteger = 1 then
          vFieldType := 'ftMemo';
      end;
    end;

    if qry.FieldByName('rdb$field_type').AsInteger in [14,37,40] then begin
      vSize := qry.FieldByName('rdb$field_length').AsInteger;
      // field com charset e colation
      if (qry.FieldByName('rdb$character_length').AsInteger > 0) and
         (qry.FieldByName('rdb$character_length').AsInteger < vSize) then
        vSize := qry.FieldByName('rdb$character_length').AsInteger;
    end
    else if qry.FieldByName('rdb$field_type').AsInteger = 27 then begin
      vSize := qry.FieldByName('rdb$field_precision').AsInteger;

      if (qry.FieldByName('rdb$field_scale').AsInteger < 0) then begin
        vSize := 15;
        if (qry.FieldByName('rdb$field_precision').AsInteger > 0) then
          vSize := qry.FieldByName('rdb$field_precision').AsInteger;
        vPrecision := Abs(qry.FieldByName('rdb$field_scale').AsInteger);
      end;
    end
    else if (qry.FieldByName('rdb$field_type').AsInteger in [7,8,16]) and
            (qry.FieldByName('rdb$field_sub_type').AsInteger > 0) then begin
      vSize := qry.FieldByName('rdb$field_precision').AsInteger;

      if (qry.FieldByName('rdb$field_scale').AsInteger < 0) then begin
        vSize := 15;
        if (qry.FieldByName('rdb$field_precision').AsInteger > 0) then
          vSize := qry.FieldByName('rdb$field_precision').AsInteger;
        vPrecision := Abs(qry.FieldByName('rdb$field_scale').AsInteger);
      end;
    end;
  end;

  procedure convertMySQLTypes;
  var
    sAux1 : string;
  begin
    vFieldType := 'ftUnknown';
    vSize := 0;
    vPrecision := 0;

    sAux1 := LowerCase(qry.FieldByName('data_type').AsString);
    if SameText(sAux1,'integer') or SameText(sAux1,'int') then begin
      vFieldType := 'ftInteger';
    end
    else if SameText(sAux1,'smallint') or SameText(sAux1,'tinyint') or
            SameText(sAux1,'mediumint') or SameText(sAux1,'bit') then begin
      vFieldType := 'ftSmallint';
    end
    else if SameText(sAux1,'longint') or SameText(sAux1,'bigint') then begin
      vFieldType := 'ftLargeint';
    end
    else if SameText(sAux1,'real') or SameText(sAux1,'decimal') or
            SameText(sAux1,'numeric') or SameText(sAux1,'float') or
            SameText(sAux1,'double') or SameText(sAux1,'double precision') then begin
      vFieldType := 'ftFloat';
      vSize := qry.FieldByName('numeric_precision').AsInteger;
      vPrecision := qry.FieldByName('numeric_scale').AsInteger;
    end
    else if SameText(sAux1,'varchar') then begin
      vFieldType := 'ftString';
      vSize := qry.FieldByName('character_maximum_length').AsInteger;
      if vSize >= 32767 then begin
        vFieldType := 'ftMemo';
        vSize := 0;
      end;
    end
    else if SameText(sAux1,'char') then begin
      vFieldType := 'ftFixedChar';
      vSize := qry.FieldByName('character_maximum_length').AsInteger;
    end
    else if SameText(sAux1,'timestamp') then begin
      vFieldType := 'ftTimeStamp';
    end
    else if SameText(sAux1,'time') then begin
      vFieldType := 'ftTime';
    end
    else if SameText(sAux1,'datetime') then begin
      vFieldType := 'ftDateTime';
    end
    else if SameText(sAux1,'date') then begin
      vFieldType := 'ftDate';
    end
    else if SameText(sAux1,'year') then begin
      vFieldType := 'ftSmallint';
    end
    else if SameText(sAux1,'blob') or SameText(sAux1,'binary') or
            SameText(sAux1,'tinyblob') or SameText(sAux1,'mediumblob') or
            SameText(sAux1,'longblob') then begin
      vFieldType := 'ftBlob';
    end
    else if SameText(sAux1,'text') or SameText(sAux1,'tinytext') or
            SameText(sAux1,'mediumtext') or SameText(sAux1,'longtext') or
            SameText(sAux1,'json') then begin
      vFieldType := 'ftMemo';
    end;
  end;

  procedure convertPostgresTypes;
  var
    sAux1 : string;
  begin
    vFieldType := 'ftUnknown';
    vSize := 0;
    vPrecision := 0;

    sAux1 := LowerCase(qry.FieldByName('data_type').AsString);
    if SameText(sAux1,'integer') or SameText(sAux1,'int') or
       (Pos('int[',sAux1) > 0) then begin
      vFieldType := 'ftInteger';
    end
    else if SameText(sAux1,'smallint') or SameText(sAux1,'tinyint') or
            SameText(sAux1,'mediumint') or SameText(sAux1,'bit') then begin
      vFieldType := 'ftSmallint';
    end
    else if (Pos('bigint',sAux1) > 0) then begin
      vFieldType := 'ftLargeint';
    end
    else if SameText(sAux1,'real') or SameText(sAux1,'decimal') or
            SameText(sAux1,'numeric') or SameText(sAux1,'float') or
            SameText(sAux1,'double') or SameText(sAux1,'double precision') then begin
      vFieldType := 'ftFloat';
      vSize := 15;
      vPrecision := 6;
    end
    else if SameText(sAux1,'varchar') or (Pos('character varying',sAux1) > 0) then begin
      vFieldType := 'ftString';
      vSize := 255;
    end
    else if SameText(sAux1,'character') or (Pos('character[',sAux1) > 0) then begin
      vFieldType := 'ftFixedChar';
      vSize := 255;
    end
    else if (Pos('timestamp',sAux1) > 0) then begin
      vFieldType := 'ftTimeStamp';
    end
    else if SameText(sAux1,'time') or (Pos('time with',sAux1) > 0) then begin
      vFieldType := 'ftTime';
    end
    else if SameText(sAux1,'date') then begin
      vFieldType := 'ftDate';
    end
    else if (Pos(sAux1,'bytea') > 0) then begin
      vFieldType := 'ftBlob';
    end
    else if (Pos(sAux1,'text') > 0) or (Pos(sAux1,'json') > 0) or
            (Pos(sAux1,'xml') > 0) then begin
      vFieldType := 'ftMemo';
    end;
  end;

begin
  // nesta funcão pode ser usado as funcoes
  // getDatabaseInfo ou isMinimumVersion
  // para trazer informacao de versao de cada banco

  if not Assigned(ParamNames) then
    ParamNames := TStringList.Create;

  vSchema := '';
  vProc := ProcName;
  if Pos('.', vProc) > 0 then begin
    vSchema := Copy(vProc, InitStrPos, Pos('.', vProc)-1);
    Delete(vProc, InitStrPos, Pos('.', vProc));
  end;

  connType := getConectionType;
  try
    vStateResource := isConnected;
    if not vStateResource Then
      Connect;

    qry := getQuery;
    try
      if connType = dbtFirebird then begin
        qry.SQL.Add('SELECT PP.RDB$PARAMETER_NAME, F.RDB$FIELD_LENGTH,');
        qry.SQL.Add('       F.RDB$FIELD_TYPE, F.RDB$FIELD_SUB_TYPE,');
        qry.SQL.Add('       F.RDB$CHARACTER_LENGTH, F.RDB$NULL_FLAG,');
        qry.SQL.Add('       F.RDB$DEFAULT_SOURCE, CS.RDB$CHARACTER_SET_NAME,');
        qry.SQL.Add('       CL.RDB$COLLATION_NAME, FD.RDB$LOWER_BOUND, FD.RDB$UPPER_BOUND');
        qry.SQL.Add('FROM RDB$PROCEDURE_PARAMETERS PP ');
        qry.SQL.Add('INNER JOIN RDB$FIELDS F ON F.RDB$FIELD_NAME = PP.RDB$FIELD_SOURCE');
        qry.SQL.Add('LEFT JOIN RDB$CHARACTER_SETS CS ON CS.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID');
        qry.SQL.Add('LEFT JOIN RDB$COLLATIONS CL ON CL.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID AND');
        qry.SQL.Add('     CL.RDB$COLLATION_ID = coalesce(F.RDB$COLLATION_ID,RF.RDB$COLLATION_ID)');
        qry.SQL.Add('LEFT JOIN RDB$FIELD_DIMENSIONS FD ON FD.RDB$FIELD_NAME = F.RDB$FIELD_NAME');
        qry.SQL.Add('WHERE PP.RDB$PROCEDURE_NAME = '+QuotedStr(UpperCase(vProc))+' AND');
        qry.SQL.Add('      PP.RDB$PARAMETER_TYPE = 0');
        qry.Open;

        while not qry.Eof do begin
          convertFB_IBTypes;
          ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                vFieldType,vSize,vPrecision]));

          qry.Next;
        end;
      end
      else if connType = dbtInterbase then begin
        qry.SQL.Add('SELECT PP.RDB$PARAMETER_NAME, F.RDB$FIELD_LENGTH,');
        qry.SQL.Add('       F.RDB$FIELD_TYPE, F.RDB$FIELD_SUB_TYPE,');
        qry.SQL.Add('       F.RDB$CHARACTER_LENGTH, F.RDB$NULL_FLAG,');
        qry.SQL.Add('       F.RDB$DEFAULT_SOURCE, CS.RDB$CHARACTER_SET_NAME,');
        qry.SQL.Add('       CL.RDB$COLLATION_NAME, FD.RDB$LOWER_BOUND, FD.RDB$UPPER_BOUND');
        qry.SQL.Add('FROM RDB$PROCEDURE_PARAMETERS PP ');
        qry.SQL.Add('INNER JOIN RDB$FIELDS F ON F.RDB$FIELD_NAME = PP.RDB$FIELD_SOURCE');
        qry.SQL.Add('LEFT JOIN RDB$CHARACTER_SETS CS ON CS.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID');
        qry.SQL.Add('LEFT JOIN RDB$COLLATIONS CL ON CL.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID AND');
        qry.SQL.Add('     CL.RDB$COLLATION_ID = coalesce(F.RDB$COLLATION_ID,RF.RDB$COLLATION_ID)');
        qry.SQL.Add('LEFT JOIN RDB$FIELD_DIMENSIONS FD ON FD.RDB$FIELD_NAME = F.RDB$FIELD_NAME');
        qry.SQL.Add('WHERE PP.RDB$PROCEDURE_NAME = '+QuotedStr(UpperCase(vProc))+' AND');
        qry.SQL.Add('      PP.RDB$PARAMETER_TYPE = 0');
        qry.Open;

        while not qry.Eof do begin
          convertFB_IBTypes;
          ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                vFieldType,vSize,vPrecision]));

          qry.Next;
        end;
      end
      else if connType = dbtMySQL then begin
        // somente mysql maior que 5
        qry.SQL.Add('SELECT parameter_name, data_type, character_maximum_length,');
        qry.SQL.Add('       character_octet_length,numeric_precision,numeric_scale,');
        qry.SQL.Add('       dtd_identifier');
        qry.SQL.Add('FROM information_schema.parameters');
        qry.SQL.Add('WHERE SPECIFIC_NAME = '+QuotedStr(vProc)+' AND');
        qry.SQL.Add('      SPECIFIC_SCHEMA = DATABASE() and');
        qry.SQL.Add('      ROUTINE_TYPE = ''PROCEDURE'' and');
        qry.SQL.Add('      PARAMETER_MODE = ''IN''');
        try
          qry.Open;
          while not qry.Eof do begin
            convertMySQLTypes;
            ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                  vFieldType,vSize,vPrecision]));

            qry.Next;
          end;
        except

        end;
      end
      else if connType = dbtPostgreSQL then begin
        qry.SQL.Add('select a.parameter_name, a.data_type');
        qry.SQL.Add('from information_schema.routines p');
        qry.SQL.Add('left join information_schema.parameters a on');
        qry.SQL.Add('          p.specific_schema = a.specific_schema and');
        qry.SQL.Add('          p.specific_name = a.specific_name');
        qry.SQL.Add('where p.routine_schema not in (''pg_catalog'', ''information_schema'') and');
        qry.SQL.Add('      p.routine_type = ''PROCEDURE'' and');
        qry.SQL.Add('      p.routine_name = '+QuotedStr(vProc)+' and');
        qry.SQL.Add('      a.parameter_name is not null and');
        qry.SQL.Add('      a.parameter_mode like ''IN%''');
        if vSchema <> '' then
          qry.SQL.Add('    and p.specific_schema = '+QuotedStr(vSchema));
        qry.SQL.Add('order by p.specific_schema, p.specific_name, p.routine_name,');
        qry.SQL.Add('         a.ordinal_position');
        try
          qry.Open;
          while not qry.Eof do begin
            convertPostgresTypes;
            ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                  vFieldType,vSize,vPrecision]));

            qry.Next;
          end;
        except

        end;
      end
      else if connType = dbtSQLLite then begin
        // sqlite nao tem procedures
      end;
    finally
      FreeAndNil(qry);
    end;

    if not vStateResource Then
      Disconect;
  except
    on E : Exception do begin
      Error          := True;
      MessageError   := E.Message;
      Disconect;
    end;
  end;
end;

function TRESTDWDriverBase.InsertMySQLReturnID(SQL: String;
                                               var Error: Boolean;
                                               var MessageError: String): integer;
begin
  Result := InsertMySQLReturnID(SQL,nil,Error,MessageError);
end;

function TRESTDWDriverBase.InsertMySQLReturnID(SQL: String;
                                               Params: TRESTDWParams;
                                               var Error: Boolean;
                                               var MessageError: String): integer;
var
  vTempQuery     : TRESTDWQuery;
  A, I           : Integer;
  vParamName     : String;
  vStringStream  : TMemoryStream;
  vStateResource : Boolean;
Begin
  Result := -1;
  Error  := False;
  vStringStream := Nil;
  if not Assigned(FConnection) then
    Exit;

  vTempQuery := getQuery;

  vStateResource := isConnected;
  if not vStateResource Then
    Connect;

  If Not connInTransaction Then
    connStartTransaction;

  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  if Params <> nil then begin
   For I := 0 To Params.Count -1 Do
    Begin
     If vTempQuery.Params.Count > I Then
      Begin
       vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
       A := vTempQuery.GetParamIndex(vParamName);
       If A > -1 Then
        Begin
         If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                               ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                              ftString,    ftWideString]    Then
          Begin
           If vTempQuery.Params[A].Size > 0 Then
            vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
           Else
            vTempQuery.Params[A].Value := Params[I].Value;
          End
         Else
          Begin
           If vTempQuery.Params[A].DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
              vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
             Else
              vTempQuery.Params[A].DataType := ftString;
            End;
           If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              Begin
               If vTempQuery.Params[A].DataType = ftSmallInt Then
                vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
               Else
                vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
              End;
            End
           Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              vTempQuery.Params[A].AsFloat  := StrToFloat(Params[I].Value);
            End
           Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              Begin
               If vTempQuery.Params[A].DataType = ftDate Then
                vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
               Else If vTempQuery.Params[A].DataType = ftTime Then
                vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
               Else
                vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
              End
             Else
              vTempQuery.Params[A].Clear
            End
           Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                     ftGraphic, ftOraBlob, ftOraClob,
                                                     ftMemo {$IFNDEF FPC}
                                                            {$IF CompilerVersion > 21}
                                                            , ftWideMemo
                                                            {$IFEND}
                                                            {$ENDIF}] Then
            Begin
             Try
              Params[I].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              If vStringStream.Size > 0 Then
               vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            vTempQuery.Params[A].Value    := Params[I].Value;
          End;
        End;
      End
     Else
      Break;
    End;
  End;

  Result := -1;
  Error  := False;
  try
    try
      vTempQuery.ExecSQL;

      Result := vTempQuery.GetInsertID;

      Error := False;

      if connInTransaction then
        connCommit;
    finally

    end;
    if not vStateResource then
      Disconect
  except
    on E : Exception do begin
      try
        Error        := True;
        MessageError := E.Message;
        Result       := -1;
        connRollback;
        Disconect;
      except

      end;
    end;
  end;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
end;

function TRESTDWDriverBase.OpenDatasets(DatasetsLine: String;
                                        var Error: Boolean;
                                        var MessageError: String;
                                        var BinaryBlob: TMemoryStream): TJSONValue;
Var
 vTempQuery      : TRESTDWQuery;
 vTempJSON       : TJSONValue;
 vJSONLine       : String;
 I, X            : Integer;
 vMetaData,
 vBinaryEvent,
 vStateResource,
 vCompatibleMode : Boolean;
 DWParams        : TRESTDWParams;
 bJsonArray      : TRESTDWJSONInterfaceArray;
 bJsonValue      : TRESTDWJSONInterfaceObject;
 vStream         : TMemoryStream;
Begin
 Inherited;
 Error           := False;
 vBinaryEvent    := False;
 vMetaData       := False;
 vCompatibleMode := False;
 bJsonArray      := Nil;
 vTempQuery      := getQuery;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;

  If Not connInTransaction Then
    connStartTransaction;

  bJsonValue  := TRESTDWJSONInterfaceObject.Create(DatasetsLine);
  For I := 0 To bJsonValue.PairCount - 1 Do
   Begin
    bJsonArray  := bJsonValue.OpenArray(I);
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vBinaryEvent    := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[2].Value);
    vMetaData       := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[3].Value);
    vCompatibleMode := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[4].Value);
    If bJsonArray.ElementCount > 1 Then
     Begin
      DWParams := TRESTDWParams.Create;
      Try
       DWParams.FromJSON(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
       For X := 0 To DWParams.Count -1 Do
        Begin
         If vTempQuery.ParamByName(DWParams[X].ParamName) <> Nil Then
          Begin
           vTempQuery.ParamByName(DWParams[X].ParamName).DataType := ObjectValueToFieldType(DWParams[X].ObjectValue);
           vTempQuery.ParamByName(DWParams[X].ParamName).Value    := DWParams[X].Value;
          End;
        End;
      Finally
       DWParams.Free;
      End;
     End;
    vTempQuery.Open;
    vTempJSON  := TJSONValue.Create;
    vTempJSON.Encoding := Encoding;
    vTempJSON.Utf8SpecialChars := True;
    If Not vBinaryEvent Then
     Begin
      vTempJSON.Utf8SpecialChars := True;
      vTempJSON.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
     End
    Else If vCompatibleMode Then
     TRESTDWClientSQLBase.SaveToStream(TDataSet(vTempQuery.Owner), vStream)
    Else
     Begin
      vStream := TMemoryStream.Create;
      Try
       vTempQuery.SaveToStream(vStream);
       vStream.Position := 0;
      Finally
      End;
     End;
    Try
     If Not vBinaryEvent Then
      Begin
       If Length(vJSONLine) = 0 Then
        vJSONLine := Format('%s', [vTempJSON.ToJSON])
       Else
        vJSONLine := vJSONLine + Format(', %s', [vTempJSON.ToJSON]);
      End
     Else
      Begin
       If Length(vJSONLine) = 0 Then
        vJSONLine := Format('{"BinaryRequest":"%s"}', [EncodeStream(vStream)])
       Else
        vJSONLine := vJSONLine + Format(', {"BinaryRequest":"%s"}', [EncodeStream(vStream)]);
       If Assigned(vStream) Then
        FreeAndNil(vStream);
      End;
    Finally
     vTempJSON.Free;
    End;
    FreeAndNil(bJsonArray);
   End;
   If connInTransaction Then
     connCommit;
   If Not vStateResource Then
    Disconect;
 Except
  On E : Exception do
   Begin
    Disconect;
    Try
     Error          := True;
     MessageError   := E.Message;
     vJSONLine      := GetPairJSONStr('NOK', MessageError);
    Except
    End;
   End;
 End;
 Result             := TJSONValue.Create;
 Result.Encoding    := Encoding;
 Result.ObjectValue := ovString;
 Try
  vJSONLine         := Format('[%s]', [vJSONLine]);
  Result.SetValue(vJSONLine, EncodeStringsJSON);
 Finally

 End;
 vTempQuery.Close;
 vTempQuery.Free;
 If bJsonValue <> Nil Then
  FreeAndNil(bJsonValue);
end;

function TRESTDWDriverBase.OpenDatasets(DatapackStream: TStream;
                                        var Error: Boolean;
                                        var MessageError: String;
                                        var BinaryBlob: TMemoryStream;
                                        aBinaryEvent: Boolean; aBinaryCompatibleMode: Boolean): TStream;
Var
 X               : Integer;
 vTempQuery      : TRESTDWQuery;
 vStateResource  : Boolean;
 DWParams        : TRESTDWParams;
 BufferOutStream,
 BufferStream,
 BufferInStream  : TRESTDWBufferBase;
 vStream         : TMemoryStream;
 vSqlStream      : TRESTDWBytes;
 vBufferStream,
 vParamsStream   : TStream;
Begin
 Inherited;
 Result          := Nil;
 Error           := False;
 BufferInStream  := TRESTDWBufferBase.Create;
 BufferOutStream := TRESTDWBufferBase.Create;
 vTempQuery      := getQuery;
 Try
  BufferInStream.LoadToStream(DatapackStream);
  vStateResource := isConnected;
  If Not vStateResource Then
    Connect;

  If Not connInTransaction Then
    connStartTransaction;

  While Not BufferInStream.Eof Do
   Begin
    BufferStream  := Nil;
    vBufferStream := BufferInStream.ReadStream;
    Try
     If Not Assigned(vBufferStream) Then
      Continue;
     BufferStream := TRESTDWBufferBase.Create;
     BufferStream.LoadToStream(vBufferStream);
     vSqlStream    := BufferStream.ReadBytes;
     vParamsStream := TMemoryStream(BufferStream.ReadStream);
    Finally
     If Assigned(BufferStream)  Then
      FreeAndNil(BufferStream);
     If Assigned(vBufferStream) Then
      FreeAndNil(vBufferStream);
    End;
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(BytesToString(vSqlStream));
    SetLength(vSqlStream, 0);
    DWParams := TRESTDWParams.Create;
    Try
     DWParams.LoadFromStream(vParamsStream);
     For X := 0 To DWParams.Count - 1 Do
      Begin
       If vTempQuery.ParamByName(DWParams[X].ParamName) <> Nil Then
        Begin
         vTempQuery.ParamByName(DWParams[X].ParamName).DataType := ObjectValueToFieldType(DWParams[X].ObjectValue);
         vTempQuery.ParamByName(DWParams[X].ParamName).Value    := DWParams[X].Value;
        End;
      End;
    Finally
     DWParams.Free;
     If Assigned(vParamsStream) Then
      FreeAndNil(vParamsStream);
    End;
    vTempQuery.Open;
    vStream := Nil;
    If aBinaryCompatibleMode Then
     TRESTDWClientSQLBase.SaveToStream(TDataSet(vTempQuery.Owner), vStream)
    Else
     Begin
      vStream := TMemoryStream.Create;
      Try
       vTempQuery.SaveToStream(vStream);
       vStream.Position := 0;
      Finally
      End;
     End;
    //Gera o Binario
    Try
     BufferOutStream.InputStream(vStream);
    Finally
    If Assigned(vStream) Then
     FreeAndNil(vStream);
    End;
   End;
   If connInTransaction Then
    connCommit;

   If Not vStateResource Then
     Disconect;
 Except
  On E : Exception do
   Begin
    Disconect;
    Try
     Error          := True;
     MessageError   := E.Message;
    Except
    End;
   End;
 End;
 FreeAndNil(BufferInStream);
 BufferOutStream.SaveToStream(Result);
 FreeAndNil(BufferOutStream);
 vTempQuery.Close;
 vTempQuery.Free;
end;

class procedure TRESTDWDriverBase.CreateConnection(const AConnectionDefs: TConnectionDefs;
                                                   var AConnection: TComponent);
begin
 if (not Assigned(AConnection)) or (not Assigned(AConnectionDefs)) then
   Exit;
end;

procedure TRESTDWDriverBase.PrepareConnection(var AConnectionDefs: TConnectionDefs);
begin
  if Assigned(OnPrepareConnection) then
    OnPrepareConnection(AConnectionDefs);

  if (not Assigned(FConnection)) or (not Assigned(AConnectionDefs)) then
    Exit;

  CreateConnection(AConnectionDefs,FConnection);
end;

procedure TRESTDWDriverBase.BuildDatasetLine(var Query: TRESTDWDataset;
                            Massivedataset: TMassivedatasetBuffer;
                            MassiveCache: Boolean);
Var
 I, A              : Integer;
 vMasterField,
 vTempValue        : String;
 vStringStream     : TMemoryStream;
 MassiveField      : TMassiveField;
 MassiveReplyValue : TMassiveReplyValue;
 MassiveReplyCache : TMassiveReplyCache;
Begin
 vTempValue    := '';
 vStringStream := Nil;
 If Massivedataset.MassiveMode = mmUpdate Then
  Begin
   For I := 0 To Massivedataset.AtualRec.UpdateFieldChanges.Count -1 Do
    Begin
     MassiveField  := MassiveDataset.Fields.FieldByName(Massivedataset.AtualRec.UpdateFieldChanges[I]);
     If (Lowercase(MassiveField.FieldName) = Lowercase(RESTDWFieldBookmark)) then
      Continue;
     If (MassiveField <> Nil) Then
      Begin
       If MassiveField.IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveField.Value;
       If MassiveCache Then
        Begin
         If (MassiveField.KeyField) And (Not (MassiveField.ReadOnly)) Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveField.IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, MassiveField.OldValue, MassiveField.Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, Null, MassiveField.OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, Null);
              End;
             If Not MassiveField.IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             If Not MassiveField.IsNull Then
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue)
             Else
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveField.FieldName;
               If Not MassiveField.IsNull Then
                MassiveReplyValue.OldValue := MassiveField.Value
               Else
                MassiveReplyValue.OldValue := MassiveField.OldValue;
               MassiveReplyValue.NewValue  := Null;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End
             Else
              Begin
               MassiveField.Value := MassiveReplyValue.NewValue;
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveField.IsNull Then
            vTempValue := MassiveField.Value;
          End;
        End;
       If ((vTempValue = 'null')  Or
           (Query.FieldByName(MassiveField.FieldName).ReadOnly) Or
           (MassiveField.IsNull)) Then
        Begin
         If Not (Query.FieldByName(MassiveField.FieldName).ReadOnly) Then
          Query.FieldByName(MassiveField.FieldName).Clear;
         Continue;
        End;
       If MassiveField.IsNull Then
        Continue;
       If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                 ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                 ftString,    ftWideString,
                                                                 ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                         {$IF CompilerVersion > 21}
                                                                                 , ftWideMemo
                                                                          {$IFEND}
                                                                         {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And (vTempValue <> '') And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.FieldByName(MassiveField.FieldName).Size > 0 Then
            Query.FieldByName(MassiveField.FieldName).AsString := Copy(vTempValue, 1, Query.FieldByName(MassiveField.FieldName).Size)
           Else
            Query.FieldByName(MassiveField.FieldName).AsString := vTempValue;
          End
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End
       Else
        Begin
         If Query.FieldByName(MassiveField.FieldName).DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).Value := vTempValue
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.FieldByName(MassiveField.FieldName).FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}
                    Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                  {$ELSE}
                    Query.FieldByName(MassiveField.FieldName).AsInteger := StrToInt64(vTempValue);
                  {$IFEND}
                 {$ELSE}
                   Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.FieldByName(MassiveField.FieldName).AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsFloat  := StrToFloat(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                        ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.FieldByName(MassiveField.FieldName)).LoadFromStream(vStringStream);
             End
            Else
             Query.FieldByName(MassiveField.FieldName).Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Query.FieldByName(MassiveField.FieldName).Value := vTempValue
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End;
      End;
    End;
  End
 Else
  Begin
   For I := 0 To Query.Fields.Count -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName) <> Nil) Then
      Begin
       If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
        Begin
         A := -1;
         If (MassiveDataset.SequenceName <> '') Then
          A := GetGenID(TRESTDWQuery(Query),MassiveDataset.SequenceName);
         If A > -1 Then
          Query.Fields[I].Value := A;
         Continue;
        End
       Else If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).isNull) Or
               (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly) Then
        Begin
         If ((Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly)) And
             (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue))) Then
          Query.Fields[I].Clear;
         Continue;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       If MassiveCache Then
        Begin
         If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).KeyField Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          Null,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              Null);
              End;
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                                                                                            MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName;
               MassiveReplyValue.OldValue  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
               MassiveReplyValue.NewValue  := MassiveReplyValue.OldValue;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               vTempValue                  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
              End;
            End;
           vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
           If vMasterField <> '' Then
            Begin
             MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue <> Nil Then
              vTempValue := MassiveReplyValue.NewValue;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
               If vMasterField = '' Then
                vMasterField := Query.Fields[I].FieldName;
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
            vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
          End;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        Continue;
       If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                             ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                             ftString,    ftWideString,
                             ftMemo, ftFmtMemo {$IFNDEF FPC}
                                     {$IF CompilerVersion > 21}
                                      , ftWideMemo
                                     {$IFEND}
                                    {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.Fields[I].Size > 0 Then
            Query.Fields[I].AsString := Copy(vTempValue, 1, Query.Fields[I].Size)
           Else
            Query.Fields[I].AsString := vTempValue;
          End
         Else
          Query.Fields[I].Clear;
        End
       Else
        Begin
         If Query.Fields[I].DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.Fields[I].Value := vTempValue
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.Fields[I].FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}Query.Fields[I].AsLargeInt := StrToInt64(vTempValue)
                  {$ELSE} Query.Fields[I].AsInteger                    := StrToInt64(vTempValue)
                  {$IFEND}
                 {$ELSE}
                  Query.Fields[I].AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.Fields[I].AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle, ftExtended{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsFloat := StrToFloat(BuildFloatString(vTempValue))
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.Fields[I].Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                              ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.Fields[I]).LoadFromStream(vStringStream);
             End
            Else
             Query.Fields[I].Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Value := vTempValue;
          End
         Else
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Clear;
          End;
        End;
      End;
    End;
  End;
end;

end.
