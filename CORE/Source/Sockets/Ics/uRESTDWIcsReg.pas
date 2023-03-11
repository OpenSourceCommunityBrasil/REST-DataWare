unit uRESTDWIcsReg;

{$I ..\..\..\Source\Includes\uRESTDW.inc}
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
  A. Brito                   - Admin - Administrador do desenvolvimento.
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
  Flávio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}

interface

uses
  Classes, DesignIntf, DesignEditors,
  uRESTDWIcsBase;

Type
  TPoolersList = Class(TStringProperty)
  Public
    Function GetAttributes: TPropertyAttributes; Override;
    Procedure GetValues(Proc: TGetStrProc); Override;
    Procedure Edit; Override;
  End;

Procedure Register;

Implementation

Function TPoolersList.GetAttributes: TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
  Result := [paValueList, paSortList];
End;

procedure TPoolersList.GetValues(Proc: TGetStrProc);
Var
  vLista: TStringList;
  I: Integer;
Begin
  // Provide a list of Poolers
  // With GetComponent(0) as TRESTDWIcsDatabase Do
  // Begin
  // Try
  // vLista := TRESTDWIcsDatabase(GetComponent(0)).PoolerList;
  // For I := 0 To vLista.Count - 1 Do
  // Proc(vLista[I]);
  // Except
  // End;
  // End;
End;

Procedure TPoolersList.Edit;
Var
  vTempData: String;
Begin
  Inherited Edit;
  Try
    vTempData := GetValue;
    SetValue(vTempData);
  Finally
  End;
end;

Procedure Register;
Begin
  RegisterComponents('REST Dataware - Service', [TRESTDWIcsServicePooler]);
End;

initialization

Finalization

end.
