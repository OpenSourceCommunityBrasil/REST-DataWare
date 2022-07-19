unit ServerMethodsUnit1;

interface

uses SysUtils, Classes, Windows, uDWConsts, uDWJSONTools, uDWJSONObject,
     uLkJSON, Dialogs, ServerUtils, SysTypes, ibquery;

Type
{$METHODINFO ON}
  TServerMethods1 = class(TServerMethods)
  Private
   Function ConsultaBanco(Var Params : TDWParams) : String;Overload;
  public
   { Public declarations }
   Constructor Create    (aOwner : TComponent); Override;
   Destructor  Destroy; Override;
   Function    ReplyEvent(SendType   : TSendEvent;
                          Context    : String;
                          Var Params : TDWParams) : String;Override;
  End;
{$METHODINFO OFF}

implementation

uses StrUtils, RestDWServerFormU;


Constructor TServerMethods1.Create (aOwner : TComponent);
Begin
 Inherited Create (aOwner);
End;

Destructor TServerMethods1.Destroy;
Begin
 Inherited Destroy;
End;

Function TServerMethods1.ReplyEvent(SendType   : TSendEvent;
                                    Context    : String;
                                    Var Params : TDWParams) : String;
Var
 JSONObject : TlkJSONobject;
Begin
 JSONObject := TlkJSONobject.Create;
 Case SendType Of
  sePOST   :
   Begin
    If UpperCase(Context) = Uppercase('ConsultaBanco') Then
     Result := ConsultaBanco(Params)
    Else
     Begin
      JSONObject.Add('STATUS', 'NOK');
      JSONObject.Add('MENSAGEM', 'Método não encontrado');
      Result := JSONObject.Value;
     End;
   End;
 End;
 JSONObject.Free;
End;

Function TServerMethods1.ConsultaBanco(Var Params : TDWParams) : String;
Var
 vSQL : String;
 JSONValue : TJSONValue;
 fdQuery : TibQuery;
Begin
 If Params.ItemsString['SQL'] <> Nil Then
  Begin
   JSONValue          := TJSONValue.Create;
   If Params.ItemsString['SQL'].value <> '' Then
    Begin
     If Params.ItemsString['TESTPARAM'] <> Nil Then
      Params.ItemsString['TESTPARAM'].SetValue('OK, OK');
     vSQL      := Params.ItemsString['SQL'].value;
     {$IFDEF FPC}
     {$ELSE}
      fdQuery   := TibQuery.Create(Nil);
      Try
       fdQuery.Database := RestDWForm.Server_FDConnection;
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

End.




