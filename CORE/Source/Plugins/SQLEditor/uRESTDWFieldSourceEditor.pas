unit uRESTDWFieldSourceEditor;

interface

uses
  {$IFDEF FPC}
  LCLIntf, LCLType, LMessages,
  {$ELSE}
  Windows, {$ENDIF}uRESTDWBasicDB, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, Buttons, DB{$IFDEF FPC}, FormEditingIntf,
  PropEdits, lazideintf{$ELSE}, DesignEditors, DesignIntf{$ENDIF};

Type
  { TfMasterDetailRelation }
  TfMasterDetailRelation = class(TForm)
    lbMasterFields: TListBox;
    lbDetailFields: TListBox;
    sbAdd: TSpeedButton;
    lbMasterDetailFields: TListBox;
    sbDelete: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    sbOk: TSpeedButton;
    sbCancel: TSpeedButton;
    procedure sbAddClick(Sender: TObject);
    procedure sbDeleteClick(Sender: TObject);
    procedure lbMasterFieldsClick(Sender: TObject);
    procedure lbMasterDetailFieldsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbCancelClick(Sender: TObject);
    procedure sbOkClick(Sender: TObject);
  Private
    { Private declarations }
   RESTDWClientSQLB : TRESTDWClientSQL;
   Procedure CompareData;
   Procedure ButtonStates;
   Procedure SetMasterDetailData(Value : String);
   Procedure ReadFields(Master, Detail : TDataset);
  Public
    { Public declarations }
   Procedure SetClientSQL(Value : TRESTDWClientSQL);
  End;

 Type
  TRESTDWFieldsRelationEditor = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

var
  fMasterDetailRelation: TfMasterDetailRelation;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ TfMasterDetailRelation }

Procedure TfMasterDetailRelation.ButtonStates;
Var
 I, X : Integer;
begin
 I                := lbMasterFields.ItemIndex;
 X                := lbDetailFields.ItemIndex;
 sbAdd.Enabled    := ((lbMasterFields.Items.Count > 0)      And
                      (lbDetailFields.Items.Count > 0))     And
                     ((I > -1) And (X > -1));
 sbDelete.Enabled := (lbMasterDetailFields.Items.Count > 0) And
                     (lbMasterDetailFields.ItemIndex   > -1);
End;

Procedure TfMasterDetailRelation.CompareData;
Var
 I           : Integer;
 vTempString,
 vField0,
 vField1     : String;
 vStringList : TStringList;
Begin
 vStringList := TStringList.Create;
 Try
  vStringList.Text := lbMasterDetailFields.Items.Text;
  For I := 0 To vStringList.Count -1 Do
   Begin
    vTempString := vStringList[I];
    vField0 := Copy(vTempString, 1, Pos('=', vTempString) -1);
    vField1 := Copy(vTempString, Pos('=', vTempString) +1, Length(vTempString));
    If lbMasterFields.Items.IndexOf(vField0) > -1 Then
     lbMasterFields.Items.Delete(lbMasterFields.Items.IndexOf(vField0));
    If lbDetailFields.Items.IndexOf(vField1) > -1 Then
     lbDetailFields.Items.Delete(lbDetailFields.Items.IndexOf(vField1));
   End;
 Finally
  FreeAndNil(vStringList);
  ButtonStates;
 End;
End;

Procedure TfMasterDetailRelation.ReadFields(Master, Detail: TDataset);
Var
 I : Integer;
Begin
 lbMasterFields.Items.Clear;
 lbDetailFields.Items.Clear;
 If Master <> Nil Then
  For I := 0 To Master.Fields.Count -1 Do
   lbMasterFields.Items.Add(Master.Fields[I].FieldName);
 If Detail <> Nil Then
  For I := 0 To Detail.Fields.Count -1 Do
   lbDetailFields.Items.Add(Detail.Fields[I].FieldName);
 CompareData;
End;

Procedure TfMasterDetailRelation.SetClientSQL(Value: TRESTDWClientSQL);
Begin
 RESTDWClientSQLB := Value;
 SetMasterDetailData(RESTDWClientSQLB.RelationFields.Text);
 ReadFields(RESTDWClientSQLB.MasterDataSet, RESTDWClientSQLB);
End;

Procedure TfMasterDetailRelation.SetMasterDetailData(Value : String);
Begin
 lbMasterDetailFields.Items.Text := Value;
End;

procedure TfMasterDetailRelation.sbAddClick(Sender: TObject);
Var
 I, X : Integer;
begin
 I := lbMasterFields.ItemIndex;
 X := lbDetailFields.ItemIndex;
 If (X > -1) And (I > -1) Then
  Begin
   lbMasterDetailFields.AddItem(Format('%s=%s', [lbMasterFields.Items[I],
                                                 lbDetailFields.Items[X]]), Nil);
   lbMasterFields.Items.Delete(I);
   lbDetailFields.Items.Delete(X);
  End;
 ButtonStates;
end;

procedure TfMasterDetailRelation.sbDeleteClick(Sender: TObject);
Var
 vTempString,
 vField0,
 vField1     : String;
begin
 vTempString := '';
 If lbMasterDetailFields.ItemIndex > -1 Then
  vTempString := lbMasterDetailFields.Items[lbMasterDetailFields.ItemIndex];
 If Trim(vTempString) <> '' Then
  Begin
   vField0 := Copy(vTempString, 1, Pos('=', vTempString) -1);
   vField1 := Copy(vTempString, Pos('=', vTempString) +1, Length(vTempString));
   lbMasterFields.Items.Add(vField0);
   lbDetailFields.Items.Add(vField1);
   lbMasterDetailFields.Items.Delete(lbMasterDetailFields.ItemIndex);
   ButtonStates;
  End;
end;

procedure TfMasterDetailRelation.lbMasterFieldsClick(Sender: TObject);
begin
 ButtonStates;
end;

procedure TfMasterDetailRelation.lbMasterDetailFieldsKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
 ButtonStates;
end;

procedure TfMasterDetailRelation.sbCancelClick(Sender: TObject);
begin
 ModalResult := mrCancel;
end;

procedure TfMasterDetailRelation.sbOkClick(Sender: TObject);
begin
 RESTDWClientSQLB.RelationFields.Text := lbMasterDetailFields.Items.Text;
 ModalResult                          := mrOk;
end;

{ TRESTDWFieldsRelationEditor }
Procedure TRESTDWFieldsRelationEditor.Edit;
Var
 objObj : TRESTDWClientSQL;
Begin
 fMasterDetailRelation := TfMasterDetailRelation.Create(Application);
 Try
  objObj        := TRESTDWClientSQL(GetComponent(0));
  fMasterDetailRelation.SetClientSQL(objObj);
  fMasterDetailRelation.ShowModal;
 Finally
  fMasterDetailRelation.Free;
 End;
End;

Function TRESTDWFieldsRelationEditor.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

Function TRESTDWFieldsRelationEditor.GetValue: String;
Begin
 Result := Trim(TRESTDWClientSQL(GetComponent(0)).RelationFields.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set the Relation Fields...'
End;

end.
