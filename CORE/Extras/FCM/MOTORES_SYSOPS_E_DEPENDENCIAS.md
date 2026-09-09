# REST Dataware 2.1 - FCM - Motores, SysOps e dependências

## Critério de suporte

O FCM REST Dataware é independente do SysOp.

Uma plataforma é apresentada como `SUPORTADA` quando existe um motor REST
Dataware compatível e estão disponíveis as dependências necessárias àquele
motor/ambiente.

A documentação pública não expõe processo interno de testes.

## Indy

O componente é:

`TRESTDWIdFirebaseCloudMessaging`

O Indy negocia envio e recebimento FCM usando a infraestrutura Indy do REST
Dataware.

### Windows

Suportado nas arquiteturas atendidas pelo Indy/REST Dataware.

Para Win64, as bibliotecas disponíveis ficam em:

`Extras/FCM/OpenSSL/Windows/Win64`

### Linux

Suportado pelo motor Indy REST Dataware.

Implantar as bibliotecas OpenSSL compatíveis com a versão Indy usada pelo
projeto e o `RESTDWRootCA.pem`.

### FreeBSD

Suportado pelo motor Indy REST Dataware.

Implantar OpenSSL compatível com o motor e `RESTDWRootCA.pem`.

### Android

Suportado.

Para Android ARM64 com Indy, estão disponíveis:

`Extras/FCM/OpenSSL/Android/ARM64/libssl.so`
`Extras/FCM/OpenSSL/Android/ARM64/libcrypto.so`

Essas bibliotecas OpenSSL 1.0.2 pertencem ao transporte Indy e não ao Firebase.

Não é necessário instalar Firebase Android SDK.

### macOS

Suportado pelo motor Indy nas configurações REST Dataware correspondentes.

Os arquivos disponíveis ficam em:

`Extras/FCM/OpenSSL/macOS`

A versão/forma de deploy do OpenSSL deve corresponder ao motor e arquitetura
usados pelo projeto.

### iOS

Suportado pelo motor Indy nas configurações REST Dataware correspondentes.

O projeto deve incorporar as bibliotecas OpenSSL exigidas pelo motor/target e o
CA bundle REST Dataware.

Não é necessário Firebase iOS SDK.

## ICS

O componente é:

`TRESTDWIcsFirebaseCloudMessaging`

Somente os SysOps realmente suportados pelo motor ICS utilizado pelo REST
Dataware recebem o componente ICS.

Não existe fallback para APIs Android/iOS ou outro motor.

## FpHTTP

O componente é:

`TRESTDWFpHttpFirebaseCloudMessaging`

Disponível nos SysOps/targets suportados pelo FpHTTP/Lazarus/FPC utilizado pelo
REST Dataware.

As dependências TLS são as exigidas pelo próprio motor.

## HttpDef

O componente é:

`TRESTDWHttpDefFirebaseCloudMessaging`

Disponível nos SysOps suportados pelo motor HttpDef REST Dataware.

## JClient/LAMW

O componente/base é:

`TRESTDWjClientLAMWFirebaseCloudMessaging`

A estrutura permanece preparada para o transporte REST Dataware próprio.

## TLS e certificados

O FCM não depende do trust store do SysOp.

O REST Dataware fornece:

`Extras/FCM/Certificates/RESTDWRootCA.pem`

Também podem ser usados:

`Connection.TLSCAFile`
`Connection.TLSCAPath`

A versão OpenSSL necessária é determinada pelo motor concreto.

## Regra de arquitetura

Nenhum motor deve usar como fallback:

- Firebase SDK;
- PushService;
- WebView;
- Firebase JS;
- Firebase Admin SDK;
- APNS SDK;
- arquitetura nativa de push do SysOp.

O motor REST Dataware negocia o envio e o recebimento.

A aplicação pode consumir os eventos do componente para mostrar Toast, Push ou
outra interface. Se precisar de execução em background, o programador cria o
Service apropriado e instancia o componente REST Dataware nele.
