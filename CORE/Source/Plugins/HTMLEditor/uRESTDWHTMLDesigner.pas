unit uRESTDWHTMLDesigner;

{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}

Interface
uses
  Classes, StrUtils, Types, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls,
 Dialogs,
 {$IFDEF FPC}
 LCLType, LCLIntf, LMessages, IniFiles, Menus, Grids, Graphics, Buttons, ImgList,
 Clipbrd,
 {$ELSE}
 Windows, Messages, IniFiles, Menus, Grids, Graphics, Buttons, ImgList,
 Clipbrd, ShellAPI, Registry,
 {$ENDIF}
 SysUtils,

 {$IFDEF FPC}
 SynEdit, SynEditTypes, SynEditMarks, SynHighlighterHtml, SynHighlighterCss,
 SynHighlighterJScript, SynHighlighterMulti,
 {$ELSE}
 uRESTDWPrivSynEdit, uRESTDWPrivSynEditTypes, uRESTDWPrivSynHighlighterHtml,
 uRESTDWPrivSynHighlighterCss, uRESTDWPrivSynHighlighterJScript,
 uRESTDWPrivSynHighlighterMulti,
 {$ENDIF}
 uRESTDWHTMLPageProducerAdapter, uRESTDWHTMLWebView,
 uRESTDWHTMLComponentManager, uRESTDWHTMLDesignerAI, uRESTDWHTMLDesignerIcons, uRESTDWHTMLWebAssets, uRESTDWHTMLIDECompat,
 uRESTDWHTMLJSONCompat, uRESTDWServerContext;
Type
 TRESTDWHTMLWebComponentInfo = Class
 Public
  Name : String;
  ClassName : String;
  PackageName : String;
  Category : String;
  JsFileName : String;
  HTML : String;
  HTMLExtension : String;
  IsVisual : Boolean;
  Placement : String;
  CSSFile : String;
  JSFile : String;
  IconFile : String;
  ExternalURL : String;
  LocalLibPath : String;
  FileName : String;
  Hint : String;
  Options : TStringList;
  Constructor Create;
  Destructor Destroy; Override;
 End;
 TRESTDWHTMLProjectNodeInfo = Class
 Public
  Name : String;
  SearchText : String;
 End;
 TRESTDWHTMLObjectBrowserNodeInfo = Class
 Public
  ElementID : String;
  TagName : String;
 End;
 TRESTDWHTMLDesignerForm = Class(TForm)
 Private
  FProducer : TRESTDWHTMLPageProducerAdapter;
  FComponents : TList;
  FGeneratedInstanceNames : TStringList;
  FDesignComponents : TList;
  FProjectItems : TList;
  FDesignMode : Boolean;
  FUpdating : Boolean;
  FSelectedInfo : TRESTDWHTMLWebComponentInfo;
  FInsertInfo : TRESTDWHTMLWebComponentInfo;
  FSelectedElementID : String;
  FSelectedElementTag : String;
  FSelectedElementOuterHTML : String;
  FPendingCodeElement : Boolean;
  FIgnoreNextInsertedSelection : Boolean;
  FPendingCodeTagName : String;
  FPendingCodeText : String;
  FPendingCodeID : String;
  FPendingCodeClass : String;
  FPendingCodeOuterHTML : String;
  FPageOptionsSelected : Boolean;
  FEditingEventCode : Boolean;
  FEventOriginalValues : TStringList;
  FSelectedFromCode : Boolean;
  FSelectedCodeTagStart : Integer;
  FSelectedCodeTagEnd : Integer;
  FUpdatingInspector : Boolean;
  FMenu : TMainMenu;
  FPaletteTabs : TPageControl;
  FWorkPanel : TPanel;
  FModeBar : TPanel;
  FFormDesignButton : TSpeedButton;
  FCodeEditorButton : TSpeedButton;
  FDesign : TScrollBox;
  FCodePages : TPageControl;
  FFullCodeTab : TTabSheet;
  FHTMLTab : TTabSheet;
  FCSSTab : TTabSheet;
  FJSTab : TTabSheet;
  FFullCode : TSynEdit;
  FHTML : TSynEdit;
  FCSS : TSynEdit;
  FJS : TSynEdit;
  FHTMLHighlighter : TSynHTMLSyn;
  FCSSHighlighter : TSynCssSyn;
  FJSHighlighter : TSynJScriptSyn;
  FFullHTMLHighlighter : TSynHTMLSyn;
  FFullCSSHighlighter : TSynCssSyn;
  FFullJSHighlighter : TSynJScriptSyn;
  FFullHighlighter : TSynMultiSyn;
  FPreviewPanel : TPanel;
  FPreviewHeader : TPanel;
  FPreviewFloatForm : TForm;
  FLeftDockHost : TPanel;
  FRightDockHost : TPanel;
  FObjectBrowserPanel : TPanel;
  FObjectBrowserHeader : TPanel;
  FObjectBrowserFloatForm : TForm;
  FObjectBrowserTree : TTreeView;
  FObjectBrowserImages : TImageList;
  FObjectBrowserSplitter : TSplitter;
  FUpdatingObjectBrowser : Boolean;
  FObjectBrowserSelectionID : String;
  FProjectPanel : TPanel;
  FProjectHeader : TPanel;
  FProjectSplitter : TSplitter;
  FProjectFloatForm : TForm;
  FProjectTree : TTreeView;
  FColorToolPanel : TPanel;
  FColorToolHeader : TPanel;
  FColorToolFloatForm : TForm;
  FColorPreview : TPanel;
  FColorR : TEdit;
  FColorG : TEdit;
  FColorB : TEdit;
  FColorHex : TEdit;
  FColorCopyHex : TButton;
  FColorCopyRGB : TButton;
  FUpdatingColor : Boolean;
  FInspectorPanel : TPanel;
  FInspectorHeader : TPanel;
  FInspectorSplitter : TSplitter;
  FInspectorFloatForm : TForm;
  FInspectorPages : TPageControl;
  FProperties : TStringGrid;
  FEvents : TStringGrid;
  FMessagesPanel : TPanel;
  FMessagesHeader : TPanel;
  FMessagesSplitter : TSplitter;
  FMessagesFloatForm : TForm;
  FMessages : TStringGrid;
  FMessagesPopup : TPopupMenu;
  FAIPanel : TPanel;
  FAIHeader : TPanel;
  FAISplitter : TSplitter;
  FAIFloatForm : TForm;
  FAIConsole : TRESTDWHTMLAIConsolePanel;
  FPreviewTimer : TTimer;
  FWebViewFirstTimer : TTimer;
  FWebViewFirstReady : Boolean;
  FToolbar : TPanel;
  FToolButtonPanel : TPanel;
  FToolButtonSeparator : TPanel;
  FNewButton : TSpeedButton;
  FOpenButton : TSpeedButton;
  FSaveButton : TSpeedButton;
  FRefreshButton : TSpeedButton;
  FHelpButton : TSpeedButton;
  FDebugStartButton : TSpeedButton;
  FDebugStopButton : TSpeedButton;
  FDebugBreakpointButton : TSpeedButton;
  FDebugClearButton : TSpeedButton;
  FDebugDevToolsButton : TSpeedButton;
  FFileMenuItem : TMenuItem;
  FEditMenuItem : TMenuItem;
  FSearchMenuItem : TMenuItem;
  FViewMenuItem : TMenuItem;
  FDebugMenuItem : TMenuItem;
  FComponentsMenuItem : TMenuItem;
  FProjectOptionsMenuItem : TMenuItem;
  FAIMenuItem : TMenuItem;
  FDebugStartMenuItem : TMenuItem;
  FDebugPauseMenuItem : TMenuItem;
  FDebugRunToCursorMenuItem : TMenuItem;
  FDebugStopMenuItem : TMenuItem;
  FDebugStepIntoMenuItem : TMenuItem;
  FDebugStepOverMenuItem : TMenuItem;
  FDebugStepOutMenuItem : TMenuItem;
  FDebugEvaluateMenuItem : TMenuItem;
  FDebugBreakpointMenuItem : TMenuItem;
  FDebugClearMenuItem : TMenuItem;
  FDebugReleaseAllMenuItem : TMenuItem;
  FDebugDevToolsMenuItem : TMenuItem;
  FNewMenuItem : TMenuItem;
  FOpenMenuItem : TMenuItem;
  FSaveMenuItem : TMenuItem;
  FModified : Boolean;
  FDebugging : Boolean;
  FDebugPaused : Boolean;
  FDebugBreakpoints : TStringList;
  FFullCodeOriginalWndProc : TWndMethod;
  FJSOriginalWndProc : TWndMethod;
  FCodeWndProcHooked : Boolean;
  FDebugMarkImages : TImageList;
  FDebugCurrentLine : Integer;
  FLastGutterClickLine : Integer;
  FLastGutterClickTick : UInt64;
  FDebugHoverExpression : String;
  FDebugHoverRequestID : Integer;
  FDebugEvaluateRequestID : Integer;
  FDebugHintForm : TForm;
  FDebugHintLabel : TLabel;
  FDebugEvaluateForm : TForm;
  FDebugEvaluateExpression : TEdit;
  FDebugEvaluateValueLabel : TLabel;
  FDebugEvaluateNewValue : TEdit;
  FCurrentFileName : String;
  FNewPageActive : Boolean;
  FPreviousFileName : String;
  FPreviousTitle : String;
  FPreviousRoute : String;
  FPreviousAutoDataTables : Boolean;
  FPreviousAutoCharts : Boolean;
  FPreviousHTML : TStringList;
  FPreviousCSS : TStringList;
  FPreviousJS : TStringList;
  FLanguageCode : String;
  FEditorTitle : String;
  FWebView : TRESTDWHTMLWebView;
  FWebDropOverlay : TForm;
  Procedure BuildUI;
  Procedure BuildMenus;
  Procedure InstallComponentClick(Sender : TObject);
  Procedure ComponentOptionsClick(Sender : TObject);
  Procedure ProjectOptionsClick(Sender : TObject);
  Procedure AIConfigureClick(Sender : TObject);
  Procedure AIConsoleClick(Sender : TObject);
  Procedure AIDockFloatClick(Sender : TObject);
  Function AIPageContext : String;
  Procedure BuildDockHeader(APanel : TPanel; Var AHeader : TPanel;
   const ACaption : String; APanelID : Integer);
  Procedure DockCloseClick(Sender : TObject);
  Procedure DockFloatClick(Sender : TObject);
  Procedure FloatingFormClose(Sender : TObject; Var CloseAction : TCloseAction);
  Procedure ShowProjectPanelClick(Sender : TObject);
  Procedure ShowInspectorPanelClick(Sender : TObject);
  Procedure ShowObjectBrowserPanelClick(Sender : TObject);
  Procedure ShowMessagesPanelClick(Sender : TObject);
  Procedure ShowFormDesignPanelClick(Sender : TObject);
  Procedure SetDockPanelVisible(APanelID : Integer; AVisible : Boolean);
  Procedure ToggleFloatDock(APanelID : Integer);
  Procedure ResetIDELayoutClick(Sender : TObject);
  Procedure BringFloatingFormsToFront;
  Procedure UpdateLeftDockHost;
  Procedure UpdateRightDockHost;
  Procedure ColorRGBChange(Sender : TObject);
  Procedure ColorHexChange(Sender : TObject);
  Procedure ColorCopyHexClick(Sender : TObject);
  Procedure ColorCopyRGBClick(Sender : TObject);
  Procedure ColorPreviewClick(Sender : TObject);
  Procedure UpdateColorFromRGB;
  Procedure UpdateColorFromHex;
  Procedure BuildProjectExplorer;
  Function ProjectNodeKey(ANode : TTreeNode) : String;
  Procedure SaveProjectExplorerState(AState : TStrings);
  Procedure RestoreProjectExplorerState(AState : TStrings;
   AFirstBuild : Boolean);
  Procedure AddProjectNode(AParent : TTreeNode;
   const ACaption, ASearchText : String);
  Procedure ParseCSSProjectNodes(AParent : TTreeNode);
  Procedure ParseJavaScriptProjectNodes(AParent : TTreeNode);
  Procedure ShowFormDesign;
  Procedure ShowCodeEditor;
  Procedure FormDesignButtonClick(Sender : TObject);
  Procedure CodeEditorButtonClick(Sender : TObject);
  Procedure WebViewDevToolsClick(Sender : TObject);
  Procedure NavigateCode(const ASearchText : String);
  Procedure PositionCode(const ASearchText : String; ASwitchToCode : Boolean);
  Procedure PositionElementCode(const ATagName, AText, AID,
   AClassName, AOuterHTML : String; ASwitchToCode : Boolean);
  Procedure ScanPackagePalette;
  Procedure LoadIDESettings;
  Procedure SaveIDESettings;
  Function IDESettingsFileName : String;
  Function ResolveEditorLibrariesPath : String;
  Procedure MessagesResize(Sender : TObject);
  Procedure MessagesDblClick(Sender : TObject);
  Procedure MessagesCopyLineClick(Sender : TObject);
  Procedure MessagesCopySelectionClick(Sender : TObject);
  Procedure MessagesSelectAllClick(Sender : TObject);
  Procedure MessagesCopyAllClick(Sender : TObject);
  Procedure MessagesKeyDown(Sender : TObject; Var Key : Word;
   Shift : TShiftState);
  Procedure OpenWebViewInBrowserClick(Sender : TObject);
  Procedure RefreshWebViewButtonClick(Sender : TObject);
  Procedure FocusCodeError(ALine, AColumn : Integer);
  Procedure AddPaletteItem(const ACategory, AName, AHTML : String;
   const AIconFile : String = '');
  Procedure PaletteMouseDown(Sender : TObject; Button : TMouseButton;
   Shift : TShiftState; X, Y : Integer);
  Procedure PaletteClick(Sender : TObject);
  Procedure InsertNonVisualComponent(AInfo : TRESTDWHTMLWebComponentInfo);
  Procedure PaletteEndDrag(Sender, Target : TObject; X, Y : Integer);
  Procedure ShowWebDropOverlay;
  Procedure HideWebDropOverlay;
  Procedure WebDropOverlayDragOver(Sender, Source : TObject;
   X, Y : Integer; State : TDragState; Var Accept : Boolean);
  Procedure WebDropOverlayDragDrop(Sender, Source : TObject;
   X, Y : Integer);
  Procedure DesignDragOver(Sender, Source : TObject; X, Y : Integer;
   State : TDragState; Var Accept : Boolean);
  Procedure DesignDragDrop(Sender, Source : TObject; X, Y : Integer);
  Procedure CodeDragOver(Sender, Source : TObject; X, Y : Integer;
   State : TDragState; Var Accept : Boolean);
  Procedure CodeDragDrop(Sender, Source : TObject; X, Y : Integer);
  Procedure ComponentClick(Sender : TObject);
  Procedure SourceChanged(Sender : TObject);
  Procedure FullCodeChanged(Sender : TObject);
  Procedure CodeEditorClick(Sender : TObject);
  Procedure CodeEditorKeyUp(Sender : TObject; Var Key : Word;
   Shift : TShiftState);
  Procedure CodeEditorMouseMove(Sender : TObject;
   Shift : TShiftState; X, Y : Integer);
  Procedure CodeEditorDblClick(Sender : TObject);
  Procedure InstallCodeWndProcHooks;
  {$IFDEF FPC}Procedure FullCodeWndProc(Var AMessage : TLMessage);{$ELSE}Procedure FullCodeWndProc(Var AMessage : TMessage);{$ENDIF}
  {$IFDEF FPC}Procedure JSCodeWndProc(Var AMessage : TLMessage);{$ELSE}Procedure JSCodeWndProc(Var AMessage : TMessage);{$ENDIF}
  {$IFDEF FPC}
  Procedure CodeGutterClick(Sender : TObject; X, Y, Line : Integer; Mark : TSynEditMark);
  {$ELSE}
  Procedure CodeGutterClick(Sender : TObject; Button : TMouseButton;
   X, Y, Line : Integer; Mark : TSynEditMark);
  {$ENDIF}
  Procedure ToggleBreakpointClick(Sender : TObject);
  Procedure DebugStartClick(Sender : TObject);
  Procedure DebugPauseClick(Sender : TObject);
  Procedure DebugRunToCursorClick(Sender : TObject);
  Procedure DebugStopClick(Sender : TObject);
  Procedure DebugStepIntoClick(Sender : TObject);
  Procedure DebugStepOverClick(Sender : TObject);
  Procedure DebugStepOutClick(Sender : TObject);
  Procedure DebugEvaluateClick(Sender : TObject);
  Procedure DebugClearBreakpointsClick(Sender : TObject);
  Procedure DebugReleaseAllBreakpointsClick(Sender : TObject);
  Procedure DebugDevToolsClick(Sender : TObject);
  Procedure DebugBreakpointHit(Sender : TObject; ALine : Integer);
  Procedure DebugEvaluateResult(Sender : TObject; ARequestID : Integer;
   const AExpression, AValue, AError : String; ASuccess : Boolean);
  Procedure DebugHintDblClick(Sender : TObject);
  Procedure EvaluateDialogEvaluateClick(Sender : TObject);
  Procedure EvaluateDialogModifyClick(Sender : TObject);
  Procedure ToggleBreakpoint(ALine : Integer);
  Procedure SyncBreakpointMarks;
  Procedure BuildDebugMarkImages;
  Function BreakpointIndex(ALine : Integer) : Integer;
  Function BuildDebugPreviewHTML : String;
  Function IsJavaScriptLine(ALine : Integer) : Boolean;
  Function DebugExpressionAtMouse(X, Y : Integer) : String;
  Procedure ShowEvaluateDialog(const AExpression : String);
  Procedure UpdateDebugMenuState;
  Procedure InspectCodeAtCaret;
  Procedure UpdateSelectedCodeElement(const AProperty, AValue : String);
  Procedure PreviewTimerTimer(Sender : TObject);
  Procedure WebViewFirstTimerTimer(Sender : TObject);
  Procedure RebuildVisualDesign;
  Procedure RebuildFullCode;
  Procedure SaveToProducer;
  Procedure ParseFullCodeToProducer;
  Procedure ToggleSourceDesign;
  Procedure FormKeyDownHandler(Sender : TObject; Var Key : Word;
   Shift : TShiftState);
  Procedure FormShowHandler(Sender : TObject);
  Procedure FormActivateHandler(Sender : TObject);
  Procedure FormCloseQueryHandler(Sender : TObject; Var CanClose : Boolean);
  Procedure NewClick(Sender : TObject);
  Procedure OpenClick(Sender : TObject);
  Procedure SaveClick(Sender : TObject);
  Procedure RefreshClick(Sender : TObject);
  Procedure HelpClick(Sender : TObject);
  Function BuildHelpHTML : String;
  Function HelpLang(const AKey : String) : String;
  Function SaveDocument : Boolean;
  Function ConfirmSaveChanges : Boolean;
  Procedure CapturePreviousPage;
  Procedure RestorePreviousPage;
  Procedure ClearPreviousPage;
  Procedure MarkModified;
  Procedure SetModified(AValue : Boolean);
  Procedure UpdateDocumentCaption;
  Procedure ApplyLazarusLanguage;
  Procedure SetDockHeaderLanguage(AHeader : TPanel; const ACaption : String);
  Function DetectLazarusLanguage : String;
  Function Lang(const AKey : String) : String;
  Procedure ProjectTreeClick(Sender : TObject);
  Procedure InspectorSetComponent(AInfo : TRESTDWHTMLWebComponentInfo);
  Procedure InspectorSetPageOptions;
  Procedure InspectorSetElement(const AElementID, ATagName, AText,
   AID, AClassName, AOuterHTML : String);
  Procedure InspectorGridDrawCell(Sender : TObject; ACol, ARow : Integer;
   ARect : TRect; AState : TGridDrawState);
  Procedure PropertiesEditingDone(Sender : TObject);
  Procedure PropertiesSetEditText(Sender : TObject; ACol, ARow : Integer; const Value : String);
  Procedure ApplyPropertyValue(const AProperty, AValue : String);
  Procedure EventsEditingDone(Sender : TObject);
  Procedure EventsDblClick(Sender : TObject);
  Procedure NavigateEventCode(const ASearchText : String;
   AInsideBody : Boolean);
  Procedure OpenOrCreateEventHandler(const AEventName, AHandlerText : String);
  Procedure OpenOrCreatePageEvent(const AEventName, AHandlerText : String);
  Procedure RemovePageEvent(const AEventName, AHandlerName : String);
  Function PageEventListener(const AEventName, AHandlerName : String) : String;
  Function PageEventDefaultHandler(const AEventName : String) : String;
  Function PageEventCurrentHandler(const AEventName : String) : String;
  Function ExtractHandlerName(const AHandlerText : String) : String;
  Function MakeEventHandlerName(const AEventName : String) : String;
  Function JavaScriptHandlerReferenceCount(const AHandlerName : String) : Integer;
  Procedure RemoveEmptyJavaScriptHandler(const AHandlerName : String);
  Procedure WebViewElementSelected(Sender : TObject;
   const AElementID, ATagName, AText, AID, AClassName,
   AOuterHTML : String);
  Procedure WebViewHTMLChanged(Sender : TObject; const AHTML : String);
  Procedure WebViewObjectTree(Sender : TObject; const AJSON : String);
  Procedure ObjectBrowserClick(Sender : TObject);
  Procedure SelectObjectBrowserElement(const AElementID : String);
  Procedure ClearObjectBrowserNodeData;
  Function ObjectBrowserIconIndex(const ATagName, AClassName, AElementName : String) : Integer;
  Procedure DeleteSelectedVisualElement;
  Procedure AddMessage(const AKind, AFile, AText : String;
   ALine, AColumn : Integer);
  Procedure ClearMessages;
  Procedure ValidateDocument;
  Procedure FindClick(Sender : TObject);
  Procedure ReplaceClick(Sender : TObject);
  Procedure UndoClick(Sender : TObject);
  Procedure CutClick(Sender : TObject);
  Procedure CopyClick(Sender : TObject);
  Procedure PasteClick(Sender : TObject);
  Function ActiveMemo : TSynEdit;
  Function ComponentHTML(const AName : String) : String;
  Function ApplyComponentOptions(AInfo : TRESTDWHTMLWebComponentInfo;
   const AHTML : String) : String;
  Function ComponentLibraryHTML(AInfo : TRESTDWHTMLWebComponentInfo) : String;
  Function ComponentInstanceHTML(AInfo : TRESTDWHTMLWebComponentInfo) : String;
  Function ComponentJSClassSource(AInfo : TRESTDWHTMLWebComponentInfo) : String;
  Function ComponentOptionsJSON(AInfo : TRESTDWHTMLWebComponentInfo) : String;
  Procedure InsertVisualComponent(AInfo : TRESTDWHTMLWebComponentInfo;
   X, Y : Integer; AAtPoint : Boolean);
  Function ComponentInstanceBaseName(AInfo : TRESTDWHTMLWebComponentInfo) : String;
  Function NextComponentInstanceName(const ABaseName : String) : String;
  Function ApplyComponentIdentity(const AHTML, AIdentity : String) : String;
  Function FindComponentByButton(AButton : TObject) : TRESTDWHTMLWebComponentInfo;
  Function FindCategoryTab(const ACategory : String) : TTabSheet;
  Function ExtractBetween(const AText, AStart, AEnd : String) : String;
  Procedure WebViewReady(Sender : TObject);
  Procedure WebViewError(Sender : TObject; const AMessage : String);
  Procedure WebViewPageError(Sender : TObject;
   const AKind, ASource, AMessage : String;
   ALine, AColumn : Integer);
  Procedure RefreshWebView;
  Function BuildPreviewHTML : String;
  Function NormalizePreviewHTML(const AHTML : String) : String;
  Function JSLineToFullCodeLine(AJSLine : Integer) : Integer;
  Function FullCodeLineToJSLine(AFullLine : Integer) : Integer;
 Public
  Constructor CreateDesigner(AProducer : TRESTDWHTMLPageProducerAdapter;
   const AEditorTitle : String = '');
  Function ExecuteModal : Boolean;
  Destructor Destroy; Override;
 End;
Function RESTDWExecuteContextRulesHTMLDesigner(
 AContextRules : TRESTDWContextRules;
 const AEditorTitle : String = '') : Boolean;
Implementation
Procedure BuildBrowserRefreshGlyph(ABitmap : TBitmap);
Begin
 ABitmap.SetSize(24,24);
 ABitmap.PixelFormat := pf24bit;
 {$IFDEF FPC}
 ABitmap.Transparent := False;
 ABitmap.Canvas.Brush.Color := clBtnFace;
 {$ELSE}
 ABitmap.Transparent := True;
 ABitmap.TransparentColor := clFuchsia;
 ABitmap.Canvas.Brush.Color := clFuchsia;
 {$ENDIF}
 ABitmap.Canvas.FillRect(Rect(0,0,24,24));
 ABitmap.Canvas.Pen.Color := clWindowText;
 ABitmap.Canvas.Pen.Width := 2;
 ABitmap.Canvas.Arc(4,4,20,20,5,16,18,5);
 ABitmap.Canvas.MoveTo(17,4);
 ABitmap.Canvas.LineTo(21,5);
 ABitmap.Canvas.LineTo(19,9);
 ABitmap.Canvas.Arc(4,4,20,20,19,8,6,19);
 ABitmap.Canvas.MoveTo(6,20);
 ABitmap.Canvas.LineTo(2,18);
 ABitmap.Canvas.LineTo(4,14);
End;

Procedure BuildBrowserWWWGlyph(ABitmap : TBitmap);
Begin
 ABitmap.SetSize(38,24);
 ABitmap.PixelFormat := pf24bit;
 {$IFDEF FPC}
 ABitmap.Transparent := False;
 ABitmap.Canvas.Brush.Color := clBtnFace;
 {$ELSE}
 ABitmap.Transparent := True;
 ABitmap.TransparentColor := clFuchsia;
 ABitmap.Canvas.Brush.Color := clFuchsia;
 {$ENDIF}
 ABitmap.Canvas.FillRect(Rect(0,0,38,24));
 ABitmap.Canvas.Brush.Style := bsClear;
 ABitmap.Canvas.Font.Name := 'Arial';
 ABitmap.Canvas.Font.Size := 7;
 ABitmap.Canvas.Font.Style := [fsBold];
 ABitmap.Canvas.Font.Color := clWindowText;
 ABitmap.Canvas.TextOut(2,6,'http://');
 ABitmap.Canvas.Pen.Color := clWindowText;
 ABitmap.Canvas.MoveTo(2,19);
 ABitmap.Canvas.LineTo(35,19);
End;

Function RESTDWRPos(
 const ASubText,
 AText : String) : Integer;
Var
 I,
 LSubLen : Integer;
Begin
 Result := 0;
 LSubLen := Length(ASubText);
 If (LSubLen = 0) Or
    (LSubLen > Length(AText)) Then
  Exit;
 For I := Length(AText) - LSubLen + 1 DownTo 1 Do
  If Copy(AText,I,LSubLen) = ASubText Then
  Begin
   Result := I;
   Exit;
  End;
End;
Constructor TRESTDWHTMLWebComponentInfo.Create;
Begin
 Inherited Create;
 Options := TStringList.Create;
 Options.NameValueSeparator := '=';
End;
Destructor TRESTDWHTMLWebComponentInfo.Destroy;
Begin
 Options.Free;
 Inherited Destroy;
End;
Constructor TRESTDWHTMLDesignerForm.CreateDesigner(
 AProducer : TRESTDWHTMLPageProducerAdapter;
 const AEditorTitle : String);
Begin
 Inherited CreateNew(Nil, 1);
 FProducer := AProducer;
 FEditorTitle := Trim(AEditorTitle);
 FComponents := TList.Create;
 FGeneratedInstanceNames := TStringList.Create;
 FGeneratedInstanceNames.CaseSensitive := False;
 FGeneratedInstanceNames.Sorted := True;
 FGeneratedInstanceNames.Duplicates := dupIgnore;
 FDesignComponents := TList.Create;
 FProjectItems := TList.Create;
 FEventOriginalValues := TStringList.Create;
 FDebugBreakpoints := TStringList.Create;
 FDebugging := False;
 FDebugPaused := False;
 FDebugCurrentLine := 0;
 FCodeWndProcHooked := False;
 FLastGutterClickLine := 0;
 FLastGutterClickTick := 0;
 FDebugHoverExpression := '';
 FDebugHoverRequestID := 0;
 FDebugEvaluateRequestID := 100;
 FDebugHintForm := Nil;
 FDebugHintLabel := Nil;
 FDebugEvaluateForm := Nil;
 FPreviousHTML := TStringList.Create;
 FPreviousCSS := TStringList.Create;
 FPreviousJS := TStringList.Create;
 FNewPageActive := False;
 FDesignMode := True;
 FUpdating := True;
 FUpdatingInspector := False;
 FSelectedElementID := '';
 FSelectedElementTag := '';
 FPendingCodeElement := False;
 FPendingCodeTagName := '';
 FPendingCodeText := '';
 FPendingCodeID := '';
 FPendingCodeClass := '';
 FPendingCodeOuterHTML := '';
 FPageOptionsSelected := False;
 FEditingEventCode := False;
 FSelectedFromCode := False;
 FSelectedCodeTagStart := 0;
 FSelectedCodeTagEnd := 0;
 FInsertInfo := Nil;
 FModified := False;
 FCurrentFileName := '';
 FLanguageCode := '';
 BuildUI;
 ScanPackagePalette;
 FHTML.Text := FProducer.HTML.Text;
 FCSS.Text := FProducer.CSS.Text;
 FJS.Text := FProducer.JavaScript.Text;
 FUpdating := False;
 BuildProjectExplorer;
 RebuildVisualDesign;
 RebuildFullCode;
 LoadIDESettings;
 ApplyLazarusLanguage;
 SetModified(False);
 UpdateDocumentCaption;
End;
Function TRESTDWHTMLDesignerForm.ExecuteModal : Boolean;
Begin
 ShowModal;
 SaveToProducer;
 Result := True;
End;
Destructor TRESTDWHTMLDesignerForm.Destroy;
Var
 I : Integer;
Begin
 SaveIDESettings;
 For I := 0 To FProjectItems.Count - 1 Do
  TObject(FProjectItems[I]).Free;
 FProjectItems.Free;
 FEventOriginalValues.Free;
 FDebugBreakpoints.Free;
 If Assigned(FDebugHintForm) Then
  FDebugHintForm.Free;
 FPreviousHTML.Free;
 FPreviousCSS.Free;
 FPreviousJS.Free;
 For I := 0 To FDesignComponents.Count - 1 Do
  TObject(FDesignComponents[I]).Free;
 FDesignComponents.Free;
 For I := 0 To FComponents.Count - 1 Do
  TObject(FComponents[I]).Free;
 FComponents.Free;
 FGeneratedInstanceNames.Free;
 Inherited Destroy;
End;
Procedure TRESTDWHTMLDesignerForm.BuildMenus;
Var
 M : TMenuItem;
 Procedure AddItem(
  AParent : TMenuItem;
  const ACaption : String;
  AHandler : TNotifyEvent;
  AShortcut : TShortCut);
 Var
  I : TMenuItem;
 Begin
  I := TMenuItem.Create(FMenu);
  I.Caption := ACaption;
  I.OnClick := AHandler;
  I.ShortCut := AShortcut;
  AParent.Add(I);
 End;
Begin
 FMenu := TMainMenu.Create(Self);
 Menu := FMenu;
 M := TMenuItem.Create(FMenu);
 M.Caption := '&File';
 FMenu.Items.Add(M);
 FFileMenuItem := M;
 FNewMenuItem := TMenuItem.Create(FMenu);
 FNewMenuItem.Caption := '&New';
 FNewMenuItem.OnClick := NewClick;
 FNewMenuItem.ShortCut := ShortCut(Ord('N'),[ssCtrl]);
 M.Add(FNewMenuItem);
 FOpenMenuItem := TMenuItem.Create(FMenu);
 FOpenMenuItem.Caption := '&Open...';
 FOpenMenuItem.OnClick := OpenClick;
 FOpenMenuItem.ShortCut := ShortCut(Ord('O'),[ssCtrl]);
 M.Add(FOpenMenuItem);
 FSaveMenuItem := TMenuItem.Create(FMenu);
 FSaveMenuItem.Caption := '&Save';
 FSaveMenuItem.OnClick := SaveClick;
 FSaveMenuItem.ShortCut := ShortCut(Ord('S'),[ssCtrl]);
 FSaveMenuItem.Enabled := False;
 M.Add(FSaveMenuItem);
 M := TMenuItem.Create(FMenu);
 M.Caption := '&Edit';
 FMenu.Items.Add(M);
 FEditMenuItem := M;
 AddItem(M,'&Undo',UndoClick,ShortCut(Ord('Z'),[ssCtrl]));
 AddItem(M,'Cu&t',CutClick,ShortCut(Ord('X'),[ssCtrl]));
 AddItem(M,'&Copy',CopyClick,ShortCut(Ord('C'),[ssCtrl]));
 AddItem(M,'&Paste',PasteClick,ShortCut(Ord('V'),[ssCtrl]));
 M := TMenuItem.Create(FMenu);
 M.Caption := '&Search';
 FMenu.Items.Add(M);
 FSearchMenuItem := M;
 AddItem(M,'&Find...',FindClick,ShortCut(Ord('F'),[ssCtrl]));
 AddItem(M,'&Replace...',ReplaceClick,ShortCut(Ord('H'),[ssCtrl]));
 M := TMenuItem.Create(FMenu);
 M.Caption := '&Components';
 FMenu.Items.Add(M);
 FComponentsMenuItem := M;
 AddItem(M,'&Install Component...',InstallComponentClick,0);
 AddItem(M,'Configure &Packages...',ComponentOptionsClick,0);
 M := TMenuItem.Create(FMenu);
 M.Caption := '&Project';
 FMenu.Items.Add(M);
 FProjectOptionsMenuItem := M;
 AddItem(M,'&Options...',ProjectOptionsClick,0);
 M := TMenuItem.Create(FMenu);
 M.Caption := '&AI';
 FMenu.Items.Add(M);
 FAIMenuItem := M;
 AddItem(M,'&Configuration...',AIConfigureClick,0);
 AddItem(M,'&Show Floating Console',AIConsoleClick,0);
 AddItem(M,'&Float / Dock Console',AIDockFloatClick,0);
 M := TMenuItem.Create(FMenu);
 M.Caption := '&Debug';
 FMenu.Items.Add(M);
 FDebugMenuItem := M;
 FDebugStartMenuItem := TMenuItem.Create(FMenu);
 FDebugStartMenuItem.Caption := '&Run / Continue';
 FDebugStartMenuItem.OnClick := DebugStartClick;
 FDebugStartMenuItem.ShortCut := ShortCut(VK_F9,[]);
 M.Add(FDebugStartMenuItem);
 FDebugPauseMenuItem := TMenuItem.Create(FMenu);
 FDebugPauseMenuItem.Caption := '&Pause';
 FDebugPauseMenuItem.OnClick := DebugPauseClick;
 M.Add(FDebugPauseMenuItem);
 FDebugRunToCursorMenuItem := TMenuItem.Create(FMenu);
 FDebugRunToCursorMenuItem.Caption := 'Run to &Cursor';
 FDebugRunToCursorMenuItem.OnClick := DebugRunToCursorClick;
 FDebugRunToCursorMenuItem.ShortCut := ShortCut(VK_F4,[]);
 M.Add(FDebugRunToCursorMenuItem);
 FDebugStopMenuItem := TMenuItem.Create(FMenu);
 FDebugStopMenuItem.Caption := 'S&top Program';
 FDebugStopMenuItem.OnClick := DebugStopClick;
 FDebugStopMenuItem.ShortCut := ShortCut(VK_F2,[ssCtrl]);
 M.Add(FDebugStopMenuItem);
 FDebugStepIntoMenuItem := TMenuItem.Create(FMenu);
 FDebugStepIntoMenuItem.Caption := 'Step &Into';
 FDebugStepIntoMenuItem.OnClick := DebugStepIntoClick;
 FDebugStepIntoMenuItem.ShortCut := ShortCut(VK_F7,[]);
 M.Add(FDebugStepIntoMenuItem);
 FDebugStepOverMenuItem := TMenuItem.Create(FMenu);
 FDebugStepOverMenuItem.Caption := 'Step &Over';
 FDebugStepOverMenuItem.OnClick := DebugStepOverClick;
 FDebugStepOverMenuItem.ShortCut := ShortCut(VK_F8,[]);
 M.Add(FDebugStepOverMenuItem);
 FDebugStepOutMenuItem := TMenuItem.Create(FMenu);
 FDebugStepOutMenuItem.Caption := 'Step O&ut';
 FDebugStepOutMenuItem.OnClick := DebugStepOutClick;
 FDebugStepOutMenuItem.ShortCut := ShortCut(VK_F8,[ssShift]);
 M.Add(FDebugStepOutMenuItem);
 FDebugEvaluateMenuItem := TMenuItem.Create(FMenu);
 FDebugEvaluateMenuItem.Caption := '&Evaluate/Modify...';
 FDebugEvaluateMenuItem.OnClick := DebugEvaluateClick;
 FDebugEvaluateMenuItem.ShortCut := ShortCut(VK_F7,[ssCtrl]);
 M.Add(FDebugEvaluateMenuItem);
 FDebugBreakpointMenuItem := TMenuItem.Create(FMenu);
 FDebugBreakpointMenuItem.Caption := 'Toggle &Breakpoint';
 FDebugBreakpointMenuItem.OnClick := ToggleBreakpointClick;
 FDebugBreakpointMenuItem.ShortCut := ShortCut(VK_F5,[]);
 M.Add(FDebugBreakpointMenuItem);
 FDebugClearMenuItem := TMenuItem.Create(FMenu);
 FDebugClearMenuItem.Caption := '&Clear Breakpoints';
 FDebugClearMenuItem.OnClick := DebugClearBreakpointsClick;
 M.Add(FDebugClearMenuItem);
 FDebugReleaseAllMenuItem := TMenuItem.Create(FMenu);
 FDebugReleaseAllMenuItem.Caption := '&Release All Breakpoints';
 FDebugReleaseAllMenuItem.OnClick := DebugReleaseAllBreakpointsClick;
 M.Add(FDebugReleaseAllMenuItem);
 FDebugDevToolsMenuItem := TMenuItem.Create(FMenu);
 FDebugDevToolsMenuItem.Caption := 'WebView &DevTools';
 FDebugDevToolsMenuItem.OnClick := DebugDevToolsClick;
 M.Add(FDebugDevToolsMenuItem);
 M := TMenuItem.Create(FMenu);
 M.Caption := '&View';
 FMenu.Items.Add(M);
 FViewMenuItem := M;
 AddItem(M,'&FormDesign',FormDesignButtonClick,0);
 AddItem(M,'&Code Editor',CodeEditorButtonClick,0);
 AddItem(M,'WebView &DevTools',WebViewDevToolsClick,0);
 AddItem(M,'Project &Explorer',ShowProjectPanelClick,0);
 AddItem(M,'Object &Inspector',ShowInspectorPanelClick,0);
 AddItem(M,'Object &Browser',ShowObjectBrowserPanelClick,0);
 AddItem(M,'Show &Errors',ShowMessagesPanelClick,0);
 AddItem(M,'Form Designer &Panel',ShowFormDesignPanelClick,0);
 AddItem(M,'AI &Console',AIConsoleClick,0);
 M := TMenuItem.Create(FMenu);
 M.Caption := '&Window';
 FMenu.Items.Add(M);
 AddItem(M,'&Reset IDE Layout',ResetIDELayoutClick,0);
End;
Procedure TRESTDWHTMLDesignerForm.InstallComponentClick(
 Sender : TObject);
Begin
 InstallRESTDWHTMLComponent(
  ResolveEditorLibrariesPath
 );
 ScanPackagePalette;
End;
Procedure TRESTDWHTMLDesignerForm.ComponentOptionsClick(
 Sender : TObject);
Begin
 ConfigureRESTDWHTMLComponents(
  ResolveEditorLibrariesPath
 );
 ScanPackagePalette;
End;
Procedure TRESTDWHTMLDesignerForm.ProjectOptionsClick(
 Sender : TObject);
Begin
 ConfigureRESTDWHTMLProject(
  FProducer,
  ResolveEditorLibrariesPath
 );
 RefreshWebView;
 MarkModified;
End;
Procedure TRESTDWHTMLDesignerForm.AIConfigureClick(
 Sender : TObject);
Begin
 ConfigureRESTDWHTMLAI(
  Self
 );
End;
Procedure TRESTDWHTMLDesignerForm.AIConsoleClick(
 Sender : TObject);
Begin
 SetDockPanelVisible(
  5,
  True
 );
 { The AI console opens floating by default so it does not consume designer
   space. The user can dock it explicitly from the AI menu or [] header. }
 If (FAIFloatForm = Nil) And
    (FAIPanel.Parent = Self) Then
  ToggleFloatDock(
   5
  );
End;
Procedure TRESTDWHTMLDesignerForm.AIDockFloatClick(
 Sender : TObject);
Begin
 SetDockPanelVisible(
  5,
  True
 );
 ToggleFloatDock(
  5
 );
End;
Function TRESTDWHTMLDesignerForm.AIPageContext : String;
Begin
 Result :=
  FFullCode.Text;
End;
Procedure TRESTDWHTMLDesignerForm.BuildDockHeader(
 APanel : TPanel;
 Var AHeader : TPanel;
 const ACaption : String;
 APanelID : Integer);
Var
 LLabel : TLabel;
 LClose,
 LWWW,
 LRefresh,
 LFloat : TSpeedButton;
Begin
 AHeader := TPanel.Create(APanel);
 AHeader.Parent := APanel;
 AHeader.Align := alTop;
 AHeader.Height := 25;
 AHeader.BevelOuter := bvLowered;
 AHeader.Caption := '';
 LLabel := TLabel.Create(AHeader);
 LLabel.Parent := AHeader;
 LLabel.Align := alClient;
 LLabel.Layout := tlCenter;
 {$IFDEF FPC}
 LLabel.BorderSpacing.Left := 6;
 {$ELSE}
 LLabel.Margins.Left := 6;
 {$ENDIF}
 LLabel.Caption := ACaption;
 LClose := TSpeedButton.Create(AHeader);
 LClose.Parent := AHeader;
 LClose.Align := alRight;
 LClose.Width := 25;
 LClose.Caption := 'X';
 LClose.Flat := True;
 LClose.Hint := Lang('Close');
 LClose.ShowHint := True;
 LClose.Tag := APanelID;
 LClose.OnClick := DockCloseClick;
 If APanelID = 4 Then
  Begin
   LWWW := TSpeedButton.Create(AHeader);
   LWWW.Parent := AHeader;
   LWWW.Align := alRight;
   LWWW.Width := 38;
   LWWW.Caption := '';
   BuildBrowserWWWGlyph(LWWW.Glyph);
   LWWW.Flat := True;
   LWWW.Hint := 'Open current WebView page in default browser';
   LWWW.ShowHint := True;
   LWWW.OnClick := OpenWebViewInBrowserClick;
   LRefresh := TSpeedButton.Create(AHeader);
   LRefresh.Parent := AHeader;
   LRefresh.Align := alRight;
   LRefresh.Width := 32;
   LRefresh.Caption := '';
   BuildBrowserRefreshGlyph(LRefresh.Glyph);
   LRefresh.Flat := True;
   LRefresh.Hint := 'Refresh current WebView with current editor code';
   LRefresh.ShowHint := True;
   LRefresh.OnClick := RefreshWebViewButtonClick;
  End;
 LFloat := TSpeedButton.Create(AHeader);
 LFloat.Parent := AHeader;
 LFloat.Align := alRight;
 LFloat.Width := 27;
 LFloat.Caption := '[]';
 LFloat.Flat := True;
 LFloat.Hint := Lang('FloatDock');
 LFloat.ShowHint := True;
 LFloat.Tag := APanelID;
 LFloat.OnClick := DockFloatClick;
End;
Procedure TRESTDWHTMLDesignerForm.FocusCodeError(
 ALine,
 AColumn : Integer);
Begin
 If ALine < 1 Then
  ALine := 1;
 If AColumn < 1 Then
  AColumn := 1;
 If FDesignMode Then
  ShowCodeEditor;
 FCodePages.ActivePage := FFullCodeTab;
 {$IFDEF FPC}
 FFullCode.CaretXY := Point(AColumn,ALine);
 {$ELSE}
 FFullCode.CaretXY := BufferCoord(AColumn,ALine);
 {$ENDIF}
 FFullCode.SetFocus;
End;
Procedure TRESTDWHTMLDesignerForm.RefreshWebViewButtonClick(
 Sender : TObject);
Begin
 If Not FDesignMode Then
 Begin
  ShowFormDesign;
  Exit;
 End;
 SaveToProducer;
 ValidateDocument;
 BuildProjectExplorer;
 RebuildVisualDesign;
End;
Procedure TRESTDWHTMLDesignerForm.UpdateColorFromRGB;
Var
 R, G, B : Integer;
 LHex : String;
Begin
 If FUpdatingColor Then
  Exit;
 If Not TryStrToInt(Trim(FColorR.Text),R) Then
  Exit;
 If Not TryStrToInt(Trim(FColorG.Text),G) Then
  Exit;
 If Not TryStrToInt(Trim(FColorB.Text),B) Then
  Exit;
 If R < 0 Then R := 0 Else If R > 255 Then R := 255;
 If G < 0 Then G := 0 Else If G > 255 Then G := 255;
 If B < 0 Then B := 0 Else If B > 255 Then B := 255;
 LHex :=
  '#' +
  IntToHex(R,2) +
  IntToHex(G,2) +
  IntToHex(B,2);
 FUpdatingColor := True;
 Try
  FColorR.Text := IntToStr(R);
  FColorG.Text := IntToStr(G);
  FColorB.Text := IntToStr(B);
  FColorHex.Text := LHex;
  FColorPreview.Color :=
   TColor(
    R Or
    (G Shl 8) Or
    (B Shl 16)
   );
 Finally
  FUpdatingColor := False;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.UpdateColorFromHex;
Var
 H : String;
 V, R, G, B,
 LCaret : Integer;
Begin
 If FUpdatingColor Then
  Exit;
 H := Trim(FColorHex.Text);
 If Copy(H,1,1) = '#' Then
  Delete(H,1,1);
 If Length(H) <> 6 Then
  Exit;
 If Not TryStrToInt('$' + H,V) Then
  Exit;
 R := (V Shr 16) And $FF;
 G := (V Shr 8) And $FF;
 B := V And $FF;
 LCaret := FColorHex.SelStart;
 FUpdatingColor := True;
 Try
  FColorR.Text := IntToStr(R);
  FColorG.Text := IntToStr(G);
  FColorB.Text := IntToStr(B);
  If FColorHex.Text <> '#' + UpperCase(H) Then
   FColorHex.Text := '#' + UpperCase(H);
  If LCaret > Length(FColorHex.Text) Then
   LCaret := Length(FColorHex.Text);
  FColorHex.SelStart := LCaret;
  FColorPreview.Color :=
   TColor(
    R Or
    (G Shl 8) Or
    (B Shl 16)
   );
 Finally
  FUpdatingColor := False;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.ColorRGBChange(Sender : TObject);
Begin
 UpdateColorFromRGB;
End;
Procedure TRESTDWHTMLDesignerForm.ColorHexChange(Sender : TObject);
Begin
 UpdateColorFromHex;
End;
Procedure TRESTDWHTMLDesignerForm.ColorCopyHexClick(Sender : TObject);
Begin
 Clipboard.AsText := FColorHex.Text;
End;
Procedure TRESTDWHTMLDesignerForm.ColorCopyRGBClick(Sender : TObject);
Begin
 Clipboard.AsText :=
  'rgb(' + FColorR.Text + ', ' + FColorG.Text + ', ' + FColorB.Text + ')';
End;
Procedure TRESTDWHTMLDesignerForm.ColorPreviewClick(Sender : TObject);
Var
 D : TColorDialog;
 C : TColor;
 R, G, B : Integer;
 LRGB : Longint;
Begin
 D := TColorDialog.Create(Self);
 Try
  D.Options :=
   D.Options +
   [cdFullOpen,cdAnyColor];
  D.Color := ColorToRGB(FColorPreview.Color);
  LRGB := ColorToRGB(D.Color);
  D.CustomColors.Values['ColorA'] :=
   IntToHex(GetRValue(LRGB),2) +
   IntToHex(GetGValue(LRGB),2) +
   IntToHex(GetBValue(LRGB),2);
  If Not D.Execute Then
   Exit;
  C := ColorToRGB(D.Color);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);
  FUpdatingColor := True;
  Try
   FColorR.Text := IntToStr(R);
   FColorG.Text := IntToStr(G);
   FColorB.Text := IntToStr(B);
   FColorHex.Text :=
    '#' +
    IntToHex(R,2) +
    IntToHex(G,2) +
    IntToHex(B,2);
   FColorPreview.Color := RGB(R,G,B);
  Finally
   FUpdatingColor := False;
  End;
 Finally
  D.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.UpdateRightDockHost;
Var
 LInspectorDocked,
 LObjectBrowserDocked : Boolean;
Begin
 If Not Assigned(FRightDockHost) Then
  Exit;
 LInspectorDocked :=
  Assigned(FInspectorPanel) And FInspectorPanel.Visible And
  (FInspectorPanel.Parent = FRightDockHost);
 LObjectBrowserDocked :=
  Assigned(FObjectBrowserPanel) And FObjectBrowserPanel.Visible And
  (FObjectBrowserPanel.Parent = FRightDockHost);
 FRightDockHost.Visible := LInspectorDocked Or LObjectBrowserDocked;
 If Assigned(FInspectorSplitter) Then
  FInspectorSplitter.Visible := FRightDockHost.Visible;
 If Assigned(FObjectBrowserSplitter) Then
  FObjectBrowserSplitter.Visible := LObjectBrowserDocked And LInspectorDocked;
End;
Procedure TRESTDWHTMLDesignerForm.UpdateLeftDockHost;
Var
 LProjectDocked,
 LColorDocked : Boolean;
Begin
 LProjectDocked :=
  Assigned(FProjectPanel) And
  (FProjectPanel.Parent = FLeftDockHost) And
  FProjectPanel.Visible;
 LColorDocked :=
  Assigned(FColorToolPanel) And
  (FColorToolPanel.Parent = FLeftDockHost) And
  FColorToolPanel.Visible;
 FLeftDockHost.Visible :=
  LProjectDocked Or
  LColorDocked;
 FProjectSplitter.Visible :=
  FLeftDockHost.Visible;
 If LColorDocked Then
 Begin
  FColorToolPanel.Align := alTop;
  FColorToolPanel.Height := 172;
  FColorToolPanel.BringToFront;
 End;
 If LProjectDocked Then
 Begin
  FProjectPanel.Align := alClient;
  FProjectPanel.BringToFront;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.BringFloatingFormsToFront;
 Procedure BringForm(AForm : TForm);
 Begin
  If Assigned(AForm) And
     AForm.Visible Then
  Begin
   AForm.FormStyle := fsStayOnTop;
   AForm.BringToFront;
  End;
 End;
Begin
 BringForm(FProjectFloatForm);
 BringForm(FInspectorFloatForm);
 BringForm(FMessagesFloatForm);
 BringForm(FPreviewFloatForm);
 BringForm(FAIFloatForm);
 BringForm(FColorToolFloatForm);
End;
Procedure TRESTDWHTMLDesignerForm.ResetIDELayoutClick(
 Sender : TObject);
 Procedure DockPanel(
  APanelID : Integer;
  APanel : TPanel;
  AFloatForm : TForm);
 Begin
  If Assigned(AFloatForm) Then
   ToggleFloatDock(APanelID)
  Else
  Begin
   APanel.Visible := True;
   Case APanelID Of
    1 :
     Begin
      APanel.Parent := FLeftDockHost;
      APanel.Align := alClient;
      FProjectSplitter.Visible := True;
     End;
    2 :
     Begin
      APanel.Parent := FRightDockHost;
      APanel.Align := alClient;
      FInspectorSplitter.Visible := True;
     End;
    3 :
     Begin
      APanel.Parent := Self;
      APanel.Align := alBottom;
      FMessagesSplitter.Visible := True;
     End;
    4 :
     Begin
      APanel.Parent := FWorkPanel;
      APanel.Align := alClient;
     End;
    5 :
     Begin
      APanel.Parent := Self;
      APanel.Align := alBottom;
      FAISplitter.Visible := True;
     End;
    6 :
     Begin
      APanel.Parent := FLeftDockHost;
      APanel.Align := alTop;
     End;
    7 :
     Begin
      APanel.Parent := FRightDockHost;
      APanel.Align := alTop;
      FObjectBrowserSplitter.Visible := True;
     End;
   End;
  End;
 End;
Begin
 DockPanel(1,FProjectPanel,FProjectFloatForm);
 DockPanel(2,FInspectorPanel,FInspectorFloatForm);
 DockPanel(3,FMessagesPanel,FMessagesFloatForm);
 DockPanel(4,FPreviewPanel,FPreviewFloatForm);
 DockPanel(5,FAIPanel,FAIFloatForm);
 DockPanel(6,FColorToolPanel,FColorToolFloatForm);
 DockPanel(7,FObjectBrowserPanel,FObjectBrowserFloatForm);
 If Assigned(FLeftDockHost) Then
  FLeftDockHost.Width := 280;
 If Assigned(FColorToolPanel) Then
 Begin
  FColorToolPanel.Height := 172;
  FColorToolPanel.BringToFront;
 End;
 If Assigned(FProjectPanel) Then
  FProjectPanel.BringToFront;
 If Assigned(FRightDockHost) Then
  FRightDockHost.Width := 320;
 If Assigned(FObjectBrowserPanel) Then
  FObjectBrowserPanel.Height := 220;
 If Assigned(FMessagesPanel) Then
  FMessagesPanel.Height := 180;
 If Assigned(FAIPanel) Then
  FAIPanel.Height := 250;
 If Assigned(FWebView) Then
 Begin
  FWebView.Parent := FPreviewPanel;
  FWebView.Align := alClient;
  FWebView.Visible := True;
  FWebView.BringToFront;
 End;
 BuildProjectExplorer;
 UpdateLeftDockHost;
 UpdateRightDockHost;
 SaveIDESettings;
End;
Procedure TRESTDWHTMLDesignerForm.SetDockPanelVisible(
 APanelID : Integer;
 AVisible : Boolean);
Var
 LPanel : TPanel;
 LForm : TForm;
Begin
 LPanel := Nil;
 LForm := Nil;
 Case APanelID Of
  1 :
   Begin
    LPanel := FProjectPanel;
    LForm := FProjectFloatForm;
    If Assigned(FProjectSplitter) Then
     FProjectSplitter.Visible :=
      AVisible And (FProjectPanel.Parent = FLeftDockHost);
   End;
  2 :
   Begin
    LPanel := FInspectorPanel;
    LForm := FInspectorFloatForm;
    If Assigned(FInspectorSplitter) Then
     FInspectorSplitter.Visible :=
      AVisible And (FInspectorPanel.Parent = FRightDockHost);
   End;
  3 :
   Begin
    LPanel := FMessagesPanel;
    LForm := FMessagesFloatForm;
    If Assigned(FMessagesSplitter) Then
     FMessagesSplitter.Visible :=
      AVisible And (FMessagesPanel.Parent = Self);
   End;
  4 :
   Begin
    LPanel := FPreviewPanel;
    LForm := FPreviewFloatForm;
   End;
  5 :
   Begin
    LPanel := FAIPanel;
    LForm := FAIFloatForm;
    If Assigned(FAISplitter) Then
     FAISplitter.Visible :=
      AVisible And
      (FAIPanel.Parent = Self);
   End;
  6 :
   Begin
    LPanel := FColorToolPanel;
    LForm := FColorToolFloatForm;
   End;
  7 :
   Begin
    LPanel := FObjectBrowserPanel;
    LForm := FObjectBrowserFloatForm;
    If Assigned(FObjectBrowserSplitter) Then
     FObjectBrowserSplitter.Visible :=
      AVisible And (FObjectBrowserPanel.Parent = FRightDockHost);
   End;
 End;
 If LPanel = Nil Then
  Exit;
 LPanel.Visible := AVisible;
 If Assigned(LForm) Then
 Begin
  If AVisible Then
  Begin
   LForm.Show;
   LForm.BringToFront;
   LForm.SetFocus;
  End
  Else
   LForm.Hide;
 End;
 If (APanelID = 1) Or
    (APanelID = 6) Then
  UpdateLeftDockHost;
 UpdateRightDockHost;
End;
Procedure TRESTDWHTMLDesignerForm.DockCloseClick(
 Sender : TObject);
Begin
 If Sender Is TSpeedButton Then
  SetDockPanelVisible(
   TSpeedButton(Sender).Tag,
   False
  );
End;
Procedure TRESTDWHTMLDesignerForm.DockFloatClick(
 Sender : TObject);
Begin
 If Sender Is TSpeedButton Then
  ToggleFloatDock(
   TSpeedButton(Sender).Tag
  );
End;
Procedure TRESTDWHTMLDesignerForm.FloatingFormClose(
 Sender : TObject;
 Var CloseAction : TCloseAction);
Begin
 CloseAction := caHide;
 If Sender = FProjectFloatForm Then
  FProjectPanel.Visible := False
 Else If Sender = FInspectorFloatForm Then
  FInspectorPanel.Visible := False
 Else If Sender = FMessagesFloatForm Then
  FMessagesPanel.Visible := False
 Else If Sender = FPreviewFloatForm Then
  FPreviewPanel.Visible := False
 Else If Sender = FAIFloatForm Then
  FAIPanel.Visible := False
 Else If Sender = FColorToolFloatForm Then
  FColorToolPanel.Visible := False
 Else If Sender = FObjectBrowserFloatForm Then
  FObjectBrowserPanel.Visible := False;
 UpdateRightDockHost;
End;
Procedure TRESTDWHTMLDesignerForm.ToggleFloatDock(
 APanelID : Integer);
Var
 LPanel : TPanel;
 LFloatForm : TForm;
 LDockParent : TWinControl;
 LDockAlign : TAlign;
 LCaption : String;
 LWidth,
 LHeight : Integer;
Begin
 LPanel := Nil;
 LFloatForm := Nil;
 LDockParent := Self;
 LDockAlign := alNone;
 LCaption := '';
 LWidth := 420;
 LHeight := 500;
 Case APanelID Of
  1 :
   Begin
    LPanel := FProjectPanel;
    LFloatForm := FProjectFloatForm;
    LDockParent := FLeftDockHost;
    LDockAlign := alClient;
    LCaption := Lang('ProjectExplorer');
    LWidth := FProjectPanel.Width;
   End;
  2 :
   Begin
    LPanel := FInspectorPanel;
    LFloatForm := FInspectorFloatForm;
    LDockParent := FRightDockHost;
    LDockAlign := alClient;
    LCaption := Lang('ObjectInspector');
    LWidth := FInspectorPanel.Width;
   End;
  3 :
   Begin
    LPanel := FMessagesPanel;
    LFloatForm := FMessagesFloatForm;
    LDockAlign := alBottom;
    LCaption := Lang('ShowErrors');
    LWidth := 850;
    LHeight := FMessagesPanel.Height + 80;
   End;
  4 :
   Begin
    LPanel := FPreviewPanel;
    LFloatForm := FPreviewFloatForm;
    LDockParent := FWorkPanel;
    LDockAlign := alClient;
    LCaption := Lang('FormDesign');
    LWidth := 900;
    LHeight := 650;
   End;
  5 :
   Begin
    LPanel := FAIPanel;
    LFloatForm := FAIFloatForm;
    LDockParent := Self;
    LDockAlign := alBottom;
    LCaption := 'REST Dataware AI Console';
    LWidth := 850;
    LHeight := 430;
   End;
  6 :
   Begin
    LPanel := FColorToolPanel;
    LFloatForm := FColorToolFloatForm;
    LDockParent := FLeftDockHost;
    LDockAlign := alTop;
    LCaption := 'CSS Color Tool';
    LWidth := 300;
    LHeight := 190;
   End;
  7 :
   Begin
    LPanel := FObjectBrowserPanel;
    LFloatForm := FObjectBrowserFloatForm;
    LDockParent := FRightDockHost;
    LDockAlign := alTop;
    LCaption := 'Object Browser';
    LWidth := 360;
    LHeight := 420;
   End;
 End;
 If LPanel = Nil Then
  Exit;
 If Assigned(LFloatForm) Then
 Begin
  If (APanelID = 4) And
     Assigned(FWebView) Then
   FWebView.DetachHost;
  LPanel.Parent := LDockParent;
  LPanel.Align := LDockAlign;
  LPanel.Visible := True;
  Case APanelID Of
   1 :
    Begin
     FProjectFloatForm.Free;
     FProjectFloatForm := Nil;
     FProjectSplitter.Visible := True;
    End;
   2 :
    Begin
     FInspectorFloatForm.Free;
     FInspectorFloatForm := Nil;
     FInspectorSplitter.Visible := True;
    End;
   3 :
    Begin
     FMessagesFloatForm.Free;
     FMessagesFloatForm := Nil;
     FMessagesSplitter.Visible := True;
    End;
   4 :
    Begin
     FPreviewFloatForm.Free;
     FPreviewFloatForm := Nil;
    End;
   5 :
    Begin
     FAIFloatForm.Free;
     FAIFloatForm := Nil;
     FAISplitter.Visible := True;
    End;
   6 :
    Begin
     FColorToolFloatForm.Free;
     FColorToolFloatForm := Nil;
    End;
   7 :
    Begin
     FObjectBrowserFloatForm.Free;
     FObjectBrowserFloatForm := Nil;
     FObjectBrowserSplitter.Visible := True;
    End;
  End;
  If (APanelID = 4) And
     Assigned(FWebView) Then
  Begin
   FWebView.Parent := FPreviewPanel;
   FWebView.Align := alClient;
   FWebView.Visible := True;
   FWebView.BringToFront;
   Application.ProcessMessages;
   FWebView.RebindHost;
  End;
  UpdateLeftDockHost;
  UpdateRightDockHost;
  Exit;
 End;
 LFloatForm := TForm.CreateNew(Self,1);
 LFloatForm.Caption := LCaption;
 LFloatForm.Position := poDesigned;
 LFloatForm.BorderStyle := bsSizeable;
 LFloatForm.FormStyle := fsStayOnTop;
 LFloatForm.Width := LWidth;
 LFloatForm.Height := LHeight;
 LFloatForm.Left := Left + 80;
 LFloatForm.Top := Top + 80;
 If LFloatForm.Left < Screen.WorkAreaRect.Left Then
  LFloatForm.Left := Screen.WorkAreaRect.Left + 20;
 If LFloatForm.Top < Screen.WorkAreaRect.Top Then
  LFloatForm.Top := Screen.WorkAreaRect.Top + 20;
 If LFloatForm.Left + LFloatForm.Width > Screen.WorkAreaRect.Right Then
  LFloatForm.Left := Screen.WorkAreaRect.Right - LFloatForm.Width - 20;
 If LFloatForm.Top + LFloatForm.Height > Screen.WorkAreaRect.Bottom Then
  LFloatForm.Top := Screen.WorkAreaRect.Bottom - LFloatForm.Height - 20;
 LFloatForm.OnClose := FloatingFormClose;
 If (APanelID = 4) And
    Assigned(FWebView) Then
  FWebView.DetachHost;
 LPanel.Align := alClient;
 LPanel.Parent := LFloatForm;
 LPanel.Visible := True;
 Case APanelID Of
  1 :
   Begin
    FProjectFloatForm := LFloatForm;
    FProjectSplitter.Visible := False;
   End;
  2 :
   Begin
    FInspectorFloatForm := LFloatForm;
    FInspectorSplitter.Visible := False;
   End;
  3 :
   Begin
    FMessagesFloatForm := LFloatForm;
    FMessagesSplitter.Visible := False;
   End;
  4 :
   FPreviewFloatForm := LFloatForm;
  5 :
   Begin
    FAIFloatForm := LFloatForm;
    FAISplitter.Visible := False;
   End;
  6 :
   FColorToolFloatForm := LFloatForm;
  7 :
   Begin
    FObjectBrowserFloatForm := LFloatForm;
    FObjectBrowserSplitter.Visible := False;
   End;
 End;
 LFloatForm.Show;
 LFloatForm.BringToFront;
 LFloatForm.SetFocus;
 If (APanelID = 4) And
    Assigned(FWebView) Then
 Begin
  { WebView/WebView2 keeps a native child window. After the preview panel is
    reparented to a floating form, force its host back onto the preview panel
    and navigate the current generated page again. Without this, some widgetsets
    and WebView2 controllers retain the old parent handle and show a gray area. }
  FWebView.Parent := FPreviewPanel;
  FWebView.Align := alClient;
  FWebView.Visible := True;
  FWebView.BringToFront;
  Application.ProcessMessages;
  FWebView.RebindHost;
 End;
 UpdateLeftDockHost;
 UpdateRightDockHost;
End;
Procedure TRESTDWHTMLDesignerForm.ShowProjectPanelClick(
 Sender : TObject);
Begin
 SetDockPanelVisible(1,True);
End;
Procedure TRESTDWHTMLDesignerForm.ShowInspectorPanelClick(
 Sender : TObject);
Begin
 SetDockPanelVisible(2,True);
End;
Procedure TRESTDWHTMLDesignerForm.ShowObjectBrowserPanelClick(
 Sender : TObject);
Begin
 SetDockPanelVisible(7,True);
End;
Procedure TRESTDWHTMLDesignerForm.ShowMessagesPanelClick(
 Sender : TObject);
Begin
 SetDockPanelVisible(3,True);
End;
Procedure TRESTDWHTMLDesignerForm.ShowFormDesignPanelClick(
 Sender : TObject);
Begin
 SetDockPanelVisible(4,True);
 ShowFormDesign;
End;
Procedure TRESTDWHTMLDesignerForm.BuildUI;
Var
 LMessagesMenuItem : TMenuItem;
 LSplit : TSplitter;
 LTab : TTabSheet;
 LLabel : TLabel;
 {$IFDEF FPC}
 LScheme : TSynHighlighterMultiScheme;
 {$ELSE}
 LScheme : TScheme;
 {$ENDIF}
Begin
 If FEditorTitle <> '' Then
  Caption := FEditorTitle
 Else
  Caption := 'REST Dataware - Visual Web IDE';
 BorderStyle := bsSizeable;
 BorderIcons := [biSystemMenu,biMinimize,biMaximize];
 FormStyle := fsNormal;
 WindowState := wsNormal;
 Position := poScreenCenter;
 Width := 1500;
 Height := 900;
 KeyPreview := True;
 OnKeyDown := FormKeyDownHandler;
 OnShow := FormShowHandler;
 OnActivate := FormActivateHandler;
 OnCloseQuery := FormCloseQueryHandler;
 BuildMenus;
 FToolbar := TPanel.Create(Self);
 FToolbar.Parent := Self;
 FToolbar.Align := alTop;
 FToolbar.Height := 66;
 FToolbar.Caption := '';
 FToolbar.BevelOuter := bvNone;
 FToolbar.Visible := True;
 FToolButtonPanel := TPanel.Create(FToolbar);
 FToolButtonPanel.Parent := FToolbar;
 FToolButtonPanel.Align := alLeft;
 FToolButtonPanel.Height := 66;
 FToolButtonPanel.Width := 156;
 FToolButtonPanel.Caption := '';
 FToolButtonPanel.BevelOuter := bvNone;
 FToolButtonSeparator := TPanel.Create(FToolbar);
 FToolButtonSeparator.Parent := FToolbar;
 FToolButtonSeparator.Align := alLeft;
 FToolButtonSeparator.Width := 1;
 FToolButtonSeparator.Caption := '';
 FToolButtonSeparator.BevelOuter := bvNone;
 FToolButtonSeparator.Color := clBtnShadow;
 FNewButton := TSpeedButton.Create(FToolButtonPanel);
 FNewButton.Parent := FToolButtonPanel;
 FNewButton.SetBounds(5,4,28,28);
 FNewButton.Caption := '';
 FNewButton.Flat := True;
 FNewButton.Hint := 'Create a new blank PageProducer page. If the current page has unsaved changes, you will be asked to save them first.';
 FNewButton.ShowHint := True;
 FNewButton.OnClick := NewClick;
 RESTDWLoadHTMLDesignerIcon(
  FNewButton.Glyph,
  'toolbar_new.bmp'
 );
 FNewButton.Caption := '';
 FOpenButton := TSpeedButton.Create(FToolButtonPanel);
 FOpenButton.Parent := FToolButtonPanel;
 FOpenButton.SetBounds(35,4,28,28);
 FOpenButton.Caption := '';
 FOpenButton.Flat := True;
 FOpenButton.Hint := 'Open an HTML page from disk and load it into the PageProducer visual editor. Unsaved changes are confirmed first. Shortcut: Ctrl+O.';
 FOpenButton.ShowHint := True;
 FOpenButton.OnClick := OpenClick;
 RESTDWLoadHTMLDesignerIcon(
  FOpenButton.Glyph,
  'toolbar_open.bmp'
 );
 FOpenButton.Caption := '';
 FSaveButton := TSpeedButton.Create(FToolButtonPanel);
 FSaveButton.Parent := FToolButtonPanel;
 FSaveButton.SetBounds(65,4,28,28);
 FSaveButton.Caption := '';
 FSaveButton.Flat := True;
 FSaveButton.Hint := 'Save the complete generated PageProducer page to disk. This command is enabled only when the document has been modified. Shortcut: Ctrl+S.';
 FSaveButton.ShowHint := True;
 FSaveButton.Enabled := False;
 FSaveButton.OnClick := SaveClick;
 RESTDWLoadHTMLDesignerSaveIcon(
  FSaveButton.Glyph
 );
 FSaveButton.NumGlyphs := 2;
 FSaveButton.Caption := '';
 FRefreshButton := TSpeedButton.Create(FToolButtonPanel);
 FRefreshButton.Parent := FToolButtonPanel;
 FRefreshButton.SetBounds(95,4,28,28);
 FRefreshButton.Caption := '';
 FRefreshButton.Flat := True;
 FRefreshButton.Hint := 'Refresh the WebViewer with the current PageProducer source.';
 FRefreshButton.ShowHint := True;
 FRefreshButton.OnClick := RefreshClick;
 BuildBrowserRefreshGlyph(FRefreshButton.Glyph);
 FRefreshButton.Caption := '';
 FHelpButton := TSpeedButton.Create(FToolButtonPanel);
 FHelpButton.Parent := FToolButtonPanel;
 FHelpButton.SetBounds(125,4,28,28);
 FHelpButton.Caption := '';
 FHelpButton.Font.Style := [fsBold];
 FHelpButton.Flat := True;
 FHelpButton.Hint := 'Open the complete REST Dataware Visual Web IDE help.';
 FHelpButton.ShowHint := True;
 FHelpButton.OnClick := HelpClick;
 RESTDWLoadHTMLDesignerIcon(
  FHelpButton.Glyph,
  'toolbar_help.bmp'
 );
 FDebugStartButton := TSpeedButton.Create(FToolButtonPanel);
 FDebugStartButton.Parent := FToolButtonPanel;
 FDebugStartButton.SetBounds(5,35,28,26);
 FDebugStartButton.Caption := '';
 FDebugStartButton.Flat := True;
 FDebugStartButton.Hint := 'Run/Continue JavaScript debugging. Lazarus shortcut: F9.';
 FDebugStartButton.ShowHint := True;
 FDebugStartButton.OnClick := DebugStartClick;
 FDebugStopButton := TSpeedButton.Create(FToolButtonPanel);
 FDebugStopButton.Parent := FToolButtonPanel;
 FDebugStopButton.SetBounds(35,35,28,26);
 FDebugStopButton.Caption := '';
 FDebugStopButton.Flat := True;
 FDebugStopButton.Hint := 'Stop debugging. Lazarus shortcut: Ctrl+F2.';
 FDebugStopButton.ShowHint := True;
 FDebugStopButton.Enabled := False;
 FDebugStopButton.OnClick := DebugStopClick;
 FDebugBreakpointButton := TSpeedButton.Create(FToolButtonPanel);
 FDebugBreakpointButton.Parent := FToolButtonPanel;
 FDebugBreakpointButton.SetBounds(65,35,28,26);
 FDebugBreakpointButton.Caption := '';
 FDebugBreakpointButton.Flat := True;
 FDebugBreakpointButton.Hint := 'Toggle breakpoint. Lazarus shortcut: F5; double-click the line-number gutter.';
 FDebugBreakpointButton.ShowHint := True;
 FDebugBreakpointButton.OnClick := ToggleBreakpointClick;
 FDebugClearButton := TSpeedButton.Create(FToolButtonPanel);
 FDebugClearButton.Parent := FToolButtonPanel;
 FDebugClearButton.SetBounds(95,35,28,26);
 FDebugClearButton.Caption := '';
 FDebugClearButton.Flat := True;
 FDebugClearButton.Hint := 'Clear all breakpoints.';
 FDebugClearButton.ShowHint := True;
 FDebugClearButton.OnClick := DebugClearBreakpointsClick;
 FDebugDevToolsButton := TSpeedButton.Create(FToolButtonPanel);
 FDebugDevToolsButton.Parent := FToolButtonPanel;
 FDebugDevToolsButton.SetBounds(125,35,28,26);
 FDebugDevToolsButton.Caption := '';
 FDebugDevToolsButton.Flat := True;
 FDebugDevToolsButton.Hint := 'Open WebView DevTools.';
 FDebugDevToolsButton.ShowHint := True;
 FDebugDevToolsButton.OnClick := DebugDevToolsClick;
 RESTDWLoadHTMLDesignerIcon(FDebugStartButton.Glyph,'toolbar_debug_start.bmp');
 RESTDWLoadHTMLDesignerStopDebugIcon(FDebugStopButton.Glyph);
 FDebugStopButton.NumGlyphs := 2;
 RESTDWLoadHTMLDesignerIcon(FDebugBreakpointButton.Glyph,'toolbar_debug_breakpoint.bmp');
 RESTDWLoadHTMLDesignerIcon(FDebugClearButton.Glyph,'toolbar_debug_clear.bmp');
 RESTDWLoadHTMLDesignerIcon(FDebugDevToolsButton.Glyph,'toolbar_debug_devtools.bmp');
 FPaletteTabs := TPageControl.Create(FToolbar);
 FPaletteTabs.Parent := FToolbar;
 FPaletteTabs.Align := alClient;
 FPaletteTabs.Height := 60;
 { Standard is intentionally the first component palette, matching
   Lazarus/Delphi and containing the most frequently used page controls. }
 LTab := TTabSheet.Create(FPaletteTabs);
 LTab.PageControl := FPaletteTabs;
 LTab.Caption := 'Standard';
 FMessagesPanel := TPanel.Create(Self);
 FMessagesPanel.Parent := Self;
 FMessagesPanel.Align := alBottom;
 FMessagesPanel.Height := 145;
 FMessagesPanel.Caption := '';
 BuildDockHeader(
  FMessagesPanel,
  FMessagesHeader,
  'Show Errors',
  3
 );
 FMessages := TStringGrid.Create(FMessagesPanel);
 FMessages.Parent := FMessagesPanel;
 FMessages.Align := alClient;
 FMessages.ColCount := 5;
 FMessages.RowCount := 1;
 FMessages.FixedRows := 0;
 FMessages.FixedCols := 0;
 FMessages.Options := [
  goFixedVertLine,
  goVertLine,
  goColSizing,
  goRangeSelect
 ];
 FMessages.Cells[0,0] := 'Type';
 FMessages.Cells[1,0] := 'File';
 FMessages.Cells[2,0] := 'Line';
 FMessages.Cells[3,0] := 'Column';
 FMessages.Cells[4,0] := 'Message';
 FMessages.ColWidths[0] := 80;
 FMessages.ColWidths[1] := 180;
 FMessages.ColWidths[2] := 60;
 FMessages.ColWidths[3] := 70;
 FMessagesPanel.OnResize := MessagesResize;
 FMessages.OnDblClick := MessagesDblClick;
 FMessages.OnKeyDown := MessagesKeyDown;
 FMessagesPopup := TPopupMenu.Create(Self);
 LMessagesMenuItem := TMenuItem.Create(FMessagesPopup);
 LMessagesMenuItem.Caption := 'Copy selected error(s)';
 LMessagesMenuItem.OnClick := MessagesCopySelectionClick;
 FMessagesPopup.Items.Add(LMessagesMenuItem);
 LMessagesMenuItem := TMenuItem.Create(FMessagesPopup);
 LMessagesMenuItem.Caption := '-';
 FMessagesPopup.Items.Add(LMessagesMenuItem);
 LMessagesMenuItem := TMenuItem.Create(FMessagesPopup);
 LMessagesMenuItem.Caption := 'Select all';
 LMessagesMenuItem.ShortCut := ShortCut(Ord('A'),[ssCtrl]);
 LMessagesMenuItem.OnClick := MessagesSelectAllClick;
 FMessagesPopup.Items.Add(LMessagesMenuItem);
 LMessagesMenuItem := TMenuItem.Create(FMessagesPopup);
 LMessagesMenuItem.Caption := 'Copy all errors';
 LMessagesMenuItem.ShortCut := ShortCut(Ord('C'),[ssCtrl,ssShift]);
 LMessagesMenuItem.OnClick := MessagesCopyAllClick;
 FMessagesPopup.Items.Add(LMessagesMenuItem);
 FMessages.PopupMenu := FMessagesPopup;
 FMessagesSplitter := TSplitter.Create(Self);
 FMessagesSplitter.Parent := Self;
 FMessagesSplitter.Align := alBottom;
 FMessagesSplitter.Height := 5;
 FAIConsole := Nil;
 FAIPanel := TPanel.Create(Self);
 FAIPanel.Parent := Self;
 FAIPanel.Align := alBottom;
 FAIPanel.Height := 225;
 FAIPanel.Caption := '';
 FAIPanel.Visible := False;
 BuildDockHeader(
  FAIPanel,
  FAIHeader,
  'AI Console',
  5
 );
 FAIConsole := TRESTDWHTMLAIConsolePanel.Create(Self);
 FAIConsole.Parent := FAIPanel;
 FAIConsole.Align := alClient;
 FAIConsole.OnBuildContext := AIPageContext;
 FAISplitter := TSplitter.Create(Self);
 FAISplitter.Parent := Self;
 FAISplitter.Align := alBottom;
 FAISplitter.Height := 5;
 FAISplitter.Visible := False;
 FLeftDockHost := TPanel.Create(Self);
 FLeftDockHost.Parent := Self;
 FLeftDockHost.Align := alLeft;
 FLeftDockHost.Width := 280;
 FLeftDockHost.Caption := '';
 FLeftDockHost.BevelOuter := bvNone;
 FColorToolPanel := TPanel.Create(FLeftDockHost);
 FColorToolPanel.Parent := FLeftDockHost;
 FColorToolPanel.Align := alTop;
 FColorToolPanel.Height := 172;
 FColorToolPanel.Caption := '';
 FColorToolPanel.BevelOuter := bvLowered;
 BuildDockHeader(
  FColorToolPanel,
  FColorToolHeader,
  'CSS Color Tool',
  6
 );
 With TLabel.Create(FColorToolPanel) Do
 Begin Parent := FColorToolPanel; SetBounds(8,34,16,20); Caption := 'R'; End;
 FColorR := TEdit.Create(FColorToolPanel);
 FColorR.Parent := FColorToolPanel;
 FColorR.SetBounds(24,31,42,22);
 FColorR.Text := '0';
 FColorR.OnChange := ColorRGBChange;
 With TLabel.Create(FColorToolPanel) Do
 Begin Parent := FColorToolPanel; SetBounds(70,34,16,20); Caption := 'G'; End;
 FColorG := TEdit.Create(FColorToolPanel);
 FColorG.Parent := FColorToolPanel;
 FColorG.SetBounds(86,31,42,22);
 FColorG.Text := '0';
 FColorG.OnChange := ColorRGBChange;
 With TLabel.Create(FColorToolPanel) Do
 Begin Parent := FColorToolPanel; SetBounds(132,34,16,20); Caption := 'B'; End;
 FColorB := TEdit.Create(FColorToolPanel);
 FColorB.Parent := FColorToolPanel;
 FColorB.SetBounds(148,31,42,22);
 FColorB.Text := '0';
 FColorB.OnChange := ColorRGBChange;
 FColorPreview := TPanel.Create(FColorToolPanel);
 FColorPreview.Parent := FColorToolPanel;
 FColorPreview.SetBounds(8,60,58,54);
 FColorPreview.Caption := '';
 FColorPreview.BevelOuter := bvLowered;
 FColorPreview.ParentBackground := False;
 FColorPreview.Color := 0;
 FColorPreview.Hint := 'Click to choose a color';
 FColorPreview.ShowHint := True;
 FColorPreview.OnClick := ColorPreviewClick;
 With TLabel.Create(FColorToolPanel) Do
 Begin Parent := FColorToolPanel; SetBounds(74,62,34,20); Caption := 'HEX'; End;
 FColorHex := TEdit.Create(FColorToolPanel);
 FColorHex.Parent := FColorToolPanel;
 FColorHex.SetBounds(108,59,82,22);
 FColorHex.Text := '#000000';
 FColorHex.OnChange := ColorHexChange;
 FColorCopyHex := TButton.Create(FColorToolPanel);
 FColorCopyHex.Parent := FColorToolPanel;
 FColorCopyHex.SetBounds(74,88,116,25);
 FColorCopyHex.Caption := 'Copy HEX';
 FColorCopyHex.OnClick := ColorCopyHexClick;
 FColorCopyRGB := TButton.Create(FColorToolPanel);
 FColorCopyRGB.Parent := FColorToolPanel;
 FColorCopyRGB.SetBounds(8,122,182,25);
 FColorCopyRGB.Caption := 'Copy RGB';
 FColorCopyRGB.OnClick := ColorCopyRGBClick;
 FProjectPanel := TPanel.Create(FLeftDockHost);
 FProjectPanel.Parent := FLeftDockHost;
 FProjectPanel.Align := alClient;
 FProjectPanel.Caption := '';
 BuildDockHeader(
  FProjectPanel,
  FProjectHeader,
  'Project Explorer',
  1
 );
 FProjectTree := TTreeView.Create(FProjectPanel);
 FProjectTree.Parent := FProjectPanel;
 FProjectTree.Align := alClient;
 FProjectTree.OnClick := ProjectTreeClick;
 FProjectSplitter := TSplitter.Create(Self);
 FProjectSplitter.Parent := Self;
 FProjectSplitter.Align := alLeft;
 FProjectSplitter.Width := 5;
 FInspectorSplitter := TSplitter.Create(Self);
 FInspectorSplitter.Parent := Self;
 FInspectorSplitter.Align := alRight;
 FInspectorSplitter.Width := 5;
 FRightDockHost := TPanel.Create(Self);
 FRightDockHost.Parent := Self;
 FRightDockHost.Align := alRight;
 FRightDockHost.Width := 320;
 FRightDockHost.BevelOuter := bvNone;
 FRightDockHost.Caption := '';
 FObjectBrowserPanel := TPanel.Create(FRightDockHost);
 FObjectBrowserPanel.Parent := FRightDockHost;
 FObjectBrowserPanel.Align := alTop;
 FObjectBrowserPanel.Height := 220;
 FObjectBrowserPanel.Constraints.MinHeight := 80;
 FObjectBrowserPanel.Caption := '';
 BuildDockHeader(
  FObjectBrowserPanel,
  FObjectBrowserHeader,
  'Object Browser',
  7
 );
 FObjectBrowserImages := TImageList.Create(Self);
 FObjectBrowserImages.Width := 16;
 FObjectBrowserImages.Height := 16;
 FObjectBrowserTree := TTreeView.Create(FObjectBrowserPanel);
 FObjectBrowserTree.Parent := FObjectBrowserPanel;
 FObjectBrowserTree.Align := alClient;
 FObjectBrowserTree.Images := FObjectBrowserImages;
 FObjectBrowserTree.AutoExpand := False;
 FObjectBrowserTree.OnClick := ObjectBrowserClick;
 FInspectorPanel := TPanel.Create(FRightDockHost);
 FInspectorPanel.Parent := FRightDockHost;
 FInspectorPanel.Align := alClient;
 FInspectorPanel.Constraints.MinHeight := 100;
 FInspectorPanel.Caption := '';
 FObjectBrowserSplitter := TSplitter.Create(FRightDockHost);
 FObjectBrowserSplitter.Parent := FRightDockHost;
 FObjectBrowserSplitter.Align := alTop;
 FObjectBrowserSplitter.Top := FObjectBrowserPanel.Height;
 FObjectBrowserSplitter.Height := 6;
 FObjectBrowserSplitter.AutoSnap := False;
 FObjectBrowserSplitter.MinSize := 80;
 FObjectBrowserSplitter.ResizeStyle := rsUpdate;
 BuildDockHeader(
  FInspectorPanel,
  FInspectorHeader,
  'Object Inspector',
  2
 );
 FInspectorPages := TPageControl.Create(FInspectorPanel); FInspectorPages.Parent := FInspectorPanel;
 FInspectorPages.Align := alClient;
 LTab := TTabSheet.Create(FInspectorPages); LTab.PageControl := FInspectorPages; LTab.Caption := 'Properties';
 FProperties := TStringGrid.Create(LTab);
 FProperties.Parent := LTab;
 FProperties.Align := alClient;
 FProperties.ColCount := 2;
 FProperties.RowCount := 1;
 FProperties.FixedRows := 0;
 FProperties.FixedCols := 1;
 FProperties.DefaultRowHeight := 21;
 FProperties.ColWidths[0] := 118;
 FProperties.ColWidths[1] := 145;
 FProperties.GridLineWidth := 0;
 FProperties.DefaultDrawing := False;
 FProperties.Options :=
  FProperties.Options +
   [goEditing,goColSizing,goDrawFocusSelected];
 FProperties.Cells[0,0] := 'Property';
 FProperties.Cells[1,0] := 'Value';
 FProperties.OnDrawCell := InspectorGridDrawCell;
 FProperties.OnExit := PropertiesEditingDone;
 FProperties.OnSetEditText := PropertiesSetEditText;
 LTab := TTabSheet.Create(FInspectorPages); LTab.PageControl := FInspectorPages; LTab.Caption := 'Events';
 FEvents := TStringGrid.Create(LTab);
 FEvents.Parent := LTab;
 FEvents.Align := alClient;
 FEvents.ColCount := 2;
 FEvents.RowCount := 1;
 FEvents.FixedRows := 0;
 FEvents.FixedCols := 1;
 FEvents.DefaultRowHeight := 21;
 FEvents.ColWidths[0] := 118;
 FEvents.ColWidths[1] := 145;
 FEvents.GridLineWidth := 0;
 FEvents.DefaultDrawing := False;
 FEvents.Options :=
  FEvents.Options +
   [goEditing,goColSizing,goDrawFocusSelected];
 FEvents.Cells[0,0] := 'Event';
 FEvents.Cells[1,0] := 'Handler';
 FEvents.OnDrawCell := InspectorGridDrawCell;
 FEvents.OnExit := EventsEditingDone;
 FEvents.OnDblClick := EventsDblClick;
 FWorkPanel := TPanel.Create(Self);
 FWorkPanel.Parent := Self;
 FWorkPanel.Align := alClient;
 FWorkPanel.Caption := '';
 FModeBar := TPanel.Create(FWorkPanel);
 FModeBar.Parent := FWorkPanel;
 FModeBar.Align := alTop;
 FModeBar.Height := 34;
 FModeBar.BevelOuter := bvLowered;
 FModeBar.Caption := '';
 FFormDesignButton := TSpeedButton.Create(FModeBar);
 FFormDesignButton.Parent := FModeBar;
 FFormDesignButton.SetBounds(6,4,105,26);
 FFormDesignButton.Caption := 'FormDesign';
 FFormDesignButton.GroupIndex := 1;
 FFormDesignButton.AllowAllUp := False;
 FFormDesignButton.Down := True;
 FFormDesignButton.OnClick := FormDesignButtonClick;
 FCodeEditorButton := TSpeedButton.Create(FModeBar);
 FCodeEditorButton.Parent := FModeBar;
 FCodeEditorButton.SetBounds(112,4,105,26);
 FCodeEditorButton.Caption := 'Code Editor';
 FCodeEditorButton.GroupIndex := 1;
 FCodeEditorButton.AllowAllUp := False;
 FCodeEditorButton.OnClick := CodeEditorButtonClick;
 { FDesign is kept only as an internal compatibility holder.
   The real Form Designer surface is TRESTDWHTMLWebView. }
 FDesign := TScrollBox.Create(FWorkPanel);
 FDesign.Parent := FWorkPanel;
 FDesign.Visible := False;
 FDesign.SetBounds(0,0,0,0);
 FPreviewPanel := TPanel.Create(FWorkPanel);
 FPreviewPanel.Parent := FWorkPanel;
 FPreviewPanel.Align := alClient;
 FPreviewPanel.Caption := '';
 BuildDockHeader(
  FPreviewPanel,
  FPreviewHeader,
  'FormDesign',
  4
 );
 FCodePages := TPageControl.Create(FWorkPanel);
 FCodePages.Parent := FWorkPanel;
 FCodePages.Align := alClient;
 FCodePages.Visible := False;
 FFullCodeTab := TTabSheet.Create(FCodePages); FFullCodeTab.PageControl := FCodePages; FFullCodeTab.Caption := 'Full Page'; FFullCodeTab.TabVisible := False;
 FHTMLTab := TTabSheet.Create(FCodePages); FHTMLTab.PageControl := FCodePages; FHTMLTab.Caption := 'HTML'; FHTMLTab.TabVisible := False;
 FCSSTab := TTabSheet.Create(FCodePages); FCSSTab.PageControl := FCodePages; FCSSTab.Caption := 'CSS'; FCSSTab.TabVisible := False;
 FJSTab := TTabSheet.Create(FCodePages); FJSTab.PageControl := FCodePages; FJSTab.Caption := 'JavaScript'; FJSTab.TabVisible := False;
 FHTMLHighlighter := TSynHTMLSyn.Create(Self);
 FCSSHighlighter := TSynCssSyn.Create(Self);
 FJSHighlighter := TSynJScriptSyn.Create(Self);
 FFullHTMLHighlighter := TSynHTMLSyn.Create(Self);
 FFullCSSHighlighter := TSynCssSyn.Create(Self);
 FFullJSHighlighter := TSynJScriptSyn.Create(Self);
 FFullHighlighter := TSynMultiSyn.Create(Self);
 FFullHighlighter.DefaultHighlighter := FFullHTMLHighlighter;
 {$IFDEF FPC}
 LScheme := TSynHighlighterMultiScheme(
  FFullHighlighter.Schemes.Add
 );
 {$ELSE}
 LScheme := TScheme(
  FFullHighlighter.Schemes.Add
 );
 {$ENDIF}
 LScheme.SchemeName := 'CSS';
 LScheme.CaseSensitive := False;
 LScheme.StartExpr := '<style[^>]*>';
 LScheme.EndExpr := '</style>';
 LScheme.Highlighter := FFullCSSHighlighter;
 {$IFDEF FPC}
 LScheme := TSynHighlighterMultiScheme(
  FFullHighlighter.Schemes.Add
 );
 {$ELSE}
 LScheme := TScheme(
  FFullHighlighter.Schemes.Add
 );
 {$ENDIF}
 LScheme.SchemeName := 'JavaScript';
 LScheme.CaseSensitive := False;
 LScheme.StartExpr := '<script[^>]*>';
 LScheme.EndExpr := '</script>';
 LScheme.Highlighter := FFullJSHighlighter;
 FFullCode := TSynEdit.Create(FFullCodeTab);
 FFullCode.Parent := FFullCodeTab;
 FFullCode.Align := alClient;
 FFullCode.Highlighter := FFullHighlighter;
 FFullCode.Font.Name := 'Courier New';
 FFullCode.Font.Size := 10;
 FFullCode.OnChange := FullCodeChanged;
 FFullCode.OnClick := CodeEditorClick;
 FFullCode.OnKeyUp := CodeEditorKeyUp;
 FFullCode.OnGutterClick := CodeGutterClick;
 FFullCode.OnMouseMove := CodeEditorMouseMove;
 FFullCode.OnDblClick := CodeEditorDblClick;
 FFullCode.Gutter.Visible := True;
 FFullCode.Gutter.AutoSize := True;
 {$IFNDEF FPC}
 FFullCode.Gutter.ShowLineNumbers := True;
 {$ENDIF}
 FHTML := TSynEdit.Create(FHTMLTab);
 FHTML.Parent := FHTMLTab;
 FHTML.Align := alClient;
 FHTML.Highlighter := FHTMLHighlighter;
 FHTML.Font.Name := 'Courier New';
 FHTML.Font.Size := 10;
 FHTML.Gutter.Visible := True;
 FHTML.Gutter.AutoSize := True;
 {$IFNDEF FPC}
 FHTML.Gutter.ShowLineNumbers := True;
 {$ENDIF}
  FHTML.OnChange := SourceChanged;
 FCSS := TSynEdit.Create(FCSSTab);
 FCSS.Parent := FCSSTab;
 FCSS.Align := alClient;
 FCSS.Highlighter := FCSSHighlighter;
 FCSS.Font.Name := 'Courier New';
 FCSS.Font.Size := 10;
 FCSS.Gutter.Visible := True;
 FCSS.Gutter.AutoSize := True;
 {$IFNDEF FPC}
 FCSS.Gutter.ShowLineNumbers := True;
 {$ENDIF}
  FCSS.OnChange := SourceChanged;
 FJS := TSynEdit.Create(FJSTab);
 FJS.Parent := FJSTab;
 FJS.Align := alClient;
 FJS.Highlighter := FJSHighlighter;
 FJS.Font.Name := 'Courier New';
 FJS.Font.Size := 10;
 FJS.Gutter.Visible := True;
 FJS.Gutter.AutoSize := True;
 {$IFNDEF FPC}
 FJS.Gutter.ShowLineNumbers := True;
 {$ENDIF}
 FJS.OnGutterClick := CodeGutterClick;
 FJS.OnDblClick := CodeEditorDblClick;
  FJS.OnChange := SourceChanged;
 FHTML.OnDragOver := CodeDragOver; FHTML.OnDragDrop := CodeDragDrop;
 FFullCode.OnDragOver := CodeDragOver; FFullCode.OnDragDrop := CodeDragDrop;
 FPreviewTimer := TTimer.Create(Self); FPreviewTimer.Enabled := False;
 FPreviewTimer.Interval := 250; FPreviewTimer.OnTimer := PreviewTimerTimer;
 FWebViewFirstTimer := TTimer.Create(Self);
 FWebViewFirstTimer.Enabled := False;
 FWebViewFirstTimer.Interval := 180;
 FWebViewFirstTimer.OnTimer := WebViewFirstTimerTimer;
 FWebViewFirstReady := False;
 FWebView := TRESTDWHTMLWebView.Create(Self);
 FWebView.Parent := FPreviewPanel;
 FWebView.Align := alClient;
 FWebView.OnReady := WebViewReady;
 FWebView.OnError := WebViewError;
 FWebView.OnPageError := WebViewPageError;
 FWebView.OnElementSelected := WebViewElementSelected;
 FWebView.OnHTMLChanged := WebViewHTMLChanged;
 FWebView.OnObjectTree := WebViewObjectTree;
 FWebView.OnDesignDragOver := DesignDragOver;
 FWebView.OnDesignDragDrop := DesignDragDrop;
 FPreviewPanel.OnDragOver := DesignDragOver;
 FPreviewPanel.OnDragDrop := DesignDragDrop;
 { WebView2 owns a native HWND and stays above normal sibling LCL controls.
   Use an owned borderless form as the drag target so Windows/LCL can accept
   palette drags while the rendered page remains visible underneath. }
 FWebDropOverlay := TForm.CreateNew(Self,1);
 FWebDropOverlay.BorderStyle := bsNone;
 FWebDropOverlay.FormStyle := fsStayOnTop;
 FWebDropOverlay.Caption := '';
 FWebDropOverlay.Color := clWhite;
 FWebDropOverlay.AlphaBlend := True;
 FWebDropOverlay.AlphaBlendValue := 1;
 FWebDropOverlay.Visible := False;
 FWebDropOverlay.OnDragOver := WebDropOverlayDragOver;
 FWebDropOverlay.OnDragDrop := WebDropOverlayDragDrop;
End;
Function TRESTDWHTMLDesignerForm.ProjectNodeKey(
 ANode : TTreeNode) : String;
Begin
 Result := '';
 While ANode <> Nil Do
 Begin
  If Result = '' Then
   Result := ANode.Text
  Else
   Result := ANode.Text + '/' + Result;
  ANode := ANode.Parent;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.SaveProjectExplorerState(
 AState : TStrings);
Var
 I : Integer;
 LNode : TTreeNode;
Begin
 If AState = Nil Then
  Exit;
 AState.Clear;
 If Not Assigned(FProjectTree) Then
  Exit;
 For I := 0 To FProjectTree.Items.Count - 1 Do
 Begin
  LNode :=
   FProjectTree.Items[I];
  If LNode.Expanded Then
   AState.Add(
    ProjectNodeKey(
     LNode
    )
   );
 End;
End;
Procedure TRESTDWHTMLDesignerForm.RestoreProjectExplorerState(
 AState : TStrings;
 AFirstBuild : Boolean);
Var
 I : Integer;
 LNode : TTreeNode;
 LKey : String;
Begin
 If Not Assigned(FProjectTree) Then
  Exit;
 If AFirstBuild Then
 Begin
  { Initial IDE layout only. After this first build the user's own collapsed /
    expanded state is always preserved exactly. }
  If FProjectTree.Items.Count > 0 Then
   FProjectTree.Items[0].Expand(False);
  For I := 0 To FProjectTree.Items.Count - 1 Do
  Begin
   LNode :=
    FProjectTree.Items[I];
   If SameText(
       LNode.Text,
       'HTML'
      ) And
      (LNode.Parent <> Nil) Then
   Begin
    LNode.Expand(False);
    Break;
   End;
  End;
  Exit;
 End;
 If AState = Nil Then
  Exit;
 For I := 0 To FProjectTree.Items.Count - 1 Do
 Begin
  LNode :=
   FProjectTree.Items[I];
  LKey :=
   ProjectNodeKey(
    LNode
   );
  If AState.IndexOf(LKey) >= 0 Then
   LNode.Expand(False)
  Else
   LNode.Collapse(False);
 End;
End;
Procedure TRESTDWHTMLDesignerForm.AddProjectNode(
 AParent : TTreeNode;
 const ACaption, ASearchText : String);
Var
 LNode : TTreeNode;
 LInfo : TRESTDWHTMLProjectNodeInfo;
Begin
 LInfo := TRESTDWHTMLProjectNodeInfo.Create;
 LInfo.Name := ACaption;
 LInfo.SearchText := ASearchText;
 FProjectItems.Add(LInfo);
 LNode := FProjectTree.Items.AddChild(
  AParent,
  ACaption
 );
 LNode.Data := LInfo;
End;
Procedure TRESTDWHTMLDesignerForm.ParseCSSProjectNodes(
 AParent : TTreeNode);
Var
 LLines : TStringList;
 I,
 P : Integer;
 LLine,
 LSelector : String;
Begin
 LLines := TStringList.Create;
 Try
  LLines.Text := FCSS.Text;
  For I := 0 To LLines.Count - 1 Do
  Begin
   LLine := Trim(LLines[I]);
   If LLine = '' Then
    Continue;
   P := Pos('{', LLine);
   If P > 1 Then
   Begin
    LSelector := Trim(
     Copy(LLine,1,P-1)
    );
    If LSelector <> '' Then
     AddProjectNode(
      AParent,
      LSelector,
      LSelector
     );
   End;
  End;
 Finally
  LLines.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.ParseJavaScriptProjectNodes(
 AParent : TTreeNode);
Var
 LLines : TStringList;
 I,
 P1,
 P2 : Integer;
 LLine,
 LLower,
 LName : String;
Begin
 LLines := TStringList.Create;
 Try
  LLines.Text := FJS.Text;
  For I := 0 To LLines.Count - 1 Do
  Begin
   LLine := Trim(LLines[I]);
   LLower := LowerCase(LLine);
   LName := '';
   P1 := Pos('function ', LLower);
   If P1 > 0 Then
   Begin
    Inc(P1, Length('function '));
    P2 := PosEx('(', LLine, P1);
    If P2 > P1 Then
     LName := Trim(
      Copy(LLine,P1,P2-P1)
     );
   End;
   If LName <> '' Then
    AddProjectNode(
     AParent,
     LName + '()',
     'function ' + LName
    );
  End;
 Finally
  LLines.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.BuildProjectExplorer;
Var
 I : Integer;
 LRoot,
 LHTML,
 LCSS,
 LJS : TTreeNode;
 LState : TStringList;
 LFirstBuild : Boolean;
Begin
 LFirstBuild :=
  FProjectTree.Items.Count = 0;
 LState := TStringList.Create;
 FProjectTree.Items.BeginUpdate;
 Try
  If Not LFirstBuild Then
   SaveProjectExplorerState(
    LState
   );
 For I := 0 To FProjectItems.Count - 1 Do
  TObject(FProjectItems[I]).Free;
 FProjectItems.Clear;
 FProjectTree.Items.Clear;
 LRoot := FProjectTree.Items.Add(
  Nil,
  Lang('PageProducerProject')
 );
 AddProjectNode(
  LRoot,
  Lang('FullPage'),
  '<!doctype html>'
 );
 LHTML := FProjectTree.Items.AddChild(
  LRoot,
  'HTML'
 );
 AddProjectNode(
  LHTML,
  Lang('PageOptions'),
  '<!doctype html>'
 );
 AddProjectNode(
  LHTML,
  Lang('IncludeScripts'),
  '<script src="/RESTDataware/webassets/'
 );
 AddProjectNode(
  LHTML,
  Lang('Header'),
  '<head>'
 );
 AddProjectNode(
  LHTML,
  Lang('Body'),
  '<body>'
 );
 If Pos(
     '<footer',
     LowerCase(FProducer.Produce)
    ) > 0 Then
  AddProjectNode(
   LHTML,
   Lang('Footer'),
   '<footer'
  );
 LCSS := FProjectTree.Items.AddChild(
  LRoot,
  'CSS'
 );
 ParseCSSProjectNodes(
  LCSS
 );
 LJS := FProjectTree.Items.AddChild(
  LRoot,
  'JavaScript'
 );
 ParseJavaScriptProjectNodes(
  LJS
 );
 FProjectTree.Items.AddChild(
  LRoot,
  Lang('Assets')
 );
 FProjectTree.Items.AddChild(
  LRoot,
  Lang('Components')
 );
 RestoreProjectExplorerState(
  LState,
  LFirstBuild
 );
 Finally
  FProjectTree.Items.EndUpdate;
  LState.Free;
 End;
End;
Function TRESTDWHTMLDesignerForm.FindCategoryTab(const ACategory : String) : TTabSheet;
Var I : Integer;
Begin
 Result := Nil;
 For I := 0 To FPaletteTabs.PageCount - 1 Do
  If SameText(FPaletteTabs.Pages[I].Caption,ACategory) Then Begin Result := FPaletteTabs.Pages[I]; Exit; End;
End;
Procedure TRESTDWHTMLDesignerForm.AddPaletteItem(
 const ACategory, AName, AHTML : String;
 const AIconFile : String);
Var
 Info : TRESTDWHTMLWebComponentInfo;
 Tab : TTabSheet;
 B : TSpeedButton;
 X : Integer;
 LLoaded : Boolean;
Begin
 Info := TRESTDWHTMLWebComponentInfo.Create;
 Info.Name := AName;
 Info.ClassName := AName;
 Info.Category := ACategory;
 Info.HTML := AHTML;
 Info.IconFile := AIconFile;
 FComponents.Add(Info);
 Tab := FindCategoryTab(ACategory);
 If Tab = Nil Then
 Begin
  Tab := TTabSheet.Create(FPaletteTabs);
  Tab.PageControl := FPaletteTabs;
  Tab.Caption := ACategory;
 End;
 X := Tab.ControlCount * 32;
 B := TSpeedButton.Create(Tab);
 B.Parent := Tab;
 B.SetBounds(X+4,4,30,30);
 B.Caption := '';
 B.Flat := True;
 B.Tag := FComponents.Count - 1;
 B.OnMouseDown := PaletteMouseDown;
 B.OnClick := PaletteClick;
 B.Hint := AName;
 B.ShowHint := True;
 LLoaded :=
  RESTDWLoadHTMLDesignerIcon(
   B.Glyph,
   AIconFile
  );
 If Not LLoaded And
    (AIconFile <> '') And
    FileExists(AIconFile) Then
 Begin
  Try
   B.Glyph.LoadFromFile(AIconFile);
   LLoaded := True;
  Except
   LLoaded := False;
  End;
 End;
 If Not LLoaded Then
  B.Caption := Copy(AName,1,1);
End;
Procedure TRESTDWHTMLDesignerForm.ScanPackagePalette;
Var
 LRoot,LFileName,LPackageName,LPackageJS,LSection,LName,LPalette,
 LClassName,LJSFileName,LHTML,LExtension,LIcon,LPlacement,
 LOptionsSection,LItem : String;
 LSearch : TSearchRec;
 LIni : TIniFile;
 LSections,LOptionKeys,LPackageFiles : TStringList;
 LInfo : TRESTDWHTMLWebComponentInfo;
 LVisual : Boolean;
 I,J,K,P,LOrder : Integer;
Begin
 For I := FComponents.Count - 1 DownTo 0 Do
  TObject(FComponents[I]).Free;
 FComponents.Clear;
 While FPaletteTabs.PageCount > 0 Do
  FPaletteTabs.Pages[0].Free;
 LRoot := RESTDWHTMLComponentsPath(ResolveEditorLibrariesPath);
 If Not DirectoryExists(LRoot) Then
  Exit;
 LSections := TStringList.Create;
 LOptionKeys := TStringList.Create;
 LPackageFiles := TStringList.Create;
 Try
  If FindFirst(IncludeTrailingPathDelimiter(LRoot)+'*.ini',faAnyFile,LSearch)=0 Then
  Begin
   Try
    Repeat
     LFileName := IncludeTrailingPathDelimiter(LRoot)+LSearch.Name;
     LIni := TIniFile.Create(LFileName);
     Try
      If LIni.ReadBool('Package','Enabled',True) Then
      Begin
       LOrder := LIni.ReadInteger('Package','Order',1000);
       LPackageFiles.Add(Format('%.8d|%s',[LOrder,LSearch.Name]));
      End;
     Finally
      LIni.Free;
     End;
    Until FindNext(LSearch)<>0;
   Finally
    FindClose(LSearch);
   End;
  End;
  LPackageFiles.Sort;
  For J := 0 To LPackageFiles.Count - 1 Do
  Begin
   LItem := LPackageFiles[J];
   P := Pos('|',LItem);
   If P>0 Then Delete(LItem,1,P);
   LFileName := IncludeTrailingPathDelimiter(LRoot)+LItem;
   LIni := TIniFile.Create(LFileName);
   Try
    LPackageName := LIni.ReadString('Package','Name',ChangeFileExt(LItem,''));
    LPackageJS := LIni.ReadString('Package','JsFileName','');
    LSections.Clear;
    LIni.ReadSections(LSections);
    For I := 0 To LSections.Count - 1 Do
    Begin
     LSection := LSections[I];
     If Pos('Component.',LSection)<>1 Then Continue;
     If Not LIni.ReadBool(LSection,'Installed',True) Then Continue;
     LName := Trim(LIni.ReadString(LSection,'Name',
      Copy(LSection,Length('Component.')+1,MaxInt)));
     LClassName := Trim(LIni.ReadString(LSection,'NameClass',''));
     LPalette := Trim(LIni.ReadString(LSection,'Palette','Custom'));
     LJSFileName := Trim(LIni.ReadString(LSection,'JsFileName',LPackageJS));
     If (LName='') Or (LClassName='') Or (LJSFileName='') Then Continue;
     If Not RESTDWHTMLResolveJSClass(
         ResolveEditorLibrariesPath,LJSFileName,LClassName,
         LHTML,LVisual,LPlacement) Then Continue;
     LExtension := LIni.ReadString(LSection,'html_extension','');
     If LExtension<>'' Then LHTML := LHTML+LExtension;
     LIcon := LIni.ReadString(LSection,'ClassIcon','');
     If (LIcon<>'') And Not FileExists(LIcon) Then
     Begin
      If FileExists(IncludeTrailingPathDelimiter(ResolveEditorLibrariesPath)+LIcon) Then
       LIcon := IncludeTrailingPathDelimiter(ResolveEditorLibrariesPath)+LIcon
      Else
       LIcon := IncludeTrailingPathDelimiter(LRoot)+LIcon;
     End;
     AddPaletteItem(LPalette,LName,LHTML,LIcon);
     If FComponents.Count=0 Then Continue;
     LInfo := TRESTDWHTMLWebComponentInfo(FComponents[FComponents.Count-1]);
     LInfo.PackageName := LPackageName;
     LInfo.ClassName := LClassName;
     LInfo.JsFileName := LJSFileName;
     LInfo.HTMLExtension := LExtension;
     LInfo.IsVisual := LVisual;
     LInfo.Placement := LPlacement;
     LInfo.ExternalURL := LIni.ReadString(LSection,'URL','');
     LInfo.LocalLibPath := LIni.ReadString(LSection,'LocalPath','');
     LInfo.FileName := LIni.ReadString(LSection,'LibFilename','');
     LInfo.Hint := LIni.ReadString(LSection,'Hint',LName);
     LOptionsSection := 'Options.'+
      Copy(LSection,Length('Component.')+1,MaxInt);
     LOptionKeys.Clear;
     LIni.ReadSection(LOptionsSection,LOptionKeys);
     LInfo.Options.Clear;
     For K := 0 To LOptionKeys.Count - 1 Do
      LInfo.Options.Values[LOptionKeys[K]] :=
       LIni.ReadString(LOptionsSection,LOptionKeys[K],'');
    End;
   Finally
    LIni.Free;
   End;
  End;
 Finally
  LPackageFiles.Free;
  LOptionKeys.Free;
  LSections.Free;
 End;
End;

Function TRESTDWHTMLDesignerForm.FindComponentByButton(
 AButton : TObject) : TRESTDWHTMLWebComponentInfo;
Var
 LIndex : Integer;
Begin
 Result := Nil;
 LIndex := -1;
 If AButton Is TSpeedButton Then
  LIndex := TSpeedButton(AButton).Tag
 Else If AButton Is TButton Then
  LIndex := TButton(AButton).Tag;
 If (LIndex >= 0) And
    (LIndex < FComponents.Count) Then
  Result :=
   TRESTDWHTMLWebComponentInfo(
    FComponents[LIndex]
   );
End;
Procedure TRESTDWHTMLDesignerForm.PaletteMouseDown(
 Sender : TObject;
 Button : TMouseButton;
 Shift : TShiftState;
 X, Y : Integer);
Begin
 FSelectedInfo :=
  FindComponentByButton(Sender);
 If (Button = mbLeft) And
    (FSelectedInfo <> Nil) And
    (Sender Is TControl) Then
 Begin
  ShowWebDropOverlay;
  TControl(Sender).BeginDrag(
   False,
   4
  );
 End;
End;
Procedure TRESTDWHTMLDesignerForm.PaletteClick(
 Sender : TObject);
Begin
 FInsertInfo := FindComponentByButton(Sender);
 If FInsertInfo = Nil Then
  Exit;
 InspectorSetComponent(FInsertInfo);
 If Not FInsertInfo.IsVisual Then
 Begin
  InsertNonVisualComponent(FInsertInfo);
  FInsertInfo := Nil;
  Exit;
 End;
 FModeBar.Caption :=
  'Insert ' + FInsertInfo.Name +
  ' - click a container or drag into FormDesign';
 If Not FDesignMode Then
  ShowFormDesign;
End;

Procedure TRESTDWHTMLDesignerForm.InsertNonVisualComponent(
 AInfo : TRESTDWHTMLWebComponentInfo);
Var
 LValue : String;
Begin
 If AInfo = Nil Then
  Exit;
 LValue := ComponentInstanceHTML(AInfo);
 If Trim(LValue) = '' Then
  Exit;
 If SameText(AInfo.Placement,'javascript') Then
  FProducer.JavaScript.Add(LValue)
 Else If SameText(AInfo.Placement,'head') Then
  FProducer.HTML.Insert(0,LValue)
 Else
  FProducer.HTML.Add(LValue);
 FHTML.Text := FProducer.HTML.Text;
 FJS.Text := FProducer.JavaScript.Text;
 RebuildFullCode;
 RebuildVisualDesign;
 BuildProjectExplorer;
 MarkModified;
End;

Procedure TRESTDWHTMLDesignerForm.ShowWebDropOverlay;
Var
 P : TPoint;
Begin
 If Not Assigned(FWebDropOverlay) Or
    Not FDesignMode Or
    Not Assigned(FWebView) Then
  Exit;
 P := FWebView.ClientToScreen(
  Types.Point(0,0)
 );
 FWebDropOverlay.SetBounds(
  P.X,
  P.Y,
  FWebView.ClientWidth,
  FWebView.ClientHeight
 );
 FWebDropOverlay.Show;
 FWebDropOverlay.BringToFront;
End;
Procedure TRESTDWHTMLDesignerForm.HideWebDropOverlay;
Begin
 If Assigned(FWebDropOverlay) Then
  FWebDropOverlay.Hide;
End;
Procedure TRESTDWHTMLDesignerForm.PaletteEndDrag(
 Sender, Target : TObject;
 X, Y : Integer);
Begin
 HideWebDropOverlay;
End;
Procedure TRESTDWHTMLDesignerForm.WebDropOverlayDragOver(
 Sender, Source : TObject;
 X, Y : Integer;
 State : TDragState;
 Var Accept : Boolean);
Begin
 FSelectedInfo := FindComponentByButton(Source);
 Accept := (FSelectedInfo <> Nil) And FSelectedInfo.IsVisual;
End;
Procedure TRESTDWHTMLDesignerForm.WebDropOverlayDragDrop(
 Sender, Source : TObject;
 X, Y : Integer);
Var
 LInfo : TRESTDWHTMLWebComponentInfo;
Begin
 LInfo :=
  FindComponentByButton(
   Source
  );
 HideWebDropOverlay;
 If LInfo = Nil Then
  Exit;
 FSelectedInfo := LInfo;
 FInsertInfo := Nil;
 FModeBar.Caption := '';
 InspectorSetComponent(
  LInfo
 );
 If Assigned(FWebView) And
    FWebView.Ready Then
 Begin
  FIgnoreNextInsertedSelection := True;
  InsertVisualComponent(LInfo,X,Y,True);
  MarkModified;
 End
 Else
 Begin
  If Trim(FHTML.Text) <> '' Then
   FHTML.Lines.Add('');
  FHTML.Lines.Add(
   ComponentInstanceHTML(LInfo)
  );
  SaveToProducer;
  MarkModified;
  RefreshWebView;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.DesignDragOver(Sender, Source : TObject; X,Y : Integer; State : TDragState; Var Accept : Boolean);
Var
 LInfo : TRESTDWHTMLWebComponentInfo;
Begin
 LInfo := FindComponentByButton(Source);
 Accept := (LInfo <> Nil) And LInfo.IsVisual;
End;
Procedure TRESTDWHTMLDesignerForm.DesignDragDrop(
 Sender, Source : TObject;
 X, Y : Integer);
Begin
 FSelectedInfo := FindComponentByButton(Source);
 FInsertInfo := Nil;
 FModeBar.Caption := '';
 If FSelectedInfo = Nil Then
  Exit;
 InspectorSetComponent(
  FSelectedInfo
 );
 If Assigned(FWebView) And
    FWebView.Ready Then
 Begin
  InsertVisualComponent(FSelectedInfo,X,Y,True);
  MarkModified;
 End
 Else
 Begin
  If Trim(FHTML.Text) <> '' Then
   FHTML.Lines.Add('');
  FHTML.Lines.Add(
   ComponentInstanceHTML(FSelectedInfo)
  );
  SaveToProducer;
  RefreshWebView;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.CodeDragOver(Sender, Source : TObject; X,Y : Integer; State : TDragState; Var Accept : Boolean);
Begin Accept := FindComponentByButton(Source)<>Nil; End;
Procedure TRESTDWHTMLDesignerForm.CodeDragDrop(
 Sender, Source : TObject;
 X,Y : Integer);
Var
 M : TSynEdit;
Begin
 FSelectedInfo :=
  FindComponentByButton(Source);
 If FSelectedInfo = Nil Then
  Exit;
 If Sender Is TSynEdit Then
 Begin
  M := TSynEdit(Sender);
  M.SelText := ComponentInstanceHTML(FSelectedInfo);
  MarkModified;
 End;
 InspectorSetComponent(
  FSelectedInfo
 );
End;
Procedure TRESTDWHTMLDesignerForm.ComponentClick(Sender : TObject);
Begin
 { Kept for compatibility. Component palette selection is handled by
   PaletteClick/FindComponentByButton using a list index in Tag. }
End;
Procedure TRESTDWHTMLDesignerForm.InspectorSetComponent(AInfo : TRESTDWHTMLWebComponentInfo);
 Procedure P(const N,V:String); Var R:Integer; Begin R:=FProperties.RowCount; FProperties.RowCount:=R+1; FProperties.Cells[0,R]:=N; FProperties.Cells[1,R]:=V; End;
 Procedure E(const N:String); Var R:Integer; Begin R:=FEvents.RowCount; FEvents.RowCount:=R+1; FEvents.Cells[0,R]:=N; FEvents.Cells[1,R]:=''; End;
Var H : String;
Begin
 FPageOptionsSelected := False;
 FSelectedInfo:=AInfo; FProperties.RowCount:=1; FEvents.RowCount:=1; If AInfo=Nil Then Exit; H:=LowerCase(AInfo.HTML);
 P('Name',AInfo.Name); P('Category',AInfo.Category); P('HTML',AInfo.HTML);
 If Pos(' id=',H)>0 Then P('ID',''); If Pos('class=',H)>0 Then P('Class','');
 If Pos('<input',H)>0 Then Begin P('Value',''); P('Placeholder',''); P('Required','False'); P('ReadOnly','False'); E('OnInput'); E('OnChange'); E('OnFocus'); E('OnBlur'); E('OnKeyDown'); E('OnKeyUp'); End
 Else If Pos('<button',H)>0 Then Begin P('Text',AInfo.Name); P('Enabled','True'); E('OnClick'); E('OnFocus'); E('OnBlur'); E('OnKeyDown'); End
 Else If Pos('<form',H)>0 Then Begin P('Action',''); P('Method','POST'); E('OnSubmit'); E('OnReset'); End
 Else If Pos('<select',H)>0 Then Begin P('Value',''); P('Multiple','False'); E('OnChange'); E('OnFocus'); E('OnBlur'); End
 Else If Pos('<img',H)>0 Then Begin P('Src',''); P('Alt',''); P('Width',''); P('Height',''); E('OnClick'); E('OnLoad'); E('OnError'); End
 Else Begin E('OnClick'); End;
End;
Procedure TRESTDWHTMLDesignerForm.InspectorSetPageOptions;
 Procedure P(const N,V : String);
 Var
  R : Integer;
 Begin
  R := FProperties.RowCount;
  FProperties.RowCount := R + 1;
   FProperties.Cells[0,R] := N;
  FProperties.Cells[1,R] := V;
 End;
 Procedure E(const N : String);
 Var
  R : Integer;
  V : String;
 Begin
  R := FEvents.RowCount;
  FEvents.RowCount := R + 1;
  V := PageEventCurrentHandler(N);
  FEvents.Cells[0,R] := N;
  FEvents.Cells[1,R] := V;
  FEventOriginalValues.Values[
   LowerCase(N)
  ] := V;
 End;
Begin
 FUpdatingInspector := True;
 Try
  FPageOptionsSelected := True;
  FSelectedElementID := '';
  FSelectedElementTag := '';
  FSelectedInfo := Nil;
  FSelectedFromCode := False;
     FProperties.RowCount := 1;
   FEvents.RowCount := 1;
  FEventOriginalValues.Clear;
  P('Title',FProducer.Title);
  P('Route',FProducer.Route);
  P('AutoDataTables',BoolToStr(FProducer.AutoDataTables,True));
  P('AutoCharts',BoolToStr(FProducer.AutoCharts,True));
  E('OnLoadPage');
  E('OnWindowLoad');
  E('OnBeforeUnload');
  E('OnUnload');
  E('OnResize');
  E('OnError');
  E('OnOnline');
  E('OnOffline');
  E('OnVisibilityChange');
  E('OnHashChange');
  E('OnPopState');
  FInspectorPages.ActivePageIndex := 0;
 Finally
  FUpdatingInspector := False;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.InspectorSetElement(
 const AElementID, ATagName, AText, AID, AClassName,
 AOuterHTML : String);
 Procedure P(const N,V : String);
 Var
  R : Integer;
 Begin
  R := FProperties.RowCount;
  FProperties.RowCount := R + 1;
   FProperties.Cells[0,R] := N;
  FProperties.Cells[1,R] := V;
 End;
 Procedure E(const N,V : String);
 Var
  R : Integer;
 Begin
  R := FEvents.RowCount;
  FEvents.RowCount := R + 1;
   FEvents.Cells[0,R] := N;
  FEvents.Cells[1,R] := V;
  FEventOriginalValues.Values[
   LowerCase(N)
  ] := V;
 End;
 Function Attr(const AName : String) : String;
 Var
  LLow,
  LNeedle : String;
  P1,
  P2 : Integer;
  Q : Char;
 Begin
  Result := '';
  LLow := LowerCase(AOuterHTML);
  LNeedle := LowerCase(AName) + '=';
  P1 := Pos(LNeedle,LLow);
  If P1 = 0 Then
   Exit;
  Inc(P1,Length(LNeedle));
  While (P1 <= Length(AOuterHTML)) And
        (AOuterHTML[P1] = ' ') Do
   Inc(P1);
  If P1 > Length(AOuterHTML) Then
   Exit;
  If (AOuterHTML[P1] = #39) Or
     (AOuterHTML[P1] = '"') Then
  Begin
   Q := AOuterHTML[P1];
   Inc(P1);
   P2 := P1;
   While (P2 <= Length(AOuterHTML)) And
         (AOuterHTML[P2] <> Q) Do
    Inc(P2);
   Result := Copy(AOuterHTML,P1,P2-P1);
  End
  Else
  Begin
   P2 := P1;
   While (P2 <= Length(AOuterHTML)) And
         (AOuterHTML[P2] > ' ') And
         (AOuterHTML[P2] <> '>') Do
    Inc(P2);
   Result := Copy(AOuterHTML,P1,P2-P1);
  End;
 End;
 Procedure CommonProperties;
 Begin
  P('ID',AID);
  P('Class',AClassName);
  P('Title',Attr('title'));
  P('Style',Attr('style'));
  P('Name',Attr('name'));
  P('Role',Attr('role'));
  P('TabIndex',Attr('tabindex'));
  P('AccessKey',Attr('accesskey'));
  P('Hidden',Attr('hidden'));
  P('Draggable',Attr('draggable'));
  P('ContentEditable',Attr('contenteditable'));
  P('SpellCheck',Attr('spellcheck'));
  P('Dir',Attr('dir'));
  P('Lang',Attr('lang'));
  P('DataToggle',Attr('data-bs-toggle'));
  P('DataTarget',Attr('data-bs-target'));
  P('DataDismiss',Attr('data-bs-dismiss'));
  P('DataPlacement',Attr('data-bs-placement'));
  P('AriaLabel',Attr('aria-label'));
  P('AriaHidden',Attr('aria-hidden'));
  P('AriaExpanded',Attr('aria-expanded'));
  P('AriaControls',Attr('aria-controls'));
  P('AriaDescribedBy',Attr('aria-describedby'));
 End;
 Procedure CommonEvents;
 Begin
  E('OnClick',Attr('onclick'));
  E('OnDblClick',Attr('ondblclick'));
  E('OnMouseDown',Attr('onmousedown'));
  E('OnMouseUp',Attr('onmouseup'));
  E('OnMouseMove',Attr('onmousemove'));
  E('OnMouseEnter',Attr('onmouseenter'));
  E('OnMouseLeave',Attr('onmouseleave'));
  E('OnMouseOver',Attr('onmouseover'));
  E('OnMouseOut',Attr('onmouseout'));
  E('OnContextMenu',Attr('oncontextmenu'));
  E('OnWheel',Attr('onwheel'));
  E('OnFocus',Attr('onfocus'));
  E('OnBlur',Attr('onblur'));
  E('OnKeyDown',Attr('onkeydown'));
  E('OnKeyUp',Attr('onkeyup'));
  E('OnKeyPress',Attr('onkeypress'));
  E('OnCopy',Attr('oncopy'));
  E('OnCut',Attr('oncut'));
  E('OnPaste',Attr('onpaste'));
  E('OnDragStart',Attr('ondragstart'));
  E('OnDrag',Attr('ondrag'));
  E('OnDragEnd',Attr('ondragend'));
  E('OnDragEnter',Attr('ondragenter'));
  E('OnDragOver',Attr('ondragover'));
  E('OnDragLeave',Attr('ondragleave'));
  E('OnDrop',Attr('ondrop'));
 End;
Var
 LTag : String;
Begin
 FPageOptionsSelected := False;
 FUpdatingInspector := True;
 Try
  FSelectedElementID := AElementID;
  FSelectedElementTag := LowerCase(ATagName);
  FSelectedElementOuterHTML := AOuterHTML;
  FSelectedInfo := Nil;
     FProperties.RowCount := 1;
   FEvents.RowCount := 1;
  FEventOriginalValues.Clear;
  LTag := LowerCase(ATagName);
  P('Tag',LTag);
  P('Text',AText);
  CommonProperties;
  If LTag = 'a' Then
  Begin
   P('Href',Attr('href'));
   P('Target',Attr('target'));
   P('Rel',Attr('rel'));
   P('Download',Attr('download'));
   P('Hreflang',Attr('hreflang'));
   P('Type',Attr('type'));
  End
  Else If LTag = 'img' Then
  Begin
   P('Src',Attr('src'));
   P('Alt',Attr('alt'));
   P('Width',Attr('width'));
   P('Height',Attr('height'));
   P('Loading',Attr('loading'));
   P('SrcSet',Attr('srcset'));
   P('Sizes',Attr('sizes'));
   P('CrossOrigin',Attr('crossorigin'));
   P('ReferrerPolicy',Attr('referrerpolicy'));
  End
  Else If LTag = 'input' Then
  Begin
   P('Type',Attr('type'));
   P('Value',Attr('value'));
   P('Placeholder',Attr('placeholder'));
   P('Min',Attr('min'));
   P('Max',Attr('max'));
   P('Step',Attr('step'));
   P('MinLength',Attr('minlength'));
   P('MaxLength',Attr('maxlength'));
   P('Pattern',Attr('pattern'));
   P('Size',Attr('size'));
   P('Accept',Attr('accept'));
   P('AutoComplete',Attr('autocomplete'));
   P('InputMode',Attr('inputmode'));
   P('Required',Attr('required'));
   P('ReadOnly',Attr('readonly'));
   P('Disabled',Attr('disabled'));
   P('Checked',Attr('checked'));
   P('Multiple',Attr('multiple'));
  End
  Else If LTag = 'textarea' Then
  Begin
   P('Value',AText);
   P('Placeholder',Attr('placeholder'));
   P('Rows',Attr('rows'));
   P('Cols',Attr('cols'));
   P('MinLength',Attr('minlength'));
   P('MaxLength',Attr('maxlength'));
   P('Wrap',Attr('wrap'));
   P('AutoComplete',Attr('autocomplete'));
   P('Required',Attr('required'));
   P('ReadOnly',Attr('readonly'));
   P('Disabled',Attr('disabled'));
  End
  Else If LTag = 'select' Then
  Begin
   P('Value',AText);
   P('Size',Attr('size'));
   P('Required',Attr('required'));
   P('Disabled',Attr('disabled'));
   P('Multiple',Attr('multiple'));
  End
  Else If LTag = 'option' Then
  Begin
   P('Value',Attr('value'));
   P('Label',Attr('label'));
   P('Selected',Attr('selected'));
   P('Disabled',Attr('disabled'));
  End
  Else If LTag = 'button' Then
  Begin
   P('Type',Attr('type'));
   P('Value',Attr('value'));
   P('Disabled',Attr('disabled'));
   P('Form',Attr('form'));
  End
  Else If LTag = 'form' Then
  Begin
   P('Action',Attr('action'));
   P('Method',Attr('method'));
   P('EncType',Attr('enctype'));
   P('Target',Attr('target'));
   P('AutoComplete',Attr('autocomplete'));
   P('NoValidate',Attr('novalidate'));
  End
  Else If LTag = 'label' Then
   P('For',Attr('for'))
  Else If (LTag = 'ol') Or
          (LTag = 'li') Then
  Begin
   P('Type',Attr('type'));
   P('Start',Attr('start'));
   P('Value',Attr('value'));
  End
  Else If LTag = 'table' Then
  Begin
   P('CellPadding',Attr('cellpadding'));
   P('CellSpacing',Attr('cellspacing'));
  End
  Else If (LTag = 'td') Or
          (LTag = 'th') Then
  Begin
   P('ColSpan',Attr('colspan'));
   P('RowSpan',Attr('rowspan'));
   P('Headers',Attr('headers'));
   P('Scope',Attr('scope'));
  End
  Else If LTag = 'iframe' Then
  Begin
   P('Src',Attr('src'));
   P('Width',Attr('width'));
   P('Height',Attr('height'));
   P('Loading',Attr('loading'));
   P('Allow',Attr('allow'));
   P('Sandbox',Attr('sandbox'));
   P('ReferrerPolicy',Attr('referrerpolicy'));
  End
  Else If (LTag = 'audio') Or
          (LTag = 'video') Then
  Begin
   P('Src',Attr('src'));
   P('AutoPlay',Attr('autoplay'));
   P('Controls',Attr('controls'));
   P('Loop',Attr('loop'));
   P('Muted',Attr('muted'));
   P('Preload',Attr('preload'));
   If LTag = 'video' Then
   Begin
    P('Poster',Attr('poster'));
    P('Width',Attr('width'));
    P('Height',Attr('height'));
   End;
  End
  Else If LTag = 'progress' Then
  Begin
   P('Value',Attr('value'));
   P('Max',Attr('max'));
  End
  Else If LTag = 'meta' Then
  Begin
   P('Charset',Attr('charset'));
   P('Content',Attr('content'));
   P('HttpEquiv',Attr('http-equiv'));
  End
  Else If LTag = 'script' Then
  Begin
   P('Src',Attr('src'));
   P('Type',Attr('type'));
   P('Async',Attr('async'));
   P('Defer',Attr('defer'));
  End
  Else If LTag = 'link' Then
  Begin
   P('Href',Attr('href'));
   P('Rel',Attr('rel'));
   P('Type',Attr('type'));
   P('Media',Attr('media'));
  End;
  P('HTML',AOuterHTML);
  CommonEvents;
  If (LTag = 'input') Or
     (LTag = 'textarea') Or
     (LTag = 'select') Then
  Begin
   E('OnInput',Attr('oninput'));
   E('OnChange',Attr('onchange'));
   E('OnSelect',Attr('onselect'));
   E('OnInvalid',Attr('oninvalid'));
  End;
  If LTag = 'form' Then
  Begin
   E('OnSubmit',Attr('onsubmit'));
   E('OnReset',Attr('onreset'));
  End;
  If (LTag = 'img') Or
     (LTag = 'iframe') Or
     (LTag = 'script') Or
     (LTag = 'link') Or
     (LTag = 'audio') Or
     (LTag = 'video') Then
  Begin
   E('OnLoad',Attr('onload'));
   E('OnError',Attr('onerror'));
  End;
  If (LTag = 'audio') Or
     (LTag = 'video') Then
  Begin
   E('OnPlay',Attr('onplay'));
   E('OnPause',Attr('onpause'));
   E('OnEnded',Attr('onended'));
   E('OnTimeUpdate',Attr('ontimeupdate'));
   E('OnVolumeChange',Attr('onvolumechange'));
  End;
 Finally
  FUpdatingInspector := False;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.InspectorGridDrawCell(
 Sender : TObject;
 ACol, ARow : Integer;
 ARect : TRect;
 AState : TGridDrawState);
Var
 LGrid : TStringGrid;
 LText : String;
 LTextRect : TRect;
Begin
 If Not (Sender Is TStringGrid) Then
  Exit;
 LGrid := TStringGrid(Sender);
 If ARow = 0 Then
 Begin
  LGrid.Canvas.Brush.Color := clBtnFace;
  LGrid.Canvas.Font.Color := clBtnText;
  LGrid.Canvas.Font.Style := [fsBold];
 End
 Else If gdSelected In AState Then
 Begin
  LGrid.Canvas.Brush.Color := clHighlight;
  LGrid.Canvas.Font.Color := clHighlightText;
  LGrid.Canvas.Font.Style := [];
 End
 Else
 Begin
  If ACol = 0 Then
   LGrid.Canvas.Brush.Color := clBtnFace
  Else
   LGrid.Canvas.Brush.Color := clWindow;
  LGrid.Canvas.Font.Color := clWindowText;
  LGrid.Canvas.Font.Style := [];
 End;
 LGrid.Canvas.FillRect(
  ARect
 );
 LText := LGrid.Cells[ACol,ARow];
 LTextRect := ARect;
 Inc(LTextRect.Left,5);
 Dec(LTextRect.Right,3);
 LGrid.Canvas.TextRect(
  LTextRect,
  LTextRect.Left,
  LTextRect.Top + 3,
  LText
 );
 { Lazarus Object Inspector visual model: one clean vertical divider
   between property/event name and editable value, no boxed cells. }
 If ACol = 0 Then
 Begin
  LGrid.Canvas.Pen.Color := clBtnShadow;
  LGrid.Canvas.MoveTo(
   ARect.Right - 1,
   ARect.Top
  );
  LGrid.Canvas.LineTo(
   ARect.Right - 1,
   ARect.Bottom
  );
 End;
End;
Procedure TRESTDWHTMLDesignerForm.ApplyPropertyValue(
 const AProperty, AValue : String);
Begin
 If FUpdatingInspector Or
    (AProperty = '') Then
  Exit;
 If FPageOptionsSelected Then
 Begin
  If SameText(AProperty,'Title') Then
   FProducer.Title := AValue
  Else If SameText(AProperty,'Route') Then
   FProducer.Route := AValue
  Else If SameText(AProperty,'AutoDataTables') Then
   FProducer.AutoDataTables :=
    SameText(AValue,'True') Or
    SameText(AValue,'1') Or
    SameText(AValue,'Yes')
  Else If SameText(AProperty,'AutoCharts') Then
   FProducer.AutoCharts :=
    SameText(AValue,'True') Or
    SameText(AValue,'1') Or
    SameText(AValue,'Yes');
  RebuildFullCode;
  BuildProjectExplorer;
  RefreshWebView;
  SetModified(True);
  Exit;
 End;
 If (FSelectedElementID = '') Or
    Not Assigned(FWebView) Or
    SameText(AProperty,'Tag') Then
  Exit;
 If FSelectedFromCode Then
  UpdateSelectedCodeElement(
   AProperty,
   AValue
  )
 Else
  FWebView.UpdateSelectedElement(
   AProperty,
   AValue
  );
End;
Procedure TRESTDWHTMLDesignerForm.PropertiesSetEditText(
 Sender : TObject; ACol, ARow : Integer; const Value : String);
Var
 LProperty : String;
Begin
 If FUpdatingInspector Or
    (ACol <> 1) Or
    (ARow < 1) Then
  Exit;
 LProperty := Trim(FProperties.Cells[0,ARow]);
 ApplyPropertyValue(LProperty,Value);
End;
Procedure TRESTDWHTMLDesignerForm.PropertiesEditingDone(
 Sender : TObject);
Var
 LRow : Integer;
 LProperty,
 LValue : String;
Begin
 If FUpdatingInspector Then
  Exit;
 LRow := FProperties.Row;
 If LRow < 1 Then
  Exit;
 LProperty := Trim(FProperties.Cells[0,LRow]);
 LValue := FProperties.Cells[1,LRow];
 ApplyPropertyValue(LProperty,LValue);
End;
Procedure TRESTDWHTMLDesignerForm.EventsEditingDone(
 Sender : TObject);
Var
 LRow : Integer;
 LEvent,
 LHandler,
 LOldHandler,
 LOldHandlerName : String;
Begin
 If FUpdatingInspector Then
  Exit;
 LRow := FEvents.Row;
 If LRow < 1 Then
  Exit;
 LEvent := Trim(
  FEvents.Cells[0,LRow]
 );
 LHandler :=
  Trim(
   FEvents.Cells[1,LRow]
  );
 If LEvent = '' Then
  Exit;
 LOldHandler :=
  FEventOriginalValues.Values[
   LowerCase(LEvent)
  ];
 If FPageOptionsSelected Then
 Begin
  If (LHandler = '') And
     (LOldHandler <> '') Then
   RemovePageEvent(
    LEvent,
    LOldHandler
   )
  Else If (LHandler <> '') And
          Not SameText(
           LHandler,
           LOldHandler
          ) Then
  Begin
   RemovePageEvent(
    LEvent,
    LOldHandler
   );
   OpenOrCreatePageEvent(
    LEvent,
    LHandler
   );
  End;
  FEventOriginalValues.Values[
   LowerCase(LEvent)
  ] := LHandler;
  Exit;
 End;
 If (FSelectedElementID = '') Or
    Not Assigned(FWebView) Then
  Exit;
 LOldHandlerName :=
  ExtractHandlerName(
   LOldHandler
  );
 If FSelectedFromCode Then
  UpdateSelectedCodeElement(
   LEvent,
   LHandler
  )
 Else
  FWebView.UpdateSelectedElement(
   LEvent,
   LHandler
  );
 FEventOriginalValues.Values[
  LowerCase(LEvent)
 ] := LHandler;
 If (LHandler = '') And
    (LOldHandlerName <> '') Then
  RemoveEmptyJavaScriptHandler(
   LOldHandlerName
  );
End;
Function TRESTDWHTMLDesignerForm.ExtractHandlerName(
 const AHandlerText : String) : String;
Var
 LText : String;
 I : Integer;
Begin
 Result := '';
 LText := Trim(AHandlerText);
 If LText = '' Then
  Exit;
 I := 1;
 While (I <= Length(LText)) And
       Not (LText[I] In ['A'..'Z','a'..'z','_','$']) Do
  Inc(I);
 While (I <= Length(LText)) And
       (LText[I] In ['A'..'Z','a'..'z','0'..'9','_','$']) Do
 Begin
  Result := Result + LText[I];
  Inc(I);
 End;
End;
Function TRESTDWHTMLDesignerForm.MakeEventHandlerName(
 const AEventName : String) : String;
Var
 LBase,
 LID,
 LEvent,
 LCandidate : String;
 I,
 N : Integer;
Begin
 LID := '';
 For I := 1 To FProperties.RowCount - 1 Do
  If SameText(
      FProperties.Cells[0,I],
      'ID'
     ) Then
  Begin
   LID := Trim(
    FProperties.Cells[1,I]
   );
   Break;
  End;
 If LID <> '' Then
  LBase := LID
 Else If FSelectedElementTag <> '' Then
  LBase := FSelectedElementTag
 Else
  LBase := 'Component';
 For I := Length(LBase) DownTo 1 Do
  If Not (LBase[I] In
      ['A'..'Z','a'..'z','0'..'9','_','$']) Then
   Delete(LBase,I,1);
 If LBase = '' Then
  LBase := 'Component';
 If LBase[1] In ['0'..'9'] Then
  LBase := 'Component' + LBase;
 LEvent := AEventName;
 If Copy(
     LowerCase(LEvent),
     1,
     2
    ) = 'on' Then
  Delete(LEvent,1,2);
 If LEvent = '' Then
  LEvent := 'Event';
 LEvent[1] := UpCase(LEvent[1]);
 LCandidate :=
  LBase +
  LEvent;
 N := 1;
 While Pos(
        LowerCase('function ' + LCandidate + '('),
        LowerCase(FJS.Text)
       ) > 0 Do
 Begin
  Inc(N);
  LCandidate :=
   LBase +
   LEvent +
   IntToStr(N);
 End;
 Result := LCandidate;
End;
Function TRESTDWHTMLDesignerForm.JavaScriptHandlerReferenceCount(
 const AHandlerName : String) : Integer;
 Procedure CountInText(
  const AText,
  ANeedle : String;
  Var ACount : Integer);
 Var
  LText : String;
  P : Integer;
 Begin
  LText := LowerCase(AText);
  P := Pos(
   LowerCase(ANeedle),
   LText
  );
  While P > 0 Do
  Begin
   Inc(ACount);
   Delete(
    LText,
    1,
    P + Length(ANeedle) - 1
   );
   P := Pos(
    LowerCase(ANeedle),
    LText
   );
  End;
 End;
Var
 LNeedle,
 LJS,
 LDeclaration : String;
 LDeclarationCount : Integer;
Begin
 Result := 0;
 If Trim(AHandlerName) = '' Then
  Exit;
 LNeedle :=
  AHandlerName +
  '(';
 CountInText(
  FProducer.HTML.Text,
  LNeedle,
  Result
 );
 { Count JavaScript calls/references too, but exclude the function's own
   declaration from the reference total. }
 LJS := FJS.Text;
 CountInText(
  LJS,
  LNeedle,
  Result
 );
 LDeclaration :=
  'function ' +
  AHandlerName +
  '(';
 LDeclarationCount := 0;
 CountInText(
  LJS,
  LDeclaration,
  LDeclarationCount
 );
 Dec(
  Result,
  LDeclarationCount
 );
 If Result < 0 Then
  Result := 0;
End;
Procedure TRESTDWHTMLDesignerForm.RemoveEmptyJavaScriptHandler(
 const AHandlerName : String);
Var
 LText,
 LLower,
 LNeedle,
 LBody : String;
 PStart,
 POpen,
 PClose,
 I,
 LDepth : Integer;
Begin
 If Trim(AHandlerName) = '' Then
  Exit;
 SaveToProducer;
 If JavaScriptHandlerReferenceCount(AHandlerName) > 0 Then
  Exit;
 LText := FJS.Text;
 LLower := LowerCase(LText);
 LNeedle :=
  LowerCase(
   'function ' + AHandlerName + '('
  );
 PStart := Pos(
  LNeedle,
  LLower
 );
 If PStart = 0 Then
  Exit;
 POpen := PosEx(
  '{',
  LText,
  PStart
 );
 If POpen = 0 Then
  Exit;
 LDepth := 1;
 I := POpen + 1;
 While (I <= Length(LText)) And
       (LDepth > 0) Do
 Begin
  If LText[I] = '{' Then
   Inc(LDepth)
  Else If LText[I] = '}' Then
   Dec(LDepth);
  Inc(I);
 End;
 If LDepth <> 0 Then
  Exit;
 PClose := I - 1;
 LBody := Trim(
  Copy(
   LText,
   POpen + 1,
   PClose-POpen-1
  )
 );
 { Only generated/declarative empty scopes are automatically removed.
   Real programming is always preserved. }
 If LBody <> '' Then
  Exit;
 While (PClose < Length(LText)) And
       (LText[PClose+1] In [#13,#10,' ',#9]) Do
  Inc(PClose);
 FUpdating := True;
 Try
  Delete(
   LText,
   PStart,
   PClose-PStart+1
  );
  FJS.Text := Trim(LText);
  FProducer.JavaScript.Assign(
   FJS.Lines
  );
 Finally
  FUpdating := False;
 End;
 SetModified(
  True
 );
 RebuildFullCode;
 BuildProjectExplorer;
End;
Function TRESTDWHTMLDesignerForm.PageEventDefaultHandler(
 const AEventName : String) : String;
Begin
 If SameText(AEventName,'OnLoadPage') Then
  Result := 'LoadPage'
 Else If SameText(AEventName,'OnWindowLoad') Then
  Result := 'WindowLoad'
 Else If SameText(AEventName,'OnBeforeUnload') Then
  Result := 'BeforeUnloadPage'
 Else If SameText(AEventName,'OnUnload') Then
  Result := 'UnloadPage'
 Else If SameText(AEventName,'OnResize') Then
  Result := 'ResizePage'
 Else If SameText(AEventName,'OnError') Then
  Result := 'ErrorPage'
 Else If SameText(AEventName,'OnOnline') Then
  Result := 'OnlinePage'
 Else If SameText(AEventName,'OnOffline') Then
  Result := 'OfflinePage'
 Else If SameText(AEventName,'OnVisibilityChange') Then
  Result := 'VisibilityChangePage'
 Else If SameText(AEventName,'OnHashChange') Then
  Result := 'HashChangePage'
 Else If SameText(AEventName,'OnPopState') Then
  Result := 'PopStatePage'
 Else
  Result := 'PageEvent';
End;
Function TRESTDWHTMLDesignerForm.PageEventListener(
 const AEventName, AHandlerName : String) : String;
Begin
 If SameText(AEventName,'OnLoadPage') Then
  Result :=
   'document.addEventListener(''DOMContentLoaded'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnWindowLoad') Then
  Result :=
   'window.addEventListener(''load'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnBeforeUnload') Then
  Result :=
   'window.addEventListener(''beforeunload'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnUnload') Then
  Result :=
   'window.addEventListener(''unload'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnResize') Then
  Result :=
   'window.addEventListener(''resize'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnError') Then
  Result :=
   'window.addEventListener(''error'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnOnline') Then
  Result :=
   'window.addEventListener(''online'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnOffline') Then
  Result :=
   'window.addEventListener(''offline'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnVisibilityChange') Then
  Result :=
   'document.addEventListener(''visibilitychange'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnHashChange') Then
  Result :=
   'window.addEventListener(''hashchange'', ' +
   AHandlerName + ');'
 Else If SameText(AEventName,'OnPopState') Then
  Result :=
   'window.addEventListener(''popstate'', ' +
   AHandlerName + ');'
 Else
  Result := '';
End;
Function TRESTDWHTMLDesignerForm.PageEventCurrentHandler(
 const AEventName : String) : String;
Var
 LMarker,
 LLine : String;
 I,
 P : Integer;
Begin
 Result := '';
 LMarker :=
  '// DS4L-PAGE-EVENT:' +
  AEventName +
  '=';
 For I := 0 To FJS.Lines.Count - 1 Do
 Begin
  LLine := Trim(
   FJS.Lines[I]
  );
  P := Pos(
   LowerCase(LMarker),
   LowerCase(LLine)
  );
  If P = 1 Then
  Begin
   Result := Trim(
    Copy(
     LLine,
     Length(LMarker) + 1,
     MaxInt
    )
   );
   Exit;
  End;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.RemovePageEvent(
 const AEventName, AHandlerName : String);
Var
 LHandler,
 LListener,
 LMarker : String;
 I : Integer;
Begin
 LHandler := Trim(AHandlerName);
 If LHandler = '' Then
  LHandler :=
   PageEventDefaultHandler(
    AEventName
   );
 LListener :=
  PageEventListener(
   AEventName,
   LHandler
  );
 LMarker :=
  '// DS4L-PAGE-EVENT:' +
  AEventName +
  '=' +
  LHandler;
 For I := FJS.Lines.Count - 1 DownTo 0 Do
  If SameText(
      Trim(FJS.Lines[I]),
      Trim(LListener)
     ) Or
     SameText(
      Trim(FJS.Lines[I]),
      Trim(LMarker)
     ) Then
   FJS.Lines.Delete(I);
 FProducer.JavaScript.Assign(
  FJS.Lines
 );
 RemoveEmptyJavaScriptHandler(
  LHandler
 );
 RebuildFullCode;
 BuildProjectExplorer;
 RefreshWebView;
 SetModified(True);
End;
Procedure TRESTDWHTMLDesignerForm.NavigateEventCode(
 const ASearchText : String;
 AInsideBody : Boolean);
Begin
 { Keep the Candidate 67 WebView lifecycle untouched. ShowCodeEditor performs
   the normal synchronization first. Only after that is the caret positioned
   on the selected/created event handler. }
 ShowCodeEditor;
 PositionCode(
  ASearchText,
  False
 );
 If AInsideBody And
    (FFullCode.CaretY < FFullCode.Lines.Count) Then
 Begin
  FFullCode.CaretY :=
   FFullCode.CaretY + 1;
  FFullCode.CaretX := 2;
 End;
 FEditingEventCode := True;
 If Assigned(FInspectorPages) And
    (FInspectorPages.PageCount > 1) Then
  FInspectorPages.ActivePageIndex := 1;
 FFullCode.SetFocus;
End;
Procedure TRESTDWHTMLDesignerForm.OpenOrCreatePageEvent(
 const AEventName, AHandlerText : String);
Var
 LHandler,
 LListener,
 LMarker,
 LFunctionText : String;
Begin
 LHandler := Trim(AHandlerText);
 If LHandler = '' Then
  LHandler :=
   PageEventDefaultHandler(
    AEventName
   );
 LListener :=
  PageEventListener(
   AEventName,
   LHandler
  );
 LMarker :=
  '// DS4L-PAGE-EVENT:' +
  AEventName +
  '=' +
  LHandler;
 If LListener = '' Then
  Exit;
 If Pos(
     LowerCase('function ' + LHandler + '('),
     LowerCase(FJS.Text)
    ) = 0 Then
 Begin
  LFunctionText :=
   'function ' +
   LHandler +
   '(event)' +
   sLineBreak +
   '{' +
   sLineBreak +
   ' ' +
   sLineBreak +
   '}' +
   sLineBreak;
  If Trim(FJS.Text) <> '' Then
   FJS.Lines.Add('');
  FJS.Lines.Text :=
   FJS.Lines.Text +
   LFunctionText;
 End;
 If Pos(
     LowerCase(LMarker),
     LowerCase(FJS.Text)
    ) = 0 Then
  FJS.Lines.Add(
   LMarker
  );
 If Pos(
     LowerCase(LListener),
     LowerCase(FJS.Text)
    ) = 0 Then
  FJS.Lines.Add(
   LListener
  );
 FProducer.JavaScript.Assign(
  FJS.Lines
 );
 If (FEvents.Row >= 1) And
    (FEvents.Row < FEvents.RowCount) Then
 Begin
  FUpdatingInspector := True;
  Try
   FEvents.Cells[1,FEvents.Row] :=
    LHandler;
  Finally
   FUpdatingInspector := False;
  End;
 End;
 FEventOriginalValues.Values[
  LowerCase(AEventName)
 ] := LHandler;
 RebuildFullCode;
 BuildProjectExplorer;
 RefreshWebView;
 SetModified(True);
 NavigateEventCode(
  'function ' +
  LHandler +
  '(event)',
  True
 );
End;
Procedure TRESTDWHTMLDesignerForm.OpenOrCreateEventHandler(
 const AEventName, AHandlerText : String);
Var
 LHandlerName,
 LInvocation,
 LFunctionText,
 LSearch : String;
 P : Integer;
Begin
 If Trim(AEventName) = '' Then
  Exit;
 LHandlerName :=
  ExtractHandlerName(
   AHandlerText
  );
 If LHandlerName <> '' Then
 Begin
  LSearch :=
   'function ' +
   LHandlerName +
   '(';
  If Pos(
      LowerCase(LSearch),
      LowerCase(FJS.Text)
     ) > 0 Then
  Begin
   RebuildFullCode;
   NavigateEventCode(
    LSearch,
    True
   );
   Exit;
  End;
 End;
 If Trim(AHandlerText) <> '' Then
 Begin
  RebuildFullCode;
  LSearch :=
   LowerCase(AEventName) +
   '="' +
   AHandlerText +
   '"';
  P := Pos(
   LowerCase(LSearch),
   LowerCase(FFullCode.Text)
  );
  If P = 0 Then
   LSearch :=
    LowerCase(AEventName) +
    '=' + #39 +
    AHandlerText +
    #39;
  If Pos(
      LowerCase(LSearch),
      LowerCase(FFullCode.Text)
     ) > 0 Then
  Begin
   NavigateEventCode(
    LSearch,
    False
   );
   Exit;
  End;
 End;
 LHandlerName :=
  MakeEventHandlerName(
   AEventName
  );
 LInvocation :=
  LHandlerName +
  '(event);';
 If (FEvents.Row >= 1) And
    (FEvents.Row < FEvents.RowCount) Then
 Begin
  FUpdatingInspector := True;
  Try
   FEvents.Cells[1,FEvents.Row] :=
    LInvocation;
  Finally
   FUpdatingInspector := False;
  End;
 End;
 If FSelectedFromCode Then
  UpdateSelectedCodeElement(
   AEventName,
   LInvocation
  )
 Else If Assigned(FWebView) Then
  FWebView.UpdateSelectedElement(
   AEventName,
   LInvocation
  );
 FEventOriginalValues.Values[
  LowerCase(AEventName)
 ] := LInvocation;
 LFunctionText :=
  'function ' +
  LHandlerName +
  '(event)' +
  sLineBreak +
  '{' +
  sLineBreak +
  ' ' +
  sLineBreak +
  '}' +
  sLineBreak;
 FUpdating := True;
 Try
  If Trim(FJS.Text) <> '' Then
   FJS.Lines.Add('');
  FJS.Lines.Text :=
   FJS.Lines.Text +
   LFunctionText;
  FProducer.JavaScript.Assign(
   FJS.Lines
  );
 Finally
  FUpdating := False;
 End;
 SetModified(
  True
 );
 RebuildFullCode;
 BuildProjectExplorer;
 RefreshWebView;
 NavigateEventCode(
  'function ' +
  LHandlerName +
  '(event)',
  True
 );
End;
Procedure TRESTDWHTMLDesignerForm.EventsDblClick(
 Sender : TObject);
Var
 LRow : Integer;
 LEvent,
 LHandler : String;
Begin
 LRow := FEvents.Row;
 If LRow < 1 Then
  Exit;
 LEvent := Trim(
  FEvents.Cells[0,LRow]
 );
 If LEvent = '' Then
  Exit;
 LHandler := Trim(
  FEvents.Cells[1,LRow]
 );
 { An event double click is always a source-code action. Never redirect this
   action to the Properties page. Keep Events selected in Object Inspector and
   immediately replace FormDesign/WebView with the Full Code editor. }
 FEditingEventCode := True;
 If Assigned(FInspectorPages) And
    (FInspectorPages.PageCount > 1) Then
  FInspectorPages.ActivePageIndex := 1;
 { Do not call ShowCodeEditor here. OpenOrCreateEventHandler and
   OpenOrCreatePageEvent own the navigation to source. Calling it early
   saves/rebuilds the producer while the visual document is still being
   processed and can leave the embedded WebView with an empty/gray document. }
 If FPageOptionsSelected Then
  OpenOrCreatePageEvent(
   LEvent,
   LHandler
  )
 Else
  OpenOrCreateEventHandler(
   LEvent,
   LHandler
  );
 If Assigned(FInspectorPages) And
    (FInspectorPages.PageCount > 1) Then
  FInspectorPages.ActivePageIndex := 1;
 FFullCode.SetFocus;
End;
Procedure TRESTDWHTMLDesignerForm.ClearObjectBrowserNodeData;
Var
 I : Integer;
Begin
 If Not Assigned(FObjectBrowserTree) Then Exit;
 For I := 0 To FObjectBrowserTree.Items.Count - 1 Do
  If FObjectBrowserTree.Items[I].Data <> Nil Then
  Begin
   TObject(FObjectBrowserTree.Items[I].Data).Free;
   FObjectBrowserTree.Items[I].Data := Nil;
  End;
End;
Function TRESTDWHTMLDesignerForm.ObjectBrowserIconIndex(
 const ATagName, AClassName, AElementName : String) : Integer;
Var
 I,P1,P2,LScore,LBestScore,LBestIndex : Integer;
 LInfo : TRESTDWHTMLWebComponentInfo;
 LHTML,LTag,LClasses,LRootClasses,LToken,LElementName,LComponentName : String;
 LMatchedClass : Boolean;
 LPicture : TPicture;
 LBitmap : TBitmap;
 LTokens : TStringList;
Begin
 Result := -1;
 If Not Assigned(FObjectBrowserImages) Then Exit;
 LTag := LowerCase(Trim(ATagName));
 LClasses := ' ' + LowerCase(Trim(AClassName)) + ' ';
 LElementName := LowerCase(Trim(AElementName));
 LBestScore := -1;
 LBestIndex := -1;
 LTokens := TStringList.Create;
 Try
  LTokens.Delimiter := ' ';
  LTokens.StrictDelimiter := True;
  For I := 0 To FComponents.Count - 1 Do
  Begin
   LInfo := TRESTDWHTMLWebComponentInfo(FComponents[I]);
   If (LInfo.IconFile = '') Or Not FileExists(LInfo.IconFile) Then Continue;
   LScore := 0;
   LComponentName := LowerCase(Trim(LInfo.ClassName));
   If LComponentName = '' Then LComponentName := LowerCase(Trim(LInfo.Name));
   If (LElementName <> '') And (LComponentName <> '') And
      (Pos(LComponentName,LElementName) = 1) Then LScore := 100;
   LHTML := LowerCase(LInfo.HTML);
   P1 := Pos('<',LHTML);
   While (P1 > 0) And (P1 < Length(LHTML)) And
         ((LHTML[P1+1] = '!') Or (LHTML[P1+1] = '?')) Do
    P1 := PosEx('<',LHTML,P1+1);
   If P1 > 0 Then
   Begin
    Inc(P1);
    P2 := P1;
    While (P2 <= Length(LHTML)) And (LHTML[P2] > ' ') And
          (LHTML[P2] <> '>') And (LHTML[P2] <> '/') Do Inc(P2);
    If Copy(LHTML,P1,P2-P1) = LTag Then
    Begin
     If LScore < 1 Then LScore := 1;
     LMatchedClass := False;
     LRootClasses := '';
     P1 := Pos('class="',LHTML);
     If P1 > 0 Then
     Begin
      Inc(P1,7);
      P2 := PosEx('"',LHTML,P1);
      If P2 > P1 Then LRootClasses := Copy(LHTML,P1,P2-P1);
     End;
     If LRootClasses <> '' Then
     Begin
      LTokens.DelimitedText := LRootClasses;
      For P1 := 0 To LTokens.Count - 1 Do
      Begin
       LToken := Trim(LTokens[P1]);
       If (LToken <> '') And (Pos(' ' + LToken + ' ',LClasses) > 0) Then
       Begin
        LMatchedClass := True;
        Inc(LScore,4);
       End;
      End;
      If Not LMatchedClass And (LScore < 100) Then LScore := 0;
     End;
    End;
   End;
   If LScore > LBestScore Then
   Begin
    LBestScore := LScore;
    LBestIndex := I;
   End;
  End;
  If (LBestIndex < 0) Or (LBestScore <= 0) Then Exit;
  LInfo := TRESTDWHTMLWebComponentInfo(FComponents[LBestIndex]);
  LPicture := TPicture.Create;
  LBitmap := TBitmap.Create;
  Try
   Try
    LPicture.LoadFromFile(LInfo.IconFile);
    LBitmap.SetSize(16,16);
    LBitmap.Canvas.StretchDraw(Rect(0,0,16,16),LPicture.Graphic);
    Result := FObjectBrowserImages.Add(LBitmap,Nil);
   Except
    Result := -1;
   End;
  Finally
   LBitmap.Free;
   LPicture.Free;
  End;
 Finally
  LTokens.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.WebViewObjectTree(
 Sender : TObject; const AJSON : String);
Var
 LData : TJSONData;
 LArray : TJSONArray;
 LItem : TJSONObject;
 LRoot,LBody,LNode,LParent,LRestoreSelected,LRestoreTop : TTreeNode;
 LParents : Array Of TTreeNode;
 LInfo,LExpandedInfo : TRESTDWHTMLObjectBrowserNodeInfo;
 LCaption,LTag,LID,LClassName,LElementID,LSelectedID,LTopID : String;
 I,J,LDepth,LIcon,LTopKind,P : Integer;
 LExpanded : TStringList;
 LHadTree,LRootExpanded,LBodyExpanded : Boolean;
Begin
 If FUpdatingObjectBrowser Or Not Assigned(FObjectBrowserTree) Then Exit;
 FUpdatingObjectBrowser := True;
 LData := Nil;
 LExpanded := TStringList.Create;
 LRestoreSelected := Nil;
 LRestoreTop := Nil;
 LSelectedID := '';
 LTopID := '';
 LTopKind := 0;
 SetLength(LParents,0);
 LHadTree := FObjectBrowserTree.Items.Count > 0;
 LRootExpanded := True;
 LBodyExpanded := True;
 Try
  LExpanded.Sorted := True;
  LExpanded.Duplicates := dupIgnore;
  If LHadTree Then
  Begin
   If FObjectBrowserTree.Items.Count > 0 Then LRootExpanded := FObjectBrowserTree.Items[0].Expanded;
   If FObjectBrowserTree.Items.Count > 1 Then LBodyExpanded := FObjectBrowserTree.Items[1].Expanded;
  End;
  If Assigned(FObjectBrowserTree.Selected) And (FObjectBrowserTree.Selected.Data <> Nil) Then
   LSelectedID := TRESTDWHTMLObjectBrowserNodeInfo(FObjectBrowserTree.Selected.Data).ElementID
  Else
   LSelectedID := FSelectedElementID;
  If Assigned(FObjectBrowserTree.TopItem) Then
  Begin
   If FObjectBrowserTree.TopItem.Data <> Nil Then
   Begin
    LTopKind := 3;
    LTopID := TRESTDWHTMLObjectBrowserNodeInfo(FObjectBrowserTree.TopItem.Data).ElementID;
   End
   Else If SameText(FObjectBrowserTree.TopItem.Text,'HTML') Then LTopKind := 1
   Else If SameText(FObjectBrowserTree.TopItem.Text,'BODY') Then LTopKind := 2;
  End;
  For I := 0 To FObjectBrowserTree.Items.Count - 1 Do
   If FObjectBrowserTree.Items[I].Expanded And (FObjectBrowserTree.Items[I].Data <> Nil) Then
   Begin
    LExpandedInfo := TRESTDWHTMLObjectBrowserNodeInfo(FObjectBrowserTree.Items[I].Data);
    If LExpandedInfo.ElementID <> '' Then LExpanded.Add(LExpandedInfo.ElementID);
   End;
  ClearObjectBrowserNodeData;
  FObjectBrowserTree.Items.BeginUpdate;
  Try
   FObjectBrowserTree.Items.Clear;
   FObjectBrowserImages.Clear;
   LRoot := FObjectBrowserTree.Items.Add(Nil,'HTML');
   LBody := FObjectBrowserTree.Items.AddChild(LRoot,'BODY');
   SetLength(LParents,1);
   LParents[0] := LBody;
   LData := GetJSON(AJSON);
   If (LData = Nil) Or (LData.JSONType <> jtArray) Then Exit;
   LArray := TJSONArray(LData);
   For I := 0 To LArray.Count - 1 Do
   Begin
    LItem := LArray.Objects[I];
    If LItem = Nil Then Continue;
    LDepth := LItem.Get('d',0);
    LElementID := LItem.Get('e','');
    LTag := LowerCase(LItem.Get('t',''));
    LID := LItem.Get('i','');
    LClassName := LItem.Get('c','');
    LItem.Free;
    LItem := Nil;
    LCaption := UpperCase(LTag);
    If LID <> '' Then LCaption := LCaption + ' #' + LID
    Else If LClassName <> '' Then
    Begin
     P := Pos(' ',LClassName);
     If P > 0 Then
      LCaption := LCaption + ' .' + Copy(LClassName,1,P-1)
     Else
      LCaption := LCaption + ' .' + LClassName;
    End;
    If LDepth < 0 Then LDepth := 0;
    If LDepth >= Length(LParents) Then SetLength(LParents,LDepth+1);
    If LDepth = 0 Then LParent := LBody
    Else If (LDepth-1 < Length(LParents)) And Assigned(LParents[LDepth-1]) Then
     LParent := LParents[LDepth-1]
    Else
     LParent := LBody;
    LNode := FObjectBrowserTree.Items.AddChild(LParent,LCaption);
    LInfo := TRESTDWHTMLObjectBrowserNodeInfo.Create;
    LInfo.ElementID := LElementID;
    LInfo.TagName := LTag;
    LNode.Data := LInfo;
    LIcon := ObjectBrowserIconIndex(LTag,LClassName,LID);
    LNode.ImageIndex := LIcon;
    LNode.SelectedIndex := LIcon;
    LParents[LDepth] := LNode;
    If LDepth+1 < Length(LParents) Then LParents[LDepth+1] := Nil;
    If SameText(LElementID,LSelectedID) Then LRestoreSelected := LNode;
    If (LTopKind = 3) And SameText(LElementID,LTopID) Then LRestoreTop := LNode;
   End;
   If LRootExpanded Then LRoot.Expand(False);
   If LBodyExpanded Then LBody.Expand(False);
   For I := 0 To FObjectBrowserTree.Items.Count - 1 Do
    If FObjectBrowserTree.Items[I].Data <> Nil Then
    Begin
     LExpandedInfo := TRESTDWHTMLObjectBrowserNodeInfo(FObjectBrowserTree.Items[I].Data);
     If (LExpandedInfo.ElementID <> '') And LExpanded.Find(LExpandedInfo.ElementID,J) Then
      FObjectBrowserTree.Items[I].Expand(False);
    End;
   If Assigned(LRestoreSelected) Then FObjectBrowserTree.Selected := LRestoreSelected;
   Case LTopKind Of
    1 : FObjectBrowserTree.TopItem := LRoot;
    2 : FObjectBrowserTree.TopItem := LBody;
    3 : If Assigned(LRestoreTop) Then FObjectBrowserTree.TopItem := LRestoreTop;
   End;
  Finally
   FObjectBrowserTree.Items.EndUpdate;
  End;
 Finally
  LExpanded.Free;
  LData.Free;
  FUpdatingObjectBrowser := False;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.SelectObjectBrowserElement(
 const AElementID : String);
Var
 I : Integer;
 LInfo : TRESTDWHTMLObjectBrowserNodeInfo;
Begin
 If FUpdatingObjectBrowser Or Not Assigned(FObjectBrowserTree) Or (AElementID = '') Then Exit;
 If SameText(FObjectBrowserSelectionID,AElementID) Then
 Begin
  FObjectBrowserSelectionID := '';
  Exit;
 End;
 For I := 0 To FObjectBrowserTree.Items.Count - 1 Do
 Begin
  If FObjectBrowserTree.Items[I].Data = Nil Then Continue;
  LInfo := TRESTDWHTMLObjectBrowserNodeInfo(FObjectBrowserTree.Items[I].Data);
  If SameText(LInfo.ElementID,AElementID) Then
  Begin
   FObjectBrowserTree.Selected := FObjectBrowserTree.Items[I];
   FObjectBrowserTree.Items[I].MakeVisible;
   Exit;
  End;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.ObjectBrowserClick(Sender : TObject);
Var
 LInfo : TRESTDWHTMLObjectBrowserNodeInfo;
Begin
 If FUpdatingObjectBrowser Or Not Assigned(FObjectBrowserTree) Or
    Not Assigned(FObjectBrowserTree.Selected) Or
    (FObjectBrowserTree.Selected.Data = Nil) Then Exit;
 LInfo := TRESTDWHTMLObjectBrowserNodeInfo(FObjectBrowserTree.Selected.Data);
 FObjectBrowserSelectionID := LInfo.ElementID;
 If Assigned(FWebView) And FWebView.Ready Then
  FWebView.SelectElement(LInfo.ElementID);
End;
Procedure TRESTDWHTMLDesignerForm.WebViewElementSelected(
 Sender : TObject;
 const AElementID, ATagName, AText, AID, AClassName,
 AOuterHTML : String);
Var
 LSameElement,
 LIgnoreCodeTarget : Boolean;
 LInspectorPage : Integer;
Begin
 If Not FDesignMode Then
  Exit;
 FEditingEventCode := False;
 LSameElement :=
  SameText(
   FSelectedElementID,
   AElementID
  ) And
  (FSelectedElementID <> '');
 LInspectorPage :=
  FInspectorPages.ActivePageIndex;
 SetDockPanelVisible(
  2,
  True
 );
 If Not LSameElement Then
  FInspectorPages.ActivePageIndex := 0;
 FSelectedFromCode := False;
 FSelectedCodeTagStart := 0;
 FSelectedCodeTagEnd := 0;
 InspectorSetElement(
  AElementID,
  ATagName,
  AText,
  AID,
  AClassName,
  AOuterHTML
 );
 If LSameElement Then
  FInspectorPages.ActivePageIndex :=
   LInspectorPage;
 If FInsertInfo <> Nil Then
 Begin
  FIgnoreNextInsertedSelection := True;
  InsertVisualComponent(FInsertInfo,0,0,False);
  FInsertInfo := Nil;
  FModeBar.Caption := '';
  Exit;
 End;
 LIgnoreCodeTarget :=
  FIgnoreNextInsertedSelection;
 If FIgnoreNextInsertedSelection Then
  FIgnoreNextInsertedSelection := False;
 { The selection generated internally by InsertHTML/InsertHTMLAt happens before
   __restdwSyncHTML. It may update Object Inspector, but it must never create a code
   navigation target from a stale producer snapshot. A later real user click
   creates the one-shot target, even when it is the same element. }
 If Not LIgnoreCodeTarget Then
 Begin
  FPendingCodeElement := True;
  FPendingCodeTagName := ATagName;
  FPendingCodeText := AText;
  FPendingCodeID := AID;
  FPendingCodeClass := AClassName;
  FPendingCodeOuterHTML := AOuterHTML;
 End;
 SelectObjectBrowserElement(AElementID);
End;
Procedure TRESTDWHTMLDesignerForm.WebViewHTMLChanged(
 Sender : TObject;
 const AHTML : String);
Begin
 If FUpdating Or
    Not FDesignMode Then
  Exit;
 If Trim(AHTML) = Trim(FHTML.Text) Then
  Exit;
 FUpdating := True;
 Try
  FHTML.Text := Trim(AHTML);
  FProducer.HTML.Assign(
   FHTML.Lines
  );
  RebuildFullCode;
 Finally
  FUpdating := False;
 End;
 SetModified(True);
End;
Procedure TRESTDWHTMLDesignerForm.DeleteSelectedVisualElement;
Begin
 If Not FDesignMode Or
    (FSelectedElementID = '') Or
    Not Assigned(FWebView) Or
    Not FWebView.Ready Then
  Exit;
 FWebView.DeleteSelectedElement;
 FSelectedElementID := '';
 FSelectedElementTag := '';
 FSelectedFromCode := False;
 FSelectedCodeTagStart := 0;
 FSelectedCodeTagEnd := 0;
 FUpdatingInspector := True;
 Try
     FProperties.RowCount := 1;
   FEvents.RowCount := 1;
 Finally
  FUpdatingInspector := False;
 End;
 SetModified(
  True
 );
End;
Procedure TRESTDWHTMLDesignerForm.RebuildVisualDesign;
Begin
 { The Form Designer is the real rendered page in TRESTDWHTMLWebView.
   No synthetic TPanel representation is created here. }
 SaveToProducer;
 RefreshWebView;
End;
Procedure TRESTDWHTMLDesignerForm.SourceChanged(
 Sender : TObject);
Begin
 If FUpdating Then
  Exit;
 MarkModified;
 FPreviewTimer.Enabled := False;
 FPreviewTimer.Enabled := True;
End;
Procedure TRESTDWHTMLDesignerForm.FullCodeChanged(
 Sender : TObject);
Begin
 If FUpdating Then
  Exit;
 MarkModified;
 { Full Code is authoritative while Code Editor is active.
   Do not rebuild/navigate the WebView from a typing timer. The producer
   is parsed exactly once when the user returns to FormDesign. }
 FPreviewTimer.Enabled := False;
End;
Procedure TRESTDWHTMLDesignerForm.CodeEditorClick(
 Sender : TObject);
Begin
 InspectCodeAtCaret;
End;
Procedure TRESTDWHTMLDesignerForm.CodeEditorKeyUp(
 Sender : TObject;
 Var Key : Word;
 Shift : TShiftState);
Begin
 InspectCodeAtCaret;
End;
Function TRESTDWHTMLDesignerForm.BreakpointIndex(
 ALine : Integer) : Integer;
Var
 I : Integer;
Begin
 Result := -1;
 For I := 0 To FDebugBreakpoints.Count - 1 Do
  If StrToIntDef(
      FDebugBreakpoints[I],
      -1
     ) = ALine Then
  Begin
   Result := I;
   Exit;
  End;
End;
Function TRESTDWHTMLDesignerForm.IsJavaScriptLine(
 ALine : Integer) : Boolean;
Var
 I : Integer;
 LLine : String;
 LInsideScript : Boolean;
Begin
 Result := False;
 If (ALine < 1) Or
    (ALine > FFullCode.Lines.Count) Then
  Exit;
 LInsideScript := False;
 For I := 0 To ALine - 1 Do
 Begin
  LLine :=
   LowerCase(
    FFullCode.Lines[I]
   );
  If Pos('<script',LLine) > 0 Then
  Begin
   If Pos('</script>',LLine) = 0 Then
    LInsideScript := True
   Else
    LInsideScript := False;
  End;
  If I = ALine - 1 Then
  Begin
   Result :=
    LInsideScript And
    (Pos('</script>',LLine) = 0);
   Exit;
  End;
  If Pos('</script>',LLine) > 0 Then
   LInsideScript := False;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.BuildDebugMarkImages;
Var
 LBitmap : TBitmap;
 I : Integer;
Begin
 If Assigned(FDebugMarkImages) Then
  Exit;
 FDebugMarkImages :=
  TImageList.Create(
   Self
  );
 FDebugMarkImages.Width := 16;
 FDebugMarkImages.Height := 16;
 LBitmap := TBitmap.Create;
 Try
  LBitmap.Width := 16;
  LBitmap.Height := 16;
  For I := 0 To 8 Do
  Begin
   LBitmap.Canvas.Brush.Color := clFuchsia;
   LBitmap.Canvas.FillRect(Rect(0,0,16,16));
   LBitmap.Canvas.Pen.Color := TColor($003030A0);
   LBitmap.Canvas.Brush.Color := TColor($003838D8);
   LBitmap.Canvas.Ellipse(2,2,14,14);
   FDebugMarkImages.AddMasked(
    LBitmap,
    clFuchsia
   );
  End;
  LBitmap.Canvas.Brush.Color := clFuchsia;
  LBitmap.Canvas.FillRect(Rect(0,0,16,16));
  LBitmap.Canvas.Pen.Color := TColor($00406020);
  LBitmap.Canvas.Brush.Color := TColor($0060B040);
  LBitmap.Canvas.Polygon([Point(3,2),Point(13,8),Point(3,14)]);
  FDebugMarkImages.AddMasked(
   LBitmap,
   clFuchsia
  );
 Finally
  LBitmap.Free;
 End;
 FFullCode.BookMarkOptions.BookmarkImages :=
  FDebugMarkImages;
 FJS.BookMarkOptions.BookmarkImages :=
  FDebugMarkImages;
End;
Procedure TRESTDWHTMLDesignerForm.SyncBreakpointMarks;
Var
 I,
 LLine,
 LJSLine : Integer;
Begin
 If Not Assigned(FFullCode) Then
  Exit;
 For I := 0 To 9 Do
 Begin
  FFullCode.ClearBookMark(
   I
  );
  If Assigned(FJS) Then
   FJS.ClearBookMark(
    I
   );
 End;
 For I := 0 To FDebugBreakpoints.Count - 1 Do
 Begin
  If I > 8 Then
   Break;
  LLine :=
   StrToIntDef(
    FDebugBreakpoints[I],
    0
   );
  If (LLine > 0) And
     (LLine <= FFullCode.Lines.Count) Then
  Begin
   FFullCode.SetBookMark(
    I,
    1,
    LLine
   );
   If Assigned(FJS) Then
   Begin
    LJSLine :=
     FullCodeLineToJSLine(
      LLine
     );
    If LJSLine > 0 Then
     FJS.SetBookMark(
      I,
      1,
      LJSLine
     );
   End;
  End;
 End;
 If FDebugPaused And
    (FDebugCurrentLine > 0) And
    (FDebugCurrentLine <= FFullCode.Lines.Count) Then
 Begin
  FFullCode.SetBookMark(
   9,
   1,
   FDebugCurrentLine
  );
  If Assigned(FJS) Then
  Begin
   LJSLine :=
    FullCodeLineToJSLine(
     FDebugCurrentLine
    );
   If LJSLine > 0 Then
    FJS.SetBookMark(
     9,
     1,
     LJSLine
    );
  End;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.ToggleBreakpoint(
 ALine : Integer);
Var
 LIndex : Integer;
Begin
 If (ALine < 1) Or
    (ALine > FFullCode.Lines.Count) Then
  Exit;
 BuildDebugMarkImages;
 LIndex :=
  BreakpointIndex(
   ALine
  );
 If LIndex >= 0 Then
  FDebugBreakpoints.Delete(
   LIndex
  )
 Else
 Begin
  If FDebugBreakpoints.Count >= 9 Then
  Begin
   AddMessage(
    'Debug',
    FCurrentFileName,
    'The visual editor supports up to 9 simultaneous breakpoints; the final gutter marker is reserved for the current debug line.',
    ALine,
    1
   );
   Exit;
  End;
  FDebugBreakpoints.Add(
   IntToStr(ALine)
  );
 End;
 SyncBreakpointMarks;
 { Force an immediate gutter repaint, matching the visible Lazarus behavior. }
 FFullCode.Invalidate;
 If Assigned(FJS) Then
  FJS.Invalidate;
End;
Procedure TRESTDWHTMLDesignerForm.CodeGutterClick(
 Sender : TObject;
 {$IFNDEF FPC}Button : TMouseButton;{$ENDIF}
 X, Y, Line : Integer;
 Mark : TSynEditMark);
{$IFDEF FPC}
Var
 LLine : Integer;
{$ENDIF}
Begin
 {$IFDEF FPC}
 LLine := Line;
 If Sender = FJS Then
  LLine := JSLineToFullCodeLine(Line);
 If LLine > 0 Then
  ToggleBreakpoint(LLine);
 {$ELSE}
 { Single gutter clicks remain standard SynEdit behavior.
   Native double-click is intercepted through WindowProc. }
 {$ENDIF}
End;
Procedure TRESTDWHTMLDesignerForm.ToggleBreakpointClick(
 Sender : TObject);
Var
 LLine : Integer;
Begin
 If FDesignMode Then
  ShowCodeEditor;
 If FCodePages.ActivePage = FJSTab Then
  LLine :=
   JSLineToFullCodeLine(
    FJS.CaretY
   )
 Else
  LLine :=
   FFullCode.CaretY;
 If LLine > 0 Then
  ToggleBreakpoint(
   LLine
  );
End;
Function TRESTDWHTMLDesignerForm.BuildDebugPreviewHTML : String;
Var
 LText : TStringList;
 I,
 LLine,
 LSpaces : Integer;
 LOriginal,
 LTrimmed,
 LDebuggerLine : String;
Begin
 Result :=
  BuildPreviewHTML;
 If FDebugBreakpoints.Count = 0 Then
  Exit;
 LText := TStringList.Create;
 Try
  LText.Text := Result;
  { Insert from bottom to top so stored source line numbers stay stable. }
  For I := FDebugBreakpoints.Count - 1 Downto 0 Do
  Begin
   LLine :=
    StrToIntDef(
     FDebugBreakpoints[I],
     0
    );
   If (LLine < 1) Or
      (LLine > LText.Count) Or
      Not IsJavaScriptLine(LLine) Then
    Continue;
   LOriginal :=
    LText[LLine - 1];
   LTrimmed :=
    TrimLeft(
     LOriginal
    );
   LSpaces :=
    Length(LOriginal) -
    Length(LTrimmed);
   LDebuggerLine :=
    StringOfChar(
     ' ',
     LSpaces
    ) +
    'try{window.chrome.webview.postMessage("RESTDWBREAK\t' +
    IntToStr(LLine) +
    '");}catch(e){} debugger; // REST Dataware breakpoint';
   LText.Insert(
    LLine - 1,
    LDebuggerLine
   );
  End;
  Result :=
   LText.Text;
 Finally
  LText.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.UpdateDebugMenuState;
Begin
 If Assigned(FDebugStartMenuItem) Then
  FDebugStartMenuItem.Enabled :=
   (Not FDebugging) Or
   FDebugPaused;
 If Assigned(FDebugPauseMenuItem) Then
  FDebugPauseMenuItem.Enabled :=
   FDebugging And
   Not FDebugPaused;
 If Assigned(FDebugStopMenuItem) Then
  FDebugStopMenuItem.Enabled :=
   FDebugging;
 If Assigned(FDebugRunToCursorMenuItem) Then
  FDebugRunToCursorMenuItem.Enabled :=
   FDebugging And
   FDebugPaused;
 If Assigned(FDebugStepIntoMenuItem) Then
  FDebugStepIntoMenuItem.Enabled :=
   FDebugging And
   FDebugPaused;
 If Assigned(FDebugStepOverMenuItem) Then
  FDebugStepOverMenuItem.Enabled :=
   FDebugging And
   FDebugPaused;
 If Assigned(FDebugStepOutMenuItem) Then
  FDebugStepOutMenuItem.Enabled :=
   FDebugging And
   FDebugPaused;
 If Assigned(FDebugEvaluateMenuItem) Then
  FDebugEvaluateMenuItem.Enabled :=
   FDebugging And
   FDebugPaused;
 If Assigned(FDebugStartButton) Then
  FDebugStartButton.Enabled :=
   (Not FDebugging) Or
   FDebugPaused;
 If Assigned(FDebugStopButton) Then
  FDebugStopButton.Enabled :=
   FDebugging;
End;
Procedure TRESTDWHTMLDesignerForm.DebugStartClick(
 Sender : TObject);
Begin
 If FDebugging Then
 Begin
  If FDebugPaused And
     Assigned(FWebView) Then
  Begin
   FDebugPaused := False;
   FWebView.DebugResume;
   UpdateDebugMenuState;
  End;
  Exit;
 End;
 If Not FDesignMode Then
  ParseFullCodeToProducer
 Else
  SaveToProducer;
 RebuildFullCode;
 SyncBreakpointMarks;
 ShowFormDesign;
 FDebugging := True;
 FDebugPaused := False;
 FDebugCurrentLine := 0;
 FPreviewTimer.Enabled := False;
 If Assigned(FWebView) Then
 Begin
  FWebView.AssetsFolder :=
   ResolveEditorLibrariesPath;
  FWebView.OnDebugBreakpoint := DebugBreakpointHit;
  FWebView.OnDebugEvaluate := DebugEvaluateResult;
  FWebView.EnableDebugger;
  FWebView.HTML :=
   BuildDebugPreviewHTML;
 End;
 UpdateDebugMenuState;
End;
Procedure TRESTDWHTMLDesignerForm.DebugPauseClick(
 Sender : TObject);
Begin
 If Not FDebugging Or
    FDebugPaused Or
    Not Assigned(FWebView) Then
  Exit;
 FWebView.DebugPause;
End;
Procedure TRESTDWHTMLDesignerForm.DebugRunToCursorClick(
 Sender : TObject);
Begin
 If Not FDebugging Or
    Not FDebugPaused Or
    Not Assigned(FWebView) Then
  Exit;
 If Not IsJavaScriptLine(
         FFullCode.CaretY
        ) Then
  Exit;
 FDebugPaused := False;
 SyncBreakpointMarks;
 FWebView.DebugContinueToLine(
  FFullCode.CaretY
 );
 UpdateDebugMenuState;
End;
Procedure TRESTDWHTMLDesignerForm.DebugStopClick(
 Sender : TObject);
Begin
 If Assigned(FWebView) Then
 Begin
  If FDebugPaused Then
   FWebView.DebugResume;
  FWebView.DisableDebugger;
  FWebView.OnDebugBreakpoint := Nil;
  FWebView.OnDebugEvaluate := Nil;
 End;
 FDebugging := False;
 FDebugPaused := False;
 SyncBreakpointMarks;
 FDebugCurrentLine := 0;
 FPreviewTimer.Enabled := True;
 If Assigned(FDebugHintForm) Then
  FDebugHintForm.Hide;
 UpdateDebugMenuState;
 RefreshWebView;
End;
Procedure TRESTDWHTMLDesignerForm.DebugStepIntoClick(
 Sender : TObject);
Begin
 If FDebugging And
    FDebugPaused And
    Assigned(FWebView) Then
 Begin
  FDebugPaused := False;
 SyncBreakpointMarks;
  FWebView.DebugStepInto;
  UpdateDebugMenuState;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.DebugStepOverClick(
 Sender : TObject);
Begin
 If FDebugging And
    FDebugPaused And
    Assigned(FWebView) Then
 Begin
  FDebugPaused := False;
 SyncBreakpointMarks;
  FWebView.DebugStepOver;
  UpdateDebugMenuState;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.DebugStepOutClick(
 Sender : TObject);
Begin
 If FDebugging And
    FDebugPaused And
    Assigned(FWebView) Then
 Begin
  FDebugPaused := False;
  SyncBreakpointMarks;
  FWebView.DebugStepOut;
  UpdateDebugMenuState;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.DebugEvaluateClick(
 Sender : TObject);
Begin
 If Not FDebugging Or
    Not FDebugPaused Then
  Exit;
 ShowEvaluateDialog(
  FDebugHoverExpression
 );
End;
Procedure TRESTDWHTMLDesignerForm.DebugClearBreakpointsClick(
 Sender : TObject);
Begin
 FDebugBreakpoints.Clear;
 SyncBreakpointMarks;
 If FDebugging Then
 Begin
  { Restart only the rendered debug page so the current list of injected
    breakpoints exactly matches the editor. }
  If Assigned(FWebView) Then
   FWebView.HTML :=
    BuildDebugPreviewHTML;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.DebugReleaseAllBreakpointsClick(
 Sender : TObject);
Begin
 If FDebugging And
    FDebugPaused And
    Assigned(FWebView) Then
  FWebView.DebugResume;
 FDebugPaused := False;
 FDebugBreakpoints.Clear;
 SyncBreakpointMarks;
 If Assigned(FWebView) Then
 Begin
  FWebView.DisableDebugger;
  If FDebugging Then
  Begin
   FWebView.EnableDebugger;
   FWebView.HTML :=
    BuildDebugPreviewHTML;
  End;
 End;
 UpdateDebugMenuState;
End;
Procedure TRESTDWHTMLDesignerForm.DebugDevToolsClick(
 Sender : TObject);
Begin
 If Assigned(FWebView) Then
  FWebView.OpenDevTools;
End;
Procedure TRESTDWHTMLDesignerForm.DebugBreakpointHit(
 Sender : TObject;
 ALine : Integer);
Begin
 If Not FDebugging Then
  Exit;
 FDebugPaused := True;
 If ALine > 0 Then
  FDebugCurrentLine := ALine;
 { A debugger stop belongs in source. Keep the WebView alive/paused in the
   background and move the IDE work area to Full Code without rebuilding the
   running page. }
 FDesignMode := False;
 FPreviewPanel.Visible := False;
 FCodePages.Visible := True;
 FCodePages.ActivePage := FFullCodeTab;
 FCodeEditorButton.Down := True;
 If (FDebugCurrentLine > 0) And
    (FDebugCurrentLine <= FFullCode.Lines.Count) Then
 Begin
  FFullCode.CaretY :=
   FDebugCurrentLine;
  FFullCode.CaretX := 1;
 end;
 SyncBreakpointMarks;
 FFullCode.SetFocus;
 UpdateDebugMenuState;
End;
Procedure TRESTDWHTMLDesignerForm.DebugEvaluateResult(
 Sender : TObject;
 ARequestID : Integer;
 const AExpression, AValue, AError : String;
 ASuccess : Boolean);
Var
 LText : String;
 LPoint : TPoint;
Begin
 If ARequestID = FDebugHoverRequestID Then
 Begin
  If Not ASuccess Then
   Exit;
  LText :=
   AExpression +
   ' = ' +
   AValue;
  FDebugHoverExpression :=
   AExpression;
  If FDebugHintForm = Nil Then
  Begin
   FDebugHintForm :=
    TForm.CreateNew(Self);
   FDebugHintForm.BorderStyle := bsNone;
   FDebugHintForm.FormStyle := fsStayOnTop;
   FDebugHintForm.AutoSize := True;
   FDebugHintLabel :=
    TLabel.Create(FDebugHintForm);
   FDebugHintLabel.Parent :=
    FDebugHintForm;
   {$IFDEF FPC}
   FDebugHintLabel.BorderSpacing.Around := 6;
   {$ELSE}
   FDebugHintLabel.Margins.SetBounds(6,6,6,6);
   {$ENDIF}
   FDebugHintLabel.OnDblClick :=
    DebugHintDblClick;
  End;
  FDebugHintLabel.Caption :=
   LText;
  LPoint :=
   Mouse.CursorPos;
  FDebugHintForm.Left :=
   LPoint.X + 12;
  FDebugHintForm.Top :=
   LPoint.Y + 18;
  FDebugHintForm.Show;
  Exit;
 End;
 If (FDebugEvaluateForm <> Nil) And
    (ARequestID = FDebugEvaluateRequestID) Then
 Begin
  If ASuccess Then
   FDebugEvaluateValueLabel.Caption :=
    AValue
  Else
   FDebugEvaluateValueLabel.Caption :=
    AError;
 End;
End;
Function TRESTDWHTMLDesignerForm.DebugExpressionAtMouse(
 X, Y : Integer) : String;
Begin
 Result := '';
 If Not FDebugging Or
    Not FDebugPaused Then
  Exit;
 { SynEdit already resolves the lexical word under the current mouse
   position. This keeps hover evaluation aligned with the code-editor
   gutter/layout and avoids altering the caret just to inspect a value. }
 Result :=
  Trim(
   FFullCode.GetWordAtRowCol(
    {$IFDEF FPC}
    FFullCode.PixelsToRowColumn(Point(X,Y))
    {$ELSE}
    FFullCode.DisplayToBufferPos(
     FFullCode.PixelsToRowColumn(X,Y)
    )
    {$ENDIF}
   )
  );
End;
Procedure TRESTDWHTMLDesignerForm.CodeEditorMouseMove(
 Sender : TObject;
 Shift : TShiftState;
 X, Y : Integer);
Var
 LExpression : String;
Begin
 If Sender <> FFullCode Then
  Exit;
 If Not FDebugging Or
    Not FDebugPaused Then
 Begin
  If Assigned(FDebugHintForm) Then
   FDebugHintForm.Hide;
  Exit;
 End;
 LExpression :=
  DebugExpressionAtMouse(
   X,
   Y
  );
 If LExpression = '' Then
 Begin
  If Assigned(FDebugHintForm) Then
   FDebugHintForm.Hide;
  Exit;
 End;
 If SameText(
     LExpression,
     FDebugHoverExpression
    ) And
    Assigned(FDebugHintForm) And
    FDebugHintForm.Visible Then
  Exit;
 FDebugHoverExpression :=
  LExpression;
 Inc(
  FDebugHoverRequestID
 );
 If FDebugHoverRequestID < 1000 Then
  FDebugHoverRequestID := 1000;
 If Assigned(FWebView) Then
  FWebView.EvaluateDebugExpression(
   FDebugHoverRequestID,
   LExpression
  );
End;
Procedure TRESTDWHTMLDesignerForm.CodeEditorDblClick(
 Sender : TObject);
Begin
 { Preserve normal source-text double-click behavior. }
End;
Procedure TRESTDWHTMLDesignerForm.InstallCodeWndProcHooks;
Begin
 If FCodeWndProcHooked Then
  Exit;
 If Assigned(FFullCode) Then
 Begin
  FFullCodeOriginalWndProc :=
   FFullCode.WindowProc;
  FFullCode.WindowProc :=
   FullCodeWndProc;
 End;
 If Assigned(FJS) Then
 Begin
  FJSOriginalWndProc :=
   FJS.WindowProc;
  FJS.WindowProc :=
   JSCodeWndProc;
 End;
 FCodeWndProcHooked := True;
End;
Procedure TRESTDWHTMLDesignerForm.FullCodeWndProc(
 {$IFDEF FPC}Var AMessage : TLMessage{$ELSE}Var AMessage : TMessage{$ENDIF});
{$IFNDEF FPC}
Var
 LMouse : TWMMouse;
 LLine : Integer;
{$ENDIF}
Begin
 {$IFNDEF FPC}
 If AMessage.Msg = WM_LBUTTONDBLCLK Then
 Begin
  LMouse := TWMMouse(AMessage);
  If (LMouse.XPos >= 0) And (LMouse.XPos < FFullCode.Gutter.Width) Then
  Begin
   LLine := FFullCode.DisplayToBufferPos(FFullCode.PixelsToRowColumn(LMouse.XPos,LMouse.YPos)).Line;
   If LLine > 0 Then
   Begin
    ToggleBreakpoint(LLine);
    AMessage.Result := 1;
    Exit;
   End;
  End;
 End;
 {$ENDIF}
 If Assigned(FFullCodeOriginalWndProc) Then
  FFullCodeOriginalWndProc(AMessage);
End;
Procedure TRESTDWHTMLDesignerForm.JSCodeWndProc(
 {$IFDEF FPC}Var AMessage : TLMessage{$ELSE}Var AMessage : TMessage{$ENDIF});
{$IFNDEF FPC}
Var
 LMouse : TWMMouse;
 LLine, LFullLine : Integer;
{$ENDIF}
Begin
 {$IFNDEF FPC}
 If AMessage.Msg = WM_LBUTTONDBLCLK Then
 Begin
  LMouse := TWMMouse(AMessage);
  If (LMouse.XPos >= 0) And (LMouse.XPos < FJS.Gutter.Width) Then
  Begin
   LLine := FJS.DisplayToBufferPos(FJS.PixelsToRowColumn(LMouse.XPos,LMouse.YPos)).Line;
   If LLine > 0 Then
   Begin
    LFullLine := JSLineToFullCodeLine(LLine);
    If LFullLine > 0 Then
    Begin
     ToggleBreakpoint(LFullLine);
     AMessage.Result := 1;
     Exit;
    End;
   End;
  End;
 End;
 {$ENDIF}
 If Assigned(FJSOriginalWndProc) Then
  FJSOriginalWndProc(AMessage);
End;
Procedure TRESTDWHTMLDesignerForm.DebugHintDblClick(
 Sender : TObject);
Begin
 If Assigned(FDebugHintForm) Then
  FDebugHintForm.Hide;
 ShowEvaluateDialog(
  FDebugHoverExpression
 );
End;
Procedure TRESTDWHTMLDesignerForm.ShowEvaluateDialog(
 const AExpression : String);
Var
 LExpressionLabel,
 LValueTitle,
 LNewValueLabel : TLabel;
 LEvaluate,
 LModify,
 LClose : TButton;
Begin
 If Not FDebugging Or
    Not FDebugPaused Then
  Exit;
 If FDebugEvaluateForm <> Nil Then
 Begin
  FDebugEvaluateForm.BringToFront;
  Exit;
 End;
 FDebugEvaluateForm :=
  TForm.CreateNew(Self);
 Try
  FDebugEvaluateForm.Caption :=
   'Evaluate/Modify';
  FDebugEvaluateForm.SetBounds(
   0,
   0,
   520,
   245
  );
  FDebugEvaluateForm.Position :=
   poScreenCenter;
  LExpressionLabel :=
   TLabel.Create(
    FDebugEvaluateForm
   );
  LExpressionLabel.Parent :=
   FDebugEvaluateForm;
  LExpressionLabel.SetBounds(
   12,
   14,
   110,
   20
  );
  LExpressionLabel.Caption :=
   'Expression:';
  FDebugEvaluateExpression :=
   TEdit.Create(
    FDebugEvaluateForm
   );
  FDebugEvaluateExpression.Parent :=
   FDebugEvaluateForm;
  FDebugEvaluateExpression.SetBounds(
   12,
   35,
   490,
   25
  );
  FDebugEvaluateExpression.Text :=
   AExpression;
  LValueTitle :=
   TLabel.Create(
    FDebugEvaluateForm
   );
  LValueTitle.Parent :=
   FDebugEvaluateForm;
  LValueTitle.SetBounds(
   12,
   70,
   110,
   20
  );
  LValueTitle.Caption :=
   'Current value:';
  FDebugEvaluateValueLabel :=
   TLabel.Create(
    FDebugEvaluateForm
   );
  FDebugEvaluateValueLabel.Parent :=
   FDebugEvaluateForm;
  FDebugEvaluateValueLabel.SetBounds(
   12,
   92,
   490,
   24
  );
  FDebugEvaluateValueLabel.Caption :=
   '';
  LNewValueLabel :=
   TLabel.Create(
    FDebugEvaluateForm
   );
  LNewValueLabel.Parent :=
   FDebugEvaluateForm;
  LNewValueLabel.SetBounds(
   12,
   122,
   110,
   20
  );
  LNewValueLabel.Caption :=
   'New value:';
  FDebugEvaluateNewValue :=
   TEdit.Create(
    FDebugEvaluateForm
   );
  FDebugEvaluateNewValue.Parent :=
   FDebugEvaluateForm;
  FDebugEvaluateNewValue.SetBounds(
   12,
   143,
   490,
   25
  );
  LEvaluate :=
   TButton.Create(
    FDebugEvaluateForm
   );
  LEvaluate.Parent :=
   FDebugEvaluateForm;
  LEvaluate.SetBounds(
   12,
   185,
   100,
   28
  );
  LEvaluate.Caption :=
   'Evaluate';
  LEvaluate.OnClick :=
   EvaluateDialogEvaluateClick;
  LModify :=
   TButton.Create(
    FDebugEvaluateForm
   );
  LModify.Parent :=
   FDebugEvaluateForm;
  LModify.SetBounds(
   122,
   185,
   100,
   28
  );
  LModify.Caption :=
   'Modify';
  LModify.OnClick :=
   EvaluateDialogModifyClick;
  LClose :=
   TButton.Create(
    FDebugEvaluateForm
   );
  LClose.Parent :=
   FDebugEvaluateForm;
  LClose.SetBounds(
   402,
   185,
   100,
   28
  );
  LClose.Caption :=
   'Close';
  LClose.ModalResult :=
   mrClose;
  If Trim(AExpression) <> '' Then
   EvaluateDialogEvaluateClick(
    LEvaluate
   );
  FDebugEvaluateForm.ShowModal;
 Finally
  FDebugEvaluateForm.Free;
  FDebugEvaluateForm := Nil;
  FDebugEvaluateExpression := Nil;
  FDebugEvaluateValueLabel := Nil;
  FDebugEvaluateNewValue := Nil;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.EvaluateDialogEvaluateClick(
 Sender : TObject);
Begin
 If (FDebugEvaluateForm = Nil) Or
    Not Assigned(FWebView) Then
  Exit;
 Inc(
  FDebugEvaluateRequestID
 );
 FWebView.EvaluateDebugExpression(
  FDebugEvaluateRequestID,
  Trim(
   FDebugEvaluateExpression.Text
  )
 );
End;
Procedure TRESTDWHTMLDesignerForm.EvaluateDialogModifyClick(
 Sender : TObject);
Begin
 If (FDebugEvaluateForm = Nil) Or
    Not Assigned(FWebView) Then
  Exit;
 If Trim(
     FDebugEvaluateExpression.Text
    ) = '' Then
  Exit;
 If Trim(
     FDebugEvaluateNewValue.Text
    ) = '' Then
  Exit;
 Inc(
  FDebugEvaluateRequestID
 );
 FWebView.ModifyDebugExpression(
  FDebugEvaluateRequestID,
  Trim(
   FDebugEvaluateExpression.Text
  ),
  Trim(
   FDebugEvaluateNewValue.Text
  )
 );
End;
Procedure TRESTDWHTMLDesignerForm.InspectCodeAtCaret;
Var
 LText,
 LTag,
 LTagName,
 LTextValue,
 LID,
 LClass : String;
 LCaretOffset,
 I,
 PStart,
 PEnd,
 PName,
 PTextEnd : Integer;
 Function Attr(const AName : String) : String;
 Var
  LLow,
  LNeedle : String;
  P1,
  P2 : Integer;
  Q : Char;
 Begin
  Result := '';
  LLow := LowerCase(LTag);
  LNeedle := LowerCase(AName) + '=';
  P1 := Pos(LNeedle,LLow);
  If P1 = 0 Then
   Exit;
  Inc(P1,Length(LNeedle));
  While (P1 <= Length(LTag)) And
        (LTag[P1] = ' ') Do
   Inc(P1);
  If P1 > Length(LTag) Then
   Exit;
  If (LTag[P1] = #39) Or
     (LTag[P1] = '"') Then
  Begin
   Q := LTag[P1];
   Inc(P1);
   P2 := P1;
   While (P2 <= Length(LTag)) And
         (LTag[P2] <> Q) Do
    Inc(P2);
   Result := Copy(LTag,P1,P2-P1);
  End
  Else
  Begin
   P2 := P1;
   While (P2 <= Length(LTag)) And
         (LTag[P2] > ' ') And
         (LTag[P2] <> '>') Do
    Inc(P2);
   Result := Copy(LTag,P1,P2-P1);
  End;
 End;
Begin
 If FDesignMode Then
  Exit;
 LText := FFullCode.Text;
 If LText = '' Then
  Exit;
 LCaretOffset := 1;
 For I := 0 To FFullCode.CaretY - 2 Do
  Inc(
   LCaretOffset,
   Length(FFullCode.Lines[I]) +
   Length(sLineBreak)
  );
 Inc(
  LCaretOffset,
  FFullCode.CaretX - 1
 );
 If LCaretOffset > Length(LText) + 1 Then
  LCaretOffset := Length(LText) + 1;
 PStart := LCaretOffset - 1;
 While (PStart > 0) And
       (LText[PStart] <> '<') Do
  Dec(PStart);
 If PStart <= 0 Then
  Exit;
 PEnd := PStart;
 While (PEnd <= Length(LText)) And
       (LText[PEnd] <> '>') Do
  Inc(PEnd);
 If PEnd > Length(LText) Then
  Exit;
 LTag := Copy(
  LText,
  PStart,
  PEnd-PStart+1
 );
 If (Length(LTag) < 3) Or
    (Copy(LTag,1,2) = '</') Or
    (Copy(LTag,1,2) = '<!') Or
    (Copy(LTag,1,2) = '<?') Then
  Exit;
 PName := 2;
 While (PName <= Length(LTag)) And
       (LTag[PName] = ' ') Do
  Inc(PName);
 I := PName;
 While (I <= Length(LTag)) And
       (LTag[I] > ' ') And
       (LTag[I] <> '>') And
       (LTag[I] <> '/') Do
  Inc(I);
 LTagName := Copy(
  LTag,
  PName,
  I-PName
 );
 If LTagName = '' Then
  Exit;
 LID := Attr('id');
 LClass := Attr('class');
 LTextValue := '';
 If PEnd < Length(LText) Then
 Begin
  PTextEnd := PEnd + 1;
  While (PTextEnd <= Length(LText)) And
        (LText[PTextEnd] <> '<') Do
   Inc(PTextEnd);
  LTextValue := Trim(
   Copy(
    LText,
    PEnd + 1,
    PTextEnd - PEnd - 1
   )
  );
 End;
 FSelectedFromCode := True;
 FSelectedCodeTagStart := PStart;
 FSelectedCodeTagEnd := PEnd;
 FSelectedElementID := 'code';
 FSelectedElementTag := LowerCase(LTagName);
 SetDockPanelVisible(
  2,
  True
 );
 If FEditingEventCode Then
 Begin
  If FInspectorPages.PageCount > 1 Then
   FInspectorPages.ActivePageIndex := 1;
 End
 Else
  FInspectorPages.ActivePageIndex := 0;
 InspectorSetElement(
  'code',
  LTagName,
  LTextValue,
  LID,
  LClass,
  LTag
 );
 { InspectorSetElement identifies a live DOM selection by default;
   restore the source flag for code editing. }
 FSelectedFromCode := True;
 FSelectedCodeTagStart := PStart;
 FSelectedCodeTagEnd := PEnd;
End;
Procedure TRESTDWHTMLDesignerForm.UpdateSelectedCodeElement(
 const AProperty, AValue : String);
Var
 LText,
 LTag,
 LNewTag,
 LProperty,
 LAttrName,
 LLower,
 LNeedle,
 LBefore,
 LAfter : String;
 P,
 PValueStart,
 PValueEnd : Integer;
 Q : Char;
Begin
 If Not FSelectedFromCode Or
    (FSelectedCodeTagStart <= 0) Or
    (FSelectedCodeTagEnd < FSelectedCodeTagStart) Then
  Exit;
 LText := FFullCode.Text;
 LTag := Copy(
  LText,
  FSelectedCodeTagStart,
  FSelectedCodeTagEnd-FSelectedCodeTagStart+1
 );
 LNewTag := LTag;
 LProperty := Trim(AProperty);
 If SameText(LProperty,'Tag') Or
    SameText(LProperty,'HTML') Then
  Exit;
 If SameText(LProperty,'Text') Then
 Begin
  P := FSelectedCodeTagEnd + 1;
  While (P <= Length(LText)) And
        (LText[P] <> '<') Do
   Inc(P);
  LBefore := Copy(
   LText,
   1,
   FSelectedCodeTagEnd
  );
  LAfter := Copy(
   LText,
   P,
   MaxInt
  );
  FUpdating := True;
  Try
   FFullCode.Text :=
    LBefore +
    AValue +
    LAfter;
  Finally
   FUpdating := False;
  End;
  ParseFullCodeToProducer;
  MarkModified;
  RefreshWebView;
  InspectCodeAtCaret;
  Exit;
 End;
 If SameText(LProperty,'Class') Then
  LAttrName := 'class'
 Else If SameText(LProperty,'ID') Then
  LAttrName := 'id'
 Else If Pos('On',LProperty) = 1 Then
  LAttrName := LowerCase(LProperty)
 Else
  LAttrName := LowerCase(LProperty);
 LLower := LowerCase(LNewTag);
 LNeedle := LAttrName + '=';
 P := Pos(LNeedle,LLower);
 If (P > 0) And
    (AValue = '') Then
 Begin
  { Remove the complete attribute when its Object Inspector value is cleared. }
  PValueStart := P;
  While (PValueStart > 1) And
        (LNewTag[PValueStart-1] = ' ') Do
   Dec(PValueStart);
  PValueEnd := P + Length(LNeedle);
  While (PValueEnd <= Length(LNewTag)) And
        (LNewTag[PValueEnd] = ' ') Do
   Inc(PValueEnd);
  If (PValueEnd <= Length(LNewTag)) And
     ((LNewTag[PValueEnd] = #39) Or
      (LNewTag[PValueEnd] = '"')) Then
  Begin
   Q := LNewTag[PValueEnd];
   Inc(PValueEnd);
   While (PValueEnd <= Length(LNewTag)) And
         (LNewTag[PValueEnd] <> Q) Do
    Inc(PValueEnd);
   If PValueEnd <= Length(LNewTag) Then
    Inc(PValueEnd);
  End
  Else
   While (PValueEnd <= Length(LNewTag)) And
         (LNewTag[PValueEnd] > ' ') And
         (LNewTag[PValueEnd] <> '>') Do
    Inc(PValueEnd);
  Delete(
   LNewTag,
   PValueStart,
   PValueEnd-PValueStart
  );
 End
 Else If P > 0 Then
 Begin
  PValueStart := P + Length(LNeedle);
  While (PValueStart <= Length(LNewTag)) And
        (LNewTag[PValueStart] = ' ') Do
   Inc(PValueStart);
  If (PValueStart <= Length(LNewTag)) And
     ((LNewTag[PValueStart] = #39) Or
      (LNewTag[PValueStart] = '"')) Then
  Begin
   Q := LNewTag[PValueStart];
   Inc(PValueStart);
   PValueEnd := PValueStart;
   While (PValueEnd <= Length(LNewTag)) And
         (LNewTag[PValueEnd] <> Q) Do
    Inc(PValueEnd);
   Delete(
    LNewTag,
    PValueStart,
    PValueEnd-PValueStart
   );
   Insert(
    AValue,
    LNewTag,
    PValueStart
   );
  End
  Else
  Begin
   PValueEnd := PValueStart;
   While (PValueEnd <= Length(LNewTag)) And
         (LNewTag[PValueEnd] > ' ') And
         (LNewTag[PValueEnd] <> '>') Do
    Inc(PValueEnd);
   Delete(
    LNewTag,
    PValueStart,
    PValueEnd-PValueStart
   );
   Insert(
    AValue,
    LNewTag,
    PValueStart
   );
  End;
 End
 Else If AValue <> '' Then
 Begin
  P := Length(LNewTag);
  If (P > 1) And
     (LNewTag[P-1] = '/') Then
   Dec(P);
  Insert(
   ' ' + LAttrName + '="' + AValue + '"',
   LNewTag,
   P
  );
 End;
 LBefore := Copy(
  LText,
  1,
  FSelectedCodeTagStart-1
 );
 LAfter := Copy(
  LText,
  FSelectedCodeTagEnd+1,
  MaxInt
 );
 FUpdating := True;
 Try
  FFullCode.Text :=
   LBefore +
   LNewTag +
   LAfter;
 Finally
  FUpdating := False;
 End;
 FSelectedCodeTagEnd :=
  FSelectedCodeTagStart +
  Length(LNewTag) - 1;
 ParseFullCodeToProducer;
 MarkModified;
 RefreshWebView;
 InspectCodeAtCaret;
End;
Procedure TRESTDWHTMLDesignerForm.PreviewTimerTimer(
 Sender : TObject);
Begin
 FPreviewTimer.Enabled := False;
 If Not FDesignMode And
    (FCodePages.ActivePage = FFullCodeTab) Then
  ParseFullCodeToProducer
 Else
  SaveToProducer;
 ValidateDocument;
 BuildProjectExplorer;
 RefreshWebView;
End;
Procedure TRESTDWHTMLDesignerForm.SaveToProducer;
Begin If FUpdating Then Exit; FProducer.HTML.Assign(FHTML.Lines); FProducer.CSS.Assign(FCSS.Lines); FProducer.JavaScript.Assign(FJS.Lines); End;
Procedure TRESTDWHTMLDesignerForm.RebuildFullCode;
Begin FUpdating:=True; Try SaveToProducer; FFullCode.Text:=FProducer.Produce; Finally FUpdating:=False; End; End;
Function TRESTDWHTMLDesignerForm.ExtractBetween(const AText,AStart,AEnd:String):String;
Var P1,P2:Integer;
Begin Result:=''; P1:=Pos(LowerCase(AStart),LowerCase(AText)); If P1=0 Then Exit; Inc(P1,Length(AStart)); P2:=PosEx(LowerCase(AEnd),LowerCase(AText),P1); If P2=0 Then Exit; Result:=Copy(AText,P1,P2-P1); End;
Procedure TRESTDWHTMLDesignerForm.ParseFullCodeToProducer;
Var T,B,C,J:String; P1,P2:Integer;
Begin
 T:=FFullCode.Text; B:=ExtractBetween(T,'<body>','</body>'); C:=ExtractBetween(T,'<style>','</style>');
 P1:=RESTDWRPos('<script>',LowerCase(T)); P2:=RESTDWRPos('</script>',LowerCase(T)); J:=''; If (P1>0) And (P2>P1) Then J:=Copy(T,P1+8,P2-(P1+8));
 { remove generated external script tags from body }
 P1:=Pos('<script src="/RESTDataware/',LowerCase(B)); If P1>0 Then B:=Copy(B,1,P1-1);
 FUpdating:=True; Try FHTML.Text:=Trim(B); FCSS.Text:=Trim(C); FJS.Text:=Trim(J); FProducer.HTML.Assign(FHTML.Lines); FProducer.CSS.Assign(FCSS.Lines); FProducer.JavaScript.Assign(FJS.Lines); Finally FUpdating:=False; End;
End;
Procedure TRESTDWHTMLDesignerForm.ShowFormDesign;
Begin
 FEditingEventCode := False;
 HideWebDropOverlay;
 { The Full Code editor is the editable source while the designer is hidden.
   Always parse it before returning to the WebView so JavaScript written in an
   event handler, HTML changes and CSS changes are immediately reflected in
   the rendered designer. }
 If Not FDesignMode Then
 Begin
  If FCodePages.ActivePage = FFullCodeTab Then
  Begin
   ClearMessages;
   If Pos('<html',LowerCase(FFullCode.Text)) = 0 Then
   Begin
    AddMessage('Error','Full Page','Missing <html> element',1,1);
    FocusCodeError(1,1);
    Exit;
   End;
   If Pos('<body',LowerCase(FFullCode.Text)) = 0 Then
   Begin
    AddMessage('Error','Full Page','Missing <body> element',1,1);
    FocusCodeError(1,1);
    Exit;
   End;
   If Pos('</body>',LowerCase(FFullCode.Text)) = 0 Then
   Begin
    AddMessage('Error','Full Page','Missing </body>',1,1);
    FocusCodeError(1,1);
    Exit;
   End;
   ParseFullCodeToProducer;
  End
  Else
   SaveToProducer;
 End;
 FDesignMode := True;
 FCodePages.Visible := False;
 FPreviewPanel.Visible := True;
 FFormDesignButton.Down := True;
 { Parse/save has already synchronized TRESTDWHTMLPageProducerAdapter. Validate before the
   single visual rebuild, then render once. RebuildVisualDesign itself calls
   RefreshWebView. A second immediate navigation is intentionally avoided
   because embedded WebView implementations may cancel/restart the first
   navigation and show only their gray host surface. }
 ValidateDocument;
 BuildProjectExplorer;
 RebuildVisualDesign;
End;
Procedure TRESTDWHTMLDesignerForm.ShowCodeEditor;
Begin
 InstallCodeWndProcHooks;
 { Object Inspector page is intentionally preserved here. In particular,
   EventsDblClick keeps the Events page active while editing its JavaScript. }
 HideWebDropOverlay;
 { Disable WebView synchronization before rebuilding code text. }
 FDesignMode := False;
 SaveToProducer;
 RebuildFullCode;
 FPreviewPanel.Visible := False;
 FCodePages.Visible := True;
 FCodePages.ActivePage := FFullCodeTab;
 FCodeEditorButton.Down := True;
 FFullCode.SetFocus;
 BuildProjectExplorer;
End;
Procedure TRESTDWHTMLDesignerForm.FormDesignButtonClick(
 Sender : TObject);
Begin
 ShowFormDesign;
End;
Procedure TRESTDWHTMLDesignerForm.CodeEditorButtonClick(
 Sender : TObject);
Var
 LTagName,
 LText,
 LID,
 LClassName,
 LOuterHTML : String;
 LNavigate : Boolean;
Begin
 LNavigate := FPendingCodeElement;
 LTagName := FPendingCodeTagName;
 LText := FPendingCodeText;
 LID := FPendingCodeID;
 LClassName := FPendingCodeClass;
 LOuterHTML := FPendingCodeOuterHTML;
 ShowCodeEditor;
 If LNavigate Then
 Begin
  FPendingCodeElement := False;
  FPendingCodeTagName := '';
  FPendingCodeText := '';
  FPendingCodeID := '';
  FPendingCodeClass := '';
  FPendingCodeOuterHTML := '';
  PositionElementCode(
   LTagName,
   LText,
   LID,
   LClassName,
   LOuterHTML,
   False
  );
  FFullCode.SetFocus;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.WebViewDevToolsClick(
 Sender : TObject);
Begin
 If Assigned(FWebView) Then
  FWebView.OpenDevTools;
End;
Procedure TRESTDWHTMLDesignerForm.ToggleSourceDesign;
Begin
 If FDesignMode Then
  ShowCodeEditor
 Else
  ShowFormDesign;
End;
Procedure TRESTDWHTMLDesignerForm.FormShowHandler(
 Sender : TObject);
Begin
 If FComponents.Count = 0 Then
  ScanPackagePalette;
 If Assigned(FWebView) Then
  FWebView.Initialize;
End;
Procedure TRESTDWHTMLDesignerForm.FormActivateHandler(
 Sender : TObject);
Var
 LOldLanguage : String;
Begin
 BringFloatingFormsToFront;
 LOldLanguage := FLanguageCode;
 ApplyLazarusLanguage;
 If Not SameText(
     LOldLanguage,
     FLanguageCode
    ) Then
  UpdateDocumentCaption;
End;
Function TRESTDWHTMLDesignerForm.DetectLazarusLanguage : String;
Begin
 Result := LowerCase(
  Trim(
   RESTDWSystemLanguage
  )
 );
 If Pos('-',Result) > 0 Then
  Result := Copy(
   Result,
   1,
   Pos('-',Result) - 1
  );
 If Pos('_',Result) > 0 Then
  Result := Copy(
   Result,
   1,
   Pos('_',Result) - 1
  );
 If Result = '' Then
  Result := 'en';
End;
Function TRESTDWHTMLDesignerForm.Lang(
 const AKey : String) : String;
Var
 LLang,
 LPack : String;
 LIndex,
 I,
 P,
 LStart : Integer;
Begin
 Result := AKey;
 LIndex := -1;
 LPack := '';
 LLang := DetectLazarusLanguage;
 If Pos('pt',LowerCase(LLang)) = 1 Then
 Begin
  If AKey = 'File' Then Result := 'Arquivo'
  Else If AKey = 'Edit' Then Result := 'Editar'
  Else If AKey = 'Search' Then Result := 'Pesquisar'
  Else If AKey = 'View' Then Result := 'Exibir'
  Else If AKey = 'New' Then Result := 'Novo'
  Else If AKey = 'Open' Then Result := 'Abrir'
  Else If AKey = 'Save' Then Result := 'Salvar'
  Else If AKey = 'ProjectName' Then Result := 'Projeto'
  Else If AKey = 'Undo' Then Result := 'Desfazer'
  Else If AKey = 'Cut' Then Result := 'Recortar'
  Else If AKey = 'Copy' Then Result := 'Copiar'
  Else If AKey = 'Paste' Then Result := 'Colar'
  Else If AKey = 'Find' Then Result := 'Localizar'
  Else If AKey = 'Replace' Then Result := 'Substituir'
  Else If AKey = 'FormDesign' Then Result := 'FormDesign'
  Else If AKey = 'CodeEditor' Then Result := 'Editor de C' + #243 + 'digo'
  Else If AKey = 'WebViewDevTools' Then Result := 'Ferramentas WebView'
  Else If AKey = 'ProjectExplorer' Then Result := 'Explorador de Projeto'
  Else If AKey = 'ObjectInspector' Then Result := 'Inspetor de Objetos'
  Else If AKey = 'ShowErrors' Then Result := 'Mostrar Erros'
  Else If AKey = 'Properties' Then Result := 'Propriedades'
  Else If AKey = 'Events' Then Result := 'Eventos'
  Else If AKey = 'Property' Then Result := 'Propriedade'
  Else If AKey = 'Value' Then Result := 'Valor'
  Else If AKey = 'Event' Then Result := 'Evento'
  Else If AKey = 'Handler' Then Result := 'Manipulador'
  Else If AKey = 'Type' Then Result := 'Tipo'
  Else If AKey = 'Line' Then Result := 'Linha'
  Else If AKey = 'Column' Then Result := 'Coluna'
  Else If AKey = 'Message' Then Result := 'Mensagem'
  Else If AKey = 'PageProducerProject' Then Result := 'Projeto PageProducer'
  Else If AKey = 'FullPage' Then Result := 'P' + #225 + 'gina Completa'
  Else If AKey = 'PageOptions' Then Result := 'Op' + #231 + #245 + 'es da P' + #225 + 'gina'
  Else If AKey = 'IncludeScripts' Then Result := 'Incluir Scripts'
  Else If AKey = 'Header' Then Result := 'Cabe' + #231 + 'alho'
  Else If AKey = 'Body' Then Result := 'Corpo'
  Else If AKey = 'Footer' Then Result := 'Rodap' + #233
  Else If AKey = 'Assets' Then Result := 'Recursos'
  Else If AKey = 'Components' Then Result := 'Componentes'
  Else If AKey = 'Close' Then Result := 'Fechar'
  Else If AKey = 'FloatDock' Then Result := 'Flutuar / Acoplar'
  Else
   Exit;
  Exit;
 End;
 If AKey = 'ProjectName' Then
 Begin
  Result := 'Project';
  Exit;
 End;
 If False Then
  LIndex := -1
 Else If AKey = 'File' Then LIndex := 0
 Else If AKey = 'Edit' Then LIndex := 1
 Else If AKey = 'Search' Then LIndex := 2
 Else If AKey = 'View' Then LIndex := 3
 Else If AKey = 'New' Then LIndex := 4
 Else If AKey = 'Open' Then LIndex := 5
 Else If AKey = 'Save' Then LIndex := 6
 Else If AKey = 'Undo' Then LIndex := 7
 Else If AKey = 'Cut' Then LIndex := 8
 Else If AKey = 'Copy' Then LIndex := 9
 Else If AKey = 'Paste' Then LIndex := 10
 Else If AKey = 'Find' Then LIndex := 11
 Else If AKey = 'Replace' Then LIndex := 12
 Else If AKey = 'FormDesign' Then LIndex := 13
 Else If AKey = 'CodeEditor' Then LIndex := 14
 Else If AKey = 'WebViewDevTools' Then LIndex := 15
 Else If AKey = 'ProjectExplorer' Then LIndex := 16
 Else If AKey = 'ObjectInspector' Then LIndex := 17
 Else If AKey = 'ShowErrors' Then LIndex := 18
 Else If AKey = 'Properties' Then LIndex := 19
 Else If AKey = 'Events' Then LIndex := 20
 Else If AKey = 'Property' Then LIndex := 21
 Else If AKey = 'Value' Then LIndex := 22
 Else If AKey = 'Event' Then LIndex := 23
 Else If AKey = 'Handler' Then LIndex := 24
 Else If AKey = 'Type' Then LIndex := 25
 Else If AKey = 'Line' Then LIndex := 26
 Else If AKey = 'Column' Then LIndex := 27
 Else If AKey = 'Message' Then LIndex := 28
 Else If AKey = 'PageProducerProject' Then LIndex := 29
 Else If AKey = 'FullPage' Then LIndex := 30
 Else If AKey = 'PageOptions' Then LIndex := 31
 Else If AKey = 'IncludeScripts' Then LIndex := 32
 Else If AKey = 'Header' Then LIndex := 33
 Else If AKey = 'Body' Then LIndex := 34
 Else If AKey = 'Footer' Then LIndex := 35
 Else If AKey = 'Assets' Then LIndex := 36
 Else If AKey = 'Components' Then LIndex := 37
 Else If AKey = 'Close' Then LIndex := 38
 Else If AKey = 'FloatDock' Then LIndex := 39;
 If LIndex < 0 Then
  Exit;
 If False Then
  LPack := ''
 Else If SameText(LLang,'en') Then LPack := 'File|Edit|Search|View|New|Open|Save|Undo|Cut|Copy|Paste|Find|Replace|FormDesign|Code Editor|WebView DevTools|Project Explorer|' +
  'Object Inspector|Show Errors|Properties|Events|Property|Value|Event|Handler|Type|Line|Column|' +
 'Message|PageProducer Project|Full Page|Page Options|Include Scripts|Header|Body|Footer|Assets|Components|Close|Float / Dock'
 Else If SameText(LLang,'af_ZA') Then LPack := 'Lêer|Wysig|Soek|Bekyk|Nuut|Open|Stoor|Ontdoen|Knip|Kopieer|Plak|Vind|Vervang|FormDesign|Kode-redigeerder|' +
  'WebView Ontwikkelaarnutsgoed|Projekverkenner|Objekinspekteur|Wys foute|Eienskappe|Gebeurtenisse|Eienskap|Waarde|' +
 'Gebeurtenis|Hanteerder|Tipe|Reël|Kolom|Boodskap|PageProducer-projek|Volledige bladsy|Bladsy-opsies|Sluit skrifte in|Kop|Liggaam|Voetskrif|Bates|Komponente|Sluit|Sweef / Dok'
 Else If SameText(LLang,'ar') Then LPack := 'ملف|تحرير|بحث|عرض|جديد|فتح|حفظ|تراجع|قص|نسخ|لصق|بحث|استبدال|FormDesign|' +
  'محرر الشفرة|أدوات WebView|مستكشف المشروع|فاحص الكائنات|' +
  'إظهار الأخطاء|الخصائص|الأحداث|الخاصية|القيمة|الحدث|المعالج|النوع|السطر|العمود|الرسالة|مشروع ' +
 'PageProducer|الصفحة الكاملة|خيارات الصفحة|تضمين البرامج النصية|الرأس|المحتوى|التذييل|الموارد|المكونات|إغلاق|عائم / إرساء'
 Else If SameText(LLang,'ca') Then LPack := 'Fitxer|Edita|Cerca|Visualitza|Nou|Obre|Desa|Desfés|Retalla|Copia|Enganxa|Cerca|Substitueix|FormDesign|Editor de codi|' +
  'Eines WebView|Explorador del projecte|Inspector d’objectes|Mostra errors|Propietats|Esdeveniments|' +
 'Propietat|Valor|Esdeveniment|Gestor|Tipus|Línia|Columna|Missatge|Projecte PageProducer|Pàgina completa|Opcions de pàgina|Inclou scripts|Capçalera|Cos|Peu|Recursos|Components|Tanca|Flotant / Acobla'
 Else If SameText(LLang,'cs') Then LPack := 'Soubor|Upravit|Hledat|Zobrazit|Nový|Otevřít|Uložit|Zpět|Vyjmout|Kopírovat|Vložit|Najít|Nahradit|FormDesign|Editor kódu|' +
  'Nástroje WebView|Průzkumník projektu|Inspektor objektů|Zobrazit chyby|Vlastnosti|Události|Vlastnost|' +
 'Hodnota|Událost|Obsluha|Typ|Řádek|Sloupec|Zpráva|Projekt PageProducer|Celá stránka|Možnosti stránky|Vložené skripty|Záhlaví|Tělo|Zápatí|Prostředky|Komponenty|Zavřít|Plovoucí / Ukotvit'
 Else If SameText(LLang,'de') Then LPack := 'Datei|Bearbeiten|Suchen|Ansicht|Neu|Öffnen|Speichern|Rückgängig|Ausschneiden|Kopieren|Einfügen|Suchen|Ersetzen|FormDesign|' +
  'Code-Editor|WebView-Entwicklertools|Projekt-Explorer|Objektinspektor|Fehler anzeigen|Eigenschaften|' +
 'Ereignisse|Eigenschaft|Wert|Ereignis|Handler|Typ|Zeile|Spalte|Meldung|PageProducer-Projekt|Komplette Seite|Seitenoptionen|Skripte einbinden|Kopf|Inhalt|Fußzeile|Ressourcen|Komponenten|Schließen|Schwebend / Andocken'
 Else If SameText(LLang,'es') Then LPack := 'Archivo|Editar|Buscar|Ver|Nuevo|Abrir|Guardar|Deshacer|Cortar|Copiar|Pegar|Buscar|Reemplazar|FormDesign|Editor de código|' +
  'Herramientas WebView|Explorador de proyecto|Inspector de objetos|Mostrar errores|Propiedades|' +
 'Eventos|Propiedad|Valor|Evento|Manejador|Tipo|Línea|Columna|Mensaje|Proyecto PageProducer|Página completa|Opciones de página|Incluir scripts|Encabezado|Cuerpo|Pie|Recursos|Componentes|Cerrar|Flotante / Acoplar'
 Else If SameText(LLang,'fi') Then LPack := 'Tiedosto|Muokkaa|Haku|Näytä|Uusi|Avaa|Tallenna|Kumoa|Leikkaa|Kopioi|Liitä|Etsi|Korvaa|FormDesign|Koodieditori|' +
  'WebView-kehittäjätyökalut|Projektiselain|Objektitarkastin|Näytä virheet|Ominaisuudet|Tapahtumat|Ominaisuus|' +
 'Arvo|Tapahtuma|Käsittelijä|Tyyppi|Rivi|Sarake|Viesti|PageProducer-projekti|Koko sivu|Sivun asetukset|Sisällytä skriptit|Ylätunniste|Runko|Alatunniste|Resurssit|Komponentit|Sulje|Kelluva / Telakoi'
 Else If SameText(LLang,'fr') Then LPack := 'Fichier|Édition|Rechercher|Affichage|Nouveau|Ouvrir|Enregistrer|Annuler|Couper|Copier|Coller|Rechercher|Remplacer|FormDesign|' +
  'Éditeur de code|Outils WebView|Explorateur de projet|Inspecteur d’objets|Afficher les erreurs|' +
 'Propriétés|Événements|Propriété|Valeur|Événement|Gestionnaire|Type|Ligne|Colonne|Message|Projet PageProducer|' +
  'Page complète|Options de page|Inclure les scripts|En-tête|Corps|Pied de page|Ressources|Composants|Fermer|' +
  'Flottant / Ancrer'
 Else If SameText(LLang,'he') Then LPack := 'קובץ|עריכה|חיפוש|תצוגה|חדש|פתח|שמור|בטל|גזור|העתק|הדבק|חפש|החלף|' +
  'FormDesign|עורך קוד|כלי WebView|סייר הפרויקט|מפקח אובייקטים|' +
  'הצג שגיאות|מאפיינים|אירועים|מאפיין|ערך|אירוע|מטפל|סוג|שורה|עמודה|הודעה|פרויקט PageProducer|עמוד ' +
 'מלא|אפשרויות עמוד|כלול סקריפטים|כותרת|גוף|כותרת תחתונה|משאבים|רכיבים|סגור|צף / עגון'
 Else If SameText(LLang,'hu') Then LPack := 'Fájl|Szerkesztés|Keresés|Nézet|Új|Megnyitás|Mentés|Visszavonás|Kivágás|Másolás|Beillesztés|Keresés|Csere|FormDesign|Kódszerkesztő|' +
  'WebView eszközök|Projektkezelő|Objektumfelügyelő|Hibák megjelenítése|Tulajdonságok|' +
 'Események|Tulajdonság|Érték|Esemény|Kezelő|Típus|Sor|Oszlop|Üzenet|PageProducer projekt|Teljes oldal|Oldalbeállítások|Szkriptek beillesztése|Fejléc|Törzs|Lábléc|Erőforrások|Komponensek|Bezárás|Lebegő / Dokkolás'
 Else If SameText(LLang,'id') Then LPack := 'Berkas|Sunting|Cari|Tampilan|Baru|Buka|Simpan|Urungkan|Potong|Salin|Tempel|Cari|Ganti|FormDesign|Editor Kode|Alat WebView|' +
  'Penjelajah Proyek|Inspektur Objek|Tampilkan Kesalahan|Properti|Peristiwa|Properti|Nilai|Peristiwa|' +
 'Penangan|Tipe|Baris|Kolom|Pesan|Proyek PageProducer|Halaman Penuh|Opsi Halaman|Sertakan Skrip|Header|Isi|Footer|Aset|Komponen|Tutup|Mengambang / Dok'
 Else If SameText(LLang,'it') Then LPack := 'File|Modifica|Cerca|Visualizza|Nuovo|Apri|Salva|Annulla|Taglia|Copia|Incolla|Trova|Sostituisci|FormDesign|Editor di codice|' +
  'Strumenti WebView|Esplora progetto|Ispettore oggetti|Mostra errori|Proprietà|Eventi|Proprietà|' +
 'Valore|Evento|Gestore|Tipo|Riga|Colonna|Messaggio|Progetto PageProducer|Pagina completa|Opzioni pagina|Includi script|Intestazione|Corpo|Piè di pagina|Risorse|Componenti|Chiudi|Mobile / Ancora'
 Else If SameText(LLang,'ja') Then LPack := 'ファイル|編集|検索|表示|新規|開く|保存|元に戻す|切り取り|コピー|貼り付け|検索|置換|FormDesign|' +
  'コードエディタ|WebView 開発者ツール|プロジェクトエクスプローラ|オブジェクトインスペクタ|エラー表示|' +
  'プロパティ|イベント|' +
  'プロパティ|値|イベント|ハンドラ|種類|行|列|メッセージ|PageProducer プロジェクト|ページ全体|ページオプション|' +
   'スクリプトを含める|ヘッダー|本文|フッター|アセット|コンポーネント|閉じる|フロート / ドッキング'
 Else If SameText(LLang,'lo') Then LPack := 'ແຟ້ມ|ແກ້ໄຂ|ຄົ້ນຫາ|ສະແດງ|ໃໝ່|ເປີດ|ບັນທຶກ|ຍົກເລີກ|ຕັດ|' +
  'ສຳເນົາ|ວາງ|ຄົ້ນຫາ|ແທນທີ່|FormDesign|ຕົວແກ້ໄຂໂຄດ|ເຄື່ອງມື WebView|' +
  'ຕົວສຳຫຼວດໂຄງການ|ຕົວກວດວັດຖຸ|ສະແດງຂໍ້ຜິດພາດ|' +
   'ຄຸນສົມບັດ|ເຫດການ|ຄຸນສົມບັດ|ຄ່າ|ເຫດການ|ຕົວຈັດການ|ປະເພດ|' +
   'ແຖວ|' +
 'ຖັນ|ຂໍ້ຄວາມ|ໂຄງການ PageProducer|ໜ້າເຕັມ|ຕົວເລືອກໜ້າ|ລວມສະຄຣິບ|' +
  'ສ່ວນຫົວ|ເນື້ອຫາ|ສ່ວນທ້າຍ|ຊັບພະຍາກອນ|ຄອມໂພເນັນ|ປິດ|' +
  'ລອຍ / ດັອກ'
 Else If SameText(LLang,'lt') Then LPack := 'Failas|Redaguoti|Ieškoti|Rodymas|Naujas|Atverti|Įrašyti|Atšaukti|Iškirpti|Kopijuoti|Įdėti|Rasti|Pakeisti|FormDesign|' +
  'Kodo redaktorius|WebView įrankiai|Projekto naršyklė|Objektų inspektorius|Rodyti klaidas|Savybės|Įvykiai|' +
 'Savybė|Reikšmė|Įvykis|Apdorojimas|Tipas|Eilutė|Stulpelis|Pranešimas|PageProducer projektas|Visas puslapis|' +
  'Puslapio parinktys|Įtraukti scenarijus|Antraštė|Turinys|Poraštė|Ištekliai|Komponentai|Užverti|' +
  'Plaukiojantis / Prijungti'
 Else If SameText(LLang,'nl') Then LPack := 'Bestand|Bewerken|Zoeken|Beeld|Nieuw|Openen|Opslaan|Ongedaan maken|Knippen|Kopiëren|Plakken|Zoeken|Vervangen|FormDesign|' +
  'Code-editor|WebView-hulpmiddelen|Projectverkenner|Objectinspecteur|Fouten tonen|Eigenschappen|' +
 'Gebeurtenissen|Eigenschap|Waarde|Gebeurtenis|Afhandelaar|Type|Regel|Kolom|Bericht|PageProducer-project|Volledige pagina|Pagina-opties|Scripts opnemen|Koptekst|Inhoud|Voettekst|Bronnen|Componenten|Sluiten|Zwevend / Docken'
 Else If SameText(LLang,'pl') Then LPack := 'Plik|Edycja|Szukaj|Widok|Nowy|Otwórz|Zapisz|Cofnij|Wytnij|Kopiuj|Wklej|Znajdź|Zamień|FormDesign|Edytor kodu|Narzędzia WebView|' +
  'Eksplorator projektu|Inspektor obiektów|Pokaż błędy|Właściwości|Zdarzenia|Właściwość|Wartość|' +
 'Zdarzenie|Obsługa|Typ|Wiersz|Kolumna|Komunikat|Projekt PageProducer|Pełna strona|Opcje strony|Dołącz skrypty|Nagłówek|Treść|Stopka|Zasoby|Komponenty|Zamknij|Pływające / Dokuj'
 Else If SameText(LLang,'pt') Then LPack := 'Ficheiro|Editar|Pesquisar|Ver|Novo|Abrir|Guardar|Desfazer|Cortar|Copiar|Colar|Localizar|Substituir|FormDesign|Editor de Código|' +
  'Ferramentas WebView|Explorador do Projeto|Inspetor de Objetos|Mostrar Erros|Propriedades|' +
 'Eventos|Propriedade|Valor|Evento|Manipulador|Tipo|Linha|Coluna|Mensagem|Projeto PageProducer|Página Completa|Opções da Página|Incluir Scripts|Cabeçalho|Corpo|Rodapé|Recursos|Componentes|Fechar|Flutuar / Acoplar'
 Else If SameText(LLang,'pt_BR') Then LPack := 'Arquivo|Editar|Pesquisar|Exibir|Novo|Abrir|Salvar|Desfazer|Recortar|Copiar|Colar|Localizar|Substituir|FormDesign|' +
  'Editor de Código|Ferramentas WebView|Explorador de Projeto|Inspetor de Objetos|Mostrar Erros|Propriedades|' +
 'Eventos|Propriedade|Valor|Evento|Manipulador|Tipo|Linha|Coluna|Mensagem|Projeto PageProducer|Página Completa|Opções da Página|Incluir Scripts|Cabeçalho|Corpo|Rodapé|Recursos|Componentes|Fechar|Flutuar / Acoplar'
 Else If SameText(LLang,'ru') Then LPack := 'Файл|Правка|Поиск|Вид|Новый|Открыть|Сохранить|Отменить|Вырезать|' +
  'Копировать|Вставить|Найти|Заменить|FormDesign|Редактор кода|' +
  'Инструменты WebView|Проводник проекта|Инспектор объектов|Показать ошибки|Свойства|События|' +
 'Свойство|Значение|Событие|Обработчик|Тип|Строка|Столбец|Сообщение|Проект PageProducer|' +
  'Полная страница|Параметры страницы|Подключить скрипты|Заголовок|Тело|Подвал|' +
  'Ресурсы|Компоненты|Закрыть|Плавающий / Закрепить'
 Else If SameText(LLang,'sk') Then LPack := 'Súbor|Upraviť|Hľadať|Zobraziť|Nový|Otvoriť|Uložiť|Späť|Vystrihnúť|Kopírovať|Vložiť|Nájsť|Nahradiť|FormDesign|Editor kódu|' +
  'Nástroje WebView|Prieskumník projektu|Inšpektor objektov|Zobraziť chyby|Vlastnosti|Udalosti|' +
 'Vlastnosť|Hodnota|Udalosť|Obsluha|Typ|Riadok|Stĺpec|Správa|Projekt PageProducer|Celá stránka|Možnosti stránky|Zahrnúť skripty|Hlavička|Telo|Päta|Prostriedky|Komponenty|Zavrieť|Plávajúce / Ukotviť'
 Else If SameText(LLang,'tr') Then LPack := 'Dosya|Düzenle|Ara|Görünüm|Yeni|Aç|Kaydet|Geri Al|Kes|Kopyala|Yapıştır|Bul|Değiştir|FormDesign|Kod Düzenleyici|WebView Araçları|' +
  'Proje Gezgini|Nesne Denetçisi|Hataları Göster|Özellikler|Olaylar|Özellik|Değer|Olay|İşleyici|' +
 'Tür|Satır|Sütun|Mesaj|PageProducer Projesi|Tam Sayfa|Sayfa Seçenekleri|Betikleri Dahil Et|Üstbilgi|Gövde|Altbilgi|Varlıklar|Bileşenler|Kapat|Yüzer / Yerleştir'
 Else If SameText(LLang,'uk') Then LPack := 'Файл|Редагування|Пошук|Вигляд|Новий|Відкрити|Зберегти|Скасувати|' +
  'Вирізати|Копіювати|Вставити|Знайти|Замінити|FormDesign|' +
  'Редактор коду|Інструменти WebView|Провідник проєкту|Інспектор об’єктів|Показати помилки|Властивості|' +
 'Події|Властивість|Значення|Подія|Обробник|Тип|Рядок|Стовпець|Повідомлення|' +
  'Проєкт PageProducer|Повна сторінка|Параметри сторінки|Підключити скрипти|Заголовок|' +
  'Тіло|Підвал|Ресурси|Компоненти|Закрити|Плаваючий / Закріпити'
 Else If SameText(LLang,'zh_CN') Then LPack := '文件|编辑|搜索|视图|新建|打开|保存|撤销|剪切|复制|粘贴|查找|替换|FormDesign|代码编辑器|WebView 开发工具|' +
  '项目浏览器|对象检查器|显示错误|属性|事件|属性|值|事件|处理程序|类型|行|列|消息|PageProducer 项目|完整页面|' +
  '页面选项|包含脚本|页眉|正文|页脚|资源|组件|关闭|浮动 / 停靠'
 Else
  LPack := 'File|Edit|Search|View|New|Open|Save|Undo|Cut|Copy|Paste|Find|Replace|FormDesign|Code Editor|WebView DevTools|Project Explorer|Object Inspector|Show Errors|Properties|Events|Property|Value|Event|Handler|Type|Line|Column|' +
  'Message|PageProducer Project|Full Page|Page Options|Include Scripts|Header|Body|Footer|Assets|Components|Close|Float / Dock';
 LStart := 1;
 For I := 0 To LIndex - 1 Do
 Begin
  P := PosEx('|',LPack,LStart);
  If P = 0 Then
   Exit;
  LStart := P + 1;
 End;
 P := PosEx('|',LPack,LStart);
 If P = 0 Then
  Result := Copy(LPack,LStart,MaxInt)
 Else
  Result := Copy(LPack,LStart,P-LStart);
End;
Procedure TRESTDWHTMLDesignerForm.SetDockHeaderLanguage(
 AHeader : TPanel;
 const ACaption : String);
Var
 I : Integer;
Begin
 If AHeader = Nil Then
  Exit;
 For I := 0 To AHeader.ControlCount - 1 Do
  If AHeader.Controls[I] Is TLabel Then
  Begin
   TLabel(AHeader.Controls[I]).Caption := ACaption;
   Exit;
  End;
End;
Procedure TRESTDWHTMLDesignerForm.ApplyLazarusLanguage;
Var
 L : String;
Begin
 FLanguageCode := DetectLazarusLanguage;
 L := LowerCase(FLanguageCode);
 If (Pos('ar',L) = 1) Or
    (Pos('he',L) = 1) Then
  BiDiMode := bdRightToLeft
 Else
  BiDiMode := bdLeftToRight;
 If Assigned(FFileMenuItem) Then
  FFileMenuItem.Caption := '&' + Lang('File');
 If Assigned(FEditMenuItem) Then
  FEditMenuItem.Caption := '&' + Lang('Edit');
 If Assigned(FSearchMenuItem) Then
  FSearchMenuItem.Caption := '&' + Lang('Search');
 If Assigned(FViewMenuItem) Then
  FViewMenuItem.Caption := '&' + Lang('View');
 If Assigned(FDebugMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugMenuItem.Caption := '&Depurar'
  Else
   FDebugMenuItem.Caption := '&Debug';
 End;
 If Assigned(FDebugStartMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugStartMenuItem.Caption := '&Executar / Continuar'
  Else
   FDebugStartMenuItem.Caption := '&Run / Continue';
 End;
 If Assigned(FDebugPauseMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugPauseMenuItem.Caption := '&Pausar'
  Else
   FDebugPauseMenuItem.Caption := '&Pause';
 End;
 If Assigned(FDebugRunToCursorMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugRunToCursorMenuItem.Caption := 'Executar até o &cursor'
  Else
   FDebugRunToCursorMenuItem.Caption := 'Run to &Cursor';
 End;
 If Assigned(FDebugStopMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugStopMenuItem.Caption := '&Parar programa'
  Else
   FDebugStopMenuItem.Caption := 'S&top Program';
 End;
 If Assigned(FDebugStepIntoMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugStepIntoMenuItem.Caption := 'Entrar &na rotina'
  Else
   FDebugStepIntoMenuItem.Caption := 'Step &Into';
 End;
 If Assigned(FDebugStepOverMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugStepOverMenuItem.Caption := 'Passar &sobre'
  Else
   FDebugStepOverMenuItem.Caption := 'Step &Over';
 End;
 If Assigned(FDebugStepOutMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugStepOutMenuItem.Caption := 'Sair da &rotina'
  Else
   FDebugStepOutMenuItem.Caption := 'Step O&ut';
 End;
 If Assigned(FDebugEvaluateMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugEvaluateMenuItem.Caption := '&Avaliar/Modificar...'
  Else
   FDebugEvaluateMenuItem.Caption := '&Evaluate/Modify...';
 End;
 If Assigned(FDebugBreakpointMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugBreakpointMenuItem.Caption := 'Alternar &breakpoint'
  Else
   FDebugBreakpointMenuItem.Caption := 'Toggle &Breakpoint';
 End;
 If Assigned(FDebugClearMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugClearMenuItem.Caption := '&Limpar breakpoints'
  Else
   FDebugClearMenuItem.Caption := '&Clear Breakpoints';
 End;
 If Assigned(FDebugReleaseAllMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugReleaseAllMenuItem.Caption := '&Liberar todos os breakpoints'
  Else
   FDebugReleaseAllMenuItem.Caption := '&Release All Breakpoints';
 End;
 If Assigned(FDebugDevToolsMenuItem) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FDebugDevToolsMenuItem.Caption := '&DevTools do WebView'
  Else
   FDebugDevToolsMenuItem.Caption := 'WebView &DevTools';
 End;
 If Assigned(FNewMenuItem) Then
  FNewMenuItem.Caption := '&' + Lang('New');
 If Assigned(FOpenMenuItem) Then
  FOpenMenuItem.Caption := '&' + Lang('Open') + '...';
 If Assigned(FSaveMenuItem) Then
  FSaveMenuItem.Caption := '&' + Lang('Save');
 If Assigned(FEditMenuItem) And
    (FEditMenuItem.Count >= 4) Then
 Begin
  FEditMenuItem.Items[0].Caption := '&' + Lang('Undo');
  FEditMenuItem.Items[1].Caption := Lang('Cut');
  FEditMenuItem.Items[2].Caption := '&' + Lang('Copy');
  FEditMenuItem.Items[3].Caption := '&' + Lang('Paste');
 End;
 If Assigned(FSearchMenuItem) And
    (FSearchMenuItem.Count >= 2) Then
 Begin
  FSearchMenuItem.Items[0].Caption := '&' + Lang('Find') + '...';
  FSearchMenuItem.Items[1].Caption := '&' + Lang('Replace') + '...';
 End;
 If Assigned(FViewMenuItem) And
    (FViewMenuItem.Count >= 8) Then
 Begin
  FViewMenuItem.Items[0].Caption := '&' + Lang('FormDesign');
  FViewMenuItem.Items[1].Caption := '&' + Lang('CodeEditor');
  FViewMenuItem.Items[2].Caption := Lang('WebViewDevTools');
  FViewMenuItem.Items[3].Caption := Lang('ProjectExplorer');
  FViewMenuItem.Items[4].Caption := Lang('ObjectInspector');
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FViewMenuItem.Items[5].Caption := 'Explorador de Objetos'
  Else
   FViewMenuItem.Items[5].Caption := 'Object Browser';
  FViewMenuItem.Items[6].Caption := Lang('ShowErrors');
  FViewMenuItem.Items[7].Caption := Lang('FormDesign');
 End;
 If Assigned(FNewButton) Then
  FNewButton.Hint :=
   Lang('New') +
   ': create a new blank PageProducer page. Unsaved changes are confirmed first. Ctrl+N.';
 If Assigned(FOpenButton) Then
  FOpenButton.Hint :=
   Lang('Open') +
   ': choose an HTML file from disk and load it into the visual editor. Unsaved changes are confirmed first. Ctrl+O.';
 If Assigned(FSaveButton) Then
  FSaveButton.Hint :=
   Lang('Save') +
   ': save the complete generated page to disk. Enabled only while the page has unsaved changes. Ctrl+S.';
 If Assigned(FFormDesignButton) Then
  FFormDesignButton.Caption := Lang('FormDesign');
 If Assigned(FCodeEditorButton) Then
 Begin
  If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
   FCodeEditorButton.Caption :=
    'Editor de C' + #243 + 'digo'
  Else
   FCodeEditorButton.Caption := 'Code Editor';
 End;
 SetDockHeaderLanguage(
  FProjectHeader,
  Lang('ProjectExplorer')
 );
 SetDockHeaderLanguage(
  FInspectorHeader,
  Lang('ObjectInspector')
 );
 If Pos('pt',LowerCase(FLanguageCode)) = 1 Then
  SetDockHeaderLanguage(FObjectBrowserHeader,'Explorador de Objetos')
 Else
  SetDockHeaderLanguage(FObjectBrowserHeader,'Object Browser');
 SetDockHeaderLanguage(
  FMessagesHeader,
  Lang('ShowErrors')
 );
 SetDockHeaderLanguage(
  FPreviewHeader,
  Lang('FormDesign')
 );
 If Assigned(FInspectorPages) And
    (FInspectorPages.PageCount >= 2) Then
 Begin
  FInspectorPages.Pages[0].Caption := Lang('Properties');
  FInspectorPages.Pages[1].Caption := Lang('Events');
 End;
 If Assigned(FProperties) Then
 Begin
  FProperties.Cells[0,0] := Lang('Property');
  FProperties.Cells[1,0] := Lang('Value');
 End;
 If Assigned(FEvents) Then
 Begin
  FEvents.Cells[0,0] := Lang('Event');
  FEvents.Cells[1,0] := Lang('Handler');
 End;
 If Assigned(FMessages) Then
 Begin
  FMessages.Cells[0,0] := Lang('Type');
  FMessages.Cells[1,0] := Lang('File');
  FMessages.Cells[2,0] := Lang('Line');
  FMessages.Cells[3,0] := Lang('Column');
  FMessages.Cells[4,0] := Lang('Message');
 End;
 If Assigned(FProjectFloatForm) Then
  FProjectFloatForm.Caption := Lang('ProjectExplorer');
 If Assigned(FInspectorFloatForm) Then
  FInspectorFloatForm.Caption := Lang('ObjectInspector');
 If Assigned(FMessagesFloatForm) Then
  FMessagesFloatForm.Caption := Lang('ShowErrors');
 If Assigned(FPreviewFloatForm) Then
  FPreviewFloatForm.Caption := Lang('FormDesign');
 BuildProjectExplorer;
 UpdateDocumentCaption;
End;
Procedure TRESTDWHTMLDesignerForm.UpdateDocumentCaption;
Var
 LName : String;
Begin
 If FCurrentFileName <> '' Then
  LName := ExtractFileName(FCurrentFileName)
 Else
  LName := FProducer.Name;
 If Trim(LName) = '' Then
  LName := 'PageProducer';
 If FEditorTitle <> '' Then
  Caption :=
   FEditorTitle +
   ' - ' +
   LName
 Else
  Caption :=
   'REST Dataware - Visual Web IDE - ' +
   LName;
 If FModified Then
  Caption := Caption + ' *';
End;
Procedure TRESTDWHTMLDesignerForm.SetModified(
 AValue : Boolean);
Begin
 FModified := AValue;
 If Assigned(FSaveButton) Then
  FSaveButton.Enabled := FModified;
 If Assigned(FSaveMenuItem) Then
  FSaveMenuItem.Enabled := FModified;
 UpdateDocumentCaption;
End;
Procedure TRESTDWHTMLDesignerForm.MarkModified;
Begin
 If Not FUpdating Then
  SetModified(True);
End;
Function TRESTDWHTMLDesignerForm.SaveDocument : Boolean;
Var
 LDialog : TSaveDialog;
 LText : TStringList;
Begin
 Result := False;
 If Not FDesignMode Then
  ParseFullCodeToProducer
 Else
  SaveToProducer;
 If FCurrentFileName = '' Then
 Begin
  LDialog := TSaveDialog.Create(Self);
  Try
   LDialog.Title := Lang('Save') + ' ' + Lang('ProjectName');
   LDialog.Filter :=
    'HTML files (*.html;*.htm)|*.html;*.htm|' +
    'All files (*.*)|*.*';
   LDialog.DefaultExt := 'html';
   LDialog.Options :=
    LDialog.Options + [ofOverwritePrompt];
   If Not LDialog.Execute Then
    Exit;
   FCurrentFileName := LDialog.FileName;
  Finally
   LDialog.Free;
  End;
 End;
 LText := TStringList.Create;
 Try
  LText.Text := FProducer.Produce;
  LText.SaveToFile(
   FCurrentFileName
  );
 Finally
  LText.Free;
 End;
 SetModified(False);
 If FNewPageActive Then
  ClearPreviousPage;
 Result := True;
End;
Function TRESTDWHTMLDesignerForm.ConfirmSaveChanges : Boolean;
Var
 LResult : Integer;
Begin
 Result := True;
 If Not FModified Then
  Exit;
 LResult := MessageDlg(
  Lang('Save') + ' ' + Lang('ProjectName') + '?',
  mtConfirmation,
  [mbYes,mbNo,mbCancel],
  0
 );
 Case LResult Of
  mrYes :
   Result := SaveDocument;
  mrNo :
   Begin
    If FNewPageActive Then
     RestorePreviousPage;
    Result := True;
   End;
  Else
   Result := False;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.FormCloseQueryHandler(
 Sender : TObject;
 Var CanClose : Boolean);
Begin
 CanClose := ConfirmSaveChanges;
End;
Procedure TRESTDWHTMLDesignerForm.CapturePreviousPage;
Begin
 FPreviousFileName := FCurrentFileName;
 FPreviousTitle := FProducer.Title;
 FPreviousRoute := FProducer.Route;
 FPreviousAutoDataTables := FProducer.AutoDataTables;
 FPreviousAutoCharts := FProducer.AutoCharts;
 FPreviousHTML.Assign(
  FProducer.HTML
 );
 FPreviousCSS.Assign(
  FProducer.CSS
 );
 FPreviousJS.Assign(
  FProducer.JavaScript
 );
 FNewPageActive := True;
End;
Procedure TRESTDWHTMLDesignerForm.RestorePreviousPage;
Begin
 If Not FNewPageActive Then
  Exit;
 FUpdating := True;
 Try
  FCurrentFileName := FPreviousFileName;
  FProducer.Title := FPreviousTitle;
  FProducer.Route := FPreviousRoute;
  FProducer.AutoDataTables := FPreviousAutoDataTables;
  FProducer.AutoCharts := FPreviousAutoCharts;
  FProducer.HTML.Assign(
   FPreviousHTML
  );
  FProducer.CSS.Assign(
   FPreviousCSS
  );
  FProducer.JavaScript.Assign(
   FPreviousJS
  );
  FHTML.Text := FProducer.HTML.Text;
  FCSS.Text := FProducer.CSS.Text;
  FJS.Text := FProducer.JavaScript.Text;
  RebuildFullCode;
  BuildProjectExplorer;
 Finally
  FUpdating := False;
 End;
 FNewPageActive := False;
 SetModified(False);
End;
Procedure TRESTDWHTMLDesignerForm.ClearPreviousPage;
Begin
 FNewPageActive := False;
 FPreviousFileName := '';
 FPreviousTitle := '';
 FPreviousRoute := '';
 FPreviousHTML.Clear;
 FPreviousCSS.Clear;
 FPreviousJS.Clear;
End;
Procedure TRESTDWHTMLDesignerForm.NewClick(
 Sender : TObject);
Begin
 If Not ConfirmSaveChanges Then
  Exit;
 CapturePreviousPage;
 FUpdating := True;
 Try
  FCurrentFileName := '';
  FPageOptionsSelected := False;
  FGeneratedInstanceNames.Clear;
  FProducer.Title := 'New REST Dataware Page';
  FProducer.Route := '/';
  FProducer.AutoDataTables := True;
  FProducer.AutoCharts := True;
  { TRESTDWHTMLPageProducerAdapter.Produce supplies <!doctype>, html, head, charset,
    viewport, Bootstrap/DataTables/Chart.js includes, body and script
    sections. FHTML intentionally contains the editable body only. }
  FHTML.Text :=
   '<main id="mainContent" class="container py-4">' + sLineBreak +
   ' <div class="row">' + sLineBreak +
   '  <div class="col-12">' + sLineBreak +
   '   <h1 class="mb-3">New REST Dataware Page</h1>' + sLineBreak +
   '   <p class="lead">Build this page with the visual component palette.</p>' + sLineBreak +
   '  </div>' + sLineBreak +
   ' </div>' + sLineBreak +
   '</main>';
  FCSS.Text :=
   'html, body {' + sLineBreak +
   ' min-height: 100%;' + sLineBreak +
   '}' + sLineBreak;
  FJS.Clear;
  FProducer.HTML.Assign(
   FHTML.Lines
  );
  FProducer.CSS.Assign(
   FCSS.Lines
  );
  FProducer.JavaScript.Assign(
   FJS.Lines
  );
  RebuildFullCode;
  BuildProjectExplorer;
 Finally
  FUpdating := False;
 End;
 RefreshWebView;
 SetModified(True);
 ShowFormDesign;
End;
Procedure TRESTDWHTMLDesignerForm.OpenClick(
 Sender : TObject);
Var
 LDialog : TOpenDialog;
 LText : TStringList;
Begin
 If Not ConfirmSaveChanges Then
  Exit;
 LDialog := TOpenDialog.Create(Self);
 Try
  LDialog.Title := Lang('Open') + ' HTML';
  LDialog.Filter :=
   'HTML files (*.html;*.htm)|*.html;*.htm|' +
   'All files (*.*)|*.*';
  LDialog.Options :=
   LDialog.Options + [ofFileMustExist];
  If Not LDialog.Execute Then
   Exit;
  LText := TStringList.Create;
  Try
   LText.LoadFromFile(
    LDialog.FileName
   );
   FGeneratedInstanceNames.Clear;
   FUpdating := True;
   Try
    FFullCode.Text := LText.Text;
   Finally
    FUpdating := False;
   End;
   ParseFullCodeToProducer;
   FCurrentFileName :=
    LDialog.FileName;
   FUpdating := True;
   Try
    RebuildFullCode;
    BuildProjectExplorer;
   Finally
    FUpdating := False;
   End;
   RefreshWebView;
   ClearPreviousPage;
   SetModified(False);
   ShowFormDesign;
  Finally
   LText.Free;
  End;
 Finally
  LDialog.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.FormKeyDownHandler(
 Sender : TObject;
 Var Key : Word;
 Shift : TShiftState);
Begin
 If Key = VK_F12 Then
 Begin
  ToggleSourceDesign;
  Key := 0;
  Exit;
 End;
 If (Key = VK_DELETE) And
    FDesignMode And
    (FSelectedElementID <> '') Then
 Begin
  DeleteSelectedVisualElement;
  Key := 0;
 End;
End;
Function TRESTDWHTMLDesignerForm.HelpLang(
 const AKey : String) : String;
Var
 LLang : String;
Begin
 LLang :=
  DetectLazarusLanguage;
 { Detailed Portuguese translation because pt/pt_BR is commonly used by this
   package. Other Lazarus languages reuse the IDE translation table for the
   structural terms and safely fall back to English for detailed prose. }
 If AKey = 'Title' Then Result := 'REST Dataware Visual Web IDE Help'
 Else If AKey = 'Subtitle' Then Result := 'Visual designer, PageProducer, Object Inspector, Project Explorer and JavaScript debugger.'
 Else If AKey = 'Contents' Then Result := 'Contents'
 Else If AKey = 'Start' Then Result := 'Getting started'
 Else If AKey = 'StartText' Then Result := 'New creates a complete PageProducer page. Open loads an HTML file from disk. Save is enabled only after a change, and the IDE asks before discarding modified content.'
 Else If AKey = 'Designer' Then Result := 'Form Designer / WebViewer'
 Else If AKey = 'DesignerText' Then Result := 'Click an element to select it for editing instead of navigating. Drag components from Component Palette into the page and press Delete to remove the selected component.'
 Else If AKey = 'Palette' Then Result := 'Component Palette'
 Else If AKey = 'PaletteText' Then Result := 'The Standard page contains common controls such as Label, Edit and Grid. Additional component definitions and plugins appear in their own palette pages.'
 Else If AKey = 'Inspector' Then Result := 'Object Inspector'
 Else If AKey = 'InspectorText' Then Result := 'Properties shows valid properties for the selected component. Events lists supported events; double-click an event to open or create its handler in Code Editor.'
 Else If AKey = 'Code' Then Result := 'Code Editor'
 Else If AKey = 'CodeText' Then Result := 'Full Code combines HTML, CSS and JavaScript with syntax highlighting. Project Explorer and event navigation position the cursor directly on the corresponding source.'
 Else If AKey = 'Debug' Then Result := 'JavaScript Debugger'
 Else If AKey = 'DebugText' Then Result := 'Double-click the line-number gutter to add or remove a breakpoint. When execution stops, Code Editor receives focus on the execution line. Hover a variable while paused to inspect its value.'
 Else If AKey = 'Command' Then Result := 'Command'
 Else If AKey = 'Shortcut' Then Result := 'Shortcut'
 Else If AKey = 'Action' Then Result := 'Action'
 Else If AKey = 'Run' Then Result := 'Run / Continue'
 Else If AKey = 'RunText' Then Result := 'Start or continue execution.'
 Else If AKey = 'Stop' Then Result := 'Stop Program'
 Else If AKey = 'StopText' Then Result := 'Stop the debug session.'
 Else If AKey = 'RunCursor' Then Result := 'Run to Cursor'
 Else If AKey = 'RunCursorText' Then Result := 'Continue to the selected JavaScript line.'
 Else If AKey = 'StepInto' Then Result := 'Step Into'
 Else If AKey = 'StepIntoText' Then Result := 'Enter a called routine.'
 Else If AKey = 'StepOver' Then Result := 'Step Over'
 Else If AKey = 'StepOverText' Then Result := 'Execute the current statement without entering the call.'
 Else If AKey = 'StepOut' Then Result := 'Step Out'
 Else If AKey = 'StepOutText' Then Result := 'Continue until the current routine returns.'
 Else If AKey = 'Evaluate' Then Result := 'Evaluate / Modify'
 Else If AKey = 'EvaluateText' Then Result := 'Inspect or change values in the paused call frame.'
 Else If AKey = 'Breakpoint' Then Result := 'Toggle Breakpoint'
 Else If AKey = 'BreakpointText' Then Result := 'Add or remove a breakpoint on the current JavaScript line.'
 Else If AKey = 'Project' Then Result := 'Project Explorer'
 Else If AKey = 'ProjectText' Then Result := 'Shows Page Options, HTML structure, CSS, JavaScript functions, assets and components. Clicking a node navigates to source while preserving the expanded/collapsed state.'
 Else If AKey = 'Logs' Then Result := 'Errors, Requests and Logs'
 Else If AKey = 'LogsText' Then Result := 'Show Errors receives source, line and column information. Double-click a request log row to inspect headers and the complete payload.'
 Else If AKey = 'Layout' Then Result := 'Docking and Layout'
 Else If AKey = 'LayoutText' Then Result := 'Project Explorer, Object Inspector, Show Errors, Form Designer and Component Palette participate in the IDE layout.'
 Else If AKey = 'Workflow' Then Result := 'Workflow'
 Else If AKey = 'WorkflowText' Then Result := 'Use Form Designer for visual composition, Object Inspector for properties/events, Project Explorer for navigation and Full Code for source editing/debugging.'
 Else If AKey = 'OpenError' Then Result := 'Could not open the local help file: '
 Else Result := AKey;
 If SameText(LLang,'pt') Or
    SameText(LLang,'pt_BR') Then
 Begin
  If AKey = 'Title' Then Result := 'Ajuda da IDE Visual Web REST Dataware'
  Else If AKey = 'Subtitle' Then Result := 'Designer visual, PageProducer, Object Inspector, Project Explorer e depurador JavaScript.'
  Else If AKey = 'Contents' Then Result := 'Conteúdo'
  Else If AKey = 'Start' Then Result := 'Primeiros passos'
  Else If AKey = 'StartText' Then Result := 'Novo cria uma página PageProducer completa. Abrir carrega um arquivo HTML do disco. Salvar só fica habilitado após alterações e a IDE pergunta antes de descartar conteúdo modificado.'
  Else If AKey = 'Designer' Then Result := 'Form Designer / WebViewer'
  Else If AKey = 'DesignerText' Then Result := 'Clique em um elemento para selecioná-lo e editar em vez de navegar. Arraste componentes da Component Palette para a página e pressione Delete para remover o componente selecionado.'
  Else If AKey = 'Palette' Then Result := 'Paleta de componentes'
  Else If AKey = 'PaletteText' Then Result := 'A página Standard contém os controles comuns como Label, Edit e Grid. Definições adicionais e plugins aparecem em suas próprias páginas da paleta.'
  Else If AKey = 'Inspector' Then Result := 'Object Inspector'
  Else If AKey = 'InspectorText' Then Result := 'Properties mostra as propriedades válidas do componente selecionado. Events lista os eventos suportados; dê duplo clique para abrir ou criar o handler no Code Editor.'
  Else If AKey = 'Code' Then Result := 'Editor de código'
  Else If AKey = 'CodeText' Then Result := 'Full Code combina HTML, CSS e JavaScript com destaque de sintaxe. Project Explorer e eventos posicionam o cursor diretamente no fonte correspondente.'
  Else If AKey = 'Debug' Then Result := 'Depurador JavaScript'
  Else If AKey = 'DebugText' Then
   Result :=
    'Dê duplo clique na régua do número da linha para adicionar ou remover ' +
    'um breakpoint. Quando a execução parar, o Code Editor recebe o foco ' +
    'na linha atual. Passe o mouse sobre uma variável durante a pausa para ' +
    'inspecionar o valor.'
  Else If AKey = 'Command' Then Result := 'Comando'
  Else If AKey = 'Shortcut' Then Result := 'Atalho'
  Else If AKey = 'Action' Then Result := 'Ação'
  Else If AKey = 'Run' Then Result := 'Executar / Continuar'
  Else If AKey = 'RunText' Then Result := 'Inicia ou continua a execução.'
  Else If AKey = 'Stop' Then Result := 'Parar programa'
  Else If AKey = 'StopText' Then Result := 'Encerra a sessão de depuração.'
  Else If AKey = 'RunCursor' Then Result := 'Executar até o cursor'
  Else If AKey = 'RunCursorText' Then Result := 'Continua até a linha JavaScript selecionada.'
  Else If AKey = 'StepInto' Then Result := 'Entrar na rotina'
  Else If AKey = 'StepIntoText' Then Result := 'Entra na rotina chamada.'
  Else If AKey = 'StepOver' Then Result := 'Passar sobre'
  Else If AKey = 'StepOverText' Then Result := 'Executa a instrução atual sem entrar na chamada.'
  Else If AKey = 'StepOut' Then Result := 'Sair da rotina'
  Else If AKey = 'StepOutText' Then Result := 'Continua até a rotina atual retornar.'
  Else If AKey = 'Evaluate' Then Result := 'Avaliar / Modificar'
  Else If AKey = 'EvaluateText' Then Result := 'Inspeciona ou altera valores no call frame pausado.'
  Else If AKey = 'Breakpoint' Then Result := 'Alternar breakpoint'
  Else If AKey = 'BreakpointText' Then Result := 'Adiciona ou remove um breakpoint na linha JavaScript atual.'
  Else If AKey = 'Project' Then Result := 'Project Explorer'
  Else If AKey = 'ProjectText' Then Result := 'Mostra Page Options, estrutura HTML, CSS, funções JavaScript, assets e componentes. O clique navega para o fonte preservando exatamente os nós abertos e fechados.'
  Else If AKey = 'Logs' Then Result := 'Erros, requisições e logs'
  Else If AKey = 'LogsText' Then Result := 'Show Errors recebe fonte, linha e coluna. No log de requisições, o duplo clique permite ver headers e todo o payload.'
  Else If AKey = 'Layout' Then Result := 'Docking e layout'
  Else If AKey = 'LayoutText' Then Result := 'Project Explorer, Object Inspector, Show Errors, Form Designer e Component Palette participam do layout da IDE.'
  Else If AKey = 'Workflow' Then Result := 'Fluxo de trabalho'
  Else If AKey = 'WorkflowText' Then Result := 'Use Form Designer para composição visual, Object Inspector para propriedades/eventos, Project Explorer para navegação e Full Code para edição e depuração.'
  Else If AKey = 'OpenError' Then Result := 'Não foi possível abrir o arquivo local de ajuda: ';
 End
 Else
 Begin
  { Structural terms use the existing 25-language Lazarus translation table. }
  If AKey = 'Designer' Then Result := Lang('FormDesign')
  Else If AKey = 'Palette' Then Result := Lang('Components')
  Else If AKey = 'Inspector' Then Result := Lang('ObjectInspector')
  Else If AKey = 'Code' Then Result := Lang('CodeEditor')
  Else If AKey = 'Project' Then Result := Lang('ProjectExplorer')
  Else If AKey = 'Logs' Then Result := Lang('ShowErrors')
  Else If AKey = 'Contents' Then
  Begin
   If SameText(LLang,'es') Then Result := 'Contenido'
   Else If SameText(LLang,'fr') Then Result := 'Sommaire'
   Else If SameText(LLang,'de') Then Result := 'Inhalt'
   Else If SameText(LLang,'it') Then Result := 'Contenuto'
   Else If SameText(LLang,'ru') Then Result := 'Содержание'
   Else If SameText(LLang,'zh_CN') Then Result := '目录'
   Else If SameText(LLang,'ja') Then Result := '目次';
  End;
 End;
End;
Function TRESTDWHTMLDesignerForm.BuildHelpHTML : String;
Var
 LHTMLLang : String;
Begin
 LHTMLLang :=
  StringReplace(
   DetectLazarusLanguage,
   '_',
   '-',
   [rfReplaceAll]
  );
 Result :=
  '<!doctype html>' + sLineBreak +
  '<html lang="' + LHTMLLang + '">' + sLineBreak +
  '<head>' + sLineBreak +
  '<meta charset="utf-8">' + sLineBreak +
  '<meta name="viewport" content="width=device-width,initial-scale=1">' + sLineBreak +
  '<title>' + HelpLang('Title') + '</title>' + sLineBreak +
  '<link rel="icon" href="data:image/svg+xml,' +
   '%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 64 64%22%3E' +
   '%3Ccircle cx=%2232%22 cy=%2232%22 r=%2230%22 fill=%22%23212529%22/%3E' +
   '%3Ctext x=%2232%22 y=%2244%22 font-size=%2242%22 text-anchor=%22middle%22 fill=%22white%22%3E?%3C/text%3E' +
   '%3C/svg%3E">' + sLineBreak +
  '<link href="../bootstrap/css/bootstrap.min.css" rel="stylesheet">' + sLineBreak +
  '<style>body{background:#f5f6f8}.hero{background:linear-gradient(135deg,#212529,#495057);color:#fff}' +
  '.card{border:0;box-shadow:0 .125rem .45rem rgba(0,0,0,.08)}kbd{white-space:nowrap}.toc a{text-decoration:none}</style>' + sLineBreak +
  '</head><body>' + sLineBreak +
  '<header class="hero py-5 mb-4"><div class="container"><h1 class="display-6 fw-bold">' +
   HelpLang('Title') + '</h1><p class="lead mb-0">' + HelpLang('Subtitle') +
   '</p></div></header>' + sLineBreak +
  '<main class="container pb-5">' +
  '<div class="card mb-4"><div class="card-body toc"><h2 class="h5">' + HelpLang('Contents') +
   '</h2><div class="row g-2">' +
  '<div class="col-md-4"><a href="#start">' + HelpLang('Start') + '</a></div>' +
  '<div class="col-md-4"><a href="#designer">' + HelpLang('Designer') + '</a></div>' +
  '<div class="col-md-4"><a href="#palette">' + HelpLang('Palette') + '</a></div>' +
  '<div class="col-md-4"><a href="#inspector">' + HelpLang('Inspector') + '</a></div>' +
  '<div class="col-md-4"><a href="#code">' + HelpLang('Code') + '</a></div>' +
  '<div class="col-md-4"><a href="#debug">' + HelpLang('Debug') + '</a></div>' +
  '<div class="col-md-4"><a href="#project">' + HelpLang('Project') + '</a></div>' +
  '<div class="col-md-4"><a href="#logs">' + HelpLang('Logs') + '</a></div>' +
  '<div class="col-md-4"><a href="#layout">' + HelpLang('Layout') + '</a></div>' +
  '</div></div></div>' +
  '<section id="start" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Start') + '</h2><p>' + HelpLang('StartText') + '</p></div></section>' +
  '<section id="designer" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Designer') + '</h2><p>' + HelpLang('DesignerText') + '</p></div></section>' +
  '<section id="palette" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Palette') + '</h2><p>' + HelpLang('PaletteText') + '</p></div></section>' +
  '<section id="inspector" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Inspector') + '</h2><p>' + HelpLang('InspectorText') + '</p></div></section>' +
  '<section id="code" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Code') + '</h2><p>' + HelpLang('CodeText') + '</p></div></section>' +
  '<section id="debug" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Debug') + '</h2><p>' + HelpLang('DebugText') + '</p>' +
  '<div class="table-responsive"><table class="table table-striped"><thead><tr><th>' +
   HelpLang('Command') + '</th><th>' + HelpLang('Shortcut') + '</th><th>' +
   HelpLang('Action') + '</th></tr></thead><tbody>' +
  '<tr><td>' + HelpLang('Run') + '</td><td><kbd>F9</kbd></td><td>' + HelpLang('RunText') + '</td></tr>' +
  '<tr><td>' + HelpLang('Stop') + '</td><td><kbd>Ctrl+F2</kbd></td><td>' + HelpLang('StopText') + '</td></tr>' +
  '<tr><td>' + HelpLang('RunCursor') + '</td><td><kbd>F4</kbd></td><td>' + HelpLang('RunCursorText') + '</td></tr>' +
  '<tr><td>' + HelpLang('StepInto') + '</td><td><kbd>F7</kbd></td><td>' + HelpLang('StepIntoText') + '</td></tr>' +
  '<tr><td>' + HelpLang('StepOver') + '</td><td><kbd>F8</kbd></td><td>' + HelpLang('StepOverText') + '</td></tr>' +
  '<tr><td>' + HelpLang('StepOut') + '</td><td><kbd>Shift+F8</kbd></td><td>' + HelpLang('StepOutText') + '</td></tr>' +
  '<tr><td>' + HelpLang('Evaluate') + '</td><td><kbd>Ctrl+F7</kbd></td><td>' + HelpLang('EvaluateText') + '</td></tr>' +
  '<tr><td>' + HelpLang('Breakpoint') + '</td><td><kbd>F5</kbd></td><td>' + HelpLang('BreakpointText') + '</td></tr>' +
  '</tbody></table></div></div></section>' +
  '<section id="project" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Project') + '</h2><p>' + HelpLang('ProjectText') + '</p></div></section>' +
  '<section id="logs" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Logs') + '</h2><p>' + HelpLang('LogsText') + '</p></div></section>' +
  '<section id="layout" class="card mb-4"><div class="card-body"><h2 class="h4">' +
   HelpLang('Layout') + '</h2><p>' + HelpLang('LayoutText') + '</p></div></section>' +
  '<div class="alert alert-primary"><strong>' + HelpLang('Workflow') + ':</strong> ' +
   HelpLang('WorkflowText') + '</div></main>' +
  '<script src="../bootstrap/js/bootstrap.bundle.min.js"></script></body></html>';
End;
Procedure TRESTDWHTMLDesignerForm.RefreshClick(
 Sender : TObject);
Begin
 RefreshWebView;
End;
Procedure TRESTDWHTMLDesignerForm.HelpClick(
 Sender : TObject);
Var
 LHelpDir,
 LHelpFile : String;
 LText : TStringList;
Begin
 LHelpDir :=
  IncludeTrailingPathDelimiter(
   ResolveEditorLibrariesPath
  ) +
  'help';
 If Not DirectoryExists(LHelpDir) Then
  ForceDirectories(LHelpDir);
 LHelpFile :=
  IncludeTrailingPathDelimiter(
   LHelpDir
  ) +
  'index.html';
 LText := TStringList.Create;
 Try
  LText.Text :=
   BuildHelpHTML;
  LText.SaveToFile(
   LHelpFile
  );
 Finally
  LText.Free;
 End;
 If Not RESTDWOpenDocument(LHelpFile) Then
  MessageDlg(
    HelpLang('OpenError') + LHelpFile,
    mtError,
    [mbOK],
    0
   );
End;
Procedure TRESTDWHTMLDesignerForm.SaveClick(
 Sender : TObject);
Begin
 SaveDocument;
End;
Procedure TRESTDWHTMLDesignerForm.PositionCode(
 const ASearchText : String;
 ASwitchToCode : Boolean);
Var
 P,
 LineNo,
 ColNo,
 I : Integer;
 TextAll : String;
Begin
 If Trim(ASearchText) = '' Then
  Exit;
 If ASwitchToCode Then
  ShowCodeEditor;
 TextAll := FFullCode.Text;
 P := Pos(
  LowerCase(ASearchText),
  LowerCase(TextAll)
 );
 If P = 0 Then
  Exit;
 LineNo := 1;
 ColNo := 1;
 For I := 1 To P - 1 Do
 Begin
  If TextAll[I] = #10 Then
  Begin
   Inc(LineNo);
   ColNo := 1;
  End
  Else If TextAll[I] <> #13 Then
   Inc(ColNo);
 End;
 {$IFDEF FPC}
 FFullCode.CaretXY := Point(ColNo,LineNo);
 {$ELSE}
 FFullCode.CaretXY := BufferCoord(ColNo,LineNo);
 {$ENDIF}
 FFullCode.BlockBegin := FFullCode.CaretXY;
 FFullCode.BlockEnd := FFullCode.CaretXY;
 If ASwitchToCode Then
  FFullCode.SetFocus;
End;
Procedure TRESTDWHTMLDesignerForm.PositionElementCode(
 const ATagName, AText, AID, AClassName, AOuterHTML : String;
 ASwitchToCode : Boolean);
Var
 LSearch,
 LTag,
 LClassToken : String;
 P : Integer;
Begin
 LSearch := Trim(AOuterHTML);
 { Prefer exact outer HTML. }
 If (LSearch <> '') And
    (Pos(LowerCase(LSearch),LowerCase(FProducer.Produce)) > 0) Then
 Begin
  PositionCode(
   LSearch,
   ASwitchToCode
  );
  Exit;
 End;
 { ID is the most reliable fallback. }
 If Trim(AID) <> '' Then
 Begin
  LSearch := 'id="' + AID + '"';
  If Pos(LowerCase(LSearch),LowerCase(FProducer.Produce)) > 0 Then
  Begin
   PositionCode(
    LSearch,
    ASwitchToCode
   );
   Exit;
  End;
  LSearch := 'id=''' + AID + '''';
  If Pos(LowerCase(LSearch),LowerCase(FProducer.Produce)) > 0 Then
  Begin
   PositionCode(
    LSearch,
    ASwitchToCode
   );
   Exit;
  End;
 End;
 { First class token is another stable fallback. }
 LClassToken := Trim(AClassName);
 P := Pos(' ',LClassToken);
 If P > 0 Then
  LClassToken := Copy(LClassToken,1,P-1);
 If LClassToken <> '' Then
 Begin
  LSearch := 'class="' + LClassToken;
  If Pos(LowerCase(LSearch),LowerCase(FProducer.Produce)) > 0 Then
  Begin
   PositionCode(
    LSearch,
    ASwitchToCode
   );
   Exit;
  End;
 End;
 { Last fallback uses visible text only. A generic '<tag' search is
   intentionally avoided because it can select the first element in the document. }
 If Trim(AText) <> '' Then
 Begin
  LSearch := Copy(Trim(AText),1,40);
  If Pos(
      LowerCase(LSearch),
      LowerCase(FProducer.Produce)
     ) > 0 Then
   PositionCode(
    LSearch,
    ASwitchToCode
   );
 End;
End;
Procedure TRESTDWHTMLDesignerForm.NavigateCode(
 const ASearchText : String);
Begin
 PositionCode(
  ASearchText,
  True
 );
End;
Procedure TRESTDWHTMLDesignerForm.ProjectTreeClick(
 Sender : TObject);
Var
 LNode : TTreeNode;
 LInfo : TRESTDWHTMLProjectNodeInfo;
 LSearchText : String;
Begin
 LNode := FProjectTree.Selected;
 If LNode = Nil Then
  Exit;
 { Copy navigation text BEFORE changing to Code Editor. ShowCodeEditor rebuilds
   the Project Explorer and therefore frees/recreates TRESTDWHTMLProjectNodeInfo. A
   const reference directly to LInfo.SearchText would otherwise point to the
   old freed node data and navigation could fall back to the beginning. }
 LSearchText := '';
 If LNode.Data <> Nil Then
 Begin
  LInfo :=
   TRESTDWHTMLProjectNodeInfo(
    LNode.Data
   );
  LSearchText :=
   LInfo.SearchText;
 End;
 If SameText(
     LNode.Text,
     Lang('PageOptions')
    ) Then
 Begin
  InspectorSetPageOptions;
  SetDockPanelVisible(
   2,
   True
  );
  If LSearchText = '' Then
   LSearchText := '<!doctype html>';
  NavigateCode(
   LSearchText
  );
  Exit;
 End;
 If LSearchText <> '' Then
 Begin
  NavigateCode(
   LSearchText
  );
  Exit;
 End;
 { Structural nodes navigate to their equivalent source section without
   changing the user's expanded/collapsed tree state. }
 If SameText(LNode.Text,'HTML') Then
  NavigateCode('<html')
 Else If SameText(LNode.Text,'CSS') Then
  NavigateCode('<style')
 Else If SameText(LNode.Text,'JavaScript') Then
  NavigateCode('<script')
 Else If SameText(LNode.Text,Lang('Assets')) Then
  NavigateCode('/RESTDataware/webassets/')
 Else If SameText(LNode.Text,Lang('Components')) Then
  NavigateCode('<body')
 Else If SameText(LNode.Text,Lang('PageProducerProject')) Then
  NavigateCode('<!doctype html>');
End;
Procedure TRESTDWHTMLDesignerForm.ClearMessages;
Begin
 FMessages.RowCount := 1;
End;
Procedure TRESTDWHTMLDesignerForm.AddMessage(
 const AKind,
 AFile,
 AText : String;
 ALine,
 AColumn : Integer);
Var
 R : Integer;
Begin
 R := FMessages.RowCount;
 FMessages.RowCount := R + 1;
 FMessages.Cells[0,R] := AKind;
 FMessages.Cells[1,R] := AFile;
 FMessages.Cells[2,R] := IntToStr(ALine);
 FMessages.Cells[3,R] := IntToStr(AColumn);
 FMessages.Cells[4,R] := AText;
End;
Procedure TRESTDWHTMLDesignerForm.ValidateDocument;
Var
 T : String;
Begin
 ClearMessages;
 T := LowerCase(FProducer.Produce);
 If Pos('<html',T) = 0 Then
  AddMessage(
   'Error',
   'Full Page',
   'Missing <html> element',
   1,
   1
  );
 If Pos('<body',T) = 0 Then
  AddMessage(
   'Error',
   'Full Page',
   'Missing <body> element',
   1,
   1
  );
 If Pos('</body>',T) = 0 Then
  AddMessage(
   'Error',
   'Full Page',
   'Missing </body>',
   1,
   1
  );
End;
Function TRESTDWHTMLDesignerForm.ActiveMemo : TSynEdit;
Begin
 Result := Nil;
 If Not FDesignMode Then
 Begin
  If FCodePages.ActivePage = FFullCodeTab Then
   Result := FFullCode
  Else If FCodePages.ActivePage = FHTMLTab Then
   Result := FHTML
  Else If FCodePages.ActivePage = FCSSTab Then
   Result := FCSS
  Else If FCodePages.ActivePage = FJSTab Then
   Result := FJS;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.FindClick(Sender:TObject);
Var
 S : String;
 M : TSynEdit;
 P,
 StartOffset,
 LineNo,
 ColNo,
 I,
 L : Integer;
 TextAll : String;
Begin
 M := ActiveMemo;
 If M = Nil Then
  Exit;
 S := '';
 If Not InputQuery('Find','Text:',S) Then
  Exit;
 TextAll := M.Text;
 StartOffset := 1;
 { Convert current caret to a character offset without SelStart/SelLength. }
 For I := 0 To M.CaretY - 2 Do
  Inc(StartOffset,Length(M.Lines[I]) + Length(sLineBreak));
 Inc(StartOffset,M.CaretX - 1);
 P := Pos(
  LowerCase(S),
  LowerCase(Copy(TextAll,StartOffset,MaxInt))
 );
 If P = 0 Then
  Exit;
 P := StartOffset + P - 1;
 LineNo := 1;
 ColNo := 1;
 For I := 1 To P - 1 Do
 Begin
  If TextAll[I] = #10 Then
  Begin
   Inc(LineNo);
   ColNo := 1;
  End
  Else If TextAll[I] <> #13 Then
   Inc(ColNo);
 End;
 {$IFDEF FPC}
 M.BlockBegin := Point(ColNo,LineNo);
 {$ELSE}
 M.BlockBegin := BufferCoord(ColNo,LineNo);
 {$ENDIF}
 L := Length(S);
 For I := 1 To L Do
 Begin
  If (P + I - 1 <= Length(TextAll)) And
     (TextAll[P + I - 1] = #10) Then
  Begin
   Inc(LineNo);
   ColNo := 1;
  End
  Else If (P + I - 1 <= Length(TextAll)) And
          (TextAll[P + I - 1] <> #13) Then
   Inc(ColNo);
 End;
 {$IFDEF FPC}
 M.BlockEnd := Point(ColNo,LineNo);
 {$ELSE}
 M.BlockEnd := BufferCoord(ColNo,LineNo);
 {$ENDIF}
 M.CaretXY := M.BlockEnd;
 M.SetFocus;
End;
Procedure TRESTDWHTMLDesignerForm.ReplaceClick(Sender:TObject); Var A,B:String; M:TSynEdit;
Begin M:=ActiveMemo; If M=Nil Then Exit; A:='';B:=''; If InputQuery('Replace','Find:',A) And InputQuery('Replace','Replace with:',B) Then M.Text:=StringReplace(M.Text,A,B,[rfReplaceAll]); End;
Procedure TRESTDWHTMLDesignerForm.UndoClick(Sender:TObject); Begin If ActiveMemo<>Nil Then ActiveMemo.Undo; End;
Procedure TRESTDWHTMLDesignerForm.CutClick(Sender:TObject); Begin If ActiveMemo<>Nil Then ActiveMemo.CutToClipboard; End;
Procedure TRESTDWHTMLDesignerForm.CopyClick(Sender:TObject); Begin If ActiveMemo<>Nil Then ActiveMemo.CopyToClipboard; End;
Procedure TRESTDWHTMLDesignerForm.PasteClick(Sender:TObject); Begin If ActiveMemo<>Nil Then ActiveMemo.PasteFromClipboard; End;
Function TRESTDWHTMLDesignerForm.ComponentInstanceBaseName(
 AInfo : TRESTDWHTMLWebComponentInfo) : String;
Var
 LSource : String;
 I : Integer;
 C : Char;
Begin
 Result := '';
 If AInfo = Nil Then
  Exit;
 LSource := Trim(AInfo.ClassName);
 If LSource = '' Then
  LSource := Trim(AInfo.Name);
 For I := 1 To Length(LSource) Do
 Begin
  C := LSource[I];
  If C In ['A'..'Z','a'..'z','0'..'9','_'] Then
   Result := Result + C;
 End;
 If Result = '' Then
  Result := 'TComponent';
 If Not (Result[1] In ['A'..'Z','a'..'z','_']) Then
  Result := 'T' + Result;
 If (AInfo.ClassName = AInfo.Name) And
    (UpCase(Result[1]) <> 'T') Then
  Result := 'T' + Result;
End;
Function TRESTDWHTMLDesignerForm.NextComponentInstanceName(
 const ABaseName : String) : String;
Var
 LAll,
 LCandidate,
 LNeedleID1,
 LNeedleID2,
 LNeedleName1,
 LNeedleName2 : String;
 N : Integer;
Begin
 LAll :=
  LowerCase(
   FProducer.HTML.Text +
   sLineBreak +
   FHTML.Text +
   sLineBreak +
   FFullCode.Text
  );
 N := 1;
 Repeat
  LCandidate :=
   ABaseName +
   IntToStr(N);
  LNeedleID1 :=
   'id="' +
   LowerCase(LCandidate) +
   '"';
  LNeedleID2 :=
   'id=''' +
   LowerCase(LCandidate) +
   '''';
  LNeedleName1 :=
   'name="' +
   LowerCase(LCandidate) +
   '"';
  LNeedleName2 :=
   'name=''' +
   LowerCase(LCandidate) +
   '''';
  If (Pos(LNeedleID1,LAll) = 0) And
     (Pos(LNeedleID2,LAll) = 0) And
     (Pos(LNeedleName1,LAll) = 0) And
     (Pos(LNeedleName2,LAll) = 0) And
     (FGeneratedInstanceNames.IndexOf(LCandidate) < 0) Then
  Begin
   FGeneratedInstanceNames.Add(
    LCandidate
   );
   Result := LCandidate;
   Exit;
  End;
  Inc(N);
 Until N = MaxInt;
 Result :=
  ABaseName +
  IntToStr(N);
End;
Function TRESTDWHTMLDesignerForm.ApplyComponentIdentity(
 const AHTML,
 AIdentity : String) : String;
Var
 LOpenEnd,
 LTagStart,
 LPos : Integer;
 LTag,
 LTail,
 LLower : String;
 Procedure ReplaceAttribute(
  const AAttribute : String);
 Var
  P,
  V1,
  V2 : Integer;
  Quote : Char;
  Prefix,
  Suffix : String;
 Begin
  LLower := LowerCase(LTag);
  P :=
   Pos(
    LowerCase(AAttribute) + '=',
    LLower
   );
  If P > 0 Then
  Begin
   V1 :=
    P +
    Length(AAttribute) +
    1;
   If V1 <= Length(LTag) Then
   Begin
    Quote := LTag[V1];
    If (Quote = '''') Or
       (Quote = '"') Then
    Begin
     V2 := V1 + 1;
     While (V2 <= Length(LTag)) And
           (LTag[V2] <> Quote) Do
      Inc(V2);
     If V2 <= Length(LTag) Then
     Begin
      Prefix := Copy(LTag,1,V1);
      Suffix := Copy(LTag,V2,MaxInt);
      LTag :=
       Prefix +
       AIdentity +
       Suffix;
      Exit;
     End;
    End;
   End;
  End;
  If (Length(LTag) > 0) And
     (LTag[Length(LTag)] = '>') Then
  Begin
   If (Length(LTag) > 1) And
      (LTag[Length(LTag) - 1] = '/') Then
    Insert(
     ' ' +
     AAttribute +
     '="' +
     AIdentity +
     '"',
     LTag,
     Length(LTag) - 1
    )
   Else
    Insert(
     ' ' +
     AAttribute +
     '="' +
     AIdentity +
     '"',
     LTag,
     Length(LTag)
    );
  End;
 End;
Begin
 Result := AHTML;
 LTagStart :=
  Pos(
   '<',
   Result
  );
 While (LTagStart > 0) And
       (LTagStart < Length(Result)) And
       (Result[LTagStart + 1] In ['!','?','/']) Do
 Begin
  LPos :=
   PosEx(
    '<',
    Result,
    LTagStart + 1
   );
  If LPos = 0 Then
   Exit;
  LTagStart := LPos;
 End;
 If LTagStart = 0 Then
  Exit;
 LOpenEnd :=
  PosEx(
   '>',
   Result,
   LTagStart + 1
  );
 If LOpenEnd = 0 Then
  Exit;
 LTag :=
  Copy(
   Result,
   LTagStart,
   LOpenEnd - LTagStart + 1
  );
 LTail :=
  Copy(
   Result,
   LOpenEnd + 1,
   MaxInt
  );
 ReplaceAttribute(
  'id'
 );
 ReplaceAttribute(
  'name'
 );
 Result :=
  Copy(
   Result,
   1,
   LTagStart - 1
  ) +
  LTag +
  LTail;
End;
Function TRESTDWHTMLDesignerForm.ComponentInstanceHTML(
 AInfo : TRESTDWHTMLWebComponentInfo) : String;
Var
 LBase,
 LIdentity : String;
Begin
 Result := '';
 If AInfo = Nil Then
  Exit;
 LBase :=
  ComponentInstanceBaseName(
   AInfo
  );
 LIdentity :=
  NextComponentInstanceName(
   LBase
  );
 Result :=
  ApplyComponentIdentity(
   ComponentHTML(AInfo.Name),
   LIdentity
  );
End;
Function TRESTDWHTMLDesignerForm.ComponentJSClassSource(
 AInfo : TRESTDWHTMLWebComponentInfo) : String;
Var
 LFileName : String;
 L : TStringList;
Begin
 Result := '';
 If (AInfo = Nil) Or
    (Trim(AInfo.JsFileName) = '') Then
  Exit;
 LFileName := AInfo.JsFileName;
 If Not FileExists(LFileName) Then
  LFileName :=
   IncludeTrailingPathDelimiter(
    RESTDWHTMLComponentsPath(
     ResolveEditorLibrariesPath
    )
   ) +
   AInfo.JsFileName;
 If Not FileExists(LFileName) Then
  Exit;
 L := TStringList.Create;
 Try
  L.LoadFromFile(LFileName);
  Result := L.Text;
 Finally
  L.Free;
 End;
End;

Function TRESTDWHTMLDesignerForm.ComponentOptionsJSON(
 AInfo : TRESTDWHTMLWebComponentInfo) : String;
Var
 I : Integer;
 LName,
 LValue : String;
 Function EscapeJSON(const AValue : String) : String;
 Begin
  Result := StringReplace(AValue,'\','\\',[rfReplaceAll]);
  Result := StringReplace(Result,'"','\"',[rfReplaceAll]);
  Result := StringReplace(Result,#13,'\r',[rfReplaceAll]);
  Result := StringReplace(Result,#10,'\n',[rfReplaceAll]);
 End;
Begin
 Result := '{';
 If (AInfo <> Nil) And
    (AInfo.Options <> Nil) Then
  For I := 0 To AInfo.Options.Count - 1 Do
  Begin
   LName := Trim(AInfo.Options.Names[I]);
   If LName = '' Then
    Continue;
   LValue := AInfo.Options.ValueFromIndex[I];
   If Length(Result) > 1 Then
    Result := Result + ',';
   Result :=
    Result +
    '"' + EscapeJSON(LName) + '":"' +
    EscapeJSON(LValue) + '"';
  End;
 Result := Result + '}';
End;

Procedure TRESTDWHTMLDesignerForm.InsertVisualComponent(
 AInfo : TRESTDWHTMLWebComponentInfo;
 X, Y : Integer;
 AAtPoint : Boolean);
Var
 LBase,
 LIdentity,
 LSource,
 LExtra,
 LLibrary,
 LFallback : String;
Begin
 If (AInfo = Nil) Or
    Not Assigned(FWebView) Or
    Not FWebView.Ready Then
  Exit;
 LBase := ComponentInstanceBaseName(AInfo);
 LIdentity := NextComponentInstanceName(LBase);
 LSource := ComponentJSClassSource(AInfo);
 LExtra := AInfo.HTMLExtension;
 LLibrary := ComponentLibraryHTML(AInfo);
 If Trim(LLibrary) <> '' Then
 Begin
  If LExtra <> '' Then
   LExtra := LExtra + sLineBreak;
  LExtra := LExtra + LLibrary;
 End;
 If Trim(LSource) <> '' Then
 Begin
  If AAtPoint Then
   FWebView.InsertJSClassAt(
    LSource,
    AInfo.ClassName,
    ComponentOptionsJSON(AInfo),
    LExtra,
    LIdentity,
    X,
    Y
   )
  Else
   FWebView.InsertJSClass(
    LSource,
    AInfo.ClassName,
    ComponentOptionsJSON(AInfo),
    LExtra,
    LIdentity
   );
 End
 Else
 Begin
  LFallback :=
   ApplyComponentIdentity(
    ComponentHTML(AInfo.Name),
    LIdentity
   );
  If AAtPoint Then
   FWebView.InsertHTMLAt(LFallback,X,Y)
  Else
   FWebView.InsertHTML(LFallback);
 End;
End;

Function TRESTDWHTMLDesignerForm.ApplyComponentOptions(
 AInfo : TRESTDWHTMLWebComponentInfo;
 const AHTML : String) : String;
Var
 I : Integer;
 LName,
 LValue,
 LAttrName,
 LOpenEnd : String;
 P : Integer;
Begin
 Result := AHTML;
 If (AInfo = Nil) Or
    (AInfo.Options = Nil) Then
  Exit;
 For I := 0 To AInfo.Options.Count - 1 Do
 Begin
  LName :=
   Trim(
    AInfo.Options.Names[I]
   );
  LValue :=
   AInfo.Options.ValueFromIndex[I];
  If LName = '' Then
   Continue;
  { Template placeholders allow component authors to decide exactly where
    an option is consumed by their HTML. }
  Result :=
   StringReplace(
    Result,
    '{{' + LName + '}}',
    LValue,
    [rfReplaceAll,rfIgnoreCase]
   );
  Result :=
   StringReplace(
    Result,
    '%' + LName + '%',
    LValue,
    [rfReplaceAll,rfIgnoreCase]
   );
  { Also expose every configured option as a data attribute on the root
    element, giving the local/external JS library a generic access path. }
  LAttrName :=
   LowerCase(
    StringReplace(
     LName,
     '_',
     '-',
     [rfReplaceAll]
    )
   );
  P :=
   Pos(
    '>',
    Result
   );
  If P > 0 Then
  Begin
   LOpenEnd :=
    ' data-laz-' +
    LAttrName +
    '="' +
    StringReplace(
     LValue,
     '"',
     '&quot;',
     [rfReplaceAll]
    ) +
    '"';
   Insert(
    LOpenEnd,
    Result,
    P
   );
  End;
 End;
End;
Function TRESTDWHTMLDesignerForm.ComponentLibraryHTML(
 AInfo : TRESTDWHTMLWebComponentInfo) : String;
Var
 LSource,
 LProjectDir,
 LDest,
 LClassFolder : String;
Begin
 Result := '';
 If (AInfo = Nil) Or
    (Trim(AInfo.FileName) = '') Then
  Exit;
 LClassFolder :=
  Trim(
   AInfo.ClassName
  );
 If LClassFolder = '' Then
  LClassFolder := AInfo.Name;
 If (FProducer.LibraryMode = lmURL) And
    (Trim(AInfo.ExternalURL) <> '') Then
 Begin
  LSource :=
   Trim(
    AInfo.ExternalURL
   );
  While (Length(LSource) > 0) And
        (LSource[Length(LSource)] = '/') Do
   Delete(
    LSource,
    Length(LSource),
    1
   );
  LSource :=
   LSource +
   '/' +
   AInfo.FileName;
 End
 Else
 Begin
  {$IFDEF Windows}
  LSource :=
   '.\html\libs\' +
   LClassFolder +
   '\' +
   AInfo.FileName;
  {$ELSE}
  LSource :=
   './html/libs/' +
   LClassFolder +
   '/' +
   AInfo.FileName;
  {$ENDIF}
  If (Trim(AInfo.LocalLibPath) <> '') And
     DirectoryExists(AInfo.LocalLibPath) And
     (RESTDWActiveProjectDir <> '') Then
  Begin
   LProjectDir :=
    RESTDWActiveProjectDir;
   LDest :=
    IncludeTrailingPathDelimiter(LProjectDir) +
    'html' +
    PathDelim +
    'libs' +
    PathDelim +
    LClassFolder;
   ForceDirectories(
    LDest
   );
   RESTDWCopyDirTree(AInfo.LocalLibPath,LDest);
  End;
 End;
 If SameText(
     ExtractFileExt(AInfo.FileName),
     '.css'
    ) Then
  Result :=
   '<link rel="stylesheet" href="' +
   LSource +
   '">'
 Else
  Result :=
   '<script src="' +
   LSource +
   '"></script>';
End;
Function TRESTDWHTMLDesignerForm.ComponentHTML(
 const AName : String) : String;
Var
 I : Integer;
 Info : TRESTDWHTMLWebComponentInfo;
 LLibraryHTML : String;
Begin
 Result := '';
 For I := 0 To FComponents.Count - 1 Do
 Begin
  Info :=
   TRESTDWHTMLWebComponentInfo(
    FComponents[I]
   );
  If SameText(
      Info.Name,
      AName
     ) Then
  Begin
   Result :=
    ApplyComponentOptions(
     Info,
     Info.HTML
    );
   LLibraryHTML :=
    ComponentLibraryHTML(
     Info
    );
   If Trim(LLibraryHTML) <> '' Then
    Result :=
     Result +
     sLineBreak +
     LLibraryHTML;
   Exit;
  End;
 End;
End;
Function TRESTDWHTMLDesignerForm.ResolveEditorLibrariesPath : String;
Var
 LConfigured,
 LProjectDir,
 LModuleDir,
 LCandidate : String;
 {$IFDEF FPC}
 LSourceDir : String;
 {$ENDIF}
 Function HasPackages(const APath : String) : Boolean;
 Var
  LSearch : TSearchRec;
 Begin
  Result := False;
  If Not DirectoryExists(APath) Then Exit;
  If FindFirst(
      IncludeTrailingPathDelimiter(APath) +
      'Packages' + PathDelim + '*.ini',
      faAnyFile,LSearch)=0 Then
  Begin
   Result := True;
   FindClose(LSearch);
  End;
 End;
 Function SearchFrom(const AStartDir : String) : String;
 Var
  LBase,
  LParent,
  LTry : String;
  I : Integer;
 Begin
  Result := '';
  If Trim(AStartDir) = '' Then Exit;
  LBase := ExpandFileName(AStartDir);
  For I := 0 To 12 Do
  Begin
   {$IFDEF FPC}
   LTry := IncludeTrailingPathDelimiter(LBase) +
    'Packages' + PathDelim + 'Lazarus' + PathDelim +
    'html' + PathDelim + 'libs';
   If HasPackages(LTry) Then Begin Result := ExpandFileName(LTry); Exit; End;
   {$ENDIF}
   LTry := IncludeTrailingPathDelimiter(LBase) +
    'Source' + PathDelim + 'Includes' + PathDelim +
    'HTMLEditor' + PathDelim + 'libs' + PathDelim + 'editor';
   If HasPackages(LTry) Then Begin Result := ExpandFileName(LTry); Exit; End;
   LTry := IncludeTrailingPathDelimiter(LBase) +
    'Source' + PathDelim + 'Includes' + PathDelim +
    'HTMLEditor' + PathDelim + 'editor';
   If HasPackages(LTry) Then Begin Result := ExpandFileName(LTry); Exit; End;
   LTry := IncludeTrailingPathDelimiter(LBase) +
    'libs' + PathDelim + 'editor';
   If HasPackages(LTry) Then Begin Result := ExpandFileName(LTry); Exit; End;
   {$IFNDEF FPC}
   LTry := IncludeTrailingPathDelimiter(LBase) +
    'Packages' + PathDelim + 'Delphi' + PathDelim +
    'html' + PathDelim + 'libs';
   If HasPackages(LTry) Then Begin Result := ExpandFileName(LTry); Exit; End;
   {$ENDIF}
   LTry := IncludeTrailingPathDelimiter(LBase) +
    'html' + PathDelim + 'libs';
   If HasPackages(LTry) Then Begin Result := ExpandFileName(LTry); Exit; End;
   LParent := ExcludeTrailingPathDelimiter(ExtractFileDir(LBase));
   If (LParent = '') Or SameText(LParent,LBase) Then Break;
   LBase := LParent;
  End;
 End;
 {$IFNDEF FPC}
 Function SearchDelphiLibraryPaths : String;
 Var
  LRegistry : TRegistry;
  LVersions,
  LPaths : TStringList;
  LVersion,
  LValue,
  LPath,
  LFound : String;
  I,
  J : Integer;
  Procedure SearchValue(const AKey,AValue : String);
  Var
   K : Integer;
  Begin
   If Result <> '' Then Exit;
   If Not LRegistry.OpenKeyReadOnly(AKey) Then Exit;
   Try
    If Not LRegistry.ValueExists(AValue) Then Exit;
    LValue := LRegistry.ReadString(AValue);
   Finally
    LRegistry.CloseKey;
   End;
   LPaths.StrictDelimiter := True;
   LPaths.Delimiter := ';';
   LPaths.DelimitedText := LValue;
   For K := 0 To LPaths.Count - 1 Do
   Begin
    LPath := Trim(LPaths[K]);
    If LPath = '' Then Continue;
    LPath := StringReplace(LPath,'$(BDS)',GetEnvironmentVariable('BDS'),[rfReplaceAll,rfIgnoreCase]);
    LPath := StringReplace(LPath,'$(BDSCOMMONDIR)',GetEnvironmentVariable('BDSCOMMONDIR'),[rfReplaceAll,rfIgnoreCase]);
    If Pos('$(',LPath) > 0 Then Continue;
    LFound := SearchFrom(LPath);
    If LFound <> '' Then
    Begin
     Result := LFound;
     Exit;
    End;
   End;
  End;
 Begin
  Result := '';
  LRegistry := TRegistry.Create(KEY_READ);
  LVersions := TStringList.Create;
  LPaths := TStringList.Create;
  Try
   LRegistry.RootKey := HKEY_CURRENT_USER;
   If LRegistry.OpenKeyReadOnly('\Software\Embarcadero\BDS') Then
   Begin
    LRegistry.GetKeyNames(LVersions);
    LRegistry.CloseKey;
   End;
   For I := LVersions.Count - 1 DownTo 0 Do
   Begin
    LVersion := LVersions[I];
    For J := 0 To 1 Do
    Begin
     If J = 0 Then
      SearchValue('\Software\Embarcadero\BDS\' + LVersion + '\Library\Win32','Search Path')
     Else
      SearchValue('\Software\Embarcadero\BDS\' + LVersion + '\Library\Win32','Browsing Path');
     If Result <> '' Then Exit;
    End;
   End;
  Finally
   LPaths.Free;
   LVersions.Free;
   LRegistry.Free;
  End;
 End;
 {$ENDIF}

Begin
 Result := '';
 LConfigured := Trim(FProducer.LibrariesPath);
 If (LConfigured <> '') And HasPackages(LConfigured) Then
 Begin
  Result := ExpandFileName(LConfigured);
  Exit;
 End;
 LProjectDir := RESTDWActiveProjectDir;
 If LProjectDir <> '' Then
 Begin
  If LConfigured <> '' Then
  Begin
   LCandidate := ExpandFileName(
    IncludeTrailingPathDelimiter(LProjectDir) + LConfigured);
   If HasPackages(LCandidate) Then
   Begin
    Result := LCandidate;
    Exit;
   End;
  End;
  Result := SearchFrom(LProjectDir);
  If Result <> '' Then Exit;
 End;
 {$IFDEF FPC}
 LSourceDir := ExtractFilePath({$I %FILE%});
 If LSourceDir <> '' Then
 Begin
  Result := SearchFrom(LSourceDir);
  If Result <> '' Then Exit;
 End;
 LModuleDir := ExtractFilePath(ParamStr(0));
 {$ELSE}
 SetLength(LModuleDir,MAX_PATH);
 SetLength(
  LModuleDir,
  GetModuleFileName(
   FindClassHInstance(Self.ClassType),
   PChar(LModuleDir),
   MAX_PATH
  )
 );
 LModuleDir := ExtractFilePath(LModuleDir);
 {$ENDIF}
 Result := SearchFrom(LModuleDir);
 If Result <> '' Then Exit;
 Result := SearchFrom(GetCurrentDir);
 If Result <> '' Then Exit;
 {$IFNDEF FPC}
 Result := SearchDelphiLibraryPaths;
 If Result <> '' Then Exit;
 {$ENDIF}
 LCandidate := FProducer.ResolveLibrariesPath;
 If HasPackages(LCandidate) Then
 Begin
  Result := ExpandFileName(LCandidate);
  Exit;
 End;
 LCandidate := RESTDWEnsureHTMLWebAssets;
 If HasPackages(LCandidate) Then
  Result := LCandidate;
End;

Function TRESTDWHTMLDesignerForm.IDESettingsFileName : String;
Var
 LPath : String;
Begin
 LPath := RESTDWEditorConfigDir;
 If Not DirectoryExists(LPath) Then
  ForceDirectories(LPath);
 Result :=
  IncludeTrailingPathDelimiter(LPath) +
  'RESTDWWebIDE_v2.ini';
End;
Procedure TRESTDWHTMLDesignerForm.MessagesCopyLineClick(
 Sender : TObject);
Var
 LRow : Integer;
 LText : String;
Begin
 If FMessages = Nil Then
  Exit;
 LRow := FMessages.Row;
 If (LRow < 1) Or (LRow >= FMessages.RowCount) Then
  Exit;
 LText :=
  FMessages.Cells[0,LRow] + #9 +
  FMessages.Cells[1,LRow] + #9 +
  FMessages.Cells[2,LRow] + #9 +
  FMessages.Cells[3,LRow] + #9 +
  FMessages.Cells[4,LRow];
 Clipboard.AsText := LText;
End;
Procedure TRESTDWHTMLDesignerForm.MessagesCopySelectionClick(
 Sender : TObject);
Var
 LTop,
 LBottom,
 I : Integer;
 LText : TStringList;
Begin
 If (FMessages = Nil) Or
    (FMessages.RowCount <= 1) Then
  Exit;
 LTop := FMessages.Selection.Top;
 LBottom := FMessages.Selection.Bottom;
 If LTop < 1 Then
  LTop := FMessages.Row;
 If LBottom < LTop Then
  LBottom := LTop;
 If LTop < 1 Then
  LTop := 1;
 If LBottom > FMessages.RowCount - 1 Then
  LBottom := FMessages.RowCount - 1;
 LText := TStringList.Create;
 Try
  For I := LTop To LBottom Do
   LText.Add(
    FMessages.Cells[0,I] + #9 +
    FMessages.Cells[1,I] + #9 +
    FMessages.Cells[2,I] + #9 +
    FMessages.Cells[3,I] + #9 +
    FMessages.Cells[4,I]
   );
  Clipboard.Clear;
  Clipboard.AsText := LText.Text;
 Finally
  LText.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.MessagesSelectAllClick(
 Sender : TObject);
Var
 LSelection : TGridRect;
Begin
 If (FMessages = Nil) Or
    (FMessages.RowCount <= 1) Then
  Exit;
 FMessages.Col := 0;
 FMessages.Row := 1;
 LSelection.Left := 0;
 LSelection.Top := 1;
 LSelection.Right := FMessages.ColCount - 1;
 LSelection.Bottom := FMessages.RowCount - 1;
 FMessages.Selection := LSelection;
 FMessages.SetFocus;
 FMessages.Invalidate;
End;
Procedure TRESTDWHTMLDesignerForm.MessagesCopyAllClick(
 Sender : TObject);
Var
 I : Integer;
 LText : TStringList;
Begin
 If (FMessages = Nil) Or
    (FMessages.RowCount <= 1) Then
  Exit;
 MessagesSelectAllClick(
  Sender
 );
 LText := TStringList.Create;
 Try
  LText.Add(
   'Type'#9'File'#9'Line'#9'Column'#9'Message'
  );
  For I := 1 To FMessages.RowCount - 1 Do
   LText.Add(
    FMessages.Cells[0,I] + #9 +
    FMessages.Cells[1,I] + #9 +
    FMessages.Cells[2,I] + #9 +
    FMessages.Cells[3,I] + #9 +
    FMessages.Cells[4,I]
   );
  Clipboard.Clear;
  Clipboard.AsText := LText.Text;
 Finally
  LText.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.MessagesKeyDown(
 Sender : TObject;
 Var Key : Word;
 Shift : TShiftState);
Begin
 If (ssCtrl In Shift) And
    (Key = Ord('A')) Then
 Begin
  MessagesSelectAllClick(
   Sender
  );
  Key := 0;
  Exit;
 End;
 If (ssCtrl In Shift) And
    (Key = Ord('C')) Then
 Begin
  MessagesCopySelectionClick(
   Sender
  );
  Key := 0;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.OpenWebViewInBrowserClick(
 Sender : TObject);
Var
 LFolder,
 LAssetsFolder,
 LSourceAssets,
 LFileName,
 LHTMLText : String;
 LHTML : TStringList;
Begin
 If FWebView = Nil Then
  Exit;
 LFolder :=
  IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) +
  'RESTDWWebPreviewBrowser';
 LAssetsFolder :=
  IncludeTrailingPathDelimiter(LFolder) +
  'assets';
 ForceDirectories(LFolder);
 LSourceAssets :=
  ResolveEditorLibrariesPath;
 If (LSourceAssets <> '') And
    DirectoryExists(LSourceAssets) Then
  RESTDWCopyDirTree(
   LSourceAssets,
   LAssetsFolder
  );
 LFileName :=
  IncludeTrailingPathDelimiter(LFolder) +
  'index.html';
 { Use the same preview HTML already prepared for the visual designer, then
   translate the WebView-only virtual host to real relative files copied beside
   index.html. The saved PageProducer/ContextRules HTML is never modified. }
 LHTMLText :=
  BuildPreviewHTML;
 LHTMLText :=
  StringReplace(
   LHTMLText,
   'https://restdwassets.local/',
   './assets/',
   [rfReplaceAll,rfIgnoreCase]
  );
 { The WebView intercepts REST calls during design. An external browser does
   not have that bridge, so add the same harmless design-only fetch response. }
 LHTMLText :=
  StringReplace(
   LHTMLText,
   '<head>',
   '<head>' +
   '<script>(function(){' +
   'var f=window.fetch;' +
   'if(!f){return;}' +
   'window.fetch=function(){' +
   'var a=arguments;' +
   'var q=(a.length>0)?a[0]:"";' +
   'var u=(q&&q.url)?q.url:String(q||"");' +
   'if(/(?:^|\\/)api(?:\\/|$)/i.test(u)){' +
   'return Promise.resolve(new Response("",{status:200,statusText:"Design Preview"}));' +
   '}' +
   'return f.apply(this,a);' +
   '};' +
   '})();</script>',
   [rfIgnoreCase]
  );
 LHTML := TStringList.Create;
 Try
  LHTML.Text := LHTMLText;
  LHTML.SaveToFile(LFileName);
 Finally
  LHTML.Free;
 End;
 If Not RESTDWOpenDocument(LFileName) Then
  ShowMessage(
   'Unable to open the current WebView page in the default browser.'
  );
End;
Procedure TRESTDWHTMLDesignerForm.MessagesResize(
 Sender : TObject);
Var
 LWidth : Integer;
Begin
 If FMessages = Nil Then
  Exit;
 LWidth :=
  FMessages.ClientWidth -
  FMessages.ColWidths[0] -
  FMessages.ColWidths[1] -
  FMessages.ColWidths[2] -
  FMessages.ColWidths[3] -
  8;
 If LWidth < 120 Then
  LWidth := 120;
 FMessages.ColWidths[4] := LWidth;
End;
Procedure TRESTDWHTMLDesignerForm.MessagesDblClick(
 Sender : TObject);
Var
 LRow,
 LLine,
 LColumn : Integer;
Begin
 LRow := FMessages.Row;
 If LRow < 1 Then
  Exit;
 LLine := StrToIntDef(
  FMessages.Cells[2,LRow],
  0
 );
 LColumn := StrToIntDef(
  FMessages.Cells[3,LRow],
  0
 );
 If LLine <= 0 Then
  Exit;
 ShowCodeEditor;
 If LLine > FFullCode.Lines.Count Then
  LLine := FFullCode.Lines.Count;
 If LLine < 1 Then
  Exit;
 FFullCode.CaretY := LLine;
 If LColumn > 0 Then
  FFullCode.CaretX := LColumn
 Else
  FFullCode.CaretX := 1;
 FFullCode.SetFocus;
End;
Procedure TRESTDWHTMLDesignerForm.LoadIDESettings;
Var
 LIni : TIniFile;
 LProjectVisible,
 LInspectorVisible,
 LObjectBrowserVisible,
 LMessagesVisible,
 LFormDesignVisible,
 LProjectFloating,
 LInspectorFloating,
 LObjectBrowserFloating,
 LMessagesFloating,
 LFormDesignFloating : Boolean;
Begin
 LIni := TIniFile.Create(
  IDESettingsFileName
 );
 Try
  Width := LIni.ReadInteger(
   'Window','Width',Width
  );
  Height := LIni.ReadInteger(
   'Window','Height',Height
  );
  Left := LIni.ReadInteger(
   'Window','Left',Left
  );
  Top := LIni.ReadInteger(
   'Window','Top',Top
  );
  WindowState := wsNormal;
  If Width > (Screen.WorkAreaRect.Right - Screen.WorkAreaRect.Left) - 40 Then
   Width := (Screen.WorkAreaRect.Right - Screen.WorkAreaRect.Left) - 40;
  If Height > (Screen.WorkAreaRect.Bottom - Screen.WorkAreaRect.Top) - 40 Then
   Height := (Screen.WorkAreaRect.Bottom - Screen.WorkAreaRect.Top) - 40;
  If Left < Screen.WorkAreaRect.Left Then
   Left := Screen.WorkAreaRect.Left + 20;
  If Top < Screen.WorkAreaRect.Top Then
   Top := Screen.WorkAreaRect.Top + 20;
  If Left + Width > Screen.WorkAreaRect.Right Then
   Left := Screen.WorkAreaRect.Right - Width - 20;
  If Top + Height > Screen.WorkAreaRect.Bottom Then
   Top := Screen.WorkAreaRect.Bottom - Height - 20;
  FProjectPanel.Width :=
   LIni.ReadInteger(
    'Layout',
    'ProjectManagerWidth',
    FProjectPanel.Width
   );
  FRightDockHost.Width :=
   LIni.ReadInteger(
    'Layout',
    'ObjectInspectorWidth',
    FRightDockHost.Width
   );
  FRightDockHost.Width :=
   LIni.ReadInteger(
    'Layout',
    'RightDockWidth',
    FRightDockHost.Width
   );
  FObjectBrowserPanel.Height :=
   LIni.ReadInteger(
    'Layout',
    'ObjectBrowserHeight',
    FObjectBrowserPanel.Height
   );
  FMessagesPanel.Height :=
   LIni.ReadInteger(
    'Layout',
    'ErrorListHeight',
    FMessagesPanel.Height
   );
  FMessages.ColWidths[0] :=
   LIni.ReadInteger(
    'ErrorList','TypeWidth',
    FMessages.ColWidths[0]
   );
  FMessages.ColWidths[1] :=
   LIni.ReadInteger(
    'ErrorList','FileWidth',
    FMessages.ColWidths[1]
   );
  FMessages.ColWidths[2] :=
   LIni.ReadInteger(
    'ErrorList','LineWidth',
    FMessages.ColWidths[2]
   );
  FMessages.ColWidths[3] :=
   LIni.ReadInteger(
    'ErrorList','ColumnWidth',
    FMessages.ColWidths[3]
   );
  LProjectVisible :=
   LIni.ReadBool('Docking','ProjectExplorerVisible',True);
  LInspectorVisible :=
   LIni.ReadBool('Docking','ObjectInspectorVisible',True);
  LObjectBrowserVisible :=
   LIni.ReadBool('Docking','ObjectBrowserVisible',True);
  LMessagesVisible :=
   LIni.ReadBool('Docking','ShowErrorsVisible',True);
  LFormDesignVisible :=
   LIni.ReadBool('Docking','FormDesignVisible',True);
  LProjectFloating :=
   LIni.ReadBool('Docking','ProjectExplorerFloating',False);
  LInspectorFloating :=
   LIni.ReadBool('Docking','ObjectInspectorFloating',False);
  LObjectBrowserFloating :=
   LIni.ReadBool('Docking','ObjectBrowserFloating',False);
  LMessagesFloating :=
   LIni.ReadBool('Docking','ShowErrorsFloating',False);
  LFormDesignFloating :=
   LIni.ReadBool('Docking','FormDesignFloating',False);
  If LProjectFloating Then
   ToggleFloatDock(1);
  If LInspectorFloating Then
   ToggleFloatDock(2);
  If LObjectBrowserFloating Then
   ToggleFloatDock(7);
  If LMessagesFloating Then
   ToggleFloatDock(3);
  If LFormDesignFloating Then
   ToggleFloatDock(4);
  SetDockPanelVisible(1,LProjectVisible);
  SetDockPanelVisible(2,LInspectorVisible);
  SetDockPanelVisible(7,LObjectBrowserVisible);
  SetDockPanelVisible(3,LMessagesVisible);
  SetDockPanelVisible(4,LFormDesignVisible);
  UpdateRightDockHost;
MessagesResize(
   FMessages
  );
 Finally
  LIni.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.SaveIDESettings;
Var
 LIni : TIniFile;
Begin
 If Not Assigned(FMessages) Or
    Not Assigned(FProjectPanel) Or
    Not Assigned(FInspectorPanel) Or
    Not Assigned(FObjectBrowserPanel) Or
    Not Assigned(FMessagesPanel) Or
    Not Assigned(FPreviewPanel) Then
  Exit;
 LIni := TIniFile.Create(
  IDESettingsFileName
 );
 Try
  LIni.WriteInteger(
   'Window','Width',Width
  );
  LIni.WriteInteger(
   'Window','Height',Height
  );
  LIni.WriteInteger(
   'Window','Left',Left
  );
  LIni.WriteInteger(
   'Window','Top',Top
  );
  LIni.WriteInteger(
   'Layout',
   'ProjectManagerWidth',
   FLeftDockHost.Width
  );
  LIni.WriteInteger(
   'Layout',
   'ObjectInspectorWidth',
   FRightDockHost.Width
  );
  LIni.WriteInteger(
   'Layout',
   'RightDockWidth',
   FRightDockHost.Width
  );
  LIni.WriteInteger(
   'Layout',
   'ObjectBrowserHeight',
   FObjectBrowserPanel.Height
  );
  LIni.WriteInteger(
   'Layout',
   'ErrorListHeight',
   FMessagesPanel.Height
  );
  LIni.WriteInteger(
   'ErrorList','TypeWidth',
   FMessages.ColWidths[0]
  );
  LIni.WriteInteger(
   'ErrorList','FileWidth',
   FMessages.ColWidths[1]
  );
  LIni.WriteInteger(
   'ErrorList','LineWidth',
   FMessages.ColWidths[2]
  );
  LIni.WriteInteger(
   'ErrorList','ColumnWidth',
   FMessages.ColWidths[3]
  );
  LIni.WriteBool(
   'Docking','ProjectExplorerVisible',
   FProjectPanel.Visible
  );
  LIni.WriteBool(
   'Docking','ObjectInspectorVisible',
   FInspectorPanel.Visible
  );
  LIni.WriteBool(
   'Docking','ObjectBrowserVisible',
   FObjectBrowserPanel.Visible
  );
  LIni.WriteBool(
   'Docking','ShowErrorsVisible',
   FMessagesPanel.Visible
  );
  LIni.WriteBool(
   'Docking','FormDesignVisible',
   FPreviewPanel.Visible
  );
  LIni.WriteBool(
   'Docking','ProjectExplorerFloating',
   Assigned(FProjectFloatForm)
  );
  LIni.WriteBool(
   'Docking','ObjectInspectorFloating',
   Assigned(FInspectorFloatForm)
  );
  LIni.WriteBool(
   'Docking','ObjectBrowserFloating',
   Assigned(FObjectBrowserFloatForm)
  );
  LIni.WriteBool(
   'Docking','ShowErrorsFloating',
   Assigned(FMessagesFloatForm)
  );
  LIni.WriteBool(
   'Docking','FormDesignFloating',
   Assigned(FPreviewFloatForm)
  );
Finally
  LIni.Free;
 End;
End;
Procedure TRESTDWHTMLDesignerForm.WebViewFirstTimerTimer(
 Sender : TObject);
Begin
 FWebViewFirstTimer.Enabled := False;
 If Not FWebViewFirstReady Or
    Not Assigned(FWebView) Or
    Not FWebView.Ready Then
 Begin
  FWebViewFirstTimer.Enabled := True;
  Exit;
 End;
 FWebView.Parent := FPreviewPanel;
 FWebView.Align := alClient;
 FWebView.Visible := True;
 FWebView.BringToFront;
 Application.ProcessMessages;
 FWebView.RebindHost;
 RefreshWebView;
 FWebViewFirstReady := False;
End;
Procedure TRESTDWHTMLDesignerForm.WebViewReady(Sender : TObject);
Begin
 FWebViewFirstReady := True;
 FWebViewFirstTimer.Enabled := False;
 FWebViewFirstTimer.Enabled := True;
End;
Procedure TRESTDWHTMLDesignerForm.WebViewError(
 Sender : TObject;
 const AMessage : String);
Begin
 AddMessage(
  'Error',
  'TRESTDWHTMLWebView',
  AMessage,
  0,
  0
 );
End;
Procedure TRESTDWHTMLDesignerForm.WebViewPageError(
 Sender : TObject;
 const AKind, ASource, AMessage : String;
 ALine, AColumn : Integer);
Begin
 AddMessage(
  AKind,
  ASource,
  AMessage,
  ALine,
  AColumn
 );
 If FDesignMode And
    (ALine > 0) And
    (
     SameText(AKind,'Error') Or
     SameText(AKind,'Promise') Or
     SameText(AKind,'Console Error')
    ) Then
  FocusCodeError(
   ALine,
   AColumn
  );
End;
Function TRESTDWHTMLDesignerForm.NormalizePreviewHTML(
 const AHTML : String) : String;
Var
 LText,
 LLower,
 LTag,
 LTagLower,
 LID,
 LLabelOpen,
 LBefore,
 LAfter : String;
 P,
 Q,
 R,
 LFieldNo,
 LLabelStart,
 LLabelEnd,
 LNextField,
 LNextTagEnd : Integer;
 Function AttrValue(
  const ATag,
  AName : String) : String;
 Var
  LLow,
  LNeedle : String;
  X,
  Y : Integer;
  C : Char;
 Begin
  Result := '';
  LLow := LowerCase(ATag);
  LNeedle := LowerCase(AName) + '=';
  X := Pos(LNeedle,LLow);
  If X = 0 Then
   Exit;
  Inc(X,Length(LNeedle));
  While (X <= Length(ATag)) And
        (ATag[X] = ' ') Do
   Inc(X);
  If X > Length(ATag) Then
   Exit;
  If (ATag[X] = '"') Or
     (ATag[X] = #39) Then
  Begin
   C := ATag[X];
   Inc(X);
   Y := X;
   While (Y <= Length(ATag)) And
         (ATag[Y] <> C) Do
    Inc(Y);
   Result := Copy(ATag,X,Y-X);
  End;
 End;
 Function HasAttr(
  const ATag,
  AName : String) : Boolean;
 Begin
  Result :=
   Pos(
    LowerCase(AName) + '=',
    LowerCase(ATag)
   ) > 0;
 End;
 Function InsertBeforeClose(
  const ATag,
  AText : String) : String;
 Var
  X : Integer;
 Begin
  Result := ATag;
  X := RESTDWRPos('>',Result);
  If X > 0 Then
   Insert(
    AText,
    Result,
    X
   );
 End;
Begin
 LText := AHTML;
 { Stop Chromium from making an implicit /favicon.ico request. This is added
   to the actual designer page before navigation, not after load. }
 If Pos(
     'rel="icon"',
     LowerCase(LText)
    ) = 0 Then
 Begin
  P := Pos(
   '<head',
   LowerCase(LText)
  );
  If P > 0 Then
  Begin
   P := PosEx(
    '>',
    LText,
    P
   );
   If P > 0 Then
    Insert(
     '<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 64 64%22%3E%3Ccircle cx=%2232%22 cy=%2232%22 r=%2230%22 fill=%22%23212529%22/%3E%3Ctext x=%2232%22 y=%2244%22 ' +
     'font-size=%2242%22 text-anchor=%22middle%22 fill=%22white%22%3E?%3C/text%3E%3C/svg%3E">',
     LText,
     P + 1
    );
  End
  Else
   LText :=
    '<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 64 64%22%3E%3Ccircle cx=%2232%22 cy=%2232%22 r=%2230%22 fill=%22%23212529%22/%3E%3Ctext x=%2232%22 y=%2244%22 ' +
    'font-size=%2242%22 text-anchor=%22middle%22 fill=%22white%22%3E?%3C/text%3E%3C/svg%3E">' +
    LText;
 End;
 { Give every form field id/name/aria-label before Chromium parses the page.
   This avoids both DevTools form-field warnings on old pages as well as on
   components created before IDs became mandatory. }
 LFieldNo := 0;
 P := 1;
 While P <= Length(LText) Do
 Begin
  LLower :=
   LowerCase(
    LText
   );
  Q := PosEx('<input',LLower,P);
  R := PosEx('<select',LLower,P);
  If (Q = 0) Or
     ((R > 0) And (R < Q)) Then
   Q := R;
  R := PosEx('<textarea',LLower,P);
  If (Q = 0) Or
     ((R > 0) And (R < Q)) Then
   Q := R;
  If Q = 0 Then
   Break;
  R := PosEx('>',LText,Q);
  If R = 0 Then
   Break;
  LTag := Copy(LText,Q,R-Q+1);
  LID := AttrValue(LTag,'id');
  If LID = '' Then
  Begin
   Inc(LFieldNo);
   LID := 'dsfield' + IntToStr(LFieldNo);
   LTag :=
    InsertBeforeClose(
     LTag,
     ' id="' + LID + '"'
    );
  End;
  If Not HasAttr(LTag,'name') Then
   LTag :=
    InsertBeforeClose(
     LTag,
     ' name="' + LID + '"'
    );
  If Not HasAttr(LTag,'aria-label') And
     Not HasAttr(LTag,'aria-labelledby') Then
   LTag :=
    InsertBeforeClose(
     LTag,
     ' aria-label="' + LID + '"'
    );
  Delete(LText,Q,R-Q+1);
  Insert(LTag,LText,Q);
  P := Q + Length(LTag);
 End;
 { Associate labels that do not already have for= with the next form field.
   This is done on markup before navigation so Chromium never sees an
   unassociated label. }
 P := 1;
 While P <= Length(LText) Do
 Begin
  LLower := LowerCase(LText);
  LLabelStart := PosEx('<label',LLower,P);
  If LLabelStart = 0 Then
   Break;
  LLabelEnd := PosEx('>',LText,LLabelStart);
  If LLabelEnd = 0 Then
   Break;
  LLabelOpen :=
   Copy(
    LText,
    LLabelStart,
    LLabelEnd-LLabelStart+1
   );
  If Pos(
      ' for=',
      LowerCase(LLabelOpen)
     ) = 0 Then
  Begin
   LNextField := PosEx('<input',LLower,LLabelEnd+1);
   Q := PosEx('<select',LLower,LLabelEnd+1);
   If (LNextField = 0) Or
      ((Q > 0) And (Q < LNextField)) Then
    LNextField := Q;
   Q := PosEx('<textarea',LLower,LLabelEnd+1);
   If (LNextField = 0) Or
      ((Q > 0) And (Q < LNextField)) Then
    LNextField := Q;
   If LNextField > 0 Then
   Begin
    LNextTagEnd := PosEx('>',LText,LNextField);
    If LNextTagEnd > LNextField Then
    Begin
     LTag :=
      Copy(
       LText,
       LNextField,
       LNextTagEnd-LNextField+1
      );
     LID :=
      AttrValue(
       LTag,
       'id'
      );
     If LID <> '' Then
     Begin
      LLabelOpen :=
       InsertBeforeClose(
        LLabelOpen,
        ' for="' + LID + '"'
       );
      Delete(
       LText,
       LLabelStart,
       LLabelEnd-LLabelStart+1
      );
      Insert(
       LLabelOpen,
       LText,
       LLabelStart
      );
      LLabelEnd :=
       LLabelStart +
       Length(LLabelOpen) - 1;
     End;
    End;
   End;
  End;
  P := LLabelEnd + 1;
 End;
 Result := LText;
End;
Function TRESTDWHTMLDesignerForm.JSLineToFullCodeLine(
 AJSLine : Integer) : Integer;
Var
 I,
 LScriptLine : Integer;
 LLine : String;
Begin
 Result := 0;
 If AJSLine < 1 Then
  Exit;
 LScriptLine := 0;
 For I := 0 To FFullCode.Lines.Count - 1 Do
 Begin
  LLine :=
   LowerCase(
    FFullCode.Lines[I]
   );
  If Pos('<script',LLine) > 0 Then
  Begin
   LScriptLine := I + 2;
   Break;
  End;
 End;
 If LScriptLine = 0 Then
  Exit;
 Result :=
  LScriptLine +
  AJSLine - 1;
 If Result > FFullCode.Lines.Count Then
  Result := 0;
End;
Function TRESTDWHTMLDesignerForm.FullCodeLineToJSLine(
 AFullLine : Integer) : Integer;
Var
 I,
 LScriptLine : Integer;
 LLine : String;
Begin
 Result := 0;
 LScriptLine := 0;
 For I := 0 To FFullCode.Lines.Count - 1 Do
 Begin
  LLine :=
   LowerCase(
    FFullCode.Lines[I]
   );
  If Pos('<script',LLine) > 0 Then
  Begin
   LScriptLine := I + 2;
   Break;
  End;
 End;
 If (LScriptLine = 0) Or
    (AFullLine < LScriptLine) Then
  Exit;
 Result :=
  AFullLine -
  LScriptLine + 1;
 If Result > FJS.Lines.Count Then
  Result := 0;
End;
Function TRESTDWHTMLDesignerForm.BuildPreviewHTML : String;
Var
 LHTML : String;
 LBasePath : String;
 PScript,
 PBody : Integer;
 Function LocalURL(const ARelativeName : String) : String;
 Var
  LRelative : String;
 Begin
  LRelative := StringReplace(
   ARelativeName,
   '\',
   '/',
   [rfReplaceAll]
  );
  LRelative := StringReplace(
   LRelative,
   ' ',
   '%20',
   [rfReplaceAll]
  );
  Result :=
   'https://restdwassets.local/' +
   LRelative;
 End;
Begin
 LHTML := FProducer.Produce;
 LBasePath :=
  ResolveEditorLibrariesPath;
 If FProducer.LibraryMode = lmLocal Then
 Begin
  LHTML := StringReplace(
   LHTML,
   FProducer.LocalHTMLLibrariesPath + '/bootstrap/css/bootstrap.min.css',
   LocalURL('bootstrap/css/bootstrap.min.css'),
   [rfReplaceAll]
  );
  LHTML := StringReplace(
   LHTML,
   FProducer.LocalHTMLLibrariesPath + '/datatables/dataTables.dataTables.min.css',
   LocalURL('datatables/dataTables.dataTables.min.css'),
   [rfReplaceAll]
  );
  LHTML := StringReplace(
   LHTML,
   FProducer.LocalHTMLLibrariesPath + '/bootstrap/js/bootstrap.bundle.min.js',
   LocalURL('bootstrap/js/bootstrap.bundle.min.js'),
   [rfReplaceAll]
  );
  LHTML := StringReplace(
   LHTML,
   FProducer.LocalHTMLLibrariesPath + '/datatables/dataTables.min.js',
   LocalURL('datatables/dataTables.min.js'),
   [rfReplaceAll]
  );
  LHTML := StringReplace(
   LHTML,
   FProducer.LocalHTMLLibrariesPath + '/chartjs/chart.umd.min.js',
   LocalURL('chartjs/chart.umd.min.js'),
   [rfReplaceAll]
  );
 End;
 LHTML := StringReplace(
  LHTML,
  '/RESTDataware/webassets/bootstrap/css/bootstrap.min.css',
  LocalURL('bootstrap/css/bootstrap.min.css'),
  [rfReplaceAll]
 );
 LHTML := StringReplace(
  LHTML,
  '/RESTDataware/webassets/datatables/dataTables.dataTables.min.css',
  LocalURL('datatables/dataTables.dataTables.min.css'),
  [rfReplaceAll]
 );
 LHTML := StringReplace(
  LHTML,
  '/RESTDataware/webassets/bootstrap/js/bootstrap.bundle.min.js',
  LocalURL('bootstrap/js/bootstrap.bundle.min.js'),
  [rfReplaceAll]
 );
 LHTML := StringReplace(
  LHTML,
  '/RESTDataware/webassets/datatables/dataTables.min.js',
  LocalURL('datatables/dataTables.min.js'),
  [rfReplaceAll]
 );
 LHTML := StringReplace(
  LHTML,
  '/RESTDataware/webassets/chartjs/chart.umd.min.js',
  LocalURL('chartjs/chart.umd.min.js'),
  [rfReplaceAll]
 );
  { Preview-only asset resolver.
   The authored HTML is not changed. Explicit /showcase paths are supported
   even when FProducer.Route is "/" because Showcase keeps one server context. }
 { The runtime-homologated form is relative to the single base context. }
 LHTML := StringReplace(
  LHTML,
  './libs/bootstrap/css/bootstrap.min.css',
  LocalURL('bootstrap/css/bootstrap.min.css'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  './libs/bootstrap/js/bootstrap.bundle.min.js',
  LocalURL('bootstrap/js/bootstrap.bundle.min.js'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  './libs/datatables/dataTables.dataTables.min.css',
  LocalURL('datatables/dataTables.dataTables.min.css'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  './libs/datatables/dataTables.min.js',
  LocalURL('datatables/dataTables.min.js'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  './libs/chartjs/chart.umd.min.js',
  LocalURL('chartjs/chart.umd.min.js'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  '/showcase/libs/bootstrap/css/bootstrap.min.css',
  LocalURL('bootstrap/css/bootstrap.min.css'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  '/showcase/libs/bootstrap/js/bootstrap.bundle.min.js',
  LocalURL('bootstrap/js/bootstrap.bundle.min.js'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  '/showcase/libs/datatables/dataTables.dataTables.min.css',
  LocalURL('datatables/dataTables.dataTables.min.css'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  '/showcase/libs/datatables/dataTables.min.js',
  LocalURL('datatables/dataTables.min.js'),
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  '/showcase/libs/chartjs/chart.umd.min.js',
  LocalURL('chartjs/chart.umd.min.js'),
  [rfReplaceAll,rfIgnoreCase]
 );
 { Restrict banner replacement to complete src attributes. Replacing the bare
   /rdw.jpg substring also matches inside restdwassets.local and
   causes brandinghttps://... on a second replacement. }
 LHTML := StringReplace(
  LHTML,
  'src="logo-rdw-oficial.png"',
  'src="' + LocalURL('branding/logo-rdw-oficial.png') + '"',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  'src="./logo-rdw-oficial.png"',
  'src="' + LocalURL('branding/logo-rdw-oficial.png') + '"',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  'src="/logo-rdw-oficial.png"',
  'src="' + LocalURL('branding/logo-rdw-oficial.png') + '"',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  'src="./rdw.jpg"',
  'src="' + LocalURL('branding/rdw.jpg') + '"',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  'src="/rdw.jpg"',
  'src="' + LocalURL('branding/rdw.jpg') + '"',
  [rfReplaceAll,rfIgnoreCase]
 );
 { Mark only preview-generated library scripts. These attributes exist solely in
   the WebView preview and are stripped from the HTML synchronized back to FHTML. }
 LHTML := StringReplace(
  LHTML,
  '<script src="https://restdwassets.local/bootstrap/js/bootstrap.bundle.min.js"></script>',
  '<script data-restdataware-generated="1" src="https://restdwassets.local/bootstrap/js/bootstrap.bundle.min.js"></script>',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  '<script src="https://restdwassets.local/datatables/dataTables.min.js"></script>',
  '<script data-restdataware-generated="1" src="https://restdwassets.local/datatables/dataTables.min.js"></script>',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  '<script src="https://restdwassets.local/chartjs/chart.umd.min.js"></script>',
  '<script data-restdataware-generated="1" src="https://restdwassets.local/chartjs/chart.umd.min.js"></script>',
  [rfReplaceAll,rfIgnoreCase]
 );
 { The final inline script before </body> is FProducer.JavaScript, not authored
   body HTML. Mark that preview node too so body synchronization cannot absorb it. }
 PBody :=
  Pos(
   '</body>',
   LowerCase(LHTML)
  );
 If PBody > 0 Then
 Begin
  PScript :=
   RESTDWRPos(
    '<script>',
    LowerCase(
     Copy(
      LHTML,
      1,
      PBody - 1
     )
    )
   );
  If PScript > 0 Then
   Insert(
    ' data-restdataware-generated="1"',
    LHTML,
    PScript + Length('<script')
   );
 End;
 Result := NormalizePreviewHTML(LHTML);
End;
Procedure TRESTDWHTMLDesignerForm.RefreshWebView;
Begin
 If Assigned(FWebView) Then
 Begin
  FWebView.AssetsFolder :=
   ResolveEditorLibrariesPath;
  FWebView.HTML :=
   BuildPreviewHTML;
 End;
End;
Function RESTDWExecuteContextRulesHTMLDesigner(
 AContextRules : TRESTDWContextRules;
 const AEditorTitle : String) : Boolean;
Var
 LAdapter : TRESTDWHTMLPageProducerAdapter;
 LDesigner : TRESTDWHTMLDesignerForm;
Begin
 Result := False;
 If AContextRules = Nil Then
  Exit;
 LAdapter :=
  TRESTDWHTMLPageProducerAdapter.CreateForContext(
   AContextRules
  );
 Try
  LDesigner :=
   TRESTDWHTMLDesignerForm.CreateDesigner(
    LAdapter,
    AEditorTitle
   );
  Try
   Result :=
    LDesigner.ExecuteModal;
   If Result Then
    LAdapter.SaveToContextRules;
  Finally
   LDesigner.Free;
  End;
 Finally
  LAdapter.Free;
 End;
End;
End.
