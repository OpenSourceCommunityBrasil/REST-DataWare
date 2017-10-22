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
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
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
      
        'Database=D:\Meus Dados\Projetos\SUGV\Componentes\XyberPower\REST' +
        '_Controls\DEMO\EMPLOYEE.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Server=localhost'
      'Port=3050'
      'CharacterSet='
      'DriverID=FB')
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckDefault
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
    Provider = 'Forms'
    Left = 278
    Top = 11
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 280
    Top = 144
  end
end
