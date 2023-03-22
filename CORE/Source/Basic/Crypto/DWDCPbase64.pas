unit DWDCPbase64;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

uses
  DWDCPtypes, Sysutils;

function Base64EncodeStr(const Value: DWDCPRawString): DWDCPRawString; overload;
  { Encode a string into Base64 format }
function Base64DecodeStr(const Value: DWDCPRawString): DWDCPRawString; overload;
  { Decode a Base64 format string }
{$IFNDEF NOTRAWSUPPORT}
function Base64EncodeStr(const Value: DWDCPUnicodeString): String; overload;
  { Encode a Unicode string into Base64 format }
function Base64DecodeStr(const Value: DWDCPUnicodeString): String; overload;
  { Decode a Base64 format Unicode string }
{$ENDIF}
function Base64Encode(pInput: pointer; pOutput: pointer; Size: longint): longint;
  { Encode a lump of raw data (output is (4/3) times bigger than input) }
function Base64Decode(pInput: pointer; pOutput: pointer; Size: longint): longint;
  { Decode a lump of raw data }


{******************************************************************************}
{******************************************************************************}
implementation
{$Q-}{$R-}

const
{$IFDEF NEXTGEN}
  STRINGBASE = 0;
{$ELSE}
  STRINGBASE = 1;
{$ENDIF}

const
  B64: array[0..63] of byte= (65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
    81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,
    109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,
    54,55,56,57,43,47);

function Base64Encode(pInput: pointer; pOutput: pointer; Size: longint): longint;
var
  i, iptr, optr: integer;
  Input, Output: PByteArray;
begin
  Input:= PByteArray(pInput); Output:= PByteArray(pOutput);
  iptr:= 0; optr:= 0;
  for i:= 1 to (Size div 3) do
  begin
    Output^[optr+0]:= B64[Input^[iptr] shr 2];
    Output^[optr+1]:= B64[((Input^[iptr] and 3) shl 4) + (Input^[iptr+1] shr 4)];
    Output^[optr+2]:= B64[((Input^[iptr+1] and 15) shl 2) + (Input^[iptr+2] shr 6)];
    Output^[optr+3]:= B64[Input^[iptr+2] and 63];
    Inc(optr,4); Inc(iptr,3);
  end;
  case (Size mod 3) of
    1: begin
         Output^[optr+0]:= B64[Input^[iptr] shr 2];
         Output^[optr+1]:= B64[(Input^[iptr] and 3) shl 4];
         Output^[optr+2]:= byte('=');
         Output^[optr+3]:= byte('=');
       end;
    2: begin
         Output^[optr+0]:= B64[Input^[iptr] shr 2];
         Output^[optr+1]:= B64[((Input^[iptr] and 3) shl 4) + (Input^[iptr+1] shr 4)];
         Output^[optr+2]:= B64[(Input^[iptr+1] and 15) shl 2];
         Output^[optr+3]:= byte('=');
       end;
  end;
  Result:= ((Size+2) div 3) * 4;
end;

function Base64EncodeStr(const Value: DWDCPRawString): DWDCPRawString;
begin
  SetLength(Result,((Length(Value)+2) div 3) * 4);
  Base64Encode(@Value[STRINGBASE],@Result[STRINGBASE],Length(Value));
end;

{$IFNDEF NOTRAWSUPPORT}
function Base64EncodeStr(const Value: DWDCPUnicodeString): String;
var
  temp: DWDCPRawString;
begin
  SetLength(temp,(((Length(Value)*SizeOf(Value[STRINGBASE])+2) div 3) * 4));
  Base64Encode(@Value[STRINGBASE],@temp[STRINGBASE],Length(Value)*SizeOf(Value[STRINGBASE]));
  Result:= DWDCPUnicodeString(temp);
end;
{$ENDIF}

function Base64Decode(pInput: pointer; pOutput: pointer; Size: longint): longint;
var
  i, j, iptr, optr: integer;
  Temp: array[0..3] of byte;
  Input, Output: PByteArray;
begin
  Input:= PByteArray(pInput); Output:= PByteArray(pOutput);
  iptr:= 0; optr:= 0;
  Result:= 0;
  for i:= 1 to (Size div 4) do
  begin
    for j:= 0 to 3 do
    begin
      case Input^[iptr] of
        65..90 : Temp[j]:= Input^[iptr] - Ord('A');
        97..122: Temp[j]:= Input^[iptr] - Ord('a') + 26;
        48..57 : Temp[j]:= Input^[iptr] - Ord('0') + 52;
        43     : Temp[j]:= 62;
        47     : Temp[j]:= 63;
        61     : Temp[j]:= $FF;
      end;
      Inc(iptr);
    end;
    Output^[optr]:= (Temp[0] shl 2) or (Temp[1] shr 4);
    Result:= optr+1;
    if (Temp[2]<> $FF) and (Temp[3]= $FF) then
    begin
      Output^[optr+1]:= (Temp[1] shl 4) or (Temp[2] shr 2);
      Result:= optr+2;
      Inc(optr)
    end
    else if (Temp[2]<> $FF) then
    begin
      Output^[optr+1]:= (Temp[1] shl 4) or (Temp[2] shr 2);
      Output^[optr+2]:= (Temp[2] shl 6) or  Temp[3];
      Result:= optr+3;
      Inc(optr,2);
    end;
    Inc(optr);
  end;
end;

function Base64DecodeStr(const Value: DWDCPRawString): DWDCPRawString;
begin
  SetLength(Result,(Length(Value) div 4) * 3);
  SetLength(Result,Base64Decode(@Value[STRINGBASE],@Result[STRINGBASE],Length(Value)));
end;

{$IFNDEF NOTRAWSUPPORT}
function Base64DecodeStr(const Value: DWDCPUnicodeString): String;
var
  temp: DWDCPRawString;
begin
  temp:= DWDCPRawString(Value);
  SetLength(Result,(Length(temp) div 4) * 3);
  SetLength(Result,Base64Decode(@temp[STRINGBASE],@Result[STRINGBASE],Length(temp)) div SizeOf(Result[STRINGBASE]));
end;
{$ENDIF}

end.
