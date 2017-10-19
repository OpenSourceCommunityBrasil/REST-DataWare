{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15710: IdSoapCSHelpers.pas 
{
{   Rev 1.1    20/6/2003 00:02:50  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:32:36  GGrieve
}
// IdSoapClient and IdSoapServer helpers

{
Version History:
  19-Jun 2003   Grahame Grieve                  Default values support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  26-Mar 2002   Grahame Grieve                  Changes to packet layer
  26-Mar 2002   Andrew Cumming                  More helpers written
  24-Mar 2002   Andrew Cumming                  Added IdSoapRegisterSizeOfBasicType
  22-Mar 2002   Andrew Cumming                  First added
}

Unit IdSoapCSHelpers;

{$I IdSoapDefines.inc}

interface

uses
  IdSoapRpcPacket,
  TypInfo;

Type
  TIdSoapBasicType = ( isbtBoolean,
                       isbtByte     , isbtShortInt     , isbtWord     , isbtSmallInt     , isbtInteger     , isbtCardinal,
                       isbtSetByte  , isbtSetShortInt  , isbtSetWord  , isbtSetSmallInt  , isbtSetInteger  , isbtSetCardinal,
                       isbtEnumByte , isbtEnumShortInt , isbtEnumWord , isbtEnumSmallInt , isbtEnumInteger , isbtEnumCardinal,
                       isbtInt64,
                       isbtSingle, isbtDouble, isbtExtended, isbtComp, isbtCurrency,
                       isbtChar, isbtWideChar,
                       isbtShortString, isbtLongString, isbtWideString,
                       isbtDynArray, isbtClass,
                       isbtUnknown
                     );

const
  IdSoapBasicTypeInteger = [isbtByte,isbtShortInt,isbtWord,isbtSmallInt,isbtInteger,isbtCardinal];
  IdSoapBasicTypeFloat   = [isbtSingle,isbtDouble,isbtExtended,isbtComp,isbtCurrency];
  IdSoapBasicTypeSet     = [isbtSetByte,isbtSetShortInt,isbtSetWord,isbtSetSmallInt,isbtSetInteger,isbtSetCardinal];
  IdSoapBasicTypeEnum    = [isbtEnumByte,isbtEnumShortInt,isbtEnumWord,isbtEnumSmallInt,isbtEnumInteger,isbtEnumCardinal,isbtBoolean];

// convert RTTI type into an IdSoapBasicType
function IdSoapBasicType(ATypeInfo: PTypeInfo): TIdSoapBasicType;
// get raw size of type
function IdSoapSizeOfBasicType(ABasicType: TIdSoapBasicType): Integer;
// get CPU register size of basic type
function IdSoapRegisterSizeOfBasicType(ABasicType: TIdSoapBasicType): Integer;
// used to extract a type name from a basic type (This is for error reporting ONLY)
function IdSoapTypeNameFromBasicType(ABasicType: TIdSoapBasicType): String;
// get a param value from a reader based on its IdSoapBasicType
procedure IdSoapGetParamFromReader(AReader: TIdSoapReader; ABaseNode: TIdSoapNode; AName: String; ABasicType: TIdSOapBasicType; Var AData);
// sets a param value in a reader based in its IdSoapBasicType
procedure IdSoapDefineParamToWriter(AWriter: TIdSoapWriter; ABaseNode: TIdSoapNode; AName: String; ABasicType: TIdSOapBasicType; ADefault : Integer; Var AData);

implementation

Uses
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapUtilities,
  SysUtils;

function IdSoapBasicType(ATypeInfo: PTypeInfo): TIdSoapBasicType;
const ASSERT_LOCATION = 'IdSoapCSHelpers.IdSoapBasicType';
begin
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': ATypeInfo = nil');
  result := isbtUnknown;
  case ATypeInfo^.Kind of
    tkInteger:
      begin
      case GetTypeData(ATypeInfo)^.OrdType of
        otUByte:      result := isbtByte;
        otSByte:      result := isbtShortInt;
        otSWord:      result := isbtSmallInt;
        otUWord:      result := isbtWord;
{$IFNDEF DELPHI4}
        otULong:      result := isbtCardinal;
{$ENDIF}
        otSLong:      result := isbtInteger;
        end;
      end;
    tkFloat:
      begin
      case GetTypeData(ATypeInfo)^.FloatType of
        ftSingle:     result := isbtSingle;
        ftDouble:     result := isbtDouble;
        ftExtended:   result := isbtExtended;
        ftComp:       result := isbtComp;
        ftCurr:       result := isbtCurrency;
        end;
      end;
    tkLString:        result := isbtLongString;
    tkWString:        result := isbtWideString;
    tkString:         result := isbtShortString;
    tkChar:           result := isbtChar;
    tkWChar:          result := isbtWideChar;
    tkEnumeration:
      begin
      if AnsiSameText(ATypeInfo^.Name, 'Boolean') then { do not localize } // kind of a special case as its not really a simple type but we treat it like one
        begin
        result := isbtBoolean;
        end
      else
        begin
        case GetTypeData(ATypeInfo)^.OrdType of
          otSByte:    result := isbtEnumShortInt;
          otUByte:    result := isbtEnumByte;
          otSWord:    result := isbtEnumSmallInt;
          otUWord:    result := isbtEnumWord;
          otSLong:    result := isbtEnumInteger;
{$IFNDEF DELPHI4}
          otULong:    result := isbtEnumCardinal;
{$ENDIF}
          end;
        end;
      end;
    tkSet:
      begin
      case GetTypeData(ATypeInfo)^.OrdType of
        otUByte:      result := isbtSetByte;
        otSByte:      result := isbtSetShortInt;
        otSWord:      result := isbtSetSmallInt;
        otUWord:      result := isbtSetWord;
{$IFNDEF DELPHI4}
        otULong:      result := isbtSetCardinal;
{$ENDIF}
        otSLong:      result := isbtSetInteger;
        end;
      end;
    tkInt64:          result := isbtInt64;
    tkDynArray:       result := isbtDynArray;
    tkClass:          result := isbtClass;
    end;
end;

function IdSoapSizeOfBasicType(ABasicType: TIdSoapBasicType): Integer;
const ASSERT_LOCATION = 'IdSoapCSHelpers.IdSoapSizeOfBasicType';
begin
  case ABasicType of
    isbtBoolean:        result := sizeof(Boolean);
    isbtByte:           result := sizeof(Byte);
    isbtShortInt:       result := sizeof(ShortInt);
    isbtWord:           result := sizeof(Word);
    isbtSmallInt:       result := sizeof(SmallInt);
    isbtInteger:        result := sizeof(Integer);
    isbtCardinal:       result := sizeof(Cardinal);
    isbtSetByte:        result := sizeof(Byte);
    isbtSetShortInt:    result := sizeof(ShortInt);
    isbtSetWord:        result := sizeof(Word);
    isbtSetSmallInt:    result := sizeof(SmallInt);
    isbtSetInteger:     result := sizeof(Integer);
    isbtSetCardinal:    result := sizeof(Cardinal);
    isbtEnumByte:       result := sizeof(Byte);
    isbtEnumShortInt:   result := sizeof(ShortInt);
    isbtEnumWord:       result := sizeof(Word);
    isbtEnumSmallInt:   result := sizeof(SmallInt);
    isbtEnumInteger:    result := sizeof(Integer);
    isbtEnumCardinal:   result := sizeof(Cardinal);
    isbtInt64:          result := sizeof(Int64);
    isbtSingle:         result := sizeof(Single);
    isbtDouble:         result := sizeof(Double);
    isbtExtended:       result := sizeof(Extended);
    isbtComp:           result := sizeof(Comp);
    isbtCurrency:       result := sizeof(Currency);
    isbtChar:           result := sizeof(Char);
    isbtWideChar:       result := sizeof(WideChar);
    isbtShortString:    result := sizeof(ShortString);
    isbtLongString:     result := sizeof(pointer);
    isbtWideString:     result := sizeof(pointer);
    isbtDynArray:       result := sizeof(pointer);
    isbtClass:          result := sizeof(pointer);
    else raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown Basic type '+inttostr(ord(ABasicType)));
    end;
end;

function IdSoapRegisterSizeOfBasicType(ABasicType: TIdSoapBasicType): Integer;
const ASSERT_LOCATION = 'IdSoapCSHelpers.IdSoapRegisterSizeOfBasicType';
begin
  case ABasicType of
    isbtBoolean:        result := 4;
    isbtByte:           result := 4;
    isbtShortInt:       result := 4;
    isbtWord:           result := 4;
    isbtSmallInt:       result := 4;
    isbtInteger:        result := 4;
    isbtCardinal:       result := 4;
    isbtSetByte:        result := 4;
    isbtSetShortInt:    result := 4;
    isbtSetWord:        result := 4;
    isbtSetSmallInt:    result := 4;
    isbtSetInteger:     result := 4;
    isbtSetCardinal:    result := 4;
    isbtEnumByte:       result := 4;
    isbtEnumShortInt:   result := 4;
    isbtEnumWord:       result := 4;
    isbtEnumSmallInt:   result := 4;
    isbtEnumInteger:    result := 4;
    isbtEnumCardinal:   result := 4;
    isbtInt64:          result := 8;
    isbtSingle:         result := 4;
    isbtDouble:         result := 8;
    isbtExtended:       result := 12;
    isbtComp:           result := 8;
    isbtCurrency:       result := 8;
    isbtChar:           result := 4;
    isbtWideChar:       result := 4;
    isbtShortString:    result := 4;
    isbtLongString:     result := 4;
    isbtWideString:     result := 4;
    isbtDynArray:       result := 4;
    isbtClass:          result := 4;
    else raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown Basic type '+inttostr(ord(ABasicType)));
    end;
end;

{ do not localize } { anything in this routine }
function IdSoapTypeNameFromBasicType(ABasicType: TIdSoapBasicType): String;
const ASSERT_LOCATION = 'IdSoapCSHelpers.IdSoapTypeNameFromBasicType';
begin
  case ABasicType of
    isbtBoolean:           Result := 'Boolean';
    isbtByte:              Result := 'Byte';
    isbtShortInt:          Result := 'ShortInt';
    isbtWord:              Result := 'Word';
    isbtSmallInt:          Result := 'SmallInt';
    isbtInteger:           Result := 'Integer';
    isbtCardinal:          Result := 'Cardinal';
    isbtSetByte:           Result := 'Byte (SET)';
    isbtSetShortInt:       Result := 'ShortInt (SET)';
    isbtSetWord:           Result := 'Word (SET)';
    isbtSetSmallInt:       Result := 'SmallInt (SET)';
    isbtSetInteger:        Result := 'Integer (SET)';
    isbtSetCardinal:       Result := 'Cardinal (SET)';
    isbtEnumByte:          Result := 'Byte (Enumeration)';
    isbtEnumShortInt:      Result := 'ShortInt (Enumeration)';
    isbtEnumWord:          Result := 'Word (Enumeration)';
    isbtEnumSmallInt:      Result := 'SmallInt (Enumeration)';
    isbtEnumInteger:       Result := 'Integer (Enumeration)';
    isbtEnumCardinal:      Result := 'Cardinal (Enumeration)';
    isbtInt64:             Result := 'Int64';
    isbtSingle:            Result := 'Single';
    isbtDouble:            Result := 'Double';
    isbtExtended:          Result := 'Extended';
    isbtComp:              Result := 'Comp';
    isbtCurrency:          Result := 'Currenct';
    isbtChar:              Result := 'Char';
    isbtWideChar:          Result := 'WideChar';
    isbtShortString:       Result := 'ShortString';
    isbtLongString:        Result := 'AnsiString';
    isbtWideString:        Result := 'WideString';
    isbtDynArray:          Result := 'DynArray';
    isbtClass:             Result := 'Class';
    else                   result := 'Unknown type '+inttostr(ord(ABasicType));
    end;
end;

procedure IdSoapGetParamFromReader(AReader: TIdSoapReader; ABaseNode: TIdSoapNode; AName: String; ABasicType: TIdSoapBasicType; Var AData);
const ASSERT_LOCATION = 'IdSoapCSHelpers.IdSoapGetParamFromReader';
begin
  assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': Reader is not valid');
  assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': BaseNode is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Parameter Name is blank');

  case ABasicType of
    isbtBoolean:       Boolean(AData)  := AReader.ParamBoolean[ABaseNode, AName];
    isbtByte:          Byte(AData)     := AReader.ParamByte[ABaseNode, AName];
    isbtShortInt:      ShortInt(AData) := AReader.ParamShortInt[ABaseNode, AName];
    isbtWord:          Word(AData)     := AReader.ParamWord[ABaseNode, AName];
    isbtSmallInt:      SmallInt(AData) := AReader.ParamSmallInt[ABaseNode, AName];
    isbtInteger:       Integer(AData)  := AReader.ParamInteger[ABaseNode, AName];
    isbtCardinal:      Cardinal(AData) := AReader.ParamCardinal[ABaseNode, AName];
    isbtSingle:        Single(AData)   := AReader.ParamSingle[ABaseNode, AName];
    isbtDouble:        Double(AData)   := AReader.ParamDouble[ABaseNode, AName];
    isbtExtended:      Extended(AData) := AReader.ParamExtended[ABaseNode, AName];
    isbtComp:          Comp(AData)     := AReader.ParamComp[ABaseNode, AName];
    isbtCurrency:      Currency(AData) := AReader.ParamCurrency[ABaseNode, AName];
    isbtInt64:         Int64(AData)    := AReader.ParamInt64[ABaseNode,AName];
    else               raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+IdSoapTypeNameFromBasicType(ABasicType) + ' is not a supported type'); { do not localize }
    end;
end;

procedure IdSoapDefineParamToWriter(AWriter: TIdSoapWriter; ABaseNode: TIdSoapNode; AName: String; ABasicType: TIdSOapBasicType; ADefault : Integer; Var AData);
const ASSERT_LOCATION = 'IdSoapCSHelpers.IdSoapDefineParamToWriter';
begin
  assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': Reader is not valid');
  assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': BaseNode is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Parameter Name is blank');

  case ABasicType of
    // no default value
    isbtBoolean:       AWriter.DefineParamBoolean(ABaseNode, AName,Boolean(AData));
    isbtByte:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (byte(AData) <> ADefault) then
          begin
          AWriter.DefineParamByte(ABaseNode, AName,Byte(AData));
          end;
        end;
    isbtShortInt:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (ShortInt(AData) <> ADefault) then
          begin
          AWriter.DefineParamShortInt(ABaseNode, AName,ShortInt(AData));
          end;
        end;
    isbtWord:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Word(AData) <> ADefault) then
          begin
          AWriter.DefineParamWord(ABaseNode, AName,Word(AData));
          end;
        end;
    isbtSmallInt:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (SmallInt(AData) <> ADefault) then
          begin
          AWriter.DefineParamSmallInt(ABaseNode, AName,SmallInt(AData));
          end;
        end;
    isbtInteger:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Integer(AData) <> ADefault) then
          begin
          AWriter.DefineParamInteger(ABaseNode, AName,Integer(AData));
          end;
        end;
    isbtCardinal:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Integer(AData) <> ADefault) then
          begin
          AWriter.DefineParamCardinal(ABaseNode, AName,Cardinal(AData));
          end;
        end;
    isbtSingle:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Single(AData) <> ADefault) then
          begin
          AWriter.DefineParamSingle(ABaseNode, AName,Single(AData));
          end;
        end;
    isbtDouble:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Double(AData) <> ADefault) then
          begin
          AWriter.DefineParamDouble(ABaseNode, AName,Double(AData));
          end;
        end;
    isbtExtended:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Extended(AData) <> ADefault) then
          begin
          AWriter.DefineParamExtended(ABaseNode, AName,Extended(AData));
          end;
        end;
    isbtComp:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Comp(AData) <> ADefault) then
          begin
          AWriter.DefineParamComp(ABaseNode, AName,Comp(AData));
          end;
        end;
    isbtCurrency:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Currency(AData) <> ADefault) then
          begin
          AWriter.DefineParamCurrency(ABaseNode, AName,Currency(AData));
          end;
        end;
    isbtInt64:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in AWriter.EncodingOptions) or (Int64(AData) <> ADefault) then
          begin
          AWriter.DefineParamInt64(ABaseNode, AName,Int64(AData));
          end;
        end;
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+IdSoapTypeNameFromBasicType(ABasicType) + ' is not a supported type'); { do not localize }
    end;
end;

end.
