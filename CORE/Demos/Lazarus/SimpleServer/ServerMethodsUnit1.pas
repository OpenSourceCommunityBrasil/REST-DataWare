unit ServerMethodsUnit1;

{$MODE Delphi}

interface

uses SysUtils, Classes, Windows, uRESTDWBase, uDWConsts, uDWConstsData, uDWJSONTools, uDWJSONObject,
     IBConnection, sqldb, Dialogs, ServerUtils, SysTypes;
Type
{$METHODINFO ON}
  TServerMethodsComp = Class(TServerMethods)
  Private
   Function ConsultaBanco(Var Params : TDWParams) : String;Overload;
  public
   { Public declarations }
   Constructor Create    (aOwner : TComponent); Override;
   Destructor  Destroy; Override;
   Procedure   vReplyEvent(SendType           : TSendEvent;
                           Context            : String;
                           Var Params         : TDWParams;
                           Var Result         : String;
                           AccessTag          : String);
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
                                         Var Result : String;
                                         AccessTag  : String);
Begin
 Case SendType Of
  sePOST   :
   Begin
    If UpperCase(Context) = Uppercase('ConsultaBanco') Then
     Result := ConsultaBanco(Params)
    Else
     Result := '{(''STATUS'',   ''NOK''), (''MENSAGEM'', ''Método não encontrado'')}';
   End;
 End;
End;

Function TServerMethodsComp.ConsultaBanco(Var Params : TDWParams) : String;
Var
 vSQL : String;
 JSONValue : uDWJSONObject.TJSONValue;
 fdQuery : TSQLQuery;
Begin
 If Params.ItemsString['SQL'] <> Nil Then
  Begin
   JSONValue          := uDWJSONObject.TJSONValue.Create;
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




