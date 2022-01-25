{
 Esta Unit será usada se montar todas as telas do sistema no Dw Core.

Desenvolvida Por  : Fabricio Mata de castro
Empresa : Point informática Ltda - www.pointltda.com.br

}

unit UBasicRO;

interface

uses
  uClasseFindArea, DBGrids, TypInfo,

  JvDBCombobox, JvExStdCtrls, JvExMask, JvEdit, JvToolEdit, JvDBControls, JvBaseEdits,
  JvExControls, JvGradient, Windows,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, DB, ImgList, StdCtrls, Buttons,
  ExtCtrls, UDM, UFuncoes, DBClient, ActnList, JvButton, JvCtrls, ComCtrls, ToolWin,
  JvExComCtrls, JvToolBar, JvCoolBar, JvLabel,
  DBCGrids, DBCtrls, Mask, Grids,  JvCombobox, System.Actions,
  System.ImageList, vcl.dialogs, JvImageList,  JvMemoryDataset, uRESTDWPoolerDB;

type
  TFrmBasic = class(TForm)
    PnlCabecalho: TPanel;
    DSPrincipal: TDataSource;
    ActionList1: TActionList;
    acVerificaReg: TAction;
    acIncluiReg: TAction;
    acEditReg: TAction;
    acGravaReg: TAction;
    acCancelaReg: TAction;
    acExcluiReg: TAction;
    acPesquisaReg: TAction;
    JvToolBar1: TJvToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    LblStatus: TJvLabel;
    acExit: TAction;
    ToolButton8: TToolButton;
    AcFecha: TAction;
    ImgToobar: TJvImageList;
    cdsprincipal: TRESTDWClientSQL;
    EdCodigo: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure acVerificaRegExecute(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
    procedure acIncluiRegExecute(Sender: TObject);
    procedure acEditRegExecute(Sender: TObject);
    procedure acGravaRegExecute(Sender: TObject);
    procedure acCancelaRegExecute(Sender: TObject);
    procedure acExcluiRegExecute(Sender: TObject);
    procedure acPesquisaRegExecute(Sender: TObject);
    procedure ActionList1StateChange(Sender: TObject);
    procedure acExitExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure EdCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure OnComboBoxEnter(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure cdsPrincipalPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure cdsprincipalBeforeOpen(DataSet: TDataSet);
    procedure cdsprincipalNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
    _Tabela, _CampoIndice: string;
    FArea: integer;
    F_Codigo: string;
    procedure SetArea(const Value: integer);
    procedure Set_Codigo(const Value: string);
    function Verifica_Necessario(Destaca: Boolean): Boolean;
    procedure Limpa_Necessario;
    procedure OnJvEditBtnKeyPress(Sender: TObject; var Key: Char);
    procedure Key_Down(Key: Word);
    function Key_Press(Key: Char): Char;

  public
    bPodeFechar, bLocalizado, bSQL_UsePersonal, bVerificado, _Excluido: Boolean;
    _SQL, _CampoLocalizar: string;
    _ExibeResultado: Boolean;
    _VisibleBasic: Boolean;
    _Vcdsprincipal: TRESTDWClientSQL;
    property Area: integer read FArea write SetArea;
    property _Codigo: string read F_Codigo write Set_Codigo;
  end;

var
  FrmBasic: TFrmBasic;

implementation

uses
  UPrincipal, UFindArea;
{$R *.dfm}

procedure TFrmBasic.FormActivate(Sender: TObject);
var
  i: integer;
begin

  if EdCodigo.Enabled then
  begin
    if _VisibleBasic then
      EdCodigo.SetFocus;

  end;
  // Top := 0;
  Limpa_Necessario;

  // Desabilitando os botoes dos LocalizarFK.
  for i := 0 to ComponentCount - 1 do
  begin
    if (Components[i] is TJvDBComboBox) then
      (Components[i] as TJvDBComboBox).OnEnter := OnComboBoxEnter;
    if (Components[i] is TDBComboBox) then
      (Components[i] as TDBComboBox).OnEnter := OnComboBoxEnter;

    // Forçando a todos os Edits e controles, a ter o CharCase maiúsculo.
    if IsPublishedProp(Components[i], 'CharCase') then
      SetPropValue(Components[i], 'CharCase', ecUpperCase);
    if Components[i].Tag = 10 then
      SetPropValue(Components[i], 'CharCase', ecNormal);

    if (Components[i] is TJvDBComboEdit) then
    begin
      (Components[i] as TJvDBComboEdit).Button.Enabled := ((cdsprincipal.State in [dsInsert, dsEdit]) and cdsprincipal.Active);
      (Components[i] as TJvDBComboEdit).Images := ImgToobar;
      (Components[i] as TJvDBComboEdit).ImageIndex := 22;

      (Components[i] as TJvDBComboEdit).OnKeyPress := OnJvEditBtnKeyPress;
    end;

    if (Components[i] is TJvDBCalcEdit) then
    begin
      (Components[i] as TJvDBCalcEdit).DecimalPlaces := 2;
      (Components[i] as TJvDBCalcEdit).DisplayFormat := '#,0.00';
    end;

    if (Components[i] is TJvComboEdit) then
    begin
      (Components[i] as TJvComboEdit).Button.Enabled := ((cdsprincipal.State in [dsInsert, dsEdit]) and cdsprincipal.Active);
      (Components[i] as TJvComboEdit).OnKeyPress := OnJvEditBtnKeyPress;
    end;

    if (Components[i] is TDBGrid) then
    begin
      if (Components[i] as TDBGrid).Tag = 0 then
      begin

        if (DSPrincipal.State in [dsInsert, dsEdit]) then
          (Components[i] as TDBGrid).Options := (Components[i] as TDBGrid).Options + [vcl.DBGrids.TDBGridOption.dgEditing,
            vcl.DBGrids.TDBGridOption.dgConfirmDelete, vcl.DBGrids.TDBGridOption.dgCancelOnExit];

      end;
    end;

//    if (Components[i] is TcxGridDBTableView) then
//    begin
//      if (Components[i] as TcxGridDBTableView).Tag = 0 then
//      begin
//        (Components[i] as TcxGridDBTableView).OptionsData.Appending := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        (Components[i] as TcxGridDBTableView).OptionsData.Deleting := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        (Components[i] as TcxGridDBTableView).OptionsData.Editing := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        (Components[i] as TcxGridDBTableView).OptionsData.Inserting := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        // (Components[i] as TcxGridDBTableView).Styles.ContentEven := DM.stEven;
//        // (Components[i] as TcxGridDBTableView).Styles.ContentOdd := DM.stOdd;
//      end;
//    end;
//
//    if (Components[i] is TcxGridDBBandedTableView) then
//    begin
//      if (Components[i] as TcxGridDBBandedTableView).Tag = 0 then
//      begin
//        (Components[i] as TcxGridDBBandedTableView).OptionsData.Appending := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        (Components[i] as TcxGridDBBandedTableView).OptionsData.Deleting := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        (Components[i] as TcxGridDBBandedTableView).OptionsData.Editing := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        (Components[i] as TcxGridDBBandedTableView).OptionsData.Inserting := ((DSPrincipal.State in [dsInsert, dsEdit]));
//        (Components[i] as TcxGridDBBandedTableView).Styles.ContentEven := dm.stEven;
//        (Components[i] as TcxGridDBBandedTableView).Styles.ContentOdd := dm.stOdd;
//      end;
//    end;

  end;

end;

procedure TFrmBasic.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Key_Down(Key);
end;

procedure TFrmBasic.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Key_Press(Key);
end;

procedure TFrmBasic.Key_Down(Key: Word);
begin
  if Key in [VK_RETURN, VK_DELETE, VK_F8] then
  begin
    with Screen.ActiveForm do
    begin
      if (Key = VK_F8) then
      begin
        if ((FindComponent('acPesquisaReg') <> nil) and (TAction(FindComponent('acPesquisaReg')).Enabled)) then
          TAction(FindComponent('acPesquisaReg')).Execute
        else
        begin
          if ((FindComponent('acPesquisaReg') <> nil) and (not TAction(FindComponent('acPesquisaReg')).Enabled)) then
          begin
            // Se for do tipo de Item com Botao, clico no botão.
            if Screen.ActiveControl is TJvComboEdit then
              (Screen.ActiveControl as TJvComboEdit).Button.Click;
            if Screen.ActiveControl is TJvDBComboEdit then
              (Screen.ActiveControl as TJvDBComboEdit).Button.Click;
          end
          else
          begin
            // Se for do tipo de Item com Botao, clico no botão.
            if Screen.ActiveControl is TJvComboEdit then
              (Screen.ActiveControl as TJvComboEdit).Button.Click;
            if Screen.ActiveControl is TJvDBComboEdit then
              (Screen.ActiveControl as TJvDBComboEdit).Button.Click;
          end;
        end;
      end;

      if (Key = VK_DELETE) and ((FindComponent('acGravaReg') <> nil) and (TAction(FindComponent('acGravaReg')).Enabled)) then
      begin
        if (Screen.ActiveControl is TDBGrid) then
        begin
          if (not((Screen.ActiveControl as TDBGrid).DataSource.State in [dsInsert, dsEdit])) and
            ((Screen.ActiveControl as TDBGrid).DataSource.DataSet.RecordCount > 0) and ((Screen.ActiveControl as TDBGrid).DataSource.Tag = 0)
          then
          begin
            if Application.MessageBox('Deseja Realmente Excluir este Registro?', 'FPI', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1 +
              MB_APPLMODAL) = ID_YES then
              (Screen.ActiveControl as TDBGrid).DataSource.DataSet.Delete;
          end;
        end;
      end;
    end;
  end;

end;

function TFrmBasic.Key_Press(Key: Char): Char;
begin
  Result := #0;
  with Screen.ActiveForm do
  begin
    Key := AnsiUpperCase(Key)[Length(Key)];

    if (not Assigned(ActiveControl)) or (ActiveControl = nil) then
      Exit;

    if (Key = #13) then
    begin
      if (ActiveControl is TJvComboEdit) then
      begin
        if (ActiveControl as TJvComboEdit).Button.Enabled then
        begin
          (ActiveControl as TJvComboEdit).Button.Click;
          try
            GetParentForm(Screen.ActiveForm).Perform(CM_DIALOGKEY, VK_TAB, 0);
          except
          end;
        end;
      end
      else
      begin
        if (ActiveControl is TJvDBComboEdit) then
        begin
          if (ActiveControl as TJvDBComboEdit).Button.Enabled then
          begin
            (ActiveControl as TJvDBComboEdit).Button.Click;
            try
              GetParentForm(Screen.ActiveForm).Perform(CM_DIALOGKEY, VK_TAB, 0);
            except
            end;
          end;
        end
        else
        begin
          try
            if ActiveControl.CanFocus then
              GetParentForm(Screen.ActiveForm).Perform(CM_DIALOGKEY, VK_TAB, 0);
          except
          end;
        end;
      end;
    end
    else if (Key = #27) and (Screen.ActiveForm <> nil) then
    begin

      begin
        try
          if (FindComponent('acCancelaReg') <> nil) and (TAction(FindComponent('acCancelaReg')).Enabled) then
            TAction(FindComponent('acCancelaReg')).Execute
          else
            Close;
        except
        end;
      end;
    end
    else
      Result := Key;
  end;
end;

procedure TFrmBasic.Limpa_Necessario;
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if (Components[i].Tag = 2) and (Components[i] is TWinControl) and ((Components[i] as TWinControl).Enabled) then
    begin
      if (Components[i] is TDBEdit) then
      begin
        (Components[i] as TDBEdit).Color := cCorFundoNecessario;
        (Components[i] as TDBEdit).Font.Color := StringToColor(cCorTextoNecessario);
      end;
      if (Components[i] is TEdit) then
      begin
        (Components[i] as TEdit).Color := cCorFundoNecessario;
        (Components[i] as TEdit).Font.Color := StringToColor(cCorTextoNecessario);
      end;
      if (Components[i] is TDBComboBox) then
      begin
        (Components[i] as TDBComboBox).Color := cCorFundoNecessario;
        (Components[i] as TDBComboBox).Font.Color := StringToColor(cCorTextoNecessario);
      end;

      if (Components[i] is TJvDBComboBox) then
      begin
        (Components[i] as TJvDBComboBox).Color := cCorFundoNecessario;
        (Components[i] as TJvDBComboBox).Font.Color := StringToColor(cCorTextoNecessario);
      end;

      if (Components[i] is TJvDBComboEdit) then
      begin
        (Components[i] as TJvDBComboEdit).Color := cCorFundoNecessario;
        (Components[i] as TJvDBComboEdit).Font.Color := StringToColor(cCorTextoNecessario);
      end;

      if (Components[i] is TJvDBDateEdit) then
      begin
        (Components[i] as TJvDBDateEdit).Color := cCorFundoNecessario;
        (Components[i] as TJvDBDateEdit).Font.Color := StringToColor(cCorTextoNecessario);
      end;

      if (Components[i] is TJvDBCalcEdit) then
      begin
        (Components[i] as TJvDBCalcEdit).Color := cCorFundoNecessario;
        (Components[i] as TJvDBCalcEdit).Font.Color := StringToColor(cCorTextoNecessario);
      end;

      if (Components[i] is TCombobox) then
      begin
        (Components[i] as TCombobox).Color := cCorFundoNecessario;
        (Components[i] as TCombobox).Font.Color := StringToColor(cCorTextoNecessario);
      end;
    end;
  end;

end;

procedure TFrmBasic.OnComboBoxEnter(Sender: TObject);
begin
  if (Sender is TJvDBComboBox) then
    (Sender as TJvDBComboBox).DroppedDown := True;
  if (Sender is TDBComboBox) then
    (Sender as TDBComboBox).DroppedDown := True;
end;

procedure TFrmBasic.OnJvEditBtnKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0' .. '9', '.', #13, #27, #83, #8]) then
    Key := #0;
end;

procedure TFrmBasic.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
  LComponent: TComponent;
begin

  Release;
//  try
//    for i := 0 to ComponentCount - 1 do
//    begin
//
//      if (Components[i] is TcxGrid) then
//      begin
//        if Assigned((Components[i] as TcxGrid)) then
//        begin
//          LComponent := (Components[i] as TcxGrid);
//
//          FreeAndNil(LComponent);
//        end;
//
//      end;
//
//    end;
//  except
//
//  end;

end;

procedure TFrmBasic.FormCreate(Sender: TObject);

begin
  LblStatus.Caption := EmptyStr;
  bPodeFechar := True;
  bVerificado := False;
  _ExibeResultado := False;
  _SQL := EmptyStr;
  _CampoLocalizar := EmptyStr;

  _VisibleBasic := True;

  Left := (Screen.Width div 2) - (Width div 2);
  Top := 0;

end;

procedure TFrmBasic.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (DSPrincipal.DataSet.State in [dsEdit, dsInsert]) then
  begin
    Application.MessageBox('Existe um registro em edição no momento. É necessário' + #13#10 + 'que você Grave ou Cancele o registro.',
      PChar(Application.Title), MB_OK + MB_ICONWARNING);
    CanClose := False;
  end
  else
    CanClose := bPodeFechar;
end;

procedure TFrmBasic.BtnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmBasic.cdsprincipalBeforeOpen(DataSet: TDataSet);
begin
  if cdsprincipal.Params.FindParam('PEMPRESA') <> nil then
    cdsprincipal.Params.ParamByName('PEMPRESA').AsString := Funcoes.GetIDEmpresa(False);
  if cdsprincipal.Params.FindParam('PSYS_POINT_CLIENTE') <> nil then
    cdsprincipal.Params.ParamByName('PSYS_POINT_CLIENTE').AsString := Funcoes.GetIDPointCliente(False);
  if cdsprincipal.Params.FindParam('PIDEMPRESA') <> nil then
    cdsprincipal.Params.ParamByName('PIDEMPRESA').AsString := Funcoes.GetIDEmpresa(False);
  if cdsprincipal.Params.FindParam('PIDSYS_POINT_CLIENTE') <> nil then
    cdsprincipal.Params.ParamByName('PIDSYS_POINT_CLIENTE').AsString := Funcoes.GetIDPointCliente(False);
end;

procedure TFrmBasic.cdsprincipalNewRecord(DataSet: TDataSet);
begin
  if cdsprincipal.Fields.FindField('IDEMPRESA') <> nil then
    cdsprincipal.FieldByName('IDEMPRESA').AsString := Funcoes.GetIDEmpresa(False);
  if cdsprincipal.Fields.FindField('IDSYS_POINT_CLIENTE') <> nil then
    cdsprincipal.FieldByName('IDSYS_POINT_CLIENTE').AsString := Funcoes.GetIDPointCliente(False);
  cdsprincipal.FieldByName(_CampoIndice).AsInteger := Funcoes.Retorna_id(_Tabela, _CampoIndice  );
  _Codigo := cdsprincipal.FieldByName(_CampoIndice).AsString;
end;

procedure TFrmBasic.cdsPrincipalPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Application.MessageBox(PChar(Format('Erro ao gravar:' + #13#10#13#10 + '%s', [E.Message])), PChar(Application.Title),
    MB_OK + MB_ICONWARNING);
end;

procedure TFrmBasic.EdCodigoKeyPress(Sender: TObject; var Key: Char);
begin
  if Length(EdCodigo.Text) > 9 then
    Key := #0;
  if not(CharInSet(Key, ['0' .. '9', #13, #27, #37, #38, #39, #40, #46, #110, #8])) then
    Key := #0;

  if (Key = #13) and (EdCodigo.Text <> '') then
  begin
    _Codigo := EdCodigo.Text;
    acVerificaReg.Execute;
  end;
end;

procedure TFrmBasic.acCancelaRegExecute(Sender: TObject);
var
  i: integer;
begin
  Screen.Cursor := crHourGlass;
  try

    if cdsprincipal.State in [dsInsert] then
      Funcoes.Retorna_id(_Tabela, _CampoIndice, 1, StrToInt(EdCodigo.Text));

    cdsprincipal.Cancel;

    cdsprincipal.Close;

    LblStatus.Caption := '';
    DSPrincipal.Enabled := True;

    Limpa_Necessario;

    for i := 0 to ComponentCount - 1 do
    begin
      if (Components[i] is TDBGrid) and ((Components[i] as TDBGrid).Tag = 0) then
        (Components[i] as TDBGrid).ReadOnly := True;

      if (Components[i] is TJvDBComboEdit) then
        (Components[i] as TJvDBComboEdit).ReadOnly := True;

      if (Components[i] is TJvDBComboBox) then
        (Components[i] as TJvDBComboBox).Enabled := False;

      { Desabilitando os botoes dos LocalizarFK. }
      if (Components[i] is TJvDBComboEdit) then
        (Components[i] as TJvDBComboEdit).Button.Enabled := False;

      if (Components[i] is TJvComboEdit) then
        (Components[i] as TJvComboEdit).Button.Enabled := False;

//      if (Components[i] is TcxGridDBTableView) then
//      begin
//        if (Components[i] as TcxGridDBTableView).Tag = 0 then
//        begin
//          (Components[i] as TcxGridDBTableView).OptionsData.Appending := False;
//          (Components[i] as TcxGridDBTableView).OptionsData.Deleting := False;
//          (Components[i] as TcxGridDBTableView).OptionsData.Editing := False;
//          (Components[i] as TcxGridDBTableView).OptionsData.Inserting := False;
//        end;
//      end;
//
//      if (Components[i] is TcxGridDBBandedTableView) then
//      begin
//        if (Components[i] as TcxGridDBBandedTableView).Tag = 0 then
//        begin
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Appending := False;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Deleting := False;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Editing := False;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Inserting := False;
//        end;
//      end;
//
    end;

    Funcoes.AddLog('Cancelar ', Caption, 'Cancela edição/update Registro: ' + EdCodigo.Text);

    EdCodigo.Text := EmptyStr;
    if EdCodigo.Enabled then
    begin
      if _VisibleBasic then
        EdCodigo.SetFocus;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

end;

procedure TFrmBasic.acEditRegExecute(Sender: TObject);
var
  i: integer;
begin

  Screen.Cursor := crHourGlass;
  try
    cdsprincipal.Edit;
    DSPrincipal.Enabled := True;
    LblStatus.Caption := '   Editando . . .';

    for i := 0 to ComponentCount - 1 do
    begin
      if (Components[i] is TDBGrid) and ((Components[i] as TDBGrid).Tag = 0) then
        (Components[i] as TDBGrid).ReadOnly := False;

      if (Components[i] is TJvDBComboEdit) then
        (Components[i] as TJvDBComboEdit).ReadOnly := False;

      if (Components[i] is TJvDBComboBox) then
        (Components[i] as TJvDBComboBox).Enabled := True;

      if (Components[i] is TJvDBComboEdit) then
        (Components[i] as TJvDBComboEdit).Button.Enabled := True;

      if (Components[i] is TJvComboEdit) then
        (Components[i] as TJvComboEdit).Button.Enabled := True;

//      if (Components[i] is TcxGridDBTableView) then
//      begin
//        if (Components[i] as TcxGridDBTableView).Tag = 0 then
//        begin
//          (Components[i] as TcxGridDBTableView).OptionsData.Appending := True;
//          (Components[i] as TcxGridDBTableView).OptionsData.Deleting := True;
//          (Components[i] as TcxGridDBTableView).OptionsData.Editing := True;
//          (Components[i] as TcxGridDBTableView).OptionsData.Inserting := True;
//        end;
//      end;
//
//      if (Components[i] is TcxGridDBBandedTableView) then
//      begin
//        if (Components[i] as TcxGridDBBandedTableView).Tag = 0 then
//        begin
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Appending := True;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Deleting := True;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Editing := True;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Inserting := True;
//        end;
//      end;

    end;
    // EdCodigo.Text := EmptyStr;
    if EdCodigo.Enabled then
    begin
      if _VisibleBasic then
        EdCodigo.SetFocus;

    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmBasic.acExcluiRegExecute(Sender: TObject);
var
  i: integer;
  TempArea: TAreaCollectionItem;
  _vsql : string;
begin

  if Application.MessageBox('Deseja excluir este registro?', 'DWerp', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1 + MB_APPLMODAL) = ID_YES
  then
  begin
    Screen.Cursor := crHourGlass;

    try

      { Desabilitando os botoes dos LocalizarFK. }
      for i := 0 to ComponentCount - 1 do
      begin
        if (Components[i] is TJvDBComboEdit) then
          (Components[i] as TJvDBComboEdit).Button.Enabled := False;

        if (Components[i] is TJvComboEdit) then
          (Components[i] as TJvComboEdit).Button.Enabled := False;

//        if (Components[i] is TcxGridDBTableView) then
//        begin
//          if (Components[i] as TcxGridDBTableView).Tag = 0 then
//          begin
//            (Components[i] as TcxGridDBTableView).OptionsData.Appending := False;
//            (Components[i] as TcxGridDBTableView).OptionsData.Deleting := False;
//            (Components[i] as TcxGridDBTableView).OptionsData.Editing := False;
//            (Components[i] as TcxGridDBTableView).OptionsData.Inserting := False;
//          end;
//        end;
//
//        if (Components[i] is TcxGridDBBandedTableView) then
//        begin
//          if (Components[i] as TcxGridDBBandedTableView).Tag = 0 then
//          begin
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Appending := False;
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Deleting := False;
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Editing := False;
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Inserting := False;
//          end;
//        end;
      end;
      TempArea := FindArea.GetArea(Area);
      _vsql := 'delete from ' +TempArea.Tabela +' where ( id'+TempArea.Tabela +' = ' + EdCodigo.text + ' ) ';
      if cdsprincipal.Fields.FindField('IDEMPRESA') <> nil then
        _vsql := _vsql + 'and ( idempresa = '+ funcoes.GetIDEmpresa +  ' )';
      if cdsprincipal.Fields.FindField('IDSYS_POINT_CLIENTE') <> nil then
         _vsql := _vsql + 'and ( IDSYS_POINT_CLIENTE =' + funcoes.GetIDPointCliente+' )';


      funcoes.RunSql(_vsql );

      cdsprincipal.Close;

      EdCodigo.Text := EmptyStr;


      Funcoes.AddLog('Exclui ', Caption, 'Exlui Registro: ' + EdCodigo.Text);

      LblStatus.Caption := EmptyStr;
      DSPrincipal.Enabled := False;
      if _VisibleBasic then
        PnlCabecalho.SetFocus;

      _Excluido := True;
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else
    _Excluido := False;
end;

procedure TFrmBasic.acExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFrmBasic.acGravaRegExecute(Sender: TObject);
var
  i: integer;
Vresultado : string;
begin

  Screen.Cursor := crHourGlass;
  try

    if not Verifica_Necessario(True) then
    begin
      Limpa_Necessario;

      { Desabilitando os botoes dos LocalizarFK. }
      for i := 0 to ComponentCount - 1 do
      begin
        if (Components[i] is TClientDataSet) then
          if (Components[i] as TClientDataSet).State in [dsInsert, dsEdit] then
            (Components[i] as TClientDataSet).UpdateRecord;

        if (Components[i] is TJvDBComboEdit) then
          (Components[i] as TJvDBComboEdit).Button.Enabled := False;

        if (Components[i] is TJvComboEdit) then
          (Components[i] as TJvComboEdit).Button.Enabled := False;

        if (Components[i] is TJvDBComboBox) then
          (Components[i] as TJvDBComboBox).Enabled := False;

//        if (Components[i] is TcxGridDBTableView) then
//        begin
//          if (Components[i] as TcxGridDBTableView).Tag = 0 then
//          begin
//            (Components[i] as TcxGridDBTableView).OptionsData.Appending := False;
//            (Components[i] as TcxGridDBTableView).OptionsData.Deleting := False;
//            (Components[i] as TcxGridDBTableView).OptionsData.Editing := False;
//            (Components[i] as TcxGridDBTableView).OptionsData.Inserting := False;
//          end;
//        end;
//
//        if (Components[i] is TcxGridDBBandedTableView) then
//        begin
//          if (Components[i] as TcxGridDBBandedTableView).Tag = 0 then
//          begin
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Appending := False;
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Deleting := False;
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Editing := False;
//            (Components[i] as TcxGridDBBandedTableView).OptionsData.Inserting := False;
//          end;
//        end;

      end;

      { Se Tag do transaction for <> 0 não commita }
      if cdsprincipal.Tag = 0 then
      begin
        if (cdsprincipal.State in [dsEdit, dsInsert]) then
          cdsprincipal.Post;


          Funcoes.ApplayUpdates([cdsprincipal], vresultado);

          if Vresultado <> 'OK' then
          begin
            Application.MessageBox(PChar(Format('Ocorreu erro na operação : %s',
              [vresultado])), PChar(Application.Title), MB_OK + MB_ICONWARNING);
            abort;
          end;

          cdsprincipal.Close;

        Funcoes.AddLog('Gravando ', Caption, 'Gravando Registro: ' + EdCodigo.Text);

      end;

      LblStatus.Caption := EmptyStr;
      if _VisibleBasic then
        PnlCabecalho.SetFocus;

      Limpa_Necessario;

      bVerificado := True;
      EdCodigo.Text := EmptyStr;
      if EdCodigo.Enabled then
      begin
        if _VisibleBasic then
          EdCodigo.SetFocus;

      end;
    end
    else
    begin
      bVerificado := False;
      abort;
    end;

  finally

    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmBasic.acIncluiRegExecute(Sender: TObject);
var
  i: integer;
begin
  if AnsiSameText(Funcoes.GetConfig('usa_nfe', 'N'), 'S') and (Funcoes.GetConfig('NFE_LIBERAINCLUSAOFISCAL', 'S') = 'N') then
  begin
    Application.MessageBox('Não é permitido incluir.' + #13#10 + ' Por favor entre em contato com administrador.', PChar(Application.Title),
      MB_OK + MB_ICONINFORMATION);
    abort;

  end;

  Screen.Cursor := crHourGlass;
  try
    if not cdsprincipal.Active then
      cdsprincipal.Open;

    cdsprincipal.Append;

    LblStatus.Caption := '   Inserindo . . .';

    DSPrincipal.Enabled := True;

    for i := 0 to ComponentCount - 1 do
    begin
      if (Components[i] is TDBGrid) and ((Components[i] as TDBGrid).Tag = 0) then
        (Components[i] as TDBGrid).ReadOnly := False;

      if (Components[i] is TJvDBComboEdit) then
        (Components[i] as TJvDBComboEdit).ReadOnly := False;

      if (Components[i] is TJvDBComboBox) then
        (Components[i] as TJvDBComboBox).Enabled := True;

      { Habilitando os botoes dos LocalizarFK. }
      if (Components[i] is TJvDBComboEdit) then
        (Components[i] as TJvDBComboEdit).Button.Enabled := True;

      if (Components[i] is TJvComboEdit) then
        (Components[i] as TJvComboEdit).Button.Enabled := True;

//      if (Components[i] is TcxGridDBTableView) then
//      begin
//        if (Components[i] as TcxGridDBTableView).Tag = 0 then
//        begin
//          (Components[i] as TcxGridDBTableView).OptionsData.Appending := True;
//          (Components[i] as TcxGridDBTableView).OptionsData.Deleting := True;
//          (Components[i] as TcxGridDBTableView).OptionsData.Editing := True;
//          (Components[i] as TcxGridDBTableView).OptionsData.Inserting := True;
//        end;
//      end;
//
//      if (Components[i] is TcxGridDBBandedTableView) then
//      begin
//        if (Components[i] as TcxGridDBBandedTableView).Tag = 0 then
//        begin
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Appending := True;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Deleting := True;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Editing := True;
//          (Components[i] as TcxGridDBBandedTableView).OptionsData.Inserting := True;
//        end;
//      end;

    end;

    Funcoes.AddLog('Incluindo', Caption, 'Incluindo Registro: ' + EdCodigo.Text);

  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmBasic.acPesquisaRegExecute(Sender: TObject);
var
  TempArea: TAreaCollectionItem;
begin

  TempArea := FindArea.GetArea(Area);

  if Funcoes.Localizar(Area, _SQL, _CampoLocalizar, '', _ExibeResultado) then
  begin
    _Codigo := dm.cdsLocalizar.FieldByName(TempArea.CampoIndice).AsString;
    acVerificaReg.Execute;
    bLocalizado := True;
  end
  else
    bLocalizado := False;

end;

procedure TFrmBasic.ActionList1StateChange(Sender: TObject);
begin
  acIncluiReg.Enabled := (DSPrincipal.DataSet.State = dsInactive);
  acEditReg.Enabled := (DSPrincipal.DataSet.State = dsBrowse);
  acGravaReg.Enabled := (DSPrincipal.DataSet.State in [dsEdit, dsInsert]);
  acCancelaReg.Enabled := (DSPrincipal.DataSet.State in [dsBrowse, dsEdit, dsInsert]);
  acExcluiReg.Enabled := (DSPrincipal.DataSet.State in [dsBrowse, dsEdit]);
  acPesquisaReg.Enabled := (DSPrincipal.DataSet.State = dsInactive);
end;

procedure TFrmBasic.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acIncluiReg.Enabled := (DSPrincipal.DataSet.State = dsInactive);
  acEditReg.Enabled := (DSPrincipal.DataSet.State = dsBrowse);
  acGravaReg.Enabled := (DSPrincipal.DataSet.State in [dsEdit, dsInsert]);
  acCancelaReg.Enabled := (DSPrincipal.DataSet.State in [dsBrowse, dsEdit, dsInsert]);
  acExcluiReg.Enabled := (DSPrincipal.DataSet.State = dsBrowse);
  acPesquisaReg.Enabled := (DSPrincipal.DataSet.State = dsInactive);
  EdCodigo.Enabled := (DSPrincipal.DataSet.State in [dsInactive, dsBrowse]);
end;

procedure TFrmBasic.acVerificaRegExecute(Sender: TObject);
var
  i: integer;
begin
  Screen.Cursor := crHourGlass;
  try
    if Funcoes.Empty(_Codigo) then
      Exit;

    if cdsprincipal.Active then
      cdsprincipal.Close;

    cdsprincipal.Params.ParamByName('PCODIGO').AsString := _Codigo;
    cdsprincipal.Open;
    cdsprincipal.Close;
    cdsprincipal.Open;

    if cdsprincipal.IsEmpty then
    begin
      cdsprincipal.Close;
      _Codigo := EmptyStr;
      Application.MessageBox('Não existe nenhum registro com esta condição.', PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
      bLocalizado := False;
    end
    else
    begin
      LblStatus.Caption := '   Visualizando...';
      DSPrincipal.Enabled := True;
      _Codigo := cdsprincipal.FieldByName(_CampoIndice).AsString;

      for i := 0 to ComponentCount - 1 do
      begin
        if (Components[i] is TDBGrid) and ((Components[i] as TDBGrid).Tag = 0) then
          (Components[i] as TDBGrid).ReadOnly := True;

        if (Components[i] is TJvDBComboEdit) then
          (Components[i] as TJvDBComboEdit).ReadOnly := True;

        if (Components[i] is TJvDBComboBox) then
          (Components[i] as TJvDBComboBox).Enabled := True;
      end;

      bLocalizado := True;
      Funcoes.AddLog('Vizualização', Caption, 'Visualizando Registro: ' + EdCodigo.Text);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmBasic.SetArea(const Value: integer);
var
  TempArea: TAreaCollectionItem;
begin
  FArea := Value;
  TempArea := FindArea.GetArea(Area);
  _CampoIndice := TempArea.GetFieldName(TempArea.CampoIndice);
  _Tabela := TempArea.Tabela;
end;

procedure TFrmBasic.Set_Codigo(const Value: string);
begin
  F_Codigo := Value;
  EdCodigo.Text := Value;
end;

function TFrmBasic.Verifica_Necessario(Destaca: Boolean): Boolean;
var
  i, campoFoco: integer;
begin
  Result := False;
  campoFoco := -1;

  if (Destaca = True) and (_VisibleBasic = True) then
  begin
    // with Screen.ActiveForm do
    begin
      for i := 0 to ComponentCount - 1 do
      begin
        if ((Components[i].Tag > 0) and (Components[i].Tag < 9)) and (Components[i] is TWinControl) and
          ((Components[i] as TWinControl).Enabled) then
        begin
          if campoFoco = -1 then
            campoFoco := i;
          if Components[i].Tag = 2 then
            Components[i].Tag := 1;
          if (Components[i] is TDBEdit) then
          begin
            if ((Components[i] as TDBEdit).Field.IsNull) or (trim((Components[i] as TDBEdit).Field.Text) = EmptyStr) then
            begin
              (Components[i] as TDBEdit).Tag := 2;
              (Components[i] as TDBEdit).Color := cCorFundoRequerido;
              (Components[i] as TDBEdit).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
          if (Components[i] is TEdit) then
          begin
            if (Components[i] as TEdit).Text = '' then
            begin
              (Components[i] as TEdit).Tag := 2;
              (Components[i] as TEdit).Color := cCorFundoRequerido;
              (Components[i] as TEdit).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
          if (Components[i] is TDBComboBox) then
          begin
            if (Components[i] as TDBComboBox).Field.IsNull then
            begin
              (Components[i] as TDBComboBox).Tag := 2;
              (Components[i] as TDBComboBox).Color := cCorFundoRequerido;
              (Components[i] as TDBComboBox).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
          if (Components[i] is TCombobox) then
          begin
            if (Components[i] as TCombobox).Text = '' then
            begin
              (Components[i] as TCombobox).Tag := 2;
              (Components[i] as TCombobox).Color := cCorFundoRequerido;
              (Components[i] as TCombobox).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
          if (Components[i] is TJvDBComboBox) then
          begin
            if (Components[i] as TJvDBComboBox).Text = '' then
            begin
              (Components[i] as TJvDBComboBox).Tag := 2;
              (Components[i] as TJvDBComboBox).Color := cCorFundoRequerido;
              (Components[i] as TJvDBComboBox).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
          if (Components[i] is TJvDBComboEdit) then
          begin
            if (Components[i] as TJvDBComboEdit).Text = '' then
            begin
              (Components[i] as TJvDBComboEdit).Tag := 2;
              (Components[i] as TJvDBComboEdit).Color := cCorFundoRequerido;
              (Components[i] as TJvDBComboEdit).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
          if (Components[i] is TJvDBDateEdit) then
          begin

            if ((Components[i] as TJvDBDateEdit).Field.IsNull) then
            begin
              (Components[i] as TJvDBDateEdit).Tag := 2;
              (Components[i] as TJvDBDateEdit).Color := cCorFundoRequerido;
              (Components[i] as TJvDBDateEdit).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
          if (Components[i] is TJvDBCalcEdit) then
          begin
            if (Components[i] as TJvDBCalcEdit).Text = '' then
            begin
              (Components[i] as TJvDBCalcEdit).Tag := 2;
              (Components[i] as TJvDBCalcEdit).Color := cCorFundoRequerido;
              (Components[i] as TJvDBCalcEdit).Font.Color := cCorTextoRequerido;
              Result := True;
            end;
          end;
        end;
      end;
    end;
  end
  else
  begin
    // with Screen.ActiveForm do
    begin
      for i := 0 to ComponentCount - 1 do
      begin
        if (Components[i].Tag = 2) then
          (Components[i]).Tag := 1;
      end;
    end;
    // Screen.ActiveForm.Refresh;
  end;
  if Result = True then
  begin
    Application.MessageBox('Os campos em Vermelho são de preenchimento Obrigatório.', 'Sistema',
      MB_OK + MB_ICONHAND + MB_DEFBUTTON1 + MB_APPLMODAL);
  end;
end;

end.
