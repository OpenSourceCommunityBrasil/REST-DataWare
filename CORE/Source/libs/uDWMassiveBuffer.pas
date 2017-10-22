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
  Function    GetValue       : String;
  Procedure   SetValue(Value : String);
 Protected
 Public
  Constructor Create;
  Destructor  Free;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Value          : String  Read GetValue Write SetValue;
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
  Function    GetValue       : String;
  Procedure   SetValue(Value : String);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Required   : Boolean      Read vRequired   Write vRequired;
  Property    KeyField   : Boolean      Read vKeyField   Write vKeyField;
  Property    FieldType  : TObjectValue Read vFieldType  Write vFieldType;
  Property    FieldsName : String       Read vFieldsName Write vFieldsName;
  Property    Size       : Integer      Read vSize       Write vSize;
  Property    Precision  : Integer      Read vPrecision  Write vPrecision;
  Property    Value      : String       Read GetValue    Write SetValue;
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
  Procedure NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                          MassiveModeData : TMassiveMode);
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Function  RecNo       : Integer;
  Function  RecordCount : Integer;
  Procedure First;
  Procedure Prior;
  Procedure Next;
  Procedure Last;
  Procedure NewBuffer   (Var MassiveLineBuff : TMassiveLine;
                         MassiveModeData     : TMassiveMode); Overload;
  Procedure NewBuffer   (MassiveModeData     : TMassiveMode); Overload;
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

Destructor TMassiveField.Destroy;
Begin
 {
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   FreeAndNil(vJSONValue^);
 }
 vJSONValue := Nil;
 Inherited;
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

Procedure TMassiveField.SetValue(Value: String);
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   vJSONValue^.Value := Value;
End;

Function TMassiveField.GetValue : String;
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

Procedure TMassiveDatasetBuffer.NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                                              MassiveModeData : TMassiveMode);
Var
 I            : Integer;
 MassiveValue : TMassiveValue;
 vresult      : String;
Begin
 For I := 0 To vMassiveFields.Count Do
  Begin
   MassiveValue       := TMassiveValue.Create;
   If I = 0 Then
    MassiveValue.Value := MassiveModeToString(MassiveModeData);
   MassiveLineBuff.vMassiveValues.Add(MassiveValue);
   If I > 0 Then
    If vMassiveFields.FieldByName(vMassiveFields.Items[I-1].FieldsName) <> Nil Then
     vMassiveFields.FieldByName(vMassiveFields.Items[I-1].FieldsName).vJSONValue := @MassiveValue;
  End;
End;

Procedure TMassiveDatasetBuffer.BuildLine(Dataset             : TRESTDWClientSQLBase;
                                          MassiveModeBuff     : TMassiveMode;
                                          Var MassiveLineBuff : TMassiveLine);
 Procedure CopyValue(MassiveModeBuff : TMassiveMode);
 Var
  I             : Integer;
  Field         : TField;
  vStringStream : TMemoryStream;
 Begin
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    Field := Dataset.FindField(vMassiveFields.Items[I].vFieldsName);
    If Field <> Nil Then
     Begin
      If MassiveModeBuff = mmDelete Then
       If Not(pfInKey in Field.ProviderFlags) Then
        Continue;
      Case Field.DataType Of
       {$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
       ftString,    ftWideString : Begin
                                    If Trim(Field.AsString) <> '' Then
                                     Begin
                                      If Field.Size > 0 Then
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Copy(Field.AsString, 1, Field.Size)
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                     End;
                                   End;
       ftInteger, ftSmallInt,
       ftWord, ftLongWord        : Begin
                                    If Trim(Field.AsString) <> '' Then
                                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString);
                                   End;
       ftFloat,
       ftCurrency, ftBCD         : Begin
                                    If Trim(Field.AsString) <> '' Then
                                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := FloatToStr(Field.AsCurrency);
                                   End;
       ftDate, ftTime,
       ftDateTime, ftTimeStamp   : Begin
                                    If Trim(Field.AsString) <> '' Then
                                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                   End;
       ftBytes, ftVarBytes,
       ftBlob, ftGraphic,
       ftOraBlob, ftOraClob      : Begin
                                    vStringStream := TMemoryStream.Create;
                                    Try
                                     TBlobField(Field).SaveToStream(vStringStream);
                                     vStringStream.Position := 0;
                                     MassiveLineBuff.vMassiveValues.Items[I + 1].LoadFromStream(vStringStream);
                                    Finally
                                     FreeAndNil(vStringStream);
                                    End;
                                   End;
       Else
        Begin
         If Trim(Field.AsString) <> '' Then
          MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
        End;
      End;
     End;
   End;
 End;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeBuff;
 Case MassiveModeBuff Of
  mmInsert : CopyValue(MassiveModeBuff);
  mmUpdate : Begin
              NewBuffer(MassiveModeBuff);
              CopyValue(MassiveModeBuff);
             End;
  mmDelete : Begin
              NewBuffer(MassiveModeBuff);
              CopyValue(MassiveModeBuff);
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
  mmBrowse   : vMassiveLine.ClearAll;
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
   If (Dataset.Fields[I].FieldKind = fkData) And (Not(Dataset.Fields[I].ReadOnly)) Then
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

Procedure TMassiveDatasetBuffer.NewBuffer(Var MassiveLineBuff : TMassiveLine;
                                          MassiveModeData     : TMassiveMode);
Begin
 MassiveLineBuff.ClearAll;
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 NewLineBuffer(MassiveLineBuff, MassiveModeData); //Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.NewBuffer(MassiveModeData     : TMassiveMode);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 NewLineBuffer(vMassiveLine, MassiveModeData); //Sempre se assume mmInsert como padrão
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
Var
 I             : Integer;
 Field         : TField;
 vStringStream : TMemoryStream;
 MassiveLine   : TMassiveLine;
 vresult       : String;
Begin
 MassiveLine   := TMassiveLine.Create;
 NewBuffer(MassiveLine, vMassiveLine.vMassiveMode);
 Try
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If I = 0 Then
     MassiveLine.vMassiveValues.Items[I].Value := vMassiveLine.vMassiveValues.Items[I].Value;
    Field := Dataset.FindField(vMassiveFields.Items[I].vFieldsName);
    If vMassiveLine.vMassiveMode = mmDelete Then
     If Not(pfInKey in Field.ProviderFlags) Then
      Continue;
    If Field <> Nil Then
     Begin
      If Field.DataType  In [ftBytes, ftVarBytes,
                             ftBlob, ftGraphic,
                             ftOraBlob, ftOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         vMassiveLine.vMassiveValues.Items[I +1].SaveToStream(vStringStream);
         vStringStream.Position := 0;
         MassiveLine.vMassiveValues.Items[I +1].LoadFromStream(vStringStream);
        Finally
         FreeAndNil(vStringStream);
        End;
       End
      Else
       Begin
        If vMassiveLine.vMassiveValues.Items[I +1].Value <> '' Then
         MassiveLine.vMassiveValues.Items[I +1].Value := vMassiveLine.vMassiveValues.Items[I +1].Value;
       End;
     End;
   End;
 Finally
  vMassiveBuffer.Add(MassiveLine);
  vMassiveLine.ClearAll;
 End;
End;

Function TMassiveDatasetBuffer.ToJSON : String;
Begin

End;

End.
