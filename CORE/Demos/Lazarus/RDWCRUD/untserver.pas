unit untServer;

{$mode objfpc}{$H+}

interface

Uses Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uSock, db, uRESTDWBase, uDWAbout,
  ComCtrls, StdCtrls, ExtCtrls, Menus, Buttons,
  IdComponent, IdBaseComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type

  { TRestDWForm }

  TRestDWForm = class(TForm)
    Label1: TLabel;
    RESTServicePooler1: TRESTServicePooler;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
  private

  public

  end;

var
  RestDWForm: TRestDWForm;

implementation

uses
  uDmService;

{$R *.lfm}

{ TRestDWForm }

procedure TRestDWForm.SpeedButton1Click(Sender: TObject);
begin
  RESTServicePooler1.ServerMethodClass := TServerMethodDM;
  RESTServicePooler1.Active := not RESTServicePooler1.Active;
  if RESTServicePooler1.Active then
   Label1.Caption := 'Servidor ON-LINE'
  else
   Label1.Caption := 'Servidor OFF-LINE';
end;

end.

