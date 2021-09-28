unit uSQLSave;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes,
  Uni, db;
type

  TSQLSave = class(TComponent)
    public
      procedure SetParamsAndValue(Source : TDataSet; Destination : TUniSQL);
      Procedure Save(UniSql : TUniSQL; Stream : TMemoryStream);
      procedure Load(Stream : TMemoryStream; Unisql : TUniSQL);
  end;


implementation

{ TSQLSave }

procedure TSQLSave.Load(Stream: TMemoryStream; Unisql: TUniSQL);
var
  LocalSql : TUniSQL;
begin
    try
      LocalSql := TUniSQL.Create(nil);
      Stream.Position := 0;
      Stream.ReadComponent(LocalSql);
      Unisql.Assign(LocalSql);
    finally
      LocalSql.Free;
    end;
end;

procedure TSQLSave.Save(UniSql: TUniSQL; Stream: TMemoryStream);
var
  LocalSql : TUniSQL;
begin
    try
      LocalSql := TUniSQL.Create(nil);
      LocalSql.Assign(UniSql);
      LocalSql.Name := 'UniSql';
      Stream.Position := 0;
      Stream.WriteComponent(LocalSql);
    finally
      LocalSql.Free;
    end;
end;

procedure TSQLSave.SetParamsAndValue(Source: TDataSet; Destination: TUniSQL);
var
  i : integer;
  Field : TField;
begin
   for I := 0 to Destination.Params.Count-1 do
   begin
       if pos('OLD_',UpperCase(Destination.Params[i].Name))=0 then
         Field := Source.FieldByName(Destination.Params[i].Name)
       else
         Field := Source.FieldByName(Copy(Destination.Params[i].Name,5,length(Destination.Params[i].Name)));
       if Field <> nil then
       begin
         Destination.Params[i].DataType := Field.DataType;
         if not Field.IsNull then
            Destination.Params[i].Value    := Field.Value
         else
         begin
            Destination.Params[i].Clear;
            Destination.Params[i].Bound := true;
         end;
         if pos('OLD_',UpperCase(Destination.Params[i].Name))<>0 then
            Destination.Params[i].Value    := Field.OldValue;
       end;
   end;

end;

end.
