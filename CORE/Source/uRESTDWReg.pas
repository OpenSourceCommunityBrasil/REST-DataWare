unit uRESTDWReg;

interface

uses
  {$IFDEF FPC}
   {$IFNDEF UNIX}Windows,
   {$ELSE}Lcl,{$ENDIF}LResources, FormEditingIntf, Classes, propedits, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents;
  {$ELSE}
   Windows,
   {$if CompilerVersion > 21}
    ToolsApi, DMForm, DesignEditors, DesignIntf, ExptIntf, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents;
   {$ELSE}
    ToolsApi, DMForm, DesignEditors, DesignIntf, ExptIntf, Classes, uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents;
   {$IFEND}
  {$ENDIF}

{$IFNDEF FPC}

{$ENDIF}

Type
 TPoolersList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;


Procedure Register;

implementation

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
 RegisterComponents('REST Dataware - Service',     [TRESTServicePooler, TDWServerEvents, TDWClientEvents,  TRESTServiceCGI,   TRESTClientPooler]);
 RegisterComponents('REST Dataware - CORE - DB',   [TRESTDWPoolerDB,    TRESTDWDataBase, TRESTDWClientSQL, TRESTDWStoredProc, TRESTDWPoolerList, TDWMassiveCache]);
 RegisterPropertyEditor(TypeInfo(String), TRESTDWDataBase, 'PoolerName', TPoolersList);
End;

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
