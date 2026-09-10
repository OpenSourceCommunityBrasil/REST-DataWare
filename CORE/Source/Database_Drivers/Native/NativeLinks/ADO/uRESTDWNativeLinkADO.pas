Unit uRESTDWNativeLinkADO;

{$I uRESTDW.inc}

Interface

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes, System.SysUtils, System.Variants, Data.DB, Data.FMTBcd,
 Data.Win.ADODB, Winapi.ADOInt,
{$ELSE}
 Classes, SysUtils, Variants, DB, FMTBcd, ADODB, ADOInt,
{$ENDIF}
 uRESTDWNativeDriver, uRESTDWDriverBase, uRESTDWParams, uRESTDWMemoryDataset;

Type
 TRESTDWNativeLinkADO = Class(TRESTDWNativeLink)
 Private
  FConnection : TADOConnection;
  Procedure SetConnection(AValue : TADOConnection);
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
  Property Connection : TADOConnection Read FConnection Write SetConnection;
 End;

Procedure Register;

Implementation

Type
 TRESTDWNativeADOQuery = Class(TRESTDWDrvQuery)
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
  ADOType     : DataTypeEnum;
  Precision   : Byte;
  Scale       : Byte;
  ReadOnly    : Boolean;
 End;

 TDirectFields = Array Of TDirectField;

Function MapADODataType(AType : DataTypeEnum; APrecision, AScale : Integer) : TFieldType;
Begin
 Case AType Of
  adTinyInt,
  adSmallInt: Result := ftSmallint;
  adInteger: Result := ftInteger;
  adUnsignedInt,
  adUnsignedBigInt: Result := ftLargeint;
  adBigInt: Result := ftLargeint;
  adUnsignedTinyInt,
  adUnsignedSmallInt: Result := ftWord;
  adSingle,
  adDouble: Result := ftFloat;
  adCurrency: Result := ftBCD;
  adDecimal,
  adNumeric,
  adVarNumeric:
   Begin
    If (AScale > 4) Or (APrecision > 19) Then
     Begin
      Result := ftFMTBcd
     End
    Else
     Begin
      Result := ftBCD;
     End;
   End;
  adBoolean: Result := ftBoolean;
  adDBDate: Result := ftDate;
  adDBTime: Result := ftTime;
  adDate,
  adDBTimeStamp: Result := ftDateTime;
  adChar: Result := ftFixedChar;
  adVarChar: Result := ftString;
  adWChar:
{$IFDEF DELPHIXEUP}
   Result := ftFixedWideChar;
{$ELSE}
   Result := ftWideString;
{$ENDIF}
  adBSTR,
  adVarWChar: Result := ftWideString;
  adLongVarChar: Result := ftMemo;
  adLongVarWChar:
{$IFDEF DELPHIXEUP}
   Result := ftWideMemo;
{$ELSE}
   Result := ftMemo;
{$ENDIF}
  adLongVarBinary: Result := ftBlob;
  adBinary: Result := ftBytes;
  adVarBinary: Result := ftVarBytes;
  adGUID: Result := ftGuid;
 Else
  Begin
   Result := ftUnknown;
  End;
 End;
End;

Procedure VariantToBytes(Const AValue : OleVariant; Var ABytes : TRESTDWMemBytes);
Var
 L, I, LowB, HighB : Integer;
Begin
 SetLength(ABytes, 0);
 If Not VarIsArray(AValue) Then
  Begin
   Exit;
  End;
 LowB := VarArrayLowBound(AValue, 1);
 HighB := VarArrayHighBound(AValue, 1);
 L := HighB - LowB + 1;
 If L <= 0 Then
  Begin
   Exit;
  End;
 SetLength(ABytes, L);
 For I := 0 To L - 1 Do
  Begin
   ABytes[I] := Byte(AValue[LowB + I]);
  End;
End;

Procedure StoreADOValue(AWriter : TRESTDWBinaryPacketWriter; AFieldIndex : Integer;
                        Const AField : TDirectField; Const AValue : OleVariant);
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
 VGuid     : TGUID;
 B         : TRESTDWMemBytes;
Begin
 If VarIsNull(AValue) Or VarIsEmpty(AValue) Then
  Begin
   AWriter.StoreNull(AFieldIndex);
   Exit;
  End;
 Case AField.DataType Of
  ftString,
  ftFixedChar,
  ftWideString,
{$IFDEF DELPHIXEUP}
  ftFixedWideChar,
{$ENDIF}
  ftMemo
{$IFDEF DELPHIXEUP}
  , ftWideMemo
{$ENDIF}
  :
   Begin
    S := AnsiString(VarToStr(AValue));
    If Length(S) = 0 Then
     Begin
      AWriter.StoreField(AFieldIndex, Nil, 0)
     End
    Else
     Begin
      AWriter.StoreField(AFieldIndex, @S[1], Length(S));
     End;
   End;
  ftSmallint:
   Begin
    VSmall := AValue;
    AWriter.StoreField(AFieldIndex, @VSmall, SizeOf(VSmall));
   End;
  ftInteger:
   Begin
    VInt := AValue;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  ftWord:
   Begin
    VWord := AValue;
    AWriter.StoreField(AFieldIndex, @VWord, SizeOf(VWord));
   End;
  ftLargeint:
   Begin
    VInt64 := AValue;
    AWriter.StoreField(AFieldIndex, @VInt64, SizeOf(VInt64));
   End;
  ftBoolean:
   Begin
    VBool := AValue;
    AWriter.StoreField(AFieldIndex, @VBool, SizeOf(VBool));
   End;
  ftFloat:
   Begin
    VDouble := AValue;
    AWriter.StoreField(AFieldIndex, @VDouble, SizeOf(VDouble));
   End;
  ftCurrency,
  ftBCD:
   Begin
    VCurrency := AValue;
    AWriter.StoreField(AFieldIndex, @VCurrency, SizeOf(VCurrency));
   End;
  ftFMTBcd:
   Begin
    VBcd := StrToBcd(VarToStr(AValue));
    AWriter.StoreField(AFieldIndex, @VBcd, SizeOf(VBcd));
   End;
  ftDate:
   Begin
    VDateTime := VarToDateTime(AValue);
    VInt := DateTimeToTimeStamp(VDateTime).Date;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  ftTime:
   Begin
    VDateTime := VarToDateTime(AValue);
    VInt := DateTimeToTimeStamp(VDateTime).Time;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  ftDateTime:
   Begin
    VDateTime := VarToDateTime(AValue);
    AWriter.StoreField(AFieldIndex, @VDateTime, SizeOf(VDateTime));
   End;
  ftGuid:
   Begin
    VGuid := StringToGUID(VarToStr(AValue));
    AWriter.StoreField(AFieldIndex, @VGuid, SizeOf(VGuid));
   End;
  ftBytes,
  ftVarBytes,
  ftBlob:
   Begin
    VariantToBytes(AValue, B);
    If Length(B) = 0 Then
     Begin
      AWriter.StoreField(AFieldIndex, Nil, 0)
     End
    Else
     Begin
      AWriter.StoreField(AFieldIndex, @B[0], Length(B));
     End;
   End;
 Else
  Begin
   DatabaseError('ADO data type is not representable by the RESTDW DataSet binary contract');
  End;
 End;
End;

Procedure BindADOParams(ACommand : TADOCommand; AParams : TRESTDWParams);
Var
 I  : Integer;
 P  : TRESTDWJSONParam;
 AP : TParameter;
Begin
 If (ACommand = Nil) Or (AParams = Nil) Then
  Begin
   Exit;
  End;
 ACommand.Parameters.Refresh;
 For I := 0 To AParams.Count - 1 Do
  Begin
   P := AParams[I];
   If P = Nil Then
    Begin
     Continue;
    End;
   AP := ACommand.Parameters.FindParam(P.ParamName);
   If AP <> Nil Then
    Begin
     AP.Value := P.Value;
    End;
  End;
End;

Procedure TRESTDWNativeADOQuery.ExecSQL;
Begin
 Inherited ExecSQL;
 FRowsAffected:=TADOQuery(Self.Owner).ExecSQL;
End;

Procedure TRESTDWNativeADOQuery.Prepare;
Begin
 Inherited Prepare;
 TADOQuery(Self.Owner).Prepared:=True;
End;

Function TRESTDWNativeADOQuery.ParamCount : Integer;
Begin
 Result:=TADOQuery(Self.Owner).Parameters.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   Result:=TADOQuery(Self.Owner).Parameters.Count;
  End;
End;

Function TRESTDWNativeADOQuery.RowsAffected : Int64;
Begin
 Result:=FRowsAffected;
End;

Function TRESTDWNativeADOQuery.getParamDataType(IParam : Integer) : TFieldType;
Begin
 Result:=TADOQuery(Self.Owner).Parameters[IParam].DataType;
End;

Function TRESTDWNativeADOQuery.getParamName(IParam : Integer) : String;
Begin
 Result:=TADOQuery(Self.Owner).Parameters[IParam].Name;
End;

Function TRESTDWNativeADOQuery.getParamSize(IParam : Integer) : Integer;
Begin
 Result:=TADOQuery(Self.Owner).Parameters[IParam].Size;
End;

Function TRESTDWNativeADOQuery.getParamValue(IParam : Integer) : Variant;
Begin
 Result:=TADOQuery(Self.Owner).Parameters[IParam].Value;
End;

Procedure TRESTDWNativeADOQuery.setParamDataType(IParam : Integer; AValue : TFieldType);
Begin
 TADOQuery(Self.Owner).Parameters[IParam].DataType:=AValue;
End;

Procedure TRESTDWNativeADOQuery.setParamValue(IParam : Integer; AValue : Variant);
Begin
 TADOQuery(Self.Owner).Parameters[IParam].Value:=AValue;
End;

Procedure TRESTDWNativeADOQuery.LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                                   BlobType : TBlobType);
Begin
 TADOQuery(Self.Owner).Parameters[IParam].LoadFromStream(Stream,TFieldType(BlobType));
End;

Function TRESTDWNativeLinkADO.GetConnection : TComponent;
Begin
 Result := FConnection;
End;

Function TRESTDWNativeLinkADO.GetQuery : TRESTDWDrvQuery;
Var
 Query : TADOQuery;
Begin
 Result := Nil;
 If FConnection = Nil Then
  Exit;
 Query := TADOQuery.Create(Self);
 Query.Connection := FConnection;
 Query.ParamCheck := True;
 Result := TRESTDWNativeADOQuery.Create(Query);
End;

Procedure TRESTDWNativeLinkADO.SetConnection(AValue : TADOConnection);
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

Procedure TRESTDWNativeLinkADO.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If (Operation = opRemove) And (AComponent = FConnection) Then
  Begin
   FConnection := Nil;
  End;
End;

Function TRESTDWNativeLinkADO.IsConnected : Boolean;
Begin
 Result := (FConnection <> Nil) And FConnection.Connected;
End;

Procedure TRESTDWNativeLinkADO.Connect;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('ADO Connection not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
End;

Procedure TRESTDWNativeLinkADO.Disconnect;
Begin
 If (FConnection <> Nil) And FConnection.Connected Then
  Begin
   FConnection.Connected := False;
  End;
End;

Procedure TRESTDWNativeLinkADO.ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                                             AOutput : TStream; ACompress : Boolean);
Var
 Cmd       : TADOCommand;
 RS        : _Recordset;
 Writer    : TRESTDWBinaryPacketWriter;
 Fields    : TDirectFields;
 F         : Field;
 I         : Integer;
 C         : Integer;
 LSize     : Integer;
 LWordSize : Word;
 LType     : TFieldType;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('ADO Connection not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
 Cmd := TADOCommand.Create(Nil);
 RS := Nil;
 Writer := TRESTDWBinaryPacketWriter.Create(AOutput);
 Try
  Cmd.Connection := FConnection;
  Cmd.CommandType := cmdText;
  Cmd.CommandText := ASQL;
  BindADOParams(Cmd, AParams);
  RS := Cmd.Execute;
  C := RS.Fields.Count;
  SetLength(Fields, C);
  Writer.ClearFieldDefs;
  For I := 0 To C - 1 Do
   Begin
    F := RS.Fields.Item[I];
    Fields[I].Name        := String(F.Name);
    Fields[I].DisplayName := String(F.Name);
    Fields[I].ADOType     := F.Type_;
    Fields[I].Precision   := F.Precision;
    Fields[I].Scale       := F.NumericScale;
    LType                 := MapADODataType(F.Type_, F.Precision, F.NumericScale);
    Fields[I].DataType    := LType;
    If LType = ftUnknown Then
     Begin
      DatabaseError('ADO data type is not representable by the RESTDW DataSet binary contract: ' +
                    IntToStr(Ord(F.Type_)));
     End;
    If LType In [ftBCD, ftFMTBcd] Then
     LSize := F.NumericScale
    Else
     LSize := F.DefinedSize;
    If LSize < 0 Then
     Begin
      LSize := -LSize;
     End;
    If LType = ftGuid Then
     Begin
      LSize := 38;
     End;
    If LSize > High(Word) Then
     Begin
      LWordSize := High(Word)
     End
    Else
     Begin
      LWordSize := Word(LSize);
     End;
    Fields[I].Size     := LWordSize;
    Fields[I].ReadOnly := (F.Attributes And adFldUpdatable) = 0;
    Writer.AddFieldDef(Fields[I].Name, Fields[I].DisplayName, Fields[I].Size,
                       Fields[I].DataType, Fields[I].ReadOnly);
   End;
  Writer.StoreFieldDefs(0);
  While Not RS.EOF Do
   Begin
    Writer.BeginRecord;
    For I := 0 To C - 1 Do
     Begin
      StoreADOValue(Writer, I, Fields[I], RS.Fields.Item[I].Value);
     End;
    Writer.EndRecord;
    RS.MoveNext;
   End;
 Finally
  Writer.Free;
  RS := Nil;
  Cmd.Free;
 End;
End;

Function TRESTDWNativeLinkADO.ExecuteCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64;
Var
 Cmd      : TADOCommand;
 Affected : Integer;
Begin
 If FConnection = Nil Then
  Begin
   DatabaseError('ADO Connection not assigned');
  End;
 If Not FConnection.Connected Then
  Begin
   FConnection.Connected := True;
  End;
 Cmd := TADOCommand.Create(Nil);
 Try
  Cmd.Connection := FConnection;
  Cmd.CommandType := cmdText;
  Cmd.CommandText := ASQL;
  BindADOParams(Cmd, AParams);
  Affected := 0;
  Cmd.Execute(Affected, EmptyParam);
  Result := Affected;
 Finally
  Cmd.Free;
 End;
End;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWNativeLinkADO]);
End;
End.
