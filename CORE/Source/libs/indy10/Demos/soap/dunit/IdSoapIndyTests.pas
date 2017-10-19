{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16393: IdSoapIndyTests.pas
{
{   Rev 1.2    23/6/2003 15:15:20  GGrieve
{ fix for V#1
}
{
{   Rev 1.1    19/6/2003 21:35:52  GGrieve
{ Version #1
}
{
{   Rev 1.0    25/2/2003 13:27:36  GGrieve
}
{
  IndySoap used to use the indy decoders, but the old ones were slow,
  and fixing them introduced version issues. So now we have our own.
  Hence we test them, but the unit is called "indy tests"
}
{
Version History:
  23-Jun 2003   Grahame Grieve                  add unit to uses clause
  19 Jun 2003   Grahame Grieve                  fix for line breaks in Base64
  27-Aug 2002   Grahame Grieve                  Linux Fixes
  17-Aug 2002   Grahame Grieve                  remove test for email bug - not relevent
  06-Aug 2002   Grahame Grieve                  Add tests for email bug - someone still needs to fix
  14-Mar 2002   Grahame Grieve                  Improve MIME Encoding tests
  12-Mar 2002   Grahame Grieve                  First Test (MIME Encoding)
}

unit IdSoapIndyTests;

interface

uses
  TestFramework;

type
  TIndyBase64Tests = class (TTestCase)
  private
    procedure DoTest(ASize : integer);
  published
    procedure TestBase64EncodingEmpty;
    procedure TestBase64Encoding200;
    procedure TestBase64Encoding2000;
    procedure TestBase64Encoding20000;
    procedure TestBase64Encoding200000;
    procedure TestBase64Encoding2000000;
  end;

implementation

uses
  Classes,
  IdSoapBase64,
  IdSoapTestingUtils,
  IdSoapUtilities,
  SysUtils;

{ TIndyBase64Tests }

procedure TIndyBase64Tests.DoTest(ASize: integer);
var
  LStream1 : TMemoryStream;
  LStream2 : TMemoryStream;
  LString : string;
  LOK : boolean;
begin
  LStream1 := TMemoryStream.create;
  try
    FillTestingStream(LStream1, ASize);
    LStream2 := IdSoapBase64Decode(IdSoapBase64Encode(LStream1, False));
    try
      LStream1.Position := 0;
      LStream2.Position := 0;
      LOK := TestStreamsIdentical(LStream1, LStream2, LString);
      check(LOK, LString);
    finally
      FreeAndNil(LStream2);
    end;
    LStream2 := IdSoapBase64Decode(IdSoapBase64Encode(LStream1, True));
    try
      LStream1.Position := 0;
      LStream2.Position := 0;
      LOK := TestStreamsIdentical(LStream1, LStream2, LString);
      check(LOK, LString);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream1);
  end;
end;

procedure TIndyBase64Tests.TestBase64Encoding200;
begin
  Dotest(97);
  Dotest(98);
  Dotest(99);
  Dotest(100);
end;

procedure TIndyBase64Tests.TestBase64Encoding2000;
begin
  Dotest(2000);
end;

procedure TIndyBase64Tests.TestBase64Encoding20000;
begin
  Dotest(20000);
  Dotest(20000);
end;

procedure TIndyBase64Tests.TestBase64Encoding200000;
begin
  Dotest(200000);
end;

procedure TIndyBase64Tests.TestBase64Encoding2000000;
begin
  Dotest(2000000);
end;

procedure TIndyBase64Tests.TestBase64EncodingEmpty;
begin
  DoTest(0);
end;

end.

