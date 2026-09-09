# REST Dataware 2.1 - Arquitetura FCM

## Regra principal

O Firebase Cloud Messaging do REST Dataware é uma implementação própria do
REST Dataware.

O CORE não depende de:

- SDK Firebase/Google;
- PushService;
- WebView;
- navegador;
- API Android;
- API iOS;
- APNS nativo;
- trust store do SysOp;
- certificados fornecidos pelo SysOp;
- serviço/background registrado automaticamente pela plataforma.

A mesma lógica de protocolo é usada em Desktop e Mobile.

## Motores

A disponibilidade do componente é definida pelo motor escolhido.

O CORE não tenta compensar uma limitação de um motor usando uma API nativa do
SysOp.

- Indy: disponível onde o motor Indy do REST Dataware estiver suportado.
- ICS: disponível apenas nas plataformas realmente suportadas pelo motor ICS.
  Se o motor ICS não suporta Android, o componente ICS não é disponibilizado
  para Android.
- FpHTTP: disponível nas plataformas suportadas pelo motor FpHTTP/Lazarus.
- HttpDef: disponível onde o motor HttpDef REST Dataware estiver suportado.
- JClient/LAMW: estrutura instalável; transporte próprio permanece separado
  até sua implementação.

Cada motor negocia tanto envio quanto recebimento.

## TLS

Os motores OpenSSL usam o CA bundle `RESTDWRootCA.pem` distribuído pelo REST
Dataware, ou `Connection.TLSCAFile/TLSCAPath` informado pelo programador.

O FCM não consulta certificados/trust stores do SysOp.

`TLSAllowInsecure=False` é o padrão seguro.

## Background e interface

O componente não registra Service Android/iOS, PushService, Toast ou qualquer
serviço nativo.

Se o programador precisar execução em background, ele cria o serviço da
aplicação e instancia o componente REST Dataware dentro dele.

`OnMessage` e demais eventos retransmitem o conteúdo recebido. Uma camada
opcional pode usar esses eventos para exibir Push, Toast ou outra interface,
sem criar dependência no CORE FCM.
