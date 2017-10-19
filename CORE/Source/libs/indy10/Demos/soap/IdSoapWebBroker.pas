{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15790: IdSoapWebBroker.pas 
{
{   Rev 1.0    11/2/2003 20:37:28  GGrieve
}
{
IndySOAP:

}
{
Version History:
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapWebBroker;

{$I IdSoapDefines.inc}

interface

implementation

end.

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  RequestStream: TStringStream;
  ResponseStream: TStringStream;
  ResponseEncoding: string;
begin
  RequestStream := TStringStream.Create(Request.Content);
  ResponseStream := TStringStream.Create('');

  GIdSoapRequestInfo := TIdSoapRequestInformation.Create;

  IdSoapServer1.HandleSoapRequest(Request.ContentEncoding,
                RequestStream, ResponseStream, ResponseEncoding);

  FreeAndNil(GIdSoapRequestInfo);

  Response.ContentEncoding := ResponseEncoding;
  Response.Content := ResponseStream.DataString;

  RequestStream.Free;
  ResponseStream.Free;
end;
