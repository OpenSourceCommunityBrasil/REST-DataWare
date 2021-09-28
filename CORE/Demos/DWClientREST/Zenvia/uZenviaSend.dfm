object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Zenvia Send'
  ClientHeight = 295
  ClientWidth = 421
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
  object Label1: TLabel
    Left = 27
    Top = 19
    Width = 55
    Height = 13
    Caption = 'Username :'
  end
  object Label2: TLabel
    Left = 29
    Top = 45
    Width = 53
    Height = 13
    Caption = 'Password :'
  end
  object Label3: TLabel
    Left = 22
    Top = 71
    Width = 60
    Height = 13
    Caption = 'Remetente :'
  end
  object Label4: TLabel
    Left = 17
    Top = 97
    Width = 65
    Height = 13
    Caption = 'Destinat'#225'rio :'
  end
  object Label5: TLabel
    Left = 19
    Top = 125
    Width = 63
    Height = 13
    Caption = 'Menssagem :'
  end
  object Label6: TLabel
    Left = 263
    Top = 71
    Width = 17
    Height = 13
    Caption = 'Id :'
  end
  object Label7: TLabel
    Left = 212
    Top = 97
    Width = 68
    Height = 13
    Caption = 'AggregateId :'
  end
  object bSendSMS: TButton
    Left = 329
    Top = 40
    Width = 75
    Height = 25
    Caption = 'SendSMS'
    TabOrder = 0
    OnClick = bSendSMSClick
  end
  object eUserName: TEdit
    Left = 88
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'seulogin'
  end
  object ePassword: TEdit
    Left = 88
    Top = 42
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'sua senha'
  end
  object eRemetente: TEdit
    Left = 88
    Top = 68
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'seutelefonecomcodpa'#237's'
  end
  object eDestinatario: TEdit
    Left = 88
    Top = 94
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'telefonecomcodpa'#237's'
  end
  object eID: TEdit
    Left = 283
    Top = 67
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'idteste'
  end
  object eAggregateId: TEdit
    Left = 283
    Top = 94
    Width = 121
    Height = 21
    TabOrder = 6
    Text = '1111'
  end
  object mMSG: TEdit
    Left = 88
    Top = 122
    Width = 316
    Height = 21
    TabOrder = 7
    Text = 'Teste sample'
  end
  object Memo1: TMemo
    Left = 0
    Top = 160
    Width = 421
    Height = 135
    Align = alBottom
    Lines.Strings = (
      '')
    TabOrder = 8
  end
  object DWClientREST1: TDWClientREST
    UseSSL = True
    SSLVersions = [sslvTLSv1_2]
    UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    ContentType = 'application/json'
    RequestCharset = esUtf8
    ProxyOptions.BasicAuthentication = False
    ProxyOptions.ProxyPort = 0
    RequestTimeOut = 10000
    AllowCookies = False
    HandleRedirects = False
    RedirectMaximum = 1
    VerifyCert = False
    AuthOptions.HasAuthentication = True
    AccessControlAllowOrigin = '*'
    Left = 80
    Top = 56
  end
end
