Unit uRESTDWSQLDBPhysRegister;

{$I uRESTDW.inc}

Interface

Uses
 Classes, uRESTDWSQLDBPhysLink;

Procedure Register;

Implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - PhysLink', [TRESTDWSQLDBPhysLink]);
 End;
End.
