object Form1: TForm1
  Left = 253
  Top = 130
  Width = 704
  Height = 376
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 101
    Top = 32
    Width = 99
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 101
    Top = 57
    Width = 99
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ePorta: TEdit
    Left = 232
    Top = 60
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    Text = '9092'
  end
  object eHost: TEdit
    Left = 232
    Top = 36
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    Text = '127.0.0.1'
  end
  object Memo1: TMemo
    Left = 232
    Top = 114
    Width = 385
    Height = 153
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 4
  end
  object Button3: TButton
    Left = 101
    Top = 82
    Width = 99
    Height = 25
    Caption = 'SendToServer'
    TabOrder = 5
    OnClick = Button3Click
  end
  object eConnectionName: TEdit
    Left = 232
    Top = 86
    Width = 177
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 6
  end
  object Button4: TButton
    Left = 415
    Top = 86
    Width = 122
    Height = 21
    Caption = 'Rename Connection'
    TabOrder = 7
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 101
    Top = 108
    Width = 99
    Height = 25
    Caption = 'SendToUser'
    TabOrder = 8
    OnClick = Button5Click
  end
  object RESTDWClientNotification1: TRESTDWClientNotification
    Active = False
    AcceptUserMessage = True
    AcceptStream = True
    AcceptFileStream = True
    Host = 'localhost'
    AuthenticationOptions.AuthorizationOption = rdwAONone
    ProxyOptions.BasicAuthentication = False
    ProxyOptions.ProxyPort = 0
    RequestTimeOut = 10000
    ConnectTimeOut = 3000
    Encoding = esUtf8
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    OnReceiveMessage = RESTDWClientNotification1ReceiveMessage
    OnBeforeConnect = RESTDWClientNotification1BeforeConnect
    OnConnect = RESTDWClientNotification1Connect
    OnDisconnect = RESTDWClientNotification1Disconnect
    Left = 64
    Top = 208
  end
end
