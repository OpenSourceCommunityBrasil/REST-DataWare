unit FireDAC.Phys.RDWMeta;

interface

uses
  FireDAC.Phys.Meta, FireDAC.Stan.Intf,
  FireDAC.Phys.Intf, FireDAC.Phys, uRESTDWBasicDB;

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
    constructor Create(const AConnection: TFDPhysConnection; const ACSVKeywords: String);
  end;


implementation

{ TFDPhysRDWMetadata }

constructor TFDPhysRDWMetadata.Create(const AConnection: TFDPhysConnection;
            const ACSVKeywords: String);
var
  oDatabase: TRESTDWDatabasebaseBase;
  iClntVer: TFDVersion;
begin
  {TODO -oDelcio -cGeneral : Implementar  TFDPhysRDWMetadata.Create}
  oDatabase := TRESTDWDatabasebaseBase(AConnection.CliObj);
  iClntVer := 0;
  FNameQuoteChar := #0;
  FNameQuoteChar1 := #0;
  FNameQuoteChar2 := #0;
  FDefLowerCase := not (npObject in inherited GetNameCaseSensParts) and
                  (npObject in inherited GetNameDefLowCaseParts);
  FDefUpperCase := not (npObject in inherited GetNameCaseSensParts) and
                   not (npObject in inherited GetNameDefLowCaseParts);
  FTxSupported := True;//oDbxMeta.SupportsTransactions;
  FTxNested := True;//oDbxMeta.SupportsNestedTransactions;
  FNameParts := [npSchema, npBaseObject, npObject];
  inherited Create(AConnection, 0, iClntVer, False);
  if ACSVKeywords <> '' then
    FKeywords.CommaText := ACSVKeywords;
  ConfigNameParts;
  ConfigQuoteChars;
end;

function TFDPhysRDWMetadata.GetColumnOriginProvided: Boolean;
begin
  Result := False;
end;

function TFDPhysRDWMetadata.GetNameCaseSensParts: TFDPhysNameParts;
begin
  if not FDefLowerCase and not FDefUpperCase then
    Result := [npBaseObject, npObject]
  else
    Result := [];
end;

function TFDPhysRDWMetadata.GetNameDefLowCaseParts: TFDPhysNameParts;
begin
  if FDefLowerCase then
    Result := [npBaseObject, npObject]
  else
    Result := [];
end;

function TFDPhysRDWMetadata.GetNameParts: TFDPhysNameParts;
begin
  Result := FNameParts;
end;

function TFDPhysRDWMetadata.GetNameQuoteChar(AQuote: TFDPhysNameQuoteLevel;
  ASide: TFDPhysNameQuoteSide): Char;
begin
  Result := #0;
  if AQuote = ncDefault then begin
    if FNameQuoteChar <> #0 then
      Result := FNameQuoteChar
    else if ASide = nsLeft then
      Result := FNameQuoteChar1
    else
      Result := FNameQuoteChar2;
  end;
end;

function TFDPhysRDWMetadata.GetTxNested: Boolean;
begin
  Result := FTxNested;
end;

function TFDPhysRDWMetadata.GetTxSupported: Boolean;
begin
  Result := FTxSupported;
end;

end.
