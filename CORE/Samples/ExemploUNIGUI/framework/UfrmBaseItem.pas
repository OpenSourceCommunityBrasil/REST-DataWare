unit UfrmBaseItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, UfrmBase, uniGUIBaseClasses, uniStatusBar,
  uniButton, uniBitBtn, uniPanel, UDmLstBaseMov, Data.DB, uniLabel;

type
  TfrmBaseItem = class(TfrmBase)
    UniPanel1: TUniPanel;
    UniBitBtn1: TUniBitBtn;
    UniBitBtn2: TUniBitBtn;
    UniPanel2: TUniPanel;
    lbItem: TUniLabel;
    procedure UniFormCreate(Sender: TObject);
    procedure UniBitBtn1Click(Sender: TObject);
    procedure UniBitBtn2Click(Sender: TObject);
    procedure UniFormShow(Sender: TObject);
  private
    { Private declarations }
    function validarCamposRequeridos: Boolean;
    procedure Inseri_log(campo, valor, mensagem: string);
  public
    { Public declarations }
    ID_ITEM: Integer;
    ListaCadastroItem : TStringList;
    DmLstCadastroMov: TDmLstBaseMov;
    procedure Depois_GravaItem; virtual;
    procedure Antes_GravaItem; virtual;
    procedure GravaItem; virtual;
    procedure Executa_GravaItem; virtual;

    procedure ValidaItem; virtual;
    procedure Calcula_Total_Item; virtual;

    procedure ConfiguraGrid(form: TUniForm); virtual;
    procedure ConfiguraQry;

    procedure AfterOpenItem(DataSet: TDataSet); virtual;
    procedure AfterInsertItem(DataSet: TDataSet); virtual;
    procedure BeforePostItem(DataSet: TDataSet); virtual;

    procedure LimpaItem; virtual;

    procedure Atualiza_DataSets(); virtual;
  end;

function frmBaseItem: TfrmBaseItem;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, uniDBEdit, uniDBLookupComboBox, uniDBMemo,
  uniDBComboBox, uniDBCheckBox, uniDBRadioGroup, uniDBDateTimePicker,
  UMensagens, UfrmValidaCampos, UFuncoesDB;

function frmBaseItem: TfrmBaseItem;
begin
  Result := TfrmBaseItem(UniMainModule.GetFormInstance(TfrmBaseItem));
end;

{ TfrmBaseItem }

procedure TfrmBaseItem.Antes_GravaItem;
begin
  ValidaItem;

  Calcula_Total_Item;
end;

procedure TfrmBaseItem.Atualiza_DataSets;
begin

end;

procedure TfrmBaseItem.Calcula_Total_Item;
begin

end;

procedure TfrmBaseItem.ConfiguraGrid(form: TUniForm);
var
  Linha: TStringList;
  i, j: Integer;
begin
 { if Assigned(ListaCadastroItem) then
  begin
    try
      Linha := TStringList.Create;

      for I := 0 to ListaCadastroItem.Count - 1 do
      begin
        Linha.Delimiter := ';';
        Linha.StrictDelimiter := True;
        Linha.DelimitedText := ListaCadastroItem.Strings[i];

        for j := 0 to form.ComponentCount - 1 do
        begin
          if form.Components[j] is TUniDBEdit then
          begin
             with TUniDBEdit(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBFormattedNumberEdit then
          begin
             with TUniDBFormattedNumberEdit(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBLookupComboBox then
          begin
             with TUniDBLookupComboBox(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBMemo then
          begin
             with TUniDBMemo(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBComboBox then
          begin
             with TUniDBComboBox(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBCheckBox then
          begin
             with TUniDBCheckBox(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBNumberEdit then
          begin
             with TUniDBNumberEdit(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBRadioGroup then
          begin
             with TUniDBRadioGroup(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
                  Break;
                end;
             end;
          end
          else if form.Components[j] is TUniDBDateTimePicker then
          begin
            with TUniDBDateTimePicker(form.Components[j]) do
             begin
                if Name = Linha.Strings[0] then
                begin
                  DataField := Linha.Strings[0];
                  DataSource := DmLstCadastroMov.dsCadItem;
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

  ConfiguraQry; }
end;

procedure TfrmBaseItem.ConfiguraQry;
var
  Linha: TStringList;
  i: Integer;
begin
  {if Assigned(ListaCadastroItem) then
  begin
    try
      Linha := TStringList.Create;

      for I := 0 to ListaCadastroItem.Count - 1 do
      begin
        Linha.Delimiter := ';';
        Linha.StrictDelimiter := True;
        Linha.DelimitedText := ListaCadastroItem.Strings[i];

        with DmLstCadastroMov.qryCadItem.FindField(Linha.Strings[0]) do
        begin
          Tag := 1;

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
             TFloatField(DmLstCadastroMov.qryCadItem.FieldByName(Linha.Strings[0])).DisplayFormat := Linha.Strings[4];
          end;
        end;

      end;

    finally
      Linha.Free;
    end;
  end;     }

end;

procedure TfrmBaseItem.Inseri_log(campo, valor, mensagem: string);
begin
  with DmLstCadastroMov do
  begin
     MemtblLogCampos.Append;
     MemtblLogCamposcampo.AsString := campo;
     MemtblLogCamposvalor.AsString := valor;
     MemtblLogCamposmensagem.AsString := mensagem;
     MemtblLogCampos.Post;
  end;
end;

procedure TfrmBaseItem.LimpaItem;
begin

end;

procedure TfrmBaseItem.UniBitBtn1Click(Sender: TObject);
begin
  inherited;
  Executa_GravaItem;
end;

procedure TfrmBaseItem.UniBitBtn2Click(Sender: TObject);
begin
  inherited;

  with DmLstCadastroMov do
  begin
    if qryCadItem.State in [dsInsert, dsEdit] then
       qryCadItem.Cancel;
  end;

  Close;
end;

procedure TfrmBaseItem.UniFormCreate(Sender: TObject);
begin
  inherited;
  ID_ITEM := 0;

  ListaCadastroItem := TStringList.Create;
  DmLstCadastroMov.qryCadItem.AfterOpen := AfterOpenItem;
  DmLstCadastroMov.qryCadItem.AfterInsert := AfterInsertItem;
  DmLstCadastroMov.qryCadItem.BeforePost := BeforePostItem;

  Atualiza_DataSets;

  LimpaItem;
end;

procedure TfrmBaseItem.UniFormShow(Sender: TObject);
begin
  inherited;
  with DmLstCadastroMov do
  begin
    if ID_ITEM = 0 then
       qryCadItem.Append
    else
    begin
       qryCadItem.Locate('ID', ID_ITEM, []);
       qryCadItem.Edit;
    end;
  end;
end;

procedure TfrmBaseItem.AfterOpenItem(DataSet: TDataSet);
begin
  {ConfiguraQry;
  with DmLstCadastroMov do
  begin
     if CampoChaveItem <> '' then
     begin
       if DataSet.FindField(CampoChaveItem) <> nil then
       begin
          DataSet.FieldByName(CampoChaveItem).ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
       end;
     end;

     if CampoEmpresa <> '' then
     begin
       if DataSet.FindField(CampoEmpresa) <> nil then
       begin
          DataSet.FieldByName(CampoEmpresa).ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
       end;
     end;
  end; }
end;

function TfrmBaseItem.validarCamposRequeridos: Boolean;
const
   espaco = '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;- ';
var
   i, aux: Integer;
   campos: TStringList;
begin
   with DmLstCadastroMov do
   begin
     Result := True;
     campos := TStringList.Create;
     aux := 0;
     for i := 0 to qryCadItem.FieldCount - 1 do
     begin
        if (qryCadItem.Fields[i].Required) and ((qryCadItem.Fields[i].IsNull) or
           (qryCadItem.Fields[i].asString = '')) then
        begin
           if qryCadItem.Fields[i].ConstraintErrorMessage = 'MSG_PADRAO' then
             Inseri_log(qryCadItem.Fields[i].DisplayLabel, 'Vazio', Kernel_Aviso_CampoObrigatorio + ' ( ' + qryCadItem.Fields[i].DisplayLabel + ' )')
           else
             Inseri_log(qryCadItem.Fields[i].DisplayLabel, 'Erro',  qryCadItem.Fields[i].ConstraintErrorMessage);

           campos.Add(espaco + qryCadItem.Fields[i].DisplayLabel);
           if aux = 0 then
              aux := I;
        end
        else if (qryCadItem.Fields[i].Required) then
        begin
           if qryCadItem.Fields[i].DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd] then
           begin
             if qryCadItem.Fields[i].AsFloat = 0 then
             begin
               if qryCadItem.Fields[i].ConstraintErrorMessage = 'MSG_PADRAO' then
                 Inseri_log(qryCadItem.Fields[i].DisplayLabel, 'Vazio', Kernel_Aviso_CampoObrigatorio + ' ( ' + qryCadItem.Fields[i].DisplayLabel + ' )')
               else
                 Inseri_log(qryCadItem.Fields[i].DisplayLabel, 'Erro',  qryCadItem.Fields[i].ConstraintErrorMessage);

               campos.Add(espaco + qryCadItem.Fields[i].DisplayLabel);
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

procedure TfrmBaseItem.Depois_GravaItem;
begin

end;

procedure TfrmBaseItem.Executa_GravaItem;
begin
  Antes_GravaItem;
  GravaItem;
  Depois_GravaItem;
end;

procedure TfrmBaseItem.GravaItem;
begin
   with DmLstCadastroMov do
   begin
     if qryCadItem.State in [dsInsert, dsEdit] then
        qryCadItem.Post;
     ModalResult := mrOk;
   end;
end;

procedure TfrmBaseItem.ValidaItem;
begin
  if not validarCamposRequeridos then
  begin
    with DmLstCadastroMov do
    begin
      if not MemtblLogCampos.IsEmpty then
      begin
        with frmValidaCampos do
        begin
          frmValidaCampos.dslog.DataSet := MemtblLogCampos;
          MemtblLogCampos.Refresh;
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

procedure TfrmBaseItem.AfterInsertItem(DataSet: TDataSet);
begin
  inherited;
  with DmLstCadastroMov do
  begin
    if DataSet.State in [dsinsert] then
    begin
      if not AutoIncItem then
      begin
         DataSet.FieldByName(CampoChaveItem).value:= Kernel_Incrementa(TabelaItemInc,CampoChaveItem);
         if Trim(CampoEmpresa) <> '' then
            DataSet.FieldByName(CampoEmpresa).Value := UniMainModule.ID_EMPRESA;
      end;
    end;
  end;
end;

procedure TfrmBaseItem.BeforePostItem(DataSet: TDataSet);
begin
  inherited;
  with DmLstCadastroMov do
  begin
    if DataSet.State in [dsinsert] then
    begin
      if not AutoInc then
      begin
         DataSet.FieldByName(CampoChaveItem).value:= Kernel_Incrementa(TabelaItemInc,CampoChaveItem);
      end;
    end;
  end;
end;

end.
