inherited DmLstBase: TDmLstBase
  OldCreateOrder = True
  Height = 357
  Width = 299
  object MemtblLogCampos: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    StoreDefs = True
    Left = 80
    Top = 24
    object MemtblLogCamposcampo: TStringField
      FieldName = 'campo'
      Size = 80
    end
    object MemtblLogCamposvalor: TStringField
      FieldName = 'valor'
      Size = 100
    end
    object MemtblLogCamposmensagem: TStringField
      FieldName = 'mensagem'
      Size = 200
    end
  end
  object dsCadBase: TDataSource
    DataSet = qryCadbase
    Left = 120
    Top = 88
  end
  object dsLstBase: TDataSource
    DataSet = qryLstbase
    Left = 120
    Top = 148
  end
  object qryCadbase: TRESTDWClientSQL
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
    Left = 48
    Top = 88
  end
  object qryLstbase: TRESTDWClientSQL
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
    Params = <
      item
        DataType = ftUnknown
        ParamType = ptUnknown
      end>
    DataBase = UniMainModule.RESTConexao
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    InBlockEvents = False
    Left = 48
    Top = 152
  end
end
