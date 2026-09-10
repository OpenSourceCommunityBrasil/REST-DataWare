Unit uRESTDWNativeDriver;

{$I uRESTDW.inc}

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

Interface

Uses
 Classes, DB, SysUtils,
{$IFDEF FPC}
 LResources,
{$ENDIF}
uRESTDWDriverBase, uRESTDWBasicDbTypes,
 uRESTDWParams, uRESTDWJSONInterface, uRESTDWTools, uRESTDWProtoTypes, uRESTDWConsts;

Type
 TRESTDWNativeLink = Class(TComponent)
{$IFDEF RESTDWLAZARUS}
 Private
  FDatabaseCharSet : TDatabaseCharSet;
{$ENDIF}
 Protected
  Function GetConnection : TComponent; Virtual; Abstract;
 Public
  Function GetQuery : TRESTDWDrvQuery; Virtual;
  Function IsConnected : Boolean; Virtual; Abstract;
  Procedure Connect; Virtual; Abstract;
  Procedure Disconnect; Virtual; Abstract;
  Procedure ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                          AOutput : TStream; ACompress : Boolean); Overload; Virtual; Abstract;
  Procedure ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                          AOutput : TStream; ACompress : Boolean;
                          ABinaryCompatibleMode : Boolean); Overload; Virtual;
  Function ExecuteCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64; Virtual; Abstract;
  Property Connection : TComponent Read GetConnection;
{$IFDEF RESTDWLAZARUS}
 Published
  Property DatabaseCharSet : TDatabaseCharSet Read FDatabaseCharSet Write FDatabaseCharSet Default csUndefined;
{$ENDIF}
 End;

 TRESTDWNativeDriver = Class(TRESTDWDriverBase)
 Private
  FBlobCompression : Boolean;
  FNativeLink      : TRESTDWNativeLink;
  Procedure SetNativeLink(AValue : TRESTDWNativeLink);
 Protected
  Property Connection;
  Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
 Public
  Constructor Create(AOwner : TComponent); Override;
  Function getConnectionType : TRESTDWDatabaseType; Override;
  Function getQuery : TRESTDWDrvQuery; Override;
  Function getQuery(AUnidir : Boolean) : TRESTDWDrvQuery; Override;
  Function getTable : TRESTDWDrvTable; Override;
  Function getStoreProc : TRESTDWDrvStoreProc; Override;
  Function compConnIsValid(AConnection : TComponent) : Boolean; Override;
  Function ConnectionSet : Boolean; Override;
  Function isConnected : Boolean; Override;
  Procedure Connect; Override;
  Procedure Disconect; Override;
  Function connInTransaction : Boolean; Override;
  Procedure connStartTransaction; Override;
  Procedure connCommit; Override;
  Procedure connRollback; Override;
  Function ExecuteCommand(SQL : String; Var Error : Boolean; Var MessageError : String;
                          Var BinaryBlob : TMemoryStream; Var RowsAffected : Integer; Execute : Boolean = False;
                          BinaryEvent : Boolean = False; MetaData : Boolean = False;
                          BinaryCompatibleMode : Boolean = False) : String; Overload; Override;
  Function ExecuteCommand(SQL : String; Params : TRESTDWParams; Var Error : Boolean;
                          Var MessageError : String; Var BinaryBlob : TMemoryStream; Var RowsAffected : Integer;
                          Execute : Boolean = False; BinaryEvent : Boolean = False; MetaData : Boolean = False;
                          BinaryCompatibleMode : Boolean = False) : String; Overload; Override;
  Procedure ExecuteNativeSelect(Const ASQL : String; AParams : TRESTDWParams; Var AStream : TStream); Virtual;
  Function ExecuteNativeCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64; Virtual;
 Published
  Property ConnectionType;
  Property NativeLink       : TRESTDWNativeLink Read FNativeLink Write SetNativeLink;
  Property BlobCompression  : Boolean Read FBlobCompression Write FBlobCompression;
 End;

Procedure Register;

Implementation

Function TRESTDWNativeLink.GetQuery : TRESTDWDrvQuery;
Begin
 Result := Nil;
End;

Procedure TRESTDWNativeLink.ExecuteSelect(Const ASQL : String; AParams : TRESTDWParams;
                                          AOutput : TStream; ACompress : Boolean;
                                          ABinaryCompatibleMode : Boolean);
Begin
 ExecuteSelect(ASQL, AParams, AOutput, ACompress);
End;

Constructor TRESTDWNativeDriver.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 FBlobCompression := False;
 FNativeLink      := Nil;
End;

Procedure TRESTDWNativeDriver.SetNativeLink(AValue : TRESTDWNativeLink);
Begin
 If FNativeLink = AValue Then
  Exit;
 If FNativeLink <> Nil Then
  FNativeLink.RemoveFreeNotification(Self);
 FNativeLink := AValue;
 If FNativeLink <> Nil Then
  Begin
   FNativeLink.FreeNotification(Self);
   {$IFDEF RESTDWLAZARUS}
   FNativeLink.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
End;

Procedure TRESTDWNativeDriver.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If (Operation = opRemove) And (AComponent = FNativeLink) Then
  FNativeLink := Nil;
End;

Function TRESTDWNativeDriver.getConnectionType : TRESTDWDatabaseType;
Begin
 Result := Inherited getConnectionType;
End;

Function TRESTDWNativeDriver.getQuery : TRESTDWDrvQuery;
Begin
 Result := Nil;
 If FNativeLink <> Nil Then
  Result := FNativeLink.GetQuery;
End;

Function TRESTDWNativeDriver.getQuery(AUnidir : Boolean) : TRESTDWDrvQuery;
Begin
 Result := Nil;
 If FNativeLink <> Nil Then
  Result := FNativeLink.GetQuery;
End;

Function TRESTDWNativeDriver.getTable : TRESTDWDrvTable;
Begin
 Result := Nil;
End;

Function TRESTDWNativeDriver.getStoreProc : TRESTDWDrvStoreProc;
Begin
 Result := Nil;
End;

Function TRESTDWNativeDriver.compConnIsValid(AConnection : TComponent) : Boolean;
Begin
 Result := (FNativeLink <> Nil) And
           (AConnection <> Nil) And
           (FNativeLink.Connection = AConnection);
End;

Function TRESTDWNativeDriver.ConnectionSet : Boolean;
Begin
 Result := (FNativeLink <> Nil) And
           (FNativeLink.Connection <> Nil);
End;

Function TRESTDWNativeDriver.isConnected : Boolean;
Begin
 Result := (FNativeLink <> Nil) And FNativeLink.IsConnected;
End;

Procedure TRESTDWNativeDriver.Connect;
Begin
 If FNativeLink <> Nil Then
  Begin
   {$IFDEF RESTDWLAZARUS}
   FNativeLink.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
   FNativeLink.Connect;
  End;
End;

Procedure TRESTDWNativeDriver.Disconect;
Begin
 If FNativeLink <> Nil Then
  FNativeLink.Disconnect;
End;

Function TRESTDWNativeDriver.connInTransaction : Boolean;
Begin
 Result := False;
End;

Procedure TRESTDWNativeDriver.connStartTransaction;
Begin
End;

Procedure TRESTDWNativeDriver.connCommit;
Begin
End;

Procedure TRESTDWNativeDriver.connRollback;
Begin
End;

Function TRESTDWNativeDriver.ExecuteCommand(SQL : String; Var Error : Boolean;
                                            Var MessageError : String; Var BinaryBlob : TMemoryStream;
                                            Var RowsAffected : Integer; Execute : Boolean;
                                            BinaryEvent : Boolean; MetaData : Boolean;
                                            BinaryCompatibleMode : Boolean) : String;
Begin
 Result := ExecuteCommand(SQL, Nil, Error, MessageError, BinaryBlob, RowsAffected,
                          Execute, BinaryEvent, MetaData, BinaryCompatibleMode);
End;

Function TRESTDWNativeDriver.ExecuteCommand(SQL : String; Params : TRESTDWParams;
                                            Var Error : Boolean; Var MessageError : String;
                                            Var BinaryBlob : TMemoryStream; Var RowsAffected : Integer;
                                            Execute : Boolean; BinaryEvent : Boolean; MetaData : Boolean;
                                            BinaryCompatibleMode : Boolean) : String;
Var
 S            : TStream;
 EventDataSet : TDataSet;
Begin
 Result       := '';
 Error        := False;
 MessageError := '';
 RowsAffected := 0;
 EventDataSet := Nil;
 Try
  If FNativeLink = Nil Then
   DatabaseError('NativeLink not assigned');
  {$IFDEF RESTDWLAZARUS}
  FNativeLink.DatabaseCharSet := DatabaseCharSet;
  {$ENDIF}
  If Not FNativeLink.IsConnected Then
   FNativeLink.Connect;
  If Assigned(Self.OnQueryBeforeOpen) Then
   Self.OnQueryBeforeOpen(EventDataSet, Params);
  If Execute Then
   Begin
    RowsAffected := Integer(FNativeLink.ExecuteCommand(SQL, Params));
    Result       := '{"COMMANDOK":true}';
   End
  Else If BinaryEvent Then
   Begin
    If BinaryBlob = Nil Then
     BinaryBlob := TMemoryStream.Create
    Else
     Begin
      BinaryBlob.Position := 0;
      BinaryBlob.Size := 0;
     End;
    BinaryBlob.Position := 0;
    S := BinaryBlob;
    FNativeLink.ExecuteSelect(SQL, Params, S, FBlobCompression Or Compression, BinaryCompatibleMode);
    BinaryBlob.Position := 0;
   End
  Else
   DatabaseError('Native SELECT requires binary transport');
 Except
  On E : Exception Do
   Begin
    Error        := True;
    MessageError := E.Message;
    If Assigned(Self.OnQueryException) Then
     Self.OnQueryException(EventDataSet, Params, E.Message);
    Result := GetPairJSONStr('NOK', MessageError);
   End;
 End;
End;

Procedure TRESTDWNativeDriver.ExecuteNativeSelect(Const ASQL : String; AParams : TRESTDWParams; Var AStream : TStream);
Begin
 If FNativeLink = Nil Then
  DatabaseError('NativeLink not assigned');
 {$IFDEF RESTDWLAZARUS}
 FNativeLink.DatabaseCharSet := DatabaseCharSet;
 {$ENDIF}
 If Not FNativeLink.IsConnected Then
  FNativeLink.Connect;
 FNativeLink.ExecuteSelect(ASQL, AParams, AStream, FBlobCompression Or Compression);
End;

Function TRESTDWNativeDriver.ExecuteNativeCommand(Const ASQL : String; AParams : TRESTDWParams) : Int64;
Begin
 If FNativeLink = Nil Then
  DatabaseError('NativeLink not assigned');
 {$IFDEF RESTDWLAZARUS}
 FNativeLink.DatabaseCharSet := DatabaseCharSet;
 {$ENDIF}
 If Not FNativeLink.IsConnected Then
  FNativeLink.Connect;
 Result := FNativeLink.ExecuteCommand(ASQL, AParams);
End;

Procedure Register;
Begin
 {$IFNDEF RESTDWFPC}
 RegisterComponents('REST Dataware - Drivers', [TRESTDWNativeDriver]);
 {$ENDIF}
End;

Initialization
{$IFDEF FPC}
 {$I uRESTDWNativeDriver.lrs}
{$ENDIF}

End.
