unit uRESTDWURLFunctions;

interface

uses
  SysUtils, uRESTDWConsts;

Type
 TRESTDWUriOptions     = Class
 Private
  vBaseServer,
  vDataUrl,
  vServerEvent,
  vEventName           : String;
  Procedure SetEventName  (Value : String);
  Procedure SetServerEvent(Value : String);
  Procedure SetBaseServer (Value : String);
  Procedure SetDataUrl    (Value : String);
 Public
  Constructor Create;
  Property BaseServer  : String Read vBaseServer  Write SetBaseServer;
  Property DataUrl     : String Read vDataUrl     Write SetDataUrl;
  Property ServerEvent : String Read vServerEvent Write SetServerEvent;
  Property EventName   : String Read vEventName   Write SetEventName;
End;

 Function EncodeURIComponent(Const ASrc: String): String;

implementation

{ TRESTDWUriOptions }

Procedure TRESTDWUriOptions.SetBaseServer (Value : String);
Begin
 vBaseServer := Lowercase(Value);
End;

Procedure TRESTDWUriOptions.SetDataUrl    (Value : String);
Begin
 vDataUrl := Lowercase(Value);
End;

Procedure TRESTDWUriOptions.SetServerEvent(Value : String);
Begin
 vServerEvent := Lowercase(Value);
 If vServerEvent <> '' Then
  If vServerEvent[InitStrPos] = '/' then
   Delete(vServerEvent, InitStrPos, 1);
End;

Procedure TRESTDWUriOptions.SetEventName(Value : String);
Begin
 vEventName := Lowercase(Value);
 If vEventName <> '' Then
  If vEventName[InitStrPos] = '/' then
   Delete(vEventName, InitStrPos, 1);
End;

Constructor TRESTDWUriOptions.Create;
Begin
 vBaseServer  := '';
 vDataUrl     := '';
 vServerEvent := '';
 vEventName   := '';
End;

Function EncodeURIComponent(Const ASrc: String) : String;
Const
 HexMap : String = '0123456789ABCDEF';
 Function IsSafeChar(ch: Integer): Boolean;
 Begin
  If      (ch >= 48) And (ch <= 57)  Then Result := True // 0-9
  Else If (ch >= 65) And (ch <= 90)  Then Result := True // A-Z
  Else If (ch >= 97) And (ch <= 122) Then Result := True // a-z
  Else If (ch = 33)  Then Result := True // !
  Else If (ch >= 39) And (ch <= 42)  Then Result := True // '()*
  Else If (ch >= 45) And (ch <= 46)  Then Result := True // -.
  Else If (ch = 95)  Then Result := True // _
  Else If (ch = 126) Then Result := True // ~
  Else Result := False;
 End;
Var
 I, J     : Integer;
 ASrcUTF8 : String;
Begin
 Result := '';    {Do not Localize}
 ASrcUTF8 := ASrc;
 // UTF8Encode call not strictly necessary but
 // prevents implicit conversion warning
 I := 1; J := 1;
 SetLength(Result, Length(ASrcUTF8) * 3); // space to %xx encode every byte
 While I <= Length(ASrcUTF8) Do
  Begin
   If IsSafeChar(Ord(ASrcUTF8[I])) then
    Begin
     Result[J] := ASrcUTF8[I];
     Inc(J);
    End
   Else
    Begin
     Result[J] := '%';
     Result[J+1] := HexMap[(Ord(ASrcUTF8[I]) shr 4) + 1];
     Result[J+2] := HexMap[(Ord(ASrcUTF8[I]) and 15) + 1];
     Inc(J,3);
    End;
   Inc(I);
  End;
 SetLength(Result, J-1);
End;

end.
