{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15722: IdSoapExceptions.pas 
{
{   Rev 1.0    11/2/2003 20:33:14  GGrieve
}
{
IndySOAP: Exception types raised by IndySOAP
}

{
Version History:
  04-Oct 2002   Grahame Grieve                  TwoWay TCP/IP Support
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  18-Jul 2002   Grahame Grieve                  Better control over Mime Types
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  02-Apr 2002   Grahame Grieve                  Date Time Support
  12-Mar 2002   Grahame Grieve                  Namespace Enchancements
  03-Mar 2002   Andrew Cumming                  Added EIdSoapMethodNotFound
  28-Feb 2002   Andrew Cumming                  Added EIdSoapUnknownPropertyName
   7-Feb 2002   Grahame Grieve                  All exceptions descend from EIdException, add EIdSoapBadBinaryFormat
   5-Feb 2002   Grahame Grieve                  Add EIdSoapBadParameterName
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapExceptions;

{$I IdSoapDefines.inc}

interface

uses
  IdException;

type
  // base class for all IndySoap exceptions
  EIdSoapException = class (EIdException);

  // raised when a parameter type is not registered with the TypeRegistry
  EIdSoapUnknownType = class(EIdSoapException);

  // raised when there is some other problem with a parameter of an interface in the ITI,
  // or at run time when a parameter value is bad
  EIdSoapBadParameterValue = class(EIdSoapException);

  // raised when there is some other problem with an interface in the ITI
  EIdSoapBadDefinition = class(EIdSoapException);

  // raised when there is some other problem with a stored ITI
  EIdSoapBadITIStore = class(EIdSoapException);

  // raised when some condition that is required for execution to
  // continue has not been met (usually related to a failure on the
  // part of a developer)
  EIdSoapRequirementFail = class(EIdSoapException);

  EIdUnderDevelopment = class(EIdSoapException);

  // raised when the SOAP encoder does not like a parameter name
  EIdSoapBadParameterName = class(EIdSoapException);

  // raised when there is a problem with the binary format
  EIdSoapBadBinaryFormat = class(EIdSoapException);

  // raised when a property name is not found
  EIdSoapUnknownPropertyName = class(EIdSoapException);

  // raised if method not found in VMT
  EIdSoapMethodNotFound = class(EIdSoapException);

  // raised when there is name space problems encoding
  EIdSoapNamespaceProblem = class (EIdException);

  // a date format was invalid
  EIdSoapDateTimeError = class (EIdSoapException);

  // server or client was unhappy with mime type of soap message
  EIdSoapBadMimeType = class (EIdException);

  // server or client had a SOAP header related error
  EIdSoapHeaderException = class (EIdSoapException);

  EIdSoapSessionRequired = class (EIdSoapException);

  // for the server application to raise if session is not valid
  EIdSoapSessionInvalid = class (EIdSoapException);

  // raised by the client when interfaces are tied to the client session and the session has been changed
  EIdSoapSessionChanged = class (EIdSoapException);

  // raised by TIdSoapTwoWayTCPIP if an attempt is made to send while there is no connection
  EIdSoapNotConnected = class (EIdSoapException);

  // raised by TIdSoapTwoWayTCPIP if it can't connect
  EIdSoapUnableToConnect = class (EIdSoapException);

implementation

end.
