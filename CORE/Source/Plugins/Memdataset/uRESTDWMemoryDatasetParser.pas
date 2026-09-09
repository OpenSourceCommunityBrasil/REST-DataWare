Unit uRESTDWMemoryDatasetParser;

Interface

Uses
  SysUtils,
  Classes,
  db,
  uRESTDWMemoryDatasetParserCore,
  uRESTDWMemoryDatasetParserDefs;

Type

  TRESTDWMemParser = Class(TRESTDWMemCustomExpressionParser)
  Private
    FDataset: TDataSet;
    FFieldVarList: TStringList;
    FResultLen: Integer;
    FIsExpression: Boolean;       // expression or simple field?
    FFieldType: TRESTDWMemExpressionType;
    FCaseInsensitive: Boolean;
    FPartialMatch: boolean;

  Protected
    FCurrentExpression: string;

    Procedure FillExpressList; override;
    Procedure HandleUnknownVariable(VarName: string); override;
    Function  GetVariableInfo(VarName: string): TField;
    Function  CurrentExpression: string; override;
    Function  GetResultType: TRESTDWMemExpressionType; override;

    Procedure SetCaseInsensitive(NewInsensitive: Boolean);
    Procedure SetPartialMatch(NewPartialMatch: boolean);
  Public
    Constructor Create(ADataset: TDataset);
    Destructor Destroy; override;

    Procedure ClearExpressions; override;

    Procedure ParseExpression(AExpression: string); virtual;
    Function ExtractFromBuffer(Buffer: TRecordBuffer): PChar; virtual;

    property Dataset: TDataSet read FDataset; // write FDataset;
    property Expression: string read FCurrentExpression;
    property ResultLen: Integer read FResultLen;

    property CaseInsensitive: Boolean read FCaseInsensitive write SetCaseInsensitive;
    property PartialMatch: boolean read FPartialMatch write SetPartialMatch;
  End;

Implementation

Uses
 {$IFDEF FPC}dbconst{$ELSE}DBConsts{$ENDIF};

{$IFNDEF FPC}
Const
 SErrIndexBasedOnUnkField = 'Index based on unknown field %s';
 SErrIndexBasedOnInvField = 'Index based on invalid field %s (%s)';
 SErrIndexResultTooLong = 'Index expression %s result is too long (%d)';
{$ENDIF}

Type
{$IFNDEF FPC}
  TStringFieldBuffer = array[0..dsMaxStringSize] Of AnsiChar;
{$ENDIF}

// TRESTDWMemFieldVar aids in retrieving field values from records
// in their proper type

  TRESTDWMemFieldVar = Class(TObject)
  Private
    FField: TField;
    FFieldName: string;
    FExprWord: TRESTDWMemExprWord;
  Protected
    Function GetFieldVal: Pointer; virtual; abstract;
    Function GetFieldType: TRESTDWMemExpressionType; virtual; abstract;
  Public
    Constructor Create(UseField: TField);

    Procedure Refresh(Buffer: TRecordBuffer); virtual; abstract;

    property FieldVal: Pointer read GetFieldVal;
    property FieldDef: TField read FField;
    property FieldType: TRESTDWMemExpressionType read GetFieldType;
    property FieldName: string read FFieldName;
  End;

  TRESTDWMemStringFieldVar = Class(TRESTDWMemFieldVar)
  Protected
    FFieldVal: {$IFDEF FPC}PChar{$ELSE}PAnsiChar{$ENDIF};

    Function GetFieldVal: Pointer; override;
    Function GetFieldType: TRESTDWMemExpressionType; override;
  Public
    Constructor Create(UseField: TField);
    Destructor Destroy; override;

    Procedure Refresh(Buffer: TRecordBuffer); override;
  End;

  TRESTDWMemFloatFieldVar = Class(TRESTDWMemFieldVar)
  Private
    FFieldVal: Double;
  Protected
    Function GetFieldVal: Pointer; override;
    Function GetFieldType: TRESTDWMemExpressionType; override;
  Public
    Procedure Refresh(Buffer: TRecordBuffer); override;
  End;

  TRESTDWMemIntegerFieldVar = Class(TRESTDWMemFieldVar)
  Private
    FFieldVal: Integer;
  Protected
    Function GetFieldVal: Pointer; override;
    Function GetFieldType: TRESTDWMemExpressionType; override;
  Public
    Procedure Refresh(Buffer: TRecordBuffer); override;
  End;

  TRESTDWMemLargeIntFieldVar = Class(TRESTDWMemFieldVar)
  Private
    FFieldVal: Int64;
  Protected
    Function GetFieldVal: Pointer; override;
    Function GetFieldType: TRESTDWMemExpressionType; override;
  Public
    Procedure Refresh(Buffer: TRecordBuffer); override;
  End;

  TRESTDWMemDateTimeFieldVar = Class(TRESTDWMemFieldVar)
  Private
    FFieldVal: TDateTime;
    Function GetFieldType: TRESTDWMemExpressionType; override;
  Protected
    Function GetFieldVal: Pointer; override;
  Public
    Procedure Refresh(Buffer: TRecordBuffer); override;
  End;

  TRESTDWMemBooleanFieldVar = Class(TRESTDWMemFieldVar)
  Private
    FFieldVal: wordbool;
    Function GetFieldType: TRESTDWMemExpressionType; override;
  Protected
    Function GetFieldVal: Pointer; override;
  Public
    Procedure Refresh(Buffer: TRecordBuffer); override;
  End;

  TRESTDWMemBCDFieldVar = Class(TRESTDWMemFloatFieldVar)
  Public
    Procedure Refresh(Buffer: TRecordBuffer); override;
  End;


//--TRESTDWMemFieldVar----------------------------------------------------------------
Constructor TRESTDWMemFieldVar.Create(UseField: TField);
Begin
 Inherited Create;

 // store field
 //FDataset := ADataset;
 FField := UseField;
 FFieldName := UseField.FieldName;
End;

//--TRESTDWMemStringFieldVar-------------------------------------------------------------
Function TRESTDWMemStringFieldVar.GetFieldVal: Pointer;
Begin
 Result := @FFieldVal;
End;

Function TRESTDWMemStringFieldVar.GetFieldType: TRESTDWMemExpressionType;
Begin
 Result := etString;
End;

Constructor TRESTDWMemStringFieldVar.Create(UseField: TField);
Begin
 Inherited;

 GetMem(FFieldVal, dsMaxStringSize+1);
End;

Destructor TRESTDWMemStringFieldVar.Destroy;
Begin
 FreeMem(FFieldVal);

 Inherited;
End;

Procedure TRESTDWMemStringFieldVar.Refresh(Buffer: TRecordBuffer);
Var Fieldbuf : TStringFieldBuffer;
Begin
 If not FField.DataSet.GetFieldData(FField,@Fieldbuf) Then
 FFieldVal^:=#0
 Else
 strcopy(FFieldVal,@Fieldbuf[0]);
End;

//--TRESTDWMemFloatFieldVar-----------------------------------------------------------
Function TRESTDWMemFloatFieldVar.GetFieldVal: Pointer;
Begin
 Result := @FFieldVal;
End;

Function TRESTDWMemFloatFieldVar.GetFieldType: TRESTDWMemExpressionType;
Begin
 Result := etFloat;
End;

Procedure TRESTDWMemFloatFieldVar.Refresh(Buffer: TRecordBuffer);
Begin
 If not FField.DataSet.GetFieldData(FField,@FFieldVal) Then
 FFieldVal := 0;
End;

//--TRESTDWMemIntegerFieldVar----------------------------------------------------------
Function TRESTDWMemIntegerFieldVar.GetFieldVal: Pointer;
Begin
 Result := @FFieldVal;
End;

Function TRESTDWMemIntegerFieldVar.GetFieldType: TRESTDWMemExpressionType;
Begin
 Result := etInteger;
End;

Procedure TRESTDWMemIntegerFieldVar.Refresh(Buffer: TRecordBuffer);
Begin
 If not FField.DataSet.GetFieldData(FField,@FFieldVal) Then
 FFieldVal := 0;
End;

//--TRESTDWMemLargeIntFieldVar----------------------------------------------------------
Function TRESTDWMemLargeIntFieldVar.GetFieldVal: Pointer;
Begin
 Result := @FFieldVal;
End;

Function TRESTDWMemLargeIntFieldVar.GetFieldType: TRESTDWMemExpressionType;
Begin
 Result := etLargeInt;
End;

Procedure TRESTDWMemLargeIntFieldVar.Refresh(Buffer: TRecordBuffer);
Begin
 If not FField.DataSet.GetFieldData(FField,@FFieldVal) Then
 FFieldVal := 0;
End;

//--TRESTDWMemDateTimeFieldVar---------------------------------------------------------
Function TRESTDWMemDateTimeFieldVar.GetFieldVal: Pointer;
Begin
 Result := @FFieldVal;
End;

Function TRESTDWMemDateTimeFieldVar.GetFieldType: TRESTDWMemExpressionType;
Begin
 Result := etDateTime;
End;

Procedure TRESTDWMemDateTimeFieldVar.Refresh(Buffer:TRecordBuffer );
Begin
 If not FField.DataSet.GetFieldData(FField,@FFieldVal) Then
 FFieldVal := 0;
End;

//--TRESTDWMemBooleanFieldVar---------------------------------------------------------
Function TRESTDWMemBooleanFieldVar.GetFieldVal: Pointer;
Begin
 Result := @FFieldVal;
End;

Function TRESTDWMemBooleanFieldVar.GetFieldType: TRESTDWMemExpressionType;
Begin
 Result := etBoolean;
End;

Procedure TRESTDWMemBooleanFieldVar.Refresh(Buffer: TRecordBuffer);
Begin
 If not FField.DataSet.GetFieldData(FField,@FFieldVal) Then
 FFieldVal := False;
End;

Procedure TRESTDWMemBCDFieldVar.Refresh(Buffer: TRecordBuffer);
Var c: currency;
Begin
 If FField.DataSet.GetFieldData(FField,@c) Then
 FFieldVal := c
 Else
 FFieldVal := 0;
End;


//--TRESTDWMemParser---------------------------------------------------------------

Constructor TRESTDWMemParser.Create(Adataset: TDataSet);
Begin
 FDataset := Adataset;
 FFieldVarList := TStringList.Create;
 FCaseInsensitive := true;
 Inherited Create;
End;

Destructor TRESTDWMemParser.Destroy;
Begin
 ClearExpressions;
 Inherited;
 FreeAndNil(FFieldVarList);
End;

Function TRESTDWMemParser.GetResultType: TRESTDWMemExpressionType;
Begin
 // if not a real expression, return type ourself
 If FIsExpression Then
 Result := Inherited GetResultType
 Else
 Result := FFieldType;
End;

Procedure TRESTDWMemParser.SetCaseInsensitive(NewInsensitive: Boolean);
Begin
 If FCaseInsensitive <> NewInsensitive Then
  Begin
   // clear and regenerate functions
   FCaseInsensitive := NewInsensitive;
   FillExpressList;
  End;
End;

Procedure TRESTDWMemParser.SetPartialMatch(NewPartialMatch: boolean);
Begin
 If FPartialMatch <> NewPartialMatch Then
  Begin
   // refill function list
   FPartialMatch := NewPartialMatch;
   FillExpressList;
  End;
End;

Procedure TRESTDWMemParser.FillExpressList;
Var
 lExpression: string;
Begin
 lExpression := FCurrentExpression;
 ClearExpressions;
 FWordsList.FreeAll;
 FWordsList.AddList(DbfWordsGeneralList, 0, DbfWordsGeneralList.Count - 1);
 If FCaseInsensitive Then
  Begin
   FWordsList.AddList(DbfWordsInsensGeneralList, 0, DbfWordsInsensGeneralList.Count - 1);
   If FPartialMatch Then
    Begin
     FWordsList.AddList(DbfWordsInsensPartialList, 0, DbfWordsInsensPartialList.Count - 1);
    End Else Begin
   FWordsList.AddList(DbfWordsInsensNoPartialList, 0, DbfWordsInsensNoPartialList.Count - 1);
  End;
End Else Begin
 FWordsList.AddList(DbfWordsSensGeneralList, 0, DbfWordsSensGeneralList.Count - 1);
 If FPartialMatch Then
  Begin
   FWordsList.AddList(DbfWordsSensPartialList, 0, DbfWordsSensPartialList.Count - 1);
  End Else Begin
  FWordsList.AddList(DbfWordsSensNoPartialList, 0, DbfWordsSensNoPartialList.Count - 1);
 End;
 End;
 If Length(lExpression) > 0 Then
 ParseExpression(lExpression);
End;

Function TRESTDWMemParser.GetVariableInfo(VarName: string): TField;
Begin
 Result := FDataset.FindField(VarName);
End;

Function TRESTDWMemParser.CurrentExpression: string;
Begin
 Result := FCurrentExpression;
End;

Procedure TRESTDWMemParser.HandleUnknownVariable(VarName: string);
Var
 FieldInfo: TField;
 TempFieldVar: TRESTDWMemFieldVar;
Begin
 // is this variable a fieldname?
 FieldInfo := GetVariableInfo(VarName);
 If FieldInfo = nil Then
 raise EDatabaseError.CreateFmt(SErrIndexBasedOnUnkField, [VarName]);

 // define field in parser
 Case FieldInfo.DataType Of
 ftString, ftFixedChar:
  Begin
   TempFieldVar := TRESTDWMemStringFieldVar.Create(FieldInfo);
   TempFieldVar.FExprWord := DefineStringVariable(VarName, TempFieldVar.FieldVal);
   TempFieldVar.FExprWord.fixedlen := Fieldinfo.Size;
  End;
 ftBoolean:
  Begin
   TempFieldVar := TRESTDWMemBooleanFieldVar.Create(FieldInfo);
   TempFieldVar.FExprWord := DefineBooleanVariable(VarName, TempFieldVar.FieldVal);
  End;
 ftFloat:
  Begin
   TempFieldVar := TRESTDWMemFloatFieldVar.Create(FieldInfo);
   TempFieldVar.FExprWord := DefineFloatVariable(VarName, TempFieldVar.FieldVal);
  End;
 ftAutoInc, ftInteger, ftSmallInt, ftWord:
  Begin
   TempFieldVar := TRESTDWMemIntegerFieldVar.Create(FieldInfo);
   TempFieldVar.FExprWord := DefineIntegerVariable(VarName, TempFieldVar.FieldVal);
  End;
 ftLargeInt:
  Begin
   TempFieldVar := TRESTDWMemLargeIntFieldVar.Create(FieldInfo);
   TempFieldVar.FExprWord := DefineLargeIntVariable(VarName, TempFieldVar.FieldVal);
  End;
 ftDate, ftDateTime:
  Begin
   TempFieldVar := TRESTDWMemDateTimeFieldVar.Create(FieldInfo);
   TempFieldVar.FExprWord := DefineDateTimeVariable(VarName, TempFieldVar.FieldVal);
  End;
 ftBCD:
  Begin
   TempFieldVar := TRESTDWMemBCDFieldVar.Create(FieldInfo);
   TempFieldVar.FExprWord := DefineFloatVariable(VarName, TempFieldVar.FieldVal);
  End;
 Else
 raise EDatabaseError.CreateFmt(SErrIndexBasedOnInvField, [VarName,Fieldtypenames[FieldInfo.DataType]]);
End;

 // add to our own list
 FFieldVarList.AddObject(VarName, TempFieldVar);
End;

Procedure TRESTDWMemParser.ClearExpressions;
Var
 I: Integer;
Begin
 Inherited;

 // test if already freed
 If FFieldVarList <> nil Then
  Begin
   // free field list
   For I := 0 To FFieldVarList.Count - 1 Do
    Begin
     // replacing with nil = undefining variable
     FWordsList.DoFree(TRESTDWMemFieldVar(FFieldVarList.Objects[I]).FExprWord);
     TRESTDWMemFieldVar(FFieldVarList.Objects[I]).Free;
    End;
   FFieldVarList.Clear;
  End;

 // clear expression
 FCurrentExpression := EmptyStr;
End;

Procedure TRESTDWMemParser.ParseExpression(AExpression: string);
Var
 TempBuffer: TRecordBuffer;
Begin
 // clear any current expression
 ClearExpressions;

 // is this a simple field or complex expression?
 FIsExpression := GetVariableInfo(AExpression) = nil;
 If FIsExpression Then
  Begin
   // parse requested
   CompileExpression(AExpression);
 
   // determine length of string length expressions
   If ResultType = etString Then
    Begin
     // make empty record
     GetMem(TempBuffer, FDataset.RecordSize);
     Try
     FillChar(TempBuffer^, FDataset.RecordSize, #0);
     FResultLen := StrLen(ExtractFromBuffer(TempBuffer));
     Finally
     FreeMem(TempBuffer);
    End;
  End;
End Else Begin
  // simple field, create field variable for it
 HandleUnknownVariable(AExpression);
 FFieldType := TRESTDWMemFieldVar(FFieldVarList.Objects[0]).FieldType;
  // set result len of variable length fields
 If FFieldType = etString Then
  FResultLen := TRESTDWMemFieldVar(FFieldVarList.Objects[0]).FieldDef.Size
 End;

 // set result len for fixed length expressions / fields
 Case ResultType Of
 etBoolean:  FResultLen := 1;
 etInteger:  FResultLen := 4;
 etFloat:    FResultLen := 8;
 etDateTime: FResultLen := 8;
 End;

 // check if expression not too long
 If FResultLen > 100 Then
 raise EDatabaseError.CreateFmt(SErrIndexResultTooLong, [AExpression, FResultLen]);

 // if no errors, assign current expression
 FCurrentExpression := AExpression;
End;

Function TRESTDWMemParser.ExtractFromBuffer(Buffer: TRecordBuffer): PChar;
Var
 I: Integer;
Begin
 // prepare all field variables
 For I := 0 To FFieldVarList.Count - 1 Do
 TRESTDWMemFieldVar(FFieldVarList.Objects[I]).Refresh(Buffer);

 // complex expression?
 If FIsExpression Then
  Begin
   // execute expression
   EvaluateCurrent;
   Result := ExpResult;
  End Else Begin
  // simple field, get field result
 Result := TRESTDWMemFieldVar(FFieldVarList.Objects[0]).FieldVal;
  // if string then dereference
 If FFieldType = etString Then
  Result := PPChar(Result)^;
End;
End;

End.
