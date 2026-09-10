Unit uRESTDWNativeLinkZeos;

{$I uRESTDW.inc}

Interface

Uses
 {$IFDEF FPC}
 LResources,
{$ENDIF}
 Classes, SysUtils, Variants, DB, FMTBcd, ZConnection, ZAbstractConnection, ZDbcIntfs,
 ZCompatibility, ZSysUtils, ZDataset, ZMemTable,
 uRESTDWNativeDriver, uRESTDWDriverBase, uRESTDWParams, uRESTDWMemoryDataset;

Type
 TRESTDWNativeLinkZeos = Class(TRESTDWNativeLink)
 Private
  FConnection : TZConnection;
  Procedure SetConnection(AValue : TZConnection);
 Protected
  Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
  Function GetConnection : TComponent; Override;
 Public
  Function GetQuery : TRESTDWDrvQuery; Override;
  Function IsConnected : Boolean; Override;
  Procedure Connect; Override;
  Procedure Disconnect; Override;
  Procedure ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                          AOutput : TStream; ACompress : Boolean); Overload; Override;
  Procedure ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                          AOutput : TStream; ACompress : Boolean;
                          ABinaryCompatibleMode : Boolean); Overload; Override;
  Function ExecuteCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64; Override;
 Published
  Property Connection : TZConnection Read FConnection Write SetConnection;
 End;

Procedure Register;

Implementation

Type
 TRESTDWNativeZeosQuery = Class(TRESTDWDrvQuery)
 Public
  Procedure ExecSQL; Override;
  Procedure Prepare; Override;
  Function ParamCount : Integer; Override;
  Function RowsAffected : Int64; Override;
  Function getParamDataType(IParam : Integer) : TFieldType; Override;
  Function getParamName(IParam : Integer) : String; Override;
  Function getParamSize(IParam : Integer) : Integer; Override;
  Function getParamValue(IParam : Integer) : Variant; Override;
  Procedure setParamDataType(IParam : Integer; AValue : TFieldType); Override;
  Procedure setParamValue(IParam : Integer; AValue : Variant); Override;
  Procedure LoadFromStreamParam(IParam : Integer; Stream : TStream; BlobType : TBlobType); Override;
 End;

 TDirectField = Record
  Name        : String;
  DisplayName : String;
  Size        : Word;
  DataType    : TFieldType;
  ZType       : TZSQLType;
  ReadOnly    : Boolean;
 End;

 TDirectFields = Array Of TDirectField;

Function MapDataType(AType : TZSQLType) : TFieldType;
Begin
 Case AType Of
  stBoolean: Result := ftBoolean;
  stByte,
  stShort,
  stSmall: Result := ftSmallint;
  stWord: Result := ftWord;
  stLongWord,
  stInteger: Result := ftInteger;
  stULong,
  stLong: Result := ftLargeint;
  stFloat,
  stDouble: Result := ftFloat;
  stCurrency: Result := ftBCD;
  stBigDecimal: Result := ftFMTBcd;
  stDate: Result := ftDate;
  stTime: Result := ftTime;
  stTimestamp: Result := ftDateTime;
  stGUID: Result := ftGuid;
  stString: Result := ftString;
  stUnicodeString: Result := ftWideString;
  stBytes: Result := ftVarBytes;
  stAsciiStream: Result := ftMemo;
  stUnicodeStream: Result := ftWideMemo;
  stBinaryStream: Result := ftBlob;
 Else
  Result := ftUnknown;
 End;
End;

Procedure StoreValue(AWriter : TRESTDWBinaryPacketWriter; AResultSet : IZResultSet;
                     AFieldIndex, AColumnIndex : Integer; AType : TZSQLType);
Var
 S          : AnsiString;
 WS         : WideString;
 B          : TBytes;
 VBool      : WordBool;
 VSmall     : SmallInt;
 VWord      : Word;
 VInt       : Integer;
 VInt64     : Int64;
 VDouble    : Double;
 VCurrency  : Currency;
 VBcd       : TBcd;
 VDateTime  : TDateTime;
{$IFDEF ZEOS80UP}
 VZTimeStamp : TZTimeStamp;
{$ENDIF}
 VGuid      : TGUID;
 P          : Pointer;
 L          : Integer;
Begin
 If AResultSet.IsNull(AColumnIndex) Then
  Begin
   AWriter.StoreNull(AFieldIndex);
   Exit;
  End;
 Case AType Of
  stBoolean:
   Begin
    VBool := AResultSet.GetBoolean(AColumnIndex);
    AWriter.StoreField(AFieldIndex, @VBool, SizeOf(VBool));
   End;
  stByte,
  stShort,
  stSmall:
   Begin
    VSmall := AResultSet.GetInt(AColumnIndex);
    AWriter.StoreField(AFieldIndex, @VSmall, SizeOf(VSmall));
   End;
  stWord:
   Begin
    VWord := AResultSet.GetInt(AColumnIndex);
    AWriter.StoreField(AFieldIndex, @VWord, SizeOf(VWord));
   End;
  stLongWord,
  stInteger:
   Begin
    VInt := AResultSet.GetInt(AColumnIndex);
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  stULong,
  stLong:
   Begin
    VInt64 := AResultSet.GetLong(AColumnIndex);
    AWriter.StoreField(AFieldIndex, @VInt64, SizeOf(VInt64));
   End;
  stFloat,
  stDouble:
   Begin
    VDouble := AResultSet.GetDouble(AColumnIndex);
    AWriter.StoreField(AFieldIndex, @VDouble, SizeOf(VDouble));
   End;
  stCurrency:
   Begin
    VCurrency := AResultSet.GetDouble(AColumnIndex);
    AWriter.StoreField(AFieldIndex, @VCurrency, SizeOf(VCurrency));
   End;
  stBigDecimal:
   Begin
    FillChar(VBcd, SizeOf(VBcd), 0);
    AResultSet.GetBigDecimal(AColumnIndex, VBcd);
    AWriter.StoreField(AFieldIndex, @VBcd, SizeOf(VBcd));
   End;
  stDate:
   Begin
    VDateTime := AResultSet.GetDate(AColumnIndex);
    VInt := DateTimeToTimeStamp(VDateTime).Date;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  stTime:
   Begin
    VDateTime := AResultSet.GetTime(AColumnIndex);
    VInt := DateTimeToTimeStamp(VDateTime).Time;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  stTimestamp:
   Begin
{$IFDEF ZEOS80UP}
    FillChar(VZTimeStamp, SizeOf(VZTimeStamp), 0);
    AResultSet.GetTimestamp(AColumnIndex, VZTimeStamp);
    If Not TryTimeStampToDateTime(VZTimeStamp, VDateTime) Then
     DatabaseError('Invalid Zeos timestamp value');
{$ELSE}
    VDateTime := AResultSet.GetTimestamp(AColumnIndex);
{$ENDIF}
    AWriter.StoreField(AFieldIndex, @VDateTime, SizeOf(VDateTime));
   End;
  stGUID:
   Begin
    FillChar(VGuid, SizeOf(VGuid), 0);
    S := AnsiString(AResultSet.GetString(AColumnIndex));
    If Length(S) > 0 Then
     VGuid := StringToGUID(String(S));
    AWriter.StoreField(AFieldIndex, @VGuid, SizeOf(VGuid));
   End;
  stString:
   Begin
    S := AResultSet.GetRawByteString(AColumnIndex);
    If Length(S) = 0 Then
     P := Nil
    Else
     P := @S[1];
    AWriter.StoreField(AFieldIndex, P, Length(S));
   End;
  stUnicodeString:
   Begin
    WS := AResultSet.GetUnicodeString(AColumnIndex);
    S := AnsiString(String(WS));
    If Length(S) = 0 Then
     P := Nil
    Else
     P := @S[1];
    AWriter.StoreField(AFieldIndex, P, Length(S));
   End;
  stBytes,
  stAsciiStream,
  stUnicodeStream,
  stBinaryStream:
   Begin
    B := AResultSet.GetBytes(AColumnIndex);
    L := Length(B);
    If L = 0 Then
     P := Nil
    Else
     P := @B[0];
    AWriter.StoreField(AFieldIndex, P, L);
   End;
 Else
  DatabaseError('Zeos data type is not representable by the RESTDW DataSet binary contract: ' +
                IntToStr(Ord(AType)));
 End;
End;

Procedure BindParams(AStatement : IZPreparedStatement; AParams : TRESTDWParams);
Var
 I : Integer;
 P : TRESTDWJSONParam;
Begin
 If (AStatement = Nil) Or (AParams = Nil) Then
  Exit;
 For I := 0 To AParams.Count - 1 Do
  Begin
   P := AParams[I];
   If P = Nil Then
    Continue;
   If VarIsNull(P.Value) Or VarIsEmpty(P.Value) Then
    AStatement.SetNull(I + FirstDbcIndex, stString)
   Else
    AStatement.SetString(I + FirstDbcIndex, VarToStr(P.Value));
  End;
End;

Procedure TRESTDWNativeZeosQuery.ExecSQL;
Begin
 Inherited ExecSQL;
 TZQuery(Self.Owner).ExecSQL;
End;

Procedure TRESTDWNativeZeosQuery.Prepare;
Begin
 Inherited Prepare;
 TZQuery(Self.Owner).Prepare;
End;

Function TRESTDWNativeZeosQuery.ParamCount : Integer;
Begin
 Result:=TZQuery(Self.Owner).Params.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   Result:=TZQuery(Self.Owner).Params.Count;
  End;
End;

Function TRESTDWNativeZeosQuery.RowsAffected : Int64;
Begin
 Result:=TZQuery(Self.Owner).RowsAffected;
End;

Function TRESTDWNativeZeosQuery.getParamDataType(IParam : Integer) : TFieldType;
Begin
 Result:=TZQuery(Self.Owner).Params[IParam].DataType;
End;

Function TRESTDWNativeZeosQuery.getParamName(IParam : Integer) : String;
Begin
 Result:=TZQuery(Self.Owner).Params[IParam].Name;
End;

Function TRESTDWNativeZeosQuery.getParamSize(IParam : Integer) : Integer;
Begin
 Result:=TZQuery(Self.Owner).Params[IParam].Size;
End;

Function TRESTDWNativeZeosQuery.getParamValue(IParam : Integer) : Variant;
Begin
 Result:=TZQuery(Self.Owner).Params[IParam].Value;
End;

Procedure TRESTDWNativeZeosQuery.setParamDataType(IParam : Integer; AValue : TFieldType);
Begin
 TZQuery(Self.Owner).Params[IParam].DataType:=AValue;
End;

Procedure TRESTDWNativeZeosQuery.setParamValue(IParam : Integer; AValue : Variant);
Begin
 TZQuery(Self.Owner).Params[IParam].Value:=AValue;
End;

Procedure TRESTDWNativeZeosQuery.LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                                    BlobType : TBlobType);
Begin
 TZQuery(Self.Owner).Params[IParam].LoadFromStream(Stream,BlobType);
End;

Function TRESTDWNativeLinkZeos.GetConnection : TComponent;
Begin
 Result := FConnection;
End;

Function TRESTDWNativeLinkZeos.GetQuery : TRESTDWDrvQuery;
Var
 Query : TZQuery;
Begin
 Result := Nil;
 If FConnection = Nil Then
  Exit;
 Query := TZQuery.Create(Self);
 Query.Connection := FConnection;
 Result := TRESTDWNativeZeosQuery.Create(Query);
End;

Procedure TRESTDWNativeLinkZeos.SetConnection(AValue : TZConnection);
Begin
 If FConnection = AValue Then
  Exit;
 If FConnection <> Nil Then
  FConnection.RemoveFreeNotification(Self);
 FConnection := AValue;
 If FConnection <> Nil Then
  FConnection.FreeNotification(Self);
End;

Procedure TRESTDWNativeLinkZeos.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If (Operation = opRemove) And (AComponent = FConnection) Then
  FConnection := Nil;
End;

Function TRESTDWNativeLinkZeos.IsConnected : Boolean;
Begin
 Result := (FConnection <> Nil) And FConnection.Connected;
End;

Procedure TRESTDWNativeLinkZeos.Connect;
Begin
 If FConnection = Nil Then
  DatabaseError('Zeos Connection not assigned');
 If Not FConnection.Connected Then
  FConnection.Connected := True;
End;

Procedure TRESTDWNativeLinkZeos.Disconnect;
Begin
 If (FConnection <> Nil) And FConnection.Connected Then
  FConnection.Connected := False;
End;

Procedure TRESTDWNativeLinkZeos.ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                                              AOutput : TStream; ACompress : Boolean;
                                              ABinaryCompatibleMode : Boolean);
Var
 Query    : TZQuery;
 MemTable : TZMemTable;
 I        : Integer;
Begin
 If ABinaryCompatibleMode Then
  Begin
   ExecuteSelect(ASQL, AParams, AOutput, ACompress);
   Exit;
  End;
 If FConnection = Nil Then
  DatabaseError('Zeos Connection not assigned');
 If Not FConnection.Connected Then
  FConnection.Connect;
 Query := TZQuery.Create(Nil);
 MemTable := TZMemTable.Create(Nil);
 Try
  Query.Connection := FConnection;
  Query.SQL.Text := ASQL;
  If AParams <> Nil Then
   Begin
    For I := 0 To AParams.Count - 1 Do
     Begin
      If Query.Params.FindParam(AParams[I].ParamName) <> Nil Then
       Query.Params.ParamByName(AParams[I].ParamName).Value := AParams[I].Value;
     End;
   End;
  Query.Open;
  MemTable.AssignDataFrom(Query);
  AOutput.Position := 0;
  AOutput.Size := 0;
  MemTable.SaveToStream(AOutput);
  AOutput.Position := 0;
 Finally
  MemTable.Free;
  Query.Free;
 End;
End;

Procedure TRESTDWNativeLinkZeos.ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                                              AOutput : TStream; ACompress : Boolean);
Var
 Statement : IZPreparedStatement;
 ResultSet : IZResultSet;
 Metadata  : IZResultSetMetadata;
 Writer    : TRESTDWBinaryPacketWriter;
 Fields    : TDirectFields;
 I         : Integer;
 C         : Integer;
 LSize     : Integer;
 LWordSize : Word;
 LType     : TFieldType;
Begin
 If FConnection = Nil Then
  DatabaseError('Zeos Connection not assigned');
 If Not FConnection.Connected Then
  FConnection.Connected := True;
 Statement := FConnection.DbcConnection.PrepareStatement(ASQL);
 BindParams(Statement, AParams);
 ResultSet := Statement.ExecuteQueryPrepared;
 Metadata := ResultSet.GetMetadata;
 C := ResultSet.GetColumnCount;
 SetLength(Fields, C);
 Writer := TRESTDWBinaryPacketWriter.Create(AOutput);
{$IFDEF RESTDWLAZARUS}
 Writer.DatabaseCharSet := DatabaseCharSet;
{$ENDIF}
 Try
  Writer.ClearFieldDefs;
  For I := 0 To C - 1 Do
   Begin
    Fields[I].Name := Metadata.GetColumnName(I + FirstDbcIndex);
    Fields[I].DisplayName := Metadata.GetColumnLabel(I + FirstDbcIndex);
    Fields[I].ZType := Metadata.GetColumnType(I + FirstDbcIndex);
    Fields[I].DataType := MapDataType(Fields[I].ZType);
    Fields[I].ReadOnly := Metadata.IsReadOnly(I + FirstDbcIndex);
    If Fields[I].DataType = ftUnknown Then
     DatabaseError('Zeos data type is not representable by the RESTDW DataSet binary contract: ' +
                   IntToStr(Ord(Fields[I].ZType)));
    If Fields[I].ZType In [stCurrency, stBigDecimal] Then
     LSize := Metadata.GetScale(I + FirstDbcIndex)
    Else
     LSize := Metadata.GetPrecision(I + FirstDbcIndex);
    If LSize < 0 Then
     LSize := -LSize;
    If LSize > High(Word) Then
     LWordSize := High(Word)
    Else
     LWordSize := Word(LSize);
    Fields[I].Size := LWordSize;
    Writer.AddFieldDef(Fields[I].Name, Fields[I].DisplayName, Fields[I].Size,
                       Fields[I].DataType, Fields[I].ReadOnly);
   End;
  Writer.StoreFieldDefs(0);
  While ResultSet.Next Do
   Begin
    Writer.BeginRecord;
    For I := 0 To C - 1 Do
     StoreValue(Writer, ResultSet, I, I + FirstDbcIndex, Fields[I].ZType);
    Writer.EndRecord;
   End;
 Finally
  Writer.Free;
  ResultSet := Nil;
  Statement := Nil;
 End;
End;

Function TRESTDWNativeLinkZeos.ExecuteCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64;
Var
 Statement : IZPreparedStatement;
Begin
 If FConnection = Nil Then
  DatabaseError('Zeos Connection not assigned');
 If Not FConnection.Connected Then
  FConnection.Connected := True;
 Statement := FConnection.DbcConnection.PrepareStatement(ASQL);
 BindParams(Statement, AParams);
 Result := Statement.ExecuteUpdatePrepared;
 Statement := Nil;
End;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWNativeLinkZeos]);
End;

Initialization
{$IFDEF FPC}
 {$I uRESTDWNativeLinkZeos.lrs}
{$ENDIF}

End.
