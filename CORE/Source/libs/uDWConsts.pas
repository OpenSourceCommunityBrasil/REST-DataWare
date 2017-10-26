unit uDWConsts;

Interface

Uses
    {$IFDEF FPC}
     SysUtils, DB, Classes, IdGlobal, IdCoderMIME, uZlibLaz, base64, uDWConstsData;
    {$ELSE}
     {$if CompilerVersion > 21} // Delphi 2010 pra cima
      System.SysUtils, IdGlobal, uZlibLaz, EncdDecd,
      Data.DB, System.Classes, IdCoderMIME, uDWConstsData;
     {$ELSE}
      SysUtils, IdGlobal, uZlibLaz, EncdDecd,
      DB, Classes, IdCoderMIME, uDWConstsData;
     {$IFEND}
    {$ENDIF}

Const
{$IFDEF POSIX} 
  {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
   InitStrPos            = 0;
   {$ELSE}
   InitStrPos            = 1;
   {$IFEND}
 {$ELSE}
 InitStrPos            = 1;
 {$ENDIF}
 TSepParams            = '|xxx|xxx|%';
 TValueFormatJSON      = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":[%s]}';
 TMassiveFormatJSON    = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":[%s]}';
 TValueDisp            = '{"PARAMS":[%s], "RESULT":[%s]}';
 TValueArrayJSON       = '[%s]';
 TValueFormatJSONValue = '{"%s":"%s", "%s":"%s", "%s":"%s", "%s":"%s", "%s":%s}';
 TJsonDatasetHeader    = '{"Field":"%s", "Type":"%s", "Primary":"%s", "Required":"%s", "Size":%d, "Precision":%d, "ReadOnly":"%s", "Autogeneration":"%s"}';
 TJsonValueFormat      = '%s';
 TJsonStringValue      = '"%s"';
 TSepValueMemString    = '\\';
 TQuotedValueMemString = '\"';
 TReplyOK              = '{"MESSAGE":"OK",  "RESULT":"OK"}';
 TReplyNOK             = '{"MESSAGE":"NOK", "RESULT":"NOK"}';
 AuthRealm             = 'Provide Authentication';
 UrlBase               = '%s://%s:%d/%s';
 ByteBuffer            = 1024 * 8; //8kb
 CompressBuffer        = 1024 * 2;

Type
 TMassiveMode     = (mmInactive, mmBrowse, mmInsert, mmUpdate, mmDelete);
 TTypeObject      = (toDataset,   toParam, toMassive,
                     toVariable,  toObject);
 TObjectValue     = (ovUnknown,         ovString,       ovSmallint,         ovInteger,    ovWord,                            // 0..4
                     ovBoolean,         ovFloat,        ovCurrency,         ovBCD,        ovDate,      ovTime,    ovDateTime,// 5..11
                     ovBytes,           ovVarBytes,     ovAutoInc,          ovBlob,       ovMemo,      ovGraphic, ovFmtMemo, //12..18
                     ovParadoxOle,      ovDBaseOle,     ovTypedBinary,      ovCursor,     ovFixedChar, ovWideString,         //19..24
                     ovLargeint,        ovADT, ovArray, ovReference,        ovDataSet,    ovOraBlob,   ovOraClob,            //25..31
                     ovVariant,         ovInterface,    ovIDispatch,        ovGuid,       ovTimeStamp, ovFMTBcd,             //32..37
                     ovFixedWideChar,   ovWideMemo,     ovOraTimeStamp,     ovOraInterval,                                   //38..41
                     ovLongWord,        ovShortint,     ovByte, ovExtended, ovConnection, ovParams,    ovStream,             //42..48
                     ovTimeStampOffset, ovObject,       ovSingle);                                                           //49..51
 TDatasetType     = (dtReflection,      dtFull,         dtDiff);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   Function GetEncoding(Avalue  : TEncodeSelect)    : TEncoding;
  {$IFEND}
  {$ELSE}
   Function GetEncoding(Avalue  : TEncodeSelect) : IIdTextEncoding;
 {$ENDIF}
 Function GetObjectName           (TypeObject      : TTypeObject)      : String;          Overload;
 Function GetObjectName           (TypeObject      : String)           : TTypeObject;     Overload;
 Function GetDirectionName        (ObjectDirection : TObjectDirection) : String;          Overload;
 Function GetDirectionName        (ObjectDirection : String)           : TObjectDirection;Overload;
 Function GetBooleanFromString    (Value           : String)           : Boolean;
 Function GetStringFromBoolean    (Value           : Boolean)          : String;
 Function GetValueType            (ObjectValue     : TObjectValue)     : String;          Overload;
 Function GetValueType            (ObjectValue     : String)           : TObjectValue;    Overload;
 Function GetFieldType            (FieldType       : TFieldType)       : String;          Overload;
 Function GetFieldType            (FieldType       : String)           : TFieldType;      Overload;
 Function StringToBoolean         (aValue          : String)           : Boolean;
 Function BooleanToString         (aValue          : Boolean)          : String;
 Function StringFloat             (aValue          : String)           : String;
 Function GenerateStringFromStream(Stream          : TStream{$IFNDEF FPC}{$if CompilerVersion > 21};AEncoding : TEncoding{$IFEND}{$ENDIF}) : String;Overload;
 //Function GenerateStringFromStream(Stream          : TStream)   : String;Overload;
 Function  FileToStr    (Const FileName     : String) : String;
 Procedure StrToFile    (Const FileName,
                               SourceString : String);
 Function  StreamToHex  (Stream : TStream; QQuoted : Boolean = True)  : String;
 Procedure HexToStream  (Str    : String;
                         Stream : TStream);
 Function  StreamToBytes(Stream       : TMemoryStream) : tidBytes;
 Procedure CopyStream   (Const Source : TStream;
                               Dest   : TStream);
 Function  ZDecompressStr(Const S     : String;
                          Var Value   : String) : Boolean;
 Function  ZDecompressStreamD(Const S   : TStringStream;
                              Var Value : TStringStream) : Boolean;
 Function  ZCompressStr  (Const s     : String;
                          Var Value   : String) : Boolean;
 Function  BytesArrToString(aValue : tIdBytes) : String;
 Function  ObjectValueToFieldType(TypeObject : TObjectValue) : TFieldType;
 Function  FieldTypeToObjectValue(FieldType  : TFieldType)   : TObjectValue;
 Function  DatasetStateToMassiveType(DatasetState : TDatasetState) : TMassiveMode;
 Function  MassiveModeToString(MassiveMode : TMassiveMode) : String;
 Function  StringToMassiveMode(Value       : String)       : TMassiveMode;


implementation

//Uses uDWJSONTools;

Function MassiveModeToString(MassiveMode : TMassiveMode) : String;
Begin
 Case MassiveMode Of
  mmInactive : Result := 'mmInactive';
  mmBrowse   : Result := 'mmBrowse';
  mmInsert   : Result := 'mmInsert';
  mmUpdate   : Result := 'mmUpdate';
  mmDelete   : Result := 'mmDelete';
 End;
End;

Function StringToMassiveMode(Value       : String)       : TMassiveMode;
Begin
 Result  := mmInactive;
 If LowerCase(Value)      = LowerCase('mmBrowse') Then
  Result := mmBrowse
 Else If LowerCase(Value) = LowerCase('mmInsert') Then
  Result := mmInsert
 Else If LowerCase(Value) = LowerCase('mmUpdate') Then
  Result := mmUpdate
 Else If LowerCase(Value) = LowerCase('mmDelete') Then
  Result := mmDelete;
End;

Function DatasetStateToMassiveType(DatasetState : TDatasetState) : TMassiveMode;
Begin
 Result := mmInactive;
 Case DatasetState Of
  dsInactive : Result := mmInactive;
  dsBrowse   : Result := mmBrowse;
  dsInsert   : Result := mmInsert;
  dsEdit     : Result := mmUpdate;
 End;
End;

Function BytesArrToString(aValue : tIdBytes) : String;
{$IFDEF FPC}
Var
 StringStream : TStringStream;
{$ENDIF}
Begin
 {$IFDEF FPC}
  StringStream := TStringStream.Create('');
  Try
   StringStream.Write(aValue[0], Length(aValue));
   StringStream.Position := 0;
   Result  := StringStream.DataString;
  Finally
   StringStream.Free;
  End;
 {$ELSE}
  Result   := BytesToString(aValue);
 {$ENDIF}
End;

Function ZCompressStr(Const s   : String;
                      Var Value : String) : Boolean;
Var
 Utf8Stream   : TStringStream;
 Compressed   : TMemoryStream;
 Base64Stream : TStringStream;
 {$IFDEF FPC}
  Encoder     : TBase64EncodingStream;
 {$ENDIF}

 ST:String;
Begin
 Result := False;
 {$IFDEF FPC}
  Utf8Stream := TStringStream.Create(S);
 {$ELSE}
  Utf8Stream := TStringStream.Create(S{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
 {$ENDIF}
 Try
  Compressed := TMemoryStream.Create;
  Try
    ZCompressStream(Utf8Stream, Compressed);
   // ZdeCompressStream( Compressed, Utf8Stream);      para teste
    Compressed.Position := 0;
   Try
    Value := StreamToHex(Compressed, False);
    Result := True;
   Finally
   End;
  Finally
   {$IFNDEF FPC}{$if CompilerVersion > 21}Compressed.Clear;{$IFEND}{$ENDIF}
   FreeAndNil(Compressed);
  End;
 Finally
  {$IFNDEF FPC}{$if CompilerVersion > 21}Utf8Stream.Clear;{$IFEND}{$ENDIF}
  FreeAndNil(Utf8Stream);
 End;
End;

Function ZDecompressStreamD(Const S   : TStringStream;
                            Var Value : TStringStream) : Boolean;
Var
 Utf8Stream,
 Base64Stream : TStringStream;
 {$IFDEF FPC}
  Encoder     : TBase64DecodingStream;
 {$ENDIF}
Begin
 {$IFDEF FPC}
  Base64Stream := TStringStream.Create('');
  S.Position   := 0;
  Base64Stream.CopyFrom(S, 0);
  Base64Stream.Position   := 0;
 {$ELSE}
  Base64Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.Utf8{$IFEND});
  S.Position   := 0;
  Base64Stream.CopyFrom(S, S.Size);
  Base64Stream.Position   := 0;
 {$ENDIF}
 Try
  {$IFDEF FPC}
  Value := TStringStream.Create('');
  {$ELSE}
  Value := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.Utf8{$IFEND});
  {$ENDIF}
  Try
   Try
    {$IFDEF FPC}
     Utf8Stream := TStringStream.Create('');
     HexToStream(Base64Stream.DataString, Utf8Stream);
     Utf8Stream.Position := 0;
     ZDecompressStream(Utf8Stream, Value);
     Value.position := 0;
    {$ELSE}
     Utf8Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.Utf8{$IFEND});
     HexToStream(Base64Stream.DataString, Utf8Stream);
     Utf8Stream.position := 0;
     ZDecompressStream(Utf8Stream, Value);
     Value.Position := 0;
    {$ENDIF}
    Result := True;
   Except
    Result := False;
   End;
  Finally
   {$IFNDEF FPC}Utf8Stream.Size := 0;{$ENDIF}
    FreeAndNil(Utf8Stream);
  End;
 Finally
  {$IFNDEF FPC}Base64Stream.Size := 0;{$ENDIF}
  FreeAndNil(Base64Stream);
 End;
End;

Function ZDecompressStr(Const S   : String;
                        Var Value : String) : Boolean;
Var
 Utf8Stream,
 Compressed,
 Base64Stream : TStringStream;
 {$IFDEF FPC}
  Encoder     : TBase64DecodingStream;
 {$ENDIF}
Begin
 Result := False;
 {$IFDEF FPC}
  Base64Stream := TStringStream.Create(S);
 {$ELSE}
  Base64Stream := TStringStream.Create(S{$if CompilerVersion > 21}, TEncoding.ASCII{$IFEND});
 {$ENDIF}
 Try
  Compressed := TStringStream.Create('');
  Try
   {$IFDEF FPC}
    Utf8Stream    := TStringStream.Create('');
    Encoder       := TBase64DecodingStream.Create(Base64Stream);
    Utf8Stream.CopyFrom(Encoder, Encoder.Size);
    Utf8Stream.Position := 0;
    FreeAndNil(Encoder);
    Compressed.position := 0;
    ZDecompressStream(Utf8Stream, Compressed);
   {$ELSE}
    Utf8Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
    DecodeStream(Base64Stream, Utf8Stream);
    Utf8Stream.position := 0;
    ZDecompressStream(Utf8Stream, Compressed);
    Compressed.Position := 0;
   {$ENDIF}
   Try
    Value := Compressed.DataString;
    Result := True;
   Finally
    {$IFNDEF FPC}Utf8Stream.Size := 0;{$ENDIF}
    FreeAndNil(Utf8Stream);
   End;
  Finally
   {$IFNDEF FPC}Compressed.Size := 0;{$ENDIF}
   FreeAndNil(Compressed);
  End;
 Finally
  {$IFNDEF FPC}Base64Stream.Size := 0;{$ENDIF}
  FreeAndNil(Base64Stream);
 End;
End;

Function StreamToBytes(Stream : TMemoryStream) : tidBytes;
Begin
 Try
  Stream.Position := 0;
  SetLength  (Result, Stream.Size);
  Stream.Read(Result[0], Stream.Size);
 Finally
 End;
end;

Procedure LimpaLixoHex(Var Value : String);
Begin
 If Length(Value) > 0 Then
  Begin
   If Value[1] = '{' Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[1] = #13 Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[1] = '"' Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[1] = 'L' Then
    Delete(Value, 1, 1);
  End;
 If Length(Value) > 0 Then
  Begin
   If Value[Length(Value)] = '"' Then
    Delete(Value, Length(Value), 1);
  End;
End;

Procedure HexToStream(Str    : String;
                      Stream : TStream);
{$IFDEF POSIX} //Android}
var bytes: TBytes;
{$ENDIF}
Begin
 LimpaLixoHex(Str);
 {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
  SetLength(bytes, Length(str) div 2);
  HexToBin(PChar(str), 0, bytes, 0, Length(bytes));
  stream.WriteBuffer(bytes[0], length(bytes));
 {$ELSE}
   TMemoryStream(Stream).Size := Length(Str) Div 2;
   {$IFDEF FPC}
   HexToBin(PChar (Str), TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
   {$ELSE}
    {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    {$IF (NOT Defined(FPC) AND Defined(LINUX))} //Alteardo para Lazarus LINUX Brito
     SetLength(bytes, Length(str) div 2);
     HexToBin(PChar(str), 0, bytes, 0, Length(bytes));
     stream.WriteBuffer(bytes[0], length(bytes));
    {$ELSE}
     HexToBin(PWideChar (Str),   TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
     {$ENDIF}
    {$ELSE}
     HexToBin(PChar (Str),   TMemoryStream(Stream).Memory, TMemoryStream(Stream).Size);
    {$IFEND}
   {$ENDIF}
 {$IFEND}
 Stream.Position := 0;
End;

{$IFDEF LINUX}
function abbintohexstring(stream: Tstream):string;
var
  s: TStream;
  i: Integer;
  b: Byte;
  hex: String;
begin
  s := stream;
  try
    s.Seek(int64(0), word(soFromBeginning));
    for i:=1 to s.Size do
    begin
      s.Read(b, 1);
      hex := IntToHex(b, 2);
      //.....
      result:=result+hex;
    end;
  finally
    s.Free;
  end;
end;
{$ENDIF}

Function StreamToHex(Stream  : TStream; QQuoted : Boolean = True) : String;
{$IFDEF POSIX} //Android}
var bytes, bytes2: TBytes;
{$ENDIF}
Begin
 Stream.Position := 0;
 {$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
  SetLength(bytes, Stream.Size);
  Stream.Read(bytes[0], Stream.Size);
  SetLength(bytes2, Length(bytes));
  BinToHex(bytes,0,bytes2,0, Length(bytes));
   result:= TEncoding.Unicode.GetString( bytes2 );
 {$ELSE}
 {$IFDEF LINUX} // Android}
  //SetLength(bytes, Stream.Size);
 // Stream.Read(bytes, Stream.Size);
  //SetLength(bytes2, Length(bytes));
  //BinToHex (bytes,0,bytes2,0, Length(bytes));
   result:=abbintohexstring(stream); // BytesToString(bytes2);  // TEncoding.UTF8.GetString(bytes2);
 {$ELSE}
   SetLength     (Result, Stream.Size * 2);
   BinToHex      (TMemoryStream(Stream).Memory, PChar(Result), Stream.Size);
   {$ENDIF}
 {$IFEND}
 If QQuoted Then
  Result := '"' + Result + '"';
End;

Function FileToStr(Const FileName : String):string;
Var
 Stream : TFileStream;
Begin
 Stream:= TFileStream.Create(FileName, fmOpenRead);
 Try
  SetLength(Result, Stream.Size);
  Stream.Position := 0;
  Stream.ReadBuffer(Pointer(Result)^, Stream.Size);
 Finally
  Stream.Free;
 End;
End;

Procedure StrToFile(Const FileName, SourceString : string);
Var
 Stream : TFileStream;
Begin
 If FileExists(FileName) Then
  DeleteFile(FileName);
 Stream:= TFileStream.Create(FileName, fmCreate);
 Try
  Stream.WriteBuffer(Pointer(SourceString)^, Length(SourceString));
 Finally
  Stream.Free;
 End;
End;

Procedure CopyStream(Const Source : TStream;
                           Dest   : TStream);
Var
 BytesRead : Integer;
 Buffer    : PByte;
 Const
  MaxBufSize = $F000;
Begin
 { ** Criando a instância do objeto TMemoryStream para retorno do método ** }
 Dest := TMemoryStream.Create;
 { ** Reposicionando o stream para o seu início ** }
 source.Seek(0, soBeginning);
 source.Position := 0;
 GetMem(Buffer, MaxBufSize);
 { ** Realizando a leitura do stream original, buffer a buffer ** }
 Repeat
  BytesRead := Source.Read(Buffer^, MaxBufSize);
  If BytesRead > 0 then
   Dest.WriteBuffer(Buffer^, BytesRead);
 Until MaxBufSize > BytesRead;
 { ** Reposicionando o stream de retorno para o seu início ** }
 Dest.Seek(0, soBeginning);
End;

Function GenerateStringFromStream(Stream : TStream{$IFNDEF FPC}{$if CompilerVersion > 21}; AEncoding: TEncoding{$IFEND}{$ENDIF}) : String;
Var
 StringStream : TStringStream;
Begin
 StringStream := TStringStream.Create(''{$IFNDEF FPC}{$if CompilerVersion > 21}, AEncoding{$IFEND}{$ENDIF});
 Try
  Stream.Position := 0;
  StringStream.CopyFrom(Stream, Stream.Size);
  Result                := StringStream.DataString;
 Finally
  {$IFNDEF FPC}{$if CompilerVersion > 21}StringStream.Clear;{$IFEND}{$ENDIF}
  StringStream.Free;
 End;
End;
{
Function GenerateStringFromStream(Stream : TStream) : String;
Var
 idBytes : TIdBytes;
Begin
 Try
  SetLength(idBytes, Stream.Size);
  Stream.ReadBuffer(idBytes[0], Stream.Size);
 Finally
 End;
// vResult := PChar(AllocMem((Length(idBytes) * 2) + 1));
 SetLength(Result, Stream.Size * 2);
 BinToHex(@idBytes, PChar(Result), Length(idBytes));
End;
}

Function StringToBoolean(aValue : String) : Boolean;
Begin
 Result := lowercase(trim(aValue)) = 'true';
End;

Function BooleanToString(aValue : Boolean) : String;
Begin
 If aValue Then
  Result := 'true'
 Else
  Result := 'false';
End;

Function StringFloat     (aValue          : String)           : String;
Begin
 Result := StringReplace(aValue, '.', '', [rfReplaceall]);
End;

Function GetStringFromBoolean(Value       : Boolean)          : String;
Begin
 Result := 'false';
 If Value Then
  Result := 'true';
End;

Function GetObjectName   (TypeObject      : TTypeObject)       : String;
Begin
 Result := 'toObject';
 Case TypeObject Of
  toDataset  : Result := 'toDataset';
  toParam    : Result := 'toParam';
  toVariable : Result := 'toVariable';
  toObject   : Result := 'toObject';
  toMassive  : Result := 'toMassive';
 End;
End;

Function FieldTypeToObjectValue(FieldType  : TFieldType)   : TObjectValue;
Begin
 Result := ovUnknown;
 Case FieldType Of
  ftString          : Result := ovString;
  ftSmallint        : Result := ovSmallint;
  ftInteger         : Result := ovInteger;
  ftWord            : Result := ovWord;
  ftBoolean         : Result := ovBoolean;
  ftFloat           : Result := ovFloat;
  ftCurrency        : Result := ovCurrency;
  ftBCD             : Result := ovBCD;
  ftDate            : Result := ovDate;
  ftTime            : Result := ovTime;
  ftDateTime        : Result := ovDateTime;
  ftBytes           : Result := ovBytes;
  ftVarBytes        : Result := ovVarBytes;
  ftAutoInc         : Result := ovAutoInc;
  ftBlob            : Result := ovBlob;
  ftMemo            : Result := ovMemo;
  ftGraphic         : Result := ovGraphic;
  ftFmtMemo         : Result := ovFmtMemo;
  ftParadoxOle      : Result := ovParadoxOle;
  ftDBaseOle        : Result := ovDBaseOle;
  ftTypedBinary     : Result := ovTypedBinary;
  ftCursor          : Result := ovCursor;
  ftFixedChar       : Result := ovFixedChar;
  ftWideString      : Result := ovWideString;
  ftLargeint        : Result := ovLargeint;
  ftADT             : Result := ovADT;
  ftArray           : Result := ovArray;
  ftReference       : Result := ovReference;
  ftDataSet         : Result := ovDataSet;
  ftOraBlob         : Result := ovOraBlob;
  ftOraClob         : Result := ovOraClob;
  ftVariant         : Result := ovVariant;
  ftInterface       : Result := ovInterface;
  ftIDispatch       : Result := ovIDispatch;
  ftGuid            : Result := ovGuid;
  ftTimeStamp       : Result := ovTimeStamp;
  ftFMTBcd          : Result := ovFMTBcd;
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 acima
    ftFixedWideChar   : Result := ovFixedWideChar;
    ftWideMemo        : Result := ovWideMemo;
    ftOraTimeStamp    : Result := ovOraTimeStamp;
    ftOraInterval     : Result := ovOraInterval;
    ftLongWord        : Result := ovLongWord;
    ftShortint        : Result := ovShortint;
    ftByte            : Result := ovByte;
    ftExtended        : Result := ovExtended;
    ftConnection      : Result := ovConnection;
    ftParams          : Result := ovParams;
    ftStream          : Result := ovStream;
    ftTimeStampOffset : Result := ovTimeStampOffset;
    ftObject          : Result := ovObject;
    ftSingle          : Result := ovSingle;
   {$IFEND}
  {$ENDIF}
 End;
End;

Function ObjectValueToFieldType(TypeObject : TObjectValue) : TFieldType;
Begin
 Result := ftUnknown;
 Case TypeObject Of
  ovString          : Result := ftString;
  ovSmallint        : Result := ftSmallint;
  ovInteger         : Result := ftInteger;
  ovWord            : Result := ftWord;
  ovBoolean         : Result := ftBoolean;
  ovFloat           : Result := ftFloat;
  ovCurrency        : Result := ftCurrency;
  ovBCD             : Result := ftBCD;
  ovDate            : Result := ftDate;
  ovTime            : Result := ftTime;
  ovDateTime        : Result := ftDateTime;
  ovBytes           : Result := ftBytes;
  ovVarBytes        : Result := ftVarBytes;
  ovAutoInc         : Result := ftAutoInc;
  ovBlob            : Result := ftBlob;
  ovMemo            : Result := ftMemo;
  ovGraphic         : Result := ftGraphic;
  ovFmtMemo         : Result := ftFmtMemo;
  ovParadoxOle      : Result := ftParadoxOle;
  ovDBaseOle        : Result := ftDBaseOle;
  ovTypedBinary     : Result := ftTypedBinary;
  ovCursor          : Result := ftCursor;
  ovFixedChar       : Result := ftFixedChar;
  ovWideString      : Result := ftWideString;
  ovLargeint        : Result := ftLargeint;
  ovADT             : Result := ftADT;
  ovArray           : Result := ftArray;
  ovReference       : Result := ftReference;
  ovDataSet         : Result := ftDataSet;
  ovOraBlob         : Result := ftOraBlob;
  ovOraClob         : Result := ftOraClob;
  ovVariant         : Result := ftVariant;
  ovInterface       : Result := ftInterface;
  ovIDispatch       : Result := ftIDispatch;
  ovGuid            : Result := ftGuid;
  ovTimeStamp       : Result := ftTimeStamp;
  ovFMTBcd          : Result := ftFMTBcd;
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 acima
    ovFixedWideChar   : Result := ftFixedWideChar;
    ovWideMemo        : Result := ftWideMemo;
    ovOraTimeStamp    : Result := ftOraTimeStamp;
    ovOraInterval     : Result := ftOraInterval;
    ovLongWord        : Result := ftLongWord;
    ovShortint        : Result := ftShortint;
    ovByte            : Result := ftByte;
    ovExtended        : Result := ftExtended;
    ovConnection      : Result := ftConnection;
    ovParams          : Result := ftParams;
    ovStream          : Result := ftStream;
    ovTimeStampOffset : Result := ftTimeStampOffset;
    ovObject          : Result := ftObject;
    ovSingle          : Result := ftSingle;
   {$IFEND}
  {$ENDIF}
 End;
End;

Function GetObjectName   (TypeObject      : String) : TTypeObject;
Var
 vTypeObject : String;
Begin
 Result := toObject;
 vTypeObject := Uppercase(TypeObject);
 If vTypeObject = Uppercase('toObject') Then
  Result := toObject
 Else If vTypeObject = Uppercase('toDataset') Then
  Result := toDataset
 Else If vTypeObject = Uppercase('toParam') Then
  Result := toParam
 Else If vTypeObject = Uppercase('toVariable') Then
  Result := toVariable
 Else If vTypeObject = Uppercase('toMassive') Then
  Result := toMassive;
End;

Function GetDirectionName(ObjectDirection : TObjectDirection) : String;
Begin
 Result := 'odINOUT';
 Case ObjectDirection Of
  odINOUT : Result := 'odINOUT';
  odIN    : Result := 'odIN';
  odOUT   : Result := 'odOUT';
 End;
End;

Function GetBooleanFromString(Value : String) : Boolean;
Begin
 Result := Uppercase(Value) = 'TRUE';
End;

Function GetDirectionName(ObjectDirection : String) : TObjectDirection;
Var
 vObjectDirection : String;
Begin
 Result := odOUT;
 vObjectDirection := Uppercase(ObjectDirection);
 If vObjectDirection = Uppercase('odINOUT') Then
  Result := odINOUT
 Else If vObjectDirection = Uppercase('odIN') Then
  Result := odIN;
{
 Else If vObjectDirection = Uppercase('odOUT') Then
  Result := odOUT;
}  
End;

Function GetValueType    (ObjectValue     : TObjectValue)     : String;
Begin
 Result := 'ovUnknown';
 Case ObjectValue Of
  ovUnknown         : Result := 'ovUnknown';
  ovString          : Result := 'ovString';
  ovSmallint        : Result := 'ovSmallint';
  ovInteger         : Result := 'ovInteger';
  ovWord            : Result := 'ovWord';
  ovBoolean         : Result := 'ovBoolean';
  ovFloat           : Result := 'ovFloat';
  ovCurrency        : Result := 'ovCurrency';
  ovBCD             : Result := 'ovBCD';
  ovDate            : Result := 'ovDate';
  ovTime            : Result := 'ovTime';
  ovDateTime        : Result := 'ovDateTime';
  ovBytes           : Result := 'ovBytes';
  ovVarBytes        : Result := 'ovVarBytes';
  ovAutoInc         : Result := 'ovAutoInc';
  ovBlob            : Result := 'ovBlob';
  ovMemo            : Result := 'ovMemo';
  ovGraphic         : Result := 'ovGraphic';
  ovFmtMemo         : Result := 'ovFmtMemo';
  ovParadoxOle      : Result := 'ovParadoxOle';
  ovDBaseOle        : Result := 'ovDBaseOle';
  ovTypedBinary     : Result := 'ovTypedBinary';
  ovCursor          : Result := 'ovCursor';
  ovFixedChar       : Result := 'ovFixedChar';
  ovWideString      : Result := 'ovWideString';
  ovLargeint        : Result := 'ovLargeint';
  ovADT             : Result := 'ovADT';
  ovArray           : Result := 'ovArray';
  ovReference       : Result := 'ovReference';
  ovDataSet         : Result := 'ovDataSet';
  ovOraBlob         : Result := 'ovOraBlob';
  ovOraClob         : Result := 'ovOraClob';
  ovVariant         : Result := 'ovVariant';
  ovInterface       : Result := 'ovInterface';
  ovIDispatch       : Result := 'ovIDispatch';
  ovGuid            : Result := 'ovGuid';
  ovTimeStamp       : Result := 'ovTimeStamp';
  ovFMTBcd          : Result := 'ovFMTBcd';
  ovFixedWideChar   : Result := 'ovFixedWideChar';
  ovWideMemo        : Result := 'ovWideMemo';
  ovOraTimeStamp    : Result := 'ovOraTimeStamp';
  ovOraInterval     : Result := 'ovOraInterval';
  ovLongWord        : Result := 'ovLongWord';
  ovShortint        : Result := 'ovShortint';
  ovByte            : Result := 'ovByte';
  ovExtended        : Result := 'ovExtended';
  ovConnection      : Result := 'ovConnection';
  ovParams          : Result := 'ovParams';
  ovStream          : Result := 'ovStream';
  ovTimeStampOffset : Result := 'ovTimeStampOffset';
  ovObject          : Result := 'ovObject';
  ovSingle          : Result := 'ovSingle';
 End;
End;

Function GetValueType (ObjectValue : String) : TObjectValue;
Var
 vObjectValue : String;
Begin
 Result := ovSingle;
 vObjectValue := Uppercase(ObjectValue);
 If vObjectValue      = Uppercase('ovUnknown')         Then
  Result := ovUnknown
 Else If vObjectValue = Uppercase('ovString')          Then
  Result := ovString
 Else If vObjectValue = Uppercase('ovSmallint')        Then
  Result := ovSmallint
 Else If vObjectValue = Uppercase('ovInteger')         Then
  Result := ovInteger
 Else If vObjectValue = Uppercase('ovWord')            Then
  Result := ovWord
 Else If vObjectValue = Uppercase('ovBoolean')         Then
  Result := ovBoolean
 Else If vObjectValue = Uppercase('ovFloat')           Then
  Result := ovFloat
 Else If vObjectValue = Uppercase('ovCurrency')        Then
  Result := ovCurrency
 Else If vObjectValue = Uppercase('ovBCD')             Then
  Result := ovBCD
 Else If vObjectValue = Uppercase('ovDate')            Then
  Result := ovDate
 Else If vObjectValue = Uppercase('ovTime')            Then
  Result := ovTime
 Else If vObjectValue = Uppercase('ovDateTime')        Then
  Result := ovDateTime
 Else If vObjectValue = Uppercase('ovBytes')           Then
  Result := ovBytes
 Else If vObjectValue = Uppercase('ovVarBytes')        Then
  Result := ovVarBytes
 Else If vObjectValue = Uppercase('ovAutoInc')         Then
  Result := ovAutoInc
 Else If vObjectValue = Uppercase('ovBlob')            Then
  Result := ovBlob
 Else If vObjectValue = Uppercase('ovMemo')            Then
  Result := ovMemo
 Else If vObjectValue = Uppercase('ovGraphic')         Then
  Result := ovGraphic
 Else If vObjectValue = Uppercase('ovFmtMemo')         Then
  Result := ovFmtMemo
 Else If vObjectValue = Uppercase('ovParadoxOle')      Then
  Result := ovParadoxOle
 Else If vObjectValue = Uppercase('ovDBaseOle')        Then
  Result := ovDBaseOle
 Else If vObjectValue = Uppercase('ovTypedBinary')     Then
  Result := ovTypedBinary
 Else If vObjectValue = Uppercase('ovCursor')          Then
  Result := ovCursor
 Else If vObjectValue = Uppercase('ovFixedChar')       Then
  Result := ovFixedChar
 Else If vObjectValue = Uppercase('ovWideString')      Then
  Result := ovWideString
 Else If vObjectValue = Uppercase('ovLargeint')        Then
  Result := ovLargeint
 Else If vObjectValue = Uppercase('ovADT')             Then
  Result := ovADT
 Else If vObjectValue = Uppercase('ovArray')           Then
  Result := ovArray
 Else If vObjectValue = Uppercase('ovReference')       Then
  Result := ovReference
 Else If vObjectValue = Uppercase('ovDataSet')         Then
  Result := ovDataSet
 Else If vObjectValue = Uppercase('ovOraBlob')         Then
  Result := ovOraBlob
 Else If vObjectValue = Uppercase('ovOraClob')         Then
  Result := ovOraClob
 Else If vObjectValue = Uppercase('ovVariant')         Then
  Result := ovVariant
 Else If vObjectValue = Uppercase('ovInterface')       Then
  Result := ovInterface
 Else If vObjectValue = Uppercase('ovIDispatch')       Then
  Result := ovIDispatch
 Else If vObjectValue = Uppercase('ovGuid')            Then
  Result := ovGuid
 Else If vObjectValue = Uppercase('ovTimeStamp')       Then
  Result := ovTimeStamp
 Else If vObjectValue = Uppercase('ovFMTBcd')          Then
  Result := ovFMTBcd
 Else If vObjectValue = Uppercase('ovFixedWideChar')   Then
  Result := ovFixedWideChar
 Else If vObjectValue = Uppercase('ovWideMemo')        Then
  Result := ovWideMemo
 Else If vObjectValue = Uppercase('ovOraTimeStamp')    Then
  Result := ovOraTimeStamp
 Else If vObjectValue = Uppercase('ovOraInterval')     Then
  Result := ovOraInterval
 Else If vObjectValue = Uppercase('ovLongWord')        Then
  Result := ovLongWord
 Else If vObjectValue = Uppercase('ovShortint')        Then
  Result := ovShortint
 Else If vObjectValue = Uppercase('ovByte')            Then
  Result := ovByte
 Else If vObjectValue = Uppercase('ovExtended')        Then
  Result := ovExtended
 Else If vObjectValue = Uppercase('ovConnection')      Then
  Result := ovConnection
 Else If vObjectValue = Uppercase('ovParams')          Then
  Result := ovParams
 Else If vObjectValue = Uppercase('ovStream')          Then
  Result := ovStream
 Else If vObjectValue = Uppercase('ovTimeStampOffset') Then
  Result := ovTimeStampOffset
 Else If vObjectValue = Uppercase('ovObject')          Then
  Result := ovObject
 Else If vObjectValue = Uppercase('ovSingle')          Then
  Result := ovSingle;
End;

Function GetFieldType (FieldType     : TFieldType)     : String;
Begin
 Result := 'ftUnknown';
 Case FieldType Of
  ftUnknown         : Result := 'ftUnknown';
  ftString          : Result := 'ftString';
  ftSmallint        : Result := 'ftSmallint';
  ftInteger         : Result := 'ftInteger';
  ftWord            : Result := 'ftWord';
  ftBoolean         : Result := 'ftBoolean';
  ftFloat           : Result := 'ftFloat';
  ftCurrency        : Result := 'ftCurrency';
  ftBCD             : Result := 'ftBCD';
  ftDate            : Result := 'ftDate';
  ftTime            : Result := 'ftTime';
  ftDateTime        : Result := 'ftDateTime';
  ftBytes           : Result := 'ftBytes';
  ftVarBytes        : Result := 'ftVarBytes';
  ftAutoInc         : Result := 'ftAutoInc';
  ftBlob            : Result := 'ftBlob';
  ftMemo            : Result := 'ftMemo';
  ftGraphic         : Result := 'ftGraphic';
  ftFmtMemo         : Result := 'ftFmtMemo';
  ftParadoxOle      : Result := 'ftParadoxOle';
  ftDBaseOle        : Result := 'ftDBaseOle';
  ftTypedBinary     : Result := 'ftTypedBinary';
  ftCursor          : Result := 'ftCursor';
  ftFixedChar       : Result := 'ftFixedChar';
  ftWideString      : Result := 'ftWideString';
  ftLargeint        : Result := 'ftLargeint';
  ftADT             : Result := 'ftADT';
  ftArray           : Result := 'ftArray';
  ftReference       : Result := 'ftReference';
  ftDataSet         : Result := 'ftDataSet';
  ftOraBlob         : Result := 'ftOraBlob';
  ftOraClob         : Result := 'ftOraClob';
  ftVariant         : Result := 'ftVariant';
  ftInterface       : Result := 'ftInterface';
  ftIDispatch       : Result := 'ftIDispatch';
  ftGuid            : Result := 'ftGuid';
  ftTimeStamp       : Result := 'ftTimeStamp';
  ftFMTBcd          : Result := 'ftFMTBcd';
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
    ftFixedWideChar   : Result := 'ftFixedWideChar';
    ftWideMemo        : Result := 'ftWideMemo';
    ftOraTimeStamp    : Result := 'ftOraTimeStamp';
    ftOraInterval     : Result := 'ftOraInterval';
    ftLongWord        : Result := 'ftLongWord';
    ftShortint        : Result := 'ftShortint';
    ftByte            : Result := 'ftByte';
    ftExtended        : Result := 'ftExtended';
    ftConnection      : Result := 'ftConnection';
    ftParams          : Result := 'ftParams';
    ftStream          : Result := 'ftStream';
    ftTimeStampOffset : Result := 'ftTimeStampOffset';
    ftObject          : Result := 'ftObject';
    ftSingle          : Result := 'ftSingle';
   {$IFEND}
  {$ENDIF}
 End;
End;

Function GetFieldType(FieldType : String) : TFieldType;
Var
 vFieldType : String;
Begin
 Result     := ftString;
 vFieldType := Uppercase(FieldType);
 If vFieldType      = Uppercase('ftUnknown')         Then
  Result := ftUnknown
 Else If vFieldType = Uppercase('ftString')          Then
  Result := ftString
 Else If vFieldType = Uppercase('ftSmallint')        Then
  Result := ftSmallint
 Else If vFieldType = Uppercase('ftInteger')         Then
  Result := ftInteger
 Else If vFieldType = Uppercase('ftWord')            Then
  Result := ftWord
 Else If vFieldType = Uppercase('ftBoolean')         Then
  Result := ftBoolean
 Else If vFieldType = Uppercase('ftFloat')           Then
  Result := ftFloat
 Else If vFieldType = Uppercase('ftCurrency')        Then
  Result := ftCurrency
 Else If vFieldType = Uppercase('ftBCD')             Then
  Result := ftBCD
 Else If vFieldType = Uppercase('ftDate')            Then
  Result := ftDate
 Else If vFieldType = Uppercase('ftTime')            Then
  Result := ftTime
 Else If vFieldType = Uppercase('ftDateTime')        Then
  Result := ftDateTime
 Else If vFieldType = Uppercase('ftBytes')           Then
  Result := ftBytes
 Else If vFieldType = Uppercase('ftVarBytes')        Then
  Result := ftVarBytes
 Else If vFieldType = Uppercase('ftAutoInc')         Then
  Result := ftAutoInc
 Else If vFieldType = Uppercase('ftBlob')            Then
  Result := ftBlob
 Else If vFieldType = Uppercase('ftMemo')            Then
  Result := ftMemo
 Else If vFieldType = Uppercase('ftGraphic')         Then
  Result := ftGraphic
 Else If vFieldType = Uppercase('ftFmtMemo')         Then
  Result := ftFmtMemo
 Else If vFieldType = Uppercase('ftParadoxOle')      Then
  Result := ftParadoxOle
 Else If vFieldType = Uppercase('ftDBaseOle')        Then
  Result := ftDBaseOle
 Else If vFieldType = Uppercase('ftTypedBinary')     Then
  Result := ftTypedBinary
 Else If vFieldType = Uppercase('ftCursor')          Then
  Result := ftCursor
 Else If vFieldType = Uppercase('ftFixedChar')       Then
  Result := ftFixedChar
 Else If vFieldType = Uppercase('ftWideString')      Then
  Result := ftWideString
 Else If vFieldType = Uppercase('ftLargeint')        Then
  Result := ftLargeint
 Else If vFieldType = Uppercase('ftADT')             Then
  Result := ftADT
 Else If vFieldType = Uppercase('ftArray')           Then
  Result := ftArray
 Else If vFieldType = Uppercase('ftReference')       Then
  Result := ftReference
 Else If vFieldType = Uppercase('ftDataSet')         Then
  Result := ftDataSet
 Else If vFieldType = Uppercase('ftOraBlob')         Then
  Result := ftOraBlob
 Else If vFieldType = Uppercase('ftOraClob')         Then
  Result := ftOraClob
 Else If vFieldType = Uppercase('ftVariant')         Then
  Result := ftVariant
 Else If vFieldType = Uppercase('ftInterface')       Then
  Result := ftInterface
 Else If vFieldType = Uppercase('ftIDispatch')       Then
  Result := ftIDispatch
 Else If vFieldType = Uppercase('ftGuid')            Then
  Result := ftGuid
 Else If vFieldType = Uppercase('ftTimeStamp')       Then
  {$IFNDEF FPC}
  Result := ftTimeStamp
  {$ELSE}
  Result := ftDateTime
  {$ENDIF}
 Else If vFieldType = Uppercase('ftFMTBcd')          Then
  Result := ftFMTBcd
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
    Else If vFieldType = Uppercase('ftFixedWideChar')   Then
     Result := ftFixedWideChar
    Else If vFieldType = Uppercase('ftWideMemo')        Then
     Result := ftWideMemo
    Else If vFieldType = Uppercase('ftOraTimeStamp')    Then
     Result := ftOraTimeStamp
    Else If vFieldType = Uppercase('ftOraInterval')     Then
     Result := ftOraInterval
    Else If vFieldType = Uppercase('ftLongWord')        Then
     Result := ftLongWord
    Else If vFieldType = Uppercase('ftShortint')        Then
     Result := ftShortint
    Else If vFieldType = Uppercase('ftByte')            Then
     Result := ftByte
    Else If vFieldType = Uppercase('ftExtended')        Then
     Result := ftExtended
    Else If vFieldType = Uppercase('ftConnection')      Then
     Result := ftConnection
    Else If vFieldType = Uppercase('ftParams')          Then
     Result := ftParams
    Else If vFieldType = Uppercase('ftStream')          Then
     Result := ftStream
    Else If vFieldType = Uppercase('ftTimeStampOffset') Then
     Result := ftTimeStampOffset
    Else If vFieldType = Uppercase('ftObject')          Then
     Result := ftObject
    Else If vFieldType = Uppercase('ftSingle')          Then
     Result := ftSingle
   {$IFEND}{$ENDIF};
End;

{$IFNDEF FPC}
{$if CompilerVersion > 21}
Function GetEncoding(Avalue  : TEncodeSelect) : TEncoding;
Begin
 Result := TEncoding.utf8;
 Case Avalue of
  esUtf8  : Result := TEncoding.Unicode;
  esASCII : Result := TEncoding.ASCII;
 End;
End;
{$IFEND}
{$ELSE}
Function GetEncoding(Avalue  : TEncodeSelect) : IIdTextEncoding;
Begin
 Result := IndyTextEncoding(encIndyDefault);
 Case Avalue of
  esUtf8  : Result := IndyTextEncoding(encUTF8);
  esASCII : Result := IndyTextEncoding(encASCII);
 End;
End;
{$ENDIF}

end.
