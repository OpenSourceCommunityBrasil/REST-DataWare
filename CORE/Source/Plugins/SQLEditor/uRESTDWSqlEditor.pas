unit uRESTDWSqlEditor;

{$I ..\..\..\Source\Includes\uRESTDW.inc}

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
  SysUtils, Dialogs, Forms, ExtCtrls, StdCtrls, ComCtrls, DBGrids,
  uRESTDWBasicDB, DB{$IFNDEF FPC}, Grids{$ENDIF}, Controls,
  Classes, SyncObjs,
  {$IFDEF FPC}
    FormEditingIntf, PropEdits, lazideintf
  {$ELSE}
    DesignEditors, DesignIntf
  {$ENDIF};

Const
 cSelect = 'Select %s From %s';
 cInsert = 'Insert into %s (%s) Values (%s)';
 cDelete = 'Delete From %s Where ';
 cUpdate = 'Update %s Set %s Where ';

 Type
  TOnTrhFimBusca = procedure(Sender : TObject; evento : string; lstString : TStringList) of object;

  { TThrBancoDados }

  TThrBancoDados = class(TThread)
  private
    FRESTDWDatabase : TRESTDWDatabasebaseBase;
    FEvent : TSimpleEvent;
    FMustDie : boolean;
    FTipoEvento : string;
    FBuscar : string;
    FMemString : TStringList;
    FOnFimEvento : TOnTrhFimBusca;
  protected
    procedure Execute; override;
    {$IFDEF FPC}
      procedure TerminatedSet; override;
    {$ENDIF}
    procedure callFimBusca;
  public
    constructor Create;
    destructor Destroy; override;

    procedure threadDie;

    procedure buscarTabelas;
    procedure buscarFieldsNames(tabela : string);
  published
    property RESTDWDatabase : TRESTDWDatabasebaseBase read FRESTDWDatabase write FRESTDWDatabase;
    property OnFimEvento : TOnTrhFimBusca read FOnFimEvento write FOnFimEvento;
  end;

  { TFrmDWSqlEditor }

  TFrmDWSqlEditor = class(TForm)
   BtnCancelar: TButton;
   BtnExecute: TButton;
   BtnOk: TButton;
   DBGridRecord: TDBGrid;
   PageControlResult: TPageControl;
   PnlAction: TPanel;
   PnlButton: TPanel;
   PnlSQL: TPanel;
   pSQLEditor: TPanel;
   lbTables: TListBox;
   labSql: TLabel;
   Label1: TLabel;
   lbFields: TListBox;
   Label2: TLabel;
   pSQLTypes: TPanel;
   rbInsert: TRadioButton;
   rbSelect: TRadioButton;
   rbDelete: TRadioButton;
   rbUpdate: TRadioButton;
   TabSheetTable: TTabSheet;
   pEditor: TPanel;
   PageControl: TPageControl;
   TabSheetSQL: TTabSheet;
   Memo: TMemo;
   Panel1: TPanel;
   Label3: TLabel;
   lbExecutedTime: TLabel;
   tmClose: TTimer;
   procedure BtnExecuteClick(Sender: TObject);
   {$IFNDEF FPC}
   procedure FormClose(Sender: TObject; var Action: TCloseAction);
   {$ELSE}
   procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
   {$ENDIF}
   procedure FormShow(Sender: TObject);
   procedure FormCreate(Sender: TObject);
   procedure lbTablesClick(Sender: TObject);
   procedure lbTablesKeyUp(Sender: TObject; var Key: Word;
     Shift: TShiftState);
   procedure MemoDragOver(Sender, Source: TObject; X, Y: Integer;
     State: TDragState; var Accept: Boolean);
   procedure MemoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BtnCancelarClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure tmCloseTimer(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
 Private
  { Private declarations }
  DataSource         : TDataSource;
  RESTDWDatabase     : TRESTDWDatabasebaseBase;
  RESTDWClientSQL,
  RESTDWClientSQLB   : TRESTDWClientSQL;
  vLastSelect,
  vOldSQL            : String;
  FThrBancoDados     : TThrBancoDados;
  FResModal          : Cardinal;
  Procedure SetFields;
  Function  BuildSQL : String;
  Procedure SetDatabase(Value : TRESTDWDatabasebaseBase);
  Procedure SetarControles(enab : boolean);
  Procedure CarregarTabelas;
  Procedure thrOnFimEvento(Sender : TObject; evento : string; lstString : TStringList);
  Procedure thrOnTerminate(Sender : TObject);
 Public
  { Public declarations }
  Procedure SetClientSQL(Value : TRESTDWClientSQL);
  Property  Database : TRESTDWDatabasebaseBase Read RESTDWDatabase Write SetDatabase;
 End;

 Type
  TRESTDWSQLEditor = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
  procedure SetValue(const Value: string);              Override;
 End;

Var
 FrmDWSqlEditor : TFrmDWSqlEditor;

Implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

Function TRESTDWSQLEditor.GetValue : String;
Begin
 Result := Trim(TRESTDWClientSQL(GetComponent(0)).SQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set SQL...'
End;

procedure TRESTDWSQLEditor.SetValue(const Value: string);
Var
  objObj : TRESTDWClientSQL;
Begin
  objObj        := TRESTDWClientSQL(GetComponent(0));
  objObj.SQL.Text := Trim(Value);
  Modified; // update na propridade do object inspector
end;

Procedure TRESTDWSQLEditor.Edit;
Var
  objObj : TRESTDWClientSQL;
  vModal : cardinal;
Begin
  FrmDWSqlEditor := TFrmDWSqlEditor.Create(Application);
  Try
    objObj        := TRESTDWClientSQL(GetComponent(0));
    FrmDWSqlEditor.SetClientSQL(objObj);
    vModal := FrmDWSqlEditor.ShowModal;

    if vModal = mrOk then
      SetValue(FrmDWSqlEditor.Memo.Text);

    objObj        := Nil;
    FrmDWSqlEditor.Free;
  Except

  End;
End;

Function TRESTDWSQLEditor.GetAttributes: TPropertyAttributes;
Begin
//paAutoUpdate
 Result := [paDialog];
End;

procedure TFrmDWSqlEditor.BtnCancelarClick(Sender: TObject);
begin
  BtnCancelar.Tag := 1;
  FResModal := mrCancel;
  Close;
end;

Procedure TFrmDWSqlEditor.BtnExecuteClick(Sender: TObject);
var
  dti, dtf : TDateTime;
Begin
 Screen.Cursor := crHourGlass;
 Try
  RESTDWClientSQLB.Close;
  RESTDWClientSQLB.BinaryRequest := RESTDWClientSQL.BinaryRequest;
  RESTDWClientSQLB.SQL.Clear;
  RESTDWClientSQLB.SQL.Add(Memo.Lines.Text);

  dti := Now;
  RESTDWClientSQLB.Open;
  dtf := Now;
 Finally
  lbExecutedTime.Caption := FormatDateTime('HH:nn:ss:zzz',dtf-dti);
  Screen.Cursor := crDefault;
 End;
End;

procedure TFrmDWSqlEditor.BtnOkClick(Sender: TObject);
begin
  FResModal := mrOk;
  Close;
end;

procedure TFrmDWSqlEditor.FormActivate(Sender: TObject);
begin
 CarregarTabelas;
end;

{$IFNDEF FPC}
procedure TFrmDWSqlEditor.FormClose(Sender: TObject; var Action: TCloseAction);
{$ELSE}
procedure TFrmDWSqlEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
{$ENDIF}
begin
 If (FResModal = mrCancel) and (vOldSQL <> Memo.Text) and (BtnCancelar.Tag = 1) Then
 Begin
   {$IFDEF FPC}
    If MessageDlg('SQL Editor', 'Realmente deseja sair ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
     Begin
      BtnCancelar.Tag := 0;
      CloseAction:=caNone;
      Exit;
     End;
  {$ELSE}
    If MessageDlg('Realmente deseja sair ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
     Begin
      BtnCancelar.Tag := 0;
      Action:=caNone;
      Exit;
     End;
  {$ENDIF}
 End;

 BtnCancelar.Tag := 2;

 if FThrBancoDados <> nil then begin
   FThrBancoDados.threadDie;
   tmClose.Enabled := True;
   {$IFDEF FPC}
     CloseAction:=caNone;
   {$ELSE}
     Action:=caNone;
   {$ENDIF}
   Exit;
 end;

 ModalResult := FResModal; // devido o clock (passa duas vezes)

 RESTDWClientSQLB.Active := False;
 FreeAndNil(RESTDWClientSQLB);
 If Assigned(RESTDWDatabase) Then
  RESTDWDatabase.Active   := False;
 FreeAndNil(DataSource);
 Release;
end;

procedure TFrmDWSqlEditor.FormCreate(Sender: TObject);
begin
 RESTDWClientSQLB := TRESTDWClientSQL.Create(Self);
 DataSource       := TDataSource.Create(Self);
 vLastSelect      := '';
 FResModal        := mrNone;

 RESTDWDatabase := nil;

 FThrBancoDados := TThrBancoDados.Create;
 FThrBancoDados.OnFimEvento := {$IFDEF FPC}@{$ENDIF}thrOnFimEvento;
 FThrBancoDados.OnTerminate := {$IFDEF FPC}@{$ENDIF}thrOnTerminate;

 SetarControles(False);
end;

procedure TFrmDWSqlEditor.FormShow(Sender: TObject);
begin
 DataSource.DataSet        := RESTDWClientSQLB;
 DBGridRecord.DataSource   := DataSource;

 If Assigned(RESTDWClientSQL) Then Begin
   RESTDWDatabase            := RESTDWClientSQL.DataBase;
   RESTDWClientSQLB.DataBase := RESTDWDatabase;
 end;

 FThrBancoDados.RESTDWDatabase := RESTDWDatabase;
end;

Procedure TFrmDWSqlEditor.SetFields;
Begin
 If (lbTables.Count > 0) And (lbTables.ItemIndex > -1)  And
    (vLastSelect <> lbTables.Items[lbTables.itemIndex]) Then
  Begin
   vLastSelect  := lbTables.Items[lbTables.itemIndex];
   FThrBancoDados.buscarFieldsNames(vLastSelect);
  End
 Else If (lbTables.Count > 0) And (lbTables.ItemIndex = -1) Then
  lbFields.Items.Clear;
End;

procedure TFrmDWSqlEditor.thrOnFimEvento(Sender: TObject; evento: string;
  lstString: TStringList);
begin
  if evento = 'T' then begin
    lbTables.Items.Text := lstString.Text;
    If lbTables.Count > 0 Then Begin
      SetarControles(True);
      lbTables.ItemIndex := 0;
      SetFields;
    End;
  end
  else if evento = 'F' then begin
    lbFields.Items.Text := lstString.Text;
  end;
end;

procedure TFrmDWSqlEditor.thrOnTerminate(Sender: TObject);
begin
 FThrBancoDados := nil;
end;

procedure TFrmDWSqlEditor.tmCloseTimer(Sender: TObject);
begin
  tmClose.Enabled := False;
  if FThrBancoDados <> nil then
    tmClose.Enabled := True
  else
    Close;
end;

procedure TFrmDWSqlEditor.SetarControles(enab: boolean);
begin
 PnlButton.Enabled         := enab;
 PageControlResult.Enabled := enab;
 pSQLEditor.Enabled        := enab;
end;

Procedure TFrmDWSqlEditor.SetClientSQL(Value: TRESTDWClientSQL);
Begin
 RESTDWClientSQL           := Value;
 vOldSQL                   := '';
 Memo.Lines.Text           := vOldSQL;

 if Assigned(RESTDWClientSQL) then begin
   vOldSQL                   := RESTDWClientSQL.SQL.Text;
   Memo.Lines.Text           := vOldSQL;
 end;
End;

Procedure TFrmDWSqlEditor.SetDatabase(Value : TRESTDWDatabasebaseBase);
Begin
 RESTDWClientSQLB.DataBase := Value;
End;

procedure TFrmDWSqlEditor.lbTablesClick(Sender: TObject);
begin
 SetFields;
end;

procedure TFrmDWSqlEditor.lbTablesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 SetFields;
end;

procedure TFrmDWSqlEditor.MemoDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
 Accept := Source is Tlistbox;
end;

Function TFrmDWSqlEditor.BuildSQL : String;
Var
 I         : Integer;
 vFieldsA,
 vFieldsB  : String;
Begin
 Result   := '';
 vFieldsA := Result;
 vFieldsB := Result;
 If lbTables.itemIndex < 0 Then
  Exit;
 If rbSelect.Checked Then
  Result := Format(cSelect, ['%s', lbTables.Items[lbTables.itemIndex]]);
 If rbInsert.Checked Then
  Result := Format(cInsert, [lbTables.Items[lbTables.itemIndex], '%s', '%s']);
 If rbDelete.Checked Then
  Result := Format(cDelete, [lbTables.Items[lbTables.itemIndex]]);
 If rbUpdate.Checked Then
  Result := Format(cUpdate, [lbTables.Items[lbTables.itemIndex], '%s']);
 If lbFields.SelCount > 0 Then
  Begin
   If rbSelect.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End
   Else If rbInsert.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
       If lbFields.Selected[I] Then
       If vFieldsB = '' Then
        vFieldsB := ':' + lbFields.Items[I]
       Else
        vFieldsB := vFieldsB + ', :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA, vFieldsB]);
    End
   Else If rbUpdate.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I] + ' = :' + lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I] + ' = :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End;
  End
 Else
  Begin
   If rbSelect.Checked Then
    Begin
     Result := Format(Result, ['*'])
    End
   Else If rbInsert.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
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
     Result := Format(Result, [vFieldsA, vFieldsB]);
    End
   Else If rbUpdate.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I] + ' = :' + lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I] + ' = :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End;
  End;
End;

procedure TFrmDWSqlEditor.CarregarTabelas;
begin
  FThrBancoDados.buscarTabelas;
end;

procedure TFrmDWSqlEditor.MemoDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
 If Source = lbTables Then
  If Trim(TMemo(Sender).Lines.Text) = '' Then
   TMemo(Sender).Lines.Text := BuildSQL
  Else
   TMemo(Sender).Lines.Text := TMemo(Sender).Lines.Text + sLineBreak + BuildSQL;
end;

{ TThrBancoDados }

procedure TThrBancoDados.buscarFieldsNames(tabela: string);
begin
  FTipoEvento := 'F';
  FBuscar := tabela;
  FEvent.SetEvent;
end;

procedure TThrBancoDados.buscarTabelas;
begin
  FTipoEvento := 'T';
  FBuscar := '';
  FEvent.SetEvent;
end;

procedure TThrBancoDados.callFimBusca;
var
  vTipo : string;
begin
  vTipo := FTipoEvento;
  FTipoEvento := ''; // limpando para nao cair no while do Execute
  if Assigned(FOnFimEvento) then
    FOnFimEvento(Self,vTipo,FMemString);
end;

constructor TThrBancoDados.Create;
begin
  FRESTDWDatabase := nil;
  FMustDie := False;
  FEvent := TSimpleEvent.Create;
  FMemString := TStringList.Create;
  FreeOnTerminate := True;
  {$IFDEF FPC}
    inherited Create(False);
  {$ELSE}
    inherited Create(False);
  {$ENDIF}
end;

destructor TThrBancoDados.Destroy;
begin
  FMemString.Free;
  FEvent.Free;

  inherited;
end;

procedure TThrBancoDados.Execute;
begin
  while not Terminated do begin
    {$IF (NOT DEFINED(FPC)) AND (CompilerVersion < 21)}
      FEvent.WaitFor($FFFFFFFF);// INFINITE
    {$ELSE}
      FEvent.WaitFor(INFINITE);
    {$IFEND}

    if FMustDie then begin
      Terminate;
      Break;
    end;

    FMemString.Clear;
    try
      if FRESTDWDatabase <> nil then begin
        if FTipoEvento = 'T' then
          FRESTDWDatabase.GetTableNames(FMemString)
        else if FTipoEvento = 'F' then
          FRESTDWDatabase.GetFieldNames(FBuscar,FMemString);
      end;
    except

    end;

    if FMemString.Count > 0 then
      Synchronize({$IFDEF FPC}@{$ENDIF}callFimBusca);

    if FMustDie then begin
      Terminate;
      Break;
    end;
  end;
end;

{$IFDEF FPC}
  procedure TThrBancoDados.TerminatedSet;
  begin
    inherited TerminatedSet;
    DoTerminate;
  end;
{$ENDIF}

procedure TThrBancoDados.threadDie;
begin
  FTipoEvento := '';
  FMustDie := True;
  FEvent.SetEvent;
end;

end.
