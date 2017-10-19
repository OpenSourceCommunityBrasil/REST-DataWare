unit uRestDriverFD;

interface

uses System.SysUtils,          System.Classes,          Data.DBXJSON,
     FireDAC.Stan.Intf,        FireDAC.Stan.Option,     FireDAC.Stan.Param,
     FireDAC.Stan.Error,       FireDAC.DatS,            FireDAC.Stan.Async,
     FireDAC.DApt,             FireDAC.UI.Intf,         FireDAC.Stan.Def,
     FireDAC.Stan.Pool,        FireDAC.Comp.Client,     FireDAC.Comp.UI,
     FireDAC.Comp.DataSet,     FireDAC.DApt.Intf,
     Data.DB,                  Data.FireDACJSONReflect, Data.DBXJSONReflect,
     uPoolerMethod,            Data.DBXPlatform,
     DbxCompressionFilter,     uRestCompressTools,
     System.ZLib, uRestPoolerDB
     {$if CompilerVersion >= 28}
     , System.JSON, FireDAC.Stan.StorageBin, FireDAC.Stan.StorageJSON, FireDAC.Phys.IBDef, Datasnap.DSProviderDataModuleAdapter
     {$ifend};

{$IFDEF MSWINDOWS}
Type
 TRESTDriverFD   = Class(TRESTDriver)
 Private
  vFDConnectionBack,
  vFDConnection                 : TFDConnection;
  Procedure SetConnection(Value : TFDConnection);
  Function  GetConnection       : TFDConnection;
 Public
  Procedure ApplyChanges(TableName,
                         SQL               : String;
                         Params            : TParams;
                         Var Error         : Boolean;
                         Var MessageError  : String;
                         Const ADeltaList  : TFDJSONDeltas);Overload;Override;
  Procedure ApplyChanges(TableName,
                         SQL               : String;
                         Var Error         : Boolean;
                         Var MessageError  : String;
                         Const ADeltaList  : TFDJSONDeltas);Overload;Override;
  Function ExecuteCommand(SQL        : String;
                          Var Error  : Boolean;
                          Var MessageError : String;
                          Execute    : Boolean = False) : TFDJSONDataSets;Overload;Override;
  Function ExecuteCommand(SQL              : String;
                          Params           : TParams;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Execute          : Boolean = False) : TFDJSONDataSets;Overload;Override;
  Function InsertMySQLReturnID(SQL              : String;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;Override;
  Function InsertMySQLReturnID(SQL              : String;
                               Params           : TParams;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;Override;
  Procedure ExecuteProcedure    (ProcName         : String;
                                 Params           : TParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Override;
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Override;
  Procedure Close;Override;
 Published
  Property Connection : TFDConnection Read GetConnection Write SetConnection;
End;
{$ENDIF}

Procedure Register;

implementation

{ TRESTDriver }

{$IFDEF MSWINDOWS}
Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers',     [TRESTDriverFD]);
End;
{$ENDIF}

procedure TRESTDriverFD.ApplyChanges(TableName, SQL: String; var Error: Boolean;
  var MessageError: String; const ADeltaList: TFDJSONDeltas);
Var
 vTempQuery   : TFDQuery;
 LApply       : IFDJSONDeltasApplyUpdates;
 vTempWriter  : TFDJSONDataSetsWriter;
 Original,
 gZIPStream   : TStringStream;
 oJsonObject  : TJSONObject;
 bDeltaList   : TFDJSONDeltas;
begin
  Inherited;
 Error                    := False;
 vTempQuery               := TFDQuery.Create(Owner);
 vTempQuery.CachedUpdates := True;
 Try
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(DecodeStrings(SQL, GetEncoding(Encoding)));
  vTempQuery.Active := True;
 Except
  On E : Exception do
   Begin
    Error := True;
    MessageError := E.Message;
    vTempQuery.DisposeOf;
    Exit;
   End;
 End;
 If Compression Then
  Begin
   oJsonObject  := TJSONObject.Create;
   Try
    TFDJSONInterceptor.DataSetsToJSONObject(ADeltaList, oJsonObject);
    TFDJSONInterceptor.JSONObjectToDataSets(oJsonObject, ADeltaList);
    LApply       := TFDJSONDeltasApplyUpdates.Create(ADeltaList);
    Original     := TStringStream.Create;
    gZIPStream   := TStringStream.Create;
    bDeltaList   := TFDJSONDeltas.Create;
    If LApply.Values[0].RecordCount > 0 Then
     Begin
      LApply.Values[0].First;
      (LApply.Values[0].Fields[0] as TBlobField).SaveToStream(Original);
      Original.Position := 0;
      doUnGZIP(Original, gZIPStream);
      gZIPStream.Position := 0;
      oJsonObject  := TJSONObject.ParseJSONValue(GetEncoding(Encoding).GetBytes(gZIPStream.DataString), 0) as TJSONObject;
      TFDJSONInterceptor.JSONObjectToDataSets(oJsonObject, bDeltaList);
     End;
   Finally
    Original.DisposeOf;
    gZIPStream.DisposeOf;
    oJsonObject.DisposeOf;
   End;
   LApply := TFDJSONDeltasApplyUpdates.Create(bDeltaList);
  End
 Else
  LApply := TFDJSONDeltasApplyUpdates.Create(ADeltaList);
 vTempQuery.UpdateOptions.UpdateTableName := TableName;
 Try
  LApply.ApplyUpdates(TableName,  vTempQuery.Command);
 Except

 End;
 If LApply.Errors.Count > 0 then
  Begin
   Error := True;
   MessageError := LApply.Errors.Strings.Text;
  End;
 If Not Error Then
  Begin
   Try
    Connection.CommitRetaining;
   Except
    On E : Exception do
     Begin
      Connection.RollbackRetaining;
      Error := True;
      MessageError := E.Message;
     End;
   End;
  End;
 vTempQuery.DisposeOf;
end;

procedure TRESTDriverFD.ApplyChanges(TableName, SQL: String; Params: TParams;
  var Error: Boolean; var MessageError: String;
  const ADeltaList: TFDJSONDeltas);
Var
 I            : Integer;
 vTempQuery   : TFDQuery;
 LApply       : IFDJSONDeltasApplyUpdates;
 vTempWriter  : TFDJSONDeltasWriter;
 oJsonObject  : TJSONObject;
 Original,
 gZIPStream   : TStringStream;
 bDeltaList   : TFDJSONDeltas;
begin
  Inherited;
 Error  := False;
 vTempQuery               := TFDQuery.Create(Owner);
 vTempQuery.CachedUpdates := True;
 Try
  vTempQuery.Connection                   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(DecodeStrings(SQL, GetEncoding(Encoding)));
  If Params <> Nil Then
   Begin
    Try
     vTempQuery.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If vTempQuery.ParamCount > I Then
       Begin
        If vTempQuery.ParamByName(Params[I].Name) <> Nil Then
         Begin
          If vTempQuery.ParamByName(Params[I].Name).DataType in [ftFixedChar, ftFixedWideChar,
                                                                 ftString,    ftWideString]    Then
           Begin
            If vTempQuery.ParamByName(Params[I].Name).Size > 0 Then
             vTempQuery.ParamByName(Params[I].Name).Value := Copy(Params[I].AsString, 1, vTempQuery.ParamByName(Params[I].Name).Size)
            Else
             vTempQuery.ParamByName(Params[I].Name).Value := Params[I].AsString;
           End
          Else
           Begin
            If vTempQuery.ParamByName(Params[I].Name).DataType in [ftUnknown] Then
             vTempQuery.ParamByName(Params[I].Name).DataType := Params[I].DataType;
            vTempQuery.ParamByName(Params[I].Name).Value    := Params[I].Value;
           End;
         End;
       End
      Else
       Break;
     End;
   End;
  vTempQuery.Active := True;
 Except
  On E : Exception do
   Begin
    Error := True;
    MessageError := E.Message;
    vTempQuery.DisposeOf;
    Exit;
   End;
 End;
 If Compression Then
  Begin
   oJsonObject  := TJSONObject.Create;
   Try
    TFDJSONInterceptor.DataSetsToJSONObject(ADeltaList, oJsonObject);
    TFDJSONInterceptor.JSONObjectToDataSets(oJsonObject, ADeltaList);
    LApply       := TFDJSONDeltasApplyUpdates.Create(ADeltaList);
    Original     := TStringStream.Create;
    gZIPStream   := TStringStream.Create;
    bDeltaList   := TFDJSONDeltas.Create;
    If LApply.Values[0].RecordCount > 0 Then
     Begin
      LApply.Values[0].First;
      (LApply.Values[0].Fields[0] as TBlobField).SaveToStream(Original);
      Original.Position := 0;
      doUnGZIP(Original, gZIPStream);
      gZIPStream.Position := 0;
      oJsonObject  := TJSONObject.ParseJSONValue(GetEncoding(Encoding).GetBytes(gZIPStream.DataString), 0) as TJSONObject;
      TFDJSONInterceptor.JSONObjectToDataSets(oJsonObject, bDeltaList);
     End;
   Finally
    Original.DisposeOf;
    gZIPStream.DisposeOf;
    oJsonObject.DisposeOf;
   End;
   LApply := TFDJSONDeltasApplyUpdates.Create(bDeltaList);
  End
 Else
  LApply := TFDJSONDeltasApplyUpdates.Create(ADeltaList);
 vTempQuery.UpdateOptions.UpdateTableName := TableName;
 Try
  LApply.ApplyUpdates(TableName,  vTempQuery.Command);
 Except
 End;
 If LApply.Errors.Count > 0 then
  Begin
   Error := True;
   MessageError := LApply.Errors.Strings.Text;
  End;
 Try
  Connection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    Connection.RollbackRetaining;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempQuery.DisposeOf;
end;

Procedure TRESTDriverFD.Close;
Begin
  Inherited;
 If Connection <> Nil Then
  Connection.Close;
End;

function TRESTDriverFD.ExecuteCommand(SQL: String; Params: TParams;
  var Error: Boolean; var MessageError: String;
  Execute: Boolean): TFDJSONDataSets;
Var
 vTempQuery  : TFDQuery;
 A, I        : Integer;
 vTempWriter : TFDJSONDataSetsWriter;
 vParamName  : String;
 Original     : TStringStream;
 gZIPStream   : TMemoryStream;
 oString      : String;
 Len          : Integer;
 tempDataSets : TFDJSONDataSets;
 MemTable     : TFDMemTable;
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
 Result := Nil;
 Error  := False;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.ResourceOptions.ParamCreate  := ParamCreate;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(DecodeStrings(SQL, GetEncoding(Encoding)));
  If Params <> Nil Then
   Begin
    if vTempQuery.ResourceOptions.ParamCreate then
    begin
      Try
//       vTempQuery.Params.Prepare(ftString, ptInput);
       vTempQuery.Prepare;
      Except
      End;
      For I := 0 To Params.Count -1 Do
       Begin
        If vTempQuery.ParamCount > I Then
         Begin
          vParamName := Copy(StringReplace(Params[I].Name, ',', '', []), 1, Length(Params[I].Name));
          A          := GetParamIndex(vTempQuery.Params, vParamName);
          If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
           Begin
            If vTempQuery.Params[A].DataType in [ftFixedChar, ftFixedWideChar,
                                                 ftString,    ftWideString]    Then
             Begin
              If vTempQuery.Params[A].Size > 0 Then
               vTempQuery.Params[A].Value := Copy(Params[I].AsString, 1, vTempQuery.Params[A].Size)
              Else
               vTempQuery.Params[A].Value := Params[I].AsString;
             End
            Else
             Begin
              If vTempQuery.Params[A].DataType in [ftUnknown] Then
               vTempQuery.Params[A].DataType := Params[I].DataType;
              vTempQuery.Params[A].Value    := Params[I].Value;
             End;
           End;
         End
        Else
         Break;
       End;
    end
    else
    begin
      For I := 0 To Params.Count -1 Do
      begin
        with vTempQuery.Params.Add do
        begin
          Name := Params[I].Name;
          DataType := Params[I].DataType;
          ParamType := Params[I].ParamType;
          Value := Params[I].Value;
        end;
      end;
    end;
   End;
  If Not Execute Then
   Begin
//    vTempQuery.Active := True;
    Result            := TFDJSONDataSets.Create;
    vTempWriter       := TFDJSONDataSetsWriter.Create(Result);
    Try
     If Compression Then
      Begin
       tempDataSets := TFDJSONDataSets.Create;
       MemTable     := TFDMemTable.Create(Nil);
       Original     := TStringStream.Create;
       gZIPStream   := TMemoryStream.Create;
       Try
        vTempQuery.Open;
        {$if CompilerVersion >= 28}
        vTempQuery.SaveToStream(Original, sfJSON);
        {$else}
        vTempQuery.SaveToStream(Original);
        {$ifend};
        //make it gzip
        doGZIP(Original, gZIPStream);
        MemTable.FieldDefs.Add('compress', ftBlob);
        MemTable.CreateDataSet;
        MemTable.Insert;
        TBlobField(MemTable.FieldByName('compress')).LoadFromStream(gZIPStream);
        MemTable.Post;
        vTempWriter.ListAdd(Result, MemTable);
       Finally
        Original.DisposeOf;
        gZIPStream.DisposeOf;
       End;
      End
     Else
      vTempWriter.ListAdd(Result, vTempQuery);
    Finally
     vTempWriter := Nil;
     vTempWriter.DisposeOf;
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    vFDConnection.CommitRetaining;
   End;
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
 GetInvocationMetaData.CloseSession := True;
End;

procedure TRESTDriverFD.ExecuteProcedure(ProcName: String; Params: TParams;
  var Error: Boolean; var MessageError: String);
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
        vParamName := Copy(StringReplace(Params[I].Name, ',', '', []), 1, Length(Params[I].Name));
        A          := GetParamIndex(vTempStoredProc.Params, vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If vTempStoredProc.Params[A].DataType in [ftFixedChar, ftFixedWideChar,
                                               ftString,    ftWideString]    Then
           Begin
            If vTempStoredProc.Params[A].Size > 0 Then
             vTempStoredProc.Params[A].Value := Copy(Params[I].AsString, 1, vTempStoredProc.Params[A].Size)
            Else
             vTempStoredProc.Params[A].Value := Params[I].AsString;
           End
          Else
           Begin
            If vTempStoredProc.Params[A].DataType in [ftUnknown] Then
             vTempStoredProc.Params[A].DataType := Params[I].DataType;
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
 GetInvocationMetaData.CloseSession := True;
 vTempStoredProc.DisposeOf;
End;

procedure TRESTDriverFD.ExecuteProcedurePure(ProcName         : String;
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
  vTempStoredProc.StoredProcName               := DecodeStrings(ProcName, GetEncoding(Encoding));
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

function TRESTDriverFD.ExecuteCommand(SQL: String; var Error: Boolean;
  var MessageError: String; Execute: Boolean): TFDJSONDataSets;
Var
 vTempQuery   : TFDQuery;
 vTempWriter  : TFDJSONDataSetsWriter;
 Original,
 gZIPStream   : TMemoryStream;
 oString      : String;
 Len          : Integer;
 tempDataSets : TFDJSONDataSets;
 MemTable     : TFDMemTable;
Begin
 Inherited;
 Result := Nil;
 Error  := False;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  if not vFDConnection.Connected then
  vFDConnection.Connected :=true;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(DecodeStrings(SQL, GetEncoding(Encoding)));
  If Not Execute Then
   Begin
    vTempQuery.Open;
    Result            := TFDJSONDataSets.Create;
    vTempWriter       := TFDJSONDataSetsWriter.Create(Result);
    Try
     If Compression Then
      Begin
       tempDataSets := TFDJSONDataSets.Create;
       MemTable     := TFDMemTable.Create(Nil);
       Original     := TStringStream.Create;
       gZIPStream   := TMemoryStream.Create;
       Try
        {$if CompilerVersion >= 28}
        vTempQuery.SaveToStream(Original, sfJSON);
        {$else}
        vTempQuery.SaveToStream(Original);
        {$ifend};
        //make it gzip
        doGZIP(Original, gZIPStream);
        MemTable.FieldDefs.Add('compress', ftBlob);
        MemTable.CreateDataSet;
        MemTable.Insert;
        TBlobField(MemTable.FieldByName('compress')).LoadFromStream(gZIPStream);
        MemTable.Post;
        vTempWriter.ListAdd(Result, MemTable);
       Finally
        Original.DisposeOf;
        gZIPStream.DisposeOf;
       End;
      End
     Else
      vTempWriter.ListAdd(Result, vTempQuery);
    Finally
     vTempWriter := Nil;
     vTempWriter.DisposeOf;
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    vFDConnection.CommitRetaining;
   End;
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
End;

Function TRESTDriverFD.GetConnection: TFDConnection;
Begin
 Result := vFDConnectionBack;
End;

Function TRESTDriverFD.InsertMySQLReturnID(SQL: String; Params: TParams;
  var Error: Boolean; var MessageError: String): Integer;
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
  fdCommand.CommandText.Add(DecodeStrings(SQL, GetEncoding(Encoding)) + '; SELECT LAST_INSERT_ID()ID');
  If Params <> Nil Then
   Begin
    For I := 0 To Params.Count -1 Do
     Begin
      If fdCommand.Params.Count > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].Name, ',', '', []), 1, Length(Params[I].Name));
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
 GetInvocationMetaData.CloseSession := True;
End;

Function TRESTDriverFD.InsertMySQLReturnID(SQL: String; var Error: Boolean;
                                         Var MessageError: String): Integer;
Var
 oTab        : TFDDatStable;
 A, I        : Integer;
 fdCommand   : TFDCommand;
Begin
  Inherited;
 Result := -1;
 Error  := False;
 fdCommand := TFDCommand.Create(Owner);
 Try
  fdCommand.Connection := vFDConnection;
  fdCommand.CommandText.Clear;
  fdCommand.CommandText.Add(DecodeStrings(SQL, GetEncoding(Encoding)) + '; SELECT LAST_INSERT_ID()ID');
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
 GetInvocationMetaData.CloseSession := True;
End;

Procedure TRESTDriverFD.SetConnection(Value: TFDConnection);
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
