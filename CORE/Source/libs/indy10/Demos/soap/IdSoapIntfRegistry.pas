{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15726: IdSoapIntfRegistry.pas 
{
{   Rev 1.1    20/6/2003 00:03:12  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:33:26  GGrieve
}
{
IndySOAP: Server Side Interface registration

All interfaces that may be published through any ITI used by the
server must be registered here in this unit.

Since IndySOAP will need to create objects to provide the interface services,
either an Class or a factory must be defined to allow the library to create
the object.

The class will need to descend from TIdSoapBaseImplementation.

The factory need not create a new instance of the object everytime - it can serve up the
same object everytime if the object is thread-safe (since the Server
implementation is implicitly multi-threaded).

Of course, the object you register, or that the factory returns, must
actually implement the interface in question.

In addition any types used by the interface itself must be registered
in IdSoapTypeRegistry

** Interface Registration should be done during unit initialization **


Registering Interface Names
===========================

A second system is maintained that simply registers interface names.
This system is currently only used by the D6 RTTI -> ITI convertor.

Registering Interfaces here is optional but this is provided for
convenience
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Unregister interface - for hosting interfaces in packages
  26-Sep 2002   Grahame Grieve                  Better reference count control again
  17-Sep 2002   Grahame Grieve                  More reference count control
  17-Sep 2002   Grahame Grieve                  Debugging and reference count control for the implementation object
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  26-Mar 2002   Grahame Grieve                  Add IdSoapDefines.inc
   7-Mar 2002   Grahame Grieve                  Review assertions, add Interface Name Registration Support (RTTI support)
  11-Feb 2002   Andrew Cumming                  Corrected spelling error
  03-Feb 2002   Andrew Cumming                  Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapIntfRegistry;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapDebug,
  TypInfo;

type
  {$M+}  // TIdSoapBaseImplementation MUST have RTTI enabled

  TIdSoapBaseImplementation = class(TInterfacedObject)
  Private
    FSerialNo: Integer;
    FReferenceCounted: boolean;
  Public
    constructor Create; Virtual;
    Destructor destroy; override;

    // refer TIdBaseObject for doco - this object can't inherit from TIdBaseObject. (well, it could, but easier to redefine here)
    property SerialNumber: Integer Read FSerialNo;
    procedure AskForBreakPointOnFree;
    function TestValid(AClassType: TClass = NIL): Boolean;

    // give user better control over object lifetime if desired
    function _AddRef: Integer; reintroduce; stdcall;
    function _Release: Integer; reintroduce; stdcall;
    property ReferenceCounted : boolean read FReferenceCounted write FReferenceCounted;
    { for further information see June 2002 Delphi Informant }
  end;

  {$M-}

  TIdSoapBaseImplementationClass = class of TIdSoapBaseImplementation;

  TIdSoapImplementationFactory = function(AInterfaceName: String): TInterfacedObject;

procedure IdSoapRegisterInterfaceClass(AInterfaceName: String; // the name of the interface as found in the source & ITI
  AClassType: pTypeInfo;  // the typeinfo for the class (i.e. TypeInfo(TMyImplementation)
  AClass: TIdSoapBaseImplementationClass);

procedure IdSoapRegisterInterfaceFactory(AInterfaceName: String; // the name of the interface as found in the source & ITI
  AClassType: pTypeInfo;  // the typeinfo for the class (i.e. TypeInfo(TMyImplementation)
  AFactory: TIdSoapImplementationFactory);

function IdSoapInterfaceRegistered(AInterfaceName: String):boolean;

procedure IdSoapUnRegister(AInterfaceName: String);

function IdSoapInterfaceImplementationFactory(AInterfaceName: String): TInterfacedObject;

procedure IdSoapRegisterInterface(AInfo : pTypeInfo);

var
  GInterfaceNames : TStringList;

implementation

uses
  IdSoapUtilities,
  SysUtils;

const
  ASSERT_UNIT = 'IdSoapIntfRegistry';

{ TIdSoapBaseImplementation }

constructor TIdSoapBaseImplementation.Create;
begin
  inherited Create;
  FSerialNo := IdObjectRegister(self);
  FReferenceCounted := true;
end;

destructor TIdSoapBaseImplementation.destroy;
begin
  IdObjectDeregister(self);
  inherited;
end;

function TIdSoapBaseImplementation._AddRef: Integer;
begin
  if FReferenceCounted then
    begin
    result := inherited _AddRef;
    end
  else
    begin
    result := -1;
    end;
end;

function TIdSoapBaseImplementation._Release: Integer;
begin
  if FReferenceCounted then
    begin
    result := inherited _Release;
    end
  else
    begin
    result := -1;
    end;
end;

procedure TIdSoapBaseImplementation.AskForBreakPointOnFree;
begin
  IdObjectBreakPointOnFree(self);
end;

function TIdSoapBaseImplementation.TestValid(AClassType: TClass): Boolean;
begin
  {$IFDEF OBJECT_TRACKING}
  Result := IdObjectTestValid(self);
  {$ELSE}
  Result := Assigned(self);
  {$ENDIF}
  if Result and assigned(AClassType) then
    begin
    Result := Self is AClassType;
    end;
end;

{ InterfaceRegistry }

var
  GInterfaceRegistry: TStringList = NIL;
  // There is no lock on GInterfaceRegistry because we assume that all the registration will be done during unit initialization

type
  TInterfaceInformation = class(TIdBaseObject)
    FInterfaceName: String;
    FTypeInfo: pTypeInfo;
    FUseFactory: Boolean;
    FClass: TIdSoapBaseImplementationClass;
    FFactory: pointer;
  end;


procedure IdSoapRegisterInterfaceClass(AInterfaceName: String; // the name of the interface as found in the source & ITI
  AClassType: pTypeInfo;  // the typeinfo for the class (i.e. TypeInfo(TMyImplementation)
  AClass: TIdSoapBaseImplementationClass);
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapRegisterInterfaceClass';
var
  LDummy: Integer;
  LInfo: TInterfaceInformation;
begin
  assert(assigned(GInterfaceRegistry), ASSERT_LOCATION+': IDSoapIntfRegistry Not initialised. Check Unit Initialization order');
  assert(AInterfaceName <> '', ASSERT_LOCATION+': Attempt to register unnamed interface');
  assert(Assigned(AClassType), ASSERT_LOCATION+': Attempt to register unknown implementation in IDSoapIntfRegistry for Interface "' + AInterfaceName + '"');
  assert(Assigned(AClass), ASSERT_LOCATION+': Attempt to register implementation in IDSoapIntfRegistry with no Class Defined for Interface "' + AInterfaceName + '"');
  assert(not GInterfaceRegistry.Find(AInterfaceName, LDummy), ASSERT_LOCATION+': Attempt to register an interface twice ("' + AInterfaceName + '") that already exists');
  LInfo := TInterfaceInformation.Create;
  LInfo.FInterfaceName := AInterfaceName;
  LInfo.FTypeInfo := AClassType;
  LInfo.FUseFactory := False;
  LInfo.FClass := AClass;
  GInterfaceRegistry.AddObject(LInfo.FInterfaceName, LInfo);
end;

procedure IdSoapRegisterInterfaceFactory(AInterfaceName: String; // the name of the interface as found in the source & ITI
  AClassType: pTypeInfo;  // the typeinfo for the class (i.e. TypeInfo(TMyImplementation)
  AFactory: TIdSoapImplementationFactory);
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapRegisterInterfaceFactory';
var
  LDummy: Integer;
  LInfo: TInterfaceInformation;
begin
  assert(assigned(GInterfaceRegistry), ASSERT_LOCATION+': IDSoapIntfRegistry Not initialised. Check Unit Initialization order');
  assert(AInterfaceName <> '', ASSERT_LOCATION+': Attempt to register unnamed interface');
  assert(Assigned(AClassType), ASSERT_LOCATION+': Attempt to register unknown implementation in IDSoapIntfRegistry for Interface "' + AInterfaceName + '"');
  assert(Assigned(AFactory), ASSERT_LOCATION+': Attempt to register implementation in IDSoapIntfRegistry with no factory Defined for Interface "' + AInterfaceName + '"');
  assert(not GInterfaceRegistry.Find(AInterfaceName, LDummy), ASSERT_LOCATION+': Attempt to register an interface twice ("' + AInterfaceName + '") that already exists');
  LInfo := TInterfaceInformation.Create;
  LInfo.FInterfaceName := AInterfaceName;
  LInfo.FTypeInfo := AClassType;
  LInfo.FUseFactory := True;
  LInfo.FFactory := @AFactory;
  GInterfaceRegistry.AddObject(LInfo.FInterfaceName, LInfo);
end;

function IdSoapInterfaceRegistered(AInterfaceName: String):boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapInterfaceImplementationFactory';
var
  LIndex: Integer;
begin
  assert(assigned(GInterfaceRegistry), ASSERT_LOCATION+': IDSoapIntfRegistry Not initialised in IdInterfaceImplementationFactory');
  assert(AInterfaceName <> '', ASSERT_LOCATION+': AInterfaceName = ''''');
  result := GInterfaceRegistry.Find(AInterfaceName, LIndex);
end;

procedure IdSoapUnRegister(AInterfaceName: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapInterfaceImplementationFactory';
var
  LIndex: Integer;
begin
  assert(assigned(GInterfaceRegistry), ASSERT_LOCATION+': IDSoapIntfRegistry Not initialised in IdInterfaceImplementationFactory');
  assert(AInterfaceName <> '', ASSERT_LOCATION+': Attempt to create an unnamed interface in IdInterfaceImplementationFactory');
  if GInterfaceRegistry.Find(AInterfaceName, LIndex) then
    begin
    GInterfaceRegistry.Delete(LIndex);
    end;
end;

function IdSoapInterfaceImplementationFactory(AInterfaceName: String): TInterfacedObject;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapInterfaceImplementationFactory';
var
  LIndex: Integer;
  LInfo: TInterfaceInformation;
begin
  assert(assigned(GInterfaceRegistry), ASSERT_LOCATION+': IDSoapIntfRegistry Not initialised in IdInterfaceImplementationFactory');
  assert(AInterfaceName <> '', ASSERT_LOCATION+': Attempt to create an unnamed interface in IdInterfaceImplementationFactory');
  IDRequire(GInterfaceRegistry.Find(AInterfaceName, LIndex), ASSERT_LOCATION+': Attempt to create an unknown interface "' + AInterfaceName + '" in IdInterfaceImplementationFactory');
  LInfo := GInterfaceRegistry.objects[LIndex] as TInterfaceInformation;
  Assert(LInfo.TestValid, ASSERT_LOCATION+': TInterfaceInformation not valid in IdInterfaceImplementationFactory');
  if LInfo.FUseFactory then
    Result := TIdSoapImplementationFactory(LInfo.FFactory)(AInterfaceName)
  else
    Result := LInfo.FClass.Create;
end;

procedure IdSoapRegisterInterface(AInfo : pTypeInfo);
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapRegisterInterface';
var
  LName : string;
begin
  assert(assigned(GInterfaceNames), ASSERT_LOCATION+': InterfaceNames is not valid');
  Assert(Assigned(AInfo), ASSERT_LOCATION+': Interface Info is not valid');
  Assert(AInfo.Kind = tkInterface, ASSERT_LOCATION+': Interface Info does not describe an interface');
  LName := AInfo.Name;
  Assert(LName <> '', ASSERT_LOCATION+': attempt to register unnamed interface');
  Assert(GInterfaceNames.IndexOf(LName) = -1, ASSERT_LOCATION+': AInterfaceName already defined');
  GInterfaceNames.AddObject(LName, TObject(AInfo));
end;

procedure InitIntfRegistry;
const ASSERT_LOCATION = ASSERT_UNIT+'.InitIntfRegistry';
begin
  Assert(not assigned(GInterfaceRegistry), ASSERT_LOCATION+': Attempt to initialize IdSoapIntfRegistry After it is already initialised');
  GInterfaceRegistry := TIdStringList.Create(True);
  GInterfaceRegistry.Sorted := True;
  GInterfaceRegistry.Duplicates := dupError;
  GInterfaceNames :=  TStringList.create;
end;

procedure CloseIntfRegistry;
const ASSERT_LOCATION = ASSERT_UNIT+'.CloseIntfRegistry';
begin
  Assert(assigned(GInterfaceRegistry), ASSERT_LOCATION+': GInterfaceRegistry not assigned finalizing IdSoapIntfRegistry');
  FreeAndNil(GInterfaceRegistry);
  FreeAndNil(GInterfaceNames);
end;

initialization
  InitIntfRegistry;
finalization
  CloseIntfRegistry;
end.
