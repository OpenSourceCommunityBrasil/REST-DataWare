object ServerMethods1: TServerMethods1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 144
  Width = 182
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
      'DriverID=IB'
      'Database=localhost:..\EMPLOYEE.GDB'
      'User_Name=sysdba'
      'password=masterkey')
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords]
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = FDConnectionEMPLOYEEBeforeConnect
    Left = 44
    Top = 21
  end
  object RESTPoolerDB: TRESTPoolerDB
    RESTDriver = RESTDriverFD1
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    Left = 102
    Top = 21
  end
  object RESTDriverFD1: TRESTDriverFD
    Connection = FDConnectionEMPLOYEE
    Left = 73
    Top = 21
  end
end
