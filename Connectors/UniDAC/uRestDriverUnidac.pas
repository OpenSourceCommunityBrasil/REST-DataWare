unit uRestDriverUnidac;

interface

uses System.SysUtils,          System.Classes,            MemDS,
     Data.DB,                  DBAccess,                  Uni,                       
     System.JSON,              Data.DBXJSONReflect,       FireDAC.Comp.Client,
     uPoolerMethod,            Data.DBXPlatform,          DbxCompressionFilter, 
   	 VirtualTable,             Vcl.StdCtrls,              uRestCompressTools,
   	 System.ZLib,              Soap.EncdDecd,             Data.FireDACJSONReflect,
   	 FireDAC.Stan.Intf,        uRestPoolerDB;

{$IFDEF MSWINDOWS}
Type
 TRESTDriverUnidac   = Class(TRESTDriver)
 Private
  vUniConnectionBack,
  vUniConnection                 : TUniConnection;
  Procedure SetConnection(Value : TUniConnection);
  Function  GetConnection       : TUniConnection;
  Procedure CloneData(Source : TUniQuery; Var Dest : TFDMemTable);
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
  Property Connection : TUniConnection Read GetConnection Write SetConnection;
End;
{$ENDIF}

Procedure Register;

implementation

{ TRESTDriver }

{$IFDEF MSWINDOWS}
Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers',     [TRESTDriverUnidac]);
End;
{$ENDIF}

Procedure TRESTDriverUnidac.CloneData(Source : TUniQuery; Var Dest : TFDMemTable);
Var
 I : Integer;
 vFieldType : TFieldType;
Begin
 Dest := TFDMemTable.Create(Nil);
 Dest.Close;
 Dest.FieldDefs.Clear;
 For I := 0 to Source.FieldDefs.Count -1 do
  Begin
   vFieldType := Source.FieldDefs[I].DataType;
   if vFieldType = ftWideString then
    vFieldType := ftString;
   if vFieldType = ftDateTime then
    vFieldType := ftTimeStamp;
   Dest.FieldDefs.Add(Source.FieldDefs[I].Name, vFieldType,
                      Source.FieldDefs[I].Size, Source.FieldDefs[I].Required);
  End;
 Dest.Open;
 Source.First;
 While Not Source.Eof Do
  Begin
   Dest.Insert;
   Dest.CopyRecord(Source);
   Dest.Post;
   Source.Next;
  End;
 Source.First;
End;


procedure TRESTDriverUnidac.ApplyChanges(TableName, SQL: String; var Error: Boolean;
  var MessageError: String; const ADeltaList: TFDJSONDeltas);
begin
  Inherited;
  Error        := True;
  MessageError := 'Method not implemented for the Unidac Driver.';
end;

procedure TRESTDriverUnidac.ApplyChanges(TableName, SQL: String; Params: TParams;
  var Error: Boolean; var MessageError: String;
  const ADeltaList: TFDJSONDeltas);
begin
  Inherited;
  Error        := True;
  MessageError := 'Method not implemented for the Unidac Driver.';
end;

Procedure TRESTDriverUnidac.Close;
Begin
  Inherited;
 If Connection <> Nil Then
  Connection.Close;
End;

function TRESTDriverUnidac.ExecuteCommand(SQL: String; Params: TParams;
  var Error: Boolean; var MessageError: String;
  Execute: Boolean): TFDJSONDataSets;
Var
 vTempQuery  : TUniQuery;
 A, I        : Integer;
 vTempWriter : TFDJSONDataSetsWriter;
 vParamName  : String;
 Original     : TStringStream;
 gZIPStream   : TMemoryStream;
 oString      : String;
 Len          : Integer;
 tempDataSets : TFDJSONDataSets;
 vTempMemT,
 MemTable     : TFDMemTable;
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
 vTempQuery               := TUniQuery.Create(Owner);
 Try
  vTempQuery.Connection   := vUniConnection;
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
        vParamName := Copy(StringReplace(Params[I].Name, ',', '', []), 1, Length(Params[I].Name));
        A          := GetParamIndex(vTempQuery.Params, vParamName);
        If A > -1 Then
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
   End;
  If Not Execute Then
   Begin
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
        CloneData(vTempQuery, vTempMemT);
        vTempMemT.SaveToStream(Original, sfJSON);
        vTempMemT.DisposeOf;
        //make it gzip
        doGZIP(Original, gZIPStream);
        MemTable.FieldDefs.Add('compress', ftBlob);
        MemTable.Active := True;
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
      Begin
        CloneData(vTempQuery, vTempMemT);
        vTempWriter.ListAdd(Result, vTempMemT);
	    End;
    Finally
     vTempWriter := Nil;
     vTempWriter.DisposeOf;
    End;
   End
  Else
   Begin
        if not vUniConnection.InTransaction then
           vUniConnection.StartTransaction;
    vTempQuery.ExecSQL;
    vUniConnection.Commit;//Retaining;
   End;
 Except
  On E : Exception do
   Begin
    Try
     vUniConnection.Rollback;//Retaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 GetInvocationMetaData.CloseSession := True;
End;

procedure TRESTDriverUnidac.ExecuteProcedure(ProcName: String; Params: TParams;
  var Error: Boolean; var MessageError: String);
Var
 A, I            : Integer;
 vParamName      : String;
 vTempStoredProc : TUniStoredProc;
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
 vTempStoredProc                               := TUniStoredProc.Create(Owner);
 Try
  vTempStoredProc.Connection                   := vUniConnection;
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
        If A > -1 Then
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
  if not vUniConnection.InTransaction then
  vUniConnection.StartTransaction;
  vTempStoredProc.ExecProc;
  vUniConnection.Commit;//Retaining;
 Except
  On E : Exception do
   Begin
    Try
     vUniConnection.Rollback;//Retaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 GetInvocationMetaData.CloseSession := True;
 vTempStoredProc.DisposeOf;
End;

procedure TRESTDriverUnidac.ExecuteProcedurePure(ProcName         : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Var
 vTempStoredProc : TUniStoredProc;
Begin
 Inherited;
 Error                                         := False;
 vTempStoredProc                               := TUniStoredProc.Create(Owner);
 Try
  If Not vUniConnection.Connected Then
   vUniConnection.Connected                     := True;
   vTempStoredProc.Connection                   := vUniConnection;
   vTempStoredProc.StoredProcName               := DecodeStrings(ProcName, GetEncoding(Encoding));

  if not vUniConnection.InTransaction then
  vUniConnection.StartTransaction;
   vTempStoredProc.ExecProc;
   vUniConnection.Commit;//Retaining;
 Except
  On E : Exception do
   Begin
    Try
     vUniConnection.Rollback;//Retaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempStoredProc.DisposeOf;
End;

function TRESTDriverUnidac.ExecuteCommand(SQL: String; var Error: Boolean;
  var MessageError: String; Execute: Boolean): TFDJSONDataSets;
Var
 vTempQuery   : TUniQuery;
 vTempWriter  : TFDJSONDataSetsWriter;
 Original,
 gZIPStream   : TMemoryStream;
 oString      : String;
 Len          : Integer;
 tempDataSets : TFDJSONDataSets;
 vTempMemT,
 MemTable     : TFDMemTable;
Begin
 Inherited;
 Result := Nil;
 Error  := False;
 vTempQuery               := TUniQuery.Create(Owner);
 Try
  if not vUniConnection.Connected then
  vUniConnection.Connected :=true;
  vTempQuery.Connection   := vUniConnection;
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
        CloneData(vTempQuery, vTempMemT);
        vTempMemT.SaveToStream(Original, sfJSON);
        vTempMemT.DisposeOf;
        doGZIP(Original, gZIPStream);
        MemTable.FieldDefs.Add('compress', ftBlob);
        MemTable.Active := True;
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
      Begin
       CloneData(vTempQuery, vTempMemT);
       vTempWriter.ListAdd(Result, vTempMemT);
      End;
    Finally
     vTempWriter := Nil;
     vTempWriter.DisposeOf;
    End;
   End
  Else
   Begin
        if not vUniConnection.InTransaction then
           vUniConnection.StartTransaction;
    vTempQuery.ExecSQL;
    vUniConnection.Commit;//Retaining;
   End;
 Except
  On E : Exception do
   Begin
    Try
     vUniConnection.Rollback;//Retaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
End;

Function TRESTDriverUnidac.GetConnection: TUniConnection;
Begin
 Result := vUniConnectionBack;
End;

Function TRESTDriverUnidac.InsertMySQLReturnID(SQL: String; Params: TParams;
  var Error: Boolean; var MessageError: String): Integer;
Var
 A, I        : Integer;
 vParamName  : String;
 fdCommand   : TUniQuery;
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
 Result := -1;
 Error  := False;
 fdCommand := TUniQuery.Create(Owner);
 Try
  fdCommand.Connection := vUniConnection;
  fdCommand.Sql.Clear;
  fdCommand.Sql.Add(DecodeStrings(SQL, GetEncoding(Encoding)) + '; SELECT LAST_INSERT_ID()ID');
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
  Result := StrToInt(fdCommand.FindField('ID').AsString);
  vUniConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    vUniConnection.RollbackRetaining;
    Error        := True;
    MessageError := E.Message;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 GetInvocationMetaData.CloseSession := True;
End;

Function TRESTDriverUnidac.InsertMySQLReturnID(SQL: String; var Error: Boolean;
                                         Var MessageError: String): Integer;
Var
 A, I        : Integer;
 fdCommand   : TUniQuery;
Begin
  Inherited;
 Result := -1;
 Error  := False;
 fdCommand := TUniQuery.Create(Owner);
 Try
  fdCommand.Connection := vUniConnection;
  fdCommand.Sql.Clear;
  fdCommand.Sql.Add(DecodeStrings(SQL, GetEncoding(Encoding)) + '; SELECT LAST_INSERT_ID()ID');
  fdCommand.Open;
  Result := StrToInt(fdCommand.FindField('ID').AsString);
  vUniConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    vUniConnection.RollbackRetaining;
    Error        := True;
    MessageError := E.Message;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 GetInvocationMetaData.CloseSession := True;
End;

Procedure TRESTDriverUnidac.SetConnection(Value: TUniConnection);
Begin
 vUniConnectionBack := Value;
 If Value <> Nil Then
  vUniConnection    := vUniConnectionBack
 Else
  Begin
   If vUniConnection <> Nil Then
    vUniConnection.Close;
  End;
End;

end.
