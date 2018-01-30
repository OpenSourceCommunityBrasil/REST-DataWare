{
 Esta Classe Foi adaptada para se trabalhar com DW Core

Desenvolvida Por  : Fabricio Mata de castro
Empresa : Point informática Ltda - www.pointltda.com.br

}





unit uClassePonto;

interface

uses
//   CodeSiteLogging,
  IdHashMessageDigest, IdHash,
  Classes, DB, SysUtils, Windows, Vcl.Forms, Vcl.Dialogs, Math, StrUtils,
  Vcl.Controls,
  Messages, Variants, Vcl.Graphics, Vcl.ComCtrls, DBClient, TlHelp32,

  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,

  System.JSON,
  uDWJSONTools ;


const

  Codes64 = '0A1B2C3D4E5F6G7H89IjKlMnOPqRsTuVWXyZabcdefghijkLmNopQrStUvwxYz+/';
  C1 = 52845;
  C2 = 22719;

type

  TClassePonto = class(TObject)
  private
    FUpdateDB                : Boolean;
    FIdempresa               : string;
    FIdsys_point_cliente     : string;


  protected

  public

    constructor Create;
    destructor Destroy; override;
    property UpdateDB: Boolean read FUpdateDB write FUpdateDB;
    property Idempresa           : string   read FIdempresa           write FIdempresa ;
    property Idsys_point_cliente : string   read FIdsys_point_cliente write FIdsys_point_cliente;

    function Decrypt(const S: AnsiString; Key: Word): AnsiString;
    function Encrypt(const S: AnsiString; Key: Word): AnsiString;
    function Empty(Texto: string): Boolean;
    function ESomenteNumero(str: string): Boolean;
    function ExatoCurrency(Value: Currency; Decimal: integer): Currency;
    function PegaVersao: ShortString;
    function ValidaCPF(CPF: string): Boolean;
    function ValidaCNPJ(numCNPJ: string): Boolean;
    function MascaraDocumento(Documento: string): string;
    function SoNumeros(TextoLimpar: string): string;
    function Sotexto(TextoLimpar: string): string;
    function TBRound(Value: Extended; Decimals: integer): Extended;
    function StrChar(str: string; Charac: string; Qnt: integer; const Direita: Boolean = False): string;
    function Replicate(str: string; VezesReplic: integer): string;
    class function SeSenao(ACondicao: Boolean; ATrue, AFalse: Variant): Variant;
    function FixSlash(aPath: string): string;
    function RetornaGUID(const SemHifen: Boolean = True): string;
    function VersaoMaior(Ver1, Ver2: string): Boolean;
    function MD5File(const FileName: string): string;
    function VersaoArquivo(const FileName: string): string;
    function IsRunningProcess(exeFileName: string): Boolean;
    procedure ForEach(DataSet: TDataSet; Proc: TProc);
    procedure VerificaForm(TFormulario: TComponentClass; var Formulario); virtual;

    procedure SetDBMask(AMask: string; DBField: TField);
    function InSertUpdate(Pdataset: TFDMemTable; Ptabela: string): TStringList;
    function peganometabela(pjson: string): string;

  end;

var
  Funcoes: TClassePonto;

implementation

{ TClassePonto }

uses Data.FireDACJSONReflect, UDmService;

function TClassePonto.peganometabela(pjson: string): string;
var
  LJSONObject: TJSONObject;
  jSubPar: TJSONPair;
  achouTabela: Boolean;
  j: integer;

begin
  LJSONObject := nil;

  try
    LJSONObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(pjson), 0) as TJSONObject;
    achouTabela := False;
    for j := 0 to LJSONObject.Size - 1 do
    begin
      jSubPar := LJSONObject.Get(j); // pega o par no índice j
      if achouTabela then
      begin
        result := jSubPar.JsonString.Value;
        break;
      end;

      if UpperCase(trim(jSubPar.JsonString.Value)) = UpperCase(trim('ValueType')) then
      begin
        achouTabela := True;

      end;
    end;

  finally

    FreeAndNil(LJSONObject);

  end;
end;

function TClassePonto.InSertUpdate(Pdataset: TFDMemTable; Ptabela: string): TStringList;
var
  i: integer;
  FfieldName, Ffield, Fmatching: string;
  resultado: TStringList;
  LinhaInup: string;
  linhaencod: string;
  fdQuery : TFDQuery;
  _vsql : string ;
begin
  LinhaInup := ' update or insert into  ' + Ptabela + ' ( ';
  FfieldName := EmptyStr;
  Ffield := EmptyStr;
  Fmatching := 'matching (';
  resultado := TStringList.Create;
  // montando os fields
  FormatSettings.DecimalSeparator := '.';
  Pdataset.First;


  while not Pdataset.Eof do
  begin

    for i := 0 to Pdataset.Fields.Count - 1 do
    begin
      if (Pdataset.Fields[i].Required) then
        Fmatching := Fmatching + Pdataset.Fields.Fields[i].FieldName + ' , ';

      if UpperCase(copy(Pdataset.Fields.Fields[i].FieldName, 1, 3)) <> UpperCase('FK_') then
        FfieldName := FfieldName + Pdataset.Fields.Fields[i].FieldName + ',';

    end;
    break;
  end;

  FfieldName := copy(FfieldName, 1, (length(FfieldName) - 1));

  LinhaInup := LinhaInup + FfieldName + ' ) values ( ';

  // montando inserto or update
  Pdataset.First;
  while not Pdataset.Eof do
  begin
    Ffield := EmptyStr;
    for i := 0 to Pdataset.Fields.Count - 1 do
    begin
      if UpperCase(copy(Pdataset.Fields.Fields[i].FieldName, 1, 3)) <> UpperCase('FK_') then
      begin
        try

          case Pdataset.Fields.Fields[i].DataType of
            ftString, ftblob, ftMemo:
              begin


                if (Pdataset.Fields.Fields[i].AsString = EmptyStr) then
                  Ffield := Ffield + ' null,'
                else
                  if Pdataset.Fields.Fields[i].AsString =#0#0  then  // caso campo blob
                     Ffield := Ffield + ' null,'
                  else
                    Ffield := Ffield + QuotedStr(Pdataset.Fields.Fields[i].AsString) + ',';
              end;
            ftInteger:
              if (Pdataset.Fields.Fields[i].AsString = EmptyStr) then
                Ffield := Ffield + ' null,'
              else
              begin


               if ( Pdataset.Fields.Fields[i].AutoGenerateValue =  arAutoInc   ) and
               ( UpperCase( Pdataset.Fields.Fields[i].FieldName ) = uppercase( 'id'+Ptabela ) )
               and (Pdataset.Fields.Fields[i].Value = 0 ) then
               begin

               fdQuery := TFDQuery.Create(Nil);
               Try
                fdQuery.Connection := UDmService.ServerMetodDM.Server_FDConnection;
                _vsql := 'select ID_RETORNO from PRC_SEQUENCIADORA( :PSYS_POINT_CLIENTE, :PEMPRESA,:PTABELA,:PCAMPO,:PPENDENCIA,:PVALORATUAL)';
                fdQuery.SQL.Text := _vsql;
                fdQuery.ParamByName('PSYS_POINT_CLIENTE').AsString := FIDSYS_POINT_CLIENTE;
                fdQuery.ParamByName('PEMPRESA').AsString := FIdempresa;
                fdQuery.ParamByName('PTABELA').AsString := AnsiUpperCase( Ptabela);
                fdQuery.ParamByName('PCAMPO').AsString := AnsiUpperCase( 'ID'+Ptabela);
                fdQuery.ParamByName('PPENDENCIA').AsInteger := 0;
                fdQuery.ParamByName('PVALORATUAL').AsInteger := 0;
                fdQuery.Prepare;
                fdQuery.Open;

                Ffield := Ffield + fdQuery.FieldByName('ID_RETORNO').AsString+ ',';

               Finally
                    FreeAndNil(fdQuery);
               End;

               end
               else
                 Ffield := Ffield + Pdataset.Fields.Fields[i].AsString + ',';

              end;
            ftBoolean:

              Ffield := Ffield + Pdataset.Fields.Fields[i].FieldName + ',';
            ftCurrency, ftBCD, ftFloat:
              Ffield := Ffield + QuotedStr(FormatCurr('0.00', Pdataset.Fields.Fields[i].AsCurrency)) + ',';

            ftDate, ftTime, ftDateTime, ftTimeStamp:
              Ffield := Ffield + QuotedStr(FormatDateTime('dd.mm.yyyy',
                StrToDate(Pdataset.Fields.Fields[i].FieldName))) + ',';

          end;
        except
          Ffield := Ffield + ' null,';
        end;
      end;
    end;

    linhaencod := LinhaInup + #13#10 + copy(trim(Ffield), 1, (length(trim(Ffield)) - 1)) + #13#10 + ' ) ' + #13#10 +
      copy(trim(Fmatching), 1, (length(trim(Fmatching)) - 1)) + ' )';


    resultado.Add(linhaencod);

    Pdataset.Next;
  end;
  FormatSettings.DecimalSeparator := ',';
  result := resultado;
  
end;

constructor TClassePonto.Create;
begin
  FUpdateDB := False;
end;

function TClassePonto.Decrypt(const S: AnsiString; Key: Word): AnsiString;
  function InternalDecrypt(const S: AnsiString; Key: Word): AnsiString;
  var
    i: Word;
    Seed: int64;
  begin
    result := S;
    Seed := Key;
    for i := 1 to length(result) do
    begin
      result[i] := AnsiChar(Byte(result[i]) xor (Seed shr 8));
      Seed := (Byte(S[i]) + Seed) * Word(C1) + Word(C2)
    end
  end;
  function PreProcess(const S: AnsiString): AnsiString;
  var
    SS: AnsiString;
    function Decode(const S: AnsiString): AnsiString;
    const
      Map: array [AnsiChar] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 0, 0, 0, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0,
        0, 0, 0, 0, 0, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
        50, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    var
      i: LongInt;
    begin
      case length(S) of
        2:
          begin
            i := Map[S[1]] + (Map[S[2]] shl 6);
            SetLength(result, 1);
            Move(i, result[1], length(result))
          end;
        3:
          begin
            i := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12);
            SetLength(result, 2);
            Move(i, result[1], length(result))
          end;
        4:
          begin
            i := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12) + (Map[S[4]] shl 18);
            SetLength(result, 3);
            Move(i, result[1], length(result))
          end
      end
    end;

  begin
    SS := S;
    result := '';
    while SS <> '' do
    begin
      result := result + Decode(copy(SS, 1, 4));
      Delete(SS, 1, 4)
    end
  end;

begin
  result := InternalDecrypt(PreProcess(S), Key)
end;

destructor TClassePonto.Destroy;
begin
  inherited;
end;

function TClassePonto.Empty(Texto: string): Boolean;
begin
  result := (trim(Texto) = '');
end;

function TClassePonto.Encrypt(const S: AnsiString; Key: Word): AnsiString;
  function InternalEncrypt(const S: AnsiString; Key: Word): AnsiString;
  var
    i: Word;
    Seed: int64;
  begin
    result := S;
    Seed := Key;
    for i := 1 to length(result) do
    begin
      result[i] := AnsiChar(Byte(result[i]) xor (Seed shr 8));
      Seed := (Byte(result[i]) + Seed) * Word(C1) + Word(C2)
    end
  end;
  function PostProcess(const S: AnsiString): AnsiString;
  var
    SS: AnsiString;

    function Encode(const S: AnsiString): AnsiString;
    const
      Map: array [0 .. 63] of AnsiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz0123456789+/';
    var
      i: LongInt;
    begin
      i := 0;
      Move(S[1], i, length(S));
      case length(S) of
        1:
          result := Map[i mod 64] + Map[(i shr 6) mod 64];
        2:
          result := Map[i mod 64] + Map[(i shr 6) mod 64] + Map[(i shr 12) mod 64];
        3:
          result := Map[i mod 64] + Map[(i shr 6) mod 64] + Map[(i shr 12) mod 64] + Map[(i shr 18) mod 64]
      end
    end;

  begin
    SS := S;
    result := '';
    while SS <> '' do
    begin
      result := result + Encode(copy(SS, 1, 3));
      Delete(SS, 1, 3)
    end
  end;

begin
  result := PostProcess(InternalEncrypt(S, Key))
end;

function TClassePonto.ESomenteNumero(str: string): Boolean;
var
  i: integer;
begin
  result := True;
  for i := 1 to length(str) do
  begin
    if not CharInSet(str[i], ['0' .. '9']) then
      result := False;
  end;
end;

function TClassePonto.ExatoCurrency(Value: Currency; Decimal: integer): Currency;
const
  arrDecimal: array [0 .. 4] of integer = (1, 10, 100, 1000, 10000);
begin
  if (Abs(Decimal) > 4) then
    raise ERangeError.Create('TruncExato: O decimal deve está no intervalo de: 0..4');
  result := Trunc(Value * arrDecimal[Decimal]) / arrDecimal[Decimal];
end;

function TClassePonto.FixSlash(aPath: string): string;
var
  vPath: string;
begin
  vPath := aPath;

  if vPath <> '' then
  begin
    if vPath[length(vPath)] <> '\' then
      vPath := vPath + '\';
    if vPath[1] = '\' then
      Delete(vPath, 1, 1);
  end;

  result := vPath;
end;

procedure TClassePonto.ForEach(DataSet: TDataSet; Proc: TProc);
var
  Bookmark: TBookmark;
begin
  Screen.Cursor := crHourGlass;
  DataSet.DisableControls;
  try
    Bookmark := DataSet.Bookmark;
    DataSet.First;
    while not DataSet.Eof do
    begin
      Proc;
      DataSet.Next;
    end;
    DataSet.Bookmark := Bookmark;
  finally
    DataSet.EnableControls;
    Screen.Cursor := crDefault;
  end;
end;

function TClassePonto.IsRunningProcess(exeFileName: string): Boolean;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  result := False;
  while integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(exeFileName)) or
      (UpperCase(FProcessEntry32.szExeFile) = UpperCase(exeFileName))) then
    begin
      result := True;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function TClassePonto.MascaraDocumento(Documento: string): string;
var
  vDocumento: string;
begin
  vDocumento := '';
  if length(Documento) = 11 then // CPF
    vDocumento := copy(Documento, 1, 3) + '.' + copy(Documento, 4, 3) + '.' + copy(Documento, 7, 3) + '-' +
      copy(Documento, 10, 2)
  else if length(Documento) = 14 then // CNPJ
    vDocumento := copy(Documento, 1, 2) + '.' + copy(Documento, 3, 3) + '.' + copy(Documento, 6, 3) + '/' +
      copy(Documento, 9, 4) + '-' + copy(Documento, 13, 2);
  if vDocumento <> '' then
    result := vDocumento
  else
    result := Documento;
end;

function TClassePonto.MD5File(const FileName: string): string;
var
  IdMD5: TIdHashMessageDigest5;
  FS: TFileStream;
begin
  IdMD5 := TIdHashMessageDigest5.Create;
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    result := IdMD5.HashStreamAsHex(FS)
  finally
    FS.Free;
    IdMD5.Free;
  end;
end;

function TClassePonto.PegaVersao: ShortString;
type
  PVerInfo = ^TVSFIXEDFILEINFO;
var
  Buf: Pointer;
  KeyPath, SelfPath: string;
  Len, Sz, L: cardinal;
  VerInfo: PVerInfo;
  VerInfoPresent: Boolean;
begin
  result := '-1';

  VerInfoPresent := False;
  SelfPath := ParamStr(0) + #0;
  Sz := GetFileVersionInfoSize(Addr(SelfPath[1]), L);
  GetMem(Buf, Sz);
  try
    if (Sz > 0) and GetFileVersionInfo(Addr(SelfPath[1]), 0, Sz, Buf) then
      VerInfoPresent := True;

    if VerInfoPresent then
    begin
      KeyPath := '\' + #0;
      if VerQueryValue(Buf, Addr(KeyPath[1]), Pointer(VerInfo), Len) then
        result := inttostr(HIWORD(VerInfo.dwFileVersionMS)) + '.' + inttostr(LOWORD(VerInfo.dwFileVersionMS)) + '.' +
          inttostr(HIWORD(VerInfo.dwFileVersionLS)) + '.' + inttostr(LOWORD(VerInfo.dwFileVersionLS));
    end;
  finally
    FreeMem(Buf);
  end;
end;

function TClassePonto.Replicate(str: string; VezesReplic: integer): string;
var
  iVezesReplic: integer;
  vStr: string;
begin
  for iVezesReplic := 1 to VezesReplic do
    vStr := vStr + str;
  result := vStr;
end;

function TClassePonto.RetornaGUID(const SemHifen: Boolean): string;
var
  vGUID: TGUID;
begin
  CreateGUID(vGUID);
  if not SemHifen then
    result := GUIDToString(vGUID)
  else
  begin
    result := StringReplace(GUIDToString(vGUID), '-', EmptyStr, [rfReplaceAll]);
    result := StringReplace(result, '{', EmptyStr, [rfReplaceAll]);
    result := StringReplace(result, '}', EmptyStr, [rfReplaceAll]);
  end;
end;

class function TClassePonto.SeSenao(ACondicao: Boolean; ATrue, AFalse: Variant): Variant;
begin
  result := AFalse;
  if ACondicao then
    result := ATrue;
end;

procedure TClassePonto.SetDBMask(AMask: string; DBField: TField);
begin
  DBField.EditMask := AMask;
end;

function TClassePonto.SoNumeros(TextoLimpar: string): string;
var
  iLimpar: integer;
  TextoLimpo: string;
begin
  TextoLimpo := '';
  for iLimpar := 1 to length(TextoLimpar) do
  begin
    if CharInSet(TextoLimpar[iLimpar], ['0' .. '9']) then
      TextoLimpo := TextoLimpo + TextoLimpar[iLimpar];
  end;
  result := TextoLimpo;
end;

function TClassePonto.Sotexto(TextoLimpar: string): string;
var
  iLimpar: integer;
  TextoLimpo: string;
begin
  TextoLimpo := '';
  for iLimpar := 1 to length(TextoLimpar) do
  begin
    if CharInSet(TextoLimpar[iLimpar], ['0' .. '9', 'a' .. 'z', 'A' .. 'Z']) then
      TextoLimpo := TextoLimpo + TextoLimpar[iLimpar];

    if CharInSet(TextoLimpar[iLimpar], ['$']) then
      TextoLimpo := TextoLimpo + TextoLimpar[iLimpar];
    if CharInSet(TextoLimpar[iLimpar], ['%']) then
      TextoLimpo := TextoLimpo + TextoLimpar[iLimpar];

  end;
  result := TextoLimpo;
end;

function TClassePonto.StrChar(str, Charac: string; Qnt: integer; const Direita: Boolean = False): string;
var
  iSpace: integer;
  vStr: string;
begin
  for iSpace := 1 to (Qnt - length(str)) do
    vStr := vStr + Charac;
  if Direita then
    result := str + vStr
  else
    result := vStr + str;
end;

function TClassePonto.TBRound(Value: Extended; Decimals: integer): Extended;
var
  Factor, Fraction: Extended;
begin
  { Arredondamento para 'n' casas decimais. }

  Factor := IntPower(10, Decimals);
  { A conversão para string e depois para float evita
    erros de arredondamentos indesejáveis. }
  Value := StrToFloat(FloatToStr(Value * Factor));
  result := Int(Value);
  Fraction := Frac(Value);
  if Fraction >= 0.5 then
    result := result + 1
  else if Fraction <= -0.5 then
    result := result - 1;
  result := result / Factor;
end;

function TClassePonto.ValidaCNPJ(numCNPJ: string): Boolean;
var
  CNPJ: string;
  dg1, dg2: integer;
  x, total: integer;
  ret: Boolean;
begin
  ret := False;
  CNPJ := '';
  // Analisa os formatos
  if length(numCNPJ) = 18 then
    if (copy(numCNPJ, 3, 1) + copy(numCNPJ, 7, 1) + copy(numCNPJ, 11, 1) + copy(numCNPJ, 16, 1) = '../-') then
    begin
      CNPJ := copy(numCNPJ, 1, 2) + copy(numCNPJ, 4, 3) + copy(numCNPJ, 8, 3) + copy(numCNPJ, 12, 4) +
        copy(numCNPJ, 17, 2);
      ret := True;
    end;
  if length(numCNPJ) = 14 then
  begin
    CNPJ := numCNPJ;
    ret := True;
  end;
  // Verifica
  if ret then
  begin
    try
      // 1° digito
      total := 0;
      for x := 1 to 12 do
      begin
        if x < 5 then
          Inc(total, StrToInt(copy(CNPJ, x, 1)) * (6 - x))
        else
          Inc(total, StrToInt(copy(CNPJ, x, 1)) * (14 - x));
      end;
      dg1 := 11 - (total mod 11);
      if dg1 > 9 then
        dg1 := 0;
      // 2° digito
      total := 0;
      for x := 1 to 13 do
      begin
        if x < 6 then
          Inc(total, StrToInt(copy(CNPJ, x, 1)) * (7 - x))
        else
          Inc(total, StrToInt(copy(CNPJ, x, 1)) * (15 - x));
      end;
      dg2 := 11 - (total mod 11);
      if dg2 > 9 then
        dg2 := 0;
      // Validação final
      if (dg1 = StrToInt(copy(CNPJ, 13, 1))) and (dg2 = StrToInt(copy(CNPJ, 14, 1))) then
        ret := True
      else
        ret := False;
    except
      ret := False;
    end;
    // Inválidos
    case AnsiIndexStr(CNPJ, ['00000000000000', '11111111111111', '22222222222222', '33333333333333', '44444444444444',
      '55555555555555', '66666666666666', '77777777777777', '88888888888888', '99999999999999']) of
      0 .. 9:
        ret := False;
    end;
  end;
  ValidaCNPJ := ret;
end;

function TClassePonto.ValidaCPF(CPF: string): Boolean;
var
  n1, n2, n3, n4, n5, n6, n7, n8, n9: integer;
  d1, d2: integer;
  digitado, calculado, num: string;
begin
  num := SoNumeros(CPF);
  n1 := StrToInt(num[1]);
  n2 := StrToInt(num[2]);
  n3 := StrToInt(num[3]);
  n4 := StrToInt(num[4]);
  n5 := StrToInt(num[5]);
  n6 := StrToInt(num[6]);
  n7 := StrToInt(num[7]);
  n8 := StrToInt(num[8]);
  n9 := StrToInt(num[9]);
  d1 := n9 * 2 + n8 * 3 + n7 * 4 + n6 * 5 + n5 * 6 + n4 * 7 + n3 * 8 + n2 * 9 + n1 * 10;
  d1 := 11 - (d1 mod 11);
  if d1 >= 10 then
    d1 := 0;
  d2 := d1 * 2 + n9 * 3 + n8 * 4 + n7 * 5 + n6 * 6 + n5 * 7 + n4 * 8 + n3 * 9 + n2 * 10 + n1 * 11;
  d2 := 11 - (d2 mod 11);
  if d2 >= 10 then
    d2 := 0;
  calculado := inttostr(d1) + inttostr(d2);
  digitado := num[10] + num[11];
  if calculado = digitado then
    result := True
  else
end;

procedure TClassePonto.VerificaForm(TFormulario: TComponentClass; var Formulario);
var
  i: integer;
  Achou: Boolean;
begin
  try
    Screen.Cursor := crHourGlass;
    Achou := False;
    for i := 0 to Screen.FormCount - 1 do
    begin

      if Screen.Forms[i].ClassType = TFormulario then
      begin
        Achou := True;
        if TForm(Formulario).Visible = False then
          TForm(Formulario).Visible := True;
        TForm(Formulario).Show;
      end;
    end;
    if not Achou then
    begin
      Application.CreateForm(TFormulario, Formulario);
      if (TForm(Formulario).FormStyle = fsMDIChild) and (TForm(Formulario).Tag = 15) then
        TForm(Formulario).Visible := True;

      if TForm(Formulario).FormStyle = fsNormal then
      begin
        try

          TForm(Formulario).ShowModal;
        finally
          TForm(Formulario).Release;
        end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TClassePonto.VersaoArquivo(const FileName: string): string;
var
  VerInfoSize, VerValueSize, Dummy: Dword;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
  V1, V2, V3, V4: Word;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    V1 := dwFileVersionMS shr 16;
    V2 := dwFileVersionMS and $FFFF;
    V3 := dwFileVersionLS shr 16;
    V4 := dwFileVersionLS and $FFFF;
  end;
  FreeMem(VerInfo, VerInfoSize);
  result := inttostr(V1) + '.' + inttostr(V2) + '.' + inttostr(V3) + '.' + inttostr(V4);
end;

function TClassePonto.VersaoMaior(Ver1, Ver2: string): Boolean;
var
  na, nb: array [1 .. 4] of integer;
  i, Ps: integer;
  sStr, tVer1, tVer2: string;
begin
  tVer1 := trim(Ver1);
  tVer2 := trim(Ver2);
  if (Pos('.', tVer1) <= 0) or (Pos('.', tVer2) <= 0) then
  begin
    result := True;
    Exit;
  end;

  { Pegando a primeira versão, e decompondo ela }
  sStr := tVer1;
  for i := 1 to 4 do
  begin
    Ps := Pos('.', sStr);
    if Ps > 0 then
      na[i] := StrToInt(copy(sStr, 1, Ps - 1))
    else
      na[i] := StrToInt(sStr);
    sStr := copy(sStr, Ps + 1, length(sStr));
  end;

  { Pegando a segunda versão, e decompondo ela }
  sStr := tVer2;
  for i := 1 to 4 do
  begin
    Ps := Pos('.', sStr);
    if Ps > 0 then
      nb[i] := StrToInt(copy(sStr, 1, Ps - 1))
    else
      nb[i] := StrToInt(sStr);
    sStr := copy(sStr, Ps + 1, length(sStr));
  end;

  result := False;

  if (na[1] > nb[1]) then
    result := True;
  if (na[1] <= nb[1]) and (na[2] > nb[2]) then
    result := True;
  if (na[1] <= nb[1]) and (na[2] <= nb[2]) and (na[3] > nb[3]) then
    result := True;
  if (na[1] <= nb[1]) and (na[2] <= nb[2]) and (na[3] <= nb[3]) and (na[4] > nb[4]) then
    result := True;

end;

end.
