{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RESTDataWareComponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWBasic, uRESTDWBasicClass, uRESTDWBasicDB, uRESTDWBasicTypes, 
  uRESTDWBufferDb, uRESTDWComponentEvents, uRESTDWFileBuffer, 
  uRESTDWMasterDetailData, uRESTDWParams, uRESTDWPoolermethod, 
  uRESTDWResponseTranslator, uRESTDWServerContext, uRESTDWServerEvents, 
  uRESTDWAttachment, uRESTDWAttachmentFile, uRESTDWBuffer, uRESTDWCoder, 
  uRESTDWCoder3to4, uRESTDWCoderBinHex4, uRESTDWCoderHeader, uRESTDWCoderMIME, 
  uRESTDWCoderQuotedPrintable, uRESTDWDataUtils, uRESTDWException, 
  uRESTDWHeaderCoderBase, uRESTDWHeaderList, uRESTDWIOHandler, 
  uRESTDWIOHandlerStream, uRESTDWMessage, uRESTDWMessageClient, 
  uRESTDWMessageCoder, uRESTDWMessageCoderBinHex4, uRESTDWMessageCoderMIME, 
  uRESTDWMessageCoderQuotedPrintable, uRESTDWMessageParts, DWDCPbase64, 
  DWDCPblockciphers, DWDCPcast256, DWDCPconst, DWDCPcrypt2, DWDCPrijndael, 
  DWDCPsha256, DWDCPtypes, uRESTDWConsts, uRESTDWDatamodule, 
  uRESTDWJSONViewer, uRESTDWFieldSourceEditor, uRESTDWSqlEditor, 
  uRESTDWUpdSqlEditor, utemplateproglaz, uRESTDWBufferBase, StringBuilderUnit, 
  uRESTDWBase64, uRESTDWDynamic, uRESTDWJSONObject, uRESTDWMassiveBuffer, 
  uRESTDWMD5, uRESTDWTools, uRESTDWDataJSON, uRESTDWJSON, 
  uRESTDWJSONInterface, uRESTDWSerialize, uRESTDWMimeTypes, uRESTDWAbout, 
  uRESTDWZlib, uRESTDWMemoryDataset, uRESTDWDesignReg, uRESTDWProtoTypes, 
  uRESTDWSelfSigned, uRESTDWExprParser, uRESTDWAuthenticators, 
  uRESTDWStorageBin, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWDesignReg', @uRESTDWDesignReg.Register);
end;

initialization
  RegisterPackage('RESTDataWareComponents', @Register);
end.
