unit uRESTDWDetailLink;

interface

uses
  Db;

type
  TFtMasterDataLink = class(TMasterDataLink)
  protected
    procedure RecordChanged(Field: TField); override;
  end;

  TFtMasterDataLinkClass = class of TFtMasterDataLink;

implementation

{ TFtMasterDataLink }

procedure TFtMasterDataLink.RecordChanged(Field: TField);
begin
  inherited;
  if Assigned(OnMasterChange) then begin
    case DataSource.State of
      dsEdit:
        if (Fields.IndexOf(Field) >= 0) then
          OnMasterChange(Self);
      dsSetKey:
        ;
    else
      inherited RecordChanged(Field);
    end;
  end;
end;

end.
