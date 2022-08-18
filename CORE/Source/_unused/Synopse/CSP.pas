/// Structures used for Content Security Policy Level 2 and Level 3 support
// Licensed under The MIT License (MIT)
unit CSP;

(*
  This unit is a path of integration project between HTML5 Boilerplate and
  Synopse mORMot Framework.

    https://synopse.info
    https://html5boilerplate.com

  Boilerplate HTTP Server
  (c) 2016-Present Yevgeny Iliyn

  https://github.com/eugeneilyin/mORMotBP

  Version 2.2
  - First public release
*)

interface

{$I Synopse.inc} // define HASINLINE CPU32 CPU64

{$IFDEF VER200}{$UNDEF HASINLINE}{$ENDIF} // Delphi 2009 has inlining issues

uses
  SynCommons,
  SynTable,
  SynCrypto,
  SynCrtSock;

type

  // Content security policy level 2 forward declarations

  PCSP2 = ^TCSP2;
  PCSP2SourceList = ^TCSP2SourceList;
  PCSP2FrameAncestors = ^TCSP2FrameAncestors;
  PCSP2MediaTypeList = ^TCSP2MediaTypeList;
  PCSP2URIReferences = ^TCSP2URIReferences;
  PCSP2SandboxTokens = ^TCSP2SandboxTokens;

  /// Content security policy level 2 directives
  TCSP2Directive = (csp2BaseURI, csp2ChildSrc, csp2ConnectSrc, csp2DefaultSrc,
    csp2FontSrc, csp2FormAction, csp2FrameAncestors, csp2ImgSrc, csp2MediaSrc,
    csp2ObjectSrc, csp2PluginTypes, csp2ReportURI, csp2Sandbox, csp2ScriptSrc,
    csp2StyleSrc);

  /// Content security policy level 2 list of sources
  TCSP2SourceList = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP2;
    Directive: TCSP2Directive;

    /// Assign to the specific CSP directive
    procedure Init(ACSP: PCSP2; const ADirective: TCSP2Directive);
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific source to the directive source list,
    // used by other methods below
    function Add(const Source: SockString): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Empty source list and add signle "'none'" directive
    // 'none' must not be mixed with other values
    function None: PCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "null" host source
    function Null: PCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "*" source (not recommended for production)
    function Any: PCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme}:" source
    // Section 7. Authors SHOULD NOT include either "'unsafe-inline'" or "data:"
    // as valid sources in their policies.
    function Scheme(const AScheme: SockString): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme}://{host}:{port}{path}" source
    function Host(
      const AScheme, AHost, APort, APath: SockString): PCSP2SourceList;
        overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{host}" source
    function Host(const AHost: SockString): PCSP2SourceList; overload;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'self'" source
    function WithSelf: PCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'unsafe-inline'" source
    // Section 7. Authors SHOULD NOT include either 'unsafe-inline' or data:
    // as valid sources in their policies.
    function UnsafeInline: PCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'unsafe-eval'" source
    function UnsafeEval: PCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'nonce-{value}'" source as a random generated sequence with
    // specific length.
    // Section 4.2. The generated value SHOULD be at least 128 bits long
    // (before encoding), and generated via a cryptographically secure random
    // number generator.
    function NonceLen(var Base64EncodedNonce: SockString;
      const NonceLength: Integer = 256): PCSP2SourceList;
        {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'nonce-{value}'" source
    // Section 4.2. The generated value SHOULD be at least 128 bits long
    // (before encoding), and generated via a cryptographically secure random
    // number generator.
    function Nonce(const ANonce: RawByteString): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'nonce-{value}'" where value is random generated
    // Base64 encoded sequence
    // Section 4.2. The generated value SHOULD be at least 128 bits long
    // (before encoding), and generated via a cryptographically secure random
    // number generator.
    function Nonce64(const Base64EncodedNonce: SockString): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" where value is a Base64 encodd hash calculated on
    // the provided content
    function SHA256(const Content: RawByteString;
      const PBase64EncodedHash: PSockString = nil): PCSP2SourceList;
        {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" with Base64 encoded hash
    function SHA256Hash(const Hash: THash256): PCSP2SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" with Base64 encoded hash
    function SHA256Hash(const Hash: RawByteString): PCSP2SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" with provided Base64 encoded hash
    function SHA256Hash64(const Base64EncodedHash: SockString): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" where value is a Base64 encodd hash calculated on
    // the provided content
    function SHA384(const Content: RawByteString;
      const PBase64EncodedHash: PSockString = nil): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" with Base64 encoded hash
    function SHA384Hash(const Hash: THash384): PCSP2SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" with Base64 encoded hash
    function SHA384Hash(const Hash: RawByteString): PCSP2SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" with provided Base64 encoded hash
    function SHA384Hash64(const Base64EncodedHash: SockString): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" where value is a Base64 encodd hash calculated on
    // the provided content
    function SHA512(const Content: RawByteString;
      const PBase64EncodedHash: PSockString = nil): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" with Base64 encoded hash
    function SHA512Hash(const Hash: THash512): PCSP2SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" with Base64 encoded hash
    function SHA512Hash(const Hash: RawByteString): PCSP2SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" with provided Base64 encoded hash
    function SHA512Hash64(const Base64EncodedHash: SockString): PCSP2SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content security policy level 2 frame ancestors
  TCSP2FrameAncestors = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP2;

    /// Assign to the specific CSP
    procedure Init(ACSP: PCSP2); {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific source to the directive source list,
    // used by other methods below
    function Add(const Value: SockString): PCSP2FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'none'" source
    function None: PCSP2FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme}:" source
    // Section 7. Authors SHOULD NOT include either "'unsafe-inline'" or "data:"
    // as valid sources in their policies.
    function Scheme(const AScheme: SockString): PCSP2FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme}://{host}:{port}{path}" source
    function Host(const AScheme, AHost,
      APort, APath: SockString): PCSP2FrameAncestors;
        overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{host}" source
    function Host(const AHost: SockString): PCSP2FrameAncestors;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content security policy level 2 media type list
  TCSP2MediaTypeList = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP2;

    /// Assign to the specific CSP
    procedure Init(ACSP: PCSP2); {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific source to the directive source list,
    // used by other methods below
    function Add(const Value: SockString): PCSP2MediaTypeList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "<type>/<subtype>" source
    function MediaType(
      const AMediaType, AMediaSubtype: SockString): PCSP2MediaTypeList;
        {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content security policy level 2 URI references
  TCSP2URIReferences = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP2;

    /// Assign to the specific CSP
    procedure Init(ACSP: PCSP2); {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific URI to the directive URI list,
    // used by method below
    function Add(const Value: SockString): PCSP2URIReferences;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add URI reference for reports sending
    function Reference(const URIReference: SockString): PCSP2URIReferences;
        {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content security policy level 2 sandbox tokens
  TCSP2SandboxTokens = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP2;

    /// Assign to the specific CSP
    procedure Init(ACSP: PCSP2); {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific token to the directive token list,
    // used by other methods below
    function Add(const Value: SockString = ''): PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Clear all sandbox tokens and add empty token
    function Empty: PCSP2SandboxTokens; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add URI reference for reports sending
    function Token(const AToken: SockString): PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-forms' flag
    function AllowForms: PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-pointer-lock' flag
    function AllowPointerLock: PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-popups' flag
    function AllowPopups: PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-same-origin' flag
    function AllowSameOrigin: PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-scripts' flag
    function AllowScripts: PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-top-navigtion' flag
    function AllowTopNavigation: PCSP2SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content Security Policy level 2
  {$IFDEF FPC_OR_UNICODE}
    TCSP2 = record private
  {$ELSE}
    TCSP2 = object protected
  {$ENDIF}
  private
    Directives: array[TCSP2Directive] of TSockStringDynArray;
    Counts: array[TCSP2Directive] of PtrInt;
    Cached: Boolean;
    Cache: SockString;
  public
    /// Initialize structure
    function Init: PCSP2; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'base-uri' directive
    function BaseURI: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'child-src' directive
    function ChildSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'connect-src' directive
    function ConnectSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'default-src' directive
    function DefaultSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'font-src' directive
    function FontSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'form-action' directive
    function FormAction: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'frame-ancestors' directive
    function FrameAncestors: TCSP2FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'img-src' directive
    function ImgSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'media-src' directive
    function MediaSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'object-src' directive
    function ObjectSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'plugin-types' directive
    function PluginTypes: TCSP2MediaTypeList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'report-uri' directive
    function ReportURI: TCSP2URIReferences; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'sandbox' directive
    function Sandbox: TCSP2SandboxTokens; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'script-src' directive
    function ScriptSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'style-src' directive
    function StyleSrc: TCSP2SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Computes and cache security policy content
    function Policy: SockString;

    /// Computes 'Content-Security-Policy' HTTP header
    function HTTPHeader: SockString;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Computes 'Content-Security-Policy-Report-Only' HTTP header
    function HTTPHeaderReportOnly: SockString;
      {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  // Content security policy level 3 forward declarations

  PCSP3 = ^TCSP3;
  PCSP3SourceList = ^TCSP3SourceList;
  PCSP3MediaTypeList = ^TCSP3MediaTypeList;
  PCSP3SandboxTokens = ^TCSP3SandboxTokens;
  PCSP3FrameAncestors = ^TCSP3FrameAncestors;

  /// Content security policy level 3 directives
  TCSP3Directive = (csp3ChildSrc, csp3ConnectSrc, csp3DefaultSrc, csp3FontSrc,
    csp3FrameSrc, csp3ImgSrc, csp3ManifestSrc, csp3MediaSrc, csp3PrefetchSrc,
    csp3ObjectSrc, csp3ScriptSrc, csp3ScriptSrcElem, csp3ScriptSrcAttr,
    csp3StyleSrc, csp3StyleSrcElem, csp3StyleSrcAttr, csp3WorkerSrc,
    csp3BaseURI, csp3PluginTypes, csp3Sandbox, csp3FormAction,
    csp3FrameAncestors, csp3NavigateTo, csp3ReportTo);

  /// Stable Content security policy level 3 extensions
  // https://www.w3.org/TR/CSP3/#directives-elsewhere
  TCSP3Extensions = set of (csp3BlockAllMixedContent,
    csp3UpgradeInsecureRequests, csp3RequireSRIFor);

  /// Content security policy level 3 SRI requires
  TCSP3SRIRequire = (csp3SRIScript, csp3SRIStyle, csp3SRIScriptStyle);

  /// Content security policy level 3 source List
  TCSP3SourceList = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP3;
    Directive: TCSP3Directive;

    /// Assign to the specific CSP directive
    procedure Init(ACSP: PCSP3; const ADirective: TCSP3Directive);
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific source to the directive source list,
    // used by other methods below
    function Add(const Source: SockString): PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Empty source list and add signle "'none'" directive
    // 'none' must not be mixed with other values
    function None: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "null" host source
    function Null: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "*" host source (not recommended for production)
    function Any: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme-part}:" source
    // Section 6. In either case, developers SHOULD NOT include either
    // 'unsafe-inline', or data: as valid sources in their policies.
    // Both enable XSS attacks by allowing code to be included directly in the
    // document itself; they are best avoided completely.
    // - AScheme is defined in section 3.1 of RFC 3986.
    function Scheme(const AScheme: SockString): PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme-part}://{host-part}:{port-part}{path-part}" source
    // - AScheme is defined in section 3.1 of RFC 3986.
    // - AHost is "*" / [ "*." ] 1*host-char *( "." 1*host-char )
    // - APort is 1*DIGIT / "*"
    // - APath is path-absolute from
    //         https://tools.ietf.org/html/rfc3986#section-3.3
    function Host(
      const AScheme, AHost, APort, APath: SockString): PCSP3SourceList;
        overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{host}" source
    function Host(const AHost: SockString): PCSP3SourceList; overload;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'self'" keyword source
    function WithSelf: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'unsafe-inline'" keyword source
    // Section 6. In either case, developers SHOULD NOT include either
    // 'unsafe-inline', or data: as valid sources in their policies.
    // Both enable XSS attacks by allowing code to be included directly in the
    // document itself; they are best avoided completely.
    function UnsafeInline: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'unsafe-eval'" keyword source
    function UnsafeEval: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'strict-dynamic'" keyword source
    function StrictDynamic: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'unsafe-hashes'" keyword source
    function UnsafeHashes: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'report-sample'" keyword source
    function ReportSample: PCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'unsafe-allow-redirects'" keyword source
    function UnsafeAllowRedirects: PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'nonce-{value}'" source as a random generated sequence with
    // specific length. The server MUST generate a unique value each time
    // it transmits a policy. The generated value SHOULD be at least 128 bits
    // long (before encoding), and SHOULD be generated via a cryptographically
    // secure random number generator in order to ensure that the value
    // is difficult for an attacker to predict.
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function NonceLen(var Base64EncodedNonce: SockString;
      const NonceLength: Integer = 256;
      const AsBase64url: Boolean = False): PCSP3SourceList;
        {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'nonce-{value}'" source
    // The server MUST generate a unique value each time it transmits a policy.
    // The generated value SHOULD be at least 128 bits long (before encoding),
    // and SHOULD be generated via a cryptographically secure random number
    // generator in order to ensure that the value is difficult for an attacker
    // to predict.
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function Nonce(const ANonce: RawByteString;
      const AsBase64url: Boolean = False): PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'nonce-{value}'" where value is random generated
    // The server MUST generate a unique value each time it transmits a policy.
    // The generated value SHOULD be at least 128 bits long (before encoding),
    // and SHOULD be generated via a cryptographically secure random number
    // generator in order to ensure that the value is difficult for an attacker
    // to predict.
    // Base64 encoded sequence
    function Nonce64(const Base64EncodedNonce: SockString): PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" where value is a Base64 encodd hash calculated on
    // the provided content
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA256(const Content: RawByteString;
      const PBase64EncodedHash: PSockString = nil;
      const AsBase64url: Boolean = False): PCSP3SourceList;
        {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" with Base64 encoded hash
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA256Hash(const Hash: THash256;
      const AsBase64url: Boolean = False): PCSP3SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" with Base64 encoded hash
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA256Hash(const Hash: RawByteString;
      const AsBase64url: Boolean = False): PCSP3SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha256-{value}'" with provided Base64 encoded hash
    function SHA256Hash64(const Base64EncodedHash: SockString): PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" where value is a Base64 encodd hash calculated on
    // the provided content
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA384(const Content: RawByteString;
      const PBase64EncodedHash: PSockString = nil;
      const AsBase64url: Boolean = False): PCSP3SourceList;
        {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" with Base64 encoded hash
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA384Hash(const Hash: THash384;
      const AsBase64url: Boolean = False): PCSP3SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" with Base64 encoded hash
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA384Hash(const Hash: RawByteString;
      const AsBase64url: Boolean = False): PCSP3SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha384-{value}'" with provided Base64 encoded hash
    function SHA384Hash64(const Base64EncodedHash: SockString): PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" where value is a Base64 encodd hash calculated on
    // the provided content
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA512(const Content: RawByteString;
      const PBase64EncodedHash: PSockString = nil;
      const AsBase64url: Boolean = False): PCSP3SourceList;
        {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" with Base64 encoded hash
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA512Hash(const Hash: THash512;
      const AsBase64url: Boolean = False): PCSP3SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" with Base64 encoded hash
    // - AsBase64url is used to specify base64url encoding, instead of base64
    function SHA512Hash(const Hash: RawByteString;
      const AsBase64url: Boolean = False): PCSP3SourceList;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'sha512-{value}'" with provided Base64 encoded hash
    function SHA512Hash64(const Base64EncodedHash: SockString): PCSP3SourceList;
      {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content security policy level 3 media type list
  TCSP3MediaTypeList = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP3;

    /// Assign to the specific CSP
    procedure Init(ACSP: PCSP3); {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific source to the directive source list,
    // used by other methods below
    function Add(const Value: SockString): PCSP3MediaTypeList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "<type>/<subtype>" source
    function MediaType(
      const AMediaType, AMediaSubtype: SockString): PCSP3MediaTypeList;
        {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content security policy level 3 sandbox tokens
  TCSP3SandboxTokens = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP3;

    /// Assign to the specific CSP
    procedure Init(ACSP: PCSP3); {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific token to the directive token list,
    // used by other methods below
    function Add(const Value: SockString = ''): PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Clear all sandbox tokens and add empty token
    function Empty: PCSP3SandboxTokens; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add URI reference for reports sending
    function Token(const AToken: SockString): PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-popups' flag
    function AllowPopups: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-top-navigtion' flag
    function AllowTopNavigation: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-top-navigation-by-user-activation' flag
    function AllowTopNavigationByUserActivation: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-same-origin' flag
    function AllowSameOrigin: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-forms' flag
    function AllowForms: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-pointer-lock' flag
    function AllowPointerLock: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-scripts' flag
    function AllowScripts: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-popups-to-escape-sandbox' flag
    function AllowPopupsToEscapeSandbox: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-modals' flag
    function AllowModals: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-orientation-lock' flag
    function AllowOrientationLock: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'allow-presentation' flag
    function AllowPresentation: PCSP3SandboxTokens;
      {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content security policy level 3 frame ancestors
  TCSP3FrameAncestors = {$IFDEF FPC_OR_UNICODE} record {$ELSE} object {$ENDIF}
  public
    CSP: PCSP3;

    /// Assign to the specific CSP
    procedure Init(ACSP: PCSP3); {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add the specific source to the directive source list,
    // used by other methods below
    function Add(const Value: SockString): PCSP3FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'none'" source
    function None: PCSP3FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme}:" source
    // Section 6. In either case, developers SHOULD NOT include either
    // 'unsafe-inline', or data: as valid sources in their policies.
    // Both enable XSS attacks by allowing code to be included directly in the
    // document itself; they are best avoided completely.
    function Scheme(const AScheme: SockString): PCSP3FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{scheme}://{host}:{port}{path}" source
    function Host(const AScheme, AHost,
      APort, APath: SockString): PCSP3FrameAncestors;
        overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "{host}" source
    function Host(const AHost: SockString): PCSP3FrameAncestors;
      overload; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add "'self'" source
    function WithSelf: PCSP3FrameAncestors; {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

  /// Content Security Policy Level 3
  {$IFDEF FPC_OR_UNICODE}
    TCSP3 = record private
  {$ELSE}
    TCSP3 = object protected
  {$ENDIF}
  private
    Directives: array[TCSP3Directive] of TSockStringDynArray;
    Counts: array[TCSP3Directive] of PtrInt;
    Cached: Boolean;
    Cache: SockString;
    Extensions: TCSP3Extensions;
    SRIRequire: TCSP3SRIRequire;
  public
    /// Initialize structure
    function Init: PCSP3; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'child-src' directive governs the creation of nested browsing
    // contexts (e.g. iframe and frame navigations) and Worker execution
    // contexts.
    function ChildSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'connect-src' directive restricts the URLs which can be loaded using
    // script interfaces.
    function ConnectSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'default-src' directive serves as a fallback for the other fetch
    // directives.
    function DefaultSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'font-src' directive restricts the URLs from which font resources
    // may be loaded.
    function FontSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'frame-src' directive restricts the URLs which may be loaded into
    // nested browsing contexts.
    function FrameSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'img-src' directive restricts the URLs from which image resources
    // may be loaded.
    function ImgSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'manifest-src' directive restricts the URLs from which application
    // manifests may be loaded
    function ManifestSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'media-src' directive restricts the URLs from which video, audio,
    // and associated text track resources may be loaded.
    function MediaSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'prefetch-src' directive restricts the URLs from which resources
    // may be prefetched or prerendered.
    function PrefetchSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'object-src' directive restricts the URLs from which plugin content
    // may be loaded.
    function ObjectSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'script-src' directive restricts the locations from which scripts
    // may be executed. This includes not only URLs loaded directly into script
    // elements, but also things like inline script blocks and XSLT stylesheets
    // which can trigger script execution.
    function ScriptSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'script-src-elem' directive applies to all script requests and
    // script blocks.
    function ScriptSrcElem: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'script-src-attr' directive applies to event handlers and, if
    // present, it will override the script-src directive for relevant checks
    function ScriptSrcAttr: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'style-src' directive restricts the locations from which style may
    // be applied to a Document.
    function StyleSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'script-src-elem' directive applies to all script requests and
    // script blocks. Attributes that execute script (inline event handlers) are
    // controlled via 'script-src-attr'.
    function StyleSrcElem: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'script-src-attr' directive specifies valid sources for JavaScript
    // inline event handlers. This includes only inline script event handlers
    // like onclick, but not URLs loaded directly into <script> elements.
    function StyleSrcAttr: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'worker-src' directive restricts the URLs which may be loaded as a
    // Worker, SharedWorker, or ServiceWorker.
    function WorkerSrc: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'base-uri' directive restricts the URLs which can be used in a
    // Document's base element.
    function BaseURI: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'plugin-types' directive restricts the set of plugins that can be
    // embedded into a document by limiting the types of resources which can be
    // loaded.
    function PluginTypes: TCSP3MediaTypeList;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'sandbox' directive specifies an HTML sandbox policy which the user
    // agent will apply to a resource, just as though it had been included in an
    // iframe with a sandbox property.
    function Sandbox: TCSP3SandboxTokens; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'form-action' directive restricts the URLs which can be used as the
    // target of a form submissions from a given context.
    function FormAction: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'frame-ancestors' directive restricts the URLs which can embed the
    // resource using frame, iframe, object, embed, or applet element. Resources
    // can use this directive to avoid many UI Redressing attacks, by avoiding
    // the risk of being embedded into potentially hostile contexts.
    function FrameAncestors: TCSP3FrameAncestors;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'navigate-to' directive restricts the URLs to which a document can
    // initiate navigations by any means (a, form, window.location, window.open,
    // etc.). This is an enforcement on what navigations this document initiates
    // not on what this document is allowed to navigate to. If the form-action
    // directive is present, the navigate-to directive will not act on
    // navigations that are form submissions.
    function NavigateTo: TCSP3SourceList; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// The 'report-to' directive defines a reporting group to which violation
    // reports ought to be sent. The directive’s behavior is defined in
    // §5.3 Report a violation.
    function ReportTo(const AToken: SockString): PCSP3;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'block-all-mixed-content' extension directive
    // https://www.w3.org/TR/mixed-content/#block-all-mixed-content
    function BlockAllMixedContent: PCSP3; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'upgrade-insecure-requests' extension directive
    // https://www.w3.org/TR/upgrade-insecure-requests/#delivery
    function UpgradeInsecureRequests: PCSP3;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Add 'require-sri-for' extension directive
    // https://www.w3.org/TR/SRI/
    function RequireSRIFor(const ASRIRequire: TCSP3SRIRequire): PCSP3;
      {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Computes and cache security policy content
    function Policy: SockString;

    /// Computes 'Content-Security-Policy' HTTP header
    function HTTPHeader: SockString; {$IFDEF HASINLINE} inline; {$ENDIF}

    /// Computes 'Content-Security-Policy-Report-Only' HTTP header
    function HTTPHeaderReportOnly: SockString;
      {$IFDEF HASINLINE} inline; {$ENDIF}
  end;

implementation

{ TCSP2SourceList }

function TCSP2SourceList.Add(const Source: SockString): PCSP2SourceList;
begin
  if Length(Source) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[Directive]) = Counts[Directive] then
        SetLength(Directives[Directive], Counts[Directive] + 4);
      Directives[Directive][Counts[Directive]] := Source;
      Inc(Counts[Directive]);
    end;
  Result := @Self;
end;

function TCSP2SourceList.Any: PCSP2SourceList;
begin
  Result := Add('*');
end;

function TCSP2SourceList.Host(
  const AScheme, AHost, APort, APath: SockString): PCSP2SourceList;
var
  Value: SockString;
begin
  Value := AHost;
  if Length(AScheme) > 0 then
    Value := AScheme + '://' + Value;
  if Length(APort) > 0 then
    Value := Value + ':' + APort;
  if Length(APath) > 0 then
    Value := Value + APath;
  Result := Add(Value);
end;

function TCSP2SourceList.Host(const AHost: SockString): PCSP2SourceList;
begin
  Result := Add(AHost);
end;

procedure TCSP2SourceList.Init(ACSP: PCSP2; const ADirective: TCSP2Directive);
begin
  CSP := ACSP;
  Directive := ADirective;
end;

function TCSP2SourceList.NonceLen(var Base64EncodedNonce: SockString;
  const NonceLength: Integer): PCSP2SourceList;
begin
  Base64EncodedNonce := BinToBase64(TAESPRNG.Main.Fill(NonceLength shr 3));
  Result := Add(FormatUTF8('''nonce-%''', [Base64EncodedNonce]));
end;

function TCSP2SourceList.Nonce(const ANonce: RawByteString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''nonce-%''', [BinToBase64(ANonce)]));
end;

function TCSP2SourceList.Nonce64(
  const Base64EncodedNonce: SockString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''nonce-%''', [Base64EncodedNonce]));
end;

function TCSP2SourceList.None: PCSP2SourceList;
begin
  with CSP^ do
    if not ((Counts[Directive] = 1) and
      (Directives[Directive][0] = '''none''')) then
    begin
      Cache := '';
      Cached := False;
      SetLength(Directives[Directive], 1);
      Directives[Directive][0] := '''none''';
      Counts[Directive] := 1;
    end;
  Result := @Self;
end;

function TCSP2SourceList.Null: PCSP2SourceList;
begin
  Result := Add('null');
end;

function TCSP2SourceList.Scheme(const AScheme: SockString): PCSP2SourceList;
begin
  Result := Add(AScheme + ':');
end;

function TCSP2SourceList.WithSelf: PCSP2SourceList;
begin
  Result := Add('''self''');
end;

function TCSP2SourceList.SHA256(const Content: RawByteString;
  const PBase64EncodedHash: PSockString): PCSP2SourceList;
var
  LSHA256: TSHA256;
  Hash: THash256;
  EncodedHash: SockString;
begin
  LSHA256.Full(Pointer(Content), Length(Content), Hash);
  EncodedHash := BinToBase64(PAnsiChar(@Hash[0]), 32);
  Result := Add(FormatUTF8('''sha256-%''', [EncodedHash]));
  if PBase64EncodedHash <> nil then
    PBase64EncodedHash^ := EncodedHash;
end;

function TCSP2SourceList.SHA256Hash(const Hash: THash256): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha256-%''',
    [BinToBase64(PAnsiChar(@Hash[0]), 32)]));
end;

function TCSP2SourceList.SHA256Hash(const Hash: RawByteString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha256-%''',
    [BinToBase64(PAnsiChar(@Hash[1]), 32)]));
end;

function TCSP2SourceList.SHA256Hash64(
  const Base64EncodedHash: SockString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha256-%''', [Base64EncodedHash]));
end;

function TCSP2SourceList.SHA384(const Content: RawByteString;
  const PBase64EncodedHash: PSockString): PCSP2SourceList;
var
  LSHA384: TSHA384;
  Hash: THash384;
  EncodedHash: SockString;
begin
  LSHA384.Full(Pointer(Content), Length(Content), Hash);
  EncodedHash := BinToBase64(PAnsiChar(@Hash[0]), 48);
  Result := Add(FormatUTF8('''sha384-%''', [EncodedHash]));
  if PBase64EncodedHash <> nil then
    PBase64EncodedHash^ := EncodedHash;
end;

function TCSP2SourceList.SHA384Hash(const Hash: THash384): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha384-%''',
    [BinToBase64(PAnsiChar(@Hash[0]), 48)]));
end;

function TCSP2SourceList.SHA384Hash(const Hash: RawByteString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha384-%''',
    [BinToBase64(PAnsiChar(@Hash[1]), 48)]));
end;

function TCSP2SourceList.SHA384Hash64(
  const Base64EncodedHash: SockString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha384-%''', [Base64EncodedHash]));
end;

function TCSP2SourceList.SHA512(const Content: RawByteString;
  const PBase64EncodedHash: PSockString): PCSP2SourceList;
var
  LSHA512: TSHA512;
  Hash: THash512;
  EncodedHash: SockString;
begin
  LSHA512.Full(Pointer(Content), Length(Content), Hash);
  EncodedHash := BinToBase64(PAnsiChar(@Hash[0]), 64);
  Result := Add(FormatUTF8('''sha512-%''', [EncodedHash]));
  if PBase64EncodedHash <> nil then
    PBase64EncodedHash^ := EncodedHash;
end;

function TCSP2SourceList.SHA512Hash(const Hash: THash512): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha512-%''',
    [BinToBase64(PAnsiChar(@Hash[0]), 64)]));
end;

function TCSP2SourceList.SHA512Hash(const Hash: RawByteString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha512-%''',
    [BinToBase64(PAnsiChar(@Hash[1]), 64)]));
end;

function TCSP2SourceList.SHA512Hash64(
  const Base64EncodedHash: SockString): PCSP2SourceList;
begin
  Result := Add(FormatUTF8('''sha512-%''', [Base64EncodedHash]));
end;

function TCSP2SourceList.UnsafeEval: PCSP2SourceList;
begin
  Result := Add('''unsafe-eval''');
end;

function TCSP2SourceList.UnsafeInline: PCSP2SourceList;
begin
  Result := Add('''unsafe-inline''');
end;

{ TCSP2FrameAncestors }

function TCSP2FrameAncestors.Add(const Value: SockString): PCSP2FrameAncestors;
begin
  if Length(Value) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[csp2FrameAncestors]) =
        Counts[csp2FrameAncestors] then
          SetLength(Directives[csp2FrameAncestors],
            Counts[csp2FrameAncestors] + 4);
      Directives[csp2FrameAncestors][Counts[csp2FrameAncestors]] := Value;
      Inc(Counts[csp2FrameAncestors]);
    end;
  Result := @Self;
end;

function TCSP2FrameAncestors.Host(const AScheme, AHost, APort,
  APath: SockString): PCSP2FrameAncestors;
var
  Value: SockString;
begin
  Value := AHost;
  if Length(AScheme) > 0 then
    Value := AScheme + '://' + Value;
  if Length(APort) > 0 then
    Value := Value + ':' + APort;
  if Length(APath) > 0 then
    Value := Value + APath;
  Result := Add(Value);
end;

function TCSP2FrameAncestors.Host(const AHost: SockString): PCSP2FrameAncestors;
begin
  Result := Add(AHost);
end;

procedure TCSP2FrameAncestors.Init(ACSP: PCSP2);
begin
  CSP := ACSP;
end;

function TCSP2FrameAncestors.None: PCSP2FrameAncestors;
begin
  with CSP^ do
    if not ((Counts[csp2FrameAncestors] = 1) and
      (Directives[csp2FrameAncestors][0] = '''none''')) then
    begin
      Cache := '';
      Cached := False;
      SetLength(Directives[csp2FrameAncestors], 1);
      Directives[csp2FrameAncestors][0] := '''none''';
      Counts[csp2FrameAncestors] := 1;
    end;
  Result := @Self;
end;

function TCSP2FrameAncestors.Scheme(
  const AScheme: SockString): PCSP2FrameAncestors;
begin
  Result := Add(AScheme + ':');
end;

{ TCSP2MediaTypeList }

function TCSP2MediaTypeList.Add(const Value: SockString): PCSP2MediaTypeList;
begin
  if Length(Value) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[csp2PluginTypes]) = Counts[csp2PluginTypes] then
          SetLength(Directives[csp2PluginTypes], Counts[csp2PluginTypes] + 4);
      Directives[csp2PluginTypes][Counts[csp2PluginTypes]] := Value;
      Inc(Counts[csp2PluginTypes]);
    end;
  Result := @Self;
end;

procedure TCSP2MediaTypeList.Init(ACSP: PCSP2);
begin
  CSP := ACSP;
end;

function TCSP2MediaTypeList.MediaType(
  const AMediaType, AMediaSubtype: SockString): PCSP2MediaTypeList;
begin
  Result := Add(FormatUTF8('%/%', [AMediaType, AMediaSubtype]));
end;

{ TCSP2URIReferences }

function TCSP2URIReferences.Add(const Value: SockString): PCSP2URIReferences;
begin
  if Length(Value) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[csp2ReportURI]) = Counts[csp2ReportURI] then
          SetLength(Directives[csp2ReportURI], Counts[csp2ReportURI] + 4);
      Directives[csp2ReportURI][Counts[csp2ReportURI]] := Value;
      Inc(Counts[csp2ReportURI]);
    end;
  Result := @Self;
end;

procedure TCSP2URIReferences.Init(ACSP: PCSP2);
begin
  CSP := ACSP;
end;

function TCSP2URIReferences.Reference(
  const URIReference: SockString): PCSP2URIReferences;
begin
  Result := Add(URIReference);
end;

{ TCSPSandboxTokens }

function TCSP2SandboxTokens.Add(const Value: SockString): PCSP2SandboxTokens;
begin
  if Length(Value) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[csp2Sandbox]) = Counts[csp2Sandbox] then
          SetLength(Directives[csp2Sandbox], Counts[csp2Sandbox] + 4);
      Directives[csp2Sandbox][Counts[csp2Sandbox]] := Value;
      Inc(Counts[csp2Sandbox]);
    end;
  Result := @Self;
end;

function TCSP2SandboxTokens.AllowForms: PCSP2SandboxTokens;
begin
  Result := Add('allow-forms');
end;

function TCSP2SandboxTokens.AllowPointerLock: PCSP2SandboxTokens;
begin
  Result := Add('allow-pointer-lock');
end;

function TCSP2SandboxTokens.AllowPopups: PCSP2SandboxTokens;
begin
  Result := Add('allow-popups');
end;

function TCSP2SandboxTokens.AllowSameOrigin: PCSP2SandboxTokens;
begin
  Result := Add('allow-same-origin');
end;

function TCSP2SandboxTokens.AllowScripts: PCSP2SandboxTokens;
begin
  Result := Add('allow-scripts');
end;

function TCSP2SandboxTokens.AllowTopNavigation: PCSP2SandboxTokens;
begin
  Result := Add('allow-top-navigation');
end;

function TCSP2SandboxTokens.Empty: PCSP2SandboxTokens;
begin
  with CSP^ do
    if not ((Counts[csp2Sandbox] = 1) and
      (Directives[csp2Sandbox][0] = '')) then
    begin
      Cache := '';
      Cached := False;
      SetLength(Directives[csp2Sandbox], 1);
      Directives[csp2Sandbox][0] := '';
      Counts[csp2Sandbox] := 1;
    end;
  Result := @Self;
end;

procedure TCSP2SandboxTokens.Init(ACSP: PCSP2);
begin
  CSP := ACSP;
end;

function TCSP2SandboxTokens.Token(const AToken: SockString): PCSP2SandboxTokens;
begin
  Result := Add(AToken);
end;

{ TCSP2 }

function TCSP2.BaseURI: TCSP2SourceList;
begin
  Result.Init(@Self, csp2BaseURI);
end;

function TCSP2.ChildSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2ChildSrc);
end;

function TCSP2.ConnectSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2ConnectSrc);
end;

function TCSP2.DefaultSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2DefaultSrc);
end;

function TCSP2.FontSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2FontSrc);
end;

function TCSP2.FormAction: TCSP2SourceList;
begin
  Result.Init(@Self, csp2FormAction);
end;

function TCSP2.FrameAncestors: TCSP2FrameAncestors;
begin
  Result.Init(@Self);
end;

function TCSP2.HTTPHeader: SockString;
begin
  Result := FormatUTF8('Content-Security-Policy: %'#$D#$A, [Policy]);
end;

function TCSP2.HTTPHeaderReportOnly: SockString;
begin
  Result := FormatUTF8(
    'Content-Security-Policy-Report-Only: %'#$D#$A, [Policy]);
end;

function TCSP2.ImgSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2ImgSrc);
end;

function TCSP2.Init: PCSP2;
var
  PValues: ^TSockStringDynArray;
  Directive: TCSP2Directive;
begin
  PValues := @Directives[Low(TCSP2Directive)];
  for Directive := Low(TCSP2Directive) to High(TCSP2Directive) do
  begin
    if Length(PValues^) > 0 then
      SetLength(PValues^, 0);
    Inc(PValues);
  end;
  FillcharFast(Counts, SizeOf(Counts), 0);
  Cached := True;
  Cache := '';
  Result := @Self;
end;

function TCSP2.MediaSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2MediaSrc);
end;

function TCSP2.ObjectSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2ObjectSrc);
end;

function TCSP2.PluginTypes: TCSP2MediaTypeList;
begin
  Result.Init(@Self);
end;

function TCSP2.Policy: SockString;
const
  DIRECTIVE_NAMES: array[TCSP2Directive] of SockString = (
    'base-uri', 'child-src', 'connect-src', 'default-src', 'font-src',
    'form-action', 'frame-ancestors', 'img-src', 'media-src', 'object-src',
    'plugin-types', 'report-uri', 'sandbox', 'script-src', 'style-src');
var
  Index, MaxSize: PtrInt;
  PCount: PPtrInt;
  Directive: TCSP2Directive;
  Writer: TSynTempWriter;
  Value: SockString;
begin
  if not Cached then
  begin
    MaxSize := 0;
    PCount := @Counts[Low(TCSP2Directive)];
    for Directive := Low(TCSP2Directive) to High(TCSP2Directive) do
    begin
      if PCount^ > 0 then
      begin
        Inc(MaxSize, 15 + 1 + 2); // Length('frame-ancestors') + ' ' + '; '
        for Index := 0 to PCount^ - 1 do
          Inc(MaxSize, Length(Directives[Directive][Index]) * 3 + 1);
      end;
      Inc(PCount);
    end;
    Writer.Init(MaxSize);
    try
      PCount := @Counts[Low(TCSP2Directive)];
      for Directive := Low(TCSP2Directive) to High(TCSP2Directive) do
      begin
        if PCount^ > 0 then
        begin
          Writer.wr(Pointer(DIRECTIVE_NAMES[Directive])^,
            Length(DIRECTIVE_NAMES[Directive]));
          Writer.wrb(Ord(' '));
          for Index := 0 to PCount^ - 1 do
            if Length(Directives[Directive][Index]) > 0 then
            begin
              Value := StringReplaceAll(StringReplaceAll(
                Directives[Directive][Index], ';', '%3B'), ',', '%2C');
              Writer.wr(Pointer(Value)^, Length(Value));
              Writer.wrb(Ord(' '));
            end;
          Dec(Writer.pos);
          Writer.wrw(Ord(';') + Ord(' ') shl 8);
        end;
        Inc(PCount);
      end;
      if Writer.Position > 0 then
        Dec(Writer.pos, 2);
      Cache := Writer.AsBinary;
      Cached := True;
    finally
      Writer.Done;
    end;
  end;
  Result := Cache;
end;

function TCSP2.ReportURI: TCSP2URIReferences;
begin
  Result.Init(@Self);
end;

function TCSP2.Sandbox: TCSP2SandboxTokens;
begin
  Result.Init(@Self)
end;

function TCSP2.ScriptSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2ScriptSrc);
end;

function TCSP2.StyleSrc: TCSP2SourceList;
begin
  Result.Init(@Self, csp2StyleSrc);
end;

{ TCSP3SourceList }

function TCSP3SourceList.Add(const Source: SockString): PCSP3SourceList;
begin
  if Length(Source) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[Directive]) = Counts[Directive] then
        SetLength(Directives[Directive], Counts[Directive] + 4);
      Directives[Directive][Counts[Directive]] := Source;
      Inc(Counts[Directive]);
    end;
  Result := @Self;
end;

function TCSP3SourceList.Any: PCSP3SourceList;
begin
  Result := Add('*');
end;

function TCSP3SourceList.Host(const AScheme, AHost, APort,
  APath: SockString): PCSP3SourceList;
var
  Value: SockString;
begin
  Value := AHost;
  if Length(AScheme) > 0 then
    Value := AScheme + '://' + Value;
  if Length(APort) > 0 then
    Value := Value + ':' + APort;
  if Length(APath) > 0 then
    Value := Value + APath;
  Result := Add(Value);
end;

function TCSP3SourceList.Host(const AHost: SockString): PCSP3SourceList;
begin
  Result := Add(AHost);
end;

procedure TCSP3SourceList.Init(ACSP: PCSP3; const ADirective: TCSP3Directive);
begin
  CSP := ACSP;
  Directive := ADirective;
end;

function TCSP3SourceList.Nonce(const ANonce: RawByteString;
  const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Result := Add(FormatUTF8('''nonce-%''', [BinToBase64uri(ANonce)]))
  else
    Result := Add(FormatUTF8('''nonce-%''', [BinToBase64(ANonce)]));
end;

function TCSP3SourceList.NonceLen(var Base64EncodedNonce: SockString;
  const NonceLength: Integer; const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Base64EncodedNonce := BinToBase64uri(TAESPRNG.Main.Fill(NonceLength shr 3))
  else
    Base64EncodedNonce := BinToBase64(TAESPRNG.Main.Fill(NonceLength shr 3));
  Result := Add(FormatUTF8('''nonce-%''', [Base64EncodedNonce]));
end;

function TCSP3SourceList.Nonce64(
  const Base64EncodedNonce: SockString): PCSP3SourceList;
begin
  Result := Add(FormatUTF8('''nonce-%''', [Base64EncodedNonce]));
end;

function TCSP3SourceList.None: PCSP3SourceList;
begin
  with CSP^ do
    if not ((Counts[Directive] = 1) and
      (Directives[Directive][0] = '''none''')) then
    begin
      Cache := '';
      Cached := False;
      SetLength(Directives[Directive], 1);
      Directives[Directive][0] := '''none''';
      Counts[Directive] := 1;
    end;
  Result := @Self;
end;

function TCSP3SourceList.Null: PCSP3SourceList;
begin
  Result := Add('null');
end;

function TCSP3SourceList.ReportSample: PCSP3SourceList;
begin
  Result := Add('''report-sample''');
end;

function TCSP3SourceList.Scheme(const AScheme: SockString): PCSP3SourceList;
begin
  Result := Add(AScheme + ':');
end;

function TCSP3SourceList.SHA256(const Content: RawByteString;
  const PBase64EncodedHash: PSockString;
  const AsBase64url: Boolean): PCSP3SourceList;
var
  LSHA256: TSHA256;
  Hash: THash256;
  EncodedHash: SockString;
begin
  LSHA256.Full(Pointer(Content), Length(Content), Hash);
  if AsBase64url then
    EncodedHash := BinToBase64uri(PAnsiChar(@Hash[0]), 32)
  else
    EncodedHash := BinToBase64(PAnsiChar(@Hash[0]), 32);
  Result := Add(FormatUTF8('''sha256-%''', [EncodedHash]));
  if PBase64EncodedHash <> nil then
    PBase64EncodedHash^ := EncodedHash;
end;

function TCSP3SourceList.SHA256Hash(const Hash: THash256;
  const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Result := Add(FormatUTF8('''sha256-%''',
      [BinToBase64uri(PAnsiChar(@Hash[0]), 32)]))
  else
    Result := Add(FormatUTF8('''sha256-%''',
      [BinToBase64(PAnsiChar(@Hash[0]), 32)]));
end;

function TCSP3SourceList.SHA256Hash(const Hash: RawByteString;
  const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Result := Add(FormatUTF8('''sha256-%''',
      [BinToBase64uri(PAnsiChar(@Hash[1]), 32)]))
  else
    Result := Add(FormatUTF8('''sha256-%''',
      [BinToBase64(PAnsiChar(@Hash[1]), 32)]));
end;

function TCSP3SourceList.SHA256Hash64(
  const Base64EncodedHash: SockString): PCSP3SourceList;
begin
  Result := Add(FormatUTF8('''sha256-%''', [Base64EncodedHash]));
end;

function TCSP3SourceList.SHA384(const Content: RawByteString;
  const PBase64EncodedHash: PSockString;
  const AsBase64url: Boolean): PCSP3SourceList;
var
  LSHA384: TSHA384;
  Hash: THash384;
  EncodedHash: SockString;
begin
  LSHA384.Full(Pointer(Content), Length(Content), Hash);
  if AsBase64url then
    EncodedHash := BinToBase64uri(PAnsiChar(@Hash[0]), 48)
  else
    EncodedHash := BinToBase64(PAnsiChar(@Hash[0]), 48);
  Result := Add(FormatUTF8('''sha384-%''', [EncodedHash]));
  if PBase64EncodedHash <> nil then
    PBase64EncodedHash^ := EncodedHash;
end;

function TCSP3SourceList.SHA384Hash(const Hash: THash384;
  const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Result := Add(FormatUTF8('''sha384-%''',
      [BinToBase64uri(PAnsiChar(@Hash[0]), 48)]))
  else
    Result := Add(FormatUTF8('''sha384-%''',
      [BinToBase64(PAnsiChar(@Hash[0]), 48)]));
end;

function TCSP3SourceList.SHA384Hash(const Hash: RawByteString;
  const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Result := Add(FormatUTF8('''sha384-%''',
      [BinToBase64uri(PAnsiChar(@Hash[1]), 48)]))
  else
    Result := Add(FormatUTF8('''sha384-%''',
      [BinToBase64(PAnsiChar(@Hash[1]), 48)]));
end;

function TCSP3SourceList.SHA384Hash64(
  const Base64EncodedHash: SockString): PCSP3SourceList;
begin
  Result := Add(FormatUTF8('''sha384-%''', [Base64EncodedHash]));
end;

function TCSP3SourceList.SHA512(const Content: RawByteString;
  const PBase64EncodedHash: PSockString;
  const AsBase64url: Boolean): PCSP3SourceList;
var
  LSHA512: TSHA512;
  Hash: THash512;
  EncodedHash: SockString;
begin
  LSHA512.Full(Pointer(Content), Length(Content), Hash);
  if AsBase64url then
    EncodedHash := BinToBase64uri(PAnsiChar(@Hash[0]), 64)
  else
    EncodedHash := BinToBase64(PAnsiChar(@Hash[0]), 64);
  Result := Add(FormatUTF8('''sha512-%''', [EncodedHash]));
  if PBase64EncodedHash <> nil then
    PBase64EncodedHash^ := EncodedHash;
end;

function TCSP3SourceList.SHA512Hash(const Hash: THash512;
  const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Result := Add(FormatUTF8('''sha512-%''',
      [BinToBase64uri(PAnsiChar(@Hash[0]), 64)]))
  else
    Result := Add(FormatUTF8('''sha512-%''',
      [BinToBase64(PAnsiChar(@Hash[0]), 64)]));
end;

function TCSP3SourceList.SHA512Hash(const Hash: RawByteString;
  const AsBase64url: Boolean): PCSP3SourceList;
begin
  if AsBase64url then
    Result := Add(FormatUTF8('''sha512-%''',
      [BinToBase64uri(PAnsiChar(@Hash[1]), 64)]))
  else
    Result := Add(FormatUTF8('''sha512-%''',
      [BinToBase64(PAnsiChar(@Hash[1]), 64)]));
end;

function TCSP3SourceList.SHA512Hash64(
  const Base64EncodedHash: SockString): PCSP3SourceList;
begin
  Result := Add(FormatUTF8('''sha512-%''', [Base64EncodedHash]));
end;

function TCSP3SourceList.StrictDynamic: PCSP3SourceList;
begin
  Result := Add('''strict-dynamic''');
end;

function TCSP3SourceList.UnsafeAllowRedirects: PCSP3SourceList;
begin
  Result := Add('''unsafe-allow-redirects''');
end;

function TCSP3SourceList.UnsafeEval: PCSP3SourceList;
begin
  Result := Add('''unsafe-eval''');
end;

function TCSP3SourceList.UnsafeHashes: PCSP3SourceList;
begin
  Result := Add('''unsafe-hashes''');
end;

function TCSP3SourceList.UnsafeInline: PCSP3SourceList;
begin
  Result := Add('''unsafe-inline''');
end;

function TCSP3SourceList.WithSelf: PCSP3SourceList;
begin
  Result := Add('''self''');
end;

{ TCSP3MediaTypeList }

function TCSP3MediaTypeList.Add(const Value: SockString): PCSP3MediaTypeList;
begin
  if Length(Value) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[csp3PluginTypes]) = Counts[csp3PluginTypes] then
          SetLength(Directives[csp3PluginTypes], Counts[csp3PluginTypes] + 4);
      Directives[csp3PluginTypes][Counts[csp3PluginTypes]] := Value;
      Inc(Counts[csp3PluginTypes]);
    end;
  Result := @Self;
end;

procedure TCSP3MediaTypeList.Init(ACSP: PCSP3);
begin
  CSP := ACSP;
end;

function TCSP3MediaTypeList.MediaType(const AMediaType,
  AMediaSubtype: SockString): PCSP3MediaTypeList;
begin
  Result := Add(FormatUTF8('%/%', [AMediaType, AMediaSubtype]));
end;

{ TCSP3SandboxTokens }

function TCSP3SandboxTokens.Add(const Value: SockString): PCSP3SandboxTokens;
begin
  if Length(Value) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[csp3Sandbox]) = Counts[csp3Sandbox] then
          SetLength(Directives[csp3Sandbox], Counts[csp3Sandbox] + 4);
      Directives[csp3Sandbox][Counts[csp3Sandbox]] := Value;
      Inc(Counts[csp3Sandbox]);
    end;
  Result := @Self;
end;

function TCSP3SandboxTokens.AllowForms: PCSP3SandboxTokens;
begin
  Result := Add('allow-forms');
end;

function TCSP3SandboxTokens.AllowModals: PCSP3SandboxTokens;
begin
  Result := Add('allow-modals');
end;

function TCSP3SandboxTokens.AllowOrientationLock: PCSP3SandboxTokens;
begin
  Result := Add('allow-orientation-lock');
end;

function TCSP3SandboxTokens.AllowPointerLock: PCSP3SandboxTokens;
begin
  Result := Add('allow-pointer-lock');
end;

function TCSP3SandboxTokens.AllowPopups: PCSP3SandboxTokens;
begin
  Result := Add('allow-popups');
end;

function TCSP3SandboxTokens.AllowPopupsToEscapeSandbox: PCSP3SandboxTokens;
begin
  Result := Add('allow-popups-to-escape-sandbox');
end;

function TCSP3SandboxTokens.AllowPresentation: PCSP3SandboxTokens;
begin
  Result := Add('allow-presentation');
end;

function TCSP3SandboxTokens.AllowSameOrigin: PCSP3SandboxTokens;
begin
  Result := Add('allow-same-origin');
end;

function TCSP3SandboxTokens.AllowScripts: PCSP3SandboxTokens;
begin
  Result := Add('allow-scripts');
end;

function TCSP3SandboxTokens.AllowTopNavigation: PCSP3SandboxTokens;
begin
  Result := Add('allow-top-navigtion');
end;

function TCSP3SandboxTokens.AllowTopNavigationByUserActivation:
  PCSP3SandboxTokens;
begin
  Result := Add('allow-top-navigation-by-user-activation');
end;

function TCSP3SandboxTokens.Empty: PCSP3SandboxTokens;
begin
  with CSP^ do
    if not ((Counts[csp3Sandbox] = 1) and
      (Directives[csp3Sandbox][0] = '')) then
    begin
      Cache := '';
      Cached := False;
      SetLength(Directives[csp3Sandbox], 1);
      Directives[csp3Sandbox][0] := '';
      Counts[csp3Sandbox] := 1;
    end;
  Result := @Self;
end;

procedure TCSP3SandboxTokens.Init(ACSP: PCSP3);
begin
  CSP := ACSP;
end;

function TCSP3SandboxTokens.Token(const AToken: SockString): PCSP3SandboxTokens;
begin
  Result := Add(AToken);
end;

{ TCSP3FrameAncestors }

function TCSP3FrameAncestors.Add(const Value: SockString): PCSP3FrameAncestors;
begin
  if Length(Value) > 0 then
    with CSP^ do
    begin
      Cache := '';
      Cached := False;
      if Length(Directives[csp3FrameAncestors]) =
        Counts[csp3FrameAncestors] then
          SetLength(Directives[csp3FrameAncestors],
            Counts[csp3FrameAncestors] + 4);
      Directives[csp3FrameAncestors][Counts[csp3FrameAncestors]] := Value;
      Inc(Counts[csp3FrameAncestors]);
    end;
  Result := @Self;
end;

function TCSP3FrameAncestors.Host(const AScheme, AHost, APort,
  APath: SockString): PCSP3FrameAncestors;
var
  Value: SockString;
begin
  Value := AHost;
  if Length(AScheme) > 0 then
    Value := AScheme + '://' + Value;
  if Length(APort) > 0 then
    Value := Value + ':' + APort;
  if Length(APath) > 0 then
    Value := Value + APath;
  Result := Add(Value);
end;

function TCSP3FrameAncestors.Host(const AHost: SockString): PCSP3FrameAncestors;
begin
  Result := Add(AHost);
end;

procedure TCSP3FrameAncestors.Init(ACSP: PCSP3);
begin
  CSP := ACSP;
end;

function TCSP3FrameAncestors.None: PCSP3FrameAncestors;
begin
  with CSP^ do
    if not ((Counts[csp3FrameAncestors] = 1) and
      (Directives[csp3FrameAncestors][0] = '''none''')) then
    begin
      Cache := '';
      Cached := False;
      SetLength(Directives[csp3FrameAncestors], 1);
      Directives[csp3FrameAncestors][0] := '''none''';
      Counts[csp3FrameAncestors] := 1;
    end;
  Result := @Self;
end;

function TCSP3FrameAncestors.Scheme(
  const AScheme: SockString): PCSP3FrameAncestors;
begin
  Result := Add(AScheme + ':');
end;

function TCSP3FrameAncestors.WithSelf: PCSP3FrameAncestors;
begin
  Result := Add('''self''')
end;

{ TCSP3 }

function TCSP3.BaseURI: TCSP3SourceList;
begin
  Result.Init(@Self, csp3BaseURI);
end;

function TCSP3.BlockAllMixedContent: PCSP3;
begin
  Include(Extensions, csp3BlockAllMixedContent);
  Cache := '';
  Cached := False;
  Result := @Self;
end;

function TCSP3.ChildSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ChildSrc);
end;

function TCSP3.ConnectSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ConnectSrc);
end;

function TCSP3.DefaultSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3DefaultSrc);
end;

function TCSP3.FontSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3FontSrc);
end;

function TCSP3.FormAction: TCSP3SourceList;
begin
  Result.Init(@Self, csp3FormAction);
end;

function TCSP3.FrameAncestors: TCSP3FrameAncestors;
begin
  Result.Init(@Self);
end;

function TCSP3.FrameSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3FrameSrc);
end;

function TCSP3.HTTPHeader: SockString;
begin
  Result := FormatUTF8('Content-Security-Policy: %'#$D#$A, [Policy]);
end;

function TCSP3.HTTPHeaderReportOnly: SockString;
begin
  Result := FormatUTF8(
    'Content-Security-Policy-Report-Only: %'#$D#$A, [Policy]);
end;

function TCSP3.ImgSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ImgSrc);
end;

function TCSP3.Init: PCSP3;
var
  PValues: ^TSockStringDynArray;
  Directive: TCSP3Directive;
begin
  PValues := @Directives[Low(TCSP3Directive)];
  for Directive := Low(TCSP3Directive) to High(TCSP3Directive) do
  begin
    if Length(PValues^) > 0 then
      SetLength(PValues^, 0);
    Inc(PValues);
  end;
  FillcharFast(Counts, SizeOf(Counts), 0);
  Cached := True;
  Cache := '';
  Extensions := [];
  SRIRequire := csp3SRIScriptStyle;
  Result := @Self;
end;

function TCSP3.ManifestSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ManifestSrc);
end;

function TCSP3.MediaSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3MediaSrc);
end;

function TCSP3.NavigateTo: TCSP3SourceList;
begin
  Result.Init(@Self, csp3NavigateTo);
end;

function TCSP3.ObjectSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ObjectSrc);
end;

function TCSP3.PluginTypes: TCSP3MediaTypeList;
begin
  Result.Init(@Self);
end;

function TCSP3.Policy: SockString;
const
  DIRECTIVE_NAMES: array[TCSP3Directive] of SockString = (
    'child-src', 'connect-src', 'default-src', 'font-src', 'frame-src',
    'img-src', 'manifest-src', 'media-src', 'prefetch-src', 'object-src',
    'script-src', 'script-src-elem', 'script-src-attr', 'style-src',
    'style-src-elem', 'style-src-attr', 'worker-src', 'base-uri',
    'plugin-types', 'sandbox', 'form-action', 'frame-ancestors', 'navigate-to',
    'report-to');
  DIRECTIVE_BLOCK_ALL_MIXED_CONTENT: SockString = 'block-all-mixed-content';
  DIRECTIVE_UPGRADE_INSECURE_REQUESTS: SockString = 'upgrade-insecure-requests';
  DIRECTIVE_REQUIRE_SRI_FOR_SCRIPT: SockString = 'require-sri-for script';
  DIRECTIVE_REQUIRE_SRI_FOR_STYLE: SockString = 'require-sri-for style';
  DIRECTIVE_REQUIRE_SRI_FOR_SCRIPT_STYLE: SockString =
    'require-sri-for script style';
var
  Index, MaxSize: PtrInt;
  PCount: PPtrInt;
  Directive: TCSP3Directive;
  Writer: TSynTempWriter;
  Value: SockString;
begin
  if not Cached then
  begin
    MaxSize := 0;
    PCount := @Counts[Low(TCSP3Directive)];
    for Directive := Low(TCSP3Directive) to High(TCSP3Directive) do
    begin
      if PCount^ > 0 then
      begin
        Inc(MaxSize, 15 + 1 + 2); // 'frame-ancestors' + ' ' + '; '
        for Index := 0 to PCount^ - 1 do
          Inc(MaxSize, Length(Directives[Directive][Index]) * 3 + 1);
      end;
      Inc(PCount);
    end;
    if csp3BlockAllMixedContent in Extensions then
      Inc(MaxSize, 23 + 2); // 'block-all-mixed-content; '
    if csp3UpgradeInsecureRequests in Extensions then
      Inc(MaxSize, 25 + 2); // 'upgrade-insecure-requests; '
    if csp3RequireSRIFor in Extensions then
      Inc(MaxSize, 15 + 1 + 6 + 1 + 5 + 2); // 'require-sri-for script style; '

    Writer.Init(MaxSize);
    try
      PCount := @Counts[Low(TCSP3Directive)];
      for Directive := Low(TCSP3Directive) to High(TCSP3Directive) do
      begin
        if PCount^ > 0 then
        begin
          Writer.wr(Pointer(DIRECTIVE_NAMES[Directive])^,
            Length(DIRECTIVE_NAMES[Directive]));
          Writer.wrb(Ord(' '));
          for Index := 0 to PCount^ - 1 do
            if Length(Directives[Directive][Index]) > 0 then
            begin
              Value := StringReplaceAll(StringReplaceAll(
                Directives[Directive][Index], ';', '%3B'), ',', '%2C');
              Writer.wr(Pointer(Value)^, Length(Value));
              Writer.wrb(Ord(' '));
            end;
          Dec(Writer.pos);
          Writer.wrw(Ord(';') + Ord(' ') shl 8);
        end;
        Inc(PCount);
      end;
      if csp3BlockAllMixedContent in Extensions then
      begin
        Writer.wr(Pointer(DIRECTIVE_BLOCK_ALL_MIXED_CONTENT)^,
          Length(DIRECTIVE_BLOCK_ALL_MIXED_CONTENT));
        Writer.wrw(Ord(';') + Ord(' ') shl 8);
      end;
      if csp3UpgradeInsecureRequests in Extensions then
      begin
        Writer.wr(Pointer(DIRECTIVE_UPGRADE_INSECURE_REQUESTS)^,
          Length(DIRECTIVE_UPGRADE_INSECURE_REQUESTS));
        Writer.wrw(Ord(';') + Ord(' ') shl 8);
      end;
      if csp3RequireSRIFor in Extensions then
      begin
        case SRIRequire of
          csp3SRIScript:
            Writer.wr(Pointer(DIRECTIVE_REQUIRE_SRI_FOR_SCRIPT)^,
              Length(DIRECTIVE_REQUIRE_SRI_FOR_SCRIPT));
          csp3SRIStyle:
            Writer.wr(Pointer(DIRECTIVE_REQUIRE_SRI_FOR_STYLE)^,
              Length(DIRECTIVE_REQUIRE_SRI_FOR_STYLE));
          csp3SRIScriptStyle:
            Writer.wr(Pointer(DIRECTIVE_REQUIRE_SRI_FOR_SCRIPT_STYLE)^,
              Length(DIRECTIVE_REQUIRE_SRI_FOR_SCRIPT_STYLE));
        end;
        Writer.wrw(Ord(';') + Ord(' ') shl 8);
      end;
      if Writer.Position > 0 then
        Dec(Writer.pos, 2);
      Cache := Writer.AsBinary;
      Cached := True;
    finally
      Writer.Done;
    end;
  end;
  Result := Cache;
end;

function TCSP3.PrefetchSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3PrefetchSrc);
end;

function TCSP3.ReportTo(const AToken: SockString): PCSP3;
begin
  if not ((Counts[csp3ReportTo] = 1) and
    (Directives[csp3ReportTo][0] = AToken)) then
  begin
    Cache := '';
    Cached := False;
    SetLength(Directives[csp3ReportTo], 1);
    Directives[csp3ReportTo][0] := AToken;
    Counts[csp3ReportTo] := 1;
  end;
  Result := @Self;
end;

function TCSP3.RequireSRIFor(const ASRIRequire: TCSP3SRIRequire): PCSP3;
begin
  Include(Extensions, csp3RequireSRIFor);
  SRIRequire := ASRIRequire;
  Cache := '';
  Cached := False;
  Result := @Self;
end;

function TCSP3.Sandbox: TCSP3SandboxTokens;
begin
  Result.Init(@Self);
end;

function TCSP3.ScriptSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ScriptSrc);
end;

function TCSP3.ScriptSrcAttr: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ScriptSrcAttr);
end;

function TCSP3.ScriptSrcElem: TCSP3SourceList;
begin
  Result.Init(@Self, csp3ScriptSrcElem);
end;

function TCSP3.StyleSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3StyleSrc);
end;

function TCSP3.StyleSrcAttr: TCSP3SourceList;
begin
  Result.Init(@Self, csp3StyleSrcAttr);
end;

function TCSP3.StyleSrcElem: TCSP3SourceList;
begin
  Result.Init(@Self, csp3StyleSrcElem);
end;

function TCSP3.UpgradeInsecureRequests: PCSP3;
begin
  Include(Extensions, csp3UpgradeInsecureRequests);
  Cache := '';
  Cached := False;
  Result := @Self;
end;

function TCSP3.WorkerSrc: TCSP3SourceList;
begin
  Result.Init(@Self, csp3WorkerSrc);
end;

end.
