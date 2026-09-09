Unit RESTDWNativeDriverReg;

Interface

Uses
 Classes, DesignIntf, uRESTDWNativeDriver;

Procedure Register;

Implementation

Procedure Register;
Begin
 RegisterPropertyEditor(TypeInfo(TComponent), TRESTDWNativeDriver, 'Connection', Nil);
End;

End.
