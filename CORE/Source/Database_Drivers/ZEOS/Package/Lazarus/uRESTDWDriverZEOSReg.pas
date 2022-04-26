unit uRESTDWDriverZEOSReg;

interface

uses
 {$IFNDEF UNIX}Windows,
 {$ELSE}Lcl,{$ENDIF}LResources, Classes, propedits, uRESTDWDriverZEOS;

Procedure Register;

implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverZEOS]);
End;

initialization
{$I restdwdriverzeos.lrs}

end.
