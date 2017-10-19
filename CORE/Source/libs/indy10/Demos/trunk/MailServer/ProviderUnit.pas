unit ProviderUnit;
{
  This unit keeps the 'Options'-Form data like provider-servers,
  passwords for accessing the account and so on.

  ***** Attention ***** it is more than worth mentioning, that the
  passwords are visible and storead as clear text in this demo!
  Change this before you make a commercial product out of this!!!!

  (c)2005
  Jörg Meier (Bob)
  briefe@jmeiersoftware.de
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Mask;

type
  TProviderForm = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    LanChk: TCheckBox;
    PhoneList: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbAccount: TLabel;
    lbPassword: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    ConnLabel: TLabel;
    Pop3Name: TEdit;
    Pop3Port: TEdit;
    Pop3Accnt: TEdit;
    Pop3PWD: TEdit;
    SMTPName: TEdit;
    SMTPPort: TEdit;
    SMTPAccnt: TEdit;
    SMTPPwd: TEdit;
    SMTPLogin: TCheckBox;
    DelMail: TCheckBox;
    CheckMailTime: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    procedure LanChkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    Function  GetProviderList:tStringList;
    Procedure LoadValues;
    Procedure SaveValues;
  end;

var
  ProviderForm: TProviderForm;

implementation
Uses RAS, IniFiles;
{$R *.DFM}

function TProviderForm.GetProviderList: tStringList;
Var       I         : Integer;
          Sz        : Integer;
          ASz       : Integer;
          Bf        : PArrayRasEntryName;
          Nr        : Integer;
          R         : Integer;
begin
     Result             := tStringList.Create;
     Result.Sorted      := True;
     Result.Duplicates  := dupIgnore;
     Nr := 0;
     Sz := SizeOf(TRasEntryName);
     GetMem(Bf,Sz);
     Bf^[0].dwSize := Sz;
     ASz := Sz;
     R := RasEnumEntries(nil,nil,Bf,ASz,NR);
     if (R <> 0) and (ASz > 0) then begin
        FreeMem(Bf,Sz);
        GetMem(Bf,ASz);
        Bf^[0].dwSize := Sz;
        RasEnumEntries(nil,nil,Bf,ASz,NR);
     end;
   {$R-}
     For I := 0 to Nr-1 do begin
         Result.Add(String(Bf^[I].SzEntryName));
     end;
   {$R+}
     freemem(Bf,ASz);
end;

procedure TProviderForm.LanChkClick(Sender: TObject);
begin
     PhoneList.Enabled := Not LANChk.Checked;
     ConnLabel.Enabled := Not LANChk.Checked;
end;

procedure TProviderForm.FormShow(Sender: TObject);
Var       Sl   : tStringList;
begin
     // Fill Combobox with Providers
     Sl := GetProviderList;
     PhoneList.Items.Assign(Sl);
     SL.Free;
     LoadValues;
end;

procedure TProviderForm.LoadValues;
Var       Ini : tIniFile;
          Fn  : String;
begin
     Fn  := ChangeFileExt(Application.ExeName,'.INI');
     Ini := tIniFile.Create(Fn);
     Try
        LanChk.Checked      := Ini.ReadBool('Connection','LanChk',True);
        PhoneList.Text      := Ini.ReadString('Connection','PhoneList','');

        DelMail.Checked     := Ini.ReadBool('Pop3','DelMail',True);
        Pop3Name.Text       := Ini.ReadString('Pop3','Pop3Name','pop3.gmx.us');
        Pop3Port.Text       := Ini.ReadString('Pop3','Pop3Port','110');
        Pop3Accnt.Text      := Ini.ReadString('Pop3','Pop3Accnt','Unknown.User@gmx.us');
        Pop3PWd.Text        := Ini.ReadString('Pop3','Pop3PWd','Top Secret');

        SMTPLogin.Checked   := Ini.ReadBool('SMTP','SMTPLogin',True);
        SMTPName.Text       := Ini.ReadString('SMTP','SMTPName','smtp.gmx.us');
        SMTPPort.Text       := Ini.ReadString('SMTP','SMTPPort','25');
        SMTPAccnt.Text      := Ini.ReadString('SMTP','SMTPAccnt','Unknown.User@gmx.us');
        SMTPPWd.Text        := Ini.ReadString('SMTP','SMTPPWd','Top Secret');
        CheckMailTime.Text  := Ini.ReadString('Mailer','CheckMailTime','10');
     finally
            Ini.Free;
     End;
end;

procedure TProviderForm.SaveValues;
Var       Ini : tIniFile;
          Fn  : String;
begin
     Fn  := ChangeFileExt(Application.ExeName,'.INI');
     Ini := tIniFile.Create(Fn);
     Ini.WriteBool('Connection','LanChk',LanChk.Checked);
     Ini.WriteString('Connection','PhoneList',PhoneList.Text);

     Ini.WriteString('Pop3','Pop3Name',Pop3Name.Text);
     try
        Ini.WriteInteger('Pop3','Pop3Port',StrToInt(Pop3Port.Text));
     except
        Ini.WriteInteger('Pop3','Pop3Port',110);
     end;
     Ini.WriteString('Pop3','Pop3Accnt',Pop3Accnt.Text);
     Ini.WriteString('Pop3','Pop3PWd',Pop3PWd.Text);
     Ini.WriteBool('Pop3','DelMail',DelMail.Checked);

     Ini.WriteBool('SMTP','SMTPLogin',SMTPLogin.Checked);
     Ini.WriteString('SMTP','SMTPName',SMTPName.Text);
     try
        Ini.WriteInteger('SMTP','SMTPPort',StrToInt(SMTPPort.Text));
     except
        Ini.WriteInteger('SMTP','SMTPPort',25);
     end;
     Ini.WriteString('SMTP','SMTPAccnt',SMTPAccnt.Text);
     Ini.WriteString('SMTP','SMTPPWd',SMTPPWd.Text);
     Try
        Ini.WriteInteger('Mailer','CheckMailTime',StrToInt(CheckMailTime.Text));
     Except
           Ini.WriteInteger('Mailer','CheckMailTime',10);
     end;
     Ini.Free;
end;

procedure TProviderForm.FormCreate(Sender: TObject);
begin
     LoadValues;
end;

procedure TProviderForm.BitBtn1Click(Sender: TObject);
begin
     SaveValues;
end;

end.
