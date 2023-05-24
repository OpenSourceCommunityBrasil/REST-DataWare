unit uRESTDWDatamodule;

{$I ..\..\Includes\uRESTDW.inc}

interface

Uses
  SysUtils, Classes, uRESTDWDataUtils, uRESTDWComponentEvents,
  uRESTDWBasicTypes, uRESTDWConsts, uRESTDWJSONObject, uRESTDWParams, uRESTDWAuthenticators;

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
                                         AuthOptions        : TRESTDWAuthToken;
                                         Var ErrorCode      : Integer;
                                         Var ErrorMessage   : String;
                                         Var TokenID        : String;
                                         Var Accept         : Boolean) Of Object;

 Type
  TRESTDWClientInfo = Class(TObject)
 Private
  vip,
  vUserAgent,
  vBaseRequest,
  vToken         : String;
  vport          : Integer;
  Procedure  SetClientInfo(ip,
                           UserAgent,
                           BaseRequest : String;
                           port        : Integer);
 Protected
 Public
  Constructor Create;
//  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property BaseRequest : String  Read vBaseRequest;
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
   Procedure   SetClientInfo(ip,
                             UserAgent,
                             BaseRequest : String;
                             port        : Integer);
   Function    GetAction    (Var URL                : String;
                             Var Params             : TRESTDWParams;
                             Var CORS_CustomHeaders : TStrings) : Boolean;
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

Uses uRESTDWServerEvents, uRESTDWServerContext;
{ TServerMethodDataModule }

Destructor TServerMethodDataModule.Destroy;
Begin
 FreeAndNil(vRESTDWClientInfo);
 If Assigned(vServerAuthOptions) Then
  FreeAndNil(vServerAuthOptions);
 Inherited;
End;

Function  TServerMethodDataModule.GetAction(Var URL                : String;
                                            Var Params             : TRESTDWParams;
                                            Var CORS_CustomHeaders : TStrings) : Boolean;
Var
 I, A,
 vPosQuery     : Integer;
 vIsQuery      : Boolean;
 vTempRoute,
 vTempValue,
 vTempParamsURI,
 vTempURL,
 ParamsURI     : String;
 vParamMethods : TRESTDWParamsMethods;
 Procedure ParseParams;
 Var
  lst       : TStringList;
  pAux1,
  cAux1     : Integer;
  sAux1,
  sAux2     : string;
  JSONParam : TJSONParam;
 Begin
  lst := TStringList.Create;
  Try
   pAux1 := Pos('?', ParamsURI);
   // params com /
   sAux1 := Copy(ParamsURI, 1, pAux1 - 1);
   // params com &
   sAux2 := Copy(ParamsURI, pAux1 + 1, Length(ParamsURI));
   cAux1 := 0;
   While (sAux1 <> '') Do
    Begin
     pAux1 := Pos('/', sAux1);
     If pAux1 = 0 Then
      pAux1 := Length(sAux1) + 1;
     lst.Add(IntToStr(cAux1) + '=' + Copy(sAux1, 1, pAux1 - 1));
     cAux1 := cAux1 + 1;
     Delete(sAux1, 1, pAux1);
    End;
   While (sAux2 <> '') Do
    Begin
     pAux1 := Pos('&', sAux2);
     If pAux1 = 0 then
      pAux1 := Length(sAux2) + 1;
     sAux1 := Copy(sAux2, 1, pAux1 - 1);
     If Pos('dwmark:', sAux1) = 0 then
      lst.Add(sAux1);
     Delete(sAux2, 1, pAux1);
    End;
   While lst.Count > 0 Do
    Begin
     JSONParam  := Params.ItemsString[lst.Names[0]];
     If JSONParam = Nil Then
      Begin
       JSONParam := TJSONParam.Create(Params.Encoding);
       JSONParam.ParamName := lst.Names[0];
       JSONParam.ObjectDirection := odIN;
       JSONParam.SetValue(lst.ValueFromIndex[0]);
       Params.Add(JSONParam);
      End
     Else If JSONParam.IsNull Then
      JSONParam.SetValue(lst.ValueFromIndex[0]);
     lst.Delete(0);
    End;
  Finally
   FreeAndNil(lst);
  End;
 End;
 Procedure CopyParams(SourceParams : TRESTDWParamsMethods);
 Var
  isrc       : Integer;
  vTempParam : TJSONParam;
 Begin
  For isrc := 0 To SourceParams.Count -1 Do
   Begin
    If SourceParams.Items[isrc].ObjectDirection in [odIN, odINOUT] Then
     Begin
      If Params.ItemsString[SourceParams.Items[isrc].ParamName] = Nil Then
       Begin
        vTempParam := TJSONParam.Create(Params.Encoding);
        vTempParam.CopyFrom(SourceParams.Items[isrc]);
        Params.Add(vTempParam);
       End;
     End;
   End;
 End;
 Procedure ParseURL;
 Begin
  vPosQuery := Pos('?', URL);
  vIsQuery  := vPosQuery > 0;
  ParamsURI := '';
  If vIsQuery Then
   Begin
    ParamsURI := Copy(URL, vPosQuery + 1, Length(URL));
    URL := Copy(URL, 1, vPosQuery - 1);
   End;
  // url igual http://localhost:8082/usuarios//?var=teste
  While (URL <> '')       And
        (URL[Length(URL)] In ['/', '?']) Do
   Delete(URL, Length(URL), 1);
  // url http://localhost:8082/usuarios//login//?var=teste
  While (Pos('//', URL) > 0) Do
   Delete(URL, Pos('//', URL), 1);
  // ParamsURI = /?teste=1
  While (ParamsURI <> '')      And
        (ParamsURI[InitStrPos] In ['/', '?']) Do
   Delete(ParamsURI, InitStrPos, 1);
  If URL = '' Then
   URL := '/';
 End;
Begin
 Result   := False;
 If Length(URL) = 0 Then
  Exit;
 ParseURL;
 vTempValue := URL;
 For I := 0 To ComponentCount -1 Do
  Begin
   If (Components[i] Is TRESTDWServerEvents) Then
    Begin
     For A := 0 To TRESTDWServerEvents(Components[I]).Events.Count -1 Do
      Begin
       vTempRoute := TRESTDWServerEvents(Components[I]).Events[A].BaseURL   +
                     TRESTDWServerEvents(Components[I]).Events[A].EventName;
       If ((vTempValue = '/') or (vTempValue = '')) Then
        Begin
         If TRESTDWServerEvents(Components[I]).DefaultEvent <> '' Then
          Begin
           vTempValue := TRESTDWServerEvents(Components[I]).DefaultEvent;
           If vTempValue[InitStrPos] <> '/' Then
            vTempValue :=  '/' + vTempValue;
          End;
        End;
       If SameText(vTempRoute, vTempValue) Then
        Begin
         Result         := True;
         vTempURL       := vTempRoute;
         vTempParamsURI := '';
         vParamMethods  := TRESTDWServerEvents(Components[I]).Events[A].Params;
         BuildCORS(TRESTDWServerEvents(Components[I]).Events[A].Routes, CORS_CustomHeaders);
         Break;
        End
       Else If SameText(vTempRoute + '/', Copy(vTempValue + '/', InitStrPos, Length(vTempRoute + '/') - FinalStrPos)) Then
        Begin
         Result         := True;
         vTempURL       := vTempRoute;
         vTempParamsURI := Copy(vTempValue, Length(vTempRoute) + 2, Length(vTempValue));
         vParamMethods  := TRESTDWServerEvents(Components[I]).Events[A].Params;
         BuildCORS(TRESTDWServerEvents(Components[I]).Events[A].Routes, CORS_CustomHeaders);
        End;
      End;
    End
   Else If (Components[i] Is TRESTDWServerContext) Then
    Begin
     For A := 0 To TRESTDWServerContext(Components[I]).ContextList.Count - 1 Do
      Begin
       vTempRoute := TRESTDWServerContext(Components[I]).ContextList[A].BaseURL   +
                     TRESTDWServerContext(Components[I]).ContextList[A].ContextName;
       If SameText(vTempRoute, vTempValue) Then
        Begin
         Result         := True;
         vTempURL       := vTempRoute;
         vTempParamsURI := '';
         vParamMethods  := TRESTDWServerContext(Components[I]).ContextList[A].Params;
         BuildCORS(TRESTDWServerContext(Components[I]).ContextList[A].Routes, CORS_CustomHeaders);
         Break;
        End
       Else If SameText(vTempRoute+'/', Copy(vTempValue+'/', 1, Length(vTempRoute+'/'))) Then
        Begin
         Result         := True;
         vTempURL       := vTempRoute;
         vTempParamsURI := Copy(vTempValue, Length(vTempRoute) + 2, Length(vTempValue));
         vParamMethods  := TRESTDWServerContext(Components[I]).ContextList[A].Params;
         BuildCORS(TRESTDWServerContext(Components[I]).ContextList[A].Routes, CORS_CustomHeaders);
        End;
      End;
     End;
   If Result Then
    Begin
     CopyParams(vParamMethods);
     URL       := vTempURL;
     ParamsURI := '?' + ParamsURI;
     ParamsURI := vTempParamsURI + ParamsURI;
     ParseParams;
     Break;
    End;
  End;
 If (Not Result)  And
    ((URL = '')   Or
     (URL = '/')) Then
  URL := '';
End;

Procedure TServerMethodDataModule.SetClientInfo(ip,
                                                UserAgent,
                                                BaseRequest   : String;
                                                port          : Integer);
Begin
 vRESTDWClientInfo.SetClientInfo(Trim(ip), Trim(UserAgent), BaseRequest, Port);
End;

Constructor TServerMethodDataModule.Create(Sender: TComponent);
Begin
 Inherited Create(Sender);
 vRESTDWClientInfo     := TRESTDWClientInfo.Create;
 vClientWelcomeMessage := '';
 vServerAuthOptions    := Nil;
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  Encoding := esUtf8;
 {$ELSE}
  Encoding := esAscii;
 {$IFEND}
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
 vBaseRequest := '';
End;

Procedure TRESTDWClientInfo.SetClientInfo(ip,
                                          UserAgent,
                                          BaseRequest : String;
                                          port        : Integer);
Begin
 vip          := Trim(ip);
 vUserAgent   := Trim(UserAgent);
 vport        := Port;
 vBaseRequest := BaseRequest;
End;

End.

