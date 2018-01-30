object FrmLocalizar: TFrmLocalizar
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'localizar'
  ClientHeight = 396
  ClientWidth = 729
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 729
    Height = 20
    Align = alTop
    Caption = 'Sistema de Localiza'#231#227'o'
    Font.Charset = ANSI_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object LblSysSQL: TLabel
      Left = 4
      Top = 3
      Width = 79
      Height = 13
      Caption = '[F1] - SYS SQL'
    end
  end
  object PnlCabecalho: TPanel
    Left = 0
    Top = 40
    Width = 729
    Height = 54
    Align = alTop
    TabOrder = 2
    DesignSize = (
      729
      54)
    object Label1: TLabel
      Left = 8
      Top = 6
      Width = 91
      Height = 13
      Caption = 'Localizando por:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblCampoIndice: TLabel
      Left = 104
      Top = 6
      Width = 91
      Height = 13
      Caption = 'Localizando por:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbOperador: TComboBox
      Left = 8
      Top = 24
      Width = 113
      Height = 21
      Style = csDropDownList
      ItemIndex = 7
      TabOrder = 2
      Text = '8- Entre (Datas)'
      OnChange = cbOperadorChange
      Items.Strings = (
        '1- Iniciado por'
        '2- Contenha'
        '3- Menor '
        '4- Menor ou Igual'
        '5- Igual'
        '6- Maior ou Igual'
        '7- Maior'
        '8- Entre (Datas)')
    end
    object EdLocalizar: TMaskEdit
      Left = 127
      Top = 24
      Width = 492
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      CharCase = ecUpperCase
      TabOrder = 3
      Text = ''
      OnKeyPress = EdLocalizarKeyPress
    end
    object BtnLocalizar: TBitBtn
      Left = 625
      Top = 23
      Width = 98
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Pesquisar'
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        200000000000000400000000000000000000000000000000000000000000CCCC
        CCFFC0C0C0FFE5E5E5FF00000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000CCCCCCFF5D99
        99FF5D5D99FF999999FFE5E5E5FF000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000005DCC
        FFFF2A99CCFF5D5D99FF999999FFE5E5E5FF0000000000000000000000000000
        000000000000000000000000000000000000000000000000000000000000CCCC
        FFFF5DCCFFFF2A99CCFF5D5D99FF999999FFE5E5E5FF00000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000CCCCFFFF5DCCFFFF2A99CCFF5D5D99FF999999FFE5E5E5FF000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000CCCCFFFF5DCCFFFF2A99CCFF5D5D99FFCCCCCCFFFFCCCCFFCC99
        99FFCC9999FFCC9999FFCCCC99FFE5E5E5FF0000000000000000000000000000
        00000000000000000000CCCCFFFF5DCCFFFFB2B2B2FFCC9999FFCCCC99FFF2EA
        BFFFFFFFCCFFF2EABFFFF2EABFFFCC9999FFECC6D9FF00000000000000000000
        0000000000000000000000000000E5E5E5FFCC9999FFFFCC99FFFFFFCCFFFFFF
        CCFFFFFFCCFFFFFFFFFFFFFFFFFFFFFFFFFFCC9999FFE5E5E5FF000000000000
        0000000000000000000000000000FFCCCCFFCCCC99FFFFFFCCFFF2EABFFFFFFF
        CCFFFFFFCCFFFFFFFFFFFFFFFFFFFFFFFFFFF2EABFFFCCCC99FF000000000000
        0000000000000000000000000000CCCC99FFFFCC99FFF2EABFFFF2EABFFFFFFF
        CCFFFFFFCCFFFFFFCCFFFFFFFFFFFFFFFFFFF2EABFFFCC9999FF000000000000
        0000000000000000000000000000CC9999FFF2EABFFFF2EABFFFF2EABFFFF2EA
        BFFFFFFFCCFFFFFFCCFFFFFFCCFFFFFFCCFFFFFFCCFFCC9999FF000000000000
        0000000000000000000000000000CCCC99FFF2EABFFFFFFFCCFFF2EABFFFF2EA
        BFFFF2EABFFFFFFFCCFFFFFFCCFFFFFFCCFFF2EABFFFCC9999FF000000000000
        0000000000000000000000000000FFCCCCFFCCCC99FFFFFFFFFFFFFFFFFFF2EA
        BFFFF2EABFFFF2EABFFFF2EABFFFFFFFCCFFCCCC99FFCCCC99FF000000000000
        0000000000000000000000000000E5E5E5FFCC9999FFECC6D9FFFFFFFFFFFFFF
        CCFFF2EABFFFF2EABFFFF2EABFFFFFCC99FFCC9999FFE5E5E5FF000000000000
        000000000000000000000000000000000000FFCCCCFFCC9999FFFFCCCCFFF2EA
        BFFFF2EABFFFF2EABFFFCCCC99FFCC9999FFFFCCCCFF00000000000000000000
        00000000000000000000000000000000000000000000E5E5E5FFCCCC99FFCC99
        99FFCC9999FFCC9999FFCC9999FFE5E5E5FF0000000000000000}
      TabOrder = 1
      OnClick = BtnLocalizarClick
    end
    object EdlocalizarVlr: TJvCalcEdit
      Left = 128
      Top = 24
      Width = 121
      Height = 21
      ShowButton = False
      TabOrder = 4
      DecimalPlacesAlwaysShown = False
    end
    object Chekit: TCheckBox
      Left = 625
      Top = 5
      Width = 97
      Height = 17
      Caption = 'Escolher KIT'
      TabOrder = 0
      Visible = False
      OnClick = ChekitClick
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 376
    Width = 729
    Height = 20
    Align = alBottom
    Caption = 'Sistema de Localiza'#231#227'o'
    Color = clGray
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 5
  end
  object GridLocalizar: TDBGrid
    Left = 0
    Top = 94
    Width = 729
    Height = 282
    Align = alClient
    Color = clWhite
    DataSource = dsLocalizar
    DrawingStyle = gdsGradient
    GradientEndColor = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ParentFont = False
    ReadOnly = True
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDrawColumnCell = GridLocalizarDrawColumnCell
    OnDblClick = GridLocalizarDblClick
    OnKeyPress = GridLocalizarKeyPress
    OnTitleClick = GridLocalizarTitleClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 20
    Width = 729
    Height = 20
    Align = alTop
    Alignment = taLeftJustify
    Caption = '    X : '
    Color = 14211288
    Font.Charset = ANSI_CHARSET
    Font.Color = 4194368
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    Visible = False
    OnClick = Panel1Click
    object Label2: TLabel
      Left = 58
      Top = 3
      Width = 51
      Height = 13
      Caption = 'Faturado'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      OnClick = Label2Click
    end
    object Label3: TLabel
      Left = 138
      Top = 3
      Width = 58
      Height = 13
      Caption = 'Cancelado'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      OnClick = Label3Click
    end
    object Label4: TLabel
      Left = 232
      Top = 3
      Width = 66
      Height = 13
      Caption = 'Contig'#234'ncia'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      OnClick = Label4Click
    end
    object Label5: TLabel
      Left = 327
      Top = 3
      Width = 39
      Height = 13
      Caption = 'Aberto'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      OnClick = Label5Click
    end
    object Label6: TLabel
      Left = 397
      Top = 3
      Width = 55
      Height = 13
      Caption = 'Rejeitado'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      OnClick = Label6Click
    end
    object Label7: TLabel
      Left = 483
      Top = 3
      Width = 77
      Height = 13
      Caption = 'EPEC P/Enviar'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      OnClick = Label7Click
    end
    object Label8: TLabel
      Left = 592
      Top = 3
      Width = 48
      Height = 13
      Caption = 'Internet'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object Label9: TLabel
      Left = 673
      Top = 5
      Width = 50
      Height = 13
      Caption = 'Ped. Exp.'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 4194368
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      OnClick = Label9Click
    end
    object Panel2: TPanel
      Left = 31
      Top = 1
      Width = 24
      Height = 17
      Color = 15132671
      ParentBackground = False
      TabOrder = 0
    end
    object Panel3: TPanel
      Left = 113
      Top = 1
      Width = 22
      Height = 17
      Color = 5987327
      ParentBackground = False
      TabOrder = 1
    end
    object Panel4: TPanel
      Left = 206
      Top = 1
      Width = 22
      Height = 17
      Color = 13041663
      ParentBackground = False
      TabOrder = 2
    end
    object Panel5: TPanel
      Left = 302
      Top = 2
      Width = 22
      Height = 17
      Color = clWhite
      ParentBackground = False
      TabOrder = 4
    end
    object Panel6: TPanel
      Left = 372
      Top = 2
      Width = 22
      Height = 17
      Color = 15066597
      ParentBackground = False
      TabOrder = 5
    end
    object Panel7: TPanel
      Left = 458
      Top = 2
      Width = 22
      Height = 17
      Color = 16760962
      ParentBackground = False
      TabOrder = 6
    end
    object Panel8: TPanel
      Left = 566
      Top = 2
      Width = 22
      Height = 17
      Color = 8454016
      ParentBackground = False
      TabOrder = 7
    end
    object Panel9: TPanel
      Left = 647
      Top = 1
      Width = 22
      Height = 17
      Color = clBlack
      ParentBackground = False
      TabOrder = 3
    end
  end
  object SQLMemo: TJvMemo
    Left = 165
    Top = 100
    Width = 423
    Height = 270
    TabOrder = 4
  end
  object dsLocalizar: TDataSource
    DataSet = DM.cdsLocalizar
    Left = 304
    Top = 192
  end
end
