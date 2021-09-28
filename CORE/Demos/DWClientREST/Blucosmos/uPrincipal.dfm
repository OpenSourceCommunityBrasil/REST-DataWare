object fBlueCosmos: TfBlueCosmos
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Bluecosmos API Teste'
  ClientHeight = 420
  ClientWidth = 623
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
  object DBGrid1: TDBGrid
    Left = 0
    Top = 79
    Width = 623
    Height = 341
    Align = alBottom
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 32
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Executar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object DWClientREST1: TDWClientREST
    UseSSL = False
    SSLVersions = []
    UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    ContentType = 'application/json'
    RequestCharset = esUtf8
    DefaultCustomHeader.Strings = (
      'X-Cosmos-Token=jtjbWYC8gWQIf_EC06dgTg')
    ProxyOptions.BasicAuthentication = False
    ProxyOptions.ProxyPort = 0
    RequestTimeOut = 1000
    AllowCookies = False
    HandleRedirects = False
    VerifyCert = False
    AuthOptions.HasAuthentication = False
    AccessControlAllowOrigin = '*'
    Left = 176
    Top = 64
  end
  object DWResponseTranslator1: TDWResponseTranslator
    ElementAutoReadRootIndex = False
    ElementRootBaseIndex = -1
    ElementRootBaseName = 'products'
    RequestOpen = rtGet
    RequestInsert = rtPost
    RequestEdit = rtPost
    RequestDelete = rtDelete
    RequestOpenUrl = 'http://api.cosmos.bluesoft.com.br/products?query=COCA'
    FieldDefs = <>
    ClientREST = DWClientREST1
    Left = 232
    Top = 64
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    FieldDefs = <>
    MasterCascadeDelete = True
    Datapacks = -1
    DataCache = False
    Params = <>
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    DWResponseTranslator = DWResponseTranslator1
    Left = 272
    Top = 64
  end
  object DataSource1: TDataSource
    DataSet = RESTDWClientSQL1
    Left = 312
    Top = 64
  end
end
