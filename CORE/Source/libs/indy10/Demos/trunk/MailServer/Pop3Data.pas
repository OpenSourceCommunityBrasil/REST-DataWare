unit Pop3Data;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  EmilData, StdCtrls, DBCtrls, Mask, Dbslist, Buttons, ExtCtrls;

type
  TPop3Form = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    Panel2: TPanel;
    NewBtn: TBitBtn;
    ChgBtn: TBitBtn;
    DelBtn: TBitBtn;
    OkBtn: TBitBtn;
    AbortBtn: TBitBtn;
    Pop3ServerList: tDBSearchList;
    DBServer: TDBEdit;
    DBEdit2: TDBEdit;
    DBPort: TDBEdit;
    DBEdit4: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    DBCheckBox1: TDBCheckBox;
    DBEdit1: TDBEdit;
    Label5: TLabel;
    procedure Pop3ServerListBuildString(Sender: TObject; var S: String);
    procedure FormShow(Sender: TObject);
    procedure Pop3ServerListEDStateChange(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Pop3Form: TPop3Form;

implementation

{$R *.DFM}

procedure TPop3Form.Pop3ServerListBuildString(Sender: TObject; var S: String);
begin
     With MaildModule do
          S := Pop3TableServer.Value + ' <' + Pop3TableAccount.Value + '>';
end;

procedure TPop3Form.FormShow(Sender: TObject);
begin
     MailDModule.Pop3Table.Open;
end;

procedure TPop3Form.Pop3ServerListEDStateChange(Sender: TObject);
begin
//
     if not DBServer.Showing then exit;
     if Pop3ServerList.EditState in [Inserting,Editing] then DBServer.SetFocus;
     if Pop3ServerList.EditState = Inserting then DBPort.Text := '110';
end;

procedure TPop3Form.OkBtnClick(Sender: TObject);
begin
     Close;
end;

end.
