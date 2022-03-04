unit uRESTDWProcessThread;

{$I uRESTDW.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.
 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
}

Interface

Uses
 {$IFDEF FPC}
 SysUtils,          Classes,      ServerUtils, {$IFDEF WINDOWS}Windows, {$ENDIF}
 IdContext,         IdTCPClient,  IdComponent,       IdBaseComponent,     uDWConsts,
 uDWConstsData,                   IdMessageCoder,    IdHashMessageDigest, IdHash, IdMessage, uDWJSON,
 IdHeaderList,                    uDWJSONObject,     IdGlobal,            IdGlobalProtocols,
 uSystemEvents, uDWConstsCharset, IdSSLOpenSSL,      IdHTTPHeaderInfo,    uRESTDWBase, syncobjs, uDWAbout;
 {$ELSE}
  IdSSLOpenSSL, IdHTTPHeaderInfo, uRESTDWBase,
  {$IF Defined(HAS_FMX)}FMX.Forms{$ELSE}{$IF CompilerVersion <= 22}Forms{$ELSE}VCL.Forms{$IFEND}{$IFEND},
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, EncdDecd, IdComponent, SyncObjs, IdBaseComponent, IdTCPClient, IdTCPConnection,
   IdHeaderList, IdHashMessageDigest, IdMessageCoderMIME, Windows,
   IdMessage, IdGlobalProtocols,     uDWConsts, uDWConstsData, uDWJSONObject, uDWConstsCharset, 
   IdHash, IdStack, uDWAbout, ServerUtils, IdGlobal;
  {$ELSE}
   System.SysUtils, System.Classes, system.SyncObjs, IdHashMessageDigest, IdHash, IdHeaderList,
   ServerUtils, uDWAbout, IdStack, uDWConstsCharset, IdContext, IdExceptionCore,
   {$IFDEF MSWINDOWS} Windows, {$ENDIF}
   uDWConsts, uDWConstsData,       IdTCPClient,
   {$IF Defined(HAS_FMX)} System.IOUtils, System.json,{$ELSE} uDWJSON,{$IFEND}IdSSL,
   IdComponent, IdBaseComponent, IdTCPConnection, uDWJSONObject,
   uSystemEvents, IdMessageCoderMIME,    IdMessage, IdGlobalProtocols,     IdGlobal;
  {$IFEND}
 {$ENDIF}

Const
 TReceiveTimeThread = 3;

Type
 TOnBeforeConnect     = Procedure (Sender           : TObject) Of Object;
 TOnConnect           = Procedure (Sender           : TObject) Of Object;
 TOnDisconnect        = Procedure (Sender           : TObject) Of Object;
 TOnReceiveCommand    = Procedure (aCmd             : String) Of Object;
 TOnReceiveMessage    = Procedure (Username         : String;
                                   aMessage         : String;
                                   Var Accept       : Boolean;
                                   Var ErrorMessage : String)  Of Object;
 TOnReceiveStream     = Procedure (Username         : String;
                                   Const aStream    : TStream;
                                   Var Accept       : Boolean;
                                   Var ErrorMessage : String)  Of Object;
 TOnReceiveFileStream = Procedure (Username         : String;
                                   Const Filename   : String;
                                   Const aStream    : TStream;
                                   Var Accept       : Boolean;
                                   Var ErrorMessage : String)  Of Object;

Type
 TRESTDwProcessDataThread = Class(TThread)
 Protected
  vSelf                : TComponent;
  vStreamMessage       : TMemoryStream;
  vDirection,
  vTagStream,
  vMessage             : String;
  vEvent               : TEvent;
  vNewConnect,
  vKill                : Boolean;
  aSizeStream          : DWInt64;
  vTcpClient           : TIdTCPClient;
  vOnReceiveMessage    : TOnReceiveMessage;
  vOnReceiveStream     : TOnReceiveStream;
  vOnReceiveFileStream : TOnReceiveFileStream;
  vOnBeforeConnect     : TOnBeforeConnect;
  vOnConnect           : TOnConnect;
  vOnDisconnect        : TOnDisconnect;
  vOnReceiveCommand    : TOnReceiveCommand;
  {$IFNDEF FPC}
   {$IF (DEFINED(OLDINDY))}
    vDataEncoding   : TIdTextEncoding;
   {$ELSE}
    vDataEncoding   : IIdTextEncoding;
   {$IFEND}
  {$ELSE}
   vDataEncoding    : IIdTextEncoding;
  {$ENDIF}
  Procedure Kill;
  Procedure ProcessMessages;
  Procedure Execute; Override;
 Private
 Public
  Procedure   SendMessage(aMessage       : String);
  Procedure   SendStream (TagStream,
                          Direction      : String;
                          Const aStream  : TStream);
  Destructor  Destroy; Override;
  Constructor Create(aSelf               : TComponent;
                     TcpClient           : TIdTCPClient;
                     OnReceiveMessage    : TOnReceiveMessage;
                     OnReceiveStream     : TOnReceiveStream;
                     OnReceiveFileStream : TOnReceiveFileStream;
                     OnBeforeConnect     : TOnBeforeConnect;
                     OnConnect           : TOnConnect;
                     OnDisconnect        : TOnDisconnect;
                     OnReceiveCommand    : TOnReceiveCommand;
                     Encode              : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}TIdTextEncoding
                                           {$ELSE}IIdTextEncoding{$IFEND}{$ELSE}IIdTextEncoding{$ENDIF});
  Property    StringCharset              : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}TIdTextEncoding
                                           {$ELSE}IIdTextEncoding{$IFEND}{$ELSE}IIdTextEncoding{$ENDIF} Read vDataEncoding Write vDataEncoding;
End;


Type
 TRESTDwProcessData = Class(TComponent)
 Private
  aSelf                : TComponent;
  vProcessReceiveData  : TRESTDwProcessDataThread;
  vActive              : Boolean;
  vTcpClient           : TIdTCPClient;
  vOnReceiveMessage    : TOnReceiveMessage;
  vOnReceiveStream     : TOnReceiveStream;
  vOnReceiveFileStream : TOnReceiveFileStream;
  vOnBeforeConnect     : TOnBeforeConnect;
  vOnConnect           : TOnConnect;
  vOnDisconnect        : TOnDisconnect;
  vOnReceiveCommand    : TOnReceiveCommand;
  {$IFNDEF FPC}
   {$IF (DEFINED(OLDINDY))}
    vDataEncoding     : TIdTextEncoding;
   {$ELSE}
    vDataEncoding     : IIdTextEncoding;
   {$IFEND}
  {$ELSE}
   vDataEncoding      : IIdTextEncoding;
  {$ENDIF}
  Procedure   SetActive  (Value    : Boolean);
  Procedure   RenameConnection(ConnectionName : String);
 Public
  Procedure   SendMessage     (aMessage       : String);    Overload;
  Procedure   SendMessage     (aUser,
                               aMessage       : String);    Overload;
  Procedure   SendStream      (aUser          : String;
                               Const aStream  : TStream);   Overload;
  Procedure   SendStream      (Const aStream  : TStream);   Overload;
  Constructor Create          (AOwner         : TComponent);Override;
  Destructor  Destroy;                                      Override;
  Property    TcpClient             : TIdTCPClient               Read vTcpClient               Write vTcpClient;
  Property    OnReceiveMessage      : TOnReceiveMessage          Read vOnReceiveMessage        Write vOnReceiveMessage;
  Property    OnReceiveStream       : TOnReceiveStream           Read vOnReceiveStream         Write vOnReceiveStream;
  Property    OnReceiveFileStream   : TOnReceiveFileStream       Read vOnReceiveFileStream     Write vOnReceiveFileStream;
  Property    OnBeforeConnect       : TOnBeforeConnect           Read vOnBeforeConnect         Write vOnBeforeConnect;
  Property    OnConnect             : TOnConnect                 Read vOnConnect               Write vOnConnect;
  Property    OnDisconnect          : TOnDisconnect              Read vOnDisconnect            Write vOnDisconnect;
  Property    OnReceiveCommand      : TOnReceiveCommand          Read vOnReceiveCommand        Write vOnReceiveCommand;
  Property    StringCharset         : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}TIdTextEncoding
                                      {$ELSE}IIdTextEncoding{$IFEND}{$ELSE}IIdTextEncoding{$ENDIF}
                                                                 Read vDataEncoding            Write vDataEncoding;
  Property    Active                : Boolean                    Read vActive                  Write SetActive;
End;

Type
 TRESTDWClientNotification = Class(TDWComponent) //Novo Componente de Acesso Socket para o RESTDataware
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  TcpRequest           : TIdTCPClient;
  LHandler             : TIdSSLIOHandlerSocketOpenSSL;
  vCripto              : TCripto;
 Private
  //Variáveis, Procedures e Funções Privadas
  vEncoding            : TEncodeSelect;
  vAcceptUserMessage,
  vAcceptStream,
  vAcceptFileStream,
  vActive              : Boolean;
  vRejectUserText,
  vRejectStreamText,
  vRejectFileStreamText,
  vAccessTag,
  vWelcomeMessage,
  vConnectionName,
  vHost                : String;
  vPort                : Integer;
  vTransparentProxy    : TIdProxyConnectionInfo;
  vRequestTimeOut      : Integer;
  vConnectTimeOut      : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  vFailOverConnections : TFailOverConnections;
  vAuthOptionParams    : TRDWClientAuthOptionParams;
  ProcessData          : TRESTDwProcessData;
  vOnReceiveMessage    : TOnReceiveMessage;
  vOnReceiveStream     : TOnReceiveStream;
  vOnReceiveFileStream : TOnReceiveFileStream;
  vOnBeforeConnect     : TOnBeforeConnect;
  vOnConnect           : TOnConnect;
  vOnDisconnect        : TOnDisconnect;
  Procedure  SetActive        (Value    : Boolean);
  Procedure  RenameConnection (Value    : String);
  Procedure  SetConnectionName(Value    : String);
  Procedure  ReceiveCommand   (Value    : String);
 Public
  //Métodos, Propriedades, Variáveis, Procedures e Funções Publicas
  Procedure   SetAuthOptionParams(Value     : TRDWClientAuthOptionParams);
  Constructor Create             (AOwner    : TComponent);Override;
  Destructor  Destroy;Override;
  Procedure   Connect;
  Procedure   Disconnect;
  Procedure   SendMessage(Value            : String);Overload;
  Procedure   SendMessage(aUser, Value     : String);Overload;
  Procedure   SendStream (aUser          : String;
                          Const aStream  : TStream); Overload;
  Procedure   SendStream (Const aStream  : TStream); Overload;
 Published
  //Métodos e Propriedades
  Property Active                  : Boolean                    Read vActive                  Write SetActive;
  Property AcceptUserMessage       : Boolean                    Read vAcceptUserMessage       Write vAcceptUserMessage;
  Property RejectUserMessageText   : String                     Read vRejectUserText          Write vRejectUserText;
  Property AcceptStream            : Boolean                    Read vAcceptStream            Write vAcceptStream;
  Property RejectStreamText        : String                     Read vRejectStreamText        Write vRejectStreamText;
  Property AcceptFileStream        : Boolean                    Read vAcceptFileStream        Write vAcceptFileStream;
  Property RejectFileStreamText    : String                     Read vRejectFileStreamText    Write vRejectFileStreamText;
  Property Host                    : String                     Read vHost                    Write vHost;
  Property Port                    : Integer                    Read vPort                    Write vPort   Default 9092;
  Property ConnectionName          : String                     Read vConnectionName          Write SetConnectionName;
  Property AuthenticationOptions   : TRDWClientAuthOptionParams Read vAuthOptionParams        Write SetAuthOptionParams;
  Property ProxyOptions            : TIdProxyConnectionInfo     Read vTransparentProxy        Write vTransparentProxy;
  Property RequestTimeOut          : Integer                    Read vRequestTimeOut          Write vRequestTimeOut;
  Property ConnectTimeOut          : Integer                    Read vConnectTimeOut          Write vConnectTimeOut;
  Property WelcomeMessage          : String                     Read vWelcomeMessage          Write vWelcomeMessage;
  Property AccessTag               : String                     Read vAccessTag               Write vAccessTag;
  Property Encoding                : TEncodeSelect              Read vEncoding                Write vEncoding;          //Encoding da string
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet           Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
  Property OnReceiveMessage        : TOnReceiveMessage          Read vOnReceiveMessage        Write vOnReceiveMessage;
  Property OnReceiveStream         : TOnReceiveStream           Read vOnReceiveStream         Write vOnReceiveStream;
  Property OnReceiveFileStream     : TOnReceiveFileStream       Read vOnReceiveFileStream     Write vOnReceiveFileStream;
  Property OnBeforeConnect         : TOnBeforeConnect           Read vOnBeforeConnect         Write vOnBeforeConnect;
  Property OnConnect               : TOnConnect                 Read vOnConnect               Write vOnConnect;
  Property OnDisconnect            : TOnDisconnect              Read vOnDisconnect            Write vOnDisconnect;
End;

Implementation

Procedure TRESTDWClientNotification.Connect;
Begin
 SetActive(True);
End;

Constructor TRESTDWClientNotification.Create(AOwner : TComponent);
Begin
 Inherited;
 TcpRequest                            := TIdTCPClient.Create(Nil);
 vCripto                               := TCripto.Create;
 vTransparentProxy                     := TIdProxyConnectionInfo.Create;
 vHost                                 := 'localhost';
 vPort                                 := 9092;
 vAuthOptionParams                     := TRDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   vEncoding         := esUtf8;
  {$ELSE}
   vEncoding         := esAscii;
  {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
  vDatabaseCharSet  := csUndefined;
 {$ENDIF}
 vRequestTimeOut                       := 10000;
 vConnectTimeOut                       := 3000;
 ProcessData                           := TRESTDwProcessData.Create(Self);
 ProcessData.OnReceiveMessage          := vOnReceiveMessage;
 ProcessData.OnReceiveStream           := vOnReceiveStream;
 ProcessData.OnReceiveFileStream       := vOnReceiveFileStream;
 {$IFDEF FPC}
 vDatabaseCharSet                      := csUndefined;
 ProcessData.OnReceiveCommand          := @ReceiveCommand;
 {$ELSE}
 ProcessData.OnReceiveCommand          := ReceiveCommand;
 {$ENDIF}
 vFailOverConnections                  := TFailOverConnections.Create(Self, TRESTDWConnectionServerCP);
 vActive                               := False;
 vAcceptUserMessage                    := True;
 vRejectUserText                       := '';
 vAcceptStream                         := True;
 vRejectStreamText                     := '';;
 vAcceptFileStream                     := True;
 vRejectFileStreamText                 := '';
 vConnectionName                       := '';
End;

Destructor TRESTDWClientNotification.Destroy;
Begin
 Try
  If TcpRequest.Connected Then
   TcpRequest.Disconnect;
 Except
 End;
 ProcessData.Active := False;
 If Assigned(LHandler) then
  FreeAndNil(LHandler);
 FreeAndNil(TcpRequest);
 FreeAndNil(ProcessData);
 FreeAndNil(vTransparentProxy);
 FreeAndNil(vFailOverConnections);
 FreeAndNil(vCripto);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Procedure TRESTDWClientNotification.Disconnect;
Begin
 SetActive(False);
End;

Procedure TRESTDWClientNotification.ReceiveCommand(Value : String);
Begin

End;

Procedure TRESTDWClientNotification.RenameConnection(Value : String);
Begin
 ProcessData.RenameConnection(Value);
End;

Procedure TRESTDWClientNotification.SendMessage(Value : String);
Begin
 ProcessData.SendMessage(Value);
End;

Procedure TRESTDWClientNotification.SendMessage(aUser,
                                                Value     : String);
Begin
 ProcessData.SendMessage(aUser, Value);
End;

Procedure TRESTDWClientNotification.SendStream (aUser          : String;
                                                Const aStream  : TStream);
Begin
 ProcessData.SendStream(aUser, aStream);
End;

Procedure TRESTDWClientNotification.SendStream (Const aStream  : TStream);
Begin
 ProcessData.SendStream(aStream);
End;

Procedure TRESTDWClientNotification.SetActive(Value : Boolean);
Begin
 Try
  If (Value) And (Not(TcpRequest.Connected)) Then
   Begin
    If Assigned(vOnBeforeConnect) Then
     vOnBeforeConnect(Self);
    vConnectionName                 := '';
    TcpRequest.Port                 := vPort;
    TcpRequest.Host                 := vHost;
    ProcessData.OnReceiveMessage    := vOnReceiveMessage;
    ProcessData.OnReceiveStream     := vOnReceiveStream;
    ProcessData.OnReceiveFileStream := vOnReceiveFileStream;
    ProcessData.OnBeforeConnect     := vOnBeforeConnect;
    ProcessData.OnConnect           := vOnConnect;
    ProcessData.OnDisconnect        := vOnDisconnect;
    ProcessData.TcpClient           := TcpRequest;
    If vEncoding = esUtf8 Then
     ProcessData.StringCharset      := IndyTextEncoding_UTF8
    Else
     ProcessData.StringCharset      := IndyTextEncoding_ASCII;
    TcpRequest.Connect;
    ProcessData.Active              := TcpRequest.Connected;
   End
  Else If (Not(Value) And (TcpRequest.Connected)) Then
   TcpRequest.Disconnect;
 Except
  On E : Exception Do
   Raise Exception.Create(E.Message);
 End;
 vActive         := TcpRequest.Connected;
End;

Procedure TRESTDWClientNotification.SetAuthOptionParams(Value : TRDWClientAuthOptionParams);
Begin
 vAuthOptionParams.Assign(Value);
End;

Procedure TRESTDWClientNotification.SetConnectionName(Value : String);
Begin
 If (Trim(Value)          <> '') And
    (vConnectionName      <> '') Then
  Begin
   vConnectionName := '';
   RenameConnection(Value);
  End
 Else If (Trim(Value)     <> '') And
         (vConnectionName  = '') Then
  vConnectionName := Value;
End;

Constructor TRESTDwProcessDataThread.Create(aSelf               : TComponent;
                                            TcpClient           : TIdTCPClient;
                                            OnReceiveMessage    : TOnReceiveMessage;
                                            OnReceiveStream     : TOnReceiveStream;
                                            OnReceiveFileStream : TOnReceiveFileStream;
                                            OnBeforeConnect     : TOnBeforeConnect;
                                            OnConnect           : TOnConnect;
                                            OnDisconnect        : TOnDisconnect;
                                            OnReceiveCommand    : TOnReceiveCommand;
                                            Encode              : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}TIdTextEncoding
                                                                  {$ELSE}IIdTextEncoding{$IFEND}{$ELSE}IIdTextEncoding{$ENDIF});
Begin
 Inherited Create(False);
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Not Defined(HAS_UTF8)}
    vEvent            := TEvent.Create(Nil, True, False, 'DataRec');
   {$IFEND}
  {$ELSE}
   vEvent             := TEvent.Create(Nil, True, False, 'DataRec');
  {$IFEND}
 {$ENDIF}
 vTcpClient           := TcpClient;
 vOnReceiveMessage    := OnReceiveMessage;
 vOnReceiveStream     := OnReceiveStream;
 vOnReceiveFileStream := OnReceiveFileStream;
 vOnBeforeConnect     := OnBeforeConnect;
 vOnConnect           := OnConnect;
 vOnDisconnect        := OnDisconnect;
 vOnReceiveCommand    := OnReceiveCommand;
 vDataEncoding        := Encode;
 vStreamMessage       := TMemoryStream.Create;
 vDirection           := '';
 vTagStream           := '';
 aSizeStream          := 0;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Not Defined(HAS_UTF8)}
    Priority          := tpLowest;
   {$IFEND}
  {$ELSE}
   Priority           := tpLowest;
  {$IFEND}
 {$ENDIF}
 vSelf                := aSelf;
 vNewConnect          := True;
end;

Destructor TRESTDwProcessDataThread.Destroy;
Begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Not Defined(HAS_UTF8)}
    FreeAndNil(vEvent);
   {$IFEND}
  {$ELSE}
   FreeAndNil(vEvent);
  {$IFEND}
 {$ENDIF}
 FreeAndNil(vStreamMessage);
 Inherited;
End;

Procedure TRESTDwProcessDataThread.Execute;
Var
 vUsername,
 vErrorMessage,
 vTempMessage   : String;
 vDataString    : DWString;
 vSizeFile      : DWInt64;
 aBuf           : TIdBytes;
 vAccept        : Boolean;
 aStream        : TMemoryStream;
 Procedure ReceiveStreamClient;
 Var
  aBuf  : TIdBytes;
  aSize,
  bSize : DWInt64;
 Begin
  SetLength(aBuf, 0);
  vTcpClient.IOHandler.ReadTimeout := -1;
  vTcpClient.IOHandler.ReadBytes(aBuf, SizeOf(DWInt64));
  aSize := PDWInt64(@aBuf[0])^;
  bSize := 0;
  While (aSize > bSize) Do
   Begin
    SetLength(aBuf, 0);
    vTcpClient.IOHandler.ReadBytes(aBuf, aSize);
    aStream.Write(aBuf[0], Length(aBuf));
    bSize := aStream.Size;
   End;
  SetLength(aBuf, 0);
  aStream.Position := 0;
 End;
 Function InternalCommand(Value : String) : Boolean;
 Var
  aSize    : DWInt64;
  oldConn,
  aValue   : String;
 Begin
  Result := False;
  If Pos(Format(TTagParams, [cConnectionRename]), Value) > 0 Then
   Begin
    Result  := True;
    aValue  := StringReplace(Value, Format(TTagParams, [cConnectionRename]), '', [rfReplaceAll]);
    oldConn := Trim(TRESTDWClientNotification(vSelf).ConnectionName);
    TRESTDWClientNotification(vSelf).ConnectionName   := aValue;
    If vNewConnect Then
     Begin
      vNewConnect := False;
      If Assigned(vOnConnect)  And
        (vTcpClient.Connected) Then
       vOnConnect(vSelf);
     End;
   End
  Else If (Pos(Format(TTagParams, [cServerMessage]), Value) > 0) Then
   Begin
    aValue  := StringReplace(Value, Format(TTagParams, [cServerMessage]), '', [rfReplaceAll]);
    If Assigned(vOnReceiveMessage) Then
     vOnReceiveMessage(vUsername, aValue, vAccept, vErrorMessage);
   End
  Else If (Pos(Format(TTagParams, [cUserMessage]), Value) > 0) Then
   Begin
    aValue  := StringReplace(Value, Format(TTagParams, [cUserMessage]), '', [rfReplaceAll]);
    If Assigned(vOnReceiveMessage) Then
     vOnReceiveMessage(vUsername, aValue, vAccept, vErrorMessage);
   End
  Else If (Pos(Format(TTagParams, [cServerStream]), Value) > 0) Then
   Begin
    vUsername  := StringReplace(Value, Format(TTagParams, [cServerStream]), '', [rfReplaceAll]);
    aStream    := TMemoryStream.Create;
    Try
     ReceiveStreamClient;
     If Assigned(vOnReceiveStream) Then
      vOnReceiveStream(vUsername, aStream, vAccept, vErrorMessage);
    Finally
     FreeAndNil(aStream);
    End;
   End
  Else If (Pos(Format(TTagParams, [cUserStream]), Value) > 0) Then
   Begin
    vUsername  := StringReplace(Value, Format(TTagParams, [cUserStream]), '', [rfReplaceAll]);
    aStream    := TMemoryStream.Create;
    Try
     ReceiveStreamClient;
     If Assigned(vOnReceiveStream) Then
      vOnReceiveStream(vUsername, aStream, vAccept, vErrorMessage);
    Finally
     FreeAndNil(aStream);
    End;
   End;
 End;
Begin
 {$IFNDEF FPC}
  Inherited;
  {$IF (DEFINED(OLDINDY))}
   vDataEncoding := enDefault;
  {$ELSE}
   vDataEncoding := IndyTextEncoding_UTF8;
  {$IFEND}
 {$ELSE}
  vDataEncoding  := IndyTextEncoding_UTF8;
 {$ENDIF};
 vUsername       := '';
 vMessage        := '';
 vErrorMessage   := '';
 vAccept         := True;
 If Assigned(vTcpClient) Then
  Begin
   While (Not(vKill)             And
          (vTcpClient.Connected) And
          Not(Terminated))       Do
    Begin
     ProcessMessages; 
     If (vMessage <> '') Then //Send Message
      Begin
       vTempMessage := vMessage;
       vMessage     := '';
       aBuf         := ToBytes(vTempMessage, vDataEncoding);
       vTempMessage := '';
       vTcpClient.IOHandler.WriteDirect(aBuf);
       SetLength(aBuf, 0);
       ProcessMessages;
      End;
     If (vStreamMessage.Size > 0)           And
        (vStreamMessage.Size = aSizeStream) Then //Send Stream
      Begin
       aSizeStream          := 0;
       aBuf                 := ToBytes(Format(TTagParams, [vTagStream]) + vDirection, vDataEncoding);
       vTcpClient.IOHandler.ReadTimeout := -1;
       vTcpClient.IOHandler.Write(aBuf);
       vTcpClient.IOHandler.WriteBufferFlush;
       ProcessMessages;
       SetLength(aBuf, 0);
       SetLength(aBuf, vStreamMessage.Size);
       vStreamMessage.Position := 0;
       vStreamMessage.Read(Pointer(aBuf)^, Length(aBuf));
       vStreamMessage.Clear;
       vSizeFile := Length(aBuf);
       vTcpClient.IOHandler.Write(ToBytes(vSizeFile), SizeOf(DWInt64)); // ToBytes(IntToStr(), vDataEncoding));
       vTcpClient.IOHandler.WriteBufferFlush;
       vTcpClient.IOHandler.Write(aBuf);
       vTcpClient.IOHandler.WriteBufferFlush;
       vDirection := '';
       SetLength(aBuf, 0);
      End;
     If vTcpClient.IOHandler.InputBuffer.Size > 0 Then //Receive Data
      Begin
       vTcpClient.IOHandler.InputBuffer.ExtractToBytes(aBuf);
       vTcpClient.IOHandler.InputBuffer.Clear;
       If Length(aBuf) > 0 Then
        Begin
         If Not(Length(aBuf) = 0) Then
          Begin
           {$IFDEF FPC}
            vDataString := BytesArrToString(aBuf);
            vDataString := utf8decode(vDataString);
           {$ELSE}
            {$IF CompilerVersion > 25} // Delphi 2010 pra cima
             vDataString := BytesToString(aBuf, vDataEncoding);
            {$ELSE}
             vDataString := BytesArrToString(aBuf);
             vDataString := utf8decode(vDataString);
            {$IFEND}
           {$ENDIF}
           SetLength(aBuf, 0);
           InternalCommand(vDataString);
          End;
        End;
      End;
     ProcessMessages;
     {$IFNDEF FPC}
      {$IF Defined(HAS_FMX)}
       {$IF Not Defined(HAS_UTF8)}
        vEvent.WaitFor(TReceiveTimeThread);
       {$IFEND}
      {$ELSE}
       vEvent.WaitFor(TReceiveTimeThread);
      {$IFEND}
     {$ENDIF}
    End;
  End;
 If Assigned(vOnDisconnect) Then
  vOnDisconnect(vSelf);
End;

Procedure TRESTDwProcessDataThread.Kill;
Begin
 vKill := True;
 Terminate;
End;

Procedure TRESTDwProcessDataThread.ProcessMessages;
Begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}{$IF Not Defined(HAS_UTF8)}FMX.Forms.TApplication.ProcessMessages;{$IFEND}
  {$ELSE}Application.Processmessages;{$IFEND}
 {$ENDIF}
End;

Procedure TRESTDwProcessDataThread.SendStream (TagStream,
                                               Direction     : String;
                                               Const aStream : TStream);
Begin
 vTagStream  := TagStream;
 vDirection  := Direction;
 aSizeStream := aStream.Size;
 vStreamMessage.Clear;
 vStreamMessage.CopyFrom(aStream, aStream.Size);
End;

Procedure TRESTDwProcessDataThread.SendMessage(aMessage : String);
Begin
 vMessage := aMessage;
End;

Constructor TRESTDwProcessData.Create(AOwner : TComponent);
Begin
 Inherited;
 aSelf               := AOwner;
 vTcpClient          := Nil;
 vProcessReceiveData := Nil;
End;

Destructor TRESTDwProcessData.Destroy;
Begin
 SetActive(False);
 Inherited;
End;

Procedure TRESTDwProcessData.RenameConnection(ConnectionName : String);
Begin
 If Assigned(vProcessReceiveData) Then
  vProcessReceiveData.SendMessage(Format(TTagParams, [cConnectionRename]) + ConnectionName);
End;

Procedure TRESTDwProcessData.SendStream (aUser          : String;
                                         Const aStream  : TStream);
Begin
 If Assigned(vProcessReceiveData) Then
  vProcessReceiveData.SendStream(cUserStream, aUser, aStream);
End;

Procedure TRESTDwProcessData.SendStream (Const aStream  : TStream);
Begin
 If Assigned(vProcessReceiveData) Then
  vProcessReceiveData.SendStream(cServerStream, '', aStream);
End;

Procedure TRESTDwProcessData.SendMessage(aMessage : String);
Begin
 If Assigned(vProcessReceiveData) Then
  vProcessReceiveData.SendMessage(Format(TTagParams, [cServerMessage]) + aMessage);
End;

Procedure TRESTDwProcessData.SendMessage(aUser, aMessage  : String);
Begin
 If Assigned(vProcessReceiveData) Then
  vProcessReceiveData.SendMessage(Format(TTagParams, [cUserMessage]) + aUser + ';' + aMessage);
End;

Procedure TRESTDwProcessData.SetActive(Value : Boolean);
Begin
 If Assigned(vProcessReceiveData) Then
  Begin
   Try
    vProcessReceiveData.Kill;
   Except
   End;
   {$IFDEF FPC}
    WaitForThreadTerminate(vProcessReceiveData.Handle, 100);
   {$ELSE}
    {$IF Not Defined(HAS_FMX)}
     WaitForSingleObject   (vProcessReceiveData.Handle, 100);
    {$IFEND}
   {$ENDIF}
   vProcessReceiveData := Nil;
   FreeAndNil(vProcessReceiveData);
   vActive := False;
  End;
 If (Value) Then
  Begin
   Try
    vProcessReceiveData := TRESTDwProcessDataThread.Create(aSelf,
                                                           vTcpClient,
                                                           vOnReceiveMessage,
                                                           vOnReceiveStream,
                                                           vOnReceiveFileStream,
                                                           vOnBeforeConnect,
                                                           vOnConnect,
                                                           vOnDisconnect,
                                                           vOnReceiveCommand,
                                                           StringCharset);
    vProcessReceiveData.Resume;
    vActive := Value;
   Except
   End;
  End;
End;

end.
