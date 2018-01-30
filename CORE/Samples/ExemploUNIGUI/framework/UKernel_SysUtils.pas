unit UKernel_SysUtils;

interface

// Retorna somente numeros de uma string
  function Kernel_Somente_Numeros(Texto: string): string;

implementation

function Kernel_Somente_Numeros(Texto: string): string;
var
  Aux, aux4: string;
  i: Integer;
begin
  Aux := Texto;
  aux4 := '';

  for i := 1 to Length(Aux) do
  begin
    if (Aux[i] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
      aux4 := aux4 + Aux[i];
  end;

  result := aux4;
end;
end.
