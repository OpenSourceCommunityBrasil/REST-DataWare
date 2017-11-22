unit SysTypes;

Interface

Uses
  IdURI, IdGlobal, SysUtils, Classes, ServerUtils, uRESTDWBase, uDWConsts,
  uDWJSONObject, uDWConstsData, uDWMassiveBuffer;

Type
 TReplyEvent     = Procedure(SendType           : TSendEvent;
                             Context            : String;
                             Var Params         : TDWParams;
                             Var Result         : String) Of Object;
 TWelcomeMessage = Procedure(Welcomemsg         : String) Of Object;
 TMassiveProcess = Procedure(Var MassiveDataset : TMassiveDatasetBuffer; Var Ignore : Boolean) Of Object;

Type
  TResultErro = Record
    Status, MessageText: String;
  End;

  TArguments = Array Of String;

Type
  TServerUtils = Class
    Class Function ParseRESTURL(Const Cmd: String
{$IFNDEF FPC}
{$IF CompilerVersion > 21};
      vEncoding: TEncoding
{$IFEND}
{$ENDIF}): TDWParams;
    Class Function Result2JSON(wsResult: TResultErro): String;
    Class Function ParseWebFormsParams(Params: TStrings; Const URL: String;
                                       Var UrlMethod: String{$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              ;vEncoding: TEncoding
                                                             {$IFEND}
                                                            {$ENDIF};MethodType : String = 'POST'): TDWParams;
  End;

Type
  TServerMethods = Class(TComponent)
  Protected
   vReplyEvent     : TReplyEvent;
   vWelcomeMessage : TWelcomeMessage;
   vMassiveProcess : TMassiveProcess;
   Function ReturnIncorrectArgs: String;
   Function ReturnMethodNotFound: String;
  Public
   Encoding: TEncodeSelect;
   Constructor Create(aOwner: TComponent); Override;
   Destructor Destroy; Override;
  Published
   Property OnReplyEvent     : TReplyEvent      Read vReplyEvent     Write vReplyEvent;
   Property OnWelcomeMessage : TWelcomeMessage  Read vWelcomeMessage Write vWelcomeMessage;
   Property OnMassiveProcess : TMassiveProcess  Read vMassiveProcess Write vMassiveProcess;
  End;

implementation

{ TServerMethods }

// Retorna um array de strings com os parametros vindos da URL
// Ex de Cmd : 'GET /NomedoMetodo/Argumento1/Argumento2/ArgumentoN HTTP/1.1'
Class Function TServerUtils.ParseRESTURL(Const Cmd: String
{$IFNDEF FPC}
{$IF CompilerVersion > 21};
  vEncoding: TEncoding
{$IFEND}
{$ENDIF}): TDWParams;
Var
  NewCmd: String;
  ArraySize, iBar1, IBar2, Cont: Integer;
  JSONParam: TJSONParam;
  Function CountExpression(Value: String; Expression: Char): Integer;
  Var
    I: Integer;
  Begin
    Result := 0;
    For I := 0 To Length(Value) - 1 Do
    Begin
      If Value[I] = Expression Then
        Inc(Result);
    End;
  End;

Begin
  NewCmd := Cmd;
  If CountExpression(NewCmd, '/') > 0 Then
  Begin
    ArraySize := CountExpression(NewCmd, '/');
    // SetLength(Result, ArraySize);
    Result := TDWParams.Create;
{$IFNDEF FPC}
{$IF CompilerVersion > 21}
    Result.Encoding := vEncoding;
{$IFEND}
{$ENDIF}
    NewCmd := NewCmd + '/';
    iBar1 := Pos('/', NewCmd);
    Delete(NewCmd, 1, iBar1);
    For Cont := 0 to ArraySize - 1 Do
    Begin
      IBar2 := Pos('/', NewCmd);
      JSONParam := TJSONParam.Create{$IFNDEF FPC}{$IF CompilerVersion > 21} (Result.Encoding){$IFEND}{$ENDIF};
      JSONParam.ParamName := Format('PARAM%d', [Cont + 1]);
{$IFNDEF FPC}
{$IF CompilerVersion > 21}
      JSONParam.SetValue(TIdURI.URLDecode(Copy(NewCmd, 1, IBar2 - 1),
        IndyTextEncoding(encUTF8)));
{$ELSE}
      JSONParam.SetValue(TIdURI.URLDecode(Copy(NewCmd, 1, IBar2 - 1)));
{$IFEND}
{$ELSE}
      JSONParam.SetValue(TIdURI.URLDecode(Copy(NewCmd, 1, IBar2 - 1)));
{$ENDIF}
      Delete(NewCmd, 1, IBar2);
    End;
  End;
 //Alexandre Magno - 07/11/2017
 If Assigned(JSONParam) Then
  FreeAndNil(JSONParam);
End;

Class Function TServerUtils.ParseWebFormsParams(Params: TStrings;
  const URL: String; Var UrlMethod: String
{$IFNDEF FPC}
{$IF CompilerVersion > 21};
  vEncoding: TEncoding
{$IFEND}
{$ENDIF};MethodType : String = 'POST'): TDWParams;
Var
  I: Integer;
  Cmd: String;
  JSONParam: TJSONParam;
  vParams : TStringList;
  Uri : TIdURI;
Begin
  // Extrai nome do ServerMethod
  Result := TDWParams.Create;
{$IFNDEF FPC}
{$IF CompilerVersion > 21}
  Result.Encoding := vEncoding;
{$IFEND}
{$ENDIF}
  If Pos('?', URL) > 0 Then
   Begin
    Cmd := URL;
    I := Pos('?', Cmd);
    UrlMethod := StringReplace(Copy(Cmd, 1, I - 1), '/', '', [rfReplaceAll]);
    Delete(Cmd, 1, I);
    I := Pos('?', Cmd);
   End
  Else
   Begin
    Cmd := URL + '/';
    I := Pos('/', Cmd);
    Delete(Cmd, 1, I);
    I := Pos('/', Cmd);
    UrlMethod := Copy(Cmd, 1, I - 1);
   End;
  // Extrai Parametros
  If (Params.Count > 0) And (MethodType = 'POST') Then
   Begin
    For I := 0 To Params.Count - 1 Do
     Begin
      JSONParam := TJSONParam.Create{$IFNDEF FPC}{$IF CompilerVersion > 21}(Result.Encoding){$IFEND}{$ENDIF};
      JSONParam.FromJSON(Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I]))));
      Result.Add(JSONParam);
     End;
   End
  Else
   Begin
    vParams := TStringList.Create;
    vParams.Delimiter := '&';
    vParams.StrictDelimiter := true;
    If pos(UrlMethod + '/', Cmd) > 0 Then
     Cmd := StringReplace(UrlMethod + '/', Cmd, '', [rfReplaceAll]);
    If (Params.Count > 0) then
     Cmd := Cmd + Params.Text;
    Uri := TIdURI.Create(Cmd);
    Try
     vParams.DelimitedText := Uri.Params;
     If vParams.count = 0 Then
      If Trim(Cmd) <> '' Then
       vParams.Add(Cmd);
    Finally
     Uri.Free;
     For I := 0 To vParams.Count - 1 Do
      Begin
       JSONParam                 := TJSONParam.Create{$IFNDEF FPC}{$IF CompilerVersion > 21}(Result.Encoding){$IFEND}{$ENDIF};
       JSONParam.ParamName       := Trim(Copy(vParams[I], 1, Pos('=', vParams[I]) - 1));
       JSONParam.AsString        := Trim(Copy(vParams[I],    Pos('=', vParams[I]) + 1, Length(vParams[I])));
       JSONParam.ObjectDirection := odIN;
       Result.Add(JSONParam);
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

constructor TServerMethods.Create(aOwner: TComponent);
begin
  inherited;
end;

destructor TServerMethods.Destroy;
begin
  inherited;
end;

Function TServerMethods.ReturnIncorrectArgs: String;
Var
  wsResult: TResultErro;
Begin
  wsResult.Status := '-1';
  wsResult.MessageText := 'Total de argumentos menor que o esperado';
  Result := TServerUtils.Result2JSON(wsResult);
End;

Function TServerMethods.ReturnMethodNotFound: String;
Var
  wsResult: TResultErro;
Begin
  wsResult.Status := '-2';
  wsResult.MessageText := 'Metodo nao encontrado';
  Result := TServerUtils.Result2JSON(wsResult);
End;

end.
