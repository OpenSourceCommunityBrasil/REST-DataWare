unit uConsts;

interface

uses uRESTDWBase;

Const
 vUsername   = 'testserver';
 vPassword   = 'testserver';
 vPort       = 8092;
 servidor    = '127.0.0.1';
 EncodedData = True;
 SSLPrivateKeyFile = '';
 SSLPrivateKeyPassword = '';
 SSLCertFile           = '';
 database    = 'EMPLOYEE.FDB';
 pasta       = 'c:\basedados\';
 porta_BD    = 3050;
 usuario_BD  = 'sysdba';
 senha_BD    = 'masterkey';
 LogFile     = 'C:\CompXE_10_2\RESTDW\CORE\Demos\Log.txt';

Var
 RESTServicePooler : TRESTServicePooler;

implementation

Initialization
 RESTServicePooler := TRESTServicePooler.Create(Nil);

Finalization
 RESTServicePooler.Active := False;
 RESTServicePooler.DisposeOf;

end.
