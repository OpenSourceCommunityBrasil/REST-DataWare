unit uRESTDWMemMath;

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

{$IFDEF FPC}
 {$MODE Delphi}
 {$ASMMode Intel}
{$ENDIF}

interface
uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils, System.Classes,
  {$ELSE ~HAS_UNITSCOPE}
  SysUtils, Classes,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase;

{ CRC-16 }
type
  TCrc16Table = array [0..255] of Word;
var
  //  CRC16Polynom = $1021;
  Crc16DefaultTable: TCrc16Table = (
    $0000, $1021, $2042, $3063, $4084, $50A5, $60C6, $70E7,
    $8108, $9129, $A14A, $B16B, $C18C, $D1AD, $E1CE, $F1EF,
    $1231, $0210, $3273, $2252, $52B5, $4294, $72F7, $62D6,
    $9339, $8318, $B37B, $A35A, $D3BD, $C39C, $F3FF, $E3DE,
    $2462, $3443, $0420, $1401, $64E6, $74C7, $44A4, $5485,
    $A56A, $B54B, $8528, $9509, $E5EE, $F5CF, $C5AC, $D58D,
    $3653, $2672, $1611, $0630, $76D7, $66F6, $5695, $46B4,
    $B75B, $A77A, $9719, $8738, $F7DF, $E7FE, $D79D, $C7BC,
    $48C4, $58E5, $6886, $78A7, $0840, $1861, $2802, $3823,
    $C9CC, $D9ED, $E98E, $F9AF, $8948, $9969, $A90A, $B92B,
    $5AF5, $4AD4, $7AB7, $6A96, $1A71, $0A50, $3A33, $2A12,
    $DBFD, $CBDC, $FBBF, $EB9E, $9B79, $8B58, $BB3B, $AB1A,
    $6CA6, $7C87, $4CE4, $5CC5, $2C22, $3C03, $0C60, $1C41,
    $EDAE, $FD8F, $CDEC, $DDCD, $AD2A, $BD0B, $8D68, $9D49,
    $7E97, $6EB6, $5ED5, $4EF4, $3E13, $2E32, $1E51, $0E70,
    $FF9F, $EFBE, $DFDD, $CFFC, $BF1B, $AF3A, $9F59, $8F78,
    $9188, $81A9, $B1CA, $A1EB, $D10C, $C12D, $F14E, $E16F,
    $1080, $00A1, $30C2, $20E3, $5004, $4025, $7046, $6067,
    $83B9, $9398, $A3FB, $B3DA, $C33D, $D31C, $E37F, $F35E,
    $02B1, $1290, $22F3, $32D2, $4235, $5214, $6277, $7256,
    $B5EA, $A5CB, $95A8, $8589, $F56E, $E54F, $D52C, $C50D,
    $34E2, $24C3, $14A0, $0481, $7466, $6447, $5424, $4405,
    $A7DB, $B7FA, $8799, $97B8, $E75F, $F77E, $C71D, $D73C,
    $26D3, $36F2, $0691, $16B0, $6657, $7676, $4615, $5634,
    $D94C, $C96D, $F90E, $E92F, $99C8, $89E9, $B98A, $A9AB,
    $5844, $4865, $7806, $6827, $18C0, $08E1, $3882, $28A3,
    $CB7D, $DB5C, $EB3F, $FB1E, $8BF9, $9BD8, $ABBB, $BB9A,
    $4A75, $5A54, $6A37, $7A16, $0AF1, $1AD0, $2AB3, $3A92,
    $FD2E, $ED0F, $DD6C, $CD4D, $BDAA, $AD8B, $9DE8, $8DC9,
    $7C26, $6C07, $5C64, $4C45, $3CA2, $2C83, $1CE0, $0CC1,
    $EF1F, $FF3E, $CF5D, $DF7C, $AF9B, $BFBA, $8FD9, $9FF8,
    $6E17, $7E36, $4E55, $5E74, $2E93, $3EB2, $0ED1, $1EF0
   );
  Crc16DefaultStart: Cardinal = $FFFF;
const
  Crc16PolynomCCITT = $1021;
  Crc16PolynomIBM   = $8005;
  Crc16Bits = 16;
  Crc16Bytes = 2;
  Crc16HighBit = $8000;
  NotCrc16HighBit = $7FFF;
// for backward compatibility (default polynom = CCITT = $1021)
function Crc16_P(X: PJclByteArray; N: Integer; Crc: Word = 0): Word; overload;
function Crc16(const X: array of Byte; N: Integer; Crc: Word = 0): Word; overload;
function Crc16_A(const X: array of Byte; Crc: Word = 0): Word; overload;
function CheckCrc16_P(X: PJclByteArray; N: Integer; Crc: Word): Integer; overload;
function CheckCrc16(var X: array of Byte; N: Integer; Crc: Word): Integer; overload;
function CheckCrc16_A(var X: array of Byte; Crc: Word): Integer; overload;
// change the default polynom
procedure InitCrc16(Polynom, Start: Word); overload;
// arbitrary polynom
function Crc16_P(const Crc16Table: TCrc16Table; X: PJclByteArray; N: Integer; Crc: Word = 0): Word; overload;
function Crc16(const Crc16Table: TCrc16Table; const X: array of Byte; N: Integer; Crc: Word = 0): Word; overload;
function Crc16_A(const Crc16Table: TCrc16Table; const X: array of Byte; Crc: Word = 0): Word; overload;
function CheckCrc16_P(const Crc16Table: TCrc16Table; X: PJclByteArray; N: Integer; Crc: Word): Integer; overload;
function CheckCrc16(const Crc16Table: TCrc16Table; var X: array of Byte; N: Integer; Crc: Word): Integer; overload;
function CheckCrc16_A(const Crc16Table: TCrc16Table; var X: array of Byte; Crc: Word): Integer; overload;
// initialize a table
procedure InitCrc16(Polynom, Start: Word; out Crc16Table: TCrc16Table); overload;
{ CRC-32 }
type
  TCrc32Table = array [0..255] of Cardinal;
var
  //  CRC32Polynom = $04C11DB7;
  Crc32DefaultTable: TCrc32Table = (
    $00000000, $04C11DB7, $09823B6E, $0D4326D9, $130476DC, $17C56B6B, $1A864DB2, $1E475005,
    $2608EDB8, $22C9F00F, $2F8AD6D6, $2B4BCB61, $350C9B64, $31CD86D3, $3C8EA00A, $384FBDBD,
    $4C11DB70, $48D0C6C7, $4593E01E, $4152FDA9, $5F15ADAC, $5BD4B01B, $569796C2, $52568B75,
    $6A1936C8, $6ED82B7F, $639B0DA6, $675A1011, $791D4014, $7DDC5DA3, $709F7B7A, $745E66CD,
    $9823B6E0, $9CE2AB57, $91A18D8E, $95609039, $8B27C03C, $8FE6DD8B, $82A5FB52, $8664E6E5,
    $BE2B5B58, $BAEA46EF, $B7A96036, $B3687D81, $AD2F2D84, $A9EE3033, $A4AD16EA, $A06C0B5D,
    $D4326D90, $D0F37027, $DDB056FE, $D9714B49, $C7361B4C, $C3F706FB, $CEB42022, $CA753D95,
    $F23A8028, $F6FB9D9F, $FBB8BB46, $FF79A6F1, $E13EF6F4, $E5FFEB43, $E8BCCD9A, $EC7DD02D,
    $34867077, $30476DC0, $3D044B19, $39C556AE, $278206AB, $23431B1C, $2E003DC5, $2AC12072,
    $128E9DCF, $164F8078, $1B0CA6A1, $1FCDBB16, $018AEB13, $054BF6A4, $0808D07D, $0CC9CDCA,
    $7897AB07, $7C56B6B0, $71159069, $75D48DDE, $6B93DDDB, $6F52C06C, $6211E6B5, $66D0FB02,
    $5E9F46BF, $5A5E5B08, $571D7DD1, $53DC6066, $4D9B3063, $495A2DD4, $44190B0D, $40D816BA,
    $ACA5C697, $A864DB20, $A527FDF9, $A1E6E04E, $BFA1B04B, $BB60ADFC, $B6238B25, $B2E29692,
    $8AAD2B2F, $8E6C3698, $832F1041, $87EE0DF6, $99A95DF3, $9D684044, $902B669D, $94EA7B2A,
    $E0B41DE7, $E4750050, $E9362689, $EDF73B3E, $F3B06B3B, $F771768C, $FA325055, $FEF34DE2,
    $C6BCF05F, $C27DEDE8, $CF3ECB31, $CBFFD686, $D5B88683, $D1799B34, $DC3ABDED, $D8FBA05A,
    $690CE0EE, $6DCDFD59, $608EDB80, $644FC637, $7A089632, $7EC98B85, $738AAD5C, $774BB0EB,
    $4F040D56, $4BC510E1, $46863638, $42472B8F, $5C007B8A, $58C1663D, $558240E4, $51435D53,
    $251D3B9E, $21DC2629, $2C9F00F0, $285E1D47, $36194D42, $32D850F5, $3F9B762C, $3B5A6B9B,
    $0315D626, $07D4CB91, $0A97ED48, $0E56F0FF, $1011A0FA, $14D0BD4D, $19939B94, $1D528623,
    $F12F560E, $F5EE4BB9, $F8AD6D60, $FC6C70D7, $E22B20D2, $E6EA3D65, $EBA91BBC, $EF68060B,
    $D727BBB6, $D3E6A601, $DEA580D8, $DA649D6F, $C423CD6A, $C0E2D0DD, $CDA1F604, $C960EBB3,
    $BD3E8D7E, $B9FF90C9, $B4BCB610, $B07DABA7, $AE3AFBA2, $AAFBE615, $A7B8C0CC, $A379DD7B,
    $9B3660C6, $9FF77D71, $92B45BA8, $9675461F, $8832161A, $8CF30BAD, $81B02D74, $857130C3,
    $5D8A9099, $594B8D2E, $5408ABF7, $50C9B640, $4E8EE645, $4A4FFBF2, $470CDD2B, $43CDC09C,
    $7B827D21, $7F436096, $7200464F, $76C15BF8, $68860BFD, $6C47164A, $61043093, $65C52D24,
    $119B4BE9, $155A565E, $18197087, $1CD86D30, $029F3D35, $065E2082, $0B1D065B, $0FDC1BEC,
    $3793A651, $3352BBE6, $3E119D3F, $3AD08088, $2497D08D, $2056CD3A, $2D15EBE3, $29D4F654,
    $C5A92679, $C1683BCE, $CC2B1D17, $C8EA00A0, $D6AD50A5, $D26C4D12, $DF2F6BCB, $DBEE767C,
    $E3A1CBC1, $E760D676, $EA23F0AF, $EEE2ED18, $F0A5BD1D, $F464A0AA, $F9278673, $FDE69BC4,
    $89B8FD09, $8D79E0BE, $803AC667, $84FBDBD0, $9ABC8BD5, $9E7D9662, $933EB0BB, $97FFAD0C,
    $AFB010B1, $AB710D06, $A6322BDF, $A2F33668, $BCB4666D, $B8757BDA, $B5365D03, $B1F740B4
    );
  Crc32DefaultStart: Cardinal = $FFFFFFFF;
const
  Crc32PolynomIEEE       = $04C11DB7;
  Crc32PolynomCastagnoli = $1EDC6F41;
  Crc32Koopman           = $741B8CD7;
  Crc32Bits = 32;
  Crc32Bytes = 4;
  Crc32HighBit = $80000000;
  NotCrc32HighBit = $7FFFFFFF;
// for backward compatibility (default polynom = IEEE = $04C11DB7)
function Crc32_P(X: PJclByteArray; N: Integer; Crc: Cardinal = 0): Cardinal; overload;
function Crc32(const X: array of Byte; N: Integer; Crc: Cardinal = 0): Cardinal; overload;
function Crc32_A(const X: array of Byte; Crc: Cardinal = 0): Cardinal; overload;
function CheckCrc32_P(X: PJclByteArray; N: Integer; Crc: Cardinal): Integer; overload;
function CheckCrc32(var X: array of Byte; N: Integer; Crc: Cardinal): Integer; overload;
function CheckCrc32_A(var X: array of Byte; Crc: Cardinal): Integer; overload;
// change the default polynom
procedure InitCrc32(Polynom, Start: Cardinal); overload;
// arbitrary polynom
function Crc32_P(const Crc32Table: TCrc32Table; X: PJclByteArray; N: Integer; Crc: Cardinal = 0): Cardinal; overload;
function Crc32(const Crc32Table: TCrc32Table; const X: array of Byte; N: Integer; Crc: Cardinal = 0): Cardinal; overload;
function Crc32_A(const Crc32Table: TCrc32Table; const X: array of Byte; Crc: Cardinal = 0): Cardinal; overload;
function CheckCrc32_P(const Crc32Table: TCrc32Table; X: PJclByteArray; N: Integer; Crc: Cardinal): Integer; overload;
function CheckCrc32(const Crc32Table: TCrc32Table; var X: array of Byte; N: Integer; Crc: Cardinal): Integer; overload;
function CheckCrc32_A(const Crc32Table: TCrc32Table; var X: array of Byte; Crc: Cardinal): Integer; overload;
// initialize a table
procedure InitCrc32(Polynom, Start: Cardinal; out Crc32Table: TCrc32Table); overload;

implementation
{$IFDEF DELPHI64_TEMPORARY}
  {$DEFINE USE_MATH_UNIT}
{$ENDIF DELPHI64_TEMPORARY}
uses
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  {$IFNDEF FPC}
  Winapi.Windows,
  {$ENDIF ~FPC}
  {$ENDIF MSWINDOWS}
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  {$IFNDEF FPC}
  Windows,
  {$ENDIF ~FPC}
  {$ENDIF MSWINDOWS}
  {$ENDIF ~HAS_UNITSCOPE}
  {$IFDEF USE_MATH_UNIT}
  System.Math,
  {$ENDIF USE_MATH_UNIT}
  uRESTDWMemResources;

// CRC 16
function Crc16Corr(const Crc16Table: TCrc16Table; Crc: Word; N: Integer): Integer;
var
  I: Integer;
//  CrcX : Cardinal;
begin
  // calculate Syndrome
//  CrcX := CrC;
  for I := 1 to Crc16Bytes do
    // a 16 bit value shr 8 is a Byte, explictit type conversion to Byte adds an ASM instruction
    Crc := Crc16Table[Crc shr (CRC16Bits - 8)] xor Word(Crc shl 8);
  I := -1;
  repeat
    Inc(I);
    if (Crc and 1) <> 0 then
      Crc := ((Crc xor Crc16Table[1]) shr 1) or Crc16HighBit
//      Crc16Table[1] = Crc16Polynom
    else
      Crc := (Crc shr 1) and NotCrc16HighBit;
  until (Crc = Crc16HighBit) or (I = (N + Crc16Bytes) * 8);
  if Crc <> Crc16HighBit then
    Result := -1000 // not correctable
  else
    // I = No. of single faulty bit
    // (high bit first,
    // starting from lowest with CRC bits)
    Result := I - Crc16Bits;
    // Result <  0 faulty CRC-bit
    // Result >= 0 No. of faulty data bit
end;
function Crc16_P(const Crc16Table: TCrc16Table; X: PJclByteArray; N: Integer; Crc: Word): Word;
var
  I: Integer;
begin
  Result := Crc16DefaultStart;
  for I := 0 to N - 1 do // The CRC Bytes are located at the end of the information
    // a 16 bit value shr 8 is a Byte, explictit type conversion to Byte adds an ASM instruction
    Result := Crc16Table[Result shr (CRC16Bits - 8)] xor Word((Result shl 8)) xor X[I];
  for I := 0 to Crc16Bytes - 1 do
  begin
    // a 16 bit value shr 8 is a Byte, explictit type conversion to Byte adds an ASM instruction
    Result := Crc16Table[Result shr (CRC16Bits-8)] xor Word((Result shl 8)) xor (Crc shr (CRC16Bits-8));
    Crc := Word(Crc shl 8);
  end;
end;
function Crc16_P(X: PJclByteArray; N: Integer; Crc: Word): Word;
begin
  Result := Crc16_P(Crc16DefaultTable, X, N, Crc);
end;
function CheckCrc16_P(const Crc16Table: TCrc16Table; X: PJclByteArray; N: Integer; Crc: Word): Integer;
// checks and corrects a single bit in up to 2^15-16 Bit -> 2^12-2 = 4094 Byte
var
  I, J: Integer;
  C: Byte;
begin
  Crc := Crc16_P(Crc16Table, X, N, Crc);
  if Crc = 0 then
    Result := 0 // No CRC-error
  else
  begin
    J := Crc16Corr(Crc16Table, Crc, N);
    if J < -(Crc16Bytes * 8 + 1) then
      Result := -1 // non-correctable error (more than one wrong bit)
    else
    begin
      if J < 0 then
        Result := 1 // one faulty Bit in CRC itself
      else
      begin // Bit J is faulty
        I := J and 7; // I <= 7 (faulty Bit in Byte)
        C := 1 shl I; // C <= 128
        I := J shr 3; // I: Index of faulty Byte
        X[N - 1 - I] := X[N - 1 - I] xor C; // correct faulty bit
        Result := 1; // Correctable error
      end;
    end;
  end;
end;
function CheckCrc16_P(X: PJclByteArray; N: Integer; Crc: Word): Integer;
begin
  Result := CheckCrc16_P(Crc16DefaultTable, X, N, Crc);
end;
function Crc16(const Crc16Table: TCrc16Table; const X: array of Byte; N: Integer; Crc: Word): Word;
begin
  Result := Crc16_P(Crc16Table, @X, N, Crc);
end;
function Crc16(const X: array of Byte; N: Integer; Crc: Word): Word;
begin
  Result := Crc16_P(Crc16DefaultTable, @X, N, Crc);
end;
function CheckCrc16(const Crc16Table: TCrc16Table; var X: array of Byte; N: Integer; Crc: Word): Integer;
begin
  Result := CheckCRC16_P(Crc16Table, @X, N, CRC);
end;
function CheckCrc16(var X: array of Byte; N: Integer; Crc: Word): Integer;
begin
  Result := CheckCRC16_P(Crc16DefaultTable, @X, N, CRC);
end;
function Crc16_A(const Crc16Table: TCrc16Table; const X: array of Byte; Crc: Word): Word;
begin
  Result := Crc16_P(Crc16Table, @X, Length(X), Crc);
end;
function Crc16_A(const X: array of Byte; Crc: Word): Word;
begin
  Result := Crc16_P(Crc16DefaultTable, @X, Length(X), Crc);
end;
function CheckCrc16_A(const Crc16Table: TCrc16Table; var X: array of Byte; Crc: Word): Integer;
begin
  Result := CheckCrc16_P(Crc16Table, @X, Length(X), Crc);
end;
function CheckCrc16_A(var X: array of Byte; Crc: Word): Integer;
begin
  Result := CheckCrc16_P(Crc16DefaultTable, @X, Length(X), Crc);
end;
// The CRC Table can be generated like this:
// const Crc16Start0 = 0;  !!
function Crc16_Bitwise(const X: array of Byte; N: Integer; Crc: Word; Polynom: Word): Word;
const
  Crc16Start0 = 0;   //Generating the table
var
  I, J: Integer;
  Sr, SrHighBit: Word;
  B: Byte;
begin
   Sr := Crc16Start0;
   SrHighBit := 0;
   for I := 0 to N - 1 + Crc16Bytes do
   begin
      if I >= N then
      begin
         B := Crc shr (Crc16Bits - 8);
         Crc := Crc shl 8;
      end
      else
        B := X[I];
      for J := 1 to 8 do
      begin
        if SrHighBit <> 0 then
          Sr := Sr xor Polynom;
        SrHighBit := Sr and Crc16HighBit;
        Sr := (Word (Sr shl 1)) or ((B shr 7) and 1);
        B := Byte(B shl 1);
      end;
   end;
   if SrHighBit <> 0 then
      Sr := Sr xor Polynom;
   Result := Sr;
end;
procedure InitCrc16(Polynom, Start: Word; out Crc16Table: TCrc16Table);
var
  X: array [0..0] of Byte;
  I: Integer;
begin
   for I := 0 to 255 do
   begin
     X[0] := I;
     Crc16Table[I] := Crc16_Bitwise(X, 1, 0, Polynom); { only with crcstart=0 !!!!}
   end;
   Crc16DefaultStart := Start;
end;
procedure InitCrc16(Polynom, Start: Word);
begin
  InitCrc16(Polynom, Start, Crc16DefaultTable);
end;
// CRC 32
function Crc32Corr(const Crc32Table: TCrc32Table; Crc: Cardinal; N: Integer): Integer;
var
  I: Integer;
begin
  // calculate Syndrome
  for I := 1 to Crc32Bytes do
    Crc := Crc32Table[Crc shr (CRC32Bits - 8)] xor (Crc shl 8);
  I := -1;
  repeat
    Inc(I);
    if (Crc and 1) <> 0 then
      Crc := ((Crc xor Crc32Table[1]) shr 1) or Crc32HighBit
//      Crc32Table[1] = Crc32Polynom
    else
      Crc := (Crc shr 1) and NotCrc32HighBit;
  until (Crc = Crc32HighBit) or (I = (N + Crc32Bytes) * 8);
  if Crc <> Crc32HighBit then
    Result := -1000 // not correctable
  else
    // I = No. of single faulty bit
    // (high bit first,
    // starting from lowest with CRC bits)
    Result := I - Crc32Bits;
    // Result <  0 faulty CRC-bit
    // Result >= 0 No. of faulty data bit
end;
function Crc32_P(const Crc32Table: TCrc32Table; X: PJclByteArray; N: Integer; Crc: Cardinal): Cardinal;
var
  I: Integer;
begin
  Result := Crc32DefaultStart;
  for I := 0 to N - 1 do // The CRC Bytes are located at the end of the information
    // a 32 bit value shr 24 is a Byte, explictit type conversion to Byte adds an ASM instruction
    Result := Crc32Table[Result shr (CRC32Bits-8)] xor (Result shl 8) xor X[I];
  for I := 0 to Crc32Bytes - 1 do
  begin
    // a 32 bit value shr 24 is a Byte, explictit type conversion to Byte adds an ASM instruction
    Result := Crc32Table[Result shr (CRC32Bits-8)] xor (Result shl 8) xor (Crc shr (CRC32Bits-8));
    Crc := Crc shl 8;
  end;
end;
function Crc32_P(X: PJclByteArray; N: Integer; Crc: Cardinal): Cardinal;
begin
  Result := Crc32_P(Crc32DefaultTable, X, N, Crc);
end;
function CheckCrc32_P(const Crc32Table: TCrc32Table; X: PJclByteArray; N: Integer; Crc: Cardinal): Integer;
// checks and corrects a single bit in up to 2^31-32 Bit -> 2^28-4 = 268435452 Byte
var
  I, J: Integer;
  C: Byte;
begin
  Crc := Crc32_P(Crc32Table, X, N, Crc);
  if Crc = 0 then
    Result := 0 // No CRC-error
  else
  begin
    J := Crc32Corr(Crc32Table, Crc, N);
    if J < -(Crc32Bytes * 8 + 1) then
      Result := -1 // non-correctable error (more than one wrong bit)
    else
    begin
      if J < 0 then
        Result := 1 // one faulty Bit in CRC itself
      else
      begin // Bit J is faulty
        I := J and 7; // I <= 7 (faulty Bit in Byte)
        C := 1 shl I; // C <= 128
        I := J shr 3; // I: Index of faulty Byte
        X[N - 1 - I] := X[N - 1 - I] xor C; // correct faulty bit
        Result := 1; // Correctable error
      end;
    end;
  end;
end;
function CheckCrc32_P(X: PJclByteArray; N: Integer; Crc: Cardinal): Integer;
begin
  Result := CheckCrc32_P(Crc32DefaultTable, X, N, Crc);
end;
function Crc32(const Crc32Table: TCrc32Table; const X: array of Byte; N: Integer; Crc: Cardinal): Cardinal;
begin
  Result := Crc32_P(Crc32Table, @X, N, Crc);
end;
function Crc32(const X: array of Byte; N: Integer; Crc: Cardinal): Cardinal;
begin
  Result := Crc32_P(Crc32DefaultTable, @X, N, Crc);
end;
function CheckCrc32(const Crc32Table: TCrc32Table; var X: array of Byte; N: Integer; Crc: Cardinal): Integer;
begin
  Result := CheckCRC32_P(Crc32Table, @X, N, CRC);
end;
function CheckCrc32(var X: array of Byte; N: Integer; Crc: Cardinal): Integer;
begin
  Result := CheckCRC32_P(Crc32DefaultTable, @X, N, CRC);
end;
function Crc32_A(const Crc32Table: TCrc32Table; const X: array of Byte; Crc: Cardinal): Cardinal;
begin
  Result := Crc32_P(Crc32Table, @X, Length(X), Crc);
end;
function Crc32_A(const X: array of Byte; Crc: Cardinal): Cardinal;
begin
  Result := Crc32_P(Crc32DefaultTable, @X, Length(X), Crc);
end;
function CheckCrc32_A(const Crc32Table: TCrc32Table; var X: array of Byte; Crc: Cardinal): Integer;
begin
  Result := CheckCrc32_P(Crc32Table, @X, Length(X), Crc);
end;
function CheckCrc32_A(var X: array of Byte; Crc: Cardinal): Integer;
begin
  Result := CheckCrc32_P(Crc32DefaultTable, @X, Length(X), Crc);
end;
// The CRC Table can be generated like this:
// const Crc32Start0 = 0;  !!
function Crc32_Bitwise(const X: array of Byte; N: Integer; Crc: Cardinal; Polynom: Cardinal) : Cardinal;
const
  Crc32Start0 = 0;   //Generating the table
var
  I, J: Integer;
  Sr, SrHighBit: Cardinal;
  B: Byte;
begin
  Sr := Crc32Start0;
  SrHighBit := 0;
  for I := 0 to N - 1 + Crc32Bytes do
  begin
    if I >= N then
    begin
      B := Crc shr (Crc32Bits - 8);
      Crc := Crc shl 8;
    end
    else
       B := X[I];
    for J := 1 to 8 do
    begin
       if SrHighBit <> 0 then
         Sr := Sr xor Polynom;
       SrHighBit := Sr and Crc32HighBit;
       Sr := (Sr shl 1) or ((B shr 7) and 1);
       B := Byte(B shl 1);
    end
  end;
  if SrHighBit <> 0 then
    Sr := Sr xor Polynom;
  Result := Sr;
end;
procedure InitCrc32(Polynom, Start: Cardinal; out Crc32Table: TCrc32Table);
var
  X: array [0..0] of Byte;
  I: Integer;
begin
   for I := 0 to 255 do
   begin
     X[0] := I;
     Crc32Table[I] := Crc32_Bitwise(X, 1, 0, Polynom);
   end;
   Crc32DefaultStart := Start;
end;
procedure InitCrc32(Polynom, Start: Cardinal);
begin
  InitCrc32(Polynom, Start, Crc32DefaultTable);
end;

end.
