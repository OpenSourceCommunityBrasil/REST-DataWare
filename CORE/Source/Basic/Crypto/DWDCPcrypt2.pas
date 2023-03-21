unit DWDCPcrypt2;

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
  Classes, Sysutils, DWDCPtypes, DWDCPbase64;


  { ****************************************************************** }
  { The base class from which all hash algorithms are to be derived }

type
  EDWDCP_hash = class(Exception);

  TDWDCP_hash = class(TComponent)
  protected
    fInitialized: boolean;
    { Whether or not the algorithm has been initialized }

    procedure DeadInt(Value: integer);
    { Knudge to display vars in the object inspector }
    procedure DeadStr(Value: string);
    { Knudge to display vars in the object inspector }

  private
    function _GetId: integer;
    function _GetAlgorithm: string;
    function _GetHashSize: integer;

  public
    property Initialized: boolean read fInitialized;

    class function GetId: integer; virtual;
    { Get the algorithm id }
    class function GetAlgorithm: string; virtual;
    { Get the algorithm name }
    class function GetHashSize: integer; virtual;
    { Get the size of the digest produced - in bits }
    class function SelfTest: boolean; virtual;
    { Tests the implementation with several test vectors }

    procedure Init; virtual;
    { Initialize the hash algorithm }
    procedure Final(var Digest); virtual;
    { Create the final digest and clear the stored information.
      The size of the Digest var must be at least equal to the hash size }
    procedure Burn; virtual;
    { Clear any stored information with out creating the final digest }

    procedure Update(const Buffer; Size: longword); virtual;
    { Update the hash buffer with Size bytes of data from Buffer }
    procedure UpdateStream(Stream: TStream; Size: longword);
    { Update the hash buffer with Size bytes of data from the stream }
    procedure UpdateStr(const Str: DWDCPRawString); {$IFNDEF NOTRAWSUPPORT}overload;{$ENDIF}

    { Update the hash buffer with the string }
    {$IFNDEF NOTRAWSUPPORT}
    procedure UpdateStr(const Str: DWDCPUnicodeString); overload;
      { Update the hash buffer with the string }
    {$ENDIF}
    destructor Destroy; override;

  published
    property Id: integer read _GetId write DeadInt;
    property Algorithm: string read _GetAlgorithm write DeadStr;
    property HashSize: integer read _GetHashSize write DeadInt;
  end;

  TDWDCP_hashclass = class of TDWDCP_hash;

  { ****************************************************************************** }
  { The base class from which all encryption components will be derived. }
  { Stream ciphers will be derived directly from this class where as }
  { Block ciphers will have a further foundation class TDWDCP_blockcipher. }

type
  EDWDCP_cipher = class(Exception);

  TDWDCP_cipher = class(TComponent)
  protected
    fInitialized: boolean; { Whether or not the key setup has been done yet }

    procedure DeadInt(Value: integer);
    { Knudge to display vars in the object inspector }
    procedure DeadStr(Value: string);
    { Knudge to display vars in the object inspector }

  private
    function _GetId: integer;
    function _GetAlgorithm: string;
    function _GetMaxKeySize: integer;

  public
    property Initialized: boolean read fInitialized;

    class function GetId: integer; virtual;
    { Get the algorithm id }
    class function GetAlgorithm: string; virtual;
    { Get the algorithm name }
    class function GetMaxKeySize: integer; virtual;
    { Get the maximum key size (in bits) }
    class function SelfTest: boolean; virtual;
    { Tests the implementation with several test vectors }

    procedure Init(const Key; Size: longword; InitVector: pointer); virtual;
    { Do key setup based on the data in Key, size is in bits }
    procedure InitStr(const Key: DWDCPRawString; HashType: TDWDCP_hashclass); {$IFNDEF NOTRAWSUPPORT}overload;{$ENDIF}

    { Do key setup based on a hash of the key string }

{$IFNDEF NOTRAWSUPPORT}
    procedure InitStr(const Key: DWDCPUnicodeString;
      HashType: TDWDCP_hashclass); overload;
    { Do key setup based on a hash of the key string }
{$ENDIF}
    procedure Burn; virtual;
    { Clear all stored key information }
    procedure Reset; virtual;
    { Reset any stored chaining information }
    procedure Encrypt(const Indata; var Outdata; Size: longword); virtual;
    { Encrypt size bytes of data and place in Outdata }
    procedure Decrypt(const Indata; var Outdata; Size: longword); virtual;
    { Decrypt size bytes of data and place in Outdata }
    function EncryptStream(InStream, OutStream: TStream; Size: longword): longword;
    { Encrypt size bytes of data from InStream and place in OutStream }
    function DecryptStream(InStream, OutStream: TStream; Size: longword): longword;
    { Decrypt size bytes of data from InStream and place in OutStream }
    function EncryptString(const Str: DWDCPRawString): DWDCPRawString; {$IFNDEF NOTRAWSUPPORT}overload;{$ENDIF} virtual;
    { Encrypt a string and return Base64 encoded }
    function DecryptString(const Str: DWDCPRawString): DWDCPRawString; {$IFNDEF NOTRAWSUPPORT}overload;{$ENDIF} virtual;
    { Decrypt a Base64 encoded string }

{$IFNDEF NOTRAWSUPPORT}
    function EncryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString; overload; virtual;
      { Encrypt a Unicode string and return Base64 encoded }
    function DecryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString; overload; virtual;
      { Decrypt a Base64 encoded Unicode string }
{$ENDIF}
    function PartialEncryptStream(AStream: TMemoryStream; Size: longword)
      : longword;
    { Partially Encrypt up to 16K bytes of data in AStream }
    function PartialDecryptStream(AStream: TMemoryStream; Size: longword)
      : longword;
    { Partially Decrypt up to 16K bytes of data in AStream }

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Id: integer read _GetId write DeadInt;
    property Algorithm: string read _GetAlgorithm write DeadStr;
    property MaxKeySize: integer read _GetMaxKeySize write DeadInt;
  end;

  TDWDCP_cipherclass = class of TDWDCP_cipher;

  { ****************************************************************************** }
  { The base class from which all block ciphers are to be derived, this }
  { extra class takes care of the different block encryption modes. }

type
  TDWDCP_ciphermode = (cmCBC, cmCFB8bit, cmCFBblock, cmOFB, cmCTR);
  // cmCFB8bit is equal to DWDCPcrypt v1.xx's CFB mode
  EDWDCP_blockcipher = class(EDWDCP_cipher);

  TDWDCP_blockcipher = class(TDWDCP_cipher)
  protected
    fCipherMode: TDWDCP_ciphermode; { The cipher mode the encrypt method uses }

    procedure InitKey(const Key; Size: longword); virtual;

  private
    function _GetBlockSize: integer;

  public
    class function GetBlockSize: integer; virtual;
    { Get the block size of the cipher (in bits) }

    procedure SetIV(const Value); virtual;
    { Sets the IV to Value and performs a reset }
    procedure GetIV(var Value); virtual;
    { Returns the current chaining information, not the actual IV }

    procedure Encrypt(const Indata; var Outdata; Size: longword); override;
    { Encrypt size bytes of data and place in Outdata using CipherMode }
    procedure Decrypt(const Indata; var Outdata; Size: longword); override;
    { Decrypt size bytes of data and place in Outdata using CipherMode }
    function EncryptString(const Str: DWDCPRawString): DWDCPRawString; overload; override;
    { Encrypt a string and return Base64 encoded }
    function DecryptString(const Str: DWDCPRawString): DWDCPRawString; overload; override;
    { Decrypt a Base64 encoded string }
{$IFNDEF NOTRAWSUPPORT}
    function EncryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString; overload; override;
      { Encrypt a Unicode string and return Base64 encoded }
    function DecryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString; overload; override;
      { Decrypt a Base64 encoded Unicode string }
{$ENDIF}

    procedure EncryptECB(const Indata; var Outdata); virtual;
    { Encrypt a block of data using the ECB method of encryption }
    procedure DecryptECB(const Indata; var Outdata); virtual;
    { Decrypt a block of data using the ECB method of decryption }
    procedure EncryptCBC(const Indata; var Outdata; Size: longword); virtual;
    { Encrypt size bytes of data using the CBC method of encryption }
    procedure DecryptCBC(const Indata; var Outdata; Size: longword); virtual;
    { Decrypt size bytes of data using the CBC method of decryption }
    procedure EncryptCFB8bit(const Indata; var Outdata; Size: longword); virtual;
    { Encrypt size bytes of data using the CFB (8 bit) method of encryption }
    procedure DecryptCFB8bit(const Indata; var Outdata; Size: longword); virtual;
    { Decrypt size bytes of data using the CFB (8 bit) method of decryption }
    procedure EncryptCFBblock(const Indata; var Outdata; Size: longword); virtual;
    { Encrypt size bytes of data using the CFB (block) method of encryption }
    procedure DecryptCFBblock(const Indata; var Outdata; Size: longword); virtual;
    { Decrypt size bytes of data using the CFB (block) method of decryption }
    procedure EncryptOFB(const Indata; var Outdata; Size: longword); virtual;
    { Encrypt size bytes of data using the OFB method of encryption }
    procedure DecryptOFB(const Indata; var Outdata; Size: longword); virtual;
    { Decrypt size bytes of data using the OFB method of decryption }
    procedure EncryptCTR(const Indata; var Outdata; Size: longword); virtual;
    { Encrypt size bytes of data using the CTR method of encryption }
    procedure DecryptCTR(const Indata; var Outdata; Size: longword); virtual;
    { Decrypt size bytes of data using the CTR method of decryption }

    constructor Create(AOwner: TComponent); override;

  published
    property BlockSize: integer read _GetBlockSize write DeadInt;
    property CipherMode: TDWDCP_ciphermode read fCipherMode write fCipherMode default cmCBC;
  end;

  TDWDCP_blockcipherclass = class of TDWDCP_blockcipher;

  { ****************************************************************************** }
  { Helper functions }

//procedure XorBlock(var InData1, InData2; Size: longword);

implementation

// {$IFDEF RESTDWWINDOWS}
//uses Windows;
// {$Q-}{$R-}
//{$ENDIF}

const
{$IFDEF NEXTGEN}
  STRINGBASE = 0;
{$ELSE}
  STRINGBASE = 1;
{$ENDIF}

{ ** TDWDCP_hash ***************************************************************** }

procedure TDWDCP_hash.DeadInt(Value: integer);
begin
end;

procedure TDWDCP_hash.DeadStr(Value: string);
begin
end;

function TDWDCP_hash._GetId: integer;
begin
  Result := GetId;
end;

function TDWDCP_hash._GetAlgorithm: string;
begin
  Result := GetAlgorithm;
end;

function TDWDCP_hash._GetHashSize: integer;
begin
  Result := GetHashSize;
end;

class function TDWDCP_hash.GetId: integer;
begin
  Result := -1;
end;

class function TDWDCP_hash.GetAlgorithm: string;
begin
  Result := '';
end;

class function TDWDCP_hash.GetHashSize: integer;
begin
  Result := -1;
end;

class function TDWDCP_hash.SelfTest: boolean;
begin
  Result := false;
end;

procedure TDWDCP_hash.Init;
begin
end;

procedure TDWDCP_hash.Final(var Digest);
begin
end;

procedure TDWDCP_hash.Burn;
begin
end;

procedure TDWDCP_hash.Update(const Buffer; Size: longword);
begin
end;

procedure TDWDCP_hash.UpdateStream(Stream: TStream; Size: longword);
var
  Buffer: array [0..8191] of byte;
  i, read: integer;
begin
  FillChar(Buffer, SizeOf(Buffer), 0);
  for i := 1 to (Size div SizeOf(Buffer)) do
  begin
    read := Stream.Read(Buffer, SizeOf(Buffer));
    Update(Buffer, read);
  end;
  if (Size mod SizeOf(Buffer)) <> 0 then
  begin
    read := Stream.Read(Buffer, Size mod SizeOf(Buffer));
    Update(Buffer, read);
  end;
end;

procedure TDWDCP_hash.UpdateStr(const Str: DWDCPRawString);
begin
  Update(Str[STRINGBASE], Length(Str));
end;

{$IFNDEF NOTRAWSUPPORT}
procedure TDWDCP_hash.UpdateStr(const Str: DWDCPUnicodeString);
begin
  Update(Str[STRINGBASE], Length(Str) * SizeOf(Str[STRINGBASE]));
end; { DecryptString }
{$ENDIF}

destructor TDWDCP_hash.Destroy;
begin
  if fInitialized then
    Burn;
  inherited Destroy;
end;

{ ** TDWDCP_cipher *************************************************************** }

procedure TDWDCP_cipher.DeadInt(Value: integer);
begin
end;

procedure TDWDCP_cipher.DeadStr(Value: string);
begin
end;

function TDWDCP_cipher._GetId: integer;
begin
  Result := GetId;
end;

function TDWDCP_cipher._GetAlgorithm: string;
begin
  Result := GetAlgorithm;
end;

function TDWDCP_cipher._GetMaxKeySize: integer;
begin
  Result := GetMaxKeySize;
end;

class function TDWDCP_cipher.GetId: integer;
begin
  Result := -1;
end;

class function TDWDCP_cipher.GetAlgorithm: string;
begin
  Result := '';
end;

class function TDWDCP_cipher.GetMaxKeySize: integer;
begin
  Result := -1;
end;

class function TDWDCP_cipher.SelfTest: boolean;
begin
  Result := false;
end;

procedure TDWDCP_cipher.Init(const Key; Size: longword; InitVector: pointer);
begin
  if fInitialized then
    Burn;
  if (Size <= 0) or ((Size and 3) <> 0) or (Size > longword(GetMaxKeySize)) then
    raise EDWDCP_cipher.Create('Invalid key size')
  else
    fInitialized := true;
end;

procedure TDWDCP_cipher.InitStr(const Key: DWDCPRawString; HashType: TDWDCP_hashclass);
var
  Hash: TDWDCP_hash;
  Digest: pointer;
begin
  if fInitialized then
    Burn;
  try
    GetMem(Digest, HashType.GetHashSize div 8);
    Hash := HashType.Create(Self);
    Hash.Init;
    Hash.UpdateStr(Key);
    Hash.Final(Digest^);
    Hash.Free;
    if MaxKeySize < HashType.GetHashSize then
    begin
      Init(Digest^, MaxKeySize, nil);
    end
    else
    begin
      Init(Digest^, HashType.GetHashSize, nil);
    end;
    FillChar(Digest^, HashType.GetHashSize div 8, $FF);
    FreeMem(Digest);
  except
    raise EDWDCP_cipher.Create('Unable to allocate sufficient memory for hash digest');
  end;
end;

{$IFNDEF NOTRAWSUPPORT}
procedure TDWDCP_cipher.InitStr(const Key: DWDCPUnicodeString; HashType: TDWDCP_hashclass);
var
  Hash: TDWDCP_hash;
  Digest: pointer;
begin
  if fInitialized then
    Burn;
  try
    GetMem(Digest, HashType.GetHashSize div 8);
    Hash := HashType.Create(Self);
    Hash.Init;
    Hash.UpdateStr(Key);
    Hash.Final(Digest^);
    Hash.Free;
    if MaxKeySize < HashType.GetHashSize then
      Init(Digest^, MaxKeySize, nil)
    else
      Init(Digest^, HashType.GetHashSize, nil);
    FillChar(Digest^, HashType.GetHashSize div 8, $FF);
    FreeMem(Digest);
  except
    raise EDWDCP_cipher.Create('Unable to allocate sufficient memory for hash digest');
  end;
end;
{$ENDIF}

procedure TDWDCP_cipher.Burn;
begin
  fInitialized := false;
end;

procedure TDWDCP_cipher.Reset;
begin
end;

procedure TDWDCP_cipher.Encrypt(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_cipher.Decrypt(const Indata; var Outdata; Size: longword);
begin
end;

const
  EncryptBufSize = 1024 * 1024 * 8; // 8 Megs
  EncryptLimit = (16 * 1024); // 16K operation size

function TDWDCP_cipher.EncryptStream(InStream, OutStream: TStream; Size: longword): longword;
var
  Buffer: TBytes;
  i, Read: longword;
  Range: longword;
  Remainder: longword;
begin
  Result := 0;

  if Size < EncryptBufSize then
    SetLength(Buffer, Size)
  else
    SetLength(Buffer, EncryptBufSize);

  Range := Size div longword(Length(Buffer));
  for i := 1 to Range do
  begin
    Read := InStream.Read(Buffer[0], Length(Buffer));
    Inc(Result, Read);
    Encrypt(Buffer[0], Buffer[0], Read);
    OutStream.Write(Buffer[0], Read);
  end;

  Remainder := Size mod longword(Length(Buffer));
  if Remainder <> 0 then
  begin
    Read := InStream.Read(Buffer[0], Remainder);
    Inc(Result, Read);
    Encrypt(Buffer[0], Buffer[0], Read);
    OutStream.Write(Buffer[0], Read);
  end;
end;

function TDWDCP_cipher.DecryptStream(InStream, OutStream: TStream; Size: longword): longword;
var
  Buffer: TBytes;
  i, Read: longword;
  Range: longword;
  Remainder: longword;
begin
  Result := 0;

  if Size < EncryptBufSize then
    SetLength(Buffer, Size)
  else
    SetLength(Buffer, EncryptBufSize);

  Range := Size div longword(Length(Buffer));
  for i := 1 to Range do
  begin
    Read := InStream.Read(Buffer[0], Length(Buffer));
    Inc(Result, Read);
    Decrypt(Buffer[0], Buffer[0], Read);
    OutStream.Write(Buffer[0], Read);
  end;

  Remainder := Size mod longword(Length(Buffer));
  if Remainder <> 0 then
  begin
    Read := InStream.Read(Buffer[0], Remainder);
    Inc(Result, Read);
    Decrypt(Buffer[0], Buffer[0], Read);
    OutStream.Write(Buffer[0], Read);
  end;
end;

function TDWDCP_cipher.EncryptString(const Str: DWDCPRawString): DWDCPRawString;
begin
  SetLength(Result, Length(Str));
  Encrypt(Str[STRINGBASE], Result[STRINGBASE], Length(Str));
  Result := Base64EncodeStr(Result);
end;

function TDWDCP_cipher.DecryptString(const Str: DWDCPRawString): DWDCPRawString;
begin
  Result := Base64DecodeStr(Str);
  Decrypt(Result[STRINGBASE], Result[STRINGBASE], Length(Result));
end;

{$IFNDEF NOTRAWSUPPORT}
function TDWDCP_cipher.EncryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString;
begin
  SetLength(Result,Length(Str));
  Encrypt(Str[STRINGBASE],Result[STRINGBASE],Length(Str)*SizeOf(Str[STRINGBASE]));
  Result := Base64EncodeStr(Result);
end;

function TDWDCP_cipher.DecryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString;
begin
  Result := Base64DecodeStr(Str);
  Decrypt(Result[STRINGBASE], Result[STRINGBASE], Length(Result) * SizeOf(Result[STRINGBASE]));
end;
{$ENDIF}

constructor TDWDCP_cipher.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Burn;
end;

destructor TDWDCP_cipher.Destroy;
begin
  if fInitialized then
    Burn;
  inherited Destroy;
end;

{ ** TDWDCP_blockcipher ********************************************************** }

procedure TDWDCP_blockcipher.InitKey(const Key; Size: longword);
begin
end;

function TDWDCP_blockcipher._GetBlockSize: integer;
begin
  Result := GetBlockSize;
end;

class function TDWDCP_blockcipher.GetBlockSize: integer;
begin
  Result := -1;
end;

procedure TDWDCP_blockcipher.SetIV(const Value);
begin
end;

procedure TDWDCP_blockcipher.GetIV(var Value);
begin
end;

procedure TDWDCP_blockcipher.Encrypt(const Indata; var Outdata; Size: longword);
begin
  case fCipherMode of
    cmCBC:
      EncryptCBC(Indata, Outdata, Size);
    cmCFB8bit:
      EncryptCFB8bit(Indata, Outdata, Size);
    cmCFBblock:
      EncryptCFBblock(Indata, Outdata, Size);
    cmOFB:
      EncryptOFB(Indata, Outdata, Size);
    cmCTR:
      EncryptCTR(Indata, Outdata, Size);
  end;
end;

function TDWDCP_blockcipher.EncryptString(const Str: DWDCPRawString): DWDCPRawString;
begin
  SetLength(Result, Length(Str));
  EncryptCFB8bit(Str[STRINGBASE], Result[STRINGBASE], Length(Str));
  Result := Base64EncodeStr(Result);
end;

function TDWDCP_blockcipher.DecryptString(const Str: DWDCPRawString): DWDCPRawString;
begin
  Result := Base64DecodeStr(Str);
  DecryptCFB8bit(Result[STRINGBASE], Result[STRINGBASE], Length(Result));
end;

{$IFNDEF NOTRAWSUPPORT}
function TDWDCP_blockcipher.EncryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString;
begin
  SetLength(Result,Length(Str));
  EncryptCFB8bit(Str[STRINGBASE],Result[STRINGBASE],Length(Str)*SizeOf(Str[STRINGBASE]));
  Result := Base64EncodeStr(Result);
end;

function TDWDCP_blockcipher.DecryptString(const Str: DWDCPUnicodeString): DWDCPUnicodeString;
begin
  Result := Base64DecodeStr(Str);
  DecryptCFB8bit(Result[STRINGBASE],Result[STRINGBASE],Length(Result)*SizeOf(Result[STRINGBASE]));
end;
{$ENDIF}

procedure TDWDCP_blockcipher.Decrypt(const Indata; var Outdata; Size: longword);
begin
  case fCipherMode of
    cmCBC:
      DecryptCBC(Indata, Outdata, Size);
    cmCFB8bit:
      DecryptCFB8bit(Indata, Outdata, Size);
    cmCFBblock:
      DecryptCFBblock(Indata, Outdata, Size);
    cmOFB:
      DecryptOFB(Indata, Outdata, Size);
    cmCTR:
      DecryptCTR(Indata, Outdata, Size);
  end;
end;

procedure TDWDCP_blockcipher.EncryptECB(const Indata; var Outdata);
begin
end;

procedure TDWDCP_blockcipher.DecryptECB(const Indata; var Outdata);
begin
end;

procedure TDWDCP_blockcipher.EncryptCBC(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.DecryptCBC(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.EncryptCFB8bit(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.DecryptCFB8bit(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.EncryptCFBblock(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.DecryptCFBblock(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.EncryptOFB(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.DecryptOFB(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.EncryptCTR(const Indata; var Outdata; Size: longword);
begin
end;

procedure TDWDCP_blockcipher.DecryptCTR(const Indata; var Outdata; Size: longword);
begin
end;

constructor TDWDCP_blockcipher.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fCipherMode := cmCBC;
end;

// Version 2.1 : Partial Stream Read capability.
function TDWDCP_cipher.PartialDecryptStream(AStream: TMemoryStream;
  Size: longword): longword;
var
  Buffer: PLongInt;
begin
  if Size > EncryptLimit then
    Size := EncryptLimit;

  Result := Size;
  Buffer := PLongInt(AStream.Memory);
  // only process the limited size:
  Decrypt(Buffer^, Buffer^, Size);
end;

// Version 2.1 : Partial Stream Read capability.
function TDWDCP_cipher.PartialEncryptStream(AStream: TMemoryStream;
  Size: longword): longword;
var
  Buffer: PLongInt;
begin
  if Size > EncryptLimit then
    Size := EncryptLimit;

  Result := Size;
  Buffer := PLongInt(AStream.Memory);
  // only process the limited size:
  Encrypt(Buffer^, Buffer^, Size);
end;

end.

