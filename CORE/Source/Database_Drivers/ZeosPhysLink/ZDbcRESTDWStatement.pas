unit ZDbcRESTDWStatement;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit
uses
  Classes, {$IFDEF MSEgui}mclasses,{$ENDIF} SysUtils, DB, Variants,
  ZDbcStatement, ZDbcIntfs, ZDbcRESTDW, FmtBcd, ZCompatibility, ZVariant,
  uRESTDWBasicDB, uRESTDWParams, uRESTDWPoolermethod, ZDatasetUtils;

type
  TZAbstractRESTDWPreparedStatement = class(TZRawParamDetectPreparedStatement)
  private
    FStream : TMemoryStream;
    FDWSQL : string;
    function RDWExecuteComand(exec : boolean = False) : Integer;
  protected
    function ExecuteQueryPrepared: IZResultSet; override;
    function ExecuteUpdatePrepared: Integer; override;
    function ExecutePrepared: Boolean; override;

    procedure CheckParameterIndex(var Value: Integer); override;
  public
    constructor Create(const Connection: IZRESTDWConnection;
      const SQL: string; const Info: TStrings);
    destructor Destroy; override;

    procedure RegisterParameter(ParameterIndex: Integer; SQLType: TZSQLType;
      ParamType: TZProcedureColumnType; const Name: String = ''; PrecisionOrSize: LengthInt = 0;
      Scale: LengthInt = 0); override;
  end;

  TZRESTDWPreparedStatement = class(TZAbstractRESTDWPreparedStatement, IZPreparedStatement)
  private
    procedure BindSInteger(Index: Integer; SQLType: TZSQLType; Value: NativeInt);
  public
    procedure SetNull(ParameterIndex: Integer; {%H-}SQLType: TZSQLType);
    procedure SetBoolean(ParameterIndex: Integer; Value: Boolean);
    procedure SetByte(ParameterIndex: Integer; Value: Byte);
    procedure SetShort(ParameterIndex: Integer; Value: ShortInt);
    procedure SetWord(ParameterIndex: Integer; Value: Word);
    procedure SetSmall(ParameterIndex: Integer; Value: SmallInt);
    procedure SetUInt(ParameterIndex: Integer; Value: Cardinal);
    procedure SetInt(ParameterIndex: Integer; Value: Integer);
    procedure SetULong(ParameterIndex: Integer; const Value: UInt64);
    procedure SetLong(ParameterIndex: Integer; const Value: Int64);
    procedure SetFloat(ParameterIndex: Integer; Value: Single);
    procedure SetDouble(ParameterIndex: Integer; const Value: Double);
    procedure SetCurrency(ParameterIndex: Integer; const Value: Currency); reintroduce;
    procedure SetBigDecimal(ParameterIndex: Integer;
                            {$IFDEF FPC_HAS_CONSTREF}
                            constref
                            {$ELSE}
                            const
                            {$ENDIF} Value: TBCD); reintroduce;
    procedure SetDate(Index: Integer;
                      {$IFDEF FPC_HAS_CONSTREF}
                      constref
                      {$ELSE}
                      const
                      {$ENDIF} Value: TZDate); reintroduce; overload;
    procedure SetTime(Index: Integer;
                      {$IFDEF FPC_HAS_CONSTREF}
                      constref
                      {$ELSE}
                      const
                      {$ENDIF} Value: TZTime); reintroduce; overload;
    procedure SetTimestamp(Index: Integer;
                           {$IFDEF FPC_HAS_CONSTREF}
                           constref
                           {$ELSE}
                           const
                           {$ENDIF} Value: TZTimeStamp); reintroduce; overload;
    procedure SetBytes(Index: Integer; Value: PByte; Len: NativeUInt); reintroduce; overload;
  end;

  TZRESTDWStatement = class(TZAbstractRESTDWPreparedStatement, IZStatement)
  public
    constructor Create(const Connection: IZRESTDWConnection;
      const Info: TStrings);
  end;


{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit
implementation
{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit

uses
  ZDbcRESTDWResultSet, ZDbcCachedResultSet;

{ TZRESTStatement }

constructor TZRESTDWStatement.Create(const Connection: IZRESTDWConnection;
  const Info: TStrings);
begin
  inherited Create(Connection, '', Info);
end;

{ TZAbstractRESTPreparedStatement }

procedure TZAbstractRESTDWPreparedStatement.CheckParameterIndex(
  var Value: Integer);
begin
  inherited CheckParameterIndex(Value);
end;

constructor TZAbstractRESTDWPreparedStatement.Create(
  const Connection: IZRESTDWConnection; const SQL: string;
  const Info: TStrings);
begin
  inherited Create(Connection, SQL, Info);
  FStream := TMemoryStream.Create;
end;

destructor TZAbstractRESTDWPreparedStatement.Destroy;
begin
  FStream.Free;
  inherited;
end;

function TZAbstractRESTDWPreparedStatement.ExecutePrepared: Boolean;
begin
  Result := False;
end;

function TZAbstractRESTDWPreparedStatement.ExecuteQueryPrepared: IZResultSet;
var
  CachedResolver: TZRESTDWCachedResolver;
  NativeResultSet: TZRESTDWResultSet;
  CachedResultSet: TZCachedResultSet;
begin
  // para select
  RDWExecuteComand(False);

  NativeResultSet := TZRESTDWResultSet.Create(Self,FDWSQL,FStream);

  NativeResultSet.SetConcurrency(rcReadOnly);

  if (GetResultSetConcurrency = rcUpdatable)
    or (GetResultSetType <> rtForwardOnly) then
  begin
    { Creates a cached result set. }
    CachedResolver := TZRESTDWCachedResolver.Create(Self,NativeResultSet.GetMetaData);
    CachedResultSet := TZRESTDWCachedResultSet.Create(NativeResultSet, FDWSQL,
      CachedResolver,GetConnection.GetConSettings);
    CachedResultSet.SetType(rtScrollInsensitive);
    CachedResultSet.SetConcurrency(GetResultSetConcurrency);

    Result := CachedResultSet;
  end
  else
    Result := NativeResultSet;
end;

function TZAbstractRESTDWPreparedStatement.ExecuteUpdatePrepared: Integer;
begin
  // para execSQL
  Result := RDWExecuteComand(True);
end;

function TZAbstractRESTDWPreparedStatement.RDWExecuteComand(
  exec: boolean): Integer;
var
  vRESTDataBase : TRESTDWDatabasebaseBase;
  vParams : TParams;
  vError : boolean;
  vMessageError : string;
  vDataSetList : TJSONValue;
  vRowsAffected : integer;
  vPoolermethod : TRESTDWPoolerMethodClient;
  vExec : boolean;
  vSQL : TStringList;

  procedure addParams;
  var
    i : integer;
    BindValue : PZBindValue;
    dwparam : string;
    vDataType : TFieldType;
    vParaType : TParamType;
    vSize : integer;
    vValue : Variant;
  begin
    for i := 0 to BindList.Count - 1 do begin
      dwparam := 'dwparam'+IntToStr(i+1);
      BindValue := BindList[i];
      vSize := 0;
      if BindValue.BindType = zbtCharByRef then begin
        vValue := String(PAnsiChar(PZCharRec(BindValue.Value)^.P));
        vSize := PZCharRec(BindValue.Value)^.Len;
      end
      else begin
        vValue := EncodeVariant(BindList.Variants[i]);
      end;

      if (BindValue.SQLType = stString) and (vSize = 0) then begin
        vSize := Length(VarToStr(vValue));
        if vSize > 32766 then
          vSize := 0; // Memo
      end;

      vDataType := ConvertDbcToDatasetType(BindValue.SQLType,cDynamic,vSize);
      vParaType := ProcColDbcToDatasetType[BindValue.ParamType];
      with vParams.AddParameter do begin
        Name      := dwparam;
        DataType  := vDataType;
        ParamType := vParaType;
        Value     := vValue;
        Size      := vSize;
      end;
    end;
  end;

  function getSQLWithParams : string;
  var
    i : integer;
    dwparam : string;
    res : string;
  begin
    i := 1;
    res := SQL;
    while Pos('?',res) > 0 do begin
      dwparam := ':dwparam'+IntToStr(i);
      res := StringReplace(res, '?', dwparam, []);
      i := i + 1;
    end;
    getSQLWithParams := res;
  end;

begin
  if SQL <> '' then begin
    BindInParameters;
    Prepare;

    vRESTDataBase := TZRESTDWConnection(Connection).Database;
    vSQL := TStringList.Create;
    FDWSQL := getSQLWithParams;
    vSQL.Text := FDWSQL;

    vParams := TParams.Create(nil);
    addParams;

    vDataSetList := nil;
    vPoolermethod := nil;
    try
      vRESTDataBase.ExecuteCommand(vPoolermethod, vSQL, vParams, vError,
                                   vMessageError, vDataSetList, vRowsAffected,
                                   exec, (not exec), (not exec), False,
                                   vRESTDataBase.RESTClientPooler);
      FStream.Size := 0;
      if (vDataSetList <> nil) and (not vDataSetList.IsNull) then
        vDataSetList.SaveToStream(FStream);
    finally
      vDataSetList.Free;
    end;

    vSQL.Free;
    vParams.Free;

    if not vError then begin
      Result := vRowsAffected;
    end
    else begin
      Result := 0;
      raise Exception.Create(vMessageError);
    end;
  end;
end;

procedure TZAbstractRESTDWPreparedStatement.RegisterParameter(
  ParameterIndex: Integer; SQLType: TZSQLType; ParamType: TZProcedureColumnType;
  const Name: String; PrecisionOrSize, Scale: LengthInt);
begin
  inherited;
end;

{ TZRESTDWPreparedStatement }

procedure TZRESTDWPreparedStatement.BindSInteger(Index: Integer;
  SQLType: TZSQLType; Value: NativeInt);
var
  BindValue: PZBindValue;
begin
  CheckParameterIndex(Index);
  BindValue := BindList[Index];
  case SQLType of
    stBoolean : BindList.Put(Index,Value <> 0);
    stShort, stSmall, stInteger
    {$IFDEF CPU64},stLong{$ENDIF},
    stArray{overwrite}: begin
      BindList.Put(Index, SQLType, {$IFNDEF CPU64}P4Bytes{$ELSE}P8Bytes{$ENDIF}(@Value));
    end;
  end;
end;

procedure TZRESTDWPreparedStatement.SetBigDecimal(ParameterIndex: Integer;
  const Value: TBCD);
begin
  raise Exception.Create('Error Message');
end;

procedure TZRESTDWPreparedStatement.SetBoolean(ParameterIndex: Integer;
  Value: Boolean);
begin
  BindSInteger(ParameterIndex{$IFNDEF GENERIC_INDEX}-1{$ENDIF}, stBoolean, Ord(Value));
end;

procedure TZRESTDWPreparedStatement.SetByte(ParameterIndex: Integer;
  Value: Byte);
begin
  raise Exception.Create('Error Message');
end;

procedure TZRESTDWPreparedStatement.SetBytes(Index: Integer; Value: PByte;
  Len: NativeUInt);
begin
  raise Exception.Create('Error Message');
end;

procedure TZRESTDWPreparedStatement.SetCurrency(ParameterIndex: Integer;
  const Value: Currency);
begin
  raise Exception.Create('Error Message');
end;

procedure TZRESTDWPreparedStatement.SetDate(Index: Integer;
  const Value: TZDate);
begin
  raise Exception.Create('Error Message');
end;

procedure TZRESTDWPreparedStatement.SetDouble(ParameterIndex: Integer;
  const Value: Double);
begin

end;

procedure TZRESTDWPreparedStatement.SetFloat(ParameterIndex: Integer;
  Value: Single);
begin

end;

procedure TZRESTDWPreparedStatement.SetInt(ParameterIndex, Value: Integer);
begin
  BindSInteger(ParameterIndex{$IFNDEF GENERIC_INDEX}-1{$ENDIF}, stInteger, Value);
end;

procedure TZRESTDWPreparedStatement.SetLong(ParameterIndex: Integer;
  const Value: Int64);
begin

end;

procedure TZRESTDWPreparedStatement.SetNull(ParameterIndex: Integer;
  SQLType: TZSQLType);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.SetNull(ParameterIndex, SQLType);
end;

procedure TZRESTDWPreparedStatement.SetShort(ParameterIndex: Integer;
  Value: ShortInt);
begin

end;

procedure TZRESTDWPreparedStatement.SetSmall(ParameterIndex: Integer;
  Value: SmallInt);
begin

end;

procedure TZRESTDWPreparedStatement.SetTime(Index: Integer;
  const Value: TZTime);
begin

end;

procedure TZRESTDWPreparedStatement.SetTimestamp(Index: Integer;
  const Value: TZTimeStamp);
begin

end;

procedure TZRESTDWPreparedStatement.SetUInt(ParameterIndex: Integer;
  Value: Cardinal);
begin

end;

procedure TZRESTDWPreparedStatement.SetULong(ParameterIndex: Integer;
  const Value: UInt64);
begin

end;

procedure TZRESTDWPreparedStatement.SetWord(ParameterIndex: Integer;
  Value: Word);
begin

end;

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit

end.

