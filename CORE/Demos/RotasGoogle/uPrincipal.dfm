object Form10: TForm10
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Rotas Google'
  ClientHeight = 295
  ClientWidth = 319
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
    Left = 9
    Top = 8
    Width = 34
    Height = 13
    Caption = 'Origem'
  end
  object Label2: TLabel
    Left = 9
    Top = 51
    Width = 36
    Height = 13
    Caption = 'Destino'
  end
  object eOrigem: TEdit
    Left = 9
    Top = 24
    Width = 300
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 0
    Text = 'VITORIA-ES'
  end
  object eDestino: TEdit
    Left = 9
    Top = 69
    Width = 223
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 1
    Text = 'CAMPINAS-SP'
  end
  object Button1: TButton
    Left = 234
    Top = 69
    Width = 75
    Height = 21
    Caption = 'Executar'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 9
    Top = 96
    Width = 300
    Height = 189
    Lines.Strings = (
      '')
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object DWClientREST1: TDWClientREST
    UseSSL = False
    SSLVersions = []
    UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    ContentType = 'application/json'
    RequestCharset = esUtf8
    ProxyOptions.BasicAuthentication = False
    ProxyOptions.ProxyPort = 0
    RequestTimeOut = 1000
    AllowCookies = False
    HandleRedirects = False
    RedirectMaximum = 1
    VerifyCert = False
    AuthOptions.HasAuthentication = False
    AccessControlAllowOrigin = '*'
    Left = 81
    Top = 24
  end
end
