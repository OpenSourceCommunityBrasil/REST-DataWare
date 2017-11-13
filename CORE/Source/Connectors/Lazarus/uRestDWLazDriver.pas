unit uRestDWLazDriver;

interface

uses SysUtils, Classes, DB, sqldb,       mssqlconn,     pqconnection,
     oracleconnection,  odbcconn,        mysql40conn,   mysql41conn,
     mysql50conn,       mysql51conn,     mysql55conn,   mysql56conn,
     mysql57conn,       sqlite3conn,     ibconnection,  uDWConsts,
     uDWConstsData,     uRESTDWPoolerDB, uDWJSONObject, uDWMassiveBuffer,
     udwjson, Variants;

Type

 { TRESTDWLazDriver }

 TRESTDWLazDriver   = Class(TRESTDWDriver)
 Private
  vConnectionBack,
  vConnection                   : TComponent;
  Procedure SetConnection(Value : TComponent);
  Function  GetConnection       : TComponent;
  Procedure SetTransaction(Var Value: TSQLTransaction);
 Public
  Function ApplyUpdates         (Massive,
                                 SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String)          : TJSONValue;Override;
  Procedure ApplyUpdates_MassiveCache(MassiveCache     : String;
                                      Var Error        : Boolean;
                                      Var MessageError : String);Override;
  Function ExecuteCommand       (SQL              : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Execute          : Boolean = False) : TJSONValue;Overload;Override;
  Function ExecuteCommand       (SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Execute          : Boolean = False) : TJSONValue;Overload;Override;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Override;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Override;
  Procedure ExecuteProcedure    (ProcName         : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Override;
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Override;
  Procedure Close;Override;
 Published
  Property Connection : TComponent Read GetConnection Write SetConnection;
End;

Procedure Register;

implementation

Uses uDWJSONTools;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWLazDriver]);
End;

{ TConnection }

procedure TRESTDWLazDriver.SetTransaction(Var Value: TSQLTransaction);
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

procedure TRESTDWLazDriver.Close;
Begin
 If Connection <> Nil Then
  TSQLConnection(Connection).Close;
End;

function TRESTDWLazDriver.ExecuteCommand(SQL              : String;
                                         Params           : TDWParams;
                                         Var Error        : Boolean;
                                         Var MessageError : String;
                                         Execute          : Boolean) : TJSONValue;
Var
 vTempQuery    : TSQLQuery;
 ATransaction  : TSQLTransaction;
 A, I          : Integer;
 vParamName    : String;
 vStringStream : TMemoryStream;
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
 Result := Nil;
 Error  := False;
 Result := TJSONValue.Create;
 vTempQuery               := TSQLQuery.Create(Nil);
 Try
  If Assigned(vConnection) Then
   Begin
    ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
    ATransaction.DataBase := TDatabase(vConnection);
    SetTransaction(ATransaction);
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Open;
    vTempQuery.DataBase     := TDatabase(vConnection);
   End
  Else
   Begin
    FreeAndNil(vTempQuery);
    Exit;
   End;
//  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
//  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
//  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
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
               vTempQuery.Params[A].AsDateTime  := StrToFloat(Params[I].Value)
              Else
               vTempQuery.Params[A].AsDateTime  := Null;
             End
            Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
             Begin
              vStringStream := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(vStringStream);
               vStringStream.Position := 0;
               vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
              Finally
               FreeAndNil(vStringStream);
              End;
             End
            Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                      ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                      ftString,    ftWideString]    Then
             vTempQuery.Params[A].AsString := Params[I].Value
            Else
             vTempQuery.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else
       Break;
     End;
   End;
  If Not Execute Then
   Begin
    vTempQuery.Active := True;
    Result := TJSONValue.Create;
    Result.DatabaseCharSet := DatabaseCharSet;
    Try
     Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
    Finally
    End;
   End
  Else
   Begin
    ATransaction.DataBase := TDatabase(vConnection);
    ATransaction.StartTransaction;;
    vTempQuery.ExecSQL;
    Result := TJSONValue.Create;
    Result.SetValue('COMMANDOK');
    ATransaction.Commit;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result.Encoded := True;
     Result.SetValue(GetPairJSON('NOK', MessageError));
     ATransaction.Rollback;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

procedure TRESTDWLazDriver.ExecuteProcedure(ProcName         : String;
                                           Params           : TDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String);
Begin
End;

procedure TRESTDWLazDriver.ExecuteProcedurePure(ProcName         : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String);
Begin
End;

function TRESTDWLazDriver.ApplyUpdates(Massive, SQL: String; Params: TDWParams;
  Var Error: Boolean; Var MessageError: String): TJSONValue;
Var
 vTempQuery     : TSQLQuery;
 ATransaction   : TSQLTransaction;
 A, I           : Integer;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 InTransaction  : Boolean;
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
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TSQLQuery;
                        MassiveDataset : TMassiveDatasetBuffer);
  Var
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer;
   Var
    X : Integer;
   Begin
    If I = 0 Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString, ftWideMemo]    Then
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
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Begin
                // Alterado por: Alexandre Magno - 04/11/2017
                If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftLargeint Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);

                // Como estava Anteriormente
                //If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                //  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                //Else
                //  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(MassiveDataset.AtualRec.PrimaryValues[X].Value);
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := StrToFloat(MassiveDataset.AtualRec.PrimaryValues[X].Value)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := Null;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
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
    If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                          ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                          ftString,    ftWideString, ftWideMemo]    Then
     Begin
      If Query.Params[I].Size > 0 Then
       Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
      Else
       Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
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
      If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
       Begin
        If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
         Begin
           // Alterado por: Alexandre Magno - 04/11/2017
           If Query.Params[I].DataType = ftLargeint Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           else If Query.Params[I].DataType = ftSmallInt Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);

           // Como estava Anteriormente
           //If Query.Params[I].DataType = ftSmallInt Then
           //  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           //Else
           //  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
         End;
       End
      Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD] Then
       Begin
        If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
         Query.Params[I].AsFloat  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
       End
      Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
       Begin
        If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
         Query.Params[I].AsDateTime  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
        Else
         Query.Params[I].AsDateTime  := Null;
       End  //Tratar Blobs de Parametros...
      Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
         vStringStream.Position := 0;
         Query.Params[I].LoadFromStream(vStringStream, ftBlob);
        Finally
         FreeAndNil(vStringStream);
        End;
       End
      Else
       Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If (MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                     (MassiveDataset.AtualRec.MassiveMode = mmInsert) Then
                   Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                 Begin
                  If I = 0 Then
                   vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                  Else
                   vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
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
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   For I := 0 To Query.Params.Count -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
      Begin
       vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
       If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value = 'null' Then
        Begin
         If vFieldType = ftUnknown Then
          Query.Params[I].DataType := ftString
         Else
          Query.Params[I].DataType := vFieldType;
         Continue;
        End;
       If MassiveDataset.MassiveMode <> mmUpdate Then
        Begin
         If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                               ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                               ftString,    ftWideString, ftWideMemo]    Then
          Begin
           If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
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
           If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
            Begin
             If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
              Begin
               If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
                Begin
                 If Query.Params[I].DataType = ftLargeint Then
                  Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else If Query.Params[I].DataType = ftSmallInt Then
                  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else
                  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                End;
              End;
            End
           Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD] Then
            Begin
             If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
              Query.Params[I].AsFloat  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
             Else
              Query.Params[I].Clear;
            End
           Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
              Query.Params[I].AsDateTime  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
             Else
              Query.Params[I].Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
              vStringStream.Position := 0;
              If vStringStream.Size > 0 Then
               Query.Params[I].LoadFromStream(vStringStream, ftBlob)
              Else
               Query.Params[I].Clear;
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
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
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Try
   Result         := False;
   MassiveDataset.FromJSON(Massive);
   MassiveDataset.First;
   B             := 1;
   Result        := True;
   InTransaction := False;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If Not InTransaction Then
      Begin
       ATransaction.StartTransaction;
       InTransaction := True;
      End;
     Query.SQL.Clear;
     PrepareData(Query, MassiveDataset);
     Try
      Query.ExecSQL;
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
        Break;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
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
  Finally
   FreeAndNil(MassiveDataset);
   Query.SQL.Clear;
  End;
 End;
Begin
 Try
  Result     := Nil;
  Error      := False;
  vTempQuery := TSQLQuery.Create(Owner);
  If Assigned(vConnection) Then
   Begin
    ATransaction          := TSQLTransaction.Create(vTempQuery.DataBase);
    ATransaction.DataBase := TDatabase(vConnection);
    SetTransaction(ATransaction);
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Open;
    vTempQuery.DataBase := TDatabase(vConnection);
   End
  Else
   Begin
    FreeAndNil(vTempQuery);
    Exit;
   End;
  vTempQuery.SQL.Clear;
  If LoadMassive(Massive, vTempQuery) Then
   Begin
    If SQL <> '' Then
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
                                                     ftString,    ftWideString, ftWideMemo]    Then
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
                     If vTempQuery.Params[A].DataType = ftLargeint Then
                      vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsFloat  := StrToFloat(Params[I].Value)
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsDateTime  := StrToFloat(Params[I].Value)
                   Else
                    vTempQuery.Params[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   vStringStream := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(vStringStream);
                    vStringStream.Position := 0;
                    vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                   Finally
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
          Result.SetValue(GetPairJSON('NOK', MessageError));
          ATransaction.Rollback;
         Except
         End;
        End;
      End;
     End;
   End;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
  ATransaction.Free;
 End;
End;

Procedure TRESTDWLazDriver.ApplyUpdates_MassiveCache(MassiveCache     : String;
                                                     Var Error        : Boolean;
                                                     Var MessageError : String);
Var
 vTempQuery     : TSQLQuery;
 ATransaction   : TSQLTransaction;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 InTransaction  : Boolean;
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
 Function LoadMassive(Var Query : TSQLQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, X        : Integer;
  bJsonArray     : TJsonArray;
  Procedure PrepareData(Var Query      : TSQLQuery;
                        MassiveDataset : TMassiveDatasetBuffer);
  Var
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer;
   Var
    X : Integer;
   Begin
    If I = 0 Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString, ftWideMemo]    Then
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
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Begin
                // Alterado por: Alexandre Magno - 04/11/2017
                If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftLargeint Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);

                // Como estava Anteriormente
                //If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                //  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                //Else
                //  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(MassiveDataset.AtualRec.PrimaryValues[X].Value);
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := StrToFloat(MassiveDataset.AtualRec.PrimaryValues[X].Value)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := Null;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
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
    If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                          ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                          ftString,    ftWideString, ftWideMemo]    Then
     Begin
      If Query.Params[I].Size > 0 Then
       Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
      Else
       Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
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
      If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
       Begin
        If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
         Begin
           // Alterado por: Alexandre Magno - 04/11/2017
           If Query.Params[I].DataType = ftLargeint Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           else If Query.Params[I].DataType = ftSmallInt Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);

           // Como estava Anteriormente
           //If Query.Params[I].DataType = ftSmallInt Then
           //  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           //Else
           //  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
         End;
       End
      Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD] Then
       Begin
        If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
         Query.Params[I].AsFloat  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
       End
      Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
       Begin
        If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
         Query.Params[I].AsDateTime  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
        Else
         Query.Params[I].Clear;
       End  //Tratar Blobs de Parametros...
      Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
         vStringStream.Position := 0;
         Query.Params[I].LoadFromStream(vStringStream, ftBlob);
        Finally
         FreeAndNil(vStringStream);
        End;
       End
      Else
       Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If (MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                     (MassiveDataset.AtualRec.MassiveMode = mmInsert) Then
                   Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                 Begin
                  If I = 0 Then
                   vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                  Else
                   vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
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
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   For I := 0 To Query.Params.Count -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
      Begin
       vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
       If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value = 'null' Then
        Begin
         If vFieldType = ftUnknown Then
          Query.Params[I].DataType := ftString
         Else
          Query.Params[I].DataType := vFieldType;
         Continue;
        End;
       If MassiveDataset.MassiveMode <> mmUpdate Then
        Begin
         If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                               ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                               ftString,    ftWideString, ftWideMemo]    Then
          Begin
           If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
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
           If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
            Begin
             If Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '' Then
              Begin
               If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
                Begin
                 If Query.Params[I].DataType = ftLargeint Then
                  Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else If Query.Params[I].DataType = ftSmallInt Then
                  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else
                  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                End;
              End
             Else
              Query.Params[I].Clear;
            End
           Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD] Then
            Begin
             If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
              Query.Params[I].AsFloat  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
             Else
              Query.Params[I].Clear;
            End
           Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
              Query.Params[I].AsDateTime  := StrToFloat(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
             Else
              Query.Params[I].Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
              vStringStream.Position := 0;
              If vStringStream.Size > 0 Then
               Query.Params[I].LoadFromStream(vStringStream, ftBlob)
              Else
               Query.Params[I].Clear;
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
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
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  bJsonArray     := TJsonArray.Create(MassiveCache);
  Result         := False;
  InTransaction  := False;
  For x := 0 To bJsonArray.length -1 Do
   Begin
    If Not InTransaction Then
     Begin
      ATransaction.StartTransaction;
      InTransaction  := True;
     End;
    Try
     MassiveDataset.FromJSON(bJsonArray.get(X).toString);
     MassiveDataset.First;
     For A := 1 To MassiveDataset.RecordCount Do
      Begin
       Query.SQL.Clear;
       PrepareData(Query, MassiveDataset);
       Try
        Query.ExecSQL;
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
          Break;
         End;
       End;
       MassiveDataset.Next;
      End;
    Finally
     Query.SQL.Clear;
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
  FreeAndNil(MassiveDataset);
  FreeAndNil(bJsonArray);
 End;
Begin
 Try
  Error      := False;
  vTempQuery := TSQLQuery.Create(Owner);
  If Assigned(vConnection) Then
   Begin
    ATransaction          := TSQLTransaction.Create(vTempQuery.DataBase);
    ATransaction.DataBase := TDatabase(vConnection);
    SetTransaction(ATransaction);
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Open;
    vTempQuery.DataBase := TDatabase(vConnection);
   End
  Else
   Begin
    FreeAndNil(vTempQuery);
    Exit;
   End;
  vTempQuery.SQL.Clear;
  LoadMassive(vTempQuery);
 Finally
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
  FreeAndNil(ATransaction);
 End;
End;

function TRESTDWLazDriver.ExecuteCommand(SQL: String; Var Error: Boolean;
  Var MessageError: String; Execute: Boolean): TJSONValue;
Var
 vTempQuery   : TSQLQuery;
 ATransaction : TSQLTransaction;
Begin
 Result := Nil;
 Error  := False;
 vTempQuery               := TSQLQuery.Create(Nil);
 Try
  If Assigned(vConnection) Then
   Begin
    ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
    ATransaction.DataBase := TDatabase(vConnection);
    SetTransaction(ATransaction);
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Open;
    vTempQuery.DataBase     := TDatabase(vConnection);
   End
  Else
   Begin
    FreeAndNil(vTempQuery);
    Exit;
   End;
//  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
//  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
//  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Not Execute Then
   Begin
    vTempQuery.Open;
    Result         := TJSONValue.Create;
    Result.DatabaseCharSet := DatabaseCharSet;
    Try
     Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
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
     Result := TJSONValue.Create;
     Result.SetValue('COMMANDOK');
     ATransaction.Commit;
     Error         := False;
    Finally
    End;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result := TJSONValue.Create;
     Result.Encoded := True;
     Result.DatabaseCharSet := DatabaseCharSet;
     Result.SetValue(GetPairJSON('NOK', MessageError));
     ATransaction.Rollback;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

function TRESTDWLazDriver.GetConnection: TComponent;
Begin
 Result := vConnectionBack;
End;

function TRESTDWLazDriver.InsertMySQLReturnID(SQL: String; Params: TDWParams;
  Var Error: Boolean; Var MessageError: String): Integer;
Var
 vTempQuery   : TSQLQuery;
 ATransaction : TSQLTransaction;
 A, I          : Integer;
 vParamName    : String;
 vStringStream : TMemoryStream;
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
 vTempQuery               := TSQLQuery.Create(Nil);
 If Assigned(vConnection) Then
  Begin
   ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
   ATransaction.DataBase := TDatabase(vConnection);
   SetTransaction(ATransaction);
   If Not TDatabase(vConnection).Connected Then
    TDatabase(vConnection).Open;
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
              vTempQuery.Params[A].AsDateTime  := StrToFloat(Params[I].Value)
             Else
              vTempQuery.Params[A].AsDateTime  := Null;
            End
           Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              Params[I].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
             Finally
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
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result       := -1;
     ATransaction.Rollback;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

function TRESTDWLazDriver.InsertMySQLReturnID(SQL: String; Var Error: Boolean;
  Var MessageError: String): Integer;
Var
 vTempQuery   : TSQLQuery;
 ATransaction : TSQLTransaction;
Begin
 Result := -1;
 Error  := False;
 vTempQuery               := TSQLQuery.Create(Nil);
 If Assigned(vConnection) Then
  Begin
   ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
   ATransaction.DataBase := TDatabase(vConnection);
   SetTransaction(ATransaction);
   If Not TDatabase(vConnection).Connected Then
    TDatabase(vConnection).Open;
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
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result       := -1;
     ATransaction.Rollback;
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
