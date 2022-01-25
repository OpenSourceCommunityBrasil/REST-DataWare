inherited DmLstBaseMov: TDmLstBaseMov
  Width = 431
  object dsCadItem: TDataSource
    DataSet = qryCadItem
    Left = 352
    Top = 24
  end
  object dsLstItem: TDataSource
    DataSet = qryLstItem
    Left = 352
    Top = 88
  end
  object qryCadItem: TRESTDWClientSQL
    FieldDefs = <>
    IndexDefs = <>
    MasterFields = ''
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords, uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    MasterCascadeDelete = True
    Inactive = False
    DataCache = False
    Params = <>
    DataBase = UniMainModule.RESTConexao
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    InBlockEvents = False
    Left = 248
    Top = 24
  end
  object qryLstItem: TRESTDWClientSQL
    FieldDefs = <>
    IndexDefs = <>
    MasterFields = ''
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords, uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    MasterCascadeDelete = True
    Inactive = False
    DataCache = False
    Params = <>
    DataBase = UniMainModule.RESTConexao
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    InBlockEvents = False
    Left = 248
    Top = 88
  end
end
