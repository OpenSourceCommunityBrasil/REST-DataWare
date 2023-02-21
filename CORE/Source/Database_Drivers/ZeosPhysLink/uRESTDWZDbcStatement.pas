unit uRESTDWZDbcStatement;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit
uses
  Classes, {$IFDEF MSEgui}mclasses,{$ENDIF} SysUtils, DB, Variants,
  ZDbcStatement, ZDbcIntfs, uRESTDWZDbc, FmtBcd, ZCompatibility, ZVariant,
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
    procedure SetDate(ParameterIndex: Integer;
                      {$IFDEF FPC_HAS_CONSTREF}
                      constref
                      {$ELSE}
                      const
                      {$ENDIF} Value: TZDate); reintroduce; overload;
    procedure SetTime(ParameterIndex: Integer;
                      {$IFDEF FPC_HAS_CONSTREF}
                      constref
                      {$ELSE}
                      const
                      {$ENDIF} Value: TZTime); reintroduce; overload;
    procedure SetTimestamp(ParameterIndex: Integer;
                           {$IFDEF FPC_HAS_CONSTREF}
                           constref
                           {$ELSE}
                           const
                           {$ENDIF} Value: TZTimeStamp); reintroduce; overload;
    procedure SetBytes(ParameterIndex: Integer; Value: PByte; Len: NativeUInt); reintroduce; overload;
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
  uRESTDWZDbcResultSet, ZDbcCachedResultSet;

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
    vStream : TStream;
    vBytes : ansistring;
    vZDate : TZDate;
    vZTime : TZTime;
    vZDateTime : TZTimeStamp;
  begin
    for i := 0 to BindList.Count - 1 do begin
      dwparam := 'dwparam'+IntToStr(i+1);
      BindValue := BindList[i];
      vSize := 0;
      vDataType := ConvertDbcToDatasetType(BindValue.SQLType,cDynamic,vSize);
      vParaType := ProcColDbcToDatasetType[BindValue.ParamType];
      with vParams.AddParameter do begin
        Name      := dwparam;
        DataType  := vDataType;

        if BindValue.BindType = zbtLob then begin
          vStream := IZBlob(BindValue.Value).GetStream;
          try
            SetLength(vBytes,vStream.Size);
            vStream.Read(vBytes[1],vStream.Size);
            vDataType := ftString;
            DataType := vDataType;
            AsAnsiString := vBytes;
          finally
            vStream.Free;
            SetLength(vBytes,0);
          end;
        end
        else if BindValue.BindType = zbtCharByRef then begin
          vValue := String(PAnsiChar(PZCharRec(BindValue.Value)^.P));
          vSize := PZCharRec(BindValue.Value)^.Len;
          AsString := vValue;
        end
        else if BindValue.BindType = zbtDate then begin
          vValue := EncodeVariant(EncodeZDate(PZDate(BindValue.Value)^));
          AsDateTime := vValue;
        end
        else if BindValue.BindType = zbtTime then begin
          vValue := EncodeVariant(EncodeZTime(PZTime(BindValue.Value)^));
          AsDateTime := vValue;
        end
        else if BindValue.BindType = zbtTimeStamp then begin
          vValue := EncodeVariant(EncodeZTimeStamp(PZTimeStamp(BindValue.Value)^));
          AsDateTime := vValue;
        end
        else begin
          vValue := EncodeVariant(BindList.Variants[i]);
          Value := vValue;
        end;

        if (BindValue.SQLType = stString) and (vSize = 0) then begin
          vSize := Length(VarToStr(vValue));
          if vSize > 32766 then
            vSize := 0; // Memo
        end;

        ParamType := vParaType;
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

procedure TZRESTDWPreparedStatement.SetBigDecimal(ParameterIndex: Integer;
  const Value: TBCD);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, Value);
end;

procedure TZRESTDWPreparedStatement.SetBoolean(ParameterIndex: Integer;
  Value: Boolean);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stBoolean, P4Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetByte(ParameterIndex: Integer;
  Value: Byte);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stByte, P4Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetBytes(ParameterIndex: Integer; Value: PByte;
  Len: NativeUInt);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stBytes, Value, Len);
end;

procedure TZRESTDWPreparedStatement.SetCurrency(ParameterIndex: Integer;
  const Value: Currency);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stCurrency, P8Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetDate(ParameterIndex: Integer;
  const Value: TZDate);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, Value);
end;

procedure TZRESTDWPreparedStatement.SetDouble(ParameterIndex: Integer;
  const Value: Double);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stDouble, P8Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetFloat(ParameterIndex: Integer;
  Value: Single);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stDouble, P8Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetInt(ParameterIndex, Value: Integer);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stInteger, P4Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetLong(ParameterIndex: Integer;
  const Value: Int64);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stLong, P8Bytes(@Value));
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
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stShort, P4Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetSmall(ParameterIndex: Integer;
  Value: SmallInt);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stSmall, P4Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetTime(ParameterIndex: Integer;
  const Value: TZTime);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, Value);
end;

procedure TZRESTDWPreparedStatement.SetTimestamp(ParameterIndex: Integer;
  const Value: TZTimeStamp);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, Value);
end;

procedure TZRESTDWPreparedStatement.SetUInt(ParameterIndex: Integer;
  Value: Cardinal);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stLong, P8Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetULong(ParameterIndex: Integer;
  const Value: UInt64);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stLong, P8Bytes(@Value));
end;

procedure TZRESTDWPreparedStatement.SetWord(ParameterIndex: Integer;
  Value: Word);
begin
  {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
  CheckParameterIndex(ParameterIndex);
  BindList.Put(ParameterIndex, stWord, P4Bytes(@Value));
end;

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit

end.

