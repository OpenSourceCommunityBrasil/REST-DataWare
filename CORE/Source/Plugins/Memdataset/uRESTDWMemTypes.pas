Unit uRESTDWMemTypes;

{$I uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

Uses
  SysUtils, Classes,
  uRESTDWMemResources;
Const
  MaxPixelCount = 32767;
{$IFNDEF COMPILER12_UP}
{$HPPEMIT '#ifndef TDate'}
{$HPPEMIT '#define TDate Controls::TDate'}
{$HPPEMIT '#define TTime Controls::TTime'}
{$HPPEMIT '#endif'}
{$ENDIF !COMPILER12_UP}
Type
  TRESTDWBytes = Pointer;
  IntPtr = Pointer;
Type
  {$IFNDEF FPC}
   {$IF (CompilerVersion >= 26) And (CompilerVersion <= 29)}
    {$IF Defined(HAS_FMX)}
     DWString     = String;
     DWWideString = WideString;
     DWChar       = Char;
    {$ELSE}
     DWString     = Utf8String;
     DWWideString = WideString;
     DWChar       = Utf8Char;
    {$IFEND}
   {$ELSE}
    {$IF Defined(HAS_FMX)}
     DWString     = Utf8String;
     DWWideString = Utf8String;
     DWChar       = Utf8Char;
    {$ELSE}
     DWString     = AnsiString;
     DWWideString = WideString;
     DWChar       = Char;
    {$IFEND}
   {$IFEND}
  {$ELSE}
   DWString     = AnsiString;
   DWWideString = WideString;
   DWChar       = Char;
  {$ENDIF}
  {$IFNDEF COMPILER9_UP}
  TVerticalAlignment = (taAlignTop, taAlignBottom, taVerticalCenter);
  TTopBottom = taAlignTop..taAlignBottom;
  {$ENDIF ~COMPILER9_UP}
  PCaptionChar = PChar;
  THintString = string;
  THintStringList = TStringList;
  { JvExVCL classes }
  TInputKey = (ikAll, ikArrows, ikChars, ikButton, ikTabs, ikEdit, ikNative{, ikNav, ikEsc});
  TInputKeys = set Of TInputKey;
  TRESTDWRGBTriple = packed Record
    rgbBlue: Byte;
    rgbGreen: Byte;
    rgbRed: Byte;
  End;
Const
  NullHandle = 0;
  // (rom) deleted fbs constants. They are already in JvConsts.pas.
Type
  TTimerProc = Procedure(hwnd: THandle; Msg: Cardinal; idEvent: Cardinal; dwTime: Cardinal);
Type
  // Base class for persistent properties that can show events.
  // By default, Delphi and BCB don't show the events of a class
  // derived from TPersistent unless it also derives from
  // TComponent.
  // The design time editor associated with TRESTDWPersistent will display
  // the events, thus mimicking a Sub Component.
  TRESTDWPersistent = Class(TComponent)
  Private
    FOwner: TPersistent;
    Function _GetOwner: TPersistent;
  Protected
    Function GetOwner: TPersistent; override;
  Public
    Constructor Create(AOwner: TPersistent); reintroduce; virtual;
    Function GetNamePath: string; {$IFNDEF FPC}override;{$ENDIF}
    property Owner: TPersistent read _GetOwner;
  End;
  // Added by dejoy (2005-04-20)
  // A lot of TRESTDWxxx control persistent properties used TPersistent,
  // So and a TRESTDWPersistentProperty to do this job. make to support batch-update mode
  // and property change notify.
  TRESTDWPropertyChangeEvent = Procedure(Sender: TObject; Const PropName: string) Of object;
  TRESTDWPersistentProperty = Class(TRESTDWPersistent)//TPersistent => TRESTDWPersistent
  Private
    FUpdateCount: Integer;
    FOnChanging: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FOnChangingProperty: TRESTDWPropertyChangeEvent;
    FOnChangedProperty: TRESTDWPropertyChangeEvent;
  Protected
    Procedure Changed; virtual;
    Procedure Changing; virtual;
    Procedure ChangedProperty(Const PropName: string); virtual;
    Procedure ChangingProperty(Const PropName: string); virtual;
    property UpdateCount: Integer read FUpdateCount;
  Public
    Procedure BeginUpdate; virtual;
    Procedure EndUpdate; virtual;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnChangedProperty: TRESTDWPropertyChangeEvent read FOnChangedProperty write FOnChangedProperty;
    property OnChangingProperty: TRESTDWPropertyChangeEvent read FOnChangingProperty write FOnChangingProperty;
  End;
  TRESTDWRegKey = (hkClassesRoot, hkCurrentUser, hkLocalMachine, hkUsers,
    hkPerformanceData, hkCurrentConfig, hkDynData);
  TRESTDWRegKeys = set Of TRESTDWRegKey;
  // base JVCL Exception class to derive from
  EJVCLException = Class(Exception);
  TRESTDWLinkClickEvent = Procedure(Sender: TObject; Link: string) Of object;
  //  TOnRegistryChangeKey = procedure(Sender: TObject; RootKey: HKEY; Path: string) of object;
  //  TAngle = 0..360;
  TRESTDWOutputMode = (omFile, omStream);
  //  TLabelDirection = (sdLeftToRight, sdRightToLeft); // JvScrollingLabel
  TRESTDWDoneFileEvent = Procedure(Sender: TObject; FileName: string; FileSize: Integer; Url: string) Of object;
  TRESTDWDoneStreamEvent = Procedure(Sender: TObject; Stream: TStream; StreamSize: Integer; Url: string) Of object;
  TRESTDWHTTPProgressEvent = Procedure(Sender: TObject; UserData, Position: Integer; TotalSize: Integer; Url: string; Var Continue: Boolean) Of object;
  TRESTDWFTPProgressEvent = Procedure(Sender: TObject; Position: Integer; Url: string) Of object;
  TRESTDWErrorEvent = Procedure(Sender: TObject; ErrorMsg: string) Of object;
  TRESTDWWaveLocation = (frFile, frResource, frRAM);
  TRESTDWPopupPosition = (ppNone, ppForm, ppApplication);
  TRESTDWProgressEvent = Procedure(Sender: TObject; Current, Total: Integer) Of object;
  TRESTDWNextPageEvent = Procedure(Sender: TObject; PageNumber: Integer) Of object;
  TRESTDWBitmapStyle = (bsNormal, bsCentered, bsStretched);
  TRESTDWGradientStyle = (grFilled, grEllipse, grHorizontal, grVertical, grPyramid, grMount);
  TRESTDWParentEvent = Procedure(Sender: TObject; ParentWindow: THandle) Of object;
  TRESTDWDiskRes = (dsSuccess, dsCancel, dsSkipfile, dsError);
  TRESTDWDiskStyle = (idfCheckFirst, idfNoBeep, idfNoBrowse, idfNoCompressed, idfNoDetails,
    idfNoForeground, idfNoSkip, idfOemDisk, idfWarnIfSkip);
  TRESTDWDiskStyles = set Of TRESTDWDiskStyle;
  TRESTDWDeleteStyle = (idNoBeep, idNoForeground);
  TRESTDWDeleteStyles = set Of TRESTDWDeleteStyle;
  TRESTDWNotifyParamsEvent = Procedure(Sender: TObject; Params: Pointer) Of object;
  TRESTDWAnimation = (anLeftRight, anRightLeft, anRightAndLeft, anLeftVumeter, anRightVumeter);
  TRESTDWAnimations = set Of TRESTDWAnimation;
  //   TOnFound = procedure(Sender: TObject; Path: string) of object; // JvSearchFile
  //  TOnChangedDir = procedure(Sender: TObject; Directory: string) of object; // JvSearchFile
  //  TOnAlarm = procedure(Sender: TObject; Keyword: string) of object; // JvAlarm
  {  TAlarm = record
      Keyword: string;
      DateTime: TDateTime;
    end;
  } // JvAlarm
  // Bianconi - Moved from JvAlarms.pas
  TRESTDWTriggerKind =
    (tkOneShot, tkEachSecond, tkEachMinute, tkEachHour, tkEachDay, tkEachMonth, tkEachYear);
  // End of Bianconi
  TRESTDWFourCC = array [0..3] Of DWChar;
  PJvAniTag = ^TRESTDWAniTag;
  TRESTDWAniTag = packed Record
    ckID: TRESTDWFourCC;
    ckSize: Longint;
  End;
  TRESTDWAniHeader = packed Record
    dwSizeof: Longint;
    dwFrames: Longint;
    dwSteps: Longint;
    dwCX: Longint;
    dwCY: Longint;
    dwBitCount: Longint;
    dwPlanes: Longint;
    dwJIFRate: Longint;
    dwFlags: Longint;
  End;
  TRESTDWLayout = (lTop, lCenter, lBottom);
  TRESTDWBevelStyle = (bsShape, bsLowered, bsRaised);
  // JvJCLUtils
  TTickCount = Cardinal;
  {**** string handling routines}
  TSetOfChar = TSysCharSet;
  TCharSet = TSysCharSet;
  TDateOrder = (doMDY, doDMY, doYMD);
  TDayOfWeekName = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);
  TDaysOfWeek = set Of TDayOfWeekName;
Const
  DefaultDateOrder = doDMY;
  CenturyOffset: Byte = 60;
  NullDate: TDateTime = 0; {-693594}
Type
  // JvDriveCtrls / JvLookOut
  TRESTDWImageSize = (isSmall, isLarge);
  TRESTDWImageAlign = (iaLeft, iaCentered);
  TRESTDWDriveType = (dtUnknown, dtRemovable, dtFixed, dtRemote, dtCDROM, dtRamDisk);
  TRESTDWDriveTypes = set Of TRESTDWDriveType;
  // Defines how a property (like a HotTrackFont) follows changes in the component's normal Font
  TRESTDWTrackFontOption = (
    hoFollowFont,  // makes HotTrackFont follow changes to the normal Font
    hoPreserveCharSet,  // don't change HotTrackFont.Charset
    hoPreserveColor,    // don't change HotTrackFont.Color
    hoPreserveHeight,   // don't change HotTrackFont.Height (affects Size as well)
    hoPreserveName,     // don't change HotTrackFont.Name
    hoPreservePitch,    // don't change HotTrackFont.Pitch
    hoPreserveStyle     // don't change HotTrackFont.Style
    {$IFDEF COMPILER10_UP}
    , hoPreserveOrientation // don't change HotTrackFont.Orientation
    {$ENDIF COMPILER10_UP}
    {$IFDEF COMPILER15_UP}
    , hoPreserveQuality // don't change HotTrackFont.Quality
    {$ENDIF COMPILER15_UP}
  );
  TRESTDWTrackFontOptions = set Of TRESTDWTrackFontOption;
Const
  DefaultTrackFontOptions = [hoFollowFont, hoPreserveColor, hoPreserveStyle];
  DefaultHotTrackColor = $00D2BDB6;
  DefaultHotTrackFrameColor = $006A240A;
Type
  // from JvListView.pas
  TRESTDWSortMethod = (smAutomatic, smAlphabetic, smNonCaseSensitive, smNumeric, smDate, smTime, smDateTime, smCurrency);
  TRESTDWListViewColumnSortEvent = Procedure(Sender: TObject; Column: Integer; Var AMethod: TRESTDWSortMethod) Of object;
  TRESTDWClickColorType =
    (cctColors, cctNoneColor, cctDefaultColor, cctCustomColor, cctAddInControl, cctNone);
  TRESTDWColorQuadLayOut = (cqlNone, cqlLeft, cqlRight, cqlClient);
  // from JvColorProvider.pas
  TColorType = (ctStandard, ctSystem, ctCustom);
Const
  ColCount = 20;
  StandardColCount = 40;
  SysColCount = 30;
  {$IFDEF COMPILER6}
   {$IF not declared(clHotLight)}
    {$MESSAGE ERROR 'You do not have Delphi 6 Runtime Library Update 2 installed. Please install it before installing the JVCL. http://downloads.codegear.com/default.aspx?productid=300'}
   {$IFEND}
  {$ENDIF COMPILER6}
Type
  TRESTDWCustomThread = Class(TThread)
  Private
    FThreadName: String;
    Function GetThreadName: String; virtual;
    Procedure SetThreadName(Const Value: String); virtual;
  Public
    {$IFNDEF DELPHI2009UP}
    Procedure NameThreadForDebugging(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
    {$ENDIF}
    Procedure NameThread(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF); {$IFDEF SUPPORTS_UNICODE_STRING} overload; {$ENDIF} virtual;
    property ThreadName: String read GetThreadName write SetThreadName;
  End;
// Using this variable you can enhance the NameThread procedure system wide by inserting a procedure
// which executes for example a MadExcept TraceOut to enhance the MadExcept call stack results.
// The procedure for MadExcept could look like:
//
//      procedure NameThreadMadExcept(AThreadName: DWString; AThreadID: LongWord);
//      begin
//        MadExcept.NameThread(AThreadID, AThreadName);
//      end;
//
// And the initialization of the unit should look like:
//
//     initialization
//       JvTypes.JvCustomThreadNamingProc := NameThreadMadExcept;
//
Var
  JvCustomThreadNamingProc: Procedure (AThreadName: DWString; AThreadID: LongWord);
{$IFDEF UNITVERSIONING}
Const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JVCL\run'
  );
{$ENDIF UNITVERSIONING}
Implementation
{ TRESTDWPersistent }
Constructor TRESTDWPersistent.Create(AOwner: TPersistent);
Begin
  If AOwner is TComponent Then
    Inherited Create(AOwner as TComponent)
  Else
    Inherited Create(nil);
  SetSubComponent(True);
  FOwner := AOwner;
End;
Type
  TPersistentAccessProtected = Class(TPersistent);
Function TRESTDWPersistent.GetNamePath: string;
Var
  S: string;
  lOwner: TPersistent;
Begin
  Result := Inherited GetNamePath;
  lOwner := GetOwner;   //Resturn Nested NamePath
  If (lOwner <> nil)
    and ( (csSubComponent in TComponent(lOwner).ComponentStyle)
         or (TPersistentAccessProtected(lOwner).GetOwner <> nil)
        )
   Then
  Begin
    S := lOwner.GetNamePath;
    If S <> '' Then
      Result := S + '.' + Result;
  End;
End;
Function TRESTDWPersistent.GetOwner: TPersistent;
Begin
  Result := FOwner;
End;
Function TRESTDWPersistent._GetOwner: TPersistent;
Begin
  Result := GetOwner;
End;
{ TRESTDWPersistentProperty }
Procedure TRESTDWPersistentProperty.BeginUpdate;
Begin
  Inc(FUpdateCount);
End;
Procedure TRESTDWPersistentProperty.Changed;
Begin
  If (FUpdateCount = 0) and Assigned(FOnChanged) Then
    FOnChanged(Self);
End;
Procedure TRESTDWPersistentProperty.ChangedProperty(Const PropName: string);
Begin
  If Assigned(FOnChangedProperty) Then
    FOnChangedProperty(Self, PropName);
End;
Procedure TRESTDWPersistentProperty.Changing;
Begin
  If (FUpdateCount = 0) and Assigned(FOnChanging) Then
    FOnChanging(Self);
End;
Procedure TRESTDWPersistentProperty.ChangingProperty(Const PropName: string);
Begin
  If Assigned(FOnChangingProperty) Then
    FOnChangingProperty(Self, PropName);
End;
Procedure TRESTDWPersistentProperty.EndUpdate;
Begin
  Dec(FUpdateCount);
End;
{$IFNDEF DELPHI2009UP}
Procedure TRESTDWCustomThread.NameThreadForDebugging(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
Type
  TThreadNameInfo = Record
    FType: LongWord;     // must be 0x1000
    FName: PAnsiChar;    // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord;    // reserved for future use, must be zero
  End;
Var
  ThreadNameInfo: TThreadNameInfo;
Begin
  //if IsDebuggerPresent then
  Begin
    ThreadNameInfo.FType := $1000;
    ThreadNameInfo.FName := PAnsiChar(AThreadName);
    ThreadNameInfo.FThreadID := AThreadID;
    ThreadNameInfo.FFlags := 0;
    //try
    //  RaiseException($406D1388, 0, SizeOf(ThreadNameInfo) div SizeOf(LongWord), @ThreadNameInfo);
    //except
    //end;
  End;
End;
{$ENDIF DELPHI2009UP}
Function TRESTDWCustomThread.GetThreadName: String;
Begin
  If FThreadName = '' Then
    Result := ClassName
  Else
    Result := FThreadName+' {'+ClassName+'}';
End;
Procedure TRESTDWCustomThread.NameThread(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
Begin
  If AThreadID = $FFFFFFFF Then
    AThreadID := ThreadID;
  NameThreadForDebugging(aThreadName, AThreadID);
  If Assigned(JvCustomThreadNamingProc) Then
    JvCustomThreadNamingProc(aThreadName, AThreadID);
End;

Procedure TRESTDWCustomThread.SetThreadName(Const Value: String);
Begin
  FThreadName := Value;
End;

End.
