{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15712: IdSoapDateTime.pas 
{
{   Rev 1.1    20/6/2003 00:02:54  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:32:42  GGrieve
}
{
IndySOAP: IdSoapDateTime

Base Types for handling Soap Dates

}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Fix registration
  29-Oct 2002   Grahame Grieve                  Merge Date/Time handling into general case IdSoapSimpleClass System
  17-Sep 2002   Grahame Grieve                  Fix Timezone bugs. REALLY FIX THEM THIS TIME
  18-Jul 2002   Grahame Grieve                  Fix timezone bugs (ta asel98@yahoo.com)
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  08-Apr 2002   Andrew Cumming                  Fixed time error in ms for D4
  07-Apr 2002   Andrew Cumming                  Made changes for D4 DateTimeToString problem
  06-Apr 2002   Andrew Cumming                  Name change for NanoSeconds
  05-Apr 2002   Grahame Grieve                  Remove Hints and warnings
  05-Apr 2002   Grahame Grieve                  Fix wrong check in assertions
  04-Apr 2002   Grahame Grieve                  Rework assertion features
  03-Apr 2002   Grahame Grieve                  Class based TIdSoapDateTime
  02-Apr 2002   Grahame Grieve                  Date Time Support first implemented
}

unit IdSoapDateTime;

{$I IdSoapDefines.inc}

interface

uses
  IdSoapTypeRegistry;

type
  TIdSoapTimeZoneInfo = (tzUnknown, tzUTC, tzNegative, tzPositive);

  TIdSoapDateTime = class (TIdSoapSimpleClass)
  private
    FYear : word;
    FMonth : word;
    FDay : word;
    FHour : word;
    FMinute : word;
    FSecond : word;
    FNanosecond : Cardinal;
    FTimezone : TIdSoapTimeZoneInfo;
    FtzHours : word;
    FtzMinutes : word;
    function GetAsDateTime: TDateTime;
    function GetAsXMLString: string;
    procedure SetAsDateTime(const AValue: TDateTime);
    procedure SetAsXMLString(const AValue: string);
    procedure SetDay(const AValue: word);
    procedure SetHour(const AValue: word);
    procedure SetMinute(const AValue: word);
    procedure SetMonth(const AValue: word);
    procedure SetNanosecond(const AValue: Cardinal);
    procedure SetSecond(const AValue: word);
    procedure SetYear(const AValue: word);
    procedure ZeroAll;
    procedure LoadTimeZone;
    procedure ReadDate(const AValue : string; Var VCursor : integer);
    procedure ReadTime(const AValue : string; Var VCursor : integer);
    procedure ReadTimezone(const AValue : string; Var VCursor : integer);
  protected
    function GetDateIsActive : boolean; virtual;
    function GetTimeIsActive : boolean; virtual;
  public
    class function GetTypeName : string; override;
    function WriteToXML : string; override;
    procedure SetAsXML(AValue, ANamespace, ATypeName : string); override;
    property AsDateTime : TDateTime Read GetAsDateTime write SetAsDateTime;
    Property AsXMLString : string read GetAsXMLString write SetAsXMLString;
  published
    property Year : word read FYear write SetYear;
    property Month : word read FMonth write SetMonth;
    property Day : word read FDay write SetDay;
    property Hour : word read FHour write SetHour;
    property Minute : word read FMinute write SetMinute;
    property Second : word read FSecond write SetSecond;
    property Nanosecond : Cardinal read FNanosecond write SetNanosecond;
    property Timezone : TIdSoapTimeZoneInfo read FTimezone write FTimezone;
    property tzHours : word read FtzHours write FtzHours;
    property tzMinutes : word read FtzMinutes write FtzMinutes;
  end;

  TIdSoapDate = class (TIdSoapDateTime)
  protected
    function GetTimeIsActive : boolean; override;
  public
    class function GetTypeName : string; override;
  end;

  TIdSoapTime = class (TIdSoapDateTime)
  protected
    function GetDateIsActive : boolean; override;
  public
    class function GetTypeName : string; override;
  end;

function IdStrToDateTimeWithError(const AStr, AError : string):TDateTime;
function IdDateTimeToStr(AValue : TDateTime; AError : string):String;

function DateTimeToIdSoapDateTime(AValue : TDateTime):TIdSoapDateTime;
function DateTimeToIdSoapTime(AValue : TDateTime):TIdSoapTime;
function DateTimeToIdSoapDate(AValue : TDateTime):TIdSoapDate;

implementation

uses
  IdGlobal,
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapResourceStrings,
  IdSoapUtilities,
  SysUtils;

const
  ASSERT_UNIT = 'IdSoapDateTime';

function DateTimeToIdSoapDateTime(AValue : TDateTime):TIdSoapDateTime;
begin
  result := TIdSoapDateTime.create;
  result.AsDateTime := AValue;
end;

function DateTimeToIdSoapTime(AValue : TDateTime):TIdSoapTime;
begin
  result := TIdSoapTime.create;
  result.AsDateTime := AValue;
end;

function DateTimeToIdSoapDate(AValue : TDateTime):TIdSoapDate;
begin
  result := TIdSoapDate.create;
  result.AsDateTime := AValue;
end;

{ TIdSoapDateTime }

function TIdSoapDateTime.GetDateIsActive: boolean;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.GetDateIsActive';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  result := true;
end;

function TIdSoapDateTime.GetTimeIsActive: boolean;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.GetTimeIsActive';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  result := true;
end;

procedure TIdSoapDateTime.SetYear(const AValue: word);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetYear';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  assert(GetDateIsActive, ASSERT_LOCATION+': not in Date mode');
  FYear := AValue;
end;

procedure TIdSoapDateTime.SetMonth(const AValue: word);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetMonth';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  assert(GetDateIsActive, ASSERT_LOCATION+': not in Date mode');
  assert(AValue <= 12, ASSERT_LOCATION+''+inttostr(AValue)+' is not valid for Month');
  FMonth := AValue;
end;

procedure TIdSoapDateTime.SetDay(const AValue: word);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetDay';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  assert(GetDateIsActive, ASSERT_LOCATION+': not in Date mode');
  assert(AValue <= 31, ASSERT_LOCATION+''+inttostr(AValue)+' is not valid for Day');
  FDay := AValue;
end;

procedure TIdSoapDateTime.SetHour(const AValue: word);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetHour';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  assert(GetTimeIsActive, ASSERT_LOCATION+': not in Time mode');
  assert(AValue <= 23, ASSERT_LOCATION+''+inttostr(AValue)+' is not valid for Hour');
  FHour := AValue;
end;

procedure TIdSoapDateTime.SetMinute(const AValue: word);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetMinute';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  assert(GetTimeIsActive, ASSERT_LOCATION+': not in Time mode');
  assert(AValue <= 59, ASSERT_LOCATION+''+inttostr(AValue)+' is not valid for Minute');
  FMinute := AValue;
end;

procedure TIdSoapDateTime.SetSecond(const AValue: word);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetSecond';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  assert(GetTimeIsActive, ASSERT_LOCATION+': not in Time mode');
  assert(AValue <= 59, ASSERT_LOCATION+''+inttostr(AValue)+' is not valid for Second');
  FSecond := AValue;
end;

procedure TIdSoapDateTime.SetNanosecond(const AValue: Cardinal);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetNanosecond';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  assert(GetTimeIsActive, ASSERT_LOCATION+': not in Time mode');
  assert(AValue <= 999999999, ASSERT_LOCATION+''+inttostr(AValue)+' is not valid for NanoSecond');
  FNanosecond := AValue;
end;


function TIdSoapDateTime.GetAsDateTime: TDateTime;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.GetAsDateTime';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  if GetDateIsActive and (FYear <> 0) then
    begin
    result := EncodeDate(FYear, max(FMonth, 1), max(FDay, 1));
    end
  else
    begin
    result := 0;
    end;
  if GetTimeIsActive then
    begin
    result := result + EncodeTime(FHour, FMinute, FSecond, FNanosecond div 1000000);
    if (FHour + FMinute+ FSecond + FNanoSecond <> 0) then
      begin
      case FTimezone of
        tzUnknown : ;// nothing
        tzUTC : result := result - TimeZoneBias;
        tzNegative : result := result + (-TimeZoneBias + EncodeTime(FtzHours, FtzMinutes, 0, 0));
        tzPositive : result := result + (-TimeZoneBias - EncodeTime(FtzHours, FtzMinutes, 0, 0));
      else
        raise EIdSoapDateTimeError.create(ASSERT_LOCATION+':'+RS_ERR_ENGINE_UNKNOWN_TYPE+ ' '+inttostr(ord(FTimezone)));
      end;
      end;
    end;
end;

procedure TIdSoapDateTime.SetAsDateTime(const AValue: TDateTime);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetAsDateTime';
var
  LMSec : word;
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  ZeroAll;
  if GetDateIsActive then
    begin
    DecodeDate(AValue, FYear, FMonth, FDay);
    end;
  if GetTimeIsActive then
    begin
    DecodeTime(AValue, FHour, FMinute, FSecond, LMSec);
    FNanoSecond := LMSec * 1000000;
    end;
  LoadTimeZone;
end;

function PadIntToStr(AInt, AWidth : integer):String;
begin
  result := IntToStr(AInt);
  while length(result) < AWidth do
    begin
    result := '0' + result;                                                             { do not localize }
    end;
end;

function RightTrimZero(Const s:String):string;
var
  i : integer;
begin
  i := length(s);
  while (I > 0) and (s[i] = '0') do                                                     { do not localize }
    begin
    dec(i);
    end;
  result := copy(s, 1, i);
end;

function TIdSoapDateTime.GetAsXMLString: string;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.GetAsXMLString';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  if GetDateIsActive then
    begin
    result :=
      PadIntToStr(FYear, 4)+'-'+                                                        { do not localize }
      PadIntToStr(FMonth, 2)+'-'+                                                       { do not localize }
      PadIntToStr(FDay, 2);
    if GetTimeIsActive then
      begin
      result := result + 'T';                                                           { do not localize }
      end;
    end
  else
    begin
    result := '';                                                                       { do not localize }
    end;
  if GetTimeIsActive then
    begin
    result := result +                                                                  { do not localize }
      PadIntToStr(FHour, 2)+':'+                                                        { do not localize }
      PadIntToStr(FMinute, 2)+':'+
      PadIntToStr(FSecond, 2);
    if FNanosecond <> 0 then
      begin
      result := result + '.'+                                                           { do not localize }
         RightTrimZero(PadIntToStr(FNanosecond, 9));
      end;
    end;
  case FTimezone of
    tzUnknown : ; // nothing
    tzUTC : result := result + 'Z';                                                          { do not localize }
    tzNegative : result := result + '-'+PadIntToStr(FtzHours,2)+':'+PadIntToStr(FtzMinutes,2); { do not localize }
    tzPositive : result := result + '+'+PadIntToStr(FtzHours,2)+':'+PadIntToStr(FtzMinutes,2); { do not localize }
  else
    raise EIdSoapDateTimeError.create(ASSERT_LOCATION+':'+RS_ERR_ENGINE_UNKNOWN_TYPE+ ' '+inttostr(ord(FTimezone)));   { do not localize }
  end;
end;

procedure IdDateCheck(ACondition : boolean; const ALocation, ASource, ADesc : string);
begin
  if not ACondition then
    raise EIdSoapDateTimeError.create(ALocation+': "'+ASource+'" '+RS_ERR_DATE_INVALID+' ['+ADesc+']');               { do not localize }
end;

procedure TIdSoapDateTime.ReadDate(const AValue : string; Var VCursor : integer);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.ReadDate';
var
  LYearLength : integer;
  LErr : integer;
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  IdDateCheck(Length(AValue) - (VCursor - 1) >= 10, ASSERT_LOCATION, AValue, RS_ERR_DATE_TOO_SHORT+' (Cursor = '+inttostr(VCursor)+')');{ do not localize }
  LYearLength := 0;
  if AValue[VCursor + 4] = '-' then
    begin
    LYearLength := 4
    end
  else if AValue[VCursor + 5] = '-' then
    begin
    LYearLength := 5;
    end
  else
    begin
    IdDateCheck(False, ASSERT_LOCATION, AValue, RS_ERR_DATE_YEAR_LENGTH);
    end;
  IdDateCheck(AValue[VCursor + LYearLength + 3] = '-', ASSERT_LOCATION, AValue, RS_ERR_DATE_YEAR_LENGTH+' (Cursor = '+inttostr(VCursor)+')'); { do not localize }
  Val(copy(AValue, VCursor, LYearLength), FYear, LErr);
  IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_DATE_INVALID_YEAR+' (Cursor = '+inttostr(VCursor)+')');  { do not localize }
  inc(VCursor, LYearLength + 1);
  Val(copy(AValue, VCursor, 2), FMonth, LErr);
  IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_DATE_INVALID_MONTH+' (Cursor = '+inttostr(VCursor)+')');  { do not localize }
  inc(VCursor, 3);
  Val(copy(AValue, VCursor, 2), FDay, LErr);
  IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_DATE_INVALID_DAY+' (Cursor = '+inttostr(VCursor)+')');  { do not localize }
  inc(VCursor, 2);
end;

procedure TIdSoapDateTime.ReadTime(const AValue : string; Var VCursor : integer);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.ReadTime';
var
  LErr : integer;
  LStart : word;
  s : string;
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  IdDateCheck(Length(AValue) - (VCursor - 1) >= 8, ASSERT_LOCATION, AValue, RS_ERR_TIME_TOO_SHORT+' (Cursor = '+inttostr(VCursor)+')');   { do not localize }
  IdDateCheck(AValue[VCursor + 2] = ':', ASSERT_LOCATION, AValue, RS_ERR_TIME_INVALID_TIME+' (1st ":") (Cursor = '+inttostr(VCursor)+')'); { do not localize }
  IdDateCheck(AValue[VCursor + 5] = ':', ASSERT_LOCATION, AValue, RS_ERR_TIME_INVALID_TIME+' (2nd ":") (Cursor = '+inttostr(VCursor)+')'); { do not localize }
  Val(copy(AValue, VCursor, 2), FHour, LErr);
  IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_TIME_INVALID_HOUR+' (Cursor = '+inttostr(VCursor)+')');  { do not localize }
  inc(VCursor, 3);
  Val(copy(AValue, VCursor, 2), FMinute, LErr);
  IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_TIME_INVALID_MIN+' (Cursor = '+inttostr(VCursor)+')'); { do not localize }
  inc(VCursor, 3);
  Val(copy(AValue, VCursor, 2), FSecond, LErr);
  IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_TIME_INVALID_SEC+' (Cursor = '+inttostr(VCursor)+')');  { do not localize }
  inc(VCursor, 2);
  if (Length(AValue) > VCursor) and (AValue[VCursor] = '.') then  { do not localize }
    begin
    LStart := VCursor + 1;
    inc(VCursor);
    while (VCursor <= Length(AValue)) and (AValue[VCursor] in ['0'..'9']) do { do not localize }
      begin
      inc(VCursor);
      end;
    s := Copy(AValue, LStart, min(VCursor - LStart, 9)); // makes sure not more than nanoseconds are read - note, this truncates, rather than rounding
    while Length(s) < 9 do
      begin
      s := s + '0'; { do not localize }
      end;
    val(s, FNanosecond, LErr);
    IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_TIME_INVALID_NSEC);
    end;
end;

procedure TIdSoapDateTime.ReadTimezone(const AValue : string; Var VCursor : integer);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.ReadTimezone';
var
  LErr : integer;
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  if VCursor > length(AValue) then
    begin
    FTimezone := tzUnknown;
    end
  else if AValue[VCursor] = 'Z' then   { do not localize }
    begin
    FTimezone := tzUTC;
    inc(VCursor);
    end
  else if AValue[VCursor] in ['+','-'] then { do not localize }
    begin
    if AValue[VCursor] = '+' then { do not localize }
      begin
      FTimezone := tzPositive
      end
    else
      begin
      FTimezone := tzNegative;
      end;
    inc(VCursor);
    IdDateCheck(Length(AValue) - (VCursor - 1) > 4, ASSERT_LOCATION, AValue, RS_ERR_TIMEZONE_TOO_SHORT+' (Cursor = '+inttostr(VCursor)+')'); { do not localize }
    IdDateCheck(AValue[VCursor + 2] = ':', ASSERT_LOCATION, AValue, RS_ERR_TIMEZONE_INVALID+ ' (":", Cursor = '+inttostr(VCursor)+')');      { do not localize }
    Val(copy(AValue, VCursor,  2), FtzHours, LErr);
    IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_TIMEZONE_INVALID_HOUR+' (Cursor = '+inttostr(VCursor)+')');                         { do not localize }
    inc(VCursor, 3);
    Val(copy(AValue, VCursor, 2), FtzMinutes, LErr);
    IdDateCheck(LErr = 0, ASSERT_LOCATION, AValue, RS_ERR_TIMEZONE_INVALID_MIN+' (Cursor = '+inttostr(VCursor)+')');                       { do not localize }
    inc(VCursor, 2);
    end
  else
    begin
    IdDateCheck(False, ASSERT_LOCATION, AValue, RS_ERR_DATE_INVALID_CHAR_END+' (Cursor = '+inttostr(VCursor)+')');  { do not localize }
    end;
end;

procedure TIdSoapDateTime.SetAsXMLString(const AValue: string);
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.SetAsXMLString';
var
  LCursor : integer;
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  ZeroAll;
  LCursor := 1;
  if GetDateIsActive then
    begin
    ReadDate(AValue, LCursor);
    if GetTimeIsActive then
      begin
      IdDateCheck((LCursor > length(AValue)) or (AValue[LCursor] = 'T'), ASSERT_LOCATION, AValue, RS_ERR_DATE_INVALID_SEPARATOR+' (Cursor = '+inttostr(LCursor)+')');     { do not localize }
      inc(LCursor);
      end;
    end;
  if GetTimeIsActive then
    begin
    ReadTime(AValue, LCursor);
    end;
  ReadTimezone(AValue, LCursor);
  IdDateCheck(LCursor > length(AValue), ASSERT_LOCATION, AValue, RS_ERR_DATE_INVALID_CHAR_END+' (Cursor = '+inttostr(LCursor)+')');  { do not localize }
end;

procedure TIdSoapDateTime.LoadTimeZone;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.LoadTimeZone';
var
  LTimezone : TDateTime;
  LSec : word;
  LMSec : word;
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  LTimezone := - TimeZoneBias;
  if LTimezone = 0 then
    begin
    FTimezone := tzUTC;
    end
  else if LTimezone > 0 then
    begin
    FTimezone := tzPositive;
    DecodeTime(LTimezone, FtzHours, FtzMinutes, LSec, LMSec);
    end
  else
    begin
    FTimezone := tzNegative;
    DecodeTime(0 - LTimezone, FtzHours, FtzMinutes, LSec, LMSec);
    end;
end;

procedure TIdSoapDateTime.ZeroAll;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDateTime.ZeroAll';
begin
  assert(Self.TestValid(TIdSoapDateTime), ASSERT_LOCATION+': self is not valid');
  FYear := 0;
  FMonth := 0;
  FDay := 0;
  FHour := 0;
  FMinute := 0;
  FSecond := 0;
  FNanosecond := 0;
  FTimezone := tzUnknown;
  FtzHours := 0;
  FtzMinutes := 0;
end;

class function TIdSoapDateTime.GetTypeName: string;
begin
  result := ID_SOAP_XSI_TYPE_DATETIME;
end;

procedure TIdSoapDateTime.SetAsXML(AValue, ANamespace, ATypeName: string);
const ASSERT_LOCATION = ASSERT_UNIT + '.TIdSoapDateTime.SetAsXML';
begin
  assert((ANamespace = '') or (ANamespace = GetNamespace), ASSERT_LOCATION +': Expected {'+GetNamespace+'}'+GetTypeName+', found {'+ANamespace+'}'+ATypeName);
  assert((ATypeName = '') or (ATypeName = GetTypeName), ASSERT_LOCATION +': Expected {'+GetNamespace+'}'+GetTypeName+', found {'+ANamespace+'}'+ATypeName);
  SetAsXMLString(AValue);
end;

function TIdSoapDateTime.WriteToXML: string;
begin
  result := GetAsXMLString;
end;

{ TIdSoapDate }

function TIdSoapDate.GetTimeIsActive: boolean;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapDate.GetTimeIsActive:';
begin
  result := false
end;

class function TIdSoapDate.GetTypeName: string;
begin
  result := ID_SOAP_XSI_TYPE_DATE;
end;

{ TIdSoapTime }

function TIdSoapTime.GetDateIsActive: boolean;
const ASSERT_LOCATION = 'IdSoapDateTime.TIdSoapTime.GetDateIsActive:';
begin
  result := false
end;

function IdStrToDateTimeWithError(const AStr, AError : string):TDateTime;
var
  LDt : TIdSoapDateTime;
begin
  LDt := TIdSoapDateTime.create;
  try
    LDt.AsXMLString := AStr;
    result := LDt.AsDateTime;
  finally
    FreeAndNil(LDt);
  end;
end;

{$IFDEF DELPHI4}
// This returns the number of miliseconds in 3 digits with leading 0's
function IdSoapMiliSecondsFromDateTime(ADateTime: TDateTime): String;
var
  h,m,s,ms: Word;
begin
  DecodeTime(ADateTime,h,m,s,ms);
  Result := IntToStr(ms);
//  if ms <> 0 then
//    result := '0' + Result;
end;

{$ENDIF}

function IdDateTimeToStr(AValue : TDateTime; AError : string):String;
var
  LTimezone : TDateTime;
  LTzChar : char;
begin
  LTimeZone := -TimeZoneBias;
  if LTimeZone = 0 then
    begin
{$IFDEF DELPHI4}
    result := FormatDateTime('YYYY-MM-DD"T"HH:NN:SS.'+IdSoapMiliSecondsFromDateTime(AValue), AValue)+'Z'; { do not localize }
{$ELSE}
    result := FormatDateTime('YYYY-MM-DD"T"HH:NN:SS.ZZZZ', AValue)+'Z';                                   { do not localize }
{$ENDIF}
    end
  else
    begin
    if LTimeZone < 0 then
      begin
      LTzChar := '-';
      end
    else
      begin
      LTzChar := '+';
      end;
{$IFDEF DELPHI4}
    result := FormatDateTime('YYYY-MM-DD"T"HH:NN:SS.'+IdSoapMiliSecondsFromDateTime(AValue), AValue)+LTzChar+FormatDateTime('HH:NN', LTimeZone);   { do not localize }
{$ELSE}
    result := FormatDateTime('YYYY-MM-DD"T"HH:NN:SS.ZZZZ', AValue)+LTzChar+FormatDateTime('HH:NN', LTimeZone);                                     { do not localize }
{$ENDIF}
    end;
end;

class function TIdSoapTime.GetTypeName: string;
begin
  result := ID_SOAP_XSI_TYPE_TIME;
end;

initialization
  IdSoapRegisterSimpleClass(TIdSoapDateTime);
  IdSoapRegisterSimpleClass(TIdSoapDate);
  IdSoapRegisterSimpleClass(TIdSoapTime);

  // not likely to be used: 
  IdSoapRegisterType(TypeInfo(TIdSoapTimeZoneInfo));
end.

