{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15728: IdSoapITI.pas 
{
{   Rev 1.2    20/6/2003 00:03:18  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:02:28  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:33:32  GGrieve
}
{
IndySOAP: ITI - Interface Type Information

Delphi has contained strong RTTI for objects since D1, but interfaces
have not been included until D6. Even then, D6 licensing restricts the
use of Interface RTTI to the enterprise edition only.

Indy SOAP maintains the Interface Type Information Manually. A process
exists to compile native Pascal code into a .iti file. The .iti contains
the information described in this unit and will be loaded sometime during
startup to create a live structure based on TIdSoapITI

ITI **must** be in sync with the code. You will get all sorts of interesting
errors if it is not. IndySoap does not make any attempt to check the
synchronisation currently. (We may do under D6/K2 in the future)

There is a unit that generates the ITI on the fly from the interface
RTTI in Delphi 6/Kylix 2. This does not support interface documentation,
but does solve the synchronisation problem
}

{Version History:
  19-Jun 2003   Grahame Grieve                  Header support, ITI renaming support 
  18-Mar 2003   Grahame Grieve                  Remove IDSOAP_USE_RENAMED_OPENXML
  09-Oct 2002   Andrew Cumming                  Fixed bugs in inherited interfaces
  26-Sep 2002   Grahame Grieve                  Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Grahame Grieve                  Support for duplicate message names from overloaded parameters
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  06-Aug 2002   Grahame Grieve                  Add SoapAddress support for WSDL parsing
  24-Jul 2002   Grahame Grieve                  Change to SOAPAction and Namespace handling
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  29-May 2002   Grahame Grieve                  Added ListServerCalls
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
   9-May 2002   Andrew Cumming                  Mods to allow you to state app/soap or text/xml
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing dependency on ole2 unit
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  04-Apr 2002   Grahame Grieve                  SoapAction and Namespace properties for Interfaces
  03-Apr 2002   Grahame Grieve                  Handle ITI Method Request and Response Names
  26-Mar 2002   Grahame Grieve                  Organise unit names alphabetically
  22-Mar 2002   Grahame Grieve                  WSDL Documentation Support
  14-Mar 2002   Grahame Grieve                  Namespace support
   7-Mar 2002   Grahame Grieve                  Review assertions, remove IsArray support
  03-Mar 2002   Andrew Cumming                  Added tkSet to allowed types as SETs are now implemented
  18-Feb 2002   Andrew Cumming                  Added write access to TypeInfo for TIdSoapITIParameter
  15-Feb 2002   Andrew Cumming                  Fixed for re-arrangement of code in helper unit
  13-Feb 2002   Andrew Cumming                  D4 compatibility
  13-Feb 2002   Andrew Cumming                  Start of dynamic array coding
  13-Feb 2002   Andrew Cumming                  Lost version resurected (initial copy was very old)
}

unit IdSoapITI;

{$I IdSoapDefines.inc}

interface

uses
{$IFDEF DELPHI4OR5}
  ActiveX,
{$ENDIF}
  Classes,
  IdSoapDebug,
  IdSoapUtilities,
  TypInfo;


// At design time, we do not validate that types are
// registered with the RTTI system. Any design time packages or executables
// must set this to true
var
  GDesignTime: Boolean = False;

type
  PIdSoapFakeTypeInfo = ^TIdSoapFakeTypeInfo;
  TIdSoapFakeTypeInfo = packed record
    Kind: TTypeKind;
    Name : String[5];
    ATypeData: TTypeData;
    end;

  TIdSoapCallingConvention = (idccStdCall, idccPascal, idccCdecl, idccRegister, idccSafeCall);
  TIdSoapEncodingMode = (semRPC, semDocument);

  TIdSoapITI = class;
  TIdSoapITIInterface = class;

  // this class and it's properties are public for streaming and DUnit testing, no other use is envisaged
  TIdSoapITINameObject = class (TIdBaseObject)
  private
    FName : string;
    FNamespace : string;
  public
    Property Name : string read FName write FName;
    Property Namespace : string read FNamespace write FNamespace;
  end;

  TIdSoapITIBaseObject = class(TIdBaseObject)
  Private
    FITI: TIdSoapITI;
    FParent : TIdSoapITIBaseObject;
    FDocumentation : string;
    FNames : TStringList;
    FReverseNames : TStringList;
    FEnums : TStringList;
    FReverseEnums : TStringList;
    FTypes : TStringList;
    FReverseTypes : TStringList;
  protected
    function GetITINamespace : string; virtual;
  Public
    constructor Create(AITI: TIdSoapITI; AParent : TIdSoapITIBaseObject);
    destructor destroy; override;
    procedure Validate(APath : String); virtual;
    property ITI: TIdSoapITI Read FITI;
    property Parent : TIdSoapITIBaseObject read FParent;
    property Documentation : String read FDocumentation write FDocumentation;
    procedure DefineEnumReplacement(AEnumType, APascalName, AXMLName : string);
    procedure DefineNameReplacement(AClassName, APascalName, ASoapName : string);
    function ReplaceName(APascalName : string; ADefaultName : string = ''): string;
    function ReplacePropertyName(AClassName, APascalName : string; ADefaultName : string = ''): string;
    function ReverseReplaceName(AClassName, ASoapName: string): string;

    procedure DefineTypeReplacement(APascalName, ASoapName, ASoapNamespace : String);
    procedure ReplaceTypeName(APascalName, AComponentNamespace:String; out VTypeName, VTypeNamespace:string);
    function ReplaceEnumName(AEnumType, APascalName :string) : String;
    function ReverseReplaceEnumName(AEnumType, AXMLName :string) : String;
    function ReverseReplaceType(ATypeName, ATypeNamespace, AComponentNamespace:string):String;

    // these are exposed for the DUnit testing and streaming
    property Names : TStringList read FNames;
    property Types : TStringList read FTypes;
    property Enums : TStringList read FEnums;
  end;

  TIdSoapITIParameter = class(TIdSoapITIBaseObject)
  Private
    FName: String;
    FParamFlag: TParamFlag;
    FNameOfType: String;
    FTypeInfo: pTypeInfo;
  Public
    property Name: String Read FName Write FName;
    property ParamFlag: TParamFlag Read FParamFlag Write FParamFlag;
    property NameOfType: String Read FNameOfType Write FNameOfType;    // cause Borland stole ClassName and ClassType
    property TypeInformation: pTypeInfo Read FTypeInfo write FTypeInfo; // cause Borland stole TypeInfo
    procedure Validate(APath : String); override;
  end;

  TIdSoapITIParamList = class (TIdStringList)
  private
    function GetParam(i: Integer): TIdSoapITIParameter;
    function GetParamByName(AName: String): TIdSoapITIParameter;
  public
    property Param[i : Integer]:TIdSoapITIParameter read GetParam;
    property ParamByName[AName : String]:TIdSoapITIParameter read GetParamByName;
    procedure AddParam(AParam : TIdSoapITIParameter);
    procedure Validate(APath : String);
  end;

  TIdSoapITIMethod = class(TIdSoapITIBaseObject)
  Private
    FName: String;
    FResponseMessageName: string;
    FRequestMessageName: string;
    FInterface : TIdSoapITIInterface;
    FMethodKind: TMethodKind;
    FInheritedMethod: Boolean;       // Method was from an inherited interface
    FCallingConvention: TIdSoapCallingConvention;
    FHeaders : TIdSoapITIParamList;
    FRespHeaders : TIdSoapITIParamList;
    FParameters: TIdSoapITIParamList;
    // about the result, if there is any
    FResultType: String;
    FResultTypeInfo: pTypeInfo;
    FSoapAction: string;
    FEncodingMode: TIdSoapEncodingMode;
    FSessionRequired: boolean;

    function GetRequestMessageName: string;
    function GetResponseMessageName: string;
  Public
    constructor Create(AITI: TIdSoapITI; AIntf : TIdSoapITIInterface);
    destructor Destroy; Override;
    procedure Validate(APath : String); override;

    property Name: String Read FName Write FName;
    property RequestMessageName : string read GetRequestMessageName write FRequestMessageName;
    property ResponseMessageName : string read GetResponseMessageName write FResponseMessageName;
    property InheritedMethod: Boolean read FInheritedMethod write FInheritedMethod;
    property CallingConvention: TIdSoapCallingConvention Read FCallingConvention Write FCallingConvention;
    property Parameters: TIdSoapITIParamList Read FParameters;
    property MethodKind: TMethodKind Read FMethodKind Write FMethodKind;
    property ResultType: String Read FResultType Write FResultType;
    property ResultTypeInfo: PTypeInfo Read FResultTypeInfo;
    property SoapAction : string read FSoapAction write FSoapAction;
    property EncodingMode : TIdSoapEncodingMode read FEncodingMode write FEncodingMode;
    property SessionRequired : boolean read FSessionRequired write FSessionRequired;
    property Headers : TIdSoapITIParamList read FHeaders;
    property RespHeaders : TIdSoapITIParamList read FRespHeaders;
  end;

  TIdSoapITIMethodNameType = (ntPascal, ntMessageRequest, ntMessageResponse);

  TIdSoapITIInterface = class(TIdSoapITIBaseObject)
  Private
    FName: String;
    FUnitName : string;
    FNamespace : string;
    FAncestor: String;        // heritage
    FMethods: TStringList;
    FRequestNames: TStringList;
    FResponseNames: TStringList;
    FGUID: TGUID;
    FSoapAddress: string;
    FIsInherited: Boolean;
  protected
    function GetITINamespace : string; override;
  Public
    constructor Create(AITI: TIdSoapITI);
    destructor Destroy; Override;
    function FindMethodByName(const AMethodName: String; ANameType : TIdSoapITIMethodNameType): TIdSoapITIMethod;
    property Name: String Read FName Write FName;
    procedure AddMethod(AMethod: TIdSoapITIMethod);
    property Methods: TStringList Read FMethods;
    property Ancestor: String Read FAncestor Write FAncestor;
    property IsInherited: Boolean read FIsInherited write FIsInherited;
    property GUID: TGUID Read FGUID Write FGUID;
    property UnitName : string read FUnitName write FUnitName;
    property Namespace : String read FNamespace write FNamespace;
    property SoapAddress : string read FSoapAddress write FSoapAddress; // this is not stored, just used by the WSDL -> pascal wizard
    procedure Validate(APath : String); override;
  end;

  TIdSoapITI = class(TIdSoapITIBaseObject)
  Private
    FInterfaces: TStringList;
    FServerLookup : TStringList;
  protected
    function GetITINamespace : string; override;
  Public
    constructor Create;
    destructor Destroy; Override;

    procedure SetupBaseRenaming;
    procedure Validate(APath : String); override;

    procedure AddInterface(AInterface: TIdSoapITIInterface);
    function FindInterfaceByName(const AName: String): TIdSoapITIInterface;
    function FindInterfaceByGUID(AGUID: TGUID): TIdSoapITIInterface;
    property Interfaces: TStringList Read FInterfaces;

    // this procedure creates the lookup table used by the server in the function call below
    // Namespace is the assigned Server namespace, or the default, if that is empty.
    // this will only be used if there is no namespace in the ITI
    procedure ConstructServerReference(ANamespace : string);

    // This procedure is used on the server to locate the interface and method that
    // correspond to the incoming request
    function FindRequestHandler(ANamespace, AMessageName : string;
         Var VInterface : TIdSoapITIInterface; Var VMethod : TIdSoapITIMethod):boolean;
    // debugging - help a developer figure out namespace issues
    procedure ListServerCalls(AList : TStrings);
  end;

  TIdSoapITIStreamingClass = class(TIdBaseObject)
  Public
    procedure SaveToStream(AITI: TIdSoapITI; AStream: TStream); Virtual; Abstract;
    procedure ReadFromStream(AITI: TIdSoapITI; AStream: TStream); Virtual; Abstract;
  end;

implementation

uses
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapOpenXML,
  IdSoapTypeRegistry,
  SysUtils;

{ TIdSoapITI }

constructor TIdSoapITI.Create;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.Create';
begin
  inherited Create(NIL, nil);
  FInterfaces := TIdStringList.Create(True);
  FInterfaces.Sorted := True;
  Finterfaces.Duplicates := dupError;
  FServerLookup := TStringList.Create;
  FServerLookup.Sorted := True;
  FServerLookup.Duplicates := dupError;
end;

destructor TIdSoapITI.Destroy;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.Destroy';
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FInterfaces);
  FreeAndNil(FServerLookup);
  inherited;
end;

procedure TIdSoapITI.AddInterface(AInterface: TIdSoapITIInterface);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.AddInterface';
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  assert(AInterface.TestValid, ASSERT_LOCATION+': AInterface is not a valid object');
  assert(FInterfaces.IndexOf(AInterface.FName) = -1, ASSERT_LOCATION+': Attempt to define an interface twice ("' + AInterface.Name + '")');
  assert(not assigned(FindInterfaceByGUID(AInterface.FGUID)), ASSERT_LOCATION+': Attempt to define an interface with a duplicate GUID ("' + AInterface.Name + '")');
  FInterfaces.AddObject(AInterface.FName, AInterface);
end;

function TIdSoapITI.FindInterfaceByName(const AName: String): TIdSoapITIInterface;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.FindInterfaceByName';
var
  Index: Integer;
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  // we don't check AName, nor do we insist that a match be found
  if FInterfaces.Find(AName, Index) then
    begin
    Result := FInterfaces.Objects[Index] as TIdSoapITIInterface;
    end
  else
    begin
    Result := NIL;
    end;
end;

function TIdSoapITI.FindInterfaceByGUID(AGUID: TGUID): TIdSoapITIInterface;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.FindInterfaceByGUID';
var
  LIndex: Integer;
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  // we don't check AGUID, nor do we insist that a match be found
  Result := NIL;
  for LIndex := 0 to Interfaces.Count - 1 do
    begin
    if IsEqualGUID(AGUID, (Interfaces.Objects[LIndex] as TIdSoapITIInterface).GUID) then
      begin
      Result := Interfaces.Objects[LIndex] as TIdSoapITIInterface;
      exit;
      end;
    end;
end;

procedure TIdSoapITI.Validate(APath : string);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.Validate';
var
  i: Integer;
begin
  assert(self.TestValid, ASSERT_LOCATION+'['+APath+']: self is not valid');
  Assert(FInterfaces.Count > 0, ASSERT_LOCATION+'['+APath+']: There must be at least one Interface registered in the ITI');
  for i := 0 to FInterfaces.Count - 1 do
    begin
    (FInterfaces.Objects[i] as TIdSoapITIInterface).Validate(APath+'.ITI');
    end;
end;

// this procedure creates the lookup table used by the server in the function call below
procedure TIdSoapITI.ConstructServerReference(ANamespace : string);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.ConstructServerReference';
var
  LCountIntf : integer;
  LIntf : TIdSoapITIInterface;
  LCountMeth : integer;
  LMeth : TIdSoapITIMethod;
  LName : string;
  LNamespace: String;
  LDummy: Integer;
  LProcessInherited: Boolean;
begin
  Assert(self.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');
  Assert(assigned(FServerLookup), ASSERT_LOCATION+': Server Lookup list not valid');
  FServerLookup.clear;
  for LProcessInherited := false to true do
    begin
    for LCountIntf := 0 to FInterfaces.count - 1 do
      begin
      LIntf := FInterfaces.Objects[LCountIntf] as TIdSoapITIInterface;
      if LProcessInherited <> LIntf.IsInherited then
        begin
        continue;
        end;
      for LCountMeth := 0 to LIntf.FMethods.count -1 do
        begin
        LMeth := LIntf.FMethods.Objects[LCountMeth] as TIdSoapITIMethod;
        if LIntf.Namespace = '' then
          begin
          LNamespace := ANamespace;
          end
        else
          begin
          LNamespace := LIntf.Namespace;
          end;
        LName := LNamespace + #1 + LMeth.RequestMessageName;
        if FServerLookup.Find(LName,LDummy) then
          begin
          IdRequire(LMeth.InheritedMethod, ASSERT_LOCATION+': Duplicate Method declaration found but method is not Inherited (Method "'+LMeth.RequestMessageName+'" in the namespace "'+LNamespace+'") interface ' + LMeth.FInterface.Name);
          end
        else
          begin
          FServerLookup.AddObject(LName, LMeth);
          end;
        end;
      end;
    end;

end;

// This procedure is used on the server to locate the interface and method that
// correspond to the incoming request
function TIdSoapITI.FindRequestHandler(ANamespace, AMessageName: string; var VInterface: TIdSoapITIInterface; var VMethod: TIdSoapITIMethod): boolean;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.FindRequestHandler';
var
  LIndex : integer;
begin
  Assert(self.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');
  Assert(ANamespace <> '', ASSERT_LOCATION+': A namespace must be provided');
  Assert(AMessageName <> '', ASSERT_LOCATION+': A MessageName must be provided');
  Assert(assigned(FServerLookup), ASSERT_LOCATION+': Server Lookup list not valid');
  result := FServerLookup.Find(ANamespace+#1+AMessageName, LIndex);
  if result then
    begin
    VMethod := FServerLookup.Objects[LIndex] as TIdSoapITIMethod;
    Vinterface := VMethod.FInterface;
    end;
end;

procedure TIdSoapITI.ListServerCalls(AList: TStrings);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITI.FindRequestHandler';
var
  i : integer;
  LLeft : string;
  LRight : string;
begin
  Assert(self.TestValid(TIdSoapITI), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(AList), ASSERT_LOCATION+': List is not valid');
  Assert(assigned(FServerLookup), ASSERT_LOCATION+': Server Lookup list not valid');
  AList.Add('{Namespace}MessageName');
  for i := 0 to FServerLookup.count - 1 do
    begin
    SplitString(FServerLookup[i], #1, LLeft, LRight);
    AList.Add('{'+LLeft+'}'+LRight);
    end;
end;

function TIdSoapITI.GetITINamespace: string;
begin
  result := '';
end;

procedure TIdSoapITI.SetupBaseRenaming;
begin
  DefineTypeReplacement('TIdSoapString', 'SoapString', '');
  DefineTypeReplacement('TIdSoapInteger', 'SoapInteger', '');
  DefineTypeReplacement('TIdSoapBoolean', 'SoapBoolean', '');
  DefineTypeReplacement('TIdSoapDouble', 'SoapDouble', '');
end;

{ TIdSoapITIInterface }

constructor TIdSoapITIInterface.Create(AITI: TIdSoapITI);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIInterface.Create';
begin
  inherited create(AITI, AITI);
  FMethods := TIdStringList.Create(True);  // cant be sorted as order is VERY important
  FRequestNames := TStringList.create;
  FRequestNames.Sorted := true;
  FRequestNames.Duplicates := dupAccept;
  FResponseNames := TStringList.create;
  FResponseNames.Sorted := true;
  FResponseNames.Duplicates := dupAccept;
end;

destructor TIdSoapITIInterface.Destroy;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIInterface.Destroy';
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FRequestNames);
  FreeAndNil(FResponseNames);
  FreeAndNil(FMethods);
  inherited;
end;

function TIdSoapITIInterface.FindMethodByName(const AMethodName: String; ANameType : TIdSoapITIMethodNameType): TIdSoapITIMethod;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIInterface.FindMethodByName';
var
  i: Integer;
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  assert(AMethodName <> '', ASSERT_LOCATION+': AMethodName is blank');
  Result := NIL;
  case ANameType of
    ntPascal :
      begin
      for i := 0 to Methods.Count - 1 do
        begin
        if AnsiSameText(AMethodName, Methods[i]) then
          begin
          Result := Methods.Objects[i] as TIdSoapITIMethod;
          exit;
          end;
        end;
      end;
    ntMessageRequest :
      begin
      if FRequestNames.Find(AMethodName, i) then
        begin
        result := FRequestNames.Objects[i] as TIdSoapITIMethod;
        end;
      end;
    ntMessageResponse :
      begin
      if FResponseNames.Find(AMethodName, i) then
        begin
        result := FResponseNames.Objects[i] as TIdSoapITIMethod;
        end;
      end;
  else
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown value for NameType ('+inttostr(ord(ANameType))+')');
  end;
end;

procedure TIdSoapITIInterface.AddMethod(AMethod: TIdSoapITIMethod);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIInterface.AddMethod';
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  assert(AMethod.TestValid, ASSERT_LOCATION+': AMethod is not a valid object');
  Assert(AMethod.FName <> '', ASSERT_LOCATION+': Attempt to add an unnamed Method)');
  Assert(FMethods.IndexOf(AMethod.FName) = -1, ASSERT_LOCATION+': Attempt to define a method twice ("' + AMethod.Name + '")');
  Assert(AMethod.RequestMessageName <> '', ASSERT_LOCATION+': Attempt to add a Method with no request name)');
  Assert(AMethod.ResponseMessageName <> '', ASSERT_LOCATION+': Attempt to add a Method with no response name)');
  FMethods.AddObject(AMethod.FName, AMethod);
  AMethod.FInterface := self;
  FRequestNames.AddObject(AMethod.RequestMessageName, AMethod);
  FResponseNames.AddObject(AMethod.ResponseMessageName, AMethod);
end;

procedure TIdSoapITIInterface.Validate;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIInterface.Validate';
var
  i: Integer;
begin
  inherited;
  assert(self.TestValid, ASSERT_LOCATION+'['+APath+']: self is not valid');
  Assert(FName <> '', ASSERT_LOCATION+'['+APath+']: Unnamed Interface in ITI');
  Assert(FUnitName <> '', ASSERT_LOCATION+'['+APath+']: The Interface ' + FName + ' has no Unitname defined');
  Assert(FMethods.Count > 0, ASSERT_LOCATION+'['+APath+']: The Interface ' + FName + ' has no methods defined');
  if not AnsiSameText(FAncestor, ID_SOAP_INTERFACE_BASE_NAME) then
    begin
    Assert(FITI.FInterfaces.IndexOf(FAncestor) <> -1, ASSERT_LOCATION+'['+APath+']: Ancester "' + FAncestor + '" of Interface "' + FName + '" was not found in the ITI');
    end;
  for i := 0 to FMethods.Count - 1 do
    begin
    (FMethods.Objects[i] as TIdSoapITIMethod).Validate(APath+'.'+FName);
    end;
end;

function TIdSoapITIInterface.GetITINamespace: string;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIInterface.GetITINamespace';
begin
  assert(self.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': self is not valid');
  result := FNamespace;
end;

{ TIdSoapITIMethod }

constructor TIdSoapITIMethod.Create(AITI: TIdSoapITI; AIntf : TIdSoapITIInterface);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIMethod.Create';
begin
  inherited create(AIti, AIntf);
  FParameters := TIdSoapITIParamList.Create(True);
  FEncodingMode := semRPC;
  FHeaders := TIdSoapITIParamList.create(true);
  FRespHeaders := TIdSoapITIParamList.create(true);
end;

destructor TIdSoapITIMethod.Destroy;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIMethod.Destroy';
begin
  assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FHeaders);
  FreeAndNil(FRespHeaders);
  FreeAndNil(FParameters);
  inherited;
end;

procedure TIdSoapITIMethod.Validate;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIMethod.Validate';
begin
  inherited;
  assert(self.TestValid, ASSERT_LOCATION+'['+APath+']: self is not valid');
  Assert(FName <> '', ASSERT_LOCATION+'['+APath+']: You must name all methods');
  Assert(FCallingConvention in [idccStdCall], ASSERT_LOCATION+'['+APath+']: IndySOAP only supports Stdcall functions (routine "'+FName+'")');
  // we don't support:
  //  ccPascal, ccCdecl, ccRegister, ccSafeCall


  Assert(FMethodKind in [mkProcedure, mkFunction], ASSERT_LOCATION+'['+APath+']: IndySOAP only supports Procedures and Functions');
  // we don't support:
  // mkConstructor, mkDestructor,  mkClassProcedure, mkClassFunction,  mkSafeProcedure, mkSafeFunction

  if FMethodKind = mkProcedure then
    begin
    Assert(FResultType = '', ASSERT_LOCATION+'['+APath+']: You cannot define a result type for a parameter'); // tkUnknown means not defined in this context
    end
  else
    begin
    Assert(FResultType <> '', ASSERT_LOCATION+'['+APath+']: The function "' + FName + '" needs a result type');

    if not GDesignTime then
      begin
      FResultTypeInfo := IdSoapGetTypeInfo(FResultType);
      end;
    end;

  FParameters.Validate(APath+'.'+FName);
  FHeaders.Validate(APath+'.'+FName+'.Headers');
  FRespHeaders.Validate(APath+'.'+FName+'.RespHeaders');
end;

{ TIdSoapITIBaseObject }

constructor TIdSoapITIBaseObject.Create(AITI: TIdSoapITI; AParent : TIdSoapITIBaseObject);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.Create';
begin
  inherited Create;
  assert((AIti = nil) or AIti.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  assert((AParent = nil) or AParent.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': Parent is not valid');
  FITI := AITI;
  FParent := AParent;
  FNames := TIdStringList.create(true);
  FNames.Sorted := true;
  FNames.Duplicates := dupError;
  FReverseNames := TIdStringList.create(True);
  FReverseNames.Sorted := true;
  FReverseNames.Duplicates := dupError;
  FTypes := TIdStringList.create(true);
  FTypes.Sorted := true;
  FTypes.Duplicates := dupError;
  FReverseTypes := TIdStringList.create(True);
  FReverseTypes.Sorted := true;
  FReverseTypes.Duplicates := dupError;
  FEnums := TIdStringList.create(true);
  FEnums.Sorted := true;
  FEnums.Duplicates := dupError;
  FReverseEnums := TIdStringList.create(True);
  FReverseEnums.Sorted := true;
  FReverseEnums.Duplicates := dupError;
end;

destructor TIdSoapITIBaseObject.destroy;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.destroy';
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FEnums);
  FreeAndNil(FReverseEnums);
  FreeAndNil(FNames);
  FreeAndNil(FReverseNames);
  FreeAndNil(FTypes);
  FreeAndNil(FReverseTypes);
  inherited;
end;

procedure TIdSoapITIBaseObject.DefineNameReplacement(AClassName, APascalName, ASoapName: string);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.DefineNameReplacement';
var
  LName : string;
  LReverseName : string;
  LNameObj : TIdSoapITINameObject;
  LIndex : integer;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  IdRequire(IsValidIdent(APascalName), ASSERT_LOCATION+': Parameter or Field Name "'+APascalName+'" is not a valid pascal identifier');
  IdRequire(isXmlName(ASoapName), ASSERT_LOCATION+': Soap Name is missing');
  if AClassName <> '' then
    begin
    IdRequire(IsValidIdent(AClassName), ASSERT_LOCATION+': Classname "'+AClassName+'" is not a valid pascal identifier');
    LName := AClassName +'.'+APascalName;
    LReverseName := AClassName + '.'+ ASoapName;
    end
  else
    begin
    LName := APascalName;
    LReverseName := ASoapName;
    end;
  IdRequire(not FNames.Find(LName, LIndex), ASSERT_LOCATION+': The Name '+LName+' is already defined');
  IdRequire(not FReverseNames.Find(LReverseName, LIndex), ASSERT_LOCATION+': The Reverse Name '+LName+' is already defined');
  LNameObj := TIdSoapITINameObject.create;
  LNameObj.FName := ASoapName;
  FNames.AddObject(LName, LNameObj);
  LNameObj := TIdSoapITINameObject.create;
  LNameObj.FName := APascalName;
  FReverseNames.AddObject(LReverseName, LNameObj);
end;

procedure TIdSoapITIBaseObject.DefineEnumReplacement(AEnumType, APascalName, AXMLName : string);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.DefineEnumReplacement';
var
  LName : string;
  LReverseName : string;
  LNameObj : TIdSoapITINameObject;
  LIndex : integer;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  IdRequire(IsValidIdent(AEnumType), ASSERT_LOCATION+': Type Name "'+AEnumType+'" is not a valid pascal identifier');
  IdRequire(IsValidIdent(APascalName), ASSERT_LOCATION+': Pascal Name "'+APascalName+'" is not a valid pascal identifier');
  IdRequire(isXmlName(AXMLName), ASSERT_LOCATION+': Soap Name "'+AXMLName+'" is not a valid XML identifier');
  LName := AEnumType +'.'+APascalName;
  LReverseName := AEnumType + '.'+ AXMLName;

  IdRequire(not FNames.Find(LName, LIndex), ASSERT_LOCATION+': The Name '+LName+' is already defined');
  IdRequire(not FReverseNames.Find(LReverseName, LIndex), ASSERT_LOCATION+': The Reverse Name '+LName+' is already defined');
  LNameObj := TIdSoapITINameObject.create;
  LNameObj.FName := AXMLName;
  FEnums.AddObject(LName, LNameObj);
  LNameObj := TIdSoapITINameObject.create;
  LNameObj.FName := APascalName;
  FReverseEnums.AddObject(LReverseName, LNameObj);
end;

function TIdSoapITIBaseObject.ReplacePropertyName(AClassName, APascalName : string; ADefaultName : string = ''): string;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.ReplaceName';
var
  LIndex : integer;
  LName : string;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(IsValidIdent(APascalName), ASSERT_LOCATION+': Parameter or Field Name "'+APascalName+'" is not a valid pascal identifier');
  assert(IsValidIdent(AClassName), ASSERT_LOCATION+': Classname "'+AClassName+'" is not a valid pascal identifier');
  LName := AClassName +'.'+APascalName;
  if FNames.Find(LName, LIndex) then
    begin
    result := (FNames.Objects[LIndex] as TIdSoapITINameObject).FName;
    end
  else
    begin
    if Assigned(FParent) then
      begin
      result := FParent.ReplacePropertyName(AClassName, APascalName, ADefaultName);
      end
    else if ADefaultName <> '' then
      begin
      result := ADefaultName;
      end
    else
      begin
      result := APascalName;
      end;
    end;
end;

function TIdSoapITIBaseObject.ReplaceName(APascalName : string; ADefaultName : string = ''): string;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.ReplaceName';
var
  LIndex : integer;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(IsValidIdent(APascalName), ASSERT_LOCATION+': Parameter or Field Name "'+APascalName+'" is not a valid pascal identifier');
  if FNames.Find(APascalName, LIndex) then
    begin
    result := (FNames.Objects[LIndex] as TIdSoapITINameObject).FName;
    end
  else
    begin
    if Assigned(FParent) then
      begin
      result := FParent.ReplaceName(APascalName, ADefaultName);
      end
    else if ADefaultName <> '' then
      begin
      result := ADefaultName;
      end
    else
      begin
      result := APascalName;
      end;
    end;
end;

function TIdSoapITIBaseObject.ReverseReplaceName(AClassName, ASoapName : string): string;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.ReplaceName';
var
  LIndex : integer;
  LName : string;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(isXmlName(ASoapName), ASSERT_LOCATION+': Parameter or Field Name "'+ASoapName+'" is not a valid XML identifier');
  if AClassName <> '' then
    begin
    assert(IsValidIdent(AClassName), ASSERT_LOCATION+': Classname "'+AClassName+'" is not a valid pascal identifier');
    LName := AClassName +'.'+ASoapName;
    end
  else
    begin
    LName := ASoapName;
    end;
  if FReverseNames.Find(LName, LIndex) then
    begin
    result := (FReverseNames.Objects[LIndex] as TIdSoapITINameObject).FName;
    end
  else
    begin
    if Assigned(FParent) then
      begin
      result := FParent.ReverseReplaceName(AClassName, ASoapName);
      end
    else
      begin
      result := ASoapName;
      end;
    end;
end;

procedure TIdSoapITIBaseObject.DefineTypeReplacement(APascalName, ASoapName, ASoapNamespace: String);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.DefineTypeReplacement';
var
  LNameObj : TIdSoapITINameObject;
  LIndex : integer;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  IdRequire(IsValidIdent(APascalName), ASSERT_LOCATION+': Parameter or Field Name "'+APascalName+'" is not a valid pascal identifier');
  IdRequire((ASoapName <> '') or (ASoapNamespace <> ''), ASSERT_LOCATION+': Both SoapName and SoapNamespace are blank for "'+APascalName+'". At least one must be defined');
  if ASoapName <> '' then
    begin
    IdRequire(isXmlName(ASoapName), ASSERT_LOCATION+': SoapName is not a valid XML identifier');
    end
  else
    begin
    ASoapName := APascalName
    end;
  IdRequire(not FTypes.Find(APascalName, LIndex), ASSERT_LOCATION+': The Name '+APascalName+' is already defined');
  IdRequire(not FReverseTypes.Find(ASoapName + #1 + ASoapNamespace, LIndex), ASSERT_LOCATION+': The Name '+APascalName+' is already defined');
  LNameObj := TIdSoapITINameObject.create;
  LNameObj.FName := ASoapName;
  LNameObj.FNamespace := ASoapNamespace;
  FTypes.AddObject(APascalName, LNameObj);
  LNameObj := TIdSoapITINameObject.create;
  LNameObj.FName := APascalName;
  FReverseTypes.AddObject(ASoapName + #1 + ASoapNamespace, LNameObj);
end;

function TIdSoapITIBaseObject.ReplaceEnumName(AEnumType, APascalName :string) : String;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.ReplaceTypeName';
var
  LName : String;
  LIndex : integer;
  LNameObj : TIdSoapITINameObject;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(IsValidIdent(AEnumType), ASSERT_LOCATION+': Enum Type "'+AEnumType+'" is not a valid pascal identifier');
  assert(IsValidIdent(APascalName), ASSERT_LOCATION+': Enum Value "'+APascalName+'" is not a valid pascal identifier');

  LName := AEnumType+'.'+APascalName;
  if FEnums.Find(LName, LIndex) then
    begin
    LNameObj := FEnums.Objects[LIndex] as TIdSoapITINameObject;
    result := LNameObj.Name;
    end
  else
    begin
    if Assigned(FParent) then
      begin
      Result := FParent.ReplaceEnumName(AEnumType, APascalName);
      end
    else
      begin
      Result := APascalName;
      end;
    end;
end;

function TIdSoapITIBaseObject.ReverseReplaceEnumName(AEnumType, AXMLName :string) : String;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.ReverseReplaceEnumName';
var
  LIndex : integer;
  LName : string;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(IsValidIdent(AEnumType), ASSERT_LOCATION+': Enum Type "'+AEnumType+'" is not a valid pascal identifier');
  assert(isXmlName(AXmlName), ASSERT_LOCATION+': Enum Value "'+AXmlName+'" is not a valid XML identifier');

  LName := AEnumType+'.'+AXmlName;

  if FReverseEnums.Find(LName, LIndex) then
    begin
    result := (FReverseEnums.Objects[LIndex] as TIdSoapITINameObject).FName;
    end
  else if assigned(FParent) then
    begin
    result := FParent.ReverseReplaceEnumName(AEnumType, AXMLName);
    end
  else
    begin
    result := AXMLName;
    end;
end;

procedure TIdSoapITIBaseObject.ReplaceTypeName(APascalName, AComponentNamespace: String; out VTypeName, VTypeNamespace: string);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.ReplaceTypeName';
var
  LIndex : integer;
  LNameObj : TIdSoapITINameObject;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(IsValidIdent(APascalName), ASSERT_LOCATION+': Parameter or Field Name "'+APascalName+'" is not a valid pascal identifier');
  // although it probably doesn't makes sense not to provide a ComponentNamespace, we don't insist that it is provided here
  if FTypes.Find(APascalName, LIndex) then
    begin
    LNameObj := FTypes.Objects[LIndex] as TIdSoapITINameObject;
    VTypeName := LNameObj.FName;
    if LNameObj.FNameSpace = '' then
      begin
      VTypeNamespace := GetITINamespace;
      if VTypeNamespace = '' then
        begin
        VTypeNamespace := AComponentNamespace;
        end;
      end
    else
      begin
      VTypeNamespace := LNameObj.FNamespace;
      end;
    end
  else
    begin
    if Assigned(FParent) then
      begin
      FParent.ReplaceTypeName(APascalName, AComponentNamespace, VTypeName, VTypeNamespace);
      if VTypeNamespace = '' then
        begin
        VTypeNamespace := GetITINamespace;
        if (VTypeNamespace = '') and not (self is TIdSoapITI) then
          begin
          VTypeNamespace := AComponentNamespace;
          end;
        end;
      end
    else
      begin
      VTypeName := APascalName;
      VTypeNamespace := GetITINamespace;
      if (VTypeNamespace = '') and not (self is TIdSoapITI) then
        begin
        VTypeNamespace := AComponentNamespace;
        end;
      end;
    end;
end;

function TIdSoapITIBaseObject.ReverseReplaceType(ATypeName, ATypeNamespace, AComponentNamespace: string): String;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.ReverseReplaceType';
var
  LIndex : integer;
  LNs : string;
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(ATypeName <> '', ASSERT_LOCATION+': TypeName = ''''');
  assert(ATypeNamespace <> '', ASSERT_LOCATION+': TypeNamespace = ''''');
  LNs := GetITINamespace;
  if LNs = '' then
    begin
    LNs := AComponentNamespace;
    end;
  if FReverseTypes.Find(ATypeName + #1 + ATypeNamespace, LIndex) then
    begin
    result := (FReverseTypes.Objects[LIndex] as TIdSoapITINameObject).FName;
    end
  else if (ATypeNamespace = LNs) and FReverseTypes.Find(ATypeName + #1, LIndex) then
    begin
    result := (FReverseTypes.Objects[LIndex] as TIdSoapITINameObject).FName;
    end
  else
    begin
    if assigned(FParent) then
      begin
      result := FParent.ReverseReplaceType(ATypeName, ATypeNamespace, AComponentNamespace);
      end
    else
      begin
      // we're going to insist on A namespace match here. This may not be a good thing - to be reviewed (GDG)
      assert(ATypeNamespace = LNs, ASSERT_LOCATION+': Namespace mismatch. Expected "'+LNs+'", but found "'+ATypeNamespace+'"');
      result := ATypeName;
      end;
    end;
end;

function TIdSoapITIBaseObject.GetITINamespace: string;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.GetITINamespace';
begin
  assert(Self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': self is not valid');
  assert(FParent.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': Parent or "'+ClassName+'" is not valid (and self is not TIdSoapITIInterface?)');
  result := FParent.GetITINamespace;
end;

procedure TIdSoapITIBaseObject.Validate(APath: String);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIBaseObject.Validate';
begin
  assert(self.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+'['+APath+']: self is not valid');
end;

{ TIdSoapITIParameter }

procedure TIdSoapITIParameter.Validate(APath : String);
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIParameter.Validate';
begin
  inherited;
  assert(self.TestValid, ASSERT_LOCATION+'['+APath+']: self is not valid');
  Assert(FName <> '', ASSERT_LOCATION+'['+APath+']: All parameters must be named');

  Assert(FParamFlag in [pfVar, pfConst, pfReference, pfOut], ASSERT_LOCATION+'['+APath+']: Unsupported Parameter Flag for Parameter ' + FName);
  // not supported:
  // pfArray, pfAddress, pfVar

  Assert(FNameOfType <> '', ASSERT_LOCATION+'['+APath+']: Parameter "' + FName + '" needs a type');

  if not GDesignTime then
    begin
    FTypeInfo := IdSoapGetTypeInfo(FNameOfType);
    Assert(FTypeInfo.Kind in [tkInteger, tkChar, tkEnumeration, tkFloat, tkString, tkClass, tkWChar,
      tkLString, tkWString, tkInt64, tkDynArray,tkSet], ASSERT_LOCATION+'['+APath+']: Unsupported Parameter Type '+IdEnumToString(TypeInfo(TTypeKind), ord(FTypeInfo.Kind)));
    // we don't support: tkMethod, tkUnknown, tkSet,tkVariant, tkArray, tkRecord, tkInterface,
    end;
end;

{ TIdSoapITIMethod }

function TIdSoapITIMethod.GetRequestMessageName: string;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIMethod.GetRequestMessageName';
begin
  if FRequestMessageName <> '' then
    begin
    Result := FRequestMessageName;
    end
  else
    begin
    result := Name;
    end;
end;

function TIdSoapITIMethod.GetResponseMessageName: string;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIMethod.GetResponseMessageName';
begin
  if FResponseMessageName <> '' then
    begin
    Result := FResponseMessageName;
    end
  else
    begin
    result := Name + 'Response';
    end;
end;

{ TIdSoapITIParamList }

procedure TIdSoapITIParamList.AddParam(AParam: TIdSoapITIParameter);
begin
  AddObject(AParam.FName, AParam);
end;

function TIdSoapITIParamList.GetParam(i: Integer): TIdSoapITIParameter;
begin
  result := Objects[i] as TIdSoapITIParameter;
end;

function TIdSoapITIParamList.GetParamByName(AName: String): TIdSoapITIParameter;
begin
  result := Objects[IndexOf(AName)] as TIdSoapITIParameter;
end;

procedure TIdSoapITIParamList.Validate;
const ASSERT_LOCATION = 'IdSoapITI.TIdSoapITIMethod.GetResponseMessageName';
var i : integer;
begin
  assert(self.TestValid, ASSERT_LOCATION+'['+APath+']: self is not valid');
  for i := 0 to Count - 1 do
    begin
    (Objects[i] as TIdSoapITIParameter).Validate(APath+'['+inttostr(i)+']');
    end;
end;

end.
