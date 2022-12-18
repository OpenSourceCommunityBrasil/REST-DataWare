unit uRESTDWStorageBase;

interface

uses
  Classes, SysUtils, uRESTDWComponentBase, DB, uRESTDWEncodeClass, uRESTDWConsts;

type
  TRESTDWStorageBase = class(TRESTDWComponent)
  private
    {$IFDEF FPC}
      FDatabaseCharSet : TDatabaseCharSet;
    {$ENDIF}
    FEncodeStrs : boolean;
  public
    constructor Create(AOwner : TComponent); override;

    procedure SaveDatasetToStream(dataset : TDataset; var stream : TStream); virtual;
    procedure LoadDatasetFromStream(dataset : TDataset; stream : TStream); overload; virtual;
  public
    {$IFDEF FPC}
      property DatabaseCharSet : TDatabaseCharSet read FDatabaseCharSet write FDatabaseCharSet;
    {$ENDIF}
    property EncodeStrs : boolean read FEncodeStrs write FEncodeStrs;
  end;

implementation

{ TRESTDWStorageBase }

constructor TRESTDWStorageBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEncodeStrs := True;
end;

procedure TRESTDWStorageBase.LoadDatasetFromStream(dataset: TDataset; stream: TStream);
begin

end;

procedure TRESTDWStorageBase.SaveDatasetToStream(dataset: TDataset; var stream: TStream);
begin

end;

end.
