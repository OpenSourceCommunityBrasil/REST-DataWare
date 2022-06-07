REST DW foi criado para facilitar a criação de CRUDs no mesmo modelo que criamos aplicações para Cliente / Servidor.

Hoje, para ser capaz de gravar dados em um SGBD via WebService é um processo muito complexo para operações simples, tornando o agendamento de simples telas muito demorado.

Com REST DW você não precisa mais se preocupar em criar em SQL Inserções, Deleções, Leituras e Execuções via WebService; Simplesmente adicione um componente de conexão RESTDataBase e adicione um componente RESTClientSQL que já fará sua solução SQL 100% funcional como era antigamente com todo o poder das tecnologias modernas de REST / JSON, compressão de dados e tudo mais que a linguagem tem a oferecer.

Use-o e divirta-se.

## Wiki com instruções de instalação e uso:
* Site: https://github.com/mobius1qwe/REST-DataWare/wiki

## Repositório dos novos demos:
https://github.com/mobius1qwe/RDWDemos

## Telegram oficial:
* https://t.me/restdataware

----------------
**Contribuições deste repo:**

## fim de 2020-03:

## pegar o IP do Client remoto, apartir de novo parâmetro RemoteIP para eventos de ServerContexts ou ServerEvents
// objetivo  <br>
Traz o IP do Client.  <br>
Pode ser usado para fazer log, por exemplo.  <br>
<br>
// uso  <br>
Em um evento OnReplyEvent de um Evento de um DWServerEvents, ou OnReplyRequest de um Evento de um DWServerContext:  <br>
> wIP := Params.ItemsString['RemoteIP'].asString;  <br>

## modificar o (HTML Response) ContentType para retornar ao Client, em ServerEvents (e ServerContexts)
// objetivo  <br>
Retornar para o Client outro ContentType para um ServerEvent, diferente de 'application/json'.  <br>
Exemplo: ocorreu um erro e é necessário retornar uma string de retorno, com a mensagem de erro ('text/html'), não necessariamente um json.  <br>
_obs: ServerContexts já têm um parâmetro ContentType com a mesma função, neste caso esta alteração servirá mais se trabalhar com ServerContexts e ServerEvents na mesma aplicação, e quiser padronizar seu código._  <br>

// uso  <br>
Em um evento OnReplyEvent de um Evento de um DWServerEvents (ou OnReplyRequest de um Evento de um DWServerContext):  <br>

> // retornar um novo DWParam com nome 'ContentType'
> var cType: TJSONParam;  <br>
> cType                 := TJSONParam.Create(esUtf8);  <br>
> cType.ParamName       := 'ContentType';  <br>
> cType.ObjectDirection := odOUT;  <br>
> cType.ObjectValue     := ovString;  <br>
> cType.Value           := 'text/html';  <br>
> Params.Add(cType);  <br>

## modificar o (HTML Response) Status Code para retornar ao Client, em ServerEvents (e ServerContexts)
// objetivo  <br>
Retornar para o Client outro StatusCode para um ServerEvent ou ServerContext, diferente de 200 (de Ok).  <br>
Exemplo: ocorreu um erro e é necessário retornar um código de erro, como 500 (de Internal Server Error) ou 503 (de Service Unavailable).  <br>

// uso  <br>
Em um evento OnReplyEvent de um Evento de um DWServerEvents, ou OnReplyRequest de um Evento de um DWServerContext:  <br>

> // retornar um novo DWParam com nome 'StatusCode'
> var cStatusCode: TJSONParam;  <br>
> cStatusCode                 := TJSONParam.Create(esUtf8);  <br>
> cStatusCode.ParamName       := 'StatusCode';  <br>
> cStatusCode.ObjectDirection := odOUT;  <br>
> cStatusCode.ObjectValue     := ovInteger;  <br>
> cStatusCode.Value           := 503; 	// Service Unavailable  <br>
> Params.Add(cStatusCode);  <br>
