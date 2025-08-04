unit uRESTDWIdReg;

{$I ..\..\Includes\uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
  de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
  Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
  de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  A. Brito                   - Admin - Administrador do desenvolvimento.
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Fl�vio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}

interface

uses
  {$IFDEF RESTDWLAZARUS}
    StdCtrls, ComCtrls, Forms, ExtCtrls, DBCtrls, DBGrids, Dialogs, Controls,
    LResources, LazFileUtils,
    {$IFNDEF RESTDWLAMW}
    FormEditingIntf, PropEdits, lazideintf,
    ProjectIntf, ComponentEditors,
    {$ENDIF}
  fpWeb,
  {$ELSE}
    {$IFNDEF DELPHIXE2UP}
      Graphics,
      DbTables,
    {$ENDIF}
    DesignIntf, DesignEditors,
  {$ENDIF}
  Classes, uRESTDWIdBase;

{$IFNDEF RESTDWLAMW}
Type
  TPoolersList = Class(TStringProperty)
  Public
    Function GetAttributes: TPropertyAttributes; Override;
    Procedure GetValues(Proc: TGetStrProc); Override;
    Procedure Edit; Override;
  End;
{$ENDIF}

Procedure Register;

Implementation

{$IFNDEF RESTDWLAMW}
Function TPoolersList.GetAttributes: TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
  Result := [paValueList, paSortList];
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

Procedure TPoolersList.GetValues(Proc: TGetStrProc);
Var
  vLista: TStringList;
  I: Integer;
Begin
  // Provide a list of Poolers
  With GetComponent(0) as TRESTDWIdDatabase Do
  Begin
    Try
      vLista := TRESTDWIdDatabase(GetComponent(0)).PoolerList;
      For I := 0 To vLista.Count - 1 Do
        Proc(vLista[I]);
    Except
    End;
  End;
End;
{$ENDIF}

Procedure Register;
Begin
 RegisterComponents    ('REST Dataware - Service', [TRESTDWIdServicePooler, TRESTDWIdProxyRequest, TRESTDWIdPoolerList]);
 RegisterComponents    ('REST Dataware - Client',  [TRESTDWIdClientREST,    TRESTDWIdClientPooler]);
 RegisterComponents    ('REST Dataware - DB',      [TRESTDWIdDatabase]);
 {$IFNDEF RESTDWLAMW}
 RegisterPropertyEditor(TypeInfo(String),           TRESTDWIdDatabase,      'PoolerName',         TPoolersList);
 {$ENDIF}
End;

{$IFDEF RESTDWLAZARUS}
initialization
{$I RESTDWIndySockets.lrs}
{$ENDIF}

end.
