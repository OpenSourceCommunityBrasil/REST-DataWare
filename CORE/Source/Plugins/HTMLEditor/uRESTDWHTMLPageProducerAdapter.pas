unit uRESTDWHTMLPageProducerAdapter;
{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}
interface
uses
  Classes, SysUtils, StrUtils, IniFiles,
  uRESTDWServerContext;
type
  TRESTDWHTMLLibraryMode = (lmLocal, lmURL);
  TRESTDWHTMLPageProducerAdapter = class(TComponent)
  private
    FContextRules : TRESTDWContextRules;
    FRoute : String;
    FTitle : String;
    FHTML : TStrings;
    FCSS : TStrings;
    FJavaScript : TStrings;
    FLibrariesPath : String;
    FLibraryMode : TRESTDWHTMLLibraryMode;
    FLibraryURL : String;
    FAutoDataTables : Boolean;
    FAutoCharts : Boolean;
    FOriginalIncludeScripts : TStrings;
    procedure SetHTML(AValue : TStrings);
    procedure SetCSS(AValue : TStrings);
    procedure SetJavaScript(AValue : TStrings);
    function ExtractBetween(const AText, AStart, AEnd : String) : String;
    function RPos(const ASub, AText : String) : Integer;
    procedure LoadContextDocument;
  public
    constructor CreateForContext(AContextRules : TRESTDWContextRules);
    destructor Destroy; override;
    function Produce : String;
    function LibraryRoot : String;
    function ResolveLibrariesPath : String;
    function LocalHTMLLibrariesPath : String;
    function ContextLibraryRoot : String;
    procedure SaveToContextRules;
    property ContextRules : TRESTDWContextRules read FContextRules;
    property Route : String read FRoute write FRoute;
    property Title : String read FTitle write FTitle;
    property HTML : TStrings read FHTML write SetHTML;
    property CSS : TStrings read FCSS write SetCSS;
    property JavaScript : TStrings read FJavaScript write SetJavaScript;
    property LibrariesPath : String read FLibrariesPath write FLibrariesPath;
    property LibraryMode : TRESTDWHTMLLibraryMode read FLibraryMode write FLibraryMode;
    property LibraryURL : String read FLibraryURL write FLibraryURL;
    property AutoDataTables : Boolean read FAutoDataTables write FAutoDataTables;
    property AutoCharts : Boolean read FAutoCharts write FAutoCharts;
  end;
implementation
constructor TRESTDWHTMLPageProducerAdapter.CreateForContext(
 AContextRules : TRESTDWContextRules);
begin
  inherited Create(nil);
  FContextRules := AContextRules;
  FHTML := TStringList.Create;
  FCSS := TStringList.Create;
  FJavaScript := TStringList.Create;
  FOriginalIncludeScripts := TStringList.Create;
  FRoute := '/';
  FTitle := 'REST Dataware';
  {$IFDEF FPC}
  FLibrariesPath := 'Packages\Lazarus\html\libs';
  {$ELSE}
  FLibrariesPath := 'html\libs';
  {$ENDIF}
  FLibraryMode := lmLocal;
  FLibraryURL := './libs';
  FAutoDataTables := True;
  FAutoCharts := True;
  if FContextRules <> nil then
    FOriginalIncludeScripts.Assign(FContextRules.IncludeScripts);
  LoadContextDocument;
end;
destructor TRESTDWHTMLPageProducerAdapter.Destroy;
begin
  FOriginalIncludeScripts.Free;
  FJavaScript.Free;
  FCSS.Free;
  FHTML.Free;
  inherited Destroy;
end;
procedure TRESTDWHTMLPageProducerAdapter.SetHTML(AValue : TStrings);
begin
  FHTML.Assign(AValue);
end;
procedure TRESTDWHTMLPageProducerAdapter.SetCSS(AValue : TStrings);
begin
  FCSS.Assign(AValue);
end;
procedure TRESTDWHTMLPageProducerAdapter.SetJavaScript(AValue : TStrings);
begin
  FJavaScript.Assign(AValue);
end;
function TRESTDWHTMLPageProducerAdapter.ExtractBetween(
 const AText, AStart, AEnd : String) : String;
var
  P1, P2 : Integer;
begin
  Result := '';
  P1 := Pos(LowerCase(AStart), LowerCase(AText));
  if P1 = 0 then
    Exit;
  Inc(P1, Length(AStart));
  P2 := PosEx(LowerCase(AEnd), LowerCase(AText), P1);
  if P2 = 0 then
    Exit;
  Result := Copy(AText, P1, P2 - P1);
end;
function TRESTDWHTMLPageProducerAdapter.RPos(
 const ASub, AText : String) : Integer;
var
 P, Offset : Integer;
begin
 Result := 0;
 Offset := 1;
 repeat
  P := PosEx(ASub, AText, Offset);
  if P > 0 then
  begin
   Result := P;
   Offset := P + 1;
  end;
 until P = 0;
end;
procedure TRESTDWHTMLPageProducerAdapter.LoadContextDocument;
var
  T, B, C, S, L, J : String;
  P1, P2, PStart, PEnd : Integer;
begin
  FHTML.Clear;
  FCSS.Clear;
  FJavaScript.Clear;
  FOriginalIncludeScripts.Clear;
  if FContextRules = nil then
    Exit;
  T := FContextRules.MasterHtml.Text;
  FTitle := Trim(ExtractBetween(T, '<title>', '</title>'));
  if FTitle = '' then
    FTitle := 'REST Dataware';
  if (Pos('<html', LowerCase(T)) > 0) or
     (Pos('<!doctype', LowerCase(T)) > 0) then
  begin
    B := ExtractBetween(T, '<body>', '</body>');
    C := ExtractBetween(T, '<style>', '</style>');
    B := StringReplace(B, FContextRules.IncludeScriptsHtmlTag, '', [rfReplaceAll,rfIgnoreCase]);
    FHTML.Text := Trim(B);
    FCSS.Text := Trim(C);
  end
  else
  begin
    B := T;
    B := StringReplace(B, FContextRules.IncludeScriptsHtmlTag, '', [rfReplaceAll,rfIgnoreCase]);
    FHTML.Text := Trim(B);
  end;
  S := FContextRules.IncludeScripts.Text;
  L := LowerCase(S);
  J := '';
  PStart := 1;
  repeat
    P1 := PosEx('<script', L, PStart);
    if P1 = 0 then
      Break;
    P2 := PosEx('>', L, P1);
    if P2 = 0 then
      Break;
    PEnd := PosEx('</script>', L, P2 + 1);
    if PEnd = 0 then
      Break;
    if Pos(' src=', LowerCase(Copy(S,P1,P2-P1+1))) > 0 then
    begin
      L := LowerCase(Copy(S,P1,PEnd+9-P1));
      if (Pos('/bootstrap/js/bootstrap.bundle.min.js',L) = 0) and
         (Pos('/datatables/datatables.min.js',L) = 0) and
         (Pos('/chartjs/chart.umd.min.js',L) = 0) then
        FOriginalIncludeScripts.Add(Trim(Copy(S,P1,PEnd+9-P1)));
    end
    else
    begin
      if J <> '' then
        J := J + sLineBreak;
      J := J + Copy(S,P2+1,PEnd-P2-1);
    end;
    PStart := PEnd + 9;
  until False;
  if (Trim(J) = '') and (Pos('<script',LowerCase(S)) = 0) then
    J := S;
  FJavaScript.Text := Trim(J);
end;
function TRESTDWHTMLPageProducerAdapter.LibraryRoot : String;
begin
  if (FLibraryMode = lmURL) and
     (Trim(FLibraryURL) <> '') then
  begin
    Result := Trim(FLibraryURL);
    while (Length(Result) > 0) and
          (Result[Length(Result)] = '/') do
      Delete(Result,Length(Result),1);
  end
  else
    Result := LocalHTMLLibrariesPath;
end;
function TRESTDWHTMLPageProducerAdapter.ContextLibraryRoot : String;
begin
  if (FLibraryMode = lmURL) and (Trim(FLibraryURL) <> '') then
  begin
    Result := Trim(FLibraryURL);
    while (Length(Result) > 0) and (Result[Length(Result)] = '/') do
      Delete(Result,Length(Result),1);
  end
  else
    Result := './html/libs';
end;
function TRESTDWHTMLPageProducerAdapter.Produce : String;
var
  LBody,
  LRoot : String;
begin
  LBody := FHTML.Text;
  LRoot := LibraryRoot;
  Result :=
    '<!doctype html>' + sLineBreak +
    '<html lang="en">' + sLineBreak +
    '<head>' + sLineBreak +
    ' <meta charset="utf-8">' + sLineBreak +
    ' <meta name="viewport" content="width=device-width,initial-scale=1">' + sLineBreak +
    ' <title>' + FTitle + '</title>' + sLineBreak +
    ' <link rel="stylesheet" href="' + LRoot + '/bootstrap/css/bootstrap.min.css">' + sLineBreak +
    ' <link rel="stylesheet" href="' + LRoot + '/datatables/dataTables.dataTables.min.css">' + sLineBreak +
    ' <style>' + sLineBreak + FCSS.Text + sLineBreak + '</style>' + sLineBreak +
    '</head>' + sLineBreak +
    '<body>' + sLineBreak +
    LBody + sLineBreak +
    ' <script src="' + LRoot + '/bootstrap/js/bootstrap.bundle.min.js"></script>' + sLineBreak;
  if FAutoDataTables then
    Result := Result +
      ' <script src="' + LRoot + '/datatables/dataTables.min.js"></script>' + sLineBreak;
  if FAutoCharts then
    Result := Result +
      ' <script src="' + LRoot + '/chartjs/chart.umd.min.js"></script>' + sLineBreak;
  Result := Result +
    ' <script>' + sLineBreak + FJavaScript.Text + sLineBreak + '</script>' + sLineBreak +
    '</body>' + sLineBreak +
    '</html>';
end;
function TRESTDWHTMLPageProducerAdapter.ResolveLibrariesPath : String;
begin
  Result := Trim(FLibrariesPath);
  if Result = '' then
  begin
    {$IFDEF FPC}
    Result := 'Packages\Lazarus\html\libs';
    {$ELSE}
    Result := 'html\libs';
    {$ENDIF}
  end;
  if not DirectoryExists(Result) then
    Result := ExpandFileName(
      IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + Result
    );
end;
function TRESTDWHTMLPageProducerAdapter.LocalHTMLLibrariesPath : String;
begin
  Result := '.\html\libs';
end;
procedure TRESTDWHTMLPageProducerAdapter.SaveToContextRules;
var
  LRoot : String;
  LMaster,
  LScripts : TStringList;
  I : Integer;
begin
  if FContextRules = nil then
    Exit;
  LRoot := ContextLibraryRoot;
  LMaster := TStringList.Create;
  LScripts := TStringList.Create;
  try
    LMaster.Add('<!doctype html>');
    LMaster.Add('<html lang="en">');
    LMaster.Add('<head>');
    LMaster.Add(' <meta charset="utf-8">');
    LMaster.Add(' <meta name="viewport" content="width=device-width,initial-scale=1">');
    LMaster.Add(' <title>' + FTitle + '</title>');
    LMaster.Add(' <link rel="stylesheet" href="' + LRoot + '/bootstrap/css/bootstrap.min.css">');
    LMaster.Add(' <link rel="stylesheet" href="' + LRoot + '/datatables/dataTables.dataTables.min.css">');
    LMaster.Add(' <style>');
    LMaster.AddStrings(FCSS);
    LMaster.Add(' </style>');
    LMaster.Add('</head>');
    LMaster.Add('<body>');
    LMaster.AddStrings(FHTML);
    LMaster.Add('{%incscripts%}');
    LMaster.Add('</body>');
    LMaster.Add('</html>');
    LScripts.Add('<script src="' + LRoot + '/bootstrap/js/bootstrap.bundle.min.js"></script>');
    if FAutoDataTables then
      LScripts.Add('<script src="' + LRoot + '/datatables/dataTables.min.js"></script>');
    if FAutoCharts then
      LScripts.Add('<script src="' + LRoot + '/chartjs/chart.umd.min.js"></script>');
    for I := 0 to FOriginalIncludeScripts.Count - 1 do
      if Trim(FOriginalIncludeScripts[I]) <> '' then
        LScripts.Add(FOriginalIncludeScripts[I]);
    LScripts.Add('<script>');
    LScripts.AddStrings(FJavaScript);
    LScripts.Add('</script>');
    FContextRules.ContentType := 'text/html';
    FContextRules.MasterHtmlTag := '$body';
    FContextRules.IncludeScriptsHtmlTag := '{%incscripts%}';
    FContextRules.MasterHtml.Assign(LMaster);
    FContextRules.IncludeScripts.Assign(LScripts);
  finally
    LScripts.Free;
    LMaster.Free;
  end;
end;
end.
