object Form14: TForm14
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Form14'
  ClientHeight = 229
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 11
    Top = 10
    Width = 99
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 11
    Top = 36
    Width = 99
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ePorta: TEdit
    Left = 118
    Top = 37
    Width = 47
    Height = 21
    TabOrder = 2
    Text = '9092'
  end
  object eHost: TEdit
    Left = 118
    Top = 13
    Width = 70
    Height = 21
    TabOrder = 3
    Text = '127.0.0.1'
  end
  object Memo1: TMemo
    Left = 118
    Top = 91
    Width = 305
    Height = 126
    TabOrder = 4
  end
  object Button3: TButton
    Left = 11
    Top = 62
    Width = 99
    Height = 25
    Caption = 'MsgToServer'
    TabOrder = 5
    OnClick = Button3Click
  end
  object eConnectionName: TEdit
    Left = 118
    Top = 63
    Width = 177
    Height = 21
    TabOrder = 6
  end
  object Button4: TButton
    Left = 301
    Top = 61
    Width = 122
    Height = 25
    Caption = 'Rename Connection'
    TabOrder = 7
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 11
    Top = 88
    Width = 99
    Height = 25
    Caption = 'MsgToUser'
    TabOrder = 8
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 11
    Top = 114
    Width = 99
    Height = 25
    Caption = 'StreamToServer'
    TabOrder = 9
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 11
    Top = 140
    Width = 99
    Height = 25
    Caption = 'StreamToUser'
    TabOrder = 10
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 11
    Top = 193
    Width = 99
    Height = 25
    Caption = 'FileToUser'
    TabOrder = 11
  end
  object Button9: TButton
    Left = 11
    Top = 167
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
    OnBeforeConnect = RESTDWClientNotification1BeforeConnect
    OnConnect = RESTDWClientNotification1Connect
    OnDisconnect = RESTDWClientNotification1Disconnect
    Left = 174
    Top = 137
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.pdf'
    Filter = 'Arquivos PDF|*.pdf'
    Left = 225
    Top = 25
  end
end
