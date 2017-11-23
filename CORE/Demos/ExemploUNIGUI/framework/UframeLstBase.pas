unit UframeLstBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIFrame, UFrameBase, uniGUIBaseClasses, uniImageList,
  uniToolBar, uniPanel, uniPageControl, Data.DB, uniLabel,
  uniBasicGrid, uniDBGrid, UDmLstBase, uniDBEdit;

type
  TframeLstBase = class(TframeBase)
    UniToolBar1: TUniToolBar;
    bt_incluir: TUniToolButton;
    bt_editar: TUniToolButton;
    bt_excluir: TUniToolButton;
    bt_salvar: TUniToolButton;
    bt_cancelar: TUniToolButton;
    bt_imprimir: TUniToolButton;
    bt_pesquisar: TUniToolButton;
    bt_fechar: TUniToolButton;
    pgCadastro: TUniPageControl;
    Tab_Consulta: TUniTabSheet;
    Tab_Cadastro: TUniTabSheet;
    pnlbotoes: TUniPanel;
    lbltitulo: TUniLabel;
    UniPanel1: TUniPanel;
    lbltitulocadastro: TUniLabel;
    pnlfiltros: TUniPanel;
    GridList: TUniDBGrid;
    procedure UniFrameCreate(Sender: TObject);
    procedure bt_pesquisarClick(Sender: TObject);
    procedure bt_incluirClick(Sender: TObject);
    procedure bt_editarClick(Sender: TObject);
    procedure bt_excluirClick(Sender: TObject);
    procedure bt_salvarClick(Sender: TObject);
    procedure bt_cancelarClick(Sender: TObject);
    procedure bt_imprimirClick(Sender: TObject);
    procedure bt_fecharClick(Sender: TObject);
  private
    { Private declarations }
    procedure HabButoes(status: Boolean);
    function validarCamposRequeridos: Boolean;
    procedure ConfiguraQry;
  public
    { Public declarations }
    DmLstCadastro: TDmLstBase;
    ListaGrid, ListaCadastro : TStringList ;

    procedure ConfiguraGrid(GridList: TUniDBGrid; frame: TUniFrame); virtual;

    procedure Pesquisa_base; virtual;
    procedure Executa_Pesquisa_base; virtual;
    procedure Antes_Pesquisa_base; virtual;
    procedure Depois_Pesquisa_base; virtual;

    procedure Novo_base; virtual;
    procedure Executa_Novo_base; virtual;
    procedure Antes_Novo_base; virtual;
    procedure Depois_Novo_base; virtual;

    procedure Alterar_base; virtual;
    procedure Executa_Alterar_base; virtual;
    procedure Antes_Alterar_base; virtual;
    procedure Depois_Alterar_base; virtual;

    procedure Excluir_base; virtual;
    procedure Executa_Excluir_base; virtual;
    procedure Antes_Excluir_base; virtual;
    procedure Depois_Excluir_base; virtual;

    procedure Imprimir_Base; virtual;
    procedure Executa_Imprimir_base; virtual;
    procedure Antes_Imprimir_base; virtual;
    procedure Depois_Imprimir_base; virtual;

    procedure Salvar_Base; virtual;
    procedure Executa_Salvar_base; virtual;
    procedure Antes_Salvar_base; virtual;
    procedure Depois_Salvar_base; virtual;
    procedure Antes_Salvar_Post_base; virtual;

    procedure Cancelar_Base; virtual;
    procedure Executa_Cancelar_base; virtual;
    procedure Antes_Cancelar_base; virtual;
    procedure Depois_Cancelar_base; virtual;

    procedure Executa_Excluir(Sender: TComponent; Res: Integer);

    procedure Inseri_log(campo,valor, mensagem: string); virtual;

    procedure Atualiza_DataSets(); virtual;

    procedure AfterInsert(DataSet: TDataSet); virtual;
    procedure BeforePost(DataSet: TDataSet); virtual;
    procedure AfterOpen(DataSet: TDataSet); virtual;
    procedure AfterPost(DataSet: TDataSet); virtual;
  end;

implementation

uses
  MainModule, UFuncoesDB, UMensagens, UfrmValidaCampos, uniDBLookupComboBox,
  uniDBMemo, uniDBComboBox, uniDBCheckBox, uniDBRadioGroup,
  uniDBDateTimePicker;

{$R *.dfm}

{ TframeBase1 }

procedure TframeLstBase.AfterInsert(DataSet: TDataSet);
begin
  with DmLstCadastro do
  begin
    if DataSet.State in [dsinsert] then
    begin
      if not AutoInc then
      begin
         DataSet.FieldByName(CampoChave).value := Kernel_Incrementa(TabelaInc,CampoChave);
         if Trim(CampoEmpresa) <> '' then
            DataSet.FieldByName(CampoEmpresa).Value := UniMainModule.ID_EMPRESA;
      end;
    end;
  end;
end;

procedure TframeLstBase.AfterOpen(DataSet: TDataSet);
begin
  ConfiguraQry;
  with DmLstCadastro do
  begin
     if CampoChave <> '' then
     begin
       if DataSet.FindField(CampoChave) <> nil then
       begin
          DataSet.FieldByName(CampoChave).ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
       end;
     end;

     if CampoEmpresa <> '' then
     begin
       if DataSet.FindField(CampoEmpresa) <> nil then
       begin
          DataSet.FieldByName(CampoEmpresa).ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
       end;
     end;
  end;
end;

procedure TframeLstBase.AfterPost(DataSet: TDataSet);
begin

end;

procedure TframeLstBase.Alterar_base;
begin
  with DmLstCadastro do
  begin
    qryCadbase.Close;
    qryCadbase.Params[0].AsInteger :=
      qryLstbase.FieldByName(DmLstCadastro.CampoChave).AsInteger;
    if qryCadbase.ParamCount > 1 then
       qryCadbase.Params[1].AsInteger := UniMainModule.ID_EMPRESA;
    qryCadbase.Open;

    qryCadbase.edit;
  end;

  Atualiza_DataSets;

  Tab_Cadastro.TabVisible := True;
  Tab_Consulta.TabVisible := False;
  pgCadastro.ActivePageIndex := 1;
  HabButoes(False);
end;

procedure TframeLstBase.Antes_Alterar_base;
begin
  if DmLstCadastro.qryLstbase.IsEmpty then
  begin
    MessageDlg('Impossível Alterar: Nenhum registro encontrado com o filtro utilizado!', mtInformation, [mbOK]);
    Abort;
  end;
end;

procedure TframeLstBase.Antes_Cancelar_base;
begin

end;

procedure TframeLstBase.Antes_Excluir_base;
begin
  if DmLstCadastro.qryLstbase.IsEmpty then
  begin
    MessageDlg('Impossível Excluir: Nenhum registro encontrado com o filtro utilizado!', mtInformation, [mbOK]);
    Abort;
  end;
end;

procedure TframeLstBase.Antes_Imprimir_base;
begin

end;

procedure TframeLstBase.Antes_Novo_base;
begin

end;

procedure TframeLstBase.Antes_Pesquisa_base;
begin

end;

procedure TframeLstBase.Antes_Salvar_base;
begin
  DmLstCadastro.MemtblLogCampos.EmptyDataSet;
end;

procedure TframeLstBase.Antes_Salvar_Post_base;
begin
  if not validarCamposRequeridos then
  begin
    with DmLstCadastro do
    begin
      if not MemtblLogCampos.IsEmpty then
      begin
        with frmValidaCampos do
        begin
          frmValidaCampos.dslog.DataSet := MemtblLogCampos;
          MemtblLogCampos.Refresh;
          // dmChamados := Self.dmChamados;
          ShowModal(
            procedure(Sender: TComponent; Result: Integer)
            begin
              MemtblLogCampos.EmptyDataSet;
            end);

          Abort;
        end;
      end;
    end;
  end;
end;

procedure TframeLstBase.Atualiza_DataSets;
begin

end;

procedure TframeLstBase.BeforePost(DataSet: TDataSet);
begin
  // Faz autoincremto do campo chave
  with DmLstCadastro do
  begin
    if DataSet.State in [dsinsert] then
    begin
      if not AutoInc then
      begin
         DataSet.FieldByName(CampoChave).value:= Kernel_Incrementa(TabelaInc,CampoChave);
      end;
    end;
  end;
end;

procedure TframeLstBase.bt_cancelarClick(Sender: TObject);
begin
  inherited;
  Executa_Cancelar_base;
end;

procedure TframeLstBase.bt_editarClick(Sender: TObject);
begin
  inherited;
  Executa_Alterar_base;
end;

procedure TframeLstBase.bt_excluirClick(Sender: TObject);
begin
  inherited;
  Executa_Excluir_base;
end;

procedure TframeLstBase.bt_fecharClick(Sender: TObject);
begin
  inherited;
 // Close;
end;

procedure TframeLstBase.bt_imprimirClick(Sender: TObject);
begin
  inherited;
  Executa_Imprimir_base;
end;

procedure TframeLstBase.bt_incluirClick(Sender: TObject);
begin
  inherited;
  Executa_Novo_base;
end;

procedure TframeLstBase.bt_pesquisarClick(Sender: TObject);
begin
  inherited;
  Executa_Pesquisa_base;
end;

procedure TframeLstBase.bt_salvarClick(Sender: TObject);
begin
  inherited;
  Executa_Salvar_base;
end;

procedure TframeLstBase.Cancelar_Base;
begin
  DmLstCadastro.qryCadbase.Cancel;
end;

procedure TframeLstBase.ConfiguraGrid(GridList: TUniDBGrid; frame: TUniFrame);
var
  Linha: TStringList;
  i, j: Integer;
begin
  if Assigned(ListaGrid) then
  begin
    try
      Linha := TStringList.Create;

      while GridList.Columns.Count-1 >= 0 do
      begin
        GridList.Columns.Delete(GridList.Columns.Count-1);
      end;

      for I := 0 to ListaGrid.Count - 1 do
      begin
        Linha.Delimiter := ';';
        Linha.StrictDelimiter := True;
        Linha.DelimitedText := ListaGrid.Strings[i];

        with GridList.Columns.Add do
        begin
          FieldName := Linha.Strings[0];
          Title.Caption := Linha.Strings[1];
          Width := StrToIntDef(Linha.Strings[2], 10);
          Visible := True;
        end;

        with DmLstCadastro do
        begin
          if qryLstbase.Active then
          begin
             if qryLstbase.FindField(Linha.Strings[0]) <> nil then
             begin
                if Linha.Count = 4 then
                begin
                  if Trim(Linha.Strings[3]) <> '' then
                  begin
                     TFloatField(qryLstbase.FieldByName(Linha.Strings[0])).DisplayFormat := Linha.Strings[3];
                  end;
                end;
             end;
          end;
        end;

      end;

    finally
      Linha.Free;
    end;
  end;

  if Assigned(ListaCadastro) then
  begin
    try
      Linha := TStringList.Create;

      for I := 0 to ListaCadastro.Count - 1 do
      begin
        Linha.Delimiter := ';';
        Linha.StrictDelimiter := True;
        Linha.DelimitedText := ListaCadastro.Strings[i];

        for j := 0 to frame.ComponentCount - 1 do
        begin
          if frame.Components[j] is TUniDBEdit then
          begin
             with TUniDBEdit(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBFormattedNumberEdit then
          begin
             with TUniDBFormattedNumberEdit(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBLookupComboBox then
          begin
             with TUniDBLookupComboBox(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBMemo then
          begin
             with TUniDBMemo(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBComboBox then
          begin
             with TUniDBComboBox(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBCheckBox then
          begin
             with TUniDBCheckBox(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBNumberEdit then
          begin
             with TUniDBNumberEdit(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBRadioGroup then
          begin
             with TUniDBRadioGroup(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end
          else if frame.Components[j] is TUniDBDateTimePicker then
          begin
            with TUniDBDateTimePicker(frame.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastro.dsCadBase;
                  Break;
                end;
             end;
          end;

        end;

      end;

    finally
      Linha.Free;
    end;
  end;
end;

procedure TframeLstBase.ConfiguraQry;
var
  Linha: TStringList;
  i: Integer;
begin
  if Assigned(ListaCadastro) then
  begin
    try
      Linha := TStringList.Create;

      for I := 0 to ListaCadastro.Count - 1 do
      begin
        Linha.Delimiter := ';';
        Linha.StrictDelimiter := True;
        Linha.DelimitedText := ListaCadastro.Strings[i];

        with DmLstCadastro.qryCadbase.FindField(Linha.Strings[0]) do
        begin
          ConstraintErrorMessage := Linha.Strings[1];
          if Linha.Strings[2] = 'S' then
             Required := True
          else
             Required :=  False;                                               
          if Linha.Strings[3] <> '0' then  
             DisplayLabel := Linha.Strings[3];
          if Linha.Strings[4] <> '0' then
          begin
             EditMask := Linha.Strings[4];
             TFloatField(DmLstCadastro.qryCadbase.FieldByName(Linha.Strings[0])).DisplayFormat := Linha.Strings[4];
          end;
        end;

      end;

    finally
      Linha.Free;
    end;
  end;
end;

function TframeLstBase.validarCamposRequeridos: Boolean;
const
   espaco = '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;- ';
var
   i, aux: Integer;
   campos: TStringList;
begin
   with DmLstCadastro do
   begin
     Result := True;
     campos := TStringList.Create;
     aux := 0;
     for i := 0 to qryCadbase.FieldCount - 1 do
     begin
        if (qryCadbase.Fields[i].Required) and ((qryCadbase.Fields[i].IsNull) or
           (qryCadbase.Fields[i].asString = '')) then
        begin
           if qryCadbase.Fields[i].ConstraintErrorMessage = 'MSG_PADRAO' then
             Inseri_log(qryCadbase.Fields[i].DisplayLabel, 'Vazio', Kernel_Aviso_CampoObrigatorio + ' ( ' + qryCadbase.Fields[i].DisplayLabel + ' )')
           else
             Inseri_log(qryCadbase.Fields[i].DisplayLabel, 'Erro',  qryCadbase.Fields[i].ConstraintErrorMessage);

           campos.Add(espaco + qryCadbase.Fields[i].DisplayLabel);
           if aux = 0 then
              aux := I;
        end
        else if (qryCadbase.Fields[i].Required) then
        begin
           if qryCadbase.Fields[i].DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd] then
           begin
             if qryCadbase.Fields[i].AsFloat = 0 then
             begin
               if qryCadbase.Fields[i].ConstraintErrorMessage = 'MSG_PADRAO' then
                 Inseri_log(qryCadbase.Fields[i].DisplayLabel, 'Vazio', Kernel_Aviso_CampoObrigatorio + ' ( ' + qryCadbase.Fields[i].DisplayLabel + ' )')
               else
                 Inseri_log(qryCadbase.Fields[i].DisplayLabel, 'Erro',  qryCadbase.Fields[i].ConstraintErrorMessage);

               campos.Add(espaco + qryCadbase.Fields[i].DisplayLabel);
               if aux = 0 then
                  aux := I;
             end;
           end;
        end;
     end;
     if campos.Count > 0 then
     begin
        Result := False;
     end;
     campos.Free;
   end;
end;

procedure TframeLstBase.Depois_Alterar_base;
begin

end;

procedure TframeLstBase.Depois_Cancelar_base;
begin
  Tab_Cadastro.TabVisible := False;
  Tab_Consulta.TabVisible := True;
  pgCadastro.ActivePageIndex := 0;
  HabButoes(True);
end;

procedure TframeLstBase.Depois_Excluir_base;
begin

end;

procedure TframeLstBase.Depois_Imprimir_base;
begin

end;

procedure TframeLstBase.Depois_Novo_base;
begin
  Atualiza_DataSets;
end;

procedure TframeLstBase.Depois_Pesquisa_base;
begin

end;

procedure TframeLstBase.Depois_Salvar_base;
begin
  Tab_Cadastro.TabVisible := False;
  Tab_Consulta.TabVisible := True;
  pgCadastro.ActivePageIndex := 0;
  HabButoes(True);
  Executa_Pesquisa_base;
end;

procedure TframeLstBase.Excluir_base;
begin
  MessageDlg('Tem certeza que deseja excluir esse registro?', mtConfirmation, mbYesNo, Executa_Excluir);
end;

procedure TframeLstBase.Executa_Alterar_base;
begin
  Antes_Alterar_base;
  Alterar_base;
  Depois_Alterar_base;
end;

procedure TframeLstBase.Executa_Cancelar_base;
begin
  Antes_Cancelar_base;
  Cancelar_base;
  Depois_Cancelar_base;
end;

procedure TframeLstBase.Executa_Excluir(Sender: TComponent; Res: Integer);
Var
 vError : String;
begin
  case Res of
    mrYes :
     begin
       // excluir o registro na tabela
       with DmLstCadastro do
       begin
         try
           if Kernel_Apaga_Rergistro(Tabela, CampoChave, CampoEmpresa, qryLstbase.FieldByName(CampoChave).AsInteger, UniMainModule.ID_EMPRESA, vError) then
           begin
             Depois_Excluir_base;
             // Implementado nos filhos
             Executa_Pesquisa_base;
           end
           else
             MessageDlg('Erro ao excluir dados: ' + vError, mtError, [mbOK]);
         except
           on e: Exception do
           begin
             MessageDlg('Erro ao excluir dados: ' + e.Message, mtError, [mbOK]);
           end;
         end;
       end;
     end;
  end;
end;

procedure TframeLstBase.Executa_Excluir_base;
begin
  Antes_Excluir_base;
  Excluir_base;
end;

procedure TframeLstBase.Executa_Imprimir_base;
begin
  Antes_Imprimir_base;
  Imprimir_base;
  Depois_Imprimir_base;
end;

procedure TframeLstBase.Executa_Novo_base;
begin
  Antes_Novo_base;
  Novo_base;
  Depois_Novo_base;
end;

procedure TframeLstBase.Executa_Pesquisa_base;
begin
  Antes_Pesquisa_base;
  Pesquisa_base;
  Depois_Pesquisa_base;
end;

procedure TframeLstBase.Executa_Salvar_base;
begin
  Antes_Salvar_base;
  Salvar_base;
  Depois_Salvar_base;
end;

procedure TframeLstBase.HabButoes(status: Boolean);
begin
  if bt_incluir.Tag = 0 then
     bt_incluir.Visible := status;
  if bt_editar.Tag = 0 then
     bt_editar.Visible := status;
  if bt_excluir.Tag = 0 then
     bt_excluir.Visible := status;
  if bt_salvar.Tag = 0 then
     bt_salvar.Visible := not status;
  if bt_cancelar.Tag = 0 then
     bt_cancelar.Visible := not status;
  if bt_pesquisar.Tag = 0 then
     bt_pesquisar.Visible := status;
  if bt_imprimir.Tag = 0 then
     bt_imprimir.Visible := status;
end;

procedure TframeLstBase.Imprimir_Base;
begin

end;

procedure TframeLstBase.Inseri_log(campo, valor, mensagem: string);
begin
  with DmLstCadastro do
  begin
     MemtblLogCampos.Append;
     MemtblLogCamposcampo.AsString := campo;
     MemtblLogCamposvalor.AsString := valor;
     MemtblLogCamposmensagem.AsString := mensagem;
     MemtblLogCampos.Post;
  end;
end;

procedure TframeLstBase.Novo_base;
begin
  with DmLstCadastro do
  begin
    qryCadbase.Close;
    qryCadbase.Params[0].AsInteger := -1;
    if qryCadbase.ParamCount > 1 then
       qryCadbase.Params[1].AsInteger := -1;
    qryCadbase.Open;
    qryCadbase.Append;
  end;

  Tab_Cadastro.TabVisible := True;
  Tab_Consulta.TabVisible := False;
  pgCadastro.ActivePageIndex := 1;
  HabButoes(false);
end;

procedure TframeLstBase.Pesquisa_base;
begin

end;

procedure TframeLstBase.Salvar_Base;
Var
 vError : String;
begin
   with DmLstCadastro do
   begin
     Antes_Salvar_Post_base;
     if qryCadbase.State in [dsInsert, dsEdit] then
        qryCadbase.Post;
     if qryCadbase.MassiveCount > 0 then
     begin
       if not qryCadbase.ApplyUpdates(vError) then
          MessageDlg('Erro ao salvar dados: ' + vError, mtError, [mbOK]);
     end;
   end;
end;

procedure TframeLstBase.UniFrameCreate(Sender: TObject);
begin
  inherited;

  ListaGrid := TStringList.Create;
  ListaCadastro := TStringList.Create;

  DmLstCadastro.qryCadbase.AfterInsert := AfterInsert;
  DmLstCadastro.qryCadbase.BeforePost := BeforePost;
  DmLstCadastro.qryCadbase.AfterOpen := AfterOpen;
  DmLstCadastro.qryCadbase.AfterPost := AfterPost;

  Tab_Cadastro.TabVisible := False;
  Tab_Consulta.TabVisible := True;
  pgCadastro.ActivePageIndex := 0;
  Self.Caption := 'Formulario de ' + DmLstCadastro.titulo;
  lbltitulo.Caption := 'Listagem de ' + DmLstCadastro.titulo;
  lbltitulocadastro.Caption := 'Manutenção de ' + DmLstCadastro.titulo;
  HabButoes(True);
  DmLstCadastro.AutoInc := False;

  if DmLstCadastro.MemtblLogCampos.Active then
    DmLstCadastro.MemtblLogCampos.EmptyDataSet
  else
    DmLstCadastro.MemtblLogCampos.CreateDataSet;

  UniMainModule.TestaConexao;

  if Trim(UniMainModule.strResultadoTesteConexao) <> '' then
  begin
    MessageDlg('Erro ao conectar ao servidor: ' + UniMainModule.strResultadoTesteConexao , mtWarning, [mbOK]);
  end;

end;

end.
