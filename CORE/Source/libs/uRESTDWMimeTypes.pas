unit uRESTDWMimeTypes;

interface

uses
{$IFDEF MSWindows}Windows, Registry, {$ENDIF}
  Classes, SysUtils, StrUtils, uRESTDWConsts;

type
  TMimeTable = Class(TObject)
  Private
    procedure FillMIMETable(Const AMIMEList: TStringList;
      Const ALoadFromOS: Boolean = True);
    procedure GetMIMETableFromOS(const AMIMEList: TStringList);
  Protected
    FLoadTypesFromOS: Boolean;
    FOnBuildCache: TNotifyEvent;
    FMIMEList: TStringList;
    Procedure BuildDefaultCache; Virtual;
  Public
    Procedure AddMimeType(Const Ext, MIMEType: String;
      Const ARaiseOnError: Boolean = True);
    Procedure BuildCache; Virtual;
    Constructor Create(Const AutoFill: Boolean = True); Reintroduce; Virtual;
    Destructor Destroy; Override;
    Function GetFileMIMEType(Const AFileName: String): String;
    Function GetDefaultFileExt(Const MIMEType: String): String;
    Procedure LoadFromStrings(Const AStrings: TStringList);
    Procedure SaveToStrings(Const AStrings: TStringList);

    Property OnBuildCache: TNotifyEvent Read FOnBuildCache Write FOnBuildCache;
    Property LoadTypesFromOS: Boolean Read FLoadTypesFromOS
      Write FLoadTypesFromOS;
  End;

implementation

{ TMimeTable }

Procedure TMimeTable.AddMimeType(Const Ext, MIMEType: String;
  Const ARaiseOnError: Boolean = True);
Var
  LExt, LMimeType: String;
Begin
  { Check and fix extension and MIMEType }
  LExt := LowerCase(Ext);
  LMimeType := LowerCase(MIMEType);
  If (Length(LExt) = 0) or (Length(LMimeType) = 0) Then
  Begin
    If ARaiseOnError Then
      Raise Exception.Create(cMIMETypeEmpty);
    Exit;
  End;

  If LExt[1] <> '.' Then
    LExt := '.' + LExt; { do not localize }
  { Check list }
  If FMIMEList.IndexOf(LExt) = -1 Then
    FMIMEList.AddPair(LExt, LMimeType)
  Else
  Begin
    If ARaiseOnError Then
      Raise Exception.Create(cMIMETypeAlreadyExists);
    Exit;
  End;
End;

Procedure TMimeTable.BuildCache;
Begin
  If Assigned(FOnBuildCache) Then
    FOnBuildCache(Self)
  Else If FMIMEList.Count = 0 Then
    BuildDefaultCache;
End;

Procedure TMimeTable.BuildDefaultCache;
Var
  LKeys: TStringList;
Begin
  LKeys := TStringList.Create;
  Try
    FillMIMETable(LKeys, LoadTypesFromOS);
    LoadFromStrings(LKeys);
  Finally
    FreeAndNil(LKeys);
  End;
End;

Constructor TMimeTable.Create(Const AutoFill: Boolean);
Begin
  Inherited Create;
  FLoadTypesFromOS := True;
  FMIMEList := TStringList.Create;
  FMIMEList.Sorted := True;
  FMIMEList.Duplicates := dupIgnore;
  If AutoFill Then
    BuildCache;
End;

Destructor TMimeTable.Destroy;
Begin
  FreeAndNil(FMIMEList);
  Inherited Destroy;
End;

procedure TMimeTable.FillMIMETable(const AMIMEList: TStringList;
  const ALoadFromOS: Boolean);
Begin
  If Not Assigned(AMIMEList) Then
    Exit;
  If AMIMEList.Count > 0 Then
    Exit;
  If ALoadFromOS Then
    GetMIMETableFromOS(AMIMEList);

  // adição dos MIMETypes básicos do RDW
  AMIMEList.AddPair('.323', 'text/h323');
  AMIMEList.AddPair('.3g2', 'video/3gpp2');
  AMIMEList.AddPair('.3gp', 'video/3gpp');
  AMIMEList.AddPair('.7z', 'application/x-7z-compressed');
  AMIMEList.AddPair('.a', 'application/x-archive');
  AMIMEList.AddPair('.aab', 'application/x-authorware-bin');
  AMIMEList.AddPair('.aac', 'audio/aac');
  AMIMEList.AddPair('.aam', 'application/x-authorware-map');
  AMIMEList.AddPair('.aas', 'application/x-authorware-seg');
  AMIMEList.AddPair('.abw', 'application/x-abiword');
  AMIMEList.AddPair('.ace', 'application/x-ace-compressed');
  AMIMEList.AddPair('.ai', 'application/postscript');
  AMIMEList.AddPair('.aif', 'audio/x-aiff');
  AMIMEList.AddPair('.aifc', 'audio/x-aiff');
  AMIMEList.AddPair('.aiff', 'audio/x-aiff');
  AMIMEList.AddPair('.alz', 'application/x-alz-compressed');
  AMIMEList.AddPair('.ani', 'application/x-navi-animation');
  AMIMEList.AddPair('.arc', 'application/x-freearc');
  AMIMEList.AddPair('.arj', 'application/x-arj');
  AMIMEList.AddPair('.art', 'image/x-jg');
  AMIMEList.AddPair('.asf', 'application/vnd.ms-asf');
  AMIMEList.AddPair('.asf', 'video/x-ms-asf');
  AMIMEList.AddPair('.asm', 'text/x-asm');
  AMIMEList.AddPair('.asx', 'video/x-ms-asf-plugin');
  AMIMEList.AddPair('.asx', 'video/x-ms-asf');
  AMIMEList.AddPair('.au', 'audio/basic');
  AMIMEList.AddPair('.avi', 'video/x-msvideo');
  AMIMEList.AddPair('.avif', 'image/avif');
  AMIMEList.AddPair('.azw', 'application/vnd.amazon.ebook');
  AMIMEList.AddPair('.bat', 'application/x-msdos-program');
  AMIMEList.AddPair('.bcpio', 'application/x-bcpio');
  AMIMEList.AddPair('.bin', 'application/octet-stream');
  AMIMEList.AddPair('.bmp', 'image/bmp');
  AMIMEList.AddPair('.boz', 'application/x-bzip2');
  AMIMEList.AddPair('.bz', 'application/x-bzip');
  AMIMEList.AddPair('.bz2', 'application/x-bzip2');
  AMIMEList.AddPair('.c', 'text/x-csrc');
  AMIMEList.AddPair('.c++', 'text/x-c++src');
  AMIMEList.AddPair('.cab', 'application/vnd.ms-cab-compressed');
  AMIMEList.AddPair('.cat', 'application/vnd.ms-pki.seccat');
  AMIMEList.AddPair('.cc', 'text/x-c++src');
  AMIMEList.AddPair('.ccn', 'application/x-cnc');
  AMIMEList.AddPair('.cco', 'application/x-cocoa');
  AMIMEList.AddPair('.cda', 'application/x-cdf');
  AMIMEList.AddPair('.cdf', 'application/x-cdf');
  AMIMEList.AddPair('.cdr', 'image/x-coreldraw');
  AMIMEList.AddPair('.cdt', 'image/x-coreldrawtemplate');
  AMIMEList.AddPair('.cer', 'application/x-x509-ca-cert');
  AMIMEList.AddPair('.chm', 'application/vnd.ms-htmlhelp');
  AMIMEList.AddPair('.chrt', 'application/vnd.kde.kchart');
  AMIMEList.AddPair('.cil', 'application/vnd.ms-artgalry');
  AMIMEList.AddPair('.class', 'application/java-vm');
  AMIMEList.AddPair('.clp', 'application/x-msclip');
  AMIMEList.AddPair('.com', 'application/x-msdos-program');
  AMIMEList.AddPair('.cpio', 'application/x-cpio');
  AMIMEList.AddPair('.cpp', 'text/x-c++src');
  AMIMEList.AddPair('.cpt', 'application/mac-compactpro');
  AMIMEList.AddPair('.cpt', 'image/x-corelphotopaint');
  AMIMEList.AddPair('.cqk', 'application/x-calquick');
  AMIMEList.AddPair('.crd', 'application/x-mscardfile');
  AMIMEList.AddPair('.crl', 'application/pkix-crl');
  AMIMEList.AddPair('.cs', 'text/x-csharp');
  AMIMEList.AddPair('.csh', 'application/x-csh');
  AMIMEList.AddPair('.css', 'text/css');
  AMIMEList.AddPair('.csv', 'text/csv');
  AMIMEList.AddPair('.cxx', 'text/x-c++src');
  AMIMEList.AddPair('.dar', 'application/x-dar');
  AMIMEList.AddPair('.dbf', 'application/x-dbase');
  AMIMEList.AddPair('.dcr', 'application/x-director');
  AMIMEList.AddPair('.deb', 'application/x-debian-package');
  AMIMEList.AddPair('.dir', 'application/x-director');
  AMIMEList.AddPair('.dist', 'vnd.apple.installer+xml');
  AMIMEList.AddPair('.distz', 'vnd.apple.installer+xml');
  AMIMEList.AddPair('.djv', 'image/vnd.djvu');
  AMIMEList.AddPair('.djvu', 'image/vnd.djvu');
  AMIMEList.AddPair('.dl', 'video/dl');
  AMIMEList.AddPair('.dll', 'application/x-msdos-program');
  AMIMEList.AddPair('.dmg', 'application/x-apple-diskimage');
  AMIMEList.AddPair('.doc', 'application/vnd.ms-word');
  AMIMEList.AddPair('.docx',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
  AMIMEList.AddPair('.dot', 'application/msword');
  AMIMEList.AddPair('.dv', 'video/dv');
  AMIMEList.AddPair('.dvi', 'application/x-dvi');
  AMIMEList.AddPair('.dxr', 'application/x-director');
  AMIMEList.AddPair('.ebk', 'application/x-expandedbook');
  AMIMEList.AddPair('.eot', 'application/vnd.ms-fontobject');
  AMIMEList.AddPair('.eps', 'application/postscript');
  AMIMEList.AddPair('.epub', 'application/epub+zip');
  AMIMEList.AddPair('.evy', 'application/envoy');
  AMIMEList.AddPair('.exe', 'application/x-msdos-program');
  AMIMEList.AddPair('.fdf', 'application/vnd.fdf');
  AMIMEList.AddPair('.fif', 'application/fractals');
  AMIMEList.AddPair('.flc', 'video/flc');
  AMIMEList.AddPair('.fli', 'video/fli');
  AMIMEList.AddPair('.flm', 'application/vnd.kde.kivio');
  AMIMEList.AddPair('.fml', 'application/x-file-mirror-list');
  AMIMEList.AddPair('.gif', 'image/gif');
  AMIMEList.AddPair('.gl', 'video/gl');
  AMIMEList.AddPair('.gnumeric', 'application/x-gnumeric');
  AMIMEList.AddPair('.gsm', 'audio/x-gsm');
  AMIMEList.AddPair('.gtar', 'application/x-gtar');
  AMIMEList.AddPair('.gz', 'application/gzip');
  AMIMEList.AddPair('.gzip', 'application/x-gzip');
  AMIMEList.AddPair('.h', 'text/x-chdr');
  AMIMEList.AddPair('.h++', 'text/x-c++hdr');
  AMIMEList.AddPair('.hdf', 'application/x-hdf');
  AMIMEList.AddPair('.hh', 'text/x-c++hdr');
  AMIMEList.AddPair('.hlp', 'application/winhlp');
  AMIMEList.AddPair('.hpf', 'application/x-icq-hpf');
  AMIMEList.AddPair('.hpp', 'text/x-c++hdr');
  AMIMEList.AddPair('.hqx', 'application/mac-binhex40');
  AMIMEList.AddPair('.hta', 'application/hta');
  AMIMEList.AddPair('.htc', 'text/x-component');
  AMIMEList.AddPair('.htm', 'text/html');
  AMIMEList.AddPair('.html', 'text/html');
  AMIMEList.AddPair('.htt', 'text/webviewhtml');
  AMIMEList.AddPair('.hxx', 'text/x-c++hdr');
  AMIMEList.AddPair('.ico', 'image/vnd.microsoft.icon');
  AMIMEList.AddPair('.ics', 'text/calendar');
  AMIMEList.AddPair('.ief', 'image/ief');
  AMIMEList.AddPair('.iii', 'application/x-iphone');
  AMIMEList.AddPair('.ims', 'application/vnd.ms-ims');
  AMIMEList.AddPair('.ins', 'application/x-internet-signup');
  AMIMEList.AddPair('.iso', 'application/x-iso9660-image');
  AMIMEList.AddPair('.ivf', 'video/x-ivf');
  AMIMEList.AddPair('.jar', 'application/java-archive');
  AMIMEList.AddPair('.java', 'text/x-java');
  AMIMEList.AddPair('.jng', 'image/x-jng');
  AMIMEList.AddPair('.jpe', 'image/jpeg');
  AMIMEList.AddPair('.jpeg', 'image/jpeg');
  AMIMEList.AddPair('.jpg', 'image/jpeg');
  AMIMEList.AddPair('.js', 'text/javascript');
  AMIMEList.AddPair('.json', 'application/json');
  AMIMEList.AddPair('.jsonld', 'application/ld+json');
  AMIMEList.AddPair('.kar', 'audio/midi');
  AMIMEList.AddPair('.karbon', 'application/vnd.kde.karbon');
  AMIMEList.AddPair('.kfo', 'application/vnd.kde.kformula');
  AMIMEList.AddPair('.kon', 'application/vnd.kde.kontour');
  AMIMEList.AddPair('.kpr', 'application/vnd.kde.kpresenter');
  AMIMEList.AddPair('.kpt', 'application/vnd.kde.kpresenter');
  AMIMEList.AddPair('.kwd', 'application/vnd.kde.kword');
  AMIMEList.AddPair('.kwt', 'application/vnd.kde.kword');
  AMIMEList.AddPair('.latex', 'application/x-latex');
  AMIMEList.AddPair('.lcc', 'application/fastman');
  AMIMEList.AddPair('.lha', 'application/x-lzh');
  AMIMEList.AddPair('.lrm', 'application/vnd.ms-lrm');
  AMIMEList.AddPair('.ls', 'text/javascript');
  AMIMEList.AddPair('.lsf', 'video/x-la-asf');
  AMIMEList.AddPair('.lsx', 'video/x-la-asf');
  AMIMEList.AddPair('.lz', 'application/x-lzip');
  AMIMEList.AddPair('.lzh', 'application/x-lzh');
  AMIMEList.AddPair('.lzma', 'application/x-lzma');
  AMIMEList.AddPair('.lzo', 'application/x-lzop');
  AMIMEList.AddPair('.lzx', 'application/x-lzx');
  AMIMEList.AddPair('.m13', 'application/x-msmediaview');
  AMIMEList.AddPair('.m14', 'application/x-msmediaview');
  AMIMEList.AddPair('.m3u', 'audio/mpegurl');
  AMIMEList.AddPair('.m4a', 'audio/x-mpg');
  AMIMEList.AddPair('.man', 'application/x-troff-man');
  AMIMEList.AddPair('.mdb', 'application/x-msaccess');
  AMIMEList.AddPair('.me', 'application/x-troff-me');
  AMIMEList.AddPair('.mht', 'message/rfc822');
  AMIMEList.AddPair('.mid', 'audio/midi');
  AMIMEList.AddPair('.midi', 'audio/x-midi');
  AMIMEList.AddPair('.mjf', 'audio/x-vnd.AudioExplosion.MjuiceMediaFile');
  AMIMEList.AddPair('.mjs', 'text/javascript');
  AMIMEList.AddPair('.mng', 'video/x-mng');
  AMIMEList.AddPair('.mny', 'application/x-msmoney');
  AMIMEList.AddPair('.mocha', 'text/javascript');
  AMIMEList.AddPair('.moov', 'video/quicktime');
  AMIMEList.AddPair('.mov', 'video/quicktime');
  AMIMEList.AddPair('.movie', 'video/x-sgi-movie');
  AMIMEList.AddPair('.mp2', 'audio/x-mpg');
  AMIMEList.AddPair('.mp2', 'video/mpeg');
  AMIMEList.AddPair('.mp3', 'audio/mpeg');
  AMIMEList.AddPair('.mp3', 'video/mpeg');
  AMIMEList.AddPair('.mp4', 'video/mp4');
  AMIMEList.AddPair('.mp4', 'video/mpeg');
  AMIMEList.AddPair('.mpa', 'video/mpeg');
  AMIMEList.AddPair('.mpe', 'video/mpeg');
  AMIMEList.AddPair('.mpeg', 'video/mpeg');
  AMIMEList.AddPair('.mpega', 'audio/x-mpg');
  AMIMEList.AddPair('.mpg', 'video/mpeg');
  AMIMEList.AddPair('.mpga', 'audio/x-mpg');
  AMIMEList.AddPair('.mpkg', 'application/vnd.apple.installer+xml');
  AMIMEList.AddPair('.mpp', 'application/vnd.ms-project');
  AMIMEList.AddPair('.ms', 'application/x-troff-ms');
  AMIMEList.AddPair('.msi', 'application/x-msi');
  AMIMEList.AddPair('.mvb', 'application/x-msmediaview');
  AMIMEList.AddPair('.mxu', 'video/vnd.mpegurl');
  AMIMEList.AddPair('.nix', 'application/x-mix-transfer');
  AMIMEList.AddPair('.nml', 'animation/narrative');
  AMIMEList.AddPair('.o', 'application/x-object');
  AMIMEList.AddPair('.oda', 'application/oda');
  AMIMEList.AddPair('.odb', 'application/vnd.oasis.opendocument.database');
  AMIMEList.AddPair('.odc', 'application/vnd.oasis.opendocument.chart');
  AMIMEList.AddPair('.odf', 'application/vnd.oasis.opendocument.formula');
  AMIMEList.AddPair('.odg', 'application/vnd.oasis.opendocument.graphics');
  AMIMEList.AddPair('.odi', 'application/vnd.oasis.opendocument.image');
  AMIMEList.AddPair('.odm', 'application/vnd.oasis.opendocument.text-master');
  AMIMEList.AddPair('.odp', 'application/vnd.oasis.opendocument.presentation');
  AMIMEList.AddPair('.ods', 'application/vnd.oasis.opendocument.spreadsheet');
  AMIMEList.AddPair('.odt', 'application/vnd.oasis.opendocument.text');
  AMIMEList.AddPair('.oga', 'audio/ogg');
  AMIMEList.AddPair('.ogg', 'application/ogg');
  AMIMEList.AddPair('.ogv', 'video/ogg');
  AMIMEList.AddPair('.ogx', 'application/ogg');
  AMIMEList.AddPair('.opus', 'audio/opus');
  AMIMEList.AddPair('.otf', 'font/otf');
  AMIMEList.AddPair('.otg',
    'application/vnd.oasis.opendocument.graphics-template');
  AMIMEList.AddPair('.oth', 'application/vnd.oasis.opendocument.text-web');
  AMIMEList.AddPair('.otp',
    'application/vnd.oasis.opendocument.presentation-template');
  AMIMEList.AddPair('.ots',
    'application/vnd.oasis.opendocument.spreadsheet-template');
  AMIMEList.AddPair('.ott', 'application/vnd.oasis.opendocument.text-template');
  AMIMEList.AddPair('.p', 'text/x-pascal');
  AMIMEList.AddPair('.p10', 'application/pkcs10');
  AMIMEList.AddPair('.p12', 'application/x-pkcs12');
  AMIMEList.AddPair('.p7b', 'application/x-pkcs7-certificates');
  AMIMEList.AddPair('.p7m', 'application/pkcs7-mime');
  AMIMEList.AddPair('.p7r', 'application/x-pkcs7-certreqresp');
  AMIMEList.AddPair('.p7s', 'application/pkcs7-signature');
  AMIMEList.AddPair('.package', 'application/vnd.autopackage');
  AMIMEList.AddPair('.pas', 'text/x-pascal');
  AMIMEList.AddPair('.pat', 'image/x-coreldrawpattern');
  AMIMEList.AddPair('.pbm', 'image/x-portable-bitmap');
  AMIMEList.AddPair('.pcx', 'image/pcx');
  AMIMEList.AddPair('.pdf', 'application/pdf');
  AMIMEList.AddPair('.pfr', 'application/font-tdpfr');
  AMIMEList.AddPair('.pgm', 'image/x-portable-graymap');
  AMIMEList.AddPair('.php', 'application/x-httpd-php');
  AMIMEList.AddPair('.pict', 'image/x-pict');
  AMIMEList.AddPair('.pkg', 'vnd.apple.installer+xml');
  AMIMEList.AddPair('.pko', 'application/vnd.ms-pki.pko');
  AMIMEList.AddPair('.pl', 'application/x-perl');
  AMIMEList.AddPair('.pls', 'audio/x-scpls');
  AMIMEList.AddPair('.png', 'image/png');
  AMIMEList.AddPair('.pnm', 'image/x-portable-anymap');
  AMIMEList.AddPair('.pnq', 'application/x-icq-pnq');
  AMIMEList.AddPair('.pntg', 'image/x-macpaint');
  AMIMEList.AddPair('.pot', 'application/mspowerpoint');
  AMIMEList.AddPair('.ppm', 'image/x-portable-pixmap');
  AMIMEList.AddPair('.pps', 'application/mspowerpoint');
  AMIMEList.AddPair('.ppt', 'application/vnd.ms-powerpoint');
  AMIMEList.AddPair('.pptx',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation');
  AMIMEList.AddPair('.ppz', 'application/mspowerpoint');
  AMIMEList.AddPair('.ps', 'application/postscript');
  AMIMEList.AddPair('.psd', 'image/x-psd');
  AMIMEList.AddPair('.pub', 'application/x-mspublisher');
  AMIMEList.AddPair('.qcp', 'audio/vnd.qcelp');
  AMIMEList.AddPair('.qpw', 'application/x-quattropro');
  AMIMEList.AddPair('.qt', 'video/quicktime');
  AMIMEList.AddPair('.qtc', 'video/x-qtc');
  AMIMEList.AddPair('.qtif', 'image/x-quicktime');
  AMIMEList.AddPair('.qtl', 'application/x-quicktimeplayer');
  AMIMEList.AddPair('.ra', 'audio/x-realaudio');
  AMIMEList.AddPair('.ram', 'audio/x-pn-realaudio');
  AMIMEList.AddPair('.rar', 'application/vnd.rar');
  AMIMEList.AddPair('.ras', 'image/x-cmu-raster');
  AMIMEList.AddPair('.rdf', 'application/rdf+xml');
  AMIMEList.AddPair('.rf', 'image/vnd.rn-realflash');
  AMIMEList.AddPair('.rgb', 'image/x-rgb');
  AMIMEList.AddPair('.rjs', 'application/vnd.rn-realsystem-rjs');
  AMIMEList.AddPair('.rm', 'application/vnd.rn-realmedia');
  AMIMEList.AddPair('.rmf', 'application/vnd.rmf');
  AMIMEList.AddPair('.rmp', 'application/vnd.rn-rn_music_package');
  AMIMEList.AddPair('.rms', 'video/vnd.rn-realvideo-secure');
  AMIMEList.AddPair('.rmx', 'application/vnd.rn-realsystem-rmx');
  AMIMEList.AddPair('.rnx', 'application/vnd.rn-realplayer');
  AMIMEList.AddPair('.rp', 'image/vnd.rn-realpix');
  AMIMEList.AddPair('.rpm', 'application/x-redhat-package-manager');
  AMIMEList.AddPair('.rsml', 'application/vnd.rn-rsml');
  AMIMEList.AddPair('.rss', 'application/rss+xml');
  AMIMEList.AddPair('.rt', 'text/vnd.rn-realtext');
  AMIMEList.AddPair('.rtf', 'application/rtf');
  AMIMEList.AddPair('.rtsp', 'application/x-rtsp');
  AMIMEList.AddPair('.rtx', 'text/richtext');
  AMIMEList.AddPair('.rv', 'video/vnd.rn-realvideo');
  AMIMEList.AddPair('.scd', 'application/x-msschedule');
  AMIMEList.AddPair('.scm', 'application/x-icq-scm');
  AMIMEList.AddPair('.sd2', 'audio/x-sd2');
  AMIMEList.AddPair('.sda', 'application/vnd.stardivision.draw');
  AMIMEList.AddPair('.sdc', 'application/vnd.stardivision.calc');
  AMIMEList.AddPair('.sdd', 'application/vnd.stardivision.impress');
  AMIMEList.AddPair('.sdp', 'application/x-sdp');
  AMIMEList.AddPair('.ser', 'application/java-serialized-object');
  AMIMEList.AddPair('.setpay', 'application/set-payment-initiation');
  AMIMEList.AddPair('.setreg', 'application/set-registration-initiation');
  AMIMEList.AddPair('.sgi', 'image/x-sgi');
  AMIMEList.AddPair('.sgm', 'text/sgml');
  AMIMEList.AddPair('.sgml', 'text/sgml');
  AMIMEList.AddPair('.sh', 'application/x-sh');
  AMIMEList.AddPair('.shar', 'application/x-shar');
  AMIMEList.AddPair('.shtml', 'server-parsed-html');
  AMIMEList.AddPair('.shw', 'application/presentations');
  AMIMEList.AddPair('.sid', 'audio/prs.sid');
  AMIMEList.AddPair('.sit', 'application/x-stuffit');
  AMIMEList.AddPair('.sitx', 'application/x-stuffitx');
  AMIMEList.AddPair('.skd', 'application/x-koan');
  AMIMEList.AddPair('.skm', 'application/x-koan');
  AMIMEList.AddPair('.skp', 'application/x-koan');
  AMIMEList.AddPair('.skt', 'application/x-koan');
  AMIMEList.AddPair('.smf', 'application/vnd.stardivision.math');
  AMIMEList.AddPair('.smi', 'application/smil');
  AMIMEList.AddPair('.smil', 'application/smil');
  AMIMEList.AddPair('.snd', 'audio/basic');
  AMIMEList.AddPair('.spl', 'application/futuresplash');
  AMIMEList.AddPair('.ssm', 'application/streamingmedia');
  AMIMEList.AddPair('.sst', 'application/vnd.ms-pki.certstore');
  AMIMEList.AddPair('.stc', 'application/vnd.sun.xml.calc.template');
  AMIMEList.AddPair('.std', 'application/vnd.sun.xml.draw.template');
  AMIMEList.AddPair('.sti', 'application/vnd.sun.xml.impress.template');
  AMIMEList.AddPair('.stl', 'application/vnd.ms-pki.stl');
  AMIMEList.AddPair('.stw', 'application/vnd.sun.xml.writer.template');
  AMIMEList.AddPair('.sv4cpio', 'application/x-sv4cpio');
  AMIMEList.AddPair('.sv4crc', 'application/x-sv4crc');
  AMIMEList.AddPair('.svg', 'image/svg+xml');
  AMIMEList.AddPair('.svgz', 'image/svg+xml');
  AMIMEList.AddPair('.svi', 'application/softvision');
  AMIMEList.AddPair('.swf', 'application/x-shockwave-flash');
  AMIMEList.AddPair('.swf1', 'application/x-shockwave-flash');
  AMIMEList.AddPair('.sxc', 'application/vnd.sun.xml.calc');
  AMIMEList.AddPair('.sxg', 'application/vnd.sun.xml.writer.global');
  AMIMEList.AddPair('.sxi', 'application/vnd.sun.xml.impress');
  AMIMEList.AddPair('.sxm', 'application/vnd.sun.xml.math');
  AMIMEList.AddPair('.sxw', 'application/vnd.sun.xml.writer');
  AMIMEList.AddPair('.t', 'application/x-troff');
  AMIMEList.AddPair('.tar', 'application/x-tar');
  AMIMEList.AddPair('.targa', 'image/x-targa');
  AMIMEList.AddPair('.tbz', 'application/x-bzip-compressed-tar');
  AMIMEList.AddPair('.tbz2', 'application/x-bzip-compressed-tar');
  AMIMEList.AddPair('.tcl', 'application/x-tcl');
  AMIMEList.AddPair('.tex', 'application/x-tex');
  AMIMEList.AddPair('.texi', 'application/x-texinfo');
  AMIMEList.AddPair('.texinfo', 'application/x-texinfo');
  AMIMEList.AddPair('.tgz', 'application/x-compressed-tar');
  AMIMEList.AddPair('.tif', 'image/tiff');
  AMIMEList.AddPair('.tiff', 'image/tiff');
  AMIMEList.AddPair('.tlz', 'application/x-lzma-compressed-tar');
  AMIMEList.AddPair('.torrent', 'application/x-bittorrent');
  AMIMEList.AddPair('.tr', 'application/x-troff');
  AMIMEList.AddPair('.trm', 'application/x-msterminal');
  AMIMEList.AddPair('.troff', 'application/x-troff');
  AMIMEList.AddPair('.ts', 'video/mp2t');
  AMIMEList.AddPair('.tsp', 'application/dsptype');
  AMIMEList.AddPair('.ttf', 'font/ttf');
  AMIMEList.AddPair('.ttz', 'application/t-time');
  AMIMEList.AddPair('.txt', 'text/plain');
  AMIMEList.AddPair('.txz', 'application/x-xz-compressed-tar');
  AMIMEList.AddPair('.udeb', 'application/x-debian-package');
  AMIMEList.AddPair('.uin', 'application/x-icq');
  AMIMEList.AddPair('.uls', 'text/iuls');
  AMIMEList.AddPair('.urls', 'application/x-url-list');
  AMIMEList.AddPair('.ustar', 'application/x-ustar');
  AMIMEList.AddPair('.vcd', 'application/x-cdlink');
  AMIMEList.AddPair('.vcf', 'text/x-vcard');
  AMIMEList.AddPair('.vor', 'application/vnd.stardivision.writer');
  AMIMEList.AddPair('.vsd', 'application/vnd.visio');
  AMIMEList.AddPair('.vsl', 'application/x-cnet-vsl');
  AMIMEList.AddPair('.wav', 'audio/wav');
  AMIMEList.AddPair('.wax', 'audio/x-ms-wax');
  AMIMEList.AddPair('.wb1', 'application/x-quattropro');
  AMIMEList.AddPair('.wb2', 'application/x-quattropro');
  AMIMEList.AddPair('.wb3', 'application/x-quattropro');
  AMIMEList.AddPair('.wbmp', 'image/vnd.wap.wbmp');
  AMIMEList.AddPair('.wcm', 'application/vnd.ms-works');
  AMIMEList.AddPair('.wdb', 'application/vnd.ms-works');
  AMIMEList.AddPair('.weba', 'audio/webm');
  AMIMEList.AddPair('.webm', 'video/webm');
  AMIMEList.AddPair('.webp', 'image/webp');
  AMIMEList.AddPair('.wks', 'application/vnd.ms-works');
  AMIMEList.AddPair('.wm', 'video/x-ms-wm');
  AMIMEList.AddPair('.wma', 'audio/x-ms-wma');
  AMIMEList.AddPair('.wmd', 'application/x-ms-wmd');
  AMIMEList.AddPair('.wml', 'text/vnd.wap.wml');
  AMIMEList.AddPair('.wmlc', 'application/vnd.wap.wmlc');
  AMIMEList.AddPair('.wmls', 'text/vnd.wap.wmlscript');
  AMIMEList.AddPair('.wmlsc', 'application/vnd.wap.wmlscriptc');
  AMIMEList.AddPair('.wmp', 'video/x-ms-wmp');
  AMIMEList.AddPair('.wms', 'application/x-ms-wms');
  AMIMEList.AddPair('.wmv', 'video/x-ms-wmv');
  AMIMEList.AddPair('.wmx', 'video/x-ms-wmx');
  AMIMEList.AddPair('.wmz', 'application/x-ms-wmz');
  AMIMEList.AddPair('.woff', 'font/woff');
  AMIMEList.AddPair('.woff2', 'font/woff2');
  AMIMEList.AddPair('.wp5', 'application/wordperfect5.1');
  AMIMEList.AddPair('.wpd', 'application/wordperfect');
  AMIMEList.AddPair('.wpl', 'application/vnd.ms-wpl');
  AMIMEList.AddPair('.wps', 'application/vnd.ms-works');
  AMIMEList.AddPair('.wri', 'application/x-mswrite');
  AMIMEList.AddPair('.wsc', 'text/scriptlet');
  AMIMEList.AddPair('.wvx', 'video/x-ms-wvx');
  AMIMEList.AddPair('.xbm', 'image/x-xbitmap');
  AMIMEList.AddPair('.xfdf', 'application/vnd.adobe.xfdf');
  AMIMEList.AddPair('.xht', 'application/xhtml+xml');
  AMIMEList.AddPair('.xhtml', 'application/xhtml+xml');
  AMIMEList.AddPair('.xlb', 'application/x-msexcel');
  AMIMEList.AddPair('.xls', 'application/vnd.ms-excel');
  AMIMEList.AddPair('.xlsx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  AMIMEList.AddPair('.xml', 'application/xml');
  AMIMEList.AddPair('.xpi', 'application/x-xpinstall');
  AMIMEList.AddPair('.xpm', 'image/x-xpixmap');
  AMIMEList.AddPair('.xps', 'application/vnd.ms-xpsdocument');
  AMIMEList.AddPair('.xsd', 'application/vnd.sun.xml.draw');
  AMIMEList.AddPair('.xul', 'application/vnd.mozilla.xul+xml');
  AMIMEList.AddPair('.xwd', 'image/x-xwindowdump');
  AMIMEList.AddPair('.z', 'application/x-compress');
  AMIMEList.AddPair('.zip', 'application/zip');
  AMIMEList.AddPair('.zoo', 'application/x-zoo');
End;

Function TMimeTable.GetDefaultFileExt(Const MIMEType: String): String;
Var
  Index: Integer;
  LMimeType: String;
Begin
  LMimeType := LowerCase(MIMEType);
  Index := FMIMEList.IndexOf(LMimeType);
  If Index = -1 Then
  Begin
    BuildCache;
    Index := FMIMEList.IndexOf(LMimeType);
  End;
  If Index <> -1 Then
    Result := FMIMEList.Names[Index]
  Else
    Result := ''; { Do not Localize }
End;

Function TMimeTable.GetFileMIMEType(Const AFileName: String): String;
Var
  Index: Integer;
  LExt: String;
Begin
  LExt := LowerCase(ExtractFileExt(AFileName));
  Index := FMIMEList.IndexOf(LExt);
  If Index = -1 Then
  Begin
    BuildCache;
    Index := FMIMEList.IndexOf(LExt);
  End;
  If Index <> -1 Then
    Result := FMIMEList.Strings[Index]
  Else
    Result := 'application/octet-stream' { do not localize }
End;

procedure TMimeTable.GetMIMETableFromOS(const AMIMEList: TStringList);
{$IFDEF MSWindows}
Var
  reg: TRegistry;
  KeyList: TStringList;
  I: Integer;
  S, LExt: String;
{$IFEND}
begin
{$IFNDEF MSWindows}
  Exit;
{$ELSE}
  // Build the file type/MIME type map
  reg := TRegistry.Create;
  Try
    KeyList := TStringList.Create;
    Try
      reg.RootKey := HKEY_CLASSES_ROOT;
      If reg.OpenKeyReadOnly('\') Then
      Begin { do not localize }
        reg.GetKeyNames(KeyList);
        reg.Closekey;
      End;
      // get a list of registered extentions
      For I := 0 To KeyList.Count - 1 Do
      Begin
        LExt := KeyList.Strings[I];
        If copy(LExt, 0, 1) = '.' Then
        Begin { do not localize }
          If reg.OpenKeyReadOnly(LExt) Then
          Begin
            S := reg.ReadString('Content Type'); { do not localize }
            If Length(S) > 0 Then
              AMIMEList.Values[LowerCase(LExt)] := LowerCase(S);
            reg.Closekey;
          End;
        End;
      end;
      If reg.OpenKeyReadOnly('\MIME\Database\Content Type') Then
      Begin { do not localize }
        // get a list of registered MIME types
        KeyList.Clear;
        reg.GetKeyNames(KeyList);
        reg.Closekey;
        For I := 0 To KeyList.Count - 1 Do
        Begin
          If reg.OpenKeyReadOnly('\MIME\Database\Content Type\' +
            KeyList[I]) Then
          Begin { do not localize }
            LExt := LowerCase(reg.ReadString('Extension'));
            { do not localize }
            If Length(LExt) > 0 Then
            Begin
              If LExt[1] <> '.' Then
                LExt := '.' + LExt; { do not localize }
              AMIMEList.Values[LExt] := LowerCase(KeyList[I]);
            End;
            reg.Closekey;
          End;
        End;
      End;
    Finally
      KeyList.Free;
    End;
  Finally
    reg.Free;
  End;
{$ENDIF}
end;

Procedure TMimeTable.LoadFromStrings(Const AStrings: TStringList);
{ Do not Localize }
Var
  I: Integer;
Begin
  InitializeStrings;
  Assert(AStrings <> nil);
  FMIMEList.Clear;
  For I := 0 To AStrings.Count - 1 Do
    AddMimeType(AStrings.Names[I], AStrings.Strings[I], False);
End;

Procedure TMimeTable.SaveToStrings(Const AStrings: TStringList);
Var
  I: Integer;
Begin
  Assert(AStrings <> nil);
  AStrings.BeginUpdate;
  Try
    AStrings.Clear;
    For I := 0 To FMIMEList.Count - 1 Do
      AStrings.AddPair(FMIMEList.Names[I], FMIMEList.Strings[I]);
  Finally
    AStrings.EndUpdate;
  End;
End;

end.
