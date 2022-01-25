object frmGetCEP: TfrmGetCEP
  Left = 317
  Top = 119
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Consulta CEP'
  ClientHeight = 146
  ClientWidth = 662
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btConsultaCEP: TSpeedButton
    Left = 91
    Top = 28
    Width = 20
    Height = 20
    Hint = 'Consultar CEP'
    Flat = True
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      33033333333333333F7F3333333333333000333333333333F777333333333333
      000333333333333F777333333333333000333333333333F77733333333333300
      033333333FFF3F777333333700073B703333333F7773F77733333307777700B3
      33333377333777733333307F8F8F7033333337F333F337F3333377F8F9F8F773
      3333373337F3373F3333078F898F870333337F33F7FFF37F333307F99999F703
      33337F377777337F3333078F898F8703333373F337F33373333377F8F9F8F773
      333337F3373337F33333307F8F8F70333333373FF333F7333333330777770333
      333333773FF77333333333370007333333333333777333333333}
    NumGlyphs = 2
    ParentShowHint = False
    ShowHint = True
    OnClick = btConsultaCEPClick
  end
  object Label1: TLabel
    Left = 9
    Top = 12
    Width = 25
    Height = 13
    Caption = 'CEP'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 119
    Top = 12
    Width = 65
    Height = 13
    Caption = 'Logradouro'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 575
    Top = 12
    Width = 44
    Height = 13
    Caption = 'N'#250'mero'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 9
    Top = 52
    Width = 76
    Height = 13
    Caption = 'Complemento'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 9
    Top = 96
    Width = 34
    Height = 13
    Caption = 'Bairro'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 283
    Top = 96
    Width = 40
    Height = 13
    Caption = 'Cidade'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 575
    Top = 96
    Width = 17
    Height = 13
    Caption = 'UF'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edCEP: TEdit
    Left = 8
    Top = 28
    Width = 76
    Height = 21
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnKeyDown = edCEPKeyDown
    OnKeyPress = edCEPKeyPress
  end
  object edLogradouro: TEdit
    Left = 118
    Top = 28
    Width = 451
    Height = 21
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnKeyDown = edCEPKeyDown
    OnKeyPress = edCEPKeyPress
  end
  object Edit1: TEdit
    Left = 574
    Top = 27
    Width = 81
    Height = 21
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnKeyDown = edCEPKeyDown
    OnKeyPress = edCEPKeyPress
  end
  object edComplemento: TEdit
    Left = 8
    Top = 70
    Width = 648
    Height = 21
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnKeyDown = edCEPKeyDown
    OnKeyPress = edCEPKeyPress
  end
  object edBairro: TEdit
    Left = 8
    Top = 112
    Width = 272
    Height = 21
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnKeyDown = edCEPKeyDown
    OnKeyPress = edCEPKeyPress
  end
  object edCidade: TEdit
    Left = 284
    Top = 112
    Width = 289
    Height = 21
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnKeyDown = edCEPKeyDown
    OnKeyPress = edCEPKeyPress
  end
  object cbUF: TComboBox
    Left = 578
    Top = 112
    Width = 61
    Height = 21
    Hint = '3'
    BevelInner = bvNone
    BevelKind = bkFlat
    BevelOuter = bvNone
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ItemHeight = 13
    ParentFont = False
    TabOrder = 6
    Items.Strings = (
      'AC'
      'AL'
      'AM'
      'AP'
      'BA'
      'CE'
      'DF'
      'ES'
      'GO'
      'MA'
      'MG'
      'MS'
      'MT'
      'PA'
      'PB'
      'PE'
      'PI'
      'PR'
      'RJ'
      'RN'
      'RO'
      'RR'
      'RS'
      'SC'
      'SE'
      'SP'
      'TO')
  end
  object dsGetCEP: TDataSource
    DataSet = dwGetCEP
    Left = 320
    Top = 8
  end
  object dwGetCEP: TRESTDWClientSQL
    Active = False
    FieldDefs = <
      item
        Name = 'cep'
        DataType = ftString
        Precision = -1
        Size = 9
      end
      item
        Name = 'logradouro'
        DataType = ftString
        Precision = -1
        Size = 200
      end
      item
        Name = 'complemento'
        DataType = ftString
        Precision = -1
        Size = 100
      end
      item
        Name = 'bairro'
        DataType = ftString
        Precision = -1
        Size = 100
      end
      item
        Name = 'localidade'
        DataType = ftString
        Precision = -1
        Size = 100
      end
      item
        Name = 'uf'
        DataType = ftString
        Precision = -1
        Size = 2
      end
      item
        Name = 'unidade'
        DataType = ftString
        Precision = -1
        Size = 100
      end
      item
        Name = 'ibge'
        DataType = ftString
        Precision = -1
        Size = 10
      end
      item
        Name = 'gia'
        DataType = ftString
        Precision = -1
        Size = 10
      end>
    MasterCascadeDelete = True
    Datapacks = -1
    DataCache = False
    Params = <>
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    Filtered = False
    DWResponseTranslator = DWResponseTranslatorCEP
    Left = 288
    Top = 8
  end
  object DWResponseTranslatorCEP: TDWResponseTranslator
    ElementAutoReadRootIndex = True
    ElementRootBaseIndex = -1
    RequestOpen = rtGet
    RequestInsert = rtPost
    RequestEdit = rtPost
    RequestDelete = rtDelete
    RequestOpenUrl = 'https://viacep.com.br/ws/01001000/json/'
    FieldDefs = <
      item
        FieldName = 'cep'
        ElementName = 'cep'
        ElementIndex = 0
        FieldSize = 9
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'logradouro'
        ElementName = 'logradouro'
        ElementIndex = 1
        FieldSize = 200
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'complemento'
        ElementName = 'complemento'
        ElementIndex = 2
        FieldSize = 100
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'bairro'
        ElementName = 'bairro'
        ElementIndex = 3
        FieldSize = 100
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'localidade'
        ElementName = 'localidade'
        ElementIndex = 4
        FieldSize = 100
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'uf'
        ElementName = 'uf'
        ElementIndex = 5
        FieldSize = 2
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'unidade'
        ElementName = 'unidade'
        ElementIndex = 6
        FieldSize = 100
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'ibge'
        ElementName = 'ibge'
        ElementIndex = 7
        FieldSize = 10
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'gia'
        ElementName = 'gia'
        ElementIndex = 8
        FieldSize = 10
        Precision = 0
        DataType = ovString
        Required = False
      end>
    ClientREST = DWClientRESTCEP
    Left = 256
    Top = 8
  end
  object DWClientRESTCEP: TDWClientREST
    UseSSL = False
    SSLVersions = []
    UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    ContentType = 'application/json'
    RequestCharset = esUtf8
    ProxyOptions.BasicAuthentication = False
    ProxyOptions.ProxyPort = 0
    RequestTimeOut = 10000
    AllowCookies = False
    HandleRedirects = False
    VerifyCert = False
    AuthOptions.HasAuthentication = False
    AccessControlAllowOrigin = '*'
    OnBeforeGet = DWClientRESTCEPBeforeGet
    Left = 224
    Top = 8
  end
end
