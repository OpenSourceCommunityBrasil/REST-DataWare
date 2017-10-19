{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15784: IdSoapUtilities.pas 
{
{   Rev 1.6    23/6/2003 21:29:02  GGrieve
{ fix for Linux EOL issues
}
{
{   Rev 1.5    23/6/2003 15:11:42  GGrieve
{ missed comments
}
{
{   Rev 1.3    20/6/2003 00:04:52  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.2    21/3/2003 11:37:10  GGrieve
}
{
{   Rev 1.1    25/2/2003 13:14:18  GGrieve
}
{
{   Rev 1.0    11/2/2003 20:37:10  GGrieve
}
{
IndySOAP: General Utilities used throughout the IndySOAP Library
}

{
Version History:
  23-Jun 2003   Grahame Grieve                  fix for EOL on Linux
  23-Jun 2003   Grahame Grieve                  ansi/utf-8 interconversion
  19-Jun 2003   Grahame Grieve                  various range check fixes, additions, compression, refine hash code
  21-Mar 2003   Grahame Grieve                  Add TIdSoapHashTable
  25-Feb 2003   Grahame Grieve                  Fix localisation problem (xml writing shouldn't be localised)
  17-Sep 2002   Grahame Grieve                  more utilities
  26-Jul 2002   Grahame Grieve                  D4 Compiler fixes
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  17-Aug 2002   Grahame Grieve                  Added IdStripTrailingEOL
  17-Jul 2002   Andrew Cumming                  Removed compiler warning with LLevelIsSimple uninitialised
  16-Jul 2002   Grahame Grieve                  New OpenXML version - OpenXML handles namespaces when reading
  27-Apr 2002   Grahame Grieve                  Add TIdStringList.TestValid, and MakeXMLPretty
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Fix for IDSOAP_USE_RENAMED_OPENXML not defined
  09-Apr 2002   Andrew Cumming                  Removed compiler warnings
  08-Apr 2002   Andrew Cumming                  Added some date equality test functions to prevent FP rounding errors causing problems
  08-Apr 2002   Grahame Grieve                  TIdSoapKeyList added
  03-Apr 2002   Grahame Grieve                  Class based TIdSoapDateTime
  02-Apr 2002   Grahame Grieve                  Date Time Support
  26-Mar 2002   Andrew Cumming                  Fixed D4/D5 compile errors
  26-Mar 2002   Grahame Grieve                  Tidy up
  22-Mar 2002   Andrew Cumming                  Remove dialogs unit
  22-Mar 2002   Andrew Cumming                  Added IdSoapAdjustLineBreaks for D4/D5/D6 independent line breaks
  18-Mar 2002   Andrew Cumming                  StrToBool had compile errors in D4/D5
  14-Mar 2002   Grahame Grieve                  Fix currency encoding
  12-Mar 2002   Grahame Grieve                  New testing utilities, Class TIdMemoryStream
   7-Mar 2002   Grahame Grieve                  Review assertions
  22-Feb 2002   Andrew Cumming                  Added PInteger definition for D4/D5
  15-Feb 2002   Andrew Cumming                  Fixed for re-arrangement of code in helper unit
   7-Feb 2002   Andrew Cumming                  PathDelim added for D4 compatibility
   7-Feb 2002   Grahame Grieve                  Better Error Reporting
   5-Feb 2002   Andrew Cumming                  Added TObjectList for D4 compatibility
   5-Feb 2002   Grahame Grieve                  Add IdEnumIsValid, more checking in Enumeration routines
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release
}

unit IdSoapUtilities;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  {$IFNDEF DELPHI4}
  Contnrs,
  {$ENDIF}
  IdSoapDebug,
  SyncObjs,
  TypInfo,
  {$IFDEF LINUX}
  Libc;
  {$ELSE}
  windows;
  {$ENDIF}

type
  TIdStringList = class(TStringList)
  Private
    FOwnsObjects: Boolean;
  Public
    constructor Create(AOwnsObjects: Boolean = False);
    destructor Destroy; Override;
    procedure Clear; Override;
    procedure Delete(AIndex: Integer); Override;
    property OwnsObjects: Boolean Read FOwnsObjects Write FOwnsObjects;
    function TestValid(AClassType: TClass = NIL): Boolean;
  end;

  { there is potential leak in the use of TMemoryStreams on the client.
    TIdMemoryStream connects to the IndySoap object tracking to help catch
    leaks }
  TIdMemoryStream = class(TMemoryStream)
  Private
    FSerialNo: Integer;
  Public
    constructor Create;
    destructor Destroy; Override;
    function TestValid(AClassType: TClass = NIL): Boolean;
  end;

  TIdCriticalSection = class(TSynchroObject)
  Protected
    FSection: TRTLCriticalSection;
    FOwnerThread: Cardinal;
    FOwnerThreadCount: Cardinal;
  Public
    constructor Create;
    destructor Destroy; Override;
    procedure Acquire; Override;
    procedure Release; Override;
    procedure Enter;
    procedure Leave;
    function LockedToMe: Boolean;
  end;

const
  DEFAULT_HASH_SIZE = 100;
  DEFAULT_ALLOCATION_SIZE = 16;
  LF = #10;
  CR = #13;

  EOL_LINUX = LF;
  EOL_WINDOWS = CR + LF;
  {$IFDEF LINUX}
  EOL_PLATFORM = EOL_LINUX;
  {$ELSE}
  EOL_PLATFORM = EOL_WINDOWS;
  {$ENDIF}

  //
  CHAR0 = #0;
  BACKSPACE = #8;

  TAB = #9;
  CHAR32 = #32;

type
  TOnIdSoapKeyListDisposeEvent = procedure(ASender: TObject; APtr: pointer) of object;

  TIdSoapKeyList = class;

  TIdSoapPair = record
    key: Cardinal;
    Value: Integer;
  end;

  TIdSoapPairArray = array [0..MAXINT div (sizeof(TIdSoapPair) * 2)] of TIdSoapPair;
  pIdSoapPairArray = ^TIdSoapPairArray;

  TIdSoapKeyListSection = class(TIdBaseObject)
  Private
    FCount,
    FAllocated: Integer;
    FItems: pIdSoapPairArray;
    FList: TIdSoapKeyList;
    procedure Grow;
    function FindItem(AKey: Cardinal; var VIndex: Integer): Boolean;
    procedure AddItem(AKey: Cardinal; AValue: Integer);
    function GetItem(AKey: Cardinal; ADefaultValue: Integer): Integer;
    procedure Delete(AKey: Cardinal);
  Public
    constructor Create(AOwner: TIdSoapKeyList);
    destructor Destroy; Override;
  end;

  TIdSoapSectionList = array [0..(MAXINT - 4) div sizeof(TIdSoapKeyListSection)] of TIdSoapKeyListSection;
  pIdSoapSectionList = ^TIdSoapSectionList;

  TIdSoapKeyProgressRec = record
    Step1, Step2: Integer;
  end;

  TIdSoapKeyList = class(TIdBaseObject)
  Private
    FHashSize: Integer;
    FHashTable: pIdSoapSectionList;

    FMemoryUsage: Cardinal;
    FOnDispose: TOnIdSoapKeyListDisposeEvent;
    FCount: Cardinal;

    function GetAsInt(AKey: Cardinal): Integer;
    function GetAsPointer(AKey: Cardinal): pointer;
    function GetAsObj(AKey: Cardinal): TObject;
    procedure SetAsInt(AKey: Cardinal; const AValue: Integer);
    procedure SetAsPointer(AKey: Cardinal; const AValue: pointer);
    procedure SetAsObj(AKey: Cardinal; const AValue: TObject);
    procedure init(AHashSize: Cardinal);
    function GetExists(AKey: Cardinal): Boolean;
  Public
    constructor Create(AHashSize: Integer = DEFAULT_HASH_SIZE);
    destructor Destroy; Override;
    property HashSize: Integer Read FHashSize;
    property MemoryUsage: Cardinal Read FMemoryUsage;
    property AsPtr[AKey: Cardinal]: pointer Read GetAsPointer Write SetAsPointer;
    property AsInt[AKey: Cardinal]: Integer Read GetAsInt Write SetAsInt;
    property AsObj[AKey: Cardinal]: TObject Read GetAsObj Write SetAsObj; default;
    property Exists[AKey: Cardinal]: Boolean Read GetExists;
    property Count: Cardinal Read FCount;
    property OnDispose: TOnIdSoapKeyListDisposeEvent Read FOnDispose Write FOnDispose;
    procedure DisposeObject(ASender: TObject; APtr: pointer);
    procedure Delete(AKey: Cardinal);
    function GetFirstKey(var VProgressRec: TIdSoapKeyProgressRec; var VKey: Cardinal): Boolean;
    function GetNextKey(var VProgressRec: TIdSoapKeyProgressRec; var VKey: Cardinal): Boolean;
    procedure Clear;
  end;

  TIdSoapHashItem = record
    FKey : TIdBaseObject;
    FValue: Integer;
  end;

  {
  This class is also known as TIdRatherBeUsingJava internally at Kestral.
  It was created because of the steady bleating of some javaphiles, who think
  that java is better than pascal (even after they've read http://www.mindprod.com/gotchas.html),
  and said that this functionality is one of the things they most miss.

  And, of course, in a few respects, java has features that we'd love to have:
  * proper cross-platform xml support
  * generics (finally)
  * interfaces and objects using the same lifecycle metaphor
  and for all I know, JUnit actually works properly (unlike DUnit)

  and now, you probably want to know what it does? Read the IndySoap doco.
  }
  TIdSoapHashTable = class (TIdBaseObject)
  private
    FHash : TIdSoapKeyList;
    FOnDispose: TOnIdSoapKeyListDisposeEvent;
    FCaseSensitive : boolean;
    function GetAsInt(AObj: TIdBaseObject): Integer;
    function GetAsPointer(AObj: TIdBaseObject): pointer;
    function GetAsObj(AObj: TIdBaseObject): TObject;
    procedure SetAsInt(AObj: TIdBaseObject; const AValue: Integer);
    procedure SetAsPointer(AObj: TIdBaseObject; const AValue: pointer);
    procedure SetAsObj(AObj: TIdBaseObject; const AValue: TObject);
    function GetAsIntSt(AStr: string): Integer;
    function GetAsObjSt(AStr: string): TObject;
    function GetAsPointerSt(AStr: string): pointer;
    procedure SetAsIntSt(AStr: string; const AValue: Integer);
    procedure SetAsObjSt(AStr: string; const AValue: TObject);
    procedure SetAsPointerSt(AStr: string; const AValue: pointer);
    function GetExists(AObj: TIdBaseObject): Boolean;
    function GetExistsSt(AStr: string): Boolean;
    procedure DisposeItem(AItem : TIdSoapHashItem);
  public
    constructor create(AHashSize: Integer = DEFAULT_HASH_SIZE);
    destructor destroy; override;
    property CaseSensitive : boolean read FCaseSensitive write FCaseSensitive;
    property AsPtr[AObj: TIdBaseObject]: pointer Read GetAsPointer Write SetAsPointer;
    property AsInt[AObj: TIdBaseObject]: Integer Read GetAsInt Write SetAsInt;
    property AsObj[AObj: TIdBaseObject]: TObject Read GetAsObj Write SetAsObj;
    property AsPtrSt[AStr: string]: pointer Read GetAsPointerSt Write SetAsPointerSt;
    property AsIntSt[AStr: string]: Integer Read GetAsIntSt Write SetAsIntSt;
    property AsObjSt[AStr: string]: TObject Read GetAsObjSt Write SetAsObjSt; default;
    property Exists[AObj: TIdBaseObject]: Boolean Read GetExists;
    property ExistsSt[AStr: string]: Boolean Read GetExistsSt;
    property OnDispose: TOnIdSoapKeyListDisposeEvent Read FOnDispose Write FOnDispose;
    procedure DisposeObject(ASender: TObject; APtr: pointer);
    procedure Delete(AObj: TIdBaseObject);
    procedure DeleteSt(AStr: string);
    procedure Clear;
  end;

  // used internally by the HashTable when handling strings. exposed for external use if desired
  TIdSoapHashString = class (TIdBaseObject)
  private
    FValue : string;
    FHash : integer;
    FOwned : boolean;
  public
    Constructor create(AValue : string; ACaseSensitive : boolean; AOwned : boolean = false);
    function idHash : integer; override;
    function idIsEqual(AObj : TIdBaseObject) : boolean; override;
  end;

{$IFDEF DELPHI4}

const
  PathDelim = '\';

type
  { not to be used outside of IndySoap as this is a minimal implementation }
  TObjectList = class(TList)
  Private
    FOwnsObjects: Boolean;
    function GetItems(AIndex: Integer): TObject;
  Public
    constructor Create(AOwnsObjects: Boolean = False);
    destructor Destroy; Override;
    property OwnsObjects: Boolean Read FOwnsObjects Write FOwnsObjects;
    property Items[AIndex: Integer]: TObject Read GetItems; Default;
    function Extract(AIndex: Pointer): TObject;
  end;
  {$ENDIF}

function IdStrToIntWithError(const AStr, AError: String): Integer;
function IdStrToIntWithErrorAndRange(ALowValue, AHighValue: Integer; const AStr, AError: String): Integer;

function IdStrToInt64WithError(const AStr, AError: String): Int64;
function IdStrToInt64WithErrorAndRange(ALowValue, AHighValue: Int64; const AStr, AError: String): Int64;

function IdStrToSingleWithError(const AStr, AError: String): Single;
function IdStrToDoubleWithError(const AStr, AError: String): Double;
function IdStrToCompWithError(const AStr, AError: String): Comp;
function IdStrToExtendedWithError(const AStr, AError: String): Extended;
function IdStrToCurrencyWithError(AStr, AError: String): Currency;

function IdSingleToStr(AValue: Single): String;
function IdDoubleToStr(AValue: Double): String;
function IdCompToStr(AValue: Comp): String;
function IdExtendedToStr(AValue: Extended): String;
function IdCurrencyToStr(AValue: Currency): String;

procedure IdRequire(ACondition: Boolean; AComment: String);

  // these exist because the borland equivalents in TypInfo failed dunit testing
function IdEnumIsValid(ATypeInfo: PTypeInfo; AIndex: Integer): Boolean;
function IdEnumStrIsValid(ATypeInfo: PTypeInfo; AValue : string): Boolean;
function IdEnumToString(ATypeInfo: PTypeInfo; AIndex: Integer): String;
function IdStringToEnum(ATypeInfo: PTypeInfo; const AStr: String): Integer;
function IdStripTrailingEOL(AValue: String): String;
function IdStripLeadingEOL(AValue: String): String;
function IdStripTrailingWhitespace(AValue: String): String;
function IdStripLeadingWhitespace(AValue: String): String;
function IdCheckURIValid(AValue: String; var VErrorMessage: String): Boolean;

function BoolToXML(AValue: Boolean; AExtra: Boolean = True): String;
function XMLToBool(const AName: String): Boolean;

  {$IFNDEF VCL5ORABOVE}
procedure FreeAndNil(var Obj);
function AnsiSameText(const S1, S2: String): Boolean;
  {$ENDIF}
  {$IFDEF DELPHI4OR5}
function BoolToStr(AValue: Boolean; AExtra: Boolean = True): String;
function StrToBool(const AName: String): Boolean;
procedure Sleep(ATime: Cardinal);

type
  PInteger = ^Integer;

  {$ENDIF}

  // This is kept even for non-D4 in case anyone wishes to code for D4-D6 easier
function IdSoapD4Interface(AObject: TObject): IUnknown;

type
  TIdSoapTextLineBreakStyle = (tislbsLF, tislbsCRLF);

function IdSoapAdjustLineBreaks(const AStr: String; AStyle: TIdSoapTextLineBreakStyle): String;

  // TDateTime comparisons. The milliseconds can have floating point reounding errors that make
  //                        a direct compare of no use if equality is important. The routines
  //                        provide for a correct equality test.
  //                        The IdSoapSameDate was included for completenes.
function IdSoapSameDateTime(const ADateTime1, ADateTime2: TDateTime; AMatchMillisecond : Boolean = true): Boolean;
function IdSoapSameDate(const ADateTime1, ADateTime2: TDateTime): Boolean;
function IdSoapSameTime(const ADateTime1, ADateTime2: TDateTime): Boolean;

function IdSoapTestNodeValid(ANode: TObject; AClassType: TClass): Boolean;

function IdSoapMakeXmlPretty(ASrc: String): String;

function Max(AValueOne, AValueTwo: Integer): Integer;
function Min(AValueOne, AValueTwo: Integer): Integer;

  // SplitString splits a string into left and right parts,
  // i.e. SplitString('Namespace:tag', ':'..) will return 'Namespace' and 'Tag'
procedure SplitString(const AStr, AToken: String; var VLeft, VRight: String);

  // commaadd will append AStr2 to the right of AStr1 and return the result.
  // if there is any content in AStr1, a comma will be added
function CommaAdd(const AStr1, AStr2: String): String;

procedure IdSoapHexToBin(AHex: String; ABin: TMemoryStream);
function  IdSoapBinToHex(ABin : TMemoryStream):String;

function IdSoapStringHash(const AValue : string):Integer;

function ZLibSupported : boolean;
procedure ZCompressStream(AStream : TMemoryStream);
procedure ZDeCompressStream(AStream : TMemoryStream);

function IdSoapAnsiToUTF8(AStr : String):String;
function IdSoapUTF8ToAnsi(AStr : String):String;
implementation

uses
  IdSoapExceptions,
  IdSoapOpenXmlUCL,
  IdSoapPointerManipulator,
  IdSoapResourceStrings,
  SysUtils
  {$IFDEF ID_SOAP_COMPRESSION}, ZLib {$ENDIF}
  ;

const
  ASSERT_UNIT = 'IdSoapUtilities';

{$IFDEF SMARTERRORS}
{ Code from DUnit, ta DUnit }
function IsBadPointer(P: Pointer): Boolean; Register;
begin
  try
    Result := (p = NIL) or ((Pointer(P^) <> P) and (Pointer(P^) = P));
  except
    Result := False
    end
end;

function CallerAddr: Pointer; Assembler;
const
  CallerIP = $4;
asm
   mov   eax, ebp
   call  IsBadPointer
   test  eax,eax
   jne   @@Error

   mov   eax, [ebp].CallerIP
   sub   eax, 5   // 5 bytes for call

   push  eax
   call  IsBadPointer
   test  eax,eax
   pop   eax
   je    @@Finish

@@Error:
   xor eax, eax
@@Finish:
end;
{$ENDIF}

function IdSoapAdjustLineBreaks(const AStr: String; AStyle: TIdSoapTextLineBreakStyle): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapAdjustLineBreaks';
  {$IFDEF DELPHI4OR5}
var
  i, LLen: Integer;
  LTmp: String;
  {$ENDIF}
begin
  {$IFDEF DELPHI4OR5}
  LTmp := AStr + ' ';
  LLen := length(AStr);
  case AStyle of
    tislbsLF:
      begin
      Result := '';
      i := 1;
      while i <= LLen do
        begin
        case AStr[i] of
          #13:
            begin
            if (i = LLen) or (AStr[i + 1] <> #10) then
              Result := Result + #10;
            end;
          #10:
            begin
            Result := Result + #10;
            if (i < LLen) and (AStr[i + 1] = #13) then
              Inc(i);
            end;
          else
            begin
            Result := Result + AStr[i];
            end;
          end;
        inc(i);
        end;
      end;
    tislbsCRLF:
      begin
      Result := AdjustLineBreaks(AStr);
      end;
    else
      begin
      raise EIdSoapRequirementFail.Create(ASSERT_LOCATION + ': Invalid style ' + IntToStr(Ord(AStyle)) + ' used in IdSoapAdjustLineBreaks') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
      end;
    end;
  {$ELSE}
  case AStyle of
    tislbsLF:
      begin
      Result := AdjustLineBreaks(AStr, tlbsLF);
      end;
    tislbsCRLF:
      begin
      Result := AdjustLineBreaks(AStr, tlbsCRLF);
      end;
    else
      begin
      raise EIdSoapRequirementFail.Create(ASSERT_LOCATION + ': Invalid style ' + IntToStr(Ord(AStyle)) + ' used in IdSoapAdjustLineBreaks') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
      end;
    end;
  {$ENDIF}
end;

function IdSoapD4Interface(AObject: TObject): IUnknown;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapD4Interface';
begin
  if not AObject.GetInterface(IUnknown, Result) then
    raise EIdSoapRequirementFail.Create(ASSERT_LOCATION + ': Interface not supported') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
end;

{$IFDEF DELPHI4}
constructor TObjectList.Create(AOwnsObjects: Boolean);
begin
  inherited Create;
  OwnsObjects := AOwnsObjects;
end;

destructor TObjectList.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TObjectList.Destroy';
var
  LIndex: Integer;
begin
  if OwnsObjects then
    begin
    for LIndex := 0 to Count - 1 do
      TObject(Items[LIndex]).Free;
    end;
  inherited;
end;

function TObjectList.Extract(AIndex: Pointer): TObject;
var
  I: Integer;
begin
  Result := NIL;
  I := IndexOf(AIndex);
  if I >= 0 then
    begin
    Result := AIndex;
    Put(I, NIL);
    Delete(I);
    end;
end;

function TObjectList.GetItems(AIndex: Integer): TObject;
const ASSERT_LOCATION = ASSERT_UNIT+'.TObjectList.GetItems';
begin
  Result := TObject(inherited Items[AIndex]);
end;
{$ENDIF}

function BoolToXML(AValue: Boolean; AExtra: Boolean = True): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.BoolToStr';
begin
  // no check on either parameter
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

function XMLToBool(const AName: String): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.StrToBool';
var
  LName: String;
begin
  // no check on either parameter
  LName := UpperCase(AName);
  if LName = 'TRUE' then
    Result := True
  else if LName = 'FALSE' then
    Result := False
  else if LName = '1' then
    Result := True
  else if LName = '0' then
    Result := False
  else
    raise EIdSoapRequirementFail.Create(ASSERT_LOCATION + ': Boolean values must be TRUE or FALSE (Value was "' + AName + '")') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
end;


{$IFDEF DELPHI4OR5}
function BoolToStr(AValue: Boolean; AExtra: Boolean = True): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.BoolToStr';
begin
  // no check on either parameter
  if AValue then
    Result := 'True'
  else
    Result := 'False';
end;

function StrToBool(const AName: String): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.StrToBool';
var
  LName: String;
begin
  // no check on either parameter
  LName := UpperCase(AName);
  if LName = 'TRUE' then
    Result := True
  else if LName = 'FALSE' then
    Result := False
  else if LName = '1' then
    Result := True
  else if LName = '0' then
    Result := False
  else
    raise EIdSoapRequirementFail.Create(ASSERT_LOCATION + ': Boolean values must be TRUE or FALSE (Value was "' + AName + '")') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
end;

procedure Sleep(ATime: Cardinal);
  {$IFDEF LINUX}
var
  LTime: TTimeVal;
begin
  // what if the user just calls sleep? without doing anything...
  // cannot use GStack.WSSelectRead(nil, ATime)
  // since no readsocketlist exists to get the fdset
  LTime.tv_sec := ATime div 1000;
  LTime.tv_usec := (ATime mod 1000) * 1000;
  Libc.Select(0, NIL, NIL, NIL, @LTime);
end;
{$ENDIF}
{$IFDEF MSWINDOWS}
begin
  Windows.Sleep(ATime);
end;
{$ENDIF}

{$ENDIF}

{ TIdStringList }

constructor TIdStringList.Create;
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
  IdObjectRegister(self);
end;


destructor TIdStringList.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdStringList.Destroy';
begin
  assert(assigned(self), ASSERT_LOCATION + ': self is nil');
  Clear;
  IdObjectDeregister(self);
  inherited Destroy;
end;

procedure TIdStringList.Clear;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdStringList.Clear';
var
  i: Integer;
  LObj: TObject;
begin
  assert(assigned(self), ASSERT_LOCATION + ': self is nil');
  if FOwnsObjects then
    begin
    for i := Count - 1 downto 0 do
      begin
      LObj := objects[i];
      objects[i] := NIL;
      Delete(i);
      FreeAndNil(LObj);
      end;
    end;
  inherited Clear;
end;

procedure TIdStringList.Delete(AIndex: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdStringList.Delete';
begin
  assert(assigned(self), ASSERT_LOCATION + ': self is nil');
  // AIndex checked in ancestor
  if FOwnsObjects then
    begin
    Objects[AIndex].Free;    // can't use FreeAndNil
    Objects[AIndex] := NIL;
    end;
  inherited Delete(AIndex);
end;

function IdStrToIntWithError(const AStr, AError: String): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToIntWithError';
var
  LErr: Integer;
begin
  Val(AStr, Result, LErr);
  if LErr <> 0 then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not a valid integer value') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToIntWithErrorAndRange(ALowValue, AHighValue: Integer; const AStr, AError: String): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToIntWithErrorAndRange';
begin
  Result := IdStrToIntWithError(AStr, AError);
  if (Result < ALowValue) or (Result > AHighValue) then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not in the range ' + IntToStr(ALowValue) + ' to ' + IntToStr(AHighValue)) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToInt64WithError(const AStr, AError: String): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToInt64WithError';
var
  LErr: Integer;
begin
  Val(AStr, Result, LErr);
  if LErr <> 0 then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not a valid Int64 value') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToInt64WithErrorAndRange(ALowValue, AHighValue: Int64; const AStr, AError: String): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToInt64WithErrorAndRange';
begin
  Result := IdStrToInt64WithError(AStr, AError);
  if (Result < ALowValue) or (Result > AHighValue) then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not in the range ' + IntToStr(ALowValue) + ' to ' + IntToStr(AHighValue)) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToSingleWithError(const AStr, AError: String): Single;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToSingleWithError';
var
  LErr: Integer;
begin
  Val(AStr, Result, LErr);
  if LErr <> 0 then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not a valid Single value') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToDoubleWithError(const AStr, AError: String): Double;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToDoubleWithError';
var
  LErr: Integer;
begin
  Val(AStr, Result, LErr);
  if LErr <> 0 then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not a valid Double value') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToCompWithError(const AStr, AError: String): Comp;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToCompWithError';
var
  LErr: Integer;
begin
  Val(AStr, Result, LErr);
  if LErr <> 0 then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not a valid Comp value') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToExtendedWithError(const AStr, AError: String): Extended;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToExtendedWithError';
var
  LErr: Integer;
begin
  Val(AStr, Result, LErr);
  if LErr <> 0 then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not a valid Extended value') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdStrToCurrencyWithError(AStr, AError: String): Currency;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStrToCurrencyWithError';
var
  LPos : integer;
begin
    if DecimalSeparator <> '.' then
      begin
      LPos := Pos('.', AStr);
      if LPos <> 0 then
        begin
        AStr := Copy (AStr, 1, LPos - 1) + DecimalSeparator + Copy (AStr, LPos + 1 , Length (AStr) - LPos);
        end;
      end;
  if not TextToFloat(PChar(AStr), Result, fvCurrency) then
    begin
    raise EIdSoapBadParameterValue.Create(AError + ': "' + AStr + '" is not a valid Currency value') {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

// thanks to Glenn Crouch, ESB (glenn@esbconsult.com) for
// this approach to handling the internationalization issues

function IdSingleToStr(AValue: Single): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSingleToStr';
var
  LPos : integer;
begin
  Result := FloatToStr(AValue);
  if DecimalSeparator <> '.' then
    begin
    LPos := Pos(DecimalSeparator, result);
    if LPos <> 0 then
      begin
      Result := Copy (Result, 1, LPos - 1) + '.' + Copy (Result, LPos + 1 , Length (Result) - LPos);
      end;
    end;
end;

function IdDoubleToStr(AValue: Double): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdDoubleToStr';
var
  LPos : integer;
begin
  Result := FloatToStr(AValue);
  if DecimalSeparator <> '.' then
    begin
    LPos := Pos(DecimalSeparator, result);
    if LPos <> 0 then
      begin
      Result := Copy (Result, 1, LPos - 1) + '.' + Copy (Result, LPos + 1 , Length (Result) - LPos);
      end;
    end;
end;

function IdCompToStr(AValue: Comp): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdCompToStr';
var
  LPos : integer;
begin
  // 20 is greater than max possible value, so comps are always represented
  // in integer format per Schema standard
  Result := FloatToStrF(AValue, ffFixed, 20, 0);
  if DecimalSeparator <> '.' then
    begin
    LPos := Pos(DecimalSeparator, result);
    if LPos <> 0 then
      begin
      Result := Copy (Result, 1, LPos - 1) + '.' + Copy (Result, LPos + 1 , Length (Result) - LPos);
      end;
    end;
end;

function IdExtendedToStr(AValue: Extended): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdExtendedToStr';
var
  LPos : integer;
begin
  Result := FloatToStr(AValue);
  if DecimalSeparator <> '.' then
    begin
    LPos := Pos(DecimalSeparator, result);
    if LPos <> 0 then
      begin
      Result := Copy (Result, 1, LPos - 1) + '.' + Copy (Result, LPos + 1 , Length (Result) - LPos);
      end;
    end;
end;

function IdCurrencyToStr(AValue: Currency): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdCurrencyToStr';
var
  LPos : integer;
begin
  // 20 is greater than max possible value, so Currency is always represented
  // in decimal format per Schema standard
  Result := FloatToStrF(AValue, ffFixed, 20, 4);
  if DecimalSeparator <> '.' then
    begin
    LPos := Pos(DecimalSeparator, result);
    if LPos <> 0 then
      begin
      Result := Copy (Result, 1, LPos - 1) + '.' + Copy (Result, LPos + 1 , Length (Result) - LPos);
      end;
    end;
end;




procedure IdRequire(ACondition: Boolean; AComment: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.IdRequire';
begin
  assert(AComment <> '', ASSERT_LOCATION + ': AComment is blank');
  if not ACondition then
    begin
    raise EIdSoapRequirementFail.Create(AComment) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function TIdStringList.TestValid(AClassType: TClass): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdStringList.TestValid';
begin
  {$IFDEF OBJECT_TRACKING}
  Result := IdObjectTestValid(self);
  {$ELSE}
  Result := Assigned(self);
  {$ENDIF}
  if Result and assigned(AClassType) then
    begin
    Result := self is AClassType;
    end;
end;

{ TIdCriticalSection }

constructor TIdCriticalSection.Create;
begin
  inherited Create;
  IdObjectRegister(self);
  InitializeCriticalSection(FSection);
  FOwnerThread := 0;
  FOwnerThreadCount := 0;
end;

destructor TIdCriticalSection.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdCriticalSection.Destroy';
begin
  Assert(Assigned(Self), ASSERT_LOCATION + ': Self is nil');
  IdObjectDeregister(self);
  DeleteCriticalSection(FSection);
  inherited Destroy;
end;

procedure TIdCriticalSection.Acquire;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdCriticalSection.Acquire';
begin
  Assert(Assigned(Self), ASSERT_LOCATION + ': Self is nil');
  EnterCriticalSection(FSection);
  assert((FOwnerThread = 0) or (FOwnerThread = GetCurrentThreadid));
  if FOwnerThread = GetCurrentThreadid then
    begin
    inc(FOwnerThreadCount);
    end
  else
    begin
    FOwnerThread := GetCurrentThreadId;
    FOwnerThreadCount := 1;
    end;
end;

procedure TIdCriticalSection.Release;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdCriticalSection.Release';
begin
  Assert(Assigned(Self), ASSERT_LOCATION + ': Self is nil');
  Assert(FOwnerThread = GetCurrentThreadID);
  dec(FOwnerThreadCount);
  if FOwnerThreadCount = 0 then
    FOwnerThread := 0;
  LeaveCriticalSection(FSection);
end;

procedure TIdCriticalSection.Enter;
begin
  Acquire;
end;

procedure TIdCriticalSection.Leave;
begin
  Release;
end;

function TIdCriticalSection.LockedToMe: Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdCriticalSection.LockedToMe';
begin
  Assert(Assigned(Self), ASSERT_LOCATION + ': Self is nil');
  Result := FOwnerThread = GetCurrentThreadId;
end;

function IdEnumIsValid(ATypeInfo: PTypeInfo; AIndex: Integer): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdEnumIsValid';
var
  LTypeData: PTypeData;
begin
  assert(ATypeInfo <> NIL, ASSERT_LOCATION + ': ATypeInfo = nil');
  // no check on AIndex
  if ATypeInfo^.Kind = tkEnumeration then
    begin
    LTypeData := GetTypeData(ATypeInfo);
    Result := (AIndex >= LTypeData^.MinValue) and (AIndex <= LTypeData^.MaxValue);
    end
  else
    Result := False;
end;

function IdEnumStrIsValid(ATypeInfo: PTypeInfo; AValue : string): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdEnumStrIsValid';
var
  LTypeData: PTypeData;
  LPChar: PChar;
  LCount : integer;
begin
  assert(ATypeInfo <> NIL, ASSERT_LOCATION + ': ATypeInfo = nil');
  assert(AValue <> '', ASSERT_LOCATION + ': AValue = ''''');
  if ATypeInfo^.Kind = tkEnumeration then
    begin
    LTypeData := GetTypeData(ATypeInfo);
    if LTypeData^.MinValue <> 0 then
      begin
      raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_BAD_ENUM_TYPE, [ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
      end;
    LPChar := @LTypeData^.NameList[0];
    LCount := 0;
    while (LCount <= LTypeData^.MaxValue) and (not AnsiSameText(ShortString(pointer(LPChar)^), AValue)) do
      begin
      inc(LPChar, Ord(LPChar^) + 1);  // move to next string
      inc(LCount);
      end;
    result := LCount <= LTypeData^.MaxValue;
    end
  else
    begin
    raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_NOT_ENUM_TYPE, [ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

function IdEnumToString(ATypeInfo: PTypeInfo; AIndex: Integer): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdEnumToString';
var
  i: Integer;
  LTypeData: PTypeData;
  LPChar: PChar;
begin
  assert(ATypeInfo <> NIL, ASSERT_LOCATION + ': ATypeInfo = nil');
  // no check on AIndex (Yet)
  if ATypeInfo^.Kind = tkEnumeration then
    begin
    LTypeData := GetTypeData(ATypeInfo);
    if LTypeData^.MinValue <> 0 then
      begin
      raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_BAD_ENUM_TYPE, [ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
      end;
    if AIndex > LTypeData^.MaxValue then
      begin
      raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_ENUM_OUT_RANGE, [IntToStr(AIndex), ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
      end;
    LPChar := PChar(@LTypeData^.NameList[0]);
    for i := 1 to AIndex do
      begin
      inc(LPChar, Ord(LPChar^) + 1);  // move to next string
      end;
    Result := ShortString(pointer(LPChar)^);
    end
  else
    raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_NOT_ENUM_TYPE, [ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
end;

function IdStringToEnum(ATypeInfo: PTypeInfo; const AStr: String): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdStringToEnum';
var
  LTypeData: PTypeData;
  LPChar: PChar;
begin
  assert(ATypeInfo <> NIL, ASSERT_LOCATION + ': IdSoapUtilities.IdStringToEnum: ATypeInfo = nil');
  assert(AStr <> '', ASSERT_LOCATION + ': IdSoapUtilities.IdStringToEnum: AStr = ''''');
  if ATypeInfo^.Kind = tkEnumeration then
    begin
    LTypeData := GetTypeData(ATypeInfo);
    if LTypeData^.MinValue <> 0 then
      begin
      raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_BAD_ENUM_TYPE, [ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
      end;
    LPChar := @LTypeData^.NameList[0];
    Result := 0;
    while (Result <= LTypeData^.MaxValue) and (not AnsiSameText(ShortString(pointer(LPChar)^), AStr)) do
      begin
      inc(LPChar, Ord(LPChar^) + 1);  // move to next string
      inc(Result);
      end;
    if Result > LTypeData^.MaxValue then
      begin
      raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_ENUM_OUT_RANGE, [AStr, ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
      end;
    end
  else
    begin
    raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_ENGINE_NOT_ENUM_TYPE, [ATypeInfo^.Name])) {$IFDEF SMARTERRORS} at CallerAddr {$ENDIF};
    end;
end;

{ TIdMemoryStream }

constructor TIdMemoryStream.Create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdMemoryStream.create';
begin
  inherited Create;
  FSerialNo := IdObjectRegister(self);
end;

destructor TIdMemoryStream.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdMemoryStream.destroy';
begin
  IdObjectDeregister(self);
  inherited;
end;

function TIdMemoryStream.TestValid(AClassType: TClass): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdMemoryStream.TestValid';
begin
  {$IFDEF OBJECT_TRACKING}
  Result := IdObjectTestValid(self);
  {$ELSE}
  Result := Assigned(self);
  {$ENDIF}
  if Result and assigned(AClassType) then
    begin
    Result := self is AClassType;
    end;
end;

{ TIdSoapKeyList }

constructor TIdSoapKeyList.Create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.Create';
begin
  inherited Create;
  init(AHashSize);
end;

procedure TIdSoapKeyList.init(AHashSize: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.init';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  Assert(AHashSize > 2, ASSERT_LOCATION + ': Hash size must be at least 2');

  FHashSize := AHashSize;
  GetMem(FHashTable, FHashSize * sizeof(pointer));
  FMemoryUsage := FHashSize * sizeof(pointer);
  for i := 0 to FHashSize - 1 do
    begin
    FHashtable^[i] := TIdSoapKeyListSection.Create(self);
    end;
  FCount := 0;
end;

destructor TIdSoapKeyList.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.Destroy';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');

  for i := 0 to FHashSize - 1 do
    begin
    FreeAndNil(FHashtable^[i]);
    end;
  FreeMem(FHashTable, FHashSize * sizeof(pointer));
  FHashTable := NIL;
  inherited Destroy;
end;

function TIdSoapKeyList.GetAsInt(AKey: Cardinal): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.GetAsInt';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey
  Result := FHashTable^[AKey mod Cardinal(FHashSize)].GetItem(AKey, Integer($FFFFFFFF));
end;

function TIdSoapKeyList.GetAsPointer(AKey: Cardinal): pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.GetAsPointer';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey
  Result := pointer(FHashTable^[AKey mod Cardinal(FHashSize)].GetItem(AKey, 0));
end;

function TIdSoapKeyList.GetAsObj(AKey: Cardinal): TObject;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.GetAsObj';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey
  Result := TObject(FHashTable^[AKey mod Cardinal(FHashSize)].GetItem(AKey, 0));
end;

procedure TIdSoapKeyList.SetAsInt(AKey: Cardinal; const AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.SetAsInt';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey, AValue
  FHashTable^[AKey mod Cardinal(FHashSize)].AddItem(AKey, AValue);
end;

procedure TIdSoapKeyList.SetAsPointer(AKey: Cardinal; const AValue: pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.SetAsPointer';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey, AValue
  FHashTable^[Akey mod Cardinal(FHashSize)].AddItem(Akey, Integer(Avalue));
end;

procedure TIdSoapKeyList.SetAsObj(AKey: Cardinal; const AValue: TObject);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.SetAsObj';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey, AValue
  FHashTable^[AKey mod Cardinal(FHashSize)].AddItem(AKey, Integer(AValue));
end;

function TIdSoapKeyList.GetExists(AKey: Cardinal): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.GetExists';
var
  Ldummy: Integer;
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey
  Result := FHashTable^[AKey mod Cardinal(FHashSize)].FindItem(AKey, LDummy);
end;

procedure TIdSoapKeyList.Delete(AKey: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.Delete';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  // no check on AKey
  FHashTable^[AKey mod Cardinal(FHashSize)].Delete(AKey);
end;

function TIdSoapKeyList.GetFirstKey(var VProgressRec: TIdSoapKeyProgressRec; var VKey: Cardinal): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.GetFirstKey';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');

  // VProgressRec just a return only. No checking required

  // Leave VKey as is. It could have a value in it that the user will use
  // if this routine returns FALSE. Of course this is not a good thing for
  // the programmer to do. The return value should only be relied on
  // when the function returns TRUE

  VProgressRec.Step1 := -1;
  VProgressRec.Step2 := 0;
  Result := GetNextKey(VProgressRec, VKey);
end;

function TIdSoapKeyList.GetNextKey(var VProgressRec: TIdSoapKeyProgressRec; var VKey: Cardinal): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.GetNextKey';
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');

  // VProgressRec is hard to check?

  // Leave VKey as is. It could have a value in it that the user will use
  // if this routine returns FALSE. Of course this is not a good thing for
  // the programmer to do. The return value should only be relied on
  // when the function returns TRUE

  if VProgressRec.Step1 = -1 then
    begin
    inc(VProgressRec.Step1);
    end
  else
    begin
    inc(VProgressRec.Step2);
    end;
  while (VProgressRec.Step1 < FHashSize) and (FHashTable^[VProgressRec.Step1].FCount <= VProgressRec.Step2) do
    begin
    inc(VProgressRec.Step1);
    VProgressRec.Step2 := 0;
    end;
  Result := (VProgressRec.Step1 < FHashSize) and (FHashTable^[VProgressRec.Step1].FCount > VProgressRec.Step2);
  if Result then
    begin
    VKey := FHashTable^[VProgressRec.Step1].Fitems[VProgressRec.Step2].key;
    end;
end;

procedure TIdSoapKeyList.Clear;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyList.Clear';
var
  LP: TIdSoapKeyProgressRec;
  LK: Cardinal;
begin
  Assert(Self.TestValid(TIdSoapKeyList), ASSERT_LOCATION + ': self is not valid');
  if GetFirstKey(LP, LK) then
    begin
    Delete(LK);
    while GetNextKey(LP, LK) do
      begin
      Delete(LK);
      end;
    end;
end;

procedure TIdSoapKeyList.DisposeObject(ASender: TObject; APtr: pointer);
begin
  FreeAndNil(APtr);
end;

{ TIdSoapKeyListSection }

constructor TIdSoapKeyListSection.Create(AOwner: TIdSoapKeyList);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyListSection.Create';
begin
  inherited Create;
  Assert(Assigned(AOwner), ASSERT_LOCATION + ': Owner not assigned in Create');
  FList := AOwner;
  FCount := 0;
  FAllocated := DEFAULT_ALLOCATION_SIZE;
  GetMem(Fitems, FAllocated * sizeof(TIdSoapPair));
  inc(FList.FMemoryUsage, FAllocated * sizeof(TIdSoapPair));
end;

destructor TIdSoapKeyListSection.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyListSection.Destroy';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapKeyListSection), ASSERT_LOCATION + ': self is not valid');
  if assigned(FList.FOnDispose) then
    begin
    for i := 0 to FCount - 1 do
      begin
      FList.FOnDispose(FList, pointer(Fitems^[i].Value));
      end;
    end;
  FreeMem(Fitems, FAllocated * sizeof(TIdSoapPair));
  Fitems := NIL;
  inherited Destroy;
end;

procedure TIdSoapKeyListSection.AddItem(AKey: Cardinal; AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyListSection.AddItem';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapKeyListSection), ASSERT_LOCATION + ': self is not valid');
  // AValue can be any Integer

  if FindItem(Akey, i) then
    begin
    if assigned(FList.FOnDispose) then
      begin
      Flist.FOnDispose(FList, pointer(Fitems^[i].Value));
      end;
    Fitems^[i].Value := AValue;
    end
  else
    begin
    if FCount = FAllocated then
      begin
      Grow;
      end;
    if I < FCount then
      begin
      System.Move(Fitems^[i], Fitems^[i + 1], (FCount - I) * SizeOf(TIdSoapPair));
      end;
    Fitems^[i].key := AKey;
    Fitems^[i].Value := AValue;
    Inc(FCount);
    inc(FList.FCount);
    end;
end;

function TIdSoapKeyListSection.FindItem(AKey: Cardinal; var VIndex: Integer): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyListSection.FindItem';
var
  L, H, I: Integer;
  C : Int64;
begin
  Assert(Self.TestValid(TIdSoapKeyListSection), ASSERT_LOCATION + ': self is not valid');
  Assert(FAllocated >= DEFAULT_ALLOCATION_SIZE, ASSERT_LOCATION + ': Illegal size of FAllocated variable ' + IntToStr(FAllocated));
  VIndex := 0;   // Initialise. Will be set in this function

  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
    begin
    I := (L + H) shr 1;
    C := Fitems^[I].key;
    c := c - AKey;
    if C < 0 then
      begin
      L := I + 1
      end
    else
      begin
      H := I - 1;
      if C = 0 then
        begin
        Result := True;
        L := I;
        end;
      end;
    end;
  VIndex := L;
end;

function TIdSoapKeyListSection.GetItem(AKey: Cardinal; ADefaultValue: Integer): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyListSection.GetItem';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapKeyListSection), ASSERT_LOCATION + ': self is not valid');
  Assert(FAllocated >= DEFAULT_ALLOCATION_SIZE, ASSERT_LOCATION + ': Illegal size of FAllocated variable ' + IntToStr(FAllocated));
  // AKey, ADefault - values can be any Integer

  if FindItem(AKey, i) then
    begin
    Result := Fitems^[i].Value;
    end
  else
    begin
    Result := ADefaultValue;
    end;
end;

procedure TIdSoapKeyListSection.Grow;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyListSection.Grow';
begin
  Assert(Self.TestValid(TIdSoapKeyListSection), ASSERT_LOCATION + ': self is not valid');
  Assert(FAllocated >= DEFAULT_ALLOCATION_SIZE, ASSERT_LOCATION + ': Illegal size of FAllocated variable ' + IntToStr(FAllocated));
  inc(FAllocated, DEFAULT_ALLOCATION_SIZE);
  inc(FList.FMemoryUsage, DEFAULT_ALLOCATION_SIZE * sizeof(TIdSoapPair));
  ReallocMem(Fitems, FAllocated * SizeOf(TIdSoapPair));
end;

procedure TIdSoapKeyListSection.Delete(AKey: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapKeyListSection.Delete';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapKeyListSection), ASSERT_LOCATION + ': self is not valid');
  Assert(FAllocated >= DEFAULT_ALLOCATION_SIZE, ASSERT_LOCATION + ': Illegal size of FAllocated variable ' + IntToStr(FAllocated));

  if FindItem(Akey, i) then
    begin
    if assigned(Flist.FOnDispose) then
      begin
      Flist.FOnDispose(FList, pointer(Fitems^[i].Value));
      end;
    Dec(FCount);
    Dec(Flist.FCount);
    if I < FCount then
      begin
      System.Move(Fitems^[I + 1], Fitems^[I], (FCount - I) * SizeOf(TIdSoapPair));
      end;
    end;
end;

function IdSoapSameDateTime(const ADateTime1, ADateTime2: TDateTime; AMatchMillisecond : Boolean = true): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapSameDateTime';
var
  Ly1, Ly2, Lm1, Lm2, Ld1, Ld2: Word;
  Lhh1, Lhh2, Lmm1, Lmm2, Lss1, Lss2, Lms1, Lms2: Word;
begin
  DecodeDate(ADateTime1, Ly1, Lm1, Ld1);
  DecodeDate(ADateTime2, Ly2, Lm2, Ld2);
  if (Ly1 = Ly2) and (Lm1 = Lm2) and (Ld1 = Ld2) then
    begin
    DecodeTime(ADateTime1, Lhh1, Lmm1, Lss1, Lms1);
    DecodeTime(ADateTime2, Lhh2, Lmm2, Lss2, Lms2);
    if (Lhh1 = Lhh2) and (Lmm1 = Lmm2) and (Lss1 = Lss2) then
      begin
      Result := not AMatchMillisecond or (Lms1 = Lms2);
      end
    else
      begin
      Result := False;
      end;
    end
  else
    begin
    Result := False;
    end;
end;

function IdSoapSameDate(const ADateTime1, ADateTime2: TDateTime): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapSameDate';
var
  Ly1, Ly2, Lm1, Lm2, Ld1, Ld2: Word;
begin
  DecodeDate(ADateTime1, Ly1, Lm1, Ld1);
  DecodeDate(ADateTime2, Ly2, Lm2, Ld2);
  if (Ly1 = Ly2) and (Lm1 = Lm2) and (Ld1 = Ld2) then
    begin
    Result := True;
    end
  else
    begin
    Result := False;
    end;
end;

function IdSoapSameTime(const ADateTime1, ADateTime2: TDateTime): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapSameTime';
var
  Lhh1, Lhh2, Lmm1, Lmm2, Lss1, Lss2, Lms1, Lms2: Word;
begin
  DecodeTime(ADateTime1, Lhh1, Lmm1, Lss1, Lms1);
  DecodeTime(ADateTime2, Lhh2, Lmm2, Lss2, Lms2);
  if (Lhh1 = Lhh2) and (Lmm1 = Lmm2) and (Lss1 = Lss2) and (Lms1 = Lms2) then
    begin
    Result := True;
    end
  else
    begin
    Result := False;
    end;
end;

function IdSoapTestNodeValid(ANode: TObject; AClassType: TClass): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapTestNodeValid';
begin
  Result := (ANode <> NIL) and ((AClassType = NIL) or (ANode.InheritsFrom(AClassType)));
end;

procedure StringAppendStart(var VStr: String; var VLen: Integer);
begin
  VLen := Length(VStr);
  SetLength(VStr, Length(VStr) + 4096);
end;

procedure StringAppend(var VStr: String; AStrToAdd: String; var VLen: Integer; ADivChar: Char = #0);
var
  LOffset: Integer;
begin
  if (AStrToAdd = '') and (ADivChar = #0) then
    begin
    exit;
    end;
  if (ADivChar <> #0) and (VLen <> 0) then
    LOffset := 1
  else
    LOffset := 0;
  if VLen + LOffset + length(AStrToAdd) > length(VStr) then
    SetLength(VStr, length(VStr) + max(4096, LOffset + length(AStrToAdd)));
  if LOffset = 1 then
    VStr[VLen + 1] := ADivChar;
  move(AStrToAdd[1], VStr[VLen + LOffset + 1], length(AStrToAdd));
  inc(VLen, LOffset + length(AStrToAdd));
end;

procedure StringAppendClose(var VStr: String; ALen: Integer);
begin
  SetLength(VStr, ALen);
end;
                 
function PadString(const AStr: String; AWidth: Integer; APadChar: Char; APadLeft: Boolean): String;
begin
  if Length(AStr) >= AWidth then
    Result := AStr
  else
    begin
    SetLength(Result, AWidth);
    FillChar(Result[1], AWidth, APadChar);
    if AStr <> '' then
      if APadLeft then
        Move(AStr[1], Result[(AWidth - Length(AStr)) + 1], Length(AStr))
      else
        Move(AStr[1], Result[1], Length(AStr))
    end;
end;

function IdSoapMakeXmlPretty(ASrc: String): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapMakeXmlPretty';
var
  i: Integer;
  l: Integer;
  LLen: Integer;
  LLevelIsSimple: Boolean;
begin
  Result := '';
  StringAppendStart(Result, LLen);
  l := -1;
  LLevelIsSimple := False;
  for i := 1 to length(ASrc) do
    begin
    if ASrc[i] = '<' then
      begin
      if (i < length(ASrc)) and (ASrc[i + 1] = '?') then
        begin
        StringAppend(Result, ASrc[i], LLen);
        end
      else if (i < length(ASrc)) and (ASrc[i + 1] = '/') then
        begin
        if not LLevelIsSimple then
          begin
          StringAppend(Result, #13#10 + PadString('', l * 2, ' ', False) + ASrc[i], LLen);
          end
        else
          begin
          StringAppend(Result, ASrc[i], LLen);
          end;
        dec(l);
        LLevelIsSimple := False;
        end
      else
        begin
        inc(l);
        LLevelIsSimple := True;
        if l <> 0 then
          begin
          StringAppend(Result, #13#10 + PadString('', l * 2, ' ', False) + ASrc[i], LLen);
          end
        else
          begin
          if (i > 0) and (ASrc[i - 1] in [#13, #10]) then
            begin
            StringAppend(Result, ASrc[i], LLen);
            end
          else
            begin
            StringAppend(Result, #13#10 + ASrc[i], LLen);
            end;
          end;
        end;
      end
    else
      begin
      if not (ASrc[i] in [#9, #10, #13]) then
        begin
        if LLevelIsSimple or (ASrc[1] <> ' ') then
          begin
          StringAppend(Result, ASrc[i], LLen);
          end;
        end;
      end
    end;
  StringAppendClose(Result, LLen);
end;

function IdStripTrailingEOL(AValue: String): String;
var
  i: Integer;
begin
  i := length(AValue);
  while (I > 0) and (AValue[i] in [#10, #13]) do
    begin
    dec(i);
    end;
  Result := copy(AValue, 1, i);
end;

function IdStripLeadingEOL(AValue: String): String;
var
  i: Integer;
begin
  i := 1;
  while (I <= Length(AValue)) and (AValue[i] in [#10, #13]) do
    begin
    inc(i);
    end;
  Result := copy(AValue, i, MaxInt);
end;

function IdStripTrailingWhitespace(AValue: String): String;
var
  i: Integer;
begin
  i := length(AValue);
  while (I > 0) and (AValue[i] in [#10, #13, #32, #9]) do
    begin
    dec(i);
    end;
  Result := copy(AValue, 1, i);
end;

function IdStripLeadingWhitespace(AValue: String): String;
var
  i: Integer;
begin
  i := 1;
  while (I <= Length(AValue)) and (AValue[i] in [#10, #13, #32, #9]) do
    begin
    inc(i);
    end;
  Result := copy(AValue, i, MaxInt);
end;

function IdCheckURIValid(AValue: String; var VErrorMessage: String): Boolean;
var
  i: Integer;
begin
  Result := True;
  if AValue = '' then
    begin
    VErrorMessage := 'URI is empty';
    Result := False;
    end
  else
    begin
    for i := 1 to length(AValue) do
      begin
      // these rules are a bit more lenient that the standard (rfc 2396)
      if not (AValue[i] in ['!'..'~']) then
        begin
        if AValue[i] in [' ', #13, #10, #9] then
          begin
          VErrorMessage := 'URI is not valid: Whitespace at Char ' + IntToStr(i) + ' ("' + AValue + '")';
          end
        else
          begin
          VErrorMessage := 'URI is not valid: Char ' + IntToStr(i) + ' value is %' + IntToHex(Ord(AValue[i]), 2) + ' ("' + AValue + '")';
          end;
        Result := False;
        exit;
        end;
      end;
    end;
end;

function Min(AValueOne, AValueTwo: Integer): Integer;
begin
  if AValueOne > AValueTwo then
    begin
    Result := AValueTwo
    end //If AValueOne > AValueTwo then
  else
    begin
    Result := AValueOne;
    end; //..If AValueOne > AValueTwo then
end;

function Max(AValueOne, AValueTwo: Integer): Integer;
begin
  if AValueOne < AValueTwo then
    begin
    Result := AValueTwo
    end //if AValueOne < AValueTwo then
  else
    begin
    Result := AValueOne;
    end; //else..if AValueOne < AValueTwo then
end;

function CommaAdd(const AStr1, AStr2: String): String;
begin
  if AStr1 = '' then
    Result := AStr2
  else
    Result := AStr1 + ',' + AStr2;
end;

procedure SplitString(const AStr, AToken: String; var VLeft, VRight: String);
var
  i: Integer;
  LLocalStr: String;
begin
  { It is possible that VLeft or VRight may be the same variable as AStr. So we copy it first }
  LLocalStr := AStr;
  i := Pos(AToken, LLocalStr);
  if i = 0 then
    begin
    VLeft := LLocalStr;
    VRight := '';
    end
  else
    begin
    VLeft := Copy(LLocalStr, 1, i - 1);
    VRight := Copy(LLocalStr, i + Length(AToken), Length(LLocalStr));
    end;
end;


{$IFNDEF VCL5ORABOVE}
procedure FreeAndNil(var Obj);
var
  P: TObject;
begin
  if TObject(Obj) <> NIL then
    begin
    P := TObject(Obj);
    TObject(Obj) := NIL;  // clear the reference before destroying the object
    P.Free;
    end;
end;

function AnsiSameText(const S1, S2: String): Boolean;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1)
    , Length(S1), PChar(S2), Length(S2)) = 2;
end;

{$ENDIF}


procedure IdSoapHexToBin(AHex: String; ABin: TMemoryStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapHexToBin';
var
  p: PChar;
  i: Integer;
  function GetHexVal(ACh: Char): Byte;
    begin
    ACh := Upcase(ACh);
    if ACh > '9' then
      begin
      Result := Ord(ACh) - Ord('A') + 10;
      end
    else
      begin
      Result := Ord(ACh) - Ord('0');
      end;
    end;
begin
  assert(length(AHex) mod 2 = 0, ASSERT_LOCATION + ': String to de-Hex is an odd number of characters long');
  assert(assigned(ABin), ASSERT_LOCATION + ': Stream is not valid');
  getmem(p, Length(AHex) div 2);
  try
    for i := 0 to (length(AHex) div 2) - 1 do
      begin
      p[i] := Char(GetHexVal(AHex[(i*2) + 1]) shl 4 + GetHexVal(AHex[(i*2) + 2]));
      end;
    ABin.Write(p^, Length(AHex) div 2);
  finally
    freemem(p);
  end;
end;

function  IdSoapBinToHex(ABin : TMemoryStream):String;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapHexToBin';
var
  p : PChar;
  i : integer;
  function GetHexChar(AOrd : byte):Char;
  begin
    if AOrd < 10 then
      begin
      result := char(ord('0') + AOrd);
      end
    else
      begin
      result := char(ord('A') + AOrd - 10);
      end;
  end;
begin
  assert(Assigned(ABin), ASSERT_LOCATION+': Stream is not valid');
  SetLength(result, ABin.Size * 2);
  p := ABin.Memory;
  for i := 0 to ABin.Size -1 do
    begin
    result[(i*2)+1] := GetHexChar(ord(p[i]) shr 4);
    result[(i*2)+2] := GetHexChar(ord(p[i]) mod 16);
    end;
end;

type
  TIdSoapHashitemList = array [0..0] of TIdSoapHashItem;
  pIdSoapHashitemList = ^TIdSoapHashitemList;

  TIdSoapHashList = class (TIdBaseObject)
  private
    FCount : Integer;
    FAllocated: Integer;
    FOwner : TIdSoapHashTable;
    FItems: pIdSoapHashitemList;
    procedure Grow;
    function FindItem(AObj : TIdBaseObject; var VIndex: Integer): Boolean;
  public
    constructor create(AOwner : TIdSoapHashTable);
    destructor destroy; override;
    procedure Delete(AObj : TIdBaseObject);
    function Get(AObj : TIdBaseObject) : integer;
    function Exists(AObj : TIdBaseObject) : boolean;
    procedure SetValue(AObj : TIdBaseObject;  AValue : integer);
  end;

{ TIdSoapHashString }

constructor TIdSoapHashString.create(AValue: string; ACaseSensitive : boolean; AOwned : boolean = false);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashString.create';
begin
  inherited create;
  assert(AValue <> '', ASSERT_LOCATION+': Hash string cannot be blank');
  if ACaseSensitive then
    begin
    FValue := AValue;
    end
  else
    begin
    FValue := lowercase(AValue);
    end;
  FHash := IdSoapStringHash(FValue);
  FOwned := AOwned;
end;

function TIdSoapHashString.idHash: integer;
begin
  result := FHash;
end;

function TIdSoapHashString.idIsEqual(AObj: TIdBaseObject): boolean;
begin
  result := (AObj is TIdSoapHashString) and ((AObj as TIdSoapHashString).FValue = FValue);
end;

{ TIdSoapHashList }
constructor TIdSoapHashList.create(AOwner : TIdSoapHashTable);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.create';
begin
  inherited create;
  Assert(AOwner.TestValid(TIdSoapHashTable), ASSERT_LOCATION + ': Owner not valid');
  FOwner := AOwner;
  FCount := 0;
  FAllocated := DEFAULT_ALLOCATION_SIZE;
  GetMem(Fitems, FAllocated * sizeof(TIdSoapHashItem));
end;

destructor TIdSoapHashList.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.destroy';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapHashList), ASSERT_LOCATION + ': self is not valid');
  for i := 0 to FCount - 1 do
    begin
    FOwner.DisposeItem(FItems^[i]);
    end;
  FreeMem(Fitems, FAllocated * sizeof(TIdSoapHashItem));
  Fitems := NIL;
  inherited Destroy;
end;

procedure TIdSoapHashList.Grow;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.Grow';
begin
  Assert(Self.TestValid(TIdSoapHashList), ASSERT_LOCATION + ': self is not valid');
  Assert(FAllocated >= DEFAULT_ALLOCATION_SIZE, ASSERT_LOCATION + ': Illegal size of FAllocated variable ' + IntToStr(FAllocated));
  inc(FAllocated, DEFAULT_ALLOCATION_SIZE);
  ReallocMem(Fitems, FAllocated * SizeOf(TIdSoapHashItem));
end;

function TIdSoapHashList.FindItem(AObj : TIdBaseObject; var VIndex: Integer): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.FindItem';
var
  i : Integer;
begin
  Assert(Self.TestValid(TIdSoapHashList), ASSERT_LOCATION + ': self is not valid');
  Assert(AObj.TestValid(TIdBaseObject), ASSERT_LOCATION + ': Obj is not valid');
  VIndex := 0;   // Initialise. Will be set in this function
  Result := False;

  for i := 0 to FCount - 1 do
    begin
    if AObj.idIsEqual(FItems^[i].FKey) then
      begin
      result := true;
      VIndex := i;
      break;
      end;
    end;
end;

procedure TIdSoapHashList.Delete(AObj : TIdBaseObject);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.Delete';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapHashList), ASSERT_LOCATION + ': self is not valid');
  Assert(AObj.TestValid(TIdBaseObject), ASSERT_LOCATION + ': Obj is not valid');

  if FindItem(AObj, i) then
    begin
    FOwner.DisposeItem(Fitems^[i]);
    Dec(FCount);
    if I < FCount then
      begin
      System.Move(Fitems^[I + 1], Fitems^[I], (FCount - I) * SizeOf(TIdSoapHashItem));
      end;
    end;
end;

function TIdSoapHashList.Get(AObj : TIdBaseObject) : integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.Get';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapHashList), ASSERT_LOCATION + ': self is not valid');
  Assert(AObj.TestValid(TIdBaseObject), ASSERT_LOCATION + ': Obj is not valid');

  if FindItem(AObj, i) then
    begin
    Result := FItems^[i].FValue;
    end
  else
    begin
    Result := 0;
    end;
end;

function TIdSoapHashList.Exists(AObj : TIdBaseObject) : boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.Exists';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapHashList), ASSERT_LOCATION + ': self is not valid');
  Assert(AObj.TestValid(TIdBaseObject), ASSERT_LOCATION + ': Obj is not valid');
  result := FindItem(AObj, i);
end;

procedure TIdSoapHashList.SetValue(AObj : TIdBaseObject;  AValue : integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashList.SetValue';
var
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapHashList), ASSERT_LOCATION + ': self is not valid');
  Assert(AObj.TestValid(TIdBaseObject), ASSERT_LOCATION + ': Obj is not valid');
  // value can be anything

  if FindItem(AObj, i) then
    begin
    FOwner.DisposeItem(Fitems^[i]);
    Fitems^[i].FKey := AObj;
    Fitems^[i].FValue := AValue;
    end
  else
    begin
    if FCount = FAllocated then
      begin
      Grow;
      end;
    Fitems^[FCount].FKey := AObj;
    Fitems^[FCount].FValue := AValue;
    Inc(FCount);
    end;
end;

{ TIdSoapHashTable }

constructor TIdSoapHashTable.create(AHashSize: Integer = DEFAULT_HASH_SIZE);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.create';
begin
  inherited create;
  assert(AHashSize > 0, ASSERT_LOCATION+': Hashsize is invalid');
  FHash := TIdSoapKeyList.create(AHashSize);
  FHash.OnDispose := FHash.DisposeObject;
end;

destructor TIdSoapHashTable.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.destroy';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FHash);
  inherited;
end;

procedure TIdSoapHashTable.Clear;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.Clear';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  FHash.Clear;
end;

procedure TIdSoapHashTable.Delete(AObj: TIdBaseObject);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.Delete';
var
  LHash : Cardinal;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  LHash := cardinal(AObj.idHash);
  if FHash.Exists[LHash] then
    begin
    (FHash[LHash] as TIdSoapHashList).Delete(AObj);
    end;
end;

procedure TIdSoapHashTable.DeleteSt(AStr: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.DeleteSt';
var
  LStr : TIdSoapHashString;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  LStr := TIdSoapHashString.create(AStr, FCaseSensitive, true);
  try
    Delete(LStr);
  finally
    FreeAndNil(LStr);
  end;
end;

procedure TIdSoapHashTable.DisposeObject(ASender: TObject; APtr: pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.DisposeObject';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(APtr);
end;

function TIdSoapHashTable.GetAsInt(AObj: TIdBaseObject): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetAsInt';
var
  LHash : Cardinal;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  result := 0;
  LHash := Cardinal(AObj.idHash);
  if FHash.Exists[LHash] then
    begin
    result := (FHash[LHash] as TIdSoapHashList).Get(AObj);
    end;
end;

function TIdSoapHashTable.GetAsIntSt(AStr: string): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetAsIntSt';
var
  LStr : TIdSoapHashString;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AStr <> '', ASSERT_LOCATION+': Str is not valid');
  LStr := TIdSoapHashString.create(AStr, FCaseSensitive, true);
  try
    result := GetAsInt(LStr);
  finally
    FreeAndNil(LStr);
  end;
end;

function TIdSoapHashTable.GetAsObj(AObj: TIdBaseObject): TObject;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetAsObj';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  result := TObject(GetAsInt(AObj));
end;

function TIdSoapHashTable.GetAsObjSt(AStr: string): TObject;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetAsObjSt';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AStr <> '', ASSERT_LOCATION+': Str is not valid');
  result := TObject(GetAsIntSt(AStr));
end;

function TIdSoapHashTable.GetAsPointer(AObj: TIdBaseObject): pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetAsPointer';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  result := pointer(GetAsInt(AObj));
end;

function TIdSoapHashTable.GetAsPointerSt(AStr: string): pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetAsPointerSt';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AStr <> '', ASSERT_LOCATION+': Str is not valid');
  result := pointer(GetAsIntSt(AStr));
end;

function TIdSoapHashTable.GetExists(AObj: TIdBaseObject): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetExists';
var
  LHash : cardinal;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  LHash := cardinal(AObj.idHash);
  result := FHash.Exists[LHash] and (FHash[LHash] as TIdSoapHashList).Exists(AObj);
end;

function TIdSoapHashTable.GetExistsSt(AStr: string): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.GetExistsSt';
var
  LStr : TIdSoapHashString;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AStr <> '', ASSERT_LOCATION+': Str is not valid');
  LStr := TIdSoapHashString.create(AStr, FCaseSensitive, true);
  try
    result := GetExists(LStr);
  finally
    FreeAndNil(LStr);
  end;
end;

procedure TIdSoapHashTable.SetAsInt(AObj: TIdBaseObject; const AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.SetAsInt';
var
  LHash : Cardinal;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  LHash := Cardinal(AObj.idHash);
  if not FHash.Exists[LHash] then
    begin
    FHash[LHash] := TIdSoapHashList.create(self);
    end;
  (FHash[LHash] as TIdSoapHashList).SetValue(AObj, AValue);
end;

procedure TIdSoapHashTable.SetAsIntSt(AStr: string; const AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.SetAsIntSt';
var
  LStr : TIdSoapHashString;
  LHash : cardinal;
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AStr <> '', ASSERT_LOCATION+': Str is not valid');
  LStr := TIdSoapHashString.create(AStr, FCaseSensitive, true);
  LHash := cardinal(LStr.idHash);
  if not FHash.Exists[LHash] then
    begin
    FHash[LHash] := TIdSoapHashList.create(self);
    end;
  (FHash[LHash] as TIdSoapHashList).SetValue(LStr, AValue);
end;

procedure TIdSoapHashTable.SetAsObj(AObj: TIdBaseObject; const AValue: TObject);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.SetAsObj';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  SetAsInt(AObj, Integer(AValue));
end;

procedure TIdSoapHashTable.SetAsObjSt(AStr: string; const AValue: TObject);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.SetAsObjSt';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AStr <> '', ASSERT_LOCATION+': Str is not valid');
  SetAsIntSt(AStr, integer(AValue));
end;

procedure TIdSoapHashTable.SetAsPointer(AObj: TIdBaseObject; const AValue: pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.SetAsPointer';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AObj.TestValid, ASSERT_LOCATION+': Obj is not valid');
  SetAsInt(AObj, Integer(AValue));
end;

procedure TIdSoapHashTable.SetAsPointerSt(AStr: string; const AValue: pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHashTable.SetAsPointerSt';
begin
  assert(self.TestValid(TIdSoapHashTable), ASSERT_LOCATION+': self is not valid');
  assert(AStr <> '', ASSERT_LOCATION+': Str is not valid');
  SetAsIntSt(AStr, integer(AValue));
end;

procedure TIdSoapHashTable.DisposeItem(AItem: TIdSoapHashItem);
begin
  if (AItem.FKey is TIdSoapHashString) and (AItem.FKey as TIdSoapHashString).FOwned then
    begin
    FreeAndNil(AItem.FKey);
    end;
  if assigned(FOnDispose) then
    begin
    FOnDispose(self, pointer(AItem.FValue));
    end;
end;

(* java:
    public int hashCode() {
        int h = hash;
        if (h == 0) {
            int off = offset;
            char val[] = value;
            int len = count;

            for (int i = 0; i < len; i++) {
                h = 31*h + val[off++];
            }
            hash = h;
        }
        return h;
    }
*)
function IdSoapStringHash(const AValue : string):Integer;
var
  i : integer;
begin
  {$R-} {$Q-}
  result := 0;
  for i := 1 to length(AValue) do
    begin
    result := 31 * result + ord(AValue[i])
    end;
end;

function ZLibSupported : boolean;
begin
  {$IFDEF ID_SOAP_COMPRESSION}
  result := true;
  {$ELSE}
  result := false;
  {$ENDIF}
end;

procedure ZCompressStream(AStream : TMemoryStream);
{$IFDEF ID_SOAP_COMPRESSION}
var
  LPtr : Pointer;
  LSize : Integer;
{$ENDIF}
begin
  {$IFDEF ID_SOAP_COMPRESSION}
  ZCompress(AStream.Memory, AStream.Size, LPtr, LSize);
  try
    AStream.SetSize(LSize);
    Move(LPtr^, AStream.Memory^, LSize);
  finally
    FreeMem(LPtr);
  end;
  AStream.Position := 0;
  {$ELSE}
  raise EIdSoapException.create('Compression has been turned off in the compiler defines (see IdSoapDefines.inc)');
  {$ENDIF}
end;

procedure ZDeCompressStream(AStream : TMemoryStream);
{$IFDEF ID_SOAP_COMPRESSION}
var
  LPtr : Pointer;
  LSize : Integer;
{$ENDIF}
begin
  {$IFDEF ID_SOAP_COMPRESSION}
  ZDecompress(AStream.Memory, AStream.Size, LPtr, LSize);
  try
    AStream.SetSize(LSize);
    Move(LPtr^, AStream.Memory^, LSize);
  finally
    FreeMem(LPtr);
  end;
  AStream.Position := 0;
  {$ELSE}
  raise EIdSoapException.create('Compression has been turned off in the compiler defines (see IdSoapDefines.inc)');
  {$ENDIF}
end;

function IdSoapAnsiToUTF8(AStr : String):String;
begin
  result := UTF16BEToUTF8Str(Iso8859_1ToUTF16Str(AStr), false);
end;

function IdSoapUTF8ToAnsi(AStr : String):String;
begin
  result := UTF16ToIso8859_1Str(UTF8ToUTF16BEStr(AStr));
end;

end.
