{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16387: IdSoapDateTimeTests.pas 
{
{   Rev 1.0    25/2/2003 13:27:18  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  06-Apr 2002   Andrew Cumming                  Name change for NanoSeconds
  05-Apr 2002   Grahame Grieve                  Remove Hints and warnings
  04-Apr 2002   Andrew Cumming                  Fixed for D4
  03-Apr 2002   Grahame Grieve                  Date Time Tests changed to class based TIdSoapDateTime
  02-Apr 2002   Grahame Grieve                  Date Time Tests added
}

unit IdSoapDateTimeTests;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  TestFramework;

type
  TIdSoapDateTimeTests = class (TTestCase)
  published
    procedure Test_IdSoapReadDateTime;
    procedure Test_IdSoapReadDate;
    procedure Test_IdSoapReadTime;
    procedure Test_ConversionRoutines;
  end;

implementation

uses
  IdSoapDateTime,
  IdSoapUtilities,
  SysUtils;

{ TIdSoapDateTimeTests }

procedure TIdSoapDateTimeTests.Test_IdSoapReadDateTime;
var
  LDate : TIdSoapDateTime;
begin
  LDate := TIdSoapDateTime.create;
  try
    LDate.AsXMLString := '1999-05-31T13:20:00-05:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Hour = 13);
    check(LDate.Minute = 20);
    check(LDate.Second = 0);
    check(LDate.Nanosecond = 0);
    check(LDate.Timezone = tzNegative);
    check(LDate.tzHours = 5);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31T13:20:00-05:00');
  finally
    FreeAndNil(LDate);
  end;

  LDate := TIdSoapDateTime.create;
  try
    LDate.AsXMLString := '1999-05-31T13:20:00.001-05:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Hour = 13);
    check(LDate.Minute = 20);
    check(LDate.Second = 0);
    check(LDate.Nanosecond = 1000000);
    check(LDate.Timezone = tzNegative);
    check(LDate.tzHours = 5);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31T13:20:00.001-05:00');
  finally
    FreeAndNil(LDate);
  end;

  LDate := TIdSoapDateTime.create;
  try
    LDate.AsXMLString := '1999-05-31T13:20:00.001001001-05:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Hour = 13);
    check(LDate.Minute = 20);
    check(LDate.Second = 0);
    check(LDate.Nanosecond = 1001001);
    check(LDate.Timezone = tzNegative);
    check(LDate.tzHours = 5);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31T13:20:00.001001001-05:00');
  finally
    FreeAndNil(LDate);
  end;

  LDate := TIdSoapDateTime.create;
  try
    LDate.AsXMLString := '1999-05-31T13:20:00.001001001454-05:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Hour = 13);
    check(LDate.Minute = 20);
    check(LDate.Second = 0);
    check(LDate.Nanosecond = 1001001);
    check(LDate.Timezone = tzNegative);
    check(LDate.tzHours = 5);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31T13:20:00.001001001-05:00');
  finally
    FreeAndNil(LDate);
  end;

  LDate := TIdSoapDateTime.create;
  try
    LDate.AsXMLString := '1999-05-31T13:20:00+05:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Hour = 13);
    check(LDate.Minute = 20);
    check(LDate.Second = 0);
    check(LDate.Nanosecond = 0);
    check(LDate.Timezone = tzPositive);
    check(LDate.tzHours = 5);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31T13:20:00+05:00');
  finally
    FreeAndNil(LDate);
  end;

  LDate := TIdSoapDateTime.create;
  try
    LDate.AsXMLString := '1999-05-31T13:20:00Z';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Hour = 13);
    check(LDate.Minute = 20);
    check(LDate.Second = 0);
    check(LDate.Nanosecond = 0);
    check(LDate.Timezone = tzUTC);
    check(LDate.tzHours = 0);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31T13:20:00Z');
  finally
    FreeAndNil(LDate);
  end;

  LDate := TIdSoapDateTime.create;
  try
    LDate.AsXMLString := '1999-05-31T13:20:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Hour = 13);
    check(LDate.Minute = 20);
    check(LDate.Second = 0);
    check(LDate.Nanosecond = 0);
    check(LDate.Timezone = tzUnknown);
    check(LDate.tzHours = 0);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31T13:20:00');
  finally
    FreeAndNil(LDate);
  end;

end;

procedure TIdSoapDateTimeTests.Test_IdSoapReadDate;
var
  LDate : TIdSoapDate;
begin
  LDate := TIdSoapDate.Create;
  try
    LDate.AsXMLString := '1999-05-31';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Timezone = tzUnknown);
    check(LDate.tzHours = 0);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31');
  finally
    FreeAndNil(LDate)
  end;

  LDate := TIdSoapDate.Create;
  try
    LDate.AsXMLString := '1999-05-31Z';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Timezone = tzUTC);
    check(LDate.tzHours = 0);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31Z');
  finally
    FreeAndNil(LDate)
  end;

  LDate := TIdSoapDate.Create;
  try
    LDate.AsXMLString := '1999-05-31-05:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Timezone = tzNegative);
    check(LDate.tzHours = 5);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31-05:00');
  finally
    FreeAndNil(LDate)
  end;

  LDate := TIdSoapDate.Create;
  try
    LDate.AsXMLString := '1999-05-31+05:00';
    check(LDate.Year = 1999);
    check(LDate.Month = 5);
    check(LDate.Day = 31);
    check(LDate.Timezone = tzPositive);
    check(LDate.tzHours = 5);
    check(LDate.tzMinutes = 0);
    check(LDate.AsXMLString = '1999-05-31+05:00');
  finally
    FreeAndNil(LDate)
  end;
end;

procedure TIdSoapDateTimeTests.Test_IdSoapReadTime;
var
  LTime : TIdSoapTime;
begin
  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 0);
    check(LTime.Timezone = tzUnknown);
    check(LTime.tzHours = 0);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01');
  finally
    FreeAndNil(LTime);
  end;

  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01.1';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 100000000);
    check(LTime.Timezone = tzUnknown);
    check(LTime.tzHours = 0);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01.1');
  finally
    FreeAndNil(LTime);
  end;

  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01.001001001';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 1001001);
    check(LTime.Timezone = tzUnknown);
    check(LTime.tzHours = 0);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01.001001001');
  finally
    FreeAndNil(LTime);
  end;

  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01.001001001765';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 1001001);
    check(LTime.Timezone = tzUnknown);
    check(LTime.tzHours = 0);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01.001001001');
  finally
    FreeAndNil(LTime);
  end;

  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01.001001001765Z';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 1001001);
    check(LTime.Timezone = tzUTC);
    check(LTime.tzHours = 0);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01.001001001Z');
  finally
    FreeAndNil(LTime);
  end;

  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01Z';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 0);
    check(LTime.Timezone = tzUTC);
    check(LTime.tzHours = 0);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01Z');
  finally
    FreeAndNil(LTime);
  end;

  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01+04:00';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 0);
    check(LTime.Timezone = tzPositive);
    check(LTime.tzHours = 4);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01+04:00');
  finally
    FreeAndNil(LTime);
  end;

  LTime := TIdSoapTime.create;
  try
    LTime.AsXMLString := '13:20:01-04:00';
    Check(LTime.Hour = 13);
    Check(LTime.Minute = 20);
    Check(LTime.Second = 01);
    Check(LTime.Nanosecond = 0);
    check(LTime.Timezone = tzNegative);
    check(LTime.tzHours = 4);
    check(LTime.tzMinutes = 0);
    check(LTime.AsXMLString = '13:20:01-04:00');
  finally
    FreeAndNil(LTime);
  end;
end;

procedure TIdSoapDateTimeTests.Test_ConversionRoutines;
var
  LDate, LDate2 : TDateTime;
  LIdDateTime : TIdSoapDateTime;
  LIdDate : TIdSoapDate;
  LIdTime : TIdSoapTime;
begin
  LDate := trunc(now);
  LIdDateTime := TIdSoapDateTime.create;
  try
    LIdDateTime.AsDateTime := LDate;
    LDate2 := LIdDateTime.AsDateTime;
  finally
    FreeAndNil(LIdDateTime);
  end;
  check(LDate2 = LDate);

  LDate := 0.01;
  LIdDateTime := TIdSoapDateTime.create;
  try
    LIdDateTime.AsDateTime := LDate;
    LDate2 := LIdDateTime.AsDateTime;
  finally
    FreeAndNil(LIdDateTime);
  end;
  check(LDate2 = LDate);

  LDate := now;
  LIdDateTime := TIdSoapDateTime.create;
  try
    LIdDateTime.AsDateTime := LDate;
    LDate2 := LIdDateTime.AsDateTime;
  finally
    FreeAndNil(LIdDateTime);
  end;
  check(LDate2 = LDate);

  LDate := 0;
  LIdDateTime := TIdSoapDateTime.create;
  try
    LIdDateTime.AsDateTime := LDate;
    LDate2 := LIdDateTime.AsDateTime;
  finally
    FreeAndNil(LIdDateTime);
  end;
  check(LDate2 = LDate);



  LDate := 0;
  LIdTime := TIdSoapTime.create;
  try
    LIdTime.AsDateTime := LDate;
    LDate2 := LIdTime.AsDateTime;
  finally
    FreeAndNil(LIdTime);
  end;
  check(LDate2 = LDate);

  LDate := EncodeTime(2,0,0, 0);
  LIdTime := TIdSoapTime.create;
  try
    LIdTime.AsDateTime := LDate;
    LDate2 := LIdTime.AsDateTime;
  finally
    FreeAndNil(LIdTime);
  end;
  check(LDate2 = LDate);

  LDate := EncodeTime(23,55,1, 545);
  LIdTime := TIdSoapTime.create;
  try
    LIdTime.AsDateTime := LDate;
    LDate2 := LIdTime.AsDateTime;
  finally
    FreeAndNil(LIdTime);
  end;
  check(LDate2 = LDate);

  LDate := trunc(now);
  LIdDate := TIdSoapDate.create;
  try
    LIdDate.AsDateTime := LDate;
    LDate2 := LIdDate.AsDateTime;
  finally
    FreeAndNil(LIdDate);
  end;
  check(LDate2 = LDate);

  LDate := 0;
  LIdDate := TIdSoapDate.create;
  try
    LIdDate.AsDateTime := LDate;
    LDate2 := LIdDate.AsDateTime;
  finally
    FreeAndNil(LIdDate);
  end;
  check(LDate2 = LDate);
  
end;

end.
