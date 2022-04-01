REST DW foi criado para facilitar a criação de CRUDs no mesmo modelo que criamos aplicações para Cliente / Servidor.

Hoje, para ser capaz de gravar dados em um SGBD via WebService é um processo muito complexo para operações simples, tornando o agendamento de simples telas muito demorado.

Com REST DW você não precisa mais se preocupar em criar em SQL Inserções, Deleções, Leituras e Execuções via WebService; Simplesmente adicione um componente de conexão RESTDataBase e adicione um componente RESTClientSQL que já fará sua solução SQL 100% funcional como era antigamente com todo o poder das tecnologias modernas de REST / JSON, compressão de dados e tudo mais que a linguagem tem a oferecer.

Use-o e divirta-se.

Wiki com instruções de instalação e uso:
* Site: https://oneclicksistemas.ddns.net
* Fontes: https://github.com/mobius1qwe/RDWWiki

Telegram oficial:
* https://t.me/restdataware



--------
contribuições deste repo:

// uRESTDWServerContext
- propriedades Description ausentes para TDWParamMethod e TDWServerContext

// uRESTDWServerEvents
- propriedades Description ausentes para TDWParamMethod, TDWServerEvents e TDWClientEvents

// uRESTDWBase
- após um ReplyRequest ou ReplyEvent, tratamento se o Params tiver algum com nome 'ContentType' ou 'StatusCode': atualiza as variáveis locais ContentType ou ErrorCode, respectivamente.
objetivo: modificar no retorno para o client, o ContentType e StatusCode
Exemplo: de 'application/json' para 'text/html' e 200 para 500 (Erro interno), para informar que houve um erro no servidor.

- novo parâmetro nome 'RemoteIP' (gerado dinâmicamente) para passar para um ReplyRequest ou ReplyEvent qual o IP do client remoto.
