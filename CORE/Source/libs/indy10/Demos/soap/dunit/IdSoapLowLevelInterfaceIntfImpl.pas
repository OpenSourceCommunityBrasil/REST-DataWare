{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16423: IdSoapLowLevelInterfaceIntfImpl.pas 
{
{   Rev 1.0    25/2/2003 13:28:48  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  09-Oct 2002   Andrew Cumming                  First added
}

unit IdSoapLowLevelInterfaceIntfImpl;

interface

uses
  SysUtils,
  IdSoapLowLevelInterfaceIntfDefn,
  IdSoapIntfRegistry;

type
  EInterfaceInheritanceFailed = class(Exception);

  TIdSoapInterfaceLevel0 = Class (TIdSoapBaseImplementation, IIdSoapInterfaceLevel0)
  public
    procedure Check(ACondition: Boolean; AMessage: String);
  published
    function Level0(Depth: Integer): Integer; stdcall;
  end;

  TIdSoapInterfaceLevel1 = Class (TIdSoapInterfaceLevel0, IIdSoapInterfaceLevel1)
  published
    function Level1(Depth: Integer): Integer; stdcall;
  end;

  TIdSoapInterfaceLevel2 = Class (TIdSoapInterfaceLevel1, IIdSoapInterfaceLevel2)
  published
    function Level2(Depth: Integer): Integer; stdcall;
  end;

  TIdSoapInterfaceCrosslink1 = Class (TIdSoapInterfaceLevel0, IIdSoapInterfaceCrosslink1)
  published
    function Level1(Depth: Integer): Integer; stdcall;
  end;

  TIdSoapInterfaceCrosslink2 = Class (TIdSoapInterfaceLevel0, IIdSoapInterfaceCrosslink2)
  published
    function Level1a(Depth: Integer): Integer; stdcall;
  end;

implementation

{ TIdSoapInterfaceLevel0 }

procedure TIdSoapInterfaceLevel0.Check(ACondition: Boolean; AMessage: String);
begin
  if not ACondition then
    raise EInterfaceInheritanceFailed.Create('Server Error: ' + AMessage);
end;

function TIdSoapInterfaceLevel0.Level0(Depth: Integer): Integer;
begin
  Check(Depth = 0,'Incorrect inheritance depth for Level 0');
  result := 0;
end;

{ TIdSoapInterfaceLevel1 }

function TIdSoapInterfaceLevel1.Level1(Depth: Integer): Integer;
begin
  Check(Depth = 1,'Incorrect inheritance depth for Level 1');
  result := 1;
end;

{ TIdSoapInterfaceLevel2 }

function TIdSoapInterfaceLevel2.Level2(Depth: Integer): Integer;
begin
  Check(Depth = 2,'Incorrect inheritance depth for Level 2');
  result := 2;
end;

{ TIdSoapInterfaceCrosslink1 }

function TIdSoapInterfaceCrosslink1.Level1(Depth: Integer): Integer;
begin
  Check(Depth = 1,'Incorrect inheritance depth for Level 1');
  result := 1;
end;

{ TIdSoapInterfaceCrosslink2 }

function TIdSoapInterfaceCrosslink2.Level1a(Depth: Integer): Integer;
begin
  Check(Depth = 11,'Incorrect inheritance depth for Level 1a');
  result := 11;
end;

Initialization
  IdSoapRegisterInterfaceClass('IIdSoapInterfaceLevel0', TypeInfo(TIdSoapInterfaceLevel0), TIdSoapInterfaceLevel0);
  IdSoapRegisterInterfaceClass('IIdSoapInterfaceLevel1', TypeInfo(TIdSoapInterfaceLevel1), TIdSoapInterfaceLevel1);
  IdSoapRegisterInterfaceClass('IIdSoapInterfaceLevel2', TypeInfo(TIdSoapInterfaceLevel2), TIdSoapInterfaceLevel2);
  IdSoapRegisterInterfaceClass('IIdSoapInterfaceCrosslink1', TypeInfo(TIdSoapInterfaceCrosslink1), TIdSoapInterfaceCrosslink1);
  IdSoapRegisterInterfaceClass('IIdSoapInterfaceCrosslink2', TypeInfo(TIdSoapInterfaceCrosslink2), TIdSoapInterfaceCrosslink2);
end.
