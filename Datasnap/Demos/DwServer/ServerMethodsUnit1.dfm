object ServerMethods1: TServerMethods1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 196
  Width = 255
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 152
    Top = 27
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 153
    Top = 133
  end
  object Server_FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\mkmDados\MKMDATAFILE.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Server=localhost'
      'Port=3050'
      'CharacterSet='
      'DriverID=FB')
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords]
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = Server_FDConnectionBeforeConnect
    Left = 59
    Top = 26
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
    Left = 60
    Top = 128
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 152
    Top = 80
  end
  object RESTDriverFD1: TRESTDriverFD
    Connection = Server_FDConnection
    Left = 61
    Top = 80
  end
end
