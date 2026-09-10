# Android ARM64 - Indy - OpenSSL 1.0.2

Para o motor Indy do REST Dataware, estas bibliotecas são válidas:

- `libssl.so`
- `libcrypto.so`

Elas correspondem à família OpenSSL 1.0.2 usada pelo `TIdSSLIOHandlerSocketOpenSSL`
do motor Indy.

O componente FCM Indy não usa SDK Firebase Android.

Estas bibliotecas pertencem somente ao transporte TLS Indy.

## Deploy

Adicionar as duas bibliotecas nativas ao deploy Android ARM64 no diretório de
bibliotecas da ABI correspondente.

O `RESTDWRootCA.pem` deve acompanhar a aplicação no local definido pelo projeto
para que o Indy possa validar o peer quando `TLSAllowInsecure=False`.

## Importante

Outros motores podem usar a API OpenSSL direta do REST Dataware e, nesse caso,
podem exigir OpenSSL 1.1+/3.x. A versão do OpenSSL é definida pelo motor, não
pelo SysOp nem pelo CORE FCM.

Status da plataforma Android:
`SUPORTADO`.

A homologação continua sendo registrada por combinação de compilador, ABI,
motor e versão OpenSSL.
