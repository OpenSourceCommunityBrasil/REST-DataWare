{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15782: IdSoapTypeUtils.pas 
{
{   Rev 1.4    23/6/2003 15:11:36  GGrieve
{ missed comments
}
{
{   Rev 1.2    20/6/2003 00:04:48  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:04:14  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:37:02  GGrieve
}
{
IndySOAP: IDSoapTypeUtils

Utility Routines for managing types and Namespaces

Do not localize strings in this unit
}

{
Version History:
  23-Jun 2003   Grahame Grieve                  move isSpecialClass to idSoapRpcUtils
  19-Jun 2003   Grahame Grieve                  Support for sets
  18-Mar 2003   Grahame Grieve                  Define QName
  29-Oct 2002   Grahame Grieve                  accept ID_SOAP_SOAP_TYPE_BASE64BINARY
  04-Oct 2002   Grahame Grieve                  Support for TQName, xsd:integer
  17-Sep 2002   Grahame Grieve                  HexBinary support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  13 Aug 2002   Grahame Grieve                  Add Datetime support
  24-Jul 2002   Grahame Grieve                  Fix schema type -> pascal type conversion
  29-May 2002   Grahame Grieve                  Add support for special types
  29-May 2002   Grahame Grieve                  add CheckXSTypeSupported
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  26-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapTypeUtils;

{$I IdSoapDefines.inc}

interface

uses
  TypInfo;

function IdTypeForKind(AKind: TTypeKind; ATypeData: pTypeData): String;
function GetNativeSchemaType(ATypeName : String):string;
function GetTypeForSchemaType(ASchemaType : string):PTypeInfo;
function CheckXSTypeSupported(AName : string):boolean;

function GetSetContentType(ASetType : PTypeInfo):PTypeInfo;

implementation

uses
  Classes,
  IdSoapConsts,
  IdSoapDateTime,
  IdSoapExceptions,
  IdSoapRawXML,
  IdSoapTypeRegistry,
  IdSoapUtilities,
  SysUtils;

function GetSetContentType(ASetType : PTypeInfo):PTypeInfo;
const ASSERT_LOCATION = 'IdSoapUtilities.GetSetContentType';
var
  LType : PTypeData;
begin
  LType := GetTypeData(ASetType);
  assert(assigned(LType.CompType), ASSERT_LOCATION+': Set with no known comp type (1)');
  result := LType.CompType^;
  assert(assigned(result), ASSERT_LOCATION+': Set with no known comp type (2)');
  assert(result.Kind = tkEnumeration, ASSERT_LOCATION+': only Sets of enumerations are supported by IndySoap');
end;

function GetNativeSchemaType(ATypeName : String):string;
const ASSERT_LOCATION = 'IdSoapUtilities.GetNativeSchemaType';
var
  LTypInfo : PTypeInfo;
  LTypData : PTypeData;
begin
  assert(ATypeName <> '', ASSERT_LOCATION+': ATypeName not provided');
  LTypInfo := IdSoapGetTypeInfo(ATypeName);
  LTypData := GetTypeData(LTypInfo);
  result := '';
  if (LTypInfo.Kind = tkClass) or AnsiSameText(ATypeName, IdTypeForKind(LTypInfo.Kind, LTypData)) then
    begin
    // we will only make direct reference to the schema if the stated type in the interface definition is the
    // same as the actual type. While it doesn't really matter, this makes the WSDL more useful as documentation
    case LTypInfo.Kind OF
      tkUnknown : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Unknown"');
      tkInteger :
        begin
        case LTypData.OrdType of
          otSByte : result := ID_SOAP_XSI_TYPE_SHORTINT;
          otUByte : result := ID_SOAP_XSI_TYPE_BYTE;
          otSWord : result := ID_SOAP_XSI_TYPE_SMALLINT;
          otUWord : result := ID_SOAP_XSI_TYPE_WORD;
          otSLong : result := ID_SOAP_XSI_TYPE_INTEGER;
{$IFNDEF DELPHI4}
          otULong : result := ID_SOAP_XSI_TYPE_CARDINAL;
{$ENDIF}
        else
          raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown Integer Type '+inttostr(ord(LTypData.OrdType)));
        end;
        end;
      tkChar : result := ID_SOAP_XSI_TYPE_STRING;
      tkEnumeration :
        begin
        if LTypInfo.Name = 'Boolean' then
          begin
          result := ID_SOAP_XSI_TYPE_BOOLEAN;
          end
        else
          begin
          result := '';
          end;
        end;
      tkFloat :
        begin
        case LTypData.FloatType of
          ftSingle : result := ID_SOAP_XSI_TYPE_SINGLE;
          ftDouble : result := ID_SOAP_XSI_TYPE_DOUBLE;
          ftExtended : result := ID_SOAP_XSI_TYPE_EXTENDED;
          ftComp : result := ID_SOAP_XSI_TYPE_COMP;
          ftCurr : result := ID_SOAP_XSI_TYPE_CURRENCY;
        else
          raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown Float Type '+inttostr(ord(LTypData.FloatType)));
        end;
        end;
      tkString : result := ID_SOAP_XSI_TYPE_STRING;
      tkSet  : result := '';
      tkClass  :
        begin
        if LTypInfo.Name = 'TStream' then               { do not localize }
          begin
          result := ID_SOAP_XSI_TYPE_BASE64BINARY;
          end
        else if LTypInfo.Name = 'THexStream' then               { do not localize }
          begin
          result := ID_SOAP_XSI_TYPE_HEXBINARY;
          end
        else if LTypInfo.Name = 'TIdSoapDateTime' then { do not localize }
          begin
          Result := ID_SOAP_XSI_TYPE_DATETIME;
          end
        else if LTypInfo.Name = 'TIdSoapDate' then { do not localize }
          begin
          Result := ID_SOAP_XSI_TYPE_DATE;
          end
        else if LTypInfo.Name = 'TIdSoapTime' then { do not localize }
          begin
          Result := ID_SOAP_XSI_TYPE_TIME;
          end
        else if LTypInfo.Name = 'TQName' then { do not localize }
          begin
          Result := ID_SOAP_XSI_TYPE_QNAME;
          end
        else
          begin
          result := '';
          end;
        end;
      tkMethod  : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Method"');
      tkWChar : result := ID_SOAP_XSI_TYPE_STRING;
      tkLString : result := ID_SOAP_XSI_TYPE_STRING;
      tkWString : result := ID_SOAP_XSI_TYPE_STRING;
      tkVariant : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Variant"');
      tkArray : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Array"');
      tkRecord : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Record"');
      tkInterface : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Interface"');
      tkInt64 : result := ID_SOAP_XSI_TYPE_INT64;
      tkDynArray : result := '';
    else
      raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown TypeKind '+inttostr(ord(LTypInfo.Kind)));
    end;
    end;
end;

function IdTypeForKind(AKind : TTypeKind; ATypeData : pTypeData):String;
const ASSERT_LOCATION = 'IdSoapUtilities.IdTypeForKind';
begin
  case AKind of
    tkUnknown : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine Normal Type for "Unknown"');
    tkInteger :
      begin
      case ATypeData^.OrdType of
        otSByte : result := 'ShortInt';
        otUByte : result := 'Byte';
        otSWord : result := 'SmallInt';
        otUWord : result := 'Word';
        otSLong : result := 'Integer';
{$IFNDEF DELPHI4}
        otULong : result := 'Cardinal';
{$ENDIF}
      else
        raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown Integer Type '+inttostr(ord(ATypeData.OrdType)));
      end;
      end;
    tkChar : result := 'Char';
    tkEnumeration : result := 'Boolean'; // at first glance this is wrong. But if we are using a boolean, then we want a match. (Special case)
    tkFloat :
      begin
      case ATypeData^.FloatType of
        ftSingle : result := 'Single';
        ftDouble : result := 'Double';
        ftExtended : result := 'Extended';
        ftComp : result := 'Comp';
        ftCurr : result := 'Currency';
      else
        raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown Float Type '+inttostr(ord(ATypeData.FloatType)));
      end;
      end;
    tkString : result := 'ShortString';
    tkSet  : result := '<no default>';
    tkClass  : result := '<no default>';
    tkMethod  : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Method"');
    tkWChar : result := 'WideChar';
    tkLString : result := 'String';
    tkWString : result := 'WideString';
    tkVariant : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Variant"');
    tkArray : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Array"');
    tkRecord : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Record"');
    tkInterface : raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to determine NativeSchemaType for "Interface"');
    tkInt64 : result := 'Int64';
    tkDynArray : result := '<no default>';
  else
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown TypeKind '+inttostr(ord(AKind)));
  end;

end;

function GetTypeForSchemaType(ASchemaType : string):PTypeInfo;
const ASSERT_LOCATION = 'IdSoapUtilities.GetTypeForSchemaType';
begin
  result := nil;
  if ASchemaType = ID_SOAP_XSI_TYPE_STRING then
    begin
    result := TypeInfo(String);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_INTEGER then
    begin
    result := TypeInfo(INTEGER);
    end
  else if ASchemaType = 'integer' then // cause it comes up occasionally
    begin
    result := TypeInfo(INTEGER);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_BOOLEAN then
    begin
    result := TypeInfo(BOOLEAN);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_BYTE then
    begin
    result := TypeInfo(BYTE);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_CARDINAL then
    begin
    result := TypeInfo(CARDINAL);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_COMP then
    begin
    result := TypeInfo(COMP);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_CURRENCY then
    begin
    result := TypeInfo(CURRENCY);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_DOUBLE then
    begin
    result := TypeInfo(DOUBLE);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_EXTENDED then
    begin
    result := TypeInfo(EXTENDED);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_INT64 then
    begin
    result := TypeInfo(INT64);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_SHORTINT then
    begin
    result := TypeInfo(SHORTINT);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_SINGLE then
    begin
    result := TypeInfo(SINGLE);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_SMALLINT then
    begin
    result := TypeInfo(SMALLINT);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_WORD then
    begin
    result := TypeInfo(WORD);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_BASE64BINARY then
    begin
    result := TypeInfo(TStream);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_HEXBINARY then
    begin
    result := TypeInfo(THexStream);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_DATETIME then
    begin
    result := TypeInfo(TIdSoapDateTime);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_DATE then
    begin
    result := TypeInfo(TIdSoapDate);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_TIME then
    begin
    result := TypeInfo(TIdSoapTime);
    end
  else if ASchemaType = ID_SOAP_XSI_TYPE_QNAME then
    begin
    result := TypeInfo(TIdSoapQName);
    end
  else if ASchemaType = '##any' then
    begin
    result := TypeInfo(TIdSoapRawXML);
    end
  else
    IdRequire(false, ASSERT_LOCATION+': Unsupported schema type '+ASchemaType);
end;

function CheckXSTypeSupported(AName : string):boolean;
// elsewhere, we consider this a type XS if it's in
// http://schemas.xmlsoap.org/soap/encoding/
// or
// http://www.w3.org/2001/XMLSchema
begin
  result :=
     (AName = ID_SOAP_XSI_TYPE_STRING) or
     (AName = ID_SOAP_XSI_TYPE_INTEGER) or
     (AName = 'integer') or // cause it comes up occasionally, even though illegal
     (AName = ID_SOAP_XSI_TYPE_BOOLEAN) or
     (AName = ID_SOAP_XSI_TYPE_BYTE) or
     (AName = ID_SOAP_XSI_TYPE_CARDINAL) or
     (AName = ID_SOAP_XSI_TYPE_COMP) or
     (AName = ID_SOAP_XSI_TYPE_CURRENCY) or
     (AName = ID_SOAP_XSI_TYPE_DATETIME) or
     (AName = ID_SOAP_XSI_TYPE_DATE) or
     (AName = ID_SOAP_XSI_TYPE_TIME) or
     (AName = ID_SOAP_XSI_TYPE_DOUBLE) or
     (AName = ID_SOAP_XSI_TYPE_EXTENDED) or
     (AName = ID_SOAP_XSI_TYPE_INT64) or
     (AName = ID_SOAP_XSI_TYPE_SHORTINT) or
     (AName = ID_SOAP_XSI_TYPE_SINGLE) or
     (AName = ID_SOAP_XSI_TYPE_SMALLINT) or
     (AName = ID_SOAP_XSI_TYPE_WORD) or
     (AName = ID_SOAP_SOAP_TYPE_BASE64BINARY) or //strictly, it's not legitimate to accept this in schema as well as soap
     (AName = ID_SOAP_XSI_TYPE_BASE64BINARY) or
     (AName = ID_SOAP_XSI_TYPE_HEXBINARY) or
     (AName = ID_SOAP_XSI_TYPE_QNAME);
end;

end.

