unit untMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    Label2: TLabel;
    Bevel1: TBevel;
    Label1: TLabel;
    Label3: TLabel;
    Bevel2: TBevel;
    labTotArqs: TLabel;
    labArq: TLabel;
    Label7: TLabel;
    Image1: TImage;
    Label6: TLabel;
    Label8: TLabel;
    Bevel4: TBevel;
    edPastaOriginal: TEdit;
    pg: TProgressBar;
    memo_Original: TMemo;
    ButtonStart: TButton;
    edPastaConvertido: TEdit;
    Button1: TButton;
    edFiltro: TEdit;
    OpenDialog1: TOpenDialog;
    cbxEngine: TComboBox;
    Label5: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }

    Function ReverseStr (S : ShortString) : ShortString;
    Function Occurs(T, S : ShortString) : Byte;
    Function OccurPos (T, S : ShortString; N : Byte) : Byte;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

Function TfrmMain.ReverseStr (S : ShortString) : ShortString;
var I : Integer;
begin
    Result := '';
    For I := Length(S) DownTo 1 Do
    Result := Result + S[I];
end;
//------------------------------------------------------------------------
{Retorna o n£mero de ocorrˆncias de uma string "T" dentro de outra "S"}
Function TfrmMain.Occurs(T, S : ShortString) : Byte;
Var P : Byte;
Begin
    Result := 0;
    P := Pos (T, S);
    while P > 0 do begin
    Inc (Result);
    S := Copy (S, P + Length (T), 255);
    P := Pos (T, S);
    end;
End;

//------------------------------------------------------------------------
{Retorna a posi‡Æo da en‚sima ocorrˆncia da string "T" na string "S"}
Function TfrmMain.OccurPos (T, S : ShortString; N : Byte) : Byte;
Var Op, P, I : Byte;
Begin
    I := 0;
    Op := 0;
    P := Pos (T, S);
    While P > 0 Do Begin
    Inc (Op);
    if Op = N Then Begin
    OccurPos := I + P;
    Exit;
    End;
    Inc(I, P + Length(T) - 1);
    P := Pos (T, Copy (S, I + 1, 255));
    End;
    OccurPos := 0;
End;

procedure TfrmMain.Button1Click(Sender: TObject);
begin

     ShowMessage( 'Desenvolvido a partir da necessidade PESSOAL de converter ZEOS para RestDW ' +
                  'após algumas tentativas frustradas de usar o "reFind".' + sLineBreak + sLineBreak +
                  'Facilmente poderá ser adaptado a quaquer necessidade como opção ao GReplace, por exemplo, ' + sLineBreak +
                  'com a vantagem de não só substituir mas ADICIONAR linhas de código tanto ao .DFM quanto ao .PAS' + sLineBreak + sLineBreak +
                  'Qualquer dúvida: ' + sLineBreak + sLineBreak +
                  'skype: mikromundo.com ou ' + sLineBreak +
                  'email: mikromundo@gail.com' + sLineBreak + sLineBreak +
                  'Flávio Motta( www.mikromundo.com )');

end;

procedure TfrmMain.ButtonStartClick(Sender: TObject);
var

   _frameBarraSup ,
   _rzButton,
   _panel,
   _rzlistbox,


   _StoreProc,_StoreProcLin, _tot,Alterou, NumLinhas, f, r, contadorTabOrder, contadorRzButton : Integer;

   SearchRec : TSearchRec;

   DfmFilename, Filename, linha, linha2, linha3, linhaSQL, linhaDataSource, linhaLeft, linhaTop, NewFileName : string;

   logfile : textfile;


   sToken1, sToken2,

   espacos : string;

   _pular,

   i, t, a, s, d,

   _itens_descartar, // dependendo da Engine de origem. Para evitar conflito de propriedades com nomes em comum entre Engines

   _itens_composto, _itens_uses, _itens_alt_dfm, _itens_add_dfm, _itens_pas, _itens_filtros, _itens_add_dfm_PropRestDataBase,

   contadorTfrm  : Integer;

   _TextColors_DisabledHighlight : integer;

   bDescarte : Boolean;

   aDescartar,    // dependendo da Engine de origem. Para evitar conflito de propriedades com nomes em comum entre Engines

   aEngineOrigem,
   aEngineOrigemComposto,
   aRestDW   ,
   aNovos ,
   aUses   ,
   aCode_EngineOrigem ,
   aCode_RestDW ,
   aAddPropRestDataBase : array[0..50] of String;

   aFiltroArqs  : array[1..2] of String;


   aArquivos    : array[1..5000] of String;

   strArqOrigem,
   strArqDestino,
   strArqTemp      : TStringList;

begin

   _itens_composto   := 0;
   _itens_alt_dfm    := 0;
   _itens_add_dfm    := 0;
   _itens_pas        := 0;
   _itens_filtros    := 0;
   _itens_add_dfm_PropRestDataBase := 0;
   _itens_uses      := 0;

   _itens_Descartar := 0;


   Inc( _itens_filtros );
   aFiltroArqs[ _itens_filtros ] := '*.dfm';
   Inc( _itens_filtros );
   aFiltroArqs[ _itens_filtros ] := '*.pas';


   //IBQUERY
   {

  object QUltimaVenda: TIBQuery
    Database = DM.IBDatabase
    Transaction = DM.IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    SQL.Strings = (

        'SELECT I.QUANT, I.VALOR, V.DATA_VEN, V.CUPOM_FISCAL_VEN, V.NUMER' +
        'O_NOTA_FISCAL, C.NOME_CLI'
      'FROM ITENS_VENDA I'
      'INNER JOIN VENDAS V'
      'ON (I.COD_VEN = V.COD_VEN)'
      'INNER JOIN CLIENTE C'
      'ON (V.COD_CLI = C.COD_CLI)'

        'WHERE I.COD_VEN = :CODVEN AND I.COD_PRO = :CODPRO AND I.COD_EMP ' +
        '= :CODEMP AND CANCELADO = 0 AND VENDA_CANCELADA = 0')
    Left = 744
    Top = 328
    ParamData = <
      item
        DataType = ftInteger
        Name = 'CODVEN'
        ParamType = ptUnknown
      end
      item
        DataType = ftInteger
        Name = 'CODPRO'
        ParamType = ptUnknown
      end
      item
        DataType = ftInteger
        Name = 'CODEMP'
        ParamType = ptUnknown
      end>
  end

   }
   // DFMs
   //

   // as criticas a seguir( de descarte ) foram adicionadas pq INFELIZMENTE
   // tinha no meu projeto um misto de conexoes( estava fazendo testes )
   // foi essa situacao que me fez criar o MIGRADOR
   //
   //if cbxEngine.Text = 'Zeos' then
   begin

       // propriedades q serão removidas / substituidas integralmente
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' AutoEncodeStrings =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' CachedUpdates = True';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' CachedUpdates = False';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ReadOnly = True';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ControlsCodePage';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Catalog';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Properties.Strings';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ''controls_cp=GET_ACP'')';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' AutoCommit';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' TransactIsolationLevel';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Connected';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' SQLHourGlass';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' HostName';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Port';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Database = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' User = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Password = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Protocol = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' DataSource =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ParamCheck =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' UpdateMode =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' WhereMode =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Options =';
       //aRestDW[ _itens_descartar ]         := '';

        // Mizael correçao para Valmir
       Inc(_itens_descartar);
       aDescartar[_itens_descartar]     := ' ''lc_ctype=ISO8859_1'')';



       //IBX
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' DatabaseName =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' LoginPrompt =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' DefaultTransaction =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ServerType =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' DefaultDatabase =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Transaction =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' BufferChunks =';
       //aRestDW[ _itens_descartar ]         := '';

       // Mizael
       aDescartar  [ _itens_descartar ] := ' UpdateObject =';
       // aRestDW[ _itens_descartar ]         := '';


   end;
   (*
   else
   if cbxEngine.Text = 'IBX' then
   begin





       // propriedades q serão removidas / substituidas integralmente
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' AutoEncodeStrings =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' CachedUpdates = True';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' CachedUpdates = False';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ReadOnly = True';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ControlsCodePage';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Catalog';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Properties.Strings';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ''controls_cp=GET_ACP'')';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' AutoCommit';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' TransactIsolationLevel';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Connected';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' SQLHourGlass';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' HostName';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Port';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Database = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' User = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Password = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Protocol = ''';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' DataSource =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' ParamCheck =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' UpdateMode =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' WhereMode =';
       //aRestDW[ _itens_descartar ]         := '';
       Inc( _itens_descartar );
       aDescartar  [ _itens_descartar ] := ' Options =';
       //aRestDW[ _itens_descartar ]         := '';

   end;
   *)
   //----------------------------------------------------------------------------------------------------------


   //----------------------------------------------------------------------------------------------------------
   // os 3 primeiros itens serao trocados por stringreplace para manter o NOME dos componentes
   // o restante será substtuido toda a linha ou REMOVIDO
   //
   // com destino para RestDW
   //

   if cbxEngine.Text = 'Zeos' then
   begin

       // propriedades q serão substituidas parcial para manter o NOME do componente original
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ': TZConnection';
       aRestDW[ _itens_alt_dfm ]         := ': TRESTDataBase';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ': TZQuery';
       aRestDW[ _itens_alt_dfm ]         := ': TRESTClientSQL';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Connection =';       // altere pra suas definicoes de conexao da ZEOS
       aRestDW[ _itens_alt_dfm ]         := ' DataBase =';

       // mizael
       Inc(_itens_alt_dfm);
       aEngineOrigem[ _itens_alt_dfm ]   := ': TZStoredProc';
       aRestDW[ _itens_alt_dfm ]         := ': TRESTStoredProc';

       // Fields
       // mizael
       Inc( _itens_alt_dfm);
       aEngineOrigem[_itens_alt_dfm] := ': TIBStringField';
       aRestDW[_itens_alt_dfm] := ': TStringField';
       Inc(_itens_alt_dfm);
       aEngineOrigem[_itens_alt_dfm] := ': TIBBCDField';
       aRestDW[_itens_alt_dfm] := ': TBCDField';

       (*
       // propriedades q serão removidas / substituidas integralmente
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' CachedUpdates = True';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' CachedUpdates = False';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ReadOnly = True';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ControlsCodePage';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Catalog';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Properties.Strings';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ''controls_cp=GET_ACP'')';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' AutoCommit';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' TransactIsolationLevel';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Connected';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' SQLHourGlass';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' HostName';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Port';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Database = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' User = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Password = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Protocol = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' DataSource =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ParamCheck =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' UpdateMode =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' WhereMode =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Options =';
       aRestDW[ _itens_alt_dfm ]         := '';
            *)

       //propriedades compostas
       //
       // Ex: ParamData = <
       //     end>
       //
       Inc( _itens_composto );
       aEngineOrigemComposto  [ _itens_composto ] := 'Params = <';
       Inc( _itens_composto );
       aEngineOrigemComposto  [ _itens_composto ] := 'ParamData = <';

   end
   else
   if cbxEngine.Text = 'IBX' then
   begin

       // propriedades q serão substituidas parcial para manter o NOME do componente original
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ': TIBDataBase';
       aRestDW[ _itens_alt_dfm ]         := ': TRESTDataBase';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ': TIBQuery';
       aRestDW[ _itens_alt_dfm ]         := ': TRESTClientSQL';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ': TIBSQL';
       aRestDW[ _itens_alt_dfm ]         := ': TRESTClientSQL';

       // mizael
       Inc(_itens_alt_dfm);
       aEngineOrigem[ _itens_alt_dfm ]   := ': TIBStoredProc';
       aRestDW[ _itens_alt_dfm ]         := ': TRESTStoredProc';


       (*
       // propriedades q serão removidas / substituidas integralmente
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' CachedUpdates = True';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' CachedUpdates = False';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ReadOnly = True';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ControlsCodePage';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Catalog';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Properties.Strings';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ''controls_cp=GET_ACP'')';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' AutoCommit';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' TransactIsolationLevel';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Connected';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' SQLHourGlass';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' HostName';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Port';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Database = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' User = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Password = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Protocol = ''';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' DataSource =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' ParamCheck =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' UpdateMode =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' WhereMode =';
       aRestDW[ _itens_alt_dfm ]         := '';
       Inc( _itens_alt_dfm );
       aEngineOrigem  [ _itens_alt_dfm ] := ' Options =';
       aRestDW[ _itens_alt_dfm ]         := '';
            *)

       //propriedades compostas
       //
       // Ex: ParamData = <
       //     end>
       //
       Inc( _itens_composto );
       aEngineOrigemComposto  [ _itens_composto ] := 'Params = <';
       Inc( _itens_composto );
       aEngineOrigemComposto  [ _itens_composto ] := 'ParamData = <';
       Inc( _itens_composto );
       aEngineOrigemComposto  [ _itens_composto ] := 'Params.Strings = (';


   end;

   //----------------------------------------------------------------------------------------------------------
   // propriedades da ENGINE DE DESTINO( no caso RestDW ) a serem adicionadas
   //
   // com destino para RestDW
   //
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'IndexDefs = <>';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'FetchOptions.AssignedValues = [evMode]';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'FetchOptions.Mode = fmAll';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'FormatOptions.MaxBcdPrecision = 2147483647';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'FormatOptions.MaxBcdScale = 2147483647';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'ResourceOptions.AssignedValues = [rvSilentMode]';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'ResourceOptions.SilentMode = True';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'UpdateOptions.LockWait = True';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'UpdateOptions.FetchGeneratorsPoint = gpNone';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'UpdateOptions.CheckRequired = False';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'UpdateOptions.AutoCommitUpdates = True';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'StoreDefs = True';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'MasterCascadeDelete = True';
   Inc( _itens_add_dfm );
   aNovos[ _itens_add_dfm ] := 'DataCache = False';
   //Inc( _itens_add_dfm );
   //aNovos[ _itens_add_dfm ] := 'Params = <>';

   //----------------------------------------------------------------------------------------------------------
   //propriedades novas para adicionar ao RestDataBase em troca ao ZConnection
   //
   // com destino para RestDW
   //
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'Active = False';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'Compression = True';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'Login = ''testserver''';    // altere para seu login
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'Password = ''testserver'''; // altere para seu usuario
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'Proxy = False';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'ProxyOptions.Port = 8888';
      Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'PoolerService = ''127.0.0.1''';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'PoolerPort = 8082';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'PoolerName = ''ServerMethods1.RESTPoolerDB''';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'RestModule = ''TServerMethods1''';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'StateConnection.AutoCheck = False';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'StateConnection.InTime = 1000';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'RequestTimeOut = 10000';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'Encoding = esUtf8';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'Context = ''Datasnap''';
   Inc( _itens_add_dfm_PropRestDataBase );
   aAddPropRestDataBase[ _itens_add_dfm_PropRestDataBase ] := 'RESTContext = ''rest/''';
   //----------------------------------------------------------------------------------------------------------

   //----------------------------------------------------------------------------------------------------------
   //PAS
   //
   // com destino para RestDW
   //
   // uses
   Inc( _itens_uses );
   aUses [ _itens_uses ] := 'uRestPoolerDB';
   // retirei as linhas abaixo pois mesmo adcionando, ao abrir um DM convertido e clicar em SALVAR
   // o delphi adicionava novamente as declaracoes
   {
   //Inc( _itens_uses );
   aUses [ _itens_uses ] := 'FireDAC.UI.Intf';
   Inc( _itens_uses );
   aUses [ _itens_uses ] := 'FireDAC.FMXUI.Wait';
   Inc( _itens_uses );
   aUses [ _itens_uses ] := 'FireDAC.Comp.UI';
   Inc( _itens_uses );
   aUses [ _itens_uses ] := 'FireDAC.Stan.Intf';
   Inc( _itens_uses );
   aUses [ _itens_uses ] := 'FireDAC.Comp.Client';
   Inc( _itens_uses );
   aUses [ _itens_uses ] := 'FireDAC.Stan.StorageJSON';
   Inc( _itens_uses );
   aUses [ _itens_uses ] := 'FireDAC.Stan.StorageBin';
   }
   //----------------------------------------------------------------------------------------------------------

   //----------------------------------------------------------------------------------------------------------
   // partes de codigo q poder ser substituidas( aqui era minha necessidade, mude de acordo com a sua...
   //
   // com destino para RestDW
   //
   Inc( _itens_pas );
   aCode_EngineOrigem   [ _itens_pas ] := '.ExecSql';  //Quaquer query...
   aCode_RestDW [ _itens_pas ]         := '.ExecSql( _Erro_DW ) then ShowMessage( _Erro_DW )'; // acrescentar if not antes

   // o item abaixo nao é DUPLICIDADE é no caso de algum EXECSQL estiver dentro de um WITH...
   // o de cima procura pelos ExecSql explicitos( query.execsql ) e o de baixo pelos implicitos
   Inc( _itens_pas );
   aCode_EngineOrigem   [ _itens_pas ] := ' ExecSql';  //Quaquer query...
   aCode_RestDW [ _itens_pas ]         := ' ExecSql( _Erro_DW ) then ShowMessage( _Erro_DW )'; // acrescentar if not antes


   Inc( _itens_pas );
   aCode_EngineOrigem   [ _itens_pas ] := '.commit';
   aCode_RestDW [ _itens_pas ]         := '//'; // comentar o inicio da linha
   Inc( _itens_pas );
   aCode_EngineOrigem   [ _itens_pas ] := '.rollback';
   aCode_RestDW [ _itens_pas ]         := '//'; // comentar o inicio da linha

   //mizael
   Inc(_itens_pas);
   aCode_EngineOrigem[_itens_pas] := '.InTransaction';
   aCode_RestDW[_itens_pas] := '//'; // comentar o inicio da linha
   Inc(_itens_pas);
   aCode_EngineOrigem[_itens_pas] := '.StartTransaction';
   aCode_RestDW[_itens_pas] := '//'; // comentar o inicio da linha

   if ( cbxEngine.Text = 'Zeos' ) then
   begin

        Inc( _itens_pas );
        aCode_EngineOrigem   [ _itens_pas ] := 'TZQuery';  //Quaquer query...
        aCode_RestDW [ _itens_pas ]         := 'TRESTClientSQL'; // acrescentar if not antes

   end
   else
   if ( cbxEngine.Text = 'IBX' ) then
   begin

      // FLAVIO PARA Mizael
      //
      // faco uma critica no INDICE <= 2 pra ZEOS, pra manter entao a compatibildiade vou criar o primeiro
      // item com algo que nao BATA na comparacao...se nao, teriamos q fazer varios IFs de acordo com
      // a Engne escolhida
      //
      // desculpem a solucao tá bem feia, mas meu tempo tá curto e já estou bem atrasado com projetos de
      // clientes...espero em breve possamos dar um ar mais profissional
      //
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := '...!!!@@@###!!!$$%%%¨¨¨&&&***'; // Quaquer query...
      aCode_RestDW[_itens_pas] := '';
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := '...!!!@@@###!!!$$%%%¨¨¨&&&***'; // Quaquer query...
      aCode_RestDW[_itens_pas] := '';

      // Mizael
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := '.ExecQuery'; // Quaquer query...
      aCode_RestDW[_itens_pas] := '.ExecOrOpen';
      // acrescentar if not antes
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := ' ExecQuery'; // Quaquer query...
      aCode_RestDW[_itens_pas] := ' ExecOrOpen';

      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := '.ExecSQL'; // Quaquer query...
      aCode_RestDW[_itens_pas] := '.ExecOrOpen';

      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := ' ExecSQL'; // Quaquer query...
      aCode_RestDW[_itens_pas] := ' ExecOrOpen';

      // Mizael
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := 'TIBQuery';
      aCode_RestDW[_itens_pas] := 'TRESTClientSQL';
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := 'TIBSQL';
      aCode_RestDW[_itens_pas] := 'TRESTClientSQL';
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := 'TIBStoredProc';
      aCode_RestDW[_itens_pas] := 'TRESTStoredProc';
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := 'TIBStringField';
      aCode_RestDW[_itens_pas] := 'TStringField';
      Inc(_itens_pas);
      aCode_EngineOrigem[_itens_pas] := 'TIBBCDField';
      aCode_RestDW[_itens_pas] := 'TBCDField';

      // Flavio
      //
      // Descomente as linhas abaixo se vc nao usar ACTIVE para QUERYs
      //
      //Inc(_itens_pas);
      //aCode_EngineOrigem[_itens_pas] := '.Active';
      //aCode_RestDW[_itens_pas] := '//'; // comentar o inicio da linha

   end;
   //----------------------------------------------------------------------------------------------------------



   if ( cbxEngine.Text <> 'Zeos' ) and
      ( cbxEngine.Text <> 'IBX' ) then
   begin

        ShowMessage( 'Ajude o projeto. A conversão é feita apenas de ZEOS para RestDW por enquanto.' );
        Exit

   end;

   if not DirectoryExists( edPastaOriginal.text ) then
   begin

        MkDir( edPastaOriginal.text );
        ShowMessage( 'A pasta de arqs. a serem convertidos( ORIGINAL ) foi criada em : ' + sLineBreak +
                     edPastaOriginal.text + sLineBreak + sLineBreak +
                     'Copie os arquivos que deseja converter para essa pasta' );

   end;

   if not DirectoryExists( edPastaConvertido.text ) then
   begin

        MkDir( edPastaConvertido.text );
        ShowMessage( 'A pasta de arqs. migrados( CONVERTIDOS ) foi criada em : ' + sLineBreak +
                     edPastaConvertido.text + sLineBreak + sLineBreak +
                     'Os arquivos migrados serão copiados para essa pasta.' );

   end;

     //contar os arquivos definidos no Array
     //
     _tot := 0;

     if edFiltro.Text <> '' then
     begin

          _itens_filtros   := 1;
          aFiltroArqs[ 1 ] := edFiltro.Text;

     end;

     for a := 1 to _itens_filtros do
     begin

         if FindFirst( edPastaOriginal.text + aFiltroArqs[ a ], faAnyFile, SearchRec) = 0 then
         begin
            Inc(_tot);
            aArquivos[ _tot ] := SearchRec.Name;
         end;

         While ( FindNext( SearchRec ) = 0 ) do
         begin

              Inc(_tot);
              aArquivos[ _tot ] := SearchRec.Name;

         end;

         FindClose(SearchRec);

     end;

     // progresso geral
     pg.Max  := _tot;
     pg.Step := 1;//Trunc(_tot/100);
     pg.Position := 0;

     // processar DFM's
     //-----------------------
     //procura pelo primeiro programa
     //

     for t := 1 to _tot do
     begin

         Filename    := edPastaOriginal.text + aArquivos[ t ];
         NewFileName := edPastaConvertido.text  + aArquivos[ t ];

         //memo_Convertido.Lines.Clear;
         memo_Original.lines.clear;

         //falha com formato stream...
         if Filename <> '' then
         begin

              memo_Original.Lines.LoadFromFile( Filename );
              memo_Original.lines.clear;

         end;

         pg.Position := pg.Position + 1;

         labArq.Caption := 'Processando: ' + ExtractFileName( Filename );

         labTotArqs.Caption := 'Processado(s) ' + pg.Position.ToString + ' de ' + _tot.ToString;

         Application.ProcessMessages;

         //apaga o arq. de destino caso tenha sido processado anteriormente
         DeleteFile( NewFileName );

         //carrega arq. original
         memo_Original.Lines.LoadFromFile( Filename );

         linha := '';

         strArqDestino := TStringList.Create;
         strArqTemp    := TStringList.Create;

         // detalhes relativos apenas a arquivos DFM
         if ( Pos( '.dfm' , labArq.Caption ) > 0 ) then
         begin

             // verificar se existe partes de CODIGO pra substituir( EXECSQL por ex. )
             f := memo_Original.Lines.Count - 1;


             // linhas que nao sao compativeis com o RestDW e devem ser removidas integralmente
             //
             r := -1;
             while r <= f do //for r := 0 to f do
             begin

                 s := 0;
                 inc( r );
                 linha := memo_Original.Lines.Strings[ r ];

                 //if Pos( 'chkImportaDAV' , linha ) > 0 then
                 //   ShowMessage( 'chkImportaDAV 1' );

                 // fazer a critica de descarte..componentes q nao devem ser processados...
                 for I := 1 to _itens_descartar do
                 begin

                       // se o objeto atual for descarte, pula até o 'end' do objeto
                       if Pos( Ansilowercase( aDescartar[ I ] ) , Ansilowercase( linha ) ) > 0 then
                          s := 1;

                 end;

                 if s = 0 then
                    strArqTemp.Add( linha );

             end;

             memo_Original.Lines.Text := strArqTemp.Text;

             // verificar se existe partes de CODIGO pra substituir( EXECSQL por ex. )
             f := memo_Original.Lines.Count - 1;


             // Remover TFields IBX
             //
             if ( cbxEngine.Text = 'IBX' ) then
             begin
                 strArqTemp.Free;
                 strArqTemp    := TStringList.Create;

                 r := -1;
                 while r <= f do //for r := 0 to f do
                 begin

                     s := 0;

                     Inc( r );
                     linha := memo_Original.Lines.Strings[ r ]; //end GERAL do objeto principal

                     //if Pos( 'chkImportaDAV' , linha ) > 0 then
                     //   ShowMessage( 'chkImportaDAV 2' );

                     // Remover TFields
                     if ( Pos( 'field' , AnsiLowerCase( linha ) ) > 0 ) and
                        ( Pos( ': TIB' , linha ) > 0 ) then
                     begin

                         repeat

                            Dec( r );
                            repeat

                                  Inc( r );
                                  linha := memo_Original.Lines.Strings[ r ];


                            until ( Pos( ' end' , linha ) > 0 );

                            Inc( r );
                            linha := memo_Original.Lines.Strings[ r ];

                         until ( Pos( 'field' , AnsiLowerCase( linha ) ) = 0 ) and
                               ( Pos( ': T' , linha ) = 0 ) ;

                         //Inc( r );
                         //linha := memo_Original.Lines.Strings[ r ]; //end GERAL do objeto principal

                     end;

                     //if s = 0 then
                        strArqTemp.Add( linha );

                 end;

                 memo_Original.Lines.Text := strArqTemp.Text;

             end;

             //strArqTemp.SaveToFile( ExtractFileDir( ParamStr(0)) + '\descarte.txt' );

             //strArqTemp.Free;


             // verificar se existe partes de CODIGO pra substituir( EXECSQL por ex. )

             //fazer critica de substituicao/adicao de codigo
             //
             r := -1;
             while r <= f do //for r := 0 to f do
             begin

                 inc( r );

                 linha := memo_Original.Lines.Strings[ r ];

                 //if ( Pos( 'Params.Strings' , linha ) > 0 ) or
                 //if   ( Pos( 'TIBStringField' , linha ) > 0 ) then
                 //   showmessage( 'ok' );

                 //verificar se esta linha pode ser processada...
                 //if Pos( r.ToString + '.' + linha , strArqTemp.Text ) = 0 then
                 begin

                     //fazer critica de adicao de propriedades( inserir logo abaixo de Objetc TRestSql )
                     //
                     for I := 1 to _itens_alt_dfm do
                     begin

                         try

                            linha2 := aEngineOrigem[ i ];

                            //if ( Pos( aEngineOrigem[ i ] ,  linha ) > 0 ) then
                            if ( Pos( AnsiLowerCase( aEngineOrigem[ i ] ) , AnsiLowerCase( linha ) ) > 0 ) then
                            begin



                                 // até a prop. CONNECTION
                                 //if i <= 3 then
                                 //   linha := StringReplace( linha, aEngineOrigem[ I ] , aRestDw[ i ] , [ rfReplaceAll , rfIgnoreCase] )
                                 //else
                                 //   linha := aRestDw[ i ];

                                 linha := StringReplace( linha, aEngineOrigem[ I ] , aRestDw[ i ] , [ rfReplaceAll , rfIgnoreCase] )

                            end;

                         except

                         end;

                     end;

                     // adicionar controles FireDac caso nao existam ANTES da declaracao do RestDABASE
                     //
                     // into pq o RestDW usa FireDac, entao dependendo do Destino pode se mudar..
                     //
                     // nosso destino padrão será o RestDW
                     //
                     if ( Pos( 'TRESTDataBase' , linha ) > 0 ) then
                     begin
                           {
                           if ( Pos( 'TFDTransaction' , linha ) = 0 ) then
                           begin

                                strArqDestino.Add( '    ' + 'object FDTransaction: TFDTransaction' );
                                strArqDestino.Add( '  ' + '  Connection = sqlLocalDBC' );
                                strArqDestino.Add( '  ' + '  Left = 5' );
                                strArqDestino.Add( '  ' + '  Top = 5' );
                                strArqDestino.Add( '  ' + 'end' );

                           end;
                           }
                           if ( Pos( 'TFDGUIxWaitCursor' , linha ) = 0 ) then
                           begin

                                strArqDestino.Add( '  ' + 'object FDGUIxWaitCursor: TFDGUIxWaitCursor' );
                                strArqDestino.Add( '  ' + '  Provider = ''FMX''' );
                                strArqDestino.Add( '  ' + '  Left = 10' );
                                strArqDestino.Add( '  ' + '  Top = 10' );
                                strArqDestino.Add( '  ' + 'end' );

                           end;
                           if ( Pos( 'TFDStanStorageJSONLink' , linha ) = 0 ) then
                           begin

                                strArqDestino.Add( '  ' + 'object FDStanStorageJSONLink: TFDStanStorageJSONLink' );
                                strArqDestino.Add( '  ' + '  Left = 15' );
                                strArqDestino.Add( '  ' + '  Top = 15' );
                                strArqDestino.Add( '  ' + 'end' );

                           end;
                           if ( Pos( 'TFDStanStorageBinLink' , linha ) = 0 ) then
                           begin

                                strArqDestino.Add( '  ' + 'object FDStanStorageBinLink: TFDStanStorageBinLink' );
                                strArqDestino.Add( '  ' + '  Left = 20' );
                                strArqDestino.Add( '  ' + '  Top = 20' );
                                strArqDestino.Add( '  ' + 'end' );

                           end;


                     end;

                     if ( Trim( linha ) <> '' ) then
                        strArqDestino.Add( linha );

                      //fazer critica de adicao de propriedades
                      //
                      // só adiciona se a linha atual for a de declaracao do TRESTClientSQL
                      //
                      if ( Pos( 'database =' , AnsiLowerCase( linha ) ) > 0 ) then // Prop. DATABASE serve tanto pra ZEOS quanto pra IBX
                      begin

                           // apos a declaraco da QUERY vem o CONNECTION

                           for a := 1 to _itens_add_dfm do
                               strArqDestino.Add( '    ' + aNovos[ a ] );

                           linhaSQL := '';

                           // processar até o fim do objeto
                           //
                           // No caso da ZEOS, a propriedade Param e ParamData tem q ser removida
                           //
                           // outras engines podem ter algo semelhante...
                           repeat

                                 Inc( r );
                                 linha := memo_Original.Lines.Strings[ r ];

                                 // item composto pode iniciar com :
                                 //
                                 // item = <
                                 // end>
                                 //
                                 // ou
                                 //
                                 // item = (
                                 // ')
                                 //
                                 // e Existem os TFields que no caso do IBX há tipos
                                 // incompativeis como TIBStringField
                                 //
                                 sToken1 := Copy( ReverseStr( linha ), 1, 1 );
                                 sToken2 := '';

                                 if sToken1 = '<' then
                                    sToken2 := 'end>'
                                 else
                                 if sToken1 = '(' then
                                    sToken2 := ''')';


                                 for I := 1 to _itens_composto do
                                 begin

                                     if ( Pos( AnsiLowerCase( aEngineOrigemComposto[ I ] ) , AnsiLowerCase( linha ) ) > 0 ) and
                                        ( Pos( '<>' , linha ) = 0 )  then
                                     begin

                                        Dec( r );
                                        repeat

                                              Inc( r );
                                              linha := memo_Original.Lines.Strings[ r ];

                                        until ( Pos( sToken2 , linha ) > 0 );
                                        //until ( Pos( 'end>' , linha ) > 0 );

                                        Inc( r );
                                        linha := memo_Original.Lines.Strings[ r ];

                                     end;

                                 end;
                                     (*
                                 // Remover TFields
                                 if ( cbxEngine.Text = 'IBX' ) and
                                    ( Pos( 'field' , AnsiLowerCase( linha ) ) > 0 ) and
                                    ( Pos( ': TIB' , linha ) > 0 ) then
                                 begin

                                     //if ( Pos( 'field' , AnsiLowerCase( linha ) ) > 0 ) and
                                     //   ( Pos( ': TIB' , linha ) > 0 )  then
                                     //begin
                                     repeat

                                        Dec( r );
                                        repeat

                                              Inc( r );
                                              linha := memo_Original.Lines.Strings[ r ];

                                              //if Pos( 'QCaixaNFCE_NUMERO' , linha ) > 0 then
                                              //   showmessagE( '....' );

                                        until ( Pos( ' end' , linha ) > 0 );
                                        //until ( Pos( 'end>' , linha ) > 0 );

                                        Inc( r );
                                        linha := memo_Original.Lines.Strings[ r ];

                                     until ( Pos( 'field' , AnsiLowerCase( linha ) ) = 0 ) and
                                           ( Pos( ': T' , linha ) = 0 ) ;

                                     Inc( r );
                                     linha := memo_Original.Lines.Strings[ r ]; //end GERAL do objeto principal

                                 end;
                                    *)
                                 strArqDestino.Add( linha );

                           until ( Pos( ' end' , linha ) > 0 ) and ( Pos( '>' , linha ) = 0 );

                      end;

                      if ( Pos( 'TRESTDataBase' , linha ) > 0 ) then
                      begin

                           for a := 1 to _itens_add_dfm_PropRestDataBase do
                               strArqDestino.Add( '    ' + aAddPropRESTDataBase[ a ] );

                           //remover propriedades incompativeis
                           linhaSQL := '';

                           // processar até o fim do objeto
                           //
                           // No caso da ZEOS, a propriedade Param e ParamData tem q ser removida
                           //
                           // outras engines podem ter algo semelhante...
                           repeat

                                 Inc( r );
                                 linha := memo_Original.Lines.Strings[ r ];

                                 // item composto pode iniciar com :
                                 //
                                 // item = <
                                 // end>
                                 //
                                 // ou
                                 //
                                 // item = (
                                 // ')
                                 //
                                 sToken1 := Copy( ReverseStr( linha ), 1, 1 );
                                 sToken2 := '';

                                 if sToken1 = '<' then
                                    sToken2 := 'end>'
                                 else
                                 if sToken1 = '(' then
                                    sToken2 := ''')';


                                 for I := 1 to _itens_composto do
                                 begin

                                     if ( Pos( AnsiLowerCase( aEngineOrigemComposto[ I ] ) , AnsiLowerCase( linha ) ) > 0 ) and
                                        ( Pos( '<>' , linha ) = 0 )  then
                                     begin

                                        Dec( r );
                                        repeat

                                              Inc( r );
                                              linha := memo_Original.Lines.Strings[ r ];

                                        until ( Pos( sToken2 , linha ) > 0 );
                                        //until ( Pos( 'end>' , linha ) > 0 );

                                        Inc( r );
                                        linha := memo_Original.Lines.Strings[ r ];

                                     end;

                                 end;

                                 strArqDestino.Add( linha );

                           until ( Pos( ' end' , linha ) > 0 ) and ( Pos( '>' , linha ) = 0 );


                      end;

                 end;

             end;

         end
         else
         // detalhes relativos apenas a arquivos DFM
         //
         // para os .pas apenas substituir TZQuery( pelo menos por enquanto... )
         begin

             //------------------------------------------------------
             // transfere o arquvo original para o que vai ser convertido
             strArqDestino.Text := memo_Original.Lines.Text;

             strArqDestino.Text := StringReplace( memo_Original.Lines.Text, aEngineOrigem[ 1 ] , aRestDw[ 1 ] , [ rfReplaceAll, rfIgnoreCase ] ) ;

             //------------------------------------------------------
             //uses  ( acrescentar uRestPoolerDB.pas ou outras...
             //
             // unit contem TRestSQL, acrescentar a USES
             //
             // a linha abaixo foi comentada para ganho de performance. H;a um atraso em unis grandes...
             //if Pos( aRestDw[ 1 ] , memo_Convertido.Lines.Text ) > 0 then
             begin
                 s := Pos( 'uses'+#13#10 , AnsiLowerCase( strArqDestino.Text ) ) - 1;

                 if ( s > 0 ) then
                 begin

                     linha2 := Copy( strArqDestino.Text , 1, s + 4) + #13#10 + '  ';

                     linha3 := Copy( strArqDestino.Text , s + 5, Length( strArqDestino.Text ) );

                     for I := 1 to _itens_uses do
                     begin

                         try

                            // se nao houver a declaracao, adiciona...
                            if ( Pos( AnsiLowerCase( aUses[ i ] ) , AnsiLowerCase( strArqDestino.Text ) ) = 0 ) then
                            begin

                                 linha2 := linha2 + aUses[ I ] + ', ' ;

                            end;

                         except

                         end;

                     end;

                     strArqDestino.Text := linha2 + linha3;

                 end;

             end;
             //
             //------------------------------------------------------

             //------------------------------------------------------
             //Migrar EXECSql da Zeos/outros para RestDW
             //
             memo_Original.Lines.Clear;
             memo_Original.Lines.Text := strArqDestino.Text;

             strArqDestino.Clear;


             // verificar se existe partes de CODIGO pra substituir( EXECSQL por ex. )
             f := memo_Original.Lines.Count - 1;


             //fazer critica de substituicao/adicao de codigo
             //
             for r := 0 to f do
             begin

                 linha := memo_Original.Lines.Strings[ r ];

                 // para ACELERAR o processo de migracao, primeiro vericamos em todo o MEMO a existencia de conteudo a
                 // ser migrado, caso haja, entao prorcessamos LINHA a LINHA
                 for I := 1 to _itens_pas do
                 begin

                     try

                        //linha := memo_Original.Lines.Strings[ r ];

                        if ( Pos( AnsiLowerCase( aCode_EngineOrigem[ i ] ) , AnsiLowerCase( linha ) ) > 0 ) then
                        begin

                             //podemos substituir parte da linha de codigo ou a linha inteira
                             //
                             // no meu caso como tenho varias querys com EXECSQL, deixei a
                             // posicao 1 como sendo padrao pra substituir qualquer query
                             //
                             // adicione outras ocorrencias de acordo com sua necessidade
                             //
                             // as demais, serao substituicao de linha inteira( o q o gReplace, cnPack poderia fazer... )
                             //
                             // OBSERVEM  indice que IMPONHO logo abaixo, entao fiquem de olho no(s) item(ns) aCode_EngineOrigem
                             // pois pra ZEOS( no meu caso ) substituo e incluo um IF NOT ....
                             //
                             // na IBX, Mizael adicionou outras situações...
                             //
                             // if i = 1 then
                             if i <= 2 then
                             begin

                                 //pegar o nome da QUERY
                                 //
                                 // verificar se tem um DM ( por ex. antes do nome da query )
                                 a := Occurs( '.' , linha );

                                 //if pos( 'exec' , ansilowercase(linha) ) > 0 then
                                 //showmessagE( 'exec' );


                                 if a = 1 then
                                    linha2 := Copy( linha, 1, Pos( '.' , linha ) - 1 )
                                 else
                                 //if a > 1 then
                                 begin

                                      linha2 := Copy( linha, 1, OccurPos( '.' , linha, 2 ) - 1 );

                                 end;
                                 // caso a linha esteja indentada...
                                 espacos := '';
                                 s := 1;
                                 while Copy( linha2 , s , 1 ) = ' '  do
                                 begin

                                   espacos := espacos + ' ';
                                   Inc( s );

                                 end;

                                 if Trim( linha2 ) = '' then
                                    espacos := '       ';

                                 // monta a linha com a nova estrutura
                                 //if a >= 1 then
                                    linha := espacos + 'if not ' + Trim( linha2 ) + aCode_RestDw[ i ];

                             end
                             else
                             if aCode_RestDw[ i ] = '//' then
                             begin

                                 // monta a linha com a nova estrutura
                                 linha := aCode_RestDw[ i ] + linha;

                             end
                             else
                                linha := StringReplace( linha, aCode_EngineOrigem[ I ] , aCode_RestDw[ i ] , [ rfReplaceAll , rfIgnoreCase] ) ;

                        end;

                     except

                     end;

                 end;

                 strArqDestino.Add( linha );

             end;

             if strArqDestino.Text.IsEmpty then
                strArqDestino.Text := memo_Original.Lines.Text;

             //------------------------------------------------------

         end;

         //salva novo arq. convertido
         strArqDestino.SaveToFile( NewFileName );

         //Break;

         strArqDestino.Clear;

         strArqDestino.Free;
         strArqTemp.Free;

         memo_Original.lines.clear;

     end;

     ShowMessage( 'Processo Finalizado !' );

end;


procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 frmMain := Nil;
 Release;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin

     Self.Left := Trunc( screen.Width / 2 ) - trunc( Self.Width / 2 );
     Self.Top  := Trunc( screen.Height / 2 ) - trunc( Self.Height / 2 );

     edPastaOriginal.Text := ExtractFilePath( ParamStr( 0 )) + 'original\';

     edPastaConvertido.Text := ExtractFilePath( ParamStr( 0 )) + 'convertido\';
end;

end.
