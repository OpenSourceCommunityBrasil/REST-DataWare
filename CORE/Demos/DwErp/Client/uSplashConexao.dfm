object FrmSplashConexao: TFrmSplashConexao
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsToolWindow
  Caption = 'Informa'#231#227'o'
  ClientHeight = 149
  ClientWidth = 421
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 2
    Top = 4
    Width = 419
    Height = 142
  end
  object JvImage1: TJvImage
    Left = 15
    Top = 23
    Width = 105
    Height = 105
  end
  object JvGradientHeaderPanel1: TJvGradientHeaderPanel
    Left = 133
    Top = 8
    Width = 288
    Height = 30
    GradientEndColor = clBtnFace
    GradientStyle = grHorizontal
    LabelCaption = 'Put your text here ...'
    LabelFont.Charset = DEFAULT_CHARSET
    LabelFont.Color = clWhite
    LabelFont.Height = -12
    LabelFont.Name = 'Tahoma'
    LabelFont.Style = [fsBold]
    LabelAlignment = taLeftJustify
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    TabOrder = 0
  end
  object Button1: TButton
    Left = 304
    Top = 109
    Width = 115
    Height = 29
    Caption = '&Finalizar Sistema'
    TabOrder = 3
    OnClick = Button1Click
  end
  object BtnReconnect: TButton
    Left = 183
    Top = 109
    Width = 115
    Height = 29
    Caption = 'Tentar &Reconectar'
    ModalResult = 1
    TabOrder = 2
    Visible = False
  end
  object Memo1: TMemo
    Left = 136
    Top = 40
    Width = 283
    Height = 65
    TabStop = False
    Color = clBtnFace
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    TabOrder = 1
  end
  object IdIcmpClient1: TIdIcmpClient
    Host = '186.202.166.159'
    Port = 211
    Protocol = 1
    ProtocolIPv6 = 58
    IPVersion = Id_IPv4
    PacketSize = 1024
    OnReply = IdIcmpClient1Reply
    Left = 337
    Top = 48
  end
end
