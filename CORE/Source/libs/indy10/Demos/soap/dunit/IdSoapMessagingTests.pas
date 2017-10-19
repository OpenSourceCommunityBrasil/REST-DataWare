{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16427: IdSoapMessagingTests.pas 
{
{   Rev 1.3    23/6/2003 21:30:12  GGrieve
{ fix for EOL on Linux
}
{
{   Rev 1.2    23/6/2003 15:15:30  GGrieve
{ fix for V#1
}
{
{   Rev 1.1    18/3/2003 11:16:04  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:28:58  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  23-Jun 2003   Grahame Grieve                  fix for EOL on Linux
  23-Jun 2003   Grahame Grieve                  Fix case of unit
  18-Mar 2003   Grahame Grieve                  QName, RawXML, Schema extensibility, Kylix compile fixes
  04-Oct 2002   Grahame Grieve                  Tests for 2Way TCP/IP
  26-Sep 2002   Grahame Grieve                  Changes for Sessional Testing
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  27-Aug 2002   Grahame Grieve                  Linux Fixes
  26-Aug 2002   Grahame Grieve                  D4 Compiler fixes
  17-Aug 2002   Andrew Cumming                  removed KProcs from uses
  06-Aug 2002   Grahame Grieve                  One/Way added
}

unit IdSoapMessagingTests;

interface

uses
  Classes,
  IdEMailAddress,
  IdMessage,
  IdSoapClient,
  IdSoapComponent,
  IdSoapInterfaceTestsIntfDefn,
  IdSoapITIProvider,
  IdSoapMsgEmail,
  IdSoapTwoWayTCPIP,
  IdSoapServer,
  IdSoapUtilities,
  IdTCPServer,
  SysUtils,
  TestFramework;

type
  TBaseOneWayTestCase = class (TTestCase)
  Private
    FListener : TIdSoapMsgReceiver;
    FExceptionClass : TClass;
    FSender : TIdSoapBaseMsgSender;
    FIntf: IIdSoapInterfaceTestsInterface;
    procedure ListenerException(ASender : TObject; AException : Exception);
  Protected
    procedure SetUp; Override;
    procedure TearDown; Override;
  end;

  TDirectTestCases = class (TBaseOneWayTestCase)
  Protected
    procedure SetUp; Override;
    function GetClientEncodingType : TIdSoapEncodingType; virtual; abstract;
  published
    procedure CheckRejection1;
    procedure CheckRejection2;
    procedure CheckServerRejection1;
    procedure CheckServerRejection2;
    procedure CheckSendSuccessServer;
    procedure CheckSendSuccessAll;
  end;

  TIdSoapMsgXML8Tests = class (TDirectTestCases)
  Protected
    function GetClientEncodingType : TIdSoapEncodingType; override;
  end;

  TIdSoapMsgXML16Tests = class (TDirectTestCases)
  Protected
    function GetClientEncodingType : TIdSoapEncodingType; override;
  end;

  TIdSoapMsgBinTests = class (TDirectTestCases)
  Protected
    function GetClientEncodingType : TIdSoapEncodingType; override;
  end;

  TEmailMsgTestCases = class(TBaseOneWayTestCase)
  private
    FMsgRecvdOK : boolean;
    FMsgError : string;
    procedure SMTPMsg(ASender: TIdCommand; var AMsg: TIdMessage; RCPT: TIdEMailAddressList; var CustomError: string);
  Protected
    procedure SetUp; Override;
  published
    procedure TestNoStream;
    procedure TestNoMimeType;
    procedure TestSend;
    procedure TestSMTPServer;
  end;

  TIdSoapTwoWayTCPIPTests = class (TTestCase)
  private
    FListener : TIdSoapMsgReceiver;
    FClient : TIdSoapTwoWayTCPIP;
    FServer : TIdSoapTwoWayTCPIP;
    FServerConnectCalled : boolean;
    FClientConnectCalled : boolean;
    FClientDisconnectCalled : boolean;
    FServerDisconnectCalled : boolean;
    FlistenerReceiveCalled : boolean;
    FListenerSendCalled : boolean;
    FClientReceiveCalled : boolean;
    FClientSendCalled : boolean;
    FServerReceiveCalled : boolean;
    FServerSendCalled : boolean;

    procedure ServerConnect(ASender : TObject);
    procedure ClientConnect(ASender : TObject);
    procedure ClientDisconnect(ASender : TObject);
    procedure ServerDisconnect(ASender : TObject);
    procedure listenerReceive(ASender : TIdSoapITIProvider; AMessage : TStream);
    procedure ListenerSend(ASender : TIdSoapITIProvider; AMessage : TStream);
    procedure ClientReceive(ASender : TIdSoapITIProvider; AMessage : TStream);
    procedure ClientSend(ASender : TIdSoapITIProvider; AMessage : TStream);
    procedure ServerReceive(ASender : TIdSoapITIProvider; AMessage : TStream);
    procedure ServerSend(ASender : TIdSoapITIProvider; AMessage : TStream);
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestConnectionManagement1;
    procedure TestConnectionManagement2;
    procedure TestConnectionManagement3;
    procedure TestConnectionManagement4;
    procedure TestConnectionManagement5;
    procedure TestSoapMessaging;
  end;

implementation

uses
  IdGlobal,
  IdSMTPServer,
  IdPOP3Server,
  IdSoapExceptions,
  IdSoapMsgDirect,
  IdSoapRpcXml,
  IdSoapXML;

{ TDirectTestCases }

procedure TDirectTestCases.SetUp;
begin
  inherited;
  FSender := TIdSoapMsgSendDirect.create(nil);
  FSender.ITISource := islResource;
  FSender.ITIResourceName := 'IdSoapInterfaceTests';
  (FSender as TIdSoapMsgSendDirect).Listener := FListener;
  FSender.Active := true;
  FIntf := IdSoapD4Interface(FSender) as IIdSoapInterfaceTestsInterface;
end;


procedure TDirectTestCases.CheckRejection1;
begin
  ExpectedException := EIdSoapRequirementFail;
  FIntf.FuncRetBoolToggle;
end;

procedure TDirectTestCases.CheckRejection2;
var
  LSet : TSmallSet;
begin
  ExpectedException := EIdSoapRequirementFail;
  FIntf.ProcOutSet(LSet);
end;

procedure TDirectTestCases.CheckServerRejection1;
var
  LWriter : TIdSoapWriterXML;
begin
  LWriter := TIdSoapWriterXML.create(IdSoapV1_1, xpOpenXML);
  try
    LWriter.SetMessageName('FuncRetBoolToggle', FListener.DefaultNamespace);
    FExceptionClass := nil;
    FSender.SoapSend(LWriter, nil, '');
    Check(FExceptionClass = EIdSoapRequirementFail);
  finally
    FreeAndNil(LWriter);
  end;
end;

procedure TDirectTestCases.CheckServerRejection2;
var
  LWriter : TIdSoapWriterXML;
begin
  LWriter := TIdSoapWriterXML.create(IdSoapV1_1, xpOpenXML);
  try
    LWriter.SetMessageName('ProcOutSet', FListener.DefaultNamespace);
    FExceptionClass := nil;
    FSender.SoapSend(LWriter, nil, '');
    Check(FExceptionClass = EIdSoapRequirementFail);
  finally
    FreeAndNil(LWriter);
  end;
end;

procedure TDirectTestCases.CheckSendSuccessServer;
var
  LWriter : TIdSoapWriterXML;
begin
  LWriter := TIdSoapWriterXML.create(IdSoapV1_1, xpOpenXML);
  try
    LWriter.SetMessageName('ProcCall', FListener.DefaultNamespace);
    FExceptionClass := nil;
    FSender.SoapSend(LWriter, nil, '');
    Check(FExceptionClass = nil);
  finally
    FreeAndNil(LWriter);
  end;
end;

procedure TDirectTestCases.CheckSendSuccessAll;
begin
  FExceptionClass := nil;
  FIntf.ProcCall;
  Check(FExceptionClass = nil);
end;

{ TIdSoapMsgXML8Tests }

function TIdSoapMsgXML8Tests.GetClientEncodingType: TIdSoapEncodingType;
begin
  result := etIdXmlUtf8;
end;

{ TIdSoapMsgXML16Tests }

function TIdSoapMsgXML16Tests.GetClientEncodingType: TIdSoapEncodingType;
begin
  result := etIdXmlUtf16;
end;

{ TIdSoapMsgBinTests }

function TIdSoapMsgBinTests.GetClientEncodingType: TIdSoapEncodingType;
begin
  result := etIdBinary;
end;

{ TEmailMsgTestCases }

procedure TEmailMsgTestCases.SetUp;
begin
  inherited;
  FSender := TIdSoapMsgSendEmail.create(nil);
  FSender.ITISource := islResource;
  FSender.ITIResourceName := 'IdSoapInterfaceTests';
  (FSender as TIdSoapMsgSendEmail).Destination.Address := 'testdest@test.org';
  (FSender as TIdSoapMsgSendEmail).Sender.Address := 'testsnd@test.org';
  (FSender as TIdSoapMsgSendEmail).SMTPHost := '127.0.0.1';
  (FSender as TIdSoapMsgSendEmail).SMTPPort := 43001;
  FSender.Active := true;
  FIntf := IdSoapD4Interface(FSender) as IIdSoapInterfaceTestsInterface;
end;

procedure TEmailMsgTestCases.TestNoMimeType;
begin
  ExpectedException := EAssertionFailed;
  FSender.TestSoapSend('', '', nil);
end;

procedure TEmailMsgTestCases.TestNoStream;
begin
  ExpectedException := EAssertionFailed;
  FSender.TestSoapSend('', 'sdf', nil);
end;

const
  TEST_STRING = '<?xml version="1.0" encoding=''UTF-8''?> <SOAP-ENV:Envelope '+
         'xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" ><SOAP-ENV:Body> ';
  TEST_STRING2 =
         '<SOAP-ENV:Fault> <faultCode>SOAP-ENV:Server</faultCode><faultString>Unknown '+
         'SOAPAction ITest</faultString></SOAP-ENV:Fault></SOAP-ENV:Body></SOAP-ENV:Envelope>'+EOL_PLATFORM;

procedure TEmailMsgTestCases.TestSend;
Var
  s : string;
  LServer : TIdSMTPServer;
  LStream : TIdMemoryStream;
begin
  LServer := TIdSMTPServer.create(nil);
  try
    LServer.DefaultPort := 43001;
    LServer.OnReceiveMessageParsed := SMTPMsg;
    LServer.ReceiveMode := rmMessageParsed;
    LServer.Active := true;
    s := TEST_STRING+TEST_STRING2;
    LStream := TIdMemoryStream.create;
    try
      LStream.Write(s[1], length(s));
      LStream.Position := 0;
      FMsgRecvdOK := false;
      FMsgError := 'no msg received';
      FSender.MessageSubject := 'test soap message';
      FSender.TestSoapSend('', 'text/xml', LStream);
      Check(FMsgRecvdOK, FMsgError);
    finally
      FreeAndNil(LStream);
    end;
  finally
    FreeAndNil(LServer)
  end;
end;

procedure TEmailMsgTestCases.SMTPMsg(ASender: TIdCommand; var AMsg: TIdMessage; RCPT: TIdEMailAddressList; var CustomError: string);
var
  s : string;
begin
  try
    check(AMsg.Subject = 'test soap message');
    check(AMsg.MessageParts.count = 0, 'should be no parts to message');
    s := IdSoapMakeXmlPretty(TEST_STRING+TEST_STRING2)+EOL_PLATFORM;
    Check(AMsg.Body.Text = s, 'body not the same');
    FMsgRecvdOK := true;
  except
    on e:exception do
      begin
      FMsgRecvdOK := false;
      FMsgError := e.message;
      end;
  end;
end;

procedure TEmailMsgTestCases.TestSMTPServer;
var
  LSMTPServer : TIdSoapMsgSMTPListener;
begin
  LSMTPServer := TIdSoapMsgSMTPListener.create(nil);
  try
    LSMTPServer.DefaultPort := 43001;
    LSMTPServer.Listener := FListener;
    LSMTPServer.Active := true;
    FExceptionClass := nil;
    FIntf.ProcCall;
    Check(FExceptionClass = nil);
  finally
    FreeAndNil(LSMTPServer);
  end;
end;

{ TBaseOneWayTestCase }

procedure TBaseOneWayTestCase.ListenerException(ASender: TObject; AException: Exception);
begin
  FExceptionClass := AException.ClassType;
end;

procedure TBaseOneWayTestCase.SetUp;
begin
  FListener := TIdSoapMsgReceiver.create(nil);
  FListener.ITISource := islResource;
  FListener.ITIResourceName := 'IdSoapInterfaceTests';
  FListener.OnException := ListenerException;
  FListener.Active := true;

end;

procedure TBaseOneWayTestCase.TearDown;
begin
  FreeAndNil(FSender);
  FreeAndNil(FListener);
  // order deliberate - check out of order close up
  // but if you don't do that here, then you will blow up at close down
  FIntf := nil;
end;

{ TIdSoapTwoWayTCPIPTests }

procedure TIdSoapTwoWayTCPIPTests.ClientConnect(ASender: TObject);
begin
  FClientConnectCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ClientDisconnect(ASender: TObject);
begin
  FClientDisconnectCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ClientReceive(ASender : TIdSoapITIProvider; AMessage : TStream);
begin
  FClientReceiveCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ClientSend(ASender : TIdSoapITIProvider; AMessage : TStream);
begin
  FClientSendCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.listenerReceive(ASender : TIdSoapITIProvider; AMessage : TStream);
begin
  FlistenerReceiveCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ListenerSend(ASender : TIdSoapITIProvider; AMessage : TStream);
begin
  FListenerSendCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ServerConnect(ASender: TObject);
begin
  FServerConnectCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ServerDisconnect(ASender: TObject);
begin
  FServerDisconnectCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ServerReceive(ASender : TIdSoapITIProvider; AMessage : TStream);
begin
  FServerReceiveCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.ServerSend(ASender : TIdSoapITIProvider; AMessage : TStream);
begin
  FServerSendCalled := true;
end;

procedure TIdSoapTwoWayTCPIPTests.Setup;
begin
  FListener := TIdSoapMsgReceiver.create(nil);
  FListener.ITISource := islResource;
  FListener.ITIResourceName := 'IdSoapInterfaceTests';
  FListener.OnReceiveMessage := listenerReceive;
  FListener.OnSendMessage := ListenerSend;
  FListener.Active := true;


  FClient := TIdSoapTwoWayTCPIP.create(nil);
  FClient.ITISource := islResource;
  FClient.ITIResourceName := 'IdSoapInterfaceTests';
  FClient.SoapHandler := FListener;
  FClient.Host := '127.0.0.1';
  FClient.Port := 43001;
  FClient.OnConnect := ClientConnect;
  FClient.OnDisconnect := ClientDisconnect;
  FClient.OnReceiveMessage := ClientReceive;
  FClient.OnSendMessage := ClientSend;


  FServer := TIdSoapTwoWayTCPIP.create(nil);
  FServer.ITISource := islResource;
  FServer.ITIResourceName := 'IdSoapInterfaceTests';
  FServer.SoapHandler := FListener;
  FServer.Host := '';
  FServer.Port := 43001;
  FServer.OnConnect := ServerConnect;
  FServer.OnDisconnect := ServerDisconnect;
  FServer.OnReceiveMessage := ServerReceive;
  FServer.OnSendMessage := ServerSend;

  FServerConnectCalled := false;
  FClientConnectCalled := false;
  FClientDisconnectCalled := false;
  FServerDisconnectCalled := false;
  FlistenerReceiveCalled := false;
  FListenerSendCalled := false;
  FClientReceiveCalled := false;
  FClientSendCalled := false;
  FServerReceiveCalled := false;
  FServerSendCalled := false;
end;

procedure TIdSoapTwoWayTCPIPTests.TearDown;
begin
  FreeAndNil(FServer);
  FreeAndNil(FClient);
  FreeAndNil(FListener);
end;

procedure TIdSoapTwoWayTCPIPTests.TestConnectionManagement1;
begin
  Check(not FClient.Active);
  Check(Not FClient.Connected);
  Check(not FServer.Active);
  Check(Not FServer.Connected);
  ExpectedException := EIdSoapUnableToConnect;
  FClient.Active := true;
end;

procedure TIdSoapTwoWayTCPIPTests.TestConnectionManagement2;
begin
  Check(not FServerConnectCalled);
  Check(not FClientConnectCalled);
  Check(not FClientDisconnectCalled);
  Check(not FServerDisconnectCalled);
  Check(not FClient.Active);
  Check(Not FClient.Connected);
  Check(not FServer.Active);
  Check(Not FServer.Connected);

  FServer.Active := true;
  sleep(20);
  Check(FServer.Active);
  Check(Not FServer.Connected);

  FClient.Active := true;
  sleep(20);
  Check(FClient.Active);
  Check(FClient.Connected);
  Check(FServer.Active);
  Check(FServer.Connected);
  Check(FServerConnectCalled);
  Check(FClientConnectCalled);

  FClient.Active := false;
  sleep(20);
  Check(not FClient.Active);
  Check(not FClient.Connected);
  Check(FClientDisconnectCalled);

  Check(FServer.Active);
  Check(not FServer.Connected);
  Check(FServerDisconnectCalled);

  Check(not FlistenerReceiveCalled);
  Check(not FListenerSendCalled);
  Check(not FClientReceiveCalled);
  Check(not FClientSendCalled);
  Check(not FServerReceiveCalled);
  Check(not FServerSendCalled);
end;

procedure TIdSoapTwoWayTCPIPTests.TestConnectionManagement3;
begin
  Check(not FServerConnectCalled);
  Check(not FClientConnectCalled);
  Check(not FClientDisconnectCalled);
  Check(not FServerDisconnectCalled);
  Check(not FClient.Active);
  Check(Not FClient.Connected);
  Check(not FServer.Active);
  Check(Not FServer.Connected);

  FServer.Active := true;
  sleep(20);
  Check(FServer.Active);
  Check(Not FServer.Connected);

  FClient.Active := true;
  sleep(20);
  Check(FClient.Active);
  Check(FClient.Connected);
  Check(FServer.Active);
  Check(FServer.Connected);
  Check(FServerConnectCalled);
  Check(FClientConnectCalled);

  FServer.Active := false;
  sleep(20);
  Check(not FClient.Active);
  Check(not FClient.Connected);
  Check(FClientDisconnectCalled);

  Check(not FServer.Active);
  Check(not FServer.Connected);
  Check(FServerDisconnectCalled);

  Check(not FlistenerReceiveCalled);
  Check(not FListenerSendCalled);
  Check(not FClientReceiveCalled);
  Check(not FClientSendCalled);
  Check(not FServerReceiveCalled);
  Check(not FServerSendCalled);
end;

procedure TIdSoapTwoWayTCPIPTests.TestConnectionManagement4;
var
  LClient : TIdSoapTwoWayTCPIP;
begin
  FServer.AcceptNewConnection := false;
  FServer.Active := true;
  FClient.Active := true;
  sleep(20);
  Check(FServer.Connected);

  LClient := TIdSoapTwoWayTCPIP.create(nil);
  try
    LClient.ITISource := islResource;
    LClient.ITIResourceName := 'IdSoapInterfaceTests';
    LClient.SoapHandler := FListener;
    LClient.Host := '127.0.0.1';
    LClient.Port := 43001;
    LClient.active := true; // cause it will be able to connect
    sleep(50);
    check(not LClient.Active);
    check(FClient.Connected);
  finally
    FreeAndNil(LClient);
  end;
end;

procedure TIdSoapTwoWayTCPIPTests.TestConnectionManagement5;
var
  LClient : TIdSoapTwoWayTCPIP;
begin
  FServer.AcceptNewConnection := true;
  FServer.Active := true;
  FClient.Active := true;
  sleep(20);
  LClient := TIdSoapTwoWayTCPIP.create(nil);
  try
    LClient.ITISource := islResource;
    LClient.ITIResourceName := 'IdSoapInterfaceTests';
    LClient.SoapHandler := FListener;
    LClient.Host := '127.0.0.1';
    LClient.Port := 43001;
    LClient.active := true;
    sleep(20);
    check(not FClient.Connected);
  finally
    FreeAndNil(LClient);
  end;
end;

procedure TIdSoapTwoWayTCPIPTests.TestSoapMessaging;
var
  LIntf : IIdSoapInterfaceTestsInterface;
begin
  FServer.Active := true;
  FClient.Active := true;
  sleep(20);
  Check(FServer.Connected);
  LIntf := IdSoapD4Interface(FClient) as IIdSoapInterfaceTestsInterface;
  Lintf.ProcCall;
  Check(FlistenerReceiveCalled);
  Check(not FListenerSendCalled);
  Check(not FClientReceiveCalled);
  Check(FClientSendCalled);
  Check(FServerReceiveCalled);
  Check(not FServerSendCalled);

  FlistenerReceiveCalled := false;
  FListenerSendCalled := false;
  FClientReceiveCalled := false;
  FClientSendCalled := false;
  FServerReceiveCalled := false;
  FServerSendCalled := false;

  LIntf := IdSoapD4Interface(FServer) as IIdSoapInterfaceTestsInterface;
  Lintf.ProcCall;

  sleep(100); // give the call time to happen
  Check(FlistenerReceiveCalled);
  Check(not FListenerSendCalled);
  Check(FClientReceiveCalled);
  Check(not FClientSendCalled);
  Check(not FServerReceiveCalled);
  Check(FServerSendCalled);
end;

end.

