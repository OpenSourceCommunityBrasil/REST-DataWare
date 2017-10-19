{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16402: IdSoapInterfaceTestsServer.pas 
{
{   Rev 1.0    25/2/2003 13:27:58  GGrieve
}
{
Version History:
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit testing
   7-May 2002   Andrew Cumming                  Added resource additions
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  12-Apr 2002   Andrew Cumming                  New interface registration for multi-interface tests
  08-Apr 2002   Grahame Grieve                  Binary Properties and Objects by reference tests
  04-Apr 2002   Grahame Grieve                  IdSoapServer.Active
  29-Mar 2002   Grahame Grieve                  Add tests relating to object lifetime management (will force fix of server leaks)
  26-Mar 2002   Grahame Grieve                  Change to direct client
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
  11-Feb 2002   Andrew Cumming                  First added file
}

Unit IdSoapInterfaceTestsServer;

{$I IdSoapDefines.inc}

Interface

uses
  IdSoapClient,
  IdSoapServer,
  IdSoapTypeRegistry,
  TestExtensions;

var
  GTestClient : TIdSoapBaseClient;
  GTestClient2 : TIdSoapBaseClient;
  GTestServerKeepAlive : boolean;
  GServerObject : TIdBaseSoapableClass;
  GServer : TIdSoapServer;
  GInDocumentMode : boolean;
  
type
  TIdSoapInterfaceTestsServerSetup = class (TTestSetup)
  protected
    procedure Setup; override;
    procedure TearDown; override;
  end;


Implementation

uses
  SysUtils,
  IdSoapClientDirect,
  IdSoapInterfaceTestsIntfImpl,
  IdSoapMultipleIntfImpl,
  IdSoapITIProvider,
  IdSoapUtilities;

{ TIdSoapInterfaceTestsServerSetup }

procedure TIdSoapInterfaceTestsServerSetup.Setup;
begin
  GServer := TIdSoapServer.Create(NIL);
  GServer.ITISource := islResource;
  GServer.ITIResourceName := 'IdSoapInterfaceTests';
  GServer.Active := true;
  GTestClient := TIdSoapClientDirect.create(nil);
  (GTestClient as TIdSoapClientDirect).SoapServer := GServer;
  GTestClient.ITISource := islResource;
  GTestClient.ITIResourceName := 'IdSoapInterfaceTests';
  GTestClient2 := TIdSoapClientDirect.create(nil);
  (GTestClient2 as TIdSoapClientDirect).SoapServer := GServer;
  GTestClient2.ITISource := islResource;
  GTestClient2.ITIResourceName := 'IdSoapInterfaceTests';
end;

procedure TIdSoapInterfaceTestsServerSetup.TearDown;
begin
  FreeAndNil(GTestClient);
  FreeAndNil(GTestClient2);
  FreeAndNil(GServer);
end;

end.
