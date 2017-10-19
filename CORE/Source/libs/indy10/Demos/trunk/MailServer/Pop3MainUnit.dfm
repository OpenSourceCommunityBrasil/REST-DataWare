object Pop3Main: TPop3Main
  Left = 330
  Top = 105
  Width = 420
  Height = 412
  Caption = 'Pop3 Server'
  Color = clBtnFace
  Constraints.MinHeight = 412
  Constraints.MinWidth = 420
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 30
    Top = 10
    Width = 362
    Height = 257
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object GetSendBtn: TBitBtn
    Left = 145
    Top = 283
    Width = 146
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Get / Send mail now'
    TabOrder = 1
    OnClick = GetSendBtnClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 325
    Width = 412
    Height = 41
    Align = alBottom
    TabOrder = 2
    object StartBtn: TButton
      Left = 70
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Start Server'
      TabOrder = 0
      OnClick = StartBtnClick
    end
    object StopBtn: TButton
      Left = 335
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Stop Server'
      Enabled = False
      TabOrder = 1
      OnClick = StopBtnClick
    end
  end
  object MainMenu1: TMainMenu
    Left = 155
    Top = 10
    object File1: TMenuItem
      Caption = 'File'
      object Close1: TMenuItem
        Caption = 'Close'
        OnClick = Close1Click
      end
    end
    object Extra1: TMenuItem
      Caption = 'Extra'
      object Options1: TMenuItem
        Caption = 'Options'
        OnClick = Options1Click
      end
    end
  end
  object CheckTimer: TTimer
    Enabled = False
    OnTimer = CheckTimerTimer
    Left = 230
    Top = 10
  end
end
