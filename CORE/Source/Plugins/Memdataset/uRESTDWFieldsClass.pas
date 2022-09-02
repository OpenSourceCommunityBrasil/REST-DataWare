unit uRESTDWFieldsClass;

interface

uses
  Db, Classes;

type
  TFtFields = class(TFields)
  private
    FInternalAddedFields: Integer;
    procedure SetInternalAddedFields(const Value: Integer);
  protected
    function GetNewCount: Integer; virtual;
    function RealCount: Integer;
  public
    property InternalAddedFields: Integer read FInternalAddedFields write SetInternalAddedFields;
    property Count: Integer read GetNewCount;
    procedure AfterConstruction; override;
  end;

implementation

uses
  SysUtils;

{ TFtFields }

procedure TFtFields.AfterConstruction;
begin
  inherited;
  InternalAddedFields := 0;
end;

function TFtFields.GetNewCount: Integer;
begin
  Result := GetCount - InternalAddedFields;
end;

function TFtFields.RealCount: Integer;
begin
  Result := GetCount;
end;

procedure TFtFields.SetInternalAddedFields(const Value: Integer);
begin
  if Value < 0 then raise Exception.Create('InternalAddedFields less then zero!');
  FInternalAddedFields := Value;
end;

end.

