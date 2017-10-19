{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15742: IdSoapManualExceptionFactory.pas 
{
{   Rev 1.1    18/3/2003 11:02:44  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:34:22  GGrieve
}
{
IndySOAP: this unit knows how to create common exceptions that do not descend
from EIdSoapableException

The following exception types are registered here:

* RTL exceptions (sysutils.pas)
* OpenXML exceptions (lot's of them)
* Indy and IndySOAP exceptions

}

{
Version History:
  18-Mar 2003   Grahame Grieve                  Remove IDSOAP_USE_RENAMED_OPENXML
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  18-Jul 2002   Grahame Grieve                  update for missing Soap Exceptions
  16-Jul 2002   Grahame Grieve                  New OpenXML version
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  12-Mar 2002   Grahame Grieve                  Bring Up to date for prior changes to IdSoapExceptions
   8-Mar 2002   Andrew Cumming                  Made D4/D5 compatible
   7-Mar 2002   Grahame Grieve                  Change XML exceptions - new XML release
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapManualExceptionFactory;

{$I IdSoapDefines.inc}

interface

Uses SysUtils;

function IdManualExceptionFactory(AExceptionClassName, AMessage : string):Exception;

implementation

uses
  IdException,
  IdSoapExceptions,
  IdSoapOpenXML,
  IdSoapResourceStrings,
  IdSoapUtilities;

// this implementation isn't very fast. and doesn't have much QWAN.
// But does performance matter? And it's easy to maintain. An alternative
// is to put all the names in a sorted list, have a integer constant for each, look
// the constant in the list, then a big case statement. This is rejected because
// it's easy to screw a system like that up. (We assume that you'll want to add
// your own to this list). If there is a requirement for a dynamically generated
// list of support exceptions that that scheme will happen

function IdManualExceptionFactory(AExceptionClassName, AMessage : string):Exception;
begin
  result := nil;
  if AExceptionClassName = '' then
    begin
    exit;
    end;

{==============================================================================
   SysUtils Exceptions - common RTL exceptions
 ==============================================================================}
  if AnsiSameText(AExceptionClassName, 'Exception') then
    begin
    result := Exception.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EAbort') then
    begin
    result := EAbort.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EHeapException') then
    begin
    result := EHeapException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EOutOfMemory') then
    begin
    result := EOutOfMemory.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIntError') then
    begin
    result := EIntError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EDivByZero') then
    begin
    result := EDivByZero.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ERangeError') then
    begin
    result := ERangeError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIntOverflow') then
    begin
    result := EIntOverflow.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EMathError') then
    begin
    result := EMathError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalidOp') then
    begin
    result := EInvalidOp.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EZeroDivide') then
    begin
    result := EZeroDivide.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EOverflow') then
    begin
    result := EOverflow.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EUnderflow') then
    begin
    result := EUnderflow.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalidPointer') then
    begin
    result := EInvalidPointer.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalidCast') then
    begin
    result := EInvalidCast.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EConvertError') then
    begin
    result := EConvertError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EAccessViolation') then
    begin
    result := EAccessViolation.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EPrivilege') then
    begin
    result := EPrivilege.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EStackOverflow') then
    begin
    result := EStackOverflow.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EControlC') then
    begin
    result := EControlC.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EQuit') then
    begin
    {$IFDEF LINUX}
    result := EQuit.create(AMessage);
    {$ELSE}
    result := Exception.create(AMessage);
    {$ENDIF}
    end
  else if AnsiSameText(AExceptionClassName, 'EVariantError') then
    begin
    result := EVariantError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EPropReadOnly') then
    begin
    result := EPropReadOnly.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EPropWriteOnly') then
    begin
    result := EPropWriteOnly.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EAssertionFailed') then
    begin
    result := EAssertionFailed.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EAbstractError') then
    begin
    {$IFDEF PC_MAPPED_EXCEPTIONS}
    result := Exception.create(AMessage)
    {$ELSE}
    result := EAbstractError.create(AMessage)
    {$ENDIF}
    end
  else if AnsiSameText(AExceptionClassName, 'EIntfCastError') then
    begin
    result := EIntfCastError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalidContainer') then
    begin
    result := EInvalidContainer.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalidInsert') then
    begin
    result := EInvalidInsert.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EPackageError') then
    begin
    result := EPackageError.create(AMessage)
    end
{$IFNDEF DELPHI4}
  else if AnsiSameText(AExceptionClassName, 'ESafecallException') then
    begin
    result := ESafecallException.create(AMessage)
    end
{$ENDIF}    
{==============================================================================
   OpenXML Exceptions
 ==============================================================================}
  else if AnsiSameText(AExceptionClassName, 'EDomException') then
    begin
    result := EDomException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIndex_Size_Err') then
    begin
    result := EIndex_Size_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EDomstring_Size_Err') then
    begin
    result := EDomstring_Size_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EHierarchy_Request_Err') then
    begin
    result := EHierarchy_Request_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EWrong_Document_Err') then
    begin
    result := EWrong_Document_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalid_Character_Err') then
    begin
    result := EInvalid_Character_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ENo_Data_Allowed_Err') then
    begin
    result := ENo_Data_Allowed_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ENo_Modification_Allowed_Err') then
    begin
    result := ENo_Modification_Allowed_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ENot_Found_Err') then
    begin
    result := ENot_Found_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ENot_Supported_Err') then
    begin
    result := ENot_Supported_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInuse_Attribute_Err') then
    begin
    result := EInuse_Attribute_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalid_State_Err') then
    begin
    result := EInvalid_State_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ESyntax_Err') then
    begin
    result := ESyntax_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalid_Modification_Err') then
    begin
    result := EInvalid_Modification_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ENamespace_Err') then
    begin
    result := ENamespace_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalid_Access_Err') then
    begin
    result := EInvalid_Access_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInuse_Node_Err') then
    begin
    result := EInuse_Node_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInuse_Content_Model_Err') then
    begin
    result := EInuse_Content_Model_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInuse_AttributeDefinition_Err') then
    begin
    result := EInuse_AttributeDefinition_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ENo_External_Entity_Allowed_Err') then
    begin
    result := ENo_External_Entity_Allowed_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EUnknown_Document_Format_Err') then
    begin
    result := EUnknown_Document_Format_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EDomASException') then
    begin
    result := EDomASException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EDuplicate_Name_Err') then
    begin
    result := EDuplicate_Name_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'ENo_AS_Available') then
    begin
    result := ENo_AS_Available.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EType_Err') then
    begin
    result := EType_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EValidation_Err') then
    begin
    result := EValidation_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EWrong_MIME_Type_Err') then
    begin
    result := EWrong_MIME_Type_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EWrong_ASModel_Err') then
    begin
    result := EWrong_ASModel_Err.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EParserException') then
    begin
    result := EParserException.create(AMessage)
    end

{==============================================================================
   Indy and IndySOAP exceptions
 ==============================================================================}
  else if AnsiSameText(AExceptionClassName, 'EIdSoapBadParameterValue') then
    begin
    result := EIdSoapBadParameterValue.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapBadDefinition') then
    begin
    result := EIdSoapBadDefinition.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapUnknownType') then
    begin
    result := EIdSoapUnknownType.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapBadITIStore') then
    begin
    result := EIdSoapBadITIStore.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdUnderDevelopment') then
    begin
    result := EIdUnderDevelopment.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapRequirementFail') then
    begin
    result := EIdSoapRequirementFail.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapBadParameterName') then
    begin
    result := EIdSoapBadParameterName.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapBadBinaryFormat') then
    begin
    result := EIdSoapBadBinaryFormat.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapUnknownPropertyName') then
    begin
    result := EIdSoapUnknownPropertyName.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapMethodNotFound') then
    begin
    result := EIdSoapMethodNotFound.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapNamespaceProblem') then
    begin
    result := EIdSoapNamespaceProblem.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapDateTimeError') then
    begin
    result := EIdSoapDateTimeError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapHeaderException') then
    begin
    result := EIdSoapHeaderException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapSessionRequired') then
    begin
    result := EIdSoapSessionRequired.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapSessionInvalid') then
    begin
    result := EIdSoapSessionInvalid.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapSessionChanged') then
    begin
    result := EIdSoapSessionChanged.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSoapBadMimeType') then
    begin
    result := EIdSoapBadMimeType.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdException') then
    begin
    result := EIdException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdAlreadyConnected') then
    begin
    result := EIdAlreadyConnected.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSilentException') then
    begin
    result := EIdSilentException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdReadTimeout') then
    begin
    result := EIdReadTimeout.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdReadLnMaxLineLengthExceeded') then
    begin
    result := EIdReadLnMaxLineLengthExceeded.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdInvalidServiceName') then
    begin
    result := EIdInvalidServiceName.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EInvalidSyslogMessage') then
    begin
    result := EInvalidSyslogMessage.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSSLProtocolReplyError') then
    begin
    result := EIdSSLProtocolReplyError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdConnectTimeout') then
    begin
    result := EIdConnectTimeout.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdConnectException') then
    begin
    result := EIdConnectException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksError') then
    begin
    result := EIdSocksError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksRequestFailed') then
    begin
    result := EIdSocksRequestFailed.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksRequestServerFailed') then
    begin
    result := EIdSocksRequestServerFailed.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksRequestIdentFailed') then
    begin
    result := EIdSocksRequestIdentFailed.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksUnknownError') then
    begin
    result := EIdSocksUnknownError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerRespondError') then
    begin
    result := EIdSocksServerRespondError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksAuthMethodError') then
    begin
    result := EIdSocksAuthMethodError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksAuthError') then
    begin
    result := EIdSocksAuthError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerGeneralError') then
    begin
    result := EIdSocksServerGeneralError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerPermissionError') then
    begin
    result := EIdSocksServerPermissionError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerNetUnreachableError') then
    begin
    result := EIdSocksServerNetUnreachableError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerHostUnreachableError') then
    begin
    result := EIdSocksServerHostUnreachableError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerConnectionRefusedError') then
    begin
    result := EIdSocksServerConnectionRefusedError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerTTLExpiredError') then
    begin
    result := EIdSocksServerTTLExpiredError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerCommandError') then
    begin
    result := EIdSocksServerCommandError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSocksServerAddressError') then
    begin
    result := EIdSocksServerAddressError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdConnectionStateError') then
    begin
    result := EIdConnectionStateError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdDnsResolverError') then
    begin
    result := EIdDnsResolverError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdInvalidSocket') then
    begin
    result := EIdInvalidSocket.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdConnClosedGracefully') then
    begin
    result := EIdConnClosedGracefully.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdResponseError') then
    begin
    result := EIdResponseError.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdClosedSocket') then
    begin
    result := EIdClosedSocket.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPException') then
    begin
    result := EIdTFTPException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPFileNotFound') then
    begin
    result := EIdTFTPFileNotFound.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPAccessViolation') then
    begin
    result := EIdTFTPAccessViolation.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPAllocationExceeded') then
    begin
    result := EIdTFTPAllocationExceeded.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPIllegalOperation') then
    begin
    result := EIdTFTPIllegalOperation.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPUnknownTransferID') then
    begin
    result := EIdTFTPUnknownTransferID.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPFileAlreadyExists') then
    begin
    result := EIdTFTPFileAlreadyExists.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPNoSuchUser') then
    begin
    result := EIdTFTPNoSuchUser.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdTFTPOptionNegotiationFailed') then
    begin
    result := EIdTFTPOptionNegotiationFailed.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdIcmpException') then
    begin
    result := EIdIcmpException.create(AMessage)
    end
  else if AnsiSameText(AExceptionClassName, 'EIdSetSizeExceeded') then
    begin
    result := EIdSetSizeExceeded.create(AMessage)
    end
{==============================================================================
   Couldn't match
 ==============================================================================}
  else
    begin
    result := nil;
    end;
end;

end.

