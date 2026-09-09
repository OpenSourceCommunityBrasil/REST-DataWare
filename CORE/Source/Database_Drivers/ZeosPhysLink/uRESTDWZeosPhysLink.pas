unit uRESTDWZeosPhysLink;

{$I uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

{$IFNDEF RESTDWLAZARUS}
 {$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
 {$ENDIF}
{$ENDIF}

uses
  Classes, SysUtils, ZConnection, uRESTDWAbout, uRESTDWBasicDB, uRESTDWConsts, uRESTDWZDbc;

type
  TRESTDWZeosPhysLink = class(TRESTDWComponent)
  private
    FZConnection : TZConnection;
    FDatabase : TRESTDWDatabasebaseBase;
    FOldZeosBeforeConnect : TNotifyEvent;
    procedure setZConnection(const Value: TZConnection);
    procedure SetDatabase(Const Value : TRESTDWDatabasebaseBase);
  protected
    procedure Notification(AComponent : TComponent; Operation : TOperation); override;
    procedure OnRESTDWZeosBeforeConnect(Sender : TObject);
  public
    Destructor Destroy; Override;
  published
    property ZConnection : TZConnection read FZConnection write setZConnection;
    property Database : TRESTDWDatabasebaseBase read FDatabase write SetDatabase;
  end;

implementation

{ TRESTDWZeosPhysLink }

Destructor TRESTDWZeosPhysLink.Destroy;
Begin
 setZConnection(Nil);
 SetDatabase(Nil);
 Inherited Destroy;
End;

procedure TRESTDWZeosPhysLink.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If Operation = opRemove Then
  Begin
   If AComponent = FZConnection Then
    Begin
     FZConnection := Nil;
     FOldZeosBeforeConnect := Nil;
    End;
   If AComponent = FDatabase Then
    FDatabase := Nil;
  End;
End;

procedure TRESTDWZeosPhysLink.OnRESTDWZeosBeforeConnect(Sender : TObject);
Begin
 If Assigned(FOldZeosBeforeConnect) Then
  FOldZeosBeforeConnect(Sender);
 If FDatabase = Nil Then
  Raise Exception.Create(cErrorDatabaseNotFound);
 If (FZConnection = Nil) Or (LowerCase(FZConnection.Protocol) <> 'restdw') Then
  Exit;
 SetRESTDWDriverDatabase(FDatabase);
End;

procedure TRESTDWZeosPhysLink.SetDatabase(Const Value : TRESTDWDatabasebaseBase);
Begin
 If FDatabase = Value Then
  Exit;
 If FDatabase <> Nil Then
  FDatabase.RemoveFreeNotification(Self);
 FDatabase := Value;
 If FDatabase <> Nil Then
  FDatabase.FreeNotification(Self);
End;

procedure TRESTDWZeosPhysLink.setZConnection(Const Value : TZConnection);
Begin
 If FZConnection = Value Then
  Exit;
 If FZConnection <> Nil Then
  Begin
   FZConnection.BeforeConnect := FOldZeosBeforeConnect;
   FZConnection.RemoveFreeNotification(Self);
  End;
 FZConnection := Value;
 FOldZeosBeforeConnect := Nil;
 If FZConnection <> Nil Then
  Begin
   FZConnection.FreeNotification(Self);
   FOldZeosBeforeConnect := FZConnection.BeforeConnect;
   FZConnection.Protocol := 'restdw';
   FZConnection.BeforeConnect := {$IFDEF FPC}@{$ENDIF}OnRESTDWZeosBeforeConnect;
  End;
End;

end.
