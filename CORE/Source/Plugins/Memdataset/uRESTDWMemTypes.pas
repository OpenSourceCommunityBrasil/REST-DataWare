unit uRESTDWMemTypes;

{$I ..\..\Includes\uRESTDW.inc}

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

Interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

uses
  SysUtils, Classes,
  uRESTDWMemResources;
const
  MaxPixelCount = 32767;
{$IFNDEF COMPILER12_UP}
{$HPPEMIT '#ifndef TDate'}
{$HPPEMIT '#define TDate Controls::TDate'}
{$HPPEMIT '#define TTime Controls::TTime'}
{$HPPEMIT '#endif'}
{$ENDIF !COMPILER12_UP}
type
  TRESTDWBytes = Pointer;
  IntPtr = Pointer;
type
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
  TInputKeys = set of TInputKey;
  TRESTDWRGBTriple = packed record
    rgbBlue: Byte;
    rgbGreen: Byte;
    rgbRed: Byte;
  end;
const
  NullHandle = 0;
  // (rom) deleted fbs constants. They are already in JvConsts.pas.
type
  TTimerProc = procedure(hwnd: THandle; Msg: Cardinal; idEvent: Cardinal; dwTime: Cardinal);
type
  // Base class for persistent properties that can show events.
  // By default, Delphi and BCB don't show the events of a class
  // derived from TPersistent unless it also derives from
  // TComponent.
  // The design time editor associated with TRESTDWPersistent will display
  // the events, thus mimicking a Sub Component.
  TRESTDWPersistent = class(TComponent)
  private
    FOwner: TPersistent;
    function _GetOwner: TPersistent;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent); reintroduce; virtual;
    function GetNamePath: string; {$IFNDEF FPC}override;{$ENDIF}
    property Owner: TPersistent read _GetOwner;
  end;
  // Added by dejoy (2005-04-20)
  // A lot of TRESTDWxxx control persistent properties used TPersistent,
  // So and a TRESTDWPersistentProperty to do this job. make to support batch-update mode
  // and property change notify.
  TRESTDWPropertyChangeEvent = procedure(Sender: TObject; const PropName: string) of object;
  TRESTDWPersistentProperty = class(TRESTDWPersistent)//TPersistent => TRESTDWPersistent
  private
    FUpdateCount: Integer;
    FOnChanging: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FOnChangingProperty: TRESTDWPropertyChangeEvent;
    FOnChangedProperty: TRESTDWPropertyChangeEvent;
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;
    procedure ChangedProperty(const PropName: string); virtual;
    procedure ChangingProperty(const PropName: string); virtual;
    property UpdateCount: Integer read FUpdateCount;
  public
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnChangedProperty: TRESTDWPropertyChangeEvent read FOnChangedProperty write FOnChangedProperty;
    property OnChangingProperty: TRESTDWPropertyChangeEvent read FOnChangingProperty write FOnChangingProperty;
  end;
  TRESTDWRegKey = (hkClassesRoot, hkCurrentUser, hkLocalMachine, hkUsers,
    hkPerformanceData, hkCurrentConfig, hkDynData);
  TRESTDWRegKeys = set of TRESTDWRegKey;
  // base JVCL Exception class to derive from
  EJVCLException = class(Exception);
  TRESTDWLinkClickEvent = procedure(Sender: TObject; Link: string) of object;
  //  TOnRegistryChangeKey = procedure(Sender: TObject; RootKey: HKEY; Path: string) of object;
  //  TAngle = 0..360;
  TRESTDWOutputMode = (omFile, omStream);
  //  TLabelDirection = (sdLeftToRight, sdRightToLeft); // JvScrollingLabel
  TRESTDWDoneFileEvent = procedure(Sender: TObject; FileName: string; FileSize: Integer; Url: string) of object;
  TRESTDWDoneStreamEvent = procedure(Sender: TObject; Stream: TStream; StreamSize: Integer; Url: string) of object;
  TRESTDWHTTPProgressEvent = procedure(Sender: TObject; UserData, Position: Integer; TotalSize: Integer; Url: string; var Continue: Boolean) of object;
  TRESTDWFTPProgressEvent = procedure(Sender: TObject; Position: Integer; Url: string) of object;
  TRESTDWErrorEvent = procedure(Sender: TObject; ErrorMsg: string) of object;
  TRESTDWWaveLocation = (frFile, frResource, frRAM);
  TRESTDWPopupPosition = (ppNone, ppForm, ppApplication);
  TRESTDWProgressEvent = procedure(Sender: TObject; Current, Total: Integer) of object;
  TRESTDWNextPageEvent = procedure(Sender: TObject; PageNumber: Integer) of object;
  TRESTDWBitmapStyle = (bsNormal, bsCentered, bsStretched);
  TRESTDWGradientStyle = (grFilled, grEllipse, grHorizontal, grVertical, grPyramid, grMount);
  TRESTDWParentEvent = procedure(Sender: TObject; ParentWindow: THandle) of object;
  TRESTDWDiskRes = (dsSuccess, dsCancel, dsSkipfile, dsError);
  TRESTDWDiskStyle = (idfCheckFirst, idfNoBeep, idfNoBrowse, idfNoCompressed, idfNoDetails,
    idfNoForeground, idfNoSkip, idfOemDisk, idfWarnIfSkip);
  TRESTDWDiskStyles = set of TRESTDWDiskStyle;
  TRESTDWDeleteStyle = (idNoBeep, idNoForeground);
  TRESTDWDeleteStyles = set of TRESTDWDeleteStyle;
  TRESTDWNotifyParamsEvent = procedure(Sender: TObject; Params: Pointer) of object;
  TRESTDWAnimation = (anLeftRight, anRightLeft, anRightAndLeft, anLeftVumeter, anRightVumeter);
  TRESTDWAnimations = set of TRESTDWAnimation;
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
  TRESTDWFourCC = array [0..3] of DWChar;
  PJvAniTag = ^TRESTDWAniTag;
  TRESTDWAniTag = packed record
    ckID: TRESTDWFourCC;
    ckSize: Longint;
  end;
  TRESTDWAniHeader = packed record
    dwSizeof: Longint;
    dwFrames: Longint;
    dwSteps: Longint;
    dwCX: Longint;
    dwCY: Longint;
    dwBitCount: Longint;
    dwPlanes: Longint;
    dwJIFRate: Longint;
    dwFlags: Longint;
  end;
  TRESTDWLayout = (lTop, lCenter, lBottom);
  TRESTDWBevelStyle = (bsShape, bsLowered, bsRaised);
  // JvJCLUtils
  TTickCount = Cardinal;
  {**** string handling routines}
  TSetOfChar = TSysCharSet;
  TCharSet = TSysCharSet;
  TDateOrder = (doMDY, doDMY, doYMD);
  TDayOfWeekName = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);
  TDaysOfWeek = set of TDayOfWeekName;
const
  DefaultDateOrder = doDMY;
  CenturyOffset: Byte = 60;
  NullDate: TDateTime = 0; {-693594}
type
  // JvDriveCtrls / JvLookOut
  TRESTDWImageSize = (isSmall, isLarge);
  TRESTDWImageAlign = (iaLeft, iaCentered);
  TRESTDWDriveType = (dtUnknown, dtRemovable, dtFixed, dtRemote, dtCDROM, dtRamDisk);
  TRESTDWDriveTypes = set of TRESTDWDriveType;
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
  TRESTDWTrackFontOptions = set of TRESTDWTrackFontOption;
const
  DefaultTrackFontOptions = [hoFollowFont, hoPreserveColor, hoPreserveStyle];
  DefaultHotTrackColor = $00D2BDB6;
  DefaultHotTrackFrameColor = $006A240A;
type
  // from JvListView.pas
  TRESTDWSortMethod = (smAutomatic, smAlphabetic, smNonCaseSensitive, smNumeric, smDate, smTime, smDateTime, smCurrency);
  TRESTDWListViewColumnSortEvent = procedure(Sender: TObject; Column: Integer; var AMethod: TRESTDWSortMethod) of object;
  TRESTDWClickColorType =
    (cctColors, cctNoneColor, cctDefaultColor, cctCustomColor, cctAddInControl, cctNone);
  TRESTDWColorQuadLayOut = (cqlNone, cqlLeft, cqlRight, cqlClient);
  // from JvColorProvider.pas
  TColorType = (ctStandard, ctSystem, ctCustom);
const
  ColCount = 20;
  StandardColCount = 40;
  SysColCount = 30;
  {$IFDEF COMPILER6}
   {$IF not declared(clHotLight)}
    {$MESSAGE ERROR 'You do not have Delphi 6 Runtime Library Update 2 installed. Please install it before installing the JVCL. http://downloads.codegear.com/default.aspx?productid=300'}
   {$IFEND}
  {$ENDIF COMPILER6}
type
  TRESTDWCustomThread = class(TThread)
  private
    FThreadName: String;
    function GetThreadName: String; virtual;
    procedure SetThreadName(const Value: String); virtual;
  public
    {$IFNDEF DELPHI2009UP}
    procedure NameThreadForDebugging(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
    {$ENDIF}
    procedure NameThread(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF); {$IFDEF SUPPORTS_UNICODE_STRING} overload; {$ENDIF} virtual;
    property ThreadName: String read GetThreadName write SetThreadName;
  end;
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
var
  JvCustomThreadNamingProc: procedure (AThreadName: DWString; AThreadID: LongWord);
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
{ TRESTDWPersistent }
constructor TRESTDWPersistent.Create(AOwner: TPersistent);
begin
  if AOwner is TComponent then
    inherited Create(AOwner as TComponent)
  else
    inherited Create(nil);
  SetSubComponent(True);
  FOwner := AOwner;
end;
type
  TPersistentAccessProtected = class(TPersistent);
function TRESTDWPersistent.GetNamePath: string;
var
  S: string;
  lOwner: TPersistent;
begin
  Result := inherited GetNamePath;
  lOwner := GetOwner;   //Resturn Nested NamePath
  if (lOwner <> nil)
    and ( (csSubComponent in TComponent(lOwner).ComponentStyle)
         or (TPersistentAccessProtected(lOwner).GetOwner <> nil)
        )
   then
  begin
    S := lOwner.GetNamePath;
    if S <> '' then
      Result := S + '.' + Result;
  end;
end;
function TRESTDWPersistent.GetOwner: TPersistent;
begin
  Result := FOwner;
end;
function TRESTDWPersistent._GetOwner: TPersistent;
begin
  Result := GetOwner;
end;
{ TRESTDWPersistentProperty }
procedure TRESTDWPersistentProperty.BeginUpdate;
begin
  Inc(FUpdateCount);
end;
procedure TRESTDWPersistentProperty.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanged) then
    FOnChanged(Self);
end;
procedure TRESTDWPersistentProperty.ChangedProperty(const PropName: string);
begin
  if Assigned(FOnChangedProperty) then
    FOnChangedProperty(Self, PropName);
end;
procedure TRESTDWPersistentProperty.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;
procedure TRESTDWPersistentProperty.ChangingProperty(const PropName: string);
begin
  if Assigned(FOnChangingProperty) then
    FOnChangingProperty(Self, PropName);
end;
procedure TRESTDWPersistentProperty.EndUpdate;
begin
  Dec(FUpdateCount);
end;
{$IFNDEF DELPHI2009UP}
procedure TRESTDWCustomThread.NameThreadForDebugging(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
type
  TThreadNameInfo = record
    FType: LongWord;     // must be 0x1000
    FName: PAnsiChar;    // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord;    // reserved for future use, must be zero
  end;
var
  ThreadNameInfo: TThreadNameInfo;
begin
  //if IsDebuggerPresent then
  begin
    ThreadNameInfo.FType := $1000;
    ThreadNameInfo.FName := PAnsiChar(AThreadName);
    ThreadNameInfo.FThreadID := AThreadID;
    ThreadNameInfo.FFlags := 0;
    //try
    //  RaiseException($406D1388, 0, SizeOf(ThreadNameInfo) div SizeOf(LongWord), @ThreadNameInfo);
    //except
    //end;
  end;
end;
{$ENDIF DELPHI2009UP}
function TRESTDWCustomThread.GetThreadName: String;
begin
  if FThreadName = '' then
    Result := ClassName
  else
    Result := FThreadName+' {'+ClassName+'}';
end;
procedure TRESTDWCustomThread.NameThread(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
begin
  if AThreadID = $FFFFFFFF then
    AThreadID := ThreadID;
  NameThreadForDebugging(aThreadName, AThreadID);
  if Assigned(JvCustomThreadNamingProc) then
    JvCustomThreadNamingProc(aThreadName, AThreadID);
end;

procedure TRESTDWCustomThread.SetThreadName(const Value: String);
begin
  FThreadName := Value;
end;

end.

