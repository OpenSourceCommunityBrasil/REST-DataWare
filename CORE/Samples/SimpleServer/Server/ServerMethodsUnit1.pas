unit ServerMethodsUnit1;

interface

uses SysUtils, Classes, Windows, uRESTDWBase, uDWConsts, uDWConstsData, uDWJSONTools, uDWJSONObject,
     System.JSON, Dialogs, ServerUtils, SysTypes,
     {$IFDEF FPC}
     {$ELSE}
     FireDAC.Dapt,
     FireDAC.Phys.FBDef,
     FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf, FireDAC.Stan.Option,
     FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
     FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, Data.DB,
     FireDAC.Comp.Client, FireDAC.Comp.UI, FireDAC.Phys.IBBase,
     FireDAC.Stan.StorageJSON;
     {$ENDIF}

Type
{$METHODINFO ON}
  TServerMethodsComp = Class(TServerMethods)
  Private
   Function ConsultaBanco(Var Params : TDWParams) : String;Overload;
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


Constructor TServerMethodsComp.Create (aOwner : TComponent);
Begin
 Inherited Create (aOwner);
 OnReplyEvent := vReplyEvent;
End;

Destructor TServerMethodsComp.Destroy;
Begin
 Inherited Destroy;
End;

Procedure TServerMethodsComp.vReplyEvent(SendType   : TSendEvent;
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

Function TServerMethodsComp.ConsultaBanco(Var Params : TDWParams) : String;
Var
 vSQL : String;
 JSONValue : uDWJSONObject.TJSONValue;
 fdQuery : TFDQuery;
Begin
 If Params.ItemsString['SQL'] <> Nil Then
  Begin
   JSONValue          := uDWJSONObject.TJSONValue.Create;
   JSONValue.Encoding := GetEncoding(RestDWForm.RESTServicePooler1.Encoding);
   If Params.ItemsString['SQL'].value <> '' Then
    Begin
     If Params.ItemsString['TESTPARAM'] <> Nil Then
      Params.ItemsString['TESTPARAM'].SetValue('OK, OK');
     vSQL      := Params.ItemsString['SQL'].value;
     {$IFDEF FPC}
     {$ELSE}
      fdQuery   := TFDQuery.Create(Nil);
      Try
       fdQuery.Connection := Nil;//Server_FDConnection; //Alterar no futuro
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




