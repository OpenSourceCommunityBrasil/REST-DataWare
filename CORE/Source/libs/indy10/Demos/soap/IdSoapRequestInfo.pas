{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15756: IdSoapRequestInfo.pas 
{
{   Rev 1.0    11/2/2003 20:35:30  GGrieve
}
{
IndySOAP: Request Information Support

On the server, when responding to the client, it might be rather useful
to know something about the request. For instance, you might want to know
whether your request is associated with a secure connection, or what cookies
are defined. Or you might need to check or set the SOAP header values.
There's lot's of things you might want to know or do.

The interface metaphor is incredibly convenient, but does shut the server
code off from knowing this kind of information. This unit is a response
to this issue. It defines an abstract root type which will be subclassed
by the server transport implementations to provide further transport specific
details.

The actual Request information is available within the context of a
request from the Thread Variable GIdSoapRequestInfo. This will be nil
if you are not in a SOAP invocation
}

{
Version History:
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  06-Aug 2002   Grahame Grieve                  Add Email to client comms type
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  26-Mar 2002   Grahame Grieve                  Add Direct Client
  14-Mar 2002   Grahame Grieve                  First Release
}

unit IdSoapRequestInfo;

interface

{$I IdSoapDefines.inc}

uses
  IdSoapDebug,
  IdSoapExceptions,
  IdSoapRpcPacket;

type
  TIdSoapClientCommsSecurity = (
     ccsUnknown,          { Transport layer doesn't know }
     ccsInsecure,         { Transport Layer knows that the client is anonymous and insecure }
     ccSecure,            { Comms are secure (SSL, etc) but client is not identified }
     ccAuthenticated);    { Client is both secure and unambiguously identified (by some PKI system) }

  TIdSoapClientCommsType = (
         cctHTTP,   { Classic Soap on HTTP, IdSoapClientHTTP/IdSoapServerHTTP }
         cctTCPIP,  { IndySoap custom TCP/IP protocol, for speed. IdSoapClientTCPIP/IdSoapServerTCPIP }
         cctDirect, { Direct call within process from client to server. IdSoapClientDirect }
         cctEmail   { Email (One Way) protocol }
       );

  TIdSoapSession = class (TIdBaseObject);

  // yes, in theory this should be an interface. But we don't want any more garbage collection issues than we already have
  TIdSoapAbstractCookieIntf = class (TIdBaseObject)
  public
    function GetCookie(Const AName : string) : string; virtual; abstract;
    procedure SetCookie(Const AName, AValue : string); virtual; abstract;
  end;


  TIdSoapRequestInformation = class (TIdBaseObject)
  private
    FClientCommsSecurity: TIdSoapClientCommsSecurity;
    FCommsType: TIdSoapClientCommsType;
    FReader: TIdSoapReader;
    FWriter: TIdSoapWriter;
    FServer: TObject;
    FSession: TObject;
    FCookieServices: TIdSoapAbstractCookieIntf;
  public
    property ClientCommsSecurity : TIdSoapClientCommsSecurity read FClientCommsSecurity write FClientCommsSecurity;
    property CommsType : TIdSoapClientCommsType read FCommsType write FCommsType;

    // The Reader and Writer are made available for you to examine them
    // You should not attempt to write to the writer except if it is an XML
    // writer and you are writing to the header section
    property Reader : TIdSoapReader read FReader write FReader;
    property Writer : TIdSoapWriter read FWriter write FWriter;

    property Server : TObject read FServer write FServer; // due to circular unit reference issues, this can't be a TIdSoapServer by declaration. But that's what it is - the server that handled the call
    property Session : TObject read FSession write FSession; // we don't know what this might be - that's up the host application
    property CookieServices : TIdSoapAbstractCookieIntf read FCookieServices write FCookieServices;
  end;

threadvar
  GIdSoapRequestInfo : TIdSoapRequestInformation;

implementation

end.
