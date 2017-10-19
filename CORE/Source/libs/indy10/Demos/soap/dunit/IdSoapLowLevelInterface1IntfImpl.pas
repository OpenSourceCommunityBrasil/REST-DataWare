{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16419: IdSoapLowLevelInterface1IntfImpl.pas 
{
{   Rev 1.0    25/2/2003 13:28:38  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  09-Oct 2002   Andrew Cumming                  First added
}

unit IdSoapLowLevelInterface1IntfImpl;

interface

uses
  IdSoapLowLevelInterfaceIntfDefn,
  IdSoapLowLevelInterfaceIntfImpl,
  IdSoapLowLevelInterface1IntfDefn,
  IdSoapIntfRegistry,
  SysUtils;

type
  TIdSoapInterfaceCrossFile = Class (TIdSoapInterfaceLevel0, IIdSoapInterfaceCrossFile)
  published
    function Level1(Depth: Integer): Integer; stdcall;
  end;

implementation

{ TIdSoapInterfaceCrossFile }

function TIdSoapInterfaceCrossFile.Level1(Depth: Integer): Integer;
begin
  Check(Depth = 11,'Incorrect inheritance depth for Level 1');
  result := 11;
end;

Initialization
  IdSoapRegisterInterfaceClass('IIdSoapInterfaceCrossFile', TypeInfo(TIdSoapInterfaceCrossFile), TIdSoapInterfaceCrossFile);
end.
