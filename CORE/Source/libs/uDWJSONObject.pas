Unit uDWJSONObject;

{$I uRESTDW.inc}

Interface

Uses
 {$IFDEF FPC}
 SysUtils,            Classes, uDWJSONTools,      IdGlobal, DB, uDWJSON,   uDWConsts,
 uDWConstsData,       memds,  LConvEncoding, Variants;
 {$ELSE}
 {$IF CompilerVersion > 21} // Delphi 2010 pra cima
 System.SysUtils,     System.Classes,      uDWJSONTools, uDWConsts, uDWJSON,
 uDWConstsData,       IdGlobal, System.Rtti,    Data.DB,      Soap.EncdDecd,
 Datasnap.DbClient
 {$IFDEF POSIX} //ANDROID}
 {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
   ,system.json, FMX.Types
 {$IFEND}
 {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
 ,system.json
 {$IFEND}
 {$ENDIF}
   {$IFDEF CLIENTDATASET}
    {,  DBClient} , Variants
   {$ENDIF}
 {$IFDEF RESJEDI}
  ,JvMemoryDataset, Variants
 {$ENDIF}
 {$IFDEF RESTKBMMEMTABLE}
  ,kbmmemtable, Variants
 {$ENDIF}
 {$IFDEF RESTFDMEMTABLE}
  ,FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Variants
 {$ENDIF};
 {$ELSE}
 SysUtils, Classes,   uDWJSONTools,   uDWJSON, IdGlobal, DB,   EncdDecd,
 DbClient, uDWConsts, uDWConstsData,  Variants
 {$IFDEF RESJEDI}
  ,JvMemoryDataset
 {$ENDIF}
 {$IFDEF RESTKBMMEMTABLE}
  ,kbmmemtable
 {$ENDIF};
 {$IFEND}
 {$ENDIF}

Const                                                 //\b  \t  \n   \f   \r
 TSpecialChars : Array [0..7] of Char = ('\', '"', '/', #8, #9, #10, #12, #13);

Type
 TJSONBufferObject = Class
End;

Type
 TJSONValue = Class
Private
 vJsonMode   : TJsonMode;
 vNullValue,
 vBinary: Boolean;
 vtagName: String;
 vTypeObject: TTypeObject;
 vObjectDirection: TObjectDirection;
 vObjectValue: TObjectValue;
 aValue: TIdBytes;
 vEncoded: Boolean;
 vEncoding: TEncodeSelect;
 {$IFDEF FPC}
 vEncodingLazarus   : TEncoding;
 vDatabaseCharSet   : TDatabaseCharSet;
 {$ENDIF}
 Function  GetValue : String;
 Procedure WriteValue   (bValue      : String);
 Function  FormatValue  (bValue      : String)       : String;
 Function  GetValueJSON (bValue      : String)       : String;
 Function  DatasetValues(bValue         : TDataset;
                         DateTimeFormat : String = '';
                         JsonModeD      : TJsonMode = jmDataware) : String;
 Function EncodedString : String;
 Procedure SetEncoding(bValue : TEncodeSelect);
Public
 Procedure ToStream(Var    bValue       : TMemoryStream);
 Procedure LoadFromDataset(TableName      : String;
                           bValue         : TDataset;
                           EncodedValue   : Boolean          = True;
                           JsonModeD      : TJsonMode        = jmDataware;
                           DateTimeFormat : String           = ''{$IFDEF FPC};
                           CharSet        : TDatabaseCharSet = csUndefined{$ENDIF});
 Procedure WriteToDataset (DatasetType  : TDatasetType;
                           JSONValue    : String;
                           DestDS       : TDataset;
                           ClearDataset : Boolean = False{$IFDEF FPC};
                           CharSet      : TDatabaseCharSet = csUndefined{$ENDIF});
 Procedure LoadFromJSON   (bValue       : String);
 Procedure LoadFromStream (Stream       : TMemoryStream;
                           Encode       : Boolean = True);
 Procedure SaveToStream   (Stream       : TMemoryStream; Binary : Boolean = False);
 Procedure StringToBytes  (Value        : String; Encode : Boolean = False);
 Function  ToJSON  : String;
 Procedure SetValue       (Value        : String;
                           Encode       : Boolean = True);
 Function  Value   : String;
 Constructor Create;
 Destructor  Destroy; Override;
 Function    IsNull          : Boolean;
 Property    TypeObject      : TTypeObject      Read vTypeObject      Write vTypeObject;
 Property    ObjectDirection : TObjectDirection Read vObjectDirection Write vObjectDirection;
 Property    ObjectValue     : TObjectValue     Read vObjectValue     Write vObjectValue;
 Property    Binary          : Boolean          Read vBinary          Write vBinary;
 Property    Encoding        : TEncodeSelect    Read vEncoding        Write SetEncoding;
 Property    Tagname         : String           Read vtagName         Write vtagName;
 Property    Encoded         : Boolean          Read vEncoded         Write vEncoded;
 Property    JsonMode        : TJsonMode        Read vJsonMode        Write vJsonMode;
 {$IFDEF FPC}
 Property DatabaseCharSet    : TDatabaseCharSet Read vDatabaseCharSet Write vDatabaseCharSet;
 {$ENDIF}
End;

Type
 PJSONParam = ^TJSONParam;
 TJSONParam = Class(TObject)
Private
 vJSONValue       : TJSONValue;
 vJsonMode        : TJsonMode;
 vEncoding        : TEncodeSelect;
 vTypeObject      : TTypeObject;
 vObjectDirection : TObjectDirection;
 vObjectValue     : TObjectValue;
 vParamName       : String;
 vBinary,
 vEncoded         : Boolean;
 Procedure WriteValue  (bValue     : String);
 Procedure SetParamName(bValue     : String);
 Function  GetAsString             : String;
 Procedure SetAsString (Value      : String);
 {$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
 Function  GetAsWideString         : WideString;
 Procedure SetAsWideString  (Value : WideString);
 Function  GetAsAnsiString         : AnsiString;
 Procedure SetAsAnsiString  (Value : AnsiString);
 {$ENDIF}
 Function  GetAsBCD                : Currency;
 Procedure SetAsBCD (Value         : Currency);
 Function  GetAsFMTBCD             : Currency;
 Procedure SetAsFMTBCD(Value       : Currency);
 Function  GetAsCurrency           : Currency;
 Procedure SetAsCurrency(Value     : Currency);
 Function  GetAsBoolean            : Boolean;
 Procedure SetAsBoolean (Value     : Boolean);
 Function  GetAsDateTime           : TDateTime;
 Procedure SetAsDateTime(Value     : TDateTime);
 Procedure SetAsDate    (Value     : TDateTime);
 Procedure SetAsTime    (Value     : TDateTime);
 Function  GetAsSingle             : Single;
 Procedure SetAsSingle  (Value     : Single);
 Function  GetAsFloat              : Double;
 Procedure SetAsFloat   (Value     : Double);
 Function  GetAsInteger            : Integer;
 Procedure SetAsInteger (Value     : Integer);
 Function  GetAsWord               : Word;
 Procedure SetAsWord    (Value     : Word);
 Procedure SetAsSmallInt(Value     : Integer);
 Procedure SetAsShortInt(Value     : Integer);
 Function  GetAsLongWord           : LongWord;
 Procedure SetAsLongWord(Value     : LongWord);
 Function  GetAsLargeInt           : LargeInt;
 Procedure SetAsLargeInt(Value     : LargeInt);
 Procedure SetObjectValue(Value    : TObjectValue);
 Function  GetByteString           : String;
 Procedure SetAsObject(Value       : String);
Public
 Constructor Create(Encoding       : TEncodeSelect);
 Destructor  Destroy; Override;
 Function    IsEmpty               : Boolean;
 Procedure   FromJSON(JSON         : String);
 Function    ToJSON                : String;
 Procedure   CopyFrom(JSONParam    : TJSONParam);
 Procedure   SetVariantValue(Value : Variant);
 Procedure   SetDataValue(Value    : Variant;
                          DataType : TObjectValue);
 Function    GetVariantValue       : Variant;
 Function    GetValue(Value        : TObjectValue) : Variant;
 Procedure   SetValue(aValue       : String;
                      Encode       : Boolean = True);
 Procedure   LoadFromStream(Stream : TMemoryStream;
                            Encode : Boolean = True);
 Procedure   StringToBytes (Value  : String;
                            Encode : Boolean = False);
 Procedure   SaveToStream  (Stream : TMemoryStream);
 Procedure   LoadFromParam (Param  : TParam);
 Property    ObjectDirection       : TObjectDirection Read vObjectDirection Write vObjectDirection;
 Property    ObjectValue           : TObjectValue     Read vObjectValue     Write SetObjectValue;
 Property    ParamName             : String           Read vParamName       Write SetParamName;
 Property    Encoded               : Boolean          Read vEncoded         Write vEncoded;
 Property    Binary                : Boolean          Read vBinary;
 Property    JsonMode              : TJsonMode        Read vJsonMode        Write vJsonMode;
 //Propriedades Novas
 Property    Value                 : Variant          Read GetVariantValue  Write SetVariantValue;
 //Novas definições por tipo
 Property    AsBCD                 : Currency         Read GetAsBCD         Write SetAsBCD;
 Property    AsFMTBCD              : Currency         Read GetAsFMTBCD      Write SetAsFMTBCD;
 Property    AsBoolean             : Boolean          Read GetAsBoolean     Write SetAsBoolean;
 Property    AsCurrency            : Currency         Read GetAsCurrency    Write SetAsCurrency;
 Property    AsExtended            : Currency         Read GetAsCurrency    Write SetAsCurrency;
 Property    AsDate                : TDateTime        Read GetAsDateTime    Write SetAsDate;
 Property    AsTime                : TDateTime        Read GetAsDateTime    Write SetAsTime;
 Property    AsDateTime            : TDateTime        Read GetAsDateTime    Write SetAsDateTime;
 Property    AsSingle              : Single           Read GetAsSingle      Write SetAsSingle;
 Property    AsFloat               : Double           Read GetAsFloat       Write SetAsFloat;
 Property    AsInteger             : integer          Read GetAsInteger     Write SetAsInteger;
 Property    AsSmallInt            : integer          Read GetAsInteger     Write SetAsSmallInt;
 Property    AsShortInt            : integer          Read GetAsInteger     Write SetAsShortInt;
 Property    AsWord                : Word             Read GetAsWord        Write SetAsWord;
 Property    AsLongWord            : LongWord         Read GetAsLongWord    Write SetAsLongWord;
 Property    AsLargeInt            : LargeInt         Read GetAsLargeInt    Write SetAsLargeInt;
 Property    AsString              : String           Read GetAsString      Write SetAsString;
 Property    AsObject              : String           Read GetAsString      Write SetAsObject;
 Property    AsByteString          : String           Read GetByteString;
 {$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
 Property    AsWideString          : WideString       Read GetAsWideString  Write SetAsWideString;
 Property    AsAnsiString          : AnsiString       Read GetAsAnsiString  Write SetAsAnsiString;
 {$ENDIF}
 Property    AsMemo                : String           Read GetAsString      Write SetAsString;
{
 Property    AsBytes               : TArray<Byte>     Read GetAsBytes       Write SetAsBytes;
//    Property AsDataSet: TDataSet read GetAsDataSet write SetAsDataSet;
 Property    AsStream              : TStream          Read GetAsStream      Write SetAsStream;
}
End;

Type
 PStringStream     = ^TStringStream;
 TStringStreamList = Class(TList)
Private
 Function  GetRec(Index   : Integer) : TStringStream;       Overload;
 Procedure PutRec(Index   : Integer;
                  Item    : TStringStream);                 Overload;
 Procedure ClearList;
Public
 Constructor Create;
 Destructor  Destroy; Override;
 Procedure   Delete(Index : Integer); Overload;
 Function    Add   (Item  : TStringStream) : Integer;       Overload;
 Property    Items[Index  : Integer]       : TStringStream  Read GetRec Write PutRec; Default;
End;

Type
 TDWParams = Class(TList)
Private
 vJsonMode : TJsonMode;
 vEncoding : TEncodeSelect;
 Function    GetRec    (Index     : Integer) : TJSONParam;  Overload;
 Procedure   PutRec    (Index     : Integer;
                        Item      : TJSONParam);            Overload;
 Function    GetRecName(Index     : String)  : TJSONParam;  Overload;
 Procedure   PutRecName(Index     : String;
                        Item      : TJSONParam);            Overload;
 Procedure   ClearList;
Public
 Constructor Create;
 Destructor  Destroy; Override;
 Function    ParamsReturn         : Boolean;
 Function    CountOutParams       : Integer;
 Function    ToJSON               : String;
 Procedure   FromJSON   (JSON     : String);
 Procedure   CopyFrom   (DWParams : TDWParams);
 Procedure   Delete     (Index    : Integer);               Overload;
 Function    Add        (Item     : TJSONParam): Integer;   Overload;
 Property    Items      [Index    : Integer]   : TJSONParam Read GetRec     Write PutRec; Default;
 Property    ItemsString[Index    : String]    : TJSONParam Read GetRecName Write PutRecName;
 Property    JsonMode                          : TJsonMode  Read vJsonMode  Write vJsonMode;
 Property    Encoding : TEncodeSelect Read vEncoding Write vEncoding;
End;

Type
 TDWDatalist = Class
End;

Function StringToJsonString(OriginalString : String) : String;

implementation

Uses uRESTDWPoolerDB;

Function removestr(Astr: string; Asubstr: string):string;
Begin
 result:= stringreplace(Astr,Asubstr,'',[rfReplaceAll, rfIgnoreCase]);
End;

Function StringToJsonString(OriginalString : String) : String;
Var
 i : Integer;
 Function NewChar(OldChar : String) : String;
 Begin
  Result := '';
  If Length(OldChar) > 0 Then
   Begin
    Case OldChar[1] Of
     '\' : Result := '\\';
     '"' : Result := '\"';
     '/' : Result := '\/';
     #8  : Result := '\b';
     #9  : Result := '\t';
     #10 : Result := '\n';
     #12 : Result := '\f';
     #13 : Result := '\r';
    End;
   End;
 End;
Begin
 Result := OriginalString;
 For i := 0 To Length(TSpecialChars) -1 Do
  Result := StringReplace(Result, TSpecialChars[i], NewChar(TSpecialChars[i]), [rfReplaceAll]);
End;

{$IF Defined(ANDROID) or Defined(IOS)} //Alterado para IOS Brito
Function CopyValue(Var bValue : String) : String;
Var
 vOldString,
 vStringBase,
 vTempString      : String;
 A, vLengthString : Integer;



 //string for debug only
 deb1, deb2: string;
Begin


 vOldString := bValue;
 vStringBase := '"ValueType":"';
 vLengthString := Length(vStringBase)-1;
 vTempString := Copy(bValue, Pos(vStringBase, bValue) + vLengthString, Length(bValue)-1);
 A := Pos(':', vTempString);
 vTempString := Copy(vTempString, A, Length(vTempString)-1);
 If vTempString[InitStrPos] = ':' Then
  vTempString:=vTempString.Remove(InitStrPos,1);// [InitStrPos]:=char(''); //Delete(vTempString, InitStrPos, 1);
 If vTempString[InitStrPos] = '"' Then
  vTempString:=vTempString.Remove(InitStrPos,1);//vTempString[InitStrPos]:='';//Delete(vTempString, InitStrPos, 1);
 If vTempString = '}' Then
  vTempString := '';
 If vTempString <> '' Then
  Begin
   For A := Length(vTempString)-1 Downto InitStrPos Do
    Begin
     If vTempString[Length(vTempString)-1] <> '}' Then
      vTempString:=vTempString.Remove(Length(vTempString)-1,1) // vTempString[Length(vTempString)-1]:='' //Delete(vTempString, Length(vTempString), 1)
     Else
      Begin
       vTempString:=vTempString.Remove(Length(vTempString)-1,1); //vTempString[Length(vTempString)-1]:='';//Delete(vTempString, Length(vTempString), 1);
       Break;
      End;
    End;
   If vTempString[Length(vTempString)-1] = '"' Then
    vTempString:=vTempString.Remove(Length(vTempString)-1,1); // vTempString[Length(vTempString)-1]:='';//Delete(vTempString, Length(vTempString), 1);
  End;
 Result := vTempString;
 deb1:= copy(result,length(result)-50,length(result)-1);
 bValue := StringReplace(bValue, Result, '', [rfReplaceAll]);
 deb1:= copy(bValue,length(bValue)-50,length(bValue)-1);
End;

{$ELSE}
Function CopyValue(Var bValue : String) : String;
Var
 vOldString,
 vStringBase,
 vTempString      : String;
 A, vLengthString : Integer;
Begin
 vOldString := bValue;
 vStringBase := '"ValueType":"';
 vLengthString := Length(vStringBase);
 vTempString := Copy(bValue, Pos(vStringBase, bValue) + vLengthString, Length(bValue));
 A := Pos(':', vTempString);
 vTempString := Copy(vTempString, A, Length(vTempString));
 If vTempString[InitStrPos] = ':' Then
  Delete(vTempString, InitStrPos, 1);
 If vTempString[InitStrPos] = '"' Then
  Delete(vTempString, InitStrPos, 1);
 If vTempString = '}' Then
  vTempString := '';
 If vTempString <> '' Then
  Begin
   For A := Length(vTempString) Downto InitStrPos Do
    Begin
     If vTempString[Length(vTempString)] <> '}' Then
      Delete(vTempString, Length(vTempString), 1)
     Else
      Begin
       Delete(vTempString, Length(vTempString), 1);
       Break;
      End;
    End;
   If vTempString[Length(vTempString)] = '"' Then
    Delete(vTempString, Length(vTempString), 1);
  End;
 Result := vTempString;
 bValue := StringReplace(bValue, Result, '', [rfReplaceAll]);
End;
{$IFEND}

Function TDWParams.Add(Item : TJSONParam): Integer;
Var
 vItem : ^TJSONParam;
Begin
 New(vItem);
 vItem^ := Item;
 vItem^.vEncoding := vEncoding;
 vItem^.JsonMode := vJsonMode;
 Result := TList(Self).Add(vItem);
End;

Constructor TDWParams.Create;
Begin
 Inherited;
 vJsonMode := jmDataware;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding := esUtf8;
 {$ELSE}
  vEncoding := esASCII;
 {$IFEND}
 {$ELSE}
 vEncoding := esUtf8;
 {$ENDIF}
End;

Function TDWParams.ToJSON: String;
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If I = 0 Then
    Result := TJSONParam(TList(Self).Items[I]^).ToJSON
   Else
    Result := Result + ', ' + TJSONParam(TList(Self).Items[I]^).ToJSON;
  End;
End;

{$IFDEF POSIX}
{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
Procedure TDWParams.FromJSON(JSON: String);
Var
 bJsonOBJ,
 bJsonValue : system.json.TJsonObject;
 bJsonArray : system.json.TJsonArray;
 JSONParam  : TJSONParam;
 I          : Integer;
Begin
 bJsonValue := TJSONObject.ParseJSONValue(Format('{"PARAMS":[%s]}', [JSON])) as TJSONObject; // udwjson.TJsonObject.Create(Format('{"PARAMS":[%s]}', [JSON]));
 Try
  bJsonArray  :=   bJsonValue.pairs[0].jsonvalue as TJsonArray; //  bJsonValue.optJSONArray(bJsonValue.names.get(0).ToString);
  For I := 0 To bJsonArray.count - 1 Do
   Begin
    JSONParam := TJSONParam.Create(vEncoding);
    bJsonOBJ  :=  bJsonArray.items[0] as TJSONObject;  //udwjson.TJsonObject.Create(bJsonArray.get(I).ToString);
    Try
     JSONParam.ParamName       := Lowercase  (removestr(bJsonOBJ.pairs[4].jsonstring.tostring,'"')); //         (bJsonOBJ.names.get(4).ToString);
     JSONParam.ObjectDirection := GetDirectionName (removestr(bJsonOBJ.pairs[1].jsonvalue.tostring,'"')); //   (bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
     JSONParam.ObjectValue     := GetValueType (removestr(bJsonOBJ.pairs[3].jsonvalue.tostring,'"'));    //       (bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString);
     JSONParam.Encoded         := GetBooleanFromString(removestr(bJsonOBJ.pairs[2].jsonvalue.tostring,'"')); //(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString);

      If (JSONParam.ObjectValue in [ovString, ovWideString]) And (JSONParam.Encoded) Then
      JSONParam.SetValue(DecodeStrings(removestr(bJsonOBJ.pairs[4].jsonvalue.tostring,'"'){$IFDEF FPC}, csUndefined{$ENDIF}))
     Else
      JSONParam.SetValue(bJsonOBJ.pairs[4].jsonvalue.tostring, JSONParam.Encoded);
     //JSONParam.SetValue(removestr(bJsonOBJ.pairs[4].jsonvalue.tostring,'"')); //bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString);
     Add(JSONParam);
    Finally
     //bJsonOBJ.Clean;
     FreeAndNil(bJsonOBJ);
    End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
 {$ELSE}
 Procedure TDWParams.FromJSON(JSON: String);
 Begin

    raise Exception.Create('Nao Usado no android)');//Não usado no android ainda

 End;
{$IFEND}
{$ELSE}
Procedure TDWParams.FromJSON(JSON: String);
Var
 bJsonOBJ,
 bJsonValue : udwjson.TJsonObject;
 bJsonArray : udwjson.TJsonArray;
 JSONParam  : TJSONParam;
 I          : Integer;
 vTempString : String;
Begin
 vTempString := Format('{"PARAMS":[%s]}', [JSON]);
 bJsonValue := udwjson.TJsonObject.Create(vTempString);
 Try
  bJsonArray  := bJsonValue.optJSONArray(bJsonValue.names.get(0).ToString);
  For I := 0 To bJsonArray.Length - 1 Do
   Begin
    JSONParam := TJSONParam.Create(vEncoding);
    bJsonOBJ  := bJsonArray.optJSONObject(I);
    Try
     JSONParam.ParamName       := Lowercase           (bJsonOBJ.names.get(4).ToString);
     JSONParam.ObjectDirection := GetDirectionName    (bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
     JSONParam.ObjectValue     := GetValueType        (bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString);
     JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString);
     If (JSONParam.ObjectValue in [ovString, ovWideString]) And (JSONParam.Encoded) Then
      JSONParam.SetValue(DecodeStrings(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString{$IFDEF FPC}, csUndefined{$ENDIF}))
     Else
      JSONParam.SetValue(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString, JSONParam.Encoded);
     Add(JSONParam);
    Finally
//     bJsonOBJ.Clean;
//     FreeAndNil(bJsonOBJ);
    End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;

{$ENDIF}

Procedure TDWParams.CopyFrom(DWParams : TDWParams);
Var
 I         : Integer;
 p,
 JSONParam : TJSONParam;
Begin
 Clear;
 For I := 0 To DWParams.Count -1 Do
  Begin
   p := DWParams.Items[I];
   JSONParam := TJSONParam.Create(DWParams.Encoding);
   JSONParam.CopyFrom(p);
   Add(JSONParam);
  End;
End;

Procedure TDWParams.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PJSONParam(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TDWParams.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

Destructor TDWParams.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TDWParams.GetRec(Index: Integer): TJSONParam;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TJSONParam(TList(Self).Items[Index]^);
End;

Function TDWParams.GetRecName(Index: String): TJSONParam;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(TJSONParam(TList(Self).Items[I]^).vParamName)) Then
    Begin
     Result := TJSONParam(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Function TDWParams.CountOutParams : Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For I := 0 To Count -1 Do
  Begin
   If TJSONParam(TList(Self).Items[I]^).ObjectDirection in [odOUT, odINOUT] Then
    Result := Result + 1;
  End;
End;

Function TDWParams.ParamsReturn: Boolean;
Var
 I : Integer;
Begin
 Result := False;
 For I := 0 To Self.Count - 1 Do
  Begin
   Result := Items[I].vObjectDirection In [odOUT, odINOUT];
   If Result Then
    Break;
  End;
End;

Procedure TDWParams.PutRec(Index: Integer; Item: TJSONParam);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TJSONParam(TList(Self).Items[Index]^) := Item;
End;

Procedure TDWParams.PutRecName(Index: String; Item: TJSONParam);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(TJSONParam(TList(Self).Items[I]^).vParamName)) Then
    Begin
     TJSONParam(TList(Self).Items[I]^) := Item;
     Break;
    End;
  End;
End;

Function EscapeQuotes(Const S: String): String;
Begin
 // Easy but not best performance
 Result := StringReplace(S,      '\', TSepValueMemString,    [rfReplaceAll]);
 Result := StringReplace(Result, '"', TQuotedValueMemString, [rfReplaceAll]);
End;

Function RevertQuotes(Const S: String): String;
Begin
 // Easy but not best performance
 Result := StringReplace(S,      TSepValueMemString,    '\', [rfReplaceAll]);
 Result := StringReplace(Result, TQuotedValueMemString, '"', [rfReplaceAll]);
End;

Constructor TJSONValue.Create;
Begin
 Inherited;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding := esUtf8;
 {$ELSE}
  vEncoding := esASCII;
 {$IFEND}
 {$ELSE}
 vEncoding := esUtf8;
 {$ENDIF}
 {$IFDEF FPC}
 vDatabaseCharSet := csUndefined;
 {$ENDIF}
 vTypeObject     := toObject;
 ObjectDirection := odINOUT;
 vObjectValue    := ovString;
 vtagName        := 'TAGJSON';
 vBinary         := True;
 vNullValue      := True;
 vJsonMode       := jmDataware;
End;

Destructor TJSONValue.Destroy;
Begin
 SetLength(aValue, 0);
 Inherited;
End;

Function TJSONValue.GetValueJSON(bValue: String): String;
Begin
 Result := bValue;
 {
 If vObjectValue In [ovString,        ovFixedChar,    ovWideString,
                     ovFixedWideChar, ovDate, ovTime, ovDateTime,
                     ovBlob, ovGraphic, ovOraBlob, ovOraClob,
                     ovMemo, ovWideMemo, ovFmtMemo] Then
  If bValue = '' Then
   Result := '""';
 }
End;

Function TJSONValue.IsNull: Boolean;
Begin
 Result := vNullValue;
End;

Function TJSONValue.FormatValue(bValue: String): String;
Var
 aResult : String;
 vInsertTag : Boolean;
Begin
 aResult    := Stringreplace(bValue, #000, '', [rfReplaceAll]);
 vInsertTag := vObjectValue In [ovDate, ovTime, ovDateTime,
                                ovBlob, ovGraphic, ovOraBlob, ovOraClob,
                                ovMemo, ovWideMemo, ovFmtMemo];
 If Trim(aResult) <> '' Then
  Begin
   If (aResult[InitStrPos] = '"')      And
      (aResult[Length(aResult) - FinalStrPos] = '"') Then
    Begin
     Delete(aResult, InitStrPos+FinalStrPos, 1);
     Delete(aResult, Length(aResult), 1);
    End;
  End;
 If Not vEncoded Then
  Begin
   If Trim(aResult) <> '' Then
    If Not(((Pos('{', aResult) > 0)  And
            (Pos('}', aResult) > 0)) Or
           ((Pos('[', aResult) > 0)  And
            (Pos(']', aResult) > 0))) Then
     If Not(vObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
      aResult := StringToJsonString(aResult);
  End;
 If (Trim(aResult) = '') And vInsertTag Then
  aResult := '""';
 If JsonMode = jmDataware Then
  Begin
   If (vTypeObject = toDataset) Or (vObjectValue  = ovObject) Then
    Result := Format(TValueFormatJSON,      ['ObjectType', GetObjectName(vTypeObject),         'Direction',
                                                           GetDirectionName(vObjectDirection), 'Encoded',
                                                           EncodedString,                      'ValueType',
                                                           GetValueType(vObjectValue),         vtagName,
                                                           GetValueJSON(aResult)])
   Else
    Begin
     If vObjectValue in [ovString, ovWideString, ovMemo,
                         ovWideMemo, ovFmtMemo, ovFixedChar] Then
      Result := Format(TValueFormatJSONValueS, ['ObjectType',  GetObjectName(vTypeObject),         'Direction',
                                                               GetDirectionName(vObjectDirection), 'Encoded',
                                                               EncodedString,                      'ValueType',
                                                               GetValueType(vObjectValue),         vtagName,
                                                               GetValueJSON(aResult)])
     Else
       If (vObjectValue In [ovFloat,  ovCurrency,  ovBCD,
                          ovFMTBcd, ovExtended]) Then
        Begin
          Result := Format(TValueFormatJSONValueS, ['ObjectType',  GetObjectName(vTypeObject),         'Direction',
                                                               GetDirectionName(vObjectDirection), 'Encoded',
                                                               EncodedString,                      'ValueType',
                                                               GetValueType(vObjectValue),         vtagName,
                                                               GetValueJSON(BuildStringFloat(aResult))]);
      End
      else
      Begin
       If (vObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
        Begin
         If ((((aResult <> '""') And
            Not((aResult[InitStrPos] = '"') and
                (aResult[Length(aResult) - FinalStrPos] = '"')))) And (vEncoded)) Or (Not(vEncoded) And (aResult = '')) Then
          aResult := '"' + aResult + '"'
         Else If (aResult = '') Then
          aResult := '""';
        End;
       Result := Format(TValueFormatJSONValue, ['ObjectType',  GetObjectName(vTypeObject),         'Direction',
                                                               GetDirectionName(vObjectDirection), 'Encoded',
                                                               EncodedString,                      'ValueType',
                                                               GetValueType(vObjectValue),         vtagName,
                                                               GetValueJSON(aResult)]);
      End;
    End;
  End
 Else
  Result := aResult;
End;

Function TJSONValue.GetValue: String;
Var
 vTempString : String;
Begin
 Result := '';
 If Length(aValue) = 0 Then
  Exit;
 {$IFDEF FPC}
 vTempString := vEncodingLazarus.GetString(aValue);
 {$ELSE}
 vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding));
 {$ENDIF}
{$IF Defined(ANDROID) or defined(IOS)} //Alterado para IOS Brito
If Length(vTempString) > 0 Then
 Begin
  If vTempString[InitStrPos]          = '"' Then
    vTempString:=vTempString.Substring(1, Length(vTempString)-1);
    //vTempString:= copy(vTempString,1,Length(vTempString)-1);
   //Delete(vTempString, InitStrPos, 1);
  If vTempString[Length(vTempString)-1] = '"' Then
    vTempString:= copy(vTempString,InitStrPos,Length(vTempString)-1);
   //Delete(vTempString, Length(vTempString)-1, 1);
  vTempString := Trim(vTempString);
 End;
If vEncoded Then
 Begin
  If (vObjectValue In [ovBytes, ovVarBytes, ovBlob,
                       ovGraphic, ovOraBlob, ovOraClob]) And (vBinary) Then
   vTempString := vTempString
  Else
   Begin
    If Length(vTempString) > 0 Then
     vTempString := DecodeStrings(vTempString);
   End;
 End
Else
Begin
   If Length(vTempString) = 0 Then
    Begin
      vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding));
    End;
  End;

If vObjectValue = ovString Then
 Begin
  If vTempString <> '' Then
   If vTempString[InitStrPos] = '"' Then
    Begin
     Delete(vTempString, 1, 1);
     If vTempString[Length(vTempString)] = '"' Then
      Delete(vTempString, Length(vTempString), 1);
    End;
  Result := vTempString;
 End
Else
 Result := vTempString;
{$ELSE}
 If Length(vTempString) > 0 Then
  Begin
   If vTempString[InitStrPos]          = '"' Then
    Delete(vTempString, InitStrPos, 1);
   If vTempString[Length(vTempString)] = '"' Then
    Delete(vTempString, Length(vTempString), 1);
   vTempString := Trim(vTempString);
  End;
 If vEncoded Then
  Begin
   If (vObjectValue In [ovBytes, ovVarBytes, ovBlob,
                        ovGraphic, ovOraBlob, ovOraClob]) And (vBinary) Then
    vTempString := vTempString
   Else
    Begin
     If Length(vTempString) > 0 Then
      vTempString := DecodeStrings(vTempString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
    End;
  End
 Else
  Begin
   If Length(vTempString) = 0 Then
    Begin
     {$IFDEF FPC}
      vTempString := vEncodingLazarus.GetString(aValue);
     {$ELSE}
      vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding));
     {$ENDIF}
    End;
  End;
 If vObjectValue = ovString Then
  Begin
   If vTempString <> '' Then
    If vTempString[InitStrPos] = '"' Then
     Begin
      Delete(vTempString, 1, 1);
      If vTempString[Length(vTempString)] = '"' Then
       Delete(vTempString, Length(vTempString), 1);
     End;
   Result := vTempString;
  End
 Else
  Result := vTempString;
 {$IFEND}
 vTempString := '';
End;

Function TJSONValue.DatasetValues(bValue         : TDataset;
                                  DateTimeFormat : String = '';
                                  JsonModeD      : TJsonMode = jmDataware) : String;
Var
 vLines : String;
 A      : Integer;
 Function GenerateHeader: String;
 Var
  I              : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc       : string;
 Begin
  For I := 0 To bValue.Fields.Count - 1 Do
   Begin
    vPrimary  := 'N';
    vAutoinc  := 'N';
    vReadOnly := 'N';
    If pfInKey in bValue.Fields[I].ProviderFlags Then
     vPrimary := 'S';
    vRequired := 'N';
    If bValue.Fields[I].Required Then
     vRequired := 'S';
    If Not (bValue.Fields[I].CanModify) Then
     vReadOnly := 'S';
    {$IFNDEF FPC}{$IF CompilerVersion > 21}
     If bValue.Fields[I].AutoGenerateValue = arAutoInc Then
      vAutoinc := 'S';
    {$ELSE}
     vAutoinc := 'N';
    {$IFEND}
    {$ENDIF}
    If bValue.Fields[I].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                     {$IFEND}{$ENDIF}ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
     vGenerateLine := Format(TJsonDatasetHeader, [bValue.Fields[I].FieldName,
                                                  GetFieldType(bValue.Fields[I].DataType),
                                                  vPrimary, vRequired, TFloatField(bValue.Fields[I]).Size,
                                                  TFloatField(bValue.Fields[I]).Precision, vReadOnly, vAutoinc])
    Else
     vGenerateLine := Format(TJsonDatasetHeader, [bValue.Fields[I].FieldName,
                                                  GetFieldType(bValue.Fields[I].DataType),
                                                  vPrimary, vRequired, bValue.Fields[I].Size, 0, vReadOnly, vAutoinc]);
    If I = 0 Then
     Result := vGenerateLine
    Else
     Result := Result + ', ' + vGenerateLine;
   End;
 End;
 Function GenerateLine: String;
 Var
  I             : Integer;
  vTempField,
  vTempValue    : String;
  bStream       : TStream;
  vStringStream : TStringStream;
 Begin
  For I := 0 To bValue.Fields.Count - 1 Do
   Begin
    Case JsonModeD Of
     jmDataware : Begin
                  End;
     jmPureJSON,
     jmMongoDB  : vTempField := Format('"%s": ', [bValue.Fields[I].FieldName]);
    End;
    If Not bValue.Fields[I].IsNull then
     Begin
      If bValue.Fields[I].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                       {$IFEND}{$ENDIF}ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
       vTempValue := Format('%s"%s"', [vTempField, BuildStringFloat(FloatToStr(bValue.Fields[I].AsFloat))])
      Else If bValue.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
       Begin
        vStringStream := TStringStream.Create('');
        bStream := bValue.CreateBlobStream(TBlobField(bValue.Fields[I]), bmRead);
        Try
         bStream.Position := 0;
         {$IFDEF FPC}
         vStringStream.CopyFrom(bStream, bStream.Size);
         {$ELSE}
         {$IF CompilerVersion > 21}
         vStringStream.LoadFromStream   (bStream);
         {$ELSE}
         vStringStream.CopyFrom(bStream, bStream.Size);
         {$IFEND}
         {$ENDIF}
         vTempValue := Format('%s%s',   [vTempField, StreamToHex(vStringStream)]);
        Finally
         vStringStream.Free;
         bStream.Free;
        End;
       End
      Else
       Begin
        If bValue.Fields[I].DataType in      [ftString,  ftWideString, ftMemo,
                                              {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                              {$IFEND}{$ENDIF}
                                              ftFmtMemo, ftFixedChar] Then
         Begin
          If vEncoded Then
           Begin
            If vJsonMode in [jmPureJSON, jmMongoDB] Then
             Begin
              {$IFDEF FPC}
              vTempValue := Format('%s"%s"',      [vTempField, EncodeStrings(StringToJsonString(bValue.Fields[I].AsString), vDatabaseCharSet)]);
              {$ELSE}
              vTempValue := Format('%s"%s"',      [vTempField, EncodeStrings(StringToJsonString(bValue.Fields[I].AsString))]);
              {$ENDIF}
             End
            Else
             Begin
              {$IFDEF FPC}
              vTempValue := Format('%s"%s"',      [vTempField, EncodeStrings(bValue.Fields[I].AsString, vDatabaseCharSet)]);
              {$ELSE}
              vTempValue := Format('%s"%s"',      [vTempField, EncodeStrings(bValue.Fields[I].AsString)]);
              {$ENDIF}
             End;
           End
          Else
           Begin
            {$IFDEF FPC}
            vTempValue := Format('%s"%s"',      [vTempField, StringToJsonString(GetStringEncode(bValue.Fields[I].AsString, vDatabaseCharSet))]);
            {$ELSE}
            vTempValue := Format('%s"%s"',      [vTempField, StringToJsonString(bValue.Fields[I].AsString)]);
            {$ENDIF}
           End;
         End
        Else If bValue.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If DateTimeFormat <> '' Then
           vTempValue     := Format('%s"%s"',    [vTempField, FormatDateTime(DateTimeFormat, bValue.Fields[I].AsDateTime)])
          Else
           vTempValue     := Format('%s"%s"',      [vTempField, inttostr(DateTimeToUnix(bValue.Fields[I].AsDateTime))]);
         End
        Else
         vTempValue     := Format('%s"%s"',      [vTempField, bValue.Fields[I].AsString]);    //asstring
       End;
     End
    Else
     vTempValue := Format('%s"%s"', [vTempField, 'null']);
    If I = 0 Then
     Result := vTempValue
    Else
     Result := Result + ', ' + vTempValue;
   End;
 End;
Begin
 bValue.DisableControls;
 Try
  If Not bValue.Active Then
   bValue.Open;
  bValue.First;
  Case JsonModeD Of
   jmDataware : Begin
                 Result    := '{"fields":[' + GenerateHeader + ']}, {"lines":[%s]}';
                End;
   jmPureJSON : Begin
                End;
   jmMongoDB  : Begin
                End;
  End;
  A := 0;
  {$IFDEF  POSIX}  //aqui para linux tem que ser diferente o rastrwio da query
  for A := 0 to bvalue.recordcount-1 do
  //While Not bValue.Eof Do
   Begin
    Case JsonModeD Of
     jmDataware : Begin
                   If bValue.RecNo = 1 Then
                    vLines := Format('{"line%d":[%s]}', [A, GenerateLine])
                   Else
                    vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
                  End;
     jmPureJSON,
     jmMongoDB  : Begin
                   If bValue.RecNo = 1 Then
                    vLines := Format('{%s}', [GenerateLine])
                   Else
                    vLines := vLines + Format(', {%s}', [GenerateLine]);
                  End;
    End;
    bValue.Next;
    //Inc(A);
   End;
  {$ELSE}
  While Not bValue.Eof Do
   Begin
    Case JsonModeD Of
     jmDataware : Begin
                   If bValue.RecNo = 1 Then
                    vLines := Format('{"line%d":[%s]}', [A, GenerateLine])
                   Else
                    vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
                  End;
     jmPureJSON,
     jmMongoDB  : Begin
                   If bValue.RecNo = 1 Then
                    vLines := Format('{%s}', [GenerateLine])
                   Else
                    vLines := vLines + Format(', {%s}', [GenerateLine]);
                  End;
    End;
    bValue.Next;
    Inc(A);
   End;
  {$ENDIF}
  Case JsonModeD Of
   jmDataware : Result := Format(Result, [vLines]);
   jmPureJSON,
   jmMongoDB  : Result := Format('{"%s": [%s]}', [vtagName, vLines]);
  End;
  bValue.First;
 Finally
  bValue.EnableControls;
 End;
End;

Function TJSONValue.EncodedString: String;
Begin
 If vEncoded Then
  Result := 'true'
 Else
  Result := 'false';
End;

Procedure TJSONValue.LoadFromDataset(TableName      : String;
                                     bValue         : TDataset;
                                     EncodedValue   : Boolean   = True;
                                     JsonModeD      : TJsonMode = jmDataware;
                                     DateTimeFormat : String = ''{$IFDEF FPC};
                                     CharSet        : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 vTagGeral        : String;
Begin
 vTypeObject      := toDataset;
 vObjectDirection := odINOUT;
 vObjectValue     := ovDataSet;
 vtagName         := Lowercase(TableName);
 vEncoded         := EncodedValue;
 vTagGeral        := DatasetValues(bValue, DateTimeFormat, JsonModeD);
 {$IFDEF FPC}
 If vEncodingLazarus = Nil Then
  SetEncoding(vEncoding);
 aValue           := TIdBytes(vEncodingLazarus.GetBytes(vTagGeral));
 {$ELSE}
 aValue           := ToBytes(vTagGeral, GetEncodingID(vEncoding));
 {$ENDIF}
 vJsonMode        := JsonModeD;
End;

Function TJSONValue.ToJSON: String;
Var
 vTempValue : String;
Begin
 Result := '';
 {$IFDEF FPC}
 If vEncodingLazarus = Nil Then
  SetEncoding(vEncoding);
 If vEncoded Then
  vTempValue := FormatValue(vEncodingLazarus.GetString(aValue))
 Else If vEncodingLazarus.GetString(aValue) = '' Then
  Begin
   If Not(vObjectValue in [ovString, ovFixedChar,   ovWideString,
                           ovFixedWideChar, ovBlob, ovGraphic,
                           ovOraBlob, ovOraClob, ovMemo, ovWideMemo, ovFmtMemo]) Then
    vTempValue  := FormatValue('""')
   Else
    vTempValue  := FormatValue('');
  End
 Else
  vTempValue  := FormatValue(vEncodingLazarus.GetString(aValue));
 {$ELSE}
 If vEncoded Then
  vTempValue := FormatValue(BytesToString(aValue, GetEncodingID(vEncoding)))
 Else If BytesArrToString(aValue, GetEncodingID(vEncoding)) = '' Then
  Begin
   If Not(vObjectValue in [ovString, ovFixedChar,   ovWideString,
                           ovFixedWideChar, ovBlob, ovGraphic,
                           ovOraBlob, ovOraClob, ovMemo, ovWideMemo, ovFmtMemo]) Then
    vTempValue  := FormatValue('"null"')
   Else
    vTempValue  := FormatValue('');
  End
 Else
  vTempValue  := FormatValue(BytesArrToString(aValue, GetEncodingID(vEncoding)));
 {$ENDIF}
 If Not(Pos('"TAGJSON":}', vTempValue) > 0) Then
  Result := vTempValue;
End;

Procedure TJSONValue.ToStream(Var bValue: TMemoryStream);
Begin
 If Length(aValue) > 0 Then
  Begin
   bValue := TMemoryStream.Create;
   bValue.Write(aValue[0], -1);
  End
 Else
  bValue := Nil;
End;

Function TJSONValue.Value: String;
Begin
 Result := GetValue;
End;

{$IF Defined(ANDROID) or Defined(IOS)} //Alterado para IOS Brito
Procedure TJSONValue.WriteToDataset(DatasetType : TDatasetType;
                                    JSONValue   : String;
                                    DestDS      : TDataset;
                                    ClearDataset : Boolean = False{$IFDEF FPC};
                                    CharSet     : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 FieldValidate  : TFieldNotifyEvent;
 bJsonOBJ,
 bJsonArraySub,
 bJsonValue     : system.json.TJsonObject;
 bJsonOBJTemp,
 bJsonArray     : system.json.TJsonArray;
 A, J, I        : Integer;
 FieldDef       : TFieldDef;
 Field          : TField;
 vOldReadOnly,
 vFindFlag      : Boolean;
 vBlobStream    : TStringStream;
 ListFields     : TStringList;
 vConvValue,
 vTempValue     : String;
 vFieldDefinition : TFieldDefinition;
 Procedure SetValueA(Field : TField;
                     Value : String);
 Var
  vTempValue    : String;
 Begin
  Case Field.DataType Of
   ftUnknown,
   ftString,
   ftFixedChar,
   ftWideString : Begin
                   Field.AsString := Value;
                  End;
   ftAutoInc,
   ftSmallint,
   ftInteger,
   ftLargeint,
   ftWord,
   {$IFNDEF FPC}
    {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    ftLongWord,
    {$IFEND}
   {$ENDIF}
   ftBoolean    : Begin
                   If Value <> '' Then
                    Begin
                     If Field.DataType = ftBoolean Then
                      Begin
                       If (Value = '0') Or (Value = '1') Then
                        Field.AsBoolean := StrToInt(Value) = 1
                       Else
                        Field.AsBoolean := lowercase(Value) = 'true';
                      End
                     Else
                      Field.AsInteger := StrToInt(Value);
                    End;
                  End;
   ftFloat,
   ftCurrency,
   ftBCD,
   ftSingle,
   ftFMTBcd     : Begin
                   vTempValue  := BuildFloatString(Value);
                   If vTempValue <> '' Then
                    Begin
                     Case Field.DataType Of
                      ftFloat  : Field.AsFloat    := StrToFloat(vTempValue);
                      ftCurrency,
                      ftBCD,
					  ftSingle,
                      ftFMTBcd : Field.AsCurrency := StrToFloat(vTempValue);
                      End;
                    End;
                  End;
   ftDate,
   ftTime,
   ftDateTime,
   ftTimeStamp  : Begin
                      vTempValue        := Value;
                      If vTempValue <> '' Then
                       If StrToInt64(vTempValue) >0 then //  StrToInt(vTempValue) > 0 Then
                        Field.AsDateTime := UnixToDateTime(strtoint64(vTempValue));

//                   vTempValue        := Value;
//                   If vTempValue <> '' Then
//                    Field.AsDateTime := UnixToDateTime(strtoint(vTempValue));
                  End;
  End;
 End;

 Function FieldIndex(FieldName: String): Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To ListFields.Count - 1 Do
   Begin
    If Uppercase(ListFields[I]) = Uppercase(FieldName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
If JSONValue = '' Then
  Exit;
 ListFields := TStringList.Create;
 Try
  If Pos('[', JSONValue) = 0 Then
   Begin
    FreeAndNil(ListFields);
    Exit;
   End;
  bJsonValue := TJsonObject.ParseJSONValue(JSONValue) as system.json.TJsonObject;
  If bJsonValue.count > 0 Then
   Begin
    vTypeObject      := GetObjectName(removestr(bJsonvalue.Pairs[0].JsonValue.tostring,'"') );       // GetObjectName       (bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
    vObjectDirection := GetDirectionName(removestr(bjsonvalue.Pairs[1].JsonValue.tostring,'"'));      //GetDirectionName    (bJsonValue.opt(bJsonValue.names.get(1).ToString).ToString);
    vEncoded         := GetBooleanFromString( removestr(bJsonvalue.Pairs[2].JsonValue.tostring,'"')); //GetBooleanFromString(bJsonValue.opt(bJsonValue.names.get(2).ToString).ToString);
    vObjectValue     := GetValueType( removestr(bJsonvalue.Pairs[3].JsonValue.tostring,'"'));         //GetValueType        (bJsonValue.opt(bJsonValue.names.get(3).ToString).ToString);
    vtagName         := Lowercase ( removestr(bJsonvalue.Pairs[4].JsonString.tostring,'"'));           //   (bJsonValue.names.get(4).ToString);
    // Add Field Defs
    DestDS.DisableControls;
    If Not(DestDS is TRESTDWClientSQL) Then
     TRESTDWClientSQL(DestDS).SetInDesignEvents(False);
    TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
    DestDS.DisableControls;
    If DestDS.Active Then
     DestDS.Close;
    bJsonArray    :=  bJsonValue.Pairs[4].JsonValue as tjsonarray; //  bJsonValue.optJSONArray   (bJsonValue.names.get(4).ToString);
    bJsonArraySub := bJsonArray.Items[0] as Tjsonobject; //  bJsonArray.optJSONObject  (0);
    bJsonArray    := bJsonArraySub.Pairs[0].JsonValue as Tjsonarray; // optJSONArray(bJsonArraySub.names.get(0).ToString);

	TRESTDWClientSQL(DestDS).NewFieldList;
    vFieldDefinition := TFieldDefinition.Create;

   If (TRESTDWClientSQL(DestDS).Fields.Count = 0) Then
      DestDS.FieldDefs.Clear
     Else
      Begin
       If (DestDS is TRESTDWClientSQL) Then
       For J := 0 To TRESTDWClientSQL(DestDS).Fields.Count - 1 Do
        Begin
         vFieldDefinition.FieldName := TRESTDWClientSQL(DestDS).Fields[J].FieldName;
         vFieldDefinition.DataType  := TRESTDWClientSQL(DestDS).Fields[J].DataType;
         vFieldDefinition.Size      := TRESTDWClientSQL(DestDS).Fields[J].Size;
         If vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                                      {$IFEND}{$ENDIF}ftFMTBcd] Then
          vFieldDefinition.Precision := TFloatField(TRESTDWClientSQL(DestDS).Fields[J]).Precision;
         vFieldDefinition.Required   := TRESTDWClientSQL(DestDS).Fields[J].Required;
         TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
        End;
      End;
   For J := 0 To TRESTDWClientSQL(DestDS).Fields.Count - 1 Do
    TRESTDWClientSQL(DestDS).Fields[J].Required := False;
   DestDS.FieldDefs.BeginUpdate;
   For J := 0 To bJsonArray.Count - 1 Do
     Begin
      bJsonOBJ := bJsonarray.Items[J] as Tjsonobject ; // Create(bJsonArray.get(J).ToString);
      Try
       If Trim(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"')) <> '' Then
        Begin
		  vTempValue          := removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"');
          FieldDef            := TRESTDWClientSQL(DestDS).FieldDefExist(vTempValue);
		 If (FieldDef = Nil) Then
          Begin
          If (TRESTDWClientSQL(DestDS).FieldExist(vTempValue) = Nil) And (DestDS is TRESTDWClientSQL) Then
           Begin
		    vFieldDefinition.FieldName := vTempValue;
		    vFieldDefinition.DataType  := GetFieldType(removestr(bJsonOBJ.Pairs[1].JsonValue.tostring,'"'));
			vFieldDefinition.Size      := StrToInt(removestr(bJsonOBJ.Pairs[4].JsonValue.tostring,'"'));
			If vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                                          {$IFEND}{$ENDIF}ftFMTBcd] Then
             vFieldDefinition.Precision := StrToInt(removestr(bJsonOBJ.Pairs[5].JsonValue.tostring,'"'));
             vFieldDefinition.Required   := Uppercase(removestr(bJsonOBJ.Pairs[3].JsonValue.tostring,'"')) = 'S';
             TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
			end;
			FieldDef          := DestDS.FieldDefs.AddFieldDef;
           FieldDef.Name     := vTempValue;
           FieldDef.DataType := GetFieldType(removestr(bJsonOBJ.Pairs[1].JsonValue.tostring,'"'));
           FieldDef.Size     := StrToInt(removestr(bJsonOBJ.Pairs[4].JsonValue.tostring,'"'));
           If Not(FieldDef.DataType In [ftFloat,    ftCurrency, ftBCD, ftExtended,
		                                ftFMTBcd]) Then
            Begin
             FieldDef.Size      := StrToInt(removestr(bJsonOBJ.Pairs[4].JsonValue.tostring,'"')); // bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString);
             FieldDef.Precision := StrToInt(removestr(bJsonOBJ.Pairs[5].JsonValue.tostring,'"')); //bJsonOBJ.opt(bJsonOBJ.names.get(5).ToString).ToString);
            End;
          End;
        End;
      Finally
      End;
     End;
    FreeAndNil(vFieldDefinition);
    If DestDS Is TRESTDWClientSQL Then              //movido para esse qdo usado cliente dataset
     TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
    DestDS.FieldDefs.EndUpdate;
    Try
     TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
     TRESTDWClientSQL(DestDS).Inactive := True;
     TRESTDWClientSQL(DestDS).CreateDataSet;
      //DestDS.Open;
     If Not DestDS.Active Then
      Begin
       bJsonValue.Free;
       ListFields.Free;
       Raise Exception.Create('Error on Parse JSON Data...');
       Exit;
      End;
     TRESTDWClientSQL(DestDS).Active   := True;
     TRESTDWClientSQL(DestDS).Inactive := False;
    Except
    End;
    //Clean Invalid Fields
    bJsonArray    := bJsonArraySub.Pairs[0].JsonValue as tjsonarray; //bJsonArraySub.optJSONArray(bJsonArraySub.names.get(0).ToString);
    For A := TRESTDWClientSQL(DestDS).Fields.Count -1 DownTo 0 Do
     Begin
      If TRESTDWClientSQL(DestDS).Fields[A].FieldKind = fkData Then
       Begin
        vFindFlag := False;
        For J := 0 To bJsonArray.count - 1 Do
         Begin
          bJsonOBJ := bJsonarray.Items[j] as Tjsonobject; // udwjson.TJsonObject.Create(bJsonArray.get(J).ToString);
          Try
           If Trim(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"')) <> '' Then //Trim(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) <> '' Then
            Begin
             vFindFlag := Lowercase(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"')) =
                          Lowercase(TRESTDWClientSQL(DestDS).Fields[A].FieldName);
             If vFindFlag Then
              Break;
            End;
          Finally
          End;
         End;
        If Not vFindFlag Then
         TRESTDWClientSQL(DestDS).Fields.Remove(TRESTDWClientSQL(DestDS).Fields[A]);
       End;
     End;
    //Add Set PK Fields
    bJsonArray    := bJsonValue.Pairs[4].JsonValue as Tjsonarray; //   bJsonValue.optJSONArray   (bJsonValue.names.get(4).ToString);
    bJsonArraySub := bJsonArray.Items[0] as Tjsonobject; //optJSONObject  (0);
    bJsonArray    := bJsonArraySub.Pairs[0].JsonValue as tjsonarray; // bJsonArraySub.optJSONArray(bJsonArraySub.names.get(0).ToString);
    For J := 0 To bJsonArray.Count - 1 Do
     Begin
      bJsonOBJ    := bJsonarray.Items[j] as Tjsonobject;; // Create(bJsonArray.get(J).ToString);
      Try
       If Uppercase(Trim(removestr(bJsonOBJ.Pairs[2].JsonValue.tostring,'"'))) = 'S' then //    bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString)) = 'S' Then
        Begin
         {$IFDEF CLIENTDATASET}
           Field := TClientDataset(DestDS).FindField(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"'));
         {$ENDIF}
        // {$IFDEF RESJEDI}
         //  Field := TJvMemoryData(DestDS).FindField(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString);
         //{$ENDIF}
         {$IFDEF RESTKBMMEMTABLE}
           Field := Tkbmmemtable(DestDS).FindField(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"'));
         {$ENDIF}
         {$IFDEF RESTFDMEMTABLE}
           Field := TFDmemtable(DestDS).FindField(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"'));
         {$ENDIF}
         If Field <> Nil Then
          Begin
           If Field.FieldKind = fkData Then
            Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
           Else
            Field.ProviderFlags := [];
         {$IFNDEF FPC}{$IF CompilerVersion > 21}
         If bJsonOBJ.Count > 6 then // names.Length > 6 Then
          Begin
           If (Uppercase(Trim( removestr(bJsonOBJ.Pairs[7].JsonValue.tostring,'"' ))) = 'S') then //  bJsonOBJ.opt(bJsonOBJ.names.get(6).ToString).ToString)) = 'S') Then
            Field.AutoGenerateValue := arAutoInc;
          End;
         {$IFEND}
         {$ENDIF}
         end;
        End;
      Finally
      End;
     End;
    For A := 0 To DestDS.Fields.Count - 1 Do
     Begin
      vFindFlag := False;
      If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
      If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
       Begin
        For J := 0 To bJsonArray.count - 1 Do
         Begin
          bJsonOBJ := bJsonArray.Items[J] as Tjsonobject;  //uDWJSON.TJsonObject.Create(bJsonArray.get(J).ToString);
          If Trim(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"' )) <> '' then //    bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) <> '' Then
           Begin
            vFindFlag := Uppercase(Trim(removestr(bJsonOBJ.Pairs[0].JsonValue.tostring,'"' ))) =
			             Uppercase(DestDS.Fields[A].FieldName); // bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString)) = Uppercase(DestDS.Fields[A].FieldName);
            If vFindFlag Then
             Begin
              ListFields.Add(IntToStr(J));
              Break;
             End;
           End;
         End;
       End;
      If Not vFindFlag Then
       ListFields.Add('-1');
     End;
	 If TRESTDWClientSQL(DestDS).GetInDesignEvents Then
     Begin
      //bJsonValue.Clean;
      FreeAndNil(bJsonValue);
      ListFields.Free;
      TRESTDWClientSQL(DestDS).SetInDesignEvents(False);
      Exit;
     End;
    bJsonArray    := bJsonValue.Pairs[4].JsonValue as Tjsonarray;  // bJsonValue.optJSONArray(bJsonValue.names.get(4).ToString);
    bJsonArraySub := bJsonarray.Items[1] as Tjsonobject; //    bJsonArray.optJSONObject(1);
    bJsonArray    := bJsonArraySub.Pairs[0].JsonValue as Tjsonarray; //   bJsonArraySub.optJSONArray(bJsonArraySub.names.get(0).ToString);
    If DestDS Is TRESTDWClientSQL Then
     TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
    For J := 0 To bJsonArray.count - 1 Do
     Begin
      bJsonOBJ     := bJsonArray.Items[J] as Tjsonobject; //  uDWJSON.TJsonObject.Create(bJsonArray.get(J).ToString);
      bJsonOBJTemp := bJsonOBJ.Pairs[0].JsonValue as tJsonarray; //   bJsonOBJ.optJSONArray(bJsonOBJ.names.get(0).ToString);
      TRESTDWClientSQL(DestDS).Append;
      Try
       For I := 0 To DestDS.Fields.Count - 1 Do
        Begin
          vOldReadOnly  := TRESTDWClientSQL(DestDS).Fields[I].ReadOnly;
         FieldValidate := TRESTDWClientSQL(DestDS).Fields[I].OnValidate;
		 TRESTDWClientSQL(DestDS).Fields[I].OnValidate := Nil;
         TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := False;
		 If (TRESTDWClientSQL(DestDS).Fields[I].FieldKind = fkLookup) Then
          Begin
           TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
           TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
           Continue;
          End;
         If (I >= ListFields.Count) then
          Begin
           TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
           TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
           Continue;
          End;
          If (StrToInt(ListFields[I]) = -1) Or
		  Not(TRESTDWClientSQL(DestDS).Fields[I].FieldKind = fkData) Then
           Begin
            TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
            TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
            Continue;
           End;
		   vTempValue := removestr(bJsonOBJTemp.items[StrToInt(ListFields[I])].Value,'"');
         If TRESTDWClientSQL(DestDS).Fields[I].DataType In [ftGraphic,     ftParadoxOle, ftDBaseOle,
                                                            ftTypedBinary, ftCursor,     ftDataSet,
                                                            ftBlob,        ftOraBlob,    ftOraClob
                                                            {$IFNDEF FPC}{$IF CompilerVersion > 21},
                                                            ftParams, ftStream{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> 'null') And
              (vTempValue <> '')     Then
            Begin
             HexStringToStream(vTempValue, vBlobStream);
             Try
              vBlobStream.Position := 0;
              TBlobField(TRESTDWClientSQL(DestDS).Fields[I]).LoadFromStream(vBlobStream);
             Finally
              {$IFNDEF FPC}
              {$IF CompilerVersion > 21}
               vBlobStream.Clear;
              {$IFEND}
              {$ENDIF}
              FreeAndNil(vBlobStream);
             End;
            End;
          End
         Else
          Begin
           If (Lowercase(vTempValue) <> 'null') Then
            Begin
             If TRESTDWClientSQL(DestDS).Fields[I].DataType in [ftString, ftWideString,
                                                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo, {$IFEND}{$ENDIF}
                                                               ftMemo, ftFmtMemo, ftFixedChar] Then
              Begin
               If vTempValue = '' Then
                TRESTDWClientSQL(DestDS).Fields[I].Value := ''
               Else
                Begin
                 If vEncoded Then
                  TRESTDWClientSQL(DestDS).Fields[I].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                 Else
                  TRESTDWClientSQL(DestDS).Fields[I].AsString := vTempValue;
                End;
              End
             Else if (vTempValue <> '') then
              SetValueA(TRESTDWClientSQL(DestDS).Fields[I], vTempValue);
            End;
          End;
         TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
         TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
        End;
      Finally
       vTempValue := '';
      End;
      TRESTDWClientSQL(DestDS).Post;
     End;
    For J := 0 To TRESTDWClientSQL(DestDS).FieldListCount -1 Do
     Begin
      If Not(TRESTDWClientSQL(DestDS).FieldExist(TRESTDWClientSQL(DestDS).ServerFieldList[J].FieldName) = Nil) Then
       TRESTDWClientSQL(DestDS).FindField(TRESTDWClientSQL(DestDS).ServerFieldList[J].FieldName).Required := TRESTDWClientSQL(DestDS).ServerFieldList[J].Required;
     End;
   End
  Else
   Begin
    DestDS.Close;
    Raise Exception.Create('Invalid JSON Data...');
   End;
 Finally
  //bJsonValue.Clean;
  FreeAndNil(bJsonValue);
  ListFields.Free;
  If DestDS.Active Then
   DestDS.First;
  If DestDS Is TRESTDWClientSQL Then
   TRESTDWClientSQL(DestDS).SetInBlockEvents(False);
  If DestDS is TRESTDWClientSQL Then
   Begin
    If TRESTDWClientSQL(DestDS).State = dsBrowse Then
     Begin
      If TRESTDWClientSQL(DestDS).RecordCount = 0 Then
       TRESTDWClientSQL(DestDS).PrepareDetailsNew
      Else
       TRESTDWClientSQL(DestDS).PrepareDetails(True);
     End;
   End;
  DestDS.EnableControls;
 End;
End;
{$ELSE}
Procedure TJSONValue.WriteToDataset(DatasetType : TDatasetType;
                                    JSONValue   : String;
                                    DestDS      : TDataset;
                                    ClearDataset : Boolean = False{$IFDEF FPC};
                                    CharSet     : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 FieldValidate  : TFieldNotifyEvent;
 bJsonOBJ,
 bJsonArraySub,
 bJsonValue     : udwjson.TJsonObject;
 bJsonOBJTemp,
 bJsonArray     : udwjson.TJsonArray;
 A, J, I        : Integer;
 FieldDef       : TFieldDef;
 Field          : TField;
 vOldReadOnly,
 vFindFlag      : Boolean;
 vBlobStream    : TStringStream;
 ListFields     : TStringList;
 vConvValue,
 vTempValue     : String;
 vFieldDefinition : TFieldDefinition;
 Procedure SetValueA(Field : TField;
                     Value : String);
 Var
  vTempValue    : String;
 Begin
  Case Field.DataType Of
   ftUnknown,
   ftString,
   ftFixedChar,
   ftWideString : Begin
                   Field.AsString := Value;
                  End;
   ftAutoInc,
   ftSmallint,
   ftInteger,
   ftLargeint,
   ftWord,
   {$IFNDEF FPC}
    {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    ftByte,
    ftLongWord,
    {$IFEND}
   {$ENDIF}
   ftBoolean    : Begin
                   If Value <> '' Then
                    Begin
                     If Field.DataType = ftBoolean Then
                      Begin
                       If (Value = '0') Or (Value = '1') Then
                        Field.AsBoolean := StrToInt(Value) = 1
                       Else
                        Field.AsBoolean := lowercase(Value) = 'true';
                      End
                     Else
                      Begin
                       If Field.DataType = ftLargeint Then
                        Field.Value := StrToInt64(Value)
                       Else
                        Field.AsInteger := StrToInt(Value);
                      End;
                    End;
                  End;
                  ftFloat,
                  ftCurrency,
                  ftBCD,
            		  {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                  {$IFEND}{$ENDIF}
                  ftFMTBcd     : Begin
                                  vTempValue  := BuildFloatString(Value);
                                  If vTempValue <> '' Then
                                   Begin
                                    Case Field.DataType Of
                                     ftFloat  : Field.AsFloat    := StrToFloat(vTempValue);
                                     ftCurrency,
                                     ftBCD,
			    	                         {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                     {$IFEND}{$ENDIF}
                                     ftFMTBcd : Field.AsCurrency := StrToFloat(vTempValue);
                                     End;
                                   End;
                                 End;
                  ftDate,
                  ftTime,
                  ftDateTime,
                  ftTimeStamp  : Begin
                                  vTempValue        := Value;
                                  If vTempValue <> '' Then
                                   If StrToInt64(vTempValue) >0 then //  StrToInt(vTempValue) > 0 Then
                                    Field.AsDateTime := UnixToDateTime(strtoint64(vTempValue));
                                 End;
  End;
 End;
 Function FieldIndex(FieldName: String): Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To ListFields.Count - 1 Do
   Begin
    If Uppercase(ListFields[I]) = Uppercase(FieldName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
 If JSONValue = '' Then
  Exit;
 ListFields := TStringList.Create;
 Try
  If Pos('[', JSONValue) = 0 Then
   Begin
    FreeAndNil(ListFields);
    Exit;
   End;
  bJsonValue := udwjson.TJsonObject.Create(JSONValue);
  If bJsonValue.names.Length > 0 Then
   Begin
    vTypeObject      := GetObjectName       (bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
    vObjectDirection := GetDirectionName    (bJsonValue.opt(bJsonValue.names.get(1).ToString).ToString);
    vEncoded         := GetBooleanFromString(bJsonValue.opt(bJsonValue.names.get(2).ToString).ToString);
    vObjectValue     := GetValueType        (bJsonValue.opt(bJsonValue.names.get(3).ToString).ToString);
    vtagName         := Lowercase           (bJsonValue.names.get(4).ToString);
    // Add Field Defs
    If Not(DestDS is TRESTDWClientSQL) Then
     TRESTDWClientSQL(DestDS).SetInDesignEvents(False);
    TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
    DestDS.DisableControls;
    If DestDS.Active Then
     DestDS.Close;
    bJsonArray    := bJsonValue.optJSONArray   (bJsonValue.names.get(4).ToString);
    bJsonArraySub := bJsonArray.optJSONObject  (0);
    bJsonArray    := bJsonArraySub.optJSONArray(bJsonArraySub.names.get(0).ToString);
    TRESTDWClientSQL(DestDS).NewFieldList;
    vFieldDefinition := TFieldDefinition.Create;
    {$IFDEF FPC}
     If (DestDS.Fields.Count > 0) Then
      TRESTDWClientSQL(DestDS).Fields.Clear;
    {$ELSE}
     If (TRESTDWClientSQL(DestDS).Fields.Count = 0) Then
      DestDS.FieldDefs.Clear
     Else
      Begin
       If (DestDS is TRESTDWClientSQL) Then
       For J := 0 To TRESTDWClientSQL(DestDS).Fields.Count - 1 Do
        Begin
         vFieldDefinition.FieldName := TRESTDWClientSQL(DestDS).Fields[J].FieldName;
         vFieldDefinition.DataType  := TRESTDWClientSQL(DestDS).Fields[J].DataType;
         vFieldDefinition.Size      := TRESTDWClientSQL(DestDS).Fields[J].Size;
         If vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                                      {$IFEND}{$ENDIF}ftFMTBcd] Then
          vFieldDefinition.Precision := TFloatField(TRESTDWClientSQL(DestDS).Fields[J]).Precision;
         vFieldDefinition.Required   := TRESTDWClientSQL(DestDS).Fields[J].Required;
         TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
        End;
      End;
     For J := 0 To TRESTDWClientSQL(DestDS).Fields.Count - 1 Do
      TRESTDWClientSQL(DestDS).Fields[J].Required := False;
    {$ENDIF}
    DestDS.FieldDefs.BeginUpdate;
    For J := 0 To bJsonArray.Length - 1 Do
     Begin
      bJsonOBJ := bJsonArray.optJSONObject(J);
      Try
       If Trim(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) <> '' Then
        Begin
         vTempValue          := bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString;
         FieldDef            := TRESTDWClientSQL(DestDS).FieldDefExist(vTempValue);
         If (FieldDef = Nil) Then
          Begin
           If (TRESTDWClientSQL(DestDS).FieldExist(vTempValue) = Nil) And
              (DestDS is TRESTDWClientSQL)  Then
            Begin
             vFieldDefinition.FieldName := vTempValue;
             vFieldDefinition.DataType  := GetFieldType(bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
             vFieldDefinition.Size      := StrToInt(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString);
             If vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                                          {$IFEND}{$ENDIF}ftFMTBcd] Then
              vFieldDefinition.Precision := StrToInt(bJsonOBJ.opt(bJsonOBJ.names.get(5).ToString).ToString);
             vFieldDefinition.Required   := Uppercase(bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString) = 'S';
             TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
            End;
           FieldDef          := DestDS.FieldDefs.AddFieldDef;
           FieldDef.Name     := vTempValue;
           FieldDef.DataType := GetFieldType(bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
           FieldDef.Size     := StrToInt(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString);
           If FieldDef.DataType In [ftFloat, ftCurrency, ftBCD, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                                {$IFEND}{$ENDIF}ftFMTBcd] Then
            Begin
             FieldDef.Size      := StrToInt(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString);
             FieldDef.Precision := StrToInt(bJsonOBJ.opt(bJsonOBJ.names.get(5).ToString).ToString);
            End;
          End;
        End;
      Finally
      End;
     End;
    FreeAndNil(vFieldDefinition);
    DestDS.FieldDefs.EndUpdate;
    Try
     TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
     TRESTDWClientSQL(DestDS).Inactive := True;
     TRESTDWClientSQL(DestDS).CreateDataSet;
      //DestDS.Open;
     If Not DestDS.Active Then
      Begin
       bJsonValue.Free;
       ListFields.Free;
       Raise Exception.Create('Error on Parse JSON Data...');
       Exit;
      End;
     TRESTDWClientSQL(DestDS).Active   := True;
     TRESTDWClientSQL(DestDS).Inactive := False;
    Except
    End;
    //Clean Invalid Fields
    bJsonArray    := bJsonArraySub.optJSONArray(bJsonArraySub.names.get(0).ToString);
    For A := TRESTDWClientSQL(DestDS).Fields.Count -1 DownTo 0 Do
     Begin
      If TRESTDWClientSQL(DestDS).Fields[A].FieldKind = fkData Then
       Begin
        vFindFlag := False;
        For J := 0 To bJsonArray.Length - 1 Do
         Begin
          bJsonOBJ := bJsonArray.getJSONObject(J);
          Try
           If Trim(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) <> '' Then
            Begin
             vFindFlag := Lowercase(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) =
                          Lowercase(TRESTDWClientSQL(DestDS).Fields[A].FieldName);
             If vFindFlag Then
              Break;
            End;
          Finally
          End;
         End;
        If Not vFindFlag Then
         TRESTDWClientSQL(DestDS).Fields.Remove(TRESTDWClientSQL(DestDS).Fields[A]);
       End;
     End;
    //Add Set PK Fields
    bJsonArray    := bJsonValue.optJSONArray   (bJsonValue.names.get(4).ToString);
    bJsonArraySub := bJsonArray.optJSONObject  (0);
    bJsonArray    := bJsonArraySub.optJSONArray(bJsonArraySub.names.get(0).ToString);
    For J := 0 To bJsonArray.Length - 1 Do
     Begin
      bJsonOBJ    := bJsonArray.getJSONObject(J);
      Try
       If Uppercase(Trim(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString)) = 'S' Then
        Begin
         Field := TRESTDWClientSQL(DestDS).FindField(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString);
         If Field <> Nil Then
          Begin
           If Field.FieldKind = fkData Then
            Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
           Else
            Field.ProviderFlags := [];
           {$IFNDEF FPC}{$IF CompilerVersion > 21}
           If bJsonOBJ.names.Length > 6 Then
            Begin
             //Set ReadOnlyProp
             If (Uppercase(Trim(bJsonOBJ.opt(bJsonOBJ.names.get(7).ToString).ToString)) = 'S') Then
              Field.AutoGenerateValue := arAutoInc;
            End;
           {$IFEND}
           {$ENDIF}
          End;
        End;
      Finally
      End;
     End;
    For A := 0 To DestDS.Fields.Count - 1 Do     //ADICIONA REGISTRO
     Begin
      vFindFlag := False;
      If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
      If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
       Begin
        For J := 0 To bJsonArray.Length - 1 Do
         Begin
          bJsonOBJ := bJsonArray.getJSONObject(J);
          If Trim(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) <> '' Then
           Begin
            vFindFlag := Uppercase(Trim(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString)) =
                         Uppercase(DestDS.Fields[A].FieldName);
            If vFindFlag Then
             Begin
              ListFields.Add(IntToStr(J));
              Break;
             End;
           End;
         End;
       End;
      If Not vFindFlag Then
       ListFields.Add('-1');
     End;
    If TRESTDWClientSQL(DestDS).GetInDesignEvents Then
     Begin
      bJsonValue.Clean;
      FreeAndNil(bJsonValue);
      ListFields.Free;
      TRESTDWClientSQL(DestDS).SetInDesignEvents(False);
      Exit;
     End;
    bJsonArray    := bJsonValue.optJSONArray(bJsonValue.names.get(4).ToString);
    bJsonArraySub := bJsonArray.optJSONObject(1);
    bJsonArray    := bJsonArraySub.optJSONArray(bJsonArraySub.names.get(0).ToString);
    If DestDS Is TRESTDWClientSQL Then
     TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
    For J := 0 To bJsonArray.Length - 1 Do
     Begin
      bJsonOBJ     := bJsonArray.getJSONObject(J);
      bJsonOBJTemp := bJsonOBJ.optJSONArray(bJsonOBJ.names.get(0).ToString);
      TRESTDWClientSQL(DestDS).Append;
      Try
       For I := 0 To DestDS.Fields.Count - 1 Do
        Begin
         vOldReadOnly  := TRESTDWClientSQL(DestDS).Fields[I].ReadOnly;
         FieldValidate := TRESTDWClientSQL(DestDS).Fields[I].OnValidate;
         TRESTDWClientSQL(DestDS).Fields[I].OnValidate := Nil;
         TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := False;
         If (TRESTDWClientSQL(DestDS).Fields[I].FieldKind = fkLookup) Then
          Begin
           TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
           TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
           Continue;
          End;
         If (I >= ListFields.Count) then
          Begin
           TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
           TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
           Continue;
          End;
         If (StrToInt(ListFields[I]) = -1) Or
            Not(TRESTDWClientSQL(DestDS).Fields[I].FieldKind = fkData) Or
            (StrToInt(ListFields[I]) = -1) Then
          Begin
           TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
           TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
           Continue;
          End;
         vTempValue := bJsonOBJTemp.get(StrToInt(ListFields[I])).ToString;
         If TRESTDWClientSQL(DestDS).Fields[I].DataType In [ftGraphic,     ftParadoxOle, ftDBaseOle,
                                                            ftTypedBinary, ftCursor,     ftDataSet,
                                                            ftBlob,        ftOraBlob,    ftOraClob
                                                            {$IFNDEF FPC}{$IF CompilerVersion > 21},
                                                            ftParams, ftStream{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> 'null') And
              (vTempValue <> '')     Then
            Begin
             HexStringToStream(vTempValue, vBlobStream);
             Try
              vBlobStream.Position := 0;
              TBlobField(TRESTDWClientSQL(DestDS).Fields[I]).LoadFromStream(vBlobStream);
             Finally
              {$IFNDEF FPC}
              {$IF CompilerVersion > 21}
               vBlobStream.Clear;
              {$IFEND}
              {$ENDIF}
              FreeAndNil(vBlobStream);
             End;
            End;
          End
         Else
          Begin
           If (Lowercase(vTempValue) <> 'null') Then
            Begin
             If TRESTDWClientSQL(DestDS).Fields[I].DataType in [ftString, ftWideString,
                                                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo, {$IFEND}{$ENDIF}
                                                               ftMemo, ftFmtMemo, ftFixedChar] Then
              Begin
               If vTempValue = '' Then
                TRESTDWClientSQL(DestDS).Fields[I].Value := ''
               Else
                Begin
                 If vEncoded Then
                  TRESTDWClientSQL(DestDS).Fields[I].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                 Else
                  TRESTDWClientSQL(DestDS).Fields[I].AsString := vTempValue;
                End;
              End
             Else if (vTempValue <> '') then
              SetValueA(TRESTDWClientSQL(DestDS).Fields[I], vTempValue);
            End;
          End;
         TRESTDWClientSQL(DestDS).Fields[I].ReadOnly := vOldReadOnly;
         TRESTDWClientSQL(DestDS).Fields[I].OnValidate := FieldValidate;
        End;
      Finally
       vTempValue := '';
      End;
      TRESTDWClientSQL(DestDS).Post;
     End;
    For J := 0 To TRESTDWClientSQL(DestDS).FieldListCount -1 Do
     Begin
      If Not(TRESTDWClientSQL(DestDS).FieldExist(TRESTDWClientSQL(DestDS).ServerFieldList[J].FieldName) = Nil) Then
       TRESTDWClientSQL(DestDS).FindField(TRESTDWClientSQL(DestDS).ServerFieldList[J].FieldName).Required := TRESTDWClientSQL(DestDS).ServerFieldList[J].Required;
     End;
   End
  Else
   Begin
    DestDS.Close;
    Raise Exception.Create('Invalid JSON Data...');
   End;
 Finally
  bJsonValue.Clean;
  FreeAndNil(bJsonValue);
  ListFields.Free;
  If DestDS.Active Then
   DestDS.First;
  If DestDS Is TRESTDWClientSQL Then
   TRESTDWClientSQL(DestDS).SetInBlockEvents(False);
  If DestDS is TRESTDWClientSQL Then
   Begin
    If TRESTDWClientSQL(DestDS).State = dsBrowse Then
     Begin
      If TRESTDWClientSQL(DestDS).RecordCount = 0 Then
       TRESTDWClientSQL(DestDS).PrepareDetailsNew
      Else
       TRESTDWClientSQL(DestDS).PrepareDetails(True);
     End;
   End;
  If DestDS Is TRESTDWClientSQL Then
   If TRESTDWClientSQL(DestDS).Active Then
    TRESTDWClientSQL(DestDS).ForceInternalCalc;
  DestDS.EnableControls;
 End;
End;
{$IFEND}

Procedure TJSONValue.SaveToStream(Stream: TMemoryStream; Binary : Boolean = False);
Begin
 Try
  If Not Binary Then
   Stream.Write(aValue[0], Length(aValue))
  Else
   HexToStream(Value, Stream);
 Finally
  Stream.Position := 0;
 End;
End;


{$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
Procedure TJSONValue.LoadFromJSON(bValue: String);
Var
 bJsonValue    : system.json.TJsonObject;
 vTempValue    : String;
 vStringStream : TMemoryStream;
Begin
 bJsonValue := TJsonObject.ParseJSONValue(bValue) as system.json.TJsonObject;
 Try
  If bJsonValue.count > 0 Then
   Begin
    vNullValue       := False;
    vTempValue       := CopyValue(bValue);
    vTypeObject      := GetObjectName(removestr(bJsonvalue.Pairs[0].Jsonvalue.tostring,'"') ); //bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
    vObjectDirection := GetDirectionName(removestr(bjsonvalue.Pairs[1].JsonValue.tostring,'"')); // bJsonValue.opt(bJsonValue.names.get(1).ToString).ToString);
    vObjectValue     := GetValueType( removestr(bJsonvalue.Pairs[3].JsonValue.tostring,'"')); //bJsonValue.opt(bJsonValue.names.get(3).ToString).ToString);
    vtagName         := Lowercase(removestr(bJsonvalue.Pairs[4].Jsonstring.tostring,'"')); // bJsonValue.names.get(4).ToString);
    If vTypeObject = toDataset Then
     Begin
      If vTempValue[InitStrPos] = '[' Then
       vTempValue:= vTempValue.Remove(Initstrpos,1); // Delete(vTempValue, InitStrPos, 1);
      If vTempValue[Length(vTempValue)-1] = ']' Then
       vTempValue:= vTempValue.Remove(Length(vTempValue)-1,1); //Delete(vTempValue, Length(vTempValue), 1);
     End;
    If vEncoded Then
     Begin
      If vObjectValue In [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         HexToStream(vTempValue, vStringStream);
         aValue := TIdBytes(StreamToBytes(vStringStream));
        Finally
         vStringStream.Free;
        End;
       End
      Else
       vTempValue := DecodeStrings(vTempValue);
     End;
    If Not(vObjectValue In [ovBytes,   ovVarBytes, ovBlob,
                            ovGraphic, ovOraBlob,  ovOraClob]) Then
     SetValue(vTempValue, vEncoded)
    Else
     Begin
      vStringStream := TMemoryStream.Create;
      Try
       HexToStream(vTempValue, vStringStream);
       aValue := TIdBytes(StreamToBytes(vStringStream));
      Finally
       FreeAndNil(vStringStream);
      End;
     End;
   End;
 Finally
  bJsonValue.Free;
 End;

End;

{$ELSE}
Procedure TJSONValue.LoadFromJSON(bValue: String);
Var
 bJsonValue    : udwjson.TJsonObject;
 vTempValue    : String;
 vStringStream : TMemoryStream;
Begin
 bJsonValue := udwjson.TJsonObject.Create(bValue);
 Try
  If bJsonValue.names.Length > 0 Then
   Begin
    vNullValue       := False;
    vTempValue       := CopyValue(bValue);
    vTypeObject      := GetObjectName(bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
    vObjectDirection := GetDirectionName(bJsonValue.opt(bJsonValue.names.get(1).ToString).ToString);
    vObjectValue     := GetValueType(bJsonValue.opt(bJsonValue.names.get(3).ToString).ToString);
    vtagName         := Lowercase(bJsonValue.names.get(4).ToString);
    If vTypeObject = toDataset Then
     Begin
      If vTempValue[InitStrPos] = '[' Then
       Delete(vTempValue, InitStrPos, 1);
      If vTempValue[Length(vTempValue)] = ']' Then
       Delete(vTempValue, Length(vTempValue), 1);
     End;
    If vEncoded Then
     Begin
      If vObjectValue In [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         HexToStream(vTempValue, vStringStream);
         aValue := TIdBytes(StreamToBytes(vStringStream));
        Finally
         vStringStream.Free;
        End;
       End
      Else
       vTempValue := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
     End;
    If Not(vObjectValue In [ovBytes,   ovVarBytes, ovBlob,
                            ovGraphic, ovOraBlob,  ovOraClob]) Then
     SetValue(vTempValue, vEncoded)
    Else
     Begin
      vStringStream := TMemoryStream.Create;
      Try
       HexToStream(vTempValue, vStringStream);
       aValue := TIdBytes(StreamToBytes(vStringStream));
      Finally
       FreeAndNil(vStringStream);
      End;
     End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
{$IFEND}

Procedure TJSONValue.LoadFromStream(Stream : TMemoryStream;
                                    Encode : Boolean = True);
Begin
 ObjectValue := ovBlob;
 vBinary     := True;
 SetValue(StreamToHex(Stream), Encode);
End;

Procedure TJSONValue.StringToBytes(Value : String;
                                   Encode : Boolean = False);
Var
 Stream : TStringStream;
Begin
 If Value <> '' Then
  Begin
   ObjectValue := ovBlob;
   vBinary     := True;
   vEncoded    := Encode;
   Stream      := TStringStream.Create(Value);
   Try
    Stream.Position := 0;
    SetValue(StreamToHex(Stream), Encode);
   Finally
    Stream.Free;
   End;
  End;
End;

procedure TJSONValue.SetEncoding(bValue: TEncodeSelect);
begin
 vEncoding := bValue;
 {$IFDEF FPC}
 Case vEncoding Of
  esASCII : vEncodingLazarus := TEncoding.ANSI;
  esUtf8  : vEncodingLazarus := TEncoding.Utf8;
 End;
 {$ENDIF}
end;

Procedure TJSONValue.SetValue      (Value  : String;
                                    Encode : Boolean);
Begin
 vEncoded := Encode;
 vNullValue := False;
 If Encode Then
  Begin
   If vObjectValue in [ovBytes,   ovVarBytes, ovBlob,
                       ovGraphic, ovOraBlob,  ovOraClob] Then
    Begin
     vBinary := True;
     WriteValue(Value);
    End
   Else
    Begin
     vBinary := False;
     WriteValue(EncodeStrings(Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}))
    End;
  End
 Else
  Begin
   If vObjectValue in [ovBytes,   ovVarBytes, ovBlob,
                       ovGraphic, ovOraBlob,  ovOraClob] Then
    Begin
     vBinary := True;
     WriteValue(Value);
    End
   Else
    Begin
     vBinary := False;
     WriteValue(Value);
    End;
  End;
End;

Procedure TJSONValue.WriteValue(bValue: String);
Begin
 SetLength(aValue, 0);
 If bValue = '' Then
  Exit;
 If vObjectValue in [ovString, ovMemo, ovWideMemo, ovFmtMemo, ovObject] Then
  Begin
   {$IFDEF FPC}
   If vEncodingLazarus = Nil Then
    SetEncoding(vEncoding);
   If vEncoded Then
    aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
   Else
    Begin
     If ((jsonmode = jmDataware) And (vencoded)) Or Not(vObjectValue  = ovObject) Then
      aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
     Else
      aValue := TIdBytes(vEncodingLazarus.GetBytes(bValue));
    End;
   {$ELSE}
   If vEncoded Then
    aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding)) //TIdBytes(vEncoding.GetBytes(Format(TJsonStringValue, [bValue])));
   Else
    Begin
     If ((jsonmode = jmDataware) And (vencoded)) Or Not(vObjectValue  = ovObject) Then
      aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding))
     Else
      aValue := ToBytes(bValue, GetEncodingID(vEncoding));
    End;
   {$ENDIF}
  End
 Else If vObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp,
                          ovOraTimeStamp, ovTimeStampOffset] Then
  Begin
   {$IFDEF FPC}
   aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])));
   {$ELSE}
   aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
   {$ENDIF}
  End
 Else If vObjectValue in [ovFloat,  ovCurrency,  ovBCD,
                          ovFMTBcd, ovExtended]  Then
  Begin
   {$IFDEF FPC}
   aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])));
   {$ELSE}
   aValue := ToBytes(BuildFloatString(Format(TJsonStringValue, [bValue])), GetEncodingID(vEncoding));
   {$ENDIF}
  End
 Else
  Begin
   {$IFDEF FPC}
   aValue := TIdBytes(vEncodingLazarus.GetBytes(bValue));
   {$ELSE}
   aValue := ToBytes(bValue, GetEncodingID(vEncoding));
   {$ENDIF}
  End;
End;

Constructor TJSONParam.Create(Encoding: TEncodeSelect);
Begin
 vJSONValue  := TJSONValue.Create;
 vJsonMode   := jmDataware;
 vEncoding   := Encoding;
 vTypeObject := toParam;
 ObjectDirection := odINOUT;
 vObjectValue := ovString;
 vBinary := False;
 vJSONValue.vBinary := vBinary;
 vEncoded := True;
End;

Destructor TJSONParam.Destroy;
Begin
 FreeAndNil(vJSONValue);
 Inherited;
End;

Procedure TJSONParam.LoadFromParam(Param: TParam);
Var
 MemoryStream : TMemoryStream;
Begin
 If Param.DataType      in [ftString, ftWideString, ftMemo,
                            {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                            {$IFEND}{$ENDIF}
                            ftFmtMemo, ftFixedChar] Then
  Begin
   vEncoded := true;
   SetValue(Param.AsString, vEncoded);
  End
 Else If Param.DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                            {$IFEND}{$ENDIF}ftInteger, ftSmallint, ftLargeint, ftFloat,
                            ftCurrency, ftFMTBcd, ftBCD] Then
  SetValue(BuildStringFloat(Param.AsString), False)
 Else If Param.DataType In [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
  Begin
   MemoryStream := TMemoryStream.Create;
   Try
    {$IFDEF FPC}
    Param.SetData(MemoryStream);
    {$ELSE}
    {$IF CompilerVersion > 21}
    MemoryStream.CopyFrom(Param.AsStream, Param.AsStream.Size);
    {$ELSE}
    Param.SetData(MemoryStream);
    {$IFEND}
    {$ENDIF}
    LoadFromStream(MemoryStream);
    vEncoded := False;
   Finally
    MemoryStream.Free;
   End;
  End
 Else If Param.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
  SetValue(intToStr(DateTimeToUnix(Param.AsDateTime)), False);
 vObjectValue            := FieldTypeToObjectValue(Param.DataType);
 vJSONValue.vObjectValue := vObjectValue;
End;

Procedure TJSONParam.LoadFromStream(Stream: TMemoryStream; Encode: Boolean);
Begin
 ObjectValue       := ovBlob;
 vEncoded          := True;
 SetValue(StreamToHex(Stream), vEncoded);
 vBinary           := True;
 vJSONValue.Binary := vBinary;
End;

{$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
Procedure TJSONParam.FromJSON(JSON: String);
Var
 bJsonValue : system.json.TJsonObject;
 vValue     : String;
Begin
 bJsonValue := TJSONObject.ParseJSONValue(JSON) as TJSONObject;
 Try
  vValue := CopyValue(JSON);
  If bJsonValue.count > 0 Then
   Begin
    vTypeObject      := GetObjectName(removestr(bJsonValue.pairs[0].jsonvalue.tostring,'"'));        //  GetObjectName(bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
    vObjectDirection := GetDirectionName(removestr(bJsonValue.pairs[1].jsonvalue.tostring,'"'));     //bJsonValue.opt(bJsonValue.names.get(1).ToString).ToString);
    vEncoded         := GetBooleanFromString(removestr(bJsonValue.pairs[2].jsonvalue.tostring,'"')); //bJsonValue.opt(bJsonValue.names.get(2).ToString).ToString);
    vObjectValue     := GetValueType(removestr(bJsonValue.pairs[3].jsonvalue.tostring,'"')); //bJsonValue.opt(bJsonValue.names.get(3).ToString).ToString);
    vParamName       := Lowercase(removestr(bJsonValue.pairs[4].jsonstring.tostring,'"')); //bJsonValue.names.get(4).ToString);
    WriteValue(vValue);
    vBinary            := vObjectValue in [ovBytes, ovVarBytes, ovBlob,
                                           ovGraphic, ovOraBlob, ovOraClob];
    vJSONValue.vBinary := vBinary;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
{$ELSE}
Procedure TJSONParam.FromJSON(JSON: String);
Var
 bJsonValue : udwjson.TJsonObject;
 vValue     : String;
Begin
 bJsonValue := uDWJSON.TJsonObject.Create(JSON);
 Try
  vValue := CopyValue(JSON);
  If bJsonValue.names.Length > 0 Then
   Begin
    vTypeObject        := GetObjectName(bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
    vObjectDirection   := GetDirectionName(bJsonValue.opt(bJsonValue.names.get(1).ToString).ToString);
    vEncoded           := GetBooleanFromString(bJsonValue.opt(bJsonValue.names.get(2).ToString).ToString);
    vObjectValue       := GetValueType(bJsonValue.opt(bJsonValue.names.get(3).ToString).ToString);
    vParamName         := Lowercase(bJsonValue.names.get(4).ToString);
    WriteValue(vValue);
    vBinary            := vObjectValue in [ovBytes, ovVarBytes, ovBlob,
                                           ovGraphic, ovOraBlob, ovOraClob];
    vJSONValue.vBinary := vBinary;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
{$IFEND}

Procedure TJSONParam.CopyFrom(JSONParam: TJSONParam);
Var
 vValue : String;
Begin
 Try
  vValue                := JSONParam.Value;
  Self.vTypeObject      := JSONParam.vTypeObject;
  Self.vObjectDirection := JSONParam.vObjectDirection;
  Self.vEncoded         := JSONParam.vEncoded;
  Self.vObjectValue     := JSONParam.vObjectValue;
  Self.vParamName       := JSONParam.vParamName;
  Self.SetValue(vValue);
 Finally
 End;
End;

Procedure TJSONParam.SaveToStream(Stream: TMemoryStream);
Begin
 HexToStream(GetAsString, Stream);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Procedure TJSONParam.SetAsAnsiString(Value: AnsiString);
Begin
 {$IFDEF FPC}
 SetDataValue(Value, ovString);
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
  SetDataValue(Utf8ToAnsi(Value), ovString);
  {$ELSE}
  SetDataValue(Value, ovString);
  {$IFEND}
 {$ENDIF}
End;
{$ENDIF}

procedure TJSONParam.SetAsBCD(Value: Currency);
begin
 SetDataValue(Value, ovBcd);
end;

procedure TJSONParam.SetAsBoolean(Value: Boolean);
begin
 SetDataValue(Value, ovBoolean);
end;

procedure TJSONParam.SetAsCurrency(Value: Currency);
begin
 SetDataValue(Value, ovCurrency);
end;

procedure TJSONParam.SetAsDate(Value: TDateTime);
begin
 SetDataValue(Value, ovDate);
end;

procedure TJSONParam.SetAsDateTime(Value: TDateTime);
begin
 SetDataValue(Value, ovDateTime);
end;

procedure TJSONParam.SetAsFloat(Value: Double);
begin
 SetDataValue(Value, ovFloat);
end;

procedure TJSONParam.SetAsFMTBCD(Value: Currency);
begin
 SetDataValue(Value, ovFMTBcd);
end;

procedure TJSONParam.SetAsInteger(Value: Integer);
begin
 SetDataValue(Value, ovInteger);
end;

procedure TJSONParam.SetAsLargeInt(Value: LargeInt);
begin
 SetDataValue(Value, ovLargeInt);
end;

procedure TJSONParam.SetAsLongWord(Value: LongWord);
begin
 SetDataValue(Value, ovLongWord);
end;

procedure TJSONParam.SetAsObject(Value: String);
begin
 SetDataValue(Value, ovObject);
end;

procedure TJSONParam.SetAsShortInt(Value: Integer);
begin
 SetDataValue(Value, ovShortInt);
end;

procedure TJSONParam.SetAsSingle(Value: Single);
begin
 SetDataValue(Value, ovSmallInt);
end;

procedure TJSONParam.SetAsSmallInt(Value: Integer);
begin
 SetDataValue(Value, ovSmallInt);
end;

procedure TJSONParam.SetAsString(Value: String);
begin
 SetDataValue(Value, ovString);
end;

procedure TJSONParam.SetAsTime(Value: TDateTime);
begin
 SetDataValue(Value, ovTime);
end;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
procedure TJSONParam.SetAsWideString(Value: WideString);
begin
 SetDataValue(Value, ovWideString);
end;
{$ENDIF}

procedure TJSONParam.SetAsWord(Value: Word);
begin
 SetDataValue(Value, ovWord);
end;

Procedure TJSONParam.SetDataValue(Value: Variant; DataType : TObjectValue);
var
 ms : TMemoryStream;
 p  : Pointer;
begin
// vEncoded := False;
 If (VarIsNull(Value)) Or (VarIsEmpty(Value)) Or
    (DataType in [ovBytes,    ovVarBytes,    ovBlob,
                  ovByte,     ovGraphic,     ovParadoxOle,
                  ovDBaseOle, ovTypedBinary, ovOraBlob,
                  ovOraClob,  ovStream]) Then
  Exit;
 vObjectValue := DataType;
 Case vObjectValue Of
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream    : Begin
                 ms := TMemoryStream.Create;
                 Try
                  ms.Position := 0;
                  p := VarArrayLock(Value);
                  ms.Write(p ^, VarArrayHighBound(Value, 1));
                  VarArrayUnlock(Value);
                  ms.Position := 0;
                  If ms.Size > 0 Then
                   LoadFromStream(ms);
                 Finally
                  ms.Free;
                 End;
                End;
  ovVariant,
  ovUnknown   : Begin
                 vEncoded     := True;
                 vObjectValue := ovString;
                 SetValue(Value, vEncoded);
                End;
  ovLargeint,
  ovLongWord,
  ovShortint,
  ovSingle,
  ovSmallint,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval:Begin
                 vEncoded := False;
                 If vObjectValue = ovBoolean Then
                  Begin
                   If Boolean(Value) then
                    SetValue('1', vEncoded)
                   Else
                    SetValue('0', vEncoded);
                  End
                 Else
                  SetValue(IntToStr(Value), vEncoded);
                End;
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended  : Begin
                 vEncoded := False;
                 vObjectValue := ovFloat;
                 SetValue(BuildStringFloat(FloatToStr(Value)), vEncoded);
                End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       vEncoded     := False;
                       vObjectValue := ovDateTime;
                       SetValue(IntToStr(DateTimeToUnix(Value)), vEncoded);
                      End;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo,
  ovObject   : Begin
                 If vObjectValue <> ovObject then
                  vObjectValue := ovString
                 Else
                  vObjectValue := ovObject;
                 SetValue(Value, vEncoded);
                End;
 End;
end;

procedure TJSONParam.SetObjectValue(Value: TObjectValue);
begin
 vObjectValue := Value;
 vBinary      := vObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob];
end;

procedure TJSONParam.SetVariantValue(Value: Variant);
begin
 SetDataValue(Value, vObjectValue);
end;

Procedure TJSONParam.StringToBytes(Value: String; Encode: Boolean);
Begin
 vJSONValue.JsonMode := vJsonMode;
 vObjectValue        := ovBlob;
 vBinary := vObjectValue in [ovBlob, ovGraphic, ovOraBlob, ovOraClob];
 If vBinary Then
  vJSONValue.StringToBytes(Value);
 vEncoded := Encoded;
 vJSONValue.vEncoded := vEncoded;
End;

Procedure TJSONParam.SetParamName(bValue: String);
Begin
 vParamName := Uppercase(bValue);
End;

Procedure TJSONParam.SetValue(aValue: String; Encode: Boolean);
Begin
 vEncoded := Encode;
 vJSONValue.JsonMode := vJsonMode;
 vJSONValue.vEncoded := vEncoded;
 vBinary := vObjectValue in [ovBlob, ovGraphic, ovOraBlob, ovOraClob];
 If (Encode) And Not (vBinary) Then
  WriteValue(EncodeStrings(aValue{$IFDEF FPC}, csUndefined{$ENDIF}))
 Else
  WriteValue(aValue);
 vJSONValue.vBinary := vBinary;
End;

Function TJSONParam.ToJSON: String;
Begin
 vJSONValue.JsonMode := vJsonMode;
 Result := vJSONValue.ToJSON;
 If vJsonMode in [jmPureJSON, jmMongoDB] Then
  Begin
   If Not(((Pos('{', Result) > 0)  And
           (Pos('}', Result) > 0)) Or
          ((Pos('[', Result) > 0)  And
           (Pos(']', Result) > 0))) Then
    Result := Format('{"%s" : "%s"}', [vParamName, vJSONValue.ToJSON]);
  End;
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Function TJSONParam.GetAsAnsiString: AnsiString;
begin
 {$IFDEF FPC}
 Result := GetValue(ovString);
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
  Result := Utf8ToAnsi(GetValue(ovString));
  {$ELSE}
  Result := GetValue(ovString);
  {$IFEND}
 {$ENDIF}
end;
{$ENDIF}

Function TJSONParam.GetAsBCD: Currency;
begin
 Result := GetValue(ovBcd);
end;

function TJSONParam.GetAsBoolean: Boolean;
begin
 Result := GetValue(ovBoolean);
end;

function TJSONParam.GetAsCurrency: Currency;
begin
 Result := GetValue(ovCurrency);
end;

Function TJSONParam.GetAsDateTime: TDateTime;
Begin
 Result := GetValue(ovDateTime);
End;

function TJSONParam.GetAsFloat: Double;
begin
 Result := GetValue(ovFloat);
end;

function TJSONParam.GetAsFMTBCD: Currency;
begin
 Result := GetValue(ovFMTBcd);
end;

function TJSONParam.GetAsInteger: Integer;
begin
 Result := GetValue(ovInteger);
end;

function TJSONParam.GetAsLargeInt: LargeInt;
begin
 Result := GetValue(ovLargeInt);
end;

function TJSONParam.GetAsLongWord: LongWord;
begin
 Result := GetValue(ovLongWord);
end;

function TJSONParam.GetAsSingle: Single;
begin
 Result := GetValue(ovSmallInt);
end;

Function TJSONParam.GetAsString: String;
Begin
 Result := GetValue(ovString);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
function TJSONParam.GetAsWideString: WideString;
begin
 Result := GetValue(ovWideString);
end;
{$ENDIF}

function TJSONParam.GetAsWord: Word;
begin
 Result := GetValue(ovWord);
end;

function TJSONParam.GetByteString: String;
Var
 Stream : TStringStream;
begin
 Stream := TStringStream.Create('');
 Try
  HexToStream(GetValue(ovString), Stream);
  Stream.Position := 0;
  Result := Stream.DataString;
 Finally
  Stream.Free;
 End;
end;

Function TJSONParam.GetValue(Value: TObjectValue): Variant;
Var
 ms       : TMemoryStream;
 MyBuffer : Pointer;
Begin
 Case Value Of
  ovVariant,
  ovUnknown         : Result := vJSONValue.Value;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo         : Result := vJSONValue.Value;
  ovLargeint,
  ovLongWord,
  ovShortint,
  ovSingle,
  ovSmallint,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Begin
                       If (vJSONValue.Value <> '') And
                          (lowercase(vJSONValue.Value) <> 'null') Then
                        Begin
                         If Value = ovBoolean Then
                          Result := (vJSONValue.Value = '1') or
                                    (lowercase(vJSONValue.Value) = 'true')
                         Else If (Trim(vJSONValue.Value) <> '') And
                                 (Trim(vJSONValue.Value) <> 'null') Then
                          Begin
                           If Value in [ovLargeint, ovLongWord] Then
                            Result := StrToInt64(vJSONValue.Value)
                           Else
                            Result := StrToInt(vJSONValue.Value);
                          End;
                        End;
                      End;
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       If (vJSONValue.Value <> '') And
                          (lowercase(vJSONValue.Value) <> 'null') Then
                        Result := StrToFloat(BuildFloatString(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       If (vJSONValue.Value <> '') And
                          (lowercase(vJSONValue.Value) <> 'null') Then
                        Result := UnixToDateTime(StrToInt(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       ms := TMemoryStream.Create;
                       Try
                        vJSONValue.SaveToStream(ms, vJSONValue.vBinary);
                        If ms.Size > 0 Then
                         Begin
                          Result   := VarArrayCreate([0, ms.Size - 1], VarByte);
                          MyBuffer := VarArrayLock(Result);
                          ms.ReadBuffer(MyBuffer^, ms.Size);
                          VarArrayUnlock(Result);
                         End
                        Else
                         Result := Null;
                       Finally
                        ms.Free;
                       End
                      End;
 End;
End;

Function TJSONParam.GetVariantValue: Variant;
Var
 ms       : TMemoryStream;
 MyBuffer : Pointer;
Begin
 Case vObjectValue Of
  ovVariant,
  ovUnknown         : Result := vJSONValue.Value;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo         : Result := vJSONValue.Value;
  ovLargeint,
  ovLongWord,
  ovShortint,
  ovSingle,
  ovSmallint,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Begin
                       If (vJSONValue.Value <> '') And
                          (lowercase(vJSONValue.Value) <> 'null') Then
                        Begin
                         If vObjectValue = ovBoolean Then
                          Result := (vJSONValue.Value = '1') or
                                    (lowercase(vJSONValue.Value) = 'true')
                         Else
                          Result := StrToInt(vJSONValue.Value)
                        End
                       Else
                        Result := Null;
                      End;
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       If (vJSONValue.Value <> '') And
                          (lowercase(vJSONValue.Value) <> 'null') Then
                        Result := StrToFloat(BuildFloatString(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       If (vJSONValue.Value <> '') And
                          (lowercase(vJSONValue.Value) <> 'null') Then
                         Result := UnixToDateTime(StrToInt64(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       ms := TMemoryStream.Create;
                       Try
                        vJSONValue.SaveToStream(ms, vJSONValue.vBinary);
                        If ms.Size > 0 Then
                         Begin
                          ms.Position := 0;
                          Result   := VarArrayCreate([0, ms.Size - 1], VarByte);
                          MyBuffer := VarArrayLock(Result);
                          ms.ReadBuffer(MyBuffer^, ms.Size);
                          VarArrayUnlock(Result);
                         End
                        Else
                         Result := Null;
                       Finally
                        ms.Free;
                       End
                      End;
 End;
End;

Function TJSONParam.IsEmpty: Boolean;
Begin
 Result := GetValue(ovString) = '';
End;

Procedure TJSONParam.WriteValue(bValue: String);
Begin
 vJSONValue.Encoding        := vEncoding;
 vJSONValue.vtagName         := vParamName;
 vJSONValue.vTypeObject      := vTypeObject;
 vJSONValue.vObjectDirection := vObjectDirection;
 vJSONValue.vObjectValue     := vObjectValue;
 vJSONValue.vEncoded         := vEncoded;
 vJSONValue.WriteValue(bValue);
End;

{ TStringStreamList }

Function TStringStreamList.Add(Item : TStringStream): Integer;
Var
 vItem : ^TStringStream;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TStringStreamList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TStringStreamList.Create;
Begin
 Inherited;
End;

Procedure TStringStreamList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
     Dispose(PStringStream(TList(Self).Items[Index]));
     {$ELSE}
     Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TStringStreamList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TStringStreamList.GetRec(Index : Integer): TStringStream;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TStringStream(TList(Self).Items[Index]^);
End;

Procedure TStringStreamList.PutRec(Index: Integer; Item: TStringStream);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TStringStream(TList(Self).Items[Index]^) := Item;
End;

End.
