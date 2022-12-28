unit uRESTDWMemUnicode;
{$I ..\..\Source\Includes\uRESTDWPlataform.inc}
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
uses
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Classes,
  {$IFDEF HAS_UNIT_CHARACTER}
  System.Character,
  {$ENDIF HAS_UNIT_CHARACTER}
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes,
  {$IFDEF HAS_UNIT_CHARACTER}
  Character,
  {$ENDIF HAS_UNIT_CHARACTER}
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase, Types;
{$IFNDEF FPC}
 {$IFDEF MSWINDOWS}
  {$DEFINE OWN_WIDESTRING_MEMMGR}
 {$ENDIF MSWINDOWS}
{$ENDIF ~FPC}
Type
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    DWString     = String;
    DWWideString = WideString;
    DWChar       = Char;
   {$ELSE}
    DWString     = Utf8String;
    DWWideString = WideString;
    DWChar       = Utf8Char;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    DWString     = Utf8String;
    DWWideString = Utf8String;
    DWChar       = Utf8Char;
   {$ELSE}
    DWString     = AnsiString;
    DWWideString = WideString;
    DWChar       = Char;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  DWString     = AnsiString;
  DWWideString = WideString;
  DWChar       = Char;
 {$ENDIF}
 PDWChar       = ^DWChar;
 LCID          = DWORD;
const
  // definitions of often used characters:
  // Note: Use them only for tests of a certain character not to determine character
  //       classes (like white spaces) as in Unicode are often many code points defined
  //       being in a certain class. Hence your best option is to use the various
  //       UnicodeIs* functions.
  WideNull = DWChar(#0);
  WideTabulator = DWChar(#9);
  WideSpace = DWChar(#32);
  // logical line breaks
  WideLF = DWChar(#10);
  WideLineFeed = DWChar(#10);
  WideVerticalTab = DWChar(#11);
  WideFormFeed = DWChar(#12);
  WideCR = DWChar(#13);
  WideCarriageReturn = DWChar(#13);
  WideCRLF = DWWideString(#13#10);
  WideLineSeparator = DWChar($2028);
  WideParagraphSeparator = DWChar($2029);
  // byte order marks for Unicode files
  // Unicode text files (in UTF-16 format) should contain $FFFE as first character to
  // identify such a file clearly. Depending on the system where the file was created
  // on this appears either in big endian or little endian style.
  BOM_LSB_FIRST = DWChar($FEFF);
  BOM_MSB_FIRST = DWChar($FFFE);
type
  TSaveFormat = ( sfUTF16LSB, sfUTF16MSB, sfUTF8, sfAnsi );
const
  sfUnicodeLSB = sfUTF16LSB;
  sfUnicodeMSB = sfUTF16MSB;
type
  // various predefined or otherwise useful character property categories
  TCharacterCategory = (
    // normative categories
    ccLetterUppercase,
    ccLetterLowercase,
    ccLetterTitlecase,
    ccMarkNonSpacing,
    ccMarkSpacingCombining,
    ccMarkEnclosing,
    ccNumberDecimalDigit,
    ccNumberLetter,
    ccNumberOther,
    ccSeparatorSpace,
    ccSeparatorLine,
    ccSeparatorParagraph,
    ccOtherControl,
    ccOtherFormat,
    ccOtherSurrogate,
    ccOtherPrivate,
    ccOtherUnassigned,
    // informative categories
    ccLetterModifier,
    ccLetterOther,
    ccPunctuationConnector,
    ccPunctuationDash,
    ccPunctuationOpen,
    ccPunctuationClose,
    ccPunctuationInitialQuote,
    ccPunctuationFinalQuote,
    ccPunctuationOther,
    ccSymbolMath,
    ccSymbolCurrency,
    ccSymbolModifier,
    ccSymbolOther,
    // bidirectional categories
    ccLeftToRight,
    ccLeftToRightEmbedding,
    ccLeftToRightOverride,
    ccRightToLeft,
    ccRightToLeftArabic,
    ccRightToLeftEmbedding,
    ccRightToLeftOverride,
    ccPopDirectionalFormat,
    ccEuropeanNumber,
    ccEuropeanNumberSeparator,
    ccEuropeanNumberTerminator,
    ccArabicNumber,
    ccCommonNumberSeparator,
    ccBoundaryNeutral,
    ccSegmentSeparator,      // this includes tab and vertical tab
    ccWhiteSpace,            // Separator characters and control characters which should be treated by programming languages as "white space" for the purpose of parsing elements.
    ccOtherNeutrals,
    ccLeftToRightIsolate,
    ccRightToLeftIsolate,
    ccFirstStrongIsolate,
    ccPopDirectionalIsolate,
    // self defined categories, they do not appear in the Unicode data file
    ccComposed,              // can be decomposed
    ccNonBreaking,
    ccSymmetric,             // has left and right forms
    ccHexDigit,              // Characters commonly used for the representation of hexadecimal numbers, plus their compatibility equivalents.
    ccQuotationMark,         // Punctuation characters that function as quotation marks.
    ccMirroring,
    ccAssigned,              // means there is a definition in the Unicode standard
    ccASCIIHexDigit,         // ASCII characters commonly used for the representation of hexadecimal numbers
    ccBidiControl,           // Format control characters which have specific functions in the Unicode Bidirectional Algorithm [UAX9].
    ccDash,                  // Punctuation characters explicitly called out as dashes in the Unicode Standard, plus their compatibility equivalents. Most of these have the General_Category value Pd, but some have the General_Category value Sm because of their use in mathematics.
    ccDeprecated,            // For a machine-readable list of deprecated characters. No characters will ever be removed from the standard, but the usage of deprecated characters is strongly discouraged.
    ccDiacritic,             // Characters that linguistically modify the meaning of another character to which they apply. Some diacritics are not combining characters, and some combining characters are not diacritics.
    ccExtender,              // Characters whose principal function is to extend the value or shape of a preceding alphabetic character. Typical of these are length and iteration marks.
    ccHyphen,                // Dashes which are used to mark connections between pieces of words, plus the Katakana middle dot. The Katakana middle dot functions like a hyphen, but is shaped like a dot rather than a dash.
    ccIdeographic,           // Characters considered to be CJKV (Chinese, Japanese, Korean, and Vietnamese) ideographs.
    ccIDSBinaryOperator,     // Used in Ideographic Description Sequences.
    ccIDSTrinaryOperator,    // Used in Ideographic Description Sequences.
    ccJoinControl,           // Format control characters which have specific functions for control of cursive joining and ligation.
    ccLogicalOrderException, // There are a small number of characters that do not use logical order. These characters require special handling in most processing.
    ccNonCharacterCodePoint, // Code points permanently reserved for internal use.
    ccOtherAlphabetic,       // Used in deriving the Alphabetic property.
    ccOtherDefaultIgnorableCodePoint, // Used in deriving the Default_Ignorable_Code_Point property.
    ccOtherGraphemeExtend,   // Used in deriving  the Grapheme_Extend property.
    ccOtherIDContinue,       // Used for backward compatibility of ID_Continue.
    ccOtherIDStart,          // Used for backward compatibility of ID_Start.
    ccOtherLowercase,        // Used in deriving the Lowercase property.
    ccOtherMath,             // Used in deriving the Math property.
    ccOtherUppercase,        // Used in deriving the Uppercase property.
    ccPatternSyntax,         // Used for pattern syntax as described in UAX #31: Unicode Identifier and Pattern Syntax [UAX31].
    ccPatternWhiteSpace,
    ccRadical,               // Used in Ideographic Description Sequences.
    ccSoftDotted,            // Characters with a "soft dot", like i or j. An accent placed on these characters causes the dot to disappear. An explicit dot above can be added where required, such as in Lithuanian.
    ccSTerm,                 // Sentence Terminal. Used in UAX #29: Unicode Text Segmentation [UAX29].
    ccTerminalPunctuation,   // Punctuation characters that generally mark the end of textual units.
    ccUnifiedIdeograph,      // Used in Ideographic Description Sequences.
    ccVariationSelector,     // Indicates characters that are Variation Selectors. For details on the behavior of these characters, see StandardizedVariants.html, Section 16.4, "Variation Selectors" in [Unicode], and the Unicode Ideographic Variation Database [UTS37].
    ccSentenceTerminal,      // Characters used at the end of a sentence
    ccPrependedQuotationMark,
    ccRegionalIndicator
  );
  TCharacterCategories = set of TCharacterCategory;
{$IFDEF HAS_UNIT_CHARACTER}
type
  TCharacterUnicodeCategory = ccLetterUppercase..ccSymbolOther;
const
  CharacterCategoryToUnicodeCategory: array [TCharacterUnicodeCategory] of TUnicodeCategory =
    ( TUnicodeCategory.ucUppercaseLetter,    // ccLetterUppercase
      TUnicodeCategory.ucLowercaseLetter,    // ccLetterLowercase
      TUnicodeCategory.ucTitlecaseLetter,    // ccLetterTitlecase
      TUnicodeCategory.ucNonSpacingMark,     // ccMarkNonSpacing
      TUnicodeCategory.ucCombiningMark,      // ccMarkSpacingCombining
      TUnicodeCategory.ucEnclosingMark,      // ccMarkEnclosing
      TUnicodeCategory.ucDecimalNumber,      // ccNumberDecimalDigit
      TUnicodeCategory.ucLetterNumber,       // ccNumberLetter
      TUnicodeCategory.ucOtherNumber,        // ccNumberOther
      TUnicodeCategory.ucSpaceSeparator,     // ccSeparatorSpace
      TUnicodeCategory.ucLineSeparator,      // ccSeparatorLine
      TUnicodeCategory.ucParagraphSeparator, // ccSeparatorParagraph
      TUnicodeCategory.ucControl,            // ccOtherControl
      TUnicodeCategory.ucFormat,             // ccOtherFormat
      TUnicodeCategory.ucSurrogate,          // ccOtherSurrogate
      TUnicodeCategory.ucPrivateUse,         // ccOtherPrivate
      TUnicodeCategory.ucUnassigned,         // ccOtherUnassigned
      TUnicodeCategory.ucModifierLetter,     // ccLetterModifier
      TUnicodeCategory.ucOtherLetter,        // ccLetterOther
      TUnicodeCategory.ucConnectPunctuation, // ccPunctuationConnector
      TUnicodeCategory.ucDashPunctuation,    // ccPunctuationDash
      TUnicodeCategory.ucOpenPunctuation,    // ccPunctuationOpen
      TUnicodeCategory.ucClosePunctuation,   // ccPunctuationClose
      TUnicodeCategory.ucInitialPunctuation, // ccPunctuationInitialQuote
      TUnicodeCategory.ucFinalPunctuation,   // ccPunctuationFinalQuote
      TUnicodeCategory.ucOtherPunctuation,   // ccPunctuationOther
      TUnicodeCategory.ucMathSymbol,         // ccSymbolMath
      TUnicodeCategory.ucCurrencySymbol,     // ccSymbolCurrency
      TUnicodeCategory.ucModifierSymbol,     // ccSymbolModifier
      TUnicodeCategory.ucOtherSymbol );      // ccSymbolOther
  UnicodeCategoryToCharacterCategory: array [TUnicodeCategory] of TCharacterCategory =
    ( ccOtherControl,            // ucControl
      ccOtherFormat,             // ucFormat
      ccOtherUnassigned,         // ucUnassigned
      ccOtherPrivate,            // ucPrivateUse
      ccOtherSurrogate,          // ucSurrogate
      ccLetterLowercase,         // ucLowercaseLetter
      ccLetterModifier,          // ucModifierLetter
      ccLetterOther,             // ucOtherLetter
      ccLetterTitlecase,         // ucTitlecaseLetter
      ccLetterUppercase,         // ucUppercaseLetter
      ccMarkSpacingCombining,    // ucCombiningMark
      ccMarkEnclosing,           // ucEnclosingMark
      ccMarkNonSpacing,          // ucNonSpacingMark
      ccNumberDecimalDigit,      // ucDecimalNumber
      ccNumberLetter,            // ucLetterNumber
      ccNumberOther,             // ucOtherNumber
      ccPunctuationConnector,    // ucConnectPunctuation
      ccPunctuationDash,         // ucDashPunctuation
      ccPunctuationClose,        // ucClosePunctuation
      ccPunctuationFinalQuote,   // ucFinalPunctuation
      ccPunctuationInitialQuote, // ucInitialPunctuation
      ccPunctuationOther,        // ucOtherPunctuation
      ccPunctuationOpen,         // ucOpenPunctuation
      ccSymbolCurrency,          // ucCurrencySymbol
      ccSymbolModifier,          // ucModifierSymbol
      ccSymbolMath,              // ucMathSymbol
      ccSymbolOther,             // ucOtherSymbol
      ccSeparatorLine,           // ucLineSeparator
      ccSeparatorParagraph,      // ucParagraphSeparator
      ccSeparatorSpace );        // ucSpaceSeparator
function CharacterCategoriesToUnicodeCategory(const Categories: TCharacterCategories): TUnicodeCategory;
function UnicodeCategoryToCharacterCategories(Category: TUnicodeCategory): TCharacterCategories;
{$ENDIF HAS_UNIT_CHARACTER}
type
  // four forms of normalization are defined:
  TNormalizationForm = (
    nfNone, // do not normalize
    nfC,    // canonical decomposition followed by canonical composition (this is most often used)
    nfD,    // canonical decomposition
    nfKC,   // compatibility decomposition followed by a canonical composition
    nfKD    // compatibility decomposition
  );
  // 16 compatibility formatting tags are defined:
  TCompatibilityFormattingTag = (
    cftCanonical, // default when no CFT is explicited
    cftFont,      // Font variant (for example, a blackletter form)
    cftNoBreak,   // No-break version of a space or hyphen
    cftInitial,   // Initial presentation form (Arabic)
    cftMedial,    // Medial presentation form (Arabic)
    cftFinal,     // Final presentation form (Arabic)
    cftIsolated,  // Isolated presentation form (Arabic)
    cftCircle,    // Encircled form
    cftSuper,     // Superscript form
    cftSub,       // Subscript form
    cftVertical,  // Vertical layout presentation form
    cftWide,      // Wide (or zenkaku) compatibility character
    cftNarrow,    // Narrow (or hankaku) compatibility character
    cftSmall,     // Small variant form (CNS compatibility)
    cftSquare,    // CJK squared font variant
    cftFraction,  // Vulgar fraction form
    cftCompat     // Otherwise unspecified compatibility character
  );
  TCompatibilityFormattingTags = set of TCompatibilityFormattingTag;
  // used to hold information about the start and end
  // position of a unicodeblock.
  TUnicodeBlockRange = record
    RangeStart,
    RangeEnd: Cardinal;
  end;
  // An Unicode block usually corresponds to a particular language script but
  // can also represent special characters, musical symbols and the like.
  // https://www.unicode.org/charts/
  TUnicodeBlock = (
    ubUndefined,
    ubBasicLatin,
    ubLatin1Supplement,
    ubLatinExtendedA,
    ubLatinExtendedB,
    ubIPAExtensions,
    ubSpacingModifierLetters,
    ubCombiningDiacriticalMarks,
    ubGreekandCoptic,
    ubCyrillic,
    ubCyrillicSupplement,
    ubArmenian,
    ubHebrew,
    ubArabic,
    ubSyriac,
    ubArabicSupplement,
    ubThaana,
    ubNKo,
    ubSamaritan,
    ubMandaic,
    ubSyriacSupplement,
    ubArabicExtendedA,
    ubDevanagari,
    ubBengali,
    ubGurmukhi,
    ubGujarati,
    ubOriya,
    ubTamil,
    ubTelugu,
    ubKannada,
    ubMalayalam,
    ubSinhala,
    ubThai,
    ubLao,
    ubTibetan,
    ubMyanmar,
    ubGeorgian,
    ubHangulJamo,
    ubEthiopic,
    ubEthiopicSupplement,
    ubCherokee,
    ubUnifiedCanadianAboriginalSyllabics,
    ubOgham,
    ubRunic,
    ubTagalog,
    ubHanunoo,
    ubBuhid,
    ubTagbanwa,
    ubKhmer,
    ubMongolian,
    ubUnifiedCanadianAboriginalSyllabicsExtended,
    ubLimbu,
    ubTaiLe,
    ubNewTaiLue,
    ubKhmerSymbols,
    ubBuginese,
    ubTaiTham,
    ubCombiningDiactiticalMarksExtended,
    ubBalinese,
    ubSundanese,
    ubBatak,
    ubLepcha,
    ubOlChiki,
    ubCyrillicExtendedC,
    ubGeorgianExtended,
    ubSundaneseSupplement,
    ubVedicExtensions,
    ubPhoneticExtensions,
    ubPhoneticExtensionsSupplement,
    ubCombiningDiacriticalMarksSupplement,
    ubLatinExtendedAdditional,
    ubGreekExtended,
    ubGeneralPunctuation,
    ubSuperscriptsandSubscripts,
    ubCurrencySymbols,
    ubCombiningDiacriticalMarksforSymbols,
    ubLetterlikeSymbols,
    ubNumberForms,
    ubArrows,
    ubMathematicalOperators,
    ubMiscellaneousTechnical,
    ubControlPictures,
    ubOpticalCharacterRecognition,
    ubEnclosedAlphanumerics,
    ubBoxDrawing,
    ubBlockElements,
    ubGeometricShapes,
    ubMiscellaneousSymbols,
    ubDingbats,
    ubMiscellaneousMathematicalSymbolsA,
    ubSupplementalArrowsA,
    ubBraillePatterns,
    ubSupplementalArrowsB,
    ubMiscellaneousMathematicalSymbolsB,
    ubSupplementalMathematicalOperators,
    ubMiscellaneousSymbolsandArrows,
    ubGlagolitic,
    ubLatinExtendedC,
    ubCoptic,
    ubGeorgianSupplement,
    ubTifinagh,
    ubEthiopicExtended,
    ubCyrillicExtendedA,
    ubSupplementalPunctuation,
    ubCJKRadicalsSupplement,
    ubKangxiRadicals,
    ubIdeographicDescriptionCharacters,
    ubCJKSymbolsandPunctuation,
    ubHiragana,
    ubKatakana,
    ubBopomofo,
    ubHangulCompatibilityJamo,
    ubKanbun,
    ubBopomofoExtended,
    ubCJKStrokes,
    ubKatakanaPhoneticExtensions,
    ubEnclosedCJKLettersandMonths,
    ubCJKCompatibility,
    ubCJKUnifiedIdeographsExtensionA,
    ubYijingHexagramSymbols,
    ubCJKUnifiedIdeographs,
    ubYiSyllables,
    ubYiRadicals,
    ubLisu,
    ubVai,
    ubCyrillicExtendedB,
    ubBamum,
    ubModifierToneLetters,
    ubLatinExtendedD,
    ubSylotiNagri,
    ubCommonIndicNumberForms,
    ubPhagsPa,
    ubSaurashtra,
    ubDevanagariExtended,
    ubKayahLi,
    ubRejang,
    ubHangulJamoExtendedA,
    ubJavanese,
    ubMyanmarExtendedB,
    ubCham,
    ubMyanmarExtendedA,
    ubTaiViet,
    ubMeeteiMayekExtensions,
    ubEthiopicExtendedA,
    ubLatinExtendedE,
    ubCherokeeSupplement,
    ubMeeteiMayek,
    ubHangulSyllables,
    ubHangulJamoExtendedB,
    ubHighSurrogates,
    ubHighPrivateUseSurrogates,
    ubLowSurrogates,
    ubPrivateUseArea,
    ubCJKCompatibilityIdeographs,
    ubAlphabeticPresentationForms,
    ubArabicPresentationFormsA,
    ubVariationSelectors,
    ubVerticalForms,
    ubCombiningHalfMarks,
    ubCJKCompatibilityForms,
    ubSmallFormVariants,
    ubArabicPresentationFormsB,
    ubHalfwidthandFullwidthForms,
    ubSpecials,
    ubLinearBSyllabary,
    ubLinearBIdeograms,
    ubAegeanNumbers,
    ubAncientGreekNumbers,
    ubAncientSymbols,
    ubPhaistosDisc,
    ubLycian,
    ubCarian,
    ubCopticEpactNumbers,
    ubOldItalic,
    ubGothic,
    ubOldPermic,
    ubUgaritic,
    ubOldPersian,
    ubDeseret,
    ubShavian,
    ubOsmanya,
    ubOsage,
    ubElbasan,
    ubCaucasianAlbanian,
    ubLinearA,
    ubCypriotSyllabary,
    ubImperialAramaic,
    ubPalmyrene,
    ubNabataean,
    ubHatran,
    ubPhoenician,
    ubLydian,
    ubMeroiticHieroglyphs,
    ubMeroiticCursive,
    ubKharoshthi,
    ubOldSouthArabian,
    ubOldNorthArabian,
    ubManichaean,
    ubAvestan,
    ubInscriptionalParthian,
    ubInscriptionalPahlavi,
    ubPsalterPahlavi,
    ubOldTurkic,
    ubOldHungarian,
    ubHanifiRohingya,
    ubRumiNumeralSymbols,
    ubYezidi,
    ubOldSogdian,
    ubSogdian,
    ubChorasmian,
    ubElymaic,
    ubBrahmi,
    ubKaithi,
    ubSoraSompeng,
    ubChakma,
    ubMahajani,
    ubSharada,
    ubSinhalaArchaicNumbers,
    ubKhojki,
    ubMultani,
    ubKhudawadi,
    ubGrantha,
    ubNewa,
    ubTirhuta,
    ubSiddam,
    ubModi,
    ubMongolianSupplement,
    ubTakri,
    ubAhom,
    ubDogra,
    ubWarangCiti,
    ubDivesAkuru,
    ubNandinagari,
    ubZanabazarSquare,
    ubSoyombo,
    ubPauCinHau,
    ubBhaiksuki,
    ubMarchen,
    ubMasaramGondi,
    ubGunjalaGondi,
    ubTamilSupplement,
    ubMakasar,
    ubLisuSupplement,
    ubCuneiform,
    ubCuneiformNumbersAndPunctuation,
    ubEarlyDynasticCuneiform,
    ubEgyptianHieroglyphs,
    ubEgyptianHieroglyphFormatControls,
    ubAnatolianHieroglyphs,
    ubBamumSupplement,
    ubMro,
    ubBassaVah,
    ubPahawhHmong,
    ubMedefaidrin,
    ubMiao,
    upIdeographicSymbolsAndPunctuation,
    ubTangut,
    ubTangutComponents,
    ubKhitanSmallScript,
    ubTangutSupplement,
    ubKanaSupplement,
    ubKanaExtendedA,
    ubSmallKanaExtension,
    ubNushu,
    ubDuployan,
    ubShorthandFormatControls,
    ubByzantineMusicalSymbols,
    ubMusicalSymbols,
    ubAncientGreekMusicalNotation,
    ubMayanNumerals,
    ubTaiXuanJingSymbols,
    ubCountingRodNumerals,
    ubSuttonSignWriting,
    ubMathematicalAlphanumericSymbols,
    ubGlagolithicSupplement,
    ubWancho,
    ubNyiakengPuachueHmong,
    ubMendeKikakui,
    ubIndicSiyaqNumbers,
    ubOttomanSiyaqNumbers,
    ubAdlam,
    ubArabicMathematicalAlphabeticSymbols,
    ubMahjongTiles,
    ubDominoTiles,
    ubPlayingCards,
    ubEnclosedAlphanumericSupplement,
    ubEnclosedIdeographicSupplement,
    ubMiscellaneousSymbolsAndPictographs,
    ubEmoticons,
    ubOrnamentalDingbats,
    ubTransportAndMapSymbols,
    ubAlchemicalSymbols,
    ubGeometricShapesExtended,
    ubSupplementalArrowsC,
    ubSupplementalSymbolsAndPictographs,
    ubChessSymbols,
    ubSymbolsAndPictographsExtendedA,
    ubSymbolsForLegacyComputing,
    ubCJKUnifiedIdeographsExtensionB,
    ubCJKUnifiedIdeographsExtensionC,
    ubCJKUnifiedIdeographsExtensionD,
    ubCJKUnifiedIdeographsExtensionE,
    ubCJKUnifiedIdeographsExtensionF,
    ubCJKCompatibilityIdeographsSupplement,
    ubCJKUnifiedIdeographsExtensionG,
    ubTags,
    ubVariationSelectorsSupplement,
    ubSupplementaryPrivateUseAreaA,
    ubSupplementaryPrivateUseAreaB
  );
  TUnicodeBlockData = record
    Range: TUnicodeBlockRange;
    Name: string;
  end;
  PUnicodeBlockData = ^TUnicodeBlockData;
const
  UnicodeBlockData: array [TUnicodeBlock] of TUnicodeBlockData =
    ((Range:(RangeStart: $FFFFFFFF; RangeEnd: $0000); Name: 'No-block'),
    (Range:(RangeStart: $0000; RangeEnd: $007F); Name: 'Basic Latin'),
    (Range:(RangeStart: $0080; RangeEnd: $00FF); Name: 'Latin-1 Supplement'),
    (Range:(RangeStart: $0100; RangeEnd: $017F); Name: 'Latin Extended-A'),
    (Range:(RangeStart: $0180; RangeEnd: $024F); Name: 'Latin Extended-B'),
    (Range:(RangeStart: $0250; RangeEnd: $02AF); Name: 'IPA Extensions'),
    (Range:(RangeStart: $02B0; RangeEnd: $02FF); Name: 'Spacing Modifier Letters'),
    (Range:(RangeStart: $0300; RangeEnd: $036F); Name: 'Combining Diacritical Marks'),
    (Range:(RangeStart: $0370; RangeEnd: $03FF); Name: 'Greek and Coptic'),
    (Range:(RangeStart: $0400; RangeEnd: $04FF); Name: 'Cyrillic'),
    (Range:(RangeStart: $0500; RangeEnd: $052F); Name: 'Cyrillic Supplement'),
    (Range:(RangeStart: $0530; RangeEnd: $058F); Name: 'Armenian'),
    (Range:(RangeStart: $0590; RangeEnd: $05FF); Name: 'Hebrew'),
    (Range:(RangeStart: $0600; RangeEnd: $06FF); Name: 'Arabic'),
    (Range:(RangeStart: $0700; RangeEnd: $074F); Name: 'Syriac'),
    (Range:(RangeStart: $0750; RangeEnd: $077F); Name: 'Arabic Supplement'),
    (Range:(RangeStart: $0780; RangeEnd: $07BF); Name: 'Thaana'),
    (Range:(RangeStart: $07C0; RangeEnd: $07FF); Name: 'NKo'),
    (Range:(RangeStart: $0800; RangeEnd: $083F); Name: 'Samaritan'),
    (Range:(RangeStart: $0840; RangeEnd: $085F); Name: 'Mandaic'),
    (Range:(RangeStart: $0860; RangeEnd: $086F); Name: 'Syriac Supplement'),
    (Range:(RangeStart: $08A0; RangeEnd: $08FF); Name: 'Arabic Extended-A'),
    (Range:(RangeStart: $0900; RangeEnd: $097F); Name: 'Devanagari'),
    (Range:(RangeStart: $0980; RangeEnd: $09FF); Name: 'Bengali'),
    (Range:(RangeStart: $0A00; RangeEnd: $0A7F); Name: 'Gurmukhi'),
    (Range:(RangeStart: $0A80; RangeEnd: $0AFF); Name: 'Gujarati'),
    (Range:(RangeStart: $0B00; RangeEnd: $0B7F); Name: 'Oriya'),
    (Range:(RangeStart: $0B80; RangeEnd: $0BFF); Name: 'Tamil'),
    (Range:(RangeStart: $0C00; RangeEnd: $0C7F); Name: 'Telugu'),
    (Range:(RangeStart: $0C80; RangeEnd: $0CFF); Name: 'Kannada'),
    (Range:(RangeStart: $0D00; RangeEnd: $0D7F); Name: 'Malayalam'),
    (Range:(RangeStart: $0D80; RangeEnd: $0DFF); Name: 'Sinhala'),
    (Range:(RangeStart: $0E00; RangeEnd: $0E7F); Name: 'Thai'),
    (Range:(RangeStart: $0E80; RangeEnd: $0EFF); Name: 'Lao'),
    (Range:(RangeStart: $0F00; RangeEnd: $0FFF); Name: 'Tibetan'),
    (Range:(RangeStart: $1000; RangeEnd: $109F); Name: 'Myanmar'),
    (Range:(RangeStart: $10A0; RangeEnd: $10FF); Name: 'Georgian'),
    (Range:(RangeStart: $1100; RangeEnd: $11FF); Name: 'Hangul Jamo'),
    (Range:(RangeStart: $1200; RangeEnd: $137F); Name: 'Ethiopic'),
    (Range:(RangeStart: $1380; RangeEnd: $139F); Name: 'Ethiopic Supplement'),
    (Range:(RangeStart: $13A0; RangeEnd: $13FF); Name: 'Cherokee'),
    (Range:(RangeStart: $1400; RangeEnd: $167F); Name: 'Unified Canadian Aboriginal Syllabics'),
    (Range:(RangeStart: $1680; RangeEnd: $169F); Name: 'Ogham'),
    (Range:(RangeStart: $16A0; RangeEnd: $16FF); Name: 'Runic'),
    (Range:(RangeStart: $1700; RangeEnd: $171F); Name: 'Tagalog'),
    (Range:(RangeStart: $1720; RangeEnd: $173F); Name: 'Hanunoo'),
    (Range:(RangeStart: $1740; RangeEnd: $175F); Name: 'Buhid'),
    (Range:(RangeStart: $1760; RangeEnd: $177F); Name: 'Tagbanwa'),
    (Range:(RangeStart: $1780; RangeEnd: $17FF); Name: 'Khmer'),
    (Range:(RangeStart: $1800; RangeEnd: $18AF); Name: 'Mongolian'),
    (Range:(RangeStart: $18B0; RangeEnd: $18FF); Name: 'Unified Canadian Aboriginal Syllabics Extended'),
    (Range:(RangeStart: $1900; RangeEnd: $194F); Name: 'Limbu'),
    (Range:(RangeStart: $1950; RangeEnd: $197F); Name: 'Tai Le'),
    (Range:(RangeStart: $1980; RangeEnd: $19DF); Name: 'New Tai Lue'),
    (Range:(RangeStart: $19E0; RangeEnd: $19FF); Name: 'Khmer Symbols'),
    (Range:(RangeStart: $1A00; RangeEnd: $1A1F); Name: 'Buginese'),
    (Range:(RangeStart: $1A20; RangeEnd: $1AAF); Name: 'Tai Tham'),
    (Range:(RangeStart: $1AB0; RangeEnd: $1AFF); Name: 'Combining Diacritical Marks Extended'),
    (Range:(RangeStart: $1B00; RangeEnd: $1B7F); Name: 'Balinese'),
    (Range:(RangeStart: $1B80; RangeEnd: $1BBF); Name: 'Sundanese'),
    (Range:(RangeStart: $1BC0; RangeEnd: $1BFF); Name: 'Batak'),
    (Range:(RangeStart: $1C00; RangeEnd: $1C4F); Name: 'Lepcha'),
    (Range:(RangeStart: $1C50; RangeEnd: $1C7F); Name: 'Ol Chiki'),
    (Range:(RangeStart: $1C80; RangeEnd: $1C8F); Name: 'Cyrillic Extended-C'),
    (Range:(RangeStart: $1C90; RangeEnd: $1CBF); Name: 'Georgian Extended'),
    (Range:(RangeStart: $1CC0; RangeEnd: $1CCF); Name: 'Sundanese Supplement'),
    (Range:(RangeStart: $1CD0; RangeEnd: $1CFF); Name: 'Vedic Extensions'),
    (Range:(RangeStart: $1D00; RangeEnd: $1D7F); Name: 'Phonetic Extensions'),
    (Range:(RangeStart: $1D80; RangeEnd: $1DBF); Name: 'Phonetic Extensions Supplement'),
    (Range:(RangeStart: $1DC0; RangeEnd: $1DFF); Name: 'Combining Diacritical Marks Supplement'),
    (Range:(RangeStart: $1E00; RangeEnd: $1EFF); Name: 'Latin Extended Additional'),
    (Range:(RangeStart: $1F00; RangeEnd: $1FFF); Name: 'Greek Extended'),
    (Range:(RangeStart: $2000; RangeEnd: $206F); Name: 'General Punctuation'),
    (Range:(RangeStart: $2070; RangeEnd: $209F); Name: 'Superscripts and Subscripts'),
    (Range:(RangeStart: $20A0; RangeEnd: $20CF); Name: 'Currency Symbols'),
    (Range:(RangeStart: $20D0; RangeEnd: $20FF); Name: 'Combining Diacritical Marks for Symbols'),
    (Range:(RangeStart: $2100; RangeEnd: $214F); Name: 'Letterlike Symbols'),
    (Range:(RangeStart: $2150; RangeEnd: $218F); Name: 'Number Forms'),
    (Range:(RangeStart: $2190; RangeEnd: $21FF); Name: 'Arrows'),
    (Range:(RangeStart: $2200; RangeEnd: $22FF); Name: 'Mathematical Operators'),
    (Range:(RangeStart: $2300; RangeEnd: $23FF); Name: 'Miscellaneous Technical'),
    (Range:(RangeStart: $2400; RangeEnd: $243F); Name: 'Control Pictures'),
    (Range:(RangeStart: $2440; RangeEnd: $245F); Name: 'Optical Character Recognition'),
    (Range:(RangeStart: $2460; RangeEnd: $24FF); Name: 'Enclosed Alphanumerics'),
    (Range:(RangeStart: $2500; RangeEnd: $257F); Name: 'Box Drawing'),
    (Range:(RangeStart: $2580; RangeEnd: $259F); Name: 'Block Elements'),
    (Range:(RangeStart: $25A0; RangeEnd: $25FF); Name: 'Geometric Shapes'),
    (Range:(RangeStart: $2600; RangeEnd: $26FF); Name: 'Miscellaneous Symbols'),
    (Range:(RangeStart: $2700; RangeEnd: $27BF); Name: 'Dingbats'),
    (Range:(RangeStart: $27C0; RangeEnd: $27EF); Name: 'Miscellaneous Mathematical Symbols-A'),
    (Range:(RangeStart: $27F0; RangeEnd: $27FF); Name: 'Supplemental Arrows-A'),
    (Range:(RangeStart: $2800; RangeEnd: $28FF); Name: 'Braille Patterns'),
    (Range:(RangeStart: $2900; RangeEnd: $297F); Name: 'Supplemental Arrows-B'),
    (Range:(RangeStart: $2980; RangeEnd: $29FF); Name: 'Miscellaneous Mathematical Symbols-B'),
    (Range:(RangeStart: $2A00; RangeEnd: $2AFF); Name: 'Supplemental Mathematical Operators'),
    (Range:(RangeStart: $2B00; RangeEnd: $2BFF); Name: 'Miscellaneous Symbols and Arrows'),
    (Range:(RangeStart: $2C00; RangeEnd: $2C5F); Name: 'Glagolitic'),
    (Range:(RangeStart: $2C60; RangeEnd: $2C7F); Name: 'Latin Extended-C'),
    (Range:(RangeStart: $2C80; RangeEnd: $2CFF); Name: 'Coptic'),
    (Range:(RangeStart: $2D00; RangeEnd: $2D2F); Name: 'Georgian Supplement'),
    (Range:(RangeStart: $2D30; RangeEnd: $2D7F); Name: 'Tifinagh'),
    (Range:(RangeStart: $2D80; RangeEnd: $2DDF); Name: 'Ethiopic Extended'),
    (Range:(RangeStart: $2DE0; RangeEnd: $2DFF); Name: 'Cyrillic Extended-A'),
    (Range:(RangeStart: $2E00; RangeEnd: $2E7F); Name: 'Supplemental Punctuation'),
    (Range:(RangeStart: $2E80; RangeEnd: $2EFF); Name: 'CJK Radicals Supplement'),
    (Range:(RangeStart: $2F00; RangeEnd: $2FDF); Name: 'Kangxi Radicals'),
    (Range:(RangeStart: $2FF0; RangeEnd: $2FFF); Name: 'Ideographic Description Characters'),
    (Range:(RangeStart: $3000; RangeEnd: $303F); Name: 'CJK Symbols and Punctuation'),
    (Range:(RangeStart: $3040; RangeEnd: $309F); Name: 'Hiragana'),
    (Range:(RangeStart: $30A0; RangeEnd: $30FF); Name: 'Katakana'),
    (Range:(RangeStart: $3100; RangeEnd: $312F); Name: 'Bopomofo'),
    (Range:(RangeStart: $3130; RangeEnd: $318F); Name: 'Hangul Compatibility Jamo'),
    (Range:(RangeStart: $3190; RangeEnd: $319F); Name: 'Kanbun'),
    (Range:(RangeStart: $31A0; RangeEnd: $31BF); Name: 'Bopomofo Extended'),
    (Range:(RangeStart: $31C0; RangeEnd: $31EF); Name: 'CJK Strokes'),
    (Range:(RangeStart: $31F0; RangeEnd: $31FF); Name: 'Katakana Phonetic Extensions'),
    (Range:(RangeStart: $3200; RangeEnd: $32FF); Name: 'Enclosed CJK Letters and Months'),
    (Range:(RangeStart: $3300; RangeEnd: $33FF); Name: 'CJK Compatibility'),
    (Range:(RangeStart: $3400; RangeEnd: $4DBF); Name: 'CJK Unified Ideographs Extension A'),
    (Range:(RangeStart: $4DC0; RangeEnd: $4DFF); Name: 'Yijing Hexagram Symbols'),
    (Range:(RangeStart: $4E00; RangeEnd: $9FFC); Name: 'CJK Unified Ideographs'),
    (Range:(RangeStart: $A000; RangeEnd: $A48F); Name: 'Yi Syllables'),
    (Range:(RangeStart: $A490; RangeEnd: $A4CF); Name: 'Yi Radicals'),
    (Range:(RangeStart: $A4D0; RangeEnd: $A4FF); Name: 'Lisu'),
    (Range:(RangeStart: $A500; RangeEnd: $A63F); Name: 'Vai'),
    (Range:(RangeStart: $A640; RangeEnd: $A69F); Name: 'Cyrillic Extended-B'),
    (Range:(RangeStart: $A6A0; RangeEnd: $A6FF); Name: 'Bamum'),
    (Range:(RangeStart: $A700; RangeEnd: $A71F); Name: 'Modifier Tone Letters'),
    (Range:(RangeStart: $A720; RangeEnd: $A7FF); Name: 'Latin Extended-D'),
    (Range:(RangeStart: $A800; RangeEnd: $A82F); Name: 'Syloti Nagri'),
    (Range:(RangeStart: $A830; RangeEnd: $A83F); Name: 'Common Indic Number Forms'),
    (Range:(RangeStart: $A840; RangeEnd: $A87F); Name: 'Phags-pa'),
    (Range:(RangeStart: $A880; RangeEnd: $A8DF); Name: 'Saurashtra'),
    (Range:(RangeStart: $A8E0; RangeEnd: $A8FF); Name: 'Devanagari Extended'),
    (Range:(RangeStart: $A900; RangeEnd: $A92F); Name: 'Kayah Li'),
    (Range:(RangeStart: $A930; RangeEnd: $A95F); Name: 'Rejang'),
    (Range:(RangeStart: $A960; RangeEnd: $A97F); Name: 'Hangul Jamo Extended-A'),
    (Range:(RangeStart: $A980; RangeEnd: $A9DF); Name: 'Javanese'),
    (Range:(RangeStart: $A9E0; RangeEnd: $A9FF); Name: 'Myanmar Extended-B'),
    (Range:(RangeStart: $AA00; RangeEnd: $AA5F); Name: 'Cham'),
    (Range:(RangeStart: $AA60; RangeEnd: $AA7F); Name: 'Myanmar Extended-A'),
    (Range:(RangeStart: $AA80; RangeEnd: $AADF); Name: 'Tai Viet'),
    (Range:(RangeStart: $AAE0; RangeEnd: $AAFF); Name: 'Meetei Mayek Extensions'),
    (Range:(RangeStart: $AB00; RangeEnd: $AB2F); Name: 'Ethiopic Extended-A'),
    (Range:(RangeStart: $AB30; RangeEnd: $AB6F); Name: 'Latin Extended-E'),
    (Range:(RangeStart: $AB70; RangeEnd: $ABBF); Name: 'Cherokee Supplement'),
    (Range:(RangeStart: $ABC0; RangeEnd: $ABFF); Name: 'Meetei Mayek'),
    (Range:(RangeStart: $AC00; RangeEnd: $D7AF); Name: 'Hangul Syllables'),
    (Range:(RangeStart: $D7B0; RangeEnd: $D7FF); Name: 'Hangul Jamo Extended-B'),
    (Range:(RangeStart: $D800; RangeEnd: $DB7F); Name: 'High Surrogates'),
    (Range:(RangeStart: $DB80; RangeEnd: $DBFF); Name: 'High Private Use Surrogates'),
    (Range:(RangeStart: $DC00; RangeEnd: $DFFF); Name: 'Low Surrogates'),
    (Range:(RangeStart: $E000; RangeEnd: $F8FF); Name: 'Private Use Area'),
    (Range:(RangeStart: $F900; RangeEnd: $FAFF); Name: 'CJK Compatibility Ideographs'),
    (Range:(RangeStart: $FB00; RangeEnd: $FB4F); Name: 'Alphabetic Presentation Forms'),
    (Range:(RangeStart: $FB50; RangeEnd: $FDFF); Name: 'Arabic Presentation Forms-A'),
    (Range:(RangeStart: $FE00; RangeEnd: $FE0F); Name: 'Variation Selectors'),
    (Range:(RangeStart: $FE10; RangeEnd: $FE1F); Name: 'Vertical Forms'),
    (Range:(RangeStart: $FE20; RangeEnd: $FE2F); Name: 'Combining Half Marks'),
    (Range:(RangeStart: $FE30; RangeEnd: $FE4F); Name: 'CJK Compatibility Forms'),
    (Range:(RangeStart: $FE50; RangeEnd: $FE6F); Name: 'Small Form Variants'),
    (Range:(RangeStart: $FE70; RangeEnd: $FEFF); Name: 'Arabic Presentation Forms-B'),
    (Range:(RangeStart: $FF00; RangeEnd: $FFEF); Name: 'Halfwidth and Fullwidth Forms'),
    (Range:(RangeStart: $FFF0; RangeEnd: $FFFF); Name: 'Specials'),
    (Range:(RangeStart: $10000; RangeEnd: $1007F); Name: 'Linear B Syllabary'),
    (Range:(RangeStart: $10080; RangeEnd: $100FF); Name: 'Linear B Ideograms'),
    (Range:(RangeStart: $10100; RangeEnd: $1013F); Name: 'Aegean Numbers'),
    (Range:(RangeStart: $10140; RangeEnd: $1018F); Name: 'Ancient Greek Numbers'),
    (Range:(RangeStart: $10190; RangeEnd: $101CF); Name: 'Ancient Symbols'),
    (Range:(RangeStart: $101D0; RangeEnd: $101FF); Name: 'Phaistos Disc'),
    (Range:(RangeStart: $10280; RangeEnd: $1029F); Name: 'Lycian'),
    (Range:(RangeStart: $102A0; RangeEnd: $102DF); Name: 'Carian'),
    (Range:(RangeStart: $102E0; RangeEnd: $102FF); Name: 'Coptic Epact Numbers'),
    (Range:(RangeStart: $10300; RangeEnd: $1032F); Name: 'Old Italic'),
    (Range:(RangeStart: $10330; RangeEnd: $1034F); Name: 'Gothic'),
    (Range:(RangeStart: $10350; RangeEnd: $1037F); Name: 'Old Permic'),
    (Range:(RangeStart: $10380; RangeEnd: $1039F); Name: 'Ugaritic'),
    (Range:(RangeStart: $103A0; RangeEnd: $103DF); Name: 'Old Persian'),
    (Range:(RangeStart: $10400; RangeEnd: $1044F); Name: 'Deseret'),
    (Range:(RangeStart: $10450; RangeEnd: $1047F); Name: 'Shavian'),
    (Range:(RangeStart: $10480; RangeEnd: $104AF); Name: 'Osmanya'),
    (Range:(RangeStart: $104B0; RangeEnd: $104FF); Name: 'Osage'),
    (Range:(RangeStart: $10500; RangeEnd: $1052F); Name: 'Elbasan'),
    (Range:(RangeStart: $10530; RangeEnd: $1056F); Name: 'Caucasian Albanian'),
    (Range:(RangeStart: $10600; RangeEnd: $1077F); Name: 'Linear A'),
    (Range:(RangeStart: $10800; RangeEnd: $1083F); Name: 'Cypriot Syllabary'),
    (Range:(RangeStart: $10840; RangeEnd: $1085F); Name: 'Imperial Aramaic'),
    (Range:(RangeStart: $10860; RangeEnd: $1087F); Name: 'Palmyrene'),
    (Range:(RangeStart: $10880; RangeEnd: $108AF); Name: 'Nabataean'),
    (Range:(RangeStart: $108E0; RangeEnd: $108FF); Name: 'Hatran'),
    (Range:(RangeStart: $10900; RangeEnd: $1091F); Name: 'Phoenician'),
    (Range:(RangeStart: $10920; RangeEnd: $1093F); Name: 'Lydian'),
    (Range:(RangeStart: $10980; RangeEnd: $1099F); Name: 'Meroitic Hieroglyphs'),
    (Range:(RangeStart: $109A0; RangeEnd: $109FF); Name: 'Meroitic Cursive'),
    (Range:(RangeStart: $10A00; RangeEnd: $10A5F); Name: 'Kharoshthi'),
    (Range:(RangeStart: $10A60; RangeEnd: $10A7F); Name: 'Old South Arabian'),
    (Range:(RangeStart: $10A80; RangeEnd: $10A9F); Name: 'Old North Arabian'),
    (Range:(RangeStart: $10AC0; RangeEnd: $10AFF); Name: 'Manichaean'),
    (Range:(RangeStart: $10B00; RangeEnd: $10B3F); Name: 'Avestan'),
    (Range:(RangeStart: $10B40; RangeEnd: $10B5F); Name: 'Inscriptional Parthian'),
    (Range:(RangeStart: $10B60; RangeEnd: $10B7F); Name: 'Inscriptional Pahlavi'),
    (Range:(RangeStart: $10B80; RangeEnd: $10BAF); Name: 'Psalter Pahlavi'),
    (Range:(RangeStart: $10C00; RangeEnd: $10C4F); Name: 'Old Turkic'),
    (Range:(RangeStart: $10C80; RangeEnd: $10CFF); Name: 'Old Hungarian'),
    (Range:(RangeStart: $10D00; RangeEnd: $10D3F); Name: 'Hanifi Rohingya'),
    (Range:(RangeStart: $10E60; RangeEnd: $10E7F); Name: 'Rumi Numeral Symbols'),
    (Range:(RangeStart: $10E80; RangeEnd: $10EBF); Name: 'Yezidi'),
    (Range:(RangeStart: $10F00; RangeEnd: $10F2F); Name: 'Old Sogdian'),
    (Range:(RangeStart: $10F30; RangeEnd: $10FAF); Name: 'Sogdian'),
    (Range:(RangeStart: $10FB0; RangeEnd: $10FDF); Name: 'Chorasmian'),
    (Range:(RangeStart: $10FE0; RangeEnd: $10FFF); Name: 'Elymaic'),
    (Range:(RangeStart: $11000; RangeEnd: $1107F); Name: 'Brahmi'),
    (Range:(RangeStart: $11080; RangeEnd: $110CF); Name: 'Kaithi'),
    (Range:(RangeStart: $110D0; RangeEnd: $110FF); Name: 'Sora Sompeng'),
    (Range:(RangeStart: $11100; RangeEnd: $1114F); Name: 'Chakma'),
    (Range:(RangeStart: $11150; RangeEnd: $1117F); Name: 'Mahajani'),
    (Range:(RangeStart: $11180; RangeEnd: $111DF); Name: 'Sharada'),
    (Range:(RangeStart: $111E0; RangeEnd: $111FF); Name: 'Sinhala Archaic Numbers'),
    (Range:(RangeStart: $11200; RangeEnd: $1124F); Name: 'Khojki'),
    (Range:(RangeStart: $11280; RangeEnd: $112AF); Name: 'Multani'),
    (Range:(RangeStart: $112B0; RangeEnd: $112FF); Name: 'Khudawadi'),
    (Range:(RangeStart: $11300; RangeEnd: $1137F); Name: 'Grantha'),
    (Range:(RangeStart: $11400; RangeEnd: $1147F); Name: 'Newa'),
    (Range:(RangeStart: $11480; RangeEnd: $114DF); Name: 'Tirhuta'),
    (Range:(RangeStart: $11580; RangeEnd: $115FF); Name: 'Siddam'),
    (Range:(RangeStart: $11600; RangeEnd: $1165F); Name: 'Modi'),
    (Range:(RangeStart: $11660; RangeEnd: $1167F); Name: 'Mongolian Supplement'),
    (Range:(RangeStart: $11680; RangeEnd: $116CF); Name: 'Takri'),
    (Range:(RangeStart: $11700; RangeEnd: $1173F); Name: 'Ahom'),
    (Range:(RangeStart: $11800; RangeEnd: $1184F); Name: 'Dogra'),
    (Range:(RangeStart: $118A0; RangeEnd: $118FF); Name: 'Warang Citi'),
    (Range:(RangeStart: $11900; RangeEnd: $1195F); Name: 'Dives Akuru'),
    (Range:(RangeStart: $119A0; RangeEnd: $119FF); Name: 'Nandinagari'),
    (Range:(RangeStart: $11A00; RangeEnd: $11A4F); Name: 'Zanabazar Square'),
    (Range:(RangeStart: $11A50; RangeEnd: $11AAF); Name: 'Soyombo'),
    (Range:(RangeStart: $11AC0; RangeEnd: $11AFF); Name: 'Pau Cin Hau'),
    (Range:(RangeStart: $11C00; RangeEnd: $11C6F); Name: 'Bhaiksuki'),
    (Range:(RangeStart: $11C70; RangeEnd: $11CBF); Name: 'Marchen'),
    (Range:(RangeStart: $11D00; RangeEnd: $11D5F); Name: 'Masaram Gondi'),
    (Range:(RangeStart: $11D60; RangeEnd: $11DAF); Name: 'Gunjala Gondi'),
    (Range:(RangeStart: $11EE0; RangeEnd: $11EFF); Name: 'Makasar'),
    (Range:(RangeStart: $11FB0; RangeEnd: $11FBF); Name: 'Lisu Supplement'),
    (Range:(RangeStart: $11FC0; RangeEnd: $11FFF); Name: 'Tamil Supplement'),
    (Range:(RangeStart: $12000; RangeEnd: $123FF); Name: 'Cuneiform'),
    (Range:(RangeStart: $12400; RangeEnd: $1247F); Name: 'Cuneiform Numbers and Punctuation'),
    (Range:(RangeStart: $12480; RangeEnd: $1254F); Name: 'Early Dynastic Cuneiform'),
    (Range:(RangeStart: $13000; RangeEnd: $1342F); Name: 'Egyptian Hieroglyphs'),
    (Range:(RangeStart: $13430; RangeEnd: $1343F); Name: 'Egyptian Hieroglyph Format Controls'),
    (Range:(RangeStart: $14400; RangeEnd: $1467F); Name: 'Anatolian Hieroglyphs'),
    (Range:(RangeStart: $16800; RangeEnd: $16A3F); Name: 'Bamum Supplement'),
    (Range:(RangeStart: $16A40; RangeEnd: $16A6F); Name: 'Mro'),
    (Range:(RangeStart: $16AD0; RangeEnd: $16AFF); Name: 'Bassa Vah'),
    (Range:(RangeStart: $16B00; RangeEnd: $16B8F); Name: 'Pahawh Hmong'),
    (Range:(RangeStart: $16E40; RangeEnd: $16E9F); Name: 'Medefaidrin'),
    (Range:(RangeStart: $16F00; RangeEnd: $16F9F); Name: 'Miao'),
    (Range:(RangeStart: $16FE0; RangeEnd: $16FFF); Name: 'Ideographic Symbols and Punctuation'),
    (Range:(RangeStart: $17000; RangeEnd: $187F7); Name: 'Tangut'),
    (Range:(RangeStart: $18800; RangeEnd: $18AFF); Name: 'Tangut Components'),
    (Range:(RangeStart: $18B00; RangeEnd: $18CFF); Name: 'Khitan Small Script'),
    (Range:(RangeStart: $18D00; RangeEnd: $18D08); Name: 'Tangut Supplement'),
    (Range:(RangeStart: $1B000; RangeEnd: $1B0FF); Name: 'Kana Supplement'),
    (Range:(RangeStart: $1B100; RangeEnd: $1B12F); Name: 'Kana Extended-A'),
    (Range:(RangeStart: $1B130; RangeEnd: $1B16F); Name: 'Small Kana Extension'),
    (Range:(RangeStart: $1B170; RangeEnd: $1B2FF); Name: 'Nushu'),
    (Range:(RangeStart: $1BC00; RangeEnd: $1BC9F); Name: 'Duployan'),
    (Range:(RangeStart: $1BCA0; RangeEnd: $1BCAF); Name: 'Shorthand Format Controls'),
    (Range:(RangeStart: $1D000; RangeEnd: $1D0FF); Name: 'Byzantine Musical Symbols'),
    (Range:(RangeStart: $1D100; RangeEnd: $1D1FF); Name: 'Musical Symbols'),
    (Range:(RangeStart: $1D200; RangeEnd: $1D24F); Name: 'Ancient Greek Musical Notation'),
    (Range:(RangeStart: $1D2E0; RangeEnd: $1D2FF); Name: 'Mayan Numerals'),
    (Range:(RangeStart: $1D300; RangeEnd: $1D35F); Name: 'Tai Xuan Jing Symbols'),
    (Range:(RangeStart: $1D360; RangeEnd: $1D37F); Name: 'Counting Rod Numerals'),
    (Range:(RangeStart: $1D400; RangeEnd: $1D7FF); Name: 'Mathematical Alphanumeric Symbols'),
    (Range:(RangeStart: $1D800; RangeEnd: $1DAAF); Name: 'Sutton SignWriting'),
    (Range:(RangeStart: $1E000; RangeEnd: $1E02F); Name: 'Glagolitic Supplement'),
    (Range:(RangeStart: $1E100; RangeEnd: $1E14F); Name: 'Nyiakeng Puachue Hmong'),
    (Range:(RangeStart: $1E2C0; RangeEnd: $1E2FF); Name: 'Wancho'),
    (Range:(RangeStart: $1E800; RangeEnd: $1E8DF); Name: 'Mende Kikakui'),
    (Range:(RangeStart: $1EC70; RangeEnd: $1ECBF); Name: 'Indic Siyaq Numbers'),
    (Range:(RangeStart: $1ED00; RangeEnd: $1ED4F); Name: 'Ottoman Siyaq Numbers'),
    (Range:(RangeStart: $1E900; RangeEnd: $1E95F); Name: 'Adlam'),
    (Range:(RangeStart: $1EE00; RangeEnd: $1EEFF); Name: 'Arabic Mathematical Alphabetic Symbols'),
    (Range:(RangeStart: $1F000; RangeEnd: $1F02F); Name: 'Mahjong Tiles'),
    (Range:(RangeStart: $1F030; RangeEnd: $1F09F); Name: 'Domino Tiles'),
    (Range:(RangeStart: $1F0A0; RangeEnd: $1F0FF); Name: 'Playing Cards'),
    (Range:(RangeStart: $1F100; RangeEnd: $1F1FF); Name: 'Enclosed Alphanumeric Supplement'),
    (Range:(RangeStart: $1F200; RangeEnd: $1F2FF); Name: 'Enclosed Ideographic Supplement'),
    (Range:(RangeStart: $1F300; RangeEnd: $1F5FF); Name: 'Miscellaneous Symbols And Pictographs'),
    (Range:(RangeStart: $1F600; RangeEnd: $1F64F); Name: 'Emoticons'),
    (Range:(RangeStart: $1F650; RangeEnd: $1F67F); Name: 'Ornamental Dingbats'),
    (Range:(RangeStart: $1F680; RangeEnd: $1F6FF); Name: 'Transport And Map Symbols'),
    (Range:(RangeStart: $1F700; RangeEnd: $1F77F); Name: 'Alchemical Symbols'),
    (Range:(RangeStart: $1F780; RangeEnd: $1F7FF); Name: 'Geometric Shapes Extended'),
    (Range:(RangeStart: $1F800; RangeEnd: $1F8FF); Name: 'Supplemental Arrows-C'),
    (Range:(RangeStart: $1F900; RangeEnd: $1F9FF); Name: 'Supplemental Symbols And Pictographs'),
    (Range:(RangeStart: $1FA00; RangeEnd: $1FA6F); Name: 'Chess Symbols'),
    (Range:(RangeStart: $1FA70; RangeEnd: $1FAFF); Name: 'Symbols and Pictographs Extended-A'),
    (Range:(RangeStart: $1FB00; RangeEnd: $1FBFF); Name: 'Symbols for Legacy Computing'),
    (Range:(RangeStart: $20000; RangeEnd: $2A6DD); Name: 'CJK Unified Ideographs Extension B'),
    (Range:(RangeStart: $2A700; RangeEnd: $2B734); Name: 'CJK Unified Ideographs Extension C'),
    (Range:(RangeStart: $2B740; RangeEnd: $2B81D); Name: 'CJK Unified Ideographs Extension D'),
    (Range:(RangeStart: $2B820; RangeEnd: $2CEA1); Name: 'CJK Unified Ideographs Extension E'),
    (Range:(RangeStart: $2CEB0; RangeEnd: $2EBE0); Name: 'CJK Unified Ideographs Extension F'),
    (Range:(RangeStart: $2F800; RangeEnd: $2FA1F); Name: 'CJK Compatibility Ideographs Supplement'),
    (Range:(RangeStart: $30000; RangeEnd: $3134A); Name: 'CJK Unified Ideographs Extension G'),
    (Range:(RangeStart: $E0000; RangeEnd: $E007F); Name: 'Tags'),
    (Range:(RangeStart: $E0100; RangeEnd: $E01EF); Name: 'Variation Selectors Supplement'),
    (Range:(RangeStart: $F0000; RangeEnd: $FFFFF); Name: 'Supplementary Private Use Area-A'),
    (Range:(RangeStart: $100000; RangeEnd: $10FFFF); Name: 'Supplementary Private Use Area-B'));
{$IFNDEF UNICODE_RTL_DATABASE}
type
  TWideStrings = class;
  TSearchFlag = (
    sfCaseSensitive,    // match letter case
    sfIgnoreNonSpacing, // ignore non-spacing characters in search
    sfSpaceCompress,    // handle several consecutive white spaces as one white space
                        // (this applies to the pattern as well as the search text)
    sfWholeWordOnly     // match only text at end/start and/or surrounded by white spaces
  );
  TSearchFlags = set of TSearchFlag;
  // a generic search class defininition used for tuned Boyer-Moore and Unicode
  // regular expression searches
  TSearchEngine = class(TObject)
  private
    FResults: TList;      // 2 entries for each result (start and stop position)
    FOwner: TWideStrings; // at the moment unused, perhaps later to access strings faster
  protected
    function GetCount: SizeInt; virtual;
  public
    constructor Create(AOwner: TWideStrings); virtual;
    destructor Destroy; override;
    procedure AddResult(Start, Stop: SizeInt); virtual;
    procedure Clear; virtual;
    procedure ClearResults; virtual;
    procedure DeleteResult(Index: SizeInt); virtual;
    procedure FindPrepare(const Pattern: DWWideString; Options: TSearchFlags); overload; virtual; abstract;
    procedure FindPrepare(Pattern: PDWChar; PatternLength: SizeInt; Options: TSearchFlags); overload; virtual; abstract;
    function FindFirst(const Text: DWWideString; var Start, Stop: SizeInt): Boolean; overload; virtual; abstract;
    function FindFirst(Text: PDWChar; TextLen: SizeInt; var Start, Stop: SizeInt): Boolean; overload; virtual; abstract;
    function FindAll(const Text: DWWideString): Boolean; overload; virtual; abstract;
    function FindAll(Text: PDWChar; TextLen: SizeInt): Boolean; overload; virtual; abstract;
    procedure GetResult(Index: SizeInt; var Start, Stop: SizeInt); virtual;
    property Count: SizeInt read GetCount;
  end;
  // The Unicode Tuned Boyer-Moore (UTBM) search implementation is an extended
  // translation created from a free package written by Mark Leisher (mleisher att crl dott nmsu dott edu).
  //
  // The code handles high and low surrogates as well as case (in)dependency,
  // can ignore non-spacing characters and allows optionally to return whole
  // words only.
  // single pattern character
  PUTBMChar = ^TUTBMChar;
  TUTBMChar = record
    LoCase,
    UpCase,
    TitleCase: UCS4;
  end;
  PUTBMSkip = ^TUTBMSkip;
  TUTBMSkip = record
    BMChar: PUTBMChar;
    SkipValues: Integer;
  end;
  TUTBMSearch = class(TSearchEngine)
  private
    FFlags: TSearchFlags;
    FPattern: PUTBMChar;
    FPatternUsed: SizeInt;
    FPatternSize: SizeInt;
    FPatternLength: SizeInt;
    FSkipValues: PUTBMSkip;
    FSkipsUsed: SizeInt;
    FMD4: SizeInt;
  protected
    procedure ClearPattern;
  public
    procedure Clear; override;
    function FindAll(const Text: DWWideString): Boolean; overload; override;
  end;
  // Regular expression search engine for text in UCS2 form taking surrogates
  // into account. This implementation is an improved translation from the URE
  // package written by Mark Leisher (mleisher att crl dott nmsu dott edu) who used a variation
  // of the RE->DFA algorithm done by Mark Hopkins (markh att csd4 dott csd dott uwm dott edu).
  // Assumptions:
  //   o  Regular expression and text already normalized.
  //   o  Conversion to lower case assumes a 1-1 mapping.
  //
  // Definitions:
  //   Separator - any one of U+2028, U+2029, NL, CR.
  //
  // Operators:
  //   .      - match any character
  //   *      - match zero or more of the last subexpression
  //   +      - match one or more of the last subexpression
  //   ?      - match zero or one of the last subexpression
  //   ()     - subexpression grouping
  //   {m, n} - match at least m occurences and up to n occurences
  //            Note: both values can be 0 or ommitted which denotes then a unlimiting bound
  //            {,} and {0,} and {0, 0} correspond to *
  //            {, 1} and {0, 1} correspond to ?
  //            {1,} and {1, 0} correspond to +
  //   {m}    - match exactly m occurences
  //
  //   Notes:
  //     o  The "." operator normally does not match separators, but a flag is
  //        available that will allow this operator to match a separator.
  //
  // Literals and Constants:
  //   c       - literal UCS2 character
  //   \x....  - hexadecimal number of up to 4 digits
  //   \X....  - hexadecimal number of up to 4 digits
  //   \u....  - hexadecimal number of up to 4 digits
  //   \U....  - hexadecimal number of up to 4 digits
  //
  // Character classes:
  //   [...]           - Character class
  //   [^...]          - Negated character class
  //   \pN1,N2,...,Nn  - Character properties class
  //   \PN1,N2,...,Nn  - Negated character properties class
  //
  //   POSIX character classes recognized:
  //     :alnum:
  //     :alpha:
  //     :cntrl:
  //     :digit:
  //     :graph:
  //     :lower:
  //     :print:
  //     :punct:
  //     :space:
  //     :upper:
  //     :xdigit:
  //
  //   Notes:
  //     o  Character property classes are \p or \P followed by a comma separated
  //        list of integers between 0 and the maximum entry index in TCharacterCategory.
  //        These integers directly correspond to the TCharacterCategory enumeration entries.
  //        Note: upper, lower and title case classes need to have case sensitive search
  //              be enabled to match correctly!
  //
  //     o  Character classes can contain literals, constants and character
  //        property classes. Example:
  //
  //        [abc\U10A\p0,13,4]
  // structure used to handle a compacted range of characters
  PUcRange = ^TUcRange;
  TUcRange = record
    MinCode,
    MaxCode: UCS4;
  end;
  TUcCClass = record
    Ranges: array of TUcRange;
    RangesUsed: SizeInt;
  end;
  // either a single character or a list of character classes
  TUcSymbol = record
    Chr: UCS4;
    CCL: TUcCClass;
  end;
  // this is a general element structure used for expressions and stack elements
  TUcElement = record
    OnStack: Boolean;
    AType,
    LHS,
    RHS: SizeInt;
  end;
  // this is a structure used to track a list or a stack of states
  PUcStateList = ^TUcStateList;
  TUcStateList = record
    List: array of SizeInt;
    ListUsed: SizeInt;
  end;
  // structure to track the list of unique states for a symbol during reduction
  PUcSymbolTableEntry = ^TUcSymbolTableEntry;
  TUcSymbolTableEntry = record
    ID,
    AType: SizeInt;
    Mods,
    Categories: TCharacterCategories;
    Symbol: TUcSymbol;
    States: TUcStateList;
  end;
  // structure to hold a single State
  PUcState = ^TUcState;
  TUcState = record
    ID: SizeInt;
    Accepting: Boolean;
    StateList: TUcStateList;
    Transitions: array of TUcElement;
    TransitionsUsed: SizeInt;
  end;
  // structure used for keeping lists of states
  TUcStateTable = record
    States: array of TUcState;
    StatesUsed: SizeInt;
  end;
  // structure to track pairs of DFA states when equivalent states are merged
  TUcEquivalent = record
    Left,
    Right: SizeInt;
  end;
  TUcExpressionList = record
    Expressions: array of TUcElement;
    ExpressionsUsed: SizeInt;
  end;
  TUcSymbolTable = record
    Symbols: array of TUcSymbolTableEntry;
    SymbolsUsed: SizeInt;
  end;
  TUcEquivalentList = record
    Equivalents: array of TUcEquivalent;
    EquivalentsUsed: SizeInt;
  end;
  // structure used for constructing the NFA and reducing to a minimal DFA
  PUREBuffer = ^TUREBuffer;
  TUREBuffer = record
    Reducing: Boolean;
    Error: Integer;
    Flags: Cardinal;
    Stack: TUcStateList;
    SymbolTable: TUcSymbolTable;       // table of unique symbols encountered
    ExpressionList: TUcExpressionList; // tracks the unique expressions generated
                                       // for the NFA and when the NFA is reduced
    States: TUcStateTable;             // the reduced table of unique groups of NFA states
    EquivalentList: TUcEquivalentList; // tracks states when equivalent states are merged
  end;
  TUcTransition = record
    Symbol,
    NextState: SizeInt;
  end;
  PDFAState = ^TDFAState;
  TDFAState = record
    Accepting: Boolean;
    NumberTransitions: SizeInt;
    StartTransition: SizeInt;
  end;
  TDFAStates = record
    States: array of TDFAState;
    StatesUsed: SizeInt;
  end;
  TUcTransitions = record
    Transitions: array of TUcTransition;
    TransitionsUsed: SizeInt;
  end;
  TDFA = record
    Flags: Cardinal;
    SymbolTable: TUcSymbolTable;
    StateList: TDFAStates;
    TransitionList: TUcTransitions;
  end;
  TURESearch = class(TSearchEngine)
  private
    FUREBuffer: TUREBuffer;
    FDFA: TDFA;
  protected
    procedure AddEquivalentPair(L, R: SizeInt);
    procedure AddRange(var CCL: TUcCClass; Range: TUcRange);
    function AddState(NewStates: array of SizeInt): SizeInt;
    procedure AddSymbolState(Symbol, State: SizeInt);
    procedure CollectPendingOperations(var State: SizeInt);
    procedure HexDigitSetup(Symbol: PUcSymbolTableEntry);
    function MakeExpression(AType, LHS, RHS: SizeInt): SizeInt;
    procedure MergeEquivalents;
    function Peek: SizeInt;
    function Pop: SizeInt;
    procedure Push(V: SizeInt);
    procedure Reduce(Start: SizeInt);
    procedure SpaceSetup(Symbol: PUcSymbolTableEntry; Categories: TCharacterCategories);
    function SymbolsAreDifferent(A, B: PUcSymbolTableEntry): Boolean;
  public
    procedure Clear; override;
  end;
  // Event used to give the application a chance to switch the way of how to save
  // the text in TWideStrings if the text contains characters not only from the
  // ANSI block but the save type is ANSI. On triggering the event the application
  // can change the property SaveUnicode as needed. This property is again checked
  // after the callback returns.
  TConfirmConversionEvent = procedure (Sender: TWideStrings; var Allowed: Boolean) of object;
  TWideStrings = class(TPersistent)
  private
    FUpdateCount: Integer;
    FLanguage: LCID;        // language can usually left alone, the system's default is used
    FSaved: Boolean;        // set in SaveToStream, True in case saving was successfull otherwise False
    FNormalizationForm: TNormalizationForm; // determines in which form Unicode strings should be stored
    FOnConfirmConversion: TConfirmConversionEvent;
    FSaveFormat: TSaveFormat;  // overrides the FSaveUnicode flag, initialized when a file is loaded,
                               // expect losses if it is set to sfAnsi before saving
    function GetName(Index: Integer): DWWideString;
    procedure WriteData(Writer: TWriter);
    function GetSaveUnicode: Boolean;
    procedure SetSaveUnicode(const Value: Boolean);
  protected
    procedure DoConfirmConversion(var Allowed: Boolean); virtual;
    function Get(Index: Integer): DWWideString; virtual; abstract;
    function GetCapacity: Integer; virtual;
    function GetCount: Integer; virtual; abstract;
    function GetObject(Index: Integer): TObject; virtual;
    function GetTextStr: DWWideString; virtual;
    procedure Put(Index: Integer; const S: DWWideString); virtual; abstract;
    procedure PutObject(Index: Integer; AObject: TObject); virtual; abstract;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure SetLanguage(Value: LCID); virtual;
  public
    constructor Create;
    function Add(const S: DWWideString): Integer; virtual;
    function AddObject(const S: DWWideString; AObject: TObject): Integer; virtual;
    procedure Append(const S: DWWideString);
    procedure AddStrings(Strings: TStrings); overload; virtual;
    procedure AddStrings(Strings: TWideStrings); overload; virtual;
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure BeginUpdate;
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure EndUpdate;
    function Equals(Strings: TWideStrings): Boolean; {$IFDEF RTL200_UP} reintroduce; {$ENDIF RTL200_UP}
    procedure Exchange(Index1, Index2: Integer); virtual;
    function GetSeparatedText(Separators: DWWideString): DWWideString; virtual;
    function IndexOfObject(AObject: TObject): Integer;
    procedure Insert(Index: Integer; const S: DWWideString); virtual; abstract;
    procedure InsertObject(Index: Integer; const S: DWWideString; AObject: TObject);
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property Language: LCID read FLanguage write SetLanguage;
    property Names[Index: Integer]: DWWideString read GetName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property Saved: Boolean read FSaved;
    property SaveUnicode: Boolean read GetSaveUnicode write SetSaveUnicode default True;
    property SaveFormat: TSaveFormat read FSaveFormat write FSaveFormat default sfUnicodeLSB;
    property Strings[Index: Integer]: DWWideString read Get write Put; default;
    property OnConfirmConversion: TConfirmConversionEvent read FOnConfirmConversion write FOnConfirmConversion;
  end;
  //----- TWideStringList class
  TWideStringItem = record
    {$IFDEF OWN_WIDESTRING_MEMMGR}
    FString: PDWChar; // "array of DWChar";
    {$ELSE ~OWN_WIDESTRING_MEMMGR}
    FString: DWWideString;
    {$ENDIF ~OWN_WIDESTRING_MEMMGR}
    FObject: TObject;
  end;
  TWideStringItemList = array of TWideStringItem;
  TWideStringList = class(TWideStrings)
  private
    FList: TWideStringItemList;
    FCount: Integer;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure Grow;
    procedure QuickSort(L, R: Integer);
    procedure SetSorted(Value: Boolean);
    {$IFDEF OWN_WIDESTRING_MEMMGR}
    procedure SetListString(Index: Integer; const S: DWWideString);
    {$ENDIF OWN_WIDESTRING_MEMMGR}
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;
    function Get(Index: Integer): DWWideString; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetLanguage(Value: LCID); override;
  public
    destructor Destroy; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    procedure Sort; virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  end;
function WideDecompose(const S: DWWideString; Compatible: Boolean = True): DWWideString; overload;
function WideDecompose(const S: DWWideString; Tags: TCompatibilityFormattingTags): DWWideString; overload;
{$ENDIF ~UNICODE_RTL_DATABASE}
function DWWideStringOfChar(C: DWChar; Count: SizeInt): DWWideString;
// case conversion function
type
  TCaseType = (ctFold, ctLower, ctTitle, ctUpper);
function WideTrim(const S: DWWideString): DWWideString;
function WideTrimLeft(const S: DWWideString): DWWideString;
function WideTrimRight(const S: DWWideString): DWWideString;
type
  // result type for number retrieval functions
  TUcNumber = record
    Numerator,
    Denominator: Integer;
  end;
// Low level character routines
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeNumberLookup(Code: UCS4; var Number: TUcNumber): Boolean;
function UnicodeCompose(const Codes: array of UCS4; out Composite: UCS4; Compatible: Boolean = True): Integer; overload;
function UnicodeCompose(const Codes: array of UCS4; out Composite: UCS4; Tags: TCompatibilityFormattingTags): Integer; overload;
function UnicodeCaseFold(Code: UCS4): TUCS4Array;
function UnicodeDecompose(Code: UCS4; Compatible: Boolean = True): TUCS4Array; overload;
function UnicodeDecompose(Code: UCS4; Tags: TCompatibilityFormattingTags): TUCS4Array; overload;
function UnicodeToTitle(Code: UCS4): TUCS4Array;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeToUpper(Code: UCS4): TUCS4Array;
function UnicodeToLower(Code: UCS4): TUCS4Array;
// Character test routines
function UnicodeIsAlpha(C: UCS4): Boolean;
function UnicodeIsDigit(C: UCS4): Boolean;
function UnicodeIsAlphaNum(C: UCS4): Boolean;
function UnicodeIsNumberOther(C: UCS4): Boolean;
function UnicodeIsCased(C: UCS4): Boolean;
function UnicodeIsControl(C: UCS4): Boolean;
function UnicodeIsSpace(C: UCS4): Boolean;
function UnicodeIsWhiteSpace(C: UCS4): Boolean;
function UnicodeIsBlank(C: UCS4): Boolean;
function UnicodeIsPunctuation(C: UCS4): Boolean;
function UnicodeIsGraph(C: UCS4): Boolean;
function UnicodeIsPrintable(C: UCS4): Boolean;
function UnicodeIsUpper(C: UCS4): Boolean;
function UnicodeIsLower(C: UCS4): Boolean;
function UnicodeIsTitle(C: UCS4): Boolean;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsHexDigit(C: UCS4): Boolean;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeIsIsoControl(C: UCS4): Boolean;
function UnicodeIsFormatControl(C: UCS4): Boolean;
function UnicodeIsSymbol(C: UCS4): Boolean;
function UnicodeIsNumber(C: UCS4): Boolean;
function UnicodeIsNonSpacing(C: UCS4): Boolean;
function UnicodeIsOpenPunctuation(C: UCS4): Boolean;
function UnicodeIsClosePunctuation(C: UCS4): Boolean;
function UnicodeIsInitialPunctuation(C: UCS4): Boolean;
function UnicodeIsFinalPunctuation(C: UCS4): Boolean;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsComposed(C: UCS4): Boolean;
function UnicodeIsQuotationMark(C: UCS4): Boolean;
function UnicodeIsSymmetric(C: UCS4): Boolean;
function UnicodeIsMirroring(C: UCS4): Boolean;
function UnicodeIsNonBreaking(C: UCS4): Boolean;
// Directionality functions
function UnicodeIsRightToLeft(C: UCS4): Boolean;
function UnicodeIsLeftToRight(C: UCS4): Boolean;
function UnicodeIsStrong(C: UCS4): Boolean;
function UnicodeIsWeak(C: UCS4): Boolean;
function UnicodeIsNeutral(C: UCS4): Boolean;
function UnicodeIsSeparator(C: UCS4): Boolean;
// Other character test functions
function UnicodeIsMark(C: UCS4): Boolean;
function UnicodeIsModifier(C: UCS4): Boolean;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeIsLetterNumber(C: UCS4): Boolean;
function UnicodeIsConnectionPunctuation(C: UCS4): Boolean;
function UnicodeIsDash(C: UCS4): Boolean;
function UnicodeIsMath(C: UCS4): Boolean;
function UnicodeIsCurrency(C: UCS4): Boolean;
function UnicodeIsModifierSymbol(C: UCS4): Boolean;
function UnicodeIsSpacingMark(C: UCS4): Boolean;
function UnicodeIsEnclosing(C: UCS4): Boolean;
function UnicodeIsPrivate(C: UCS4): Boolean;
function UnicodeIsSurrogate(C: UCS4): Boolean;
function UnicodeIsLineSeparator(C: UCS4): Boolean;
function UnicodeIsParagraphSeparator(C: UCS4): Boolean;
function UnicodeIsIdentifierStart(C: UCS4): Boolean;
function UnicodeIsIdentifierPart(C: UCS4): Boolean;
function UnicodeIsDefined(C: UCS4): Boolean;
function UnicodeIsUndefined(C: UCS4): Boolean;
function UnicodeIsHan(C: UCS4): Boolean;
function UnicodeIsHangul(C: UCS4): Boolean;
function UnicodeIsUnassigned(C: UCS4): Boolean;
function UnicodeIsLetterOther(C: UCS4): Boolean;
function UnicodeIsConnector(C: UCS4): Boolean;
function UnicodeIsPunctuationOther(C: UCS4): Boolean;
function UnicodeIsSymbolOther(C: UCS4): Boolean;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsLeftToRightEmbedding(C: UCS4): Boolean;
function UnicodeIsLeftToRightOverride(C: UCS4): Boolean;
function UnicodeIsRightToLeftArabic(C: UCS4): Boolean;
function UnicodeIsRightToLeftEmbedding(C: UCS4): Boolean;
function UnicodeIsRightToLeftOverride(C: UCS4): Boolean;
function UnicodeIsPopDirectionalFormat(C: UCS4): Boolean;
function UnicodeIsEuropeanNumber(C: UCS4): Boolean;
function UnicodeIsEuropeanNumberSeparator(C: UCS4): Boolean;
function UnicodeIsEuropeanNumberTerminator(C: UCS4): Boolean;
function UnicodeIsArabicNumber(C: UCS4): Boolean;
function UnicodeIsCommonNumberSeparator(C: UCS4): Boolean;
function UnicodeIsBoundaryNeutral(C: UCS4): Boolean;
function UnicodeIsSegmentSeparator(C: UCS4): Boolean;
function UnicodeIsOtherNeutrals(C: UCS4): Boolean;
function UnicodeIsASCIIHexDigit(C: UCS4): Boolean;
function UnicodeIsBidiControl(C: UCS4): Boolean;
function UnicodeIsDeprecated(C: UCS4): Boolean;
function UnicodeIsDiacritic(C: UCS4): Boolean;
function UnicodeIsExtender(C: UCS4): Boolean;
function UnicodeIsHyphen(C: UCS4): Boolean;
function UnicodeIsIdeographic(C: UCS4): Boolean;
function UnicodeIsIDSBinaryOperator(C: UCS4): Boolean;
function UnicodeIsIDSTrinaryOperator(C: UCS4): Boolean;
function UnicodeIsJoinControl(C: UCS4): Boolean;
function UnicodeIsLogicalOrderException(C: UCS4): Boolean;
function UnicodeIsNonCharacterCodePoint(C: UCS4): Boolean;
function UnicodeIsOtherAlphabetic(C: UCS4): Boolean;
function UnicodeIsOtherDefaultIgnorableCodePoint(C: UCS4): Boolean;
function UnicodeIsOtherGraphemeExtend(C: UCS4): Boolean;
function UnicodeIsOtherIDContinue(C: UCS4): Boolean;
function UnicodeIsOtherIDStart(C: UCS4): Boolean;
function UnicodeIsOtherLowercase(C: UCS4): Boolean;
function UnicodeIsOtherMath(C: UCS4): Boolean;
function UnicodeIsOtherUppercase(C: UCS4): Boolean;
function UnicodeIsPatternSyntax(C: UCS4): Boolean;
function UnicodeIsPatternWhiteSpace(C: UCS4): Boolean;
function UnicodeIsRadical(C: UCS4): Boolean;
function UnicodeIsSoftDotted(C: UCS4): Boolean;
function UnicodeIsSTerm(C: UCS4): Boolean;
function UnicodeIsTerminalPunctuation(C: UCS4): Boolean;
function UnicodeIsUnifiedIdeograph(C: UCS4): Boolean;
function UnicodeIsVariationSelector(C: UCS4): Boolean;
{$ENDIF ~UNICODE_RTL_DATABASE}
// Utility functions
function CodeBlockName(const CB: TUnicodeBlock): string;
function CodeBlockRange(const CB: TUnicodeBlock): TUnicodeBlockRange;
function CodeBlockFromChar(const C: UCS4): TUnicodeBlock;
type
  TCompareFunc = function (const W1, W2: DWWideString; Locale: LCID): Integer;
var
  WideCompareText: TCompareFunc;
type
  EJclUnicodeError = class(EJclError);
// functions to load Unicode data from resource
procedure LoadCharacterCategories;
procedure LoadCaseMappingData;
procedure LoadDecompositionData;
procedure LoadCombiningClassData;
procedure LoadNumberData;
procedure LoadCompositionData;
// functions around TUCS4Array
function UCS4Array(Ch: UCS4): TUCS4Array;
function UCS4ArrayConcat(Left, Right: UCS4): TUCS4Array; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
procedure UCS4ArrayConcat(var Left: TUCS4Array; Right: UCS4); overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
procedure UCS4ArrayConcat(var Left: TUCS4Array; const Right: TUCS4Array); overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: TUCS4Array): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; Right: UCS4): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: DWString): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; Right: DWChar): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JCL\source\common';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}
implementation
// Unicode data for case mapping, decomposition, numbers etc. This data is
// loaded on demand which means only those parts will be put in memory which are
// needed by one of the lookup functions.
// Note: There is a little tool called UDExtract which creates a resouce script from
//       the Unicode database file which can be compiled to the needed res file.
//       This tool, including its source code, can be downloaded from www.lischke-online.de/Unicode.html.
{$IFNDEF UNICODE_RTL_DATABASE}
{$IFDEF UNICODE_RAW_DATA}
{$R JclUnicode.res}
{$ENDIF UNICODE_RAW_DATA}
{$IFDEF UNICODE_BZIP2_DATA}
{$R JclUnicodeBZip2.res}
{$ENDIF UNICODE_BZIP2_DATA}
{$IFDEF UNICODE_ZLIB_DATA}
{$R JclUnicodeZLib.res}
{$ENDIF UNICODE_ZLIB_DATA}
{$ENDIF ~UNICODE_RTL_DATABASE}
uses
  {$IFDEF HAS_UNIT_RTLCONSTS}
  {$IFDEF HAS_UNITSCOPE}
  System.RtlConsts,
  {$ELSE ~HAS_UNITSCOPE}
  RtlConsts,
  {$ENDIF ~HAS_UNITSCOPE}
  {$ENDIF HAS_UNIT_RTLCONSTS}
  {$IFNDEF UNICODE_RTL_DATABASE}
  {$IFDEF UNICODE_BZIP2_DATA}
  BZip2,
  {$ENDIF UNICODE_BZIP2_DATA}
  {$IFDEF UNICODE_ZLIB_DATA}
  ZLibh,
  {$ENDIF UNICODE_ZLIB_DATA}
  uRESTDWMemStreams,
  {$ENDIF ~UNICODE_RTL_DATABASE}
  uRESTDWMemResources, uRESTDWMemStringConversions, uRESTDWMemWideStrings;
const
  {$IFDEF FPC} // declarations from unit [Rtl]Consts
  SDuplicateString = 'String list does not allow duplicates';
  SListIndexError = 'List index out of bounds (%d)';
  SSortedListError = 'Operation not allowed on sorted string list';
  {$ENDIF FPC}
  // some predefined sets to shorten parameter lists below and ease repeative usage
  ClassLetter = [ccLetterUppercase, ccLetterLowercase, ccLetterTitlecase, ccLetterModifier, ccLetterOther];
  ClassSpace = [ccSeparatorSpace];
  ClassPunctuation = [ccPunctuationConnector, ccPunctuationDash, ccPunctuationOpen, ccPunctuationClose,
    ccPunctuationOther, ccPunctuationInitialQuote, ccPunctuationFinalQuote];
  ClassMark = [ccMarkNonSpacing, ccMarkSpacingCombining, ccMarkEnclosing];
  ClassNumber = [ccNumberDecimalDigit, ccNumberLetter, ccNumberOther];
  ClassSymbol = [ccSymbolMath, ccSymbolCurrency, ccSymbolModifier, ccSymbolOther];
  ClassEuropeanNumber = [ccEuropeanNumber, ccEuropeanNumberSeparator, ccEuropeanNumberTerminator];
  // used to negate a set of categories
  ClassAll = [Low(TCharacterCategory)..High(TCharacterCategory)];
{$IFDEF HAS_UNIT_CHARACTER}
function CharacterCategoriesToUnicodeCategory(const Categories: TCharacterCategories): TUnicodeCategory;
var
  Category: TCharacterUnicodeCategory;
begin
  for Category := Low(TCharacterUnicodeCategory) to High(TCharacterUnicodeCategory) do
    if Category in Categories then
  begin
    Result := CharacterCategoryToUnicodeCategory[Category];
    Exit;
  end;
  Result := TUnicodeCategory.ucUnassigned;
end;
function UnicodeCategoryToCharacterCategories(Category: TUnicodeCategory): TCharacterCategories;
begin
  Result := [];
  Include(Result, UnicodeCategoryToCharacterCategory[Category]);
end;
{$ENDIF HAS_UNIT_CHARACTER}
{$IFDEF UNICODE_RTL_DATABASE}
procedure LoadCharacterCategories;
begin
  // do nothing, the RTL database is already loaded
end;
procedure LoadCaseMappingData;
begin
  // do nothing, the RTL database is already loaded
end;
procedure LoadDecompositionData;
begin
  // do nothing, the RTL database is already loaded
end;
procedure LoadCombiningClassData;
begin
  // do nothing, the RTL database is already loaded
end;
procedure LoadNumberData;
begin
  // do nothing, the RTL database is already loaded
end;
procedure LoadCompositionData;
begin
  // do nothing, the RTL database is already loaded
end;
{$ELSE ~UNICODE_RTL_DATABASE}
function OpenResourceStream(const ResName: string): TJclEasyStream;
var
  ResourceStream: TStream;
  {$IFNDEF UNICODE_RAW_DATA}
  DecompressionStream: TStream;
  RawStream: TMemoryStream;
  {$ENDIF ~UNICODE_RAW_DATA}
begin
  ResourceStream := TResourceStream.Create(HInstance, ResName, 'UNICODEDATA');
  {$IFDEF UNICODE_RAW_DATA}
  Result := TJclEasyStream.Create(ResourceStream, True);
  {$ENDIF UNICODE_RAW_DATA}
  {$IFDEF UNICODE_BZIP2_DATA}
  try
    LoadBZip2;
    DecompressionStream := TJclBZIP2DecompressionStream.Create(ResourceStream);
    try
      RawStream := TMemoryStream.Create;
      StreamCopy(DecompressionStream, RawStream);
      RawStream.Seek(0, soBeginning);
      Result := TJclEasyStream.Create(RawStream, True);
    finally
      DecompressionStream.Free;
    end;
  finally
    ResourceStream.Free;
  end;
  {$ENDIF UNICODE_BZIP2_DATA}
  {$IFDEF UNICODE_ZLIB_DATA}
  try
    LoadZLib;
    DecompressionStream := TJclZLibDecompressStream.Create(ResourceStream);
    try
      RawStream := TMemoryStream.Create;
      StreamCopy(DecompressionStream, RawStream);
      RawStream.Seek(0, soBeginning);
      Result := TJclEasyStream.Create(RawStream, True);
    finally
      DecompressionStream.Free;
    end;
  finally
    ResourceStream.Free;
  end;
  {$ENDIF UNICODE_ZLIB_DATA}
end;
function StreamReadChar(Stream: TStream): Cardinal;
begin
  Result := 0;
  Stream.ReadBuffer(Result, 3);
end;
//----------------- support for character categories -----------------------------------------------
// Character category data is quite a large block since every defined character in Unicode is assigned at least
// one category. Because of this we cannot use a sparse matrix to provide quick access as implemented for
// e.g. composition data.
// The approach used here is based on the fact that an application seldomly uses all characters defined in Unicode
// simultanously. In fact the opposite is true. Most application will use either Western Europe or Arabic or
// Far East character data, but very rarely all together. Based on this fact is the implementation of virtual
// memory using the systems paging file (aka file mapping) to load only into virtual memory what is used currently.
// The implementation is not yet finished and needs a lot of improvements yet.
type
  // start and stop of a range of code points
  TRange = record
    Start,
    Stop: Cardinal;
  end;
  TRangeArray = array of TRange;
  TCategoriesArray = array of array of TCharacterCategories;
var
  // character categories, stored in the system's swap file and mapped on demand
  CategoriesLoaded: Boolean;
  Categories: array [Byte] of TCategoriesArray;
procedure LoadCharacterCategories;
// Loads the character categories data (as saved by the Unicode database extractor, see also
// the comments about JclUnicode.res above).
var
  Size: Integer;
  Stream: TJclEasyStream;
  Category: TCharacterCategory;
  Buffer: TRangeArray;
  First, Second, Third: Byte;
  J, K: Integer;
begin
  // make sure no other code is currently modifying the global data area
//  LoadInProgress.Enter;
  try
    // Data already loaded?
    if not CategoriesLoaded then
    begin
      Stream := OpenResourceStream('CATEGORIES');
      try
        while Stream.Position < Stream.Size do
        begin
          // a) read which category is current in the stream
          Category := TCharacterCategory(Stream.ReadByte);
          // b) read the size of the ranges and the ranges themself
          Size := Stream.ReadInteger;
          if Size > 0 then
          begin
            SetLength(Buffer, Size);
            for J := 0 to Size - 1 do
            begin
              Buffer[J].Start := StreamReadChar(Stream);
              Buffer[J].Stop := StreamReadChar(Stream);
            end;
            // c) go through every range and add the current category to each code point
            for J := 0 to Size - 1 do
              for K := Buffer[J].Start to Buffer[J].Stop do
              begin
                Assert(K < $1000000, LoadResString(@RsCategoryUnicodeChar));
                First := (K shr 16) and $FF;
                Second := (K shr 8) and $FF;
                Third := K and $FF;
                // add second step array if not yet done
                if Categories[First] = nil then
                  SetLength(Categories[First], 256);
                if Categories[First, Second] = nil then
                  SetLength(Categories[First, Second], 256);
                // The array is allocated on the exact size, but the compiler generates
                // a 32 bit "BTS" instruction that accesses memory beyond the allocated block.
                if Third < 255 then
                  Include(Categories[First, Second, Third], Category)
                else
                  Categories[First, Second, Third] := Categories[First, Second, Third] + [Category];
              end;
          end;
        end;
        // Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        CategoriesLoaded := True;
      end;
    end;
  finally
//    LoadInProgress.Leave;
  end;
end;
function CategoryLookup(Code: Cardinal; Cats: TCharacterCategories): Boolean; overload;
// determines whether the Code is in the given category
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000, LoadResString(@RsCategoryUnicodeChar));
  // load property data if not already done
  if not CategoriesLoaded then
    LoadCharacterCategories;
  First := (Code shr 16) and $FF;
  Second := (Code shr 8) and $FF;
  Third := Code and $FF;
  if (Categories[First] <> nil) and (Categories[First, Second] <> nil) then
    Result := Categories[First, Second, Third] * Cats <> []
  else
    Result := False;
end;
//----------------- support for case mapping -------------------------------------------------------
type
  TCase = array [TCaseType] of TUCS4Array; // mapping for case fold, lower, title and upper in this order
  TCaseArray = array of array of TCase;
var
  // An array for all case mappings (including 1 to many casing if saved by the extraction program).
  // The organization is a sparse, two stage matrix.
  // SingletonMapping is to quickly return a single default mapping.
  CaseDataLoaded: Boolean;
  CaseMapping: array [Byte] of TCaseArray;
procedure LoadCaseMappingData;
var
  Stream: TJclEasyStream;
  I, J, Code, Size: Integer;
  First, Second, Third: Byte;
begin
  // make sure no other code is currently modifying the global data area
//  LoadInProgress.Enter;
  try
    if not CaseDataLoaded then
    begin
      Stream := OpenResourceStream('CASE');
      try
        // the first entry in the stream is the number of entries in the case mapping table
        Size := Stream.ReadInteger;
        for I := 0 to Size - 1 do
        begin
          // a) read actual code point
          Code := StreamReadChar(Stream);
          Assert(Code < $1000000, LoadResString(@RsCasedUnicodeChar));
          // if there is no high byte entry in the first stage table then create one
          First := (Code shr 16) and $FF;
          Second := (Code shr 8) and $FF;
          Third := Code and $FF;
          if CaseMapping[First] = nil then
            SetLength(CaseMapping[First], 256);
          if CaseMapping[First, Second] = nil then
            SetLength(CaseMapping[First, Second], 256);
          // b) read fold case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctFold], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctFold, J] := StreamReadChar(Stream);
          end;
          // c) read lower case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctLower], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctLower, J] := StreamReadChar(Stream);
          end;
          // d) read title case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctTitle], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctTitle, J] := StreamReadChar(Stream);
          end;
          // e) read upper case array
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            SetLength(CaseMapping[First, Second, Third, ctUpper], Size);
            for J := 0 to Size - 1 do
              CaseMapping[First, Second, Third, ctUpper, J] := StreamReadChar(Stream);
          end;
        end;
        Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        CaseDataLoaded := True;
      end;
    end;
  finally
//    LoadInProgress.Leave;
  end;
end;
function CaseLookup(Code: Cardinal; CaseType: TCaseType; var Mapping: TUCS4Array): Boolean;
// Performs a lookup of the given code; returns True if Found, with Mapping referring to the mapping.
// ctFold is handled specially: if no mapping is found then result of looking up ctLower
//   is returned
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000, LoadResString(@RsCasedUnicodeChar));
  // load case mapping data if not already done
  if not CaseDataLoaded then
    LoadCaseMappingData;
  First := (Code shr 16) and $FF;
  Second := (Code shr 8) and $FF;
  Third := Code and $FF;
  // Check first stage table whether there is a mapping for a particular block and
  // (if so) then whether there is a mapping or not.
  if (CaseMapping[First] <> nil) and (CaseMapping[First, Second] <> nil) and
     (CaseMapping[First, Second, Third, CaseType] <> nil) then
    Mapping := CaseMapping[First, Second, Third, CaseType]
  else
    Mapping := nil;
  Result := Assigned(Mapping);
  // defer to lower case if no fold case exists
  if not Result and (CaseType = ctFold) and (CaseMapping[First] <> nil) and
    (CaseMapping[First, Second] <> nil) and (CaseMapping[First, Second, Third, ctLower] <> nil) then
  begin
    Mapping := CaseMapping[First, Second, Third, ctLower];
    Result := Assigned(Mapping);
  end;
end;
function UnicodeCaseFold(Code: UCS4): TUCS4Array;
// This function returnes an array of special case fold mappings if there is one defined for the given
// code, otherwise the lower case will be returned. This all applies only to cased code points.
// Uncased code points are returned unchanged.
begin
  SetLength(Result, 0);
  if not CaseLookup(Code, ctFold, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
end;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeToUpper(Code: UCS4): TUCS4Array;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  SetLength(Result, 1);
  Result[0] := Ord(TCharacter.ToUpper(Chr(Code)));
  {$ELSE ~UNICODE_RTL_DATABASE}
  SetLength(Result, 0);
  if not CaseLookup(Code, ctUpper, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeToLower(Code: UCS4): TUCS4Array;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  SetLength(Result, 1);
  Result[0] := Ord(TCharacter.ToLower(Chr(Code)));
  {$ELSE ~UNICODE_RTL_DATABASE}
  SetLength(Result, 0);
  if not CaseLookup(Code, ctLower, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeToTitle(Code: UCS4): TUCS4Array;
begin
  SetLength(Result, 0);
  if not CaseLookup(Code, ctTitle, Result) then
  begin
    SetLength(Result, 1);
    Result[0] := Code;
  end;
end;
//----------------- support for decomposition ------------------------------------------------------
const
  // constants for hangul composition and hangul-to-jamo decomposition
  SBase = $AC00;             // hangul syllables start code point
  LBase = $1100;             // leading syllable
  VBase = $1161;
  TBase = $11A7;             // trailing syllable
  LCount = 19;
  VCount = 21;
  TCount = 28;
  NCount = VCount * TCount;   // 588
  SCount = LCount * NCount;   // 11172
type
  TDecomposition = record
    Tag: TCompatibilityFormattingTag;
    Leaves: TUCS4Array;
  end;
  TDecompositions = array of array of TDecomposition;
  TDecompositionsArray = array [Byte] of TDecompositions;
var
  // list of decompositions, organized (again) as three stage matrix
  // Note: there are two tables, one for canonical decompositions and the other one
  //       for compatibility decompositions.
  DecompositionsLoaded: Boolean;
  Decompositions: TDecompositionsArray;
procedure LoadDecompositionData;
var
  Stream: TJclEasyStream;
  I, J, Code, Size: Integer;
  First, Second, Third: Byte;
begin
  // make sure no other code is currently modifying the global data area
//  LoadInProgress.Enter;
  try
    if not DecompositionsLoaded then
    begin
      Stream := OpenResourceStream('DECOMPOSITION');
      try
        // determine how many decomposition entries we have
        Size := Stream.ReadInteger;
        for I := 0 to Size - 1 do
        begin
          Code := StreamReadChar(Stream);
          Assert(Code < $1000000, LoadResString(@RsDecomposedUnicodeChar));
          First := (Code shr 16) and $FF;
          Second := (Code shr 8) and $FF;
          Third := Code and $FF;
          // if there is no high byte entry in the first stage table then create one
          if Decompositions[First] = nil then
            SetLength(Decompositions[First], 256);
          if Decompositions[First, Second] = nil then
            SetLength(Decompositions[First, Second], 256);
          Size := Stream.ReadByte;
          if Size > 0 then
          begin
            Decompositions[First, Second, Third].Tag := TCompatibilityFormattingTag(Stream.ReadByte);
            SetLength(Decompositions[First, Second, Third].Leaves, Size);
            for J := 0 to Size - 1 do
              Decompositions[First, Second, Third].Leaves[J] := StreamReadChar(Stream);
          end;
        end;
        Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        DecompositionsLoaded := True;
      end;
    end;
  finally
//    LoadInProgress.Leave;
  end;
end;
function UnicodeDecomposeHangul(Code: UCS4): TUCS4Array;
// algorithmically decomposes hangul character
var
  Rest: Integer;
begin
  Dec(Code, SBase);
  Rest := Code mod TCount;
  if Rest = 0 then
    SetLength(Result, 2)
  else
    SetLength(Result, 3);
  Result[0] := LBase + (Code div NCount);
  Result[1] := VBase + ((Code mod NCount) div TCount);
  if Rest <> 0 then
    Result[2] := TBase + Rest;
end;
function UnicodeDecompose(Code: UCS4; Compatible: Boolean): TUCS4Array;
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000, LoadResString(@RsDecomposedUnicodeChar));
  // load decomposition data if not already done
  if not DecompositionsLoaded then
    LoadDecompositionData;
  Result := nil;
  // if the code is hangul then decomposition is algorithmically
  if UnicodeIsHangul(Code) then
    Result := UnicodeDecomposeHangul(Code)
  else
  begin
    First := (Code shr 16) and $FF;
    Second := (Code shr 8) and $FF;
    Third := Code and $FF;
    if (Decompositions[First] <> nil) and (Decompositions[First, Second] <> nil)
      and (Decompositions[First, Second, Third].Leaves <> nil)
      and (Compatible or (Decompositions[First, Second, Third].Tag = cftCanonical)) then
      Result := Decompositions[First, Second, Third].Leaves
    else
      Result := nil;
  end;
end;
function UnicodeDecompose(Code: UCS4; Tags: TCompatibilityFormattingTags): TUCS4Array;
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000, LoadResString(@RsDecomposedUnicodeChar));
  // load decomposition data if not already done
  if not DecompositionsLoaded then
    LoadDecompositionData;
  Result := nil;
  // if the code is hangul then decomposition is algorithmically
  if UnicodeIsHangul(Code) then
    Result := UnicodeDecomposeHangul(Code)
  else
  begin
    First := (Code shr 16) and $FF;
    Second := (Code shr 8) and $FF;
    Third := Code and $FF;
    if (Decompositions[First] <> nil) and (Decompositions[First, Second] <> nil)
      and (Decompositions[First, Second, Third].Leaves <> nil)
      and (Decompositions[First, Second, Third].Tag in Tags) then
      Result := Decompositions[First, Second, Third].Leaves
    else
      Result := nil;
  end;
end;
//----------------- support for combining classes --------------------------------------------------
type
  TClassArray = array of array of Byte;
var
  // canonical combining classes, again as two stage matrix
  CCCsLoaded: Boolean;
  CCCs: array [Byte] of TClassArray;
procedure LoadCombiningClassData;
var
  Stream: TJclEasyStream;
  I, J, K, Size: Integer;
  Buffer: TRangeArray;
  First, Second, Third: Byte;
begin
  // make sure no other code is currently modifying the global data area
//  LoadInProgress.Enter;
  try
    if not CCCsLoaded then
    begin
      Stream := OpenResourceStream('COMBINING');
      try
        while Stream.Position < Stream.Size do
        begin
          // a) determine which class is stored here
          I := Stream.ReadByte;
          // b) determine how many ranges are assigned to this class
          Size := Stream.ReadByte;
          // c) read start and stop code of each range
          if Size > 0 then
          begin
            SetLength(Buffer, Size);
            for J := 0 to Size - 1 do
            begin
              Buffer[J].Start := StreamReadChar(Stream);
              Buffer[J].Stop := StreamReadChar(Stream);
            end;
            // d) put this class in every of the code points just loaded
            for J := 0 to Size - 1 do
              for K := Buffer[J].Start to Buffer[J].Stop do
              begin
                // (outchy) TODO: handle in a cleaner way
                Assert(K < $1000000, LoadResString(@RsCombiningClassUnicodeChar));
                First := (K shr 16) and $FF;
                Second := (K shr 8) and $FF;
                Third := K and $FF;
                // add second step array if not yet done
                if CCCs[First] = nil then
                  SetLength(CCCs[First], 256);
                if CCCs[First, Second] = nil then
                  SetLength(CCCs[First, Second], 256);
                CCCs[First, Second, Third] := I;
              end;
          end;
        end;
        // Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        CCCsLoaded := True;
      end;
    end;
  finally
//    LoadInProgress.Leave;
  end;
end;
function CanonicalCombiningClass(Code: Cardinal): Cardinal;
var
  First, Second, Third: Byte;
begin
  Assert(Code < $1000000, LoadResString(@RsCombiningClassUnicodeChar));
  // load combining class data if not already done
  if not CCCsLoaded then
    LoadCombiningClassData;
  First := (Code shr 16) and $FF;
  Second := (Code shr 8) and $FF;
  Third := Code and $FF;
  if (CCCs[First] <> nil) and (CCCs[First, Second] <> nil) then
    Result := CCCs[First, Second, Third]
  else
    Result := 0;
end;
//----------------- support for numeric values -----------------------------------------------------
type
  // structures for handling numbers
  TCodeIndex = record
    Code,
    Index: Cardinal;
  end;
var
  // array to hold the number equivalents for specific codes
  NumberCodesLoaded: Boolean;
  NumberCodes: array of TCodeIndex;
  // array of numbers used in NumberCodes
  Numbers: array of TUcNumber;
procedure LoadNumberData;
var
  Stream: TJclEasyStream;
  Size, I: Integer;
begin
  // make sure no other code is currently modifying the global data area
//  LoadInProgress.Enter;
  try
    if not NumberCodesLoaded then
    begin
      Stream := OpenResourceStream('NUMBERS');
      try
        // Numbers are special (compared to other Unicode data) as they utilize two
        // arrays, one containing all used numbers (in nominator-denominator format) and
        // another one which maps a code point to one of the numbers in the first array.
        // a) determine size of numbers array
        Size := Stream.ReadByte;
        SetLength(Numbers, Size);
        // b) read numbers data
        for I := 0 to Size - 1 do
        begin
          Numbers[I].Numerator := Stream.ReadInteger;
          Numbers[I].Denominator := Stream.ReadInteger;
        end;
        // c) determine size of index array
        Size := Stream.ReadInteger;
        SetLength(NumberCodes, Size);
        // d) read index data
        for I := 0 to Size - 1 do
        begin
          NumberCodes[I].Code := StreamReadChar(Stream);
          NumberCodes[I].Index := Stream.ReadByte;
        end;
        Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        NumberCodesLoaded := True;
      end;
    end;
  finally
//    LoadInProgress.Leave;
  end;
end;
function UnicodeNumberLookup(Code: UCS4; var Number: TUcNumber): Boolean;
// Searches for the given code and returns its number equivalent (if there is one).
// Typical cases are: '1/6' (U+2159), '3/8' (U+215C), 'XII' (U+216B) etc.
// Result is set to True if the code could be found.
var
  L, R, M: Integer;
begin
  // load number data if not already done
  if not NumberCodesLoaded then
    LoadNumberData;
  Result := False;
  L := 0;
  R := High(NumberCodes);
  while L <= R do
  begin
    M := (L + R) shr 1;
    if Code > NumberCodes[M].Code then
      L := M + 1
    else
    begin
      if Code < NumberCodes[M].Code then
        R := M - 1
      else
      begin
        Number := Numbers[NumberCodes[M].Index];
        Result := True;
        Break;
      end;
    end;
  end;
end;
//----------------- support for composition --------------------------------------------------------
type
  // maps between a pair of code points to a composite code point
  // Note: the source pair is packed into one 4 byte value to speed up search.
  TComposition = record
    Code: Cardinal;
    Tag: TCompatibilityFormattingTag;
    First: Cardinal;
    Next: array of Cardinal;
  end;
var
  // list of composition mappings
  CompositionsLoaded: Boolean;
  Compositions: array of TComposition;
  MaxCompositionSize: Integer;
procedure LoadCompositionData;
var
  Stream: TJclEasyStream;
  I, J, Size: Integer;
begin
  // make sure no other code is currently modifying the global data area
//  LoadInProgress.Enter;
  try
    if not CompositionsLoaded then
    begin
      Stream := OpenResourceStream('COMPOSITION');
      try
        // a) determine size of compositions array
        Size := Stream.ReadInteger;
        SetLength(Compositions, Size);
        // b) read data
        for I := 0 to Size - 1 do
        begin
          Compositions[I].Code := StreamReadChar(Stream);
          Size := Stream.ReadByte;
          if Size > MaxCompositionSize then
            MaxCompositionSize := Size;
          SetLength(Compositions[I].Next, Size - 1);
          Compositions[I].Tag := TCompatibilityFormattingTag(Stream.ReadByte);
          Compositions[I].First := StreamReadChar(Stream);
          for J := 0 to Size - 2 do
            Compositions[I].Next[J] := StreamReadChar(Stream);
        end;
        Assert(Stream.Position = Stream.Size);
      finally
        Stream.Free;
        CompositionsLoaded := True;
      end;
    end;
  finally
//    LoadInProgress.Leave;
  end;
end;
function UnicodeCompose(const Codes: array of UCS4; out Composite: UCS4; Compatible: Boolean): Integer;
// Maps the sequence of Codes (up to MaxCompositionSize codes) to a composite
// Result is the number of Codes that were composed (at least 1 if Codes is not empty)
var
  L, R, M, I, HighCodes, HighNext: Integer;
begin
  if not CompositionsLoaded then
    LoadCompositionData;
  Result := 0;
  HighCodes := High(Codes);
  if HighCodes = -1 then
    Exit;
  if HighCodes = 0 then
  begin
    Result := 1;
    Composite := Codes[0];
    Exit;
  end;
  L := 0;
  R := High(Compositions);
  while L <= R do
  begin
    M := (L + R) shr 1;
    if Compositions[M].First > Codes[0] then
      R := M - 1
    else
    if Compositions[M].First < Codes[0] then
      L := M + 1
    else
    begin
      // back to the first element where Codes[0] = First
      while (M > 0) and (Compositions[M-1].First = Codes[0]) do
        Dec(M);
      while (M <= High(Compositions)) and (Compositions[M].First = Codes[0]) do
      begin
        HighNext := High(Compositions[M].Next);
        Result := 0;
        if (HighNext < HighCodes) // enough characters in buffer to be tested
          and (Compatible or (Compositions[M].Tag = cftCanonical)) then
        begin
          for I := 0 to HighNext do
            if Compositions[M].Next[I] = Codes[I + 1] then
              Result := I + 2 { +1 for first, +1 because of 0-based array }
            else
              Break;
          if Result = HighNext + 2 then // all codes matched
          begin
            Composite := Compositions[M].Code;
            Exit;
          end;
        end;
        Inc(M);
      end;
      Break;
    end;
  end;
  Result := 1;
  Composite := Codes[0];
end;
function UnicodeCompose(const Codes: array of UCS4; out Composite: UCS4; Tags: TCompatibilityFormattingTags): Integer;
// Maps the sequence of Codes (up to MaxCompositionSize codes) to a composite
// Result is the number of Codes that were composed (at least 1 if Codes is not empty)
var
  L, R, M, I, HighCodes, HighNext: Integer;
begin
  if not CompositionsLoaded then
    LoadCompositionData;
  Result := 0;
  HighCodes := High(Codes);
  if HighCodes = -1 then
    Exit;
  if HighCodes = 0 then
  begin
    Result := 1;
    Composite := Codes[0];
    Exit;
  end;
  L := 0;
  R := High(Compositions);
  while L <= R do
  begin
    M := (L + R) shr 1;
    if Compositions[M].First > Codes[0] then
      R := M - 1
    else
    if Compositions[M].First < Codes[0] then
      L := M + 1
    else
    begin
      // back to the first element where Codes[0] = First
      while (M > 0) and (Compositions[M-1].First = Codes[0]) do
        Dec(M);
      while (M <= High(Compositions)) and (Compositions[M].First = Codes[0]) do
      begin
        HighNext := High(Compositions[M].Next);
        Result := 0;
        if (HighNext < HighCodes) // enough characters in buffer to be tested
          and (Compositions[M].Tag in Tags) then
        begin
          for I := 0 to HighNext do
            if Compositions[M].Next[I] = Codes[I + 1] then
              Result := I + 2 { +1 for first, +1 because of 0-based array }
            else
              Break;
          if Result = HighNext + 2 then // all codes matched
          begin
            Composite := Compositions[M].Code;
            Exit;
          end;
        end;
        Inc(M);
      end;
      Break;
    end;
  end;
  Result := 1;
  Composite := Codes[0];
end;
//=== { TSearchEngine } ======================================================
constructor TSearchEngine.Create(AOwner: TWideStrings);
begin
  inherited Create;
  FOwner := AOwner;
  FResults := TList.Create;
end;
destructor TSearchEngine.Destroy;
begin
  Clear;
  FResults.Free;
  inherited Destroy;
end;
procedure TSearchEngine.AddResult(Start, Stop: SizeInt);
begin
  FResults.Add(Pointer(Start));
  FResults.Add(Pointer(Stop));
end;
procedure TSearchEngine.Clear;
begin
  ClearResults;
end;
procedure TSearchEngine.ClearResults;
begin
  FResults.Clear;
end;
procedure TSearchEngine.DeleteResult(Index: SizeInt);
// explicitly deletes a search result
begin
  with FResults do
  begin
    // start index
    Delete(2 * Index);
    // stop index
    Delete(2 * Index);
  end;
end;
function TSearchEngine.GetCount: SizeInt;
// returns the number of matches found
begin
  Result := FResults.Count div 2;
end;
procedure TSearchEngine.GetResult(Index: SizeInt; var Start, Stop: SizeInt);
// returns the start position of a match (end position can be determined by
// adding the length of the pattern to the start position)
begin
  Start := SizeInt(FResults[2 * Index]);
  Stop := SizeInt(FResults[2 * Index + 1]);
end;
//----------------- TUTBSearch ---------------------------------------------------------------------
procedure TUTBMSearch.ClearPattern;
begin
  FreeMem(FPattern);
  FPattern := nil;
  FFlags := [];
  FPatternUsed := 0;
  FPatternSize := 0;
  FPatternLength := 0;
  FreeMem(FSkipValues);
  FSkipValues := nil;
  FSkipsUsed := 0;
  FMD4 := 0;
end;
procedure TUTBMSearch.Clear;
begin
  ClearPattern;
  inherited Clear;
end;
function TUTBMSearch.FindAll(const Text: DWWideString): Boolean;
begin
  Result := FindAll(PDWChar(Text), Length(Text));
end;
//----------------- Unicode RE search core ---------------------------------------------------------
const
  // error codes
  _URE_OK = 0;
  _URE_UNEXPECTED_EOS = -1;
  _URE_CCLASS_OPEN = -2;
  _URE_UNBALANCED_GROUP = -3;
  _URE_INVALID_PROPERTY = -4;
  _URE_INVALID_RANGE = -5;
  _URE_RANGE_OPEN = -6;
  // options that can be combined for searching
  URE_IGNORE_NONSPACING = $01;
  URE_DONT_MATCHES_SEPARATORS = $02;
const
  // Flags used internally in the DFA
  _URE_DFA_CASEFOLD = $01;
  _URE_DFA_BLANKLINE = $02;
  // symbol types for the DFA
  _URE_ANY_CHAR = 1;
  _URE_CHAR = 2;
  _URE_CCLASS = 3;
  _URE_NCCLASS = 4;
  _URE_BOL_ANCHOR = 5;
  _URE_EOL_ANCHOR = 6;
  // op codes for converting the NFA to a DFA
  _URE_SYMBOL = 10;
  _URE_PAREN = 11;
  _URE_QUEST = 12;
  _URE_STAR = 13;
  _URE_PLUS = 14;
  _URE_ONE = 15;
  _URE_AND = 16;
  _URE_OR = 17;
  _URE_NOOP = $FFFF;
//----------------- TURESearch ---------------------------------------------------------------------
procedure TURESearch.Clear;
begin
  inherited Clear;
end;
procedure TURESearch.Push(V: SizeInt);
begin
  with FUREBuffer do
  begin
    // If the 'Reducing' parameter is True, check to see if the value passed is
    // already on the stack.
    if Reducing and ExpressionList.Expressions[Word(V)].OnStack then
      Exit;
    if Stack.ListUsed = Length(Stack.List) then
      SetLength(Stack.List, Length(Stack.List) + 8);
    Stack.List[Stack.ListUsed] := V;
    Inc(Stack.ListUsed);
    // If the 'reducing' parameter is True, flag the element as being on the Stack.
    if Reducing then
      ExpressionList.Expressions[Word(V)].OnStack := True;
  end;
end;
function TURESearch.Peek: SizeInt;
begin
  if FUREBuffer.Stack.ListUsed = 0 then
    Result := _URE_NOOP
  else
    Result := FUREBuffer.Stack.List[FUREBuffer.Stack.ListUsed - 1];
end;
function TURESearch.Pop: SizeInt;
begin
  if FUREBuffer.Stack.ListUsed = 0 then
    Result := _URE_NOOP
  else
  begin
    Dec(FUREBuffer.Stack.ListUsed);
    Result := FUREBuffer.Stack.List[FUREBuffer.Stack.ListUsed];
    if FUREBuffer.Reducing then
      FUREBuffer.ExpressionList.Expressions[Word(Result)].OnStack := False;
  end;
end;
procedure TURESearch.AddRange(var CCL: TUcCClass; Range: TUcRange);
// Insert a Range into a character class, removing duplicates and ordering them
// in increasing Range-start order.
var
  I: SizeInt;
  Temp: UCS4;
begin
  // If the `Casefold' flag is set, then make sure both endpoints of the Range
  // are converted to lower.
  if (FUREBuffer.Flags and _URE_DFA_CASEFOLD) <> 0 then
  begin
    { TODO : use the entire mapping, not only the first character }
    Range.MinCode := UnicodeToLower(Range.MinCode)[0];
    Range.MaxCode := UnicodeToLower(Range.MaxCode)[0];
  end;
  // Swap the Range endpoints if they are not in increasing order.
  if Range.MinCode > Range.MaxCode then
  begin
    Temp := Range.MinCode;
    Range.MinCode := Range.MaxCode;
    Range.MaxCode := Temp;
  end;
  I := 0;
  while (I < CCL.RangesUsed) and (Range.MinCode < CCL.Ranges[I].MinCode) do
    Inc(I);
  // check for a duplicate
  if (I < CCL.RangesUsed) and (Range.MinCode = CCL.Ranges[I].MinCode) and
    (Range.MaxCode = CCL.Ranges[I].MaxCode) then
    Exit;
  if CCL.RangesUsed = Length(CCL.Ranges) then
    SetLength(CCL.Ranges, Length(CCL.Ranges) + 8);
  if I < CCL.RangesUsed then
    Move(CCL.Ranges[I], CCL.Ranges[I + 1], SizeOf(TUcRange) * (CCL.RangesUsed - I));
  CCL.Ranges[I].MinCode := Range.MinCode;
  CCL.Ranges[I].MaxCode := Range.MaxCode;
  Inc(CCL.RangesUsed);
end;
type
  PTrie = ^TTrie;
  TTrie = record
    Key: UCS2;
    Len,
    Next: SizeInt;
    Setup: SizeInt;
    Categories: TCharacterCategories;
  end;
procedure TURESearch.SpaceSetup(Symbol: PUcSymbolTableEntry; Categories: TCharacterCategories);
var
  Range: TUcRange;
begin
  Symbol.Categories := Symbol.Categories + Categories;
  Range.MinCode := UCS4(WideTabulator);
  Range.MaxCode := UCS4(WideTabulator);
  AddRange(Symbol.Symbol.CCL, Range);
  Range.MinCode := UCS4(WideCarriageReturn);
  Range.MaxCode := UCS4(WideCarriageReturn);
  AddRange(Symbol.Symbol.CCL, Range);
  Range.MinCode := UCS4(WideLineFeed);
  Range.MaxCode := UCS4(WideLineFeed);
  AddRange(Symbol.Symbol.CCL, Range);
  Range.MinCode := UCS4(WideFormFeed);
  Range.MaxCode := UCS4(WideFormFeed);
  AddRange(Symbol.Symbol.CCL, Range);
  Range.MinCode := $FEFF;
  Range.MaxCode := $FEFF;
  AddRange(Symbol.Symbol.CCL, Range);
end;
procedure TURESearch.HexDigitSetup(Symbol: PUcSymbolTableEntry);
var
  Range: TUcRange;
begin
  Range.MinCode := UCS4('0');
  Range.MaxCode := UCS4('9');
  AddRange(Symbol.Symbol.CCL, Range);
  Range.MinCode := UCS4('A');
  Range.MaxCode := UCS4('F');
  AddRange(Symbol.Symbol.CCL, Range);
  Range.MinCode := UCS4('a');
  Range.MaxCode := UCS4('f');
  AddRange(Symbol.Symbol.CCL, Range);
end;
const
  CClassTrie: array [0..64] of TTrie = (
    (Key: #$003A; Len: 1; Next:  1; Setup: 0; Categories: []),
    (Key: #$0061; Len: 9; Next: 10; Setup: 0; Categories: []),
    (Key: #$0063; Len: 8; Next: 19; Setup: 0; Categories: []),
    (Key: #$0064; Len: 7; Next: 24; Setup: 0; Categories: []),
    (Key: #$0067; Len: 6; Next: 29; Setup: 0; Categories: []),
    (Key: #$006C; Len: 5; Next: 34; Setup: 0; Categories: []),
    (Key: #$0070; Len: 4; Next: 39; Setup: 0; Categories: []),
    (Key: #$0073; Len: 3; Next: 49; Setup: 0; Categories: []),
    (Key: #$0075; Len: 2; Next: 54; Setup: 0; Categories: []),
    (Key: #$0078; Len: 1; Next: 59; Setup: 0; Categories: []),
    (Key: #$006C; Len: 1; Next: 11; Setup: 0; Categories: []),
    (Key: #$006E; Len: 2; Next: 13; Setup: 0; Categories: []),
    (Key: #$0070; Len: 1; Next: 16; Setup: 0; Categories: []),
    (Key: #$0075; Len: 1; Next: 14; Setup: 0; Categories: []),
    (Key: #$006D; Len: 1; Next: 15; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 16; Setup: 1; Categories: ClassLetter + ClassNumber),
    (Key: #$0068; Len: 1; Next: 17; Setup: 0; Categories: []),
    (Key: #$0061; Len: 1; Next: 18; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 19; Setup: 1; Categories: ClassLetter),
    (Key: #$006E; Len: 1; Next: 20; Setup: 0; Categories: []),
    (Key: #$0074; Len: 1; Next: 21; Setup: 0; Categories: []),
    (Key: #$0072; Len: 1; Next: 22; Setup: 0; Categories: []),
    (Key: #$006C; Len: 1; Next: 23; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 24; Setup: 1; Categories: [ccOtherControl, ccOtherFormat]),
    (Key: #$0069; Len: 1; Next: 25; Setup: 0; Categories: []),
    (Key: #$0067; Len: 1; Next: 26; Setup: 0; Categories: []),
    (Key: #$0069; Len: 1; Next: 27; Setup: 0; Categories: []),
    (Key: #$0074; Len: 1; Next: 28; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 29; Setup: 1; Categories: ClassNumber),
    (Key: #$0072; Len: 1; Next: 30; Setup: 0; Categories: []),
    (Key: #$0061; Len: 1; Next: 31; Setup: 0; Categories: []),
    (Key: #$0070; Len: 1; Next: 32; Setup: 0; Categories: []),
    (Key: #$0068; Len: 1; Next: 33; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 34; Setup: 1; Categories: ClassMark + ClassNumber + ClassLetter + ClassPunctuation +
      ClassSymbol),
    (Key: #$006F; Len: 1; Next: 35; Setup: 0; Categories: []),
    (Key: #$0077; Len: 1; Next: 36; Setup: 0; Categories: []),
    (Key: #$0065; Len: 1; Next: 37; Setup: 0; Categories: []),
    (Key: #$0072; Len: 1; Next: 38; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 39; Setup: 1; Categories: [ccLetterLowercase]),
    (Key: #$0072; Len: 2; Next: 41; Setup: 0; Categories: []),
    (Key: #$0075; Len: 1; Next: 45; Setup: 0; Categories: []),
    (Key: #$0069; Len: 1; Next: 42; Setup: 0; Categories: []),
    (Key: #$006E; Len: 1; Next: 43; Setup: 0; Categories: []),
    (Key: #$0074; Len: 1; Next: 44; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 45; Setup: 1; Categories: ClassMark + ClassNumber + ClassLetter + ClassPunctuation +
      ClassSymbol + [ccSeparatorSpace]),
    (Key: #$006E; Len: 1; Next: 46; Setup: 0; Categories: []),
    (Key: #$0063; Len: 1; Next: 47; Setup: 0; Categories: []),
    (Key: #$0074; Len: 1; Next: 48; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 49; Setup: 1; Categories: ClassPunctuation),
    (Key: #$0070; Len: 1; Next: 50; Setup: 0; Categories: []),
    (Key: #$0061; Len: 1; Next: 51; Setup: 0; Categories: []),
    (Key: #$0063; Len: 1; Next: 52; Setup: 0; Categories: []),
    (Key: #$0065; Len: 1; Next: 53; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 54; Setup: 2; Categories: ClassSpace),
    (Key: #$0070; Len: 1; Next: 55; Setup: 0; Categories: []),
    (Key: #$0070; Len: 1; Next: 56; Setup: 0; Categories: []),
    (Key: #$0065; Len: 1; Next: 57; Setup: 0; Categories: []),
    (Key: #$0072; Len: 1; Next: 58; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 59; Setup: 1; Categories: [ccLetterUppercase]),
    (Key: #$0064; Len: 1; Next: 60; Setup: 0; Categories: []),
    (Key: #$0069; Len: 1; Next: 61; Setup: 0; Categories: []),
    (Key: #$0067; Len: 1; Next: 62; Setup: 0; Categories: []),
    (Key: #$0069; Len: 1; Next: 63; Setup: 0; Categories: []),
    (Key: #$0074; Len: 1; Next: 64; Setup: 0; Categories: []),
    (Key: #$003A; Len: 1; Next: 65; Setup: 3; Categories: [])
  );
function TURESearch.SymbolsAreDifferent(A, B: PUcSymbolTableEntry): Boolean;
begin
  Result := False;
  if (A.AType <> B.AType) or (A.Mods <> B.Mods) or (A.Categories <> B.Categories) then
    Result := True
  else
  begin
    if (A.AType = _URE_CCLASS) or (A.AType = _URE_NCCLASS) then
    begin
      if A.Symbol.CCL.RangesUsed <> B.Symbol.CCL.RangesUsed then
        Result := True
      else
      begin
        if (A.Symbol.CCL.RangesUsed > 0) and
          not CompareMem(@A.Symbol.CCL.Ranges[0], @B.Symbol.CCL.Ranges[0],
            SizeOf(TUcRange) * A.Symbol.CCL.RangesUsed) then
          Result := True;;
      end;
    end
    else
    begin
      if (A.AType = _URE_CHAR) and (A.Symbol.Chr <> B.Symbol.Chr) then
        Result := True;
    end;
  end;
end;
function TURESearch.MakeExpression(AType, LHS, RHS: SizeInt): SizeInt;
var
  I: SizeInt;
begin
  // Determine if the expression already exists or not.
  with FUREBuffer.ExpressionList do
  begin
    for I := 0 to ExpressionsUsed - 1 do
    begin
      if (Expressions[I].AType = AType) and
         (Expressions[I].LHS = LHS) and
         (Expressions[I].RHS = RHS) then
      begin
        Result := I;
        Exit;
      end;
    end;
    // Need to add a new expression.
    if ExpressionsUsed = Length(Expressions) then
      SetLength(Expressions, Length(Expressions) + 8);
    Expressions[ExpressionsUsed].OnStack := False;
    Expressions[ExpressionsUsed].AType := AType;
    Expressions[ExpressionsUsed].LHS := LHS;
    Expressions[ExpressionsUsed].RHS := RHS;
    Result := ExpressionsUsed;
    Inc(ExpressionsUsed);
  end;
end;
function IsSpecial(C: Word): Boolean;
begin
  case C of
    Word('+'),
    Word('*'),
    Word('?'),
    Word('{'),
    Word('|'),
    Word(')'):
      Result := True;
  else
    Result := False;
  end;
end;
procedure TURESearch.CollectPendingOperations(var State: SizeInt);
// collects all pending AND and OR operations and make corresponding expressions
var
  Operation: SizeInt;
begin
  repeat
    Operation := Peek;
    if (Operation <> _URE_AND) and (Operation <> _URE_OR) then
      Break;
    // make an expression with the AND or OR operator and its right hand side
    Operation := Pop;
    State := MakeExpression(Operation, Pop, State);
  until False;
end;
procedure TURESearch.AddSymbolState(Symbol, State: SizeInt);
var
  I, J: SizeInt;
  Found: Boolean;
begin
  // Locate the symbol in the symbol table so the state can be added.
  // If the symbol doesn't exist, then we are in serious trouble.
  with FUREBuffer.SymbolTable do
  begin
    I := 0;
    while (I < SymbolsUsed) and (Symbol <> Symbols[I].ID) do
      Inc(I);
    Assert(I < SymbolsUsed);
  end;
  // Now find out if the state exists in the symbol's state list.
  with FUREBuffer.SymbolTable.Symbols[I].States do
  begin
    Found := False;
    for J := 0 to ListUsed - 1 do
    begin
      if State <= List[J] then
      begin
        Found := True;
        Break;
      end;
    end;
    if not Found then
      J := ListUsed;
    if not Found or (State < List[J]) then
    begin
      // Need to add the state in order.
      if ListUsed = Length(List) then
        SetLength(List, Length(List) + 8);
      if J < ListUsed then
        Move(List[J], List[J + 1], SizeOf(SizeInt) * (ListUsed - J));
      List[J] := State;
      Inc(ListUsed);
    end;
  end;
end;
function TURESearch.AddState(NewStates: array of SizeInt): SizeInt;
var
  I: SizeInt;
  Found: Boolean;
begin
  Found := False;
  for I := 0 to FUREBuffer.States.StatesUsed - 1 do
  begin
    if (FUREBuffer.States.States[I].StateList.ListUsed = Length(NewStates)) and
       CompareMem(@NewStates[0], @FUREBuffer.States.States[I].StateList.List[0],
         SizeOf(SizeInt) * Length(NewStates)) then
    begin
      Found := True;
      Break;
    end;
  end;
  if not Found then
  begin
    // Need to add a new DFA State (set of NFA states).
    if FUREBuffer.States.StatesUsed = Length(FUREBuffer.States.States) then
      SetLength(FUREBuffer.States.States, Length(FUREBuffer.States.States) + 8);
    with FUREBuffer.States.States[FUREBuffer.States.StatesUsed] do
    begin
      ID := FUREBuffer.States.StatesUsed;
      if (StateList.ListUsed + Length(NewStates)) >= Length(StateList.List) then
        SetLength(StateList.List, Length(StateList.List) + Length(NewStates) + 8);
      Move(NewStates[0], StateList.List[StateList.ListUsed], SizeOf(SizeInt) * Length(NewStates));
      Inc(StateList.ListUsed, Length(NewStates));
    end;
    Inc(FUREBuffer.States.StatesUsed);
  end;
  // Return the ID of the DFA state representing a group of NFA States.
  if Found then
    Result := I
  else
    Result := FUREBuffer.States.StatesUsed - 1;
end;
procedure TURESearch.Reduce(Start: SizeInt);
var
  I, J,
  Symbols: SizeInt;
  State,
  RHS,
  s1, s2,
  ns1, ns2: SizeInt;
  Evaluating: Boolean;
begin
  FUREBuffer.Reducing := True;
  // Add the starting state for the reduction.
  AddState([Start]);
  // Process each set of NFA states that get created.
  I := 0;
  // further states are added in the loop
  while I < FUREBuffer.States.StatesUsed do
  begin
    with FUREBuffer, States.States[I], ExpressionList do
    begin
      // Push the current states on the stack.
      for J := 0 to StateList.ListUsed - 1 do
        Push(StateList.List[J]);
      // Reduce the NFA states.
      Accepting := False;
      Symbols := 0;
      J := 0;
      // need a while loop here as the stack will be modified within the loop and
      // so also its usage count used to terminate the loop
      while J < FUREBuffer.Stack.ListUsed do
      begin
        State := FUREBuffer.Stack.List[J];
        Evaluating := True;
        // This inner loop is the iterative equivalent of recursively
        // reducing subexpressions generated as a result of a reduction.
        while Evaluating do
        begin
          case Expressions[State].AType of
            _URE_SYMBOL:
              begin
                ns1 := MakeExpression(_URE_ONE, _URE_NOOP, _URE_NOOP);
                AddSymbolState(Expressions[State].LHS, ns1);
                Inc(Symbols);
                Evaluating := False;
              end;
            _URE_ONE:
              begin
                Accepting := True;
                Evaluating := False;
              end;
            _URE_QUEST:
              begin
                s1 := Expressions[State].LHS;
                ns1 := MakeExpression(_URE_ONE, _URE_NOOP, _URE_NOOP);
                State := MakeExpression(_URE_OR, ns1, s1);
              end;
            _URE_PLUS:
              begin
                s1 := Expressions[State].LHS;
                ns1 := MakeExpression(_URE_STAR, s1, _URE_NOOP);
                State := MakeExpression(_URE_AND, s1, ns1);
              end;
            _URE_STAR:
              begin
                s1 := Expressions[State].LHS;
                ns1 := MakeExpression(_URE_ONE, _URE_NOOP, _URE_NOOP);
                ns2 := MakeExpression(_URE_PLUS, s1, _URE_NOOP);
                State := MakeExpression(_URE_OR, ns1, ns2);
              end;
            _URE_OR:
              begin
                s1 := Expressions[State].LHS;
                s2 := Expressions[State].RHS;
                Push(s1);
                Push(s2);
                Evaluating := False;
              end;
            _URE_AND:
              begin
                s1 := Expressions[State].LHS;
                s2 := Expressions[State].RHS;
                case Expressions[s1].AType of
                  _URE_SYMBOL:
                    begin
                      AddSymbolState(Expressions[s1].LHS, s2);
                      Inc(Symbols);
                      Evaluating := False;
                    end;
                  _URE_ONE:
                    State := s2;
                  _URE_QUEST:
                    begin
                      ns1 := Expressions[s1].LHS;
                      ns2 := MakeExpression(_URE_AND, ns1, s2);
                      State := MakeExpression(_URE_OR, s2, ns2);
                    end;
                  _URE_PLUS:
                    begin
                      ns1 := Expressions[s1].LHS;
                      ns2 := MakeExpression(_URE_OR, s2, State);
                      State := MakeExpression(_URE_AND, ns1, ns2);
                    end;
                  _URE_STAR:
                    begin
                      ns1 := Expressions[s1].LHS;
                      ns2 := MakeExpression(_URE_AND, ns1, State);
                      State := MakeExpression(_URE_OR, s2, ns2);
                    end;
                  _URE_OR:
                    begin
                      ns1 := Expressions[s1].LHS;
                      ns2 := Expressions[s1].RHS;
                      ns1 := MakeExpression(_URE_AND, ns1, s2);
                      ns2 := MakeExpression(_URE_AND, ns2, s2);
                      State := MakeExpression(_URE_OR, ns1, ns2);
                    end;
                  _URE_AND:
                    begin
                      ns1 := Expressions[s1].LHS;
                      ns2 := Expressions[s1].RHS;
                      ns2 := MakeExpression(_URE_AND, ns2, s2);
                      State := MakeExpression(_URE_AND, ns1, ns2);
                    end;
                end;
              end;
          end;
        end;
        Inc(J);
      end;
      // clear the state stack
      while Pop <> _URE_NOOP do
        { nothing };
      // generate the DFA states for the symbols collected during the current reduction
      if (TransitionsUsed + Symbols) > Length(Transitions) then
        SetLength(Transitions, Length(Transitions) + Symbols);
      // go through the symbol table and generate the DFA state transitions for
      // each symbol that has collected NFA states
      Symbols := 0;
      J := 0;
      while J < FUREBuffer.SymbolTable.SymbolsUsed do
      begin
        begin
          if FUREBuffer.SymbolTable.Symbols[J].States.ListUsed > 0 then
          begin
            Transitions[Symbols].LHS := FUREBuffer.SymbolTable.Symbols[J].ID;
            with FUREBuffer.SymbolTable.Symbols[J] do
            begin
              RHS := AddState(Copy(States.List, 0, States.ListUsed));
              States.ListUsed := 0;
            end;
            Transitions[Symbols].RHS := RHS;
            Inc(Symbols);
          end;
        end;
        Inc(J);
      end;
      // set the number of transitions actually used
      // Note: we need again to qualify a part of the TransistionsUsed path since the
      //       state array could be reallocated in the AddState call above and the
      //       with ... do will then be invalid.
      States.States[I].TransitionsUsed := Symbols;
    end;
    Inc(I);
  end;
  FUREBuffer.Reducing := False;
end;
procedure TURESearch.AddEquivalentPair(L, R: SizeInt);
var
  I: SizeInt;
begin
  L := FUREBuffer.States.States[L].ID;
  R := FUREBuffer.States.States[R].ID;
  if L <> R then
  begin
    if L > R then
    begin
      I := L;
      L := R;
      R := I;
    end;
    // Check to see if the equivalence pair already exists.
    I := 0;
    with FUREBuffer.EquivalentList do
    begin
      while (I < EquivalentsUsed) and
            ((Equivalents[I].Left <> L) or (Equivalents[I].Right <> R)) do
        Inc(I);
      if I >= EquivalentsUsed then
      begin
        if EquivalentsUsed = Length(Equivalents) then
          SetLength(Equivalents, Length(Equivalents) + 8);
        Equivalents[EquivalentsUsed].Left := L;
        Equivalents[EquivalentsUsed].Right := R;
        Inc(EquivalentsUsed);
      end;
    end;
  end;
end;
procedure TURESearch.MergeEquivalents;
// merges the DFA states that are equivalent
var
  I, J, K,
  Equal: SizeInt;
  Done: Boolean;
  State1, State2,
  LeftState,
  RightState: PUcState;
begin
  for I := 0 to FUREBuffer.States.StatesUsed - 1 do
  begin
    State1 := @FUREBuffer.States.States[I];
    if State1.ID = SizeInt(I) then
    begin
      J := 0;
      while J < I do
      begin
        State2 := @FUREBuffer.States.States[J];
        if State2.ID = SizeInt(J) then
        begin
          FUREBuffer.EquivalentList.EquivalentsUsed := 0;
          AddEquivalentPair(I, J);
          Done := False;
          Equal := 0;
          while Equal < FUREBuffer.EquivalentList.EquivalentsUsed do
          begin
            LeftState := @FUREBuffer.States.States[FUREBuffer.EquivalentList.Equivalents[Equal].Left];
            RightState := @FUREBuffer.States.States[FUREBuffer.EquivalentList.Equivalents[Equal].Right];
            if (LeftState.Accepting <> RightState.Accepting) or
               (LeftState.TransitionsUsed <> RightState.TransitionsUsed) then
            begin
              Done := True;
              Break;
            end;
            K := 0;
            while (K < LeftState.TransitionsUsed) and
                  (LeftState.Transitions[K].LHS = RightState.Transitions[K].LHS) do
              Inc(K);
            if K < LeftState.TransitionsUsed then
            begin
              Done := True;
              Break;
            end;
            for K := 0 to LeftState.TransitionsUsed - 1 do
              AddEquivalentPair(LeftState.Transitions[K].RHS, RightState.Transitions[K].RHS);
            Inc(Equal);
          end;
          if not Done then
            Break;
        end;
        Inc(J);
      end;
      if J < I then
      begin
        with FUREBuffer do
        begin
          for Equal := 0 to EquivalentList.EquivalentsUsed - 1 do
          begin
            States.States[EquivalentList.Equivalents[Equal].Right].ID :=
              States.States[EquivalentList.Equivalents[Equal].Left].ID;
          end;
        end;
      end;
    end;
  end;
  // Renumber the states appropriately
  State1 := @FUREBuffer.States.States[0];
  Equal := 0;
  for I := 0 to FUREBuffer.States.StatesUsed - 1 do
  begin
    if State1.ID = SizeInt(I) then
    begin
      State1.ID := Equal;
      Inc(Equal);
    end
    else
      State1.ID := FUREBuffer.States.States[State1.ID].ID;
    Inc(State1);
  end;
end;
function IsSeparator(C: UCS4): Boolean;
begin
  Result := (C = $D) or (C = $A) or (C = $2028) or (C = $2029);
end;
constructor TWideStrings.Create;
begin
  inherited Create;
  FNormalizationForm := nfC;
  FSaveFormat := sfUnicodeLSB;
end;
procedure TWideStrings.SetLanguage(Value: LCID);
begin
  FLanguage := Value;
end;
function TWideStrings.GetSaveUnicode: Boolean;
begin
  Result := SaveFormat = sfUnicodeLSB;
end;
procedure TWideStrings.SetSaveUnicode(const Value: Boolean);
begin
  if Value then
    SaveFormat := sfUnicodeLSB
  else
    SaveFormat := sfAnsi;
end;
function TWideStrings.Add(const S: DWWideString): Integer;
begin
  Result := GetCount;
  Insert(Result, S);
end;
function TWideStrings.AddObject(const S: DWWideString; AObject: TObject): Integer;
begin
  Result := Add(S);
  PutObject(Result, AObject);
end;
procedure TWideStrings.Append(const S: DWWideString);
begin
  Add(S);
end;
procedure TWideStrings.AddStrings(Strings: TStrings);
var
  I: Integer;
  {$IFNDEF SUPPORTS_UNICODE}
  CP: Word;
  {$ENDIF ~SUPPORTS_UNICODE}
begin
  BeginUpdate;
  try
    {$IFNDEF SUPPORTS_UNICODE}
    CP := CodePageFromLocale(FLanguage);
    {$ENDIF ~SUPPORTS_UNICODE}
    for I := 0 to Strings.Count - 1 do
    begin
      {$IFDEF SUPPORTS_UNICODE}
      AddObject(Strings[I], Strings.Objects[I])
      {$ELSE ~SUPPORTS_UNICODE}
      AddObject(StringToWideStringEx(Strings[I], CP), Strings.Objects[I])
      {$ENDIF ~SUPPORTS_UNICODE}
    end;
  finally
    EndUpdate;
  end;
end;
procedure TWideStrings.AddStrings(Strings: TWideStrings);
var
  I: Integer;
begin
  Assert(Strings <> nil);
  BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
      AddObject(Strings[I], Strings.Objects[I]);
  finally
    EndUpdate;
  end;
end;
procedure TWideStrings.Assign(Source: TPersistent);
// usual assignment routine, but able to assign wide and small strings
begin
  if Source is TWideStrings then
  begin
    BeginUpdate;
    try
      Clear;
      AddStrings(TWideStrings(Source));
    finally
      EndUpdate;
    end;
  end
  else
  begin
    if Source is TStrings then
    begin
      BeginUpdate;
      try
        Clear;
        AddStrings(TStrings(Source));
      finally
        EndUpdate;
      end;
    end
    else
      inherited Assign(Source);
  end;
end;
procedure TWideStrings.AssignTo(Dest: TPersistent);
// need to do also assignment to old style TStrings, but this class doesn't know
// TWideStrings, so we need to do it from here
var
  I: Integer;
  {$IFNDEF SUPPORTS_UNICODE}
  CP: Word;
  {$ENDIF ~SUPPORTS_UNICODE}
begin
  if Dest is TStrings then
  begin
    with Dest as TStrings do
    begin
      BeginUpdate;
      try
        {$IFNDEF SUPPORTS_UNICODE}
        CP := CodePageFromLocale(FLanguage);
        {$ENDIF SUPPORTS_UNICODE}
        Clear;
        for I := 0 to Self.Count - 1 do
        begin
          {$IFDEF SUPPORTS_UNICODE}
          AddObject(Self[I], Self.Objects[I]);
          {$ELSE ~SUPPORTS_UNICODE}
          AddObject(WideStringToStringEx(Self[I], CP), Self.Objects[I]);
          {$ENDIF ~SUPPORTS_UNICODE}
        end;
      finally
        EndUpdate;
      end;
    end;
  end
  else
  begin
    if Dest is TWideStrings then
    begin
      with Dest as TWideStrings do
      begin
        BeginUpdate;
        try
          Clear;
          AddStrings(Self);
        finally
          EndUpdate;
        end;
      end;
    end
    else
      inherited AssignTo(Dest);
  end;
end;
procedure TWideStrings.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TWideStrings.DoConfirmConversion(var Allowed: Boolean);
begin
  if Assigned(FOnConfirmConversion) then
    FOnConfirmConversion(Self, Allowed);
end;
procedure TWideStrings.EndUpdate;
begin
  Dec(FUpdateCount);
end;
function TWideStrings.Equals(Strings: TWideStrings): Boolean;
var
  I, Count: Integer;
begin
  Assert(Strings <> nil);
  Result := False;
  Count := GetCount;
  if Count <> Strings.GetCount then
    Exit;
  { TODO : use internal comparation routine as soon as composition is implemented }
  for I := 0 to Count - 1 do
    if Get(I) <> Strings.Get(I) then
      Exit;
  Result := True;
end;
procedure TWideStrings.Exchange(Index1, Index2: Integer);
var
  TempObject: TObject;
  TempString: DWWideString;
begin
  BeginUpdate;
  try
    TempString := Strings[Index1];
    TempObject := Objects[Index1];
    Strings[Index1] := Strings[Index2];
    Objects[Index1] := Objects[Index2];
    Strings[Index2] := TempString;
    Objects[Index2] := TempObject;
  finally
    EndUpdate;
  end;
end;
function TWideStrings.GetCapacity: Integer;
// Descendants may optionally override/replace this default implementation.
begin
  Result := Count;
end;
function TWideStrings.GetName(Index: Integer): DWWideString;
var
  P: Integer;
begin
  Result := Get(Index);
  P := Pos('=', Result);
  if P > 0 then
    SetLength(Result, P - 1)
  else
    Result := '';
end;
function TWideStrings.GetObject(Index: Integer): TObject;
begin
  Result := nil;
end;
function TWideStrings.GetSeparatedText(Separators: DWWideString): DWWideString;
// Same as GetText but with customizable separator characters.
var
  I, L,
  Size,
  Count,
  SepSize: Integer;
  P: PDWChar;
  S: DWWideString;
begin
  Count := GetCount;
  SepSize := Length(Separators);
  Size := 0;
  for I := 0 to Count - 1 do
    Inc(Size, Length(Get(I)) + SepSize);
  // set one separator less, the last line does not need a trailing separator
  SetLength(Result, Size - SepSize);
  if Size > 0 then
  begin
    P := Pointer(Result);
    I := 0;
    while True do
    begin
      S := Get(I);
      L := Length(S);
      if L <> 0 then
      begin
        // add current string
        System.Move(Pointer(S)^, P^, 2 * L);
        Inc(P, L);
      end;
      Inc(I);
      if I = Count then
        Break;
      // add separators
      System.Move(Pointer(Separators)^, P^, SizeOf(WideChar) * SepSize);
      Inc(P, SepSize);
    end;
  end;
end;
function TWideStrings.GetTextStr: DWWideString;
begin
  Result := GetSeparatedText(WideCRLF);
end;
function TWideStrings.IndexOfObject(AObject: TObject): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if GetObject(Result) = AObject then
      Exit;
  Result := -1;
end;
procedure TWideStrings.InsertObject(Index: Integer; const S: DWWideString; AObject: TObject);
begin
  Insert(Index, S);
  PutObject(Index, AObject);
end;
procedure TWideStrings.Move(CurIndex, NewIndex: Integer);
var
  TempObject: TObject;
  TempString: DWWideString;
begin
  if CurIndex <> NewIndex then
  begin
    BeginUpdate;
    try
      TempString := Get(CurIndex);
      TempObject := GetObject(CurIndex);
      Delete(CurIndex);
      InsertObject(NewIndex, TempString, TempObject);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TWideStrings.SetCapacity(NewCapacity: Integer);
begin
  // do nothing - descendants may optionally implement this method
end;
procedure TWideStrings.WriteData(Writer: TWriter);
begin
  Writer.{$IFDEF RTL240_UP}WriteString{$ELSE}WriteWideString{$ENDIF}(GetTextStr);
end;
//=== { TWideStringList } ====================================================
destructor TWideStringList.Destroy;
begin
  FOnChange := nil;
  FOnChanging := nil;
  Clear;
  inherited Destroy;
end;
procedure TWideStringList.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then
    FOnChange(Self);
end;
procedure TWideStringList.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;
procedure TWideStringList.Clear;
{$IFDEF OWN_WIDESTRING_MEMMGR}
var
  I: Integer;
{$ENDIF OWN_WIDESTRING_MEMMGR}
begin
  if FCount <> 0 then
  begin
    Changing;
    {$IFDEF OWN_WIDESTRING_MEMMGR}
    for I := 0 to FCount - 1 do
      with FList[I] do
        if TDynWideCharArray(FString) <> nil then
          TDynWideCharArray(FString) := nil;
    {$ENDIF OWN_WIDESTRING_MEMMGR}
    // this will automatically finalize the array
    FList := nil;
    FCount := 0;
    SetCapacity(0);
    Changed;
  end;
end;
procedure TWideStringList.Delete(Index: Integer);
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    raise Exception.Create(Format(SListIndexError, [Index]));
  Changing;
  {$IFDEF OWN_WIDESTRING_MEMMGR}
  SetListString(Index, '');
  {$ELSE ~OWN_WIDESTRING_MEMMGR}
  FList[Index].FString := '';
  {$ENDIF ~OWN_WIDESTRING_MEMMGR}
  Dec(FCount);
  if Index < FCount then
  begin
    System.Move(FList[Index + 1], FList[Index], (FCount - Index) * SizeOf(TWideStringItem));
    Pointer(FList[FCount].FString) := nil; // avoid freeing the string, the address is now used in another element
  end;
  Changed;
end;
procedure TWideStringList.Exchange(Index1, Index2: Integer);
begin
  if Cardinal(Index1) >= Cardinal(FCount) then
    raise Exception.Create(Format(SListIndexError, [Index1]));
  if Cardinal(Index2) >= Cardinal(FCount) then
    raise Exception.Create(Format(SListIndexError, [Index2]));
  Changing;
  ExchangeItems(Index1, Index2);
  Changed;
end;
procedure TWideStringList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: TWideStringItem;
begin
  Temp := FList[Index1];
  FList[Index1] := FList[Index2];
  FList[Index2] := Temp;
end;
function TWideStringList.Get(Index: Integer): DWWideString;
{$IFDEF OWN_WIDESTRING_MEMMGR}
var
  Len: Integer;
{$ENDIF OWN_WIDESTRING_MEMMGR}
begin
  if Cardinal(Index) >= Cardinal(FCount) then
   raise Exception.Create(Format(SListIndexError, [Index]));
  {$IFDEF OWN_WIDESTRING_MEMMGR}
  with FList[Index] do
  begin
    Len := Length(TDynWideCharArray(FString));
    if Len > 0 then
    begin
      SetLength(Result, Len - 1); // exclude #0
      if Result <> '' then
        System.Move(FString^, Result[1], Len * SizeOf(WideChar));
    end
    else
      Result := '';
  end;
  {$ELSE ~OWN_WIDESTRING_MEMMGR}
  Result := FList[Index].FString;
  {$ENDIF ~OWN_WIDESTRING_MEMMGR}
end;
function TWideStringList.GetCapacity: Integer;
begin
  Result := Length(FList);
end;
function TWideStringList.GetCount: Integer;
begin
  Result := FCount;
end;
function TWideStringList.GetObject(Index: Integer): TObject;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    raise Exception.Create(Format(SListIndexError, [Index]));
  Result := FList[Index].FObject;
end;
procedure TWideStringList.Grow;
var
  Delta,
  Len: Integer;
begin
  Len := Length(FList);
  if Len > 64 then
    Delta := Len div 4
  else
  begin
    if Len > 8 then
      Delta := 16
    else
      Delta := 4;
  end;
  SetCapacity(Len + Delta);
end;
{$IFDEF OWN_WIDESTRING_MEMMGR}
procedure TWideStringList.SetListString(Index: Integer; const S: DWWideString);
var
  Len: Integer;
  A: TDynWideCharArray;
begin
  with FList[Index] do
  begin
    Pointer(A) := TDynWideCharArray(FString);
    if A <> nil then
      A := nil; // free memory
    Len := Length(S);
    if Len > 0 then
    begin
      SetLength(A, Len + 1); // include #0
      System.Move(S[1], A[0], Len * SizeOf(WideChar));
      A[Len] := #0;
    end;
    FString := PDWChar(A);
    Pointer(A) := nil; // do not release the array on procedure exit
  end;
end;
{$ENDIF OWN_WIDESTRING_MEMMGR}
procedure TWideStringList.PutObject(Index: Integer; AObject: TObject);
begin
  if Cardinal(Index) >= Cardinal(FCount) then
   raise Exception.Create(Format(SListIndexError, [Index]));
  Changing;
  FList[Index].FObject := AObject;
  Changed;
end;
procedure TWideStringList.QuickSort(L, R: Integer);
var
  I, J: Integer;
  P: DWWideString;
begin
  repeat
    I := L;
    J := R;
    P := PDWString(@FList[(L + R) shr 1].FString)^;
    repeat
      while WideCompareText(PDWString(@FList[I].FString)^, P, FLanguage) < 0 do
        Inc(I);
      while WideCompareText(PDWString(@FList[J].FString)^, P, FLanguage) > 0 do
        Dec(J);
      if I <= J then
      begin
        ExchangeItems(I, J);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J);
    L := I;
  until I >= R;
end;
procedure TWideStringList.SetCapacity(NewCapacity: Integer);
begin
  SetLength(FList, NewCapacity);
  if NewCapacity < FCount then
    FCount := NewCapacity;
end;
procedure TWideStringList.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then
      Sort;
    FSorted := Value;
  end;
end;
procedure TWideStringList.Sort;
begin
  if not Sorted and (FCount > 1) then
  begin
    Changing;
    QuickSort(0, FCount - 1);
    Changed;
  end;
end;
procedure TWideStringList.SetLanguage(Value: LCID);
begin
  inherited SetLanguage(Value);
  if Sorted then
    Sort;
end;
{$ENDIF ~UNICODE_RTL_DATABASE}
function DWWideStringOfChar(C: DWChar; Count: SizeInt): DWWideString;
// returns a string of Count characters filled with C
var
  I: SizeInt;
begin
  SetLength(Result, Count);
  for I := 1 to Count do
    Result[I] := C;
end;
function WideTrim(const S: DWWideString): DWWideString;
var
  I, L: SizeInt;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (UnicodeIsWhiteSpace(UCS4(S[I])) or UnicodeIsControl(UCS4(S[I]))) do
    Inc(I);
  if I > L then
    Result := ''
  else
  begin
    while UnicodeIsWhiteSpace(UCS4(S[L])) or UnicodeIsControl(UCS4(S[L])) do
      Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;
function WideTrimLeft(const S: DWWideString): DWWideString;
var
  I, L: SizeInt;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (UnicodeIsWhiteSpace(UCS4(S[I])) or UnicodeIsControl(UCS4(S[I]))) do
    Inc(I);
  Result := Copy(S, I, Maxint);
end;
function WideTrimRight(const S: DWWideString): DWWideString;
var
  I: SizeInt;
begin
  I := Length(S);
  while (I > 0) and (UnicodeIsWhiteSpace(UCS4(S[I])) or UnicodeIsControl(UCS4(S[I]))) do
    Dec(I);
  Result := Copy(S, 1, I);
end;
{$IFNDEF UNICODE_RTL_DATABASE}
procedure FixCanonical(var S: DWWideString);
// Examines S and reorders all combining marks in the string so that they are in canonical order.
var
  I: SizeInt;
  Temp: DWChar;
  CurrentClass,
  LastClass: Cardinal;
begin
  I := Length(S);
  if I > 1 then
  begin
    CurrentClass := CanonicalCombiningClass(UCS4(S[I]));
    repeat
      Dec(I);
      LastClass := CurrentClass;
      CurrentClass := CanonicalCombiningClass(UCS4(S[I]));
      // A swap is presumed to be rare (and a double-swap very rare),
      // so don't worry about efficiency here.
      if (CurrentClass > LastClass) and (LastClass > 0) then
      begin
        // swap characters
        Temp := S[I];
        S[I] := S[I + 1];
        S[I + 1] := Temp;
        // if not at end, backup (one further, to compensate for loop)
        if I < Length(S) - 1 then
          Inc(I, 2);
        // reset type, since we swapped.
        CurrentClass := CanonicalCombiningClass(UCS4(S[I]));
      end;
    until I = 1;
  end;
end;
function WideDecompose(const S: DWWideString; Compatible: Boolean): DWWideString;
// returns a string with all characters of S but decomposed, e.g.  is returned as E^ etc.
var
  I, J: SizeInt;
  Decomp: TUCS4Array;
begin
  Result := '';
  Decomp := nil;
  // iterate through each source code point
  for I := 1 to Length(S) do
  begin
    Decomp := UnicodeDecompose(UCS4(S[I]), Compatible);
    if Decomp = nil then
      Result := Result + S[I]
    else
      for J := 0 to High(Decomp) do
        Result := Result + DWChar(Decomp[J]);
  end;
  // combining marks must be sorted according to their canonical combining class
  FixCanonical(Result);
end;
function WideDecompose(const S: DWWideString; Tags: TCompatibilityFormattingTags): DWWideString;
// returns a string with all characters of S but decomposed, e.g.  is returned as E^ etc.
var
  I, J: SizeInt;
  Decomp: TUCS4Array;
begin
  Result := '';
  Decomp := nil;
  // iterate through each source code point
  for I := 1 to Length(S) do
  begin
    Decomp := UnicodeDecompose(UCS4(S[I]), Tags);
    if Decomp = nil then
      Result := Result + S[I]
    else
      for J := 0 to High(Decomp) do
        Result := Result + DWChar(Decomp[J]);
  end;
  // combining marks must be sorted according to their canonical combining class
  FixCanonical(Result);
end;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeIsAlpha(C: UCS4): Boolean; // Is the character alphabetic?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsLetter(Chr(C));
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsDigit(C: UCS4): Boolean; // Is the character a digit?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsDigit(Chr(C));
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccNumberDecimalDigit]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsAlphaNum(C: UCS4): Boolean; // Is the character alphabetic or a number?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsLetterOrDigit(Chr(C));
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter + [ccNumberDecimalDigit]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsNumberOther(C: UCS4): Boolean;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherNumber;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccNumberOther]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsCased(C: UCS4): Boolean;
// Is the character a "cased" character, i.e. either lower case, title case or upper case
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucTitlecaseLetter, TUnicodeCategory.ucUppercaseLetter];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterLowercase, ccLetterTitleCase, ccLetterUppercase]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsControl(C: UCS4): Boolean;
// Is the character a control character?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucControl, TUnicodeCategory.ucFormat];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherControl, ccOtherFormat]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsSpace(C: UCS4): Boolean;
// Is the character a spacing character?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSpaceSeparator;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassSpace);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsWhiteSpace(C: UCS4): Boolean;
// Is the character a white space character (same as UnicodeIsSpace plus
// tabulator, new line etc.)?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.IsWhiteSpace(Chr(C));
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassSpace + [ccWhiteSpace, ccSegmentSeparator]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsBlank(C: UCS4): Boolean;
// Is the character a space separator?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSpaceSeparator;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSeparatorSpace]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsPunctuation(C: UCS4): Boolean;
// Is the character a punctuation mark?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassPunctuation);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsGraph(C: UCS4): Boolean;
// Is the character graphical?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucEnclosingMark,
     TUnicodeCategory.ucNonSpacingMark,
     TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber,
     TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation,
     TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassMark + ClassNumber + ClassLetter + ClassPunctuation + ClassSymbol);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsPrintable(C: UCS4): Boolean;
// Is the character printable?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucEnclosingMark,
     TUnicodeCategory.ucNonSpacingMark,
     TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber,
     TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation,
     TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol,
     TUnicodeCategory.ucSpaceSeparator];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassMark + ClassNumber + ClassLetter + ClassPunctuation + ClassSymbol +
    [ccSeparatorSpace]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsUpper(C: UCS4): Boolean;
// Is the character already upper case?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUppercaseLetter;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterUppercase]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsLower(C: UCS4): Boolean;
// Is the character already lower case?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLowercaseLetter;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterLowercase]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsTitle(C: UCS4): Boolean;
// Is the character already title case?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucTitlecaseLetter;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterTitlecase]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsHexDigit(C: UCS4): Boolean;
// Is the character a hex digit?
begin
  Result := CategoryLookup(C, [ccHexDigit]);
end;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeIsIsoControl(C: UCS4): Boolean;
// Is the character a C0 control character (< 32)?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucControl;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherControl]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsFormatControl(C: UCS4): Boolean;
// Is the character a format control character?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucFormat;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherFormat]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsSymbol(C: UCS4): Boolean;
// Is the character a symbol?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassSymbol);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsNumber(C: UCS4): Boolean;
// Is the character a number or digit?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassNumber);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsNonSpacing(C: UCS4): Boolean;
// Is the character non-spacing?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucNonSpacingMark;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccMarkNonSpacing]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsOpenPunctuation(C: UCS4): Boolean;
// Is the character an open/left punctuation (e.g. '[')?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOpenPunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationOpen]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsClosePunctuation(C: UCS4): Boolean;
// Is the character an close/right punctuation (e.g. ']')?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucClosePunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationClose]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsInitialPunctuation(C: UCS4): Boolean;
// Is the character an initial punctuation (e.g. U+2018 LEFT SINGLE QUOTATION MARK)?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucInitialPunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationInitialQuote]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsFinalPunctuation(C: UCS4): Boolean;
// Is the character a final punctuation (e.g. U+2019 RIGHT SINGLE QUOTATION MARK)?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucFinalPunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationFinalQuote]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsComposed(C: UCS4): Boolean;
// Can the character be decomposed into a set of other characters?
begin
  Result := CategoryLookup(C, [ccComposed]);
end;
function UnicodeIsQuotationMark(C: UCS4): Boolean;
// Is the character one of the many quotation marks?
begin
  Result := CategoryLookup(C, [ccQuotationMark]);
end;
function UnicodeIsSymmetric(C: UCS4): Boolean;
// Is the character one that has an opposite form (i.e. <>)?
begin
  Result := CategoryLookup(C, [ccSymmetric]);
end;
function UnicodeIsMirroring(C: UCS4): Boolean;
// Is the character mirroring (superset of symmetric)?
begin
  Result := CategoryLookup(C, [ccMirroring]);
end;
function UnicodeIsNonBreaking(C: UCS4): Boolean;
// Is the character non-breaking (i.e. non-breaking space)?
begin
  Result := CategoryLookup(C, [ccNonBreaking]);
end;
function UnicodeIsRightToLeft(C: UCS4): Boolean;
// Does the character have strong right-to-left directionality (i.e. Arabic letters)?
begin
  Result := CategoryLookup(C, [ccRightToLeft]);
end;
function UnicodeIsLeftToRight(C: UCS4): Boolean;
// Does the character have strong left-to-right directionality (i.e. Latin letters)?
begin
  Result := CategoryLookup(C, [ccLeftToRight]);
end;
function UnicodeIsStrong(C: UCS4): Boolean;
// Does the character have strong directionality?
begin
  Result := CategoryLookup(C, [ccLeftToRight, ccRightToLeft]);
end;
function UnicodeIsWeak(C: UCS4): Boolean;
// Does the character have weak directionality (i.e. numbers)?
begin
  Result := CategoryLookup(C, ClassEuropeanNumber + [ccArabicNumber, ccCommonNumberSeparator]);
end;
function UnicodeIsNeutral(C: UCS4): Boolean;
// Does the character have neutral directionality (i.e. whitespace)?
begin
  Result := CategoryLookup(C, [ccSeparatorParagraph, ccSegmentSeparator, ccWhiteSpace, ccOtherNeutrals]);
end;
function UnicodeIsSeparator(C: UCS4): Boolean;
// Is the character a block or segment separator?
begin
  Result := CategoryLookup(C, [ccSeparatorParagraph, ccSegmentSeparator]);
end;
function UnicodeIsMark(C: UCS4): Boolean;
// Is the character a mark of some kind?
begin
  Result := CategoryLookup(C, ClassMark);
end;
function UnicodeIsModifier(C: UCS4): Boolean;
// Is the character a letter modifier?
begin
  Result := CategoryLookup(C, [ccLetterModifier]);
end;
{$ENDIF ~UNICODE_RTL_DATABASE}
function UnicodeIsLetterNumber(C: UCS4): Boolean;
// Is the character a number represented by a letter?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLetterNumber;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccNumberLetter]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsConnectionPunctuation(C: UCS4): Boolean;
// Is the character connecting punctuation?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucConnectPunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationConnector]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsDash(C: UCS4): Boolean;
// Is the character a dash punctuation?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucDashPunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationDash]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsMath(C: UCS4): Boolean;
// Is the character a math character?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucMathSymbol;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolMath]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsCurrency(C: UCS4): Boolean;
// Is the character a currency character?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucCurrencySymbol;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolCurrency]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsModifierSymbol(C: UCS4): Boolean;
// Is the character a modifier symbol?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucModifierSymbol;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolModifier]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsSpacingMark(C: UCS4): Boolean;
// Is the character a spacing mark?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLineSeparator, TUnicodeCategory.ucParagraphSeparator,
     TUnicodeCategory.ucSpaceSeparator];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccMarkSpacingCombining]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsEnclosing(C: UCS4): Boolean;
// Is the character enclosing (i.e. enclosing box)?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucEnclosingMark;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccMarkEnclosing]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsPrivate(C: UCS4): Boolean;
// Is the character from the Private Use Area?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucPrivateUse;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherPrivate]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsSurrogate(C: UCS4): Boolean;
// Is the character one of the surrogate codes?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSurrogate;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherSurrogate]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsLineSeparator(C: UCS4): Boolean;
// Is the character a line separator?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLineSeparator;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSeparatorLine]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsParagraphSeparator(C: UCS4): Boolean;
// Is th character a paragraph separator;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucParagraphSeparator;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSeparatorParagraph]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsIdentifierStart(C: UCS4): Boolean;
// Can the character begin an identifier?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucLetterNumber];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter + [ccNumberLetter]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsIdentifierPart(C: UCS4): Boolean;
// Can the character appear in an identifier?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucLetterNumber, TUnicodeCategory.ucDecimalNumber,
     TUnicodeCategory.ucNonSpacingMark, TUnicodeCategory.ucCombiningMark,
     TUnicodeCategory.ucConnectPunctuation,
     TUnicodeCategory.ucFormat];
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, ClassLetter + [ccNumberLetter, ccMarkNonSpacing, ccMarkSpacingCombining,
    ccNumberDecimalDigit, ccPunctuationConnector, ccOtherFormat]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsDefined(C: UCS4): Boolean;
// Is the character defined (appears in one of the data files)?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) <> TUnicodeCategory.ucUnassigned;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccAssigned]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsUndefined(C: UCS4): Boolean;
// Is the character undefined (not assigned in the Unicode database)?
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUnassigned;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := not CategoryLookup(C, [ccAssigned]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsHan(C: UCS4): Boolean;
// Is the character a Han ideograph?
begin
  Result := ((C >= $4E00) and (C <= $9FFF))  or ((C >= $F900) and (C <= $FAFF));
end;
function UnicodeIsHangul(C: UCS4): Boolean;
// Is the character a pre-composed Hangul syllable?
begin
  Result := (C >= $AC00) and (C <= $D7FF);
end;
function UnicodeIsUnassigned(C: UCS4): Boolean;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUnassigned;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccOtherUnassigned]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsLetterOther(C: UCS4): Boolean;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherLetter;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccLetterOther]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsConnector(C: UCS4): Boolean;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucConnectPunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationConnector]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsPunctuationOther(C: UCS4): Boolean;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherPunctuation;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccPunctuationOther]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
function UnicodeIsSymbolOther(C: UCS4): Boolean;
begin
  {$IFDEF UNICODE_RTL_DATABASE}
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherSymbol;
  {$ELSE ~UNICODE_RTL_DATABASE}
  Result := CategoryLookup(C, [ccSymbolOther]);
  {$ENDIF ~UNICODE_RTL_DATABASE}
end;
{$IFNDEF UNICODE_RTL_DATABASE}
function UnicodeIsLeftToRightEmbedding(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccLeftToRightEmbedding]);
end;
function UnicodeIsLeftToRightOverride(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccLeftToRightOverride]);
end;
function UnicodeIsRightToLeftArabic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRightToLeftArabic]);
end;
function UnicodeIsRightToLeftEmbedding(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRightToLeftEmbedding]);
end;
function UnicodeIsRightToLeftOverride(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRightToLeftOverride]);
end;
function UnicodeIsPopDirectionalFormat(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccPopDirectionalFormat]);
end;
function UnicodeIsEuropeanNumber(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccEuropeanNumber]);
end;
function UnicodeIsEuropeanNumberSeparator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccEuropeanNumberSeparator]);
end;
function UnicodeIsEuropeanNumberTerminator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccEuropeanNumberTerminator]);
end;
function UnicodeIsArabicNumber(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccArabicNumber]);
end;
function UnicodeIsCommonNumberSeparator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccCommonNumberSeparator]);
end;
function UnicodeIsBoundaryNeutral(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccBoundaryNeutral]);
end;
function UnicodeIsSegmentSeparator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccSegmentSeparator]);
end;
function UnicodeIsOtherNeutrals(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherNeutrals]);
end;
function UnicodeIsASCIIHexDigit(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccASCIIHexDigit]);
end;
function UnicodeIsBidiControl(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccBidiControl]);
end;
function UnicodeIsDeprecated(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccDeprecated]);
end;
function UnicodeIsDiacritic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccDiacritic]);
end;
function UnicodeIsExtender(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccExtender]);
end;
function UnicodeIsHyphen(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccHyphen]);
end;
function UnicodeIsIdeographic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccIdeographic]);
end;
function UnicodeIsIDSBinaryOperator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccIDSBinaryOperator]);
end;
function UnicodeIsIDSTrinaryOperator(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccIDSTrinaryOperator]);
end;
function UnicodeIsJoinControl(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccJoinControl]);
end;
function UnicodeIsLogicalOrderException(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccLogicalOrderException]);
end;
function UnicodeIsNonCharacterCodePoint(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccNonCharacterCodePoint]);
end;
function UnicodeIsOtherAlphabetic(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherAlphabetic]);
end;
function UnicodeIsOtherDefaultIgnorableCodePoint(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherDefaultIgnorableCodePoint]);
end;
function UnicodeIsOtherGraphemeExtend(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherGraphemeExtend]);
end;
function UnicodeIsOtherIDContinue(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherIDContinue]);
end;
function UnicodeIsOtherIDStart(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherIDStart]);
end;
function UnicodeIsOtherLowercase(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherLowercase]);
end;
function UnicodeIsOtherMath(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherMath]);
end;
function UnicodeIsOtherUppercase(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccOtherUppercase]);
end;
function UnicodeIsPatternSyntax(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccPatternSyntax]);
end;
function UnicodeIsPatternWhiteSpace(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccPatternWhiteSpace]);
end;
function UnicodeIsRadical(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccRadical]);
end;
function UnicodeIsSoftDotted(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccSoftDotted]);
end;
function UnicodeIsSTerm(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccSTerm]);
end;
function UnicodeIsTerminalPunctuation(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccTerminalPunctuation]);
end;
function UnicodeIsUnifiedIdeograph(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccUnifiedIdeograph]);
end;
function UnicodeIsVariationSelector(C: UCS4): Boolean;
begin
  Result := CategoryLookup(C, [ccVariationSelector]);
end;
{$ENDIF ~UNICODE_RTL_DATABASE}
function CodeBlockRange(const CB: TUnicodeBlock): TUnicodeBlockRange;
// http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
begin
  Result := UnicodeBlockData[CB].Range;
end;

// Names taken from http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
function CodeBlockName(const CB: TUnicodeBlock): string;
begin
  Result := UnicodeBlockData[CB].Name;
end;
// Returns an ID for the Unicode code block to which C belongs.
// If C does not belong to any of the defined blocks then ubUndefined is returned.
// Note: the code blocks listed here are based on Unicode Version 5.0.0
function CodeBlockFromChar(const C: UCS4): TUnicodeBlock;
// http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
var
  L, H, I: TUnicodeBlock;
begin
  Result := ubUndefined;
  L := ubBasicLatin;
  H := High(TUnicodeBlock);
  while L <= H do
  begin
    I := TUnicodeBlock((Cardinal(L) + Cardinal(H)) shr 1);
    if (C >= UnicodeBlockData[I].Range.RangeStart) and (C <= UnicodeBlockData[I].Range.RangeEnd) then
    begin
      Result := I;
      Break;
    end
    else
    if C < UnicodeBlockData[I].Range.RangeStart then
    begin
      Dec(I);
      H := I;
    end
    else
    begin
      Inc(I);
      L := I;
    end;
  end;
end;

function UCS4Array(Ch: UCS4): TUCS4Array;
begin
  SetLength(Result, 1);
  Result[0] := Ch;
end;
function UCS4ArrayConcat(Left, Right: UCS4): TUCS4Array;
begin
  SetLength(Result, 2);
  Result[0] := Left;
  Result[1] := Right;
end;
procedure UCS4ArrayConcat(var Left: TUCS4Array; Right: UCS4);
var
  I: SizeInt;
begin
  I := Length(Left);
  SetLength(Left, I + 1);
  Left[I] := Right;
end;
procedure UCS4ArrayConcat(var Left: TUCS4Array; const Right: TUCS4Array);
var
  I, J: SizeInt;
begin
  I := Length(Left);
  J := Length(Right);
  SetLength(Left, I + J);
  Move(Right[0], Left[I], J * SizeOf(Right[0]));
end;
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: TUCS4Array): Boolean;
var
  I: SizeInt;
begin
  I := Length(Left);
  Result := I = Length(Right);
  while Result do
  begin
    Dec(I);
    Result := (I >= 0) and (Left[I] = Right[I]);
  end;
  Result := I < 0;
end;
function UCS4ArrayEquals(const Left: TUCS4Array; Right: UCS4): Boolean;
begin
  Result := (Length(Left) = 1) and (Left[0] = Right);
end;
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: DWString): Boolean;
var
  I: SizeInt;
begin
  I := Length(Left);
  Result := I = Length(Right);
  while Result do
  begin
    Dec(I);
    Result := (I >= 0) and (Left[I] = Ord(Right[I + 1]));
  end;
  Result := I < 0;
end;
function UCS4ArrayEquals(const Left: TUCS4Array; Right: DWChar): Boolean;
begin
  Result := (Length(Left) = 1) and (Left[0] = Ord(Right));
end;
end.
