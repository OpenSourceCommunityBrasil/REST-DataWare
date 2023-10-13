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

interface

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
  TJvBytes = Pointer;
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
  TJvRGBTriple = packed record
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
  // The design time editor associated with TJvPersistent will display
  // the events, thus mimicking a Sub Component.
  TJvPersistent = class(TComponent)
  private
    FOwner: TPersistent;
    function _GetOwner: TPersistent;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent); reintroduce; virtual;
    function GetNamePath: string; override;
    property Owner: TPersistent read _GetOwner;
  end;
  // Added by dejoy (2005-04-20)
  // A lot of TJVxxx control persistent properties used TPersistent,
  // So and a TJvPersistentProperty to do this job. make to support batch-update mode
  // and property change notify.
  TJvPropertyChangeEvent = procedure(Sender: TObject; const PropName: string) of object;
  TJvPersistentProperty = class(TJvPersistent)//TPersistent => TJvPersistent
  private
    FUpdateCount: Integer;
    FOnChanging: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FOnChangingProperty: TJvPropertyChangeEvent;
    FOnChangedProperty: TJvPropertyChangeEvent;
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
    property OnChangedProperty: TJvPropertyChangeEvent read FOnChangedProperty write FOnChangedProperty;
    property OnChangingProperty: TJvPropertyChangeEvent read FOnChangingProperty write FOnChangingProperty;
  end;
  TJvRegKey = (hkClassesRoot, hkCurrentUser, hkLocalMachine, hkUsers,
    hkPerformanceData, hkCurrentConfig, hkDynData);
  TJvRegKeys = set of TJvRegKey;
  // base JVCL Exception class to derive from
  EJVCLException = class(Exception);
  TJvLinkClickEvent = procedure(Sender: TObject; Link: string) of object;
  //  TOnRegistryChangeKey = procedure(Sender: TObject; RootKey: HKEY; Path: string) of object;
  //  TAngle = 0..360;
  TJvOutputMode = (omFile, omStream);
  //  TLabelDirection = (sdLeftToRight, sdRightToLeft); // JvScrollingLabel
  TJvDoneFileEvent = procedure(Sender: TObject; FileName: string; FileSize: Integer; Url: string) of object;
  TJvDoneStreamEvent = procedure(Sender: TObject; Stream: TStream; StreamSize: Integer; Url: string) of object;
  TJvHTTPProgressEvent = procedure(Sender: TObject; UserData, Position: Integer; TotalSize: Integer; Url: string; var Continue: Boolean) of object;
  TJvFTPProgressEvent = procedure(Sender: TObject; Position: Integer; Url: string) of object;
  TJvErrorEvent = procedure(Sender: TObject; ErrorMsg: string) of object;
  TJvWaveLocation = (frFile, frResource, frRAM);
  TJvPopupPosition = (ppNone, ppForm, ppApplication);
  TJvProgressEvent = procedure(Sender: TObject; Current, Total: Integer) of object;
  TJvNextPageEvent = procedure(Sender: TObject; PageNumber: Integer) of object;
  TJvBitmapStyle = (bsNormal, bsCentered, bsStretched);
  TJvGradientStyle = (grFilled, grEllipse, grHorizontal, grVertical, grPyramid, grMount);
  TJvParentEvent = procedure(Sender: TObject; ParentWindow: THandle) of object;
  TJvDiskRes = (dsSuccess, dsCancel, dsSkipfile, dsError);
  TJvDiskStyle = (idfCheckFirst, idfNoBeep, idfNoBrowse, idfNoCompressed, idfNoDetails,
    idfNoForeground, idfNoSkip, idfOemDisk, idfWarnIfSkip);
  TJvDiskStyles = set of TJvDiskStyle;
  TJvDeleteStyle = (idNoBeep, idNoForeground);
  TJvDeleteStyles = set of TJvDeleteStyle;
  TJvNotifyParamsEvent = procedure(Sender: TObject; Params: Pointer) of object;
  TJvAnimation = (anLeftRight, anRightLeft, anRightAndLeft, anLeftVumeter, anRightVumeter);
  TJvAnimations = set of TJvAnimation;
  //   TOnFound = procedure(Sender: TObject; Path: string) of object; // JvSearchFile
  //  TOnChangedDir = procedure(Sender: TObject; Directory: string) of object; // JvSearchFile
  //  TOnAlarm = procedure(Sender: TObject; Keyword: string) of object; // JvAlarm
  {  TAlarm = record
      Keyword: string;
      DateTime: TDateTime;
    end;
  } // JvAlarm
  // Bianconi - Moved from JvAlarms.pas
  TJvTriggerKind =
    (tkOneShot, tkEachSecond, tkEachMinute, tkEachHour, tkEachDay, tkEachMonth, tkEachYear);
  // End of Bianconi
  TJvFourCC = array [0..3] of DWChar;
  PJvAniTag = ^TJvAniTag;
  TJvAniTag = packed record
    ckID: TJvFourCC;
    ckSize: Longint;
  end;
  TJvAniHeader = packed record
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
  TJvLayout = (lTop, lCenter, lBottom);
  TJvBevelStyle = (bsShape, bsLowered, bsRaised);
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
  TJvImageSize = (isSmall, isLarge);
  TJvImageAlign = (iaLeft, iaCentered);
  TJvDriveType = (dtUnknown, dtRemovable, dtFixed, dtRemote, dtCDROM, dtRamDisk);
  TJvDriveTypes = set of TJvDriveType;
  // Defines how a property (like a HotTrackFont) follows changes in the component's normal Font
  TJvTrackFontOption = (
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
  TJvTrackFontOptions = set of TJvTrackFontOption;
const
  DefaultTrackFontOptions = [hoFollowFont, hoPreserveColor, hoPreserveStyle];
  DefaultHotTrackColor = $00D2BDB6;
  DefaultHotTrackFrameColor = $006A240A;
type
  // from JvListView.pas
  TJvSortMethod = (smAutomatic, smAlphabetic, smNonCaseSensitive, smNumeric, smDate, smTime, smDateTime, smCurrency);
  TJvListViewColumnSortEvent = procedure(Sender: TObject; Column: Integer; var AMethod: TJvSortMethod) of object;
  TJvClickColorType =
    (cctColors, cctNoneColor, cctDefaultColor, cctCustomColor, cctAddInControl, cctNone);
  TJvColorQuadLayOut = (cqlNone, cqlLeft, cqlRight, cqlClient);
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
  TJvCustomThread = class(TThread)
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
{ TJvPersistent }
constructor TJvPersistent.Create(AOwner: TPersistent);
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
function TJvPersistent.GetNamePath: string;
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
function TJvPersistent.GetOwner: TPersistent;
begin
  Result := FOwner;
end;
function TJvPersistent._GetOwner: TPersistent;
begin
  Result := GetOwner;
end;
{ TJvPersistentProperty }
procedure TJvPersistentProperty.BeginUpdate;
begin
  Inc(FUpdateCount);
end;
procedure TJvPersistentProperty.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanged) then
    FOnChanged(Self);
end;
procedure TJvPersistentProperty.ChangedProperty(const PropName: string);
begin
  if Assigned(FOnChangedProperty) then
    FOnChangedProperty(Self, PropName);
end;
procedure TJvPersistentProperty.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;
procedure TJvPersistentProperty.ChangingProperty(const PropName: string);
begin
  if Assigned(FOnChangingProperty) then
    FOnChangingProperty(Self, PropName);
end;
procedure TJvPersistentProperty.EndUpdate;
begin
  Dec(FUpdateCount);
end;
{$IFNDEF DELPHI2009UP}
procedure TJvCustomThread.NameThreadForDebugging(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
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
function TJvCustomThread.GetThreadName: String;
begin
  if FThreadName = '' then
    Result := ClassName
  else
    Result := FThreadName+' {'+ClassName+'}';
end;
procedure TJvCustomThread.NameThread(AThreadName: DWString; AThreadID: LongWord = $FFFFFFFF);
begin
  if AThreadID = $FFFFFFFF then
    AThreadID := ThreadID;
  NameThreadForDebugging(aThreadName, AThreadID);
  if Assigned(JvCustomThreadNamingProc) then
    JvCustomThreadNamingProc(aThreadName, AThreadID);
end;

procedure TJvCustomThread.SetThreadName(const Value: String);
begin
  FThreadName := Value;
end;

end.

