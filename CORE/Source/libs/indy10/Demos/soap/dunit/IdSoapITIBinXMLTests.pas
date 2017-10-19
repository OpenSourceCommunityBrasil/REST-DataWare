{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16406: IdSoapITIBinXMLTests.pas 
{
{   Rev 1.0    25/2/2003 13:28:08  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  21-Aug 2002   Grahame Grieve                  Add Tests for renaming names and types
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  14-Mar 2002   Andrew Cumming                  Added code for Application.ProcessMessages equiv to TearDown
  14-Mar 2002   Grahame Grieve                  Fix check identity name
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
  03-Feb 2002   Andrew Cumming                  Added D4 support
}

unit IdSoapITIBinXMLTests;

{$I IdSoapDefines.inc}

interface

uses
  TestFramework,
  IdSoapITI;

type
  TITIStreamCase = class(TTestCase)
  Private
    FITI: TIdSoapITI;
  Protected
    procedure Setup; Override;
    procedure TearDown; Override;
  Published
    procedure TestBin;
    procedure TestXML;
  end;

implementation

uses
  Classes,
  IdSoapTestingUtils,
  IdSoapExceptions,
  IdSoapITIBin,
  IdSoapITIXML,
  IdSoapUtilities,
  SysUtils,
  TypInfo;

 {

 The structure of these tests is fairly straight forward.
 We will create an ITI of the required complexity. Then
 we will write it to a file, read it back, write it
 to another file, and compare them. If they do not match byte for
 byte, then we hold that the test has failed

 }

{ TITIStreamCase }

procedure TITIStreamCase.Setup;
begin
  FITI := CreatePopulatedITI;
end;

procedure TITIStreamCase.TearDown;
begin
  FreeAndNil (FITI);
  IdSoapProcessMessages;
end;

procedure TITIStreamCase.TestBin;
var LITI:TIdSoapITI;
    LBin : TIdSoapITIBinStreamer;
    LS1 : TStringStream;
    LS2 : TStringStream;
    s1, s2 : string;
begin
  CheckPopulatedITI(FITI);
  LITI := TIdSoapITI.create;
  try
    LBin := TIdSoapITIBinStreamer.create;
    try
      LS1 := TStringStream.create('');
      try
        LBin.SaveToStream(FITI, LS1);
        s1 := LS1.DataString;
        LS1.Position := 0;
        LBin.ReadFromStream(LITI, LS1);
        CheckPopulatedITI(LITI);
        LS2 := TStringStream.create('');
        try
          LBin.SaveToStream(LITI, LS2);
          s2 := LS2.DataString;
        finally
          FreeAndNil(LS2);
          end;
      finally
        FreeAndNil(LS1);
      end;
    finally
      FreeAndNil(LBin);
    end;
  finally
    LITI.free;
  end;
  Check(s1 = s2, 'Binary Encoder Failed');
end;

procedure TITIStreamCase.TestXML;
var LITI:TIdSoapITI;
    LXML : TIdSoapITIXMLStreamer;
    LS1 : TStringStream;
    LS2 : TStringStream;
    s1, s2 : string;
begin
  CheckPopulatedITI(FITI);
  LITI := TIdSoapITI.create;
  try
    LXML := TIdSoapITIXMLStreamer.create;
    try
      LS1 := TStringStream.create('');
      try
        LXML.SaveToStream(FITI, LS1);
        s1 := LS1.DataString;
        LS1.Position := 0;
        LXML.ReadFromStream(LITI, LS1);
        CheckPopulatedITI(LITI);
        LS2 := TStringStream.create('');
        try
          LXML.SaveToStream(LITI, LS2);
          s2 := LS2.DataString;
        finally
          FreeAndNil(LS2);
          end;
      finally
        FreeAndNil(LS1);
      end;
    finally
      FreeAndNil(LXML);
    end;
  finally
    LITI.free;
  end;
  Check(s1 = s2, 'XML Encoder Failed');
end;

end.
