unit uRESTDWAssets;

interface

{$I Synopse.inc}
// define HASINLINE CPU32 CPU64

Uses
  SysUtils,
  SynCommons;

Type
  TFileCheck = (fcModified, fcSize);
  TFileChecks = Set Of TFileCheck;
  TAssetEncoding = (aeIdentity, aeGZip, aeRESTDW);
  {$IFDEF FPC} {$PACKRECORDS 1} {$ELSE} {$A-} {$ENDIF}
  TAsset = {$IFDEF FPC_OR_UNICODE}Record {$ELSE}Object{$ENDIF}
  Public
   Path          : RawUTF8;
   Timestamp     : TDateTime;
   Content       : RawByteString;
   ContentHash   : Cardinal;
   ContentType   : RawUTF8;
   GZipExists    : Boolean;
   GZipContent   : RawByteString;
   GZipHash      : Cardinal;
   RESTDWExists  : Boolean;
   RESTDWContent : RawByteString;
   RESTDWHash    : Cardinal;
   Function LoadFromFile(Const Root, FileName : TFileName) : Boolean;
   Procedure SetContent (Const AContent       : RawByteString;
                         Const Encoding       : TAssetEncoding = aeIdentity);
   Function SaveToFile  (Const Root           : TFileName      = '';
                         Const Encoding       : TAssetEncoding = aeIdentity;
                         Const ChecksNotModified : TFileChecks = [fcModified, fcSize]): TFileName;
   Function SaveIdentityToFile(Const Root     : TFileName = '';
                               Const ChecksNotModified : TFileChecks = [fcModified, fcSize]): TFileName;
 End;
PAsset = ^TAsset;
TAssetDynArray = Array Of TAsset;
Type
 {$IFDEF FPC_OR_UNICODE}
  TAssets = Record Private
 {$ELSE}
  TAssets = Object Protected
 {$ENDIF}
  FAssetsDAH : TDynArrayHashed;
  Public
   Assets: TAssetDynArray;
   Count: Integer;
   Procedure Init;
   Function  Add              (Const Root,
                               FileName       : TFileName): PAsset;
   Function  SaveToFile       (Const FileName : TFileName): Boolean;
   Procedure LoadFromFile     (Const FileName : TFileName);
   Procedure LoadFromResource (Const ResName  : string);
   Procedure SaveAll          (Const Root     : TFileName = '';
                               Const ChecksNotModified : TFileChecks = [fcModified, fcSize]);
   Procedure SaveAllIdentities(Const Root     : TFileName = '';
                               Const ChecksNotModified : TFileChecks = [fcModified, fcSize]);
   Function Find              (Const Path              : RawUTF8): PAsset;{$IFDEF HASINLINE}Inline;{$ENDIF}
End;

Procedure CreateDirectories(Const DirName  : TFileName);{$IFDEF HASINLINE}Inline;{$ENDIF}
Function  GetFileInfo      (Const FileName : TFileName;
                            Modified       : PDateTime;
                            Size           : PInt64): Boolean;

Function  SetFileTime      (Const FileName : TFileName;
                            Const Modified : TDateTime) : Boolean;{$IFDEF HASINLINE}Inline;{$ENDIF}

Var
 KnownMIMETypes: TSynNameValue;

Const
  MIME_TYPES_FILE_EXTENSIONS: array[0..1490 Shl 1 - 1]  Of RawUTF8 = ('application/a2l', '.a2l',
                                                                      'application/aml', '.aml',
                                                                      'application/andrew-inset', '.ez',
                                                                      'application/applixware', '.aw',
                                                                      'application/atf', '.atf',
                                                                      'application/atfx', '.atfx',
                                                                      'application/atom+xml', '.atom',
                                                                      'application/atomcat+xml', '.atomcat',
                                                                      'application/atomdeleted+xml', '.atomdeleted',
                                                                      'application/atomsvc+xml', '.atomsvc',
                                                                      'application/atsc-dwd+xml', '.dwd',
                                                                      'application/atsc-held+xml', '.held',
                                                                      'application/atsc-rsat+xml', '.rsat',
                                                                      'application/atxml', '.atxml',
                                                                      'application/auth-policy+xml', '.apxml',
                                                                      'application/bacnet-xdd+zip', '.xdd',
                                                                      'application/calendar+xml', '.xcs',
                                                                      'application/cbor', '.cbor',
                                                                      'application/cccex', '.c3ex',
                                                                      'application/ccmp+xml', '.ccmp',
                                                                      'application/ccxml+xml', '.ccxml',
                                                                      'application/cdfx+xml', '.cdfx',
                                                                      'application/cdmi-capability', '.cdmia',
                                                                      'application/cdmi-container', '.cdmic',
                                                                      'application/cdmi-domain', '.cdmid',
                                                                      'application/cdmi-object', '.cdmio',
                                                                      'application/cdmi-queue', '.cdmiq',
                                                                      'application/cea', '.cea',
                                                                      'application/cellml+xml', '.cellml',
                                                                      'application/clue_info+xml', '.clue',
                                                                      'application/cms', '.cmsc',
                                                                      'application/cpl+xml', '.cpl',
                                                                      'application/csrattrs', '.csrattrs',
                                                                      'application/cu-seeme', '.cu',
                                                                      'application/dash+xml', '.mpd',
                                                                      'application/dashdelta', '.mpdd',
                                                                      'application/davmount+xml', '.davmount',
                                                                      'application/dcd', '.dcd',
                                                                      'application/dicom', '.dcm',
                                                                      'application/dii', '.dii',
                                                                      'application/dit', '.dit',
                                                                      'application/docbook+xml', '.dbk',
                                                                      'application/dskpp+xml', '.xmls',
                                                                      'application/dssc+der', '.dssc',
                                                                      'application/dssc+xml', '.xdssc',
                                                                      'application/dvcs', '.dvc',
                                                                      'application/ecmascript', '.ecma',
                                                                      'application/efi', '.efi',
                                                                      'application/emma+xml', '.emma',
                                                                      'application/emotionml+xml', '.emotionml',
                                                                      'application/epub+zip', '.epub',
                                                                      'application/exi', '.exi',
                                                                      'application/fastinfoset', '.finf',
                                                                      'application/fdt+xml', '.fdt',
                                                                      'application/font-tdpfr', '.pfr',
                                                                      'application/geo+json', '.geojson',
                                                                      'application/geo+json', '.topojson',
                                                                      'application/geopackage+sqlite3', '.gpkg',
                                                                      'application/gltf-buffer', '.glbin',
                                                                      'application/gltf-buffer', '.glbuf',
                                                                      'application/gml+xml', '.gml',
                                                                      'application/gpx+xml', '.gpx',
                                                                      'application/gxf', '.gxf',
                                                                      'application/gzip', '.gz',
                                                                      'application/held+xml', '.heldxml',
                                                                      'application/hyperstudio', '.stk',
                                                                      'application/inkml+xml', '.ink',
                                                                      'application/inkml+xml', '.inkml',
                                                                      'application/ipfix', '.ipfix',
                                                                      'application/its+xml', '.its',
                                                                      'application/java-archive', '.jar',
                                                                      'application/java-serialized-object', '.ser',
                                                                      'application/java-vm', '.class',
                                                                      'application/jrd+json', '.jrd',
                                                                      'application/json', '.json',
                                                                      'application/json-patch+json', '.json-patch',
                                                                      'application/jsonml+json', '.jsonml',
                                                                      'application/ld+json', '.jsonld',
                                                                      'application/lgr+xml', '.lgr',
                                                                      'application/link-format', '.wlnk',
                                                                      'application/lost+xml', '.lostxml',
                                                                      'application/lostsync+xml', '.lostsyncxml',
                                                                      'application/lpf+zip', '.lpf',
                                                                      'application/lxf', '.lxf',
                                                                      'application/mac-binhex40', '.hqx',
                                                                      'application/mac-compactpro', '.cpt',
                                                                      'application/mads+xml', '.mads',
                                                                      'application/manifest+json', '.webmanifest',
                                                                      'application/marc', '.mrc',
                                                                      'application/marcxml+xml', '.mrcx',
                                                                      'application/mathematica', '.ma',
                                                                      'application/mathematica', '.mb',
                                                                      'application/mathematica', '.nb',
                                                                      'application/mathml+xml', '.mathml',
                                                                      'application/mbox', '.mbox',
                                                                      'application/mediaservercontrol+xml', '.mscml',
                                                                      'application/metalink+xml', '.metalink',
                                                                      'application/metalink4+xml', '.meta4',
                                                                      'application/mets+xml', '.mets',
                                                                      'application/mf4', '.mf4',
                                                                      'application/mmt-aei+xml', '.maei',
                                                                      'application/mmt-usd+xml', '.musd',
                                                                      'application/mods+xml', '.mods',
                                                                      'application/mp21', '.m21',
                                                                      'application/mp21', '.mp21',
                                                                      'application/mp4', '.mp4s',
                                                                      'application/msword', '.doc',
                                                                      'application/msword', '.dot',
                                                                      'application/mxf', '.mxf',
                                                                      'application/n-quads', '.nq',
                                                                      'application/n-triples', '.nt',
                                                                      'application/node', '.cjs',
                                                                      'application/ocsp-request', '.orq',
                                                                      'application/ocsp-response', '.ors',
                                                                      'application/octet-stream', '.bin',
                                                                      'application/octet-stream', '.bpk',
                                                                      'application/octet-stream', '.deploy',
                                                                      'application/octet-stream', '.dump',
                                                                      'application/octet-stream', '.elc',
                                                                      'application/octet-stream', '.lrf',
                                                                      'application/octet-stream', '.mar',
                                                                      'application/octet-stream', '.safariextz',
                                                                      'application/octet-stream', '.so',
                                                                      'application/oda', '.oda',
                                                                      'application/odx', '.odx',
                                                                      'application/oebps-package+xml', '.opf',
                                                                      'application/ogg', '.ogx',
                                                                      'application/omdoc+xml', '.omdoc',
                                                                      'application/onenote', '.onepkg',
                                                                      'application/onenote', '.onetmp',
                                                                      'application/onenote', '.onetoc',
                                                                      'application/onenote', '.onetoc2',
                                                                      'application/oxps', '.oxps',
                                                                      'application/p2p-overlay+xml', '.relo',
                                                                      'application/patch-ops-error+xml', '.xer',
                                                                      'application/pdf', '.pdf',
                                                                      'application/pdx', '.pdx',
                                                                      'application/pem-certificate-chain', '.pem',
                                                                      'application/pgp-encrypted', '.pgp',
                                                                      'application/pgp-signature', '.asc',
                                                                      'application/pgp-signature', '.sig',
                                                                      'application/pics-rules', '.prf',
                                                                      'application/pkcs10', '.p10',
                                                                      'application/pkcs12', '.p12',
                                                                      'application/pkcs12', '.pfx',
                                                                      'application/pkcs7-mime', '.p7c',
                                                                      'application/pkcs7-mime', '.p7m',
                                                                      'application/pkcs7-mime', '.p7z',
                                                                      'application/pkcs7-signature', '.p7s',
                                                                      'application/pkcs8', '.p8',
                                                                      'application/pkcs8-encrypted', '.p8e',
                                                                      'application/pkix-attr-cert', '.ac',
                                                                      'application/pkix-cert', '.cer',
                                                                      'application/pkix-crl', '.crl',
                                                                      'application/pkix-pkipath', '.pkipath',
                                                                      'application/pkixcmp', '.pki',
                                                                      'application/pls+xml', '.pls',
                                                                      'application/postscript', '.ai',
                                                                      'application/postscript', '.eps',
                                                                      'application/postscript', '.ps',
                                                                      'application/provenance+xml', '.provx',
                                                                      'application/prs.cww', '.cw',
                                                                      'application/prs.cww', '.cww',
                                                                      'application/prs.hpub+zip', '.hpub',
                                                                      'application/prs.nprend', '.rct',
                                                                      'application/prs.nprend', '.rnd',
                                                                      'application/prs.rdf-xml-crypt', '.rdf-crypt',
                                                                      'application/prs.xsf+xml', '.xsf',
                                                                      'application/pskc+xml', '.pskcxml',
                                                                      'application/rdf+xml', '.rdf',
                                                                      'application/reginfo+xml', '.rif',
                                                                      'application/relax-ng-compact-syntax', '.rnc',
                                                                      'application/resource-lists+xml', '.rl',
                                                                      'application/resource-lists-diff+xml', '.rld',
                                                                      'application/rfc+xml', '.rfcxml',
                                                                      'application/rls-services+xml', '.rs',
                                                                      'application/route-apd+xml', '.rapd',
                                                                      'application/route-s-tsid+xml', '.sls',
                                                                      'application/route-usd+xml', '.rusd',
                                                                      'application/rpki-manifest', '.mft',
                                                                      'application/rpki-roa', '.roa',
                                                                      'application/rsd+xml', '.rsd',
                                                                      'application/rss+xml', '.rss',
                                                                      'application/rtf', '.rtf',
                                                                      'application/sarif+json', '.sarif',
                                                                      'application/sbml+xml', '.sbml',
                                                                      'application/scim+json', '.scim',
                                                                      'application/scim+json', '.scm',
                                                                      'application/scvp-cv-request', '.scq',
                                                                      'application/scvp-cv-response', '.scs',
                                                                      'application/scvp-vp-request', '.spq',
                                                                      'application/scvp-vp-response', '.spp',
                                                                      'application/sdp', '.sdp',
                                                                      'application/senml+cbor', '.senmlc',
                                                                      'application/senml+json', '.senml',
                                                                      'application/senml+xml', '.senmlx',
                                                                      'application/senml-etch+cbor', '.senml-etchc',
                                                                      'application/senml-etch+json', '.senml-etchj',
                                                                      'application/senml-exi', '.senmle',
                                                                      'application/sensml+cbor', '.sensmlc',
                                                                      'application/sensml+json', '.sensml',
                                                                      'application/sensml+xml', '.sensmlx',
                                                                      'application/sensml-exi', '.sensmle',
                                                                      'application/set-payment-initiation', '.setpay',
                                                                      'application/set-registration-initiation', '.setreg',
                                                                      'application/shf+xml', '.shf',
                                                                      'application/sieve', '.sieve',
                                                                      'application/sieve', '.siv',
                                                                      'application/sipc', '.h5',
                                                                      'application/smil+xml', '.smi',
                                                                      'application/smil+xml', '.smil',
                                                                      'application/smil+xml', '.sml',
                                                                      'application/sparql-query', '.rq',
                                                                      'application/sparql-results+xml', '.srx',
                                                                      'application/sql', '.sql',
                                                                      'application/srgs', '.gram',
                                                                      'application/srgs+xml', '.grxml',
                                                                      'application/sru+xml', '.sru',
                                                                      'application/ssdl+xml', '.ssdl',
                                                                      'application/ssml+xml', '.ssml',
                                                                      'application/stix+json', '.stix',
                                                                      'application/swid+xml', '.swidtag',
                                                                      'application/tamp-apex-update', '.tau',
                                                                      'application/tamp-apex-update-confirm', '.auc',
                                                                      'application/tamp-community-update', '.tcu',
                                                                      'application/tamp-community-update-confirm', '.cuc',
                                                                      'application/tamp-error', '.ter',
                                                                      'application/tamp-sequence-adjust', '.tsa',
                                                                      'application/tamp-sequence-adjust-confirm', '.sac',
                                                                      'application/tamp-status-query', '.tsq',
                                                                      'application/tamp-status-response', '.tsr',
                                                                      'application/tamp-update', '.tur',
                                                                      'application/tamp-update-confirm', '.tuc',
                                                                      'application/td+json', '.jsontd',
                                                                      'application/tei+xml', '.odd',
                                                                      'application/tei+xml', '.tei',
                                                                      'application/tei+xml', '.teicorpus',
                                                                      'application/thraud+xml', '.tfi',
                                                                      'application/timestamped-data', '.tsd',
                                                                      'application/trig', '.trig',
                                                                      'application/ttml+xml', '.ttml',
                                                                      'application/urc-grpsheet+xml', '.gsheet',
                                                                      'application/urc-ressheet+xml', '.rsheet',
                                                                      'application/urc-targetdesc+xml', '.td',
                                                                      'application/urc-uisocketdesc+xml', '.uis',
                                                                      'application/vnd.1000minds.decision-model+xml', '.1km',
                                                                      'application/vnd.3gpp.pic-bw-large', '.plb',
                                                                      'application/vnd.3gpp.pic-bw-small', '.psb',
                                                                      'application/vnd.3gpp.pic-bw-Var', '.pvb',
                                                                      'application/vnd.3gpp2.sms', '.sms',
                                                                      'application/vnd.3gpp2.tcap', '.tcap',
                                                                      'application/vnd.3lightssoftware.imagescal', '.imgcal',
                                                                      'application/vnd.3m.post-it-notes', '.pwn',
                                                                      'application/vnd.accpac.simply.aso', '.aso',
                                                                      'application/vnd.accpac.simply.imp', '.imp',
                                                                      'application/vnd.acucobol', '.acu',
                                                                      'application/vnd.acucorp', '.acutc',
                                                                      'application/vnd.acucorp', '.atc',
                                                                      'application/vnd.adobe.air-application-installer-package+zip', '.air',
                                                                      'application/vnd.adobe.formscentral.fcdt', '.fcdt',
                                                                      'application/vnd.adobe.fxp', '.fxp',
                                                                      'application/vnd.adobe.fxp', '.fxpl',
                                                                      'application/vnd.adobe.xdp+xml', '.xdp',
                                                                      'application/vnd.adobe.xfdf', '.xfdf',
                                                                      'application/vnd.afpc.modca-overlay', '.ovl',
                                                                      'application/vnd.afpc.modca-pagesegment', '.psg',
                                                                      'application/vnd.ahead.space', '.ahead',
                                                                      'application/vnd.airzip.filesecure.azf', '.azf',
                                                                      'application/vnd.airzip.filesecure.azs', '.azs',
                                                                      'application/vnd.amazon.ebook', '.azw',
                                                                      'application/vnd.amazon.mobi8-ebook', '.azw3',
                                                                      'application/vnd.americandynamics.acc', '.acc',
                                                                      'application/vnd.amiga.ami', '.ami',
                                                                      'application/vnd.android.ota', '.ota',
                                                                      'application/vnd.android.package-archive', '.apk',
                                                                      'application/vnd.anki', '.apkg',
                                                                      'application/vnd.anser-web-certificate-issue-initiation', '.cii',
                                                                      'application/vnd.anser-web-funds-transfer-initiation', '.fti',
                                                                      'application/vnd.apple.installer+xml', '.dist',
                                                                      'application/vnd.apple.installer+xml', '.distz',
                                                                      'application/vnd.apple.installer+xml', '.mpkg',
                                                                      'application/vnd.apple.installer+xml', '.pkg',
                                                                      'application/vnd.apple.keynote', '.key',
                                                                      'application/vnd.apple.mpegurl', '.m3u8',
                                                                      'application/vnd.apple.numbers', '.numbers',
                                                                      'application/vnd.apple.pages', '.pages',
                                                                      'application/vnd.aristanetworks.swi', '.swi',
                                                                      'application/vnd.artisan+json', '.artisan',
                                                                      'application/vnd.astraea-software.iota', '.iota',
                                                                      'application/vnd.audiograph', '.aep',
                                                                      'application/vnd.autopackage', '.package',
                                                                      'application/vnd.balsamiq.bmml+xml', '.bmml',
                                                                      'application/vnd.balsamiq.bmpr', '.bmpr',
                                                                      'application/vnd.banana-accounting', '.ac2',
                                                                      'application/vnd.biopax.rdf+xml', '.owl',
                                                                      'application/vnd.blueice.multipass', '.mpm',
                                                                      'application/vnd.bluetooth.ep.oob', '.ep',
                                                                      'application/vnd.bluetooth.le.oob', '.le',
                                                                      'application/vnd.bmi', '.bmi',
                                                                      'application/vnd.bpf', '.bpf',
                                                                      'application/vnd.bpf3', '.bpf3',
                                                                      'application/vnd.businessobjects', '.rep',
                                                                      'application/vnd.cendio.thinlinc.clientconf', '.tlclient',
                                                                      'application/vnd.chemdraw+xml', '.cdxml',
                                                                      'application/vnd.chipnuts.karaoke-mmd', '.mmd',
                                                                      'application/vnd.cinderella', '.cdy',
                                                                      'application/vnd.citationstyles.style+xml', '.csl',
                                                                      'application/vnd.claymore', '.cla',
                                                                      'application/vnd.cloanto.rp9', '.rp9',
                                                                      'application/vnd.clonk.c4group', '.c4d',
                                                                      'application/vnd.clonk.c4group', '.c4f',
                                                                      'application/vnd.clonk.c4group', '.c4g',
                                                                      'application/vnd.clonk.c4group', '.c4p',
                                                                      'application/vnd.clonk.c4group', '.c4u',
                                                                      'application/vnd.cluetrust.cartomobile-config', '.c11amc',
                                                                      'application/vnd.cluetrust.cartomobile-config-pkg', '.c11amz',
                                                                      'application/vnd.coffeescript', '.coffee',
                                                                      'application/vnd.collabio.xodocuments.document', '.xodt',
                                                                      'application/vnd.collabio.xodocuments.document-template', '.xott',
                                                                      'application/vnd.collabio.xodocuments.presentation', '.xodp',
                                                                      'application/vnd.collabio.xodocuments.presentation-template', '.xotp',
                                                                      'application/vnd.collabio.xodocuments.spreadsheet', '.xods',
                                                                      'application/vnd.collabio.xodocuments.spreadsheet-template', '.xots',
                                                                      'application/vnd.commerce-battelle', '.ic0',
                                                                      'application/vnd.commerce-battelle', '.ic1 ic2',
                                                                      'application/vnd.commerce-battelle', '.ic3',
                                                                      'application/vnd.commerce-battelle', '.ic4',
                                                                      'application/vnd.commerce-battelle', '.ic5',
                                                                      'application/vnd.commerce-battelle', '.ic6',
                                                                      'application/vnd.commerce-battelle', '.ic7',
                                                                      'application/vnd.commerce-battelle', '.ic8',
                                                                      'application/vnd.commerce-battelle', '.ica',
                                                                      'application/vnd.commerce-battelle', '.icd icc',
                                                                      'application/vnd.commerce-battelle', '.icf',
                                                                      'application/vnd.commonspace', '.csp',
                                                                      'application/vnd.contact.cmsg', '.cdbcmsg',
                                                                      'application/vnd.coreos.ignition+json', '.ign',
                                                                      'application/vnd.coreos.ignition+json', '.ignition',
                                                                      'application/vnd.cosmocaller', '.cmc',
                                                                      'application/vnd.crick.clicker', '.clkx',
                                                                      'application/vnd.crick.clicker.keyboard', '.clkk',
                                                                      'application/vnd.crick.clicker.palette', '.clkp',
                                                                      'application/vnd.crick.clicker.template', '.clkt',
                                                                      'application/vnd.crick.clicker.wordbank', '.clkw',
                                                                      'application/vnd.criticaltools.wbs+xml', '.wbs',
                                                                      'application/vnd.crypto-shade-file', '.ssvc',
                                                                      'application/vnd.ctc-posml', '.pml',
                                                                      'application/vnd.cups-ppd', '.ppd',
                                                                      'application/vnd.curl.car', '.car',
                                                                      'application/vnd.curl.pcurl', '.pcurl',
                                                                      'application/vnd.dart', '.dart',
                                                                      'application/vnd.data-vision.rdz', '.rdz',
                                                                      'application/vnd.dbf', '.dbf',
                                                                      'application/vnd.dece.data', '.uvd',
                                                                      'application/vnd.dece.data', '.uvf',
                                                                      'application/vnd.dece.data', '.uvvd',
                                                                      'application/vnd.dece.data', '.uvvf',
                                                                      'application/vnd.dece.ttml+xml', '.uvt',
                                                                      'application/vnd.dece.ttml+xml', '.uvvt',
                                                                      'application/vnd.dece.unspecified', '.uvvx',
                                                                      'application/vnd.dece.unspecified', '.uvx',
                                                                      'application/vnd.dece.zip', '.uvvz',
                                                                      'application/vnd.dece.zip', '.uvz',
                                                                      'application/vnd.denovo.fcselayout-link', '.fe_launch',
                                                                      'application/vnd.desmume.movie', '.dsm',
                                                                      'application/vnd.dna', '.dna',
                                                                      'application/vnd.document+json', '.docjson',
                                                                      'application/vnd.doremir.scorecloud-binary-document', '.scld',
                                                                      'application/vnd.dpgraph', '.dpg',
                                                                      'application/vnd.dpgraph', '.dpgraph',
                                                                      'application/vnd.dpgraph', '.mwc',
                                                                      'application/vnd.dreamfactory', '.dfac',
                                                                      'application/vnd.ds-keypoint', '.kpxx',
                                                                      'application/vnd.dtg.local.flash', '.fla',
                                                                      'application/vnd.dvb.ait', '.ait',
                                                                      'application/vnd.dvb.service', '.svc',
                                                                      'application/vnd.dynageo', '.geo',
                                                                      'application/vnd.dzr', '.dzr',
                                                                      'application/vnd.ecowin.chart', '.mag',
                                                                      'application/vnd.efi.img', '.img',
                                                                      'application/vnd.enliven', '.nml',
                                                                      'application/vnd.epson.esf', '.esf',
                                                                      'application/vnd.epson.msf', '.msf',
                                                                      'application/vnd.epson.quickanime', '.qam',
                                                                      'application/vnd.epson.salt', '.slt',
                                                                      'application/vnd.epson.ssf', '.ssf',
                                                                      'application/vnd.ericsson.quickcall', '.qca',
                                                                      'application/vnd.ericsson.quickcall', '.qcall',
                                                                      'application/vnd.espass-espass+zip', '.espass',
                                                                      'application/vnd.eszigno3+xml', '.es3',
                                                                      'application/vnd.eszigno3+xml', '.et3',
                                                                      'application/vnd.etsi.asic-e+zip', '.asice',
                                                                      'application/vnd.etsi.asic-e+zip', '.sce',
                                                                      'application/vnd.etsi.asic-s+zip', '.asics',
                                                                      'application/vnd.etsi.timestamp-token', '.tst',
                                                                      'application/vnd.evolv.ecig.profile', '.ecigprofile',
                                                                      'application/vnd.evolv.ecig.settings', '.ecig',
                                                                      'application/vnd.evolv.ecig.theme', '.ecigtheme',
                                                                      'application/vnd.exstream-empower+zip', '.mpw',
                                                                      'application/vnd.ezpix-album', '.ez2',
                                                                      'application/vnd.ezpix-package', '.ez3',
                                                                      'application/vnd.fastcopy-disk-image', '.dim',
                                                                      'application/vnd.fdf', '.fdf',
                                                                      'application/vnd.fdsn.mseed', '.msd',
                                                                      'application/vnd.fdsn.mseed', '.mseed',
                                                                      'application/vnd.fdsn.seed', '.dataless',
                                                                      'application/vnd.fdsn.seed', '.seed',
                                                                      'application/vnd.ficlab.flb+zip', '.flb',
                                                                      'application/vnd.filmit.zfc', '.zfc',
                                                                      'application/vnd.flographit', '.gph',
                                                                      'application/vnd.fluxtime.clip', '.ftc',
                                                                      'application/vnd.font-fontforge-sfd', '.sfd',
                                                                      'application/vnd.framemaker', '.book',
                                                                      'application/vnd.framemaker', '.fm',
                                                                      'application/vnd.framemaker', '.frame',
                                                                      'application/vnd.framemaker', '.maker',
                                                                      'application/vnd.frogans.fnc', '.fnc',
                                                                      'application/vnd.frogans.ltf', '.ltf',
                                                                      'application/vnd.fsc.weblaunch', '.fsc',
                                                                      'application/vnd.fujitsu.oasys', '.oas',
                                                                      'application/vnd.fujitsu.oasys2', '.oa2',
                                                                      'application/vnd.fujitsu.oasys3', '.oa3',
                                                                      'application/vnd.fujitsu.oasysgp', '.fg5',
                                                                      'application/vnd.fujitsu.oasysprs', '.bh2',
                                                                      'application/vnd.fujixerox.ddd', '.ddd',
                                                                      'application/vnd.fujixerox.docuworks', '.xdw',
                                                                      'application/vnd.fujixerox.docuworks.binder', '.xbd',
                                                                      'application/vnd.fujixerox.docuworks.container', '.xct',
                                                                      'application/vnd.fuzzysheet', '.fzs',
                                                                      'application/vnd.genomatix.tuxedo', '.txd',
                                                                      'application/vnd.gentics.grd+json', '.grd',
                                                                      'application/vnd.geogebra.file', '.ggb',
                                                                      'application/vnd.geogebra.tool', '.ggt',
                                                                      'application/vnd.geometry-explorer', '.gex',
                                                                      'application/vnd.geometry-explorer', '.gre',
                                                                      'application/vnd.geonext', '.gxt',
                                                                      'application/vnd.geoplan', '.g2w',
                                                                      'application/vnd.geospace', '.g3w',
                                                                      'application/vnd.gerber', '.gbr',
                                                                      'application/vnd.gmx', '.gmx',
                                                                      'application/vnd.google-earth.kml+xml', '.kml',
                                                                      'application/vnd.google-earth.kmz', '.kmz',
                                                                      'application/vnd.grafeq', '.gqf',
                                                                      'application/vnd.grafeq', '.gqs',
                                                                      'application/vnd.groove-account', '.gac',
                                                                      'application/vnd.groove-help', '.ghf',
                                                                      'application/vnd.groove-identity-message', '.gim',
                                                                      'application/vnd.groove-injector', '.grv',
                                                                      'application/vnd.groove-tool-message', '.gtm',
                                                                      'application/vnd.groove-tool-template', '.tpl',
                                                                      'application/vnd.groove-vcard', '.vcg',
                                                                      'application/vnd.hal+xml', '.hal',
                                                                      'application/vnd.handheld-entertainment+xml', '.zmm',
                                                                      'application/vnd.hbci', '.bpd',
                                                                      'application/vnd.hbci', '.hbc',
                                                                      'application/vnd.hbci', '.hbci',
                                                                      'application/vnd.hbci', '.kom',
                                                                      'application/vnd.hbci', '.pkd',
                                                                      'application/vnd.hbci', '.upa',
                                                                      'application/vnd.hdt', '.hdt',
                                                                      'application/vnd.hhe.lesson-player', '.les',
                                                                      'application/vnd.hp-hpgl', '.hpgl',
                                                                      'application/vnd.hp-hpid', '.hpi',
                                                                      'application/vnd.hp-hpid', '.hpid',
                                                                      'application/vnd.hp-hps', '.hps',
                                                                      'application/vnd.hp-jlyt', '.jlt',
                                                                      'application/vnd.hp-pcl', '.pcl',
                                                                      'application/vnd.hp-pclxl', '.pclxl',
                                                                      'application/vnd.hydrostatix.sof-data', '.sfd-hdstx',
                                                                      'application/vnd.ibm.electronic-media', '.emm',
                                                                      'application/vnd.ibm.minipay', '.mpy',
                                                                      'application/vnd.ibm.modcap', '.afp',
                                                                      'application/vnd.ibm.modcap', '.list3820',
                                                                      'application/vnd.ibm.modcap', '.listafp',
                                                                      'application/vnd.ibm.modcap', '.pseg3820',
                                                                      'application/vnd.ibm.rights-management', '.irm',
                                                                      'application/vnd.ibm.secure-container', '.sc',
                                                                      'application/vnd.iccprofile', '.icc',
                                                                      'application/vnd.iccprofile', '.icm',
                                                                      'application/vnd.ieee.1905', '.1905',
                                                                      'application/vnd.igloader', '.igl',
                                                                      'application/vnd.imagemeter.folder+zip', '.imf',
                                                                      'application/vnd.imagemeter.image+zip', '.imi',
                                                                      'application/vnd.immervision-ivp', '.ivp',
                                                                      'application/vnd.immervision-ivu', '.ivu',
                                                                      'application/vnd.ims.imsccv1p3', '.imscc',
                                                                      'application/vnd.insors.igm', '.igm',
                                                                      'application/vnd.intercon.formnet', '.xpw',
                                                                      'application/vnd.intercon.formnet', '.xpx',
                                                                      'application/vnd.intergeo', '.i2g',
                                                                      'application/vnd.intu.qbo', '.qbo',
                                                                      'application/vnd.intu.qfx', '.qfx',
                                                                      'application/vnd.ipunplugged.rcprofile', '.rcprofile',
                                                                      'application/vnd.irepository.package+xml', '.irp',
                                                                      'application/vnd.is-xpr', '.xpr',
                                                                      'application/vnd.isac.fcs', '.fcs',
                                                                      'application/vnd.jam', '.jam',
                                                                      'application/vnd.jcp.javame.midlet-rms', '.rms',
                                                                      'application/vnd.jisp', '.jisp',
                                                                      'application/vnd.joost.joda-archive', '.joda',
                                                                      'application/vnd.kahootz', '.ktr',
                                                                      'application/vnd.kahootz', '.ktz',
                                                                      'application/vnd.kde.karbon', '.karbon',
                                                                      'application/vnd.kde.kchart', '.chrt',
                                                                      'application/vnd.kde.kformula', '.kfo',
                                                                      'application/vnd.kde.kivio', '.flw',
                                                                      'application/vnd.kde.kontour', '.kon',
                                                                      'application/vnd.kde.kpresenter', '.kpr',
                                                                      'application/vnd.kde.kpresenter', '.kpt',
                                                                      'application/vnd.kde.kspread', '.ksp',
                                                                      'application/vnd.kde.kword', '.kwd',
                                                                      'application/vnd.kde.kword', '.kwt',
                                                                      'application/vnd.kenameaapp', '.htke',
                                                                      'application/vnd.kidspiration', '.kia',
                                                                      'application/vnd.kinar', '.kne',
                                                                      'application/vnd.kinar', '.knp',
                                                                      'application/vnd.kinar', '.sdf',
                                                                      'application/vnd.koan', '.skd',
                                                                      'application/vnd.koan', '.skm',
                                                                      'application/vnd.koan', '.skp',
                                                                      'application/vnd.koan', '.skt',
                                                                      'application/vnd.kodak-descriptor', '.sse',
                                                                      'application/vnd.las', '.las',
                                                                      'application/vnd.las.las+json', '.lasjson',
                                                                      'application/vnd.las.las+xml', '.lasxml',
                                                                      'application/vnd.laszip', '.laz',
                                                                      'application/vnd.llamagraphics.life-balance.desktop', '.lbd',
                                                                      'application/vnd.llamagraphics.life-balance.exchange+xml', '.lbe',
                                                                      'application/vnd.logipipe.circuit+zip', '.lca',
                                                                      'application/vnd.logipipe.circuit+zip', '.lcs',
                                                                      'application/vnd.loom', '.loom',
                                                                      'application/vnd.lotus-1-2-3', '.0',
                                                                      'application/vnd.lotus-1-2-3', '.123',
                                                                      'application/vnd.lotus-1-2-3', '.wk1',
                                                                      'application/vnd.lotus-1-2-3', '.wk3',
                                                                      'application/vnd.lotus-1-2-3', '.wk4',
                                                                      'application/vnd.lotus-approach', '.apr',
                                                                      'application/vnd.lotus-approach', '.vew',
                                                                      'application/vnd.lotus-freelance', '.pre',
                                                                      'application/vnd.lotus-freelance', '.prz',
                                                                      'application/vnd.lotus-notes', '.ndl',
                                                                      'application/vnd.lotus-notes', '.ns2',
                                                                      'application/vnd.lotus-notes', '.ns3',
                                                                      'application/vnd.lotus-notes', '.ns4',
                                                                      'application/vnd.lotus-notes', '.nsf',
                                                                      'application/vnd.lotus-notes', '.nsg',
                                                                      'application/vnd.lotus-organizer', '.or2',
                                                                      'application/vnd.lotus-organizer', '.or3',
                                                                      'application/vnd.lotus-organizer', '.org',
                                                                      'application/vnd.lotus-wordpro', '.lwp',
                                                                      'application/vnd.lotus-wordpro', '.sam',
                                                                      'application/vnd.macports.portpkg', '.portpkg',
                                                                      'application/vnd.mapbox-vector-tile', '.mvt',
                                                                      'application/vnd.marlin.drm.mdcf', '.mdc',
                                                                      'application/vnd.maxmind.maxmind-db', '.mmdb',
                                                                      'application/vnd.mcd', '.mcd',
                                                                      'application/vnd.medcalcdata', '.mc1',
                                                                      'application/vnd.mediastation.cdkey', '.cdkey',
                                                                      'application/vnd.mfer', '.mwf',
                                                                      'application/vnd.mfmp', '.mfm',
                                                                      'application/vnd.micrografx.flo', '.flo',
                                                                      'application/vnd.micrografx.igx', '.igx',
                                                                      'application/vnd.microsoft.portable-executable', '.dll',
                                                                      'application/vnd.microsoft.portable-executable', '.exe',
                                                                      'application/vnd.mif', '.mif',
                                                                      'application/vnd.mobius.daf', '.daf',
                                                                      'application/vnd.mobius.dis', '.dis',
                                                                      'application/vnd.mobius.mbk', '.mbk',
                                                                      'application/vnd.mobius.mqy', '.mqy',
                                                                      'application/vnd.mobius.msl', '.msl',
                                                                      'application/vnd.mobius.plc', '.plc',
                                                                      'application/vnd.mobius.txf', '.txf',
                                                                      'application/vnd.mophun.application', '.mpn',
                                                                      'application/vnd.mophun.certificate', '.mpc',
                                                                      'application/vnd.mozilla.xul+xml', '.xul',
                                                                      'application/vnd.ms-artgalry', '.cil',
                                                                      'application/vnd.ms-cab-compressed', '.cab',
                                                                      'application/vnd.ms-excel', '.xla',
                                                                      'application/vnd.ms-excel', '.xlc',
                                                                      'application/vnd.ms-excel', '.xlm',
                                                                      'application/vnd.ms-excel', '.xls',
                                                                      'application/vnd.ms-excel', '.xlt',
                                                                      'application/vnd.ms-excel', '.xlw',
                                                                      'application/vnd.ms-excel.addin.macroenabled.12', '.xlam',
                                                                      'application/vnd.ms-excel.sheet.binary.macroenabled.12', '.xlsb',
                                                                      'application/vnd.ms-excel.sheet.macroenabled.12', '.xlsm',
                                                                      'application/vnd.ms-excel.template.macroenabled.12', '.xltm',
                                                                      'application/vnd.ms-fontobject', '.eot',
                                                                      'application/vnd.ms-htmlhelp', '.chm',
                                                                      'application/vnd.ms-ims', '.ims',
                                                                      'application/vnd.ms-lrm', '.lrm',
                                                                      'application/vnd.ms-officetheme', '.thmx',
                                                                      'application/vnd.ms-pki.seccat', '.cat',
                                                                      'application/vnd.ms-powerpoint', '.pot',
                                                                      'application/vnd.ms-powerpoint', '.pps',
                                                                      'application/vnd.ms-powerpoint', '.ppt',
                                                                      'application/vnd.ms-powerpoint.addin.macroenabled.12', '.ppam',
                                                                      'application/vnd.ms-powerpoint.presentation.macroenabled.12', '.pptm',
                                                                      'application/vnd.ms-powerpoint.slide.macroenabled.12', '.sldm',
                                                                      'application/vnd.ms-powerpoint.slideshow.macroenabled.12', '.ppsm',
                                                                      'application/vnd.ms-powerpoint.template.macroenabled.12', '.potm',
                                                                      'application/vnd.ms-project', '.mpp',
                                                                      'application/vnd.ms-project', '.mpt',
                                                                      'application/vnd.ms-word.document.macroenabled.12', '.docm',
                                                                      'application/vnd.ms-word.template.macroenabled.12', '.dotm',
                                                                      'application/vnd.ms-works', '.wcm',
                                                                      'application/vnd.ms-works', '.wdb',
                                                                      'application/vnd.ms-works', '.wks',
                                                                      'application/vnd.ms-works', '.wps',
                                                                      'application/vnd.ms-wpl', '.wpl',
                                                                      'application/vnd.ms-xpsdocument', '.xps',
                                                                      'application/vnd.msa-disk-image', '.msa',
                                                                      'application/vnd.mseq', '.mseq',
                                                                      'application/vnd.multiad.creator', '.crtr',
                                                                      'application/vnd.musician', '.mus',
                                                                      'application/vnd.muvee.style', '.msty',
                                                                      'application/vnd.mynfc', '.taglet',
                                                                      'application/vnd.nervana', '.bkm',
                                                                      'application/vnd.nervana', '.entity',
                                                                      'application/vnd.nervana', '.kcm',
                                                                      'application/vnd.nervana', '.req',
                                                                      'application/vnd.nervana', '.request',
                                                                      'application/vnd.neurolanguage.nlu', '.nlu',
                                                                      'application/vnd.nimn', '.nimn',
                                                                      'application/vnd.nintendo.nitro.rom', '.nds',
                                                                      'application/vnd.nintendo.snes.rom', '.sfc',
                                                                      'application/vnd.nintendo.snes.rom', '.smc',
                                                                      'application/vnd.nitf', '.nitf',
                                                                      'application/vnd.nitf', '.ntf',
                                                                      'application/vnd.noblenet-directory', '.nnd',
                                                                      'application/vnd.noblenet-sealer', '.nns',
                                                                      'application/vnd.noblenet-web', '.nnw',
                                                                      'application/vnd.nokia.n-gage.data', '.ngdat',
                                                                      'application/vnd.nokia.n-gage.symbian.install', '.n-gage',
                                                                      'application/vnd.nokia.radio-preset', '.rpst',
                                                                      'application/vnd.nokia.radio-presets', '.rpss',
                                                                      'application/vnd.novadigm.edm', '.edm',
                                                                      'application/vnd.novadigm.edx', '.edx',
                                                                      'application/vnd.novadigm.ext', '.ext',
                                                                      'application/vnd.oasis.opendocument.chart', '.odc',
                                                                      'application/vnd.oasis.opendocument.chart-template', '.otc',
                                                                      'application/vnd.oasis.opendocument.database', '.odb',
                                                                      'application/vnd.oasis.opendocument.formula', '.odf',
                                                                      'application/vnd.oasis.opendocument.formula-template', '.odft',
                                                                      'application/vnd.oasis.opendocument.graphics', '.odg',
                                                                      'application/vnd.oasis.opendocument.graphics-template', '.otg',
                                                                      'application/vnd.oasis.opendocument.image', '.odi',
                                                                      'application/vnd.oasis.opendocument.image-template', '.oti',
                                                                      'application/vnd.oasis.opendocument.presentation', '.odp',
                                                                      'application/vnd.oasis.opendocument.presentation-template', '.otp',
                                                                      'application/vnd.oasis.opendocument.spreadsheet', '.ods',
                                                                      'application/vnd.oasis.opendocument.spreadsheet-template', '.ots',
                                                                      'application/vnd.oasis.opendocument.text', '.odt',
                                                                      'application/vnd.oasis.opendocument.text-master', '.odm',
                                                                      'application/vnd.oasis.opendocument.text-template', '.ott',
                                                                      'application/vnd.oasis.opendocument.text-web', '.oth',
                                                                      'application/vnd.olpc-sugar', '.xo',
                                                                      'application/vnd.oma.dd2+xml', '.dd2',
                                                                      'application/vnd.onepager', '.tam',
                                                                      'application/vnd.onepagertamp', '.tamp',
                                                                      'application/vnd.onepagertamx', '.tamx',
                                                                      'application/vnd.onepagertat', '.tat',
                                                                      'application/vnd.onepagertatp', '.tatp',
                                                                      'application/vnd.onepagertatx', '.tatx',
                                                                      'application/vnd.openblox.game+xml', '.obgx',
                                                                      'application/vnd.openblox.game-binary', '.obg',
                                                                      'application/vnd.openeye.oeb', '.oeb',
                                                                      'application/vnd.openofficeorg.extension', '.oxt',
                                                                      'application/vnd.openstreetmap.data+xml', '.osm',
                                                                      'application/vnd.openxmlformats-officedocument.presentationml.presentation', '.pptx',
                                                                      'application/vnd.openxmlformats-officedocument.presentationml.slide', '.sldx',
                                                                      'application/vnd.openxmlformats-officedocument.presentationml.slideshow', '.ppsx',
                                                                      'application/vnd.openxmlformats-officedocument.presentationml.template', '.potx',
                                                                      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', '.xlsx',
                                                                      'application/vnd.openxmlformats-officedocument.spreadsheetml.template', '.xltx',
                                                                      'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '.docx',
                                                                      'application/vnd.openxmlformats-officedocument.wordprocessingml.template', '.dotx',
                                                                      'application/vnd.osgeo.mapguide.package', '.mgp',
                                                                      'application/vnd.osgi.dp', '.dp',
                                                                      'application/vnd.osgi.subsystem', '.esa',
                                                                      'application/vnd.oxli.countgraph', '.oxlicg',
                                                                      'application/vnd.palm', '.oprc',
                                                                      'application/vnd.palm', '.pdb',
                                                                      'application/vnd.palm', '.pqa',
                                                                      'application/vnd.panoply', '.plp',
                                                                      'application/vnd.patentdive', '.dive',
                                                                      'application/vnd.pawaafile', '.paw',
                                                                      'application/vnd.pg.format', '.str',
                                                                      'application/vnd.pg.osasli', '.ei6',
                                                                      'application/vnd.piaccess.application-licence', '.pil',
                                                                      'application/vnd.picsel', '.efif',
                                                                      'application/vnd.pmi.widget', '.wg',
                                                                      'application/vnd.pocketlearn', '.plf',
                                                                      'application/vnd.powerbuilder75', '.pbd',
                                                                      'application/vnd.preminet', '.preminet',
                                                                      'application/vnd.previewsystems.box', '.box',
                                                                      'application/vnd.previewsystems.box', '.vbox',
                                                                      'application/vnd.proteus.magazine', '.mgz',
                                                                      'application/vnd.psfs', '.psfs',
                                                                      'application/vnd.publishare-delta-tree', '.qps',
                                                                      'application/vnd.pvi.ptid1', '.ptid',
                                                                      'application/vnd.qualcomm.brew-app-res', '.bar',
                                                                      'application/vnd.quark.quarkxpress', '.qwd',
                                                                      'application/vnd.quark.quarkxpress', '.qwt',
                                                                      'application/vnd.quark.quarkxpress', '.qxb',
                                                                      'application/vnd.quark.quarkxpress', '.qxd',
                                                                      'application/vnd.quark.quarkxpress', '.qxl',
                                                                      'application/vnd.quark.quarkxpress', '.qxt',
                                                                      'application/vnd.quobject-quoxdocument', '.quiz',
                                                                      'application/vnd.quobject-quoxdocument', '.quox',
                                                                      'application/vnd.rainstor.data', '.tree',
                                                                      'application/vnd.realvnc.bed', '.bed',
                                                                      'application/vnd.recordare.musicxml', '.mxl',
                                                                      'application/vnd.recordare.musicxml+xml', '.musicxml',
                                                                      'application/vnd.rig.cryptonote', '.cryptonote',
                                                                      'application/vnd.rim.cod', '.cod',
                                                                      'application/vnd.rn-realmedia', '.rm',
                                                                      'application/vnd.rn-realmedia-vbr', '.rmvb',
                                                                      'application/vnd.route66.link66+xml', '.link66',
                                                                      'application/vnd.sailingtracker.track', '.st',
                                                                      'application/vnd.sar', '.sar',
                                                                      'application/vnd.scribus', '.sla',
                                                                      'application/vnd.scribus', '.slaz',
                                                                      'application/vnd.sealed.3df', '.s3df',
                                                                      'application/vnd.sealed.csf', '.scsf',
                                                                      'application/vnd.sealed.doc', '.s1w',
                                                                      'application/vnd.sealed.doc', '.sdo',
                                                                      'application/vnd.sealed.doc', '.sdoc',
                                                                      'application/vnd.sealed.eml', '.sem',
                                                                      'application/vnd.sealed.eml', '.seml',
                                                                      'application/vnd.sealed.mht', '.smh',
                                                                      'application/vnd.sealed.mht', '.smht',
                                                                      'application/vnd.sealed.ppt', '.s1p',
                                                                      'application/vnd.sealed.ppt', '.sppt',
                                                                      'application/vnd.sealed.tiff', '.stif',
                                                                      'application/vnd.sealed.xls', '.s1e',
                                                                      'application/vnd.sealed.xls', '.sxl',
                                                                      'application/vnd.sealed.xls', '.sxls',
                                                                      'application/vnd.sealedmedia.softseal.html', '.s1h',
                                                                      'application/vnd.sealedmedia.softseal.html', '.stm',
                                                                      'application/vnd.sealedmedia.softseal.html', '.stml',
                                                                      'application/vnd.sealedmedia.softseal.pdf', '.s1a',
                                                                      'application/vnd.sealedmedia.softseal.pdf', '.spd',
                                                                      'application/vnd.sealedmedia.softseal.pdf', '.spdf',
                                                                      'application/vnd.seemail', '.see',
                                                                      'application/vnd.sema', '.sema',
                                                                      'application/vnd.semd', '.semd',
                                                                      'application/vnd.semf', '.semf',
                                                                      'application/vnd.shade-save-file', '.ssv',
                                                                      'application/vnd.shana.informed.formdata', '.ifm',
                                                                      'application/vnd.shana.informed.formtemplate', '.itp',
                                                                      'application/vnd.shana.informed.interchange', '.iif',
                                                                      'application/vnd.shana.informed.package', '.ipk',
                                                                      'application/vnd.shp', '.shp',
                                                                      'application/vnd.shx', '.shx',
                                                                      'application/vnd.sigrok.session', '.sr',
                                                                      'application/vnd.simtech-mindmapper', '.twd',
                                                                      'application/vnd.simtech-mindmapper', '.twds',
                                                                      'application/vnd.smaf', '.mmf',
                                                                      'application/vnd.smart.notebook', '.notebook',
                                                                      'application/vnd.smart.teacher', '.teacher',
                                                                      'application/vnd.snesdev-page-table', '.pt',
                                                                      'application/vnd.snesdev-page-table', '.ptrom',
                                                                      'application/vnd.software602.filler.form+xml', '.fo',
                                                                      'application/vnd.software602.filler.form-xml-zip', '.zfo',
                                                                      'application/vnd.solent.sdkm+xml', '.sdkd',
                                                                      'application/vnd.solent.sdkm+xml', '.sdkm',
                                                                      'application/vnd.spotfire.dxp', '.dxp',
                                                                      'application/vnd.spotfire.sfs', '.sfs',
                                                                      'application/vnd.sqlite3', '.db',
                                                                      'application/vnd.sqlite3', '.sqlite',
                                                                      'application/vnd.sqlite3', '.sqlite3',
                                                                      'application/vnd.stardivision.calc', '.sdc',
                                                                      'application/vnd.stardivision.draw', '.sda',
                                                                      'application/vnd.stardivision.impress', '.sdd',
                                                                      'application/vnd.stardivision.math', '.smf',
                                                                      'application/vnd.stardivision.writer', '.sdw',
                                                                      'application/vnd.stardivision.writer', '.vor',
                                                                      'application/vnd.stardivision.writer-global', '.sgl',
                                                                      'application/vnd.stepmania.package', '.smzip',
                                                                      'application/vnd.stepmania.stepchart', '.sm',
                                                                      'application/vnd.sun.wadl+xml', '.wadl',
                                                                      'application/vnd.sun.xml.calc', '.sxc',
                                                                      'application/vnd.sun.xml.calc.template', '.stc',
                                                                      'application/vnd.sun.xml.draw', '.sxd',
                                                                      'application/vnd.sun.xml.draw.template', '.std',
                                                                      'application/vnd.sun.xml.impress', '.sxi',
                                                                      'application/vnd.sun.xml.impress.template', '.sti',
                                                                      'application/vnd.sun.xml.math', '.sxm',
                                                                      'application/vnd.sun.xml.writer', '.sxw',
                                                                      'application/vnd.sun.xml.writer.global', '.sxg',
                                                                      'application/vnd.sun.xml.writer.template', '.stw',
                                                                      'application/vnd.sus-calendar', '.sus',
                                                                      'application/vnd.sus-calendar', '.susp',
                                                                      'application/vnd.svd', '.svd',
                                                                      'application/vnd.sycle+xml', '.scl',
                                                                      'application/vnd.symbian.install', '.sis',
                                                                      'application/vnd.symbian.install', '.sisx',
                                                                      'application/vnd.syncml+xml', '.xsm',
                                                                      'application/vnd.syncml.dm+wbxml', '.bdm',
                                                                      'application/vnd.syncml.dm+xml', '.xdm',
                                                                      'application/vnd.syncml.dmddf+xml', '.ddf',
                                                                      'application/vnd.tao.intent-module-archive', '.tao',
                                                                      'application/vnd.tcpdump.pcap', '.cap',
                                                                      'application/vnd.tcpdump.pcap', '.dmp',
                                                                      'application/vnd.tcpdump.pcap', '.pcap',
                                                                      'application/vnd.think-cell.ppttc+json', '.ppttc',
                                                                      'application/vnd.tml', '.vfr',
                                                                      'application/vnd.tml', '.viaframe',
                                                                      'application/vnd.tmobile-livetv', '.tmo',
                                                                      'application/vnd.trid.tpt', '.tpt',
                                                                      'application/vnd.triscape.mxs', '.mxs',
                                                                      'application/vnd.trueapp', '.tra',
                                                                      'application/vnd.ufdl', '.ufd',
                                                                      'application/vnd.ufdl', '.ufdl',
                                                                      'application/vnd.uiq.theme', '.utz',
                                                                      'application/vnd.umajin', '.umj',
                                                                      'application/vnd.unity', '.unityweb',
                                                                      'application/vnd.uoml+xml', '.uo',
                                                                      'application/vnd.uoml+xml', '.uoml',
                                                                      'application/vnd.uri-map', '.urim',
                                                                      'application/vnd.uri-map', '.urimap',
                                                                      'application/vnd.valve.source.material', '.vmt',
                                                                      'application/vnd.vcx', '.vcx',
                                                                      'application/vnd.vd-study', '.model-inter',
                                                                      'application/vnd.vd-study', '.mxi',
                                                                      'application/vnd.vd-study', '.study-inter',
                                                                      'application/vnd.vectorworks', '.vwx',
                                                                      'application/vnd.veryant.thin', '.istc',
                                                                      'application/vnd.veryant.thin', '.isws',
                                                                      'application/vnd.ves.encrypted', '.ves',
                                                                      'application/vnd.visio', '.vsd',
                                                                      'application/vnd.visio', '.vss',
                                                                      'application/vnd.visio', '.vst',
                                                                      'application/vnd.visio', '.vsw',
                                                                      'application/vnd.visio2013', '.vsdx',
                                                                      'application/vnd.visionary', '.vis',
                                                                      'application/vnd.vividence.scriptfile', '.vsc',
                                                                      'application/vnd.vsf', '.vsf',
                                                                      'application/vnd.wap.sic', '.sic',
                                                                      'application/vnd.wap.slc', '.slc',
                                                                      'application/vnd.wap.wbxml', '.wbxml',
                                                                      'application/vnd.wap.wmlc', '.wmlc',
                                                                      'application/vnd.wap.wmlscriptc', '.wmlsc',
                                                                      'application/vnd.webturbo', '.wtb',
                                                                      'application/vnd.wfa.p2p', '.p2p',
                                                                      'application/vnd.wmc', '.wmc',
                                                                      'application/vnd.wolfram.mathematica.package', '.m',
                                                                      'application/vnd.wolfram.player', '.nbp',
                                                                      'application/vnd.wordperfect', '.wpd',
                                                                      'application/vnd.wqd', '.wqd',
                                                                      'application/vnd.wt.stf', '.stf',
                                                                      'application/vnd.wv.csp+wbxml', '.wv',
                                                                      'application/vnd.xara', '.xar',
                                                                      'application/vnd.xfdl', '.xfdl',
                                                                      'application/vnd.xmi+xml', '.xmi',
                                                                      'application/vnd.xmpie.cpkg', '.cpkg',
                                                                      'application/vnd.xmpie.dpkg', '.dpkg',
                                                                      'application/vnd.xmpie.plan', '.plan',
                                                                      'application/vnd.xmpie.ppkg', '.ppkg',
                                                                      'application/vnd.xmpie.xlim', '.xlim',
                                                                      'application/vnd.yamaha.hv-dic', '.hvd',
                                                                      'application/vnd.yamaha.hv-script', '.hvs',
                                                                      'application/vnd.yamaha.hv-voice', '.hvp',
                                                                      'application/vnd.yamaha.openscoreformat', '.osf',
                                                                      'application/vnd.yamaha.openscoreformat.osfpvg+xml', '.osfpvg',
                                                                      'application/vnd.yamaha.smaf-audio', '.saf',
                                                                      'application/vnd.yamaha.smaf-phrase', '.spf',
                                                                      'application/vnd.yaoweme', '.yme',
                                                                      'application/vnd.yellowriver-custom-menu', '.cmp',
                                                                      'application/vnd.zul', '.zir',
                                                                      'application/vnd.zul', '.zirz',
                                                                      'application/vnd.zzazz.deck+xml', '.zaz',
                                                                      'application/voicexml+xml', '.vxml',
                                                                      'application/voucher-cms+json', '.vcj',
                                                                      'application/wasm', '.wasm',
                                                                      'application/watcherinfo+xml', '.wif',
                                                                      'application/widget', '.wgt',
                                                                      'application/winhlp', '.hlp',
                                                                      'application/wsdl+xml', '.wsdl',
                                                                      'application/wspolicy+xml', '.wspolicy',
                                                                      'application/x-7z-compressed', '.7z',
                                                                      'application/x-abiword', '.abw',
                                                                      'application/x-ace-compressed', '.ace',
                                                                      'application/x-apple-diskimage', '.dmg',
                                                                      'application/x-authorware-bin', '.aab',
                                                                      'application/x-authorware-bin', '.u32',
                                                                      'application/x-authorware-bin', '.vox',
                                                                      'application/x-authorware-bin', '.x32',
                                                                      'application/x-authorware-map', '.aam',
                                                                      'application/x-authorware-seg', '.aas',
                                                                      'application/x-bb-appworld', '.bbaw',
                                                                      'application/x-bcpio', '.bcpio',
                                                                      'application/x-bittorrent', '.torrent',
                                                                      'application/x-blorb', '.blb',
                                                                      'application/x-blorb', '.blorb',
                                                                      'application/x-bzip', '.bz',
                                                                      'application/x-bzip2', '.boz',
                                                                      'application/x-bzip2', '.bz2',
                                                                      'application/x-cbr', '.cb7',
                                                                      'application/x-cbr', '.cba',
                                                                      'application/x-cbr', '.cbr',
                                                                      'application/x-cbr', '.cbt',
                                                                      'application/x-cbr', '.cbz',
                                                                      'application/x-cdlink', '.vcd',
                                                                      'application/x-cfs-compressed', '.cfs',
                                                                      'application/x-chat', '.chat',
                                                                      'application/x-chess-pgn', '.pgn',
                                                                      'application/x-chrome-extension', '.crx',
                                                                      'application/x-conference', '.nsc',
                                                                      'application/x-cpio', '.cpio',
                                                                      'application/x-csh', '.csh',
                                                                      'application/x-debian-package', '.deb',
                                                                      'application/x-debian-package', '.udeb',
                                                                      'application/x-dgc-compressed', '.dgc',
                                                                      'application/x-director', '.cct',
                                                                      'application/x-director', '.cst',
                                                                      'application/x-director', '.cxt',
                                                                      'application/x-director', '.dcr',
                                                                      'application/x-director', '.dir',
                                                                      'application/x-director', '.dxr',
                                                                      'application/x-director', '.fgd',
                                                                      'application/x-director', '.swa',
                                                                      'application/x-director', '.w3d',
                                                                      'application/x-doom', '.wad',
                                                                      'application/x-dtbncx+xml', '.ncx',
                                                                      'application/x-dtbook+xml', '.dtb',
                                                                      'application/x-dtbresource+xml', '.res',
                                                                      'application/x-dvi', '.dvi',
                                                                      'application/x-envoy', '.evy',
                                                                      'application/x-eva', '.eva',
                                                                      'application/x-font-bdf', '.bdf',
                                                                      'application/x-font-ghostscript', '.gsf',
                                                                      'application/x-font-linux-psf', '.psf',
                                                                      'application/x-font-pcf', '.pcf',
                                                                      'application/x-font-snf', '.snf',
                                                                      'application/x-font-type1', '.afm',
                                                                      'application/x-font-type1', '.pfa',
                                                                      'application/x-font-type1', '.pfb',
                                                                      'application/x-font-type1', '.pfm',
                                                                      'application/x-freearc', '.arc',
                                                                      'application/x-futuresplash', '.spl',
                                                                      'application/x-gca-compressed', '.gca',
                                                                      'application/x-glulx', '.ulx',
                                                                      'application/x-gnumeric', '.gnumeric',
                                                                      'application/x-gramps-xml', '.gramps',
                                                                      'application/x-gtar', '.gtar',
                                                                      'application/x-hdf', '.hdf',
                                                                      'application/x-httpd-php', '.php',
                                                                      'application/x-install-instructions', '.install',
                                                                      'application/x-iso9660-image', '.iso',
                                                                      'application/x-java-jnlp-file', '.jnlp',
                                                                      'application/x-latex', '.latex',
                                                                      'application/x-lzh-compressed', '.lha',
                                                                      'application/x-lzh-compressed', '.lzh',
                                                                      'application/x-mie', '.mie',
                                                                      'application/x-mobipocket-ebook', '.mobi',
                                                                      'application/x-mobipocket-ebook', '.prc',
                                                                      'application/x-ms-application', '.application',
                                                                      'application/x-ms-shortcut', '.lnk',
                                                                      'application/x-ms-wmd', '.wmd',
                                                                      'application/x-ms-wmz', '.wmz',
                                                                      'application/x-ms-xbap', '.xbap',
                                                                      'application/x-msaccess', '.mdb',
                                                                      'application/x-msbinder', '.obd',
                                                                      'application/x-mscardfile', '.crd',
                                                                      'application/x-msclip', '.clp',
                                                                      'application/x-msdownload', '.bat',
                                                                      'application/x-msdownload', '.com',
                                                                      'application/x-msdownload', '.msi',
                                                                      'application/x-msmediaview', '.m13',
                                                                      'application/x-msmediaview', '.m14',
                                                                      'application/x-msmediaview', '.mvb',
                                                                      'application/x-msmetafile', '.emf',
                                                                      'application/x-msmetafile', '.emz',
                                                                      'application/x-msmetafile', '.wmf',
                                                                      'application/x-msmoney', '.mny',
                                                                      'application/x-mspublisher', '.pub',
                                                                      'application/x-msschedule', '.scd',
                                                                      'application/x-msterminal', '.trm',
                                                                      'application/x-mswrite', '.wri',
                                                                      'application/x-netcdf', '.cdf',
                                                                      'application/x-netcdf', '.nc',
                                                                      'application/x-nzb', '.nzb',
                                                                      'application/x-opera-extension', '.oex',
                                                                      'application/x-pkcs7-certificates', '.p7b',
                                                                      'application/x-pkcs7-certificates', '.spc',
                                                                      'application/x-pkcs7-certreqresp', '.p7r',
                                                                      'application/x-rar-compressed', '.rar',
                                                                      'application/x-research-info-systems', '.ris',
                                                                      'application/x-sh', '.sh',
                                                                      'application/x-shar', '.shar',
                                                                      'application/x-shockwave-flash', '.swf',
                                                                      'application/x-silverlight-app', '.xap',
                                                                      'application/x-stuffit', '.sit',
                                                                      'application/x-stuffitx', '.sitx',
                                                                      'application/x-subrip', '.srt',
                                                                      'application/x-sv4cpio', '.sv4cpio',
                                                                      'application/x-sv4crc', '.sv4crc',
                                                                      'application/x-t3vm-image', '.t3',
                                                                      'application/x-tads', '.gam',
                                                                      'application/x-tar', '.tar',
                                                                      'application/x-tcl', '.tcl',
                                                                      'application/x-tex', '.tex',
                                                                      'application/x-tex-tfm', '.tfm',
                                                                      'application/x-texinfo', '.texi',
                                                                      'application/x-texinfo', '.texinfo',
                                                                      'application/x-ustar', '.ustar',
                                                                      'application/x-wais-source', '.src',
                                                                      'application/x-web-app-manifest+json', '.webapp',
                                                                      'application/x-x509-ca-cert', '.crt',
                                                                      'application/x-x509-ca-cert', '.der',
                                                                      'application/x-xfig', '.fig',
                                                                      'application/x-xpinstall', '.xpi',
                                                                      'application/x-xz', '.xz',
                                                                      'application/x-zmachine', '.z1',
                                                                      'application/x-zmachine', '.z2',
                                                                      'application/x-zmachine', '.z3',
                                                                      'application/x-zmachine', '.z4',
                                                                      'application/x-zmachine', '.z5',
                                                                      'application/x-zmachine', '.z6',
                                                                      'application/x-zmachine', '.z7',
                                                                      'application/x-zmachine', '.z8',
                                                                      'application/xaml+xml', '.xaml',
                                                                      'application/xcap-att+xml', '.xav',
                                                                      'application/xcap-caps+xml', '.xca',
                                                                      'application/xcap-diff+xml', '.xdf',
                                                                      'application/xcap-el+xml', '.xel',
                                                                      'application/xcap-ns+xml', '.xns',
                                                                      'application/xenc+xml', '.xenc',
                                                                      'application/xhtml+xml', '.xht',
                                                                      'application/xhtml+xml', '.xhtm',
                                                                      'application/xhtml+xml', '.xhtml',
                                                                      'application/xliff+xml', '.xlf',
                                                                      'application/xml', '.xml',
                                                                      'application/xml-dtd', '.dtd',
                                                                      'application/xml-dtd', '.mod',
                                                                      'application/xop+xml', '.xop',
                                                                      'application/xproc+xml', '.xpl',
                                                                      'application/xslt+xml', '.xsl',
                                                                      'application/xslt+xml', '.xslt',
                                                                      'application/xspf+xml', '.xspf',
                                                                      'application/xv+xml', '.mxml',
                                                                      'application/xv+xml', '.xhvml',
                                                                      'application/xv+xml', '.xvm',
                                                                      'application/xv+xml', '.xvml',
                                                                      'application/yang', '.yang',
                                                                      'application/yin+xml', '.yin',
                                                                      'application/zip', '.zip',
                                                                      'application/zstd', '.zst',
                                                                      'audio/32kadpcm', '.726',
                                                                      'audio/aac', '.aac',
                                                                      'audio/aac', '.adts',
                                                                      'audio/aac', '.ass',
                                                                      'audio/adpcm', '.adp',
                                                                      'audio/amr', '.amr',
                                                                      'audio/amr-wb', '.awb',
                                                                      'audio/asc', '.acn',
                                                                      'audio/atrac-advanced-lossless', '.aal',
                                                                      'audio/atrac-x', '.atx',
                                                                      'audio/atrac-x', '.omg',
                                                                      'audio/atrac3', '.aa3',
                                                                      'audio/basic', '.au',
                                                                      'audio/basic', '.snd',
                                                                      'audio/dls', '.dls',
                                                                      'audio/evrc', '.evc',
                                                                      'audio/evrc-qcp', '.qcp',
                                                                      'audio/evrcb', '.evb',
                                                                      'audio/evrcnw', '.enw',
                                                                      'audio/evrcwb', '.evw',
                                                                      'audio/ilbc', '.lbc',
                                                                      'audio/l16', '.l16',
                                                                      'audio/mhas', '.mhas',
                                                                      'audio/midi', '.kar',
                                                                      'audio/midi', '.mid',
                                                                      'audio/midi', '.midi',
                                                                      'audio/midi', '.rmi',
                                                                      'audio/mobile-xmf', '.mxmf',
                                                                      'audio/mp4', '.f4a',
                                                                      'audio/mp4', '.f4b',
                                                                      'audio/mp4', '.m4a',
                                                                      'audio/mp4', '.mp4a',
                                                                      'audio/mpeg', '.m2a',
                                                                      'audio/mpeg', '.m3a',
                                                                      'audio/mpeg', '.mp1',
                                                                      'audio/mpeg', '.mp2',
                                                                      'audio/mpeg', '.mp2a',
                                                                      'audio/mpeg', '.mp3',
                                                                      'audio/mpeg', '.mpga',
                                                                      'audio/ogg', '.oga',
                                                                      'audio/ogg', '.ogg',
                                                                      'audio/ogg', '.spx',
                                                                      'audio/opus', '.opus',
                                                                      'audio/prs.sid', '.psid',
                                                                      'audio/red', '.red',
                                                                      'audio/s3m', '.s3m',
                                                                      'audio/silk', '.sil',
                                                                      'audio/smv', '.smv',
                                                                      'audio/sofa', '.sofa',
                                                                      'audio/usac', '.loas',
                                                                      'audio/usac', '.xhe',
                                                                      'audio/vnd.audiokoz', '.koz',
                                                                      'audio/vnd.dece.audio', '.uva',
                                                                      'audio/vnd.dece.audio', '.uvva',
                                                                      'audio/vnd.digital-winds', '.eol',
                                                                      'audio/vnd.dolby.mlp', '.mlp',
                                                                      'audio/vnd.dra', '.dra',
                                                                      'audio/vnd.dts', '.dts',
                                                                      'audio/vnd.dts.hd', '.dtshd',
                                                                      'audio/vnd.everad.plj', '.plj',
                                                                      'audio/vnd.lucent.voice', '.lvp',
                                                                      'audio/vnd.ms-playready.media.pya', '.pya',
                                                                      'audio/vnd.nortel.vbk', '.vbk',
                                                                      'audio/vnd.nuera.ecelp4800', '.ecelp4800',
                                                                      'audio/vnd.nuera.ecelp7470', '.ecelp7470',
                                                                      'audio/vnd.nuera.ecelp9600', '.ecelp9600',
                                                                      'audio/vnd.presonus.multitrack', '.multitrack',
                                                                      'audio/vnd.rip', '.rip',
                                                                      'audio/vnd.sealedmedia.softseal.mpeg', '.s1m',
                                                                      'audio/vnd.sealedmedia.softseal.mpeg', '.smp',
                                                                      'audio/vnd.sealedmedia.softseal.mpeg', '.smp3',
                                                                      'audio/wav', '.wav',
                                                                      'audio/webm', '.weba',
                                                                      'audio/x-aiff', '.aif',
                                                                      'audio/x-aiff', '.aifc',
                                                                      'audio/x-aiff', '.aiff',
                                                                      'audio/x-caf', '.caf',
                                                                      'audio/x-flac', '.flac',
                                                                      'audio/x-matroska', '.mka',
                                                                      'audio/x-mpegurl', '.m3u',
                                                                      'audio/x-ms-wax', '.wax',
                                                                      'audio/x-ms-wma', '.wma',
                                                                      'audio/x-pn-realaudio', '.ra',
                                                                      'audio/x-pn-realaudio', '.ram',
                                                                      'audio/x-pn-realaudio-plugin', '.rmp',
                                                                      'audio/xm', '.xm',
                                                                      'chemical/x-cdx', '.cdx',
                                                                      'chemical/x-cif', '.cif',
                                                                      'chemical/x-cmdf', '.cmdf',
                                                                      'chemical/x-cml', '.cml',
                                                                      'chemical/x-csml', '.csml',
                                                                      'chemical/x-xyz', '.xyz',
                                                                      'font/collection', '.ttc',
                                                                      'font/otf', '.otf',
                                                                      'font/sfnt', '.sfnt',
                                                                      'font/ttf', '.ttf',
                                                                      'font/woff', '.woff',
                                                                      'font/woff2', '.woff2',
                                                                      'image/aces', '.exr',
                                                                      'image/apng', '.apng',
                                                                      'image/avci', '.avci',
                                                                      'image/avcs', '.avcs',
                                                                      'image/bmp', '.bmp',
                                                                      'image/bmp', '.dib',
                                                                      'image/cgm', '.cgm',
                                                                      'image/dicom-rle', '.drle',
                                                                      'image/fits', '.fits',
                                                                      'image/g3fax', '.g3',
                                                                      'image/gif', '.gif',
                                                                      'image/heic', '.heic',
                                                                      'image/heic-sequence', '.heics',
                                                                      'image/heif', '.heif',
                                                                      'image/heif', '.hif',
                                                                      'image/heif-sequence', '.heifs',
                                                                      'image/hej2k', '.hej2',
                                                                      'image/hsj2', '.hsj2',
                                                                      'image/ief', '.ief',
                                                                      'image/jls', '.jls',
                                                                      'image/jp2', '.jp2',
                                                                      'image/jp2', '.jpg2',
                                                                      'image/jpeg', '.jpe',
                                                                      'image/jpeg', '.jpeg',
                                                                      'image/jpeg', '.jpg',
                                                                      'image/jph', '.jph',
                                                                      'image/jphc', '.jhc',
                                                                      'image/jpx', '.jpf',
                                                                      'image/jpx', '.jpx',
                                                                      'image/jxr', '.jxr',
                                                                      'image/jxra', '.jxra',
                                                                      'image/jxrs', '.jxrs',
                                                                      'image/jxs', '.jxs',
                                                                      'image/jxsc', '.jxsc',
                                                                      'image/jxsi', '.jxsi',
                                                                      'image/jxss', '.jxss',
                                                                      'image/ktx', '.ktx',
                                                                      'image/ktx2', '.ktx2',
                                                                      'image/pjpeg', '.pjpeg',
                                                                      'image/png', '.png',
                                                                      'image/prs.btif', '.btf',
                                                                      'image/prs.btif', '.btif',
                                                                      'image/prs.pti', '.pti',
                                                                      'image/sgi', '.sgi',
                                                                      'image/svg+xml', '.svg',
                                                                      'image/svg+xml', '.svgz',
                                                                      'image/t38', '.t38',
                                                                      'image/tiff', '.tif',
                                                                      'image/tiff', '.tiff',
                                                                      'image/tiff-fx', '.tfx',
                                                                      'image/vnd.adobe.photoshop', '.psd',
                                                                      'image/vnd.airzip.accelerator.azv', '.azv',
                                                                      'image/vnd.dece.graphic', '.uvg',
                                                                      'image/vnd.dece.graphic', '.uvi',
                                                                      'image/vnd.dece.graphic', '.uvvg',
                                                                      'image/vnd.dece.graphic', '.uvvi',
                                                                      'image/vnd.djvu', '.djv',
                                                                      'image/vnd.djvu', '.djvu',
                                                                      'image/vnd.dwg', '.dwg',
                                                                      'image/vnd.dxf', '.dxf',
                                                                      'image/vnd.fastbidsheet', '.fbs',
                                                                      'image/vnd.fpx', '.fpx',
                                                                      'image/vnd.fst', '.fst',
                                                                      'image/vnd.fujixerox.edmics-mmr', '.mmr',
                                                                      'image/vnd.fujixerox.edmics-rlc', '.rlc',
                                                                      'image/vnd.globalgraphics.pgb', '.pgb',
                                                                      'image/vnd.ms-modi', '.mdi',
                                                                      'image/vnd.ms-photo', '.wdp',
                                                                      'image/vnd.net-fpx', '.npx',
                                                                      'image/vnd.pco.b16', '.b16',
                                                                      'image/vnd.radiance', '.hdr',
                                                                      'image/vnd.radiance', '.rgbe',
                                                                      'image/vnd.radiance', '.xyze',
                                                                      'image/vnd.sealed.png', '.s1n',
                                                                      'image/vnd.sealed.png', '.spn',
                                                                      'image/vnd.sealed.png', '.spng',
                                                                      'image/vnd.sealedmedia.softseal.gif', '.s1g',
                                                                      'image/vnd.sealedmedia.softseal.gif', '.sgif',
                                                                      'image/vnd.sealedmedia.softseal.jpg', '.s1j',
                                                                      'image/vnd.sealedmedia.softseal.jpg', '.sjp',
                                                                      'image/vnd.sealedmedia.softseal.jpg', '.sjpg',
                                                                      'image/vnd.tencent.tap', '.tap',
                                                                      'image/vnd.valve.source.texture', '.vtf',
                                                                      'image/vnd.wap.wbmp', '.wbmp',
                                                                      'image/vnd.xiff', '.xif',
                                                                      'image/webp', '.webp',
                                                                      'image/x-3ds', '.3ds',
                                                                      'image/x-cmu-raster', '.ras',
                                                                      'image/x-cmx', '.cmx',
                                                                      'image/x-freehand', '.fh',
                                                                      'image/x-freehand', '.fh4',
                                                                      'image/x-freehand', '.fh5',
                                                                      'image/x-freehand', '.fh7',
                                                                      'image/x-freehand', '.fhc',
                                                                      'image/x-icon', '.cur',
                                                                      'image/x-icon', '.ico',
                                                                      'image/x-mrsid-image', '.sid',
                                                                      'image/x-pcx', '.pcx',
                                                                      'image/x-pict', '.pct',
                                                                      'image/x-pict', '.pic',
                                                                      'image/x-portable-anymap', '.pnm',
                                                                      'image/x-portable-bitmap', '.pbm',
                                                                      'image/x-portable-graymap', '.pgm',
                                                                      'image/x-portable-pixmap', '.ppm',
                                                                      'image/x-rgb', '.rgb',
                                                                      'image/x-tga', '.tga',
                                                                      'image/x-xbitmap', '.xbm',
                                                                      'image/x-xpixmap', '.xpm',
                                                                      'image/x-xwindowdump', '.xwd',
                                                                      'message/disposition-notification', '.disposition-notification',
                                                                      'message/global', '.u8msg',
                                                                      'message/global-delivery-status', '.u8dsn',
                                                                      'message/global-disposition-notification', '.u8mdn',
                                                                      'message/global-headers', '.u8hdr',
                                                                      'message/imdn+xml', '.cl',
                                                                      'message/rfc822', '.eml',
                                                                      'message/rfc822', '.mime',
                                                                      'message/vnd.wfa.wsc', '.wsc',
                                                                      'model/3mf', '.3mf',
                                                                      'model/gltf+json', '.gltf',
                                                                      'model/gltf-binary', '.glb',
                                                                      'model/iges', '.iges',
                                                                      'model/iges', '.igs',
                                                                      'model/mesh', '.mesh',
                                                                      'model/mesh', '.msh',
                                                                      'model/mesh', '.silo',
                                                                      'model/mtl', '.mtl',
                                                                      'model/obj', '.obj',
                                                                      'model/stl', '.stl',
                                                                      'model/vnd.collada+xml', '.dae',
                                                                      'model/vnd.dwf', '.dwf',
                                                                      'model/vnd.gdl', '.dor',
                                                                      'model/vnd.gdl', '.gdl',
                                                                      'model/vnd.gdl', '.gsm',
                                                                      'model/vnd.gdl', '.ism',
                                                                      'model/vnd.gdl', '.lmp',
                                                                      'model/vnd.gdl', '.msm',
                                                                      'model/vnd.gdl', '.rsm',
                                                                      'model/vnd.gdl', '.win',
                                                                      'model/vnd.gtw', '.gtw',
                                                                      'model/vnd.moml+xml', '.moml',
                                                                      'model/vnd.mts', '.mts',
                                                                      'model/vnd.opengex', '.ogex',
                                                                      'model/vnd.parasolid.transmit.binary', '.x_b',
                                                                      'model/vnd.parasolid.transmit.text', '.x_t',
                                                                      'model/vnd.usdz+zip', '.usdz',
                                                                      'model/vnd.valve.source.compiled-map', '.bsp',
                                                                      'model/vnd.vtu', '.vtu',
                                                                      'model/vrml', '.vrml',
                                                                      'model/vrml', '.wrl',
                                                                      'model/x3d+binary', '.x3db',
                                                                      'model/x3d+binary', '.x3dbz',
                                                                      'model/x3d+vrml', '.x3dv',
                                                                      'model/x3d+vrml', '.x3dvz',
                                                                      'model/x3d+xml', '.x3d',
                                                                      'model/x3d+xml', '.x3dz',
                                                                      'multipart/vnd.bint.med-plus', '.bmed',
                                                                      'multipart/voice-message', '.vpm',
                                                                      'text/cache-manifest', '.appcache',
                                                                      'text/cache-manifest', '.manifest',
                                                                      'text/calendar', '.ics',
                                                                      'text/calendar', '.ifb',
                                                                      'text/css', '.css',
                                                                      'text/csv', '.csv',
                                                                      'text/csv-schema', '.csvs',
                                                                      'text/dns', '.soa',
                                                                      'text/dns', '.zone',
                                                                      'text/ecmascript', '.es',
                                                                      'text/gff3', '.gff3',
                                                                      'text/html', '.htm',
                                                                      'text/html', '.html',
                                                                      'text/javascript', '.js',
                                                                      'text/javascript', '.mjs',
                                                                      'text/jcr-cnd', '.cnd',
                                                                      'text/markdown', '.markdown',
                                                                      'text/markdown', '.md',
                                                                      'text/mizar', '.miz',
                                                                      'text/n3', '.n3',
                                                                      'text/plain', '.conf',
                                                                      'text/plain', '.def',
                                                                      'text/plain', '.in',
                                                                      'text/plain', '.list',
                                                                      'text/plain', '.log',
                                                                      'text/plain', '.text',
                                                                      'text/plain', '.txt',
                                                                      'text/plain-bas', '.par',
                                                                      'text/provenance-notation', '.provn',
                                                                      'text/prs.fallenstein.rst', '.rst',
                                                                      'text/prs.lines.tag', '.dsc',
                                                                      'text/prs.lines.tag', '.tag',
                                                                      'text/richtext', '.rtx',
                                                                      'text/sgml', '.sgm',
                                                                      'text/sgml', '.sgml',
                                                                      'text/shaclc', '.shaclc',
                                                                      'text/shaclc', '.shc',
                                                                      'text/spdx', '.spdx',
                                                                      'text/tab-separated-values', '.tsv',
                                                                      'text/troff', '.man',
                                                                      'text/troff', '.me',
                                                                      'text/troff', '.ms',
                                                                      'text/troff', '.roff',
                                                                      'text/troff', '.t',
                                                                      'text/troff', '.tr',
                                                                      'text/turtle', '.ttl',
                                                                      'text/uri-list', '.uri',
                                                                      'text/uri-list', '.uris',
                                                                      'text/uri-list', '.urls',
                                                                      'text/vcard', '.vcard',
                                                                      'text/vcard', '.vcf',
                                                                      'text/vnd.a', '.a',
                                                                      'text/vnd.abc', '.abc',
                                                                      'text/vnd.ascii-art', '.ascii',
                                                                      'text/vnd.curl', '.curl',
                                                                      'text/vnd.curl.dcurl', '.dcurl',
                                                                      'text/vnd.curl.mcurl', '.mcurl',
                                                                      'text/vnd.curl.scurl', '.scurl',
                                                                      'text/vnd.dmclientscript', '.dms',
                                                                      'text/vnd.dvb.subtitle', '.sub',
                                                                      'text/vnd.esmertec.theme-descriptor', '.jtd',
                                                                      'text/vnd.ficlab.flt', '.flt',
                                                                      'text/vnd.fly', '.fly',
                                                                      'text/vnd.fmi.flexstor', '.flx',
                                                                      'text/vnd.graphviz', '.gv',
                                                                      'text/vnd.hans', '.hans',
                                                                      'text/vnd.hgl', '.hgl',
                                                                      'text/vnd.in3d.3dml', '.3dm',
                                                                      'text/vnd.in3d.3dml', '.3dml',
                                                                      'text/vnd.in3d.spot', '.spo',
                                                                      'text/vnd.in3d.spot', '.spot',
                                                                      'text/vnd.ms-mediapackage', '.mpf',
                                                                      'text/vnd.net2phone.commcenter.command', '.ccc',
                                                                      'text/vnd.rim.location.xloc', '.xloc',
                                                                      'text/vnd.senx.warpscript', '.mc2',
                                                                      'text/vnd.si.uricatalogue', '.uric',
                                                                      'text/vnd.sosi', '.sos',
                                                                      'text/vnd.sun.j2me.app-descriptor', '.jad',
                                                                      'text/vnd.wap.si', '.si',
                                                                      'text/vnd.wap.sl', '.sl',
                                                                      'text/vnd.wap.wml', '.wml',
                                                                      'text/vnd.wap.wmlscript', '.wmls',
                                                                      'text/vtt', '.vtt',
                                                                      'text/x-asm', '.asm',
                                                                      'text/x-asm', '.s',
                                                                      'text/x-c', '.c',
                                                                      'text/x-c', '.cc',
                                                                      'text/x-c', '.cpp',
                                                                      'text/x-c', '.cxx',
                                                                      'text/x-c', '.dic',
                                                                      'text/x-c', '.h',
                                                                      'text/x-c', '.hh',
                                                                      'text/x-component', '.htc',
                                                                      'text/x-fortran', '.f',
                                                                      'text/x-fortran', '.f77',
                                                                      'text/x-fortran', '.f90',
                                                                      'text/x-fortran', '.for',
                                                                      'text/x-java-source', '.java',
                                                                      'text/x-nfo', '.nfo',
                                                                      'text/x-opml', '.opml',
                                                                      'text/x-pascal', '.p',
                                                                      'text/x-pascal', '.pas',
                                                                      'text/x-setext', '.etx',
                                                                      'text/x-sfv', '.sfv',
                                                                      'text/x-uuencode', '.uu',
                                                                      'text/x-vcalendar', '.vcs',
                                                                      'text/xml-external-parsed-entity', '.ent',
                                                                      'text/yaml', '.yaml',
                                                                      'video/3gpp', '.3gp',
                                                                      'video/3gpp', '.3gpp',
                                                                      'video/3gpp2', '.3g2',
                                                                      'video/3gpp2', '.3gpp2',
                                                                      'video/h261', '.h261',
                                                                      'video/h263', '.h263',
                                                                      'video/h264', '.h264',
                                                                      'video/iso.segment', '.m4s',
                                                                      'video/jpeg', '.jpgv',
                                                                      'video/jpm', '.jpgm',
                                                                      'video/jpm', '.jpm',
                                                                      'video/mj2', '.mj2',
                                                                      'video/mj2', '.mjp2',
                                                                      'video/mp2t', '.ts',
                                                                      'video/mp4', '.f4p',
                                                                      'video/mp4', '.f4v',
                                                                      'video/mp4', '.m4v',
                                                                      'video/mp4', '.mp4',
                                                                      'video/mp4', '.mp4v',
                                                                      'video/mp4', '.mpg4',
                                                                      'video/mpeg', '.m1v',
                                                                      'video/mpeg', '.m2v',
                                                                      'video/mpeg', '.mpe',
                                                                      'video/mpeg', '.mpeg',
                                                                      'video/mpeg', '.mpg',
                                                                      'video/ogg', '.ogv',
                                                                      'video/quicktime', '.mov',
                                                                      'video/quicktime', '.qt',
                                                                      'video/vnd.dece.hd', '.uvh',
                                                                      'video/vnd.dece.hd', '.uvvh',
                                                                      'video/vnd.dece.mobile', '.uvm',
                                                                      'video/vnd.dece.mobile', '.uvvm',
                                                                      'video/vnd.dece.pd', '.uvp',
                                                                      'video/vnd.dece.pd', '.uvvp',
                                                                      'video/vnd.dece.sd', '.uvs',
                                                                      'video/vnd.dece.sd', '.uvvs',
                                                                      'video/vnd.dece.video', '.uvv',
                                                                      'video/vnd.dece.video', '.uvvv',
                                                                      'video/vnd.dvb.file', '.dvb',
                                                                      'video/vnd.fvt', '.fvt',
                                                                      'video/vnd.mpegurl', '.m4u',
                                                                      'video/vnd.mpegurl', '.mxu',
                                                                      'video/vnd.ms-playready.media.pyv', '.pyv',
                                                                      'video/vnd.nokia.interleaved-multimedia', '.nim',
                                                                      'video/vnd.radgamettools.bink', '.bik',
                                                                      'video/vnd.radgamettools.bink', '.bk2',
                                                                      'video/vnd.radgamettools.smacker', '.smk',
                                                                      'video/vnd.sealed.mpeg1', '.s11',
                                                                      'video/vnd.sealed.mpeg4', '.s14',
                                                                      'video/vnd.sealed.mpeg4', '.smpg',
                                                                      'video/vnd.sealed.swf', '.ssw',
                                                                      'video/vnd.sealed.swf', '.sswf',
                                                                      'video/vnd.sealedmedia.softseal.mov', '.s1q',
                                                                      'video/vnd.sealedmedia.softseal.mov', '.smo',
                                                                      'video/vnd.sealedmedia.softseal.mov', '.smov',
                                                                      'video/vnd.uvvu.mp4', '.uvu',
                                                                      'video/vnd.uvvu.mp4', '.uvvu',
                                                                      'video/vnd.vivo', '.viv',
                                                                      'video/vnd.youtube.yt', '.yt',
                                                                      'video/webm', '.webm',
                                                                      'video/x-fli', '.fli',
                                                                      'video/x-flv', '.flv',
                                                                      'video/x-matroska', '.mk3d',
                                                                      'video/x-matroska', '.mks',
                                                                      'video/x-matroska', '.mkv',
                                                                      'video/x-mng', '.mng',
                                                                      'video/x-ms-asf', '.asf',
                                                                      'video/x-ms-asf', '.asx',
                                                                      'video/x-ms-vob', '.vob',
                                                                      'video/x-ms-wm', '.wm',
                                                                      'video/x-ms-wmv', '.wmv',
                                                                      'video/x-ms-wmx', '.wmx',
                                                                      'video/x-ms-wvx', '.wvx',
                                                                      'video/x-msvideo', '.avi',
                                                                      'video/x-sgi-movie', '.movie',
                                                                      'x-conference/x-cooltalk', '.ice');

Implementation

Uses
 {$IFDEF MSWINDOWS}
  Windows,
 {$ENDIF}
 {$IFDEF KYLIX3}
  Libc,
 {$ELSE KYLIX3}
  {$IFDEF LINUX}
    BaseUnix,
  {$ENDIF LINUX}
 {$ENDIF KYLIX3}
 Classes;

Function GetFileInfo(Const FileName : TFileName;
                     Modified       : PDateTime;
                     Size           : PInt64): Boolean;
{$IFDEF MSWINDOWS}
Var
 FA         : TWin32FileAttributeData;
 SystemTime : TSystemTime;
Begin
 Result := GetFileAttributesEx(Pointer(FileName), GetFileExInfoStandard, @FA);
 If Not Result Then Exit;
 If Modified <> Nil Then
  Begin
   Result := FileTimeToSystemTime(FA.ftLastWriteTime, SystemTime);
   If Not Result Then Exit;
   Modified^ := SystemTimeToDateTime(SystemTime);
  End;
 If Size <> Nil Then
  Begin
   PInt64Rec(Size)^.Lo := FA.nFileSizeLow;
   PInt64Rec(Size)^.Hi := FA.nFileSizeHigh;
  End;
End;
{$ENDIF}
{$IFDEF FPCLINUX}
Var
 fd : cint;
 sb : Stat;
Begin
 fd := FpOpen(PChar(FileName), O_RdOnly);
 Result := fd > 0;
 If Not Result Then Exit;
 Try
  Result := FpFStat(fd, sb) = 0;
  If Not Result Then Exit;
  If Modified <> Nil Then
   Modified^ := UnixMSTimeToDateTime(TUnixMSTime(sb.st_mtime) * MSecsPerSec);
  If Size <> Nil Then
   Size^ := sb.st_size;
 Finally
  If FpClose(fd) <> 0 Then
   Result := False;
 End;
End;
{$ENDIF}
{$IFDEF KYLIX3}
Var
 Handle   : Integer;
 StatBuf  : TStatBuf;
 Current,
 LSize    : Int64;
Begin
 Handle := Libc.open(PChar(FileName), O_RDONLY);
 Result := PtrInt(Handle) > 0;
 If Not Result Then Exit;
 Try
  If Modified <> Nil Then
   Begin
    Result := Libc.fstat(Handle, StatBuf) = 0;
    If Not Result Then Exit;
    Modified^ := UnixMSTimeToDateTime(TUnixMSTime(StatBuf.st_mtime) * MSecsPerSec);
   End;
  If Size <> Nil Then
   Begin
    Current := Libc.lseek64(Handle, 0, SEEK_CUR);
    Result := Current <> -1;
    If Not Result Then Exit;
    LSize := Libc.lseek64(Handle, 0, SEEK_END);
    Result := LSize <> -1;
    If Not Result Then Exit;
    Result := lseek64(Handle, Current, SEEK_SET) <> -1;
    If Not Result Then Exit;
    Size^ := LSize;
   End;
 Finally
  If Libc.__close(Handle) <> 0 Then
   Result := False;
 End;
End;
{$ENDIF}

Function SetFileTime(Const FileName : TFileName;
                     Const Modified : TDateTime) : Boolean;
{$IFDEF MSWINDOWS}
Var
 Handle     : THandle;
 SystemTime : TSystemTime;
 LModified  : TFileTime;
Begin
 DateTimeToSystemTime(Modified, SystemTime);
 Result := SystemTimeToFileTime(SystemTime, LModified);
 If Not Result Then Exit;
 Handle := FileOpen(FileName, fmOpenWrite or fmShareDenyNone);
 If Handle = THandle(-1) Then
  Begin
   Result := False;
   Exit;
  End;
 Result := Windows.SetFileTime(Handle, @LModified, @LModified, @LModified);
 FileClose(Handle);
End;
{$ENDIF}
{$IFDEF FPCLINUX}
Var
 times : UTimBuf;
Begin
 times.actime := DateTimeToUnixTime(Modified);
 times.modtime := times.actime;
 Result := FpUtime(PChar(FileName), @times) = 0;
End;
{$ENDIF}
{$IFDEF KYLIX3}
Var
 AccessModTimes : TAccessModificationTimes;
 TimeStamp      : Int64;
Begin
 TimeStamp                               := DateTimeToUnixTime(Modified);
 AccessModTimes.AccessTime.tv_sec        := TimeStamp;
 AccessModTimes.AccessTime.tv_usec       := 0;
 AccessModTimes.ModificationTime.tv_sec  := TimeStamp;
 AccessModTimes.ModificationTime.tv_usec := 0;
 Result                                  := utimes(PChar(FileName), AccessModTimes) = 0;
End;
{$ENDIF}

Procedure CreateDirectories(Const DirName : TFileName);
Var
 Index : Integer;
Begin
 Index := 1;
 Repeat
  Index := PosExString(PathDelim, DirName, Index);
  If Index = 0 Then Break;
  EnsureDirectoryExists(Copy(DirName, 1, Index), True);
  Inc(Index);
 Until False;
End;

Function TAsset.LoadFromFile(Const Root, FileName : TFileName): Boolean;
Var
 Len : Integer;
Begin
 Result := FileExists(FileName);
 If Not Result Then Exit;
 Result := GetFileInfo(FileName, @Timestamp, Nil);
 If Not Result Then Exit;
 Len := Length(Root);
 If (Len > 0) And (Len <= Length(FileName)) And
    IdemPropName(Pointer(Root), Pointer(FileName), Len, Len) Then
  Path := Copy(ToUTF8(FileName), Len, MaxInt)
 Else
  Path := ToUTF8(FileName);
 {$IFDEF MSWINDOWS}
  Path := StringReplaceChars(Path, PathDelim, '/');
 {$ENDIF}
 LowerCaseSelf(Path);
 SetContent(StringFromFile(FileName));
 ContentType := KnownMIMETypes.Value(LowerCase(ToUTF8(ExtractFileExt(FileName))), #0);
 If ContentType = #0 Then
  ContentType := 'application/octet-stream';
 GZipExists := False;
 GZipContent := '';
 GZipHash := 0;
 RESTDWExists := False;
 RESTDWContent := '';
 RESTDWHash := 0;
End;

Function TAsset.SaveIdentityToFile(Const Root              : TFileName;
                                   Const ChecksNotModified : TFileChecks): TFileName;
Var
 LModified    : TDateTime;
 LSize        : Int64;
 FileModified : Boolean;
Begin
 Result := UTF8ToString(Path);
 {$IFDEF MSWINDOWS}
  Result := StringReplace(Result, '/', PathDelim, [rfReplaceAll]);
 {$ENDIF}
 If Root = '' Then
  Delete(Result, 1, 1)
 Else If Root[Length(Root)] = PathDelim Then
  Result := Root + Result
 Else
  Result := Root + PathDelim + Result;
 If (ChecksNotModified <> []) And FileExists(Result) And
     GetFileInfo(Result, @LModified, @LSize)         Then
  Begin
   FileModified := False;
   If fcModified In ChecksNotModified Then
    FileModified := FileModified Or (Round((LModified - Timestamp) * SecsPerDay) <> 0);
   If fcSize     In ChecksNotModified Then
    FileModified := FileModified Or (FileSize(Result) <> Length(Content));
   If Not FileModified Then Exit;
  End;
 CreateDirectories(Result);
 If FileFromString(Content, Result) Then
  SetFileTime(Result, Timestamp);
End;

Function TAsset.SaveToFile(Const Root              : TFileName;
                           Const Encoding          : TAssetEncoding;
                           Const ChecksNotModified : TFileChecks) : TFileName;
Const
 DIRS : Array[TAssetEncoding] Of TFileName = ('identity', 'gzip', 'RESTDW');
 EXTS : Array[TAssetEncoding] Of TFileName = ('', '.gz', '.br');
Var
 LModified    : TDateTime;
 LSize        : Int64;
 FileModified : Boolean;
 FileContent  : RawByteString;
Begin
 Case Encoding Of
  aeIdentity : FileContent := Content;
  aeGZip     : Begin
                If GZipExists Then
                  FileContent := GZipContent
                Else
                 Begin
                  Result := '';
                  Exit;
                 End;
                End;
  aeRESTDW    : Begin
                 If RESTDWExists Then
                  FileContent := RESTDWContent
                 Else
                  Begin
                   Result := '';
                   Exit;
                  End;
                End;
 End;
 Result := UTF8ToString(Path);
 {$IFDEF MSWINDOWS}
  Result := StringReplace(Result, '/', PathDelim, [rfReplaceAll]);
 {$ENDIF}
 If Root = '' Then
  Result := DIRS[Encoding] + Result
 Else If Root[Length(Root)] = PathDelim Then
  Result := Root + DIRS[Encoding] + Result
 Else
  Result := Root + PathDelim + DIRS[Encoding] + Result;
 If Encoding in [aeGZip, aeRESTDW] Then
  Result := Result + EXTS[Encoding];
 If (ChecksNotModified <> []) And FileExists(Result) And
     GetFileInfo(Result, @LModified, @LSize)         Then
  Begin
   FileModified := False;
   If fcModified In ChecksNotModified Then
    FileModified := FileModified Or (Round((LModified - Timestamp) * SecsPerDay) <> 0);
   If fcSize     In ChecksNotModified Then
    FileModified := FileModified Or (FileSize(Result) <> Length(FileContent));
   If Not FileModified Then Exit;
  End;
 CreateDirectories(Result);
 If FileFromString(FileContent, Result) Then
  SetFileTime(Result, Timestamp);
End;

Procedure TAsset.SetContent(Const AContent : RawByteString;
                            Const Encoding : TAssetEncoding = aeIdentity);
Begin
  Case Encoding Of
   aeIdentity : Begin
                 Content := AContent;
                 ContentHash := crc32c(0, Pointer(AContent), Length(AContent));
                End;

   aeGZip     : Begin
                 GZipExists := True;
                 GZipContent := AContent;
                 GZipHash := crc32c(0, Pointer(AContent), Length(AContent));
                End;

   aeRESTDW   : Begin
                 RESTDWExists := True;
                 RESTDWContent := AContent;
                 RESTDWHash := crc32c(0, Pointer(AContent), Length(AContent));
                End;
  End;
End;

Function TAssets.Add(Const Root, FileName : TFileName) : PAsset;
Var
 Asset    : TAsset;
 Index    : Integer;
 WasAdded : Boolean;
Begin
 If Not Asset.LoadFromFile(Root, FileName) Then
  Begin
   Result := Nil;
   Exit;
  End;
 Index         := FAssetsDAH.FindHashedForAdding(Asset, WasAdded);
 Assets[Index] := Asset;
 Result        := @Assets[Index];
End;

Function TAssets.Find(Const Path: RawUTF8): PAsset;
Var
 Index : Integer;
Begin
 Index := FAssetsDAH.FindHashed(Path);
 If Index >= 0 Then
  Result := @Assets[Index]
 Else
  Result := Nil;
End;

Procedure TAssets.Init;
Begin
 Count := 0;
 Assets := Nil;
 FAssetsDAH.InitSpecific(TypeInfo(TAssetDynArray), Assets, djRawUTF8, @Count);
End;

Procedure TAssets.LoadFromFile(Const FileName: TFileName);
Begin
 FAssetsDAH.LoadFrom(Pointer(AlgoSynLZ.Decompress(StringFromFile(FileName))));
 FAssetsDAH.ReHash;
End;

Procedure TAssets.LoadFromResource(Const ResName : String);
Var
 RawAssets : RawByteString;
Begin
 ResourceSynLZToRawByteString(ResName, RawAssets);
 FAssetsDAH.LoadFrom(Pointer(RawAssets));
 FAssetsDAH.ReHash;
End;

Procedure TAssets.SaveAll(Const Root              : TFileName;
                          Const ChecksNotModified : TFileChecks);
Var
 Index    : Integer;
 Encoding : TAssetEncoding;
Begin
 For Index := 0 to Count - 1 Do
  Begin
   With Assets[Index] Do
    Begin
     For Encoding := Low(TAssetEncoding) To High(TAssetEncoding) Do
      SaveToFile(Root, Encoding, ChecksNotModified);
    End;
  End;
End;

Procedure TAssets.SaveAllIdentities(Const Root              : TFileName;
                                    Const ChecksNotModified : TFileChecks);
Var
 Index : Integer;
Begin
 For Index := 0 to Count - 1 Do
  Begin
   With Assets[Index] Do
    SaveIdentityToFile(Root, ChecksNotModified);
  End;
End;

Function TAssets.SaveToFile         (Const FileName         : TFileName): Boolean;
Begin
 Result := ForceDirectories(IncludeTrailingPathDelimiter(ExtractFilePath(FileName)));
 If Not Result Then Exit;
 Result := FileFromString(AlgoSynLZ.Compress(FAssetsDAH.SaveTo), FileName, True);
End;

Procedure InitKnownMIMETypes;
Var
 Index : Integer;
Begin
 KnownMIMETypes.Init(False);
 For Index := 0 To Length(MIME_TYPES_FILE_EXTENSIONS) Shr 1 - 1 Do
  KnownMIMETypes.Add(MIME_TYPES_FILE_EXTENSIONS[Index shl 1 + 1], MIME_TYPES_FILE_EXTENSIONS[Index shl 1]);
End;

Initialization
 InitKnownMIMETypes;

End.
