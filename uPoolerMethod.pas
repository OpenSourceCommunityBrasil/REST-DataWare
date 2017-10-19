unit uPoolerMethod;

Interface

Uses Datasnap.DSProxyRest,  Datasnap.DSClientRest,   Data.DBXCommon,
     Data.DBXClient,          Data.DBXDataSnap,      Data.DBXJSON, Datasnap.DSProxy, System.Classes,
     System.SysUtils,         Data.DB, Data.SqlExpr, Data.DBXDBReaders,              Data.DBXCDSReaders,
     Data.FireDACJSONReflect, Data.DBXJSONReflect,   FireDAC.Stan.Param,             Soap.EncdDecd,
      uRestCompressTools,    System.ZLib,  REST.JSON,           IdGlobal
     {$if CompilerVersion >= 28}
       , System.JSON, System.NetEncoding
     {$ifend};

Const
 ZCompressionLevel  = zcDefault; //zcMax; //zcFastest; //zcDefault;

 Type
  IDSRestCachedTStringList     = Interface;
  TSMPoolerMethodClient        = Class(TDSAdminRestClient)
  Private
   vCompression                : Boolean;
   vEncoding                   : TEncoding;
   FEchoPoolerCommand,
   FPoolersDataSetCommand,
   FPoolersDataSetCommand_Cache,
   FEchoStringCommand,
   FInsertValueCommand,
   FExecuteCommandCommand,
   FExecuteCommandJSONCommand,
   FInsertValueCommandPure,
   FExecuteCommandPureCommand,
   FExecuteCommandPureJSONCommand,
   FApplyChangesPureCommand,
   FApplyChangesCommand,
   FGetPoolerListCommand,
   FGetPoolerListCommand_Cache,
   FExecuteProcedureCommand,
   FExecuteProcedurePureCommand  : TDSRestCommand;
   Function DecompressJSON(Value : String) : TJSONObject;

  Public
   Property Compression                 : Boolean   Read vCompression Write vCompression;
   Property Encoding                    : TEncoding Read vEncoding    Write vEncoding;

   Constructor Create(ARestConnection: TDSRestConnection); Overload;
   Constructor Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean); Overload;
   Destructor  Destroy; override;
   //Faz uma chamada de Execução para verificar o funcionamento do WebService
   Function    EchoPooler(Value, Method_Prefix : String;
                          Const ARequestFilter : String = '';
                          TimeOut              : Integer = 3000;
                          UserName             : String  = '';
                          Password             : String  = '')     : String;
   //Retorna todos os Poolers no DataModule do WebService
   Function    PoolersDataSet(Method_Prefix        : String;
                              Const ARequestFilter : String = '';
                              TimeOut              : Integer = 3000;
                              UserName             : String  = '';
                              Password             : String  = '') : TStringList;
   //Roda Comando SQL
   Function    InsertValue       (Pooler,
                                  Method_Prefix,
                                  SQL                  : String;
                                  Params               : TParams;
                                  Var Error            : Boolean;
                                  Var MessageError     : String;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = ''): Integer;
   Function    ExecuteCommand    (Pooler,
                                  Method_Prefix,
                                  SQL                  : String;
                                  Params               : TParams;
                                  Var Error            : Boolean;
                                  Var MessageError     : String;
                                  Execute              : Boolean;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '') : TFDJSONDataSets;
   Function    ExecuteCommandJSON(Pooler,
                                  Method_Prefix,
                                  SQL                  : String;
                                  Params               : TParams;
                                  Var Error            : Boolean;
                                  Var MessageError     : String;
                                  Execute              : Boolean;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '') : TJSONObject;
   Function    InsertValuePure   (Pooler,
                                  Method_Prefix,
                                  SQL                  : String;
                                  Var Error            : Boolean;
                                  Var MessageError     : String;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '') : Integer;
   Function    ExecuteCommandPure(Pooler,
                                  Method_Prefix,
                                  SQL                  : String;
                                  Var Error            : Boolean;
                                  Var MessageError     : String;
                                  Execute              : Boolean;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '') : TFDJSONDataSets;
   Function    ExecuteCommandPureJSON(Pooler,
                                      Method_Prefix,
                                      SQL                  : String;
                                      Var Error: Boolean;
                                      Var MessageError     : String;
                                      Execute: Boolean;
                                      Const ARequestFilter : String = '';
                                      TimeOut              : Integer = 3000;
                                      UserName             : String  = '';
                                      Password             : String  = ''): TJSONObject;
   //Executa um ApplyUpdate no Servidor
   Procedure   ApplyChangesPure  (Pooler,
                                  Method_Prefix,
                                  TableName,
                                  SQL                  : String;
                                  ADeltaList           : TFDJSONDeltas;
                                  Var Error            : Boolean;
                                  Var MessageError     : String;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '');
   Procedure   ApplyChanges      (Pooler,
                                  Method_Prefix,
                                  TableName,
                                  SQL                  : String;
                                  Params               : TParams;
                                  ADeltaList           : TFDJSONDeltas;
                                  Var Error            : Boolean;
                                  Var MessageError     : String;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '');
   //Lista todos os Pooler's do Servidor
   Procedure GetPoolerList       (Method_Prefix        : String;
                                  Var PoolerList       : TStringList;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '');
   Procedure GetPoolerList_Cache (Method_Prefix        : String;
                                  PoolerList : TStringList;
                                  Out PoolerList_Cache : IDSRestCachedTStringList;
                                  Const ARequestFilter : String = '';
                                  TimeOut              : Integer = 3000;
                                  UserName             : String  = '';
                                  Password             : String  = '');
   //StoredProc
   Procedure  ExecuteProcedure    (Pooler,
                                   Method_Prefix,
                                   ProcName             : String;
                                   Params               : TParams;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Const ARequestFilter : String = '');
   Procedure  ExecuteProcedurePure(Pooler,
                                   Method_Prefix,
                                   ProcName             : String;
                                   Var Error            : Boolean;
                                   Var MessageError     : String;
                                   Const ARequestFilter : String = '');

 End;
  IDSRestCachedTStringList = Interface(IDSRestCachedObject<TStringList>)
 End;
  TDSRestCachedTStringList = Class(TDSRestCachedObject<TStringList>, IDSRestCachedTStringList, IDSRestCachedCommand)
 End;

Const
  TSMPoolerMethodClient_EchoPooler: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'Value'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'string')
  );

  TSMPoolerMethodClient_PoolersDataSet: array [0..0] of TDSRestParameterMetaData =
  (
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TStringList')
  );

  TSMPoolerMethodClient_ExecuteCommand: array [0..6] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Params'; Direction: 1; DBXType: 23; TypeName: 'TParams'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string'),
    (Name: 'Execute'; Direction: 1; DBXType: 4; TypeName: 'Boolean'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TFDJSONDataSets')
  );

  TSMPoolerMethodClient_ExecuteCommandJSON: array [0..6] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Params'; Direction: 1; DBXType: 23; TypeName: 'TParams'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string'),
    (Name: 'Execute'; Direction: 1; DBXType: 4; TypeName: 'Boolean'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TJSONObject')
  );

  TSMPoolerMethodClient_ExecuteCommandPure: array [0..5] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string'),
    (Name: 'Execute'; Direction: 1; DBXType: 4; TypeName: 'Boolean'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TFDJSONDataSets')
  );

  TSMPoolerMethodClient_ExecuteCommandPureJSON: array [0..5] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string'),
    (Name: 'Execute'; Direction: 1; DBXType: 4; TypeName: 'Boolean'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TJSONObject')
  );

  TSMPoolerMethodClient_ApplyChangesPure: array [0..5] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'TableName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'ADeltaList'; Direction: 1; DBXType: 37; TypeName: 'TFDJSONDeltas'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string')
  );

  TSMPoolerMethodClient_ApplyChanges: array [0..6] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'TableName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Params'; Direction: 1; DBXType: 23; TypeName: 'TParams'),
    (Name: 'ADeltaList'; Direction: 1; DBXType: 37; TypeName: 'TFDJSONDeltas'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string')
  );

  TSMPoolerMethodClient_InsertValuePure: array [0..4] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 6; TypeName: 'Integer')
  );

  TSMPoolerMethodClient_InsertValue: array [0..5] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'SQL'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Params'; Direction: 1; DBXType: 23; TypeName: 'TParams'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 6; TypeName: 'Integer')
  );
  TSMPoolerMethodClient_GetPoolerList: array [0..0] of TDSRestParameterMetaData =
  (
    (Name: 'PoolerList'; Direction: 3; DBXType: 37; TypeName: 'TStringList')
  );

  TSMPoolerMethodClient_GetPoolerList_Cache: array [0..0] of TDSRestParameterMetaData =
  (
    (Name: 'PoolerList'; Direction: 2; DBXType: 26; TypeName: 'String')
  );
  TSMPoolerMethodClient_ExecuteProcedure: array [0..4] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'ProcName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Params'; Direction: 1; DBXType: 23; TypeName: 'TParams'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string')
  );

  TSMPoolerMethodClient_ExecuteProcedurePure: array [0..3] of TDSRestParameterMetaData =
  (
    (Name: 'Pooler'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'ProcName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'Error'; Direction: 3; DBXType: 4; TypeName: 'Boolean'),
    (Name: 'MessageError'; Direction: 3; DBXType: 26; TypeName: 'string')
  );


Var
 CompressionEncoding,
 CompressionDecoding : TEncoding;

implementation

Function ZCompressStr(const s: String; level: TZCompressionLevel = zcMax) : tIdBytes;
Var
 Compress   : TzCompressionStream;
 SrcStream,
 OutPut     : TStringStream;
Begin
 OutPut             := TStringStream.Create('', CompressionDecoding);
 SrcStream          := TStringStream.Create(s,  CompressionEncoding);
 OutPut.Position    := 0;
 Try
  Compress            := TzCompressionStream.Create(OutPut);
  Compress.CopyFrom(SrcStream, 0);
  FreeAndNil(Compress);
  OutPut.Position := 0;
  If OutPut.Size > 0 Then
   ReadTIdBytesFromStream(OutPut, Result, OutPut.Size);
//  Result          := OutPut.DataString;
  FreeAndNil(OutPut);
  FreeAndNil(SrcStream);
 Except
  SetLength(Result, 0);
 End;
End;

Function ZDecompressStr(Const S : String; Var Value : String) : Boolean;
Var
 zipFile : TZDecompressionStream;
 strInput,
 strOutput: TStringStream;
Begin
 Result := False;
 Value := '';
 If S <> '' Then
  Begin
    strInput          := TStringStream.Create(S, CompressionDecoding);
    strOutput         := TStringStream.Create('', CompressionEncoding);
    strInput.Position := 0;
    zipFile := TZDecompressionStream.Create(strInput, 31);
   Try
    Try
     zipFile.Position := 0;
     strOutput.CopyFrom(zipFile, zipFile.Size);
     strOutput.Position := 0;
     Value := strOutput.DataString;
     Result := True;
    Except
    End;
    zipFile.Free;
   Finally
    strInput.Free;
    strOutput.Free;
   End;
  End;
End;

Function EncodeStrings(Value : String;Encoding:TEncoding) : String;
Var
 Input,
 Output : TStringStream;
Begin
 Input := TStringStream.Create(Value,Encoding);
 Try
  Input.Position := 0;
  Output := TStringStream.Create('', Encoding);
  Try
   Soap.EncdDecd.EncodeStream(Input, Output);
   Result := Output.DataString;
  Finally
   Output.Free;
  End;
 Finally
  Input.Free;
 End;
End;

Function DecodeStrings(Value : String;Encoding:TEncoding) : String;
Var
 Input,
 Output : TStringStream;
Begin
 If Length(Value) > 0 Then
  Begin
   Input := TStringStream.Create(Value, Encoding);
   Try
    Output := TStringStream.Create('', Encoding);
    Try
     Soap.EncdDecd.DecodeStream(Input, Output);
     Output.Position := 0;
     Try
      Result := Output.DataString;
     Except
      Raise;
     End;
    Finally
     Output.Free;
    End;
   Finally
    Input.Free;
   End;
  End;
End;

procedure TSMPoolerMethodClient.ExecuteProcedure(Pooler,
                                                 Method_Prefix,
                                                 ProcName             : String;
                                                 Params               : TParams;
                                                 Var Error            : Boolean;
                                                 Var MessageError     : String;
                                                 Const ARequestFilter : String);
Begin
 If FExecuteProcedureCommand = Nil Then
  Begin
   FExecuteProcedureCommand             := FConnection.CreateCommand;
   FExecuteProcedureCommand.RequestType := 'POST';
   FExecuteProcedureCommand.Text        := Method_Prefix + '."ExecuteProcedure"';
   FExecuteProcedureCommand.Prepare(TSMPoolerMethodClient_ExecuteProcedure);
  End;
 FExecuteProcedureCommand.Parameters[0].Value.SetWideString(Pooler);
 FExecuteProcedureCommand.Parameters[1].Value.SetWideString(EncodeStrings(ProcName, vEncoding));
 FExecuteProcedureCommand.Parameters[2].Value.SetDBXReader (TDBXParamsReader.Create(Params, FInstanceOwner), True);
 FExecuteProcedureCommand.Parameters[3].Value.SetBoolean   (Error);
 FExecuteProcedureCommand.Parameters[4].Value.SetWideString(MessageError);
 FExecuteProcedureCommand.Execute                          (ARequestFilter);
 Error        := FExecuteProcedureCommand.Parameters[3].Value.GetBoolean;
 MessageError := FExecuteProcedureCommand.Parameters[4].Value.GetWideString;
end;

Procedure TSMPoolerMethodClient.ExecuteProcedurePure(Pooler,
                                                     Method_Prefix,
                                                     ProcName             : String;
                                                     Var   Error          : Boolean;
                                                     Var   MessageError   : String;
                                                     Const ARequestFilter : String);
begin
 If FExecuteProcedurePureCommand = Nil Then
  Begin
   FExecuteProcedurePureCommand             := FConnection.CreateCommand;
   FExecuteProcedurePureCommand.RequestType := 'GET';
   FExecuteProcedurePureCommand.Text        := Method_Prefix + '.ExecuteCommandPure';
   FExecuteProcedurePureCommand.Prepare(TSMPoolerMethodClient_ExecuteProcedurePure);
  End;
 FExecuteProcedurePureCommand.Parameters[0].Value.SetWideString(Pooler);
 FExecuteProcedurePureCommand.Parameters[1].Value.SetWideString(EncodeStrings(ProcName, vEncoding));
 FExecuteProcedurePureCommand.Parameters[2].Value.SetBoolean   (Error);
 FExecuteProcedurePureCommand.Parameters[3].Value.SetWideString(MessageError);
 FExecuteProcedurePureCommand.Execute                          (ARequestFilter);
 Error        := FExecuteProcedurePureCommand.Parameters[2].Value.GetBoolean;
 MessageError := FExecuteProcedurePureCommand.Parameters[3].Value.GetWideString;
End;

Procedure TSMPoolerMethodClient.ApplyChangesPure(Pooler,
                                                 Method_Prefix,
                                                 TableName,
                                                 SQL                  : String;
                                                 ADeltaList           : TFDJSONDeltas;
                                                 Var Error            : Boolean;
                                                 Var MessageError     : String;
                                                 Const ARequestFilter : String = '';
                                                 TimeOut              : Integer = 3000;
                                                 UserName             : String  = '';
                                                 Password             : String  = '');
Begin
 If FApplyChangesPureCommand = Nil Then
  Begin
   FApplyChangesPureCommand := FConnection.CreateCommand;
   FApplyChangesPureCommand.RequestType := 'POST';
   FApplyChangesPureCommand.Text := Method_Prefix + '."ApplyChangesPure"';
   FApplyChangesPureCommand.Prepare(TSMPoolerMethodClient_ApplyChangesPure);
  End;
 {$if CompilerVersion >= 28}
  FApplyChangesPureCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FApplyChangesPureCommand.Connection.UserName                 := UserName;
 FApplyChangesPureCommand.Connection.Password                 := Password;
 FApplyChangesPureCommand.Connection.LoginProperties.UserName := UserName;
 FApplyChangesPureCommand.Connection.LoginProperties.Password := Password;
 FApplyChangesPureCommand.Parameters[0].Value.SetWideString(Pooler);
 FApplyChangesPureCommand.Parameters[1].Value.SetWideString(TableName);
 FApplyChangesPureCommand.Parameters[2].Value.SetWideString(EncodeStrings(SQL, vEncoding));
 If Not Assigned(ADeltaList) Then
  FApplyChangesPureCommand.Parameters[3].Value.SetNull
 Else
  Begin
   FMarshal := TDSRestCommand(FApplyChangesPureCommand.Parameters[3].ConnectionHandler).GetJSONMarshaler;
   Try
    FApplyChangesPureCommand.Parameters[3].Value.SetJSONValue(FMarshal.Marshal(ADeltaList), True);
    If FInstanceOwner Then
     ADeltaList.Free;
   Finally
    FreeAndNil(FMarshal);
   End;
  End;
 FApplyChangesPureCommand.Parameters[4].Value.SetBoolean(Error);
 FApplyChangesPureCommand.Parameters[5].Value.SetWideString(MessageError);
 FApplyChangesPureCommand.Execute(ARequestFilter);
 Error := FApplyChangesPureCommand.Parameters[4].Value.GetBoolean;
 MessageError := FApplyChangesPureCommand.Parameters[5].Value.GetWideString;
End;

Procedure TSMPoolerMethodClient.GetPoolerList_Cache(Method_Prefix        : String;
                                                    PoolerList           : TStringList;
                                                    Out PoolerList_Cache : IDSRestCachedTStringList;
                                                    Const ARequestFilter : String = '';
                                                    TimeOut              : Integer = 3000;
                                                    UserName             : String  = '';
                                                    Password             : String  = '');
Begin
 If FGetPoolerListCommand_Cache = Nil Then
  Begin
   FGetPoolerListCommand_Cache := FConnection.CreateCommand;
   FGetPoolerListCommand_Cache.RequestType := 'POST';
   FGetPoolerListCommand_Cache.Text := Method_Prefix + '."GetPoolerList"';
   FGetPoolerListCommand_Cache.Prepare(TSMPoolerMethodClient_GetPoolerList_Cache);
  End;
 {$if CompilerVersion >= 28}
  FGetPoolerListCommand_Cache.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FGetPoolerListCommand_Cache.Connection.UserName            := UserName;
 FGetPoolerListCommand_Cache.Connection.Password            := Password;
 If Not Assigned(PoolerList) Then
  FGetPoolerListCommand_Cache.Parameters[0].Value.SetNull
 Else
  Begin
   FMarshal := TDSRestCommand(FGetPoolerListCommand_Cache.Parameters[0].ConnectionHandler).GetJSONMarshaler;
   Try
    FGetPoolerListCommand_Cache.Parameters[0].Value.SetJSONValue(FMarshal.Marshal(PoolerList), True);
    If FInstanceOwner Then
     PoolerList.Free;
   Finally
    FreeAndNil(FMarshal);
   End;
  End;
 FGetPoolerListCommand_Cache.ExecuteCache(ARequestFilter);
 PoolerList_Cache := TDSRestCachedTStringList.Create(FGetPoolerListCommand_Cache.Parameters[0].Value.GetString);
End;

Procedure TSMPoolerMethodClient.GetPoolerList(Method_Prefix        : String;
                                              Var PoolerList       : TStringList;
                                              Const ARequestFilter : String = '';
                                              TimeOut              : Integer = 3000;
                                              UserName             : String  = '';
                                              Password             : String  = '');
Begin
 If FGetPoolerListCommand = Nil Then
  Begin
   FGetPoolerListCommand := FConnection.CreateCommand;
   FGetPoolerListCommand.RequestType := 'POST';
   FGetPoolerListCommand.Text := Method_Prefix + '."GetPoolerList"';
   FGetPoolerListCommand.Prepare(TSMPoolerMethodClient_GetPoolerList);
  End;
 {$if CompilerVersion >= 28}
  FGetPoolerListCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FGetPoolerListCommand.Connection.UserName                 := UserName;
 FGetPoolerListCommand.Connection.Password                 := Password;
 FGetPoolerListCommand.Connection.LoginProperties.UserName := UserName;
 FGetPoolerListCommand.Connection.LoginProperties.Password := Password;
 If Not Assigned(PoolerList) Then
  FGetPoolerListCommand.Parameters[0].Value.SetNull
 Else
  Begin
   FMarshal := TDSRestCommand(FGetPoolerListCommand.Parameters[0].ConnectionHandler).GetJSONMarshaler;
   Try
    FGetPoolerListCommand.Parameters[0].Value.SetJSONValue(FMarshal.Marshal(PoolerList), True);
    If FInstanceOwner Then
     PoolerList.Free
   Finally
    FreeAndNil(FMarshal)
   End;
  End;
  FGetPoolerListCommand.Execute(ARequestFilter);
  If Not FGetPoolerListCommand.Parameters[0].Value.IsNull Then
   Begin
    FUnMarshal := TDSRestCommand(FGetPoolerListCommand.Parameters[0].ConnectionHandler).GetJSONUnMarshaler;
    Try
     PoolerList := TStringList(FUnMarshal.UnMarshal(FGetPoolerListCommand.Parameters[0].Value.GetJSONValue(True)));
     If FInstanceOwner Then
      FGetPoolerListCommand.FreeOnExecute(PoolerList);
    Finally
     FreeAndNil(FUnMarshal)
    End;
   End
  Else
   PoolerList := nil;
End;

Procedure TSMPoolerMethodClient.ApplyChanges(Pooler,
                                             Method_Prefix,
                                             TableName,
                                             SQL                  : String;
                                             Params               : TParams;
                                             ADeltaList           : TFDJSONDeltas;
                                             Var Error            : Boolean;
                                             Var MessageError     : String;
                                             Const ARequestFilter : String = '';
                                             TimeOut              : Integer = 3000;
                                             UserName             : String  = '';
                                             Password             : String  = '');
Begin
 If FApplyChangesCommand = Nil Then
  Begin
   FApplyChangesCommand := FConnection.CreateCommand;
   FApplyChangesCommand.RequestType := 'POST';
   FApplyChangesCommand.Text := Method_Prefix + '."ApplyChanges"';
   FApplyChangesCommand.Prepare(TSMPoolerMethodClient_ApplyChanges);
  End;
 {$if CompilerVersion >= 28}
  FApplyChangesCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FApplyChangesCommand.Connection.UserName                 := UserName;
 FApplyChangesCommand.Connection.Password                 := Password;
 FApplyChangesCommand.Connection.LoginProperties.UserName := UserName;
 FApplyChangesCommand.Connection.LoginProperties.Password := Password;
 FApplyChangesCommand.Parameters[0].Value.SetWideString(Pooler);
 FApplyChangesCommand.Parameters[1].Value.SetWideString(TableName);
 FApplyChangesCommand.Parameters[2].Value.SetWideString(EncodeStrings(SQL, vEncoding));
 FApplyChangesCommand.Parameters[3].Value.SetDBXReader(TDBXParamsReader.Create(TParams(Params), FInstanceOwner), True);
 If Not Assigned(ADeltaList) Then
  FApplyChangesCommand.Parameters[4].Value.SetNull
 Else
  Begin
   FMarshal := TDSRestCommand(FApplyChangesCommand.Parameters[4].ConnectionHandler).GetJSONMarshaler;
   Try
    FApplyChangesCommand.Parameters[4].Value.SetJSONValue(FMarshal.Marshal(ADeltaList), True);
    If FInstanceOwner Then
     ADeltaList.Free;
   Finally
    FreeAndNil(FMarshal);
   End
  End;
 FApplyChangesCommand.Parameters[5].Value.SetBoolean(Error);
 FApplyChangesCommand.Parameters[6].Value.SetWideString(MessageError);
 FApplyChangesCommand.Execute(ARequestFilter);
 Error        := FApplyChangesCommand.Parameters[5].Value.GetBoolean;
 MessageError := FApplyChangesCommand.Parameters[6].Value.GetWideString;
end;

Function TSMPoolerMethodClient.ExecuteCommandPureJSON(Pooler,
                                                      Method_Prefix,
                                                      SQL                  : String;
                                                      Var Error            : Boolean;
                                                      Var MessageError     : String;
                                                      Execute              : Boolean;
                                                      Const ARequestFilter : String = '';
                                                      TimeOut              : Integer = 3000;
                                                      UserName             : String  = '';
                                                      Password             : String  = ''): TJSONObject;
Begin
 If FExecuteCommandPureJSONCommand = Nil Then
  Begin
   FExecuteCommandPureJSONCommand := FConnection.CreateCommand;
   FExecuteCommandPureJSONCommand.RequestType := 'GET';
   FExecuteCommandPureJSONCommand.Text := Method_Prefix + '.ExecuteCommandPureJSON';
   FExecuteCommandPureJSONCommand.Prepare(TSMPoolerMethodClient_ExecuteCommandPureJSON);
  End;
 {$if CompilerVersion >= 28}
  FExecuteCommandPureJSONCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FExecuteCommandPureJSONCommand.Connection.UserName                 := UserName;
 FExecuteCommandPureJSONCommand.Connection.Password                 := Password;
 FExecuteCommandPureJSONCommand.Connection.LoginProperties.UserName := UserName;
 FExecuteCommandPureJSONCommand.Connection.LoginProperties.Password := Password;
 FExecuteCommandPureJSONCommand.Parameters[0].Value.SetWideString(Pooler);
 FExecuteCommandPureJSONCommand.Parameters[1].Value.SetWideString(EncodeStrings(SQL,self.vEncoding));
 FExecuteCommandPureJSONCommand.Parameters[2].Value.SetBoolean(Error);
 FExecuteCommandPureJSONCommand.Parameters[3].Value.SetWideString(MessageError);
 FExecuteCommandPureJSONCommand.Parameters[4].Value.SetBoolean(Execute);
 Try
  FExecuteCommandPureJSONCommand.Execute(ARequestFilter);
  Error := FExecuteCommandPureJSONCommand.Parameters[2].Value.GetBoolean;
  MessageError := FExecuteCommandPureJSONCommand.Parameters[3].Value.GetWideString;
  Result := TJSONObject(FExecuteCommandPureJSONCommand.Parameters[5].Value.GetJSONValue(FInstanceOwner));
 Except
  Result := Nil;
  FExecuteCommandPureJSONCommand := Nil;
  FExecuteCommandPureJSONCommand.DisposeOf;
 End;
End;


Function TSMPoolerMethodClient.ExecuteCommandPure(Pooler,
                                                  Method_Prefix,
                                                  SQL                  : String;
                                                  Var Error            : Boolean;
                                                  Var MessageError     : String;
                                                  Execute              : Boolean;
                                                  Const ARequestFilter : String = '';
                                                  TimeOut              : Integer = 3000;
                                                  UserName             : String  = '';
                                                  Password             : String  = ''): TFDJSONDataSets;
Begin
 Result := Nil;
 If FExecuteCommandPureCommand = Nil Then
  Begin
   FExecuteCommandPureCommand := FConnection.CreateCommand;
   FExecuteCommandPureCommand.RequestType := 'GET';
   FExecuteCommandPureCommand.Text := Method_Prefix + '.ExecuteCommandPure';
   FExecuteCommandPureCommand.Prepare(TSMPoolerMethodClient_ExecuteCommandPure);
  End;
 {$if CompilerVersion >= 28}
  FExecuteCommandPureCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FExecuteCommandPureCommand.Connection.UserName                 := UserName;
 FExecuteCommandPureCommand.Connection.Password                 := Password;
 FExecuteCommandPureCommand.Connection.LoginProperties.UserName := UserName;
 FExecuteCommandPureCommand.Connection.LoginProperties.Password := Password;
 FExecuteCommandPureCommand.Parameters[0].Value.SetWideString(Pooler);
 FExecuteCommandPureCommand.Parameters[1].Value.SetWideString(EncodeStrings(SQL,vEncoding));
 FExecuteCommandPureCommand.Parameters[2].Value.SetBoolean(Error);
 FExecuteCommandPureCommand.Parameters[3].Value.SetWideString(MessageError);
 FExecuteCommandPureCommand.Parameters[4].Value.SetBoolean(Execute);
 FExecuteCommandPureCommand.Execute(ARequestFilter);
 Error := FExecuteCommandPureCommand.Parameters[2].Value.GetBoolean;
 MessageError := FExecuteCommandPureCommand.Parameters[3].Value.GetWideString;
 If Not FExecuteCommandPureCommand.Parameters[5].Value.IsNull Then
  Begin
   If Not Execute Then
    Begin
     FUnMarshal := TDSRestCommand(FExecuteCommandPureCommand.Parameters[5].ConnectionHandler).GetJSONUnMarshaler;
     Try
      If vCompression Then
       {$if CompilerVersion >= 28}
         Result := TFDJSONDataSets(FUnMarshal.UnMarshal( DecompressJSON(FExecuteCommandPureCommand.Parameters[6].Value.GetJSONValue(FInstanceOwner).ToJSON)))
       {$else}
         Result := TFDJSONDataSets(FUnMarshal.UnMarshal(DecompressJSON(TJson.ObjectToJsonString(FExecuteCommandPureCommand.Parameters[6].Value.GetJSONValue(FInstanceOwner)))))
       {$ifend}
      Else
       Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FExecuteCommandPureCommand.Parameters[5].Value.GetJSONValue(True)));
      If FInstanceOwner Then
       FExecuteCommandPureCommand.FreeOnExecute(Result);
     Finally
      FreeAndNil(FUnMarshal);
     End;
    End;
  End;
End;

Function TSMPoolerMethodClient.ExecuteCommandJSON(Pooler,
                                                  Method_Prefix,
                                                  SQL                  : String;
                                                  Params               : TParams;
                                                  Var Error            : Boolean;
                                                  Var MessageError     : String;
                                                  Execute              : Boolean;
                                                  Const ARequestFilter : String = '';
                                                  TimeOut              : Integer = 3000;
                                                  UserName             : String  = '';
                                                  Password             : String  = '') : TJSONObject;
Begin
 If FExecuteCommandJSONCommand = Nil Then
  Begin
   FExecuteCommandJSONCommand := FConnection.CreateCommand;
   FExecuteCommandJSONCommand.RequestType := 'POST';
   FExecuteCommandJSONCommand.Text := Method_Prefix + '."ExecuteCommandJSON"';
   FExecuteCommandJSONCommand.Prepare(TSMPoolerMethodClient_ExecuteCommandJSON);
  End;
 {$if CompilerVersion >= 28}
  FExecuteCommandJSONCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FExecuteCommandJSONCommand.Connection.UserName                 := UserName;
 FExecuteCommandJSONCommand.Connection.Password                 := Password;
 FExecuteCommandJSONCommand.Connection.LoginProperties.UserName := UserName;
 FExecuteCommandJSONCommand.Connection.LoginProperties.Password := Password;
 FExecuteCommandJSONCommand.Parameters[0].Value.SetWideString(Pooler);
 FExecuteCommandJSONCommand.Parameters[1].Value.SetWideString(EncodeStrings(SQL,vEncoding));
 try
 FExecuteCommandJSONCommand.Parameters[2].Value.SetDBXReader(TDBXParamsReader.Create(TParams(Params), FInstanceOwner), True);
 except

 end;
 FExecuteCommandJSONCommand.Parameters[3].Value.SetBoolean(Error);
 FExecuteCommandJSONCommand.Parameters[4].Value.SetWideString(MessageError);
 FExecuteCommandJSONCommand.Parameters[5].Value.SetBoolean(Execute);
 Try
  FExecuteCommandJSONCommand.Execute(ARequestFilter);
  Error := FExecuteCommandJSONCommand.Parameters[3].Value.GetBoolean;
  MessageError := FExecuteCommandJSONCommand.Parameters[4].Value.GetWideString;
{
  If vCompression Then
   Result := DecompressJSON(FExecuteCommandJSONCommand.Parameters[6].Value.GetJSONValue(FInstanceOwner).ToJSON)
  Else
}
  Result := TJSONObject(FExecuteCommandJSONCommand.Parameters[6].Value.GetJSONValue(FInstanceOwner));
 Except
  Result := Nil;
  FExecuteCommandJSONCommand := Nil;
  FExecuteCommandJSONCommand.DisposeOf;
 End;
End;

Function TSMPoolerMethodClient.InsertValuePure(Pooler,
                                               Method_Prefix,
                                               SQL                  : String;
                                               Var Error            : Boolean;
                                               Var MessageError     : String;
                                               Const ARequestFilter : String = '';
                                               TimeOut              : Integer = 3000;
                                               UserName             : String  = '';
                                               Password             : String  = ''): Integer;
begin
 Result := -1;
 If FInsertValueCommandPure = Nil Then
  Begin
   FInsertValueCommandPure             := FConnection.CreateCommand;
   FInsertValueCommandPure.RequestType := 'GET';
   FInsertValueCommandPure.Text        := Method_Prefix + '.InsertValuePure';
   FInsertValueCommandPure.Prepare(TSMPoolerMethodClient_InsertValuePure);
  End;
 {$if CompilerVersion >= 28}
  FInsertValueCommandPure.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FInsertValueCommandPure.Connection.UserName                 := UserName;
 FInsertValueCommandPure.Connection.Password                 := Password;
 FInsertValueCommandPure.Connection.LoginProperties.UserName := UserName;
 FInsertValueCommandPure.Connection.LoginProperties.Password := Password;
 FInsertValueCommandPure.Parameters[0].Value.SetWideString(Pooler);
 FInsertValueCommandPure.Parameters[1].Value.SetWideString(EncodeStrings(SQL,vEncoding));
 FInsertValueCommandPure.Parameters[2].Value.SetBoolean(Error);
 FInsertValueCommandPure.Parameters[3].Value.SetWideString(MessageError);
 Try
  FInsertValueCommandPure.Execute(ARequestFilter);
  Error        := FInsertValueCommandPure.Parameters[2].Value.GetBoolean;
  MessageError := FInsertValueCommandPure.Parameters[3].Value.GetWideString;
  Result       := FInsertValueCommandPure.Parameters[4].Value.GetInt32;
 Except
  On E : Exception do
   Begin
    Error        := True;
    MessageError := E.Message;
   End;
 End;
end;

Function TSMPoolerMethodClient.InsertValue(Pooler,
                                           Method_Prefix,
                                           SQL                  : String;
                                           Params               : TParams;
                                           Var Error            : Boolean;
                                           Var MessageError     : String;
                                           Const ARequestFilter : String = '';
                                           TimeOut              : Integer = 3000;
                                           UserName             : String  = '';
                                           Password             : String  = ''): Integer;
begin
 Result := -1;
 If FInsertValueCommand = Nil Then
  Begin
   FInsertValueCommand             := FConnection.CreateCommand;
   FInsertValueCommand.RequestType := 'POST';
   FInsertValueCommand.Text        := Method_Prefix + '."InsertValue"';
   FInsertValueCommand.Prepare(TSMPoolerMethodClient_InsertValue);
  End;
 {$if CompilerVersion >= 28}
  FInsertValueCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FInsertValueCommand.Connection.UserName                 := UserName;
 FInsertValueCommand.Connection.Password                 := Password;
 FInsertValueCommand.Connection.LoginProperties.UserName := UserName;
 FInsertValueCommand.Connection.LoginProperties.Password := Password;
 FInsertValueCommand.Parameters[0].Value.SetWideString(Pooler);
 FInsertValueCommand.Parameters[1].Value.SetWideString(EncodeStrings(SQL,vEncoding));
 FInsertValueCommand.Parameters[2].Value.SetDBXReader(TDBXParamsReader.Create(Params, FInstanceOwner), True);
 FInsertValueCommand.Parameters[3].Value.SetBoolean(Error);
 FInsertValueCommand.Parameters[4].Value.SetWideString(MessageError);
 Try
  FInsertValueCommand.Execute(ARequestFilter);
  Error        := FInsertValueCommand.Parameters[3].Value.GetBoolean;
  MessageError := FInsertValueCommand.Parameters[4].Value.GetWideString;
  Result       := FInsertValueCommand.Parameters[5].Value.GetInt32;
 Except
  On E : Exception do
   Begin
    Error        := True;
    MessageError := E.Message;
   End;
 End;
End;

Function TSMPoolerMethodClient.ExecuteCommand(Pooler               : String;
                                              Method_Prefix        : String;
                                              SQL                  : String;
                                              Params               : TParams;
                                              Var Error            : Boolean;
                                              Var MessageError     : String;
                                              Execute              : Boolean;
                                              Const ARequestFilter : String = '';
                                              TimeOut              : Integer = 3000;
                                              UserName             : String  = '';
                                              Password             : String  = '') : TFDJSONDataSets;
Begin
 Result := Nil;
 If FExecuteCommandCommand = Nil Then
  Begin
   FExecuteCommandCommand := FConnection.CreateCommand;
   FExecuteCommandCommand.RequestType := 'POST';
   FExecuteCommandCommand.Text := Method_Prefix + '."ExecuteCommand"';
   FExecuteCommandCommand.Prepare(TSMPoolerMethodClient_ExecuteCommand);
  End;
 {$if CompilerVersion >= 28}
  FExecuteCommandCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FExecuteCommandCommand.Connection.UserName                 := UserName;
 FExecuteCommandCommand.Connection.Password                 := Password;
 FExecuteCommandCommand.Connection.LoginProperties.UserName := UserName;
 FExecuteCommandCommand.Connection.LoginProperties.Password := Password;
 FExecuteCommandCommand.Parameters[0].Value.SetWideString(Pooler);
 FExecuteCommandCommand.Parameters[1].Value.SetWideString(EncodeStrings(SQL,vEncoding));
 FExecuteCommandCommand.Parameters[2].Value.SetDBXReader(TDBXParamsReader.Create(Params, FInstanceOwner), True);
 FExecuteCommandCommand.Parameters[3].Value.SetBoolean(Error);
 FExecuteCommandCommand.Parameters[4].Value.SetWideString(MessageError);
 FExecuteCommandCommand.Parameters[5].Value.SetBoolean(Execute);
 FExecuteCommandCommand.Execute(ARequestFilter);
 Error := FExecuteCommandCommand.Parameters[3].Value.GetBoolean;
 MessageError := FExecuteCommandCommand.Parameters[4].Value.GetWideString;
 If Not FExecuteCommandCommand.Parameters[6].Value.IsNull Then
  Begin
   If Not Execute Then
    Begin
     FUnMarshal := TDSRestCommand(FExecuteCommandCommand.Parameters[6].ConnectionHandler).GetJSONUnMarshaler;
     Try
      If vCompression Then
       {$if CompilerVersion >= 28}
         Result := TFDJSONDataSets(FUnMarshal.UnMarshal(DecompressJSON(FExecuteCommandCommand.Parameters[6].Value.GetJSONValue(FInstanceOwner).ToJSON)))
       {$else}
         Result := TFDJSONDataSets(FUnMarshal.UnMarshal(DecompressJSON(TJson.ObjectToJsonString(FExecuteCommandCommand.Parameters[6].Value.GetJSONValue(FInstanceOwner)))))
       {$ifend}
      Else
       Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FExecuteCommandCommand.Parameters[6].Value.GetJSONValue(True)));
      If FInstanceOwner Then
       FExecuteCommandCommand.FreeOnExecute(Result);
     Finally
      FreeAndNil(FUnMarshal);
     End;
    End;
  End;
End;

Function TSMPoolerMethodClient.EchoPooler(Value, Method_Prefix : String;
                                          Const ARequestFilter : String = '';
                                          TimeOut              : Integer = 3000;
                                          UserName             : String  = '';
                                          Password             : String  = '') : String;
Begin
 If FEchoPoolerCommand = Nil Then
  Begin
   FEchoPoolerCommand := FConnection.CreateCommand;
   FEchoPoolerCommand.RequestType := 'GET';
   FEchoPoolerCommand.Text := Method_Prefix + '.EchoPooler';
   FEchoPoolerCommand.Prepare(TSMPoolerMethodClient_EchoPooler);
  End;
 {$if CompilerVersion >= 28}
  FEchoPoolerCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FEchoPoolerCommand.Connection.UserName                 := UserName;
 FEchoPoolerCommand.Connection.Password                 := Password;
 FEchoPoolerCommand.Connection.LoginProperties.UserName := UserName;
 FEchoPoolerCommand.Connection.LoginProperties.Password := Password;
 FEchoPoolerCommand.Parameters[0].Value.SetWideString(Value);
 FEchoPoolerCommand.Execute(ARequestFilter);
 Result := FEchoPoolerCommand.Parameters[1].Value.GetWideString;
end;

Function TSMPoolerMethodClient.PoolersDataSet(Method_Prefix        : String;
                                              Const ARequestFilter : String = '';
                                              TimeOut              : Integer = 3000;
                                              UserName             : String  = '';
                                              Password             : String  = '') : TStringList;
Var
 vTempString : String;
Begin
 If FPoolersDataSetCommand = Nil then
  Begin
   FPoolersDataSetCommand             := FConnection.CreateCommand;
   FPoolersDataSetCommand.RequestType := 'GET';
   FPoolersDataSetCommand.Text        := Method_Prefix + '.PoolersDataSet';
   FPoolersDataSetCommand.Prepare(TSMPoolerMethodClient_PoolersDataSet);
  End;
 {$if CompilerVersion >= 28}
  FPoolersDataSetCommand.Connection.HTTP.ConnectTimeout     := TimeOut;
 {$ifend}
 FPoolersDataSetCommand.Connection.UserName                 := UserName;
 FPoolersDataSetCommand.Connection.Password                 := Password;
 FPoolersDataSetCommand.Connection.LoginProperties.UserName := UserName;
 FPoolersDataSetCommand.Connection.LoginProperties.Password := Password;
 FPoolersDataSetCommand.Execute(ARequestFilter);
 vTempString := FPoolersDataSetCommand.Parameters[0].Value.GetWideString;
 Result      := TStringList.Create;
 While Not (vTempString = '') Do
  Begin
   if Pos('|', vTempString) > 0 then
    Begin
     Result.Add(Copy(vTempString, 1, Pos('|', vTempString) -1));
     Delete(vTempString, 1, Pos('|', vTempString));
    End
   Else
    Begin
     Result.Add(Copy(vTempString, 1, Length(vTempString)));
     Delete(vTempString, 1, Length(vTempString));
    End;
  End;
End;

Constructor TSMPoolerMethodClient.Create(ARestConnection: TDSRestConnection);
Begin
 inherited Create(ARestConnection);
 FInstanceOwner := True;
End;

Constructor TSMPoolerMethodClient.Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean);
Begin
 inherited Create(ARestConnection, AInstanceOwner);
End;


Function TSMPoolerMethodClient.DecompressJSON(Value : String) : TJSONObject;
Var
 vValue : String;
Begin
 If ZDecompressStr(Value, vValue) Then
  Result := TJSONObject.ParseJSONValue(CompressionDecoding.GetBytes(vValue), 0) as TJSONObject
 Else
  Result := Nil;
End;

Destructor TSMPoolerMethodClient.Destroy;
Begin
 FEchoPoolerCommand.DisposeOf;
 FPoolersDataSetCommand.DisposeOf;
 FPoolersDataSetCommand_Cache.DisposeOf;
 FEchoStringCommand.DisposeOf;
 inherited;
End;

Initialization
 CompressionEncoding := TEncoding.UTF8;
 CompressionDecoding := TEncoding.UTF8;

end.

