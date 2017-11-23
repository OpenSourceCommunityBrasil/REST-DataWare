unit USQL_Constantes;

interface

uses
  MainModule, System.SysUtils;

const
  SQL_INSERT_TRANSPORTADORA = 'select * from TRANSPORTADORA where ID = :ID';
  SQL_SELECT_TRANSPORTADORA = 'select * from TRANSPORTADORA where NOME like :NOME ' +
  'AND CNPJ like :CNPJ';

implementation


end.
