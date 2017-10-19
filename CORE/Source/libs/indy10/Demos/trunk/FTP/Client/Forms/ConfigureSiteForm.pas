{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  23020: ConfigureSiteForm.pas 
{
{   Rev 1.2    09/11/2003 3:20:48 PM  Jeremy Darling
{ Completed Log Color customization.
}
{
{   Rev 1.1    09/11/2003 2:11:52 PM  Jeremy Darling
{ Updated some of the site configuration stuff and made it so that you can add,
{ edit and delete sites from your site list.  Also added a Site Name so that
{ you don't have to see the address when selecting a site.
}
{
{   Rev 1.0    09/11/2003 12:49:20 PM  Jeremy Darling
{ Project Added to TC
}
unit ConfigureSiteForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FTPSiteInfo, StdCtrls;

type
  TfrmConfigureSite = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cbMaskPassword: TCheckBox;
    edDisplayName: TEdit;
    edAddress: TEdit;
    edUserName: TEdit;
    edPassword: TEdit;
    btnCancel: TButton;
    btnOk: TButton;
    Label5: TLabel;
    edRootFolder: TEdit;
    btnDelete: TButton;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbMaskPasswordClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfigureSite: TfrmConfigureSite;

function ConfigureSite(SiteIndex : Integer; SiteList : TFTPSiteList) : Boolean;

implementation

uses
  MainForm;

{$R *.DFM}

function ConfigureSite(SiteIndex : Integer; SiteList : TFTPSiteList) : Boolean;
var
  bCreated : Boolean;
  SI       : Integer;
begin
  Result := false;

  bCreated := SiteIndex = -1;

  if bCreated then
    begin
      SI := SiteList.IndexOf(SiteList.New);
      with SiteList[SI] do
        begin
          Name    := frmMain.cbFTPAddress.Text;
          Address := frmMain.cbFTPAddress.Text;
          UserName:= frmMain.edUserName.Text;
          Password:= frmMain.edPassword.Text;
          RootDir := '/';
        end;
    end
  else
    SI := SiteIndex;

  if (not Assigned(SiteList)) then
    exit;

  with TfrmConfigureSite.Create(Application) do
    begin
      try
        edAddress.Text     := SiteList[SI].Address;
        edDisplayName.Text := SiteList[SI].Name;
        edUserName.Text    := SiteList[SI].UserName;
        edPassword.Text    := SiteList[SI].Password;
        edRootFolder.Text  := SiteList[SI].RootDir;
        btnDelete.Enabled  := not bCreated;
        
        case ShowModal of
          mrOk : begin
                   SiteList[SI].Address  := edAddress.Text;
                   SiteList[SI].Name     := edDisplayName.Text;
                   SiteList[SI].UserName := edUserName.Text;
                   SiteList[SI].Password := edPassword.Text;
                   SiteList[SI].RootDir  := edRootFolder.Text;

                   result := true;
                 end;
          mrCancel : begin
                       if bCreated then
                         begin
                           SiteList.Delete(SI);
                         end;
                       Result := false;
                     end;
          mrNo : begin
                   SiteList.Delete(SI);
                   result := true;
                 end;
        else
          result := false;
        end;
      finally
        Free;
      end;
    end;
end;

procedure TfrmConfigureSite.FormResize(Sender: TObject);
begin
  btnDelete.Left := (width - btnOk.Width - btnCancel.Width - 15 - btnDelete.Width) div 2;
  btnOk.Left     := btnDelete.Width + btnDelete.Left + 5;
  btnCancel.Left := btnOk.Left + 5 + btnOk.Width;
end;

procedure TfrmConfigureSite.FormShow(Sender: TObject);
begin
  edPassword.PasswordChar := '*';
end;

procedure TfrmConfigureSite.cbMaskPasswordClick(Sender: TObject);
begin
  if cbMaskPassword.Checked then
    edPassword.PasswordChar := '*'
  else
    edPassword.PasswordChar := #0;
end;

end.
