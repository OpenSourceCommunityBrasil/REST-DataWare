{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16383: IdSoapBuildersTests.pas 
{
{   Rev 1.0    25/2/2003 13:27:08  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  27-Aug 2002   Grahame Grieve                  Linux Fixes
  26-Aug 2002   Grahame Grieve                  D4 Compiler fixes
  26-Aug 2002   Grahame Grieve                  Fix for various SoapBuilder problems
  21-Aug 2002   Grahame Grieve                  Fix namespace issue
  17-Aug 2002   Grahame Grieve                  drop 2nd MS test
  16-Aug 2002   Grahame Grieve                  Fix date equals checking
  15 Aug 2002   Grahame Grieve                  Live SoapBuilders tests in DUnit testing
}

unit IdSoapBuildersTests;

interface

Uses
  IdHTTP,
  IdSoapClient,
  Interop,
  TestExtensions,
  TestFramework;

type
  TIdSoapShortBuildersTests = class (TTestCase)
  published
    procedure TestEchoVoid;
    procedure TestEchoString;
    procedure TestEchoInteger;
    procedure TestEchoFloat;
    procedure TestEchoStruct;
  end;

  TIdSoapBuildersTests = class (TIdSoapShortBuildersTests)
  published
    procedure TestEchoStringArray;
    procedure TestEchoIntegerArray;
    procedure TestEchoFloatArray;
    procedure TestEchoStructArray;
    procedure TestEchoBase64;
    procedure TestEchoDate;
  end;

  TIdSoapBuildersEasySoap = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

  TIdSoapBuildersDolphin = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

  TIdSoapBuildersIona = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

  TIdSoapBuildersKafka = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

  TIdSoapBuildersMSSoap = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

  TIdSoapBuildersMSNet = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

  TIdSoapBuildersSoap4R = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

  TIdSoapBuildersSoapLite = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;

implementation

uses
  Classes,
  {$IFNDEF LINUX}
  Dialogs,
  {$ENDIF}
  IdGlobal,
  {$IFNDEF LINUX}
  IdSoapClientWinInet,
  {$ENDIF}
  IdSoapClientHTTP,
  IdSoapDateTime,
  IdSoapITIProvider,
  IdSoapRPCPacket,
  IdSoapTestingUtils,
  IdSoapUtilities,
  IniFiles,
  SysUtils;

type
  THelper = class
  private
    procedure OnSend(ASender : TIdSoapITIProvider; AStream : TStream);
    procedure OnGet(ASender : TIdSoapITIProvider; AStream : TStream);
  end;

{ THelper }

procedure THelper.OnGet(ASender: TIdSoapITIProvider; AStream: TStream);
begin
//  IdSoapViewStream(AStream, 'xml');
end;

procedure THelper.OnSend(ASender: TIdSoapITIProvider; AStream: TStream);
begin
//  IdSoapViewStream(AStream, 'xml');
// {$IFNDEF LINUX}
//  showmessage('click to send');
// {$ENDIF}
end;


var
  GClient : TIdSoapBaseClient;
  GHTTP : TIdHTTP;
  GIntf : InteropTest;
  GHelper : THelper;

procedure BuildClient(AURL : string; ATypes : boolean = true; AAnyNamespaces : boolean = false);
var
  LIni : TIniFile;
begin
  GHelper := THelper.create;
  LIni := TIniFile.create('IdSoapTestSettings.ini');
  try
    {$IFNDEF LINUX}
    if LIni.ReadBool('Proxy', 'UseIE', true) then
      begin
      GClient := TIdSoapClientWinInet.create(nil);
      (GClient as TIdSoapClientWinInet).SoapURL := AURL;
      end
    else {$ENDIF}
      begin
      GClient := TIdSoapClientHTTP.create(nil);
      (GClient as TIdSoapClientHTTP).SoapURL := AURL;
      GHTTP := TIdHTTP.create(nil);
      (GClient as TIdSoapClientHTTP).HTTPClient := GHTTP;
      GHTTP.ProxyParams.ProxyServer := LIni.ReadString('Proxy', 'Address', '');
      GHTTP.ProxyParams.ProxyPort := LIni.ReadInteger('Proxy', 'Port', 8080);
      GHTTP.ProxyParams.ProxyUsername := LIni.ReadString('Proxy', 'Username', '');
      GHTTP.ProxyParams.ProxyPassword := LIni.ReadString('Proxy', 'Password', '');
      end;
  finally
    FreeAndNil(LIni);
  end;
  GClient.ITISource := islFile;
  GClient.ITIFileName := 'Interop.iti';
  if ATypes Then
    begin
    GClient.EncodingOptions := [seoUseCrLf, seoCheckStrings, seoRequireTypes];
    end
  else
    begin
    GClient.EncodingOptions := [seoUseCrLf, seoCheckStrings];
    end;
  if AAnyNamespaces then
    begin
    GClient.EncodingOptions := GClient.EncodingOptions + [seoArraysAnyNamespace];
    end;
  GClient.OnReceiveMessage := GHelper.OnGet;
  GClient.OnSendMessage := GHelper.OnSend;
  GClient.Active := true;
  GIntf := GetInteropTest(GClient);
end;

{ TIdSoapBuildersTests }

procedure TIdSoapShortBuildersTests.TestEchoVoid;
begin
  GIntf.echoVoid;
end;

const
  TEST_BINARY = 'sdf'#0#1'asdasdf'#255;

procedure TIdSoapBuildersTests.TestEchoBase64;
var
  LStream1, LStream2 : TidMemoryStream;
  s : string;
begin
  LStream1 := TIdMemoryStream.create;
  try
    LStream1.Write(TEST_BINARY[1], length(TEST_BINARY));
    LStream1.Position := 0;
    LStream2 := GIntf.echoBase64(LStream1) as TIdMemoryStream;
    try
      SetLength(s, LStream2.Size);
      LStream2.Read(s[1], LStream2.Size);
      check(s = TEST_BINARY);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream1);
  end;
end;

const
  SECOND_LENGTH = 1 / (24 * 60);
  
procedure TIdSoapBuildersTests.TestEchoDate;
var
  LNow : TDateTime;
  LDate1, LDate2 : TIdSoapDateTime;
begin
  LNow := now;
  LDate1 := TIdSoapDateTime.create;
  try
    LDate1.AsDateTime := LNow;
    LNow := LDate1.AsDateTime; // drop the seconds off
    LDate2 := GIntf.echoDate(LDate1);
    try
      check(abs(LDate2.AsDateTime - LNow) < SECOND_LENGTH, 'dates are different: sent '+LDate1.AsXMLString+', got '+LDate2.AsXMLString);
    finally
      FreeAndNil(LDate2);
    end;
  finally
    FreeAndNil(LDate1);
  end;
end;

procedure TIdSoapShortBuildersTests.TestEchoFloat;
begin
  Check(GIntf.echoFloat(3.5) = 3.5);
end;

procedure TIdSoapBuildersTests.TestEchoFloatArray;
var
  LArrDbl1, LArrDbl2 : ArrayOffloat;
begin
  SetLength(LArrDbl1, 2);
  LArrDbl1[0] := 3.5;
  LArrDbl1[1] := 2.5;
  LArrDbl2 := GIntf.echoFloatArray(LArrDbl1);
  Check(length(LArrDbl2) = 2);
  Check(LArrDbl2[0] = 3.5);
  Check(LArrDbl2[1] = 2.5);
end;

procedure TIdSoapShortBuildersTests.TestEchoInteger;
begin
  Check(GIntf.echoInteger(65540) = 65540);
end;

procedure TIdSoapBuildersTests.TestEchoIntegerArray;
var
  LArrInt1, LArrInt2 : ArrayOfint;
begin
  SetLength(LArrInt1, 2);
  LArrInt1[0] := 3;
  LArrInt1[1] := 0;
  LArrInt2 := GIntf.echoIntegerArray(LArrInt1);
  Check(length(LArrInt2) = 2);
  Check(LArrInt2[0] = 3);
  Check(LArrInt2[1] = 0);
end;

procedure TIdSoapShortBuildersTests.TestEchoString;
begin
  Check(GIntf.echoString('indysoap test') = 'indysoap test');
  Check(GIntf.echoString('') = '');
end;

procedure TIdSoapBuildersTests.TestEchoStringArray;
var
  LArrStr1, LArrStr2 : ArrayOfstring;
begin
  SetLength(LArrStr1, 3);
  LArrStr1[0] := 'test1';
  LArrStr1[1] := 'test2';
  LArrStr1[2] := '';
  LArrStr2 := GIntf.echoStringArray(LArrStr1);
  Check(length(LArrStr2) = 3);
  Check(LArrStr2[0] = 'test1');
  Check(LArrStr2[1] = 'test2');
  Check(LArrStr2[2] = '');
end;

procedure TIdSoapShortBuildersTests.TestEchoStruct;
var
  LStruct1, LStruct2 : SOAPStruct;
begin
  LStruct1 := SOAPStruct.create;
  try
    LStruct1.varString := 'test s 1';
    LStruct1.varInt := 23452;
    LStruct1.varFloat := 3.5;
    LStruct2 := GIntf.echoStruct(LStruct1);
    try
      Check(LStruct2.varString = 'test s 1');
      Check(LStruct2.varInt = 23452);
      Check(LStruct2.varFloat = 3.5);
    finally
      FreeAndNil(LStruct2);
    end;
  finally
    FreeAndNil(LStruct1);
  end;

end;

procedure TIdSoapBuildersTests.TestEchoStructArray;
var
  LStructArr1, LStructArr2 : ArrayOfSOAPStruct;
  i : integer;
begin
  SetLength(LStructArr1, 3);
  LStructArr1[0] := SOAPStruct.create;
  LStructArr1[1] := SOAPStruct.create;
  LStructArr1[2] := SOAPStruct.create;
  try
    LStructArr1[0].varString := 'test1';
    LStructArr1[0].varInt := 3;
    LStructArr1[0].varFloat := 3.5;
    LStructArr1[1].varString := 'as';
    LStructArr1[1].varInt := 1;
    LStructArr1[1].varFloat := -3.5;
    LStructArr1[2].varString := 'sd';
    LStructArr1[2].varInt := -3;
    LStructArr1[2].varFloat := 0.5;
    LStructArr2 := GIntf.echoStructArray(LStructArr1);
    try
      Check(LStructArr2[0].varString = 'test1');
      Check(LStructArr2[0].varInt = 3);
      Check(LStructArr2[0].varFloat = 3.5);
      Check(LStructArr2[1].varString = 'as');
      Check(LStructArr2[1].varInt = 1);
      Check(LStructArr2[1].varFloat = -3.5);
      Check(LStructArr2[2].varString = 'sd');
      Check(LStructArr2[2].varInt = -3);
      Check(LStructArr2[2].varFloat = 0.5);
    finally
      for i := Low(LStructArr2) to High(LStructArr2) do
        begin
        FreeAndNil(LStructArr2[i]);
        end;
    end;
  finally
    for i := Low(LStructArr1) to High(LStructArr1) do
      begin
      FreeAndNil(LStructArr1[i]);
      end;
  end;
end;

{ TIdSoapBuildersEasySoap }

procedure TIdSoapBuildersEasySoap.Setup;
begin
  BuildClient('http://easysoap.sourceforge.net/cgi-bin/interopserver');
end;

procedure TIdSoapBuildersEasySoap.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

{ TIdSoapBuildersDolphin }

procedure TIdSoapBuildersDolphin.Setup;
begin
  BuildClient('http://www.dolphinharbor.org/services/interop2001');
end;

procedure TIdSoapBuildersDolphin.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

{ TIdSoapBuildersIona }

procedure TIdSoapBuildersIona.Setup;
begin
  BuildClient('http://interop.xmlbus.com:7002/xmlbus/container/InteropTest/InteropTestService/InteropTestPort/');
end;

procedure TIdSoapBuildersIona.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

{ TIdSoapBuildersKafka }

procedure TIdSoapBuildersKafka.Setup;
begin
  BuildClient('http://www.vbxml.com/soapworkshop/services/kafka10/services/endpoint.asp?service=ilab');
end;

procedure TIdSoapBuildersKafka.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

{ TIdSoapBuildersMSSoap }

procedure TIdSoapBuildersMSSoap.Setup;
begin
  BuildClient('http://www.mssoapinterop.org/stk/InteropTyped.wsdl');
end;

procedure TIdSoapBuildersMSSoap.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

{ TIdSoapBuildersMSNet1 }

procedure TIdSoapBuildersMSNet.Setup;
begin
  BuildClient('http://www.mssoapinterop.org/asmx/simple.asmx?WSDL', false);
end;

procedure TIdSoapBuildersMSNet.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

{ TIdSoapBuildersSoap4R }

procedure TIdSoapBuildersSoap4R.Setup;
begin
  BuildClient('http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/');
end;

procedure TIdSoapBuildersSoap4R.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

{ TIdSoapBuildersSoapLite }

procedure TIdSoapBuildersSoapLite.Setup;
begin
  BuildClient('http://services.soaplite.com/interop.cgi', true, true);
end;

procedure TIdSoapBuildersSoapLite.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  FreeAndNil(GHTTP);
end;

end.


