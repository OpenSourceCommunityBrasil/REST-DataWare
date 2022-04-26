unit uRESTDWDriverMYDACReg;

interface

uses
 {$IFNDEF UNIX}Windows,
 {$ELSE}Lcl,{$ENDIF}LResources, Classes, propedits, uRESTDWDriverMYDAC;

Procedure Register;

implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverMYDAC]);
End;

initialization
{$I restdwdrivermydac.lrs}

end.
