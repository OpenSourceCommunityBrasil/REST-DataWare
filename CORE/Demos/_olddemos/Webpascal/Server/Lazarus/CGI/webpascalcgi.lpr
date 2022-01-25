program webpascalcgi;

{$mode objfpc}{$H+}

{$DEFINE APACHE}


uses
  fpCGI,
  {$IFNDEF APACHE}
  HTTPDefs, fpHTTP, fpWeb, fpHTTPApp,
  {$ENDIF}
  uConsts, dmdwcgiserver, uDmService;

begin
  {$IFNDEF APACHE}
   Application.Port:= serverPort;
  {$ENDIF}
  Application.CreateForm(TdwCGIService, dwCGIService);
  Application.Initialize;
  Application.Run;
end.

