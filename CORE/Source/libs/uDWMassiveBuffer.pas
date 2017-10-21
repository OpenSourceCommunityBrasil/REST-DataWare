unit uDWMassiveBuffer;

{$I uRESTDW.inc}

interface

uses SysUtils,  Classes,        uDWJSONObject,
     DB,        uRESTDWBase,    uDWPoolerMethod,
     uDWConsts, uDWConstsData;

Type
 TMassiveValue = Class
 Private
  vJSONValue  : TJSONValue;
 Protected
 Public
  Constructor Create;
  Destructor  Free;
  Function    GetValue   : String;
  Procedure   SetValue(Value : String);
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Value      : String  Read GetValue Write SetValue;
End;

Type
 PMassiveValue  = ^TMassiveValue;
 TMassiveValues = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveValue;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveValue); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveValue) : Integer;          Overload;
  Property   Items[Index  : Integer]       : TMassiveValue Read GetRec Write PutRec; Default;
End;

Type
 TMassiveField = Class
 Private
  vRequired,
  vKeyField   : Boolean;
  vJSONValue  : ^TMassiveValue;
  vFieldsName : String;
  vFieldType  : TObjectValue;
  vSize,
  vPrecision  : Integer;
 Protected
 Public
  Constructor Create;
  Destructor  Free;
  Function    Value      : String;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Required   : Boolean      Read vRequired   Write vRequired;
  Property    KeyField   : Boolean      Read vKeyField   Write vKeyField;
  Property    FieldType  : TObjectValue Read vFieldType  Write vFieldType;
  Property    FieldsName : String       Read vFieldsName Write vFieldsName;
  Property    Size       : Integer      Read vSize       Write vSize;
  Property    Precision  : Integer      Read vPrecision  Write vPrecision;
End;

Type
 PMassiveField  = ^TMassiveField;
 TMassiveFields = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveField;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveField); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveField) : Integer;          Overload;
  Function   FieldByName(FieldName : String) : TMassiveField;
  Property   Items[Index  : Integer]       : TMassiveField Read GetRec Write PutRec; Default;
End;

Type
 TMassiveLine = Class
 Private
  vMassiveValues  : TMassiveValues;
  vMassiveMode    : TMassiveMode;
  Function   GetRec(Index : Integer)       : TMassiveValue;
  Procedure  PutRec(Index : Integer; Item  : TMassiveValue);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   ClearAll;
  Property    MassiveMode  : TMassiveMode              Read vMassiveMode Write vMassiveMode;
  Property    Value[Index  : Integer] : TMassiveValue  Read GetRec       Write PutRec;
End;

Type
 PMassiveLine   = ^TMassiveLine;
 TMassiveBuffer = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveLine;    Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveLine);   Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                         Overload;
  Function   Add   (Item  : TMassiveLine)  : Integer;         Overload;
  Property   Items[Index  : Integer]       : TMassiveLine Read GetRec Write PutRec; Default;
End;

Type
 TMassiveDatasetBuffer = Class(TMassiveDataset)
 Protected
  vRecNo         : Integer;
  vMassiveBuffer : TMassiveBuffer;
  vMassiveLine   : TMassiveLine;
  vMassiveFields : TMassiveFields;
  vMassiveMode   : TMassiveMode;
  vTableName     : String;
 Private
  Procedure ReadBuffer;
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Function  RecNo       : Integer;
  Function  RecordCount : Integer;
  Procedure First;
  Procedure Prior;
  Procedure Next;
  Procedure Last;
  Procedure BuildDataset(Dataset             : TRESTDWClientSQLBase;
                         UpdateTableName     : String);   //Constroi o Dataset Massivo
  Procedure BuildLine   (Dataset             : TRESTDWClientSQLBase;
                         MassiveModeBuff     : TMassiveMode;
                         Var MassiveLineBuff : TMassiveLine);
  Procedure BuildBuffer (Dataset     : TRESTDWClientSQLBase;    //Cria um Valor Massivo Baseado nos Dados de Um Dataset
                         MassiveMode : TMassiveMode);
  Procedure SaveBuffer  (Dataset     : TRESTDWClientSQLBase);   //Salva Um Buffer Massivo na Lista de Massivos
  Procedure ClearBuffer;                                        //Limpa o Buffer Massivo Atual
  Procedure ClearDataset;                                       //Limpa Todo o Dataset Massivo
  Procedure ClearLine;                                          //Limpa o Buffer Temporario
  Function  ToJSON      : String;                               //Gera o JSON do Dataset Massivo
  Procedure FromJSON    (Value : String);                       //Carrega o Dataset Massivo a partir de um JSON
  Property  MassiveMode : TMassiveMode   Read vMassiveMode;     //Modo Massivo do Buffer Atual
  Property  Fields      : TMassiveFields Read vMassiveFields Write vMassiveFields;
  Property  TableName   : String         Read vTableName;
End;

implementation

Uses uRESTDWPoolerDB;

{ TMassiveField }

Constructor TMassiveField.Create;
Begin
 vRequired   := False;
 vKeyField   := vRequired;
 vFieldType  := ovUnknown;
 vJSONValue  := Nil;
 vFieldsName := '';
End;

Destructor TMassiveField.Free;
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   FreeAndNil(vJSONValue^);
 vJSONValue := Nil;
End;

Procedure TMassiveField.LoadFromStream(Stream: TMemoryStream);
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   vJSONValue^.LoadFromStream(Stream);
End;

Procedure TMassiveField.SaveToStream(Stream: TMemoryStream);
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   vJSONValue^.SaveToStream(Stream);
End;

Function TMassiveField.Value : String;
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   Result := vJSONValue^.Value;
End;

{ TMassiveFields }

Function TMassiveFields.Add(Item: TMassiveField): Integer;
Var
 vItem : ^TMassiveField;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveFields.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveField(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveField(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TMassiveFields.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Destructor TMassiveFields.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveFields.FieldByName(FieldName : String): TMassiveField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   If LowerCase(TMassiveField(TList(Self).Items[I]^).vFieldsName) =
      LowerCase(FieldName) Then
    Begin
     Result := TMassiveField(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Function TMassiveFields.GetRec(Index : Integer) : TMassiveField;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveField(TList(Self).Items[Index]^);
End;

Procedure TMassiveFields.PutRec(Index : Integer; Item : TMassiveField);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveField(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveValue }

Constructor TMassiveValue.Create;
Begin
 vJSONValue := TJSONValue.Create;
End;

Destructor TMassiveValue.Free;
Begin
 FreeAndNil(vJSONValue);
End;

Function TMassiveValue.GetValue: String;
Begin
 Result := vJSONValue.Value;
End;

Procedure TMassiveValue.LoadFromStream(Stream: TMemoryStream);
Begin
 vJSONValue.LoadFromStream(Stream);
End;

Procedure TMassiveValue.SaveToStream(Stream: TMemoryStream);
Begin
 vJSONValue.SaveToStream(Stream);
End;

Procedure TMassiveValue.SetValue(Value: String);
Begin
 vJSONValue.SetValue(Value);
End;

{ TMassiveValues }

Function TMassiveValues.Add(Item: TMassiveValue): Integer;
Var
 vItem : ^TMassiveValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveValues.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Procedure TMassiveValues.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveValue(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveValues.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveValues.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(Self).Items[Index]^);
End;

Procedure TMassiveValues.PutRec(Index: Integer; Item: TMassiveValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveValue(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveLine }

Constructor TMassiveLine.Create;
Begin
 vMassiveValues  := TMassiveValues.Create;
 vMassiveMode    := mmBrowse;
End;

Destructor TMassiveLine.Destroy;
Begin
 FreeAndNil(vMassiveValues);
 Inherited;
End;

Function TMassiveLine.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(vMassiveValues).Items[Index]^);
End;

Procedure TMassiveLine.ClearAll;
Begin
 vMassiveValues.ClearAll;
End;

Procedure TMassiveLine.PutRec(Index: Integer; Item: TMassiveValue);
Begin
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  TMassiveValue(TList(vMassiveValues).Items[Index]^) := Item;
End;

{ TMassiveBuffer }

Function TMassiveBuffer.Add(Item : TMassiveLine): Integer;
Var
 vItem : ^TMassiveLine;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveBuffer.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Procedure TMassiveBuffer.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveLine(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveLine(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveBuffer.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveBuffer.GetRec(Index: Integer): TMassiveLine;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveLine(TList(Self).Items[Index]^);
End;

Procedure TMassiveBuffer.PutRec(Index: Integer; Item: TMassiveLine);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveLine(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveDatasetBuffer }

Procedure TMassiveDatasetBuffer.BuildLine(Dataset             : TRESTDWClientSQLBase;
                                          MassiveModeBuff     : TMassiveMode;
                                          Var MassiveLineBuff : TMassiveLine);
Var
 I : Integer;
Begin
 Case MassiveModeBuff Of
  mmInsert : Begin

             End;
  mmUpdate : Begin

             End;
  mmDelete : Begin

             End;
 End;
End;

Procedure TMassiveDatasetBuffer.BuildBuffer(Dataset     : TRESTDWClientSQLBase;
                                            MassiveMode : TMassiveMode);
Begin
 Case MassiveMode Of
  mmInactive : Begin
                vMassiveBuffer.ClearAll;
                vMassiveLine.ClearAll;
                vMassiveFields.ClearAll;
               End;
  mmBrowse   : Begin
                vMassiveLine.ClearAll;
               End;
  Else
   BuildLine(Dataset, MassiveMode, vMassiveLine);
 End;
End;

Procedure TMassiveDatasetBuffer.BuildDataset(Dataset         : TRESTDWClientSQLBase;
                                             UpdateTableName : String);
Var
 I : Integer;
 MassiveField : TMassiveField;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 For I := 0 To Dataset.Fields.Count -1 Do
  Begin
   If Dataset.Fields[I].FieldKind = fkData Then
    Begin
     MassiveField             := TMassiveField.Create;
     MassiveField.vRequired   := Dataset.Fields[I].Required;
     MassiveField.vKeyField   := pfInKey in Dataset.Fields[I].ProviderFlags;
     MassiveField.vFieldsName := Dataset.Fields[I].FieldName;
     MassiveField.vFieldType  := FieldTypeToObjectValue(Dataset.Fields[I].DataType);
     MassiveField.vSize       := Dataset.Fields[I].DataSize;
     vMassiveFields.Add(MassiveField);
    End;
  End;
 If vMassiveFields.Count > 0 Then
  vMassiveLine.vMassiveMode := mmBrowse;
 vTableName := UpdateTableName;
End;

Procedure TMassiveDatasetBuffer.ClearBuffer;
Begin
 vMassiveBuffer.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearLine;
Begin
 vMassiveLine.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearDataset;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
End;

Constructor TMassiveDatasetBuffer.Create;
Begin
 vRecNo         := -1;
 vMassiveBuffer := TMassiveBuffer.Create;
 vMassiveLine   := TMassiveLine.Create;
 vMassiveFields := TMassiveFields.Create;
 vMassiveMode   := mmInactive;
 vTableName     := '';
End;

Destructor TMassiveDatasetBuffer.Destroy;
Begin
 FreeAndNil(vMassiveBuffer);
 FreeAndNil(vMassiveLine);
 FreeAndNil(vMassiveFields);
 Inherited;
End;

Procedure TMassiveDatasetBuffer.First;
Begin
 If RecordCount > 0 Then
  Begin
   vRecNo := 0;
   ReadBuffer;
  End;
End;

Procedure TMassiveDatasetBuffer.FromJSON(Value: String);
Begin

End;

Procedure TMassiveDatasetBuffer.Last;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo <> (RecordCount -1) Then
    Begin
     vRecNo := RecordCount -1;
     ReadBuffer;
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.Next;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo < (RecordCount -1) Then
    Begin
     Inc(vRecNo);
     ReadBuffer;
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.Prior;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo > 0 Then
    Begin
     Dec(vRecNo);
     ReadBuffer;
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.ReadBuffer;
Begin

End;

Function TMassiveDatasetBuffer.RecNo : Integer;
Begin
 Result := vRecNo;
End;

Function TMassiveDatasetBuffer.RecordCount : Integer;
Begin
 Result := vMassiveBuffer.Count -1;
End;

Procedure TMassiveDatasetBuffer.SaveBuffer(Dataset : TRESTDWClientSQLBase);
Begin

End;

Function TMassiveDatasetBuffer.ToJSON : String;
Begin

End;

End.
