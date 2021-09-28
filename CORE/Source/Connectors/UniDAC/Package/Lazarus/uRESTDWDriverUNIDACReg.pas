unit uRESTDWDriverUNIDACReg;

interface

uses
 {$IFNDEF UNIX}Windows,
 {$ELSE}Lcl,{$ENDIF}LResources, Classes, propedits, uRESTDWDriverUNIDAC;

Procedure Register;

implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverUniDAC]);
End;

initialization
{$I restdwdriverunidac.lrs}

end.
