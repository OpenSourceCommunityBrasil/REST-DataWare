unit uDWDatamodule;

interface

Uses
  SysUtils, Classes, SysTypes, uSystemEvents, uDWJSONObject, uDWConstsData, uDWConstsCharset, uRESTDWServerEvents,
  ServerUtils, uDWMassiveBuffer;

Type
 TUserBasicAuth  =             Procedure(Welcomemsg, AccessTag,
                                         Username, Password : String;
                                         Var Params         : TDWParams;
                                         Var ErrorCode      : Integer;
                                         Var ErrorMessage   : String;
                                         Var Accept         : Boolean) Of Object;
 TUserTokenAuth  =             Procedure(Welcomemsg,
                                         AccessTag          : String;
                                         Params             : TDWParams;
                                         AuthOptions        : TRDWAuthTokenParam;
                                         Var ErrorCode      : Integer;
                                         Var ErrorMessage   : String;
                                         Var TokenID        : String;
                                         Var Accept         : Boolean) Of Object;

 Type
  TRESTDWClientInfo = Class(TObject)
 Private
  vip,
  vipVersion,
  vUserAgent,
  vBaseRequest,
  vRequest,
  vToken         : String;
  vport          : Integer;
  Procedure  SetClientInfo(ip, ipVersion,
                           UserAgent,
                           BaseRequest, Request : String;
                           port                 : Integer);
  Procedure  SetToken     (aToken : String);
 Protected
 Public
  Constructor Create;
//  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property BaseRequest : String  Read vBaseRequest;
  Property Request     : String  Read vRequest;
  Property ip          : String  Read vip;
  Property UserAgent   : String  Read vUserAgent;
  Property port        : Integer Read vport;
  Property Token       : String  Read vToken;
 End;

 Type
  TServerMethodDataModule = Class(TDataModule)
  Private
   vClientWelcomeMessage : String;
   vReplyEvent           : TDWReplyEvent;
   vWelcomeMessage       : TWelcomeMessage;
   vMassiveProcess       : TMassiveProcess;
   vUserBasicAuth        : TUserBasicAuth;
   vUserTokenAuth        : TUserTokenAuth;
   vOnGetToken           : TOnGetToken;
   vOnMassiveBegin,
   vOnMassiveAfterStartTransaction,
   vOnMassiveAfterBeforeCommit,
   vOnMassiveAfterAfterCommit,
   vOnMassiveEnd         : TMassiveEvent;
   vOnMassiveLineProcess : TMassiveLineProcess;
   vEncoding             : TEncodeSelect;
   vRESTDWClientInfo     : TRESTDWClientInfo;
   vServerAuthOptions    : TRDWAuthOptionParam;
  Public
   Procedure   SetClientWelcomeMessage(Value : String);
   Procedure   SetClientInfo(ip, ipVersion,
                             UserAgent,
                             BaseRequest, Request : String;
                             port                 : Integer);
   Constructor Create(Sender : TComponent);Override;
   Destructor  Destroy;override;
   Property ServerAuthOptions              : TRDWAuthOptionParam Read vServerAuthOptions              Write vServerAuthOptions;
  Published
   Property ClientWelcomeMessage           : String              Read vClientWelcomeMessage;
   Property ClientInfo                     : TRESTDWClientInfo   Read vRESTDWClientInfo;
   Property Encoding                       : TEncodeSelect       Read vEncoding                       Write vEncoding;
   Property OnReplyEvent                   : TDWReplyEvent       Read vReplyEvent                     Write vReplyEvent;
   Property OnWelcomeMessage               : TWelcomeMessage     Read vWelcomeMessage                 Write vWelcomeMessage;
   Property OnMassiveProcess               : TMassiveProcess     Read vMassiveProcess                 Write vMassiveProcess;
   Property OnAfterMassiveLineProcess      : TMassiveLineProcess Read vOnMassiveLineProcess           Write vOnMassiveLineProcess;
   Property OnMassiveBegin                 : TMassiveEvent       Read vOnMassiveBegin                 Write vOnMassiveBegin;
   Property OnMassiveAfterStartTransaction : TMassiveEvent       Read vOnMassiveAfterStartTransaction Write vOnMassiveAfterStartTransaction;
   Property OnMassiveAfterBeforeCommit     : TMassiveEvent       Read vOnMassiveAfterBeforeCommit     Write vOnMassiveAfterBeforeCommit;
   Property OnMassiveAfterAfterCommit      : TMassiveEvent       Read vOnMassiveAfterAfterCommit      Write vOnMassiveAfterAfterCommit;
   Property OnMassiveEnd                   : TMassiveEvent       Read vOnMassiveEnd                   Write vOnMassiveEnd;
   Property OnUserBasicAuth                : TUserBasicAuth      Read vUserBasicAuth                  Write vUserBasicAuth;
   Property OnUserTokenAuth                : TUserTokenAuth      Read vUserTokenAuth                  Write vUserTokenAuth;
   Property OnGetToken                     : TOnGetToken         Read vOnGetToken                     Write vOnGetToken;
 End;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ TServerMethodDataModule }

Destructor TServerMethodDataModule.Destroy;
Begin
 FreeAndNil(vRESTDWClientInfo);
 If Assigned(vServerAuthOptions) Then
  FreeAndNil(vServerAuthOptions);
 Inherited;
End;

Procedure TServerMethodDataModule.SetClientInfo(ip, ipVersion,
                                                UserAgent,
                                                BaseRequest, Request : String;
                                                port                 : Integer);
Begin
 vRESTDWClientInfo.SetClientInfo(Trim(ip), ipVersion, Trim(UserAgent), BaseRequest, Request, Port);
End;

Constructor TServerMethodDataModule.Create(Sender: TComponent);
Begin
 Inherited Create(Sender);
 vRESTDWClientInfo               := TRESTDWClientInfo.Create;
 vClientWelcomeMessage           := '';
 vServerAuthOptions              := Nil;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  Encoding         := esUtf8;
 {$ELSE}
  Encoding         := esAscii;
 {$IFEND}
 {$ELSE}
  Encoding         := esUtf8;
 {$ENDIF}
End;

Procedure TServerMethodDataModule.SetClientWelcomeMessage(Value: String);
Begin
 vClientWelcomeMessage := Value;
End;

{ TRESTDWClientInfo }
{
Procedure TRESTDWClientInfo.Assign(Source : TPersistent);
Var
 Src : TRESTDWClientInfo;
Begin
 If Source is TRESTDWClientInfo Then
  Begin
   Src        := TRESTDWClientInfo(Source);
   vip        := Trim(Src.ip);
   vUserAgent := Trim(Src.UserAgent);
   vport      := Src.Port;
  End
 Else
  Inherited;
End;
}
Constructor TRESTDWClientInfo.Create;
Begin
 Inherited;
 vip          := '0.0.0.0';
 vUserAgent   := 'Undefined';
 vport        := 0;
 vToken       := '';
 vipVersion   := '';
 vBaseRequest := '';
 vRequest     := '';
End;

Procedure TRESTDWClientInfo.SetClientInfo(ip, ipVersion,
                                          UserAgent,
                                          BaseRequest, Request : String;
                                          port                 : Integer);
Begin
 vip          := Trim(ip);
 vUserAgent   := Trim(UserAgent);
 vipVersion   := Trim(ipVersion);
 vport        := Port;
 vBaseRequest := Request;
 vRequest     := BaseRequest;
End;

Procedure  TRESTDWClientInfo.SetToken    (aToken : String);
Begin
 vToken := aToken;
End;

end.
