REST Dataware 2.1 - Firebase Cloud Messaging

Fontes comuns FCM:
Sockets

Fontes especficos:
Sockets\Indy
Sockets\Ics
Sockets\Fphttp
Sockets\HttpDef
Sockets\JClient_LAMW

Nenhuma pasta adicional e nenhum novo Library Path/Search Path so necessrios.

Os componentes so registrados pelos Reg.pas j existentes dos motores.
No existem units FirebaseCloudMessagingReg separadas.

Configurao pblica:
ProjectID
AppID
APIKey
VAPIDKey
ClientEmail
PrivateKey
Connection
Receive
Notification

LoadGoogleServices importa ProjectID, AppID e APIKey.
LoadServiceAccountConfig importa ProjectID, ClientEmail e PrivateKey.

Correo JSONInterface:
utils\JSON\uRESTDWJSONInterface.pas

CA bundle:
utils\SSL\RESTDWRootCA.pem
