unit uRestDWLazDriver;

interface

uses SysUtils,  Classes, DB, lconvencoding, uRESTDWCharset,
     sqldb,       mssqlconn,     pqconnection,
     oracleconnection,  odbcconn,        mysql40conn,   mysql41conn,
     mysql50conn,       mysql51conn,     mysql55conn,   mysql56conn,
     mysql57conn,       sqlite3conn,     ibconnection,  uRESTDWConsts,
     uRESTDWDataUtils,     uRESTDWBasicDB,
     uRESTDWJSONInterface, uRESTDWDataJSON,     uRESTDWMassiveBuffer,
     Variants,             uRESTDWDatamodule,   uRESTDWDataset,
     uRESTDWJSONObject,    uRESTDWParams,       uRESTDWBasicTypes,
     uRESTDWBasic,         uRESTDWTools;

Type
 TRESTDWLazDriver   = Class(TRESTDWDriver)
 Private
  vConnectionBack,
  vConnection                   : TComponent;
  Procedure SetConnection(Value : TComponent);
  Function  GetConnection       : TComponent;
  Procedure SetTransaction(Var Value: TSQLTransaction);
 Public
  Function ConnectionSet                                  : Boolean;Override;
  Function GetGenID                 (Query                : TComponent;
                                     GenName              : String)        : Integer;Override;
  Function ApplyUpdatesTB           (Massive              : String;
                                     Params               : TRESTDWParams;
                                     Var Error            : Boolean;
                                     Var MessageError     : String;
                                     Var RowsAffected     : Integer)        : TJSONValue;Override;
  Function ExecuteCommandTB       (Tablename            : String;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Var BinaryBlob       : TMemoryStream;
                                   Var RowsAffected     : Integer;
                                   BinaryEvent          : Boolean = False;
                                   MetaData             : Boolean = False;
                                   BinaryCompatibleMode : Boolean = False)  : String;Overload;Override;
  Function ExecuteCommandTB       (Tablename            : String;
                                   Params               : TRESTDWParams;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Var BinaryBlob       : TMemoryStream;
                                   Var RowsAffected     : Integer;
                                   BinaryEvent          : Boolean = False;
                                   MetaData             : Boolean = False;
                                   BinaryCompatibleMode : Boolean = False)  : String;Overload;Override;
  Function ApplyUpdates           (Massive,
                                   SQL                  : String;
                                   Params               : TRESTDWParams;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Var RowsAffected     : Integer)          : TJSONValue;Override;
  Function ApplyUpdates_MassiveCache(MassiveCache       : String;
                                     Var Error          : Boolean;
                                     Var MessageError   : String)          : TJSONValue;
  Function ProcessMassiveSQLCache   (MassiveSQLCache    : String;
                                     Var Error          : Boolean;
                                     Var MessageError   : String)          : TJSONValue;
  Function ExecuteCommand         (SQL                  : String;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Var BinaryBlob       : TMemoryStream;
                                   Var RowsAffected     : Integer;
                                   Execute              : Boolean = False;
                                   BinaryEvent          : Boolean = False;
                                   MetaData             : Boolean = False;
                                   BinaryCompatibleMode : Boolean = False) : String;Overload;Override;
  Function ExecuteCommand         (SQL                  : String;
                                   Params               : TRESTDWParams;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Var BinaryBlob       : TMemoryStream;
                                   Var RowsAffected     : Integer;
                                   Execute              : Boolean = False;
                                   BinaryEvent          : Boolean = False;
                                   MetaData             : Boolean = False;
                                   BinaryCompatibleMode : Boolean = False) : String;Overload;Override;
  Function InsertMySQLReturnID    (SQL                  : String;
                                   Var Error            : Boolean;
                                   Var MessageError     : String)          : Integer;Overload;Override;
  Function InsertMySQLReturnID    (SQL                  : String;
                                   Params               : TRESTDWParams;
                                   Var Error            : Boolean;
                                   Var MessageError     : String)          : Integer;Overload;Override;
  Procedure ExecuteProcedure      (ProcName             : String;
                                   Params               : TRESTDWParams;
                                   Var Error            : Boolean;
                                   Var MessageError     : String);Override;
  Procedure ExecuteProcedurePure  (ProcName             : String;
                                   Var Error            : Boolean;
                                   Var MessageError     : String);Override;
  Function  OpenDatasets          (DatasetsLine         : String;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Var BinaryBlob       : TMemoryStream)   : TJSONValue;Override;
  Class Procedure CreateConnection(Const ConnectionDefs : TConnectionDefs;
                                   Var   Connection     : TObject);        Override;
  Procedure PrepareConnection     (Var   ConnectionDefs : TConnectionDefs);Override;
  Procedure GetTableNames         (Var TableNames       : TStringList;
                                   Var Error            : Boolean;
                                   Var MessageError     : String);Override;
  Procedure GetFieldNames         (TableName            : String;
                                   Var FieldNames       : TStringList;
                                   Var Error            : Boolean;
                                   Var MessageError     : String);Override;
  Procedure GetKeyFieldNames      (TableName            : String;
                                   Var FieldNames       : TStringList;
                                   Var Error            : Boolean;
                                   Var MessageError     : String);Override;
  Procedure GetProcNames          (Var ProcNames        : TStringList;
                                   Var Error            : Boolean;
                                   Var MessageError     : String);                  Override;
  Procedure GetProcParams         (ProcName             : String;
                                   Var ParamNames       : TStringList;
                                   Var Error            : Boolean;
                                   Var MessageError     : String);                  Override;
  Procedure Close;Override;
 Published
  Property Connection : TComponent Read GetConnection Write SetConnection;
End;

Procedure Register;

implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWLazDriver]);
End;

{ TConnection }

procedure TRESTDWLazDriver.SetTransaction(var Value: TSQLTransaction);
Begin
 If (vConnection is TIBConnection) Then
  TIBConnection(vConnection).Transaction := Value
 Else If (vConnection is TMSSQLConnection) Then
  TMSSQLConnection(vConnection).Transaction := Value
 Else If (vConnection is TMySQL40Connection) Then
  TMySQL40Connection(vConnection).Transaction := Value
 Else If (vConnection is TMySQL41Connection) Then
  TMySQL41Connection(vConnection).Transaction := Value
 Else If (vConnection is TMySQL50Connection) Then
  TMySQL50Connection(vConnection).Transaction := Value
 Else If (vConnection is TMySQL51Connection) Then
  TMySQL51Connection(vConnection).Transaction := Value
 Else If (vConnection is TMySQL55Connection) Then
  TMySQL55Connection(vConnection).Transaction := Value
 Else If (vConnection is TMySQL56Connection) Then
  TMySQL56Connection(vConnection).Transaction := Value
 Else If (vConnection is TMySQL57Connection) Then
  TMySQL57Connection(vConnection).Transaction := Value
 Else If (vConnection is TODBCConnection) Then
  TODBCConnection(vConnection).Transaction := Value
 Else If (vConnection is TOracleConnection) Then
  TOracleConnection(vConnection).Transaction := Value
 Else If (vConnection is TPQConnection) Then
  TPQConnection(vConnection).Transaction := Value
 Else If (vConnection is TSQLite3Connection) Then
  TSQLite3Connection(vConnection).Transaction := Value
 Else If (vConnection is TSybaseConnection) Then
  TSybaseConnection(vConnection).Transaction := Value;
End;

Function TRESTDWLazDriver.ConnectionSet: Boolean;
Begin
 Result := vConnection <> Nil;
End;

procedure TRESTDWLazDriver.Close;
Begin
 If Connection <> Nil Then
  TSQLConnection(Connection).Close;
End;

Function TRESTDWLazDriver.ExecuteCommand(SQL                  : String;
                                         Params               : TRESTDWParams;
                                         Var Error            : Boolean;
                                         Var MessageError     : String;
                                         Var BinaryBlob       : TMemoryStream;
                                         Var RowsAffected     : Integer;
                                         Execute              : Boolean;
                                         BinaryEvent          : Boolean;
                                         MetaData             : Boolean;
                                         BinaryCompatibleMode : Boolean): String;
Var
 vTempQuery     : TSQLQuery;
 ATransaction   : TSQLTransaction;
 A, I           : Integer;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 DataBase       : TDatabase;
 aResult        : TJSONValue;
 vDWMemtable1   : TRESTDWMemtable;
 vStateResource : Boolean;
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
 Result := '';
 Error  := False;
 vStringStream := Nil;
 aResult := TJSONValue.Create;
 {$IFDEF FPC}
  aResult.DatabaseCharSet := DatabaseCharSet;
 {$ENDIF}
 vTempQuery               := TSQLQuery.Create(Nil);
 Try
  If Assigned(vConnection) Then
   Begin
    ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
    ATransaction.DataBase := TDatabase(vConnection);
    SetTransaction(ATransaction);
    vStateResource := TDatabase(vConnection).Connected;
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Connected := True;
    vTempQuery.DataBase     := TDatabase(vConnection);
   End
  Else
   Begin
    FreeAndNil(vTempQuery);
    Exit;
   End;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Params <> Nil Then
   Begin
    Try
     If Not Execute Then
      vTempQuery.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If (vTempQuery.Params.Count > I) And (Not (Params[I].IsNull)) Then
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
            If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
             Begin
              If (Not(Params[I].IsNull)) Then
               Begin
                If vTempQuery.Params[A].DataType = ftSmallInt Then
                 vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                Else
                 vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
               End;
             End
            Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD] Then
             Begin
              If (Not(Params[I].IsNull)) Then
               vTempQuery.Params[A].AsFloat  := StrToFloat(Params[I].Value)
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
             End
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
                                                      ftMemo {$IFNDEF FPC}
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
               vTempQuery.Params[A].Value   := Params[I].AsString
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
   End;
  If Not Execute Then
   Begin
    vTempQuery.Active := True;
    aResult.Encoded         := True;
    aResult.Encoding        := Encoding;
    Try
     If Not BinaryEvent Then
      Begin
       aResult.Utf8SpecialChars := True;
       aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
       Result := aResult.ToJSON;
      End
     Else
      Begin
       If Not BinaryCompatibleMode Then
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
      End;
    Finally
    End;
    TDatabase(vConnection).Connected := vStateResource;
   End
  Else
   Begin
    vStateResource := TDatabase(vConnection).Connected;
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Connected := True;
    ATransaction.DataBase := TDatabase(vConnection);
    ATransaction.StartTransaction;;
    vTempQuery.ExecSQL;
    aResult.Encoded         := True;
    aResult.Encoding        := Encoding;
    ATransaction.Commit;
    aResult.SetValue('COMMANDOK');
    Result := aResult.ToJSON;
    TDatabase(vConnection).Connected := vStateResource;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     aResult.DatabaseCharSet := DatabaseCharSet;
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result := aResult.ToJSON;
     ATransaction.Rollback;
     TDatabase(vConnection).Connected := False;
    Except
    End;
   End;
 End;
 FreeAndNil(aResult);
 RowsAffected := vTempQuery.RowsAffected;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

Procedure TRESTDWLazDriver.ExecuteProcedure(ProcName         : String;
                                            Params           : TRESTDWParams;
                                            Var Error        : Boolean;
                                            Var MessageError : String);
Begin
End;

Procedure TRESTDWLazDriver.ExecuteProcedurePure(ProcName        : String;
                                                Var Error        : Boolean;
                                                Var MessageError : String);
Begin
End;

Function TRESTDWLazDriver.OpenDatasets(DatasetsLine     : String;
                                       Var Error        : Boolean;
                                       Var MessageError : String;
                                       Var BinaryBlob   : TMemoryStream): TJSONValue;
Var
 vTempQuery      : TSQLQuery;
 vTempJSON       : TJSONValue;
 vJSONLine       : String;
 I, X            : Integer;
 vStateResource,
 vMetaData,
 vBinaryEvent,
 vCompatibleMode : Boolean;
 DWParams        : TRESTDWParams;
 bJsonArray      : TRESTDWJSONInterfaceArray;
 bJsonValue      : TRESTDWJSONInterfaceObject;
 vStream         : TMemoryStream;
 vDWMemtable1    : TRESTDWMemtable;
 ATransaction    : TSQLTransaction;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error           := False;
 vBinaryEvent    := False;
 vMetaData       := False;
 vCompatibleMode := False;
 bJsonArray      := Nil;
 ATransaction    := Nil;
 vTempQuery      := TSQLQuery.Create(Nil);
 Try
  If Assigned(vConnection) Then
   Begin
    ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
    ATransaction.DataBase := TDatabase(vConnection);
    SetTransaction(ATransaction);
    vStateResource := TDatabase(vConnection).Connected;
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Connected := True;
    vTempQuery.DataBase     := TDatabase(vConnection);
   End
  Else
   Begin
    FreeAndNil(vTempQuery);
    Exit;
   End;
  bJsonValue  := TRESTDWJSONInterfaceObject.Create(DatasetsLine);
  For I := 0 To bJsonValue.PairCount - 1 Do
   Begin
    bJsonArray  := bJsonValue.OpenArray(I);
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vBinaryEvent    := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[2].Value);
    vMetaData       := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[3].Value);
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
    vTempJSON  := TJSONValue.Create;
    vTempJSON.Encoding := Encoding;
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
       vTempQuery.SaveToStream(vStream);
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
  TDatabase(vConnection).Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     Error          := True;
     MessageError   := E.Message;
     vJSONLine      := GetPairJSONStr('NOK', MessageError);
     TDatabase(vConnection).Connected := False;
    Except
    End;
   End;
 End;
 Result             := TJSONValue.Create;
 Result.Encoding    := Encoding;
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
 If Assigned(ATransaction) Then
  FreeAndNil(ATransaction);
End;

Class Procedure TRESTDWLazDriver.CreateConnection(Const ConnectionDefs : TConnectionDefs;
                                                  Var   Connection     : TObject);
 Procedure ServerParamValue(ParamName, Value : String);
 Var
  I, vIndex : Integer;
  vFound : Boolean;
 Begin
  vFound := False;
  vIndex := -1;
  For I := 0 To TSQLConnection(Connection).Params.Count -1 Do
   Begin
    If Lowercase(TSQLConnection(Connection).Params.Names[I]) = Lowercase(ParamName) Then
     Begin
      vFound := True;
      vIndex := I;
      Break;
     End;
   End;
  If Not (vFound) Then
   TSQLConnection(Connection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Lowercase(Value)]))
  Else
   TSQLConnection(Connection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Lowercase(Value)]);
 End;
Begin
 If Assigned(ConnectionDefs) Then
  Begin
   Case ConnectionDefs.DriverType Of
    dbtUndefined  : Begin

                    End;
    dbtAccess     : Begin
//                     TSQLConnection(Connection). DriverName := 'MSAcc';

                    End;
    dbtDbase      : Begin

                    End;
    dbtFirebird   : Begin
//                     TFDConnection(Connection).DriverName := 'FB';
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtInterbase  : Begin
//                     TFDConnection(Connection).DriverName := 'IB';
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtMySQL      : Begin
//                     TFDConnection(Connection).DriverName := 'MYSQL';

                    End;
    dbtSQLLite    : Begin
//                     TFDConnection(Connection).DriverName := 'SQLLite';

                    End;
    dbtOracle     : Begin
//                     TFDConnection(Connection).DriverName := 'Ora';

                    End;
    dbtMsSQL      : Begin
//                     TFDConnection(Connection).DriverName := 'MSSQL';
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));

                    End;
    dbtODBC       : Begin
//                     TFDConnection(Connection).DriverName := 'ODBC';
                     ServerParamValue('DataSource', ConnectionDefs.DataSource);
                    End;
    dbtParadox    : Begin

                    End;
    dbtPostgreSQL : Begin
//                     TFDConnection(Connection).DriverName := 'PG';

                    End;
   End;
  End;
End;

Procedure TRESTDWLazDriver.GetTableNames(Var TableNames   : TStringList;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Var
 vStateResource : Boolean;
Begin
 TableNames := TStringList.Create;
 Try
  vStateResource := TSQLConnection(Connection).Connected;
  If Not TSQLConnection(Connection).Connected Then
   TSQLConnection(Connection).Connected := True;
  TSQLConnection(Connection).GetTableNames(TableNames);
  TSQLConnection(Connection).Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    TSQLConnection(Connection).Connected := False;
   End;
 End;
End;

Procedure TRESTDWLazDriver.GetProcNames(Var ProcNames    : TStringList;
                                        Var Error        : Boolean;
                                        Var MessageError : String);
Var
 vStateResource : Boolean;
Begin
 ProcNames := TStringList.Create;
 Try
  vStateResource := TSQLConnection(Connection).Connected;
  If Not TSQLConnection(Connection).Connected Then
   TSQLConnection(Connection).Connected := True;
  TSQLConnection(Connection).GetProcedureNames(ProcNames);
  TSQLConnection(Connection).Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    TSQLConnection(Connection).Connected := False;
   End;
 End;
End;

Procedure TRESTDWLazDriver.GetProcParams(ProcName         : String;
                                         Var ParamNames   : TStringList;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Begin
 ParamNames := TStringList.Create;
End;

Procedure TRESTDWLazDriver.GetKeyFieldNames(TableName        : String;
                                            Var FieldNames   : TStringList;
                                            Var Error        : Boolean;
                                            Var MessageError : String);
Var
 I        : Integer;
 vSQLData : TSQLQuery;
 vTable,
 vSchema  : String;
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
  vStateResource := TSQLConnection(Connection).Connected;
  If Not TSQLConnection(Connection).Connected Then
   TSQLConnection(Connection).Connected := True;
  vSQLData  := TSQLQuery.Create(Nil);
  vSQLData.SQL.Add(Format('select * from %s where 1 = 0', [TableName]));
  vSQLData.Open;
  For I := 0 To vSQLData.fields.count -1 Do
   Begin
    If pfInKey in vSQLData.fields[I].ProviderFlags Then
     FieldNames.Add(vSQLData.fields[I].FieldName);
   End;
  TSQLConnection(Connection).Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    TSQLConnection(Connection).Connected := False;
   End;
 End;
 vSQLData.Close;
 vSQLData.Free;
End;

Procedure TRESTDWLazDriver.GetFieldNames(TableName        : String;
                                         Var FieldNames   : TStringList;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Var
 vTable,
 vSchema        : String;
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
  vStateResource := TSQLConnection(Connection).Connected;
  If Not TSQLConnection(Connection).Connected Then
   TSQLConnection(Connection).Connected := True;
  TSQLConnection(Connection).GetFieldNames(vTable, FieldNames);
  TSQLConnection(Connection).Connected := vStateResource
 Except
  On E : Exception do
   Begin
    Error          := True;
    MessageError   := E.Message;
    TSQLConnection(Connection).Connected := False;
   End;
 End;
End;

Procedure TRESTDWLazDriver.PrepareConnection(Var ConnectionDefs : TConnectionDefs);
 Procedure ServerParamValue(ParamName, Value : String);
 Var
  I, vIndex : Integer;
  vFound : Boolean;
 Begin
  vFound := False;
  vIndex := -1;
  For I := 0 To TSQLConnection(Connection).Params.Count -1 Do
   Begin
    If Lowercase(TSQLConnection(Connection).Params.Names[I]) = Lowercase(ParamName) Then
     Begin
      vFound := True;
      vIndex := I;
      Break;
     End;
   End;
  If Not (vFound) Then
   TSQLConnection(Connection).Params.Add(Format('%s=%s', [ParamName, Value]))
  Else
   TSQLConnection(Connection).Params[vIndex] := Format('%s=%s', [ParamName, Value]);
 End;
Begin
 If Assigned(ConnectionDefs) Then
  Begin
   Case ConnectionDefs.DriverType Of
    dbtUndefined  : Begin

                    End;
    dbtAccess     : Begin
//                     TSQLConnection(Connection).DriverName := 'MSAcc';

                    End;
    dbtDbase      : Begin

                    End;
    dbtFirebird   : Begin
//                     TSQLConnection(Connection).DriverName := 'FB';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtInterbase  : Begin
//                     TSQLConnection(Connection).DriverName := 'IB';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtMySQL      : Begin
//                     TSQLConnection(Connection).DriverName := 'MYSQL';

                    End;
    dbtSQLLite    : Begin
//                     TSQLConnection(Connection).DriverName := 'SQLLite';

                    End;
    dbtOracle     : Begin
//                     TSQLConnection(Connection).DriverName := 'Ora';

                    End;
    dbtMsSQL      : Begin
//                     TSQLConnection(Connection).DriverName := 'MSSQL';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtODBC       : Begin
//                     TSQLConnection(Connection).DriverName := 'ODBC';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DataSource', ConnectionDefs.DataSource);
                    End;
    dbtParadox    : Begin

                    End;
    dbtPostgreSQL : Begin
//                     TSQLConnection(Connection).DriverName := 'PG';

                    End;
   End;
  End;
End;

function TRESTDWLazDriver.GetGenID(Query: TComponent; GenName: String): Integer;
Begin
 Result := -1;
End;

Function TRESTDWLazDriver.ExecuteCommandTB(Tablename            : String;
                                           Params               : TRESTDWParams;
                                           Var Error            : Boolean;
                                           Var MessageError     : String;
                                           Var BinaryBlob       : TMemoryStream;
                                           Var RowsAffected     : Integer;
                                           BinaryEvent          : Boolean;
                                           MetaData             : Boolean;
                                           BinaryCompatibleMode : Boolean): String;
Begin

End;

Function TRESTDWLazDriver.ExecuteCommandTB(Tablename            : String;
                                           Var Error            : Boolean;
                                           Var MessageError     : String;
                                           Var BinaryBlob       : TMemoryStream;
                                           Var RowsAffected     : Integer;
                                           BinaryEvent          : Boolean;
                                           MetaData             : Boolean;
                                           BinaryCompatibleMode : Boolean): String;
Begin

End;

Function TRESTDWLazDriver.ApplyUpdatesTB(Massive          : String;
                                         Params           : TRESTDWParams;
                                         Var Error        : Boolean;
                                         Var MessageError : String;
                                         Var RowsAffected : Integer): TJSONValue;
Begin

End;

Function TRESTDWLazDriver.ApplyUpdates(Massive,
                                       SQL              : String;
                                       Params           : TRESTDWParams;
                                       Var Error        : Boolean;
                                       Var MessageError : String;
                                       Var RowsAffected : Integer): TJSONValue;
Var
 vTempQuery     : TSQLQuery;
 aTransaction   : TSQLTransaction;
 vZSequence     : TSQLSequence;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
 InTransaction,
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
  vFieldChanged     := False;
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
 Function LoadMassive(Massive : String; Var Query : TSQLQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TSQLQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLineSQL,
   vFields,
   vParamsSQL : String;
   C, I       : Integer;
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
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord,
                                                                         {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
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
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
          If Not Assigned(vStringStream) Then
           vStringStream := TMemoryStream.Create;
          Try
           If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
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
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         Query.FindField(MassiveDataset.Fields.Items[I].FieldName).Required := False;
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           vZSequence.FieldName    := MassiveDataset.Fields.Items[I].FieldName;
           vZSequence.SequenceName := MassiveDataset.SequenceName;
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
                   If Query.Params[I].DataType in [ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
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
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo{$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                         {$ENDIF}]    Then
              Begin
               If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].AsString := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
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
               Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftLongWord{$IFEND}{$ENDIF}, ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                    Begin
                     {$IFNDEF FPC}
                      {$IF CompilerVersion > 21}Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
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
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
     If Not InTransaction Then
      Begin
       ATransaction.StartTransaction;
       InTransaction := True;
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
        If InTransaction Then
         ATransaction.Rollback;
        InTransaction := False;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If InTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
          ATransaction.Commit;
          InTransaction := False;
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
          If InTransaction Then
           ATransaction.Rollback;
          InTransaction := False;
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
    If InTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
      ATransaction.Commit;
      InTransaction := False;
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
      If InTransaction Then
       ATransaction.Rollback;
      InTransaction := False;
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
  Result      := Nil;
  vStringStream := Nil;
  Error       := False;
  InTransaction := False;
  vTempQuery  := TSQLQuery.Create(Owner);
  vZSequence  := TSQLSequence.Create(vTempQuery);
  vStateResource := TDatabase(vConnection).Connected;
  If Not TDatabase(vConnection).Connected Then
   TDatabase(vConnection).Connected := True;
  vTempQuery.Sequence := vZSequence;
  vTempQuery.DataBase := TDatabase(vConnection);
  vTempQuery.SQL.Clear;
  vResultReflection := '';
  ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
  ATransaction.DataBase := TDatabase(vConnection);
  SetTransaction(ATransaction);
  vTempQuery.Transaction := ATransaction;
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
             A          := GetParamIndex(vTempQuery.Params, vParamName);
             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
              Begin
               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo {$IFNDEF FPC}
                                                              {$IF CompilerVersion > 21}
                                                               , ftWideMemo
                                                              {$IFEND}
                                                            {$ENDIF}]    Then
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
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftLongWord{$IFEND}{$ENDIF}, ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                      Begin
                       {$IFNDEF FPC}
                        {$IF CompilerVersion > 21}vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value);
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
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
       vStateResource := TDatabase(vConnection).Connected;
       If Not TDatabase(vConnection).Connected Then
        TDatabase(vConnection).Connected := True;
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
          ATransaction.Rollback;
          InTransaction := False;
          TDatabase(vConnection).Connected := False;
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
      TDatabase(vConnection).Connected := vStateResource;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
  FreeAndNil(aTransaction);
 End;
End;

Function TRESTDWLazDriver.ProcessMassiveSQLCache(MassiveSQLCache  : String;
                                                 Var Error        : Boolean;
                                                 Var MessageError : String) : TJSONValue;
Var
 vTempQuery        : TSQLQuery;
 vStringStream     : TMemoryStream;
 bPrimaryKeys      : TStringList;
 vFieldType        : TFieldType;
 vStateResource,
 InTransaction,
 vMassiveLine      : Boolean;
 vResultReflection : String;
 aTransaction      : TSQLTransaction;
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
 Function LoadMassive(Massive : String; Var Query : TSQLQuery) : Boolean;
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
     If Not InTransaction Then
      Begin
       ATransaction.StartTransaction;
       InTransaction := True;
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
                             A          := GetParamIndex(vTempQuery.Params, vParamName);
                             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
                              Begin
                               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
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
                                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftLongWord{$IFEND}{$ENDIF} ftLargeint] Then
                                  Begin
                                   If (Not(vDWParams[I].IsNull)) Then
                                    Begin
                                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                                      vTempQuery.Params[A].AsLargeInt := StrToInt64(vDWParams[I].Value)
                                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                                      vTempQuery.Params[A].AsSmallInt := StrToInt(vDWParams[I].Value)
                                     Else
                                      vTempQuery.Params[A].AsInteger  := StrToInt(vDWParams[I].Value);
                                    End
                                   Else
                                    vTempQuery.Params[A].Clear;
                                  End
                                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
      If InTransaction Then
       Begin
        ATransaction.Commit;
        InTransaction := False;
       End;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If InTransaction Then
         Begin
          ATransaction.Rollback;
          InTransaction := False;
         End;
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
 Result            := Nil;
 vStringStream     := Nil;
 InTransaction     := False;
 Try
  Error      := False;
  vTempQuery := TSQLQuery.Create(Owner);
  vStateResource := TDatabase(vConnection).Connected;
  If Not TDatabase(vConnection).Connected Then
   TDatabase(vConnection).Connected := True;
  vTempQuery.DataBase   := TDatabase(vConnection);
  ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
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
  TDatabase(vConnection).Connected := vStateResource;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
  ATransaction.Free;
 End;
End;

Function TRESTDWLazDriver.ApplyUpdates_MassiveCache(MassiveCache     : String;
                                                    Var Error        : Boolean;
                                                    Var MessageError : String): TJSONValue;
Var
 vTempQuery        : TSQLQuery;
 vZSequence        : TSQLSequence;
 aTransaction      : TSQLTransaction;
 vStringStream     : TMemoryStream;
 bPrimaryKeys      : TStringList;
 vFieldType        : TFieldType;
 vStateResource,
 InTransaction,
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
                                        vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
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
                                      If (vTempValue <> cNullvalue) And (vTempValue <> '') Then
                                       Begin
                                        If (StrToDateTime(vTempValue) <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(vTempValue)));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
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
 Function LoadMassive(Massive : String; Var Query : TSQLQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, X           : Integer;
//  bJsonArray     : udwjson.TJsonArray;
  bJsonValueB    : TRESTDWJSONInterfaceBase;
  bJsonValue     : TRESTDWJSONInterfaceObject;
  bJsonArray     : TRESTDWJSONInterfaceArray;
  Procedure PrepareData(Var Query      : TSQLQuery;
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
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
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
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
          //vStringStream := TMemoryStream.Create;
          Try
           If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
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
     Query.Open;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         Query.FindField(MassiveDataset.Fields.Items[I].FieldName).Required := False;
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           vZSequence.FieldName    := MassiveDataset.Fields.Items[I].FieldName;
           vZSequence.SequenceName := MassiveDataset.SequenceName;
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
                   If Query.Params[I].DataType in [ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
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
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo {$IFNDEF FPC}
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
               Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                    Begin
                     {$IFNDEF FPC}
                      {$IF CompilerVersion > 21}Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
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
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle{$IFEND}{$ENDIF}] Then
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
     If Not InTransaction Then
      Begin
       ATransaction.StartTransaction;
       InTransaction := True;
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
           If InTransaction Then
            Begin
             InTransaction := False;
             ATransaction.Rollback;
            End;
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
      If InTransaction Then
       Begin
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
           TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
         End;
        ATransaction.Commit;
        InTransaction := False;
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
        If InTransaction Then
         Begin
          InTransaction := False;
          ATransaction.Rollback;
         End;
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
 Result     := Nil;
 vStringStream := Nil;
 Try
  Error         := False;
  InTransaction := False;
  vTempQuery    := TSQLQuery.Create(Owner);
  vZSequence    := TSQLSequence.Create(vTempQuery);
  vStateResource := TDatabase(vConnection).Connected;
  If Not TDatabase(vConnection).Connected Then
   TDatabase(vConnection).Connected := True;
  vTempQuery.Sequence := vZSequence;
  vTempQuery.DataBase := TDatabase(vConnection);
  vTempQuery.SQL.Clear;
  vResultReflection := '';
  ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
  ATransaction.DataBase := TDatabase(vConnection);
  SetTransaction(ATransaction);
  vTempQuery.Transaction := ATransaction;
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
  TDatabase(vConnection).Connected := vStateResource;
 Finally
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
  FreeAndNil(aTransaction);
 End;
End;

Function TRESTDWLazDriver.ExecuteCommand(SQL                  : String;
                                         Var Error            : Boolean;
                                         Var MessageError     : String;
                                         Var BinaryBlob       : TMemoryStream;
                                         Var RowsAffected     : Integer;
                                         Execute              : Boolean;
                                         BinaryEvent          : Boolean;
                                         MetaData             : Boolean;
                                         BinaryCompatibleMode : Boolean): String;
Var
 vTempQuery     : TSQLQuery;
 ATransaction   : TSQLTransaction;
 aResult        : TJSONValue;
 vDWMemtable1   : TRESTDWMemtable;
 vStateResource : Boolean;
Begin
 Result := '';
 Error  := False;
 vTempQuery               := TSQLQuery.Create(Nil);
 Try
  If Assigned(vConnection) Then
   Begin
    ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
    ATransaction.DataBase := TDatabase(vConnection);
    SetTransaction(ATransaction);
    vStateResource := TDatabase(vConnection).Connected;
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Connected := True;
    vTempQuery.DataBase     := TDatabase(vConnection);
   End
  Else
   Begin
    FreeAndNil(vTempQuery);
    Exit;
   End;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Not Execute Then
   Begin
    vTempQuery.Open;
    aResult         := TJSONValue.Create;
    aResult.Encoded         := True;
    aResult.Encoding        := Encoding;
    aResult.DatabaseCharSet := DatabaseCharSet;
    Try
     If Not BinaryEvent Then
      Begin
       aResult.Utf8SpecialChars := True;
       aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
       Result        := aResult.ToJSON;
      End
     Else
      Begin
       If Not BinaryCompatibleMode Then
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
      End;
     FreeAndNil(aResult);
     Error         := False;
    Finally
    End;
   End
  Else
   Begin
    Try
     ATransaction.DataBase := TDatabase(vConnection);
     ATransaction.StartTransaction;;
     vTempQuery.ExecSQL;
     aResult := TJSONValue.Create;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     ATransaction.Commit;
     aResult.SetValue('COMMANDOK');
     Result                  := aResult.ToJSON;
     FreeAndNil(aResult);
     Error         := False;
    Finally
    End;
   End;
  TDatabase(vConnection).Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     aResult := TJSONValue.Create;
     aResult.Encoded         := True;
     aResult.Encoding        := Encoding;
     {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result                  := aResult.ToJSON;
     FreeAndNil(aResult);
     ATransaction.Rollback;
     TDatabase(vConnection).Connected := False;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 RowsAffected := vTempQuery.RowsAffected;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

function TRESTDWLazDriver.GetConnection: TComponent;
Begin
 Result := vConnectionBack;
End;

function TRESTDWLazDriver.InsertMySQLReturnID(SQL: String; Params: TRESTDWParams;
  var Error: Boolean; var MessageError: String): Integer;
Var
 vTempQuery     : TSQLQuery;
 ATransaction   : TSQLTransaction;
 A, I           : Integer;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 vStateResource : Boolean;
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
 Result := -1;
 Error  := False;
 vStringStream := Nil;
 vTempQuery               := TSQLQuery.Create(Nil);
 If Assigned(vConnection) Then
  Begin
   ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
   ATransaction.DataBase := TDatabase(vConnection);
   SetTransaction(ATransaction);
   vStateResource := TDatabase(vConnection).Connected;
   If Not TDatabase(vConnection).Connected Then
    TDatabase(vConnection).Connected := True;
   vTempQuery.DataBase     := TDatabase(vConnection);
  End
 Else
  Begin
   FreeAndNil(vTempQuery);
   Exit;
  End;
 vTempQuery.SQL.Clear;
 vTempQuery.SQL.Add(SQL);
 If Params <> Nil Then
  Begin
   For I := 0 To Params.Count -1 Do
    Begin
     If vTempQuery.Params.Count > I Then
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
           If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              Begin
               If vTempQuery.Params[A].DataType = ftSmallInt Then
                vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
               Else
                vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
              End;
            End
           Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              vTempQuery.Params[A].AsFloat  := StrToFloat(Params[I].Value);
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
              vTempQuery.Params[A].AsDateTime  := Null;
            End
           Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                     ftGraphic, ftOraBlob, ftOraClob,
                                                     ftMemo {$IFNDEF FPC}
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
 Result := -1;
 Error  := False;
 Try
  Try
   ATransaction.StartTransaction;;
   vTempQuery.ExecSQL;
   If (vConnection is TMySQL40Connection)      Then
   Else If (vConnection is TMySQL41Connection) Then
    Result := TMySQL41Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL50Connection) Then
    Result := TMySQL50Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL51Connection) Then
    Result := TMySQL51Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL55Connection) Then
    Result := TMySQL55Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL56Connection) Then
    Result := TMySQL56Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL57Connection) Then
    Result := TMySQL57Connection(vConnection).GetInsertID;
   Error         := False;
   ATransaction.Commit;
  Finally
  End;
  TDatabase(vConnection).Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result       := -1;
     ATransaction.Rollback;
     TDatabase(vConnection).Connected := False;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

Function TRESTDWLazDriver.InsertMySQLReturnID(SQL              : String;
                                              Var Error        : Boolean;
                                              Var MessageError : String) : Integer;
Var
 vTempQuery     : TSQLQuery;
 ATransaction   : TSQLTransaction;
 vStateResource : Boolean;
Begin
 Result := -1;
 Error  := False;
 vTempQuery               := TSQLQuery.Create(Nil);
 If Assigned(vConnection) Then
  Begin
   ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
   ATransaction.DataBase := TDatabase(vConnection);
   SetTransaction(ATransaction);
   vStateResource := TDatabase(vConnection).Connected;
   If Not TDatabase(vConnection).Connected Then
    TDatabase(vConnection).Connected := True;
   vTempQuery.DataBase     := TDatabase(vConnection);
  End
 Else
  Begin
   FreeAndNil(vTempQuery);
   Exit;
  End;
 vTempQuery.SQL.Clear;
 vTempQuery.SQL.Add(SQL);
 Result := -1;
 Error  := False;
 Try
  Try
   ATransaction.StartTransaction;;
   vTempQuery.ExecSQL;
   If (vConnection is TMySQL40Connection)      Then
   Else If (vConnection is TMySQL41Connection) Then
    Result := TMySQL41Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL50Connection) Then
    Result := TMySQL50Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL51Connection) Then
    Result := TMySQL51Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL55Connection) Then
    Result := TMySQL55Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL56Connection) Then
    Result := TMySQL56Connection(vConnection).GetInsertID
   Else If (vConnection is TMySQL57Connection) Then
    Result := TMySQL57Connection(vConnection).GetInsertID;
   ATransaction.Commit;
   Error         := False;
  Finally
  End;
  TDatabase(vConnection).Connected := vStateResource;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result       := -1;
     ATransaction.Rollback;
     TDatabase(vConnection).Connected := False;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

procedure TRESTDWLazDriver.SetConnection(Value: TComponent);
Begin
 If Not((Value is TIBConnection)      Or
        (Value is TMSSQLConnection)   Or
        (Value is TMySQL40Connection) Or
        (Value is TMySQL41Connection) Or
        (Value is TMySQL50Connection) Or
        (Value is TMySQL51Connection) Or
        (Value is TMySQL55Connection) Or
        (Value is TMySQL56Connection) Or
        (Value is TMySQL57Connection) Or
        (Value is TODBCConnection)    Or
        (Value is TOracleConnection)  Or
        (Value is TPQConnection)      Or
        (Value is TSQLite3Connection) Or
        (Value is TSybaseConnection)) Then
  Begin
   vConnection     := Nil;
   vConnectionBack := vConnection;
   Exit;
  End;
 vConnectionBack := Value;
 If Value <> Nil Then
  vConnection    := vConnectionBack
 Else
  Begin
   If vConnection <> Nil Then
    TSQLConnection(vConnection).Close;
  End;
End;

end.
