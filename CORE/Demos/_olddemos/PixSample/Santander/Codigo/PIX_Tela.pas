unit PIX_Tela;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst,
  Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ComCtrls, ACBrGIF, Data.FMTBcd,
  Data.DB, Datasnap.DBClient, Datasnap.Provider, Data.SqlExpr, PIX, ACBrBase,
  ACBrPosPrinter, uDWResponseTranslator, uDWAbout, RLPrinters;

Const
 cLoja   = '1';
 LojaSeq = '1';

type
  TfrmPIX_Tela = class(TForm)
    Panel1: TPanel;
    imgLogo: TImage;
    imgQRCODE: TImage;
    btnImprQrCode: TBitBtn;
    btnConfirmar: TBitBtn;
    btnCancelar: TBitBtn;
    pbProgress: TProgressBar;
    TimerConsultar: TTimer;
    lblValor: TLabel;
    qryPIX: TSQLQuery;
    DSPPIX: TDataSetProvider;
    CDSPIX: TClientDataSet;
    qryPIXSEQUENCIA: TIntegerField;
    qryPIXCODCONTA: TIntegerField;
    qryPIXCHAVE: TStringField;
    qryPIXVALOR: TFMTBCDField;
    qryPIXTXID: TStringField;
    qryPIXCRIACAO: TSQLTimeStampField;
    qryPIXEXPIRACAO: TIntegerField;
    qryPIXLOCATION: TStringField;
    qryPIXQRCODE: TStringField;
    qryPIXREVISAO: TIntegerField;
    CDSPIXSEQUENCIA: TIntegerField;
    CDSPIXCODCONTA: TIntegerField;
    CDSPIXCHAVE: TStringField;
    CDSPIXVALOR: TFMTBCDField;
    CDSPIXTXID: TStringField;
    CDSPIXCRIACAO: TSQLTimeStampField;
    CDSPIXEXPIRACAO: TIntegerField;
    CDSPIXLOCATION: TStringField;
    CDSPIXQRCODE: TStringField;
    CDSPIXREVISAO: TIntegerField;
    qryPIXDEVEDOR: TStringField;
    qryPIXDEVEDOR_CPF: TStringField;
    qryPIXSTATUS: TStringField;
    CDSPIXDEVEDOR: TStringField;
    CDSPIXDEVEDOR_CPF: TStringField;
    CDSPIXSTATUS: TStringField;
    lblStatus: TLabel;
    qryPIXRECTO_VALOR: TFMTBCDField;
    qryPIXRECTO_HORARIO: TSQLTimeStampField;
    qryPIXRECEBIDO: TStringField;
    CDSPIXRECTO_VALOR: TFMTBCDField;
    CDSPIXRECTO_HORARIO: TSQLTimeStampField;
    CDSPIXRECEBIDO: TStringField;
    ACBrPosPrinterPIX: TACBrPosPrinter;
    mImp: TMemo;
    qryPesq: TSQLQuery;
    DWCR_PIX: TDWClientREST;
    qryAux_PIX: TSQLQuery;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnImprQrCodeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerConsultarTimer(Sender: TObject);
  private
    { Private declarations }
    bRecebido  : Boolean;
    nSeqTabPIX : Integer;
    cQrCode,
    cFantasia  : String;
    procedure Gerar;
    procedure Atualizar(cStatus : String);

    procedure ConsultaRecto(dMostraMensagem : Boolean);
    procedure GravaPIX(pSequencia: Integer; pPIX: TPix;cStatus : String);
    function NewAddSequencia: Integer;
  public
    { Public declarations }
    bContinuarPIX : Boolean;
    nCodBancoPIX  : Integer;
    nValorPIX     : Currency;
    cMensagemPIX  : String;
    cDevedor_Nome : String;
    cDevedor_CPF  : String;
    cInfo_adicionais_Nome  : String;
    cInfo_adicionais_Valor : String;
    cCidadeLoja            : String;
    cTXID : String;

  end;

var
  frmPIX_Tela: TfrmPIX_Tela;

implementation

{$R *.dfm}

Function Limpalixo(Value : String) : String;
Begin
 Result := StringReplace(StringReplace(StringReplace(Value, '-', '', [rfReplaceAll]),
                                                            '.', '', [rfReplaceAll]),
                                                            '/', '', [rfReplaceAll]);
End;

procedure TfrmPIX_Tela.btnCancelarClick(Sender: TObject);
begin
    //verificar aqui se foi gerado o PIX
    Atualizar('REMOVIDA_PELO_USUARIO_RECEBEDOR');
    Close;
end;

procedure TfrmPIX_Tela.btnConfirmarClick(Sender: TObject);
begin
    //aqui vou confirmar o recebimento
    ConsultaRecto(True);
    if bRecebido = True then
    begin
        bContinuarPIX := True;
        Close;
    end
    else
     MessageBox(0, 'Atenção', 'Recebimento de PIX não confirmado!', mb_IconInformation + mb_ok);
end;

procedure TfrmPIX_Tela.ConsultaRecto(dMostraMensagem : Boolean);
var PIX : TPix;
begin
    Try
        PIX := TPix.Create(nValorPIX,nCodBancoPIX,'');//informar aqui a cidade da loja

        PIX.ConsultarCobranca(cTXID);

        if PIX.Resultado_Cod = 200 then
        begin
            lblStatus.Caption := 'Situação: '+PIX.Resultado.status;

            if PIX.Resultado.status = 'CONCLUIDA' then
            begin
                //Verificar se Foi Recebido aqui e Ja alterar para Recebido
                if PIX.RecebidoTagPIX = True then
                begin
                    if Assigned(PIX.Resultado.pix) then  //santander
                    begin//então tem o recebimento
                        bRecebido := True;
//                        GravaPIX(nSeqTabPIX,PIX,'');
                    end
                    else//foi cancelado ou expirado
                     MessageBox(0, 'Atenção','Expirado ou Cancelado!', mb_IconInformation + mb_ok);
                end
                else
                begin
                      bRecebido := True;
//                      GravaPIX(nSeqTabPIX,PIX,'');
                end;
            end;
        end
        else
        begin
            if dMostraMensagem = True then
              MessageBox(0, 'Atenção',PChar('Erro ao Consultar o PIX, tente novamente!'#13#10+PIX.Retorno), mb_IconInformation + mb_ok);
        end;
    Finally
      pix.Free;
    End;
end;

procedure TfrmPIX_Tela.btnImprQrCodeClick(Sender: TObject);
begin
        try

//                NomeImpr('PIX');     /

          ACBrPosPrinterPIX.Modelo               := TACBrPosPrinterModelo( ppEscPosEpson ); //EscPosEpson
          ACBrPosPrinterPIX.PaginaDeCodigo       := TACBrPosPaginaCodigo( pc850 );//pc850
          ACBrPosPrinterPIX.Porta                := 'TCP:localhost';//pela rede TCP:192.168.0.30
          ACBrPosPrinterPIX.ColunasFonteNormal   := 48;
          ACBrPosPrinterPIX.LinhasEntreCupons    := 1;
          ACBrPosPrinterPIX.EspacoEntreLinhas    := 1;
          ACBrPosPrinterPIX.LinhasBuffer         := 0;
          ACBrPosPrinterPIX.CortaPapel    := True;
          ACBrPosPrinterPIX.TraduzirTags  := True;

          //Configurando o QrCOde
          ACBrPosPrinterPIX.configqrcode.Tipo               := 2;
          ACBrPosPrinterPIX.configqrcode.LarguraModulo      := 6;//4;
          ACBrPosPrinterPIX.configqrcode.ErrorLevel         := 0;

          //aplicando
          mImp.Lines.Clear;
          mImp.Lines.Add('</zera>');
          mImp.Lines.Add('</ce>');
          mImp.Lines.Add('<a><n>'+cFantasia+'</n></a>');
          mImp.Lines.Add('</ce>');
          mImp.Lines.Add('<qrcode>'+cQrCode+'</qrcode>');
          mImp.Lines.Add('</ce>');
          mImp.Lines.Add('<n><e><a>'+lblValor.Caption+'</a></e></n>');
          mImp.Lines.Add('</fn>');
          mImp.Lines.Add('</ce>');
          mImp.Lines.Add('</corte_total>');
          ACBrPosPrinterPIX.Ativar;
          ACBrPosPrinterPIX.Buffer.Text := mImp.Lines.Text;
          ACBrPosPrinterPIX.Imprimir;

      finally
          ACBrPosPrinterPIX.Desativar;
      end;
end;

procedure TfrmPIX_Tela.FormCreate(Sender: TObject);
begin
    bRecebido     := False;

    bContinuarPIX := False;
    nCodBancoPIX  := 0;
    nValorPIX     := 0;
    cMensagemPIX  := '';
    cDevedor_Nome := '';
    cDevedor_CPF  := '';
    cInfo_adicionais_Nome  := '';
    cInfo_adicionais_Valor := '';
    cCidadeLoja            := '';

    cTXID         := '';

    cQrCode   := '';
    cFantasia := '';

end;

procedure TfrmPIX_Tela.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_Escape then
  begin
    Key := 0;
    btnCancelar.SetFocus;
    btnCancelar.Click;
  end;
  if key = VK_F4 then
  begin
  //    ConfigRelat('PIX','BOBINA','S','2','0000');
  end;
end;

procedure TfrmPIX_Tela.FormShow(Sender: TObject);
begin
    qryPesq.Close;
    qryPesq.SQL.Clear;
    qryPesq.SQL.Add('SELECT RAZAO,EMAIL_COMERCIAL, FANTASIA, CIDADE FROM LOJAS');
    qryPesq.SQL.Add('WHERE CODIGO = :COD');
    qryPesq.ParamByName('COD').AsString := cLoja;
    qryPesq.Open;
    if not qryPesq.IsEmpty then
    begin
        cFantasia   := qryPesq.FieldByName('FANTASIA').AsString;
        cCidadeLoja := qryPesq.FieldByName('CIDADE').AsString;
    end;
    qryPesq.Close;

    if nCodBancoPIX > 0 then
        Gerar;

    lblValor.Caption := 'R$ '+FormatFLoat('###,###,##0.00',nValorPIX);
end;

procedure TfrmPIX_Tela.Gerar;
var PIX : TPix;
    cValor : String;
begin
    Try
        PIX := TPix.Create(nValorPIX,nCodBancoPIX,cCidadeLoja);//Informar aqui a cidade da loja

        PIX.info_adicionais_Nome  := cInfo_adicionais_Nome;
        PIX.info_adicionais_Valor := cInfo_adicionais_Valor;

        if ((cDevedor_CPF <> '') and (cDevedor_Nome <> '')) then
        begin //05071810000152
            if Length(Limpalixo(cDevedor_CPF)) = 14 then
                PIX.Devedor_Documento_Tipo  := pJuridica
            else
                PIX.Devedor_Documento_Tipo  := pFisica;
            PIX.Devedor_Documento       := cDevedor_CPF;
            PIX.Devedor_Nome            := cDevedor_Nome;
        end;

        PIX.PIXMensagem := cMensagemPIX;

        PIX.CriarCobranca;//Gerando uma Cobrança

        if PIX.Resultado_Cod = 200 then
        begin
            //Gravar na Tabela PIX
            GravaPIX(0,PIX,'');



//            btnAtualQRCODE.Tag := 1;//Gerado

            //TimerConsultar.enabled := True;

            lblStatus.Caption := 'Situação: '+PIX.Resultado.status;

            //chamar a tela com o PIX
            if PIX.Resultado.textoImagemQRcode <> '' then
            begin
//                PintarQRCodeGiGa(PIX.Resultado.textoImagemQRcode, imgQRCODE.Picture.Bitmap);
                cQrCode := PIX.Resultado.textoImagemQRcode;
            end
            else
            begin
//                PintarQRCodeGiGa(PIX.Resultado.location, imgQRCODE.Picture.Bitmap);
                cQrCode := PIX.Resultado.location;
            end;
//            edtCopiaCola.Text := cQrCode;

            cValor := StringReplace(PIX.Resultado.valor.original, '.', ',', [rfReplaceAll]);
            lblValor.Caption := 'R$ '+FormatFLoat('###,###,##0.00',StrToCurr(cValor));
        end
        else
        begin
            lblStatus.Caption  := 'Situação: Erro ao Gerar';
            MessageBox(0, 'Atenção', PChar('Erro ao Gerar PIX, tente novamente!'#13#10+PIX.Retorno), mb_IconInformation + mb_ok);
        end;
    Finally
      pix.Free;
    End;
end;

Function TfrmPIX_Tela.NewAddSequencia : Integer;
Begin

End;

Function StrZero(N       : Longint;
                 Tamanho : Integer) : String;
Var
 vMask : String;
 I     : Integer;
Begin
 vMask := '';
 For I := 1 To Tamanho Do
  vMask := vMask + '0';
 Result := FormatFloat(vMask, N);
End;

procedure TfrmPIX_Tela.GravaPIX(pSequencia: Integer;pPIX : TPix;cStatus : String);
Var
 cOper,
 cCriacao,
 ErrorMsg : String;
begin
 ErrorMsg := '';
    Try
//     Start_Transacao(1);
     CDSPIX.Close;
     qryPIX.ParamByName('SEQ').AsInteger := pSequencia;
     CDSPIX.Open;
     if not CDSPIX.IsEmpty then
     begin
        cOper := 'A';
//        IniciarMatriz(CDSPIX,'N');

        CDSPIX.Edit;
     end
     else
     begin
        cOper := 'I';
//        IniciarMatriz(CDSPIX,'S');

        pSequencia := 0;
        while pSequencia = 0 do
        begin
          pSequencia := NewAddSequencia;

        end;
        pSequencia := StrToInt(LojaSeq+StrZero(StrToInt(pSequencia.ToString),7));

        nSeqTabPIX    := pSequencia;

        CDSPIX.Append;
        CDSPIXSEQUENCIA.AsInteger := pSequencia;


        cCriacao := ppix.Resultado.calendario.criacao;
        cCriacao := copy(cCriacao,9,2)+'/'+copy(cCriacao,6,2)+'/'+copy(cCriacao,1,4)+' '+copy(cCriacao,12,8);

        if cCriacao <> '' then
            CDSPIXCRIACAO.AsDateTime  := StrToDateTime(cCriacao);

        cTXID := ppix.Resultado.txid;//Utilizado para consultar e alterar

        CDSPIXCODCONTA.AsInteger  := nCodBancoPIX;

        if ppix.Resultado.chave <> '' then
            CDSPIXCHAVE.AsString  := ppix.Resultado.chave;
        CDSPIXVALOR.AsCurrency    := nValorPIX;

        if ppix.Resultado.txid <> '' then
            CDSPIXTXID.AsString       := ppix.Resultado.txid;

        CDSPIXDEVEDOR.AsString    := cDevedor_Nome;
        CDSPIXDEVEDOR_CPF.AsString:= Limpalixo(cDevedor_CPF);

        if ppix.Resultado.calendario.expiracao > 0 then
            CDSPIXEXPIRACAO.AsInteger := ppix.Resultado.calendario.expiracao;
     end;

     if ppix.Resultado_Cod = 0 then
     begin
         CDSPIXSTATUS.AsString     := cStatus;
     end
     else
     begin
         if ppix.Resultado.location <> '' then
            CDSPIXLOCATION.AsString   := ppix.Resultado.location;

         if ppix.Resultado.textoImagemQRcode <> '' then
            CDSPIXQRCODE.AsString     := ppix.Resultado.textoImagemQRcode;

         CDSPIXREVISAO.AsInteger   := ppix.Resultado.revisao;
         CDSPIXSTATUS.AsString     := ppix.Resultado.status;
     end;


     //Informação da Gravação
     if bRecebido = True then
     begin
        CDSPIXRECEBIDO.AsString := 'S';
        CDSPIXRECTO_VALOR.AsCurrency  := ppix.Resultado.pix[0].valor;

        cCriacao := ppix.Resultado.pix[0].horario;
        cCriacao := copy(cCriacao,9,2)+'/'+copy(cCriacao,6,2)+'/'+copy(cCriacao,1,4)+' '+copy(cCriacao,12,8);

        if cCriacao <> '' then
        begin
            try
              CDSPIXRECTO_HORARIO.AsDateTime  := StrToDateTime(cCriacao);
            Except//não vou me importar se der erro aqui.

            end;
        end;
     end;

     CDSPIX.Post;
     if (CDSPIX.ApplyUpdates(0) <> 0) then
        Raise Exception.Create ( ErrorMsg );
//     PreparaLog(CDSPIX,cOper,0,'PIX',Usuario,Loja, FormatDateTime('dd/mm/yyyy',DataSistema),FormatDateTime('hh:mm:ss',Time()));
//     Confirma_Transacao(1,True);
    Except
      on Exc:Exception do
      begin
//        Confirma_Transacao(1,False);
        MessageBox(0, 'Atenção', PChar('Houve um erro na tentativa de salvar o registro. Tente novamente!'+ Exc.Message), mb_IconInformation + mb_ok);
      end;
    end;
end;

procedure TfrmPIX_Tela.TimerConsultarTimer(Sender: TObject);
begin
{    TimerConsultar.enabled := False;
    ConsultaRecto(True);
    if bRecebido = True then
    begin
        bContinuarPIX := True;
        Close;
    end
    else
        TimerConsultar.enabled := True;}
end;

procedure TfrmPIX_Tela.Atualizar(cStatus:String);
var PIX : TPix;
    cValor : String;
begin
    Try
        PIX := TPix.Create(nValorPIX,nCodBancoPIX,cCidadeLoja);//informar aqui a cidade da loja

        PIX.info_adicionais_Nome  := cInfo_adicionais_Nome;
        PIX.info_adicionais_Valor := cInfo_adicionais_Valor;

        if ((cDevedor_CPF <> '') and (cDevedor_Nome <> '')) then
        begin //05071810000152
            if Length(Limpalixo(cDevedor_CPF)) = 14 then
                PIX.Devedor_Documento_Tipo  := pJuridica
            else
                PIX.Devedor_Documento_Tipo  := pFisica;
            PIX.Devedor_Documento       := cDevedor_CPF;
            PIX.Devedor_Nome            := cDevedor_Nome;
        end;

        PIX.PIXMensagem := cMensagemPIX;

        PIX.RevisarCobranca(cTXID,cStatus);//Gerando uma Cobrança

        if PIX.Resultado_Cod = 200 then
        begin
            GravaPIX(nSeqTabPIX,PIX,'');

            //chamar a tela com o PIX
            if PIX.Resultado.textoImagemQRcode <> '' then
            begin
//                PintarQRCodeGiGa(PIX.Resultado.textoImagemQRcode, imgQRCODE.Picture.Bitmap);
                cQrCode := PIX.Resultado.textoImagemQRcode;
            end
            else
            begin
//                PintarQRCodeGiGa(PIX.Resultado.location, imgQRCODE.Picture.Bitmap);
                cQrCode := PIX.Resultado.location;
            end;
//            edtCopiaCola.Text := cQrCode;

            lblStatus.Caption := 'Situação: '+PIX.Resultado.status;

            cValor := StringReplace(PIX.Resultado.valor.original, '.', ',', [rfReplaceAll]);
            lblValor.Caption := 'R$ '+FormatFLoat('###,###,##0.00',StrToCurr(cValor));
        end
        else
        begin
            if PIX.Resultado_Cod = 0 then//Esse banco não faz cancelamento ou Alteracao
            begin
                 GravaPIX(nSeqTabPIX,PIX,cStatus);//Marcar cancelado no sistema;
            end
            else
             MessageBox(0, 'Atenção', PChar('Erro ao Gerar PIX, tente novamente!'#13#10+PIX.Retorno), mb_IconInformation + mb_ok);
        end;
    Finally
      pix.Free;
    End;
end;

end.
