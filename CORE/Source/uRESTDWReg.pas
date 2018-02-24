unit uRESTDWReg;

interface

uses
  {$IFDEF FPC}
   {$IFNDEF UNIX}Windows,
   {$ELSE}Lcl,{$ENDIF}LResources, SysUtils, FormEditingIntf, PropEdits, lazideintf, ComponentEditors, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents;
  {$ELSE}
   Windows, SysUtils,
   {$if CompilerVersion > 21}
    ToolsApi, DMForm, DesignEditors, DesignIntf, ExptIntf, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents, Db, DbTables, DSDesign;
   {$ELSE}
    ToolsApi, DMForm, DesignEditors, DesignIntf, ExptIntf, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents, Db, DbTables, DSDesign;
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
 ShowFieldsEditor(Designer, TDataSet(Component), TDSDesignerDW);
end;

procedure TRESTDWClientSQLEditor.ExecuteVerb(Index: Integer);
 Procedure EditFields(DataSet: TDataSet);
 begin
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
    TRESTDWClientSQL(DataSet).Close;
    TRESTDWClientSQL(DataSet).CreateDatasetFromList;
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
 RegisterComponentEditor(TDWClientEvents,  TDWClientEventsEditor);
 {$IFNDEF FPC}
 RegisterComponentEditor(TRESTDWClientSQL, TRESTDWClientSQLEditor);
 {$ENDIF}
End;

{ TDWClientEventsEditor }

procedure TDWClientEventsEditor.ExecuteVerb(Index: Integer);
begin
  inherited;
  case Index of
    0: (Component as TDWClientEvents).GetEvents := True; //chama o GetEvents
    1: (Component as TDWClientEvents).ClearEvents; //chama o GetEvents
  end;
end;

function TDWClientEventsEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Get Server Events';
    1: Result := '&Clear Client Events';
  end;
end;

function TDWClientEventsEditor.GetVerbCount: Integer;
begin
  Result := 2;
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
