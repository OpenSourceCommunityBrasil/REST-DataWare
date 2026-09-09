unit uRESTDWHTMLWebView;
{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}
Interface
Uses
 Classes, SysUtils, StrUtils, Controls, ExtCtrls, uRESTDWHTMLJSONCompat, uRESTDWHTMLWebAssets
 {$IFDEF MSWINDOWS},
 Windows, uRESTDWPrivWVBrowser, uRESTDWPrivWVWindowParent, uRESTDWPrivWVLoader, uRESTDWPrivWVTypes, uRESTDWPrivWVEvents,
 uRESTDWPrivWVTypeLibrary, uRESTDWPrivWVCoreWebView2Args
 {$ENDIF};
Type
 TRESTDWHTMLWebViewErrorEvent = Procedure(Sender : TObject;
  const AMessage : String) Of Object;
 TRESTDWHTMLWebViewPageErrorEvent = Procedure(Sender : TObject;
  const AKind, ASource, AMessage : String;
  ALine, AColumn : Integer) Of Object;
 TRESTDWHTMLWebViewElementSelectedEvent = Procedure(Sender : TObject;
  const AElementID, ATagName, AText, AID, AClassName,
  AOuterHTML : String) Of Object;
 TRESTDWHTMLWebViewHTMLChangedEvent = Procedure(Sender : TObject;
  const AHTML : String) Of Object;
 TRESTDWHTMLWebViewObjectTreeEvent = Procedure(Sender : TObject;
  const AJSON : String) Of Object;
 TRESTDWHTMLWebViewDebugBreakpointEvent = Procedure(Sender : TObject;
  ALine : Integer) Of Object;
 TRESTDWHTMLWebViewDebugEvaluateEvent = Procedure(Sender : TObject;
  ARequestID : Integer; const AExpression, AValue, AError : String;
  ASuccess : Boolean) Of Object;
 TDSWebViewDragOverEvent = Procedure(Sender, Source : TObject;
  X, Y : Integer; State : TDragState; Var Accept : Boolean) Of Object;
 TDSWebViewDragDropEvent = Procedure(Sender, Source : TObject;
  X, Y : Integer) Of Object;
 TRESTDWHTMLWebView = Class(TCustomControl)
 Private
  FHTML : String;
  FPreviewFileName : String;
  FPreviewFolder : String;
  FAssetsFolder : String;
  FVirtualHostsReady : Boolean;
  FNavigationSerial : Integer;
  FOnDesignDragOver : TDSWebViewDragOverEvent;
  FOnDesignDragDrop : TDSWebViewDragDropEvent;
  FReady : Boolean;
  FStarted : Boolean;
  FOnReady : TNotifyEvent;
  FOnError : TRESTDWHTMLWebViewErrorEvent;
  FOnPageError : TRESTDWHTMLWebViewPageErrorEvent;
  FOnElementSelected : TRESTDWHTMLWebViewElementSelectedEvent;
  FOnHTMLChanged : TRESTDWHTMLWebViewHTMLChangedEvent;
  FOnObjectTree : TRESTDWHTMLWebViewObjectTreeEvent;
  FOnDebugBreakpoint : TRESTDWHTMLWebViewDebugBreakpointEvent;
  FOnDebugEvaluate : TRESTDWHTMLWebViewDebugEvaluateEvent;
  FDebugCallFrameID : String;
  FDebugScriptID : String;
  FDebugSourceLine : Integer;
  FDebugExpressions : TStringList;
  {$IFDEF MSWINDOWS}
  FWindowParent : TWVWindowParent;
  FBrowser : TWVBrowser;
  FInitTimer : TTimer;
  FInitTicks : Integer;
  FLoaderReadyTicks : Integer;
  Procedure InitTimer(Sender : TObject);
  Procedure BrowserAfterCreated(Sender : TObject);
  Procedure BrowserInitializationError(Sender : TObject;
   AErrorCode : HRESULT; const AErrorMessage : wvstring);
  Procedure BrowserWebMessageReceived(Sender : TObject;
   const AWebView : ICoreWebView2;
   const AArgs : ICoreWebView2WebMessageReceivedEventArgs);
  Procedure BrowserNavigationCompleted(Sender : TObject;
   const AWebView : ICoreWebView2;
   const AArgs : ICoreWebView2NavigationCompletedEventArgs);
  Procedure BrowserDevToolsEventReceived(Sender : TObject;
   const AWebView : ICoreWebView2;
   const AArgs : ICoreWebView2DevToolsProtocolEventReceivedEventArgs;
   const AEventName : wvstring; AEventID : Integer);
  Procedure BrowserDevToolsMethodCompleted(Sender : TObject;
   AErrorCode : HRESULT; const AResult : wvstring; AExecutionID : Integer);
  Procedure InstallPageErrorBridge;
  Function InjectPageErrorBridge(const AHTML : String) : String;
  Procedure EmitPageError(const AKind, ASource, AMessage : String;
   ALine, AColumn : Integer);
  Procedure WindowDragOver(Sender, Source : TObject;
   X, Y : Integer; State : TDragState; Var Accept : Boolean);
  Procedure WindowDragDrop(Sender, Source : TObject;
   X, Y : Integer);
  {$ENDIF}
  Procedure SetHTML(const AValue : String);
  Procedure SetAssetsFolder(const AValue : String);
  Function PrepareVirtualHosts : Boolean;
 Protected
  Procedure Resize; Override;
 Public
  Constructor Create(AOwner : TComponent); Override;
  Destructor Destroy; Override;
  Procedure Initialize;
  Procedure Refresh;
  Procedure DetachHost;
  Procedure RebindHost;
  Procedure OpenDevTools;
  Procedure EnableDebugger;
  Procedure DisableDebugger;
  Procedure DebugResume;
  Procedure DebugPause;
  Procedure DebugStepInto;
  Procedure DebugStepOver;
  Procedure DebugStepOut;
  Procedure DebugContinueToLine(ALine : Integer);
  Procedure EvaluateDebugExpression(ARequestID : Integer;
   const AExpression : String);
  Procedure ModifyDebugExpression(ARequestID : Integer;
   const AExpression, AValueExpression : String);
  Procedure UpdateSelectedElement(const AProperty, AValue : String);
  Procedure SelectElement(const AElementID : String);
  Procedure InsertHTML(const AHTML : String);
  Procedure InsertJSClass(const AJavaScript, AClassName,
   AOptionsJSON, AHTMLExtension, AIdentity : String);
  Procedure InsertHTMLAt(const AHTML : String; X, Y : Integer);
  Procedure InsertJSClassAt(const AJavaScript, AClassName,
   AOptionsJSON, AHTMLExtension, AIdentity : String; X, Y : Integer);
  Procedure DeleteSelectedElement;
  Procedure RequestHTML;
  Property Ready : Boolean Read FReady;
 Published
  Property Align;
  Property Anchors;
  Property Visible;
  Property Enabled;
  Property HTML : String Read FHTML Write SetHTML;
  Property AssetsFolder : String Read FAssetsFolder Write SetAssetsFolder;
  Property OnReady : TNotifyEvent Read FOnReady Write FOnReady;
  Property OnError : TRESTDWHTMLWebViewErrorEvent Read FOnError Write FOnError;
  Property OnPageError : TRESTDWHTMLWebViewPageErrorEvent
   Read FOnPageError Write FOnPageError;
  Property OnElementSelected : TRESTDWHTMLWebViewElementSelectedEvent
   Read FOnElementSelected Write FOnElementSelected;
  Property OnHTMLChanged : TRESTDWHTMLWebViewHTMLChangedEvent
   Read FOnHTMLChanged Write FOnHTMLChanged;
  Property OnObjectTree : TRESTDWHTMLWebViewObjectTreeEvent
   Read FOnObjectTree Write FOnObjectTree;
  Property OnDebugBreakpoint : TRESTDWHTMLWebViewDebugBreakpointEvent
   Read FOnDebugBreakpoint Write FOnDebugBreakpoint;
  Property OnDebugEvaluate : TRESTDWHTMLWebViewDebugEvaluateEvent
   Read FOnDebugEvaluate Write FOnDebugEvaluate;
  Property OnDesignDragOver : TDSWebViewDragOverEvent
   Read FOnDesignDragOver Write FOnDesignDragOver;
  Property OnDesignDragDrop : TDSWebViewDragDropEvent
   Read FOnDesignDragDrop Write FOnDesignDragDrop;
 End;
Implementation
Var
 GRESTDWHTMLWebViewCount : Integer = 0;
Function RESTDWEscapeJavaScriptString(Const AValue : String) : String;
Begin
 Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
 Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
 Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
 Result := StringReplace(Result, #39, '\''', [rfReplaceAll]);
 Result := StringReplace(Result, '</', '<\/', [rfReplaceAll]);
End;
Function RESTDWHTMLTempDir : String;
{$IFDEF MSWINDOWS}
Var
 LBuffer : Array[0..MAX_PATH] Of Char;
 LLen : DWORD;
{$ENDIF}
Begin
 {$IFDEF MSWINDOWS}
 LLen := Windows.GetTempPath(
  MAX_PATH,
  LBuffer
 );
 If LLen > 0 Then
  SetString(
   Result,
   LBuffer,
   LLen
  )
 Else
  Result := ExtractFilePath(ParamStr(0));
 {$ELSE}
 Result := GetEnvironmentVariable('TMPDIR');
 If Result = '' Then
  Result := GetEnvironmentVariable('TEMP');
 If Result = '' Then
  Result := ExtractFilePath(ParamStr(0));
 {$ENDIF}
 Result := IncludeTrailingPathDelimiter(Result);
End;
Constructor TRESTDWHTMLWebView.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 Inc(GRESTDWHTMLWebViewCount);
 FHTML := '';
 FPreviewFolder :=
  RESTDWHTMLTempDir +
  'RESTDatawareWebPreview';
 If Not DirectoryExists(FPreviewFolder) Then
  ForceDirectories(FPreviewFolder);
 FPreviewFileName :=
  IncludeTrailingPathDelimiter(FPreviewFolder) +
  'index.html';
 FAssetsFolder := '';
 FVirtualHostsReady := False;
 FNavigationSerial := 0;
 FReady := False;
 FStarted := False;
 {$IFDEF MSWINDOWS}
 FInitTicks := 0;
 FLoaderReadyTicks := 0;
 FWindowParent := TWVWindowParent.Create(Self);
 FWindowParent.Parent := Self;
 FWindowParent.Align := alClient;
 FWindowParent.OnDragOver := WindowDragOver;
 FWindowParent.OnDragDrop := WindowDragDrop;
 FBrowser := TWVBrowser.Create(Self);
 { Do not set DefaultURL here.
   WebView4Delphi fires OnAfterCreated and only after it returns navigates to
   DefaultURL. Setting about:blank would therefore overwrite the FormDesign
   navigation started by BrowserAfterCreated. }
 FBrowser.OnAfterCreated := BrowserAfterCreated;
 FBrowser.OnInitializationError := BrowserInitializationError;
 FBrowser.OnWebMessageReceived := BrowserWebMessageReceived;
 FBrowser.OnNavigationCompleted := BrowserNavigationCompleted;
 FWindowParent.Browser := FBrowser;
 FInitTimer := TTimer.Create(Self);
 FInitTimer.Enabled := False;
 FInitTimer.Interval := 200;
 FInitTimer.OnTimer := InitTimer;
 {$ENDIF}
End;
Destructor TRESTDWHTMLWebView.Destroy;
Begin
 {$IFDEF MSWINDOWS}
 If Assigned(FInitTimer) Then
  FInitTimer.Enabled := False;
 If Assigned(FWindowParent) Then
  FWindowParent.Browser := Nil;
 If Assigned(FBrowser) Then
 Begin
  Try
   FBrowser.IsVisible := False;
   FBrowser.ParentWindow := 0;
  Except
  End;
  FBrowser.Free;
  FBrowser := Nil;
 End;
 If Assigned(FWindowParent) Then
 Begin
  FWindowParent.Free;
  FWindowParent := Nil;
 End;
 If GRESTDWHTMLWebViewCount > 0 Then
  Dec(GRESTDWHTMLWebViewCount);
 If GRESTDWHTMLWebViewCount = 0 Then
  DestroyGlobalWebView2Loader;
 {$ENDIF}
 FDebugExpressions.Free;
 FDebugExpressions := Nil;
 Inherited Destroy;
End;
Procedure TRESTDWHTMLWebView.Initialize;
Begin
 {$IFDEF MSWINDOWS}
 If FStarted Then
  Exit;
 FStarted := True;
 FInitTicks := 0;
 FLoaderReadyTicks := 0;
 { Force creation of the native child host window before WebView2. }
 FWindowParent.HandleNeeded;
 If FWindowParent.Handle = 0 Then
 Begin
  FStarted := False;
  If Assigned(FOnError) Then
   FOnError(
    Self,
    'TRESTDWHTMLWebView host window handle could not be created.'
   );
  Exit;
 End;
 If GlobalWebView2Loader = Nil Then
 Begin
  GlobalWebView2Loader := TWVLoader.Create(Nil);
  GlobalWebView2Loader.UseInternalLoader := True;
  GlobalWebView2Loader.ShowMessageDlg := False;
  GlobalWebView2Loader.UserDataFolder :=
   UTF8Decode(
    RESTDWHTMLTempDir +
    'RESTDatawareWebView2_' +
    IntToStr(
     GetCurrentProcessId
    )
   );
  GlobalWebView2Loader.StartWebView2;
 End;
 FInitTimer.Enabled := True;
 {$ELSE}
 FReady := False;
 FStarted := False;
 If Assigned(FOnError) Then
  FOnError(
   Self,
   'TRESTDWHTMLWebView is currently available on Windows/WebView2.'
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.SetAssetsFolder(
 const AValue : String);
Begin
 If FAssetsFolder = AValue Then
  Exit;
 FAssetsFolder := AValue;
 FVirtualHostsReady := False;
 If FReady Then
  PrepareVirtualHosts;
End;
Procedure TRESTDWHTMLWebView.SetHTML(
 const AValue : String);
Begin
 FHTML := AValue;
 If FReady Then
  Refresh;
End;
Function TRESTDWHTMLWebView.PrepareVirtualHosts : Boolean;
Var
 LPreviewOK,
 LAssetsOK : Boolean;
Begin
 Result := False;
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 If Not DirectoryExists(FPreviewFolder) Then
  ForceDirectories(FPreviewFolder);
 LPreviewOK :=
  FBrowser.SetVirtualHostNameToFolderMapping(
   'restdwpreview.local',
   UTF8Decode(
    ExpandFileName(FPreviewFolder)
   ),
   COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND_ALLOW
  );
 LAssetsOK := True;
 If Trim(FAssetsFolder) <> '' Then
 Begin
  If Not DirectoryExists(FAssetsFolder) Then
  Begin
   EmitPageError(
    'Assets',
    'TRESTDWHTMLWebView',
    'Assets folder not found: ' + FAssetsFolder,
    0,
    0
   );
   LAssetsOK := False;
  End
  Else
   LAssetsOK :=
    FBrowser.SetVirtualHostNameToFolderMapping(
     'restdwassets.local',
     UTF8Decode(
      ExpandFileName(FAssetsFolder)
     ),
     COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND_ALLOW
    );
 End;
 FVirtualHostsReady :=
  LPreviewOK And LAssetsOK;
 If Not LPreviewOK Then
  EmitPageError(
   'WebView',
   'TRESTDWHTMLWebView',
   'Could not map internal preview host.',
   0,
   0
  );
 If Not LAssetsOK Then
  EmitPageError(
   'WebView',
   'TRESTDWHTMLWebView',
   'Could not map internal assets host.',
   0,
   0
  );
 Result := FVirtualHostsReady;
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.Refresh;
Var
 LText : TStringList;
 LURL,
 LHTML : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 If Not FVirtualHostsReady Then
  If Not PrepareVirtualHosts Then
   Exit;
 LHTML :=
  InjectPageErrorBridge(
   FHTML
  );
 { ContextRules pages may keep a relative logo URL. Resolve it here at the
   final WebView boundary so every preview path uses the REST Dataware asset host. }
 LHTML := StringReplace(
  LHTML,
  'src="./logo-rdw-oficial.png"',
  'src="https://restdwassets.local/branding/logo-rdw-oficial.png"',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  'src="logo-rdw-oficial.png"',
  'src="https://restdwassets.local/branding/logo-rdw-oficial.png"',
  [rfReplaceAll,rfIgnoreCase]
 );
 LHTML := StringReplace(
  LHTML,
  'src="/logo-rdw-oficial.png"',
  'src="https://restdwassets.local/branding/logo-rdw-oficial.png"',
  [rfReplaceAll,rfIgnoreCase]
 );
 LText := TStringList.Create;
 Try
  LText.Text := LHTML;
  { HTML preview must always be written as UTF-8. TStringList.SaveToFile without
    an encoding uses the active ANSI code page and converts Página/Conteúdo/
    Configuração into mojibake in WebView2. }
  LText.SaveToFile(
   FPreviewFileName,
   TEncoding.UTF8
  );
 Finally
  LText.Free;
 End;
 Inc(FNavigationSerial);
 { Each refresh uses a unique URL so WebView2 reloads the generated document.
   Do not call Stop here: stopping immediately before Navigate can leave the
   embedded controller with its gray host surface and no committed document. }
 LURL :=
  'https://restdwpreview.local/index.html?restdwrefresh=' +
  IntToStr(FNavigationSerial);
 If Not FBrowser.Navigate(
     UTF8Decode(LURL)
    ) Then
  EmitPageError(
   'Navigation',
   'TRESTDWHTMLWebView',
   'WebView2 rejected the generated PageProducer refresh.',
   0,
   0
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.UpdateSelectedElement(
 const AProperty, AValue : String);
Var
 LScript : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 LScript :=
  '(function(){' +
  'var e=window.__restdwSelectedElement;if(!e){return;}' +
  'var p=' + #39 + RESTDWEscapeJavaScriptString(AProperty) + #39 + ';' +
  'var v=' + #39 + RESTDWEscapeJavaScriptString(AValue) + #39 + ';' +
  'if(p==="Text"){e.textContent=v;}' +
  'else if(p==="HTML"){e.outerHTML=v;}' +
  'else if(p==="ID"){e.id=v;}' +
  'else if(p==="Class"){e.className=v;}' +
  'else if(p==="Value"){e.value=v;e.setAttribute("value",v);}' +
  'else if(p==="Enabled"){if(v===""){e.removeAttribute("disabled");}else{e.disabled=(v.toLowerCase()==="false");}}' +
  'else if(p==="Required"){if(v===""){e.removeAttribute("required");}else{e.required=(v.toLowerCase()==="true");}}' +
  'else if(p==="ReadOnly"){if(v===""){e.removeAttribute("readonly");}else{e.readOnly=(v.toLowerCase()==="true");}}' +
  'else if(p==="Multiple"){if(v===""){e.removeAttribute("multiple");}else{e.multiple=(v.toLowerCase()==="true");}}' +
  'else{' +
  ' var n=p.toLowerCase();' +
  ' if(v===""){e.removeAttribute(n);}' +
  ' else{e.setAttribute(n,v);}' +
  '}' +
  'if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  '})();';
 FBrowser.ExecuteScript(
  UTF8Decode(LScript)
 );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.SelectElement(
 const AElementID : String);
Var
 LScript : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Or
    (AElementID = '') Then
  Exit;
 LScript :=
  '(function(){' +
  'var e=document.querySelector("[data-restdw-editor-id=\"' +
  RESTDWEscapeJavaScriptString(AElementID) + '\"]");' +
  'if(e&&window.__restdwSelectElement){window.__restdwSelectElement(e);' +
  'try{e.scrollIntoView({block:"nearest",inline:"nearest"});}catch(x){}}' +
  '})();';
 FBrowser.ExecuteScript(UTF8Decode(LScript));
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.InsertHTML(
 const AHTML : String);
Var
 LScript : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 LScript :=
  '(function(){' +
  'var h=' + #39 + RESTDWEscapeJavaScriptString(AHTML) + #39 + ';' +
  'var e=window.__restdwSelectedElement;' +
  'var n=null;' +
  'if(e){' +
  ' var tag=(e.tagName||"").toLowerCase();' +
  ' var container=(tag==="div"||tag==="section"||tag==="main"||tag==="header"||tag==="footer"||tag==="nav"||tag==="article"||tag==="aside"||tag==="form"||tag==="body");' +
  ' if(container){e.insertAdjacentHTML("beforeend",h);n=e.lastElementChild;}' +
  ' else if(e.parentNode){e.insertAdjacentHTML("afterend",h);n=e.nextElementSibling;}' +
  '}else if(document.body){' +
  ' document.body.insertAdjacentHTML("beforeend",h);' +
  ' n=document.body.lastElementChild;' +
  '}' +
  'if(window.__restdwSelectElement&&n){window.__restdwSelectElement(n);}' +
  'if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  '})();';
 FBrowser.ExecuteScript(
  UTF8Decode(LScript)
 );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.InsertJSClass(
 const AJavaScript,
 AClassName,
 AOptionsJSON,
 AHTMLExtension,
 AIdentity : String);
Var
 LScript,
 LClassScript : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 LClassScript := StringReplace(AJavaScript,'export default ','',[rfReplaceAll]);
 LClassScript := StringReplace(LClassScript,'export ','',[rfReplaceAll]);
 LScript :=
  '(function(){' +
  LClassScript +
  'var o=JSON.parse(' + #39 +
  RESTDWEscapeJavaScriptString(AOptionsJSON) + #39 + ');' +
  'var h=' + AClassName + '.createHTML(o);' +
  'if(h===undefined||h===null){h="";}h=String(h);' +
  'var ext=' + #39 +
  RESTDWEscapeJavaScriptString(AHTMLExtension) + #39 + ';' +
  'var e=window.__restdwSelectedElement;' +
  'if(!e||e===document.documentElement){e=document.body;}' +
  'if(!e){return;}' +
  'var tag=(e.tagName||"").toLowerCase();' +
  'var c=(tag==="div"||tag==="section"||tag==="main"||tag==="header"||' +
  'tag==="footer"||tag==="nav"||tag==="article"||tag==="aside"||' +
  'tag==="form"||tag==="body");' +
  'var m=document.createElement("span");m.style.display="none";' +
  'var z=document.createElement("span");z.style.display="none";' +
  'if(c){e.appendChild(m);m.insertAdjacentElement("afterend",z);}' +
  'else if(e.parentNode){e.insertAdjacentElement("afterend",m);' +
  'm.insertAdjacentElement("afterend",z);}' +
  'else{document.body.appendChild(m);m.insertAdjacentElement("afterend",z);}' +
  'm.insertAdjacentHTML("afterend",h);' +
  'var n=m.nextElementSibling;' +
  'if(ext){z.insertAdjacentHTML("beforebegin",ext);}' +
  'm.remove();z.remove();' +
  'if(n){n.id=' + #39 +
  RESTDWEscapeJavaScriptString(AIdentity) + #39 + ';' +
  'n.setAttribute("name",' + #39 +
  RESTDWEscapeJavaScriptString(AIdentity) + #39 + ');' +
  'for(var k in o){if(Object.prototype.hasOwnProperty.call(o,k)){' +
  'n.setAttribute("data-laz-"+String(k).replace(/_/g,"-").toLowerCase(),' +
  'String(o[k]));}}' +
  'if(typeof ' + AClassName + '.mount==="function"){' +
  AClassName + '.mount(n,o);}' +
  '}' +
  'if(window.__restdwSelectElement&&n){window.__restdwSelectElement(n);}' +
  'if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  '})();';
 FBrowser.ExecuteScript(UTF8Decode(LScript));
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.InsertHTMLAt(
 const AHTML : String;
 X, Y : Integer);
Var
 LScript : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 LScript :=
  '(function(){' +
  'var h=' + #39 + RESTDWEscapeJavaScriptString(AHTML) + #39 + ';' +
  'var x=' + IntToStr(X) + ';' +
  'var y=' + IntToStr(Y) + ';' +
  'var e=document.elementFromPoint(x,y);' +
  'var n=null;' +
  'if(e===document.documentElement){e=document.body;}' +
  'if(e){' +
  ' var tag=(e.tagName||"").toLowerCase();' +
  ' var container=(tag==="div"||tag==="section"||tag==="main"||tag==="header"||tag==="footer"||tag==="nav"||tag==="article"||tag==="aside"||tag==="form"||tag==="body");' +
  ' if(container){' +
  '  e.insertAdjacentHTML("beforeend",h);' +
  '  n=e.lastElementChild;' +
  ' }else if(e.parentNode){' +
  '  e.insertAdjacentHTML("afterend",h);' +
  '  n=e.nextElementSibling;' +
  ' }' +
  '}else if(document.body){' +
  ' document.body.insertAdjacentHTML("beforeend",h);' +
  ' n=document.body.lastElementChild;' +
  '}' +
  'if(window.__restdwSelectElement&&n){window.__restdwSelectElement(n);}' +
  'if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  '})();';
 FBrowser.ExecuteScript(
  UTF8Decode(LScript)
 );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.InsertJSClassAt(
 const AJavaScript,
 AClassName,
 AOptionsJSON,
 AHTMLExtension,
 AIdentity : String;
 X, Y : Integer);
Var
 LScript,
 LClassScript : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 LClassScript := StringReplace(AJavaScript,'export default ','',[rfReplaceAll]);
 LClassScript := StringReplace(LClassScript,'export ','',[rfReplaceAll]);
 LScript :=
  '(function(){' +
  LClassScript +
  'var o=JSON.parse(' + #39 +
  RESTDWEscapeJavaScriptString(AOptionsJSON) + #39 + ');' +
  'var h=' + AClassName + '.createHTML(o);' +
  'if(h===undefined||h===null){h="";}h=String(h);' +
  'var ext=' + #39 +
  RESTDWEscapeJavaScriptString(AHTMLExtension) + #39 + ';' +
  'var x=' + IntToStr(X) + ';var y=' + IntToStr(Y) + ';' +
  'var e=document.elementFromPoint(x,y);' +
  'if(e===document.documentElement){e=document.body;}' +
  'var c=false;if(e){var tag=(e.tagName||"").toLowerCase();' +
  'c=(tag==="div"||tag==="section"||tag==="main"||tag==="header"||' +
  'tag==="footer"||tag==="nav"||tag==="article"||tag==="aside"||' +
  'tag==="form"||tag==="body");}' +
  'if(!e){e=document.body;c=true;}if(!e){return;}' +
  'var m=document.createElement("span");m.style.display="none";' +
  'var z=document.createElement("span");z.style.display="none";' +
  'if(c){e.appendChild(m);m.insertAdjacentElement("afterend",z);}' +
  'else if(e.parentNode){e.insertAdjacentElement("afterend",m);' +
  'm.insertAdjacentElement("afterend",z);}' +
  'else{document.body.appendChild(m);m.insertAdjacentElement("afterend",z);}' +
  'm.insertAdjacentHTML("afterend",h);' +
  'var n=m.nextElementSibling;' +
  'if(ext){z.insertAdjacentHTML("beforebegin",ext);}' +
  'm.remove();z.remove();' +
  'if(n){n.id=' + #39 +
  RESTDWEscapeJavaScriptString(AIdentity) + #39 + ';' +
  'n.setAttribute("name",' + #39 +
  RESTDWEscapeJavaScriptString(AIdentity) + #39 + ');' +
  'for(var k in o){if(Object.prototype.hasOwnProperty.call(o,k)){' +
  'n.setAttribute("data-laz-"+String(k).replace(/_/g,"-").toLowerCase(),' +
  'String(o[k]));}}' +
  'if(typeof ' + AClassName + '.mount==="function"){' +
  AClassName + '.mount(n,o);}' +
  '}' +
  'if(window.__restdwSelectElement&&n){window.__restdwSelectElement(n);}' +
  'if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  '})();';
 FBrowser.ExecuteScript(UTF8Decode(LScript));
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DeleteSelectedElement;
Var
 LScript : String;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Then
  Exit;
 LScript :=
  '(function(){' +
  'var e=window.__restdwSelectedElement;' +
  'if(!e||e===document.body||e===document.documentElement){return;}' +
  'var p=e.parentElement;' +
  'e.remove();' +
  'window.__restdwSelectedElement=null;' +
  'if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  'if(window.__restdwSelectElement&&p&&p!==document.body&&p!==document.documentElement){window.__restdwSelectElement(p);}' +
  '})();';
 FBrowser.ExecuteScript(
  UTF8Decode(LScript)
 );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.RequestHTML;
Begin
 {$IFDEF MSWINDOWS}
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.ExecuteScript(
   UTF8Decode(
    'if(window.__restdwSyncHTML){window.__restdwSyncHTML();}'
   )
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.EnableDebugger;
Begin
 {$IFDEF MSWINDOWS}
 FDebugCallFrameID := '';
 FDebugScriptID := '';
 FDebugSourceLine := 0;
 If FDebugExpressions = Nil Then
  FDebugExpressions := TStringList.Create
 Else
  FDebugExpressions.Clear;
 If FReady And
    Assigned(FBrowser) Then
 Begin
  FBrowser.OnDevToolsProtocolEventReceived :=
   BrowserDevToolsEventReceived;
  FBrowser.OnCallDevToolsProtocolMethodCompleted :=
   BrowserDevToolsMethodCompleted;
  FBrowser.SubscribeToDevToolsProtocolEvent(
   'Debugger.paused',
   1
  );
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.enable',
   '{}',
   0
  );
 End;
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DisableDebugger;
Begin
 {$IFDEF MSWINDOWS}
 FDebugCallFrameID := '';
 FDebugScriptID := '';
 FDebugSourceLine := 0;
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.disable',
   '{}',
   0
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DebugResume;
Begin
 {$IFDEF MSWINDOWS}
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.resume',
   '{}',
   0
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DebugPause;
Begin
 {$IFDEF MSWINDOWS}
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.pause',
   '{}',
   0
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DebugStepInto;
Begin
 {$IFDEF MSWINDOWS}
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.stepInto',
   '{}',
   0
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DebugStepOver;
Begin
 {$IFDEF MSWINDOWS}
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.stepOver',
   '{}',
   0
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DebugStepOut;
Begin
 {$IFDEF MSWINDOWS}
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.stepOut',
   '{}',
   0
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.DebugContinueToLine(
 ALine : Integer);
Var
 LLocation,
 LParams : TJSONObject;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Or
    (Trim(FDebugScriptID) = '') Or
    (ALine < 1) Then
  Exit;
 LLocation := TJSONObject.Create;
 LParams := TJSONObject.Create;
 Try
  LLocation.Add(
   'scriptId',
   FDebugScriptID
  );
  LLocation.Add(
   'lineNumber',
   ALine - 1
  );
  LLocation.Add(
   'columnNumber',
   0
  );
  LParams.Add(
   'location',
   LLocation
  );
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.continueToLocation',
   UTF8Decode(
    LParams.AsJSON
   ),
   0
  );
  LLocation := Nil;
 Finally
  LLocation.Free;
  LParams.Free;
 End;
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.EvaluateDebugExpression(
 ARequestID : Integer;
 const AExpression : String);
Var
 LParams : TJSONObject;
Begin
 {$IFDEF MSWINDOWS}
 If Not FReady Or
    Not Assigned(FBrowser) Or
    (Trim(FDebugCallFrameID) = '') Then
 Begin
  If Assigned(FOnDebugEvaluate) Then
   FOnDebugEvaluate(
    Self,
    ARequestID,
    AExpression,
    '',
    'No paused JavaScript call frame is available.',
    False
   );
  Exit;
 End;
 If FDebugExpressions = Nil Then
  FDebugExpressions := TStringList.Create;
 While FDebugExpressions.Count <= ARequestID Do
  FDebugExpressions.Add('');
 FDebugExpressions[ARequestID] := AExpression;
 LParams := TJSONObject.Create;
 Try
  LParams.Add(
   'callFrameId',
   FDebugCallFrameID
  );
  LParams.Add(
   'expression',
   AExpression
  );
  LParams.Add(
   'returnByValue',
   True
  );
  LParams.Add(
   'generatePreview',
   True
  );
  FBrowser.CallDevToolsProtocolMethod(
   'Debugger.evaluateOnCallFrame',
   UTF8Decode(
    LParams.AsJSON
   ),
   ARequestID
  );
 Finally
  LParams.Free;
 End;
 {$ELSE}
 If Assigned(FOnDebugEvaluate) Then
  FOnDebugEvaluate(
   Self,
   ARequestID,
   AExpression,
   '',
   'Debugger evaluation is available only on WebView2.',
   False
  );
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.ModifyDebugExpression(
 ARequestID : Integer;
 const AExpression, AValueExpression : String);
Begin
 EvaluateDebugExpression(
  ARequestID,
  '(' +
  AExpression +
  ' = (' +
  AValueExpression +
  '))'
 );
End;
Procedure TRESTDWHTMLWebView.OpenDevTools;
Begin
 {$IFDEF MSWINDOWS}
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.OpenDevToolsWindow;
 {$ENDIF}
End;
Procedure TRESTDWHTMLWebView.RebindHost;
{$IFDEF MSWINDOWS}
Begin
 If Not Assigned(FWindowParent) Or
    Not Assigned(FBrowser) Then
  Exit;
 FWindowParent.HandleNeeded;
 If FWindowParent.Handle = 0 Then
  Exit;
 Try
  FBrowser.IsVisible := False;
  FBrowser.ParentWindow := 0;
  FBrowser.ParentWindow := FWindowParent.Handle;
  FWindowParent.UpdateSize;
  FBrowser.NotifyParentWindowPositionChanged;
  FBrowser.IsVisible := True;
  FWindowParent.UpdateSize;
  Refresh;
 Except
  On E : Exception Do
   If Assigned(FOnError) Then
    FOnError(Self,E.Message);
 End;
End;
{$ELSE}
Begin
End;
{$ENDIF}
Procedure TRESTDWHTMLWebView.DetachHost;
{$IFDEF MSWINDOWS}
Begin
 If Not Assigned(FBrowser) Then
  Exit;
 Try
  FBrowser.IsVisible := False;
  FBrowser.ParentWindow := 0;
 Except
 End;
End;
{$ELSE}
Begin
End;
{$ENDIF}
Procedure TRESTDWHTMLWebView.Resize;
Begin
 Inherited Resize;
 {$IFDEF MSWINDOWS}
 If Assigned(FWindowParent) Then
  FWindowParent.UpdateSize;
 {$ENDIF}
End;
{$IFDEF MSWINDOWS}
Procedure TRESTDWHTMLWebView.InitTimer(Sender : TObject);
Begin
 Inc(FInitTicks);
 If FInitTicks > 100 Then
 Begin
  FInitTimer.Enabled := False;
  FStarted := False;
  If Assigned(FOnError) Then
   FOnError(
    Self,
    'TRESTDWHTMLWebView initialization timeout. WebView2 Runtime could not be initialized.'
   );
  Exit;
 End;
 If GlobalWebView2Loader.InitializationError Then
 Begin
  FInitTimer.Enabled := False;
  FStarted := False;
  If Assigned(FOnError) Then
   FOnError(
    Self,
    UTF8Encode(
     GlobalWebView2Loader.ErrorMessage
    )
   );
  Exit;
 End;
 If GlobalWebView2Loader.Initialized Then
 Begin
  { Cold-start stabilization.
    On the first IDE use, WebView2Loader can report Initialized immediately
    before its environment is fully settled for controller creation. Subsequent
    openings work because that environment is already warm.
    Wait only a few timer ticks after Initialized becomes true. Do not depend on
    panel size or form geometry, and do not alter the normal warm-start path. }
  Inc(FLoaderReadyTicks);
  If FLoaderReadyTicks < 3 Then
   Exit;
  { Keep Candidate 103 retry behavior. If CreateBrowser returns False, leave
    the timer enabled and retry on the next tick. }
  If FBrowser.Initialized Then
  Begin
   FInitTimer.Enabled := False;
   Exit;
  End;
  If FBrowser.CreateBrowser(
      FWindowParent.Handle
     ) Then
   FInitTimer.Enabled := False;
 End
 Else
  FLoaderReadyTicks := 0;
End;
Procedure TRESTDWHTMLWebView.WindowDragOver(
 Sender, Source : TObject;
 X, Y : Integer;
 State : TDragState;
 Var Accept : Boolean);
Begin
 If Assigned(FOnDesignDragOver) Then
  FOnDesignDragOver(
   Self,
   Source,
   X,
   Y,
   State,
   Accept
  );
End;
Procedure TRESTDWHTMLWebView.WindowDragDrop(
 Sender, Source : TObject;
 X, Y : Integer);
Begin
 If Assigned(FOnDesignDragDrop) Then
  FOnDesignDragDrop(
   Self,
   Source,
   X,
   Y
  );
End;
Procedure TRESTDWHTMLWebView.EmitPageError(
 const AKind, ASource, AMessage : String;
 ALine, AColumn : Integer);
Begin
 If Assigned(FOnPageError) Then
  FOnPageError(
   Self,
   AKind,
   ASource,
   AMessage,
   ALine,
   AColumn
  );
End;
Function TRESTDWHTMLWebView.InjectPageErrorBridge(
 const AHTML : String) : String;
Const
 LBridge =
  '<script>' +
  '(function(){' +
  ' if(window.__restdwDesignerBridgeInstalled){return;}' +
  ' window.__restdwDesignerBridgeInstalled=true;' +
  ' function clean(v){' +
  '  if(v===undefined||v===null){return "";}' +
  '  return String(v).replace(/\t/g," ").replace(/[\r\n]+/g," ");' +
  ' }' +
  ' function send(k,m,s,l,c){' +
  '  try{' +
  '   window.chrome.webview.postMessage(' +
  '    "RESTDWERR\t"+clean(k)+"\t"+clean(l||0)+"\t"+clean(c||0)+"\t"+clean(s)+"\t"+clean(m)' +
  '   );' +
  '  }catch(e){}' +
  ' }' +
  ' if(window.fetch){' +
  '  var of=window.fetch;' +
  '  window.fetch=function(){' +
  '   var a=arguments;' +
  '   var q=(a.length>0)?a[0]:"";' +
  '   var u=(q&&q.url)?q.url:String(q||"");' +
  '   if(location.hostname==="restdwpreview.local"&&(/\/api(?:\/|$)/i).test(u)){' +
  '    return Promise.resolve(new Response("",{status:200,statusText:"Design Preview"}));' +
  '   }' +
  '   return of.apply(this,a).then(function(r){' +
  '    if(!r.ok){send("HTTP","HTTP "+r.status+" "+r.statusText,r.url,0,0);}' +
  '    return r;' +
  '   }).catch(function(e){' +
  '    if(!(e&&e.__restdwReported)){' +
  '     send("Fetch",e&&e.message?e.message:e,u||location.href,0,0);' +
  '     try{if(e){e.__restdwReported=true;}}catch(x){}' +
  '    }' +
  '    throw e;' +
  '   });' +
  '  };' +
  ' }' +
  ' var XO=XMLHttpRequest.prototype.open;' +
  ' var XS=XMLHttpRequest.prototype.send;' +
  ' XMLHttpRequest.prototype.open=function(m,u){this.__restdwurl=u;return XO.apply(this,arguments);};' +
  ' XMLHttpRequest.prototype.send=function(){' +
  '  this.addEventListener("loadend",function(){' +
  '   if(this.status>=400){send("XHR","HTTP "+this.status,this.responseURL||this.__restdwurl,0,0);}' +
  '  });' +
  '  this.addEventListener("error",function(){send("XHR","Network request failed",this.responseURL||this.__restdwurl,0,0);});' +
  '  return XS.apply(this,arguments);' +
  ' };' +
  ' var seq=0;' +
  ' function eid(e){if(!e.dataset.restdwEditorId){e.dataset.restdwEditorId="restdw"+(++seq);}return e.dataset.restdwEditorId;}' +
  ' function msg(v){return clean(v);}' +
  ' window.__restdwSyncHTML=function(){try{' +
  '  var b=document.body.cloneNode(true);' +
  '  var g=b.querySelectorAll("[data-restdataware-generated]");' +
  '  for(var gi=0;gi<g.length;gi++){g[gi].remove();}' +
  '  var a=b.querySelectorAll("[data-restdw-editor-id],[data-restdw-old-resize],[data-restdw-old-overflow]");' +
  '  for(var i=0;i<a.length;i++){var x=a[i];x.removeAttribute("data-restdw-editor-id");' +
  'x.removeAttribute("contenteditable");x.style.outline="";x.style.outlineOffset="";if(x.hasAttribute("data-restdw-old-resize")){' +
  'x.style.resize=x.getAttribute("data-restdw-old-resize")||"";}if(x.hasAttribute("data-restdw-old-overflow")){' +
  'x.style.overflow=x.getAttribute("data-restdw-old-overflow")||"";}x.removeAttribute("data-restdw-old-resize");' +
  'x.removeAttribute("data-restdw-old-overflow");' +
  'if(x.getAttribute("style")===""){x.removeAttribute("style");}}' +
  '  window.chrome.webview.postMessage("RESTDWHTML\t"+b.innerHTML);' +
  ' }catch(e){}};' +
  ' function select(e){' +
  '  if(!e||e===document.documentElement||e===document.body){return;}' +
  '  if(window.__restdwSelectedElement){var o=window.__restdwSelectedElement;o.style.outline=window.__restdwOldOutline||"";' +
  'o.style.outlineOffset="";if(o.hasAttribute("data-restdw-old-resize")){o.style.resize=o.getAttribute("data-restdw-old-resize")||"";' +
  'o.removeAttribute("data-restdw-old-resize");}if(o.hasAttribute("data-restdw-old-overflow")){' +
  'o.style.overflow=o.getAttribute("data-restdw-old-overflow")||"";o.removeAttribute("data-restdw-old-overflow");}}' +
  '  window.__restdwSelectedElement=e;window.__restdwOldOutline=e.style.outline;' +
  '  e.style.outline="2px dashed #4f46e5";e.style.outlineOffset="2px";if(!e.hasAttribute("data-restdw-old-resize")){' +
  'e.setAttribute("data-restdw-old-resize",e.style.resize||"");e.setAttribute("data-restdw-old-overflow",e.style.overflow||"");}' +
  'e.style.resize="both";if(!e.style.overflow||e.style.overflow==="visible"){e.style.overflow="auto";}' +
  '  try{window.chrome.webview.postMessage("RESTDWSEL\t"+eid(e)+"\t"+msg(e.tagName.toLowerCase())+"\t"+msg(e.innerText||e.value||"")+"\t"+msg(e.id||"")+"\t"+msg(e.className||"")+"\t"+msg(e.outerHTML||""));}catch(x){}' +
  '  try{if(window.__restdwResizeObserver){window.__restdwResizeObserver.disconnect();window.__restdwResizeObserver.observe(e);}}catch(x){}' +
  ' }' +
  ' window.__restdwSelectElement=select;' +
  ' window.__restdwSendObjectTree=function(){try{' +
  '  var a=[];function skip(e){var t=(e.tagName||"").toLowerCase();return t==="script"||t==="style"||t==="link"||t==="meta"||t==="title"||t==="base"||t==="noscript"||t==="template";}' +
  '  function walk(p,d){for(var i=0;i<p.children.length;i++){var e=p.children[i];if(skip(e)){continue;}a.push({d:d,e:eid(e),t:(e.tagName||"").toLowerCase(),i:e.id||"",c:(typeof e.className==="string"?e.className:"")});walk(e,d+1);}}' +
  '  if(document.body){walk(document.body,0);}' +
  '  window.chrome.webview.postMessage("RESTDWOBJ\t"+JSON.stringify(a));' +
  ' }catch(x){}};' +
  ' window.__restdwSendObjectTree();' +
  ' if(document.readyState==="loading"){document.addEventListener("DOMContentLoaded",function(){window.__restdwSendObjectTree();},{once:true});}' +
  ' window.addEventListener("load",function(){window.__restdwSendObjectTree();setTimeout(window.__restdwSendObjectTree,120);},{once:true});' +
  ' setTimeout(window.__restdwSendObjectTree,350);' +
  ' if(window.MutationObserver&&document.body){' +
  'window.__restdwTreeMutationObserver=new MutationObserver(function(ms){' +
  'var refresh=false;for(var mi=0;mi<ms.length;mi++){' +
  'if(ms[mi].type==="childList"&&(ms[mi].addedNodes.length>0||' +
  'ms[mi].removedNodes.length>0)){refresh=true;break;}}' +
  'if(refresh){clearTimeout(window.__restdwTreeTimer);' +
  'window.__restdwTreeTimer=setTimeout(window.__restdwSendObjectTree,60);}});' +
  'window.__restdwTreeMutationObserver.observe(document.body,' +
  '{childList:true,subtree:true});}' +
  ' if(window.ResizeObserver){window.__restdwResizeObserver=new ResizeObserver(function(es){for(var i=0;i<es.length;i++){' +
  'if(es[i].target===window.__restdwSelectedElement){clearTimeout(window.__restdwResizeTimer);' +
  'window.__restdwResizeTimer=setTimeout(function(){window.__restdwSyncHTML();},80);break;}}});}' +
  ' window.__restdwMoveState=null;' +
  ' document.addEventListener("mousedown",function(ev){' +
  '  if(ev.button!==0){return;}' +
  '  var e=window.__restdwSelectedElement;' +
  '  if(!e||e===document.body||e===document.documentElement){return;}' +
  '  if(!(ev.target===e||(e.contains&&e.contains(ev.target)))){return;}' +
  '  if(e.isContentEditable||(ev.target&&ev.target.isContentEditable)){return;}' +
  '  var r=e.getBoundingClientRect();' +
  '  var nearRight=(r.right-ev.clientX)<=16;' +
  '  var nearBottom=(r.bottom-ev.clientY)<=16;' +
  '  if(nearRight&&nearBottom){return;}' +
  '  var cs=window.getComputedStyle(e);' +
  '  var pos=cs.position||"static";' +
  '  if(pos==="static"){e.style.position="relative";pos="relative";}' +
  '  var left=parseFloat(e.style.left);if(isNaN(left)){left=0;}' +
  '  var top=parseFloat(e.style.top);if(isNaN(top)){top=0;}' +
  '  window.__restdwMoveState={el:e,x:ev.clientX,y:ev.clientY,left:left,top:top,moved:false};' +
  '  try{document.body.style.userSelect="none";}catch(x){}' +
  '  ev.preventDefault();ev.stopImmediatePropagation();ev.stopPropagation();' +
  ' },true);' +
  ' document.addEventListener("mousemove",function(ev){' +
  '  var s=window.__restdwMoveState;if(!s||!s.el){return;}' +
  '  var dx=ev.clientX-s.x;var dy=ev.clientY-s.y;' +
  '  if(Math.abs(dx)<1&&Math.abs(dy)<1){return;}' +
  '  s.moved=true;' +
  '  s.el.style.left=Math.round(s.left+dx)+"px";' +
  '  s.el.style.top=Math.round(s.top+dy)+"px";' +
  '  ev.preventDefault();ev.stopImmediatePropagation();ev.stopPropagation();' +
  ' },true);' +
  ' document.addEventListener("mouseup",function(ev){' +
  '  var s=window.__restdwMoveState;if(!s){return;}' +
  '  window.__restdwMoveState=null;' +
  '  try{document.body.style.userSelect="";}catch(x){}' +
  '  if(s.moved){' +
  '   if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  '   ' +
  '   ev.preventDefault();ev.stopImmediatePropagation();ev.stopPropagation();' +
  '  }' +
  ' },true);' +
  ' try{' +
  '  document.querySelectorAll("a[href]").forEach(function(a){a.dataset.dsHref=a.getAttribute("href")||"";});' +
  ' }catch(e){}' +
  ' document.addEventListener("click",function(ev){' +
  '  var e=ev.target;if(!e){return;}' +
  '  ev.preventDefault();ev.stopImmediatePropagation();ev.stopPropagation();' +
  '  select(e);return false;' +
  ' },true);' +
  ' document.addEventListener("auxclick",function(ev){ev.preventDefault();ev.stopImmediatePropagation();return false;},true);' +
  ' document.addEventListener("contextmenu",function(ev){ev.preventDefault();ev.stopImmediatePropagation();return false;},true);' +
  ' document.addEventListener("submit",function(ev){ev.preventDefault();ev.stopImmediatePropagation();return false;},true);' +
  ' document.addEventListener("mousedown",function(ev){' +
  '  if(ev.button!==0){ev.preventDefault();ev.stopImmediatePropagation();}' +
  ' },true);' +
  ' document.addEventListener("click",function(ev){' +
  '  var a=ev.target&&ev.target.closest?ev.target.closest("a,button,input,select,textarea,label,form"):null;' +
  '  if(a){ev.preventDefault();}' +
  ' },false);' +
  ' document.addEventListener("keydown",function(ev){' +
  '  if(ev.key!=="Delete"){return;}' +
  '  var a=document.activeElement;' +
  '  if(a&&a.isContentEditable){return;}' +
  '  var e=window.__restdwSelectedElement;' +
  '  if(!e||e===document.body||e===document.documentElement){return;}' +
  '  ev.preventDefault();ev.stopImmediatePropagation();ev.stopPropagation();' +
  '  var p=e.parentElement;' +
  '  e.remove();window.__restdwSelectedElement=null;' +
  '  if(window.__restdwSyncHTML){window.__restdwSyncHTML();}' +
  '  if(window.__restdwSelectElement&&p&&p!==document.body){window.__restdwSelectElement(p);}' +
  '  return false;' +
  ' },true);' +
  ' document.addEventListener("dblclick",function(ev){' +
  '  var e=ev.target;if(!e){return;}ev.preventDefault();ev.stopPropagation();select(e);' +
  '  var t=e.tagName.toLowerCase();' +
  '  if(["input","select","textarea","img","canvas","script","style"].indexOf(t)<0){' +
  '   e.contentEditable="true";e.focus();' +
  '   var done=function(){e.removeEventListener("blur",done);e.removeAttribute("contenteditable");window.__restdwSyncHTML();};' +
  '   e.addEventListener("blur",done);' +
  '  }' +
  ' },true);' +
  '})();' +
  '</script>';
Var
 P : Integer;
Begin
 Result := AHTML;
 P := Pos(
  '<head>',
  LowerCase(Result)
 );
 If P > 0 Then
  Insert(
   LBridge,
   Result,
   P + Length('<head>')
  )
 Else
 Begin
  P := Pos(
   '<body',
   LowerCase(Result)
  );
  If P > 0 Then
   Insert(
    LBridge,
    Result,
    P
   )
  Else
   Result := LBridge + Result;
 End;
End;
Procedure TRESTDWHTMLWebView.InstallPageErrorBridge;
Const
 LBridgeScript =
  '(function(){' +
  ' if(window.__restdwErrorBridgeInstalled){return;}' +
  ' window.__restdwErrorBridgeInstalled=true;' +
  ' function clean(v){' +
  '  if(v===undefined||v===null){return "";}' +
  '  return String(v).replace(/\t/g," ").replace(/[\r\n]+/g," ");' +
  ' }' +
  ' function send(k,m,s,l,c){' +
  '  try{' +
  '   window.chrome.webview.postMessage(' +
  '    "RESTDWERR\t"+clean(k)+"\t"+clean(l||0)+"\t"+clean(c||0)+"\t"+clean(s)+"\t"+clean(m)' +
  '   );' +
  '  }catch(e){}' +
  ' }' +
  ' window.addEventListener("error",function(e){' +
  '  if(e.target&&e.target!==window){' +
  '   var u=e.target.src||e.target.href||e.target.currentSrc||e.target.tagName||"resource";' +
  '   send("Resource","Failed to load resource: "+u,u,0,0);' +
  '  }else{' +
  '   send("Error",e.message||"JavaScript error",e.filename||location.href,e.lineno||0,e.colno||0);' +
  '  }' +
  ' },true);' +
  ' window.addEventListener("unhandledrejection",function(e){' +
  '  var r=e.reason;' +
  '  if(r&&r.__restdwReported){return;}' +
  '  var m=(r&&r.message)?r.message:r;' +
  '  send("Promise",m||"Unhandled promise rejection",location.href,0,0);' +
  ' });' +
  ' var ce=console.error;' +
  ' console.error=function(){' +
  '  send("Console Error",Array.prototype.join.call(arguments," "),location.href,0,0);' +
  '  return ce.apply(console,arguments);' +
  ' };' +
  ' var cw=console.warn;' +
  ' console.warn=function(){' +
  '  send("Console Warning",Array.prototype.join.call(arguments," "),location.href,0,0);' +
  '  return cw.apply(console,arguments);' +
  ' };' +
  '})();';
Begin
 If FReady And
    Assigned(FBrowser) Then
  FBrowser.AddScriptToExecuteOnDocumentCreated(
   UTF8Decode(LBridgeScript)
  );
End;
Procedure TRESTDWHTMLWebView.BrowserWebMessageReceived(
 Sender : TObject;
 const AWebView : ICoreWebView2;
 const AArgs : ICoreWebView2WebMessageReceivedEventArgs);
Const
 CHTMLPrefix  = 'RESTDWHTML';
 CObjectPrefix = 'RESTDWOBJ';
 CSELPRefix   = 'RESTDWSEL';
 CBreakPrefix = 'RESTDWBREAK';
 CErrorPrefix = 'RESTDWERR';
Var
 LArgs : TCoreWebView2WebMessageReceivedEventArgs;
 LMessage,
 LKind,
 LLineText,
 LColumnText,
 LSource,
 LText : String;
 P1,
 P2,
 P3,
 P4,
 P5 : Integer;
 Function HasProtocol(
  const AProtocol : String) : Boolean;
 Begin
  Result :=
   Copy(
    LMessage,
    1,
    Length(AProtocol) + 1
   ) =
   AProtocol + #9;
 End;
 Function PayloadStart(
  const AProtocol : String) : Integer;
 Begin
  Result :=
   Length(AProtocol) + 2;
 End;
 Function NextPart(
  const AValue : String;
  AStart : Integer;
  Out ANext : Integer) : String;
 Var
  P : Integer;
 Begin
  P := PosEx(
   #9,
   AValue,
   AStart
  );
  If P = 0 Then
  Begin
   Result :=
    Copy(
     AValue,
     AStart,
     MaxInt
    );
   ANext :=
    Length(AValue) + 1;
  End
  Else
  Begin
   Result :=
    Copy(
     AValue,
     AStart,
     P - AStart
    );
   ANext :=
    P + 1;
  End;
 End;
Begin
 LArgs :=
  TCoreWebView2WebMessageReceivedEventArgs.Create(
   AArgs
  );
 Try
  { WebView2 already returns Unicode. Keep the message Unicode end-to-end. }
  LMessage :=
   LArgs.WebMessageAsString;
 Finally
  LArgs.Free;
 End;
 { Full HTML synchronized by the design bridge. }
 If HasProtocol(CHTMLPrefix) Then
 Begin
  If Assigned(FOnHTMLChanged) Then
   FOnHTMLChanged(
    Self,
    Copy(
     LMessage,
     PayloadStart(CHTMLPrefix),
     MaxInt
    )
   );
  Exit;
 End;
 If HasProtocol(CObjectPrefix) Then
 Begin
  If Assigned(FOnObjectTree) Then
   FOnObjectTree(
    Self,
    Copy(
     LMessage,
     PayloadStart(CObjectPrefix),
     MaxInt
    )
   );
  Exit;
 End;
 { Visual element selection:
   RESTDWSEL <tab> editor-id <tab> tag <tab> text <tab> id <tab> class <tab> outerHTML
   The old DataSnap parser used fixed offsets for "DSSEL". After the RESTDW
   protocol rename those offsets no longer matched the prefix, so the Delphi
   Object Inspector never received the selected element. }
 If HasProtocol(CSELPRefix) Then
 Begin
  P1 :=
   PayloadStart(CSELPRefix);
  LKind :=
   NextPart(
    LMessage,
    P1,
    P2
   );
  LLineText :=
   NextPart(
    LMessage,
    P2,
    P3
   );
  LColumnText :=
   NextPart(
    LMessage,
    P3,
    P4
   );
  LSource :=
   NextPart(
    LMessage,
    P4,
    P5
   );
  LText :=
   NextPart(
    LMessage,
    P5,
    P1
   );
  If Assigned(FOnElementSelected) Then
   FOnElementSelected(
    Self,
    LKind,
    LLineText,
    LColumnText,
    LSource,
    LText,
    Copy(
     LMessage,
     P1,
     MaxInt
    )
   );
  Exit;
 End;
 { Debug breakpoint notification. }
 If HasProtocol(CBreakPrefix) Then
 Begin
  FDebugSourceLine :=
   StrToIntDef(
    Copy(
     LMessage,
     PayloadStart(CBreakPrefix),
     MaxInt
    ),
    0
   );
  Exit;
 End;
 { Page/console/runtime error notification. }
 If Not HasProtocol(CErrorPrefix) Then
  Exit;
 P1 :=
  PayloadStart(CErrorPrefix);
 LKind :=
  NextPart(
   LMessage,
   P1,
   P2
  );
 LLineText :=
  NextPart(
   LMessage,
   P2,
   P3
  );
 LColumnText :=
  NextPart(
   LMessage,
   P3,
   P4
  );
 LSource :=
  NextPart(
   LMessage,
   P4,
   P5
  );
 LText :=
  Copy(
   LMessage,
   P5,
   MaxInt
  );
 EmitPageError(
  LKind,
  LSource,
  LText,
  StrToIntDef(
   LLineText,
   0
  ),
  StrToIntDef(
   LColumnText,
   0
  )
 );
End;
Procedure TRESTDWHTMLWebView.BrowserDevToolsEventReceived(
 Sender : TObject;
 const AWebView : ICoreWebView2;
 const AArgs : ICoreWebView2DevToolsProtocolEventReceivedEventArgs;
 const AEventName : wvstring;
 AEventID : Integer);
Var
 LArgs : TCoreWebView2DevToolsProtocolEventReceivedEventArgs;
 LData : TJSONData;
 LObject,
 LFrame,
 LLocation : TJSONObject;
 LFrames : TJSONArray;
Begin
 If UTF8Encode(AEventName) <> 'Debugger.paused' Then
  Exit;
 LArgs :=
  TCoreWebView2DevToolsProtocolEventReceivedEventArgs.Create(
   AArgs
  );
 LData := Nil;
 Try
  LData :=
   GetJSON(
    UTF8Encode(
     LArgs.ParameterObjectAsJson
    )
   );
  If (LData = Nil) Or
     (LData.JSONType <> jtObject) Then
   Exit;
  LObject :=
   TJSONObject(
    LData
   );
  LFrames :=
   LObject.Arrays[
    'callFrames'
   ];
  If (LFrames = Nil) Or
     (LFrames.Count = 0) Then
   Exit;
  LFrame :=
   LFrames.Objects[
    0
   ];
  If LFrame = Nil Then
   Exit;
  FDebugCallFrameID :=
   LFrame.Get(
    'callFrameId',
    ''
   );
  LLocation :=
   LFrame.Objects[
    'location'
   ];
  If LLocation <> Nil Then
   FDebugScriptID :=
    LLocation.Get(
     'scriptId',
     ''
    );
  If (FDebugSourceLine <= 0) And
     (LLocation <> Nil) Then
   FDebugSourceLine :=
    LLocation.Get(
     'lineNumber',
     0
    ) + 1;
  If Assigned(FOnDebugBreakpoint) Then
   FOnDebugBreakpoint(
    Self,
    FDebugSourceLine
   );
 Finally
  LData.Free;
  LArgs.Free;
 End;
End;
Procedure TRESTDWHTMLWebView.BrowserDevToolsMethodCompleted(
 Sender : TObject;
 AErrorCode : HRESULT;
 const AResult : wvstring;
 AExecutionID : Integer);
Var
 LData,
 LValueData : TJSONData;
 LObject,
 LResultObject,
 LException : TJSONObject;
 LExpression,
 LValue,
 LError : String;
 LSuccess : Boolean;
Begin
 If AExecutionID <= 0 Then
  Exit;
 LExpression := '';
 If (FDebugExpressions <> Nil) And
    (AExecutionID < FDebugExpressions.Count) Then
  LExpression :=
   FDebugExpressions[
    AExecutionID
   ];
 LValue := '';
 LError := '';
 LSuccess := False;
 LData := Nil;
 If AErrorCode <> 0 Then
  LError :=
   'WebView debugger error ' +
   IntToStr(AErrorCode)
 Else
 Begin
  Try
   LData :=
    GetJSON(
     UTF8Encode(
      AResult
     )
    );
   If (LData <> Nil) And
      (LData.JSONType = jtObject) Then
   Begin
    LObject :=
     TJSONObject(
      LData
     );
    LException :=
     LObject.Objects[
      'exceptionDetails'
     ];
    If LException <> Nil Then
     LError :=
      LException.Get(
       'text',
       'JavaScript evaluation error'
      )
    Else
    Begin
     LResultObject :=
      LObject.Objects[
       'result'
      ];
     If LResultObject <> Nil Then
     Begin
      LValueData :=
       LResultObject.Find(
        'value'
       );
      If LValueData <> Nil Then
      Begin
       If LValueData.JSONType = jtString Then
        LValue :=
         LValueData.AsString
       Else
        LValue :=
         LValueData.AsJSON;
      End
      Else
       LValue :=
        LResultObject.Get(
         'description',
         LResultObject.Get(
          'type',
          ''
         )
        );
      LSuccess := True;
     End;
    End;
   End;
  Except
   On E : Exception Do
    LError := E.Message;
  End;
 End;
 LData.Free;
 If Assigned(FOnDebugEvaluate) Then
  FOnDebugEvaluate(
   Self,
   AExecutionID,
   LExpression,
   LValue,
   LError,
   LSuccess
  );
End;
Procedure TRESTDWHTMLWebView.BrowserNavigationCompleted(
 Sender : TObject;
 const AWebView : ICoreWebView2;
 const AArgs : ICoreWebView2NavigationCompletedEventArgs);
Var
 LArgs : TCoreWebView2NavigationCompletedEventArgs;
Begin
 LArgs := TCoreWebView2NavigationCompletedEventArgs.Create(
  AArgs
 );
 Try
  If Not LArgs.IsSuccess Then
  Begin
   { ConnectionAborted can be generated when WebView2 replaces an in-flight
     navigation. It is not a page source error and must not pollute Error List. }
   If Ord(LArgs.WebErrorStatus) <> 9 Then
    EmitPageError(
     'Navigation',
     'TRESTDWHTMLWebView',
     'Page navigation failed. WebErrorStatus=' +
      IntToStr(Ord(LArgs.WebErrorStatus)) +
      ', HTTP=' +
      IntToStr(LArgs.HttpStatusCode),
     0,
     0
    );
  End
  Else If Assigned(FBrowser) Then
   FBrowser.ExecuteScript(
    UTF8Decode(
     '(function(){' +
     'function send(){if(window.__restdwSendObjectTree){window.__restdwSendObjectTree();}}' +
     'send();setTimeout(send,80);setTimeout(send,250);setTimeout(send,600);' +
     '})();'
    )
   );
 Finally
  LArgs.Free;
 End;
End;
Procedure TRESTDWHTMLWebView.BrowserAfterCreated(Sender : TObject);
Begin
 FReady := True;
 FBrowser.WebMessageEnabled := True;
 FVirtualHostsReady := False;
 { First controller creation already received FWindowParent.Handle in
   CreateBrowser. Do not detach/rebind it here: the form has only just become
   visible and changing ParentWindow at this stage can leave WebView2 gray. }
 FWindowParent.UpdateSize;
 InstallPageErrorBridge;
 PrepareVirtualHosts;
 { The designer performs the single initial navigation in WebViewReady. }
 If Assigned(FOnReady) Then
  FOnReady(Self);
End;
Procedure TRESTDWHTMLWebView.BrowserInitializationError(
 Sender : TObject;
 AErrorCode : HRESULT;
 const AErrorMessage : wvstring);
Begin
 FReady := False;
 If Assigned(FOnError) Then
  FOnError(
   Self,
   UTF8Encode(AErrorMessage)
  );
End;
{$ENDIF}
End.
