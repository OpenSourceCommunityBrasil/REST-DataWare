unit uRESTDWDatamodule;

interface

Uses
  SysUtils, Classes, uRESTDWCharset, uRESTDWParams, DataUtils, uRESTDWComponentEvents,
  uRESTDWBasicTypes, uRESTDWConsts, uRESTDWJSONObject;

Type
 TUserBasicAuth  =             Procedure(Welcomemsg, AccessTag,
                                         Username, Password : String;
                                         Var Params         : TRESTDWParams;
                                         Var ErrorCode      : Integer;
                                         Var ErrorMessage   : String;
                                         Var Accept         : Boolean) Of Object;
 TUserTokenAuth  =             Procedure(Welcomemsg,
                                         AccessTag          : String;
                                         Params             : TRESTDWParams;
                                         AuthOptions        : TRESTDWAuthTokenParam;
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
   vQueuedRequest        : Boolean;
   vClientWelcomeMessage : String;
   vReplyEvent           : TRESTDWReplyEvent;
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
   vServerAuthOptions    : TRESTDWAuthOptionParam;
//   Procedure Loaded; Override;
  Public
   Procedure   SetClientWelcomeMessage(Value : String);
   Procedure   SetClientInfo(ip, ipVersion,
                             UserAgent,
                             BaseRequest, Request : String;
                             port                 : Integer);
   Constructor Create(Sender : TComponent);Override;
   Destructor  Destroy;override;
   Property ServerAuthOptions              : TRESTDWAuthOptionParam Read vServerAuthOptions              Write vServerAuthOptions;
  Published
   Property ClientWelcomeMessage           : String              Read vClientWelcomeMessage;
   Property ClientInfo                     : TRESTDWClientInfo   Read vRESTDWClientInfo;
   Property Encoding                       : TEncodeSelect       Read vEncoding                       Write vEncoding;
   Property OnReplyEvent                   : TRESTDWReplyEvent   Read vReplyEvent                     Write vReplyEvent;
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
   Property QueuedRequest                  : Boolean             Read vQueuedRequest                  Write vQueuedRequest;
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

end.
