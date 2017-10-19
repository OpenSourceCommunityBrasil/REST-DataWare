object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  OnReplyEvent = ServerMethodDataModuleReplyEvent
  OnWelcomeMessage = ServerMethodDataModuleWelcomeMessage
  Height = 220
  Width = 366
  object RESTDWPoolerDB1: TRESTDWPoolerDB
    RESTDriver = RESTDWDriverFD1
    Compression = True
    Encoding = esASCII
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = False
    PoolerOffMessage = 'RESTPooler not active.'
    Left = 56
    Top = 120
  end
  object RESTDWDriverFD1: TRESTDWDriverFD
    Connection = Server_FDConnection
    Left = 152
    Top = 120
  end
  object Server_FDConnection: TFDConnection
    Params.Strings = (
      'Database=employee.fdb'
      'User_Name=SYSDBA'
      'Password=abrito'
      'Server=127.0.0.1'
      'Port=3050'
      'Protocol=TCPIP'
      'DriverID=FB')
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckDefault
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <
      item
        SourceDataType = dtAnsiString
        TargetDataType = dtWideString
      end>
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords]
    ConnectedStoredUsage = []
    LoginPrompt = False
    OnError = Server_FDConnectionError
    BeforeConnect = Server_FDConnectionBeforeConnect
    Left = 54
    Top = 50
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 278
    Top = 103
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 277
    Top = 55
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Console'
    ScreenCursor = gcrNone
    Left = 278
    Top = 11
  end
  object FDQuery1: TFDQuery
    Connection = Server_FDConnection
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <
      item
        SourceDataType = dtAnsiString
        TargetDataType = dtWideString
      end>
    SQL.Strings = (
      'select * from employee where emp_no=250')
    Left = 160
    Top = 64
  end
end
