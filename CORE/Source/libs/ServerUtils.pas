unit ServerUtils;

interface

Uses
  {$IFDEF FPC}
  Classes, SysUtils, IdURI, IdGlobal;
  {$ELSE}
  Classes, StringBuilderUnit,
  SysUtils, IdURI, IdGlobal;
  {$ENDIF}

Type
 TServerParams = Class(TPersistent)
 Private
  FOwner                     : TPersistent;
  fUsername,
  fPassword                  : String;
  fHasAuthenticacion         : Boolean;
  Function GetUserName       : String;
  Function GetPassword       : String;
 Protected
  Function GetOwner : TPersistent; Override;
 Public
  Constructor Create(AOwner  : TPersistent);
  Procedure   Assign(Source  : TPersistent); Override;
 Published
  Property HasAuthentication : Boolean Read fHasAuthenticacion Write fHasAuthenticacion;
  Property UserName          : String  Read GetUserName        Write fUsername;
  Property Password          : String  Read GetPassword        Write fPassword;
End;

implementation

Procedure TServerParams.Assign(Source: TPersistent);
Var
 Src : TServerParams;
Begin
 If Source is TServerParams Then
  Begin
   Src                := TServerParams(Source);
   fUsername          := Src.fUsername;
   fPassword          := Src.fPassword;
   fHasAuthenticacion := Src.fHasAuthenticacion;
  End
 Else
  Inherited Assign(Source);
End;

Constructor TServerParams.Create(AOwner: TPersistent);
Begin
 inherited Create;
 FOwner            := AOwner;
 HasAuthentication := False;
End;

Function TServerParams.GetUserName : String;
Begin
 Result := fUsername;
End;

Function TServerParams.GetOwner: TPersistent;
Begin
 Result := FOwner;
End;

Function TServerParams.GetPassword : String;
Begin
 Result := fPassword;
End;

end.
