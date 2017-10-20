unit uRestDWDriverFD;

interface

uses System.SysUtils,          System.Classes,          Data.DBXJSON,
     FireDAC.Stan.Intf,        FireDAC.Stan.Option,     FireDAC.Stan.Param,
     FireDAC.Stan.Error,       FireDAC.DatS,            FireDAC.Stan.Async,
     FireDAC.DApt,             FireDAC.UI.Intf,         FireDAC.Stan.Def,
     FireDAC.Stan.Pool,        FireDAC.Comp.Client,     FireDAC.Comp.UI,
     FireDAC.Comp.DataSet,     FireDAC.DApt.Intf,       Data.DB,
     uDWConsts, uDWConstsData, uRestDWPoolerDB,         uDWJSONObject;

Type
 TRESTDWDriverFD   = Class(TRESTDWDriver)
 Private
  vFDConnectionBack,
  vFDConnection                 : TFDConnection;
  Procedure SetConnection(Value : TFDConnection);
  Function  GetConnection       : TFDConnection;
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
  Property Connection : TFDConnection Read GetConnection Write SetConnection;
End;



Procedure Register;

implementation

Uses uDWJSONTools;


Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverFD]);
End;



procedure TRESTDWDriverFD.ApplyChanges(TableName,
                                     SQL              : String;
                                     Var Error        : Boolean;
                                     Var MessageError : String;
                                     Const ADeltaList : TJSONValue);
begin
  Inherited;
end;

procedure TRESTDWDriverFD.ApplyChanges(TableName,
                                       SQL              : String;
                                       Params           : TDWParams;
                                       Var Error        : Boolean;
                                       Var MessageError : String;
                                       Const ADeltaList : TJSONValue);
begin
  Inherited;
end;

Procedure TRESTDWDriverFD.Close;
Begin
  Inherited;
 If Connection <> Nil Then
  Connection.Close;
End;

function TRESTDWDriverFD.ExecuteCommand(SQL              : String;
                                        Params           : TDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean) : TJSONValue;
Var
 vTempQuery    : TFDQuery;
 A, I          : Integer;
 vParamName    : String;
 vStringStream : TMemoryStream;
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
 Result := TJSONValue.Create;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Params <> Nil Then
   Begin
    Try
    // vTempQuery.Prepare;
    Except
    End;
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
            If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord] Then
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
  If Not Execute Then
   Begin
    vTempQuery.Active := True;
    If Result = Nil Then
     Result := TJSONValue.Create;
    Try
     Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
    Finally
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    If Result = Nil Then
     Result := TJSONValue.Create;
    Result.SetValue('COMMANDOK');
    vFDConnection.CommitRetaining;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     If Result = Nil Then
      Result := TJSONValue.Create;
     Result.Encoded := True;
     Result.SetValue(GetPairJSON('NOK', MessageError));
     vFDConnection.RollbackRetaining;
    Except
    End;
   End;
 End;
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
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.RollbackRetaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempStoredProc.DisposeOf;
End;

procedure TRESTDWDriverFD.ExecuteProcedurePure(ProcName         : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String);
Var
 vTempStoredProc : TFDStoredProc;
Begin
 Inherited;
 Error                                         := False;
 vTempStoredProc                               := TFDStoredProc.Create(Owner);
 Try
  If Not vFDConnection.Connected Then
   vFDConnection.Connected                     := True;
  vTempStoredProc.Connection                   := vFDConnection;
  vTempStoredProc.FormatOptions.StrsTrim       := StrsTrim;
  vTempStoredProc.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempStoredProc.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempStoredProc.StoredProcName               := ProcName;
  vTempStoredProc.ExecProc;
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.RollbackRetaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempStoredProc.DisposeOf;
End;

Function TRESTDWDriverFD.ExecuteCommand(SQL              : String;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean) : TJSONValue;
Var
 vTempQuery   : TFDQuery;
Begin
 Inherited;
 Result := Nil;
 Error  := False;
 //Result := TJSONValue.Create;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
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
      If Result = Nil Then
       Result := TJSONValue.Create;
      Result.SetValue('COMMANDOK');
      vFDConnection.CommitRetaining;
      Error         := False;
    finally
    end;

   End;
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
     vFDConnection.RollbackRetaining;
    Except
    End;

   End;
 End;
   {ico}
// Result.Free;
   {ico}
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverFD.GetConnection: TFDConnection;
Begin
 Result := vFDConnectionBack;
End;

Function TRESTDWDriverFD.InsertMySQLReturnID(SQL              : String;
                                             Params           : TDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 oTab        : TFDDatStable;
 A, I        : Integer;
 vParamName  : String;
 fdCommand   : TFDCommand;
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
 fdCommand := TFDCommand.Create(Owner);
 Try
  fdCommand.Connection := vFDConnection;
  fdCommand.CommandText.Clear;
  fdCommand.CommandText.Add(SQL + '; SELECT LAST_INSERT_ID()ID');
  If Params <> Nil Then
   Begin
    For I := 0 To Params.Count -1 Do
     Begin
      If fdCommand.Params.Count > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := GetParamIndex(fdCommand.Params, vParamName);
        If A > -1 Then
         fdCommand.Params[A].Value := Params[I].Value;
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
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    vFDConnection.RollbackRetaining;
    Error        := True;
    MessageError := E.Message;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 FreeAndNil(oTab);
End;

Function TRESTDWDriverFD.InsertMySQLReturnID(SQL              : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 oTab      : TFDDatStable;
 fdCommand : TFDCommand;
Begin
  Inherited;
 Result := -1;
 Error  := False;
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
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    vFDConnection.RollbackRetaining;
    Error        := True;
    MessageError := E.Message;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 FreeAndNil(oTab);
End;

Procedure TRESTDWDriverFD.SetConnection(Value: TFDConnection);
Begin
 vFDConnectionBack := Value;
 If Value <> Nil Then
  vFDConnection    := vFDConnectionBack
 Else
  Begin
   If vFDConnection <> Nil Then
    vFDConnection.Close;
  End;
End;

end.
