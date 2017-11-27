unit uRESTDWServerEvents;

interface

Uses
 SysUtils, Classes, uDWJSONObject, uDWConsts, uDWConstsData,
 uRESTDWBase, uDWJSONTools, udwjson {$IFNDEF FPC}
                                    {$IF CompilerVersion > 21}
                                    {$IFDEF POSIX}
                                    {$IF Defined(ANDROID) or Defined(IOS)} //Alterado para IOS Brito
                                    ,system.json
                                    {$else}
                                    ,system.json
                                    {$IFEND}
                                    {$ENDIF}
                                    {$IFEND}
                                    {$ENDIF};

Const
 TServerEventsConst = '{"typeobject":"%s", "objectdirection":"%s", "objectvalue":"%s", "paramname":"%s", "encoded":"%s", "default":"%s"}';

Type
 TDWReplyEvent = Procedure(Var Params         : TDWParams;
                           Var Result         : String) Of Object;

Type
 TDWReplyEventData = Class(TComponent)
 Private
  vReplyEvent : TDWReplyEvent;
 Public
  Property    OnReplyEvent : TDWReplyEvent Read vReplyEvent    Write vReplyEvent;
End;

Type
 TDWParamMethod = Class;
 TDWParamMethod = Class(TCollectionItem)
 Private
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
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
 TDWEvent = Class;
 TDWEvent = Class(TCollectionItem)
 Protected
 Private
  FName                         : String;
  vDWParams                     : TDWParamsMethods;
  vOwnerCollection              : TCollection;
  DWReplyEventData              : TDWReplyEventData;
  Function  GetReplyEvent       : TDWReplyEvent;
  Procedure SetReplyEvent(Value : TDWReplyEvent);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Procedure   Assign        (Source      : TPersistent); Override;
  Constructor Create        (aCollection : TCollection); Override;
  Function    GetNamePath  : String;                     Override;
  Destructor  Destroy; Override;
 Published
  Property    DWParams     : TDWParamsMethods Read vDWParams      Write vDWParams;
  Property    Name         : String           Read GetDisplayName Write SetDisplayName;
  Property    OnReplyEvent : TDWReplyEvent    Read GetReplyEvent  Write SetReplyEvent;
End;

Type
 TDWEventList = Class;
 TDWEventList = Class(TOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TDWEvent;       Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWEvent);                 Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWEvent;       Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWEvent);                 Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    ToJSON : String;
  Procedure   FromJSON   (Value      : String );
  Procedure   Delete     (Index      : Integer);                  Overload;
  Property    Items      [Index      : Integer]  : TDWEvent       Read GetRec     Write PutRec; Default;
  Property    EventByName[Index      : String ]  : TDWEvent       Read GetRecName Write PutRecName;
End;

Type
 TDWServerEvents = Class(TComponent)
 Protected
 Private
  vIgnoreInvalidParams : Boolean;
  vEventList      : TDWEventList;
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName    : String;
                             Var DWParams : TDWParams);
 Published
  Property    IgnoreInvalidParams : Boolean      Read vIgnoreInvalidParams Write vIgnoreInvalidParams;
  Property    Events              : TDWEventList Read vEventList           Write vEventList;
End;

Type
 TDWClientEvents = Class(TComponent)
 Protected
 Private
  vEditParamList,
  vGetEvents        : Boolean;
  vEventList        : TDWEventList;
  vRESTClientPooler : TRESTClientPooler;
  Procedure GetOnlineEvents(Value  : Boolean);
  Procedure SetEventList   (aValue : TDWEventList);
//  Procedure SetEditParamList(Value : Boolean);
 Public
  Destructor  Destroy; Override;
  Constructor Create        (AOwner    : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName : String; Var DWParams : TDWParams);
  Function    SendEvent     (EventName : String; Var DWParams : TDWParams;
                             Var Error : String) : Boolean;
 Published
  Property    RESTClientPooler : TRESTClientPooler Read vRESTClientPooler Write vRESTClientPooler;
//  Property    EditParamList    : Boolean           Read vEditParamList    Write SetEditParamList;
  Property    Events           : TDWEventList      Read vEventList        Write SetEventList;
  Property    GetEvents        : Boolean           Read vGetEvents        Write GetOnlineEvents;
End;

implementation

{ TDWEvent }

Function TDWEvent.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TDWEvent.Create(aCollection: TCollection);
begin
  inherited;
  vDWParams        := TDWParamsMethods.Create(aCollection, TDWParamMethod);
  DWReplyEventData := TDWReplyEventData.Create(Nil);
  vOwnerCollection := aCollection;
  FName            := 'dwevent' + IntToStr(aCollection.Count);
  DWReplyEventData.Name := FName;
end;

destructor TDWEvent.Destroy;
begin
  vDWParams.Free;
  DWReplyEventData.Free;
  inherited;
end;

Function TDWEvent.GetDisplayName: String;
Begin
 Result := DWReplyEventData.Name;
End;

Procedure TDWEvent.Assign(Source: TPersistent);
begin
 If Source is TDWEvent then
  Begin
   FName       := TDWEvent(Source).Name;
   vDWParams   := TDWEvent(Source).DWParams;
   DWReplyEventData.OnReplyEvent := TDWEvent(Source).OnReplyEvent;
  End
 Else
  Inherited;
End;

Function TDWEvent.GetReplyEvent: TDWReplyEvent;
Begin
 Result := DWReplyEventData.OnReplyEvent;
End;

Procedure TDWEvent.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid Event Name')
 Else
  Begin
   FName := Value;
   DWReplyEventData.Name := FName;
   Inherited;
  End;
End;

procedure TDWEvent.SetReplyEvent(Value: TDWReplyEvent);
begin
 DWReplyEventData.OnReplyEvent := Value;
end;

Function TDWEventList.Add : TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TDWEvent(Inherited Add);
End;

procedure TDWEventList.ClearList;
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

Constructor TDWEventList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWEvent);
 Self.fOwner := AOwner;
 vEditable   := True;
End;

procedure TDWEventList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWEventList.Destroy;
begin
 ClearList;
 inherited;
end;

{
procedure TDWEventList.Editable(Value: Boolean);
begin
 vEditable := Value;
end;
}

{$IFDEF POSIX}
Procedure TDWEventList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : system.json.TJsonObject;

 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : system.json.TJsonArray;

 I, X, Y      : Integer;
 vDWEvent     : TDWEvent;
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
       If EventByName[bJsonOBJb.getvalue('eventname').value] = Nil Then
        vDWEvent  := TDWEvent(Self.Add)
       Else
        vDWEvent  := EventByName[bJsonOBJb.getvalue('eventname').value];
       vDWEvent.Name := bJsonOBJb.getvalue('eventname').value;
       If bJsonOBJb.getvalue('params').value <> '' Then
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
Procedure TDWEventList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : {$IFDEF POSIX}system.json.TJsonObject;
                {$ELSE}       udwjson.TJsonObject;{$ENDIF}
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : {$IFDEF POSIX}system.json.TJsonArray;
                {$ELSE}       udwjson.TJsonArray;{$ENDIF}
 I, X, Y      : Integer;
 vDWEvent     : TDWEvent;
 vDWParamMethod : TDWParamMethod;
Begin
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
       If EventByName[bJsonOBJb.get('eventname').tostring] = Nil Then
        vDWEvent  := TDWEvent(Self.Add)
       Else
        vDWEvent  := EventByName[bJsonOBJb.get('eventname').tostring];
       vDWEvent.Name := bJsonOBJb.get('eventname').tostring;
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
     bJsonArrayB.Free;
    End;
   End;
 Finally
  bJsonArray.Free;
 End;
End;
{$ENDIF}

Function TDWEventList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWEventList.GetRec(Index: Integer): TDWEvent;
begin
 Result := TDWEvent(Inherited GetItem(Index));
end;

function TDWEventList.GetRecName(Index: String): TDWEvent;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
    Begin
     Result := TDWEvent(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TDWEventList.PutRec(Index: Integer; Item: TDWEvent);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TDWEventList.PutRecName(Index: String; Item: TDWEvent);
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

Function TDWEventList.ToJSON: String;
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
   vTagEvent    := Format('{"eventname":"%s"', [Items[I].FName]);
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

Procedure TDWServerEvents.CreateDWParams(EventName    : String;
                                         Var DWParams : TDWParams);
Var
 dwParam : TJSONParam;
 I       : Integer;
 vFound  : Boolean;
Begin
 FreeAndNil(DWParams);
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
   If Not Assigned(DWParams) Then
    DWParams := TDWParams.Create;
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vFound  := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil;
     If Not(vFound) Then
      dwParam                := TJSONParam.Create{$IFNDEF FPC}(DWParams.Encoding){$ENDIF}
     Else
      dwParam                := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName];
     dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
     dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
     dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
     dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
     If vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '' Then
      dwParam.Value           := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
     If Not(vFound) Then
      DWParams.Add(dwParam);
    End;
  End
 Else
  DWParams := Nil;
End;

Constructor TDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited;
 vEventList := TDWEventList.Create(Self, TDWEvent);
 vIgnoreInvalidParams := False;
End;

Destructor TDWServerEvents.Destroy;
Begin
 vEventList.Free;
 Inherited;
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
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Then
    Begin
     Result := TDWParamMethod(Self.Items[I]);
     Break;
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
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
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
End;

function TDWParamMethod.GetDisplayName: String;
begin
 Result := vParamName;
end;

procedure TDWParamMethod.SetDisplayName(const Value: String);
begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid Param Name')
 Else
  Begin
   vParamName := Trim(Value);
   Inherited;
  End;
end;

{ TDWClientEvents }

constructor TDWClientEvents.Create(AOwner: TComponent);
begin
 Inherited;
 vEventList     := TDWEventList.Create(Self, TDWEvent);
 vGetEvents     := False;
 vEditParamList := True;
end;

Procedure TDWClientEvents.CreateDWParams(EventName    : String;
                                         Var DWParams : TDWParams);
Var
 dwParam : TJSONParam;
 I       : Integer;
 vFound  : Boolean;
Begin
 FreeAndNil(DWParams);
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
   If (Not Assigned(DWParams)) or (dwParams = nil) Then
    DWParams := TDWParams.Create;
   {$IFNDEF FPC}
   DWParams.Encoding := GetEncoding(vRESTClientPooler.Encoding);
   {$ENDIF}
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vFound  := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil;
     If Not(vFound) Then
      dwParam                := TJSONParam.Create{$IFNDEF FPC}(DWParams.Encoding){$ENDIF}
     Else
      dwParam                := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName];
     dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
     dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
     dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
     dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
     If vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '' Then
      dwParam.Value           := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
     If Not(vFound) Then
      DWParams.Add(dwParam);
    End;
  End
 Else
  DWParams := Nil;
End;

destructor TDWClientEvents.Destroy;
begin
 vEventList.Free;
 Inherited;
end;

procedure TDWClientEvents.GetOnlineEvents(Value: Boolean);
Var
 RESTClientPoolerExec : TRESTClientPooler;
 vResult,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TDWParams;
Begin
 If Assigned(vRESTClientPooler) Then
  RESTClientPoolerExec := vRESTClientPooler
 Else
  Exit;
 DWParams                        := TDWParams.Create;
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPoolerExec.SendEvent('GetEvents', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
    Begin
     If Not DWParams.ItemsString['error'].AsBoolean Then
      Begin
       vResult := DWParams.ItemsString['Result'].Value;
       If Trim(vResult) <> '' Then //Carreta o ParamList
        vEventList.FromJSON(Trim(vResult));
      End
     Else
      Raise Exception.Create(DWParams.ItemsString['MessageError'].AsString);
    End
   Else
    Begin
     If (lResponse = '') Then
      lResponse  := Format('Unresolved Host : ''%s''', [RESTClientPoolerExec.Host])
     Else If (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
      lResponse  := Format('Unauthorized Username : ''%s''', [RESTClientPoolerExec.UserName]);
     Raise Exception.Create(lResponse);
     lResponse   := '';
    End;
  Except
   On E : Exception Do
    Begin
     Raise Exception.Create(E.Message);
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

{
procedure TDWClientEvents.SetEditParamList(Value: Boolean);
begin
 vEditParamList := Value;
 vEventList.Editable(vEditParamList);
end;
}

Function TDWClientEvents.SendEvent(EventName    : String;
                                   Var DWParams : TDWParams;
                                   Var Error    : String): Boolean;
Begin
 If vRESTClientPooler <> Nil Then
  vRESTClientPooler.SendEvent(EventName, DWParams);
End;

procedure TDWClientEvents.SetEventList(aValue : TDWEventList);
begin
 If vEditParamList Then
  vEventList := aValue;
end;

Initialization
 RegisterClass(TDWServerEvents);
 RegisterClass(TDWClientEvents);
end.
