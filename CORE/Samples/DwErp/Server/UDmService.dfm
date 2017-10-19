object ServerMetodDM: TServerMetodDM
  OldCreateOrder = False
  OnReplyEvent = ServerMethodDataModuleReplyEvent
  OnWelcomeMessage = ServerMethodDataModuleWelcomeMessage
  Height = 292
  Width = 683
  object RESTDWPoolerDB1: TRESTDWPoolerDB
    RESTDriver = RESTDWDriverFD1
    Compression = True
    Encoding = esASCII
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = False
    PoolerOffMessage = 'RESTPooler not active.'
    Left = 80
    Top = 168
  end
  object RESTDWDriverFD1: TRESTDWDriverFD
    Connection = Server_FDConnection
    Left = 80
    Top = 80
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 479
    Top = 23
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 357
    Top = 23
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 590
    Top = 23
  end
  object Server_FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\clientes\ativo\conflex3c.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'CharacterSet=WIN1252'
      'Port=3050'
      'Server=localhost'
      'DriverID=FB')
    FetchOptions.AssignedValues = [evMode, evCursorKind, evDetailOptimize]
    FetchOptions.Mode = fmAll
    FetchOptions.CursorKind = ckDynamic
    FetchOptions.DetailOptimize = False
    UpdateOptions.AssignedValues = [uvLockMode, uvLockWait]
    UpdateOptions.LockMode = lmPessimistic
    UpdateOptions.LockWait = True
    LoginPrompt = False
    Left = 592
    Top = 72
  end
  object qry: TFDQuery
    Connection = Server_FDConnection
    SQL.Strings = (
      '')
    Left = 592
    Top = 128
  end
  object FDStanStorageBinLink1: TFDStanStorageBinLink
    Left = 480
    Top = 72
  end
  object FDMem: TFDMemTable
    CachedUpdates = True
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 296
    Top = 216
  end
  object Qryapplyupdate: TFDQuery
    CachedUpdates = True
    Connection = Server_FDConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate, uvUpdateChngFields, uvUpdateMode, uvRefreshMode]
    SQL.Strings = (
      '')
    Left = 392
    Top = 216
  end
end
