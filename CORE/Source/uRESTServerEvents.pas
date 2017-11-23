unit uRESTServerEvents;

interface

Uses
 SysUtils, Classes, uDWJSONObject;

Type
 TDWReplyEvent = Procedure(Var Params         : TDWParams;
                           Var Result         : String) Of Object;

Type
 TDWEvent = Class(TPersistent)
 Private
  vDWParams   : TDWParams;
  vReplyEvent : TDWReplyEvent;
 Public
  Procedure Assign(Source : TPersistent); Override;
 Published
  Property DWParams     : TDWParams     Read vDWParams   Write vDWParams;
  Property OnReplyEvent : TDWReplyEvent Read vReplyEvent Write vReplyEvent;
End;

Type
 TDWEventList = Class(TList)
 Private
  Function    GetRec    (Index     : Integer) : TDWEvent;  Overload;
  Procedure   PutRec    (Index     : Integer;
                         Item      : TDWEvent);            Overload;
  Procedure   ClearList;
 Public
  Destructor  Destroy; Override;
  Procedure   Delete     (Index    : Integer);             Overload;
  Function    Add        (Item     : TDWEvent) : Integer;  Overload;
  Property    Items      [Index    : Integer]  : TDWEvent Read GetRec Write PutRec; Default;
End;

Type
 TDWEvents = Class(TPersistent)
 Private
  vItemsList  : TDWEventList;
 Public
  Procedure  Assign(Source : TPersistent); Override;
  Destructor Destroy; Override;
 Published
//  Property DWParams     : TDWParams     Read vDWParams   Write vDWParams;
End;

Type
 TDWServerEvents = Class(TComponent)
 Protected
 Private
  vEventList      : TDWEvents;
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
 Published
  Property Events : TDWEvents Read vEventList Write vEventList;
End;

implementation

{ TDWEvent }

procedure TDWEvent.Assign(Source: TPersistent);
Begin
 Inherited;
End;

{ TDWEventList }

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

function TDWEventList.GetRec(Index: Integer): TDWEvent;
begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TDWEvent(TList(Self).Items[Index]^);
end;

procedure TDWEventList.PutRec(Index: Integer; Item: TDWEvent);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TDWEvent(TList(Self).Items[Index]^) := Item;
end;

{ TDWServerEvents }

Constructor TDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited;
 vEventList := TDWEvents.Create;
End;

Destructor TDWServerEvents.Destroy;
Begin
 vEventList.Free;
 Inherited;
End;

{ TDWEvents }

Procedure TDWEvents.Assign(Source: TPersistent);
Begin
 Inherited;
End;

Destructor TDWEvents.Destroy;
Begin
 vItemsList.Free;
 Inherited;
End;

end.
