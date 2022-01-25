object fODataTest: TfODataTest
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'OData Test'
  ClientHeight = 411
  ClientWidth = 741
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
    Top = 74
    Width = 741
    Height = 337
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
    RedirectMaximum = 1
    VerifyCert = False
    AuthOptions.HasAuthentication = False
    AccessControlAllowOrigin = '*'
    Left = 272
    Top = 144
  end
  object DWResponseTranslator1: TDWResponseTranslator
    ElementAutoReadRootIndex = False
    ElementRootBaseIndex = -1
    ElementRootBaseName = 'value'
    RequestOpen = rtGet
    RequestInsert = rtPost
    RequestEdit = rtPost
    RequestDelete = rtDelete
    RequestOpenUrl = 
      'https://services.odata.org/TripPinRESTierService/(S(ajrvp01flke4' +
      'mgq0jsunxkm3))/People'
    FieldDefs = <
      item
        FieldName = 'UserName'
        ElementName = 'UserName'
        ElementIndex = 0
        FieldSize = 20
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'FirstName'
        ElementName = 'FirstName'
        ElementIndex = 1
        FieldSize = 40
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'LastName'
        ElementName = 'LastName'
        ElementIndex = 2
        FieldSize = 40
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'MiddleName'
        ElementName = 'MiddleName'
        ElementIndex = 3
        FieldSize = 30
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'Gender'
        ElementName = 'Gender'
        ElementIndex = 4
        FieldSize = 10
        Precision = 0
        DataType = ovString
        Required = False
      end
      item
        FieldName = 'Age'
        ElementName = 'Age'
        ElementIndex = 5
        FieldSize = 10
        Precision = 0
        DataType = ovString
        Required = False
      end>
    ClientREST = DWClientREST1
    Left = 432
    Top = 112
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    FieldDefs = <
      item
        Name = 'UserName'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'FirstName'
        DataType = ftString
        Size = 40
      end
      item
        Name = 'LastName'
        DataType = ftString
        Size = 40
      end
      item
        Name = 'MiddleName'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'Gender'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'Age'
        DataType = ftString
        Size = 10
      end>
    MasterCascadeDelete = True
    Datapacks = -1
    DataCache = False
    Params = <>
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    DWResponseTranslator = DWResponseTranslator1
    Left = 464
    Top = 88
    object RESTDWClientSQL1UserName: TStringField
      FieldName = 'UserName'
    end
    object RESTDWClientSQL1FirstName: TStringField
      FieldName = 'FirstName'
      Size = 40
    end
    object RESTDWClientSQL1LastName: TStringField
      FieldName = 'LastName'
      Size = 40
    end
    object RESTDWClientSQL1MiddleName: TStringField
      FieldName = 'MiddleName'
      Size = 30
    end
    object RESTDWClientSQL1Gender: TStringField
      FieldName = 'Gender'
      Size = 10
    end
    object RESTDWClientSQL1Age: TStringField
      FieldName = 'Age'
      Size = 10
    end
  end
  object DataSource1: TDataSource
    DataSet = RESTDWClientSQL1
    Left = 496
    Top = 112
  end
end
