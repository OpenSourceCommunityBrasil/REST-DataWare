{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15706: IdSoapComponentRegistration.pas 
{
{   Rev 1.0    11/2/2003 20:32:24  GGrieve
}
{
IndySOAP: This unit registers the design time components
}
{
Version History:
  06-Aug 2002   Grahame Grieve                  Add One-Way components
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  05-Apr 2002   Grahame Grieve                  Make TIdSoapClientWinInet IFDEF MSWINDOWS
  02-Apr 2002   Grahame Grieve                  Add TIdSoapClientWinInet
  26-Mar 2002   Grahame Grieve                  Add TIdSoapClientDirect
  22-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapComponentRegistration;

{$I IdSoapDefines.inc}

interface

{$R IdSoapComponentRegistration.dcr}

procedure Register;

implementation

uses
  Classes,
  IdSoapClientDirect,
  IdSoapClientHTTP,
  IdSoapClientTCPIP,
  {$IFDEF MSWINDOWS}
  IdSoapClientWinInet,
  {$ENDIF}
  IdSoapMsgDirect,
  IdSoapMsgEmail,
  IdSoapResourceStrings,
  IdSoapServer,
  IdSoapServerHTTP,
  IdSoapServerTCPIP;

procedure Register;
begin
  RegisterComponents(RS_NAME_INDYSOAP, [
     TIdSoapClientHTTP, TIdSoapClientTCPIP, TIdSoapClientDirect,
     {$IFDEF MSWINDOWS} TIdSoapClientWinInet, {$ENDIF}

     TIdSoapMsgSendDirect, TIdSoapMsgSendEmail,

     TIdSoapServer, TIdSoapMsgReceiver, 

     TIdSoapMsgSMTPListener, TIdSoapMsgPopListener,

     TIdSoapServerHTTP, TIdSOAPServerTCPIP]);
end;

end.
