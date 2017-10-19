unit Ras;

interface

uses
    Windows, SysUtils,Classes,ExtCtrls,Forms, Dialogs;

const
    rasapi32              = 'rasapi32.dll';

    UNLEN                 = 256;    // Maximum user name length
    PWLEN                 = 256;    // Maximum password length
    CNLEN                 = 15;     // Computer name length
    DNLEN                 = CNLEN;  // Maximum domain name length

    RAS_MaxDeviceType     = 16;
    RAS_MaxPhoneNumber    = 128;
    RAS_MaxIpAddress      = 15;
    RAS_MaxIpxAddress     = 21;
    RAS_MaxEntryName      = 256;
    RAS_MaxDeviceName     = 128;
    RAS_MaxCallbackNumber = RAS_MaxPhoneNumber;
    RAS_MaxAreaCode       = 10;
    RAS_MaxPadType        = 32;
    RAS_MaxX25Address     = 200;
    RAS_MaxFacilities     = 200;
    RAS_MaxUserData       = 200;
                                           
    RASCS_OpenPort            = 0;
    RASCS_PortOpened          = 1;
    RASCS_ConnectDevice       = 2;
    RASCS_DeviceConnected     = 3;
    RASCS_AllDevicesConnected = 4;
    RASCS_Authenticate        = 5;
    RASCS_AuthNotify          = 6;
    RASCS_AuthRetry           = 7;
    RASCS_AuthCallback        = 8;
    RASCS_AuthChangePassword  = 9;
    RASCS_AuthProject         = 10;
    RASCS_AuthLinkSpeed       = 11;
    RASCS_AuthAck             = 12;
    RASCS_ReAuthenticate      = 13;
    RASCS_Authenticated       = 14;
    RASCS_PrepareForCallback  = 15;
    RASCS_WaitForModemReset   = 16;
    RASCS_WaitForCallback     = 17;
    RASCS_Projected           = 18;

    RASCS_StartAuthentication = 19;
    RASCS_CallbackComplete    = 20;
    RASCS_LogonNetwork        = 21;
    RASCS_SubEntryConnected   = 22;
    RASCS_SubEntryDisconnected= 23;

    RASCS_PAUSED              = $1000;
    RASCS_Interactive         = RASCS_PAUSED;
    RASCS_RetryAuthentication = (RASCS_PAUSED + 1);
    RASCS_CallbackSetByCaller = (RASCS_PAUSED + 2);
    RASCS_PasswordExpired     = (RASCS_PAUSED + 3);

    RASCS_DONE                = $2000;
    RASCS_Connected           = RASCS_DONE;
    RASCS_Disconnected        = (RASCS_DONE + 1);

    // If using RasDial message notifications, get the notification message code
    // by passing this string to the RegisterWindowMessageA() API.
    // WM_RASDIALEVENT is used only if a unique message cannot be registered.
    RASDIALEVENT    = 'RasDialEvent';
    WM_RASDIALEVENT = $CCCD;

    // TRASPROJECTION
    RASP_Amb        = $10000;
    RASP_PppNbf     = $0803F;
    RASP_PppIpx     = $0802B;
    RASP_PppIp      = $08021;
    RASP_Slip       = $20000;

type

    tRasErrorEvent = Procedure(Sender:tObject;ErrString : String) of Object;
    tRasStateEvent = Procedure(Sender:tObject;NewState  : Integer) of Object;

    THRASCONN     = THandle;
    PHRASCONN     = ^THRASCONN;
    TRASCONNSTATE = DWORD;
    PDWORD        = ^DWORD;
    PBOOL         = ^BOOL;

    TRASDIALPARAMS = packed record
        dwSize           : DWORD;
        szEntryName      : array [0..RAS_MaxEntryName] of Char;
        szPhoneNumber    : array [0..RAS_MaxPhoneNumber] of Char;
        szCallbackNumber : array [0..RAS_MaxCallbackNumber] of Char;
        szUserName       : array [0..UNLEN] of Char;
        szPassword       : array [0..PWLEN] of Char;
        szDomain         : array [0..DNLEN] of Char;
{$IFDEF WINVER401}
        dwSubEntry       : DWORD;
        dwCallbackId     : DWORD;
{$ENDIF}
        szPadding        : array [0..2] of Char;
    end;
    PRASDIALPARAMS = ^TRASDIALPARAMS;

    TRASDIALEXTENSIONS = packed record
        dwSize     : DWORD;
        dwfOptions : DWORD;
        hwndParent : HWND;
        reserved   : DWORD;
    end;
    PRASDIALEXTENSIONS = ^TRASDIALEXTENSIONS;

    TRASCONNSTATUS = packed record
        dwSize       : DWORD;
        RasConnState : TRASCONNSTATE;
        dwError      : DWORD;
        szDeviceType : array [0..RAS_MaxDeviceType] of char;
        szDeviceName : array [0..RAS_MaxDeviceName] of char;
        szPadding    : array [0..1] of Char;
    end;
    PRASCONNSTATUS = ^TRASCONNSTATUS;

    TRASCONN = packed record
        dwSize       : DWORD;
        hRasConn     : THRASCONN;
        szEntryName  : array [0..RAS_MaxEntryName] of char;
        szDeviceType : array [0..RAS_MaxDeviceType] of char;
        szDeviceName : array [0..RAS_MaxDeviceName] of char;
        szPadding    : array [0..0] of Char;
    end;
    PRASCONN = ^TRASCONN;

    TRASENTRYNAME = packed record
        dwSize       : DWORD;
        szEntryName  : array [0..RAS_MaxEntryName] of char;
        szPadding    : array [0..2] of Char;
    end;
    PRASENTRYNAME = ^TRASENTRYNAME;
    TArrayRasEntryName = Array[0..0] of TRasEntryName;
    PArrayRasEntryName = ^tArrayRasEntryName;

    TRASENTRYDLG = packed record
        dwSize       : DWORD;
        hWndOwner    : HWND;
        dwFlags      : DWORD;
        xDlg         : LongInt;
        yDlg         : LongInt;
        szEntry      : array [0..RAS_MaxEntryName] of char;
        dwError      : DWORD;
        Reserved     : DWORD;
        Reserved2    : DWORD;
        szPadding    : array [0..2] of Char;
    end;
    PRASENTRYDLG = ^TRASENTRYDLG;

    TRASPROJECTION = integer;
    TRASPPPIP = record
        dwSize  : DWORD;
        dwError : DWORD;
        szIpAddress : array [0..RAS_MaxIpAddress] of char;
    end;

{************************************************************}
{*                                                          *}
{*       tRasConnection - Object                            *}
{*                                                          *}
{************************************************************}
    TRasConnection = class;
    RasIdentifier  = packed Record
        rasHandle  : tHRasConn;
        RasObject  : tRasConnection;
    end;
    tRasIdentifier = ^RasIdentifier;

    TRasConnection = class(tComponent)
    private
        fHandle     : tHRasConn;
        fOwner      : tComponent;
        fConnected  : boolean;
        fAborted    : boolean;
        fTimer      : tTimer;
        fReady      : Boolean;
        fState      : Integer;
        fError      : Integer;
        fErrMsg     : String;
        fStateChange: tRasStateEvent;
        fErrorProc  : tRasErrorEvent;
        fDialParams : tRasDialParams;
        Procedure   TimeOut(Sender : tObject);
        Procedure   SetState(Value:integer);
        Procedure   SetConnected(Value : Boolean);
        Procedure   DialUp;
        Procedure   AbortDial;
    Public
        Constructor Create(AOwner:tComponent);override;
        Destructor  Destroy;                  override;
        Function    Connectwith(Ras : String) : Boolean;
        Procedure   Hangup;
        Property    Handle    : tHRasConn  read fHandle;
        property    Connected : Boolean    read fConnected  write SetConnected;
        property    State     : integer    read fState      write SetState;
        Property    Aborted   : boolean    read fAborted;
        Property    Error     : Integer    read fError;
        Property    ErrMsg    : String     read fErrMsg;
    published
        property onStateChange : tRasStateEvent read fStateChange write fStateChange;
        property onError       : tRasErrorEvent read fErrorProc   write fErrorProc;
    end;

{************************************************************}
{*                                                          *}
{*       Pascal Interfaces                                  *}
{*                                                          *}
{************************************************************}

Function RasEnumEntries(Reserved       : Pointer;	 // reserved, must be NIL
                        szPhonebook    : PChar;	         // full path and filename of phonebook file
                        lpRasEntryName : PArrayRASENTRYNAME;  // buffer to receive entries
                   var  lpcb           : integer;	 // size in bytes of buffer
                   var  lpcEntries     : integer	         // number of entries written to buffer
                        ) : Integer;

function RasDial(RasDialExtensions: PRASDIALEXTENSIONS;
                  PhoneBook     : PChar;
                  RasDialParams : tRASDIALPARAMS;
                  NotifierType  : DWORD;
                  Notifier      : Pointer;
              var RasConn       : tHRASCONN
                 ): DWORD;

function RasHangup(RasConn: THRASCONN): DWORD;

function RasGetEntryDialParams(
                  szPhonebook : PChar; // pointer to the full path and filename of the phonebook file
              var rasdialparams : tRASDIALPARAMS;	// pointer to a structure that receives the connection parameters
              var fPassword     : BOOL    // indicates whether the user's password was retrieved
                 ) : DWORD;

function RasGetErrorString(
                  uErrorValue   : DWORD // error to get string for
                 ): String;

function RasEditPhonebookEntry(
                   hWndParent : HWND;     // handle to the parent window of the dialog box
                   Phonebook : String; // pointer to the full path and filename of the phonebook file
                   EntryName : String  // pointer to the phonebook entry name
                 ) : DWORD;

function RasCreatePhonebookEntry(
                     hWndParent : HWND;    // handle to the parent window of the dialog box
                     Phonebook  : String   // pointer to the full path and filename of the phonebook file
                   ) : DWORD;

function RasEnumConnections(
                  pRasConn    : PRASCONN;	 // buffer to receive connections data
            var   CB          : LongInt;	 // size in bytes of buffer
            var   Connections : DWORD            // number of connections written to buffer
                 ) : DWORD;
Function RasCountConnections  : Integer;
{************************************************************}
{*                                                          *}
{*       original Interfaces                                *}
{*                                                          *}
{************************************************************}
function RasHangupA(RasConn: THRASCONN): DWORD; stdcall;

function RasDialA(RasDialExtensions: PRASDIALEXTENSIONS;
                  PhoneBook     : PChar;
                  RasDialParams : PRASDIALPARAMS;
                  NotifierType  : DWORD;
                  Notifier      : Pointer;
                  RasConn       : PHRASCONN
                 ): DWORD; stdcall;
function RasGetErrorStringA(
                  uErrorValue   : DWORD; // error to get string for
                  szErrorString : PChar; // buffer to hold error string
                  cBufSize      : DWORD	 // size, in characters, of buffer
                 ): DWORD; stdcall;
function RasConnectionStateToString(nState : Integer) : String;
function RasGetConnectStatusA(
                  hRasConn: THRASCONN;   // handle to RAS connection of interest
                  lpRasConnStatus : PRASCONNSTATUS // buffer to receive status data
                 ): DWORD; stdcall;
function RasEnumConnectionsA(
                  pRasConn : PRASCONN;	 // buffer to receive connections data
                  pCB      : PDWORD;	 // size in bytes of buffer
                  pcConnections : PDWORD // number of connections written to buffer
                 ) : DWORD; stdcall
function RasEnumEntriesA(
                  Reserved : Pointer;	 // reserved, must be NIL
                  szPhonebook : PChar;	 // full path and filename of phonebook file
                  lpRasEntryName : PRASENTRYNAME; // buffer to receive entries
                  lpcb : PDWORD;	 // size in bytes of buffer
                  lpcEntries : PDWORD	 // number of entries written to buffer
                 ) : DWORD; stdcall;
function RasGetEntryDialParamsA(
                  lpszPhonebook : PChar; // pointer to the full path and filename of the phonebook file
                  lprasdialparams : PRASDIALPARAMS;	// pointer to a structure that receives the connection parameters
                  lpfPassword : PBOOL    // indicates whether the user's password was retrieved
                 ) : DWORD; stdcall;
function RasEditPhonebookEntryA(
                   hWndParent : HWND;     // handle to the parent window of the dialog box
                   lpszPhonebook : PChar; // pointer to the full path and filename of the phonebook file
                   lpszEntryName : PChar  // pointer to the phonebook entry name
                 ) : DWORD; stdcall;
//function RasEntryDlgA(
//                   lpszPhonebook : PChar; // pointer to the full path and filename of the phone-book file
//                   lpszEntry : PChar;     // pointer to the name of the phone-book entry to edit, copy, or create
//                   lpInfo : PRASENTRYDLG  // pointer to a structure that contains additional parameters
//                 ) : DWORD; stdcall;
function RasCreatePhonebookEntryA(
                     hWndParent : HWND;    // handle to the parent window of the dialog box
                     lpszPhonebook : PChar // pointer to the full path and filename of the phonebook file
                   ) : DWORD; stdcall;

function RasGetProjectionInfoA(
                    hRasConn      : THRASCONN;      // handle that specifies remote access connection of interest
                    RasProjection : TRASPROJECTION; // specifies type of projection information to obtain
                    lpProjection  : Pointer;        // points to buffer that receives projection information
                    lpcb          : PDWORD          // points to variable that specifies buffer size
                   ) : DWORD; stdcall;
function RasGetIPAddress: string;


Procedure Register;

implementation

Procedure Register;
Begin
     Registercomponents('Tests',[TRasConnection]);
end;

var     RasObjectList : tlist;
{************************************************************}
{*                                                          *}
{*       tRasConnection - Object                            *}
{*                                                          *}
{************************************************************}
Function FindRasIndex(Handle:tHRasConn):Integer;
var      I    : Integer;
Begin
     for I := 0 to RasObjectList.Count -1 do
     begin
          if tRasIdentifier(RasObjectList[I]).rasHandle = Handle then
          begin
               Result := I;
               Exit;
          end;
     end;
     Result := -1;
end;

Constructor tRasConnection.Create(AOwner : tComponent);
Begin
     inherited create(AOwner);
     fHandle    := 0;
     fOwner     := AOwner;
     fConnected := False;
     fTimer     := tTimer.Create(nil);
     fReady     := false;
     fState     := -1;
     fAborted   := false;
     With fTimer do
     begin
          enabled  := false;
          Interval := 30000;
          onTimer  := TimeOut;
     end;
     RasObjectlist.Add(@self);
end;

Destructor tRasConnection.Destroy;
Begin
     if connected then RasHangup(Handle);
     fTimer.free;
     inherited destroy;
end;

Procedure tRasConnection.SetState(Value:Integer);
Begin
     If fState <> Value then
     begin
          fState := Value;
          If Value = RASCS_DONE then
          begin
             fReady     := true;
             fConnected := true;
             fTimer.Enabled := false;
          end;
          if Assigned(OnStateChange) then
             OnStateChange(self,Value);
     end;
end;

Procedure tRasConnection.SetConnected(Value:Boolean);
Begin
     If fConnected <> Value then
     begin
          fAborted := False;
          if Value then
             DialUp
          else
             Hangup;
     end;
end;

Procedure MyDialFunc1(Hndl     : tHRasConn;
                      MsNum    : uint;
                      NewState : SmallInt;
                      ActError : integer;
                      xError   : Integer); stdcall;
{*********************************************************************************}
{* This callback doesn't know which tRasconnection is to receive the information *}
{*********************************************************************************}
Var     I      : Integer;
        RasObj : tRasConnection;
begin
     I := FindRasIndex(Hndl);
     if I < 0 then exit;
     RasObj := tRasIdentifier(RasObjectList[I]).rasObject;
     with RasObj do begin
          If ActError = 0 then
          begin
               State := NewState;
          end
          else
          begin
               fError := ActError;
               fErrMsg := RasGetErrorString(ActError);
               AbortDial;
               If Assigned(OnError) then
                  OnError(RasObj,ErrMsg);
          end;
     end;
end;

Procedure tRasConnection.DialUp;
{ Dial with given DialParams }
var                 thisRas     : tRasIdentifier;
                    R           : Integer;
Begin
     fError    := 0;
     Connected := false;   { Hangup any pending connection }
     fHandle := 0;
     R := RasDial(nil,nil,fDialParams,1,@MyDialFunc1,fHandle);
     If R <> 0 then begin
        Raise Exception.create('Verbindungsfehler : '+ErrMsg);
     end;
     fTimer.Enabled := True;
     If fHandle <= 0 then exit;
     new(thisRas);
     thisRas.rasHandle := fhandle;
     thisRas.RasObject := Self;
     RasObjectList.Add(thisRas);
     While not fReady do
     begin
          Application.Handlemessage;
          Application.ProcessMessages;
     end;
     fTimer.enabled := false;
end;

Function  tRasConnection.Connectwith(Ras : String) : Boolean;
var       HavePassWord : bool;
          I            : integer;
          R            : Integer;
begin
     Result := False;
     fReady  := False;
     Fillchar(fDialParams,SizeOf(fDialParams),0);
     fDialParams.dwSize := SizeOf(fDialParams);
     for I := 1 to length(Ras) do
         fDialParams.szEntryName[Pred(I)] := Ras[I];
     HavePassWord := False;
     R := RasGetEntryDialParams(nil,fDialParams,HavePassWord);
     if R <> 0 then
     begin
        { couldn't get the Dial Params !!! }
        fAborted := true;
        exit;
     end;
     if not havePassword then
     begin
{ TODO : Passwort - Dialog einfügen }
     end;
     DialUp;
     Result := Connected;
end;

Procedure tRasConnection.Hangup;
var       RasIndex    : Integer;
          thisRas     : tRasIdentifier;
begin
     fConnected     := False;
     fTimer.Enabled := false;
     RasHangup(Handle);
     If Handle = 0 then Exit;
     RasIndex := FindRasIndex(Handle);
     if rasIndex >= 0 then
     begin
        ThisRas := RasObjectList.Items[RasIndex];
        DisPose(ThisRas);  
        RasObjectlist.Delete(RasIndex);
     end;
end;

Procedure tRasConnection.AbortDial;
begin
     Hangup;
     fAborted       := True;
     fReady         := True;
end;

Procedure tRasConnection.TimeOut(Sender : tObject);
{ The connection was timed out }
begin
     AbortDial;
end;

{************************************************************}
{*                                                          *}
{*       Pascal Interfaces                                  *}
{*                                                          *}
{************************************************************}
Function RasEnumEntries(Reserved       : Pointer;	 // reserved, must be NIL
                        szPhonebook    : PChar;	         // full path and filename of phonebook file
                        lpRasEntryName : PArrayRASENTRYNAME;  // buffer to receive entries
                   var  lpcb           : integer;	 // size in bytes of buffer
                   var  lpcEntries     : integer	         // number of entries written to buffer
                        ) : Integer;
Begin
        Result := RasEnumEntriesA(Reserved,szPhonebook,@lpRasEntryName^[0],@lpcb,@lpcEntries);
end;

function RasDial(RasDialExtensions: PRASDIALEXTENSIONS;
                  PhoneBook     : PChar;
                  RasDialParams : tRASDIALPARAMS;
                  NotifierType  : DWORD;
                  Notifier      : Pointer;
            var   RasConn       : tHRASCONN
                 ): DWORD;
Begin
     RasDial := RasDialA(RasDialExtensions,Phonebook,@RasDialParams,NotifierType,
                         Notifier,@RasConn);
end;

function RasHangup(RasConn: THRASCONN): DWORD;
Var      RASConnStatus : TRasConnStatus;
         Status        : Integer;
Begin
     FillChar(RasConnStatus, SizeOf(RasConnStatus), 0);
     RasConnStatus.dwSize := SizeOf(RasConnStatus);
     {Status := }RasGetConnectStatusA(RasConn, @RasConnStatus);
     RasHangup := RasHangupA(RasConn);
     Repeat
           Status := RasGetConnectStatusA(RasConn, @RasConnStatus);
           sleep(0);
     Until Status = ERROR_INVALID_HANDLE;
end;

function RasGetEntryDialParams(
                  szPhonebook : PChar; // pointer to the full path and filename of the phonebook file
              var rasdialparams : tRASDIALPARAMS;	// pointer to a structure that receives the connection parameters
              var fPassword     : BOOL    // indicates whether the user's password was retrieved
                 ) : DWORD;
begin
     Result := RasGetEntryDialParamsA(szPhonebook,@RasDialParams,@fPassword);
end;

function RasGetErrorString(
                  uErrorValue   : DWORD // error to get string for
                 ): String;
Begin
     SetLength(Result,256);
     If RasGetErrorStringA(uErrorValue,PChar(Result),256) <> 0 then
        Result := '';
     SetLength(Result,Pos(#0,Result));
end;

function RasEditPhonebookEntry(
                   hWndParent : HWND;     // handle to the parent window of the dialog box
                   Phonebook : String; // pointer to the full path and filename of the phonebook file
                   EntryName : String  // pointer to the phonebook entry name
                 ) : DWORD;
begin
     Result := RasEditPhonebookEntryA(hWndParent,Pchar(Phonebook),PChar(Entryname));
end;

function RasCreatePhonebookEntry(
                     hWndParent : HWND;    // handle to the parent window of the dialog box
                     Phonebook  : String   // pointer to the full path and filename of the phonebook file
                   ) : DWORD;
begin
     Result := RasCreatePhonebookEntryA(HwndParent,PChar(Phonebook));
end;

function RasEnumConnections(
                  pRasConn    : PRASCONN;	 // buffer to receive connections data
            var   CB          : LongInt;	 // size in bytes of buffer
            var   Connections : DWORD            // number of connections written to buffer
                 ) : DWORD;
begin
     Result := RasEnumConnectionsA(pRasConn,@CB,@Connections);
end;

Function RasCountConnections  : Integer;
var        Sz      : LongInt;
           Nr      : DWord;
begin
     Sz := 0;
     RasEnumConnections(nil,Sz,Nr);
     Result := Sz div SizeOf(tRasConn);
end;

{************************************************************}
{*                                                          *}
{*       original Interfaces                                *}
{*                                                          *}
{************************************************************}
function RasConnectionStateToString(nState : Integer) : String;
begin
    case nState of
    RASCS_OpenPort:             Result := 'Opening Port';
    RASCS_PortOpened:           Result := 'Port Opened';
    RASCS_ConnectDevice:        Result := 'Connecting Device';
    RASCS_DeviceConnected:      Result := 'Device Connected';
    RASCS_AllDevicesConnected:  Result := 'All Devices Connected';
    RASCS_Authenticate:         Result := 'Starting Authentication';
    RASCS_AuthNotify:           Result := 'Authentication Notify';
    RASCS_AuthRetry:            Result := 'Authentication Retry';
    RASCS_AuthCallback:         Result := 'Callback Requested';
    RASCS_AuthChangePassword:   Result := 'Change Password Requested';
    RASCS_AuthProject:          Result := 'Projection Phase Started';
    RASCS_AuthLinkSpeed:        Result := 'Link Speed Calculation';
    RASCS_AuthAck:              Result := 'Authentication Acknowledged';
    RASCS_ReAuthenticate:       Result := 'Reauthentication Started';
    RASCS_Authenticated:        Result := 'Authenticated';
    RASCS_PrepareForCallback:   Result := 'Preparation For Callback';
    RASCS_WaitForModemReset:    Result := 'Waiting For Modem Reset';
    RASCS_WaitForCallback:      Result := 'Waiting For Callback';
    RASCS_Projected:            Result := 'Projected';
    RASCS_StartAuthentication:  Result := 'Start Authentication';
    RASCS_CallbackComplete:     Result := 'Callback Complete';
    RASCS_LogonNetwork:         Result := 'Logon Network';
    RASCS_SubEntryConnected:    Result := '';
    RASCS_SubEntryDisconnected: Result := '';
    RASCS_Interactive:          Result := 'Interactive';
    RASCS_RetryAuthentication:  Result := 'Retry Authentication';
    RASCS_CallbackSetByCaller:  Result := 'Callback Set By Caller';
    RASCS_PasswordExpired:      Result := 'Password Expired';
    RASCS_Connected:            Result := 'Connected';
    RASCS_Disconnected:         Result := 'Disconnected';
    else
        Result := 'Connection state #' + IntToStr(nState);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function RasGetIPAddress: string;
var
    RASConns   : TRasConn;
    dwSize     : DWORD;
    dwCount    : DWORD;
    RASpppIP   : TRASPPPIP;
begin
    Result          := '';
    RASConns.dwSize := SizeOf(TRASConn);
    RASpppIP.dwSize := SizeOf(RASpppIP);
    dwSize          := SizeOf(RASConns);
    if RASEnumConnectionsA(@RASConns, @dwSize, @dwCount) = 0 then begin
        if dwCount > 0 then begin
            dwSize := SizeOf(RASpppIP);
            RASpppIP.dwSize := SizeOf(RASpppIP);
            if RASGetProjectionInfoA(RASConns.hRasConn,
                                     RASP_PppIp,
                                     @RasPPPIP,
                                     @dwSize) = 0 then
                Result := StrPas(RASpppIP.szIPAddress);
       end;
    end;
end;



{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function RasDialA;                 external rasapi32 name 'RasDialA';
function RasGetErrorStringA;       external rasapi32 name 'RasGetErrorStringA';
function RasHangUpA;               external rasapi32 name 'RasHangUpA';
function RasGetConnectStatusA;     external rasapi32 name 'RasGetConnectStatusA';
function RasEnumConnectionsA;      external rasapi32 name 'RasEnumConnectionsA';
function RasEnumEntriesA;          external rasapi32 name 'RasEnumEntriesA';
function RasGetEntryDialParamsA;   external rasapi32 name 'RasGetEntryDialParamsA';
function RasEditPhonebookEntryA;   external rasapi32 name 'RasEditPhonebookEntryA';
//function RasEntryDlgA;             external rasapi32 name 'RasEntryDlgA';
function RasCreatePhonebookEntryA; external rasapi32 name 'RasCreatePhonebookEntryA';
function RasGetProjectionInfoA;    external rasapi32 name 'RasGetProjectionInfoA';

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
initialization
        RasObjectList := tList.create;
Finalization
        RasObjectList.Free;
end.
