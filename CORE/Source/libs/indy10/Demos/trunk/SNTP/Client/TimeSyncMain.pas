{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  115832: TimeSyncMain.pas }
{
    Rev 1.0    2/11/2005 1:52:24 AM  DSiders
  Initial checkin.
}
unit TimeSyncMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Dialogs,
  Graphics, Controls, StdCtrls, ExtCtrls,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, IdSNTP;

type
  TFormTimeSync = class(TForm)
    PanelInfo: TPanel;
    ImageTimeSync: TImage;
    LabelInfo: TLabel;
    LabelSNTPHost: TLabel;
    LabelTimeout: TLabel;
    LabelHostTime: TLabel;
    LabelTimeZone: TLabel;
    LabelLocalTime: TLabel;
    LabelRoundtrip: TLabel;
    LabelOffset: TLabel;
    ComboBoxSNTPHost: TComboBox;
    EditTimeout: TEdit;
    EditHostTime: TEdit;
    EditTimezone: TEdit;
    EditLocalTime: TEdit;
    EditLocalOffset: TEdit;
    EditRoundTrip: TEdit;
    ButtonGetTime: TButton;
    ButtonSetTime: TButton;
    SntpClient: TIdSNTP;

    procedure ButtonGetTimeClick(Sender: TObject);
    procedure ButtonSetTimeClick(Sender: TObject);
    procedure ComboBoxSNTPHostChange(Sender: TObject);
    procedure UpdateDisplayInfo(const ANow, ADate, ARoundtrip, AOffset: TDateTime);
    procedure ClearDisplayInfo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTimeSync: TFormTimeSync;

implementation

uses
  IdGlobal;

{$R *.DFM}

const
  csTimeFormat = 'HH:NN:SS.ZZZ';
  csCaptionFormat = '%s using the %s SNTP client (%s)';
  ciDefaultTimeout = 15000;   // in millisecs

procedure TFormTimeSync.ButtonGetTimeClick(Sender: TObject);
var
  ADateTime: TDateTime;
  ANow: TDateTime;
begin
  ClearDisplayInfo;

  if ComboBoxSNTPHost.Text <> '' then
    SntpClient.Host := ComboBoxSNTPHost.Text;

  SntpClient.ReceiveTimeout := StrToIntDef(EditTimeout.Text, ciDefaultTimeout);

  try
    ANow := Now;
    ADateTime := SntpClient.DateTime;
    UpdateDisplayInfo(ANow, ADateTime,
      SntpClient.RoundTripDelay, SntpClient.AdjustmentTime);
  except
    on E: Exception do
    begin
      MessageBeep(MB_ICONEXCLAMATION);
      ShowMessage(E.Message)
    end;
  end;
end;

procedure TFormTimeSync.ButtonSetTimeClick(Sender: TObject);
var
  ANow: TDateTime;
begin
  ClearDisplayInfo;

  if ComboBoxSNTPHost.Text <> '' then
    SntpClient.Host := ComboBoxSNTPHost.Text;

  SntpClient.ReceiveTimeout := StrToIntDef(EditTimeout.Text, ciDefaultTimeout);

  try
    ANow := Now;
    SntpClient.SyncTime;
    UpdateDisplayInfo(ANow, SntpClient.DateTime,
      SntpClient.RoundTripDelay, SntpClient.AdjustmentTime);
  except
    on E: Exception do
    begin
      MessageBeep(MB_ICONEXCLAMATION);
      ShowMessage(E.Message)
    end;
  end;
end;

procedure TFormTimeSync.ClearDisplayInfo;
begin
  EditHostTime.Text := '';
  EditRoundTrip.Text := '';
  EditLocalOffset.Text := '';
  EditTimezone.Text := '';
  EditLocalTime.Text := '';

  Application.ProcessMessages;
end;

procedure TFormTimeSync.ComboBoxSNTPHostChange(Sender: TObject);
begin
  ClearDisplayInfo;
end;

procedure TFormTimeSync.UpdateDisplayInfo(const ANow, ADate, ARoundtrip, AOffset: TDateTime);
var
  ATZInfo: _TIME_ZONE_INFORMATION;
begin
  EditHostTime.Text := FormatDateTime(csTimeFormat, ADate);
  EditRoundTrip.Text := FormatDateTime(csTimeFormat, ARoundtrip);
  EditLocalOffset.Text := FormatDateTime(csTimeFormat, AOffset);
  EditLocalTime.Text := FormatDateTime(csTimeFormat, ANow);

  GetTimeZoneInformation(ATZInfo);
  
  EditTimezone.Text := iif(
    ATZInfo.Bias = ATZInfo.StandardBias,
    ATZInfo.StandardName, 
    ATZInfo.DaylightName);

  Application.ProcessMessages;
end;

procedure TFormTimeSync.FormCreate(Sender: TObject);
begin
  LabelInfo.Caption := Format(csCaptionFormat,
    [ Application.Title, gsIdProductName, gsIdVersion ]);

  // SNTPHosts.txt has a list of SNTP hosts by country / province
  ComboBoxSNTPHost.Items.LoadFromFile('SNTPHost.txt');
  
  if ComboBoxSNTPHost.Items.Count <> 0 then
    ComboBoxSNTPHost.ItemIndex := 0;  
end;

end.
