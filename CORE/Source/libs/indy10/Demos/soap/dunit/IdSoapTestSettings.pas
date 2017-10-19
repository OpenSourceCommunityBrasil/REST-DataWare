{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16443: IdSoapTestSettings.pas 
{
{   Rev 1.0    25/2/2003 13:29:40  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Aug 2002   Grahame Grieve                  D4 Compiler fixes
  15 Aug 2002   Grahame Grieve                  Live SoapBuilders tests in DUnit testing
}

unit IdSoapTestSettings;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, IniFiles;

const
  SECS_LENGTH = 15;

type
  TIdSoapTestSettingsForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    rbRun: TRadioButton;
    rbNoRun: TRadioButton;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    eAddress: TEdit;
    rbIE: TRadioButton;
    rbIndy: TRadioButton;
    ePort: TEdit;
    eUsername: TEdit;
    ePassword: TEdit;
    eDomain: TEdit;
    Panel3: TPanel;
    BitBtn1: TBitBtn;
    bOK: TBitBtn;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rbRunClick(Sender: TObject);
    procedure eAddressChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure bOKClick(Sender: TObject);
  private
    { Private declarations }
    FIniFile : TIniFile;
    FSecondsLeft : integer;
    procedure CheckOkEnabled;
  public
    { Public declarations }
  end;

var
  IdSoapTestSettingsForm: TIdSoapTestSettingsForm;

function CheckTestOptions : boolean;

implementation

uses
  IdSoapUtilities;
  
{$R *.DFM}

function CheckTestOptions : boolean;
begin
   IdSoapTestSettingsForm := TIdSoapTestSettingsForm.create(nil);
   try
     result := IdSoapTestSettingsForm.ShowModal = mrOK;
   finally
     FreeAndNil(IdSoapTestSettingsForm);
   end;
end;

procedure TIdSoapTestSettingsForm.FormCreate(Sender: TObject);
begin
  FIniFile := TIniFile.create('IdSoapTestSettings.ini');
  if FIniFile.ValueExists('SoapBuilders', 'Use') then
    begin
    if FIniFile.ReadBool('SoapBuilders', 'Use', true) then
      begin
      rbRun.Checked := true;
      end
    else
      begin
      rbNoRun.Checked := true;
      end;
    end;
  if FIniFile.ValueExists('Proxy', 'UseIE') then
    begin
    if FIniFile.ReadBool('Proxy', 'UseIE', true) then
      begin
      rbIE.Checked := true;
      end
    else
      begin
      rbIndy.Checked := true;
      end;
    end;
  eAddress.text := FIniFile.ReadString('Proxy', 'Address', '');
  ePort.text := FIniFile.ReadString('Proxy', 'Port', '');
  eUsername.text := FIniFile.ReadString('Proxy', 'Username', '');
  ePassword.text := FIniFile.ReadString('Proxy', 'Password', '');
  eDomain.text := FIniFile.ReadString('Proxy', 'Domain', '');
  CheckOkEnabled;
  if bOk.Enabled then
    begin
    FSecondsLeft := SECS_LENGTH;
    bOK.Caption := 'OK ('+inttostr(SECS_LENGTH)+'sec)';
    end
  else
    begin
    FSecondsLeft := 0;
    end;
end;

procedure TIdSoapTestSettingsForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FIniFile);
end;

procedure TIdSoapTestSettingsForm.rbRunClick(Sender: TObject);
begin
  CheckOkEnabled;
end;

procedure TIdSoapTestSettingsForm.eAddressChange(Sender: TObject);
begin
  CheckOkEnabled;
end;

procedure TIdSoapTestSettingsForm.CheckOkEnabled;
begin
  bOk.enabled :=
     (rbRun.checked or rbNoRun.checked) and
     (rbIE.checked or rbIndy.checked) and
     ( ((ePort.Text = '') and (eAddress.Text = '')) or (StrToIntDef(ePort.Text, 0) <> 0));
  FSecondsLeft := 0;
  bOK.Caption := 'OK';
end;

procedure TIdSoapTestSettingsForm.Timer1Timer(Sender: TObject);
begin
  if FSecondsLeft > 0 then
    begin
    dec(FSecondsLeft);
    if FSecondsLeft = 0 then
      begin
      ModalResult := mrOk;
      bOKClick(self);
      end
    else
      begin
      bOK.Caption := 'OK ('+inttostr(FSecondsLeft)+'sec)';
      end;
    end;
end;

procedure TIdSoapTestSettingsForm.bOKClick(Sender: TObject);
begin
  FIniFile.WriteString('Proxy', 'Address', eAddress.text);
  FIniFile.WriteString('Proxy', 'Port', ePort.text);
  FIniFile.WriteString('Proxy', 'Username', eUsername.text);
  FIniFile.WriteString('Proxy', 'Password', ePassword.text);
  FIniFile.WriteString('Proxy', 'Domain', eDomain.text);
  FIniFile.WriteBool('SoapBuilders', 'Use', rbRun.Checked);
  FIniFile.WriteBool('Proxy', 'UseIE', rbIE.Checked);
end;

end.

