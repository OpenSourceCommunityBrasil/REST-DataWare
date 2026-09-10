Unit uRESTDWNativeLinkFD;

{$I uRESTDW.inc}

Interface

Uses
 Classes, SysUtils, Variants, DB, FMTBcd, SqlTimSt,
 FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Util, FireDAC.DatS,
 FireDAC.Phys.Intf, FireDAC.Phys, FireDAC.Comp.Client,
 uRESTDWNativeDriver, uRESTDWDriverBase, uRESTDWParams, uRESTDWMemoryDataset;

Type
 TRESTDWNativeLinkFD = Class(TRESTDWNativeLink)
 Private
  FConnection : TFDConnection;
  Procedure SetConnection(AValue : TFDConnection);
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
  Property Connection : TFDConnection Read FConnection Write SetConnection;
 End;

Procedure Register;

Implementation

Type
 TRESTDWNativeFDQuery = Class(TRESTDWDrvQuery)
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

 TFDConnectionAccess = Class(TFDConnection);
 PRESTDWUInt64       = ^UInt64;

 TDirectField = Record
  Name        : String;
  DisplayName : String;
  Size        : Word;
  DataType    : TFieldType;
  FDType      : TFDDataType;
  ReadOnly    : Boolean;
 End;

 TDirectFields = Array Of TDirectField;

Function MapDataType(AType : TFDDataType) : TFieldType;
Begin
 Case AType Of
  dtBoolean: Result := ftBoolean;
  dtSByte,
  dtInt16: Result := ftSmallint;
  dtInt32: Result := ftInteger;
  dtInt64: Result := ftLargeint;
  dtByte,
  dtUInt16: Result := ftWord;
  dtUInt32,
  dtUInt64: Result := ftLargeint;
  dtSingle: Result := ftFloat;
  dtDouble,
  dtExtended: Result := ftFloat;
  dtCurrency: Result := ftBCD;
  dtBCD: Result := ftBCD;
  dtFmtBCD: Result := ftFMTBcd;
  dtDate: Result := ftDate;
  dtTime: Result := ftTime;
  dtDateTime: Result := ftDateTime;
  dtDateTimeStamp: Result := ftDateTime;
{$IFDEF DELPHI10_4UP}
  dtDateTimeStampOff: Result := ftDateTime;
{$ENDIF}
  dtAnsiString: Result := ftString;
  dtWideString: Result := ftWideString;
  dtByteString: Result := ftVarBytes;
  dtBlob,
  dtHBlob,
  dtHBFile: Result := ftBlob;
  dtMemo,
  dtHMemo,
  dtXML: Result := ftMemo;
  dtWideMemo,
  dtWideHMemo: Result := ftWideMemo;
  dtGUID: Result := ftGuid;
 Else
  Result := ftUnknown;
 End;
End;

Procedure StoreFireDACValue(AWriter : TRESTDWBinaryPacketWriter;
                            AFieldIndex : Integer; AFDType : TFDDataType;
                            ABuffer : Pointer; ADataLen : LongWord);
Var
 S         : AnsiString;
 WS        : WideString;
 VSmall    : SmallInt;
 VWord     : Word;
 VInt      : Integer;
 VInt64    : Int64;
 VSingle   : Single;
 VDouble   : Double;
 VCurrency : Currency;
 VBcd      : TBcd;
 VDateTime : TDateTime;
{$IFDEF DELPHI10_4UP}
 VTimeStampOffset : TSQLTimeStampOffset;
{$ENDIF}
 VBool     : WordBool;
 VGuid     : TGUID;
Begin
 If ABuffer = Nil Then
  Begin
   AWriter.StoreNull(AFieldIndex);
   Exit;
  End;
 Case AFDType Of
  dtAnsiString:
   AWriter.StoreField(AFieldIndex, ABuffer, ADataLen);
  dtWideString:
   Begin
    SetLength(WS, ADataLen);
    If ADataLen > 0 Then
     Move(ABuffer^, WS[1], ADataLen * SizeOf(WideChar));
    S := AnsiString(String(WS));
    AWriter.StoreField(AFieldIndex, Pointer(S), Length(S));
   End;
  dtByteString,
  dtBlob,
  dtHBlob,
  dtHBFile,
  dtMemo,
  dtHMemo,
  dtXML: AWriter.StoreField(AFieldIndex, ABuffer, ADataLen);
  dtWideMemo,
  dtWideHMemo: AWriter.StoreField(AFieldIndex, ABuffer, ADataLen * SizeOf(WideChar));
  dtBoolean:
   Begin
    VBool := PWordBool(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VBool, SizeOf(VBool));
   End;
  dtSByte:
   Begin
    VSmall := PShortInt(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VSmall, SizeOf(VSmall));
   End;
  dtInt16: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(SmallInt));
  dtInt32: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Integer));
  dtInt64: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Int64));
  dtByte:
   Begin
    VWord := PByte(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VWord, SizeOf(VWord));
   End;
  dtUInt16: AWriter.StoreField(AFieldIndex, ABuffer, SizeOf(Word));
  dtUInt32:
   Begin
    VInt64 := PCardinal(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VInt64, SizeOf(VInt64));
   End;
  dtUInt64:
   Begin
    If PRESTDWUInt64(ABuffer)^ > UInt64(High(Int64)) Then
     DatabaseError('FireDAC UInt64 value exceeds RESTDW DataSet ftLargeInt range');
    VInt64 := Int64(PRESTDWUInt64(ABuffer)^);
    AWriter.StoreField(AFieldIndex, @VInt64, SizeOf(VInt64));
   End;
  dtSingle:
   Begin
    VDouble := PSingle(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VDouble, SizeOf(VDouble));
   End;
  dtDouble:
   Begin
    VDouble := PDouble(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VDouble, SizeOf(VDouble));
   End;
  dtExtended:
   Begin
    VDouble := PExtended(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VDouble, SizeOf(VDouble));
   End;
  dtCurrency:
   Begin
    VCurrency := PCurrency(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VCurrency, SizeOf(VCurrency));
   End;
  dtBCD:
   Begin
    VBcd := PBcd(ABuffer)^;
    If Not BcdToCurr(VBcd, VCurrency) Then
     DatabaseError('FireDAC BCD value cannot be represented by RESTDW DataSet ftBCD');
    AWriter.StoreField(AFieldIndex, @VCurrency, SizeOf(VCurrency));
   End;
  dtFmtBCD:
   Begin
    VBcd := PBcd(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VBcd, SizeOf(VBcd));
   End;
  dtDate:
   Begin
    VInt := PInteger(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  dtTime:
   Begin
    VDateTime := FDTime2DateTime(PInteger(ABuffer)^);
    VInt := DateTimeToTimeStamp(VDateTime).Time;
    AWriter.StoreField(AFieldIndex, @VInt, SizeOf(VInt));
   End;
  dtDateTime:
   Begin
    VDateTime := FDMSecs2DateTime(PDateTimeRec(ABuffer)^.DateTime);
    AWriter.StoreField(AFieldIndex, @VDateTime, SizeOf(VDateTime));
   End;
  dtDateTimeStamp:
   Begin
    VDateTime := SQLTimeStampToDateTime(PSQLTimeStamp(ABuffer)^);
    AWriter.StoreField(AFieldIndex, @VDateTime, SizeOf(VDateTime));
   End;
{$IFDEF DELPHI10_4UP}
  dtDateTimeStampOff:
   Begin
    Move(ABuffer^, VTimeStampOffset, SizeOf(VTimeStampOffset));
    VDateTime := SQLTimeStampOffsetToDateTime(VTimeStampOffset);
    AWriter.StoreField(AFieldIndex, @VDateTime, SizeOf(VDateTime));
   End;
{$ENDIF}
  dtGUID:
   Begin
    VGuid := PGUID(ABuffer)^;
    AWriter.StoreField(AFieldIndex, @VGuid, SizeOf(VGuid));
   End;
 Else
  AWriter.StoreField(AFieldIndex, ABuffer, ADataLen);
 End;
End;

Procedure BindParams(ACmd : IFDPhysCommand; AParams : TRESTDWParams);
Var
 I  : Integer;
 P  : TRESTDWJSONParam;
 FP : TFDParam;
Begin
 If (AParams = Nil) Or (ACmd = Nil) Then
  Exit;
 For I := 0 To AParams.Count - 1 Do
  Begin
   P := AParams[I];
   If P = Nil Then
    Continue;
   FP := ACmd.Params.FindParam(P.ParamName);
   If FP <> Nil Then
    FP.Value := P.Value;
  End;
End;

Procedure TRESTDWNativeFDQuery.ExecSQL;
Begin
 Inherited ExecSQL;
 TFDQuery(Self.Owner).ExecSQL;
End;

Procedure TRESTDWNativeFDQuery.Prepare;
Begin
 Inherited Prepare;
 TFDQuery(Self.Owner).Prepare;
End;

Function TRESTDWNativeFDQuery.ParamCount : Integer;
Begin
 Result:=TFDQuery(Self.Owner).Params.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   Result:=TFDQuery(Self.Owner).Params.Count;
  End;
End;

Function TRESTDWNativeFDQuery.RowsAffected : Int64;
Begin
 Result:=TFDQuery(Self.Owner).RowsAffected;
End;

Function TRESTDWNativeFDQuery.getParamDataType(IParam : Integer) : TFieldType;
Begin
 Result:=TFDQuery(Self.Owner).Params[IParam].DataType;
End;

Function TRESTDWNativeFDQuery.getParamName(IParam : Integer) : String;
Begin
 Result:=TFDQuery(Self.Owner).Params[IParam].Name;
End;

Function TRESTDWNativeFDQuery.getParamSize(IParam : Integer) : Integer;
Begin
 Result:=TFDQuery(Self.Owner).Params[IParam].Size;
End;

Function TRESTDWNativeFDQuery.getParamValue(IParam : Integer) : Variant;
Begin
 Result:=TFDQuery(Self.Owner).Params[IParam].Value;
End;

Procedure TRESTDWNativeFDQuery.setParamDataType(IParam : Integer; AValue : TFieldType);
Begin
 TFDQuery(Self.Owner).Params[IParam].DataType:=AValue;
End;

Procedure TRESTDWNativeFDQuery.setParamValue(IParam : Integer; AValue : Variant);
Begin
 TFDQuery(Self.Owner).Params[IParam].Value:=AValue;
End;

Procedure TRESTDWNativeFDQuery.LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                                  BlobType : TBlobType);
Begin
 TFDQuery(Self.Owner).Params[IParam].LoadFromStream(Stream,BlobType);
End;

Function TRESTDWNativeLinkFD.GetConnection : TComponent;
Begin
 Result := FConnection;
End;

Function TRESTDWNativeLinkFD.GetQuery : TRESTDWDrvQuery;
Var
 Query : TFDQuery;
Begin
 Result := Nil;
 If FConnection = Nil Then
  Exit;
 Query := TFDQuery.Create(Self);
 Query.Connection := FConnection;
 Query.ResourceOptions.ParamCreate := True;
 Query.ResourceOptions.StoreItems := [siMeta, siData, siDelta];
 Query.FetchOptions.Mode := fmAll;
 Result := TRESTDWNativeFDQuery.Create(Query);
End;

Procedure TRESTDWNativeLinkFD.SetConnection(AValue : TFDConnection);
Begin
 If FConnection = AValue Then
  Exit;
 If FConnection <> Nil Then
  FConnection.RemoveFreeNotification(Self);
 FConnection := AValue;
 If FConnection <> Nil Then
  FConnection.FreeNotification(Self);
End;

Procedure TRESTDWNativeLinkFD.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If (Operation = opRemove) And (AComponent = FConnection) Then
  FConnection := Nil;
End;

Function TRESTDWNativeLinkFD.IsConnected : Boolean;
Begin
 Result := (FConnection <> Nil) And FConnection.Connected;
End;

Procedure TRESTDWNativeLinkFD.Connect;
Begin
 If FConnection = Nil Then
  DatabaseError('FireDAC Connection not assigned');
 If Not FConnection.Connected Then
  FConnection.Connected := True;
End;

Procedure TRESTDWNativeLinkFD.Disconnect;
Begin
 If (FConnection <> Nil) And FConnection.Connected Then
  FConnection.Connected := False;
End;

Procedure TRESTDWNativeLinkFD.ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                                            AOutput : TStream; ACompress : Boolean;
                                            ABinaryCompatibleMode : Boolean);
Var
 Query : TFDQuery;
 Param : TRESTDWJSONParam;
 I     : Integer;
Begin
 If ABinaryCompatibleMode Then
  Begin
   ExecuteSelect(ASQL, AParams, AOutput, ACompress);
   Exit;
  End;
 If FConnection = Nil Then
  DatabaseError('FireDAC Connection not assigned');
 If Not FConnection.Connected Then
  FConnection.Connected := True;
 Query := TFDQuery.Create(Nil);
 Try
  Query.Connection := FConnection;
  Query.SQL.Text := ASQL;
  If AParams <> Nil Then
   Begin
    For I := 0 To AParams.Count - 1 Do
     Begin
      Param := AParams[I];
      If (Param <> Nil) And (Query.Params.FindParam(Param.ParamName) <> Nil) Then
       Query.Params.ParamByName(Param.ParamName).Value := Param.Value;
     End;
   End;
  Query.Open;
  AOutput.Position := 0;
  AOutput.Size := 0;
  Query.SaveToStream(AOutput, sfBinary);
  AOutput.Position := 0;
 Finally
  Query.Free;
 End;
End;

Procedure TRESTDWNativeLinkFD.ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                                            AOutput : TStream; ACompress : Boolean);
Var
 P         : IFDPhysConnection;
 Cmd       : IFDPhysCommand;
 Tab       : TFDDatSTable;
 Row       : TFDDatSRow;
 Col       : TFDDatSColumn;
 Writer    : TRESTDWBinaryPacketWriter;
 Fields    : TDirectFields;
 A, I      : Integer;
 Data      : Pointer;
 DataLen   : LongWord;
 LSize     : LongWord;
 LWordSize : Word;
 LType     : TFieldType;
 VTimeStamp : TSQLTimeStamp;
 VDateTime  : TDateTime;
Begin
 If FConnection = Nil Then
  DatabaseError('FireDAC Connection not assigned');
 If Not FConnection.Connected Then
  FConnection.Connected := True;
 P := TFDConnectionAccess(FConnection).ConnectionIntf;
 P.CreateCommand(Cmd);
 Cmd.CommandText := ASQL;
 Cmd.Options.FetchOptions.RowsetSize := 1000;
 Cmd.Prepare;
 BindParams(Cmd, AParams);
 Tab := Cmd.Define;
 SetLength(Fields, Tab.Columns.Count);
 Writer := TRESTDWBinaryPacketWriter.Create(AOutput);
 Try
  Writer.ClearFieldDefs;
  For I := 0 To Tab.Columns.Count - 1 Do
   Begin
    Col                   := Tab.Columns.ItemsI[I];
    Fields[I].Name        := Col.Name;
    Fields[I].DisplayName := Col.Name;
    Fields[I].FDType      := Col.DataType;
    LType                 := MapDataType(Col.DataType);
    Fields[I].DataType    := LType;
    If LType = ftUnknown Then
     DatabaseError('FireDAC data type is not representable by the RESTDW DataSet binary contract: ' +
                   IntToStr(Ord(Col.DataType)));
    LSize := Col.Size;
    If Col.DataType = dtCurrency Then
     Begin
      LSize := Col.Scale;
      If LSize < 0 Then
       LSize := -LSize;
     End;
    If LType = ftGuid Then
     LSize := 38;
    If LSize > High(Word) Then
     LWordSize := High(Word)
    Else
     LWordSize := Word(LSize);
    Fields[I].Size     := LWordSize;
    Fields[I].ReadOnly := caReadOnly in Col.Attributes;
    Writer.AddFieldDef(Fields[I].Name, Fields[I].DisplayName, Fields[I].Size,
                       Fields[I].DataType, Fields[I].ReadOnly);
   End;
  Writer.StoreFieldDefs(0);
  Cmd.Open;
  Repeat
   Tab.Clear;
   Cmd.Fetch(Tab, False, False);
   If Tab.Rows.Count = 0 Then
    Break;
   For A := 0 To Tab.Rows.Count - 1 Do
    Begin
     Row := Tab.Rows.ItemsI[A];
     Writer.BeginRecord;
     For I := 0 To Tab.Columns.Count - 1 Do
      Begin
       If Fields[I].FDType = dtDateTimeStamp Then
        Begin
         FillChar(VTimeStamp, SizeOf(VTimeStamp), 0);
         Data := @VTimeStamp;
         DataLen := 0;
         If Row.GetData(I, rvDefault, Data, SizeOf(VTimeStamp), DataLen, True) Then
          Begin
           VDateTime := SQLTimeStampToDateTime(VTimeStamp);
           Writer.StoreField(I, @VDateTime, SizeOf(VDateTime));
          End
         Else
          Writer.StoreNull(I);
        End
       Else
        Begin
         Data    := Nil;
         DataLen := 0;
         If Row.GetData(I, rvDefault, Data, 0, DataLen, False) Then
          StoreFireDACValue(Writer, I, Fields[I].FDType, Data, DataLen)
         Else
          Writer.StoreNull(I);
        End;
      End;
     Writer.EndRecord;
    End;
  Until False;
 Finally
  Writer.Free;
  Cmd := Nil;
 End;
End;

Function TRESTDWNativeLinkFD.ExecuteCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64;
Var
 Q  : TFDQuery;
 I  : Integer;
 P  : TRESTDWJSONParam;
 FP : TFDParam;
Begin
 If FConnection = Nil Then
  DatabaseError('FireDAC Connection not assigned');
 Q := TFDQuery.Create(Nil);
 Try
  Q.Connection := FConnection;
  Q.SQL.Text    := ASQL;
  Q.Prepare;
  If AParams <> Nil Then
   For I := 0 To AParams.Count - 1 Do
    Begin
     P := AParams[I];
     If P = Nil Then
      Continue;
     FP := Q.Params.FindParam(P.ParamName);
     If FP <> Nil Then
      FP.Value := P.Value;
    End;
  Q.ExecSQL;
  Result := Q.RowsAffected;
 Finally
  Q.Free;
 End;
End;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWNativeLinkFD]);
End;

End.
