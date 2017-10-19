object IdSoapTestSettingsForm: TIdSoapTestSettingsForm
  Left = 328
  Top = 285
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'IndySoap Tests Choices'
  ClientHeight = 369
  ClientWidth = 264
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 264
    Height = 105
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 10
      Width = 247
      Height = 41
      AutoSize = False
      Caption = 
        'Some IndySoap tests require an internet connection These tests c' +
        'heck that IndySoap can interoperate with SoapBuilders Test Serve' +
        'rs.'
      WordWrap = True
    end
    object rbRun: TRadioButton
      Left = 24
      Top = 62
      Width = 181
      Height = 17
      Caption = 'Run the SoapBuilders Tests'
      TabOrder = 0
      OnClick = rbRunClick
    end
    object rbNoRun: TRadioButton
      Left = 24
      Top = 78
      Width = 181
      Height = 17
      Caption = 'Don'#39't run the SoapBuilders Tests'
      TabOrder = 1
      OnClick = rbRunClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 105
    Width = 264
    Height = 212
    Align = alTop
    TabOrder = 1
    object Label2: TLabel
      Left = 10
      Top = 10
      Width = 106
      Height = 13
      Caption = 'Internet Proxy Settings'
    end
    object Label3: TLabel
      Left = 40
      Top = 74
      Width = 38
      Height = 13
      Caption = 'Address'
    end
    object Label4: TLabel
      Left = 40
      Top = 127
      Width = 48
      Height = 13
      Caption = 'Username'
    end
    object Label5: TLabel
      Left = 40
      Top = 101
      Width = 19
      Height = 13
      Caption = 'Port'
    end
    object Label6: TLabel
      Left = 40
      Top = 154
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object Label7: TLabel
      Left = 40
      Top = 180
      Width = 36
      Height = 13
      Caption = 'Domain'
    end
    object eAddress: TEdit
      Left = 94
      Top = 72
      Width = 121
      Height = 21
      TabOrder = 0
      OnChange = eAddressChange
    end
    object rbIE: TRadioButton
      Left = 24
      Top = 28
      Width = 209
      Height = 17
      Caption = 'Use WinInet with IE Proxy settings'
      TabOrder = 1
      OnClick = rbRunClick
    end
    object rbIndy: TRadioButton
      Left = 24
      Top = 46
      Width = 209
      Height = 17
      Caption = 'Use Indy with these settings:'
      TabOrder = 2
      OnClick = rbRunClick
    end
    object ePort: TEdit
      Left = 94
      Top = 98
      Width = 121
      Height = 21
      TabOrder = 3
      OnChange = eAddressChange
    end
    object eUsername: TEdit
      Left = 94
      Top = 124
      Width = 121
      Height = 21
      TabOrder = 4
      OnChange = eAddressChange
    end
    object ePassword: TEdit
      Left = 94
      Top = 150
      Width = 121
      Height = 21
      TabOrder = 5
      OnChange = eAddressChange
    end
    object eDomain: TEdit
      Left = 94
      Top = 176
      Width = 121
      Height = 21
      TabOrder = 6
      OnChange = eAddressChange
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 317
    Width = 264
    Height = 52
    Align = alClient
    TabOrder = 2
    object BitBtn1: TBitBtn
      Left = 178
      Top = 12
      Width = 75
      Height = 25
      TabOrder = 0
      Kind = bkAbort
    end
    object bOK: TBitBtn
      Left = 92
      Top = 12
      Width = 85
      Height = 25
      TabOrder = 1
      OnClick = bOKClick
      Kind = bkOK
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 14
    Top = 329
  end
end
