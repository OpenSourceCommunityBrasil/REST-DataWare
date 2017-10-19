unit uRESTDWMasterDetailData;

Interface

Uses SysUtils, Classes;

Type
 TRESTClient = Class End;

Type
 TMasterDetailItem = Class
 Private
  vDataSet : TRESTClient;
  vFields  : TStringList;
 Protected
 Public
  Constructor Create;
  Destructor  Free;
  Procedure   ParseFields(Value : String);
  Property    DataSet : TRESTClient    Read vDataSet Write vDataSet;
  Property    Fields  : TStringList    Read vFields  Write vFields;
End;

Type
 PMasterDetailItem = ^TMasterDetailItem;
 TMasterDetailList = Class(TList)
 Private
  Function  GetRec(Index    : Integer)      : TMasterDetailItem;  Overload;
  Procedure PutRec(Index    : Integer; Item : TMasterDetailItem); Overload;
 Protected
 Public
  Function  GetItem(Value: TRESTClient)       : TMasterDetailItem;
  Procedure Delete(Index : Integer);                              Overload;
  Procedure DeleteDS(Value : TRESTClient);
  Function  Add   (Item  : TMasterDetailItem) : Integer;          Overload;
  Property  Items[Index  : Integer]           : TMasterDetailItem   Read GetRec Write PutRec; Default;
End;

Implementation

Uses uRESTDWPoolerDB;

{ TMasterDetailList }

Function TMasterDetailList.Add(Item: TMasterDetailItem): Integer;
Var
 vItem : ^TMasterDetailItem;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMasterDetailList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMasterDetailItem(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Function TMasterDetailList.GetItem(Value : TRESTClient) : TMasterDetailItem;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   If (TMasterDetailItem(TList(Self).Items[I]^)          <> Nil)   And
      (TMasterDetailItem(TList(Self).Items[I]^).vDataSet =  Value) Then
    Begin
     Result := TMasterDetailItem(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Procedure TMasterDetailList.DeleteDS(Value : TRESTClient);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count -1 Do
  Begin
   If (TMasterDetailItem(TList(Self).Items[I]^)          <> Nil)   And
      (TMasterDetailItem(TList(Self).Items[I]^).vDataSet =  Value) Then
    Begin
     If Assigned(TList(Self).Items[I]) Then
      FreeMem(TList(Self).Items[I]);
     TList(Self).Delete(I);
     Break;
    End;
  End;
End;

Function TMasterDetailList.GetRec(Index: Integer): TMasterDetailItem;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMasterDetailItem(TList(Self).Items[Index]^);
End;

Procedure TMasterDetailList.PutRec(Index: Integer; Item: TMasterDetailItem);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMasterDetailItem(TList(Self).Items[Index]^) := Item;
End;

Constructor TMasterDetailItem.Create;
Begin
 vFields := TStringList.Create;
End;

Destructor TMasterDetailItem.Free;
Begin
 vFields.Free;
End;

Procedure TMasterDetailItem.ParseFields(Value : String);
Var
 vTempFields : String;
Begin
 vFields.Clear;
 vTempFields := Value;
 While (vTempFields <> '') Do
  Begin
   If Pos(';', vTempFields) > 0 Then
    Begin
     vFields.Add(UpperCase(Trim(Copy(vTempFields, 1, Pos(';', vTempFields) -1))));
     Delete(vTempFields, 1, Pos(';', vTempFields));
    End
   Else
    Begin
     vFields.Add(UpperCase(Trim(vTempFields)));
     vTempFields := '';
    End;
   vTempFields := Trim(vTempFields);
  End;
End;

end.
