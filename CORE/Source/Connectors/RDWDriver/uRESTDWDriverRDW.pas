unit uRESTDWDriverRDW;

interface

uses SysUtils,                 uDWPoolerMethod,     Classes, DB,
     uDWConsts, uDWConstsData, uRESTDWPoolerDB,     uDWJSONInterface,
     uDWJSONObject,            uDWMassiveBuffer,    Variants,
     uDWDatamodule,            SysTypes, uSystemEvents;

Type
 TRESTDWDriverRDW         = Class(TRESTDWDriver)
 Private
  vRESTConnectionDB             : TDWPoolerMethodClient;
  vFDConnection                 : TRESTDWDataBase;
  Procedure SetConnection(Value : TRESTDWDataBase);
  Function  GetConnection       : TRESTDWDataBase;
  Procedure PrepareConnectionOnline;
 Protected
  Procedure Notification            (AComponent            : TComponent;
                                     Operation             : TOperation);Override;
 Public
  Function ConnectionSet                                  : Boolean;Override;
  Function GetGenID                 (Query                : TComponent;
                                     GenName              : String)          : Integer;Override;
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
                                     Var MessageError      : String)          : TJSONValue;Override;
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
  Property  Connection          : TRESTDWDataBase       Read GetConnection    Write SetConnection;
End;

Procedure Register;

implementation

{$IFNDEF FPC}{$if CompilerVersion < 21}
{$R .\Package\D7\RESTDWDriverRDW.dcr}
{$IFEND}{$ENDIF}

Uses uDWJSONTools, uDWConstsCharset;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverRDW]);
End;

Function TRESTDWDriverRDW.ProcessMassiveSQLCache(MassiveSQLCache  : String;
                                                 Var Error        : Boolean;
                                                 Var MessageError : String)  : TJSONValue;
Var
 SocketError : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error         := False;
 Result        := NIl;
 Try
  If Assigned(vFDConnection) Then
   Begin
    Result := vRESTConnectionDB.ProcessMassiveSQLCache(MassiveSQLCache,
                                                       vFDConnection.PoolerName,
                                                       vFDConnection.PoolerURL,
                                                       Error,
                                                       MessageError,
                                                       SocketError,
                                                       vFDConnection.RequestTimeOut,
                                                       vFDConnection.ConnectTimeOut,
                                                       vFDConnection.ClientConnectionDefs.ConnectionDefs);
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Function TRESTDWDriverRDW.ApplyUpdates_MassiveCache(MassiveCache     : String;
                                                    Var Error        : Boolean;
                                                    Var MessageError : String)      : TJSONValue;
Var
 SocketError : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error         := False;
 Result        := NIl;
 Try
  If Assigned(vFDConnection) Then
   Begin
    Result := vRESTConnectionDB.ApplyUpdates_MassiveCache(MassiveCache,
                                                          vFDConnection.PoolerName,
                                                          vFDConnection.PoolerURL,
                                                          Error,
                                                          MessageError,
                                                          SocketError,
                                                          vFDConnection.RequestTimeOut,
                                                          vFDConnection.ConnectTimeOut,
                                                          vFDConnection.ClientConnectionDefs.ConnectionDefs);
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDriverRDW.Close;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 If Connection <> Nil Then
  Connection.Close;
End;

Function TRESTDWDriverRDW.ConnectionSet: Boolean;
Begin
 Result := vRESTConnectionDB <> Nil;
End;

Class Procedure TRESTDWDriverRDW.CreateConnection(Const ConnectionDefs : TConnectionDefs;
                                                  Var Connection       : TObject);
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
End;

function TRESTDWDriverRDW.ExecuteCommand(SQL                  : String;
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
 LDataSetList : TJSONValue;
 SocketError  : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error                 := False;
 Try
  If Assigned(vFDConnection) Then
   Begin
    LDataSetList := vRESTConnectionDB.ExecuteCommandJSON(vFDConnection.PoolerName,
                                                         vFDConnection.PoolerURL,
                                                         SQL, Params, Error,
                                                         MessageError,
                                                         SocketError,
                                                         RowsAffected,
                                                         Execute,
                                                         BinaryEvent,
                                                         BinaryCompatibleMode,
                                                         MetaData,
                                                         vFDConnection.RequestTimeOut,
                                                         vFDConnection.ConnectTimeOut,
                                                         vFDConnection.ClientConnectionDefs.ConnectionDefs);
    If Not Error Then
     Result := LDataSetList.ToJSON;
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

procedure TRESTDWDriverRDW.ExecuteProcedure(ProcName         : String;
                                            Params           : TDWParams;
                                            Var Error        : Boolean;
                                            Var MessageError : String);
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
End;

procedure TRESTDWDriverRDW.ExecuteProcedurePure(ProcName         : String;
                                                Var Error        : Boolean;
                                                Var MessageError : String);
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
End;

Function TRESTDWDriverRDW.GetGenID(Query   : TComponent;
                                   GenName : String)     : Integer;
Begin
 Result := -1;
End;

Function TRESTDWDriverRDW.ApplyUpdatesTB(Massive              : String;
                                              Params               : TDWParams;
                                              Var Error            : Boolean;
                                              Var MessageError     : String;
                                              Var RowsAffected     : Integer) : TJSONValue;
Begin

End;

Function TRESTDWDriverRDW.ExecuteCommandTB(Tablename            : String;
                                           Params               : TDWParams;
                                           Var Error            : Boolean;
                                           Var MessageError     : String;
                                           Var BinaryBlob       : TMemoryStream;
                                           Var RowsAffected     : Integer;
                                           BinaryEvent          : Boolean = False;
                                           MetaData             : Boolean = False;
                                           BinaryCompatibleMode : Boolean = False)  : String;
Var
 LDataSetList : TJSONValue;
 SocketError : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error         := False;
 Result        := '';
 Try
  If Assigned(vFDConnection) Then
   Begin
    LDataSetList := vRESTConnectionDB.ExecuteCommandJSONTB(vFDConnection.PoolerName,
                                                     vFDConnection.PoolerURL,
                                                     Tablename,
                                                     Params,
                                                     Error,
                                                     MessageError,
                                                     SocketError,
                                                     RowsAffected,
                                                     BinaryEvent,
                                                     BinaryCompatibleMode,
                                                     MetaData,
                                                     vFDConnection.RequestTimeOut,
                                                     vFDConnection.ConnectTimeOut,
                                                     vFDConnection.ClientConnectionDefs.ConnectionDefs);
    If Not Error Then
     Result := LDataSetList.ToJSON;
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Function TRESTDWDriverRDW.ExecuteCommandTB(Tablename            : String;
                                           Var Error            : Boolean;
                                           Var MessageError     : String;
                                           Var BinaryBlob       : TMemoryStream;
                                           Var RowsAffected     : Integer;
                                           BinaryEvent          : Boolean = False;
                                           MetaData             : Boolean = False;
                                           BinaryCompatibleMode : Boolean = False)  : String;
Var
 SocketError : Boolean;
 LDataSetList : TJSONValue;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error         := False;
 Result        := '';
 Try
  If Assigned(vFDConnection) Then
   Begin
    LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSONTB(vFDConnection.PoolerName,
                                                         vFDConnection.PoolerURL,
                                                         Tablename,
                                                         Error,
                                                         MessageError,
                                                         SocketError,
                                                         RowsAffected,
                                                         BinaryEvent,
                                                         BinaryCompatibleMode,
                                                         MetaData,
                                                         vFDConnection.RequestTimeOut,
                                                         vFDConnection.ConnectTimeOut,
                                                         vFDConnection.ClientConnectionDefs.ConnectionDefs);
    If Not Error Then
     Result := LDataSetList.ToJSON;
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Function TRESTDWDriverRDW.ApplyUpdates(Massive,
                                       SQL               : String;
                                       Params            : TDWParams;
                                       Var Error         : Boolean;
                                       Var MessageError  : String;
                                       Var RowsAffected  : Integer) : TJSONValue;
Var
 SocketError : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error         := False;
 Result        := NIl;
 Try
  If Assigned(vFDConnection) Then
   Begin
    Result := vRESTConnectionDB.ApplyUpdates(Nil, vFDConnection.PoolerName,
                                             vFDConnection.PoolerURL,
                                             SQL, Params, Error,
                                             MessageError,
                                             SocketError,
                                             RowsAffected,
                                             vFDConnection.RequestTimeOut,
                                             vFDConnection.ConnectTimeOut,
                                             Massive,
                                             vFDConnection.ClientConnectionDefs.ConnectionDefs);
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDriverRDW.PrepareConnectionOnline;
Begin
 vRESTConnectionDB                := TDWPoolerMethodClient.Create(Nil);
 vRESTConnectionDB.WelcomeMessage := vFDConnection.WelcomeMessage;
 vRESTConnectionDB.Host           := vFDConnection.PoolerService;
 vRESTConnectionDB.Port           := vFDConnection.PoolerPort;
 vRESTConnectionDB.Compression    := vFDConnection.Compression;
 vRESTConnectionDB.TypeRequest    := vFDConnection.TypeRequest;
 vRESTConnectionDB.Encoding       := Encoding;
 vRESTConnectionDB.EncodeStrings  := EncodeStringsJSON;
 vRESTConnectionDB.AccessTag      := vFDConnection.AccessTag;
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
End;

Function TRESTDWDriverRDW.ExecuteCommand(SQL                  : String;
                                         Var Error            : Boolean;
                                         Var MessageError     : String;
                                         Var BinaryBlob       : TMemoryStream;
                                         Var RowsAffected     : Integer;
                                         Execute              : Boolean = False;
                                         BinaryEvent          : Boolean = False;
                                         MetaData             : Boolean = False;
                                         BinaryCompatibleMode : Boolean = False) : String;
Var
 LDataSetList : TJSONValue;
 SocketError  : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error                 := False;
 Try
  If Assigned(vFDConnection) Then
   Begin
    LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSON(vFDConnection.PoolerName,
                                                             vFDConnection.PoolerURL,
                                                             SQL, Error,
                                                             MessageError,
                                                             SocketError,
                                                             RowsAffected,
                                                             Execute,
                                                             BinaryEvent,
                                                             BinaryCompatibleMode,
                                                             MetaData,
                                                             vFDConnection.RequestTimeOut,
                                                             vFDConnection.ConnectTimeOut,
                                                             vFDConnection.ClientConnectionDefs.ConnectionDefs);
    If Not Error Then
     Result := LDataSetList.ToJSON;
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Function TRESTDWDriverRDW.GetConnection: TRESTDWDataBase;
Begin
 Result := vFDConnection;
End;

Function TRESTDWDriverRDW.InsertMySQLReturnID(SQL              : String;
                                              Params           : TDWParams;
                                              Var Error        : Boolean;
                                              Var MessageError : String): Integer;
Var
 SocketError : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error     := False;
 Result    := -1;
 Try
  If Assigned(vFDConnection) Then
   Begin
    Result := vRESTConnectionDB.InsertValue(vFDConnection.PoolerName,
                                            vFDConnection.PoolerURL,
                                            SQL, Params, Error,
                                            MessageError,
                                            SocketError,
                                            vFDConnection.RequestTimeOut,
                                            vFDConnection.ConnectTimeOut,
                                            vFDConnection.ClientConnectionDefs.ConnectionDefs);
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDriverRDW.Notification(AComponent: TComponent; Operation: TOperation);
Begin
 //Alexandre Magno - 25/11/2018
 If (Operation  = opRemove)      And
    (AComponent = vFDConnection) Then
  vFDConnection := Nil;
 Inherited Notification(AComponent, Operation);
End;

Procedure TRESTDWDriverRDW.GetTableNames(Var TableNames       : TStringList;
                                         Var Error            : Boolean;
                                         Var MessageError     : String);
Var
 SocketError  : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error        := False;
 SocketError  := False;
 Try
  If Assigned(vFDConnection) Then
   Begin
    If Not vRESTConnectionDB.GetTableNames(vFDConnection.PoolerName,
                                           vFDConnection.PoolerURL,
                                           TableNames,
                                           Error,
                                           MessageError,
                                           SocketError,
                                           vFDConnection.RequestTimeOut,
                                           vFDConnection.ConnectTimeOut,
                                           vFDConnection.ClientConnectionDefs.ConnectionDefs) Then
     Begin
      Error        := True;
      MessageError := 'Invalid Connection.';
     End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDriverRDW.GetProcNames(Var ProcNames        : TStringList;
                                        Var Error            : Boolean;
                                        Var MessageError     : String);
Begin

End;

Procedure TRESTDWDriverRDW.GetProcParams(ProcName             : String;
                                         Var ParamNames       : TStringList;
                                         Var Error            : Boolean;
                                         Var MessageError     : String);
Begin

End;

Procedure TRESTDWDriverRDW.GetKeyFieldNames(TableName            : String;
                                            Var FieldNames       : TStringList;
                                            Var Error            : Boolean;
                                            Var MessageError     : String);
Var
 SocketError  : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error        := False;
 SocketError  := False;
 Try
  If Assigned(vFDConnection) Then
   Begin
    If Not vRESTConnectionDB.GetKeyFieldNames(vFDConnection.PoolerName,
                                              vFDConnection.PoolerURL,
                                              TableName, FieldNames,
                                              Error,
                                              MessageError,
                                              SocketError,
                                              vFDConnection.RequestTimeOut,
                                              vFDConnection.ConnectTimeOut,
                                              vFDConnection.ClientConnectionDefs.ConnectionDefs) Then
     Begin
      Error        := True;
      MessageError := 'Invalid Connection.';
     End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDriverRDW.GetFieldNames(TableName        : String;
                                         Var FieldNames   : TStringList;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Var
 SocketError  : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error        := False;
 SocketError  := False;
 Try
  If Assigned(vFDConnection) Then
   Begin
    If Not vRESTConnectionDB.GetFieldNames(vFDConnection.PoolerName,
                                           vFDConnection.PoolerURL,
                                           TableName, FieldNames,
                                           Error,
                                           MessageError,
                                           SocketError,
                                           vFDConnection.RequestTimeOut,
                                           vFDConnection.ConnectTimeOut,
                                           vFDConnection.ClientConnectionDefs.ConnectionDefs) Then
     Begin
      Error        := True;
      MessageError := 'Invalid Connection.';
     End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Function TRESTDWDriverRDW.OpenDatasets(DatasetsLine     : String;
                                       Var Error        : Boolean;
                                       Var MessageError : String;
                                       Var BinaryBlob   : TMemoryStream)  : TJSONValue;
Var
 LDataSetList : String;
 SocketError  : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error  := False;
 Result := Nil;
 Try
  If Assigned(vFDConnection) Then
   Begin
    LDataSetList := vRESTConnectionDB.OpenDatasets(DatasetsLine,
                                                   vFDConnection.PoolerName,
                                                   vFDConnection.PoolerURL,
                                                   Error,
                                                   MessageError,
                                                   SocketError,
                                                   vFDConnection.RequestTimeOut,
                                                   vFDConnection.ConnectTimeOut,
                                                   vFDConnection.ClientConnectionDefs.ConnectionDefs);
    If Not Error Then
     Begin
      Result := TJSONValue.Create;
      Result.Encoded  := True;
      Result.Encoding := Encoding;
      Result.LoadFromJSON(LDataSetList);
     End;
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDriverRDW.PrepareConnection(Var ConnectionDefs : TConnectionDefs);
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
End;

Function TRESTDWDriverRDW.InsertMySQLReturnID(SQL              : String;
                                              Var Error        : Boolean;
                                              Var MessageError : String)   : Integer;
Var
 SocketError : Boolean;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 PrepareConnectionOnline;
 Error     := False;
 Result    := -1;
 Try
  If Assigned(vFDConnection) Then
   Begin
    Result := vRESTConnectionDB.InsertValuePure(vFDConnection.PoolerName,
                                                vFDConnection.PoolerURL,
                                                SQL, Error,
                                                MessageError,
                                                SocketError,
                                                vFDConnection.RequestTimeOut,
                                                vFDConnection.ConnectTimeOut,
                                                vFDConnection.ClientConnectionDefs.ConnectionDefs);
   End
  Else
   Begin
    Error        := True;
    MessageError := 'Invalid Connection.';
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDriverRDW.SetConnection(Value : TRESTDWDataBase);
Begin
 //Alexandre Magno - 25/11/2018
 If vFDConnection <> Value Then vFDConnection := Value;
 If vFDConnection <> Nil   Then vFDConnection.FreeNotification(Self);
End;

end.
