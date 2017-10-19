{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15702: IdSoapComponent.pas 
{
{   Rev 1.1    20/6/2003 00:02:40  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:32:12  GGrieve
}
{
IndySOAP: This unit defines a base component which plugs in to the leak tracking architecture
}
{
Version History:
  19-Jun 2003   Grahame Grieve                  remove class_tracking
  26-Jul 2002   Grahame Grieve                  D4 Compiler fixes
  22-Jul 2002   Grahame Grieve                  Soap Version support
  18-Jul 2002   Grahame Grieve                  Better control over Mime Types
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  26-Feb 2002   Grahame Grieve                  First written
}


unit IdSoapComponent;


{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdComponent,
  IdSoapDebug;

type
{==============================================================================

 Soap version support

 currently IndySoap only implements Version 1.1                                }

  TIdSoapVersion = (IdSoapV1_1);

{
  IdSoapV1_1: Soap Version 1.1 specification, as widely implemented.

    References
       SOAP  http://www.w3.org/TR/2000/NOTE-SOAP-20000508
       WSDL  http://www.w3.org/TR/2001/NOTE-wsdl-20010315                      }

  TIdSoapVersionSet = set of TIdSoapVersion;

{==============================================================================}

  TIdSoapComponent = class(TIdComponent)
  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; Override;
    function TestValid(AClassType: TClass = NIL): Boolean;
  end;

implementation

{ TIdSoapComponent }

constructor TIdSoapComponent.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF OBJECT_TRACKING}
  IdObjectRegister(self);
  {$ENDIF}
end;

destructor TIdSoapComponent.Destroy;
begin
  {$IFDEF OBJECT_TRACKING}
  IdObjectDeregister(self);
  {$ENDIF}
  inherited;
end;

function TIdSoapComponent.TestValid(AClassType: TClass): Boolean;
begin
  {$IFDEF OBJECT_TRACKING}
  Result := IdObjectTestValid(self);
  {$ELSE}
  Result := Assigned(self);
  {$ENDIF}
  if Result and assigned(AClassType) then
    begin
    Result := self is AClassType;
    end;
end;

end.
