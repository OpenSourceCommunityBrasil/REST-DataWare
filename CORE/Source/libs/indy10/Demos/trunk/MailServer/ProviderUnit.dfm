object ProviderForm: TProviderForm
  Left = 519
  Top = 184
  Width = 410
  Height = 470
  Caption = 'Provider information'
  Color = clBtnFace
  Constraints.MaxHeight = 470
  Constraints.MaxWidth = 410
  Constraints.MinHeight = 470
  Constraints.MinWidth = 410
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 5
    Top = 5
    Width = 391
    Height = 391
    Caption = 'Options'
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 90
      Width = 139
      Height = 13
      Caption = 'POP3 Server for inbound mail'
    end
    object Label2: TLabel
      Left = 12
      Top = 110
      Width = 102
      Height = 13
      Caption = '&Port (Standard is 110)'
    end
    object Label8: TLabel
      Left = 12
      Top = 130
      Width = 40
      Height = 13
      Caption = '&Account'
    end
    object Label9: TLabel
      Left = 12
      Top = 150
      Width = 46
      Height = 13
      Caption = '&Password'
    end
    object lbAccount: TLabel
      Left = 12
      Top = 270
      Width = 40
      Height = 13
      Caption = '&Account'
    end
    object lbPassword: TLabel
      Left = 12
      Top = 290
      Width = 46
      Height = 13
      Caption = '&Password'
    end
    object Label11: TLabel
      Left = 12
      Top = 230
      Width = 157
      Height = 13
      Caption = 'SMTP - Server for outbound mail '
    end
    object Label12: TLabel
      Left = 12
      Top = 250
      Width = 96
      Height = 13
      Caption = 'Po&rt (Standard is 25)'
    end
    object ConnLabel: TLabel
      Left = 12
      Top = 50
      Width = 84
      Height = 13
      Caption = 'Use connection   '
    end
    object Label3: TLabel
      Left = 15
      Top = 325
      Width = 99
      Height = 13
      Caption = 'Check for mail every '
    end
    object Label4: TLabel
      Left = 235
      Top = 330
      Width = 36
      Height = 13
      Caption = 'minutes'
    end
    object LanChk: TCheckBox
      Left = 12
      Top = 25
      Width = 196
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Connect via LAN'
      TabOrder = 0
      OnClick = LanChkClick
    end
    object PhoneList: TComboBox
      Left = 190
      Top = 45
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
    object Pop3Name: TEdit
      Left = 190
      Top = 85
      Width = 121
      Height = 21
      TabOrder = 2
      Text = 'Pop3Name'
    end
    object Pop3Port: TEdit
      Left = 190
      Top = 105
      Width = 31
      Height = 21
      TabOrder = 3
      Text = '110'
    end
    object Pop3Accnt: TEdit
      Left = 190
      Top = 125
      Width = 121
      Height = 21
      TabOrder = 4
      Text = 'Pop3Accnt'
    end
    object Pop3PWD: TEdit
      Left = 190
      Top = 145
      Width = 121
      Height = 21
      TabOrder = 5
      Text = 'Pop3PWD'
    end
    object SMTPName: TEdit
      Left = 190
      Top = 225
      Width = 121
      Height = 21
      TabOrder = 6
      Text = 'SMTPName'
    end
    object SMTPPort: TEdit
      Left = 190
      Top = 245
      Width = 26
      Height = 21
      TabOrder = 7
      Text = '25'
    end
    object SMTPAccnt: TEdit
      Left = 190
      Top = 265
      Width = 121
      Height = 21
      TabOrder = 8
      Text = 'SMTPAccnt'
    end
    object SMTPPwd: TEdit
      Left = 190
      Top = 285
      Width = 121
      Height = 21
      TabOrder = 9
      Text = 'SMTPPwd'
    end
    object SMTPLogin: TCheckBox
      Left = 10
      Top = 208
      Width = 193
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Login with Account + Password'
      TabOrder = 10
    end
    object DelMail: TCheckBox
      Left = 10
      Top = 170
      Width = 193
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Delete Received Mail on Server'
      TabOrder = 11
    end
    object CheckMailTime: TEdit
      Left = 190
      Top = 325
      Width = 36
      Height = 21
      TabOrder = 12
      Text = '5'
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 402
    Width = 402
    Height = 41
    Align = alBottom
    TabOrder = 1
    object BitBtn1: TBitBtn
      Left = 75
      Top = 10
      Width = 101
      Height = 25
      TabOrder = 0
      OnClick = BitBtn1Click
      Kind = bkOK
    end
    object BitBtn2: TBitBtn
      Left = 235
      Top = 10
      Width = 96
      Height = 25
      TabOrder = 1
      Kind = bkCancel
    end
  end
end
