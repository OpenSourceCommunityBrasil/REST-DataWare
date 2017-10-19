{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15708: IdSoapConsts.pas 
{
{   Rev 1.2    20/6/2003 00:02:44  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:02:12  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:32:30  GGrieve
}
{
IndySOAP: Global Constants
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Header, compression support
  18-Mar 2003   Grahame Grieve                  Add QName
  29-Oct 2002   Grahame Grieve                  new constants for new functionality
  10-Oct 2002   Andrew Cumming                  Added streaming for inherited interface info
  09-Oct 2002   Andrew Cumming                  New stream version + IIdSoapInterface string for inherited interfaces fix
  04-Oct 2002   Grahame Grieve                  Attachments
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  17-Sep 2002   Grahame Grieve                  HexBinary Support
  07-Sep 2002   Grahame Grieve                  fix charset definitions
  25-Aug 2002   Grahame Grieve                  Move version to IdSoapVersion.inc
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  24-Jul 2002   Grahame Grieve                  Change default name
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
  27-Apr 2002   Andrew Cumming                  Changed case of envelope and body to match SOAP standards
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Add WSDL SOAP namespace
  08-Apr 2002   Grahame Grieve                  Objects by reference
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  03-Apr 2002   Grahame Grieve                  Handle ITI Method Request and Response Names
  03-Apr 2002   Grahame Grieve                  Change to Packet writer interface - no difference between request and response
  02-Apr 2002   Grahame Grieve                  Date Time Support
  26-Mar 2002   Grahame Grieve                  rename constants to consistent names and fix xsi integer type
  22-Mar 2002   Grahame Grieve                  WSDL Changes + Version added
  22-Mar 2002   Grahame Grieve                  Begin WSDL definition
  22-Mar 2002   Grahame Grieve                  Change Node handling to differentiate between arrays, elements, and structs
  15-Mar 2002   Grahame Grieve                  TCP/IP support
  14-Mar 2002   Grahame Grieve                  Fixed inisgnedint constant
  14-Mar 2002   Andrew Cumming                  Added IDSOAP_INVALID_POINTER
  14-Mar 2002   Grahame Grieve                  Namespace support
  12-Mar 2002   Grahame Grieve                  Binary Support (TStream)
   4-Mar 2002   Andrew Cumming                  Added define for SETs
   3-Mar 2002   Grahame Grieve                  Namespace constants
  22-Feb 2002   Andrew Cumming                  Some dynamic array consts
   7-Feb 2002   Grahame Grieve                  Add BINARY encoding Parameter Names
   5-Feb 2002   Grahame Grieve                  Add SOAP Encoding parameter names
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapConsts;

{$I IdSoapDefines.inc}

interface

{$I IdSoapVersion.inc}

const
  {$IFDEF DELPHI5}
  PathDelim = '\';                                                                // do not localise
  {$ENDIF}

  MININT = integer($80000000); // when no default is set on a property

  // ITI management
  ID_SOAP_CONFIG_FILE_EXT = '.IdSoapCfg';                                         // do not localise

  // Interface specifics
  ID_SOAP_INTERFACE_BASE_NAME = 'IIdSoapInterface';    // do not localise   MUST be the name of the base IndySoap interface

  // ITI related constants
  ID_SOAP_ITI_BIN_STREAM_VERSION_OLDEST = 7;
  ID_SOAP_ITI_BIN_STREAM_VERSION_SOAPACTION = 8; // When SOAP Action was introduced
  ID_SOAP_ITI_BIN_STREAM_VERSION_NAMES = 9;      // When Name ReDefining was introduced
  ID_SOAP_ITI_BIN_STREAM_VERSION_SOAPOP = 10;    // When Doc|Lit support was introduced
  ID_SOAP_ITI_BIN_STREAM_VERSION_SESSION = 11;    // When Sessional support was introduced
  ID_SOAP_ITI_BIN_STREAM_VERSION_INTF_FIX = 12;    // When interface inheritance was fixed
  ID_SOAP_ITI_BIN_STREAM_VERSION_HEADERS = 13;    // When headers were added

  ID_SOAP_ITI_BIN_STREAM_VERSION = 13;   // SOAP ITI stream version number
  ID_SOAP_ITI_XML_STREAM_VERSION = 7;   // SOAP ITI stream version number

  // ITI XML Node Names
  ID_SOAP_ITI_XML_NODE_NAME = 'Name';                                            // do not localise
  ID_SOAP_ITI_XML_NODE_UNITNAME = 'UnitName';                                    // do not localise
  ID_SOAP_ITI_XML_NODE_GUID = 'GUID';                                            // do not localise
  ID_SOAP_ITI_XML_NODE_ANCESTOR = 'Ancestor';                                    // do not localise
  ID_SOAP_ITI_XML_NODE_METHOD = 'Method';                                        // do not localise
  ID_SOAP_ITI_XML_NODE_CALLINGCONVENTION = 'CallingConvention';                  // do not localise
  ID_SOAP_ITI_XML_NODE_METHODKIND = 'MethodKind';                                // do not localise
  ID_SOAP_ITI_XML_NODE_METHODSESSION = 'Sessional';                              // do not localise
  ID_SOAP_ITI_XML_NODE_RESULTTYPE = 'ResultType';                                // do not localise
  ID_SOAP_ITI_XML_NODE_PARAMETER = 'Parameter';                                  // do not localise
  ID_SOAP_ITI_XML_NODE_PARAMFLAG = 'ParamFlag';                                  // do not localise
  ID_SOAP_ITI_XML_NODE_NAMEOFTYPE = 'NameOfType';                                // do not localise
  ID_SOAP_ITI_XML_NODE_VERSION = 'Version';                                      // do not localise
  ID_SOAP_ITI_XML_NODE_ITI = 'ITI';                                              // do not localise
  ID_SOAP_ITI_XML_NODE_INTERFACE = 'Interface';                                  // do not localise
  ID_SOAP_ITI_XML_NODE_DOCUMENTATION = 'Documentation';                          // do not localise
  ID_SOAP_ITI_XML_NODE_REQUEST_NAME = 'RequestMsgName';                          // do not localise
  ID_SOAP_ITI_XML_NODE_RESPONSE_NAME = 'ResponseMsgName';                        // do not localise
  ID_SOAP_ITI_XML_NODE_NAMESPACE = 'Namespace';                                  // do not localise
  ID_SOAP_ITI_XML_NODE_SOAPACTION = 'SoapAction';                                // do not localise
  ID_SOAP_ITI_XML_NODE_SOAPOPTYPE = 'SoapOpType';                                // do not localise
  ID_SOAP_ITI_XML_NODE_INHERITED_METHOD = 'InheritedMethod';                     // do not localise
  ID_SOAP_ITI_XML_NODE_IS_INHERITED = 'IsInherited';                             // do not localise
  ID_SOAP_ITI_XML_NODE_HEADER = 'Header';                                        // do not localise
  ID_SOAP_ITI_XML_NODE_RESPHEADER = 'Respheader';                                // do not localise

  // XML encoding support:

  ID_SOAP_DEFAULT_NAMESPACE_CODE = 'ns';                                         // do not localise
  ID_SOAP_DS_DEFAULT_ROOT = 'urn:nevrona.com/indysoap/v1/';                      // do not localise

  ID_SOAP_NS_SOAPENV = 'http://schemas.xmlsoap.org/soap/envelope/';              // do not localise
  ID_SOAP_NS_SOAPENC = 'http://schemas.xmlsoap.org/soap/encoding/';              // do not localise
  ID_SOAP_NS_SCHEMA_1999 = 'http://www.w3.org/1999/XMLSchema';                   // do not localise
  ID_SOAP_NS_SCHEMA_INST_1999 = 'http://www.w3.org/1999/XMLSchema-instance';     // do not localise
  ID_SOAP_NS_SCHEMA_2001 = 'http://www.w3.org/2001/XMLSchema';                   // do not localise
  ID_SOAP_NS_SCHEMA_INST_2001 = 'http://www.w3.org/2001/XMLSchema-instance';     // do not localise
  ID_SOAP_NS_WSDL_SOAP = 'http://schemas.xmlsoap.org/wsdl/soap/';                // do not localise
  ID_SOAP_NS_SOAP_HTTP = 'http://schemas.xmlsoap.org/soap/http';                 // do not localise
  ID_SOAP_NS_WSDL =  'http://schemas.xmlsoap.org/wsdl/';                         // do not localise
  ID_SOAP_NS_SOAPENV_CODE = 'soap';                                              // do not localise
  ID_SOAP_NS_SOAPENC_CODE = 'soap-enc';                                          // do not localise
  ID_SOAP_NS_SCHEMA_CODE = 'xs';                                                 // do not localise
  ID_SOAP_NS_SCHEMA_INST_CODE = 'xsi';                                           // do not localise
  ID_SOAP_NS_WSDL_SOAP_CODE = 'soap';                                            // do not localise

  ID_SOAP_NS_SCHEMA = ID_SOAP_NS_SCHEMA_2001;                                    // do not localise
  ID_SOAP_NS_SCHEMA_INST = ID_SOAP_NS_SCHEMA_INST_2001;                          // do not localise

  ID_SOAP_SCHEMA_QNAME = 'QName';
  ID_SOAP_SCHEMA_MINOCCURS = 'minOccurs';                                        // do not localise
  ID_SOAP_SCHEMA_MAXOCCURS = 'maxOccurs';                                        // do not localise
  ID_SOAP_SCHEMA_IMPORT = 'import';                                              // do not localise
  ID_SOAP_SCHEMA_NAMESPACE = 'namespace';                                        // do not localise
  ID_SOAP_SCHEMA_REF = 'ref';                                                    // do not localise
  ID_SOAP_SCHEMA_ELEMENT = 'element';                                            // do not localise

  ID_SOAP_NAME_ENCODINGSTYLE = 'encodingStyle';                                  // do not localise
  ID_SOAP_NAME_MUSTUNDERSTAND = 'mustUnderstand';                                // do not localise
  ID_SOAP_NAME_FAULT = 'Fault';                                                  // do not localise
  ID_SOAP_NAME_FAULTCODE = 'faultcode';                                          // do not localise
  ID_SOAP_NAME_FAULTACTOR = 'faultactor';                                        // do not localise
  ID_SOAP_NAME_FAULTSTRING = 'faultstring';                                      // do not localise
  ID_SOAP_NAME_FAULTDETAIL = 'detail';                                           // do not localise
  ID_SOAP_NAME_SCHEMA_TYPE = 'type';                                             // do not localise
  ID_SOAP_NAME_ENV = 'Envelope';                                                 // do not localise
  ID_SOAP_NAME_BODY = 'Body';                                                    // do not localise
  ID_SOAP_NAME_HEADER = 'Header';                                                // do not localise
  ID_SOAP_NAME_XML_ID = 'id';                                                    // do not localise
  ID_SOAP_NAME_XML_HREF = 'href';                                                // do not localise
  ID_SOAP_NAME_XML_XMLNS = 'xmlns';                                              // do not localise
  ID_SOAP_NAME_SCHEMA_POSITION = 'position';                                     // do not localise
  ID_SOAP_NAME_SCHEMA_OFFSET = 'offset';                                         // do not localise
  ID_SOAP_NAME_SCHEMA_ITEM = 'item';                                             // do not localise

  ID_SOAP_WSDL_OPEN = '##any';

  ID_SOAP_CHARSET_8 = 'charset=utf-8';
  ID_SOAP_CHARSET_16 = 'charset=utf-16';

  // SOAP NAMES OF SIGNIFICANCE
  ID_SOAP_NAME_RESULT = 'return';
  ID_SOAP_NULL_TYPE = 'NULL'; // this is used for the class type for an null and unnamed class reading a SOAP packet

  // SOAP NAMES OF INSIGNIFICANCE
  ID_SOAP_NULL_NODE_NAME = 'Root';
  ID_SOAP_NULL_NODE_TYPE = 'Null';
  ID_SOAP_NAME_REF_TYPE = '#ref'; // this is the arbitrary type assigned to a reference node

  // Schema Types
  ID_SOAP_XSI_TYPE_STRING = 'string';                                            // do not localise
  ID_SOAP_XSI_TYPE_INTEGER = 'int';                                              // do not localise
  ID_SOAP_XSI_TYPE_BOOLEAN = 'boolean';                                          // do not localise
  ID_SOAP_XSI_TYPE_BYTE = 'unsignedByte';                                        // do not localise
  ID_SOAP_XSI_TYPE_CARDINAL = 'unsignedInt';                                     // do not localise
  ID_SOAP_XSI_TYPE_COMP = 'long';                                                // do not localise
  ID_SOAP_XSI_TYPE_CURRENCY = 'decimal';                                         // do not localise
  ID_SOAP_XSI_TYPE_DATETIME = 'dateTime';                                        // do not localise
  ID_SOAP_XSI_TYPE_TIMEINSTANT = 'timeInstant';{from 1999 schema but we allow it}// do not localise
  ID_SOAP_XSI_TYPE_DATE = 'date';                                                // do not localise
  ID_SOAP_XSI_TYPE_TIME = 'time';                                                // do not localise
  ID_SOAP_XSI_TYPE_DOUBLE = 'double';                                            // do not localise
  ID_SOAP_XSI_TYPE_EXTENDED = 'double';                                          // do not localise
  ID_SOAP_XSI_TYPE_INT64 = 'long';                                               // do not localise
  ID_SOAP_XSI_TYPE_SHORTINT = 'byte';                                            // do not localise
  ID_SOAP_XSI_TYPE_SINGLE = 'float';                                             // do not localise
  ID_SOAP_XSI_TYPE_SMALLINT = 'short';                                           // do not localise
  ID_SOAP_XSI_TYPE_WORD = 'unsignedShort';                                       // do not localise
  ID_SOAP_XSI_TYPE_BASE64BINARY = 'base64Binary';                                // do not localise
  ID_SOAP_SOAP_TYPE_BASE64BINARY = 'base64';     {Apache error}                  // do not localise
  ID_SOAP_XSI_TYPE_HEXBINARY = 'hexBinary';                                      // do not localise
  ID_SOAP_SOAPENC_ARRAY = 'Array';                                               // do not localise
  ID_SOAP_SOAPENC_ARRAYTYPE = 'arrayType';                                       // do not localise
  ID_SOAP_XSI_TYPE_QNAME = 'QName';                                              // do not localise
  ID_SOAP_XSI_ATTR_NIL = 'nil';                                                  // do not localise
  ID_SOAP_XSI_ATTR_NULL = 'null';                                                // do not localise
  ID_SOAP_XSI_ATTR_NILLABLE = 'nillable';                                        // do not localise

  // HTTP RPC settings                                                           // do not localise
  ID_SOAP_DEFAULT_SOAP_PATH = '/soap/';                                          // do not localise
  ID_SOAP_HTTP_ACTION_HEADER = 'SOAPAction';                                     // do not localise
// V1.2 ID_SOAP_HTTP_SOAP_TYPE = 'application/soap';                             // do not localise
  ID_SOAP_HTTP_SOAP_TYPE = 'text/xml';                                           // do not localise
  ID_SOAP_HTTP_BIN_TYPE = 'application/Octet-Stream';                            // do not localise
  ID_SOAP_HTTP_DIME_TYPE = 'application/dime';                                   // do not localise

  ID_SOAP_DEFAULT_WSDL_PATH = '/wsdl';                                           // do not localise

  ID_SOAP_HTTP_DEFLATE = 'deflate';

  // TCPIP Communications constants
  ID_SOAP_TCPIP_MAGIC_REQUEST = $49445351; // IDSQ
  ID_SOAP_TCPIP_MAGIC_RESPONSE = $49445341; // IDSA
  ID_SOAP_TCPIP_MAGIC_FOOTER = $49445345; // IDSE
  ID_SOAP_MAX_MIMETYPE_LENGTH = 100;              // not allowed to have interface names longer than this in requests (DoS protection)
  ID_SOAP_MAX_PACKET_LENGTH = 100 * 1024 * 1024;  // not allowed to have interface names longer than 100MB in requests (DoS protection) (should be long enough! - needs more work)
  ID_SOAP_TCPIP_TIMEOUT = 60000;


  // client Interface Handling Settings
  ID_SOAP_BUFFER_SIZE = 8192;          // size of SOAP stub buffer (keep it large for efficient allocs)
  ID_SOAP_MAX_STUB_BUFFER_SIZE = 20;   // max size of a SOAP stub
  ID_SOAP_MAX_STRING_PARAMS = 50;      // max num of string OR widestring params allowed in a single method.
  ID_SOAP_INVALID = '|||';
  
  // you may have up to IDSOAP_MAX_STRING_PARAMS AnsiStrings AND
  //                    IDSOAP_MAX_STRING_PARAMS WideStrings but no more
  // This option uses IDSOAP_MAX_STRING_PARAMS * 8 bytes only during


  // server Interface Handling Settings
  ID_SOAP_INIT_MEM_VALUE = #0;        // what to initialize mem to (generally for the OUT param type). Leave this at 0 - anything else will have fatal consequences
  ID_SOAP_INVALID_POINTER = pointer($fffffffe);   // just to prevent use of invalid pointers

  // Binary Stream Constants
  ID_SOAP_BIN_MAGIC = $10EA8F0A;

  ID_SOAP_BIN_PACKET_EXCEPTION = 1;
  ID_SOAP_BIN_PACKET_MESSAGE = 2;

  ID_SOAP_BIN_NODE_STRUCT = 1;
  ID_SOAP_BIN_NODE_ARRAY = 2;
  ID_SOAP_BIN_NODE_REFERENCE = 3;

  ID_SOAP_BIN_NOTVALID = 0;
  ID_SOAP_BIN_TYPE_PARAM = 1;
  ID_SOAP_BIN_TYPE_NODE = 2;

  ID_SOAP_BIN_CLASS_NIL = 0;
  ID_SOAP_BIN_CLASS_NOT_NIL = 1;

  ID_SOAP_BIN_TYPE_BOOLEAN = 2;
  ID_SOAP_BIN_TYPE_BYTE = 3;
  ID_SOAP_BIN_TYPE_CARDINAL = 4;
  ID_SOAP_BIN_TYPE_CHAR = 5;
  ID_SOAP_BIN_TYPE_COMP = 6;
  ID_SOAP_BIN_TYPE_CURRENCY = 7;
  ID_SOAP_BIN_TYPE_DOUBLE = 8;
  ID_SOAP_BIN_TYPE_ENUM = 9;
  ID_SOAP_BIN_TYPE_EXTENDED = 10;
  ID_SOAP_BIN_TYPE_INT64 = 11;
  ID_SOAP_BIN_TYPE_INTEGER = 12;
  ID_SOAP_BIN_TYPE_SHORTINT = 13;
  ID_SOAP_BIN_TYPE_SHORTSTRING = 14;
  ID_SOAP_BIN_TYPE_SINGLE = 15;
  ID_SOAP_BIN_TYPE_SMALLINT = 16;
  ID_SOAP_BIN_TYPE_STRING = 17;
  ID_SOAP_BIN_TYPE_WIDECHAR = 18;
  ID_SOAP_BIN_TYPE_WIDESTRING = 19;
  ID_SOAP_BIN_TYPE_WORD = 20;
  ID_SOAP_BIN_TYPE_SET = 21;
  ID_SOAP_BIN_TYPE_BINARY = 22;
  ID_SOAP_BIN_TYPE_DATETIME = 23;
  ID_SOAP_BIN_TYPE_DATETIME_NULL = 24;
  ID_SOAP_BIN_TYPE_GENERAL = 25;
  ID_SOAP_BIN_TYPE_XML = 26;

  ID_SOAP_WSDL_SUFFIX_SERVICE = 'Service';
  ID_SOAP_WSDL_SUFFIX_PORT = 'Port';
  ID_SOAP_WSDL_SUFFIX_BINDING = 'Binding';

implementation

end.
