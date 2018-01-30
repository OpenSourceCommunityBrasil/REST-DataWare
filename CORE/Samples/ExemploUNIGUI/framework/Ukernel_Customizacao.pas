unit Ukernel_Customizacao;

interface

Const
   Mascara_Data_Inicial : string = 'mm"/"dd"/"yyyy 00:00';
   Mascara_Data_Final : string = 'mm"/"dd"/"yyyy 23:59';
   Mascara_Data : string = 'mm"/"dd"/"yyyy';

   // Mascara no padrão exigido pelo manual de integração
   Mascara_Data_NFe : string = 'yyyy-mm-dd';
   Mascara_DataHora_NFe : string = 'yyyy-mm-dd hh:mm:ss';
   Mascara_Hora_NFe : string = 'hh:mm:ss';

   Valor_2casas : string = '##0.00';
   Valor_4casas : string = '##0.0000';

type
  TConstantes = class
  const
    {$WRITEABLECONST ON}
    DECIMAIS_QUANTIDADE:Integer = 3;
    DECIMAIS_VALOR:Integer = 2;
    {$WRITEABLECONST OFF}
  end;

implementation

end.
