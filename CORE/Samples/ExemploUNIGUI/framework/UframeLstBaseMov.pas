unit UframeLstBaseMov;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIFrame, UframeLstBase, uniBasicGrid, uniDBGrid, uniLabel,
  uniPanel, uniPageControl, uniToolBar, uniGUIBaseClasses, UDmLstBaseMov;

type
  TframeLstBaseMov = class(TframeLstBase)
  private
    { Private declarations }
  public
    { Public declarations }
    DmLstCadastroMov: TDmLstBaseMov;

    procedure Executa_NovoRegistroItm; virtual;
    procedure NovoRegistroItm; virtual;
    procedure AntesNovoRegistroItm; virtual;
    procedure DepoisNovoRegistroItm; virtual;

    procedure Executa_AlterarRegistroItm; virtual;
    procedure AlterarRegistroItm; virtual;
    procedure AntesAlterarRegistroItm; virtual;
    procedure DepoisAlterarRegistroItm; virtual;

    procedure Executa_ExcluirRegistroItm; virtual;
    procedure AntesExcluirRegistroItm; virtual;
    procedure ExcluirRegistroItm; virtual;
    procedure DepoisExcluirRegistroItm; virtual;

    procedure Executa_ExcluirItem(Sender: TComponent; Res: Integer); virtual;

    procedure Executa_Atualiza_Total_Mov; virtual;
    procedure Antes_Atualiza_Total_Mov; virtual;
    procedure Atualiza_Total_Mov; virtual;
    procedure Depois_Atualiza_Total_Mov; virtual;

  end;

implementation

uses
  UMensagens, MainModule, UFuncoesDB, Data.DB;

{$R *.dfm}



{ TframeLstBaseMov }

procedure TframeLstBaseMov.AlterarRegistroItm;
begin

end;

procedure TframeLstBaseMov.AntesAlterarRegistroItm;
begin

end;

procedure TframeLstBaseMov.AntesExcluirRegistroItm;
begin
  if DmLstCadastroMov.qryCadItem.IsEmpty then
  begin
    MessageDlg(Kernel_Aviso_TabelaVazia, mtWarning, [mbOK]);
    Abort;
  end;
end;

procedure TframeLstBaseMov.AntesNovoRegistroItm;
begin

end;

procedure TframeLstBaseMov.Antes_Atualiza_Total_Mov;
begin

end;

procedure TframeLstBaseMov.Atualiza_Total_Mov;
begin

end;

procedure TframeLstBaseMov.DepoisAlterarRegistroItm;
begin

end;

procedure TframeLstBaseMov.DepoisExcluirRegistroItm;
begin
  Executa_Atualiza_Total_Mov;
end;

procedure TframeLstBaseMov.DepoisNovoRegistroItm;
begin

end;

procedure TframeLstBaseMov.Depois_Atualiza_Total_Mov;
begin

end;

procedure TframeLstBaseMov.ExcluirRegistroItm;
var
  vErros: string;
begin
  with DmLstCadastroMov do
  begin
     qryCadItem.Delete;

// COMENTADO POR AQUI NÃO APAGAR NA BASE NESSE MOMENTO MAIS NO APPLY NA FRENTE
//   if not Kernel_Apaga_Rergistro(TabelaItem, CampoChaveItem, CampoEmpresa,
//      qryCadItem.FieldByName(CampoChaveItem).Value, UniMainModule.ID_EMPRESA, vErros) then
//      raise Exception.Create(vErros);
  end;
end;

procedure TframeLstBaseMov.Executa_AlterarRegistroItm;
begin
  if DmLstCadastroMov.qryCadItem.IsEmpty then
  begin
    MessageDlg(Kernel_Aviso_TabelaVazia, mtWarning, [mbOK]);
  end;

  AntesAlterarRegistroItm;
  AlterarRegistroItm;
  DepoisAlterarRegistroItm;
end;

procedure TframeLstBaseMov.Executa_Atualiza_Total_Mov;
begin
  Antes_Atualiza_Total_Mov;
  Atualiza_Total_Mov;
  Depois_Atualiza_Total_Mov;
end;

procedure TframeLstBaseMov.Executa_ExcluirRegistroItm;
begin
  AntesExcluirRegistroItm;

  MessageDlg(Kernel_Confirmacao_Apaga_Registro, mtConfirmation, mbYesNo, Executa_ExcluirItem);

end;

procedure TframeLstBaseMov.Executa_ExcluirItem(Sender: TComponent; Res: Integer);
//var
//  int_codigo: integer;
begin
  with DmLstCadastroMov do
  begin
    case Res of
      mrYes :
       begin
         try
//           int_codigo := qryLstItem.FieldByName(CampoChaveItem).Value;

           ExcluirRegistroItm;

//           qryLstItem.Close;
//           qryLstItem.Params[0].AsInteger :=
//             UniMainModule.ID_EMPRESA;
//           qryLstItem.Params[1].AsInteger := qryCadbase.FieldByName(CampoChave).AsInteger;
//           qryLstItem.Open();

           DepoisExcluirRegistroItm;

//           qryLstItem.Locate(CampoChaveItem, int_codigo, []);
         except
           MessageDlg(Kernel_Erro_FalhaInesperada +
            ' o registro (' + IntToStr(qryCadItem.FieldByName(CampoChaveItem)
            .Value) + ')', mtError, [mbOK]);
           Abort;
         end;
       end;
    end;
  end;
end;

procedure TframeLstBaseMov.Executa_NovoRegistroItm;
begin
 // AntesNovoRegistroItm;
  NovoRegistroItm;
//  DepoisNovoRegistroItm;
end;

procedure TframeLstBaseMov.NovoRegistroItm;
begin

end;

end.
