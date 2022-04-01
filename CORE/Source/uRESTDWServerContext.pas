unit uRESTDWServerContext;

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Ivan Cesar                 - Admin - Administrador do CORE do pacote.
 Joanan Mendonça Jr. (jlmj) - Admin - Administrador do CORE do pacote.
 Giovani da Cruz            - Admin - Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Alexandre Souza            - Admin - Administrador do Grupo de Organização.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Mizael Rocha               - Member Tester and DEMO Developer.
 Flávio Motta               - Member Tester and DEMO Developer.
 Itamar Gaucho              - Member Tester and DEMO Developer.
 Ico Menezes                - Member Tester and DEMO Developer.
}


interface

Uses
 SysUtils, Classes, uDWJSONObject, uDWConsts, uDWConstsData, uDWAbout,
 uDWConstsCharset,
 uRESTDWBase, uDWJSONTools{$IFNDEF FPC}
                           {$IF CompilerVersion > 21} // Delphi 2010 pra cima
                            {$IF Defined(HAS_FMX)} // Alteardo para IOS Brito
                              , System.json
                            {$ELSE}
                             , uDWJSON
                            {$IFEND}
                           {$ELSE}
                            , uDWJSON
                           {$IFEND}
                           {$ELSE}
                           , uDWJSON
                           {$ENDIF};

Const
 TServerEventsConst = '{"typeobject":"%s", "objectdirection":"%s", "objectvalue":"%s", "paramname":"%s", "encoded":"%s", "default":"%s"}';
 DefaultTag         = '<input %s placeholder="%s">';

Type
 TDWReplyRequest       = Procedure(Const Params         : TDWParams;
                                   Var   ContentType,
                                         Result         : String;
                                   Const RequestType    : TRequestType)    Of Object;
 TDWAuthRequest        = Procedure(Const Params         : TDWParams;
                                   Var   Rejected       : Boolean;
                                   Var   ResultError    : String;
                                   Var   StatusCode     : Integer;
                                   RequestHeader        : TStringList)     Of Object;
 TDWMarkRequest        = Procedure(Const Params         : TDWParams;
                                   Var   ContentType,
                                         Result         : String)          Of Object;
 TDWGetContextItemTag  = Procedure(Var   ContextItemTag : String)          Of Object;
 TDWBeforeRenderer     = Procedure(Const BaseHeader     : String;
                                   Var   ContentType,
                                   ContentRenderer      : String;
                                   Const RequestType    : TRequestType)    Of Object;
 TObjectEvent          = Procedure(aSelf                : TComponent)      Of Object;
 TObjectExecute        = Procedure(Const aSelf          : TCollectionItem) Of Object;


 TDWReplyRequestStream = Procedure(Const Params       : TDWParams;
                                   Var   ContentType  : String;
                                   Const Result       : TMemoryStream;
                                   Const RequestType  : TRequestType;
                                   Var   StatusCode     : Integer) Of Object;

Type
 TDWReplyRequestData = Class(TComponent)
 Private
  vReplyRequest : TDWReplyRequest;
  vReplyRequestStream : TDWReplyRequestStream;
 Public
  Property  OnReplyRequest       : TDWReplyRequest       Read vReplyRequest       Write vReplyRequest;
  Property  OnReplyRequestStream : TDWReplyRequestStream Read vReplyRequestStream Write vReplyRequestStream;
End;

Type
 TDWParamMethod = Class;
 PDWParamMethod = ^TDWParamMethod;
 TDWParamMethod = Class(TCollectionItem)
 Private
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  vAlias,
  vDefaultValue,
  vParamName       : String;
  vEncoded         : Boolean;
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Constructor Create        (aCollection : TCollection); Override;
 Published
  Property TypeObject      : TTypeObject      Read vTypeObject      Write vTypeObject;
  Property ObjectDirection : TObjectDirection Read vObjectDirection Write vObjectDirection;
  Property ObjectValue     : TObjectValue     Read vObjectValue     Write vObjectValue;
  Property Alias           : String           Read vAlias           Write vAlias;
  Property ParamName       : String           Read GetDisplayName   Write SetDisplayName;
  Property Encoded         : Boolean          Read vEncoded         Write vEncoded;
  Property DefaultValue    : String           Read vDefaultValue    Write vDefaultValue;
End;

Type
 TDWParamsMethods = Class;
 TDWParamsMethods = Class(TOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TDWParamMethod;  Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWParamMethod);            Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWParamMethod;  Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWParamMethod);            Overload;
 Public
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete     (Index      : Integer);                   Overload;
  Property    Items      [Index      : Integer]   : TDWParamMethod Read GetRec     Write PutRec; Default;
  Property    ParamByName[Index      : String ]   : TDWParamMethod Read GetRecName Write PutRecName;
End;

Type
 TDWContextRule = Class;
 PDWContextRule = ^TDWContextRule;
 TDWContextRule = Class(TCollectionItem)
 Protected
 Private
  vDWMarkRequest       : TDWMarkRequest;
  vDWGetContextItemTag : TDWGetContextItemTag;
  FName,
  vCSS,
  vType,
  vClass,
  vTagID,
  vTagReplace,
  vContextTag          : String;
  vContextScript       : TStrings;
  vOwnerCollection     : TCollection;
  Procedure SetContextScript(Value : TStrings);
 Public
  Function    GetDisplayName                  : String;             Override;
  Procedure   SetDisplayName    (Const Value  : String);            Override;
  Function    GetNamePath      : String;                            Override;
  Procedure   Assign            (Source       : TPersistent);       Override;
  Constructor Create            (aCollection  : TCollection);       Override;
  Destructor  Destroy;           Override;
  Function    BuildClass       : String;
 Published
  Property    ContextTag                  : String               Read vContextTag          Write vContextTag;
  Property    TypeItem                    : String               Read vType                Write vType;
  Property    ClassItem                   : String               Read vClass               Write vClass;
  Property    TagID                       : String               Read vTagID               Write vTagID;
  Property    TagReplace                  : String               Read vTagReplace          Write vTagReplace;
  Property    css                         : String               Read vCss                 Write vCss;
  Property    ContextScript               : TStrings             Read vContextScript       Write SetContextScript;
  Property    ObjectName                  : String               Read FName                Write FName;
  Property    OnRequestExecute            : TDWMarkRequest       Read vDWMarkRequest       Write vDWMarkRequest;
  Property    OnBeforeRendererContextItem : TDWGetContextItemTag Read vDWGetContextItemTag Write vDWGetContextItemTag;
End;

Type
 TDWContextRuleList = Class;
 TDWContextRuleList = Class(TDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec     (Index       : Integer) : TDWContextRule;       Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TDWContextRule);                 Overload;
  Procedure   ClearList;
  Function    GetRecName (Index       : String)  : TDWContextRule;       Overload;
  Procedure   PutRecName (Index       : String;
                          Item        : TDWContextRule);                 Overload;
  Function    GetMarkName(Index       : String)  : TDWContextRule;       Overload;
  Procedure   PutMarkName(Index       : String;
                          Item        : TDWContextRule);                 Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete       (Index      : Integer);                  Overload;
  Property    Items        [Index      : Integer]  : TDWContextRule     Read GetRec      Write PutRec; Default;
  Property    ContextByName[Index      : String ]  : TDWContextRule     Read GetRecName  Write PutRecName;
  Property    MarkByName   [Index      : String ]  : TDWContextRule     Read GetMarkName Write PutMarkName;
End;

Type
 TDWContextRules = Class(TDWComponent)
 Protected
 Private
  vMasterHtml,
  vIncludeScripts,
  vInvalidChars : TStrings;
  vDWContextRuleList : TDWContextRuleList;
  vIncludeScriptsHtmlTag,
  vMasterHTMLTag,
  vContentType       : String;
  vOnBeforeRenderer  : TObjectEvent;
  Procedure SetIncludeScripts  (Value : TStrings);
  Procedure SetInvalidChars    (Value : TStrings);
  Procedure SetMasterHtml      (Value : TStrings);
  Procedure SetOnBeforeRenderer(Value : TObjectEvent);
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner      : TComponent);Override; //Cria o Componente
  Function    BuildContext(BaseHTML         : TStrings;
                           IgnoreBaseHeader : Boolean) : String;
 Published
  Property    ContentType        : String             Read vContentType           Write vContentType;
  Property    MasterHtml         : TStrings           Read vMasterHtml            Write SetMasterHtml;
  Property    MasterHtmlTag      : String             Read vMasterHTMLTag         Write vMasterHTMLTag;
  Property IncludeScripts        : TStrings           Read vIncludeScripts        Write SetIncludeScripts;
  Property IncludeScriptsHtmlTag : String             Read vIncludeScriptsHtmlTag Write vIncludeScriptsHtmlTag;
  Property DeleteInvalidChars    : TStrings           Read vInvalidChars          Write SetInvalidChars;
  Property Items                 : TDWContextRuleList Read vDWContextRuleList     Write vDWContextRuleList;
  Property    OnBeforeRenderer   : TObjectEvent       Read vOnBeforeRenderer      Write SetOnBeforeRenderer;
End;

Type
 TDWContext = Class;
 PDWContext = ^TDWContext;
 TDWContext = Class(TCollectionItem)
 Protected
 Private
  vDescription,
  vDefaultHtml                           : TStrings;
  vContextName,
  FName,
  vContentType                           : String;
  vDWParams                              : TDWParamsMethods;
  vDWContextRules                        : TDWContextRules;
  vOwnerCollection                       : TCollection;
  DWReplyRequestData                     : TDWReplyRequestData;
  vDWRoutes                              : TDWRoutes;
  vDWBeforeRenderer                      : TDWBeforeRenderer;
  vOnBeforeCall                          : TObjectExecute;
  vAuthRequest                           : TDWAuthRequest;
  vOnlyPreDefinedParams,
  vNeedAuthorization,
  vignorebaseheader                      : Boolean;
  Function  GetReplyRequest              : TDWReplyRequest;
  Procedure SetReplyRequest   (Value     : TDWReplyRequest);
  Function  GetReplyRequestStream        : TDWReplyRequestStream;
  Procedure SetReplyRequestStream(Value  : TDWReplyRequestStream);
  Procedure SetDefaultPage    (Strings   : TStrings);
  Procedure SetDescription    (Strings   : TStrings);
  Function  GetBeforeRenderer            : TDWBeforeRenderer;
  Procedure SetBeforeRenderer (Value     : TDWBeforeRenderer);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Function    GetNamePath                : String;       Override;
  Procedure   Assign        (Source      : TPersistent); Override;
  Procedure   CompareParams (Var Dest    : TDWParams);
  Constructor Create        (aCollection : TCollection); Override;
  Destructor  Destroy; Override;
 Published
  Property    DWParams                   : TDWParamsMethods       Read vDWParams              Write vDWParams;
  Property    ContentType                : String                 Read vContentType           Write vContentType;
  Property    Name                       : String                 Read GetDisplayName         Write SetDisplayName;
  Property    ContextName                : String                 Read vContextName           Write vContextName;
  Property    DefaultHtml                : TStrings               Read vDefaultHtml           Write SetDefaultPage;
  Property    Description                : TStrings               Read vDescription           Write SetDescription;
  Property    Routes                     : TDWRoutes              Read vDWRoutes              Write vDWRoutes;
  Property    ContextRules               : TDWContextRules        Read vDWContextRules        Write vDWContextRules;
  Property    OnlyPreDefinedParams       : Boolean                Read vOnlyPreDefinedParams  Write vOnlyPreDefinedParams;
  Property    IgnoreBaseHeader           : Boolean                Read vignorebaseheader      Write vignorebaseheader;
  Property    NeedAuthorization          : Boolean                Read vNeedAuthorization     Write vNeedAuthorization;
  Property    OnAuthRequest              : TDWAuthRequest         Read vAuthRequest           Write vAuthRequest;
  Property    OnReplyRequest             : TDWReplyRequest        Read GetReplyRequest        Write SetReplyRequest;
  Property    OnReplyRequestStream       : TDWReplyRequestStream  Read GetReplyRequestStream  Write SetReplyRequestStream;
  Property    OnBeforeRenderer           : TDWBeforeRenderer      Read GetBeforeRenderer      Write SetBeforeRenderer;
  Property    OnBeforeCall               : TObjectExecute         Read vOnBeforeCall          Write vOnBeforeCall;
End;

Type
 TDWContextList = Class;
 TDWContextList = Class(TDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TDWContext;     Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWContext);               Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWContext;     Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWContext);               Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add                    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    ToJSON : String;
  Procedure   FromJSON     (Value    : String );
  Procedure   Delete       (Index    : Integer);                  Overload;
  Property    Items        [Index    : Integer]  : TDWContext     Read GetRec     Write PutRec; Default;
  Property    ContextByName[Index    : String ]  : TDWContext     Read GetRecName Write PutRecName;
End;

Type
 TDWServerContext = Class(TDWComponent)
 Protected
 Private
  vBaseHeader          : TStrings;
  vIgnoreInvalidParams : Boolean;
  vEventList           : TDWContextList;
  vAccessTag,
  vServerContext,
  vRootContext         : String;
  vOnBeforeRenderer    : TObjectEvent;
  Procedure SetBaseHeader(Value : TStrings);
//  Procedure AfterConstruction; override;
  Procedure SetOnBeforeRenderer(Value : TObjectEvent);
 Public
  Procedure   CreateDWParams(ContextName  : String;
                             Var DWParams : TDWParams);
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
 Published
  Property    IgnoreInvalidParams : Boolean        Read vIgnoreInvalidParams Write vIgnoreInvalidParams;
  Property    ContextList         : TDWContextList Read vEventList           Write vEventList;
  Property    AccessTag           : String         Read vAccessTag           Write vAccessTag;
  Property    BaseContext         : String         Read vServerContext       Write vServerContext;
  Property    BaseHeader          : TStrings       Read vBaseHeader          Write SetBaseHeader;
  Property    RootContext         : String         Read vRootContext         Write vRootContext;
  Property    OnBeforeRenderer    : TObjectEvent   Read vOnBeforeRenderer    Write SetOnBeforeRenderer;
End;

implementation

{ TDWContext }

Function TDWContext.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TDWContext.Create(aCollection: TCollection);
begin
 Inherited;
 vDWParams               := TDWParamsMethods.Create(aCollection, TDWParamMethod);
 vContentType            := 'text/html';
 DWReplyRequestData      := TDWReplyRequestData.Create(Nil);
 vOwnerCollection        := aCollection;
 FName                   := 'dwcontext' + IntToStr(aCollection.Count);
 vContextName            := '';
 DWReplyRequestData.Name := FName;
 vNeedAuthorization      := True;
 vDWRoutes               := [crAll];
 vDefaultHtml            := TStringList.Create;
 vDescription            := TStringList.Create;
 vDWContextRules         := Nil;
 vIgnorebaseheader       := False;
 vOnlyPreDefinedParams   := False;
end;

destructor TDWContext.Destroy;
begin
  vDWParams.Free;
  DWReplyRequestData.Free;
  vDefaultHtml.Free;
  vDescription.Free;
  inherited;
end;

Function TDWContext.GetBeforeRenderer: TDWBeforeRenderer;
Begin
 Result := vDWBeforeRenderer;
End;

Function TDWContext.GetDisplayName: String;
Begin
 Result := DWReplyRequestData.Name;
End;

Procedure TDWContext.CompareParams(Var Dest : TDWParams);
Var
 I : Integer;
Begin
 If vOnlyPreDefinedParams Then
  Begin
   If Not Assigned(Dest) Then
    Exit;
   If vDWParams.Count = 0 Then
    Dest.Clear;
   For I := Dest.Count -1 DownTo 0 Do
    Begin
     If (vDWParams.ParamByName[Dest.Items[I].Alias] = Nil)     And
        (vDWParams.ParamByName[Dest.Items[I].ParamName] = Nil) Then
      Dest.Delete(I);
    End;
  End;
End;

Procedure TDWContext.Assign(Source: TPersistent);
begin
 If Source is TDWContext then
  Begin
   FName       := TDWContext(Source).ContextName;
   vDWParams   := TDWContext(Source).DWParams;
   DWReplyRequestData.OnReplyRequest := TDWContext(Source).OnReplyRequest;
  End
 Else
  Inherited;
End;

Function TDWContext.GetReplyRequestStream: TDWReplyRequestStream;
Begin
 Result := DWReplyRequestData.OnReplyRequestStream;
End;

Function TDWContext.GetReplyRequest: TDWReplyRequest;
Begin
 Result := DWReplyRequestData.OnReplyRequest;
End;

Procedure TDWContext.SetBeforeRenderer(Value: TDWBeforeRenderer);
Begin
 vDWBeforeRenderer := Value;
End;

Procedure TDWContext.SetDescription(Strings   : TStrings);
begin
 vDescription.Assign(Strings);
end;

procedure TDWContext.SetDefaultPage(Strings: TStrings);
begin
 vDefaultHtml.Assign(Strings);
end;

Procedure TDWContext.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidContextName)
 Else
  Begin
   FName := Value;
   DWReplyRequestData.Name := FName;
   If vContextName = '' Then
    vContextName  := DWReplyRequestData.Name;
   Inherited;
  End;
End;

Procedure TDWContext.SetReplyRequestStream(Value : TDWReplyRequestStream);
begin
 DWReplyRequestData.OnReplyRequestStream := Value;
end;

procedure TDWContext.SetReplyRequest(Value: TDWReplyRequest);
begin
 DWReplyRequestData.OnReplyRequest := Value;
end;

Function TDWContextList.Add : TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TDWContext(Inherited Add);
End;

procedure TDWContextList.ClearList;
Var
 I : Integer;
 vOldEditable : Boolean;
Begin
 vOldEditable := vEditable;
 vEditable    := True;
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
  vEditable := vOldEditable;
 End;
End;

Constructor TDWContextList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWContext);
 Self.fOwner := AOwner;
 vEditable   := True;
End;

procedure TDWContextList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWContextList.Destroy;
begin
 ClearList;
 inherited;
end;

{
procedure TDWContextList.Editable(Value: Boolean);
begin
 vEditable := Value;
end;
}

{$IFDEF Defined(HAS_FMX)}
Procedure TDWContextList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : system.json.TJsonObject;

 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : system.json.TJsonArray;

 I, X, Y      : Integer;
 vDWEvent     : TDWContext;
 vDWParamMethod : TDWParamMethod;
Begin
 Try
  bJsonArray  := TJSONObject.ParseJSONValue(Value) as TJSONArray;
  For I := 0 to bJsonArray.count -1 Do
   Begin
    bJsonOBJ := bJsonArray.get(I) as TJsonobject;
    Try
     bJsonArrayB := bJsonOBJ.getvalue('serverevents') as Tjsonarray;
     For X := 0 To bJsonArrayB.count -1 Do
      Begin
       bJsonOBJb := bJsonArrayB.get(X) as TJsonObject;
       If ContextByName[bJsonOBJb.getvalue('contextname').value] = Nil Then
        vDWEvent  := TDWContext(Self.Add)
       Else
        vDWEvent  := ContextByName[bJsonOBJb.getvalue('contextname').value];
       vDWEvent.Name := bJsonOBJb.getvalue('contextname').value;
       If bJsonOBJb.getvalue('params').ToString <> '' Then
        Begin
         bJsonArrayC    := bJsonOBJb.getvalue('params') as Tjsonarray;
         Try
          For Y := 0 To bJsonArrayC.count -1 do
           Begin
            bJsonOBJc                      := bJsonArrayC.get(Y) as TJsonobject;
            If vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value] = Nil Then
             vDWParamMethod                := TDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.getvalue('typeobject').value);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.getvalue('objectdirection').value);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.getvalue('objectvalue').value);
            vDWParamMethod.ParamName       := bJsonOBJc.getvalue('paramname').value;
            vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.getvalue('encoded').value);
            If Trim(bJsonOBJc.getvalue('default').value) <> '' Then
             vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.getvalue('default').value{$IFDEF FPC}, csUndefined{$ENDIF});
           End;
         Finally
          bJsonArrayC.Free;
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
      End;
    Finally
     bJsonArrayB.Free;
    End;
   End;
 Finally
  bJsonArray.Free;
 End;
End;
{$ELSE}
Procedure TDWContextList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : {$IFDEF Defined(HAS_FMX)}system.json.TJsonObject;
                {$ELSE}       udwjson.TJsonObject;{$ENDIF}
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : {$IFDEF Defined(HAS_FMX)}system.json.TJsonArray;
                {$ELSE}       udwjson.TJsonArray;{$ENDIF}
 I, X, Y      : Integer;
 vDWEvent     : TDWContext;
 vDWParamMethod : TDWParamMethod;
Begin
 bJsonArrayB := Nil;
 bJsonArray  := Nil;
 Try
  bJsonArray  := Tjsonarray.Create(Value);
  For I := 0 to bJsonArray.length -1 Do
   Begin
    bJsonOBJ := bJsonArray.getJSONObject(I);
    Try
     bJsonArrayB := Tjsonarray.Create(bJsonOBJ.get('serverevents').tostring);
     For X := 0 To bJsonArrayB.length -1 Do
      Begin
       bJsonOBJb := bJsonArrayB.getJSONObject(X);
       If ContextByName[bJsonOBJb.get('contextname').tostring] = Nil Then
        vDWEvent  := TDWContext(Self.Add)
       Else
        vDWEvent  := ContextByName[bJsonOBJb.get('contextname').tostring];
       vDWEvent.ContextName := bJsonOBJb.get('contextname').tostring;
       If bJsonOBJb.get('params').toString <> '' Then
        Begin
         bJsonArrayC    := Tjsonarray.Create(bJsonOBJb.get('params').toString);
         Try
          For Y := 0 To bJsonArrayC.length -1 do
           Begin
            bJsonOBJc                      := bJsonArrayC.getJSONObject(Y);
            If vDWEvent.vDWParams.ParamByName[bJsonOBJc.get('paramname').toString] = Nil Then
             vDWParamMethod                := TDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[bJsonOBJc.get('paramname').toString];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.get('typeobject').toString);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.get('objectdirection').toString);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.get('objectvalue').toString);
            vDWParamMethod.ParamName       := bJsonOBJc.get('paramname').toString;
            vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.get('encoded').toString);
            If Trim(bJsonOBJc.get('default').toString) <> '' Then
             vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.get('default').toString{$IFDEF FPC}, csUndefined{$ENDIF});
           End;
         Finally
          bJsonArrayC.Free;
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
      End;
    Finally
     If Assigned(bJsonArrayB) Then
      bJsonArrayB.Free;
    End;
   End;
 Finally
  If Assigned(bJsonArray) Then
   bJsonArray.Free;
 End;
End;
{$ENDIF}

Function TDWContextList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWContextList.GetRec(Index: Integer): TDWContext;
begin
 Result := TDWContext(Inherited GetItem(Index));
end;

function TDWContextList.GetRecName(Index: String): TDWContext;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
    Begin
     Result := TDWContext(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TDWContextList.PutRec(Index: Integer; Item: TDWContext);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TDWContextList.PutRecName(Index: String; Item: TDWContext);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Function TDWContextList.ToJSON: String;
Var
 A, I : Integer;
 vTagEvent,
 vParamsLines,
 vParamLine,
 vEventsLines : String;
Begin
 Result := '';
 vEventsLines := '';
 For I := 0 To Count -1 Do
  Begin
   vTagEvent    := Format('{"contextname":"%s"', [Items[I].FName]);
   vTagEvent    := vTagEvent + ', "params":[%s]}';
   vParamsLines := '';
   For A := 0 To Items[I].vDWParams.Count -1 Do
    Begin
     vParamLine := Format(TServerEventsConst,
                          [GetObjectName(Items[I].vDWParams[A].vTypeObject),
                           GetDirectionName(Items[I].vDWParams[A].vObjectDirection),
                           GetValueType(Items[I].vDWParams[A].vObjectValue),
                           Items[I].vDWParams[A].vParamName,
                           BooleanToString(Items[I].vDWParams[A].vEncoded),
                           EncodeStrings(Items[I].vDWParams[A].vDefaultValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
     If vParamsLines = '' Then
      vParamsLines := vParamLine
     Else
      vParamsLines := vParamsLines + ', ' + vParamLine;
    End;
   If vEventsLines = '' Then
    vEventsLines := vEventsLines + Format(vTagEvent, [vParamsLines])
   Else
    vEventsLines := vEventsLines + Format(', ' + vTagEvent, [vParamsLines]);
  End;
 Result := Format('{"serverevents":[%s]}', [vEventsLines]);
End;

{
Procedure TDWServerContext.AfterConstruction;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;
}

Constructor TDWServerContext.Create(AOwner : TComponent);
Begin
 Inherited;
 vOnBeforeRenderer  := Nil;
 vEventList := TDWContextList.Create(Self, TDWContext);
 vIgnoreInvalidParams := False;
 vBaseHeader := TStringList.Create;
End;

Destructor TDWServerContext.Destroy;
Begin
 vEventList.Free;
 vBaseHeader.Free;
 Inherited;
End;

Procedure TDWServerContext.SetBaseHeader(Value: TStrings);
Begin
 vBaseHeader.Assign(Value);
End;


Procedure TDWServerContext.CreateDWParams(ContextName  : String;
                                          Var DWParams : TDWParams);
Var
 vParamName : String;
 dwParam : TJSONParam;
 I       : Integer;
 vFound  : Boolean;
Begin
 vParamName := '';
 If (vEventList.ContextByName[ContextName] <> Nil) Then
  Begin
   If Not Assigned(DWParams) Then
    DWParams := TDWParams.Create;
   DWParams.JsonMode := jmPureJSON;
   For I := 0 To vEventList.ContextByName[ContextName].vDWParams.Count -1 Do
    Begin
     vParamName := '';
     vFound  := (DWParams.ItemsString[vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName] <> Nil);
     If vFound Then
      vParamName := vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName
     Else
      Begin
       vFound  := (DWParams.ItemsString[vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias]   <> Nil);
       If vFound Then
        vParamName := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
      End;
     If Not(vFound) Then
      Begin
       dwParam                 := TJSONParam.Create(DWParams.Encoding);
       dwParam.ParamName       := vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName;
       dwParam.Alias           := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
       dwParam.ObjectDirection := vEventList.ContextByName[ContextName].vDWParams.Items[I].ObjectDirection;
       dwParam.ObjectValue     := vEventList.ContextByName[ContextName].vDWParams.Items[I].ObjectValue;
       dwParam.Encoded         := vEventList.ContextByName[ContextName].vDWParams.Items[I].Encoded;
       dwParam.JsonMode        := DWParams.JsonMode;
       If (vEventList.ContextByName[ContextName].vDWParams.Items[I].DefaultValue <> '')  And
          (Trim(dwParam.AsString) = '') Then
        dwParam.Value           := vEventList.ContextByName[ContextName].vDWParams.Items[I].DefaultValue;
       DWParams.Add(dwParam);
      End
     Else
      Begin
       If (DWParams.ItemsString[vParamName].ParamName             =  '') Or
          ((DWParams.ItemsString[vParamName].ParamName            <> '') And
           (Lowercase(DWParams.ItemsString[vParamName].ParamName) <>
            Lowercase(vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName))) Then
        Begin
         DWParams.ItemsString[vParamName].Alias      := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
         DWParams.ItemsString[vParamName].ParamName  := vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName;
        End;
       If DWParams.ItemsString[vParamName].Alias      = '' Then
        DWParams.ItemsString[vParamName].Alias       := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
      End;
    End;
  End
 Else
  DWParams := Nil;
End;

Procedure TDWServerContext.SetOnBeforeRenderer(Value: TObjectEvent);
Begin
 vOnBeforeRenderer := Value;
End;

procedure TDWParamsMethods.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

constructor TDWParamsMethods.Create(AOwner     : TPersistent;
                                    aItemClass : TCollectionItemClass);
begin
 Inherited Create(AOwner, TDWParamMethod);
 Self.fOwner := AOwner;
end;

procedure TDWParamsMethods.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWParamsMethods.Destroy;
begin
 ClearList;
 Inherited;
end;

Function TDWParamsMethods.GetRec(Index: Integer): TDWParamMethod;
Begin
 Result := TDWParamMethod(inherited GetItem(Index));
End;

function TDWParamsMethods.GetRecName(Index: String): TDWParamMethod;
Var
 I : Integer;
Begin
 Result := Nil;
 If Lowercase(Index) <> '' Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Lowercase(Index) = Lowercase(Self.Items[I].vParamName)) Or
        (Lowercase(Index) = Lowercase(Self.Items[I].vAlias))     Then
      Begin
       Result := TDWParamMethod(Self.Items[I]);
       Break;
      End;
    End;
  End;
End;

procedure TDWParamsMethods.PutRec(Index: Integer; Item: TDWParamMethod);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

procedure TDWParamsMethods.PutRecName(Index: String; Item: TDWParamMethod);
Var
 I : Integer;
Begin
 If Lowercase(Index) <> '' Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Or
        (Lowercase(Index) = Lowercase(Self.Items[I].vAlias))     Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Constructor TDWParamMethod.Create(aCollection: TCollection);
Begin
 Inherited;
 vTypeObject      := toParam;
 vObjectDirection := odINOUT;
 vObjectValue     := ovString;
 vParamName       :=  'dwparam' + IntToStr(aCollection.Count);
 vEncoded         := True;
 vDefaultValue    := '';
 vAlias           := '';
End;

function TDWParamMethod.GetDisplayName: String;
begin
 Result := vParamName;
end;

procedure TDWParamMethod.SetDisplayName(const Value: String);
begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidParamName)
 Else
  Begin
   vParamName := Trim(Value);
   Inherited;
  End;
end;

{ TDWContextRules }

constructor TDWContextRules.Create(AOwner: TComponent);
begin
 Inherited;
 vOnBeforeRenderer      := Nil;
 vIncludeScripts        := TStringList.Create;
 vInvalidChars          := TStringList.Create;
 vMasterHtml            := TStringList.Create;
 vDWContextRuleList     := TDWContextRuleList.Create(Self, TDWContextRule);
 vContentType           := 'text/html';
 vMasterHTMLTag         := '$body';
 vIncludeScriptsHtmlTag := '{%incscripts%}';
end;

destructor TDWContextRules.Destroy;
begin
 vIncludeScripts.Free;
 vInvalidChars.Free;
 vMasterHtml.Free;
 vDWContextRuleList.Free;
 Inherited;
end;

procedure TDWContextRules.SetIncludeScripts(Value: TStrings);
begin
 vIncludeScripts.Assign(Value);
end;

procedure TDWContextRules.SetInvalidChars(Value: TStrings);
begin
 vInvalidChars.Assign(Value);
end;

procedure TDWContextRules.SetMasterHtml(Value: TStrings);
begin
 vMasterHtml.Assign(Value);
end;

Procedure TDWContextRules.SetOnBeforeRenderer(Value: TObjectEvent);
Begin
 vOnBeforeRenderer := Value;
End;

procedure TDWContextRule.Assign(Source: TPersistent);
begin
  inherited;
 If Source is TDWContextRule then
  Begin
   vContextTag    := TDWContextRule(Source).ContextTag;
   vTagID         := TDWContextRule(Source).TagID;
   vContextScript := TDWContextRule(Source).ContextScript;
  End
 Else
  Inherited;
end;

Function TDWContextRule.BuildClass : String;
Begin
 Result := '';
End;

Constructor TDWContextRule.Create(aCollection: TCollection);
Begin
 Inherited;
 vTagID            := lowercase('dwcontextrule') + IntToStr(aCollection.Count);
 vContextTag       := Format(DefaultTag, ['{%itemtag%}', vTagID]);
 vType             := 'text';
 vClass            := 'form-control item';
 vTagReplace       := '{%' + vTagID + '%}';
 FName             := vTagID;
 vOwnerCollection  := aCollection;
 vContextScript    := TStringList.Create;
 vCss              := '';
End;

Destructor TDWContextRule.Destroy;
Begin
 vContextScript.Free;
 Inherited;
End;

Function TDWContextRule.GetDisplayName: String;
Begin
 Result := FName;
End;

function TDWContextRule.GetNamePath: String;
begin
 Result := vOwnerCollection.GetNamePath + FName;
end;

Procedure TDWContextRule.SetContextScript(Value: TStrings);
Begin
 vContextScript.Assign(Value);
End;

procedure TDWContextRule.SetDisplayName(const Value: String);
begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidContextRule)
 Else
  Begin
   FName := Value;
   Inherited;
  End;
end;

{ TDWContextRuleList }

Function TDWContextRuleList.Add: TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TDWContextRule(Inherited Add);
End;

Function TDWContextRules.BuildContext(BaseHTML         : TStrings;
                                      IgnoreBaseHeader : Boolean): String;
Var
 vTempResult,
 vTempComponent,
 vTempClass     : String;
 I              : Integer;
 Procedure ApplyContextTagList(ObjectName : String; Var TagComponent : String);
 Var
  I        : Integer;
  vTempTag : String;
 Begin
  For I := 0 To vDWContextRuleList.Count -1 Do
   Begin
    If Pos(vDWContextRuleList[I].vTagReplace, TagComponent) > InitStrPos Then
     Begin
      vTempTag := vDWContextRuleList[I].vContextTag;
      If Assigned(vDWContextRuleList[I].OnBeforeRendererContextItem) Then
       vDWContextRuleList[I].OnBeforeRendererContextItem(vTempTag);
      TagComponent := StringReplace(TagComponent, vDWContextRuleList[I].vTagReplace, vTempTag, [rfReplaceAll]);
     End;
   End;
 End;
Begin
 If Assigned(vOnBeforeRenderer) Then
  vOnBeforeRenderer(Self);
 vTempResult := '';
 Result      := '';
 If Not IgnoreBaseHeader Then
  Begin
   If Assigned(BaseHTML) Then
    vTempResult := BaseHTML.Text;
   If Pos(vMasterHTMLTag, vTempResult) > 0 Then
    If vMasterHtml.Count > 0 Then
     vTempResult := StringReplace(vTempResult, vMasterHTMLTag, vMasterHtml.Text,  [rfReplaceAll, rfIgnoreCase]);
  End;
 If vTempResult = '' Then
  vTempResult := vMasterHtml.Text;
 If Pos(vIncludeScriptsHtmlTag, vTempResult) > 0 Then
  If vIncludeScripts.Count > 0 Then
   vTempResult := StringReplace(vTempResult, vIncludeScriptsHtmlTag, vIncludeScripts.Text,  [rfReplaceAll, rfIgnoreCase]);
 For I := 0 To vDWContextRuleList.Count -1 Do
  Begin
   If (vDWContextRuleList[I].vContextTag <> DefaultTag) And
      (Pos('{%itemtag%}', lowercase(vDWContextRuleList[I].vContextTag)) > 0) Then
    Begin
     vTempClass := vDWContextRuleList[I].vContextTag;
     vTempComponent := '';
     Try
      If vDWContextRuleList[I].vType <> '' Then
       vTempComponent := vTempComponent + Format(' type="%s"',  [vDWContextRuleList[I].vType]);
      If vDWContextRuleList[I].vClass <> '' Then
       vTempComponent := vTempComponent + Format(' class="%s"', [vDWContextRuleList[I].vClass]);
      If vDWContextRuleList[I].vTagID <> '' Then
       vTempComponent := vTempComponent + Format(' id="%s"',    [vDWContextRuleList[I].vTagID]);
      If vDWContextRuleList[I].vCSS <> '' Then
       vTempComponent := vTempComponent + Format(' css="%s"',   [vDWContextRuleList[I].vCSS]);
     Finally
      vTempComponent := StringReplace(vTempClass, '{%itemtag%}', vTempComponent, [rfReplaceAll, rfIgnoreCase]);
     End;
    End
   Else
    vTempComponent := vDWContextRuleList[I].vContextTag;
   If Assigned(vDWContextRuleList[I].OnBeforeRendererContextItem) Then
    vDWContextRuleList[I].OnBeforeRendererContextItem(vTempComponent);
   ApplyContextTagList(vDWContextRuleList[I].ObjectName, vTempComponent);
   If ((vTempComponent <> '') And (vTempComponent <> DefaultTag)) Or
      ((vTempComponent = '') And (vDWContextRuleList[I].vTagReplace <> '')) Then
    vTempResult := StringReplace(vTempResult, vDWContextRuleList[I].vTagReplace, vTempComponent, [rfReplaceAll, rfIgnoreCase]);
  End;
 Result := vTempResult;
End;

procedure TDWContextRuleList.ClearList;
Var
 I : Integer;
 vOldEditable : Boolean;
Begin
 vOldEditable := vEditable;
 vEditable    := True;
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
  vEditable := vOldEditable;
 End;
End;

constructor TDWContextRuleList.Create(AOwner: TPersistent;
  aItemClass: TCollectionItemClass);
begin
 Inherited Create(AOwner, TDWContextRule);
 Self.fOwner := AOwner;
 vEditable   := True;
end;

procedure TDWContextRuleList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWContextRuleList.Destroy;
begin
 ClearList;
 Inherited;
end;

Function TDWContextRuleList.GetMarkName(Index : String): TDWContextRule;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
    Begin
     Result := TDWContextRule(Self.Items[I]);
     Break;
    End;
  End;
End;

Function TDWContextRuleList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWContextRuleList.GetRec(Index: Integer): TDWContextRule;
begin
 Result := TDWContextRule(Inherited GetItem(Index));
end;

Function TDWContextRuleList.GetRecName(Index: String): TDWContextRule;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vTagID)) Then
    Begin
     Result := TDWContextRule(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TDWContextRuleList.PutMarkName(Index : String;
                                         Item  : TDWContextRule);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

procedure TDWContextRuleList.PutRec(Index: Integer; Item: TDWContextRule);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TDWContextRuleList.PutRecName(Index: String; Item: TDWContextRule);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].vTagID)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Initialization
 RegisterClass(TDWServerContext);
 RegisterClass(TDWContextRules);
end.
