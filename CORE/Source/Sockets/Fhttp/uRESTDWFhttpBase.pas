unit uRESTDWFhttpBase;

{$I ..\..\Includes\uRESTDW.inc}
//{$I DefineCompile.inc}

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
  A. Brito                   - Admin - Administrador do desenvolvimento.
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
  {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
  {$IFNDEF FPC}
    {$IF (CompilerVersion <= 22)}
  SyncObjs, uRESTDWMassiveBuffer,
    {$ELSE}
      SyncObjs,
    {$IFEND}
  {$IF Defined(RESTDWFMX) AND Not(Defined(RESTDWAndroidService))} FMX.Forms, {$IFEND}
    {$IFNDEF RESTDWFMX}
      {$IF (CompilerVersion > 22)}
  VCL.Forms,
      {$ELSE}
        Forms,
      {$IFEND}
    {$ENDIF}
  {$ENDIF}
  SysUtils, Classes, DB, Variants,
  uRESTDWBasic, uRESTDWBasicDB, uRESTDWComponentEvents, uRESTDWBasicTypes,
  uRESTDWJSONObject, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
  uRESTDWConsts, uRESTDWProtoTypes, uRESTDWDataUtils, uRESTDWTools, uRESTDWZlib,
  uRESTDWMIMETypes, uRESTDWCharSets,uRESTDWFhttpException, uRESTDWITextEncoding, {uRESTDWFhttpProtocols, uRESTDWFhttpException,}
  fphttpclient, fphttpserver, HTTPDefs, sslbase, sslsockets, ssockets

    // Anderson remover dependência do Indy
  {
  IdContext, IdHeaderList, IdTCPConnection, IdHTTPServer, IdCustomHTTPServer,
  IdSSLOpenSSL, IdSSL, IdAuthentication, IdTCPClient, IdHTTPHeaderInfo,
  IdComponent, IdBaseComponent, IdHTTP, IdMultipartFormData, IdMessageCoder,
  IdMessage, IdGlobalProtocols, IdGlobal, IdStack } ;



  const
  sContentTypeFormData = 'multipart/form-data; boundary=';            {do not localize}
  sContentTypeOctetStream = 'application/octet-stream';               {do not localize}
  sContentTypeTextPlain = 'text/plain';                               {do not localize}
  CRLF = #13#10;
  sContentDispositionPlaceHolder = 'Content-Disposition: form-data; name="%s"';  {do not localize}
  sFileNamePlaceHolder = '; filename="%s"';                           {do not localize}
  sContentTypePlaceHolder = 'Content-Type: %s';                       {do not localize}
  sCharsetPlaceHolder = '; charset="%s"';                             {do not localize}
  sContentTransferPlaceHolder = 'Content-Transfer-Encoding: %s';      {do not localize}
  sContentTransferQuotedPrintable = 'quoted-printable';               {do not localize}
  sContentTransferBinary = 'binary';                                  {do not localize}


  csAddressSpecials: String = '()[]<>:;.,@\"';  {Do not Localize}

  base64_tbl: array [0..63] of Char = (
    'A','B','C','D','E','F','G','H',     {Do not Localize}
    'I','J','K','L','M','N','O','P',      {Do not Localize}
    'Q','R','S','T','U','V','W','X',      {Do not Localize}
    'Y','Z','a','b','c','d','e','f',      {Do not Localize}
    'g','h','i','j','k','l','m','n',      {Do not Localize}
    'o','p','q','r','s','t','u','v',       {Do not Localize}
    'w','x','y','z','0','1','2','3',       {Do not Localize}
    '4','5','6','7','8','9','+','/');      {Do not Localize}

  type


  EHeaderEncodeError = class(EException);

  THeaderCoderClass = class of THeaderCoder;

  { THeaderCoderList }

  THeaderCoderList = class(TList{$IFDEF HAS_GENERICS_TList}<THeaderCoderClass>{$ENDIF})
  public
    function ByCharSet(const ACharSet: String): THeaderCoderClass;
  end;

  THeaderDecodingNeededEvent = procedure(const ACharSet: String; const AData: TBytes; var VResult: String; var VHandled: Boolean) of object;
  THeaderEncodingNeededEvent = procedure(const ACharSet, AData: String; var VResult: TBytes; var VHandled: Boolean) of object;

  THeaderCoder = class(TObject)
  public
    class function Decode(const ACharSet: String; const AData: TBytes): String; virtual;
    class function Encode(const ACharSet, AData: String): TBytes; virtual;
    class function CanHandle(const ACharSet: String): Boolean; virtual;
  end;

  TReadFileExclusiveStream = class(TFileStream)
  public
    constructor Create(const AFile : String);
  end;

  TMultiPartFormDataStream = class;



   { TFormDataField }

  TFormDataField = class(TCollectionItem)
  protected
    FFileName: string;
    FCharset: string;
    FContentType: string;
    FContentTransfer: string;
    FFieldName: string;
    FFieldStream: TStream;
    FFieldValue: String;
    FCanFreeFieldStream: Boolean;
    FHeaderCharSet: string;
    FHeaderEncoding: Char;
    function EncodeHeaderData(const ACharSet, AData: String): TBytes;
    function EncodeHeader(const Header: string; Specials: String; const HeaderEncoding: Char;
      const MimeCharSet: string): string;
    function FormatHeader: string;
    function DecodeHeader(const Header: string): string;

    function DecodeHeaderData(const ACharSet: String; const AData: TBytes; var VResult: String): Boolean;


    function PrepareDataStream(var VCanFree: Boolean): TStream;

    function GetFieldSize: Int64;
    function GetFieldStream: TStream;
    function GetFieldValue: string;
    procedure SetCharset(const Value: string);
    procedure SetContentType(const Value: string);
    procedure SetContentTransfer(const Value: string);
    procedure SetFieldName(const Value: string);
    procedure SetFieldStream(const Value: TStream);
    procedure SetFieldValue(const Value: string);
    procedure SetFileName(const Value: string);
    procedure SetHeaderCharSet(const Value: string);
    procedure SetHeaderEncoding(const Value: Char);
    function GetDefaultCharSet: TRESTDWCharSet;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    // procedure Assign(Source: TPersistent); override;
    property ContentTransfer: string read FContentTransfer write SetContentTransfer;
    property ContentType: string read FContentType write SetContentType;
    property Charset: string read FCharset write SetCharset;
    property FieldName: string read FFieldName write SetFieldName;
    property FieldStream: TStream read GetFieldStream write SetFieldStream;
    property FileName: string read FFileName write SetFileName;
    property FieldValue: string read GetFieldValue write SetFieldValue;
    property FieldSize: Int64 read GetFieldSize;
    property HeaderCharSet: string read FHeaderCharSet write SetHeaderCharSet;
    property HeaderEncoding: Char read FHeaderEncoding write SetHeaderEncoding;
  end;

  TFormDataFields = class(TCollection)
  protected
    FParentStream: TMultiPartFormDataStream;
    function GetFormDataField(AIndex: Integer): TFormDataField;
  public
    constructor Create(AMPStream: TMultiPartFormDataStream);
    function Add: TFormDataField;
    property MultipartFormDataStream: TMultiPartFormDataStream read FParentStream;
    property Items[AIndex: Integer]: TFormDataField read GetFormDataField;
  end;

  { TBaseStream }

  TBaseStream = class(TStream)
  protected
    function IdRead(var VBuffer: TBytes; AOffset, ACount: Longint): Longint; virtual; abstract;
    function IdWrite(const ABuffer: TBytes; AOffset, ACount: Longint): Longint; virtual; abstract;
    function IdSeek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64; virtual; abstract;
    procedure IdSetSize(ASize: Int64); virtual; abstract;
    {$IFDEF DOTNET}
    procedure SetSize(ASize: Int64); override;
    {$ELSE}
      {$IFDEF STREAM_SIZE_64}
    procedure SetSize(const NewSize: Int64); override;
      {$ELSE}
    procedure SetSize(ASize: Integer); override;
      {$ENDIF}
    {$ENDIF}

    function RawToBytes(const AValue; const ASize: Integer): TBytes;
  public
    {$IFDEF DOTNET}
    function Read(var VBuffer: array of Byte; AOffset, ACount: Longint): Longint; override;
    function Write(const ABuffer: array of Byte; AOffset, ACount: Longint): Longint; override;
    function Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64; override;
    {$ELSE}
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
      {$IFDEF STREAM_SIZE_64}
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
      {$ELSE}
    function Seek(Offset: Longint; Origin: Word): Longint; override;
      {$ENDIF}
    {$ENDIF}
  end;


  TMultiPartFormDataStream = class(TBaseStream)
  protected
    FInputStream: TStream;
    FFreeInputStream: Boolean;
    FBoundary: string;
    FRequestContentType: string;
    FCurrentItem: integer;
    FInitialized: Boolean;
    FInternalBuffer: TBytes;

    FPosition: Int64;
    FSize: Int64;

    FFields: TFormDataFields;

    function GenerateUniqueBoundary: string;
    procedure CalculateSize;

   // function IdRead(var VBuffer: TBytes; AOffset, ACount: Longint): Longint; override;
    function IdWrite(const ABuffer: TBytes; AOffset, ACount: Longint): Longint; override;
    function IdSeek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64; override;
    procedure IdSetSize(ASize : Int64); override;
  public
    constructor Create;
    destructor Destroy; override;

    function AddFormField(const AFieldName, AFieldValue: string; const ACharset: string = ''; const AContentType: string = ''; const AFileName: string = ''): TFormDataField; overload;
    function AddFormField(const AFieldName, AContentType, ACharset: string; AFieldValue: TStream; const AFileName: string = ''): TFormDataField; overload;
    function AddObject(const AFieldName, AContentType, ACharset: string; AFileData: TObject; const AFileName: string = ''): TFormDataField; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use overloaded version of AddFormField()'{$ENDIF};{$ENDIF}
    function AddFile(const AFieldName, AFileName: String; const AContentType: string = ''): TFormDataField;

    procedure Clear;

    property Boundary: string read FBoundary;
    property RequestContentType: string read FRequestContentType;
  end;


  PFhttpSSLVersions = ^TSSLType;

  TSSLVersions = set of TSSLType;

  TSSLMode = (sslmUnassigned, sslmClient, sslmServer, sslmBoth);
  TSSLVerifyMode = (sslvrfPeer, sslvrfFailIfNoPeerCert, sslvrfClientOnce);
  TSSLVerifyModeSet = set of TSSLVerifyMode;
  TStatus = (hsResolving,
    hsConnecting,
    hsConnected,
    hsDisconnecting,
    hsDisconnected,
    hsStatusText,
    ftpTransfer,  // These are to eliminate the TIdFTPStatus and the
    ftpReady,     // coresponding event
    ftpAborted);  // These can be use din the other protocols to.

type
  TRESTDWFhttpServicePooler = class(TRESTServicePoolerBase)
  private
    vCipherList, vaSSLRootCertFile, ASSLPrivateKeyFile, ASSLPrivateKeyPassword,
    ASSLCertFile: string;
    aSSLMethod: TSSLType;
    HTTPServer: TFPHttpServer;
    lHandler: TSSLSocketHandler;
    vSSLVerifyMode: TSSLVerifyModeSet;
    vSSLVerifyDepth: integer;
    vSSLMode: TSSLMode;
    aSSLVersions: TSSLVersions;
    procedure aCommandGet(Sender: TObject; var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);

  {
  Procedure aCommandOther           (AContext         : TIdContext;
                                     ARequestInfo     : TIdHTTPRequestInfo;
                                     AResponseInfo    : TIdHTTPResponseInfo);

  Procedure CustomOnConnect         (AContext         : TIdContext);
  procedure IdHTTPServerQuerySSLPort(APort            : Word;
                                     Var VUseSSL      : Boolean);
  Procedure CreatePostStream        (AContext         : TIdContext;
                                     AHeaders         : TIdHeaderList;
                                     Var VPostStream  : TStream);
  Procedure OnParseAuthentication   (AContext         : TIdContext;
                                     Const AAuthType,
                                     AAuthData        : String;
                                     var VUsername,
                                     VPassword        : String;
                                     Var VHandled     : Boolean);
  }
    procedure SetActive(Value: boolean); override;

  {
  Function  SSLVerifyPeer           (Certificate      : TIdX509;
                                     AOk              : Boolean;
                                     ADepth, AError   : Integer) : Boolean;
  Procedure GetSSLPassWord          (Var Password     : String);
  }
    procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      var Pooler, MyIP: string; AccessTag: string;
      var InvalidTag: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property SSLPrivateKeyFile: string read aSSLPrivateKeyFile write aSSLPrivateKeyFile;
    property SSLPrivateKeyPassword: string
      read aSSLPrivateKeyPassword write aSSLPrivateKeyPassword;
    property SSLCertFile: string read aSSLCertFile write aSSLCertFile;
    property SSLRootCertFile: string read vaSSLRootCertFile write vaSSLRootCertFile;
    property SSLVerifyMode: TSSLVerifyModeSet read vSSLVerifyMode write vSSLVerifyMode;
    property SSLVerifyDepth: integer read vSSLVerifyDepth write vSSLVerifyDepth;
    property SSLMode: TSSLMode read vSSLMode write vSSLMode;
    property SSLMethod: TSSLType read aSSLMethod write aSSLMethod;
    property SSLVersions: TSSLVersions read aSSLVersions write aSSLVersions;
    property CipherList: string read vCipherList write vCipherList;
  end;



type
  TRESTDWFhttpClientREST = class(TRESTDWClientRESTBase)
  private
    HttpRequest: TFPHTTPClient;
    vVerifyCert: boolean;
    vAUrl, vCertFile, vKeyFile, vRootCertFile, vHostCert: string;
    vPortCert: integer;
    vOnGetpassword: TOnGetpassword;
    vSSLVersions: TSSLType;
    ssl: TSSLSocketHandler;
    vCertMode: TSSLMode;
    procedure SetParams;
    procedure SetUseSSL(Value: boolean); override;
    Procedure SetHeaders        (AHeaders           : TStringList);Overload;Override;
    Procedure SetHeaders        (AHeaders           : TStringList;
                               Var SendParams     : TMultipartFormDataStream);Overload;
    Procedure SetRawHeaders     (AHeaders           : TStringList;
                               Var SendParams     : TMultipartFormDataStream);
    procedure pOnWork(Sender: TObject; const ContentLength, CurrentPos: int64);
    procedure SetOnWork(Value: TOnWork); override;
    procedure pOnWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: int64);
    procedure SetOnWorkBegin(Value: TOnWork); override;
    procedure pOnWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure SetOnWorkEnd(Value: TOnWorkEnd); override;
    procedure pOnStatus(ASender: TObject; const AStatus: TStatus;
      const AStatusText: string);
    procedure SetOnStatus(Value: TOnStatus); override;
    procedure DestroyClient; override;
    procedure SetCertOptions;
    procedure Getpassword(var Password: string);
    function GetVerifyCert: boolean;
    procedure SetVerifyCert(aValue: boolean);
  {$IFNDEF FPC}
  {$IFNDEF DELPHI_10TOKYO_UP}
    function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate: TIdX509;
      AOk: boolean): boolean;
      overload;
    function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate: TIdX509;
      AOk: boolean; ADepth: integer): boolean;
      overload;
  {$ENDIF}
  {$ENDIF}
    function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate: TX509Certificate;
      AOk: boolean; ADepth, AError: integer): boolean;
      overload;
    procedure SetInternalEvents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Get(AUrl: string = ''; CustomHeaders: TStringList = nil;
      const AResponse: TStream = nil; IgnoreEvents: boolean = False): integer;
      overload; override;
    function Get(AUrl: string = ''; CustomHeaders: TStringList = nil;
      IgnoreEvents: boolean = False): string;
      overload; override;
    Function   Post      (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Post      (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const CustomBody  : TMultipartFormDataStream = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;

  Function   Post      (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Post      (AUrl              : String;
                        var AResponseText : String;
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Post      (AUrl              : String;
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomBody        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        CustomBody        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Delete    (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Delete    (AUrl              : String;
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;

  published
    property VerifyCert: boolean read GetVerifyCert write SetVerifyCert;
    property SSLVersions: TSSLType read vSSLVersions write vSSLVersions;
    property CertMode: TSSLMode read vCertMode write vCertMode;
    property CertFile: string read vCertFile write vCertFile;
    property KeyFile: string read vKeyFile write vKeyFile;
    property RootCertFile: string read vRootCertFile write vRootCertFile;
    property HostCert: string read vHostCert write vHostCert;
    property PortCert: integer read vPortCert write vPortCert;
    property OnGetpassword: TOnGetpassword read vOnGetpassword write vOnGetpassword;
  end;


type
  TRESTDWFhttpDatabase = class(TRESTDWDatabasebaseBase)
  private
    vCipherList: string;
    aSSLMethod: TSSLType;
    vSSLMode: TSSLMode;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property SSLMode: TSSLMode read vSSLMode write vSSLMode;
    property CipherList: string read vCipherList write vCipherList;
  end;

type
  TRESTDWFhttpClientPooler = class(TRESTClientPoolerBase)
  private
    vCipherList: string;
    aSSLMethod: TSSLType;
    HttpRequest: TRESTDWFhttpClientREST;
    vSSLMode: TSSLMode;
    function SendEvent(EventData: string; var Params: TRESTDWParams;
      EventType: TSendEvent = sePOST; DataMode: TDataMode = dmDataware;
      ServerEventName: string = ''; Assyncexec: boolean = False): string;
      override;
    procedure SetParams(TransparentProxy: TProxyConnectionInfo;
      aRequestTimeout, aConnectTimeout: integer;
      AuthorizationParams: TRESTDWClientAuthOptionParams);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReconfigureConnection(aTypeRequest: Ttyperequest;
      aWelcomeMessage, aHost: string; aPort: integer;
      Compression, EncodeStrings: boolean; aEncoding: TEncodeSelect;
      aAccessTag: string; aAuthenticationOptions:
      TRESTDWClientAuthOptionParams);
      override;
  published
    property SSLMode: TSSLMode read vSSLMode write vSSLMode;
    property CipherList: string read vCipherList write vCipherList;
  end;

type
  TRESTDWFhttpPoolerList = class(TRESTDWPoolerListBase)
  public
    constructor Create(AOwner: TComponent); override; //Cria o Componente
    destructor Destroy; override;
  end;

//Fix to Indy Request Patch and Put
type
  THTTPAccess = class(TFPHTTPClient)
  end;

type

    { T8BitEncoding }

    { TTextEncodingBase }

  TTextEncodingBase = class(TInterfacedObject, ITextEncoding)
  protected
    FIsSingleByte: Boolean;
    FMaxCharSize: Integer;
  public
    function GetByteCount(const AChars: TWideChars): Integer; overload;
    function GetByteCount(const AChars: TWideChars; ACharIndex, ACharCount: Integer): Integer; overload;
    function GetByteCount(const AChars: PWideChar; ACharCount: Integer): Integer; overload; virtual; abstract;
    function GetByteCount(const AStr: UnicodeString): Integer; overload;
    function GetByteCount(const AStr: UnicodeString; ACharIndex, ACharCount: Integer): Integer; overload;

    function GetBytes(const AChars: TWideChars): TBytes; overload;
    function GetBytes(const AChars: TWideChars; ACharIndex, ACharCount: Integer): TBytes; overload;
    function GetBytes(const AChars: TWideChars; ACharIndex, ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer; overload;
    function GetBytes(const AChars: PWideChar; ACharCount: Integer): TBytes; overload;
    function GetBytes(const AChars: PWideChar; ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer; overload;
    function GetBytes(const AChars: PWideChar; ACharCount: Integer; ABytes: PByte; AByteCount: Integer): Integer; overload; virtual; abstract;
    function GetBytes(const AStr: UnicodeString): TBytes; overload;
    function GetBytes(const AStr: UnicodeString; ACharIndex, ACharCount: Integer): TBytes; overload;
    function GetBytes(const AStr: UnicodeString; ACharIndex, ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer; overload;

    function GetCharCount(const ABytes: TBytes): Integer; overload;
    function GetCharCount(const ABytes: TBytes; AByteIndex, AByteCount: Integer): Integer; overload;
    function GetCharCount(const ABytes: PByte; AByteCount: Integer): Integer; overload; virtual; abstract;

    function GetChars(const ABytes: TBytes): TWideChars; overload;
    function GetChars(const ABytes: TBytes; AByteIndex, AByteCount: Integer): TWideChars; overload;
    function GetChars(const ABytes: TBytes; AByteIndex, AByteCount: Integer; var VChars: TWideChars; ACharIndex: Integer): Integer; overload;
    function GetChars(const ABytes: PByte; AByteCount: Integer): TWideChars; overload;
    function GetChars(const ABytes: PByte; AByteCount: Integer; var VChars: TWideChars; ACharIndex: Integer): Integer; overload;
    function GetChars(const ABytes: PByte; AByteCount: Integer; AChars: PWideChar; ACharCount: Integer): Integer; overload; virtual; abstract;

    function GetIsSingleByte: Boolean;
    function GetMaxByteCount(ACharCount: Integer): Integer; virtual; abstract;
    function GetMaxCharCount(AByteCount: Integer): Integer; virtual; abstract;
    function GetPreamble: TBytes; virtual;
    function GetString(const ABytes: TBytes): UnicodeString; overload;
    function GetString(const ABytes: TBytes; AByteIndex, AByteCount: Integer): UnicodeString; overload;
    function GetString(const ABytes: PByte; AByteCount: Integer): UnicodeString; overload;
  end;

  T8BitEncoding = class(TTextEncodingBase)
  public
    constructor Create; virtual;
    function GetByteCount(const AChars: PWideChar; ACharCount: Integer): Integer; override;
    function GetBytes(const AChars: PWideChar; ACharCount: Integer; ABytes: PByte; AByteCount: Integer): Integer; override;
    function GetCharCount(const ABytes: PByte; AByteCount: Integer): Integer; override;
    function GetChars(const ABytes: PByte; AByteCount: Integer; AChars: PWideChar; ACharCount: Integer): Integer; override;
    function GetMaxByteCount(ACharCount: Integer): Integer; override;
    function GetMaxCharCount(AByteCount: Integer): Integer; override;
  end;

  TextEncodingType = (encDefault, encOSDefault, enc8Bit, encASCII, encUTF16BE, encUTF16LE, encUTF7, encUTF8);

  var
  GHeaderEncodingNeeded: THeaderEncodingNeededEvent = nil;
  GHeaderDecodingNeeded: THeaderDecodingNeededEvent = nil;
  G8BitEncoding: ITextEncoding = nil;
  GDefaultTextEncoding: TextEncodingType = encASCII;
  GHeaderCoderList: THeaderCoderList = nil;

  procedure CheckByteEncoding(var VBytes: TBytes; ASrcEncoding, ADestEncoding: ITextEncoding);
  function HeaderCoderByCharSet(const ACharSet: String): THeaderCoderClass;

  // To and From Bytes conversion routines
  function ToBytes(const AValue: string; ADestEncoding: ITextEncoding = nil
    {$IFDEF STRING_IS_ANSI}; ASrcEncoding: ITextEncoding = nil{$ENDIF}): TBytes; overload;

  function ToBytes(const AValue: string; const ALength: Integer; const AIndex: Integer = 1;
    ADestEncoding: ITextEncoding = nil
    {$IFDEF STRING_IS_ANSI}; ASrcEncoding: ITextEncoding = nil{$ENDIF}): TBytes; overload;

  function ToBytes(const AValue: Char; ADestEncoding: ITextEncoding = nil
    {$IFDEF STRING_IS_ANSI}; ASrcEncoding: ITextEncoding = nil{$ENDIF}): TBytes; overload;


  function ToBytes(const AValue: Int8): TBytes; overload;
  function ToBytes(const AValue: UInt8): TBytes; overload;
  function ToBytes(const AValue: Int16): TBytes; overload;
  function ToBytes(const AValue: UInt16): TBytes; overload;
  function ToBytes(const AValue: Int32): TBytes; overload;
  function ToBytes(const AValue: UInt32): TBytes; overload;
  function ToBytes(const AValue: Int64): TBytes; overload;
  function ToBytes(const AValue: QWord): TBytes; overload;
  function ToBytes(const AValue: TBytes; const ASize: Integer; const AIndex: Integer = 0): TBytes; overload;

  function ILength(const ABuffer: String; const ALength: Integer = -1; const AIndex: Integer = 1): Integer; overload;
  function ILength(const ABuffer: TBytes; const ALength: Integer = -1; const AIndex: Integer = 0): Integer; overload;

  function IMin(const AValueOne, AValueTwo: Int64): Int64; overload;
  function IMin(const AValueOne, AValueTwo: Int32): Int32; overload;
  function IMin(const AValueOne, AValueTwo: UInt16): UInt16; overload;
  function IMax(const AValueOne, AValueTwo: Int64): Int64; overload;
  function IMax(const AValueOne, AValueTwo: Int32): Int32; overload;
  function IMax(const AValueOne, AValueTwo: UInt16): UInt16; overload;

  procedure EnsureEncoding(var VEncoding : ITextEncoding; ADefEncoding: TextEncodingType = encDefault);

  function TextEncoding(AType: TextEncodingType): ITextEncoding; overload;
  function TextEncoding(ACodepage: UInt16): ITextEncoding; overload;
  function TextEncoding(const ACharSet: String): ITextEncoding; overload;

  function TextEncoding_Default: ITextEncoding;
  function TextEncoding_OSDefault: ITextEncoding;
  function TextEncoding_8Bit: ITextEncoding;
  function TextEncoding_ASCII: ITextEncoding;
  function TextEncoding_UTF16BE: ITextEncoding;
  function TextEncoding_UTF16LE: ITextEncoding;
  function TextEncoding_UTF7: ITextEncoding;
  function TextEncoding_UTF8: ITextEncoding;

implementation

uses uRESTDWJSONInterface;

procedure CheckByteEncoding(var VBytes: TBytes; ASrcEncoding,
  ADestEncoding: ITextEncoding);
begin
  if ASrcEncoding <> ADestEncoding then begin
    VBytes := ADestEncoding.GetBytes(ASrcEncoding.GetChars(VBytes));
  end;
end;

function HeaderCoderByCharSet(const ACharSet: String): THeaderCoderClass;
begin
  if Assigned(GHeaderCoderList) then begin
    Result := GHeaderCoderList.ByCharSet(ACharSet);
  end else begin
    Result := nil;
  end;
end;

function TextEncoding_8Bit: ITextEncoding;
{$IFNDEF DOTNET}
var
  LEncoding: ITextEncoding;
{$ENDIF}
begin
  if G8BitEncoding = nil then begin
    {$IFDEF DOTNET}
    // We need a charset that converts UTF-16 codeunits in the $00-$FF range
    // to/from their numeric values as-is.  Was previously using "Windows-1252"
    // which does so for most codeunits, however codeunits $80-$9F in
    // Windows-1252 map to different codepoints in Unicode, which we don't want.
    // "ISO-8859-1" aka "ISO_8859-1:1987" (not to be confused with the older
    // "ISO 8859-1" charset), on the other hand, treats codeunits $00-$FF as-is,
    // and seems to be just as widely supported as Windows-1252 on most systems,
    // so we'll use that for now...

    // TODO: use thread-safe assignment
    G8BitEncoding := TIdDotNetEncoding.Create('ISO-8859-1');
    {$ELSE}
    LEncoding := T8BitEncoding.Create;
    if InterlockedCompareExchangeIntf(IInterface(G8BitEncoding), LEncoding, nil) <> nil then begin
      LEncoding := nil;
    end;
    {$ENDIF}
  end;
  Result := G8BitEncoding;
end;

function ToBytes(const AValue: string; ADestEncoding: ITextEncoding = nil
    {$IFDEF STRING_IS_ANSI}; ASrcEncoding: ITextEncoding = nil{$ENDIF}): TBytes; overload;
{$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  Result := ToBytes(AValue, -1, 1, ADestEncoding
    {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
    );
end;

function ToBytes(const AValue: string; const ALength: Integer; const AIndex: Integer = 1;
    ADestEncoding: ITextEncoding = nil
    {$IFDEF STRING_IS_ANSI}; ASrcEncoding: ITextEncoding = nil{$ENDIF}): TBytes; overload;
var
  LLength: Integer;
  {$IFDEF STRING_IS_ANSI}
  LBytes: TBytes;
  {$ENDIF}
begin
  {$IFDEF STRING_IS_ANSI}
  LBytes := nil; // keep the compiler happy
  {$ENDIF}
  LLength := ILength(AValue, ALength, AIndex);
  if LLength > 0 then
  begin
    EnsureEncoding(ADestEncoding);
    {$IFDEF STRING_IS_UNICODE}
    SetLength(Result, ADestEncoding.GetByteCount(AValue, AIndex, LLength));
    if Length(Result) > 0 then begin
      ADestEncoding.GetBytes(AValue, AIndex, LLength, Result, 0);
    end;
    {$ELSE}
    EnsureEncoding(ASrcEncoding, encOSDefault);
    LBytes := RawToBytes(AValue[AIndex], LLength);
    CheckByteEncoding(LBytes, ASrcEncoding, ADestEncoding);
    Result := LBytes;
    {$ENDIF}
  end else begin
    SetLength(Result, 0);
  end;
end;

function ToBytes(const AValue: Char; ADestEncoding: ITextEncoding = nil
    {$IFDEF STRING_IS_ANSI}; ASrcEncoding: ITextEncoding = nil{$ENDIF}): TBytes; overload;
var
{$IFDEF STRING_IS_UNICODE}
  LChars: {$IFDEF DOTNET}array[0..0] of Char{$ELSE}TIdWideChars{$ENDIF};
{$ELSE}
  LBytes: TBytes;
{$ENDIF}
begin
  EnsureEncoding(ADestEncoding);
  {$IFDEF STRING_IS_UNICODE}
    {$IFNDEF DOTNET}
  SetLength(LChars, 1);
    {$ENDIF}
  LChars[0] := AValue;
  Result := ADestEncoding.GetBytes(LChars);
  {$ELSE}
  EnsureEncoding(ASrcEncoding, encOSDefault);
  LBytes := RawToBytes(AValue, 1);
  CheckByteEncoding(LBytes, ASrcEncoding, ADestEncoding);
  Result := LBytes;
  {$ENDIF}
end;

function ToBytes(const AValue: Int8): TBytes;
begin

end;

function ToBytes(const AValue: UInt8): TBytes;
begin

end;

function ToBytes(const AValue: Int16): TBytes;
begin

end;

function ToBytes(const AValue: UInt16): TBytes;
begin

end;

function ToBytes(const AValue: Int32): TBytes;
begin

end;

function ToBytes(const AValue: UInt32): TBytes;
begin

end;

function ToBytes(const AValue: Int64): TBytes;
begin

end;

function ToBytes(const AValue: QWord): TBytes;
begin

end;

function ToBytes(const AValue: TBytes; const ASize: Integer;
  const AIndex: Integer): TBytes;
begin

end;

function ILength(const ABuffer: String; const ALength: Integer;
  const AIndex: Integer): Integer;
var
  LAvailable: Integer;
begin
  Assert(AIndex >= 1);
  LAvailable := IMax(Length(ABuffer)-AIndex+1, 0);
  if ALength < 0 then begin
    Result := LAvailable;
  end else begin
    Result := IMin(LAvailable, ALength);
  end;
end;

function ILength(const ABuffer: TBytes; const ALength: Integer;
  const AIndex: Integer): Integer;
var
  LAvailable: Integer;
begin
  Assert(AIndex >= 0);
  LAvailable := IMax(Length(ABuffer)-AIndex, 0);
  if ALength < 0 then begin
    Result := LAvailable;
  end else begin
    Result := IMin(LAvailable, ALength);
  end;
end;

function IMin(const AValueOne, AValueTwo: Int64): Int64;
begin
  if AValueOne > AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IMin(const AValueOne, AValueTwo: Int32): Int32;
begin
  if AValueOne > AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IMin(const AValueOne, AValueTwo: UInt16): UInt16;
begin
  if AValueOne > AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IMax(const AValueOne, AValueTwo: Int64): Int64;
begin
  if AValueOne < AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IMax(const AValueOne, AValueTwo: Int32): Int32;
begin
  if AValueOne < AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IMax(const AValueOne, AValueTwo: UInt16): UInt16;
begin
  if AValueOne < AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

procedure EnsureEncoding(var VEncoding: ITextEncoding;
  ADefEncoding: TextEncodingType);
begin
  if VEncoding = nil then begin
    VEncoding := TextEncoding(ADefEncoding);
  end;
end;

function TextEncoding(AType: TextEncodingType): ITextEncoding;
begin
  case AType of
    encDefault: Result := TextEncoding_Default;
    // encOSDefault handled further below
    enc8Bit:        Result := TextEncoding_8Bit;
    encASCII:       Result := TextEncoding_ASCII;
    encUTF16BE:     Result := TextEncoding_UTF16BE;
    encUTF16LE:     Result := TextEncoding_UTF16LE;
    encUTF7:        Result := TextEncoding_UTF7;
    encUTF8:        Result := TextEncoding_UTF8;
  else
    // encOSDefault
    Result := TextEncoding_OSDefault;
  end;
end;

function TextEncoding(ACodepage: UInt16): ITextEncoding;
begin

end;

function TextEncoding(const ACharSet: String): ITextEncoding;
begin

end;

function TextEncoding_Default: ITextEncoding;
  var
  LType: TextEncodingType;
begin
  LType := GDefaultTextEncoding;
  if LType = encDefault then begin
    LType := encASCII;
  end;
  Result := TextEncoding(LType);
end;


{ TTextEncodingBase }

function TTextEncodingBase.GetByteCount(const AChars: TWideChars): Integer;
begin
  //
end;

function TTextEncodingBase.GetByteCount(const AChars: TWideChars; ACharIndex,
  ACharCount: Integer): Integer;
begin
  //
end;

function TTextEncodingBase.GetByteCount(const AStr: UnicodeString): Integer;
begin
  //
end;

function TTextEncodingBase.GetByteCount(const AStr: UnicodeString; ACharIndex,
  ACharCount: Integer): Integer;
begin
  //
end;

function TTextEncodingBase.GetBytes(const AChars: TWideChars): TBytes;
begin
  //
end;

function TTextEncodingBase.GetBytes(const AChars: TWideChars; ACharIndex,
  ACharCount: Integer): TBytes;
begin
  //
end;

function TTextEncodingBase.GetBytes(const AChars: TWideChars; ACharIndex,
  ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer;
begin
   //
end;

function TTextEncodingBase.GetBytes(const AChars: PWideChar; ACharCount: Integer
  ): TBytes;
begin
   //
end;

function TTextEncodingBase.GetBytes(const AChars: PWideChar;
  ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer;
begin
   //
end;

function TTextEncodingBase.GetBytes(const AStr: UnicodeString): TBytes;
begin
  //
end;

function TTextEncodingBase.GetBytes(const AStr: UnicodeString; ACharIndex,
  ACharCount: Integer): TBytes;
begin
  //
end;

function TTextEncodingBase.GetBytes(const AStr: UnicodeString; ACharIndex,
  ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer;
begin
  //
end;

function TTextEncodingBase.GetCharCount(const ABytes: TBytes): Integer;
begin
  //
end;

function TTextEncodingBase.GetCharCount(const ABytes: TBytes; AByteIndex,
  AByteCount: Integer): Integer;
begin
   //
end;

function TTextEncodingBase.GetChars(const ABytes: TBytes): TWideChars;
begin
   //
end;

function TTextEncodingBase.GetChars(const ABytes: TBytes; AByteIndex,
  AByteCount: Integer): TWideChars;
begin
   //
end;

function TTextEncodingBase.GetChars(const ABytes: TBytes; AByteIndex,
  AByteCount: Integer; var VChars: TWideChars; ACharIndex: Integer): Integer;
begin
   //
end;

function TTextEncodingBase.GetChars(const ABytes: PByte; AByteCount: Integer
  ): TWideChars;
begin
   //
end;

function TTextEncodingBase.GetChars(const ABytes: PByte; AByteCount: Integer;
  var VChars: TWideChars; ACharIndex: Integer): Integer;
begin
  //
end;

function TTextEncodingBase.GetIsSingleByte: Boolean;
begin
  //
end;

function TTextEncodingBase.GetPreamble: TBytes;
begin
   //
end;

function TTextEncodingBase.GetString(const ABytes: TBytes): UnicodeString;
begin
   //
end;

function TTextEncodingBase.GetString(const ABytes: TBytes; AByteIndex,
  AByteCount: Integer): UnicodeString;
begin
   //
end;

function TTextEncodingBase.GetString(const ABytes: PByte; AByteCount: Integer
  ): UnicodeString;
begin
    //
end;

{ T8BitEncoding }

constructor T8BitEncoding.Create;
begin
  inherited Create;
  FIsSingleByte := True;
  FMaxCharSize := 1;
end;

{ TIdHeaderCoderList }

function THeaderCoderList.ByCharSet(const ACharSet: String
  ): THeaderCoderClass;
var
  I: Integer;
  LCoder: THeaderCoderClass;
begin
  Result := nil;
  // loop backwards so that user-defined coders can override native coders
  for I := Count-1 downto 0 do begin
    LCoder := THeaderCoderClass(Items[I]);
    if LCoder.CanHandle(ACharSet) then begin
      Result := LCoder;
      Exit;
    end;
  end;
end;

{ THeaderCoderList }


destructor TRESTDWFhttpClientREST.Destroy;
begin
  if Assigned(HttpRequest) then
  begin
    //HttpRequest.Disconnect(false);

    FreeAndNil(HttpRequest);
  end;
  inherited;
end;

procedure TRESTDWFhttpClientREST.DestroyClient;
begin
 {$IFNDEF FPC}
  inherited;
 {$ENDIF}
  if Assigned(HttpRequest) then
  begin
    // HttpRequest.Disconnect(False);
    FreeAndNil(HttpRequest);
  end;
end;

procedure TRESTDWFhttpClientREST.SetInternalEvents;
begin
  if Assigned(OnWork) then
  begin
   {$IFDEF FPC}
   HttpRequest.OnDataReceived := @pOnWork;
   {$ELSE}
    HttpRequest.OnWork := pOnWork;
   {$ENDIF}
  end;
 {
 If Assigned(OnWorkBegin) Then
  Begin
   {$IFDEF FPC}
   HttpRequest.OnWorkBegin := @pOnWorkBegin;
   {$ELSE}
   HttpRequest.OnWorkBegin := pOnWorkBegin;
   {$ENDIF}
  End;
 If Assigned(OnWorkEnd) Then
  Begin
   {$IFDEF FPC}
   HttpRequest.OnWorkEnd := @pOnWorkEnd;
   {$ELSE}
   HttpRequest.OnWorkEnd := pOnWorkEnd;
   {$ENDIF}
  End;
 If Assigned(OnStatus) Then
  Begin
   {$IFDEF FPC}
   HttpRequest.OnStatus := @pOnStatus;
   {$ELSE}
   HttpRequest.OnStatus := pOnStatus;
   {$ENDIF}
  End;
 }
end;

procedure TRESTDWFhttpClientREST.SetParams;
begin
  if not Assigned(HttpRequest) then
    HttpRequest := TFPHTTPClient.Create(nil);
  SetInternalEvents;
 {
 If HttpRequest.Request.BasicAuthentication Then
  Begin
   If HttpRequest.Request.Authentication = Nil Then
    HttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
  End;
 }
  HttpRequest.Proxy.Username := ProxyOptions.ProxyUsername;
  HttpRequest.Proxy.Host := ProxyOptions.ProxyServer;
  HttpRequest.Proxy.Password := ProxyOptions.ProxyPassword;
  HttpRequest.Proxy.Port := ProxyOptions.ProxyPort;
  HttpRequest.IOTimeout := RequestTimeout;
  HttpRequest.ConnectTimeout := ConnectTimeOut;
  //HttpRequest.AllowCookies                      := AllowCookies;
  //HttpRequest.HandleRedirects                   := HandleRedirects;
  HttpRequest.MaxRedirects := RedirectMaximum;
  //HttpRequest.HTTPOptions                       := [hoKeepOrigProtocol];
 {
 If RequestCharset = esUtf8 Then
  Begin
   HttpRequest.Request.Charset                  := 'utf-8';
   HttpRequest.Request.AcceptCharSet            := HttpRequest.Request.Charset;
  End;

 HttpRequest.Request.Accept                    := Accept;
 HttpRequest.Request.AcceptEncoding            := AcceptEncoding;
 HttpRequest.Request.ContentType               := ContentType;
 HttpRequest.Request.ContentEncoding           := ContentEncoding;
 HttpRequest.Request.UserAgent                 := UserAgent;
 HttpRequest.MaxAuthRetries                    := MaxAuthRetries;
  }
end;

function TRESTDWFhttpClientREST.Get(AUrl: string = '';
  CustomHeaders: TStringList = nil; const AResponse: TStream = nil;
  IgnoreEvents: boolean = False): integer;
var
  aString: string;
  temp: TStringStream;
  vTempHeaders: TStringList;
  atempResponse, tempResponse: TStream;
  SendParams: TMultipartFormDataStream;
begin
  Result := 200;     // o novo metodo recebe sempre 200 como code inicial;
  try
    AUrl := StringReplace(AUrl, #012, '', [rfReplaceAll]);
    vAUrl := AUrl;
    tempResponse := nil;
    SendParams := nil;
    SetParams;
    SetUseSSL(UseSSL);
    vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
    if not Assigned(AResponse) then
    begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
    end;
    try
      //Copy Custom Headers
      //   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
      SetHeaders(TStringList(DefaultCustomHeader));
      if not IgnoreEvents then
        if Assigned(OnBeforeGet) then
          if not Assigned(CustomHeaders) then
            OnBeforeGet(AUrl, vTempHeaders)
          else
            OnBeforeGet(AUrl, CustomHeaders);
      //Copy New Headers
      CopyStringList(CustomHeaders, vTempHeaders);
      SetHeaders(vTempHeaders, SendParams);
      if not Assigned(AResponse) then
      begin
        HttpRequest.Get(AUrl, atempResponse);
        Result := HttpRequest.ResponseStatusCode;
        if Assigned(OnHeadersAvailable) then
          OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
        atempResponse.Position := 0;
        if RequestCharset = esUtf8 then
          aString := utf8Decode(TStringStream(atempResponse).DataString)
        else
          aString := TStringStream(atempResponse).DataString;
        StringToStream(tempResponse, aString);
        FreeAndNil(atempResponse);
        tempResponse.Position := 0;
        if not IgnoreEvents then
          if Assigned(OnAfterRequest) then
            OnAfterRequest(AUrl, rtGet, tempResponse);
      end
      else
      begin
        HttpRequest.Get(AUrl, atempResponse); // AResponse);
        Result := HttpRequest.ResponseStatusCode;
        if Assigned(OnHeadersAvailable) then
          OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
        atempResponse.Position := 0;
        if RequestCharset = esUtf8 then
          aString := utf8Decode(TStringStream(atempResponse).DataString)
        else
          aString := TStringStream(atempResponse).DataString;
        StringToStream(AResponse, aString);
        FreeAndNil(atempResponse);
        AResponse.Position := 0;
        if not IgnoreEvents then
          if Assigned(OnAfterRequest) then
            OnAfterRequest(AUrl, rtGet, AResponse);
      end;
    finally
      vTempHeaders.Free;
      if Assigned(tempResponse) then
        tempResponse.Free;
      if Assigned(atempResponse) then
        atempResponse.Free;
    end;
  except
  {
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.Message) > 0) or (E.Code <> 0) Then
     Begin
      Result:= E.Code;
      temp := TStringStream.Create(E.Message{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;

  End;
  }
    On E: ESocketError do
    begin
      raise Exception.Create(E.Message);
      // HttpRequest.Disconnect(false);
      FreeAndNil(HttpRequest);
    end;
  end;
  DestroyClient;
end;

function TRESTDWFhttpClientREST.Get(AUrl: string = '';
  CustomHeaders: TStringList = nil; IgnoreEvents: boolean = False): string;
var
  temp: TStringStream;
  vTempHeaders: TStringList;
  SendParams: TMultipartFormDataStream;
begin
  try
    AUrl := StringReplace(AUrl, #012, '', [rfReplaceAll]);
    vAUrl := AUrl;
    Result := '';
    SendParams := nil;
    SetParams;
    SetUseSSL(UseSSL);
    vTempHeaders := TStringList.Create;
    try
      SetHeaders(TStringList(DefaultCustomHeader));
      if not IgnoreEvents then
        if Assigned(OnBeforeGet) then
          if not Assigned(CustomHeaders) then
            OnBeforeGet(AUrl, vTempHeaders)
          else
            OnBeforeGet(AUrl, CustomHeaders);
      CopyStringList(CustomHeaders, vTempHeaders);
      SetHeaders(vTempHeaders, SendParams);
      Result := HttpRequest.Get(AUrl);
      if Assigned(OnHeadersAvailable) then
        OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
    finally
      vTempHeaders.Free;
    end;
  except
  {
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result := E.ErrorMessage;
      Raise;
     End;
   End;
   }
    On E: ESocketError do
    begin
      //HttpRequest.Disconnect(false);
      FreeAndNil(HttpRequest);
      raise;
    end;
  end;
  DestroyClient;
end;

function TRESTDWFhttpClientREST.Post(AUrl: string = '';
  CustomHeaders: TStringList = nil; const CustomBody: TStream = nil;
  IgnoreEvents: boolean = False; RawHeaders: boolean = False): integer;
var
  temp: TStringStream;
  vTempHeaders: TStringList;
  atempResponse, tempResponse: TStringStream;
  SendParams: TMultipartFormDataStream;
  aString, sResponse: string;
begin
  Result := 200;
  SendParams := TMultipartFormDataStream.Create;
  try
    SetParams;
    SetUseSSL(UseSSL);
    vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
    if not Assigned(CustomBody) then
  {$IFDEF FPC}
   tempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
   {$ELSE}
    tempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
    vAUrl := AUrl;
    try
      SetHeaders(TStringList(DefaultCustomHeader));
      if not IgnoreEvents then
        if Assigned(OnBeforePost) then
          if not Assigned(CustomHeaders) then
            OnBeforePost(AUrl, vTempHeaders)
          else
            OnBeforePost(AUrl, CustomHeaders);
      CopyStringList(CustomHeaders, vTempHeaders);
      SetRawHeaders(vTempHeaders, SendParams);

      if not Assigned(CustomBody) then
      begin
        HttpRequest.FormPost(AUrl, RawByteString(SendParams), atempResponse);
        Result := HttpRequest.ResponseStatusCode;
        if Assigned(OnHeadersAvailable) then
          OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
        atempResponse.Position := 0;
        tempResponse.CopyFrom(atempResponse, atempResponse.Size);
        FreeAndNil(atempResponse);
        tempResponse.Position := 0;
        if not IgnoreEvents then
          if Assigned(OnAfterRequest) then
            OnAfterRequest(AUrl, rtPost, tempResponse);
      end
      else
      begin
        HttpRequest.FormPost(AUrl, vTempHeaders, atempResponse);
        Result := HttpRequest.ResponseStatusCode;
        if Assigned(OnHeadersAvailable) then
          OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
        atempResponse.Position := 0;
        CustomBody.CopyFrom(atempResponse, atempResponse.Size);
        FreeAndNil(atempResponse);
        CustomBody.Position := 0;
        if not IgnoreEvents then
          if Assigned(OnAfterRequest) then
            OnAfterRequest(AUrl, rtPost, CustomBody);
      end;
    finally
      if not Assigned(CustomBody) then
      begin
        if Assigned(tempResponse) then
          FreeAndNil(tempResponse);
      end;
      vTempHeaders.Free;
      if Assigned(atempResponse) then
        FreeAndNil(atempResponse);
      SendParams.Free;
    end;
  except
  {
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result := E.ErrorCode;
      If E.ErrorMessage <> '' Then
       Raise Exception.Create(E.ErrorMessage)
      Else
       Raise Exception.Create(E.Message);
     End;
   End;
   }
    On E: ESocketError do
    begin
      //HttpRequest.Disconnect(false);
      FreeAndNil(HttpRequest);
      raise;
    end;
  end;
  DestroyClient;
end;

function TRESTDWFhttpClientREST.Post(AUrl: string = '';
  CustomHeaders: TStringList = nil;
  const CustomBody: TMultipartFormDataStream = nil;
  const AResponse: TStream = nil; IgnoreEvents: boolean = False;
  RawHeaders: boolean = False): integer;
var
  vTempHeaders: TStringList;
  atempResponse, temp, tempResponse: TStringStream;
  SendParams: TMultipartFormDataStream;
  aString, sResponse: string;
begin
  Result := 200;
  Temp := nil;
  SendParams := TMultipartFormDataStream.Create;
  try
    tempResponse := nil;
    SetParams;
    SetUseSSL(UseSSL);
    vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
    if not Assigned(AResponse) then
    begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
    end;
    vAUrl := AUrl;
    try
      SetHeaders(TStringList(DefaultCustomHeader));

      if not IgnoreEvents then
        if Assigned(OnBeforePost) then
          if not Assigned(CustomHeaders) then
            OnBeforePost(AUrl, vTempHeaders)
          else
            OnBeforePost(AUrl, CustomHeaders);

      CopyStringList(CustomHeaders, vTempHeaders);
      if not Assigned(CustomBody) then
        SetRawHeaders(vTempHeaders, SendParams);
      if not Assigned(AResponse) then
      begin
        HttpRequest.FormPost(AUrl, RawByteString(SendParams), atempResponse);
        Result := HttpRequest.ResponseStatusCode;
        if Assigned(OnHeadersAvailable) then
          OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
        atempResponse.Position := 0;
        if RequestCharset = esUtf8 then
          aString := utf8Decode(atempResponse.DataString)
        else
          aString := tempResponse.DataString;
        StringToStream(tempResponse, aString);
        FreeAndNil(atempResponse);
        tempResponse.Position := 0;
        if not IgnoreEvents then
          if Assigned(OnAfterRequest) then
            OnAfterRequest(AUrl, rtPost, tempResponse);
      end
      else
      begin
        if Assigned(CustomBody) then
          HttpRequest.FormPost(AUrl, RawByteString(CustomBody), AResponse)
        else if Assigned(SendParams) then
          HttpRequest.FormPost(AUrl, RawByteString(SendParams), AResponse)
        else
          HttpRequest.FormPost(AUrl, RawByteString(CustomHeaders), AResponse);
        Result := HttpRequest.ResponseStatusCode;
        if (HttpRequest.ResponseStatusCode > 299) then
          if Trim(sResponse) = '' then
            sResponse := HttpRequest.ResponseStatusText;
        if Assigned(OnHeadersAvailable) then
          OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
        if Trim(sResponse) <> '' then
        begin
          if RequestCharset = esUtf8 then
            aString := utf8Decode(sResponse)
          else
            aString := sResponse;
        end;
        AResponse.Position := 0;
        if not IgnoreEvents then
          if Assigned(OnAfterRequest) then
            OnAfterRequest(AUrl, rtPost, AResponse);
      end;
    finally
      FreeAndNil(vTempHeaders);
      if Assigned(tempResponse) then
        FreeAndNil(tempResponse);
      if Assigned(atempResponse) then
        FreeAndNil(atempResponse);
      FreeAndNil(SendParams);
    end;
  except
  {
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) Or
       (E.ErrorCode            > 0) Then
     Begin
      Result := E.ErrorCode;
      If E.ErrorMessage <> '' Then
       Begin
        If E.Message <> '' Then
         If E.Message <> E.ErrorMessage then
          //temp := TStringStream.Create(E.Message + ' - ' + E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF})
         Else
          temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
       End
      Else
       temp := TStringStream.Create(E.Message{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      FreeAndNil(temp);
      DestroyClient;
     End;
   End;
   }
    On E: ESocketError do
    begin
      if Assigned(temp) then
        FreeAndNil(temp);
      //HttpRequest.Disconnect(false);
      FreeAndNil(HttpRequest);
      DestroyClient;
      raise;
    end;
  end;
end;

function TRESTDWFhttpClientREST.Post(AUrl: string = '';
  CustomHeaders: TStringList = nil; CustomBody: TStringList = nil;
  const AResponse: TStringStream = nil; IgnoreEvents: boolean = False;
  RawHeaders: boolean = False): integer;
var
  temp: TStringStream;
  vTempHeaders: TStringList;
  atempResponse, tempResponse: TStringStream;
  SendParams: TStringList; //TIdMultipartFormDataStream;
begin
  Result := 200;
  SendParams := TStringList.Create;
  try
    tempResponse := nil;
    SetParams;
    SetUseSSL(UseSSL);
    vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
    if not Assigned(AResponse) then
    begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
    end;
    vAUrl := AUrl;
    try
      //Copy Custom Headers
      //   If Assigned(CustomHeaders) Then
      SetHeaders(CustomHeaders);
      if not IgnoreEvents then
        if Assigned(OnBeforePost) then
          if not Assigned(CustomHeaders) then
            OnBeforePost(AUrl, vTempHeaders)
          else
            OnBeforePost(AUrl, CustomHeaders);
      if not Assigned(AResponse) then
      begin
        HttpRequest.FormPost(AUrl, CustomBody, atempResponse);
        Result := HttpRequest.ResponseStatusCode;
        if Assigned(OnHeadersAvailable) then
          OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
        atempResponse.Position := 0;
        if atempResponse.Size = 0 then
        begin
          if RequestCharset = esUtf8 then
            tempResponse.WriteString(utf8Decode(HttpRequest.ResponseHeaders.Text))
          else
            tempResponse.WriteString(HttpRequest.ResponseHeaders.Text);
        end
        else
        begin
          if RequestCharset = esUtf8 then
            tempResponse.WriteString(utf8Decode(atempResponse.DataString))
          else
            tempResponse.WriteString(atempResponse.DataString);
        end;
        FreeAndNil(atempResponse);
        tempResponse.Position := 0;
        if not IgnoreEvents then
          if Assigned(OnAfterRequest) then
            OnAfterRequest(AUrl, rtPost, tempResponse);
      end
   {
   Else
    Begin
     temp := Nil;
     If Assigned(CustomBody) Then
      temp         := TStringStream.Create(CustomBody.Text);
     HttpRequest.FormPost(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseStatusCode;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(TStringList(HttpRequest.ResponseHeaders), True);
     atempResponse.Position := 0;
     If atempResponse.Size = 0 Then
      Begin
       If RequestCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(HttpRequest.ResponseHeaders.Text))
       Else
        AResponse.WriteString(HttpRequest.ResponseHeaders.Text);
      End
     Else
      Begin
       If RequestCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(atempResponse.DataString))
       Else
        AResponse.WriteString(atempResponse.DataString);
      End;
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
    }
    finally
      vTempHeaders.Free;
      if Assigned(tempResponse) then
        tempResponse.Free;
      if Assigned(atempResponse) then
        atempResponse.Free;
      SendParams.Free;
      if Assigned(temp) then
        temp.Free;
    end;
  except
  {
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
   }
    On E: ESocketError do
    begin
      //HttpRequest.Disconnect(false);
      FreeAndNil(HttpRequest);
      raise;
    end;
  end;
end;

{
Function   TRESTDWFhttpClientREST.Post(AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TStringList; //TIdMultipartFormDataStream;
 aString      : String;
Begin
 Result:= 200;
 SendParams   := TStringList.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddStrings('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Post(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

}
 {
Function   TRESTDWFhttpClientREST.Post(AUrl              : String;
                                    Var AResponseText : String;
                                    CustomHeaders     : TStringList    = Nil;
                                    CustomParams      : TStringList    = Nil;
                                    Const CustomBody  : TStream       = Nil;
                                    Const AResponse   : TStream        = Nil;
                                    IgnoreEvents      : Boolean        = False;
                                    RawHeaders        : Boolean        = False) : Integer;
Var
 temp         : TStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TStringList; //TIdMultipartFormDataStream;
 aString,
 sResponse    : string;
Begin
 Result:= 200;
 SendParams   := TStringList.Create;
 temp         := Nil;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   If Assigned(CustomBody) Then
    Begin
     SendParams.Clear;
     SendParams.Write(CustomBody, CustomBody.Size);
    End
   Else
    SetRawHeaders(vTempHeaders, SendParams);
//   If Assigned(CustomBody) Then
//    Begin
//     temp         := TMemoryStream.Create;
//     temp.CopyFrom(CustomBody, CustomBody.Size - CustomBody.Position);
//     temp.Position := 0;
//    End;
   If Not Assigned(AResponse) Then
    Begin
//     If Assigned(temp) Then
//      HttpRequest.Post(AUrl, Temp, atempResponse)
//     Else
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := tempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     If Assigned(CustomBody) Then
      HttpRequest.Post(AUrl, SendParams, AResponse)
     Else
      HttpRequest.Post(AUrl, CustomHeaders, AResponse);
     Result:= HttpRequest.ResponseCode;
     If (HttpRequest.ResponseCode > 299) Then
      If Trim(sResponse) = '' Then
       sResponse := HttpRequest.ResponseText;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(sResponse)
     Else
      aString := sResponse;
//     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    FreeAndNil(tempResponse);
   If Assigned(atempResponse) Then
    FreeAndNil(atempResponse);
   SendParams.Free;
   If Assigned(temp) Then
    FreeAndNil(temp);
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      If E.ErrorMessage <> '' Then
     descomentar de caso voltar // temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF})
      Else
       temp := TStringStream.Create(E.Message{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;


}
 {
Function   TRESTDWFhttpClientREST.Post(AUrl            : String;

                                    CustomHeaders   : TStringList    = Nil;
                                    CustomParams    : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Var
 aString      : String;
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TStringList; //TIdMultipartFormDataStream;
Begin
 Result:= 200;
 SendParams   := TStringList.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Post(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
 //     AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;


Function  TRESTDWIdClientREST.Put(AUrl            : String         = '';
                                  CustomHeaders   : TStringList    = Nil;
                                  Const AResponse : TStream        = Nil;
                                  IgnoreEvents    : Boolean        = False):Integer;
Var
 aString      : String;
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse,
 SendParams   : TStringStream;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(AResponse, aString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
  //    temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl            : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   Const CustomBody : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 aString      : String;
Begin
 Result:= 200;
 Try
  temp         := Nil;
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   If Assigned(CustomBody) Then
    temp         := TStringStream.Create(TStringStream(CustomBody).DataString);
   HttpRequest.Put(AUrl, temp, atempResponse);
   Result:= HttpRequest.ResponseCode;
   If Assigned(temp) Then
    FreeAndNil(temp);
   atempResponse.Position := 0;
   If atempResponse.Size = 0 Then
    Begin
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(HttpRequest.Response.RawHeaders.Text)
     Else
      aString := HttpRequest.Response.RawHeaders.Text;
    End
   Else
    Begin
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
    End;
   FreeAndNil(atempResponse);
   StringToStream(AResponse, aString);
   AResponse.Position := 0;
   If Not IgnoreEvents Then
   If Assigned(OnAfterRequest) then
    OnAfterRequest(AUrl, rtPut, AResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   FileName         : String         = '';
                                   FileStream       : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 aString      : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(tempResponse, aString);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Put(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
  //    temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   CustomParams     : TStringList    = Nil;
                                   Const CustomBody : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(AResponse, aString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
  //    temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   CustomParams     : TStringList    = Nil;
                                   FileName         : String         = '';
                                   FileStream       : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Put(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
 //     temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;//TIdMultipartFormDataStream.Create;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePatch) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePatch(AUrl, vTempHeaders)
    Else
     OnBeforePatch(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   HttpRequest.Request.Date := Now;
   If Not Assigned(AResponse) Then
    Begin
     temp := TStringStream.Create(vTempHeaders.Text);
 //    {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
        If Assigned(SendParams) Then
         Begin
          If SendParams.Size = 0 Then
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
          Else
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
         End
        Else
         TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, []);
        {$IFEND}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPatch, tempResponse);
    End
   Else
    Begin
     temp := TStringStream.Create(StringReplace(vTempHeaders.Text, sLineBreak, '', [rfReplaceAll]));
     temp.Position := 0;
 //    {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
         If Assigned(SendParams) Then
          Begin
           If SendParams.Size = 0 Then
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
           Else
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
          End
         Else
          TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, Nil, []);
        {$IFEND}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     If atempResponse.Size > 0 Then
      Begin
       atempResponse.Position := 0;
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(atempResponse.DataString)
       Else
        aString := atempResponse.DataString;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End
     Else
      Begin
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(HttpRequest.ResponseText)
       Else
        aString := HttpRequest.ResponseText;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End;
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Assigned(atempResponse) Then
      FreeAndNil(atempResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
 //     temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function  TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomBody      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;//TIdMultipartFormDataStream.Create;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePatch) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePatch(AUrl, vTempHeaders)
    Else
     OnBeforePatch(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   HttpRequest.Request.Date := Now;
   If Not Assigned(AResponse) Then
    Begin
     temp := TStringStream.Create(vTempHeaders.Text);
     If Assigned(CustomBody) Then
      temp         := TStringStream.Create(TStringStream(CustomBody).DataString);
 //    {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
        If Assigned(SendParams) Then
         Begin
          If SendParams.Size = 0 Then
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
          Else
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
         End
        Else
         TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, []);
        {$IFEND}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(tempResponse, aString);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPatch, tempResponse);
    End
   Else
    Begin
     temp := TStringStream.Create(StringReplace(vTempHeaders.Text, sLineBreak, '', [rfReplaceAll]));
     temp.Position := 0;
 //    {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
         If Assigned(SendParams) Then
          Begin
           If SendParams.Size = 0 Then
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
           Else
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
          End
         Else
          TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, Nil, []);
        {$IFEND}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     If atempResponse.Size > 0 Then
      Begin
       atempResponse.Position := 0;
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(atempResponse.DataString)
       Else
        aString := atempResponse.DataString;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End
     Else
      Begin
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(HttpRequest.ResponseText)
       Else
        aString := HttpRequest.ResponseText;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End;
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Assigned(atempResponse) Then
      FreeAndNil(atempResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
//      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     CustomParams    : TStringList    = Nil;
                                     CustomBody      : TStream        = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   If Not Assigned(AResponse) Then
    Begin
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(tempResponse, aString);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(AResponse, aString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
//      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     CustomParams    : TStringList    = Nil;
                                     FileName        : String         = '';
                                     FileStream      : TStream        = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
 //     temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Delete(AUrl            : String         = '';
                                      CustomHeaders   : TStringList    = Nil;
                                      Const AResponse : TStream        = Nil;
                                      IgnoreEvents    : Boolean        = False):Integer;
Var
 vTempHeaders  : TStringList;
 Temp,
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeDelete(AUrl, vTempHeaders)
    Else
     OnBeforeDelete(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   {$IFDEF FPC}
    HttpRequest.Delete(AUrl, atempResponse);
   {$ELSE}
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, AUrl, SendParams, atempResponse, []);
   {$ENDIF}
   Result:= HttpRequest.ResponseCode;
   If Assigned(atempResponse) Then
    atempResponse.Position := 0;
   If RequestCharset = esUtf8 Then
    aString := utf8Decode(atempResponse.DataString)
   Else
    aString := atempResponse.DataString;
   StringToStream(tempResponse, aString);
   tempResponse.Position := 0;
   FreeAndNil(atempResponse);
   If Not IgnoreEvents Then
   If Assigned(OnAfterRequest) then
    OnAfterRequest(AUrl, rtDelete, tempResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(SendParams) Then
    SendParams.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
 //     temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      Temp.Free;
     End;
   End;
  On E : EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Delete(AUrl              : String;
                                      CustomHeaders     : TStringList  = Nil;
                                      CustomParams      : TStringList  = Nil;
                                      Const AResponse   : TStream      = Nil;
                                      IgnoreEvents      : Boolean      = False):Integer;
Var
 vTempHeaders : TStringList;
 Temp,
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeDelete(AUrl, vTempHeaders)
    Else
     OnBeforeDelete(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   {$IFDEF FPC}
    HttpRequest.Delete(AUrl, atempResponse);
   {$ELSE}
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, AUrl, SendParams, atempResponse, []);
   {$ENDIF}
   Result:= HttpRequest.ResponseCode;
   If Assigned(atempResponse) Then
    atempResponse.Position := 0;
   If RequestCharset = esUtf8 Then
    aString := utf8Decode(atempResponse.DataString)
   Else
    aString := atempResponse.DataString;
   StringToStream(AResponse, aString);
   AResponse.Position := 0;
   FreeAndNil(atempResponse);
   If Not IgnoreEvents Then
   If Assigned(OnAfterRequest) then
    OnAfterRequest(AUrl, rtDelete, tempResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(SendParams) Then
    SendParams.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
//      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      Temp.Free;
     End;
   End;
  On E : EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise
   End;
 End;
 DestroyClient;
End;

}
constructor TRESTDWFhttpClientREST.Create(AOwner: TComponent);
begin
  inherited;
  //application/json
  ContentType := cContentTypeFormUrl;
  ContentEncoding := cDefaultContentEncoding;
  Accept := cDefaultAccept;
  AcceptEncoding := '';
  MaxAuthRetries := 0;
  UserAgent := cUserAgent;
  AccessControlAllowOrigin := '*';
  ActiveRequest := '';
  RedirectMaximum := 1;
  RequestTimeOut := 5000;
  ConnectTimeOut := 5000;
  ssl := nil;
end;

{$IFNDEF FPC}
{$IFNDEF DELPHI_10TOKYO_UP}
function TRESTDWIdClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(
  Certificate: TIdX509; AOk: boolean): boolean;
begin
  Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, -1);
end;

function TRESTDWIdClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(
  Certificate: TIdX509; AOk: boolean; ADepth: integer): boolean;
begin
  Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, ADepth, -1);
end;

{$ENDIF}
{$ENDIF}
function TRESTDWFhttpClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(
  Certificate: TX509Certificate; AOk: boolean; ADepth, AError: integer): boolean;
begin
  Result := AOk;
  if not vVerifyCert then
    Result := True;
end;

procedure TRESTDWFhttpClientREST.pOnWork(Sender: TObject;
  const ContentLength, CurrentPos: int64);
begin
  OnWork(Sender, ContentLength);
end;

procedure TRESTDWFhttpClientREST.Getpassword(var Password: string);
begin
  if Assigned(vOnGetpassword) then
    vOnGetpassword(Password);
end;

function TRESTDWFhttpClientREST.GetVerifyCert: boolean;
begin
  Result := vVerifyCert;
end;

procedure TRESTDWFhttpClientREST.SetVerifyCert(aValue: boolean);
begin
  vVerifyCert := aValue;
end;

procedure TRESTDWFhttpClientREST.SetCertOptions;
begin
 {
 If Assigned(ssl) Then
  Begin
   {$IFDEF FPC}
    ssl.OnGetPassword          := @Getpassword;
   {$ELSE}
    ssl.OnGetPassword          := Getpassword;
   {$ENDIF}
   ssl.SSLOptions.CertFile     := vCertFile;
   ssl.SSLOptions.KeyFile      := vKeyFile;
   ssl.SSLOptions.RootCertFile := vRootCertFile;
   ssl.Host                    := vHostCert;
   ssl.Port                    := vPortCert;
   ssl.SSLOptions.Mode         := vCertMode;
  End;
  }
end;

procedure TRESTDWFhttpClientREST.pOnStatus(ASender: TObject;
  const AStatus: TStatus; const AStatusText: string);
begin
  OnStatus(ASender, TConnStatus(AStatus), AStatusText);
end;

procedure TRESTDWFhttpClientREST.pOnWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  OnWorkEnd(ASender);
end;

procedure TRESTDWFhttpClientREST.pOnWorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCount: int64);
begin
  OnWorkBegin(ASender, AWorkCount);
end;

procedure TRESTDWFhttpClientREST.SetHeaders(AHeaders: TStringList;
  var SendParams: TMultipartFormDataStream);
var
  I: integer;
begin
  // HttpRequest.Request.CustomHeaders.Clear;
  // HttpRequest.Request.AcceptEncoding := AcceptEncoding;
  if AccessControlAllowOrigin <> '' then
  begin
    if SendParams <> nil then
    begin
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
      HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin',
        AccessControlAllowOrigin);
      {$ELSE}
       HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', AccessControlAllowOrigin);
      {$IFEND}
     {$ELSE}
      HttpRequest.AddHeader('Access-Control-Allow-Origin',  AccessControlAllowOrigin);
     {$ENDIF}
    end;
  end;
  if Assigned(AHeaders) then
  begin
    if AHeaders.Count > 0 then
    begin
      for i := 0 to AHeaders.Count - 1 do
      begin
        if SendParams = nil then
        begin
          if (AHeaders.Names[i] <> '') or (AHeaders.ValueFromIndex[i] <> '') then
          begin
            if RequestCharset = esUtf8 then
              HttpRequest.AddHeader(AHeaders.Names[i],
                utf8Decode(AHeaders.ValueFromIndex[i]))
            else
              HttpRequest.AddHeader(AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
          end;
        end
        else
        begin
          if (AHeaders.Names[i] <> '') or (AHeaders.ValueFromIndex[i] <> '') then
          begin
            if RequestCharset = esUtf8 then
              SendParams.AddFormField(AHeaders.Names[i],
                utf8Decode(AHeaders.ValueFromIndex[i]))
            else
              SendParams.AddFormField(AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
          end;
        end;
      end;
    end;
  end;
end;

procedure TRESTDWFhttpClientREST.SetRawHeaders(AHeaders: TStringList;
  var SendParams:TMultipartFormDataStream);
var
  I: integer;
begin
  HttpRequest.RequestHeaders.Clear;
  // HttpRequest.Request.CustomHeaders.Clear;
  if AccessControlAllowOrigin <> '' then
  begin
    if SendParams <> nil then
    begin
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
      SendParams.AddFormField('Access-Control-Allow-Origin', AccessControlAllowOrigin);
      {$ELSE}
       SendParams.AddFormField('Access-Control-Allow-Origin', AccessControlAllowOrigin);
      {$IFEND}
     {$ELSE}
      SendParams.AddFormField('Access-Control-Allow-Origin',  AccessControlAllowOrigin);
     {$ENDIF}
      // HttpRequest.Request.ContentEncoding := cContentTypeMultiPart;
    end;
  end;
  if Assigned(AHeaders) then
  begin
    if AHeaders.Count > 0 then
    begin
      for i := 0 to AHeaders.Count - 1 do
      begin
        if SendParams = nil then
        begin
          if RequestCharset = esUtf8 then
            HttpRequest.RequestHeaders.Add(utf8Decode(AHeaders[i]))
          else
            HttpRequest.RequestHeaders.Add(AHeaders[i]);
        end
        else
        begin
          if RequestCharset = esUtf8 then
            SendParams.AddFormField(AHeaders.Names[i], utf8Decode(AHeaders.ValueFromIndex[i]))
          else
            SendParams.AddFormField(AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
        end;
      end;
    end;
  end;
end;

procedure TRESTDWFhttpClientREST.SetUseSSL(Value: boolean);
begin
  inherited;
 {
 If Assigned(HttpRequest) Then
  HttpRequest.IOHandler := Nil;
 If Value Then
  Begin
   If ssl = Nil Then
    Begin
     ssl               := TIdSSLIOHandlerSocketOpenSSL.Create(HttpRequest);
     {$IFDEF FPC}
      ssl.OnVerifyPeer := @IdSSLIOHandlerSocketOpenSSL1VerifyPeer;
     {$ELSE}
      ssl.OnVerifyPeer := IdSSLIOHandlerSocketOpenSSL1VerifyPeer;
     {$ENDIF}
    End;
    ssl.SSLOptions.SSLVersions := vSSLVersions;

   SetCertOptions;
   If Assigned(HttpRequest) Then
    HttpRequest.IOHandler := ssl;
  End
 Else
  Begin
   If Assigned(ssl) Then
    FreeAndNil(ssl);
  End;
  }
end;

procedure TRESTDWFhttpClientREST.SetHeaders(AHeaders: TStringList);
var
  I: integer;
  vmark: string;
  DWParams: TRESTDWParams;
begin
 {$IFNDEF FPC}
  inherited;
 {$ENDIF}
  vmark := '';
  DWParams := nil;
  //HttpRequest.Request.AcceptEncoding := AcceptEncoding;
  HttpRequest.RequestHeaders.Clear;
  // HttpRequest.Request.CustomHeaders.NameValueSeparator := cNameValueSeparator;
 {If Assigned(AHeaders) Then
  If AHeaders.Count > 0 Then
   HttpRequest.Request.FoldLines := False;
 If (AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken]) Then
  HttpRequest.Request.CustomHeaders.FoldLines := False;
 If AccessControlAllowOrigin <> '' Then
  Begin
   {$IFNDEF FPC}
    {$if CompilerVersion > 21}
     HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', AccessControlAllowOrigin);
    {$ELSE}
     HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', AccessControlAllowOrigin);
    {$IFEND}
   {$ELSE}
    HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin',  AccessControlAllowOrigin);
   {$ENDIF}
  End;
 }
  if Assigned(AHeaders) then
  begin
    if AHeaders.Count > 0 then
    begin
      for i := 0 to AHeaders.Count - 1 do
        HttpRequest.RequestHeaders.AddPair(AHeaders.Names[i],
          AHeaders.ValueFromIndex[i]);
    end;
  end;
 {
 If AuthenticationOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken, rdwOAuth] Then
  Begin
   HttpRequest.Request.BasicAuthentication := AuthenticationOptions.AuthorizationOption = rdwAOBasic;
   Case AuthenticationOptions.AuthorizationOption of
    rdwAOBasic  : Begin
                   If HttpRequest.Request.Authentication = Nil Then
                    HttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
                   HttpRequest.Request.Authentication.Password := TRESTDWAuthOptionBasic(AuthenticationOptions.OptionParams).Password;
                   HttpRequest.Request.Authentication.Username := TRESTDWAuthOptionBasic(AuthenticationOptions.OptionParams).UserName;
                  End;
    rdwAOBearer : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   HttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token);
                  End;
    rdwAOToken  : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   HttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token]));
                  End;
    rdwOAuth    : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   ActiveRequest := Stringreplace(lowercase(ActiveRequest), 'http://', '', [rfReplaceAll]);
                   ActiveRequest := Stringreplace(lowercase(ActiveRequest), 'https://', '', [rfReplaceAll]);
                   TRESTDWDataUtils.ParseRESTURL(ActiveRequest, RequestCharset, vmark{$IFDEF FPC}, csUndefined{$ENDIF}, DWParams);
                   If Assigned(DWParams) Then
                    FreeAndNil(DWParams);
//                   If (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(UriOptions.EventName))   Or
//                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent))  Or
//                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.EventName))  Or
//                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.ServerEvent)) Then
//                    Begin
//                     If (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.EventName))  Or
//                        (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent)) Then
//                      Begin
//                       If TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).AutoBuildHex Then
//                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
//                                                                                                               TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
//                                                                                                               {$IFDEF FPC}, csUndefined{$ENDIF})]))
//                       Else
//                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
//                                                                                                               TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
//                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]));
//                      End;
//                    End
//                   Else
//                    Begin
                     Case TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).TokenType Of
                      rdwOATBasic  : Begin
                                      If TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).AutoBuildHex Then
                                       HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
                                                                                                                              TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
                                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]))
                                      Else
                                       HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
                                                                                                                              TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
                                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]));
                                     End;
                      rdwOATBearer : HttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).Token);
                      rdwOATToken  : HttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).Token]));
                     End;
//                    End;
                  End;
   End;
  End;
 }
end;

procedure TRESTDWFhttpClientREST.SetOnStatus(Value: TOnStatus);
begin
  inherited SetOnStatus(Value);
end;

procedure TRESTDWFhttpClientREST.SetOnWork(Value: TOnWork);
begin
  inherited SetOnWork(Value);
end;

procedure TRESTDWFhttpClientREST.SetOnWorkBegin(Value: TOnWork);
begin
  inherited SetOnWorkBegin(Value);
end;

procedure TRESTDWFhttpClientREST.SetOnWorkEnd(Value: TOnWorkEnd);
begin
  inherited SetOnWorkEnd(Value);
end;

procedure TRESTDWFhttpServicePooler.aCommandGet(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
var
  zCount, k : Integer;
  z, zList : string;
   sCharSet, vToken, ErrorMessage, vAuthRealm, vContentType, vResponseString: string;
  I, StatusCode: integer;
  ResultStream: TStream;
  vCORSHeader: TStrings;
  vResponseHeader, vRawHeaderList: TStringList;
  mb: TStringStream;
  vRedirect: TRedirect;

  procedure WriteError;    { #todo -oAnderson : Verificar se esse WriteError é usado em algum lugar }
  begin
    AResponse.Code := StatusCode;
  {$IFNDEF FPC}
    //  mb                                   := TStringStream.Create(ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
    mb.Position := 0;
    AResponseInfo.FreeContentStream := True;
    AResponseInfo.ContentStream := mb;
    AResponseInfo.ContentStream.Position := 0;
    AResponseInfo.ContentLength := mb.Size;
    AResponseInfo.WriteContent;
  {$ELSE}
   mb                                   := TStringStream.Create(ErrorMessage);
   mb.Position                          := 0;
   AResponse.FreeContentStream      := True;
   AResponse.ContentStream          := mb;
   AResponse.ContentStream.Position := 0;
   AResponse.ContentLength          := -1;//mb.Size;
   //AResponse.SendContent;  {TODO : Verificar o SendContet com o WriteContet do Indy}
  {$ENDIF}
  end;

  procedure DestroyComponents;
  begin
    if Assigned(vResponseHeader) then
      FreeAndNil(vResponseHeader);
    if Assigned(vCORSHeader) then
      FreeAndNil(vCORSHeader);
    if Assigned(vRawHeaderList) then
      FreeAndNil(vRawHeaderList);
  end;

  procedure Redirect(Url: string);
  begin
    AResponse.SendRedirect(Url);
  end;

  procedure SetReplyCORS;
  var
    I: integer;
  begin
    if CORS then
    begin
      if CORS_CustomHeaders.Count > 0 then
      begin
        for I := 0 to CORS_CustomHeaders.Count - 1 do
          AResponse.CustomHeaders.AddPair(CORS_CustomHeaders.Names[I],
            CORS_CustomHeaders.ValueFromIndex[I]);
      end
      else
        AResponse.CustomHeaders.AddPair('Access-Control-Allow-Origin', '*');
      if Assigned(vCORSHeader) then
      begin
        if vCORSHeader.Count > 0 then
        begin
          for I := 0 to vCORSHeader.Count - 1 do
            AResponse.CustomHeaders.AddPair(vCORSHeader.Names[I],
              vCORSHeader.ValueFromIndex[I]);
        end;
      end;
    end;
  end;

begin
  vResponseHeader := TStringList.Create;
  vCORSHeader := TStringList.Create;
  vResponseString := '';
 {$IFNDEF FPC}
  @vRedirect := @Redirect;
 {$ELSE}
  vRedirect      := TRedirect(@Redirect);
 {$ENDIF}
  try
  {$IFNDEF FPC}
   {$IF Defined(HAS_FMX)}
    {$IFDEF HAS_UTF8}
     If Assigned({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}) Then
      vToken       := TRESTDWAuthOptionTokenClient({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}).Token;
    {$ELSE}
    if Assigned(AContext.Data) then
      vToken := TRESTDWAuthOptionTokenClient(AContext.Data).Token;
    {$ENDIF}
   {$ELSE}
    If Assigned(AContext.Data) Then
     vToken       := TRESTDWAuthOptionTokenClient(AContext.Data).token;
   {$IFEND}
  {$ELSE}
  // If Assigned(AContext.Data) Then
  //  vToken       := TRESTDWAuthOptionTokenClient(AContext.Data).Token;
  {$ENDIF}
    vAuthRealm := AResponse.Authorization;
    vContentType := AResponse.ContentType;

    vRawHeaderList := nil;
    vRawHeaderList := TStringList.Create;
    vRawHeaderList.NameValueSeparator:= ':';
    zCount:= ARequest.FieldCount;
    for k:=0 to ARequest.FieldCount -1 do
    begin
      vRawHeaderList.AddPair(ARequest.FieldNames[k], ARequest.FieldValues[k]);
      zList:= zList + ' FieldName:' + ARequest.FieldNames[k] + ' FieldValue:' + ARequest.FieldValues[k];
    end;

    z :=  'Unknown:'+ ARequest.GetHTTPVariable (hvUnknown        ) + ' ' +
	  'HttpVersion:'+ ARequest.GetHTTPVariable(hvHTTPVersion    ) + ' ' +
	  'Method:'+ ARequest.GetHTTPVariable(hvMethod         ) + ' ' +
	  'Cookie:'+ ARequest.GetHTTPVariable(hvCookie         ) + ' ' +
	  'SetCookie:'+ ARequest.GetHTTPVariable(hvSetCookie      ) + ' ' +
	  'RequestWith:'+ ARequest.GetHTTPVariable(hvXRequestedWith ) + ' ' +
	  'PathInfo:'+ ARequest.GetHTTPVariable(hvPathInfo       ) + ' ' +
	  'PathTranslated:'+ ARequest.GetHTTPVariable(hvPathTranslated ) + ' ' +
	  'RemoteAdress:'+ ARequest.GetHTTPVariable(hvRemoteAddress  ) + ' ' +
	  ''+ ARequest.GetHTTPVariable(hvRemoteHost     ) + ' ' +
	  'ScriptName:'+ ARequest.GetHTTPVariable(hvScriptName     ) + ' ' +
	  'ServerPort:'+ ARequest.GetHTTPVariable(hvServerPort     ) + ' ' +
	  'Url:'+ ARequest.GetHTTPVariable(hvURL            ) + ' ' +
	  'Query'+ ARequest.GetHTTPVariable(hvQuery          ) + ' ' +
	  'Content'+ ARequest.GetHTTPVariable(hvContent);

    if CommandExec(TComponent(ARequest),
                   RemoveBackslashCommands(ARequest.GetHTTPVariable(hvPathInfo)),
                   ARequest.GetHTTPVariable(hvMethod)  + ' ' + ARequest.GetHTTPVariable(hvURL) + ' HTTP/' + ARequest.GetHTTPVariable(hvHTTPVersion),
                   vContentType,
                   '0.0.0.0',//ARequest.Binding.PeerIP,
                  ARequest.GetFieldByName('User-Agent'),
                   '',
                   '', //ARequest.AuthPassword,
                   vToken,
                   ARequest.CustomHeaders,
                   0, //ARequest.Binding.PeerPort,
                   vRawHeaderList,
                   ARequest.QueryFields,
                   ARequest.QueryString,
                   nil, //ARequest.PostStream,
                   vAuthRealm,
                   sCharSet,
                   ErrorMessage,
                   StatusCode,
                   vResponseHeader,
                   vResponseString,
                   ResultStream,
                   vCORSHeader,
                   vRedirect) then
    begin
      SetReplyCORS;
      AResponse.Authorization := vAuthRealm;
      AResponse.ContentType := vContentType;


      zCount:= AResponse.FieldCount;
    for k:=0 to AResponse.FieldCount -1 do
    begin
     // vRawHeaderList.AddPair(ARequest.FieldNames[k], ARequest.FieldValues[k]);
      zList:= zList + ' FieldName:' + AResponse.FieldNames[k] + ' FieldValue:' + AResponse.FieldValues[k];
    end;

    z :=  'Unknown:'+ AResponse.GetHTTPVariable (hvUnknown        ) + ' ' +
	  'HttpVersion:'+ AResponse.GetHTTPVariable(hvHTTPVersion    ) + ' ' +
	  'Method:'+ AResponse.GetHTTPVariable(hvMethod         ) + ' ' +
	  'Cookie:'+ AResponse.GetHTTPVariable(hvCookie         ) + ' ' +
	  'SetCookie:'+ AResponse.GetHTTPVariable(hvSetCookie      ) + ' ' +
	  'RequestWith:'+ AResponse.GetHTTPVariable(hvXRequestedWith ) + ' ' +
	  'PathInfo:'+ AResponse.GetHTTPVariable(hvPathInfo       ) + ' ' +
	  'PathTranslated:'+ AResponse.GetHTTPVariable(hvPathTranslated ) + ' ' +
	  'RemoteAdress:'+ AResponse.GetHTTPVariable(hvRemoteAddress  ) + ' ' +
	  ''+ AResponse.GetHTTPVariable(hvRemoteHost     ) + ' ' +
	  'ScriptName:'+ AResponse.GetHTTPVariable(hvScriptName     ) + ' ' +
	  'ServerPort:'+ AResponse.GetHTTPVariable(hvServerPort     ) + ' ' +
	  'Url:'+ AResponse.GetHTTPVariable(hvURL            ) + ' ' +
	  'Query'+ AResponse.GetHTTPVariable(hvQuery          ) + ' ' +
	  'Content'+ AResponse.GetHTTPVariable(hvContent);



    {If Encoding = esUtf8 Then
     AResponse.CharSet := 'utf-8'
    Else
     AResponseo.CharSet := 'ansi';  }
      AResponse.Code := StatusCode;
      if (vResponseString <> '') or (ErrorMessage <> '') then
      begin
        if Assigned(ResultStream) then
          FreeAndNil(ResultStream);
        if (vResponseString <> '') then
          ResultStream := TStringStream.Create(vResponseString)
        else
          ResultStream := TStringStream.Create(ErrorMessage);
      end;
      if Assigned(ResultStream) then
      begin
        AResponse.FreeContentStream := True;
        AResponse.ContentStream := ResultStream;
        AResponse.ContentStream.Position := 0;
      end;
    {$IFNDEF FPC}
      if Assigned(ResultStream) then
        AResponseInfo.ContentLength := ResultStream.Size
      else
        AResponseInfo.ContentLength := -1;
    {$ELSE}
     if Assigned(ResultStream) then
      if (ResultStream.Size > 0) then
        AResponse.ContentLength           := ResultStream.Size;
    {$ENDIF}
      for I := 0 to vResponseHeader.Count - 1 do
        AResponse.CustomHeaders.AddPair(vResponseHeader.Names[I],
          vResponseHeader.Values[vResponseHeader.Names[I]]);
      if vResponseHeader.Count > 0 then
        AResponse.SendHeaders;
    //  AResponse.SendContent;   { #todo -oAnderson : Não é necessário o SendContent }
    end
    else //Tratamento de Erros.
    begin
      SetReplyCORS;
      AResponse.Authorization := vAuthRealm;
    {$IFNDEF FPC}
     {$if CompilerVersion > 21}
      if (sCharSet <> '') then
        AResponseInfo.CharSet := sCharSet;
     {$IFEND}
    {$ENDIF}
      AResponse.Code := StatusCode;
      if ErrorMessage <> '' then
        AResponse.CodeText := ErrorMessage
      else
      begin
        AResponse.FreeContentStream := True;
        AResponse.ContentStream := ResultStream;
        AResponse.ContentStream.Position := 0;
      {$IFNDEF FPC}
        AResponseInfo.ContentLength := ResultStream.Size;
      {$ELSE}
       AResponse.ContentLength         := -1;
      {$ENDIF}
      end;
    end;
  finally

    DestroyComponents;
  end;
end;

{
Procedure TRESTDWIdServicePooler.aCommandOther(AContext      : TIdContext;
                                               ARequestInfo  : TIdHTTPRequestInfo;
                                               AResponseInfo : TIdHTTPResponseInfo);
Begin
 aCommandGet(AContext, ARequestInfo, AResponseInfo);
End;

Procedure TRESTDWIdServicePooler.CustomOnConnect(AContext : TIdContext);
Begin
 AContext.Connection.Socket.ReadTimeout := RequestTimeout;
End;

Procedure TRESTDWIdServicePooler.IdHTTPServerQuerySSLPort(APort       : Word;
                                                          Var VUseSSL : Boolean);
Begin
 VUseSSL := (APort = Self.ServicePort);
End;
}
constructor TRESTDWFhttpServicePooler.Create(AOwner: TComponent);
begin
  inherited;
  HTTPServer := TFPHttpServer.Create(Owner);
  { #todo -oAnderson : ssockets.TSocketServer.SetNonBlocking ;anderson }

  //lHandler                         := TServerIOHandlerSSLOpenSSL.Create(Nil);
 {$IFDEF FPC}
// HTTPServer.OnQuerySSLPort        := @IdHTTPServerQuerySSLPort;
 HTTPServer.OnRequest             := @aCommandGet;
// HTTPServer.OnCommandOther        := @aCommandOther;
// HTTPServer.OnAllowConnect        := @CustomOnConnect;
// HTTPServer.OnCreatePostStream    := @CreatePostStream;
// HTTPServer.OnParseAuthentication := @OnParseAuthentication;
 DatabaseCharSet                  := csUndefined;
 {$ELSE}
  HTTPServer.OnQuerySSLPort := IdHTTPServerQuerySSLPort;
  HTTPServer.OnCommandGet := aCommandGet;
  HTTPServer.OnCommandOther := aCommandOther;
  HTTPServer.OnConnect := CustomOnConnect;
  HTTPServer.OnCreatePostStream := CreatePostStream;
  HTTPServer.OnParseAuthentication := OnParseAuthentication;
 {$ENDIF}
  //HTTPServer.MaxConnections      := -1;
end;

destructor TRESTDWFhttpServicePooler.Destroy;
begin
  try
    if HTTPServer.Active then
      HTTPServer.Active := False;
  except
  end;
 {$IF Defined(HAS_FMX)}
  lHandler.DisposeOf;
  HTTPServer.DisposeOf;
 {$ELSE}
  //FreeAndNil(lHandler);
  FreeAndNil(HTTPServer);
 {$IFEND}
  inherited;
end;

procedure TRESTDWFhttpServicePooler.EchoPooler(ServerMethodsClass, AContext: TComponent;
  var Pooler, MyIP: string; AccessTag: string; var InvalidTag: boolean);
var
  I: integer;
begin
 {$IFNDEF FPC}
  inherited;
 {$ENDIF}
  InvalidTag := False;
  MyIP := '';
  if ServerMethodsClass <> nil then
  begin
    for I := 0 to ServerMethodsClass.ComponentCount - 1 do
    begin
      if (ServerMethodsClass.Components[i].ClassType = TRESTDWPoolerDB) or
        (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) then
      begin
        if Pooler = Format('%s.%s', [ServerMethodsClass.ClassName,
          ServerMethodsClass.Components[i].Name]) then
        begin
          if Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' then
          begin
            if TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <>
              AccessTag then
            begin
              InvalidTag := True;
              Exit;
            end;
          end;
          if AContext <> nil then
              MyIP := TFPHTTPConnectionRequest(AContext).GetHTTPVariable(hvRemoteAddress);
            Break;
        end;
      end;
    end;
  end;
  if MyIP = '' then
    raise Exception.Create(cInvalidPoolerName);
end;

  {
Procedure TRESTDWIdServicePooler.CreatePostStream(AContext        : TIdContext;
                                                  AHeaders        : TIdHeaderList;
                                                  Var VPostStream : TStream);
Var
 headerIndex : Integer;
 vValueAuth  : String;
 vAuthValue  : TRESTDWAuthOptionTokenClient;
Begin
 headerIndex := AHeaders.IndexOfName('Authorization');
 If (headerIndex = -1) Then
  Begin
   {$IFNDEF FPC}
    {$IF Not Defined(HAS_FMX)}
     AContext.Data := Nil; // not an Authorization attempt
    {$ELSE}
     {$IFDEF HAS_UTF8}
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := Nil;
     {$ELSE}
      AContext.DataObject := Nil;
     {$ENDIF}
    {$IFEND}
   {$ELSE}
    AContext.Data := Nil; // not an Authorization attempt
   {$ENDIF}
   Exit;
  End
 Else
  Begin
   vValueAuth  := AHeaders[headerIndex];
   If (AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken])  And
      (Pos('basic', Lowercase(vValueAuth)) = 0) Then
    Begin
     vAuthValue       := TRESTDWAuthOptionTokenClient.Create;
     vAuthValue.Token := vValueAuth;
     {$IFNDEF FPC}
      {$IF Not Defined(HAS_FMX)}
       AContext.Data  := vAuthValue;
      {$ELSE}
       {$IFDEF HAS_UTF8}
        {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := vAuthValue;
       {$ELSE}
        AContext.DataObject := vAuthValue;
       {$ENDIF}
      {$IFEND}
     {$ELSE}
      AContext.Data   := vAuthValue;
     {$ENDIF}
     AHeaders.Delete(headerIndex);
    End;
  End;
End;

Procedure TRESTDWIdServicePooler.OnParseAuthentication(AContext    : TIdContext;
                                                   Const AAuthType, AAuthData: String;
                                                   Var VUsername, VPassword: String; Var VHandled: Boolean);
Var
 vAuthValue : TRESTDWAuthOptionTokenClient;
Begin
  {$IFNDEF FPC}
   {$IF Not Defined(HAS_FMX)}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.Data        = Nil) Then
     Begin
      vAuthValue       := TRESTDWAuthOptionTokenClient.Create;
      vAuthValue.Token := AAuthType + ' ' + AAuthData;
      AContext.Data    := vAuthValue;
      VHandled         := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
   {$ELSE}
    {$IFDEF HAS_UTF8}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       ({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}  = Nil) Then
     Begin
      vAuthValue          := TRESTDWAuthOptionTokenClient.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}       := vAuthValue;
      VHandled            := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ELSE}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.DataObject  = Nil) Then
     Begin
      vAuthValue          := TRESTDWAuthOptionTokenClient.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      AContext.DataObject := vAuthValue;
      VHandled            := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ENDIF}
   {$IFEND}
  {$ELSE}
   If (Lowercase(AAuthType) = Lowercase('bearer')) Or
      (Lowercase(AAuthType) = Lowercase('token'))  And
      (AContext.Data        = Nil) Then
    Begin
     vAuthValue       := TRESTDWAuthOptionTokenClient.Create;
     vAuthValue.Token := AAuthType + ' ' + AAuthData;
     AContext.Data    := vAuthValue;
     VHandled         := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
    End;
  {$ENDIF}
End;

Function  TRESTDWIdServicePooler.SSLVerifyPeer(Certificate : TIdX509;
                                               AOk         : Boolean;
                                               ADepth,
                                               AError      : Integer) : Boolean;

Begin
 If ADepth = 0 Then
  Result := AOk
 Else
  Result := True;
End;
 }
procedure TRESTDWFhttpServicePooler.SetActive(Value: boolean);
begin
  if (Value) and (not (HTTPServer.Active)) then
  begin
    if not (Assigned(ServerMethodClass)) and (Self.GetDataRouteCount = 0) then
      raise Exception.Create(cServerMethodClassNotAssigned);

    try
      if (ASSLPrivateKeyFile <> '') and (ASSLPrivateKeyPassword <> '') and
        (ASSLCertFile <> '') then
      begin
        lHandler.SSLType := aSSLMethod;
        // lHandler.SSLType                          := PIdSSLVersions(@SSLVersions)^;
      {$IFDEF FPC}
      //lHandler.OnGetPassword                    := @GetSSLPassword;
      //lHandler.OnVerifyPeer                     := @SSLVerifyPeer;
      {$ELSE}
        lHandler.OnGetPassword := GetSSLPassword;
        lHandler.OnVerifyPeer := SSLVerifyPeer;
      {$ENDIF}
    {  lHandler.SSLOptions.CertFile              := ASSLCertFile;
      lHandler.SSLOptions.KeyFile               := ASSLPrivateKeyFile;
      lHandler.SSLOptions.VerifyMode            := vSSLVerifyMode;
      lHandler.SSLOptions.VerifyDepth           := vSSLVerifyDepth;
      lHandler.SSLOptions.RootCertFile          := vASSLRootCertFile;
      lHandler.SSLOptions.Mode                  := vSSLMode;
      lHandler.SSLOptions.CipherList            := vCipherList;
      HTTPServer.IOHandler := lHandler;                          }
      end;
   { Else
     HTTPServer.IOHandler  := Nil;

    If HTTPServer.Bindings.Count > 0 Then
     HTTPServer.Bindings.Clear;
    }
      //Add IPv4 bind
      if ((ServerIPVersionConfig.ServerIpVersion = sivBoth) or
        (ServerIPVersionConfig.ServerIpVersion = sivIPv4)) then
      begin
        with HTTPServer do
        begin
          // HostName := ServerIPVersionConfig.IPv4Address;
          //IPVersion := Id_IPv4;
          // Port := ServicePort;
        end;
      end;
    {
    //Add IPv6 bind
    if ((ServerIPVersionConfig.ServerIpVersion = sivBoth) or (ServerIPVersionConfig.ServerIpVersion = sivIPv6)) then
    begin
      with HTTPServer.Bindings.Add do
      begin
        IP := ServerIPVersionConfig.IPv6Address;
        IPVersion := Id_IPv6;
        Port := ServicePort;
      end;
    end;   }

      //      HTTPServer.HostName := 'localhost';

      HTTPServer.OnRequest := @aCommandGet;
      HTTPServer.QueueSize := 5;
      HTTPServer.Threaded := True;
      HTTPServer.Port := ServicePort;
      HTTPServer.Active := True;
    except
      On E: Exception do
      begin
        raise Exception.Create(PChar(E.Message));
      end;
    end;
  end
  else if not (Value) then
  begin
    HTTPServer.Active := False;
  end;
  inherited SetActive(HTTPServer.Active);
end;

{
Procedure TRESTDWIdServicePooler.GetSSLPassWord(var Password:String);
Begin
 Password := aSSLPrivateKeyPassword;
End;
   }
{ TRESTDWIdClientPooler }


procedure TRESTDWFhttpClientPooler.SetParams(TransparentProxy: TProxyConnectionInfo;
  aRequestTimeout: integer; aConnectTimeout: integer;
  AuthorizationParams: TRESTDWClientAuthOptionParams);
begin
  HttpRequest.DefaultCustomHeader.Clear;
  // HttpRequest.DefaultCustomHeader.NameValueSeparator := cNameValueSeparator;
  HttpRequest.Accept := Accept;
  HttpRequest.AcceptEncoding := AcceptEncoding;
  HttpRequest.AuthenticationOptions := AuthorizationParams;
  HttpRequest.ProxyOptions.ProxyUsername := TransparentProxy.ProxyUsername;
  HttpRequest.ProxyOptions.ProxyServer := TransparentProxy.ProxyServer;
  HttpRequest.ProxyOptions.ProxyPassword := TransparentProxy.ProxyPassword;
  HttpRequest.ProxyOptions.ProxyPort := TransparentProxy.ProxyPort;
  HttpRequest.RequestTimeout := aRequestTimeout;
  HttpRequest.ConnectTimeout := aConnectTimeout;
  HttpRequest.ContentType := ContentType;
  HttpRequest.ContentEncoding := ContentEncoding;
  HttpRequest.AllowCookies := AllowCookies;
  HttpRequest.HandleRedirects := HandleRedirects;
  HttpRequest.Charset := Charset;
  HttpRequest.UserAgent := UserAgent;
  HttpRequest.OnWork := Self.OnWork;
  HttpRequest.OnWorkBegin := Self.OnWorkBegin;
  HttpRequest.OnWorkEnd := Self.OnWorkEnd;
  HttpRequest.OnStatus := Self.OnStatus;
end;

constructor TRESTDWFhttpClientPooler.Create(AOwner: TComponent);
begin
  inherited;
  HttpRequest := nil;
  vCipherList := '';
  ContentType := cContentTypeFormUrl;
  ContentEncoding := cDefaultContentEncoding;
end;

destructor TRESTDWFhttpClientPooler.Destroy;
begin
  if Assigned(HttpRequest) then
    FreeAndNil(HttpRequest);
  inherited;
end;

procedure TRESTDWFhttpClientPooler.ReconfigureConnection(aTypeRequest: Ttyperequest;
  aWelcomeMessage, aHost: string; aPort: integer;
  Compression, EncodeStrings: boolean; aEncoding: TEncodeSelect;
  aAccessTag: string; aAuthenticationOptions: TRESTDWClientAuthOptionParams);
begin
 {$IFNDEF FPC}
  inherited;
 {$ENDIF}
  if (UseSSL) then
  begin
    HttpRequest.CertMode := vSSLMode;
    // HttpRequest.SSLVersions := PIdSSLVersions(@SSLVersions)^;
  end;
end;

function TRESTDWFhttpClientPooler.SendEvent(EventData: string;
                                        var Params: TRESTDWParams;
                                            EventType: TSendEvent;
                                            DataMode: TDataMode;
                                            ServerEventName: string;
                                            Assyncexec: boolean): string;
var
  vErrorMessage, vErrorMessageA, vDataPack, SResult, vURL, vResponse,
  vTpRequest: string;
  vErrorCode, I: integer;
  vDWParam: TJSONParam;
  vResultParams: TStringStream;
  MemoryStream, aStringStream, bStringStream, StringStream: TStream;
  SendParams: TMultiPartFormDataStream;
  StringStreamList: TStringStreamList;
  JSONValue: TJSONValue;
  aBinaryCompatibleMode, aBinaryRequest: boolean;

  procedure SetData(var InputValue: string; var ParamsData: TRESTDWParams;
  var ResultJSON: string);
  var
    bJsonOBJ, bJsonValue: TRESTDWJSONInterfaceObject;
    bJsonOBJTemp: TRESTDWJSONInterfaceArray;
    JSONParam, JSONParamNew: TJSONParam;
    A, InitPos: integer;
    vValue, aValue, vTempValue: string;
  begin
    ResultJSON := InputValue;
    if Pos(', "RESULT":[', InputValue) = 0 then
    begin
      if (Encoding = esUtf8) then //NativeResult Correções aqui
      begin
      {$IFDEF FPC}
       ResultJSON := GetStringDecode(InputValue, DatabaseCharSet);
      {$ELSE}
       {$IF (CompilerVersion > 22)}
        ResultJSON := pwidechar(InputValue); //PWidechar(UTF8Decode(InputValue));
       {$ELSE}
        ResultJSON := UTF8Decode(ResultJSON); //Correção para Delphi's Antigos de Charset.
       {$IFEND}
      {$ENDIF}
      end
      else
        ResultJSON := InputValue;
      Exit;
    end;
    try
      //   InitPos    := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[') ;
      if (Pos(', "RESULT":[{"MESSAGE":"', InputValue) > 0) then
        InitPos := Pos(', "RESULT":[{"MESSAGE":"', InputValue) +
          Length(', "RESULT":[')   //TODO Brito
      else if (Pos(', "RESULT":[', InputValue) > 0) then
        InitPos := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[')
      else if (Pos('{"PARAMS":[{"', InputValue) > 0) and
        (Pos('", "RESULT":', InputValue) > 0) then
        InitPos := Pos('", "RESULT":', InputValue) + Length('", "RESULT":');
      aValue := Copy(InputValue, InitPos, Length(InputValue) - 1);
      if Pos(']}', aValue) > 0 then
        aValue := Copy(aValue, InitStrPos, Pos(']}', aValue) - 1);
      vTempValue := aValue;
      InputValue := Copy(InputValue, InitStrPos, InitPos - 1) + ']}';
      //Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
      if (Params <> nil) and (InputValue <> '{"PARAMS"]}') and (InputValue <> '') then
      begin
     {$IFDEF FPC}
      If Encoding = esUtf8 Then
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(PWidechar(UTF8Decode(InputValue)))
      Else
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(InputValue);
     {$ELSE}
      {$IF (CompilerVersion <= 22)}
        if Encoding = esUtf8 then //Correção para Delphi's Antigos de Charset.
          bJsonValue := TRESTDWJSONInterfaceObject.Create(
            pwidechar(UTF8Decode(InputValue)))
        else
          bJsonValue := TRESTDWJSONInterfaceObject.Create(InputValue);
      {$ELSE}
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(InputValue);
      {$IFEND}
     {$ENDIF}
        InputValue := '';
        if bJsonValue.PairCount > 0 then
        begin
          bJsonOBJTemp := TRESTDWJSONInterfaceArray(
            bJsonValue.OpenArray(bJsonValue.pairs[0].Name));
          if bJsonOBJTemp.ElementCount > 0 then
          begin
            for A := 0 to bJsonOBJTemp.ElementCount - 1 do
            begin
              bJsonOBJ := TRESTDWJSONInterfaceObject(bJsonOBJTemp.GetObject(A));
              if Length(bJsonOBJ.Pairs[0].Value) = 0 then
              begin
                FreeAndNil(bJsonOBJ);
                Continue;
              end;
              if GetObjectName(bJsonOBJ.Pairs[0].Value) <> toParam then
              begin
                FreeAndNil(bJsonOBJ);
                Continue;
              end;
              JSONParam := TJSONParam.Create(Encoding);
              try
                JSONParam.ParamName := bJsonOBJ.Pairs[4].Name;
                JSONParam.ObjectValue := GetValueType(bJsonOBJ.Pairs[3].Value);
                JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.Pairs[1].Value);
                JSONParam.Encoded := GetBooleanFromString(bJsonOBJ.Pairs[2].Value);
                if not (JSONParam.ObjectValue in [ovBlob, ovStream,
                  ovGraphic, ovOraBlob, ovOraClob]) then
                begin
                  if (JSONParam.Encoded) then
                  begin
                {$IFDEF FPC}
                 vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value{$IFDEF FPC}, DatabaseCharSet{$ENDIF});
                {$ELSE}
                    vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
                      );
                 {$if CompilerVersion < 21}
                    if Encoding = esUtf8 then
                      vValue := Utf8Decode(vValue);
                    vValue := ansistring(vValue);
                 {$IFEND}
                {$ENDIF}
                  end
                  else if JSONParam.ObjectValue <> ovObject then
                    vValue := bJsonOBJ.Pairs[4].Value
                  else                                            //TODO Brito
                  begin
                    vValue := bJsonOBJ.Pairs[4].Value;
                    DeleteInvalidChar(vValue);
                  end;
                end
                else
                  vValue := bJsonOBJ.Pairs[4].Value;
                JSONParam.SetValue(vValue, JSONParam.Encoded);
                //parametro criandos no servidor
                if ParamsData.ItemsString[JSONParam.ParamName] = nil then
                begin
                  JSONParamNew := TJSONParam.Create(ParamsData.Encoding);
                  JSONParamNew.ParamName := JSONParam.ParamName;
                  JSONParamNew.ObjectDirection := JSONParam.ObjectDirection;
                  JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
                  ParamsData.Add(JSONParamNew);
                end
                else if not (ParamsData.ItemsString[JSONParam.ParamName].Binary) then
                  ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value
                else
                  ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue,
                    JSONParam.Encoded);
              finally
                FreeAndNil(JSONParam);
                FreeAndNil(bJsonOBJ);
              end;
            end;
          end;
        end;
        if Assigned(bJsonValue) then
          FreeAndNil(bJsonValue);
        if Assigned(bJsonOBJTemp) then
          FreeAndNil(bJsonOBJTemp);
      end;
    finally
      if vTempValue <> '' then
        ResultJSON := vTempValue;
      vTempValue := '';
    end;
  end;

  function GetParamsValues(var DWParams: TRESTDWParams
{$IFDEF FPC};vDatabaseCharSet : TDatabaseCharSet{$ENDIF}
    ): string;
  var
    I: integer;
  begin
    Result := '';
    JSONValue := nil;
    if WelcomeMessage <> '' then
      Result := 'dwwelcomemessage=' + EncodeStrings(WelcomeMessage
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
        );
    if AccessTag <> '' then
    begin
      if Result <> '' then
        Result := Result + '&dwaccesstag=' + EncodeStrings(AccessTag
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
          )
      else
        Result := 'dwaccesstag=' + EncodeStrings(AccessTag
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
          );
    end;
    if ServerEventName <> '' then
    begin
      if Assigned(DWParams) then
      begin
        vDWParam := DWParams.ItemsString['dwservereventname'];
        if not Assigned(vDWParam) then
        begin
          vDWParam := TJSONParam.Create(DWParams.Encoding);
          vDWParam.ObjectDirection := odIN;
          DWParams.Add(vDWParam);
        end;
        try
          vDWParam.Encoded := True;
          vDWParam.ParamName := 'dwservereventname';
          vDWParam.SetValue(ServerEventName, vDWParam.Encoded);
        finally
          //       FreeAndNil(JSONValue);
        end;
      end
      else
      begin
        JSONValue := TJSONValue.Create;
        try
          JSONValue.Encoding := DWParams.Encoding;
          JSONValue.Encoded := True;
          JSONValue.Tagname := 'dwservereventname';
          JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
        finally
          if Result <> '' then
            Result := Result + '&dwservereventname=' + EncodeStrings(JSONValue.ToJSON
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
              )
          else
            Result := 'dwservereventname=' + EncodeStrings(JSONValue.ToJSON
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
              );
          FreeAndNil(JSONValue);
        end;
      end;
    end;
    if Result <> '' then
      Result := Result + '&datacompression=' + BooleanToString(DataCompression)
    else
      Result := 'datacompression=' + BooleanToString(DataCompression);
    if Result <> '' then
      Result := Result + '&dwassyncexec=' + BooleanToString(Assyncexec)
    else
      Result := 'dwassyncexec=' + BooleanToString(Assyncexec);
    if Result <> '' then
      Result := Result + '&dwencodestrings=' + BooleanToString(EncodedStrings)
    else
      Result := 'dwencodestrings=' + BooleanToString(EncodedStrings);
    if Result <> '' then
    begin
      if Assigned(vCripto) then
        if vCripto.Use then
          Result := Result + '&dwusecript=true';
    end
    else
    begin
      if Assigned(vCripto) then
        if vCripto.Use then
          Result := 'dwusecript=true';
    end;
    if DWParams <> nil then
    begin
      for I := 0 to DWParams.Count - 1 do
      begin
        if Result <> '' then
        begin
          if DWParams.Items[I].ObjectValue in [ovSmallint, ovInteger,
            ovWord, ovBoolean, ovByte, ovAutoInc, ovLargeint,
            ovLongWord, ovShortint, ovSingle] then
            Result := Result + Format('&%s=%s',
              [DWParams.Items[I].ParamName, DWParams.Items[I].Value])
          else
          begin
            if vCripto.Use then
              Result := Result + Format('&%s=%s',
                [DWParams.Items[I].ParamName, vCripto.Encrypt(DWParams.Items[I].Value)])
            else
              Result := Result + Format('&%s=%s',
                [DWParams.Items[I].ParamName, EncodeStrings(DWParams.Items[I].Value
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
                )]);
          end;
        end
        else
        begin
          if DWParams.Items[I].ObjectValue in [ovSmallint, ovInteger,
            ovWord, ovBoolean, ovByte, ovAutoInc, ovLargeint,
            ovLongWord, ovShortint, ovSingle] then
            Result := Format('%s=%s', [DWParams.Items[I].ParamName,
              DWParams.Items[I].Value])
          else
          begin
            if vCripto.Use then
              Result := Format('%s=%s', [DWParams.Items[I].ParamName,
                vCripto.Encrypt(DWParams.Items[I].Value)])
            else
              Result := Format('%s=%s', [DWParams.Items[I].ParamName,
                EncodeStrings(DWParams.Items[I].Value
{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}
                )]);
          end;
        end;
      end;
    end;
    //  If Result <> '' Then
    //   Result := '?' + Result;
  end;

  procedure SetParamsValues(DWParams: TRESTDWParams;
    SendParamsData: TMultiPartFormDataStream);
  var
    I: integer;
    vCharsset: string;
  begin
    MemoryStream := nil;
    if DWParams <> nil then
    begin
      if not (Assigned(StringStreamList)) then
        StringStreamList := TStringStreamList.Create;
      if BinaryRequest then
      begin
        DWParams.SaveToStream(MemoryStream);
        try
          if Assigned(MemoryStream) then
          begin
            MemoryStream.Position := 0;
            SendParamsData.AddObject( 'binarydata', 'application/octet-stream', '', MemoryStream); //StringStreamList.Items[StringStreamList.Count-1]);
          end;
        finally
        end;
      end
      else
      begin
        vCharsset := 'ASCII';
        if Encoding = esUtf8 then
          vCharsset := 'UTF8';
        for I := 0 to DWParams.Count - 1 do
        begin
          If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob, ovStream,
                                             ovMemo,   ovGraphic, ovFmtMemo,  ovOraBlob, ovOraClob] Then
         Begin
          StringStreamList.Add({$IFDEF FPC}
                               TStringStream.Create(DWParams.Items[I].ToJSON)
                               {$ELSE}
                               TStringStream.Create(DWParams.Items[I].ToJSON{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND})
                               {$ENDIF});
           SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', vCharsset, StringStreamList.Items[StringStreamList.Count-1]);
         End
        Else
         SendParamsData.AddFormField(DWParams.Items[I].ParamName, DWParams.Items[I].ToJSON);
       End;
      end;
    end;
  end;

  function BuildUrl(TpRequest: TTypeRequest; Host, aDataRoute: string;
    Port: integer): string;
  var
    vTpRequest: string;
  begin
    Result := '';

    if TpRequest = trHttp then
      vTpRequest := 'http'
    else if TpRequest = trHttps then
      vTpRequest := 'https';

    if ClientIpVersion = civIPv6 then
      Host := '[' + Host + ']';

    if (aDataRoute = '') then
      Result := LowerCase(Format(UrlBaseA, [vTpRequest, Host, Port, '/'])) + EventData
    else
      Result := LowerCase(Format(UrlBaseA, [vTpRequest, Host, Port, aDataRoute])) +
        EventData;

  end;

  procedure SetCharsetRequest(var HttpRequest: TRESTDWFhttpClientREST;
    Charset: TEncodeSelect);
  begin
    if Charset = esUtf8 then
    begin
      if HttpRequest.ContentType = '' then
        HttpRequest.ContentType := 'application/json;charset=utf-8';
      if HttpRequest.Charset = '' then
        HttpRequest.Charset := 'utf-8';
    end
    else if Charset in [esANSI, esASCII] then
      HttpRequest.Charset := 'ansi';
  end;

  function ExecRequest(EventType: TSendEvent;
    URL, WelcomeMessage, AccessTag: string; Charset: TEncodeSelect;
    Datacompress, hEncodeStrings, BinaryRequest: boolean;
  var ResultData, ErrorMessage: string): boolean;
  var
    vAccessURL, vWelcomeMessage, vUrl: string;
    A: integer;

    function BuildValue(Name, Value: string): string;
    begin
      if vURL = URL + '?' then
        Result := Format('%s=%s', [Name, Value])
      else
        Result := Format('&%s=%s', [Name, Value]);
    end;

  begin
    Result := True;
    ResultData := '';
    ErrorMessage := '';
    vAccessURL := '';
    vWelcomeMessage := '';
    vUrl := '';
  {$IFDEF FPC}
   vResultParams   := TStringStream.Create('');
  {$ELSE}
    vResultParams := TStringStream.Create(''
{$if CompilerVersion > 21}
      , TEncoding.UTF8
{$IFEND}
      );
  {$ENDIF}
    try
      HttpRequest.UserAgent := UserAgent;
      HttpRequest.RedirectMaximum := RedirectMaximum;
      HttpRequest.HandleRedirects := HandleRedirects;
      case EventType of
        seGET,
        seDELETE:
        begin
          HttpRequest.ContentType := 'application/json';
          vURL := URL + '?';
          if WelcomeMessage <> '' then
            vURL := vURL + BuildValue('dwwelcomemessage', EncodeStrings(WelcomeMessage
{$IFDEF FPC}, DatabaseCharSet{$ENDIF}
              ));
          if (AccessTag <> '') then
            vURL := vURL + BuildValue('dwaccesstag', EncodeStrings(AccessTag
{$IFDEF FPC}, DatabaseCharSet{$ENDIF}
              ));
          if AuthenticationOptions.AuthorizationOption <> rdwAONone then
          begin
            case AuthenticationOptions.AuthorizationOption of
              rdwAOBearer: begin
                if TRESTDWAuthOptionBearerClient(
                  AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader then
                  if TRESTDWAuthOptionBearerClient(
                    AuthenticationOptions.OptionParams).Token <> '' then
                    vURL :=
                      vURL + BuildValue(TRESTDWAuthOptionBearerClient(
                      AuthenticationOptions.OptionParams).Key,
                      TRESTDWAuthOptionBearerClient(
                      AuthenticationOptions.OptionParams).Token);
              end;
              rdwAOToken: begin
                if TRESTDWAuthOptionTokenClient(
                  AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader then
                  if TRESTDWAuthOptionTokenClient(
                    AuthenticationOptions.OptionParams).Token <> '' then
                    vURL :=
                      vURL + BuildValue(TRESTDWAuthOptionTokenClient(
                      AuthenticationOptions.OptionParams).Key,
                      TRESTDWAuthOptionTokenClient(
                      AuthenticationOptions.OptionParams).Token);
              end;
            end;
          end;
          vURL := vURL + BuildValue('datacompression', BooleanToString(Datacompress));
          vURL := vURL + BuildValue('dwassyncexec', BooleanToString(Assyncexec));
          vURL := vURL + BuildValue('dwencodestrings', BooleanToString(EncodedStrings));
          vURL := vURL + BuildValue('binaryrequest', BooleanToString(BinaryRequest));
          if aBinaryCompatibleMode then
            vURL := vURL + BuildValue('BinaryCompatibleMode',
              BooleanToString(aBinaryCompatibleMode));
          vURL := Format('%s&%s', [vURL, GetParamsValues(Params
{$IFDEF FPC}, DatabaseCharSet{$ENDIF}
            )]);
          if Assigned(vCripto) then
            vURL := vURL + BuildValue('dwusecript', BooleanToString(vCripto.Use));
      {$IFDEF FPC}
       aStringStream := TStringStream.Create('');
      {$ELSE}
          aStringStream := TStringStream.Create(''
{$if CompilerVersion > 21}
            , TEncoding.UTF8
{$IFEND}
            );
      {$ENDIF}
          case EventType of
            seGET: vErrorCode :=
                HttpRequest.Get(vURL, TStringList(HttpRequest.DefaultCustomHeader),
                aStringStream);
            seDELETE: begin
              // THTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, vURL, SendParams, aStringStream, []);
              // vErrorCode := TIdHTTPAccess(HttpRequest).ResponseCode;
            end;
          end;
          if not Assyncexec then
          begin
            if Datacompress then
            begin
              if Assigned(aStringStream) then
              begin
                if aStringStream.Size > 0 then
                  StringStream := ZDecompressStreamNew(aStringStream);
                FreeAndNil(aStringStream);
                ResultData := TStringStream(StringStream).DataString;
                FreeAndNil(StringStream);
              end;
            end
            else
            begin
              ResultData := TStringStream(aStringStream).DataString;
              FreeAndNil(aStringStream);
            end;
          end;
          if Encoding = esUtf8 then
            ResultData := Utf8Decode(ResultData);
        end;
        sePOST,
        sePUT,
        sePATCH:
        begin
          ;
          SendParams := TMultiPartFormDataStream.Create;
          If WelcomeMessage <> '' Then
       SendParams.AddFormField('dwwelcomemessage', EncodeStrings(WelcomeMessage{$IFDEF FPC}, DatabaseCharSet{$ENDIF}));
      If AccessTag <> '' Then
       SendParams.AddFormField('dwaccesstag',      EncodeStrings(AccessTag{$IFDEF FPC}, DatabaseCharSet{$ENDIF}));
      If ServerEventName <> '' Then
          begin
            if Assigned(Params) then
            begin
              vDWParam := Params.ItemsString['dwservereventname'];
              if not Assigned(vDWParam) then
                vDWParam := TJSONParam.Create(Params.Encoding);
              try
                vDWParam.Encoded := True;
                vDWParam.ObjectDirection := odIN;
                vDWParam.ParamName := 'dwservereventname';
                vDWParam.SetValue(ServerEventName, vDWParam.Encoded);
              finally
                if Params.ItemsString['dwservereventname'] = nil then
                  Params.Add(vDWParam);
              end;
            end;
            JSONValue := TJSONValue.Create;
            try
              JSONValue.Encoding := Charset;
              JSONValue.Encoded := True;
              JSONValue.Tagname := 'dwservereventname';
              JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
            finally
              SendParams.AddFormField('dwservereventname', JSONValue.ToJSON);
              FreeAndNil(JSONValue);
            end;
          end
                Else
                 Begin
                  If Assigned(Params) Then
                   Begin
                    For A := 0 To Params.Count -1 Do
                     SendParams.AddFormField(Params[A].ParamName, Params[A].AsString);
                   End;
                 End;
          SendParams.AddFormField('datacompression', BooleanToString(Datacompress));
          SendParams.AddFormField('dwassyncexec', BooleanToString(Assyncexec));
          SendParams.AddFormField('dwencodestrings', BooleanToString(EncodedStrings));
          SendParams.AddFormField('binaryrequest', BooleanToString(BinaryRequest));
          if AuthenticationOptions.AuthorizationOption <> rdwAONone then
          begin
            if Assigned(Params) then
            begin
              case AuthenticationOptions.AuthorizationOption of
                rdwAOBearer: begin
                  if TRESTDWAuthOptionBearerClient(
                    AuthenticationOptions.OptionParams).TokenRequestType <>
                    rdwtHeader then
                  begin
                    if TRESTDWAuthOptionBearerClient(
                      AuthenticationOptions.OptionParams).Token <> '' then
                    begin
                      SendParams.AddFormField(
                        TRESTDWAuthOptionBearerClient(
                        AuthenticationOptions.OptionParams).Key,
                        TRESTDWAuthOptionBearerClient(
                        AuthenticationOptions.OptionParams).Token);
                      vDWParam :=
                        Params.ItemsString[TRESTDWAuthOptionBearerClient(
                        AuthenticationOptions.OptionParams).Key];
                      if not Assigned(vDWParam) then
                        vDWParam := TJSONParam.Create(Params.Encoding);
                      try
                        vDWParam.Encoded := True;
                        vDWParam.ObjectDirection := odIN;
                        vDWParam.ParamName :=
                          TRESTDWAuthOptionBearerClient(
                          AuthenticationOptions.OptionParams).Key;
                        vDWParam.SetValue(
                          TRESTDWAuthOptionBearerClient(
                          AuthenticationOptions.OptionParams).Token,
                          vDWParam.Encoded);
                      finally
                        if Params.ItemsString[TRESTDWAuthOptionBearerClient(
                          AuthenticationOptions.OptionParams).Key] = nil then
                          Params.Add(vDWParam);
                      end;
                    end;
                  end;
                end;
                rdwAOToken: begin
                  if TRESTDWAuthOptionTokenClient(
                    AuthenticationOptions.OptionParams).TokenRequestType <>
                    rdwtHeader then
                  begin
                    if TRESTDWAuthOptionTokenClient(
                      AuthenticationOptions.OptionParams).Token <> '' then
                    begin
                      SendParams.AddFormField(
                        TRESTDWAuthOptionTokenClient(
                        AuthenticationOptions.OptionParams).Key,
                        TRESTDWAuthOptionTokenClient(
                        AuthenticationOptions.OptionParams).Token);
                      vDWParam :=
                        Params.ItemsString[TRESTDWAuthOptionTokenClient(
                        AuthenticationOptions.OptionParams).Key];
                      if not Assigned(vDWParam) then
                        vDWParam := TJSONParam.Create(Params.Encoding);
                      try
                        vDWParam.Encoded := True;
                        vDWParam.ObjectDirection := odIN;
                        vDWParam.ParamName :=
                          TRESTDWAuthOptionTokenClient(
                          AuthenticationOptions.OptionParams).Key;
                        vDWParam.SetValue(
                          TRESTDWAuthOptionTokenClient(
                          AuthenticationOptions.OptionParams).Token,
                          vDWParam.Encoded);
                      finally
                        if Params.ItemsString[TRESTDWAuthOptionTokenClient(
                          AuthenticationOptions.OptionParams).Key] = nil then
                          Params.Add(vDWParam);
                      end;
                    end;
                  end;
                end;
              end;
            end
            else
            begin
              case AuthenticationOptions.AuthorizationOption of
                rdwAOBearer: begin
                  if TRESTDWAuthOptionBearerClient(
                    AuthenticationOptions.OptionParams).TokenRequestType <>
                    rdwtHeader then
                    SendParams.AddFormField(
                      TRESTDWAuthOptionBearerClient(
                      AuthenticationOptions.OptionParams).Key,
                      TRESTDWAuthOptionBearerClient(
                      AuthenticationOptions.OptionParams).Token);
                end;
                rdwAOToken: begin
                  if TRESTDWAuthOptionTokenClient(
                    AuthenticationOptions.OptionParams).TokenRequestType <>
                    rdwtHeader then
                    SendParams.AddFormField(
                      TRESTDWAuthOptionTokenClient(
                      AuthenticationOptions.OptionParams).Key,
                      TRESTDWAuthOptionTokenClient(
                      AuthenticationOptions.OptionParams).Token);
                end;
              end;
            end;
          end;
          if aBinaryCompatibleMode then
            SendParams.AddFormField('BinaryCompatibleMode',
              BooleanToString(aBinaryCompatibleMode));
          if Assigned(vCripto) then
            SendParams.AddFormField('dwusecript', BooleanToString(vCripto.Use));
          if Params <> nil then
            SetParamsValues(Params, SendParams);
          if (Params <> nil) or (WelcomeMessage <> '') or (Datacompress) then
          begin
            if HttpRequest.Accept = '' then
              HttpRequest.Accept := cDefaultContentType;
            if HttpRequest.AcceptEncoding = '' then
              HttpRequest.AcceptEncoding := AcceptEncoding;
            if HttpRequest.ContentType = '' then
              HttpRequest.ContentType := cContentTypeFormUrl;
            if HttpRequest.ContentEncoding = '' then
              HttpRequest.ContentEncoding := cContentTypeMultiPart;
            if TEncodeSelect(Encoding) = esUtf8 then
              HttpRequest.Charset := 'Utf-8'
            else if TEncodeSelect(Encoding) in [esANSI, esASCII] then
              HttpRequest.Charset := 'ansi';
            if not BinaryRequest then
              while HttpRequest.DefaultCustomHeader.IndexOfName('binaryrequest') > -1 do
                HttpRequest.DefaultCustomHeader.Delete(
                  HttpRequest.DefaultCustomHeader.IndexOfName('binaryrequest'));
            if not aBinaryCompatibleMode then
              while HttpRequest.DefaultCustomHeader.IndexOfName(
                  'BinaryCompatibleMode') > -1 do
                HttpRequest.DefaultCustomHeader.Delete(
                  HttpRequest.DefaultCustomHeader.IndexOfName('BinaryCompatibleMode'));
            HttpRequest.UserAgent := UserAgent;
            if Datacompress then
            begin
          {$IFDEF FPC}
           aStringStream := TStringStream.Create('');
          {$ELSE}
              aStringStream := TStringStream.Create(''
{$if CompilerVersion > 21}
                , TEncoding.UTF8
{$IFEND}
                );
          {$ENDIF}
              case EventType of
                sePUT: vErrorCode := HttpRequest.Put(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
                sePATCH: vErrorCode := HttpRequest.Patch(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
                sePOST: vErrorCode := HttpRequest.Post(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
              end;
              if not Assyncexec then
              begin
                if Assigned(aStringStream) then
                begin
                  if (aStringStream.Size > 0) and (vErrorCode = 200)
                  then
                    StringStream := ZDecompressStreamNew(aStringStream)
                  else
                    StringStream :=
                      TStringStream.Create(TStringStream(aStringStream).DataString);
                  FreeAndNil(aStringStream);
                end;
              end;
            end
            else
            begin
          {$IFDEF FPC}
           StringStream := TStringStream.Create('');
          {$ELSE}
              StringStream := TStringStream.Create(''
{$if CompilerVersion > 21}
                , TEncoding.UTF8
{$IFEND}
                );
          {$ENDIF}
              case EventType of
                sePUT: vErrorCode :=
                    HttpRequest.Put(URL, TStringList(HttpRequest.DefaultCustomHeader),
                    SendParams, StringStream);
                sePATCH: vErrorCode :=
                    HttpRequest.Patch(URL, TStringList(HttpRequest.DefaultCustomHeader),
                    SendParams, aStringStream);
                sePOST: vErrorCode :=
                    HttpRequest.Post(URL, TStringList(HttpRequest.DefaultCustomHeader),
                    SendParams, StringStream);
              end;
            end;
            if SendParams <> nil then
            begin
              if Assigned(StringStreamList) then
                FreeAndNil(StringStreamList);
          {$IFNDEF FPC}
              SendParams.Clear;
          {$ENDIF}
              FreeAndNil(SendParams);
            end;
          end
          else
          begin
            HttpRequest.ContentType := cDefaultContentType;
            HttpRequest.ContentEncoding := '';
            HttpRequest.UserAgent := UserAgent;
            aStringStream := TStringStream.Create('');
            HttpRequest.Get(URL, TStringList(HttpRequest.DefaultCustomHeader),
              aStringStream);
            aStringStream.Position := 0;
            StringStream := TStringStream.Create('');
            bStringStream := TStringStream.Create('');
            if not Assyncexec then
            begin
              if Datacompress then
              begin
                bStringStream.CopyFrom(aStringStream, aStringStream.Size);
                bStringStream.Position := 0;
                ZDecompressStreamD(TStringStream(bStringStream),
                  TStringStream(StringStream));
              end
              else
              begin
                bStringStream.CopyFrom(aStringStream, aStringStream.Size);
                bStringStream.Position := 0;
                HexToStream(TStringStream(bStringStream).DataString,
                  TStringStream(StringStream));
              end;
            end;
            FreeAndNil(bStringStream);
            FreeAndNil(aStringStream);
          end;
          if BinaryRequest then
          begin
            if not Assyncexec then
            begin
              if (vErrorCode = 200) then
              begin
                StringStream.Position := 0;
                Params.LoadFromStream(StringStream);
            {$IFNDEF FPC}
             {$IF CompilerVersion > 21}
                TStringStream(StringStream).Clear;
             {$IFEND}
                StringStream.Size := 0;
            {$ENDIF}
                if Params.ItemsString['MessageError'].AsString = trim('') then
                  ResultData := TReplyOK
                else
                  ResultData := Params.ItemsString['MessageError'].AsString;
              end
              else
              begin
                ErrorMessage := TStringStream(StringStream).DataString;
                ResultData := TReplyNOK;
              end;
              FreeAndNil(StringStream);
            end;
          end
          else
          begin
            if not Assyncexec then
            begin
              if Assigned(StringStream) then
              begin
                StringStream.Position := 0;
                if Datacompress then
                  vDataPack := BytesToString(StreamToBytes(TMemoryStream(StringStream)))
                else
                  vDataPack := TStringStream(StringStream).DataString;
            {$IFNDEF FPC}
             {$IF CompilerVersion > 21}
                TStringStream(StringStream).Clear;
             {$IFEND}
                StringStream.Size := 0;
            {$ENDIF}
                FreeAndNil(StringStream);
                SetData(vDataPack, Params, ResultData);
              end
              else
              begin
                SetData(vDataPack, Params, ResultData);
              end;
              if (vErrorCode <> 200) then
              begin
                ErrorMessage := ResultData;
                ResultData := TReplyNOK;
              end;
            end;
          end;
        end;
      end;
      // Eloy
      case vErrorCode of
        401: ErrorMessage := cInvalidAuth;
        404: ErrorMessage := cEventNotFound;
        405: ErrorMessage := cInvalidPoolerName;
      end;
    except
   {
   On E : EIdHTTPProtocolException Do
    Begin
     Result := False;
     ResultData := '';
     LastErrorMessage := HttpRequest.LastErrorMessage;
     LastErrorCode    := e.ErrorCode;
     If Pos(Uppercase(cInvalidInternalError), Uppercase(vErrorMessageA)) = 0 Then
      Begin
       vErrorMessage := Trim(vErrorMessageA);
       vErrorMessage := StringReplace(vErrorMessage, '\\', '\', [rfReplaceAll]);
       If Pos(IntToStr(e.ErrorCode), vErrorMessage) > 0 Then
        Begin
         Delete(vErrorMessage, 1, Pos(IntToStr(e.ErrorCode), vErrorMessage) + Length(IntToStr(e.ErrorCode)));
         vErrorMessage := Trim(vErrorMessage);
        End;
        // irrelevante isso aqui pois vai ser modificado logo abaixo
         vErrorMessage := Unescape_chars(vErrorMessage);
      End;
     If e.ErrorCode = 405 Then
      vErrorMessage := cInvalidPoolerName;
     If e.ErrorCode = 401 Then
      Begin
       vErrorMessage := cInvalidAuth;
       //ClearToken to Auto-Renew
       Case AuthenticationOptions.AuthorizationOption Of
        rdwAOBearer : Begin
                       If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                          (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) And
                          (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                        TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                      End;
        rdwAOToken  : Begin
                       If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                          (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) And
                          (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                        TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                      End;
       End;
      End;

     If Assigned(MemoryStream) Then
      FreeAndNil(MemoryStream);
     If Assigned(aStringStream) Then
      FreeAndNil(aStringStream);
     If Assigned(SendParams) then
      FreeAndNil(SendParams);
     If Assigned(vResultParams) then
      FreeAndNil(vResultParams);
     If Assigned(StringStreamList) Then
      FreeAndNil(StringStreamList);
     If Assigned(StringStream) then
      FreeAndNil(StringStream);
     If Assigned(aStringStream) then
      FreeAndNil(aStringStream);
     If Not FailOver then
      Begin
      {$IFNDEF FPC}
       {$IF Defined(HAS_FMX)}
        ErrorMessage := vErrorMessage;
       {$ELSE}
        Raise Exception.Create(vErrorMessage);
       {$IFEND}
      {$ELSE}
       Raise Exception.Create(vErrorMessage);
      {$ENDIF}
      End
     Else
      ErrorMessage := vErrorMessage;
    End;
    }
      On E: Exception do
      begin
        Result := False;
        ResultData := GetPairJSONStr('NOK', PoolerNotFoundMessage);
        if Assigned(SendParams) then
          FreeAndNil(SendParams);
        if Assigned(vResultParams) then
          FreeAndNil(vResultParams);
        if Assigned(StringStreamList) then
          FreeAndNil(StringStreamList);
        if Assigned(StringStream) then
          FreeAndNil(StringStream);
        if Assigned(aStringStream) then
          FreeAndNil(aStringStream);
        if Assigned(MemoryStream) then
          FreeAndNil(MemoryStream);
        if not FailOver then
        begin
          ErrorMessage := E.Message;
      {$IFNDEF FPC}
       {$IF Defined(HAS_FMX)}
          ErrorMessage := PoolerNotFoundMessage;
       {$ELSE}
        Raise Exception.Create(PoolerNotFoundMessage);
       {$IFEND}
      {$ELSE}
       Raise Exception.Create(PoolerNotFoundMessage);
      {$ENDIF}
        end
        else
          ErrorMessage := e.Message;
      end;
    end;
    if Assigned(vResultParams) then
      FreeAndNil(vResultParams);
    if Assigned(SendParams) then
      FreeAndNil(SendParams);
    if Assigned(StringStream) then
      FreeAndNil(StringStream);
    if Assigned(MemoryStream) then
      FreeAndNil(MemoryStream);
    if Assigned(aStringStream) then
      FreeAndNil(aStringStream);
    if Assigned(MemoryStream) then
      FreeAndNil(MemoryStream);
  end;

begin
  vDWParam := nil;
  MemoryStream := nil;
  vResultParams := nil;
  aStringStream := nil;
  bStringStream := nil;
  JSONValue := nil;
  SendParams := nil;
  StringStreamList := nil;
  StringStream := nil;
  aStringStream := nil;
  vResultParams := nil;
  aBinaryRequest := False;
  aBinaryCompatibleMode := False;
  if (Params.ItemsString['BinaryRequest'] <> nil) then
    aBinaryRequest := Params.ItemsString['BinaryRequest'].AsBoolean;
  if (Params.ItemsString['BinaryCompatibleMode'] <> nil) then
    aBinaryCompatibleMode := Params.ItemsString['BinaryCompatibleMode'].AsBoolean and
      aBinaryRequest;
  if not aBinaryRequest then
    aBinaryRequest := BinaryRequest;
  vURL := BuildUrl(TypeRequest, Host, DataRoute, Port);
  if Assigned(HttpRequest) then
    FreeAndNil(HttpRequest);
  HttpRequest := TRESTDWFhttpClientREST.Create(nil);
  //If (TypeRequest = trHttps) Then
  // HttpRequest.SSLVersions := PIdSSLVersions(@SSLVersions)^;
  HttpRequest.UserAgent := UserAgent;
  SetCharsetRequest(HttpRequest, Encoding);
  SetParams(ProxyOptions, RequestTimeout, ConnectTimeout, AuthenticationOptions);
  HttpRequest.MaxAuthRetries := 0;
  // HttpRequest.DefaultCustomHeader.NameValueSeparator := cNameValueSeparator;
  if BinaryRequest then
    if HttpRequest.DefaultCustomHeader.IndexOfName('binaryrequest') = -1 then
    begin
    {$IFNDEF FPC}
     {$if CompilerVersion > 30}
      HttpRequest.DefaultCustomHeader.AddPair('binaryrequest', 'true');
     {$ELSE}
      HttpRequest.DefaultCustomHeader.Add('binaryrequest=true');
     {$IFEND}
    {$ELSE}
    HttpRequest.DefaultCustomHeader.AddPair('binaryrequest', 'true');
    {$ENDIF}
    end;
  if aBinaryCompatibleMode then
    if HttpRequest.DefaultCustomHeader.IndexOfName('BinaryCompatibleMode') = -1 then
    begin
    {$IFNDEF FPC}
     {$if CompilerVersion > 30}
      HttpRequest.DefaultCustomHeader.AddPair('BinaryCompatibleMode', 'true');
     {$ELSE}
      HttpRequest.DefaultCustomHeader.Add('BinaryCompatibleMode=true');
     {$IFEND}
    {$ELSE}
     HttpRequest.DefaultCustomHeader.AddPair('BinaryCompatibleMode', 'true');
    {$ENDIF}
    end;
  LastErrorMessage := '';
  LastErrorCode := -1;
  try
    if not ExecRequest(EventType, vURL, WelcomeMessage, AccessTag,
      Encoding, DataCompression, EncodedStrings, aBinaryRequest,
      Result, vErrorMessage) then
    begin
      if FailOver then
      begin
        for I := 0 to FailOverConnections.Count - 1 do
        begin
          if I = 0 then
          begin
            if ((FailOverConnections[I].TypeRequest = TypeRequest) and
              (FailOverConnections[I].WelcomeMessage = WelcomeMessage) and
              (FailOverConnections[I].Host = Host) and
              (FailOverConnections[I].Port = Port) and
              (FailOverConnections[I].Compression = DataCompression) and
              (FailOverConnections[I].hEncodeStrings = EncodedStrings) and
              (FailOverConnections[I].Encoding = Encoding) and
              (FailOverConnections[I].AccessTag = AccessTag) and
              (FailOverConnections[I].DataRoute = DataRoute)) or
              (not (FailOverConnections[I].Active)) then
              Continue;
          end;
          if Assigned(OnFailOverExecute) then
            OnFailOverExecute(FailOverConnections[I]);
          vURL := BuildUrl(FailOverConnections[I].TypeRequest,
            FailOverConnections[I].Host, FailOverConnections[I].DataRoute,
            FailOverConnections[I].Port);
          //LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
          SetCharsetRequest(HttpRequest, FailOverConnections[I].Encoding);
          SetParams(FailOverConnections[I].ProxyOptions,
            FailOverConnections[I].RequestTimeOut,
            FailOverConnections[I].ConnectTimeOut,
            FailOverConnections[I].AuthenticationOptions);
          if ExecRequest(EventType, vURL,
            FailOverConnections[I].WelcomeMessage,
            FailOverConnections[I].AccessTag, FailOverConnections[I].Encoding,
            FailOverConnections[I].Compression,
            FailOverConnections[I].hEncodeStrings, BinaryRequest,
            Result, vErrorMessage) then
          begin
            if FailOverReplaceDefaults then
            begin
              TypeRequest := FailOverConnections[I].TypeRequest;
              WelcomeMessage := FailOverConnections[I].WelcomeMessage;
              Host := FailOverConnections[I].Host;
              Port := FailOverConnections[I].Port;
              DataCompression := FailOverConnections[I].Compression;
              ProxyOptions := FailOverConnections[I].ProxyOptions;
              EncodedStrings := FailOverConnections[I].hEncodeStrings;
              Encoding := FailOverConnections[I].Encoding;
              AccessTag := FailOverConnections[I].AccessTag;
              RequestTimeout := FailOverConnections[I].RequestTimeOut;
              ConnectTimeout := FailOverConnections[I].ConnectTimeOut;
              DataRoute := FailOverConnections[I].DataRoute;
            end;
            Break;
          end
          else
          begin
            if Assigned(OnFailOverError) then
            begin
              OnFailOverError(FailOverConnections[I], vErrorMessage);
              vErrorMessage := '';
            end;
          end;
        end;
      end;
    end;
  finally
    if Assigned(HttpRequest) then
      FreeAndNil(HttpRequest);

    if (vErrorMessage <> '') then
    begin
      Result := unescape_chars(vErrorMessage);
      raise Exception.Create(Result);
    end;
  end;
end;

{ TRESTDWIdDatabase }

constructor TRESTDWFhttpDatabase.Create(AOwner: TComponent);
begin
  inherited;

  vCipherList := '';
  RESTClientPooler :=
    TRESTDWFhttpClientPooler.Create(Self);
  ContentType := cContentTypeFormUrl;
  ContentEncoding := cDefaultContentEncoding;

  TRESTDWFhttpClientPooler(RESTClientPooler).ClientIpVersion := ClientIpVersion;
end;

destructor TRESTDWFhttpDatabase.Destroy;
begin
  DestroyClientPooler;

  inherited;
end;


{ TRESTDWIdPoolerList }

constructor TRESTDWFhttpPoolerList.Create(AOwner: TComponent);
begin
  inherited;

  RESTClientPooler := TRESTDWFhttpClientPooler.Create(Self);
end;

destructor TRESTDWFhttpPoolerList.Destroy;
begin

  inherited;
end;

{$IFDEF DOTNET}
function TIdBaseStream.Read(var VBuffer: array of Byte; AOffset, ACount: Longint): Longint;
var
  LBytes: TIdBytes;
begin
  // this is a silly work around really, but array of Byte and TIdByte aren't
  // interchangable in a var parameter, though really they *should be*
  SetLength(LBytes, ACount - AOffset);
  Result := IdRead(LBytes, 0, ACount - AOffset);
  CopyTIdByteArray(LBytes, 0, VBuffer, AOffset, Result);
end;

function TIdBaseStream.Write(const ABuffer: array of Byte; AOffset, ACount: Longint): Longint;
begin
  Result := IdWrite(ABuffer, AOffset, ACount);
end;

function TIdBaseStream.Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64;
begin
  Result := IdSeek(AOffset, AOrigin);
end;

procedure TIdBaseStream.SetSize(ASize: Int64);
begin
  IdSetSize(ASize);
end;

{$ELSE}

  {$IFDEF STREAM_SIZE_64}
procedure TIdBaseStream.SetSize(const NewSize: Int64);
begin
   IdSetSize(NewSize);
end;
  {$ELSE}
procedure TBaseStream.SetSize(ASize: Integer);
begin
  IdSetSize(ASize);
end;
{$ENDIF}

{$IFNDEF DOTNET}
function TBaseStream.RawToBytes(const AValue; const ASize: Integer): TBytes;
{$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  SetLength(Result, ASize);
  if ASize > 0 then begin
    Move(AValue, Result[0], ASize);
  end;
end;
{$ENDIF}

function TBaseStream.Read(var Buffer; Count: Longint): Longint;
var
  LBytes: TBytes;
begin
  SetLength(LBytes, Count);
  Result := IdRead(LBytes, 0, Count);
  if Result > 0 then begin
    Move(LBytes[0], Buffer, Result);
  end;
end;

function TBaseStream.Write(const Buffer; Count: Longint): Longint;
begin
  if Count > 0 then begin
    Result := IdWrite(RawToBytes(Buffer, Count), 0, Count);
  end else begin
    Result := 0;
  end;
end;

  {$IFDEF STREAM_SIZE_64}
function TBaseStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := IdSeek(Offset, Origin);
end;
  {$ELSE}
function TBaseStream.Seek(Offset: Longint; Origin: Word): Longint;
var
  LSeek : TSeekOrigin;
begin
  case Origin of
    soFromBeginning : LSeek := soBeginning;
    soFromCurrent : LSeek := soCurrent;
    soFromEnd : LSeek := soEnd;
  else
    Result := 0;
    Exit;
  end;
  Result := IdSeek(Offset, LSeek) and $FFFFFFFF;
end;
  {$ENDIF}

{$ENDIF}


{ TIdMultiPartFormDataStream }

constructor TMultiPartFormDataStream.Create;
begin
  inherited Create;
  FSize := 0;
  FInitialized := False;
  FBoundary := GenerateUniqueBoundary;
  FRequestContentType := sContentTypeFormData + FBoundary;
  FFields := TFormDataFields.Create(Self);
end;

destructor TMultiPartFormDataStream.Destroy;
begin
  FreeAndNil(FFields);
  inherited Destroy;
end;

//{$I IdDeprecatedImplBugOff.inc}
function TMultiPartFormDataStream.AddObject(const AFieldName,
  AContentType, ACharset: string; AFileData: TObject;
  const AFileName: string = ''): TFormDataField;
//{$I IdDeprecatedImplBugOn.inc}
begin
 { if not (AFileData is TStream) then begin
    raise EIdInvalidObjectType.Create('Unsupported object type. You can assign only one of the following types or their descendants: TStrings, TStream.');
  end; Anderson}
  Result := AddFormField(AFieldName, AContentType, ACharset, TStream(AFileData), AFileName);
end;

function TMultiPartFormDataStream.AddFile(const AFieldName, AFileName: String;
  const AContentType: string = ''): TFormDataField;
var
  LStream: TReadFileExclusiveStream;
  LItem: TFormDataField;
begin
  LStream := TReadFileExclusiveStream.Create(AFileName);
  try
    LItem := FFields.Add;
  except
    FreeAndNil(LStream);
    raise;
  end;

  LItem.FFieldName := AFieldName;
  LItem.FFileName := ExtractFileName(AFileName);
  LItem.FFieldStream := LStream;
  LItem.FCanFreeFieldStream := True;
  if AContentType <> '' then begin
    LItem.ContentType := AContentType;
  end else begin
    LItem.FContentType := TRESTDWMIMEType.GetMIMEType(AFileName);
  end;
  LItem.FContentTransfer := sContentTransferBinary;

  Result := LItem;
end;

function TMultiPartFormDataStream.AddFormField(const AFieldName, AFieldValue: string;
  const ACharset: string = ''; const AContentType: string = ''; const AFileName: string = ''): TFormDataField;
var
  LItem: TFormDataField;
begin
  LItem := FFields.Add;

  LItem.FFieldName := AFieldName;
  LItem.FFileName := ExtractFileName(AFileName);
  LItem.FFieldValue := AFieldValue;
  if AContentType <> '' then begin
    LItem.ContentType := AContentType;
  end else begin
    LItem.FContentType := sContentTypeTextPlain;
  end;
  if ACharset <> '' then begin
    LItem.FCharset := ACharset;
  end;
  LItem.FContentTransfer := sContentTransferQuotedPrintable;

  Result := LItem;
end;

function TMultiPartFormDataStream.AddFormField(const AFieldName, AContentType, ACharset: string;
  AFieldValue: TStream; const AFileName: string = ''): TFormDataField;
var
  LItem: TFormDataField;
begin
 { if not Assigned(AFieldValue) then begin
    raise EIdInvalidObjectType.Create(RSMFDInvalidObjectType);
  end;  Anderson}

  LItem := FFields.Add;

  LItem.FFieldName := AFieldName;
  LItem.FFileName := ExtractFileName(AFileName);
  LItem.FFieldStream := AFieldValue;
  if AContentType <> '' then begin
    LItem.ContentType := AContentType;
  end else begin
    LItem.FContentType := TRESTDWMIMEType.GetMIMEType(AFileName);
  end;
  if ACharset <> '' then begin
    LItem.FCharSet := ACharset;
  end;
  LItem.FContentTransfer := sContentTransferBinary;

  Result := LItem;
end;

procedure TMultiPartFormDataStream.Clear;
begin
  FInitialized := False;
  FFields.Clear;
  if FFreeInputStream then begin
    FInputStream.Free;
  end;
  FInputStream := nil;
  FFreeInputStream := False;
  FCurrentItem := 0;
  FPosition := 0;
  FSize := 0;
  SetLength(FInternalBuffer, 0);
end;

function TMultiPartFormDataStream.GenerateUniqueBoundary: string;
begin
  // TODO: add a way for a user-defined prefix to be placed in between
  // the dashes and the random data, such as 'WebKitFormBoundary'...
  Result := '--------' + FormatDateTime('mmddyyhhnnsszzz', Now);  {do not localize}
end;

procedure TMultiPartFormDataStream.CalculateSize;
var
  I: Integer;
begin
  FSize := 0;
  if FFields.Count > 0 then begin
    for I := 0 to FFields.Count-1 do begin
      FSize := FSize + FFields.Items[I].FieldSize;
    end;
    FSize := FSize + 2{'--'} + Length(Boundary) + 4{'--'+CRLF};
  end;
end;

// RLebeau - IdRead() should wrap multiple files of the same field name
// using a single "multipart/mixed" MIME part, as recommended by RFC 1867
{

Anderson

function TMultiPartFormDataStream.IdRead(var VBuffer: TBytes; AOffset, ACount: Longint): Longint;
var
  LTotalRead, LCount, LBufferCount, LRemaining : Integer;
  LItem: TFormDataField;
  LEncoding: ITextEncoding;
begin
  if not FInitialized then begin
    FInitialized := True;
    FCurrentItem := 0;
    SetLength(FInternalBuffer, 0);
  end;

  LTotalRead := 0;
  LBufferCount := 0;

  while (LTotalRead < ACount) and ((Length(FInternalBuffer) > 0) or Assigned(FInputStream) or (FCurrentItem < FFields.Count)) do
  begin
    if (Length(FInternalBuffer) = 0) and (not Assigned(FInputStream)) then
    begin
      LItem := FFields.Items[FCurrentItem];
      EnsureEncoding(LEncoding, enc8Bit);
      AppendString(FInternalBuffer, LItem.FormatHeader, -1, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});

      FInputStream := LItem.PrepareDataStream(FFreeInputStream);
      if not Assigned(FInputStream) then begin
        AppendString(FInternalBuffer, CRLF);
        Inc(FCurrentItem);
      end;
    end;

    if Length(FInternalBuffer) > 0 then begin
      LCount := IndyMin(ACount - LBufferCount, Length(FInternalBuffer));
      if LCount > 0 then begin
        LRemaining := Length(FInternalBuffer) - LCount;
        CopyTIdBytes(FInternalBuffer, 0, VBuffer, LBufferCount, LCount);
        if LRemaining > 0 then begin
          CopyTIdBytes(FInternalBuffer, LCount, FInternalBuffer, 0, LRemaining);
        end;
        SetLength(FInternalBuffer, LRemaining);
        LBufferCount := LBufferCount + LCount;
        FPosition := FPosition + LCount;
        LTotalRead := LTotalRead + LCount;
      end;
    end;

    if (LTotalRead < ACount) and (Length(FInternalBuffer) = 0) and Assigned(FInputStream) then begin
      LCount := TIdStreamHelper.ReadBytes(FInputStream, VBuffer, ACount - LTotalRead, LBufferCount);
      if LCount > 0 then begin
        LBufferCount := LBufferCount + LCount;
        LTotalRead := LTotalRead + LCount;
        FPosition := FPosition + LCount;
      end
      else begin
        SetLength(FInternalBuffer, 0);
        if FFreeInputStream then begin
          FInputStream.Free;
        end else begin
          FInputStream.Position := 0;
          AppendString(FInternalBuffer, CRLF);
        end;
        FInputStream := nil;
        FFreeInputStream := False;
        Inc(FCurrentItem);
      end;
    end;

    if (Length(FInternalBuffer) = 0) and (not Assigned(FInputStream)) and (FCurrentItem = FFields.Count) then begin
      AppendString(FInternalBuffer, '--' + Boundary + '--' + CRLF);     {do not localize}
      Inc(FCurrentItem);
    end;
  end;

  Result := LTotalRead;
end;
  }
function TMultiPartFormDataStream.IdSeek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64;
begin
  Result := 0;
  case AOrigin of
    soBeginning: begin
      if (AOffset = 0) then begin
        FInitialized := False;
        FPosition := 0;
        Result := 0;
      end else begin
        Result := FPosition;
      end;
    end;
    soCurrent: begin
      Result := FPosition;
    end;
    soEnd: begin
      if (AOffset = 0) then begin
        CalculateSize;
        Result := FSize;
      end else begin
        Result := FPosition;
      end;
    end;
  end;
end;

function TMultiPartFormDataStream.IdWrite(const ABuffer: TBytes; AOffset, ACount: Longint): Longint;
begin
 // anderson raise EIdUnsupportedOperation.Create(RSUnsupportedOperation);
end;

procedure TMultiPartFormDataStream.IdSetSize(ASize: Int64);
begin
 // anderson raise EIdUnsupportedOperation.Create(RSUnsupportedOperation);
end;

{ TFormDataFields }

function TFormDataFields.Add: TFormDataField;
begin
  Result := TFormDataField(inherited Add);
end;

constructor TFormDataFields.Create(AMPStream: TMultiPartFormDataStream);
begin
  inherited Create(TFormDataField);
  FParentStream := AMPStream;
end;

function TFormDataFields.GetFormDataField(AIndex: Integer): TFormDataField;
begin
  Result := TFormDataField(inherited Items[AIndex]);
end;

{ TFormDataField }

constructor TFormDataField.Create(ACollection: TCollection);
var
  LDefCharset: TRESTDWCharSet;
begin
  inherited Create(Collection);
  FFieldStream := nil;
  FFileName := '';
  FFieldName := '';
  FContentType := '';
  FCanFreeFieldStream := False;

  // it's not clear when FHeaderEncoding should be Q not B.
  // Comments welcome on atozedsoftware.indy.general

  LDefCharset := GetDefaultCharSet; //Anderson, remover essa dependência do Indy...

  case LDefCharset of
    idcs_ISO_8859_1:
      begin
        FHeaderEncoding := 'Q';     { quoted-printable }    {Do not Localize}
        FHeaderCharSet := RESTDWCharsetNames[LDefCharset];
      end;
    idcs_UNICODE_1_1:
      begin
        FHeaderEncoding := 'B';     { base64 }    {Do not Localize}
        FHeaderCharSet := RESTDWCharsetNames[idcs_UTF_8];
      end;
  else
    begin
      FHeaderEncoding := 'B';     { base64 }    {Do not Localize}
      FHeaderCharSet := RESTDWCharsetNames[LDefCharset];
    end;
  end;
end;

destructor TFormDataField.Destroy;
begin
  if Assigned(FFieldStream) then begin
    if FCanFreeFieldStream then begin
      FFieldStream.Free;
    end;
  end;
  inherited Destroy;
end;

function TFormDataField.EncodeHeaderData(const ACharSet, AData: String): TBytes;
var
  LCoder: THeaderCoderClass;
  LEncoded: Boolean;
begin
  LCoder := HeaderCoderByCharSet(ACharSet);
  if LCoder <> nil then begin
    Result := LCoder.Encode(ACharSet, AData);
  end else
  begin
    Result := nil;
    LEncoded := False;
    if Assigned(GHeaderEncodingNeeded) then begin
      GHeaderEncodingNeeded(ACharSet, AData, Result, LEncoded);
    end;
    if not LEncoded then begin
      raise EHeaderEncodeError.CreateFmt('Could not encode header data using charset "%s"', [ACharSet]);
    end;
  end;
end;

function TFormDataField.EncodeHeader(const Header: string; Specials: String;
  const HeaderEncoding: Char; const MimeCharSet: string): string;
const
  SPACES = [Ord(' '), 9, 13, 10];    {Do not Localize}
var
  T: string;
  Buf: TBytes;
  L, P, Q, R: Integer;
  B0, B1, B2: Integer;
  InEncode: Integer;
  NeedEncode: Boolean;
  csNoEncode, csNoReqQuote, csSpecials: TBytes;
  BeginEncode, EndEncode: string;

  procedure EncodeWord(AP: Integer);
  const
    MaxEncLen = 75;
  var
    LQ: Integer;
    EncLen: Integer;
    Enc1: string;
  begin
    T := T + BeginEncode;
    if L < AP then AP := L + 1;
    LQ := InEncode;
    InEncode := -1;
    EncLen := Length(BeginEncode) + 2;

    case PosInStrArray(HeaderEncoding, ['Q', 'B'], False) of {Do not Localize}
      0: begin { quoted-printable }
        while LQ < AP do
        begin
          if Buf[LQ] = Ord(' ') then begin {Do not Localize}
            Enc1 := '_';  {Do not Localize}
          end
          else if (not ByteIsInSet(Buf, LQ, csNoReqQuote)) or ByteIsInSet(Buf, LQ, csSpecials) then begin
            Enc1 := '=' + IntToHex(Buf[LQ], 2);     {Do not Localize}
          end
          else begin
            Enc1 := Char(Buf[LQ]);
          end;
          if (EncLen + Length(Enc1)) > MaxEncLen then begin
            //T := T + EndEncode + #13#10#9 + BeginEncode;
            //CC: The #13#10#9 above caused the subsequent call to FoldWrapText to
            //insert an extra #13#10 which, being a blank line in the headers,
            //was interpreted by email clients, etc., as the end of the headers
            //and the start of the message body.  FoldWrapText seems to look for
            //and treat correctly the sequence #13#10 + ' ' however...
            T := T + EndEncode + EOL + ' ' + BeginEncode;
            EncLen := Length(BeginEncode) + 2;
          end;
          T := T + Enc1;
          Inc(EncLen, Length(Enc1));
          Inc(LQ);
        end;
      end;
      1: begin { base64 }
        while LQ < AP do begin
          if (EncLen + 4) > MaxEncLen then begin
            //T := T + EndEncode + #13#10#9 + BeginEncode;
            //CC: The #13#10#9 above caused the subsequent call to FoldWrapText to
            //insert an extra #13#10 which, being a blank line in the headers,
            //was interpreted by email clients, etc., as the end of the headers
            //and the start of the message body.  FoldWrapText seems to look for
            //and treat correctly the sequence #13#10 + ' ' however...
            T := T + EndEncode + EOL + ' ' + BeginEncode;
            EncLen := Length(BeginEncode) + 2;
          end;

          B0 := Buf[LQ];
          case AP - LQ of
            1:
              begin
                T := T + base64_tbl[B0 shr 2] + base64_tbl[B0 and $03 shl 4] + '==';  {Do not Localize}
              end;
            2:
              begin
                B1 := Buf[LQ + 1];
                T := T + base64_tbl[B0 shr 2] +
                  base64_tbl[B0 and $03 shl 4 + B1 shr 4] +
                  base64_tbl[B1 and $0F shl 2] + '=';  {Do not Localize}
              end;
            else
              begin
                B1 := Buf[LQ + 1];
                B2 := Buf[LQ + 2];
                T := T + base64_tbl[B0 shr 2] +
                  base64_tbl[B0 and $03 shl 4 + B1 shr 4] +
                  base64_tbl[B1 and $0F shl 2 + B2 shr 6] +
                  base64_tbl[B2 and $3F];
              end;
          end;
          Inc(EncLen, 4);
          Inc(LQ, 3);
        end;
      end;
    end;
    T := T + EndEncode;
  end;

  function CreateEncodeRange(AStart, AEnd: Byte): TBytes;
  var
    I: Integer;
  begin
    SetLength(Result, AEnd-AStart+1);
    for I := 0 to Length(Result)-1 do begin
      Result[I] := AStart+I;
    end;
  end;

begin
  if Header = '' then begin
    Result := '';
    Exit;
  end;

  // TODO: this function needs to take encoded codeunits into account when
  // deciding where to split the encoded data between adjacent encoded-words,
  // so that a single encoded character does not get split between encoded-words
  // thus corrupting that character...

  Buf := EncodeHeaderData(MimeCharSet, Header);

  {Suggested by Andrew P.Rybin for easy 8bit support}
  if HeaderEncoding = '8' then begin {Do not Localize}
    Result := BytesToStringRaw(Buf);
    Exit;
  end;//if

  // RLebeau 1/7/09: using Char() for #128-#255 because in D2009, the compiler
  // may change characters >= #128 from their Ansi codepage value to their true
  // Unicode codepoint value, depending on the codepage used for the source code.
  // For instance, #128 may become #$20AC...

  // RLebeau 2/12/09: changed the logic to use "no-encode" sets instead, so
  // that words containing codeunits outside the ASCII range are always
  // encoded.  This is easier to manage when Unicode data is involved.

  csNoEncode := CreateEncodeRange(32, 126);

  csNoReqQuote := CreateEncodeRange(33, 60);
  AppendByte(csNoReqQuote, 62);
  AppendBytes(csNoReqQuote, CreateEncodeRange(64, 94));
  AppendBytes(csNoReqQuote, CreateEncodeRange(96, 126));

  csSpecials := ToBytes(Specials, TextEncoding_8Bit);

  BeginEncode := '=?' + MimeCharSet + '?' + HeaderEncoding + '?';    {Do not Localize}
  EndEncode := '?=';  {Do not Localize}

  // JMBERG: We want to encode stuff that the user typed
  // as if it already is encoded!!
  if DecodeHeader(Header) <> Header then begin
    RemoveBytes(csNoEncode, 1, ByteIndex(Ord('='), csNoEncode));
  end;

  L := Length(Buf);
  P := 0;
  T := '';  {Do not Localize}
  InEncode := -1;
  while P < L do
  begin
    Q := P;
    while (P < L) and (Buf[P] in SPACES) do begin
      Inc(P);
    end;
    R := P;
    NeedEncode := False;
    while (P < L) and (not (Buf[P] in SPACES)) do begin
      if (not ByteIsInSet(Buf, P, csNoEncode)) or ByteIsInSet(Buf, P, csSpecials) then begin
        NeedEncode := True;
      end;
      Inc(P);
    end;
    if NeedEncode then begin
      if InEncode = -1 then begin
        T := T + BytesToString(Buf, Q, R - Q);
        InEncode := R;
      end;
    end else
    begin
      if InEncode <> -1 then begin
        EncodeWord(Q);
      end;
      T := T + BytesToString(Buf, Q, P - Q);
    end;
  end;
  if InEncode <> -1 then begin
    EncodeWord(P);
  end;
  Result := T;
end;

function TFormDataField.FormatHeader: string;
var
  LBoundary: string;
begin
  LBoundary := '--' + TFormDataFields(Collection).MultipartFormDataStream.Boundary; {do not localize}

  // TODO: when STRING_IS_ANSI is defined, provide a way for the user to specify the AnsiString encoding for header values...

  Result := Format('%s' + CRLF + sContentDispositionPlaceHolder,
    [LBoundary, EncodeHeader(FieldName, '', FHeaderEncoding, FHeaderCharSet)]);       {do not localize}

  if Length(FileName) > 0 then begin
    Result := Result + Format(sFileNamePlaceHolder,
      [EncodeHeader(FileName, '', FHeaderEncoding, FHeaderCharSet)]);                 {do not localize}
  end;

  Result := Result + CRLF;

  if Length(ContentType) > 0 then begin
    Result := Result + Format(sContentTypePlaceHolder, [ContentType]);      {do not localize}
    if Length(CharSet) > 0 then begin
      Result := Result + Format(sCharsetPlaceHolder, [Charset]);            {do not localize}
    end;
    Result := Result + CRLF;
  end;

  if Length(FContentTransfer) > 0 then begin
    Result := Result + Format(sContentTransferPlaceHolder + CRLF, [FContentTransfer]);
  end;

  Result := Result + CRLF;
end;


function B64(AChar: Char): Byte;
//TODO: Make this use the more efficient MIME Coder
begin
  for Result := Low(base64_tbl) to High(base64_tbl) do begin
    if AChar = base64_tbl[Result] then begin
      Exit;
    end;
  end;
  Result := 0;
end;

function TFormDataField.DecodeHeader(const Header: string): string;
var
  HeaderCharS, HeaderEncod, HeaderData, S: string;
  LDecoded: Boolean;
  LStartPos, LLength, LEncodingStartPos, LEncodingEndPos, LLastStartPos: Integer;
  LLastWordWasEncoded: Boolean;
  Buf: TBytes;

  function ExtractEncoding(const AHeader: string; const AStartPos: Integer;
    var VStartPos, VEndPos: Integer; var VCharSet, VEncoding, VData: String): Boolean;
  var
    LCharSet, LCharSetEnd, LEncoding, LEncodingEnd, LData, LDataEnd: Integer;
  begin
    Result := False;

    //we need a '=? followed by 2 question marks followed by a '?='.    {Do not Localize}
    //to find the end of the substring, we can't just search for '?=',    {Do not Localize}
    //example: '=?ISO-8859-1?Q?=E4?='    {Do not Localize}

    LCharSet := Pos('=?', AHeader, AStartPos);  {Do not Localize}
    if (LCharSet = 0) or (LCharSet > VEndPos) then begin
      Exit;
    end;
    Inc(LCharSet, 2);

    // ignore language, if present
    LCharSetEnd := FindFirstOf('*?', AHeader, -1, LCharSet);  {Do not Localize}
    if (LCharSetEnd = 0) or (LCharSetEnd > VEndPos) then begin
      Exit;
    end;
    if AHeader[LCharSetEnd] = '*' then begin
      LEncoding := Pos('?', AHeader, LCharSetEnd);  {Do not Localize}
      if (LEncoding = 0) or (LEncoding > VEndPos) then begin
        Exit;
      end;
    end else begin
      LEncoding := LCharSetEnd;
    end;
    Inc(LEncoding);

    LEncodingEnd := Pos('?', AHeader, LEncoding);  {Do not Localize}
    if (LEncodingEnd = 0) or (LEncodingEnd > VEndPos) then begin
      Exit;
    end;
    LData := LEncodingEnd+1;

    LDataEnd := Pos('?=', AHeader, LData);  {Do not Localize}
    if (LDataEnd = 0) or (LDataEnd > VEndPos) then begin
      Exit;
    end;

    VStartPos := LCharSet-2;
    VEndPos := LDataEnd+1;
    VCharSet := Copy(AHeader, LCharSet, LCharSetEnd-LCharSet);
    VEncoding := Copy(AHeader, LEncoding, LEncodingEnd-LEncoding);
    VData := Copy(AHeader, LData, LDataEnd-LData);

    Result := True;
  end;

  // TODO: use TIdCoderQuotedPrintable and TIdCoderMIME instead
  function ExtractEncodedData(const AEncoding, AData: String; var VDecoded: TBytes): Boolean;
  var
    I, J: Integer;
    a3: TBytes;
    a4: array [0..3] of Byte;
  begin
    Result := False;
    SetLength(VDecoded, 0);
    case PosInStrArray(AEncoding, ['Q', 'B', '8'], False) of {Do not Localize}
      0: begin // quoted-printable
        I := 1;
        while I <= Length(AData) do begin
          if AData[i] = '_' then begin {Do not Localize}
            AppendByte(VDecoded, Ord(' '));    {Do not Localize}
          end
          else if (AData[i] = '=') and (Length(AData) >= (i+2)) then begin //make sure we can access i+2
            AppendByte(VDecoded, StrToIntDef('$' + Copy(AData, i+1, 2), 32));   {Do not Localize}
            Inc(I, 2);
          end else
          begin
            AppendByte(VDecoded, Ord(AData[i]));
          end;
          Inc(I);
        end;
        Result := True;
      end;
      1: begin // base64
        J := Length(AData) div 4;
        if J > 0 then
        begin
          SetLength(a3, 3);
          for I := 0 to J-1 do
          begin
            a4[0] := B64(AData[(I*4)+1]);
            a4[1] := B64(AData[(I*4)+2]);
            a4[2] := B64(AData[(I*4)+3]);
            a4[3] := B64(AData[(I*4)+4]);

            a3[0] := Byte((a4[0] shl 2) or (a4[1] shr 4));
            a3[1] := Byte((a4[1] shl 4) or (a4[2] shr 2));
            a3[2] := Byte((a4[2] shl 6) or (a4[3] shr 0));

            if AData[(I*4)+4] = '=' then begin
              if AData[(I*4)+3] = '=' then begin
                AppendByte(VDecoded, a3[0]);
              end else begin
                AppendBytes(VDecoded, a3, 0, 2);
              end;
              Break;
            end else begin
              AppendBytes(VDecoded, a3, 0, 3);
            end;
          end;
        end;
        Result := True;
      end;
      2: begin // 8-bit
        {$IFDEF STRING_IS_ANSI}
        if AData <> '' then begin
          VDecoded := RawToBytes(AData[1], Length(AData));
        end;
        {$ELSE}
        VDecoded := IndyTextEncoding_8Bit.GetBytes(AData);
        {$ENDIF}
        Result := True;
      end;
    end;
  end;

begin
  Result := Header;

  LStartPos := 1;
  LLength := Length(Result);

  LLastWordWasEncoded := False;
  LLastStartPos := LStartPos;

  while LStartPos <= LLength do
  begin
    // valid encoded words can not contain spaces
    // if the user types something *almost* like an encoded word,
    // and its sent as-is, we need to find this!!
    LStartPos := FindFirstNotOf(LWS+CR+LF, Result, LLength, LStartPos);
    if LStartPos = 0 then begin
      Break;
    end;
    LEncodingEndPos := FindFirstOf(LWS+CR+LF, Result, LLength, LStartPos);
    if LEncodingEndPos <> 0 then begin
      Dec(LEncodingEndPos);
    end else begin
      LEncodingEndPos := LLength;
    end;
    if ExtractEncoding(Result, LStartPos, LEncodingStartPos, LEncodingEndPos, HeaderCharS, HeaderEncod, HeaderData) then
    begin
      LDecoded := False;
      if ExtractEncodedData(HeaderEncoding, HeaderData, Buf) then begin
        LDecoded := DecodeHeaderData(HeaderCharSet, Buf, S);
      end;
      if LDecoded then
      begin
        //replace old substring in header with decoded string,
        // ignoring whitespace that separates encoded words:
        if LLastWordWasEncoded then begin
          Result := Copy(Result, 1, LLastStartPos - 1) + S + Copy(Result, LEncodingEndPos + 1, MaxInt);
          LStartPos := LLastStartPos + Length(S);
        end else begin
          Result := Copy(Result, 1, LEncodingStartPos - 1) + S + Copy(Result, LEncodingEndPos + 1, MaxInt);
          LStartPos := LEncodingStartPos + Length(S);
        end;
      end else
      begin
        // could not decode the data, so preserve it in case the user
        // wants to do it manually.  Though, they really should use the
        // IdHeaderCoderBase.GHeaderDecodingNeeded hook for that instead...
        LStartPos := LEncodingEndPos + 1;
      end;
      LLength := Length(Result);
      LLastWordWasEncoded := True;
      LLastStartPos := LStartPos;
    end else
    begin
      LStartPos := FindFirstOf(LWS+CR+LF, Result, LLength, LStartPos);
      if LStartPos = 0 then begin
        Break;
      end;
      LLastWordWasEncoded := False;
    end;
  end;
end;



function TFormDataField.GetFieldSize: Int64;
var
  LStream: TStream;
  LOldPos: TStreamSize;
  {$IFDEF STRING_IS_ANSI}
  LBytes: TBytes;
  {$ENDIF}
  I: Integer;
begin
  {$IFDEF STRING_IS_ANSI}
  LBytes := nil; // keep the compiler happy
  {$ENDIF}
  Result := Length(FormatHeader);
  if Assigned(FFieldStream) then begin
    I := PosInStrArray(ContentTransfer, cAllowedContentTransfers, False);
    if I <= 2 then begin
      // need to include an explicit CRLF at the end of the data
      Result := Result + FFieldStream.Size + 2{CRLF};
    end else
    begin
      LStream := TIdCalculateSizeStream.Create;
      try
        LOldPos := FFieldStream.Position;
        try
          if I = 3 then begin
            TIdEncoderQuotedPrintable.EncodeStream(FFieldStream, LStream);
            // the encoded text always includes a CRLF at the end...
            Result := Result + LStream.Size {+2};
          end else begin
            TIdEncoderMime.EncodeStream(FFieldStream, LStream);
            // the encoded text does not include a CRLF at the end...
            Result := Result + LStream.Size + 2;
          end;
        finally
          FFieldStream.Position := LOldPos;
        end;
      finally
        LStream.Free;
      end;
    end;
  end
  else if Length(FFieldValue) > 0 then begin
    I := PosInStrArray(FContentTransfer, cAllowedContentTransfers, False);
    if I <= 0 then begin
      // 7bit
      {$IFDEF STRING_IS_UNICODE}
      I := IndyTextEncoding_ASCII.GetByteCount(FFieldValue);
      {$ELSE}
      // the methods useful for calculating a length without actually
      // encoding are protected, so have to actually encode the
      // string to find out the final length...
      LBytes := RawToBytes(FFieldValue[1], Length(FFieldValue));
      CheckByteEncoding(LBytes, CharsetToEncoding(FCharset), IndyTextEncoding_ASCII);
      I := Length(LBytes);
      {$ENDIF}
      // need to include an explicit CRLF at the end of the data
      Result := Result + I + 2{CRLF};
    end
    else if (I = 1) or (I = 2) then begin
      // 8bit/binary
      {$IFDEF STRING_IS_UNICODE}
      I := CharsetToEncoding(FCharset).GetByteCount(FFieldValue);
      {$ELSE}
      I := Length(FFieldValue);
      {$ENDIF}
      // need to include an explicit CRLF at the end of the data
      Result := Result + I + 2{CRLF};
    end else
    begin
      LStream := TIdCalculateSizeStream.Create;
      try
        {$IFNDEF STRING_IS_UNICODE}
        LBytes := RawToBytes(FFieldValue[1], Length(FFieldValue));
        {$ENDIF}
        if I = 3 then begin
          // quoted-printable
          {$IFDEF STRING_IS_UNICODE}
          TIdEncoderQuotedPrintable.EncodeString(FFieldValue, LStream, CharsetToEncoding(FCharset));
          {$ELSE}
          TIdEncoderQuotedPrintable.EncodeBytes(LBytes, LStream);
          {$ENDIF}
          // the encoded text always includes a CRLF at the end...
          Result := Result + LStream.Size {+2};
        end else begin
          // base64
          {$IFDEF STRING_IS_UNICODE}
          TIdEncoderMIME.EncodeString(FFieldValue, LStream, CharsetToEncoding(FCharset){$IFDEF STRING_IS_ANSI}, IndyTextEncoding_OSDefault{$ENDIF});
          {$ELSE}
          TIdEncoderMIME.EncodeBytes(LBytes, LStream);
          {$ENDIF}
          // the encoded text does not include a CRLF at the end...
          Result := Result + LStream.Size + 2;
        end;
      finally
        LStream.Free;
      end;
    end;
  end else begin
    // need to include an explicit CRLF at the end of blank text
    Result := Result + 2{CRLF};
  end;
end;

function TFormDataField.PrepareDataStream(var VCanFree: Boolean): TStream;
var
  I: Integer;
  {$IFDEF STRING_IS_ANSI}
  LBytes: TIdBytes;
  {$ENDIF}
begin
  {$IFDEF STRING_IS_ANSI}
  LBytes := nil; // keep the compiler happy
  {$ENDIF}
  Result := nil;
  VCanFree := False;

  if Assigned(FFieldStream) then begin
    FFieldStream.Position := 0;
    I := PosInStrArray(FContentTransfer, cAllowedContentTransfers, False);
    if I <= 2 then begin
      Result := FFieldStream;
    end else begin
      Result := TMemoryStream.Create;
      try
        if I = 3 then begin
          TIdEncoderQuotedPrintable.EncodeStream(FFieldStream, Result);
          // the encoded text always includes a CRLF at the end...
        end else begin
          TIdEncoderMime.EncodeStream(FFieldStream, Result);
          // the encoded text does not include a CRLF at the end...
          WriteStringToStream(Result, CRLF);
        end;
        Result.Position := 0;
      except
        FreeAndNil(Result);
        raise;
      end;
      VCanFree := True;
    end;
  end
  else if Length(FFieldValue) > 0 then begin
    Result := TMemoryStream.Create;
    try
      {$IFDEF STRING_IS_ANSI}
      LBytes := RawToBytes(FFieldValue[1], Length(FFieldValue));
      {$ENDIF}
      I := PosInStrArray(FContentTransfer, cAllowedContentTransfers, False);
      if I <= 0 then begin
        // 7bit
        {$IFDEF STRING_IS_UNICODE}
        WriteStringToStream(Result, FFieldValue, IndyTextEncoding_ASCII);
        {$ELSE}
        CheckByteEncoding(LBytes, CharsetToEncoding(FCharset), IndyTextEncoding_ASCII);
        WriteTIdBytesToStream(Result, LBytes);
        {$ENDIF}
        // need to include an explicit CRLF at the end of the data
        WriteStringToStream(Result, CRLF);
      end
      else if (I = 1) or (I = 2) then begin
        // 8bit/binary
        {$IFDEF STRING_IS_UNICODE}
        WriteStringToStream(Result, FFieldValue, CharsetToEncoding(FCharset));
        {$ELSE}
        WriteTIdBytesToStream(Result, LBytes);
        {$ENDIF}
        // need to include an explicit CRLF at the end of the data
        WriteStringToStream(Result, CRLF);
      end else
      begin
        if I = 3 then begin
          // quoted-printable
          {$IFDEF STRING_IS_UNICODE}
          TIdEncoderQuotedPrintable.EncodeString(FFieldValue, Result, CharsetToEncoding(FCharset));
          {$ELSE}
          TIdEncoderQuotedPrintable.EncodeBytes(LBytes, Result);
          {$ENDIF}
          // the encoded text always includes a CRLF at the end...
        end else begin
          // base64
          {$IFDEF STRING_IS_UNICODE}
          TIdEncoderMIME.EncodeString(FFieldValue, Result, CharsetToEncoding(FCharset));
          {$ELSE}
          TIdEncoderMIME.EncodeBytes(LBytes, Result);
          {$ENDIF}
          // the encoded text does not include a CRLF at the end...
          WriteStringToStream(Result, CRLF);
        end;
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
    Result.Position := 0;
    VCanFree := True;
  end;
end;

function TFormDataField.GetFieldStream: TStream;
begin
  if not Assigned(FFieldStream) then begin
    raise EIdInvalidObjectType.Create(RSMFDInvalidObjectType);
  end;
  Result := FFieldStream;
end;

function TFormDataField.GetFieldValue: string;
begin
  if Assigned(FFieldStream) then begin
    raise EIdInvalidObjectType.Create(RSMFDInvalidObjectType);
  end;
  Result := FFieldValue;
end;

procedure TFormDataField.SetCharset(const Value: string);
begin
  FCharset := Value;
end;

procedure TFormDataField.SetContentTransfer(const Value: string);
begin
  if Length(Value) > 0 then begin
    if PosInStrArray(Value, cAllowedContentTransfers, False) = -1 then begin
      raise EIdUnsupportedTransfer.Create(RSMFDInvalidTransfer);
    end;
  end;
  FContentTransfer := Value;
end;

procedure TFormDataField.SetContentType(const Value: string);
var
  LContentType, LCharSet: string;
begin
  if Length(Value) > 0 then begin
    LContentType := Value;
  end
  else if Length(FFileName) > 0 then begin
    LContentType := GetMIMETypeFromFile(FFileName);
  end
  else begin
    LContentType := sContentTypeOctetStream;
  end;

  FContentType := RemoveHeaderEntry(LContentType, 'charset', LCharSet, QuoteMIME); {do not localize}

  // RLebeau: per RFC 2045 Section 5.2:
  //
  // Default RFC 822 messages without a MIME Content-Type header are taken
  // by this protocol to be plain text in the US-ASCII character set,
  // which can be explicitly specified as:
  //
  //   Content-type: text/plain; charset=us-ascii
  //
  // This default is assumed if no Content-Type header field is specified.
  // It is also recommend that this default be assumed when a
  // syntactically invalid Content-Type header field is encountered. In
  // the presence of a MIME-Version header field and the absence of any
  // Content-Type header field, a receiving User Agent can also assume
  // that plain US-ASCII text was the sender's intent.  Plain US-ASCII
  // text may still be assumed in the absence of a MIME-Version or the
  // presence of an syntactically invalid Content-Type header field, but
  // the sender's intent might have been otherwise.
  if (LCharSet = '') and (FCharSet = '') and IsHeaderMediaType(FContentType, 'text') then begin {do not localize}
    LCharSet := 'us-ascii'; {do not localize}
  end;
  {RLebeau: override the current CharSet only if the header specifies a new value}
  if LCharSet <> '' then begin
    FCharSet := LCharSet;
  end;
end;

procedure TFormDataField.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TFormDataField.SetFieldStream(const Value: TStream);
begin
  if not Assigned(Value) then begin
    raise EIdInvalidObjectType.Create(RSMFDInvalidObjectType);
  end;

  if Assigned(FFieldStream) and FCanFreeFieldStream then begin
    FFieldStream.Free;
  end;

  FFieldValue := '';
  FFieldStream := Value;
  FCanFreeFieldStream := False;
end;

procedure TFormDataField.SetFieldValue(const Value: string);
begin
  if Assigned(FFieldStream) then begin
    if FCanFreeFieldStream then begin
      FFieldStream.Free;
    end;
    FFieldStream := nil;
    FCanFreeFieldStream := False;
  end;
  FFieldValue := Value;
end;

procedure TFormDataField.SetFileName(const Value: string);
begin
  FFileName := ExtractFileName(Value);
end;

procedure TFormDataField.SetHeaderCharSet(const Value: string);
begin
  FHeaderCharset := Value;
end;

procedure TFormDataField.SetHeaderEncoding(const Value: Char);
begin
  if FHeaderEncoding <> Value then begin
    if PosInStrArray(Value, cAllowedHeaderEncodings, False) = -1 then begin
      raise EIdUnsupportedEncoding.Create(RSMFDInvalidEncoding);
    end;
    FHeaderEncoding := Value;
  end;
end;

function TFormDataField.GetDefaultCharSet: TRESTDWCharSet;
{$IFDEF USE_INLINE}inline;{$ENDIF}
begin
  {$IFDEF UNIX}
  Result := GIdDefaultCharSet;
  {$ENDIF}
  {$IFDEF DOTNET}
  Result := idcs_UNICODE_1_1;
  // not a particular Unicode encoding - just unicode in general
  // i.e. DotNet native string is 2 byte Unicode, we do not concern ourselves
  // with Byte order. (though we have to concern ourselves once we start
  // writing to some stream or Bytes
  {$ENDIF}
  {$IFDEF WINDOWS}
  // Many defaults are set here when the choice is ambiguous. However for
  // IdMessage OnInitializeISO can be used by user to choose other.
  case SysLocale.PriLangID of
    LANG_CHINESE: begin
      if SysLocale.SubLangID = SUBLANG_CHINESE_SIMPLIFIED then begin
        Result := idcs_GB2312;
      end else begin
        Result := idcs_Big5;
      end;
    end;
    LANG_JAPANESE: Result := idcs_ISO_2022_JP;
    LANG_KOREAN: Result := idcs_csEUCKR;
    // Kudzu
    // 1251 is the Windows standard for Russian but its not used in emails.
    // KOI8-R is by far the most widely used and thus the default.
    LANG_RUSSIAN: Result := idcs_KOI8_R;
    // Kudzu
    // Ukranian is about 50/50 KOI8u and 1251, but 1251 is the newer one and
    // the Windows one so we default to it.
    LANG_UKRAINIAN: Result := idcs_windows_1251;
    else begin
      {$IFDEF STRING_IS_UNICODE}
      Result := idcs_UNICODE_1_1;
      // not a particular Unicode encoding - just unicode in general
      // i.e. Delphi/C++Builder 2009+ native string is 2 byte Unicode,
      // we do not concern ourselves with Byte order. (though we have
      // to concern ourselves once we start writing to some stream or
      // Bytes
      {$ELSE}
      Result := idcs_ISO_8859_1;
      {$ENDIF}
    end;
  end;
  {$ENDIF}
end;

end.
