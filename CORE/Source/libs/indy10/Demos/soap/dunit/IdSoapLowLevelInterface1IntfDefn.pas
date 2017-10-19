{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16417: IdSoapLowLevelInterface1IntfDefn.pas 
{
{   Rev 1.0    25/2/2003 13:28:32  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  09-Oct 2002   Andrew Cumming                  First added
}

unit IdSoapLowLevelInterface1IntfDefn;

interface

uses
  IdSoapLowLevelInterfaceIntfDefn,
  IdSoapTypeRegistry;

type
  IIdSoapInterfaceCrossFile = Interface(IIdSoapInterfaceLevel0) ['{BD92C535-2F50-4EAF-9D04-AC351F472CBC}']
  {!namespace: http://www.kestral.com.au/test/alternate1}   { needed to prevent clash with IIdSoapInterfaceLevel1.Level1 }
    function Level1(Depth: Integer): Integer; stdcall;
  end;

implementation

end.
