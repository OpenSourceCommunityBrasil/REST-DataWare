{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16381: IdSoapBuildersTests2.pas 
{
{   Rev 1.1    18/3/2003 11:15:34  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:27:02  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  18-Mar 2003   Grahame Grieve                  QName, RawXML, Schema extensibility, Kylix compile fixes
  04-Oct 2002   Grahame Grieve                  Comment out stream viewing
  18-Sep 2002   Grahame Grieve                  Fix compiler problems
  17-Sep 2002   Grahame Grieve                  First booked in
}

unit IdSoapBuildersTests2;

interface

Uses
  IdHTTP,
  IdSoapClient,
  IdSoapRPCPacket,
  Interop2Base,
  Interop2GroupB,
  TestExtensions,
  TestFramework;

type
  TIdSoapSoapBuilders2BaseTestsNoHex = class (TTestCase)
  published
    procedure TestEchoVoid;
    procedure TestEchoString1;
    procedure TestEchoString2;
    procedure TestEchoInteger;
    procedure TestEchoFloat;
    procedure TestEchoStruct;
    procedure TestEchoStringArray;
    procedure TestEchoIntegerArray;
    procedure TestEchoFloatArray;
    procedure TestEchoStructArray;
    procedure TestEchoBase64;
    procedure TestEchoDate;
    procedure TestEchoDecimal;
    procedure TestEchoBoolean;
  end;

  TIdSoapSoapBuilders2BaseTests = class (TIdSoapSoapBuilders2BaseTestsNoHex)
  published
    procedure TestEchoHexBinary;
  end;

  TIdSoapSoapBuilders2GroupBTestsShort = class (TTestCase)
  published
    procedure TestEchoSimpleTypesAsStruct;
    procedure TestechoStructAsSimpleTypes;
    procedure TestechoNestedStruct;
    procedure TestechoNestedArray;
  end;

  TIdSoapSoapBuilders2GroupBTests = class (TIdSoapSoapBuilders2GroupBTestsShort)
  published
    procedure Testecho2DStringArray;
  end;



  TIdSoapBuilders2Setup = class (TTestSetup)
  private
    FURL : string;
    FURLB : string;
    FTypes : boolean;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  public
    constructor Create(ATest: ITest; AName: ShortString; AURL : String; ATypes : boolean; AGroupBURL : string = '');
  end;

implementation

uses
  Classes,
  IdGlobal,
  {$IFNDEF LINUX}
  IdSoapClientWinInet,
  {$ENDIF}
  IdSoapClientHTTP,
  IdSoapDateTime,
  IdSoapITIProvider,
  IdSoapTestingUtils,
  IdSoapTypeRegistry,
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
//  {$IFNDEF LINUX}
 // showmessage('click to send');
 // {$ENDIF}
end;


var
  GClient : TIdSoapBaseClient;
  GClientB : TIdSoapBaseClient;
  GHTTP : TIdHTTP;
  GIntf : InteropTest2;
  GIntfB : IInteropService2B;
  GHelper : THelper;

procedure BuildClient(AURL : string; ATypes : boolean = true; AGroupBURL : string = '');
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
      if AGroupBURL <> '' then
        begin
        GClientB := TIdSoapClientWinInet.create(nil);
        (GClientB as TIdSoapClientWinInet).SoapURL := AGroupBURL;
        end;
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
      if AGroupBURL <> '' then
        begin
        GClientB := TIdSoapClientHTTP.create(nil);
        (GClientB as TIdSoapClientHTTP).SoapURL := AGroupBURL;
        (GClientB as TIdSoapClientHTTP).HTTPClient := GHTTP;
        end;
      end;
  finally
    FreeAndNil(LIni);
  end;
  GClient.ITISource := islResource;
  GClient.ITIResourceName := 'Interop2Base';
  if ATypes Then
    begin
    GClient.EncodingOptions := [seoUseCrLf, seoCheckStrings, seoRequireTypes];
    end
  else
    begin
    GClient.EncodingOptions := [seoUseCrLf, seoCheckStrings];
    end;
  GClient.OnReceiveMessage := GHelper.OnGet;
  GClient.OnSendMessage := GHelper.OnSend;
  GClient.Active := true;
  GIntf := GetInteropTest2(GClient);
  if AGroupBURL <> '' then
    begin
    GClientB.EncodingOptions := [seoUseCrLf, seoCheckStrings];
    GClientB.ITISource := islResource;
    GClientB.ITIResourceName := 'Interop2GroupB';
    GClientB.OnReceiveMessage := GHelper.OnGet;
    GClientB.OnSendMessage := GHelper.OnSend;
    GClientB.Active := true;
    GIntfB := GetInteropServiceB(GClientB);
    end;
end;

{ TIdSoapBuildersTests }

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoVoid;
begin
  GIntf.echoVoid;
end;

const
  TEST_BINARY = 'sdf'#0#1'asdasdf'#255;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoBase64;
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
  
procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoDate;
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

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoFloat;
begin
  Check(GIntf.echoFloat(3.5) = 3.5);
end;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoFloatArray;
var
  LArrDbl1, LArrDbl2 : TArrayOffloat;
begin
  SetLength(LArrDbl1, 2);
  LArrDbl1[0] := 3.5;
  LArrDbl1[1] := 2.5;
  LArrDbl2 := GIntf.echoFloatArray(LArrDbl1);
  Check(length(LArrDbl2) = 2);
  Check(LArrDbl2[0] = 3.5);
  Check(LArrDbl2[1] = 2.5);
end;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoInteger;
begin
  Check(GIntf.echoInteger(65540) = 65540);
end;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoIntegerArray;
var
  LArrInt1, LArrInt2 : TArrayOfint;
begin
  SetLength(LArrInt1, 2);
  LArrInt1[0] := 3;
  LArrInt1[1] := 0;
  LArrInt2 := GIntf.echoIntegerArray(LArrInt1);
  Check(length(LArrInt2) = 2);
  Check(LArrInt2[0] = 3);
  Check(LArrInt2[1] = 0);
end;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoString1;
begin
  Check(GIntf.echoString('indysoap test') = 'indysoap test');
end;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoString2;
begin
  Check(GIntf.echoString('') = '');
end;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoStringArray;
var
  LArrStr1, LArrStr2 : TArrayOfstring;
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

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoStruct;
var
  LStruct1, LStruct2 : TSOAPStruct;
begin
  LStruct1 := TSOAPStruct.create;
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

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoStructArray;
var
  LStructArr1, LStructArr2 : TArrayOfSOAPStruct;
  i : integer;
begin
  SetLength(LStructArr1, 3);
  LStructArr1[0] := TSOAPStruct.create;
  LStructArr1[1] := TSOAPStruct.create;
  LStructArr1[2] := TSOAPStruct.create;
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

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoBoolean;
begin
  Check(GIntf.echoBoolean(true) = true);
  Check(GIntf.echoBoolean(false) = false);
end;

procedure TIdSoapSoapBuilders2BaseTestsNoHex.TestEchoDecimal;
begin
  Check(GIntf.echoDecimal(0.01) = 0.01);
  Check(GIntf.echoDecimal(100000.01) = 100000.01);
end;

procedure TIdSoapSoapBuilders2BaseTests.TestEchoHexBinary;
var
  LStream1, LStream2 : THexStream;
  s : string;
begin
  LStream1 := THexStream.create;
  try
    LStream1.Write(TEST_BINARY[1], length(TEST_BINARY));
    LStream1.Position := 0;
    LStream2 := GIntf.echoHexBinary(LStream1);
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

{ TIdSoapBuilders2Setup }

constructor TIdSoapBuilders2Setup.Create(ATest: ITest; AName: ShortString; AURL: String; ATypes : boolean; AGroupBURL : string);
begin
  inherited Create(ATest, AName);
  FURL := AURL;
  FURLB := AGroupBURL;
  FTypes := ATypes;
end;

procedure TIdSoapBuilders2Setup.Setup;
begin
  BuildClient(FURL, FTypes, FURLB);
end;

procedure TIdSoapBuilders2Setup.TearDown;
begin
  GIntf := nil;
  FreeAndNil(GClient);
  GIntfB := nil;
  FreeAndNil(GClientB);
  FreeAndNil(GHTTP);
end;

{ TIdSoapSoapBuilders2GroupBTests }

procedure TIdSoapSoapBuilders2GroupBTests.Testecho2DStringArray;
var
  LArrStr1, LArrStr2 : TArrayOfstring2;
begin
  SetLength(LArrStr1, 3);
  SetLength(LArrStr1[0], 4);
  SetLength(LArrStr1[1], 4);
  SetLength(LArrStr1[2], 4);
  LArrStr1[0,0] := 't00';
  LArrStr1[0,1] := 't01';
  LArrStr1[0,2] := 't02';
  LArrStr1[0,3] := 't03';
  LArrStr1[1,0] := 't10';
  LArrStr1[1,1] := 't11';
  LArrStr1[1,2] := 't12';
  LArrStr1[1,3] := 't13';
  LArrStr1[2,0] := 't20';
  LArrStr1[2,1] := 't21';
  LArrStr1[2,2] := 't22';
  LArrStr1[2,3] := 't23';
  LArrStr2 := GIntfB.echo2DStringArray(LArrStr1);
  Check(length(LArrStr2) = 3);
  Check(length(LArrStr2[1]) = 4);
  Check(length(LArrStr2[1]) = 4);
  Check(length(LArrStr2[1]) = 4);
  Check(LArrStr1[0,0] = 't00');
  Check(LArrStr1[0,1] = 't01');
  Check(LArrStr1[0,2] = 't02');
  Check(LArrStr1[0,3] = 't03');
  Check(LArrStr1[1,0] = 't10');
  Check(LArrStr1[1,1] = 't11');
  Check(LArrStr1[1,2] = 't12');
  Check(LArrStr1[1,3] = 't13');
  Check(LArrStr1[2,0] = 't20');
  Check(LArrStr1[2,1] = 't21');
  Check(LArrStr1[2,2] = 't22');
  Check(LArrStr1[2,3] = 't23');
end;

procedure TIdSoapSoapBuilders2GroupBTestsShort.TestechoNestedArray;
var
  LStruct1, LStruct2 : TSOAPArrayStruct;
  LArr : TArrayOfString;
begin
  LStruct1 := TSOAPArrayStruct.create;
  try
    LStruct1.varString := 'test s 1';
    LStruct1.varInt := 23452;
    LStruct1.varFloat := 3.5;
    SetLength(LArr, 3);
    LStruct1.varArray := copy(LArr);
    LStruct1.varArray[0] := 's1';
    LStruct1.varArray[1] := '';
    LStruct1.varArray[2] := '4';

    LStruct2 := GIntfB.echoNestedArray(LStruct1);
    try
      Check(LStruct2.varString = 'test s 1');
      Check(LStruct2.varInt = 23452);
      Check(LStruct2.varFloat = 3.5);
      Check(LStruct2.varArray[0] = 's1');
      Check(LStruct2.varArray[1] = '');
      Check(LStruct2.varArray[2] = '4');
    finally
      FreeAndNil(LStruct2);
    end;
  finally
    FreeAndNil(LStruct1);
  end;
end;

procedure TIdSoapSoapBuilders2GroupBTestsShort.TestechoNestedStruct;
var
  LStruct1, LStruct2 : TSOAPStructStruct;
begin
  LStruct1 := TSOAPStructStruct.create;
  try
    LStruct1.varString := 'test s 1';
    LStruct1.varInt := 23452;
    LStruct1.varFloat := 3.5;
    LStruct1.varStruct := TSOAPStruct.create;
    LStruct1.varStruct.varString := 'test2';
    LStruct1.varStruct.varInt := -2;
    LStruct1.varStruct.varFloat := 0.001;

    LStruct2 := GIntfB.echoNestedStruct(LStruct1);
    try
      Check(LStruct2.varString = 'test s 1');
      Check(LStruct2.varInt = 23452);
      Check(LStruct2.varFloat = 3.5);
      Check(LStruct2.varStruct.varString = 'test2');
      Check(LStruct2.varStruct.varInt = -2);
      Check(abs(LStruct2.varStruct.varFloat - 0.001) < 0.000000001);
    finally
      FreeAndNil(LStruct2);
    end;
  finally
    FreeAndNil(LStruct1);
  end;
end;

procedure TIdSoapSoapBuilders2GroupBTestsShort.TestEchoSimpleTypesAsStruct;
var
  LStruct : TSOAPStruct;
begin
  LStruct := GIntfB.echoSimpleTypesAsStruct('test s 1', 23452, 3.5);
  try
    Check(LStruct.varString = 'test s 1');
    Check(LStruct.varInt = 23452);
    Check(LStruct.varFloat = 3.5);
  finally
    FreeAndNil(LStruct);
  end;
end;

procedure TIdSoapSoapBuilders2GroupBTestsShort.TestechoStructAsSimpleTypes;
var
  LStruct1 : TSOAPStruct;
  s : string;
  i : integer;
  f : Single;
begin
  LStruct1 := TSOAPStruct.create;
  try
    LStruct1.varString := 'test s 1';
    LStruct1.varInt := 23452;
    LStruct1.varFloat := 3.5;
    GIntfB.echoStructAsSimpleTypes(LStruct1, s, i, f);
    Check(s = 'test s 1');
    Check(i = 23452);
    Check(f = 3.5);
  finally
    FreeAndNil(LStruct1);
  end;
end;

end.


