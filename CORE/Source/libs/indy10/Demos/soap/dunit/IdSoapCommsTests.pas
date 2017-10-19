{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16385: IdSoapCommsTests.pas 
{
{   Rev 1.1    19/6/2003 21:35:46  GGrieve
{ Version #1
}
{
{   Rev 1.0    25/2/2003 13:27:14  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  Compression tests
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  16-Aug 2002   Grahame Grieve                  Fix SoapAction to have ""
  22-Jul 2002   Grahame Grieve                  Soap V1.1 conformance testing
  10-May 2002   Andrew Cumming                  backed out Mods
   9-May 2002   Andrew Cumming                  Mods to allow you to state app/soap or text/xml
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  04-Apr 2002   Grahame Grieve                  Changes to SoapAction and MimeType transmission
  26-Mar 2002   Grahame Grieve                  Change names of constants
  20-Mar 2002   Andrew Cumming                  Made D4/D5 capable
  15-Mar 2002   Grahame Grieve                  First write Comms Tests
}

unit IdSoapCommsTests;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapClientDirect,
  IdSoapClientHTTP,
  IdSoapClientTCPIP,
  {$IFDEF MSWINDOWS}
  IdSoapClientWinInet,
  {$ENDIF}
  IdSoapRequestInfo,
  IdSoapServer,
  IdSoapServerHTTP,
  IdSoapServerTCPIP,
  IdTCPServer,
  IdCustomHTTPServer,
  TestFramework;

type
  TIdSoapCommsTests = class (TTestCase)
  private
    FClient : TIdSoapClientDirect;
    FServer : TIdSoapServer;
  protected
    procedure Setup; override;
    procedure Teardown; override;
  published
  end;

  TIdSoapHTTPTests = class (TTestCase)
  private
    FReqInfoExisted : boolean;
    FClient : TIdSoapClientHTTP;
    FServer : TIdSoapServerHTTP;
    FObservedSoapAction : string;
    FObservedType : string;
    FNonSOAPExecuted : boolean;
    procedure SoapPreExecute(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var VHandled: Boolean);
    procedure NonSoapPreExecute(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  protected
    procedure Setup; override;
    procedure Teardown; override;
  published
    procedure TestPipe;
    procedure TestNoInterfaceHeader;
    procedure TestNoSendStream;
    procedure TestNoRecvStream;
    procedure TestGet1;
    procedure TestGet2;
    procedure TestPostNoContent;
    procedure TestPostNoInterfaceHeader;
    {$IFDEF ID_SOAP_COMPRESSION}
    procedure TestPipeComp;
    procedure TestPipeCompC;
    procedure TestPipeCompS;
    procedure TestPipeCompCS;
    {$ENDIF}
  end;

  TIdSoapTCPIPTests = class (TTestCase)
  private
    FReqInfoExisted : boolean;
    FClient : TIdSoapClientTCPIP;
    FServer : TIdSoapServerTCPIP;
    FWaitTime : integer;
    FObservedMimeType : string;
    FDropOnPreExecute : boolean;
    procedure SoapPreExecute(AThread: TIdPeerThread; const AInMimeType : string; ARequest, AResponse : TStream; var VOutMimeType : string; var VOutcome: TIdSoapTCPIPPreExecuteOutcome);
  protected
    procedure Setup; override;
    procedure Teardown; override;
  published
    procedure TestPipe;
    procedure TestPipeTimeout;
    procedure TestPipeHangup;
    procedure TestNoInterfaceHeader;
    procedure TestNoSendStream;
    procedure TestNoRecvStream;
    {$IFDEF ID_SOAP_COMPRESSION}
    procedure TestCompressed;
    {$ENDIF}
  end;

  {$IFDEF MSWINDOWS}
  TIdSoapWinInetTests = class (TTestCase)
  private
    FReqInfoExisted : boolean;
    FClient : TIdSoapClientWinInet;
    FServer : TIdSoapServerHTTP;
    FObservedSoapAction : string;
    FObservedType : string;
    FNonSOAPExecuted : boolean;
    procedure SoapPreExecute(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var VHandled: Boolean);
  protected
    procedure Setup; override;
    procedure Teardown; override;
  published
    procedure TestPipe;
    procedure TestNoInterfaceHeader;
    procedure TestNoSendStream;
    procedure TestNoRecvStream;
    procedure TestPostNoContent;
  end;
  {$ENDIF}


implementation

uses
  IdHTTP,
  IdException,
  IdSoapComponent,
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapITIProvider,
  IdSoapTestingUtils,
  IdSoapUtilities,
  SysUtils,
  TestIntfDefn;

{ TIdSoapHTTPTests }

procedure TIdSoapHTTPTests.Setup;
begin
  FObservedSoapAction := '';
  FObservedType := '';
  FNonSOAPExecuted := false;
  FClient := TIdSoapClientHTTP.create(nil);
  FClient.SoapURL := 'http://localhost:20345/soap';
  FServer := TIdSoapServerHTTP.create(nil);
  FServer.SOAPPath := '/soap';
  FServer.DefaultPort := 20345;
  FServer.OnPreExecute := SoapPreExecute;
  FServer.Active := true;
end;

procedure TIdSoapHTTPTests.Teardown;
begin
  FreeAndNil(FClient);
  FreeAndNil(FServer);
end;

procedure TIdSoapHTTPTests.SoapPreExecute(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var VHandled: Boolean);
begin
  VHandled := true;
  AResponseInfo.ContentStream := TIdMemoryStream.create;
  AResponseInfo.ContentStream.CopyFrom(ARequestInfo.PostStream, 0);
  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentType := ID_SOAP_HTTP_SOAP_TYPE;
  FObservedSoapAction := ARequestInfo.RawHeaders.Values[ID_SOAP_HTTP_ACTION_HEADER];
  FObservedType := ARequestInfo.ContentType;
  FReqInfoExisted := assigned(GIdSoapRequestInfo);
end;

procedure TIdSoapHTTPTests.NonSoapPreExecute(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  FNonSOAPExecuted := true;
  AResponseInfo.ContentText := 'hello';
  AResponseInfo.ResponseNo := 200;
end;

procedure TIdSoapHTTPTests.TestPipe;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LMimeType : string;
  LOK : boolean;
begin
  check(FClient.SoapURL = 'http://localhost:20345/soap');
  check(FServer.SOAPPath = '/soap');
  check(FServer.DefaultPort = 20345);
  Check(not assigned(GIdSoapRequestInfo));

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      FillTestingStream(LRequest, 400);
      LRequest.Position := 0;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
      LRequest.Position := 0;
      LResponse.Position := 0;
      LOK := TestStreamsIdentical(LRequest, LResponse, LMsg);
      check(LOK, LMsg);
      Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
      Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
      Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
      Check(FReqInfoExisted);
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapHTTPTests.TestNoInterfaceHeader;
var
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  FClient.TestSoapRequest('', ID_SOAP_HTTP_SOAP_TYPE, nil, nil, LMimeType);
end;

procedure TIdSoapHTTPTests.TestNoRecvStream;
var
  LStream : TMemoryStream;
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  LStream := TIdMemoryStream.create;
  try
    FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LStream, nil, LMimeType);
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapHTTPTests.TestNoSendStream;
var
  LStream : TMemoryStream;
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  LStream := TIdMemoryStream.create;
  try
    FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, nil, LStream, LMimeType);
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapHTTPTests.TestPostNoContent;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      LRequest.Position := 0;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
      LRequest.Position := 0;
      LResponse.Position := 0;
      LOK := TestStreamsIdentical(LRequest, LResponse, LMsg);
      check(LOK, LMsg);
      Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
      Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
      Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapHTTPTests.TestGet1;
var
  LHTTP : TIdHTTP;
begin
  FServer.OnPreExecute := nil;
  LHTTP := TIdHTTP.create(nil);
  try
    ExpectedException := EIdHTTPProtocolException;
    LHTTP.Get('http://localhost:20345/soap');
  finally
    FreeAndNil(LHTTP);
  end;
end;

procedure TIdSoapHTTPTests.TestGet2;
var
  LHTTP : TIdHTTP;
begin
  FServer.OnPreExecute := nil;
  FServer.OnNonSOAPExecute := NonSoapPreExecute;
  LHTTP := TIdHTTP.create(nil);
  try
    LHTTP.Get('http://localhost:20345/nonsoap');
  finally
    FreeAndNil(LHTTP);
  end;
  Check(FNonSOAPExecuted, 'Soap Non Soap execution failed');
end;

procedure TIdSoapHTTPTests.TestPostNoInterfaceHeader;
var
  LHTTP : TIdHTTP;
  LRequest : TMemoryStream;
begin
  FServer.OnPreExecute := nil;
  LHTTP := TIdHTTP.create(nil);
  try
    LRequest := TIdMemoryStream.create;
    try
      FillTestingStream(LRequest, 200);
      ExpectedException := EIdHTTPProtocolException;
      LHTTP.Post('http://localhost:20345/soap', LRequest);
    finally
      FreeAndNil(LRequest);
    end;
  finally
    FreeAndNil(LHTTP);
  end;
end;

{$IFDEF ID_SOAP_COMPRESSION}
procedure TIdSoapHTTPTests.TestPipeCompC;
var
  LRequest : TMemoryStream;
  LStore : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LMimeType : string;
  LOK : boolean;
begin
  FClient.Compression := true;
  check(FClient.SoapURL = 'http://localhost:20345/soap');
  check(FServer.SOAPPath = '/soap');
  check(FServer.DefaultPort = 20345);
  Check(not assigned(GIdSoapRequestInfo));

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      LStore := TIdMemoryStream.create;
      try
        FillTestingStreamASCII(LRequest, 400);
        LRequest.Position := 0;
        LStore.CopyFrom(LRequest, 0);
        LRequest.Position := 0;
        LStore.Position := 0;
        FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
        LResponse.Position := 0;
        LOK := TestStreamsIdentical(LStore, LResponse, LMsg);
        check(LOK, LMsg);
        Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
        Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
        Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
        Check(FReqInfoExisted);
      finally
        FreeAndNil(LStore);
      end;
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapHTTPTests.TestPipeCompCS;
var
  LRequest : TMemoryStream;
  LStore : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LMimeType : string;
  LOK : boolean;
begin
  FClient.Compression := true;
  FServer.Compression := true;
  check(FClient.SoapURL = 'http://localhost:20345/soap');
  check(FServer.SOAPPath = '/soap');
  check(FServer.DefaultPort = 20345);
  Check(not assigned(GIdSoapRequestInfo));

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      LStore := TIdMemoryStream.create;
      try
        FillTestingStreamASCII(LRequest, 400);
        LRequest.Position := 0;
        LStore.CopyFrom(LRequest, 0);
        LRequest.Position := 0;
        LStore.Position := 0;
        FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
        LResponse.Position := 0;
        LOK := TestStreamsIdentical(LStore, LResponse, LMsg);
        check(LOK, LMsg);
        Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
        Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
        Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
        Check(FReqInfoExisted);
      finally
        FreeAndNil(LStore);
      end;
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapHTTPTests.TestPipeCompS;
var
  LRequest : TMemoryStream;
  LStore : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LMimeType : string;
  LOK : boolean;
begin
  FServer.Compression := true;
  check(FClient.SoapURL = 'http://localhost:20345/soap');
  check(FServer.SOAPPath = '/soap');
  check(FServer.DefaultPort = 20345);
  Check(not assigned(GIdSoapRequestInfo));

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      LStore := TIdMemoryStream.create;
      try
        FillTestingStreamASCII(LRequest, 400);
        LRequest.Position := 0;
        LStore.CopyFrom(LRequest, 0);
        LRequest.Position := 0;
        LStore.Position := 0;
        FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
        LResponse.Position := 0;
        LOK := TestStreamsIdentical(LStore, LResponse, LMsg);
        check(LOK, LMsg);
        Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
        Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
        Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
        Check(FReqInfoExisted);
      finally
        FreeAndNil(LStore);
      end;
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapHTTPTests.TestPipeComp;
var
  LRequest : TMemoryStream;
  LStore : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LMimeType : string;
  LOK : boolean;
begin
  check(FClient.SoapURL = 'http://localhost:20345/soap');
  check(FServer.SOAPPath = '/soap');
  check(FServer.DefaultPort = 20345);
  Check(not assigned(GIdSoapRequestInfo));

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      LStore := TIdMemoryStream.create;
      try
        FillTestingStreamASCII(LRequest, 400);
        LRequest.Position := 0;
        LStore.CopyFrom(LRequest, 0);
        LRequest.Position := 0;
        LStore.Position := 0;
        FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
        LResponse.Position := 0;
        LOK := TestStreamsIdentical(LStore, LResponse, LMsg);
        check(LOK, LMsg);
        Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
        Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
        Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
        Check(FReqInfoExisted);
      finally
        FreeAndNil(LStore);
      end;
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;
{$ENDIF}

{ TIdSoapTCPIPTests }

procedure TIdSoapTCPIPTests.Setup;
begin
  FClient := TIdSoapClientTCPIP.create(nil);
  FClient.SoapHost := 'localhost';
  FClient.SoapPort := 20345;
  FClient.SoapTimeout := 5000;
  FServer := TIdSoapServerTCPIP.create(nil);
  FServer.DefaultPort := 20345;
  FServer.OnPreExecute := SoapPreExecute;
  FServer.Active := true;
  FDropOnPreExecute := false;
  FObservedMimeType := '';
  FWaitTime := 0;
end;

procedure TIdSoapTCPIPTests.Teardown;
begin
  FreeAndNil(FClient);
  FreeAndNil(FServer);
end;

procedure TIdSoapTCPIPTests.SoapPreExecute(AThread: TIdPeerThread; const AInMimeType : string; ARequest, AResponse : TStream; var VOutMimeType : string; var VOutcome: TIdSoapTCPIPPreExecuteOutcome);
begin
  sleep(FWaitTime);
  FObservedMimeType := AInMimeType;
  VOutMimeType := ID_SOAP_HTTP_BIN_TYPE;
  FReqInfoExisted := assigned(GIdSoapRequestInfo);
  if FDropOnPreExecute then
    begin
    AThread.Connection.Disconnect;
    VOutcome := peoHandled;
    end
  else
    begin
    AResponse.CopyFrom(ARequest, 0);
    VOutcome := peoWriteStream;
    end;
end;

procedure TIdSoapTCPIPTests.TestPipe;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  Check(FClient.SoapHost = 'localhost');
  Check(FClient.SoapPort = 20345);
  Check(FClient.SoapTimeout = 5000);
  Check(FServer.DefaultPort = 20345);
  Check(not assigned(GIdSoapRequestInfo));

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      FillTestingStream(LRequest, 400);
      LRequest.Position := 0;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
      LRequest.Position := 0;
      LResponse.Position := 0;
      LOK := TestStreamsIdentical(LRequest, LResponse, LMsg);
      check(LOK, LMsg);
      Check(FObservedMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request mime type not succesfully sent');
      Check(LMimeType = ID_SOAP_HTTP_BIN_TYPE, 'Soap response mime type not succesfully sent');
      Check(FReqInfoExisted);
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapTCPIPTests.TestNoInterfaceHeader;
var
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  FClient.TestSoapRequest('', ID_SOAP_HTTP_SOAP_TYPE, nil, nil, LMimeType);
end;

procedure TIdSoapTCPIPTests.TestNoRecvStream;
var
  LStream : TMemoryStream;
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  LStream := TIdMemoryStream.create;
  try
    FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LStream, nil, LMimeType);
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapTCPIPTests.TestNoSendStream;
var
  LStream : TMemoryStream;
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  LStream := TIdMemoryStream.create;
  try
    FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, nil, LStream, LMimeType);
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapTCPIPTests.TestPipeHangup;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMimeType : string;
begin
  FDropOnPreExecute := true;
  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      FillTestingStream(LRequest, 400);
      LRequest.Position := 0;
      ExpectedException := EIdConnClosedGracefully;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapTCPIPTests.TestPipeTimeout;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMimeType : string;
begin
  FWaitTime := 60;
  FClient.SoapTimeout := 20;
  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      FillTestingStream(LRequest, 400);
      LRequest.Position := 0;
      ExpectedException := EIdReadTimeout;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

{$IFDEF ID_SOAP_COMPRESSION}
procedure TIdSoapTCPIPTests.TestCompressed;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  FClient.Active := false;
  FServer.Active := false;
  FClient.Compression := true;
  FServer.Compression := true;
  FServer.Active := true;

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      FillTestingStream(LRequest, 400);
      LRequest.Position := 0;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
      LRequest.Position := 0;
      LResponse.Position := 0;
      LOK := TestStreamsIdentical(LRequest, LResponse, LMsg);
      check(LOK, LMsg);
      Check(FObservedMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request mime type not succesfully sent');
      Check(LMimeType = ID_SOAP_HTTP_BIN_TYPE, 'Soap response mime type not succesfully sent');
      Check(FReqInfoExisted);
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;
{$ENDIF}


{$IFDEF MSWINDOWS}
{ TIdSoapWinInetTests }

procedure TIdSoapWinInetTests.Setup;
begin
  FObservedSoapAction := '';
  FObservedType := '';
  FNonSOAPExecuted := false;
  FClient := TIdSoapClientWinInet.create(nil);
  FClient.SoapURL := 'http://localhost:20345/soap';
  FClient.UseIEProxySettings := false;
  FServer := TIdSoapServerHTTP.create(nil);
  FServer.SOAPPath := '/soap';
  FServer.DefaultPort := 20345;
  FServer.OnPreExecute := SoapPreExecute;
  FServer.Active := true;
end;

procedure TIdSoapWinInetTests.Teardown;
begin
  FreeAndNil(FClient);
  FreeAndNil(FServer);
end;

procedure TIdSoapWinInetTests.SoapPreExecute(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var VHandled: Boolean);
begin
  VHandled := true;
  AResponseInfo.ContentStream := TIdMemoryStream.create;
  AResponseInfo.ContentStream.CopyFrom(ARequestInfo.PostStream, 0);
  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentType := ID_SOAP_HTTP_SOAP_TYPE;
  FObservedSoapAction := ARequestInfo.RawHeaders.Values[ID_SOAP_HTTP_ACTION_HEADER];
  FObservedType := ARequestInfo.ContentType;
  FReqInfoExisted := assigned(GIdSoapRequestInfo);
end;

procedure TIdSoapWinInetTests.TestPipe;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  check(FClient.SoapURL = 'http://localhost:20345/soap');
  check(FServer.SOAPPath = '/soap');
  check(FServer.DefaultPort = 20345);
  Check(not assigned(GIdSoapRequestInfo));

  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      FillTestingStream(LRequest, 400);
      LRequest.Position := 0;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
      LRequest.Position := 0;
      LResponse.Position := 0;
      LOK := TestStreamsIdentical(LRequest, LResponse, LMsg);
      check(LOK, LMsg);
      Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
      Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
      Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
      Check(FReqInfoExisted);
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapWinInetTests.TestNoInterfaceHeader;
var
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  FClient.TestSoapRequest('', ID_SOAP_HTTP_SOAP_TYPE, nil, nil, LMimeType);
end;

procedure TIdSoapWinInetTests.TestNoRecvStream;
var
  LStream : TMemoryStream;
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  LStream := TIdMemoryStream.create;
  try
    FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LStream, nil, LMimeType);
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapWinInetTests.TestNoSendStream;
var
  LStream : TMemoryStream;
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  LStream := TIdMemoryStream.create;
  try
    FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, nil, LStream, LMimeType);
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapWinInetTests.TestPostNoContent;
var
  LRequest : TMemoryStream;
  LResponse : TMemoryStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LRequest := TIdMemoryStream.create;
  try
    LResponse := TIdMemoryStream.create;
    try
      LRequest.Position := 0;
      FClient.TestSoapRequest('test', ID_SOAP_HTTP_SOAP_TYPE, LRequest, LResponse, LMimeType);
      LRequest.Position := 0;
      LResponse.Position := 0;
      LOK := TestStreamsIdentical(LRequest, LResponse, LMsg);
      check(LOK, LMsg);
      Check(FObservedSoapAction = '"test"', 'SoapAction not succesfully received');
      Check(FObservedType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap request Mime Type wrong');
      Check(LMimeType = ID_SOAP_HTTP_SOAP_TYPE, 'Soap response Mime Type wrong');
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

{$ENDIF}


{ TIdSoapCommsTests }

procedure TIdSoapCommsTests.Setup;
begin
  FServer := TIdSoapServer.create(nil);
  FServer.ITISource := islFile;
  FServer.ITIFileName := 'ttemp.iti';
  FServer.EncodingType := etIdXmlUtf8;
  FServer.Active := true;
  FClient := TIdSoapClientDirect.create(nil);
  FClient.SoapServer := FServer;
  FClient.ITISource := islFile;
  FClient.ITIFileName := 'ttemp.iti';
  FClient.EncodingType := etIdXmlUtf8;
  FClient.Active := true;
end;

procedure TIdSoapCommsTests.Teardown;
begin
  FreeAndNil(FClient);
  FreeAndNil(FServer);
end;
(*

procedure TIdSoapCommsTests.Test_ServerTypeChecking_1;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
// the server should return a soap exception packet with a type application/server (utf-8) if the request was a total failure
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('application/soap', m1, m2, s);
    Check(s = 'application/soap');
    Check(Pos('stream is empty', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_1a;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
// the server should return a soap exception packet with a type application/server (utf-8) if the request was a total failure
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.MimeTypeCharType := true;
    FServer.HandleSoapRequest('application/soap', m1, m2, s);
    Check(s = 'application/soap; charset="utf-8"');
    Check(Pos('stream is empty', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_2;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
// the server should return a soap exception packet with a type text/xml (utf-8) if the request was a total failure
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('text/xml', m1, m2, s);
    Check(s = 'text/xml');
    Check(Pos('stream is empty', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_3;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
// the server should return a soap exception packet with a type application/server (utf-8) if the request was a total failure
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('text/plain', m1, m2, s);
    Check(s = 'application/soap');
    Check(Pos('mimetype', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_4;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtAppSoap];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('application/soap', m1, m2, s);
    Check(s = 'application/soap');
    Check(Pos('stream is empty', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_5;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtAppSoap];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('text/xml', m1, m2, s);
    Check(s = 'application/soap');
    Check(Pos('mimetype', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_6;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtAppSoap];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('bin/application', m1, m2, s);
    Check(s = 'application/soap');
    Check(Pos('mimetype', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_7;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtTextXML];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('text/xml', m1, m2, s);
    Check(s = 'text/xml');
    Check(Pos('stream is empty', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_8;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtTextXML];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('application/soap', m1, m2, s);
    Check(s = 'text/xml');
    Check(Pos('mimetype', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_9;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtTextXML];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('bin/application', m1, m2, s);
    Check(s = 'text/xml');
    Check(Pos('mimetype', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

// this is touch weird. we insist on the mimetype that belongs with
// the binary encoding, but require xml encoding (just makes the test
// easier - isn't a real world combination that makes sense
procedure TIdSoapCommsTests.Test_ServerTypeChecking_10;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtAppBin];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('application/Octet-Stream', m1, m2, s);
    Check(s = 'application/Octet-Stream');
    Check(Pos('stream is empty', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_11;
var
  s : string;
  m1, m2 : TMemoryStream;
begin
  FServer.MimeTypes := [idmtAppBin];
  m1 := TMemoryStream.create;
  m2 := TMemoryStream.create;
  try
    FServer.HandleSoapRequest('Text/xml', m1, m2, s);
    Check(s = 'application/Octet-Stream');
    Check(Pos('mimetype', lowercase(IdSoapReadException(m2))) > 0);
  finally
    FreeAndNil(m1);
    FreeAndNil(m2);
  end;
end;

procedure TIdSoapCommsTests.Test_ServerTypeChecking_12;
begin
  ExpectedException := EIdSoapRequirementFail;
  FServer.MimeTypes := [];
end;

procedure TIdSoapCommsTests.Test_ClientMimeTypeControl1;
begin
  FServer.MimeTypes := [idmtAppSoap];
  FClient.MimeTypes := [idmtAppSoap];
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;


procedure TIdSoapCommsTests.Test_ClientMimeTypeControl2;
begin
  FServer.MimeTypes := [idmtTextXML];
  FClient.MimeTypes := [idmtTextXML];
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;

procedure TIdSoapCommsTests.Test_ClientMimeTypeControl3;
begin
  FClient.Active := false;
  FServer.Active := false;
  FServer.MimeTypes := [idmtAppBin];
  FClient.MimeTypes := [idmtAppBin];
  FServer.EncodingType := etIdBinary;
  FClient.EncodingType := etIdBinary;
  FServer.Active := true;
  FClient.Active := true;
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;

procedure TIdSoapCommsTests.Test_ClientMimeTypeControl3a;
begin
  FServer.MimeTypes := [idmtAppBin];
  FClient.MimeTypes := [idmtAppBin];
  ExpectedException := EIdSoapRequirementFail; // cause the encoding type and mime type will mismatch
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;

procedure TIdSoapCommsTests.Test_ClientMimeTypeControl4;
begin
  FServer.MimeTypes := [idmtAppSoap];
  FClient.MimeTypes := [idmtAppBin];
  ExpectedException := EIdSoapBadMimeType;
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;

procedure TIdSoapCommsTests.Test_ClientMimeTypeControl5;
begin
  FServer.MimeTypes := [idmtTextXml];
  FClient.MimeTypes := [idmtAppSoap];
  ExpectedException := EIdSoapBadMimeType;
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;

procedure TIdSoapCommsTests.Test_ClientMimeTypeControl6;
begin
  FServer.Active := false;
  FServer.MimeTypes := [idmtAppBin];
  FServer.EncodingType := etIdBinary;
  FServer.Active := true;
  FClient.MimeTypes := [idmtTextXML];
  ExpectedException := EIdSoapBadMimeType;
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;

procedure TIdSoapCommsTests.Test_ClientMimeTypeControl7;
begin
  FServer.MimeTypes := [idmtTextXml];
  FClient.MimeTypes := [idmtAppSoap, IdmtTextXml];
{$IFDEF DELPHI4}
  (IdSoapD4Interface(FClient) as IIDTestInterface).Sample1(42);
{$ELSE}
  (FClient as IIdTestInterface).Sample1(42);
{$ENDIF}
end;
  *)
end.
