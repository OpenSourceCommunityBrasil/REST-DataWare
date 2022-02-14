unit SysTypes;

{$I uRESTDW.inc}

Interface

Uses
  IdURI, IdGlobal, IdHeaderList, SysUtils, Classes, ServerUtils, uDWConsts,
  uDWJSONObject,   uDWConstsCharset;

Type
  TServerUtils = Class
    Class Procedure ParseRESTURL        (Const Cmd          : String;
                                         vEncoding          : TEncodeSelect;
                                         Var UriOptions     : TRESTDWUriOptions;
                                         Var mark           : String
                                         {$IFDEF FPC};
                                          DatabaseCharSet   : TDatabaseCharSet
                                         {$ENDIF};
                                         Var Result         : TDWParams;
                                         ParamsCount        : Integer);Overload;
    Class Procedure ParseRESTURL        (UriParams          : String;
                                         vEncoding          : TEncodeSelect;
                                         {$IFDEF FPC}
                                         DatabaseCharSet    : TDatabaseCharSet;
                                         {$ENDIF}
                                         Var Result         : TDWParams);Overload;
    Class Function  Result2JSON          (wsResult          : TResultErro)     : String;
    Class Procedure ParseWebFormsParams (Params             : TStrings;
                                         Const URL,
                                         Query              : String;
                                         Var UriOptions     : TRESTDWUriOptions;
                                         Var mark           : String;
                                         vEncoding          : TEncodeSelect;
                                         {$IFDEF FPC}
                                          DatabaseCharSet   : TDatabaseCharSet;
                                         {$ENDIF}
                                         Var Result         : TDWParams;
                                         ParamsCount        : Integer;
                                         MethodType         : TRequestType = rtPost;
                                         ContentType        : String = 'application/json'); Overload;
    Class Procedure ParseWebFormsParams (Var DWParams       : TDWParams;
                                         Params             : TStrings;
                                         Const URL,
                                         Query              : String;
                                         Var UriOptions     : TRESTDWUriOptions;
                                         Var mark           : String;
                                         vEncoding          : TEncodeSelect;
                                         {$IFDEF FPC}
                                          DatabaseCharSet   : TDatabaseCharSet;
                                         {$ENDIF}
                                         ParamsCount        : Integer;
                                         MethodType         : TRequestType = rtPost);Overload;
    Class Procedure ParseWebFormsParams (Var DWParams       : TDWParams;
                                         WebParams          : TStrings;
                                         vEncoding          : TEncodeSelect
                                         {$IFDEF FPC}
                                         ;DatabaseCharSet   : TDatabaseCharSet
                                         {$ENDIF};
                                         MethodType         : TRequestType = rtPost);Overload;
    Class Function ParseDWParamsURL     (Const Cmd          : String;
                                         vEncoding          : TEncodeSelect;
                                         Var ResultPR       : TDWParams{$IFDEF FPC}
                                         ;DatabaseCharSet   : TDatabaseCharSet
                                         {$ENDIF})          : Boolean;
    {Tiago IStuque - 28/12/2018}
    Class Function ParseBodyRawToDWParam(Const BodyRaw      : String;
                                         vEncoding          : TEncodeSelect;
                                         Var ResultPR       : TDWParams{$IFDEF FPC}
                                         ;DatabaseCharSet   : TDatabaseCharSet
                                         {$ENDIF})          : Boolean;
    Class Function ParseBodyBinToDWParam(Const BodyBin      : String;
                                         vEncoding          : TEncodeSelect;
                                         Var ResultPR       : TDWParams{$IFDEF FPC}
                                         ;DatabaseCharSet   : TDatabaseCharSet
                                         {$ENDIF})          : Boolean;
    Class Function ParseFormParamsToDWParam(Const FormParams : String;
                                            vEncoding        : TEncodeSelect;
                                            var ResultPR     : TDWParams{$IFDEF FPC}
                                            ;DatabaseCharSet : TDatabaseCharSet
                                            {$ENDIF})        : Boolean;

    {Tiago IStuque - 28/12/2018}
  End;

implementation

uses uDWJSONTools;

Function CountExpression(Value      : String;
                         Expression : Char): Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For I := InitStrPos To Length(Value) - FinalStrPos Do
  Begin
   If Value[I] = Expression Then
    Inc(Result);
  End;
End;

{$IFDEF FPC}
Function URLDecode(const s: String): String;
var
   sAnsi,
   sUtf8    : String;
   sWide    : WideString;
   i, len   : Cardinal;
   ESC      : String[2];
   CharCode : integer;
   c        : char;
begin
   sAnsi := PChar(s);
   SetLength(sUtf8, Length(sAnsi));
   i := 1;
   len := 1;
   while (i <= Cardinal(Length(sAnsi))) do begin
      if (sAnsi[i] <> '%') then begin
         if (sAnsi[i] = '+') then begin
            c := ' ';
         end else begin
            c := sAnsi[i];
         end;
         sUtf8[len] := c;
         Inc(len);
      end else begin
         Inc(i);
         ESC := Copy(sAnsi, i, 2);
         Inc(i, 1);
         try
            CharCode := StrToInt('$' + ESC);
            c := Char(CharCode);
            sUtf8[len] := c;
            Inc(len);
         except end;
      end;
      Inc(i);
   end;
   Dec(len);
   SetLength(sUtf8, len);
   sWide := UTF8Decode(sUtf8);
   len := Length(sWide);
   Result := sWide;
end;
{$ENDIF}


Class Procedure TServerUtils.ParseRESTURL(UriParams          : String;
                                          vEncoding          : TEncodeSelect;
                                          {$IFDEF FPC}
                                          DatabaseCharSet    : TDatabaseCharSet;
                                          {$ENDIF}
                                          Var Result         : TDWParams);
Var
 vValue,
 vTempdata : String;
 A, I, 
 IndexS,
 Count     : Integer;
 JSONParam : TJSONParam;
Begin
 JSONParam    := Nil;
 A            := 0;
 If Not Assigned(Result) Then
  Begin
   Result := TDWParams.Create;
   Result.Encoding := vEncoding;
   {$IFDEF FPC}
   Result.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
 vTempdata := UriParams;
 IndexS    := InitStrPos;                                 
 Count     := Length(vTempdata);
 vValue    := '';
 For I := IndexS To Count - FinalStrPos Do
  Begin
   If (Trim(vValue) <> '')        And
      ((vTempData[I] = '/')       Or
       (vTempData[I] = '?')       Or
       (vTempData[I] = '&')       Or
       (I = Count - FinalStrPos)) Then
    Begin
     If (I = Count - FinalStrPos) Then
      vValue := vValue + vTempData[I];
     If Pos('=', vValue) > 0 Then
      Begin
       JSONParam := TJSONParam.Create(Result.Encoding);
       JSONParam.ObjectDirection := odIN;
       JSONParam.ParamName := Copy(vValue, InitStrPos, Pos('=', vValue) - 1);
       Delete(vValue, 1, Pos('=', vValue));
       {$IFDEF FPC}
        vValue            := URLDecode(vValue);
       {$ELSE}
        {$IFNDEF FPC}
         {$IF (DEFINED(OLDINDY))}
          vValue          := TIdURI.URLDecode(vValue);
         {$ELSE}
          vValue          := TIdURI.URLDecode(vValue, GetEncodingID(vEncoding));
         {$IFEND}
        {$ELSE}
         vValue           := TIdURI.URLDecode(vValue, GetEncodingID(vEncoding));
        {$ENDIF}
       {$ENDIF}
       JSONParam.SetValue(vValue);
      End
     Else
      Begin
       JSONParam := Result.ItemsString[IntToStr(A)];
       If JSONParam = Nil Then
        Begin
         JSONParam := TJSONParam.Create(Result.Encoding);
         JSONParam.ParamName := IntToStr(A);
         JSONParam.ObjectDirection := odIN;
         Result.Add(JSONParam);
        End;
       JSONParam.SetValue(vValue);
       Inc(A);
      End;
     vValue := '';
    End
   Else
    vValue := vValue + vTempData[I];
   // Adicionado para URIParams que vem com o tamanho da string 1 (Exemplo: http://localhost:9092/helloworld/1)
   If (Count = 1) then
    Begin
     JSONParam := Result.ItemsString[IntToStr(A)];
     If JSONParam = Nil Then
      Begin
       JSONParam := TJSONParam.Create(Result.Encoding);
       JSONParam.ParamName := IntToStr(A);
       JSONParam.ObjectDirection := odIN;
       Result.Add(JSONParam);
      End;
     JSONParam.SetValue(vValue);
     Inc(A);
     vValue := '';
    End;
  End;
End;

Class Procedure TServerUtils.ParseRESTURL(Const Cmd          : String;
                                          vEncoding          : TEncodeSelect;
                                          Var UriOptions     : TRESTDWUriOptions;
                                          Var mark           : String
                                          {$IFDEF FPC};
                                          DatabaseCharSet    : TDatabaseCharSet
                                          {$ENDIF};
                                          Var Result         : TDWParams;
                                          ParamsCount        : Integer);
Var
 vTempData,
 NewCmd,
 vArrayValues : String;
 ArraySize,
 aParamsCount,
 aParamsIndex,
 iBar1,
 IBar2, Count : Integer;
 aNewParam    : Boolean;
 JSONParam    : TJSONParam;
Begin
 JSONParam    := Nil;
 vArrayValues := '';
 UriOptions.BaseServer  := '';
 UriOptions.DataUrl     := '';
 UriOptions.ServerEvent := '';
 UriOptions.EventName   := '';
 aParamsCount           := ParamsCount;
 aParamsIndex           := 0;
 If Pos('?', Cmd) > 0 Then
  Begin
   vArrayValues := Copy(Cmd, Pos('?', Cmd) + 1, Length(Cmd));
   NewCmd       := Copy(Cmd, 1, Pos('?', Cmd) - 1);
  End
 Else
  NewCmd     := Cmd;
 If NewCmd <> '' Then
  Begin
   If NewCmd[Length(NewCmd) - FinalStrPos] <> '/' Then
    NewCmd := NewCmd + '/';
  End;
 If Not Assigned(Result) Then
  Begin
   Result := TDWParams.Create;
   Result.Encoding := vEncoding;
   {$IFDEF FPC}
   Result.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
 If (CountExpression(NewCmd, '/') > 1) Then
  Begin
   If NewCmd[InitStrPos] <> '/' then
    NewCmd := '/' + NewCmd
   Else
    NewCmd := Copy(NewCmd, 2, Length(NewCmd));
   If NewCmd[Length(NewCmd) - FinalStrPos] <> '/' Then
    NewCmd := NewCmd + '/';
   ArraySize := CountExpression(NewCmd, '/');
   For Count := 0 to ArraySize - 1 Do
    Begin
     IBar2     := Pos('/', NewCmd);
     {$IFNDEF FPC}
      {$IF (DEFINED(OLDINDY))}
       vTempData := TIdURI.URLDecode(Copy(NewCmd, 1, IBar2 - 1));
      {$ELSE}
       vTempData := TIdURI.URLDecode(Copy(NewCmd, 1, IBar2 - 1), GetEncodingID(vEncoding));
      {$IFEND}
     {$ELSE}
      vTempData := TIdURI.URLDecode(Copy(NewCmd, 1, IBar2 - 1), GetEncodingID(vEncoding));
     {$ENDIF}
     If Count <= aParamsCount Then
      Begin
       If (UriOptions.EventName = '') Or (aParamsCount = cParamsCount) Then
        Begin
         If (vTempData <> '') then
          Begin
           If (aParamsCount = cParamsCount) Then
            Begin
             If ArraySize <= cParamsCount Then
              Begin
               If ArraySize < cParamsCount Then
                Begin
                 If (UriOptions.EventName = '') Then
                  UriOptions.EventName    := vTempData
                 Else
                  UriOptions.ServerEvent  := vTempData;
                End
               Else
                Begin
                 If (UriOptions.ServerEvent <> '') Then
                  UriOptions.EventName    := vTempData
                 Else
                  UriOptions.ServerEvent  := vTempData;
                End;
              End
             Else
              Begin
               If (UriOptions.ServerEvent <> '') Then
                UriOptions.EventName    := vTempData
               Else
                UriOptions.ServerEvent  := vTempData;
              End;
            End
           Else
            Begin
             If (UriOptions.ServerEvent <> '') Then
              UriOptions.EventName    := vTempData
             Else
              UriOptions.ServerEvent  := vTempData;
            End;
          End;
        End
       Else If (UriOptions.EventName <> '') Then
        Begin
         If (vTempData <> '') then
          Begin
           If UriOptions.BaseServer <> '' Then
            Begin
             If (UriOptions.DataUrl     <> '') And
                (UriOptions.ServerEvent <> '') Then
              Begin
               If (UriOptions.DataUrl <> UriOptions.ServerEvent) then
                UriOptions.BaseServer := UriOptions.DataUrl
               Else
                UriOptions.ServerEvent := UriOptions.EventName;
              End
             Else
              Begin
  //             UriOptions.DataUrl     := UriOptions.ServerEvent;
               UriOptions.ServerEvent := UriOptions.EventName;
              End;
             UriOptions.EventName   := vTempData;
            End
           Else
            Begin
             UriOptions.BaseServer  := UriOptions.ServerEvent;
             UriOptions.DataUrl     := UriOptions.EventName;
             UriOptions.ServerEvent := UriOptions.DataUrl;
             UriOptions.EventName   := vTempData;
            End;
          End;
        End;
      End
     Else
      Begin
       aNewParam   := False;
       JSONParam                 := Result.ItemsString[IntToStr(aParamsIndex)];
       If JSONParam = Nil Then
        Begin
         aNewParam := True;
         JSONParam := TJSONParam.Create(Result.Encoding);
         JSONParam.ParamName     := IntToStr(aParamsIndex);
        End;
       JSONParam.ObjectDirection := odIN;
       JSONParam.AsString        := vTempData;
       If aNewParam Then
        Result.Add(JSONParam);
       Inc(aParamsIndex);
       aNewParam := False;
      End;
     NewCmd := Copy(NewCmd, IBar2 +1, Length(NewCmd));
    End;
   If (UriOptions.ServerEvent <> '') And (UriOptions.EventName = '') Then
    Begin
     UriOptions.EventName   := UriOptions.ServerEvent;
     UriOptions.ServerEvent := '';
    End;
   ArraySize := CountExpression(vArrayValues, '&');
   If ArraySize = 0 Then
    Begin
     If Length(vArrayValues) > 0 Then
      ArraySize := 1;
    End
   Else
    ArraySize := ArraySize + 1;
   For Count := 0 to ArraySize - 1 Do
    Begin
     IBar2     := Pos('&', vArrayValues);
     If IBar2 = 0 Then
      Begin
       IBar2    := Length(vArrayValues);
       vTempData := Copy(vArrayValues, 1, IBar2);
      End
     Else
      vTempData := Copy(vArrayValues, 1, IBar2 - 1);
      If Pos('dwmark:', vTempData) > 0 Then
       mark := Copy(vTempData, Pos('dwmark:', vTempData) + 7, Length(vTempData))
      Else
       Begin
        If Pos('=', vTempData) > 0 Then
         Begin
          aNewParam := False;
          If Copy(vTempData, 1, Pos('=', vTempData) - 1) <> '' Then
           JSONParam := Result.ItemsString[Copy(vTempData, 1, Pos('=', vTempData) - 1)]
          Else
           JSONParam := Result.ItemsString[cUndefined];
          If JSONParam = Nil Then
           Begin
            aNewParam := True;
            JSONParam := TJSONParam.Create(Result.Encoding);
            JSONParam.ObjectDirection := odIN;
            JSONParam.ParamName := Copy(vTempData, 1, Pos('=', vTempData) - 1);
            Delete(vTempData, 1, Pos('=', vTempData));
            {$IFDEF FPC}
             vTempData          := URLDecode(vTempData);
            {$ELSE}
             {$IFNDEF FPC}
              {$IF (DEFINED(OLDINDY))}
               vTempData          := TIdURI.URLDecode(vTempData);
              {$ELSE}
               vTempData          := TIdURI.URLDecode(vTempData, GetEncodingID(vEncoding));
              {$IFEND}
             {$ELSE}
              vTempData          := TIdURI.URLDecode(vTempData, GetEncodingID(vEncoding));
             {$ENDIF}
            {$ENDIF}
            JSONParam.SetValue(vTempData);
           End;
         End
        Else
         Begin
          aNewParam := False;
          JSONParam := Result.ItemsString[cUndefined];
          If JSONParam = Nil Then
           Begin
            aNewParam := True;
            JSONParam := TJSONParam.Create(Result.Encoding);
            JSONParam.ParamName := cUndefined;//Format('PARAM%d', [0]);
            JSONParam.ObjectDirection := odIN;
            Result.Add(JSONParam);
           End;
          JSONParam.SetValue(vTempData);
         End;
        If aNewParam Then
         Result.Add(JSONParam);
       End;
     Delete(vArrayValues, 1, IBar2);
    End;
  End;
End;

{Tiago IStuque - 28/12/2018}
class Function TServerUtils.ParseBodyBinToDWParam(const BodyBin    : String;
                                                  vEncoding        : TEncodeSelect;
                                                  var ResultPR     : TDWParams{$IFDEF FPC}
                                                  ;DatabaseCharSet : TDatabaseCharSet
                                                  {$ENDIF})        : Boolean;
var
  JSONParam: TJSONParam;
  vContentType: string;
begin
 if (BodyBin <> EmptyStr) then
 Begin
  If Not Assigned(ResultPR) Then
   Begin
    ResultPR := TDWParams.Create;
    ResultPR.Encoding := vEncoding;
    {$IFDEF FPC}
    ResultPR.DatabaseCharSet := DatabaseCharSet;
    {$ENDIF}
   End;
  JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
  JSONParam.ObjectDirection := odIN;
  If Assigned(ResultPR.ItemsString['dwParamNameBody']) And (ResultPR.ItemsString['dwParamNameBody'].AsString<>'') Then
   JSONParam.ParamName       := ResultPR.ItemsString['dwParamNameBody'].AsString
  Else
   JSONParam.ParamName       := 'UNDEFINED';
  JSONParam.SetValue(BodyBin, True);
  ResultPR.Add(JSONParam);
  If Assigned(ResultPR.ItemsString['dwFileNameBody']) And (ResultPR.ItemsString['dwFileNameBody'].AsString<>'') Then
   Begin
    JSONParam   := TJSONParam.Create(ResultPR.Encoding);
    JSONParam.ObjectDirection := odIN;
    JSONParam.ParamName := 'dwfilename';
    JSONParam.SetValue(ResultPR.ItemsString['dwFileNameBody'].AsString, JSONParam.Encoded);
    ResultPR.Add(JSONParam);
    If Not Assigned(ResultPR.ItemsString['Content-Type']) then
     Begin
       vContentType:= GetMIMEType(ResultPR.ItemsString['dwFileNameBody'].AsString);
       If vContentType <> '' then
        Begin
         JSONParam   := TJSONParam.Create(ResultPR.Encoding);
         JSONParam.ObjectDirection := odIN;
         JSONParam.ParamName := 'Content-Type';
         JSONParam.SetValue(vContentType, JSONParam.Encoded);
         ResultPR.Add(JSONParam);
        End;
     End;
   End;
 End;
end;

class Function TServerUtils.ParseFormParamsToDWParam(Const FormParams : String;
                                                     vEncoding        : TEncodeSelect;
                                                     var ResultPR     : TDWParams{$IFDEF FPC}
                                                     ;DatabaseCharSet : TDatabaseCharSet
                                                     {$ENDIF})        : Boolean;
Var
 JSONParam: TJSONParam;
 i            : Integer;
 vTempValue,
 vObjectName,
 vArrayValues : String;
 vParamList   : TStringList;
 Function FindValue(ParamList   : TStringList; Var IndexValue : Integer) : String;
 Var
  vFlagnew : Boolean;
 Begin
  vFlagnew := False;
  Result := '';
  While IndexValue <= ParamList.Count -1 Do
   Begin
    If vFlagnew Then
     Begin
      Result := ParamList[IndexValue];
      Break;
     End
    Else
     vFlagnew := ParamList[IndexValue] = '';
    Inc(IndexValue);
   End;
 End;
begin
 vArrayValues := StringReplace(FormParams, '=' + sLineBreak,   '', [rfReplaceAll]);
 vParamList      := TStringList.Create;
 Try
  If (vArrayValues <> EmptyStr) Then
   Begin
    vParamList.Text := vArrayValues;
    I := 0;
    While I <= vParamList.Count -1 Do
     Begin
      If Not Assigned(ResultPR) Then
       Begin
        ResultPR := TDWParams.Create;
        ResultPR.Encoding := vEncoding;
        {$IFDEF FPC}
        ResultPR.DatabaseCharSet := DatabaseCharSet;
        {$ENDIF}
       End;
      vObjectName := Copy(lowercase(vParamList[I]), Pos('; name="', lowercase(vParamList[I])) + length('; name="'),  length(lowercase(vParamList[I])));
      vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
      If vObjectName = '' Then
       Begin
        Inc(I);
        Continue;
       End;
      JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
      JSONParam.ObjectDirection := odIN;
      JSONParam.ParamName       := vObjectName;
      vTempValue := FindValue(vParamList, I);
      If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(vTempValue)) > 0) Or
         (Pos(Lowercase('{"ObjectType":"toObject", "Direction":"'), lowercase(vTempValue)) > 0) Then
       JSONParam.FromJSON(vTempValue)
      Else
       JSONParam.SetValue(vTempValue, True);
      ResultPR.Add(JSONParam);
      Inc(I);
     End;
   End;
 Finally
  FreeAndNil(vParamList);
 End;
end;

{Tiago IStuque - 28/12/2018}
class Function TServerUtils.ParseBodyRawToDWParam(const BodyRaw    : String;
                                                  vEncoding        : TEncodeSelect;
                                                  var ResultPR     : TDWParams{$IFDEF FPC}
                                                  ;DatabaseCharSet : TDatabaseCharSet
                                                  {$ENDIF})        : Boolean;
var
  JSONParam: TJSONParam;
begin
 If (BodyRaw <> EmptyStr) Then
 Begin
  If Not Assigned(ResultPR) Then
   Begin
    ResultPR := TDWParams.Create;
    ResultPR.Encoding := vEncoding;
    {$IFDEF FPC}
    ResultPR.DatabaseCharSet := DatabaseCharSet;
    {$ENDIF}
   End;
  JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
  JSONParam.ObjectDirection := odIN;
  If Assigned(ResultPR.ItemsString['dwNameParamBody']) And (ResultPR.ItemsString['dwNameParamBody'].AsString<>'') Then
   JSONParam.ParamName       := ResultPR.ItemsString['dwNameParamBody'].AsString
  Else
   JSONParam.ParamName       := 'UNDEFINED';
  JSONParam.SetValue(BodyRaw, True);
  ResultPR.Add(JSONParam);
 End;
end;

Class Function TServerUtils.ParseDWParamsURL(Const Cmd        : String;
                                             vEncoding        : TEncodeSelect;
                                             Var ResultPR     : TDWParams{$IFDEF FPC}
                                             ;DatabaseCharSet : TDatabaseCharSet
                                             {$ENDIF})        : Boolean;
Var
 vTempData,
 vArrayValues: String;
 ArraySize,
 IBar2, Cont : Integer;
 JSONParam   : TJSONParam;
 vParamList  : TStringList;
 Function CountExpression(Value: String; Expression: Char): Integer;
 Var
  I : Integer;
 Begin
  Result := 0;
  For I := 0 To Length(Value) - 1 Do
   Begin
    If Value[I] = Expression Then
     Inc(Result);
   End;
 End;
Begin
 vArrayValues         := Cmd;
 vParamList           := TStringList.Create;
 vParamList.Text      := StringReplace(vArrayValues, '&', #13, [rfReplaceAll]);
 If vParamList.Count < 1 Then
  Begin
   Result := Pos('=', vArrayValues) > 0;
   If Result Then
    Begin
     If Not Assigned(ResultPR) Then
      Begin
       ResultPR := TDWParams.Create;
       ResultPR.Encoding := vEncoding;
       {$IFDEF FPC}
       ResultPR.DatabaseCharSet := DatabaseCharSet;
       {$ENDIF}
      End;
     JSONParam  := Nil;
     ArraySize := CountExpression(vArrayValues, '&');
     If ArraySize = 0 Then
      Begin
       If Length(vArrayValues) > 0 Then
        ArraySize := 1;
      End
     Else
      ArraySize := ArraySize + 1;
     For Cont := 0 to ArraySize - 1 Do
      Begin
       IBar2     := Pos('&', vArrayValues);
       If IBar2 = 0 Then
        Begin
         IBar2    := Length(vArrayValues);
         vTempData := Copy(vArrayValues, 1, IBar2);
        End
       Else
        vTempData := Copy(vArrayValues, 1, IBar2 - 1);
       If Pos('=', vTempData) > 0 Then
        Begin
         JSONParam := TJSONParam.Create(ResultPR.Encoding);
         JSONParam.ObjectDirection := odIN;
         JSONParam.ParamName := Copy(vTempData, 1, Pos('=', vTempData) - 1);
         Delete(vTempData, 1, Pos('=', vTempData));
         {$IFNDEF FPC}
          {$IF (DEFINED(OLDINDY))}
           JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll])));
          {$ELSE}
           JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll]), GetEncodingID(ResultPR.Encoding)));
          {$IFEND}
         {$ELSE}
          JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll]), GetEncodingID(ResultPR.Encoding)));
         {$ENDIF}
        End
       Else
        Begin
         JSONParam := ResultPR.ItemsString[cUndefined];
         If JSONParam = Nil Then
          Begin
           JSONParam := TJSONParam.Create(ResultPR.Encoding);
           JSONParam.ObjectDirection := odIN;
           JSONParam.ParamName := cUndefined;//Format('PARAM%d', [0]);
          End;
         {$IFNDEF FPC}
          {$IF (DEFINED(OLDINDY))}
           JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll])));
          {$ELSE}
           JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll]), GetEncodingID(ResultPR.Encoding)));
          {$IFEND}
         {$ELSE}
          JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll]), GetEncodingID(ResultPR.Encoding)));
         {$ENDIF}
        End;
       ResultPR.Add(JSONParam);
       Delete(vArrayValues, 1, IBar2);
      End;
    End;
  End
 Else
  Begin
   // Verificar se conteudo Body/Raw é um JSON para casos em que não se passa parametro indicando a presente de JSON
   // Ico Menezes - 30/08/2019
   Result   := True;
   vArrayValues := StringReplace(Trim(vArrayValues), #239#187#191, '', [rfReplaceAll]);
   vArrayValues := StringReplace(vArrayValues, sLineBreak,   '', [rfReplaceAll]);
   If (vArrayValues[InitStrPos] = '[') or (vArrayValues[InitStrPos] = '{') then
    Begin
     JSONParam := TJSONParam.Create(ResultPR.Encoding);
     JSONParam.ParamName       := cUndefined;
     JSONParam.ObjectDirection := odIN;
     JSONParam.SetValue(vArrayValues, True);
     ResultPR.Add(JSONParam);
    End
   Else
    Begin
     For Cont := 0 to vParamList.Count - 1 Do
      Begin
       If vParamList.Names[cont] = '' Then
        Begin
         JSONParam := ResultPR.ItemsString[cUndefined];
         If JSONParam = Nil Then
          Begin
           JSONParam := TJSONParam.Create(ResultPR.Encoding);
           JSONParam.ParamName := cUndefined;
           JSONParam.ObjectDirection := odIN;
          End;
         JSONParam.SetValue(vParamList[cont]);
        End
       Else
        Begin
         JSONParam := ResultPR.ItemsString[vParamList.Names[cont]];
         If JSONParam = Nil Then
          Begin
           JSONParam := TJSONParam.Create(ResultPR.Encoding);
           JSONParam.ObjectDirection := odIN;
           JSONParam.ParamName := vParamList.Names[cont];
          End;
         JSONParam.SetValue(vParamList.Values[vParamList.Names[cont]]);
        End;
       ResultPR.Add(JSONParam);
      End;
    End;
  End;
 vParamList.Free;
End;

Class Procedure TServerUtils.ParseWebFormsParams (Var DWParams     : TDWParams;
                                                  WebParams        : TStrings;
                                                  vEncoding        : TEncodeSelect
                                                  {$IFDEF FPC}
                                                  ;DatabaseCharSet : TDatabaseCharSet
                                                  {$ENDIF};
                                                  MethodType       : TRequestType = rtPost);
Var
 I          : Integer;
 JSONParam  : TJSONParam;
 vParams    : TStringList;
 vParamName : String;
Begin                                                   
 JSONParam := Nil;
 vParams   := Nil;
 If (WebParams.Count > 0) Then
  Begin
   WebParams.Text := TIdURI.URLDecode(WebParams.Text);
   For I := 0 To WebParams.Count - 1 Do
    Begin
     If Pos('{"ObjectType":"toParam", "Direction":"', WebParams[I]) > 0 Then
      Begin
       JSONParam := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ObjectDirection := odIN;
       If Pos('=', WebParams[I]) > 0 Then
        JSONParam.FromJSON(Trim(Copy(WebParams[I], Pos('=', WebParams[I]) + 1, Length(WebParams[I]))))
       Else
        JSONParam.FromJSON(WebParams[I]);
      End
     Else
      Begin
       vParamName := Copy(WebParams[I], 1, Pos('=', WebParams[I]) - 1);
       JSONParam  := DWParams.ItemsString[vParamName];
       If Not Assigned(JSONParam) Then
        JSONParam := TJSONParam.Create(DWParams.Encoding)
       Else
        Continue; 
       JSONParam.ObjectDirection := odIN;
       JSONParam.ParamName := vParamName;
       If DWParams.Encoding = esUtf8 then
        JSONParam.AsString  := Utf8Encode(Trim(Copy(WebParams[I], Pos('=', WebParams[I]) + 1, Length(WebParams[I]))))
       Else
        JSONParam.AsString  := Trim(Copy(WebParams[I], Pos('=', WebParams[I]) + 1, Length(WebParams[I])));
       If JSONParam.AsString = '' Then
        JSONParam.Encoded         := False;
      End;
     If Assigned(JSONParam) Then
      DWParams.Add(JSONParam);
    End;
  End;
End;

Class Procedure TServerUtils.ParseWebFormsParams (Var DWParams       : TDWParams;
                                                  Params             : TStrings;
                                                  Const URL,
                                                  Query              : String;
                                                  Var UriOptions     : TRESTDWUriOptions;
                                                  Var mark           : String;
                                                  vEncoding          : TEncodeSelect;
                                                  {$IFDEF FPC}
                                                   DatabaseCharSet   : TDatabaseCharSet;
                                                  {$ENDIF}
                                                  ParamsCount        : Integer;
                                                  MethodType         : TRequestType = rtPost);
Var
 aParamsCount,
 aParamsIndex,
 ArraySize,
 IBar, I    : Integer;
 vTempValue,
 vTempData,
 Cmd        : String;
 aNewParam  : Boolean;
 JSONParam  : TJSONParam;
 vParams    : TStringList;
 Uri        : TIdURI;
Begin
  // Extrai nome do ServerMethod
 If DWParams = Nil Then
  Begin
   DWParams := TDWParams.Create;
   DWParams.Encoding := vEncoding;
   {$IFDEF FPC}
   DWParams.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
 JSONParam := Nil;
 UriOptions.BaseServer  := '';
 UriOptions.DataUrl     := '';
 UriOptions.ServerEvent := '';
 UriOptions.EventName   := '';
 aParamsCount           := ParamsCount;
 aParamsIndex           := 0;
 Cmd                    := URL;
 If Pos('?', Cmd) > 0 Then
  Begin
   I := Pos('?', Cmd);
   Cmd := Copy(Cmd, InitStrPos, I - FinalStrPos);
  End;
 If Cmd <> '' Then
  Begin
   If Cmd[Length(Cmd) - FinalStrPos] <> '/' Then
    Cmd := URL + '/';
  End;
 If (CountExpression(Cmd, '/') > 1) Then
  Begin
   If Cmd[InitStrPos] <> '/' then
    Cmd := '/' + Cmd
   Else
    Cmd := Copy(Cmd, 2, Length(Cmd));
   If Cmd[Length(Cmd) - FinalStrPos] <> '/' Then
    Cmd := Cmd + '/';
   ArraySize := CountExpression(Cmd, '/');
   For I := 0 to ArraySize - 1 Do
    Begin
     IBar     := Pos('/', Cmd);
     {$IFNDEF FPC}
      {$IF (DEFINED(OLDINDY))}
       vTempData := TIdURI.URLDecode(Copy(Cmd, 1, IBar - 1));
      {$ELSE}
       vTempData := TIdURI.URLDecode(Copy(Cmd, 1, IBar - 1), GetEncodingID(vEncoding));
      {$IFEND}
     {$ELSE}
      vTempData := TIdURI.URLDecode(Copy(Cmd, 1, IBar - 1), GetEncodingID(vEncoding));
     {$ENDIF}
     If I <= aParamsCount Then
      Begin
       If (UriOptions.EventName = '')  Or (aParamsCount = cParamsCount) Then
        Begin
         If (vTempData <> '') Then
          Begin
           If (aParamsCount = cParamsCount) Then
            Begin
             If ArraySize <= cParamsCount Then
              Begin
               If ArraySize < cParamsCount Then
                Begin
                 If (UriOptions.EventName = '') Then
                  UriOptions.EventName    := vTempData
                 Else
                  UriOptions.ServerEvent  := vTempData;
                End
               Else
                Begin
                 If (UriOptions.ServerEvent <> '') Then
                  UriOptions.EventName    := vTempData
                 Else
                  UriOptions.ServerEvent  := vTempData;
                End;
              End
             Else
              Begin
               If (UriOptions.ServerEvent <> '') Then
                UriOptions.EventName    := vTempData
               Else
                UriOptions.ServerEvent  := vTempData;
              End;
            End
           Else
            Begin
             If (UriOptions.ServerEvent <> '') Then
              UriOptions.EventName    := vTempData
             Else
              UriOptions.ServerEvent  := vTempData;
            End;
          End;
        End
       Else If (UriOptions.EventName <> '') Then
        Begin
         If (vTempData <> '') then
          Begin
           If UriOptions.BaseServer <> '' Then
            Begin
             If (UriOptions.DataUrl     <> '') And
                (UriOptions.ServerEvent <> '') Then
              Begin
               If (UriOptions.DataUrl <> UriOptions.ServerEvent) then
                UriOptions.BaseServer := UriOptions.DataUrl
               Else
                UriOptions.ServerEvent := UriOptions.EventName;
              End
             Else
              Begin
  //             UriOptions.DataUrl     := UriOptions.ServerEvent;
               UriOptions.ServerEvent := UriOptions.EventName;
              End;
             UriOptions.EventName   := vTempData;
            End
           Else
            Begin
             UriOptions.BaseServer  := UriOptions.ServerEvent;
             UriOptions.DataUrl     := UriOptions.EventName;
             UriOptions.ServerEvent := UriOptions.DataUrl;
             UriOptions.EventName   := vTempData;
            End;
          End;
        End;
      End
     Else
      Begin
       aNewParam   := False;
       JSONParam                 := DWParams.ItemsString[IntToStr(aParamsIndex)];
       If JSONParam = Nil Then
        Begin
         aNewParam := True;
         JSONParam := TJSONParam.Create(DWParams.Encoding);
         JSONParam.ParamName     := IntToStr(aParamsIndex);
        End;
       JSONParam.ObjectDirection := odIN;
       JSONParam.AsString        := vTempData;
       If aNewParam Then
        DWParams.Add(JSONParam);
       Inc(aParamsIndex);
       aNewParam := False;
      End;
     Cmd := Copy(Cmd, IBar +1, Length(Cmd));
    End;
   If (UriOptions.ServerEvent <> '') And (UriOptions.EventName = '') Then
    Begin
     UriOptions.EventName   := UriOptions.ServerEvent;
     UriOptions.ServerEvent := '';
    End;
  End;
  // Extrai Parametros
 If (Params.Count > 0) And (MethodType = rtPost) Then
  Begin
   Params.Text := TIdURI.URLDecode(Params.Text);
   For I := 0 To Params.Count - 1 Do
    Begin
     If Pos('dwmark:', Params[I]) > 0 Then
      mark := Copy(Params[I], Pos('dwmark:', Params[I]) + 7, Length(Params[I]))
     Else
      Begin
       JSONParam := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ObjectDirection := odIN;
       If Pos('{"ObjectType":"toParam", "Direction":"', Params[I]) > 0 Then
        Begin
         If Pos('=', Params[I]) > 0 Then
          JSONParam.FromJSON(Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I]))))
         Else
          JSONParam.FromJSON(Params[I]);
        End
       Else
        Begin
         JSONParam.ParamName := Copy(Params[I], 1, Pos('=', Params[I]) - 1);
         If DWParams.Encoding = esUtf8 then
          JSONParam.AsString  := Utf8Encode(Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I]))))
         Else
          JSONParam.AsString  := Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I])));
         If JSONParam.AsString = '' Then
          JSONParam.Encoded         := False;
        End;
       DWParams.Add(JSONParam);
      End;
    End;
  End
 Else
  Begin
   vParams := TStringList.Create;
   vParams.Delimiter := '&';
   {$IFNDEF FPC}{$if CompilerVersion > 21}vParams.StrictDelimiter := true;{$IFEND}{$ENDIF}
   If pos(UriOptions.EventName + '/', Cmd) > 0 Then
    Cmd := StringReplace(UriOptions.EventName + '/', Cmd, '', [rfReplaceAll]);
   If (MethodType = rtGet) Then
    Begin
     If ((Params.Count > 0) And (Pos('?', URL) = 0)) And (Query = '') then
      Cmd := Cmd + Params.Text
     Else
      Cmd := Cmd + TIdURI.URLDecode(Query);
    End
   Else
    Begin
     If ((Params.Count > 0) And (Pos('?', URL) = 0)) And (Query = '') then
      Cmd := Cmd + TIdURI.URLDecode(Params.Text)
     Else
      Cmd := Cmd + TIdURI.URLDecode(Query);
    End;
   Uri := TIdURI.Create(Cmd);
   Try
    vParams.DelimitedText := Uri.Params;
    If vParams.count = 0 Then
     If Trim(Cmd) <> '' Then
      vParams.DelimitedText := StringReplace(Cmd, sLineBreak, '&', [rfReplaceAll]); //Alterações enviadas por "joaoantonio19"
      //vParams.Add(Cmd);
   Finally
    Uri.Free;
    For I := 0 To vParams.Count - 1 Do
     Begin
      If Pos('dwmark:', vParams[I]) > 0 Then
       mark := Copy(vParams[I], Pos('dwmark:', vParams[I]) + 7, Length(vParams[I]))
      Else
       Begin
        If vParams[I] <> '' Then
         Begin
          JSONParam                 := TJSONParam.Create(DWParams.Encoding);
          JSONParam.ObjectDirection := odIN;
          JSONParam.ParamName       := Trim(Copy(vParams[I], 1, Pos('=', vParams[I]) - 1));
          JSONParam.AsString        := Trim(Copy(vParams[I],    Pos('=', vParams[I]) + 1, Length(vParams[I])));
          DWParams.Add(JSONParam);
         End;
       End;
     End;
    vParams.Free;
   End;
  End;
End;

Class Procedure TServerUtils.ParseWebFormsParams(Params             : TStrings;
                                                 Const URL,
                                                 Query              : String;
                                                 Var UriOptions     : TRESTDWUriOptions;
                                                 Var mark           : String;
                                                 vEncoding          : TEncodeSelect;
                                                 {$IFDEF FPC}
                                                  DatabaseCharSet   : TDatabaseCharSet;
                                                 {$ENDIF}
                                                 Var Result         : TDWParams;
                                                 ParamsCount        : Integer;
                                                 MethodType         : TRequestType = rtPost;
                                                 ContentType        : String = 'application/json');
Var
 aParamsCount,
 aParamsIndex,
 I, IBar,
 ArraySize  : Integer;
 vTempValue,
 Cmd        : String;
 JSONParam  : TJSONParam;
 vParams    : TStringList;
 Uri        : TIdURI;
 vTempData,
 vValue     : String;
 vCreateParam,
 aNewParam  : Boolean;
Begin
  // Extrai nome do ServerMethod
 If Not Assigned(Result) Then
  Begin
   Result := TDWParams.Create;
   Result.Encoding := vEncoding;
   {$IFDEF FPC}
   Result.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
 JSONParam := Nil;
 UriOptions.BaseServer  := '';
 UriOptions.DataUrl     := '';
 UriOptions.ServerEvent := '';
 UriOptions.EventName   := '';
 Cmd := URL;
 aParamsCount := ParamsCount;
 aParamsIndex := 0;
 If Pos('?', Cmd) > 0 Then
  Begin
   I := Pos('?', Cmd);
   Cmd := Copy(Cmd, InitStrPos, I - FinalStrPos);
  End;
 If Cmd <> '' Then
  Begin
   If Cmd[Length(Cmd) - FinalStrPos] <> '/' Then
    Cmd := URL + '/';
  End;
 If (CountExpression(Cmd, '/') > 1) Then
  Begin
   If Cmd[InitStrPos] <> '/' then
    Cmd := '/' + Cmd
   Else
    Cmd := Copy(Cmd, 2, Length(Cmd));
   If Cmd[Length(Cmd) - FinalStrPos] <> '/' Then
    Cmd := Cmd + '/';
   ArraySize := CountExpression(Cmd, '/');
   For I := 0 to ArraySize - 1 Do
    Begin
     IBar     := Pos('/', Cmd);
     {$IFNDEF FPC}
      {$IF (DEFINED(OLDINDY))}
       vTempData := TIdURI.URLDecode(Copy(Cmd, 1, IBar - 1));
      {$ELSE}
       vTempData := TIdURI.URLDecode(Copy(Cmd, 1, IBar - 1), GetEncodingID(vEncoding));
      {$IFEND}
     {$ELSE}
      vTempData := TIdURI.URLDecode(Copy(Cmd, 1, IBar - 1), GetEncodingID(vEncoding));
     {$ENDIF}
     If I <= aParamsCount Then
      Begin
       If (UriOptions.EventName = '') Or (aParamsCount = cParamsCount) Then
        Begin
         If (vTempData <> '') then
          Begin
           If (aParamsCount = cParamsCount) Then
            Begin
             If ArraySize <= cParamsCount Then
              Begin
               If ArraySize < cParamsCount Then
                Begin
                 If (UriOptions.EventName = '') Then
                  UriOptions.EventName    := vTempData
                 Else
                  UriOptions.ServerEvent  := vTempData;
                End
               Else
                Begin
                 If (UriOptions.ServerEvent <> '') Then
                  UriOptions.EventName    := vTempData
                 Else
                  UriOptions.ServerEvent  := vTempData;
                End;
              End
             Else
              Begin
               If (UriOptions.ServerEvent <> '') Then
                UriOptions.EventName    := vTempData
               Else
                UriOptions.ServerEvent  := vTempData;
              End;
            End
           Else
            Begin
             If (UriOptions.ServerEvent <> '') Then
              UriOptions.EventName    := vTempData
             Else
              UriOptions.ServerEvent  := vTempData;
            End;
          End;
        End
       Else If (UriOptions.EventName <> '') Then
        Begin
         If (vTempData <> '') then
          Begin
           If UriOptions.BaseServer <> '' Then
            Begin
             If (UriOptions.DataUrl     <> '') And
                (UriOptions.ServerEvent <> '') Then
              Begin
               If (UriOptions.DataUrl <> UriOptions.ServerEvent) then
                UriOptions.BaseServer := UriOptions.DataUrl
               Else
                UriOptions.ServerEvent := UriOptions.EventName;
              End
             Else
              Begin
  //             UriOptions.DataUrl     := UriOptions.ServerEvent;
               UriOptions.ServerEvent := UriOptions.EventName;
              End;
             UriOptions.EventName   := vTempData;
            End
           Else
            Begin
             UriOptions.BaseServer  := UriOptions.ServerEvent;
             UriOptions.DataUrl     := UriOptions.EventName;
             UriOptions.ServerEvent := UriOptions.DataUrl;
             UriOptions.EventName   := vTempData;
            End;
          End;
        End;
      End
     Else
      Begin
       aNewParam   := False;
       JSONParam                 := Result.ItemsString[IntToStr(aParamsIndex)];
       If JSONParam = Nil Then
        Begin
         aNewParam := True;
         JSONParam := TJSONParam.Create(Result.Encoding);
         JSONParam.ParamName     := IntToStr(aParamsIndex);
        End;
       JSONParam.ObjectDirection := odIN;
       JSONParam.AsString        := vTempData;
       If aNewParam Then
        Result.Add(JSONParam);
       Inc(aParamsIndex);
       aNewParam := False;
      End;
     Cmd := Copy(Cmd, IBar +1, Length(Cmd));
    End;
   If (UriOptions.ServerEvent <> '') And (UriOptions.EventName = '') Then
    Begin
     UriOptions.EventName   := UriOptions.ServerEvent;
     UriOptions.ServerEvent := '';
    End;
  End;
  // Extrai Parametros
  If (Params.Count > 0) And (MethodType = rtPost) Then
   Begin
    If ContentType <> cApplicationJSON then
     Begin
      {$IFNDEF FPC}
       {$IF (DEFINED(OLDINDY))}
        Params.Text := TIdURI.URLDecode(Params.Text, enDefault);
       {$ELSE}
        Params.Text := TIdURI.URLDecode(Params.Text, IndyTextEncoding_UTF8);
       {$IFEND}
      {$ENDIF}
     End;
    For I := 0 To Params.Count - 1 Do
     Begin
      vCreateParam := False;
      If Pos('dwmark:', Params[I]) > 0 Then
       mark := Copy(Params[I], Pos('dwmark:', Params[I]) + 7, Length(Params[I]))
      Else
       Begin
        If Pos('{"ObjectType":"toParam", "Direction":"', Params[I]) > 0 Then
         Begin
          vCreateParam := True;
          JSONParam := TJSONParam.Create(Result.Encoding);
          {$IFDEF FPC}
          JSONParam.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          JSONParam.ObjectDirection := odIN;
          If Pos('=', Params[I]) > 0 Then
           JSONParam.FromJSON(Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I]))))
          Else
           JSONParam.FromJSON(Params[I]);
         End
        Else
         Begin
          If ((Copy(Params[I], 1, Pos('=', Params[I]) - 1) = '')) And
             (ContentType = cApplicationJSON) Then
           Begin
            JSONParam := Result.ItemsString[cUndefined];
            If JSONParam = Nil Then
             Begin
              vCreateParam := True;
              JSONParam := TJSONParam.Create(Result.Encoding);
              {$IFDEF FPC}
              JSONParam.DatabaseCharSet := DatabaseCharSet;
              {$ENDIF}
              JSONParam.ObjectDirection := odIN;
              JSONParam.ParamName       := cUndefined;
             End;
           End
          Else
           Begin
            If Copy(Params[I], 1, Pos('=', Params[I]) - 1) <> '' Then
             JSONParam := Result.ItemsString[Copy(Params[I], 1, Pos('=', Params[I]) - 1)]
            Else
             JSONParam := Result.ItemsString[cUndefined];
            If JSONParam = Nil Then
             Begin
              vCreateParam := True;
              JSONParam := TJSONParam.Create(Result.Encoding);
              {$IFDEF FPC}
              JSONParam.DatabaseCharSet := DatabaseCharSet;
              {$ENDIF}
              JSONParam.ObjectDirection := odIN;
              If Copy(Params[I], 1, Pos('=', Params[I]) - 1) <> '' Then
               JSONParam.ParamName := Copy(Params[I], 1, Pos('=', Params[I]) - 1)
              Else
               JSONParam.ParamName := cUndefined;
             End;
           End;
          If JSONParam.IsNull Then
           Begin
            If ContentType <> cApplicationJSON Then
             Begin
              vValue  := Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I])));
              {$IFNDEF FPC}
               If Result.Encoding = esUtf8 then
                vValue   := Utf8Encode(vValue);
              {$ENDIF}
             End
            Else
             Begin
              If Copy(Params[I], 1, Pos('=', Params[I]) - 1) <> '' Then
               vValue  := Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I])))
              Else
               vValue  := Params[I];
             End;
            JSONParam.AsString   := vValue;
            If JSONParam.AsString = '' Then
             JSONParam.Encoded   := False;
           End;
         End;
        If vCreateParam Then
         Result.Add(JSONParam);
       End;
     End;
   End
  Else
   Begin
    If (MethodType In [rtGet, rtDelete]) Then
     Begin
      If ((UriOptions.BaseServer = '')   And
          (UriOptions.DataUrl    = ''))  And
         ((UriOptions.ServerEvent <> '') And
          (UriOptions.EventName <> ''))  And
          (Trim(Query) = '') Then
       Begin
        Cmd                    := UriOptions.EventName;
        UriOptions.EventName   := UriOptions.ServerEvent;
        UriOptions.ServerEvent := '';
       End;
     End;
    vParams := TStringList.Create;
    vParams.Delimiter := '&';
    {$IFNDEF FPC}{$if CompilerVersion > 21}vParams.StrictDelimiter := true;{$IFEND}{$ENDIF}
    If pos(UriOptions.EventName + '/', Cmd) > 0 Then
     Cmd := StringReplace(UriOptions.EventName + '/', Cmd, '', [rfReplaceAll]);
    If (MethodType = rtGet) Then
     Begin
      If ((Params.Count > 0) And (Pos('?', URL) = 0)) And (Query = '') then
       Cmd := Cmd + Params.Text
      Else
       Cmd := Cmd + TIdURI.URLDecode(Query);
     End
    Else
     Begin
      If ((Params.Count > 0) And (Pos('?', URL) = 0)) And (Query = '') then
       Cmd := Cmd + TIdURI.URLDecode(Params.Text)
      Else
       Cmd := Cmd + TIdURI.URLDecode(Query);
     End;
    Uri := TIdURI.Create(Cmd);
    Try
     vParams.DelimitedText := Uri.Params;
     If vParams.count = 0 Then
      If Trim(Cmd) <> '' Then
       vParams.DelimitedText := StringReplace(Cmd, sLineBreak, '&', [rfReplaceAll]); //Alterações enviadas por "joaoantonio19"
       //vParams.Add(Cmd);
    Finally
     Uri.Free;
     For I := 0 To vParams.Count - 1 Do
      Begin
       If Pos('dwmark:', vParams[I]) > 0 Then
        mark := Copy(vParams[I], Pos('dwmark:', vParams[I]) + 7, Length(vParams[I]))
       Else
        Begin
         If vParams[I] <> '' Then
          Begin
           JSONParam                 := TJSONParam.Create(Result.Encoding);
           JSONParam.ObjectDirection := odIN;
           If (vParams.names[I] <> '') And
              (Trim(Query)      <> '') Then
            Begin
             JSONParam.ParamName       := Trim(Copy(vParams[I], 1, Pos('=', vParams[I]) - 1));
             JSONParam.AsString        := Trim(Copy(vParams[I],    Pos('=', vParams[I]) + 1, Length(vParams[I])));
            End
           Else
            Begin
             JSONParam.ParamName       := IntToStr(I);
             JSONParam.AsString        := vParams[I];
            End;
           {$IFDEF FPC}
           JSONParam.DatabaseCharSet := DatabaseCharSet;
           {$ENDIF}
           Result.Add(JSONParam);
          End;
        End;
      End;
     vParams.Free;
    End;
   End;
End;

Class Function TServerUtils.Result2JSON(wsResult: TResultErro): String;
Begin
  Result := '{"STATUS":"' + wsResult.Status + '","MENSSAGE":"' +
    wsResult.MessageText + '"}';
End;

end.


