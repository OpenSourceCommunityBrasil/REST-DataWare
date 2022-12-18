unit Firedac.Phys.RDWMeta;


interface

uses
  System.Classes, FireDAC.Stan.Intf, uRESTDWBasicDB,
  FireDAC.Phys.Intf, FireDAC.Phys, FireDAC.Phys.Meta, Firedac.Phys.RDW;

type
  TFDPhysRDWMetadata = class (TFDPhysConnectionMetadata)
  private
    FTxSupported: Boolean;
    FTxNested: Boolean;
    FNameQuoteChar: Char;
    FNameQuoteChar1: Char;
    FNameQuoteChar2: Char;
    FDefLowerCase: Boolean;
    FDefUpperCase: Boolean;
    FNameParts: TFDPhysNameParts;
  protected
    function GetTxSupported: Boolean; override;
    function GetTxNested: Boolean; override;
    function GetNameQuoteChar(AQuote: TFDPhysNameQuoteLevel; ASide: TFDPhysNameQuoteSide): Char; override;
    function GetNameParts: TFDPhysNameParts; override;
    function GetNameCaseSensParts: TFDPhysNameParts; override;
    function GetNameDefLowCaseParts: TFDPhysNameParts; override;
    function GetColumnOriginProvided: Boolean; override;
  public
    constructor Create(const AConnection: TFDPhysConnection;
      const ACSVKeywords: String);
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Util;

{-------------------------------------------------------------------------------}
{ TFDPhysRDWMetadata                                                           }
{-------------------------------------------------------------------------------}
constructor TFDPhysRDWMetadata.Create(const AConnection: TFDPhysConnection;
  const ACSVKeywords: String);
var
  oDbxConn: TRESTDWDatabasebaseBase;
  iClntVer: TFDVersion;
begin
{TODO -oDelcio -cGeneral : Implementar  TFDPhysRDWMetadata.Create}

  oDbxConn := TRESTDWDatabasebaseBase(AConnection.CliObj);
 // oDbxMeta := oDbxConn.DatabaseMetaData;
//  if oDbxConn is TDBXConnectionEx then
//    iClntVer := FDVerStr2Int(TDBXConnectionEx(oDbxConn).ProductVersion)
//  else
    iClntVer := 0;
  FNameQuoteChar := #0;
  FNameQuoteChar1 := #0;
  FNameQuoteChar2 := #0;
//  if oDbxMeta is TDBXDatabaseMetaDataEx then begin
//    s := TDBXDatabaseMetaDataEx(oDbxMeta).QuotePrefix;
//    if Length(s) <> 0 then
//      FNameQuoteChar1 := s[1];
//    s := TDBXDatabaseMetaDataEx(oDbxMeta).QuoteSuffix;
//    if Length(s) <> 0 then
//      FNameQuoteChar2 := s[1];
//    FDefLowerCase := True;//TDBXDatabaseMetaDataEx(oDbxMeta).SupportsLowerCaseIdentifiers;
//    FDefUpperCase := True;//TDBXDatabaseMetaDataEx(oDbxMeta).SupportsUpperCaseIdentifiers;
//  end
//  else begin
//    s := oDbxMeta.QuoteChar;
//    if Length(s) <> 0 then
//      FNameQuoteChar := s[1];
    FDefLowerCase := not (npObject in inherited GetNameCaseSensParts) and
      (npObject in inherited GetNameDefLowCaseParts);
    FDefUpperCase := not (npObject in inherited GetNameCaseSensParts) and
      not (npObject in inherited GetNameDefLowCaseParts);
//  end;
  FTxSupported := True;//oDbxMeta.SupportsTransactions;
  FTxNested := True;//oDbxMeta.SupportsNestedTransactions;
//  // most likely DBMS support schemas
  FNameParts := [npSchema, npBaseObject, npObject];
//  if oDbxConn is TDBXConnectionEx then begin
//    try
//      oDbxMetaWrtr := TDBXMetaDataWriterFactory.CreateWriter(TDBXConnectionEx(oDbxConn).ProductName);
//    except
//      // no visible exception, if metadata is not registered
//      oDbxMetaWrtr := nil;
//    end;
//    if oDbxMetaWrtr <> nil then begin
//      FNameParts := [npBaseObject, npObject];
//      if oDbxMetaWrtr.CatalogsSupported then
//        Include(FNameParts, npCatalog);
//      if oDbxMetaWrtr.SchemasSupported then
//        Include(FNameParts, npSchema);
//      FDFreeAndNil(oDbxMetaWrtr);
//    end;
//  end;
  inherited Create(AConnection, 0, iClntVer, False);
  if ACSVKeywords <> '' then
    FKeywords.CommaText := ACSVKeywords;
  ConfigNameParts;
  ConfigQuoteChars;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWMetadata.GetTxNested: Boolean;
begin
  Result := FTxNested;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWMetadata.GetTxSupported: Boolean;
begin
  Result := FTxSupported;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWMetadata.GetNameQuoteChar(AQuote: TFDPhysNameQuoteLevel;
  ASide: TFDPhysNameQuoteSide): Char;
begin
  Result := #0;
  if AQuote = ncDefault then
    if FNameQuoteChar <> #0 then
      Result := FNameQuoteChar
    else if ASide = nsLeft then
      Result := FNameQuoteChar1
    else
      Result := FNameQuoteChar2;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWMetadata.GetNameParts: TFDPhysNameParts;
begin
  Result := FNameParts;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWMetadata.GetNameCaseSensParts: TFDPhysNameParts;
begin
  if not FDefLowerCase and not FDefUpperCase then
    Result := [npBaseObject, npObject]
  else
    Result := [];
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWMetadata.GetNameDefLowCaseParts: TFDPhysNameParts;
begin
  if FDefLowerCase then
    Result := [npBaseObject, npObject]
  else
    Result := [];
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWMetadata.GetColumnOriginProvided: Boolean;
begin
  Result := False;
end;

end.
