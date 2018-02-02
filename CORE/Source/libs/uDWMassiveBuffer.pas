unit uDWMassiveBuffer;

{$I uRESTDW.inc}

interface

uses SysUtils,       Classes,
     DB,             uRESTDWBase,  uDWConsts,
     uDWConstsData,  uDWJSONTools, udwjson {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            {$IFDEF POSIX}
                                            {$IF Defined(ANDROID) or Defined(IOS)} //Alterado para IOS Brito
                                            ,system.json
                                            {$else}
                                            ,system.json
                                            {$IFEND}
                                            {$ENDIF}
                                            {$IFEND}
                                            {$ENDIF}, uDWJSONObject;



Type
 TMassiveValue = Class
 Private
  vBinary     : Boolean;
  vJSONValue  : TJSONValue;
  Function    GetValue       : String;
  Procedure   SetValue(Value : String);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Value          : String  Read GetValue Write SetValue;
  Property    Binary         : Boolean Read vBinary  Write vBinary;
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
  vMassiveFields : TList;
  vAutoGenerateValue,
  vRequired,
  vKeyField   : Boolean;
  vFieldName  : String;
  vFieldType  : TObjectValue;
  vFieldIndex,
  vSize,
  vPrecision  : Integer;
  Function    GetValue       : String;
  Procedure   SetValue(Value : String);
 Protected
 Public
  Constructor Create(MassiveFields : TList; FieldIndex : Integer);
  Destructor  Destroy;Override;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Required          : Boolean      Read vRequired          Write vRequired;
  Property    AutoGenerateValue : Boolean      Read vAutoGenerateValue Write vAutoGenerateValue;
  Property    KeyField          : Boolean      Read vKeyField          Write vKeyField;
  Property    FieldType         : TObjectValue Read vFieldType         Write vFieldType;
  Property    FieldName         : String       Read vFieldName         Write vFieldName;
  Property    Size              : Integer      Read vSize              Write vSize;
  Property    Precision         : Integer      Read vPrecision         Write vPrecision;
  Property    Value             : String       Read GetValue           Write SetValue;
End;

Type
 PMassiveField  = ^TMassiveField;
 TMassiveFields = Class(TList)
 Private
  vMassiveDataset : TMassiveDataset;
  Function   GetRec(Index : Integer)       : TMassiveField;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveField); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Constructor Create(MassiveDataset : TMassiveDataset);
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
  vPrimaryValues  : TMassiveValues;
  vMassiveMode    : TMassiveMode;
  vChanges        : TStringList;
  Function   GetRec  (Index : Integer)       : TMassiveValue;
  Procedure  PutRec  (Index : Integer; Item  : TMassiveValue);
  Function   GetRecPK(Index : Integer)       : TMassiveValue;
  Procedure  PutRecPK(Index : Integer; Item  : TMassiveValue);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   ClearAll;
  Property    MassiveMode                     : TMassiveMode   Read vMassiveMode Write vMassiveMode;
  Property    UpdateFieldChanges              : TStringList    Read vChanges     Write vChanges;
  Property    Values       [Index  : Integer] : TMassiveValue  Read GetRec       Write PutRec;
  Property    PrimaryValues[Index  : Integer] : TMassiveValue  Read GetRecPK     Write PutRecPK;
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
  vDataset       : TRESTDWClientSQLBase;
  vRecNo         : Integer;
  vMassiveBuffer : TMassiveBuffer;
  vMassiveLine   : TMassiveLine;
  vMassiveFields : TMassiveFields;
  vMassiveMode   : TMassiveMode;
  vTableName     : String;
 Private
  Procedure ReadStatus;
  Procedure NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                          MassiveModeData     : TMassiveMode);
 Public
  Constructor Create(Dataset : TRESTDWClientSQLBase);
  Destructor  Destroy;Override;
  Function  RecNo       : Integer;
  Function  RecordCount : Integer;
  Procedure First;
  Procedure Prior;
  Procedure Next;
  Procedure Last;
  Property  TempBuffer  : TMassiveLine     Read vMassiveLine;
  Function  PrimaryKeys : TStringList;
  Function  AtualRec    : TMassiveLine;
  Procedure NewBuffer   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeData      : TMassiveMode); Overload;
  Procedure NewBuffer   (Var MassiveLineBuff  : TMassiveLine;
                         MassiveModeData      : TMassiveMode); Overload;
  Procedure NewBuffer   (MassiveModeData      : TMassiveMode); Overload;
  Procedure BuildDataset(Dataset              : TRESTDWClientSQLBase;
                         UpdateTableName      : String);                 //Constroi o Dataset Massivo
  Procedure BuildLine   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeBuff      : TMassiveMode;
                         Var MassiveLineBuff  : TMassiveLine;
                         UpdateTag            : Boolean = False);
  Procedure BuildBuffer (Dataset              : TRESTDWClientSQLBase;    //Cria um Valor Massivo Baseado nos Dados de Um Dataset
                         MassiveMode          : TMassiveMode;
                         UpdateTag            : Boolean = False);
  Procedure SaveBuffer  (Dataset              : TRESTDWClientSQLBase);   //Salva Um Buffer Massivo na Lista de Massivos
  Procedure ClearBuffer;                                                //Limpa o Buffer Massivo Atual
  Procedure ClearDataset;                                               //Limpa Todo o Dataset Massivo
  Procedure ClearLine;                                                  //Limpa o Buffer Temporario
  Function  ToJSON      : String;                                       //Gera o JSON do Dataset Massivo
  Procedure FromJSON    (Value : String);                               //Carrega o Dataset Massivo a partir de um JSON
  Property  MassiveMode : TMassiveMode   Read vMassiveMode;             //Modo Massivo do Buffer Atual
  Property  Fields      : TMassiveFields Read vMassiveFields Write vMassiveFields;
  Property  TableName   : String         Read vTableName;
 End;

Type
 TDWMassiveCacheValue = String;

Type
 PMassiveCacheValue  = ^TDWMassiveCacheValue;
 TDWMassiveCacheList = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TDWMassiveCacheValue;     Overload;
  Procedure  PutRec(Index : Integer; Item  : TDWMassiveCacheValue);    Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                Overload;
  Function   Add   (Item  : TDWMassiveCacheValue) : Integer;           Overload;
  Property   Items[Index  : Integer]            : TDWMassiveCacheValue Read GetRec Write PutRec; Default;
End;

Type
 TDWMassiveCache = Class(TComponent)
 Private
  MassiveCacheList : TDWMassiveCacheList;
 Public
  Function    MassiveCount   : Integer;
  Function    ToJSON         : String;
  Procedure   Add(Value : String);
  Procedure   Clear;
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
End;

Type
 TDWMassiveCacheSQLValue = Class
  MassiveSQLMode : TMassiveSQLMode;
  SQL            : String;
  Params         : TDWParams;
End;

Type
 PMassiveCacheSQLValue  = ^TDWMassiveCacheSQLValue;
 TDWMassiveCacheSQLList = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TDWMassiveCacheSQLValue;     Overload;
  Procedure  PutRec(Index : Integer; Item  : TDWMassiveCacheSQLValue);    Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                     Overload;
  Function   Add   (Item  : TDWMassiveCacheSQLValue) : Integer;           Overload;
  Property   Items[Index  : Integer]            : TDWMassiveCacheSQLValue Read GetRec Write PutRec; Default;
End;

Type
 TDWMassiveSQLCache = Class(TComponent)
 Private
  MassiveCacheSQLList : TDWMassiveCacheSQLList;
//  Procedure   Add(Value      : TDWMassiveCacheSQLValue);
 Public
  Function    MassiveCount   : Integer;
  Function    ToJSON         : String;
  Procedure   Clear;
  Procedure   AddDataset(Dataset : TDataset);
  Constructor Create    (AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
End;

implementation

Uses uRESTDWPoolerDB, uDWPoolerMethod;


Function removestr(Astr: string; Asubstr: string):string;
Begin
 result:= stringreplace(Astr,Asubstr,'',[rfReplaceAll, rfIgnoreCase]);
End;

{ TMassiveField }

Constructor TMassiveField.Create(MassiveFields : TList; FieldIndex : Integer);
Begin
 vRequired          := False;
 vAutoGenerateValue := False;
 vKeyField          := vRequired;
 vFieldType         := ovUnknown;
 vFieldName         := '';
 vMassiveFields     := MassiveFields;
 vFieldIndex        := FieldIndex;
End;

Destructor TMassiveField.Destroy;
Begin
 Inherited;
End;

Procedure TMassiveField.LoadFromStream(Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].LoadFromStream(Stream);
  End;
End;

Procedure TMassiveField.SaveToStream(Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].SaveToStream(Stream);
  End;
End;

Procedure TMassiveField.SetValue(Value: String);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value := Value;
  End;
End;

Function TMassiveField.GetValue : String;
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value;
  End;
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

Constructor TMassiveFields.Create(MassiveDataset: TMassiveDataset);
Begin
 Inherited Create;
 vMassiveDataset := MassiveDataset;
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
   If LowerCase(TMassiveField(TList(Self).Items[I]^).vFieldName) =
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
 vBinary    := False;
 vJSONValue := udwjsonobject.TJSONValue.Create;
End;

Destructor TMassiveValue.Destroy;
Begin
 FreeAndNil(vJSONValue);
 Inherited;
End;

Function TMassiveValue.GetValue: String;
Begin
 Result := vJSONValue.Value;
End;

Procedure TMassiveValue.LoadFromStream(Stream: TMemoryStream);
Begin
 vBinary := True;
 vJSONValue.LoadFromStream(Stream);
End;

Procedure TMassiveValue.SaveToStream(Stream: TMemoryStream);
Begin
 vJSONValue.ObjectValue := ovBlob;
 vJSONValue.Encoded     := True;
 vJSONValue.SaveToStream(Stream, True);
End;

Procedure TMassiveValue.SetValue(Value: String);
Begin
 If vJSONValue <> Nil Then
  Begin
   vJSONValue.Binary  := vBinary;
   If vJSONValue.Binary Then
    Begin
     vJSONValue.ObjectValue := ovBlob;
     vJSONValue.SetValue(Value, False);
     vJSONValue.Encoded := True;
    End
   Else
    vJSONValue.SetValue(Value);
  End;
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
 vChanges        := TStringList.Create;
End;

Destructor TMassiveLine.Destroy;
Begin
 FreeAndNil(vMassiveValues);
 FreeAndNil(vChanges);
 If Assigned(vPrimaryValues) Then
  FreeAndNil(vPrimaryValues);
 Inherited;
End;

Function TMassiveLine.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(vMassiveValues).Items[Index]^);
End;

Function TMassiveLine.GetRecPK(Index : Integer) : TMassiveValue;
Begin
 Result := Nil;
 If vPrimaryValues <> Nil Then
  If (Index < vPrimaryValues.Count) And (Index > -1) Then
   Result := TMassiveValue(TList(vPrimaryValues).Items[Index]^);
End;

Procedure TMassiveLine.ClearAll;
Begin
 vMassiveValues.ClearAll;
 If Assigned(vPrimaryValues) Then
  vPrimaryValues.ClearAll;
 If Assigned(vChanges)       Then
  vChanges.Clear;
End;

Procedure TMassiveLine.PutRec(Index: Integer;   Item : TMassiveValue);
Begin
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  TMassiveValue(TList(vMassiveValues).Items[Index]^) := Item;
End;

Procedure TMassiveLine.PutRecPK(Index: Integer; Item : TMassiveValue);
Begin
 If (Index < vPrimaryValues.Count) And (Index > -1) Then
  TMassiveValue(TList(vPrimaryValues).Items[Index]^) := Item;
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
                                              MassiveModeData     : TMassiveMode);
Var
 I            : Integer;
 MassiveValue : TMassiveValue;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 For I := 0 To vMassiveFields.Count Do
  Begin
   MassiveValue       := TMassiveValue.Create;
   If I = 0 Then
    MassiveValue.Value := MassiveModeToString(MassiveModeData);
   MassiveLineBuff.vMassiveValues.Add(MassiveValue);
  End;
End;

Procedure TMassiveDatasetBuffer.BuildLine(Dataset             : TRESTDWClientSQLBase;
                                          MassiveModeBuff     : TMassiveMode;
                                          Var MassiveLineBuff : TMassiveLine;
                                          UpdateTag           : Boolean = False);
 Procedure CopyValue(MassiveModeBuff : TMassiveMode);
 Var
  I             : Integer;
  Field         : TField;
  vStringStream : TMemoryStream;
  vUpdateCase   : Boolean;
  MassiveValue  : TMassiveValue;
 Begin
  vUpdateCase := False;
  //KeyValues to Update
  If MassiveModeBuff = mmUpdate Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues = Nil;
  If MassiveLineBuff.vPrimaryValues <> Nil Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues.Count = 0;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
    If Field <> Nil Then
     Begin
      If (Field.ProviderFlags = []) Or (Field.ReadOnly) Then
       Continue;
      If MassiveModeBuff = mmDelete Then
       If Not(pfInKey in Field.ProviderFlags) Then
        Continue;
      //KeyValues to Update
      If (MassiveModeBuff = mmUpdate)      And
         (vUpdateCase)                     Then
       If (pfInKey in Field.ProviderFlags) Then
        Begin
         If MassiveLineBuff.vPrimaryValues = Nil Then
          MassiveLineBuff.vPrimaryValues := TMassiveValues.Create;
         If vUpdateCase Then
          Begin
           MassiveValue  := TMassiveValue.Create;
           If Field.DataType in [ftBytes, ftVarBytes,
                                 ftBlob, ftGraphic,
                                 ftMemo, {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            ftWideMemo,
                                            {$IFEND}
                                         {$ENDIF}
                                 ftOraBlob, ftOraClob] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              If Not Field.IsNull Then
               Begin
                TBlobField(Field).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                MassiveValue.LoadFromStream(vStringStream);
                MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
               End
              Else
               MassiveValue.Value := '';
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else
            Begin
             If Trim(Field.AsString) <> '' Then
              MassiveValue.Value := Field.AsString;
            End;
           MassiveLineBuff.vPrimaryValues.Add(MassiveValue);
          End;
        End;
      Case Field.DataType Of
       {$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
       ftFixedChar, ftFixedWideChar,
       {$IFEND}{$ENDIF}
       ftString,    ftWideString : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       Begin
                                        If Field.Size > 0 Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Copy(Field.AsString, 1, Field.Size)
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                       End
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftInteger, ftSmallInt,
       ftWord,    ftLargeint
       {$IFNDEF FPC}{$if CompilerVersion > 21}, ftLongWord{$IFEND}{$ENDIF}
                                 : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString)
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString);
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftFloat,
       ftCurrency, ftBCD{$IFNDEF FPC}
                        {$IF CompilerVersion > 21}
                        , ftSingle
                        {$IFEND}
                        {$ENDIF} : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := BuildStringFloat(FloatToStr(Field.AsCurrency))
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        If Trim(Field.AsString) <> '' Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := BuildStringFloat(FloatToStr(Field.AsCurrency))
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftDate, ftTime,
       ftDateTime, ftTimeStamp   : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := IntToStr(DateTimeToUnix(Field.AsDateTime))
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        If Trim(Field.AsString) <> '' Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := IntToStr(DateTimeToUnix(Field.AsDateTime))
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftBytes, ftVarBytes,
       ftBlob, ftGraphic,
       ftMemo, {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            ftWideMemo,
                                            {$IFEND}
                                         {$ENDIF}
       ftOraBlob, ftOraClob      : Begin
                                    vStringStream := TMemoryStream.Create;
                                    Try
                                     If Not Field.IsNull Then
                                      Begin
                                       TBlobField(Field).SaveToStream(vStringStream);
                                       vStringStream.Position := 0;
                                       If Not UpdateTag Then
                                        MassiveLineBuff.vMassiveValues.Items[I + 1].LoadFromStream(vStringStream)
                                       Else
                                        Begin
                                         If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> StreamToHex(vStringStream) Then
                                          Begin
                                           MassiveLineBuff.vMassiveValues.Items[I + 1].LoadFromStream(vStringStream);
                                           MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                          End;
                                        End;
                                      End
                                     Else If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> '' Then
                                      Begin
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                       MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                      End;
                                    Finally
                                     FreeAndNil(vStringStream);
                                    End;
                                   End;
       Else
        Begin
         If Not UpdateTag Then
          MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString
         Else
          Begin
           If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
            Begin
             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
             MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
            End;
          End;
        End;
      End;
     End;
   End;
 End;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeBuff;
 Case MassiveModeBuff Of
  mmInsert : CopyValue(MassiveModeBuff);
  mmUpdate : CopyValue(MassiveModeBuff);
  mmDelete : Begin
              NewBuffer(MassiveModeBuff);
              CopyValue(MassiveModeBuff);
             End;
 End;
End;

Function TMassiveDatasetBuffer.AtualRec : TMassiveLine;
Begin
 Result := Nil;
 If RecordCount > 0 Then
  Result := vMassiveBuffer.Items[vRecNo -1];
End;

Procedure TMassiveDatasetBuffer.BuildBuffer(Dataset     : TRESTDWClientSQLBase;
                                            MassiveMode : TMassiveMode;
                                            UpdateTag   : Boolean = False);
Begin
 Case MassiveMode Of
  mmInactive : Begin
                vMassiveBuffer.ClearAll;
                vMassiveLine.ClearAll;
                vMassiveFields.ClearAll;
               End;
  mmBrowse   : vMassiveLine.ClearAll;
  Else
   BuildLine(Dataset, MassiveMode, vMassiveLine, UpdateTag);
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
   If (Dataset.Fields[I].FieldKind = fkData) And (Not(Dataset.Fields[I].ReadOnly)) And
      ((pfInUpdate in Dataset.Fields[I].ProviderFlags)  Or
       (pfInWhere  in Dataset.Fields[I].ProviderFlags)  Or
       (pfInKey    in Dataset.Fields[I].ProviderFlags)) Then
    Begin
     MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
     MassiveField.vRequired          := Dataset.Fields[I].Required;
     MassiveField.vKeyField          := pfInKey in Dataset.Fields[I].ProviderFlags;
     MassiveField.vFieldName         := Dataset.Fields[I].FieldName;
     MassiveField.vFieldType         := FieldTypeToObjectValue(Dataset.Fields[I].DataType);
     MassiveField.vSize              := Dataset.Fields[I].DataSize;
     {$IFNDEF FPC}{$IF CompilerVersion > 21}
     MassiveField.vAutoGenerateValue := Dataset.Fields[I].AutoGenerateValue = arAutoInc;
     If Not (MassiveField.vAutoGenerateValue) Then
      MassiveField.vAutoGenerateValue := Dataset.Fields[I].FieldKind = fkInternalCalc;
     {$ELSE}
     MassiveField.vAutoGenerateValue := Dataset.Fields[I].FieldKind = fkInternalCalc;
     {$IFEND}
     {$ELSE}
     MassiveField.vAutoGenerateValue := Dataset.Fields[I].FieldKind = fkInternalCalc;
     {$ENDIF}
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

Constructor TMassiveDatasetBuffer.Create(Dataset : TRESTDWClientSQLBase);
Begin
 vDataset       := Dataset;
 vRecNo         := -1;
 vMassiveBuffer := TMassiveBuffer.Create;
 vMassiveLine   := TMassiveLine.Create;
 vMassiveFields := TMassiveFields.Create(Self);
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
   vRecNo := 1;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.Last;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo <> RecordCount Then
    vRecNo := RecordCount;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Var MassiveLineBuff : TMassiveLine;
                                          MassiveModeData     : TMassiveMode);
Begin
 MassiveLineBuff.ClearAll;
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 NewLineBuffer(MassiveLineBuff, MassiveModeData); //Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Dataset         : TRESTDWClientSQLBase;
                                          MassiveModeData : TMassiveMode);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 NewLineBuffer(vMassiveLine, MassiveModeData); //Sempre se assume mmInsert como padrão
 //BuildLine(Dataset, MassiveModeData, vMassiveLine);//Sempre se assume mmInsert como padrão
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
   If vRecNo < RecordCount Then
    Inc(vRecNo);
   ReadStatus;
  End;
End;

Function TMassiveDatasetBuffer.PrimaryKeys : TStringList;
Var
 I : Integer;
Begin
 Result := TStringList.Create;
 If vMassiveFields <> Nil Then
  Begin
   For I := 0 To vMassiveFields.Count -1 Do
    Begin
     If vMassiveFields.Items[I].vKeyField Then
      Result.Add(vMassiveFields.Items[I].vFieldName);
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.Prior;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo > 1 Then
    Dec(vRecNo);
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.ReadStatus;
Begin
 If RecordCount > 0 Then
  vMassiveMode := StringToMassiveMode(vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[0].Value)
 Else
  vMassiveMode := mmInactive;
End;

Function TMassiveDatasetBuffer.RecNo : Integer;
Begin
 Result := vRecNo;
End;

Function TMassiveDatasetBuffer.RecordCount : Integer;
Begin
 Result := 0;
 If vMassiveBuffer <> Nil Then
  Result := vMassiveBuffer.Count;
End;

Procedure TMassiveDatasetBuffer.SaveBuffer(Dataset : TRESTDWClientSQLBase);
Var
 I, A          : Integer;
 Field         : TField;
 vStringStream : TMemoryStream;
 MassiveLine   : TMassiveLine;
 MassiveValue  : TMassiveValue;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
Begin
 MassiveLine   := TMassiveLine.Create;
 NewBuffer(MassiveLine, vMassiveLine.vMassiveMode);
 Try
  If vMassiveLine.vMassiveMode = mmUpdate Then
   Begin
    For I := 0 To vMassiveLine.vChanges.Count -1 Do
     Begin
      Field := Dataset.FindField(vMassiveLine.vChanges[I]);
      If Field <> Nil Then
       Begin
        If Field.DataType  In [ftBytes, ftVarBytes,
                               ftBlob, ftGraphic,
                               ftMemo, {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            ftWideMemo,
                                            {$IFEND}
                                         {$ENDIF}
                               ftOraBlob, ftOraClob] Then
         Begin
          vStringStream := TMemoryStream.Create;
          Try
           vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].SaveToStream(vStringStream);
           vStringStream.Position := 0;
           If vStringStream.Size > 0 Then
            MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].LoadFromStream(vStringStream);
          Finally
           FreeAndNil(vStringStream);
          End;
         End
        Else
         MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value;
       End;
     End;
   End
  Else
   Begin
    For I := 0 To vMassiveFields.Count -1 Do
     Begin
      If I = 0 Then
       MassiveLine.vMassiveValues.Items[I].Value := vMassiveLine.vMassiveValues.Items[I].Value;
      Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
      If vMassiveLine.vMassiveMode = mmDelete Then
       If Not(pfInKey in Field.ProviderFlags) Then
        Continue;
      If Field <> Nil Then
       Begin
        If Field.DataType  In [ftBytes, ftVarBytes,
                               ftBlob, ftGraphic,
                               ftMemo, {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            ftWideMemo,
                                            {$IFEND}
                                         {$ENDIF}
                               ftOraBlob, ftOraClob] Then
         Begin
          vStringStream := TMemoryStream.Create;
          Try
           vMassiveLine.vMassiveValues.Items[I +1].SaveToStream(vStringStream);
           vStringStream.Position := 0;
           If vStringStream.Size > 0 Then
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
   End;
 Finally
  //Update Changes
  For A := 0 To vMassiveLine.vChanges.Count -1 do
   MassiveLine.vChanges.Add(vMassiveLine.vChanges[A]);
  //KeyValues to Update
  If vMassiveLine.vPrimaryValues <> Nil Then
   Begin
    If vMassiveLine.vPrimaryValues.Count > 0 Then
     Begin
      If MassiveLine.vPrimaryValues = Nil Then
       MassiveLine.vPrimaryValues := TMassiveValues.Create;
      For A := 0 To vMassiveLine.vPrimaryValues.Count -1 do
       Begin
        MassiveValue  := TMassiveValue.Create;
        MassiveValue.Value := vMassiveLine.vPrimaryValues.Items[A].Value;
        MassiveLine.vPrimaryValues.Add(MassiveValue);
       End;
     End;
   End;
  vMassiveBuffer.Add(MassiveLine);
  vMassiveLine.ClearAll;
 End;
End;

Procedure TMassiveDatasetBuffer.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonValue  : {$IFDEF POSIX}system.json.TJsonObject; {$ELSE} udwjson.TJsonObject;{$ENDIF}
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC,
 bJsonArrayD,
 bJsonArrayE  : {$IFDEF POSIX}system.json.TJsonArray; {$ELSE} udwjson.TJsonArray;{$ENDIF}
 MassiveValue : TMassiveValue;
 A, C,
 D, E, I      : Integer;
 MassiveField : TMassiveField;
 MassiveLine  : TMassiveLine;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
Begin
 {$IFDEF POSIX}
  bJsonValue:= system.json.TJsonObject.ParseJSONValue(TEncoding.utf8.GetBytes(Value),0) as system.json.TJsonObject;
 {$ELSE}
  bJsonValue := udwjson.TJsonObject.Create(Value);
 {$ENDIF}
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 Try
   {$IFDEF POSIX}
    vTableName  := removestr(bJsonValue.pairs[4].JsonValue.tostring,'"');  //opt(bJsonValue.names.get(4).ToString).ToString;
    bJsonArray  := bJsonValue.pairs[5].JsonValue as tjsonarray; //  bJsonValue.optJSONArray(bJsonValue.names.get(5).ToString);
   {$ELSE}
    vTableName  := bJsonValue.opt(bJsonValue.names.get(4).ToString).ToString;
    bJsonArray  := bJsonValue.optJSONArray(bJsonValue.names.get(5).ToString);
   {$ENDIF}
  For A := 0 To 1 Do
   Begin
    If A = 0 Then //Fields
     Begin
       {$IFDEF POSIX}
        bJsonOBJ    := bJsonArray.Items[A] as Tjsonobject; //udwjson.TJsonObject.Create(bJsonArray.get(A).ToString); //bJsonOBJ.names.get(0).ToString);
       {$ELSE}
        bJsonOBJ    := udwjson.TJsonObject.Create(bJsonArray.get(A).ToString); //bJsonOBJ.names.get(0).ToString);
       {$ENDIF}

      Try
        {$IFDEF POSIX}
        bJsonArrayB := bJsonOBJ.get('fields').JsonValue as Tjsonarray;
        For I := 0 To bJsonArrayB.count - 1 Do
         Begin
          bJsonOBJb :=  bJsonArrayB.items[I] as Tjsonobject; // udwjson.TJsonObject.Create(bJsonArrayB.get(I).ToString);
          Try
           MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
           MassiveField.vRequired          := removestr(bJsonOBJb.get('Required').JsonValue.tostring,'"')      = 'S';
           MassiveField.vKeyField          := removestr(bJsonOBJb.get('Primary').JsonValue.tostring,'"')       = 'S';
           MassiveField.vFieldName         := removestr(bJsonOBJb.get('Field').JsonValue.tostring,'"');
           MassiveField.vFieldType         := GetValueType(removestr(bJsonOBJb.get('Type').JsonValue.tostring,'"'));
           MassiveField.vSize              := StrToInt(removestr(bJsonOBJb.get('Size').JsonValue.tostring,'"'));
           MassiveField.vAutoGenerateValue := removestr(bJsonOBJb.get('Autogeneration').JsonValue.tostring,'"') = 'S';
           vMassiveFields.Add(MassiveField);
          Finally
           //bJsonOBJb.Clean;
           FreeAndNil(bJsonOBJb);
          End;
         End;
        {$ELSE}
       bJsonArrayB := bJsonOBJ.optJSONArray('fields');
       For I := 0 To bJsonArrayB.Length - 1 Do
        Begin
         bJsonOBJb := udwjson.TJsonObject.Create(bJsonArrayB.get(I).ToString);
         Try
          MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
          MassiveField.vRequired          := bJsonOBJb.opt('Required').ToString       = 'S';
          MassiveField.vKeyField          := bJsonOBJb.opt('Primary').ToString        = 'S';
          MassiveField.vFieldName         := bJsonOBJb.opt('Field').ToString;
          MassiveField.vFieldType         := GetValueType(bJsonOBJb.opt('Type').ToString);
          MassiveField.vSize              := StrToInt(bJsonOBJb.opt('Size').ToString);
          MassiveField.vAutoGenerateValue := bJsonOBJb.opt('Autogeneration').ToString = 'S';
          vMassiveFields.Add(MassiveField);
         Finally
          bJsonOBJb.Clean;
          FreeAndNil(bJsonOBJb);
         End;
        End;
        {$ENDIF}
      Finally
        {$IFDEF POSIX}
         bJsonOBJ:=nil;
        {$ELSE}
         bJsonOBJ.Clean;
         FreeAndNil(bJsonOBJ);
        {$ENDIF}

      End;
     End
    Else //Data
     Begin
       {$IFDEF POSIX}
        bJsonOBJ    := bJsonArray.Items[A] as Tjsonobject; //udwjson.TJsonObject.Create(bJsonArray.get(A).ToString); //bJsonOBJ.names.get(0).ToString);
        bJsonArrayB := bJsonOBJ.get('lines').JsonValue as Tjsonarray;
       {$ELSE}
        bJsonOBJ    := udwjson.TJsonObject.Create(bJsonArray.get(A).ToString); //bJsonOBJ.names.get(0).ToString);
        bJsonArrayB := bJsonOBJ.optJSONArray('lines');
       {$ENDIF}
       {$IFDEF POSIX}
       For E := 0 to bJsonArrayB.count -1  Do
       Begin
        bJsonArrayC := bJsonArrayB.items[E] as tjsonarray; // getJSONArray(E);
        Try
         bJsonArrayD  := bJsonArrayC.items[0] as tjsonarray; // getJSONArray(0); //Line
         vMassiveMode := StringToMassiveMode(removestr(bJsonArrayD.items[0].tostring,'"')); // opt(0).tostring);
         MassiveLine  := TMassiveLine.Create;
         NewLineBuffer(MassiveLine, vMassiveMode); //Sempre se assume MassiveMode vindo na String
         If vMassiveMode = mmUpdate Then
          Begin
           If bJsonArrayD.count> 1 Then
            Begin
             bJsonArrayE  := bJsonArrayC.items[2] as Tjsonarray; // getJSONArray(2); //Campos Alterados
             For D := 0 To bJsonArrayE.count -1 Do //Valores
              MassiveLine.vChanges.Add(removestr(bJsonArrayE.items[D].tostring,'"'));
             bJsonArrayE  :=bJsonArrayC.items[1] as Tjsonarray;  // bJsonArrayC.getJSONArray(1); //Key Primary
             For D := 0 To bJsonArrayE.count -1 Do //Valores
              Begin
               MassiveValue       := TMassiveValue.Create;
               If vMassiveFields.Items[D].vFieldType in [ovString, ovWideString, ovWideMemo,
                                                         ovFixedChar, ovFixedWideChar] Then
                MassiveValue.Value := removestr(bJsonArrayC.items[D].tostring,'"') //bJsonArrayE.opt(D).tostring
               Else
                MassiveValue.Value := removestr(bJsonArrayE.items[D].tostring,'"');
               If Not Assigned(MassiveLine.vPrimaryValues) Then
                MassiveLine.vPrimaryValues := TMassiveValues.Create;
               MassiveLine.vPrimaryValues.Add(MassiveValue);
              End;
            End;
           For C := 1 To bJsonArrayD.count -1 Do //Valores
            Begin
             If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovString, ovWideString, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
              Begin
               If lowercase(removestr(bJsonArrayD.items[C].tostring,'"')) <> 'null' then
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := DecodeStrings(removestr(bJsonArrayD.items[C].tostring,'"'){$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := removestr(bJsonArrayD.items[C].tostring,'"');
              End
             Else
              Begin
               If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovBytes, ovVarBytes, ovBlob,
                                                                                                ovGraphic, ovOraBlob, ovOraClob] Then
                Begin
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Binary := True;
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value  := removestr(bJsonArrayD.items[C].tostring,'"'); //bJsonArrayD.opt(C).tostring;
                End
               Else
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := removestr(bJsonArrayD.items[C].tostring,'"'); //bJsonArrayD.opt(C).tostring;
              End;
            End;
          End
         Else
          Begin
           For C := 1 To bJsonArrayD.count -1 Do //Valores
            Begin
             If vMassiveFields.Items[C-1].vFieldType in [ovString, ovWideString, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
              Begin
               If lowercase(removestr(bJsonArrayD.items[C].tostring,'"')) <> 'null' then
                MassiveLine.Values[C].Value := DecodeStrings(removestr(bJsonArrayD.items[C].tostring,'"'){$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                MassiveLine.Values[C].Value := removestr(bJsonArrayD.items[C].tostring,'"');
              End
             Else
              MassiveLine.Values[C].Value := removestr(bJsonArrayD.items[C].tostring,'"');
            End;
          End;
        Finally
         vMassiveBuffer.Add(MassiveLine);
        End;
       End;
       {$ELSE}
      For E := 0 to bJsonArrayB.length -1  Do
       Begin
        bJsonArrayC := bJsonArrayB.getJSONArray(E);
        Try
         bJsonArrayD  := bJsonArrayC.getJSONArray(0); //Line
         vMassiveMode := StringToMassiveMode(bJsonArrayD.opt(0).tostring);
         MassiveLine  := TMassiveLine.Create;
         NewLineBuffer(MassiveLine, vMassiveMode); //Sempre se assume MassiveMode vindo na String
         If vMassiveMode = mmUpdate Then
          Begin
           If bJsonArrayD.length > 1 Then
            Begin
             bJsonArrayE  := bJsonArrayC.getJSONArray(2); //Campos Alterados
             For D := 0 To bJsonArrayE.length -1 Do //Valores
              MassiveLine.vChanges.Add(bJsonArrayE.opt(D).tostring);
             bJsonArrayE  := bJsonArrayC.getJSONArray(1); //Key Primary
             For D := 0 To bJsonArrayE.length -1 Do //Valores
              Begin
               MassiveValue       := TMassiveValue.Create;
               If vMassiveFields.Items[D].vFieldType in [ovString, ovWideString, ovWideMemo,
                                                         ovFixedChar, ovFixedWideChar] Then
                MassiveValue.Value := bJsonArrayE.opt(D).tostring
               Else
                MassiveValue.Value := bJsonArrayE.opt(D).tostring;
               If Not Assigned(MassiveLine.vPrimaryValues) Then
                MassiveLine.vPrimaryValues := TMassiveValues.Create;
               MassiveLine.vPrimaryValues.Add(MassiveValue);
              End;
            End;
           For C := 1 To bJsonArrayD.length -1 Do //Valores
            Begin
             If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovString, ovWideString, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
              Begin
               If lowercase(bJsonArrayD.opt(C).tostring) <> 'null' then
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := DecodeStrings(bJsonArrayD.opt(C).tostring{$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := bJsonArrayD.opt(C).tostring;
              End
             Else
              Begin
               If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovBytes, ovVarBytes, ovBlob,
                                                                                                ovGraphic, ovOraBlob, ovOraClob] Then
                Begin
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Binary := True;
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value  := bJsonArrayD.opt(C).tostring;
                End
               Else
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := bJsonArrayD.opt(C).tostring;
              End;
            End;
          End
         Else
          Begin
           For C := 1 To bJsonArrayD.length -1 Do //Valores
            Begin
             If vMassiveFields.Items[C-1].vFieldType in [ovString, ovWideString, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
              Begin
               If lowercase(bJsonArrayD.opt(C).tostring) <> 'null' then
                MassiveLine.Values[C].Value := DecodeStrings(bJsonArrayD.opt(C).tostring{$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                MassiveLine.Values[C].Value := bJsonArrayD.opt(C).tostring;
              End
             Else
              MassiveLine.Values[C].Value := bJsonArrayD.opt(C).tostring;
            End;
          End;
        Finally
         vMassiveBuffer.Add(MassiveLine);
        End;
       End;
       {$ENDIF}

      FreeAndNil(bJsonOBJ);
     End;
   End;
 Finally
 {$IFDEF POSIX}
 bJsonValue:=nil;
 {$ELSE}
  bJsonValue.Free;
  {$ENDIF}
 End;
End;

Function TMassiveDatasetBuffer.ToJSON : String;
Var
 A           : Integer;
 vLines,
 vTagFields  : String;
 Function GenerateHeader: String;
 Var
  I              : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc       : string;
 Begin
  For I := 0 To vMassiveFields.Count - 1 Do
   Begin
    If vDataset <> Nil Then
     Begin
      If (vDataset.FieldByName(vMassiveFields.Items[I].vFieldName) <> Nil) Then
       Begin
        If vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).ReadOnly Then
         Continue;
        {$IFNDEF FPC}{$IF CompilerVersion > 21}
        vMassiveFields.Items[I].vAutoGenerateValue := vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).AutoGenerateValue = arAutoInc;
        If Not (vMassiveFields.Items[I].vAutoGenerateValue) Then
         vMassiveFields.Items[I].vAutoGenerateValue := vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc;
        {$ELSE}
        vMassiveFields.Items[I].vAutoGenerateValue := vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc;
        {$IFEND}
        {$ELSE}
        vMassiveFields.Items[I].vAutoGenerateValue := vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc;
        {$ENDIF}
       End;
     End;
    vPrimary  := 'N';
    vAutoinc  := 'N';
    vReadOnly := 'N';
    If vMassiveFields.Items[I].vKeyField Then
     vPrimary := 'S';
    vRequired := 'N';
    If vMassiveFields.Items[I].vRequired Then
     vRequired := 'S';
    If (vMassiveFields.Items[I].vAutoGenerateValue) Or
       (vMassiveFields.Items[I].FieldType = ovAutoInc) Then
     vAutoinc := 'S';
    If vMassiveFields.Items[I].FieldType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ovExtended,
                                             {$IFEND}{$ENDIF}ovFloat, ovCurrency, ovFMTBcd, ovSingle, ovBCD] Then
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size,
                                                  vMassiveFields.Items[I].Precision, vReadOnly, vAutoinc])
    Else
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size, 0, vReadOnly, vAutoinc]);
    If I = 0 Then
     Result := vGenerateLine
    Else
     Result := Result + ', ' + vGenerateLine;
   End;
 End;
 Function GenerateLine(MassiveLineBuff : TMassiveLine) : String;
 Var
  A, I          : Integer;
  vTempLine,
  vTempComp,
  vTempKeys,
  vTempValue    : String;
  vMassiveMode  : TMassiveMode;
  vNoChange     : Boolean;
 Begin
  vMassiveMode := mmInactive;
  For I := 0 To MassiveLineBuff.vMassiveValues.Count - 1 Do
   Begin
    If I = 0 Then
     vMassiveMode  := StringToMassiveMode(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value)
    Else
     Begin
      If vMassiveMode = mmUpdate Then
       Begin
        If MassiveLineBuff.vChanges.Count = 0 Then
         Continue;
        vNoChange := True;
        For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
         Begin
          If vDataset <> Nil Then
           Begin
            If (vDataset.FieldByName(vMassiveFields.Items[I-1].vFieldName) <> Nil) Then
             Begin
              If vDataset.FieldByName(vMassiveFields.Items[I-1].vFieldName).ReadOnly Then
               Continue;
             End;
           End;
          vNoChange := Lowercase(vMassiveFields.Items[I-1].vFieldName) <>
                       Lowercase(MassiveLineBuff.vChanges[A]);
          If Not (vNoChange) Then
           Break;
         End;
        If vNoChange Then
         Continue;
       End;
      If vDataset <> Nil Then
       Begin
        If (vDataset.FieldByName(vMassiveFields.Items[I-1].vFieldName) <> Nil) Then
         Begin
          If vDataset.FieldByName(vMassiveFields.Items[I-1].vFieldName).ReadOnly Then
           Continue;
         End;
       End;
     End;
    If MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.IsNull Then
     vTempValue := Format('"%s"', ['null'])
    Else
     Begin
      If I = 0 Then
       vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value])    //asstring
      Else
       Begin
        If vMassiveFields.Items[I-1].vFieldType in [ovString, ovWideString, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
         vTempValue    := Format('"%s"', [EncodeStrings(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value{$IFDEF FPC}, csUndefined{$ENDIF})])
        Else
         vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value])
       End;
     End;
    If I = 0 Then
     vTempLine := vTempValue
    Else
     vTempLine := vTempLine + ', ' + vTempValue;
   End;
  vTempLine := '[' + vTempLine + ']';
  If MassiveLineBuff.vChanges.Count > 0 Then
   Begin
    For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
     Begin
      vTempValue := Format('"%s"', [MassiveLineBuff.vChanges[A]]);    //asstring
      If A = 0 Then
       vTempKeys := vTempValue
      Else
       vTempKeys := vTempKeys + ', ' + vTempValue;
     End;
    vTempKeys := '[' + vTempKeys + ']';
   End;
  If MassiveLineBuff.vPrimaryValues <> Nil Then
   Begin
    For I := 0 To MassiveLineBuff.vPrimaryValues.Count - 1 Do
     Begin
      If MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.IsNull Then
       vTempValue := Format('"%s"', ['null'])
      Else
       vTempValue    := Format('"%s"', [MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.Value]);    //asstring
      If I = 0 Then
       vTempComp := vTempValue
      Else
       vTempComp := vTempComp + ', ' + vTempValue;
     End;
    If MassiveLineBuff.vPrimaryValues.Count > 0 Then
     vTempComp := '[' + vTempComp + ']';
   End;
  If (vTempComp <> '') And (vTempKeys <> '') Then
   Result := Format('%s,%s,%s', [vTempLine, vTempComp, vTempKeys])
  Else
   Result := vTempLine;
 End;
Begin
 vTagFields  := '{"fields":[' + GenerateHeader + ']}';
 For A := 0 To vMassiveBuffer.Count -1 Do
  Begin
   If A = 0 Then
    vLines := Format('[%s]', [GenerateLine(vMassiveBuffer.Items[A])])
   Else
    vLines := vLines + Format(', [%s]', [GenerateLine(vMassiveBuffer.Items[A])]);
  End;
 vTagFields := vTagFields + Format(', {"lines":[%s]}', [vLines]);
 Result := Format(TMassiveFormatJSON, ['ObjectType',   GetObjectName(toMassive),
                                       'Direction',    GetDirectionName(odINOUT),
                                       'Encoded',      'true',
                                       'ValueType',    GetValueType(ovObject),
                                       'TableName',    vTableName,
                                       'MassiveValue', vTagFields]);
End;

{ TDWMassiveCacheList }

function TDWMassiveCacheList.Add(Item: TDWMassiveCacheValue): Integer;
Var
 vItem : ^TDWMassiveCacheValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

procedure TDWMassiveCacheList.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

procedure TDWMassiveCacheList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If TDWMassiveCacheValue(TList(Self).Items[Index]^) <> '' Then
      TDWMassiveCacheValue(TList(Self).Items[Index]^) := '';
     {$IFDEF FPC}
      Dispose(PMassiveCacheValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
end;

destructor TDWMassiveCacheList.Destroy;
begin
 ClearAll;
 Inherited;
end;

function TDWMassiveCacheList.GetRec(Index: Integer): TDWMassiveCacheValue;
begin
 Result := '';
 If (Index < Self.Count) And (Index > -1) Then
  Result := TDWMassiveCacheValue(TList(Self).Items[Index]^);
end;

procedure TDWMassiveCacheList.PutRec(Index: Integer; Item: TDWMassiveCacheValue);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TDWMassiveCacheValue(TList(Self).Items[Index]^) := Item;
end;

{ TDWMassiveCache }

Constructor TDWMassiveCache.Create(AOwner: TComponent);
Begin
  inherited;
 MassiveCacheList := TDWMassiveCacheList.Create;
End;

Function TDWMassiveCache.MassiveCount : Integer;
Begin
 Result := MassiveCacheList.Count;
End;

Procedure TDWMassiveCache.Add(Value: String);
Begin
 MassiveCacheList.Add(Value);
End;

Procedure TDWMassiveCache.Clear;
Begin
 MassiveCacheList.Clear;
End;

Function TDWMassiveCache.ToJSON : String;
Var
 I : Integer;
 vMassiveLine : String;
Begin
 Result := '[%s]';
 vMassiveLine := '';
 For I := 0 To MassiveCacheList.Count -1 Do
  Begin
   If Length(vMassiveLine) = 0 Then
    vMassiveLine := MassiveCacheList.Items[I]
   Else
    vMassiveLine := vMassiveLine + ', ' + MassiveCacheList.Items[I];
  End;
 If vMassiveLine <> '' Then
  Result := Format(Result, [vMassiveLine])
 Else
  Result := vMassiveLine;
End;

Destructor TDWMassiveCache.Destroy;
Begin
 FreeAndNil(MassiveCacheList);
  inherited;
End;

{ TDWMassiveSQLCache }

{
procedure TDWMassiveSQLCache.Add(Value: TDWMassiveCacheSQLValue);
begin
 MassiveCacheSQLList.Add(Value);
end;
}

procedure TDWMassiveSQLCache.AddDataset(Dataset: TDataset);
Begin
 If Dataset is TRESTDWClientSQL Then
  Begin

  End;
End;

procedure TDWMassiveSQLCache.Clear;
begin
 MassiveCacheSQLList.Clear;
end;

constructor TDWMassiveSQLCache.Create(AOwner: TComponent);
begin
  inherited;
 MassiveCacheSQLList := TDWMassiveCacheSQLList.Create;
end;

destructor TDWMassiveSQLCache.Destroy;
begin
 FreeAndNil(MassiveCacheSQLList);
  inherited;
end;

function TDWMassiveSQLCache.MassiveCount: Integer;
begin
 Result := MassiveCacheSQLList.Count;
end;

function TDWMassiveSQLCache.ToJSON: String;
begin

end;

{ TDWMassiveCacheSQLList }

function TDWMassiveCacheSQLList.Add(Item: TDWMassiveCacheSQLValue): Integer;
Var
 vItem : ^TDWMassiveCacheSQLValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

procedure TDWMassiveCacheSQLList.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

procedure TDWMassiveCacheSQLList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If TDWMassiveCacheSQLValue(TList(Self).Items[Index]^).SQL <> '' Then
      TDWMassiveCacheSQLValue(TList(Self).Items[Index]^).SQL := '';
     {$IFDEF FPC}
      Dispose(PMassiveCacheSQLValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
end;

destructor TDWMassiveCacheSQLList.Destroy;
begin
 ClearAll;
  inherited;
end;

function TDWMassiveCacheSQLList.GetRec(Index: Integer): TDWMassiveCacheSQLValue;
begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TDWMassiveCacheSQLValue(TList(Self).Items[Index]^);
end;

procedure TDWMassiveCacheSQLList.PutRec(Index: Integer;
  Item: TDWMassiveCacheSQLValue);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TDWMassiveCacheSQLValue(TList(Self).Items[Index]^) := Item;
end;

End.
