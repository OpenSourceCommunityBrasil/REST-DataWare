unit JvPropertyStoreEditorIntf;
{$I ..\..\Source\Includes\uRESTDWPlataform.inc}
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
}

interface
uses
  Classes;
type
  IJvPropertyEditorHandler = interface
    ['{7DD4CC1F-335E-44F7-AE90-9DB630BF5B31}']
    function EditIntf_GetVisibleObjectName : string;
    function EditIntf_TranslatePropertyName (const PropertyName : string) : string;
    function EditIntf_GetObjectHint : string;
    function EditIntf_GetPropertyHint(const PropertyName : string) : string;
    function EditIntf_DisplayProperty (const PropertyName : string) : Boolean;
    function EditIntf_IsPropertySimple (const PropertyName : string) : Boolean;
  end;
  IJvPropertyListEditorHandler = interface
    ['{BC1F664F-867F-4041-B718-0FD76A0CA3E8}']
    function ListEditIntf_ObjectCount : integer;
    function ListEditIntf_GetObject(Index : integer): TPersistent;
    function ListEditIntf_IndexOfObject(AObject : TPersistent) : Integer;
    procedure ListEditIntf_MoveObjectPosition (Index : Integer; PosDelta : Integer);
    procedure ListEditIntf_SortObjects (iAscending : Boolean);
    function ListEditIntf_CreateNewObject: TPersistent;
    function ListEditIntf_CloneNewObject(Index : integer): TPersistent;
    procedure ListEditIntf_DeleteObject (Index : integer);
  end;
{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JVCL\run'
  );
{$ENDIF UNITVERSIONING}
implementation

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);
finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.