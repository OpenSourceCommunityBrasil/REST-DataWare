unit uRESTDWZAnalyser;

{$I ..\..\Includes\uRESTDW.inc}

{$IFNDEF RESTDWLAZARUS}
  {$I ZDbc.inc}
{$ENDIF}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

{$IFNDEF ZEOS_DISABLE_RESTDW}

uses Classes, ZGenericSqlAnalyser;

type

  {** Implements an RESTDW statements analyser. }
  TZRESTDWStatementAnalyser = class (TZGenericStatementAnalyser)
  public
    constructor Create;
  end;

{$ENDIF ZEOS_DISABLE_RESTDW}

implementation

{$IFNDEF ZEOS_DISABLE_RESTDW}

const
  {** The generic constants.}
  RESTDWSectionNames: array[0..11] of string = (
    'SELECT', 'UPDATE', 'DELETE', 'INSERT', 'FROM',
    'WHERE', 'INTO', 'GROUP*BY', 'HAVING', 'ORDER*BY',
    'OFFSET', 'LIMIT'
  );
  RESTDWSelectOptions: array[0..1] of string = (
    'DISTINCT', 'ALL'
  );
  RESTDWFromJoins: array[0..7] of string = (
    'NATURAL', 'RIGHT', 'LEFT', 'FULL', 'INNER', 'OUTER', 'JOIN', 'CROSS'
  );
  RESTDWFromClauses: array[0..1] of string = (
    'ON', 'USING'
  );

{ TZRESTDWStatementAnalyser }

{**
  Creates the object and assignes the main properties.
}
constructor TZRESTDWStatementAnalyser.Create;
begin
  SectionNames := ArrayToStrings(RESTDWSectionNames);
  SelectOptions := ArrayToStrings(RESTDWSelectOptions);
  FromJoins := ArrayToStrings(RESTDWFromJoins);
  FromClauses := ArrayToStrings(RESTDWFromClauses);
end;

{$ENDIF ZEOS_DISABLE_RESTDW}
end.

