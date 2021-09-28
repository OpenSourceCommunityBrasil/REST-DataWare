object Form1: TForm1
  Left = 248
  Top = 113
  BorderStyle = bsSingle
  Caption = 'OData Test'
  ClientHeight = 409
  ClientWidth = 739
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
  object DBGrid1: TDBGrid
    Left = 0
    Top = 72
    Width = 739
    Height = 337
    Align = alBottom
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 8
    Top = 19
    Width = 107
    Height = 25
    Caption = 'Get for Events'
    TabOrder = 1
    OnClick = Button1Click
  end
  object DWClientREST1: TDWClientREST
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
    OnBeforeGet = DWClientREST1BeforeGet
    Left = 80
    Top = 96
  end
  object DWResponseTranslator1: TDWResponseTranslator
    ElementAutoReadRootIndex = False
    ElementRootBaseIndex = -1
    ElementRootBaseName = 'value'
    RequestOpen = rtGet
    RequestInsert = rtPost
    RequestEdit = rtPost
    RequestDelete = rtDelete
    FieldDefs = <>
    ClientREST = DWClientREST1
    Left = 112
    Top = 96
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    Active = False
    FieldDefs = <>
    MasterCascadeDelete = True
    Datapacks = -1
    DataCache = False
    Params = <>
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    Filtered = False
    DWResponseTranslator = DWResponseTranslator1
    Left = 144
    Top = 96
  end
  object DataSource1: TDataSource
    DataSet = RESTDWClientSQL1
    Left = 176
    Top = 96
  end
end
