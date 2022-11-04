Unit uRESTDWCustom;

{$I ..\Includes\uRESTDWPlataform.inc}

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
 Fernando Banhos            - Drivers e Datasets.
}

Interface

Uses
 Classes,  SysUtils, uRESTDWConsts, uRESTDWPhysicBase, Db;

 Type
  TCustomdwMemtable = Class(TDataSet)
 Protected
  Procedure   InternalPost;             Override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
  Procedure   InternalOpen;             Override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Open
  Function    GetRecordCount : Integer; Override;
  Procedure   InternalRefresh;          Override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Refresh
  Procedure   CloseCursor;              Override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Close
 Private
  vIndexFieldNames,
  vIndexName,
  vMasterFields : String;
  vIndexDefs    : TIndexDefs;
  vPhysicDriver : TRESTDWPhysicBase;
 Public
  Procedure CreateDataset;Virtual;
  Procedure CleanData;    Virtual;
  Procedure SetIndexFieldNames(aIndexFieldNames  : String); Virtual;
  Procedure SetIndexDefs      (aIndexDefs        : String); Virtual;
  Procedure SetIndexName      (aIndexName        : String); Virtual;
  Procedure SetMasterFields   (aIndexFieldNames  : String); Virtual;
  Procedure LoadFromStream    (aStream           : TStream);Virtual;
  Procedure SaveToStream      (Var aStream       : TStream);Virtual;
  Procedure SortOn            (Const AFieldNames : String = '';
                               ACaseInsensitive  : Boolean = True;
                               ADescending       : Boolean = False); Overload;
  Constructor Create(AOwner        : TComponent);Override;
  Destructor  Destroy;    Override;
 Published
  Property IndexDefs       : TIndexDefs        Read vIndexDefs       Write vIndexDefs;
  Property PhysicDriver    : TRESTDWPhysicBase Read vPhysicDriver    Write vPhysicDriver;
  Property IndexFieldNames : String            Read vIndexFieldNames Write vIndexFieldNames;
  Property IndexName       : String            Read vIndexName       Write vIndexName;
  Property MasterFields    : String            Read vMasterFields    Write vMasterFields;
 End;

Implementation

Procedure TCustomdwMemtable.CleanData;
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['CleanData']));
End;

Procedure TCustomdwMemtable.CloseCursor;
Begin
 If Not Assigned(vPhysicDriver) Then
  Raise Exception.Create(cSetPhysicDriver)
 Else
  Inherited;
End;

Constructor TCustomdwMemtable.Create(AOwner: TComponent);
Begin
 Inherited;
 vPhysicDriver := Nil;
 vIndexDefs    := TIndexDefs.Create(Self);
End;

Procedure TCustomdwMemtable.CreateDataset;
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['CreateDataset']));
End;

Destructor TCustomdwMemtable.Destroy;
Begin
 FreeAndNil(vIndexDefs);
 Inherited;
End;

Function TCustomdwMemtable.GetRecordCount : Integer;
Begin
 If Not Assigned(vPhysicDriver) Then
  Raise Exception.Create(cSetPhysicDriver)
 Else
  Result := 0;
End;

Procedure TCustomdwMemtable.InternalOpen;
Begin
 If Not Assigned(vPhysicDriver) Then
  Raise Exception.Create(cSetPhysicDriver)
 Else
  Inherited;
End;

Procedure TCustomdwMemtable.InternalPost;
Begin
 If Not Assigned(vPhysicDriver) Then
  Raise Exception.Create(cSetPhysicDriver)
 Else
  Inherited;
End;

Procedure TCustomdwMemtable.InternalRefresh;
Begin
 If Not Assigned(vPhysicDriver) Then
  Raise Exception.Create(cSetPhysicDriver)
 Else
  Inherited;
End;

Procedure TCustomdwMemtable.LoadFromStream(aStream : TStream);
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['LoadFromStream']));
End;

Procedure TCustomdwMemtable.SaveToStream(Var aStream: TStream);
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['SaveToStream']));
End;

Procedure TCustomdwMemtable.SetIndexDefs(aIndexDefs: String);
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['SetIndexDefs']));
End;

Procedure TCustomdwMemtable.SetIndexFieldNames(aIndexFieldNames: String);
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['SetIndexFieldNames']));
End;

Procedure TCustomdwMemtable.SetIndexName(aIndexName: String);
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['SetIndexName']));
End;

Procedure TCustomdwMemtable.SetMasterFields(aIndexFieldNames: String);
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['SetMasterFields']));
End;

Procedure TCustomdwMemtable.SortOn(Const AFieldNames : String;
                                   ACaseInsensitive,
                                   ADescending       : Boolean);
Begin
 Raise Exception.Create(Format(cInvalidVirtualMethod, ['SortOn']));
End;

End.
