Unit uRESTDWMemStrings;

{$I uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface
Uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes;
{regular expressions}
{template functions}
Function ReplaceFirst(Const SourceStr, FindStr, ReplaceStr: string): string;
Function ReplaceLast(Const SourceStr, FindStr, ReplaceStr: string): string;
Function InsertLastBlock(Var SourceStr: string; BlockStr: string): Boolean;
Function RemoveMasterBlocks(Const SourceStr: string): string;
Function RemoveFields(Const SourceStr: string): string;
{http functions}
Function URLEncode(Const Value: AnsiString): AnsiString; // Converts string To A URLEncoded string
Function URLDecode(Const Value: AnsiString): AnsiString; // Converts string From A URLEncoded string
{set functions}
Procedure SplitSet(AText: string; AList: TStringList);
Function JoinSet(AList: TStringList): string;
Function FirstOfSet(Const AText: string): string;
Function LastOfSet(Const AText: string): string;
Function CountOfSet(Const AText: string): Integer;
Function SetRotateRight(Const AText: string): string;
Function SetRotateLeft(Const AText: string): string;
Function SetPick(Const AText: string; AIndex: Integer): string;
Function SetSort(Const AText: string): string;
Function SetUnion(Const Set1, Set2: string): string;
Function SetIntersect(Const Set1, Set2: string): string;
Function SetExclude(Const Set1, Set2: string): string;
{simple hash, Result can be used in Encrypt}
Function Hash(Const AText: string): Integer;
{ Base64 encode and decode a string }
Function B64Encode(Const S: AnsiString): AnsiString;
Function B64Decode(Const S: AnsiString): AnsiString;
{Basic encryption from a Borland Example}
Function Encrypt(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
Function Decrypt(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
{Using Encrypt and Decrypt in combination with B64Encode and B64Decode}
Function EncryptB64(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
Function DecryptB64(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
Procedure CSVToTags(Src, Dst: TStringList);
// converts a csv list to a tagged string list
Procedure TagsToCSV(Src, Dst: TStringList);
// converts a tagged string list to a csv list
// only fieldnames from the first record are scanned ib the other records
Procedure ListSelect(Src, Dst: TStringList; Const AKey, AValue: string);
{selects akey=avalue from Src and returns recordset in Dst}
Procedure ListFilter(Src: TStringList; Const AKey, AValue: string);
{filters Src for akey=avalue}
Procedure ListOrderBy(Src: TStringList; Const AKey: string; Numeric: Boolean);
{orders a tagged Src list by akey}
Function PosStr(Const FindString, SourceString: string;
  StartPos: Integer = 1): Integer;
{ PosStr searches the first occurrence of a substring FindString in a string
  given by SourceString with case sensitivity (upper and lower case characters
  are differed). This function returns the index value of the first character
  of a specified substring from which it occurs in a given string starting with
  StartPos character index. If a specified substring is not found Q_PosStr
  returns zero. The author of algorithm is Peter Morris (UK) (Faststrings unit
  from www.torry.ru). }
Function PosStrLast(Const FindString, SourceString: string): Integer;
{finds the last occurance}
Function LastPosChar(Const FindChar: Char; SourceString: string): Integer;
Function PosText(Const FindString, SourceString: string;
  StartPos: Integer = 1): Integer;
{ PosText searches the first occurrence of a substring FindString in a string
  given by SourceString without case sensitivity (upper and lower case
  characters are not differed). This function returns the index value of the
  first character of a specified substring from which it occurs in a given
  string starting with StartPos character index. If a specified substring is
  not found Q_PosStr returns zero. The author of algorithm is Peter Morris
  (UK) (Faststrings unit from www.torry.ru). }
Function PosTextLast(Const FindString, SourceString: string): Integer;
{finds the last occurance}
Function NameValuesToXML(Const AText: string): string;
{$IFDEF MSWINDOWS}
Procedure LoadResourceFile(AFile: string; MemStream: TMemoryStream);
{$ENDIF MSWINDOWS}
Procedure DirFiles(Const ADir, AMask: string; AFileList: TStringList);
Procedure RecurseDirFiles(Const ADir: string; Var AFileList: TStringList);
Procedure RecurseDirProgs(Const ADir: string; Var AFileList: TStringList);
Procedure SaveString(Const AFile, AText: string);
Function LoadString(Const AFile: string): string;
Function UppercaseHTMLTags(Const AText: string): string;
Function LowercaseHTMLTags(Const AText: string): string;
Procedure GetHTMLAnchors(Const AFile: string; AList: TStringList);
Function RelativePath(Const ASrc, ADst: string): string;
Function GetToken(Var Start: Integer; Const SourceText: string): string;
Function PosNonSpace(Start: Integer; Const SourceText: string): Integer;
Function PosEscaped(Start: Integer; Const SourceText, FindText: string; EscapeChar: Char): Integer;
Function DeleteEscaped(Const SourceText: string; EscapeChar: Char): string;
Function BeginOfAttribute(Start: Integer; Const SourceText: string): Integer;
// parses the beginning of an attribute: space + alpha character
Function ParseAttribute(Var Start: Integer; Const SourceText: string; Var AName, AValue: string): Boolean;
// parses a name="value" attribute from Start; returns 0 when not found or else the position behind the attribute
Procedure ParseAttributes(Const SourceText: string; Attributes: TStrings);
// parses all name=value attributes to the attributes TStringList
Function HasStrValue(Const AText, AName: string; Var AValue: string): Boolean;
// checks if a name="value" pair exists and returns any value
Function GetStrValue(Const AText, AName, ADefault: string): string;
// retrieves string value from a line like:
//  name="jan verhoeven" email="jan1 dott verhoeven att wxs dott nl"
// returns ADefault when not found
Function GetIntValue(Const AText, AName: string; ADefault: Integer): Integer;
// same for an Integer
Function GetFloatValue(Const AText, AName: string; ADefault: Extended): Extended;
// same for a float
Function GetBoolValue(Const AText, AName: string): Boolean;
// same for Boolean but without default
Function GetValue(Const AText, AName: string): string;
// retrieves string value from a line like:
//  name="jan verhoeven" email="jan1 dott verhoeven att wxs dott nl"
Procedure SetValue(Var AText: string; Const AName, AValue: string);
// sets a string value in a line
Procedure DeleteValue(Var AText: string; Const AName: string);
// deletes a AName="value" pair from AText
Procedure GetNames(AText: string; AList: TStringList);
// get a list of names from a string with name="value" pairs
Function BackPosStr(Start: Integer; Const FindString, SourceString: string): Integer;
// finds a string backward case sensitive
Function BackPosText(Start: Integer; Const FindString, SourceString: string): Integer;
// finds a string backward case insensitive
Function PosRangeStr(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
// finds a text range, e.g. <TD>....</TD> case sensitive
Function PosRangeText(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
// finds a text range, e.g. <TD>....</td> case insensitive
Function BackPosRangeStr(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
// finds a text range backward, e.g. <TD>....</TD> case sensitive
Function BackPosRangeText(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
// finds a text range backward, e.g. <TD>....</td> case insensitive
Function PosTag(Start: Integer; SourceString: string; Var RangeBegin: Integer;
  Var RangeEnd: Integer): Boolean;
// finds a HTML or XML tag:  <....>
Function InnerTag(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
// finds the innertext between opening and closing tags
Function Easter(NYear: Integer): TDateTime;
// returns the easter date of a year.
Function GetWeekNumber(Today: TDateTime): string;
//gets a datecode. Returns year and weeknumber in format: YYWW
Function ParseNumber(Const S: string): Integer;
// parse number returns the last position, starting from 1
Function ParseDate(Const S: string): Integer;
// parse a SQL style data string from positions 1,
// starts and ends with #

Implementation
Uses
  {$IFDEF RTL200_UP}
  AnsiStrings,
  {$ENDIF RTL200_UP}
  uRESTDWMemConsts, uRESTDWMemResources, uRESTDWMemTypes;

Const
  B64Table: AnsiString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  ValidURLChars: AnsiString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$-_@.&+-!*"''(),;/#?:';

Procedure SaveString(Const AFile, AText: string);
Begin
  With TFileStream.Create(AFile, fmCreate) Do
  Try
    WriteBuffer(AText[1], Length(AText));
  Finally
    Free;
  End;
End;
Function LoadString(Const AFile: string): string;
Var
  S: string;
Begin
  With TFileStream.Create(AFile, fmOpenRead) Do
  Try
    SetLength(S, Size);
    ReadBuffer(S[1], Size);
  Finally
    Free;
  End;
  Result := S;
End;
Procedure DeleteValue(Var AText: string; Const AName: string);
Var
  P, P2, L: Integer;
Begin
  L := Length(AName) + 2;
  P := PosText(AName + '="', AText);
  If P = 0 Then
    Exit;
  P2 := PosStr('"', AText, P + L);
  If P2 = 0 Then
    Exit;
  If P > 1 Then
    Dec(P); // include the preceding space if not the first one
  Delete(AText, P, P2 - P + 1);
End;
Function GetValue(Const AText, AName: string): string;
Var
  P, P2, L: Integer;
Begin
  Result := '';
  L := Length(AName) + 2;
  P := PosText(AName + '="', AText);
  If P = 0 Then
    Exit;
  P2 := PosStr('"', AText, P + L);
  If P2 = 0 Then
    Exit;
  Result := Copy(AText, P + L, P2 - (P + L));
  Result := SysUtils.StringReplace(Result, '~~', Cr, [rfReplaceAll]);
End;
Function HasStrValue(Const AText, AName: string; Var AValue: string): Boolean;
Var
  P, P2, L: Integer;
  S: string;
Begin
  Result := False;
  L := Length(AName) + 2;
  P := PosText(AName + '="', AText);
  If P = 0 Then
    Exit;
  P2 := PosStr('"', AText, P + L);
  If P2 = 0 Then
    Exit;
  S := Copy(AText, P + L, P2 - (P + L));
  AValue := SysUtils.StringReplace(S, '~~', Cr, [rfReplaceAll]);
  Result := True;
End;
Function GetStrValue(Const AText, AName, ADefault: string): string;
Var
  S: string;
Begin
  S := '';
  If HasStrValue(AText, AName, S) Then
    Result := S
  Else
    Result := ADefault;
End;
Function GetIntValue(Const AText, AName: string; ADefault: Integer): Integer;
Var
  S: string;
Begin
  S := GetValue(AText, AName);
  Try
    Result := StrToInt(S);
  Except
    Result := ADefault;
  End;
End;
Function GetFloatValue(Const AText, AName: string; ADefault: Extended): Extended;
Var
  S: string;
Begin
  S := '';
  If HasStrValue(AText, AName, S) Then
  Try
    Result := StrToFloat(S);
  Except
    Result := ADefault;
  End
  Else
    Result := ADefault;
End;
Procedure SetValue(Var AText: string; Const AName, AValue: string);
Var
  P, P2, L: Integer;
Begin
  L := Length(AName) + 2;
  If AText = '' Then
    AText := AName + '="' + AValue + '"'
  Else
  Begin
    P := PosText(AName + '="', AText);
    If P = 0 Then
      AText := AText + ' ' + AName + '="' + AValue + '"'
    Else
    Begin
      P2 := PosStr('"', AText, P + L);
      If P2 = 0 Then
        Exit;
      Delete(AText, P + L, P2 - (P + L));
      Insert(AValue, AText, P + L);
    End;
  End;
End;
Function BackPosStr(Start: Integer; Const FindString, SourceString: string): Integer;
Var
  P, L: Integer;
Begin
  Result := 0;
  L := Length(FindString);
  If (L = 0) or (SourceString = '') or (Start < 2) Then
    Exit;
  Start := Start - L;
  If Start < 1 Then
    Exit;
  Repeat
    P := PosStr(FindString, SourceString, Start);
    If P < Start Then
    Begin
      Result := P;
      Exit;
    End;
    Start := Start - L;
  Until Start < 1;
End;
Function BackPosText(Start: Integer; Const FindString, SourceString: string): Integer;
Var
  P, L, From: Integer;
Begin
  Result := 0;
  L := Length(FindString);
  If (L = 0) or (SourceString = '') or (Start < 2) Then
    Exit;
  From := Start - L;
  If From < 1 Then
    Exit;
  Repeat
    P := PosText(FindString, SourceString, From);
    If P < Start Then
    Begin
      Result := P;
      Exit;
    End;
    From := From - L;
  Until From < 1;
End;
Function PosRangeStr(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
Begin
  Result := False;
  RangeBegin := PosStr(HeadString, SourceString, Start);
  If RangeBegin = 0 Then
    Exit;
  RangeEnd := PosStr(TailString, SourceString, RangeBegin + Length(HeadString));
  If RangeEnd = 0 Then
    Exit;
  RangeEnd := RangeEnd + Length(TailString) - 1;
  Result := True;
End;
Function PosRangeText(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
Begin
  Result := False;
  RangeBegin := PosText(HeadString, SourceString, Start);
  If RangeBegin = 0 Then
    Exit;
  RangeEnd := PosText(TailString, SourceString, RangeBegin + Length(HeadString));
  If RangeEnd = 0 Then
    Exit;
  RangeEnd := RangeEnd + Length(TailString) - 1;
  Result := True;
End;
Function InnerTag(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
Begin
  Result := False;
  RangeBegin := PosText(HeadString, SourceString, Start);
  If RangeBegin = 0 Then
    Exit;
  RangeBegin := RangeBegin + Length(HeadString);
  RangeEnd := PosText(TailString, SourceString, RangeBegin + Length(HeadString));
  If RangeEnd = 0 Then
    Exit;
  RangeEnd := RangeEnd - 1;
  Result := True;
End;
Function PosTag(Start: Integer; SourceString: string; Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
Begin
  Result := PosRangeStr(Start, '<', '>', SourceString, RangeBegin, RangeEnd);
End;
Function BackPosRangeStr(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
Var
  L: Integer;
Begin
  // finds a text range backward, e.g. <TD>....</TD> case sensitive
  Result := False;
  L := Length(HeadString);
  If (L = 0) or (Start < 2) Then
    Exit;
  Start := Start - L;
  If Start < 1 Then
    Exit;
  Repeat
    If not PosRangeStr(Start, HeadString, TailString, SourceString, RangeBegin, RangeEnd) Then
      Exit;
    If RangeBegin < Start Then
    Begin
      Result := True;
      Exit;
    End;
    Start := Start - L;
  Until Start < 1;
End;
Function BackPosRangeText(Start: Integer; Const HeadString, TailString, SourceString: string;
  Var RangeBegin: Integer; Var RangeEnd: Integer): Boolean;
Var
  L: Integer;
Begin
  // finds a text range backward, e.g. <TD>....</TD> case insensitive
  Result := False;
  L := Length(HeadString);
  If (L = 0) or (Start < 2) Then
    Exit;
  Start := Start - L;
  If Start < 1 Then
    Exit;
  Repeat
    If not PosRangeText(Start, HeadString, TailString, SourceString, RangeBegin, RangeEnd) Then
      Exit;
    If RangeBegin < Start Then
    Begin
      Result := True;
      Exit;
    End;
    Start := Start - L;
  Until Start < 1;
End;
Function PosNonSpace(Start: Integer; Const SourceText: string): Integer;
Var
  P, L: Integer;
Begin
  Result := 0;
  L := Length(SourceText);
  P := Start;
  If L = 0 Then
    Exit;
  While (P < L) and (SourceText[P] = ' ') Do
    Inc(P);
  If SourceText[P] <> ' ' Then
    Result := P;
End;
Function BeginOfAttribute(Start: Integer; Const SourceText: string): Integer;
Var
  P, L: Integer;
Begin
  // parses the beginning of an attribute: space + alpha character
  Result := 0;
  L := Length(SourceText);
  If L = 0 Then
    Exit;
  P := PosStr(' ', SourceText, Start);
  If P = 0 Then
    Exit;
  P := PosNonSpace(P, SourceText);
  If P = 0 Then
    Exit;
  If (SourceText[P] in ['a'..'z', 'A'..'Z']) Then
    Result := P;
End;
Function ParseAttribute(Var Start: Integer; Const SourceText: string;
  Var AName, AValue: string): Boolean;
Var
  PN, PV, P: Integer;
Begin
  // parses a name="value" attribute from Start; returns 0 when not found or else the position behind the attribute
  Result := False;
  PN := BeginOfAttribute(Start, SourceText);
  If PN = 0 Then
    Exit;
  P := PosStr('="', SourceText, PN);
  If P = 0 Then
    Exit;
  AName := Trim(Copy(SourceText, PN, P - PN));
  PV := P + 2;
  P := PosStr('"', SourceText, PV);
  If P = 0 Then
    Exit;
  AValue := Copy(SourceText, PV, P - PV);
  Start := P + 1;
  Result := True;
End;
Procedure ParseAttributes(Const SourceText: string; Attributes: TStrings);
Var
  Name, Value: string;
  Start: Integer;
Begin
  Attributes.BeginUpdate;
  Try
    Attributes.Clear;
    Start := 1;
    While ParseAttribute(Start, SourceText, Name, Value) Do
      Attributes.Add(Name + '=' + Value);
  Finally
    Attributes.EndUpdate;
  End;
End;
Function GetToken(Var Start: Integer; Const SourceText: string): string;
Var
  P1, P2: Integer;
Begin
  Result := '';
  If Start > Length(SourceText) Then
    Exit;
  P1 := PosNonSpace(Start, SourceText);
  If P1 = 0 Then
    Exit;
  If SourceText[P1] = '"' Then
  Begin // quoted token
    P2 := PosStr('"', SourceText, P1 + 1);
    If P2 = 0 Then
      Exit;
    Result := Copy(SourceText, P1 + 1, P2 - P1 - 1);
    Start := P2 + 1;
  End
  Else
  Begin
    P2 := PosStr(' ', SourceText, P1 + 1);
    If P2 = 0 Then
      P2 := Length(SourceText) + 1;
    Result := Copy(SourceText, P1, P2 - P1);
    Start := P2;
  End;
End;
Function Easter(NYear: Integer): TDateTime;
Var
  NMonth, NDay, NMoon, NEpact, NSunday, NGold, NCent, NCorX, NCorZ: Integer;
Begin
  { The Golden Number of the year in the 19 year Metonic Cycle }
  NGold := ((NYear mod 19) + 1);
  { Calculate the Century }
  NCent := ((NYear div 100) + 1);
  { No. of Years in which leap year was dropped in order to keep in step
    with the sun }
  NCorX := ((3 * NCent) div 4 - 12);
  { Special Correction to Syncronize Easter with the moon's orbit }
  NCorZ := ((8 * NCent + 5) div 25 - 5);
  { Find Sunday }
  NSunday := ((5 * NYear) div 4 - NCorX - 10);
  { Set Epact (specifies occurance of full moon }
  NEpact := ((11 * NGold + 20 + NCorZ - NCorX) mod 30);
  If (NEpact < 0) Then
    NEpact := NEpact + 30;
  If ((NEpact = 25) and (NGold > 11)) or (NEpact = 24) Then
    NEpact := NEpact + 1;
  { Find Full Moon }
  NMoon := 44 - NEpact;
  If (NMoon < 21) Then
    NMoon := NMoon + 30;
  { Advance to Sunday }
  NMoon := (NMoon + 7 - ((NSunday + NMoon) mod 7));
  If (NMoon > 31) Then
  Begin
    NMonth := 4;
    NDay := (NMoon - 31);
  End
  Else
  Begin
    NMonth := 3;
    NDay := NMoon;
  End;
  Result := EncodeDate(NYear, NMonth, NDay);
End;
//gets a datecode. Returns year and weeknumber in format: YYWW
{DayOfWeek function returns Integer 1..7 equivalent to Sunday..Saturday.
ISO 8601 weeks Start with Monday and the first week of a year is the one which
includes the first Thursday - Fiddle takes care of all this}
Function GetWeekNumber(Today: TDateTime): string;
Const
  Fiddle: array [1..7] Of Byte = (6, 7, 8, 9, 10, 4, 5);
Var
  Present, StartOfYear: TDateTime;
  FirstDayOfYear, WeekNumber, NumberOfDays: Integer;
  Year, Month, Day: Word;
  YearNumber: string;
Begin
  Present := Trunc(Today); //truncate to remove hours, mins and secs
  DecodeDate(Present, Year, Month, Day); //decode to find year
  StartOfYear := EncodeDate(Year, 1, 1); //encode 1st Jan of the year
  //find what day of week 1st Jan is, then add days according to rule
  FirstDayOfYear := Fiddle[DayOfWeek(StartOfYear)];
  //calc number of days since beginning of year + additional according to rule
  NumberOfDays := Trunc(Present - StartOfYear) + FirstDayOfYear;
  //calc number of weeks
  WeekNumber := Trunc(NumberOfDays / 7);
  //Format year, needed to prevent millenium bug and keep the Fluffy Spangle happy
  YearNumber := FormatDateTime('yyyy', Present);
  YearNumber := YearNumber + 'W';
  If WeekNumber < 10 Then
    YearNumber := YearNumber + '0'; //add leading zero for week
  //create datecode string
  Result := YearNumber + IntToStr(WeekNumber);
  If WeekNumber = 0 Then //recursive call for year begin/end...
    //see if previous year end was week 52 or 53
    Result := GetWeekNumber(EncodeDate(Year - 1, 12, 31))
  Else
  If WeekNumber = 53 Then
    //if 31st December less than Thursday then must be week 01 of next year
    If DayOfWeek(EncodeDate(Year, 12, 31)) < 5 Then
    Begin
      YearNumber := FormatDateTime('yyyy', EncodeDate(Year + 1, 1, 1));
      Result := YearNumber + 'W01';
    End;
End;
Function RelativePath(Const ASrc, ADst: string): string;
Var
  Doc, SDoc, ParDoc, Img, SImg, ParImg, Rel: string;
  PDoc, PImg: Integer;
Begin
  Doc := ASrc;
  Img := ADst;
  Repeat
    PDoc := Pos('\', Doc);
    If PDoc > 0 Then
    Begin
      ParDoc := Copy(Doc, 1, PDoc);
      ParDoc[Length(ParDoc)] := '/';
      SDoc := SDoc + ParDoc;
      Delete(Doc, 1, PDoc);
    End;
    PImg := Pos('\', Img);
    If PImg > 0 Then
    Begin
      ParImg := Copy(Img, 1, PImg);
      ParImg[Length(ParImg)] := '/';
      SImg := SImg + ParImg;
      Delete(Img, 1, PImg);
    End;
    If (PDoc > 0) and (PImg > 0) and (SDoc <> SImg) Then
      Rel := '../' + Rel + ParImg;
    If (PDoc = 0) and (PImg <> 0) Then
    Begin
      Rel := Rel + ParImg + Img;
      If Pos(':', Rel) > 0 Then
        Rel := '';
      Result := Rel;
      Exit;
    End;
    If (PDoc > 0) and (PImg = 0) Then
    Begin
      Rel := '../' + Rel;
    End;
  Until (PDoc = 0) and (PImg = 0);
  Rel := Rel + SysUtils.ExtractFileName(Img);
  If Pos(':', Rel) > 0 Then
    Rel := '';
  Result := Rel;
End;
Procedure GetHTMLAnchors(Const AFile: string; AList: TStringList);
Var
  S, SA: string;
  P1, P2: Integer;
Begin
  S := LoadString(AFile);
  P1 := 1;
  Repeat
    P1 := PosText('<a name="', S, P1);
    If P1 <> 0 Then
    Begin
      P2 := PosText('"', S, P1 + 9);
      If P2 <> 0 Then
      Begin
        SA := Copy(S, P1 + 9, P2 - P1 - 9);
        AList.Add(SA);
        P1 := P2;
      End
      Else
        P1 := 0;
    End;
  Until P1 = 0;
End;
Function UppercaseHTMLTags(Const AText: string): string;
Var
  P, P2: Integer;
Begin
  Result := '';
  P2 := 1;
  Repeat
    P := PosStr('<', AText, P2);
    If P > 0 Then
    Begin
      Result := Result + Copy(AText, P2, P - P2);
      P2 := P;
      If Copy(AText, P, 4) = '<!--' Then
      Begin
        P := PosStr('-->', AText, P);
        If P > 0 Then
        Begin
          Result := Result + Copy(AText, P2, P + 3 - P2);
          P2 := P + 3;
        End
        Else
          Result := Result + Copy(AText, P2, Length(AText));
      End
      Else
      Begin
        P := PosStr('>', AText, P);
        If P > 0 Then
        Begin
          Result := Result + UpperCase(Copy(AText, P2, P - P2 + 1));
          P2 := P + 1;
        End
        Else
          Result := Result + Copy(AText, P2, Length(AText));
      End;
    End
    Else
    Begin
      Result := Result + Copy(AText, P2, Length(AText));
    End;
  Until P = 0;
End;
Function LowercaseHTMLTags(Const AText: string): string;
Var
  P, P2: Integer;
Begin
  Result := '';
  P2 := 1;
  Repeat
    P := PosStr('<', AText, P2);
    If P > 0 Then
    Begin
      Result := Result + Copy(AText, P2, P - P2);
      P2 := P;
      // now check for comments
      If Copy(AText, P, 4) = '<!--' Then
      Begin
        P := PosStr('-->', AText, P);
        If P > 0 Then
        Begin
          Result := Result + Copy(AText, P2, P + 3 - P2);
          P2 := P + 3;
        End
        Else
          Result := Result + Copy(AText, P2, Length(AText));
      End
      Else
      Begin
        P := PosStr('>', AText, P);
        If P > 0 Then
        Begin
          Result := Result + LowerCase(Copy(AText, P2, P - P2 + 1));
          P2 := P + 1;
        End
        Else
          Result := Result + Copy(AText, P2, Length(AText));
      End;
    End
    Else
    Begin
      Result := Result + Copy(AText, P2, Length(AText));
    End;
  Until P = 0;
End;
Function PosEscaped(Start: Integer; Const SourceText, FindText: string; EscapeChar: Char): Integer;
Begin
  Result := PosText(FindText, SourceText, Start);
  If Result = 0 Then
    Exit;
  If Result = 1 Then
    Exit;
  If SourceText[Result - 1] <> EscapeChar Then
    Exit;
  Repeat
    Result := PosText(FindText, SourceText, Result + 1);
    If Result = 0 Then
      Exit;
  Until SourceText[Result - 1] <> EscapeChar;
End;
Function DeleteEscaped(Const SourceText: string; EscapeChar: Char): string;
Var
  I: Integer;
  RealLen: Integer;
Begin
  RealLen := 0;
  SetLength(Result, Length(SourceText));
  For I := 1 To Length(SourceText) Do
    If SourceText[I] <> EscapeChar Then
    Begin
      Inc(RealLen);
      Result[RealLen] := SourceText[I];
    End;
  SetLength(Result, RealLen);
End;
Procedure RecurseDirFiles(Const ADir: string; Var AFileList: TStringList);
Var
  SR: TSearchRec;
  FileAttrs: Integer;
Begin
  FileAttrs := faAnyFile or faDirectory;
  If FindFirst(ADir + PathDelim + AllFilePattern, FileAttrs, SR) = 0 Then
    While FindNext(SR) = 0 Do
      If (SR.Attr and faDirectory) <> 0 Then
      Begin
        If (SR.Name <> '.') and (SR.Name <> '..') Then
          RecurseDirFiles(ADir + PathDelim + SR.Name, AFileList);
      End
      Else
        AFileList.Add(ADir + PathDelim + SR.Name);
  FindClose(SR);
End;
Procedure RecurseDirProgs(Const ADir: string; Var AFileList: TStringList);
Var
  SR: TSearchRec;
  FileAttrs: Integer;
  E: string;
  {$IFDEF UNIX}
  ST: TStatBuf;
  {$ENDIF UNIX}
Begin
  FileAttrs := faAnyFile or faDirectory;
  If FindFirst(ADir + PathDelim + AllFilePattern, FileAttrs, SR) = 0 Then
    While FindNext(SR) = 0 Do
    Begin
      If (SR.Attr and faDirectory) <> 0 Then
      Begin
        If (SR.Name <> '.') and (SR.Name <> '..') Then
          RecurseDirProgs(ADir + PathDelim + SR.Name, AFileList);
      End
      {$IFDEF MSWINDOWS}
      Else
      Begin
        E := SysUtils.LowerCase(SysUtils.ExtractFileExt(SR.Name));
        If E = '.exe' Then
          AFileList.Add(ADir + PathDelim + SR.Name);
      End;
      {$ENDIF MSWINDOWS}
      {$IFDEF UNIX}
      Else
      Begin
        If stat(PChar(ADir + PathDelim + SR.Name), ST) = 0 Then
        Begin
          If ST.st_mode and (S_IXUSR or S_IXGRP or S_IXOTH) <> 0 Then
            AFileList.Add(ADir + PathDelim + SR.Name);
        End;
      End;
      {$ENDIF UNIX}
    End;
  FindClose(SR);
End;
Procedure LoadResourceFile(AFile: string; MemStream: TMemoryStream);
Var
  ResStream: TResourceStream;
  Ext: string;
Begin
  Ext := SysUtils.UpperCase(SysUtils.ExtractFileExt(AFile));
  Ext := Copy(Ext, 2, Length(Ext));
  If Ext = 'HTM' Then
    Ext := 'HTML';
  AFile := SysUtils.ChangeFileExt(AFile, '');
  ResStream := TResourceStream.Create(HInstance, PChar(AFile), PChar(Ext));
  Try
    MemStream.CopyFrom(ResStream, ResStream.Size);
  Finally
    ResStream.Free;
  End;
End;
Procedure GetNames(AText: string; AList: TStringList);
Var
  P: Integer;
  S: string;
Begin
  AList.Clear;
  Repeat
    AText := Trim(AText);
    P := Pos('="', AText);
    If P > 0 Then
    Begin
      S := Copy(AText, 1, P - 1);
      AList.Add(S);
      Delete(AText, 1, P + 1);
      P := Pos('"', AText);
      If P > 0 Then
        Delete(AText, 1, P);
    End;
  Until P = 0;
End;
Function NameValuesToXML(Const AText: string): string;
Var
  AList: TStringList;
  I, C: Integer;
  IName, IValue, Xml: string;
Begin
  Result := '';
  If AText = '' Then
    Exit;
  AList := TStringList.Create;
  GetNames(AText, AList);
  C := AList.Count;
  If C = 0 Then
  Begin
    AList.Free;
    Exit
  End;
  Xml := '<accountdata>' + Cr;
  For I := 0 To C - 1 Do
  Begin
    IName := AList[I];
    IValue := GetValue(AText, IName);
    IValue := SysUtils.StringReplace(IValue, '~~', Cr, [rfReplaceAll]);
    Xml := Xml + '<' + IName + '>' + Cr;
    Xml := Xml + '  ' + IValue + Cr;
    Xml := Xml + '</' + IName + '>' + Cr;
  End;
  Xml := Xml + '</accountdata>' + Cr;
  AList.Free;
  Result := Xml;
End;
Function LastPosChar(Const FindChar: Char; SourceString: string): Integer;
Var
  I: Integer;
Begin
  I := Length(SourceString);
  While (I > 0) and (SourceString[I] <> FindChar) Do
    Dec(I);
  Result := I;
End;
Function PosStr(Const FindString, SourceString: string; StartPos: Integer): Integer;
Var
  P: PChar;
Begin
  Result := 0;
  If (FindString <> '') and (SourceString <> '') and (StartPos <= Length(SourceString)) Then
  Begin
    P := StrPos(PChar(SourceString) + StartPos - 1, PChar(FindString));
    If P <> nil Then
      Result := P - PChar(SourceString) + 1;
  End;
End;
Function PosText(Const FindString, SourceString: string; StartPos: Integer): Integer;
Begin
  // Not the fastest implementation but the JCL doesn't have a better one, either.
  Result := Pos(UpperCase(FindString), UpperCase(Copy(SourceString, StartPos, MaxInt)));
  If Result <> 0 Then
    Result := Result + StartPos - 1;
End;
Function GetBoolValue(Const AText, AName: string): Boolean;
Begin
  Result := CompareText(GetValue(AText, AName), 'yes') = 0;
End;
Procedure ListSelect(Src, Dst: TStringList; Const AKey, AValue: string);
Var
  I: Integer;
Begin
  Dst.Clear;
  For I := 0 To Src.Count - 1 Do
  Begin
    If GetValue(Src[I], AKey) = AValue Then
      Dst.Add(Src[I]);
  End;
End;
Procedure ListFilter(Src: TStringList; Const AKey, AValue: string);
Var
  I: Integer;
  Dst: TStringList;
Begin
  Dst := TStringList.Create;
  For I := 0 To Src.Count - 1 Do
  Begin
    If GetValue(Src[I], AKey) = AValue Then
      Dst.Add(Src[I]);
  End;
  Src.Assign(Dst);
  Dst.Free;
End;
Procedure ListOrderBy(Src: TStringList; Const AKey: string; Numeric: Boolean);
Var
  I, Index: Integer;
  Lit, Dst: TStringList;
  S: string;
  IValue: Integer;
Begin
  If Src.Count < 2 Then
    Exit; // nothing to sort
  Lit := TStringList.Create;
  Dst := TStringList.Create;
  For I := 0 To Src.Count - 1 Do
  Begin
    S := GetValue(Src[I], AKey);
    If Numeric Then
    Try
      IValue := StrToInt(S);
      // format to 5 decimal places for correct string sorting
      // e.g. 5 becomes 00005
      S := Format('%5.5d', [IValue]);
    Except
      // just use the unformatted value
    End;
    {$IFNDEF FPC}
     Lit.AddObject(S, TObject(I));
    {$ELSE}
     Lit.AddObject(S, TObject(@I));
    {$ENDIF}
  End;
  Lit.Sort;
  For I := 0 To Src.Count - 1 Do
  Begin
   {$IFNDEF FPC}
    Index := Integer(Lit.Objects[I]);
   {$ELSE}
    Index := PInteger(Lit.Objects[I])^;
   {$ENDIF}
    Dst.Add(Src[Index]);
  End;
  Lit.Free;
  Src.Assign(Dst);
  Dst.Free;
End;
// converts a csv list to a tagged string list
Procedure CSVToTags(Src, Dst: TStringList);
Var
  I, FI, FC: Integer;
  Names: TStringList;
  Rec: TStringList;
  S: string;
Begin
  Dst.Clear;
  If Src.Count < 2 Then
    Exit;
  Names := TStringList.Create;
  Rec := TStringList.Create;
  Try
    Names.CommaText := Src[0];
    FC := Names.Count;
    If FC > 0 Then
      For I := 1 To Src.Count - 1 Do
      Begin
        Rec.CommaText := Src[I];
        S := '';
        For FI := 0 To FC - 1 Do
          S := S + Names[FI] + '="' + Rec[FI] + '" ';
        Dst.Add(S);
      End;
  Finally
    Rec.Free;
    Names.Free;
  End;
End;
// converts a tagged string list to a csv list
// only fieldnames from the first record are scanned ib the other records
Procedure TagsToCSV(Src, Dst: TStringList);
Var
  I, FI, FC: Integer;
  Names: TStringList;
  Rec: TStringList;
  S: string;
Begin
  Dst.Clear;
  If Src.Count < 1 Then
    Exit;
  Names := TStringList.Create;
  Rec := TStringList.Create;
  Try
    GetNames(Src[0], Names);
    FC := Names.Count;
    If FC > 0 Then
    Begin
      Dst.Add(Names.CommaText);
      For I := 0 To Src.Count - 1 Do
      Begin
        S := '';
        Rec.Clear;
        For FI := 0 To FC - 1 Do
          Rec.Add(GetValue(Src[I], Names[FI]));
        Dst.Add(Rec.CommaText);
      End;
    End;
  Finally
    Rec.Free;
    Names.Free;
  End;
End;
Function B64Encode(Const S: AnsiString): AnsiString;
Var
  I: Integer;
  InBuf: array [0..2] Of Byte;
  OutBuf: array [0..3] Of AnsiChar;
Begin
  SetLength(Result, ((Length(S) + 2) div 3) * 4);
  For I := 1 To ((Length(S) + 2) div 3) Do
  Begin
    If Length(S) < (I * 3) Then
      Move(S[(I - 1) * 3 + 1], InBuf, Length(S) - (I - 1) * 3)
    Else
      Move(S[(I - 1) * 3 + 1], InBuf, 3);
    OutBuf[0] := B64Table[((InBuf[0] and $FC) shr 2) + 1];
    OutBuf[1] := B64Table[(((InBuf[0] and $03) shl 4) or ((InBuf[1] and $F0) shr 4)) + 1];
    OutBuf[2] := B64Table[(((InBuf[1] and $0F) shl 2) or ((InBuf[2] and $C0) shr 6)) + 1];
    OutBuf[3] := B64Table[(InBuf[2] and $3F) + 1];
    Move(OutBuf, Result[(I - 1) * 4 + 1], 4);
  End;
  If (Length(S) mod 3) = 1 Then
  Begin
    Result[Length(Result) - 1] := '=';
    Result[Length(Result)] := '=';
  End
  Else
  If (Length(S) mod 3) = 2 Then
    Result[Length(Result)] := '=';
End;
Function B64Decode(Const S: AnsiString): AnsiString;
Var
  I: Integer;
  InBuf: array [0..3] Of Byte;
  OutBuf: array [0..2] Of Byte;
  RetValue: AnsiString;
Begin
  If ((Length(S) mod 4) <> 0) or (S = '') Then
    raise EJVCLException.CreateRes({$IFNDEF CLR}@{$ENDIF}RsEIncorrectStringFormat);
  SetLength(RetValue, ((Length(S) div 4) - 1) * 3);
  For I := 1 To ((Length(S) div 4) - 1) Do
  Begin
    Move(S[(I - 1) * 4 + 1], InBuf, 4);
    If (InBuf[0] > 64) and (InBuf[0] < 91) Then
      Dec(InBuf[0], 65)
    Else
    If (InBuf[0] > 96) and (InBuf[0] < 123) Then
      Dec(InBuf[0], 71)
    Else
    If (InBuf[0] > 47) and (InBuf[0] < 58) Then
      Inc(InBuf[0], 4)
    Else
    If InBuf[0] = 43 Then
      InBuf[0] := 62
    Else
      InBuf[0] := 63;
    If (InBuf[1] > 64) and (InBuf[1] < 91) Then
      Dec(InBuf[1], 65)
    Else
    If (InBuf[1] > 96) and (InBuf[1] < 123) Then
      Dec(InBuf[1], 71)
    Else
    If (InBuf[1] > 47) and (InBuf[1] < 58) Then
      Inc(InBuf[1], 4)
    Else
    If InBuf[1] = 43 Then
      InBuf[1] := 62
    Else
      InBuf[1] := 63;
    If (InBuf[2] > 64) and (InBuf[2] < 91) Then
      Dec(InBuf[2], 65)
    Else
    If (InBuf[2] > 96) and (InBuf[2] < 123) Then
      Dec(InBuf[2], 71)
    Else
    If (InBuf[2] > 47) and (InBuf[2] < 58) Then
      Inc(InBuf[2], 4)
    Else
    If InBuf[2] = 43 Then
      InBuf[2] := 62
    Else
      InBuf[2] := 63;
    If (InBuf[3] > 64) and (InBuf[3] < 91) Then
      Dec(InBuf[3], 65)
    Else
    If (InBuf[3] > 96) and (InBuf[3] < 123) Then
      Dec(InBuf[3], 71)
    Else
    If (InBuf[3] > 47) and (InBuf[3] < 58) Then
      Inc(InBuf[3], 4)
    Else
    If InBuf[3] = 43 Then
      InBuf[3] := 62
    Else
      InBuf[3] := 63;
    OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);
    OutBuf[1] := (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $0F);
    OutBuf[2] := (InBuf[2] shl 6) or (InBuf[3] and $3F);
    Move(OutBuf, RetValue[(I - 1) * 3 + 1], 3);
  End;
  If S <> '' Then
  Begin
    Move(S[Length(S) - 3], InBuf, 4);
    If InBuf[2] = 61 Then
    Begin
      If (InBuf[0] > 64) and (InBuf[0] < 91) Then
        Dec(InBuf[0], 65)
      Else
      If (InBuf[0] > 96) and (InBuf[0] < 123) Then
        Dec(InBuf[0], 71)
      Else
      If (InBuf[0] > 47) and (InBuf[0] < 58) Then
        Inc(InBuf[0], 4)
      Else
      If InBuf[0] = 43 Then
        InBuf[0] := 62
      Else
        InBuf[0] := 63;
      If (InBuf[1] > 64) and (InBuf[1] < 91) Then
        Dec(InBuf[1], 65)
      Else
      If (InBuf[1] > 96) and (InBuf[1] < 123) Then
        Dec(InBuf[1], 71)
      Else
      If (InBuf[1] > 47) and (InBuf[1] < 58) Then
        Inc(InBuf[1], 4)
      Else
      If InBuf[1] = 43 Then
        InBuf[1] := 62
      Else
        InBuf[1] := 63;
      OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);
      RetValue := RetValue + AnsiChar(OutBuf[0]);
    End
    Else
    If InBuf[3] = 61 Then
    Begin
      If (InBuf[0] > 64) and (InBuf[0] < 91) Then
        Dec(InBuf[0], 65)
      Else
      If (InBuf[0] > 96) and (InBuf[0] < 123) Then
        Dec(InBuf[0], 71)
      Else
      If (InBuf[0] > 47) and (InBuf[0] < 58) Then
        Inc(InBuf[0], 4)
      Else
      If InBuf[0] = 43 Then
        InBuf[0] := 62
      Else
        InBuf[0] := 63;
      If (InBuf[1] > 64) and (InBuf[1] < 91) Then
        Dec(InBuf[1], 65)
      Else
      If (InBuf[1] > 96) and (InBuf[1] < 123) Then
        Dec(InBuf[1], 71)
      Else
      If (InBuf[1] > 47) and (InBuf[1] < 58) Then
        Inc(InBuf[1], 4)
      Else
      If InBuf[1] = 43 Then
        InBuf[1] := 62
      Else
        InBuf[1] := 63;
      If (InBuf[2] > 64) and (InBuf[2] < 91) Then
        Dec(InBuf[2], 65)
      Else
      If (InBuf[2] > 96) and (InBuf[2] < 123) Then
        Dec(InBuf[2], 71)
      Else
      If (InBuf[2] > 47) and (InBuf[2] < 58) Then
        Inc(InBuf[2], 4)
      Else
      If InBuf[2] = 43 Then
        InBuf[2] := 62
      Else
        InBuf[2] := 63;
      OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);
      OutBuf[1] := (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $0F);
      RetValue := RetValue + AnsiChar(OutBuf[0]) + AnsiChar(OutBuf[1]);
    End
    Else
    Begin
      If (InBuf[0] > 64) and (InBuf[0] < 91) Then
        Dec(InBuf[0], 65)
      Else
      If (InBuf[0] > 96) and (InBuf[0] < 123) Then
        Dec(InBuf[0], 71)
      Else
      If (InBuf[0] > 47) and (InBuf[0] < 58) Then
        Inc(InBuf[0], 4)
      Else
      If InBuf[0] = 43 Then
        InBuf[0] := 62
      Else
        InBuf[0] := 63;
      If (InBuf[1] > 64) and (InBuf[1] < 91) Then
        Dec(InBuf[1], 65)
      Else
      If (InBuf[1] > 96) and (InBuf[1] < 123) Then
        Dec(InBuf[1], 71)
      Else
      If (InBuf[1] > 47) and (InBuf[1] < 58) Then
        Inc(InBuf[1], 4)
      Else
      If InBuf[1] = 43 Then
        InBuf[1] := 62
      Else
        InBuf[1] := 63;
      If (InBuf[2] > 64) and (InBuf[2] < 91) Then
        Dec(InBuf[2], 65)
      Else
      If (InBuf[2] > 96) and (InBuf[2] < 123) Then
        Dec(InBuf[2], 71)
      Else
      If (InBuf[2] > 47) and (InBuf[2] < 58) Then
        Inc(InBuf[2], 4)
      Else
      If InBuf[2] = 43 Then
        InBuf[2] := 62
      Else
        InBuf[2] := 63;
      If (InBuf[3] > 64) and (InBuf[3] < 91) Then
        Dec(InBuf[3], 65)
      Else
      If (InBuf[3] > 96) and (InBuf[3] < 123) Then
        Dec(InBuf[3], 71)
      Else
      If (InBuf[3] > 47) and (InBuf[3] < 58) Then
        Inc(InBuf[3], 4)
      Else
      If InBuf[3] = 43 Then
        InBuf[3] := 62
      Else
        InBuf[3] := 63;
      OutBuf[0] := (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);
      OutBuf[1] := (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $0F);
      OutBuf[2] := (InBuf[2] shl 6) or (InBuf[3] and $3F);
      RetValue := RetValue + AnsiChar(OutBuf[0]) + AnsiChar(OutBuf[1]) + AnsiChar(OutBuf[2]);
    End;
  End;
  Result := RetValue;
End;
{*******************************************************
 * Standard Encryption algorithm - Copied from Borland *
 *******************************************************}
Function Encrypt(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
Var
  I: Integer;
Begin
  Result := '';
  For I := 1 To Length(InString) Do
  Begin
    Result := Result + AnsiChar(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(Result[I]) + StartKey) * MultKey + AddKey;
  End;
End;
{*******************************************************
 * Standard Decryption algorithm - Copied from Borland *
 *******************************************************}
Function Decrypt(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
Var
  I: Integer;
Begin
  Result := '';
  For I := 1 To Length(InString) Do
  Begin
    Result := Result + AnsiChar(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(InString[I]) + StartKey) * MultKey + AddKey;
  End;
End;
Function EncryptB64(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
Begin
  Result := B64Encode(Encrypt(InString, StartKey, MultKey, AddKey));
End;
Function DecryptB64(Const InString: AnsiString; StartKey, MultKey, AddKey: Integer): AnsiString;
Begin
  Result := Decrypt(B64Decode(InString), StartKey, MultKey, AddKey);
End;
Function Hash(Const AText: string): Integer;
Var
  I: Integer;
Begin
  Result := 0;
  If AText = '' Then
    Exit;
  Result := Ord(AText[1]);
  For I := 2 To Length(AText) Do
    Result := (Result * Ord(AText[I])) xor Result;
End;

Function FirstOfSet(Const AText: string): string;
Var
  P: Integer;
Begin
  Result := Trim(AText);
  If Result = '' Then
    Exit;
  If Result[1] = '"' Then
  Begin
    P := PosStr('"', Result, 2);
    Result := Copy(Result, 2, P - 2);
  End
  Else
  Begin
    P := Pos(' ', Result);
    Result := Copy(Result, 1, P - 1);
  End;
End;
Function LastOfSet(Const AText: string): string;
Var
  C: Integer;
Begin
  Result := Trim(AText);
  If Result = '' Then
    Exit;
  C := Length(Result);
  If Result[C] = '"' Then
  Begin
    While (C > 1) and (Result[C - 1] <> '"') Do
      Dec(C);
    Result := Copy(Result, C, Length(Result) - C);
  End
  Else
  Begin
    While (C > 1) and (Result[C - 1] <> ' ') Do
      Dec(C);
    Result := Copy(Result, C, Length(Result));
  End;
End;
Function CountOfSet(Const AText: string): Integer;
Var
  Lit: TStringList;
Begin
  Lit := TStringList.Create;
  SplitSet(AText, Lit);
  Result := Lit.Count;
  Lit.Free;
End;
Function SetRotateRight(Const AText: string): string;
Var
  Lit: TStringList;
  C: Integer;
Begin
  Lit := TStringList.Create;
  SplitSet(AText, Lit);
  C := Lit.Count;
  If C > 0 Then
  Begin
    Lit.Move(C - 1, 0);
    Result := JoinSet(Lit);
  End
  Else
    Result := '';
  Lit.Free;
End;
Function SetRotateLeft(Const AText: string): string;
Var
  Lit: TStringList;
  C: Integer;
Begin
  Lit := TStringList.Create;
  SplitSet(AText, Lit);
  C := Lit.Count;
  If C > 0 Then
  Begin
    Lit.Move(0, C - 1);
    Result := JoinSet(Lit);
  End
  Else
    Result := '';
  Lit.Free;
End;
Procedure SplitSet(AText: string; AList: TStringList);
Var
  P: Integer;
Begin
  AList.Clear;
  If AText = '' Then
    Exit;
  AText := Trim(AText);
  While AText <> '' Do
  Begin
    If AText[1] = '"' Then
    Begin
      Delete(AText, 1, 1);
      P := Pos('"', AText);
      If P <> 0 Then
      Begin
        AList.Add(Copy(AText, 1, P - 1));
        Delete(AText, 1, P);
      End;
    End
    Else
    Begin
      P := Pos(' ', AText);
      If P = 0 Then
      Begin
        AList.Add(AText);
        AText := '';
      End
      Else
      Begin
        AList.Add(Copy(AText, 1, P - 1));
        Delete(AText, 1, P);
      End;
    End;
    AText := Trim(AText);
  End;
End;
Function JoinSet(AList: TStringList): string;
Var
  I: Integer;
Begin
  Result := '';
  For I := 0 To AList.Count - 1 Do
    Result := Result + AList[I] + ' ';
  Delete(Result, Length(Result), 1);
End;
Function SetPick(Const AText: string; AIndex: Integer): string;
Var
  Lit: TStringList;
  C: Integer;
Begin
  Lit := TStringList.Create;
  SplitSet(AText, Lit);
  C := Lit.Count;
  If (C > 0) and (AIndex < C) Then
    Result := Lit[AIndex]
  Else
    Result := '';
  Lit.Free;
End;
Function SetSort(Const AText: string): string;
Var
  Lit: TStringList;
Begin
  Lit := TStringList.Create;
  SplitSet(AText, Lit);
  If Lit.Count > 0 Then
  Begin
    Lit.Sort;
    Result := JoinSet(Lit);
  End
  Else
    Result := '';
  Lit.Free;
End;
Function SetUnion(Const Set1, Set2: string): string;
Var
  Lit1, Lit2, Lit3: TStringList;
  I, C: Integer;
Begin
  Lit1 := TStringList.Create;
  Lit2 := TStringList.Create;
  Lit3 := TStringList.Create;
  SplitSet(Set1, Lit1);
  SplitSet(Set2, Lit2);
  C := Lit2.Count;
  If C <> 0 Then
  Begin
    Lit2.Addstrings(Lit1);
    For I := 0 To Lit2.Count - 1 Do
      If Lit3.IndexOf(Lit2[I]) = -1 Then
        Lit3.Add(Lit2[I]);
    Result := JoinSet(Lit3);
  End
  Else
  Begin
    Result := JoinSet(Lit1);
  End;
  Lit1.Free;
  Lit2.Free;
  Lit3.Free;
End;
Function SetIntersect(Const Set1, Set2: string): string;
Var
  Lit1, Lit2, Lit3: TStringList;
  I: Integer;
Begin
  Lit1 := TStringList.Create;
  Lit2 := TStringList.Create;
  Lit3 := TStringList.Create;
  SplitSet(Set1, Lit1);
  SplitSet(Set2, Lit2);
  If Lit2.Count <> 0 Then
  Begin
    For I := 0 To Lit2.Count - 1 Do
      If Lit1.IndexOf(Lit2[I]) <> -1 Then
        Lit3.Add(Lit2[I]);
    Result := JoinSet(Lit3);
  End
  Else
    Result := '';
  Lit1.Free;
  Lit2.Free;
  Lit3.Free;
End;
Function SetExclude(Const Set1, Set2: string): string;
Var
  Lit1, Lit2: TStringList;
  I, Index: Integer;
Begin
  Lit1 := TStringList.Create;
  Lit2 := TStringList.Create;
  SplitSet(Set1, Lit1);
  SplitSet(Set2, Lit2);
  If Lit2.Count <> 0 Then
  Begin
    For I := 0 To Lit2.Count - 1 Do
    Begin
      Index := Lit1.IndexOf(Lit2[I]);
      If Index <> -1 Then
        Lit1.Delete(Index);
    End;
    Result := JoinSet(Lit1);
  End
  Else
    Result := JoinSet(Lit1);
  Lit1.Free;
  Lit2.Free;
End;
// This function converts a string into a RFC 1630 compliant URL
Function URLEncode(Const Value: AnsiString): AnsiString;
Var
  I: Integer;
Begin
  Result := '';
  For I := 1 To Length(Value) Do
    If Pos(UpperCase(Value[I]), ValidURLChars) > 0 Then
      Result := Result + Value[I]
    Else
    Begin
      If Value[I] = ' ' Then
        Result := Result + '+'
      Else
      Begin
        Result := Result + '%';
        Result := Result + AnsiString(IntToHex(Byte(Value[I]), 2));
      End;
    End;
End;
Function URLDecode(Const Value: AnsiString): AnsiString;
Const
  HexChars: AnsiString = '0123456789ABCDEF';
Var
  I: Integer;
  Ch, H1, H2: AnsiChar;
  Len: Integer;
Begin
  Result := '';
  Len := Length(Value);
  I := 1;
  While I <= Len Do
  Begin
    Ch := Value[I];
    Case Ch Of
      '%':
        Begin
          H1 := Value[I + 1];
          H2 := Value[I + 2];
          Inc(I, 2);
          Result := Result + AnsiChar(Chr((({$IFDEF SUPPORTS_UNICODE}AnsiPos{$ELSE}Pos{$ENDIF SUPPORTS_UNICODE}(H1, HexChars) - 1) * 16) +
                                           ({$IFDEF SUPPORTS_UNICODE}AnsiPos{$ELSE}Pos{$ENDIF SUPPORTS_UNICODE}(H2, HexChars) - 1)));
        End;
      '+':
        Result := Result + ' ';
      '&':
        Result := Result + CrLf;
    Else
      Result := Result + Ch;
    End;
    Inc(I);
  End;
End;
{template functions}
Function ReplaceFirst(Const SourceStr, FindStr, ReplaceStr: string): string;
Var
  P: Integer;
Begin
  Result := SourceStr;
  P := PosText(FindStr, SourceStr, 1);
  If P <> 0 Then
    Result := Copy(SourceStr, 1, P - 1) + ReplaceStr + Copy(SourceStr, P + Length(FindStr), Length(SourceStr));
End;
Function ReplaceLast(Const SourceStr, FindStr, ReplaceStr: string): string;
Var
  P: Integer;
Begin
  Result := SourceStr;
  P := PosTextLast(FindStr, SourceStr);
  If P <> 0 Then
    Result := Copy(SourceStr, 1, P - 1) + ReplaceStr + Copy(SourceStr, P + Length(FindStr), Length(SourceStr));
End;
// insert a block template
// the last occurance of {block:aBlockname}
// the block template is marked with {begin:aBlockname} and {end:aBlockname}
Function InsertLastBlock(Var SourceStr: string; BlockStr: string): Boolean;
Var
  // phead: Integer;
  PBlock, PE, PB: Integer;
  SBB, SBE, SB, SBR: string;
  SBBL, SBEL: Integer;
Begin
  Result := False;
  //  phead:= PosStr('</head>',SourceStr,1);
  //  If phead = 0 Then Exit;
  //  phead:= phead + 7;
  SB := '{block:' + BlockStr + '}';
  //  sbL:=Length(SB);
  SBB := '{begin:' + BlockStr + '}';
  SBBL := Length(SBB);
  SBE := '{end:' + BlockStr + '}';
  SBEL := Length(SBE);
  PBlock := PosTextLast(SB, SourceStr);
  If PBlock = 0 Then
    Exit;
  PB := PosText(SBB, SourceStr, 1);
  If PB = 0 Then
    Exit;
  PE := PosText(SBE, SourceStr, PB);
  If PE = 0 Then
    Exit;
  PE := PE + SBEL - 1;
  // now replace
  SBR := Copy(SourceStr, PB + SBBL, PE - PB - SBBL - SBEL + 1);
  SourceStr := Copy(SourceStr, 1, PBlock - 1) + SBR + Copy(SourceStr, PBlock, Length(SourceStr));
  Result := True;
End;
// removes all  {begin:somefield} to {end:somefield} from ASource
Function RemoveMasterBlocks(Const SourceStr: string): string;
Var
  S, Src: string;
  PB: Integer;
  PE: Integer;
  PEE: Integer;
Begin
  S := '';
  Src := SourceStr;
  Repeat
    PB := PosText('{begin:', Src);
    If PB > 0 Then
    Begin
      PE := PosText('{end:', Src, PB);
      If PE > 0 Then
      Begin
        PEE := PosStr('}', Src, PE);
        If PEE > 0 Then
        Begin
          S := S + Copy(Src, 1, PB - 1);
          Delete(Src, 1, PEE);
        End;
      End;
    End;
  Until PB = 0;
  Result := S + Src;
End;
// removes all {field} entries in a template
Function RemoveFields(Const SourceStr: string): string;
Var
  Src, S: string;
  PB: Integer;
  PE: Integer;
Begin
  S := '';
  Src := SourceStr;
  Repeat
    PB := Pos('{', Src);
    If PB > 0 Then
    Begin
      PE := Pos('}', Src);
      If PE > 0 Then
      Begin
        S := S + Copy(Src, 1, PB - 1);
        Delete(Src, 1, PE);
      End;
    End;
  Until PB = 0;
  Result := S + Src;
End;
{finds the last occurance}
Function PosStrLast(Const FindString, SourceString: string): Integer;
Var
  I, L: Integer;
Begin
  Result := 0;
  L := Length(FindString);
  If L = 0 Then
    Exit;
  I := Length(SourceString);
  If I = 0 Then
    Exit;
  I := I - L + 1;
  While I > 0 Do
  Begin
    Result := PosStr(FindString, SourceString, I);
    If Result > 0 Then
      Exit;
    I := I - L;
  End;
End;
{finds the last occurance}
Function PosTextLast(Const FindString, SourceString: string): Integer;
Var
  I, L: Integer;
Begin
  Result := 0;
  L := Length(FindString);
  If L = 0 Then
    Exit;
  I := Length(SourceString);
  If I = 0 Then
    Exit;
  I := I - L + 1;
  While I > 0 Do
  Begin
    Result := PosText(FindString, SourceString, I);
    If Result > 0 Then
      Exit;
    I := I - L;
  End;
End;
Procedure DirFiles(Const ADir, AMask: string; AFileList: TStringList);
Var
  SR: TSearchRec;
  FileAttrs: Integer;
Begin
  FileAttrs := faArchive + faDirectory;
  If FindFirst(ADir + AMask, FileAttrs, SR) = 0 Then
    While FindNext(SR) = 0 Do
      If (SR.Attr and faArchive) <> 0 Then
        AFileList.Add(ADir + SR.Name);
  FindClose(SR);
End;
// parse number returns the last position, starting from 1
Function ParseNumber(Const S: string): Integer;
Var
  I, E, E2, C: Integer;
Begin
  Result := 0;
  I := 0;
  C := Length(S);
  If C = 0 Then
    Exit;
  While (I + 1 <= C) and (S[I + 1] in DigitChars + [',', '.']) Do
    Inc(I);
  If (I + 1 <= C) and (S[I + 1] in ['e', 'E']) Then
  Begin
    E := I;
    Inc(I);
    If (I + 1 <= C) and (S[I + 1] in ['+', '-']) Then
      Inc(I);
    E2 := I;
    While (I + 1 <= C) and (S[I + 1] in DigitChars) Do
      Inc(I);
    If I = E2 Then
      I := E;
  End;
  Result := I;
End;
// parse a SQL style data string from positions 1,
// starts and ends with #
Function ParseDate(Const S: string): Integer;
Var
  P: Integer;
Begin
  Result := 0;
  If Length(S) < 2 Then
    Exit;
  P := PosStr('#', S, 2);
  If P <> 0 Then
    Try
      StrToDate(Copy(S, 2, P - 2));
      Result := P;
    Except
      Result := 0;
    End;
End;
{$IFDEF UNITVERSIONING}
Initialization
 RegisterUnitVersion(HInstance, UnitVersioning);
Finalization
 UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
End.
