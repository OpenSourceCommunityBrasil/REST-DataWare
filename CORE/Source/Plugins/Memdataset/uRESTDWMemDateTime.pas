Unit uRESTDWMemDateTime;
{$I uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface
Uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.SysUtils,
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils,
  {$ENDIF ~HAS_UNITSCOPE}
  {$IFDEF HAS_UNIT_LIBC}
  Libc,
  {$ENDIF HAS_UNIT_LIBC}
  {$IFDEF FPC}
  {$IFDEF UNIX}
  {$IFNDEF LINUX}
  Unix,
  {$ENDIF ~LINUX}
  {$ENDIF FPC}
  {$ENDIF}
  uRESTDWMemBase, uRESTDWMemResources;
Const
  // 1970-01-01T00:00:00 in TDateTime
  UnixTimeStart = 25569;
{ Encode / Decode functions }
Function EncodeDate(Const Year: Integer; Month, Day: Word): TDateTime;
Procedure DecodeDate(Date: TDateTime; out Year, Month, Day: Word); overload;
Procedure DecodeDate(Date: TDateTime; out Year: Integer; out Month, Day: Word); overload;
Procedure DecodeDate(Date: TDateTime; out Year, Month, Day: Integer); overload;
Function CenturyOfDate(Const DateTime: TDateTime): Integer;
Function CenturyBaseYear(Const DateTime: TDateTime): Integer;
Function DayOfDate(Const DateTime: TDateTime): Integer;
Function MonthOfDate(Const DateTime: TDateTime): Integer;
Function YearOfDate(Const DateTime: TDateTime): Integer;
Function DayOfTheYear(Const DateTime: TDateTime; out Year: Integer): Integer; overload;
Function DayOfTheYear(Const DateTime: TDateTime): Integer; overload;
Function DayOfTheYearToDateTime(Const Year, Day: Integer): TDateTime;
Function HourOfTime(Const DateTime: TDateTime): Integer;
Function MinuteOfTime(Const DateTime: TDateTime): Integer;
Function SecondOfTime(Const DateTime: TDateTime): Integer;
{ ISO 8601 support }
Function GetISOYearNumberOfWeeks(Const Year: Word): Word;
Function IsISOLongYear(Const Year: Word): Boolean; overload;
Function IsISOLongYear(Const DateTime: TDateTime): Boolean; overload;
Function ISODayOfWeek(Const DateTime: TDateTime): Word;
Function ISOWeekNumber(DateTime: TDateTime; out YearOfWeekNumber, WeekDay: Integer): Integer; overload;
Function ISOWeekNumber(DateTime: TDateTime; out YearOfWeekNumber: Integer): Integer; overload;
Function ISOWeekNumber(DateTime: TDateTime): Integer; overload;
Function ISOWeekToDateTime(Const Year, Week, Day: Integer): TDateTime;
{ Miscellanous }
Function IsLeapYear(Const Year: Integer): Boolean; overload;
Function IsLeapYear(Const DateTime: TDateTime): Boolean; overload;
Function DaysInMonth(Const DateTime: TDateTime): Integer;
Function Make4DigitYear(Year, Pivot: Integer): Integer;
Function MakeYear4Digit(Year, WindowsillYear: Integer): Integer;
Function EasterSunday(Const Year: Integer): TDateTime;
Function FormatDateTime(Form: string; DateTime: TDateTime): string;
Function FATDatesEqual(Const FileTime1, FileTime2: Int64): Boolean; overload;
Function FATDatesEqual(Const FileTime1, FileTime2: TFileTime): Boolean; overload;
// Conversion
Type
  TDosDateTime = Integer;
Function HoursToMSecs(Hours: Integer): Integer;
Function MinutesToMSecs(Minutes: Integer): Integer;
Function SecondsToMSecs(Seconds: Integer): Integer;
Function TimeOfDateTimeToSeconds(DateTime: TDateTime): Integer;
Function TimeOfDateTimeToMSecs(DateTime: TDateTime): Integer;
Function DateTimeToLocalDateTime(DateTime: TDateTime): TDateTime;
Function LocalDateTimeToDateTime(DateTime: TDateTime): TDateTime;
{$IFDEF MSWINDOWS}
Function DateTimeToDosDateTime(Const DateTime: TDateTime): TDosDateTime;
Function DateTimeToFileTime(DateTime: TDateTime): TFileTime;
Function DateTimeToSystemTime(DateTime: TDateTime): TSystemTime; overload;
Procedure DateTimeToSystemTime(DateTime: TDateTime; out SysTime: TSystemTime); overload;
Function LocalDateTimeToFileTime(DateTime: TDateTime): FileTime;
{$ENDIF MSWINDOWS}
Function DosDateTimeToDateTime(Const DosTime: TDosDateTime): TDateTime;
{$IFDEF MSWINDOWS}
Function DosDateTimeToFileTime(DosTime: TDosDateTime): TFileTime; overload;
Procedure DosDateTimeToFileTime(DTH, DTL: Word; FT: TFileTime); overload;
Function DosDateTimeToSystemTime(Const DosTime: TDosDateTime): TSystemTime;
{$ENDIF MSWINDOWS}
Function DosDateTimeToStr(DateTime: Integer): string;
Function FileTimeToDateTime(Const FileTime: TFileTime): TDateTime;
{$IFDEF MSWINDOWS}
Function FileTimeToLocalDateTime(Const FileTime: TFileTime): TDateTime;
Function FileTimeToDosDateTime(Const FileTime: TFileTime): TDosDateTime; overload;
Procedure FileTimeToDosDateTime(Const FileTime: TFileTime; out Date, Time: Word); overload;
Function FileTimeToSystemTime(Const FileTime: TFileTime): TSystemTime; overload;
Procedure  FileTimeToSystemTime(Const FileTime: TFileTime; out ST: TSystemTime); overload;
{$ENDIF MSWINDOWS}
Function FileTimeToStr(Const FileTime: TFileTime): string;
{$IFDEF MSWINDOWS}
Function SystemTimeToDosDateTime(Const SystemTime: TSystemTime): TDosDateTime;
Function SystemTimeToFileTime(Const SystemTime: TSystemTime): TFileTime; overload;
Procedure SystemTimeToFileTime(Const SystemTime: TSystemTime; FTime: TFileTime); overload;
Function SystemTimeToStr(Const SystemTime: TSystemTime): string;
// Filedates
Function CreationDateTimeOfFile(Const Sr: TSearchRec): TDateTime;
Function LastAccessDateTimeOfFile(Const Sr: TSearchRec): TDateTime;
Function LastWriteDateTimeOfFile(Const Sr: TSearchRec): TDateTime;
{$ENDIF MSWINDOWS}
Type
  TJclUnixTime32 = Longword;
Function DateTimeToUnixTime(DateTime: TDateTime): TJclUnixTime32;
Function UnixTimeToDateTime(Const UnixTime: TJclUnixTime32): TDateTime;
{$IFDEF MSWINDOWS}
Function FileTimeToUnixTime(Const AValue: TFileTime): TJclUnixTime32;
Function UnixTimeToFileTime(Const AValue: TJclUnixTime32): TFileTime;
{$ENDIF MSWINDOWS}
// Time stamps (formerly in JclSchedule)
Function NullStamp: TTimeStamp;
Function CompareTimeStamps(Const Stamp1, Stamp2: TTimeStamp): Int64;
Function EqualTimeStamps(Const Stamp1, Stamp2: TTimeStamp): Boolean;
Function IsNullTimeStamp(Const Stamp: TTimeStamp): Boolean;
Function TimeStampDOW(Const Stamp: TTimeStamp): Integer;
// Day of week (formerly in JclSchedule)
Function FirstWeekDay(Const Year, Month: Integer; out DOW: Integer): Integer; overload;
Function FirstWeekDay(Const Year, Month: Integer): Integer; overload;
Function LastWeekDay(Const Year, Month: Integer; out DOW: Integer): Integer; overload;
Function LastWeekDay(Const Year, Month: Integer): Integer; overload;
Function IndexedWeekDay(Const Year, Month: Integer; Index: Integer): Integer;
Function FirstWeekendDay(Const Year, Month: Integer; out DOW: Integer): Integer; overload;
Function FirstWeekendDay(Const Year, Month: Integer): Integer; overload;
Function LastWeekendDay(Const Year, Month: Integer; out DOW: Integer): Integer; overload;
Function LastWeekendDay(Const Year, Month: Integer): Integer; overload;
Function IndexedWeekendDay(Const Year, Month: Integer; Index: Integer): Integer;
Function FirstDayOfWeek(Const Year, Month, DayOfWeek: Integer): Integer;
Function LastDayOfWeek(Const Year, Month, DayOfWeek: Integer): Integer;
Function IndexedDayOfWeek(Const Year, Month, DayOfWeek, Index: Integer): Integer;
Type
  EJclDateTimeError = Class(EJclError);
{$IFDEF UNITVERSIONING}
Const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JCL\source\common';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}
Implementation
//uses
  //uRESTDWMemSysUtils;
Const
  DaysInMonths: array [1..12] Of Integer =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  MinutesPerDay     = 60 * 24;
  //SecondsPerMinute  = 60;
  //SecondsPerHour    = 3600;
  SecondsPerDay     = MinutesPerDay * 60;
  MsecsPerMinute    = 60 * 1000;
  MsecsPerHour      = 60 * MsecsPerMinute;
  DaysPerYear       = 365.2422454;          // Solar Year
  DaysPerMonth      = DaysPerYear / 12;
  DateTimeBaseDay   = -693593;              //  1/1/0001
  EncodeDateMaxYear = 9999;
  SolarDifference   = 1.7882454;            //  Difference of Julian Calendar to Solar Calendar at 1/1/10000
  DateTimeMaxDay    = 2958466;              //  12/31/EncodeDateMaxYear + 1;
  FileTimeBase      = -109205.0;
  FileTimeStep: Extended = 24.0 * 60.0 * 60.0 * 1000.0 * 1000.0 * 10.0; // 100 nSek per Day
  // Weekday to start the week
  //   1 : Sonday
  //   2 : Monday (according to ISO 8601)
  //ISOFirstWeekDay = 2;
  // minmimum number of days of the year in the first week of the year week
  //   1 : week one starts at 1/1
  //   4 : first week has at least four days (according to ISO 8601)
  //   7 : first full week
  //ISOFirstWeekMinDays = 4;
Function EncodeDate(Const Year: Integer; Month, Day: Word): TDateTime;
Begin
  If (Year > 0) and (Year < EncodeDateMaxYear + 1) Then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.EncodeDate(Year, Month, Day)
  Else
  Begin
    If Year <= 0 Then
      Result := Year * DaysPerYear + DateTimeBaseDay
    Else      // Year >= 10000
              // for some reason year 0 does not exist so we switch from
              // the last day of year -1 (-693594) to the first days of year 1
      Result := (Year-1) * DaysPerYear + DateTimeBaseDay + // BaseDate is 1/1/1
        SolarDifference;  // guarantee a smooth transition at 1/1/10000
    Result := Trunc(Result);
    Result := Result + (Month - 1) * DaysPerMonth;
    Result := Integer(Round(Result)) + (Day - 1);
  End;
End;
Procedure DecodeDate(Date: TDateTime; out Year, Month, Day: Word);
Begin
  {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.DecodeDate(Date, Year, Month, Day);
End;
Procedure DecodeDate(Date: TDateTime; out Year, Month, Day: Integer);
Var
  WMonth, WDay: Word;
Begin
  DecodeDate(Date, Year, WMonth, WDay);
  Month := WMonth;
  Day := WDay;
End;
Procedure DecodeDate(Date: TDateTime; out Year: Integer; out Month, Day: Word);
Var
  WYear: Word;
  RDays, RMonths: TDateTime;
Begin
  If (Date >= DateTimeBaseDay) and (Date < DateTimeMaxDay) Then
  Begin
    {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.DecodeDate(Date, WYear, Month, Day);
    Year := WYear;
  End
  Else
  Begin
    Year := Trunc((Date - DateTimeBaseDay) / DaysPerYear);
    If Year <= 0 Then
      Year := Year - 1
              // for some historical reason year 0 does not exist so we switch from
              // the last day of year -1 (-693594) to the first days of year 1
    Else                                    // Year >= 10000
      Date := Date - SolarDifference;       // guarantee a smooth transition at 1/1/10000
    RDays := Date - DateTimeBaseDay;        // Days relative to 1/1/0001
    RMonths := RDays / DaysPerMonth;        // "Months" relative to 1/1/0001
    RMonths := RMonths - Year * 12.0;       // 12 "Months" per Year
    If RMonths < 0 Then                     // possible truncation glitches
    Begin
      RMonths := 11;
      Year := Year - 1;
    End;
    Month := Trunc(RMonths);
    RMonths := Month;
    Month := Month + 1;
    RDays := RDays - Year * DaysPerYear;    // subtract Base Day ot the year
    RDays := RDays - RMonths * DaysPerMonth;// subtract Base Day of the month
    Day := Trunc(RDays)+ 1;
    If Year > 0 Then                        // Year >= 10000
      Year := Year + 1;                     // BaseDate is 1/1/1
  End;
End;
Procedure ResultCheck(Val: LongBool);
Begin
  If not Val Then
    raise EJclDateTimeError.CreateRes(@RsDateConversion);
End;
Function CenturyBaseYear(Const DateTime: TDateTime): Integer;
Var
  Y: Integer;
Begin
  Y := YearOfDate(DateTime);
  Result := (Y div 100) * 100;
  If Y <= 0 Then
    Result := Result - 100;
End;
Function CenturyOfDate(Const DateTime: TDateTime): Integer;
Var
  Y: Integer;
Begin
  Y := YearOfDate(DateTime);
  If Y > 0 Then
    Result := (Y div 100) + 1
  Else
    Result := (Y div 100) - 1;
End;
Function DayOfDate(Const DateTime: TDateTime): Integer;
Var
  Y: Integer;
  M, D: Word;
Begin
  DecodeDate(DateTime, Y, M, D);
  Result := D;
End;
Function MonthOfDate(Const DateTime: TDateTime): Integer;
Var
  Y: Integer;
  M, D: Word;
Begin
  DecodeDate(DateTime, Y, M, D);
  Result := M;
End;
Function YearOfDate(Const DateTime: TDateTime): Integer;
Var
  M, D: Word;
Begin
  DecodeDate(DateTime, Result, M, D);
End;
Function DayOfTheYear(Const DateTime: TDateTime; out Year: Integer): Integer;
Var
  Month, Day: Word;
  DT: TDateTime;
Begin
  DecodeDate(DateTime, Year, Month, Day);
  DT := EncodeDate(Year, 1, 1);
  Result := Trunc(DateTime);
  Result := Result - Trunc(DT) + 1;
End;
Function DayOfTheYear(Const DateTime: TDateTime): Integer;
Var
  Year: Integer;
Begin
  Result := DayOfTheYear(DateTime, Year);
End;
Function DayOfTheYearToDateTime(Const Year, Day: Integer): TDateTime;
Begin
  Result := EncodeDate(Year, 1, 1) + Day - 1;
End;
Function HourOfTime(Const DateTime: TDateTime): Integer;
Var
  H, M, S, MS: Word;
Begin
  DecodeTime(DateTime, H, M, S, MS);
  Result := H;
End;
Function MinuteOfTime(Const DateTime: TDateTime): Integer;
Var
  H, M, S, MS: Word;
Begin
  DecodeTime(DateTime, H, M, S, MS);
  Result := M;
End;
Function SecondOfTime(Const DateTime: TDateTime): Integer;
Var
  H, M, S, MS: Word;
Begin
  DecodeTime(DateTime, H, M, S, MS);
  Result := S;
End;
Function TimeOfDateTimeToSeconds(DateTime: TDateTime): Integer;
Begin
  Result := Round(Frac(DateTime) * SecondsPerDay);
End;
Function TimeOfDateTimeToMSecs(DateTime: TDateTime): Integer;
Begin
  Result := Round(Frac(DateTime) * MSecsPerDay);
End;
Function DaysInMonth(Const DateTime: TDateTime): Integer;
Var
  M: Integer;
Begin
  M := MonthOfDate(DateTime);
  Result := DaysInMonths[M];
  If (M = 2) and IsLeapYear(DateTime) Then
    Result := 29;
End;
// SysUtils.DayOfWeek returns the day of the week of the given date. The result is an integer between
// 1 and 7, corresponding to Sunday through Saturday. ISODayOfWeek on the other hand returns an integer
// between 1 and 7 where the first day is a Monday. The forumla for calculation ISODayOfTheWeek is
// simply
//                    DayOfWeek(D) - 1  if DayOfWeek(D) > 1
// ISODayOfWeek (D) = 7                 if DayOfWeek(D) = 1
Function ISODayOfWeek(Const DateTime: TDateTime): Word;
Var
  TmpDayOfWeek: Word;
Begin
  TmpDayOfWeek := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.DayOfWeek(DateTime);
  If TmpDayOfWeek = 1 Then
    Result := 7
  Else
    Result := TmpDayOfWeek - 1;
End;
// Determines if the ISO Year is ordinary  (52 weeks) or Long (53 weeks). Uses a rule first
// suggested by Sven Pran (Norway) and Lars Nordentoft (Denmark) - according to
// http://www.phys.uu.nl/~vgent/calendar/isocalendar.htm
Function IsISOLongYear(Const DateTime: TDateTime): Boolean;
Var
  TmpYear: Word;
Begin
  TmpYear := YearOfDate(DateTime);
  Result := IsISOLongYear(TmpYear);
End;
Function IsISOLongYear(Const Year: Word): Boolean;
Var
  TmpWeekday: Word;
Begin
  TmpWeekday := ISODayOfWeek(DayOfTheYearToDateTime(Year, 1));
  Result := (IsLeapYear(Year) and ((TmpWeekday = 3) or (TmpWeekday = 4))) or (TmpWeekday = 4);
End;
Function GetISOYearNumberOfWeeks(Const Year: Word): Word;
Begin
  Result := 52;
  If IsISOLongYear(Year) Then
    Result := 53;
End;
// ISOWeekNumber function returns Integer 1..7 equivalent to Sunday..Saturday.
// ISO 8601 weeks start with Monday and the first week of a year is the one which
// includes the first Thursday
Function ISOWeekNumber(DateTime: TDateTime; out YearOfWeekNumber, WeekDay: Integer): Integer;
Var
  TmpYear: Integer;
  January4th: TDateTime;
  FirstMonday: TDateTime;
Begin
  // Applying the rule: The first calender week is the week that includes January, 4th
  TmpYear := YearOfDate(DateTime);
  WeekDay := ISODayOfWeek(DateTime);
  // adjust if we are between 12/29 and 12/31
  If (MonthOfDate(DateTime) = 12) and (DayOfDate(DateTime) >= 29) and
    (ISODayOfWeek(DateTime) <= 3) Then
    TmpYear := TmpYear + 1;
  January4th := DayOfTheYearToDateTime(TmpYear, 4);
  FirstMonday := January4th + 1 - ISODayOfWeek(January4th);
  // If our date is < FirstMonday we are in the last week of the previous year
  If DateTime < FirstMonday Then
  Begin
    Result := GetISOYearNumberOfWeeks(TmpYear - 1);
    YearOfWeekNumber := TmpYear - 1;
    Exit;
  End
  Else
  Begin
    YearOfWeekNumber := TmpYear;
    Result := (Trunc(DateTime - FirstMonday) div 7) + 1;
  End;
  If Result > GetISOYearNumberOfWeeks(YearOfDate(DateTime)) Then
    Result := GetISOYearNumberOfWeeks(YearOfDate(DateTime));
End;
Function ISOWeekNumber(DateTime: TDateTime; out YearOfWeekNumber: Integer): Integer;
Var
  Temp: Integer;
Begin
  Result := ISOWeekNumber(DateTime, YearOfWeekNumber, Temp);
End;
Function ISOWeekNumber(DateTime: TDateTime): Integer;
Var
  Temp: Integer;
Begin
  Result := ISOWeekNumber(DateTime, Temp, Temp);
End;
Function ISOWeekToDateTime(Const Year, Week, Day: Integer): TDateTime;
Var
  January4th: TDateTime;
  FirstMonday: TDateTime;
Begin
  January4th := DayOfTheYearToDateTime(Year, 4);
  FirstMonday := January4th + 1 - ISODayOfWeek(January4th);
  Result := FirstMonday + (Week - 1) * 7 + (Day - 1);
End;
// The original Gregorian rule for all who want to learn it
// Result := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));
Function IsLeapYear(Const Year: Integer): Boolean;
Begin
  Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.IsLeapYear(Year);
End;
Function IsLeapYear(Const DateTime: TDateTime): Boolean;
Begin
  Result := IsLeapYear(YearOfDate(DateTime));
End;
Function Make4DigitYear(Year, Pivot: Integer): Integer;
Begin
  { TODO : Make4DigitYear }                                                                                                  
  Assert((Year >= 0) and (Year <= 100) and (Pivot >= 0) and (Pivot <= 100));
  If Year = 100 Then
    Year := 0;
  If Pivot = 100 Then
    Pivot := 0;
  If Year < Pivot Then
    Result := 2000 + Year
  Else
    Result := 1900 + Year;
End;
// "window" technique for years to translate 2 digits to 4 digits.
// The window is 100 years wide
// The windowsill year is the lower edge of the window
// A windowsill year of 1900 is equivalent to putting 1900 before every 2-digit year
// if WindowsillYear is 1940, then 40 is interpreted as 1940, 00 as 2000 and 39 as 2039
// The system default is 1950
Function MakeYear4Digit(Year, WindowsillYear: Integer): Integer;
Var
  CC, Y: Integer;
Begin
  // have come across this specific problem : y2K read as year 100
  If Year = 100 Then
    Year := 0;
  // turn 2 digit years to 4 digits
  Y := Year mod 100;
  CC := (WindowsillYear div 100) * 100;
  Result := Y + CC;  // give the result the same century as the windowsill
  If Result < WindowsillYear Then   // cannot be lower than the windowsill
    Result := Result + 100;
  If (Year >= 100) or (Year < 0) Then
    Assert(Year = Result);  // Assert: no unwanted century translation
End;
// Calculates and returns Easter Day for specified year.
// Originally from Mark Lussier, AppVision <MLussier att best dott com>.
// Corrected to prevent integer overflow if it is inadvertedly
// passed a year of 6554 or greater.
Function EasterSunday(Const Year: Integer): TDateTime;
Var
  Month, Day, Moon, Epact, Sunday,
  Gold, Cent, Corx, Corz: Integer;
Begin
  { The Golden Number of the year in the 19 year Metonic Cycle: }
  Gold := Year mod 19 + 1;
  { Calculate the Century: }
  Cent := Year div 100 + 1;
  { Number of years in which leap year was dropped in order... }
  { to keep in step with the sun: }
  Corx := (3 * Cent) div 4 - 12;
  { Special correction to syncronize Easter with moon's orbit: }
  Corz := (8 * Cent + 5) div 25 - 5;
  { Find Sunday: }
  Sunday := (Longint(5) * Year) div 4 - Corx - 10;
              { ^ To prevent overflow at year 6554}
  { Set Epact - specifies occurrence of full moon: }
  Epact := (11 * Gold + 20 + Corz - Corx) mod 30;
  If Epact < 0 Then
    Epact := Epact + 30;
  If ((Epact = 25) and (Gold > 11)) or (Epact = 24) Then
    Epact := Epact + 1;
  { Find Full Moon: }
  Moon := 44 - Epact;
  If Moon < 21 Then
    Moon := Moon + 30;
  { Advance to Sunday: }
  Moon := Moon + 7 - ((Sunday + Moon) mod 7);
  If Moon > 31 Then
  Begin
    Month := 4;
    Day := Moon - 31;
  End
  Else
  Begin
    Month := 3;
    Day := Moon;
  End;
  Result := EncodeDate(Year, Month, Day);
End;
// Conversion
{$IFDEF MSWINDOWS}
Function DateTimeToLocalDateTime(DateTime: TDateTime): TDateTime;
Var
  TimeZoneInfo: TTimeZoneInformation;
Begin
//  ResetMemory(TimeZoneInfo, SizeOf(TimeZoneInfo));
  Case GetTimeZoneInformation(TimeZoneInfo) Of
    TIME_ZONE_ID_STANDARD, TIME_ZONE_ID_UNKNOWN:
      Result := DateTime - (TimeZoneInfo.Bias + TimeZoneInfo.StandardBias) / MinutesPerDay;
    TIME_ZONE_ID_DAYLIGHT:
      Result := DateTime - (TimeZoneInfo.Bias + TimeZoneInfo.DaylightBias) / MinutesPerDay;
  Else
    raise EJclDateTimeError.CreateRes(@RsMakeUTCTime);
  End;
End;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
Function DateTimeToLocalDateTime(DateTime: TDateTime): TDateTime;
Var
  {$IFDEF LINUX}
  TimeNow: time_t;
  Local, UTCTime: TUnixTime;
  {$ENDIF LINUX}
  Offset: Double;
Begin
  {$IFDEF LINUX}
  TimeNow := __time(nil);
  UTCTime := gmtime(@TimeNow)^;
  Local   := localtime(@TimeNow)^;
  Offset  := difftime(mktime(UTCTime), mktime(Local));
  {$ELSE ~LINUX}
  Offset := -TZSeconds;
  {$ENDIF ~LINUX}
  Result  := ((DateTime * SecsPerDay) - Offset) / SecsPerDay;
End;
{$ENDIF UNIX}
{$IFDEF MSWINDOWS}
Function LocalDateTimeToDateTime(DateTime: TDateTime): TDateTime;
Var
  TimeZoneInfo: TTimeZoneInformation;
Begin
//  ResetMemory(TimeZoneInfo, SizeOf(TimeZoneInfo));
  Case GetTimeZoneInformation(TimeZoneInfo) Of
    TIME_ZONE_ID_STANDARD, TIME_ZONE_ID_UNKNOWN:
      Result := DateTime + (TimeZoneInfo.Bias + TimeZoneInfo.StandardBias) / MinutesPerDay;
    TIME_ZONE_ID_DAYLIGHT:
      Result := DateTime + (TimeZoneInfo.Bias + TimeZoneInfo.DaylightBias) / MinutesPerDay;
  Else
    raise EJclDateTimeError.CreateRes(@RsMakeUTCTime);
  End;
End;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
Function LocalDateTimeToDateTime(DateTime: TDateTime): TDateTime;
Var
  {$IFDEF LINUX}
  TimeNow: time_t;
  Local, UTCTime: TUnixTime;
  {$ENDIF LINUX}
  Offset: Double;
Begin
  {$IFDEF LINUX}
  TimeNow := __time(nil);
  UTCTime := gmtime(@TimeNow)^;
  Local   := localtime(@TimeNow)^;
  Offset  := difftime(mktime(UTCTime), mktime(Local));
  {$ELSE ~LINUX}
  Offset := -TZSeconds;
  {$ENDIF ~LINUX}
  Result  := ((DateTime * SecsPerDay) + Offset) / SecsPerDay;
End;
{$ENDIF UNIX}
Function HoursToMSecs(Hours: Integer): Integer;
Begin
  Assert(Hours < MaxInt / MsecsPerHour);
  Result := Hours * MsecsPerHour;
End;
Function MinutesToMSecs(Minutes: Integer): Integer;
Begin
  Assert(Minutes < MaxInt div MsecsPerMinute);
  Result := Minutes * MsecsPerMinute;
End;
Function SecondsToMSecs(Seconds: Integer): Integer;
Begin
  Assert(Seconds < MaxInt div 1000);
  Result := Seconds * 1000;
End;
// using system calls this can be done like this:
// var
//  SystemTime: TSystemTime;
// begin
//  ResultCheck(FileTimeToSystemTime(FileTime, SystemTime));
//  Result := SystemTimeToDateTime(SystemTime);
Function FileTimeToDateTime(Const FileTime: TFileTime): TDateTime;
Begin
  Result := Int64(FileTime) / FileTimeStep;
  Result := Result + FileTimeBase;
End;
{$IFDEF MSWINDOWS}
Function FileTimeToLocalDateTime(Const FileTime: TFileTime): TDateTime;
Var
  LocalFileTime: TFileTime;
Begin
  LocalFileTime.dwHighDateTime := 0;
  LocalFileTime.dwLowDateTime := 0;
  ResultCheck(FileTimeToLocalFileTime(FileTime, LocalFileTime));
  Result := FileTimeToDateTime(LocalFileTime);
  { TODO : daylight saving time }
End;
Function LocalDateTimeToFileTime(DateTime: TDateTime): FileTime;
Var
  LocalFileTime: TFileTime;
Begin
  LocalFileTime := DateTimeToFileTime(DateTime);
  Result.dwHighDateTime := 0;
  Result.dwLowDateTime := 0;
  ResultCheck(LocalFileTimeToFileTime(LocalFileTime, Result));
  { TODO : daylight saving time }
End;
{$ENDIF MSWINDOWS}
Function DateTimeToFileTime(DateTime: TDateTime): TFileTime;
Var
  E: Extended;
  F64: Int64;
Begin
  E := (DateTime - FileTimeBase) * FileTimeStep;
  F64 := Round(E);
  Result := TFileTime(F64);
End;
{$IFDEF MSWINDOWS}
Function DosDateTimeToSystemTime(Const DosTime: TDosDateTime): TSystemTime;
Var
  FileTime: TFileTime;
Begin
  FileTime := DosDateTimeToFileTime(DosTime);
  Result := FileTimeToSystemTime(FileTime);
End;
Function SystemTimeToDosDateTime(Const SystemTime: TSystemTime): TDosDateTime;
Var
  FileTime: TFileTime;
Begin
  FileTime := SystemTimeToFileTime(SystemTime);
  Result := FileTimeToDosDateTime(FileTime);
End;
{$ENDIF MSWINDOWS}
// DosDateTimeToDateTime performs the same action as SysUtils.FileDateToDateTime
// not using SysUtils.FileDateToDateTime this can be done like that:
// var
//  FileTime: TFileTime;
//  SystemTime: TSystemTime;
//  begin
//  ResultCheck(DosDateTimeToFileTime(HiWord(DosTime), LoWord(DosTime), FileTime));
//  ResultCheck(FileTimeToSystemTime(FileTime, SystemTime));
//  Result := SystemTimeToDateTime(SystemTime);
Function DosDateTimeToDateTime(Const DosTime: TDosDateTime): TDateTime;
Begin
  Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.FileDateToDateTime(DosTime);
End;
// DateTimeToDosDateTime performs the same action as SysUtils.DateTimeToFileDate
// not using SysUtils.DateTimeToDosDateTime this can be done like that:
// var
//  SystemTime: TSystemTime;
//  FileTime: TFileTime;
//  Date, Time: Word;
// begin
//  DateTimeToSystemTime(DateTime, SystemTime);
//  ResultCheck(SystemTimeToFileTime(SystemTime, FileTime));
//  ResultCheck(FileTimeToDosDateTime(FileTime, Date, Time));
//  Result := (Date shl 16) or Time;
Function DateTimeToDosDateTime(Const DateTime: TDateTime): TDosDateTime;
Begin
  Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.DateTimeToFileDate(DateTime);
End;
{$IFDEF MSWINDOWS}
Function FileTimeToSystemTime(Const FileTime: TFileTime): TSystemTime; overload;
Begin
  ResultCheck({$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.FileTimeToSystemTime(FileTime, Result));
End;
Procedure FileTimeToSystemTime(Const FileTime: TFileTime; out ST: TSystemTime); overload;
Begin
  {$IFDEF FPC}
  ST.Day := 0;
  {$ENDIF FPC}
  {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.FileTimeToSystemTime(FileTime, ST);
End;
Function SystemTimeToFileTime(Const SystemTime: TSystemTime): TFileTime;  overload;
Begin
  Result.dwHighDateTime := 0;
  Result.dwLowDateTime := 0;
  ResultCheck({$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.SystemTimeToFileTime(SystemTime, Result));
End;
Procedure SystemTimeToFileTime(Const SystemTime: TSystemTime; FTime: TFileTime); overload;
Begin
  {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.SystemTimeToFileTime(SystemTime, FTime);
End;
Function DateTimeToSystemTime(DateTime: TDateTime): TSystemTime;  overload;
Begin
  {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.DateTimeToSystemTime(DateTime, Result);
End;
Procedure DateTimeToSystemTime(DateTime: TDateTime; out SysTime: TSystemTime); overload;
Begin
  {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.DateTimeToSystemTime(DateTime, SysTime);
End;
Function DosDateTimeToFileTime(DosTime: TDosDateTime): TFileTime; overload;
Begin
  Result.dwHighDateTime := 0;
  Result.dwLowDateTime := 0;
  ResultCheck({$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.DosDateTimeToFileTime(HIWORD(DosTime), LOWORD(DosTime), Result));
End;
Procedure DosDateTimeToFileTime(DTH, DTL: Word; FT: TFileTime); overload;
Begin
  {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.DosDateTimeToFileTime(DTH, DTL, FT);
End;
Function FileTimeToDosDateTime(Const FileTime: TFileTime): TDosDateTime; overload;
Var
  Date, Time: Word;
Begin
  Date := 0;
  Time := 0;
  ResultCheck({$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.FileTimeToDosDateTime(FileTime, Date, Time));
  Result := (Date shl 16) or Time;
End;
Procedure FileTimeToDosDateTime(Const FileTime: TFileTime; out Date, Time: Word); overload;
Begin
  Date := 0;
  Time := 0;
  {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.FileTimeToDosDateTime(FileTime, Date, Time);
End;
{$ENDIF MSWINDOWS}
Function FileTimeToStr(Const FileTime: TFileTime): string;
Var
  DateTime: TDateTime;
Begin
  DateTime := FileTimeToDateTime(FileTime);
  Result := DateTimeToStr(DateTime);
End;
Function DosDateTimeToStr(DateTime: Integer): string;
Begin
  Result := DateTimeToStr(DosDateTimeToDateTime(DateTime));
End;
{$IFDEF MSWINDOWS}
// we can't do this better without copying Borland-owned code from the Delphi VCL,
// as the straight forward conversion doing exactly this task is hidden
// deeply inside SysUtils.pas.
// So the date is converted forth and back to/from Julian date
// If someone needs a faster version please take a look at SysUtils.pas->DateTimeToStr.
Function SystemTimeToStr(Const SystemTime: TSystemTime): string;
Begin
  Result := DateTimeToStr(SystemTimeToDateTime(SystemTime));
End;
Function CreationDateTimeOfFile(Const Sr: TSearchRec): TDateTime;
Begin
  Result := FileTimeToDateTime(Sr.FindData.ftCreationTime);
End;
Function LastAccessDateTimeOfFile(Const Sr: TSearchRec): TDateTime;
Begin
  Result := FileTimeToDateTime(Sr.FindData.ftLastAccessTime);
End;
Function LastWriteDateTimeOfFile(Const Sr: TSearchRec): TDateTime;
Begin
  Result := FileTimeToDateTime(Sr.FindData.ftLastWriteTime);
End;
{$ENDIF MSWINDOWS}
// Additional format tokens (also available in upper case):
// w: Week no according to ISO
// ww: Week no according to ISO forced two digits
// i: Year of the ISO-week denoted by w (4 digits for 1000..9999)
// ii: Year of the ISO-week denoted by w forced two digits
// e: Number of the Day in the ISO-week denoted by w (ISO-Notation 1=Monday...)
// f: Number of the Day in the year denoted by y
// fff: Number of the Day in the year denoted by y forced three digits
Function FormatDateTime(Form: string; DateTime: TDateTime): string;
Var
  N: Integer;
  ISODay, ISOWeek, ISOYear, DayOfYear, YY: Integer;
  Procedure Digest;
  Begin
    If N > 1 Then
    Begin
      Result := Result + Copy(Form, 1, N - 1);
      Delete(Form, 1, N - 1);
      N := 1;
    End;
  End;
Begin
  ISOWeek := 0;
  DayOfYear := 0;
  Result := '';
  N := 1;
  While N <= Length(Form) Do
  Begin
    Case Form[N] Of
      '"':
        Begin
          Inc(N);
          Digest;
          N := Pos('"', Form);
          If N = 0 Then
          Begin
            Result := Result + Form;
            Form := '';
            N := 1;
          End
          Else
          Begin
            Inc(N);
            Digest;
          End;
        End;
      '''':
        Begin
          Inc(N);
          Digest;
          N := Pos('''', Form);
          If N = 0 Then
          Begin
            Result := Result + Form;
            Form := '';
            N := 1;
          End
          Else
          Begin
            Inc(N);
            Digest;
          End;
        End;
      'i', 'I':             //ISO Week Year
        Begin
          Digest;
          If ISOWeek = 0 Then
            ISOWeek := ISOWeekNumber(DateTime, ISOYear, ISODay);
          If (Length(Form) > 1) and ((Form[2] = 'i') or (Form[2] = 'I')) Then
          Begin              // <ii>
            If (Length(Form) > 2) and ((Form[3] = 'i') or (Form[3] = 'I')) Then
            Begin
              If (Length(Form) > 3) and ((Form[4] = 'i') or (Form[4] = 'I')) Then
              Begin        // <iiii>
                Delete(Form, 1, 4);
                Result := Result + '"' + IntToStr(ISOYear) + '"';
              End
              Else
              Begin        // <iii>
                Delete(Form, 1, 3);
                Result := Result + '"' + IntToStr(ISOYear) + '"';
              End;
            End
            Else
            Begin           // <ii>
              Delete(Form, 1, 2);
              Result := Result + '"';
              If ISOYear < 10 Then
                Result := Result + '0';
              YY := ISOYear mod 100;
              If YY < 10 Then
                Result := Result + '0';
              Result := Result + IntToStr(YY) + '"';
            End;
          End
          Else
          Begin               // <i>
            Delete(Form, 1, 1);
            Result := Result + '"' + IntToStr(ISOYear) + '"';
          End;
        End;
      'w', 'W':              // ISO Week
        Begin
          Digest;
          If ISOWeek = 0 Then
            ISOWeek := ISOWeekNumber(DateTime, ISOYear, ISODay);
          If (Length(Form) > 1) and ((Form[2] = 'w') or (Form[2] = 'W')) Then
          Begin               // <ww>
            Delete(Form, 1, 2);
            Result := Result + '"';
            If ISOWeek < 10 Then
              Result := Result + '0';
            Result := Result + IntToStr(ISOWeek) + '"';
          End
          Else
          Begin               // <w>
            Delete(Form, 1, 1);
            Result := Result + '"' + IntToStr(ISOWeek) + '"';
          End;
        End;
      'e', 'E':   // ISO Week Day
        Begin
          Digest;
          If ISOWeek = 0 Then
            ISOWeek := ISOWeekNumber(DateTime, ISOYear, ISODay);
          Delete(Form, 1, 1);
          Result := Result + '"' + IntToStr(ISODay) + '"';
        End;
      'f', 'F':   // Day of the Year
        Begin
          Digest;
          If DayOfYear = 0 Then
            DayOfYear := DayOfTheYear(DateTime);
          If (Length(Form) > 1) and ((Form[2] = 'f') or (Form[2] = 'F')) Then
          Begin
            If (Length(Form) > 2) and ((Form[3] = 'f') or (Form[3] = 'F')) Then
            Begin            // <fff>
              Delete(Form, 1, 3);
              Result := Result + '"';
              If DayOfYear < 10 Then
                Result := Result + '0';
              If DayOfYear < 100 Then
                Result := Result + '0';
              Result := Result + IntToStr(DayOfYear) + '"';
            End
            Else
            Begin            // <ff>
              Delete(Form, 1, 2);
              Result := Result + '"';
              If DayOfYear < 10 Then
                Result := Result + '0';
              Result := Result + IntToStr(DayOfYear) + '"';
            End;
          End
          Else
          Begin               // <f>
            Delete(Form, 1, 1);
            Result := Result + '"' + IntToStr(DayOfYear) + '"';
          End
        End;
    Else
      Inc(N);
    End;
  End;
  Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.FormatDateTime(Result + Form, DateTime);
End;
// FAT has a granularity of 2 seconds
// The intervals are 1/10 of a second
Function FATDatesEqual(Const FileTime1, FileTime2: Int64): Boolean;
Const
  ALLOWED_FAT_FILE_TIME_VARIATION = 20;
Begin
  Result := Abs(FileTime1 - FileTime2) <= ALLOWED_FAT_FILE_TIME_VARIATION;
End;
Function FATDatesEqual(Const FileTime1, FileTime2: TFileTime): Boolean;
Begin
  Result := FATDatesEqual(Int64(FileTime1), Int64(FileTime2));
End;
// Conversion Unix time <--> TDateTime
Function DateTimeToUnixTime(DateTime: TDateTime): TJclUnixTime32;
Begin
  Result := Round((DateTime-UnixTimeStart) * SecondsPerDay);
End;
Function UnixTimeToDateTime(Const UnixTime: TJclUnixTime32): TDateTime;
Begin
  Result:= UnixTimeStart + (UnixTime / SecondsPerDay);
End;
// Conversion Unix time <--> FileTime
{$IFDEF MSWINDOWS}
Function UnixTimeToFileTime(Const AValue: TJclUnixTime32): TFileTime;
Begin
  Result := DateTimeToFileTime(UnixTimeToDateTime(AValue));
End;
Function FileTimeToUnixTime(Const AValue: TFileTime): TJclUnixTime32;
Begin
 Result := DateTimeToUnixTime(FileTimeToDateTime(AValue));
End;
{$ENDIF MSWINDOWS}
// Time stamps utilities
// Utility functions
Function NullStamp: TTimeStamp;
Begin
  Result.Date := 0;
  Result.Time := -1;
End;
Function CompareTimeStamps(Const Stamp1, Stamp2: TTimeStamp): Int64;
Begin
  If Stamp1.Date < Stamp2.Date Then
    Result := -1
  Else
  If Stamp1.Date = Stamp2.Date Then
  Begin
    If Stamp1.Time < Stamp2.Time Then
      Result := -1
    Else
    If Stamp1.Time = Stamp2.Time Then
      Result := 0
    Else // If Stamp1.Time > Stamp2.Time then
      Result := 1;
  End
  Else // if Stamp1.Date > Stamp2.Date then
    Result := 1;
//  Result := Int64(Stamp1) - Int64(Stamp2);
End;
Function EqualTimeStamps(Const Stamp1, Stamp2: TTimeStamp): Boolean;
Begin
  Result := CompareTimeStamps(Stamp1, Stamp2) = 0;
End;
Function IsNullTimeStamp(Const Stamp: TTimeStamp): Boolean;
Begin
  Result := CompareTimeStamps(NullStamp, Stamp) = 0;
End;
Function TimeStampDOW(Const Stamp: TTimeStamp): Integer;
Begin
  Result := (Stamp.Date - 1) mod 7 + 1
End;
// day of week utilities
Function FirstWeekDay(Const Year, Month: Integer; out DOW: Integer): Integer;
Begin
  DOW := ISODayOfWeek(EncodeDate(Year, Month, 1));
  If DOW > 5 Then
  Begin
    Result := 9 - DOW;
    DOW := 1;
  End
  Else
    Result := 1;
End;
Function FirstWeekDay(Const Year, Month: Integer): Integer;
Var
  Dummy: Integer;
Begin
  Result := FirstWeekDay(Year, Month, Dummy);
End;
Function LastWeekDay(Const Year, Month: Integer; out DOW: Integer): Integer;
Begin
  DOW := ISODayOfWeek(EncodeDate(Year, Month, DaysInMonth(EncodeDate(Year, Month, 1))));
  If DOW > 5 Then
  Begin
    Result := DaysInMonth(EncodeDate(Year, Month, 1)) - (DOW - 5);
    DOW := 5;
  End
  Else
    Result := DaysInMonth(EncodeDate(Year, Month, 1));
End;
Function LastWeekDay(Const Year, Month: Integer): Integer;
Var
  Dummy: Integer;
Begin
  Result := LastWeekDay(Year, Month, Dummy);
End;
Function IndexedWeekDay(Const Year, Month: Integer; Index: Integer): Integer;
Var
  DOW: Integer;
Begin
  If Index > 0 Then
    Result := FirstWeekDay(Year, Month, DOW)
  Else
  If Index < 0 Then
    Result := LastWeekDay(Year, Month, DOW)
  Else
    Result := 0;
  If Index > 1 Then                   // n-th weekday from start of month
  Begin
    Dec(Index);
    If DOW > 1 Then                   // adjust to first monday
    Begin
      If Index < (5 - DOW) Then
      Begin
        Inc(Result, Index);
        Index := 0;
      End
      Else
      Begin
        Dec(Index, 6 - DOW);
        Inc(Result, 8 - DOW);
      End;
    End;
    Result := Result + (7 * (Index div 5)) + (Index mod 5);
  End
  Else
  If Index < -1 Then             // n-th weekday from end of month
  Begin
    Index := Abs(Index) - 1;
    If DOW < 5 Then                   // adjust to last friday
    Begin
      If Index < DOW Then
      Begin
        Dec(Result, Index);
        Index := 0;
      End
      Else
      Begin
        Dec(Index, DOW);
        Dec(Result, DOW + 2);
      End;
    End;
    Result := Result - (7 * (Index div 5)) - (Index mod 5);
  End;
  If (Result < 0) or (Result > DaysInMonth(EncodeDate(Year, Month, 1))) Then
    Result := 0;
End;
Function FirstWeekendDay(Const Year, Month: Integer; out DOW: Integer): Integer;
Begin
  DOW := ISODayOfWeek(EncodeDate(Year, Month, 1));
  If DOW < 6 Then
  Begin
    Result := 7 - DOW;
    DOW := 6;
  End
  Else
    Result := 1;
End;
Function FirstWeekendDay(Const Year, Month: Integer): Integer;
Var
  Dummy: Integer;
Begin
  Result := FirstWeekendDay(Year, Month, Dummy);
End;
Function LastWeekendDay(Const Year, Month: Integer; out DOW: Integer): Integer;
Begin
  DOW := ISODayOfWeek(EncodeDate(Year, Month, DaysInMonth(EncodeDate(Year, Month, 1))));
  If DOW < 6 Then
  Begin
    Result := DaysInMonth(EncodeDate(Year, Month, 1)) - DOW;
    DOW := 7;
  End
  Else
    Result := DaysInMonth(EncodeDate(Year, Month, 1));
End;
Function LastWeekendDay(Const Year, Month: Integer): Integer;
Var
  Dummy: Integer;
Begin
  Result := LastWeekendDay(Year, Month, Dummy);
End;
Function IndexedWeekendDay(Const Year, Month: Integer; Index: Integer): Integer;
Var
  DOW: Integer;
Begin
  If Index > 0 Then
    Result := FirstWeekendDay(Year, Month, DOW)
  Else
  If Index < 0 Then
    Result := LastWeekendDay(Year, Month, DOW)
  Else
    Result := 0;
  If Index > 1 Then                         // n-th weekend day from the start of the month
  Begin
    If (DOW > 6) and not Odd(Index) Then   // Adjust to first saturday
    Begin
      Inc(Result, 6);
      Dec(Index);
    End;
    If Index > 1 Then
    Begin
      Dec(Index);
      Result := Result + (7 * (Index div 2)) + (Index mod 2);
    End;
  End
  Else
  If Index < -1 Then                   // n-th weekend day from the start of the month
  Begin
    Index := Abs(Index);
    If (DOW < 7) and not Odd(Index) Then    // Adjust to last sunday
    Begin
      Dec(Result, 6);
      Dec(Index);
    End;
    If Index > 1 Then
    Begin
      Dec(Index);
      Result := Result - (7 * (Index div 2)) - (Index mod 2);
    End;
  End;
  If (Result < 0) or (Result > DaysInMonth(EncodeDate(Year, Month, 1))) Then
    Result := 0;
End;
Function FirstDayOfWeek(Const Year, Month, DayOfWeek: Integer): Integer;
Var
  DOW: Integer;
Begin
  DOW := ISODayOfWeek(EncodeDate(Year, Month, 1));
  If DOW > DayOfWeek Then
    Result := 8 + DayOfWeek - DOW
  Else
  If DOW < DayOfWeek Then
    Result := 1 + DayOfWeek - DOW
  Else
    Result := 1;
End;
Function LastDayOfWeek(Const Year, Month, DayOfWeek: Integer): Integer;
Var
  DOW: Integer;
Begin
  DOW := ISODayOfWeek(EncodeDate(Year, Month, DaysInMonth(EncodeDate(Year, Month, 1))));
  If DOW > DayOfWeek Then
    Result := DaysInMonth(EncodeDate(Year, Month, 1)) - (DOW - DayOfWeek)
  Else
  If DOW < DayOfWeek Then
    Result := DaysInMonth(EncodeDate(Year, Month, 1)) - (7 - DayOfWeek + DOW)
  Else
    Result := DaysInMonth(EncodeDate(Year, Month, 1));
End;
Function IndexedDayOfWeek(Const Year, Month, DayOfWeek, Index: Integer): Integer;
Begin
  If Index > 0 Then
    Result := FirstDayOfWeek(Year, Month, DayOfWeek) + 7 * (Index - 1)
  Else
  If Index < 0 Then
    Result := LastDayOfWeek(Year, Month, DayOfWeek) - 7 * (Abs(Index) - 1)
  Else
    Result := 0;
  If (Result < 0) or (Result > DaysInMonth(EncodeDate(Year, Month, 1))) Then
    Result := 0;
End;
{$IFDEF UNITVERSIONING}
Initialization
 RegisterUnitVersion(HInstance, UnitVersioning);
Finalization
 UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
End.
