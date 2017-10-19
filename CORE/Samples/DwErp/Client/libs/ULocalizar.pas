{
 Tela de localizar unica para todo o sistema
 para ser usado no Dw Core.

Desenvolvida Por  : Fabricio Mata de castro
Empresa : Point informática Ltda - www.pointltda.com.br

}


unit ULocalizar;

interface

uses
  uFindArea, uClasseFindArea, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Mask, ExtCtrls, DB, Grids, DBGrids, DBClient, JvExMask,
  JvToolEdit, JvBaseEdits,

  uRESTDWPoolerDB, JvExStdCtrls, JvMemo;

type
  TFrmLocalizar = class(TForm)
    PnlTitulo: TPanel;
    PnlCabecalho: TPanel;
    Label1: TLabel;
    LblCampoIndice: TLabel;
    cbOperador: TComboBox;
    EdLocalizar: TMaskEdit;
    BtnLocalizar: TBitBtn;
    pnlStatus: TPanel;
    GridLocalizar: TDBGrid;
    dsLocalizar: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel;
    Label2: TLabel;
    Panel3: TPanel;
    Label3: TLabel;
    Panel4: TPanel;
    Label4: TLabel;
    Panel5: TPanel;
    Label5: TLabel;
    EdlocalizarVlr: TJvCalcEdit;
    Panel6: TPanel;
    Label6: TLabel;
    LblSysSQL: TLabel;
    Panel7: TPanel;
    Label7: TLabel;
    Panel8: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    Panel9: TPanel;
    Chekit: TCheckBox;
    SQLMemo: TJvMemo;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbOperadorChange(Sender: TObject);
    procedure BtnLocalizarClick(Sender: TObject);
    procedure GridLocalizarTitleClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure GridLocalizarDblClick(Sender: TObject);
    procedure GridLocalizarKeyPress(Sender: TObject; var Key: Char);
    procedure GridLocalizarDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure EdLocalizarKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ChekitClick(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label9Click(Sender: TObject);
  private
    { Private declarations }
    procedure MontaOperador(vNomeCampo: string);
    procedure MontaColunas;
    procedure PintaCampoIndice;
    procedure OncdsLocalizarBeforeOpen(DataSet: TDataSet);
    function MontaSQL: string;
    function RetornaIdxCampo(ANomeCampo: string): Integer;
  public
    LastForm: TForm;
    ExibeResultado: Boolean;
    CurrentArea: TAreaCollectionItem;
    _vpodepesq: string;
  end;

var
  FrmLocalizar: TFrmLocalizar;

implementation

uses
  UFuncoes, uDM;

{$R *.dfm}

procedure TFrmLocalizar.BtnLocalizarClick(Sender: TObject);
var
  TimeInicio, TimeFim: TTime;
begin
  try

    // cdsEmpresa.Close;
    // cdsEmpresa.open;
    // cdsEmpresa.Close;

    BtnLocalizar.Enabled := false;

    if EdLocalizar.Visible and (not Funcoes.MaquinaDesenvolvedor) then
    begin

      if (not CurrentArea.PermitePesqBranco) and (Trim(EdLocalizar.Text) = EmptyStr) then
      begin
        Application.MessageBox('É necessário que você digite algo para pesquisar.', PChar(Application.Title), MB_OK + MB_ICONWARNING);
        exit;
      end;

    end;

    if EdlocalizarVlr.Visible and (not Funcoes.MaquinaDesenvolvedor) then
    begin

      if (not CurrentArea.PermitePesqBranco) and (Trim(EdlocalizarVlr.Text) = EmptyStr) then
      begin
        Application.MessageBox('É necessário que você digite algo para pesquisar.', PChar(Application.Title), MB_OK + MB_ICONWARNING);
        exit;
      end;

    end;

    if _vpodepesq = 'N' then
      exit;

    _vpodepesq := 'N';

    TimeInicio := Now;

    Screen.Cursor := crHourGlass;
    pnlStatus.Caption := '  Executando pesquisa, por favor aguarde...';
    FrmLocalizar.Repaint;
    try
      dm.cdsLocalizar.Filter := '';
      dm.cdsLocalizar.Filtered := false;

      dm.cdsLocalizar.AfterOpen := OncdsLocalizarBeforeOpen;
      dm.cdsLocalizar.close;
      dm.cdsLocalizar.SQL.Text := MontaSQL;

      SQLMemo.Lines.Text := dm.cdsLocalizar.sql.Text;

      // CodeSite.Send( SQLMemo.Lines.Text ) ;
      dm.cdsLocalizar.Open;

      if not( dm.cdsLocalizar.IsEmpty ) then
        GridLocalizar.SetFocus;

      EdLocalizar.Clear;

    finally
      TimeFim := Now;
      Screen.Cursor := crDefault;
      pnlStatus.Visible := True;
      pnlStatus.Enabled:= True;

      pnlStatus.Caption := '   Pesquisa Efetuada com Sucesso!        Total Encontrado: ' +
        IntToStr( dm.cdsLocalizar.RecordCount ) + '  -  Tempo Execução: ' +
        FormatDateTime('hh:mm:ss', (TimeFim - TimeInicio));
//    pnlStatus.Repaint;

    end;

  finally
    BtnLocalizar.Enabled := true;
    _vpodepesq := 'S';
  end;
end;

procedure TFrmLocalizar.cbOperadorChange(Sender: TObject);
var
  Idx: Integer;
begin
  if GridLocalizar.Columns.Count <= 0 then
    exit;

  Idx := RetornaIdxCampo(CurrentArea.CampoLocalizar);
  if Idx < 0 then
    exit;

  if CurrentArea.Campos.Items[Idx].Tipo = tcDate then
  begin
    EdLocalizar.EditMask := '!00\/00\/0000\';

    if Copy(cbOperador.Text, 1, 1) = '8' then
      EdLocalizar.EditMask := '!00\/00\/0000\ \à\ 00\/00\/0000;1;_';

  end

  else
  begin

    if Copy(cbOperador.Text, 1, 1) = '8' then
      EdLocalizar.EditMask := '!00\/00\/0000\ \à\ 00\/00\/0000;1;_'
    else
      EdLocalizar.EditMask := '';

    if CurrentArea.Campos.Items[Idx].Tipo = tcNumber then
      EdlocalizarVlr.DisplayFormat := CurrentArea.Campos.Items[Idx].Mascara;

  end;
  if CurrentArea.Campos.Items[Idx].Tipo = tcNumber then
  begin
    EdlocalizarVlr.Visible := true;
    EdlocalizarVlr.SetFocus;
    EdLocalizar.Visible := false;

  end
  else
  begin
    EdLocalizar.Visible := true;
    // Localizar.SetFocus;
    EdlocalizarVlr.Visible := false;
  end;

end;

procedure TFrmLocalizar.ChekitClick(Sender: TObject);
begin
  if (Chekit.Checked = true) and (Chekit.Visible = true) then
  begin
    CurrentArea := TAreaCollectionItem.Create;
    CurrentArea.Assign(FindArea.GetArea(330));
    dm.cdsLocalizar.close;
    cbOperador.ItemIndex := 1;
    pnlStatus.Caption := EmptyStr;
    MontaColunas;

    if (Trim(CurrentArea.Titulo) <> EmptyStr) then
      FrmLocalizar.Caption := CurrentArea.Titulo;

    EdlocalizarVlr.Visible := false;
    EdLocalizar.Visible := true;

    EdlocalizarVlr.Clear;
    EdLocalizar.Clear;

    PintaCampoIndice;
    LblSysSQL.Visible := Funcoes.MaquinaDesenvolvedor;
    SQLMemo.Visible := false;
    SQLMemo.Align := alClient;

  end;
  if (Chekit.Checked = false) and (Chekit.Visible = true) then
  begin
    CurrentArea := TAreaCollectionItem.Create;
    CurrentArea.Assign(FindArea.GetArea(14));
    dm.cdsLocalizar.close;
    cbOperador.ItemIndex := 1;
    pnlStatus.Caption := EmptyStr;
    MontaColunas;

    if (Trim(CurrentArea.Titulo) <> EmptyStr) then
      FrmLocalizar.Caption := CurrentArea.Titulo;

    EdlocalizarVlr.Visible := false;
    EdLocalizar.Visible := true;

    EdlocalizarVlr.Clear;
    EdLocalizar.Clear;

    PintaCampoIndice;
    LblSysSQL.Visible := Funcoes.MaquinaDesenvolvedor;
    SQLMemo.Visible := false;
    SQLMemo.Align := alClient;

  end;

end;

procedure TFrmLocalizar.EdLocalizarKeyPress(Sender: TObject; var Key: Char);
var
  IdxCampo: Integer;
begin
  IdxCampo := RetornaIdxCampo(CurrentArea.CampoLocalizar);
  if CurrentArea.Campos.Items[IdxCampo].Tipo = tcNumber then
  begin
    if not(Key in ['0' .. '9', Chr(8)]) then
      Key := #0;
  end;
end;

procedure TFrmLocalizar.FormActivate(Sender: TObject);
begin
  if not dsLocalizar.DataSet.IsEmpty then
    GridLocalizar.SetFocus
  else if EdLocalizar.Enabled and EdLocalizar.Visible then
    EdLocalizar.SetFocus;

  if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49) or
    (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    Panel1.Visible := true;
  try
    cbOperadorChange(self);
  except

  end;

end;

procedure TFrmLocalizar.FormCreate(Sender: TObject);
begin

  cbOperador.ItemIndex := 1;
  pnlStatus.Caption := EmptyStr;
  Panel1.Visible := false;

  EdlocalizarVlr.Visible := false;
  EdLocalizar.Visible := true;

  EdlocalizarVlr.Clear;
  EdLocalizar.Clear;
  _vpodepesq := 'S';

end;

procedure TFrmLocalizar.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F1) and Funcoes.MaquinaDesenvolvedor then
    SQLMemo.Visible := not SQLMemo.Visible;

end;

procedure TFrmLocalizar.FormKeyPress(Sender: TObject; var Key: Char);
begin

  if ((Key = #13) and EdLocalizar.Focused) or ((Key = #13) and EdlocalizarVlr.Focused) then
  begin
    BtnLocalizar.Click;
    exit;
  end;

  if Key = #27 then
  begin
    Key := #0;
    ModalResult := mrNone;
    close;
  end;
end;

procedure TFrmLocalizar.FormShow(Sender: TObject);
begin
  dm.cdsLocalizar.close;
  cbOperador.ItemIndex := 1;
  pnlStatus.Caption := EmptyStr;
  MontaColunas;

  if (Trim(CurrentArea.Titulo) <> EmptyStr) then
    FrmLocalizar.Caption := CurrentArea.Titulo;

  EdlocalizarVlr.Visible := false;
  EdLocalizar.Visible := true;

  EdlocalizarVlr.Clear;
  EdLocalizar.Clear;

  PintaCampoIndice;
  LblSysSQL.Visible := Funcoes.MaquinaDesenvolvedor;
  SQLMemo.Visible := false;
  SQLMemo.Align := alClient;
  Chekit.Checked := false;
end;

procedure TFrmLocalizar.GridLocalizarDblClick(Sender: TObject);
begin
  if (not dm.cdsLocalizar.IsEmpty) and (GridLocalizar.SelectedIndex >= 0) then
    ModalResult := mrOK;

end;

procedure TFrmLocalizar.GridLocalizarDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if (CurrentArea.Area = 58) then // Cad. Pessoas
  begin
    if dm.cdsLocalizar.FieldByName('DESCRICAOCOR').AsString <> '' then
    begin
      GridLocalizar.Canvas.Brush.Color := StringToColor(dm.cdsLocalizar.FieldByName('DESCRICAOCOR').AsString);
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  end;

  if (CurrentArea.Area = 7) then // Cad. Pessoas
  begin
    if AnsiSameText(dm.cdsLocalizar.FieldByName('STATUS').AsString, 'I') then
    begin
      GridLocalizar.Canvas.Brush.Color := $00D9D9FF;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  end;

  if (CurrentArea.Area = 46) then
  begin
    if (dm.cdsLocalizar.FieldByName('conferido').AsInteger = 1) then
    begin
      GridLocalizar.Canvas.Brush.Color := clGreen;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end
    else
    begin
      GridLocalizar.Canvas.Brush.Color := clYellow;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);

    end;

  end;

  if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49) or
    (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
  begin
    if ((not dm.cdsLocalizar.FieldByName('numeronota').IsNull) and (not Funcoes.Empty(dm.cdsLocalizar.FieldByName('numeronota').AsString)))
    then
    begin
      if dm.cdsLocalizar.FieldByName('numeronota').AsInteger > 0 then
      begin
        GridLocalizar.Canvas.Brush.Color := $00E6E7FF;
        GridLocalizar.Canvas.Font.Color := clBlack;
        GridLocalizar.Canvas.FillRect(Rect);
        GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      end;
    end;

    if ((not dm.cdsLocalizar.FieldByName('numeronota').IsNull) and (not Funcoes.Empty(dm.cdsLocalizar.FieldByName('numeronota').AsString)))
      and (dm.cdsLocalizar.FieldByName('status').AsString = 'C') then
    begin
      GridLocalizar.Canvas.Brush.Color := $005B5BFF;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

    if ((not dm.cdsLocalizar.FieldByName('numeronota').IsNull) and (not Funcoes.Empty(dm.cdsLocalizar.FieldByName('numeronota').AsString)))
      and (dm.cdsLocalizar.FieldByName('contigencia').AsString = 'S') then
    begin
      GridLocalizar.Canvas.Brush.Color := $00C6FFFF;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

    if dm.cdsLocalizar.FindField('REJEITADO') <> nil then
    begin
      if (not dm.cdsLocalizar.FieldByName('REJEITADO').IsNull) and (dm.cdsLocalizar.FieldByName('REJEITADO').AsString = 'S') then
      begin
        GridLocalizar.Canvas.Brush.Color := $00E5E5E5;
        GridLocalizar.Canvas.Font.Color := clBlack;
        GridLocalizar.Canvas.FillRect(Rect);
        GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      end;
    end;

    if (dm.cdsLocalizar.FieldByName('protocolo_epec').AsString <> EmptyStr) and (dm.cdsLocalizar.FieldByName('notaenviada').AsString = 'N')
    then
    begin
      GridLocalizar.Canvas.Brush.Color := $00FFC082;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
    if (dm.cdsLocalizar.FieldByName('exportado').AsString = 'S') then
    begin
      GridLocalizar.Canvas.Brush.Color := clBlack;
      GridLocalizar.Canvas.Font.Color := clWhite;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  end;

  if (CurrentArea.Area = 56) then
  begin
    if not dm.cdsLocalizar.FieldByName('num_nota').IsNull then
    begin
      if dm.cdsLocalizar.FieldByName('num_nota').AsInteger > 0 then
      begin

        GridLocalizar.Canvas.Brush.Color := $00E6E7FF;
        GridLocalizar.Canvas.Font.Color := clBlack;
        GridLocalizar.Canvas.FillRect(Rect);
        GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);

      end;
    end;

    if (not dm.cdsLocalizar.FieldByName('num_nota').IsNull) and (dm.cdsLocalizar.FieldByName('status').AsString = 'C') then
    begin

      GridLocalizar.Canvas.Brush.Color := $005B5BFF;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);

    end;

    if (not dm.cdsLocalizar.FieldByName('num_nota').IsNull) and (dm.cdsLocalizar.FieldByName('ENVIOUCONTSEFAZ').AsString = 'S') then
    begin

      GridLocalizar.Canvas.Brush.Color := $00C6FFFF;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);

    end;

  end;

  if (CurrentArea.Area = 134) then
  begin
    if (dm.cdsLocalizar.FieldByName('fk_qtd').AsInteger > 0) then
    begin
      GridLocalizar.Canvas.Brush.Color := clYellow;
      GridLocalizar.Canvas.Font.Color := clBlack;
      GridLocalizar.Canvas.FillRect(Rect);
      GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  end;

end;

procedure TFrmLocalizar.GridLocalizarKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
  begin
    Key := #0;
    if (not dm.cdsLocalizar.IsEmpty) then
      ModalResult := mrOK;

  end;
end;

procedure TFrmLocalizar.GridLocalizarTitleClick(Column: TColumn);

var
  _idx: Integer;

begin
  if Column.FieldName <> EmptyStr then
  begin
    _idx := RetornaIdxCampo(Column.FieldName);
    if _idx >= 0 then
    begin
      if CurrentArea.Campos.Items[_idx].CanLocate then
      begin
        try
          EdLocalizar.Clear;
          CurrentArea.CampoLocalizar := Column.FieldName;
          PintaCampoIndice;
          cbOperadorChange(self);
          EdlocalizarVlr.Clear;
          if EdlocalizarVlr.Visible then
            EdlocalizarVlr.SetFocus;
          if EdLocalizar.Visible then
            EdLocalizar.SetFocus;
        except
        end;
      end;
    end;
  end
  else
    Application.MessageBox('Não é possível localizar por este campo.', PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
end;

procedure TFrmLocalizar.Label2Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    begin

      dm.cdsLocalizar.Filtered := false;
      dm.cdsLocalizar.Filter := '( numeronota > 0 ) and ( status <> ' + QuotedStr('C') + ' )';
      dm.cdsLocalizar.Filtered := true;

    end;

    // if (dm.cdsLocalizar.FieldByName('exportado').AsString = 'S') then
    // begin
    // GridLocalizar.Canvas.Brush.Color := clBlack;
    // GridLocalizar.Canvas.Font.Color := clWhite;
    // GridLocalizar.Canvas.FillRect(Rect);
    // GridLocalizar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    // end;
    //
    // end;

  end;

end;

procedure TFrmLocalizar.Label3Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    begin

      dm.cdsLocalizar.Filtered := false;
      dm.cdsLocalizar.Filter := '( numeronota > 0 ) and ( status = ' + QuotedStr('C') + ' )';
      dm.cdsLocalizar.Filtered := true;

    end;
  end;

end;

procedure TFrmLocalizar.Label4Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    begin

      dm.cdsLocalizar.Filtered := false;
      dm.cdsLocalizar.Filter := '( numeronota > 0 ) and ( contigencia = ' + QuotedStr('S') + ' )';
      dm.cdsLocalizar.Filtered := true;

    end;
  end;

end;

procedure TFrmLocalizar.Label5Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    begin

      dm.cdsLocalizar.Filtered := false;

      dm.cdsLocalizar.Filter := '( numeronota IS NULL ) and ( status = ' + QuotedStr('N') + ' ) and ( exportado =' + QuotedStr('N') + ' )';
      dm.cdsLocalizar.Filtered := true;

    end;
  end;

end;

procedure TFrmLocalizar.Label6Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    begin

      dm.cdsLocalizar.Filtered := false;
      dm.cdsLocalizar.Filter := '( rejeitado = ' + QuotedStr('S') + ' ) ';
      dm.cdsLocalizar.Filtered := true;

    end;

  end;
end;

procedure TFrmLocalizar.Label7Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    begin

      dm.cdsLocalizar.Filtered := false;
      dm.cdsLocalizar.Filter := ' ( protocolo_epec <> ' + QuotedStr('') + ' ) and ( notaenviada = ' + QuotedStr('N') + ' ) ';
      dm.cdsLocalizar.Filtered := true;

    end;
  end;
end;

procedure TFrmLocalizar.Label9Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
    begin

      dm.cdsLocalizar.Filtered := false;
      dm.cdsLocalizar.Filter := ' ( exportado = ' + QuotedStr('S') + ' ) and ( status = ' + QuotedStr('N') + ' ) ';
      dm.cdsLocalizar.Filtered := true;

    end;
  end;
end;

procedure TFrmLocalizar.MontaColunas;
var
  i: Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    for i := GridLocalizar.Columns.Count - 1 downto 0 do
      GridLocalizar.Columns.Delete(i);

    for i := 0 to CurrentArea.Campos.Count - 1 do
    begin
      if CurrentArea.Campos.Items[i].ShowInFindForm then
      begin
        GridLocalizar.Columns.Add;
        GridLocalizar.Columns[GridLocalizar.Columns.Count - 1].FieldName := CurrentArea.Campos.Items[i].NomeCampo;
        GridLocalizar.Columns[GridLocalizar.Columns.Count - 1].Title.Caption := CurrentArea.Campos.Items[i].Titulo;
        GridLocalizar.Columns[GridLocalizar.Columns.Count - 1].Width := CurrentArea.Campos.Items[i].Tamanho;

        case CurrentArea.Campos.Items[i].Tipo of
          tcText:
            GridLocalizar.Columns[GridLocalizar.Columns.Count - 1].Alignment := taLeftJustify;
          tcNumber:
            GridLocalizar.Columns[GridLocalizar.Columns.Count - 1].Alignment := taRightJustify;
        else
          GridLocalizar.Columns[GridLocalizar.Columns.Count - 1].Alignment := taCenter;
        end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmLocalizar.MontaOperador(vNomeCampo: string);
begin
  cbOperador.Items.Clear;
  try
    case CurrentArea.Campos.Items[RetornaIdxCampo(vNomeCampo)].Tipo of
      tcText:
        begin
          cbOperador.Items.Add('1- Iniciado por');
          cbOperador.Items.Add('2- Contenha');
          cbOperador.ItemIndex := Funcoes.GetConfig('DEFULTPESQUISA', 0);
        end;
      tcNumber:
        begin
          cbOperador.Items.Add('3- Menor');
          cbOperador.Items.Add('4- Menor ou Igual');
          cbOperador.Items.Add('5- Igual');
          cbOperador.Items.Add('6- Maior ou Igual');
          cbOperador.Items.Add('7- Maior');
          cbOperador.ItemIndex := 2;
        end;
      tcDate, tcTime, tcDateTime:
        begin
          cbOperador.Items.Add('3- Menor');
          cbOperador.Items.Add('4- Menor ou Igual');
          cbOperador.Items.Add('5- Igual');
          cbOperador.Items.Add('6- Maior ou Igual');
          cbOperador.Items.Add('7- Maior');
          cbOperador.Items.Add('8- Entre (Datas)');
          cbOperador.ItemIndex := 2;
        end;
    else
      cbOperador.Items.Add('2- Contenha');
      cbOperador.ItemIndex := 0;
    end;

  finally
    if cbOperador.ItemIndex < 0 then
      cbOperador.ItemIndex := 0;
  end;

  // if EdLocalizar.CanFocus then
  // EdLocalizar.SetFocus;
end;

function TFrmLocalizar.MontaSQL: string;
var
  IdxCampo: Integer;
  NewSQL, NewWhere, DataIni, DataFim, OldCampoIndice: string;
  NewOrder: string;
  _Operador, _CampoLocalizar: string;
begin
  NewSQL := CurrentArea.SQL;

  OldCampoIndice := CurrentArea.CampoIndice;

  IdxCampo := RetornaIdxCampo(CurrentArea.CampoLocalizar);

  if CurrentArea.Campos.Items[IdxCampo].IsFK then
    _CampoLocalizar := CurrentArea.Campos.Items[IdxCampo].FKCampo
  else
    _CampoLocalizar := CurrentArea.Campos.Items[IdxCampo].NomeCampo;

  if CurrentArea.Campos.Items[IdxCampo].TDatetime = true then
    _CampoLocalizar := 'CAST( ' + _CampoLocalizar + ' as date ) ';

  if EdlocalizarVlr.Value > 0 then
  begin
    try
      EdLocalizar.Text := StringReplace(FormatCurr('0.00', EdlocalizarVlr.Value), ',', '.', [rfReplaceAll, rfIgnoreCase]);
      // ShowMessage(EdLocalizar.Text);
    except
      on E: Exception do
      begin

        Application.MessageBox(PChar(Format('Erro  %s', [E.Message])), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
        EdLocalizar.Clear;
        EdlocalizarVlr.Clear;
        Result := NewSQL;
        exit;
      end;
    end;

  end;

  if (Trim(StringReplace(EdLocalizar.Text, '/', EmptyStr, [rfReplaceAll])) <> EmptyStr) then
  begin
    // Testo o operador do WHERE
    case StrToInt(Copy(cbOperador.Text, 1, 1)) of
      1, 2:
        _Operador := ' LIKE ';
      3:
        _Operador := ' < ';
      4:
        _Operador := ' <= ';
      5:
        _Operador := ' = ';
      6:
        _Operador := ' >= ';
      7:
        _Operador := ' > ';
      8:
        _Operador := ' BETWEEN ';
    end;

    case CurrentArea.Campos.Items[IdxCampo].Tipo of
      tcText:
        begin
          if (Copy(cbOperador.Text, 1, 1) = '1') then
            NewWhere := ' (UPPER(' + UpperCase(_CampoLocalizar) + ') ' + _Operador + ' ' +
              QuotedStr(AnsiUpperCase(EdLocalizar.Text) + '%') + ')';
          if (Copy(cbOperador.Text, 1, 1) = '2') then
            NewWhere := ' (UPPER(' + UpperCase(_CampoLocalizar) + ') ' + _Operador + ' ' +
              QuotedStr('%' + AnsiUpperCase(EdLocalizar.Text) + '%') + ')';
        end;
      tcNumber:

        NewWhere := ' (' + UpperCase(_CampoLocalizar) + ' ' + _Operador + ' ' + StringReplace(EdLocalizar.Text, ',', '.',
          [rfReplaceAll]) + ')';
      tcDate:
        begin
          DataIni := Copy(EdLocalizar.Text, 1, 10);
          DataFim := Copy(EdLocalizar.Text, 14, 10);
          if not Funcoes.Empty(DataFim) then
          begin
            NewWhere := ' (' + UpperCase(_CampoLocalizar) + ' ' + _Operador + ' ' +
              QuotedStr(StringReplace(DataIni, '/', '.', [rfReplaceAll])) + ' AND ' +
              QuotedStr(StringReplace(DataFim, '/', '.', [rfReplaceAll])) + ' )';
          end
          else
          begin

            NewWhere := ' (' + UpperCase(_CampoLocalizar) + ' ' + _Operador + ' ' +
              QuotedStr(StringReplace(DataIni, '/', '.', [rfReplaceAll])) + ')';

          end;

        end;
    else
      NewWhere := ' (' + UpperCase(_CampoLocalizar) + ' = ' + QuotedStr(AnsiUpperCase(EdLocalizar.Text)) + ' )';
    end;

    if (Pos('ORDER BY', AnsiUpperCase(NewSQL)) > 0) then
    begin
      NewOrder := Copy(NewSQL, Pos('ORDER BY', AnsiUpperCase(NewSQL)), Length(NewSQL));
      NewSQL := Copy(NewSQL, 1, Pos('ORDER BY', AnsiUpperCase(NewSQL)) - 1);

      if (Pos('WHERE', AnsiUpperCase(NewSQL)) <= 0) then
        NewSQL := NewSQL + ' WHERE (' + NewWhere + ')'
      else
        NewSQL := NewSQL + ' AND (' + NewWhere + ')';

      NewSQL := NewSQL + NewOrder;
    end
    else
    begin
      if (Pos('WHERE', AnsiUpperCase(NewSQL)) <= 0) then
        NewSQL := NewSQL + ' WHERE (' + NewWhere + ')'
      else
        NewSQL := NewSQL + ' AND (' + NewWhere + ')';
    end;

    if (Pos('ORDER BY', AnsiUpperCase(NewSQL)) <= 0) then
      NewSQL := NewSQL + ' ORDER BY ' + _CampoLocalizar;
  end
  else if (Pos('ORDER BY', AnsiUpperCase(CurrentArea.SQL)) <= 0) then
  begin
    // if (Pos('WHERE', AnsiUpperCase(NewSQL)) <= 0) then
    // NewSQL := NewSQL + ' WHERE '
    // else
    // NewSQL := NewSQL + ' AND ';
    //

    // if Funcoes.TableExistsIDEmpresa(CurrentArea.Tabela) and Funcoes.TableExistsIDPointCliente(CurrentArea.Tabela) then

    // NewSQL := NewSQL + ' ((IDEMPRESA = ' + Funcoes.GetIDEmpresa + ') OR (IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + '))'
    // else
    // begin
    // if Funcoes.TableExistsIDEmpresa(CurrentArea.Tabela) then
    // NewSQL := NewSQL + ' (IDEMPRESA = ' + Funcoes.GetIDEmpresa + ')';
    // if Funcoes.TableExistsIDPointCliente(CurrentArea.Tabela) then
    // NewSQL := NewSQL + ' (IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ')';
    // end;

    NewSQL := NewSQL + ' ORDER BY ' + _CampoLocalizar;
  end;

  // Memo1.Text := NewSQL;
  Result := NewSQL;
end;

procedure TFrmLocalizar.OncdsLocalizarBeforeOpen(DataSet: TDataSet);
var
  i, Idx: Integer;
  Mascara: string;
  FTipo: TTipoColuna;
begin
  for i := 0 to DataSet.FieldCount - 1 do
  begin

    try
      Idx := RetornaIdxCampo(DataSet.Fields[i].FieldName);
      if Idx < 0 then
        Continue;
    except
    end;

    try
      Mascara := CurrentArea.Campos.Items[Idx].Mascara;
      FTipo := CurrentArea.Campos.Items[Idx].Tipo;
    except
    end;

    if Funcoes.Empty(Mascara) then
      Continue;

    case FTipo of
      tcNumber:
        TFMTBCDField(DataSet.Fields[i]).DisplayFormat := Mascara;
      tcDate, tcTime, tcDateTime:
        TDateTimeField(DataSet.Fields[i]).DisplayFormat := Mascara;

    end;
  end;
end;

procedure TFrmLocalizar.Panel1Click(Sender: TObject);
begin
  if dm.cdsLocalizar.Active then
  begin
    if (CurrentArea.Area = 40) or (CurrentArea.Area = 50) or (CurrentArea.Area = 51) or (CurrentArea.Area = 42) or (CurrentArea.Area = 49)
      or (CurrentArea.Area = 52) or (CurrentArea.Area = 57) or (CurrentArea.Area = 63) or (CurrentArea.Area = 77) then
      dm.cdsLocalizar.Filtered := false;

  end;
end;

procedure TFrmLocalizar.PintaCampoIndice;
var
  Idx: Integer;
begin

  if GridLocalizar.Columns.Count <= 0 then
    exit;

  Idx := RetornaIdxCampo(CurrentArea.CampoLocalizar);
  if Idx < 0 then
    exit;

  LblCampoIndice.Caption := CurrentArea.Campos.Items[Idx].Titulo;
  MontaOperador(CurrentArea.CampoLocalizar);
end;

function TFrmLocalizar.RetornaIdxCampo(ANomeCampo: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  if (ANomeCampo <> EmptyStr) then
  begin
    if CurrentArea.Campos.Count > 0 then
    begin
      for i := 0 to CurrentArea.Campos.Count - 1 do
      begin
        try
          if (UpperCase(CurrentArea.Campos.Items[i].NomeCampo) = UpperCase(ANomeCampo)) then
          begin
            Result := i;
            Break;
          end;
        except

        end;
      end;
    end;
  end;
end;

end.
