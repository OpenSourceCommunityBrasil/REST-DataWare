object Form7: TForm7
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'REST Dataware OpenGL Demo'
  ClientHeight = 338
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tVideoFrame: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tVideoFrameTimer
    Left = 136
    Top = 104
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    FieldDefs = <
      item
        Name = 'CUST_NO'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'CUSTOMER'
        Attributes = [faRequired]
        DataType = ftString
        Size = 25
      end
      item
        Name = 'CONTACT_FIRST'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'CONTACT_LAST'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'PHONE_NO'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'ADDRESS_LINE1'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'ADDRESS_LINE2'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'CITY'
        DataType = ftString
        Size = 25
      end
      item
        Name = 'STATE_PROVINCE'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'COUNTRY'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'POSTAL_CODE'
        DataType = ftString
        Size = 12
      end
      item
        Name = 'ON_HOLD'
        Attributes = [faFixed]
        DataType = ftFixedChar
        Size = 1
      end
      item
        Name = 'FIELDERROR'
        DataType = ftFloat
        Precision = 16
      end
      item
        Name = 'FIELDERROR2'
        DataType = ftLargeint
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvStoreItems, rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    SequenceName = 'EMP_NO_GEN'
    SequenceField = 'EMP_NO'
    MasterCascadeDelete = False
    BinaryRequest = True
    Datapacks = -1
    DataCache = False
    Params = <>
    DataBase = RESTDWDataBase1
    SQL.Strings = (
      'select FULL_NAME from EMPLOYEE')
    UpdateTableName = 'employee'
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    RaiseErrors = True
    ActionCursor = crSQLWait
    ReflectChanges = True
    Left = 325
    Top = 74
  end
  object RESTDWDataBase1: TRESTDWDataBase
    Active = False
    Compression = True
    CriptOptions.Use = True
    CriptOptions.Key = 'RDWBASEKEY256'
    Login = 'testserver'
    Password = 'testserver'
    Proxy = False
    ProxyOptions.Port = 8888
    PoolerService = '127.0.0.1'
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
    ParamCreate = False
    FailOver = True
    FailOverConnections = <>
    FailOverReplaceDefaults = True
    ClientConnectionDefs.Active = False
    Left = 230
    Top = 116
  end
end
