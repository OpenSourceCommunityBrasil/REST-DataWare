unit uRESTDWSelfSignedMacros;

{$I ..\..\..\Source\Includes\uRESTDW.inc}

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
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

uses
  Classes, SysUtils, uRESTDWOpenSslLib;

function EVP_PKEY_CTX_set_rsa_keygen_bits(pctx: PEVP_PKEY_CTX; bits: Integer): integer;
function EVP_PKEY_CTX_set_ec_paramgen_curve_nid(pctx: PEVP_PKEY_CTX; nid: Integer): integer;
function EVPPKEYCBcallFunc(pctx: PEVP_PKEY_CTX): Integer; cdecl;
function EVP_PKEY_dup(PKey: PEVP_PKEY): PEVP_PKEY;

implementation

uses
  uRESTDWSelfSigned;

function EVP_PKEY_CTX_set_rsa_keygen_bits(pctx : PEVP_PKEY_CTX; bits : Integer) : integer;
var
  keytype: Integer;
  optype: Integer;
  cmd: Integer;
  p1: Integer;
  p2: Pointer;
begin
  optype := EVP_PKEY_OP_KEYGEN;
  cmd := EVP_PKEY_CTRL_RSA_KEYGEN_BITS;
  p1 := bits;
  p2 := nil;

  if RESTDW_OPENSSL_VERSION_NUMBER < OPENSSL_VER_1101 then
    keytype := EVP_PKEY_RSA
  else
    keytype := -1;

  Result := EVP_PKEY_CTX_ctrl(pctx, keytype, optype, cmd, p1, p2);
end;

function EVP_PKEY_CTX_set_ec_paramgen_curve_nid(pctx : PEVP_PKEY_CTX; nid : Integer) : integer;
var
  keytype: Integer;
  optype: Integer;
  cmd: Integer;
  p1: Integer;
  p2: Pointer;
begin
  keytype := EVP_PKEY_EC;
  optype := EVP_PKEY_OP_PARAMGEN OR EVP_PKEY_OP_KEYGEN;
  cmd := EVP_PKEY_CTRL_EC_PARAMGEN_CURVE_NID;
  p1 := nid;
  p2 := nil;

  Result := EVP_PKEY_CTX_ctrl(pctx, keytype, optype, cmd, p1, p2);
end;

function EVPPKEYCBcallFunc(pctx: PEVP_PKEY_CTX): Integer; cdecl;
var
  Arg: Pointer;
  CertTools: TRESTDWSelfSigned;
begin
  Result := 1;
  if NOT Assigned(pctx) then
    Exit;
  try
    Arg := EVP_PKEY_CTX_get_app_data(pctx);
    if not Assigned (Arg) then
      Exit;
    CertTools := TRESTDWSelfSigned(Arg);
    with CertTools do begin
      { good idea to call ProcessMessages in event so program remains responsive!!! }
      if Assigned(CertTools.OnKeyProgress) then
        CertTools.OnKeyProgress(CertTools);
    end;
  except

  end;
end;

function EVP_PKEY_dup(PKey: PEVP_PKEY): PEVP_PKEY;
begin
  Result := nil;
  if PKey <> nil then begin
    EVP_PKEY_up_ref(PKey);
    Result := PKey;
  end;
end;


end.

