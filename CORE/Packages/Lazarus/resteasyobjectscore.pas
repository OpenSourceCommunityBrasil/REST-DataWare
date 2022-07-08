{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit resteasyobjectscore;

{$warn 5023 off : no warning about unused units}
interface

uses
  uZlibLaz, utemplateproglaz, uRESTDWDataJSON, uRESTDWAbout, uRESTDWBasic, 
  uRESTDWBasicClass, uRESTDWBasicDB, uRESTDWBasicTypes, uRESTDWBufferDb, 
  uRESTDWComponentEvents, uRESTDWEncodeClass, uRESTDWFileBuffer, 
  uRESTDWMasterDetailData, uRESTDWParams, uRESTDWPoolermethod, uRESTDWReg, 
  uRESTDWResponseTranslator, uRESTDWServerContext, uRESTDWServerEvents, 
  PropertyPersist, DWDCPblockciphers, DWDCPconst, DWDCPcrypt2, DWDCPtypes, 
  DWDCPbase64, DWDCPcast256, DWDCPrijndael, DWDCPsha256, uRESTDWAboutForm, 
  uRESTDWMessageClient, uRESTDWMessageCoder, uRESTDWMessageCoderBinHex4, 
  uRESTDWMessageCoderMIME, uRESTDWMessageCoderQuotedPrintable, 
  uRESTDWMessageParts, DataUtils, uRESTDWAttachment, uRESTDWAttachmentFile, 
  uRESTDWBuffer, uRESTDWCoder, uRESTDWCoder3to4, uRESTDWCoderBinHex4, 
  uRESTDWCoderHeader, uRESTDWCoderMIME, uRESTDWCoderQuotedPrintable, 
  uRESTDWException, uRESTDWHeaderCoderBase, uRESTDWHeaderList, 
  uRESTDWIOHandler, uRESTDWIOHandlerStream, uRESTDWMessage, uRESTDWConsts, 
  uRESTDWCharset, uRESTDWDynamic, uRESTDWJSONObject, uRESTDWMassiveBuffer, 
  uRESTDWMD5, uRESTDWTools, StringBuilderUnit, uDWConst404HTML, uRESTDWBase64, 
  uRESTDWDynArray, uRESTDWJSON, uRESTDWJSONInterface, uRESTDWSerialize, 
  uRESTDWDatamodule, uRESTDWJSONViewer, uRESTDWDataset, uRESTDWExprParser, 
  uRESTDWSqlEditor, uRESTDWUpdSqlEditor, uRESTDWFieldSourceEditor, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uRESTDWReg', @uRESTDWReg.Register);
end;

initialization
  RegisterPackage('resteasyobjectscore', @Register);
end.
