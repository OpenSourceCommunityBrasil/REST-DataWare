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
 pasta       = 'D:\Meus Dados\Projetos\SUGV\Componentes\XyberPower\REST_Controls\DEMO';
 porta_BD    = 3050;
 usuario_BD  = 'sysdba';
 senha_BD    = 'masterkey';
 LogFile     = 'D:\Meus Dados\Projetos\SUGV\Componentes\XyberPower\REST_Controls\DEMO\WindowsService\Log.txt';

Var
 RESTServicePooler : TRESTServicePooler;

implementation

Initialization
 RESTServicePooler := TRESTServicePooler.Create(Nil);

Finalization
 RESTServicePooler.Active := False;
 RESTServicePooler.DisposeOf;

end.
