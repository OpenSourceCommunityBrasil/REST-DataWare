unit PIX_Parametros;

interface

uses System.Generics.collections;

type

  TPIX = class
      private
          FendToEndId  : String;
          Ftxid        : String;
          Fvalor       : Currency;
          Fhorario     : String;
      public
          property endToEndId : String   read FendToEndId  write FendToEndId;
          property txid       : String   read Ftxid        write Ftxid;
          property valor      : Currency read Fvalor       write Fvalor;
          property horario    : String   read Fhorario     write Fhorario;



  end;

  TCalendario = class
  private
      Fcriacao : String;
      Fexpiracao: Integer;
      FdataDeVencimento : String;
      FvalidadeAposVencimento : Integer;

  public
      property criacao                : String  read Fcriacao                 write Fcriacao;
      property expiracao              : Integer read Fexpiracao               write Fexpiracao;
      property dataDeVencimento       : String  read FdataDeVencimento        write FdataDeVencimento;
      property validadeAposVencimento : Integer read FvalidadeAposVencimento  write FvalidadeAposVencimento;
  end;


  TDevedor = class
  private
      Fcpf        : String;
      Fcnpj       : String;
      Fnome       : String;
      Flogradouro : String;
      Fcidade     : String;
      FUF         : String;
      FCEP        : String;
  public
      property cpf         : String read Fcpf        write Fcpf;
      property cnpj        : String read Fcnpj       write Fcnpj;
      property nome        : String read Fnome       write Fnome;
      property logradouro  : String read Flogradouro write Flogradouro;
      property cidade      : String read Fcidade     write Fcidade;
      property UF          : String read FUF         write FUF;
      property CEP         : String read FCEP        write FCEP;
  end;

  TLoc = class
  private
    FId       : Integer;
    FLocation : string;
    FTipoCob  : string;
  public
    property Id         : Integer read FId        write FId;
    property Location   : string  read FLocation  write FLocation;
    property TipoCob    : string  read FTipoCob   write FTipoCob;
  end;


  TValor = class
  private
      Foriginal            : String;
      FmodalidadeAlteracao : Integer;
  public
      property original             : String  read Foriginal             write Foriginal;
      property modalidadeAlteracao  : Integer read FmodalidadeAlteracao  write FmodalidadeAlteracao;
  end;


  Tinfo_adicionais = class
  private
      Fnome    : String;
      Fvalor   : String;
  public
      property nome  : String read Fnome  write Fnome;
      property valor : String read Fvalor write Fvalor;
  end;


   TDevolucaoHorario = class
  private
    fSolicitacao: string;
    fLiquidacao: string;
  public
    property Solicitacao: string read fSolicitacao write fSolicitacao;
    property Liquidacao : string read fLiquidacao write fSolicitacao;
  end;


  TDevolucao = class
  private
    fId         : string;
    fRtrId      : string;
    fValor      : Currency;
    fHorario    : TDevolucaoHorario;
    fStatus     : string;
  public
    property Id       : string              read fId write fId;
    property RtrId    : string              read fRtrId write fRtrId;
    property Valor    : Currency            read fValor write fValor;
    property Horario  : TDevolucaoHorario   read fHorario write fHorario;
    property Status   : string              read fStatus write fStatus;
  end;


   TPagador = class
  private
    Fcpf          : String;
    Fcnpj         : String;
    Fnome         : String;
    Finformacao   : String;

  public
    property cpf         : String read Fcpf        write Fcpf;
    property cnpj        : String read Fcnpj       write Fcnpj;
    property nome        : String read Fnome       write Fnome;
    property informacao  : String read Finformacao write Finformacao;
  end;

  TPix_Parametros = class
  private
    FendToEndID         : String;
    Fchave              : String;
    Ftxid               : String;
    Fstatus             : String;
    Fcalendario         : Tcalendario;
    Fdevedor            : Tdevedor;
    Frevisao            : Integer;
    Flocation           : String;
    Fvalor              : Tvalor;
    Fsolicitacaopagador : String;
    Finfo_adicionais    : TArray<Tinfo_adicionais>;

    Finformacaopagador  : String;
//    Fpagador            : Tpagador;
    FDevolucao          : tArray<TDevolucao>;
//    fHorario            : TDevolucaoHorario;

    fdata_inicio_criacao: String;
    fdata_final_criacao : String;
    ftextoImagemQRcode  : String;

    FPIX          : tArray<TPIX>;




  public
//    property endToEndID         : String                    read FendToEndID          write FendToEndID;
    property chave              : String                    read Fchave               write Fchave;
    property txid               : String                    read Ftxid                write Ftxid;
    property calendario         : Tcalendario               read Fcalendario          write Fcalendario;
    property status             : String                    read Fstatus              write Fstatus;
    property revisao            : Integer                   read Frevisao             write Frevisao;
    property location           : String                    read Flocation            write Flocation;
    property devedor            : Tdevedor                  read Fdevedor             write Fdevedor;
    property valor              : Tvalor                    read Fvalor               write Fvalor;
    property solicitacaopagador : String                    read Fsolicitacaopagador  write Fsolicitacaopagador;
    property info_adicionais    : TArray<Tinfo_adicionais>  read Finfo_adicionais     write Finfo_adicionais;
//    property Pagador            : TPagador                  read fpagador             write fpagador;
    property devolucao          : TArray<TDevolucao>        read FDevolucao           write FDevolucao;
//    property Horario            : TDevolucaoHorario         read fHorario             write fHorario;
    property data_inicio_criacao: String                    read fdata_inicio_criacao write fdata_inicio_criacao;
    property data_final_criacao : String                    read fdata_final_criacao  write fdata_final_criacao;
    property textoImagemQRcode  : String                    read ftextoImagemQRcode   write ftextoImagemQRcode;

    property pix    : TArray<TPIX>  read Fpix     write Fpix;//para REetorno da consulta




    destructor Destroy;override;

  end;





implementation

{ TPix_Entrada }


destructor TPix_Parametros.Destroy;
var Vinfo_adicionais : Tinfo_adicionais;
    Vdevolucao : TDevolucao;
    Vpix : Tpix;

begin
    if Assigned(FCalendario) then
       FCalendario.Free;

    if Assigned(Fvalor) then
       Fvalor.Free;

    if Assigned(Fdevedor) then
       Fdevedor.Free;

{    if Assigned(Fpagador) then
       Fpagador.Free;}

    for Vinfo_adicionais in Finfo_adicionais do
      Vinfo_adicionais.Free;

    for Vdevolucao in FDevolucao do
      Vdevolucao.Free;

    for Vpix in Fpix do
      Vpix.Free;

{    if Assigned(FHorario) then
       fHorario.Free;}

  inherited;
end;


end.
