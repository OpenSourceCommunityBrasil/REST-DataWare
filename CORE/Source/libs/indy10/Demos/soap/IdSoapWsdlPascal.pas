{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15796: IdSoapWsdlPascal.pas 
{
{   Rev 1.6    23/6/2003 21:29:12  GGrieve
{ fix for Linux EOL issues
}
{
{   Rev 1.5    23/6/2003 15:11:50  GGrieve
{ missed comments
}
{
{   Rev 1.3    20/6/2003 00:05:10  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.2    18/3/2003 11:04:30  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.1    25/2/2003 13:14:14  GGrieve
}
{
{   Rev 1.0    11/2/2003 20:37:48  GGrieve
}
{
IndySOAP: WSDL -> Pascal conversion
}

{
Version History:
  23-Jun 2003   Grahame Grieve                  fix for EOL on Linux
  23-Jun 2003   Grahame Grieve                  Fix syntax error
  19-Jun 2003   Grahame Grieve                  set, header and default value support; overhaul service -> interface mapping
  18-Mar 2003   Grahame Grieve                  Qname and RawXML support
  25-Feb 2003   Grahame Grieve                  allow exclusion of types
  29-Oct 2002   Grahame Grieve                  Fix for operation namespace issue; IdSoapSimpleClass support, better Element support
  04-Oct 2002   Grahame Grieve                  Add notes regarding use of inLine Arrays when mode is RPC
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  29-Aug 2002   Grahame Grieve                  Fix problem with object inheritence and WSDLs
  28-Aug 2002   Grahame Grieve                  Fix naming issues - overloaded methods, read wrapper node name from wrong place
  27-Jul 2002   Grahame Grieve                  Linux fixes
  26-Jul 2002   Grahame Grieve                  D4 Compiler fixes
  25-Aug 2002   Grahame Grieve                  Fix bug with GetXXX routine - must have a client provided
  23-Aug 2002   Grahame Grieve                  Fix compile problems in D6
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  22-Aug 2002   Grahame Grieve                  Support type and name redefining properly
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition. WSDL layer yet to be fixed
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  06-Aug 2002   Grahame Grieve                  Factory / Soap Address support
  24-Jul 2002   Grahame Grieve                  First developed
}

unit IdSoapWsdlPascal;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  {$IFNDEF DELPHI4}
  Contnrs,
  {$ENDIF}
  IdSoapDebug,
  IdSoapITI,
  IdSoapRpcPacket,
  IdSoapUtilities,
  IdSoapWsdl;

type
  TPortTypeEntry = class (TIdBaseObject)
  private
    FSvc : TIdSoapWSDLService;
    FPort : TIdSoapWSDLPortType;
    FBind : TIdSoapWSDLBinding;
  end;

  TIdSoapWSDLToPascalConvertor = class (TIdBaseObject)
  private
    FComments : TStringList;
    FExemptTypes : TStringList;
    FUsesClause : TStringList;
    FSoapSvcPorts : TObjectList;
    FValidPortTypes : TStringList;
    FDefinedTypes : TStringList;
    FUsedPascalIDs : TStringList;
    FReservedPascalNames : TStringList;
    FNameAndTypeComments : TStringList;

    FStream : TStream;
    FWsdl : TIdSoapWsdl;
    FIti : TIdSoapITI;
    FOneInterface : TIdSoapITIInterface;

    FUnitName : string;
    FWSDLSource: string;
    FAddFactory: boolean;
    FFactoryText : string;
    FUseIdSoapDateTime :boolean;
    FUseClasses :boolean;
    FUsesRawXML : boolean;
    FPrependTypeNames : boolean;
    FDefaultEncoding : TIdSoapEncodingMode;
    FResourceFileName: string;
    FOnlyOneInterface: boolean;
    FOneInterfaceName: string;

    procedure Write(const s:string);
    procedure Writeln(const s:string);
    procedure ListSoapSvcPorts;
    procedure ListDescendents(ADescendents : TObjectList; AName : TQName);
    procedure ProcessSoapHeaders(AMsg : TIdSoapWSDLBindingOperationMessage; AMethod : TIdSoapITIMethod; AHeaderList : TIdSoapITIParamList);
    procedure ProcessOperation(AInterface : TIdSoapITIInterface; AOp : TIdSoapWSDLPortTypeOperation; ABind : TIdSoapWSDLBinding);
    procedure ProcessMessageParts(AMethod : TIdSoapITIMethod; AMessage : TIdSoapWSDLMessage; AIsOutput : boolean);
    function  ProcessType(AMethod : TIdSoapITIMethod; AType : IdSoapWSDL.TQName):string;
    function  ProcessElement(AMethod : TIdSoapITIMethod; AElement : IdSoapWSDL.TQName):string;
    function GetInterfaceForEntry(AEntry : TPortTypeEntry):TIdSoapITIInterface;
    procedure WriteITI;
    procedure WriteMethod(AMeth : TIdSoapITIMethod; ADefSoapAction : string);
    function  DescribeParam(AParam : TIdSoapITIParameter):String;
    function  WriteComplexType(AMethod : TIdSoapITIMethod; ATypeName : TQName; AClassName : string; AType : TIdSoapWsdlComplexType; out VAncestor, VImpl, VReg : string):String;
    function  TypeIsArray(AType : IdSoapWSDL.TQName):boolean;
    procedure ProcessPorts;
    procedure WriteHeader;
    procedure WriteTypes;
    procedure WriteImpl;
    function  AllMethodsAreDocument(AIntf : TIdSoapITIInterface):boolean;
    procedure LoadReservedWordList;
    function  ChoosePascalNameForType(const ASoapName: string): String;
    function  ChoosePascalName(Const AClassName, ASoapName : string; AAddNameChange : boolean):String;
    function CreateArrayType(AMethod: TIdSoapITIMethod; ABaseType: IdSoapWSDL.TQName): string;
    procedure ProcessRPCOperation(AOp: TIdSoapWSDLPortTypeOperation; AMethod: TIdSoapITIMethod);
    procedure ProcessDocLitOperation(AOp: TIdSoapWSDLPortTypeOperation; AMethod: TIdSoapITIMethod);
    function FindRootElement(AMethod : TIdSoapITIMethod; AName: string): TIdSoapWsdlElementDefn;
    procedure ProcessDocLitParts(AMethod: TIdSoapITIMethod; ABaseElement: TIdSoapWSDLElementDefn; AIsOutput: boolean);
    function GetOpNamespace(AOp: TIdSoapWSDLPortTypeOperation;
      ABind: TIdSoapWSDLBinding): string;
    function GetEnumName(AEnumType, AEnumValue: string): String;
    function MakeInterfaceForEntry(
      AEntry: TPortTypeEntry): TIdSoapITIInterface;
    function GetServiceSoapAddress(AService: TIdSoapWSDLService): String;
  public
    constructor create;
    destructor destroy; override;
    property Comments : TStringList read FComments;
    property UnitName : string read FUnitName write FUnitName;
    property WSDLSource : string read FWSDLSource write FWSDLSource;
    property ResourceFileName : string read FResourceFileName write FResourceFileName;
    property AddFactory : boolean read FAddFactory write FAddFactory;
    property PrependTypeNames : boolean read FPrependTypeNames write FPrependTypeNames;
    property OneInterfaceName : string read FOneInterfaceName write FOneInterfaceName;
    property OnlyOneInterface : boolean read FOnlyOneInterface write FOnlyOneInterface;
    procedure SetExemptTypes(AList : String);
    procedure SetUsesClause(AList : string);
    procedure Convert(AWsdl : TIdSoapWsdl; AStream : TStream);
  end;

implementation

uses
  {$IFDEF LINUX}

  {$ELSE}
  ActiveX,
  ComObj,
  {$ENDIF}
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapOpenXML,
  IdSoapTypeRegistry,
  IdSoapTypeUtils,
  SysUtils,
  TypInfo;

const
  ASSERT_UNIT = 'IdSoapWsdlPascal';
  MULTIPLE_ADDRESSES = 'Multiple Addresses For this Interface (or Indeterminate)';

type
  TIdSoapTypeType = (idttSimple, idttSet, idttArray, idttClass);

  TIdSoapWSDLPascalFragment = class (TIdBaseObject)
  private
    FPascalName : string;
    FAncestor : string;
    FTypeType : TIdSoapTypeType;
    FCode : string;
    FDecl : string;
    FImpl : string;
    FReg : string;
    FIncludeInPascal : boolean;
  public
    Constructor create;
  end;

procedure Check(ACondition : boolean; AComment :String);
begin
  if not ACondition then
    begin
    raise EIdSoapException.create(AComment);
    end;
end;

{ TIdSoapWSDLPascalFragment }

constructor TIdSoapWSDLPascalFragment.create;
begin
  inherited;
  FIncludeInPascal := true;
end;

{ TIdSoapWSDLToPascalConvertor }

constructor TIdSoapWSDLToPascalConvertor.create;
begin
  inherited;
  FComments := TStringList.create;
  FSoapSvcPorts := TObjectList.create(false);
  FValidPortTypes := TIdStringList.create(true);
  FDefinedTypes := TIdStringList.create(true);
  FUsedPascalIDs := TStringList.create;
  FReservedPascalNames := TStringList.create;
  FNameAndTypeComments := TStringList.create;
  FExemptTypes := TStringList.create;
  FUsesClause := TStringList.create;
  LoadReservedWordList;
end;

destructor TIdSoapWSDLToPascalConvertor.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.destroy';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FNameAndTypeComments);
  FreeAndNil(FReservedPascalNames);
  FreeAndNil(FUsedPascalIDs);
  FreeAndNil(FDefinedTypes);
  FreeAndNil(FValidPortTypes);
  FreeAndNil(FSoapSvcPorts);
  FreeAndNil(FComments);
  FreeAndNil(FExemptTypes);
  FreeAndNil(FUsesClause);
  inherited;
end;

procedure TIdSoapWSDLToPascalConvertor.Convert(AWsdl: TIdSoapWsdl; AStream: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.Convert';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AWsdl.TestValid(TIdSoapWsdl), ASSERT_LOCATION+': WSDL is not valid');
  Assert(Assigned(AStream), ASSERT_LOCATION+': Stream is not valid');
  Assert(IsValidIdent(UnitName), ASSERT_LOCATION+': UnitName is not valid');

  FStream := AStream;
  FWsdl := AWsdl;
  FComments.Clear;
  FUseIdSoapDateTime := false;
  FUseClasses := false;
  FUsesRawXML := false;

  AWsdl.Validate; // check that it's internally self consistent
  ListSoapSvcPorts;
  IdRequire(FValidPortTypes.count > 0, 'Error converting WSDL to Pascal Source: No acceptable SOAP Services were found in WSDL');
  FIti := TIdSoapITI.create;
  try
    ProcessPorts;

    WriteHeader;
    WriteTypes;
    WriteITI;
    Writeln('Implementation');
    Writeln('');
    if FResourceFileName <> '' then
      begin
      Writeln('{$R '+FResourceFileName+'}');
      Writeln('');
      end;
    Writeln('uses');
    Writeln('  IdSoapRTTIHelpers,');
    if FAddFactory then
      begin
      Writeln('  IdSoapUtilities,');
      end;
    Writeln('  SysUtils;');
    Writeln('');
    WriteImpl;
    Writeln('End.');
  finally
    FreeAndNil(FIti);
  end;
end;

procedure TIdSoapWSDLToPascalConvertor.Write(const s: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.Write';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  FStream.Write(s[1], length(s));
end;

procedure TIdSoapWSDLToPascalConvertor.Writeln(const s: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.WriteLn';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Write(s+EOL_WINDOWS);
end;

procedure TIdSoapWSDLToPascalConvertor.ListSoapSvcPorts;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ListSoapSvcPorts';
var
  iSvc : integer;
  iSvcPort : integer;
  iBind : integer;
  iPort : integer;
  LSvc : TIdSoapWSDLService;
  LPort : TIdSoapWSDLServicePort;
  LBind : TIdSoapWSDLBinding;
  LEntry : TPortTypeEntry;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');

  for iSvc := 0 to FWsdl.Services.count - 1 do
    begin
    LSvc := FWsdl.Services.Objects[iSvc] as TIdSoapWSDLService;
    Assert(LSvc.TestValid(TIdSoapWSDLService), ASSERT_LOCATION+': Svc '+inttostr(iSvc)+' is not valid');
    for iSvcPort := 0 to LSvc.Ports.Count - 1 do
      begin
      try
        LPort := LSvc.Ports.Objects[iSvcPort] as TIdSoapWSDLServicePort;
        Check(LPort.SoapAddress <> '', 'Service '+LSvc.Name+'.'+LPort.Name+' ignored as no SOAP Address was specified');
        iBind := FWsdl.Bindings.IndexOf(LPort.BindingName.Name);
        Check(iBind <> -1, 'Service '+LSvc.Name+'.'+LPort.Name+' ignored as binding could not be found');
        LBind := FWsdl.Bindings.objects[iBind] as TIdSoapWSDLBinding;
        Check(LBind.SoapTransport = ID_SOAP_NS_SOAP_HTTP, 'Service '+LSvc.Name+'.'+LPort.Name+' ignored as Soap:Document is transport type is not supported');
        iPort := FWsdl.PortTypes.IndexOf(LBind.PortType.Name);
        Check(iPort <> -1, 'Service '+LSvc.Name+'.'+LPort.Name+' ignored as Binding PortType not found');
        LEntry := TPortTypeEntry.create;
        LEntry.FSvc := LSvc;
        LEntry.FBind := LBind;
        LEntry.FPort := FWsdl.PortTypes.Objects[iPort] as TIdSoapWSDLPortType;
        FValidPortTypes.AddObject(LPort.SoapAddress, LEntry);
      except
        on e:EIdSoapException do
          begin
          FComments.add('* '+e.message);
          FComments.add('');
          end
        else
          raise;
      end;
      end;
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.ProcessRPCOperation(AOp: TIdSoapWSDLPortTypeOperation; AMethod: TIdSoapITIMethod);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessRPCOperation';
var
  i : integer;
  LMessage : TIdSoapWSDLMessage;
begin
  Assert(Self.testValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid' );
  Assert(AOp.TestValid(TIdSoapWSDLPortTypeOperation), ASSERT_LOCATION+': Op is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': method is not valid');

  AMethod.RequestMessageName := AOp.Name;
  AMethod.ResponseMessageName := AOp.Name+'Response';

  i := FWsdl.Messages.IndexOf(AOp.Input.Message.Name);
  Assert(i <> -1, ASSERT_LOCATION+': unable to find input message definition for Operation "'+AOp.Name+'"');
  LMessage := FWsdl.Messages.objects[i] as TIdSoapWSDLMessage;
  ProcessMessageParts(AMethod, LMessage, false);

  i := FWsdl.Messages.IndexOf(AOp.output.Message.Name);
  Assert(i <> -1, ASSERT_LOCATION+': unable to find output message definition for Operation "'+AOp.Name+'"');
  LMessage := FWsdl.Messages.objects[i] as TIdSoapWSDLMessage;
  ProcessMessageParts(AMethod, LMessage, true);

  // no process headers for RPC at the moment
end;

function TIdSoapWSDLToPascalConvertor.FindRootElement(AMethod : TIdSoapITIMethod; AName : string):TIdSoapWsdlElementDefn;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.FindRootElement';
var
  i : integer;
  LMessage : TIdSoapWSDLMessage;
  LPart : TIdSoapWSDLMessagePart;
begin
  Assert(Self.testValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid' );
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': method is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  
  i := FWsdl.Messages.IndexOf(AName);
  Assert(i <> -1, ASSERT_LOCATION+': unable to find input message definition for Operation "'+AName+'"');
  LMessage := FWsdl.Messages.objects[i] as TIdSoapWSDLMessage;
  Assert(LMessage.Parts.count = 1, ASSERT_LOCATION+': Operation "'+AMethod.Name+'" is a doc|lit service. The definition for the message "'+AName+'" has more than one part ("'+LMessage.Parts.CommaText+'"). IndySoap does not support this');
  LPart := LMessage.Parts.Objects[0] as TIdSoapWSDLMessagePart;
  Assert(LPart.Element.Name <> '', ASSERT_LOCATION+': Operation "'+AMethod.Name+'" is a doc|lit service but parameter is not an element');
  i := FWsdl.SchemaSection[LPart.Element.Namespace].Elements.IndexOf(LPart.Element.Name);
  Assert(i > -1, ASSERT_LOCATION+': Operation "'+AMethod.Name+'": Element "'+LPart.Element.Name+'" in "'+LPart.Element.Namespace+'" not found');
  result := FWsdl.SchemaSection[LPart.Element.Namespace].Elements.Objects[i] as TIdSoapWsdlElementDefn;
  Assert(result.Namespace = LPart.Element.Namespace, ASSERT_LOCATION+': Namespace mismatch internally');
  Assert(result.Namespace = FWsdl.Namespace, 'Operation "'+AMethod.Name+'": Base Element "'+LPart.Element.Name+'" is in the namespace "'+LPart.Element.Namespace+'" which is different to the Interface Namespace "'+FWsdl.Namespace+'". Cannot continue');
end;

procedure TIdSoapWSDLToPascalConvertor.ProcessDocLitOperation(AOp: TIdSoapWSDLPortTypeOperation; AMethod: TIdSoapITIMethod);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessDocLitOperation';
var
  LBaseElement : TIdSoapWsdlElementDefn;
begin
  Assert(Self.testValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid' );
  Assert(AOp.TestValid(TIdSoapWSDLPortTypeOperation), ASSERT_LOCATION+': Op is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': method is not valid');

//  ok, are we in document mode? If we are, then the name of the message is the
//  name of the element that is the first part of the message.
//  we have a rule that there can only be one part per message - otherwise what would
//  it''s message name be? that would put it outside the scope of IndySoap.
  LBaseElement := FindRootElement(AMethod, AOp.Input.Message.Name);
  AMethod.RequestMessageName := LBaseElement.Name;
  ProcessDocLitParts(AMethod, LBaseElement, false);

  LBaseElement := FindRootElement(AMethod, AOp.Output.Message.Name);
  AMethod.ResponseMessageName := LBaseElement.Name;
  ProcessDocLitParts(AMethod, LBaseElement, true);
end;

function TIdSoapWSDLToPascalConvertor.GetOpNamespace(AOp: TIdSoapWSDLPortTypeOperation; ABind : TIdSoapWSDLBinding):string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.GetOpNamespace';
var
  i : integer;
  LBindOp : TIdSoapWSDLBindingOperation;
begin
  Assert(Self.testValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid' );
  Assert(AOp.TestValid(TIdSoapWSDLPortTypeOperation), ASSERT_LOCATION+': Op is not valid');
  Assert(ABind.TestValid(TIdSoapWSDLBinding), ASSERT_LOCATION+': Bind is not valid');

  i := ABind.Operations.IndexOf(AOp.Name+'|'+AOp.Input.Name+'|'+AOp.Output.Name);
  if i > -1 then
    begin
    LBindOp := ABind.Operations.Objects[i] as TIdSoapWSDLBindingOperation;
    if assigned(LBindOp.Input) then
      begin
      result := LBindOp.Input.SoapNamespace;
      if assigned(LBindOp.Output) then
        begin
        Assert(LBindOp.Input.SoapNamespace = LBindOp.Output.SoapNamespace, ASSERT_LOCATION+': input and output namespaces must be the same');
        end;
      end
    else
      begin
      if assigned(LBindOp.Output) then
        begin
        result := LBindOp.Output.SoapNamespace;
        end
      else
        begin
        result := '';
        end;
      end;
    end
  else
    begin
    result := '';
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.ProcessSoapHeaders(AMsg: TIdSoapWSDLBindingOperationMessage; AMethod: TIdSoapITIMethod; AHeaderList: TIdSoapITIParamList);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessSoapHeaders';
var
  i, j : integer;
  LHeader : TIdSoapWSDLBindingOperationMessageHeader;
  LParam : TIdSoapITIParameter;
  LMsg : TIdSoapWSDLMessage;
  LPart : TIdSoapWSDLMessagePart;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AMsg.TestValid(TIdSoapWSDLBindingOperationMessage), ASSERT_LOCATION+': Msg is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': Method is not valid');
  Assert(AHeaderList.TestValid(TIdSoapITIParamList), ASSERT_LOCATION+': HeaderList is not valid');

  for i := 0 to AMsg.Headers.count -1 do
    begin
    LHeader := AMsg.Headers.Objects[i] as TIdSoapWSDLBindingOperationMessageHeader;
    // ignore: SoapUse, SoapEncodingStyle, SoapNamespace until we have some cause to look at them
    Assert(LHeader.Message.Namespace = FWsdl.Namespace, ASSERT_LOCATION+': namespace problem - looking for a message in namespace "'+LHeader.Message.Namespace+'", but wsdl is in namespace "'+FWsdl.Namespace+'"');
    j := FWsdl.Messages.IndexOf(LHeader.Message.Name);
    Assert(j <> -1, ASSERT_LOCATION+': unable to find header message definition for Operation "'+LHeader.Message.Name+'"');
    LMsg := FWsdl.Messages.objects[j] as TIdSoapWSDLMessage;
    Assert(LMsg.Parts.count = 1, ASSERT_LOCATION+': header "'+LHeader.Message.Name+'" has multiple parts - this is not supported');
    LPart := LMsg.Parts.Objects[0] as TIdSoapWSDLMessagePart;

    LParam := TIdSoapITIParameter.create(AMethod.ITI, AMethod);
    LParam.Name := ChoosePascalName('', LPart.Name, true);
    if LPart.Element.Name <> '' then
      begin
      LParam.NameOfType := ProcessElement(AMethod, LPart.Element);
      end
    else
      begin
      LParam.NameOfType := ProcessType(AMethod, LPart.PartType);
      end;
    AHeaderList.AddParam(LParam);
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.ProcessOperation(AInterface : TIdSoapITIInterface; AOp: TIdSoapWSDLPortTypeOperation; ABind : TIdSoapWSDLBinding);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessOperation';
var
  LMethod : TIdSoapITIMethod;
  i : integer;
  LBindOp : TIdSoapWSDLBindingOperation;
  LName : string;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AOp.TestValid(TIdSoapWSDLPortTypeOperation), ASSERT_LOCATION+': WSDL is not valid');
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  Assert(FIti.TestValid(TIdSoapITI), ASSERT_LOCATION+': WSDL is not valid');

  LName := ChoosePascalName('', AOp.Name, false);
  if AInterface.Methods.indexof(LName) <> -1 then
    begin
    i := 0;
    repeat
      inc(i);
      LName := ChoosePascalName('', AOp.Name + inttostr(i), false);
    until AInterface.Methods.indexof(LName) = -1;
    end;

  LMethod := TIdSoapITIMethod.create(FIti, AInterface);
  LMethod.CallingConvention := idccStdCall;
  LMethod.Name := LName;
  AInterface.Methods.AddObject(LMethod.Name, LMethod);
  LMethod.Documentation := AOp.Documentation;
  i := ABind.Operations.IndexOf(AOp.Name+'|'+AOp.Input.Name+'|'+AOp.Output.Name);
  if i > -1 then
    begin
    LBindOp := ABind.Operations.Objects[i] as TIdSoapWSDLBindingOperation;
    LMethod.SoapAction := LBindOp.SoapAction;
    if LBindOp.SoapStyle = sbsDocument then
      begin
      LMethod.EncodingMode := semDocument;
      end;
    ProcessSoapHeaders(LBindOp.Input, LMethod, LMethod.Headers);
    ProcessSoapHeaders(LBindOp.Output, LMethod, LMethod.RespHeaders);
    end;
  if LMethod.EncodingMode = semDocument then
    begin
    ProcessDocLitOperation(AOp, LMethod);
    end
  else
    begin
    ProcessRPCOperation(AOp, LMethod);
    end;
  if LMethod.ResultType <> '' then
    begin
    LMethod.MethodKind := mkFunction;
    end
  else
    begin
    LMethod.MethodKind := mkProcedure;
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.ProcessMessageParts(AMethod: TIdSoapITIMethod; AMessage: TIdSoapWSDLMessage; AIsOutput: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessMessageParts';
var
  i : integer;
  LPart : TIdSoapWSDLMessagePart;
  LType : string;
  LParam : TIdSoapITIParameter;
  LPascalName : string;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': WSDL is not valid');
  Assert(AMessage.TestValid(TIdSoapWSDLMessage), ASSERT_LOCATION+': WSDL is not valid');
  // no check AIsOutput

  for i := 0 to AMessage.Parts.count -1 do
    begin
    LPart := AMessage.Parts.Objects[i] as TIdSoapWSDLMessagePart;
    if LPart.Element.Name <> '' then
      begin
      LType := ProcessElement(AMethod, LPart.Element);
      end
    else
      begin
      LType := ProcessType(AMethod, LPart.PartType);
      end;
    if AIsOutput then
      begin
      if (i = 0) and (AnsiSameText(LPart.Name, 'return') or AnsiSameText(LPart.Name, 'result')) then
        begin
        AMethod.ResultType := LType;
        end
      else
        begin
        LPascalName := ChoosePascalName('', LPart.Name, true);
        if AMethod.Parameters.indexof(LPascalName) = -1 then
          begin
          LParam := TIdSoapITIParameter.create(FIti, AMethod);
          AMethod.Parameters.AddObject(LPascalName, LParam);
          LParam.Name := LPascalName;
          LParam.ParamFlag := pfOut;
          LParam.NameOfType := LType;
          end
        else
          begin
          LParam := AMethod.Parameters.ParamByName[LPascalName];
          Assert(LParam.NameOfType = LType, ASSERT_LOCATION+': different types in and out for parameter "'+AMethod.Name+'.'+LPascalName+'"');
          LParam.ParamFlag := pfVar;
          end;
        end;
      end
    else
      begin
      LParam := TIdSoapITIParameter.create(FIti, AMethod);
      LPascalName := ChoosePascalName('', LPart.Name, true);
      AMethod.Parameters.AddObject(LPascalName, LParam);
      LParam.Name := LPascalName;
      LParam.ParamFlag := pfConst;
      LParam.NameOfType := LType;
      end;
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.ProcessDocLitParts(AMethod: TIdSoapITIMethod; ABaseElement: TIdSoapWSDLElementDefn; AIsOutput: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessDocLitParts';
var
  i : integer;
  LName : string;
  LPascalName : string;
  LType : string;
  LComplexType : TIdSoapWsdlComplexType;
  LPart : TIdSoapWSDLAbstractType;
  AElement : TIdSoapWSDLElementDefn;
  LParam : TIdSoapITIParameter;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': WSDL is not valid');
  Assert(ABaseElement.TestValid(TIdSoapWSDLElementDefn), ASSERT_LOCATION+': WSDL is not valid');
  // no check AIsOutput

  Assert(ABaseElement.TypeDefn.TestValid(TIdSoapWsdlComplexType), ASSERT_LOCATION+': The base element must be a complex type in doc|lit');
  LComplexType := ABaseElement.TypeDefn as TIdSoapWsdlComplexType;
  for i := 0 to LComplexType.Elements.count -1 do
    begin
    LPart := LComplexType.Elements.Objects[i] as TIdSoapWSDLAbstractType;
    if LPart is TIdSoapWsdlElementDefn then
      begin
      Assert((LPart as TIdSoapWsdlElementDefn).IsReference, ASSERT_LOCATION+': expected a reference');
      AElement := FWsdl.GetElement((LPart as TIdSoapWsdlElementDefn).TypeInfo);
      Assert(AElement.TestValid(TIdSoapWSDLElementDefn), ASSERT_LOCATION+': Referenced Element is not valid');
      Assert(AElement.TypeInfo.Name <> '', ASSERT_LOCATION+': Referenced Element has no type');
      LType := ProcessType(AMethod, AElement.TypeInfo);
      LName := AElement.Name;
      end
    else if LPart is TIdSoapWsdlSimpleType then
      begin
      LType := ProcessType(AMethod, (LPart as TIdSoapWsdlSimpleType).Info);
      LName := LPart.Name;
      end
    else
      Raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': unexpected type '+LPart.ClassName);

    LPascalName := ChoosePascalName('', LName, true);
    if AIsOutput then
      begin
      if (i = 0) and (AnsiSameText(LName, 'return') or AnsiSameText(LName, 'result')) or AnsiSameText(LName, AMethod.Name+'result') then
        begin
        AMethod.ResultType := LType;
        end
      else
        begin
        if AMethod.Parameters.indexof(LPascalName) = -1 then
          begin
          LParam := TIdSoapITIParameter.create(FIti, AMethod);
          AMethod.Parameters.AddObject(LPascalName, LParam);
          LParam.Name := LPascalName;
          LParam.ParamFlag := pfOut;
          LParam.NameOfType := LType;
          end
        else
          begin
          LParam := AMethod.Parameters.ParamByName[LPascalName];
          Assert(LParam.NameOfType = LType, ASSERT_LOCATION+': different types in and out for parameter "'+AMethod.Name+'.'+LPascalName+'"');
          LParam.ParamFlag := pfVar;
          end;
        end;
      end
    else
      begin
      LParam := TIdSoapITIParameter.create(FIti, AMethod);
      AMethod.Parameters.AddObject(LPascalName, LParam);
      LParam.Name := LPascalName;
      LParam.ParamFlag := pfConst;
      LParam.NameOfType := LType;
      end;
    end;
end;

function TIdSoapWSDLToPascalConvertor.TypeIsArray(AType: IdSoapWSDL.TQName): boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.TypeIsArray';
var
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AType.TestValid(IdSoapWSDL.TQName), ASSERT_LOCATION+': self is not valid');

  if AType.NameSpace = ID_SOAP_NS_SCHEMA then
    begin
    result := false;
    end
  else
    begin
    i := FDefinedTypes.IndexOf(AType.NameSpace+#1+AType.Name);
    Assert(i <> -1, ASSERT_LOCATION+': Type '+AType.Name+' not declared yet');
    result := (FDefinedTypes.objects[i] as TIdSoapWSDLPascalFragment).FTypeType = idttArray;
    end;
end;

function TIdSoapWSDLToPascalConvertor.ProcessElement(AMethod: TIdSoapITIMethod; AElement: IdSoapWSDL.TQName): string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessType';
var
  i : integer;
  LType : TIdSoapWsdlElementDefn;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': self is not valid');
  Assert(AElement.TestValid(TQName), ASSERT_LOCATION+': self is not valid');

  i := FWsdl.SchemaSection[AElement.NameSpace].Elements.IndexOf(AElement.Name);
  Assert(i <> -1, ASSERT_LOCATION+': Element '+AElement.Name+' in "'+AElement.NameSpace+'" not declared in the WSDL');
  LType := FWsdl.SchemaSection[AElement.NameSpace].Elements.Objects[i] as TIdSoapWsdlElementDefn;
  if LType.TypeInfo.Name <> '' then
    begin
    result := ProcessType(AMethod, LType.TypeInfo);
    end
  else
    begin
    result := 'not done yet'
    end;
end;

function TIdSoapWSDLToPascalConvertor.GetEnumName(AEnumType, AEnumValue : string):String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.GetEnumName';
var
  LModified : boolean;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(isXmlName(AEnumType), 'Enum Type "'+AEnumType+'" not valid');
  Assert(isXmlName(AEnumValue), 'Enum Value "'+AEnumValue+'" not valid');


  result := AEnumValue;
  LModified := false;
  while (FUsedPascalIDs.IndexOf(result) > -1) or (FReservedPascalNames.Indexof(result) > -1) do
    begin
    if LModified then
      begin
      if result[Length(result)] = '_' then
        begin
        result := result + '1';
        end
      else
        begin
        if result[Length(result)] = '9' then
          begin
          result[Length(result)] := 'A';
          end
        else
          begin
          Assert(result[Length(result)] < 'Z', ASSERT_LOCATION+': Ran out of space generating an alternate representation for the name "'+AEnumType+'.'+AEnumValue+'"');
          result[Length(result)] := Chr(ord(result[Length(result)])+1);
          end;
        end;
      end
    else
      begin
      result := result + '_';
      LModified := true;
      end;
    end;
  FUsedPascalIDs.Add(result);
  if LModified then
    begin
    FNameAndTypeComments.Add('Enum: '+AEnumType+'.'+result+' = '+AEnumValue);
    end;
end;

function TIdSoapWSDLToPascalConvertor.ProcessType(AMethod : TIdSoapITIMethod; AType: IdSoapWSDL.TQName):string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessType';
var
  i : integer;
  LType : TIdSoapWSDLAbstractType;
  LTypeCode : TIdSoapWSDLPascalFragment;
  LTypeComment : string;
  LImpl : string;
  LReg : string;
  LAncestor : string;
  LPascalName : string;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AType.TestValid(IdSoapWSDL.TQName), ASSERT_LOCATION+': self is not valid');

  if (AType.NameSpace = ID_SOAP_NS_SCHEMA) or (AType.NameSpace = ID_SOAP_NS_SOAPENC) then
    begin
    // if it's a type in the schema namespace, then we should be able to map it directly
    // we also make this rule for the SOAP encoding namespace, since the bulk of
    // types in that namespace are simply extensions of schema types with id and href
    // added, and we don't care about that.
    // this does mean that we will serialise using XSD instead of the soap namespace.
    // if this is a problem, then we will deal with it then
    result := GetTypeForSchemaType(AType.Name)^.Name;
    if (result = 'TIdSoapDateTime') or (result = 'TIdSoapDate') or (result = 'TIdSoapTime') then
      begin
      FUseIdSoapDateTime := true;
      end;
    if result = 'TStream' then
      begin
      FUseClasses := true;
      end;
    end
  else
    begin
    i := FWsdl.SchemaSection[AType.NameSpace].Types.IndexOf(AType.Name);
    Assert(i <> -1, ASSERT_LOCATION+': Type '+AType.Name+' in "'+AType.NameSpace+'" not declared in the WSDL');
    LType := FWsdl.SchemaSection[AType.NameSpace].Types.Objects[i] as TIdSoapWSDLAbstractType;
    if FDefinedTypes.IndexOf(AType.Namespace+#1+AType.Name) > -1 then
      begin
      LTypeCode := FDefinedTypes.objects[FDefinedTypes.IndexOf(AType.Namespace+#1+AType.Name)] as TIdSoapWSDLPascalFragment;
      result := LTypeCode.FPascalName;
      end
    else
      begin
      LPascalName := ChoosePascalNameForType(AType.Name);
      if (LPascalName <> AType.Name) or (AType.Namespace <> FWsdl.Namespace) then
        begin
        LTypeComment := 'Type: '+ LPascalName+' = ';
        if (LPascalName <> AType.Name) then
          begin
          LTypeComment := LTypeComment + AType.Name+' ';
          end;
        if (AType.Namespace <> FWsdl.Namespace) then
          begin
          LTypeComment := LTypeComment + 'in '+ AType.Namespace;
          end;
        FNameAndTypeComments.Add(LTypeComment);
        end;
      result := LPascalName;
      LTypeCode := TIdSoapWSDLPascalFragment.create;
      LTypeCode.FIncludeInPascal := FExemptTypes.IndexOf('{'+AType.Namespace+'}'+AType.Name) = -1;
      FDefinedTypes.AddObject(AType.Namespace+#1+AType.Name, LTypeCode);
      LTypeCode.FPascalName := LPascalName;
      if LType is TIdSoapWsdlSimpleType then
        begin
        LTypeCode.FTypeType := idttSimple;
        LTypeCode.FReg := '  IdSoapRegisterType(TypeInfo('+Result+'));'+EOL_WINDOWS;
        LTypeCode.FCode := '  '+result+' = '+GetTypeForSchemaType((LType as TIdSoapWsdlSimpleType).Info.Name)^.Name+';'+EOL_WINDOWS;
        end
      else if LType is TIdSoapWsdlSetType then
        begin
        LTypeCode.FTypeType := idttSet;
        LTypeCode.FReg := '  IdSoapRegisterType(TypeInfo('+Result+'));'+EOL_WINDOWS;
        LTypeCode.FCode := '  '+result+' = Set of ' + ProcessType(AMethod, (LType as TIdSoapWsdlSetType).Enum)+';'+EOL_WINDOWS;
        end
      else if LType is TIdSoapWsdlEnumeratedType then
        begin
        Assert((LType as TIdSoapWsdlEnumeratedType).Values.count > 0, ASSERT_LOCATION+': unexpected condition, no values in enumerated type');
        LTypeCode.FTypeType := idttSimple;
        LTypeCode.FReg := '  IdSoapRegisterType(TypeInfo('+Result+'));'+EOL_WINDOWS;
        LTypeCode.FCode := '  '+result+' = (' +GetEnumName(result, (LType as TIdSoapWsdlEnumeratedType).Values[0]);
        for i := 1 to (LType as TIdSoapWsdlEnumeratedType).Values.count - 1 do
          begin
          LTypeCode.FCode := LTypeCode.FCode + ', '+GetEnumName(result, (LType as TIdSoapWsdlEnumeratedType).Values[i]);
          end;
        LTypeCode.FCode := LTypeCode.FCode + ');'+EOL_WINDOWS;
        end
      else if LType is TIdSoapWsdlArrayType then
        begin
        LTypeCode.FTypeType := idttArray;
        LTypeCode.FReg := '  IdSoapRegisterType(TypeInfo('+result+'), '''', TypeInfo('+ProcessType(AMethod, (LType as TIdSoapWsdlArrayType).TypeName)+'));'+EOL_WINDOWS;
        LTypeCode.FCode := '  '+result+' = array of '+ ProcessType(AMethod, (LType as TIdSoapWsdlArrayType).TypeName)+';'+EOL_WINDOWS;
        end
      else if LType is TIdSoapWsdlComplexType then
        begin
        LTypeCode.FTypeType := idttClass;
        LTypeCode.FDecl := '  '+result+' = class;'+EOL_WINDOWS;
        LTypeCode.FCode := WriteComplexType(AMethod, AType, result, LType as TIdSoapWsdlComplexType, LAncestor, LImpl, LReg);
        LTypeCode.FAncestor := LAncestor;
        LTypeCode.FImpl := LImpl;
        LTypeCode.FReg := LReg
        end
      else
        begin
        Assert(false, ASSERT_LOCATION+': Unknown WSDL type class '+LType.ClassName);
        end;
      end;
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.WriteITI;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.WriteITI';
var
  i, j : integer;
  LIntf : TIdSoapITIInterface;
  LSoapAction : string;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');

  LSoapAction := '';
  for i := 0 to FITI.Interfaces.count - 1 do
    begin
    LIntf := FITI.Interfaces.objects[i] as TIdSoapITIInterface;
    writeln('type');
    writeln('  {Soap Address for this Interface: '+LIntf.SoapAddress+'}');
    writeln('  '+LIntf.Name+' = Interface (IIdSoapInterface) ['''+GUIDToString(LIntf.GUID)+''']');
    Write('       {!Namespace: '+LIntf.Namespace);
    if (LIntf.Methods.count > 0) and ((LIntf.Methods.objects[0] as TIdSoapITIMethod).SoapAction <> '') then
      begin
      LSoapAction := (LIntf.Methods.objects[0] as TIdSoapITIMethod).SoapAction;
      Writeln(';');
      Write('         SoapAction: '+LSoapAction);
      end;
    if AllMethodsAreDocument(LIntf) then
      begin
      Writeln(';');
      Write('         Encoding: Document');
      FDefaultEncoding := semDocument;
      end
    else
      begin
      FDefaultEncoding := semRPC;
      end;
    Writeln('}');
    if LIntf.Documentation <> '' then
      begin
      Writeln('      {&'+LIntf.Documentation+'}');
      end;
    for j := 0 to LIntf.Methods.count - 1 do
      begin
      WriteMethod(LIntf.Methods.objects[j] as TIdSoapITIMethod, LSoapAction);
      end;
    writeln('  end;');
    writeln('');

    if FAddFactory  then
      begin
      if (LIntf.SoapAddress = MULTIPLE_ADDRESSES) or not (AnsiSameText('http', copy(LIntf.SoapAddress, 1, 4))) then
        begin
        Writeln('function Get'+LIntf.Name+'(AClient : TIdSoapBaseSender) : '+LIntf.Name+';');
        Writeln('');
        FFactoryText := FFactoryText +
          'function Get'+LIntf.Name+'(AClient : TIdSoapBaseSender) : '+LIntf.Name+';'+EOL_WINDOWS+
          'begin'+EOL_WINDOWS+
          '  result := IdSoapD4Interface(AClient) as '+LIntf.Name+';'+EOL_WINDOWS+
          'end;'+EOL_WINDOWS+
          ''+EOL_WINDOWS;
        end
      else
        begin
        Writeln('function Get'+LIntf.Name+'(AClient : TIdSoapBaseSender; ASetUrl : Boolean = true) : '+LIntf.Name+';');
        Writeln('');
        FFactoryText := FFactoryText +
          'function Get'+LIntf.Name+'(AClient : TIdSoapBaseSender; ASetUrl : Boolean = true) : '+LIntf.Name+';'+EOL_WINDOWS+
          'begin'+EOL_WINDOWS+
          '  if ASetURL and (AClient is TIdSoapWebClient) then'+EOL_WINDOWS+
          '    begin'+EOL_WINDOWS+
          '    (AClient as TIdSoapWebClient).SoapURL := '''+LIntf.SoapAddress+''';'+EOL_WINDOWS+
          '    end;'+EOL_WINDOWS+
          '  result := IdSoapD4Interface(AClient) as '+LIntf.Name+';'+EOL_WINDOWS+
          'end;'+EOL_WINDOWS+
          ''+EOL_WINDOWS;
        end;
      end;
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.WriteMethod(AMeth: TidSoapITIMethod; ADefSoapAction : string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.WriteMethod';
var
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AMeth.TestValid(TidSoapITIMethod), ASSERT_LOCATION+': self is not valid');

  write('    ');
  if AMeth.ResultType <> '' then
    begin
    Write('function  ');
    end
  else
    begin
    Write('procedure ');
    end;
  Write(AMeth.Name);
  if AMeth.Parameters.count > 0 then
    begin
    write('('+DescribeParam(AMeth.Parameters.Param[0]));
    for i := 1 to AMeth.Parameters.count - 1 do
      begin
      write('; '+DescribeParam(AMeth.Parameters.Param[i]));
      end;
    write(')');
    end;
  if AMeth.ResultType <> '' then
    begin
    write(' : ');
    write(AMeth.ResultType);
    end;
  write(';');
  writeln(' stdcall;');
  if (AMeth.RequestMessageName <> AMeth.Name) or (AMeth.ResponseMessageName <> AMeth.Name+'Response') or
     (AMeth.SoapAction <> ADefSoapAction) or (AMeth.EncodingMode <> FDefaultEncoding) or
     (AMeth.Headers.Count > 0) or (AMeth.RespHeaders.Count > 0) then
    begin
    write('      {!');
    if (AMeth.RequestMessageName <> AMeth.Name) then
      begin
      write('Request: '+AMeth.RequestMessageName+'; ');
      end;
    if (AMeth.ResponseMessageName <> AMeth.Name+'Response') then
      begin
      write('Response: '+AMeth.ResponseMessageName+'; ');
      end;
    if (AMeth.SoapAction <> ADefSoapAction) then
      begin
      write('SoapAction: '+AMeth.SoapAction+'; ');
      end;
    if AMeth.EncodingMode <> FDefaultEncoding then
      begin
      write('Encoding: '+copy(IdEnumToString(TypeInfo(TIdSoapEncodingMode), ord(AMeth.EncodingMode)), 4, $FF)+'; ');
      end;
    for i := 0 to AMeth.Headers.Count - 1 do
      begin
      write('Header: '+ AMeth.Headers.Param[i].Name+' = '+ AMeth.Headers.Param[i].NameOfType +'; ');
      end;
    for i := 0 to AMeth.RespHeaders.Count - 1 do
      begin
      write('RespHeader: '+ AMeth.RespHeaders.Param[i].Name+' = '+ AMeth.RespHeaders.Param[i].NameOfType +'; ');
      end;
    writeln('}');
    end;
  if AMeth.Documentation <> '' then
    begin
    Writeln('      {&'+AMeth.Documentation+'}');
    end;
end;

function TIdSoapWSDLToPascalConvertor.DescribeParam(AParam: TIdSoapITIParameter): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.DescribeParam';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': self is not valid');

  result := AParam.Name +' : '+AParam.NameOfType;
  if AParam.ParamFlag = pfVar then
    begin
    result := 'var '+result;
    end
  else if AParam.ParamFlag = pfOut then
    begin
    result := 'out '+result;
    end;
end;

function TIdSoapWSDLToPascalConvertor.CreateArrayType(AMethod : TIdSoapITIMethod; ABaseType: IdSoapWSDL.TQName) : string;
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.CreateArrayType';
var
  LTypeCode : TIdSoapWSDLPascalFragment;
  AName : String;
  LTypeName : string;
  LTypeComment : string;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': self is not valid');
  Assert(ABaseType.TestValid(IdSoapWSDL.TQName), ASSERT_LOCATION+': self is not valid');

  if AnsiSameText(ABaseType.Name, 'String') then
    begin
    result := 'TStringArray';
    end
  else if AnsiSameText(ABaseType.Name, 'Integer') then
    begin
    result := 'TIntegerArray';
    end
  else
    begin
    AName := ABaseType.Name + 'Array';
    if FDefinedTypes.IndexOf(ABaseType.Namespace+#1+AName) > -1 then
      begin
      LTypeCode := FDefinedTypes.objects[FDefinedTypes.IndexOf(ABaseType.Namespace+#1+AName)] as TIdSoapWSDLPascalFragment;
      result := LTypeCode.FPascalName;
      end
    else
      begin
      LTypeName := ProcessType(AMethod, ABaseType);
      LTypeCode := TIdSoapWSDLPascalFragment.create;
      LTypeCode.FPascalName := ChoosePascalNameForType(AName);
      if (LTypeCode.FPascalName <> AName) or (ABaseType.Namespace <> FWsdl.Namespace) then
        begin
        LTypeComment := 'Type: '+ LTypeCode.FPascalName+' = ';
        if (LTypeCode.FPascalName <> AName) then
          begin
          LTypeComment := LTypeComment + AName+' ';
          end;
        if (ABaseType.Namespace <> FWsdl.Namespace) then
          begin
          LTypeComment := LTypeComment + 'in '+ ABaseType.Namespace;
          end;
        FNameAndTypeComments.Add(LTypeComment);
        end;
      FDefinedTypes.AddObject(ABaseType.Namespace+#1+AName, LTypeCode);
      result := LTypeCode.FPascalName;
      LTypeCode.FTypeType := idttArray;
      LTypeCode.FReg := '  IdSoapRegisterType(TypeInfo('+result+'), '''', TypeInfo('+LTypeName+'));'+EOL_WINDOWS;
      LTypeCode.FCode := '  '+result+' = array of '+ LTypeName+';'+EOL_WINDOWS;
      end;
    end;
end;

function TIdSoapWSDLToPascalConvertor.WriteComplexType(AMethod : TIdSoapITIMethod; ATypeName : TQName; AClassName : string; AType: TIdSoapWsdlComplexType; out VAncestor, VImpl, VReg : string): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.WriteComplexType';
var
  LPrivate : string;
  LPublic : string;
  LPublished : string;
  LDestroy : string;
  LCreate : String;
  i, j : integer;
  LProp : TIdSoapWsdlSimpleType;
  LName : string;
  LArrayType : string;
  LRef : TIdSoapWsdlElementDefn;
  LInfo : IdSoapWSDL.TQName;
  LMaxOccurs : string;
  LType : string;
  LDescendents : TObjectList;
  LDef : String;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AType.TestValid(TIdSoapWsdlComplexType), ASSERT_LOCATION+': self is not valid');

  LPrivate := '';
  LPublic := '';
  LCreate := '';
  LPublished := '';
  LDestroy := '';
  LInfo := nil;
  LDescendents := TObjectList.create(true);
  try
    ListDescendents(LDescendents, ATypeName);
    if LDescendents.Count > 0 then
      begin
      VReg := '  IdSoapRegisterClass(TypeInfo('+AClassName+'), [';
      VReg := VReg + 'TypeInfo('+ProcessType(AMethod, LDescendents.items[0] as TQName)+')';
      for i := 1 to LDescendents.count -1 do
        begin
        VReg := VReg+ ',TypeInfo('+ProcessType(AMethod, LDescendents.items[i] as TQName)+')';
        end;
      VReg := VReg + '], false);'+EOL_WINDOWS;
      end
    else
      begin
      VReg := '  IdSoapRegisterType(TypeInfo('+AClassName+'));'+EOL_WINDOWS;
      end
  finally
    FreeAndNil(LDescendents);
  end;
  for i := 0 to AType.Elements.count -1 do
    begin
    LDef := '';
    if AType.Elements.Objects[i] is TIdSoapWsdlSimpleType then
      begin
      LProp := AType.Elements.Objects[i] as TIdSoapWsdlSimpleType;
      if LProp.Name = '' then
        begin
        VImpl := '';
        VReg := '';
        result := 'TIdSoapRawXML';
        FComments.add('* Property of type ##any in Class '+AClassName+' coded as TIdSoapRawXML. Consult doco for further information');
        FComments.add('');
        FUsesRawXML := true;
        exit;
        end
      else
        begin
        LName := ChoosePascalName(AClassName, LProp.Name, true);
        LInfo := LProp.Info;
        LMaxOccurs := LProp.MaxOccurs;
        LDef := LProp.DefaultValue;
        end;
      end
    else
      begin
      LRef := AType.Elements.Objects[i] as TIdSoapWsdlElementDefn;
      LMaxOccurs := LRef.MaxOccurs;
      j := FWsdl.SchemaSection[LRef.TypeInfo.NameSpace].Elements.IndexOf(LRef.TypeInfo.Name);
      Assert(j <> -1, ASSERT_LOCATION+': Element {'+LRef.TypeInfo.NameSpace+'}'+LRef.TypeInfo.Name+' not declared in the WSDL ['+FWsdl.SchemaSection[LRef.TypeInfo.NameSpace].Types.CommaText+']');
      LRef := FWsdl.SchemaSection[LRef.TypeInfo.NameSpace].Elements.Objects[j] as TIdSoapWsdlElementDefn;
      // this type can (and usually will be) a complex
      LName := ChoosePascalName(AClassName, LRef.Name, true);
      LInfo := LRef.TypeInfo;
      end;
    if LMaxOccurs = 'unbounded' then
      begin
      if AMethod.EncodingMode <> semDocument then
        begin
        FComments.Add('* Type "'+LName+'" contains array elements that must be encoded in-line. You must set the ');
        FComments.Add('  Encoding Option seoArraysInLine for any SOAP components that use or express this interface');
        FComments.Add('');
        end;
      LArrayType := CreateArrayType(AMethod, LInfo);
      LPrivate := LPrivate + '    F'+LName+' : '+LArrayType+';'+EOL_WINDOWS;
      LPublic := LPublic +   '    property '+LName+' : '+LArrayType+' read F'+LName+' write F'+LName+';'+EOL_WINDOWS;
      LDestroy := LDestroy + '  IdSoapFreeAndNilArray(pointer(F'+LName+'), TypeInfo('+LArrayType+'));'+EOL_WINDOWS;
      VReg := VReg +
        '  IdSoapRegisterProperty('''+AClassName+''', '''+LName+''','+EOL_WINDOWS+
        '                   IdSoapFieldProp(@'+AClassName+'(nil).F'+LName+'),'+EOL_WINDOWS+
        '                   IdSoapFieldProp(@'+AClassName+'(nil).F'+LName+'),'+EOL_WINDOWS+
        '                   TypeInfo('+LArrayType+'));'+EOL_WINDOWS;
      end
    else
      begin
      Assert((LMaxOccurs = '') or (LMaxOccurs = '1'), ASSERT_LOCATION+': unacceptable value for MaxOccurs: "'+LMaxOccurs+'"');
      LPrivate := LPrivate + '    F'+LName+' : '+ProcessType(AMethod, LInfo)+';'+EOL_WINDOWS;
      if TypeIsArray(LInfo) then
        begin
        LArrayType := ProcessType(AMethod, LInfo);
        LPublic := LPublic + '    property '+LName+' : '+LArrayType+' read F'+LName+' write F'+LName+';'+EOL_WINDOWS;
        LDestroy := LDestroy + '  IdSoapFreeAndNilArray(pointer(F'+LName+'), TypeInfo('+LArrayType+'));'+EOL_WINDOWS;
        VReg := VReg +
          '  IdSoapRegisterProperty('''+AClassName+''', '''+LName+''','+EOL_WINDOWS+
          '                   IdSoapFieldProp(@'+AClassName+'(nil).F'+LName+'),'+EOL_WINDOWS+
          '                   IdSoapFieldProp(@'+AClassName+'(nil).F'+LName+'),'+EOL_WINDOWS+
          '                   TypeInfo('+ProcessType(AMethod, LInfo)+'));'+EOL_WINDOWS;
        end
      else
        begin
        LType := ProcessType(AMethod, LInfo);
        LPublished := LPublished + '    property '+LName+' : '+LType+' read F'+LName+' write F'+LName;
        if LDef <> '' then
          begin
          if AnsiSameText(LType, 'String') or AnsiSameText(LType, 'Char') then
            begin
            LCreate := LCreate + '  F'+LName+' := '''+LDef+''';'+EOL_WINDOWS;
            end
          else
            begin
            LCreate := LCreate + '  F'+LName+' := '+LDef+';'+EOL_WINDOWS;
            if not AnsiSameText(LType, 'Double') then
              begin
              LPublished := LPublished + ' default '+LDef;
              end;
            end;
          end;
        LPublished := LPublished+';'+EOL_WINDOWS;
        if LType = 'TIdSoapRawXML' then
          begin
          FUsesRawXML := true;
          end;
        end;
      end;
    end;
  if AType.ExtensionBase.Name <> '' then
    begin
    VAncestor := ProcessType(AMethod, AType.ExtensionBase);
    result := '  '+AClassName+' = class ('+VAncestor+')';
    end
  else
    begin
    result :=
      '  '+AClassName+' = class (TIdBaseSoapableClass)';
    end;
  if (LPrivate = '') and (LPublic = '') and (LPublished = '') then
    begin
    result := result + ';'+EOL_WINDOWS;
    end
  else
    begin
    result := result +EOL_WINDOWS;
    end;
  if LPrivate <> '' then
    begin
    result := result +
      '  Private'+EOL_WINDOWS+
      LPrivate;
    end;
  if (LPublic <> '') or (LDestroy <> '') or (LCreate <> '') then
    begin
    result := result +
      '  Public'+EOL_WINDOWS;
    if LCreate <> '' then
      result := result +
        '    Constructor Create; override;'+EOL_WINDOWS;
    if LDestroy <> '' then
      result := result +
        '    Destructor Destroy; override;'+EOL_WINDOWS;
    if LPublic <> '' then
      result := result +
        LPublic;
    end;
  if LPublished <> '' then
    begin
    result := result +
      '  Published'+EOL_WINDOWS+
      LPublished;
    end;
  if (LPrivate <> '') or (LPublic <> '') or (LPublished <> '') then
    begin
    result := result + '  end;'+EOL_WINDOWS;
    end;
  VImpl := '';
  if (LDestroy <> '') or (LCreate <> '') then
    begin
    VImpl := VImpl +
      '{ '+AClassName+' }'+EOL_WINDOWS+
      EOL_WINDOWS;
    end;
  if LCreate <> '' then
    begin
    VImpl := VImpl +
      'constructor '+AClassName+'.create;'+EOL_WINDOWS+
      'begin'+EOL_WINDOWS+
      '  inherited;'+EOL_WINDOWS+
      LCreate+
      'end;'+EOL_WINDOWS+EOL_WINDOWS;
    end;
  if LDestroy <> '' then
    begin
    VImpl := VImpl +
      'destructor '+AClassName+'.destroy;'+EOL_WINDOWS+
      'begin'+EOL_WINDOWS+
      LDestroy+
      '  inherited;'+EOL_WINDOWS+
      'end;'+EOL_WINDOWS+EOL_WINDOWS;
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.ProcessPorts;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ProcessPorts';
var
  i, j : integer;
  LEntry  : TPortTypeEntry;
  LNamespace : string;
  s : string;
  LInterface : TIdSoapITIInterface;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FIti.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');
  Assert(FWsdl.TestValid(TIdSoapWsdl), ASSERT_LOCATION+': self is not valid');

  LNamespace := '';
  for i := 0 to FValidPortTypes.count - 1 do
    begin
    LEntry := FValidPortTypes.objects[i] as TPortTypeEntry;
    LInterface := GetInterfaceForEntry(LEntry);
    for j := 0 to LEntry.FPort.Operations.count -1 do
      begin
      if LNamespace = '' then
        begin
        LNamespace := GetOpNamespace(LEntry.FPort.Operations.Objects[j] as TIdSoapWSDLPortTypeOperation, LEntry.FBind);
        if LNamespace = '' then
          begin
          LNamespace := FWsdl.Namespace;
          end
        end
      else
        begin
        s := GetOpNamespace(LEntry.FPort.Operations.Objects[j] as TIdSoapWSDLPortTypeOperation, LEntry.FBind);
        Assert((s = '') or (s = LNamespace), ASSERT_LOCATION+': IndySoap cannot deal with interfaces that cover more than a single namespace. Please refer your WSDL to indy-soap-public@yahoogroups.com for consideration');
        // if this is a problem, we could back the scope of this check back to a single interface
        end;
      end;
    LInterface.Namespace := LNamespace;
    end;

  for i := 0 to FValidPortTypes.count - 1 do
    begin
    LEntry := FValidPortTypes.objects[i] as TPortTypeEntry;
    LInterface := GetInterfaceForEntry(LEntry);
    for j := 0 to LEntry.FPort.Operations.count -1 do
      begin
      ProcessOperation(LInterface, LEntry.FPort.Operations.Objects[j] as TIdSoapWSDLPortTypeOperation, LEntry.FBind);
      end;
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.WriteHeader;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.WriteHeader';
var
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FIti.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');

  writeln('Unit '+FUnitName+';');
  writeln('');
  writeln('{---------------------------------------------------------------------------');
  writeln('This file generated by the IndySoap WSDL -> Pascal translator');
  writeln('');
  writeln('Source:   '+FWSDLSource);
  writeln('Date:     '+FormatDateTime('c', now));
  writeln('IndySoap: V'+ID_SOAP_VERSION);
  if FComments.count > 0 then
    begin
    writeln('Notes:');
    for i := 0 to FComments.count -1 do
      begin
      writeln('   '+FComments[i]);
      end;
    end;
  writeln('---------------------------------------------------------------------------}');
  writeln('');
  writeln('Interface');
  writeln('');
  writeln('Uses');

  if FUseClasses then
    begin
    FUsesClause.Add('Classes');
    end;
  if FUsesRawXML then
    begin
    FUsesClause.Add('IdSoapRawXML');
    end;
  if FAddFactory then
    begin
    FUsesClause.Add('IdSoapClient');
    end;
  if FUseIdSoapDateTime then
    begin
    FUsesClause.Add('IdSoapDateTime');
    end;
  FUsesClause.Add('IdSoapTypeRegistry');
  FUsesClause.Sort;
  for i := 0 to FUsesClause.count - 2 do
    begin
    Writeln('  '+FUsesClause[i]+',');
    end;
  Writeln('  '+FUsesClause[FUsesClause.count -1]+';');
  writeln('');
  writeln('Type');
end;

function TypeCompare(AList: TStringList; AIndex1, AIndex2: Integer): Integer;
var
  LFrag1 : TIdSoapWSDLPascalFragment;
  LFrag2 : TIdSoapWSDLPascalFragment;
begin
  LFrag1 := AList.Objects[AIndex1] as TIdSoapWSDLPascalFragment;
  LFrag2 := AList.Objects[AIndex2] as TIdSoapWSDLPascalFragment;
  result := CompareText(LFrag2.FAncestor, LFrag1.FAncestor);
  if result = 0 then
    begin
    result := CompareText(LFrag2.FPascalName, LFrag1.FPascalName);
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.WriteTypes;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.WriteTypes';
var
  i : integer;
  LFlag : boolean;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FIti.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');

  {$IFDEF VCL5ORABOVE}
  // no sorting if D4 - user will have to sort this out themselves
  FDefinedTypes.CustomSort(TypeCompare);
  {$ENDIF}

  LFlag := false;
  for i := FDefinedTypes.count - 1 downto 0 do
    begin
    LFlag := true;
    if ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FIncludeInPascal) and ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FTypeType = idttSimple) then
      begin
      Write((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FCode);
      end;
    end;
  if LFlag then
    begin
    WriteLn('');
    LFlag := false;
    end;
  for i := FDefinedTypes.count - 1 downto 0 do
    begin
    LFlag := true;
    if ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FIncludeInPascal) and ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FTypeType = idttSet) then
      begin
      Write((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FCode);
      end;
    end;
  if LFlag then
    begin
    WriteLn('');
    LFlag := false;
    end;
  for i := FDefinedTypes.count - 1 downto 0 do
    begin
    LFlag := true;
    if ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FIncludeInPascal) and ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FTypeType = idttClass) then
      begin
      Write((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FDecl);
      end;
    end;
  if LFlag then
    begin
    WriteLn('');
    LFlag := false;
    end;
  for i := FDefinedTypes.count - 1 downto 0 do
    begin
    LFlag := true;
    if ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FIncludeInPascal) and ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FTypeType = idttArray) then
      begin
      Write((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FCode);
      end;
    end;
  if LFlag then
    begin
    WriteLn('');
    LFlag := false;
    end;
  for i := FDefinedTypes.count - 1 downto 0 do
    begin
    LFlag := true;
    if ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FIncludeInPascal) and ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FTypeType = idttClass) then
      begin
      Writeln((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FCode);
      end;
    end;
  if LFlag then
    begin
    WriteLn('');
    end;
  WriteLn('{!');
  FNameAndTypeComments.sort;
  for i := 0 to FNameAndTypeComments.count -1 do
    begin
    Writeln('  '+FNameAndTypeComments[i]+';');
    end;
  WriteLn('}');
  WriteLn('');
end;

procedure TIdSoapWSDLToPascalConvertor.WriteImpl;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.WriteTypes';
var
  i : integer;
  LFlag : boolean;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FIti.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');

  LFlag := false;
  for i := FDefinedTypes.count - 1 downto 0 do
    begin
    if ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FIncludeInPascal) and ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FTypeType = idttClass) then
      begin
      if (FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FImpl <> '' then
        begin
        Write((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FImpl);
        end;
      end;
    end;
  Writeln('');
  if FAddFactory then
    begin
    write(FFactoryText);
    end;
  for i := FDefinedTypes.count - 1 downto 0 do
    begin
    if Not LFlag then
      begin
      Writeln('Initialization');
      end;
    LFlag := true;
    if ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FIncludeInPascal) and ((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FReg <> '') then
      begin
      Write((FDefinedTypes.Objects[i] as TIdSoapWSDLPascalFragment).FReg);
      end;
    end;
end;

function TIdSoapWSDLToPascalConvertor.ChoosePascalNameForType(const ASoapName: string): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ChoosePascalNameForType';
var
  LModified : boolean;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(ASoapname <> '', ASSERT_LOCATION+': SoapName is blank');

  result := ASoapName;
  if FPrependTypeNames and ((ASoapName[1] <> 'T') or (length(ASoapName) = 1) or (upcase(ASoapName[2]) <> ASoapName[2])) then
    begin
    result := 'T'+ASoapName;
    end;
  LModified := false;
  while (FUsedPascalIDs.IndexOf(result) > -1) or (FReservedPascalNames.Indexof(result) > -1) do
    begin
    if LModified then
      begin
      if result[Length(result)] = '_' then
        begin
        result := result + '1';
        end
      else
        begin
        if result[Length(result)] = '9' then
          begin
          result[Length(result)] := 'A';
          end
        else
          begin
          Assert(result[Length(result)] < 'Z', ASSERT_LOCATION+': Ran out of space generating an alternate representation for the name "'+ASoapName+'"');
          result[Length(result)] := Chr(ord(result[Length(result)])+1);
          end;
        end;
      end
    else
      begin
      result := result + '_';
      LModified := true;
      end;
    end;
  FUsedPascalIDs.Add(result);
end;

procedure TIdSoapWSDLToPascalConvertor.LoadReservedWordList;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.LoadReservedWordList';
begin
  FReservedPascalNames.sorted := true;
  FReservedPascalNames.Duplicates := dupError;

  // this list taken from D6 help, subject "reserved words"
  FReservedPascalNames.Add('and');
  FReservedPascalNames.Add('array');
  FReservedPascalNames.Add('as');
  FReservedPascalNames.Add('asm');
  FReservedPascalNames.Add('begin');
  FReservedPascalNames.Add('case');
  FReservedPascalNames.Add('class');
  FReservedPascalNames.Add('const');
  FReservedPascalNames.Add('constructor');
  FReservedPascalNames.Add('destructor');
  FReservedPascalNames.Add('dispinterface');
  FReservedPascalNames.Add('div');
  FReservedPascalNames.Add('do');
  FReservedPascalNames.Add('downto');
  FReservedPascalNames.Add('else');
  FReservedPascalNames.Add('end');
  FReservedPascalNames.Add('except');
  FReservedPascalNames.Add('exports');
  FReservedPascalNames.Add('file');
  FReservedPascalNames.Add('finalization');
  FReservedPascalNames.Add('finally');
  FReservedPascalNames.Add('for');
  FReservedPascalNames.Add('function');
  FReservedPascalNames.Add('goto');
  FReservedPascalNames.Add('if');
  FReservedPascalNames.Add('implementation');
  FReservedPascalNames.Add('in');
  FReservedPascalNames.Add('inherited');
  FReservedPascalNames.Add('initialization');
  FReservedPascalNames.Add('inline');
  FReservedPascalNames.Add('interface');
  FReservedPascalNames.Add('is');
  FReservedPascalNames.Add('label');
  FReservedPascalNames.Add('library');
  FReservedPascalNames.Add('mod');
  FReservedPascalNames.Add('nil');
  FReservedPascalNames.Add('not');
  FReservedPascalNames.Add('object');
  FReservedPascalNames.Add('of');
  FReservedPascalNames.Add('or');
  FReservedPascalNames.Add('out');
  FReservedPascalNames.Add('packed');
  FReservedPascalNames.Add('procedure');
  FReservedPascalNames.Add('program');
  FReservedPascalNames.Add('property');
  FReservedPascalNames.Add('raise');
  FReservedPascalNames.Add('record');
  FReservedPascalNames.Add('repeat');
  FReservedPascalNames.Add('resourcestring');
  FReservedPascalNames.Add('set');
  FReservedPascalNames.Add('shl');
  FReservedPascalNames.Add('shr');
  FReservedPascalNames.Add('string');
  FReservedPascalNames.Add('then');
  FReservedPascalNames.Add('threadvar');
  FReservedPascalNames.Add('to');
  FReservedPascalNames.Add('try');
  FReservedPascalNames.Add('type');
  FReservedPascalNames.Add('unit');
  FReservedPascalNames.Add('until');
  FReservedPascalNames.Add('uses');
  FReservedPascalNames.Add('var');
  FReservedPascalNames.Add('while');
  FReservedPascalNames.Add('with');
  FReservedPascalNames.Add('xor');
  FReservedPascalNames.Add('private');
  FReservedPascalNames.Add('protected');
  FReservedPascalNames.Add('public');
  FReservedPascalNames.Add('published');
  FReservedPascalNames.Add('automated');
  FReservedPascalNames.Add('at');
  FReservedPascalNames.Add('on');

  // also added on principle - could be *real* confusing
  FReservedPascalNames.Add('ShortInt');
  FReservedPascalNames.Add('Byte');
  FReservedPascalNames.Add('SmallInt');
  FReservedPascalNames.Add('Word');
  FReservedPascalNames.Add('Integer');
  FReservedPascalNames.Add('Cardinal');
  FReservedPascalNames.Add('Char');
  FReservedPascalNames.Add('Boolean');
  FReservedPascalNames.Add('Single');
  FReservedPascalNames.Add('Double');
  FReservedPascalNames.Add('Extended');
  FReservedPascalNames.Add('Comp');
  FReservedPascalNames.Add('Currency');
  FReservedPascalNames.Add('ShortString');
  FReservedPascalNames.Add('WideChar');
  FReservedPascalNames.Add('WideString');
  FReservedPascalNames.Add('Int64');

end;

function IsValidIdentChar(ACh : char; AIndex : integer):boolean;
begin
  if AIndex = 1 then
    begin
    result := upcase(ACh) in ['_', 'A'..'Z'];
    end
  else
    begin
    result := upcase(ACh) in ['_', 'A'..'Z', '0'..'9'];
    end;
end;


function TIdSoapWSDLToPascalConvertor.ChoosePascalName(const AClassName, ASoapName: string; AAddNameChange : boolean): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ChoosePascalName';
var
  LModified : boolean;
  LDefinition : string;
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(isXMLName(ASoapname), ASSERT_LOCATION+': SoapName is blank');

  result := ASoapName;
  for i := length(result) downto 1 do
    begin
    if not IsValidIdentChar(result[i], i) then
      begin
      delete(result, i, 1);
      end;
    end;
  while (result <> '') and (not IsValidIdentChar(result[1], 1)) do
    begin
    delete(result, 1, 1);
    end;
  if result = '' then
    begin
    result := 'Unnamed';
    end;
  LModified := false;
  while (FReservedPascalNames.Indexof(result) > -1) do
    begin
    if LModified then
      begin
      if result[Length(result)] = '_' then
        begin
        result := result + '1';
        end
      else
        begin
        if result[Length(result)] = '9' then
          begin
          result[Length(result)] := 'A';
          end
        else
          begin
          Assert(result[Length(result)] < 'Z', ASSERT_LOCATION+': Ran out of space generating an alternate representation for the name "'+ASoapName+'"');
          result[Length(result)] := Chr(ord(result[Length(result)])+1);
          end;
        end;
      end
    else
      begin
      result := result + '_';
      LModified := true;
      end;
    end;
  if AAddNameChange and (result <> ASoapname) then
    begin
    if AClassName <> '' then
      begin
      LDefinition := 'Name: '+AClassName+'.'+result+' = '+ASoapName;
      end
    else
      begin
      LDefinition := 'Name: '+result+' = '+ASoapName;
      end;
    if FNameAndTypeComments.indexof(LDefinition) = -1 then
      begin
      FNameAndTypeComments.Add(LDefinition);
      end;
    end;
end;

function TIdSoapWSDLToPascalConvertor.AllMethodsAreDocument(AIntf: TIdSoapITIInterface): boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ChoosePascalName';
var
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AIntf.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': self is not valid');
  result := AIntf.Methods.count > 0;
  for i := 0 to AIntf.Methods.count - 1 do
    begin
    result := result and ((AIntf.Methods.objects[i] as TIdSoapITIMethod).EncodingMode = semDocument);
    end;
end;

procedure TIdSoapWSDLToPascalConvertor.SetExemptTypes(AList: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.SetExemptTypes';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  FExemptTypes.CommaText := AList;
  FExemptTypes.Sort;
end;

procedure TIdSoapWSDLToPascalConvertor.SetUsesClause(AList : string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.SetUsesClause';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  FUsesClause.CommaText := AList;
end;

procedure TIdSoapWSDLToPascalConvertor.ListDescendents(ADescendents: TObjectList; AName: TQName);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.ListDescendents';
var
  i, j: integer;
  LNs : TIdSoapWSDLSchemaSection;
  LType : TIdSoapWSDLAbstractType;
  LMatch : TQName;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(assigned(ADescendents), ASSERT_LOCATION+': Descendents is not valid');
  Assert(AName.TestValid(TQName), ASSERT_LOCATION+': Name is not valid');

  for i := 0 to FWsdl.SchemaSections.count - 1 do
    begin
    LNs := FWsdl.SchemaSections.Objects[i] as TIdSoapWSDLSchemaSection;
    for j := 0 to LNs.Types.count - 1 do
      begin
      LType := LNs.Types.objects[j] as TIdSoapWSDLAbstractType;
      if (LType is TIdSoapWsdlComplexType) and AName.Equals((LType as TIdSoapWsdlComplexType).ExtensionBase) then
        begin
        LMatch := TQName.create;
        LMatch.NameSpace := FWsdl.SchemaSections[i];
        LMatch.Name := LNs.Types[j];
        ADescendents.Add(LMatch);
        end;
      end;
    end;
end;

function TIdSoapWSDLToPascalConvertor.MakeInterfaceForEntry(AEntry: TPortTypeEntry): TIdSoapITIInterface;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.MakeInterfaceForEntry';
var
  LName : string;
  LGUID : TGUID;
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AEntry.TestValid(TPortTypeEntry), ASSERT_LOCATION+': self is not valid');

  result := TIdSoapITIInterface.create(FIti);
  LName := AEntry.FSvc.Name;
  if AnsiSameText(copy(LName, Length(LName)-6, 7), 'service') then
    begin
    delete(LName, Length(LName)-6, 7);
    end;
  if LName[1] <> 'I' then
    begin
    LName := 'I'+LName;
    end;
  result.Name := ChoosePascalName('', LName, false);
  FIti.Interfaces.AddObject(result.Name, result);
  {$IFDEF LINUX}
  CreateGUID(LGUID);
  {$ELSE}
  CoCreateGuid(LGUID);
  {$ENDIF}
  result.GUID := LGUID;
  result.Documentation := AEntry.FSvc.Documentation;
  result.soapAddress := GetServiceSoapAddress(AEntry.FSvc);
end;

function TIdSoapWSDLToPascalConvertor.GetInterfaceForEntry(AEntry: TPortTypeEntry): TIdSoapITIInterface;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.GetInterfaceForEntry';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AEntry.TestValid(TPortTypeEntry), ASSERT_LOCATION+': self is not valid');

  if OnlyOneInterface then
    begin
    if Assigned(FOneInterface) then
      begin
      result := FOneInterface;
      if GetServiceSoapAddress(AEntry.FSvc) <> result.SoapAddress then
        begin
        result.SoapAddress := MULTIPLE_ADDRESSES;
        end;
      end
    else
      begin
      result := MakeInterfaceForEntry(AEntry);
      if OneInterfaceName <> '' then
        begin
        result.Name := OneInterfaceName
        end;
      FOneInterface := result;
      end;
    end
  else
    begin
    if Assigned(AEntry.FSvc.Slot) then
      begin
      result := AEntry.FSvc.Slot as TIdSoapITIInterface;
      end
    else
      begin
      result := MakeInterfaceForEntry(AEntry);
      AEntry.FSvc.Slot := result;
      end;
    end;
end;

function TIdSoapWSDLToPascalConvertor.GetServiceSoapAddress(AService : TIdSoapWSDLService) : String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWSDLToPascalConvertor.GetServiceSoapAddress';
begin
  Assert(self.TestValid(TIdSoapWSDLToPascalConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(AService.TestValid(TIdSoapWSDLService), ASSERT_LOCATION+': self is not valid');

  if AService.Ports.count <> 1 then
    begin
    result := MULTIPLE_ADDRESSES;
    end
  else
    begin
    result := (AService.Ports.objects[0] as TIdSoapWSDLServicePort).SoapAddress;
    end;
end;

end.

