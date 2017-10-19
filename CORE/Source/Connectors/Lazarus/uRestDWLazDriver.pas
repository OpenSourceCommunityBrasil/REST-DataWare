unit uRestDWLazDriver;

interface

uses SysUtils, Classes, DB, sqldb,       mssqlconn,    pqconnection,
     oracleconnection,  odbcconn,        mysql40conn,  mysql41conn,
     mysql50conn,       mysql51conn,     mysql55conn,  mysql56conn,
     mysql57conn,       sqlite3conn,     ibconnection, uDWConsts,
     uDWConstsData,     uRestDWPoolerDB, uDWJSONObject;

Type
 TRESTDWLazDriver   = Class(TRESTDWDriver)
 Private
  vConnectionBack,
  vConnection                   : TComponent;
  Procedure SetConnection(Value : TComponent);
  Function  GetConnection       : TComponent;
 Public
  Procedure ApplyChanges        (TableName,
                                 SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Const ADeltaList : TJSONValue);Overload;Override;
  Procedure ApplyChanges        (TableName,
                                 SQL              : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Const ADeltaList : TJSONValue);Overload;Override;
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

procedure TRESTDWLazDriver.ApplyChanges(TableName,
                                     SQL              : String;
                                     Var Error        : Boolean;
                                     Var MessageError : String;
                                     Const ADeltaList : TJSONValue);
begin
end;

procedure TRESTDWLazDriver.ApplyChanges(TableName,
                                       SQL              : String;
                                       Params           : TDWParams;
                                       Var Error        : Boolean;
                                       Var MessageError : String;
                                       Const ADeltaList : TJSONValue);
begin
end;

Procedure TRESTDWLazDriver.Close;
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
 vTempQuery   : TSQLQuery;
 ATransaction : TSQLTransaction;
 A, I         : Integer;
 vParamName   : String;
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
  vTempQuery.DataBase     := TDatabase(vConnection);
  If Assigned(vTempQuery.DataBase) Then
   Begin
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Open;
    ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
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
            If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord] Then
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
                If vTempQuery.Params[A].DataType      = ftDate Then
                 vTempQuery.Params[A].AsDate      := StrToDate(Params[I].Value)
                Else If vTempQuery.Params[A].DataType = ftTime Then
                 vTempQuery.Params[A].AsDateTime  := StrToTime(Params[I].Value)
                Else If vTempQuery.Params[A].DataType In [ftDateTime, ftTimeStamp] Then
                 vTempQuery.Params[A].AsDateTime  := StrToDateTime(Params[I].Value);
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
  If Not Execute Then
   Begin
    vTempQuery.Active := True;
    Result := TJSONValue.Create;
    Try
     Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
    Finally
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    Result := TJSONValue.Create;
    Result.SetValue('COMMANDOK');
    ATransaction.CommitRetaining;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result.Encoded := True;
     Result.SetValue(GetPairJSON('NOK', MessageError));
     ATransaction.RollbackRetaining;
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

Function TRESTDWLazDriver.ExecuteCommand(SQL              : String;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean) : TJSONValue;
Var
 vTempQuery   : TSQLQuery;
 ATransaction : TSQLTransaction;
Begin
 Result := Nil;
 Error  := False;
 vTempQuery               := TSQLQuery.Create(Nil);
 Try
  vTempQuery.DataBase     := TDatabase(vConnection);
  If Assigned(vTempQuery.DataBase) Then
   Begin
    If Not TDatabase(vConnection).Connected Then
     TDatabase(vConnection).Open;
    ATransaction := TSQLTransaction.Create(vTempQuery.DataBase);
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
    Try
     Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
     Error         := False;
    Finally
    End;
   End
  Else
   Begin
    try
      vTempQuery.ExecSQL;
      Result := TJSONValue.Create;
      Result.SetValue('COMMANDOK');
      ATransaction.CommitRetaining;
      Error         := False;
    finally
    end;

   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result := TJSONValue.Create;
     Result.Encoded := True;
     Result.SetValue(GetPairJSON('NOK', MessageError));
     ATransaction.RollbackRetaining;
    Except
    End;

   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
 FreeAndNil(ATransaction);
End;

Function TRESTDWLazDriver.GetConnection: TComponent;
Begin
 Result := vConnectionBack;
End;

Function TRESTDWLazDriver.InsertMySQLReturnID(SQL              : String;
                                             Params           : TDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Begin
End;

Function TRESTDWLazDriver.InsertMySQLReturnID(SQL              : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Begin
 Result := -1;
 Error  := False;
 Try
 Except
  On E : Exception do
   Begin
    Error        := True;
    MessageError := E.Message;
   End;
 End;
End;

Procedure TRESTDWLazDriver.SetConnection(Value : TComponent);
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
