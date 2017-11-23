object ServerMethods1: TServerMethods1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 143
  Width = 211
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 48
    Top = 67
  end
  object FDPhysIBDriverLink1: TFDPhysIBDriverLink
    Left = 104
    Top = 67
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 76
    Top = 67
  end
  object FDConnectionEMPLOYEE: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'Database=..\EMPLOYEE.FDB'
      'User_Name=sysdba'
      'password=masterkey')
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords, uvFetchGeneratorsPoint]
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = FDConnectionEMPLOYEEBeforeConnect
    Left = 60
    Top = 21
  end
  object RESTPoolerDB: TRESTPoolerDB
    RESTDriver = RESTDriverFD1
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Left = 116
    Top = 21
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 132
    Top = 67
  end
  object RESTDriverFD1: TRESTDriverFD
    Connection = FDConnectionEMPLOYEE
    Left = 88
    Top = 21
  end
end
