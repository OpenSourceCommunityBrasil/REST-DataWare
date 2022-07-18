unit uRestDWDriverFD;

interface

uses System.SysUtils,          System.Classes,      Data.DBXJSON,
     FireDAC.Stan.Intf,        FireDAC.Stan.Option, FireDAC.Stan.Param,
     FireDAC.Stan.Error,       FireDAC.DatS,        FireDAC.Stan.Async,
     FireDAC.DApt,             FireDAC.UI.Intf,     FireDAC.Stan.Def,
     FireDAC.Stan.Pool,        FireDAC.Comp.Client, FireDAC.Comp.UI,
     FireDAC.Comp.DataSet,     FireDAC.DApt.Intf,
     {$IFNDEF FPC}
      {$IF CompilerVersion > 26} // Delphi XE6 pra cima
      FireDAC.Stan.StorageBin,
      {$IFEND}
     {$ENDIF}
     FireDAC.Phys.Intf,        Data.DB, uDWConsts,  uDWConstsData,
     uRestDWPoolerDB,          uDWJSONInterface,    uDWJSONObject,
     uDWMassiveBuffer,         Variants,            uDWDatamodule,
     SysTypes,                 uSystemEvents,       uDWDataset;

Type
 TFDCustomTableRDW = class(TFDTable)
 Public
  Property RowsAffected;
End;

Type
 TRESTDWDriverFD   = Class(TRESTDWDriver)
 Private
  vFDConnection                 : TFDConnection;
  Procedure SetConnection(Value : TFDConnection);
  Function  GetConnection       : TFDConnection;
 protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Function  ConnectionSet                                 : Boolean;Override;
  Function  GetGenID                (Query                : TComponent;
                                     GenName              : String): Integer;Override;
  Function ApplyUpdatesTB           (Massive              : String;
                                     Params               : TDWParams;
                                     Var Error            : Boolean;
                                     Var MessageError     : String;
                                     Var RowsAffected     : Integer)          : TJSONValue;Override;
//  Function ApplyUpdates_MassiveCacheTB(MassiveCache         : String;
//                                       Var Error            : Boolean;
//                                       Var MessageError     : String)           : TJSONValue;Override;
  Function ExecuteCommandTB         (Tablename            : String;
                                     Var Error            : Boolean;
                                     Var MessageError     : String;
                                     Var BinaryBlob       : TMemoryStream;
                                     Var RowsAffected     : Integer;
                                     BinaryEvent          : Boolean = False;
                                     MetaData             : Boolean = False;
                                     BinaryCompatibleMode : Boolean = False)  : String;Overload;Override;
  Function ExecuteCommandTB         (Tablename            : String;
                                     Params               : TDWParams;
                                     Var Error            : Boolean;
                                     Var MessageError     : String;
                                     Var BinaryBlob       : TMemoryStream;
                                     Var RowsAffected     : Integer;
                                     BinaryEvent          : Boolean = False;
                                     MetaData             : Boolean = False;
                                     BinaryCompatibleMode : Boolean = False)  : String;Overload;Override;
  Function ApplyUpdates             (Massive,
                                     SQL                   : String;
                                     Params                : TDWParams;
                                     Var Error             : Boolean;
                                     Var MessageError      : String;
                                     Var RowsAffected      : Integer)          : TJSONValue;Override;
  Function ApplyUpdates_MassiveCache(MassiveCache          : String;
                                     Var Error             : Boolean;
                                     Var MessageError      : String)          : TJSONValue;Override;
  Function ProcessMassiveSQLCache   (MassiveSQLCache       : String;
                                     Var Error             : Boolean;
                                     Var MessageError      : String)           : TJSONValue;Override;
  Function ExecuteCommand            (SQL                  : String;
                                      Var Error            : Boolean;
                                      Var MessageError     : String;
                                      Var BinaryBlob       : TMemoryStream;
                                      Var RowsAffected     : Integer;
                                      Execute              : Boolean = False;
                                      BinaryEvent          : Boolean = False;
                                      MetaData             : Boolean = False;
                                      BinaryCompatibleMode : Boolean = False) : String;Overload;Override;
  Function ExecuteCommand            (SQL                  : String;
                                      Params               : TDWParams;
                                      Var Error            : Boolean;
                                      Var MessageError     : String;
                                      Var BinaryBlob       : TMemoryStream;
                                      Var RowsAffected     : Integer;
                                      Execute              : Boolean = False;
                                      BinaryEvent          : Boolean = False;
                                      MetaData             : Boolean = False;
                                      BinaryCompatibleMode : Boolean = False) : String;Overload;Override;
  Function InsertMySQLReturnID       (SQL                  : String;
                                      Var Error            : Boolean;
                                      Var MessageError     : String)          : Integer;Overload;Override;
  Function InsertMySQLReturnID       (SQL                  : String;
                                      Params               : TDWParams;
                                      Var Error            : Boolean;
                                      Var MessageError     : String)          : Integer;Overload;Override;
  Procedure ExecuteProcedure         (ProcName             : String;
                                      Params               : TDWParams;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);Override;
  Procedure ExecuteProcedurePure     (ProcName             : String;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);Override;
  Function  OpenDatasets             (DatasetsLine         : String;
                                      Var Error            : Boolean;
                                      Var MessageError     : String;
                                      Var BinaryBlob       : TMemoryStream)          : TJSONValue;Override;
  Procedure GetTableNames            (Var TableNames       : TStringList;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);Override;
  Procedure GetFieldNames            (TableName            : String;
                                      Var FieldNames       : TStringList;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);Override;
  Procedure GetKeyFieldNames         (TableName            : String;
                                      Var FieldNames       : TStringList;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);Override;
  Procedure GetProcNames             (Var ProcNames        : TStringList;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);                  Override;
  Procedure GetProcParams            (ProcName             : String;
                                      Var ParamNames       : TStringList;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);                  Override;
  Procedure Close;Override;
  Class Procedure CreateConnection   (Const ConnectionDefs : TConnectionDefs;
                                      Var   Connection     : TObject);        Override;
  Procedure PrepareConnection        (Var   ConnectionDefs : TConnectionDefs);Override;
 Published
  Property Connection : TFDConnection Read GetConnection Write SetConnection;
End;



Procedure Register;

implementation

Uses uDWJSONTools;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverFD]);
End;

Function TRESTDWDriverFD.ProcessMassiveSQLCache(MassiveSQLCache      : String;
                                                Var Error            : Boolean;
                                                Var MessageError     : String) : TJSONValue;
Var
 vTempQuery        : TFDQuery;
 vStringStream     : TMemoryStream;
 bPrimaryKeys      : TStringList;
 vFieldType        : TFieldType;
 vStateResource,
 vMassiveLine      : Boolean;
 vResultReflection : String;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TFDQuery) : Boolean;
 Var
  X, A, I         : Integer;
  vMassiveSQLMode : TMassiveSQLMode;
  vSQL,
  vParamsString,
  vBookmark,
  vParamName      : String;
  vBinaryRequest  : Boolean;
  vDWParams       : TDWParams;
  bJsonValueB     : TDWJSONBase;
  bJsonValue      : TDWJSONObject;
  bJsonArray      : TDWJSONArray;
 Begin
  bJsonValue     := TDWJSONObject.Create(MassiveSQLCache);
  bJsonArray     := TDWJSONArray(bJsonValue);
  Result         := False;
  Try
   For X := 0 To bJsonArray.ElementCount -1 Do
    Begin
     bJsonValueB := bJsonArray.GetObject(X);//bJsonArray.get(X);
     If Not vFDConnection.InTransaction Then
      Begin
       {$IF CompilerVersion >= 30}
        If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
       {$IFEND}
       vFDConnection.StartTransaction;
      End;
     vDWParams          := TDWParams.Create;
     vDWParams.Encoding := Encoding;
     Try
//      TDWJSONObject(bJsonValueB).ToJSON;
      vMassiveSQLMode := MassiveSQLMode(TDWJSONObject(bJsonValueB).pairs[0].Value);
      vSQL            := StringReplace(DecodeStrings(TDWJSONObject(bJsonValueB).pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}), #$B, ' ', [rfReplaceAll]);
      vParamsString   := DecodeStrings(TDWJSONObject(bJsonValueB).pairs[2].Value{$IFDEF FPC}, csUndefined{$ENDIF});
      vBookmark       := TDWJSONObject(bJsonValueB).pairs[3].Value;
      vBinaryRequest  := StringToBoolean(TDWJSONObject(bJsonValueB).pairs[4].Value);
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
                         If vTempQuery.ResourceOptions.ParamCreate then
                          begin
                           Try
                           // vTempQuery.Prepare;
                           Except
                           End;
                           For I := 0 To vDWParams.Count -1 Do
                            Begin
                             If vTempQuery.ParamCount > I Then
                              Begin
                               vParamName := Copy(StringReplace(vDWParams[I].ParamName, ',', '', []), 1, Length(vDWParams[I].ParamName));
                               A          := GetParamIndex(vTempQuery.Params, vParamName);
                               If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
                                Begin
                                 If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       {$IF CompilerVersion > 22}Data.{$IFEND}DB.ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString]    Then
                                  Begin
                                   // fernando is not null protection
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
                                   If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                                    Begin
                                     If (Not (vDWParams[I].isNull)) Then
                                      Begin
                                       If vTempQuery.Params[A].DataType in [ftLongWord, ftLargeint] Then
                                        vTempQuery.Params[A].AsLargeInt := StrToInt64(vDWParams[I].Value)
                                       Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                                        vTempQuery.Params[A].AsSmallInt := StrToInt(vDWParams[I].Value)
                                       Else
                                        vTempQuery.Params[A].AsInteger  := StrToInt(vDWParams[I].Value);
                                      End
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End
                                   Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
                                      vDWParams[I].SaveToStream(vStringStream);
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
                                     // fernando
                                     //If (Trim(vDWParams[I].Value) <> '') Then
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
                          End
                         Else
                          Begin
                           For I := 0 To vDWParams.Count -1 Do
                            begin
                             With vTempQuery.Params.Add do
                              Begin
                               vParamName := Copy(StringReplace(vDWParams[I].ParamName, ',', '', []), 1, Length(vDWParams[I].ParamName));
                               Name := vParamName;
                               ParamType := ptInput;
                               If Not (ObjectValueToFieldType(vDWParams[I].ObjectValue) in [ftUnknown]) Then
                                DataType := ObjectValueToFieldType(vDWParams[I].ObjectValue)
                               Else
                                DataType := ftString;
                               If vTempQuery.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                                Begin
                                 If (Not (vDWParams[I].IsNull)) Then
                                  Begin
                                   // Alterado por: Alexandre Magno - 04/11/2017
                                   If vTempQuery.Params[I].DataType in [ftLongWord, ftLargeint] Then
                                    vTempQuery.Params[I].AsLargeInt := StrToInt64(vDWParams[I].Value)
                                   Else If vTempQuery.Params[I].DataType = ftSmallInt Then
                                    vTempQuery.Params[I].AsSmallInt := StrToInt(vDWParams[I].Value)
                                   Else
                                    vTempQuery.Params[I].AsInteger  := StrToInt(vDWParams[I].Value);
                                  End
                                 Else
                                  vTempQuery.Params[I].Clear;
                                End
                                Else If vTempQuery.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
                                 Begin
                                  If (Not (vDWParams[I].IsNull)) Then
                                   vTempQuery.Params[I].AsFloat  := StrToFloat(BuildFloatString(vDWParams[I].Value))
                                  Else
                                   vTempQuery.Params[I].Clear;
                                 End
                                Else If vTempQuery.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                                 Begin
                                  If (Not (vDWParams[I].IsNull)) Then
                                   Begin
                                    If vTempQuery.Params[I].DataType = ftDate Then
                                     vTempQuery.Params[I].AsDate     := vDWParams[I].AsDateTime
                                    Else If vTempQuery.Params[I].DataType = ftTime Then
                                     vTempQuery.Params[I].AsTime     := vDWParams[I].AsDateTime
                                    Else
                                     vTempQuery.Params[I].AsDateTime := vDWParams[I].AsDateTime;
                                   End
                                  Else
                                   vTempQuery.Params[I].Clear;
                                 End  //Tratar Blobs de Parametros...
                                Else If vTempQuery.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                          ftGraphic, ftOraBlob, ftOraClob] Then
                                 Begin
                                  If Not Assigned(vStringStream) Then
                                   vStringStream  := TMemoryStream.Create;
                                  Try
                                   vDWParams[I].SaveToStream(vStringStream);
                                   vStringStream.Position := 0;
                                   If Assigned(vStringStream) Then
                                    If vStringStream.Size > 0 Then
                                     vTempQuery.Params[I].LoadFromStream(vStringStream, ftBlob);
                                  Finally
                                   If Assigned(vStringStream) Then
                                    FreeAndNil(vStringStream);
                                  End;
                                 End
                                Else If vTempQuery.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                          ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                          ftString,    ftWideString,
                                                                          ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                                    {$IF CompilerVersion > 21}
                                                                                    , ftWideMemo
                                                                                    {$IFEND}
                                                                                   {$ENDIF}]    Then
                                 Begin
                                  If (Not (vDWParams[I].IsNull)) Then
                                   vTempQuery.Params[I].AsString := vDWParams[I].Value
                                  Else
                                   vTempQuery.Params[I].Clear;
                                 End
                                Else
                                 vTempQuery.Params[I].Value    := vDWParams[I].Value;
                              End;
                            End;
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
      If vFDConnection.InTransaction Then
       Begin
        {$IF CompilerVersion >= 30}
         If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
        {$IFEND}
          vFDConnection.Commit;
       End;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If vFDConnection.InTransaction Then
        {$IF CompilerVersion >= 30}
         If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
        {$IFEND}
         vFDConnection.Rollback;
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
  vTempQuery := TFDQuery.Create(Owner);
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
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
  vFDConnection.Connected := vStateResource;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
End;

Function TRESTDWDriverFD.ApplyUpdates_MassiveCache(MassiveCache     : String;
                                                   Var Error        : Boolean;
                                                   Var MessageError : String)  : TJSONValue;
Var
 vTempQuery        : TFDQuery;
 vStringStream     : TMemoryStream;
 bPrimaryKeys      : TStringList;
 vFieldType        : TFieldType;
 vStateResource,
 vMassiveLine      : Boolean;
 vResultReflection : String;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
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
  If MassiveDataset.Fields.FieldByName(DWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s, "mycomptag":"%s"}', [MassiveDataset.Fields.FieldByName(DWFieldBookmark).Value, ', "reflectionlines":[%s]', MassiveDataset.MyCompTag]);
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
                                        vFieldChanged := Encodeb64Stream(vStringStream) <> MassiveField.Value;
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
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, Encodeb64Stream(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, Encodeb64Stream(vStringStream)]);
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
 Function LoadMassive(Massive : String; Var Query : TFDQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, X           : Integer;
  bJsonValueB    : TDWJSONBase;
  bJsonValue     : TDWJSONObject;
  bJsonArray     : TDWJSONArray;
  Procedure PrepareData(Var Query      : TFDQuery;
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
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
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
                // Alterado por: Alexandre Magno - 04/11/2017
                If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftLongWord, ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                Else
                 Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD,ftFMTBcd, ftSingle] Then
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
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            // Alterado por: Alexandre Magno - 04/11/2017
            If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(DWFieldBookmark)))) Then
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
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then
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
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(DWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(DWFieldBookmark)))) Then
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
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           Query.FindField(MassiveDataset.Fields.Items[I].FieldName).Required          := False;
           Query.FindField(MassiveDataset.Fields.Items[I].FieldName).AutoGenerateValue := arAutoInc;
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
      BuildDatasetLine(TDataset(Query), MassiveDataset, True);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
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
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(vStringStream);
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
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
  bJsonValue     := TDWJSONObject.Create(MassiveCache);
  bJsonArray     := TDWJSONArray(bJsonValue);
  Result         := False;
  Try
   For x := 0 To bJsonArray.ElementCount -1 Do
    Begin
     bJsonValueB := bJsonArray.GetObject(X);//bJsonArray.get(X);
     If Not vFDConnection.InTransaction Then
      Begin
       {$IF CompilerVersion >= 30}
        If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
       {$IFEND}
         vFDConnection.StartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Try
      MassiveDataset.FromJSON(TDWJSONObject(bJsonValueB).ToJSON);
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
          Query.ExecSQL;
        Except
         On E : Exception do
          Begin
           Error  := True;
           Result := False;
           If vFDConnection.InTransaction Then
           {$IF CompilerVersion >= 30}
            If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
           {$IFEND}
             vFDConnection.Rollback;
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
      If vFDConnection.InTransaction Then
       Begin
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
           TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
         End;
        {$IF CompilerVersion >= 30}
         If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
        {$IFEND}
          vFDConnection.Commit;
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
        If vFDConnection.InTransaction Then
        {$IF CompilerVersion >= 30}
         If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
        {$IFEND}
          vFDConnection.Rollback;
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
  vTempQuery := TFDQuery.Create(Owner);
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
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
  vFDConnection.Connected := vStateResource;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
End;

Procedure TRESTDWDriverFD.Close;
Begin
  Inherited;
 If Connection <> Nil Then
  Connection.Close;
End;

Function TRESTDWDriverFD.ConnectionSet : Boolean;
Begin
 Result := vFDConnection <> Nil;
End;

Class Procedure TRESTDWDriverFD.CreateConnection(Const ConnectionDefs : TConnectionDefs;
                                                 Var Connection       : TObject);
 Procedure ServerParamValue(ParamName, Value : String);
 Var
  I, vIndex : Integer;
  vFound : Boolean;
 Begin
  vFound := False;
  vIndex := -1;
  For I := 0 To TFDConnection(Connection).Params.Count -1 Do
   Begin
    If Lowercase(TFDConnection(Connection).Params.Names[I]) = Lowercase(ParamName) Then
     Begin
      vFound := True;
      vIndex := I;
      Break;
     End;
   End;
  If Not (vFound) Then
   TFDConnection(Connection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Lowercase(Value)]))
  Else
   TFDConnection(Connection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Lowercase(Value)]);
 End;
Begin
 Inherited;
 If Assigned(ConnectionDefs) Then
  Begin
   Case ConnectionDefs.DriverType Of
    dbtUndefined  : Begin

                    End;
    dbtAccess     : Begin
                     TFDConnection(Connection).DriverName := 'MSAcc';

                    End;
    dbtDbase      : Begin

                    End;
    dbtFirebird   : Begin
                     TFDConnection(Connection).DriverName := 'FB';
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtInterbase  : Begin
                     TFDConnection(Connection).DriverName := 'IB';
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtMySQL      : Begin
                     TFDConnection(Connection).DriverName := 'MYSQL';
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                    End;
    dbtSQLLite    : Begin
                     TFDConnection(Connection).DriverName := 'SQLLite';
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                    End;
    dbtOracle     : Begin
                     TFDConnection(Connection).DriverName := 'Ora';

                    End;
    dbtMsSQL      : Begin
                     TFDConnection(Connection).DriverName := 'MSSQL';
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtODBC       : Begin
                     TFDConnection(Connection).DriverName := 'ODBC';
                     ServerParamValue('DataSource', ConnectionDefs.DataSource);
                    End;
    dbtParadox    : Begin

                    End;
    dbtPostgreSQL : Begin
                     TFDConnection(Connection).DriverName := 'PG';
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                    End;
   End;
  End;
End;

function TRESTDWDriverFD.ExecuteCommand(SQL                  : String;
                                        Params               : TDWParams;
                                        Var Error            : Boolean;
                                        Var MessageError     : String;
                                        Var BinaryBlob       : TMemoryStream;
                                        Var RowsAffected     : Integer;
                                        Execute              : Boolean = False;
                                        BinaryEvent          : Boolean = False;
                                        MetaData             : Boolean = False;
                                        BinaryCompatibleMode : Boolean = False) : String;
Var
 vTempQuery     : TFDQuery;
 A, I           : Integer;
 vParamName     : String;
 vStateResource : Boolean;
 vStringStream  : TMemoryStream;
 aResult        : TJSONValue;
 vDWMemtable1   : tDWMemtable;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
 Inherited;
 Error  := False;
 Result := '';
 vStringStream := Nil;
 aResult := TJSONValue.Create;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  If Not vFDConnection.InTransaction Then
   Begin
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
    vFDConnection.StartTransaction;
   End;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.ResourceOptions.ParamCreate  := ParamCreate;
  vTempQuery.ResourceOptions.StoreItems   := [siMeta, siData, siDelta];
  vTempQuery.FetchOptions.Mode            := fmAll;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Params <> Nil Then
   Begin
    if vTempQuery.ResourceOptions.ParamCreate then
    begin
      Try
      // vTempQuery.Prepare;
      Except
      End;
      For I := 0 To Params.Count -1 Do
       Begin
        If (vTempQuery.ParamCount > I) And (Not (Params[I].IsNull)) Then
         Begin
          vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
          A          := GetParamIndex(vTempQuery.Params, vParamName);
          If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
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
              If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
               Begin
                If (Not (Params[I].IsNull)) Then
                 Begin
                  If vTempQuery.Params[A].DataType in [ftLongWord, ftLargeint] Then
                   vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                  Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                   vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                  Else
                   vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                 End
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
//                  vTempQuery.Params[A].AsDateTime  := Params[I].AsDateTime
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
                 Params[I].SaveToStream(vStringStream);
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
                If (Trim(Params[I].Value) <> '') Then
                 vTempQuery.Params[A].AsString := Params[I].Value
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else If vTempQuery.Params[A].DataType in [ftGuid] Then
               Begin
                If (Not (Params[I].IsNull)) Then
                 vTempQuery.Params[A].AsGUID   := StringToGUID(Params[I].AsString)
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
     end
     Else
      Begin
       For I := 0 To Params.Count -1 Do
        begin
         With vTempQuery.Params.Add do
          Begin
           vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
           Name := vParamName;
           ParamType := ptInput;
           If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
            DataType := ObjectValueToFieldType(Params[I].ObjectValue)
           Else
            DataType := ftString;
           If vTempQuery.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
            Begin
             If (Not (Params[I].IsNull)) Then
              Begin
               // Alterado por: Alexandre Magno - 04/11/2017
               If vTempQuery.Params[I].DataType in [ftLongWord, ftLargeint] Then
                vTempQuery.Params[I].AsLargeInt := StrToInt64(Params[I].Value)
               Else If vTempQuery.Params[I].DataType = ftSmallInt Then
                vTempQuery.Params[I].AsSmallInt := StrToInt(Params[I].Value)
               Else
                vTempQuery.Params[I].AsInteger  := StrToInt(Params[I].Value);
              End
             Else
              vTempQuery.Params[I].Clear;
            End
            Else If vTempQuery.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               vTempQuery.Params[I].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
              Else
               vTempQuery.Params[I].Clear;
             End
            Else If vTempQuery.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               Begin
                If vTempQuery.Params[I].DataType = ftDate Then
                 vTempQuery.Params[I].AsDate     := Params[I].AsDateTime
                Else If vTempQuery.Params[I].DataType = ftTime Then
                 vTempQuery.Params[I].AsTime     := Params[I].AsDateTime
                Else
                 vTempQuery.Params[I].AsDateTime := Params[I].AsDateTime;
               End
              Else
               vTempQuery.Params[I].Clear;
             End  //Tratar Blobs de Parametros...
            Else If vTempQuery.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                      ftGraphic, ftOraBlob, ftOraClob] Then
             Begin
              If Not Assigned(vStringStream) Then
               vStringStream  := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(vStringStream);
               vStringStream.Position := 0;
               If Assigned(vStringStream) Then
                If vStringStream.Size > 0 Then
                 vTempQuery.Params[I].LoadFromStream(vStringStream, ftBlob);
              Finally
               If Assigned(vStringStream) Then
                FreeAndNil(vStringStream);
              End;
             End
            Else If vTempQuery.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                      ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                      ftString,    ftWideString,
                                                      ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                {$IF CompilerVersion > 21}
                                                                , ftWideMemo
                                                                {$IFEND}
                                                               {$ENDIF}]    Then
             Begin
              If (Not (Params[I].IsNull)) Then
               vTempQuery.Params[I].AsString := Params[I].Value
              Else
               vTempQuery.Params[I].Clear;
             End
            Else If vTempQuery.Params[I].DataType in [ftGuid] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               vTempQuery.Params[I].AsGUID   := StringToGUID(Params[I].AsString)
              Else
               vTempQuery.Params[I].Clear;
             End
            Else
             vTempQuery.Params[I].Value    := Params[I].Value;
          End;
        End;
      End;
   End;
  If Not Execute Then
   Begin
     If Assigned(Self.OnQueryBeforeOpen) Then
      Self.OnQueryBeforeOpen(TDataset(vTempQuery), Params);
    vTempQuery.Open;
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
     If vFDConnection.InTransaction Then
      vFDConnection.Commit;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
    aResult.Encoding := Encoding;
    Try
     If Not BinaryEvent Then
      Begin
       aResult.Utf8SpecialChars := True;
       aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
       Result := aResult.ToJSON;
      End
     Else If Not BinaryCompatibleMode Then
      Begin
       If Not Assigned(BinaryBlob) Then
        BinaryBlob := TMemoryStream.Create;
       Try
        vTempQuery.SaveToStream(BinaryBlob, sfBinary);
        BinaryBlob.Position := 0;
       Finally
       End;
      End
     Else
      TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
    Finally
    End;
   End
  Else
   Begin
    If Assigned(Self.OnQueryBeforeOpen) Then
      Self.OnQueryBeforeOpen(TDataset(vTempQuery), Params);
    vTempQuery.ExecSQL;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
     If vFDConnection.InTransaction Then
      vFDConnection.Commit;
    aResult.SetValue('COMMANDOK');
    Result := aResult.ToJSON;
   End;
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     If aResult = Nil Then
      aResult := TJSONValue.Create;
     aResult.Encoded := True;
     aResult.SetValue(GetPairJSON('NOK', MessageError));
     Result := aResult.ToJSON;
     If vFDConnection.InTransaction Then
     {$IF CompilerVersion >= 30}
      If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
     {$IFEND}
       vFDConnection.Rollback;

     If Assigned(Self.OnQueryException) Then
      Self.OnQueryException(TDataset(vTempQuery), Params, E.Message);
    Except
    End;
    vFDConnection.Connected := False;
   End;
 End;
 FreeAndNil(aResult);
 RowsAffected := vTempQuery.RowsAffected;
 vTempQuery.Close;
 vTempQuery.Free;
End;

procedure TRESTDWDriverFD.ExecuteProcedure(ProcName         : String;
                                           Params           : TDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String);
Var
 A, I            : Integer;
 vParamName      : String;
 vStateResource  : Boolean;
 vTempStoredProc : TFDStoredProc;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
 Inherited;
 Error  := False;
 vTempStoredProc                               := TFDStoredProc.Create(Owner);
 vStateResource                                := vFDConnection.Connected;
 If Not vFDConnection.Connected Then
  vFDConnection.Connected := True;
 If Not vFDConnection.InTransaction Then
  {$IF CompilerVersion >= 30}
  If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
   {$IFEND}
   vFDConnection.StartTransaction;
 Try
  vTempStoredProc.Connection                   := vFDConnection;
  vTempStoredProc.FormatOptions.StrsTrim       := StrsTrim;
  vTempStoredProc.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempStoredProc.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempStoredProc.StoredProcName               := ProcName;
  If Params <> Nil Then
   Begin
    Try
     vTempStoredProc.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If vTempStoredProc.ParamCount > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := GetParamIndex(vTempStoredProc.Params, vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If vTempStoredProc.Params[A].DataType in [ftFixedChar, ftFixedWideChar,
                                                    ftString,    ftWideString]    Then
           Begin
            If vTempStoredProc.Params[A].Size > 0 Then
             vTempStoredProc.Params[A].Value := Copy(Params[I].Value, 1, vTempStoredProc.Params[A].Size)
            Else
             vTempStoredProc.Params[A].Value := Params[I].Value;
           End
          Else
           Begin
            If vTempStoredProc.Params[A].DataType in [ftUnknown] Then
             vTempStoredProc.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue);
            vTempStoredProc.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else
       Break;
     End;
   End;
  vTempStoredProc.ExecProc;
  If vFDConnection.InTransaction Then
   {$IF CompilerVersion >= 30}
   If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
   {$IFEND}
    vFDConnection.Commit;
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     If vFDConnection.InTransaction Then
     {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
     {$IFEND}
      vFDConnection.Rollback;
    Except
    End;
    Error := True;
    MessageError := E.Message;
    vFDConnection.Connected := False;
   End;
 End;
 vTempStoredProc.DisposeOf;
End;

procedure TRESTDWDriverFD.ExecuteProcedurePure(ProcName         : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String);
Var
 vTempStoredProc : TFDStoredProc;
 vStateResource  : Boolean;
Begin
 Inherited;
 Error                                         := False;
 vTempStoredProc                               := TFDStoredProc.Create(Owner);
 Try
  vStateResource                               := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempStoredProc.Connection                   := vFDConnection;
  vTempStoredProc.FormatOptions.StrsTrim       := StrsTrim;
  vTempStoredProc.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempStoredProc.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempStoredProc.StoredProcName               := ProcName;
  vTempStoredProc.ExecProc;
  If vFDConnection.InTransaction Then
  {$IF CompilerVersion >= 30}
   If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
  {$IFEND}
   vFDConnection.Commit;
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     If vFDConnection.InTransaction Then
     {$IF CompilerVersion >= 30}
      If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
     {$IFEND}
      vFDConnection.Rollback;
    Except
    End;
    Error := True;
    MessageError := E.Message;
    vFDConnection.Connected := False;
   End;
 End;
 vTempStoredProc.DisposeOf;
End;

Function TRESTDWDriverFD.ApplyUpdates(Massive,
                                      SQL               : String;
                                      Params            : TDWParams;
                                      Var Error         : Boolean;
                                      Var MessageError  : String;
                                      Var RowsAffected  : Integer) : TJSONValue;
Var
 vTempQuery     : TFDQuery;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
 vMassiveLine   : Boolean;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
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
  If MassiveDataset.Fields.FieldByName(DWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(DWFieldBookmark).Value, ', "reflectionlines":[%s]']);
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
                                        vFieldChanged := Encodeb64Stream(vStringStream) <> MassiveField.Value;
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
                                                             Encodeb64Stream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 Encodeb64Stream(vStringStream)]); // StreamToHex(vStringStream)]);
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
 Function LoadMassive(Massive : String; Var Query : TFDQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TFDQuery;
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
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
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
                // Alterado por: Alexandre Magno - 04/11/2017
                If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftLongWord, ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                Else
                 Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD,ftFMTBcd, ftSingle] Then
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
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            // Alterado por: Alexandre Magno - 04/11/2017
            If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(DWFieldBookmark)))) Then
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
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then
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
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(DWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(DWFieldBookmark)))) Then
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
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           Query.FindField(MassiveDataset.Fields.Items[I].FieldName).Required          := False;
           Query.FindField(MassiveDataset.Fields.Items[I].FieldName).AutoGenerateValue := arAutoInc;
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
      BuildDatasetLine(TDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
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
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(vStringStream);
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
               Else  If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
  Try
   Result         := False;
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
     If Not vFDConnection.InTransaction Then
      Begin
      {$IF CompilerVersion >= 30}
       If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
      {$IFEND}
        vFDConnection.StartTransaction;
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
        If vFDConnection.InTransaction Then
        {$IF CompilerVersion >= 30}
         If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
        {$IFEND}
          vFDConnection.Rollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If vFDConnection.InTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
          {$IF CompilerVersion >= 30}
           If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
          {$IFEND}
           vFDConnection.Commit;
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
          If vFDConnection.InTransaction Then
          {$IF CompilerVersion >= 30}
           If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
          {$IFEND}
            vFDConnection.Rollback;
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
    If vFDConnection.InTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
      {$IF CompilerVersion >= 30}
       If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
      {$IFEND}
       vFDConnection.Commit;
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
      If vFDConnection.InTransaction Then
      {$IF CompilerVersion >= 30}
       If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
      {$IFEND}
        vFDConnection.Rollback;
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
  vTempQuery := TFDQuery.Create(Nil);
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
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
             A          := GetParamIndex(vTempQuery.Params, vParamName);
             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
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
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [ftLongWord, ftLargeint] Then
                      vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
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
       vTempQuery.Open;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
       Error         := False;
       vFDConnection.Connected := vStateResource;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          Result.SetValue(GetPairJSON('NOK', MessageError));
          If vFDConnection.InTransaction Then
          {$IF CompilerVersion >= 30}
           If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
          {$IFEND}
           vFDConnection.Rollback;
         Except
         End;
         vFDConnection.Connected := False;
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
End;

Function TRESTDWDriverFD.ExecuteCommand(SQL                  : String;
                                        Var Error            : Boolean;
                                        Var MessageError     : String;
                                        Var BinaryBlob       : TMemoryStream;
                                        Var RowsAffected     : Integer;
                                        Execute              : Boolean = False;
                                        BinaryEvent          : Boolean = False;
                                        MetaData             : Boolean = False;
                                        BinaryCompatibleMode : Boolean = False) : String;
Var
 vTempQuery   : TFDQuery;
 aResult      : TJSONValue;
// vStream      : TMemoryStream;
 vDWMemtable1 : tDWMemtable;
 vStateResource : Boolean;
Begin
 Inherited;
 Result := '';
 Error  := False;
 aResult := Nil;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  If Not vFDConnection.InTransaction Then
   Begin
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
    vFDConnection.StartTransaction;
   End;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.ResourceOptions.StoreItems   := [siMeta, siData, siDelta];
  vTempQuery.FetchOptions.Mode            := fmAll;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Not Execute Then
   Begin
    If Assigned(Self.OnQueryBeforeOpen) Then
     Self.OnQueryBeforeOpen(TDataset(vTempQuery), nil);
    vTempQuery.Open;
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
     If vFDConnection.InTransaction Then
      vFDConnection.Commit;
    vTempQuery.fetchall;
    aResult         := TJSONValue.Create;
    aResult.Encoding := Encoding;
    Try
     If Not BinaryEvent Then
      Begin
       aResult.Utf8SpecialChars := True;
       aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
       Result := aResult.ToJSON;
      End
     Else If Not BinaryCompatibleMode Then
      Begin
       If Not Assigned(BinaryBlob) Then
        BinaryBlob := TMemoryStream.Create;
       Try
        vTempQuery.SaveToStream(BinaryBlob, sfBinary);
        BinaryBlob.Position := 0;
       Finally
       End;
      End
     Else
      TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
     FreeAndNil(aResult);
     Error         := False;
    Finally
    End;
   End
  Else
   Begin
    try
      If Assigned(Self.OnQueryBeforeOpen) Then
       Self.OnQueryBeforeOpen(TDataset(vTempQuery), nil);
      vTempQuery.ExecSQL;
      If aResult = Nil Then
       aResult := TJSONValue.Create;
      {$IF CompilerVersion >= 30}
       If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
      {$IFEND}
       vFDConnection.Commit;
      aResult.SetValue('COMMANDOK');
      Result := aResult.ToJSON;
      FreeAndNil(aResult);
      Error         := False;
    Finally
    End;
   End;
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     Error          := True;
     MessageError   := E.Message;
     If aResult = Nil Then
      aResult        := TJSONValue.Create;
     //Alexandre Magno 18/01/2018 - Add Try finally
     Try
      aResult.Encoded := True;
      aResult.SetValue(GetPairJSON('NOK', MessageError));
      Result := aResult.ToJSON;
     Finally
      FreeAndNil(aResult);
     End;
    Except
     If Assigned(aResult) then
      FreeAndNil(aResult);
    End;
    If vFDConnection.InTransaction Then
    {$IF CompilerVersion >= 30}
    If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
     vFDConnection.Rollback;

    If Assigned(Self.OnQueryException) Then
     Self.OnQueryException(TDataset(vTempQuery), nil, E.Message);

    vFDConnection.Connected := False;
   End;
 End;
 RowsAffected := vTempQuery.RowsAffected;
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverFD.GetConnection: TFDConnection;
Begin
 Result := vFDConnection;
End;

Function TRESTDWDriverFD.InsertMySQLReturnID(SQL              : String;
                                             Params           : TDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 oTab           : TFDDatStable;
 A, I           : Integer;
 vParamName     : String;
 fdCommand      : TFDCommand;
 vStringStream  : TMemoryStream;
 vStateResource : Boolean;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
  Inherited;
 Result := -1;
 Error  := False;
 vStringStream := Nil;
 vStateResource := vFDConnection.Connected;
 If Not vFDConnection.Connected Then
  vFDConnection.Connected := True;
 If Not vFDConnection.InTransaction Then
  {$IF CompilerVersion >= 30}
  If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
   {$IFEND}
   vFDConnection.StartTransaction;
 fdCommand := TFDCommand.Create(Owner);
 Try
  fdCommand.Connection := vFDConnection;
  fdCommand.CommandText.Clear;
  fdCommand.CommandText.Add(SQL + '; SELECT LAST_INSERT_ID()ID');
  If Params <> Nil Then
   Begin
    Try
    // vTempQuery.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If fdCommand.Params.Count > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := GetParamIndex(fdCommand.Params, vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If fdCommand.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                ftString,    ftWideString]    Then
           Begin
            If fdCommand.Params[A].Size > 0 Then
             fdCommand.Params[A].Value := Copy(Params[I].Value, 1, fdCommand.Params[A].Size)
            Else
             fdCommand.Params[A].Value := Params[I].Value;
           End
          Else
           Begin
            If fdCommand.Params[A].DataType in [ftUnknown] Then
             Begin
              If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
               fdCommand.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
              Else
               fdCommand.Params[A].DataType := ftString;
             End;
            If fdCommand.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               Begin
                 // Alterado por: Alexandre Magno - 04/11/2017
                 If fdCommand.Params[A].DataType in [ftLongWord, ftLargeint] Then
                   fdCommand.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                 else If fdCommand.Params[A].DataType = ftSmallInt Then
                   fdCommand.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                 Else
                   fdCommand.Params[A].AsInteger  := StrToInt(Params[I].Value);

                 // Como estava Anteriormente
                 //If fdCommand.Params[A].DataType = ftSmallInt Then
                 //  fdCommand.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                 //Else
                 //  fdCommand.Params[A].AsInteger  := StrToInt(Params[I].Value);
               End;
             End
            Else If fdCommand.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               fdCommand.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value));
             End
            Else If fdCommand.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               Begin
                If fdCommand.Params[A].DataType = ftDate Then
                 fdCommand.Params[A].AsDate     := Params[I].AsDateTime
                Else If fdCommand.Params[A].DataType = ftTime Then
                 fdCommand.Params[A].AsTime     := Params[I].AsDateTime
                Else
                 fdCommand.Params[A].AsDateTime := Params[I].AsDateTime;
               End
              Else
               fdCommand.Params[A].AsDateTime  := Null;
             End  //Tratar Blobs de Parametros...
            Else If fdCommand.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                     ftGraphic, ftOraBlob, ftOraClob,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}] Then
             Begin
              //vStringStream := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(vStringStream);
               vStringStream.Position := 0;
               If vStringStream.Size > 0 Then
                fdCommand.Params[A].LoadFromStream(vStringStream, ftBlob);
              Finally
               If Assigned(vStringStream) Then
                FreeAndNil(vStringStream);
              End;
             End
            Else
             fdCommand.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else
       Break;
     End;
   End;
  fdCommand.Open;
  oTab := fdCommand.Define;
  fdCommand.Fetch(oTab, True);
  If oTab.Rows.Count > 0 Then
   Result := StrToInt(oTab.Rows[0].AsString['ID']);
  If vFDConnection.InTransaction Then
  {$IF CompilerVersion >= 30}
   If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
  {$IFEND}
   vFDConnection.Commit;
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    If vFDConnection.InTransaction Then
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
     vFDConnection.Rollback;
    Error        := True;
    MessageError := E.Message;
    vFDConnection.Connected := False;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 FreeAndNil(oTab);
End;

procedure TRESTDWDriverFD.Notification(AComponent: TComponent; Operation: TOperation);
begin
  //Alexandre Magno - 25/11/2018
  if (Operation = opRemove) and (AComponent = vFDConnection) then
  begin
    vFDConnection := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

Procedure TRESTDWDriverFD.GetTableNames(Var TableNames       : TStringList;
                                        Var Error            : Boolean;
                                        Var MessageError     : String);
Var
 vStateResource : Boolean;
Begin
 TableNames := TStringList.Create;
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vFDConnection.GetTableNames('', '', '', TableNames, [osMy, osOther], [tkTable], True);
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vFDConnection.Connected := False;
    Error          := True;
    MessageError   := E.Message;
   End;
 End;
End;

Procedure TRESTDWDriverFD.GetProcNames(Var ProcNames        : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);
Var
 vStateResource : Boolean;
Begin
 ProcNames := TStringList.Create;
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vFDConnection.GetStoredProcNames('', '', '', '', ProcNames, [osMy, osOther]);
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vFDConnection.Connected := False;
    Error          := True;
    MessageError   := E.Message;
   End;
 End;
End;

Procedure TRESTDWDriverFD.GetProcParams(ProcName             : String;
                                        Var ParamNames       : TStringList;
                                        Var Error            : Boolean;
                                        Var MessageError     : String);
Var
 vFDStoredProc  : TFDStoredProc;
 I              : Integer;
 vStateResource : Boolean;
Begin
 ParamNames := TStringList.Create;
 vFDStoredProc := TFDStoredProc.Create(Nil);
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vFDStoredProc.Connection     := vFDConnection;
  vFDStoredProc.StoredProcName := ProcName;
  For I := 0 To vFDStoredProc.Params.Count -1 Do
   ParamNames.Add(Format(cParamDetails, [vFDStoredProc.Params[I].Name,
                                         GetFieldType(vFDStoredProc.Params[I].DataType),
                                         vFDStoredProc.Params[I].Size,
                                         vFDStoredProc.Params[I].Precision]));
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vFDConnection.Connected := False;
    Error          := True;
    MessageError   := E.Message;
   End;
 End;
 FreeAndNil(vFDStoredProc);
End;

Procedure TRESTDWDriverFD.GetKeyFieldNames(TableName            : String;
                                           Var FieldNames       : TStringList;
                                           Var Error            : Boolean;
                                           Var MessageError     : String);
Var
 vStateResource : Boolean;
Begin
 FieldNames := TStringList.Create;
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vFDConnection.GetKeyFieldNames('', '', TableName, '', FieldNames);
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vFDConnection.Connected := False;
    Error          := True;
    MessageError   := E.Message;
   End;
 End;
End;

Procedure TRESTDWDriverFD.GetFieldNames(TableName            : String;
                                        Var FieldNames       : TStringList;
                                        Var Error            : Boolean;
                                        Var MessageError     : String);
Var
 vStateResource : Boolean;
Begin
 FieldNames := TStringList.Create;
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vFDConnection.GetFieldNames('', '', TableName, '', FieldNames);
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vFDConnection.Connected := False;
    Error          := True;
    MessageError   := E.Message;
   End;
 End;
End;

Function TRESTDWDriverFD.OpenDatasets       (DatasetsLine     : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String;
                                             Var BinaryBlob   : TMemoryStream): TJSONValue;
Var
 vTempQuery      : TFDQuery;
 vTempJSON       : TJSONValue;
 vJSONLine       : String;
 I, X            : Integer;
 vMetaData,
 vBinaryEvent,
 vStateResource,
 vCompatibleMode : Boolean;
 DWParams        : TDWParams;
 bJsonArray      : TDWJSONArray;
 bJsonValue      : TDWJSONObject;
 vStream         : TMemoryStream;
 vDWMemtable1    : tDWMemtable;
Begin
 Inherited;
 Error           := False;
 vBinaryEvent    := False;
 vMetaData       := False;
 vCompatibleMode := False;
 bJsonArray      := Nil;
 vTempQuery      := TFDQuery.Create(Nil);
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  If Not vFDConnection.InTransaction Then
   Begin
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
    vFDConnection.StartTransaction;
   End;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  bJsonValue  := TDWJSONObject.Create(DatasetsLine);
  For I := 0 To bJsonValue.PairCount - 1 Do
   Begin
    bJsonArray  := bJsonValue.OpenArray(I);
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(DecodeStrings(TDWJSONObject(bJsonArray).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vBinaryEvent    := StringToBoolean(TDWJSONObject(bJsonArray).Pairs[2].Value);
    vMetaData       := StringToBoolean(TDWJSONObject(bJsonArray).Pairs[3].Value);
    vCompatibleMode := StringToBoolean(TDWJSONObject(bJsonArray).Pairs[4].Value);
    vTempQuery.ResourceOptions.StoreItems   := [siMeta,siData,siDelta];
    vTempQuery.FetchOptions.Mode            := fmAll;
    If bJsonArray.ElementCount > 1 Then
     Begin
      DWParams := TDWParams.Create;
      Try
       DWParams.FromJSON(DecodeStrings(TDWJSONObject(bJsonArray).Pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
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
      vTempJSON.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
     End
    Else If vCompatibleMode Then
     TRESTDWClientSQLBase.SaveToStream(vTempQuery, vStream)
    Else
     Begin
      vStream := TMemoryStream.Create;
      Try
       vTempQuery.SaveToStream(vStream, sfBinary);
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
        vJSONLine := Format('{"BinaryRequest":"%s"}', [Encodeb64Stream(vStream)])
       Else
        vJSONLine := vJSONLine + Format(', {"BinaryRequest":"%s"}', [Encodeb64Stream(vStream)]);
       If Assigned(vStream) Then
        FreeAndNil(vStream);
      End;
    Finally
     vTempJSON.Free;
    End;
    FreeAndNil(bJsonArray);
   End;
  {$IF CompilerVersion >= 30}
   If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
  {$IFEND}
   If vFDConnection.InTransaction Then
    vFDConnection.Commit;
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vFDConnection.Connected := False;
    Try
     Error          := True;
     MessageError   := E.Message;
     vJSONLine      := GetPairJSON('NOK', MessageError);
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
End;

Procedure TRESTDWDriverFD.PrepareConnection(Var ConnectionDefs : TConnectionDefs);
 Procedure ServerParamValue(ParamName, Value : String);
 Var
  I, vIndex : Integer;
  vFound : Boolean;
 Begin
  vFound := False;
  vIndex := -1;
  For I := 0 To vFDConnection.Params.Count -1 Do
   Begin
    If Lowercase(vFDConnection.Params.Names[I]) = Lowercase(ParamName) Then
     Begin
      vFound := True;
      vIndex := I;
      Break;
     End;
   End;
  If Not (vFound) Then
   vFDConnection.Params.Add(Format('%s=%s', [ParamName, Value]))
  Else
   vFDConnection.Params[vIndex] := Format('%s=%s', [ParamName, Value]);
 End;
Begin
 Inherited;
 If Assigned(ConnectionDefs) Then
  Begin
   Case ConnectionDefs.DriverType Of
    dbtUndefined  : Begin

                    End;
    dbtAccess     : Begin
                     vFDConnection.DriverName := 'MSAcc';

                    End;
    dbtDbase      : Begin

                    End;
    dbtFirebird   : Begin
                     vFDConnection.DriverName := 'FB';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  vFDConnection.DriverName);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtInterbase  : Begin
                     vFDConnection.DriverName := 'IB';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  vFDConnection.DriverName);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtMySQL      : Begin
                     vFDConnection.DriverName := 'MYSQL';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  vFDConnection.DriverName);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                    End;
    dbtSQLLite    : Begin
                     vFDConnection.DriverName := 'SQLLite';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  vFDConnection.DriverName);
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                    End;
    dbtOracle     : Begin
                     vFDConnection.DriverName := 'Ora';

                    End;
    dbtMsSQL      : Begin
                     vFDConnection.DriverName := 'MSSQL';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  vFDConnection.DriverName);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtODBC       : Begin
                     vFDConnection.DriverName := 'ODBC';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DataSource', ConnectionDefs.DataSource);
                    End;
    dbtParadox    : Begin

                    End;
    dbtPostgreSQL : Begin
                     vFDConnection.DriverName := 'PG';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  vFDConnection.DriverName);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
//                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
   End;
  End;
End;

Function TRESTDWDriverFD.InsertMySQLReturnID(SQL              : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 oTab      : TFDDatStable;
 fdCommand : TFDCommand;
 vStateResource : Boolean;
Begin
  Inherited;
 Result := -1;
 Error  := False;
 vStateResource := vFDConnection.Connected;
 If Not vFDConnection.Connected Then
  vFDConnection.Connected := True;
 If Not vFDConnection.InTransaction Then
  {$IF CompilerVersion >= 30}
  If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
   {$IFEND}
   vFDConnection.StartTransaction;
 fdCommand := TFDCommand.Create(Owner);
 Try
  fdCommand.Connection := vFDConnection;
  fdCommand.CommandText.Clear;
  fdCommand.CommandText.Add(SQL + '; SELECT LAST_INSERT_ID()ID');
  fdCommand.Open;
  oTab := fdCommand.Define;
  fdCommand.Fetch(oTab, True);
  If oTab.Rows.Count > 0 Then
   Result := StrToInt(oTab.Rows[0].AsString['ID']);
  If vFDConnection.InTransaction Then
  {$IF CompilerVersion >= 30}
   If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
  {$IFEND}
   vFDConnection.Commit;
  vFDConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    If vFDConnection.InTransaction Then
    {$IF CompilerVersion >= 30}
     If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
    {$IFEND}
     vFDConnection.Rollback;
    Error        := True;
    MessageError := E.Message;
    vFDConnection.Connected := False;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 FreeAndNil(oTab);
End;

Function TRESTDWDriverFD.ApplyUpdatesTB(Massive              : String;
                                        Params               : TDWParams;
                                        Var Error            : Boolean;
                                        Var MessageError     : String;
                                        Var RowsAffected     : Integer) : TJSONValue;
Var
 vTempQuery     : TFDTable;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vMassiveLine   : Boolean;
 vValueKeys     : TRESTDWValueKeys;
 Function GetFieldIndex(Params : TFields; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].FieldName) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
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
  If MassiveDataset.Fields.FieldByName(DWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(DWFieldBookmark).Value, ', "reflectionlines":[%s]']);
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
                                        vFieldChanged := Encodeb64Stream(vStringStream) <> MassiveField.Value;
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
                                                             Encodeb64Stream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 Encodeb64Stream(vStringStream)]); // StreamToHex(vStringStream)]);
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
 Function LoadMassive(Massive : String; Var Query : TFDTable) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TFDTable;
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
                // Alterado por: Alexandre Magno - 04/11/2017
                If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
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
      Self.OnTableBeforeOpen(TDataset(Query), Params, MassiveDataset.TableName);
     Query.Open;
     Query.FetchAll;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           Query.FindField(MassiveDataset.Fields.Items[I].FieldName).Required          := False;
           If MassiveDataset.SequenceName <> '' Then
            Begin
//             vZSequence.Connection   := vFDConnection;
//             Query.SequenceField     := MassiveDataset.Fields.Items[I].FieldName;
//             vZSequence.SequenceName := MassiveDataset.SequenceName;
            End;
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
      BuildDatasetLine(TDataset(Query), MassiveDataset);
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
  Try
   Result         := False;
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
     If Not vFDConnection.InTransaction Then
      Begin
       {$IF CompilerVersion >= 30}
        If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
       {$IFEND}
        vFDConnection.StartTransaction;
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
        If vFDConnection.InTransaction Then
         {$IF CompilerVersion >= 30}
          If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
         {$IFEND}
          vFDConnection.Rollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If vFDConnection.InTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
          {$IF CompilerVersion >= 30}
           If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
          {$IFEND}
           vFDConnection.Commit;
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
          If vFDConnection.InTransaction Then
           {$IF CompilerVersion >= 30}
            If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
           {$IFEND}
            vFDConnection.Rollback;
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
    If vFDConnection.InTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
       {$IF CompilerVersion >= 30}
        If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
       {$IFEND}
        vFDConnection.Commit;
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
      If vFDConnection.InTransaction Then
       {$IF CompilerVersion >= 30}
        If Not vFDConnection.UpdateOptions.AutoCommitUpdates Then
       {$IFEND}
        vFDConnection.Rollback;
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
  vTempQuery     := TFDTable.Create(Owner);
  vValueKeys     := TRESTDWValueKeys.Create;
  vTempQuery.CachedUpdates := False;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
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
             A          := GetFieldIndex(vTempQuery.Fields, vParamName);
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
       Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
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
          Result.SetValue(GetPairJSON('NOK', MessageError));
          vFDConnection.Rollback;
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
End;

Function TRESTDWDriverFD.ExecuteCommandTB(Tablename            : String;
                                          Params               : TDWParams;
                                          Var Error            : Boolean;
                                          Var MessageError     : String;
                                          Var BinaryBlob       : TMemoryStream;
                                          Var RowsAffected     : Integer;
                                          BinaryEvent          : Boolean = False;
                                          MetaData             : Boolean = False;
                                          BinaryCompatibleMode : Boolean = False)  : String;
Var
 vTempQuery     : TFDTable;
 A, I           : Integer;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 aResult        : TJSONValue;
 vStateResource : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error  := False;
 vStringStream  := Nil;
 aResult := TJSONValue.Create;
 vTempQuery               := TFDTable.Create(Owner);
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.TableName    := TableName;
  vTempQuery.FetchOptions.RowsetSize := -1;
  If Assigned(Self.OnTableBeforeOpen) Then
   Self.OnTableBeforeOpen(TDataset(vTempQuery), Params, TableName);
  If Not vTempQuery.Active Then
   vTempQuery.Open;
  If aResult = Nil Then
   aResult := TJSONValue.Create;
  aResult.Encoded         := EncodeStringsJSON;
  aResult.Encoding        := Encoding;
  {$IFDEF FPC}
   aResult.DatabaseCharSet := DatabaseCharSet;
  {$ENDIF}
  Try
   If Not BinaryEvent Then
    Begin
     aResult.Utf8SpecialChars := True;
     aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
     Result := aResult.ToJson;
    End
   Else If Not BinaryCompatibleMode Then
    Begin
     If Not Assigned(BinaryBlob) Then
      BinaryBlob := TMemoryStream.Create;
     Try
      vTempQuery.SaveToStream(BinaryBlob, sfBinary);
      BinaryBlob.Position := 0;
     Finally
     End;
    End
   Else
    TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
   vFDConnection.Connected := vStateResource;
  Finally
  End;
 Except
  On E : Exception do
   Begin
    Try
     Error                   := True;
     MessageError            := E.Message;
     If aResult = Nil Then
      aResult := TJSONValue.Create;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     aResult.SetValue(GetPairJSON('NOK', MessageError));
     Result := aResult.ToJson;
     vFDConnection.Rollback;
     vFDConnection.Connected := False;
    Except
    End;
   End;
 End;
 If Assigned(aResult) Then
  FreeAndNil(aResult);
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverFD.ExecuteCommandTB(Tablename            : String;
                                          Var Error            : Boolean;
                                          Var MessageError     : String;
                                          Var BinaryBlob       : TMemoryStream;
                                          Var RowsAffected     : Integer;
                                          BinaryEvent          : Boolean = False;
                                          MetaData             : Boolean = False;
                                          BinaryCompatibleMode : Boolean = False)  : String;
Var
 vTempQuery     : TFDTable;
 aResult        : TJSONValue;
 vStateResource : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 aResult := Nil;
 Result  := '';
 Error   := False;
 vTempQuery               := TFDTable.Create(Owner);
 Try
  vStateResource := vFDConnection.Connected;
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.TableName    := TableName;
  vTempQuery.FetchOptions.RowsetSize := -1;
  If Assigned(Self.OnTableBeforeOpen) Then
   Self.OnTableBeforeOpen(TDataset(vTempQuery), Nil, TableName);
  If Not vTempQuery.Active Then
   vTempQuery.Open;
  vTempQuery.FetchAll;
  aResult         := TJSONValue.Create;
  Try
   aResult.Encoded         := EncodeStringsJSON;
   aResult.Encoding        := Encoding;
   {$IFDEF FPC}
    aResult.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
   If Not BinaryEvent Then
    Begin
     aResult.Utf8SpecialChars := True;
     aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
     Result := aResult.ToJSON;
    End
   Else If Not BinaryCompatibleMode Then
    Begin
     If Not Assigned(BinaryBlob) Then
      BinaryBlob := TMemoryStream.Create;
     Try
      vTempQuery.SaveToStream(BinaryBlob, sfBinary);
      BinaryBlob.Position := 0;
     Finally
     End;
    End
   Else
    TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
   FreeAndNil(aResult);
   vFDConnection.Connected := vStateResource;
  Finally
  End;
 Except
  On E : Exception do
   Begin
    aResult        := TJSONValue.Create;
    Try
     Error          := True;
     MessageError   := E.Message;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     aResult.SetValue(GetPairJSON('NOK', MessageError));
     Result := aResult.ToJSON;
     vFDConnection.Rollback;
    Except
    End;
    vFDConnection.Connected := False;
    FreeAndNil(aResult);
   End;
 End;
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverFD.GetGenID(Query               : TComponent;
                                  GenName             : String): Integer;
Var
 vTempClient : TFDQuery;
Begin
 Result := -1;
 If Query <> Nil Then
  Begin
   vTempClient := TFDQuery.Create(Nil);
   vTempClient.Connection := TFDQuery(Query).Connection;
   Try
    If (Uppercase(TFDQuery(Query).Connection.DriverName) = 'FB')     Or
       (Uppercase(TFDQuery(Query).Connection.DriverName) = 'IB')     Or
       (Uppercase(TFDQuery(Query).Connection.DriverName) = 'IBLITE') Then
     Begin
      vTempClient.SQL.Add(Format('select gen_id(%s, 1)GenID From rdb$database', [GenName]));
      vTempClient.Active := True;
      Result := vTempClient.FindField('GenID').AsInteger;
     End
    Else If Uppercase(TFDQuery(Query).Connection.DriverName) = 'PG' Then
     Begin
      vTempClient.SQL.Add(Format('select nextval(''%s'')GenID', [GenName]));
      vTempClient.Active := True;
      Result := vTempClient.FindField('GenID').AsInteger;
     End;
   Except

   End;
   vTempClient.Free;
  End;
End;

Procedure TRESTDWDriverFD.SetConnection(Value: TFDConnection);
Begin
 //Alexandre Magno - 25/11/2018
 If vFDConnection <> Value Then
  vFDConnection := Value;
 If vFDConnection <> Nil   Then
  vFDConnection.FreeNotification(Self);
End;

end.
