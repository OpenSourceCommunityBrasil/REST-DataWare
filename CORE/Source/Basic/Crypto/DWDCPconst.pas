{******************************************************************************}
{* DWDCPcrypt v2.0 written by David Barton (crypto@cityinthesky.co.uk) **********}
{******************************************************************************}
{* Constants for use with DWDCPcrypt ********************************************}
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
unit DWDCPconst;

interface

{******************************************************************************}
const
  { Component registration }
  DWDCPcipherpage     = 'DWDCPciphers';
  DWDCPhashpage       = 'DWDCPhashes';

  { ID values }
  DWDCP_rc2           =  1;
  DWDCP_sha1          =  2;
  DWDCP_rc5           =  3;
  DWDCP_rc6           =  4;
  DWDCP_blowfish      =  5;
  DWDCP_twofish       =  6;
  DWDCP_cast128       =  7;
  DWDCP_gost          =  8;
  DWDCP_rijndael      =  9;
  DWDCP_ripemd160     = 10;
  DWDCP_misty1        = 11;
  DWDCP_idea          = 12;
  DWDCP_mars          = 13;
  DWDCP_haval         = 14;
  DWDCP_cast256       = 15;
  DWDCP_md5           = 16;
  DWDCP_md4           = 17;
  DWDCP_tiger         = 18;
  DWDCP_rc4           = 19;
  DWDCP_ice           = 20;
  DWDCP_thinice       = 21;
  DWDCP_ice2          = 22;
  DWDCP_des           = 23;
  DWDCP_3des          = 24;
  DWDCP_tea           = 25;
  DWDCP_serpent       = 26;
  DWDCP_ripemd128     = 27;
  DWDCP_sha256        = 28;
  DWDCP_sha384        = 29;
  DWDCP_sha512        = 30;


{******************************************************************************}
{******************************************************************************}
implementation

end.

