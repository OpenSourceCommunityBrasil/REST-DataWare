{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15780: IdSoapTypeRegistry.pas
{
{   Rev 1.3    20/6/2003 00:04:42  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.2    18/3/2003 11:04:10  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.1    25/2/2003 13:14:24  GGrieve
}
{
{   Rev 1.0    11/2/2003 20:36:56  GGrieve
}
{
IndySOAP: IDSoapTypeRegistry

This Unit maintains a list of types and pointers to type information.
Any type (including classes) used in an SOAP interface must be
registered with this unit, and there is also support for registering
exceptions. See below

***** All Type registration should be done during unit initialization ******

}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Major overhaul of typoe registration for polymorphism
  18-Mar 2003   Grahame Grieve                  define QName
  25-Feb 2003   Grahame Grieve                  Fix exception handling
  29-Oct 2002   Grahame Grieve                  Introduce IdSoapSimpleClass
  04-Oct 2002   Grahame Grieve                  Support for TQName
  17-Sep 2002   Grahame Grieve                  HexBinary support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Jul 2002   Grahame Grieve                  fix random number bug
  24-Jul 2002   Grahame Grieve                  remove Namespacing from this unit - change in policy
  09-Jul 2002   Grahame Grieve                  Register TDateTime
  29-May 2002   Grahame Grieve                  Fix problem registering enumerations in D4/D5 (try to look up registration while registering....)
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing compiler warnings
  12-Apr 2002   Andrew Cumming                  Fixed bug in name space code (uninit var)
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Remove Hints and Warnings
  08-Apr 2002   Grahame Grieve                  Change Server cleanup to manage reference counting across objects
  06-Apr 2002   Andrew Cumming                  Added date/tim classes to default class registration
  05-Apr 2002   Grahame Grieve                  Fix problem with garbage collection
  03-Apr 2002   Grahame Grieve                  reorganise code to avoid circular unit problems
  02-Apr 2002   Grahame Grieve                  remove doco
  31-Mar 2002   Andrew Cumming                  Chaged property traversal to generic routines
  29-Mar 2002   Grahame Grieve                  Garbage collection of TIdBaseSoapableClass
  29-Mar 2002   Grahame Grieve                  TIdBaseSoapableClass.OwnsObjects
  26-Mar 2002   Grahame Grieve                  Add IdSoapTypeRegistered, change parameter order in IdSoapRegisterType
  24-Mar 2002   Andrew Cumming                  Fix to compile again
  22-Mar 2002   Andrew Cumming                  Remove warnings
  19-Mar 2002   Andrew Cumming                  Added extra namespace info for D4/D5 support
  14-Mar 2002   Grahame Grieve                  Namespace support, doco for default params, crlf in strings
  12-Mar 2002   Grahame Grieve                  Binary support (TStream)
   7-Mar 2002   Grahame Grieve                  Review assertions
   3-Feb 2002   Andrew Cumming                  Added support for SETs
  28-Feb 2002   Andrew Cumming                  Made D4 compatible
  28-Feb 2002   Andrew Cumming                  Assorted changes/additions for class support
  25-Feb 2002   Andrew Cumming                  Added RTTI to IdBaseSoapableClass
  22-Feb 2002   Andrew Cumming                  Added D4 support for dynamic arrays
  03-Feb 2002   Andrew Cumming                  Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release
}

unit IdSoapTypeRegistry;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
{$IFNDEF DELPHI4}
  Contnrs,
{$ENDIF}
  IdSoapConsts,
  IdSoapDebug,
  IdSoapUtilities,
  SysUtils,
  TypInfo;

{==============================================================================}
{  Basic Interface Declaration                                                 ]
{==============================================================================}

// all interfaces to be offered to IndySOAP must descend from this Interface
// RTTI Support is applied as a cross check and to enable RTTI -> ITI in D6 etc

{$IFDEF VER140}{$M+}{$ENDIF}
type
  IIdSoapInterface = interface( {$IFDEF DELPHI4OR5} IUnknown {$ELSE} IInterface {$ENDIF})
  end;
{$IFDEF VER140}{$M-}{$ENDIF}

{==============================================================================}
{  Type Registration                                                           ]
{==============================================================================}

type
  PTypeInfoArray = Array of PTypeInfo;

procedure IdSoapRegisterType(ATypeDetails: PTypeInfo; ATypeName : string = ''; ABaseType: PTypeInfo = nil);

// register a class, and register all the classes that can replace it in a SOAP message.
procedure IdSoapRegisterClass(ATypeDetails: PTypeInfo; ASubstitutionList : Array of PTypeInfo; ARegisterSubstitutions : Boolean = true);

function GetTypeForClass(ATypeInfo : PTypeInfo; AInstance : TObject) : PTypeInfo;

function GetClassSubstList(ATypeInfo : PTypeInfo): PTypeInfoArray;

function IdSoapTypeRegistered(const ATypeName: String): boolean;
function IdSoapGetTypeInfo(const ATypeName: String; AExpectedClass : PTypeInfo = nil): PTypeInfo;

{==============================================================================}
{  Base IndySoap Encodable Class                                               ]
{==============================================================================}
type
 // we need RTTI info for this class and it's ancestors
{$M+}
  TIdBaseSoapableClass = class;
{$M-}

  TIdBaseSoapableClassContext = class (TIdBaseObject)
  private
    FFirst : TIdBaseSoapableClass;
    FLast : TIdBaseSoapableClass;
    FOwnedObjectCount : integer;
    FOtherObjects : TObjectList;
    procedure Detach(AObject : TIdBaseSoapableClass);
  public
    constructor create;
    destructor destroy; override;
    procedure Attach(AObject : TIdBaseSoapableClass);
    procedure AttachObj(AObj : TIdBaseObject);
    procedure Cleanup;
    property OwnedObjectCount : integer read FOwnedObjectCount;
    function OwnsObject(AObject : TIdBaseSoapableClass) : boolean;
  end;

  TIdBaseSoapableClassList = array of TIdBaseSoapableClass;

  TIdBaseSoapableClassClass = class of TIdBaseSoapableClass;

  TIdBaseSoapableClass = class (TIdBaseObject)
  private
    FOwnsObjects : boolean;
    FRefCount : integer;
    FRefCountSession : integer;
    FServerLeaveAlive : boolean;
    {for the context:}
    FContext : TIdBaseSoapableClassContext;
    FPrev : TIdBaseSoapableClass;
    FNext : TIdBaseSoapableClass;
    function PrivValidate(ASession : integer; var VOwners : TIdBaseSoapableClassList; var VMsg : string):boolean;
    function PrivValidateProperties(ASession: integer; ATypeInfo : PTypeInfo; var VOwners : TIdBaseSoapableClassList; var VMsg : string):boolean;
    procedure CleanUpProperties(ATypeInfo : PTypeInfo);
  Public
    constructor Create; Virtual;
    destructor destroy; override;
    property OwnsObjects:boolean read FOwnsObjects write FOwnsObjects;
    property ServerLeaveAlive : boolean read FServerLeaveAlive write FServerLeaveAlive;
    function ValidateTree(ASession : integer; Var VMsg : string):boolean;
    procedure DeReference;
  end;

{==============================================================================}
{  Generic Array Support                                                            }
{==============================================================================}

type
  TStringArray = array of String;
  TIntegerArray = array of integer;

function IdArrayToString(const AArray : TIntegerArray) : string; overload;
function IdArrayToString(const AArray : TStringArray) : string; overload;
function IdFindValueInArray(const AArray : TIntegerArray; AVal : integer):boolean; overload;
function IdFindValueInArray(const AArray : TStringArray; AVal : String):boolean; overload;
procedure IdAddToArray(Var VArray : TIntegerArray; AVal : integer); overload;
procedure IdAddToArray(Var VArray : TStringArray; AVal : string); overload;
procedure IdDeleteValueFromArray(Var VArray : TIntegerArray; AVal : integer); overload;
procedure IdDeleteValueFromArray(Var VArray : TStringArray; AVal : string); overload;
procedure IdDeleteFromArray(Var VArray : TIntegerArray; AIndex : integer); overload;
procedure IdDeleteFromArray(Var VArray : TStringArray; AIndex : integer); overload;

{==============================================================================}
{  Soapable classes                                                            }
{==============================================================================}

type
  THexStream = class (TIdMemoryStream);

  { TIdSoapSimpleClass is the root for a series of classes that represent
    simple XML types as a pascal class. There is 3 reasons for doing this:

    * where the simple XML type cannot be represented as a simple pascal
      type (QName, dates, etc)

    * to be able to convey the concept of the parameter
      being "nil" or not present in the message (parameter will be nil)

    * to support polymorphism (i.e. "any") in the XML

    unlike simple parameters, these are classes, so you must free
    them manually or have garbage collection on
  }
  TIdSoapSimpleClass = class (TIdBaseSoapableClass)
  public
    class function GetNamespace : string; virtual;
    class function GetTypeName : string; virtual; abstract;
    function WriteToXML : string; virtual; abstract;
    procedure SetAsXML(AValue, ANamespace, ATypeName : string); virtual; abstract;
  end;

  TIdSoapSimpleClassType = class of TIdSoapSimpleClass;

  // this type will have the namespace integrated with the XML namespace system
  // and the stated WSDL type will be QName
  TIdSoapQName = class(TIdBaseSoapableClass)
  Private
    FValue: String;
    FNamespace: String;
  Published
    property Namespace: String Read FNamespace Write FNamespace;
    property Value: String Read FValue Write FValue;
  end;

procedure IdSoapRegisterSimpleClass(AClass : TIdSoapSimpleClassType);
function IdSoapGetSimpleClass(AClassName : string ) : TIdSoapSimpleClassType;

{ predefined simple classes. These exist for 2 reasons:
* Allow the concept of nil to be represented
* allow for XML polymorphism where type is unknown
}

type
  TIdSoapBoolean = class (TIdSoapSimpleClass)
  private
    FValue : boolean;
  public
    class function GetTypeName : string; override;
    function WriteToXML : string; override;
    procedure SetAsXML(AValue, ANamespace, ATypeName : string); override;
  published
    property Value : boolean read FValue write FValue;
  end;

  TIdSoapDouble = class (TIdSoapSimpleClass)
  private
    FValue : Double;
  public
    class function GetTypeName : string; override;
    function WriteToXML : string; override;
    procedure SetAsXML(AValue, ANamespace, ATypeName : string); override;
  published
    property Value : Double read FValue write FValue;
  end;

  TIdSoapInteger = class (TIdSoapSimpleClass)
  private
    FValue : Integer;
  public
    class function GetTypeName : string; override;
    function WriteToXML : string; override;
    procedure SetAsXML(AValue, ANamespace, ATypeName : string); override;
  published
    property Value : Integer read FValue write FValue;
  end;

  TIdSoapString = class (TIdSoapSimpleClass)
  private
    FValue : String;
  public
    class function GetTypeName : string; override;
    function WriteToXML : string; override;
    procedure SetAsXML(AValue, ANamespace, ATypeName : string); override;
  published
    property Value : String read FValue write FValue;
  end;

{==============================================================================}
{  Exception support                                                           ]
{==============================================================================}

type
  EIdBaseSoapableException = class(Exception)
  Public
    constructor Create(const AMessage: String); Virtual;
  end;

  EIdSoapFault = class(Exception)
  private
    FFaultActor:  String;
    FFaultCode:   String;
    FFaultString: WideString;
    FDetails : WideString;
  public
    constructor create(AMessage, AActor, ACode, AString, ADetails : string);
    property FaultActor:  String read FFaultActor  write FFaultActor;
    property FaultCode:   String read FFaultCode   write FFaultCode;
    property FaultString: WideString read FFaultString write FFaultString;
    property Details : WideString read FDetails write FDetails;
  end;

  TIdBaseSoapableExceptionClass = class of EIdBaseSoapableException;

procedure IdRegisterException(AExceptionClass: TIdBaseSoapableExceptionClass; AManualName: String = '');
  // AManualName allows you to map an exception class from the server to a different exception type on the client
function IdExceptionFactory(AExceptionSourceName, AExceptionClassName: String; AMessage : WideString): Exception;

{==============================================================================}
{  Administration                                                              ]
{==============================================================================}

function IdTypeRegistry: TStringList; // no known reason to expose this, just in case someone needs it?
function IdDescribeTypeKind(AType: TTypeKind): String;

{$IFDEF DELPHI4OR5}
function IdSoapBaseArrayType(ATypeInfo: PTypeInfo): PTypeInfo;
{$ENDIF}

implementation

uses
  IdSoapExceptions,
  IdSoapManualExceptionFactory,
  IdSoapPointerManipulator,
  IdSoapResourceStrings,
  IdSoapRTTIHelpers;

var
  GTypeRegistry: TStringList = NIL;
  GSimpleClassList : TStringList = nil;
  // There is no lock on these because we assume that all the registration will be done during unit initialization

type
  TIdSoapTypeInformation = class (TIdBaseObject)
  private
    FTypeInfo : PTypeInfo;
    FBaseType: PTypeInfo;
    FSubstitutionList : PTypeInfoArray;
    function SupportsClass(ATypeInfo : PTypeInfo):Boolean;
  end;

function TIdSoapTypeInformation.SupportsClass(ATypeInfo : PTypeInfo):Boolean;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdSoapTypeInformation.SupportsClass';
var
  i : integer;
begin
  Assert(self.TestValid(TIdSoapTypeInformation), ASSERT_LOCATION+': self is not valid');
  Assert(assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo is not valid');
  if ATypeInfo = FTypeInfo then
    begin
    result := true;
    end
  else
    begin
    result := false;
    for i := Low(FSubstitutionList) to High(FSubstitutionList) do
      begin
      if FSubstitutionList[i] = ATypeInfo then
        begin
        result := true;
        exit;
        end;
      end;
    end;
end;

function LookupTypeInformation(AName : string):TIdSoapTypeInformation;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.LookupTypeInformation';
var
  LIndex : integer;
begin
  Assert(AName <> '', ASSERT_LOCATION+': Name is not valid');
  result := nil;
  if GTypeRegistry.Find(AName, LIndex) then
    begin
    result := GTypeRegistry.Objects[LIndex] as TIdSoapTypeInformation;
    end;
  if not result.TestValid(TIdSoapTypeInformation) then
    begin
    raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNREG_TYPE, [AName]));
    end;
end;

function GetParentClass(ATypeInfo : PTypeInfo):PTypeInfo;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.GetParentClass';
var
  LData : PTypeData;
begin
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+': TypeInfo is not valid');
  Assert(ATypeInfo.Kind = tkClass, ASSERT_LOCATION+': TypeInfo is not a class');
  result := nil;
  LData := GetTypeData(ATypeInfo);
  if assigned(LData.ParentInfo) then
    begin
    result := LData.ParentInfo^;
    end;
end;

function GetTypeForClass(ATypeInfo : PTypeInfo; AInstance : TObject) : PTypeInfo;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdSoapRegisterClass';
var
  LInfo : TIdSoapTypeInformation;
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Assert(assigned(ATypeInfo), ASSERT_LOCATION+': Attempt to get instance type for unregistered object "' + ATypeInfo^.Name + '"');
  Assert(assigned(AInstance), ASSERT_LOCATION+': Attempt to get instance type for nil instance, type "' + ATypeInfo^.Name + '"');
  LInfo := LookupTypeInformation(ATypeInfo^.Name);

  result := AInstance.ClassInfo;
  while assigned(result) and not LInfo.SupportsClass(result) do
    begin
    result := GetParentClass(result);
    end;
  Assert(assigned(result), ASSERT_LOCATION+': the type '+AInstance.ClassName+' is not an acceptable substitute for '+ATypeInfo^.Name);
end;

function GetClassSubstList(ATypeInfo : PTypeInfo): PTypeInfoArray;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.GetClassSubstList';
var
  i : integer;
  LInfo : TIdSoapTypeInformation;
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Assert(assigned(ATypeInfo), ASSERT_LOCATION+': Attempt to get substitutions for a nil type "' + ATypeInfo^.Name + '" with IDSoapTypeRegistry');

  LInfo := LookupTypeInformation(ATypeInfo^.Name);
  SetLength(result, length(LInfo.FSubstitutionList));
  for i := Low(LInfo.FSubstitutionList) to High(LInfo.FSubstitutionList) do
    begin
    result[i] := LInfo.FSubstitutionList[i];
    end;
end;

procedure IdSoapRegisterClass(ATypeDetails: PTypeInfo; ASubstitutionList : Array of PTypeInfo; ARegisterSubstitutions : Boolean = true);
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdSoapRegisterClass';
var
  i : integer;
  LInfo : TIdSoapTypeInformation;
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Assert(assigned(ATypeDetails), ASSERT_LOCATION+': Attempt to register an undescribed type "' + ATypeDetails^.Name + '" with IDSoapTypeRegistry');
  for i := Low(ASubstitutionList) to High(ASubstitutionList) do
    begin
    Assert(assigned(ASubstitutionList[i]), ASSERT_LOCATION+': ASubstitutionList['+inttostr(i)+'] is not valid');
    end;
  IdSoapRegisterType(ATypeDetails);
  if ARegisterSubstitutions then
    begin
    for i := Low(ASubstitutionList) to High(ASubstitutionList) do
      begin
      IdSoapRegisterType(ASubstitutionList[i]);
      end;
    end;
  if Length(ASubstitutionList) > 0 then
    begin
    LInfo := LookupTypeInformation(ATypeDetails^.Name);
    SetLength(LInfo.FSubstitutionList, length(ASubstitutionList));
    for i := Low(ASubstitutionList) to High(ASubstitutionList) do
      begin
      LInfo.FSubstitutionList[i] := ASubstitutionList[i];
      end;
    end;
end;

procedure IdSoapRegisterType(ATypeDetails: PTypeInfo; ATypeName : string = ''; ABaseType: PTypeInfo = nil);
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdSoapRegisterType';
var
  LDummy: Integer;
  LTypeData: PTypeData;
  LInfo : TIdSoapTypeInformation;
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Assert(assigned(ATypeDetails), ASSERT_LOCATION+': Attempt to register an undescribed type "' + ATypeName + '" with IDSoapTypeRegistry');
  if ATypeName = '' then
    begin
    ATypeName := ATypeDetails^.Name;
    end;

  Assert(not GTypeRegistry.Find(ATypeName, LDummy), ASSERT_LOCATION+': Attempt to Register the type "' + ATypeName + '" twice in IDSoapTypeRegistry');
  Assert(ATypeDetails.Kind in [tkInteger, tkChar, tkEnumeration, tkFloat, tkString, tkClass, tkWChar, tkLString, tkWString, tkInt64, tkDynArray, tkSet],
     ASSERT_LOCATION+'Attempt to register unsupported Type '+ATypeName+' = ' + IdDescribeTypeKind(ATypeDetails.Kind) + ' with IdSoapTypeRegistry');
  Assert((ATypeDetails^.Kind <> tkDynArray) or assigned(ABaseType),ASSERT_LOCATION+': No base type supplied for dynamic array ' + ATypeDetails^.Name);
  if ATypeDetails.Kind = tkClass then
    begin
    if (ATypeDetails.Name <> 'TStream') and (ATypeDetails.Name <> 'THexStream') then // TStream is a special cases
      begin
      {$IFOPT C+}
      LTypeData := pointer(PChar(@ATypeDetails^.Name[0]) + 1 + length(ATypeDetails^.Name));
      Assert(LTypeData.ClassType.InheritsFrom(TIdBaseSoapableClass), ASSERT_LOCATION+': Soapable Classes must inherit from TIdBaseSoapableClass');
      {$ENDIF}
      end;
    CreatePropertyManager(ATypeDetails);
    end;
  LInfo := TIdSoapTypeInformation.create;
  LInfo.FTypeInfo := ATypeDetails;
  LInfo.FBaseType := ABaseType;
  GTypeRegistry.AddObject(ATypeName, LInfo);
end;

function IdSoapGetTypeInfo(const ATypeName: String; AExpectedClass : PTypeInfo = nil): PTypeInfo;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdSoapGetType';
var
  LInfo : TIdSoapTypeInformation;
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Assert(ATypeName <> '', ASSERT_LOCATION+': Attempt to find type information in IdSoapTypeRegistry for an unnamed type');
  LInfo := LookupTypeInformation(ATypeName);
  result := LInfo.FTypeInfo;
  if Assigned(AExpectedClass) then
    begin
    LInfo := LookupTypeInformation(AExpectedClass^.Name);
    Assert(LInfo.SupportsClass(result), ASSERT_LOCATION+': Attempt to read type '+ATypeName+' when the type '+AExpectedClass^.Name+' was expected');
    end;
end;

{$IFDEF DELPHI4OR5}
function IdSoapBaseArrayType(ATypeInfo: PTypeInfo): PTypeInfo;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdSoapBaseArrayType';
Var
  LInfo : TIdSoapTypeInformation;
begin
  Assert(Assigned(ATypeInfo),ASSERT_LOCATION+': ATypeInfo is nil');
  Assert(ATypeInfo^.Kind = tkDynArray,ASSERT_LOCATION+': ATypeInfo not a dynamic array');
  LInfo := LookupTypeInformation(ATypeInfo^.Name);
  result := LInfo.FBaseType;
end;
{$ENDIF}

function IdSoapTypeRegistered(const ATypeName: String): boolean;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdSoapTypeRegistered';
var
  LIndex : integer;
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Assert(ATypeName <> '', ASSERT_LOCATION+': Attempt to find type information in IdSoapTypeRegistry for an unnamed type');
  Result := GTypeRegistry.Find(ATypeName, LIndex);
end;

function IdTypeRegistry: TStringList;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdTypeRegistry:';
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Result := GTypeRegistry;
end;

procedure RegisterCommonTypes;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.RegisterCommonTypes';
begin
  Assert(assigned(GTypeRegistry), ASSERT_LOCATION+': IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  IdSoapRegisterType(TypeInfo(Integer)); // do not localize
  IdSoapRegisterType(TypeInfo(Cardinal)); // do not localize
  IdSoapRegisterType(TypeInfo(Shortint)); // do not localize
  IdSoapRegisterType(TypeInfo(Smallint)); // do not localize
  IdSoapRegisterType(TypeInfo(Longint), 'Longint'); // do not localize
  IdSoapRegisterType(TypeInfo(Int64)); // do not localize
  IdSoapRegisterType(TypeInfo(Byte)); // do not localize
  IdSoapRegisterType(TypeInfo(Word)); // do not localize
  IdSoapRegisterType(TypeInfo(Longword), 'Longword'); // do not localize
  IdSoapRegisterType(TypeInfo(Real)); // do not localize
  IdSoapRegisterType(TypeInfo(Single)); // do not localize
  IdSoapRegisterType(TypeInfo(Double)); // do not localize
  IdSoapRegisterType(TypeInfo(Extended)); // do not localize
  IdSoapRegisterType(TypeInfo(Comp)); // do not localize
  IdSoapRegisterType(TypeInfo(Currency)); // do not localize
  IdSoapRegisterType(TypeInfo(Char)); // do not localize
  IdSoapRegisterType(TypeInfo(Boolean)); // do not localize
  IdSoapRegisterType(TypeInfo(LongBool)); // do not localize
  IdSoapRegisterType(TypeInfo(AnsiChar), 'AnsiChar'); // do not localize
  IdSoapRegisterType(TypeInfo(WideChar)); // do not localize
  IdSoapRegisterType(TypeInfo(ShortString)); // do not localize
  IdSoapRegisterType(TypeInfo(String)); // do not localize
  IdSoapRegisterType(TypeInfo(AnsiString), 'AnsiString'); // do not localize
  IdSoapRegisterType(TypeInfo(WideString)); // do not localize
  // special cases:
  IdSoapRegisterType(TypeInfo(TStream)); // do not localize
  IdSoapRegisterType(TypeInfo(TDateTime)); // do not localize

  // types provided here for general use
  IdSoapRegisterType(TypeInfo(THexStream)); // do not localize
  IdSoapRegisterType(TypeInfo(TStringArray), '', TypeInfo(String)); // do not localize
  IdSoapRegisterType(TypeInfo(TIntegerArray), '', TypeInfo(Integer)); // do not localize
  IdSoapRegisterType(TypeInfo(TIdSoapQName)); // do not localize

  IdSoapRegisterSimpleClass(TIdSoapBoolean);
  IdSoapRegisterSimpleClass(TIdSoapDouble);
  IdSoapRegisterSimpleClass(TIdSoapInteger);
  IdSoapRegisterSimpleClass(TIdSoapString);
end;

procedure InitTypeRegistry;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.InitTypeRegistry';
begin
  GTypeRegistry := TIdStringList.Create(true);
  GTypeRegistry.Sorted := True;
  GTypeRegistry.Duplicates := dupError;
  GSimpleClassList := TIdStringList.Create(false);
  GSimpleClassList.Sorted := True;
  GSimpleClassList.Duplicates := dupError;
  RegisterCommonTypes;
end;

procedure IdSoapRegisterSimpleClass(AClass : TIdSoapSimpleClassType);
const ASSERT_LOCATION = 'IdSoapTypeRegistry.RegisterSimpleClassHandler';
begin
  Assert(assigned(GSimpleClassList), ASSERT_LOCATION+': SimpleClassRegistry is not valid');
  Assert(assigned(AClass), ASSERT_LOCATION+': class is not valid');
  Assert(AClass.ClassName = PTypeInfo(AClass.ClassInfo)^.Name, ASSERT_LOCATION+': class name information does not match internally');

  Assert(GSimpleClassList.indexof(AClass.ClassName) = -1, ASSERT_LOCATION+': SimpleClass "'+AClass.ClassName+'" already registered');
  GSimpleClassList.AddObject(AClass.ClassName, TObject(AClass));
  IdSoapRegisterType(AClass.ClassInfo);
end;

function IdSoapGetSimpleClass(AClassName : string ) : TIdSoapSimpleClassType;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.GetSimpleClassHandler';
var
  LIndex : integer;
begin
  Assert(assigned(GSimpleClassList), ASSERT_LOCATION+': SimpleClassRegistry is not valid');
  Assert(AClassName <> '', ASSERT_LOCATION+': Class Name is not valid');
  if GSimpleClassList.Find(AClassName, LIndex) then
    begin
    result := TIdSoapSimpleClassType(GSimpleClassList.Objects[Lindex]);
    end
  else
    begin
    result := nil;
    end;
end;

function IdDescribeTypeKind(AType: TTypeKind): String;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdDescribeTypeKind';
begin
  case AType of
    tkUnknown:
      Result := 'Unknown/Undefined'; // do not localize
    tkInteger:
      Result := 'Numeric'; // do not localize
    tkChar:
      Result := 'Char'; // do not localize
    tkEnumeration:
      Result := 'Enumeration'; // do not localize
    tkFloat:
      Result := 'Float'; // do not localize
    tkString:
      Result := 'String'; // do not localize
    tkSet:
      Result := 'Set'; // do not localize
    tkClass:
      Result := 'Class'; // do not localize
    tkMethod:
      Result := 'Method'; // do not localize
    tkWChar:
      Result := 'WideChar'; // do not localize
    tkLString:
      Result := 'LString'; // do not localize
    tkWString:
      Result := 'WString'; // do not localize
    tkVariant:
      Result := 'Variant'; // do not localize
    tkArray:
      Result := 'Array'; // do not localize
    tkRecord:
      Result := 'Record'; // do not localize
    tkInterface:
      Result := 'Interface'; // do not localize
    tkInt64:
      Result := 'Int64'; // do not localize
    tkDynArray:
      Result := 'Dynamic Array'; // do not localize
    else
      Result := 'Unknown Type ('+inttostr(ord(AType))+')';  // do not localize
    end;    // case
end;

{ TIdBaseSoapableClass }

constructor TIdBaseSoapableClass.Create;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClass.Create';
begin
  inherited Create;
  FOwnsObjects := true;
  FRefCount := 0;
  FRefCountSession := 0;
  FServerLeaveAlive := false;
  FContext := nil;
  FPrev := nil;
  FNext := nil;
end;

destructor TIdBaseSoapableClass.destroy;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClass.destroy';
var
  LOk : boolean;
  LMsg : string;
begin
  Assert(self.TestValid(TIdBaseSoapableClass), ASSERT_LOCATION+': self is not valid');

  if assigned(FContext) then
    begin
    FContext.Detach(self);
    end;
  if FOwnsObjects then
    begin
    if FRefCountSession = 0 then
      begin
      LOk := ValidateTree(Random($FFFE)+1, LMsg);
      IdRequire(LOk, ASSERT_LOCATION+': '+LMsg);
      end;
    CleanUpProperties(ClassInfo);
    end;
  inherited;
end;

function TIdBaseSoapableClass.PrivValidateProperties(ASession: integer; ATypeInfo : PTypeInfo; var VOwners : TIdBaseSoapableClassList; var VMsg : string):boolean;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClass.PrivValidateProperties';
var
  LCount : Integer;
  LInt : integer;
  LClass : TObject;
  LPropMan: TIdSoapPropertyManager;
begin
  Assert(ATypeInfo <> nil, ASSERT_LOCATION+': no type information available for '+ClassName);
  Assert(ATypeInfo^.Kind = tkClass,ASSERT_LOCATION+': Class type expected in ATypeInfo for '+ClassName);
  Assert(self.TestValid, ASSERT_LOCATION+': self is not valid ('+ATypeInfo^.Name+')');
  result := true;
  LPropMan := TIdSoapPropertyManager.Create(ATypeInfo);
  // LPropMan has all properties (parents included) that have both read and write capabilities.
  // it makes no sense for a SOAP property not to have read AND write available.
  try
    LCount := LPropMan.Count;
    for LInt := 1 to LCount do   // iterate through all properties for this class
      begin
      if LPropMan[LInt]^.PropType^^.Kind = tkClass then
        begin
        LClass := LPropMan.AsClass[self,LInt];
        if (LClass <> nil) and (LClass is TIdBaseSoapableClass) then
          begin
          result := result and(LClass as TIdBaseSoapableClass).PrivValidate(ASession, VOwners, VMsg);
          end;
        end;
      end;
  finally
    FreeAndNil(LPropMan);
    end;
end;

function TIdBaseSoapableClass.PrivValidate(ASession : integer; var VOwners : TIdBaseSoapableClassList; var VMsg : string):boolean;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClass.PrivValidate';
var i : integer;
begin
  Assert(self.TestValid, ASSERT_LOCATION+': self is not valid ('+ClassName+')');
  result := true;
  if FRefCountSession = ASession then
    begin
    for i := Low(VOwners) to High(VOwners) do
      begin
      if VOwners[i] = self then
        begin
        result := false;
        VMsg := 'Object points to itself at level '+inttostr(i);
        end;
      end;
    if result then
      begin
      inc(FRefCount);
      end
    end
  else
    begin
    FRefCount := 1;
    FRefCountSession := ASession;
    SetLength(VOwners, length(VOwners)+1);
    VOwners[High(VOwners)] := self;
    result := PrivValidateProperties(ASession, ClassInfo, VOwners, VMsg);
    SetLength(VOwners, length(VOwners)-1);
    end;
end;

procedure TIdBaseSoapableClass.CleanUpProperties(ATypeInfo : PTypeInfo);
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClass.CleanUpProperties';
var
  LInt : integer;
  LClass : TObject;
  LPropMan: TIdSoapPropertyManager;
begin
  Assert(self.TestValid, ASSERT_LOCATION+': self is not valid ('+ATypeInfo^.Name+')');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+': no type information available for '+ClassName);
  Assert(ATypeInfo^.Kind = tkClass,ASSERT_LOCATION+': Class type expected in ATypeInfo for '+ClassName);
  LPropMan := TIdSoapPropertyManager.Create(ATypeInfo);
  try
    for LInt := 1 to LPropMan.Count do   // iterate through all properties for this class
      begin
      if LPropMan[LInt]^.PropType^^.Kind = tkClass then
        begin
        LClass := LPropMan.AsClass[self,LInt];
        if Assigned(LClass) then
          begin
          if LClass is TIdBaseSoapableClass then
            begin
            (LClass as TIdBaseSoapableClass).DeReference;
            end
          else
            begin
            FreeAndNil(LClass);
            end;
          LPropMan.AsClass[self,LInt] := nil;
          end;
        end;
      end;
  finally
    FreeAndNil(LPropMan);
    end;
end;

function TIdBaseSoapableClass.ValidateTree(ASession : integer; Var VMsg : string):boolean;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClass.ValidateTree';
var
  LObjList : TIdBaseSoapableClassList;
begin
  Assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  Assert(ASession <> 0, ASSERT_LOCATION+': Session is 0');
  SetLength(LObjList, 0);
  result := PrivValidate(ASession, LObjList, VMsg);
end;

procedure TIdBaseSoapableClass.DeReference;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClass.DeReference';
begin
  Assert(self.TestValid, ASSERT_LOCATION+': self is not valid');
  if FRefCount > 0 then
    begin
    dec(FRefCount);
    end;
  if FRefCount = 0 then
    begin
    free;
    end;
end;

{ EIdBaseSoapableException }

var
  GExceptionRegistry: TStringList;
  // There is no lock on GExceptionRegistry because we assume that all the registration will be done during unit initialization

type
  TIdExceptionInfo = class(TIdBaseObject)
    FExceptClass: TIdBaseSoapableExceptionClass;
    constructor Create(AExceptClass: TIdBaseSoapableExceptionClass);
  end;

constructor EIdBaseSoapableException.Create(const AMessage: String);
begin
  inherited Create(AMessage);
end;

procedure IdRegisterException(AExceptionClass: TIdBaseSoapableExceptionClass; AManualName: String = '');
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdRegisterException';
var
  LDummy: Integer;
begin
  Assert(assigned(GExceptionRegistry), 'IdSoapTypeRegistry.IdRegisterException: IDSoapTypeRegistry Not initialised. Check Unit Initialization order');
  Assert(assigned(AExceptionClass), 'IdSoapTypeRegistry.IdRegisterException: Attempt to register an invalid Exception with IDSoapTypeRegistry'); // surely couldn't happen?
  if AManualName = '' then
    AManualName := AExceptionClass.ClassName;
  Assert(AManualName <> '', 'IdSoapTypeRegistry.IdRegisterException: Attempt to register an invalid Exception with IDSoapTypeRegistry'); // surely couldn't happen?
  Assert(not GExceptionRegistry.Find(AManualName, LDummy), 'IdSoapTypeRegistry.IdRegisterException: Attempt to Register the Exception class "' + AManualName + '" twice in IDSoapTypeRegistry');
  GExceptionRegistry.AddObject(AManualName, TIdExceptionInfo.Create(AExceptionClass));
end;

function IdExceptionFactory(AExceptionSourceName, AExceptionClassName: String; AMessage : WideString): Exception;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.IdExceptionFactory';
var
  LIndex: Integer;
begin
  // AExceptionClassName can be ''
  if AMessage = '' then
    AMessage := 'No Message Provided for Exception in SOAP Packet'; // err, who knows whether this is wise or not?

  if AExceptionSourceName = '' then
    begin
    AExceptionSourceName := ID_SOAP_NS_SOAPENV_CODE+':'+RS_MSG_SERVER_ERROR;
    end;
  AMessage := AExceptionSourceName+': '+AMessage;

  // first, we check in our registry. This is to support the use of AManualName above
  if GExceptionRegistry.Find(AExceptionClassName, LIndex) then
    begin
    Result := (GExceptionRegistry.Objects[LIndex] as TIdExceptionInfo).FExceptClass.Create(AMessage);
    end
  else
    begin
    Result := IdManualExceptionFactory(AExceptionClassName, AMessage);
    end;
end;

procedure InitExceptionRegistry;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.InitExceptionRegistry';
begin
  Assert(not assigned(GExceptionRegistry), 'IdSoapTypeRegistry.InitExceptionRegistry: Attempt to initialize IDSoapTypeRegistry After it is already initialised');
  GExceptionRegistry := TIdStringList.Create(True);
  GExceptionRegistry.Sorted := True;
  GExceptionRegistry.Duplicates := dupError;
end;

{ TIdExceptionInfo }

constructor TIdExceptionInfo.Create(AExceptClass: TIdBaseSoapableExceptionClass);
begin
  inherited Create;
  FExceptClass := AExceptClass;
end;

{ TIdBaseSoapableClassContext }

constructor TIdBaseSoapableClassContext.create;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClassContext.create';
begin
  inherited;
  FFirst := nil;
  FLast := nil;
  FOwnedObjectCount := 0;
  FOtherObjects := TObjectList.create(true);
end;

destructor TIdBaseSoapableClassContext.destroy;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClassContext.destroy';
begin
  Assert(self.TestValid(TIdBaseSoapableClassContext), ASSERT_LOCATION+': self is not valid');
  CleanUp;
  FreeAndNil(FOtherObjects);
  inherited;
end;

procedure TIdBaseSoapableClassContext.AttachObj(AObj : TIdBaseObject);
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClassContext.Attach';
begin
  // this is used for other non soapable objects that also fall into this garbage collection context
  Assert(self.TestValid(TIdBaseSoapableClassContext), ASSERT_LOCATION+': self is not valid');
  Assert(AObj.TestValid(TIdBaseObject), ASSERT_LOCATION+': self is not valid');
  FOtherObjects.Add(AObj);
  inc(FOwnedObjectCount);
end;

procedure TIdBaseSoapableClassContext.Attach(AObject : TIdBaseSoapableClass);
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClassContext.Attach';
begin
  Assert(self.TestValid(TIdBaseSoapableClassContext), ASSERT_LOCATION+': self is not valid');
  Assert(AObject.TestValid(TIdBaseSoapableClass), ASSERT_LOCATION+': self is not valid');
  if AObject.FContext <> self then
    begin
    if AObject.FContext <> nil then
      begin
      AObject.FContext.Detach(AObject);
      end;
    if FFirst = nil then
      begin
      Assert(FOwnedObjectCount = 0, ASSERT_LOCATION+': First is nil, and object count <> 0');
      Assert(FLast = nil, ASSERT_LOCATION+': First is nil, and Last is not');
      end
    else
      begin
      Assert(FOwnedObjectCount <> 0, ASSERT_LOCATION+': First is not nil, and object count = 0');
      Assert(FLast <> nil, ASSERT_LOCATION+': First is not nil, and Last is not');
      end;
    AObject.FNext := FFirst;
    AObject.FPrev := nil;
    inc(FOwnedObjectCount);
    if assigned(FFirst) then
      begin
      FFirst.FPrev := AObject;
      end
    else
      begin
      FLast := AObject;
      end;
    FFirst := AObject;
    AObject.FContext := self;
    end;
end;

procedure TIdBaseSoapableClassContext.Detach(AObject : TIdBaseSoapableClass);
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClassContext.Detach';
begin
  Assert(self.TestValid(TIdBaseSoapableClassContext), ASSERT_LOCATION+': self is not valid');
  Assert(FFirst <> nil, ASSERT_LOCATION+': First is nil');
  Assert(FLast <> nil, ASSERT_LOCATION+': Last is nil');
  Assert(AObject.TestValid(TIdBaseSoapableClass), ASSERT_LOCATION+': Object is not valid');
  Assert(FOwnedObjectCount > 0, ASSERT_LOCATION+': Object count = 0');
  if AObject.FPrev = nil then
    begin
    Assert(FFirst = AObject, ASSERT_LOCATION+': Object has no previous, but is not first');
    end;
  if AObject.FNext = nil then
    begin
    Assert(FLast = AObject, ASSERT_LOCATION+': Object has no Next, but is not Last');
    end;
  if (AObject.FPrev <> nil) and (AObject.FNext <> nil) then
    begin
    Assert(FFirst <> AObject, ASSERT_LOCATION+': Object has prev and Next but is first');
    Assert(FLast <> AObject, ASSERT_LOCATION+': Object has prev and Next but is last');
    end;
  if FFirst = AObject then
    begin
    FFirst := AObject.FNext;
    if assigned(FFirst) then
      begin
      FFirst.FPrev := nil;
      end;
    end
  else
    begin
    AObject.FPrev.FNext := AObject.FNext;
    end;
  if FLast = AObject then
    begin
    FLast := AObject.FPrev;
    if assigned(FLast) then
      begin
      FLast.FNext := nil;
      end;
    end
  else
    begin
    AObject.FNext.FPrev := AObject.FPrev;
    end;
  AObject.FContext := nil;
  AObject.FPrev := nil;
  AObject.FNext := nil;
  dec(FOwnedObjectCount);
end;

procedure TIdBaseSoapableClassContext.Cleanup;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClassContext.Cleanup';
var
  FTemp : TIdBaseSoapableClass;
begin
  Assert(self.TestValid(TIdBaseSoapableClassContext), ASSERT_LOCATION+': self is not valid');
  While FFirst <> nil do
    begin
    FTemp := FFirst;
    Assert(FTemp.TestValid(TIdBaseSoapableClass), ASSERT_LOCATION+': Temp is not valid');
    FFirst := FFirst.FNext;
    FTemp.FContext := nil;
    FTemp.free;
    end;
  FLast := nil;
  FOtherObjects.Clear;
  FOwnedObjectCount := 0;
end;

function TIdBaseSoapableClassContext.OwnsObject(AObject : TIdBaseSoapableClass) : boolean;
const ASSERT_LOCATION = 'IdSoapTypeRegistry.TIdBaseSoapableClassContext.OwnsObject';
begin
  result := AObject.FContext = self;
end;


{ EIdSoapFault }

constructor EIdSoapFault.create(AMessage, AActor, ACode, AString, ADetails : string);
begin
  inherited create(AMessage);
  FFaultActor := AActor;
  FFaultCode := ACode;
  FFaultString := AString;
  FDetails := ADetails;
end;

{ TIdSoapSimpleClass }

class function TIdSoapSimpleClass.GetNamespace : string;
begin
  result := ID_SOAP_NS_SCHEMA_2001;
end;

{ TIdSoapBoolean }

class function TIdSoapBoolean.GetTypeName : string;
begin
  result := ID_SOAP_XSI_TYPE_BOOLEAN;
end;

function TIdSoapBoolean.WriteToXML : string;
begin
  result := BoolToXML(FValue);
end;

procedure TIdSoapBoolean.SetAsXML(AValue, ANamespace, ATypeName : string);
begin
  // we do not check the type
  FValue := XMLToBool(AValue);
end;

{ TIdSoapDouble }

class function TIdSoapDouble.GetTypeName : string;
begin
  result := ID_SOAP_XSI_TYPE_DOUBLE;
end;

function TIdSoapDouble.WriteToXML : string;
begin
  result := IdDoubleToStr(FValue);
end;

procedure TIdSoapDouble.SetAsXML(AValue, ANamespace, ATypeName : string);
begin
  // we do not check the type
  FValue := IdStrToDoubleWithError(AValue, 'TIdSoapDouble Value');
end;

{ TIdSoapInteger }

class function TIdSoapInteger.GetTypeName : string;
begin
  result := ID_SOAP_XSI_TYPE_INTEGER;
end;

function TIdSoapInteger.WriteToXML : string;
begin
  result := IntToStr(FValue);
end;

procedure TIdSoapInteger.SetAsXML(AValue, ANamespace, ATypeName : string);
begin
  // we do not check the type
  FValue := IdStrToIntWithError(AValue, 'TIdSoapInteger Value');
end;

{ TIdSoapString }

class function TIdSoapString.GetTypeName : string;
begin
  result := ID_SOAP_XSI_TYPE_STRING;
end;

function TIdSoapString.WriteToXML : string;
begin
  result := FValue;
end;

procedure TIdSoapString.SetAsXML(AValue, ANamespace, ATypeName : string);
begin
  // we do not check the type
  FValue := AValue;
end;

function IdArrayToString(const AArray : TIntegerArray) : string; overload;
var
  i : integer;
begin
  if Length(AArray) = 0 then
    begin
    result := '';
    end
  else
    begin
    result := inttostr(AArray[0]);
    for i := Low(AArray) +1 to High(AArray) do
      begin
      result := result + ', ' + inttostr(AArray[i]);
      end;
    end;
end;

function Escape(AStr : string):String;
var
  i : integer;
begin
  if pos(',', AStr) and pos('"', AStr) = 0 then
    begin
    result := AStr;
    end
  else
    begin
    result := '"';
    for i := 1 to length(AStr) do
      begin
      if AStr[i] = '"' then
        begin
        result := result + AStr[i];
        end;
      result := result + AStr[i];
      end;
    end;
end;

function IdArrayToString(const AArray : TStringArray) : string; overload;
var
  i : integer;
begin
  if Length(AArray) = 0 then
    begin
    result := '';
    end
  else
    begin
    result := Escape(AArray[0]);
    for i := Low(AArray) +1 to High(AArray) do
      begin
      result := result + ', ' + escape(AArray[i]);
      end;
    end;
end;

procedure IdAddToArray(Var VArray : TIntegerArray; AVal : integer); overload;
begin
  SetLength(VArray, Length(VArray)+1);
  VArray[Length(VArray)-1] := AVal;
end;

procedure IdAddToArray(Var VArray : TStringArray; AVal : string); overload;
begin
  SetLength(VArray, Length(VArray)+1);
  VArray[Length(VArray)-1] := AVal;
end;

procedure IdDeleteFromArray(Var VArray : TIntegerArray; AIndex : integer); overload;
var
  i : integer;
begin
  for i := AIndex to High(VArray) - 1 do
    begin
    VArray[i] := VArray[i + 1];
    end;
  SetLength(VArray, Length(VArray)-1);
end;

procedure IdDeleteFromArray(Var VArray : TStringArray; AIndex : integer); overload;
var
  i : integer;
begin
  for i := AIndex to High(VArray) - 1 do
    begin
    VArray[i] := VArray[i + 1];
    end;
  SetLength(VArray, Length(VArray)-1);
end;

procedure IdDeleteValueFromArray(Var VArray : TIntegerArray; AVal : integer); overload;
var
  i : integer;
begin
  for i := High(VArray) to Low(VArray) do
    begin
    if VArray[i] = AVal then
      begin
      IdDeleteFromArray(VArray, i);
      end;
    end;
end;

procedure IdDeleteValueFromArray(Var VArray : TStringArray; AVal : string); overload;
var
  i : integer;
begin
  for i := High(VArray) to Low(VArray) do
    begin
    if AnsiSameText(VArray[i], AVal) then
      begin
      IdDeleteFromArray(VArray, i);
      end;
    end;
end;

function IdFindValueInArray(const AArray : TIntegerArray; AVal : integer):boolean; overload;
var
  i : integer;
begin
  result := false;
  for i := Low(AArray) to High(AArray) do
    begin
    if AArray[i] = AVal then
      begin
      result := true;
      exit;
      end;
    end;
end;

function IdFindValueInArray(const AArray : TStringArray; AVal : String):boolean; overload;
var
  i : integer;
begin
  result := false;
  for i := Low(AArray) to High(AArray) do
    begin
    if AnsiSameText(AArray[i], AVal) then
      begin
      result := true;
      exit;
      end;
    end;
end;
initialization
  InitTypeRegistry;
  InitExceptionRegistry;

finalization
  FreeAndNil(GExceptionRegistry);
  FreeAndNil(GTypeRegistry);
  FreeAndNil(GSimpleClassList);
end.

