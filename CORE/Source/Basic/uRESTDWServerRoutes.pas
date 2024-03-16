unit uRESTDWServerRoutes;

{$I ..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilberto Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Maiores informações:
 https://github.com/OpenSourceCommunityBrasil/REST-DataWare
}

{$IFNDEF RESTDWLAZARUS}
 {$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
 {$ENDIF}
{$ENDIF}

interface

Uses
  {$IFDEF RESTDWFMX}
    System.JSON,
  {$ELSE}
    uRESTDWJSON,
  {$ENDIF}
  SysUtils, Classes,
  uRESTDWJSONObject, uRESTDWConsts, uRESTDWParams, uRESTDWBasic,
  uRESTDWBasicTypes, uRESTDWTools, uRESTDWAbout;

Const
 TServerEventsConst = '{"typeobject":"%s", "objectdirection":"%s", "objectvalue":"%s", "paramname":"%s", "encoded":"%s", "default":"%s"}';
 DefaultTag         = '<input %s placeholder="%s">';

Type
 TRESTDWReplyRequest       = Procedure(Const Params         : TRESTDWParams;
                                       Var   ContentType    : String;
                                       Const Result         : TStringList;
                                       Const RequestType    : TRequestType)    Of Object;
 TRESTDWReplyRequestStream = Procedure(Const Params         : TRESTDWParams;
                                       Var   ContentType    : String;
                                       Const Result         : TMemoryStream;
                                       Const RequestType    : TRequestType;
                                       Var   StatusCode     : Integer)         Of Object;
 TRESTDWAuthRequest        = Procedure(Const Params         : TRESTDWParams;
                                       Var   Rejected       : Boolean;
                                       Var   ResultError    : String;
                                       Var   StatusCode     : Integer;
                                       RequestHeader        : TStringList)     Of Object;
 TObjectEvent              = Procedure(aSelf                : TComponent;
                                       Const Params         : TRESTDWParams)   Of Object;
 TObjectExecute            = Procedure(Const aSelf          : TCollectionItem) Of Object;

Type
 TRESTDWReplyRequestData = Class(TComponent)
 Private
  vReplyRequest : TRESTDWReplyRequest;
  vReplyRequestStream : TRESTDWReplyRequestStream;
 Public
  Property  OnReplyRequest       : TRESTDWReplyRequest       Read vReplyRequest       Write vReplyRequest;
  Property  OnReplyRequestStream : TRESTDWReplyRequestStream Read vReplyRequestStream Write vReplyRequestStream;
End;

Type
 TRESTDWRoute = Class;
 PRESTDWRoute = ^TRESTDWRoute;
 TRESTDWRoute = Class(TCollectionItem)
 Protected
 Private
  vRedirectTo,
  vDescription,
  vBaseURL,
  FName,
  vRouteName,
  vContentType                           : String;
  vOwnerCollection                       : TCollection;
  DWReplyRequestData                     : TRESTDWReplyRequestData;
  vDWRoutes                              : TRESTDWRoutes;
  vAuthRequest                           : TRESTDWAuthRequest;
  Function  GetReplyRequest              : TRESTDWReplyRequest;
  Procedure SetReplyRequest   (Value     : TRESTDWReplyRequest);
  Function  GetReplyRequestStream        : TRESTDWReplyRequestStream;
  Procedure SetReplyRequestStream(Value  : TRESTDWReplyRequestStream);
  Procedure SetBaseURL(Value : String);
 Public
  Function    GetDisplayName             : String;  {$IFNDEF FPC}Override;{$ENDIF}
  Procedure   SetDisplayName(Const Value : String); {$IFNDEF FPC}Override;{$ENDIF}
  Function    GetNamePath                : String;  {$IFNDEF FPC}Override;{$ENDIF}
  Procedure   Assign        (Source      : TPersistent); Override;
  Constructor Create        (aCollection : TCollection); Override;
  Destructor  Destroy; Override;
 Published
  Property    ContentType                : String                     Read vContentType           Write vContentType;
  Property    RouteName                  : String                     Read vRouteName             Write vRouteName;
  Property    Name                       : String                     Read GetDisplayName         Write SetDisplayName;
  Property    BaseURL                    : String                     Read vBaseURL               Write SetBaseURL;
  Property    RedirectTo                 : String                     Read vRedirectTo            Write vRedirectTo;
  Property    Routes                     : TRESTDWRoutes              Read vDWRoutes              Write vDWRoutes;
  Property    OnAuthRequest              : TRESTDWAuthRequest         Read vAuthRequest           Write vAuthRequest;
  Property    OnReplyRequest             : TRESTDWReplyRequest        Read GetReplyRequest        Write SetReplyRequest;
  Property    OnReplyRequestStream       : TRESTDWReplyRequestStream  Read GetReplyRequestStream  Write SetReplyRequestStream;
End;

Type
 TRESTDWRouteList = Class(TRESTDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TRESTDWRoute;     Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TRESTDWRoute);               Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TRESTDWRoute;     Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TRESTDWRoute);               Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add                    : TCollectionItem;
  Function    AddRoute   (Const RouteName   : String;
                          BaseURL           : String                    = '/';
                          RedirectTo        : String                    = cBaseRedirect;
                          OnReplyRequest    : TRESTDWReplyRequest       = Nil;
                          ContentType       : String                    = cDefaultContext) : TRESTDWRoute;Overload;
  Function    AddRoute   (Const RouteName   : String;
                          BaseURL           : String                    = '/';
                          RedirectTo        : String                    = cBaseRedirect;
                          OnReplyRequest    : TRESTDWReplyRequestStream = Nil;
                          ContentType       : String                    = cDefaultContext) : TRESTDWRoute;Overload;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    ToJSON : String;
  Procedure   FromJSON     (Value    : String );
  Procedure   Delete       (Index    : Integer);                  Overload;
  Property    Items        [Index    : Integer]  : TRESTDWRoute     Read GetRec     Write PutRec; Default;
  Property    RouteByName  [Index    : String ]  : TRESTDWRoute     Read GetRecName Write PutRecName;
End;

Type
 TRESTDWServerRoutes   = Class(TRESTDWComponent)
 Protected
 Private
  vBaseHeader          : TStrings;
  vIgnoreInvalidParams : Boolean;
  vEventList           : TRESTDWRouteList;
  vAccessTag           : String;
  Procedure SetBaseHeader(Value : TStrings);
//  Procedure AfterConstruction; override;
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
 Published
  Property    IgnoreInvalidParams : Boolean          Read vIgnoreInvalidParams Write vIgnoreInvalidParams;
  Property    Routes              : TRESTDWRouteList Read vEventList           Write vEventList;
  Property    AccessTag           : String           Read vAccessTag           Write vAccessTag;
  Property    BaseHeader          : TStrings         Read vBaseHeader          Write SetBaseHeader;
End;

implementation

{ TRESTDWRoute }

Function TRESTDWRoute.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TRESTDWRoute.Create(aCollection: TCollection);
begin
 Inherited;
 vContentType            := 'text/html';
 DWReplyRequestData      := TRESTDWReplyRequestData.Create(Nil);
 vOwnerCollection        := aCollection;
 FName                   := 'dwcontext' + IntToStr(aCollection.Count);
 vBaseURL                := '/';
 DWReplyRequestData.Name := FName;
 vDWRoutes               := TRESTDWRoutes.Create;
end;

destructor TRESTDWRoute.Destroy;
begin
  vDWRoutes.Free;
  DWReplyRequestData.Free;
  inherited;
end;

Function TRESTDWRoute.GetDisplayName: String;
Begin
 Result := DWReplyRequestData.Name;
End;

Procedure TRESTDWRoute.Assign(Source: TPersistent);
begin
 If Source is TRESTDWRoute then
  Begin
   FName       := TRESTDWRoute(Source).Name;
   DWReplyRequestData.OnReplyRequest := TRESTDWRoute(Source).OnReplyRequest;
  End
 Else
  Inherited;
End;

Function TRESTDWRoute.GetReplyRequestStream: TRESTDWReplyRequestStream;
Begin
 Result := DWReplyRequestData.OnReplyRequestStream;
End;

Function TRESTDWRoute.GetReplyRequest: TRESTDWReplyRequest;
Begin
 Result := DWReplyRequestData.OnReplyRequest;
End;

Procedure TRESTDWRoute.SetBaseURL(Value : String);
Var
 vTempValue : String;
Begin
 vTempValue := Value;
 If Trim(vTempValue) = '' Then
  vBaseURL := '/'
 Else
  Begin
   If Copy(vTempValue, 1, 1) <> '/' Then
    vTempValue := '/' + vTempValue;
   If Copy(vTempValue, Length(vTempValue), 1) <> '/' Then
    vTempValue := vTempValue + '/';
   vBaseURL := vTempValue;
  End;
End;

Procedure TRESTDWRoute.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidContextName)
 Else
  Begin
   FName := Value;
   DWReplyRequestData.Name := FName;
   If vRouteName = '' Then
    vRouteName  := DWReplyRequestData.Name;
   Inherited SetDisplayName(Value);
  End;
End;

Procedure TRESTDWRoute.SetReplyRequestStream(Value : TRESTDWReplyRequestStream);
begin
 DWReplyRequestData.OnReplyRequestStream := Value;
end;

procedure TRESTDWRoute.SetReplyRequest(Value: TRESTDWReplyRequest);
begin
 DWReplyRequestData.OnReplyRequest := Value;
end;

Function TRESTDWRouteList.AddRoute (Const RouteName   : String;
                                    BaseURL           : String                    = '/';
                                    RedirectTo        : String                    = cBaseRedirect;
                                    OnReplyRequest    : TRESTDWReplyRequest       = Nil;
                                    ContentType       : String                    = cDefaultContext) : TRESTDWRoute;
Var
 Context : TRESTDWRoute;
Begin
 Context                := TRESTDWRoute(Add);
 Context.RouteName      := RouteName;
 Context.BaseUrl        := BaseUrl;
 Context.ContentType    := ContentType;
 Context.OnReplyRequest := OnReplyRequest;
 Result                 := Context;
End;

Function TRESTDWRouteList.AddRoute (Const RouteName   : String;
                                    BaseURL           : String                    = '/';
                                    RedirectTo        : String                    = cBaseRedirect;
                                    OnReplyRequest    : TRESTDWReplyRequestStream = Nil;
                                    ContentType       : String                    = cDefaultContext) : TRESTDWRoute;
Var
 Context : TRESTDWRoute;
Begin
 Context                      := TRESTDWRoute(Add);
 Context.RouteName            := RouteName;
 Context.BaseUrl              := BaseUrl;
 Context.ContentType          := ContentType;
 Context.OnReplyRequestStream := OnReplyRequest;
 Result                       := Context;
End;

Function TRESTDWRouteList.Add : TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TRESTDWRoute(Inherited Add);
End;

procedure TRESTDWRouteList.ClearList;
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

Constructor TRESTDWRouteList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWRoute);
 Self.fOwner := AOwner;
 vEditable   := True;
End;

procedure TRESTDWRouteList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TRESTDWRouteList.Destroy;
begin
 ClearList;
 inherited;
end;

{
procedure TRESTDWRouteList.Editable(Value: Boolean);
begin
 vEditable := Value;
end;
}

{$IFDEF RESTDWFMX}
Procedure TRESTDWRouteList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : system.json.TJsonObject;

 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : system.json.TJsonArray;

 I, X, Y      : Integer;
 vDWEvent     : TRESTDWRoute;
 vDWParamMethod : TRESTDWParamMethod;
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
       If RouteByName[bJsonOBJb.getvalue('contextname').value] = Nil Then
        vDWEvent  := TRESTDWRoute(Self.Add)
       Else
        vDWEvent  := RouteByName[bJsonOBJb.getvalue('contextname').value];
       vDWEvent.Name := bJsonOBJb.getvalue('contextname').value;
       If bJsonOBJb.getvalue('params').ToString <> '' Then
        Begin
         bJsonArrayC    := bJsonOBJb.getvalue('params') as Tjsonarray;
         Try
          For Y := 0 To bJsonArrayC.count -1 do
           Begin
            bJsonOBJc                      := bJsonArrayC.get(Y) as TJsonobject;
            //TODO XyberX
{
            If vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value] = Nil Then
             vDWParamMethod                := TRESTDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value];
}
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
        End;
//TODO XyberX
{
       Else
        vDWEvent.vDWParams.ClearList;
}
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

Procedure TRESTDWRouteList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : {$IFDEF RESTDWFMX}system.json.TJsonObject;
                {$ELSE}       uRESTDWJSON.TJsonObject;{$ENDIF}
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : {$IFDEF RESTDWFMX}system.json.TJsonArray;
                {$ELSE}       uRESTDWJSON.TJsonArray;{$ENDIF}
 I, X, Y      : Integer;
 vDWEvent     : TRESTDWRoute;
 vDWParamMethod : TRESTDWParamMethod;
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
       If RouteByName[bJsonOBJb.get('contextname').tostring] = Nil Then
        vDWEvent  := TRESTDWRoute(Self.Add)
       Else
        vDWEvent  := RouteByName[bJsonOBJb.get('contextname').tostring];
       vDWEvent.RouteName := bJsonOBJb.get('contextname').tostring;
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

Function TRESTDWRouteList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TRESTDWRouteList.GetRec(Index: Integer): TRESTDWRoute;
begin
 Result := TRESTDWRoute(Inherited GetItem(Index));
end;

function TRESTDWRouteList.GetRecName(Index: String): TRESTDWRoute;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].RouteName))                          Or
      (Uppercase(Index) = Uppercase(Self.Items[I].BaseURL + Self.Items[I].RouteName))  Then
    Begin
     Result := TRESTDWRoute(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TRESTDWRouteList.PutRec(Index: Integer; Item: TRESTDWRoute);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TRESTDWRouteList.PutRecName(Index: String; Item: TRESTDWRoute);
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

Function TRESTDWRouteList.ToJSON: String;
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
   If vEventsLines = '' Then
    vEventsLines := vEventsLines + Format(vTagEvent, [vParamsLines])
   Else
    vEventsLines := vEventsLines + Format(', ' + vTagEvent, [vParamsLines]);
  End;
 Result := Format('{"serverevents":[%s]}', [vEventsLines]);
End;

Constructor TRESTDWServerRoutes.Create(AOwner : TComponent);
Begin
 Inherited;
 vEventList := TRESTDWRouteList.Create(Self, TRESTDWRoute);
 vIgnoreInvalidParams := False;
 vBaseHeader := TStringList.Create;
End;

Destructor TRESTDWServerRoutes.Destroy;
Begin
 vEventList.Free;
 vBaseHeader.Free;
 Inherited;
End;

Procedure TRESTDWServerRoutes.SetBaseHeader(Value: TStrings);
Begin
 vBaseHeader.Assign(Value);
End;

Initialization
 RegisterClass(TRESTDWServerRoutes);
end.
