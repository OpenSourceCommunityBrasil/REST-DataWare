Unit uRESTDWNativeLinkDBExpress;

{$I uRESTDW.inc}

Interface

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes, System.SysUtils, System.Variants, Data.DB, Data.FMTBcd, Data.SqlTimSt,
 Data.SqlExpr, Data.DBXCommon,
{$ELSE}
 Classes, SysUtils, Variants, DB, FMTBcd, SqlTimSt, SqlExpr, DBXCommon,
{$ENDIF}
 uRESTDWNativeDriver, uRESTDWDriverBase, uRESTDWParams, uRESTDWMemoryDataset;

Type
 TRESTDWNativeLinkDBExpress = Class(TRESTDWNativeLink)
 Private
  FConnection : TSQLConnection;
  Procedure SetConnection(AValue : TSQLConnection);
 Protected
  Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
  Function GetConnection : TComponent; Override;
 Public
  Function GetQuery : TRESTDWDrvQuery; Override;
  Function IsConnected : Boolean; Override;
  Procedure Connect; Override;
  Procedure Disconnect; Override;
  Procedure ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                          AOutput : TStream; ACompress : Boolean); Override;
  Function ExecuteCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64; Override;
 Published
  Property Connection : TSQLConnection Read FConnection Write SetConnection;
 End;

Procedure Register;

Implementation

Type
 TRESTDWNativeDBExpressQuery = Class(TRESTDWDrvQuery)
 Private
  FRowsAffected : Int64;
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

Type
 TDirectField = Record
  Name        : String;
  DisplayName : String;
  Size        : Word;
  DataType    : TFieldType;
  DBXType     : Integer;
  ReadOnly    : Boolean;
 End;

 TDirectFields = Array Of TDirectField;

Function MapDBXDataType(AType : Integer) : TFieldType;
Begin
 Case AType Of
  TDBXDataTypes.BooleanType: Result := ftBoolean;
  TDBXDataTypes.Int8Type,
  TDBXDataTypes.Int16Type: Result := ftSmallint;
  TDBXDataTypes.UInt8Type,
  TDBXDataTypes.UInt16Type: Result := ftWord;
  TDBXDataTypes.Int32Type: Result := ftInteger;
  TDBXDataTypes.UInt32Type,
  TDBXDataTypes.Int64Type,
  TDBXDataTypes.UInt64Type: Result := ftLargeint;
  TDBXDataTypes.SingleType,
  TDBXDataTypes.DoubleType: Result := ftFloat;
  TDBXDataTypes.CurrencyType: Result := ftBCD;
  TDBXDataTypes.BcdType: Result := ftFMTBcd;
  TDBXDataTypes.DateType: Result := ftDate;
  TDBXDataTypes.TimeType: Result := ftTime;
  TDBXDataTypes.DateTimeType,
  TDBXDataTypes.TimeStampType,
  TDBXDataTypes.TimeStampOffsetType: Result := ftDateTime;
  TDBXDataTypes.AnsiStringType: Result := ftString;
  TDBXDataTypes.WideStringType: Result := ftWideString;
  TDBXDataTypes.BytesType,
  TDBXDataTypes.VarBytesType: Result := ftVarBytes;
  TDBXDataTypes.BlobType,
  TDBXDataTypes.BinaryBlobType: Result := ftBlob;
 Else
  Begin
   Result := ftUnknown;
  End;
 End;
End;

Procedure BindDBXParams(ACommand : TDBXCommand; AParams : TRESTDWParams);
Var
 I  : Integer;
 P  : TRESTDWJSONParam;
 DP : TDBXParameter;
Begin
 If (ACommand = Nil) Or (AParams = Nil) Then
  Begin
   Exit;
  End;
 ACommand.Prepare;
 For I := 0 To AParams.Count - 1 Do
  Begin
   P := AParams[I];
   If P = Nil Then
    Begin
     Continue;
    End;
   DP := ACommand.Parameters[P.ParamName];
   If DP <> Nil Then
    Begin
     DP.Value.AsVariant := P.Value;
    End;
  End;
End;

Procedure StoreDBXValue(AWriter : TRESTDWBinaryPacketWriter; AFieldIndex : Integer;
                        ADBXType : Integer; AValue : TDBXValue);
Var
 S         : AnsiString;
 VSmall    : SmallInt;
 VWord     : Word;
 VInt      : Integer;
 VInt64    : Int64;
 VDouble   : Double;
 VCurrency : Currency;
 VBcd      : TBcd;
 VDateTime : TDateTime;
 VBool     : WordBool;
 Stm       : TStream;
 B         : TRESTDWMemBytes;
 L         : Integer;
Begin
 If (AValue = Nil) Or AValue.IsNull Then
  Begin
   AWriter.StoreNull(AFieldIndex);
   Exit;
  End;
 Case ADBXType Of
  TDBXDataTypes.AnsiStringType,
  TDBXDataTypes.WideStringType:
   Begin
    S := AnsiString(AValue.AsString);
    If Length(S) = 0 Then
     Begin
      AWriter.StoreField(AFieldIndex, Nil, 0)
     End
    Else
     Begin
      AWriter.StoreField(AFieldIndex, @S[1], Length(S));
     End;
   End;
  TDBXDataTypes.BooleanType:
   Begin
    VBool := AValue.AsBoolean;
    AWriter.StoreField(AFieldIndex, @VBool, SizeOf(VBool));
   End;
  TDBXDataTypes.Int8Type,
  TDBXDataTypes.Int16Type:
   Begin
    VSmall := AValue.AsInt16;
    AWriter.StoreField(AFieldIndex, @VSmall, SizeOf(VSmall));
   End;
  TDBXDataTypes.UInt8Type,
  TDBXDataTypes.UInt16Type:
   Begin
    VWord := AValue.AsUInt16;
    AWriter.StoreField(AFieldIndex, @VWord, SizeOf(VWord));
   End;
  TDBXDataTypes.Int32Type:
   Begin
    VInt := AValue.AsInt32;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  TDBXDataTypes.UInt32Type,
  TDBXDataTypes.Int64Type,
  TDBXDataTypes.UInt64Type:
   Begin
    VInt64 := AValue.AsInt64;
    AWriter.StoreField(AFieldIndex, @VInt64, SizeOf(VInt64));
   End;
  TDBXDataTypes.SingleType,
  TDBXDataTypes.DoubleType:
   Begin
    VDouble := AValue.AsDouble;
    AWriter.StoreField(AFieldIndex, @VDouble, SizeOf(VDouble));
   End;
  TDBXDataTypes.CurrencyType:
   Begin
    VCurrency := AValue.AsVariant;
    AWriter.StoreField(AFieldIndex, @VCurrency, SizeOf(VCurrency));
   End;
  TDBXDataTypes.BcdType:
   Begin
    VBcd := AValue.AsBcd;
    AWriter.StoreField(AFieldIndex, @VBcd, SizeOf(VBcd));
   End;
  TDBXDataTypes.DateType:
   Begin
    VDateTime := AValue.AsDateTime;
    VInt := DateTimeToTimeStamp(VDateTime).Date;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  TDBXDataTypes.TimeType:
   Begin
    VDateTime := AValue.AsDateTime;
    VInt := DateTimeToTimeStamp(VDateTime).Time;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  TDBXDataTypes.DateTimeType,
  TDBXDataTypes.TimeStampType,
  TDBXDataTypes.TimeStampOffsetType:
   Begin
    VDateTime := AValue.AsDateTime;
    AWriter.StoreField(AFieldIndex, @VDateTime, SizeOf(VDateTime));
   End;
  TDBXDataTypes.BytesType,
  TDBXDataTypes.VarBytesType,
  TDBXDataTypes.BlobType,
  TDBXDataTypes.BinaryBlobType:
   Begin
    Stm := AValue.AsStream;
    Try
     If Stm = Nil Then
      Begin
       AWriter.StoreField(AFieldIndex, Nil, 0)
      End
     Else
      Begin
       Stm.Position := 0;
       L := Stm.Size;
       SetLength(B, L);
       If L > 0 Then
        Begin
         Stm.ReadBuffer(B[0], L);
         AWriter.StoreField(AFieldIndex, @B[0], L);
        End
       Else
        Begin
         AWriter.StoreField(AFieldIndex, Nil, 0);
        End;
      End;
    Finally
     Stm.Free;
    End;
   End;
 Else
  Begin
   DatabaseError('dbExpress data type is not representable by the RESTDW DataSet binary contract: ' +
                 IntToStr(ADBXType));
  End;
 End;
End;

Procedure TRESTDWNativeDBExpressQuery.ExecSQL;
Begin
 Inherited ExecSQL;
 FRowsAffected:=TSQLQuery(Self.Owner).ExecSQL;
End;

Procedure TRESTDWNativeDBExpressQuery.Prepare;
Begin
 Inherited Prepare;
 TSQLQuery(Self.Owner).Prepared:=True;
End;

Function TRESTDWNativeDBExpressQuery.ParamCount : Integer;
Begin
 Result:=TSQLQuery(Self.Owner).Params.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   Result:=TSQLQuery(Self.Owner).Params.Count;
  End;
End;

Function TRESTDWNativeDBExpressQuery.RowsAffected : Int64;
Begin
 Result:=FRowsAffected;
End;

Function TRESTDWNativeDBExpressQuery.getParamDataType(IParam : Integer) : TFieldType;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].DataType;
End;

Function TRESTDWNativeDBExpressQuery.getParamName(IParam : Integer) : String;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].Name;
End;

Function TRESTDWNativeDBExpressQuery.getParamSize(IParam : Integer) : Integer;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].Size;
End;

Function TRESTDWNativeDBExpressQuery.getParamValue(IParam : Integer) : Variant;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].Value;
End;

Procedure TRESTDWNativeDBExpressQuery.setParamDataType(IParam : Integer; AValue : TFieldType);
Begin
 TSQLQuery(Self.Owner).Params[IParam].DataType:=AValue;
End;

Procedure TRESTDWNativeDBExpressQuery.setParamValue(IParam : Integer; AValue : Variant);
Begin
 TSQLQuery(Self.Owner).Params[IParam].Value:=AValue;
End;

Procedure TRESTDWNativeDBExpressQuery.LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                                         BlobType : TBlobType);
Begin
 TSQLQuery(Self.Owner).Params[IParam].LoadFromStream(Stream,BlobType);
End;

Function TRESTDWNativeLinkDBExpress.GetConnection : TComponent;
Begin
 Result := FConnection;
End;

Function TRESTDWNativeLinkDBExpress.GetQuery : TRESTDWDrvQuery;
Var
 Query : TSQLQuery;
Begin
 Result := Nil;
 If FConnection = Nil Then
  Exit;
 Query := TSQLQuery.Create(Self);
 Query.SQLConnection := FConnection;
 Query.ParamCheck := True;
 Result := TRESTDWNativeDBExpressQuery.Create(Query);
End;

Procedure TRESTDWNativeLinkDBExpress.SetConnection(AValue : TSQLConnection);
Begin
 If FConnection = AValue Then
  Begin
   Exit;
  End;
 If FConnection <> Nil Then
  Begin
   FConnection.RemoveFreeNotification(Self);
  End;
 FConnection := AValue;
 If FConnection <> Nil Then
  Begin
   FConnection.FreeNotification(Self);
  End;
End;

Procedure TRESTDWNativeLinkDBExpress.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If (Operation = opRemove) And (AComponent = FConnection) Then
  Begin
   FConnection := Nil;
  End;
End;

Function TRESTDWNativeLinkDBExpress.IsConnected : Boolean;
Begin
 Result := (FConnection <> Nil) And FConnection.Connected;
End;

Procedure TRESTDWNativeLinkDBExpress.Connect;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('dbExpress Connection not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
End;

Procedure TRESTDWNativeLinkDBExpress.Disconnect;
Begin
 If (FConnection <> Nil) And FConnection.Connected Then
  Begin
   FConnection.Connected := False;
  End;
End;

Procedure TRESTDWNativeLinkDBExpress.ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                                                   AOutput : TStream; ACompress : Boolean);
Var
 Cmd       : TDBXCommand;
 Reader    : TDBXReader;
 Writer    : TRESTDWBinaryPacketWriter;
 Fields    : TDirectFields;
 VT        : TDBXValueType;
 I         : Integer;
 C         : Integer;
 LSize     : Int64;
 LWordSize : Word;
 LType     : TFieldType;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('dbExpress Connection not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
 If FConnection.DBXConnection = Nil Then
  Begin
   DatabaseError('dbExpress native DBXConnection not available');
  End;
 Cmd := FConnection.DBXConnection.CreateCommand;
 Reader := Nil;
 Writer := TRESTDWBinaryPacketWriter.Create(AOutput);
 Try
  Cmd.CommandType := TDBXCommandTypes.DbxSQL;
  Cmd.Text := ASQL;
  Cmd.RowSetSize := 1000;
  BindDBXParams(Cmd, AParams);
  Reader := Cmd.ExecuteQuery;
  C := Reader.ColumnCount;
  SetLength(Fields, C);
  Writer.ClearFieldDefs;
  For I := 0 To C - 1 Do
   Begin
    VT := Reader.ValueType[I];
    Fields[I].Name        := VT.Name;
    Fields[I].DisplayName := VT.DisplayName;
    Fields[I].DBXType     := VT.DataType;
    Fields[I].DataType    := MapDBXDataType(VT.DataType);
    Fields[I].ReadOnly    := False;
    If Fields[I].DataType = ftUnknown Then
     Begin
      DatabaseError('dbExpress data type is not representable by the RESTDW DataSet binary contract: ' +
                    IntToStr(VT.DataType));
     End;
    If VT.DataType In [TDBXDataTypes.CurrencyType, TDBXDataTypes.BcdType] Then
     LSize := VT.Scale
    Else
     LSize := VT.Size;
    If LSize < 0 Then
     Begin
      LSize := -LSize;
     End;
    If LSize > High(Word) Then
     Begin
      LWordSize := High(Word)
     End
    Else
     Begin
      LWordSize := Word(LSize);
     End;
    Fields[I].Size := LWordSize;
    Writer.AddFieldDef(Fields[I].Name, Fields[I].DisplayName, Fields[I].Size,
                       Fields[I].DataType, Fields[I].ReadOnly);
   End;
  Writer.StoreFieldDefs(0);
  While Reader.Next Do
   Begin
    Writer.BeginRecord;
    For I := 0 To C - 1 Do
     Begin
      StoreDBXValue(Writer, I, Fields[I].DBXType, Reader.Value[I]);
     End;
    Writer.EndRecord;
   End;
 Finally
  Writer.Free;
  Reader.Free;
  Cmd.Free;
 End;
End;

Function TRESTDWNativeLinkDBExpress.ExecuteCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64;
Var
 Cmd : TDBXCommand;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('dbExpress Connection not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
 If FConnection.DBXConnection = Nil Then
  Begin
   DatabaseError('dbExpress native DBXConnection not available');
  End;
 Cmd := FConnection.DBXConnection.CreateCommand;
 Try
  Cmd.CommandType := TDBXCommandTypes.DbxSQL;
  Cmd.Text := ASQL;
  BindDBXParams(Cmd, AParams);
  Cmd.ExecuteUpdate;
  Result := Cmd.RowsAffected;
 Finally
  Cmd.Free;
 End;
End;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWNativeLinkDBExpress]);
End;
End.
