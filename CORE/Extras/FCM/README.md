# REST Dataware 2.1 - Extras do FCM

O FCM REST Dataware não exige SDK Firebase/Google.

Esta pasta contém somente dependências de baixo nível usadas pelos próprios
motores REST Dataware.

## A versão OpenSSL depende do motor

Não existe uma única versão OpenSSL obrigatória para todos os motores.

### Indy

O Indy usa `TIdSSLIOHandlerSocketOpenSSL`.

No Android ARM64, o motor utiliza OpenSSL 1.0.2 e as bibliotecas estão em:

`OpenSSL/Android/ARM64`

- `libssl.so`
- `libcrypto.so`

### Transports OpenSSL diretos

ICS/FpHTTP/HttpDef, quando usam a camada OpenSSL direta do FCM, seguem a API
OpenSSL prevista pelo respectivo transport REST Dataware e podem exigir
OpenSSL 1.1+/3.x.

### Windows Win64

Disponíveis:

`OpenSSL/Windows/Win64`

- `libssl-3-x64.dll`
- `libcrypto-3-x64.dll`

### Windows Win32 / Delphi antigo

A combinação correta de Indy/OpenSSL será validada com Delphi antigo durante a
homologação específica.

### macOS

Disponíveis no pacote:

`OpenSSL/macOS`

- `libssl-merged-osx32.dylib`
- `libssl-merged-osx64.dylib`

A plataforma é suportada. Cada combinação CPU/motor será validada em teste.

### iOS

A plataforma é suportada pelos motores que realmente operam no target.

Os binários OpenSSL e o deploy exato serão adicionados após a homologação
prática de cada arquitetura.

### Linux e FreeBSD

São suportados pelos motores REST Dataware compatíveis. OpenSSL e deploy serão
documentados por combinação homologada.

## Certificados

`Certificates/RESTDWRootCA.pem`

é o CA bundle controlado pelo REST Dataware.

O CORE FCM não depende do trust store do SysOp.

## Regra geral

- sem Firebase SDK;
- sem SDK Android/iOS de push;
- sem WebView;
- sem PushService automático;
- dependências apenas do motor REST Dataware;
- envio e recebimento feitos pelo motor;
- interface Push/Toast apenas por eventos/propriedades opcionais da aplicação.

Consulte `MOTORES_SYSOPS_E_DEPENDENCIAS.md`.
