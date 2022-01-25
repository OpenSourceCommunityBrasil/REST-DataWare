object fGenFile: TfGenFile
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Gerar Arquivo'
  ClientHeight = 452
  ClientWidth = 782
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    AlignWithMargins = True
    Left = 4
    Top = 72
    Width = 774
    Height = 376
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BorderStyle = bsNone
    Color = clInfoBk
    DataSource = DataSource1
    DrawingStyle = gdsGradient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
    ParentFont = False
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Calibri'
    TitleFont.Style = [fsBold]
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 121
    Height = 25
    Caption = 'Gerar Arquivo'
    TabOrder = 1
    OnClick = Button1Click
  end
  object eFilename: TEdit
    Left = 135
    Top = 10
    Width = 361
    Height = 21
    TabOrder = 2
    Text = 'C:\Temp\testefiles\IMAGELIST.txt'
  end
  object rgFileType: TRadioGroup
    Left = 499
    Top = 2
    Width = 142
    Height = 31
    Caption = 'FileType'
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'CSV'
      'FixedTXT')
    TabOrder = 3
  end
  object cbHeaders: TCheckBox
    Left = 648
    Top = 14
    Width = 97
    Height = 17
    Caption = 'Headers???'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object Button2: TButton
    Left = 8
    Top = 39
    Width = 121
    Height = 25
    Caption = 'Ler Arquivo'
    TabOrder = 5
    OnClick = Button2Click
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    BinaryCompatibleMode = False
    MasterCascadeDelete = False
    BinaryRequest = True
    Datapacks = -1
    DataCache = False
    MassiveType = mtMassiveObject
    Params = <>
    DataBase = RESTDWDataBase1
    SQL.Strings = (
      'select * From IMAGELIST')
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    RaiseErrors = True
    ActionCursor = crSQLWait
    ReflectChanges = True
    Left = 331
    Top = 120
  end
  object RESTDWDataBase1: TRESTDWDataBase
    Active = False
    Compression = True
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    AuthenticationOptions.AuthorizationOption = rdwAOBasic
    AuthenticationOptions.OptionParams.AuthDialog = True
    AuthenticationOptions.OptionParams.CustomDialogAuthMessage = 'Protected Space...'
    AuthenticationOptions.OptionParams.Custom404TitleMessage = '(404) The address you are looking for does not exist'
    AuthenticationOptions.OptionParams.Custom404BodyMessage = '404'
    AuthenticationOptions.OptionParams.Custom404FooterMessage = 'Take me back to <a href="./">Home REST Dataware'
    AuthenticationOptions.OptionParams.Username = 'testserver'
    AuthenticationOptions.OptionParams.Password = 'testserver'
    Proxy = False
    ProxyOptions.Port = 8888
    PoolerService = 'localhost'
    PoolerPort = 8082
    PoolerName = 'TServerMethodDM.RESTDWPoolerFD'
    StateConnection.AutoCheck = False
    StateConnection.InTime = 1000
    RequestTimeOut = 100000
    EncodeStrings = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = False
    HandleRedirects = True
    RedirectMaximum = 2
    ParamCreate = False
    FailOver = True
    FailOverConnections = <>
    FailOverReplaceDefaults = True
    ClientConnectionDefs.Active = False
    UserAgent = 
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, l' +
      'ike Gecko) Chrome/41.0.2227.0 Safari/537.36'
    Left = 302
    Top = 120
  end
  object DataSource1: TDataSource
    DataSet = RESTDWClientSQL1
    Left = 360
    Top = 120
  end
  object dwFileBufferDB: TRESTDWBufferDB
    BufferSize = 1024
    StreamMode = rdwFileStream
    CreateDirectories = False
    RewriteFile = False
    Position = 0
    Dataset = RESTDWClientSQL1
    MaskOptions.InsertChar = ' '
    MaskOptions.DefaultInsertLeftChar = False
    MaskOptions.DecimalSeparator = ','
    MaskOptions.ExcludeDecimalSeparator = False
    MaskOptions.DateSeparator = '/'
    MaskOptions.TimeSeparator = ':'
    MaskOptions.NumberFormat = '#########0.00'
    MaskOptions.DateFormat = 'dd/MM/yyyy'
    MaskOptions.TimeFormat = 'hh:mm'
    MaskOptions.DateTimeFormat = 'dd/MM/yyyy hh:mm'
    MaskOptions.IntegerMask = '0'
    MaskOptions.MemoToString = True
    MaskOptions.ReplaceLinebreakFor = '<|#%30#|>'
    MaskOptions.DefaultPrecision = 0
    MaskOptions.DefaultFieldSize = 50
    FieldDefs = <>
    FileOptions.HeaderFields = False
    FileOptions.RewriteFile = True
    FileOptions.ISODateTimeFormat = False
    FileOptions.IgnoreBlobs = False
    FileOptions.BlobsFiles = True
    FileOptions.WriteHeader = True
    FileOptions.OnlyCustomFields = False
    FileOptions.Delimiter = ';'
    FileOptions.ReplaceSeparator = '<|#%20#|>'
    FileOptions.FileType = ftbCSVFile
    FileOptions.Encoding = esUtf8
    FileOptions.Utf8SpecialChars = True
    Left = 184
    Top = 248
  end
  object RESTDWClientSQL2: TRESTDWClientSQL
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvStoreItems, rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    BinaryCompatibleMode = False
    SequenceName = 'GEN_IMAGELIST2'
    SequenceField = 'ID'
    MasterCascadeDelete = False
    BinaryRequest = True
    Datapacks = -1
    DataCache = False
    MassiveType = mtMassiveObject
    Params = <>
    DataBase = RESTDWDataBase1
    SQL.Strings = (
      'select * From IMAGELIST2')
    UpdateTableName = 'IMAGELIST2'
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    RaiseErrors = True
    ActionCursor = crSQLWait
    ReflectChanges = True
    Left = 331
    Top = 176
    object RESTDWClientSQL2ID: TIntegerField
      FieldName = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object RESTDWClientSQL2BLOBIMAGE: TBlobField
      FieldName = 'BLOBIMAGE'
    end
    object RESTDWClientSQL2BLOBTEXT: TMemoField
      FieldName = 'BLOBTEXT'
      BlobType = ftMemo
    end
  end
end
