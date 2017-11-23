unit uRestDWLazDriverReg;

interface

uses
 {$IFNDEF UNIX}Windows,
 {$ELSE}Lcl,{$ENDIF}LResources, Classes, propedits, uRestDWLazDriver;

Procedure Register;

implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWLazDriver]);
End;

initialization
{$I restdwlazdriver.lrs}

end.
