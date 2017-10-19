unit uRestDWDriverZEOS;

interface

uses SysUtils,  Classes, DB, DBTables, uDWConsts, uDWConstsData,
     uRestDWPoolerDB, uDWJSONObject, ZConnection, ZAbstractRODataset,
     ZAbstractDataset, ZDataset, ZStoredProcedure;

{$IFDEF MSWINDOWS}
Type
 TRESTDWDriverZEOS   = Class(TRESTDWDriver)
 Private
  vFDConnectionBack,
  vFDConnection                 : TZConnection;
  Procedure SetConnection(Value : TZConnection);
  Function  GetConnection       : TZConnection;
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
  Property Connection : TZConnection Read GetConnection Write SetConnection;
End;
{$ENDIF}

Procedure Register;

implementation

Uses uDWJSONTools;

{$IFDEF MSWINDOWS}
Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverZEOS]);
End;
{$ENDIF}

procedure TRESTDWDriverZEOS.ApplyChanges(TableName,
                                     SQL              : String;
                                     Var Error        : Boolean;
                                     Var MessageError : String;
                                     Const ADeltaList : TJSONValue);
begin
  Inherited;
end;

procedure TRESTDWDriverZEOS.ApplyChanges(TableName,
                                       SQL              : String;
                                       Params           : TDWParams;
                                       Var Error        : Boolean;
                                       Var MessageError : String;
                                       Const ADeltaList : TJSONValue);
begin
  Inherited;
end;

Procedure TRESTDWDriverZEOS.Close;
Begin
  Inherited;
 If Connection <> Nil Then
  Connection.Disconnect;
End;

function TRESTDWDriverZEOS.ExecuteCommand(SQL              : String;
                                        Params           : TDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean) : TJSONValue;
Var
 vTempQuery  : TZQuery;
 A, I        : Integer;
 vParamName  : String;
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
 Inherited;
 Result := Nil;
 Error  := False;
 vTempQuery               := TZQuery.Create(Owner);
 Try
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  vFDConnection.StartTransaction;
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
             vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
            Else If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord,
                                                      ftFloat,   ftCurrency, ftBCD] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               Begin
                If vTempQuery.Params[A].DataType = ftSmallInt Then
                 vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                Else
                 vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
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
     Result.LoadFromDataset('RESULTDATA', vTempQuery, False);
    Finally
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    vFDConnection.Commit;
   End;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.Rollback;
    Except
    End;
    Error := True;
    MessageError := E.Message;
    Result := TJSONValue.Create;
    Result.Encoded := True;
    Result.SetValue(GetPairJSON('NOK', MessageError));
   End;
 End;
 vTempQuery.Free;
End;

procedure TRESTDWDriverZEOS.ExecuteProcedure(ProcName         : String;
                                           Params           : TDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String);
Var
 A, I            : Integer;
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
 Inherited;
 Error  := False;
 vTempStoredProc                               := TZStoredProc.Create(Owner);
 Try
  vFDConnection.StartTransaction;
  vTempStoredProc.Connection                   := vFDConnection;
  vTempStoredProc.StoredProcName               := ProcName;
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
        A          := GetParamIndex(vTempStoredProc.Params, vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If vTempStoredProc.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
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
  vFDConnection.Commit;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.Rollback;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempStoredProc.Free;
End;

procedure TRESTDWDriverZEOS.ExecuteProcedurePure(ProcName         : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String);
Var
 vTempStoredProc : TZStoredProc;
Begin
 Inherited;
 Error                                         := False;
 vTempStoredProc                               := TZStoredProc.Create(Owner);
 Try
  If Not vFDConnection.Connected Then
   vFDConnection.Connected                     := True;
  vFDConnection.StartTransaction;
  vTempStoredProc.Connection                   := vFDConnection;
  vTempStoredProc.StoredProcName               := ProcName;
  vTempStoredProc.ExecProc;
  vFDConnection.Commit;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.Rollback;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempStoredProc.Free;
End;

Function TRESTDWDriverZEOS.ExecuteCommand(SQL              : String;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean) : TJSONValue;
Var
 vTempQuery   : TZQuery;
Begin
 Inherited;
 Result := Nil;
 Error  := False;
 vTempQuery               := TZQuery.Create(Owner);
 Try
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vFDConnection.StartTransaction; 
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Not Execute Then
   Begin
    vTempQuery.Open;
    Result         := TJSONValue.Create;
    Try
     Result.LoadFromDataset('RESULTDATA', vTempQuery, False);
     Error         := False;
    Finally
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    vFDConnection.Commit;
    Error         := False;
   End;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.Rollback;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempQuery.Free;
End;

Function TRESTDWDriverZEOS.GetConnection: TZConnection;
Begin
 Result := vFDConnectionBack;
End;

Function TRESTDWDriverZEOS.InsertMySQLReturnID(SQL              : String;
                                             Params           : TDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Begin
  Inherited;
End;

Function TRESTDWDriverZEOS.InsertMySQLReturnID(SQL              : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Begin
  Inherited;
End;

Procedure TRESTDWDriverZEOS.SetConnection(Value: TZConnection);
Begin
 vFDConnectionBack := Value;
 If Value <> Nil Then
  vFDConnection    := vFDConnectionBack
 Else
  Begin
   If vFDConnection <> Nil Then
    vFDConnection.Disconnect;
  End;
End;

end.
