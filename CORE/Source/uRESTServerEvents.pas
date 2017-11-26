unit uRESTServerEvents;

interface

Uses
 SysUtils, Classes, uDWJSONObject, uDWConsts, uDWConstsData, uRESTDWBase;

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
 TDWEventList = Class(TOwnedCollection)
 Protected
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
 Public
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
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner    : TComponent);Override; //Cria o Componente
 Published
  Property    RESTClientPooler : TRESTClientPooler Read vRESTClientPooler Write vRESTClientPooler;
  Property    EditParamList    : Boolean           Read vEditParamList    Write vEditParamList;
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

procedure TDWEventList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TDWEventList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWEvent);
 Self.fOwner := AOwner;
End;

procedure TDWEventList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWEventList.Destroy;
begin
 ClearList;
 inherited;
end;

Procedure TDWEventList.FromJSON(Value : String);
Begin

End;

Function TDWEventList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWEventList.GetRec(Index: Integer): TDWEvent;
begin
 Result := TDWEvent(inherited GetItem(Index));
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
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

procedure TDWEventList.PutRecName(Index: String; Item: TDWEvent);
Var
 I : Integer;
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

function TDWEventList.ToJSON: String;
begin

end;

{ TDWServerEvents }

Constructor TDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
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
 Inherited Create(AOwner);
 vEventList     := TDWEventList.Create(Self, TDWEvent);
 vGetEvents     := False;
 vEditParamList := False;
end;

destructor TDWClientEvents.Destroy;
begin
 vEventList.Free;
 Inherited;
end;

procedure TDWClientEvents.GetOnlineEvents(Value: Boolean);
begin
 //
end;

procedure TDWClientEvents.SetEventList(aValue : TDWEventList);
begin
 If vEditParamList Then
  vEventList := aValue;
end;

end.
