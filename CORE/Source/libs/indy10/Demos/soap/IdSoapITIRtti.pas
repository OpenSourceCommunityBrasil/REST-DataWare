{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15738: IdSoapITIRtti.pas 
{
{   Rev 1.0    11/2/2003 20:34:08  GGrieve
}
{
IndySOAP: this unit knows how to populate an ITI from the RTTI in IntfInfo

Note that due to the way the RTTI is populated, this works differently
to the other ITI's

If you declare a type
type
  TMyInteger = integer;

Then using a parsed ITI, IndySoap will use the type "TMyInteger" in the WSDL
(though the actual type on the wire will be xsi:integer). The RTTI ITI will
generate a WSDL with the type "Integer" since the original type name never
makes it's way into the RTTI (same applies to "longint")

though you can declare it as
type
  TMyInteger = type integer;

to get the same outcome
}

{
Version History:
  17-Sep 2002   Grahame Grieve                  Fix compile problems
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  26-Mar 2002   Grahame Grieve                  Remove hints and warnings
  14-Mar 2002   Grahame Grieve                  Namespace support (UnitName)
   8-Mar 2002   Grahame Grieve                  Resolve TParamFlags Issue - only support one flag
   7-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapITIRtti;

{$I IdSoapDefines.inc}

{$IFNDEF VER140}
This unit should not be included unless VER140 is defined (D6/D7/K2/K3)
{$ENDIF}


interface

uses
  Classes,
  IdSoapITI;

procedure PopulateITIFromRTTI(AITI : TIdSoapITI; ARTTINames : TStringList; AIncludeNames : boolean);

implementation

uses
  IdSoapExceptions,
  IdSoapIntfRegistry,
  IntfInfo,
  SysUtils,
  Typinfo;

function ConvertCallConvToIdSoapCallingConvention(AValue : TCallConv):TIdSoapCallingConvention;
const ASSERT_LOCATION = 'IdSoapITIRtti.ConvertCallConvToIdSoapCallingConvention';
begin
  case AValue of
    ccReg: result := idccRegister;
    ccCdecl: result := idccCdecl;
    ccPascal: result := idccPascal;
    ccStdCall: result := idccStdCall;
    ccSafeCall: result := idccSafeCall;
  else
    raise EIdSoapBadDefinition.create(ASSERT_LOCATION+': Bad value for Calling Convention ('+inttostr(Ord(AValue))+')');
  end;
end;

function GetActiveFlag(AFlagSet : TParamFlags; ADesc : string):TParamFlag;
const ASSERT_LOCATION = 'IdSoapITIRtti.GetActiveFlag';
var
  LFound : boolean;
  i : TParamFlag;
begin
  LFound := false;
  result := pfReference;
  for i := low(TParamFlag) to High(TParamFlag) do
    begin
    if i in AFlagSet then
      begin
      if LFound then
        begin
        raise EIdSoapBadDefinition.Create(ASSERT_LOCATION+': Only parameters with a single flag are supported ('+ADesc+') [Duplicate]');
        end;
      LFound := true;
      result := i;
      end;
    end;

  // IndySoap doesn't differentiate between pfAddress and pfReference
  if result = pfAddress then
    begin
    result := pfReference;
    end;
end;

procedure AddInterfaceToITI(AITI : TIdSoapITI; AInterfaceName : string);
const ASSERT_LOCATION = 'IdSoapITIRtti.AddInterfaceToITI';
var
  LTypeInfo : PTypeInfo;
  LTypeData : pTypeData;
  LIntfInfo : TIntfMetaData;
  LMethInfo : TIntfMethEntry;
  LParamInfo : TIntfParamEntry;
  i, j : integer;
  LITIIntf : TIdSoapITIInterface;
  LITIMethod : TIdSoapITIMethod;
  LITIParam : TIdSoapITIParameter;
begin
  Assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  Assert(AInterfaceName <> '', ASSERT_LOCATION+': Blank Interface Name');
  i := GInterfaceNames.indexof(AInterfaceName);
  Assert(i > -1, ASSERT_LOCATION+': Interface "'+AInterfaceName+'" has not been registered using IdSoapRegisterInterface');
  LTypeInfo := PTypeInfo(GInterfaceNames.Objects[i]);
  Assert(Assigned(LTypeInfo));
  Assert(LTypeInfo.Kind = tkInterface, ASSERT_LOCATION+': Interface Type Info is not for an interface');
  Assert(AnsiSameText(LTypeInfo.Name, AInterfaceName), ASSERT_LOCATION+': Interface Type Info is not for an interface');
  LTypeData := GetTypeData(LTypeInfo);

  LITIIntf := TIdSoapITIInterface.Create(AITI);
  LITIIntf.Name := LTypeInfo.Name;
  LITIIntf.UnitName := LTypeData.IntfUnit;
  LITIIntf.Ancestor := LTypeData.IntfParent^^.Name;
  LITIIntf.GUID := LTypeData.Guid;
  AITI.AddInterface(LITIIntf);

  // we are about to drop out of our usual assurance, and run a Borland method.
  GetIntfMetaData(LTypeInfo, LIntfInfo, fmoNoBaseMethods);

  for i := Low(LIntfInfo.MDA) to High(LIntfInfo.MDA) do
    begin
    LMethInfo := LIntfInfo.MDA[i];
    LITIMethod := TIdSoapITIMethod.Create(AITI, LITIIntf);
    LITIMethod.Name := LMethInfo.Name;
    LITIMethod.CallingConvention := ConvertCallConvToIdSoapCallingConvention(LMethInfo.CC);
    if LMethInfo.ResultInfo = nil then
      begin
      LITIMethod.MethodKind := mkProcedure;
      LITIMethod.ResultType := '';                // do not localize
      end
    else
      begin
      LITIMethod.MethodKind := mkFunction;
      LITIMethod.ResultType := LMethInfo.ResultInfo^.Name;
      end;
    LITIIntf.AddMethod(LITIMethod);

    for j := Low(LMethInfo.Params) to High(LMethInfo.Params) - 1 do
      begin
      LParamInfo := LMethInfo.Params[j];
      LITIParam := TIdSoapITIParameter.create(AITI, LITIMethod);
      LITIParam.Name := LParamInfo.Name;
      LITIParam.ParamFlag := GetActiveFlag(LParamInfo.Flags,  LTypeInfo.Name+'.'+LMethInfo.Name+'.'+LParamInfo.Name);
      LITIParam.NameOfType := LParamInfo.Info^.Name;
      LITIMethod.AddParam(LITIParam);
      end;
    end;
end;

procedure PopulateITIFromRTTI(AITI : TIdSoapITI; ARTTINames : TStringList; AIncludeNames : boolean);
const ASSERT_LOCATION = 'IdSoapITIRtti.PopulateITIFromRTTI';
var
  i : integer;
begin
  Assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  Assert(Assigned(ARTTINames), ASSERT_LOCATION+': RTTINames is not valid');
  // no check on AIncludeNames
  if AIncludeNames then
    begin
    for i := 0 to ARTTINames.count - 1 do
      begin
      AddInterfaceToITI(AITI, ARTTINames[i]);
      end;
    end
  else
    begin
    for i := 0 to GInterfaceNames.count - 1 do
      begin
      if ARTTINames.IndexOf(GInterfaceNames[i]) = -1 then
        begin
        AddInterfaceToITI(AITI, GInterfaceNames[i]);
        end;
      end;
    end;
end;

end.
