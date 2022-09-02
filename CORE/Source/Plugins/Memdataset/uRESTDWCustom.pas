unit uRESTDWCustom;

interface

uses
  DBClient, Classes, Math, Db;

type
  TCustomdwMemtable = class(TCustomClientDataSet)
  private

  public
    procedure CleanData; virtual;
    procedure SortOn(const AFieldNames: string = ''; ACaseInsensitive: Boolean = True; ADescending: Boolean = False); overload;
  end;

implementation

uses
  DBConsts;

procedure _DBError(const Msg: string);
begin
  DatabaseError(Msg);
end;

procedure AssignRecord(Source, Dest: TDataset; ByName: Boolean = True);
var
  I: Integer;
  F, FSrc: TField;
begin
  if not(Dest.State in dsEditModes) then
    _DBError(SNotEditing);
  if ByName then begin
    for I := 0 to Source.FieldCount - 1 do begin
      F := Dest.FindField(Source.Fields[I].FieldName);
      FSrc := Source.Fields[I];
      if (F <> nil) and (F.DataType <> ftAutoInc) then begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
          ftString:
            F.AsString := FSrc.AsString;
          ftInteger:
            F.AsInteger := FSrc.AsInteger;
          ftBoolean:
            F.AsBoolean := FSrc.AsBoolean;
          ftFloat:
            F.AsFloat := FSrc.AsFloat;
          ftCurrency:
            F.AsCurrency := FSrc.AsCurrency;
          ftDate:
            F.AsDateTime := FSrc.AsDateTime;
          ftDateTime:
            F.AsDateTime := FSrc.AsDateTime;
        else
          F.Value := FSrc.Value;
          end;
      end;
    end;
  end else begin
    for I := 0 to Min(Source.FieldDefs.Count - 1, Dest.FieldDefs.Count - 1) do begin
      F := Dest.FindField(Dest.FieldDefs[I].Name);
      FSrc := Source.FindField(Source.FieldDefs[I].Name);
      if (F <> nil) and (FSrc <> nil) and (F.DataType <> ftAutoInc) then begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
          ftString:
            F.AsString := FSrc.AsString;
          ftInteger:
            F.AsInteger := FSrc.AsInteger;
          ftBoolean:
            F.AsBoolean := FSrc.AsBoolean;
          ftFloat:
            F.AsFloat := FSrc.AsFloat;
          ftCurrency:
            F.AsCurrency := FSrc.AsCurrency;
          ftDate:
            F.AsDateTime := FSrc.AsDateTime;
          ftDateTime:
            F.AsDateTime := FSrc.AsDateTime;
        else
          F.Value := FSrc.Value;
          end;
      end;
    end;
  end;
end;

procedure TCustomdwMemtable.CleanData;
begin

end;


procedure TCustomdwMemtable.SortOn(const AFieldNames: string; ACaseInsensitive, ADescending: Boolean);
begin
  IndexFieldNames := AFieldNames;
end;

end.
