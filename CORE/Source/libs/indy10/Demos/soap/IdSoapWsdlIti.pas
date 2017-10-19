{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15794: IdSoapWsdlIti.pas
{
{   Rev 1.2    20/6/2003 00:05:06  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:04:26  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:37:42  GGrieve
}
{
IndySOAP: interconversion between ITI and WSDL
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Set, header and default value support
  18-Mar 2003   Grahame Grieve                  Schema Extensibility support
  29-Oct 2002   Grahame Grieve                  IdSoapSimpleClass Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  29-Aug 2002   Grahame Grieve                  Fix problem with object inheritence and WSDLs
  23-Aug 2002   Grahame Grieve                  Fix compile problem
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Connect to Name/Type replacement system.
  24-Jul 2002   Grahame Grieve                  Change to Namespace policy, fixes for WSDL -> pascal conversion
  22-Jul 2002   Grahame Grieve                  change to namespace philosphy
  29-May 2002   Grahame Grieve                  Working on WSDL -> Pascal (incomplete)
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  First written
}

unit IdSoapWsdlIti;

{$I IdSoapDefines.inc}

interface

uses
  IdSoapConsts,
  IdSoapDebug,
  IdSoapExceptions,
  IdSoapITI,
  IdSoapITIProvider,
  IdSoapRawXML,
  IdSoapResourceStrings,
  IdSoapRpcUtils,
  IdSoapRTTIHelpers,
  IdSoapTypeRegistry,
  IdSoapTypeUtils,
  IdSoapUtilities,
  IdSoapWSDL,
  SysUtils,
  TypInfo;

Type
  TIdSoapITIDescriber = class (TIdBaseObject)
  private
    FWsdl : TIdSoapWSDL;
    FProvider : TIdSoapITIProvider;
    procedure AddDocLitParam(AElement: TIdSoapWsdlComplexType; APath, AName, ATypeName: string; AITIObject: TIdSoapITIBaseObject);
    procedure AddParam(AMessage: TIdSoapWSDLMessage; APath, AName, ATypeName: string; AITIObject: TIdSoapITIBaseObject);
    procedure BuildBindingDetails(ABinding: TIdSoapWSDLBinding; AInterface: TIdSoapITIInterface);
    procedure BuildDocLitMethod(APortType: TIdSoapWSDLPortType; APath : string; AMethod: TIdSoapITIMethod; AOp: TIdSoapWSDLPortTypeOperation);
    procedure BuildPortTypeDetails(APortType: TIdSoapWSDLPortType; AInterface: TIdSoapITIInterface);
    procedure BuildRPCMethod(APortType: TIdSoapWSDLPortType; APath : string; AMethod: TIdSoapITIMethod; AOp: TIdSoapWSDLPortTypeOperation);

    procedure DescribeHeaders(APath: String; AOp : TIdSoapWSDLBindingOperation; AMessage : TIdSoapWSDLBindingOperationMessage; AHeaderList : TIdSoapITIParamList; AITIObject : TIdSoapITIBaseObject);
    procedure DescribeRawXML(APath : string; var VNamespace, VTypeName : string; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean; AType : TIdSoapWSDLBaseObject);
    procedure DescribeArray(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject: TIdSoapITIBaseObject; ADocLit: boolean);
    procedure DescribeEnumeration(var VNamespace, VTypeName: string; AItiLink : TIdSoapITIBaseObject; ATypeInfo: PTypeInfo);
    procedure DescribeSet(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean);
    procedure DescribeSimpleClass(var VNamespace, VTypeName: string; AClassType: TIdSoapSimpleClassType; AITIObject: TIdSoapITIBaseObject; ADocLit: boolean);
    procedure DescribeSimpleType(var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo);
    procedure DescribeSpecialClass(var VNamespace, VTypeName: string; AHandler: TIdSoapSimpleClassHandler; AITIObject: TIdSoapITIBaseObject; ADocLit: boolean);
    procedure DescribeStruct(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject: TIdSoapITIBaseObject; ADocLit: boolean);
    function RegisterType(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject: TIdSoapITIBaseObject; ADocLit: boolean; AType : TIdSoapWSDLBaseObject) : boolean;
  public
    Constructor create(AWsdl : TIdSoapWSDL; AProvider : TIdSoapITIProvider);
    procedure Describe(AInterface : TIdSoapITIInterface; ALocation : String);
  end;

implementation

const
  ASSERT_UNIT = 'IdSoapWsdlITI';

constructor TIdSoapITIDescriber.create(AWsdl: TIdSoapWSDL; AProvider: TIdSoapITIProvider);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.create';
begin
  inherited create;
  assert(AWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  assert((AProvider = nil) or AProvider.TestValid(TIdSoapITIProvider), ASSERT_LOCATION+': Provider is not valid');

  FWsdl := AWsdl;
  FProvider := AProvider;
end;

procedure TIdSoapITIDescriber.DescribeSimpleType(var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeSimpleType';
var
  LTypeDefn : TIdSoapWsdlSimpleType;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo = nil');

  FWsdl.SeeType(VNamespace, VTypeName); // cause it might refer to itself later.
  // this is a simple case. The app is using something that maps straight onto a simple type, but has given it
  // a different name (usually for improved self documentation of interfaces)
  LTypeDefn := TIdSoapWsdlSimpleType.create(FWsdl, VTypeName);
  LTypeDefn.Info.NameSpace := ID_SOAP_NS_SCHEMA;
  LTypeDefn.Info.Name := GetNativeSchemaType(IdTypeForKind(ATypeInfo.Kind, GetTypeData(ATypeInfo)));
  FWsdl.AddTypeDefinition(VNamespace, VTypeName, LTypeDefn);
end;

procedure TIdSoapITIDescriber.DescribeSimpleClass(var VNamespace, VTypeName: string; AClassType: TIdSoapSimpleClassType; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeSimpleClass';
var
  LTypeDefn : TIdSoapWsdlSimpleType;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(AClassType), ASSERT_LOCATION+': ClassType = nil');

  FWsdl.SeeType(VNamespace, VTypeName); // cause it might refer to itself later.

  LTypeDefn := TIdSoapWsdlSimpleType.create(FWsdl, VTypeName);
  LTypeDefn.Info.NameSpace := AClassType.GetNamespace;
  LTypeDefn.Info.Name := AClassType.GetTypeName;
  LTypeDefn.Nillable := nilTrue;
  FWsdl.AddTypeDefinition(VNamespace, VTypeName, LTypeDefn);
end;

procedure TIdSoapITIDescriber.DescribeSpecialClass(var VNamespace, VTypeName: string; AHandler : TIdSoapSimpleClassHandler; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeSimpleClass';
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(AHandler), ASSERT_LOCATION+': ClassType = nil');

  try
    VNamespace := AHandler.GetNamespace;
    VTypeName := AHandler.GetTypeName;
  finally
    FreeAndNil(AHandler);
  end;
end;

procedure TIdSoapITIDescriber.DescribeRawXML(APath : string; var VNamespace, VTypeName: string; AITIObject: TIdSoapITIBaseObject; ADocLit: boolean; AType : TIdSoapWSDLBaseObject);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeRawXML';
var
  LHandled : boolean;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');

  LHandled := false;
  if assigned(FProvider) and assigned(FProvider.OnGetSchemaType) then
    begin
    FProvider.OnGetSchemaType(FProvider, APath, ADocLit, LHandled, VNamespace, VTypeName);
    end;
  if not LHandled then
    begin
    VNamespace := '';
    VTypeName := '';
    end;
  //ok, we set the naming stuff up. Now we need to mark this item for work later
  assert(AType.TestValid(TIdSoapWSDLBaseObject), ASSERT_LOCATION+': in Raw XML but type not available');
  AType.Path := APath;
end;


procedure TIdSoapITIDescriber.DescribeEnumeration(var VNamespace, VTypeName: string; AItiLink : TIdSoapITIBaseObject; ATypeInfo: PTypeInfo);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeEnumeration';
var
  LTypeDefn : TIdSoapWsdlEnumeratedType;
  LTypeData: PTypeData;
  i: Integer;
  LPChar: PChar;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo = nil');
  assert(ATypeInfo.kind = tkEnumeration, ASSERT_LOCATION+': TypeInfo not for Enumeration');

  FWsdl.SeeType(VNamespace, VTypeName); // cause it might refer to itself later.

  LTypeDefn := TIdSoapWsdlEnumeratedType.create(FWsdl, VTypeName);
  LTypeData := GetTypeData(ATypeInfo);
  if LTypeData^.MinValue <> 0 then
    begin
    raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION+': Tricky enumerated type not handled by IndySOAP');
    end;
  LPChar := PChar(@LTypeData^.NameList[0]);
  for i := 0 to LTypeData^.MaxValue do
    begin
    LTypeDefn.Values.Add(AItiLink.ReplaceEnumName(ATypeInfo^.Name, ShortString(pointer(LPChar)^)));
    inc(LPChar,Ord(LPChar^)+1);  // move to next string
    end;
  FWsdl.AddTypeDefinition(VNamespace, VTypeName, LTypeDefn);
end;

procedure TIdSoapITIDescriber.DescribeSet(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeSet';
var
  LTypeDefn : TIdSoapWsdlSetType;
  LTypeInfo : PTypeInfo;
  LQName : TQName;
  LType, LTypeNS : string;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo = nil');
  assert(ATypeInfo.kind = tkSet, ASSERT_LOCATION+': TypeInfo not for Enumeration');

  FWsdl.SeeType(VNamespace, VTypeName); // cause it might refer to itself later.

  LTypeInfo := GetSetContentType(ATypeInfo);
  AITIObject.ReplaceTypeName(LTypeInfo^.Name, FWsdl.Namespace, LType, LTypeNS);
  LQName :=  TQName.create;
  LQName.NameSpace := LTypeNS;
  LQName.Name := LType;
  LTypeDefn := TIdSoapWsdlSetType.create(FWsdl, VTypeName, LQName);
  RegisterType(APath+'.Content', LTypeNS, LType, LTypeInfo, AITIObject, ADocLit, LTypeDefn);
  FWsdl.AddTypeDefinition(VNamespace, VTypeName, LTypeDefn);
end;


procedure TIdSoapITIDescriber.DescribeStruct(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeStruct';
var
  LPropMan: TIdSoapPropertyManager;
  LIndex : integer;
  LPropInfo : PPropInfo;
  LSchemaType : string;
  LTypeDefn : TIdSoapWsdlComplexType;
  LPropDefn : TIdSoapWsdlSimpleType;
  LTypeInfo : PTypeInfo;
  LType : string;
  LTypeNS : string;
  LTypeData : PTypeData;
  LParentType : PTypeInfo;
  LSubstitutions : PTypeInfoArray;
  i : integer;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo = nil');
  assert(ATypeInfo.kind = tkClass, ASSERT_LOCATION+': TypeInfo not for Class');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITI Link is not valid');

  FWsdl.SeeType(VNamespace, VTypeName); // cause it might refer to itself later.
  LTypeDefn := TIdSoapWsdlComplexType.create(FWsdl, VTypeName);
  LTypeData := GetTypeData(ATypeInfo);
  LParentType := LTypeData^.ParentInfo^;
  if not AnsiSameText(LParentType.Name, 'TIdBaseSoapableClass') then
    begin
    AITIObject.ReplaceTypeName(LParentType^.Name, FWsdl.Namespace, LType, LTypeNS);
    RegisterType(APath, LTypeNS, LType, LParentType, AITIObject, ADocLit, LTypeDefn);
    LTypeDefn.ExtensionBase.NameSpace := LTypeNS;
    LTypeDefn.ExtensionBase.Name := LType;
    end;
  LPropMan := IdSoapGetClassPropertyInfo(ATypeInfo);
  Assert(Assigned(LPropMan),ASSERT_LOCATION+': Unable to locate property info for class ' + ATypeInfo^.Name);
  if LPropMan.OwnPropertyStart > -1 then
    begin
    for LIndex:= LPropMan.OwnPropertyStart + 1 to LPropMan.Count do
      begin
      LPropInfo := LPropMan[LIndex];
      LSchemaType := GetNativeSchemaType(LPropInfo.PropType^.Name);
      LPropDefn := TIdSoapWsdlSimpleType.create(FWsdl, AITIObject.ReplacePropertyName(ATypeInfo^.Name,LPropInfo.Name));
      if ADocLit then
        begin
        LPropDefn.MinOccurs := '0';
        LPropDefn.MaxOccurs := '1';
        end;
      if LPropInfo^.Default <> MININT then
        begin
        if LPropInfo.PropType^.Kind = tkEnumeration then
          begin
          LPropDefn.DefaultValue := IdEnumToString(LPropInfo.PropType^, LPropInfo^.Default);
          end
        else
          begin
          LPropDefn.DefaultValue := inttostr(LPropInfo^.Default);
          end;
        end;
      if LSchemaType <> '' then
        begin
        LPropDefn.Info.NameSpace := ID_SOAP_NS_SCHEMA;
        LPropDefn.Info.Name := LSchemaType;
        end
      else if ADocLit and (LPropInfo.PropType^^.Kind = tkDynArray) then
        begin
        // a special case. We need to collapse
        LPropDefn.MaxOccurs := 'unbounded';
        LTypeInfo := IdSoapGetDynArrBaseTypeInfo(LPropInfo.PropType^);
        AITIObject.ReplaceTypeName(LTypeInfo^.Name, FWsdl.Namespace, LType, LTypeNS);
        RegisterType(APath+'.'+LPropInfo.Name, LTypeNS, LType, LTypeInfo, AITIObject, ADocLit, LPropDefn);
        LPropDefn.Info.NameSpace := LTypeNS;
        LPropDefn.Info.Name := LType;
        end
      else
        begin
        AITIObject.ReplaceTypeName(LPropInfo.PropType^.Name, FWsdl.Namespace, LType, LTypeNS);
        RegisterType(APath+'.'+LPropInfo.Name, LTypeNS, LType, LPropInfo.PropType^, AITIObject, ADocLit, LPropDefn);
        LPropDefn.Info.NameSpace := LTypeNS;
        LPropDefn.Info.Name := LType;
        end;
      LTypeDefn.Elements.AddObject(LPropDefn.Name, LPropDefn);
      end;
    end;
  FWsdl.AddTypeDefinition(VNamespace, VTypeName, LTypeDefn);

  LSubstitutions := GetClassSubstList(ATypeInfo);
  for i := Low(LSubstitutions) to High(LSubstitutions) do
    begin
    AITIObject.ReplaceTypeName(LSubstitutions[i]^.Name, FWsdl.Namespace, LType, LTypeNS);
    RegisterType(APath+'->'+LSubstitutions[i]^.Name, LTypeNS, LType, IdSoapGetTypeInfo(LSubstitutions[i]^.Name), AITIObject, false, LTypeDefn);
    end
end;

procedure TIdSoapITIDescriber.DescribeArray(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeArray';
var
  LTypeDefn : TIdSoapWsdlArrayType;
  LSchemaType : string;
  LType : string;
  LTypeNS : string;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo = nil');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITI Link is not valid');
  FWsdl.SeeType(VNamespace, VTypeName); // cause it might refer to itself later.

  LTypeDefn := TIdSoapWsdlArrayType.create(FWsdl, VTypeName);
  FWsdl.AddTypeDefinition(VNamespace, VTypeName, LTypeDefn);
  ATypeInfo := IdSoapGetDynArrBaseTypeInfo(ATypeInfo);
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': Unable to find leaf type for Array "'+VTypeName+'"');
  LSchemaType := GetNativeSchemaType(ATypeInfo^.Name);
  if LSchemaType <> '' then
    begin
    LTypeDefn.TypeName.NameSpace := ID_SOAP_NS_SCHEMA;
    LTypeDefn.TypeName.Name := LSchemaType;
    end
  else
    begin
    AITIObject.ReplaceTypeName(ATypeInfo^.Name, FWsdl.Namespace, LType, LTypeNS);
    RegisterType(APath+'[]', LTypeNS, LType, ATypeInfo, AITIObject, ADocLit, LTypeDefn);
    LTypeDefn.TypeName.NameSpace := LTypeNS;
    LTypeDefn.TypeName.Name := LType;
    end;
end;

function TIdSoapITIDescriber.RegisterType(APath : string; var VNamespace, VTypeName: string; ATypeInfo: PTypeInfo; AITIObject : TIdSoapITIBaseObject; ADocLit : boolean; AType : TIdSoapWSDLBaseObject) : boolean;
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.RegisterType';
var
  LClassType : TIdSoapSimpleClassType;
  LHandler : TIdSoapSimpleClassHandler;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(VNamespace <> '', ASSERT_LOCATION+': Namespace = ""');
  assert(VTypeName <> '', ASSERT_LOCATION+': TypeName = ""');
  assert(Assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo = nil');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITI Link is not valid');

  result := false;
  if not FWsdl.TypeSeen(VNamespace, VTypeName) then
    begin
    result := true;
    case ATypeInfo.Kind of
      tkUnknown, tkMethod, tkVariant, tkArray, tkRecord, tkInterface :
        begin
        raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': '+RS_ERR_WSDL_UNSUPPORTED_TYPE+' '+IdDescribeTypeKind(ATypeInfo.Kind));
        end;
      tkInteger, tkChar, tkFloat, tkString, tkWChar, tkLString, tkWString, tkInt64:
        begin
        DescribeSimpleType(VNamespace, VTypeName, ATypeInfo);
        end;
      tkEnumeration :
        begin
        if ATypeInfo.Name = 'Boolean' then // though it's not clear that this is actually possible
          begin
          DescribeSimpleType(VNamespace, VTypeName, TypeInfo(Boolean));
          end
        else
          begin
          DescribeEnumeration(VNamespace, VTypeName, AITIObject, ATypeInfo);
          end;
        end;
      tkSet :
        begin
        DescribeSet(APath, Vnamespace, VTypeName, ATypeInfo, AITIObject, ADocLit);
        end;
      tkClass :
        begin
        LClassType := IdSoapGetSimpleClass(ATypeInfo.Name);
        if assigned(LClassType) then
          begin
          DescribeSimpleClass(VNamespace, VTypeName, LClassType, AITIObject, ADocLit);
          end
        else
          begin
          LHandler := IdSoapSpecialType(ATypeInfo.Name);
          if assigned(LHandler) then
            begin
            if LHandler is TIdSoapRawXMLHandler then
              begin
              FreeAndNil(LHandler);
              DescribeRawXML(APath, VNamespace, VTypeName, AITIObject, ADocLit, AType);
              end
            else
              begin
              DescribeSpecialClass(VNamespace, VTypeName, LHandler, AITIObject, ADocLit);
              end;
            end
          else
            begin
            DescribeStruct(APath, VNamespace, VTypeName, ATypeInfo, AITIObject, ADocLit);
            end;
          end;
        end;
      tkDynArray :
        begin
        DescribeArray(APath, VNamespace, VTypeName, ATypeInfo, AITIObject, ADocLit);
        end;
    else
      raise EIdSoapRequirementFail.create(ASSERT_LOCATION+'(2): '+RS_ERR_WSDL_UNSUPPORTED_TYPE+' '+inttostr(ord((ATypeInfo.Kind))));
    end;
    end;
end;

procedure TIdSoapITIDescriber.AddParam(AMessage: TIdSoapWSDLMessage; APath, AName, ATypeName : string; AITIObject : TIdSoapITIBaseObject);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.AddParam';
var
  LSchemaType : string;
  LMessagePart : TIdSoapWSDLMessagePart;
  LName : string;
  LType : string;
  LTypeNS : string;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(AMessage.TestValid(TIdSoapWSDLMessage), ASSERT_LOCATION+': Message is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name = ''''');
  assert(ATypeName <> '', ASSERT_LOCATION+': TypeName = ''''');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITI Link is not valid');

  LName := AITIObject.ReplaceName(AName);
  LSchemaType := GetNativeSchemaType(ATypeName);
  if LSchemaType <> '' then
    begin
    LMessagePart := TIdSoapWSDLMessagePart.create(FWsdl, LName);
    AMessage.Parts.AddObject(LMessagePart.Name, LMessagePart);
    LMessagePart.PartType.NameSpace := ID_SOAP_NS_SCHEMA;
    LMessagePart.PartType.Name := LSchemaType;
    end
  else
    begin
    LMessagePart := TIdSoapWSDLMessagePart.create(FWsdl, LName);
    AMessage.Parts.AddObject(LMessagePart.Name, LMessagePart);
    AITIObject.ReplaceTypeName(ATypeName, FWsdl.Namespace, LType, LTypeNS);
    RegisterType(APath+'.'+AName, LTypeNS, LType, IdSoapGetTypeInfo(ATypeName), AITIObject, false, LMessagePart);
    idRequire((LType <> '') and (LTypeNS <> ''), ASSERT_LOCATION+': A proper QName must be provided for the type of an message parameter in RPC mode (Path = "'+APath+'")');
    LMessagePart.PartType.NameSpace := LTypeNS;
    LMessagePart.PartType.Name := LType;
    end;
end;

procedure TIdSoapITIDescriber.AddDocLitParam(AElement: TIdSoapWsdlComplexType; APath, AName, ATypeName : string; AITIObject : TIdSoapITIBaseObject);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.AddParam';
var
  LSchemaType : string;
  LSimpleType : TIdSoapWsdlSimpleType;
  LName : string;
  LType : string;
  LTypeNS : string;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(AElement.TestValid(TIdSoapWsdlComplexType), ASSERT_LOCATION+': Message is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name = ''''');
  assert(ATypeName <> '', ASSERT_LOCATION+': TypeName = ''''');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITI Link is not valid');

  LName := AITIObject.ReplaceName(AName);
  LSchemaType := GetNativeSchemaType(ATypeName);
  if LSchemaType <> '' then
    begin
    LSimpleType := TIdSoapWsdlSimpleType.create(FWsdl, LName);
    AElement.Elements.AddObject(LSimpleType.Name, LSimpleType);
    LSimpleType.Info.NameSpace := ID_SOAP_NS_SCHEMA;
    LSimpleType.Info.Name := LSchemaType;
    end
  else
    begin
    LSimpleType := TIdSoapWsdlSimpleType.create(FWsdl, LName);
    AElement.Elements.AddObject(LSimpleType.Name, LSimpleType);
    AITIObject.ReplaceTypeName(ATypeName, FWsdl.Namespace, LType, LTypeNS);
    RegisterType(APath, LTypeNS, LType, IdSoapGetTypeInfo(ATypeName), AITIObject, true, LSimpleType);
    LSimpleType.Info.NameSpace := LTypeNS;
    LSimpleType.Info.Name := LType;
    end;
end;

procedure TIdSoapITIDescriber.BuildRPCMethod(APortType: TIdSoapWSDLPortType; APath : string; AMethod : TIdSoapITIMethod; AOp : TIdSoapWSDLPortTypeOperation);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.BuildRPCMethod';
var
  j : integer;
  LMessage : TIdSoapWSDLMessage;
  LParam : TIdSoapITIParameter;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(APortType.TestValid(TIdSoapWSDLPortType), ASSERT_LOCATION+': PortType is not valid');
  assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': PortType is not valid');
  assert(AOp.TestValid(TIdSoapWSDLPortTypeOperation), ASSERT_LOCATION+': PortType is not valid');

  AOp.Input.Message.NameSpace := FWsdl.Namespace;
  AOp.Input.Message.Name := AMethod.RequestMessageName;
  LMessage := TIdSoapWSDLMessage.create(FWsdl, AMethod.RequestMessageName);
  FWsdl.Messages.AddObject(LMessage.Name, LMessage);
  for j := 0 to AMethod.Parameters.count -1 DO
    begin
    LParam := AMethod.Parameters.Param[j];
    if LParam.ParamFlag <> pfOut then
      begin
      AddParam(LMessage, APath+'.'+AMethod.Name, LParam.Name, LParam.NameOfType, LParam);
      end;
    end;

  AOp.Output.Message.NameSpace := FWsdl.Namespace;
  AOp.Output.Message.Name := AMethod.ResponseMessageName;
  LMessage := TIdSoapWSDLMessage.create(FWsdl, AMethod.ResponseMessageName);
  FWsdl.Messages.AddObject(LMessage.Name, LMessage);
  if AMethod.ResultType <> '' then
    begin
    AddParam(LMessage, APath+'.'+AMethod.Name, ID_SOAP_NAME_RESULT, AMethod.ResultType, AMethod);
    end;
  for j := 0 to AMethod.Parameters.count -1 DO
    begin
    LParam := AMethod.Parameters.Param[j];
    if LParam.ParamFlag in [pfVar, pfOut] then
      begin
      AddParam(LMessage, APath+'.'+AMethod.Name, LParam.Name, LParam.NameOfType, LParam);
      end;
    end;
end;

procedure TIdSoapITIDescriber.BuildDocLitMethod(APortType: TIdSoapWSDLPortType; APath : string; AMethod : TIdSoapITIMethod; AOp : TIdSoapWSDLPortTypeOperation);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.BuildDocLitMethod';
var
  i : integer;
  LMessage : TIdSoapWSDLMessage;
  LMessagePart : TIdSoapWSDLMessagePart;
  LElement : TIdSoapWSDLElementDefn;
  LComplexType : TIdSoapWSDLComplexType;
  LParam : TIdSoapITIParameter;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(APortType.TestValid(TIdSoapWSDLPortType), ASSERT_LOCATION+': PortType is not valid');
  assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': PortType is not valid');
  assert(AOp.TestValid(TIdSoapWSDLPortTypeOperation), ASSERT_LOCATION+': PortType is not valid');


  AOp.Input.Message.NameSpace := FWsdl.Namespace;
  AOp.Input.Message.Name := AMethod.Name+'SoapIn';

  LMessage := TIdSoapWSDLMessage.create(FWsdl, AOp.Input.Message.Name);
  FWsdl.Messages.AddObject(LMessage.Name, LMessage);

  LMessagePart := TIdSoapWSDLMessagePart.create(FWsdl, 'parameters');
  LMessage.Parts.AddObject(LMessagePart.Name, LMessagePart);
  LMessagePart.Element.NameSpace := FWsdl.Namespace;
  LMessagePart.Element.Name := AMethod.RequestMessageName;
  LElement := TIdSoapWsdlElementDefn.create(FWsdl, AMethod.RequestMessageName, FWsdl.Namespace);
  FWsdl.AddElementDefinition(FWsdl.Namespace, AMethod.RequestMessageName, LElement);
  LComplexType := TIdSoapWSDLComplexType.create(FWsdl, '');
  LElement.TypeDefn := LComplexType;
  for i := 0 to AMethod.Parameters.count -1 DO
    begin
    LParam := AMethod.Parameters.Param[i];
    if LParam.ParamFlag <> pfOut then
      begin
      AddDocLitParam(LComplexType, APath+'.'+AMethod.Name, LParam.Name, LParam.NameOfType, LParam);
      end;
    end;


  AOp.Output.Message.NameSpace := FWsdl.Namespace;
  AOp.Output.Message.Name := AMethod.Name+'SoapOut';

  LMessage := TIdSoapWSDLMessage.create(FWsdl, AOp.Output.Message.Name);
  FWsdl.Messages.AddObject(LMessage.Name, LMessage);

  LMessagePart := TIdSoapWSDLMessagePart.create(FWsdl, 'parameters');
  LMessage.Parts.AddObject(LMessagePart.Name, LMessagePart);
  LMessagePart.Element.NameSpace := FWsdl.Namespace;
  LMessagePart.Element.Name := AMethod.ResponseMessageName;
  LElement := TIdSoapWsdlElementDefn.create(FWsdl, AMethod.ResponseMessageName, FWsdl.Namespace);
  FWsdl.AddElementDefinition(FWsdl.Namespace, AMethod.ResponseMessageName, LElement);
  LComplexType := TIdSoapWSDLComplexType.create(FWsdl, '');
  LElement.TypeDefn := LComplexType;
  if AMethod.ResultType <> '' then
    begin
    AddDocLitParam(LComplexType, APath+'.'+AMethod.Name, ID_SOAP_NAME_RESULT, AMethod.ResultType, AMethod);
    end;
  for i := 0 to AMethod.Parameters.count -1 DO
    begin
    LParam := AMethod.Parameters.Param[i];
    if LParam.ParamFlag in [pfVar, pfOut] then
      begin
      AddDocLitParam(LComplexType, APath+'.'+AMethod.Name, LParam.Name, LParam.NameOfType, LParam);
      end;
    end;
end;

procedure TIdSoapITIDescriber.BuildPortTypeDetails(APortType: TIdSoapWSDLPortType; AInterface: TIdSoapITIInterface);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.BuildPortTypeDetails';
var
  i : integer;
  LMethod : TIdSoapITIMethod;
  LOp : TIdSoapWSDLPortTypeOperation;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(APortType.TestValid(TIdSoapWSDLPortType), ASSERT_LOCATION+': PortType is not valid');
  // no check on root namespace
  assert(AInterface.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': Interface is not valid');
  for i := 0 to AInterface.Methods.count - 1 do
    begin
    LMethod := AInterface.Methods.objects[i] as TIdSoapITIMethod;
    LOp := TIdSoapWSDLPortTypeOperation.create(FWsdl, LMethod.Name);
    LOp.Documentation := LMethod.Documentation;
    APortType.Operations.AddObject(LOp.Name, LOp);
    if LMethod.EncodingMode = semDocument then
      begin
      BuildDocLitMethod(APortType, AInterface.Name, LMethod, LOp);
      end
    else
      begin
      BuildRPCMethod(APortType, AInterface.Name, LMethod, LOp);
      end;
    end;
end;

procedure TIdSoapITIDescriber.BuildBindingDetails(ABinding: TIdSoapWSDLBinding; AInterface: TIdSoapITIInterface);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.BuildBindingDetails';
var
  i : integer;
  LMethod : TIdSoapITIMethod;
  LOp : TIdSoapWSDLBindingOperation;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(ABinding.TestValid(TIdSoapWSDLBinding), ASSERT_LOCATION+': Binding is not valid');
  assert(AInterface.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': Interface is not valid');

  ABinding.SoapStyle := sbsUnknown;
  ABinding.SoapTransport := ID_SOAP_NS_SOAP_HTTP;
  for i := 0 to AInterface.Methods.count - 1 do
    begin
    LMethod := AInterface.Methods.objects[i] as TIdSoapITIMethod;
    LOp := TIdSoapWSDLBindingOperation.create(FWsdl, LMethod.Name);
    ABinding.Operations.AddObject(LOp.Name, LOp);
    LOp.SoapAction := FWsdl.Namespace + '#'+LMethod.Name;
    if LMethod.EncodingMode = semDocument then
      begin
      LOp.SoapStyle := sbsDocument;
      LOp.Input.SoapUse := sesLiteral;
      LOp.Output.SoapUse := sesLiteral;
      DescribeHeaders(AInterface.Name+'.'+LOp.Name+'.Headers', LOp, LOp.Input, LMethod.Headers, LMethod);
      DescribeHeaders(AInterface.Name+'.'+LOp.Name+'.RespHeaders', LOp, LOp.Output, LMethod.RespHeaders, LMethod);
      end
    else
      begin
      LOp.SoapStyle := sbsRPC;
      LOp.Input.SoapUse := sesEncoded;
      LOp.Output.SoapUse := sesEncoded;
      LOp.Input.SoapEncodingStyle := ID_SOAP_NS_SOAPENC;
      LOp.Output.SoapEncodingStyle := ID_SOAP_NS_SOAPENC;
      end;
    end;
end;

procedure TIdSoapITIDescriber.Describe(AInterface : TIdSoapITIInterface; ALocation : string);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.Describe';
var
  LService : TIdSoapWSDLService;
  LSvcPort : TIdSoapWSDLServicePort;
  LBinding : TIdSoapWSDLBinding;
  LPortType : TIdSoapWSDLPortType;
  LName : string;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  // no check on root ALocation - we allow it to be ''
  assert(AInterface.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': Interface is not valid');

  if FWsdl.Name <> '' then
    begin
    FWsdl.Name := AInterface.Name;
    end;

  LName := AInterface.Name;
  if LName[1] = 'I' then
    begin
    Delete(LName, 1, 1);
    end;
  if not AnsiSameText(Copy(LName, Length(LName)-6, 7), 'service') then
    begin
    LName := LName +ID_SOAP_WSDL_SUFFIX_SERVICE;
    end;
  LService := TIdSoapWSDLService.create(FWsdl, LName);
  FWsdl.Services.AddObject(LService.Name, LService);
  LService.Documentation := AInterface.Documentation;
  LSvcPort := TIdSoapWSDLServicePort.create(FWsdl, LName + 'Soap');
  LService.Ports.AddObject(LSvcPort.Name, LSvcPort);
  LSvcPort.SoapAddress := ALocation;
  LSvcPort.BindingName.NameSpace := FWsdl.Namespace;

  LBinding := TIdSoapWSDLBinding.create(FWsdl, LName + 'Soap');
  FWsdl.Bindings.AddObject(LBinding.Name, LBinding);
  LSvcPort.BindingName.Name := LBinding.Name;
  LBinding.PortType.NameSpace := FWsdl.Namespace;
  BuildBindingDetails(LBinding, AInterface);

  LPortType := TIdSoapWSDLPortType.create(FWsdl, AInterface.Name);
  FWsdl.PortTypes.AddObject(LPortType.Name, LPortType);
  LBinding.PortType.Name := LPortType.Name;
  BuildPortTypeDetails(LPortType, AInterface);
end;

procedure TIdSoapITIDescriber.DescribeHeaders(APath: String; AOp : TIdSoapWSDLBindingOperation; AMessage: TIdSoapWSDLBindingOperationMessage; AHeaderList: TIdSoapITIParamList; AITIObject : TIdSoapITIBaseObject);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDescriber.DescribeHeaders';
var
  i : integer;
  LHeader : TIdSoapWSDLBindingOperationMessageHeader;
  LName, LNs : String;
  LMessage : TIdSoapWSDLMessage;
  LMessagePart : TIdSoapWSDLMessagePart;
  LElement : TIdSoapWSDLElementDefn;
begin
  assert(self.TestValid(TIdSoapITIDescriber), ASSERT_LOCATION+': self is not valid');
  assert(APath <> '', ASSERT_LOCATION+': path is not valid');
  assert(AOp.TestValid(TIdSoapWSDLBindingOperation), ASSERT_LOCATION+': Op is not valid');
  assert(AMessage.TestValid(TIdSoapWSDLBindingOperationMessage), ASSERT_LOCATION+': Message is not valid');
  assert(assigned(AHeaderList), ASSERT_LOCATION+': Headerlist is not valid');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITI Object is not valid');

  for i := 0 to AHeaderList.Count - 1 do
    begin
    LHeader := TIdSoapWSDLBindingOperationMessageHeader.create(FWsdl, AHeaderList.Param[i].Name);
    LHeader.SoapUse := sesLiteral;

    LName := GetNativeSchemaType(AHeaderList.Param[i].NameOfType);
    if LName <> '' then
      begin
      LNs := ID_SOAP_NS_SCHEMA_2001;
      end
    else
      begin
      AITIObject.ReplaceTypeName(AHeaderList.Param[i].NameOfType, FWsdl.Namespace, LName, LNs);
      RegisterType(APath, LNs, LName, AHeaderList.Param[i].TypeInformation, AITIObject, true, nil);
      end;
    if not assigned(FWsdl.GetElementDefinition(LNs, LName)) then
      begin
      LElement := TIdSoapWsdlElementDefn.create(FWsdl, LName, LNs);
      FWsdl.AddElementDefinition(LNs, LName, LElement);
      LElement.TypeInfo.NameSpace := LNs;
      LElement.TypeInfo.Name := LName;
      end;

    LHeader.Message.NameSpace := FWsdl.Namespace;
    LHeader.Message.Name := AOp.Name+LName;
    AMessage.AddHeader(LHeader);

    LMessage := TIdSoapWSDLMessage.create(FWsdl, AOp.Name+LName);
    FWsdl.Messages.AddObject(LMessage.Name, LMessage);
    LMessagePart := TIdSoapWSDLMessagePart.create(FWsdl, 'parameters');
    LMessage.Parts.AddObject(LMessagePart.Name, LMessagePart);

    LMessagePart.Element.NameSpace := LNs;
    LMessagePart.Element.Name := LName;
    end;
end;

end.

