{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16421: IdSoapLowLevelInterfaceIntfDefn.pas 
{
{   Rev 1.0    25/2/2003 13:28:44  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  09-Oct 2002   Andrew Cumming                  First added
}

unit IdSoapLowLevelInterfaceIntfDefn;

interface

uses
  IdSoapTypeRegistry;

type
  IIdSoapInterfaceLevel0 = Interface(IIdSoapInterface) ['{0C45818A-A021-4F34-B973-43034FBE701F}']
    function Level0(Depth: Integer): Integer; stdcall;
  end;

  IIdSoapInterfaceLevel1 = Interface(IIdSoapInterfaceLevel0) ['{35E2A758-F7DC-4163-AEE0-9EE47EEBB53C}']
    function Level1(Depth: Integer): Integer; stdcall;
  end;

  IIdSoapInterfaceLevel2 = Interface(IIdSoapInterfaceLevel1) ['{41552C5D-8180-4884-94F1-148A83130001}']
    function Level2(Depth: Integer): Integer; stdcall;
  end;

  IIdSoapInterfaceCrosslink1 = Interface(IIdSoapInterfaceLevel0) ['{7E4BDD5E-839A-4460-BCAF-B2E0A14CB722}']
  {!namespace: http://www.kestral.com.au/test/alternate}   { needed to prevent clash with IIdSoapInterfaceLevel1.Level1 }
    function Level1(Depth: Integer): Integer; stdcall;
  end;

  IIdSoapInterfaceCrosslink2 = Interface(IIdSoapInterfaceLevel0) ['{B79B819C-675C-4AEC-887C-9831F3473EB4}']
    function Level1a(Depth: Integer): Integer; stdcall;
  end;

implementation

{$R IdSoapLowLevelInterfaceTests.res}

end.
