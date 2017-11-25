unit uRESTServerEvents;

interface

Uses
 SysUtils, Classes, uDWJSONObject;

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
 TDWEvent = Class(TCollectionItem)
 Protected
 Private
  FName       : String;
  vDWParams   : TDWParams;
  vOwnerCollection : TCollection;
  DWReplyEventData : TDWReplyEventData;
  Function  GetReplyEvent : TDWReplyEvent;
  Procedure SetReplyEvent(Value : TDWReplyEvent);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Procedure   Assign        (Source      : TPersistent); Override;
  Constructor Create        (Collection  : TCollection); Override;
  Function    GetNamePath  : String;                     Override;
  Destructor  Destroy; Override;
 Published
  Property    DWParams     : TDWParams     Read vDWParams      Write vDWParams;
  Property    Name         : String        Read GetDisplayName Write SetDisplayName;
  Property    OnReplyEvent : TDWReplyEvent Read GetReplyEvent  Write SetReplyEvent;
End;

Type
 TDWEventList = Class(TOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index      : Integer) : TDWEvent;  Overload;
  Procedure   PutRec    (Index      : Integer;
                         Item       : TDWEvent);            Overload;
  Procedure   ClearList;
  Function    GetOwner: TPersistent; override;
 Public
  Constructor Create     (AOwner    : TPersistent;
                          ItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete     (Index     : Integer);             Overload;
  Function    Add        (Item      : TDWEvent) : Integer;  Overload;
  Property    Items      [Index     : Integer]  : TDWEvent Read GetRec Write PutRec; Default;
End;

Type
 TDWServerEvents = Class(TComponent)
 Protected
 Private
  vEventList      : TDWEventList;
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
 Published
  Property Events : TDWEventList Read vEventList Write vEventList;
End;

implementation

{ TDWEvent }

Function TDWEvent.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TDWEvent.Create(Collection: TCollection);
begin
  inherited;
  vDWParams        := TDWParams.Create;
  DWReplyEventData := TDWReplyEventData.Create(Nil);
  vOwnerCollection := Collection;
  FName            := 'event' + IntToStr(Collection.Count);
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

Function TDWEventList.Add(Item: TDWEvent): Integer;
Var
 vItem : ^TDWEvent;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

procedure TDWEventList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TDWEventList.Create(AOwner    : TPersistent;
                                ItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWEvent);
 Self.fOwner := AOwner;
End;

procedure TDWEventList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
     Dispose(PStringStream(TList(Self).Items[Index]));
     {$ELSE}
     Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
end;

destructor TDWEventList.Destroy;
begin
 ClearList;
 inherited;
end;

Function TDWEventList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWEventList.GetRec(Index: Integer): TDWEvent;
begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TDWEvent(TList(Self).Items[Index]^);
end;

procedure TDWEventList.PutRec(Index: Integer; Item: TDWEvent);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

{ TDWServerEvents }

Constructor TDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 vEventList := TDWEventList.Create(Self, TDWEvent);
End;

Destructor TDWServerEvents.Destroy;
Begin
 vEventList.Free;
 Inherited;
End;

{ TDWEvents }

end.
