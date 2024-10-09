unit uRESTDW.System;

{$INCLUDE 'uRESTDW.inc'}

interface

{$IFDEF FPC}
 {$MODE Delphi}
Uses
  Classes, SysUtils;
{$ENDIF}

type
  { Abstract base class for classes that can implement interfaces, but are not
    reference counted (unless on ARC systems of course). If you want your class
    to be reference counted, derive from TInterfacedObject instead. }
  TRESTDWNonRefCountedObject = {$IFNDEF FPC}class abstract(TObject){$ELSE}class(TInterfacedObject){$ENDIF}
  {$REGION 'Internal Declarations'}
  protected
    { IInterface }
   {$IFNDEF FPC}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
   {$ELSE}
    function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} iid : tguid;out obj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
   {$ENDIF}
  {$ENDREGION 'Internal Declarations'}
  end;

implementation

{ TRESTDWNonRefCountedObject }

{$IFNDEF FPC}
function TRESTDWNonRefCountedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
{$ELSE}
function TRESTDWNonRefCountedObject.QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} iid : tguid;out obj) : Longint;
{$ENDIF}
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

{$IFNDEF FPC}
function TRESTDWNonRefCountedObject._AddRef: Integer;
{$ELSE}
function TRESTDWNonRefCountedObject._AddRef : longint;
{$ENDIF}
begin
  Result := -1;
end;

{$IFNDEF FPC}
function TRESTDWNonRefCountedObject._Release: Integer;
{$ELSE}
function TRESTDWNonRefCountedObject._Release : longint;
{$ENDIF}
begin
  Result := -1;
end;

end.
