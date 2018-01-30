unit UKernel_String;

interface

  function RemoveChar(Const texto: String): String;

implementation

  function RemoveChar(Const texto: String): String;
var
  I: integer;
  S: string;
begin
  S := '';
  for I := 1 To Length(texto) Do
    begin
      if (texto[I] in ['0' .. '9']) then
        begin
          S := S + copy(texto, I, 1);
        end;
    end;
  Result := S;
end;
end.
