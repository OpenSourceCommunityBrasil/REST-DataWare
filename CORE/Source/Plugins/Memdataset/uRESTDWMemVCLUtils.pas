unit uRESTDWMemVCLUtils;
{$I ..\..\Source\Includes\uRESTDWPlataform.inc}
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
  Variants,
  {$IFDEF MSWINDOWS}
  Windows, Messages, ShellAPI, Registry,
  {$ENDIF MSWINDOWS}
  Types,
  {$IFDEF HAS_UNIT_SYSTEM_UITYPES}
  System.UITypes,
  {$ENDIF}
  SysUtils,
  MultiMon,
  Classes, // must be after "Forms"
  uRESTDWMemBase,
  uRESTDWMemJCLUtils, uRESTDWMemAppStorage, uRESTDWMemTypes;

// hides / shows the a forms caption area
procedure HideFormCaption(FormHandle: THandle; Hide: Boolean);
{$IFDEF MSWINDOWS}
type
  TJvWallpaperStyle = (wpTile, wpCenter, wpStretch);
// set the background wallpaper (two versions)
procedure SetWallpaper(const Path: string); overload;
procedure SetWallpaper(const Path: string; Style: TJvWallpaperStyle); overload;
{$ENDIF MSWINDOWS}
procedure RGBToHSV(R, G, B: Integer; var H, S, V: Integer);
{ from JvVCLUtils }

procedure LaunchCpl(const FileName: string);
// for Win 2000 and XP
procedure ShowSafeRemovalDialog;
{
  GetControlPanelApplets retrieves information about all control panel applets in a specified folder.
  APath is the Path to the folder to search and AMask is the filename mask (containing wildcards if necessary) to use.
  The information is returned in the Strings and Images lists according to the following rules:
   The Display Name and Path to the CPL file is returned in Strings with the following format:
     '<displayname>=<Path>'
   You can access the DisplayName by using the Strings.Names array and the Path by accessing the Strings.Values array
   Strings.Objects can contain either of two values depending on if Images is nil or not:
     * If Images is nil then Strings.Objects contains the image for the applet as a TBitmap. Note that the caller (you)
     is responsible for freeing the bitmaps in this case
     * If Images <> nil, then the Strings.Objects array contains the index of the image in the Images array for the selected item.
       To access and use the ImageIndex, typecast Strings.Objects to an int:
         Tmp.Name := Strings.Name[I];
         Tmp.ImageIndex := Integer(Strings.Objects[I]);
  The function returns True if any Control Panel Applets were found (i.e Strings.Count is > 0 when returning)
}
function PointInPolyRgn(const P: TPoint; const Points: array of TPoint): Boolean;
procedure PaintInverseRect(const RectOrg, RectEnd: TPoint);
procedure DrawInvertFrame(ScreenRect: TRect; Width: Integer);
procedure ShowMDIClientEdge(ClientHandle: THandle; ShowEdge: Boolean);
{ Gradient filling routine }
type
  TFillDirection = (fdTopToBottom, fdBottomToTop, fdLeftToRight, fdRightToLeft);

{ Grid drawing }
type
  TVertAlignment = (vaTopJustify, vaCenterJustify, vaBottomJustify);

function MsgBox(Handle: THandle; const Caption, Text: string; Flags: Integer): Integer; overload;
(***** Utility MessageBox based dialogs *)
// returns True if user clicked Yes
function MsgYesNo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// returns True if user clicked Retry
function MsgRetryCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// returns IDABORT, IDRETRY or IDIGNORE
function MsgAbortRetryIgnore(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
// returns IDYES, IDNO or IDCANCEL
function MsgYesNoCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
// returns True if user clicked OK
function MsgOKCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// dialog without icon
procedure MsgOK(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with info icon
procedure MsgInfo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with warning icon
procedure MsgWarn(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with question icon
procedure MsgQuestion(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with error icon
procedure MsgError(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with custom icon (must be available in the app resource)
procedure MsgAbout(Handle: Integer; const Msg, Caption: string; const IcoName: string = 'MAINICON'; Flags: DWORD = MB_OK);
{**** Windows routines }

//=== { Support functions for DPI Aware apps } ================================
const cDefaultPixelsPerInch : Integer = 96;
type
  TMenuAnimation = (maNone, maRandom, maUnfold, maSlide);
{$IFDEF MSWINDOWS}
{ return filename ShortCut linked to }
function ResolveLink(const HWND: THandle; const LinkFile: TFileName;
  var FileName: TFileName): HRESULT;
{$ENDIF MSWINDOWS}
type
  TProcObj = procedure of object;
{ end JvUtils }
type
  TOnGetDefaultIniName = function: string;
  TPlacementOption = (fpState, fpSize, fpLocation, fpActiveControl);
  TPlacementOptions = set of TPlacementOption;
  TPlacementOperation = (poSave, poRestore);
var
  OnGetDefaultIniName: TOnGetDefaultIniName = nil;
  DefCompanyName: string = '';
  RegUseAppTitle: Boolean = False;
function StrToIniStr(const Str: string): string;
function IniStrToStr(const Str: string): string;
// Ini Utilitie Functions
// Added by RDB
function RectToStr(Rect: TRect): string;
function StrToRect(const Str: string; const Def: TRect): TRect;
function PointToStr(P: TPoint): string;
function StrToPoint(const Str: string; const Def: TPoint): TPoint;
type
  TMappingMethod = (mmHistogram, mmQuantize, mmTrunc784, mmTrunc666,
    mmTripel, mmGrayscale);

var
  DefaultMappingMethod: TMappingMethod = mmHistogram;
type
  // equivalent of TPoint, but that can be a published property
  TJvPoint = class(TPersistent)
  private
    FY: Longint;
    FX: Longint;
    FOnChange: TNotifyEvent;
    procedure SetX(Value: Longint);
    procedure SetY(Value: Longint);
    function GetAsPoint: TPoint;
    procedure SetAsPoint(const Value: TPoint);
  protected
    procedure DoChange;
  public
    procedure AssignPoint(const Source: TPoint);
    procedure Assign(Source: TPersistent); overload; override;
    procedure Assign(const Source: TPoint); reintroduce; overload;
    procedure CopyToPoint(var Point: TPoint);
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property AsPoint: TPoint read GetAsPoint write SetAsPoint;  
  published
    property X: Longint read FX write SetX default 0;
    property Y: Longint read FY write SetY default 0;
  end;
  // equivalent of TRect, but that can be a published property
  TJvRect = class(TPersistent)
  private
    FTopLeft: TJvPoint;
    FBottomRight: TJvPoint;
    FOnChange: TNotifyEvent;
    function GetBottom: Integer;
    function GetLeft: Integer;
    function GetRight: Integer;
    function GetTop: Integer;
    procedure SetBottom(Value: Integer);
    procedure SetLeft(Value: Integer);
    procedure SetRight(Value: Integer);
    procedure SetTop(Value: Integer);
    procedure SetBottomRight(Value: TJvPoint);
    procedure SetTopLeft(Value: TJvPoint);
    procedure PointChange(Sender: TObject);
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure SetHeight(Value: Integer);
    procedure SetWidth(Value: Integer);
  protected
    procedure DoChange;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AssignRect(const Source: TRect);
    procedure Assign(Source: TPersistent); overload; override;
    procedure Assign(const Source: TRect); reintroduce; overload;
    procedure CopyToRect(var Rect: TRect);
    property TopLeft: TJvPoint read FTopLeft write SetTopLeft;
    property BottomRight: TJvPoint read FBottomRight write SetBottomRight;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Left: Integer read GetLeft write SetLeft default 0;
    property Top: Integer read GetTop write SetTop default 0;
    property Right: Integer read GetRight write SetRight default 0;
    property Bottom: Integer read GetBottom write SetBottom default 0;
  end;
  TJvSize = class(TPersistent)
  private
    FWidth: Longint;
    FHeight: Longint;
    FOnChange: TNotifyEvent;
    procedure SetWidth(Value: Longint);
    procedure SetHeight(Value: Longint);
    function GetSize: TSize;
    procedure SetSize(const Value: TSize);
  protected
    procedure DoChange;
  public
    procedure AssignSize(const Source: TSize);
    procedure Assign(Source: TPersistent); overload; override;
    procedure Assign(const Source: TSize); reintroduce; overload;
    procedure CopyToSize(var Size: TSize);
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property AsSize: TSize read GetSize write SetSize;
  published
    property Width: Longint read FWidth write SetWidth default 0;
    property Height: Longint read FHeight write SetHeight default 0;
  end;
{ begin JvCtrlUtils }
//------------------------------------------------------------------------------
// ToolBarMenu
//------------------------------------------------------------------------------
type
  PJvLVItemStateData = ^TJvLVItemStateData;
  TJvLVItemStateData = record
    Caption: string;
    Data: Pointer;
    Focused: Boolean;
    Selected: Boolean;
  end;
{$IFDEF MSWINDOWS}
// AllocateHWndEx works like Classes.AllocateHWnd but does not use any virtual memory pages
function AllocateHWndEx(Method: TWndMethod; const AClassName: string = ''): THandle;
// DeallocateHWndEx works like Classes.DeallocateHWnd but does not use any virtual memory pages
procedure DeallocateHWndEx(Wnd: THandle);
function JvMakeObjectInstance(Method: TWndMethod): Pointer;
procedure JvFreeObjectInstance(ObjectInstance: Pointer);
{$ENDIF MSWINDOWS}
function IsPositiveResult(Value: TModalResult): Boolean;
function IsNegativeResult(Value: TModalResult): Boolean;
function IsAbortResult(const Value: TModalResult): Boolean;
function StripAllFromResult(const Value: TModalResult): TModalResult;
type
  TJvHTMLCalcType = (htmlShow, htmlCalcWidth, htmlCalcHeight, htmlHyperLink);
const
  DefaultSuperSubScriptRatio = 2/3;
function HTMLPrepareText(const Text: string): string;
function GetTopOwner(aCmp: TComponent): TComponent;
function IsOwnedComponent(aCmp, aOwner: TComponent): Boolean;
function IsChildWindow(const AChild, AParent: THandle): Boolean;
// This function generates a unique name for a component inside the list of all
// owner components.
// The name is generated in the login <OwnerName>_<AComponentName><Nr> or
// <OwnerName>_<ACOmponent.ClassName><Nr> when the AComponentName parameter
// is not defined. The number will be increased until the name is unique.
function GenerateUniqueComponentName(AOwner, AComponent: TComponent; const AComponentName: string = ''): string; overload;
// This function generates a unique name for a component inside the list of all
// components of its owner.
// The name is generated in the login <OwnerName>_<AComponentName><Nr> or
// <OwnerName>_<ACOmponent.ClassName><Nr> when the AComponentName parameter
// is not defined. The number will be increased until the name is unique.
procedure GenerateUniqueComponentName(AComponent: TComponent; const AComponentName: string = ''); overload;
function ReplaceComponentReference(This, NewReference: TComponent; var VarReference: TComponent): Boolean;

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
uses
  {$IFDEF MSWINDOWS}
  CommCtrl, ShlObj, ActiveX,
  {$ENDIF MSWINDOWS}
  Math, Contnrs,
  uRESTDWMemFileUtils,
  uRESTDWMemConsts, uRESTDWMemResources;

//{$R uRESTDWMemConsts.res}

const
  {$IFDEF MSWINDOWS}
  RC_ControlRegistry = 'Control Panel\Desktop';
  RC_WallPaperStyle = 'WallpaperStyle';
  RC_WallpaperRegistry = 'Wallpaper';
  RC_TileWallpaper = 'TileWallpaper';
  RC_RunCpl = 'rundll32.exe shell32,Control_RunDLL ';
  {$ENDIF MSWINDOWS}
procedure RGBToHSV(R, G, B: Integer; var H, S, V: Integer);
var
  Delta: Integer;
  Min, Max: Integer;
  function GetMax(I, J, K: Integer): Integer;
  begin
    if J > I then
      I := J;
    if K > I then
      I := K;
    Result := I;
  end;
  function GetMin(I, J, K: Integer): Integer;
  begin
    if J < I then
      I := J;
    if K < I then
      I := K;
    Result := I;
  end;
begin
  Min := GetMin(R, G, B);
  Max := GetMax(R, G, B);
  V := Max;
  Delta := Max - Min;
  if Max = 0 then
    S := 0
  else
    S := (255 * Delta) div Max;
  if S = 0 then
    H := 0
  else
  begin
    if R = Max then
      H := (60 * (G - B)) div Delta
    else
    if G = Max then
      H := 120 + (60 * (B - R)) div Delta
    else
      H := 240 + (60 * (R - G)) div Delta;
    if H < 0 then
      H := H + 360;
  end;
end;
{$IFDEF MSWINDOWS}
procedure SetWallpaper(const Path: string);
begin
  SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(Path), SPIF_UPDATEINIFILE);
end;
procedure SetWallpaper(const Path: string; Style: TJvWallpaperStyle);
begin
  with TRegistry.Create do
  begin
    try
      OpenKey(RC_ControlRegistry, False);
      case Style of
        wpTile:
          begin
            WriteString(RC_TileWallpaper, '1');
            WriteString(RC_WallPaperStyle, '0');
          end;
        wpCenter:
          begin
            WriteString(RC_TileWallpaper, '0');
            WriteString(RC_WallPaperStyle, '0');
          end;
        wpStretch:
          begin
            WriteString(RC_TileWallpaper, '0');
            WriteString(RC_WallPaperStyle, '2');
          end;
      end;
      WriteString(RC_WallpaperRegistry, Path);
    finally
      Free;
    end;
  end;
  SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, nil, SPIF_SENDWININICHANGE);
end;
{$ENDIF MSWINDOWS}
type
  TGetXBitmapMode =(gxRed, gxGreen, gxBlue, gxHue, gxSaturation, gxValue);
procedure HideFormCaption(FormHandle: THandle; Hide: Boolean);
begin
  if Hide then
    SetWindowLong(FormHandle, GWL_STYLE,
      GetWindowLong(FormHandle, GWL_STYLE) and not WS_CAPTION)
  else
    SetWindowLong(FormHandle, GWL_STYLE,
      GetWindowLong(FormHandle, GWL_STYLE) or WS_CAPTION);
end;

procedure LaunchCpl(const FileName: string);
begin
  // rundll32.exe shell32,Control_RunDLL ';
  RunDLL32('shell32.dll', 'Control_RunDLL', FileName, True);
  //  WinExec(PChar(RC_RunCpl + FileName), SW_SHOWNORMAL);
end;
procedure ShowSafeRemovalDialog;
begin
  LaunchCpl('HOTPLUG.DLL');
end;
const
  {$EXTERNALSYM WM_CPL_LAUNCH}
  WM_CPL_LAUNCH = (WM_USER + 1000);
  {$EXTERNALSYM WM_CPL_LAUNCHED}
  WM_CPL_LAUNCHED = (WM_USER + 1001);
  { (p3) just define enough to make the Cpl unnecessary for us (for the benefit of PE users) }
  cCplAddress = 'CPlApplet';
  CPL_INIT = 1;
  {$EXTERNALSYM CPL_INIT}
  CPL_GETCOUNT = 2;
  {$EXTERNALSYM CPL_GETCOUNT}
  CPL_INQUIRE = 3;
  {$EXTERNALSYM CPL_INQUIRE}
  CPL_EXIT = 7;
  {$EXTERNALSYM CPL_EXIT}
  CPL_NEWINQUIRE = 8;
  {$EXTERNALSYM CPL_NEWINQUIRE}
type
  TCPLApplet = function(hwndCPl: THandle; uMsg: UINT;
    lParam1, lParam2: LPARAM): Longint; stdcall;
  TCPLInfo = record
    idIcon: Integer;
    idName: Integer;
    idInfo: Integer;
    lData: LONG_PTR;
  end;
  TNewCPLInfoA = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwHelpContext: DWORD;
    lData: LONG_PTR;
    HICON: HICON;
    szName: array [0..31] of AnsiChar;
    szInfo: array [0..63] of AnsiChar;
    szHelpFile: array [0..127] of AnsiChar;
  end;
  TNewCPLInfoW = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwHelpContext: DWORD;
    lData: LONG_PTR;
    HICON: HICON;
    szName: array [0..31] of WideChar;
    szInfo: array [0..63] of WideChar;
    szHelpFile: array [0..127] of WideChar;
  end;
procedure PaintInverseRect(const RectOrg, RectEnd: TPoint);
var
  DC: Windows.HDC;
  R: TRect;
begin
  DC := Windows.GetDC(HWND_DESKTOP);
  try
    R := Rect(RectOrg.X, RectOrg.Y, RectEnd.X, RectEnd.Y);
    Windows.InvertRect(DC, R);
  finally
    Windows.ReleaseDC(HWND_DESKTOP, DC);
  end;
end;
procedure DrawInvertFrame(ScreenRect: TRect; Width: Integer);
var
  DC: Windows.HDC;
  I: Integer;
begin
  DC := Windows.GetDC(HWND_DESKTOP);
  try
    for I := 1 to Width do
    begin
      Windows.DrawFocusRect(DC, ScreenRect);
      //InflateRect(ScreenRect, -1, -1);
    end;
  finally
    Windows.ReleaseDC(HWND_DESKTOP, DC);
  end;
end;
function PointInPolyRgn(const P: TPoint; const Points: array of TPoint):
  Boolean;
var
  Rgn: HRGN;
  Count: Integer;
begin
  Count := Length(Points);
  Result := Count > 0;
  if Result then
  begin
    Rgn := CreatePolygonRgn(Points[0], Count, WINDING);
    try
      Result := PtInRegion(Rgn, P.X, P.Y);
    finally
      DeleteObject(Rgn);
    end;
  end;
end;
function PaletteEntries(Palette: HPALETTE): Integer;
begin
  GetObject(Palette, SizeOf(Integer), @Result);
end;
procedure ShowMDIClientEdge(ClientHandle: THandle; ShowEdge: Boolean);
var
  Style: Longint;
begin
  if ClientHandle <> 0 then
  begin
    Style := GetWindowLong(ClientHandle, GWL_EXSTYLE);
    if ShowEdge then
      if Style and WS_EX_CLIENTEDGE = 0 then
        Style := Style or WS_EX_CLIENTEDGE
      else
        Exit
    else
    if Style and WS_EX_CLIENTEDGE <> 0 then
      Style := Style and not WS_EX_CLIENTEDGE
    else
      Exit;
    SetWindowLong(ClientHandle, GWL_EXSTYLE, Style);
    SetWindowPos(ClientHandle, 0, 0, 0, 0, 0,
      SWP_FRAMECHANGED or SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER);
  end;
end;
function MsgBox(Handle: THandle; const Caption, Text: string; Flags: Integer): Integer;
begin
  {$IFDEF MSWINDOWS}
  Result := Windows.MessageBox(Handle, PChar(Text), PChar(Caption), Flags);
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  Result := MsgBox(Caption, Text, Flags);
  {$ENDIF UNIX}
end;
{$IFDEF MSWINDOWS}
function LoadAniCursor(Instance: THandle; ResID: PChar): HCURSOR;
{ Unfortunately I don't know how we can load animated cursor from
  executable resource directly. So I write this routine using temporary
  file and LoadCursorFromFile function. }
var
  S: TFileStream;
  FileName: string;
  RSrc: HRSRC;
  Res: THandle;
  Data: Pointer;
begin
  Result := 0;
  RSrc := FindResource(Instance, ResID, RT_ANICURSOR);
  if RSrc <> 0 then
  begin
    FileName := FileGetTempName('ANI');
    try
      Res := LoadResource(Instance, RSrc);
      try
        Data := LockResource(Res);
        if Data <> nil then
        try
          S := TFileStream.Create(FileName, fmCreate);
          try
            S.WriteBuffer(Data^, SizeOfResource(Instance, RSrc));
          finally
            S.Free;
          end;
          Result := LoadCursorFromFile(PChar(FileName));
        finally
          UnlockResource(Res);
        end;
      finally
        FreeResource(Res);
      end;
    finally
      Windows.DeleteFile(PChar(FileName));
    end;
  end;
end;
{$ENDIF MSWINDOWS}
var
  WaitCount: Integer = 0;
  SaveCursor: TCursor = crDefault;
const
  FWaitCursor: TCursor = crHourGlass;
{$IFDEF MSWINDOWS}
var
  OLEDragCursorsLoaded: Boolean = False;
{ Check if this is the active Windows task }
{ Copied from implementation of FORMS.PAS  }
type
  PCheckTaskInfo = ^TCheckTaskInfo;
  TCheckTaskInfo = record
    FocusWnd: Windows.HWND;
    Found: Boolean;
  end;
function CheckTaskWindow(Window: HWND; Data: LPARAM): BOOL; stdcall;
begin
  Result := True;
  if PCheckTaskInfo(Data).FocusWnd = Window then
  begin
    PCheckTaskInfo(Data).Found := True;
    Result := False;
  end;
end;
function IsForegroundTask: Boolean;
var
  Info: TCheckTaskInfo;
begin
  Info.FocusWnd := Windows.GetActiveWindow;
  Info.Found := False;
  EnumThreadWindows(GetCurrentThreadId, @CheckTaskWindow, LPARAM(@Info));
  Result := Info.Found;
end;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
function IsForegroundTask: Boolean;
begin
  Result := Application.Active;
end;
{$ENDIF UNIX}
const
  NoHelp = 0; { for MsgDlg2 }
  MsgDlgCharSet: Integer = DEFAULT_CHARSET;
function MsgYesNo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_YESNO or Flags) = IDYES;
end;
function MsgRetryCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_RETRYCANCEL or Flags) = IDRETRY;
end;
function MsgAbortRetryIgnore(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_ABORTRETRYIGNORE or Flags);
end;
function MsgYesNoCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_YESNOCANCEL or Flags);
end;
function MsgOKCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_OKCANCEL or Flags) = IDOK;
end;
procedure MsgOK(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgBox(Handle, Caption, Msg, MB_OK or Flags);
end;
procedure MsgInfo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONINFORMATION or Flags);
end;
procedure MsgWarn(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONWARNING or Flags);
end;
procedure MsgQuestion(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONQUESTION or Flags);
end;
procedure MsgError(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONERROR or Flags);
end;
function FindIcon(hInstance: DWORD; const IconName: string): Boolean;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := (IconName <> '') and
      (FindResourceW(hInstance, PWideChar(WideString(IconName)), PWideChar(RT_GROUP_ICON)) <> 0) or
      (FindResourceW(hInstance, PWideChar(WideString(IconName)), PWideChar(RT_ICON)) <> 0)
  else
    Result := (IconName <> '') and
      (FindResourceA(hInstance, PAnsiChar(AnsiString(IconName)), PAnsiChar(RT_GROUP_ICON)) <> 0) or
      (FindResourceA(hInstance, PAnsiChar(AnsiString(IconName)), PAnsiChar(RT_ICON)) <> 0);
end;
type
  TMsgBoxParamsRec = record
    case Boolean of
      False: (ParamsA: TMsgBoxParamsA);
      True: (ParamsW: TMsgBoxParamsW);
  end;
procedure MsgAbout(Handle: Integer; const Msg, Caption: string; const IcoName: string = 'MAINICON'; Flags: DWORD = MB_OK);
var
  Params: TMsgBoxParamsRec;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    Params.ParamsW.hInstance := hInstance;
    Params.ParamsW.cbSize := SizeOf(TMsgBoxParamsW);
    Params.ParamsW.hwndOwner := Handle;
    Params.ParamsW.lpszText := PWideChar(WideString(Msg));
    Params.ParamsW.lpszCaption := PWideChar(WideString(Caption));
    Params.ParamsW.dwStyle := Flags;
    if FindIcon(hInstance, IcoName) then
    begin
      Params.ParamsW.dwStyle := Params.ParamsW.dwStyle or MB_USERICON;
      Params.ParamsW.lpszIcon := PWideChar(WideString(IcoName));
    end
    else
      Params.ParamsW.dwStyle := Params.ParamsW.dwStyle or MB_ICONINFORMATION;
    Params.ParamsW.dwContextHelpId := 0;
    Params.ParamsW.lpfnMsgBoxCallback := nil;
    Params.ParamsW.dwLanguageId := GetUserDefaultLangID;
    MessageBoxIndirectW(Params.ParamsW);
  end
  else
  begin
    Params.ParamsA.hInstance := hInstance;
    Params.ParamsA.cbSize := SizeOf(TMsgBoxParamsA);
    Params.ParamsA.hwndOwner := Handle;
    Params.ParamsA.lpszText := PAnsiChar(AnsiString(Msg));
    Params.ParamsA.lpszCaption := PAnsiChar(AnsiString(Caption));
    Params.ParamsA.dwStyle := Flags;
    if FindIcon(hInstance, IcoName) then
    begin
      Params.ParamsA.dwStyle := Params.ParamsA.dwStyle or MB_USERICON;
      Params.ParamsA.lpszIcon := PAnsiChar(AnsiString(IcoName));
    end
    else
      Params.ParamsA.dwStyle := Params.ParamsA.dwStyle or MB_ICONINFORMATION;
    Params.ParamsA.dwContextHelpId := 0;
    Params.ParamsA.lpfnMsgBoxCallback := nil;
    Params.ParamsA.dwLanguageId := GetUserDefaultLangID;
    MessageBoxIndirectA(Params.ParamsA);
  end;
end;
{$IFDEF MSWINDOWS}
function ResolveLink(const HWND: THandle; const LinkFile: TFileName;
  var FileName: TFileName): HRESULT;
var
  psl: IShellLink;
  WLinkFile: array [0..MAX_PATH] of WideChar;
  wfd: TWin32FindData;
  ppf: IPersistFile;
  wnd: Windows.HWND;
begin
  wnd := HWND;
  Pointer(psl) := nil;
  Pointer(ppf) := nil;
  Result := CoInitialize(nil);
  if Succeeded(Result) then
  begin
    // Get a Pointer to the IShellLink interface.
    Result := CoCreateInstance(CLSID_ShellLink, nil,
      CLSCTX_INPROC_SERVER, IShellLink, psl);
    if Succeeded(Result) then
    begin
      // Get a Pointer to the IPersistFile interface.
      Result := psl.QueryInterface(IPersistFile, ppf);
      if Succeeded(Result) then
      begin
        StringToWideChar(LinkFile, WLinkFile, SizeOf(WLinkFile) - 1);
        // Load the shortcut.
        Result := ppf.Load(WLinkFile, STGM_READ);
        if Succeeded(Result) then
        begin
          // Resolve the link.
          Result := psl.Resolve(wnd, SLR_ANY_MATCH);
          if Succeeded(Result) then
          begin
            // Get the path to the link target.
            SetLength(FileName, MAX_PATH);
            Result := psl.GetPath(PChar(FileName), MAX_PATH, wfd,
              SLGP_UNCPRIORITY);
            if not Succeeded(Result) then
              Exit;
            SetLength(FileName, Length(PChar(FileName)));
          end;
        end;
        // Release the Pointer to the IPersistFile interface.
        ppf._Release;
      end;
      // Release the Pointer to the IShellLink interface.
      psl._Release;
    end;
    CoUninitialize;
  end;
  Pointer(psl) := nil;
  Pointer(ppf) := nil;
end;
{$ENDIF MSWINDOWS}
var
  ProcList: TList = nil;
type
  TJvProcItem = class(TObject)
  private
    FProcObj: TProcObj;
  public
    constructor Create(AProcObj: TProcObj);
  end;
constructor TJvProcItem.Create(AProcObj: TProcObj);
begin
  inherited Create;
  FProcObj := AProcObj;
end;
procedure TmrProc(hwnd: THandle; uMsg: Integer; idEvent: Integer; dwTime: Integer); stdcall;
var
  Pr: TProcObj;
begin
  if ProcList[idEvent] <> nil then
  begin
    Pr := TJvProcItem(ProcList[idEvent]).FProcObj;
    TJvProcItem(ProcList[idEvent]).Free;
  end
  else
    Pr := nil;
  ProcList.Delete(idEvent);
  KillTimer(hwnd, idEvent);
  if ProcList.Count <= 0 then
  begin
    ProcList.Free;
    ProcList := nil;
  end;
  if Assigned(Pr) then
    Pr;
end;
{ end JvUtils }
function StrToIniStr(const Str: string): string;
var
  N: Integer;
begin
  Result := Str;
  repeat
    N := Pos(CrLf, Result);
    if N > 0 then
      Result := Copy(Result, 1, N - 1) + '\n' + Copy(Result, N + 2, Length(Result));
  until N = 0;
  repeat
    N := Pos(#10#13, Result);
    if N > 0 then
      Result := Copy(Result, 1, N - 1) + '\n' + Copy(Result, N + 2, Length(Result));
  until N = 0;
end;
function IniStrToStr(const Str: string): string;
var
  N: Integer;
begin
  Result := Str;
  repeat
    N := Pos('\n', Result);
    if N > 0 then
      Result := Copy(Result, 1, N - 1) + CrLf + Copy(Result, N + 2, Length(Result));
  until N = 0;
end;
{ The following strings should not be localized }
const
  siFlags = 'Flags';
  siShowCmd = 'ShowCmd';
  siMinMaxPos = 'MinMaxPos';
  siNormPos = 'NormPos';
  siPixels = 'PixelsPerInch';
  siMDIChild = 'MDI Children';
  siListCount = 'Count';
  siItem = 'Item%d';
{$HINTS OFF}
type
  TComponentAccessProtected = class(TComponent);
{$HINTS ON}
{ end JvAppUtils }

function MaxFloat(const Values: array of Extended): Extended;
var
  I: Cardinal;
begin
  Result := Values[Low(Values)];
  for I := Low(Values) + 1 to High(Values) do
    if Values[I] > Result then
      Result := Values[I];
end;
function WidthBytes(I: Longint): Longint;
begin
  Result := ((I + 31) div 32) * 4;
end;
const
  MAX_COLORS = 4096;
type
  TTriple = array [0..2] of Byte;
  PQColor = ^TQColor;
  TQColor = record
    RGB: TTriple;
    NewColorIndex: Byte;
    Count: Longint;
    PNext: PQColor;
  end;
  PQColorArray = ^TQColorArray;
  TQColorArray = array [0..MAX_COLORS - 1] of TQColor;
  PQColorList = ^TQColorList;
  TQColorList = array [0..{$IFDEF RTL230_UP}MaxInt div 16{$ELSE}MaxListSize{$ENDIF RTL230_UP} - 1] of PQColor;
  PNewColor = ^TNewColor;
  TNewColor = record
    RGBMin: TTriple;
    RGBWidth: TTriple;
    NumEntries: Longint;
    Count: Longint;
    QuantizedColors: PQColor;
  end;
  PNewColorArray = ^TNewColorArray;
  TNewColorArray = array [Byte] of TNewColor;
procedure PInsert(ColorList: PQColorList;
  Number: Integer; SortRGBAxis: Integer);
var
  Q1, Q2: PQColor;
  I, J: Integer;
  Temp: PQColor;
begin
  for I := 1 to Number - 1 do
  begin
    Temp := ColorList[I];
    J := I - 1;
    while J >= 0 do
    begin
      Q1 := Temp;
      Q2 := ColorList[J];
      if Q1.RGB[SortRGBAxis] - Q2.RGB[SortRGBAxis] > 0 then
        Break;
      ColorList[J + 1] := ColorList[J];
      Dec(J);
    end;
    ColorList[J + 1] := Temp;
  end;
end;
procedure PSort(ColorList: PQColorList;
  Number: Integer; SortRGBAxis: Integer);
var
  Q1, Q2: PQColor;
  I, J, N, Nr: Integer;
  Temp, Part: PQColor;
begin
  if Number < 8 then
  begin
    PInsert(ColorList, Number, SortRGBAxis);
    Exit;
  end;
  Part := ColorList[Number div 2];
  I := -1;
  J := Number;
  repeat
    repeat
      Inc(I);
      Q1 := ColorList[I];
      Q2 := Part;
      N := Q1.RGB[SortRGBAxis] - Q2.RGB[SortRGBAxis];
    until N >= 0;
    repeat
      Dec(J);
      Q1 := ColorList[J];
      Q2 := Part;
      N := Q1.RGB[SortRGBAxis] - Q2.RGB[SortRGBAxis];
    until N <= 0;
    if I >= J then
      Break;
    Temp := ColorList[I];
    ColorList[I] := ColorList[J];
    ColorList[J] := Temp;
  until False;
  Nr := Number - I;
  if I < Number div 2 then
  begin
    PSort(ColorList, I, SortRGBAxis);
    PSort(PQColorList(@ColorList[I]), Nr, SortRGBAxis);
  end
  else
  begin
    PSort(PQColorList(@ColorList[I]), Nr, SortRGBAxis);
    PSort(ColorList, I, SortRGBAxis);
  end;
end;
function DivideMap(NewColorSubdiv: PNewColorArray; ColorMapSize: Integer;
  var NewColormapSize: Integer; LPSTR: Pointer): Integer;
var
  I, J: Integer;
  MaxSize, Index: Integer;
  NumEntries, MinColor, MaxColor: Integer;
  Sum, Count: Longint;
  QuantizedColor: PQColor;
  SortArray: PQColorList;
  SortRGBAxis: Integer;
begin
  Index := 0;
  SortRGBAxis := 0;
  while ColorMapSize > NewColormapSize do
  begin
    MaxSize := -1;
    for I := 0 to NewColormapSize - 1 do
    begin
      for J := 0 to 2 do
      begin
        if (NewColorSubdiv[I].RGBWidth[J] > MaxSize) and
          (NewColorSubdiv[I].NumEntries > 1) then
        begin
          MaxSize := NewColorSubdiv[I].RGBWidth[J];
          Index := I;
          SortRGBAxis := J;
        end;
      end;
    end;
    if MaxSize = -1 then
    begin
      Result := 1;
      Exit;
    end;
    SortArray := PQColorList(LPSTR);
    J := 0;
    QuantizedColor := NewColorSubdiv[Index].QuantizedColors;
    while (J < NewColorSubdiv[Index].NumEntries) and
      (QuantizedColor <> nil) do
    begin
      SortArray[J] := QuantizedColor;
      Inc(J);
      QuantizedColor := QuantizedColor.PNext;
    end;
    PSort(SortArray, NewColorSubdiv[Index].NumEntries, SortRGBAxis);
    for J := 0 to NewColorSubdiv[Index].NumEntries - 2 do
      SortArray[J].PNext := SortArray[J + 1];
    SortArray[NewColorSubdiv[Index].NumEntries - 1].PNext := nil;
    NewColorSubdiv[Index].QuantizedColors := SortArray[0];
    QuantizedColor := SortArray[0];
    Sum := NewColorSubdiv[Index].Count div 2 - QuantizedColor.Count;
    NumEntries := 1;
    Count := QuantizedColor.Count;
    Dec(Sum, QuantizedColor.PNext.Count);
    while (Sum >= 0) and (QuantizedColor.PNext <> nil) and
      (QuantizedColor.PNext.PNext <> nil) do
    begin
      QuantizedColor := QuantizedColor.PNext;
      Inc(NumEntries);
      Inc(Count, QuantizedColor.Count);
      Dec(Sum, QuantizedColor.PNext.Count);
    end;
    MaxColor := (QuantizedColor.RGB[SortRGBAxis]) shl 4;
    MinColor := (QuantizedColor.PNext.RGB[SortRGBAxis]) shl 4;
    NewColorSubdiv[NewColormapSize].QuantizedColors := QuantizedColor.PNext;
    QuantizedColor.PNext := nil;
    NewColorSubdiv[NewColormapSize].Count := Count;
    Dec(NewColorSubdiv[Index].Count, Count);
    NewColorSubdiv[NewColormapSize].NumEntries := NewColorSubdiv[Index].NumEntries - NumEntries;
    NewColorSubdiv[Index].NumEntries := NumEntries;
    for J := 0 to 2 do
    begin
      NewColorSubdiv[NewColormapSize].RGBMin[J] :=
        NewColorSubdiv[Index].RGBMin[J];
      NewColorSubdiv[NewColormapSize].RGBWidth[J] :=
        NewColorSubdiv[Index].RGBWidth[J];
    end;
    NewColorSubdiv[NewColormapSize].RGBWidth[SortRGBAxis] :=
      NewColorSubdiv[NewColormapSize].RGBMin[SortRGBAxis] +
      NewColorSubdiv[NewColormapSize].RGBWidth[SortRGBAxis] -
      MinColor;
    NewColorSubdiv[NewColormapSize].RGBMin[SortRGBAxis] := MinColor;
    NewColorSubdiv[Index].RGBWidth[SortRGBAxis] := MaxColor - NewColorSubdiv[Index].RGBMin[SortRGBAxis];
    Inc(NewColormapSize);
  end;
  Result := 1;
end;
function Quantize(const Bmp: TBitmapInfoHeader; gptr, Data8: Pointer;
  var ColorCount: Integer; var OutputColormap: TRGBPalette): Integer;
type
  PWord = ^Word;
var
  P: PByteArray;
  LineBuffer, Data: PAnsiChar;
  LineWidth: Longint;
  TmpLineWidth, NewLineWidth: Longint;
  I, J: Longint;
  Index: Word;
  NewColormapSize, NumOfEntries: Integer;
  Mems: Longint;
  cRed, cGreen, cBlue: Longint;
  LPSTR, Temp, Tmp: PAnsiChar;
  NewColorSubdiv: PNewColorArray;
  ColorArrayEntries: PQColorArray;
  QuantizedColor: PQColor;
begin
  LineWidth := WidthBytes(Longint(Bmp.biWidth) * Bmp.biBitCount);
  Mems := (Longint(SizeOf(TQColor)) * (MAX_COLORS)) +
    (Longint(SizeOf(TNewColor)) * 256) + LineWidth +
    (Longint(SizeOf(PQColor)) * (MAX_COLORS));
  LPSTR := AllocMem(Mems);
  try
    Temp := AllocMem(Longint(Bmp.biWidth) * Longint(Bmp.biHeight) * SizeOf(Word));
    try
      ColorArrayEntries := PQColorArray(LPSTR);
      NewColorSubdiv := PNewColorArray(LPSTR + Longint(SizeOf(TQColor)) * (MAX_COLORS));
      LineBuffer := LPSTR + (Longint(SizeOf(TQColor)) * (MAX_COLORS))
        +
        (Longint(SizeOf(TNewColor)) * 256);
      for I := 0 to MAX_COLORS - 1 do
      begin
        ColorArrayEntries^[I].RGB[0] := I shr 8;
        ColorArrayEntries^[I].RGB[1] := (I shr 4) and $0F;
        ColorArrayEntries^[I].RGB[2] := I and $0F;
        ColorArrayEntries^[I].Count := 0;
      end;
      Tmp := Temp;
      for I := 0 to Bmp.biHeight - 1 do
      begin
        Move(Pointer(PAnsiChar(gptr) + (Bmp.biHeight - 1 - I) * LineWidth)^, LineBuffer^, LineWidth);
        P := PByteArray(LineBuffer);
        for J := 0 to Bmp.biWidth - 1 do
        begin
          Index := (Longint(P^[2] and $F0) shl 4) +
            Longint(P^[1] and $F0) + (Longint(P^[0] and $F0) shr 4);
          Inc(ColorArrayEntries^[Index].Count);
          Inc(PByte(P), 3);
          PWord(Tmp)^ := Index;
          Inc(Tmp, 2);
        end;
      end;
      for I := 0 to 255 do
      begin
        NewColorSubdiv^[I].QuantizedColors := nil;
        NewColorSubdiv^[I].Count := 0;
        NewColorSubdiv^[I].NumEntries := 0;
        for J := 0 to 2 do
        begin
          NewColorSubdiv^[I].RGBMin[J] := 0;
          NewColorSubdiv^[I].RGBWidth[J] := 255;
        end;
      end;
      I := 0;
      while I < MAX_COLORS do
      begin
        if ColorArrayEntries^[I].Count > 0 then
          Break;
        Inc(I);
      end;
      QuantizedColor := @ColorArrayEntries^[I];
      NewColorSubdiv^[0].QuantizedColors := @ColorArrayEntries^[I];
      NumOfEntries := 1;
      Inc(I);
      while I < MAX_COLORS do
      begin
        if ColorArrayEntries^[I].Count > 0 then
        begin
          QuantizedColor^.PNext := @ColorArrayEntries^[I];
          QuantizedColor := @ColorArrayEntries^[I];
          Inc(NumOfEntries);
        end;
        Inc(I);
      end;
      QuantizedColor^.PNext := nil;
      NewColorSubdiv^[0].NumEntries := NumOfEntries;
      NewColorSubdiv^[0].Count := Longint(Bmp.biWidth) * Longint(Bmp.biHeight);
      NewColormapSize := 1;
      DivideMap(NewColorSubdiv, ColorCount, NewColormapSize,
        LPSTR + Longint(SizeOf(TQColor)) * (MAX_COLORS) + Longint(SizeOf(TNewColor)) * 256 + LineWidth);
      if NewColormapSize < ColorCount then
      begin
        for I := NewColormapSize to ColorCount - 1 do
          FillChar(OutputColormap[I], SizeOf(TRGBQuad), 0);
      end;
      for I := 0 to NewColormapSize - 1 do
      begin
        J := NewColorSubdiv^[I].NumEntries;
        if J > 0 then
        begin
          QuantizedColor := NewColorSubdiv^[I].QuantizedColors;
          cRed := 0;
          cGreen := 0;
          cBlue := 0;
          while QuantizedColor <> nil do
          begin
            QuantizedColor^.NewColorIndex := I;
            Inc(cRed, QuantizedColor^.RGB[0]);
            Inc(cGreen, QuantizedColor^.RGB[1]);
            Inc(cBlue, QuantizedColor^.RGB[2]);
            QuantizedColor := QuantizedColor^.PNext;
          end;
          with OutputColormap[I] do
          begin
            rgbRed := (Longint(cRed shl 4) or $0F) div J;
            rgbGreen := (Longint(cGreen shl 4) or $0F) div J;
            rgbBlue := (Longint(cBlue shl 4) or $0F) div J;
            rgbReserved := 0;
            if (rgbRed <= $10) and (rgbGreen <= $10) and (rgbBlue <= $10) then
              FillChar(OutputColormap[I], SizeOf(TRGBQuad), 0); { clBlack }
          end;
        end;
      end;
      TmpLineWidth := Longint(Bmp.biWidth) * SizeOf(Word);
      NewLineWidth := WidthBytes(Longint(Bmp.biWidth) * 8);
      FillChar(Data8^, NewLineWidth * Bmp.biHeight, #0);
      for I := 0 to Bmp.biHeight - 1 do
      begin
        LineBuffer := Temp + (Bmp.biHeight - 1 - I) * TmpLineWidth;
        Data := PAnsiChar(Data8) + I * NewLineWidth;
        for J := 0 to Bmp.biWidth - 1 do
        begin
          PByte(Data)^ := ColorArrayEntries^[PWord(LineBuffer)^].NewColorIndex;
          Inc(LineBuffer, 2);
          Inc(Data);
        end;
      end;
    finally
      FreeMem(Temp);
    end;
  finally
    FreeMem(LPSTR);
  end;
  ColorCount := NewColormapSize;
  Result := 0;
end;
{
  Procedures to truncate to lower bits-per-pixel, grayscale, tripel and
  histogram conversion based on freeware C source code of GBM package by
  Andy Key (nyangau att interalpha dott co dott uk). The home page of GBM
  author is at http://www.interalpha.net/customer/nyangau/.
}
{ Truncate to lower bits per pixel }
type
  TTruncLine = procedure(Src, Dest: Pointer; CX: Integer);
  { For 6Rx6Gx6B, 7Rx8Gx4B palettes etc. }
const
  Scale04: array [0..3] of Byte = (0, 85, 170, 255);
  Scale06: array [0..5] of Byte = (0, 51, 102, 153, 204, 255);
  Scale07: array [0..6] of Byte = (0, 43, 85, 128, 170, 213, 255);
  Scale08: array [0..7] of Byte = (0, 36, 73, 109, 146, 182, 219, 255);
  { For 6Rx6Gx6B, 7Rx8Gx4B palettes etc. }
var
  TruncTablesInitialized: Boolean = False;
  TruncIndex04: array [Byte] of Byte;
  TruncIndex06: array [Byte] of Byte;
  TruncIndex07: array [Byte] of Byte;
  TruncIndex08: array [Byte] of Byte;
  { These functions initialises this module }
procedure InitTruncTables;
  function NearestIndex(Value: Byte; const Bytes: array of Byte): Byte;
  var
    B, I: Byte;
    Diff, DiffMin: Word;
  begin
    Result := 0;
    B := Bytes[0];
    DiffMin := Abs(Value - B);
    for I := 1 to High(Bytes) do
    begin
      B := Bytes[I];
      Diff := Abs(Value - B);
      if Diff < DiffMin then
      begin
        DiffMin := Diff;
        Result := I;
      end;
    end;
  end;
var
  I: Integer;
begin
  if not TruncTablesInitialized then
  begin
    TruncTablesInitialized := True;
    // (rom) secured because it is called in initialization section
    // (ahuser) moved from initialization section to "on demand" initialization
    try
      { For 7 Red X 8 Green X 4 Blue palettes etc. }
      for I := 0 to 255 do
      begin
        TruncIndex04[I] := NearestIndex(Byte(I), Scale04);
        TruncIndex06[I] := NearestIndex(Byte(I), Scale06);
        TruncIndex07[I] := NearestIndex(Byte(I), Scale07);
        TruncIndex08[I] := NearestIndex(Byte(I), Scale08);
      end;
    except
    end;
  end;
end;
procedure Trunc(const Header: TBitmapInfoHeader; Src, Dest: Pointer;
  DstBitsPerPixel: Integer; TruncLineProc: TTruncLine);
var
  SrcScanline, DstScanline: Longint;
  Y: Integer;
begin
  SrcScanline := (Header.biWidth * 3 + 3) and not 3;
  DstScanline := ((Header.biWidth * DstBitsPerPixel + 31) div 32) * 4;
  for Y := 0 to Header.biHeight - 1 do
    TruncLineProc(PAnsiChar(Src) + Y * SrcScanline, PAnsiChar(Dest) + Y * DstScanline, Header.biWidth);
end;
{ return 6Rx6Gx6B palette
  This function makes the palette for the 6 red X 6 green X 6 blue palette.
  216 palette entrys used. Remaining 40 Left blank.
}
procedure TruncPal6R6G6B(var Colors: TRGBPalette);
var
  I, R, G, B: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), $80);
  I := 0;
  for R := 0 to 5 do
    for G := 0 to 5 do
      for B := 0 to 5 do
      begin
        Colors[I].rgbRed := Scale06[R];
        Colors[I].rgbGreen := Scale06[G];
        Colors[I].rgbBlue := Scale06[B];
        Colors[I].rgbReserved := 0;
        Inc(I);
      end;
end;
{ truncate to 6Rx6Gx6B one line }
procedure TruncLine6R6G6B(Src, Dest: Pointer; CX: Integer);
var
  X: Integer;
  R, G, B: Byte;
begin
  InitTruncTables;
  for X := 0 to CX - 1 do
  begin
    B := TruncIndex06[Byte(Src^)];
    Inc(PByte(Src));
    G := TruncIndex06[Byte(Src^)];
    Inc(PByte(Src));
    R := TruncIndex06[Byte(Src^)];
    Inc(PByte(Src), 1);
    PByte(Dest)^ := 6 * (6 * R + G) + B;
    Inc(PByte(Dest));
  end;
end;
{ truncate to 6Rx6Gx6B }
procedure Trunc6R6G6B(const Header: TBitmapInfoHeader;
  const Data24, Data8: Pointer);
begin
  Trunc(Header, Data24, Data8, 8, TruncLine6R6G6B);
end;
{ return 7Rx8Gx4B palette
  This function makes the palette for the 7 red X 8 green X 4 blue palette.
  224 palette entrys used. Remaining 32 Left blank.
  Colours calculated to match those used by 8514/A PM driver.
}
procedure TruncPal7R8G4B(var Colors: TRGBPalette);
var
  I, R, G, B: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), $80);
  I := 0;
  for R := 0 to 6 do
    for G := 0 to 7 do
      for B := 0 to 3 do
      begin
        Colors[I].rgbRed := Scale07[R];
        Colors[I].rgbGreen := Scale08[G];
        Colors[I].rgbBlue := Scale04[B];
        Colors[I].rgbReserved := 0;
        Inc(I);
      end;
end;
{ truncate to 7Rx8Gx4B one line }
procedure TruncLine7R8G4B(Src, Dest: Pointer; CX: Integer);
var
  X: Integer;
  R, G, B: Byte;
begin
  InitTruncTables;
  for X := 0 to CX - 1 do
  begin
    B := TruncIndex04[Byte(Src^)];
    Inc(PByte(Src));
    G := TruncIndex08[Byte(Src^)];
    Inc(PByte(Src));
    R := TruncIndex07[Byte(Src^)];
    Inc(PByte(Src));
    PByte(Dest)^ := 4 * (8 * R + G) + B;
    Inc(PByte(Dest));
  end;
end;
{ truncate to 7Rx8Gx4B }
procedure Trunc7R8G4B(const Header: TBitmapInfoHeader;
  const Data24, Data8: Pointer);
begin
  Trunc(Header, Data24, Data8, 8, TruncLine7R8G4B);
end;
{ Grayscale support }
procedure GrayPal(var Colors: TRGBPalette);
var
  I: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), 0);
  for I := 0 to 255 do
    FillChar(Colors[I], 3, I);
end;
procedure GrayScale(const Header: TBitmapInfoHeader; Data24, Data8: Pointer);
var
  SrcScanline, DstScanline: Longint;
  Y, X: Integer;
  Src, Dest: PByte;
  R, G, B: Byte;
begin
  SrcScanline := (Header.biWidth * 3 + 3) and not 3;
  DstScanline := (Header.biWidth + 3) and not 3;
  for Y := 0 to Header.biHeight - 1 do
  begin
    Src := Data24;
    Dest := Data8;
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Src^;
      Inc(Src);
      G := Src^;
      Inc(Src);
      R := Src^;
      Inc(Src);
      Dest^ := Byte(Longint(Word(R) * 77 + Word(G) * 150 + Word(B) * 29) shr 8);
      Inc(Dest);
    end;
    Data24 := PAnsiChar(Data24) + SrcScanline;
    Data8 := PAnsiChar(Data8) + DstScanline;
  end;
end;
{ Tripel conversion }
procedure TripelPal(var Colors: TRGBPalette);
var
  I: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), 0);
  for I := 0 to $40 do
  begin
    Colors[I].rgbRed := I shl 2;
    Colors[I + $40].rgbGreen := I shl 2;
    Colors[I + $80].rgbBlue := I shl 2;
  end;
end;
procedure Tripel(const Header: TBitmapInfoHeader; Data24, Data8: Pointer);
var
  SrcScanline, DstScanline: Longint;
  Y, X: Integer;
  Src, Dest: PByte;
  R, G, B: Byte;
begin
  SrcScanline := (Header.biWidth * 3 + 3) and not 3;
  DstScanline := (Header.biWidth + 3) and not 3;
  for Y := 0 to Header.biHeight - 1 do
  begin
    Src := Data24;
    Dest := Data8;
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Src^;
      Inc(Src);
      G := Src^;
      Inc(Src);
      R := Src^;
      Inc(Src);
      case ((X + Y) mod 3) of
        0: Dest^ := Byte(R shr 2);
        1: Dest^ := Byte($40 + (G shr 2));
        2: Dest^ := Byte($80 + (B shr 2));
      end;
      Inc(Dest);
    end;
    Data24 := PAnsiChar(Data24) + SrcScanline;
    Data8 := PAnsiChar(Data8) + DstScanline;
  end;
end;
{ Histogram/Frequency-of-use method of color reduction }
const
  MAX_N_COLS = 2049;
  MAX_N_HASH = 5191;
function Hash(R, G, B: Byte): Word;
begin
  Result := Word(Longint(Longint(R + G) * Longint(G + B) * Longint(B + R)) mod MAX_N_HASH);
end;
type
  PFreqRecord = ^TFreqRecord;
  TFreqRecord = record
    B: Byte;
    G: Byte;
    R: Byte;
    Frequency: Longint;
    Nearest: Byte;
  end;
  PHist = ^THist;
  THist = record
    ColCount: Longint;
    Rm: Byte;
    Gm: Byte;
    BM: Byte;
    Freqs: array [0..MAX_N_COLS - 1] of TFreqRecord;
    HashTable: array [0..MAX_N_HASH - 1] of Word;
  end;
function CreateHistogram(R, G, B: Byte): PHist;
{ create empty histogram }
begin
  GetMem(Result, SizeOf(THist));
  with Result^ do
  begin
    Rm := R;
    Gm := G;
    BM := B;
    ColCount := 0;
  end;
  FillChar(Result^.HashTable, MAX_N_HASH * SizeOf(Word), 255);
end;
procedure ClearHistogram(var Hist: PHist; R, G, B: Byte);
begin
  with Hist^ do
  begin
    Rm := R;
    Gm := G;
    BM := B;
    ColCount := 0;
  end;
  FillChar(Hist^.HashTable, MAX_N_HASH * SizeOf(Word), 255);
end;
procedure DeleteHistogram(var Hist: PHist);
begin
  FreeMem(Hist, SizeOf(THist));
  Hist := nil;
end;
function AddToHistogram(var Hist: THist; const Header: TBitmapInfoHeader;
  Data24: Pointer): Boolean;
{ add bitmap data to histogram }
var
  Step24: Integer;
  HashColor, Index: Word;
  Rm, Gm, BM, R, G, B: Byte;
  X, Y, ColCount: Longint;
begin
  Step24 := ((Header.biWidth * 3 + 3) and not 3) - Header.biWidth * 3;
  Rm := Hist.Rm;
  Gm := Hist.Gm;
  BM := Hist.BM;
  ColCount := Hist.ColCount;
  for Y := 0 to Header.biHeight - 1 do
  begin
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Byte(Data24^) and BM;
      Inc(PByte(Data24));
      G := Byte(Data24^) and Gm;
      Inc(PByte(Data24));
      R := Byte(Data24^) and Rm;
      Inc(PByte(Data24));
      HashColor := Hash(R, G, B);
      repeat
        Index := Hist.HashTable[HashColor];
        if (Index = $FFFF) or ((Hist.Freqs[Index].R = R) and
          (Hist.Freqs[Index].G = G) and (Hist.Freqs[Index].B = B)) then
          Break;
        Inc(HashColor);
        if HashColor = MAX_N_HASH then
          HashColor := 0;
      until False;
      { Note: loop will always be broken out of }
      { We don't allow HashTable to fill up above half full }
      if Index = $FFFF then
      begin
        { Not found in Hash table }
        if ColCount = MAX_N_COLS then
        begin
          Result := False;
          Exit;
        end;
        Hist.Freqs[ColCount].Frequency := 1;
        Hist.Freqs[ColCount].B := B;
        Hist.Freqs[ColCount].G := G;
        Hist.Freqs[ColCount].R := R;
        Hist.HashTable[HashColor] := ColCount;
        Inc(ColCount);
      end
      else
      begin
        { Found in Hash table, update index }
        Inc(Hist.Freqs[Index].Frequency);
      end;
    end;
    Inc(PByte(Data24), Step24);
  end;
  Hist.ColCount := ColCount;
  Result := True;
end;
procedure PalHistogram(var Hist: THist; var Colors: TRGBPalette;
  ColorsWanted: Integer);
{ work out a palette from Hist }
var
  I, J: Longint;
  MinDist, Dist: Longint;
  MaxJ, MinJ: Longint;
  DeltaB, DeltaG, DeltaR: Longint;
  MaxFreq: Longint;
begin
  I := 0;
  MaxJ := 0;
  MinJ := 0;
  { Now find the ColorsWanted most frequently used ones }
  while (I < ColorsWanted) and (I < Hist.ColCount) do
  begin
    MaxFreq := 0;
    for J := 0 to Hist.ColCount - 1 do
      if Hist.Freqs[J].Frequency > MaxFreq then
      begin
        MaxJ := J;
        MaxFreq := Hist.Freqs[J].Frequency;
      end;
    Hist.Freqs[MaxJ].Nearest := Byte(I);
    Hist.Freqs[MaxJ].Frequency := 0; { Prevent later use of Freqs[MaxJ] }
    Colors[I].rgbBlue := Hist.Freqs[MaxJ].B;
    Colors[I].rgbGreen := Hist.Freqs[MaxJ].G;
    Colors[I].rgbRed := Hist.Freqs[MaxJ].R;
    Colors[I].rgbReserved := 0;
    Inc(I);
  end;
  { Unused palette entries will be medium grey }
  while I <= 255 do
  begin
    Colors[I].rgbRed := $80;
    Colors[I].rgbGreen := $80;
    Colors[I].rgbBlue := $80;
    Colors[I].rgbReserved := 0;
    Inc(I);
  end;
  { For the rest, find the closest one in the first ColorsWanted }
  for I := 0 to Hist.ColCount - 1 do
  begin
    if Hist.Freqs[I].Frequency <> 0 then
    begin
      MinDist := 3 * 256 * 256;
      for J := 0 to ColorsWanted - 1 do
      begin
        DeltaB := Hist.Freqs[I].B - Colors[J].rgbBlue;
        DeltaG := Hist.Freqs[I].G - Colors[J].rgbGreen;
        DeltaR := Hist.Freqs[I].R - Colors[J].rgbRed;
        Dist := Longint(DeltaR * DeltaR) + Longint(DeltaG * DeltaG) +
          Longint(DeltaB * DeltaB);
        if Dist < MinDist then
        begin
          MinDist := Dist;
          MinJ := J;
        end;
      end;
      Hist.Freqs[I].Nearest := Byte(MinJ);
    end;
  end;
end;
procedure MapHistogram(var Hist: THist; const Header: TBitmapInfoHeader;
  Data24, Data8: Pointer);
{ map bitmap data to Hist palette }
var
  Step24: Integer;
  Step8: Integer;
  HashColor, Index: Longint;
  Rm, Gm, BM, R, G, B: Byte;
  X, Y: Longint;
begin
  Step24 := ((Header.biWidth * 3 + 3) and not 3) - Header.biWidth * 3;
  Step8 := ((Header.biWidth + 3) and not 3) - Header.biWidth;
  Rm := Hist.Rm;
  Gm := Hist.Gm;
  BM := Hist.BM;
  for Y := 0 to Header.biHeight - 1 do
  begin
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Byte(Data24^) and BM;
      Inc(PByte(Data24));
      G := Byte(Data24^) and Gm;
      Inc(PByte(Data24));
      R := Byte(Data24^) and Rm;
      Inc(PByte(Data24));
      HashColor := Hash(R, G, B);
      repeat
        Index := Hist.HashTable[HashColor];
        if (Hist.Freqs[Index].R = R) and (Hist.Freqs[Index].G = G) and
          (Hist.Freqs[Index].B = B) then
          Break;
        Inc(HashColor);
        if HashColor = MAX_N_HASH then
          HashColor := 0;
      until False;
      PByte(Data8)^ := Hist.Freqs[Index].Nearest;
      Inc(PByte(Data8));
    end;
    Inc(PByte(Data24), Step24);
    Inc(PByte(Data8), Step8);
  end;
end;
procedure Histogram(const Header: TBitmapInfoHeader; var Colors: TRGBPalette;
  Data24, Data8: Pointer; ColorsWanted: Integer; Rm, Gm, BM: Byte);
{ map single bitmap to frequency optimised palette }
var
  Hist: PHist;
begin
  Hist := CreateHistogram(Rm, Gm, BM);
  try
    repeat
      if AddToHistogram(Hist^, Header, Data24) then
        Break
      else
      begin
        if Gm > Rm then
          Gm := Gm shl 1
        else
        if Rm > BM then
          Rm := Rm shl 1
        else
          BM := BM shl 1;
        ClearHistogram(Hist, Rm, Gm, BM);
      end;
    until False;
    { Above loop will always be exited as if masks get rough   }
    { enough, ultimately number of unique colours < MAX_N_COLS }
    PalHistogram(Hist^, Colors, ColorsWanted);
    MapHistogram(Hist^, Header, Data24, Data8);
  finally
    DeleteHistogram(Hist);
  end;
end;
{ expand to 24 bits-per-pixel }
(*
procedure ExpandTo24Bit(const Header: TBitmapInfoHeader; Colors: TRGBPalette;
  Data, NewData: Pointer);
var
  Scanline, NewScanline: Longint;
  Y, X: Integer;
  Src, Dest: PAnsiChar;
  C: Byte;
begin
  if Header.biBitCount = 24 then
  begin
    Exit;
  end;
  Scanline := ((Header.biWidth * Header.biBitCount + 31) div 32) * 4;
  NewScanline := ((Header.biWidth * 3 + 3) and not 3);
  for Y := 0 to Header.biHeight - 1 do
  begin
    Src := PAnsiChar(Data) + Y * Scanline;
    Dest := PAnsiChar(NewData) + Y * NewScanline;
    case Header.biBitCount of
      1:
      begin
        C := 0;
        for X := 0 to Header.biWidth - 1 do
        begin
          if (X and 7) = 0 then
          begin
            C := Byte(Src^);
            Inc(Src);
          end
          else C := C shl 1;
          PByte(Dest)^ := Colors[C shr 7].rgbBlue;
          Inc(Dest);
          PByte(Dest)^ := Colors[C shr 7].rgbGreen;
          Inc(Dest);
          PByte(Dest)^ := Colors[C shr 7].rgbRed;
          Inc(Dest);
        end;
      end;
      4:
      begin
        X := 0;
        while X < Header.biWidth - 1 do
        begin
          C := Byte(Src^);
          Inc(Src);
          PByte(Dest)^ := Colors[C shr 4].rgbBlue;
          Inc(Dest);
          PByte(Dest)^ := Colors[C shr 4].rgbGreen;
          Inc(Dest);
          PByte(Dest)^ := Colors[C shr 4].rgbRed;
          Inc(Dest);
          PByte(Dest)^ := Colors[C and 15].rgbBlue;
          Inc(Dest);
          PByte(Dest)^ := Colors[C and 15].rgbGreen;
          Inc(Dest);
          PByte(Dest)^ := Colors[C and 15].rgbRed;
          Inc(Dest);
          Inc(X, 2);
        end;
        if X < Header.biWidth then
        begin
          C := Byte(Src^);
          PByte(Dest)^ := Colors[C shr 4].rgbBlue;
          Inc(Dest);
          PByte(Dest)^ := Colors[C shr 4].rgbGreen;
          Inc(Dest);
          PByte(Dest)^ := Colors[C shr 4].rgbRed;
          {Inc(Dest);}
        end;
      end;
      8:
      begin
        for X := 0 to Header.biWidth - 1 do
        begin
          C := Byte(Src^);
          Inc(Src);
          PByte(Dest)^ := Colors[C].rgbBlue;
          Inc(Dest);
          PByte(Dest)^ := Colors[C].rgbGreen;
          Inc(Dest);
          PByte(Dest)^ := Colors[C].rgbRed;
          Inc(Dest);
        end;
      end;
    end;
  end;
end;
*)
function BytesPerScanLine(PixelsPerScanline, BitsPerPixel,
  Alignment: Longint): Longint;
begin
  Dec(Alignment);
  Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
  Result := Result div 8;
end;

function GetDInColors(const BI: TBitmapInfoHeader): Integer;
begin
  if (BI.biClrUsed = 0) and (BI.biBitCount <= 8) then
    Result := 1 shl BI.biBitCount
  else
    Result := BI.biClrUsed;
end;
{ Change bits per pixel in a General Bitmap }
function ZoomImage(ImageW, ImageH, MaxW, MaxH: Integer; Stretch: Boolean):
  TPoint;
var
  Zoom: Double;
begin
  Result := Point(0, 0);
  if (MaxW <= 0) or (MaxH <= 0) or (ImageW <= 0) or (ImageH <= 0) then
    Exit;
  if Stretch then
  begin
    Zoom := MaxFloat([ImageW / MaxW, ImageH / MaxH]);
    if Zoom > 0 then
    begin
      Result.X := Round(ImageW * 0.98 / Zoom);
      Result.Y := Round(ImageH * 0.98 / Zoom);
    end
    else
    begin
      Result.X := ImageW;
      Result.Y := ImageH;
    end;
  end
  else
  begin
    Result.X := MaxW;
    Result.Y := MaxH;
  end;
end;

{$IFDEF MSWINDOWS}
//=== AllocateHWndEx =========================================================
const
  cUtilWindowExClass: TWndClass = (
    style: 0;
    lpfnWndProc: nil;
    cbClsExtra: 0;
    cbWndExtra: SizeOf(TMethod);
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TPUtilWindowEx');
function StdWndProc(Window: THandle; Message, WParam: WPARAM;
  LParam: LPARAM): LRESULT; stdcall;
var
  Msg: Messages.TMessage;
  WndProc: TWndMethod;
begin
  TMethod(WndProc).Code := Pointer(GetWindowLongPtr(Window, 0));
  TMethod(WndProc).Data := Pointer(GetWindowLongPtr(Window, SizeOf(Pointer)));
  if Assigned(WndProc) then
  begin
    Msg.Msg := Message;
    Msg.WParam := WParam;
    Msg.LParam := LParam;
    Msg.Result := 0;
    WndProc(Msg);
    Result := Msg.Result;
  end
  else
    Result := DefWindowProc(Window, Message, WParam, LParam);
end;
function AllocateHWndEx(Method: TWndMethod; const AClassName: string = ''): THandle;
var
  TempClass: TWndClass;
  UtilWindowExClass: TWndClass;
  ClassRegistered: Boolean;
begin
  UtilWindowExClass := cUtilWindowExClass;
  UtilWindowExClass.hInstance := HInstance;
  UtilWindowExClass.lpfnWndProc := @DefWindowProc;
  if AClassName <> '' then
    UtilWindowExClass.lpszClassName := PChar(AClassName);
  ClassRegistered := Windows.GetClassInfo(HInstance, UtilWindowExClass.lpszClassName,
    TempClass);
  if not ClassRegistered or (TempClass.lpfnWndProc <> @DefWindowProc) then
  begin
    if ClassRegistered then
      Windows.UnregisterClass(UtilWindowExClass.lpszClassName, HInstance);
    Windows.RegisterClass(UtilWindowExClass);
  end;
  Result := Windows.CreateWindowEx(Windows.WS_EX_TOOLWINDOW, UtilWindowExClass.lpszClassName,
    '', Windows.WS_POPUP, 0, 0, 0, 0, 0, 0, HInstance, nil);
  if Assigned(Method) then
  begin
    SetWindowLongPtr(Result, 0, LONG_PTR(TMethod(Method).Code));
    SetWindowLongPtr(Result, SizeOf(TMethod(Method).Code), LONG_PTR(TMethod(Method).Data));
    SetWindowLongPtr(Result, GWLP_WNDPROC, LONG_PTR(@StdWndProc));
  end;
end;
procedure DeallocateHWndEx(Wnd: THandle);
begin
  Windows.DestroyWindow(Wnd);
end;
function JvMakeObjectInstance(Method: TWndMethod): Pointer;
begin
  Result := MakeObjectInstance(Method);
end;
procedure JvFreeObjectInstance(ObjectInstance: Pointer);
begin
  if Assigned(ObjectInstance) then
    FreeObjectInstance(ObjectInstance);
end;
{$ENDIF MSWINDOWS}
const
  LeftBrackets = ['[', '{', '('];
  RightsBrackets = [']', '}', ')'];
function RectToStr(Rect: TRect): string;
begin
  Result := Format('[%d,%d,%d,%d]', [Rect.Left, Rect.Top, Rect.Right, Rect.Bottom]);
end;
function StrToRect(const Str: string; const Def: TRect): TRect;
var
  S: string;
  Temp: string{$IFNDEF RTL200_UP}[10]{$ENDIF ~RTL200_UP};
  I: Integer;
begin
  Result := Def;
  S := Str;
  if (S <> '') and CharInSet(S[1], LeftBrackets) and CharInSet(S[Length(S)], RightsBrackets) then
  begin
    Delete(S, 1, 1);
    SetLength(S, Length(S) - 1);
  end;
  I := Pos(',', S);
  if I > 0 then
  begin
    Temp := Trim(Copy(S, 1, I - 1));
    Result.Left := StrToIntDef(Temp, Def.Left);
    Delete(S, 1, I);
    I := Pos(',', S);
    if I > 0 then
    begin
      Temp := Trim(Copy(S, 1, I - 1));
      Result.Top := StrToIntDef(Temp, Def.Top);
      Delete(S, 1, I);
      I := Pos(',', S);
      if I > 0 then
      begin
        Temp := Trim(Copy(S, 1, I - 1));
        Result.Right := StrToIntDef(Temp, Def.Right);
        Delete(S, 1, I);
        Temp := Trim(S);
        Result.Bottom := StrToIntDef(Temp, Def.Bottom);
      end;
    end;
  end;
end;
function PointToStr(P: TPoint): string;
begin
  Result := Format('[%d,%d]', [P.X, P.Y]);
end;
function StrToPoint(const Str: string; const Def: TPoint): TPoint;
var
  S: string;
  Temp: string{$IFNDEF RTL200_UP}[10]{$ENDIF ~RTL200_UP};
  I: Integer;
begin
  Result := Def;
  S := Str;
  if (S <> '') and CharInSet(S[1], LeftBrackets) and CharInSet(S[Length(Str)], RightsBrackets) then
  begin
    Delete(S, 1, 1);
    SetLength(S, Length(S) - 1);
  end;
  I := Pos(',', S);
  if I > 0 then
  begin
    Temp := Trim(Copy(S, 1, I - 1));
    Result.X := StrToIntDef(Temp, Def.X);
    Delete(S, 1, I);
    Temp := Trim(S);
    Result.Y := StrToIntDef(Temp, Def.Y);
  end;
end;
function IsPositiveResult(Value: TModalResult): Boolean;
begin
  Result := Value in [mrOk, mrYes, mrAll, mrYesToAll];
end;
function IsNegativeResult(Value: TModalResult): Boolean;
begin
  Result := Value in [mrNo, mrNoToAll];
end;
function IsAbortResult(const Value: TModalResult): Boolean;
begin
  Result := Value in [mrCancel, mrAbort];
end;
function StripAllFromResult(const Value: TModalResult): TModalResult;
begin
  case Value of
    mrAll:
      Result := mrOk;
    mrNoToAll:
      Result := mrNo;
    mrYesToAll:
      Result := mrYes;
  else
    Result := Value;
  end;
end;
//=== { TJvPoint } ===========================================================
procedure TJvPoint.Assign(Source: TPersistent);
begin
  if Source is TJvPoint then
  begin
    FX := TJvPoint(Source).X;
    FY := TJvPoint(Source).Y;
    DoChange;
  end
  else
    inherited Assign(Source);
end;
procedure TJvPoint.AssignPoint(const Source: TPoint);
begin
  X := Source.X;
  Y := Source.Y;
end;
procedure TJvPoint.Assign(const Source: TPoint);
begin
  X := Source.X;
  Y := Source.Y;
end;
procedure TJvPoint.CopyToPoint(var Point: TPoint);
begin
  Point.X := X;
  Point.Y := Y;
end;
procedure TJvPoint.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;
function TJvPoint.GetAsPoint: TPoint;
begin
  Result := Point(FX, FY);
end;
procedure TJvPoint.SetAsPoint(const Value: TPoint);
begin
  if (Value.X <> FX) or (Value.Y <> FY) then
  begin
    FX := Value.X;
    FY := Value.Y;
    DoChange;
  end;
end;
procedure TJvPoint.SetX(Value: Longint);
begin
  if Value <> FX then
  begin
    FX := Value;
    DoChange;
  end;
end;
procedure TJvPoint.SetY(Value: Longint);
begin
  if Value <> FY then
  begin
    FY := Value;
    DoChange;
  end;
end;
//=== { TJvRect } ============================================================
constructor TJvRect.Create;
begin
  inherited Create;
  FTopLeft := TJvPoint.Create;
  FBottomRight := TJvPoint.Create;
  FTopLeft.OnChange := PointChange;
  FBottomRight.OnChange := PointChange;
end;
destructor TJvRect.Destroy;
begin
  FTopLeft.Free;
  FBottomRight.Free;
  inherited Destroy;
end;
procedure TJvRect.Assign(Source: TPersistent);
begin
  if Source is TJvRect then
  begin
    TopLeft.Assign(TJvRect(Source).TopLeft);
    BottomRight.Assign(TJvRect(Source).BottomRight);
    DoChange;
  end
  else
    inherited Assign(Source);
end;
procedure TJvRect.AssignRect(const Source: TRect);
begin
  TopLeft.AssignPoint(Source.TopLeft);
  BottomRight.AssignPoint(Source.BottomRight);
end;
procedure TJvRect.Assign(const Source: TRect);
begin
  TopLeft.Assign(Source.TopLeft);
  BottomRight.Assign(Source.BottomRight);
end;
procedure TJvRect.CopyToRect(var Rect: TRect);
begin
  TopLeft.CopyToPoint(Rect.TopLeft);
  BottomRight.CopyToPoint(Rect.BottomRight);
end;
procedure TJvRect.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;
function TJvRect.GetBottom: Integer;
begin
  Result := FBottomRight.Y;
end;
function TJvRect.GetLeft: Integer;
begin
  Result := FTopLeft.X;
end;
function TJvRect.GetRight: Integer;
begin
  Result := FBottomRight.X;
end;
function TJvRect.GetTop: Integer;
begin
  Result := FTopLeft.Y;
end;
procedure TJvRect.PointChange(Sender: TObject);
begin
  DoChange;
end;
procedure TJvRect.SetBottom(Value: Integer);
begin
  FBottomRight.Y := Value;
end;
procedure TJvRect.SetBottomRight(Value: TJvPoint);
begin
  FBottomRight.Assign(Value);
end;
procedure TJvRect.SetLeft(Value: Integer);
begin
  FTopLeft.X := Value;
end;
procedure TJvRect.SetRight(Value: Integer);
begin
  FBottomRight.X := Value;
end;
procedure TJvRect.SetTop(Value: Integer);
begin
  FTopLeft.Y := Value;
end;
procedure TJvRect.SetTopLeft(Value: TJvPoint);
begin
  FTopLeft.Assign(Value);
end;
function TJvRect.GetHeight: Integer;
begin
  Result := FBottomRight.Y - FTopLeft.Y;
end;
function TJvRect.GetWidth: Integer;
begin
  Result := FBottomRight.X - FTopLeft.X;
end;
procedure TJvRect.SetHeight(Value: Integer);
begin
  FBottomRight.Y := FTopLeft.Y + Value;
end;
procedure TJvRect.SetWidth(Value: Integer);
begin
  FBottomRight.X := FTopLeft.X + Value;
end;
{ TJvSize }
procedure TJvSize.Assign(Source: TPersistent);
begin
  if Source is TJvSize then
  begin
    FWidth := (Source as TJvSize).Width;
    FHeight := (Source as TJvSize).Height;
    DoChange;
  end
  else
  begin
    inherited Assign(Source);
  end;
end;
procedure TJvSize.AssignSize(const Source: TSize);
begin
  FWidth := Source.cx;
  FHeight := Source.cy;
  DoChange;
end;
procedure TJvSize.Assign(const Source: TSize);
begin
  FWidth := Source.cx;
  FHeight := Source.cy;
  DoChange;
end;
procedure TJvSize.CopyToSize(var Size: TSize);
begin
  Size.cx := Width;
  Size.cy := Height;
end;
procedure TJvSize.DoChange;
begin
  if Assigned(OnChange) then
   OnChange(Self);
end;
function TJvSize.GetSize: TSize;
begin
  Result.cx := FWidth;
  Result.cy := FHeight;
end;
procedure TJvSize.SetSize(const Value: TSize);
begin
  if (Value.cx <> FWidth) or (Value.cy <> FHeight) then
  begin
    FWidth := Value.cx;
    FHeight := Value.cy;
    DoChange;
  end;
end;
procedure TJvSize.SetHeight(Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    DoChange;
  end;
end;
procedure TJvSize.SetWidth(Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    DoChange;
  end;
end;
const
  cBR = '<BR>';
  cHR = '<HR>';
  cTagBegin = '<';
  cTagEnd = '>';
  cLT = '<';
  cGT = '>';
  cQuote = '"';
  cCENTER = 'CENTER';
  cRIGHT = 'RIGHT';
  cHREF = 'HREF';
  cIND = 'IND';
  cCOLOR = 'COLOR';
  cBGCOLOR = 'BGCOLOR';
// moved from JvHTControls and renamed
function HTMLPrepareText(const Text: string): string;
type
  THtmlCode = record
    Html: string;
    Text: UTF8String;
  end;
const
  Conversions: array [0..6] of THtmlCode = (
    (Html: '&amp;'; Text: '&'),
    (Html: '&quot;'; Text: '"'),
    (Html: '&reg;'; Text: #$C2#$AE),
    (Html: '&copy;'; Text: #$C2#$A9),
    (Html: '&trade;'; Text: #$E2#$84#$A2),
    (Html: '&euro;'; Text: #$E2#$82#$AC),
    (Html: '&nbsp;'; Text: ' ')
  );
var
  I: Integer;
begin
  Result := Text;
  for I := Low(Conversions) to High(Conversions) do
    Result := StringReplace(Result, Conversions[I].Html, Utf8ToAnsi(Conversions[I].Text), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, sLineBreak, '', [rfReplaceAll, rfIgnoreCase]); // only <BR> can be new line
  Result := StringReplace(Result, cBR, sLineBreak, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, cHR, cHR + sLineBreak, [rfReplaceAll, rfIgnoreCase]); // fixed <HR><BR>
end;
function HTMLBeforeTag(var Str: string; DeleteToTag: Boolean = False): string;
begin
  if Pos(cTagBegin, Str) > 0 then
  begin
    Result := Copy(Str, 1, Pos(cTagBegin, Str) - 1);
    if DeleteToTag then
      Delete(Str, 1, Pos(cTagBegin, Str) - 1);
  end
  else
  begin
    Result := Str;
    if DeleteToTag then
      Str := '';
  end;
end;
function GetChar(const Str: string; Pos: Word; Up: Boolean = False): Char;
begin
  if Length(Str) >= Pos then
    Result := Str[Pos]
  else
    Result := ' ';
  if Up then
    Result := UpCase(Result);
end;
function HTMLDeleteTag(const Str: string): string;
begin
  Result := Str;
  if (GetChar(Result, 1) = cTagBegin) and (Pos(cTagEnd, Result) > 1) then
    Delete(Result, 1, Pos(cTagEnd, Result));
end;
type
  TScriptPosition = (spNormal, spSuperscript, spSubscript);
function HTMLPlainText(const Text: string): string;
var
  S: string;
begin
  Result := '';
  S := HTMLPrepareText(Text);
  while Pos(cTagBegin, S) > 0 do
  begin
    Result := Result + Copy(S, 1, Pos(cTagBegin, S)-1);
    if Pos(cTagEnd, S) > 0 then
      Delete(S, 1, Pos(cTagEnd, S))
    else
      Delete(S, 1, Pos(cTagBegin, S));
  end;
  Result := Result + S;
end;
function MapWindowRect(hWndFrom, hWndTo: HWND; ARect: TRect): TRect;
begin
  MapWindowPoints(hWndFrom, hWndTo, ARect, 2);
  Result := ARect;
end;
function BeginClipRect(DC: HDC; AClipRect: TRect; fnMode: Integer): Integer; 
var
  MyRgn: HRGN;
begin
  Result := RGN_ERROR;
  if not IsRectEmpty(AClipRect) then
  begin
    MyRgn := CreateRectRgnIndirect(AClipRect);
    try
      Result := ExtSelectClipRgn(DC, MyRgn, fnMode);
    finally
      DeleteObject(MyRgn);
    end;
  end;
end;
function EndClipRect(DC: HDC): Integer;
begin
  Result := SelectClipRgn(DC, 0);
end;
function GetTopOwner(aCmp: TComponent): TComponent;
begin
  if aCmp = nil then
    Result := nil
  else
  if aCmp.Owner <> nil then
    Result := GetTopOwner(aCmp.Owner)
  else
    Result := aCmp;
end;
function IsOwnedComponent(aCmp, aOwner: TComponent): Boolean;
begin
  Result := False;
  if not (Assigned(aCmp) or Assigned(aOwner)) then
    Exit;
  Result := True;
  while aCmp.Owner <> nil do
  begin
    if aCmp.Owner = aOwner then
      Exit;
    aCmp := aCmp.Owner;
  end;
  Result := False;
end;
function IsChildWindow(const AChild, AParent: THandle): Boolean;
var
  LParent: HWND;
begin
  { Determines whether a window is the child (or grand^x-child) of another window }
  LParent := AChild;
  if LParent = AParent then
    Result := False // (ahuser) a parent is no a child of itself
  else
  begin
    while (LParent <> AParent) and (LParent <> NullHandle) do
      LParent := GetParent(LParent);
    Result := (LParent = AParent) and (LParent <> NullHandle);
  end;
end;
function GenerateUniqueComponentName(AOwner, AComponent: TComponent; const
    AComponentName: string = ''): string;
  function ValidateName(const AName: string): String;
  var
    I: Integer;
    Ignore : Boolean;
    C : Char;
  begin
    Ignore := True;
    Result := '';
    for I := 1 to Length(AName)  do
    begin
      C := AName[I];
      if CharInSet(C, ['A'..'Z', 'a'..'z', '_']) or
         ((Result <> '') and CharInSet(C, ['0'..'9'])) then
      begin
        Ignore := False;
        Result := Result+C;
      end
      else if Result <> '' then
      begin
        if not Ignore then
          Result := Result+'_';
        Ignore := True;
      end;
    end;
  end;
  function GenerateName(const AName: string; ANumber: Integer): string;
  var vName : String;
  begin
    vName := ValidateName (AName);
    if Assigned(AOwner) then
      if (AOwner.Name <> '') then
        Result := AOwner.Name
      else
        Result := AOwner.ClassName
    else
      Result := '';
    if (vName <> '') and (Result <> '') then
      Result := Result + '_';
    Result := Result + vName;
    if ANumber > 0 then
      Result := Result + IntToStr(ANumber);
  end;
  function IsUnique(const AName: string): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    if (AName <> '') and Assigned(AOwner) then
      for I := 0 to AOwner.ComponentCount - 1 do
        if (AOwner.Components[I] <> AComponent) and
          (CompareText(AOwner.Components[I].Name, AName) = 0) then
        begin
          Result := False;
          Break;
        end;
  end;
var
  I: Integer;
begin
  for I := 0 to MaxInt do
  begin
    if (AComponentName <> '') then
      Result := GenerateName(AComponentName, I)
    else
      if Assigned(AComponent) then
        Result := GenerateName(AComponent.ClassName, I)
      else
        Result := GenerateName('', I);
    if IsUnique(Result) then
      Break;
  end;
end;
procedure GenerateUniqueComponentName(AComponent: TComponent; const AComponentName: string = '');
begin
  if not Assigned(AComponent) then
    Exit;
  AComponent.Name := GenerateUniqueComponentName(AComponent.Owner, AComponent, AComponentName);
end;

function ReplaceComponentReference(This, NewReference: TComponent; var VarReference: TComponent): Boolean;
begin
  Result := (VarReference <> NewReference) and Assigned(This);
  if Result then
  begin
    if Assigned(VarReference) then
      VarReference.RemoveFreeNotification(This);
    VarReference := NewReference;
    if Assigned(VarReference) then
      VarReference.FreeNotification(This);
  end;
end;
end.
