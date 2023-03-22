unit uRESTDWUpdSqlEditor;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

uses
  SysUtils, Dialogs, Forms, ExtCtrls, StdCtrls, ComCtrls, DBGrids, uRESTDWBasicDB, DB{$IFNDEF FPC}, Grids{$ENDIF}, Controls,
  Classes,{$IFDEF FPC}ComponentEditors, FormEditingIntf, PropEdits, lazideintf{$ELSE}DesignEditors, DesignIntf{$ENDIF};

Const
 cSelectLock      = 'Select %s From %s %s WITH LOCK';
 cSelectNoLock    = 'Select %s From %s %s NOLOCK';
 cSelectFetchRows = 'Select %s From %s %s';
 cInsert          = 'Insert into %s (%s) Values (%s)';
 cDelete          = 'Delete From %s %s';
 cUpdate          = 'Update %s Set %s %s';

 Type

  { TFrmDWUpdSqlEditor }

  TFrmDWUpdSqlEditor = class(TForm)
   BtnCancelar: TButton;
   BtnOk: TButton;
   Label1: TLabel;
   lbFields: TListBox;
    mInsertSQL: TMemo;
    PageControl: TPageControl;
   PnlAction: TPanel;
   PnlSQL: TPanel;
    pSQLEditor: TPanel;
    lbTables: TListBox;
    labSql: TLabel;
    Label2: TLabel;
    pSQLTypes: TPanel;
    rbModifySQL: TRadioButton;
    rbInsertSQL: TRadioButton;
    rbLockSQL: TRadioButton;
    rbDeleteSQL: TRadioButton;
    tsInsertSQL: TTabSheet;
    tsModifySQL: TTabSheet;
    tsDeleteSQL: TTabSheet;
    tsLockSQL: TTabSheet;
    tsUnlockSQL: TTabSheet;
    tsFetchRowSQL: TTabSheet;
    mModifySQL: TMemo;
    mDeleteSQL: TMemo;
    mLockSQL: TMemo;
    mUnlockSQL: TMemo;
    mFetchRowSQL: TMemo;
    rbUnLockSQL: TRadioButton;
    rbFetchRowSQL: TRadioButton;
    lbKeyFields: TListBox;
    Label3: TLabel;
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lbTablesClick(Sender: TObject);
    procedure lbTablesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mInsertSQLDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure mInsertSQLDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure rbInsertSQLClick(Sender: TObject);
    procedure rbModifySQLClick(Sender: TObject);
    procedure rbDeleteSQLClick(Sender: TObject);
    procedure rbLockSQLClick(Sender: TObject);
    procedure rbUnLockSQLClick(Sender: TObject);
    procedure rbFetchRowSQLClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    {$IFNDEF FPC}
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    {$ELSE}
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    {$ENDIF}
 Private
  { Private declarations }
  vLastSelect        : String;
  RESTDWDatabase     : TRESTDWDatabasebaseBase;
  RESTDWStoredProc   : TRESTDWStoredProcedure;
  RESTDWClientSQL    : TRESTDWClientSQL;
  RESTDWUpdateSQL    : TRESTDWUpdateSQL;
  Procedure SetFields;
  Procedure SetTableState(Value : TTabSheet);
  Procedure SetMemoProps (Value : TRESTDWUpdateSQL);
  Procedure SetPropsMemo (Value : TRESTDWUpdateSQL);
  Function  GetSQL(Value : TTabSheet) : String;
 Public
  { Public declarations }
  Procedure SetClientSQL(Value : TRESTDWClientSQL);
 End;

 Type
  TDWUpdSQLEditorDelete = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

 Type
  TDWUpdSQLEditorInsert = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

 Type
  TDWUpdSQLEditorLock = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

 Type
  TDWUpdSQLEditorUnlock = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

 Type
  TDWUpdSQLEditorFetchRow = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

 Type
  TDWUpdSQLEditorModify = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

Type
 TDWUpdateSQLEditor = Class(TComponentEditor)
  Function  GetVerbCount      : Integer;  Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;

Var
 FrmDWUpdSqlEditor : TFrmDWUpdSqlEditor;

Implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

Function TDWUpdateSQLEditor.GetVerbCount: Integer;
Begin
 Result := 1;
End;

Function TDWUpdateSQLEditor.GetVerb(Index: Integer): string;
Begin
 Case Index of
  0 : Result := '&SQL Editor';
 End;
End;

Procedure TDWUpdateSQLEditor.ExecuteVerb(Index: Integer);
Var
 objObj : TRESTDWUpdateSQL;
Begin
 Inherited;
 Case Index of
   0 : Begin
        FrmDWUpdSqlEditor := TFrmDWUpdSqlEditor.Create(Application);
        Try
         objObj                             := TRESTDWUpdateSQL(Component);
         FrmDWUpdSqlEditor.RESTDWUpdateSQL  := objObj;
         FrmDWUpdSqlEditor.SetMemoProps(objObj);
         FrmDWUpdSqlEditor.SetClientSQL (TRESTDWClientSQL(objObj.Dataset));
         FrmDWUpdSqlEditor.SetTableState(FrmDWUpdSqlEditor.tsInsertSQL);
         FrmDWUpdSqlEditor.ShowModal;
         Designer.Modified;
        Finally
       //  FreeAndNil(FrmDWUpdSqlEditor);
        End;
       End;
 End;
End;

Function TFrmDWUpdSqlEditor.GetSQL(Value : TTabSheet) : String;
Var
 I         : Integer;
 vFieldsA,
 vFieldsB,
 vFieldsC  : String;
Begin
 Result := '';
 vFieldsA := Result;
 vFieldsB := Result;
 If lbTables.itemIndex < 0 Then
  Exit;
 If Value = tsInsertSQL Then
  Begin
   Result := cInsert;
   For I := 0 To lbFields.Count -1 Do
    Begin
     If ((lbFields.Selected[I])   And
         (lbFields.SelCount > 0)) Or
        (lbFields.SelCount = 0)   Then
      Begin
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
       If vFieldsB = '' Then
        vFieldsB := ':' + lbFields.Items[I]
       Else
        vFieldsB := vFieldsB + ', :' + lbFields.Items[I];
      End;
    End;
   Result := Format(Result, [lbTables.Items[lbTables.itemIndex], vFieldsA, vFieldsB]);
  End
 Else If Value = tsModifySQL Then
  Begin
   Result   := cUpdate;
   vFieldsC := '';
   For I := 0 To lbFields.Count -1 Do
    Begin
     If ((lbFields.Selected[I])   And
         (lbFields.SelCount > 0)) Or
        (lbFields.SelCount = 0)   Then
     If vFieldsA = '' Then
      vFieldsA := lbFields.Items[I] + ' = :' + lbFields.Items[I]
     Else
      vFieldsA := vFieldsA + ', ' + lbFields.Items[I] + ' = :' + lbFields.Items[I];
    End;
   For I := 0 To lbKeyFields.Count -1 Do
    Begin
     If ((lbKeyFields.Selected[I])   And
         (lbKeyFields.SelCount > 0)) Or
        (lbKeyFields.SelCount = 0)   Then
      Begin
       If vFieldsC = '' Then
        vFieldsC := lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I]
       Else
        vFieldsC := vFieldsC + ' AND ' + lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I];
      End;
    End;
   If Trim(vFieldsC) <> '' Then
    vFieldsC := 'where ' + vFieldsC;
   Result := Format(Result, [lbTables.Items[lbTables.itemIndex], vFieldsA, vFieldsC]);
  End
 Else If Value = tsDeleteSQL Then
  Begin
   Result := cDelete;
   For I := 0 To lbKeyFields.Count -1 Do
    Begin
     If ((lbKeyFields.Selected[I])   And
         (lbKeyFields.SelCount > 0)) Or
        (lbKeyFields.SelCount = 0)   Then
      Begin
       If vFieldsC = '' Then
        vFieldsC := lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I]
       Else
        vFieldsC := vFieldsC + ' AND ' + lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I];
      End;
    End;
   If Trim(vFieldsC) <> '' Then
    vFieldsC := 'where ' + vFieldsC;
   Result := Format(Result, [lbTables.Items[lbTables.itemIndex], vFieldsC]);
  End
 Else If Value = tsLockSQL   Then
  Begin
   Result := cSelectLock;
   If lbFields.SelCount > 0 Then
   For I := 0 To lbFields.Count -1 Do
    Begin
     If lbFields.Selected[I] Then
      If vFieldsA = '' Then
       vFieldsA := lbFields.Items[I]
      Else
       vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
    End;
   For I := 0 To lbKeyFields.Count -1 Do
    Begin
     If ((lbKeyFields.Selected[I])   And
         (lbKeyFields.SelCount > 0)) Or
        (lbKeyFields.SelCount = 0)   Then
      Begin
       If vFieldsC = '' Then
        vFieldsC := lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I]
       Else
        vFieldsC := vFieldsC + ' AND ' + lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I];
      End;
    End;
   If Trim(vFieldsC) <> '' Then
    vFieldsC := 'where ' + vFieldsC;
   If lbFields.SelCount > 0 Then
    Result := Format(Result, [vFieldsA, lbTables.Items[lbTables.itemIndex], vFieldsC])
   Else
    Result := Format(Result, ['*', lbTables.Items[lbTables.itemIndex], vFieldsC]);
  End
 Else If Value = tsUnlockSQL Then
  Begin
   Result := cSelectNoLock;
   If lbFields.SelCount > 0 Then
   For I := 0 To lbFields.Count -1 Do
    Begin
     If lbFields.Selected[I] Then
     If vFieldsA = '' Then
      vFieldsA := lbFields.Items[I]
     Else
      vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
    End;
   For I := 0 To lbKeyFields.Count -1 Do
    Begin
     If ((lbKeyFields.Selected[I])   And
         (lbKeyFields.SelCount > 0)) Or
        (lbKeyFields.SelCount = 0)   Then
      Begin
       If vFieldsC = '' Then
        vFieldsC := lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I]
       Else
        vFieldsC := vFieldsC + ' AND ' + lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I];
      End;
    End;
   If Trim(vFieldsC) <> '' Then
    vFieldsC := 'where ' + vFieldsC;
   If lbFields.SelCount > 0 Then
    Result := Format(Result, [vFieldsA, lbTables.Items[lbTables.itemIndex], vFieldsC])
   Else
    Result := Format(Result, ['*', lbTables.Items[lbTables.itemIndex], vFieldsC]);
  End
 Else If Value = tsFetchRowSQL Then
  Begin
   Result := cSelectFetchRows;
   If lbFields.SelCount > 0 Then
   For I := 0 To lbFields.Count -1 Do
    Begin
     If lbFields.Selected[I] Then
     If vFieldsA = '' Then
      vFieldsA := lbFields.Items[I]
     Else
      vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
    End;
   For I := 0 To lbKeyFields.Count -1 Do
    Begin
     If ((lbKeyFields.Selected[I])   And
         (lbKeyFields.SelCount > 0)) Or
        (lbKeyFields.SelCount = 0)   Then
      Begin
       If vFieldsC = '' Then
        vFieldsC := lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I]
       Else
        vFieldsC := vFieldsC + ' AND ' + lbKeyFields.Items[I] + ' = :KEY_' + lbKeyFields.Items[I];
      End;
    End;
   If Trim(vFieldsC) <> '' Then
    vFieldsC := 'where ' + vFieldsC;
   If lbFields.SelCount > 0 Then
    Result := Format(Result, [vFieldsA, lbTables.Items[lbTables.itemIndex], vFieldsC])
   Else
    Result := Format(Result, ['*', lbTables.Items[lbTables.itemIndex], vFieldsC]);
  End;
End;

Procedure TFrmDWUpdSqlEditor.SetPropsMemo(Value : TRESTDWUpdateSQL);
Begin
 Value.InsertSQL.Text   := mInsertSQL.Text;
 Value.ModifySQL.Text   := mModifySQL.Text;
 Value.DeleteSQL.Text   := mDeleteSQL.Text;
 Value.LockSQL.Text     := mLockSQL.Text;
 Value.UnlockSQL.Text   := mUnlockSQL.Text;
 Value.FetchRowSQL.Text := mFetchRowSQL.Text;
End;

Procedure TFrmDWUpdSqlEditor.SetMemoProps(Value : TRESTDWUpdateSQL);
Begin
 mInsertSQL.Text   := Value.InsertSQL.Text;
 mModifySQL.Text   := Value.ModifySQL.Text;
 mDeleteSQL.Text   := Value.DeleteSQL.Text;
 mLockSQL.Text     := Value.LockSQL.Text;
 mUnlockSQL.Text   := Value.UnlockSQL.Text;
 mFetchRowSQL.Text := Value.FetchRowSQL.Text;
End;

Procedure TFrmDWUpdSqlEditor.SetTableState(Value : TTabSheet);
Begin
 PageControl.ActivePage := Value;
 rbInsertSQL.Checked    := Value = tsInsertSQL;
 rbModifySQL.Checked    := Value = tsModifySQL;
 rbDeleteSQL.Checked    := Value = tsDeleteSQL;
 rbLockSQL.Checked      := Value = tsLockSQL;
 rbUnlockSQL.Checked    := Value = tsUnlockSQL;
 rbFetchRowSQL.Checked  := Value = tsFetchRowSQL;
End;

Function TDWUpdSQLEditorDelete.GetValue : String;
Begin
 Result := Trim(TRESTDWUpdateSQL(GetComponent(0)).DeleteSQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set DeleteSQL...'
End;

Function TDWUpdSQLEditorInsert.GetValue : String;
Begin
 Result := Trim(TRESTDWUpdateSQL(GetComponent(0)).InsertSQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set InsertSQL...'
End;

Function TDWUpdSQLEditorLock.GetValue : String;
Begin
 Result := Trim(TRESTDWUpdateSQL(GetComponent(0)).LockSQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set LockSQL...'
End;

Function TDWUpdSQLEditorUnlock.GetValue : String;
Begin
 Result := Trim(TRESTDWUpdateSQL(GetComponent(0)).UnlockSQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set UnlockSQL...'
End;

Function TDWUpdSQLEditorFetchRow.GetValue : String;
Begin
 Result := Trim(TRESTDWUpdateSQL(GetComponent(0)).FetchRowSQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set FetchRowSQL...'
End;

Function TDWUpdSQLEditorModify.GetValue : String;
Begin
 Result := Trim(TRESTDWUpdateSQL(GetComponent(0)).ModifySQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set ModifySQL...'
End;

Procedure TDWUpdSQLEditorDelete.Edit;
Var
 objObj : TRESTDWUpdateSQL;
Begin
 FrmDWUpdSqlEditor := TFrmDWUpdSqlEditor.Create(Application);
 Try
  objObj                             := TRESTDWUpdateSQL(GetComponent(0));
  FrmDWUpdSqlEditor.RESTDWUpdateSQL  := objObj;
  FrmDWUpdSqlEditor.SetMemoProps(objObj);
  FrmDWUpdSqlEditor.SetClientSQL (TRESTDWClientSQL(objObj.Dataset));
  FrmDWUpdSqlEditor.SetTableState(FrmDWUpdSqlEditor.tsDeleteSQL);
  FrmDWUpdSqlEditor.ShowModal;
 Finally
//  FreeAndNil(FrmDWUpdSqlEditor);
 End;
End;

Procedure TDWUpdSQLEditorInsert.Edit;
Var
 objObj : TRESTDWUpdateSQL;
Begin
 FrmDWUpdSqlEditor := TFrmDWUpdSqlEditor.Create(Application);
 Try
  objObj                             := TRESTDWUpdateSQL(GetComponent(0));
  FrmDWUpdSqlEditor.RESTDWUpdateSQL  := objObj;
  FrmDWUpdSqlEditor.SetMemoProps(objObj);
  FrmDWUpdSqlEditor.SetClientSQL (TRESTDWClientSQL(objObj.Dataset));
  FrmDWUpdSqlEditor.SetTableState(FrmDWUpdSqlEditor.tsInsertSQL);
  FrmDWUpdSqlEditor.ShowModal;
 Finally
  //FreeAndNil(FrmDWUpdSqlEditor);
 End;
End;

Procedure TDWUpdSQLEditorLock.Edit;
Var
 objObj : TRESTDWUpdateSQL;
Begin
 FrmDWUpdSqlEditor := TFrmDWUpdSqlEditor.Create(Application);
 Try
  objObj                             := TRESTDWUpdateSQL(GetComponent(0));
  FrmDWUpdSqlEditor.RESTDWUpdateSQL  := objObj;
  FrmDWUpdSqlEditor.SetMemoProps(objObj);
  FrmDWUpdSqlEditor.SetClientSQL (TRESTDWClientSQL(objObj.Dataset));
  FrmDWUpdSqlEditor.SetTableState(FrmDWUpdSqlEditor.tsLockSQL);
  FrmDWUpdSqlEditor.ShowModal;
 Finally
  //FreeAndNil(FrmDWUpdSqlEditor);
 End;
End;

Procedure TDWUpdSQLEditorUnlock.Edit;
Var
 objObj : TRESTDWUpdateSQL;
Begin
 FrmDWUpdSqlEditor := TFrmDWUpdSqlEditor.Create(Application);
 Try
  objObj                             := TRESTDWUpdateSQL(GetComponent(0));
  FrmDWUpdSqlEditor.RESTDWUpdateSQL  := objObj;
  FrmDWUpdSqlEditor.SetMemoProps(objObj);
  FrmDWUpdSqlEditor.SetClientSQL (TRESTDWClientSQL(objObj.Dataset));
  FrmDWUpdSqlEditor.SetTableState(FrmDWUpdSqlEditor.tsUnlockSQL);
  FrmDWUpdSqlEditor.ShowModal;
 Finally
  //FreeAndNil(FrmDWUpdSqlEditor);
 End;
End;

Procedure TDWUpdSQLEditorFetchRow.Edit;
Var
 objObj : TRESTDWUpdateSQL;
Begin
 FrmDWUpdSqlEditor := TFrmDWUpdSqlEditor.Create(Application);
 Try
  objObj                             := TRESTDWUpdateSQL(GetComponent(0));
  FrmDWUpdSqlEditor.RESTDWUpdateSQL  := objObj;
  FrmDWUpdSqlEditor.SetMemoProps(objObj);
  FrmDWUpdSqlEditor.SetClientSQL (TRESTDWClientSQL(objObj.Dataset));
  FrmDWUpdSqlEditor.SetTableState(FrmDWUpdSqlEditor.tsFetchRowSQL);
  FrmDWUpdSqlEditor.ShowModal;
 Finally
  //FreeAndNil(FrmDWUpdSqlEditor);
 End;
End;

Procedure TDWUpdSQLEditorModify.Edit;
Var
 objObj : TRESTDWUpdateSQL;
Begin
 FrmDWUpdSqlEditor := TFrmDWUpdSqlEditor.Create(Application);
 Try
  objObj                             := TRESTDWUpdateSQL(GetComponent(0));
  FrmDWUpdSqlEditor.RESTDWUpdateSQL  := objObj;
  FrmDWUpdSqlEditor.SetMemoProps(objObj);
  FrmDWUpdSqlEditor.SetClientSQL (TRESTDWClientSQL(objObj.Dataset));
  FrmDWUpdSqlEditor.SetTableState(FrmDWUpdSqlEditor.tsModifySQL);
  FrmDWUpdSqlEditor.ShowModal;
 Finally
  //FreeAndNil(FrmDWUpdSqlEditor);
 End;
End;

Function TDWUpdSQLEditorDelete.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

Function TDWUpdSQLEditorInsert.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

Function TDWUpdSQLEditorLock.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

Function TDWUpdSQLEditorUnlock.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

Function TDWUpdSQLEditorModify.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

Function TDWUpdSQLEditorFetchRow.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

procedure TFrmDWUpdSqlEditor.BtnCancelarClick(Sender: TObject);
begin
 Close;
end;

procedure TFrmDWUpdSqlEditor.BtnOkClick(Sender: TObject);
begin
 SetPropsMemo(RESTDWUpdateSQL);
 Close;
end;

procedure TFrmDWUpdSqlEditor.FormCreate(Sender: TObject);
begin
 RESTDWDatabase   := TRESTDWDatabasebaseBase.Create(Self);
 RESTDWClientSQL  := Nil;
 RESTDWStoredProc := Nil;
 vLastSelect      := '';
end;

Procedure TFrmDWUpdSqlEditor.SetFields;
Var
 vMemString : TStringList;
Begin
 If (lbTables.Count > 0) And (lbTables.ItemIndex > -1) And
    (vLastSelect <> lbTables.Items[lbTables.itemIndex]) Then
  Begin
   If (RESTDWStoredProc <> Nil) Or
      (RESTDWClientSQL  <> Nil) Then
    Begin
     If (RESTDWClientSQL  <> Nil) Then
      If RESTDWClientSQL.DataBase = Nil Then
       Exit;
     If (RESTDWStoredProc  <> Nil) Then
      If RESTDWStoredProc.DataBase = Nil Then
       Exit;
     vLastSelect                   := lbTables.Items[lbTables.itemIndex];
     vMemString                    := TStringList.Create;
     Try
      RESTDWDatabase.GetFieldNames   (lbTables.Items[lbTables.itemIndex], vMemString);
      lbFields.Items.Text          := vMemString.Text;
      vMemString.Text              := '';
      RESTDWDatabase.GetKeyFieldNames(lbTables.Items[lbTables.itemIndex], vMemString);
      lbKeyFields.Items.Text       := vMemString.Text;
     Finally
      FreeAndNil(vMemString);
     End;
    End;
  End
 Else If (lbTables.Count > 0) And (lbTables.ItemIndex = -1) Then
  lbFields.Items.Clear;
End;

Procedure TFrmDWUpdSqlEditor.SetClientSQL(Value: TRESTDWClientSQL);
Var
 vMemString : TStringList;
Begin
 If Value.ClassType = TRESTDWStoredProcedure Then
  Begin
   RESTDWStoredProc   := TRESTDWStoredProcedure(Value);
   If RESTDWStoredProc <> Nil Then
    Begin
     If RESTDWStoredProc.DataBase <> Nil Then
      Begin
       RESTDWDatabase.AccessTag             := RESTDWStoredProc.DataBase.AccessTag;
       RESTDWDatabase.Encoding              := RESTDWStoredProc.DataBase.Encoding;
       RESTDWDatabase.Context               := RESTDWStoredProc.DataBase.Context;
       RESTDWDatabase.EncodedStrings        := RESTDWStoredProc.DataBase.EncodedStrings;
       RESTDWDatabase.Compression           := RESTDWStoredProc.DataBase.Compression;
       RESTDWDatabase.ParamCreate           := RESTDWStoredProc.DataBase.ParamCreate;
       RESTDWDatabase.PoolerName            := RESTDWStoredProc.DataBase.PoolerName;
       RESTDWDatabase.PoolerPort            := RESTDWStoredProc.DataBase.PoolerPort;
       RESTDWDatabase.PoolerService         := RESTDWStoredProc.DataBase.PoolerService;
       RESTDWDatabase.Proxy                 := RESTDWStoredProc.DataBase.Proxy;
       RESTDWDatabase.ProxyOptions.Server   := RESTDWStoredProc.DataBase.ProxyOptions.Server;
       RESTDWDatabase.ProxyOptions.Port     := RESTDWStoredProc.DataBase.ProxyOptions.Port;
       RESTDWDatabase.ProxyOptions.Login    := RESTDWStoredProc.DataBase.ProxyOptions.Login;
       RESTDWDatabase.ProxyOptions.Password := RESTDWStoredProc.DataBase.ProxyOptions.Password;
       RESTDWDatabase.RequestTimeOut        := RESTDWStoredProc.DataBase.RequestTimeOut;
       RESTDWDatabase.TypeRequest           := RESTDWStoredProc.DataBase.TypeRequest;
       RESTDWDatabase.WelcomeMessage        := RESTDWStoredProc.DataBase.WelcomeMessage;
       RESTDWDatabase.CriptOptions.Use      := RESTDWStoredProc.DataBase.CriptOptions.Use;
       RESTDWDatabase.CriptOptions.Key      := RESTDWStoredProc.DataBase.CriptOptions.Key;
       RESTDWDatabase.DataRoute             := RESTDWStoredProc.DataBase.DataRoute;
       RESTDWDatabase.AuthenticationOptions.Assign(RESTDWStoredProc.DataBase.AuthenticationOptions);
       vMemString                           := TStringList.Create;
       Try
        RESTDWDatabase.GetTableNames(vMemString);
        lbTables.Items.Text                 := vMemString.Text;
        If lbTables.Count > 0 Then
         Begin
          lbTables.ItemIndex                 := 0;
          SetFields;
         End;
       Finally
        FreeAndNil(vMemString);
       End;
      End;
    End;
  End
 Else
  Begin
   RESTDWClientSQL    := TRESTDWClientSQL(Value);
   If RESTDWClientSQL <> Nil Then
    Begin
     If RESTDWClientSQL.DataBase <> Nil Then
      Begin
       RESTDWDatabase.AccessTag             := RESTDWClientSQL.DataBase.AccessTag;
       RESTDWDatabase.Encoding              := RESTDWClientSQL.DataBase.Encoding;
       RESTDWDatabase.Context               := RESTDWClientSQL.DataBase.Context;
       RESTDWDatabase.EncodedStrings        := RESTDWClientSQL.DataBase.EncodedStrings;
       RESTDWDatabase.Compression           := RESTDWClientSQL.DataBase.Compression;
       RESTDWDatabase.ParamCreate           := RESTDWClientSQL.DataBase.ParamCreate;
       RESTDWDatabase.PoolerName            := RESTDWClientSQL.DataBase.PoolerName;
       RESTDWDatabase.PoolerPort            := RESTDWClientSQL.DataBase.PoolerPort;
       RESTDWDatabase.PoolerService         := RESTDWClientSQL.DataBase.PoolerService;
       RESTDWDatabase.Proxy                 := RESTDWClientSQL.DataBase.Proxy;
       RESTDWDatabase.ProxyOptions.Server   := RESTDWClientSQL.DataBase.ProxyOptions.Server;
       RESTDWDatabase.ProxyOptions.Port     := RESTDWClientSQL.DataBase.ProxyOptions.Port;
       RESTDWDatabase.ProxyOptions.Login    := RESTDWClientSQL.DataBase.ProxyOptions.Login;
       RESTDWDatabase.ProxyOptions.Password := RESTDWClientSQL.DataBase.ProxyOptions.Password;
       RESTDWDatabase.RequestTimeOut        := RESTDWClientSQL.DataBase.RequestTimeOut;
       RESTDWDatabase.TypeRequest           := RESTDWClientSQL.DataBase.TypeRequest;
       RESTDWDatabase.WelcomeMessage        := RESTDWClientSQL.DataBase.WelcomeMessage;
       RESTDWDatabase.CriptOptions.Use      := RESTDWClientSQL.DataBase.CriptOptions.Use;
       RESTDWDatabase.CriptOptions.Key      := RESTDWClientSQL.DataBase.CriptOptions.Key;
       RESTDWDatabase.DataRoute             := RESTDWClientSQL.DataBase.DataRoute;
       RESTDWDatabase.AuthenticationOptions.Assign(RESTDWClientSQL.DataBase.AuthenticationOptions);
       vMemString                           := TStringList.Create;
       Try
        RESTDWDatabase.GetTableNames(vMemString);
        lbTables.Items.Text                 := vMemString.Text;
        If lbTables.Count > 0 Then
         Begin
          lbTables.ItemIndex                 := 0;
          SetFields;
         End;
       Finally
        FreeAndNil(vMemString);
       End;
      End;
    End;
  End;
End;

procedure TFrmDWUpdSqlEditor.FormResize(Sender: TObject);
begin
 PageControl.Top    := 0;
 PageControl.Left   := pSQLEditor.Width;
end;

procedure TFrmDWUpdSqlEditor.lbTablesClick(Sender: TObject);
begin
 SetFields;
end;

procedure TFrmDWUpdSqlEditor.lbTablesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 SetFields;
end;

procedure TFrmDWUpdSqlEditor.mInsertSQLDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
 Accept := Source is Tlistbox;
end;

procedure TFrmDWUpdSqlEditor.mInsertSQLDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
 If Source = lbTables Then
  Begin
   If Trim(TMemo(Sender).Lines.Text) = '' Then
    TMemo(Sender).Lines.Text := GetSQL(TTabSheet(TMemo(Sender).Parent))
   Else
    TMemo(Sender).Lines.Text := TMemo(Sender).Lines.Text + sLineBreak + GetSQL(TTabSheet(TMemo(Sender).Parent));
  End;
end;

procedure TFrmDWUpdSqlEditor.rbInsertSQLClick(Sender: TObject);
begin
 PageControl.ActivePage := tsInsertSQL;
end;

procedure TFrmDWUpdSqlEditor.rbModifySQLClick(Sender: TObject);
begin
 PageControl.ActivePage := tsModifySQL;
end;

procedure TFrmDWUpdSqlEditor.rbDeleteSQLClick(Sender: TObject);
begin
 PageControl.ActivePage := tsDeleteSQL;
end;

procedure TFrmDWUpdSqlEditor.rbLockSQLClick(Sender: TObject);
begin
 PageControl.ActivePage := tsLockSQL;
end;

procedure TFrmDWUpdSqlEditor.rbUnLockSQLClick(Sender: TObject);
begin
 PageControl.ActivePage := tsUnlockSQL;
end;

procedure TFrmDWUpdSqlEditor.rbFetchRowSQLClick(Sender: TObject);
begin
 PageControl.ActivePage := tsFetchRowSQL;
end;

procedure TFrmDWUpdSqlEditor.PageControlChange(Sender: TObject);
begin
 SetTableState(PageControl.ActivePage);
end;

{$IFNDEF FPC}
procedure TFrmDWUpdSqlEditor.FormClose(Sender: TObject; var Action: TCloseAction);
{$ELSE}
procedure TFrmDWUpdSqlEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
{$ENDIF}
begin
 RESTDWDatabase.Active   := False;
 FreeAndNil(RESTDWDatabase);
 Release;
end;

end.
