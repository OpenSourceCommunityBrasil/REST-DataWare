{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15752: IdSoapOpenXmlUCL.pas 
{
{   Rev 1.1    18/3/2003 11:03:20  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:35:16  GGrieve
}
{
This unit is an slightly modified version of UCL (UnicodeConv.pas).
For further discussion, see IdSoapDefines.inc.
The following changes have been made to this unit:
* changed the name of this unit

IndySOAP would like to that Dieter Kohler for permission to
include a renamed copy of OpenXML with IndySOAP. This file is
covered by the UCL licence, not the IndySOAP licence.

}

{
Version History:
  18-Mar 2003   Grahame Grieve                  Remove IDSOAP_USE_RENAMED_OPENXML
  17-Jul 2002   Grahame Grieve                  Remove registration of TCSMIB
  16-Jul 2002   Grahame Grieve                  New OpenXML version
  09-Jul 2002   Grahame Grieve                  Updated version of OpenXML & Unicode Library
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
   7-Mar 2002   Grahame Grieve                  First included in IndySoap
}

{*------- End of Indy Modifications except as noted above --------------------*}

unit IdSoapOpenXmlUCL;

{$I IdSoapDefines.inc}

// UnicodeConv 2.0.0
// Unicode Converter Library 2.0.0
// Delphi 3/4/5/6 and Kylix Implementation
//
// Copyright (c) 2002 by Dieter Köhler
// ("http://www.philo.de/xml/")
//
// Definitions:
// - "Package" refers to the collection of files distributed by
//   the Copyright Holder, and derivatives of that collection of
//   files created through textual modification.
// - "Standard Version" refers to such a Package if it has not
//   been modified, or has been modified in accordance with the
//   wishes of the Copyright Holder.
// - "Copyright Holder" is whoever is name in the copyright or
//   copyrights for the package.
// - "You" is you, if you're thinking about copying or distributing
//   this Package.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Package"), to deal in the Package without restriction,
// including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the
// Package, and to permit persons to whom the Package is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Package.
//
// You may modify your copy of this Package in any way, provided
// that you insert a prominent notice in each changed file stating
// how and when you changed a file, and provided that you do at
// least one of the following:
//
// a) allow the Copyright Holder to include your modifications in
// the Standard Version of the Package.
//
// b) use the modified Package only within your corporation or
// organization.
//
// c) rename any non standard executables, units, and classes so
// the names do not conflict with standard executables, units, and
// classes, and provide a separate manual page that clearly documents
// how it differs from the standard version.
//
// d) make other distribution arrangements with the Copyright Holder.
//
// The name of the Copyright Holder may not be used to endorse or
// promote products derived from this Package without specific prior
// written permission.
//
// THE PACKAGE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// PACKAGE OR THE USE OR OTHER DEALINGS IN THE PACKAGE.

interface

uses
  SysUtils, Classes;

type
  TdomEncodingType = (etUnknown,etUTF8,etUTF16BE,etUTF16LE,etLatin1,
                      etLatin2,etLatin3,etLatin4,etCyrillic,etArabic,
                      etGreek,etHebrew,etLatin5,etLatin6,etLatin7,
                      etLatin8,etLatin9,etKOI8R,etcp10000_MacRoman,
                      etWindows1250,etWindows1251,etWindows1252);

  EConversionStream = class(EStreamError);

  TConversionStream = class(TStream)
  private
    FTarget: TStream;
    FConvertCount: longint;
    FConvertBufP: pointer;
    FConvertBufSize: longint;
  protected
    function convertReadBuffer(const buffer; count: longint): longint; virtual;
    function convertWriteBuffer(const buffer; count: longint): longint; virtual;
    procedure setConvertBufSize(newSize: longint); virtual;
  public
    constructor create(target: TStream);
    destructor destroy; override;
    function read(var buffer; count: longint): longint; override;
    function write(const buffer; count: longint): longint; override;
    function seek(offset: longint; origin: word): longint; override;
    procedure freeConvertBuffer;
    property target: TStream read FTarget;
    property convertBufP: pointer read FConvertBufP;
    property convertCount: longint read FConvertCount;
    property convertBufSize: longint read FConvertBufSize;
  end;

  TUTF16BEToUTF8Stream = class(TConversionStream)
  private
    FExpandLF: boolean;
  protected
    function convertWriteBuffer(const buffer; count: longint): longint; override;
  public
    property expandLF: boolean read FExpandLF write FExpandLF;
  end;

function StrToEncoding(const S: String): TdomEncodingType;

function SingleByteEncodingToUTF16Char(const P: Char; const Encoding: TdomEncodingType): WideChar;

function Iso8859_1ToUTF16Char(const P: Char): WideChar;
function Iso8859_2ToUTF16Char(const P: Char): WideChar;
function Iso8859_3ToUTF16Char(const P: Char): WideChar;
function Iso8859_4ToUTF16Char(const P: Char): WideChar;
function Iso8859_5ToUTF16Char(const P: Char): WideChar;
function Iso8859_6ToUTF16Char(const P: Char): WideChar;
function Iso8859_7ToUTF16Char(const P: Char): WideChar;
function Iso8859_8ToUTF16Char(const P: Char): WideChar;
function Iso8859_9ToUTF16Char(const P: Char): WideChar;
function Iso8859_10ToUTF16Char(const P: Char): WideChar;
function Iso8859_13ToUTF16Char(const P: Char): WideChar;
function Iso8859_14ToUTF16Char(const P: Char): WideChar;
function Iso8859_15ToUTF16Char(const P: Char): WideChar;
function KOI8_RToUTF16Char(const P: Char): WideChar;
function cp10000_MacRomanToUTF16Char(const P: Char): WideChar;
function cp1250ToUTF16Char(const P: Char): WideChar;
function cp1251ToUTF16Char(const P: Char): WideChar;
function cp1252ToUTF16Char(const P: Char): WideChar;
function Iso8859_1ToUTF16Str(const S: string): wideString;
function Iso8859_2ToUTF16Str(const S: string): wideString;
function Iso8859_3ToUTF16Str(const S: string): wideString;
function Iso8859_4ToUTF16Str(const S: string): wideString;
function Iso8859_5ToUTF16Str(const S: string): wideString;
function Iso8859_6ToUTF16Str(const S: string): wideString;
function Iso8859_7ToUTF16Str(const S: string): wideString;
function Iso8859_8ToUTF16Str(const S: string): wideString;
function Iso8859_9ToUTF16Str(const S: string): wideString;
function Iso8859_10ToUTF16Str(const S: string): wideString;
function Iso8859_13ToUTF16Str(const S: string): wideString;
function Iso8859_14ToUTF16Str(const S: string): wideString;
function Iso8859_15ToUTF16Str(const S: string): wideString;
function KOI8_RToUTF16Str(const S: string): wideString;
function cp10000_MacRomanToUTF16Str(const S: string): wideString;
function cp1250ToUTF16Str(const S: string): wideString;
function cp1251ToUTF16Str(const S: string): wideString;
function cp1252ToUTF16Str(const S: string): wideString;
function UTF8ToUTF16BEStr(const S: string): wideString;
function UTF16BEToUTF8Str(const ws: wideString;
                          const expandLF: boolean): string;

function UTF16To7BitASCIIChar(const P: wideChar): char;
function UTF16ToIso8859_1Char(const P: wideChar): char;
function UTF16To7BitASCIIStr(const S: wideString): string;
function UTF16ToIso8859_1Str(const S: wideString): string;

function UTF16HighSurrogate(const value: integer): WideChar;
function UTF16LowSurrogate(const value: integer): WideChar;
function UTF16SurrogateToInt(const highSurrogate, lowSurrogate: WideChar): integer;
function IsUTF16HighSurrogate(const S: WideChar): boolean;
function IsUTF16LowSurrogate(const S: WideChar): boolean;

type
  ECSMIBException = Exception;

  TCSMIBChangingEvent = procedure (Sender: TObject;
                                   NewEnum: integer;
                                   var AllowChange: Boolean) of object;

  TCSMIB = class (TComponent)
  protected
    FEnum: integer;
    FIgnoreInvalidEnum: boolean;
    FOnChanging: TCSMIBChangingEvent;
    FOnChange: TNotifyEvent;
    procedure DoChange(Sender: TObject); virtual;
    procedure DoChanging(Sender: TObject;
                                 NewEnum: integer;
                                 var AllowChange: Boolean); virtual;
    function GetPrfMIMEName: string; virtual;
    function GetAlias(i: integer): string; virtual;
    function GetAliasCount: integer; virtual;
    procedure SetEnum(const Value: integer); virtual;
    procedure SetOnChange(const Value: TNotifyEvent); virtual;
    procedure SetOnChanging(const Value: TCSMIBChangingEvent); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    function IsValidEnum(const Value: integer): boolean; virtual;
    function SetToAlias(const S: string): boolean; virtual;
    property Alias[i: integer]: string read GetAlias;
    property AliasCount: integer read GetAliasCount;
    property PreferredMIMEName: string read GetPrfMIMEName;
  published
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property OnChanging: TCSMIBChangingEvent read FOnChanging write SetOnChanging;
    property Enum: integer read FEnum write SetEnum;
    property IgnoreInvalidEnum: boolean read FIgnoreInvalidEnum write FIgnoreInvalidEnum;
  end;


implementation

resourcestring
  SOddSizeInvalid = 'Odd size not valid for WideString';
  STargetNil      = 'Must have a target stream';


// +++++++++++++++++++++++++ TConversionStream +++++++++++++++++++++++++
//                     - Provided by Karl Waclawek -
// This is an input/output stream for other streams.
// Purpose: transform data as they are written to or read from a target
//          stream.
constructor TConversionStream.create(Target: TStream);
begin
  if Target = nil then raise EConversionStream.create(STargetNil);
  inherited create;
  FTarget := Target;
end;

destructor TConversionStream.destroy;
begin
  FreeMem(FConvertBufP);
  inherited destroy;
end;

function TConversionStream.Seek(Offset: longint; Origin: Word): longint;
begin
  Result := 0;  // Seek makes no sense here
end;

function TConversionStream.ConvertReadBuffer(const Buffer; Count: longint): longint;
// Performs the actual conversion of the data in Buffer (read buffer);
// the result of the conversion must be written to ConvertBufB }
begin
  Result := 0; //do nothing, override in descendants
end;

function TConversionStream.ConvertWriteBuffer(const Buffer; Count: longint): longint;
// Performs the actual conversion of the data in Buffer (write buffer);
// the result of the conversion must be written to ConvertBufB }
begin
  Result := 0; //do nothing, override in descendants
end;

function TConversionStream.Read(var Buffer; Count: longint): longint;
// Reads Count bytes from target stream into Buffer;
// converts those bytes and stores the result in ConvertBufP;
// ConvertCount indicates the amount of bytes converted.
begin
  Result := Target.Read(Buffer, Count);
  FConvertCount := ConvertReadBuffer(Buffer, Result);
end;

function TConversionStream.Write(const Buffer; Count: longint): longint;
// Converts Count bytes from Buffer into ConvertBufP;
// ConvertCount indicates the amount of bytes converted;
// if not all converted bytes could be written to the target stream,
// then this returns the negative of the number of bytes actually written.
begin
  Result := Count;
  FConvertCount := ConvertWriteBuffer(Buffer, Result);
  Count := Target.Write(FConvertBufP^, FConvertCount);
  //if not all converted data could be written, return the negative
  //count of the data actually written. This avoids having Result
  //being the same as Count by coincidence
  if Count <> FConvertCount then Result := -Count;
end;

procedure TConversionStream.FreeConvertBuffer;
begin
  ReallocMem(FConvertBufP, 0);
  FConvertBufSize := 0;
end;

procedure TConversionStream.SetConvertBufSize(NewSize: Integer);
begin
  ReallocMem(FConvertBufP, NewSize);
  FConvertBufSize := NewSize;
end;


// ++++++++++++++++++++++++++ TUTF16BEToUTF8Stream +++++++++++++++++++++++
function TUTF16BEToUTF8Stream.ConvertWriteBuffer(const Buffer;
                                                       Count: Integer): longint;
// Converts an UTF-16BE stream into an UTF-8 encoded stream
// (and expands LF to CR+LF if its protected expandLF property
// is 'true').
//  - This function was provided by Ernst van der Pols -
//  - expandLF parameter added by Dieter Köhler -
//  - converted for stream processing by Karl Waclawek -
type
  TWideCharBuf = array[0..(MaxInt shr 1) - 1] of WideChar;
var
  InIndx, OutIndx: longint;
  Wc: WideChar;
  InBuf: TWideCharBuf absolute Buffer;

  procedure IncBufSize(BufSize: longint);
    var
      Delta: longint;
    begin
    Inc(BufSize);
    Delta := BufSize shr 2;
    if Delta < 8 then Delta := 8;
    BufSize := ((BufSize + Delta) shr 2) shl 2; //make it multiple of 4
    setConvertBufSize(BufSize);
    end;

  procedure UCS4CodeToUTF8String(Code: longint);
    const
      MaxCode: array[0..5] of longint = ($7F,$7FF,$FFFF,$1FFFFF,$3FFFFFF,$7FFFFFFF);
      FirstByte: array[0..5] of Byte = (0,$C0,$E0,$F0,$F8,$FC);
    var
      Mo, Indx, StartIndx: longint;
    begin
    Mo := 0;			// get number of bytes
    while ((Code > MaxCode[Mo]) and (Mo < 5)) do Inc(Mo);
    StartIndx := OutIndx;
    OutIndx := StartIndx + Mo;
    if OutIndx >= ConvertBufSize then IncBufSize(OutIndx);
    for Indx := OutIndx downto StartIndx + 1 do	// fill bytes from rear end
      begin
      PChar(FConvertBufP)[Indx] := Char($80 or (Code and $3F));
      Code := Code shr 6;
      end;
    PChar(FConvertBufP)[StartIndx] := Char(FirstByte[Mo] or Code); // fill first byte
    end;

begin
  Result := 0;
  if Count = 0 then Exit;
  if Odd(Count) then raise EConversionStream.create(SOddSizeInvalid);
  Count := Count shr 1;  //for initial size, assume all low ASCII chars
  if Count > ConvertBufSize then setConvertBufSize(Count);
  OutIndx := -1;	// keep track of end position
  InIndx := 0;
  if InBuf[0] = #$feff then Inc(InIndx);  // Test for BOM

  while InIndx < Count do begin
    Wc := InBuf[InIndx];
    case Word(Wc) of
      $0020..$007F,$0009,$000D:	// plain ASCII
        begin
        Inc(OutIndx);
        if OutIndx >= ConvertBufSize then IncBufSize(OutIndx);
        PChar(FConvertBufP)[OutIndx]:= Char(Wc);
        end;
      $000A:	// LF --> CR+LF
        if ExpandLF then
          begin
          Inc(OutIndx, 2);
          if OutIndx >= ConvertBufSize then IncBufSize(OutIndx);
          PChar(FConvertBufP)[OutIndx - 1] := Chr(13);
          PChar(FConvertBufP)[OutIndx] := Chr(10);
          end
        else
          begin
          Inc(OutIndx);
          if OutIndx >= ConvertBufSize then IncBufSize(OutIndx);
          PChar(FConvertBufP)[OutIndx] := Chr(10);
          end;
      $D800..$DBFF:	// high surrogate
        begin
        Inc(InIndx);
        if (InIndx < (Count - 1)) and (Word(InBuf[InIndx]) >= $DC00)
          and (Word(InBuf[InIndx]) <= $DFFF) then
          begin
          Inc(OutIndx);
          UCS4CodeToUTF8String(Utf16SurrogateToInt(Wc, InBuf[InIndx]));
          end
        else
          raise EConvertError.CreateFmt(
            'High surrogate %4.4X without low surrogate.',[Word(Wc)]);
        end;
      $DC00..$DFFF:	// low surrogate
        begin
        Inc(InIndx);
        if (InIndx < (Count - 1)) and (Word(InBuf[InIndx]) >= $D800)
          and (Word(InBuf[InIndx]) <= $DBFF) then
          begin
          Inc(OutIndx);
          UCS4CodeToUTF8String(Utf16SurrogateToInt(InBuf[InIndx], Wc));
          end
        else
          raise EConvertError.CreateFmt(
            'Low surrogate %4.4X without high surrogate.',[Word(Wc)]);
        end;
      $0080..$D7FF,$E000..$FFFD:
        begin
        Inc(OutIndx);
        UCS4CodeToUTF8String(Word(Wc));
        end;
    end; {case ...}
    Inc(InIndx);
  end; { while ...}
  Result := OutIndx + 1;
end;


// +++++++++++++++++++ encoding detection functions +++++++++++++++++++++

function StrToEncoding(const S: String): TdomEncodingType;
var
  csmib: TCSMIB;
begin
  if (CompareText(S,'cp10000_MacRoman') = 0)
    then begin result:= etcp10000_MacRoman; exit; end;

  csmib:= TCSMIB.Create(nil);
  try
    if csmib.SetToAlias(S) then begin
      case csmib.Enum of
        4: result:= etLatin1;
        5: result:= etLatin2;
        6: result:= etLatin3;
        7: result:= etLatin4;
        8: result:= etCyrillic;
        9: result:= etArabic;
        10: result:= etGreek;
        11: result:= etHebrew;
        12: result:= etLatin5;
        13: result:= etLatin6;
        106: result:= etUTF8;
        109: result:= etLatin7;
        110: result:= etLatin8;
        111: result:= etLatin9;
        1013,1015: result:= etUTF16BE;
        1014: result:= etUTF16LE;
        2084: result:= etKOI8R;
        2250: result:= etWindows1250;
        2251: result:= etWindows1251;
        2252: result:= etWindows1252;
      else
        result:= etUnknown;
      end;
    end else result:= etUnknown;
  finally
    csmib.free;
  end;
end;


// ++++++++++++++++++++++ conversion functions ++++++++++++++++++++++++

function SingleByteEncodingToUTF16Char(const P: Char; const Encoding: TdomEncodingType):WideChar;
begin
  case Encoding of
    etLatin1:   result:= Iso8859_1ToUTF16Char(P);
    etLatin2:   result:= Iso8859_2ToUTF16Char(P);
    etLatin3:   result:= Iso8859_3ToUTF16Char(P);
    etLatin4:   result:= Iso8859_4ToUTF16Char(P);
    etCyrillic: result:= Iso8859_5ToUTF16Char(P);
    etArabic:   result:= Iso8859_6ToUTF16Char(P);
    etGreek:    result:= Iso8859_7ToUTF16Char(P);
    etHebrew:   result:= Iso8859_8ToUTF16Char(P);
    etLatin5:   result:= Iso8859_9ToUTF16Char(P);
    etLatin6:   result:= Iso8859_10ToUTF16Char(P);
    etLatin7:   result:= Iso8859_13ToUTF16Char(P);
    etLatin8:   result:= Iso8859_14ToUTF16Char(P);
    etLatin9:   result:= Iso8859_15ToUTF16Char(P);
    etKOI8R:    result:= KOI8_RToUTF16Char(P);
    etcp10000_MacRoman: result:= cp10000_MacRomanToUTF16Char(P);
    etWindows1250:   result:= cp1250ToUTF16Char(P);
    etWindows1251:   result:= cp1251ToUTF16Char(P);
    etWindows1252:   result:= cp1252ToUTF16Char(P);
  else
    raise EConvertError.Create('Invalid encoding type specified');
  end;
end;

function Iso8859_1ToUTF16Char(const P: Char):WideChar;
begin
  result:= WideChar(ord(P));
end;

function Iso8859_2ToUTF16Char(const P: Char):WideChar;
begin
  case ord(p) of
    $a1: result:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
    $a2: result:= #$02d8;  // BREVE
    $a3: result:= #$0141;  // LATIN CAPITAL LETTER L WITH STROKE
    $a5: result:= #$0132;  // LATIN CAPITAL LETTER L WITH CARON
    $a6: result:= #$015a;  // LATIN CAPITAL LETTER S WITH ACUTE
    $a9: result:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
    $aa: result:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
    $ab: result:= #$0164;  // LATIN CAPITAL LETTER T WITH CARON
    $ac: result:= #$0179;  // LATIN CAPITAL LETTER Z WITH ACUTE
    $ae: result:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
    $af: result:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
    $b1: result:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
    $b2: result:= #$02db;  // OGONEK
    $b3: result:= #$0142;  // LATIN SMALL LETTER L WITH STROKE
    $b5: result:= #$013e;  // LATIN SMALL LETTER L WITH CARON
    $b6: result:= #$015b;  // LATIN SMALL LETTER S WITH ACUTE
    $b7: result:= #$02c7;  // CARON
    $b9: result:= #$0161;  // LATIN SMALL LETTER S WITH CARON
    $ba: result:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
    $bb: result:= #$0165;  // LATIN SMALL LETTER T WITH CARON
    $bc: result:= #$017a;  // LATIN SMALL LETTER Z WITH ACUTE
    $bd: result:= #$02dd;  // DOUBLE ACUTE ACCENT
    $be: result:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
    $bf: result:= #$017c;  // LATIN SMALL LETTER Z WITH DOT ABOVE
    $c0: result:= #$0154;  // LATIN CAPITAL LETTER R WITH ACUTE
    $c3: result:= #$0102;  // LATIN CAPITAL LETTER A WITH BREVE
    $c5: result:= #$0139;  // LATIN CAPITAL LETTER L WITH ACUTE
    $c6: result:= #$0106;  // LATIN CAPITAL LETTER C WITH ACUTE
    $c8: result:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
    $ca: result:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
    $cc: result:= #$011a;  // LATIN CAPITAL LETTER E WITH CARON
    $cf: result:= #$010e;  // LATIN CAPITAL LETTER D WITH CARON
    $d0: result:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
    $d1: result:= #$0143;  // LATIN CAPITAL LETTER N WITH ACUTE
    $d2: result:= #$0147;  // LATIN CAPITAL LETTER N WITH CARON
    $d5: result:= #$0150;  // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
    $d8: result:= #$0158;  // LATIN CAPITAL LETTER R WITH CARON
    $d9: result:= #$016e;  // LATIN CAPITAL LETTER U WITH RING ABOVE
    $db: result:= #$0170;  // LATIN CAPITAL LETTER U WITH WITH DOUBLE ACUTE
    $de: result:= #$0162;  // LATIN CAPITAL LETTER T WITH CEDILLA
    $e0: result:= #$0155;  // LATIN SMALL LETTER R WITH ACUTE
    $e3: result:= #$0103;  // LATIN SMALL LETTER A WITH BREVE
    $e5: result:= #$013a;  // LATIN SMALL LETTER L WITH ACUTE
    $e6: result:= #$0107;  // LATIN SMALL LETTER C WITH ACUTE
    $e8: result:= #$010d;  // LATIN SMALL LETTER C WITH CARON
    $ea: result:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
    $ec: result:= #$011b;  // LATIN SMALL LETTER E WITH CARON
    $ef: result:= #$010f;  // LATIN SMALL LETTER D WITH CARON
    $f0: result:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
    $f1: result:= #$0144;  // LATIN SMALL LETTER N WITH ACUTE
    $f2: result:= #$0148;  // LATIN SMALL LETTER N WITH CARON
    $f5: result:= #$0151;  // LATIN SMALL LETTER O WITH DOUBLE ACUTE
    $f8: result:= #$0159;  // LATIN SMALL LETTER R WITH CARON
    $f9: result:= #$016f;  // LATIN SMALL LETTER U WITH RING ABOVE
    $fb: result:= #$0171;  // LATIN SMALL LETTER U WITH WITH DOUBLE ACUTE
    $fe: result:= #$0163;  // LATIN SMALL LETTER T WITH CEDILLA
    $ff: result:= #$02d9;  // DOT ABOVE
  else
    result:= WideChar(ord(P));
  end;
end;

function Iso8859_3ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $a1: result:= #$0126;  // LATIN CAPITAL LETTER H WITH STROKE
    $a2: result:= #$02d8;  // BREVE
    $a5: raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[P]);
    $a6: result:= #$0124;  // LATIN CAPITAL LETTER H WITH CIRCUMFLEX
    $a9: result:= #$0130;  // LATIN CAPITAL LETTER I WITH DOT ABOVE
    $aa: result:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
    $ab: result:= #$011e;  // LATIN CAPITAL LETTER G WITH BREVE
    $ac: result:= #$0134;  // LATIN CAPITAL LETTER J WITH CIRCUMFLEX
    $ae: raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[P]);
    $af: result:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT
    $b1: result:= #$0127;  // LATIN SMALL LETTER H WITH STROKE
    $b6: result:= #$0125;  // LATIN SMALL LETTER H WITH CIRCUMFLEX
    $b9: result:= #$0131;  // LATIN SMALL LETTER DOTLESS I
    $ba: result:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
    $bb: result:= #$011f;  // LATIN SMALL LETTER G WITH BREVE
    $bc: result:= #$0135;  // LATIN SMALL LETTER J WITH CIRCUMFLEX
    $be: raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[P]);
    $bf: result:= #$017c;  // LATIN SMALL LETTER Z WITH DOT
    $c3: raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[P]);
    $c5: result:= #$010a;  // LATIN CAPITAL LETTER C WITH DOT ABOVE
    $c6: result:= #$0108;  // LATIN CAPITAL LETTER C WITH CIRCUMFLEX
    $d0: raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[P]);
    $d5: result:= #$0120;  // LATIN CAPITAL LETTER G WITH DOT ABOVE
    $d8: result:= #$011c;  // LATIN CAPITAL LETTER G WITH CIRCUMFLEX
    $dd: result:= #$016c;  // LATIN CAPITAL LETTER U WITH BREVE
    $de: result:= #$015c;  // LATIN CAPITAL LETTER S WITH CIRCUMFLEX
    $e3: raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[P]);
    $e5: result:= #$010b;  // LATIN SMALL LETTER C WITH DOT ABOVE
    $e6: result:= #$0109;  // LATIN SMALL LETTER C WITH CIRCUMFLEX
    $f0: raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[P]);
    $f5: result:= #$0121;  // LATIN SMALL LETTER G WITH DOT ABOVE
    $f8: result:= #$011d;  // LATIN SMALL LETTER G WITH CIRCUMFLEX
    $fd: result:= #$016d;  // LATIN SMALL LETTER U WITH BREVE
    $fe: result:= #$015d;  // LATIN SMALL LETTER S WITH CIRCUMFLEX
    $ff: result:= #$02d9;  // DOT ABOVE
  else
    result:= WideChar(ord(P));
  end;
end;

function Iso8859_4ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $a1: result:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
    $a2: result:= #$0138;  // LATIN SMALL LETTER KRA
    $a3: result:= #$0156;  // LATIN CAPITAL LETTER R WITH CEDILLA
    $a5: result:= #$0128;  // LATIN CAPITAL LETTER I WITH TILDE
    $a6: result:= #$013b;  // LATIN CAPITAL LETTER L WITH CEDILLA
    $a9: result:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
    $aa: result:= #$0112;  // LATIN CAPITAL LETTER E WITH MACRON
    $ab: result:= #$0122;  // LATIN CAPITAL LETTER G WITH CEDILLA
    $ac: result:= #$0166;  // LATIN CAPITAL LETTER T WITH STROKE
    $ae: result:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
    $b1: result:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
    $b2: result:= #$02db;  // OGONEK
    $b3: result:= #$0157;  // LATIN SMALL LETTER R WITH CEDILLA
    $b5: result:= #$0129;  // LATIN SMALL LETTER I WITH TILDE
    $b6: result:= #$013c;  // LATIN SMALL LETTER L WITH CEDILLA
    $b7: result:= #$02c7;  // CARON
    $b9: result:= #$0161;  // LATIN SMALL LETTER S WITH CARON
    $ba: result:= #$0113;  // LATIN SMALL LETTER E WITH MACRON
    $bb: result:= #$0123;  // LATIN SMALL LETTER G WITH CEDILLA
    $bc: result:= #$0167;  // LATIN SMALL LETTER T WITH STROKE
    $bd: result:= #$014a;  // LATIN CAPITAL LETTER ENG
    $be: result:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
    $bf: result:= #$014b;  // LATIN SMALL LETTER ENG
    $c0: result:= #$0100;  // LATIN CAPITAL LETTER A WITH MACRON
    $c7: result:= #$012e;  // LATIN CAPITAL LETTER I WITH OGONEK
    $c8: result:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
    $ca: result:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
    $cc: result:= #$0116;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
    $cf: result:= #$012a;  // LATIN CAPITAL LETTER I WITH MACRON
    $d0: result:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
    $d1: result:= #$0145;  // LATIN CAPITAL LETTER N WITH CEDILLA
    $d2: result:= #$014c;  // LATIN CAPITAL LETTER O WITH MACRON
    $d3: result:= #$0136;  // LATIN CAPITAL LETTER K WITH CEDILLA
    $d9: result:= #$0172;  // LATIN CAPITAL LETTER U WITH OGONEK
    $dd: result:= #$0168;  // LATIN CAPITAL LETTER U WITH TILDE
    $de: result:= #$016a;  // LATIN CAPITAL LETTER U WITH MACRON
    $e0: result:= #$0101;  // LATIN SMALL LETTER A WITH MACRON
    $e7: result:= #$012f;  // LATIN SMALL LETTER I WITH OGONEK
    $e8: result:= #$010d;  // LATIN SMALL LETTER C WITH CARON
    $ea: result:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
    $ec: result:= #$0117;  // LATIN SMALL LETTER E WITH DOT ABOVE
    $ef: result:= #$012b;  // LATIN SMALL LETTER I WITH MACRON
    $f0: result:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
    $f1: result:= #$0146;  // LATIN SMALL LETTER N WITH CEDILLA
    $f2: result:= #$014d;  // LATIN SMALL LETTER O WITH MACRON
    $f3: result:= #$0137;  // LATIN SMALL LETTER K WITH CEDILLA
    $f9: result:= #$0173;  // LATIN SMALL LETTER U WITH OGONEK
    $fd: result:= #$0169;  // LATIN SMALL LETTER U WITH TILDE
    $fe: result:= #$016b;  // LATIN SMALL LETTER U WITH MACRON
    $ff: result:= #$02d9;  // DOT ABOVE
  else
    result:= WideChar(ord(P));
  end;
end;

function Iso8859_5ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $00..$a0,$ad:
      result:= WideChar(ord(P));
    $f0: result:= #$2116;  // NUMERO SIGN
    $fd: result:= #$00a7;  // SECTION SIGN
  else
    result:= WideChar(ord(P)+$0360);
  end;
end;

function Iso8859_6ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $00..$a0,$a4,$ad:
      result:= WideChar(ord(P));
    $ac,$bb,$bf,$c1..$da,$e0..$f2:
      result:= WideChar(ord(P)+$0580);
  else
    raise EConvertError.CreateFmt('Invalid ISO-8859-6 sequence "%s"',[P]);
  end;
end;

function Iso8859_7ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $00..$a0,$a6..$a9,$ab..$ad,$b0..$b3,$b7,$bb,$bd:
      result:= WideChar(ord(P));
    $a1: result:= #$2018;  // LEFT SINGLE QUOTATION MARK
    $a2: result:= #$2019;  // RIGHT SINGLE QUOTATION MARK
    $af: result:= #$2015;  // HORIZONTAL BAR
    $d2,$ff: raise EConvertError.CreateFmt('Invalid ISO-8859-7 sequence "%s"',[P]);
  else
    result:= WideChar(ord(P)+$02d0);
  end;
end;

function Iso8859_8ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $00..$a0,$a2..$a9,$ab..$ae,$b0..$b9,$bb..$be:
      result:= WideChar(ord(P));
    $aa: result:= #$00d7;  // MULTIPLICATION SIGN
    $af: result:= #$203e;  // OVERLINE
    $ba: result:= #$00f7;  // DIVISION SIGN
    $df: result:= #$2017;  // DOUBLE LOW LINE
    $e0..$fa:
      result:= WideChar(ord(P)+$04e0);
  else
    raise EConvertError.CreateFmt('Invalid ISO-8859-8 sequence "%s"',[P]);
  end;
end;

function Iso8859_9ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $d0: result:= #$011e;  // LATIN CAPITAL LETTER G WITH BREVE
    $dd: result:= #$0130;  // LATIN CAPITAL LETTER I WITH DOT ABOVE
    $de: result:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
    $f0: result:= #$011f;  // LATIN SMALL LETTER G WITH BREVE
    $fd: result:= #$0131;  // LATIN SMALL LETTER I WITH DOT ABOVE
    $fe: result:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
  else
    result:= WideChar(ord(P));
  end;
end;

function Iso8859_10ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $a1: result:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
    $a2: result:= #$0112;  // LATIN CAPITAL LETTER E WITH MACRON
    $a3: result:= #$0122;  // LATIN CAPITAL LETTER G WITH CEDILLA
    $a4: result:= #$012a;  // LATIN CAPITAL LETTER I WITH MACRON
    $a5: result:= #$0128;  // LATIN CAPITAL LETTER I WITH TILDE
    $a6: result:= #$0136;  // LATIN CAPITAL LETTER K WITH CEDILLA
    $a8: result:= #$013b;  // LATIN CAPITAL LETTER L WITH CEDILLA
    $a9: result:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
    $aa: result:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
    $ab: result:= #$0166;  // LATIN CAPITAL LETTER T WITH STROKE
    $ac: result:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
    $ae: result:= #$016a;  // LATIN CAPITAL LETTER U WITH MACRON
    $af: result:= #$014a;  // LATIN CAPITAL LETTER ENG
    $b1: result:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
    $b2: result:= #$0113;  // LATIN SMALL LETTER E WITH MACRON
    $b3: result:= #$0123;  // LATIN SMALL LETTER G WITH CEDILLA
    $b4: result:= #$012b;  // LATIN SMALL LETTER I WITH MACRON
    $b5: result:= #$0129;  // LATIN SMALL LETTER I WITH TILDE
    $b6: result:= #$0137;  // LATIN SMALL LETTER K WITH CEDILLA
    $b8: result:= #$013c;  // LATIN SMALL LETTER L WITH CEDILLA
    $b9: result:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
    $ba: result:= #$0161;  // LATIN SMALL LETTER S WITH CARON
    $bb: result:= #$0167;  // LATIN SMALL LETTER T WITH STROKE
    $bc: result:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
    $bd: result:= #$2015;  // HORIZONTAL BAR
    $be: result:= #$016b;  // LATIN SMALL LETTER U WITH MACRON
    $bf: result:= #$014b;  // LATIN SMALL LETTER ENG
    $c0: result:= #$0100;  // LATIN CAPITAL LETTER A WITH MACRON
    $c7: result:= #$012e;  // LATIN CAPITAL LETTER I WITH OGONEK
    $c8: result:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
    $ca: result:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
    $cc: result:= #$0116;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
    $d1: result:= #$0145;  // LATIN CAPITAL LETTER N WITH CEDILLA
    $d2: result:= #$014c;  // LATIN CAPITAL LETTER O WITH MACRON
    $d7: result:= #$0168;  // LATIN CAPITAL LETTER U WITH TILDE
    $d9: result:= #$0172;  // LATIN CAPITAL LETTER U WITH OGONEK
    $e0: result:= #$0101;  // LATIN SMALL LETTER A WITH MACRON
    $e7: result:= #$012f;  // LATIN SMALL LETTER I WITH OGONEK
    $e8: result:= #$010d;  // LATIN SMALL LETTER C WITH CARON
    $ea: result:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
    $ec: result:= #$0117;  // LATIN SMALL LETTER E WITH DOT ABOVE
    $f1: result:= #$0146;  // LATIN SMALL LETTER N WITH CEDILLA
    $f2: result:= #$014d;  // LATIN SMALL LETTER O WITH MACRON
    $f7: result:= #$0169;  // LATIN SMALL LETTER U WITH TILDE
    $f9: result:= #$0173;  // LATIN SMALL LETTER U WITH OGONEK
    $ff: result:= #$0138;  // LATIN SMALL LETTER KRA
  else
    result:= WideChar(ord(P));
  end;
end;

function Iso8859_13ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $a1: result:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
    $a5: result:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
    $a8: result:= #$00d8;  // LATIN CAPITAL LETTER O WITH STROKE
    $aa: result:= #$0156;  // LATIN CAPITAL LETTER R WITH CEDILLA
    $af: result:= #$00c6;  // LATIN CAPITAL LETTER AE
    $b4: result:= #$201c;  // LEFT DOUBLE QUOTATION MARK
    $b8: result:= #$00f8;  // LATIN SMALL LETTER O WITH STROKE
    $ba: result:= #$0157;  // LATIN SMALL LETTER R WITH CEDILLA
    $bf: result:= #$00e6;  // LATIN SMALL LETTER AE
    $c0: result:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
    $c1: result:= #$012e;  // LATIN CAPITAL LETTER I WITH OGONEK
    $c2: result:= #$0100;  // LATIN CAPITAL LETTER A WITH MACRON
    $c3: result:= #$0106;  // LATIN CAPITAL LETTER C WITH ACUTE
    $c6: result:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
    $c7: result:= #$0112;  // LATIN CAPITAL LETTER E WITH MACRON
    $c8: result:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
    $ca: result:= #$0179;  // LATIN CAPITAL LETTER Z WITH ACUTE
    $cb: result:= #$0116;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
    $cc: result:= #$0122;  // LATIN CAPITAL LETTER G WITH CEDILLA
    $cd: result:= #$0136;  // LATIN CAPITAL LETTER K WITH CEDILLA
    $ce: result:= #$012a;  // LATIN CAPITAL LETTER I WITH MACRON
    $cf: result:= #$013b;  // LATIN CAPITAL LETTER L WITH CEDILLA
    $d0: result:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
    $d1: result:= #$0143;  // LATIN CAPITAL LETTER N WITH ACUTE
    $d2: result:= #$0145;  // LATIN CAPITAL LETTER N WITH CEDILLA
    $d4: result:= #$014c;  // LATIN CAPITAL LETTER O WITH MACRON
    $d8: result:= #$0172;  // LATIN CAPITAL LETTER U WITH OGONEK
    $d9: result:= #$0141;  // LATIN CAPITAL LETTER L WITH STROKE
    $da: result:= #$015a;  // LATIN CAPITAL LETTER S WITH ACUTE
    $db: result:= #$016a;  // LATIN CAPITAL LETTER U WITH MACRON
    $dd: result:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
    $de: result:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
    $e0: result:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
    $e1: result:= #$012f;  // LATIN SMALL LETTER I WITH OGONEK
    $e2: result:= #$0101;  // LATIN SMALL LETTER A WITH MACRON
    $e3: result:= #$0107;  // LATIN SMALL LETTER C WITH ACUTE
    $e6: result:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
    $e7: result:= #$0113;  // LATIN SMALL LETTER E WITH MACRON
    $e8: result:= #$010d;  // LATIN SMALL LETTER C WITH CARON
    $ea: result:= #$017a;  // LATIN SMALL LETTER Z WITH ACUTE
    $eb: result:= #$0117;  // LATIN SMALL LETTER E WITH DOT ABOVE
    $ec: result:= #$0123;  // LATIN SMALL LETTER G WITH CEDILLA
    $ed: result:= #$0137;  // LATIN SMALL LETTER K WITH CEDILLA
    $ee: result:= #$012b;  // LATIN SMALL LETTER I WITH MACRON
    $ef: result:= #$013c;  // LATIN SMALL LETTER L WITH CEDILLA
    $f0: result:= #$0161;  // LATIN SMALL LETTER S WITH CARON
    $f1: result:= #$0144;  // LATIN SMALL LETTER N WITH ACUTE
    $f2: result:= #$0146;  // LATIN SMALL LETTER N WITH CEDILLA
    $f4: result:= #$014d;  // LATIN SMALL LETTER O WITH MACRON
    $f8: result:= #$0173;  // LATIN SMALL LETTER U WITH OGONEK
    $f9: result:= #$0142;  // LATIN SMALL LETTER L WITH STROKE
    $fa: result:= #$015b;  // LATIN SMALL LETTER S WITH ACUTE
    $fb: result:= #$016b;  // LATIN SMALL LETTER U WITH MACRON
    $fd: result:= #$017c;  // LATIN SMALL LETTER Z WITH DOT ABOVE
    $fe: result:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
    $ff: result:= #$2019;  // RIGHT SINGLE QUOTATION MARK
  else
    result:= WideChar(ord(P));
  end;
end;

function Iso8859_14ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $a1: result:= #$1e02;  // LATIN CAPITAL LETTER B WITH DOT ABOVE
    $a2: result:= #$1e03;  // LATIN SMALL LETTER B WITH DOT ABOVE
    $a4: result:= #$010a;  // LATIN CAPITAL LETTER C WITH DOT ABOVE
    $a5: result:= #$010b;  // LATIN SMALL LETTER C WITH DOT ABOVE
    $a6: result:= #$1e0a;  // LATIN CAPITAL LETTER D WITH DOT ABOVE
    $a8: result:= #$1e80;  // LATIN CAPITAL LETTER W WITH GRAVE
    $aa: result:= #$1e82;  // LATIN CAPITAL LETTER W WITH ACUTE
    $ab: result:= #$1e0b;  // LATIN SMALL LETTER D WITH DOT ABOVE
    $ac: result:= #$1ef2;  // LATIN CAPITAL LETTER Y WITH GRAVE
    $af: result:= #$0178;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
    $b0: result:= #$1e1e;  // LATIN CAPITAL LETTER F WITH DOT ABOVE
    $b1: result:= #$1e1f;  // LATIN SMALL LETTER F WITH DOT ABOVE
    $b2: result:= #$0120;  // LATIN CAPITAL LETTER G WITH DOT ABOVE
    $b3: result:= #$0121;  // LATIN SMALL LETTER G WITH DOT ABOVE
    $b4: result:= #$1e40;  // LATIN CAPITAL LETTER M WITH DOT ABOVE
    $b5: result:= #$1e41;  // LATIN SMALL LETTER M WITH DOT ABOVE
    $b7: result:= #$1e56;  // LATIN CAPITAL LETTER P WITH DOT ABOVE
    $b8: result:= #$1e81;  // LATIN SMALL LETTER W WITH GRAVE
    $b9: result:= #$1e57;  // LATIN SMALL LETTER P WITH DOT ABOVE
    $ba: result:= #$1e83;  // LATIN SMALL LETTER W WITH ACUTE
    $bb: result:= #$1e60;  // LATIN CAPITAL LETTER S WITH DOT ABOVE
    $bc: result:= #$1ef3;  // LATIN SMALL LETTER Y WITH GRAVE
    $bd: result:= #$1e84;  // LATIN CAPITAL LETTER W WITH DIAERESIS
    $be: result:= #$1e85;  // LATIN SMALL LETTER W WITH DIAERESIS
    $bf: result:= #$1e61;  // LATIN SMALL LETTER S WITH DOT ABOVE
    $d0: result:= #$0174;  // LATIN CAPITAL LETTER W WITH CIRCUMFLEX
    $d7: result:= #$1e6a;  // LATIN CAPITAL LETTER T WITH DOT ABOVE
    $de: result:= #$0176;  // LATIN CAPITAL LETTER Y WITH CIRCUMFLEX
    $f0: result:= #$0175;  // LATIN SMALL LETTER W WITH CIRCUMFLEX
    $f7: result:= #$1e6b;  // LATIN SMALL LETTER T WITH DOT ABOVE
    $fe: result:= #$0177;  // LATIN SMALL LETTER Y WITH CIRCUMFLEX
  else
    result:= WideChar(ord(P));
  end;
end;

function Iso8859_15ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $a4: result:= #$20ac;  // EURO SIGN
    $a6: result:= #$00a6;  // LATIN CAPITAL LETTER S WITH CARON
    $a8: result:= #$0161;  // LATIN SMALL LETTER S WITH CARON
    $b4: result:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
    $b8: result:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
    $bc: result:= #$0152;  // LATIN CAPITAL LIGATURE OE
    $bd: result:= #$0153;  // LATIN SMALL LIGATURE OE
    $be: result:= #$0178;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
  else
    result:= WideChar(ord(P));
  end;
end;

function KOI8_RToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $80: result:= #$2500;  // BOX DRAWINGS LIGHT HORIZONTAL
    $81: result:= #$2502;  // BOX DRAWINGS LIGHT VERTICAL
    $82: result:= #$250c;  // BOX DRAWINGS LIGHT DOWN AND RIGHT
    $83: result:= #$2510;  // BOX DRAWINGS LIGHT DOWN AND LEFT
    $84: result:= #$2514;  // BOX DRAWINGS LIGHT UP AND RIGHT
    $85: result:= #$2518;  // BOX DRAWINGS LIGHT UP AND LEFT
    $86: result:= #$251c;  // BOX DRAWINGS LIGHT VERTICAL AND RIGHT
    $87: result:= #$2524;  // BOX DRAWINGS LIGHT VERTICAL AND LEFT
    $88: result:= #$252c;  // BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
    $89: result:= #$2534;  // BOX DRAWINGS LIGHT UP AND HORIZONTAL
    $8a: result:= #$253c;  // BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
    $8b: result:= #$2580;  // UPPER HALF BLOCK
    $8c: result:= #$2584;  // LOWER HALF BLOCK
    $8d: result:= #$2588;  // FULL BLOCK
    $8e: result:= #$258c;  // LEFT HALF BLOCK
    $8f: result:= #$2590;  // RIGHT HALF BLOCK
    $90: result:= #$2591;  // LIGHT SHADE
    $91: result:= #$2592;  // MEDIUM SHADE
    $92: result:= #$2593;  // DARK SHADE
    $93: result:= #$2320;  // TOP HALF INTEGRAL
    $94: result:= #$25a0;  // BLACK SQUARE
    $95: result:= #$2219;  // BULLET OPERATOR
    $96: result:= #$221a;  // SQUARE ROOT
    $97: result:= #$2248;  // ALMOST EQUAL TO
    $98: result:= #$2264;  // LESS-THAN OR EQUAL TO
    $99: result:= #$2265;  // GREATER-THAN OR EQUAL TO
    $9a: result:= #$00a0;  // NO-BREAK SPACE
    $9b: result:= #$2321;  // BOTTOM HALF INTEGRAL
    $9c: result:= #$00b0;  // DEGREE SIGN
    $9d: result:= #$00b2;  // SUPERSCRIPT TWO
    $9e: result:= #$00b7;  // MIDDLE DOT
    $9f: result:= #$00f7;  // DIVISION SIGN
    $a0: result:= #$2550;  // BOX DRAWINGS DOUBLE HORIZONTAL
    $a1: result:= #$2551;  // BOX DRAWINGS DOUBLE VERTICAL
    $a2: result:= #$2552;  // BOX DRAWINGS DOWN SINGLE AND RIGHT DOUBLE
    $a3: result:= #$0451;  // CYRILLIC SMALL LETTER IO
    $a4: result:= #$2553;  // BOX DRAWINGS DOWN DOUBLE AND RIGHT SINGLE
    $a5: result:= #$2554;  // BOX DRAWINGS DOUBLE DOWN AND RIGHT
    $a6: result:= #$2555;  // BOX DRAWINGS DOWN SINGLE AND LEFT DOUBLE
    $a7: result:= #$2556;  // BOX DRAWINGS DOWN DOUBLE AND LEFT SINGLE
    $a8: result:= #$2557;  // BOX DRAWINGS DOUBLE DOWN AND LEFT
    $a9: result:= #$2558;  // BOX DRAWINGS UP SINGLE AND RIGHT DOUBLE
    $aa: result:= #$2559;  // BOX DRAWINGS UP DOUBLE AND RIGHT SINGLE
    $ab: result:= #$255a;  // BOX DRAWINGS DOUBLE UP AND RIGHT
    $ac: result:= #$255b;  // BOX DRAWINGS UP SINGLE AND LEFT DOUBLE
    $ad: result:= #$255c;  // BOX DRAWINGS UP DOUBLE AND LEFT SINGLE
    $ae: result:= #$255d;  // BOX DRAWINGS DOUBLE UP AND LEFT
    $af: result:= #$255e;  // BOX DRAWINGS VERTICAL SINGLE AND RIGHT DOUBLE
    $b0: result:= #$255f;  // BOX DRAWINGS VERTICAL DOUBLE AND RIGHT SINGLE
    $b1: result:= #$2560;  // BOX DRAWINGS DOUBLE VERTICAL AND RIGHT
    $b2: result:= #$2561;  // BOX DRAWINGS VERTICAL SINGLE AND LEFT DOUBLE
    $b3: result:= #$0401;  // CYRILLIC CAPITAL LETTER IO
    $b4: result:= #$2562;  // BOX DRAWINGS VERTICAL DOUBLE AND LEFT SINGLE
    $b5: result:= #$2563;  // BOX DRAWINGS DOUBLE VERTICAL AND LEFT
    $b6: result:= #$2564;  // BOX DRAWINGS DOWN SINGLE AND HORIZONTAL DOUBLE
    $b7: result:= #$2565;  // BOX DRAWINGS DOWN DOUBLE AND HORIZONTAL SINGLE
    $b8: result:= #$2566;  // BOX DRAWINGS DOUBLE DOWN AND HORIZONTAL
    $b9: result:= #$2567;  // BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE
    $ba: result:= #$2568;  // BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE
    $bb: result:= #$2569;  // BOX DRAWINGS DOUBLE UP AND HORIZONTAL
    $bc: result:= #$256a;  // BOX DRAWINGS VERTICAL SINGLE AND HORIZONTAL DOUBLE
    $bd: result:= #$256b;  // BOX DRAWINGS VERTICAL DOUBLE AND HORIZONTAL SINGLE
    $be: result:= #$256c;  // BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL
    $bf: result:= #$00a9;  // COPYRIGHT SIGN
    $c0: result:= #$044e;  // CYRILLIC SMALL LETTER YU
    $c1: result:= #$0430;  // CYRILLIC SMALL LETTER A
    $c2: result:= #$0431;  // CYRILLIC SMALL LETTER BE
    $c3: result:= #$0446;  // CYRILLIC SMALL LETTER TSE
    $c4: result:= #$0434;  // CYRILLIC SMALL LETTER DE
    $c5: result:= #$0435;  // CYRILLIC SMALL LETTER IE
    $c6: result:= #$0444;  // CYRILLIC SMALL LETTER EF
    $c7: result:= #$0433;  // CYRILLIC SMALL LETTER GHE
    $c8: result:= #$0445;  // CYRILLIC SMALL LETTER HA
    $c9: result:= #$0438;  // CYRILLIC SMALL LETTER I
    $ca: result:= #$0439;  // CYRILLIC SMALL LETTER SHORT I
    $cb: result:= #$043a;  // CYRILLIC SMALL LETTER KA
    $cc: result:= #$043b;  // CYRILLIC SMALL LETTER EL
    $cd: result:= #$043c;  // CYRILLIC SMALL LETTER EM
    $ce: result:= #$043d;  // CYRILLIC SMALL LETTER EN
    $cf: result:= #$043e;  // CYRILLIC SMALL LETTER O
    $d0: result:= #$043f;  // CYRILLIC SMALL LETTER PE
    $d1: result:= #$044f;  // CYRILLIC SMALL LETTER YA
    $d2: result:= #$0440;  // CYRILLIC SMALL LETTER ER
    $d3: result:= #$0441;  // CYRILLIC SMALL LETTER ES
    $d4: result:= #$0442;  // CYRILLIC SMALL LETTER TE
    $d5: result:= #$0443;  // CYRILLIC SMALL LETTER U
    $d6: result:= #$0436;  // CYRILLIC SMALL LETTER ZHE
    $d7: result:= #$0432;  // CYRILLIC SMALL LETTER VE
    $d8: result:= #$044c;  // CYRILLIC SMALL LETTER SOFT SIGN
    $d9: result:= #$044b;  // CYRILLIC SMALL LETTER YERU
    $da: result:= #$0437;  // CYRILLIC SMALL LETTER ZE
    $db: result:= #$0448;  // CYRILLIC SMALL LETTER SHA
    $dc: result:= #$044d;  // CYRILLIC SMALL LETTER E
    $dd: result:= #$0449;  // CYRILLIC SMALL LETTER SHCHA
    $de: result:= #$0447;  // CYRILLIC SMALL LETTER CHE
    $df: result:= #$044a;  // CYRILLIC SMALL LETTER HARD SIGN
    $e0: result:= #$042e;  // CYRILLIC CAPITAL LETTER YU
    $e1: result:= #$0410;  // CYRILLIC CAPITAL LETTER A
    $e2: result:= #$0411;  // CYRILLIC CAPITAL LETTER BE
    $e3: result:= #$0426;  // CYRILLIC CAPITAL LETTER TSE
    $e4: result:= #$0414;  // CYRILLIC CAPITAL LETTER DE
    $e5: result:= #$0415;  // CYRILLIC CAPITAL LETTER IE
    $e6: result:= #$0424;  // CYRILLIC CAPITAL LETTER EF
    $e7: result:= #$0413;  // CYRILLIC CAPITAL LETTER GHE
    $e8: result:= #$0425;  // CYRILLIC CAPITAL LETTER HA
    $e9: result:= #$0418;  // CYRILLIC CAPITAL LETTER I
    $ea: result:= #$0419;  // CYRILLIC CAPITAL LETTER SHORT I
    $eb: result:= #$041a;  // CYRILLIC CAPITAL LETTER KA
    $ec: result:= #$041b;  // CYRILLIC CAPITAL LETTER EL
    $ed: result:= #$041c;  // CYRILLIC CAPITAL LETTER EM
    $ee: result:= #$041d;  // CYRILLIC CAPITAL LETTER EN
    $ef: result:= #$041e;  // CYRILLIC CAPITAL LETTER O
    $f0: result:= #$041f;  // CYRILLIC CAPITAL LETTER PE
    $f1: result:= #$042f;  // CYRILLIC CAPITAL LETTER YA
    $f2: result:= #$0420;  // CYRILLIC CAPITAL LETTER ER
    $f3: result:= #$0421;  // CYRILLIC CAPITAL LETTER ES
    $f4: result:= #$0422;  // CYRILLIC CAPITAL LETTER TE
    $f5: result:= #$0423;  // CYRILLIC CAPITAL LETTER U
    $f6: result:= #$0416;  // CYRILLIC CAPITAL LETTER ZHE
    $f7: result:= #$0412;  // CYRILLIC CAPITAL LETTER VE
    $f8: result:= #$042c;  // CYRILLIC CAPITAL LETTER SOFT SIGN
    $f9: result:= #$042b;  // CYRILLIC CAPITAL LETTER YERU
    $fa: result:= #$0417;  // CYRILLIC CAPITAL LETTER ZE
    $fb: result:= #$0428;  // CYRILLIC CAPITAL LETTER SHA
    $fc: result:= #$042d;  // CYRILLIC CAPITAL LETTER E
    $fd: result:= #$0429;  // CYRILLIC CAPITAL LETTER SHCHA
    $fe: result:= #$0427;  // CYRILLIC CAPITAL LETTER CHE
    $ff: result:= #$042a;  // CYRILLIC CAPITAL LETTER HARD SIGN
  else
    result:= WideChar(ord(P));
  end;
end;

function cp10000_MacRomanToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $80: result:= #$00c4;  // LATIN CAPITAL LETTER A WITH DIAERESIS
    $81: result:= #$00c5;  // LATIN CAPITAL LETTER A WITH RING ABOVE
    $82: result:= #$00c7;  // LATIN CAPITAL LETTER C WITH CEDILLA
    $83: result:= #$00c9;  // LATIN CAPITAL LETTER E WITH ACUTE
    $84: result:= #$00d1;  // LATIN CAPITAL LETTER N WITH TILDE
    $85: result:= #$00d6;  // LATIN CAPITAL LETTER O WITH DIAERESIS
    $86: result:= #$00dc;  // LATIN CAPITAL LETTER U WITH DIAERESIS
    $87: result:= #$00e1;  // LATIN SMALL LETTER A WITH ACUTE
    $88: result:= #$00e0;  // LATIN SMALL LETTER A WITH GRAVE
    $89: result:= #$00e2;  // LATIN SMALL LETTER A WITH CIRCUMFLEX
    $8a: result:= #$00e4;  // LATIN SMALL LETTER A WITH DIAERESIS
    $8b: result:= #$00e3;  // LATIN SMALL LETTER A WITH TILDE
    $8c: result:= #$00e5;  // LATIN SMALL LETTER A WITH RING ABOVE
    $8d: result:= #$00e7;  // LATIN SMALL LETTER C WITH CEDILLA
    $8e: result:= #$00e9;  // LATIN SMALL LETTER E WITH ACUTE
    $8f: result:= #$00e8;  // LATIN SMALL LETTER E WITH GRAVE
    $90: result:= #$00ea;  // LATIN SMALL LETTER E WITH CIRCUMFLEX
    $91: result:= #$00eb;  // LATIN SMALL LETTER E WITH DIAERESIS
    $92: result:= #$00ed;  // LATIN SMALL LETTER I WITH ACUTE
    $93: result:= #$00ec;  // LATIN SMALL LETTER I WITH GRAVE
    $94: result:= #$00ee;  // LATIN SMALL LETTER I WITH CIRCUMFLEX
    $95: result:= #$00ef;  // LATIN SMALL LETTER I WITH DIAERESIS
    $96: result:= #$00f1;  // LATIN SMALL LETTER N WITH TILDE
    $97: result:= #$00f3;  // LATIN SMALL LETTER O WITH ACUTE
    $98: result:= #$00f2;  // LATIN SMALL LETTER O WITH GRAVE
    $99: result:= #$00f4;  // LATIN SMALL LETTER O WITH CIRCUMFLEX
    $9a: result:= #$00f6;  // LATIN SMALL LETTER O WITH DIAERESIS
    $9b: result:= #$00f5;  // LATIN SMALL LETTER O WITH TILDE
    $9c: result:= #$00fa;  // LATIN SMALL LETTER U WITH ACUTE
    $9d: result:= #$00f9;  // LATIN SMALL LETTER U WITH GRAVE
    $9e: result:= #$00fb;  // LATIN SMALL LETTER U WITH CIRCUMFLEX
    $9f: result:= #$00fc;  // LATIN SMALL LETTER U WITH DIAERESIS
    $a0: result:= #$2020;  // DAGGER
    $a1: result:= #$00b0;  // DEGREE SIGN
    $a4: result:= #$00a7;  // SECTION SIGN
    $a5: result:= #$2022;  // BULLET
    $a6: result:= #$00b6;  // PILCROW SIGN
    $a7: result:= #$00df;  // LATIN SMALL LETTER SHARP S
    $a8: result:= #$00ae;  // REGISTERED SIGN
    $aa: result:= #$2122;  // TRADE MARK SIGN
    $ab: result:= #$00b4;  // ACUTE ACCENT
    $ac: result:= #$00a8;  // DIAERESIS
    $ad: result:= #$2260;  // NOT EQUAL TO
    $ae: result:= #$00c6;  // LATIN CAPITAL LIGATURE AE
    $af: result:= #$00d8;  // LATIN CAPITAL LETTER O WITH STROKE
    $b0: result:= #$221e;  // INFINITY
    $b2: result:= #$2264;  // LESS-THAN OR EQUAL TO
    $b3: result:= #$2265;  // GREATER-THAN OR EQUAL TO
    $b4: result:= #$00a5;  // YEN SIGN
    $b6: result:= #$2202;  // PARTIAL DIFFERENTIAL
    $b7: result:= #$2211;  // N-ARY SUMMATION
    $b8: result:= #$220f;  // N-ARY PRODUCT
    $b9: result:= #$03c0;  // GREEK SMALL LETTER PI
    $ba: result:= #$222b;  // INTEGRAL
    $bb: result:= #$00aa;  // FEMININE ORDINAL INDICATOR
    $bc: result:= #$00ba;  // MASCULINE ORDINAL INDICATOR
    $bd: result:= #$2126;  // OHM SIGN
    $be: result:= #$00e6;  // LATIN SMALL LIGATURE AE
    $bf: result:= #$00f8;  // LATIN SMALL LETTER O WITH STROKE
    $c0: result:= #$00bf;  // INVERTED QUESTION MARK
    $c1: result:= #$00a1;  // INVERTED EXCLAMATION MARK
    $c2: result:= #$00ac;  // NOT SIGN
    $c3: result:= #$221a;  // SQUARE ROOT
    $c4: result:= #$0192;  // LATIN SMALL LETTER F WITH HOOK
    $c5: result:= #$2248;  // ALMOST EQUAL TO
    $c6: result:= #$2206;  // INCREMENT
    $c7: result:= #$00ab;  // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    $c8: result:= #$00bb;  // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    $c9: result:= #$2026;  // HORIZONTAL ELLIPSIS
    $ca: result:= #$00a0;  // NO-BREAK SPACE
    $cb: result:= #$00c0;  // LATIN CAPITAL LETTER A WITH GRAVE
    $cc: result:= #$00c3;  // LATIN CAPITAL LETTER A WITH TILDE
    $cd: result:= #$00d5;  // LATIN CAPITAL LETTER O WITH TILDE
    $ce: result:= #$0152;  // LATIN CAPITAL LIGATURE OE
    $cf: result:= #$0153;  // LATIN SMALL LIGATURE OE
    $d0: result:= #$2013;  // EN DASH
    $d1: result:= #$2014;  // EM DASH
    $d2: result:= #$201c;  // LEFT DOUBLE QUOTATION MARK
    $d3: result:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
    $d4: result:= #$2018;  // LEFT SINGLE QUOTATION MARK
    $d5: result:= #$2019;  // RIGHT SINGLE QUOTATION MARK
    $d6: result:= #$00f7;  // DIVISION SIGN
    $d7: result:= #$25ca;  // LOZENGE
    $d8: result:= #$00ff;  // LATIN SMALL LETTER Y WITH DIAERESIS
    $d9: result:= #$0178;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
    $da: result:= #$2044;  // FRACTION SLASH
    $db: result:= #$00a4;  // CURRENCY SIGN
    $dc: result:= #$2039;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    $dd: result:= #$203a;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    $de: result:= #$fb01;  // LATIN SMALL LIGATURE FI
    $df: result:= #$fb02;  // LATIN SMALL LIGATURE FL
    $e0: result:= #$2021;  // DOUBLE DAGGER
    $e1: result:= #$00b7;  // MIDDLE DOT
    $e2: result:= #$201a;  // SINGLE LOW-9 QUOTATION MARK
    $e3: result:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
    $e4: result:= #$2030;  // PER MILLE SIGN
    $e5: result:= #$00c2;  // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
    $e6: result:= #$00ca;  // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
    $e7: result:= #$00c1;  // LATIN CAPITAL LETTER A WITH ACUTE
    $e8: result:= #$00cb;  // LATIN CAPITAL LETTER E WITH DIAERESIS
    $e9: result:= #$00c8;  // LATIN CAPITAL LETTER E WITH GRAVE
    $ea: result:= #$00cd;  // LATIN CAPITAL LETTER I WITH ACUTE
    $eb: result:= #$00ce;  // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
    $ec: result:= #$00cf;  // LATIN CAPITAL LETTER I WITH DIAERESIS
    $ed: result:= #$00cc;  // LATIN CAPITAL LETTER I WITH GRAVE
    $ee: result:= #$00d3;  // LATIN CAPITAL LETTER O WITH ACUTE
    $ef: result:= #$00d4;  // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
    $f0: raise EConvertError.CreateFmt('Invalid cp10000_MacRoman sequence "%s"',[P]);
    $f1: result:= #$00d2;  // LATIN CAPITAL LETTER O WITH GRAVE
    $f2: result:= #$00da;  // LATIN CAPITAL LETTER U WITH ACUTE
    $f3: result:= #$00db;  // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
    $f4: result:= #$00d9;  // LATIN CAPITAL LETTER U WITH GRAVE
    $f5: result:= #$0131;  // LATIN SMALL LETTER DOTLESS I
    $f6: result:= #$02c6;  // MODIFIER LETTER CIRCUMFLEX ACCENT
    $f7: result:= #$02dc;  // SMALL TILDE
    $f8: result:= #$00af;  // MACRON
    $f9: result:= #$02d8;  // BREVE
    $fa: result:= #$02d9;  // DOT ABOVE
    $fb: result:= #$02da;  // RING ABOVE
    $fc: result:= #$00b8;  // CEDILLA
    $fd: result:= #$02dd;  // DOUBLE ACUTE ACCENT
    $fe: result:= #$02db;  // OGONEK
    $ff: result:= #$02c7;  // CARON
  else
    result:= WideChar(ord(P));
  end;
end;

function cp1250ToUTF16Char(const P: Char):WideChar;
// This function was provided by Miloslav Skácel
const
  sInvalidWindows1250Sequence = 'Invalid Windows-1250 sequence "%s"';
begin
  case ord(p) of
    // NOT USED
    $81,$83,$88,$90,$98:
      raise EConvertError.CreateFmt(sInvalidWindows1250Sequence,[P]);
    $80: result:= #$20ac;  // EURO SIGN
    $82: Result:= #$201a;  // SINGLE LOW-9 QUOTATION MARK
    $84: Result:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
    $85: Result:= #$2026;  // HORIZONTAL ELLIPSIS
    $86: Result:= #$2020;  // DAGGER
    $87: Result:= #$2021;  // DOUBLE DAGGER
    $89: Result:= #$2030;  // PER MILLE SIGN
    $8a: Result:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
    $8b: Result:= #$2039;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    $8c: Result:= #$015a;  // LATIN CAPITAL LETTER S WITH ACUTE
    $8d: Result:= #$0164;  // LATIN CAPITAL LETTER T WITH CARON
    $8e: Result:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
    $8f: Result:= #$0179;  // LATIN CAPITAL LETTER Z WITH ACUTE
    $91: Result:= #$2018;  // LEFT SINGLE QUOTATION MARK
    $92: Result:= #$2019;  // RIGHT SINGLE QUOTATION MARK
    $93: Result:= #$201c;  // LEFT DOUBLE QUOTATION MARK
    $94: Result:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
    $95: Result:= #$2022;  // BULLET
    $96: Result:= #$2013;  // EN-DASH
    $97: Result:= #$2014;  // EM-DASH
    $99: Result:= #$2122;  // TRADE MARK SIGN
    $9a: Result:= #$0161;  // LATIN SMALL LETTER S WITH CARON
    $9b: Result:= #$203a;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    $9c: Result:= #$015b;  // LATIN SMALL LETTER S WITH ACUTE
    $9d: Result:= #$0165;  // LATIN SMALL LETTER T WITH CARON
    $9e: Result:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
    $9f: Result:= #$017a;  // LATIN SMALL LETTER Z WITH ACUTE
    $a0: Result:= #$00a0;  // NO-BREAK SPACE
    $a1: Result:= #$02c7;  // CARON
    $a2: Result:= #$02d8;  // BREVE
    $a3: Result:= #$0141;  // LATIN CAPITAL LETTER L WITH STROKE
    $a4: Result:= #$00a4;  // CURRENCY SIGN
    $a5: Result:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
    $a6: Result:= #$00a6;  // BROKEN BAR
    $a7: Result:= #$00a7;  // SECTION SIGN
    $a8: Result:= #$00a8;  // DIAERESIS
    $a9: Result:= #$00a9;  // COPYRIGHT SIGN
    $aa: Result:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
    $ab: Result:= #$00ab;  // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    $ac: Result:= #$00ac;  // NOT SIGN
    $ad: Result:= #$00ad;  // SOFT HYPHEN
    $ae: Result:= #$00ae;  // REGISTERED SIGN
    $af: Result:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
    $b0: Result:= #$00b0;  // DEGREE SIGN
    $b1: Result:= #$00b1;  // PLUS-MINUS SIGN
    $b2: Result:= #$02db;  // OGONEK
    $b3: Result:= #$0142;  // LATIN SMALL LETTER L WITH STROKE
    $b4: Result:= #$00b4;  // ACUTE ACCENT
    $b5: Result:= #$00b5;  // MIKRO SIGN
    $b6: Result:= #$00b6;  // PILCROW SIGN
    $b7: Result:= #$00b7;  // MIDDLE DOT
    $b8: Result:= #$00b8;  // CEDILLA
    $b9: Result:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
    $ba: Result:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
    $bb: Result:= #$00bb;  // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    $bc: Result:= #$013d;  // LATIN CAPITAL LETTER L WITH CARON
    $bd: Result:= #$02dd;  // DOUBLE ACUTE ACCENT
    $be: Result:= #$013e;  // LATIN SMALL LETTER L WITH CARON
    $bf: Result:= #$017c;  // LATIN SMALL LETTER Z WITH DOT ABOVE
    $c0: Result:= #$0154;  // LATIN CAPITAL LETTER R WITH ACUTE
    $c1: Result:= #$00c1;  // LATIN CAPITAL LETTER A WITH ACUTE
    $c2: Result:= #$00c2;  // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
    $c3: Result:= #$0102;  // LATIN CAPITAL LETTER A WITH BREVE
    $c4: Result:= #$00c4;  // LATIN CAPITAL LETTER A WITH DIAERESIS
    $c5: Result:= #$0139;  // LATIN CAPITAL LETTER L WITH ACUTE
    $c6: Result:= #$0106;  // LATIN CAPITAL LETTER C WITH ACUTE
    $c7: Result:= #$00c7;  // LATIN CAPITAL LETTER C WITH CEDILLA
    $c8: Result:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
    $c9: Result:= #$00c9;  // LATIN CAPITAL LETTER E WITH ACUTE
    $ca: Result:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
    $cb: Result:= #$00cb;  // LATIN CAPITAL LETTER E WITH DIAERESIS
    $cc: Result:= #$011a;  // LATIN CAPITAL LETTER E WITH CARON
    $cd: Result:= #$00cd;  // LATIN CAPITAL LETTER I WITH ACUTE
    $ce: Result:= #$00ce;  // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
    $cf: Result:= #$010e;  // LATIN CAPITAL LETTER D WITH CARON
    $d0: Result:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
    $d1: Result:= #$0143;  // LATIN CAPITAL LETTER N WITH ACUTE
    $d2: Result:= #$0147;  // LATIN CAPITAL LETTER N WITH CARON
    $d3: Result:= #$00d3;  // LATIN CAPITAL LETTER O WITH ACUTE
    $d4: Result:= #$00d4;  // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
    $d5: Result:= #$0150;  // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
    $d6: Result:= #$00d6;  // LATIN CAPITAL LETTER O WITH DIAERESIS
    $d7: Result:= #$00d7;  // MULTIPLICATION SIGN
    $d8: Result:= #$0158;  // LATIN CAPITAL LETTER R WITH CARON
    $d9: Result:= #$016e;  // LATIN CAPITAL LETTER U WITH RING ABOVE
    $da: Result:= #$00da;  // LATIN CAPITAL LETTER U WITH ACUTE
    $db: Result:= #$0170;  // LATIN CAPITAL LETTER U WITH WITH DOUBLE ACUTE
    $dc: Result:= #$00dc;  // LATIN CAPITAL LETTER U WITH DIAERESIS
    $dd: Result:= #$00dd;  // LATIN CAPITAL LETTER Y WITH ACUTE
    $de: Result:= #$0162;  // LATIN CAPITAL LETTER T WITH CEDILLA
    $df: Result:= #$00df;  // LATIN SMALL LETTER SHARP S
    $e0: Result:= #$0155;  // LATIN SMALL LETTER R WITH ACUTE
    $e1: Result:= #$00e1;  // LATIN SMALL LETTER A WITH ACUTE
    $e2: Result:= #$00e2;  // LATIN SMALL LETTER A WITH CIRCUMFLEX
    $e3: Result:= #$0103;  // LATIN SMALL LETTER A WITH BREVE
    $e4: Result:= #$00e4;  // LATIN SMALL LETTER A WITH DIAERESIS
    $e5: Result:= #$013a;  // LATIN SMALL LETTER L WITH ACUTE
    $e6: Result:= #$0107;  // LATIN SMALL LETTER C WITH ACUTE
    $e7: Result:= #$00e7;  // LATIN SMALL LETTER C WITH CEDILLA
    $e8: Result:= #$010d;  // LATIN SMALL LETTER C WITH CARON 100D
    $e9: Result:= #$00e9;  // LATIN SMALL LETTER E WITH ACUTE
    $ea: Result:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
    $eb: Result:= #$00eb;  // LATIN SMALL LETTER E WITH DIAERESIS
    $ec: Result:= #$011b;  // LATIN SMALL LETTER E WITH CARON
    $ed: Result:= #$00ed;  // LATIN SMALL LETTER I WITH ACUTE
    $ee: Result:= #$00ee;  // LATIN SMALL LETTER I WITH CIRCUMFLEX
    $ef: Result:= #$010f;  // LATIN SMALL LETTER D WITH CARON
    $f0: Result:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
    $f1: Result:= #$0144;  // LATIN SMALL LETTER N WITH ACUTE
    $f2: Result:= #$0148;  // LATIN SMALL LETTER N WITH CARON
    $f3: Result:= #$00f3;  // LATIN SMALL LETTER O WITH ACUTE
    $f4: Result:= #$00f4;  // LATIN SMALL LETTER O WITH CIRCUMFLEX
    $f5: Result:= #$0151;  // LATIN SMALL LETTER O WITH DOUBLE ACUTE
    $f6: Result:= #$00f6;  // LATIN SMALL LETTER O WITH DIAERESIS
    $f7: Result:= #$00f7;  // DIVISION SIGN
    $f8: Result:= #$0159;  // LATIN SMALL LETTER R WITH CARON
    $f9: Result:= #$016f;  // LATIN SMALL LETTER U WITH RING ABOVE
    $fa: Result:= #$00fa;  // LATIN SMALL LETTER U WITH ACUTE
    $fb: Result:= #$0171;  // LATIN SMALL LETTER U WITH WITH DOUBLE ACUTE
    $fc: Result:= #$00fc;  // LATIN SMALL LETTER U WITH DIAERESIS
    $fd: Result:= #$00fd;  // LATIN SMALL LETTER Y WITH ACUTE
    $fe: Result:= #$0163;  // LATIN SMALL LETTER T WITH CEDILLA
    $ff: Result:= #$02d9;  // DOT ABOVE
  else
    Result:= WideChar(ord(P));
  end;
end;

function cp1251ToUTF16Char(const P: Char):WideChar;
begin
  case ord(P) of
    $80: result:= #$0402;  // CYRILLIC CAPITAL LETTER DJE
    $81: result:= #$0403;  // CYRILLIC CAPITAL LETTER GJE
    $82: result:= #$201a;  // SINGLE LOW-9 QUOTATION MARK
    $83: result:= #$0453;  // CYRILLIC SMALL LETTER GJE
    $84: result:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
    $85: result:= #$2026;  // HORIZONTAL ELLIPSIS
    $86: result:= #$2020;  // DAGGER
    $87: result:= #$2021;  // DOUBLE DAGGER
    $88: result:= #$20ac;  // EURO SIGN
    $89: result:= #$2030;  // PER MILLE SIGN
    $8a: result:= #$0409;  // CYRILLIC CAPITAL LETTER LJE
    $8b: result:= #$2039;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    $8c: result:= #$040a;  // CYRILLIC CAPITAL LETTER NJE
    $8d: result:= #$040c;  // CYRILLIC CAPITAL LETTER KJE
    $8e: result:= #$040b;  // CYRILLIC CAPITAL LETTER TSHE
    $8f: result:= #$040f;  // CYRILLIC CAPITAL LETTER DZHE
    $90: result:= #$0452;  // CYRILLIC SMALL LETTER DJE
    $91: result:= #$2018;  // LEFT SINGLE QUOTATION MARK
    $92: result:= #$2019;  // RIGHT SINGLE QUOTATION MARK
    $93: result:= #$201c;  // LEFT DOUBLE QUOTATION MARK
    $94: result:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
    $95: result:= #$2022;  // BULLET
    $96: result:= #$2013;  // EN DASH
    $97: result:= #$2014;  // EM DASH
    $98: raise EConvertError.CreateFmt('Invalid cp1251 sequence "%s"',[P]);
    $99: result:= #$2122;  // TRADE MARK SIGN
    $9a: result:= #$0459;  // CYRILLIC SMALL LETTER LJE
    $9b: result:= #$203a;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    $9c: result:= #$045a;  // CYRILLIC SMALL LETTER NJE
    $9d: result:= #$045c;  // CYRILLIC SMALL LETTER KJE
    $9e: result:= #$045b;  // CYRILLIC SMALL LETTER TSHE
    $9f: result:= #$045f;  // CYRILLIC SMALL LETTER DZHE
    $a0: result:= #$00a0;  // NO-BREAK SPACE
    $a1: result:= #$040e;  // CYRILLIC CAPITAL LETTER SHORT U
    $a2: result:= #$045e;  // CYRILLIC SMALL LETTER SHORT U
    $a3: result:= #$0408;  // CYRILLIC CAPITAL LETTER JE
    $a4: result:= #$00a4;  // CURRENCY SIGN
    $a5: result:= #$0490;  // CYRILLIC CAPITAL LETTER GHE WITH UPTURN
    $a8: result:= #$0401;  // CYRILLIC CAPITAL LETTER IO
    $aa: result:= #$0404;  // CYRILLIC CAPITAL LETTER UKRAINIAN IE
    $af: result:= #$0407;  // CYRILLIC CAPITAL LETTER YI
    $b2: result:= #$0406;  // CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
    $b3: result:= #$0456;  // CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
    $b4: result:= #$0491;  // CYRILLIC SMALL LETTER GHE WITH UPTURN
    $b8: result:= #$0451;  // CYRILLIC SMALL LETTER IO
    $b9: result:= #$2116;  // NUMERO SIGN
    $ba: result:= #$0454;  // CYRILLIC SMALL LETTER UKRAINIAN IE
    $bc: result:= #$0458;  // CYRILLIC SMALL LETTER JE
    $bd: result:= #$0405;  // CYRILLIC CAPITAL LETTER DZE
    $be: result:= #$0455;  // CYRILLIC SMALL LETTER DZE
    $bf: result:= #$0457;  // CYRILLIC SMALL LETTER YI
    $c0..$ff:
      result:= WideChar(ord(P)+$350);
  else
    result:= WideChar(ord(P));
  end;
end;

function cp1252ToUTF16Char(const P: Char):WideChar;
// Provided by Olaf Lösken.
// Info taken from
// ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1252.TXT
const
  sInvalidWindows1252Sequence = 'Invalid Windows-1252 sequence "%s"';
begin
  case ord(p) of
    $80 : result:= #$20AC; //EUROSIGN
    $81 : raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[P]);
    $82 : result:= #$201A; //SINGLE LOW-9 QUOTATION MARK
    $83 : result:= #$0192; //ATIN SMALL LETTER F WITH HOOK
    $84 : result:= #$201E; //DOUBLE LOW-9 QUOTATION MARK
    $85 : result:= #$2026; //HORIZONTAL ELLIPSIS
    $86 : result:= #$2020; //DAGGER
    $87 : result:= #$2021; //DOUBLE DAGGER
    $88 : result:= #$02C6; //MODIFIER LETTER CIRCUMFLEX ACCENT
    $89 : result:= #$2030; //PER MILLE SIGN
    $8A : result:= #$0160; //LATIN CAPITAL LETTER S WITH CARON
    $8B : result:= #$2039; //SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    $8C : result:= #$0152; //LATIN CAPITAL LIGATURE OE
    $8D : raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[P]);
    $8E : result:= #$017D; //LATIN CAPITAL LETTER Z WITH CARON
    $8F : raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[P]);
    $90 : raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[P]);
    $91 : result:= #$2018; //LEFT SINGLE QUOTATION MARK
    $92 : result:= #$2019; //RIGHT SINGLE QUOTATION MARK
    $93 : result:= #$201C; //LEFT DOUBLE QUOTATION MARK
    $94 : result:= #$201D; //RIGHT DOUBLE QUOTATION MARK
    $95 : result:= #$2022; //BULLET
    $96 : result:= #$2013; //EN DASH
    $97 : result:= #$2014; //EM DASH
    $98 : result:= #$02DC; //SMALL TILDE
    $99 : result:= #$2122; //TRADE MARK SIGN
    $9A : result:= #$0161; //LATIN SMALL LETTER S WITH CARON
    $9B : result:= #$203A; //SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    $9C : result:= #$0153; //LATIN SMALL LIGATURE OE
    $9D : raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[P]);
    $9E : result:= #$017E; //LATIN SMALL LETTER Z WITH CARON
    $9F : result:= #$0178; //LATIN CAPITAL LETTER Y WITH D
  else
    Result:= WideChar(ord(P));
  end;
end;

function Iso8859_1ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-1 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_1ToUTF16Char(s[i]);
end;

function Iso8859_2ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-2 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_2ToUTF16Char(s[i]);
end;

function Iso8859_3ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-3 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_3ToUTF16Char(s[i]);
end;

function Iso8859_4ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-4 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_4ToUTF16Char(s[i]);
end;

function Iso8859_5ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-5 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_5ToUTF16Char(s[i]);
end;

function Iso8859_6ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-6 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_6ToUTF16Char(s[i]);
end;

function Iso8859_7ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-7 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_7ToUTF16Char(s[i]);
end;

function Iso8859_8ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-8 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_8ToUTF16Char(s[i]);
end;

function Iso8859_9ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-9 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_9ToUTF16Char(s[i]);
end;

function Iso8859_10ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-10 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_10ToUTF16Char(s[i]);
end;

function Iso8859_13ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-13 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_13ToUTF16Char(s[i]);
end;

function Iso8859_14ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-14 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_14ToUTF16Char(s[i]);
end;

function Iso8859_15ToUTF16Str(const s: string): wideString;
// Converts an ISO-8859-15 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=Iso8859_15ToUTF16Char(s[i]);
end;

function KOI8_RToUTF16Str(const s: string): wideString;
// Converts an KOI8-R string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=KOI8_RToUTF16Char(s[i]);
end;

function cp10000_MacRomanToUTF16Str(const s: string): wideString;
// Converts an cp10000_MacRoman string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=cp10000_MacRomanToUTF16Char(s[i]);
end;

function cp1250ToUTF16Str(const s: string): wideString;
// Converts an cp1250 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=cp1250ToUTF16Char(s[i]);
end;

function cp1251ToUTF16Str(const s: string): wideString;
// Converts an cp1251 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=cp1251ToUTF16Char(s[i]);
end;

function cp1252ToUTF16Str(const s: string): wideString;
// Converts an cp1252 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) are done.
var
  i,j: integer;
begin
  j:= length(s);
  setLength(Result,j);
  for i:= 1 to j do
    Result[i]:=cp1252ToUTF16Char(s[i]);
end;

function UTF8ToUTF16BEStr(const s: string): wideString;
// Converts an UTF-8 string into an UTF-16 wideString.
// No special conversions (e.g. on line breaks) and
// no XML-char checking are done.
// - This function was provided by Ernst van der Pols -
// - and slightly modified by Dieter Köhler -
const
  MaxCode: array[1..6] of integer = ($7F,$7FF,$FFFF,$1FFFFF,$3FFFFFF,$7FFFFFFF);
var
  i, j, CharSize, mask, ucs4: integer;
  c, first: char;
begin
  setLength(Result,Length(s)+1); // assume no or little above-ASCII-chars
  j:=0;                          // keep track of actual length
  i:=0;
  while i<length(s) do
  begin
    Inc(i); c:=s[i];
    if ord(c)>=$80 then         // UTF-8 sequence
    begin
      CharSize:=1;
      first:=c; mask:=$40; ucs4:=ord(c);
      if (ord(c) and $C0<>$C0) then
        raise EConvertError.CreateFmt('Invalid UTF-8 sequence %2.2X',[ord(c)]);
      while (mask and ord(first)<>0) do
      begin
        // read next character of stream
        if i=length(s) then
          raise EConvertError.CreateFmt('Aborted UTF-8 sequence "%s"',[Copy(s,i-CharSize,CharSize)]);
        Inc(i); c:=s[i];
        if (ord(c) and $C0<>$80) then
          raise EConvertError.CreateFmt('Invalid UTF-8 sequence $%2.2X',[ord(c)]);
        ucs4:=(ucs4 shl 6) or (ord(c) and $3F); // add bits to result
        Inc(CharSize);  // increase sequence length
        mask:=mask shr 1;    // adjust mask
      end;
      if (CharSize>6) then   // no 0 bit in sequence header 'first'
        raise EConvertError.CreateFmt('Invalid UTF-8 sequence "%s"',[Copy(s,i-CharSize,CharSize)]);
      ucs4:=ucs4 and MaxCode[CharSize]; // dispose of header bits
      // check for invalid sequence as suggested by RFC2279
      if ((CharSize>1) and (ucs4<=MaxCode[CharSize-1])) then
        raise EConvertError.CreateFmt('Invalid UTF-8 encoding "%s"',[Copy(s,i-CharSize,CharSize)]);
      // convert non-ASCII UCS-4 to UTF-16 if possible
      case ucs4 of
      $00000080..$0000D7FF,$0000E000..$0000FFFD:
        begin
          Inc(j); Result[j]:=WideChar(ord(c));
        end;
      $0000D800..$0000DFFF,$0000FFFE,$0000FFFF:
        raise EConvertError.CreateFmt('Invalid UCS-4 character $%8.8X',[ucs4]);
      $00010000..$0010FFFF:
        begin
          // add high surrogate to content as if it was processed earlier
          Inc(j); Result[j]:= Utf16HighSurrogate(ucs4);  // assign high surrogate
          Inc(j); Result[j]:= Utf16LowSurrogate(ucs4);   // assign low surrogate
        end;
      else // out of UTF-16 range
        raise EConvertError.CreateFmt('Cannot convert $%8.8X to UTF-16',[ucs4]);
      end;
    end
    else        // ASCII char
    begin
      Inc(j); Result[j]:=WideChar(ord(c));
    end;
  end;
  setLength(Result,j); // set to correct length
end;

function UTF16BEToUTF8Str(const ws: wideString;
                          const expandLF: boolean): string;
var
  StringStr: TStringStream;
  UTF16To8: TUTF16BEToUTF8Stream;
begin
  StringStr := TStringStream.create('');
  try
    UTF16To8 := TUTF16BEToUTF8Stream.create(StringStr);
    try
      UTF16To8.ExpandLF := expandLF;
      UTF16To8.WriteBuffer(pointer(ws)^, Length(ws) shl 1);
    finally
      UTF16To8.Free;
    end;
    Result := StringStr.DataString;
  finally
    StringStr.Free;
  end;
end;

function UTF16To7BitASCIIChar(const P: wideChar): char;
begin
  case ord(p) of
    $00..$7f: result:= char(ord(p));
  else
    raise EConvertError.CreateFmt('Invalid 7BitASCII sequence "%s"',[P]);
  end;
end;

function UTF16ToIso8859_1Char(const P: wideChar): char;
begin
  case ord(p) of
    $00..$ff: result:= char(ord(p));
  else
   raise EConvertError.CreateFmt('Invalid ISO-8859-1 sequence "%s"',[P]);
  end;
end;

function UTF16To7BitASCIIStr(const S: wideString): string;
var
  i,j,start: integer;
  encType: TdomEncodingType;
begin
  j:= length(s);
  start:= 1;
  encType:= etUTF16BE;
  if j > 0 then begin
    // Byte order mark?
    if s[1] = #$feff then start:= 2
    else if s[1] = #$fffe then begin start:= 2; encType:= etUTF16LE; end;
  end;
  setLength(Result,j-start+1);
  if encType = etUTF16BE
    then for i:= start to j do Result[i]:= UTF16To7BitASCIIChar(s[i])
    else for i:= start to j do Result[i]:= UTF16To7BitASCIIChar(wideChar(Swap(ord(s[i]))));
end;

function UTF16ToIso8859_1Str(const S: wideString): string;
var
  i,j,start: integer;
  encType: TdomEncodingType;
begin
  j:= length(s);
  start:= 1;
  encType:= etUTF16BE;
  if j > 0 then begin
    // Byte order mark?
    if s[1] = #$feff then start:= 2
    else if s[1] = #$fffe then begin start:= 2; encType:= etUTF16LE; end;
  end;
  setLength(Result,j-start+1);
  if encType = etUTF16BE
    then for i:= start to j do Result[i]:= UTF16ToIso8859_1Char(s[i])
    else for i:= start to j do Result[i]:= UTF16ToIso8859_1Char(wideChar(Swap(ord(s[i]))));
end;

function Utf16HighSurrogate(const value: integer): WideChar;
var
  value2: word;
begin
  value2:= ($D7C0 + ( value shr 10 ));
  Result:= WideChar(value2);
end;

function Utf16LowSurrogate(const value: integer): WideChar;
var
  value2: word;
begin
  value2:= ($DC00 XOR (value AND $3FF));
  Result:= WideChar(value2);
end;

function Utf16SurrogateToInt(const highSurrogate, lowSurrogate: WideChar): integer;
begin
  Result:=  ( (word(highSurrogate) -  $D7C0) shl 10 )
          + (  word(lowSurrogate) XOR $DC00  );
end;

function IsUtf16HighSurrogate(const S: WideChar): boolean;
begin
  Case Word(S) of
    $D800..$DBFF: result:= true;
  else
    result:= false;
  end;
end;

function IsUtf16LowSurrogate(const S: WideChar): boolean;
begin
  Case Word(S) of
    $DC00..$DFFF: result:= true;
  else
    result:= false;
  end;
end;



{ TCSMIB }

constructor TCSMIB.Create(AOwner: TComponent);
begin
  inherited;
  Enum:= 3;
end;

procedure TCSMIB.DoChange(Sender: TObject);
begin
  if assigned(FOnChange)
    then FOnChange(Sender);
end;

procedure TCSMIB.DoChanging(Sender: TObject; NewEnum: integer;
  var AllowChange: Boolean);
begin
  if assigned(FOnChanging)
    then FOnChanging(Sender,NewEnum,AllowChange);
end;

function TCSMIB.GetAlias(i: integer): string;
begin
  case FEnum of
    3: case i of
      0: result:= 'ANSI_X3.4-1968';
      1: result:= 'iso-ir-6';
      2: result:= 'ANSI_X3.4-1986';
      3: result:= 'ISO_646.irv:1991';
      4: result:= 'ASCII';
      5: result:= 'ISO646-US';
      6: result:= 'US-ASCII';
      7: result:= 'us';
      8: result:= 'IBM367';
      9: result:= 'cp367';
      10: result:= 'csASCII';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    4: case i of
      0: result:= 'ISO_8859-1:1987';
      1: result:= 'iso-ir-100';
      2: result:= 'ISO_8859-1';
      3: result:= 'ISO-8859-1';
      4: result:= 'latin1';
      5: result:= 'l1';
      6: result:= 'IBM819';
      7: result:= 'CP819';
      8: result:= 'csISOLatin1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    5: case i of
      0: result:= 'ISO_8859-2:1987';
      1: result:= 'iso-ir-101';
      2: result:= 'ISO_8859-2';
      3: result:= 'ISO-8859-2';
      4: result:= 'latin2';
      5: result:= 'l2';
      6: result:= 'csISOLatin2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    6: case i of
      0: result:= 'ISO_8859-3:1988';
      1: result:= 'iso-ir-109';
      2: result:= 'ISO_8859-3';
      3: result:= 'ISO-8859-3';
      4: result:= 'latin3';
      5: result:= 'l3';
      6: result:= 'csISOLatin3';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    7: case i of
      0: result:= 'ISO_8859-4:1988';
      1: result:= 'iso-ir-110';
      2: result:= 'ISO_8859-4';
      3: result:= 'ISO-8859-4';
      4: result:= 'latin4';
      5: result:= 'l4';
      6: result:= 'csISOLatin4';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    8: case i of
      0: result:= 'ISO_8859-5:1988';
      1: result:= 'iso-ir-144';
      2: result:= 'ISO_8859-5';
      3: result:= 'ISO-8859-5';
      4: result:= 'cyrillic';
      5: result:= 'csISOLatinCyrillic';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    9: case i of
      0: result:= 'ISO_8859-6:1987';
      1: result:= 'iso-ir-127';
      2: result:= 'ISO_8859-6';
      3: result:= 'ISO-8859-6';
      4: result:= 'ECMA-114';
      5: result:= 'ASMO-708';
      6: result:= 'arabic';
      7: result:= 'csISOLatinArabic';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    10: case i of
      0: result:= 'ISO_8859-7:1987';
      1: result:= 'iso-ir-126';
      2: result:= 'ISO_8859-7';
      3: result:= 'ISO-8859-7';
      4: result:= 'ELOT_928';
      5: result:= 'ECMA-118';
      6: result:= 'greek';
      7: result:= 'greek8';
      8: result:= 'csISOLatinGreek';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    11: case i of
      0: result:= 'ISO_8859-8:1988';
      1: result:= 'iso-ir-138';
      2: result:= 'ISO_8859-8';
      3: result:= 'ISO-8859-8';
      4: result:= 'hebrew';
      5: result:= 'csISOLatinHebrew';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    12: case i of
      0: result:= 'ISO_8859-9:1989';
      1: result:= 'iso-ir-148';
      2: result:= 'ISO_8859-9';
      3: result:= 'ISO-8859-9';
      4: result:= 'latin5';
      5: result:= 'l5';
      6: result:= 'csISOLatin5';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    13: case i of
      0: result:= 'ISO_8859-10';
      1: result:= 'iso-ir-157';
      2: result:= 'l6';
      3: result:= 'ISO-8859-10:1992';
      4: result:= 'csISOLatin6';
      5: result:= 'latin6';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    14: case i of
      0: result:= 'ISO_6937-2-add';
      1: result:= 'iso-ir-142';
      2: result:= 'csISOTextComm';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    15: case i of
      0: result:= 'JIS_X0201';
      1: result:= 'X0201';
      2: result:= 'csHalfWidthKatakana';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    16: case i of
      0: result:= 'JIS_Encoding';
      1: result:= 'csJISEncoding';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    17: case i of
      0: result:= 'Shift_JIS';
      1: result:= 'MS_Kanji';
      2: result:= 'csShiftJIS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    18: case i of
      0: result:= 'Extended_UNIX_Code_Packed_Format_for_Japanese';
      1: result:= 'csEUCPPkdFmtJapanese';
      2: result:= 'EUC-JP';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    19: case i of
      0: result:= 'Extended_UNIX_Code_Fixed_Width_for_Japanese';
      1: result:= 'csEUCFixWidJapanese';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    20: case i of
      0: result:= 'BS_4730';
      1: result:= 'iso-ir-4';
      2: result:= 'ISO646-GB';
      3: result:= 'gb';
      4: result:= 'uk';
      5: result:= 'csISO4UnitedKingdom';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    21: case i of
      0: result:= 'SEN_850200_C';
      1: result:= 'iso-ir-11';
      2: result:= 'ISO646-SE2';
      3: result:= 'se2';
      4: result:= 'csISO11SwedishForNames';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    22: case i of
      0: result:= 'IT';
      1: result:= 'iso-ir-15';
      2: result:= 'ISO646-IT';
      3: result:= 'csISO15Italian';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    23: case i of
      0: result:= 'ES';
      1: result:= 'iso-ir-17';
      2: result:= 'ISO646-ES';
      3: result:= 'csISO17Spanish';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    24: case i of
      0: result:= 'DIN_66003';
      1: result:= 'iso-ir-21';
      2: result:= 'de';
      3: result:= 'ISO646-DE';
      4: result:= 'csISO21German';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    25: case i of
      0: result:= 'NS_4551-1';
      1: result:= 'iso-ir-60';
      2: result:= 'ISO646-NO';
      3: result:= 'no';
      4: result:= 'csISO60Danish-Norwegian';
      5: result:= 'csISO60Norwegian1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    26: case i of
      0: result:= 'NF_Z_62-010';
      1: result:= 'iso-ir-69';
      2: result:= 'ISO646-FR';
      3: result:= 'fr';
      4: result:= 'csISO69French';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    27: case i of
      0: result:= 'ISO-10646-UTF-1';
      1: result:= 'csISO10646UTF1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    28: case i of
      0: result:= 'ISO_646.basic:1983';
      1: result:= 'ref';
      2: result:= 'csISO646basic1983';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    29: case i of
      0: result:= 'INVARIANT';
      1: result:= 'csINVARIANT';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    30: case i of
      0: result:= 'ISO_646.irv:1983';
      1: result:= 'iso-ir-2';
      2: result:= 'irv';
      3: result:= 'csISO2Int1RefVersion';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    31: case i of
      0: result:= 'NATS-SEFI';
      1: result:= 'iso-ir-8-1';
      2: result:= 'csNATSSEFI';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    32: case i of
      0: result:= 'NATS-SEFI-ADD';
      1: result:= 'iso-ir-8-2';
      2: result:= 'csNATSSEFIADD';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    33: case i of
      0: result:= 'NATS-DANO';
      1: result:= 'iso-ir-9-1';
      2: result:= 'csNATSDANO';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    34: case i of
      0: result:= 'NATS-DANO-ADD';
      1: result:= 'iso-ir-9-2';
      2: result:= 'csNATSDANOADD';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    35: case i of
      0: result:= 'SEN_850200_B';
      1: result:= 'iso-ir-10';
      2: result:= 'FI';
      3: result:= 'ISO646-FI';
      4: result:= 'ISO646-SE';
      5: result:= 'se';
      6: result:= 'csISO10Swedish';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    36: case i of
      0: result:= 'KS_C_5601-1987';
      1: result:= 'iso-ir-149';
      2: result:= 'KS_C_5601-1989';
      3: result:= 'KSC_5601';
      4: result:= 'korean';
      5: result:= 'csKSC56011987';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    37: case i of
      0: result:= 'ISO-2022-KR';
      1: result:= 'csISO2022KR';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    38: case i of
      0: result:= 'EUC-KR';
      1: result:= 'csEUCKR';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    39: case i of
      0: result:= 'ISO-2022-JP';
      1: result:= 'csISO2022JP';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    40: case i of
      0: result:= 'ISO-2022-JP-2';
      1: result:= 'csISO2022JP2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    41: case i of
      0: result:= 'JIS_C6220-1969-jp';
      1: result:= 'JIS_C6220-1969';
      2: result:= 'iso-ir-13';
      3: result:= 'katakana';
      4: result:= 'x0201-7';
      5: result:= 'csISO13JISC6220jp';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    42: case i of
      0: result:= 'JIS_C6220-1969-ro';
      1: result:= 'iso-ir-14';
      2: result:= 'jp';
      3: result:= 'ISO646-JP';
      4: result:= 'csISO14JISC6220ro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    43: case i of
      0: result:= 'PT';
      1: result:= 'iso-ir-16';
      2: result:= 'ISO646-PT';
      3: result:= 'csISO16Portuguese';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    44: case i of
      0: result:= 'greek7-old';
      1: result:= 'iso-ir-18';
      2: result:= 'csISO18Greek7Old';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    45: case i of
      0: result:= 'latin-greek';
      1: result:= 'iso-ir-19';
      2: result:= 'csISO19LatinGreek';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    46: case i of
      0: result:= 'NF_Z_62-010_(1973)';
      1: result:= 'iso-ir-25';
      2: result:= 'ISO646-FR1';
      3: result:= 'csISO25French';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    47: case i of
      0: result:= 'Latin-greek-1';
      1: result:= 'iso-ir-27';
      2: result:= 'csISO27LatinGreek1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    48: case i of
      0: result:= 'ISO_5427';
      1: result:= 'iso-ir-37';
      2: result:= 'csISO5427Cyrillic';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    49: case i of
      0: result:= 'JIS_C6226-1978';
      1: result:= 'iso-ir-42';
      2: result:= 'csISO42JISC62261978';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    50: case i of
      0: result:= 'BS_viewdata';
      1: result:= 'iso-ir-47';
      2: result:= 'csISO47BSViewdata';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    51: case i of
      0: result:= 'INIS';
      1: result:= 'iso-ir-49';
      2: result:= 'csISO49INIS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    52: case i of
      0: result:= 'INIS-8';
      1: result:= 'iso-ir-50';
      2: result:= 'csISO50INIS8';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    53: case i of
      0: result:= 'INIS-cyrillic';
      1: result:= 'iso-ir-51';
      2: result:= 'csISO51INISCyrillic';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    54: case i of
      0: result:= 'ISO_5427:1981';
      1: result:= 'iso-ir-54';
      2: result:= 'ISO5427Cyrillic1981';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    55: case i of
      0: result:= 'ISO_5428:1980';
      1: result:= 'iso-ir-55';
      2: result:= 'csISO5428Greek';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    56: case i of
      0: result:= 'GB_1988-80';
      1: result:= 'iso-ir-57';
      2: result:= 'cn';
      3: result:= 'ISO646-CN';
      4: result:= 'csISO57GB1988';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    57: case i of
      0: result:= 'GB_2312-80';
      1: result:= 'iso-ir-58';
      2: result:= 'chinese';
      3: result:= 'csISO58GB231280';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    58: case i of
      0: result:= 'NS_4551-2';
      1: result:= 'ISO646-NO2';
      2: result:= 'iso-ir-61';
      3: result:= 'no2';
      4: result:= 'csISO61Norwegian2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    59: case i of
      0: result:= 'videotex-suppl';
      1: result:= 'iso-ir-70';
      2: result:= 'csISO70VideotexSupp1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    60: case i of
      0: result:= 'PT2';
      1: result:= 'iso-ir-84';
      2: result:= 'ISO646-PT2';
      3: result:= 'csISO84Portuguese2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    61: case i of
      0: result:= 'ES2';
      1: result:= 'iso-ir-85';
      2: result:= 'ISO646-ES2';
      3: result:= 'csISO85Spanish2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    62: case i of
      0: result:= 'MSZ_7795.3';
      1: result:= 'iso-ir-86';
      2: result:= 'ISO646-HU';
      3: result:= 'hu';
      4: result:= 'csISO86Hungarian';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    63: case i of
      0: result:= 'JIS_C6226-1983';
      1: result:= 'iso-ir-87';
      2: result:= 'x0208';
      3: result:= 'JIS_X0208-1983';
      4: result:= 'csISO87JISX0208';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    64: case i of
      0: result:= 'greek7';
      1: result:= 'iso-ir-88';
      2: result:= 'csISO88Greek7';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    65: case i of
      0: result:= 'ASMO_449';
      1: result:= 'ISO_9036';
      2: result:= 'arabic7';
      3: result:= 'iso-ir-89';
      4: result:= 'csISO89ASMO449';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    66: case i of
      0: result:= 'iso-ir-90';
      1: result:= 'csISO90';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    67: case i of
      0: result:= 'JIS_C6229-1984-a';
      1: result:= 'iso-ir-91';
      2: result:= 'jp-ocr-a';
      3: result:= 'csISO91JISC62291984a';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    68: case i of
      0: result:= 'JIS_C6229-1984-b';
      1: result:= 'iso-ir-92';
      2: result:= 'ISO646-JP-OCR-B';
      3: result:= 'jp-ocr-b';
      4: result:= 'csISO92JISC62291984b';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    69: case i of
      0: result:= 'JIS_C6229-1984-b-add';
      1: result:= 'iso-ir-93';
      2: result:= 'jp-ocr-b-add';
      3: result:= 'csISO93JISC62291984badd';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    70: case i of
      0: result:= 'JIS_C6229-1984-hand';
      1: result:= 'iso-ir-94';
      2: result:= 'jp-ocr-hand';
      3: result:= 'csISO94JISC62291984hand';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    71: case i of
      0: result:= 'JIS_C6229-1984-hand-add';
      1: result:= 'iso-ir-95';
      2: result:= 'jp-ocr-hand-add';
      3: result:= 'csISO95JISC62291984handadd';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    72: case i of
      0: result:= 'JIS_C6229-1984-kana';
      1: result:= 'iso-ir-96';
      2: result:= 'jp-ocr-hand';
      3: result:= 'csISO96JISC62291984kana';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    73: case i of
      0: result:= 'ISO_2033-1983';
      1: result:= 'iso-ir-98';
      2: result:= 'e13b';
      3: result:= 'csISO2033';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    74: case i of
      0: result:= 'ANSI_X3.110-1983';
      1: result:= 'iso-ir-99';
      2: result:= 'CSA_T500-1983';
      3: result:= 'NAPLPS';
      4: result:= 'csISO99NAPLPS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    75: case i of
      0: result:= 'T.61-7bit';
      1: result:= 'iso-ir-102';
      2: result:= 'csISO102T617bit';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    76: case i of
      0: result:= 'T.61-8bit';
      1: result:= 'T.61';
      2: result:= 'iso-ir-103';
      3: result:= 'csISO103T618bit';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    77: case i of
      0: result:= 'ECMA-cyrillic';
      1: result:= 'iso-ir-111';
      2: result:= 'csISO111ECMACyrillic';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    78: case i of
      0: result:= 'CSA_Z243.4-1985-1';
      1: result:= 'iso-ir-121';
      2: result:= 'ISO646-CA';
      3: result:= 'csa7-1';
      4: result:= 'ca';
      5: result:= 'csISO121Canadian1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    79: case i of
      0: result:= 'CSA_Z243.4-1985-2';
      1: result:= 'iso-ir-122';
      2: result:= 'ISO646-CA2';
      3: result:= 'csa7-2';
      4: result:= 'csISO122Canadian2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    80: case i of
      0: result:= 'CSA_Z243.4-1985-gr';
      1: result:= 'iso-ir-123';
      2: result:= 'csISO123CSAZ24341985gr';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    81: case i of
      0: result:= 'ISO_8859-6-E';
      1: result:= 'csISO88596E';
      2: result:= 'ISO-8859-6-E';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    82: case i of
      0: result:= 'ISO_8859-6-I';
      1: result:= 'csISO88596I';
      2: result:= 'ISO-8859-6-I';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    83: case i of
      0: result:= 'T.101-G2';
      1: result:= 'iso-ir-128';
      2: result:= 'csISO128T101G2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    84: case i of
      0: result:= 'ISO_8859-8-E';
      1: result:= 'csISO88598E';
      2: result:= 'ISO-8859-8-E';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    85: case i of
      0: result:= 'ISO_8859-8-I';
      1: result:= 'csISO88598I';
      2: result:= 'ISO-8859-8-I';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    86: case i of
      0: result:= 'CSN_369103';
      1: result:= 'iso-ir-139';
      2: result:= 'csISO139CSN369103';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    87: case i of
      0: result:= 'JUS_I.B1.002';
      1: result:= 'iso-ir-141';
      2: result:= 'ISO646-YU';
      3: result:= 'js';
      4: result:= 'yu';
      5: result:= 'csISO141JUSIB1002';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    88: case i of
      0: result:= 'IEC_P27-1';
      1: result:= 'iso-ir-143';
      2: result:= 'csISO143IECP271';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    89: case i of
      0: result:= 'JUS_I.B1.003-serb';
      1: result:= 'iso-ir-146';
      2: result:= 'serbian';
      3: result:= 'csISO146Serbian';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    90: case i of
      0: result:= 'JUS_I.B1.003-mac';
      1: result:= 'macedonian';
      2: result:= 'iso-ir-147';
      3: result:= 'csISO147Macedonian';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    91: case i of
      0: result:= 'greek-ccitt';
      1: result:= 'iso-ir-150';
      2: result:= 'csISO150';
      3: result:= 'csISO150GreekCCITT';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    92: case i of
      0: result:= 'NC_NC00-10:81';
      1: result:= 'cuba';
      2: result:= 'iso-ir-151';
      3: result:= 'ISO646-CU';
      4: result:= 'csISO151Cuba';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    93: case i of
      0: result:= 'ISO_6937-2-25';
      1: result:= 'iso-ir-152';
      2: result:= 'csISO6937Add';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    94: case i of
      0: result:= 'GOST_19768-74';
      1: result:= 'ST_SEV_358-88';
      2: result:= 'iso-ir-153';
      3: result:= 'csISO153GOST1976874';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    95: case i of
      0: result:= 'ISO_8859-supp';
      1: result:= 'iso-ir-154';
      2: result:= 'latin1-2-5';
      3: result:= 'csISO8859Supp';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    96: case i of
      0: result:= 'ISO_10367-box';
      1: result:= 'iso-ir-155';
      2: result:= 'csISO10367Box';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    97: case i of
      0: result:= 'latin-lap';
      1: result:= 'lap';
      2: result:= 'iso-ir-158';
      3: result:= 'csISO158Lap';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    98: case i of
      0: result:= 'JIS_X0212-1990';
      1: result:= 'x0212';
      2: result:= 'iso-ir-159';
      3: result:= 'csISO159JISX02121990';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    99: case i of
      0: result:= 'DS_2089';
      1: result:= 'DS2089';
      2: result:= 'ISO646-DK';
      3: result:= 'dk';
      4: result:= 'csISO646Danish';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    100: case i of
      0: result:= 'us-dk';
      1: result:= 'csUSDK';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    101: case i of
      0: result:= 'dk-us';
      1: result:= 'csDKUS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    102: case i of
      0: result:= 'KSC5636';
      1: result:= 'ISO646-KR';
      2: result:= 'csKSC5636';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    103: case i of
      0: result:= 'UNICODE-1-1-UTF-7';
      1: result:= 'csUnicode11UTF7';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    104: case i of
      0: result:= 'ISO-2022-CN';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    105: case i of
      0: result:= 'ISO-2022-CN-EXT';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    106: case i of
      0: result:= 'UTF-8';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    109: case i of
      0: result:= 'ISO-8859-13';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    110: case i of
      0: result:= 'ISO-8859-14';
      1: result:= 'iso-ir-199';
      2: result:= 'ISO_8859-14:1998';
      3: result:= 'ISO_8859-14';
      4: result:= 'latin8';
      5: result:= 'iso-celtic';
      6: result:= 'l8';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    111: case i of
      0: result:= 'ISO-8859-15';
      1: result:= 'ISO_8869-15';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    112: case i of
      0: result:= 'ISO-8859-16';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1000: case i of
      0: result:= 'ISO-10646-UCS-2';
      1: result:= 'csUnicode';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1001: case i of
      0: result:= 'ISO-10646-UCS-4';
      1: result:= 'csUCS4';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1002: case i of
      0: result:= 'ISO-10646-UCS-Basic';
      1: result:= 'csUnicodeASCII';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1003: case i of
      0: result:= 'ISO-10646-Unicode-Latin1';
      1: result:= 'csUnicodeLatin1';
      2: result:= 'ISO-10646';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1004: case i of
      0: result:= 'ISO-10646-J-1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1005: case i of
      0: result:= 'ISO-Unicode-IBM-1261';
      1: result:= 'csUnicodeIBM1261';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1006: case i of
      0: result:= 'ISO-Unicode-IBM-1268';
      1: result:= 'csUnicodeIBM1268';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1007: case i of
      0: result:= 'ISO-Unicode-IBM-1276';
      1: result:= 'csUnicodeIBM1276';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1008: case i of
      0: result:= 'ISO-Unicode-IBM-1264';
      1: result:= 'csUnicodeIBM1264';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1009: case i of
      0: result:= 'ISO-Unicode-IBM-1265';
      1: result:= 'csUnicodeIBM1265';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1010: case i of
      0: result:= 'UNICODE-1-1';
      1: result:= 'csUnicode11';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1011: case i of
      0: result:= 'SCSU';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1012: case i of
      0: result:= 'UTF-7';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1013: case i of
      0: result:= 'UTF-16BE';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1014: case i of
      0: result:= 'UTF-16LE';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    1015: case i of
      0: result:= 'UTF-16';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2000: case i of
      0: result:= 'ISO-8859-1-Windows-3.0-Latin-1';
      1: result:= 'csWindows30Latin1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2001: case i of
      0: result:= 'ISO-8859-1-Windows-3.1-Latin-1';
      1: result:= 'csWindows31Latin1';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2002: case i of
      0: result:= 'ISO-8859-2-Windows-Latin-2';
      1: result:= 'csWindows31Latin2';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2003: case i of
      0: result:= 'ISO-8859-9-Windows-Latin-5';
      1: result:= 'csWindows31Latin5';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2004: case i of
      0: result:= 'hp-roman8';
      1: result:= 'roman8';
      2: result:= 'r8';
      3: result:= 'csHPRoman8';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2005: case i of
      0: result:= 'Adobe-Standard-Encoding';
      1: result:= 'csAdobeStandardEncoding';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2006: case i of
      0: result:= 'Ventura-US';
      1: result:= 'csVenturaUS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2007: case i of
      0: result:= 'Ventura-International';
      1: result:= 'csVenturaInternational';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2008: case i of
      0: result:= 'DEC-MCS';
      1: result:= 'dec';
      2: result:= 'csDECMCS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2009: case i of
      0: result:= 'IBM850';
      1: result:= 'cp850';
      2: result:= '850';
      3: result:= 'csPC850Multilingual';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2010: case i of
      0: result:= 'IBM852';
      1: result:= 'cp852';
      2: result:= '852';
      3: result:= 'csPCp852';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2011: case i of
      0: result:= 'IBM437';
      1: result:= 'cp437';
      2: result:= '437';
      3: result:= 'csPC8CodePage437';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2012: case i of
      0: result:= 'PC8-Danish-Norwegian';
      1: result:= 'csPC8DanishNorwegian';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2013: case i of
      0: result:= 'IBM862';
      1: result:= 'cp862';
      2: result:= '862';
      3: result:= 'csPC862LatinHebrew';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2014: case i of
      0: result:= 'PC8-Turkish';
      1: result:= 'csPC8Turkish';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2015: case i of
      0: result:= 'IBM-Symbols';
      1: result:= 'csIBMSymbols';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2016: case i of
      0: result:= 'IBM-Thai';
      1: result:= 'csIBMThai';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2017: case i of
      0: result:= 'HP-Legal';
      1: result:= 'csHPLegal';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2018: case i of
      0: result:= 'HP-Pi-font';
      1: result:= 'csHPPiFont';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2019: case i of
      0: result:= 'HP-Math8';
      1: result:= 'csHPMath8';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2020: case i of
      0: result:= 'Adobe-Symbol-Encoding';
      1: result:= 'csHPPSMath';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2021: case i of
      0: result:= 'HP-DeskTop';
      1: result:= 'csHPDesktop';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2022: case i of
      0: result:= 'Ventura-Math';
      1: result:= 'csVenturaMath';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2023: case i of
      0: result:= 'Microsoft-Publishing';
      1: result:= 'csMicrosoftPublishing';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2024: case i of
      0: result:= 'Windows-31J';
      1: result:= 'csWindows31J';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2025: case i of
      0: result:= 'GB2312';
      1: result:= 'csGB2312';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2026: case i of
      0: result:= 'Big5';
      1: result:= 'csBig5';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2027: case i of
      0: result:= 'macintosh';
      1: result:= 'mac';
      2: result:= 'csMacintosh';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2028: case i of
      0: result:= 'IBM037';
      1: result:= 'cp037';
      2: result:= 'ebcdic-cp-us';
      3: result:= 'ebcdic-cp-ca';
      4: result:= 'ebcdic-cp-wt';
      5: result:= 'ebcdic-cp-nl';
      6: result:= 'csIBM037';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2029: case i of
      0: result:= 'IBM038';
      1: result:= 'EBCDIC-INT';
      2: result:= 'cp038';
      3: result:= 'csIBM038';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2030: case i of
      0: result:= 'IBM273';
      1: result:= 'CP273';
      2: result:= 'csIBM273';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2031: case i of
      0: result:= 'IBM274';
      1: result:= 'EBCDIC-BE';
      2: result:= 'CP274';
      3: result:= 'csIBM274';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2032: case i of
      0: result:= 'IBM275';
      1: result:= 'EBCDIC-BR';
      2: result:= 'cp275';
      3: result:= 'csIBM275';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2033: case i of
      0: result:= 'IBM277';
      1: result:= 'EBCDIC-CP-DK';
      2: result:= 'EBCDIC-CP-NO';
      3: result:= 'csIBM277';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2034: case i of
      0: result:= 'IBM278';
      1: result:= 'CP278';
      2: result:= 'ebcdic-cp-fi';
      3: result:= 'ebcdic-cp-se';
      4: result:= 'csIBM278';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2035: case i of
      0: result:= 'IBM280';
      1: result:= 'CP280';
      2: result:= 'ebcdic-cp-it';
      3: result:= 'csIBM280';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2036: case i of
      0: result:= 'IBM281';
      1: result:= 'EBCDIC-JP-E';
      2: result:= 'cp281';
      3: result:= 'csIBM281';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2037: case i of
      0: result:= 'IBM284';
      1: result:= 'CP284';
      2: result:= 'ebcdic-cp-es';
      3: result:= 'csIBM284';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2038: case i of
      0: result:= 'IBM285';
      1: result:= 'CP285';
      2: result:= 'ebcdic-cp-gb';
      3: result:= 'csIBM285';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2039: case i of
      0: result:= 'IBM290';
      1: result:= 'cp290';
      2: result:= 'EBCDIC-JP-kana';
      3: result:= 'csIBM290';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2040: case i of
      0: result:= 'IBM297';
      1: result:= 'cp297';
      2: result:= 'ebcdic-cp-fr';
      3: result:= 'csIBM297';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2041: case i of
      0: result:= 'IBM420';
      1: result:= 'cp420';
      2: result:= 'ebcdic-cp-ar1';
      3: result:= 'csIBM420';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2042: case i of
      0: result:= 'IBM423';
      1: result:= 'cp423';
      2: result:= 'ebcdic-cp-gr';
      3: result:= 'csIBM423';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2043: case i of
      0: result:= 'IBM424';
      1: result:= 'cp424';
      2: result:= 'ebcdic-cp-he';
      3: result:= 'csIBM424';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2044: case i of
      0: result:= 'IBM500';
      1: result:= 'CP500';
      2: result:= 'ebcdic-cp-be';
      3: result:= 'ebcdic-cp-ch';
      4: result:= 'csIBM500';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2045: case i of
      0: result:= 'IBM851';
      1: result:= 'cp851';
      2: result:= '851';
      3: result:= 'csIBM851';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2046: case i of
      0: result:= 'IBM855';
      1: result:= 'cp855';
      2: result:= '855';
      3: result:= 'csIBM855';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2047: case i of
      0: result:= 'IBM857';
      1: result:= 'cp857';
      2: result:= '857';
      3: result:= 'csIBM857';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2048: case i of
      0: result:= 'IBM860';
      1: result:= 'cp860';
      2: result:= '860';
      3: result:= 'csIBM860';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2049: case i of
      0: result:= 'IBM861';
      1: result:= 'cp861';
      2: result:= '861';
      3: result:= 'cp-is';
      4: result:= 'csIBM861';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2050: case i of
      0: result:= 'IBM863';
      1: result:= 'cp863';
      2: result:= '863';
      3: result:= 'csIBM863';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2051: case i of
      0: result:= 'IBM864';
      1: result:= 'cp864';
      2: result:= 'csIBM864';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2052: case i of
      0: result:= 'IBM865';
      1: result:= 'cp865';
      2: result:= '865';
      3: result:= 'csIBM865';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2053: case i of
      0: result:= 'IBM868';
      1: result:= 'CP868';
      2: result:= 'cp-ar';
      3: result:= 'csIBM868';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2054: case i of
      0: result:= 'IBM869';
      1: result:= 'cp869';
      2: result:= '869';
      3: result:= 'cp-gr';
      4: result:= 'csIBM869';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2055: case i of
      0: result:= 'IBM870';
      1: result:= 'CP870';
      2: result:= 'ebcdic-cp-roece';
      3: result:= 'ebcdic-cp-yu';
      4: result:= 'csIBM870';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2056: case i of
      0: result:= 'IBM871';
      1: result:= 'CP871';
      2: result:= 'ebcdic-cp-is';
      3: result:= 'csIBM871';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2057: case i of
      0: result:= 'IBM880';
      1: result:= 'cp880';
      2: result:= 'EBCDIC-Cyrillic';
      3: result:= 'csIBM880';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2058: case i of
      0: result:= 'IBM891';
      1: result:= 'cp891';
      2: result:= 'csIBM891';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2059: case i of
      0: result:= 'IBM903';
      1: result:= 'cp903';
      2: result:= 'csIBM903';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2060: case i of
      0: result:= 'IBM904';
      1: result:= 'cp904';
      2: result:= '904';
      3: result:= 'csIBM904';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2061: case i of
      0: result:= 'IBM905';
      1: result:= 'CP905';
      2: result:= 'ebcdic-cp-tr';
      3: result:= 'csIBM905';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2062: case i of
      0: result:= 'IBM918';
      1: result:= 'CP918';
      2: result:= 'ebcdic-cp-ar2';
      3: result:= 'csIBM918';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2063: case i of
      0: result:= 'IBM1026';
      1: result:= 'CP1026';
      2: result:= 'csIBM1026';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2064: case i of
      0: result:= 'EBCDIC-AT-DE';
      1: result:= 'csIBMEBCDICATDE';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2065: case i of
      0: result:= 'EBCDIC-AT-DE-A';
      1: result:= 'csIBMEBCDICATDEA';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2066: case i of
      0: result:= 'EBCDIC-CA-FR';
      1: result:= 'csIBMEBCDICCAFR';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2067: case i of
      0: result:= 'EBCDIC-DK-NO';
      1: result:= 'csIBMEBCDICDKNO';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2068: case i of
      0: result:= 'EBCDIC-DK-NO-A';
      1: result:= 'csIBMEBCDICDKNOA';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2069: case i of
      0: result:= 'EBCDIC-FI-SE';
      1: result:= 'csIBMEBCDICFISE';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2070: case i of
      0: result:= 'EBCDIC-FI-SE-A';
      1: result:= 'csIBMEBCDICFISEA';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2071: case i of
      0: result:= 'EBCDIC-FR';
      1: result:= 'csIBMEBCDICFR';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2072: case i of
      0: result:= 'EBCDIC-IT';
      1: result:= 'csIBMEBCDICIT';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2073: case i of
      0: result:= 'EBCDIC-PT';
      1: result:= 'csIBMEBCDICPT';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2074: case i of
      0: result:= 'EBCDIC-ES';
      1: result:= 'csIBMEBCDICES';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2075: case i of
      0: result:= 'EBCDIC-ES-A';
      1: result:= 'csIBMEBCDICESA';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2076: case i of
      0: result:= 'EBCDIC-ES-S';
      1: result:= 'csIBMEBCDICESS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2077: case i of
      0: result:= 'EBCDIC-UK';
      1: result:= 'csIBMEBCDICUK';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2078: case i of
      0: result:= 'EBCDIC-US';
      1: result:= 'csIBMEBCDICUS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2079: case i of
      0: result:= 'UNKNOWN-8BIT';
      1: result:= 'csUnkown8Bit';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2080: case i of
      0: result:= 'MNEMONIC';
      1: result:= 'csMnemonic';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2081: case i of
      0: result:= 'MNEM';
      1: result:= 'csMnem';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2082: case i of
      0: result:= 'VISCII';
      1: result:= 'csVISCII';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2083: case i of
      0: result:= 'VIQR';
      1: result:= 'csVIQR';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2084: case i of
      0: result:= 'KOI8-R';
      1: result:= 'csKOI8R';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2085: case i of
      0: result:= 'HZ-GB-2312';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2086: case i of
      0: result:= 'IBM866';
      1: result:= 'cp866';
      2: result:= '866';
      3: result:= 'csIBM866';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2087: case i of
      0: result:= 'IBM775';
      1: result:= 'cp775';
      2: result:= 'csPC775Baltic';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2088: case i of
      0: result:= 'KOI8-U';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2089: case i of
      0: result:= 'IBM00858';
      1: result:= 'CCSID00858';
      2: result:= 'CP00858';
      3: result:= 'PC-Multilingual-850+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2090: case i of
      0: result:= 'IBM00924';
      1: result:= 'CCSID00924';
      2: result:= 'CP00924';
      3: result:= 'ebcdic-Latin9--euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2091: case i of
      0: result:= 'IBM01140';
      1: result:= 'CCSID01140';
      2: result:= 'CP01140';
      3: result:= 'ebcdic-us-37+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2092: case i of
      0: result:= 'IBM01141';
      1: result:= 'CCSID01141';
      2: result:= 'CP01141';
      3: result:= 'ebcdic-de-273+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2093: case i of
      0: result:= 'IBM01142';
      1: result:= 'CCSID01142';
      2: result:= 'CP01142';
      3: result:= 'ebcdic-dk-277+euro';
      4: result:= 'ebcdic-no-277+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2094: case i of
      0: result:= 'IBM01143';
      1: result:= 'CCSID01143';
      2: result:= 'CP01143';
      3: result:= 'ebcdic-fi-278+euro';
      4: result:= 'ebcdic-se-278+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2095: case i of
      0: result:= 'IBM01144';
      1: result:= 'CCSID01144';
      2: result:= 'CP01144';
      3: result:= 'ebcdic-it-280+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2096: case i of
      0: result:= 'IBM01145';
      1: result:= 'CCSID01145';
      2: result:= 'CP01145';
      3: result:= 'ebcdic-es-284+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2097: case i of
      0: result:= 'IBM01146';
      1: result:= 'CCSID01146';
      2: result:= 'CP01146';
      3: result:= 'ebcdic-gb-285+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2098: case i of
      0: result:= 'IBM01147';
      1: result:= 'CCSID01147';
      2: result:= 'CP01147';
      3: result:= 'ebcdic-fr-297+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2099: case i of
      0: result:= 'IBM01148';
      1: result:= 'CCSID01148';
      2: result:= 'CP01148';
      3: result:= 'ebcdic-international-500+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2100: case i of
      0: result:= 'IBM01149';
      1: result:= 'CCSID01149';
      2: result:= 'CP01149';
      3: result:= 'ebcdic-is-871+euro';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2101: case i of
      0: result:= 'Big5-HKSCS';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2250: case i of
      0: result:= 'windows-1250';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2251: case i of
      0: result:= 'windows-1251';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2252: case i of
      0: result:= 'windows-1252';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2253: case i of
      0: result:= 'windows-1253';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2254: case i of
      0: result:= 'windows-1254';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2255: case i of
      0: result:= 'windows-1255';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2256: case i of
      0: result:= 'windows-1256';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2257: case i of
      0: result:= 'windows-1257';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2258: case i of
      0: result:= 'windows-1258';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
    2259: case i of
      0: result:= 'TIS-620';
    else
      raise ECSMIBException.Create('Invalid MIB number');
    end;
  else
    raise ECSMIBException.Create('Invalid MIB number');
  end;
end;

function TCSMIB.GetAliasCount: integer;
begin
  case FEnum of
    104..106,109,112,1004,1011..1015,2085,2088,2101,2250..2259: result:= 1;
    16,19,27,29,37..40,66,100..101,103,111,1000..1002,1005..1010,2000..2003,2005..2007,2012,2014..2026,2064..2084: result:= 2;
    14..15,17..18,28,31..34,44..45,47..55,59,64,72,75,77,80..86,88,93,96,102,1003,2008,2027,2030,2051,2058..2059,2063,2087: result:= 3;
    22..23,30,43,46,57,60..61,67,69..71,73,76,89..91,94..95,97..98,2004,2009..2011,2013,2029,2031..2033,2035..2043,2045..2048,2050,2052..2053,2056..2057,2060..2062,2086,2089..2092,2095..2100: result:= 4;
    21,24,26,42,56,58,62..63,65,68,74,79,92,99,2034,2044,2049,2054..2055,2093..2094: result:= 5;
    8,11,13,20,25,36,41,78,87: result:= 6;
    5..7,12,35,110,2028: result:= 7;
    9: result:= 8;
    4,10: result:= 9;
    3: result:= 11;
  else
    raise ECSMIBException.Create('Invalid MIB number');
  end;
end;

function TCSMIB.GetPrfMIMEName: string;
begin
  case FEnum of
  13,17,37..40,2025..2026,2084: result:= Alias[0];
  18,82,84..85: result:= Alias[2];
  4..12: result:= Alias[3];
  3: result:= Alias[6];
  else
    result:= '';
  end;
end;

function TCSMIB.IsValidEnum(const Value: integer): boolean;
begin
  case Value of
    3..106,109..112,1000..1015,2000..2101,2250..2259:
      result:= true;
  else
    result:= false;
  end;
end;

procedure TCSMIB.SetEnum(const Value: integer);
var
  AllowChange: boolean;
begin
  if IsValidEnum(Value) then begin
    if FEnum = Value then exit;
    AllowChange:= True;
    DoChanging(self,Value,AllowChange);
    if AllowChange then begin
      FEnum:= Value;
      DoChange(self);
    end;
  end else if not IgnoreInvalidEnum then begin
    raise ECSMIBException.Create('Invalid MIB number');
  end;
end;

procedure TCSMIB.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TCSMIB.SetOnChanging(const Value: TCSMIBChangingEvent);
begin
  FOnChanging := Value;
end;

function TCSMIB.SetToAlias(const S: string): boolean;
var
  i,j,oldEnum: integer;
begin
  result:= true;
  oldEnum:= Enum;
  for i:= 3 to 106 do begin
    Enum:= i;
    for j:= 0 to pred(AliasCount) do begin
      if CompareText(Alias[j],S) = 0 then exit;
    end;
  end;
  for i:= 109 to 112 do begin
    Enum:= i;
    for j:= 0 to pred(AliasCount) do begin
      if CompareText(Alias[j],S) = 0 then exit;
    end;
  end;
  for i:= 1000 to 1015 do begin
    Enum:= i;
    for j:= 0 to pred(AliasCount) do begin
      if CompareText(Alias[j],S) = 0 then exit;
    end;
  end;
  for i:= 2000 to 2101 do begin
    Enum:= i;
    for j:= 0 to pred(AliasCount) do begin
      if CompareText(Alias[j],S) = 0 then exit;
    end;
  end;
  for i:= 2250 to 2259 do begin
    Enum:= i;
    for j:= 0 to pred(AliasCount) do begin
      if CompareText(Alias[j],S) = 0 then exit;
    end;
  end;
  result:= false;
  Enum:= oldEnum;
end;

end.
