object dm: Tdm
  OldCreateOrder = False
  Height = 342
  Width = 491
  object DataSource1: TDataSource
    Left = 408
    Top = 176
  end
  object RESTDWDataBase1: TRESTDWDataBase
    Active = True
    Compression = True
    MyIP = '127.0.0.1'
    Login = 'testserver'
    Password = 'testserver'
    Proxy = False
    ProxyOptions.Port = 8888
    PoolerService = '127.0.0.1'
    PoolerPort = 8082
    PoolerName = 'TServerMethodDM.RESTDWPoolerDB1'
    StateConnection.AutoCheck = False
    StateConnection.InTime = 1000
    RequestTimeOut = 10000
    EncodeStrings = True
    Encoding = esASCII
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    ParamCreate = True
    Left = 256
    Top = 16
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'DEPT_NO'
        Attributes = [faRequired]
        DataType = ftString
        Size = 3
      end
      item
        Name = 'DEPARTMENT'
        Attributes = [faRequired]
        DataType = ftString
        Size = 25
      end>
    IndexDefs = <>
    MasterFields = ''
    Params = <>
    StoreDefs = True
    AfterScroll = RESTDWClientSQL1AfterScroll
    MasterCascadeDelete = True
    Inactive = False
    Datapacks = -1
    DataCache = False
    DataBase = RESTDWDataBase1
    SQL.Strings = (
      'select DEPT_NO, DEPARTMENT'
      'from DEPARTMENT'
      'order by DEPT_NO')
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    InBlockEvents = False
    Left = 88
    Top = 16
  end
  object RESTDWClientSQL2: TRESTDWClientSQL
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'EMP_NO'
        Attributes = [faRequired]
        DataType = ftSmallint
      end
      item
        Name = 'FIRST_NAME'
        Attributes = [faRequired]
        DataType = ftString
        Size = 15
      end
      item
        Name = 'LAST_NAME'
        Attributes = [faRequired]
        DataType = ftString
        Size = 20
      end
      item
        Name = 'PHONE_EXT'
        DataType = ftString
        Size = 4
      end
      item
        Name = 'HIRE_DATE'
        Attributes = [faRequired]
        DataType = ftTimeStamp
      end
      item
        Name = 'DEPT_NO'
        Attributes = [faRequired]
        DataType = ftString
        Size = 3
      end
      item
        Name = 'SALARY'
        Attributes = [faRequired]
        DataType = ftFloat
      end>
    IndexDefs = <>
    MasterFields = ''
    Params = <
      item
        DataType = ftString
        Name = 'DEPT_NO'
        ParamType = ptInput
      end>
    StoreDefs = True
    MasterCascadeDelete = True
    Inactive = False
    Datapacks = -1
    DataCache = False
    DataBase = RESTDWDataBase1
    SQL.Strings = (
      
        'select EMP_NO, FIRST_NAME, LAST_NAME,PHONE_EXT, HIRE_DATE, DEPT_' +
        'NO, SALARY from EMPLOYEE      where DEPT_NO = :DEPT_NO order by ' +
        'EMP_NO')
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    InBlockEvents = False
    Left = 80
    Top = 128
  end
end
