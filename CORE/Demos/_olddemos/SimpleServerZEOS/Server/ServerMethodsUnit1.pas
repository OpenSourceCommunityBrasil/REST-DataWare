unit ServerMethodsUnit1;

interface

uses SysUtils, Classes, Windows, uDWConsts, uDWConstsData, uDWJSONTools, uDWJSONObject,
     System.JSON, Dialogs, ServerUtils, SysTypes,
     {$IFDEF FPC}
     {$ELSE}
         ZAbstractConnection, ZConnection,ZAbstractRODataset, ZAbstractDataset,
     ZDataset;

     {$ENDIF}

Type
{$METHODINFO ON}
  TServerMethods1 = class(TServerMethods)
  Private
   // http://localhost:8080/InsereAluno/fulano
   Function InsereAluno (NomeAluno : String) : String;
   // http://localhost:8080/ConsultaAluno/fulano
   Function ConsultaAluno (NomeAluno : String) : String;
   // http://localhost:8080/GetListaAlunos
   Function GetListaAlunos : String;
   // http://localhost:8080/AtualizaAluno/Fulano/cicrano
   Function AtualizaAluno(OldNomeAluno,
                          NewNome   : String) : String;
   // http://localhost:8080/ExcluiAluno/NomeAluno
   Function ExcluiAluno  (NomeAluno : String) : String;
   // http://localhost:8080/ConsultaBanco/SQL ENCODE64
   Function ConsultaBanco(SQL        : String)    : String;Overload;
   Function ConsultaBanco(Var Params : TDWParams) : String;Overload;
   Function CallGETServerMethod   (Argumentos : TArguments) : String;
   Function CallPUTServerMethod   (Argumentos : TArguments) : string;
   Function CallDELETEServerMethod(Argumentos : TArguments) : string;
   Function CallPOSTServerMethod  (Argumentos : TArguments) : string;
  public
   { Public declarations }
   Constructor Create    (aOwner : TComponent); Override;
   Destructor  Destroy; Override;
   Procedure   vReplyEvent(SendType   : TSendEvent;
                           Context    : String;
                           Var Params : TDWParams;
                           Var Result : String);
  End;
{$METHODINFO OFF}

implementation

uses StrUtils, RestDWServerFormU;


Constructor TServerMethods1.Create (aOwner : TComponent);
Begin
 Inherited Create (aOwner);
 OnReplyEvent := vReplyEvent;
End;

Destructor TServerMethods1.Destroy;
Begin
 Inherited Destroy;
End;

Function TServerMethods1.CallGETServerMethod (Argumentos : TArguments) : string;
Var
 FoundMethod : Boolean;
begin
 FoundMethod := False;
 If Length(Argumentos) > 0 Then
  Begin
   If UpperCase(Argumentos[0]) = UpperCase('ConsultaAluno') Then
    Begin
     FoundMethod := True;
     {TODO CRISTIANO BARBOSA - jsonp}
     If Length (Argumentos) >= 4 Then
      Result := ConsultaAluno (Argumentos[2])
     else If Length (Argumentos) >= 2 Then
      Result := ConsultaAluno (Argumentos[1])
     Else
      Result := ReturnIncorrectArgs;
    End;
   If UpperCase(Argumentos[0]) = UpperCase('GetListaAlunos') Then
    Begin
     FoundMethod := True;
     {falta testar - jsonp}

     If Length (Argumentos) >= 1 Then
      Result := GetListaAlunos
     Else
      Result := ReturnIncorrectArgs;
    End;
   If UpperCase(Argumentos[0]) = UpperCase('ConsultaBanco') Then
    Begin
     FoundMethod := True;
     {TODO CRISTIANO BARBOSA - jsonp}
     If Length (Argumentos) >= 4 Then
      Result := ConsultaBanco (Argumentos[2])
     else If Length (Argumentos) >= 2 Then
      Result := ConsultaBanco(Argumentos[1])
     Else
      Result := ReturnIncorrectArgs;
    End;
  End;
 If Not FoundMethod Then
  Result := ReturnMethodNotFound;
End;

Function TServerMethods1.CallPOSTServerMethod (Argumentos : TArguments) : string;
Var
 FoundMethod : Boolean;
Begin
 FoundMethod := False;
 If UpperCase(Argumentos[0]) = UpperCase('AtualizaAluno') Then
  Begin
   FoundMethod := True;
   If Length (Argumentos) >= 3 Then
    Result := AtualizaAluno (Argumentos[1], Argumentos[2])
   Else
    Result := ReturnIncorrectArgs;
  End;
 If UpperCase(Argumentos[0]) = UpperCase('ConsultaBanco') Then
  Begin
   FoundMethod := True;
   If Length (Argumentos) >= 2 Then
    Result := ConsultaBanco(Argumentos[1])
   Else
    Result := ReturnIncorrectArgs;
  End;
 If Not FoundMethod Then
  Result := ReturnMethodNotFound;
End;

Function TServerMethods1.CallPUTServerMethod (Argumentos : TArguments) : string;
Var
 FoundMethod : Boolean;
Begin
 FoundMethod := False;
 If UpperCase(Argumentos[0]) = UpperCase('InsereAluno') Then
  Begin
   FoundMethod := True;
   If Length (Argumentos) >= 2 Then
    Result := InsereAluno (Argumentos[1])
   Else
    Result := ReturnIncorrectArgs;
  End;
 If Not FoundMethod Then
  Result := ReturnMethodNotFound;
End;

Function TServerMethods1.CallDELETEServerMethod (Argumentos : TArguments) : string;
Var
 FoundMethod : Boolean;
Begin
 FoundMethod := False;
 If UpperCase(Argumentos[0]) = UpperCase('ExcluiAluno') Then
  Begin
   FoundMethod := True;
   If Length (Argumentos) >= 2 Then
    Result := ExcluiAluno (Argumentos[1])
   Else
    Result := ReturnIncorrectArgs;
  End;
 If Not FoundMethod Then
  Result := ReturnMethodNotFound;
End;

// Aqui voce vai
// 1 - Conectar com o Banco
// 2 - Executar a query
// 3 - Fechar conexão com o banco
// 4 - Retornar o resultado em JSON

// Foi usado um Arquivo Texto para armazenar dados e um StringList
// o objetivo aqui é apenas mostrar como é um WebService REST + JSON
// e suas operações, o codigo de banco fica por sua conta.

Function TServerMethods1.InsereAluno (NomeAluno : String) : String;
Var
 List       : TStringList;
 JSONObject : TJSONObject;
Begin
 List       := TStringList.Create;
 JSONObject := TJSONObject.Create;
 Try
  If Not FileExists (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt') then
   FileClose(FileCreate (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt'));
  List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
  List.Add (NomeAluno);
  List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
  JSONObject.AddPair(TJSONPair.Create('STATUS',   'OK'));
  JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Inserido com sucesso'));
  Result := JSONObject.ToJSON;
 Finally
  List.Free;
  JSONObject.Free;
 End;
End;

Procedure TServerMethods1.vReplyEvent(SendType   : TSendEvent;
                                      Context    : String;
                                      Var Params : TDWParams;
                                      Var Result : String);
Var
 JSONObject : TJSONObject;
Begin
 JSONObject := TJSONObject.Create;
 Case SendType Of
  sePOST   :
   Begin
    If UpperCase(Context) = Uppercase('ConsultaBanco') Then
     Result := ConsultaBanco(Params)
    Else
     Begin
      JSONObject.AddPair(TJSONPair.Create('STATUS',   'NOK'));
      JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Método não encontrado'));
      Result := JSONObject.ToJSON;
     End;
   End;
 End;
 JSONObject.Free;
End;

Function TServerMethods1.ConsultaAluno (NomeAluno : String) : String;
Var
 List : TStringList;
 JSONObject : TJSONObject;
 ID : Integer;
Begin
 List := TStringList.Create;
 JSONObject := TJSONObject.Create;
 Try
  If FileExists (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt') Then
   Begin
    List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
    ID := List.IndexOf(NomeAluno);
    If ID > -1 Then
     JSONObject.AddPair(TJSONPair.Create('ID', IntToStr(ID)))
    Else
     Begin
      JSONObject.AddPair(TJSONPair.Create('STATUS',   'NOK'));
      JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Não encontrado'));
     End;
   End
  Else
   Begin
    JSONObject.AddPair(TJSONPair.Create('STATUS',   'NOK'));
    JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Não encontrado'));
   End;
  Result := JSONObject.ToJSON;
 Finally
  List.Free;
  JSONObject.Free;
 End;
End;

Function TServerMethods1.ConsultaBanco(Var Params : TDWParams) : String;
Var
 vSQL : String;
 JSONValue : uDWJSONObject.TJSONValue;
 fdQuery : TZQuery;
 JSONParam: TJSONParam;
Begin
 If Params.ItemsString['SQL'] <> Nil Then
  Begin
   JSONValue          := uDWJSONObject.TJSONValue.Create;
   JSONValue.Encoding := GetEncoding(RestDWForm.RESTServicePooler1.Encoding);
   If Params.ItemsString['SQL'].value <> '' Then
    Begin
     If Params.ItemsString['TESTPARAM'] <> Nil Then
      Params.ItemsString['TESTPARAM'].SetValue('OK');

     If Params.ItemsString['PARAM_CRIADO_NO_SERVER'] = Nil Then
     begin
         //DWParams            := TDWParams.Create;
         //DWParams.Encoding   := GetEncoding(RESTClientPooler1.Encoding);
         JSONParam           := TJSONParam.Create(Params.Encoding);
         JSONParam.ParamName := 'PARAM_CRIADO_NO_SERVER';

         //;;SQL := mComando1.Text;
         JSONParam.SetValue('SERVER_OK');
         Params.Add(JSONParam);

     end
     else
       Params.ItemsString['PARAM_CRIADO_NO_SERVER'].SetValue('SERVER_OK');

     vSQL      := Params.ItemsString['SQL'].value;
     {$IFDEF FPC}
     {$ELSE}
      fdQuery   := TZQuery.Create(Nil);
      Try
       fdQuery.Connection := RestDWForm.Server_FDConnection;
       fdQuery.SQL.Add(vSQL);
       JSONValue.LoadFromDataset('sql', fdQuery, RestDWForm.cbEncode.Checked);
       Result             := JSONValue.ToJSON;
      Finally
       JSONValue.Free;
       fdQuery.Free;
      End;
     {$ENDIF}
    End;
  End;
End;

Function TServerMethods1.ConsultaBanco(SQL : String): String;
Var
 vSQL : String;
 JSONValue : uDWJSONObject.TJSONValue;
 {$IFDEF FPC}
 {$ELSE}
    fdQuery : TZQuery;
 {$ENDIF}
Begin
 JSONValue := uDWJSONObject.TJSONValue.Create;
 JSONValue.Encoding := GetEncoding(RestDWForm.RESTServicePooler1.Encoding);
 JSONValue.LoadFromJSON(SQL);
 If JSONValue.Value <> '' Then
  Begin
   vSQL      := DecodeStrings(JSONValue.Value);
   {$IFDEF FPC}
   {$ELSE}
    fdQuery   := TZQuery.Create(Nil);
    Try
     fdQuery.Connection := RestDWForm.Server_FDConnection;
     fdQuery.SQL.Add(vSQL);
     JSONValue.LoadFromDataset('sql', fdQuery);
     Result             := JSONValue.Value;
    Finally
     JSONValue.Free;
     fdQuery.Free;
    End;
   {$ENDIF}
  End;
End;

Function TServerMethods1.GetListaAlunos : String;
Var
 List        : TStringList;
 ID          : Integer;
 LJson       : TJSONObject;
 LJsonObject : TJSONObject;
 LArr        : TJSONArray;
 FileLoad,
 LinesD      : String;
Begin
 FileLoad    := ExtractFilePath(ParamSTR(0)) + '\Alunos.Txt';
 If FileExists(FileLoad) Then
  Begin
   List        := TStringList.Create;
   LJsonObject := TJSONObject.Create;
   LArr        := TJSONArray.Create;
   Try
    List.LoadFromFile(FileLoad);
    For Id := 0 To List.Count - 1 Do
     Begin
      LinesD := List [ID];
      LJson := TJSONObject.Create;
      LJson.AddPair(TJSONPair.Create('NomeAluno', LinesD));
      LArr.Add(LJson);
     End;
    LJsonObject.AddPair(TJSONPair.Create('Alunos', LArr));
    LinesD := LJsonObject.ToJSON;
    Result := LinesD;
   Finally
    List.Free;
    LJsonObject.Free;
   End;
  End;
End;

Function TServerMethods1.AtualizaAluno (OldNomeAluno, NewNome : String) : String;
Var
 List       : TStringList;
 JSONObject : TJSONObject;
 ID         : Integer;
Begin
 List := TStringList.Create;
 JSONObject := TJSONObject.Create;
 Try
  List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
  ID := List.IndexOf(OldNomeAluno);
  If ID > -1 Then
   Begin
    List[ID] := NewNome;
    List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
    JSONObject.AddPair(TJSONPair.Create('STATUS',   'OK'));
    JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Atualizado com sucesso'));
   End
  Else
   Begin
    JSONObject.AddPair(TJSONPair.Create('STATUS',   'NOK'));
    JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Aluno não encontrado'));
   End;
  Result := JSONObject.ToJSON;
 Finally
  List.Free;
  JSONObject.Free;
 End;
End;

Function TServerMethods1.ExcluiAluno (NomeAluno : String) : String;
Var
 List       : TStringList;
 JSONObject : TJSONObject;
 ID         : Integer;
Begin
 List := TStringList.Create;
 JSONObject := TJSONObject.Create;
 Try
  List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
  ID := List.IndexOf(NomeAluno);
  If ID > -1 Then
   Begin
    List.Delete(ID);
    List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
    JSONObject.AddPair(TJSONPair.Create('STATUS',   'OK'));
    JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Deletado com sucesso'));
   End
  Else
   Begin
    JSONObject.AddPair(TJSONPair.Create('STATUS',   'NOK'));
    JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Aluno não encontrado'));
   End;
  Result := JSONObject.ToJSON;
 Finally
  List.Free;
  JSONObject.Free;
 End;
End;


End.




