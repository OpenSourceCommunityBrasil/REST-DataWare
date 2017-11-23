unit UFuncoesSysUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniGroupBox,
  uniEdit, uniDBEdit, uniLabel,pngimage, uniPanel, uniImage,
  uniButton, uniBitBtn, uniRadioButton, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uniPageControl, uniMemo,
  UniHTMLMemo;

function Kernel_ValidarCNPJ(CNPJ: string): Boolean;
function ValidarChaveNFe(const ChaveNFe: string):boolean;
Function IsWrongIP(ip: string): Boolean;

implementation

Function IsWrongIP(ip: string): Boolean;
var
  z: Integer;
  i: byte;
  st: array [1 .. 3] of byte;
const
  ziff = ['0' .. '9'];
begin
  st[1] := 0;
  st[2] := 0;
  st[3] := 0;
  z := 0;
  Result := False;
  for i := 1 to Length(ip) do
    if ip[i] in ziff then
    else
    begin
      if ip[i] = '.' then
      begin
        Inc(z);
        if z < 4 then
          st[z] := i
        else
        begin
          IsWrongIP := True;
          Exit;
        end;
      end
      else
      begin
        IsWrongIP := True;
        Exit;
      end;
    end;
  if (z <> 3) or (st[1] < 2) or (st[3] = Length(ip)) or (st[1] + 2 > st[2]) or
    (st[2] + 2 > st[3]) or (st[1] > 4) or (st[2] > st[1] + 4) or
    (st[3] > st[2] + 4) then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, 1, st[1] - 1));
  if (z > 255) or (ip[1] = '0') then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, st[1] + 1, st[2] - st[1] - 1));
  if (z > 255) or ((z <> 0) and (ip[st[1] + 1] = '0')) then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, st[2] + 1, st[3] - st[2] - 1));
  if (z > 255) or ((z <> 0) and (ip[st[2] + 1] = '0')) then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, st[3] + 1, Length(ip) - st[3]));
  if (z > 255) or ((z <> 0) and (ip[st[3] + 1] = '0')) then
  begin
    IsWrongIP := True;
    Exit;
  end;
end;

function Kernel_ValidarCNPJ(CNPJ: string): Boolean;

  function LimparCNPJ(CNPJ: string): string;
  begin
    result := StringReplace(CNPJ, '.', '', [rfReplaceAll]);
    result := StringReplace(result, '-', '', [rfReplaceAll]);
    result := StringReplace(result, '/', '', [rfReplaceAll]);
  end;

var
  i, soma, mult: Integer;
  aCNPJ: string;
begin
  result := False;
  aCNPJ := LimparCNPJ(CNPJ);

  if Length(aCNPJ) <> 14 then
  begin
    result := False;
    exit;
  end;

  soma := 0;
  mult := 2;

  for i := 12 downto 1 do
  begin
    soma := soma + StrToInt(aCNPJ[i]) * mult;
    mult := mult + 1;
    if mult > 9 then
      mult := 2;
  end;

  mult := soma mod 11;

  if mult <= 1 then
    mult := 0
  else
    mult := 11 - mult;

  if mult <> StrToInt(aCNPJ[13]) then
  begin
    result := False;
    exit;
  end;

  soma := 0;
  mult := 2;

  for i := 13 downto 1 do
  begin
    soma := soma + StrToInt(aCNPJ[i]) * mult;
    mult := mult + 1;

    if mult > 9 then
      mult := 2;
  end;

  mult := soma mod 11;
  if mult <= 1 then
    mult := 0
  else
    mult := 11 - mult;

  if mult = StrToInt(aCNPJ[14]) then
    result := True
  else
   result := False;
end;

function ValidarChaveNFe(const ChaveNFe: string):boolean;
const
  PESO : Array[0..43] of Integer = (4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4,
  3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 0);
var
  Retorno : boolean;
  aChave  : Array[0..43] of Char;
  Soma    : Integer;
  Verif   : Integer;
  I       : Integer;
begin
  Retorno := false;
  try
    try
      if not Length(ChaveNFe) = 44 then
        raise Exception.Create('');

      StrPCopy(aChave,StringReplace(ChaveNFe,' ', '',[rfReplaceAll]));
      Soma := 0;
      for I := Low(aChave) to High(aChave) do
        Soma := Soma + (StrToInt(aChave[i]) * PESO[i]);

      if Soma = 0 then
        raise Exception.Create('');

      Soma := Soma - (11 * (Trunc(Soma / 11)));
      if (Soma = 0) or (Soma = 1) then
        Verif := 0
      else
        Verif := 11 - Soma;

      Retorno := Verif = StrToInt(aChave[43]);
    except
      Retorno := false;
    end;
  finally
    Result := Retorno;
  end;
end;


end.
