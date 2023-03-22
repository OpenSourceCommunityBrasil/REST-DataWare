unit uRESTDWException;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
 SysUtils;

 Type
  eRESTDWException = Class(Exception)
 Public
  Constructor Create  (Const AMsg : String); Overload; Virtual;
 End;
 TClassIdException                      = Class Of eRESTDWException;
 eRESTDWSilentException                 = Class(eRESTDWException);
 eRESTDWConnClosedGracefully            = Class(eRESTDWSilentException);
 eRESTDWSocketHandleError               = Class(eRESTDWException);
 {$IFDEF RESTDWLINUX}
  eRESTDWNonBlockingNotSupported        = Class(eRESTDWException);
 {$ENDIF}
 eRESTDWMessageException                = Class(eRESTDWException);
 eRESTDWMessageCannotLoad               = Class(eRESTDWMessageException);
 eRESTDWPackageSizeTooBig               = Class(eRESTDWSocketHandleError);
 eRESTDWNotAllBytesSent                 = Class(eRESTDWSocketHandleError);
 eRESTDWCouldNotBindSocket              = Class(eRESTDWSocketHandleError);
 eRESTDWCanNotBindPortInRange           = Class(eRESTDWSocketHandleError);
 eRESTDWInvalidPortRange                = Class(eRESTDWSocketHandleError);
 eRESTDWCannotSetIPVersionWhenConnected = Class(eRESTDWSocketHandleError);
 eRESTDWReadTimeout                     = Class(eRESTDWException);
 eRESTDWReadLnWaitMaxAttemptsExceeded   = Class(eRESTDWException);
 eRESTDWFailedToRetreiveTimeZoneInfo    = Class(eRESTDWException);

Implementation

Constructor eRESTDWException.Create  (Const AMsg : String);
Begin
 Inherited Create(AMsg);
End;

End.
