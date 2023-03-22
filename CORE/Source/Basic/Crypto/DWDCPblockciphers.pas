{******************************************************************************}
{* DWDCPcrypt v2.1 written by David Barton (crypto@cityinthesky.co.uk) **********}
{******************************************************************************}
{* Block cipher component definitions *****************************************}
{******************************************************************************}
{* Copyright (c) 1999-2002 David Barton                                       *}
{* Permission is hereby granted, free of charge, to any person obtaining a    *}
{* copy of this software and associated documentation files (the "Software"), *}
{* to deal in the Software without restriction, including without limitation  *}
{* the rights to use, copy, modify, merge, publish, distribute, sublicense,   *}
{* and/or sell copies of the Software, and to permit persons to whom the      *}
{* Software is furnished to do so, subject to the following conditions:       *}
{*                                                                            *}
{* The above copyright notice and this permission notice shall be included in *}
{* all copies or substantial portions of the Software.                        *}
{*                                                                            *}
{* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR *}
{* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   *}
{* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    *}
{* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *}
{* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    *}
{* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER        *}
{* DEALINGS IN THE SOFTWARE.                                                  *}
{******************************************************************************}
unit DWDCPblockciphers;

interface
uses
  Classes, Sysutils, DWDCPtypes, DWDCPcrypt2;

{******************************************************************************}
    { Base type definition for 64 bit block ciphers }
type
  TDWDCP_blockcipher64= class(TDWDCP_blockcipher)
  private
    IV, CV: array[0..7] of byte;

    procedure IncCounter;
  public
    class function GetBlockSize: integer; override;
      { Get the block size of the cipher (in bits) }

    procedure Reset; override;
      { Reset any stored chaining information }
    procedure Burn; override;
      { Clear all stored key information and chaining information }
    procedure SetIV(const Value); override;
      { Sets the IV to Value and performs a reset }
    procedure GetIV(var Value); override;
      { Returns the current chaining information, not the actual IV }
    procedure Init(const Key; Size: longword; InitVector: pointer); override;
      { Do key setup based on the data in Key, size is in bits }

    procedure EncryptCFB8bit(const Indata; var Outdata; Size: longword); override;
      { Encrypt size bytes of data using the CFB (8 bit) method of encryption }
    procedure DecryptCFB8bit(const Indata; var Outdata; Size: longword); override;
      { Decrypt size bytes of data using the CFB (8 bit) method of decryption }
  end;

{******************************************************************************}
    { Base type definition for 128 bit block ciphers }
type
  TDWDCP_blockcipher128= class(TDWDCP_blockcipher)
  private
    IV, CV: array[0..15] of byte;

    procedure IncCounter;
  public
    class function GetBlockSize: integer; override;
      { Get the block size of the cipher (in bits) }

    procedure Reset; override;
      { Reset any stored chaining information }
    procedure Burn; override;
      { Clear all stored key information and chaining information }
    procedure SetIV(const Value); override;
      { Sets the IV to Value and performs a reset }
    procedure GetIV(var Value); override;
      { Returns the current chaining information, not the actual IV }
    procedure Init(const Key; Size: longword; InitVector: pointer); override;
      { Do key setup based on the data in Key, size is in bits }

    procedure EncryptCFB8bit(const Indata; var Outdata; Size: longword); override;
      { Encrypt size bytes of data using the CFB (8 bit) method of encryption }
    procedure DecryptCFB8bit(const Indata; var Outdata; Size: longword); override;
      { Decrypt size bytes of data using the CFB (8 bit) method of decryption }
  end;

implementation

{$IFDEF SUPPORTS_UNICODE_STRING}
  {$POINTERMATH ON}
{$ENDIF}

{** TDWDCP_blockcipher64 ********************************************************}

procedure TDWDCP_blockcipher64.IncCounter;
var
  i: integer;
begin
  Inc(CV[7]);
  i:= 7;
  while (i> 0) and (CV[i] = 0) do
  begin
    Inc(CV[i-1]);
    Dec(i);
  end;
end;

class function TDWDCP_blockcipher64.GetBlockSize: integer;
begin
  Result:= 64;
end;

procedure TDWDCP_blockcipher64.Init(const Key; Size: longword; InitVector: pointer);
begin
  inherited Init(Key,Size,InitVector);
  InitKey(Key,Size);
  if InitVector= nil then
  begin
    FillChar(IV,8,{$IFDEF DWDCP1COMPAT}$FF{$ELSE}0{$ENDIF});
    EncryptECB(IV,IV);
    Reset;
  end
  else
  begin
    Move(InitVector^,IV,8);
    Reset;
  end;
end;

procedure TDWDCP_blockcipher64.SetIV(const Value);
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  Move(Value,IV,8);
  Reset;
end;

procedure TDWDCP_blockcipher64.GetIV(var Value);
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  Move(CV,Value,8);
end;

procedure TDWDCP_blockcipher64.Reset;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized')
  else
    Move(IV,CV,8);
end;

procedure TDWDCP_blockcipher64.Burn;
begin
  FillChar(IV,8,$FF);
  FillChar(CV,8,$FF);
  inherited Burn;
end;

procedure TDWDCP_blockcipher64.EncryptCFB8bit(const Indata; var Outdata; Size: longword);
var
  i: longword;
  p1, p2: Pbyte;
  Temp: array[0..7] of byte;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  p1:= @Indata;
  p2:= @Outdata;
  FillChar(Temp, SizeOf(Temp), 0);
  for i:= 1 to Size do
  begin
    EncryptECB(CV,Temp);
    p2^:= p1^ xor Temp[0];
    Move(CV[1],CV[0],8-1);
    CV[7]:= p2^;
    Inc(p1);
    Inc(p2);
  end;
end;

procedure TDWDCP_blockcipher64.DecryptCFB8bit(const Indata; var Outdata; Size: longword);
var
  i: longword;
  p1, p2: Pbyte;
  TempByte: byte;
  Temp: array[0..7] of byte;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  p1:= @Indata;
  p2:= @Outdata;
  FillChar(Temp, SizeOf(Temp), 0);
  for i:= 1 to Size do
  begin
    TempByte:= p1^;
    EncryptECB(CV,Temp);
    p2^:= p1^ xor Temp[0];
    Move(CV[1],CV[0],8-1);
    CV[7]:= TempByte;
    Inc(p1);
    Inc(p2);
  end;
end;

procedure TDWDCP_blockcipher128.IncCounter;
var
  i: integer;
begin
  Inc(CV[15]);
  i:= 15;
  while (i> 0) and (CV[i] = 0) do
  begin
    Inc(CV[i-1]);
    Dec(i);
  end;
end;

class function TDWDCP_blockcipher128.GetBlockSize: integer;
begin
  Result:= 128;
end;

procedure TDWDCP_blockcipher128.Init(const Key; Size: longword; InitVector: pointer);
begin
  inherited Init(Key,Size,InitVector);
  InitKey(Key,Size);
  if InitVector= nil then
  begin
    FillChar(IV,16,{$IFDEF DWDCP1COMPAT}$FF{$ELSE}0{$ENDIF});
    EncryptECB(IV,IV);
    Reset;
  end
  else
  begin
    Move(InitVector^,IV,16);
    Reset;
  end;
end;

procedure TDWDCP_blockcipher128.SetIV(const Value);
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  Move(Value,IV,16);
  Reset;
end;

procedure TDWDCP_blockcipher128.GetIV(var Value);
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  Move(CV,Value,16);
end;

procedure TDWDCP_blockcipher128.Reset;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized')
  else
    Move(IV,CV,16);
end;

procedure TDWDCP_blockcipher128.Burn;
begin
  FillChar(IV,16,$FF);
  FillChar(CV,16,$FF);
  inherited Burn;
end;

procedure TDWDCP_blockcipher128.EncryptCFB8bit(const Indata; var Outdata; Size: longword);
var
  i: longword;
  p1, p2: Pbyte;
  Temp: array[0..15] of byte;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  p1:= @Indata;
  p2:= @Outdata;
  FillChar(Temp, SizeOf(Temp), 0);
  for i:= 1 to Size do
  begin
    EncryptECB(CV,Temp);
    p2^:= p1^ xor Temp[0];
    Move(CV[1],CV[0],15);
    CV[15]:= p2^;
    Inc(p1);
    Inc(p2);
  end;
end;

procedure TDWDCP_blockcipher128.DecryptCFB8bit(const Indata; var Outdata; Size: longword);
var
  i: longword;
  p1, p2: Pbyte;
  TempByte: byte;
  Temp: array[0..15] of byte;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  p1:= @Indata;
  p2:= @Outdata;
  FillChar(Temp, SizeOf(Temp), 0);
  for i:= 1 to Size do
  begin
    TempByte:= p1^;
    EncryptECB(CV,Temp);
    p2^:= p1^ xor Temp[0];
    Move(CV[1],CV[0],15);
    CV[15]:= TempByte;
    Inc(p1);
    Inc(p2);
  end;
end;

end.
