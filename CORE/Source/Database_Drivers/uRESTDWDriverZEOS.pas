unit uRESTDWDriverZEOS;

interface

uses
 {$IFDEF FPC}
 SysUtils,  Classes, DB, lconvencoding, uRESTDWCharset,
 {$ELSE}
 {$IF CompilerVersion < 23}
 SysUtils,          Classes, DB,
 {$ELSE}
 System.SysUtils,   System.Classes, Data.DB,
 {$IFEND}
 {$ENDIF}
 ZSqlUpdate,           ZAbstractRODataset,  ZAbstractDataset,
 ZDataset,             ZConnection,         ZStoredProcedure,
 ZSqlProcessor,        ZSequence,           ZSqlMetadata,
 uRESTDWConsts,        uRESTDWDataUtils,           uRESTDWBasicDB,
 uRESTDWJSONInterface, uRESTDWDataJSON,     uRESTDWMassiveBuffer,
 Variants,             uRESTDWDatamodule,   uRESTDWDataset,
 uRESTDWJSONObject,    uRESTDWParams,       uRESTDWBasicTypes,
 uRESTDWBasic,         uRESTDWTools;

Type
 TRESTDWDriverZeos   = Class(TRESTDWDriver)
 Private
  vZConnection                  : TZConnection;
  Procedure SetConnection(Value : TZConnection);
  Function  GetConnection       : TZConnection;
  protected procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Function ConnectionSet                                    : Boolean;Override;
  Function GetGenID                   (Query                : TComponent;
                                       GenName              : String)           : Integer;Override;
  Function ApplyUpdatesTB             (Massive              : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var RowsAffected     : Integer)          : TJSONValue;Override;
//  Function ApplyUpdates_MassiveCacheTB(MassiveCache         : String;
//                                       Var Error            : Boolean;
//                                       Var MessageError     : String)           : TJSONValue;Override;
  Function ExecuteCommandTB           (Tablename            : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False)  : String;Overload;Override;
  Function ExecuteCommandTB           (Tablename            : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False)  : String;Overload;Override;
  Function ApplyUpdates               (Massive,
                                       SQL                   : String;
                                       Params                : TRESTDWParams;
                                       Var Error             : Boolean;
                                       Var MessageError      : String;
                                       Var RowsAffected      : Integer)         : TJSONValue;Override;
  Function ApplyUpdates_MassiveCache  (MassiveCache          : String;
                                       Var Error             : Boolean;
                                       Var MessageError      : String)          : TJSONValue;Override;
  Function ProcessMassiveSQLCache     (MassiveSQLCache       : String;
                                       Var Error             : Boolean;
                                       Var MessageError      : String)          : TJSONValue;Override;
  Function ExecuteCommand             (SQL                  : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       Execute              : Boolean = False;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Override;
  Function ExecuteCommand             (SQL                  : String;
                                       Params               : TRESTDWParams;
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
                                      Params               : TRESTDWParams;
                                      Var Error            : Boolean;
                                      Var MessageError     : String)          : Integer;Overload;Override;
  Procedure ExecuteProcedure         (ProcName             : String;
                                      Params               : TRESTDWParams;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);Override;
  Procedure ExecuteProcedurePure     (ProcName             : String;
                                      Var Error            : Boolean;
                                      Var MessageError     : String);Override;
  Function  OpenDatasets             (DatasetsLine         : String;
                                      Var Error            : Boolean;
                                      Var MessageError     : String;
                                      Var BinaryBlob       : TMemoryStream)   : TJSONValue;Override;
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
  Property Connection : TZConnection Read GetConnection Write SetConnection;
End;



Procedure Register;

implementation

{$IFNDEF FPC}
 {$if CompilerVersion < 23}
  {$R .\RESTDWDriverZEOS.dcr}
 {$IFEND}
{$ENDIF}

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWDriverZeos]);
End;

Function TRESTDWDriverZeos.ProcessMassiveSQLCache(MassiveSQLCache      : String;
                                                    Var Error            : Boolean;
                                                    Var MessageError     : String) : TJSONValue;
Var
 vTempQuery        : TZQuery;
 vStringStream     : TMemoryStream;
 vStateResource    : Boolean;
 vResultReflection : String;
 Function GetParamIndex(Params : TParams; ParamName : String) : Integer;
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
 Function LoadMassive(Massive : String; Var Query : TZQuery) : Boolean;
 Var
  X, A, I         : Integer;
  vMassiveSQLMode : TMassiveSQLMode;
  vSQL,
  vParamsString,
  vBookmark,
  vParamName      : String;
  vDWParams       : TRESTDWParams;
  vBinaryRequest  : Boolean;
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
     If Not vZConnection.InTransaction Then
      Begin
       If not vZConnection.AutoCommit Then
        vZConnection.StartTransaction;
      End;
     vDWParams          := TRESTDWParams.Create;
     vDWParams.Encoding := Encoding;
     Try
//      TRESTDWJSONInterfaceObject(bJsonValueB).ToJSON;
      vMassiveSQLMode := MassiveSQLMode(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[0].Value);
      vSQL            := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF});
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
                         For I := 0 To vDWParams.Count -1 Do
                          Begin
                           If vTempQuery.Params.Count > I Then
                            Begin
                             vParamName := Copy(StringReplace(vDWParams[I].ParamName, ',', '', []), 1, Length(vDWParams[I].ParamName));
                             A          := GetParamIndex(TParams(vTempQuery.Params), vParamName);
                             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
                              Begin
                               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
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
                                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                                  Begin
                                   If (Not(vDWParams[I].IsNull)) Then
                                    Begin
                                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                                      {$IFNDEF FPC}
                                       {$IF CompilerVersion >= 22}
                                        vTempQuery.Params[A].AsLargeInt := StrToInt64(vDWParams[I].Value)
                                       {$ELSE}
                                        vTempQuery.Params[A].AsInteger  := StrToInt64(vDWParams[I].Value)
                                       {$IFEND}
                                      {$ELSE}
                                       vTempQuery.Params[A].AsLargeInt := StrToInt64(vDWParams[I].Value)
                                      {$ENDIF}
                                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                                      vTempQuery.Params[A].AsSmallInt := StrToInt(vDWParams[I].Value)
                                     Else
                                      vTempQuery.Params[A].AsInteger  := StrToInt(vDWParams[I].Value);
                                    End
                                   Else
                                    vTempQuery.Params[A].Clear;
                                  End
                                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
                                  Begin
                                   If (Not(vDWParams[I].IsNull)) Then
                                    vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(vDWParams[I].Value))
                                   Else
                                    vTempQuery.Params[A].Clear;
                                  End
                                 Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                                  Begin
                                   If (Not(vDWParams[I].IsNull)) Then
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
                                 Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
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
                                    // fernando
                                    //If (Trim(vDWParams[I].Value) <> '') then begin
                                    if not vDWParams[I].IsNull then begin
                                     vTempQuery.Params[A].DataType := ftString;
                                     vTempQuery.Params[A].AsString := vDWParams[I].Value;
                                    End
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
      If vZConnection.InTransaction Then
       Begin
        If Not vZConnection.AutoCommit Then
         vZConnection.Commit;
       End;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If vZConnection.InTransaction Then
         If not vZConnection.AutoCommit Then
          vZConnection.Rollback;
        MessageError := E.Message;
       End;
     End;
    End;
  Finally
   FreeAndNil(bJsonValue);
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 vResultReflection := '';
 Result     := Nil;
 vStringStream := Nil;
 Try
  Error      := False;
  vTempQuery := TZQuery.Create(Owner);
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
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
  vZConnection.Connected := vStateResource;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
End;

Function TRESTDWDriverZeos.ApplyUpdates_MassiveCache(MassiveCache     : String;
                                                   Var Error        : Boolean;
                                                   Var MessageError : String)  : TJSONValue;
Var
 vTempQuery        : TZQuery;
 vZSequence        : TZSequence;
 vStringStream     : TMemoryStream;
 bPrimaryKeys      : TStringList;
 vFieldType        : TFieldType;
 vStateResource,
 vMassiveLine      : Boolean;
 vResultReflection : String;
 Function GetParamIndex(Params : TParams; ParamName : String) : Integer;
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
  {$IFDEF FPC}
  vFieldChanged     := False;
  {$ENDIF}
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
            Else //          If MassiveReplyValue <> Nil Then
             MassiveDataset.MassiveReply.UpdateBufferValue(MassiveDataset.MyCompTag, Query.Fields[I].FieldName, MassiveField.Value, Query.Fields[I].AsString);
           End;
          vTempValue := Query.Fields[I].AsString;
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If ((vTempValue <> cNullvalue) And (vTempValue <> '')) Or (MassiveField.Modified) Then
                                       Begin
                                        If ((StrToDateTime(vTempValue) <> MassiveField.Value)) Or (MassiveField.Modified) Then
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
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22},
                                 ftSingle,
                                 ftExtended
                                 {$IFEND}{$ENDIF} : Begin
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
 Function LoadMassive(Massive : String; Var Query : TZQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, X           : Integer;
//  bJsonArray     : udwjson.TJsonArray;
  bJsonValueB    : TRESTDWJSONInterfaceBase;
  bJsonValue     : TRESTDWJSONInterfaceObject;
  bJsonArray     : TRESTDWJSONInterfaceArray;
  Procedure PrepareData(Var Query      : TZQuery;
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
            End
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
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord,
                                                                         {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
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
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd
                                                                              {$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
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
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
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
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Begin
            Query.Params[I].DataType := ftString;
            Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size);
           End
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
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
             Query.Params[I]{$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
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
                       (MassiveDataset.Fields.Items[I].ReadOnly))         And
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
     Query.FetchAll;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           Query.FindField(MassiveDataset.Fields.Items[I].FieldName).Required := False;
           If MassiveDataset.SequenceName <> '' Then
            Begin
             vZSequence.Connection   := vZConnection;
             Query.SequenceField     := MassiveDataset.Fields.Items[I].FieldName;
             vZSequence.SequenceName := MassiveDataset.SequenceName;
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
     For I := 0 To Query.Params.Count -1 Do
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
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   {$IFNDEF FPC}
                    {$IF CompilerVersion >= 22}
                     If Query.Params[I].DataType in [ftLargeint] Then
                      Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                     Else If Query.Params[I].DataType = ftSmallInt Then
                      Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                     Else
                      Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                    {$ELSE}
                     Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                    {$IFEND}
                   {$ELSE}
                    Query.Params[I].AsLargeInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   {$ENDIF}
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd] Then
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
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
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
               If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Begin
                   Query.Params[I].DataType := ftString;
                   Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size);
                  End
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
               Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                    Begin
                     {$IFNDEF FPC}
                      {$IF CompilerVersion > 22}Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                      {$ELSE}Query.Params[I].AsInteger                     := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                      {$IFEND}
                     {$ELSE}
                      Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                     {$ENDIF}
  //                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                    End
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
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
  bJsonValue     := TRESTDWJSONInterfaceObject.Create(MassiveCache);
  bJsonArray     := TRESTDWJSONInterfaceArray(bJsonValue);
  Result         := False;
  Try
   For x := 0 To bJsonArray.ElementCount -1 Do
    Begin
     bJsonValueB := bJsonArray.GetObject(X);//bJsonArray.get(X);
     If Not vZConnection.InTransaction Then
      Begin
       If not vZConnection.AutoCommit Then
        vZConnection.StartTransaction;
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
          Query.ExecSQL;
        Except
         On E : Exception do
          Begin
           Error  := True;
           Result := False;
           If vZConnection.InTransaction Then
            If not vZConnection.AutoCommit Then
             vZConnection.Rollback;
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
      If vZConnection.InTransaction Then
       Begin
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
           TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
         End;
        If not vZConnection.AutoCommit Then
         vZConnection.Commit;
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
        If vZConnection.InTransaction Then
         If not vZConnection.AutoCommit Then
          vZConnection.Rollback;
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
 {$IFNDEF FPC}Inherited;{$ENDIF}
 vResultReflection := '';
 Result     := Nil;
 vStringStream  := Nil;
 Try
  Error      := False;
  vTempQuery := TZQuery.Create(Owner);
  vTempQuery.UpdateMode    := umUpdateAll;
  vTempQuery.WhereMode     := wmWhereAll;
  vTempQuery.CachedUpdates := False;
  vZSequence := TZSequence.Create(Owner);
  vTempQuery.Sequence := vZSequence;
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
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
  vZConnection.Connected := vStateResource;
 Finally
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
  FreeAndNil(vZSequence);
 End;
End;

Procedure TRESTDWDriverZeos.Close;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 If Connection <> Nil Then
  Connection.Disconnect;
End;

Function TRESTDWDriverZeos.ConnectionSet: Boolean;
Begin
 Result := vZConnection <> Nil;
End;

Class Procedure TRESTDWDriverZeos.CreateConnection(Const ConnectionDefs : TConnectionDefs;
                                                   Var Connection       : TObject);
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}

End;

Function TRESTDWDriverZeos.ExecuteCommandTB(Tablename            : String;
                                            Params               : TRESTDWParams;
                                            Var Error            : Boolean;
                                            Var MessageError     : String;
                                            Var BinaryBlob       : TMemoryStream;
                                            Var RowsAffected     : Integer;
                                            BinaryEvent          : Boolean = False;
                                            MetaData             : Boolean = False;
                                            BinaryCompatibleMode : Boolean = False)  : String;
Var
 vTempQuery     : TZTable;
 vParamName     : String;
 vStateResource : Boolean;
 vStringStream  : TMemoryStream;
 aResult        : TJSONValue;
 vDWMemtable1   : TRESTDWMemtable;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error  := False;
// vStringStream  := Nil;
 aResult := TJSONValue.Create;
 vTempQuery               := TZTable.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
  vTempQuery.TableName    := TableName;
  vTempQuery.FetchRow := -1;
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
      BinaryBlob  := TMemoryStream.Create;
     vDWMemtable1 := TRESTDWMemtable.Create(Nil);
     Try
      vDWMemtable1.Assign(vTempQuery);
      vDWMemtable1.SaveToStream(BinaryBlob);
      BinaryBlob.Position := 0;
     Finally
      FreeAndNil(vDWMemtable1);
     End;
    End
   Else
    TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
  Finally
   vZConnection.Connected := vStateResource;
  End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     If aResult = Nil Then
      aResult := TJSONValue.Create;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result := aResult.ToJson;
     vZConnection.Rollback;
     vZConnection.Connected := False;
    Except
    End;
   End;
 End;
 If Assigned(aResult) Then
  FreeAndNil(aResult);
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverZeos.ExecuteCommand(SQL                  : String;
                                          Params               : TRESTDWParams;
                                          Var Error            : Boolean;
                                          Var MessageError     : String;
                                          Var BinaryBlob       : TMemoryStream;
                                          Var RowsAffected     : Integer;
                                          Execute              : Boolean = False;
                                          BinaryEvent          : Boolean = False;
                                          MetaData             : Boolean = False;
                                          BinaryCompatibleMode : Boolean = False) : String;
Var
 vTempQuery     : TZQuery;
 A, I           : Integer;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 aResult        : TJSONValue;
 vStateResource : Boolean;
 vDWMemtable1   : TRESTDWMemtable;
 Function GetParamIndex(Params : TParams; ParamName : String) : Integer;
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
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error  := False;
 vStringStream  := Nil;
 aResult := TJSONValue.Create;
 vTempQuery               := TZQuery.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Params <> Nil Then
  Begin
   If vTempQuery.ParamCheck then
    Begin
      For I := 0 To Params.Count -1 Do
       Begin
        If (vTempQuery.Params.Count > I) And (Not (Params[I].IsNull)) Then
         Begin
          vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
          A          := GetParamIndex(TParams(vTempQuery.Params), vParamName);
          If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
           Begin
            If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion >= 22} // Delphi 2010 pra baixo
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
              If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
               Begin
                If (Not(Params[I].IsNull)) Then
                 Begin
                  {$IFNDEF FPC}
                  {$IF CompilerVersion < 22}
                  If vTempQuery.Params[A].DataType = ftSmallInt Then
                  begin
                   vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value);
                  end
                  Else
                  begin
                   vTempQuery.Params[A].AsInteger  := StrToInt64(Params[I].Value);
                  end;
                  {$ELSE}
                  If vTempQuery.Params[A].DataType in [ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
                   vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                  Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                   vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                  Else
                   vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                  {$IFEND}
                  {$ELSE}
                  If vTempQuery.Params[A].DataType in [ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
                   vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                  Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                   vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                  Else
                   vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                  {$ENDIF}
                 End
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
               Begin
                If (Not(Params[I].IsNull)) Then
                 vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
               Begin
                If (Not(Params[I].IsNull)) Then
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
                 Params[I].SaveToStream(vStringStream);
                 vStringStream.Position := 0;
                 If vStringStream.Size > 0 Then
                  vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                Finally
                 If Assigned(vStringStream) Then
                  FreeAndNil(vStringStream);
                End;
               End
              Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion >= 22} // Delphi 2010 pra baixo
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
                If (Trim(Params[I].Value) <> '') Then
                 Begin
                  vTempQuery.Params[A].DataType := ftString;
                  vTempQuery.Params[A].AsString := Params[I].Value;
                 End
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else If vTempQuery.Params[A].DataType in [ftGuid] Then
               Begin
                If (Not (Params[I].IsNull)) Then
                 vTempQuery.Params[A].Value := Params[I].AsString
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else
               vTempQuery.Params[A].Value    := Params[I].Value;
             End;
           End;
         End
        Else If (vTempQuery.Params.Count <= I) Then
         Break;
       End;
    End
   Else
    Begin
     For I := 0 To Params.Count -1 Do
      begin
       {$IFNDEF FPC}
        {$if CompilerVersion < 23}
          With vTempQuery.Params.Add do
        {$ELSE}
          With vTempQuery.Params.AddParameter do
        {$IFEND}
       {$ELSE}
       With vTempQuery.Params.Add do
       {$ENDIF}
        Begin
         vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
         Name := vParamName;
         {$IFNDEF FPC}
          {$IF CompilerVersion >= 23}
          ParamType := ptInput;
           If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
            DataType := ObjectValueToFieldType(Params[I].ObjectValue)
           Else
            DataType := ftString;
          {$IFEND}
         {$ENDIF}
         If vTempQuery.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
          Begin
           If (Not(Params[I].IsNull)) Then
            Begin
             {$IFNDEF FPC}
              {$IF CompilerVersion < 22}
               If vTempQuery.Params[I].DataType = ftSmallInt Then
                vTempQuery.Params[I].AsSmallInt := StrToInt(Params[I].Value)
               Else
                vTempQuery.Params[I].AsInteger  := StrToInt64(Params[I].Value);
                {$ELSE}
               If vTempQuery.Params[I].DataType in [ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
                vTempQuery.Params[I].AsLargeInt := StrToInt64(Params[I].Value)
               Else If vTempQuery.Params[I].DataType = ftSmallInt Then
                vTempQuery.Params[I].AsSmallInt := StrToInt(Params[I].Value)
               Else
                vTempQuery.Params[I].AsInteger  := StrToInt(Params[I].Value);
              {$IFEND}
             {$ELSE}
              If vTempQuery.Params[I].DataType in [ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
               vTempQuery.Params[I].AsLargeInt := StrToInt64(Params[I].Value)
              Else If vTempQuery.Params[I].DataType = ftSmallInt Then
               vTempQuery.Params[I].AsSmallInt := StrToInt(Params[I].Value)
              Else
               vTempQuery.Params[I].AsInteger  := StrToInt(Params[I].Value);
             {$ENDIF}
            End
           Else
            vTempQuery.Params[I].Clear;
          End
          Else If vTempQuery.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD{$IFNDEF FPC}{$if CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
           Begin
            If (Not(Params[I].IsNull)) Then
             vTempQuery.Params[I].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
            Else
             vTempQuery.Params[I].Clear;
           End
          Else If vTempQuery.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
           Begin
            If (Not(Params[I].IsNull)) Then
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
             If vStringStream.Size > 0 Then
              vTempQuery.Params[I].LoadFromStream(vStringStream, ftBlob);
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else If vTempQuery.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion >= 22} // Delphi 2010 pra baixo
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
            If (Not(Params[I].IsNull)) Then
             Begin
              vTempQuery.Params[I].DataType := ftString;
              vTempQuery.Params[I].AsString := Params[I].Value;
             End
            Else
             vTempQuery.Params[I].Clear;
           End
          Else If vTempQuery.Params[I].DataType in [ftGuid] Then
           Begin
            If (Not (Params[I].IsNull)) Then
             vTempQuery.Params[I].Value := Params[I].AsString
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
    vTempQuery.Active := True;
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
        BinaryBlob  := TMemoryStream.Create;
       vDWMemtable1 := TRESTDWMemtable.Create(Nil);
       Try
        vDWMemtable1.Assign(vTempQuery);
        vDWMemtable1.SaveToStream(BinaryBlob);
        BinaryBlob.Position := 0;
       Finally
        FreeAndNil(vDWMemtable1);
       End;
      End
     Else
      TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
    Finally
     vZConnection.Connected := vStateResource;
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
    aResult.Encoded         := True;
    aResult.Encoding        := Encoding;
    {$IFDEF FPC}
     aResult.DatabaseCharSet := DatabaseCharSet;
    {$ENDIF}
    If Not vZConnection.AutoCommit Then
     vZConnection.Commit;
    aResult.SetValue('COMMANDOK');
    Result := aResult.ToJSON;
    vZConnection.Connected := vStateResource;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     If aResult = Nil Then
      aResult := TJSONValue.Create;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result := aResult.ToJson;
     vZConnection.Rollback;
     vZConnection.Connected := False;
    Except
    End;
   End;
 End;
 If Assigned(aResult) Then
  FreeAndNil(aResult);
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverZeos.GetGenID(Query   : TComponent;
                                    GenName : String)       : Integer;
Var
 vTempClient : TzQuery;
Begin
 Result := -1;
 If TzQuery(Query).Connection <> Nil then
  If Pos('firebird', TzQuery(Query).Connection.Protocol) > 0 Then
   Begin
    vTempClient := TzQuery.Create(Nil);
    Try
     vTempClient.Connection := TzQuery(Query).Connection;
     vTempClient.SQL.Add(Format('select gen_id(%s, 1)GenID From rdb$database', [GenName]));
     vTempClient.Active := True;
     Result := vTempClient.FindField('GenID').AsInteger;
    Finally
     FreeAndnil(vTempClient);
    End;
   End;
End;

procedure TRESTDWDriverZeos.ExecuteProcedure(ProcName       : String;
                                           Params           : TRESTDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String);
Var
 A, I            : Integer;
 vStateResource  : Boolean;
 vParamName      : String;
 vTempStoredProc : TZStoredProc;
 Function GetParamIndex(Params : TParams; ParamName : String) : Integer;
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
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error  := False;
 vTempStoredProc                               := TZStoredProc.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempStoredProc.Connection                   := vZConnection;
  If Params <> Nil Then
   Begin
    Try
     vTempStoredProc.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If vTempStoredProc.Params.Count > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := GetParamIndex(TParams(vTempStoredProc.Params), vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If vTempStoredProc.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion >= 22} // Delphi 2010 pra baixo
                                                    ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
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
  If Not vZConnection.AutoCommit Then
   vZConnection.Commit;
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     vZConnection.Rollback;
    Except
    End;
    Error                  := True;
    MessageError           := E.Message;
    vZConnection.Connected := False;
   End;
 End;
 vTempStoredProc.Free;
End;

procedure TRESTDWDriverZeos.ExecuteProcedurePure(ProcName         : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String);
Var
 vTempStoredProc : TZStoredProc;
 vStateResource  : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error                                         := False;
 vTempStoredProc                               := TZStoredProc.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempStoredProc.Connection                   := vZConnection;
  vTempStoredProc.ExecProc;
  If Not vZConnection.AutoCommit Then
   vZConnection.Commit;
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     vZConnection.Rollback;
    Except
    End;
    Error                  := True;
    MessageError           := E.Message;
    vZConnection.Connected := False;
   End;
 End;
 vTempStoredProc.Free;
End;

Function TRESTDWDriverZeos.ApplyUpdatesTB(Massive              : String;
                                          Params               : TRESTDWParams;
                                          Var Error            : Boolean;
                                          Var MessageError     : String;
                                          Var RowsAffected     : Integer) : TJSONValue;
Var
 vTempQuery     : TZTable;
 vZSequence     : TZSequence;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
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
 Function LoadMassive(Massive : String; Var Query : TZTable) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TZTable;
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
//            Query.Fields[I].DataType := ftString;
            Query.Fields[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value, 1, Query.Fields[I].Size);
           End
          Else
           Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
         End;
       End
      Else
       Begin
//        If Query.Fields[I].DataType in [ftUnknown] Then
//         Begin
//          If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldType) in [ftUnknown]) Then
//           Query.Fields[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldType)
//          Else
//           Query.Fields[I].DataType := ftString;
//         End;
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
                   If I = 0 Then
                    vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value])
                   Else
                    vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value]);
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
             vZSequence.Connection   := vZConnection;
             Query.SequenceField     := MassiveDataset.Fields.Items[I].FieldName;
             vZSequence.SequenceName := MassiveDataset.SequenceName;
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
     If Not vZConnection.InTransaction Then
      Begin
       If not vZConnection.AutoCommit Then
        vZConnection.StartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
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
        If vZConnection.InTransaction Then
         If not vZConnection.AutoCommit Then
          vZConnection.Rollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If vZConnection.InTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
          If not vZConnection.AutoCommit Then
           vZConnection.Commit;
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
          If vZConnection.InTransaction Then
           If not vZConnection.AutoCommit Then
            vZConnection.Rollback;
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
    If vZConnection.InTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
      If not vZConnection.AutoCommit Then
       vZConnection.Commit;
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
      If vZConnection.InTransaction Then
       If not vZConnection.AutoCommit Then
        vZConnection.Rollback;
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
  vTempQuery     := TZTable.Create(Owner);
  vValueKeys     := TRESTDWValueKeys.Create;
  vTempQuery.UpdateMode    := umUpdateAll;
  vTempQuery.WhereMode     := wmWhereAll;
  vTempQuery.CachedUpdates := False;
  vZSequence := TZSequence.Create(Owner);
  vTempQuery.Sequence := vZSequence;
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
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
                    vTempQuery.Fields[A].AsDateTime  := Params[I].AsDateTime
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
       vZConnection.Connected := vStateResource;
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
          vZConnection.Rollback;
          vZConnection.Connected := False;
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
      vZConnection.Connected := vStateResource;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  If Assigned(vZSequence) Then
   FreeAndNil(vZSequence);
  FreeAndNil(vTempQuery);
  FreeAndNil(vValueKeys);
 End;
End;

Function TRESTDWDriverZeos.ApplyUpdates(Massive,
                                        SQL               : String;
                                        Params            : TRESTDWParams;
                                        Var Error         : Boolean;
                                        Var MessageError  : String;
                                        Var RowsAffected  : Integer) : TJSONValue;
Var
 vTempQuery     : TZQuery;
 vZSequence     : TZSequence;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
 vMassiveLine   : Boolean;
 Function GetParamIndex(Params : TParams; ParamName : String) : Integer;
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
 Function LoadMassive(Massive : String; Var Query : TZQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TZQuery;
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
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
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
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Begin
            Query.Params[I].DataType := ftString;
            Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size);
           End
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
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
             Query.Params[I]{$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
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
//     Query.UseSequenceFieldForRefreshSQL := True;
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
//           Query.FindField(MassiveDataset.Fields.Items[I].FieldName).AutoGenerateValue := arAutoInc;
           If MassiveDataset.SequenceName <> '' Then
            Begin
             vZSequence.Connection   := vZConnection;
             Query.SequenceField     := MassiveDataset.Fields.Items[I].FieldName;
             vZSequence.SequenceName := MassiveDataset.SequenceName;
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
     For I := 0 To Query.Params.Count -1 Do
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
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   {$IFNDEF FPC}
                    {$IF CompilerVersion >= 22}
                     If Query.Params[I].DataType in [ftLargeint] Then
                      Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                     Else If Query.Params[I].DataType = ftSmallInt Then
                      Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                     Else
                      Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                    {$ELSE}
                     Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                    {$IFEND}
                   {$ELSE}
                    Query.Params[I].AsLargeInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   {$ENDIF}
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd] Then
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
           If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If Query.Params[I].DataType = ftUnknown Then
            Query.Params[I].DataType := vFieldType;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo{$IFNDEF FPC}
                                           {$IF CompilerVersion > 22}
                                            , ftWideMemo
                                           {$IFEND}
                                           {$ELSE}
                                           , ftWideMemo
                                         {$ENDIF}]    Then
              Begin
               If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Begin
                   Query.Params[I].DataType := ftString;
                   Query.Params[I].AsString := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size);
                  End
                 Else
                  Query.Params[I].AsString := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
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
               Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}, ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                    Begin
                     {$IFNDEF FPC}
                      {$IF CompilerVersion > 22}Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                      {$ELSE}Query.Params[I].AsInteger                     := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                      {$IFEND}
                     {$ELSE}
                      Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                     {$ENDIF}
                    End
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
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
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
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
     If Not vZConnection.InTransaction Then
      Begin
       If not vZConnection.AutoCommit Then
        vZConnection.StartTransaction;
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
          (MassiveDataset.MassiveMode = mmDelete)) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If vZConnection.InTransaction Then
         If not vZConnection.AutoCommit Then
          vZConnection.Rollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If vZConnection.InTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
          If not vZConnection.AutoCommit Then
           vZConnection.Commit;
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
          If vZConnection.InTransaction Then
           If not vZConnection.AutoCommit Then
            vZConnection.Rollback;
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
    If vZConnection.InTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
      If not vZConnection.AutoCommit Then
       vZConnection.Commit;
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
      If vZConnection.InTransaction Then
       If not vZConnection.AutoCommit Then
        vZConnection.Rollback;
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
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Try
  Result     := Nil;
  Error      := False;
  vStringStream  := Nil;
  vTempQuery := TZQuery.Create(Owner);
  vTempQuery.UpdateMode    := umUpdateAll;
  vTempQuery.WhereMode     := wmWhereAll;
  vTempQuery.CachedUpdates := False;
  vZSequence := TZSequence.Create(Owner);
  vTempQuery.Sequence := vZSequence;
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
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
           If vTempQuery.Params.Count > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A          := GetParamIndex(TParams(vTempQuery.Params), vParamName);
             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
              Begin
               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
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
                 If vTempQuery.Params[A].Size > 0 Then
                  Begin
                   vTempQuery.Params[A].DataType := ftString;
                   vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size);
                  End
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
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}, ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                      Begin
                       {$IFNDEF FPC}
                        {$IF CompilerVersion > 22}vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value);
                        {$ELSE}vTempQuery.Params[A].AsInteger                     := StrToInt64(Params[I].Value);
                        {$IFEND}
                       {$ELSE}
                        vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value);
                       {$ENDIF}
                      End
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
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
       vZConnection.Connected := vStateResource;
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
          vZConnection.Rollback;
          vZConnection.Connected := False;
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
      vZConnection.Connected := vStateResource;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  If Assigned(vZSequence) Then
   FreeAndNil(vZSequence);
  FreeAndNil(vTempQuery);
 End;
End;

Function TRESTDWDriverZeos.ExecuteCommandTB(Tablename            : String;
                                            Var Error            : Boolean;
                                            Var MessageError     : String;
                                            Var BinaryBlob       : TMemoryStream;
                                            Var RowsAffected     : Integer;
                                            BinaryEvent          : Boolean = False;
                                            MetaData             : Boolean = False;
                                            BinaryCompatibleMode : Boolean = False)  : String;
Var
 vTempQuery     : TZTable;
 aResult        : TJSONValue;
 vStateResource : Boolean;
 vDWMemtable1   : TRESTDWMemtable;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 aResult := Nil;
 Result  := '';
 Error   := False;
 vTempQuery               := TZTable.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
  vTempQuery.TableName    := TableName;
  vTempQuery.FetchRow := -1;
  If Assigned(Self.OnTableBeforeOpen) Then
   Self.OnTableBeforeOpen(TDataset(vTempQuery), Nil, TableName);
  If Not vTempQuery.Active Then
   vTempQuery.Open;
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
      BinaryBlob  := TMemoryStream.Create;
     vDWMemtable1 := TRESTDWMemtable.Create(Nil);
     Try
      vDWMemtable1.Assign(vTempQuery);
      vDWMemtable1.SaveToStream(BinaryBlob);
      BinaryBlob.Position := 0;
     Finally
      FreeAndNil(vDWMemtable1);
     End;
    End
   Else
    TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
   FreeAndNil(aResult);
  Finally
  End;
  vZConnection.Connected := vStateResource;
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
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result := aResult.ToJSON;
     vZConnection.Rollback;
     vZConnection.Connected := False;
    Except
    End;
    FreeAndNil(aResult);
   End;
 End;
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverZeos.ExecuteCommand(SQL                  : String;
                                          Var Error            : Boolean;
                                          Var MessageError     : String;
                                          Var BinaryBlob       : TMemoryStream;
                                          Var RowsAffected     : Integer;
                                          Execute              : Boolean = False;
                                          BinaryEvent          : Boolean = False;
                                          MetaData             : Boolean = False;
                                          BinaryCompatibleMode : Boolean = False) : String;
Var
 vTempQuery     : TZQuery;
 aResult        : TJSONValue;
 vStateResource : Boolean;
 vDWMemtable1   : TRESTDWMemtable;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 aResult := Nil;
 Result  := '';
 Error   := False;
 vTempQuery               := TZQuery.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Not Execute Then
   Begin
    vTempQuery.FetchRow := -1;
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
        BinaryBlob  := TMemoryStream.Create;
       vDWMemtable1 := TRESTDWMemtable.Create(Nil);
       Try
        vDWMemtable1.Assign(vTempQuery);
        vDWMemtable1.SaveToStream(BinaryBlob);
        BinaryBlob.Position := 0;
       Finally
        FreeAndNil(vDWMemtable1);
       End;
      End
     Else
      TRESTDWClientSQLBase.SaveToStream(vTempQuery, BinaryBlob);
     FreeAndNil(aResult);
     vZConnection.Connected := vStateResource;
    Finally
    End;
   End
  Else
   Begin
    aResult := TJSONValue.Create;
    Try
     vTempQuery.ExecSQL;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     If Not vZConnection.AutoCommit Then
      vZConnection.Commit;
     Error         := False;
     Result := aResult.ToJSON;
     aResult.SetValue('COMMANDOK');
    Finally
     FreeAndNil(aResult);
     vZConnection.Connected := vStateResource;
    End;
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
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result := aResult.ToJSON;
     vZConnection.Rollback;
     vZConnection.Connected := False;
    Except
    End;
    FreeAndNil(aResult);
   End;
 End;
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverZeos.GetConnection: TZConnection;
Begin
 Result := vZConnection;
End;

Function TRESTDWDriverZeos.InsertMySQLReturnID(SQL              : String;
                                             Params           : TRESTDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 A, I           : Integer;
 vParamName     : String;
 ZCommand       : TZQuery;
 vStateResource : Boolean;
 vStringStream  : TMemoryStream;
 Function GetParamIndex(Params : TParams; ParamName : String) : Integer;
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
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Result := -1;
 Error  := False;
 vStringStream  := Nil;
 ZCommand := TZQuery.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  ZCommand.Connection := vZConnection;
  ZCommand.SQL.Clear;
  ZCommand.SQL.Add(SQL + '; SELECT LAST_INSERT_ID()ID');
  If Params <> Nil Then
   Begin
    Try
    // vTempQuery.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If ZCommand.Params.Count > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := GetParamIndex(TParams(ZCommand.Params), vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If ZCommand.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion >= 22} // Delphi 2010 pra baixo
                                                ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                ftString,    ftWideString]    Then
           Begin
            If ZCommand.Params[A].Size > 0 Then
             ZCommand.Params[A].Value := Copy(Params[I].Value, 1, ZCommand.Params[A].Size)
            Else
             ZCommand.Params[A].Value := Params[I].Value;
           End
          Else
           Begin
            If ZCommand.Params[A].DataType in [ftUnknown] Then
             Begin
              If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
               ZCommand.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
              Else
               ZCommand.Params[A].DataType := ftString;
             End;
            If ZCommand.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               Begin
                {$IFNDEF FPC}
                {$IF CompilerVersion < 22}
                 If ZCommand.Params[A].DataType = ftSmallInt Then
                 begin
                   ZCommand.Params[A].AsSmallInt := StrToInt(Params[I].Value);
                 end
                 else
                 begin
                   ZCommand.Params[A].AsInteger  := StrToInt64(Params[I].Value);
                 end;
                {$ELSE}
                  If ZCommand.Params[A].DataType in [ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
                  begin
                   ZCommand.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                  end
                  else If ZCommand.Params[A].DataType = ftSmallInt Then
                  begin
                   ZCommand.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                  end
                  Else
                  begin
                   ZCommand.Params[A].AsInteger  := StrToInt(Params[I].Value);
                  end;
                  {$IFEND}
                  {$ELSE}
                    If ZCommand.Params[A].DataType in [ftLargeint{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}] Then
                    begin
                     ZCommand.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                    end
                    else If ZCommand.Params[A].DataType = ftSmallInt Then
                    begin
                     ZCommand.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                    end
                    Else
                    begin
                     ZCommand.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    end;
                {$ENDIF}
               End;
             End
            Else If ZCommand.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD{$IFNDEF FPC}{$if CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               ZCommand.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value));
             End
            Else If ZCommand.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               Begin
                If ZCommand.Params[A].DataType = ftDate Then
                 ZCommand.Params[A].AsDate     := Params[I].AsDateTime
                Else If ZCommand.Params[A].DataType = ftTime Then
                 ZCommand.Params[A].AsTime     := Params[I].AsDateTime
                Else
                 ZCommand.Params[A].AsDateTime := Params[I].AsDateTime;
               End
              Else
               ZCommand.Params[A].AsDateTime  := Null;
             End  //Tratar Blobs de Parametros...
            Else If ZCommand.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob,
                                                    ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                            {$IF CompilerVersion > 22}
                                                             , ftWideMemo
                                                            {$IFEND}
                                                            {$ELSE}
                                                            , ftWideMemo
                                                           {$ENDIF}] Then
             Begin
              //vStringStream := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(vStringStream);
               vStringStream.Position := 0;
               If vStringStream.Size > 0 Then
                ZCommand.Params[A].LoadFromStream(vStringStream, ftBlob);
              Finally
               If Assigned(vStringStream) Then
                FreeAndNil(vStringStream);
              End;
             End
            Else
             ZCommand.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else
       Break;
     End;
   End;
  ZCommand.Open;
  If ZCommand.RecordCount > 0 Then
   Result := StrToInt(ZCommand.FindField('ID').AsString);
  If Not vZConnection.AutoCommit Then
   vZConnection.Commit;
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vZConnection.Rollback;
    Error        := True;
    MessageError := E.Message;
    vZConnection.Connected := False;
   End;
 End;
 ZCommand.Close;
 FreeAndNil(ZCommand);
End;

procedure TRESTDWDriverZeos.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = vZConnection) then
  begin
    vZConnection := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

Procedure TRESTDWDriverZeos.GetTableNames(Var TableNames       : TStringList;
                                          Var Error            : Boolean;
                                          Var MessageError     : String);
Var
 vStateResource : Boolean;
Begin
 TableNames := TStringList.Create;
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vZConnection.GetTableNames('', TableNames);
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    vZConnection.Connected := False;
   End;
 End;
End;

Procedure TRESTDWDriverZeos.GetProcNames(Var ProcNames        : TStringList;
                                         Var Error            : Boolean;
                                         Var MessageError     : String);
Var
 vStateResource : Boolean;
Begin
 ProcNames := TStringList.Create;
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vZConnection.GetStoredProcNames('', ProcNames);
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    vZConnection.Connected := False;
   End;
 End;
End;

Procedure TRESTDWDriverZeos.GetProcParams(ProcName             : String;
                                          Var ParamNames       : TStringList;
                                          Var Error            : Boolean;
                                          Var MessageError     : String);
Var
 vFDStoredProc  : TzStoredProc;
 vStateResource : Boolean;
 I              : Integer;
Begin
 ParamNames := TStringList.Create;
 vFDStoredProc := TzStoredProc.Create(Nil);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vFDStoredProc.Connection     := vZConnection;
  vFDStoredProc.StoredProcName := ProcName;
  For I := 0 To vFDStoredProc.Params.Count -1 Do
   ParamNames.Add(Format(cParamDetails, [vFDStoredProc.Params[I].Name,
                                         GetFieldType(vFDStoredProc.Params[I].DataType),
                                         vFDStoredProc.Params[I].Size,
                                         vFDStoredProc.Params[I].Precision]));
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    vZConnection.Connected := False;
   End;
 End;
 FreeAndNil(vFDStoredProc);
End;

Procedure TRESTDWDriverZeos.GetKeyFieldNames(TableName            : String;
                                             Var FieldNames       : TStringList;
                                             Var Error            : Boolean;
                                             Var MessageError     : String);
Var
 vZMetadata     : TZSQLMetadata;
 vTable,
 vSchema        : String;
 vStateResource : Boolean;
 Procedure LoadResult;
 Begin
  vZMetadata.Open;
  vZMetadata.First;
  While Not vZMetadata.Eof Do
   Begin
    FieldNames.Add(vZMetadata.FindField('COLUMN_NAME').AsString);
    vZMetadata.Next;
   End;
 End;
Begin
 vTable     := TableName;
 vSchema    := '';
 If Pos('.', vTable) > 0 Then
  Begin
   vSchema  := Copy(vTable, InitStrPos, Pos('.', vTable) -1);
   DeleteStr(vTable, InitStrPos, Pos('.', vTable));
  End;
 FieldNames := TStringList.Create;
 vStateResource := vZConnection.Connected;
 If Not vZConnection.Connected Then
  vZConnection.Connected := True;
 vZMetadata              := TZSQLMetadata.Create(Nil);
 Try
  vZMetadata.Connection   := vZConnection;
  If Pos('firebird', vZConnection.Protocol) > 0 Then
   vTable := Uppercase(vTable);
  vZMetadata.TableName    := vTable;
  If vSchema <> '' Then
   vZMetadata.Schema      := vSchema;
  vZMetadata.MetadataType := mdPrimaryKeys;
  LoadResult;
  vZConnection.Connected  := vStateResource;
 Except
  On E : Exception do
   Begin
    Error                  := True;
    MessageError           := E.Message;
    vZConnection.Connected := False;
   End;
 End;
 vZConnection.Connected := False;
 vZMetadata.Close;
 vZMetadata.Free;
End;

Procedure TRESTDWDriverZeos.GetFieldNames(TableName            : String;
                                          Var FieldNames       : TStringList;
                                          Var Error            : Boolean;
                                          Var MessageError     : String);
Var
 vTable,
 vSchema    : String;
 vStateResource : Boolean;
Begin
 vTable     := TableName;
 vSchema    := '';
 If Pos('.', vTable) > 0 Then
  Begin
   vSchema  := Copy(vTable, InitStrPos, Pos('.', vTable) -1);
   DeleteStr(vTable, InitStrPos, Pos('.', vTable));
  End;
 FieldNames := TStringList.Create;
 Try
  If vSchema <> '' Then
   vZConnection.Catalog := vSchema;
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  If Pos('firebird', vZConnection.Protocol) > 0 Then
   vTable := Uppercase(vTable);
  vZConnection.GetColumnNames(vTable, '', FieldNames);
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    vZConnection.Connected := False;
   End;
 End;
End;

Function TRESTDWDriverZeos.OpenDatasets     (DatasetsLine     : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String;
                                             Var BinaryBlob   : TMemoryStream) : TJSONValue;
Var
 vTempQuery      : TZQuery;
 vTempJSON       : TJSONValue;
 vJSONLine       : String;
 I, X            : Integer;
 vCompatibleMode,
 vStateResource,
 vBinaryEvent    : Boolean;
 DWParams        : TRESTDWParams;
 bJsonArray      : TRESTDWJSONInterfaceArray;
 bJsonValue      : TRESTDWJSONInterfaceObject;
 vStream         : TMemoryStream;
 vDWMemtable1    : TRESTDWMemtable;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error           := False;
 {$IFDEF FPC}
 vBinaryEvent    := False;
 {$ENDIF}
 vStream         := Nil;
// vMetaData       := False;
 vCompatibleMode := False;
 bJsonArray      := Nil;
 vTempQuery      := TZQuery.Create(Nil);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  vTempQuery.Connection   := vZConnection;
  bJsonValue  := TRESTDWJSONInterfaceObject.Create(DatasetsLine);
  For I := 0 To bJsonValue.PairCount - 1 Do
   Begin
    bJsonArray  := bJsonValue.OpenArray(I);
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vBinaryEvent    := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[2].Value);
//    vMetaData       := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[3].Value);
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
    vTempQuery.FetchAll;
    vTempJSON  := TJSONValue.Create;
    vTempJSON.Encoding := Encoding;
    If Not vBinaryEvent Then
     Begin
      vTempJSON.Utf8SpecialChars := True;
      vTempJSON.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
     End
    Else If Not vCompatibleMode Then
     Begin
      vStream      := TMemoryStream.Create;
      vDWMemtable1 := TRESTDWMemtable.Create(Nil);
      Try
       vDWMemtable1.Assign(vTempQuery);
       vDWMemtable1.SaveToStream(vStream);
       vStream.Position := 0;
      Finally
       FreeAndNil(vDWMemtable1);
      End;
     End
    Else
     TRESTDWClientSQLBase.SaveToStream(vTempQuery, vStream);
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
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     Error          := True;
     MessageError   := E.Message;
     vJSONLine      := GetPairJSONStr('NOK', MessageError);
    Except
    End;
    vZConnection.Connected := False;
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

Procedure TRESTDWDriverZeos.PrepareConnection(Var ConnectionDefs : TConnectionDefs);
 Procedure ServerParamValue(ParamName, Value : String);
 Var
  I, vIndex : Integer;
  vFound : Boolean;
 Begin
  vFound := False;
  vIndex := -1;
  For I := 0 To vZConnection.Properties.Count -1 Do
   Begin
    If Lowercase(vZConnection.Properties.Names[I]) = Lowercase(ParamName) Then
     Begin
      vFound := True;
      vIndex := I;
      Break;
     End;
   End;
  If Not (vFound) Then
   vZConnection.Properties.Add(Format('%s=%s', [ParamName, Value]))
  Else
   vZConnection.Properties[vIndex] := Format('%s=%s', [ParamName, Value]);
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 If Assigned(ConnectionDefs) Then
  Begin
   Case ConnectionDefs.DriverType Of
    dbtUndefined  : Begin

                    End;
    dbtAccess     : Begin

                    End;
    dbtDbase      : Begin

                    End;
    dbtFirebird   : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.ClientCodepage := ConnectionDefs.Charset;
                     vZConnection.Database := ConnectionDefs.DatabaseName;
                     vZConnection.HostName := ConnectionDefs.HostName;
                     vZConnection.Port     := ConnectionDefs.dbPort;
                     vZConnection.User     := ConnectionDefs.Username;
                     vZConnection.Password := ConnectionDefs.Password;
                    End;
    dbtInterbase  : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.ClientCodepage := ConnectionDefs.Charset;
                     vZConnection.Database       := ConnectionDefs.DatabaseName;
                     vZConnection.HostName       := ConnectionDefs.HostName;
                     vZConnection.Port           := ConnectionDefs.dbPort;
                     vZConnection.User           := ConnectionDefs.Username;
                     vZConnection.Password       := ConnectionDefs.Password;
                    End;
    dbtMySQL      : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.ClientCodepage := ConnectionDefs.Charset;
                     vZConnection.Database       := ConnectionDefs.DatabaseName;
                     vZConnection.HostName       := ConnectionDefs.HostName;
                     vZConnection.Port           := ConnectionDefs.dbPort;
                     vZConnection.User           := ConnectionDefs.Username;
                     vZConnection.Password       := ConnectionDefs.Password;
                    End;
    dbtSQLLite    : Begin
                     vZConnection.Protocol       := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.Database       := ConnectionDefs.DatabaseName;
                    End;
    dbtOracle     : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.ClientCodepage := ConnectionDefs.Charset;
                     vZConnection.Database       := ConnectionDefs.DatabaseName;
                     vZConnection.HostName       := ConnectionDefs.HostName;
                     vZConnection.Port           := ConnectionDefs.dbPort;
                     vZConnection.User           := ConnectionDefs.Username;
                     vZConnection.Password       := ConnectionDefs.Password;
                    End;
    dbtMsSQL      : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.ClientCodepage := ConnectionDefs.Charset;
                     vZConnection.Database       := ConnectionDefs.DatabaseName;
                     vZConnection.HostName       := ConnectionDefs.HostName;
                     vZConnection.Port           := ConnectionDefs.dbPort;
                     vZConnection.User           := ConnectionDefs.Username;
                     vZConnection.Password       := ConnectionDefs.Password;
                    End;
    dbtODBC       : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.Database := ConnectionDefs.DataSource;
                    End;
    dbtParadox    : Begin

                    End;
    dbtPostgreSQL : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.ClientCodepage := ConnectionDefs.Charset;
                     vZConnection.Database       := ConnectionDefs.DatabaseName;
                     vZConnection.HostName       := ConnectionDefs.HostName;
                     vZConnection.Port           := ConnectionDefs.dbPort;
                     vZConnection.User           := ConnectionDefs.Username;
                     vZConnection.Password       := ConnectionDefs.Password;
                    End;
    dbtAdo        : Begin
                     vZConnection.Protocol := ConnectionDefs.Protocol;
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     vZConnection.Database := ConnectionDefs.DataSource;
                    End;

   End;
  End;
End;

Function TRESTDWDriverZeos.InsertMySQLReturnID(SQL              : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 ZCommand       : TZQuery;
 vStateResource : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Result := -1;
 Error  := False;
 ZCommand := TZQuery.Create(Owner);
 Try
  vStateResource := vZConnection.Connected;
  If Not vZConnection.Connected Then
   vZConnection.Connected := True;
  ZCommand.Connection := vZConnection;
  ZCommand.SQL.Clear;
  ZCommand.SQL.Add(SQL + '; SELECT LAST_INSERT_ID()ID');
  ZCommand.Open;
  If ZCommand.RecordCount > 0 Then
   Result := StrToInt(ZCommand.FindField('ID').AsString);
  If Not vZConnection.AutoCommit Then
   vZConnection.Commit;
  vZConnection.Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    vZConnection.Rollback;
    Error        := True;
    MessageError := E.Message;
    vZConnection.Connected := False;
   End;
 End;
 ZCommand.Close;
 FreeAndNil(ZCommand);
End;

Procedure TRESTDWDriverZeos.SetConnection(Value: TZConnection);
Begin
  if vZConnection <> Value then
    vZConnection := Value;
  if vZConnection <> nil then
    vZConnection.FreeNotification(Self);
End;

end.
