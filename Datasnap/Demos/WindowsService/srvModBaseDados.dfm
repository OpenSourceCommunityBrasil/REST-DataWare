object DSServerModuleBaseDados: TDSServerModuleBaseDados
  OldCreateOrder = False
  Height = 226
  Width = 363
  object RESTPoolerDB: TRESTPoolerDB
    Database = Server_FDConnection
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Left = 108
    Top = 72
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
    UpdateOptions.CountUpdatedRecords = False
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = Server_FDConnectionBeforeConnect
    Left = 107
    Top = 26
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 224
    Top = 19
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 224
    Top = 72
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 225
    Top = 125
  end
end
