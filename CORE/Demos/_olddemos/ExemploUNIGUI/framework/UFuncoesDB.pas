unit UFuncoesDB;

interface

uses
  FireDAC.Comp.Client, uniComboBox, uniGUIForm, uniGUIFrame, uniDBLookupComboBox,
  uniDBEdit, uniEdit, Vcl.Graphics, uDWConstsData,
  uRESTDWPoolerDB{, UniSFSweetAlert};

procedure kernel_RefreshCds(aCds: TRESTDWClientSQL);
procedure Kernel_Preenche_TComobox(var Cb: TUniComboBox;
  Tabela, Campo, condicao: String);
Function InstanciaQuery(): TFDQuery;
function Kernel_Incrementa(TableName, Campo: String): Integer;
function Kernel_Consulta_string(TableName, Campo, where: String): string;
function Kernel_Consulta_boolean(TableName, Campo, where: String): Boolean;
function Kernel_Data_Servidor: Tdatetime;
{ Retorna a data atual do servidor de banco de dados }
function Kernel_Apaga_Rergistro(Tabela, Campo, CampoEmpresa: string; Valor, idEmpresa: Integer; out vError: string): Boolean;
function Kernel_Consulta_Inteiro(TableName, Campo, where: String): Integer;
function Consulta_IBGE(cidade: string; uf: Integer): string;
function Consulta_IDEstado(uf: string): Integer;
function Consulta_EstadoCliente(id, idEmpresa: Integer): String;
procedure Kernel_Abre_Pesquisa(xTabela, xCampoCodigo, xCampoNome, xCampoData,
  xCampoExclusao, xCondicaoauxiliar1, xCampoStatus, xtitulo: string;
  Combo :TUniDBLookupComboBox); overload;
procedure Kernel_Abre_Pesquisa(xTabela, xCampoCodigo, xCampoNome, xCampoData,
  xCampoExclusao, xCondicaoauxiliar1, xCampoStatus, xtitulo: string;
  EDT :TUniDBEdit; EDT_DESC: TUniEdit); overload;
procedure Kernel_Consulta_Dados(TableName, Campo, where: String; EDT :TUniDBEdit;
  EDT_DESC: TUniEdit); overload;
procedure Kernel_Consulta_Dados(TableName, Campo, where: String; EDT :TUniEdit;
  EDT_DESC: TUniEdit); overload;
function Kernel_Remove_Caracteres_Especiais(Texto: string): string;
function Kernel_RetornaDataFuso(Data: Tdatetime; ID_EMPRESA: Integer): Tdatetime;
function Confirma_antesenvio(chavenfe: string; ID_NF: integer; ID_EMPRESA: Integer): Boolean;
function Confirma_envio(recibo, idnota: string; ID_NF: integer; Data_AutNF: TDatetime; ID_EMPRESA: Integer): Boolean;
function Confirma_autorizacao(protocolo, retorno: string;
  ID_NF: integer; Data_AutNF: TDatetime; ID_EMPRESA : Integer): Boolean;
function Retorna_Email_Cliente(id, idempresa: integer): string;
function Confirma_negacao(protocolo, retorno: string;
  ID_NF, idstnfe, codretornoerror: integer; ID_EMPRESA: Integer): Boolean;
function Confirma_cancelamento(protocolo, RetornoNF: string; id: integer;
  Data_CancNFCe: TDatetime; ID_EMPRESA: Integer): Boolean;
function Confirma_Inutilizacao(protocolo: string; id: integer;
  Data_CancNFCe: TDatetime; ID_EMPRESA: Integer): Boolean;
function Log_Inutilizacao(descricao, strSerie: string;
  IDOperador, NumIncial, NumFinal, idEmpresa: Integer): Boolean;
function Confirma_ContEPEC(recibo, idnota: string; ID_NF: integer; protocolo: string; ID_EMPRESA: Integer): Boolean;
function Retorna_Proximo_Evento_CCe(ID_NF, ID_EMPRESA: integer): integer;
function validarCamposRequeridos(const cds: TFDQuery; frame: TUniFrame{; sa: TUniSFSweetAlert}): Boolean; overload;
function validarCamposRequeridos(const cds: TFDQuery; frame: TUniForm{; sa: TUniSFSweetAlert}): Boolean; overload;
function ExecutaSQL(Rest: TRESTDWClientSQL; var vErros: string): Boolean;

Function InstanciaQueryREST(): TRESTDWClientSQL;

function Percentual_Partilha_Origem(Ano: TdateTime): Double;
function Percentual_Partilha_Destino(Ano: TdateTime): Double;

procedure AtivaReadOnly(dados: TRESTDWClientSQL);
procedure desativaReadOnly(dados: TRESTDWClientSQL);

implementation

uses
  System.SysUtils, System.Classes, Data.DB, MainModule,
  UfrmConsultaGenerica, Vcl.Controls, System.DateUtils, Vcl.Dialogs;

procedure AtivaReadOnly(dados: TRESTDWClientSQL);
var
  i: Integer;
begin
  for I := 0 to dados.Fields.Count - 1 do
  begin
     if dados.Fields[i].Tag = 1 then
        dados.Fields[i].ReadOnly := True;
  end;
end;

procedure desativaReadOnly(dados: TRESTDWClientSQL);
var
  i: Integer;
begin
  for I := 0 to dados.Fields.Count - 1 do
  begin
     if dados.Fields[i].Tag = 1 then
        dados.Fields[i].ReadOnly := False;
  end;
end;

function ExecutaSQL(Rest: TRESTDWClientSQL; var vErros: string): Boolean;
begin
  Rest.DataBase.Active := False;
  Rest.DataBase.Active := True;
  Result := Rest.ExecSQL(vErros);
end;

function validarCamposRequeridos(const cds: TFDQuery; frame: TUniForm{; sa: TUniSFSweetAlert}): Boolean;
const
   espaco = '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;- ';
var
   i, aux: Integer;
   campos: TStringList;
begin
   Result := True;
   campos := TStringList.Create;
   aux := 0;
   for i := 0 to cds.FieldCount - 1 do
   begin
      if (cds.Fields[i].Required) and ((cds.Fields[i].IsNull) or
         (cds.Fields[i].asString = '')) then
      begin
         campos.Add(espaco + cds.Fields[i].DisplayLabel);
         if aux = 0 then
            aux := I;
      end;
   end;
   if campos.Count > 0 then
   begin
      frame.MessageDlg('Existem campos obrigatórios que não foram preenchidos neste formulário.'
         + '<br/>' + 'Campos:' + '<br/>' + campos.Text
         + '<br/>' + 'Informe todos os campos com asterisco (*)', mtWarning, [mbOK]);
      try
         cds.Fields[aux].FocusControl;
      except
      end;
      Result := False;
   end;
   campos.Free;
end;

function validarCamposRequeridos(const cds: TFDQuery; frame: TUniFrame{; sa: TUniSFSweetAlert}): Boolean;
const
   espaco = '&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;- ';
var
   i, aux: Integer;
   campos: TStringList;
begin
   Result := True;
   campos := TStringList.Create;
   aux := 0;
   for i := 0 to cds.FieldCount - 1 do
   begin
      if (cds.Fields[i].Required) and ((cds.Fields[i].IsNull) or
         (cds.Fields[i].asString = '')) then
      begin
         campos.Add(espaco + cds.Fields[i].DisplayLabel);
         if aux = 0 then
            aux := I;
      end;
   end;
   if campos.Count > 0 then
   begin
      frame.MessageDlg('Existem campos obrigatórios que não foram preenchidos neste formulário.'
         + '<br/>' + 'Campos:' + '<br/>' + campos.Text
         + '<br/>' + 'Informe todos os campos com asterisco (*)', mtWarning, [mbOK]);
      try
         cds.Fields[aux].FocusControl;
      except
      end;
      Result := False;
   end;
   campos.Free;
end;

function Retorna_Proximo_Evento_CCe(ID_NF, ID_EMPRESA: integer): integer;
var
  Qry: TFDQuery;
begin
  Result := 0;
  Qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with Qry do
    begin
      SQL.Add('select max(SEQUENCIA) sequencia FROM CARTA_CORRECAO_NFE WHERE ID_NF_CABECALHO=:ID_NF_CABECALHO and ID_EMPRESA = :ID_EMPRESA');
      Params[0].AsInteger := ID_NF;
      Params[1].AsInteger := ID_EMPRESA;
      open;

      // Se retornar registro quantos registros existes
      if not IsEmpty then
      begin
        Result := Fields[0].AsInteger + 1;
      end
      else
        Result := 1;

    end;
  finally
    FreeAndNil(Qry); { : libera o objeto da memória }
  end;
end;

function Confirma_ContEPEC(recibo, idnota: string; ID_NF: integer; protocolo: string; ID_EMPRESA: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with Qry do
    Begin
      Close;
      SQL.Clear;
      SQL.Add('update NOTA_FISCAL_CAB set recibonf=:RECIBONF, chavenf=:CHAVENF, '
        + ' id_situacao_nfe=:ID_SITUACAO_NFE, protocolonf=:PROTOCOLONF WHERE id=:ID and ID_EMPRESA = :ID_EMPRESA ');
      ParamByName('RECIBONF').AsString := recibo;
      ParamByName('CHAVENF').AsString := idnota;
      ParamByName('ID_SITUACAO_NFE').AsInteger := 9; // processamento
      ParamByName('PROTOCOLONF').AsString := protocolo;
      ParamByName('ID').AsInteger := ID_NF;
      ParamByName('ID_EMPRESA').AsInteger := ID_EMPRESA;
      ExecSQL();

      Result := not IsEmpty;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

 function Log_Inutilizacao(descricao, strSerie: string;
  IDOperador, NumIncial, NumFinal, idEmpresa: Integer): Boolean;
var
  qry: TFDQuery;
begin
  Result := False;
  qry := InstanciaQuery;
  try
    try
      with qry do
      Begin
        Close;
        SQL.Clear;
        SQL.Add('INSERT INTO LOG_INUTILIZACAO(ID, DATA, DESCRICAO, ID_FUNCIONARIO, NUMERO_INICIAL, NUMERO_FINAL, SERIE, MODELO, ID_EMPRESA)'
          + 'VALUES(:ID, :DATA, :DESCRICAO, :ID_FUNCIONARIO, :NUMERO_INICIAL, :NUMERO_FINAL, :SERIE, :MODELO, :ID_EMPRESA)');
        Params[0].AsInteger := Kernel_Incrementa('LOG_INUTILIZACAO WHERE ID_EMPRESA = ' + IntToStr(idEmpresa), 'ID');
        Params[1].AsDate := Now;
        Params[2].AsString := descricao;
        Params[3].AsInteger := IDOperador;
        Params[4].AsInteger := NumIncial;
        Params[5].AsInteger := NumFinal;
        Params[6].AsString := strSerie;
        Params[7].AsInteger := 55;
        Params[8].AsInteger := idEmpresa;
        ExecSQL();
      end;
    except
      Result := False;
    end;
  finally
    FreeAndNil(qry);
  end;
end;

 function Confirma_Inutilizacao(protocolo: string; id: integer;
  Data_CancNFCe: TDatetime; ID_EMPRESA: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := InstanciaQuery(); { : cria uma instância do objeto }
  try
    try
      with Qry do
      Begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE NOTA_FISCAL_CAB SET protocoloinut=:PROTOCOLOINUT, '
          + ' data_inut=:DATA_INUT, id_situacao_nfe=8  WHERE id=:ID and ID_EMPRESA = :ID_EMPRESA');
        Params[0].AsString := protocolo;
        Params[1].AsDateTime := Data_CancNFCe;
        Params[2].AsInteger := id;
        Params[3].AsInteger := ID_EMPRESA;
        ExecSQL();
      end;
    except
      Result := False;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

function Confirma_cancelamento(protocolo, RetornoNF: string; id: integer;
  Data_CancNFCe: TDatetime; ID_EMPRESA: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := InstanciaQuery(); { : cria uma instância do objeto }
  try
    try
      with Qry do
      Begin
        // ativa no parametro a contigencia
        Close;
        SQL.Clear;
        SQL.Add('UPDATE NOTA_FISCAL_CAB SET protocolocanc=:PROTOCOLOCANC, retornoautnf=:RETORNOAUTNF, '
          + ' data_cancelado=:DATA_CANCELADO, id_situacao_nfe=6,  cancelada=''S'' WHERE id=:ID and ID_EMPRESA = :ID_EMPRESA');
        Params[0].AsString   := protocolo;
        Params[1].AsString   := RetornoNF;
        Params[2].AsDateTime := Data_CancNFCe;
        Params[3].AsInteger  := id;
        Params[4].AsInteger := ID_EMPRESA;
        ExecSQL();

        // Rotina voltar estoque mercadoria
      end;
    except
      Result := False;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

function Confirma_negacao(protocolo, retorno: string;
  ID_NF, idstnfe, codretornoerror: integer; ID_EMPRESA: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with Qry do
    Begin
      Close;
      SQL.Clear;
      SQL.Add('update NOTA_FISCAL_CAB set protocolonegnf=:PROTOCOLONEGNF, '
        + ' retornonegnf=:RETORNONEGNF, id_situacao_nfe=:ID_SITUACAO_NFE, cancelada=''N'', '
        + ' codretornoerror=:CODRETORNOERROR WHERE id=:ID and ID_EMPRESA = :ID_EMPRESA');
      ParamByName('PROTOCOLONEGNF').AsString := protocolo;
      ParamByName('RETORNONEGNF').AsString := retorno;
      ParamByName('ID_SITUACAO_NFE').AsInteger := idstnfe;
      ParamByName('ID').AsInteger := ID_NF;
      ParamByName('CODRETORNOERROR').AsInteger := codretornoerror;
      ParamByName('ID_EMPRESA').AsInteger := ID_EMPRESA;
      ExecSQL();

      Result := not IsEmpty;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

function Retorna_Email_Cliente(id, idempresa: integer): string;
var
  Qry: TFDQuery;
begin
  Result := '';
  Qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with Qry do
    begin
      SQL.Add('select email from CLIENTE_FORNCEDOR where id=:id and id_empresa = :id_empresa');
      Params[0].AsInteger := id;
      Params[1].AsInteger := idempresa;
      open;

      // Se retornar registro quantos registros existes
      if not IsEmpty then
        Result := Fields[0].AsString
    end;
  finally
    FreeAndNil(Qry); { : libera o objeto da memória }
  end;
end;

function Confirma_autorizacao(protocolo, retorno: string;
  ID_NF: integer; Data_AutNF: TDatetime; ID_EMPRESA : Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with Qry do
    Begin
      Close;
      SQL.Clear;
      SQL.Add('update NOTA_FISCAL_CAB set protocolonf=:PROTOCOLONF, retornoautnf=:RETORNOAUTNF, '
        + 'id_tipo_emissao=1, id_situacao_nfe=4, cancelada=''N'', data_autorizacaonf =:DATA_AUTORIZACAONF WHERE id=:ID and ID_EMPRESA = :ID_EMPRESA');
      Params[0].AsString := protocolo;
      Params[1].AsString := retorno;
      Params[2].AsDateTime := Data_AutNF;
      Params[3].AsInteger := ID_NF;
      Params[4].AsInteger := ID_EMPRESA;
      ExecSQL();

      Result := not IsEmpty;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

function Confirma_envio(recibo, idnota: string; ID_NF: integer; Data_AutNF: TDatetime; ID_EMPRESA: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with Qry do
    Begin
      Close;
      SQL.Clear;
      SQL.Add('update NOTA_FISCAL_CAB set recibonf=:RECIBONF, chavenf=:CHAVENF, '
        + ' data_envio_nf=:DATA_ENVIO_NF, id_situacao_nfe=:ID_SITUACAO_NFE WHERE id=:ID and ID_EMPRESA = :ID_EMPRESA ');
      ParamByName('RECIBONF').AsString := recibo;
      ParamByName('CHAVENF').AsString := idnota;
      ParamByName('DATA_ENVIO_NF').AsDateTime := Data_AutNF;
      ParamByName('ID_SITUACAO_NFE').AsInteger := 3; // processamento
      ParamByName('ID_EMPRESA').AsInteger := ID_EMPRESA;
      ParamByName('ID').AsInteger := ID_NF;
      ExecSQL();

      Result := not IsEmpty;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

function Confirma_antesenvio(chavenfe: string; ID_NF: integer; ID_EMPRESA: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with Qry do
    Begin
      Close;
      SQL.Clear;
      SQL.Add('update NOTA_FISCAL_CAB set  chavenf=:CHAVENF WHERE id=:ID and ID_EMPRESA = :ID_EMPRESA ');
      ParamByName('CHAVENF').AsString := chavenfe;
      ParamByName('ID_EMPRESA').AsInteger := ID_EMPRESA;
      ParamByName('ID').AsInteger := ID_NF;
      ExecSQL();

      Result := not IsEmpty;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

function Kernel_RetornaDataFuso(Data: Tdatetime; ID_EMPRESA: Integer): Tdatetime;
var
  strFuso, strFusoSefaz: string;
  qry: TRESTDWClientSQL;
begin
  qry := InstanciaQueryREST; { : cria uma instância do objeto }
  try
    qry.Close;
    qry.SQL.Add('select * FROM EMPRESA WHERE id = ' +
      IntToStr(ID_EMPRESA));
    qry.Open();

    strFuso := qry.FieldByName('FUSOHORARIO').AsString;
    strFusoSefaz := qry.FieldByName('FUSOSEFAZ').AsString;

  finally
    FreeAndNil(qry);
  end;

  if (strFusoSefaz <> strFuso) then
  begin
    if (strFuso = '-02:00') and (strFusoSefaz = '-03:00') then
    begin
      Result := IncHour(Data, -1);
    end
    else if (strFuso = '-02:00') and (strFusoSefaz = '-04:00') then
    begin
      Result := IncHour(Data, -2);
    end
    else if (strFuso = '-03:00') and (strFusoSefaz = '-02:00') then
    begin
      Result := IncHour(Data);
    end
    else if (strFuso = '-03:00') and (strFusoSefaz = '-04:00') then
    begin
      Result := IncHour(Data, -1);
    end
    else if (strFuso = '-04:00') and (strFusoSefaz = '-02:00') then
    begin
      Result := IncHour(Data, 2);
    end
    else if (strFuso = '-04:00') and (strFusoSefaz = '-03:00') then
    begin
      Result := IncHour(Data);
    end;
  end
  else
    Result := Data;
end;

function Kernel_Remove_Caracteres_Especiais(Texto: string): string;
var
  TamanhoTexto, i: Integer;
begin
  while Pos(chr(39), Texto) > 0 do
    Delete(Texto, Pos(chr(39), Texto), 1);
  while Pos('"', Texto) > 0 do
    Delete(Texto, Pos('"', Texto), 1);

  Texto := Trim(Texto);
  TamanhoTexto := Length(Texto);
  for i := 1 to (TamanhoTexto) do
  begin
    if Pos(Texto[i],
      ' 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ()+=-/\')
      = 0 then
    begin
      case Texto[i] of
        'á', 'Á':
          Texto[i] := 'A';
        'é', 'É':
          Texto[i] := 'E';
        'í', 'Í':
          Texto[i] := 'I';
        'ó', 'Ó':
          Texto[i] := 'O';
        'ú', 'Ú':
          Texto[i] := 'U';
        'à', 'À':
          Texto[i] := 'A';
        'è', 'È':
          Texto[i] := 'E';
        'ì', 'Ì':
          Texto[i] := 'I';
        'ò', 'Ò':
          Texto[i] := 'O';
        'ù', 'Ù':
          Texto[i] := 'U';
        'â', 'Â':
          Texto[i] := 'A';
        'ê', 'Ê':
          Texto[i] := 'E';
        'î', 'Î':
          Texto[i] := 'I';
        'ô', 'Ô':
          Texto[i] := 'O';
        'û', 'Û':
          Texto[i] := 'U';
        'ä', 'Ä':
          Texto[i] := 'A';
        'ë', 'Ë':
          Texto[i] := 'E';
        'ï', 'Ï':
          Texto[i] := 'I';
        'ö', 'Ö':
          Texto[i] := 'O';
        'ü', 'Ü':
          Texto[i] := 'U';
        'ç', 'Ç':
          Texto[i] := 'C';
        'ñ', 'Ñ':
          Texto[i] := 'N';
        'ã', 'Ã':
          Texto[i] := 'A';
        '&':
          Texto[i] := 'E';
        'õ', 'Õ':
          Texto[i] := 'O';
      else
        Texto[i] := ' ';
      end;
    end;
  end;
  Result := AnsiUpperCase(Texto);
end;

procedure Kernel_Consulta_Dados(TableName, Campo, where: String; EDT :TUniEdit;
  EDT_DESC: TUniEdit);
var
  qry: TFDQuery;
begin
  if Trim(EDT.Text) = '' then
  begin
     EDT_DESC.Color := clWindow;
     EDT_DESC.Clear;
     Exit;
  end;

  qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with qry do
    begin
      sql.Add('SELECT ' + Campo + ' FROM ' + TableName);

      if where <> '' then
        sql.Add(' ' + where);

      open;

      if not IsEmpty then
      begin
        EDT_DESC.Text := Fields[0].AsString;
        EDT_DESC.Color := clWindow;
      end
      else
      begin
         EDT_DESC.Text := 'Dados não encontrado no sistema';
         EDT_DESC.Color := $007575FF;
         EDT.SetFocus;
      end;
    end;
  finally
    FreeAndNil(qry); { : libera o objeto da memória }
  end;
end;

procedure Kernel_Consulta_Dados(TableName, Campo, where: String; EDT :TUniDBEdit;
  EDT_DESC: TUniEdit);
var
  qry: TRESTDWClientSQL;
begin
  if Trim(EDT.Text) = '' then
  begin
     EDT_DESC.Color := clWindow;
     EDT_DESC.Clear;
     Exit;
  end;

  qry := InstanciaQueryREST; { : cria uma instância do objeto }
  try
    with qry do
    begin
      sql.Add('SELECT ' + Campo + ' FROM ' + TableName);

      if where <> '' then
        sql.Add(' ' + where);

      open;

      if not IsEmpty then
      begin
        EDT_DESC.Text := Fields[0].AsString;
        EDT_DESC.Color := clWindow;
      end
      else
      begin
         EDT_DESC.Text := 'Dados não encontrado no sistema';
         EDT_DESC.Color := $007575FF;
         EDT.SetFocus;
      end;
    end;
  finally
    FreeAndNil(qry); { : libera o objeto da memória }
  end;
end;

procedure Kernel_Abre_Pesquisa(xTabela, xCampoCodigo, xCampoNome, xCampoData,
  xCampoExclusao, xCondicaoauxiliar1, xCampoStatus, xtitulo: string;
  EDT :TUniDBEdit; EDT_DESC: TUniEdit);
begin
  with frmConsultaGenerica do
  begin
    Tabela := xTabela;
    CampoCodigo := xCampoCodigo;
    CampoNome := xCampoNome;
    CampoData := xCampoData;
    CampoExclusao := xCampoExclusao;
    CampoStatus := xCampoStatus;
    TipoPesquisa := 1;
    Condicaoauxiliar1 := xCondicaoauxiliar1;

    lblTitulo.Caption := 'Consulta de ' + xtitulo;

    ShowModal(
      procedure(Sender: TComponent; Resultado: Integer)
      begin
         if Resultado = mrOk then
         begin
            if Trim(CampoCodigo) <> '' then
            begin
               EDT.Text := CampoCodigo;
               EDT_DESC.Text := CampoNome;
            end;
         end;
      end);

  end;
end;

procedure Kernel_Abre_Pesquisa(xTabela, xCampoCodigo, xCampoNome, xCampoData,
  xCampoExclusao, xCondicaoauxiliar1, xCampoStatus, xtitulo: string;
  Combo :TUniDBLookupComboBox);
begin
  with frmConsultaGenerica do
  begin
    Tabela := xTabela;
    CampoCodigo := xCampoCodigo;
    CampoNome := xCampoNome;
    CampoData := xCampoData;
    CampoExclusao := xCampoExclusao;
    CampoStatus := xCampoStatus;
    TipoPesquisa := 1;
    Condicaoauxiliar1 := xCondicaoauxiliar1;

    lblTitulo.Caption := 'Consulta de ' + xtitulo;

    ShowModal(
      procedure(Sender: TComponent; Resultado: Integer)
      begin
         if Resultado = mrOk then
         begin
            if Trim(CampoCodigo) <> '' then
               Combo.KeyValue := StrToInt(CampoCodigo);
         end;
      end);

  end;
end;

function Kernel_Apaga_Rergistro(Tabela, Campo, CampoEmpresa: string; Valor, idEmpresa: Integer; out vError: string): Boolean;
var
  Qry_Data: TRESTDWClientSQL;
begin
  Qry_Data := InstanciaQueryREST; { : cria uma instância do objeto }
  try

    with Qry_Data do
    begin
      close;
      SQL.Clear;
      if Trim(CampoEmpresa) <> '' then
         sql.Add('delete from ' + Tabela + ' where '+CampoEmpresa+' = ' + IntToStr(idEmpresa) + ' and ' + Campo + '=' +
           IntToStr(Valor))
      else
         sql.Add('delete from ' + Tabela + ' where ' + Campo + '=' +
           IntToStr(Valor));
      Result := ExecSQL(vError);
    end;
  finally
    FreeAndNil(Qry_Data); // : libera o objeto da memória
  end;
end;

function Kernel_Data_Servidor: Tdatetime;
var
  Qry_Data: TFDQuery;
begin
//  Qry_Data := InstanciaQuery; { : cria uma instância do objeto }
//  try
//    with Qry_Data do
//    begin
//      close;
//      sql.Add('SELECT current_timestamp FROM RDB$DATABASE');
//      open;
//
//      Result := Fields[0].AsDateTime;
//    end;
//  finally
//    FreeAndNil(Qry_Data); // : libera o objeto da memória
//  end;

  Result := Now;
end;

function Kernel_Consulta_string(TableName, Campo, where: String): string;
var
  qry: TRESTDWClientSQL;
begin
  Result := '';
  qry := InstanciaQueryREST; { : cria uma instância do objeto }
  try
    with qry do
    begin
      sql.Add('SELECT ' + Campo + ' FROM ' + TableName);

      if where <> '' then
        sql.Add(' ' + where);

      open;

      if not IsEmpty then
        Result := Fields[0].AsString;
    end;
  finally
    FreeAndNil(qry); { : libera o objeto da memória }
  end;
end;

function Kernel_Consulta_boolean(TableName, Campo, where: String): Boolean;
var
  qry: TFDQuery;
begin
  Result := False;
  qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with qry do
    begin
      SQL.Add('SELECT ' + Campo + ' FROM ' + TableName);

      if where <> '' then
        SQL.Add(' ' + where);

      Open;

      if Fields[0].IsNull then { : se a tabela está vazia, retornará nulo }
        Result := False
      else
        Result := True;
    end;
  finally
    FreeAndNil(qry); { : libera o objeto da memória }
  end;
end;

function Kernel_Incrementa(TableName, Campo: String): Integer;
var
  qry: TRESTDWClientSQL;
begin
  qry := InstanciaQueryREST; { : cria uma instância do objeto }
  try
    with qry do
    begin
      sql.Add('SELECT MAX(' + Campo + ')FROM ' + TableName);
      open;

      if Fields[0].IsNull then { : se a tabela está vazia, retornará nulo }
        Result := 1 { : então este será o 1º registro }
      else
        Result := Fields[0].Value + 1;
    end;
  finally
    FreeAndNil(qry); { : libera o objeto da memória }
  end;
end;

procedure kernel_RefreshCds(aCds: TRESTDWClientSQL);
begin
  { : atualiza o ClientDataSet (principalmente para Relatórios) }
  aCds.close;
  aCds.Open();
end;

procedure Kernel_Preenche_TComobox(var Cb: TUniComboBox;
Tabela, Campo, condicao: String);
var
  qry: TFDQuery;
begin
  qry := InstanciaQuery(); { : cria uma instância do objeto }
  try
    with qry do
    begin
      close;
      sql.Clear;
      sql.Add('select ' + Campo + ' from ' + Tabela);

      // se tiver condicao aplica na consulta
      if condicao <> '' then
        sql.Add(condicao);

      sql.Add('order by ' + Campo);
      open;

      if not IsEmpty then
        Cb.Clear;
      First;
      While not eof do
      Begin
        Cb.Items.Add(FieldByName(Campo).AsString);
        Next;
      End;
    end;
  finally
    FreeAndNil(qry); { : libera o objeto da memória }
  end;
end;

Function InstanciaQuery(): TFDQuery;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil); { : cria uma instância do objeto }
  qry.Connection := UniMainModule.conConexao; { : componente de conexão }
  Result := qry; // Retorna a query instancia para quem chamou a função
end;

Function InstanciaQueryREST(): TRESTDWClientSQL;
var
  qry: TRESTDWClientSQL;
begin
  qry := TRESTDWClientSQL.Create(nil); { : cria uma instância do objeto }
  qry.DataBase := UniMainModule.RESTConexao; { : componente de conexão }
  Result := qry; // Retorna a query instancia para quem chamou a função
end;

function Kernel_Consulta_Inteiro(TableName, Campo, where: String): Integer;
var
  qry: TFDQuery;
begin
  Result := 0;
  qry := InstanciaQuery; { : cria uma instância do objeto }
  try
    with qry do
    begin
      sql.Add('SELECT ' + Campo + ' FROM ' + TableName);

      if where <> '' then
        sql.Add(' ' + where);

      open;

      if not IsEmpty then
        Result := Fields[0].Asinteger;
    end;
  finally
    FreeAndNil(qry); { : libera o objeto da memória }
  end;
end;

function Consulta_IBGE(cidade: string; uf: Integer): string;
var
  qry: TFDQuery;
begin
  Result := '';
  qry := InstanciaQuery(); { : cria uma instância do objeto }
  try
    try
      with qry do
      Begin
        // ativa no parametro a contigencia
        close;
        sql.Clear;
        sql.Add('select codigo_ibge from cidade where nomecidade=:nomecidade and idestado=:idestado');
        Params[0].AsString := cidade;
        Params[1].Asinteger := uf;
        open;

        if not IsEmpty then
          Result := Fields[0].AsString;
      end;
    except
    end;
  finally
    FreeAndNil(qry);
  end;
end;

function Consulta_EstadoCliente(id, idEmpresa: Integer): String;
var
  qry: TRESTDWClientSQL;
begin
  Result := ''; // amazonas
  qry := InstanciaQueryREST(); { : cria uma instância do objeto }
  try
    try
      with qry do
      Begin
        // ativa no parametro a contigencia
        close;
        sql.Clear;
        sql.Add('select * from CLIENTE_FORNCEDOR where id = :id and id_empresa = :id_empresa');
        Params[0].AsInteger := id;
        Params[1].AsInteger := idEmpresa;
        open;

        if not IsEmpty then
          Result := FieldByName('ESTADO').AsString;
      end;
    except
    end;
  finally
    FreeAndNil(qry);
  end;
end;

function Consulta_IDEstado(uf: string): Integer;
var
  qry: TFDQuery;
begin
  Result := 13; // amazonas
  qry := InstanciaQuery(); { : cria uma instância do objeto }
  try
    try
      with qry do
      Begin
        // ativa no parametro a contigencia
        close;
        sql.Clear;
        sql.Add('select id from estado where uf=:uf');
        Params[0].AsString := uf;
        open;

        if not IsEmpty then
          Result := Fields[0].Asinteger;
      end;
    except
    end;
  finally
    FreeAndNil(qry);
  end;
end;

function Percentual_Partilha_Destino(Ano: TdateTime): Double;
var
  Qry: TRESTDWClientSQL;
begin
  // Pega a Aliquota Interestadual
  Qry :=  InstanciaQueryREST(); {: cria uma instância do objeto}
  try
    with Qry do
    Begin
      SQL.Clear;
      SQL.add('SELECT PERCENTUAL_DESTINO FROM PERCENTUAL_DIVISAO_PARTILHA '+
      'WHERE ANO=:ANO');
      ParamByName('ANO').AsInteger := YearOf(Ano);
      Open;

      Result := Fields[0].Value;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

function Percentual_Partilha_Origem(Ano: TdateTime): Double;
var
  Qry: TRESTDWClientSQL;
begin
  // Pega a Aliquota Interestadual conforme o ano Atual
  Qry :=  InstanciaQueryREST(); {: cria uma instância do objeto}
  try
    with Qry do
    Begin
      SQL.Clear;
      SQL.add('SELECT PERCENTUAL_ORIGEM FROM PERCENTUAL_DIVISAO_PARTILHA '+
      'WHERE ANO=:ANO');
      ParamByName('ANO').AsInteger := YearOf(Ano);
      Open;

      Result := Fields[0].Value;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

end.
