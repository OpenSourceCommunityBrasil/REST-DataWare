object Form1: TForm1
  Left = 253
  Top = 130
  Width = 536
  Height = 303
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
    Left = 11
    Top = 36
    Width = 99
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 11
    Top = 61
    Width = 99
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ePorta: TEdit
    Left = 120
    Top = 44
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    Text = '9092'
  end
  object eHost: TEdit
    Left = 120
    Top = 20
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    Text = '127.0.0.1'
  end
  object Memo1: TMemo
    Left = 120
    Top = 98
    Width = 385
    Height = 153
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 4
  end
  object eConnectionName: TEdit
    Left = 120
    Top = 70
    Width = 177
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 5
  end
  object Button4: TButton
    Left = 303
    Top = 70
    Width = 122
    Height = 21
    Caption = 'Rename Connection'
    TabOrder = 6
    OnClick = Button4Click
  end
  object Button3: TButton
    Left = 11
    Top = 86
    Width = 99
    Height = 25
    Caption = 'MsgToServer'
    TabOrder = 7
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 11
    Top = 112
    Width = 99
    Height = 25
    Caption = 'MsgToUser'
    TabOrder = 8
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 11
    Top = 138
    Width = 99
    Height = 25
    Caption = 'StreamToServer'
    TabOrder = 9
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 11
    Top = 164
    Width = 99
    Height = 25
    Caption = 'StreamToUser'
    TabOrder = 10
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 11
    Top = 217
    Width = 99
    Height = 25
    Caption = 'FileToUser'
    TabOrder = 11
  end
  object Button9: TButton
    Left = 11
    Top = 191
    Width = 99
    Height = 25
    Caption = 'FileToServer'
    TabOrder = 12
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
    OnReceiveStream = RESTDWClientNotification1ReceiveStream
    OnBeforeConnect = RESTDWClientNotification1BeforeConnect
    OnConnect = RESTDWClientNotification1Connect
    OnDisconnect = RESTDWClientNotification1Disconnect
    Left = 288
    Top = 144
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.pdf'
    Filter = 'Arquivos PDF|*.pdf'
    Left = 225
    Top = 25
  end
end
