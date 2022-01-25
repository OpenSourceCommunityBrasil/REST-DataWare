unit uClasseFindArea;

{$M+}

interface

uses
  Vcl.Dialogs, SysUtils, Classes, Contnrs, TypInfo;

type
  TTipoColuna = (tcText, tcNumber, tcDate, tcTime, tcDateTime, tcCheckBox, tcImage, tcProgress);

  // ***********
  // **  Definição dos Campos propriamente dito
  // *****************************************
  TCamposCollectionItem = class
  private
    FTitulo: string;
    FTipo: TTipoColuna;
    FFKCampo: string;
    FParams: string;
    FIsFK: boolean;
    FNomeCampo: string;
    FTamanhoCampo: integer;
    FMascara: string;
    FShowInFind: boolean;
    FTamanho: integer;
    FCanLocate: boolean;
    FTdatetime: boolean;
    Fkit: string;
    procedure SetTipo(const Value: TTipoColuna);
    procedure SetTitulo(const Value: string);
    procedure SetFKCampo(const Value: string);
    procedure SetIsFK(const Value: boolean);
    procedure SetMascara(const Value: string);
    procedure SetNomeCampo(const Value: string);
    procedure SetTamanhoCampo(const Value: integer);
    procedure SetParams(const Value: string);
    procedure SetShowInFind(const Value: boolean);
    procedure SetTamanho(const Value: integer);
    procedure SetCanLocate(const Value: boolean);
    procedure SetTdatetime(const Value: boolean);
    procedure SetKit(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Tipo: TTipoColuna read FTipo write SetTipo;
    property NomeCampo: string read FNomeCampo write SetNomeCampo;
    property TamanhoCampo: Integer read FTamanhoCampo write SetTamanhoCampo;
    property Titulo: string read FTitulo write SetTitulo;
    property Mascara: string read FMascara write SetMascara;
    property ShowInFindForm: boolean read FShowInFind write SetShowInFind default True;
    property IsFK: boolean read FIsFK write SetIsFK default False;
    property FKCampo: string read FFKCampo write SetFKCampo;
    property Params: string read FParams write SetParams;
    property Tamanho: integer read FTamanho write SetTamanho;
    property CanLocate: boolean read FCanLocate write SetCanLocate;
    property TDatetime: boolean read FTDatetime write SetTDatetime;
  end;

  // ***********
  // **  Definição dos Campos (pai)
  // *****************************************
  TCamposCollection = class(TObjectList)
  private
    function GetItems(Index: integer): TCamposCollectionItem;
    procedure SetItems(Index: integer; const Value: TCamposCollectionItem);
  public
    Total: integer;
    constructor Create;
    destructor Destroy; override;
    function Add(AObject: TCamposCollectionItem): integer;
    property Items[Index: integer]: TCamposCollectionItem read GetItems write SetItems; default;
  end;

  // ***********
  // **  Definição das Áreas propriamente dita
  // *****************************************
  TAreaCollectionItem = class
  private
    FTitulo: string;
    FCampoLocalizar: string;
    FTabela: string;
    FSQL: string;
    FArea: integer;
    FCampoIndice: string;
    FCampos: TCamposCollection;
    FPermitePesqBranco: boolean;
    FPacketRecord: integer;
    FTDatetime: boolean;
    Fkit: string;
    procedure SetArea(const Value: integer);
    procedure SetCampoLocalizar(const Value: string);
    procedure SetSQL(const Value: string);
    procedure SetTabela(const Value: string);
    procedure SetTitulo(const Value: string);
    procedure SetCampoIndice(const Value: string);
    procedure SetCampos(const Value: TCamposCollection);
    procedure SetPermitePesqBranco(const Value: boolean);
    procedure SetPacketRecord(const Value: Integer);
    procedure SetTDatetime(const Value: boolean);
    procedure SetKit(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TAreaCollectionItem);
    function RetornaIdxCampo(ANomeCampo: string): integer;
    function GetFieldName(AFieldName: string): string;
  published
    property Area: integer read FArea write SetArea;
    property CampoIndice: string read FCampoIndice write SetCampoIndice;
    property CampoLocalizar: string read FCampoLocalizar write SetCampoLocalizar;
    property Titulo: string read FTitulo write SetTitulo;
    property Tabela: string read FTabela write SetTabela;
    property SQL: string read FSQL write SetSQL;
    property PermitePesqBranco: boolean read FPermitePesqBranco write SetPermitePesqBranco;
    property Campos: TCamposCollection read FCampos write SetCampos;
    property PacketRecord: integer read FPacketRecord write SetPacketRecord;
    property Kit: string read FKit write SetKit;
  end;

  // ***********
  // **  Definição das Áreas (pai)
  // *****************************************
  TAreaCollection = class(TObjectList)
    function GetItems(Index: integer): TAreaCollectionItem;
    procedure SetItems(Index: integer; const Value: TAreaCollectionItem);
  public
    Total: integer;
    constructor Create;
    destructor Destroy; override;
    function Add(AObject: TAreaCollectionItem): integer;
    property Items[Index: integer]: TAreaCollectionItem read GetItems write SetItems; default;
  end;

  // ***********
  // **  Classe Principal
  // *****************************************
  TClasseFindArea = class(TObject)
  private
    FAreas: TAreaCollection;
    procedure SetAreas(const Value: TAreaCollection);
    function GetIdxArea(const AArea: integer): integer;
  public
    constructor Create;
    destructor Destroy; override;
    function GetSQL(AArea: integer): string;
    function GetArea(AArea: integer): TAreaCollectionItem;
    function LastArea: integer;
    function GetCampoType(AArea: integer; ACampo: string): TTipoColuna;
    function GetPacketRecord(AArea: integer): integer;
  published
    property Areas: TAreaCollection read FAreas write SetAreas;
  end;

implementation

{ TClasseFindArea }

//uses ServerController;

constructor TClasseFindArea.Create;
begin
  FAreas := TAreaCollection.Create;
  FAreas.OwnsObjects := True;
end;

destructor TClasseFindArea.Destroy;
begin
  FreeAndNil(FAreas);
  inherited;
end;

function TClasseFindArea.GetArea(AArea: integer): TAreaCollectionItem;
var
  i: integer;
begin
  for i := 0 to FAreas.Count - 1 do
  begin
    if FAreas.Items[i].Area = AArea then
    begin
      Result := FAreas.Items[i];
      break;
    end;
  end;

end;

function TClasseFindArea.GetCampoType(AArea: integer; ACampo: string): TTipoColuna;
var
  i, Idx: integer;
begin
  Idx := GetIdxArea(AArea);
  for i := 0 to FAreas.Items[Idx].Campos.Count - 1 do
    if AnsiSameText(FAreas.Items[Idx].Campos.Items[i].NomeCampo, ACampo) then
    begin
      Result := FAreas.Items[Idx].Campos.Items[i].Tipo;
      break;
    end;
end;

function TClasseFindArea.GetIdxArea(const AArea: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to FAreas.Count - 1 do
  begin
    if FAreas.Items[i].Area = AArea then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TClasseFindArea.GetSQL(AArea: integer): string;
var
  i: integer;
begin
  for i := 0 to FAreas.Count - 1 do
  begin
    if FAreas.Items[i].Area = AArea then
    begin
      Result := FAreas.Items[i].SQL;
      break;
    end;
  end;
end;

function TClasseFindArea.GetPacketRecord(AArea: integer): integer;
var
  i: integer;
begin
  for i := 0 to FAreas.Count - 1 do
  begin
    if FAreas.Items[i].Area = AArea then
    begin
      Result := FAreas.Items[i].PacketRecord;
      break;
    end;
  end;
end;

function TClasseFindArea.LastArea: integer;
begin
  Result := FAreas.Count - 1;
end;

procedure TClasseFindArea.SetAreas(const Value: TAreaCollection);
begin
  FAreas := Value;
end;

{ TAreaCollectionItem }

procedure TAreaCollectionItem.Assign(Source: TAreaCollectionItem);
var
  i: integer;
  TempCampo: TCamposCollectionItem;
begin
  Self.Area := Source.Area;
  Self.CampoIndice := Source.CampoIndice;
  Self.CampoLocalizar := Source.CampoLocalizar;
  Self.Titulo := Source.Titulo;
  Self.PermitePesqBranco := Source.PermitePesqBranco;
  Self.Tabela := Source.Tabela;
  Self.SQL := Source.SQL;

  for i := 0 to Source.Campos.Count - 1 do
  begin
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := Source.Campos.Items[i].Tipo;
      NomeCampo := Source.Campos.Items[i].NomeCampo;
      Titulo := Source.Campos.Items[i].Titulo;
      Mascara := Source.Campos.Items[i].Mascara;
      ShowInFindForm := Source.Campos.Items[i].ShowInFindForm;
      IsFK := Source.Campos.Items[i].IsFK;
      FKCampo := Source.Campos.Items[i].FKCampo;
      Params := Source.Campos.Items[i].Params;
      Tamanho := Source.Campos.Items[i].Tamanho;
      CanLocate := Source.Campos.Items[i].CanLocate;
      TDatetime := Source.Campos.Items[i].TDatetime;

    end;

    Self.Campos.Add(TempCampo);
  end;
end;

constructor TAreaCollectionItem.Create;
begin
  inherited;
  FCampos := TCamposCollection.Create;
  FCampos.OwnsObjects := False;
  FPermitePesqBranco := True;
  FPacketRecord := -1;
end;

destructor TAreaCollectionItem.Destroy;
begin
  FreeAndNil(FCampos);
end;

function TAreaCollectionItem.GetFieldName(AFieldName: string): string;
var
  ResCampo: string;
begin
  if Campos.Items[RetornaIdxCampo(AFieldName)].IsFK then
    ResCampo := Campos.Items[RetornaIdxCampo(AFieldName)].FKCampo
  else
    ResCampo := Campos.Items[RetornaIdxCampo(AFieldName)].NomeCampo;

  Result := Copy(ResCampo, Pos('.', ResCampo) + 1, Length(ResCampo));
end;

function TAreaCollectionItem.RetornaIdxCampo(ANomeCampo: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Campos.Count - 1 do
  begin
    if AnsiSameText(Campos.Items[i].NomeCampo, ANomeCampo) then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TAreaCollectionItem.SetArea(const Value: integer);
begin
  FArea := Value;
end;

procedure TAreaCollectionItem.SetCampoIndice(const Value: string);
begin
  FCampoIndice := Value;
end;

procedure TAreaCollectionItem.SetCampoLocalizar(const Value: string);
begin
  FCampoLocalizar := Value;
end;

procedure TAreaCollectionItem.SetCampos(const Value: TCamposCollection);
begin
  FCampos := Value;
end;

procedure TAreaCollectionItem.SetPermitePesqBranco(const Value: boolean);
begin
  FPermitePesqBranco := Value;
end;

procedure TAreaCollectionItem.SetPacketRecord(const Value: integer);
begin
  FPacketRecord := Value;
end;

procedure TAreaCollectionItem.SetSQL(const Value: string);
begin
  FSQL := Value;
end;

procedure TAreaCollectionItem.SetTabela(const Value: string);
begin
  FTabela := Value;
end;

procedure TAreaCollectionItem.SetTitulo(const Value: string);
begin
  FTitulo := Value;
end;

procedure TAreaCollectionItem.SetTDatetime(const Value: boolean);
begin
  FTDatetime := Value;
end;

procedure TAreaCollectionItem.SetKit(const Value: string);
begin
  Fkit := Value;
end;


{ TCamposCollectionItem }

constructor TCamposCollectionItem.Create;
begin
  FShowInFind := True;
  FCanLocate := True;
  FIsFK := False;
  FTamanho := 0;
end;

destructor TCamposCollectionItem.Destroy;
begin

  inherited;
end;

procedure TCamposCollectionItem.SetCanLocate(const Value: boolean);
begin
  FCanLocate := Value;
end;

procedure TCamposCollectionItem.SetTdatetime(const Value: boolean);
begin
  FTdatetime := Value;
end;

procedure TCamposCollectionItem.SetKit(const Value: string);
begin
  Fkit := Value;
end;

procedure TCamposCollectionItem.SetFKCampo(const Value: string);
begin
  FFKCampo := AnsiUpperCase(Value);
end;

procedure TCamposCollectionItem.SetIsFK(const Value: boolean);
begin
  FIsFK := Value;
end;

procedure TCamposCollectionItem.SetMascara(const Value: string);
begin
  FMascara := Value;
end;

procedure TCamposCollectionItem.SetNomeCampo(const Value: string);
begin
  FNomeCampo := AnsiUpperCase(Value);
end;

procedure TCamposCollectionItem.SetParams(const Value: string);
begin
  FParams := Value;
end;

procedure TCamposCollectionItem.SetShowInFind(const Value: boolean);
begin
  FShowInFind := Value;
end;

procedure TCamposCollectionItem.SetTamanho(const Value: integer);
begin
  FTamanho := Value;
end;

procedure TCamposCollectionItem.SetTamanhoCampo(const Value: integer);
begin
  FTamanhoCampo := Value;
end;

procedure TCamposCollectionItem.SetTipo(const Value: TTipoColuna);
begin
  FTipo := Value;
end;

procedure TCamposCollectionItem.SetTitulo(const Value: string);
begin
  FTitulo := Value;
end;

{ TCamposCollection }

function TCamposCollection.Add(AObject: TCamposCollectionItem): integer;
begin
  Result := inherited Add(AObject);
  Inc(Total);
end;

constructor TCamposCollection.Create;
begin
  Total := 0;
end;

destructor TCamposCollection.Destroy;

begin
  Total := Total - 1;
  while Total >= 0 do
  begin
    Items[Total].Free;
    Total := Total - 1;
  end;
end;

function TCamposCollection.GetItems(Index: integer): TCamposCollectionItem;
begin
  Result := TCamposCollectionItem(inherited Items[Index]);
end;

procedure TCamposCollection.SetItems(Index: integer; const Value: TCamposCollectionItem);
begin
  inherited Items[Index] := Value;
end;

{ TAreaCollection }

function TAreaCollection.Add(AObject: TAreaCollectionItem): integer;
begin
  Result := inherited Add(AObject);
  Inc(Total);
end;

constructor TAreaCollection.Create;
begin
  inherited;
  Total := 0;
end;

destructor TAreaCollection.Destroy;

begin
  Total := Total - 1;
  while Total >= 0 do
  begin
    Items[Total].Free;
    Total := Total - 1;
  end;

  //  inherited;
end;

function TAreaCollection.GetItems(Index: integer): TAreaCollectionItem;
begin
  Result := TAreaCollectionItem(inherited Items[Index]);
end;

procedure TAreaCollection.SetItems(Index: integer; const Value: TAreaCollectionItem);
begin
  inherited Items[Index] := Value;
end;

end.


