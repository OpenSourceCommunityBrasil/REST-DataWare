Unit uRESTDWNativeDriverRegLazarus;

Interface

Uses
 Classes, TypInfo, PropEdits, uRESTDWNativeDriver;

Procedure Register;

Implementation

Procedure Register;
Var
 PropInfo : PPropInfo;
Begin
 PropInfo := TypInfo.GetPropInfo(TRESTDWNativeDriver, 'Connection');
 If PropInfo <> Nil Then
  RegisterPropertyEditor(PropInfo^.PropType, TRESTDWNativeDriver, 'Connection', THiddenPropertyEditor);
End;

End.
