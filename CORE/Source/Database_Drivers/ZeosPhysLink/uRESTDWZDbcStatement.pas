unit uRESTDWZDbcStatement;

{$I ..\..\Includes\uRESTDW.inc}

{$IFNDEF RESTDWLAZARUS}
  {$I ZDbc.inc}
{$ELSE}
  {$MODE DELPHI}
{$ENDIF}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit
uses
  Classes, SysUtils, DB, Variants, ZDbcStatement, ZDbcIntfs, uRESTDWZDbc,
  FmtBcd, ZCompatibility, ZVariant, ZDatasetUtils,
  uRESTDWBasicDB, uRESTDWParams, uRESTDWPoolermethod, uRESTDWConsts;

type
  {$IFDEF ZEOS80UP}
  TZAbstractRESTDWPreparedStatement = class(TZRawParamDetectPreparedStatement)
  {$ELSE}
  TZAbstractRESTDWPreparedStatement = class(TZAbstractPreparedStatement, IZPreparedStatement)
  {$ENDIF}
  private
    FStream : TMemoryStream;
    FDWSQL : string;
    function RDWExecuteComand(exec : boolean = False) : Integer;
  public
    constructor Create(const Connection: IZRESTDWConnection;
      const SQL: string; const Info: TStrings);
    destructor Destroy; override;

    function ExecuteQueryPrepared: IZResultSet; override;
    function ExecuteUpdatePrepared: Integer; override;
    function ExecutePrepared: Boolean; override;
  end;

  {$IFDEF ZEOS80UP}
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
  {$ENDIF}

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

constructor TZAbstractRESTDWPreparedStatement.Create(
  const Connection: IZRESTDWConnection; const SQL: string;
  const Info: TStrings);
begin
  FStream := TMemoryStream.Create;
  inherited Create(Connection, SQL, Info);
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

  if Assigned(FOpenResultSet) then
    IZResultSet(FOpenResultSet).Close;

  NativeResultSet := TZRESTDWResultSet.Create(Self,FDWSQL,FStream);

  NativeResultSet.SetConcurrency(rcReadOnly);

  if (GetResultSetConcurrency = rcUpdatable) or
     (GetResultSetType <> rtForwardOnly) then
  begin
    { Creates a cached result set. }
    CachedResolver := TZRESTDWCachedResolver.Create(Self,NativeResultSet.GetMetaData);
    {$IFDEF ZEOS80UP}
      CachedResultSet := TZRESTDWCachedResultSet.Create(NativeResultSet, FDWSQL,
        CachedResolver,GetConnection.GetConSettings);
    {$ELSE}
      CachedResultSet := TZCachedResultSet.Create(NativeResultSet, FDWSQL,
        CachedResolver,GetConnection.GetConSettings);
    {$ENDIF}
    CachedResultSet.SetType(rtScrollInsensitive);
    CachedResultSet.SetConcurrency(GetResultSetConcurrency);

    Result := CachedResultSet;
  end
  else
    Result := NativeResultSet;

  FOpenResultSet := Pointer(Result);

  inherited ExecuteQueryPrepared; //Log values
end;

function TZAbstractRESTDWPreparedStatement.ExecuteUpdatePrepared: Integer;
begin
  // para execSQL
  Result := RDWExecuteComand(True);
  inherited ExecuteUpdatePrepared; //log values
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

  {$IFDEF ZEOS80UP}
    procedure addParams;
    var
      i : integer;
      BindValue : PZBindValue;
      dwparam : string;
      vDataType : TFieldType;
      vParaType : TParamType;
      vParam : TParam;
      vSize : integer;
      vValue : Variant;
      vStream : TStream;
      vBytes : ansistring;
    begin
      for i := 0 to BindList.Count - 1 do begin
        dwparam := 'dwparam'+IntToStr(i+1);
        BindValue := BindList[i];
        vSize := 0;
        vDataType := ConvertDbcToDatasetType(BindValue.SQLType,cDynamic,vSize);
        vParaType := ProcColDbcToDatasetType[BindValue.ParamType];
        vParam := vParams.Add as TParam;
        with vParam do begin
          Name      := dwparam;
          DataType  := vDataType;

          if BindValue.BindType = zbtLob then begin
            vStream := IZBlob(BindValue.Value).GetStream;
            try
              SetLength(vBytes,vStream.Size);
              vStream.Read(vBytes[InitStrPos],vStream.Size);
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
  {$ELSE}
    procedure addParams;
    var
      i : integer;
      dwparam : string;
      vDataType : TFieldType;
      vParaType : TParamType;
      vParam : TParam;
      vSize : integer;
      vValue : Variant;
      vZBlob: IZBlob;
    begin
      for i := 0 to InParamCount - 1 do begin
        dwparam := 'dwparam'+IntToStr(i+1);
        vSize := 0;
        vDataType := ConvertDbcToDatasetType(InParamTypes[i]);
        vParaType := ptUnknown;
        vParam := vParams.Add as TParam;
        with vParam do begin
          Name      := dwparam;
          DataType  := vDataType;

          if InParamTypes[i] = stBinaryStream then begin
            vDataType := ftString;
            DataType  := vDataType;
            vZBlob := ClientVarManager.GetAsInterface(InParamValues[i]) as IZBlob;
            AsAnsiString := vZBlob.GetString;
          end
          else if InParamTypes[i] = stAsciiStream then begin
            vZBlob := ClientVarManager.GetAsInterface(InParamValues[i]) as IZBlob;
            AsAnsiString := vZBlob.GetAnsiString;
          end
          else begin
            vValue := EncodeVariant(InParamValues[i]);
            Value := vValue;
          end;

          ParamType := vParaType;
          Size      := vSize;
        end;
      end;
    end;
  {$ENDIF}

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

    vRESTDataBase := IZRESTDWConnection(Connection).GetDatabase;
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

{ TZRESTDWPreparedStatement }

{$IFDEF ZEOS80UP}
  procedure TZRESTDWPreparedStatement.SetBigDecimal(ParameterIndex: Integer;
    {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} Value: TBCD);
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
    {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} Value: TZDate);
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
    {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} Value: TZTime);
  begin
    {$IFNDEF GENERIC_INDEX}ParameterIndex := ParameterIndex -1;{$ENDIF}
    CheckParameterIndex(ParameterIndex);
    BindList.Put(ParameterIndex, Value);
  end;

  procedure TZRESTDWPreparedStatement.SetTimestamp(ParameterIndex: Integer;
    {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} Value: TZTimeStamp);
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
{$ENDIF}

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit

end.

