Unit uRESTDWFCMTLS;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWOpenSslLib;

Procedure RESTDWFCMConfigureTLSContext(AContext    : PSSL_CTX;
                                      AVerifyPeer : Boolean;
                                      Const ACAFile,
                                            ACAPath : String);

Procedure RESTDWFCMConfigureTLSConnection(ASSL       : PSSL;
                                         Const AHost : String;
                                         AVerifyPeer : Boolean);

Procedure RESTDWFCMCheckTLSConnection(ASSL       : PSSL;
                                     AVerifyPeer : Boolean);

Implementation

Function RESTDWFCMLoadLocation(AContext : PSSL_CTX;
                               Const ACAFile,
                                     ACAPath : String) : Boolean;
Var
  LFile,
  LPath : AnsiString;
  PFile,
  PPath : PAnsiChar;
Begin
  Result := False;

  LFile := AnsiString(ACAFile);
  LPath := AnsiString(ACAPath);

  If LFile <> '' Then
    PFile := PAnsiChar(LFile)
  Else
    PFile := Nil;

  If LPath <> '' Then
    PPath := PAnsiChar(LPath)
  Else
    PPath := Nil;

  If (PFile = Nil) And
     (PPath = Nil) Then
    Exit;

  Result :=
    SSL_CTX_load_verify_locations(
      AContext,
      PFile,
      PPath
    ) = 1;
End;

Function RESTDWFCMDefaultCAFile : String;
Begin
  Result :=
    ExtractFilePath(ParamStr(0)) +
    'RESTDWRootCA.pem';
End;

Procedure RESTDWFCMConfigureTLSContext(AContext    : PSSL_CTX;
                                      AVerifyPeer : Boolean;
                                      Const ACAFile,
                                            ACAPath : String);
Var
  LLoaded : Boolean;
Begin
  If AContext = Nil Then
    Raise Exception.Create('FCM TLS: contexto OpenSSL invalido');

  SSL_CTX_set_options(
    AContext,
    SSL_OP_NO_SSLv2 Or
    SSL_OP_NO_SSLv3 Or
    SSL_OP_NO_TLSv1 Or
    SSL_OP_NO_TLSv1_1
  );

  If Not AVerifyPeer Then
  Begin
    SSL_CTX_set_verify(
      AContext,
      SSL_VERIFY_NONE,
      Nil
    );
    Exit;
  End;

  SSL_CTX_set_verify(
    AContext,
    SSL_VERIFY_PEER,
    Nil
  );

  LLoaded := False;

  If (ACAFile <> '') Or
     (ACAPath <> '') Then
  Begin
    LLoaded :=
      RESTDWFCMLoadLocation(
        AContext,
        ACAFile,
        ACAPath
      );

    If Not LLoaded Then
      Raise Exception.Create(
        'FCM TLS: nao foi possivel carregar TLSCAFile/TLSCAPath'
      );
  End
  Else
    LLoaded :=
      RESTDWFCMLoadLocation(
        AContext,
        RESTDWFCMDefaultCAFile,
        ''
      );

  If Not LLoaded Then
    Raise Exception.Create(
      'FCM TLS: RESTDWRootCA.pem nao encontrado'
    );
End;

Procedure RESTDWFCMConfigureTLSConnection(ASSL       : PSSL;
                                         Const AHost : String;
                                         AVerifyPeer : Boolean);
Var
  LHost : AnsiString;
Begin
  If ASSL = Nil Then
    Raise Exception.Create('FCM TLS: SSL invalido');

  If AHost <> '' Then
    SSL_set_tlsext_host_name(
      ASSL,
      AHost
    );

  If Not AVerifyPeer Then
    Exit;

  LHost := AnsiString(AHost);

  If LHost = '' Then
    Raise Exception.Create(
      'FCM TLS: hostname necessario para validacao TLS'
    );

  If X509_VERIFY_PARAM_set1_host(
       SSL_get0_param(ASSL),
       PAnsiChar(LHost),
       0
     ) <> 1 Then
    Raise Exception.Create(
      'FCM TLS: nao foi possivel configurar validacao do hostname'
    );
End;

Procedure RESTDWFCMCheckTLSConnection(ASSL       : PSSL;
                                     AVerifyPeer : Boolean);
Begin
  If Not AVerifyPeer Then
    Exit;

  If ASSL = Nil Then
    Raise Exception.Create('FCM TLS: SSL invalido');

  If SSL_get_verify_result(ASSL) <> X509_V_OK Then
    Raise Exception.Create(
      'FCM TLS: cadeia de certificados nao confiavel'
    );
End;

End.
