unit uRESTDWMemResources;

{$I ..\..\Includes\uRESTDW.inc}

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
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface
//=== used in several files ==================================================
resourcestring
  RsENoCharset = 'No matching charset';
  RsELibraryNotFound  = 'Library not found: %s';
  RsEFunctionNotFound = 'Function not found: %s.%s';
  RsWin32Error        = 'Win32 error: %s (%u)%s%s';
  RsButtonOKCaption = '&OK';
  RsButtonCancelCaption = 'Cancel';
  RsBackButtonCaption = '< &Back';
  RsPrevButtonCaption = '< &Prev';
  RsNextButtonCaption = '&Next >';
  RsDateDlgCaption = 'Select a Date';
  RsDetailsLeftCaption = '<< &Details';
  RsDetailsRightCaption = '&Details >>';
  RsUndoItem = '&Undo';
  RsCutItem = 'Cu&t';
  RsCopyItem = '&Copy';
  RsPasteItem = '&Paste';
  RsDeleteItem = '&Delete';
  RsSelectAllItem = 'Select &All';
  RsCantConvertAddr64  = 'The address %s%.16x cannot be converted to 32 bit';
  RsEReplacementChar   = 'Failed to get ANSI replacement character';
  RsEUnexpectedEOSeq   = 'Unexpected end of sequence';
  RsEmptyItem = '<Empty>';
  RsNoName = '(unnamed)';
  RsDatabaseName = 'Database name: %s';
  RsDataItemRenderHasNoText = '(item does not support the IJvDataItemText interface)';
  RsError = 'Error';
  RsFalse = 'False';
  RsTrue = 'True';
  RsEErrorSetupDll = 'SetupApi.dll not found';
  RsEInternalError = 'internal error';
  RsEUnterminatedStringNears = 'unterminated string near %s';
  RsEStackOverflow = 'stack overflow';
  RsEStackUnderflow = 'stack underflow';
  RsEReturnStackUnderflow = 'return stack underflow';
  RsENotImplemented = 'not implemented';
  RsEDelSubTreeNotImplemented = 'DeleteSubTreeInt has not been implemented yet';
  { Polaris patch }
  RsEDateOutOfRange = '%0:s - Enter a date between "%1:s" and "%2:s"';
  RsEDateOutOfMin = '%0:s - Enter a date after "%1:s"';
  RsEDateOutOfMax = '%0:s - Enter a date before "%1:s"';
  RsEID3NoController = 'No controller specified';
  RsEReturnStackOverflow = 'return stack overflow';
  RsESorryForOneDimensionalArraysOnly = 'Sorry, for one-dimensional arrays only';
  RsELocalDatabase = 'Cannot perform this operation on a local database';
  RsEInterfaceNotSupported = '%0:s does not support the %1:s interface';
  RsECircularReference = 'Circular reference not allowed';
  RsESourceBitmapTooSmall = 'Source bitmap too small';
  RsIntelCacheDescr00 = 'Null descriptor';
  RsIntelCacheDescr01 = 'Instruction TLB: 4 KByte pages, 4-way set associative, 32 entries';
  RsIntelCacheDescr02 = 'Instruction TLB: 4 MByte pages, 4-way set associative, 2 entries';
  RsIntelCacheDescr03 = 'Data TLB: 4 KByte pages, 4-way set associative, 64 entries';
  RsIntelCacheDescr04 = 'Data TLB: 4 MByte pages, 4-way set associative, 8 entries';
  RsIntelCacheDescr05 = 'Data TLB1: 4 MByte pages, 4-way set associative, 32 entries';
  RsIntelCacheDescr06 = '1st level instruction cache: 8 KBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr08 = '1st level instruction cache: 16 KBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr09 = '1st level instruction cache: 32 KBytes, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr0A = '1st level data cache: 8 KBytes, 2-way set associative, 32 byte line size';
  RsIntelCacheDescr0B = 'Instruction TLB: 4 MByte pages, 4-way set associative, 4 entries';
  RsIntelCacheDescr0C = '1st level data cache: 16 KBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr0D = '1st level data cache: 16 KBytes, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr0E = '1st level data cache: 24 KBytes, 6-way set associative, 64 byte line size';
  RsIntelCacheDescr21 = '2nd level cache: 256 KBytes, 8-way set associative, 64 byte line size';
  RsIntelCacheDescr22 = '3rd level cache: 512 KBytes, 4-way set associative, 64 byte line size, 2 lines per sector';
  RsIntelCacheDescr23 = '3rd level cache: 1 MBytes, 8-way set associative, 64 byte line size, 2 lines per sector';
  RsIntelCacheDescr25 = '3rd level cache: 2 MBytes, 8-way set associative, 64 byte line size, 2 lines per sector';
  RsIntelCacheDescr29 = '3rd level cache: 4 MBytes, 8-way set associative, 64 byte line size, 2 lines per sector';
  RsIntelCacheDescr2C = '1st level data cache: 32 KBytes, 8-way set associative, 64 byte line size';
  RsIntelCacheDescr30 = '1st level instruction cache: 32 KBytes, 8-way set associative, 64 byte line size';
  RsIntelCacheDescr39 = '2nd-level cache: 128 KBytes, 4-way set associative, sectored cache, 64-byte line size';
  RsIntelCacheDescr3A = '2nd-level cache: 192 KBytes, 6-way set associative, sectored cache, 64-byte line size';
  RsIntelCacheDescr3B = '2nd-level cache: 128 KBytes, 2-way set associative, sectored cache, 64-byte line size';
  RsIntelCacheDescr3C = '2nd-level cache: 256 KBytes, 4-way set associative, sectored cache, 64-byte line size';
  RsIntelCacheDescr3D = '2nd-level cache: 384 KBytes, 6-way set associative, sectored cache, 64-byte line size';
  RsIntelCacheDescr3E = '2nd-level cache: 512 KBytes, 4-way set associative, sectored cache, 64-byte line size';
  RsIntelCacheDescr40 = 'No 2nd-level cache or, if processor contains a valid 2nd-level cache, no 3rd-level cache';
  RsIntelCacheDescr41 = '2nd-level cache: 128 KBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr42 = '2nd-level cache: 256 KBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr43 = '2nd-level cache: 512 KBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr44 = '2nd-level cache: 1 MBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr45 = '2nd-level cache: 2 MBytes, 4-way set associative, 32 byte line size';
  RsIntelCacheDescr46 = '3rd-level cache: 4 MBytes, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr47 = '3rd-level cache: 8 MBytes, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr48 = '3rd-level cache: 8 MByte, 8-way set associative, 64 byte line size';
  RsIntelCacheDescr49 = '2nd-level cache: 4 MBytes, 16-way set associative, 64 byte line size';
  RsIntelCacheDescr4A = '3rd-level cache: 6MByte, 12-way set associative, 64 byte line size';
  RsIntelCacheDescr4B = '3rd-level cache: 8MByte, 16-way set associative, 64 byte line size';
  RsIntelCacheDescr4C = '3rd-level cache: 12MByte, 12-way set associative, 64 byte line size';
  RsIntelCacheDescr4D = '3rd-level cache: 16MByte, 16-way set associative, 64 byte line size';
  RsIntelCacheDescr4E = '2nd-level cache: 6MByte, 24-way set associative, 64 byte line size';
  RsIntelCacheDescr4F = 'Instruction TLB: 4 KByte pages, 32 Entries';
  RsIntelCacheDescr50 = 'Instruction TLB: 4 KByte and 2 MByte or 4 MByte pages, 64 Entries';
  RsIntelCacheDescr51 = 'Instruction TLB: 4 KByte and 2 MByte or 4 MByte pages, 128 Entries';
  RsIntelCacheDescr52 = 'Instruction TLB: 4 KByte and 2 MByte or 4 MByte pages, 256 Entries';
  RsIntelCacheDescr55 = 'Instruction TLB: 2-MByte or 4-MByte pages, fully associative, 7 entries';
  RsIntelCacheDescr56 = 'Data TLB0: 4 MByte pages, 4-way set associative, 16 entries';
  RsIntelCacheDescr57 = 'Data TLB0: 4 KByte pages, 4-way associative, 16 entries';
  RsIntelCacheDescr59 = 'Data TLB0: 4 KByte pages, fully associative, 16 entries';
  RsIntelCacheDescr5A = 'Data TLB0: 2 MByte or 4 MByte pages, 4-way set associative, 32 entries';
  RsIntelCacheDescr5B = 'Data TLB: 4 KByte and 4 MByte pages, 64 Entries';
  RsIntelCacheDescr5C = 'Data TLB: 4 KByte and 4 MByte pages, 128 Entries';
  RsIntelCacheDescr5D = 'Data TLB: 4 KByte and 4 MByte pages, 256 Entries';
  RsIntelCacheDescr60 = '1st-level data cache: 16 KByte, 8-way set associative, 64 byte line size';
  RsIntelCacheDescr66 = '1st-level data cache: 8 KBytes, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr67 = '1st-level data cache: 16 KBytes, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr68 = '1st-level data cache: 32 KBytes, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr70 = 'Trace cache: 12 K-Ops, 8-way set associative';
  RsIntelCacheDescr71 = 'Trace cache: 16 K-Ops, 8-way set associative';
  RsIntelCacheDescr72 = 'Trace cache: 32 K-Ops, 8-way set associative';
  RsIntelCacheDescr73 = 'Trace cache: 64 K-Ops, 8-way set associative';
  RsIntelCacheDescr76 = 'Instruction TLB: 2M/4M pages, fully associative, 8 entries';
  RsIntelCacheDescr78 = '2nd-level cache: 1 MBytes, 4-way set associative, 64 bytes line size';
  RsIntelCacheDescr79 = '2nd-level cache: 128 KBytes, 8-way set associative, 64 bytes line size, 2 lines per sector';
  RsIntelCacheDescr7A = '2nd-level cache: 256 KBytes, 8-way set associative, 64 bytes line size, 2 lines per sector';
  RsIntelCacheDescr7B = '2nd-level cache: 512 KBytes, 8-way set associative, 64 bytes line size, 2 lines per sector';
  RsIntelCacheDescr7C = '2nd-level cache: 1 MBytes, 8-way set associative, 64 bytes line size, 2 lines per sector';
  RsIntelCacheDescr7D = '2nd-level cache: 2 MBytes, 8-way set associative, 64 byte line size';
  RsIntelCacheDescr7F = '2nd-level cache: 512 KBytes, 2-way set associative, 64 byte line size';
  RsIntelCacheDescr80 = '2nd-level cache: 512 KBytes, 8-way set associative, 64 byte line size';
  RsIntelCacheDescr82 = '2nd-level cache: 256 KBytes, 8-way associative, 32 byte line size';
  RsIntelCacheDescr83 = '2nd-level cache: 512 KBytes, 8-way associative, 32 byte line size';
  RsIntelCacheDescr84 = '2nd-level cache: 1 MBytes, 8-way associative, 32 byte line size';
  RsIntelCacheDescr85 = '2nd-level cache: 2 MBytes, 8-way associative, 32 byte line size';
  RsIntelCacheDescr86 = '2nd-level cache: 512 KByte, 4-way set associative, 64 byte line size';
  RsIntelCacheDescr87 = '2nd-level cache: 1 MByte, 8-way set associative, 64 byte line size';
  RsIntelCacheDescrB0 = 'Instruction TLB: 4 KByte pages, 4-way set associative, 128 entries';
  RsIntelCacheDescrB1 = 'Instruction TLB: 2 MByte pages, 4-way, 8 entries or 4 MByte pages, 4-way, 4 entries';
  RsIntelCacheDescrB2 = 'Instruction TLB: 4 KByte pages, 4-way set associative, 64 entries';
  RsIntelCacheDescrB3 = 'Data TLB: 4 KByte pages, 4-way set associative, 128 entries';
  RsIntelCacheDescrB4 = 'Data TLB1: 4 KByte pages, 4-way set associative, 256 entries';
  RsIntelCacheDescrBA = 'Data TLB1: 4 KByte pages, 4-way set associative, 64 entries';
  RsIntelCacheDescrC0 = 'Data TLB: 4 KByte and 4 MByte pages, 4-way set associative, 8 entries';
  RsIntelCacheDescrCA = 'Shared 2nd-Level TLB: 4 KByte pages, 4-way associative, 512 entries';
  RsIntelCacheDescrD0 = '3rd-level cache: 512 KByte, 4-way set associative, 64 byte line size';
  RsIntelCacheDescrD1 = '3rd-level cache: 1 MByte, 4-way set associative, 64 byte line size';
  RsIntelCacheDescrD2 = '3rd-level cache: 2 MByte, 4-way set associative, 64 byte line size';
  RsIntelCacheDescrD6 = '3rd-level cache: 1 MByte, 8-way set associative, 64 byte line size';
  RsIntelCacheDescrD7 = '3rd-level cache: 2 MByte, 8-way set associative, 64 byte line size';
  RsIntelCacheDescrD8 = '3rd-level cache: 4 MByte, 8-way set associative, 64 byte line size';
  RsIntelCacheDescrDC = '3rd-level cache: 1.5 MByte, 12-way set associative, 64 byte line size';
  RsIntelCacheDescrDD = '3rd-level cache: 3 MByte, 12-way set associative, 64 byte line size';
  RsIntelCacheDescrDE = '3rd-level cache: 6 MByte, 12-way set associative, 64 byte line size';
  RsIntelCacheDescrE2 = '3rd-level cache: 2 MByte, 16-way set associative, 64 byte line size';
  RsIntelCacheDescrE3 = '3rd-level cache: 4 MByte, 16-way set associative, 64 byte line size';
  RsIntelCacheDescrE4 = '3rd-level cache: 8 MByte, 16-way set associative, 64 byte line size';
  RsIntelCacheDescrEA = '3rd-level cache: 12 MByte, 24-way set associative, 64 byte line size';
  RsIntelCacheDescrEB = '3rd-level cache: 18 MByte, 24-way set associative, 64 byte line size';
  RsIntelCacheDescrEC = '3rd-level cache: 24 MByte, 24-way set associative, 64 byte line size';
  RsIntelCacheDescrF0 = '64-Byte Prefetching';
  RsIntelCacheDescrF1 = '128-Byte Prefetching';
  RsIntelCacheDescrFF = 'CPUID leaf 2 does not report cache descriptor information, use CPUID leaf 4 to query cache parameters';
  RsMakeUTCTime    = 'Error converting to UTC time. Time zone could not be determined';
  RsDateConversion = 'Error illegal date or time format';
  RsCompressionReadNotSupported      = 'read is not an supported operation.';
  RsCompressionWriteNotSupported     = 'write is not an supported operation.';
  RsCompressionResetNotSupported     = 'reset is not an supported operation.';
  RsCompressionSeekNotSupported      = 'seek is not an supported operation.';
  RsCompressionUserAbort             = 'User abort';
  RsCompressionZLibZErrNo            = 'zlib returned: ERRNO';
  RsCompressionZLibZStreamError      = 'zlib returned: Stream error';
  RsCompressionZLibZDataError        = 'zlib returned: data error';
  RsCompressionZLibZMemError         = 'zlib returned: memory error';
  RsCompressionZLibZBufError         = 'zlib returned: buffer error';
  RsCompressionZLibZVersionError     = 'zlib returned: version error';
  RsCompressionZLibError             = 'zLib returned: unknown error (%d)';
  RsCompressionGZIPInvalidID         = 'gzip: Invalid ID (ID1=%.2x; ID2=%.2x)';
  RsCompressionGZIPUnsupportedCM     = 'gzip: unsupported compression method (%d)';
  RsCompressionGZIPHeaderCRC         = 'gzip: CRC failed, header is damaged';
  RsCompressionGZIPDecompressing     = 'gzip: this property is not readable when the data are being decompressed';
  RsCompressionGZIPNotDecompressed   = 'gzip: this property is not readable until the data are fully decompressed';
  RsCompressionGZIPDataTruncated     = 'gzip: data are truncated';
  RsCompressionGZIPInternalError     = 'gzip: internal error';
  RsCompressionGZIPDataCRCFailed     = 'gzip: CRC failed, data are damaged';
  RsCompressionGZIPExtraFieldTooLong = 'gzip: extra field is too long';
  RsCompressionGZIPBadString         = 'gzip: the string contains null chars';
  RsCompressionBZIP2SequenceError    = 'bzip2 returned: sequence error';
  RsCompressionBZIP2ParameterError   = 'bzip2 returned: parameter error';
  RsCompressionBZIP2MemoryError      = 'bzip2 returned: memory error';
  RsCompressionBZIP2DataError        = 'bzip2 returned: data error';
  RsCompressionBZIP2HeaderError      = 'bzip2 returned: header error';
  RsCompressionBZIP2IOError          = 'bzip2 returned: IO error';
  RsCompressionBZIP2EOFError         = 'bzip2 returned: unexpected end of file';
  RsCompressionBZIP2OutBuffError     = 'bzip2 returned: out buffer is too small';
  RsCompressionBZIP2ConfigError      = 'bzip2 returned: configuration error';
  RsCompressionBZIP2Error            = 'bzip2 returned: unknown error (%d)';
  RsCompressionUnavailableProperty   = 'Property is not available';
  RsCompressionCompressingError      = 'Operation is not supported while compressing';
  RsCompressionDecompressingError    = 'Operation is not supported while decompressing';
  RsCompressionNoFileName            = 'File name not supplied';
  RsCompressionUnsupportedMethod     = 'Unsupported method';
  RsCompressionDataError             = 'Data error';
  RsCompressionCRCError              = 'CRC error';
  RsCompressionNoNestedArchive       = 'Nested archive is not supported';
  RsCompressionUnknownError          = 'Unknown error';
  RsCompression7zLoadError           = 'Sevenzip: Failed to load 7z.dll';
  RsCompression7zReturnError         = 'Sevenzip: Error result (%.8x) "%s"';
  RsCompression7zUnassignedStream    = 'Sevenzip: Stream object is not assigned';
  RsCompression7zOutArchiveError     = 'Sevenzip: Failed to get out archive interface for class %s';
  RsCompression7zInArchiveError      = 'Sevenzip: Failed to get in archive interface for class %s';
  RsCompression7zUnknownValueType    = 'Sevenzip: Unknown value type (%d) for property ID %d';
  RsCompression7zOnlyCurrentFile     = 'Sevenzip: Only properties for current file can be retreived';
  RsCompression7zWindows             = 'Windows';
  RsCompression7zUnix                = 'Unix';
  RsCompressionZipName               = 'Zip archive';
  RsCompressionZipExtensions         = '*.zip;' +   // Basic ZIP file
                                       '*.jar;*.ear;*.war;' +  // JAVA files
                                       '*.cbz;' + //Comic reader files - ZIP version
                                       '*.apk;' + // Android application package
                                       '*.wsz;*.wal;' + // Winamp Skins
                                       '*.xpi;*.crx;' + // Firefox, Chrome extensions
                                       '*.dfsz;' + // ???
                                       '*.pcv;' + // MozBackup file
                                       '*.bsz;' + // BSplayer skin
                                       '*.mskin;' + // Maxthon skin
                                       '*.wmz;' + // Windows Media Player skin
                                       '*.ipa;' + // iPhone/iPad application
                                       '*.docx;*.xlsx;*.pptx;' + // MsOffice
                                       '*.sxw;*.sxi;*.sxt;*.sxd;*.sxc;*.sxm;*.sxg;*.stw;*.sti;*.std;*.stc;' + // OpenOffice.org 1.x documents and templates
                                       '*.odh;*.odd;*.odt;*.odm;*.ods;*.ots;*.odg;*.otg;*.odp;*.otp;*.odf;*.odb'; // OpenOffice.org 2.x/3.x docs and templates
  RsCompressionBZip2Name             = 'BZip2 archive';
  RsCompressionBZip2Extensions       = '*.bz2;*.bzip2;*.tbz2;*.tbz';
  RsCompressionBZip2SubExtensions    = '.tbz2=.tar;.tbz=.tar';
  RsCompressionRarName               = 'Rar archive';
  RsCompressionRarExtensions         = '*.rar;*.r00;'+
                                       '*.cbr'; // Comic reader file - RAR version
  RsCompressionArjName               = 'Arj archive';
  RsCompressionArjExtensions         = '*.arj';
  RsCompressionZName                 = 'Z archive';
  RsCompressionZExtensions           = '*.z;*.taz';
  RsCompressionZSubExtensions        = '.taz=.tar';
  RsCompressionLzhName               = 'Lzh archive';
  RsCompressionLzhExtensions         = '*.lzh;*.lha';
  RsCompression7zName                = '7z archive';
  RsCompression7zExtensions          = '*.7z';
  RsCompressionCabName               = 'Cab archive';
  RsCompressionCabExtensions         = '*.cab;'+
                                       '*.fwp'; // FrontPage Web Package
  RsCompressionNsisName              = 'Nsis archive';
  RsCompressionNsisExtensions        = '*.nsis';
  RsCompressionLzmaName              = 'Lzma archive';
  RsCompressionLzmaExtensions        = '*.lzma';
  RsCompressionLzma86Name            = 'Lzma86 archive';
  RsCompressionLzma86Extensions      = '*.lzma86';
  RsCompressionPeName                = 'Pe archive';
  RsCompressionPeExtensions          = '*.exe;*.dll;*.sys;*.bpl';
  RsCompressionElfName               = 'Elf archive';
  // TODO: extension might be *.*, but then TJclCompressionStreamFormats.FindDecompressFormat can fail
  RsCompressionElfExtensions         = '*.';
  RsCompressionMachoName             = 'Mach-O archive';
  // TODO: extension might be *.*, but then TJclCompressionStreamFormats.FindDecompressFormat can fail
  RsCompressionMachoExtensions       = '*.';
  RsCompressionUdfName               = 'Udf archive';
  RsCompressionUdfExtensions         = '*.iso;*.img';
  RsCompressionXarName               = 'Xar archive';
  RsCompressionXarExtensions         = '*.xar;'+
                                       '*.safariextz'; // Safari extensions
  RsCompressionMubName               = 'Mub archive';
  // TODO: extension might be *.*, but then TJclCompressionStreamFormats.FindDecompressFormat can fail
  RsCompressionMubExtensions         = '*.';
  RsCompressionHfsName               = 'Hfs archive';
  RsCompressionHfsExtensions         = '*.hfs';
  RsCompressionDmgName               = 'Dmg archive';
  RsCompressionDmgExtensions         = '*.dmg';
  RsCompressionCompoundName          = 'Compound archive';
  RsCompressionCompoundExtensions    = '*.msi;*.msp;*.doc;*.xls;*.ppt';
  RsCompressionWimName               = 'Wim archive';
  RsCompressionWimExtensions         = '*.wim;*.swm';
  RsCompressionIsoName               = 'Iso archive';
  RsCompressionIsoExtensions         = '*.iso;*.img';
  RsCompressionChmName               = 'Chm archive';
  RsCompressionChmExtensions         = '*.chm;*.chi;*.chq;*.chw;*.hxs;*.hxi;*.hxr;*.hxq;*.hxw;*.lit';
  RsCompressionSplitName             = 'Split archive';
  RsCompressionSplitExtensions       = '*.001';
  RsCompressionRpmName               = 'Rpm archive';
  RsCompressionRpmExtensions         = '*.rpm';
  RsCompressionDebName               = 'Deb archive';
  RsCompressionDebExtensions         = '*.deb';
  RsCompressionCpioName              = 'Cpio archive';
  RsCompressionCpioExtensions        = '*.cpio';
  RsCompressionTarName               = 'Tar archive';
  RsCompressionTarExtensions         = '*.tar';
  RsCompressionGZipName              = 'GZip archive';
  RsCompressionGZipExtensions        = '*.gz;*.gzip;*.tgz;*.tpz';
  RsCompressionGZipSubExtensions     = '.tgz=.tar;.tpz=.tar';
  RsCompressionXzName                = 'Xz archive';
  RsCompressionXzExtensions          = '*.xz;*.txz';
  RsCompressionXzSubExtensions       = '.txz=.tar';
  RsCompressionNtfsName              = 'Ntfs archive';
  RsCompressionNtfsExtensions        = '*.ntfs;*.img';
  RsCompressionFatName               = 'Fat archive';
  RsCompressionFatExtensions         = '*.fat;*.img';
  RsCompressionMbrName               = 'Mbr archive';
  RsCompressionMbrExtensions         = '*.mbr';
  RsCompressionVhdName               = 'Vhd archive';
  RsCompressionVhdExtensions         = '*.vhd';
  RsCompressionVhdSubExtensions      = '.vhd=.mbr';
  RsCompressionFlvName               = 'Flv archive';
  RsCompressionFlvExtensions         = '*.flv';
  RsCompressionMsLZName              = 'MsLZ archive';
  // TODO: extension might be *.*, but then TJclCompressionStreamFormats.FindDecompressFormat can fail
  RsCompressionMsLZExtensions        = '*.';
  RsCompressionSwfName               = 'Swf archive';
  RsCompressionSwfExtensions         = '*.swf';
  RsCompressionSwfcName              = 'Swf archive';
  RsCompressionSwfcExtensions        = '*.swf';
  RsCompressionApmName               = 'APM archive';
  RsCompressionApmExtensions         = '*.';
  RsCompressionPpmdName              = 'PPMD archive';
  RsCompressionPpmdExtensions        = '*.pmd';
  RsCompressionTEName                = 'Terse Executable';
  RsCompressionTEExtensions          = '*.te';
  RsCompressionUEFIcName             = 'UEFIc archive';
  RsCompressionUEFIcExtensions       = '*.scap';
  RsCompressionUEFIsName             = 'UEFIs archive';
  RsCompressionUEFIsExtensions       = '*.';
  RsCompressionSquashFSName          = 'SquashFS archive';
  RsCompressionSquashFSExtensions    = '*.squashfs';
  RsCompressionCramFSName            = 'CramFS archive';
  RsCompressionCramFSExtensions      = '*.cramfs';
  RsCompressionExtName               = 'Ext filesystem archive';
  RsCompressionExtExtensions         = '*.ext;*.ext2;*.ext3;*.ext4;*.img';
  RsCompressionVMDKName              = 'Virtual Machine Disk archive';
  RsCompressionVMDKExtensions        = '*.vmdk';
  RsCompressionVDIName               = 'Virtual Disk Image archive';
  RsCompressionVDIExtensions         = '*.vdi';
  RsCompressionQcowName              = 'QEMU Copy On Write archive';
  RsCompressionQcowExtensions        = '*.qcow;*.qcow2;*.qcow2c';
  RsCompressionGPTName               = 'GUID Partition Table archive';
  RsCompressionGPTExtensions         = '*.gpt;*.mbr';
  RsCompressionRar5Name              = 'RAR v5 archive';
  RsCompressionRar5Extensions        = '*.rar;*.r00';
  RsCompressionIHexName              = 'IHex archive';
  RsCompressionIHexExtensions        = '*.ihex';
  RsCompressionHxsName               = 'Help 2.0 archive';
  RsCompressionHxsExtensions         = '*.hxs;*.hxi;*.hxr;*.hxq;*.hxw;*.lit';
  RsCompressionDuplicate             = 'The file %s already exists in the archive';
  RsCompressionReplaceError          = 'At least one compression volume could not be replaced after an archive out-of-place update';
  RsCategoryUnicodeChar       = 'category Unicode character > $FFFFFF found';
  RsCasedUnicodeChar          = 'cased Unicode character > $FFFFFF found';
  RsDecomposedUnicodeChar     = 'decomposed Unicode character > $FFFFFF found';
  RsCombiningClassUnicodeChar = 'combining class for Unicode character > $FFFFFF found';
  RsUREErrorFmt               = '%s%s%s';
  RsUREBaseString             = 'Error in regular expression: %s' + sLineBreak;
  RsUREUnexpectedEOS          = 'Unexpected end of pattern.';
  RsURECharacterClassOpen     = 'Character class not closed, '']'' is missing.';
  RsUREUnbalancedGroup        = 'Unbalanced group expression, '')'' is missing.';
  RsUREInvalidCharProperty    = 'A character property is invalid';
  RsUREInvalidRepeatRange     = 'Invalid repetition range.';
  RsURERepeatRangeOpen        = 'Repetition range not closed, ''}'' is missing.';
  RsUREExpressionEmpty        = 'Expression is empty.';
  RsInvalidEmptyStringItem  = 'String list passed to StringsToMultiSz cannot contain empty strings.';
  RsNumericConstantTooLarge = 'Numeric constant too large (%d) at position %d.';
  RsBlankSearchString       = 'Search string cannot be blank';
  RsFormatException         = 'Format exception';
  RsDotNetFormatNullFormat  = 'Format string is null';
  RsArgumentIsNull          = 'Argument %d is null';
  RsDotNetFormatArgumentNotSupported = 'Argument type of %d is not supported';
  RsDotNetFormatObjectArgumentNotSupported = 'Argument type (%s) of %d is not supported';
  RsArgumentOutOfRange      = 'Argument out of range';
  RsTabs_DuplicatesNotAllowed = 'Duplicate tab stops are not allowed.';
  RsTabs_StopExpected = 'A tab stop was expected but not found.';
  RsTabs_CloseBracketExpected = 'Closing bracket expected.';
  RsTabs_TabWidthExpected = 'Tab width expected.';
  RsUnableToOpenKeyRead  = 'Unable to open key "%s\%s" for read';
  RsUnableToOpenKeyWrite = 'Unable to open key "%s\%s" for write';
  RsUnableToAccessValue  = 'Unable to open key "%s\%s" and access value "%s"';
  RsWrongDataType        = '"%s\%s\%s" is of wrong kind or size';
  RsInconsistentPath     = '"%s" does not match RootKey';
  RsArg_NullReferenceException = 'Object reference not set to an instance of an object.';
  RsSynchAttachWin32Handle    = 'Invalid handle to TJclWin32HandleObject.Attach';
  RsSynchDuplicateWin32Handle = 'Invalid handle to TJclWin32HandleObject.Duplicate';
  RsSynchInitCriticalSection  = 'Failed to initalize critical section';
  RsSynchAttachDispatcher     = 'Invalid handle to TJclDispatcherObject.Attach';
  RsSynchCreateEvent          = 'Failed to create event';
  RsSynchOpenEvent            = 'Failed to open event';
  RsSynchCreateWaitableTimer  = 'Failed to create waitable timer';
  RsSynchOpenWaitableTimer    = 'Failed to open waitable timer';
  RsSynchCreateSemaphore      = 'Failed to create semaphore';
  RsSynchOpenSemaphore        = 'Failed to open semaphore';
  RsSynchCreateMutex          = 'Failed to create mutex';
  RsSynchOpenMutex            = 'Failed to open mutex';
  RsMetSectInvalidParameter   = 'An invalid parameter was passed to the constructor.';
  RsMetSectInitialize         = 'Failed to initialize the metered section.';
  RsMetSectNameEmpty          = 'Name cannot be empty when using the Open constructor.';
  RsFileStreamCreate         = 'Unable to create temporary file stream';
  RsCreateFileMapping        = 'Failed to create FileMapping';
  RsCreateFileMappingView    = 'Failed to create FileMappingView';
  RsLoadFromStreamSize       = 'Not enough space in View in procedure LoadFromStream';
  RsFileMappingInvalidHandle = 'Invalid file handle';
  RsViewNeedsMapping         = 'FileMap argument of TJclFileMappingView constructor cannot be nil';
  RsFailedToObtainSize       = 'Failed to obtain size of file';
  RsCannotRaiseSignal = 'Cannot raise %s signal.';
  RsInvalidMMFName = 'Invalid MMF name "%s"';
  RsInvalidMMFEmpty = 'The MMF named "%s" cannot be created empty';
  RsVMTMemoryWriteError  = 'Error writing VMT memory (%s)';
  RsCannotWriteRefStream = 'Can not write to a read-only memory stream';
  RsStringToBoolean      = 'Unable to convert the string "%s" to a boolean';
  RsInvalidDigit         = 'Invalid base %d digit ''%s'' encountered.';
  RsInvalidDigitValue    = 'There is no valid base %d digit for decimal value %d';
  RsFileMappingOpenFile = 'Unable to open the file';
  RsFileIndexOutOfRange = 'Index of out range';
  RsPathInvalidDrive = '%s is not a valid drive';
  RsDelTreePathIsEmpty = 'DelTree: Path is empty';
  RsDefaultFileTypeName = ' File';
  RsCannotCreateDir = 'Unable to create directory';
  RsUnknownDrive   = 'Unknown drive type';
  RsRemovableDrive = 'Removable Drive';
  RsHardDisk       = 'Hard Disk';
  RsRemoteDrive    = 'Remote Drive';
  RsCDRomDrive     = 'CD-ROM';
  RsRamDisk        = 'RAM-Disk';
  // GetFileAttributeList()
  RsAttrDirectory  = 'Directory';
  RsAttrReadOnly   = 'ReadOnly';
  RsAttrSystemFile = 'SystemFile';
  RsAttrVolumeID   = 'Volume ID';
  RsAttrArchive    = 'Archive';
  RsAttrAnyFile    = 'AnyFile';
  RsAttrHidden     = 'Hidden';
  RsAttrNormal       = 'Normal';
  RsAttrTemporary    = 'Temporary';
  RsAttrCompressed   = 'Compressed';
  RsAttrOffline      = 'Offline';
  RsAttrEncrypted    = 'Encrypted';
  RsAttrReparsePoint = 'Reparse Point';
  RsAttrSparseFile   = 'Sparse';
  RsFileUtilsAttrUnavailable = 'Unable to retrieve attributes of %s';
  RsVosUnknown      = 'Unknown';
  RsVosDos          = 'MS-DOS';
  RsVosOS216        = '16-bit OS/2';
  RsVosOS232        = '32-bit OS/2';
  RsVosNT           = 'Windows NT';
  RsVosWindows16    = '16-bit Windows';
  RsVosPM16         = '16-bit PM';
  RsVosPM32         = '32-bit PM';
  RsVosWindows32    = '32-bit Windows';
  RsVosDosWindows16 = '16-bit Windows, running on MS-DOS';
  RsVosDosWindows32 = 'Win32 API, running on MS-DOS';
  RsVosOS216PM16    = '16-bit PM, running on 16-bit OS/2';
  RsVosOS232PM32    = '32-bit PM, running on 32-bit OS/2';
  RsVosNTWindows32  = 'Win32 API, running on Windows/NT';
  RsVosDesignedFor  = 'Designed for %s';
  RsVftUnknown         = 'Unknown';
  RsVftApp             = 'Application';
  RsVftDll             = 'Library';
  RsVftDrv             = 'Driver';
  RsVftFont            = 'Font';
  RsVftVxd             = 'Virtual device';
  RsVftStaticLib       = 'Static-link library';
  RsVft2DrvPRINTER     = 'Printer';
  RsVft2DrvKEYBOARD    = 'Keyboard';
  RsVft2DrvLANGUAGE    = 'Language';
  RsVft2DrvDISPLAY     = 'Display';
  RsVft2DrvMOUSE       = 'Mouse';
  RsVft2DrvNETWORK     = 'Network';
  RsVft2DrvSYSTEM      = 'System';
  RsVft2DrvINSTALLABLE = 'Installable';
  RsVft2DrvSOUND       = 'Sound';
  RsVft2DrvCOMM        = 'Communications';
  RsVft2FontRASTER     = 'Raster';
  RsVft2FontVECTOR     = 'Vector';
  RsVft2FontTRUETYPE   = 'TrueType';
  RsEModuleNotValid = 'The Module with handle %d is not valid';
  RsEWindowNotValid = 'The window with handle %d is not valid';
  RsEProcessNotValid = 'The process with ID %d is not valid';
  RsFileUtilsFileDoesNotExist = 'The file %s does not exist';
  RsFileUtilsNoVersionInfo = 'File contains no version information';
  RsFileUtilsLanguageIndex = 'Illegal language index';
  RsFileUtilsEmptyValue = 'No value was supplied';
  RsFileUtilsValueNotFound = 'The value %s was not found.';
  RsFileSearchAttrInconsistency = 'Some file search attributes are required AND rejected!';
  RsInvalidGUIDString    = 'Invalid conversion from string to GUID (%s).';
  RsUnexpectedValue    = 'Unexpected data value';
  RsMathDomainError    = 'Domain check failure in JclMath';
  RsEmptyArray         = 'Empty array is not allowed as input parameter';
  RsNonPositiveArray   = 'Input array contains non-positive or zero values';
  RsInvalidRational    = 'Invalid rational number';
  RsPowerComplex       = 'Power function: Result is complex';
  RsPowerInfinite      = 'Power function: Result is infinite';
  RsNoNaN              = 'NaN expected';
  RsNaNTagError        = 'NaN Tag value %d out of range';
  RsNaNSignal          = 'NaN signaling %d';
  RsDivByZero          = 'Division by zero';
  RsRationalDivByZero  = 'Rational division by zero';
  RsStreamsCreateError = 'Cannot create file %s';
  RsStreamsOpenError = 'Cannot open file %s';
  RsStreamsSetSizeError = 'Error setting stream size';
  RsStreamsSeekError = 'Error seeking stream';
  RsStreamsCRCError = 'Cyclic Redundency Check (CRC) error: data are damaged';
  RsEInvalidXMLElementUnexpectedCharacte =
    'Invalid XML Element: Unexpected character in property declaration ("%s" found at position %d)';
  RsEInvalidXMLElementUnexpectedCharacte_ =
    'Invalid XML Element: Unexpected character in property declaration. Expecting " or '' but "%s"  found at position %d';
  RsEUnexpectedValueForLPos = 'Unexpected value for lPos at position %d';
  RsEInvalidXMLElementExpectedBeginningO = 'Invalid XML Element: Expected beginning of tag but "%s" found at position %d';
  RsEInvalidXMLElementExpectedEndOfTagBu = 'Invalid XML Element: Expected end of tag but "%s" found at position %d';
  RsEInvalidXMLElementMalformedTagFoundn = 'Invalid XML Element: malformed tag found (no valid name) at position %d';
  RsEInvalidXMLElementErroneousEndOfTagE =
    'Invalid XML Element: Erroneous end of tag, expecting </%0:s> but </%1:s> found at position %d';
  RsEInvalidCommentExpectedsButFounds = 'Invalid Comment: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidCommentNotAllowedInsideComme = 'Invalid Comment: "--" not allowed inside comments at position %d';
  RsEInvalidCommentUnexpectedEndOfData = 'Invalid Comment: Unexpected end of data at position %d';
  RsEInvalidCDATAExpectedsButFounds = 'Invalid CDATA: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidCDATAUnexpectedEndOfData = 'Invalid CDATA: Unexpected end of data at position %d';
  RsEInvalidHeaderExpectedsButFounds = 'Invalid Header: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidStylesheetExpectedsButFounds = 'Invalid Stylesheet: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidStylesheetUnexpectedEndOfDat = 'Invalid Stylesheet: Unexpected end of data at position %d';
  RsEInvalidMSOExpectedsButFounds = 'Invalid MSO: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidMSOUnexpectedEndOfDat = 'Invalid MSO: Unexpected end of data at position %d';
  RsEInvalidDocumentUnexpectedTextInFile = 'Invalid Document: Unexpected text in file prolog at position %d';
  RsENetWkstaGetInfo            = 'NetWkstaGetInfo failed';
  RsSystemIdleProcess = 'System Idle Process';
  RsSystemProcess     = 'System Process';
  RsOSVersionWin2000            = 'Windows 2000';
  RsOSVersionWinXP              = 'Windows XP';
  RsOSVersionWin2003            = 'Windows Server 2003';
  RsOSVersionWin2003R2          = 'Windows Server 2003 R2';
  RsOSVersionWinXP64            = 'Windows XP x64';
  RsOSVersionWinVista           = 'Windows Vista';
  RsOSVersionWinServer2008      = 'Windows Server 2008';
  RsOSVersionWin7               = 'Windows 7';
  RsOSVersionWinServer2008R2    = 'Windows Server 2008 R2';
  RsOSVersionWin8               = 'Windows 8';
  RsOSVersionWin8RT             = 'Windows RT';
  RsOSVersionWinServer2012      = 'Windows Server 2012';
  RsOSVersionWin81              = 'Windows 8.1';
  RsOSVersionWin81RT            = 'Windows RT 8.1';
  RsOSVersionWinServer2012R2    = 'Windows Server 2012 R2';
  RsOSVersionWin10              = 'Windows 10';
  RsOSVersionWinServer2016      = 'Windows Server 2016';
  RsOSVersionWinServer2019      = 'Windows Server 2019';
  RsOSVersionWinServer2022      = 'Windows Server 2022';
  RsOSVersionWinServer          = 'Windows Server';
  RsOSVersionWin11              = 'Windows 11';
  RsEditionWinXPHome            = 'Home Edition';
  RsEditionWinXPPro             = 'Professional';
  RsEditionWinXPHomeN           = 'Home Edition N';
  RsEditionWinXPProN            = 'Professional N';
  RsEditionWinXPHomeK           = 'Home Edition K';
  RsEditionWinXPProK            = 'Professional K';
  RsEditionWinXPHomeKN          = 'Home Edition KN';
  RsEditionWinXPProKN           = 'Professional KN';
  RsEditionWinXPStarter         = 'Starter Edition';
  RsEditionWinXPMediaCenter     = 'Media Center Edition';
  RsEditionWinXPTablet          = 'Tablet PC Edition';
  RsEditionWinVistaStarter      = 'Starter';
  RsEditionWinVistaHomeBasic    = 'Home Basic';
  RsEditionWinVistaHomeBasicN   = 'Home Basic N';
  RsEditionWinVistaHomePremium  = 'Home Premium';
  RsEditionWinVistaBusiness     = 'Business';
  RsEditionWinVistaBusinessN    = 'Business N';
  RsEditionWinVistaEnterprise   = 'Enterprise';
  RsEditionWinVistaUltimate     = 'Ultimate';
  RsEditionWin7Starter          = 'Starter';
  RsEditionWin7HomeBasic        = 'Home Basic';
  RsEditionWin7HomePremium      = 'Home Premium';
  RsEditionWin7Professional     = 'Professional';
  RsEditionWin7Enterprise       = 'Enterprise';
  RsEditionWin7Ultimate         = 'Ultimate';
  RsEditionWin8Pro              = 'Pro';
  RsEditionWin8Enterprise       = 'Enterprise';
  RsEditionWin8RT               = 'RT';
  RsEditionWin81Pro             = 'Pro';
  RsEditionWin81Enterprise      = 'Enterprise';
  RsEditionWin81RT              = 'RT';
  RsEditionWin10Home            = 'Home';
  RsEditionWin10Pro             = 'Pro';
  RsEditionWin10Enterprise      = 'Enterprise';
  RsEditionWin10Education       = 'Education';
  RsProductTypeWorkStation      = 'Workstation';
  RsProductTypeServer           = 'Server';
  RsProductTypeAdvancedServer   = 'Advanced Server';
  RsProductTypePersonal         = 'Home Edition';
  RsProductTypeProfessional     = 'Professional';
  RsProductTypeDatacenterServer = 'Datacenter Server';
  RsProductTypeEnterprise       = 'Enterprise';
  RsProductTypeWebEdition       = 'Web Edition';
  RsEOpenGLInfo                 = 'GetOpenGLVersion: %s failed';
  RsOpenGLInfoError = 'Err';
  RsIntelUnknownCache = 'Unknown cache ID (%.2x)';
  RsUnknownAMDModel = 'Unknown AMD (Model %d)';
  RsRTTISetValueOutOfRange  = 'Set value over %s does not fit into a 32-bit integer.';
  RsRTTIValueOutOfRange   = 'Value %s out of range %s..%s.';
  RsRTTIUnknownIdentifier = 'Unknown identifier ''%s''.';
  RsRTTIInvalidBaseType   = 'Invalid base type (%s is of type %s).';
  RsRTTINoStringValue     = 'The property %s of type %s has no string value';
  RsRTTIVar           = 'var ';
  RsRTTIConst         = 'const ';
  RsRTTIArrayOf       = 'array of ';
  RsRTTIOut           = 'out ';
  RsRTTIBits          = 'bits';
  RsRTTIOrdinal       = 'ordinal=';
  RsRTTITrue          = 'True';
  RsRTTIFalse         = 'False';
  RsRTTITypeError     = '???';
  RsRTTITypeInfoAt    = 'Type info: %p';
  RsRTTIPropRead      = 'read';
  RsRTTIPropWrite     = 'write';
  RsRTTIPropStored    = 'stored';
  RsRTTIField         = 'field';
  RsRTTIStaticMethod  = 'static method';
  RsRTTIVirtualMethod = 'virtual method';
  RsRTTIIndex         = 'index';
  RsRTTIDefault       = 'default';
  RsRTTIName          = 'Name: ';
  RsRTTIType          = 'Type: ';
  RsRTTIFlags         = 'Flags: ';
  RsRTTIGUID          = 'GUID: ';
  RsRTTITypeKind      = 'Type kind: ';
  RsRTTIOrdinalType   = 'Ordinal type: ';
  RsRTTIMinValue      = 'Min value: ';
  RsRTTIMaxValue      = 'Max value: ';
  RsRTTINameList      = 'Names: ';
  RsRTTIClassName     = 'Class name: ';
  RsRTTIParent        = 'Parent: ';
  RsRTTIPropCount     = 'Property count: ';
  RsRTTIUnitName      = 'Unit name: ';
  RsRTTIBasedOn       = 'Based on: ';
  RsRTTIFloatType     = 'Float type: ';
  RsRTTIMethodKind    = 'Method kind: ';
  RsRTTIParamCount    = 'Parameter count: ';
  RsRTTIReturnType    = 'Return type: ';
  RsRTTIMaxLen        = 'Max length: ';
  RsRTTIElSize        = 'Element size: ';
  RsRTTIElType        = 'Element type: ';
  RsRTTIElNeedCleanup = 'Elements need clean up: ';
  RsRTTIVarType       = 'Variant type: ';
  RsDeclarationFormat = '// Declaration for ''%s'' not supported.';

resourcestring
  RsAniExtension = 'ani';
  RsAniFilterName = 'ANI Image';
  RsAniCurFilter = 'Animated Cursors (*.ani)|*.ani|Any files (*.*)|*.*';
  RsEInvalidAnimatedIconImage = 'Invalid animated icon image';
//=== JvAppDBStorage.pas =====================================================
resourcestring
  RsENotSupported = 'Method not supported';
  RsEBufTooSmallFmt = 'Buffer too small (%d bytes required)';
//=== JvAppIniStorage.pas ====================================================
resourcestring
  RsEReadValueFailed = 'TJvAppIniFileStorage.ReadValue: Section undefined';
  RsEWriteValueFailed = 'TJvAppIniFileStorage.WriteValue: Section undefined';
//=== JvAppRegistryStorage.pas ===============================================
resourcestring
  RsRootValueReplaceFmt =
    'The Default Root Value "%0:s" has been replaced with "%1:s".' + sLineBreak +
    'Please change the value in the FileVersionInfo Project Properties.';
  RsEUnableToCreateKey = 'Unable to create key ''%s''';
  RsEEnumeratingRegistry = 'Error enumerating registry';
//=== JvAppStorage.pas =======================================================
resourcestring
  RsEInvalidType = 'Invalid type';
  RsEUnknownBaseType = 'Unknown base type for given set';
  RsEInvalidPath = 'Invalid path';
  RsENotAUniqueRootPath = '''%s'' is not a unique root path';
  RsECircularReferenceOfStorages = 'Circular reference of storages';
  RsJvAppStorageSynchronizeTimeout = '%s: Mutex Timeout';
  RsJvAppStorageSynchronizeProcedureName = 'TJvCustomAppStorage.Synchronize:';
//=== JvAppStorageSelectList.pas =============================================
resourcestring
  RsLoadSettings = 'Load Settings';
  RsSaveSettings = 'Save Settings';
  RsDeleteSettings = 'Delete Settings';
  RsLoadCaption = '&Load';
  RsSaveCaption = '&Save';
  RsDeleteCaption = '&Delete';
  RsEDynControlEngineNotDefined = 'TJvAppStorageSelectList.CreateDialog: DynControlEngine not defined!';
  RsEDynAppStorageNotDefined = 'TJvAppStorageSelectList.GetSelectListPath: No AppStorage assigned';
//=== JvAppXMLStorage.pas ====================================================
resourcestring
  RsENodeCannotBeEmpty = 'The node must be given a name';
  RsEPathDoesntExists = 'Path ''%s'' does not exists';
  RsENotABooleanValue = '''%s'' is not a valid boolean value';
  RsENodeNameCannotContainSpaces =
    'XML Node names cannot contain white space and the WhiteSpaceReplacement property is empty. Please set the WhiteSpaceReplacementProperty to a non empty value.';
  RsEWhiteSpaceReplacementCannotContainSpaces =
    'The WhiteSpaceReplacement property cannot contain any white spaces.';
  RsENodeNameCannotInvalidChars =
    'XML Node names cannot contain invalid chars ("%s") and the InvalidCharReplacement property is empty. Please set the InvalidCharReplacement to a non empty value.';
  RsENotAllowedCharacterForProperty = '"%0:s" is not an allowed character for the %1:s property.';
//=== JvAVICapture.pas =======================================================
resourcestring
  RsNotConnected = 'Not connected';
  RsErrorMessagePrefix = 'Error #';
  RsEInvalidDriverIndex =
    '%0:d is an invalid driver index. The maximum value is %1:d' + sLineBreak +
    'This may also happen if the device could not be initialized properly.';
//=== JvBackgrounds.pas ======================================================
resourcestring
  SChainError =
   'Message from %0:s.%1:s:' + sLineBreak + sLineBreak +
   'Oops... Messing up %2:s''s window procedure chain.%3:s';
  SWorkaround = sLineBreak + sLineBreak +
    'To avoid this, $DEFINE the NO_DESIGNHOOK conditional compilation symbol and rebuild.';
//=== JvBalloonHint.pas ======================================================
resourcestring
  RsEParentRequired = 'Control ''%s'' has no parent window';
  RsEParentGivenNotAParent = 'Parent given is not a parent of ''%s''';
//=== JvBaseEdits.pas ========================================================
resourcestring
  RsEOutOfRangeXFloat = 'Value must be between %.*f and %.*f';
//=== JvBDECheckPasswordForm.pas+JvBaseDBPasswordDialog ======================
resourcestring
  RsChangePassword = 'Change password';
  RsOldPasswordLabel = '&Old password:';
  RsNewPasswordLabel = '&New password:';
  RsConfirmPasswordLabel = '&Confirm password:';
  RsPasswordChanged = 'Password has been changed';
  RsPasswordNotChanged = 'Password has not been changed';
  RsPasswordsMismatch = 'The new and confirmed passwords do not match';
//=== JvBaseDBPasswordDialog.pas  ============================================
resourcestring
  RsOldPasswordsMismatch = 'The current and old passwords do not match';
  RsChangeButtonCaption = 'Change';
  RsPasswordLengthToShort = 'Password length must be greater or equal %d';
  RsPasswordNotAllowedCharacters = 'Password contains not allowed characters';
//=== JvDBLogonDialogDoa.pas + JvDBLogonDialogOdac.pas  ======================
resourcestring
  RsDoYouWantToChangePassword = 'Do you want to change the password?';
//=== JvBaseDBLogonDialog.pas  ===============================================
resourcestring
  RsLogonToDatabase = 'Logon to Database';
  RsBtnConnect = 'Connect';
  RsBtnAdditional = 'Additional';
  RsBtnHintAddDefinitionToList = 'Add Definition to List';
  RsBtnHintSelectDefinitionFromList = 'Select Definition from List';
  RsBtnHintDeleteDefinitionFromList = 'Delete Definition from List';
  RsPageByUser = 'By User';
  RsPageByDatabase = 'By Database';
  RsPageByGroup = 'By Group';
  RsPageDefaultList = 'Default List';
  RsUsername = '&Username';
  RsPassword = '&Password';
  RsDatabase = '&Database';
  RsAlias= 'Al&ias';
  RsShortcut = '&Shortcut';
  RsConnectGroup = '&Connect Group';
  RsConnectAs = 'Connect-&As';
  RsImportConnectionList = 'Import Connection List';
  RsExportConnectionList = 'Export Connection List';
  RsConnectionListImportOverwrite = 'Overwrite';
  RsConnectionListImportAppend = 'Append';
  RsConnectionListImportAppendOverwriteExistingEntries = 'Append/Overwrite existing entries?';
  RsNoConnectionEntriesFound = 'No Connection Entries found!';
  RsConnectionListExportImportFilter = 'XML-Files (*.xml)|*.xml|INI-Files (*.ini)|*.ini|All Files (*.*)|*.*';
  RsConnectionListItemName = 'Connection';
  RsGroupNameUndefined = 'Undefined';
  RsCheckboxSavePasswords = '&Save Passwords';
  RsCheckBoxGroupByUser = 'Group By User';
  RsCheckBoxGroupByDatabase = 'Group By Database';
//=== JvDBLogonDialogOdac.pas  ===============================================
resourcestring
  RsOracleHome = 'Oracle Home';
  RsUseNetOptionForDirectConnect = 'Use Net-Option for direct connect';
  RsNetOptionCheckBoxHint =
      'If this option is activated the connecting passed sql*net'#13#10+
      'and tries to connect to the server direct via tcpip.'#13#10+
      'The database name must contain Server name, Oracle service name,'#13#10+
      'and port in the following format:'#13#10+
      '    Host:Port:SID'#13#10+
      '  Where'#13#10+
      '    Host is the address of server;'#13#10+
      '    Port is the number of port that server listens to;'#13#10+
      '    SID is system identifier that specifies Global Database Name.';
  RsNetOptionConnectionList = 'NET Option';
//=== JvDBLogonDialogUnidac.pas  ===============================================
resourcestring
  RsServer= 'Ser&ver';
  RsPort= 'Port';
  RsProvider='&Provider';
  RsDirectConnect='&Direct Connect';
//=== JvBDEExceptionForm.pas =================================================
resourcestring
  RsDBExceptCaption = 'Database Engine Error';
  RsBDEErrorLabel = 'BDE Error';
  RsServerErrorLabel = 'Server Error';
  RsErrorMsgLabel = 'Error message';
//=== JvBDEFilter.pas ========================================================
resourcestring
  RsECaptureFilter = 'Cannot perform this operation when controls are captured';
  RsENotCaptureFilter = 'Cannot perform this operation when controls are not captured';
//=== JvBDELoginDialog.pas ===================================================
resourcestring
  RsEInvalidUserName = 'Invalid user name or password';
  RsLastLoginUserName = 'Last Login User';  // Also used by JvLoginForm
  RsSelectDatabase = 'SelectDatabase'; { dialog never writes this value }
  RsLastAliasName = 'LastAlias'; { used if SelectDatabase = True  }
//=== JvBDEMove.pas ==========================================================
resourcestring
  RsEInvalidReferenceDescriptor = 'Invalid reference descriptor';
//=== JvBdeUtils.pas =========================================================
resourcestring
  RsRetryLogin = 'Do you wish to retry the connect to database?';
  RsETableNotInExclusiveMode = 'Table must be opened in exclusive mode to add passwords';
  RsETableNotOpen = 'Table must be opened to pack';
  RsETableNotOpenExclusively = 'Table must be opened exclusively to pack';
  RsENoParadoxDBaseTable = 'Table must be either of Paradox or dBASE type to pack';
//=== JvBehaviorLabel.pas ====================================================
resourcestring
  RsENeedBehaviorLabel = 'Cannot call %s.Create with ALabel = nil';
  RsENoOwnerLabelParent = 'OwnerLabel.Parent is nil in %s.Start';
//=== JvBevel.pas ============================================================
resourcestring
  RsEGradientDeprecated = 'Gradient is no longer available, use a TJvGradient component instead';
//=== JvBrowseFolder.pas =====================================================
resourcestring
  RsEShellNotCompatible = 'Shell not compatible with BrowseForFolder';
//=== JvButtons.pas ==========================================================
resourcestring
  RsEOwnerMustBeForm = '%s owner must be a TForm';
//=== JvCalc.pas =============================================================
resourcestring
  RsCalculatorCaption = 'Calculator';
//=== JvCalendar.pas =========================================================
resourcestring
  RsEInvalidDateStr = 'Invalid date specification to TMonthCalStrings (%s)';
  RsECannotAssign = 'Cannot assign %0:s to a %1:s';
  RsEInvalidArgumentToSetDayStates = 'Invalid argument to SetDayStates';
  RsEInvalidAppearance = 'TJvCustomMonthCalendar.CreateWithAppearance: cannot be created without valid Appearance';
//=== JvCaptionButton.pas ====================================================
resourcestring
  RsEOwnerMustBeTCustomForm = 'TJvCaptionButton owner must be a TCustomForm';
//=== JvCaret.pas ============================================================
resourcestring
  RsEInvalidCaretOwner = '%s: cannot be created without a valid Owner';
//=== JvChangeNotify.pas =====================================================
resourcestring
  RsFileNameChange = 'Filename Change';
  RsDirectoryNameChange = 'Directory Name Change';
  RsAttributesChange = 'Attributes Change';
  RsSizeChange = 'Size Change';
  RsWriteChange = 'Write Change';
  RsSecurityChange = 'Security Change';
  RsEFmtCannotChangeName = 'Cannot change %s when active';
  RsEFmtInvalidPath = 'Invalid or empty path (%s)';
  RsEFmtMaxCountExceeded = 'Maximum of %d items exceeded';
  RsEFmtInvalidPathAtIndex = 'Invalid or empty path ("%0:s") at index %1:d';
  RsENotifyErrorFmt = '%0:s:' + sLineBreak + '%1:s';
//=== JvChart.pas ============================================================
resourcestring
  RsChartDesigntimeLabel = ': JEDI JVCL Charting Component';
  RsNoData = 'No data. (Data.ValueCount=0)';
  RsGraphHeader = 'Graph Header';
  RsCurrentHeaders = 'Current Header: %s';
  RsXAxisHeaders = 'X Axis Header: %s';
  RsGraphScale = 'Graph Scale';
  RsYAxisScales = 'Y Axis Scale: %s';
  RsNoValuesHere = 'No values here!';
  RsNA = ' n/a ';
  RsEDataIndexCannotBeNegative = 'Data: index cannot be negative';
  RsEPenIndexInvalid = 'Data: pen index invalid/out of range.';
  RsEDataIndexTooLargeProbablyAnInternal = 'Data: index too large. Probably an internal error';
  RsEGetAverageValueIndexNegative = 'GetAverageValue: Index negative';
  RsESetAverageValueIndexNegative = 'SetAverageValue: Index negative';
  RsEChartOptionsPenCountPenCountOutOf = 'JvChart.Options.PenCount - PenCount out of range';
  RsEChartOptionsXStartOffsetValueOutO = 'JvChart.Options.XStartOffset  - value out of range';
  RsEUnableToGetCanvas = 'Unable to get canvas';
//=== JvCheckedMaskEdit.pas ==================================================
resourcestring
  RsEBeginUnsupportedNestedCall = 'TJvCustomCheckedMaskEdit.BeginInternalChange: Unsupported nested call!';
  RsEEndUnsupportedNestedCall = 'TJvCustomCheckedMaskEdit.EndInternalChange: Unsupported nested call!';
//=== JvClipboardViewer.pas ==================================================
  RsClipboardUnknown = 'Cannot display. Data in Clipboard is in an unknown format.';
  RsClipboardEmpty = 'Clipboard is empty';
//=== JvClipbrd.pas ==========================================================
resourcestring
  RsENoRenderFormatEventGiven = 'No OnRenderFormat was given';
//=== JvColorButton.pas ======================================================
resourcestring
  RsOtherCaption = '&Other...';
//=== JvColorCombo.pas =======================================================
resourcestring
  RsCustomCaption = 'Custom...';
  RsNewColorPrefix = 'Custom';
//=== JvColorProvider.pas ====================================================
resourcestring
  RsDelphiConstantNames = 'Delphi constant names';
  RsEnglishNames = 'English names';
  RsCustomColors = 'Custom colors';
  RsStandardColors = 'Standard colors';
  RsSystemColors = 'System colors';
  RsNoSettings = '(no settings)';
  RsESpecifiedMappingError = 'Specified mapping does not belong to the current provider';
  RsEAlreadyRegistered = '''%s'' is already registered';
  RsENoICR = 'Component does not support IInterfaceComponentReference';
  RsENoColProv = 'Component does not support IJvColorProvider';
  RsEMappingCollectionExpected = 'Mapping collection expected';
  RsEExpectedMappingName = 'Expected mapping name';
  RsEExpectedNameMappings = 'Expected name mappings';
  RsEInvalidNameMappingSpecification = 'Invalid name mapping specification';
  RsEUnknownColor = 'Unknown color ''%s''';
  RsEInvalidColor = 'Invalid color (%d)';
  RsEItemNotForList = 'Item does not belong to this list';
//=== JvCombobox.pas =========================================================
resourcestring
  RsCapSelAll = '&Select all';
  RsCapDeselAll = '&Deselect all';
  RsCapInvertAll = '&Invert all';
  RsENoMoreLength = 'Too many items selected';
//=== JvComputerInfoEx.pas ===================================================
resourcestring
  RsEReadOnlyProperty = 'This value is read-only and cannot be changed.';
  RsFileTypeString = '%s file';
  RsAttrArchiveShortString = 'A';
  RsAttrCompressedShortString = 'C';
  RsAttrDirectoryShortString = 'D';
  RsAttrReadOnlyShortString = 'R';
  RsAttrHiddenShortString = 'H';
  RsAttrSystemShortString = 'S';
//=== JvContextProvider.pas ==================================================
resourcestring
  RsContextItemEmptyCaption = '(no context assigned to this item)';
  RsENoContextAssigned = 'No context has been assigned to this item';
  RsENoContextItem = 'Specified item is not a context item';
  RsENotSupportedIInterfaceComponentReference = 'Component does not support IInterfaceComponentReference';
  RsENotSupportedIJvDataProvider = 'Component does not support IJvDataProvider';
//=== JvCreateProcess.pas ====================================================
resourcestring
  RsIdle = 'Idle';
  RsNormal = 'Normal';
  RsHigh = 'High';
  RsRealTime = 'RealTime';
  RsBelowNormal = 'Below normal';
  RsAboveNormal = 'Above normal';
  RsEProcessIsRunning = 'Cannot perform this operation when process is running';
  RsEProcessNotRunning = 'Process is not running';
//=== JvCSVBaseControls.pas ==================================================
resourcestring
  RsReplaceExistingDatabase = 'Replace existing database?';
  RsCVSDatabase = 'CSV Database';
  RsFindText = 'Find Text:';
  RsFirstHint = 'First';
  RsPreviousHint = 'Previous';
  RsFindHint = 'Find';
  RsNextHint = 'Next';
  RsLastHint = 'Last';
  RsAddHint = 'Add';
  RsDeleteHint = 'Delete';
  RsPostHint = 'Post';
  RsRefreshHint = 'Refresh';
  RsENoFieldsDefined = 'No fields defined';
//=== JvCsvData.pas ==========================================================
resourcestring
  RsErrorRowItem = '<ERROR>';
  RsECsvErrFormat = '%0:s: %1:s';
  RsECsvErrFormat2 = '%0:s: %1:s (%2:d)';
  RsECsvInvalidSeparatorFmt = 'Invalid separator character (%s)';
  RsEProblemReadingRow = 'Problem reading row %d';
  RsENoRecord = 'No records';
  RsENoFieldNamesMatch = 'No field names match in these datasets. CopyFromDataset failed.';
  RsETimeTConvError = 'SetFieldData Error - TimeT-to-DateTime conversion error';
  RsEFieldTypeNotHandled = 'SetFieldData Error - Field type not handled';
  RsEUnableToLocateCSVFileInfo = 'Unable to locate CSV file information for field %s';
  RsEPhysicalLocationOfCSVField = 'Physical location of CSV field %s unknown';
  RsEInvalidFieldTypeCharacter = 'Invalid field type character: %s';
  RsECsvNoRecord = 'No database record';
  RsEUnexpectedError = 'Unexpected error parsing CSV Field Definitions';
  RsEFieldDefinitionError = 'Field Definition Error. CsvFieldDef, FieldDefs, and file contents must match';
  RsEInvalidCsvKeyDef = 'Invalid CsvKeyDef property. InternalInitFieldDefs failed';
  RsEInternalErrorParsingCsvKeyDef = 'Internal Error parsing CsvKeyDef. InternalInitFieldDefs failed';
  RsEContainsField = 'CsvKeyDef contains field ''%s'' which is not defined. InternalInitFieldDefs failed';
  RsEInsertBlocked = 'InternalAddRecord cannot Add. Insert blocked';
  RsEPostingHasBeenBlocked = 'Posting to this database has been blocked';
  RsEKeyNotUnique = '%s - Key is not unique ';
  RsECannotInsertNewRow = 'Cannot insert new row. Insert blocked';
  RsECannotPost = 'Cannot post. Not in dsEdit or dsInsert mode';
  RsESortFailedCommaSeparated = 'Sort failed. You must give a comma separated list of field names';
  RsESortFailedFieldNames = 'Sort failed. Unable to parse field names. ';
  RsESortFailedInvalidFieldNameInList = 'Sort failed. Invalid field name in list: %s';
  RsEDataSetNotOpen = 'AppendRowString: DataSet is not open (active not set to true)';
  RsEErrorProcessingFirstLine = 'Error processing first line of CSV file';
  RsEFieldInFileButNotInDefinition = 'ProcessCsvHeaderRow: Field %s found in file, but not in field definitions';
  RsECsvFieldLocationError = 'CSV field location error: %s';
  RsEFieldNotFound = 'Field %s not found in the data file';
  RsECsvStringTooLong = 'CSV string is too long: %s...';
  RsECannotReadCsvFile = 'Can''t read CSV file %s';
  RsEInternalLimit = 'JvCsvData - Internal Limit of MAXCOLUMNS (%d) reached. CSV Data has too many columns';
  RsETableNameNotSet = 'TableName not specified';
  RsEGetMode = 'Invalid option to GetMode';
  RsENoTableName = 'TableName not specified';
  RsETableNameRequired = 'LoadsFromFile = True, so a TableName is required';
  RsEInternalCompare = 'InternalCompare. Nil value detected';
  RsEInvalidTableName = 'TJvCustomCsvDataSet.GetFileName - TableName property is not set';
//=== JvCsvParse.pas =========================================================
resourcestring
  RsEInvalidHexLiteral = 'HexStrToInt: Invalid hex literal';
//=== JvCursor.pas ===========================================================
resourcestring
  RsCurExtension = 'cur';
  RsCurDescription = 'Cursor files';
  RsCursor = 'Cursor';
  RsECursorLoadFromStream = 'LoadFromStream not supported';
  RsECursorSaveToStream = 'SaveToStream not supported';
//=== JvDataProvider.pas =====================================================
resourcestring
  RsEItemsMayNotBeMovedInTheMainTree = 'Items may not be moved in the main tree';
  RsEInvalidIndex = 'Invalid index';
  RsEItemCanNotBeDeleted = 'Item cannot be deleted';
  RsEContextNameExpected = 'Context name expected';
  RsEConsumerStackIsEmpty = 'Consumer stack is empty';
  RsEContextStackIsEmpty = 'Context stack is empty';
  RsEAContextWithThatNameAlreadyExists = 'A context with that name already exists';
  RsECannotCreateAContextWithoutAContext = 'Cannot create a context without a context list owner';
  RsEComponentDoesNotSupportTheIJvDataPr = 'Component does not support the IJvDataProvider interface';
  RsEComponentDoesNotSupportTheIInterfac = 'Component does not support the IInterfaceComponentReference interface';
  RsEYouMustSpecifyAProviderBeforeSettin = 'You must specify a provider before setting the context';
  RsEProviderHasNoContextNameds = 'Provider has no context named "%s"';
  RsEProviderDoesNotSupportContexts = 'Provider does not support contexts';
  RsETheSpecifiedContextIsNotPartOfTheSa = 'The specified context is not part of the same provider';
  RsEYouMustSpecifyAProviderBeforeSettin_ = 'You must specify a provider before setting the item';
  RsEItemNotFoundInTheSelectedContext = 'Item not found in the selected context';
  RsEViewListOutOfSync = 'ViewList out of sync';
  RsEProviderIsNoIJvDataConsumer = 'Provider property of ''%s'' does not point to a IJvDataConsumer';
  RsEComponentIsNotDataConsumer = 'Component ''%s'' is not a data consumer';
  RsECannotAddNil = 'Cannot add a nil pointer';
  RsEConsumerNoSupportIJvDataConsumerClientNotify =
    'Consumer does not support the ''IJvDataConsumerClientNotify'' interface';
  RsENotifierNoSupprtIJvDataConsumer = 'Notifier does not support the ''IJvDataConsumer'' interface';
  RsEExtensibleIntObjDuplicateClass = 'Implementation of that class already exists';
  RsEExtensibleIntObjCollectionExpected = 'Expected collection';
  RsEExtensibleIntObjClassNameExpected = 'Missing ClassName property';
  RsEExtensibleIntObjInvalidClass = 'Invalid class type';
  RsEDataProviderNeedsItemsImpl = 'Cannot create a data provider without an IJvDataItems implementation';
//=== JvDatePickerEdit.pas ===================================================
resourcestring
  RsDefaultNoDateShortcut = 'Alt+Del';
  RsEMustHaveADate = '%s must have a date!';
//=== JvDateTimePicker.pas ===================================================
resourcestring
  RsNoneCaption = '(none)';
//=== JvDBActions.pas, JvDynControlEngineDBTools.pas =========================
resourcestring
  RsDBPosDialogCaption = 'Change Current Record Position';
  RsDBPosCurrentPosition = 'Current Position';
  RsDBPosNewPosition = 'New Position';
  RsDBPosMovementType = 'Movement Type';
  RsDBPosAbsolute = 'Absolute';
  RsDBPosBackward = 'Backward';
  RsDBPosForward = 'Forward';
  RsDBPosPercental = 'Percental';
  RsDBPosPositionNormal = ' %3d / %3d ';
  RsDBPosPositionSelected = ' %3d / %3d (%d) ';
  RsDBPosPositionInactive = ' - / - ';
  RsSRWPostButtonCaption = '&Post';
  RsSRWCancelButtonCaption = '&Cancel';
  RsSRWCloseButtonCaption = 'C&lose';
//=== JvDBActions.pas, =======================================================
resourcestring
  SModifyAllOkButton = 'Modify';
  SModifyAllCaption = 'Modify All Records';
  SModifyAllModifyField = 'Modify Field';
  SModifyAllOnlyIfNull = 'Only If Null';
  SModifyAllChangeTo = 'Change To';
  SModifyAllClearFieldValues = 'Clear Field Values';
  SShowSQLStatementCaption = 'Show Current SQL Statement';
  SSQLStatementClipboardButton = '&Clipboard';
  SSQLStatementWordWrapped = '&Word Wrapped';

//=== JvDBControls.pas =======================================================
resourcestring
  RsInactiveData = 'Closed';
  RsBrowseData = 'Browse';
  RsEditData = 'Edit';
  RsInsertData = 'Insert';
  RsSetKeyData = 'Search';
  RsCalcFieldsData = 'Calculate';
//=== JvDBGrid.pas ===========================================================
resourcestring
  RsJvDBGridSelectTitle = 'Select columns';
  //RsJvDBGridSelectOption = '[With the real field name]';
  RsJvDBGridSelectWarning = 'At least one column must be visible!';
  RsEJvDBGridControlPropertyNotAssigned = 'JvDBGrid.EditControls: property Control not assigned';
//=== JvDBUltimGrid.pas ======================================================
resourcestring
  RsEJvDBGridBadFieldKind = 'Cannot sort a binary or special field';
  RsEJvDBGridIndexPropertyMissing = 'Cannot sort. An index property is missing';
  RsEJvDBGridIndexMissing  = 'Cannot sort. The corresponding index is missing';
  RsEJvDBGridUserSortNotAssigned = 'Cannot sort. OnUserSort is not assigned';
//=== JvDBGridExport.pas =====================================================
resourcestring
  RsHTMLExportDocTitle = 'Grid to HTML Export';
  RsExportWord = 'Exporting to MS Word...';
  RsExportExcel = 'Exporting to MS Excel...';
  RsExportHTML = 'Exporting to HTML...';
  RsExportFile = 'Exporting to CSV/Text...';
  RsExportClipboard = 'Exporting to Clipboard...';
  RsEDataSetDataSourceIsUnassigned = 'Dataset or DataSource unassigned';
  RsEGridIsUnassigned = 'No grid assigned';
//=== JvDBLookup.pas =========================================================
resourcestring
  RsEInvalidFormatNotAllowed = 'Invalid format: % not allowed';
  RsEInvalidFormatsNotAllowed = 'Invalid format: %s not allowed';
//=== JvDBQueryParamsForm.pas ================================================
resourcestring
  // (p3) copied from bdeconst so we don't have to include the entire BDE for three strings...
  RsDataTypes =
    ';String;SmallInt;Integer;Word;Boolean;Float;Currency;BCD;Date;Time;DateTime;;;;Blob;Memo;Graphic;;;;;Cursor;';
  RsParamEditor = '%0:s%1:s%2:s Parameters';
  RsEInvalidParamFieldType = 'Must have a valid field type selected';
//=== JvDBTreeView.pas =======================================================
resourcestring
  RsDeleteNode = 'Delete %s ?';
  RsDeleteNode2 = 'Delete %s (with all children) ?';
  RsMasterFieldError = '"MasterField" must be integer type';
  RsDetailFieldError = '"DetailField" must be integer type';
  RsItemFieldError = '"ItemField" must be string, date or integer type';
  RsIconFieldError = '"IconField" must be integer type';
  RsMasterFieldEmpty = '"MasterField" property must be filled';
  RsDetailFieldEmpty = '"DetailField" property must be filled';
  RsItemFieldEmpty = '"ItemField" property must be filled';
  RsEMoveToModeError = 'Invalid move mode for JvDBTreeNode';
  RsMasterDetailFieldError = '"MasterField" and "DetailField" must be of same type';
  RsEDataSetNotActive = 'DataSet not active';
  RsEErrorValueForDetailValue = 'error value for DetailValue';
//=== JvDBUtils.pas ==========================================================
resourcestring
  RsConfirmSave = 'The data has changed. Save it?';
//=== JvDdeCmd.pas ===========================================================
resourcestring
  RsEErrorCommandStart = 'Invalid command start format';
  RsEErrorCommandFormat = 'Invalid command format: %s';
//=== JvDesignImp.pas ========================================================
resourcestring
  RsEDesignCannotSelect = 'Cannot add a nil selection.';
  RsEOldestFmt = '%0:s: Oldest ancestor of Container must be a form.';
//=== JvDesignSurface.pas ====================================================
resourcestring
  RsEDesignNilFmt = '%0:s: %1:s is nil';
//=== JvDesktopAlertForm.pas =================================================
resourcestring
  RsClose = 'Close';
//=== JvDrawImage.pas ========================================================
resourcestring
  RsImageMustBeSquare = 'image must be square for Spirographs';
  RsSumOfRadiTolarge = 'sum of radi too large';
  RsBothRadiMustBeGr = 'both radi must be >%d';
//=== JvDropDownForm.pas =====================================================
resourcestring
  RsETJvCustomDropDownFormCreateOwnerMus = 'TJvCustomDropDownForm.Create: Owner must be a TCustomEdit';
//=== JvDSADialogs.pas =======================================================
resourcestring
  RsInTheCurrentQueue = 'in the current queue';
  RsDSActkShowText = 'Do not show this dialog again';
  RsDSActkAskText = 'Do not ask me again';
  RsDSActkWarnText = 'Do not warn me again';
  RsCntdownText = 'This dialog is closing in %s.';
  RsCntdownMinText = 'minute';
  RsCntdownMinsText = 'minutes';
  RsCntdownSecText = 'second';
  RsCntdownSecsText = 'seconds';
  RsECannotEndCustomReadIfNotInCustomRea = 'Cannot end custom read if not in custom read mode';
  RsECannotEndCustomWriteIfNotInCustomWr = 'Cannot end custom write if not in custom write mode';
  RsECannotEndReadIfNotInReadMode = 'Cannot end read if not in read mode';
  RsECannotEndWriteIfNotInWriteMode = 'Cannot end write if not in write mode';
  RsEJvDSADialogPatchErrorJvDSADialogCom = 'JvDSADialog patch error: JvDSADialog component not found';
  RsEDSARegKeyCreateError = 'Unable to create key %s';
  RsEDSADuplicateID = 'DSA dialog with ID ''%d'' is already assigned to another dialog name';
  RsEDSADuplicateName = 'DSA dialog named ''%s'' is already assigned to another dialog ID';
  RsEDSADialogIDNotFound = 'DSA dialog %d does not exist';
  RsEDSADuplicateCTK_ID = 'CheckMarkText ID %d already registered';
  RsEDSADialogIDNotStored = 'DSA dialog %d has not been stored';
  RsEDSAKeyNotFound = 'Key %s does not exist';
  RsEDSAKeyNoAccessAs = 'Key %0:s cannot be accessed as %1:s';
  RsECtrlHasNoCheckedProp = 'The specified control has no "Checked" property';
  RsECtrlHasNoCaptionProp = 'The specified control has no "Caption" property';
  RsEDialogIDChangeOnlyInDesign = 'The dialog ID can only be changed at design time';
  RsEOnlyAllowedOnForms = 'TJvDSADialog is only allowed on forms';
  RsEAlreadyDSADialog = 'The form already has a TJvDSADialog component';
  RsEDSAAccessBool = 'Boolean';
  RsEDSAAccessFloat = 'Float';
  RsEDSAAccessInt64 = 'Int64';
  RsEDSAAccessInt = 'Integer';
  RsEDSAAccessString = 'string';
//=== JvDualList.pas =========================================================
resourcestring
  RsDualListSrcCaption = '&Source';
  RsDualListDestCaption = '&Destination';
//=== JvDynControlEngine.pas =================================================
resourcestring
  RsEIntfCastError = 'component does not support interface';
  RsEUnsupportedControlClass = 'TJvDynControlEngine.RegisterControl: Unsupported ControlClass "%s"';
  RsENoRegisteredControlClass = 'TJvDynControlEngine.CreateControl: No Registered ControlClass "%s"';
  RsENoFocusControl = 'TJvDynControlEngine.CreateLabelControlPanel: AFocusControl must be assigned';
//=== JvDynControlEngineDB.pas ===============================================
resourcestring
  RsEUnassignedField = 'TJvDynControlEngineDB.GetFieldControlType: AField must be assigned';
  RsEUnassignedMultiple = 'TJvDynControlEngineDB.CreateControlsFromDatasourceOnControl: ADataSource, ADataSource.Dataset and AControl must be assigned';
  RsEUnassignedDataSet = 'TJvDynControlEngineDB.CreateControlsFromDatasourceOnControl: ADataSource.Dataset must be active';
//=== JvEDIDBBuffering.pas ===================================================
resourcestring
  RsENoProfileDatasets = 'Not all profile datasets have been assigned.';
//=== JvEditor.pas, JvUnicodeEditor.pas ======================================
resourcestring
  RsERedoNotYetImplemented = 'Redo not yet implemented';
  RsEInvalidCompletionMode = 'Invalid JvEditor Completion Mode';
//=== JvEmbeddedForms.pas ====================================================
resourcestring
  RsEFormLinkSingleInstanceOnly = 'You only need one form link per form.';
  RsELinkCircularRef = 'Circular references not allowed.';
//=== JvErrorIndicator.pas ===================================================
resourcestring
  RsEControlNotFoundInGetError = 'Control not found in GetError';
  RsEControlNotFoundInGetImageAlignment = 'Control not found in GetImageAlignment';
  RsEControlNotFoundInGetImagePadding = 'Control not found in GetImagePadding';
  RsEUnableToAddControlInSetError = 'Unable to add control in SetError';
  RsEUnableToAddControlInSetImageAlignme = 'Unable to add control in SetImageAlignment';
  RsEUnableToAddControlInSetImagePadding = 'Unable to add control in SetImagePadding';
//=== JvExceptionForm.pas ====================================================
resourcestring
  RsCodeError = '%0:s.' + sLineBreak + 'Error Code: %1:.8x (%1:d).';
  RsModuleError = 'Exception in module %0:s.' + sLineBreak + '%1:s';
//=== JvFindReplace.pas ======================================================
resourcestring
  RsNotFound = 'Search string ''%s'' not found';
  RsXOccurencesReplaced = '%0:d occurence(s) of ''%1:s'' were replaced';
  RsReplaceCaption = 'Replace';
  RsFindCaption = 'Find';
  RsENoEditAssigned = 'No edit control assigned!';
//=== JvFooter.pas ===========================================================
resourcestring
  RsETJvFooterBtnCanOnlyBePlacedOnATJvFo = 'TJvFooterBtn can only be placed on a TJvFooter';
//=== JvForth.pas ============================================================
resourcestring
  RsEInvalidNumbers = 'invalid number %s';
  RsEUnrecognizedDataTypeInSetOperation = 'unrecognized data type in set operation';
  RsEUnterminatedBlockNear = 'unterminated block near ';
  RsEParserTimedOutAfterdSecondsYouMayHa = 'parser timed out after %d seconds; you may have circular includes';
  RsEUnterminatedIncludeNears = 'unterminated include near %s';
  RsEIllegalSpaceCharacterInTheIncludeFi = 'illegal space character in the include file: %s';
  RsECanNotFindIncludeFiles = 'Can not find include file: %s';
  RsEOnIncludeHandlerNotAssignedCanNotHa = 'OnInclude handler not assigned, can not handle include file: %s';
  RsEMissingCommentTerminatorNears = 'missing "}" comment terminator near %s';
  RsEMissingXmlMethodSpecifierNears = 'missing XML method specifier near %s';
  RsEMissingDataSourceMethodSpecifierNea = 'missing data source method specifier near %s';
  RsEMissingSystemMethodSpecifierNears = 'missing system method specifier near %s';
  RsEMissingExternalVariableMethodSpecif = 'missing external variable method specifier near %s';
  RsEMissingInternalVariableMethodSpecif = 'missing internal variable method specifier near %s';
  RsEUndefinedWordsNears = 'undefined word "%0:s" near %1:s';
  RsEScriptTimedOutAfterdSeconds = 'Script timed out after %d seconds';
  RsECanNotAssignVariables = 'can not assign variable %s';
  RsEVariablesNotDefined = 'Variable %s not defined';
  RsEProceduresNotDefined = 'procedure %s not defined';
  RsEVariablesNotDefined_ = 'variable %s not defined';
  RsESystemsNotDefined = 'System %s not defined';
  RsECanNotAssignSystems = 'can not assign System %s';
  RsEUnrecognizedExternalVariableMethodss = 'unrecognized external variable method %0:s.%1:s';
  RsEUnrecognizedInternalVariableMethodss = 'unrecognized internal variable method %0:s.%1:s';
  RsEUnrecognizedSystemMethodss = 'unrecognized system method %0:s.%1:s';
  RsEFilesDoesNotExist = 'File %s does not exist';
  RsECanNotSaveToFiles = 'Can not save to file %s';
  RsEXMLSelectionIsEmpty = 'XML selection is empty';
  RsENoXMLSelectionSelected = 'no XML selection selected';
  RsEXMLSelectionOutOfRange = 'XML selection out of range';
  RsEInvalidXmlMethodSpecifiers = 'invalid XML method specifier %s';
  RsEIncrementIndexExpectedIns = 'Increment Index: "[" expected in %s';
  RsEIncrementIndexExpectedIns_ = 'Increment Index: "]" expected in %s';
  RsEIncrementIndexExpectedIntegerBetwee = 'Increment Index: expected integer between "[..]" in %s';
  RsEDSOIndexOutOfRanged = 'DSO index out of range %d';
  RsEDSOUnknownKeys = 'DSO unknown key %s';
//=== JvFullColorCtrls.pas ===================================================
resourcestring
  RsColorHintFmt1 = 'FullColor: %0:.8x' + sLineBreak +
    'ColorSpace: %1:s (%2:d)' + sLineBreak +
    'Name: %3:s' + sLineBreak +
    'Pretty name: %4:s';
  RsColorHintFmt2 = 'FullColor: %0:.8x, ColorSpace: %1:s (%2:d)' + sLineBreak +
    'Axis %3:s = %4:d' + sLineBreak +
    'Axis %5:s = %6:d' + sLineBreak +
    'Axis %7:s = %8:d';
  RsEDuplicateTrackBar     = 'TrackBar already used by component "%s"';
  RsEUnsupportedColorSpace = 'Unsupported color space "%d"';
//=== JvFullColorDialogs.pas =================================================
resourcestring
  RsExpandedCaption = '<< &Hide';
  RsCollapsedCaption = '&Panels >>';
//=== JvFullColorSpaces.pas ==================================================
resourcestring
  RsENoTypeInfo         = 'The class %s contains no run time type info' + sLineBreak +
    '"Class in module" test cannot be executed';
  RsEUnnamedAxis        = 'Unnamed Color Axis';
  RsEUnnamedSpace       = 'Unnamed Color Space';
  RsEUCS                = 'UCS';
  RsENoName             = 'No Name';
  RsECSNotFound         = 'Color Space not found: %d';
  RsEIllegalID          = 'Color Space ID %d is illegal';
  RsECSAlreadyExists    = 'Color Space Already exists [ID: %0:d, Name: %1:s]';
  RsEInconvertibleColor = 'TColor value $%.8X cannot be converted to TJvFullColor';
  RsRGB_Red       = 'Red';
  RsRGB_Green     = 'Green';
  RsRGB_Blue      = 'Blue';
  RsRGB_FullName  = 'True Color';
  RsRGB_ShortName = 'RGB';
  RsHLS_Hue        = 'Hue';
  RsHLS_Lightness  = 'Lightness';
  RsHLS_Saturation = 'Saturation';
  RsHLS_FullName   = 'Chromatic Vision';
  RsHLS_ShortName  = 'HLS';
  RsCMY_Cyan      = 'Cyan';
  RsCMY_Magenta   = 'Magenta';
  RsCMY_Yellow    = 'Yellow';
  RsCMY_FullName  = 'Substractive Vision';
  RsCMY_ShortName = 'CMY';
  RsYUV_Y         = 'Y Value';
  RsYUV_U         = 'U Value';
  RsYUV_V         = 'V Value';
  RsYUV_FullName  = 'PC Video';
  RsYUV_ShortName = 'YUV';
  RsHSV_Hue        = 'Hue';
  RsHSV_Saturation = 'Saturation';
  RsHSV_Value      = 'Value';
  RsHSV_FullName   = 'Rotation Vision';
  RsHSV_ShortName  = 'HSV';
  RsYIQ_Y         = 'Y';
  RsYIQ_I         = 'I';
  RsYIQ_Q         = 'Q';
  RsYIQ_FullName  = 'NTSC US television standard';
  RsYIQ_ShortName = 'YIQ';
  RsYCC_Y         = 'Y';
  RsYCC_Cr        = 'Cr';
  RsYCC_Cb        = 'Cb';
  RsYCC_FullName  = 'YCrCb';
  RsYCC_ShortName = 'YCC';
  RsXYZ_X         = 'X';
  RsXYZ_Y         = 'Y';
  RsXYZ_Z         = 'Z';
  RsXYZ_FullName  = 'CIE XYZ';
  RsXYZ_ShortName = 'XYZ';
  RsLAB_L         = 'L';
  RsLAB_A         = 'A';
  RsLAB_B         = 'B';
  RsLAB_FullName  = 'CIE LAB';
  RsLAB_ShortName = 'LAB';
  RsDEF_FullName  = 'Delphi predefined colors';
  RsDEF_ShortName = 'DEF';
//=== Jvg3DColors.pas ========================================================
resourcestring
  RsEOnlyOneInstanceOfTJvg3DLocalColors = 'Cannot create more than one instance of TJvg3DLocalColors component';
//=== JvGammaPanel.pas =======================================================
resourcestring
  RsRedFormat = 'R : %3D';
  RsGreenFormat = 'G : %3D';
  RsBlueFormat = 'B : %3D';
  RsHint1 = 'Background Color';
  RsHint2 = 'Foreground Color';
  RsXCaption = 'X';
  RsLabelHint = 'Exchange colors';
  RsDefaultB = 'B : ---';
  RsDefaultG = 'G : ---';
  RsDefaultR = 'R : ---';
//=== JvgAskListBox.pas ======================================================
resourcestring
  RsYes = 'yes';
  RsNo = 'no';
//=== JvgButton.pas ==========================================================
resourcestring
  RsEErrorDuringAccessGlyphsListOrGlyphP = 'Error during access GlyphsList or Glyph property';
//=== JvgCaption.pas =========================================================
resourcestring
  RsEOnlyOneInstanceOfTJvgCaption = 'Cannot create more than one instance of TJvgCaption component';
//=== JvgCheckVersionInfoForm.pas ============================================
resourcestring
  RsNoNewerVersionOfProgramAvailable = 'No newer version of program available';
//=== JvGenetic.pas ==========================================================
resourcestring
  RsENoTest = 'TJvGenetic: OnTestMember must be assigned';
//=== JvgExportComponents.pas ================================================
resourcestring
  RsEDataSetIsUnassigned = 'DataSet is unassigned';
  RsESaveToFileNamePropertyIsEmpty = 'SaveToFileName property is empty';
  RsEExcelNotAvailable = 'Excel not available';
//=== JvgHelpPanel.pas =======================================================
resourcestring
  RsHelp = ' help ';
  RsOpenContextMenuToLoadRTFTextControl = 'Open context menu to load RTF text. Control shows text at runtime only.';
//=== JvgHint.pas ============================================================
resourcestring
  RsEOnlyOneInstanceOfTJvgHint = 'Cannot create more than one instance of TJvgHint component';
//=== JvgHTTPVersionInfo.pas =================================================
resourcestring
  RsEUnknownURLPropertyVersionDataURLIs = 'Unknown URL: property VersionDataURL is empty';
//=== JvGIF.pas ==============================================================
resourcestring
  RsGIFImage = 'CompuServe GIF Image';
  RsEChangeGIFSize = 'Cannot change the Size of a GIF image';
  RsENoGIFData = 'No GIF Data to write';
  RsEUnrecognizedGIFExt = 'Unrecognized extension block: %.2x';
  RsEWrongGIFColors = 'Wrong number of colors; must be a power of 2';
  RsEBadGIFCodeSize = 'GIF code size not in range 2 to 9';
  RsEGIFDecodeError = 'GIF encoded data is corrupt';
  RsEGIFEncodeError = 'GIF image encoding error';
  RsEGIFVersion = 'Unknown GIF version';
//=== JvgLogics.pas ==========================================================
resourcestring
  RsEqualTo = 'equal to';
  RsStartingWith = 'starting with';
  RsEndsWith = 'ends with';
  RsContains = 'contains';
  RsIsContainedWithin = 'is contained within';
  RsNotEmpty = 'not empty';
  RsStep = 'Step ';
  RsComments = 'Comments';
//=== JvgMailSlots.pas =======================================================
resourcestring
  RsJvMailSlotServerErrorCreatingChan = 'Mailslot-Server: Error creating channel!';
  RsJvMailSlotServerErrorGatheringInf = 'Mailslot-Server: Error gathering information!';
  RsJvMailSlotServerErrorReadingMessa = 'Mailslot-Server: Error reading message!';
//=== JvgProgress.pas ========================================================
resourcestring
  RsProgressCaption = 'Progress...[%d%%]';
//=== JvgQPrintPreviewForm.pas ===============================================
resourcestring
  RsPageOfPages = 'Page %0:d of %1:d';
//=== JvGradientHeaderPanel.pas ==============================================
resourcestring
  RsYourTextHereCaption = 'Put your text here ...';
//=== JvgReport.pas ==========================================================
resourcestring
  RsOLELinkedObjectNotFound = 'OLE: Linked object not found.';
  RsErrorText = 'Error';
  RsErrorReadingComponent = 'Error reading component';
//=== JvGridPreviewForm.pas ==================================================
resourcestring
  RsOfd = 'of %d';
  RsPaged = 'Page %d';
  RsNoPrinterIsInstalled = 'No Printer is installed';
//=== JvGridPrinter.pas ======================================================
resourcestring
  RsPrintOptionsPageFooter = 'date|time|page';
  RsPrintOptionsDateFormat = 'd-mmm-yyyy';
  RsPrintOptionsTimeFormat = 'h:nn am/pm';
//=== JvgSingleInstance.pas ==================================================
resourcestring
  RsOneInstanceOfThisProgramIsAlreadyRu =
    'One instance of this program is already running. A second instance launch is not allowed.';
  RsSecondInstanceLaunchOfs = 'Second instance launch of %s';
//=== JvgSmallFontsDefense.pas ===============================================
resourcestring
  RsTJvgSmallFontsDefenseCannotBeUsedWi = 'TJvgSmallFontsDefense cannot be used with large fonts.';
//=== JvgUtils.pas ===========================================================
resourcestring
  RsERightBracketsNotFound = 'Right brackets not found';
  RsERightBracketHavntALeftOnePosd = 'Right bracket does not have a left one. Pos: %d';
  RsEDivideBy = 'Divide by 0';
  RsEDuplicateSignsAtPos = 'Duplicate signs at Pos: %d';
  RsEExpressionStringIsEmpty = 'Expression string is empty';
  {$IFDEF glDEBUG}
  RsEObjectMemoryLeak = 'object memory leak';
  {$ENDIF glDEBUG}
//=== JvgXMLSerializer.pas ===================================================
resourcestring
  { RUSSIAN
  RsOpenXMLTagNotFound = 'Îòêðûâàþùèé òåã íå íàéäåí: <%s>';
  RsCloseXMLTagNotFound = 'Çàêðûâàþùèé òåã íå íàéäåí: </%s>';
  RsUncknownProperty = 'Uncknown property: %s'
  }
  RsOpenXMLTagNotFound = 'Open tag not found: <%s>';
  RsCloseXMLTagNotFound = 'Close tag not found: </%s>';
  RsUnknownProperty = 'Unknown property: %s';
//=== JvHidControllerClass.pas ===============================================
resourcestring
  RsUnknownLocaleIDFmt = 'Unknown Locale ID $%.4x';
  RsHIDP_STATUS_NULL = 'Device not plugged in';
  RsHIDP_STATUS_INVALID_PREPARSED_DATA = 'Invalid preparsed data';
  RsHIDP_STATUS_INVALID_REPORT_TYPE = 'Invalid report type';
  RsHIDP_STATUS_INVALID_REPORT_LENGTH = 'Invalid report length';
  RsHIDP_STATUS_USAGE_NOT_FOUND = 'Usage not found';
  RsHIDP_STATUS_VALUE_OUT_OF_RANGE = 'Value out of range';
  RsHIDP_STATUS_BAD_LOG_PHY_VALUES = 'Bad logical or physical values';
  RsHIDP_STATUS_BUFFER_TOO_SMALL = 'Buffer too small';
  RsHIDP_STATUS_INTERNAL_ERROR = 'Internal error';
  RsHIDP_STATUS_I8042_TRANS_UNKNOWN = '8042 key translation impossible';
  RsHIDP_STATUS_INCOMPATIBLE_REPORT_ID = 'Incompatible report ID';
  RsHIDP_STATUS_NOT_VALUE_ARRAY = 'Not a value array';
  RsHIDP_STATUS_IS_VALUE_ARRAY = 'Is a value array';
  RsHIDP_STATUS_DATA_INDEX_NOT_FOUND = 'Data index not found';
  RsHIDP_STATUS_DATA_INDEX_OUT_OF_RANGE = 'Data index out of range';
  RsHIDP_STATUS_BUTTON_NOT_PRESSED = 'Button not pressed';
  RsHIDP_STATUS_REPORT_DOES_NOT_EXIST = 'Report does not exist';
  RsHIDP_STATUS_NOT_IMPLEMENTED = 'Not implemented';
  RsUnknownHIDFmt = 'Unknown HID error %x';
  RsHIDErrorPrefix = 'HID Error: ';
  RsEDirectThreadCreationNotAllowed = 'Direct creation of a TJvDeviceReadThread object is not allowed';
  RsEDirectHidDeviceCreationNotAllowed = 'Direct creation of a TJvHidDevice object is not allowed';
  RsEDeviceCannotBeIdentified = 'Device cannot be identified';
  RsEDeviceCannotBeOpened = 'Device cannot be opened';
  RsEOnlyOneControllerPerProgram = 'Only one TJvHidDeviceController allowed per program';
  RsEHIDBooleanError = 'HID Error: a boolean function failed';
//=== JvHint.pas =============================================================
resourcestring
  RsHintCaption = 'Hint';
//=== JvHLEditorPropertyForm.pas =============================================
resourcestring
  RsHLEdPropDlg_Caption = 'Editor Properties';
  RsHLEdPropDlg_tsEditor = 'Editor';
  RsHLEdPropDlg_tsColors = 'Colors';
  RsHLEdPropDlg_lblEditorSpeedSettings = 'Editor SpeedSettings';
  RsHLEdPropDlg_cbKeyboardLayoutDefault = 'Default keymapping';
  RsHLEdPropDlg_gbEditor = 'Editor options:';
  RsHLEdPropDlg_cbAutoIndent = '&Auto indent mode';
  RsHLEdPropDlg_cbSmartTab = 'S&mart tab';
  RsHLEdPropDlg_cbBackspaceUnindents = 'Backspace &unindents';
  RsHLEdPropDlg_cbGroupUndo = '&Group undo';
  RsHLEdPropDlg_cbCursorBeyondEOF = 'Cursor beyond &EOF';
  RsHLEdPropDlg_cbCursorBeyondEOL = 'Cursor beyond end of &line';
  RsHLEdPropDlg_cbUndoAfterSave = '&Undo after sa&ve';
  RsHLEdPropDlg_cbKeepTrailingBlanks = '&Keep trailing blanks';
  RsHLEdPropDlg_cbDoubleClickLine = '&Double click line';
  RsHLEdPropDlg_cbSytaxHighlighting = 'Use &syntax highlight';
  RsHLEdPropDlg_lblTabStops = '&Tab stops:';
  RsHLEdPropDlg_lblColorSpeedSettingsFor = 'Color SpeedSettings for';
  RsHLEdPropDlg_lblElement = '&Element:';
  RsHLEdPropDlg_lblColor = '&Color:';
  RsHLEdPropDlg_gbTextAttributes = 'Text attributes:';
  RsHLEdPropDlg_gbUseDefaultsFor = 'Use defaults for:';
  RsHLEdPropDlg_cbBold = '&Bold';
  RsHLEdPropDlg_cbItalic = '&Italic';
  RsHLEdPropDlg_cbUnderline = '&Underline';
  RsHLEdPropDlg_cbDefForeground = '&Foreground';
  RsHLEdPropDlg_cbDefBackground = '&Background';
  RsHLEdPropDlg_OptionCantBeChanged = 'This option cannot be changed. Sorry.';
  RsEHLEdPropDlg_RAHLEditorNotAssigned = 'JvHLEditor property is not assigned';
  RsEHLEdPropDlg_RegAutoNotAssigned = 'RegAuto property is not assigned';
  RsEHLEdPropDlg_GridCellNotFound = 'Grid cell not found';
//=== JvHTTPGrabber.pas ======================================================
resourcestring
  RsAgent = 'TJvHTTPGrabber Delphi Component';
//=== JvId3v1.pas ============================================================
resourcestring
  RsENotActive = 'Not active';
//=== JvID3v2Base.pas ========================================================
resourcestring
  RsENameMsgFormat = '%0:s: %1:s';
  RsEAllowedEncodingsIsEmpty = 'FAllowedEncodings is empty';
  RsEAlreadyReadingWriting = 'Already reading or writing';
  RsEAlreadyReadingWritingFrame = 'Already reading/writing frame';
  RsEAlreadyUsingTempStream = 'Already using temp stream';
  RsECannotCallCanRead = 'Cannot call CanRead while writing';
  RsEControllerDoesNotSupportCompression = 'Controller does not support compression';
  RsEControllerDoesNotSupportCRC = 'Controller does not support CRC';
  RsEControllerDoesNotSupportEncryption = 'Controller does not support encryption';
  RsEControllerDoesNotSupportFooter = 'Controller does not support footer';
  RsECouldNotFindAllowableEncoding = 'Could not find allowable encoding';
  RsECouldNotReadData = 'Could not read data from stream';
  RsEErrorInFrame = 'Error in frame %0:s (%1:s), %2:s';
  RsEFrameSizeDiffers = 'Frame size differs from actually amount of data written';
  RsEFrameSizeTooBig = 'Frame size is too big';
  RsELanguageNotOfLength3 = 'Language is not of length 3';
  RsENoTempStream = 'No temp stream';
  RsENotReadingFrame = 'Not reading frame';
  RsENotUsingTempStream = 'Not using temp stream';
  RsENotWriting = 'Not writing';
  RsENotWritingFrame = 'Not writing frame';
  RsETagTooBig = 'Tag is too big';
  RsEValueTooBig = 'Cannot write value in v2.2; too big';
  RsENotReading = 'Not reading';
  RsEID3FrameNotFound = 'Frame not found';
  RsEID3UnknownEncoding = 'Unknown encoding';
  RsEID3UnknownVersion = 'Unknown version';
  RsEID3DuplicateFrame = 'Frame is a duplicate of another frame in the tag';
  RsEID3AlreadyContainsFrame = 'Tag already contains a ''%s'' frame';
  RsEID3ControllerNotActive = 'Controller is not active';
  RsEID3EncodingNotSupported = 'Encoding not supported in this version';
  RsEID3VersionNotSupported = 'Version not supported';
  RsEID3InvalidLanguageValue = '''%s'' is an invalid language value';
  RsEID3InvalidPartInSetValue = '''%s'' is an invalid ''part in set'' value';
  RsEID3InvalidTimeValue = '''%s'' is an invalid time value.' + sLineBreak + 'Value must be of format ''HHMM''';
  RsEID3InvalidDateValue = '''%s'' is an invalid date value.' + sLineBreak + 'Value must be of format ''DDMM''';
  RsEID3ValueTooBig = '''%d'' is an invalid value. Value is too big';
  RsEID3StringTooLong = '''%s'' is an invalid value. String is too long';
  RsEID3InvalidCharinList = 'Invalid char ''%0:s'' in string ''%1:s'' in list';
  RsEID3InvalidFrameClass = 'Frame class ''%0:s'' cannot be used to represent frame ID ''%1:s''';
  RsEID3FrameIDNotSupported = 'Frame ID ''%s'' not supported by this frame';
  RsEID3FrameIDStrNotSupported = 'Frame ID string ''%s'' not supported by this frame';
//=== JvId3v2Types.pas =======================================================
resourcestring
  RsEFrameIDSizeCanOnlyBe34 = 'Frame ID size can only be 3 or 4';
//=== JvImageDlg.pas =========================================================
resourcestring
  RsImageTitle = 'Image Viewer';
//=== JvImageList.pas ========================================================
resourcestring
  RsResource = 'Resource %s';
  RsMappedResource = 'Mapped Resource %s';
  RsBitmap = 'Bitmap %s';
  RsEWrongImageListMode = 'Wrong image list mode. For this function the mode must be %s';
//=== JvImageWindow.pas ======================================================
resourcestring
  RsEImagesNotAssigned = 'Images not Assigned!';
//=== JvInspector.pas ========================================================
resourcestring
  RsJvInspItemValueException = 'Exception ';
  RsJvInspItemUnInitialized = '(uninitialized)';
  RsJvInspItemUnassigned = '(unassigned)';
  RsJvInspItemNoValue = '(no value)';
  RsStringListEditorCaption = 'String list editor';
  RsXLinesCaption = ' lines';
  RsOneLineCaption = '1 line';
  RsEJvInspItemHasParent = 'Item already assigned to another parent';
  RsEJvInspItemNotAChild = 'Specified Item is not a child of this item';
  RsEJvInspItemColNotFound = 'Specified column does not belong to this compound item';
  RsEJvInspItemItemIsNotCol = 'Specified item is not a column of this compound item';
  RsEJvInspItemInvalidPropValue = 'Invalid property value %s';
  RsEJvInspDataNoAccessAs = 'Data cannot be accessed as %s';
  RsEJvInspDataNotInit = 'Data not initialized';
  RsEJvInspDataNotAssigned = 'Data not assigned';
  RsEJvInspDataNoValue = 'Data has no value';
  RsEJvInspDataStrTooLong = 'String too long';
  RsEJvInspRegNoCompare = 'Cannot compare %0:s to %1:s';
  RsEJvInspNoGenReg = 'Unable to create generic item registration list';
  RsEJvInspPaintNotActive = 'Painter is not the active painter of the specified inspector';
  RsEJvInspPaintOnlyUsedOnce = 'Inspector painter can only be linked to one inspector';
  RsEInspectorInternalError = 'Internal error: two data instances pointing to the same data are registered';
  RsESpecifierBeforeSeparator = 'A specifier should be placed before and after a separator';
  RsEDOrDDOnlyOnce = '''d'' or ''dd'' should appear only once';
  RsEMOrMMOnlyOnce = '''m'' or ''mm'' should appear only once';
  RsEYYOrYYYYOnlyOnce = '''yy'' or ''yyyy'' should appear only once';
  RsEOnlyDOrDDAllowed = 'Only ''d'' or ''dd'' are allowed';
  RsEOnlyMOrMMAllowed = 'Only ''m'' or ''mm'' are allowed';
  RsEOnlyYYOrYYYYAllowed = 'Only ''yy'' or ''yyyy'' are allowed';
  RsEOnlyTwoSeparators = 'Only two separators are allowed';
  RsEOnlyDMYSAllowed = 'Only ''d'', ''m'', ''y'' and ''%s'' are allowed';
  RsEDOrDDRequired = '''d'' or ''dd'' are required';
  RsEMOrMMRequired = '''m'' or ''mm'' are required';
  RsEYYOrYYYYRequired = '''yy'' or ''yyyy'' are required';
  RsEInstanceAlreadyExists = 'Instance already exists with another name';
  RsENameAlreadyExistsForInstance = 'Name already exists for another instance';
  RsEInstanceNonexistent = 'Instance does not exist';
  RsEMethodAlreadyExists = 'Method already exists with another name';
  RsENameAlreadyExistsForMethod = 'Name already exists for another method';
  RsENamedInstanceNonexistent = 'Instance named ''%s'' does not exist';
  RsEMethodNonexistent = 'Method does not exist';
  RsENamedMethodNonexistent = 'Method named ''%s'' does not exist';
  RsENotSeparately = '%s cannot be created separately';
  RsENoNewInstance = '%s does not allow a new instance to be created';
  // (rom) converted assertions
  RsEJvAssertSetTopIndex = 'TJvCustomInspector.SetTopIndex: unexpected MaxIdx <= -1';
  RsEJvAssertInspectorPainter = 'TJvInspectorCustomCompoundItem.DivideRect: unexpected Inspector.Painter = nil';
  RsEJvAssertDataParent = 'TJvInspectorSetMemberData.New: unexpected ADataParent = nil';
  RsEJvAssertParent = 'TJvInspectorSetMemberData.New: unexpected AParent = nil';
  RsEJvAssertPropInfo = 'TJvInspectorPropData.New: unexpected PropInfo = nil';
  RsEJvAssertClassInfo = 'TJvInspectorPropData.New: unexpected ClassInfo = nil';
  RsEJvAssertINIFile = 'TJvInspectorINIFileData.New: unexpected AINIFile = nil';
//=== JvInspXVCL.pas =========================================================
resourcestring
  RsENoNodeSpecified = 'TJvInspectorxNodeData.New: No node specified';
//=== JvInstallLabel.pas =====================================================
resourcestring
  RsEListOutOfBounds = 'List index out of bounds (%d)';
//=== JvInterpreter.pas ======================================================
resourcestring
  RsNotImplemented = 'Function not yet implemented';
  RsOleAutomationCall = 'Ole automation call';
  RsESorryDynamicArraysSupportIsMadeForO = 'Sorry. Dynamic arrays support is made for one-dimensional arrays only';
  RsEUnknownRecordType = 'Unknown RecordType';
  RsERangeCheckError = 'Range check error';
  RsArrayToArrayAssignment = 'Array to array assignment';
//=== JvInterpreter_Quickrpt.pas =============================================
resourcestring
  RsENoQuickReportFound = 'TQuickRep component not found on the form';
//=== JvInterpreter_System.pas ===============================================
resourcestring
  RsESizeMustBeEven = 'The size of bounds array must be even!';
//=== JvInterpreterConst.pas =================================================
resourcestring
  RsEInterpreter0 = 'Ok';
  RsEInterpreter1 = 'Unknown error';
  RsEInterpreter2 = 'Internal interpreter error: %s';
  RsEInterpreter3 = 'User break';
  RsEInterpreter4 = 'Re-raising an exception only allowed in exception handler';
  RsEInterpreter5 = 'Error in unit ''%0:s'' on line %1:d : %2:s';
  RsEInterpreter6 = 'External error in unit ''%0:s'' on line %1:d : %2:s';
  RsEInterpreter7 = 'Access denied to ''%s''';
  RsEInterpreter8 = 'Expression is too complex - overflow';
  RsEInterpreter31 = 'Record ''%s'' not defined';
  RsEInterpreter52 = 'Stack overflow';
  RsEInterpreter53 = 'Type mismatch';
  RsEInterpreter55 = 'Function ''main'' undefined';
  RsEInterpreter56 = 'Unit ''%s'' not found';
  RsEInterpreter57 = 'Event ''%s'' not registered';
  RsEInterpreter58 = 'DFM ''%s'' not found';
  RsEInterpreter101 = 'Error in remark'; // (rom) in comment?
  RsEInterpreter103 = '%0:s expected but %1:s found';
  RsEInterpreter104 = 'Undeclared Identifier ''%s''';
  RsEInterpreter105 = 'Type of expression must be boolean';
  RsEInterpreter106 = 'Class type required';
  RsEInterpreter107 = ' not allowed before else';
  RsEInterpreter108 = 'Type of expression must be integer';
  RsEInterpreter109 = 'Record, object or class type required';
  RsEInterpreter110 = 'Missing operator or semicolon';
  RsEInterpreter111 = 'Identifier redeclared: ''%s''';
  RsEInterpreter171 = 'Array index out of bounds';
  RsEInterpreter172 = 'Too many array bounds';
  RsEInterpreter173 = 'Not enough array bounds';
  RsEInterpreter174 = 'Invalid array dimension';
  RsEInterpreter175 = 'Invalid array range';
  RsEInterpreter176 = 'Array type required';
  RsEInterpreter181 = 'Too many actual parameters';
  RsEInterpreter182 = 'Not enough parameters';
  RsEInterpreter183 = 'Incompatible types: ''%0:s'' and ''%1:s''';
  RsEInterpreter184 = 'Error loading library ''%s''';
  RsEInterpreter185 = 'Invalid type of argument in call to function ''%s''';
  RsEInterpreter186 = 'Invalid type of result in call to function ''%s''';
  RsEInterpreter187 = 'Can''t get proc address for function ''%s''';
  RsEInterpreter188 = 'Invalid type of argument in call to function ''%s''';
  RsEInterpreter189 = 'Invalid type of result in call to function ''%s''';
  RsEInterpreter190 = 'Invalid calling convention for function ''%s''';
  RsEInterpreter201 = 'Calling ''%0:s'' failed: ''%1:s''';
  RsEInterpreter301 = 'Expression';
  RsEInterpreter302 = 'Identifier';
  RsEInterpreter303 = 'Declaration';
  RsEInterpreter304 = 'End of File';
  RsEInterpreter305 = 'Class Declaration';
  RsEInterpreter306 = 'Integer Constant''';
  RsEInterpreter307 = 'Integer Value';
  RsEInterpreter308 = 'String Constant';
  RsEInterpreter309 = 'Statement';
  RsEInterpreter401 = 'Implementation of unit not found';
  RsEInterpreter402 = 'Array and Record types are not allowed as procedure/function parameter';
  RsEXOrX = ''' or ''';
//=== JvInterpreterFm.pas ====================================================
resourcestring
  RsENoReportProc = 'Procedure "JvInterpreterRunReportPreview" not found';
  RsENoReportProc2 = 'Procedure "JvInterpreterRunReportPreview2" not found';
//=== JvJanTreeView.pas ======================================================
resourcestring
  RsSaveCurrentTree = 'Save Current Tree';
  RsSearch = 'Search';
  RsSearchFor = 'Search for:';
  RsNoMoresFound = 'No more %s found';
  RsEInvalidReduction = 'Invalid reduction';
  RsEBadTokenState = 'Bad token state';
  RsTreeViewFiles = 'TreeView Files';
  RsNewNode = 'new node';
  RsNew = 'new';
  RsRecalculateErr = 'Error in: %s';
//=== JvJoystick.pas =========================================================
resourcestring
  RsNoJoystickDriver = 'The joystick driver is not present.';
  RsCannotCaptureJoystick = 'Cannot capture the joystick';
  RsJoystickUnplugged = 'The specified joystick is not connected to the system.';
  RsJoystickErrorParam = 'The specified joystick device identifier is invalid.';
  RsEJoystickError = 'Unable to initialize joystick driver';
//=== JvJVCLUtils.pas ========================================================
resourcestring
  RsENotForMdi = 'MDI forms are not allowed';
  RsEPixelFormatNotImplemented = 'BitmapToMemoryStream: pixel format not implemented';
  RsEBitCountNotImplemented = 'BitmapToMemoryStream: bit count not implemented';
  RsECantGetShortCut = 'Target FileName for ShortCut %s not available';
  RsEBadGraphicSignature = 'Bad Graphic Signature';
  RsEChildControlMissing = 'Child control is nil';
//=== JvLinkedControls.pas ===================================================
resourcestring
  RsEOwnerLinkError = 'Cannot link to owner control';
//=== JvLinkLabel.pas ========================================================
resourcestring
  RsEUnableToLocateMode = 'Unable to locate specified node';
  RsETagNotFound = 'TJvCustomLinkLabel.UpdateDynamicTag: Tag not found';
//=== JvLinkLabelParser.pas ==================================================
resourcestring
  RsENoMoreElementsToReturn = 'TElementEnumerator.GetNextElement: No more elements to return';
  RsEUnsupportedState = 'TDefaultParser.ParseNode: Unsupported state';
//=== JvLinkLabelTextHandler.pas =============================================
resourcestring
  RsENoMoreWords = 'TWordEnumerator.GetNext: No more words to return';
  RsEUnsupported = 'TTextHandler.EmptyBuffer: Unsupported TParentTextElement descendant encountered';
//=== JvLinkLabelTools.pas ===================================================
resourcestring
  RsECannotBeInstantiated = 'This class cannot be instantiated';
//=== JvLinkLabelTree.pas ====================================================
resourcestring
  RsETNodeGetNodeTypeUnknownClass = 'TNode.GetNodeType: Unknown class';
  RsENoMoreNodesToReturn = 'No more nodes to return';
  RsENoMoreRecordsToReturn = 'No more records to return';
  RsEWordInfoIndexOutOfBounds = 'TStringNode.GetWordInfo: Index out of bounds';
//=== JvListView.pas =========================================================
resourcestring
  RsETooManyColumns = 'TJvListView.GetColumnsOrder: too many columns';
//=== JvLoginForm.pas ========================================================
resourcestring
  RsRegistrationCaption = 'Registration';
  RsAppTitleLabel = 'Application "%s"';
  RsHintLabel = 'Type your user name and password to enter the application';
  RsUserNameLabel = '&User name:';
  RsPasswordLabel = '&Password:';
  RsUnlockCaption = 'Unlock application';
  RsUnlockHint = 'Type your password to unlock the application';
//=== JvMail.pas =============================================================
resourcestring
  RsAttachmentNotFound = 'Attached file "%s" not found';
  RsRecipNotValid = 'Recipient %s has invalid address';
  RsNoClientInstalled = 'There is no MAPI-enabled client on the machine';
  RsNoUserLogged = 'There must be a user logged before call this function';
//=== JvMemoryDataset.pas ====================================================
resourcestring
  RsEMemNoRecords = 'No data found';
  // 'Registro ya existente.';
  RsERecordDuplicate = 'Record already exists.';
  // 'Registro no encontrado.';
  RsERecordInexistent = 'Record not found.';
  // 'No se pudo agregar el registro.';
  RsEInsertError = 'Unable to append the record.';
  // 'No se pudo modificar el registro.';
  RsEUpdateError = 'Unable to modify the record.';
  // 'No se pudo eliminar el registro.';
  RsEDeleteError = 'Unable to erase the record.';
  RsEFieldOffsetOverflow = 'Field offset overflow. Index: %0:d';
//=== JvMouseGesture.pas =====================================================
resourcestring
  RsECannotHookTwice = 'JvMouseGesture Fatal: You cannot hook this event twice';
//=== JvMRUList.pas ==========================================================
resourcestring
  RsEErrorMruCreating = 'Unable to create MRU';
  RsEErrorMruUnicode = 'Windows NT required for Unicode in MRU';
//=== JvMRUManager.pas =======================================================
resourcestring
  RsEDuplicatesNotAllowedInMRUList = 'Duplicates not allowed in MRU list';
//=== JvMTComponents.pas =====================================================
resourcestring
  RsENoThreadManager = 'No ThreadManager specified';
  RsEOperatorNotAvailable = 'Operation not available while thread is active';
  RsECannotChangePropertySection = 'Cannot change property of active section';
  RsECannotChangePropertyBuffer = 'Cannot change property of active buffer';
//=== JvMTData.pas ===========================================================
resourcestring
  RsEMethodOnlyForMainThread = '%s method can only be used by the main VCL thread';
//=== JvMTSync.pas ===========================================================
resourcestring
  RsESemaphoreFailure = 'Semaphore failure (%d)';
  RsESemaphoreAbandoned = 'Semaphore was abandoned';
  RsEThreadAbandoned = 'Thread was abandoned';
//=== JvMTThreading.pas ======================================================
resourcestring
  RsECurThreadIsPartOfManager = 'Current MTThread is part of the MTManager';
  RsECheckTerminateCalledByWrongThread = 'CheckTerminate can only be called by the same thread';
  RsEThreadNotInitializedOrWaiting = 'Cannot run: thread is not Initializing or Waiting';
  RsECannotChangeNameOfOtherActiveThread = 'Cannot change name of other active thread';
  RsEReleaseOfUnusedTicket = 'Release of unused ticket';
//=== JvMultiHttpGrabber.pas =================================================
resourcestring
  RsErrorConnection = 'Unable to connect';
  RsMultiAgent = 'TJvMultiHTTPGrabber Delphi Component';
//=== JvNavigationPane.pas ===================================================
resourcestring
  RsEUnsupportedButtonType = 'ButtonType not supported';
//=== JvNTEventLog.pas =======================================================
resourcestring
  RsLogError = 'Error';
  RsLogWarning = 'Warning';
  RsLogInformation = 'Information';
  RsLogSuccessAudit = 'Success Audit';
  RsLogFailureAudit = 'Failure Audit';
  RsLogUserSIDNotFound = 'User SID not found';
//=== JvObjectPickerDialog.pas ===============================================
resourcestring
  RsEAttributeIndexOutOfBounds = '%d is not a valid attribute index';
  RsESelectionIndexOutOfBounds = '%d is not a valid selection index';
//=== JvOfficeColorButton.pas ================================================
resourcestring
  RsDragToFloating = 'Drag to floating';
//=== JvOfficeColorForm.pas ==================================================
resourcestring
  RsColorWindow = 'Color Window';
  // (rom) probably the same as RsDragToFloating
  RsDragToFloat = 'Drag to float';
//=== JvOfficeColorPanel.pas =================================================
resourcestring
  RsNoneColorCaption = 'No Color';
  RsDefaultColorCaption = 'Automatic';
  RsCustomColorCaption = 'Other Colors...';
//=== JvOracleDataset.pas ====================================================
resourcestring
  RsODSOpenFetch = 'Open / Fetch : ';
  RsODSCurrentRecord = 'Current Record : ';
  RsODSRowsFetchedContinue = '%d rows fetched. Continue ? ';
  RsODSContinueYes = '&Yes';
  RsODSContinuePause = '&Pause';
  RsODSContinueNo = '&No';
  RsODSContinueClose = '&Close';
  RsODSContinueAll = '&All';
  RsODSGotoLastFetchRecords = 'Goto Last - Fetch Records';
  RsODSFetchRecords = 'Fetch Records';
  RsODSOpenQueryFetchRecords = 'Open Query - Fetch Records';
  RsODSFetchRecordsCancel = 'Fetch Records - Cancel';
  RsODSOpenQuery = 'Open Query';
  RsODSOpenQueryCancel = 'Open Query - Cancel' ;
  RsODSRefreshQueryFetchRecords = 'Refresh Query - Fetch Records';
  RsODSRefreshQuery = 'Refresh Query';
  RsODSRefreshQueryCancel = 'Refresh Query - Cancel';
//=== JvPageSetup.pas ========================================================
resourcestring
  RsEInvalidValue = 'Value must be greater than zero';
//=== JvPainterQBForm.pas ====================================================
resourcestring
  RsPainterQuickBackdrops = 'Painter Quick Backdrops';
  RsEnterName = 'Enter Name:';
  RsNoItemSelected = 'No item selected!';
  RsErrorInPresets = 'Error in Presets';
//=== JvParameterList.pas ====================================================
resourcestring
  RsErrParameterMustBeEntered = 'Parameter "%s" must be entered!';
  RsHistorySelectPath = 'History';
  RsDialogCaption = '';
  RsCancelButton = '&Cancel';
  RsHistoryLoadButton = '&Load';
  RsHistorySaveButton = '&Save';
  RsHistoryClearButton = 'Cl&ear';
  RsHistoryLoadCaption = 'Load Parameter Settings';
  RsHistorySaveCaption = 'Save Parameter Settings';
  RsHistoryClearCaption = 'Manage Parameter Settings';
  RsENoParametersDefined = 'TJvParameterList.ShowParameterDialog: No Parameters defined';
  RsEAddObjectWrongObjectType = 'TJvParameterList.AddObject: Wrong object type';
  RsEAddObjectSearchNameNotDefined = 'TJvParameterList.AddObject: SearchName not defined';
  RsEAddObjectDuplicateSearchNamesNotAllowed = 'TJvParameterList.AddObject: Duplicate SearchNames ("%s") not allowed';
  RsECreateWinControlsOnWinControlDuplicateBeforeAfterNotAllowed = 'TJvParameterList.CreateWinControlsOnWinControl: %s "%s" already used';
//=== JvParameterListParameter.pas ===========================================
resourcestring
  // RsErrParameterMustBeEntered = 'Parameter %s must be entered!';
  RsErrParameterIsNotAValidNumber = 'Parameter %0:s: %1:s is not a valid number value!';
  RsErrParameterMustBeBetween = 'Parameter %0:s: %1:s must be between %2:s and %3:s!';
  RsErrParameterFileDoesNotExist = 'Parameter %0:s: The file "%1:s" does not exist!';
  RsErrParameterFileExistOverwrite = 'Parameter %0:s: The file "%1:s" exists! Overwrite?';
  RsErrParameterDirectoryNotExist = 'Parameter %0:s: The directory "%1:s" does not exist!';
//=== JvParameterListTools.pas ===============================================
resourcestring
  RsSelectCaption = 'Select...';
//=== JvParserForm.pas =======================================================
resourcestring
  RsNewObject = 'New';
//=== JvPatchForm.pas ========================================================
resourcestring
  RsJvPatcherEditorComparingFilesd = 'Jv - Patcher Editor: Comparing files %d%%';
  RsJvPatcherEditorEndStep = 'Jv - Patcher Editor: end step ...';
  RsErrJvPatcherEditorInvalidFilename = 'Invalid filename(s). Please specify valid filenames for both source and destination and try again.';
//=== JvPcx.pas ==============================================================
resourcestring
  RsPcxExtension = 'pcx';
  RsPcxFilterName = 'PCX Image';
  RsEPcxUnknownFormat = 'PCX: Unknown format';
  RsEPcxPaletteProblem = 'PCX: Unable to retrieve palette';
  RsEPcxInvalid = 'PCX: Invalid PCX file';
//=== JvPerfMon95.pas ========================================================
resourcestring
  RsWrongOS = 'TJvPerfMon95 component is intended for Win95/98 only';
  RsECantOpenPerfKey = 'Performance registry key not found';
  RsECantStart = 'Cannot start performance statistics (%s)';
  RsECantStop = 'Cannot stop performance statistics (%s)';
  RsEKeyNotExist = 'Specified key "%s" does not exist';
//=== JvPickDate.pas =========================================================
resourcestring
  RsNextYearHint = 'Next Year|';
  RsNextMonthHint = 'Next Month|';
  RsPrevYearHint = 'Previous Year|';
  RsPrevMonthHint = 'Previous Month|';
//=== JvPlugin.pas ===========================================================
resourcestring
  RsEFmtResNotFound = 'Resource not found: %s';
//=== JvPluginManager.pas ====================================================
resourcestring
  RsEErrEmptyExt = 'Extension may not be empty';
  RsEPluginPackageNotFound = 'Plugin package not found: %s';
  RsERegisterPluginNotFound = 'Plugin function %0:s not found in %1:s';
  RsERegisterPluginFailed = 'Calling %0:s in %1:s failed';
//=== JvPoweredBy.pas ========================================================
resourcestring
  RsURLPoweredByJCL = 'http://jcl.delphi-jedi.org/';
  RsURLPoweredByJVCL = 'http://jvcl.delphi-jedi.org/';
//=== JvProfilerForm.pas =====================================================
resourcestring
  RsTotalElapsedTimedms = '%0:s -  total elapsed time: %1:d (ms)';
  RsTextFormatsasctxtinfdocAllFiles = 'Text formats|*.asc;*.txt;*.inf;*.doc|All files|*.*';
  RsDefCaption = 'Profiler 32 Report';
  RsDefHeader = 'Profiler 32 run %0:s by "%1:s" (machine %2:s).';
  RsEMaxNumberOfIDsExceededd = 'Max number of ID''s exceeded (%d)';
  RsEMaxStackSizeExceededd = 'Max stack size exceeded (%d)';
//=== JvProgramVersionCheck.pas ==============================================
resourcestring
  RsPVFailedUnableToConnectTo = 'Failed: Unable to connect to %s';
  RsPVFailedUnableToGet = 'Failed: Unable to get %s';
  RsPVDownloadFailed = 'Failed: %s';
  RsPVDefaultVersioninfoFileName = 'versioninfo.ini';
  RsPVTempFileNameExtension = '.temp';
  RsPVSiceB = '%6f B';
  RsPVSiceKB = '%6.2f KB';
  RsPVSiceMB = '%6.2f MB';
  RsPVSiceGB = '%6.2f GB';
  RsPVCReleaseTypeAlpha = 'Alpha';
  RsPVCReleaseTypeBeta = 'Beta';
  RsPVCReleaseTypeProduction = 'Production';
  RsPVCDownloading = 'Downloading ...';
  RsPVCDialogCaption = '%s Upgrade Check';
  RsPVCDialogExecuteButton = '&Execute';
  RsPVCNewVersionAvailable = 'A new version (%0:s) of %1:s is available!';
  RsPVCChooseWhichVersion = 'Which &version do you want to install?';
  RsPVCChooseOperation = '&Choose Operation';
  RsPVCOperationIgnore = 'I&gnore';
  RsPVCOperationDownloadOnly = 'Download/Copy &Only';
  RsPVCOperationDownloadInstall = 'Download/Copy and &Install';
  RsPVCWhatNewInS = 'What''s new in %s';
  RsPVCChangesBetween = 'Changes between %0:s and %1:s';
  RsPVCFileDownloadNotSuccessful =
    'The file download was not successful!' + sLineBreak + 'Please try again manually.';
  RsPVCDownloadSuccessfulInstallManually =
    'The file download was successful.' + sLineBreak + 'Install manually from: %s';
  RsPVCErrorStartingSetup = 'Error starting the setup process.';
  RsPVCDownloadSuccessfullInstallNow =
    'The file download was successful.' + sLineBreak +
    'Do you want to close and install?';
  RsPVInfoButtonCaption = 'Info';
  RSProgramVersionInfo_PropertyHint_ProgramReleaseDate = 'Date of Release ';
  RSProgramVersionInfo_PropertyHint_ProgramSize = 'Size of the installer in bytes ';
  RSProgramVersionInfo_PropertyHint_ProgramReleaseType = 'Release type of the version.'#13#10+
    'In the update dialog there are only the highest version numbers for each type visible.'#13#10+
    'The type must be higher then AllowedReleaseType property of the TJvProgramVersionCheck component';
  RSProgramVersionInfo_PropertyHint_VersionDescription = 'This is a description field which could be shown in the update dialog via the version info button.';
  RSProgramVersionInfo_PropertyHint_ProgramVersion = 'Program version in the format <main>.<sub>.<release>.<build> This property is compared with the fileversion properties of the current application.';
  RSProgramVersionInfo_PropertyHint_ProgramLocationFileName = 'File name of the installer file ';
  RSProgramVersionInfo_PropertyHint_ProgramLocationPath = 'Path where the installer of the version could be found. This could be a absolute path or a relative path to the location of the version list';
  RSProgramVersionInfo_PropertyHint_LocalInstallerParams = 'List of parameters for the execution of the installer file';
  RSProgramVersionInfo_PropertyHint_DownloadPassword = 'Flag to define whether a password is required for the download or not';
  RSProgramVersionInfo_ObjectHint = 'Class to collect all information about a program version'#13#10+
    'This information will be stored in a file on the remote site';
  RSProgramVersionHistory_PropertyHint_alpha = 'Auto calculated version number of the highest alpha version';
  RSProgramVersionHistory_PropertyHint_beta = 'Auto calculated version number of the highest beta version';
  RSProgramVersionHistory_PropertyHint_Production = 'Auto calculated version number of the highest production version';
  RSProgramVersionHistory_ObjectHint = 'Class to define a list of program version information. This class is used '+
            'to detect which versions are available. The information will also be used '+
            'in the version info dialog';
  RSProgramVersionHistory = 'Program Version History';
//=== JvPropertyStore.pas ====================================================
resourcestring
  RsJvPropertyStoreMutexStorePropertiesProcedureName = 'TJvCustomPropertyStore.StoreProperties:';
  RsJvPropertyStoreMutexLoadPropertiesProcedureName = 'TJvCustomPropertyStore.LoadProperties:';
  RsJvPropertyStoreMutexLoadStorePropertiesProcedureName = 'TJvCustomPropertyStore.LoadStoreProperties:';
  RsJvPropertyStoreEnterMutexTimeout = '%s: Mutex Timeout';
//=== JvPropertyStoreEditor.pas ====================================================
resourcestring
  RSPropertyStoreEditorDialogButtonOk = '&Ok';
  RSPropertyStoreEditorDialogButtonCancel = '&Cancel';
  RSPropertyStoreEditorListButtonInsert = '&Insert';
  RSPropertyStoreEditorListButtonCopy = '&Copy';
  RSPropertyStoreEditorListButtonEdit = '&Edit';
  RSPropertyStoreEditorListButtonDelete = '&Delete';
  RSPropertyStoreEditorListButtonUp = '&Up';
  RSPropertyStoreEditorListButtonDown = 'Do&wn';
  RSPropertyStoreEditorListButtonSortUp = 'Sort &Asc';
  RSPropertyStoreEditorListButtonSortDown = 'Sort Desc';
  RSPropertyStoreEditorDialogCaptionEditProperties = 'Edit Properties';
  RSPropertyStoreEditorDeleteEntry = 'Delete Entry?';
//=== JvPrvwRender.pas =======================================================
resourcestring
  RsEAPrintPreviewComponentMustBeAssigne = 'A PrintPreview component must be assigned in CreatePreview!';
  RsEARichEditComponentMustBeAssignedInC = 'A RichEdit component must be assigned in CreatePreview!';
  RsECannotPerfromThisOperationWhilePrin = 'Cannot perfrom this operation while printing!';
  RsEPrinterNotAssigned = 'Printer not assigned!';
  RsENoPrintPreviewAssigned = 'No PrintPreview assigned!';
//=== JvRas32.pas ============================================================
resourcestring
  RsRasDllName = 'RASAPI32.DLL';
  RsERasError = 'RAS: Unable to find RasApi32.dll';
//=== JvRegistryTreeview.pas =================================================
resourcestring
  RsDefaultCaption = '(Default)';
  RsMyComputer = 'My Computer';
  RsDefaultNoValue = '(value not set)';
  RsUnknownCaption = '(Unknown)';
//=== JvRichEdit.pas =========================================================
resourcestring
  RsRTFFilter = 'Rich Text Format (*.rtf)|*.rtf';
  RsTextFilter = 'Plain text (*.txt)|*.txt';
  RsEConversionError = 'Conversion error %.8x';
  RsEConversionBusy = 'Cannot execute multiple conversions';
  RsECouldNotInitConverter = 'Could not initialize converter';
  RsEDiskFull = 'Out of space on output';
  RsEDocTooLarge = 'Conversion document too large for target';
  RsEInvalidDoc = 'Invalid document';
  RsEInvalidFile = 'Invalid data in conversion file';
  RsENoMemory = 'Out of memory';
  RsEOpenConvErr = 'Error opening conversion file';
  RsEOpenExceptErr = 'Error opening exception file';
  RsEOpenInFileErr = 'Could not open input file';
  RsEOpenOutFileErr = 'Could not open output file';
  RsEReadErr = 'Error during read';
  RsEUserCancel = 'Conversion cancelled by user';
  RsEWriteErr = 'Error during write';
  RsEWriteExceptErr = 'Error writing exception file';
  RsEWrongFileType = 'Wrong file type for this converter';
//=== JvSAL.pas ==============================================================
resourcestring
  RsEBooleanStackOverflow = 'Boolean stack overflow';
  RsEBooleanStackUnderflow = 'Boolean stack underflow';
  RsEProgramStopped = 'Program stopped';
  RsEUnterminatedIncludeDirectiveNears = 'Unterminated include directive near %s';
  RsEOngetUnitEventHandlerIsNotAssigned = 'OngetUnit event handler is not assigned';
  RsECouldNotIncludeUnits = 'Could not include unit %s';
  RsEUnterminatedCommentNears = 'Unterminated comment near %s';
  RsEUnterminatedProcedureNears = 'Unterminated procedure near %s';
  RsEVariablesAllreadyDefineds = 'Variable %0:s already defined;%1:s';
  RsEVariablesIsNotYetDefineds = 'Variable %0:s is not yet defined;%1:s';
  RsEProceduresNears = 'Procedure %0:s near %1:s';
  RsEUndefinedProcedures = 'Undefined procedure %s';
  RsECouldNotFindEndOfProcedure = 'Could not find end of procedure';
//=== JvSALCore.pas ==========================================================
resourcestring
  RsEVariablesIsNotInitialized = 'Variable %s is not initialized';
  RsEDivisionByZeroError = 'Division by zero error';
  RsEMissingendselect = 'Missing "endselect"';
//=== JvSchedEvtStore.pas ====================================================
resourcestring
  RsEStructureStackIsEmpty = 'Structure stack is empty';
  RsEScheduleIsActiveReadingANewSchedule =
    'Schedule is active. Reading a new schedule can only be done on inactive schedules';
  RsEScheduleIsActiveStoringOfAScheduleC =
    'Schedule is active. Storing of a schedule can only be done on inactive schedules';
  RsENotImplemented_ = 'not implemented';
  RsENotASchedule = 'Not a schedule';
  RsEUnknownScheduleVersions = 'Unknown schedule version ($%s)';
  RsEUnexpectedStructure = 'Unexpected structure';
  RsEIncorrectIdentifierFound = 'Incorrect identifier found';
  RsEIncorrectStructure = 'Incorrect structure found';
//=== JvScheduledEvents.pas ==================================================
resourcestring
  RsECannotRestart = 'Cannot restart: Event is being triggered or is executing';
//=== JvScrollMax.pas ========================================================
resourcestring
  RsRightClickAndChooseAddBand = 'Right click and choose "Add band"';
  { (rom) deactivated  see DefineCursor in JvScrollMax.pas
  RsECannotLoadCursorResource = 'Cannot load cursor resource';
  RsETooManyUserdefinedCursors = 'Too many user-defined cursors';
  }
  RsETJvScrollMaxBandCanBePutOnlyIntoTJv = 'TJvScrollMaxBand can be put only into TJvScrollMax component';
  RsETJvScrollMaxCanContainOnlyTJvScroll = 'TJvScrollMax can contain only TJvScrollMaxBand components';
  RsEControlsNotAChildOfs = 'Control %0:s not a child of %1:s';
//=== JvSegmentedLEDDisplay.pas ==============================================
resourcestring
  RsEInvalidClass = 'Invalid class';
  RsEInvalidMappingFile = 'Invalid mapping file';
  RsEDuplicateDigitClass = 'Duplicate DigitClass registered';
//=== JvSegmentedLEDDisplayMapperFrame.pas ===================================
resourcestring
  RsTheCurrentCharacterHasBeenModifiedA = 'The current character has been modified. Apply changes?';
  RsTheCurrentMappingHasBeenModifiedSav = 'The current mapping has been modified. Save changes to file?';
  RsSegmentedLEDDisplayMappingFilessdms = 'Segmented LED display mapping files (*.sdm)|*.sdm|All files (*.*)|*.*';
  RsSelectCharacter = 'Select character...';
  RsSpecifyANewCharacter = 'Specify a new character';
//=== JvSHFileOperation.pas ==================================================
resourcestring
  RsENoFilesSpecifiedToTJvSHFileOperatio = 'No files specified to TJvSHFileOperation Execute function';
//=== JvSpeedbar.pas =========================================================
resourcestring
  RsEAutoSpeedbarMode = 'Cannot set this property value while Position is bpAuto';
//=== JvSpeedbarSetupForm.pas ================================================
resourcestring
  RsCustomizeSpeedbar = 'Customize Speedbar';
  RsAvailButtons = '&Available buttons:';
  RsSpeedbarCategories = '&Categories:';
  RsSpeedbarEditHint = 'To add command buttons, drag and drop buttons onto the SpeedBar.' +
    ' To remove command buttons, drag them off the SpeedBar.';
//=== JvSpellChecker.pas =====================================================
resourcestring
  RsENoSpellCheckerAvailable = 'No IJvSpellChecker implementation available!';
//=== JvSpellerForm.pas ======================================================
resourcestring
  RsENoDictionaryLoaded = 'No dictionary loaded';
//=== JvSpin.pas =============================================================
resourcestring
  RsEOutOfRangeFloat = 'Value must be between %0:g and %1:g';
//=== JvStatusBar.pas ========================================================
resourcestring
  RsEInvalidControlSelection = 'Invalid control selection';
//=== JvSticker.pas ==========================================================
resourcestring
  RsEditStickerCaption = 'Edit sticker';
//=== JvStringHolder.pas =====================================================
resourcestring
  RsENoItemFoundWithName = 'No item found with name "%s"';
//=== JvStrings.pas ==========================================================
resourcestring
  RsECannotLoadResource = 'Cannot load resource: %s';
  RsEIncorrectStringFormat = 'Base64: Incorrect string format';
//=== JvSyncSplitter.pas =====================================================
resourcestring
  RsEInvalidPartner = 'TJvSyncSplitter.SetPartner: cannot set Partner to Self!';
//=== JvSysRequirements.pas ==================================================
resourcestring
  RsSysRequirementsCaption = 'System Requirements for %s';
  RsMinColorDepthReq = 'The color depth must be at least %1:d bits per pixel, but is only %0:d bits per pixel.';
  RsMaxColorDepthReq = 'The color depth cannot be more than %1:d bits per pixel, but is %0:d bits per pixel.';
  RsBetweenColorDepthReq = 'The color depth must be between %1:d and %2:d bits per pixel, but is %0:d bits per pixel.';
  RsMinScreenXReq = 'The horizontal screen resolution must be at least %1:d pixels, but is only %0:d pixels.';
  RsMaxScreenXReq = 'The horizontal screen resolution cannot be more than %1:d pixels, but is %0:d pixel.';
  RsBetweenScreenXReq = 'The horizontal screen resolution must be between %1:d and %2:d pixels, but is %0:d pixel.';
  RsMinScreenYReq = 'The vertical screen resolution must be at least %1:d pixels, but is only %0:d pixels.';
  RsMaxScreenYReq = 'The vertical screen resolution cannot be more than %1:d pixels, but is %0:d pixel.';
  RsBetweenScreenYReq = 'The vertical screen resolution must be between %1:d and %2:d pixels, but is %0:d pixel.';
  RsMinRefreshReq = 'The video refresh rate must be at least %1:d Hertz, but is only %0:d Hertz.';
  RsMaxRefreshReq = 'The video refresh rate cannot be more than %1:d Hertz, but is %0:d Hertz.';
  RsBetweenRefreshReq = 'The video refresh rate must be between %1:d and %2:d Hertz, but is %0:d Hertz.';
  RsWindowsVersionReq = 'This version of Windows is not supported.';
  RsSystemFontSmallReq = 'The system does not use small fonts.';
  RsSystemFontBigReq = 'The system does not use big fonts.';
//=== JvSystemPopup.pas ======================================================
resourcestring
  RsEAlreadyHooked = 'TJvSystemPopup.Hook: already hooked';
//=== JvTFDays.pas ===========================================================
resourcestring
  RsEInvalidPrimeTimeStartTime = 'Invalid PrimeTime StartTime';
  RsEInvalidPrimeTimeEndTime = 'Invalid PrimeTime EndTime';
  RsEColumnIndexOutOfBounds = 'Column index out of bounds';
  RsERowIndexOutOfBounds = 'Row index out of bounds';
  RsEMapColNotFoundForAppointment = 'Map column not found for appointment';
  RsECorruptAppointmentMap = 'Corrupt appointment map';
  RsEGridGranularityCannotBeGreater = 'Grid granularity cannot be greater ' +
    'than the time block granularity';
  RsETimeBlockGranularityMustBeEvenly = 'Time block granularity must be evenly ' +
    'divisible by the grid granularity';
  RsETimeBlocksMustBeginExactlyOn = 'Time blocks must begin exactly on ' +
    'a grid time division';
  RsEGridEndTimeCannotBePriorToGridStart = 'GridEndTime cannot be prior to GridStartTime';
  RsEGridStartTimeCannotBeAfterGridEndTi = 'GridStartTime cannot be after GridEndTime';
  RsEInvalidRowd = 'Invalid row (%d)';
  RsEThereIsNoDataToPrint = 'There is no data to print';
  RsENoPageInfoExists = 'No page info exists.  ' +
    'Document must be prepared';
  RsEATimeBlockNameCannotBeNull = 'A time block name cannot be null';
  RsEAnotherTimeBlockWithTheName = 'Another time block with the name "%s" already exists';
  RsEATimeBlockWithTheNamesDoesNotExist = 'A time block with the name "%s" does not exist';
//=== JvTFGantt.pas ==========================================================
resourcestring
  RsThisIsTheMajorScale = 'This is the Major Scale';
  RsThisIsTheMinorScale = 'This is the Minor Scale';
//=== JvTFGlance.pas =========================================================
resourcestring
  RsECellDatesCannotBeChanged = 'Cell Dates cannot be changed';
  RsECellMapHasBeenCorrupteds = 'Cell map has been corrupted %s';
  RsECellObjectNotAssigned = 'Cell object not assigned';
  RsEInvalidColIndexd = 'Invalid col index (%d)';
  RsEInvalidRowIndexd = 'Invalid row index (%d)';
  RsEApptIndexOutOfBoundsd = 'Appt index out of bounds (%d)';
  RsECellCannotBeSplit = 'Cell cannot be split';
  RsEASubcellCannotBeSplit = 'A subcell cannot be split';
  RsGlanceMainTitle = '(Title)';
//=== JvTFGlanceTextViewer.pas ===============================================
resourcestring
  RsEGlanceControlNotAssigned = 'GlanceControl not assigned';
//=== JvTFManager.pas ========================================================
resourcestring
  RsECouldNotCreateCustomImageMap = 'Could not create CustomImageMap.  ' +
    'Appointment not assigned';
  RsECouldNotCreateAppointmentObject = 'Could not create Appointment object.  ' +
    'ScheduleManager not assigned';
  RsEScheduleManagerNotificationFailedSc = 'ScheduleManager notification failed.  ScheduleManager not assigned';
  RsEScheduleNotificationFailed = 'Schedule notification failed.  ' +
    'Schedule not assigned';
  RsEInvalidStartAndEndTimes = 'Invalid start and end times';
  RsEInvalidStartAndEndDates = 'Invalid start and end dates';
  RsEAppointmentNotificationFailed = 'Appointment notification failed.  ' +
    'Appointment not assigned';
  RsECouldNotCreateNewAppointment = 'Could not create new appointment. ' +
    'Appointment with given ID already exists';
  RsEInvalidTriggerForRefreshControls = 'Invalid Trigger for RefreshControls';
  RsEInvalidScopeInReconcileRefresh = 'Invalid Scope in ReconcileRefresh';
  RsECouldNotRetrieveSchedule = 'Could not retrieve schedule.  ' +
    'ScheduleManager not assigned';
  RsECouldNotReleaseSchedule = 'Could not release schedule.  ' +
    'ScheduleManager not assigned';
  RsECouldNotCreateADocumentBecauseA = 'Could not create a document because a ' +
    'document already exists';
  RsECouldNotFinishDocumentBecauseNo = 'Could not finish document because no ' +
    'document has been created';
  RsEDocumentDoesNotExist = 'Document does not exist';
  RsEDocumentPagesCannotBeAccessedIf = 'Document pages cannot be accessed if ' +
    'printing directly to the printer';
  RsEDocumentPagesAreInaccessibleUntil = 'Document pages are inaccessible until ' +
    'the document has been finished';
  RsECouldNotRetrievePageCount = 'Could not retrieve page count ' +
    'because document does not exist';
  RsEOnlyAFinishedDocumentCanBePrinted = 'Only a finished document can be printed';
  RsEThereAreNoPagesToPrint = 'There are no pages to print';
  RsEDocumentMustBeFinishedToSaveToFile = 'Document must be Finished to save to file';
  RsEThisPropertyCannotBeChangedIfA = 'This property cannot be changed if a ' +
    'document exists';
  RsECouldNotCreateTJvTFPrinterPageLayou = 'Could not create TJvTFPrinterPageLayout ' +
    'because aPrinter must be assigned';
  RsEInvalidFooterHeightd = 'Invalid Footer Height (%d)';
  RsEInvalidHeaderHeightd = 'Invalid Header Height (%d)';
//=== JvTFSparseMatrix.pas ===================================================
resourcestring
  RsEMatrixMustBeEmpty = 'Matrix must be empty before setting null value';
//=== JvTFUtils.pas ==========================================================
resourcestring
  RsEResultDoesNotFallInMonth = 'Result does not fall in given month';
  RsEInvalidMonthValue = 'Invalid Month Value (%d)';
  RsEInvalidDayOfWeekValue = 'Invalid value for day of week (%d)';
//=== JvTFWeeks.pas ==========================================================
resourcestring
  RsWeekOf = 'Week of %s';
//=== JvThreadDialog.pas =====================================================
resourcestring
  RsENotATJvThread = 'TJvCustomThreadDialogForm.SetConnectedThread: A thread must be a TJvThread-Component';
//=== JvThumbImage.pas =======================================================
resourcestring
  RsEUnknownFileExtension = 'Unknown file extension %s';
  RsFileFilters = '|PCX Files(*.pcx)|*.pcx|Targa Files(*.tga)|*.tga';
  RsPcxTga = '*.pcx;*.tga;';
//=== JvThumbnails.pas =======================================================
resourcestring
  RsUnknown = 'Unknown';
//=== JvTimer.pas ============================================================
resourcestring
  RsCannotChangeInTimerEvent = 'Cannot change %s in the timer event';
//=== JvTimeLimit.pas ========================================================
resourcestring
  RsExpired = 'The test period has expired, please register this application';
//=== JvTimeList.pas =========================================================
resourcestring
  RsEOwnerMustBeTJvTimerList = 'Owner of TJvTimerEvents must be a TJvTimerList';
//=== JvTipOfDay.pas =========================================================
resourcestring
  RsCloseCaption = '&Close';
  RsNextCaption = '&Next Tip';
  RsTipsTitle = 'Tips and Tricks';
  RsTipsHeaderText = 'Did you know...';
  RsTipsCheckBoxText = '&Show Tips on Startup';
  RsStoreShowOnStartUp = 'Show_On_Startup'; // (p3) Spaces in XML node names is not valid XML...
//=== JvToolEdit.pas =========================================================
resourcestring
  RsBrowseCaption = 'Browse';
  {$IFDEF MSWINDOWS}
  RsDefaultFilter = 'All files (*.*)|*.*';
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  RsDefaultFilter = 'All files (*)|*';
  {$ENDIF UNIX}
  { Polaris patch }
  RsEDateMinLimit = 'Enter a date before "%s"';
  RsEDateMaxLimit = 'Enter a date after "%s"';
//=== JvTurtle.pas ===========================================================
resourcestring
  RsErrorCanvasNotAssigned = 'Canvas not assigned';
  RsEmptyScript = 'Empty script';
  RsInvalidIntegerIns = 'Invalid integer in %s';
  RsInvalidColorIns = 'Invalid color in %s';
  RsInvalidCopyMode = 'Invalid copy mode';
  RsInvalidPenMode = 'Invalid pen mode';
  RsInvalidTextIns = 'Invalid text in %s';
  RsMissingFontname = 'Missing fontname';
  RsNumberExpectedIns = 'Number expected in %s';
  RsNumberStackUnderflow = 'Number stack underflow';
  RsNumberStackOverflow = 'Number stack overflow';
  RsMissingAfterComment = 'Missing "}" after comment';
  RsErrorIns = 'Error in %s';
  RsDivisionByZero = 'Division by zero';
  RsInvalidParameterIns = 'Invalid parameter in %s';
  RsSymbolsIsNotDefined = 'Symbol %s is not defined';
  RsMissingAfterBlock = 'Missing "]" after block';
  RsStackUnderflowIns = 'Stack underflow in %s';
  RsSymbolExpectedAfterIf = 'Symbol expected after if';
  RsCanNotTakeSqrtOf = 'Can not take sqrt of 0';
  RsNotAllowedIns = '0 not allowed in %s';
  RsNeedMinimumOfSidesIns = 'Need minimum of 3 sides in %s';
  RsMaximumSidesExceededIns = 'Maximum 12 sides exceeded in %s';
  RsTokenExpected = 'Token expected';
  RssDoesNotExist = '%s does not exist';
  RsDivisionByZeroNotAllowedInIn = 'Division by zero not allowed in in-';
  RsStackOverflow = 'Stack overflow';
  RsStackUnderflow = 'Stack underflow';
//=== JvTypes.pas ============================================================
resourcestring
  RsClBlack = 'Black';
  RsClMaroon = 'Maroon';
  RsClGreen = 'Green';
  RsClOlive = 'Olive green';
  RsClNavy = 'Navy blue';
  RsClPurple = 'Purple';
  RsClTeal = 'Teal';
  RsClGray = 'Gray';
  RsClSilver = 'Silver';
  RsClRed = 'Red';
  RsClLime = 'Lime';
  RsClYellow = 'Yellow';
  RsClBlue = 'Blue';
  RsClFuchsia = 'Fuchsia';
  RsClAqua = 'Aqua';
  RsClWhite = 'White';
  RsClMoneyGreen = 'Money green';
  RsClSkyBlue = 'Sky blue';
  RsClCream = 'Cream';
  RsClMedGray = 'Medium gray';
  //Standrad colors
  RsClBrown = 'Brown';
  RsClOliveGreen = 'Olive Green';
  RsClDarkGreen = 'Dark Green';
  RsClDarkTeal = 'Dark Teal';
  RsClDarkBlue = 'Dark Blue';
  RsClIndigo = 'Indigo';
  RsClGray80 = 'Gray 80%';
  RsClDarkRed = 'Dark Red';
  RsClOrange = 'Orange';
  RsClDarkYellow = 'Dark Yellow';
  RsClBlueGray = 'Blue Gray';
  RsClGray50 = 'Gray 50%';
  RsClLightOrange = 'Light Orange';
  RsClSeaGreen = 'Sea Green';
  RsClLightBlue = 'Light Blue';
  RsClViolet = 'Violet';
  RsClGray40 = 'Gray 40%';
  RsClPink = 'Pink';
  RsClGold = 'Gold';
  RsClBrightGreen = 'Bright Green';
  RsClTurquoise = 'Turquoise';
  RsClPlum = 'Plum';
  RsClGray25 = 'Gray 25%';
  RsClRose = 'Rose';
  RsClTan = 'Tan';
  RsClLightYellow  = 'Light Yellow';
  RsClLightGreen = 'Light Green';
  RsClLightTurquoise = 'Light Turquoise';
  RsClPaleBlue = 'Pale Blue';
  RsClLavender = 'Lavender';
  // windows system colors
  RsClScrollBar = 'Scrollbar';
  RsClBackground = 'Desktop background';
  RsClActiveCaption = 'Active window title bar';
  RsClInactiveCaption = 'Inactive window title bar';
  RsClMenu = 'Menu background';
  RsClWindow = 'Window background';
  RsClWindowFrame = 'Window frame';
  RsClMenuText = 'Menu text';
  RsClWindowText = 'Window text';
  RsClCaptionText = 'Active window title bar text';
  RsClActiveBorder = 'Active window border';
  RsClInactiveBorder = 'Inactive window border';
  RsClAppWorkSpace = 'Application workspace';
  RsClHighlight = 'Selection background';
  RsClHighlightText = 'Selection text';
  RsClBtnFace = 'Button face';
  RsClBtnShadow = 'Button shadow';
  RsClGrayText = 'Dimmed text';
  RsClBtnText = 'Button text';
  RsClInactiveCaptionText = 'Inactive window title bar text';
  RsClBtnHighlight = 'Button highlight';
  RsCl3DDkShadow = 'Dark shadow 3D elements';
  RsCl3DLight = 'Highlight 3D elements';
  RsClInfoText = 'Tooltip text';
  RsClInfoBk = 'Tooltip background';
  RsGradientActiveCaption ='Gradient Active Caption';
  RsGradientInactiveCaption ='Gradient Inactive Caption';
  RsHotLight ='Hot Light';
  RsMenuBar ='Menu Bar';
  RsMenuHighlight ='Menu Highlight';

//=== JvUrlGrabbers.pas ======================================================
resourcestring
  RsFileNotFoundFmt = 'File "%s" not found';
//=== JvUrlListGrabber.pas ===================================================
resourcestring
  RsENoGrabberForUrl = 'There is no grabber capable of handling URL: %s';
  RsEAtLeastOneGrabberRunning = 'There is at least one grabber running, you cannot change the URLs.';
  RsEGrabberNotStopped = 'The grabber is not stopped, you cannot change its URL.';
  RsJediAgent = 'JEDI-VCL';
  RsDefaultOutputFileName = 'output.txt';
//=== JvValidateEdit.pas =====================================================
resourcestring
  RsEBaseTooBig = 'Base > 36 not supported';
  RsEBaseTooSmall = 'Base must be greater than 1';
//=== JvValidators.pas =======================================================
resourcestring
  RsEInsertNilValidator = 'Cannot insert nil validator';
  RsERemoveNilValidator = 'Cannot remove nil validator';
  RsEValidatorNotChild = 'Validator is not owned by this component';
  RsEInvalidIndexd = 'Invalid index (%d)';
//=== JvVirtualKeySelectionFrame.pas =========================================
resourcestring
  RsNoValidKeyCode = 'This is not a valid key code';
  RsInvalidKeyCode = 'Invalid key code';
//=== JvWinampLabel.pas ======================================================
resourcestring
  RsEInvalidSkin = 'Invalid skin';
//=== JvWinDialogs.pas =======================================================
resourcestring
  //SDiskFullError =
  //  'TJvDiskFullDialog does not support removable media or network drives.';
  RsEFunctionNotSupported = 'This function is not supported by your version of Windows';
  RsEInvalidDriveChar = 'Invalid drive (%s)';
  { make Delphi 5 compiler happy // andreas
    RsEUnsupportedDisk = 'Unsupported drive (%s): JvDiskFullDialog only supports fixed drives';}
//=== JvWinHelp.pas ==========================================================
resourcestring
  RsEOwnerForm = 'Owner must be of type TCustomForm';
//=== JvWizard.pas ===========================================================
resourcestring
  RsFirstButtonCaption = 'To &Start Page';
  RsLastButtonCaption = 'To &Last Page';
  RsFinishButtonCaption = '&Finish';
  RsWelcome = 'Welcome';
  RsTitle = 'Title';
  RsSubtitle = 'Subtitle';
  RsEInvalidParentControl = 'The Parent should be TJvWizard or a descendant';
  RsEInvalidWizardPage = 'The pages belong to another wizard';
//=== JvWizardCommon.pas =====================================================
resourcestring
  RsETilingError = 'Tiling only works on images with dimensions > 0';
//=== JvWizardRouteMapSteps.pas ==============================================
resourcestring
  RsActiveStepFormat = 'Step %0:d of %1:d';
  RsBackTo = 'Back to';
  RsNextStep = 'Next Step';
//=== JvXmlDatabase.pas ======================================================
resourcestring
  RsEUnknownInstruction = 'Unknown Instruction %s';
  RsEUnexpectedEndOfQuery = 'Unexpected end of query';
  RsEUnexpectedStatement = 'Unexpected statement %s';
//=== JvXPBar.pas ============================================================
resourcestring
  RsUntitled = 'untitled';
  RsUntitledFmt = '(%0:s %1:d)';
  RsHintShortcutFmt = '%0:s (%1:s)';
//=== JvXPCore.pas ===========================================================
resourcestring
  RsCopyright = 'Design eXperience. (c) 2002 M. Hoffmann Version ';
  RsCopyright2 = 'Design eXperience II - (c) 2002 M. Hoffmann Version ';
  RsVersion = '2.0.1'; // always increase version number on new releases!
//=== JvYearGrid.pas =========================================================
resourcestring
  RsYearGrid = 'YearGrid';
  RsEnterYear = 'Enter year (1999-2050):';
  RsInvalidYear = 'invalid year';
  RsYear = '&Year...';
  RsEdit = '&Edit';
  RsColor = '&Color...';
  RsNoColor = '&No Color';
  RsSaveAllInfo = '&Save All Info';
  RsSaveFoundInfo = 'Save Found Info';
  RsBorderColor = '&Border Color...';
  RsBookMarkColor = 'Book&Mark Color...';
  RsFindItem = '&Find...';
  RsClearFind = 'Clear Find';
  RsYearGridFind = 'YearGrid Find';
  RsEnterSeachText = 'Enter seach text:';
  RsFounds = 'Found %s';
  RsToday = 'Today ';
//=== JvDBFilterExpr =========================================================
resourcestring
  RsInvalidFilterNodeKind = 'Invalid filter node kind';
  RsUnknownFilterOperation = 'Unknown filter operator';
  RsUnknownFilterFunction = 'Unknown filter function "%s"';
  RsMissingFilterFunctionParameters = 'Missing filter function parameters for "%s"';
//=== JvPanel ================================================================
resourcestring
  RsDestroyingArrangeSettingsNotAllowed = 'Your code tried to destroy the TJvPanel.ArrangeSettings ' +
    'objects leaving the panel in a broken state. Please fix your code by adding'#13#10#13#10 +
    '    if not ((Components[I] is TJvArrangeSettings) or'#13#10 +
    '            (Components[I] is TJvPanelHotTrackOptions)) then'#13#10#13#10 +
    'or by using the Controls[] array property if possible.';
//=== JvXMLBrowser.pas ====================================================
resourcestring
  RSXMLBrowserDialogButtonClose = '&Close';
//=== not taken into JVCL ====================================================
{
resourcestring
  // MathParser
  SParseSyntaxError = 'Syntax error';
  SParseNotCramp = 'Invalid condition (no cramp)';
  SParseDivideByZero = 'Divide by zero';
  SParseSqrError = 'Invalid floating operation';
  SParseLogError = 'Invalid floating operation';
  SParseInvalidFloatOperation = 'Invalid floating operation';
  // JvDBFilter
  SExprNotBoolean = 'Field ''%s'' is not of type Boolean';
  SExprBadNullTest = 'NULL only allowed with ''='' and ''<>''';
  SExprBadField = 'Field ''%s'' cannot be used in a filter expression';
  // JvDBFilter expression parser
  SExprIncorrect = 'Incorrectly formed filter expression';
  SExprTermination = 'Filter expression incorrectly terminated';
  SExprNameError = 'Unterminated field name';
  SExprStringError = 'Unterminated string constant';
  SExprInvalidChar = 'Invalid filter expression character: ''%s''';
  SExprNoRParen = ''')'' expected but %s found';
  SExprExpected = 'Expression expected but %s found';
  SExprBadCompare = 'Relational operators require a field and a constant';
}
{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JVCL\run'
  );
{$ENDIF UNITVERSIONING}
implementation
{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);
finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
end.
