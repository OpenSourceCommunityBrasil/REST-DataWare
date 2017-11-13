unit USQL;

interface

type
   TSql = class
     class function getSql(Tabela: string; intTipo: Integer): string;
   end;

implementation

uses
  USQL_Constantes;

{ TSql }

class function TSql.getSql(Tabela: string; intTipo: Integer): string;
begin
  if Tabela = 'TRANSPORTADORA' then
  begin
     if intTipo = 1 then
        Result := SQL_INSERT_TRANSPORTADORA;
     if intTipo = 2 then
        Result := SQL_SELECT_TRANSPORTADORA;
  end;
end;

end.
