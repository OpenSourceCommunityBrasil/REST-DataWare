Unit uRESTDWNativeLinkSQLDB;

{$I uRESTDW.inc}

Interface

{$IFDEF FPC}

Uses
 {$IFDEF FPC}
 LResources,
{$ENDIF}
 Classes, SysUtils, DB, SQLDB, FMTBcd,
 uRESTDWNativeDriver, uRESTDWDriverBase, uRESTDWParams, uRESTDWMemoryDataset;

Type
 TRESTDWNativeLinkSQLDB = Class(TRESTDWNativeLink)
 Private
  FConnection : TSQLConnection;
  FTransaction : TSQLTransaction;
  Procedure SetConnection(AValue : TSQLConnection);
  Procedure SetTransaction(AValue : TSQLTransaction);
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
  Property Connection : TSQLConnection Read FConnection Write SetConnection;
  Property Transaction : TSQLTransaction Read FTransaction Write SetTransaction;
 End;

Procedure Register;

{$ENDIF}

Implementation

{$IFDEF FPC}

Type
 TRESTDWNativeSQLDBQuery = Class(TRESTDWDrvQuery)
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

 TSQLConnectionAccess = Class(TSQLConnection)
 Public
  Function NativeAllocateCursor : TSQLCursor;
  Procedure NativeDeAllocateCursor(Var ACursor : TSQLCursor);
  Procedure NativePrepare(ACursor : TSQLCursor; ATransaction : TSQLTransaction;
                          Const ASQL : String; AParams : TParams);
  Procedure NativeExecute(ACursor : TSQLCursor; ATransaction : TSQLTransaction;
                          AParams : TParams);
  Function NativeFetch(ACursor : TSQLCursor) : Boolean;
  Procedure NativeAddFieldDefs(ACursor : TSQLCursor; AFieldDefs : TFieldDefs);
  Function NativeLoadField(ACursor : TSQLCursor; AFieldDef : TFieldDef;
                           ABuffer : Pointer; Out ACreateBlob : Boolean) : Boolean;
  Procedure NativeUnPrepare(ACursor : TSQLCursor);
  Function NativeRowsAffected(ACursor : TSQLCursor) : Int64;
 End;

Function TSQLConnectionAccess.NativeAllocateCursor : TSQLCursor;
Begin
 Result := AllocateCursorHandle;
End;

Procedure TSQLConnectionAccess.NativeDeAllocateCursor(Var ACursor : TSQLCursor);
Begin
 DeAllocateCursorHandle(ACursor);
End;

Procedure TSQLConnectionAccess.NativePrepare(ACursor : TSQLCursor;
                                             ATransaction : TSQLTransaction;
                                             Const ASQL : String; AParams : TParams);
Begin
 PrepareStatement(ACursor, ATransaction, ASQL, AParams);
End;

Procedure TSQLConnectionAccess.NativeExecute(ACursor : TSQLCursor;
                                             ATransaction : TSQLTransaction;
                                             AParams : TParams);
Begin
 Execute(ACursor, ATransaction, AParams);
End;

Function TSQLConnectionAccess.NativeFetch(ACursor : TSQLCursor) : Boolean;
Begin
 Result := Fetch(ACursor);
End;

Procedure TSQLConnectionAccess.NativeAddFieldDefs(ACursor : TSQLCursor;
                                                  AFieldDefs : TFieldDefs);
Begin
 AddFieldDefs(ACursor, AFieldDefs);
End;

Function TSQLConnectionAccess.NativeLoadField(ACursor : TSQLCursor;
                                              AFieldDef : TFieldDef;
                                              ABuffer : Pointer;
                                              Out ACreateBlob : Boolean) : Boolean;
Begin
 Result := LoadField(ACursor, AFieldDef, ABuffer, ACreateBlob);
End;

Procedure TSQLConnectionAccess.NativeUnPrepare(ACursor : TSQLCursor);
Begin
 UnPrepareStatement(ACursor);
End;

Function TSQLConnectionAccess.NativeRowsAffected(ACursor : TSQLCursor) : Int64;
Begin
 Result := RowsAffected(ACursor);
End;

Procedure StoreSQLDBValue(AWriter : TRESTDWBinaryPacketWriter; AFieldIndex : Integer;
                          AFieldDef : TFieldDef; ABuffer : Pointer);
Var
 LSize      : Integer;
 VDateTime  : TDateTime;
 VWireValue : Integer;
 VTimeStamp : TTimeStamp;
Begin
 LSize := AFieldDef.Size;
 Case AFieldDef.DataType Of
  ftString,
  ftFixedChar,
  ftWideString,
  ftFixedWideChar:
   Begin
    If LSize < 1 Then
     Begin
      LSize := 1;
     End;
    AWriter.StoreField(AFieldIndex, ABuffer, StrLen(PChar(ABuffer)));
   End;
  ftSmallint: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(SmallInt));
  ftInteger: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Integer));
  ftAutoInc: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Int64));
  ftWord: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Word));
  ftLargeint: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Int64));
  ftBoolean: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(WordBool));
  ftFloat: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Double));
  ftCurrency,
  ftBCD: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Currency));
  ftFMTBcd: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(TBcd));
  ftDate:
   Begin
    Move(ABuffer^, VDateTime, SizeOf(VDateTime));
    VWireValue := Trunc(VDateTime) + 693594;
    AWriter.StoreField(AFieldIndex, @VWireValue, SizeOf(VWireValue));
   End;
  ftTime:
   Begin
    Move(ABuffer^, VDateTime, SizeOf(VDateTime));
    VTimeStamp := DateTimeToTimeStamp(VDateTime);
    VWireValue := VTimeStamp.Time;
    AWriter.StoreField(AFieldIndex, @VWireValue, SizeOf(VWireValue));
   End;
  ftDateTime,
  ftTimeStamp:
   Begin
    Move(ABuffer^, VDateTime, SizeOf(VDateTime));
    AWriter.StoreField(AFieldIndex, @VDateTime, SizeOf(VDateTime));
   End;
 Else
  Begin
   AWriter.StoreField(AFieldIndex, ABuffer, LSize);
  End;
 End;
End;

Procedure BindParams(AParams : TRESTDWParams; ADBParams : TParams);
Var
 I : Integer;
 P : TRESTDWJSONParam;
Begin
 If (AParams = Nil) Or (ADBParams = Nil) Then
  Begin
   Exit;
  End;
 For I := 0 To AParams.Count - 1 Do
  Begin
   P := AParams[I];
   If P = Nil Then
    Begin
     Continue;
    End;
   If I < ADBParams.Count Then
    Begin
     ADBParams[I].Value := P.Value;
    End;
  End;
End;

Procedure TRESTDWNativeSQLDBQuery.ExecSQL;
Begin
 Inherited ExecSQL;
 TSQLQuery(Self.Owner).ExecSQL;
End;

Procedure TRESTDWNativeSQLDBQuery.Prepare;
Begin
 Inherited Prepare;
 TSQLQuery(Self.Owner).Prepare;
End;

Function TRESTDWNativeSQLDBQuery.ParamCount : Integer;
Begin
 Result:=TSQLQuery(Self.Owner).Params.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   Result:=TSQLQuery(Self.Owner).Params.Count;
  End;
End;

Function TRESTDWNativeSQLDBQuery.RowsAffected : Int64;
Begin
 Result:=TSQLQuery(Self.Owner).RowsAffected;
End;

Function TRESTDWNativeSQLDBQuery.getParamDataType(IParam : Integer) : TFieldType;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].DataType;
End;

Function TRESTDWNativeSQLDBQuery.getParamName(IParam : Integer) : String;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].Name;
End;

Function TRESTDWNativeSQLDBQuery.getParamSize(IParam : Integer) : Integer;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].Size;
End;

Function TRESTDWNativeSQLDBQuery.getParamValue(IParam : Integer) : Variant;
Begin
 Result:=TSQLQuery(Self.Owner).Params[IParam].Value;
End;

Procedure TRESTDWNativeSQLDBQuery.setParamDataType(IParam : Integer; AValue : TFieldType);
Begin
 TSQLQuery(Self.Owner).Params[IParam].DataType:=AValue;
End;

Procedure TRESTDWNativeSQLDBQuery.setParamValue(IParam : Integer; AValue : Variant);
Begin
 TSQLQuery(Self.Owner).Params[IParam].Value:=AValue;
End;

Procedure TRESTDWNativeSQLDBQuery.LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                                     BlobType : TBlobType);
Begin
 TSQLQuery(Self.Owner).Params[IParam].LoadFromStream(Stream,BlobType);
End;

Function TRESTDWNativeLinkSQLDB.GetConnection : TComponent;
Begin
 Result := FConnection;
End;

Function TRESTDWNativeLinkSQLDB.GetQuery : TRESTDWDrvQuery;
Var
 Query        : TSQLQuery;
 LTransaction : TSQLTransaction;
Begin
 Result := Nil;
 If FConnection = Nil Then
  Exit;
 LTransaction := FTransaction;
 If LTransaction = Nil Then
  Begin
   LTransaction := FConnection.Transaction;
  End;
 Query := TSQLQuery.Create(Self);
 Query.SQLConnection := FConnection;
 Query.Transaction := LTransaction;
 Result := TRESTDWNativeSQLDBQuery.Create(Query);
End;

Procedure TRESTDWNativeLinkSQLDB.SetConnection(AValue : TSQLConnection);
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

Procedure TRESTDWNativeLinkSQLDB.SetTransaction(AValue : TSQLTransaction);
Begin
 If FTransaction = AValue Then
  Begin
   Exit;
  End;
 If FTransaction <> Nil Then
  Begin
   FTransaction.RemoveFreeNotification(Self);
  End;
 FTransaction := AValue;
 If FTransaction <> Nil Then
  Begin
   FTransaction.FreeNotification(Self);
  End;
End;

Procedure TRESTDWNativeLinkSQLDB.Notification(AComponent : TComponent;
                                              Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If Operation = opRemove Then
  Begin
   If AComponent = FConnection Then
    Begin
     FConnection := Nil;
    End;
   If AComponent = FTransaction Then
    Begin
     FTransaction := Nil;
    End;
  End;
End;

Function TRESTDWNativeLinkSQLDB.IsConnected : Boolean;
Begin
 Result := (FConnection <> Nil) And FConnection.Connected;
End;

Procedure TRESTDWNativeLinkSQLDB.Connect;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('SQLDB Connection not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
End;

Procedure TRESTDWNativeLinkSQLDB.Disconnect;
Begin
End;

Procedure TRESTDWNativeLinkSQLDB.ExecuteSelect(Const ASQL : String;
                                               AParams : TRESTDWParams;
                                               AOutput : TStream;
                                               ACompress : Boolean;
                                               ABinaryCompatibleMode : Boolean);
Var
 Query        : TSQLQuery;
 LTransaction : TSQLTransaction;
Begin
 If ABinaryCompatibleMode Then
  Begin
   ExecuteSelect(ASQL, AParams, AOutput, ACompress);
   Exit;
  End;
 If FConnection = Nil Then
  Begin
   DatabaseError('SQLDB Connection not assigned');
  End;
 LTransaction := FTransaction;
 If LTransaction = Nil Then
  Begin
   LTransaction := FConnection.Transaction;
  End;
 If LTransaction = Nil Then
  Begin
   DatabaseError('SQLDB Transaction not assigned');
  End;
 If LTransaction.Database <> FConnection Then
  Begin
   LTransaction.Database := FConnection;
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
 If Not LTransaction.Active Then
  Begin
   LTransaction.StartTransaction;
  End;
 Query := TSQLQuery.Create(Nil);
 Try
  Query.Database := FConnection;
  Query.Transaction := LTransaction;
  Query.SQL.Text := ASQL;
  BindParams(AParams, Query.Params);
  Query.Open;
  AOutput.Position := 0;
  AOutput.Size := 0;
  Query.SaveToStream(AOutput);
  AOutput.Position := 0;
 Finally
  Query.Free;
 End;
End;

Procedure TRESTDWNativeLinkSQLDB.ExecuteSelect(Const ASQL : String;
                                               AParams : TRESTDWParams;
                                               AOutput : TStream;
                                               ACompress : Boolean);
Var
 C          : TSQLConnectionAccess;
 Cursor     : TSQLCursor;
 Params     : TParams;
 FieldDefs  : TFieldDefs;
 Writer     : TRESTDWBinaryPacketWriter;
 I          : Integer;
 Buffer     : Pointer;
 BufferSize   : Integer;
 CreateBlob   : Boolean;
 LTransaction : TSQLTransaction;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('SQLDB Connection not assigned');
  End;
 LTransaction := FTransaction;
 If LTransaction = Nil Then
  Begin
   LTransaction := FConnection.Transaction;
  End;
 If LTransaction = Nil Then
  Begin
   DatabaseError('SQLDB Transaction not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
 If Not LTransaction.Active Then
  Begin
   LTransaction.StartTransaction;
  End;
 C := TSQLConnectionAccess(FConnection);
 Cursor := C.NativeAllocateCursor;
 Params := TParams.Create(Nil);
 FieldDefs := TFieldDefs.Create(Nil);
 AOutput.Position := 0;
 AOutput.Size := 0;
 Writer := TRESTDWBinaryPacketWriter.Create(AOutput);
{$IFDEF RESTDWLAZARUS}
 Writer.DatabaseCharSet := DatabaseCharSet;
{$ENDIF}
 Try
  C.NativePrepare(Cursor, LTransaction, ASQL, Params);
  BindParams(AParams, Params);
  C.NativeExecute(Cursor, LTransaction, Params);
  C.NativeAddFieldDefs(Cursor, FieldDefs);
  Writer.ClearFieldDefs;
  For I := 0 To FieldDefs.Count - 1 Do
   Begin
    Writer.AddFieldDef(FieldDefs[I].Name, FieldDefs[I].DisplayName,
                       FieldDefs[I].Size, FieldDefs[I].DataType,
                       False);
   End;
  Writer.StoreFieldDefs(1);
  While C.NativeFetch(Cursor) Do
   Begin
    Writer.BeginRecord;
    For I := 0 To FieldDefs.Count - 1 Do
     Begin
      BufferSize := FieldDefs[I].Size;
      If BufferSize < 32 Then
       Begin
        BufferSize := 32;
       End;
      If FieldDefs[I].DataType In ftBlobTypes Then
       Begin
        BufferSize := SizeOf(Pointer) * 4;
       End;
      GetMem(Buffer, BufferSize + 8);
      Try
       FillChar(Buffer^, BufferSize + 8, 0);
       CreateBlob := False;
       If C.NativeLoadField(Cursor, FieldDefs[I], Buffer, CreateBlob) Then
        Begin
         StoreSQLDBValue(Writer, I, FieldDefs[I], Buffer)
        End
       Else
        Begin
         Writer.StoreNull(I);
        End;
      Finally
       FreeMem(Buffer);
      End;
     End;
    Writer.EndRecord;
   End;
 Finally
  Writer.Free;
  FieldDefs.Free;
  Params.Free;
  C.NativeUnPrepare(Cursor);
  C.NativeDeAllocateCursor(Cursor);
 End;
 AOutput.Position := 0;
End;

Function TRESTDWNativeLinkSQLDB.ExecuteCommand(Const ASQL : String;
                                               AParams : TRESTDWParams) : Int64;
Var
 C            : TSQLConnectionAccess;
 Cursor       : TSQLCursor;
 Params       : TParams;
 LTransaction : TSQLTransaction;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('SQLDB Connection not assigned');
  End;
 LTransaction := FTransaction;
 If LTransaction = Nil Then
  Begin
   LTransaction := FConnection.Transaction;
  End;
 If LTransaction = Nil Then
  Begin
   DatabaseError('SQLDB Transaction not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
 If Not LTransaction.Active Then
  Begin
   LTransaction.StartTransaction;
  End;
 C := TSQLConnectionAccess(FConnection);
 Cursor := C.NativeAllocateCursor;
 Params := TParams.Create(Nil);
 Try
  C.NativePrepare(Cursor, LTransaction, ASQL, Params);
  BindParams(AParams, Params);
  C.NativeExecute(Cursor, LTransaction, Params);
  Result := C.NativeRowsAffected(Cursor);
 Finally
  Params.Free;
  C.NativeUnPrepare(Cursor);
  C.NativeDeAllocateCursor(Cursor);
 End;
End;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWNativeLinkSQLDB]);
End;

{$ENDIF}

Initialization
{$IFDEF FPC}
 {$I uRESTDWNativeLinkSQLDB.lrs}
{$ENDIF}
{$IFDEF FPC}

{$ENDIF}
End.
