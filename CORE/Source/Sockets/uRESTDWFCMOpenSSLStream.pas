Unit uRESTDWFCMOpenSSLStream;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMTransport;

Type
  TRESTDWFCMOpenSSLStreamTransport = Class(TRESTDWFCMStreamTransport)
  Private
    FContext   : Pointer;
    FBIO       : Pointer;
    FConnected : Boolean;
    FVerifyPeer : Boolean;
    FCAFile     : String;
    FCAPath     : String;

    Procedure ReleaseHandles;
  Public
    Constructor Create;
    Destructor Destroy; Override;

    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Override;

    Procedure Connect(Const AHost : String;
                      APort       : Integer); Override;
    Procedure Disconnect; Override;
    Function Connected : Boolean; Override;
    Function ReadByte : Byte; Override;
    Procedure ReadBuffer(Var ABuffer; ACount : Integer); Override;
    Procedure WriteBuffer(Const ABuffer; ACount : Integer); Override;
  End;

Implementation

Uses
  uRESTDWOpenSslLib,
  uRESTDWFCMCompat,
  uRESTDWFCMTLS;

Constructor TRESTDWFCMOpenSSLStreamTransport.Create;
Begin
  Inherited Create;
  FContext := Nil;
  FBIO := Nil;
  FConnected := False;
  FVerifyPeer := True;
  FCAFile := '';
  FCAPath := '';
End;

Procedure TRESTDWFCMOpenSSLStreamTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                                        Const ACAFile,
                                                              ACAPath : String);
Begin
  FVerifyPeer := AVerifyPeer;
  FCAFile := ACAFile;
  FCAPath := ACAPath;
End;

Destructor TRESTDWFCMOpenSSLStreamTransport.Destroy;
Begin
  FConnected := False;
  ReleaseHandles;
  Inherited Destroy;
End;

Procedure TRESTDWFCMOpenSSLStreamTransport.ReleaseHandles;
Begin
  If FBIO <> Nil Then
  Begin
    BIO_free_all(PBIO(FBIO));
    FBIO := Nil;
  End;

  If FContext <> Nil Then
  Begin
    SSL_CTX_free(PSSL_CTX(FContext));
    FContext := Nil;
  End;
End;

Procedure TRESTDWFCMOpenSSLStreamTransport.Connect(Const AHost : String;
                                                   APort       : Integer);
Var
  LContext  : PSSL_CTX;
  LBIO      : PBIO;
  LSSL      : PSSL;
  LHostPort : AnsiString;
Begin
  FConnected := False;
  ReleaseHandles;

  LContext := SSL_CTX_new(TLSv1_2_client_method);

  If LContext = Nil Then
    Raise Exception.Create('FCM TLS: SSL_CTX_new falhou');

  LBIO := Nil;

  Try
    RESTDWFCMConfigureTLSContext(
      LContext,
      FVerifyPeer,
      FCAFile,
      FCAPath
    );

    LBIO := BIO_new_ssl_connect(LContext);

    If LBIO = Nil Then
      Raise Exception.Create('FCM TLS: BIO_new_ssl_connect falhou');

    LHostPort :=
      AnsiString(
        AHost + ':' + IntToStr(APort)
      );

    If BIO_ctrl(
         LBIO,
         BIO_C_SET_CONNECT,
         0,
         PAnsiChar(LHostPort)
       ) <= 0 Then
      Raise Exception.Create('FCM TLS: hostname invalido');

    LSSL := Nil;

    BIO_ctrl(
      LBIO,
      BIO_C_GET_SSL,
      0,
      @LSSL
    );

    RESTDWFCMConfigureTLSConnection(
      LSSL,
      AHost,
      FVerifyPeer
    );

    If BIO_ctrl(
         LBIO,
         BIO_C_DO_STATE_MACHINE,
         0,
         Nil
       ) <= 0 Then
      Raise Exception.Create('FCM TLS: conexao falhou');

    RESTDWFCMCheckTLSConnection(
      LSSL,
      FVerifyPeer
    );

    If BIO_ctrl(
         LBIO,
         BIO_C_SET_NBIO,
         1,
         Nil
       ) <= 0 Then
      Raise Exception.Create('FCM TLS: modo nonblocking falhou');

    FContext := LContext;
    FBIO := LBIO;
    FConnected := True;

    { Ownership transferido para a instancia. }
    LContext := Nil;
    LBIO := Nil;
  Finally
    If LBIO <> Nil Then
      BIO_free_all(LBIO);

    If LContext <> Nil Then
      SSL_CTX_free(LContext);
  End;
End;

Procedure TRESTDWFCMOpenSSLStreamTransport.Disconnect;
Begin
  { Nao libera BIO/SSL_CTX aqui. Disconnect pode ser chamado por outra
    thread enquanto ReadBuffer esta executando. O BIO esta em nonblocking;
    a thread leitora observa FConnected=False, sai e o destructor libera
    os handles somente depois que a worker terminou. }
  FConnected := False;
End;

Function TRESTDWFCMOpenSSLStreamTransport.Connected : Boolean;
Begin
  Result := FConnected And (FBIO <> Nil);
End;

Function TRESTDWFCMOpenSSLStreamTransport.ReadByte : Byte;
Begin
  ReadBuffer(Result, 1);
End;

Procedure TRESTDWFCMOpenSSLStreamTransport.ReadBuffer(Var ABuffer;
                                                      ACount : Integer);
Var
  LRead,
  LTotal : Integer;
  P      : PByte;
Begin
  If Not Connected Then
    Raise Exception.Create('FCM TLS: stream desconectado');

  P := @ABuffer;
  LTotal := 0;

  While LTotal < ACount Do
  Begin
    LRead := BIO_read(PBIO(FBIO),
                      RESTDWFCMPtrOffset(P, LTotal),
                      ACount - LTotal);
    If LRead <= 0 Then
    Begin
      If Not FConnected Then
        Raise Exception.Create('FCM TLS: leitura interrompida');

      If BIO_should_retry(PBIO(FBIO)) Then
      Begin
        RESTDWFCMSleep(10);
        Continue;
      End;

      FConnected := False;
      Raise Exception.Create('FCM TLS: leitura encerrada');
    End;

    Inc(LTotal, LRead);
  End;
End;

Procedure TRESTDWFCMOpenSSLStreamTransport.WriteBuffer(Const ABuffer;
                                                       ACount : Integer);
Var
  LWritten,
  LTotal : Integer;
  P      : PByte;
Begin
  If Not Connected Then
    Raise Exception.Create('FCM TLS: stream desconectado');

  P := @ABuffer;
  LTotal := 0;

  While LTotal < ACount Do
  Begin
    LWritten := BIO_write(PBIO(FBIO),
                          RESTDWFCMPtrOffset(P, LTotal),
                          ACount - LTotal);
    If LWritten <= 0 Then
    Begin
      If Not FConnected Then
        Raise Exception.Create('FCM TLS: escrita interrompida');

      If BIO_should_retry(PBIO(FBIO)) Then
      Begin
        RESTDWFCMSleep(10);
        Continue;
      End;

      FConnected := False;
      Raise Exception.Create('FCM TLS: escrita encerrada');
    End;

    Inc(LTotal, LWritten);
  End;
End;

End.
