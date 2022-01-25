unit PIX;

interface

uses System.Generics.collections,Data.DB,
 System.SysUtils, System.Classes, PIX_Parametros,
  uDWConstsData, uRESTDWPoolerDB,
  uDWConsts,ServerUtils,DWDCPbase64,IdSSLOpenSSL,IdHTTP,IdHashMessageDigest,
  ACBrUtil, IdGlobal, Vcl.Dialogs, System.ZLib, Winapi.Windows, System.StrUtils,
  Rest.JSON, System.JSON;

type

  //Tipos de Variaveis
  TPSP          = (pspSicredi, pspBancoDoBrasil, pspBradesco,pspSantander,pspSicoob);
  TTipoChavePIX = (tcCPF_CNPJ, tcTelefone, tcEmail, tcOutro);
  TTipoQrCode   = (tqDinamico, tqEstatico);
  TTipoAmbiente = (taSandBox,taHomologacao,taProducao);
  TPessoaDevedor = (pFisica, pJuridica);


  TPix = class
  private

    FPIXValorPix  : Currency;
    FPIXMensagem  : String;

    FPIXCodConta  : Integer;

    FURLApi       : string;

    FCob          : String;

    FURLToken     : String;

    fdeveloper_application_key : String;


    fCertificado_Nome : String;
    fCertificado_Senha: String;





    FPSP          : TPSP;
    FTipoChavePIX : TTipoChavePIX;
    FTipoAmbiente : TTipoAmbiente;
    FChavePIX     : String;
    FClient_ID    : String;
    FClient_Secret: String;
    fCNPJRecebedor: String;
    fTXID         : String;

    fPIXCidadeLoja: String;

    fRecebidoTagPIX : Boolean;

    fPermiteRevisar  : Boolean;
    fPermiteCancelar : Boolean;


    fInstanteGeradoToken: Cardinal;

    fAcess_token  : string;
    fExpires_in   : Integer;
    fToken_type   : string;
    fScope        : string;

    fIDX            : String;


    fDevedor_Nome           : String;
    fDevedor_Documento      : String;
    fDevedor_Documento_Tipo : TPessoaDevedor;


    Finfoadicionais_Nome    : String;  //não vou deixar lista, sem necessidade
    Finfoadicionais_Valor   : String;

    fResultado_Cod          : Integer;

    fRetorno: string;

    fResultado : TPix_Parametros;



    procedure GetContaBancaria();
    procedure GetURLToken();
    procedure GetToKEN;
    procedure SetTXId; //busca ACCES TOKEN

    procedure SetCriadoExpiraBD;
    function MD5(const texto: string): string;
    Function GeraEMV_Payload:String;
    function ZeroAEsquerda(ADado: string): string;
    function GetValue(Id, Value: string): string;
    function GetUniquePayment: string;
    function GetMerchantAccountInformation: string;
    function GetAdditionalDataFieldTemplate: string;
    function GetCRC16(Payload: string): string;
    function CRC16CCITT(texto: string): WORD;
    function StrZero(Numero: string; Quant: integer): String;
    function ExtraiNumero(Texto: String): String;
    function TirarAcentoE(Texto: string): widestring;


  public

    property Devedor_Nome           : String          read fDevedor_Nome           write fDevedor_Nome;
    property Devedor_Documento      : String          read fDevedor_Documento      write fDevedor_Documento;
    property Devedor_Documento_Tipo : TPessoaDevedor  read fDevedor_Documento_Tipo write fDevedor_Documento_Tipo;
    property info_adicionais_Nome   : String          read Finfoadicionais_Nome    write Finfoadicionais_Nome;
    property info_adicionais_Valor  : String          read Finfoadicionais_Valor   write Finfoadicionais_Valor;
    property PIXMensagem            : String          read FPIXMensagem            write FPIXMensagem;

    property Retorno                : string          read fRetorno;

    property Resultado_Cod          : Integer         read fResultado_Cod          write fResultado_Cod;
    property Resultado              : TPix_Parametros read fResultado              write fResultado;

    property RecebidoTagPIX         : Boolean         read fRecebidoTagPIX         write fRecebidoTagPIX;









    procedure CriarCobranca;//Cob_PUT; //Criação e Atualização de Cobrança
    procedure RevisarCobranca(cTXID,cStatus:String); //Alteração de uma Cobrança

    procedure ConsultarCobranca(TXID:String);



    constructor Create(PIXValorPix : Currency;PIXCodConta : Integer;PIXCidadeLoja : String);

//    destructor Destroy;override;

  end;

  const
    ID_PAYLOAD_FORMAT_INDICATOR                 = '00';
    ID_POINT_OF_INITIATION_METHOD               = '01';
    ID_MERCHANT_ACCOUNT_INFORMATION             = '26';
    ID_MERCHANT_ACCOUNT_INFORMATION_GUI         = '00';
    ID_MERCHANT_ACCOUNT_INFORMATION_KEY         = '01';
    ID_MERCHANT_ACCOUNT_INFORMATION_DESCRIPTION = '02';
    ID_MERCHANT_ACCOUNT_INFORMATION_URL         = '25';
    ID_MERCHANT_CATEGORY_CODE                   = '52';
    ID_TRANSACTION_CURRENCY                     = '53';
    ID_TRANSACTION_AMOUNT                       = '54';
    ID_COUNTRY_CODE                             = '58';
    ID_MERCHANT_NAME                            = '59';
    ID_MERCHANT_CITY                            = '60';
    ID_ADDITIONAL_DATA_FIELD_TEMPLATE           = '62';
    ID_ADDITIONAL_DATA_FIELD_TEMPLATE_TXID      = '05';
    ID_CRC16                                    = '63';





implementation

{ TPix }

uses PIX_Tela;


function TPix.StrZero(Numero:string;Quant:integer):String;
var
  I:integer;
  Retorno : String;
begin
  Retorno := '';
  for I:=1 to quant-Length(Numero) do
    Retorno := Retorno + '0';
  Retorno := Retorno + Numero;
  StrZero := Retorno;
end;


procedure TPix.SetCriadoExpiraBD;
begin
    //atualizo na conta bancaria a data de criação e quando expira a chave
    {try
        Start_Transacao(1);

        frmPIX_Tela.CDSContaBancaria.Close;
        frmPIX_Tela.qryContaBancaria.ParamByName('CODCONTA').AsInteger := FPIXCodConta;
        frmPIX_Tela.CDSContaBancaria.Open;

        frmPIX_Tela.CDSContaBancaria.Edit;
        frmPIX_Tela.CDSContaBancariaACCES_TOKEN_CRIADO.AsInteger  := fInstanteGeradoToken;
        frmPIX_Tela.CDSContaBancariaACCES_TOKEN_EXPIRA.AsInteger  := fExpires_in;
        frmPIX_Tela.CDSContaBancariaACCES_TOKEN.AsString          := fAcess_token;
        frmPIX_Tela.CDSContaBancaria.Post;

        if (frmPIX_Tela.CDSContaBancaria.ApplyUpdates(0) <> 0) then
            Raise Exception.Create ( ErrorMsg );

        Confirma_Transacao(1,True);
    Except
      on Exc:Exception do
      begin
        Confirma_Transacao(1,False);
      end;
    end;
    frmPIX_Tela.CDSContaBancaria.Close;}
end;

function TPix.MD5(const texto:string):string;
var
  idmd5 : TIdHashMessageDigest5;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  try
    result := idmd5.HashStringAsHex(texto);
  finally
    idmd5.Free;
  end;
end;

procedure TPix.SetTXId();
var Uid: TGuid;
    idmd5 : TIdHashMessageDigest5;
begin
    CreateGUID(Uid);
    // Montando o TIID
    fTXID := {ExtraiNumero(fCNPJRecebedor)+}Uid.ToString;

    if Length(fTXID) < 26 then
        StrZero(fTXID, 26);


    fTXID := MD5(fTXID);
end;

procedure TPix.GetURLToken();
begin
  if FTipoAmbiente = taSandBox then
  begin
    case FPSP of
      pspSicredi      : begin
                          FURLToken       := '';
                          FURLAPI         := '';

                          FCob            := '/cob/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspBancoDoBrasil: begin
                          FURLToken     := '';
                          FURLAPI       := '';
                          FCob          := '/cobqrcode/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspSantander: begin
                          FURLToken       := 'https://pix.santander.com.br/sandbox/oauth/token';
                          FURLAPI         := 'https://pix.santander.com.br/api/v1/sandbox';
                          FCob            := '/cob/{txid}';
                          fRecebidoTagPIX := True;

                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;

      pspSicoob: begin
                          FURLToken       := '';
                          FURLAPI         := '';
                          FCob            := '/cob/{txid}';
                          fRecebidoTagPIX := True;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspBradesco     : begin
                          FURLToken     := '';
                          FURLAPI       := '';
                          FCob          := '/cob/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
    end;
  end
  else if FTipoAmbiente = taHomologacao then
  begin
    case FPSP of
      pspSicredi      : begin
                          FURLToken       := 'https://api-pix-h.sicredi.com.br/oauth/token';  //pode ser diferente a URL do TOKEN para URL de consumo API
                          FURLAPI         := 'https://api-pix-h.sicredi.com.br/v2';

                          FCob            := '/cob/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspBancoDoBrasil: begin
                          FURLToken     := 'https://oauth.hm.bb.com.br/oauth/token';
                          FURLAPI       := 'https://api.hm.bb.com.br/pix/v1';
                          FCob          := '/cobqrcode/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspSantander: begin
                          FURLToken       := 'https://trust-pix-h.santander.com.br/oauth/token';
                          FURLAPI         := 'https://trust-pix-h.santander.com.br/api/v1';
                          FCob            := '/cob/{txid}';
                          fRecebidoTagPIX := True;

                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;

      pspSicoob: begin
                          FURLToken       := 'https://api-homol.sicoob.com.br/cooperado/pix/token';
                          FURLAPI         := 'https://api-homol.sicoob.com.br/cooperado/pix/api/v2';
                          FCob            := '/cob/{txid}';
                          fRecebidoTagPIX := True;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspBradesco     : begin
                          FURLToken     := '';
                          FURLAPI       := '';
                          FCob          := '/cob/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
    end;
  end
  else if FTipoAmbiente = taProducao then
  begin
    case FPSP of
      pspSicredi      : begin
                          FURLToken     := '';
                          FURLAPI       := '';
                          FCob          := '/cob/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspBancoDoBrasil: begin
                          FURLToken     := '';
                          FURLAPI       := '';
                          FCob          := '/cobqrcode/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
      pspSantander    : begin
                          FURLToken       := 'https://trust-pix.santander.com.br/oauth/token';
                          FURLAPI         := 'https://trust-pix.santander.com.br/api/v1';

                          FCob          := '/cob/{txid}';
                          fRecebidoTagPIX := True;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
       pspSicoob:       begin
                          FURLToken       := '';
                          FURLAPI         := '';
                          FCob            := '/cob/{txid}';
                          fRecebidoTagPIX := True;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;

      pspBradesco     : begin
                          FURLToken     := '';
                          FURLAPI       := '';
                          FCob          := '/cob/{txid}';
                          fRecebidoTagPIX := False;
                          fPermiteRevisar := False;
                          fPermiteCancelar  := False;
                        end;
    end;
  end;

  if FURLToken = '' then
    FURLToken := 'URL do Token deve ser informada.';
end;

function TPix.ExtraiNumero(Texto : String) : String;
var
  X : SmallInt;
  Ret : String;
begin
  for X := 1 to Length(Texto) do
  begin
    if Pos(Copy(Texto,X,1),'0123456789') > 0 then
      Ret := Ret + Copy(Texto,X,1);
  end;
  Result := Ret;
end;

procedure TPix.RevisarCobranca(cTXID,cStatus: String);
var
  cURL         : string;
  cValor       : string;
  cdata        : string;


  DataToSend    : TStringStream;
  sRetorno       : TStringStream;

  JsonDevedor: TJsonObject;


  RequestBody : TStringList;

  nResp : Integer;

  Stream: TStringStream;

  JsonValor      : TJsonObject;
  JsonCalendario : TJsonObject;
  JsonEnviar     : TJSONObject;

  JSonInfoA      : TJSOnArray;
  JSonInfo       : TJSOnObject;

begin
  if cTXId = '' then
  begin
    fRetorno := 'Campo do ID deve ser informado na transação.';
    Exit;
  end;
  if cStatus = '' then
  begin
    fRetorno := 'Informe o Status para Alteração.';
    Exit;
  end;

  if fAcess_token = '' then
  begin
      fRetorno := 'Erro ao Obter Acces Token';
      Exit;
  end;

  if ((fPermiteRevisar = False) and (cStatus = 'ATIVA')) then//Revisar - Atualizar
  begin
      Resultado_Cod := 00;
      fRetorno := 'Este Banco não permite Atualizar a Cobrança!';
      Exit;
  end;

  if ((fPermiteCancelar = False) and (cStatus <> 'ATIVA')) then//Revisar - Atualizar
  begin
      Resultado_Cod := 00;
      fRetorno := 'Este Banco não permite Cancelar a Cobrança!';
      Exit;
  end;



  cValor := FormatFloat('#0.00',FPIXValorPix);

  if Pos(',', cValor) > 0 then
    cValor := StringReplace(cValor, ',', '.', [rfReplaceAll]);

  try
     Stream       := TStringStream.Create('', TEncoding.UTF8);
     RequestBody  := TStringList.Create;

     //Criando o Objeto Valor
     JsonValor := TJSONObject.Create;
     JsonValor.AddPair('original', cValor);

     //Criando o Objeto Calendario
     JsonCalendario := TJSONObject.Create;
     JsonCalendario.AddPair('expiracao', TJSONNumber.Create(1800));//1800 30 minutos-86400 igual a 24 horas, aqui é em segundo 3600 segundos = 1 h

     //Dados do Devedor
     if ((fDevedor_Documento <> '') and (fDevedor_Nome <> '')) then
     begin
        JsonDevedor := TJSONObject.Create;

        case fDevedor_Documento_Tipo of
          pFisica   : JsonDevedor.AddPair('cpf', ExtraiNumero(fDevedor_Documento));
          pJuridica : JsonDevedor.AddPair('cnpj', ExtraiNumero(fDevedor_Documento));
        end;

        JsonDevedor.AddPair('nome', TirarAcentoE(fDevedor_Nome));
     end;

     //Info Adicionais - Não tenho necessidade de mais de uma informação, por isso vou deixar uma somente
     if ((info_adicionais_Nome <> '') and (info_adicionais_Valor <> '')) then
     begin
        JSonInfoA := TJSOnArray.Create;//Criando a Lista de Objetos
        JSonInfo  := TJSOnObject.Create;//Criando o Objeto

        JSonInfo.AddPair('nome',TirarAcentoE(info_adicionais_Nome));
        JSonInfo.AddPair('valor',TirarAcentoE(info_adicionais_Valor));

        JSonInfoA.AddElement(JSonInfo);//Adicionando o Objeto na Lista de Objetos
     end;

     //Montrando o Json a Enviar
     JsonEnviar := TJSOnObject.Create;//Criando o Objeto

     JsonEnviar.AddPair('status', cStatus);
     JsonEnviar.AddPair('chave', fChavePIX);
     JsonEnviar.AddPair('calendario', JsonCalendario);
     if Assigned(JsonDevedor) then
        JsonEnviar.AddPair('devedor', JsonDevedor);
     JsonEnviar.AddPair('valor', JsonValor);
     JsonEnviar.AddPair('solicitacaoPagador', TirarAcentoE(FPIXMensagem));

     if Assigned(JSonInfoA) then
        JsonEnviar.AddPair('info_adicionais', JSonInfoA);


     cdata := JsonEnviar.ToString;

     cURL := fURLAPI + '/cob/{txid}';
     cURL := StringReplace(cURL, '{txid}', cTXId, [rfReplaceAll]);

     if fdeveloper_application_key <> '' then
        cURL := cURL + '?gw-dev-app-key=' + fdeveloper_application_key;

     frmPIX_Tela.DWCR_PIX.ContentType  := 'application/json';
     frmPIX_Tela.DWCR_PIX.UseSSL       := True;
     frmPIX_Tela.DWCR_PIX.SSLVersions  := [sslvTLSv1_2];

     frmPIX_Tela.DWCR_PIX.AuthenticationOptions.AuthorizationOption  := rdwAOBearer;
     TRDWAuthOptionBearerClient(frmPIX_Tela.DWCR_PIX.AuthenticationOptions.OptionParams).Token := fAcess_token;

     //body
     RequestBody.Add(JsonEnviar.ToString);//JSON

     fRetorno := JsonEnviar.ToString;

     nResp := frmPIX_Tela.DWCR_PIX.Patch(cURL,requestBody,Stream,false);

     if nResp = 200 then
     begin
          Resultado_Cod := 200;
          fRetorno := UTF8Decode(Stream.DataString);//para poder analisar se esta correto

          Resultado := TJson.JsonToObject<TPix_Parametros>(fRetorno);
          if Resultado.textoImagemQRcode = '' then//gerar CMV
             Resultado.textoImagemQRcode := GeraEMV_Payload;
     end
     else
     begin
         Resultado_Cod := 400;
         fRetorno := UTF8Decode(Stream.DataString);
     end;

  finally

    if Assigned(JsonValor) then
        JsonValor.Free;

     if Assigned(JsonCalendario) then
        JsonCalendario.Free;

     if Assigned(JSonInfo) then
        JSonInfo.Free;

     if Assigned(JsonDevedor) then
        JsonDevedor.Free;

      Stream.Free;
  end;

end;

function TPix.TirarAcentoE(Texto: string): widestring;
  const
    ComAcentuacao = ' &àáâãäèéêëìíîïòóôõöùúûüçÀÁÁÂÃÄÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÇ`´ª°ºªÇÚ,<>'+'''';
    SemAcentuacao = ' EaaaaaeeeeiiiiooooouuuucAAAAAAEEEEIIIIOOOOOUUUUCC  aooaCU               ';
  var
    i : Integer;
begin
  for i:=1 to Length(Texto) do
    if Pos(Texto[i],ComAcentuacao) <> 0 then
      Texto[i]:=SemAcentuacao[Pos(Texto[i],ComAcentuacao)];

  Result:=Trim(Texto);
end;


procedure TPix.CriarCobranca;//Cob_PUT;//o TXID é pego na busca da conta
var
  cURL         : string;
  cValor       : string;
  cdata        : string;


  DataToSend    : TStringStream;
  sRetorno       : TStringStream;

  JsonDevedor: TJsonObject;


   RequestBody : TStringList;

   nResp : Integer;

   Stream: TStringStream;

   JsonValor      : TJsonObject;
   JsonCalendario : TJsonObject;
   JsonEnviar     : TJSONObject;

   JSonInfoA      : TJSOnArray;
   JSonInfo       : TJSOnObject;

begin
  SetTXId();//crio o TXID
  if fTXId = '' then
  begin
    fRetorno := 'Campo do ID deve ser informado na transação.';
    Exit;
  end;

  if fAcess_token = '' then
  begin
      fRetorno := 'Erro ao Obter Acces Token';
      Exit;
  end;

  cValor := FormatFloat('#0.00',FPIXValorPix);

  if Pos(',', cValor) > 0 then
    cValor := StringReplace(cValor, ',', '.', [rfReplaceAll]);

  try
     Stream       := TStringStream.Create('', TEncoding.UTF8);
     RequestBody  := TStringList.Create;

     //Criando o Objeto Valor
     JsonValor := TJSONObject.Create;
     JsonValor.AddPair('original', cValor);

     //Criando o Objeto Calendario
     JsonCalendario := TJSONObject.Create;
     JsonCalendario.AddPair('expiracao', TJSONNumber.Create(1800));//aqui é em segundo 3600 segundos = 1 h

     //Dados do Devedor
     if ((fDevedor_Documento <> '') and (fDevedor_Nome <> '')) then
     begin
        JsonDevedor := TJSONObject.Create;

        case fDevedor_Documento_Tipo of
          pFisica   : JsonDevedor.AddPair('cpf', ExtraiNumero(fDevedor_Documento));
          pJuridica : JsonDevedor.AddPair('cnpj', ExtraiNumero(fDevedor_Documento));
        end;

        JsonDevedor.AddPair('nome', copy(TirarAcentoE(fDevedor_Nome),1,200)); //<200
     end;

     //Info Adicionais - Não tenho necessidade de mais de uma informação, por isso vou deixar uma somente
     if ((info_adicionais_Nome <> '') and (info_adicionais_Valor <> '')) then
     begin
        JSonInfoA := TJSOnArray.Create;//Criando a Lista de Objetos
        JSonInfo  := TJSOnObject.Create;//Criando o Objeto

        JSonInfo.AddPair('nome',TirarAcentoE(info_adicionais_Nome));
        JSonInfo.AddPair('valor',TirarAcentoE(info_adicionais_Valor));

        JSonInfoA.AddElement(JSonInfo);//Adicionando o Objeto na Lista de Objetos
     end;

     //Montrando o Json a Enviar
     JsonEnviar := TJSOnObject.Create;//Criando o Objeto

     JsonEnviar.AddPair('calendario', JsonCalendario);
     if Assigned(JsonDevedor) then
        JsonEnviar.AddPair('devedor', JsonDevedor);
     JsonEnviar.AddPair('valor', JsonValor);

     JsonEnviar.AddPair('chave', fChavePIX);

     JsonEnviar.AddPair('solicitacaoPagador', TirarAcentoE(FPIXMensagem));

     if Assigned(JSonInfoA) then
        JsonEnviar.AddPair('info_adicionais', JSonInfoA);


     cdata := JsonEnviar.ToString;

     cURL := fURLAPI + FCob;
     cURL := StringReplace(cURL, '{txid}', fTXId, [rfReplaceAll]);

     if fdeveloper_application_key <> '' then
        cURL := cURL + '?gw-dev-app-key=' + fdeveloper_application_key;

     frmPIX_Tela.DWCR_PIX.ContentType  := 'application/json';
     frmPIX_Tela.DWCR_PIX.UseSSL       := True;
     frmPIX_Tela.DWCR_PIX.SSLVersions  := [sslvTLSv1_2];

     frmPIX_Tela.DWCR_PIX.AuthenticationOptions.AuthorizationOption  := rdwAOBearer;
     TRDWAuthOptionBearerClient(frmPIX_Tela.DWCR_PIX.AuthenticationOptions.OptionParams).Token := fAcess_token;

     //body
     RequestBody.Add(JsonEnviar.ToString);//JSON

     fRetorno := JsonEnviar.ToString;

     //exit;

     nResp := frmPIX_Tela.DWCR_PIX.Put(cURL,requestBody,Stream,false);

     if ((nResp = 200) or (nResp = 201)) then
     begin
          Resultado_Cod := 200;
          fRetorno := UTF8Decode(Stream.DataString);//para poder analisar se esta correto

          Resultado := TJson.JsonToObject<TPix_Parametros>(fRetorno);

          if Resultado.textoImagemQRcode = '' then//gerar CMV
             Resultado.textoImagemQRcode := GeraEMV_Payload;
     end
     else
     begin
         Resultado_Cod := 400;
         fRetorno := UTF8Decode(Stream.DataString);
     end;

  finally

    if Assigned(JsonValor) then
        JsonValor.Free;

     if Assigned(JsonCalendario) then
        JsonCalendario.Free;

     if Assigned(JSonInfo) then
        JSonInfo.Free;

     if Assigned(JsonDevedor) then
        JsonDevedor.Free;


      Stream.Free;
  end;
end;

procedure TPix.ConsultarCobranca(TXID: String);
var
  cURL         : string;
  cValor       : string;
  cdata        : string;


  DataToSend    : TStringStream;
  sRetorno       : TStringStream;

  JsonDevedor: TJsonObject;


  nResp : Integer;

  Stream: TStringStream;

  JsonValor      : TJsonObject;
  JsonCalendario : TJsonObject;
  JsonEnviar     : TJSONObject;

  JSonInfoA      : TJSOnArray;
  JSonInfo       : TJSOnObject;

begin
  if TXId = '' then
  begin
    fRetorno := 'Campo do ID deve ser informado na transação.';
    Exit;
  end;

  if fAcess_token = '' then
  begin
      fRetorno := 'Erro ao Obter Acces Token';
      Exit;
  end;

  try
     Stream       := TStringStream.Create('', TEncoding.UTF8);

     cURL := fURLAPI + '/cob/{txid}';
     cURL := StringReplace(cURL, '{txid}', TXId, [rfReplaceAll]);

     if fdeveloper_application_key <> '' then
         cURL := cURL + '?gw-dev-app-key=' + fdeveloper_application_key;

     frmPIX_Tela.DWCR_PIX.ContentType  := 'application/json';
     frmPIX_Tela.DWCR_PIX.UseSSL       := True;
     frmPIX_Tela.DWCR_PIX.SSLVersions  := [sslvTLSv1_2];

     frmPIX_Tela.DWCR_PIX.AuthenticationOptions.AuthorizationOption  := rdwAOBearer;
     TRDWAuthOptionBearerClient(frmPIX_Tela.DWCR_PIX.AuthenticationOptions.OptionParams).Token := fAcess_token;

     nResp := frmPIX_Tela.DWCR_PIX.Get(cURL,Nil,Stream,false);

     if nResp = 200 then
     begin
          Resultado_Cod := 200;
          fRetorno := UTF8Decode(Stream.DataString);//para poder analisar se esta correto

          Resultado := TJson.JsonToObject<TPix_Parametros>(fRetorno);
     end
     else
     begin
         Resultado_Cod := 400;
         fRetorno := UTF8Decode(Stream.DataString);
     end;

  finally
      Stream.Free;
  end;
end;

constructor TPix.Create(PIXValorPix: Currency; PIXCodConta: Integer;PIXCidadeLoja : String);
var TempoToken: Integer;
    cVersao : String;

    fAgora: Cardinal;
begin
  frmPIX_Tela.DWCR_PIX.ConnectTimeOut := 10000;
  frmPIX_Tela.DWCR_PIX.RequestTimeOut := 10000;

  FPIXValorPix  := PIXValorPix;
  FPIXCodConta  := PIXCodConta;

  fPIXCidadeLoja:= PIXCidadeLoja;

  //Inicializando as variaveis
  FURLToken     := '';
  fAcess_token  := '';
  FChavePIX     := '';
  FClient_ID    := '';
  FClient_Secret:= '';
  fTXID         := '';

  fCertificado_Nome := '';
  fCertificado_Senha:= '';


  Resultado_Cod := 0;

  //Iniciando
  GetContaBancaria();//Busca as informações da conta bancaria

  GetURLToken();//busca as URLs e parametros do banco escolhido


  if (fAcess_token = '') then
    GetToKEN
  else
  begin
    fAgora := GetTickCount;//pegando a hora que gerou o token
                        //momento Atual - momento que foi gerado
    TempoToken := Trunc((fAgora - fInstanteGeradoToken) / 1000);

    TempoToken := (TempoTOken * 1000);//Milegundos
    if TempoToken >= fExpires_in then
        GetToKEN
    else
        fRetorno := fAcess_token;
  end;
end;


function TPix.CRC16CCITT(texto: string): WORD;
const polynomial = $1021;
var crc: WORD;
    i, j: Integer;
    b: Byte;
    bit, c15: Boolean;
begin
    crc := $FFFF;
    for i := 1 to length(texto) do
    begin
        b := Byte(texto[i]);
        for j := 0 to 7 do
        begin
            bit := (((b shr (7 - j)) and 1) = 1);
            c15 := (((crc shr 15) and 1) = 1);
            crc := crc shl 1;
            if (c15 xor bit) then
              crc := crc xor polynomial;
        end;
    end;
    Result := crc and $FFFF;
end;

function TPix.ZeroAEsquerda(ADado: string): string;
begin
  if length(ADado) = 1 then Result := '0' + ADado else Result := ADado;
end;

function TPix.GetValue(Id, Value: string): string;
var Size:  Integer;
begin
  if Length(Value) < 2 then
    Value := StrZero(Value, 2);
  Size := Length(Value);

  Result := Id + IfThen(Size < 10, StrZero(Size.ToString, 2), Size.ToString) + Value;
end;

function TPix.GetUniquePayment: string;
begin
    Result := GetValue(ID_POINT_OF_INITIATION_METHOD,'12');
end;

function TPix.GetMerchantAccountInformation: string;
var
  Gui: string;
  Url: string;
begin
  //DOMÍNIO DO BANCO
  Gui := GetValue(ID_MERCHANT_ACCOUNT_INFORMATION_GUI,'br.gov.bcb.pix');

  //URL DO QR CODE DINÂMICO
  Url := IfThen(Length(Resultado.location) > 0, GetValue(ID_MERCHANT_ACCOUNT_INFORMATION_URL, Resultado.location), '');

  //VALOR COMPLETO DA CONTA
  Result  := GetValue(ID_MERCHANT_ACCOUNT_INFORMATION, Gui + Url);
end;

function TPix.GetAdditionalDataFieldTemplate: string;
var
  TxId: string;
begin
  //TXID
  TxId := GetValue(ID_ADDITIONAL_DATA_FIELD_TEMPLATE_TXID,'***');//fTxid

  //RETORNA O VALOR COMPLETO
  Result := GetValue(ID_ADDITIONAL_DATA_FIELD_TEMPLATE, TxId);
end;

function TPix.GetCRC16(Payload: string): string;
begin
  //ADICIONA DADOS GERAIS NO PAYLOAD
  Payload := Payload + ID_CRC16 + '04';

  Result := ID_CRC16 + '04' + Inttohex(CRC16CCITT(Payload), 4);
end;


function TPix.GeraEMV_Payload():String;//retorna a stringo para incluir no qrcode
var Payload, cDevedor : String;
//    a,b,c,d,e,f,g,h,i,j : String;

begin
    cDevedor  := '';
    if Resultado.Devedor <> Nil then
        cDevedor  := copy(Resultado.Devedor.Nome,1,25);

    //Testando
    {a :=  GetValue(ID_PAYLOAD_FORMAT_INDICATOR,'01');
    b :=  GetUniquePayment();
    c :=  GetMerchantAccountInformation() ;
    d :=  GetValue(ID_MERCHANT_CATEGORY_CODE,'0000');
    e :=  GetValue(ID_TRANSACTION_CURRENCY,'986') ;
    f :=  IfThen(lENGTH(Resultado.Valor.Original) > 0, GetValue(ID_TRANSACTION_AMOUNT, Resultado.Valor.Original), '') ;
    g :=  GetValue(ID_COUNTRY_CODE,'BR') ;
    h :=  GetValue(ID_MERCHANT_NAME,cDevedor) ;
    i :=  GetValue(ID_MERCHANT_CITY, fPIXCidadeLoja) ;
    j :=  GetAdditionalDataFieldTemplate();}



    Payload := GetValue(ID_PAYLOAD_FORMAT_INDICATOR,'01') +
               GetUniquePayment() +
               GetMerchantAccountInformation() +
               GetValue(ID_MERCHANT_CATEGORY_CODE,'0000') +
               GetValue(ID_TRANSACTION_CURRENCY,'986') +
               IfThen(lENGTH(Resultado.Valor.Original) > 0, GetValue(ID_TRANSACTION_AMOUNT, Resultado.Valor.Original), '') +
               GetValue(ID_COUNTRY_CODE,'BR') +
               GetValue(ID_MERCHANT_NAME,cDevedor) +
               GetValue(ID_MERCHANT_CITY, fPIXCidadeLoja) +
               GetAdditionalDataFieldTemplate();

    Result := Payload + GetCRC16(Payload);
end;

procedure TPix.GetContaBancaria;
var cPasta : String;

    BlobStream : TStream;
    FileStream : TFileStream;
begin
    frmPIX_Tela.qryAux_PIX.Close;
    frmPIX_Tela.qryAux_PIX.SQL.Clear;
    frmPIX_Tela.qryAux_PIX.SQL.Add('SELECT CODIGO, LOJA, BANCO, NUMBANCO, ');
    frmPIX_Tela.qryAux_PIX.SQL.Add('AGENCIA, AG_DV, NUMCONTA, DIGITO, ');
    frmPIX_Tela.qryAux_PIX.SQL.Add('CNPJ_CPF, CHAVE_PIX, CLIENT_ID, ');
    frmPIX_Tela.qryAux_PIX.SQL.Add('CLIENT_SECRET,  AMBIENTE, ');
    frmPIX_Tela.qryAux_PIX.SQL.Add('TX_ID, ACCES_TOKEN,CHAVE_PIX_TIPO, ACCES_TOKEN_CRIADO, ACCES_TOKEN_EXPIRA,CERTIFICADO,CERTIFICADO_KEY ');
    frmPIX_Tela.qryAux_PIX.SQL.Add('FROM CONTABANCARIA C ');
    frmPIX_Tela.qryAux_PIX.SQL.Add('WHERE C.CODIGO =:CODCONTA ');
    frmPIX_Tela.qryAux_PIX.ParamByName('CODCONTA').AsInteger := FPIXCodConta;
    frmPIX_Tela.qryAux_PIX.Open;
    if not frmPIX_Tela.qryAux_PIX.IsEmpty then
    begin
        FChavePIX       := frmPIX_Tela.qryAux_PIX.FieldByName('CHAVE_PIX').AsString;
        FCLIENT_ID      := frmPIX_Tela.qryAux_PIX.FieldByName('CLIENT_ID').AsString;
        FCLIENT_Secret  := frmPIX_Tela.qryAux_PIX.FieldByName('CLIENT_SECRET').AsString;
        fCNPJRecebedor  := (frmPIX_Tela.qryAux_PIX.FieldByName('CNPJ_CPF').AsString); //precisa para gerar o TXID

        fdeveloper_application_key := frmPIX_Tela.qryAux_PIX.FieldByName('TX_ID').AsString;

        if frmPIX_Tela.qryAux_PIX.FieldByName('NUMBANCO').AsString = '748' then
            FPSP := pspSicredi
        else if frmPIX_Tela.qryAux_PIX.FieldByName('NUMBANCO').AsString = '1' then
            FPSP := pspBancoDoBrasil
        else if frmPIX_Tela.qryAux_PIX.FieldByName('NUMBANCO').AsString = '33' then
            FPSP := pspSantander
        else if frmPIX_Tela.qryAux_PIX.FieldByName('NUMBANCO').AsString = '347' then
            FPSP := pspBradesco
        else if frmPIX_Tela.qryAux_PIX.FieldByName('NUMBANCO').AsString = '756' then
            FPSP := pspSicoob;



        if copy(frmPIX_Tela.qryAux_PIX.FieldByName('CHAVE_PIX_TIPO').AsString,1,1) = '0' then
        begin
              FTipoChavePIX := tcCPF_CNPJ;
        end
        else if copy(frmPIX_Tela.qryAux_PIX.FieldByName('CHAVE_PIX_TIPO').AsString,1,1) = '1' then
        begin
              FTipoChavePIX := tcTelefone;
              fChavePIX := '+55' + fChavePIX;
        end
        else if copy(frmPIX_Tela.qryAux_PIX.FieldByName('CHAVE_PIX_TIPO').AsString,1,1) = '2' then
              FTipoChavePIX := tcEmail
        else
              FTipoChavePIX := tcOutro;


        if frmPIX_Tela.qryAux_PIX.FieldByName('AMBIENTE').AsString = '1' then
            FTipoAmbiente := taHomologacao
        else if frmPIX_Tela.qryAux_PIX.FieldByName('AMBIENTE').AsString = '2' then
            FTipoAmbiente := taProducao
        else
            FTipoAmbiente := taSandBox;

        fInstanteGeradoToken  := frmPIX_Tela.qryAux_PIX.FieldByName('ACCES_TOKEN_CRIADO').AsInteger; //pegando quando foi criado
        fExpires_in           := frmPIX_Tela.qryAux_PIX.FieldByName('ACCES_TOKEN_EXPIRA').AsInteger; //pegando quando expira

        fAcess_token          := frmPIX_Tela.qryAux_PIX.FieldByName('ACCES_TOKEN').AsString;

        cPasta := 'd:\Teste';
        //Pegando o certificado digital
        if frmPIX_Tela.qryAux_PIX.FieldByName('CERTIFICADO').AsString <> '' then//tem certificado
        begin
            fCertificado_Nome := cPasta+'\g.pem';

            //Gravando o Arquivo em DISCO
            BlobStream    := frmPIX_Tela.qryAux_PIX.CreateBlobStream(frmPIX_Tela.qryAux_PIX.FieldByName('CERTIFICADO') as TBlobField, bmRead);
            try
                FileStream := TFileStream.Create(fCertificado_Nome, fmCreate);
                try
                    FileStream.CopyFrom(BlobStream, 0);
                finally
                  FileStream.Free;
                end;
            finally
              BlobStream.Free;
            end;


            //VERIFICANDO SE TEM CHAVE
            if frmPIX_Tela.qryAux_PIX.FieldByName('CERTIFICADO_KEY').AsString <> '' then
            begin
                fCertificado_Senha:= cPasta+'\g.Key';

                BlobStream    := frmPIX_Tela.qryAux_PIX.CreateBlobStream(frmPIX_Tela.qryAux_PIX.FieldByName('CERTIFICADO_KEY') as TBlobField, bmRead);
                try
                    FileStream := TFileStream.Create(fCertificado_Senha, fmCreate);
                    try
                        FileStream.CopyFrom(BlobStream, 0);
                    finally
                      FileStream.Free;
                    end;
                finally
                  BlobStream.Free;
                end;

            end;
        end;
    end;
    frmPIX_Tela.qryAux_PIX.Close;
end;

procedure TPix.GetToKEN;
var JsonResponse: TJSONObject;
    Stream: TStringStream;

    nResp : Integer;
    RequestBody : TStringList;
begin
  try
    RequestBody := TStringList.Create;

    Stream := TStringStream.Create('', TEncoding.UTF8);


    frmPIX_Tela.DWCR_PIX.ContentType      := 'application/x-www-form-urlencoded';

    frmPIX_Tela.DWCR_PIX.UseSSL       := True;
    frmPIX_Tela.DWCR_PIX.SSLVersions  := [sslvTLSv1_2];

    frmPIX_Tela.DWCR_PIX.AuthenticationOptions.AuthorizationOption  := rdwOAuth;
    TRDWAuthOAuth(frmPIX_Tela.DWCR_PIX.AuthenticationOptions.OptionParams).ClientID      := fClient_ID;
    TRDWAuthOAuth(frmPIX_Tela.DWCR_PIX.AuthenticationOptions.OptionParams).ClientSecret  := fClient_Secret;

    fInstanteGeradoToken := GetTickCount;//pegando a hora que gerou o token


    case FPSP of
      pspSicredi      : begin
                            RequestBody.Add('grant_type=client_credentials');
                            RequestBody.Add('scope=cob.read cob.write pix.read pix.write');


                        end;
      pspBancoDoBrasil: begin //SAND BOX - OK
                            RequestBody.Add('grant_type=client_credentials');
                            RequestBody.Add('scope=cob.read cob.write pix.read pix.write');


                        end;
      pspSantander    : begin  //sANDbOX - OK
                            frmPIX_Tela.DWCR_PIX.Accept           := '*/*';
                            frmPIX_Tela.DWCR_PIX.AcceptEncoding   := 'gzip, deflate, br';
                            frmPIX_Tela.DWCR_PIX.ContentEncoding  := '';

                            FURLToken := FURLToken+'{param}';
                            FURLToken := StringReplace(FURLToken, '{param}', '?grant_type=client_credentials', [rfReplaceAll]);

                            RequestBody.Add('client_id='+fClient_ID);
                            RequestBody.Add('client_secret='+fClient_Secret);

                            //fCertificado_Nome := 'D:\PIX DOCUMENTOS\0-Certificado_GiGa\giga.pem';
                            //fCertificado_Senha:= 'D:\PIX DOCUMENTOS\0-Certificado_GiGa\giga_dec.key';


                            frmPIX_Tela.DWCR_PIX.CertMode := sslmClient;
                            frmPIX_Tela.DWCR_PIX.CertFile := fCertificado_Nome;
                            frmPIX_Tela.DWCR_PIX.HostCert := 'https://trust-pix-h.santander.com.br';
                            frmPIX_Tela.DWCR_PIX.PortCert := 443;//PADRAO
                            frmPIX_Tela.DWCR_PIX.KeyFile  := fCertificado_Senha;

                        end;
      pspSicoob       : begin
                            RequestBody.Add('grant_type=client_credentials');
                            RequestBody.Add('client_id='+fClient_ID);
                            RequestBody.Add('client_secret='+fClient_Secret);
                            RequestBody.Add('scope=cob.read cob.write pix.read pix.write');


                        end;
      pspBradesco     : begin



                        end;
    end;



    try
      nResp := frmPIX_Tela.DWCR_PIX.Post(FURLToken,requestBody,Stream,false,False);
    Except
        fAcess_token  := '';
        fToken_type   := '';
        fExpires_in   := 0;;

        SetCriadoExpiraBD; //gravando na conta bancaria criacao e expiração

        Exit;
    end;

    if nResp = 200 then
    begin
        fRetorno := UTF8Decode(Stream.DataString);//para poder analisar se esta correto

        JsonResponse := TJSONObject.ParseJsonValue(UTF8Decode(Stream.DataString)) as TJSONObject;

        fAcess_token  := JsonResponse.GetValue<string>('access_token');
        fToken_type   := JsonResponse.GetValue<string>('token_type');
        fExpires_in   := JsonResponse.GetValue<Integer>('expires_in');

        SetCriadoExpiraBD; //gravando na conta bancaria criacao e expiração
    end
    else
       fRetorno := UTF8Decode(Stream.DataString);

  finally
    Stream.Free;
  end;

end;

end.
