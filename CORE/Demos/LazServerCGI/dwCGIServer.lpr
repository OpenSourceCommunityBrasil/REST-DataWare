program dwCGIServer;

{$mode objfpc}{$H+}

{.$DEFINE APACHE}


uses
  fpCGI, fpWeb, HTTPDefs, fpHTTP,
  {$IFNDEF APACHE}
  fpHTTPApp,
  {$ENDIF}
  dmdwcgiserver, uDmService, uConsts;

begin
  {$IFNDEF APACHE}
   Application.Title:='dwCGIServer';
   Application.Port:= serverPort;
  {$ENDIF}
  Application.Initialize;
  Application.Run;
end.

