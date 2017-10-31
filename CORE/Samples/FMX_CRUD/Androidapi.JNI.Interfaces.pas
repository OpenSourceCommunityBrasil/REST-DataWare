{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{ Copyright(c) 2014 Embarcadero Technologies, Inc.      }
{                                                       }
{*******************************************************}

unit Androidapi.JNI.Interfaces;

interface

uses
  Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Widget,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Util,
  Androidapi.JNI.Os,
  Androidapi.JNI.Net,
  Androidapi.JNI.App;

type
// ===== Forward declarations =====

  JListActivity = interface;//android.app.ListActivity
  JFileDialog = interface;//com.lamerman.FileDialog
  JFileDialog_1 = interface;//com.lamerman.FileDialog$1
  JFileDialog_2 = interface;//com.lamerman.FileDialog$2
  JFileDialog_3 = interface;//com.lamerman.FileDialog$3
  JFileDialog_4 = interface;//com.lamerman.FileDialog$4
  JFileDialog_5 = interface;//com.lamerman.FileDialog$5
  JSelectionMode = interface;//com.lamerman.SelectionMode

// ===== Interface declarations =====

  JListActivityClass = interface(JActivityClass)
    ['{CBFA42B6-76C6-4853-89DE-B5C9FEE07AF7}']
    {class} function init: JListActivity; cdecl;
  end;

  [JavaSignature('android/app/ListActivity')]
  JListActivity = interface(JActivity)
    ['{B3B8B015-85F0-41D8-9C51-BCECD5E105B7}']
    function getListAdapter: JListAdapter; cdecl;
    function getListView: JListView; cdecl;
    function getSelectedItemId: Int64; cdecl;
    function getSelectedItemPosition: Integer; cdecl;
    procedure onContentChanged; cdecl;
    procedure setListAdapter(adapter: JListAdapter); cdecl;
    procedure setSelection(position: Integer); cdecl;
  end;
  TJListActivity = class(TJavaGenericImport<JListActivityClass, JListActivity>) end;

  JFileDialogClass = interface(JListActivityClass)
    ['{15DDF1B3-5204-4127-BB7B-171DFA8D9F93}']
    {class} function _GetCAN_SELECT_DIR: JString;
    {class} function _GetFORMAT_FILTER: JString;
    {class} function _GetRESULT_PATH: JString;
    {class} function _GetSELECTION_MODE: JString;
    {class} function _GetSTART_PATH: JString;
    {class} function init: JFileDialog; cdecl;
    {class} property CAN_SELECT_DIR: JString read _GetCAN_SELECT_DIR;
    {class} property FORMAT_FILTER: JString read _GetFORMAT_FILTER;
    {class} property RESULT_PATH: JString read _GetRESULT_PATH;
    {class} property SELECTION_MODE: JString read _GetSELECTION_MODE;
    {class} property START_PATH: JString read _GetSTART_PATH;
  end;

  [JavaSignature('com/lamerman/FileDialog')]
  JFileDialog = interface(JListActivity)
    ['{979DFF7A-E98F-4CFE-9AE8-77EF88F5017E}']
    procedure onCreate(P1: JBundle); cdecl;
    function onKeyDown(P1: Integer; P2: JKeyEvent): Boolean; cdecl;
  end;
  TJFileDialog = class(TJavaGenericImport<JFileDialogClass, JFileDialog>) end;

  JFileDialog_1Class = interface(JObjectClass)
    ['{2B97B2FD-B582-4EB7-B5E6-2998001547AD}']
  end;

  [JavaSignature('com/lamerman/FileDialog$1')]
  JFileDialog_1 = interface(JObject)
    ['{096DE301-7698-4C5A-AE49-7B0B779CAEFD}']
    procedure onClick(P1: JView); cdecl;
  end;
  TJFileDialog_1 = class(TJavaGenericImport<JFileDialog_1Class, JFileDialog_1>) end;

  JFileDialog_2Class = interface(JObjectClass)
    ['{88EDB944-4E8D-43BE-8F18-D07971066BFF}']
  end;

  [JavaSignature('com/lamerman/FileDialog$2')]
  JFileDialog_2 = interface(JObject)
    ['{15672130-74B0-4C9A-85F2-A38AF7A4340F}']
    procedure onClick(P1: JView); cdecl;
  end;
  TJFileDialog_2 = class(TJavaGenericImport<JFileDialog_2Class, JFileDialog_2>) end;

  JFileDialog_3Class = interface(JObjectClass)
    ['{1DD325CB-FA1E-4080-AE24-553BEFFC7CF7}']
  end;

  [JavaSignature('com/lamerman/FileDialog$3')]
  JFileDialog_3 = interface(JObject)
    ['{37AF2E8D-A195-4B7A-B395-5805473C8B5C}']
    procedure onClick(P1: JView); cdecl;
  end;
  TJFileDialog_3 = class(TJavaGenericImport<JFileDialog_3Class, JFileDialog_3>) end;

  JFileDialog_4Class = interface(JObjectClass)
    ['{600075B8-103D-4ACA-89B8-F2147D51FBD5}']
  end;

  [JavaSignature('com/lamerman/FileDialog$4')]
  JFileDialog_4 = interface(JObject)
    ['{3FAD73F7-66EC-4293-AABD-C00DF6A4CC74}']
    procedure onClick(P1: JView); cdecl;
  end;
  TJFileDialog_4 = class(TJavaGenericImport<JFileDialog_4Class, JFileDialog_4>) end;

  JFileDialog_5Class = interface(JObjectClass)
    ['{C2C08B4A-9BEF-4EC2-AFE4-A52B485977F4}']
  end;

  [JavaSignature('com/lamerman/FileDialog$5')]
  JFileDialog_5 = interface(JObject)
    ['{36ED0F02-A5FC-446A-9F65-FD945277E8B9}']
    procedure onClick(P1: JDialogInterface; P2: Integer); cdecl;
  end;
  TJFileDialog_5 = class(TJavaGenericImport<JFileDialog_5Class, JFileDialog_5>) end;

  JSelectionModeClass = interface(JObjectClass)
    ['{EB30474F-6DA3-4775-AA58-EB8354B584A8}']
    {class} function _GetMODE_CREATE: Integer;
    {class} function _GetMODE_OPEN: Integer;
    {class} function init: JSelectionMode; cdecl;
    {class} property MODE_CREATE: Integer read _GetMODE_CREATE;
    {class} property MODE_OPEN: Integer read _GetMODE_OPEN;
  end;

  [JavaSignature('com/lamerman/SelectionMode')]
  JSelectionMode = interface(JObject)
    ['{88293D28-7E34-4FD1-8FFF-3B23A31064A9}']
  end;
  TJSelectionMode = class(TJavaGenericImport<JSelectionModeClass, JSelectionMode>) end;

implementation

procedure RegisterTypes;
begin
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JListActivity', TypeInfo(Androidapi.JNI.Interfaces.JListActivity));
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JFileDialog', TypeInfo(Androidapi.JNI.Interfaces.JFileDialog));
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JFileDialog_1', TypeInfo(Androidapi.JNI.Interfaces.JFileDialog_1));
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JFileDialog_2', TypeInfo(Androidapi.JNI.Interfaces.JFileDialog_2));
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JFileDialog_3', TypeInfo(Androidapi.JNI.Interfaces.JFileDialog_3));
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JFileDialog_4', TypeInfo(Androidapi.JNI.Interfaces.JFileDialog_4));
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JFileDialog_5', TypeInfo(Androidapi.JNI.Interfaces.JFileDialog_5));
  TRegTypes.RegisterType('Androidapi.JNI.Interfaces.JSelectionMode', TypeInfo(Androidapi.JNI.Interfaces.JSelectionMode));
end;

initialization
  RegisterTypes;
end.


