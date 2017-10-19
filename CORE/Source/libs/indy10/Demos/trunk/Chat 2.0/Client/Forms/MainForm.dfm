object frmMain: TfrmMain
  Left = 196
  Top = 181
  Width = 428
  Height = 316
  Caption = 'Basic TCP client/server - client'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 420
    Height = 41
    Align = alTop
  end
  object Label2: TLabel
    Left = 9
    Top = 13
    Width = 22
    Height = 13
    Caption = 'Host'
  end
  object Label3: TLabel
    Left = 165
    Top = 13
    Width = 19
    Height = 13
    Caption = 'Port'
  end
  object edHost: TEdit
    Left = 38
    Top = 9
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object edPort: TEdit
    Left = 194
    Top = 9
    Width = 41
    Height = 21
    TabOrder = 1
    Text = '8800'
  end
  object btnConnect: TButton
    Left = 242
    Top = 5
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btnConnectClick
  end
  object memMsgs: TMemo
    Left = 0
    Top = 40
    Width = 185
    Height = 89
    Lines.Strings = (
      'memMsgs')
    TabOrder = 3
  end
  object Panel1: TPanel
    Left = 0
    Top = 264
    Width = 420
    Height = 25
    Align = alBottom
    TabOrder = 4
    object edMsg: TEdit
      Left = 2
      Top = 2
      Width = 415
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'edMsg'
      OnKeyPress = edMsgKeyPress
    end
  end
  object Client: TIdTCPClient
    OnDisconnected = ClientDisconnected
    OnConnected = ClientConnected
    Port = 0
    Left = 352
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 8
    Top = 48
  end
end
