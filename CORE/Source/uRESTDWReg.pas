unit uRESTDWReg;

interface

uses
  {$IFDEF FPC}
   {$IFNDEF UNIX}Windows,
   {$ELSE}Lcl,{$ENDIF}LResources, SysUtils, FormEditingIntf, PropEdits, lazideintf, ComponentEditors, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents;
  {$ELSE}
   Windows, SysUtils,
   {$if CompilerVersion > 21}
    ToolsApi, DMForm, DesignEditors, DesignIntf, ExptIntf, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents, Db, DSDesign, ColnEdit;
   {$ELSE}
    ToolsApi, DMForm, DesignEditors, DesignIntf, ExptIntf, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents, Db, DbTables, DSDesign, ColnEdit;
   {$IFEND}
  {$ENDIF}

Type
 TAddFields = Procedure (All: Boolean) of Object;

Type
 TPoolersList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

type
 TDWServerEventsEditor = Class(TComponentEditor)
  Function GetVerbCount : Integer; Override;
  Function GetVerb     (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;

Type
 TDWClientEventsEditor = Class(TComponentEditor)
  Function GetVerbCount : Integer; Override;
  Function GetVerb     (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;

{$IFNDEF FPC}
Type
 TDSDesignerDW = Class(TDSDesigner)
 Private
  vOldState : Boolean;
 Public
  {$if CompilerVersion > 21}
  Function  DoCreateField(const FieldName: WideString; Origin: string): TField; override;
  {$ELSE}
  Function  DoCreateField(const FieldName: String; Origin: string): TField; override;
  {$IFEND}
End;

Type
 TRESTDWClientSQLEditor = Class(TComponentEditor)
 Private
 Public
  Procedure Edit; override;
  Function  GetVerbCount : Integer; Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;
{$ENDIF}

Procedure Register;

implementation


{$IFNDEF FPC}
procedure TRESTDWClientSQLEditor.Edit;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion < 21}
   TRESTDWClientSQL(Component).Close;
   TRESTDWClientSQL(Component).CreateDatasetFromList;
  {$IFEND}
 {$ENDIF}
 ShowFieldsEditor(Designer, TDataSet(Component), TDSDesignerDW);
end;

procedure TRESTDWClientSQLEditor.ExecuteVerb(Index: Integer);
 Procedure EditFields(DataSet: TDataSet);
 begin
  {$IFNDEF FPC}
   {$IF CompilerVersion < 21}
    TRESTDWClientSQL(DataSet).Close;
    TRESTDWClientSQL(DataSet).CreateDatasetFromList;
   {$IFEND}
  {$ENDIF}
  ShowFieldsEditor(Designer, TDataSet(Component), TDSDesignerDW);
 End;
Begin
 Case Index of
  0 : EditFields(TDataSet(Component));
 End;
end;

Function TRESTDWClientSQLEditor.GetVerb(Index: Integer): String;
Begin
 Case Index Of
  0 : Result := 'Fields Edi&tor';
 End;
End;

Function TRESTDWClientSQLEditor.GetVerbCount: Integer;
Begin
 Result := 1;
End;

{$if CompilerVersion > 21}
Function  TDSDesignerDW.DoCreateField(const FieldName: WideString; Origin: string): TField;
{$ELSE}
Function  TDSDesignerDW.DoCreateField(const FieldName: String; Origin: string): TField;
{$IFEND}
Var
 FieldDefinition : TFieldDefinition;
Begin
 Result := Nil;
 Try
  If TRESTDWClientSQL(DataSet).FieldListCount > 0 Then
   Begin
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      TRESTDWClientSQL(DataSet).Close;
      TRESTDWClientSQL(DataSet).CreateDatasetFromList;
     {$IFEND}
    {$ENDIF}
    If TRESTDWClientSQL(DataSet).FieldDefExist(FieldName) <> Nil Then
     Result := Inherited DoCreateField(FieldName, Origin);
   End;
 Finally
 End;
End;
{$ENDIF}

Function TPoolersList.GetAttributes : TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
End;

procedure TPoolersList.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
end;

Procedure TPoolersList.GetValues(Proc : TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
Begin
 //Provide a list of Poolers
 vLista := Nil;
 With GetComponent(0) as TRESTDWDataBase Do
  Begin
   Try
    vLista := TRESTDWDataBase(GetComponent(0)).GetRestPoolers;
    For I := 0 To vLista.Count -1 Do
     Proc (vLista[I]);
   Except
   End;
   If vLista <> Nil Then
    vLista.Free;
  End;
End;

Procedure Register;
Begin
 {$IFNDEF FPC}
  RegisterNoIcon([TServerMethodDataModule]);
  RegisterCustomModule(TServerMethodDataModule, TCustomModule); //TDataModuleDesignerCustomModule);
 {$ELSE}
  FormEditingHook.RegisterDesignerBaseClass(TServerMethodDataModule);
 {$ENDIF}
 RegisterComponents('REST Dataware - Service',     [TRESTServicePooler, TDWServerEvents, TRESTServiceCGI,  TDWClientEvents,    TRESTClientPooler]);
 RegisterComponents('REST Dataware - CORE - DB',   [TRESTDWPoolerDB,    TRESTDWDataBase, TRESTDWClientSQL, TDWMassiveSQLCache, TRESTDWStoredProc, TRESTDWPoolerList, TDWMassiveCache]);
 RegisterPropertyEditor(TypeInfo(String), TRESTDWDataBase, 'PoolerName', TPoolersList);
 RegisterComponentEditor(TDWServerEvents, TDWServerEventsEditor);
 RegisterComponentEditor(TDWClientEvents,  TDWClientEventsEditor);
 {$IFNDEF FPC}
 RegisterComponentEditor(TRESTDWClientSQL, TRESTDWClientSQLEditor);
 {$ENDIF}
End;

{ TDWServerEventsEditor }

procedure TDWServerEventsEditor.ExecuteVerb(Index: Integer);
begin
  inherited;
  case Index of
    0 : Begin
         {$IFNDEF FPC}
          ShowCollectionEditor(Designer, Component, (Component as TDWServerEvents).Events, 'Events');
         {$ELSE}
          TCollectionPropertyEditor.ShowCollectionEditor(TDWServerEvents(Component).Events, Component, 'Events');
         {$ENDIF}
        End;
  end;
end;

function TDWServerEventsEditor.GetVerb(Index: Integer): String;
begin
  case Index of
    0: Result := 'Events &List';
  end;
end;

function TDWServerEventsEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TDWClientEventsEditor }

procedure TDWClientEventsEditor.ExecuteVerb(Index: Integer);
begin
  inherited;
  case Index of
    // Procedure in the unit ColnEdit.pas
    0: Begin
        {$IFNDEF FPC}
         ShowCollectionEditor(Designer, Component, TDWClientEvents(Component).Events, 'Events');
        {$ELSE}
         TCollectionPropertyEditor.ShowCollectionEditor(TDWClientEvents(Component).Events,Component, 'Events');
        {$ENDIF}
       End;
    1: (Component as TDWClientEvents).GetEvents := True;
    2: (Component as TDWClientEvents).ClearEvents;
  end;
end;

function TDWClientEventsEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Events &List';
    1: Result := '&Get Server Events';
    2: Result := '&Clear Client Events';
  end;
end;

function TDWClientEventsEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

initialization
{$IFDEF FPC}
{$I resteasyobjectscore.lrs}
{$ELSE}
{$if CompilerVersion < 21}
 {$R ..\Packages\Delphi\D7\RestEasyObjectsCORE.dcr}
{$IFEND}
UnlistPublishedProperty(TRESTDWClientSQL, 'CachedUpdates');
{$ENDIF}

end.
