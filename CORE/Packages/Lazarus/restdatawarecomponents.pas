{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit restdatawarecomponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  uRESTDWDesignReg, PropertyPersist, uRESTDWBasic, uRESTDWBasicClass, 
  uRESTDWBasicComponent, uRESTDWBasicDB, uRESTDWBasicTypes, uRESTDWBufferDb, 
  uRESTDWComponentBase, uRESTDWComponentEvents, uRESTDWEncodeClass, uRESTDWFileBuffer, 
  uRESTDWMasterDetailData, uRESTDWParams, uRESTDWPoolermethod, 
  uRESTDWResponseTranslator, uRESTDWServerContext, uRESTDWServerEvents, 
  uRESTDWAttachment, uRESTDWAttachmentFile, uRESTDWBuffer, uRESTDWCoder, 
  uRESTDWCoder3to4, uRESTDWCoderBinHex4, uRESTDWCoderHeader, uRESTDWCoderMIME, 
  uRESTDWCoderQuotedPrintable, uRESTDWDataUtils, uRESTDWException, 
  uRESTDWHeaderCoderBase, uRESTDWHeaderList, uRESTDWIOHandler, uRESTDWIOHandlerStream, 
  uRESTDWMessage, uRESTDWMessageClient, uRESTDWMessageCoder, uRESTDWMessageCoderBinHex4, 
  uRESTDWMessageCoderMIME, uRESTDWMessageCoderQuotedPrintable, uRESTDWMessageParts, 
  DWDCPbase64, DWDCPblockciphers, DWDCPcast256, DWDCPconst, DWDCPcrypt2, DWDCPrijndael, 
  DWDCPsha256, DWDCPtypes, uRESTDWConsts, StringBuilderUnit, uRESTDWBase64, 
  uRESTDWCharset, uRESTDWDynamic, uRESTDWJSONObject, uRESTDWMassiveBuffer, uRESTDWMD5, 
  uRESTDWTools, uZlibLaz, uRESTDWDataJSON, uRESTDWDynArray, uRESTDWJSON, 
  uRESTDWJSONInterface, uRESTDWSerialize, uRESTDWDatamodule, uRESTDWJSONViewer, 
  uRESTDWDataset, uRESTDWExprParser, uRESTDWFieldSourceEditor, uRESTDWSqlEditor, 
  uRESTDWUpdSqlEditor, utemplateproglaz, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWDesignReg', @uRESTDWDesignReg.Register);
end;

initialization
  RegisterPackage('restdatawarecomponents', @Register);
end.
