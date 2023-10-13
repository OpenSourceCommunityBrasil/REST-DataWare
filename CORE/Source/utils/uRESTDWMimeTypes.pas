unit uRESTDWMimeTypes;

{$I ..\Includes\uRESTDW.inc}

interface

uses
{$IFDEF RESTDWWINDOWS}Windows, Registry, {$ENDIF}
  Classes, SysUtils, StrUtils, uRESTDWTools, uRESTDWConsts;

type
  TRESTDWMIMEType = class(TObject)
  private
    procedure FillMIMETable(const AMIMEList: TStringList;
      const ALoadFromOS: boolean = True);
    procedure GetMIMETableFromOS(const AMIMEList: TStringList);
  protected
    FLoadTypesFromOS: boolean;
    FOnBuildCache: TNotifyEvent;
    FMIMEList: TStringList;
    procedure BuildDefaultCache; virtual;
  public
    class function GetMIMEType(aFile: TFileName): string;
    class function GetMIMETypeExt(aMIMEType: string): string;
    procedure AddMimeType(const Ext, MIMEType: string;
      const ARaiseOnError: boolean = True);
    procedure BuildCache; virtual;
    constructor Create(const AutoFill: boolean = True); reintroduce; virtual;
    destructor Destroy; override;
    function GetFileMIMEType(const AFileName: string): string;
    function GetDefaultFileExt(const MIMEType: string): string;
    procedure LoadFromStrings(const AStrings: TStringList);
    procedure SaveToStrings(const AStrings: TStringList);

    property OnBuildCache: TNotifyEvent read FOnBuildCache write FOnBuildCache;
    property LoadTypesFromOS: boolean read FLoadTypesFromOS
      write FLoadTypesFromOS;
  end;

implementation

{ TMimeTable }

procedure TRESTDWMIMEType.AddMimeType(const Ext, MIMEType: string;
  const ARaiseOnError: boolean = True);
var
  LExt, LMimeType: string;
begin
  { Check and fix extension and MIMEType }
  LExt := LowerCase(Ext);
  LMimeType := LowerCase(MIMEType);
  if (Length(LExt) = 0) or (Length(LMimeType) = 0) then
  begin
    if ARaiseOnError then
      raise Exception.Create(cMIMETypeEmpty);
    Exit;
  end;

  if LExt[1] <> '.' then
    LExt := '.' + LExt; { do not localize }
  { Check list }
  if FMIMEList.IndexOf(LExt) = -1 then
    FMIMEList.Add(LExt + '=' + LMimeType)
  else
  begin
    if ARaiseOnError then
      raise Exception.Create(cMIMETypeAlreadyExists);
    Exit;
  end;
end;

procedure TRESTDWMIMEType.BuildCache;
begin
  if Assigned(FOnBuildCache) then
    FOnBuildCache(Self)
  else if FMIMEList.Count = 0 then
    BuildDefaultCache;
end;

procedure TRESTDWMIMEType.BuildDefaultCache;
begin
  FillMIMETable(FMIMEList, LoadTypesFromOS);
end;

constructor TRESTDWMIMEType.Create(const AutoFill: boolean);
begin
  inherited Create;
  FLoadTypesFromOS := True;
  FMIMEList := TStringList.Create;
  FMIMEList.Sorted := True;
  FMIMEList.Duplicates := dupIgnore;
  initializestrings;
  if AutoFill then
    BuildCache;
end;

destructor TRESTDWMIMEType.Destroy;
begin
  FreeAndNil(FMIMEList);
  inherited Destroy;
end;

procedure TRESTDWMIMEType.FillMIMETable(const AMIMEList: TStringList;
  const ALoadFromOS: boolean);
begin
  if not Assigned(AMIMEList) then
    Exit;
  if AMIMEList.Count > 0 then
    Exit;
  if ALoadFromOS then
    GetMIMETableFromOS(AMIMEList);

  AMIMEList.BeginUpdate;
  // adição dos MIMETypes básicos do RDW
  AMIMEList.Add('.323' + '=' + 'text/h323');
  AMIMEList.Add('.3g2' + '=' + 'video/3gpp2');
  AMIMEList.Add('.3gp' + '=' + 'video/3gpp');
  AMIMEList.Add('.7z' + '=' + 'application/x-7z-compressed');
  AMIMEList.Add('.a' + '=' + 'application/x-archive');
  AMIMEList.Add('.aab' + '=' + 'application/x-authorware-bin');
  AMIMEList.Add('.aac' + '=' + 'audio/aac');
  AMIMEList.Add('.aam' + '=' + 'application/x-authorware-map');
  AMIMEList.Add('.aas' + '=' + 'application/x-authorware-seg');
  AMIMEList.Add('.abw' + '=' + 'application/x-abiword');
  AMIMEList.Add('.ace' + '=' + 'application/x-ace-compressed');
  AMIMEList.Add('.ai' + '=' + 'application/postscript');
  AMIMEList.Add('.aif' + '=' + 'audio/x-aiff');
  AMIMEList.Add('.aifc' + '=' + 'audio/x-aiff');
  AMIMEList.Add('.aiff' + '=' + 'audio/x-aiff');
  AMIMEList.Add('.alz' + '=' + 'application/x-alz-compressed');
  AMIMEList.Add('.ani' + '=' + 'application/x-navi-animation');
  AMIMEList.Add('.arc' + '=' + 'application/x-freearc');
  AMIMEList.Add('.arj' + '=' + 'application/x-arj');
  AMIMEList.Add('.art' + '=' + 'image/x-jg');
  AMIMEList.Add('.asf' + '=' + 'application/vnd.ms-asf');
  AMIMEList.Add('.asf' + '=' + 'video/x-ms-asf');
  AMIMEList.Add('.asm' + '=' + 'text/x-asm');
  AMIMEList.Add('.asx' + '=' + 'video/x-ms-asf-plugin');
  AMIMEList.Add('.asx' + '=' + 'video/x-ms-asf');
  AMIMEList.Add('.au' + '=' + 'audio/basic');
  AMIMEList.Add('.avi' + '=' + 'video/x-msvideo');
  AMIMEList.Add('.avif' + '=' + 'image/avif');
  AMIMEList.Add('.azw' + '=' + 'application/vnd.amazon.ebook');
  AMIMEList.Add('.bat' + '=' + 'application/x-msdos-program');
  AMIMEList.Add('.bcpio' + '=' + 'application/x-bcpio');
  AMIMEList.Add('.bin' + '=' + 'application/octet-stream');
  AMIMEList.Add('.bmp' + '=' + 'image/bmp');
  AMIMEList.Add('.boz' + '=' + 'application/x-bzip2');
  AMIMEList.Add('.bz' + '=' + 'application/x-bzip');
  AMIMEList.Add('.bz2' + '=' + 'application/x-bzip2');
  AMIMEList.Add('.c' + '=' + 'text/x-csrc');
  AMIMEList.Add('.c++' + '=' + 'text/x-c++src');
  AMIMEList.Add('.cab' + '=' + 'application/vnd.ms-cab-compressed');
  AMIMEList.Add('.cat' + '=' + 'application/vnd.ms-pki.seccat');
  AMIMEList.Add('.cc' + '=' + 'text/x-c++src');
  AMIMEList.Add('.ccn' + '=' + 'application/x-cnc');
  AMIMEList.Add('.cco' + '=' + 'application/x-cocoa');
  AMIMEList.Add('.cda' + '=' + 'application/x-cdf');
  AMIMEList.Add('.cdf' + '=' + 'application/x-cdf');
  AMIMEList.Add('.cdr' + '=' + 'image/x-coreldraw');
  AMIMEList.Add('.cdt' + '=' + 'image/x-coreldrawtemplate');
  AMIMEList.Add('.cer' + '=' + 'application/x-x509-ca-cert');
  AMIMEList.Add('.chm' + '=' + 'application/vnd.ms-htmlhelp');
  AMIMEList.Add('.chrt' + '=' + 'application/vnd.kde.kchart');
  AMIMEList.Add('.cil' + '=' + 'application/vnd.ms-artgalry');
  AMIMEList.Add('.class' + '=' + 'application/java-vm');
  AMIMEList.Add('.clp' + '=' + 'application/x-msclip');
  AMIMEList.Add('.com' + '=' + 'application/x-msdos-program');
  AMIMEList.Add('.cpio' + '=' + 'application/x-cpio');
  AMIMEList.Add('.cpp' + '=' + 'text/x-c++src');
  AMIMEList.Add('.cpt' + '=' + 'application/mac-compactpro');
  AMIMEList.Add('.cpt' + '=' + 'image/x-corelphotopaint');
  AMIMEList.Add('.cqk' + '=' + 'application/x-calquick');
  AMIMEList.Add('.crd' + '=' + 'application/x-mscardfile');
  AMIMEList.Add('.crl' + '=' + 'application/pkix-crl');
  AMIMEList.Add('.cs' + '=' + 'text/x-csharp');
  AMIMEList.Add('.csh' + '=' + 'application/x-csh');
  AMIMEList.Add('.css' + '=' + 'text/css');
  AMIMEList.Add('.csv' + '=' + 'text/csv');
  AMIMEList.Add('.cxx' + '=' + 'text/x-c++src');
  AMIMEList.Add('.dar' + '=' + 'application/x-dar');
  AMIMEList.Add('.dbf' + '=' + 'application/x-dbase');
  AMIMEList.Add('.dcr' + '=' + 'application/x-director');
  AMIMEList.Add('.deb' + '=' + 'application/x-debian-package');
  AMIMEList.Add('.dir' + '=' + 'application/x-director');
  AMIMEList.Add('.dist' + '=' + 'vnd.apple.installer+xml');
  AMIMEList.Add('.distz' + '=' + 'vnd.apple.installer+xml');
  AMIMEList.Add('.djv' + '=' + 'image/vnd.djvu');
  AMIMEList.Add('.djvu' + '=' + 'image/vnd.djvu');
  AMIMEList.Add('.dl' + '=' + 'video/dl');
  AMIMEList.Add('.dll' + '=' + 'application/x-msdos-program');
  AMIMEList.Add('.dmg' + '=' + 'application/x-apple-diskimage');
  AMIMEList.Add('.doc' + '=' + 'application/vnd.ms-word');
  AMIMEList.Add('.docx' + '=' +
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
  AMIMEList.Add('.dot' + '=' + 'application/msword');
  AMIMEList.Add('.dv' + '=' + 'video/dv');
  AMIMEList.Add('.dvi' + '=' + 'application/x-dvi');
  AMIMEList.Add('.dxr' + '=' + 'application/x-director');
  AMIMEList.Add('.ebk' + '=' + 'application/x-expandedbook');
  AMIMEList.Add('.eot' + '=' + 'application/vnd.ms-fontobject');
  AMIMEList.Add('.eps' + '=' + 'application/postscript');
  AMIMEList.Add('.epub' + '=' + 'application/epub+zip');
  AMIMEList.Add('.evy' + '=' + 'application/envoy');
  AMIMEList.Add('.exe' + '=' + 'application/x-msdos-program');
  AMIMEList.Add('.fdf' + '=' + 'application/vnd.fdf');
  AMIMEList.Add('.fif' + '=' + 'application/fractals');
  AMIMEList.Add('.flc' + '=' + 'video/flc');
  AMIMEList.Add('.fli' + '=' + 'video/fli');
  AMIMEList.Add('.flm' + '=' + 'application/vnd.kde.kivio');
  AMIMEList.Add('.fml' + '=' + 'application/x-file-mirror-list');
  AMIMEList.Add('.gif' + '=' + 'image/gif');
  AMIMEList.Add('.gl' + '=' + 'video/gl');
  AMIMEList.Add('.gnumeric' + '=' + 'application/x-gnumeric');
  AMIMEList.Add('.gsm' + '=' + 'audio/x-gsm');
  AMIMEList.Add('.gtar' + '=' + 'application/x-gtar');
  AMIMEList.Add('.gz' + '=' + 'application/gzip');
  AMIMEList.Add('.gzip' + '=' + 'application/x-gzip');
  AMIMEList.Add('.h' + '=' + 'text/x-chdr');
  AMIMEList.Add('.h++' + '=' + 'text/x-c++hdr');
  AMIMEList.Add('.hdf' + '=' + 'application/x-hdf');
  AMIMEList.Add('.hh' + '=' + 'text/x-c++hdr');
  AMIMEList.Add('.hlp' + '=' + 'application/winhlp');
  AMIMEList.Add('.hpf' + '=' + 'application/x-icq-hpf');
  AMIMEList.Add('.hpp' + '=' + 'text/x-c++hdr');
  AMIMEList.Add('.hqx' + '=' + 'application/mac-binhex40');
  AMIMEList.Add('.hta' + '=' + 'application/hta');
  AMIMEList.Add('.htc' + '=' + 'text/x-component');
  AMIMEList.Add('.htm' + '=' + 'text/html');
  AMIMEList.Add('.html' + '=' + 'text/html');
  AMIMEList.Add('.htt' + '=' + 'text/webviewhtml');
  AMIMEList.Add('.hxx' + '=' + 'text/x-c++hdr');
  AMIMEList.Add('.ico' + '=' + 'image/vnd.microsoft.icon');
  AMIMEList.Add('.ics' + '=' + 'text/calendar');
  AMIMEList.Add('.ief' + '=' + 'image/ief');
  AMIMEList.Add('.iii' + '=' + 'application/x-iphone');
  AMIMEList.Add('.ims' + '=' + 'application/vnd.ms-ims');
  AMIMEList.Add('.ins' + '=' + 'application/x-internet-signup');
  AMIMEList.Add('.iso' + '=' + 'application/x-iso9660-image');
  AMIMEList.Add('.ivf' + '=' + 'video/x-ivf');
  AMIMEList.Add('.jar' + '=' + 'application/java-archive');
  AMIMEList.Add('.java' + '=' + 'text/x-java');
  AMIMEList.Add('.jng' + '=' + 'image/x-jng');
  AMIMEList.Add('.jpe' + '=' + 'image/jpeg');
  AMIMEList.Add('.jpeg' + '=' + 'image/jpeg');
  AMIMEList.Add('.jpg' + '=' + 'image/jpeg');
  AMIMEList.Add('.js' + '=' + 'text/javascript');
  AMIMEList.Add('.json' + '=' + 'application/json');
  AMIMEList.Add('.jsonld' + '=' + 'application/ld+json');
  AMIMEList.Add('.kar' + '=' + 'audio/midi');
  AMIMEList.Add('.karbon' + '=' + 'application/vnd.kde.karbon');
  AMIMEList.Add('.kfo' + '=' + 'application/vnd.kde.kformula');
  AMIMEList.Add('.kon' + '=' + 'application/vnd.kde.kontour');
  AMIMEList.Add('.kpr' + '=' + 'application/vnd.kde.kpresenter');
  AMIMEList.Add('.kpt' + '=' + 'application/vnd.kde.kpresenter');
  AMIMEList.Add('.kwd' + '=' + 'application/vnd.kde.kword');
  AMIMEList.Add('.kwt' + '=' + 'application/vnd.kde.kword');
  AMIMEList.Add('.latex' + '=' + 'application/x-latex');
  AMIMEList.Add('.lcc' + '=' + 'application/fastman');
  AMIMEList.Add('.lha' + '=' + 'application/x-lzh');
  AMIMEList.Add('.lrm' + '=' + 'application/vnd.ms-lrm');
  AMIMEList.Add('.ls' + '=' + 'text/javascript');
  AMIMEList.Add('.lsf' + '=' + 'video/x-la-asf');
  AMIMEList.Add('.lsx' + '=' + 'video/x-la-asf');
  AMIMEList.Add('.lz' + '=' + 'application/x-lzip');
  AMIMEList.Add('.lzh' + '=' + 'application/x-lzh');
  AMIMEList.Add('.lzma' + '=' + 'application/x-lzma');
  AMIMEList.Add('.lzo' + '=' + 'application/x-lzop');
  AMIMEList.Add('.lzx' + '=' + 'application/x-lzx');
  AMIMEList.Add('.m13' + '=' + 'application/x-msmediaview');
  AMIMEList.Add('.m14' + '=' + 'application/x-msmediaview');
  AMIMEList.Add('.m3u' + '=' + 'audio/mpegurl');
  AMIMEList.Add('.m4a' + '=' + 'audio/x-mpg');
  AMIMEList.Add('.man' + '=' + 'application/x-troff-man');
  AMIMEList.Add('.mdb' + '=' + 'application/x-msaccess');
  AMIMEList.Add('.me' + '=' + 'application/x-troff-me');
  AMIMEList.Add('.mht' + '=' + 'message/rfc822');
  AMIMEList.Add('.mid' + '=' + 'audio/midi');
  AMIMEList.Add('.midi' + '=' + 'audio/x-midi');
  AMIMEList.Add('.mjf' + '=' + 'audio/x-vnd.AudioExplosion.MjuiceMediaFile');
  AMIMEList.Add('.mjs' + '=' + 'text/javascript');
  AMIMEList.Add('.mng' + '=' + 'video/x-mng');
  AMIMEList.Add('.mny' + '=' + 'application/x-msmoney');
  AMIMEList.Add('.mocha' + '=' + 'text/javascript');
  AMIMEList.Add('.moov' + '=' + 'video/quicktime');
  AMIMEList.Add('.mov' + '=' + 'video/quicktime');
  AMIMEList.Add('.movie' + '=' + 'video/x-sgi-movie');
  AMIMEList.Add('.mp2' + '=' + 'audio/x-mpg');
  AMIMEList.Add('.mp2' + '=' + 'video/mpeg');
  AMIMEList.Add('.mp3' + '=' + 'audio/mpeg');
  AMIMEList.Add('.mp3' + '=' + 'video/mpeg');
  AMIMEList.Add('.mp4' + '=' + 'video/mp4');
  AMIMEList.Add('.mp4' + '=' + 'video/mpeg');
  AMIMEList.Add('.mpa' + '=' + 'video/mpeg');
  AMIMEList.Add('.mpe' + '=' + 'video/mpeg');
  AMIMEList.Add('.mpeg' + '=' + 'video/mpeg');
  AMIMEList.Add('.mpega' + '=' + 'audio/x-mpg');
  AMIMEList.Add('.mpg' + '=' + 'video/mpeg');
  AMIMEList.Add('.mpga' + '=' + 'audio/x-mpg');
  AMIMEList.Add('.mpkg' + '=' + 'application/vnd.apple.installer+xml');
  AMIMEList.Add('.mpp' + '=' + 'application/vnd.ms-project');
  AMIMEList.Add('.ms' + '=' + 'application/x-troff-ms');
  AMIMEList.Add('.msi' + '=' + 'application/x-msi');
  AMIMEList.Add('.mvb' + '=' + 'application/x-msmediaview');
  AMIMEList.Add('.mxu' + '=' + 'video/vnd.mpegurl');
  AMIMEList.Add('.nix' + '=' + 'application/x-mix-transfer');
  AMIMEList.Add('.nml' + '=' + 'animation/narrative');
  AMIMEList.Add('.o' + '=' + 'application/x-object');
  AMIMEList.Add('.oda' + '=' + 'application/oda');
  AMIMEList.Add('.odb' + '=' + 'application/vnd.oasis.opendocument.database');
  AMIMEList.Add('.odc' + '=' + 'application/vnd.oasis.opendocument.chart');
  AMIMEList.Add('.odf' + '=' + 'application/vnd.oasis.opendocument.formula');
  AMIMEList.Add('.odg' + '=' + 'application/vnd.oasis.opendocument.graphics');
  AMIMEList.Add('.odi' + '=' + 'application/vnd.oasis.opendocument.image');
  AMIMEList.Add('.odm' + '=' +
    'application/vnd.oasis.opendocument.text-master');
  AMIMEList.Add('.odp' + '=' +
    'application/vnd.oasis.opendocument.presentation');
  AMIMEList.Add('.ods' + '=' +
    'application/vnd.oasis.opendocument.spreadsheet');
  AMIMEList.Add('.odt' + '=' + 'application/vnd.oasis.opendocument.text');
  AMIMEList.Add('.oga' + '=' + 'audio/ogg');
  AMIMEList.Add('.ogg' + '=' + 'application/ogg');
  AMIMEList.Add('.ogv' + '=' + 'video/ogg');
  AMIMEList.Add('.ogx' + '=' + 'application/ogg');
  AMIMEList.Add('.opus' + '=' + 'audio/opus');
  AMIMEList.Add('.otf' + '=' + 'font/otf');
  AMIMEList.Add('.otg' + '=' +
    'application/vnd.oasis.opendocument.graphics-template');
  AMIMEList.Add('.oth' + '=' + 'application/vnd.oasis.opendocument.text-web');
  AMIMEList.Add('.otp' + '=' +
    'application/vnd.oasis.opendocument.presentation-template');
  AMIMEList.Add('.ots' + '=' +
    'application/vnd.oasis.opendocument.spreadsheet-template');
  AMIMEList.Add('.ott' + '=' +
    'application/vnd.oasis.opendocument.text-template');
  AMIMEList.Add('.p' + '=' + 'text/x-pascal');
  AMIMEList.Add('.p10' + '=' + 'application/pkcs10');
  AMIMEList.Add('.p12' + '=' + 'application/x-pkcs12');
  AMIMEList.Add('.p7b' + '=' + 'application/x-pkcs7-certificates');
  AMIMEList.Add('.p7m' + '=' + 'application/pkcs7-mime');
  AMIMEList.Add('.p7r' + '=' + 'application/x-pkcs7-certreqresp');
  AMIMEList.Add('.p7s' + '=' + 'application/pkcs7-signature');
  AMIMEList.Add('.package' + '=' + 'application/vnd.autopackage');
  AMIMEList.Add('.pas' + '=' + 'text/x-pascal');
  AMIMEList.Add('.pat' + '=' + 'image/x-coreldrawpattern');
  AMIMEList.Add('.pbm' + '=' + 'image/x-portable-bitmap');
  AMIMEList.Add('.pcx' + '=' + 'image/pcx');
  AMIMEList.Add('.pdf' + '=' + 'application/pdf');
  AMIMEList.Add('.pfr' + '=' + 'application/font-tdpfr');
  AMIMEList.Add('.pgm' + '=' + 'image/x-portable-graymap');
  AMIMEList.Add('.php' + '=' + 'application/x-httpd-php');
  AMIMEList.Add('.pict' + '=' + 'image/x-pict');
  AMIMEList.Add('.pkg' + '=' + 'vnd.apple.installer+xml');
  AMIMEList.Add('.pko' + '=' + 'application/vnd.ms-pki.pko');
  AMIMEList.Add('.pl' + '=' + 'application/x-perl');
  AMIMEList.Add('.pls' + '=' + 'audio/x-scpls');
  AMIMEList.Add('.png' + '=' + 'image/png');
  AMIMEList.Add('.pnm' + '=' + 'image/x-portable-anymap');
  AMIMEList.Add('.pnq' + '=' + 'application/x-icq-pnq');
  AMIMEList.Add('.pntg' + '=' + 'image/x-macpaint');
  AMIMEList.Add('.pot' + '=' + 'application/mspowerpoint');
  AMIMEList.Add('.ppm' + '=' + 'image/x-portable-pixmap');
  AMIMEList.Add('.pps' + '=' + 'application/mspowerpoint');
  AMIMEList.Add('.ppt' + '=' + 'application/vnd.ms-powerpoint');
  AMIMEList.Add('.pptx' + '=' +
    'application/vnd.openxmlformats-officedocument.presentationml.presentation');
  AMIMEList.Add('.ppz' + '=' + 'application/mspowerpoint');
  AMIMEList.Add('.ps' + '=' + 'application/postscript');
  AMIMEList.Add('.psd' + '=' + 'image/x-psd');
  AMIMEList.Add('.pub' + '=' + 'application/x-mspublisher');
  AMIMEList.Add('.qcp' + '=' + 'audio/vnd.qcelp');
  AMIMEList.Add('.qpw' + '=' + 'application/x-quattropro');
  AMIMEList.Add('.qt' + '=' + 'video/quicktime');
  AMIMEList.Add('.qtc' + '=' + 'video/x-qtc');
  AMIMEList.Add('.qtif' + '=' + 'image/x-quicktime');
  AMIMEList.Add('.qtl' + '=' + 'application/x-quicktimeplayer');
  AMIMEList.Add('.ra' + '=' + 'audio/x-realaudio');
  AMIMEList.Add('.ram' + '=' + 'audio/x-pn-realaudio');
  AMIMEList.Add('.rar' + '=' + 'application/vnd.rar');
  AMIMEList.Add('.ras' + '=' + 'image/x-cmu-raster');
  AMIMEList.Add('.rdf' + '=' + 'application/rdf+xml');
  AMIMEList.Add('.rf' + '=' + 'image/vnd.rn-realflash');
  AMIMEList.Add('.rgb' + '=' + 'image/x-rgb');
  AMIMEList.Add('.rjs' + '=' + 'application/vnd.rn-realsystem-rjs');
  AMIMEList.Add('.rm' + '=' + 'application/vnd.rn-realmedia');
  AMIMEList.Add('.rmf' + '=' + 'application/vnd.rmf');
  AMIMEList.Add('.rmp' + '=' + 'application/vnd.rn-rn_music_package');
  AMIMEList.Add('.rms' + '=' + 'video/vnd.rn-realvideo-secure');
  AMIMEList.Add('.rmx' + '=' + 'application/vnd.rn-realsystem-rmx');
  AMIMEList.Add('.rnx' + '=' + 'application/vnd.rn-realplayer');
  AMIMEList.Add('.rp' + '=' + 'image/vnd.rn-realpix');
  AMIMEList.Add('.rpm' + '=' + 'application/x-redhat-package-manager');
  AMIMEList.Add('.rsml' + '=' + 'application/vnd.rn-rsml');
  AMIMEList.Add('.rss' + '=' + 'application/rss+xml');
  AMIMEList.Add('.rt' + '=' + 'text/vnd.rn-realtext');
  AMIMEList.Add('.rtf' + '=' + 'application/rtf');
  AMIMEList.Add('.rtsp' + '=' + 'application/x-rtsp');
  AMIMEList.Add('.rtx' + '=' + 'text/richtext');
  AMIMEList.Add('.rv' + '=' + 'video/vnd.rn-realvideo');
  AMIMEList.Add('.scd' + '=' + 'application/x-msschedule');
  AMIMEList.Add('.scm' + '=' + 'application/x-icq-scm');
  AMIMEList.Add('.sd2' + '=' + 'audio/x-sd2');
  AMIMEList.Add('.sda' + '=' + 'application/vnd.stardivision.draw');
  AMIMEList.Add('.sdc' + '=' + 'application/vnd.stardivision.calc');
  AMIMEList.Add('.sdd' + '=' + 'application/vnd.stardivision.impress');
  AMIMEList.Add('.sdp' + '=' + 'application/x-sdp');
  AMIMEList.Add('.ser' + '=' + 'application/java-serialized-object');
  AMIMEList.Add('.setpay' + '=' + 'application/set-payment-initiation');
  AMIMEList.Add('.setreg' + '=' + 'application/set-registration-initiation');
  AMIMEList.Add('.sgi' + '=' + 'image/x-sgi');
  AMIMEList.Add('.sgm' + '=' + 'text/sgml');
  AMIMEList.Add('.sgml' + '=' + 'text/sgml');
  AMIMEList.Add('.sh' + '=' + 'application/x-sh');
  AMIMEList.Add('.shar' + '=' + 'application/x-shar');
  AMIMEList.Add('.shtml' + '=' + 'server-parsed-html');
  AMIMEList.Add('.shw' + '=' + 'application/presentations');
  AMIMEList.Add('.sid' + '=' + 'audio/prs.sid');
  AMIMEList.Add('.sit' + '=' + 'application/x-stuffit');
  AMIMEList.Add('.sitx' + '=' + 'application/x-stuffitx');
  AMIMEList.Add('.skd' + '=' + 'application/x-koan');
  AMIMEList.Add('.skm' + '=' + 'application/x-koan');
  AMIMEList.Add('.skp' + '=' + 'application/x-koan');
  AMIMEList.Add('.skt' + '=' + 'application/x-koan');
  AMIMEList.Add('.smf' + '=' + 'application/vnd.stardivision.math');
  AMIMEList.Add('.smi' + '=' + 'application/smil');
  AMIMEList.Add('.smil' + '=' + 'application/smil');
  AMIMEList.Add('.snd' + '=' + 'audio/basic');
  AMIMEList.Add('.spl' + '=' + 'application/futuresplash');
  AMIMEList.Add('.ssm' + '=' + 'application/streamingmedia');
  AMIMEList.Add('.sst' + '=' + 'application/vnd.ms-pki.certstore');
  AMIMEList.Add('.stc' + '=' + 'application/vnd.sun.xml.calc.template');
  AMIMEList.Add('.std' + '=' + 'application/vnd.sun.xml.draw.template');
  AMIMEList.Add('.sti' + '=' + 'application/vnd.sun.xml.impress.template');
  AMIMEList.Add('.stl' + '=' + 'application/vnd.ms-pki.stl');
  AMIMEList.Add('.stw' + '=' + 'application/vnd.sun.xml.writer.template');
  AMIMEList.Add('.sv4cpio' + '=' + 'application/x-sv4cpio');
  AMIMEList.Add('.sv4crc' + '=' + 'application/x-sv4crc');
  AMIMEList.Add('.svg' + '=' + 'image/svg+xml');
  AMIMEList.Add('.svgz' + '=' + 'image/svg+xml');
  AMIMEList.Add('.svi' + '=' + 'application/softvision');
  AMIMEList.Add('.swf' + '=' + 'application/x-shockwave-flash');
  AMIMEList.Add('.swf1' + '=' + 'application/x-shockwave-flash');
  AMIMEList.Add('.sxc' + '=' + 'application/vnd.sun.xml.calc');
  AMIMEList.Add('.sxg' + '=' + 'application/vnd.sun.xml.writer.global');
  AMIMEList.Add('.sxi' + '=' + 'application/vnd.sun.xml.impress');
  AMIMEList.Add('.sxm' + '=' + 'application/vnd.sun.xml.math');
  AMIMEList.Add('.sxw' + '=' + 'application/vnd.sun.xml.writer');
  AMIMEList.Add('.t' + '=' + 'application/x-troff');
  AMIMEList.Add('.tar' + '=' + 'application/x-tar');
  AMIMEList.Add('.targa' + '=' + 'image/x-targa');
  AMIMEList.Add('.tbz' + '=' + 'application/x-bzip-compressed-tar');
  AMIMEList.Add('.tbz2' + '=' + 'application/x-bzip-compressed-tar');
  AMIMEList.Add('.tcl' + '=' + 'application/x-tcl');
  AMIMEList.Add('.tex' + '=' + 'application/x-tex');
  AMIMEList.Add('.texi' + '=' + 'application/x-texinfo');
  AMIMEList.Add('.texinfo' + '=' + 'application/x-texinfo');
  AMIMEList.Add('.tgz' + '=' + 'application/x-compressed-tar');
  AMIMEList.Add('.tif' + '=' + 'image/tiff');
  AMIMEList.Add('.tiff' + '=' + 'image/tiff');
  AMIMEList.Add('.tlz' + '=' + 'application/x-lzma-compressed-tar');
  AMIMEList.Add('.torrent' + '=' + 'application/x-bittorrent');
  AMIMEList.Add('.tr' + '=' + 'application/x-troff');
  AMIMEList.Add('.trm' + '=' + 'application/x-msterminal');
  AMIMEList.Add('.troff' + '=' + 'application/x-troff');
  AMIMEList.Add('.ts' + '=' + 'video/mp2t');
  AMIMEList.Add('.tsp' + '=' + 'application/dsptype');
  AMIMEList.Add('.ttf' + '=' + 'font/ttf');
  AMIMEList.Add('.ttz' + '=' + 'application/t-time');
  AMIMEList.Add('.txt' + '=' + 'text/plain');
  AMIMEList.Add('.txz' + '=' + 'application/x-xz-compressed-tar');
  AMIMEList.Add('.udeb' + '=' + 'application/x-debian-package');
  AMIMEList.Add('.uin' + '=' + 'application/x-icq');
  AMIMEList.Add('.uls' + '=' + 'text/iuls');
  AMIMEList.Add('.urls' + '=' + 'application/x-url-list');
  AMIMEList.Add('.ustar' + '=' + 'application/x-ustar');
  AMIMEList.Add('.vcd' + '=' + 'application/x-cdlink');
  AMIMEList.Add('.vcf' + '=' + 'text/x-vcard');
  AMIMEList.Add('.vor' + '=' + 'application/vnd.stardivision.writer');
  AMIMEList.Add('.vsd' + '=' + 'application/vnd.visio');
  AMIMEList.Add('.vsl' + '=' + 'application/x-cnet-vsl');
  AMIMEList.Add('.wav' + '=' + 'audio/wav');
  AMIMEList.Add('.wax' + '=' + 'audio/x-ms-wax');
  AMIMEList.Add('.wb1' + '=' + 'application/x-quattropro');
  AMIMEList.Add('.wb2' + '=' + 'application/x-quattropro');
  AMIMEList.Add('.wb3' + '=' + 'application/x-quattropro');
  AMIMEList.Add('.wbmp' + '=' + 'image/vnd.wap.wbmp');
  AMIMEList.Add('.wcm' + '=' + 'application/vnd.ms-works');
  AMIMEList.Add('.wdb' + '=' + 'application/vnd.ms-works');
  AMIMEList.Add('.weba' + '=' + 'audio/webm');
  AMIMEList.Add('.webm' + '=' + 'video/webm');
  AMIMEList.Add('.webp' + '=' + 'image/webp');
  AMIMEList.Add('.wks' + '=' + 'application/vnd.ms-works');
  AMIMEList.Add('.wm' + '=' + 'video/x-ms-wm');
  AMIMEList.Add('.wma' + '=' + 'audio/x-ms-wma');
  AMIMEList.Add('.wmd' + '=' + 'application/x-ms-wmd');
  AMIMEList.Add('.wml' + '=' + 'text/vnd.wap.wml');
  AMIMEList.Add('.wmlc' + '=' + 'application/vnd.wap.wmlc');
  AMIMEList.Add('.wmls' + '=' + 'text/vnd.wap.wmlscript');
  AMIMEList.Add('.wmlsc' + '=' + 'application/vnd.wap.wmlscriptc');
  AMIMEList.Add('.wmp' + '=' + 'video/x-ms-wmp');
  AMIMEList.Add('.wms' + '=' + 'application/x-ms-wms');
  AMIMEList.Add('.wmv' + '=' + 'video/x-ms-wmv');
  AMIMEList.Add('.wmx' + '=' + 'video/x-ms-wmx');
  AMIMEList.Add('.wmz' + '=' + 'application/x-ms-wmz');
  AMIMEList.Add('.woff' + '=' + 'font/woff');
  AMIMEList.Add('.woff2' + '=' + 'font/woff2');
  AMIMEList.Add('.wp5' + '=' + 'application/wordperfect5.1');
  AMIMEList.Add('.wpd' + '=' + 'application/wordperfect');
  AMIMEList.Add('.wpl' + '=' + 'application/vnd.ms-wpl');
  AMIMEList.Add('.wps' + '=' + 'application/vnd.ms-works');
  AMIMEList.Add('.wri' + '=' + 'application/x-mswrite');
  AMIMEList.Add('.wsc' + '=' + 'text/scriptlet');
  AMIMEList.Add('.wvx' + '=' + 'video/x-ms-wvx');
  AMIMEList.Add('.xbm' + '=' + 'image/x-xbitmap');
  AMIMEList.Add('.xfdf' + '=' + 'application/vnd.adobe.xfdf');
  AMIMEList.Add('.xht' + '=' + 'application/xhtml+xml');
  AMIMEList.Add('.xhtml' + '=' + 'application/xhtml+xml');
  AMIMEList.Add('.xlb' + '=' + 'application/x-msexcel');
  AMIMEList.Add('.xls' + '=' + 'application/vnd.ms-excel');
  AMIMEList.Add('.xlsx' + '=' +
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  AMIMEList.Add('.xml' + '=' + 'application/xml');
  AMIMEList.Add('.xpi' + '=' + 'application/x-xpinstall');
  AMIMEList.Add('.xpm' + '=' + 'image/x-xpixmap');
  AMIMEList.Add('.xps' + '=' + 'application/vnd.ms-xpsdocument');
  AMIMEList.Add('.xsd' + '=' + 'application/vnd.sun.xml.draw');
  AMIMEList.Add('.xul' + '=' + 'application/vnd.mozilla.xul+xml');
  AMIMEList.Add('.xwd' + '=' + 'image/x-xwindowdump');
  AMIMEList.Add('.z' + '=' + 'application/x-compress');
  AMIMEList.Add('.zip' + '=' + 'application/zip');
  AMIMEList.Add('.zoo' + '=' + 'application/x-zoo');
  AMIMEList.EndUpdate;
end;

function TRESTDWMIMEType.GetDefaultFileExt(const MIMEType: string): string;
var
  Index: integer;
  LMimeType: string;
begin
  LMimeType := LowerCase(MIMEType);
  Index := FMIMEList.IndexOf(LMimeType);
  if (Index = -1) and (FMIMEList.Count = 0) then
  begin
    BuildCache;
    Index := FMIMEList.IndexOf(LMimeType);
  end;
  if Index <> -1 then
    Result := FMIMEList.Names[Index]
  else
    Result := ''; { Do not Localize }
end;

function TRESTDWMIMEType.GetFileMIMEType(const AFileName: string): string;
var
  Index: integer;
  LExt: string;
begin
  LExt := LowerCase(ExtractFileExt(AFileName));
  Index := FMIMEList.IndexOfName(LExt);
  if (Index = -1) and (FMIMEList.Count = 0) then
  begin
    BuildCache;
    Index := FMIMEList.IndexOf(LExt);
  end;
  if Index <> -1 then
    Result := FMIMEList.ValueFromIndex[Index]
  else
    Result := 'application/octet-stream'; { do not localize }
end;

procedure TRESTDWMIMEType.GetMIMETableFromOS(const AMIMEList: TStringList);
{$IFDEF RESTDWWINDOWS}
var
  reg: TRegistry;
  KeyList: TStringList;
  I: integer;
  S, LExt: string;
{$ENDIF}
begin
{$IFNDEF RESTDWWINDOWS}
  Exit;
{$ELSE}
  AMIMEList.Sorted := False;
  // Build the file type/MIME type map
  reg := TRegistry.Create;
  try
    KeyList := TStringList.Create;
    try
      reg.RootKey := HKEY_CLASSES_ROOT;
      if reg.OpenKeyReadOnly('\') then
      begin { do not localize }
        reg.GetKeyNames(KeyList);
        reg.Closekey;
      end;
      // get a list of registered extentions
      for I := 0 to KeyList.Count - 1 do
      begin
        LExt := KeyList.Strings[I];
        if copy(LExt, 0, 1) = '.' then
        begin { do not localize }
          if reg.OpenKeyReadOnly(LExt) then
          begin
            S := reg.ReadString('Content Type'); { do not localize }
            if Length(S) > 0 then
              AMIMEList.Values[LowerCase(LExt)] := LowerCase(S);
            reg.Closekey;
          end;
        end;
      end;
      if reg.OpenKeyReadOnly('\MIME\Database\Content Type') then
      begin { do not localize }
        // get a list of registered MIME types
        KeyList.Clear;
        reg.GetKeyNames(KeyList);
        reg.Closekey;
        for I := 0 to KeyList.Count - 1 do
        begin
          if reg.OpenKeyReadOnly('\MIME\Database\Content Type\' + KeyList[I])
          then
          begin { do not localize }
            LExt := LowerCase(reg.ReadString('Extension'));
            { do not localize }
            if Length(LExt) > 0 then
            begin
              if LExt[1] <> '.' then
                LExt := '.' + LExt; { do not localize }
              AMIMEList.Values[LExt] := LowerCase(KeyList[I]);
            end;
            reg.Closekey;
          end;
        end;
      end;
    finally
      KeyList.Free;
    end;
  finally
    reg.Free;
    AMIMEList.Sort;
    AMIMEList.Sorted := True;
  end;
{$ENDIF}
end;

class function TRESTDWMIMEType.GetMIMEType(aFile: TFileName): string;
Var
  Mime: TRESTDWMIMEType;
Begin
  Mime := TRESTDWMIMEType.Create();
  try
    Result := Mime.GetFileMIMEType(aFile);
  finally
    Mime.Free
  end;
end;

class function TRESTDWMIMEType.GetMIMETypeExt(aMIMEType: string): string;
Var
  MIMEMap: TRESTDWMIMEType;
Begin
  MIMEMap := TRESTDWMIMEType.Create(True);
  Try
    Result := MIMEMap.GetDefaultFileExt(aMIMEType);
  Finally
    MIMEMap.Free;
  End;
end;

procedure TRESTDWMIMEType.LoadFromStrings(const AStrings: TStringList);
begin
  initializestrings;
  if AStrings <> nil then
    try
      FMIMEList.BeginUpdate;
      FMIMEList.Clear;
      FMIMEList.Assign(AStrings);
    finally
      FMIMEList.EndUpdate;
      FMIMEList.Sort;
      FMIMEList.Sorted := True;
    end;
end;

procedure TRESTDWMIMEType.SaveToStrings(const AStrings: TStringList);
begin
  Assert(AStrings <> nil);
  AStrings.BeginUpdate;
  try
    AStrings.Clear;
    AStrings.Assign(FMIMEList);
  finally
    AStrings.EndUpdate;
  end;
end;

end.
