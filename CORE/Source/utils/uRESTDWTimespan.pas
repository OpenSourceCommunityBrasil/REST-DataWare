unit uRESTDWTimespan;

{$WEAKPACKAGEUNIT OFF}

interface
{$IFNDEF CPUX86}
{$WARN LOST_EXTENDED_PRECISION OFF}
{$ENDIF !CPUX86}
{$HPPEMIT LEGACYHPP}

{$IFDEF FPC}
Resourcestring
 sInvalidTimespanFormat    = 'Invalid Timespan format';
 sTimespanTooLong          = 'Timespan too long';
 sTimespanElementTooLong   = 'Timespan element too long';
 sInvalidTimespanDuration  = 'The duration cannot be returned because the absolute value exceeds the value of TTimeSpan.MaxValue';
 sTimespanValueCannotBeNan = 'Value cannot be NaN';
 sCannotNegateTimespan     = 'Negating the minimum value of a Timespan is invalid';
{$ENDIF}

type
  TTimeSpan = Class
  private
    FTicks: Int64;
  strict private
    function GetDays: Integer;
    function GetHours: Integer;
    function GetMinutes: Integer;
    function GetSeconds: Integer;
    function GetMilliseconds: Integer;
    function GetTotalDays: Double;
    function GetTotalHours: Double;
    function GetTotalMinutes: Double;
    function GetTotalSeconds: Double;
    function GetTotalMilliseconds: Double;
    class function GetScaledInterval(Value: Double; Scale: Integer): TTimeSpan; static;
    constructor Create;Overload;
  strict private class var
    FMinValue: TTimeSpan{ = (FTicks: -9223372036854775808)};
    FMaxValue: TTimeSpan{ = (FTicks: $7FFFFFFFFFFFFFFF)};
    FZero: TTimeSpan;
  strict private const
    MillisecondsPerTick = 0.0001;
    SecondsPerTick = 1e-07;
    MinutesPerTick = 1.6666666666666667E-09;
    HoursPerTick = 2.7777777777777777E-11;
    DaysPerTick = 1.1574074074074074E-12;
    MillisPerSecond = 1000;
    MillisPerMinute = 60 * MillisPerSecond;
    MillisPerHour = 60 * MillisPerMinute;
    MillisPerDay = 24 * MillisPerHour;
    MaxSeconds = 922337203685;
    MinSeconds = -922337203685;
    MaxMilliseconds = 922337203685477;
    MinMilliseconds = -922337203685477;
  public const
    TicksPerMillisecond = 10000;
    TicksPerSecond = 1000 * Int64(TicksPerMillisecond);
    TicksPerMinute = 60 * Int64(TicksPerSecond);
    TicksPerHour = 60 * Int64(TicksPerMinute);
    TicksPerDay = 24 * TIcksPerHour;
  public
    constructor Create(ATicks: Int64); Reintroduce;Overload;
    constructor Create(Hours, Minutes, Seconds: Integer); Reintroduce;Overload;
    constructor Create(Days, Hours, Minutes, Seconds: Integer); Reintroduce;Overload;
    constructor Create(Days, Hours, Minutes, Seconds, Milliseconds: Integer); Reintroduce;Overload;

    function Add(const TS: TTimeSpan): TTimeSpan; overload;
    function Duration: TTimeSpan;
    function Negate: TTimeSpan;
    function Subtract(const TS: TTimeSpan): TTimeSpan; overload;
    /// <summary>Converts the TTimeSpan value into a string</summary>
    function ToString: string;

    class function FromDays(Value: Double): TTimeSpan; static;
    class function FromHours(Value: Double): TTimeSpan; static;
    class function FromMinutes(Value: Double): TTimeSpan; static;
    class function FromSeconds(Value: Double): TTimeSpan; static;
    class function FromMilliseconds(Value: Double): TTimeSpan; static;
    class function FromTicks(Value: Int64): TTimeSpan; static;
    class function Subtract(const D1, D2: TDateTime): TTimeSpan; overload; static;

    class function Parse(const S: string): TTimeSpan; static;
    class function TryParse(const S: string; out Value: TTimeSpan): Boolean; static;

    class Function  Add(const Left, Right: TTimeSpan): TTimeSpan;Overload;
    class Function  Add(const Left: TDateTime; Right: TTimeSpan): TDateTime;Overload;
    class Function  Subtract(const Left, Right: TTimeSpan): TTimeSpan;Overload;
    class Function  Subtract(const Left: TDateTime; Right: TTimeSpan): TDateTime;Overload;
    class Function  Equal(const Left, Right: TTimeSpan): Boolean;
    class Function  NotEqual(const Left, Right: TTimeSpan): Boolean;
    class Function  GreaterThan(const Left, Right: TTimeSpan): Boolean;
    class Function  GreaterThanOrEqual(const Left, Right: TTimeSpan): Boolean;
    class Function  LessThan(const Left, Right: TTimeSpan): Boolean;
    class Function  LessThanOrEqual(const Left, Right: TTimeSpan): Boolean;
    class Function  Negative(const Value: TTimeSpan): TTimeSpan;
    class Function  Positive(const Value: TTimeSpan): TTimeSpan;
    class Function  Implicit(const Value: TTimeSpan): string;
    class Function  Explicit(const Value: TTimeSpan): string;

    property Ticks: Int64 read FTicks;
    property Days: Integer read GetDays;
    property Hours: Integer read GetHours;
    property Minutes: Integer read GetMinutes;
    property Seconds: Integer read GetSeconds;
    property Milliseconds: Integer read GetMilliseconds;
    property TotalDays: Double read GetTotalDays;
    property TotalHours: Double read GetTotalHours;
    property TotalMinutes: Double read GetTotalMinutes;
    property TotalSeconds: Double read GetTotalSeconds;
    property TotalMilliseconds: Double read GetTotalMilliseconds;
    class property MinValue: TTimeSpan read FMinValue;
    class property MaxValue: TTimeSpan read FMaxValue;
    class property Zero: TTimeSpan read FZero;
  end;

implementation

uses
  {$IFNDEF FPC}
   System.RTLConsts,
   System.SysUtils,
   System.Math
  {$ELSE}
   RTLConsts,
   SysUtils,
   Math
  {$ENDIF};

type
  TTimeSpanParser = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  public type
    TParseError = (peNone, peFormat, peOverflow, peOverflowHMS);
  private
    FStr: string;
    FPos: Integer;
  public
    function CurrentChar: Char; inline;
    function NextChar: Char; inline;
    function NextNonDigit: Char;
    function Convert(const S: string): Int64;
    function TryConvert(const S: string; out Value: Int64): TParseError;
    function NextInt(MaxValue: Integer; out Value: Integer): TParseError;
    function ConvertTime(out Time: Int64): TParseError;
    procedure SkipWhite;
  end;

{ TTimeSpanParser }

function TTimeSpanParser.CurrentChar: Char;
begin
  if (FPos>= Low(string)) and (FPos <= High(FStr)) then
    Result := FStr[FPos]
  else
    Result := #0;
end;

function TTimeSpanParser.NextChar: Char;
begin
  if FPos <= High(FStr) then
    Inc(FPos);
  Result := CurrentChar;
end;

function TTimeSpanParser.NextNonDigit: Char;
var
  I: Integer;
begin
  for I := FPos to High(FStr) do
  begin
    Result := FStr[I];
    if (Result < '0') or (Result > '9') then // do not localize
      Exit;
  end;
  Result := #0;
end;

function TTimeSpanParser.Convert(const S: string): Int64;
begin
  Result := 0;
  case TryConvert(S, Result) of
    peFormat:
      raise Exception.Create(sInvalidTimespanFormat);
    peOverflow:
      raise EIntOverflow.Create(sTimespanTooLong);
    peOverflowHMS:
      raise EIntOverflow.Create(sTimespanElementTooLong);
  end;
end;

function TTimeSpanParser.NextInt(MaxValue: Integer; out Value: Integer): TParseError;
var
  StartPos: Integer;
  Ch: Char;
begin
  Value := 0;
  StartPos := FPos;
  Ch := CurrentChar;
  while (Ch >= '0') and (Ch <= '9') do // do not localize
  begin
    if Value and $F0000000 <> 0 then
      Exit(peOverflow);
    Value := Value * 10 + (Ord(Ch) - $30);
    if Value < 0 then
      Exit(peOverflow);
    Ch := NextChar;
  end;
  if FPos = StartPos then
    Exit(peFormat);
  if Value > MaxValue then
    Exit(peOverflow);
  Result := peNone;
end;

function TTimeSpanParser.ConvertTime(out Time: Int64): TParseError;
var
  Part: Integer;
  Ch: Char;
begin
  Time := 0;
  Result := NextInt(23, Part);
  if Result <> peNone then
  begin
    if Result = peOverflow then
      Result := peOverflowHMS;
    Exit;
  end;
  Time := Part * TTimeSpan.TicksPerHour;
  if CurrentChar <> ':' then
    Exit(peFormat);
  NextChar;
  Result := NextInt(59, Part);
  if Result <> peNone then
  begin
    if Result = peOverflow then
      Result := peOverflowHMS;
    Exit;
  end;
  Time := Time + Part * TTimeSpan.TicksPerMinute;
  if CurrentChar = ':' then
  begin
    if NextChar <> '.' then
    begin
      Result := NextInt(59, Part);
      if Result <> peNone then
      begin
        if Result = peOverflow then
          Result := peOverflowHMS;
        Exit;
      end;
      Time := Time + Part * TTimeSpan.TicksPerSecond;
    end;
    if CurrentChar = '.' then
    begin
      Ch := NextChar;
      Part := TTimeSpan.TicksPerSecond;
      while (Part > 1) and ((Ch >= '0') and (Ch <= '9')) do // do not localize
      begin
        Part := Part div 10;
        Time := Time + (Ord(Ch) - $30) * Part;
        Ch := NextChar;
      end;
    end;
  end;
  Result := peNone;
end;

procedure TTimeSpanParser.SkipWhite;
var
  Ch: Char;
begin
  Ch := CurrentChar;
  while (Ch= ' ') or (Ch = #9) do
    Ch := NextChar;
end;

function TTimeSpanParser.TryConvert(const S: string; out Value: Int64): TParseError;
var
  Ticks, TimeVal: Int64;
  Days: Integer;
  IsNegative: Boolean;
begin
  Ticks := 0;
  Value := 0;
  FStr := S;
  FPos := Low(string);
  SkipWhite;
  IsNegative := False;
  if CurrentChar = '-' then
  begin
    IsNegative := True;
    NextChar;
  end;
  if NextNonDigit = ':' then
  begin
    Result := ConvertTime(Ticks);
    if Result <> peNone then
      Exit;
  end else
  begin
    Result := NextInt($a2e3ff, Days);
    if Result <> peNone then
      Exit;
    Ticks := Days * TTimeSpan.TicksPerDay;
    if CurrentChar = '.' then
    begin
      NextChar;
      Result := ConvertTime(TimeVal);
      if Result <> peNone  then
        Exit;
      Ticks := Ticks + TimeVal;
    end;
  end;
  if IsNegative then
  begin
    Ticks := -Ticks;
    if Ticks > 0 then
      Exit(peOverflow);
  end else if Ticks < 0 then
    Exit(peOverflow);
  SkipWhite;
  if FPos <= High(FStr) then
    Exit(peFormat);
  Value := Ticks;
  Result := peNone;
end;

{ TTimeSpan }

constructor TTimeSpan.Create(ATicks: Int64);
begin
  FTicks := ATicks;
end;

constructor TTimeSpan.Create(Hours, Minutes, Seconds: Integer);
begin
  FTicks := Int64(Hours) * 3600 + Int64(Minutes) * 60 + Seconds;
  if (FTicks > MaxSeconds) or (FTicks < MinSeconds) then
    raise EArgumentOutOfRangeException.Create(sTimespanTooLong);
  FTicks := FTicks * TicksPerSecond;
end;

constructor TTimeSpan.Create(Days, Hours, Minutes, Seconds: Integer);
begin
  Create(Days, Hours, Minutes, Seconds, 0);
end;

constructor TTimeSpan.Create(Days, Hours, Minutes, Seconds, Milliseconds: Integer);
var
  LTicks: Int64;
begin
  LTicks := (Int64(Days) * 3600 * 24 + Int64(Hours) * 3600 + Int64(Minutes) * 60 + Seconds) * 1000 + Milliseconds;
  if (LTicks > MaxMilliseconds) or (LTicks < MinMilliseconds) then
    raise EArgumentOutOfRangeException.Create(sTimespanTooLong);
  FTicks := LTicks * TicksPerMillisecond;
end;

function TTimeSpan.Add(const TS: TTimeSpan): TTimeSpan;
var
  NewTicks: Int64;
begin
  NewTicks := FTicks + TS.FTicks;
  if ((FTicks shr 63) = (TS.FTicks shr 63)) and ((FTicks shr 63) <> (NewTicks shr 63)) then
    raise EArgumentOutOfRangeException.Create(sTimespanTooLong);
  Result := TTimeSpan.Create(NewTicks);
end;

class Function  TTimeSpan.Add(const Left, Right: TTimeSpan): TTimeSpan;
begin
  Result := Left.Add(Right);
end;

class Function  TTimeSpan.Add(const Left: TDateTime; Right: TTimeSpan): TDateTime;
begin
  Result := TimeStampToDateTime(MSecsToTimeStamp(TimeStampToMSecs(DateTimeToTimeStamp(Left)) + Trunc(Right.TotalMilliseconds)));
end;

function TTimeSpan.Duration: TTimeSpan;
begin
  if FTicks = MinValue.FTicks then
    raise EIntOverflow.Create(sInvalidTimespanDuration);
  if FTicks < 0 then
    Result := TTimeSpan.Create(-FTicks)
  else
    Result := TTimeSpan.Create(FTicks);
end;

class Function  TTimeSpan.Equal(const Left, Right: TTimeSpan): Boolean;
begin
  Result := Left.FTicks = Right.FTicks;
end;

class Function  TTimeSpan.Explicit(const Value: TTimeSpan): string;
begin
  Result := Value.ToString;
end;

class function TTimeSpan.FromDays(Value: Double): TTimeSpan;
begin
  Result := GetScaledInterval(Value, MillisPerDay);
end;

class function TTimeSpan.FromHours(Value: Double): TTimeSpan;
begin
  Result := GetScaledInterval(Value, MillisPerHour);
end;

class function TTimeSpan.FromMilliseconds(Value: Double): TTimeSpan;
begin
  Result := GetScaledInterval(Value, 1);
end;

class function TTimeSpan.FromMinutes(Value: Double): TTimeSpan;
begin
  Result := GetScaledInterval(Value, MillisPerMinute);
end;

class function TTimeSpan.FromSeconds(Value: Double): TTimeSpan;
begin
  Result := GetScaledInterval(Value, MillisPerSecond);
end;

class function TTimeSpan.FromTicks(Value: Int64): TTimeSpan;
begin
  Result := TTimeSpan.Create(Value);
end;

function TTimeSpan.GetDays: Integer;
begin
  Result := Integer(FTicks div TicksPerDay);
end;

function TTimeSpan.GetHours: Integer;
begin
  Result := Integer((FTicks div TicksPerHour) mod 24);
end;

function TTimeSpan.GetMilliseconds: Integer;
begin
  Result := Integer((FTicks div TicksPerMillisecond) mod 1000);
end;

function TTimeSpan.GetMinutes: Integer;
begin
  Result := Integer((FTicks div TicksPerMinute) mod 60);
end;

function TTimeSpan.GetSeconds: Integer;
begin
  Result := Integer((FTicks div TicksPerSecond) mod 60);
end;

function TTimeSpan.GetTotalDays: Double;
begin
  Result := FTicks * DaysPerTick;
end;

function TTimeSpan.GetTotalHours: Double;
begin
  Result := FTicks * HoursPerTick;
end;

function TTimeSpan.GetTotalMilliseconds: Double;
begin
  Result := MillisecondsPerTick;
  Result := FTicks * Result;
  if Result > MaxMilliseconds then
    Result := MaxMilliseconds
  else if Result < MinMilliseconds then
    Result := MinMilliseconds;
end;

function TTimeSpan.GetTotalMinutes: Double;
begin
  Result := FTicks * MinutesPerTick;
end;

function TTimeSpan.GetTotalSeconds: Double;
begin
  Result := FTicks * SecondsPerTick;
end;

class Function  TTimeSpan.GreaterThan(const Left, Right: TTimeSpan): Boolean;
begin
  Result := Left.FTicks > Right.FTicks;
end;

class Function  TTimeSpan.GreaterThanOrEqual(const Left, Right: TTimeSpan): Boolean;
begin
  Result := Left.FTicks >= Right.FTicks;
end;

class Function  TTimeSpan.Implicit(const Value: TTimeSpan): string;
begin
  Result := Value.ToString;
end;

constructor TTimeSpan.Create;
begin
 Inherited;
 {$IFDEF FPC}
  FMinValue := TTimeSpan.Create;
  FMaxValue := TTimeSpan.Create;
 {$ENDIF}
  FMinValue.FTicks := -9223372036854775808;
  FMaxValue.FTicks := $7FFFFFFFFFFFFFFF;
end;

class function TTimeSpan.GetScaledInterval(Value: Double; Scale: Integer): TTimeSpan;
var
  NewVal: Double;
begin
  if IsNan(Value) then
    raise EArgumentException.Create(sTimespanValueCannotBeNan);
  NewVal := Value * Scale;
  if Value >= 0.0 then
    NewVal := NewVal + 0.5
  else
    NewVal := NewVal - 0.5;
  if (NewVal > MaxMilliseconds) or (NewVal < MinMilliseconds) then
    raise EArgumentOutOfRangeException.Create(sTimespanTooLong);
  Result := TTimeSpan.Create(Trunc(NewVal) * TicksPerMillisecond);
end;

class Function  TTimeSpan.LessThan(const Left, Right: TTimeSpan): Boolean;
begin
  Result := Left.FTicks < Right.FTicks;
end;

class Function  TTimeSpan.LessThanOrEqual(const Left, Right: TTimeSpan): Boolean;
begin
  Result := Left.FTicks <= Right.FTicks;
end;

function TTimeSpan.Negate: TTimeSpan;
begin
  if FTicks = MinValue.FTicks then
    raise EIntOverflow.Create(sCannotNegateTimespan);
  Result := TTimeSpan.Create(-FTicks);
end;

class Function  TTimeSpan.Negative(const Value: TTimeSpan): TTimeSpan;
begin
  Result := Value.Negate;
end;

class Function  TTimeSpan.NotEqual(const Left, Right: TTimeSpan): Boolean;
begin
  Result := Left.FTicks <> Right.FTicks;
end;

class function TTimeSpan.Parse(const S: string): TTimeSpan;
var
  TimeSpanParser: TTimeSpanParser;
begin
  Result := TTimeSpan.Create(TimeSpanParser.Convert(S));
end;

class Function  TTimeSpan.Positive(const Value: TTimeSpan): TTimeSpan;
begin
  Result := Value;
end;

class Function  TTimeSpan.Subtract(const Left, Right: TTimeSpan): TTimeSpan;
begin
  Result := Left.Subtract(Right);
end;

function TTimeSpan.Subtract(const TS: TTimeSpan): TTimeSpan;
var
  NewTicks: Int64;
begin
  NewTicks := FTicks - TS.FTicks;
  if ((FTicks shr 63) <> (TS.FTicks shr 63)) and ((FTicks shr 63) <> (NewTicks shr 63)) then
    raise EArgumentOutOfRangeException.Create(sTimespanTooLong);
  Result := TTimeSpan.Create(NewTicks);
end;

function TTimeSpan.ToString: string;
var
  Fmt: string;
  aDays, SubSecondTicks: Integer;
  LTicks: Int64;
begin
  Fmt := '%1:.2d:%2:.2d:%3:.2d'; // do not localize
  aDays := FTicks div TicksPerDay;
  LTicks := FTicks mod TicksPerDay;
  if FTicks < 0 then
    LTicks := -LTicks;
  if aDays <> 0 then
    Fmt := '%0:d.' + Fmt; // do not localize
  SubSecondTicks := LTicks mod TicksPerSecond;
  if SubSecondTicks <> 0 then
    Fmt := Fmt + '.%4:.7d'; // do not localize
  Result := Format(Fmt,
    [Days,
    (LTicks div TicksPerHour) mod 24,
    (LTicks div TicksPerMinute) mod 60,
    (LTicks div TicksPerSecond) mod 60,
    SubSecondTicks]);
end;

class function TTimeSpan.TryParse(const S: string; out Value: TTimeSpan): Boolean;
var
  LTicks: Int64;
  TimeSpanParser: TTimeSpanParser;
begin
  if TimeSpanParser.TryConvert(S, LTicks) = peNone then
  begin
    Value := TTimeSpan.Create(LTicks);
    Result := True;
  end else
  begin
    Value := Zero;
    Result := False;
  end;
end;

class function TTimeSpan.Subtract(const D1, D2: TDateTime): TTimeSpan;
begin
  Result := TTimeSpan.Create(Trunc(TimeStampToMSecs(DateTimeToTimeStamp(D1)) - TimeStampToMSecs(DateTimeToTimeStamp(D2))) * TicksPerMillisecond);
end;

class Function  TTimeSpan.Subtract(const Left: TDateTime; Right: TTimeSpan): TDateTime;
begin
  Result := TimeStampToDateTime(MSecsToTimeStamp(TimeStampToMSecs(DateTimeToTimeStamp(Left)) - Trunc(Right.TotalMilliseconds)));
end;

end.
