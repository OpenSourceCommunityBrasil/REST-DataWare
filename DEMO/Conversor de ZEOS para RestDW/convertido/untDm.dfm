object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 900
  Width = 1523
  object ZConnection: TZConnection
    ControlsCodePage = cGET_ACP
    Catalog = ''
    Properties.Strings = (
      'controls_cp=GET_ACP')
    AutoCommit = False
    TransactIsolationLevel = tiReadCommitted
    Connected = True
    SQLHourGlass = True
    HostName = ''
    Port = 3050
    Database = 'c:\mkmDados\MKMDATAFILE.FDB'
    User = 'SYSDBA'
    Password = 'masterkey'
    Protocol = 'firebird-2.5'
    Left = 28
    Top = 8
  end
  object dsFormaPagto: TDataSource
    AutoEdit = False
    DataSet = zQryFormasPagto
    Left = 176
    Top = 180
  end
  object zQryFormasPagto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select FP.* from FormasPagamento FP'
      ''
      'order by FP.descricao')
    Params = <>
    Left = 176
    Top = 140
  end
  object dsTiposPagto: TDataSource
    AutoEdit = False
    DataSet = zQryTiposPagto
    Left = 228
    Top = 180
  end
  object zQryTiposPagto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from TiposPagamento'
      'order by descricao')
    Params = <>
    Left = 228
    Top = 140
  end
  object dsLogin: TDataSource
    AutoEdit = False
    DataSet = zQryLogin
    Left = 264
    Top = 8
  end
  object zQryLogin: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Acessos'
      ''
      'order by Usuario, Data, Hora')
    Params = <>
    Left = 216
    Top = 8
  end
  object dsCentroCusto: TDataSource
    AutoEdit = False
    DataSet = zQryCentroCusto
    Left = 280
    Top = 180
  end
  object zQryCentroCusto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from CentroCusto'
      'order by descricao')
    Params = <>
    Left = 280
    Top = 140
  end
  object dsBancos: TDataSource
    AutoEdit = False
    DataSet = zQryBancos
    Left = 388
    Top = 180
  end
  object zQryBancos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Bancos'
      'order by descricao')
    Params = <>
    Left = 388
    Top = 140
  end
  object dsUsuarios: TDataSource
    AutoEdit = False
    DataSet = zQryUsuarios
    Left = 388
    Top = 8
  end
  object zQryUsuarios: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Usuarios'
      ''
      'order by Nome')
    Params = <>
    Left = 324
    Top = 8
  end
  object dsGrupos: TDataSource
    AutoEdit = False
    DataSet = zQryGrupos
    Left = 24
    Top = 92
  end
  object zQryGrupos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Grupos'
      ''
      'order by descricao')
    Params = <>
    Left = 24
    Top = 52
  end
  object dsSubGrupos: TDataSource
    AutoEdit = False
    DataSet = zQrySubGrupos
    Left = 76
    Top = 92
  end
  object zQrySubGrupos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select SG.*, G.Descricao as Grupo from SubGrupos SG'
      ''
      'inner join Grupos G'
      'on G.Codigo = SG.CodiGrupo'
      ''
      'order by SG.descricao')
    Params = <>
    Left = 76
    Top = 52
  end
  object dsFretes: TDataSource
    AutoEdit = False
    DataSet = zQryFretes
    Left = 544
    Top = 520
  end
  object zQryFretes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Fretes'
      ''
      'order by descricao')
    Params = <>
    Left = 544
    Top = 480
  end
  object dsProdForn: TDataSource
    AutoEdit = False
    DataSet = zQryProdForn
    Left = 500
    Top = 92
  end
  object zQryProdForn: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select PF.*, F.Fantasia as Fornecedor from ProdFornec PF'
      ''
      'Left Join Fornecedores F'
      'on PF.CodiFor = F.Codigo'
      ''
      'Where PF.CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 500
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsProdutos: TDataSource
    AutoEdit = False
    DataSet = zQryProdutos
    Left = 444
    Top = 92
  end
  object zQryProdutos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Produtos'
      ''
      'order by descricao')
    Params = <>
    Left = 444
    Top = 52
  end
  object dsClientes: TDataSource
    AutoEdit = False
    DataSet = zQryClientes
    Left = 200
    Top = 92
  end
  object zQryClientes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa , C.*  '
      ''
      'from Clientes C'
      ''
      'Left Join Empresas E'
      'On E.Codigo = C.CodiEmp'
      ''
      'order by Nome')
    Params = <>
    Left = 200
    Top = 52
  end
  object dsFornecedores: TDataSource
    AutoEdit = False
    DataSet = zQryFornecedores
    Left = 120
    Top = 92
  end
  object zQryFornecedores: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Fornecedores'
      ''
      'order by Fantasia')
    Params = <>
    Left = 120
    Top = 52
  end
  object dsFuncionarios: TDataSource
    AutoEdit = False
    DataSet = zQryFuncionarios
    Left = 20
    Top = 180
  end
  object zQryFuncionarios: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa, F.* '
      ''
      'from Funcionarios F'
      ''
      'Left Join Empresas E'
      'On E.Codigo = F.CodiEmp'
      ''
      'order by Nome')
    Params = <>
    Left = 20
    Top = 140
  end
  object dsCargos: TDataSource
    AutoEdit = False
    DataSet = zQryCargos
    Left = 440
    Top = 180
  end
  object zQryCargos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Cargos'
      'order by descricao')
    Params = <>
    Left = 440
    Top = 140
  end
  object zQryTransportadoras: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Transportadoras'
      ''
      'order by Fantasia')
    Params = <>
    Left = 944
    Top = 228
  end
  object dsTransportadoras: TDataSource
    AutoEdit = False
    DataSet = zQryTransportadoras
    Left = 944
    Top = 268
  end
  object dsMontadoras: TDataSource
    AutoEdit = False
    DataSet = zQryMontadoras
    Left = 28
    Top = 520
  end
  object zQryMontadoras: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Montadoras'
      'order by descricao')
    Params = <>
    Left = 28
    Top = 480
  end
  object dsCarros: TDataSource
    AutoEdit = False
    DataSet = zQryCarros
    Left = 80
    Top = 520
  end
  object zQryCarros: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Carros'
      'order by descricao')
    Params = <>
    Left = 80
    Top = 480
  end
  object dsCombustiveis: TDataSource
    AutoEdit = False
    DataSet = zQryCombustiveis
    Left = 136
    Top = 520
  end
  object zQryCombustiveis: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Combustiveis'
      'order by descricao')
    Params = <>
    Left = 136
    Top = 480
  end
  object dsFuracoes: TDataSource
    AutoEdit = False
    DataSet = zQryFuracoes
    Left = 192
    Top = 520
  end
  object zQryFuracoes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Furacoes'
      'order by descricao')
    Params = <>
    Left = 192
    Top = 480
  end
  object dsAros: TDataSource
    AutoEdit = False
    DataSet = zQryTamAros
    Left = 248
    Top = 520
  end
  object zQryTamAros: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from TamAros'
      'order by descricao')
    Params = <>
    Left = 248
    Top = 480
  end
  object dsTipoPneus: TDataSource
    AutoEdit = False
    DataSet = zQryTipoPneus
    Left = 304
    Top = 520
  end
  object zQryTipoPneus: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from TipoPneus'
      'order by descricao')
    Params = <>
    Left = 304
    Top = 480
  end
  object dsCustos: TDataSource
    AutoEdit = False
    DataSet = zQryCustos
    Left = 332
    Top = 180
  end
  object zQryCustos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Custos'
      'order by descricao')
    Params = <>
    Left = 332
    Top = 140
  end
  object dsProdCustos: TDataSource
    AutoEdit = False
    DataSet = zQryProdCustos
    Left = 556
    Top = 92
  end
  object zQryProdCustos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select C.Descricao as Custo , PC.* from ProdCustos PC'
      ''
      'Left Join Custos C'
      'on C.Codigo = PC.CodiCusto'
      ''
      'Where PC.CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 556
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsEmpresas: TDataSource
    AutoEdit = False
    DataSet = zQryEmpresas
    Left = 520
    Top = 8
  end
  object zQryEmpresas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Empresas'
      ''
      'order by Descricao')
    Params = <>
    Left = 456
    Top = 8
  end
  object dsConvenios: TDataSource
    AutoEdit = False
    DataSet = zQryConvenios
    Left = 492
    Top = 180
  end
  object zQryConvenios: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Convenios'
      'order by descricao')
    Params = <>
    Left = 492
    Top = 140
  end
  object dsProdEstoque: TDataSource
    AutoEdit = False
    DataSet = zQryProdEstoque
    Left = 612
    Top = 92
  end
  object zQryProdEstoque: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa, '
        '       PE.Atual, PE.EstMin, PE.EstCritico, PE.EstMax, PE.Multipl' +
        'icador,'
      '       PE.EstPedCompra as Pendente,'
      '       PE.EstPedVenda as Reservado,'
      '       PE.EstAtualIni , PE.Codigo, PE.CodiEmp, PE.CodiProd'
      ''
      'from ProdEstoque PE'
      ''
      'Left Join Empresas E'
      'on E.Codigo = PE.CodiEmp'
      ''
      'Where PE.CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 612
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsProdAplic: TDataSource
    AutoEdit = False
    DataSet = zQryProdAplic
    Left = 668
    Top = 92
  end
  object zQryProdAplic: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select C.Descricao as Carro, PA.*'
      ''
      'from ProdAplicacoes PA'
      ''
      'Left Join Carros C'
      'on C.Codigo = PA.CodiCarro'
      ''
      'Where PA.CodiProduto = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 668
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryServicos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Servicos'
      ''
      'order by descricao')
    Params = <>
    Left = 1004
    Top = 52
  end
  object dsServicos: TDataSource
    AutoEdit = False
    DataSet = zQryServicos
    Left = 1004
    Top = 92
  end
  object zQryServCustos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select C.Descricao as Custo , SC.* from ServCustos SC'
      ''
      'Left Join Custos C'
      'on C.Codigo = SC.CodiCusto'
      ''
      'Where SC.CodiServ = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsServicos
    Left = 1064
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsServCustos: TDataSource
    AutoEdit = False
    DataSet = zQryServCustos
    Left = 1064
    Top = 92
  end
  object dsParametros: TDataSource
    AutoEdit = False
    DataSet = zQryParametros
    Left = 164
    Top = 8
  end
  object zQryParametros: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select '
      ''
      'p.*, '
      'p1.seqnivel as caixa,'
      'p2.seqnivel as vendaavista,'
      'p3.seqnivel as vendaaprazo,'
      'p4.seqnivel as compraavista,'
      'p5.seqnivel as compraaprazo'
      ''
      'from Parametros p'
      ''
      'left join planocontas p1'
      'on p1.codigo = p.conta_caixa'
      ''
      'left join planocontas p2'
      'on p2.codigo = p.conta_vendaavista'
      ''
      'left join planocontas p3'
      'on p3.codigo = p.conta_vendaaprazo'
      ''
      'left join planocontas p4'
      'on p4.codigo = p.conta_compraavista'
      ''
      'left join planocontas p5'
      'on p5.codigo = p.conta_compraaprazo')
    Params = <>
    Left = 112
    Top = 8
  end
  object dsASCII: TDataSource
    AutoEdit = False
    DataSet = zQryASCII
    Left = 628
    Top = 8
  end
  object zQryASCII: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from ASCII'
      ''
      '')
    Params = <>
    Left = 580
    Top = 8
  end
  object zQryCadGeral: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    Params = <>
    Left = 680
    Top = 8
  end
  object dsCadGeral: TDataSource
    DataSet = zQryCadGeral
    Left = 731
    Top = 8
  end
  object dsCliVeiculos: TDataSource
    AutoEdit = False
    DataSet = zQryCliVeiculos
    Left = 256
    Top = 92
  end
  object zQryCliVeiculos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  V.*, M.Descricao as Montadora, '
      #9'C.Descricao as Carro, '
      #9'Co.Descricao as Combustivel'
      ''
      'from Veiculos V'
      #9
      'Left Join Carros C'
      'On C.Codigo = V.CodiCarro'
      ''
      'Left Join Montadoras M'
      'On M.Codigo = V.CodiMontadora'
      ''
      'Left Join Combustiveis Co'
      'On Co.Codigo = V.CodiCombustivel'
      ''
      'Where V.CodiCli = :Codigo'
      ''
      'order by V.CodiCli')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsClientes
    Left = 256
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    object zQryCliVeiculosVENDIDO: TStringField
      FieldName = 'VENDIDO'
      Size = 1
    end
    object zQryCliVeiculosPLACA: TStringField
      DisplayWidth = 7
      FieldName = 'PLACA'
      EditMask = 'AAA-9999;0; '
      Size = 7
    end
    object zQryCliVeiculosMONTADORA: TStringField
      FieldName = 'MONTADORA'
    end
    object zQryCliVeiculosCARRO: TStringField
      FieldName = 'CARRO'
    end
    object zQryCliVeiculosDESCRICAO: TStringField
      FieldName = 'DESCRICAO'
      Size = 30
    end
    object zQryCliVeiculosCOMBUSTIVEL: TStringField
      FieldName = 'COMBUSTIVEL'
      Size = 30
    end
    object zQryCliVeiculosANO: TIntegerField
      FieldName = 'ANO'
    end
    object zQryCliVeiculosMODELO: TIntegerField
      FieldName = 'MODELO'
    end
    object zQryCliVeiculosCHASSIS: TStringField
      FieldName = 'CHASSIS'
      Size = 30
    end
    object zQryCliVeiculosUSUARIO: TStringField
      FieldName = 'USUARIO'
      Size = 30
    end
    object zQryCliVeiculosCODIGO: TIntegerField
      FieldName = 'CODIGO'
      Required = True
    end
    object zQryCliVeiculosCODICARRO: TIntegerField
      FieldName = 'CODICARRO'
    end
    object zQryCliVeiculosCODICLI: TIntegerField
      FieldName = 'CODICLI'
    end
    object zQryCliVeiculosCODICOMBUSTIVEL: TIntegerField
      FieldName = 'CODICOMBUSTIVEL'
    end
  end
  object dsOSes: TDataSource
    AutoEdit = False
    DataSet = zQryOSes
    Left = 568
    Top = 180
  end
  object zQryOSes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select FIRST 1 E.Descricao as Empresa, OS.* , C.Descricao as Con' +
        'venio, C.Desconto, OSConf.Situacao as Conferido'
      ''
      'from OSes OS'
      ''
      'Left Join Empresas E'
      'On E.Codigo = OS.CodiEmp'
      ''
      'Left Join Convenios C'
      'on C.Codigo = OS.CodiConv'
      ''
      'Left Join OSES_Conferencia OSConf'
      'on OSConf.codigo = OS.codigo'
      ''
      ''
      'order by OS.Codigo, OS.DtCadastro, OS.HoraEntrada')
    Params = <>
    Left = 568
    Top = 140
  end
  object zQrySeguradoras: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Seguradoras'
      ''
      'order by Fantasia')
    Params = <>
    Left = 996
    Top = 228
  end
  object dsSeguradoras: TDataSource
    AutoEdit = False
    DataSet = zQrySeguradoras
    Left = 996
    Top = 268
  end
  object dsOSesPecas: TDataSource
    AutoEdit = False
    DataSet = zQryOSesPecas
    Left = 628
    Top = 180
  end
  object zQryOSesPecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  cAST( SUBSTRING ( P.Equiv1 FROM 1 FOR 12 )  AS VARCHAR(1' +
        '3) ) AS CODINTERNO, '
        '                substring( OP.Descricao from 1 for 45 ) as Peca ' +
        ','
      #9'OP.Qtde, OP.ValorUnit as Valor_Unit, '
        #9'OP.Desconto1_Valor as Desc_1, OP.TotalProd, OP.CodiProd, P.Refe' +
        'rencia, '
      #9'OP.CodiOS,'
      #9'OP.CodiFunc1, OP.Codigo , OP.Apoio As ASeq, '
        #9' OP.CodiEmp, OP.CodiProd, P.CodiGrupo,  P.ComissaoValor,  P.Equ' +
        'iv1,'
      #9'OP.ValCusto, OP.Apoio, OP.Desconto2_Valor as Desc_2, '
      #9'OP.Desconto3_Valor as Desc_3, OP.Devolvido, op.Desconto1_Porc, '
        '                OP.Codicategoria, op.codibarra, op.data, op.larg' +
        'ura, op.altura, op.m_quad,'
        '                OP.NumSerial, P.Descricao_ECF, OP.Unidade, OP.Se' +
        'q_CAD,'
        '               OP.sit_trib, OP.aliquota_ecf , OP.cod_totalizador' +
        '_trib , OP.val_basecalculo , OP.val_reducao_bc, OP.val_imposto,'
        '               OP.seq_davpv , OP.CODI_SEQ_ORIGEM, OP.PDV, op.coo' +
        ', op.ccf, P.IAT, P.IPPT, p.classifiscal, p.IMPOSTO_ICMS_CST'
      ''
      'from OSes_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Left Join Grupos G'
      'on G.Codigo = P.CodiGrupo'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.Codigo DESC')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsOSes
    Left = 628
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsOSesServicos: TDataSource
    AutoEdit = False
    DataSet = zQryOSesServicos
    Left = 684
    Top = 180
  end
  object zQryOSesServicos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  OS.Descricao as Servico ,  OS.NumSerial as Formato, OS.Q' +
        'tde, OS.ValorUnit as Valor_Unit, '
      #9'OS.Desconto1_Valor as Desc_1, OS.TotalServ, '
        #9'OS.CodiFunc1, OS.CodiFunc2, OS.CodiFunc3, OS.CodiFunc4, OS.Codi' +
        'Func5,OS.CodiFunc6,OS.CodiFunc7,'
      '        OS.Codigo, OS.CodiEmp, OS.CodiOS, OS.CodiServ,'
      ' '#9'S.CodiGrupo,  S.ComissaoValor, S.ValFunc, OS.ValorUnitFunc,'
        #9'OS.ComissaoF1_Porc, OS.ComissaoF2_Porc, OS.ComissaoF3_Porc, OS.' +
        'ComissaoF4_Porc, '
        #9'OS.ComissaoF5_Porc , OS.ComissaoF6_Porc , OS.ComissaoF7_Porc , ' +
        'OS.Desconto1_Porc, OS.Desconto3_Porc, OS.Desconto3_Valor, '
      '               OS.CorRecebido as Cor, '
        '                OS. MarcaRecebido as Marca, OS.ProdRecebido as P' +
        'roduto,OS.devolvido,'
        '               OS.sit_trib, OS.aliquota_ecf , OS.cod_totalizador' +
        '_trib , OS.val_basecalculo , OS.val_reducao_bc, OS.val_imposto,'
        '               OS.seq_davpv , OS.CODI_SEQ_ORIGEM, OS.SEQ_CAD, OS' +
        '.PDV, os.coo, os.ccf'
      ''
      ''
      'from OSes_Servicos OS'
      ''
      'Left Join Servicos S'
      'on S.Codigo = OS.CodiServ'
      ''
      'Where OS.CodiOs = :Codigo'
      ''
      'order by OS.CodiOs, OS.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsOSes
    Left = 684
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryConsultaGeral: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    Params = <>
    Left = 796
    Top = 8
  end
  object dsConsultaGeral: TDataSource
    DataSet = zQryConsultaGeral
    Left = 847
    Top = 8
  end
  object dsOSesPagto: TDataSource
    AutoEdit = False
    DataSet = zQryOSesPagto
    Left = 740
    Top = 180
  end
  object zQryOSesPagto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  F.Descricao as Forma_Pagto, OP.Valor, OP.NumDocumento, '
      #9'OP.Juros , OP.Taxa_ADM, OP.Corrigido , OP.Data, OP.Codigo, '
      #9'F.Codigo as CodiFPagto, F.CodiTipo as TipoPagto, '
      #9'OP.Codifunc1 , OP.CodiEmp, OP.CodiOs, OP.CodiFormaPagto,'
        #9'OP.SeqContaDespRec, OP.SeqContaCxBanco , TP.Descricao as Tipodo' +
        'Pagto,'
      #9'OP.CodiBanco, OP.NumConta, OP.NumAgencia, '
        '                OP.Num_Serie_Ecf, OP.MF_ADICIONAL, OP.NUM_USUARI' +
        'O, OP.COO, OP.CCF,OP.GNF,OP.INDICADOR_ESTORNO,OP.VALOR_ESTORNADO' +
        ','
        '                OP.TEF_NSU_TRANSACAO, OP.TEF_CODIGO_AUTORIZACAO,' +
        ' OP.VALOR_INFORMADO'
      ''
      'from OSes_Pagamento OP'
      ''
      'Left Join FormasPagamento F'
      'on F.Codigo = OP.CodiFormaPagto'
      ''
      'Left Join TiposPagamento TP'
      'on TP.Codigo = OP.CodiTipoPagto'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsOSes
    Left = 740
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsSessoes: TDataSource
    AutoEdit = False
    DataSet = zQrySessoes
    Left = 420
    Top = 520
  end
  object zQrySessoes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select *'
      ''
      'from Sessoes'
      ''
      'order by Descricao')
    Params = <>
    Left = 420
    Top = 480
  end
  object dsMarcas: TDataSource
    AutoEdit = False
    DataSet = zQryMarcas
    Left = 360
    Top = 520
  end
  object zQryMarcas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Marcas'
      'order by descricao')
    Params = <>
    Left = 360
    Top = 480
  end
  object zQryFunc_Prod: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select P.Descricao as Produto, FP.* '
      ''
      'from Func_Prod FP'
      ''
      'Left Join Produtos P'
      'On P.Codigo = FP.CodiProd'
      ''
      'Where FP.CodiFunc = :Codigo'
      ''
      'order by FP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsFuncionarios
    Left = 72
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    object zQryFunc_ProdPRODUTO: TStringField
      DisplayWidth = 40
      FieldName = 'PRODUTO'
      Size = 60
    end
    object zQryFunc_ProdCOMISSAO: TFloatField
      FieldName = 'COMISSAO'
    end
    object zQryFunc_ProdCODIGO: TIntegerField
      FieldName = 'CODIGO'
    end
  end
  object dsFunc_Prod: TDataSource
    AutoEdit = False
    DataSet = zQryFunc_Prod
    Left = 72
    Top = 180
  end
  object zQryFunc_Serv: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select S.Descricao as Servico, FS.* '
      ''
      'from Func_Serv FS'
      ''
      'Left Join Servicos S'
      'On S.Codigo = FS.CodiServ'
      ''
      'Where FS.CodiFunc = :Codigo'
      ''
      'order by FS.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsFuncionarios
    Left = 124
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    object zQryFunc_ServSERVICO: TStringField
      DisplayWidth = 40
      FieldName = 'SERVICO'
      Size = 100
    end
    object zQryFunc_ServCOMISSAO: TFloatField
      FieldName = 'COMISSAO'
    end
    object zQryFunc_ServCODIGO: TIntegerField
      FieldName = 'CODIGO'
    end
  end
  object dsFunc_Serv: TDataSource
    AutoEdit = False
    DataSet = zQryFunc_Serv
    Left = 124
    Top = 180
  end
  object zQryContasReceber: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select CR.* ,'
        '( select fp.coditipo from formaspagamento fp where fp.codigo = c' +
        'r.codiformapagto_orig ) as CodiTipoPag'
      ''
      'from ContasReceber CR'
      ''
      'Left Join Empresas E'
      'On E.Codigo = CR.CodiEmp'
      ''
      'order by CR.DTVencimento')
    Params = <>
    Left = 64
    Top = 324
  end
  object dsContasReceber: TDataSource
    AutoEdit = False
    DataSet = zQryContasReceber
    Left = 64
    Top = 364
  end
  object zQryPlanoContas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select PC.* '
      ''
      'from PlanoContas PC'
      ''
      'Left Join Empresas E'
      'On E.Codigo = PC.CodiEmp'
      ''
      'order by SeqNivel')
    Params = <>
    Left = 24
    Top = 324
  end
  object dsPlanoContas: TDataSource
    AutoEdit = False
    DataSet = zQryPlanoContas
    Left = 24
    Top = 364
  end
  object dsCFOPs: TDataSource
    AutoEdit = False
    DataSet = zQryCFOPs
    Left = 480
    Top = 520
  end
  object zQryCFOPs: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from CFOP'
      ''
      'order by descricao')
    Params = <>
    Left = 480
    Top = 480
  end
  object dsProdComposicao: TDataSource
    AutoEdit = False
    DataSet = zQryProdComposicao
    Left = 720
    Top = 92
  end
  object zQryProdComposicao: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select P.Descricao as Produto, PC.Qtde, PC.CodiProd, PC.CodiProd' +
        'Comp, PC.Codigo'
      ''
      'from ProdComposicao PC'
      ''
      'Left Join Produtos P'
      'on P.Codigo = PC.CodiProdComp'
      ''
      'Where PC.CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 720
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsCompras: TDataSource
    AutoEdit = False
    DataSet = zQryCompras
    Left = 652
    Top = 268
  end
  object zQryCompras: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa, C.* , F.Fantasia as Fornecedor'
      ''
      'from Compras C'
      ''
      'Left Join Empresas E'
      'On E.Codigo = C.CodiEmp'
      ''
      'Left Join Fornecedores F'
      'on F.Codigo = C.CodiForn'
      ''
      ''
      'order by C.Codigo, C.DtCadastro, C.HoraEntrada')
    Params = <>
    Left = 652
    Top = 228
  end
  object dsComprasPecas: TDataSource
    AutoEdit = False
    DataSet = zQryComprasPecas
    Left = 712
    Top = 268
  end
  object zQryComprasPecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  P.Descricao as Peca , CP.Qtde, CP.ValorUnit as Valor_Uni' +
        't, '
        #9'CP.Desconto1_Valor as Desc_1, CP.Desconto2_Valor as Desc_2, Cp.' +
        'ValCheio,'
        #9'CP.TotalProd, CP.CodiFunc1, CP.Codigo , CP.CodiOS ,CP.CodiProd,' +
        ' CP.Apoio As ASeq, CP.QtdeVenda , CP.Data,'
        #9'P.ValCustoMedio, P.ValCompra, P.ValUltCompra, CP.Ipi_Porc, CP.O' +
        'S_Casada, CP.Qtde_Venda, '
        #9'CP.ValorUnit_Venda, CP.Desconto1_Porc, CP.Desconto2_Porc,  CP.D' +
        'esconto3_Porc,  '
      #9'CP.Desconto1_Real,  CP.Desconto2_Real,  '
      #9'CP.Ipi_Porc,  CP.Ipi_Valor, CP.Icms_St, CP.Icms_St_Valor, '
        #9'CP.QtdeCheio, CP.TotalCheio, CP.ValCheio, CP.QtdeApoio, CP.Lote' +
        ', CP.Garantia_Compra, CP.Garantia_Venda, CP.CodiForn'
      ''
      'from Compras_Pecas CP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = CP.Codiprod'
      ''
      'Where CP.CodiOs = :Codigo'
      ''
      'order by CP.CodiOs, CP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsCompras
    Left = 712
    Top = 228
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsComprasServicos: TDataSource
    AutoEdit = False
    DataSet = zQryComprasServicos
    Left = 768
    Top = 268
  end
  object zQryComprasServicos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  S.Descricao as Servico , CS.Qtde, CS.ValorUnit as Valor_' +
        'Unit, '
      #9'CS.Desconto1_Valor as Desc_1, CS.TotalServ, '
        #9'CS.CodiFunc1, CS.CodiFunc2, CS.CodiFunc3, CS.CodiFunc4, CS.Codi' +
        'Func5,'
      '        CS.Codigo, CS.CodiEmp'
      ''
      'from Compras_Servicos CS'
      ''
      'Left Join Servicos S'
      'on S.Codigo = CS.CodiServ'
      ''
      'Where CS.CodiOs = :Codigo'
      ''
      'order by CS.CodiOs, CS.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsCompras
    Left = 768
    Top = 228
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsComprasPagto: TDataSource
    AutoEdit = False
    DataSet = zQryComprasPagto
    Left = 824
    Top = 268
  end
  object zQryComprasPagto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  F.Descricao as Forma_Pagto, CP.Valor, CP.NumDocumento, C' +
        'P.Juros , CP.Taxa_ADM, '
        #9'CP.Corrigido , CP.Data, CP.Codigo, F.Codigo as CodiFPagto, F.Co' +
        'diTipo as TipoPagto,'
      #9'CP.SeqContaDespRec, CP.SeqContaCxBanco'
      ''
      'from Compras_Pagamento CP'
      ''
      'Left Join FormasPagamento F'
      'on F.Codigo = CP.CodiFormaPagto'
      ''
      'Where CP.CodiOs = :Codigo'
      ''
      'order by CP.CodiOs, CP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsCompras
    Left = 824
    Top = 228
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryHistoricoReceber: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  FP.Descricao as FormaRecebto, HR.DtCadastro as DtRecebto' +
        ','
      #9'HR.NumDocumento,'
        #9'HR.ValorRecebido , HR.ValorCorrigido, PC.SeqNivel||'#39'-'#39'||PC.Desc' +
        'ricao as Conta_C,'
        #9'HR.ValorJuros, HR.ValorMulta, HR.ValorDesconto, FP.CodiTipo as ' +
        'TipoPagto,'
        #9'HR.CodiContaEntrada, Hr.CodiContaDespRec, HR.CodiEmp, HR.Codigo' +
        ', HR.Apoio, HR.NovoCredito'
      #9
      ''
      'from HistoricoReceber HR'
      ''
      'Left Join FormasPagamento FP'
      'On FP.Codigo = HR.CodiFormaPagto'
      ''
      'Left Join PlanoContas PC'
      'On PC.Codigo = HR.CodiContaEntrada'
      ''
      'where HR.CodiReceber = :Codigo'
      ''
      'and HR.CodiEmp = PC.CodiEmp'
      ''
      'order by HR.DTCadastro')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsContasReceber
    Left = 104
    Top = 324
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsHistoricoReceber: TDataSource
    AutoEdit = False
    DataSet = zQryHistoricoReceber
    Left = 104
    Top = 364
  end
  object zQryContasPagar: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select CP.* , '
        '( select fp.coditipo from formaspagamento fp where fp.codigo = c' +
        'p.codiformapagto_orig ) as CodiTipoPag'
      ''
      'from ContasPagar CP'
      ''
      'Left Join Empresas E'
      'On E.Codigo = CP.CodiEmp'
      ''
      'order by CP.DTVencimento')
    Params = <>
    Left = 144
    Top = 324
  end
  object dsContasPagar: TDataSource
    AutoEdit = False
    DataSet = zQryContasPagar
    Left = 144
    Top = 364
  end
  object zQryHistoricoPagar: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  FP.Descricao as FormaPagto, HP.DtCadastro as DtPagto,'
      #9'HP.NumDocumento,'
      #9'HP.ValorPago , HP.ValorCorrigido, '
      '        PC.SeqNivel||'#39'-'#39'||PC.Descricao as Conta_Baixa,'
      '        PC1.SeqNivel||'#39'-'#39'||PC1.Descricao as Conta_Desp,'
        #9'HP.ValorJuros, HP.ValorMulta, HP.ValorDesconto, FP.CodiTipo as ' +
        'TipoPagto,'
        #9'HP.CodiContaSaida, HP.CodiContaDespRec, HP.CodiEmp, HP.Codigo, ' +
        'HP.Apoio'
      #9
      ''
      'from HistoricoPagar HP'
      ''
      'Left Join FormasPagamento FP'
      'On FP.Codigo = HP.CodiFormaPagto'
      ''
      'Left Join PlanoContas PC'
      'On PC.Codigo = HP.CodiContaSaida'
      ''
      'Left Join PlanoContas PC1'
      'On PC1.Codigo = HP.CodiContaDespRec'
      ''
      'where HP.CodiPagar = :Codigo'
      ''
      'and HP.CodiEmp = PC.CodiEmp'
      ''
      'order by HP.DTCadastro')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsContasPagar
    Left = 188
    Top = 324
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    object zQryHistoricoPagarFORMAPAGTO: TStringField
      FieldName = 'FORMAPAGTO'
      Size = 30
    end
    object zQryHistoricoPagarDTPAGTO: TDateField
      FieldName = 'DTPAGTO'
      Required = True
    end
    object zQryHistoricoPagarNUMDOCUMENTO: TStringField
      FieldName = 'NUMDOCUMENTO'
      Size = 30
    end
    object zQryHistoricoPagarVALORPAGO: TFloatField
      FieldName = 'VALORPAGO'
    end
    object zQryHistoricoPagarVALORCORRIGIDO: TFloatField
      FieldName = 'VALORCORRIGIDO'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryHistoricoPagarVALORJUROS: TFloatField
      FieldName = 'VALORJUROS'
    end
    object zQryHistoricoPagarVALORMULTA: TFloatField
      FieldName = 'VALORMULTA'
    end
    object zQryHistoricoPagarVALORDESCONTO: TFloatField
      FieldName = 'VALORDESCONTO'
    end
    object zQryHistoricoPagarTIPOPAGTO: TIntegerField
      FieldName = 'TIPOPAGTO'
    end
    object zQryHistoricoPagarCODICONTASAIDA: TIntegerField
      FieldName = 'CODICONTASAIDA'
    end
    object zQryHistoricoPagarCODICONTADESPREC: TIntegerField
      FieldName = 'CODICONTADESPREC'
    end
    object zQryHistoricoPagarCODIEMP: TIntegerField
      FieldName = 'CODIEMP'
    end
    object zQryHistoricoPagarCODIGO: TIntegerField
      FieldName = 'CODIGO'
      Required = True
    end
    object zQryHistoricoPagarAPOIO: TStringField
      FieldName = 'APOIO'
      Size = 1
    end
    object zQryHistoricoPagarCONTA_BAIXA: TStringField
      FieldName = 'CONTA_BAIXA'
      Size = 65
    end
    object zQryHistoricoPagarCONTA_DESP: TStringField
      FieldName = 'CONTA_DESP'
      Size = 65
    end
  end
  object dsHistoricoPagar: TDataSource
    AutoEdit = False
    DataSet = zQryHistoricoPagar
    Left = 188
    Top = 364
  end
  object zQryMovDia: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select MD.* '
      ''
      'from MovDia MD'
      ''
      'Left Join Empresas E'
      'On E.Codigo = MD.CodiEmp'
      ''
      'order by DtCadastro')
    Params = <>
    Left = 232
    Top = 324
  end
  object dsMovDia: TDataSource
    AutoEdit = False
    DataSet = zQryMovDia
    Left = 232
    Top = 364
  end
  object dsRecibos: TDataSource
    AutoEdit = False
    DataSet = zQryRecibos
    Left = 604
    Top = 520
  end
  object zQryRecibos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Recibos'
      ''
      'order by Data, descricao')
    Params = <>
    Left = 604
    Top = 480
  end
  object dsProventos: TDataSource
    AutoEdit = False
    DataSet = zQryProventos
    Left = 1416
    Top = 512
  end
  object zQryProventos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Proventos'
      ''
      'order by descricao')
    Params = <>
    Left = 1416
    Top = 472
  end
  object zQryNFSPecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  NFP.Descricao as Peca , NFP.Qtde, NFP.ValorUnit, NFP.Tot' +
        'alProd, NFP.CodiProd,'
        #9'NFP.Codigo, NFP.SeqItem, nfp.pESO_bRUTO, NFP.PESO_LIQUIDO, NFP.' +
        'Unidade, NFP.Icms, NFP.Ipi, nfp.cfop, nfp.cst, nfp.valor_icms, n' +
        'fp.codibarras,'
        '               NFP.QtdeCom, NFP.UnidadeCom, NFP.ValorUnitCom, nf' +
        'p.desconto, nfp.descontoperc, nfp.cst_ipi, nfp.ipi_codenquadrame' +
        'nto, nfp.origem, nfp.cst_icms,  nfp.valor_ipi,'
        '                 nfp.valor_frete, nfp.valor_seguro, nfp.classifi' +
        'scal, nfp.equiv1, nfp.cst_pis, nfp.cst_cofins, nfp.valor_pis, nf' +
        'p.valor_cofins, nfp.pis, nfp.cofins, '
        '                 nfp.descri_arma, nfp.tipouso, nfp.numserie, nfp' +
        '.numcano, p.equiv4 as tipousoarma, NFP.percentual_reducao,'
        '               nfp.valor_desp_anu, nfp.valor_ii, nfp.valor_bc_ii' +
        ', nfp.valor_iof, nfp.valor_outros, P.Referencia,'
      '    nfp.CSOSN,'
      '    nfp.COMPOETOTALNF               ,'
      '    nfp.PRODESPECIFICO              ,'
      '    nfp.REGIMEICMS                  ,'
      '    nfp.ALIQCREDITO                 ,'
      '    nfp.CREDAPROVEITADO             ,'
      '    nfp.MODAL_DET_BC_ICMS           ,'
      '    nfp.ALIQ_BC_OPER_PROP           ,'
      '    nfp.MODAL_DET_BC_ICMS_ST        ,'
      '    nfp.BASECALCICMS_ST             ,'
      '    nfp.PERCENTUAL_REDUCAO_ICMS_ST  ,'
      '    nfp.BC_ICMS_ST_RET_UF_REM       ,'
      '    nfp.VAL_ICMS_ST_RET_UF_REM      ,'
      '    nfp.BC_ICMS_ST_RET_ANT          ,'
      '    nfp.VAL_ICMS_ST_RET_ANT         ,'
      '    nfp.UF_ICMS_ST_DEVIDO           ,'
      '    nfp.CLASSENQUADRAM              ,'
      '    nfp.CNPJPRODUTOR                ,'
      '    nfp.CODSELOCONTROLE             ,'
      '    nfp.QTDESELO                    ,'
      '    nfp.TIPOCALCIPI                 ,'
      '    nfp.BC_IPI                      ,'
      '    nfp.QTDETOTUNIDADEIPI           ,'
      '    nfp.VALORUNIDADEIPI             ,'
      '    nfp.TIPOCALCPIS                 ,'
      '    nfp.BC_PIS                      ,'
      '    nfp.ALIQUOTAREALPIS             ,'
      '    nfp.QTDEVENDIDAPIS              ,'
      '    nfp.TIPOCALCPISST               ,'
      '    nfp.BC_PIS_ST                   ,'
      '    nfp.PIS_ST                      ,'
      '    nfp.ALIQUOTAREALPISST           ,'
      '    nfp.QTDEVENDIDAPISST            ,'
      '    nfp.VALOR_PIS_ST                ,'
      '    nfp.TIPOCALCCOFINS              ,'
      '    nfp.BC_COFINS                   ,'
      '    nfp.ALIQUOTAREALCOFINS          ,'
      '    nfp.QTDEVENDIDACOFINS           ,'
      '    nfp.TIPOCALCCOFINSST            ,'
      '    nfp.BC_COFINS_ST                ,'
      '    nfp.COFINS_ST                   ,'
      '    nfp.ALIQUOTAREALCOFINSST        ,'
      '    nfp.QTDEVENDIDACOFINSST         ,'
      '    nfp.VALOR_COFINS_ST             ,'
      '    nfp.TIPOOPERACAOVEICULO         ,'
      '    nfp.CONDICAOVEICULO             ,'
      '    nfp.CHASSIVEICULO               ,'
      '    nfp.CHASSIREMARCADOVEICULO      ,'
      '    nfp.SERIEVEICULO                ,'
      '    nfp.NUMMOTORVEICULO             ,'
      '    nfp.POTENCIAVEICULO             ,'
      '    nfp.CILINDRADASVEICULO          ,'
      '    nfp.PESOLVEICULO                ,'
      '    nfp.PESOBVEICULO                ,'
      '    nfp.TRACAOVEICULO               ,'
      '    nfp.DISTEIXOSVEICULO            ,'
      '    nfp.TIPOCOMBUSTIVELVEICULO      ,'
      '    nfp.TIPOVEICULO                 ,'
      '    nfp.CODMARCAVEICULO             ,'
      '    nfp.ANOFABRICVEICULO            ,'
      '    nfp.ANOMODELOVEICULO            ,'
      '    nfp.CODCORDENATRANVEICULO       ,'
      '    nfp.CODCORMONTADORAVEICULO      ,'
      '    nfp.TIPOPINTURAVEICULO          ,'
      '    nfp.DESCRICORVEICULO            ,'
      '    nfp.ESPECIEVEICULO              ,'
      '    nfp.LOCATACAOVEICULO            ,'
      '    nfp.RESTRICAOVEICULO,'
      '    nfp.EX_TIPI,'
      '    nfp.GENERO,'
      '    nfp.CARGAMAXVEICULO,'
      '    nfp.RENAVAMVEICULO,'
      '    nfp.VIN_VEICULO,'
      '    nfp.MVA_ICMS_ST,'
      '    nfp.MOTIVODESONERACAO_ICMS,'
      '    nfp.REPASSE_CST,'
      '    nfp.PARTILHA_CST,'
      '    nfp.BC_ICMS_ST_RET_UF_DEST ,'
      '    nfp.VAL_ICMS_ST_RET_UF_DEST ,'
      '    nfp.BASECALCICMS,'
      '    nfp.BASECALCICMS_ST,'
      '    nfp.ICMS_SUBST,'
      '    nfp.VALOR_ICMS_SUBST,'
      '    nfp.inf_adicionais_prod,'
      '    nfp.valor_icms_subst,'
      '    nfp.codifunc1,'
      '    nfp.COMISSAOF1_PORC,'
      '    nfp.COMISSAOF1_VALOR,'
      '    nfp.VALCUSTO'
      ''
      'from NFS_PRODS NFP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = NFP.Codiprod'
      ''
      'Where NFP.CodiNF = :Codigo'
      ''
      'order by NFP.CodiNF, NFP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsNFs
    Left = 720
    Top = 480
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryNFSservicos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  NFS.Descricao as Servico , NFS.Qtde, NFS.ValorUnit, NFS.' +
        'TotalServ, NFs.CodiServ,'
      #9'NFs.Codigo, NFs.CodiEmp, NFS.SeqItem'
      ''
      'from NFS_SERVS NFS'
      ''
      'Left Join Servicos S'
      'on S.Codigo = NFS.CodiServ'
      ''
      'Where NFS.CodiNF = :Codigo'
      ''
      'order by NFS.CodiNF, NFS.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsNFs
    Left = 772
    Top = 480
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsNFSservicos: TDataSource
    AutoEdit = False
    DataSet = zQryNFSservicos
    Left = 772
    Top = 520
  end
  object dsNFSpecas: TDataSource
    AutoEdit = False
    DataSet = zQryNFSPecas
    Left = 716
    Top = 520
  end
  object zQryGeral: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  OS.*, Cli.RazSoc as Cliente, Cli.DDD1 as Cli_DDD1, Cli.D' +
        'DD2 as Cli_DDD2 , '
      #9'Cli.Fone1 as Cli_Fone1, Cli.Fone2 as Cli_Fone2 , '
      #9'Cli.Cnpj_Cpf as Cli_Doc, Forn.RazSoc as Fornecedor, '
        #9'Forn.DDD1 as Forn_DDD1, Forn.DDD2 as Forn_DDD2 , Forn.Fone1 as ' +
        'Forn_Fone1,'
      #9'Forn.Fone2  as Forn_Fone2, Forn.Cnpj_Cpf as Forn_Doc,'
      #9'CF.Seq as CFOP'
      ''
      ''
      'From NFs OS'
      ''
      'Left Join Clientes Cli'
      'On Cli.Codigo = OS.CodiCli'
      ''
      'Left Join Fornecedores Forn'
      'On Forn.Codigo = OS.CodiForn'
      ''
      'Left Join CFOP CF'
      'On CF.Codigo = OS.CodiCfop'
      ''
      ''
      ''
      ''
      '')
    Params = <>
    Left = 1108
    Top = 52
  end
  object dsGeral: TDataSource
    DataSet = zQryGeral
    Left = 1111
    Top = 99
  end
  object zQryNFsItens: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  *'
      ''
      'from NFS_ITENS_PG1 NFI'
      ''
      'Where NFI.CodiNF = :Codigo'
      ''
      'order by NFI.CodiNF, NFI.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsNFs
    Left = 828
    Top = 480
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dszQryNFsItens: TDataSource
    AutoEdit = False
    DataSet = zQryNFsItens
    Left = 828
    Top = 520
  end
  object zQryECFs: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from ECFs'
      ''
      'order by Codigo')
    Params = <>
    Left = 696
    Top = 316
  end
  object dsECFs: TDataSource
    AutoEdit = False
    DataSet = zQryECFs
    Left = 696
    Top = 356
  end
  object zQryECFsPEcas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  NFP.Descricao as Peca , NFP.Qtde, NFP.ValorUnit, NFP.Tot' +
        'alProd, NFP.CodiProd,'
      #9'NFP.Codigo, NFP.SeqItem'
      ''
      'from ECFS_PRODS NFP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = NFP.Codiprod'
      ''
      'Where NFP.CodiNF = :Codigo'
      ''
      'order by NFP.CodiNF, NFP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsECFs
    Left = 748
    Top = 316
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryECFsServicos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  NFS.Descricao as Servico , NFS.Qtde, NFS.ValorUnit, NFS.' +
        'TotalServ, NFs.CodiServ,'
      #9'NFs.Codigo, NFs.CodiEmp, NFS.SeqItem'
      ''
      'from ECFS_SERVS NFS'
      ''
      'Left Join Servicos S'
      'on S.Codigo = NFS.CodiServ'
      ''
      'Where NFS.CodiNF = :Codigo'
      ''
      'order by NFS.CodiNF, NFS.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsECFs
    Left = 804
    Top = 316
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsECFsServicos: TDataSource
    AutoEdit = False
    DataSet = zQryECFsServicos
    Left = 804
    Top = 356
  end
  object dsECFsPecas: TDataSource
    AutoEdit = False
    DataSet = zQryECFsPEcas
    Left = 748
    Top = 356
  end
  object dsMovFunc: TDataSource
    AutoEdit = False
    DataSet = zQryMovFunc
    Left = 272
    Top = 364
  end
  object zQryMovFunc: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select MF.* '
      ''
      'from MovFunc MF'
      ''
      'Left Join Empresas E'
      'On E.Codigo = MF.CodiEmp'
      ''
      'order by MF.DtCadastro')
    Params = <>
    Left = 272
    Top = 324
  end
  object dsAvisos: TDataSource
    AutoEdit = False
    DataSet = zQryAvisos
    Left = 316
    Top = 364
  end
  object zQryAvisos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Avisos'
      ''
      'order by Data1')
    Params = <>
    Left = 316
    Top = 324
  end
  object dsAgenda: TDataSource
    AutoEdit = False
    DataSet = zQryAgenda
    Left = 360
    Top = 364
  end
  object zQryAgenda: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Agenda'
      ''
      'order by Nome')
    Params = <>
    Left = 360
    Top = 324
  end
  object zQryRestricoes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  *'
      ''
      'from Restricoes R'
      ''
      'Where r.CodiUser = :Codigo'
      ''
      'order by R.CodiUser')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsUsuarios
    Left = 868
    Top = 316
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsRestricoes: TDataSource
    AutoEdit = False
    DataSet = zQryRestricoes
    Left = 868
    Top = 356
  end
  object dsContasPagar_Anexos: TDataSource
    AutoEdit = False
    DataSet = zQryContasPagar_Anexos
    Left = 8
    Top = 264
  end
  object zQryContasPagar_Anexos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select CP.* '
      ''
      'from ContasPagar_Anexos CP'
      ''
      'Left Join Empresas E'
      'On E.Codigo = CP.CodiEmp'
      ''
      'order by CP.DTVencimento')
    Params = <>
    Left = 8
    Top = 224
  end
  object zQryContasReceber_Anexos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select CR.* '
      ''
      'from ContasReceber_Anexos CR'
      ''
      'Left Join Empresas E'
      'On E.Codigo = CR.CodiEmp'
      ''
      'order by CR.DTVencimento')
    Params = <>
    Left = 56
    Top = 224
  end
  object dsContasReceber_Anexos: TDataSource
    AutoEdit = False
    DataSet = zQryContasReceber_Anexos
    Left = 56
    Top = 264
  end
  object zQryAgendaItens: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  AI.*'
      ''
      'from Agenda_Itens AI'
      ''
      'Where AI.CodiAgenda = :Codigo'
      ''
      'order by AI.Data, AI.Hora')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsAgenda
    Left = 404
    Top = 324
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsAgendaItens: TDataSource
    AutoEdit = False
    DataSet = zQryAgendaItens
    Left = 404
    Top = 364
  end
  object dsCliDescontos: TDataSource
    AutoEdit = False
    DataSet = zQryCliDescontos
    Left = 308
    Top = 92
  end
  object zQryCliDescontos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  CD.*, M.Descricao as Montadora'
      ''
      'from Cliente_Desconto CD'
      #9
      'Left Join Montadoras M'
      'On M.Codigo = CD.CodiMontadora'
      ''
      'Where CD.CodiCliente = :Codigo'
      ''
      'order by M.Descricao')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsClientes
    Left = 308
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object ZQuery1: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  substring( OP.Descricao from 1 for 45 ) as Peca ,'
        #9'OP.Qtde, OP.ValorUnit as Valor_Unit, OP.TotalProd, OP.CodiProd,' +
        ' '
      #9'OP.Desconto1_Valor as Desc_1, OP.Desconto2_Valor as Desc_2,'
      #9'OP.Desconto3_Valor as Desc_3,'
      #9'OP.CodiFunc1, OP.Codigo , OP.Apoio As ASeq, '
        #9'OP.CodiOS, OP.CodiEmp, OP.CodiProd, P.CodiGrupo,  P.ComissaoVal' +
        'or,'
      #9'OP.ValCusto, OP.Apoio'
      ''
      'from OSes_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Left Join Grupos G'
      'on G.Codigo = P.CodiGrupo'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsOSes
    Left = 1080
    Top = 144
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object DataSource1: TDataSource
    AutoEdit = False
    DataSet = ZQuery1
    Left = 1080
    Top = 184
  end
  object dsMovCaixa: TDataSource
    AutoEdit = False
    DataSet = zQryMovCaixa
    Left = 292
    Top = 268
  end
  object zQryMovCaixa: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from MovCaixa'
      ''
      'order by Data_Abertura')
    Params = <>
    Left = 292
    Top = 228
  end
  object zQryCheques: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Cheques'
      '')
    Params = <>
    Left = 552
    Top = 232
  end
  object dsCheques: TDataSource
    AutoEdit = False
    DataSet = zQryCheques
    Left = 552
    Top = 272
  end
  object dsAcertos_Estoque: TDataSource
    AutoEdit = False
    DataSet = zQryAcertos_Estoque
    Left = 1136
    Top = 184
  end
  object zQryAcertos_Estoque: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa, OS.* '
      ''
      'from Acertos_Estoque OS'
      ''
      'Left Join Empresas E'
      'On E.Codigo = OS.CodiEmp'
      ''
      ''
      'order by OS.Codigo, OS.DtCadastro')
    Params = <>
    Left = 1136
    Top = 144
  end
  object dsAcertos_Estoque_Pecas: TDataSource
    AutoEdit = False
    DataSet = zQryAcertos_Estoque_Pecas
    Left = 1196
    Top = 184
  end
  object zQryAcertos_Estoque_Pecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  substring( OP.Descricao from 1 for 45 ) as Peca ,'
      #9'OP.Qtde as Entrada, '
      ''
      #9'OP.QtdeSai as Saida, '
      ''
      #9' OP.CodiProd, P.Referencia, P.Equiv1,'
      #9
        #9'OP.CodiFunc1, OP.Codigo , OP.Apoio As ASeq, OP.ApoioSai As ASeq' +
        'Sai, '
      #9' OP.CodiEmp,  P.CodiGrupo,  P.ComissaoValor,  '
      #9'OP.ValCusto, OP.Apoio, OP.Desconto2_Valor as Desc_2, '
      #9'OP.Desconto3_Valor as Desc_3, OP.ValorUnit as Valor_Unit, '
      #9'OP.Desconto1_Valor as Desc_1, OP.TotalProd, OP.CodiOS'
      ''
      ''
      'from Acertos_Estoque_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Left Join Grupos G'
      'on G.Codigo = P.CodiGrupo'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsAcertos_Estoque
    Left = 1196
    Top = 144
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryAtualizar: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Cheques'
      '')
    Params = <>
    Left = 600
    Top = 232
  end
  object dsAtualizar: TDataSource
    AutoEdit = False
    DataSet = zQryAtualizar
    Left = 600
    Top = 272
  end
  object zQryRotas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Rotas'
      ''
      'order by Descricao')
    Params = <>
    Left = 648
    Top = 316
  end
  object dsRotas: TDataSource
    AutoEdit = False
    DataSet = zQryRotas
    Left = 648
    Top = 356
  end
  object dsCli_Prod: TDataSource
    AutoEdit = False
    DataSet = zQryCli_Prod
    Left = 376
    Top = 92
  end
  object zQryCli_Prod: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  CP.*, P.Descricao as Produto'
      ''
      'from Cli_Prods CP'
      #9
      'Left Join Produtos P'
      'On P.Codigo = CP.CodiProd'
      ''
      'Where CP.CodiCli = :Codigo'
      ''
      'order by P.Descricao')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsClientes
    Left = 376
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsRefCusto: TDataSource
    AutoEdit = False
    DataSet = zQryRefCusto
    Left = 924
    Top = 356
  end
  object zQryRefCusto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from RefCusto'
      ''
      '')
    Params = <>
    Left = 924
    Top = 316
  end
  object zQryTipoUso: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'select Codigo,  Descricao '
      'from TipoUso'
      'order by Descricao'
      ' ')
    Params = <>
    Left = 108
    Top = 224
  end
  object dsTipoUso: TDataSource
    DataSet = zQryTipoUso
    Left = 107
    Top = 271
  end
  object zQryTipoSuperficie: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'select Codigo,  Descricao '
      'from TipoSuperficie'
      'order by Descricao'
      ' ')
    Params = <>
    Left = 156
    Top = 224
  end
  object dsTipoSuperficie: TDataSource
    DataSet = zQryTipoSuperficie
    Left = 155
    Top = 271
  end
  object zQryTipoAplicacao: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'select Codigo,  Descricao '
      'from TipoAplicacao'
      'order by Descricao'
      ' ')
    Params = <>
    Left = 200
    Top = 224
  end
  object dsTipoAplicacao: TDataSource
    DataSet = zQryTipoAplicacao
    Left = 199
    Top = 271
  end
  object dsMovTransf: TDataSource
    AutoEdit = False
    DataSet = zQryMovTransf
    Left = 244
    Top = 268
  end
  object zQryMovTransf: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from MovTransf'
      ''
      'order by DtCadastro')
    Params = <>
    Left = 244
    Top = 228
  end
  object dsMeta_Comissao: TDataSource
    AutoEdit = False
    DataSet = zQryMeta_Comissao
    Left = 452
    Top = 268
  end
  object zQryMeta_Comissao: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Meta_Comissoes'
      ''
      'order by v1_comissao, v2_comissao, v3_comissao, v4_comissao')
    Params = <>
    Left = 452
    Top = 228
  end
  object zQryExtintores: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Extintores'
      ''
      'order by Numero')
    Params = <>
    Left = 512
    Top = 228
  end
  object dsExtintores: TDataSource
    AutoEdit = False
    DataSet = zQryExtintores
    Left = 512
    Top = 268
  end
  object zQryFrota: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Frota'
      ''
      'order by descricao')
    Params = <>
    Left = 336
    Top = 232
  end
  object dsFrota: TDataSource
    AutoEdit = False
    DataSet = zQryFrota
    Left = 336
    Top = 272
  end
  object zQryFrotaDesp: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  '#9'TD.Descricao as TipoDespesa, FD.Descricao as Despesa , ' +
        'FD.Qtde, FD.ValorUnit, FD.Total, '
      #9'FD.Km_Rodado, F.Nome, FD.Codigo'
      ''
      'from FROTA_DESPESAS FD'
      ''
      'Left Join Funcionarios F'
      'on F.Codigo = FD.CodiFunc'
      ''
      'Left Join TipoDesp_Frota TD'
      'On TD.Codigo = FD.CodiTipoDesp'
      ''
      'Where FD.CodiVeiculo = :Codigo'
      ''
      'order by FD.Data Desc, FD.CodiVeiculo, FD.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsFrota
    Left = 388
    Top = 232
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsFrotaDesp: TDataSource
    AutoEdit = False
    DataSet = zQryFrotaDesp
    Left = 388
    Top = 272
  end
  object dsClassifCli: TDataSource
    AutoEdit = False
    DataSet = zQryClassifCli
    Left = 464
    Top = 364
  end
  object zQryClassifCli: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from TiposClientes'
      ''
      'order by descricao')
    Params = <>
    Left = 464
    Top = 324
  end
  object dsTipos_Cheques: TDataSource
    AutoEdit = False
    DataSet = zQryTipos_Cheques
    Left = 512
    Top = 364
  end
  object zQryTipos_Cheques: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Tipos_Cheques'
      ''
      'order by descricao')
    Params = <>
    Left = 512
    Top = 324
  end
  object zQryTiposReclamacao: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from TiposReclamacao'
      'order by descricao')
    Params = <>
    Left = 556
    Top = 332
  end
  object dsTiposReclamacao: TDataSource
    AutoEdit = False
    DataSet = zQryTiposReclamacao
    Left = 556
    Top = 372
  end
  object zQryPosVenda: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from PosVenda'
      'order by data, hora, codicli')
    Params = <>
    Left = 608
    Top = 332
  end
  object dsPosVenda: TDataSource
    AutoEdit = False
    DataSet = zQryPosVenda
    Left = 608
    Top = 372
  end
  object zQryTab_Icms: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Tab_Icms'
      ''
      'order by uf_origem, uf_destino')
    Params = <>
    Left = 272
    Top = 408
  end
  object dsTab_Icms: TDataSource
    AutoEdit = False
    DataSet = zQryTab_Icms
    Left = 272
    Top = 448
  end
  object zQryProdLotes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select P.Descricao as Produto, PC.*'
      ''
      'from ProdLotes PC'
      ''
      'Left Join Produtos P'
      'on P.Codigo = PC.CodiProd'
      ''
      'Where PC.CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 772
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsProdLotes: TDataSource
    AutoEdit = False
    DataSet = zQryProdLotes
    Left = 772
    Top = 92
  end
  object zQryContrato_Fornecimento: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa, OS.* '
      ''
      'from Contrato_Fornecimento OS'
      ''
      'Left Join Empresas E'
      'On E.Codigo = OS.CodiEmp'
      ''
      ''
      'order by OS.Codigo, OS.DtCadastro')
    Params = <>
    Left = 24
    Top = 404
  end
  object dsContrato_Fornecimento: TDataSource
    AutoEdit = False
    DataSet = zQryContrato_Fornecimento
    Left = 24
    Top = 444
  end
  object zQryContrato_Fornec_Pecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  substring( OP.Descricao from 1 for 45 ) as Peca ,'
      #9'OP.Qtde as Entrada, '
      ''
      #9'OP.QtdeSai as Saida, '
      ''
      #9' OP.CodiProd, P.Referencia, P.Equiv1,'
      #9
        #9'OP.CodiFunc1, OP.Codigo , OP.Apoio As ASeq, OP.ApoioSai As ASeq' +
        'Sai, '
      #9' OP.CodiEmp,  P.CodiGrupo,  P.ComissaoValor,  '
      #9'OP.ValCusto, OP.Apoio, OP.Desconto2_Valor as Desc_2, '
      #9'OP.Desconto3_Valor as Desc_3, OP.ValorUnit as Valor_Unit, '
      #9'OP.Desconto1_Valor as Desc_1, OP.TotalProd, OP.CodiOS'
      ''
      ''
      'from Contrato_Fornec_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Left Join Grupos G'
      'on G.Codigo = P.CodiGrupo'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsContrato_Fornecimento
    Left = 68
    Top = 404
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsContrato_Fornec_Pecas: TDataSource
    AutoEdit = False
    DataSet = zQryContrato_Fornec_Pecas
    Left = 68
    Top = 444
  end
  object dsLimitesdeCredito: TDataSource
    AutoEdit = False
    DataSet = zQryLimitesdeCredito
    Left = 132
    Top = 448
  end
  object zQryLimitesdeCredito: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select L.*, C.Nome'
      ''
      ' from LimitesdeCredito L'
      ''
      'left join clientes c'
      'on c.codigo = l.codicli'
      ''
      'order by nome, data, operacao')
    Params = <>
    Left = 132
    Top = 408
  end
  object zQryProdSeriais: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select PF.Serial, SS.Descricao as Situacao, '
        '          CAST( SUBSTRING ( F.FANTASIA FROM 1 FOR 25 )  AS VARCH' +
        'AR(25) ) AS Fornecedor,'
      '          PF.Garantia_Compra, '
        '          PF.Garantia_Venda, PF.Codigo, PF.CodiFor, PF.CodiSitua' +
        'cao'
      ''
      'from ProdSeriais PF'
      ''
      'Left Join Fornecedores F'
      'on PF.CodiFor = F.Codigo'
      ''
      'Left Join Tipo_Situacao_Serial SS'
      'On SS.Codigo = PF.CodiSituacao'
      ''
      'Where PF.CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 816
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsProdSeriais: TDataSource
    AutoEdit = False
    DataSet = zQryProdSeriais
    Left = 816
    Top = 92
  end
  object zQryProdFotos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from ProdFotos'
      ''
      'Where CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 856
    Top = 52
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsProdFotos: TDataSource
    AutoEdit = False
    DataSet = zQryProdFotos
    Left = 856
    Top = 92
  end
  object zQryComprasSeriais: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  CP.Serial, CP.Data, CP.Garantia_Compra, CP.Garantia_Vend' +
        'a, P.Descricao, CP.CodiProd, CP.CodiForn, CP.Codigo'
      ''
      'from Compras_Seriais CP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = CP.Codiprod'
      ''
      'Where CP.CodiOs = :Codigo'
      ''
      'order by CP.CodiOs, CP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsCompras
    Left = 888
    Top = 228
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsComprasSeriais: TDataSource
    AutoEdit = False
    DataSet = zQryComprasSeriais
    Left = 888
    Top = 276
  end
  object zQryMedicos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  *'
      ''
      'from Medicos'
      '')
    Params = <>
    DataSource = dsUsuarios
    Left = 1032
    Top = 356
  end
  object dsMedicos: TDataSource
    AutoEdit = False
    DataSet = zQryMedicos
    Left = 1032
    Top = 396
  end
  object zQryPacientes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Pacientes'
      ''
      'order by Nome')
    Params = <>
    Left = 1084
    Top = 364
  end
  object dsPacientes: TDataSource
    AutoEdit = False
    DataSet = zQryPacientes
    Left = 1084
    Top = 404
  end
  object dsContratos: TDataSource
    AutoEdit = False
    DataSet = zQryContratos
    Left = 328
    Top = 448
  end
  object zQryContratos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select E.Descricao as Empresa, OS.* , C.Descricao as Convenio, C' +
        '.Desconto'
      ''
      'from Contratos OS'
      ''
      'Left Join Empresas E'
      'On E.Codigo = OS.CodiEmp'
      ''
      'Left Join Convenios C'
      'on C.Codigo = OS.CodiConv'
      ''
      ''
      'order by OS.Codigo, OS.DtCadastro, OS.HoraEntrada')
    Params = <>
    Left = 328
    Top = 408
  end
  object dsContratosPecas: TDataSource
    AutoEdit = False
    DataSet = zQryContratosPecas
    Left = 388
    Top = 448
  end
  object zQryContratosPecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      ''
        'Select  OP.Descricao as Peca, OP.Qtde, OP.ValorUnit as Valor_Uni' +
        't, '
      #9'OP.Desconto1_Valor as Desc_1, OP.Desconto2_Valor as Desc_2,'
        #9'OP.TotalProd, OP.CodiFunc1, OP.Codigo , OP.CodiProd, OP.Apoio A' +
        's ASeq, '
        #9'OP.CodiOS, OP.CodiEmp, OP.CodiProd, P.CodiGrupo, P.CodiSubGrupo' +
        ','
      #9'P.ComissaoValor, OP.NumSerial'
      ''
      'from Contratos_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsContratos
    Left = 388
    Top = 408
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsContratosPagto: TDataSource
    AutoEdit = False
    DataSet = zQryContratosPagto
    Left = 448
    Top = 448
  end
  object zQryContratosPagto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  F.Descricao as Forma_Pagto, OP.Valor, OP.NumDocumento, '
      #9'OP.Juros , OP.Taxa_ADM, OP.Corrigido , OP.Data, OP.Codigo, '
      #9'F.Codigo as CodiFPagto, F.CodiTipo as TipoPagto, '
      #9'OP.Codifunc1 , OP.CodiEmp, OP.CodiOs, OP.CodiFormaPagto,'
      #9'OP.SeqContaDespRec, OP.SeqContaCxBanco '
      ''
      ''
      'from Contratos_Pagamento OP'
      ''
      'Left Join FormasPagamento F'
      'on F.Codigo = OP.CodiFormaPagto'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsContratos
    Left = 448
    Top = 408
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryTiposClientes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from TiposClientes'
      'order by descricao')
    Params = <>
    Left = 944
    Top = 404
  end
  object dsTiposClientes: TDataSource
    AutoEdit = False
    DataSet = zQryTiposClientes
    Left = 944
    Top = 444
  end
  object zQryMov_Aparelhos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Mov_Aparelhos'
      'order by Data')
    Params = <>
    Left = 844
    Top = 404
  end
  object dsMov_Aparelhos: TDataSource
    AutoEdit = False
    DataSet = zQryMov_Aparelhos
    Left = 844
    Top = 444
  end
  object zQryEspecialidades: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Especialidades'
      ''
      'order by descricao')
    Params = <>
    Left = 200
    Top = 404
  end
  object dsEspecialidades: TDataSource
    AutoEdit = False
    DataSet = zQryEspecialidades
    Left = 200
    Top = 440
  end
  object zQryFabricantes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Fabricantes'
      ''
      'order by Fantasia')
    Params = <>
    Left = 164
    Top = 52
  end
  object dsFabricantes: TDataSource
    AutoEdit = False
    DataSet = zQryFabricantes
    Left = 164
    Top = 92
  end
  object zQryOSesSeriais: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  CP.Serial, CP.Data, CP.Garantia_Compra, CP.Garantia_Vend' +
        'a, P.Descricao, CP.CodiProd, CP.CodiForn, CP.Codigo'
      ''
      'from OSes_Seriais CP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = CP.Codiprod'
      ''
      'Where CP.CodiOs = :Codigo'
      ''
      'order by CP.CodiOs, CP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsOSes
    Left = 796
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsOSesSeriais: TDataSource
    AutoEdit = False
    DataSet = zQryOSesSeriais
    Left = 796
    Top = 180
  end
  object dsContratos_Seriais: TDataSource
    AutoEdit = False
    DataSet = zQryContratosSeriais
    Left = 508
    Top = 448
  end
  object zQryContratosSeriais: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  CP.Serial, CP.Data, CP.Garantia_Compra, CP.Garantia_Vend' +
        'a, P.Descricao, CP.CodiProd, CP.CodiForn, CP.Codigo'
      ''
      'from Contratos_Seriais CP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = CP.Codiprod'
      ''
      'Where CP.CodiOs = :Codigo'
      ''
      'order by CP.CodiOs, CP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsContratos
    Left = 508
    Top = 408
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryContasRec_Locm: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select CR.* '
      ''
      'from ContasRec_Locm CR'
      ''
      'Left Join Empresas E'
      'On E.Codigo = CR.CodiEmp'
      ''
      'order by CR.DTVencimento')
    Params = <>
    Left = 616
    Top = 412
  end
  object zQryHistoricoReceber_Locm: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  FP.Descricao as FormaRecebto, HR.DtCadastro as DtRecebto' +
        ','
      #9'HR.NumDocumento,'
        #9'HR.ValorRecebido , HR.ValorCorrigido, PC.SeqNivel||'#39'-'#39'||PC.Desc' +
        'ricao as Conta_C,'
        #9'HR.ValorJuros, HR.ValorMulta, HR.ValorDesconto, FP.CodiTipo as ' +
        'TipoPagto,'
        #9'HR.CodiContaEntrada, Hr.CodiContaDespRec, HR.CodiEmp, HR.Codigo' +
        ', HR.Apoio'
      #9
      ''
      'from HistoricoReceber_Locm HR'
      ''
      'Left Join FormasPagamento FP'
      'On FP.Codigo = HR.CodiFormaPagto'
      ''
      'Left Join PlanoContas PC'
      'On PC.Codigo = HR.CodiContaEntrada'
      ''
      'where HR.CodiReceber = :Codigo'
      ''
      'order by HR.DTCadastro')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsContasRec_Locm
    Left = 668
    Top = 404
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsHistoricoReceber_Locm: TDataSource
    AutoEdit = False
    DataSet = zQryHistoricoReceber_Locm
    Left = 656
    Top = 452
  end
  object dsContasRec_Locm: TDataSource
    AutoEdit = False
    DataSet = zQryContasRec_Locm
    Left = 616
    Top = 452
  end
  object zQryContasRec_Locm_Anexos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select CR.* '
      ''
      'from ContasRec_Locm_Anexos CR'
      ''
      'Left Join Empresas E'
      'On E.Codigo = CR.CodiEmp'
      ''
      'order by CR.DTVencimento')
    Params = <>
    Left = 728
    Top = 404
  end
  object dsContasRec_Locm_Anexos: TDataSource
    AutoEdit = False
    DataSet = zQryContasRec_Locm_Anexos
    Left = 736
    Top = 436
  end
  object zQryAcertos_Precos_Pecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  substring( OP.Descricao from 1 for 45 ) as Peca ,'
      ''
      '                OP.Preco_Consum_Novo,'
      '                OP.Preco_Revenda_Novo,'
      '                OP.Preco_Consum_Antigo,'
      '                OP.Preco_Revenda_Antigo,'
      ''
      #9' OP.CodiProd, P.Referencia, P.Equiv1,'
      #9
        #9'OP.CodiFunc1, OP.Codigo , OP.Apoio As ASeq, OP.ApoioSai As ASeq' +
        'Sai, '
      #9' OP.CodiEmp,  P.CodiGrupo,  P.ComissaoValor,  '
      #9'OP.ValCusto, OP.Apoio, OP.Desconto2_Valor as Desc_2, '
      #9'OP.Desconto3_Valor as Desc_3, OP.ValorUnit as Valor_Unit, '
      #9'OP.Desconto1_Valor as Desc_1, OP.TotalProd, OP.CodiOS,'
      '                OP.Preco_Consum_Antigo, OP.Preco_Revenda_Antigo,'
      #9'OP.Qtde as Entrada, '
      #9'OP.QtdeSai as Saida'
      ''
      ''
      'from Acertos_Precos_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Left Join Grupos G'
      'on G.Codigo = P.CodiGrupo'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsAcertos_Precos
    Left = 888
    Top = 568
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryAcertos_Precos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa, OS.* '
      ''
      'from Acertos_Precos OS'
      ''
      'Left Join Empresas E'
      'On E.Codigo = OS.CodiEmp'
      ''
      ''
      'order by OS.Codigo, OS.DtCadastro')
    Params = <>
    Left = 828
    Top = 568
  end
  object dsAcertos_Precos: TDataSource
    AutoEdit = False
    DataSet = zQryAcertos_Precos
    Left = 828
    Top = 608
  end
  object dsAcertos_Precos_Pecas: TDataSource
    AutoEdit = False
    DataSet = zQryAcertos_Precos_Pecas
    Left = 888
    Top = 608
  end
  object zQrySMS_Enviados: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select *'
      ''
      ' from SMS_Enviados'
      ''
      'order by codigo')
    Params = <>
    Left = 740
    Top = 572
  end
  object dsSMS_Enviados: TDataSource
    AutoEdit = False
    DataSet = zQrySMS_Enviados
    Left = 740
    Top = 612
  end
  object zQryConfere_Estoque_Pecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  substring( OP.Descricao from 1 for 45 ) as Peca ,'
      ''
      '                OP.Preco_Consum_Novo,'
      '                OP.Preco_Revenda_Novo,'
      '                OP.Preco_Consum_Antigo,'
      '                OP.Preco_Revenda_Antigo,'
      ''
      #9' OP.CodiProd, P.Referencia, P.Equiv1,'
      #9
        #9'OP.CodiFunc1, OP.Codigo , OP.Apoio As ASeq, OP.ApoioSai As ASeq' +
        'Sai, '
      #9' OP.CodiEmp,  P.CodiGrupo,  P.ComissaoValor,  '
      #9'OP.ValCusto, OP.Apoio, OP.Desconto2_Valor as Desc_2, '
      #9'OP.Desconto3_Valor as Desc_3, OP.ValorUnit as Valor_Unit, '
      #9'OP.Desconto1_Valor as Desc_1, OP.TotalProd, OP.CodiOS,'
      '                OP.Preco_Consum_Antigo, OP.Preco_Revenda_Antigo,'
      #9'OP.Qtde as Entrada, '
      #9'OP.QtdeSai as Saida'
      ''
      ''
      'from Confere_Estoque_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Left Join Grupos G'
      'on G.Codigo = P.CodiGrupo'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.CodiOs, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsConfere_Estoque
    Left = 640
    Top = 580
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object zQryConfere_Estoque: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select E.Descricao as Empresa, OS.* '
      ''
      'from Confere_Estoque OS'
      ''
      'Left Join Empresas E'
      'On E.Codigo = OS.CodiEmp'
      ''
      ''
      'order by OS.Codigo, OS.DtCadastro')
    Params = <>
    Left = 580
    Top = 580
  end
  object dsConfere_Estoque: TDataSource
    AutoEdit = False
    DataSet = zQryConfere_Estoque
    Left = 580
    Top = 620
  end
  object dsConfere_Estoque_Pecas: TDataSource
    AutoEdit = False
    DataSet = zQryConfere_Estoque_Pecas
    Left = 640
    Top = 620
  end
  object dsBoletos: TDataSource
    AutoEdit = False
    DataSet = zQryBoletos
    Left = 28
    Top = 612
  end
  object zQryBoletos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select *'
      ''
      ' from Boletos'
      ''
      '')
    Params = <>
    Left = 28
    Top = 572
  end
  object zQryCotacoes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Cotacoes'
      ''
      'order by Data Desc')
    Params = <>
    Left = 1056
    Top = 220
  end
  object dsCotacoes: TDataSource
    AutoEdit = False
    DataSet = zQryCotacoes
    Left = 1056
    Top = 260
  end
  object dsMoedas: TDataSource
    AutoEdit = False
    DataSet = zQryMoedas
    Left = 1056
    Top = 332
  end
  object zQryMoedas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Moedas'
      ''
      'order by Descricao')
    Params = <>
    Left = 1056
    Top = 292
  end
  object zQryPromocoes: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Promocoes'
      ''
      'order by descricao')
    Params = <>
    Left = 1044
    Top = 672
  end
  object dsPromocoes: TDataSource
    AutoEdit = False
    DataSet = zQryPromocoes
    Left = 1044
    Top = 712
  end
  object zQryVenda_PorQtde: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Venda_PorQtde'
      ''
      'order by v1, v2, v3, v4')
    Params = <>
    Left = 100
    Top = 576
  end
  object dsVenda_PorQtde: TDataSource
    AutoEdit = False
    DataSet = zQryVenda_PorQtde
    Left = 100
    Top = 616
  end
  object zQryGarantias_Cral: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select *'
      ''
      ' from Garantias_Cral'
      ''
      '')
    Params = <>
    Left = 192
    Top = 572
  end
  object dsGarantias_Cral: TDataSource
    AutoEdit = False
    DataSet = zQryGarantias_Cral
    Left = 184
    Top = 620
  end
  object zQryUnidades: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select *'
      ''
      ' from Unidades'
      ''
      '')
    Params = <>
    Left = 324
    Top = 576
  end
  object dsUnidades: TDataSource
    AutoEdit = False
    DataSet = zQryUnidades
    Left = 324
    Top = 616
  end
  object zQryEmp: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from EMP')
    Params = <>
    Left = 380
    Top = 576
  end
  object dsEmp: TDataSource
    AutoEdit = False
    DataSet = zQryEmp
    Left = 380
    Top = 620
  end
  object zQryPesquisaDIEF: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from EMP')
    Params = <>
    Left = 436
    Top = 576
  end
  object DataSource2: TDataSource
    AutoEdit = False
    DataSet = zQryPesquisaDIEF
    Left = 436
    Top = 620
  end
  object zQryIncluiDIEF: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from EMP')
    Params = <>
    Left = 496
    Top = 576
  end
  object DataSource3: TDataSource
    AutoEdit = False
    DataSet = zQryIncluiDIEF
    Left = 496
    Top = 620
  end
  object zQryTabComDia: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Tab_Comissao_Dia'
      '')
    Params = <>
    Left = 1184
    Top = 56
  end
  object dsTabComDia: TDataSource
    AutoEdit = False
    DataSet = zQryTabComDia
    Left = 1184
    Top = 96
  end
  object zQrySucatas_Cral: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select *'
      ''
      ' from Garantias_Cral'
      ''
      '')
    Params = <>
    Left = 260
    Top = 572
  end
  object dsSucatas_CRAL: TDataSource
    AutoEdit = False
    DataSet = zQrySucatas_Cral
    Left = 260
    Top = 620
  end
  object zQryAidfs: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Tab_Aidfs'
      ''
      'order by aidf')
    Params = <>
    Left = 1096
    Top = 468
  end
  object dsAidfs: TDataSource
    AutoEdit = False
    DataSet = zQryAidfs
    Left = 1096
    Top = 508
  end
  object zQryEstagios: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Seguradoras'
      ''
      'order by Fantasia')
    Params = <>
    Left = 1164
    Top = 268
  end
  object dsEstagios: TDataSource
    AutoEdit = False
    DataSet = zQryEstagios
    Left = 1164
    Top = 316
  end
  object zQryBina_Mem: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Bina_Memoria'
      ''
      ''
      'order by Data, Hora')
    Params = <>
    Left = 1160
    Top = 396
  end
  object dsBina_Mem: TDataSource
    AutoEdit = False
    DataSet = zQryBina_Mem
    Left = 1160
    Top = 436
  end
  object zQryCorretores: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Corretores'
      ''
      'order by nome')
    Params = <>
    Left = 1056
    Top = 568
  end
  object dsCorretores: TDataSource
    AutoEdit = False
    DataSet = zQryCorretores
    Left = 1056
    Top = 608
  end
  object zQryNFs: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from NFs'
      ''
      'order by numeronf')
    Params = <>
    Left = 660
    Top = 484
  end
  object dsNFs: TDataSource
    AutoEdit = False
    DataSet = zQryNFs
    Left = 660
    Top = 524
  end
  object zQryNFE: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from NFE'
      ''
      'order by numeronf')
    Params = <>
    Left = 824
    Top = 676
  end
  object dsNFE: TDataSource
    AutoEdit = False
    DataSet = zQryNFE
    Left = 824
    Top = 716
  end
  object zQryNFEPecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  NFP.Descricao as Peca , NFP.Qtde, NFP.ValorUnit, NFP.Tot' +
        'alProd, NFP.CodiProd,'
        #9'NFP.Codigo, NFP.SeqItem, nfp.pESO_bRUTO, NFP.PESO_LIQUIDO, NFP.' +
        'Unidade, NFP.Icms, NFP.Ipi, nfp.cfop, nfp.cst, nfp.valor_icms,'
        '               NFP.QtdeCom, NFP.UnidadeCom, NFP.ValorUnitCom, NF' +
        'P.Frete'
      ''
      'from NFe_PRODS NFP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = NFP.Codiprod'
      ''
      'Where NFP.CodiNF = :Codigo'
      ''
      'order by NFP.CodiNF, NFP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsNFE
    Left = 880
    Top = 672
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsNFEPecas: TDataSource
    AutoEdit = False
    DataSet = zQryNFEPecas
    Left = 880
    Top = 712
  end
  object zQryNFEServicos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  NFS.Descricao as Servico , NFS.Qtde, NFS.ValorUnit, NFS.' +
        'TotalServ, NFs.CodiServ,'
      #9'NFs.Codigo, NFs.CodiEmp, NFS.SeqItem'
      ''
      'from NFe_SERVS NFS'
      ''
      'Left Join Servicos S'
      'on S.Codigo = NFS.CodiServ'
      ''
      'Where NFS.CodiNF = :Codigo'
      ''
      'order by NFS.CodiNF, NFS.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsNFE
    Left = 936
    Top = 672
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsNFEServicos: TDataSource
    AutoEdit = False
    DataSet = zQryNFEServicos
    Left = 936
    Top = 712
  end
  object zQryMetasVendas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Metas_Vendas'
      ''
      'order by codigo, ano, mes')
    Params = <>
    Left = 1156
    Top = 556
  end
  object dsMetasVendas: TDataSource
    AutoEdit = False
    DataSet = zQryMetasVendas
    Left = 1156
    Top = 596
  end
  object zQryMetasTotais: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select MT.*, F.Nome as Vendedor '
      ''
      'from Metas_Totais MT'
      ''
      'Left Join Funcionarios F'
      'on F.codigo = MT.CodiFunc'
      ''
      'Where MT.CodiMeta = :Codigo and Tipo = '#39'M'#39
      ''
      'order by MT.ANO, MT.MES, MT.Dia_Ini')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsMetasVendas
    Left = 1244
    Top = 556
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    object zQryMetasTotaisCODIMETA: TIntegerField
      FieldName = 'CODIMETA'
      Required = True
    end
    object zQryMetasTotaisTIPO: TStringField
      FieldName = 'TIPO'
      Size = 1
    end
    object zQryMetasTotaisDIA_INI: TIntegerField
      FieldName = 'DIA_INI'
    end
    object zQryMetasTotaisDIA_FIM: TIntegerField
      FieldName = 'DIA_FIM'
    end
    object zQryMetasTotaisMES: TIntegerField
      FieldName = 'MES'
    end
    object zQryMetasTotaisANO: TIntegerField
      FieldName = 'ANO'
    end
    object zQryMetasTotaisDEBITO_ACUMULADO: TFloatField
      FieldName = 'DEBITO_ACUMULADO'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryMetasTotaisCODIFUNC: TIntegerField
      FieldName = 'CODIFUNC'
    end
    object zQryMetasTotaisBRONZE: TFloatField
      FieldName = 'BRONZE'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryMetasTotaisPRATA: TFloatField
      FieldName = 'PRATA'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryMetasTotaisOURO: TFloatField
      FieldName = 'OURO'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryMetasTotaisDIAMANTE: TFloatField
      FieldName = 'DIAMANTE'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryMetasTotaisREALIZADO: TFloatField
      FieldName = 'REALIZADO'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryMetasTotaisMETA_ATINGIDA: TStringField
      FieldName = 'META_ATINGIDA'
      Size = 10
    end
    object zQryMetasTotaisDEBITO_SEMANA: TFloatField
      FieldName = 'DEBITO_SEMANA'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object zQryMetasTotaisTICKET_MEDIO: TFloatField
      FieldName = 'TICKET_MEDIO'
    end
    object zQryMetasTotaisNUM_VENDAS: TIntegerField
      FieldName = 'NUM_VENDAS'
    end
    object zQryMetasTotaisVENDEDOR: TStringField
      FieldName = 'VENDEDOR'
      Size = 60
    end
  end
  object dsMetasTotais: TDataSource
    AutoEdit = False
    DataSet = zQryMetasTotais
    Left = 1244
    Top = 596
  end
  object zQryMetasTotaisMensal: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select MT.*, F.Nome as Vendedor '
      ''
      'from Metas_Totais MT'
      ''
      'Left Join Funcionarios F'
      'on F.codigo = MT.CodiFunc'
      ''
      'Where MT.CodiMeta = :Codigo and Tipo = '#39'M'#39
      ''
      'order by MT.ANO, MT.MES, MT.Dia_Ini')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsMetasVendas
    Left = 1320
    Top = 556
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    object IntegerField1: TIntegerField
      FieldName = 'CODIMETA'
      Required = True
    end
    object StringField1: TStringField
      FieldName = 'TIPO'
      Size = 1
    end
    object IntegerField2: TIntegerField
      FieldName = 'DIA_INI'
    end
    object IntegerField3: TIntegerField
      FieldName = 'DIA_FIM'
    end
    object IntegerField4: TIntegerField
      FieldName = 'MES'
    end
    object IntegerField5: TIntegerField
      FieldName = 'ANO'
    end
    object FloatField1: TFloatField
      FieldName = 'DEBITO_ACUMULADO'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object IntegerField6: TIntegerField
      FieldName = 'CODIFUNC'
    end
    object FloatField2: TFloatField
      FieldName = 'BRONZE'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object FloatField3: TFloatField
      FieldName = 'PRATA'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object FloatField4: TFloatField
      FieldName = 'OURO'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object FloatField5: TFloatField
      FieldName = 'DIAMANTE'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object FloatField6: TFloatField
      FieldName = 'REALIZADO'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object StringField2: TStringField
      FieldName = 'META_ATINGIDA'
      Size = 10
    end
    object FloatField7: TFloatField
      FieldName = 'DEBITO_SEMANA'
      DisplayFormat = ',###,##0.00;-,###,##0.00'
      currency = True
    end
    object FloatField8: TFloatField
      FieldName = 'TICKET_MEDIO'
    end
    object IntegerField7: TIntegerField
      FieldName = 'NUM_VENDAS'
    end
    object StringField3: TStringField
      FieldName = 'VENDEDOR'
      Size = 60
    end
  end
  object dsMetasTotaisMensal: TDataSource
    AutoEdit = False
    DataSet = zQryMetasTotaisMensal
    Left = 1320
    Top = 596
  end
  object zQryNFsDI: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  *'
      ''
      'from NFS_DI NFI'
      ''
      'Where NFI.CodiNF = :Codigo '
      'And NFI.CodiProd = :CodiProd'
      ''
      'Order by NFI.CodiNF, NFI.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CodiProd'
        ParamType = ptUnknown
      end>
    DataSource = dsNFs
    Left = 888
    Top = 484
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CodiProd'
        ParamType = ptUnknown
      end>
  end
  object dsNFSDi: TDataSource
    AutoEdit = False
    DataSet = zQryNFsDI
    Left = 884
    Top = 524
  end
  object zQryPromocoesProds: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  PP.*, P.Descricao as Peca, P.Referencia'
      ''
      'from Promocoes_Prods PP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = PP.CodiProd'
      ''
      'Where PP.CodiPromocao = :Codigo'
      ''
      'order by PP.CodiPromocao, PP.CodiProd')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsPromocoes
    Left = 1104
    Top = 676
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    object zQryPromocoesProdsCODIGO: TIntegerField
      FieldName = 'CODIGO'
      Required = True
    end
    object zQryPromocoesProdsCODIPROMOCAO: TIntegerField
      FieldName = 'CODIPROMOCAO'
    end
    object zQryPromocoesProdsCODIPROD: TIntegerField
      FieldName = 'CODIPROD'
    end
    object zQryPromocoesProdsVALOR_PROD: TFloatField
      FieldName = 'VALOR_PROD'
    end
    object zQryPromocoesProdsDESC_PROD: TFloatField
      FieldName = 'DESC_PROD'
    end
    object zQryPromocoesProdsPECA: TStringField
      FieldName = 'PECA'
      Size = 60
    end
    object zQryPromocoesProdsREFERENCIA: TStringField
      FieldName = 'REFERENCIA'
      Size = 100
    end
  end
  object dsPromocoesProds: TDataSource
    AutoEdit = False
    DataSet = zQryPromocoesProds
    Left = 1104
    Top = 716
  end
  object zQryProdRefer: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select m.descricao as marca, pr.referencia, pr.codigo, pr.codipr' +
        'od '
      ''
      'from ProdRefer PR'
      ''
      'left join marcas m'
      'on m.codigo = pr.codimarca'
      ''
      'Where PR.CodiProd = :Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsProdutos
    Left = 920
    Top = 56
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsProdRefer: TDataSource
    AutoEdit = False
    DataSet = zQryProdRefer
    Left = 920
    Top = 96
  end
  object zQryProds_Servs: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from Prods_Servs'
      'order by Descricao')
    Params = <>
    DataSource = dsOSes
    Left = 1320
    Top = 148
  end
  object dsProds_Servs: TDataSource
    AutoEdit = False
    DataSet = zQryProds_Servs
    Left = 1320
    Top = 188
  end
  object zQryOSesConferenciaPecas: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select  cAST( SUBSTRING ( P.Equiv1 FROM 1 FOR 12 )  AS VARCHAR(1' +
        '3) ) AS CODINTERNO, '
        '                substring( OP.Descricao from 1 for 45 ) as Peca ' +
        ','
      #9'OP.Qtde, OP.ValorUnit as Valor_Unit, '
        #9'OP.Desconto1_Valor as Desc_1, OP.TotalProd, OP.CodiProd, P.Refe' +
        'rencia, '
      #9'OP.CodiOS,'
      #9'OP.CodiFunc1, OP.Codigo , OP.Apoio As ASeq, '
        #9' OP.CodiEmp, OP.CodiProd, P.CodiGrupo,  P.ComissaoValor,  P.Equ' +
        'iv1,'
      #9'OP.ValCusto, OP.Apoio, OP.Desconto2_Valor as Desc_2, '
      #9'OP.Desconto3_Valor as Desc_3, OP.Devolvido, op.Desconto1_Porc, '
        '                OP.Codicategoria, op.codibarra, op.data, op.larg' +
        'ura, op.altura, op.m_quad,'
      '                OP.NumSerial, P.Descricao_ECF, OP.Unidade'
      ''
      'from OSes_Conferencia_Pecas OP'
      ''
      'Left Join Produtos P'
      'on P.Codigo = OP.Codiprod'
      ''
      'Left Join Grupos G'
      'on G.Codigo = P.CodiGrupo'
      ''
      'Where OP.CodiOs = :Codigo'
      ''
      'order by OP.Codigo DESC')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsOSesConferencia
    Left = 960
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsOSesConferenciaPecas: TDataSource
    AutoEdit = False
    DataSet = zQryOSesConferenciaPecas
    Left = 960
    Top = 180
  end
  object zQryOSesConferencia: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
        'Select FIRST 1 E.Descricao as Empresa, OS.* , C.Descricao as Con' +
        'venio, C.Desconto'
      ''
      'from OSes_Conferencia OS'
      ''
      'Left Join Empresas E'
      'On E.Codigo = OS.CodiEmp'
      ''
      'Left Join Convenios C'
      'on C.Codigo = OS.CodiConv'
      ''
      ''
      'order by OS.Codigo, OS.DtCadastro, OS.HoraEntrada')
    Params = <>
    Left = 904
    Top = 140
  end
  object dsOSesConferencia: TDataSource
    AutoEdit = False
    DataSet = zQryOSesConferencia
    Left = 904
    Top = 180
  end
  object zQryCores: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Bina_Memoria'
      ''
      ''
      'order by Data, Hora')
    Params = <>
    Left = 1268
    Top = 316
  end
  object dsCores: TDataSource
    AutoEdit = False
    DataSet = zQryCores
    Left = 1268
    Top = 368
  end
  object zQryMensagensSMS: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from mensagens_sms'
      ''
      'order by titulo')
    Params = <>
    Left = 1272
    Top = 468
  end
  object dsMensagensSMS: TDataSource
    AutoEdit = False
    DataSet = zQryMensagensSMS
    Left = 1272
    Top = 508
  end
  object zQryParametros_Texto_OS: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select Descricao, codigo from Parametros_Texto_OS'
      'order by codigo')
    Params = <>
    Left = 1244
    Top = 668
  end
  object dsParametros_Texto_OS: TDataSource
    AutoEdit = False
    DataSet = zQryParametros_Texto_OS
    Left = 1244
    Top = 708
  end
  object zQryParametros_Texto_OS2: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select Descricao, codigo from Parametros_Texto_OS_2'
      'order by codigo')
    Params = <>
    Left = 1388
    Top = 668
  end
  object dsParametros_Texto_OS2: TDataSource
    AutoEdit = False
    DataSet = zQryParametros_Texto_OS2
    Left = 1388
    Top = 708
  end
  object zQryHistoricos: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from historicos'
      ''
      'order by descricao')
    Params = <>
    Left = 576
    Top = 696
  end
  object dsHistoricos: TDataSource
    AutoEdit = False
    DataSet = zQryHistoricos
    Left = 576
    Top = 736
  end
  object zQrySql: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Bina_Memoria'
      ''
      ''
      'order by Data, Hora')
    Params = <>
    Left = 1360
    Top = 316
  end
  object zQrySqlECF: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Bina_Memoria'
      ''
      ''
      'order by Data, Hora')
    Params = <>
    Left = 1360
    Top = 384
  end
  object zQryContador: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Bina_Memoria'
      ''
      ''
      'order by Data, Hora')
    Params = <>
    Left = 1368
    Top = 224
  end
  object zQryContador2: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * '
      ''
      'from Bina_Memoria'
      ''
      ''
      'order by Data, Hora')
    Params = <>
    Left = 1376
    Top = 264
  end
  object zQryTB_ECF: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'SELECT FIRST 1 * from TB_ECFs')
    Params = <>
    Left = 648
    Top = 692
  end
  object dsTB_ECF: TDataSource
    AutoEdit = False
    DataSet = zQryTB_ECF
    Left = 648
    Top = 732
  end
  object zQryNaturezaOp: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'SELECT  * from TB_NATUREZA_OPERACAO')
    Params = <>
    Left = 720
    Top = 692
  end
  object dsNaturezaOp: TDataSource
    AutoEdit = False
    DataSet = zQryNaturezaOp
    Left = 720
    Top = 732
  end
  object zQryNFsPagto: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select  F.Descricao as Forma_Pagto, OP.Valor, OP.NumDocumento, '
      #9'OP.Juros , OP.Taxa_ADM, OP.Corrigido , OP.Data, OP.Codigo, '
      #9'F.Codigo as CodiFPagto, F.CodiTipo as TipoPagto, '
      #9'OP.Codifunc1 , OP.CodiEmp, OP.CodiNF, OP.CodiFormaPagto,'
        #9'OP.SeqContaDespRec, OP.SeqContaCxBanco , TP.Descricao as Tipodo' +
        'Pagto,'
      #9'OP.CodiBanco, OP.NumConta, OP.NumAgencia, '
        '                OP.Num_Serie_Ecf, OP.MF_ADICIONAL, OP.NUM_USUARI' +
        'O, OP.COO, OP.CCF,OP.GNF,OP.INDICADOR_ESTORNO,OP.VALOR_ESTORNADO' +
        ','
      '                OP.TEF_NSU_TRANSACAO, OP.TEF_CODIGO_AUTORIZACAO'
      ''
      'from NFS_Pagamento OP'
      ''
      'Left Join FormasPagamento F'
      'on F.Codigo = OP.CodiFormaPagto'
      ''
      'Left Join TiposPagamento TP'
      'on TP.Codigo = OP.CodiTipoPagto'
      ''
      'Where OP.CodiNF = :Codigo'
      ''
      'order by OP.CodiNF, OP.Codigo')
    Params = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
    DataSource = dsNFs
    Left = 944
    Top = 488
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Codigo'
        ParamType = ptUnknown
      end>
  end
  object dsNFsPagto: TDataSource
    AutoEdit = False
    DataSet = zQryNFsPagto
    Left = 944
    Top = 528
  end
  object dsPlanosTelefonia: TDataSource
    AutoEdit = False
    DataSet = zQryPlanosTelefonia
    Left = 380
    Top = 732
  end
  object zQryPlanosTelefonia: TRESTClientSQL
     IndexDefs = <>
     FetchOptions.AssignedValues = [evMode]
     FetchOptions.Mode = fmAll
     FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
     FormatOptions.MaxBcdPrecision = 2147483647
     FormatOptions.MaxBcdScale = 2147483647
     ResourceOptions.AssignedValues = [rvSilentMode]
     ResourceOptions.SilentMode = True
     UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
     UpdateOptions.LockWait = True
     UpdateOptions.FetchGeneratorsPoint = gpNone
     UpdateOptions.CheckRequired = False
     UpdateOptions.AutoCommitUpdates = True
     StoreDefs = True
     MasterCascadeDelete = True
     DataCache = False
    DataBase = RESTDataBase
    SQL.Strings = (
      'Select * from TamAros'
      ''
      'order by descricao')
    Params = <>
    Left = 380
    Top = 692
  end
  object IdFTP_KingHost: TIdFTP
    IPVersion = Id_IPv4
    Host = 'ftp.flaviomotta.com'
    Passive = True
    ConnectTimeout = 0
    Password = '1q2w3e4r5t'
    Username = 'flaviomotta'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    ReadTimeout = 9000
    Left = 1432
    Top = 187
  end
  object IdFTP_conexao: TIdFTP
    IPVersion = Id_IPv4
    Host = 'ftp.mikromundo.com'
    Passive = True
    ConnectTimeout = 0
    Password = '14mT7xyl6Q'
    Username = 'mikromun'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    ReadTimeout = 9000
    Left = 1428
    Top = 59
  end
  object IdAntiFreeze: TIdAntiFreeze
    Left = 1392
    Top = 8
  end
  object IdFTP_hostnet: TIdFTP
    IPVersion = Id_IPv4
    Host = 'ftp.mikromundo.com.br'
    Passive = True
    ConnectTimeout = 0
    Password = '@r@c@tik@rdecTianguA'
    Username = 'mikromundo'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    ReadTimeout = 9000
    Left = 1288
    Top = 99
  end
  object IdFTP_plugin: TIdFTP
    IPVersion = Id_IPv4
    Host = 'plugrevenda01.plugin.com.br'
    Passive = True
    ConnectTimeout = 0
    Password = 'miki386'
    Username = 'hpmikromundo'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    ReadTimeout = 9000
    Left = 1288
    Top = 51
  end
  object IdFTP_netrevenda: TIdFTP
    IPVersion = Id_IPv4
    Host = 'ftp.mikromundosistemas.com.br'
    Passive = True
    ConnectTimeout = 0
    Password = '5@t1r0d1@5377101cpWHM'
    Username = 'mkmsistemas'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    ReadTimeout = 9000
    Left = 1288
    Top = 3
  end
  object IdServerIOHandlerSSLOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    Destination = 'ftp.mikromundosistemas.com.br:443'
    Host = 'ftp.mikromundosistemas.com.br'
    MaxLineAction = maException
    Port = 443
    DefaultPort = 0
    ReadTimeout = 9000
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 1252
    Top = 248
  end
  object IdFTP_conexao_SSL: TIdFTP
    IOHandler = IdServerIOHandlerSSLOpenSSL1
    IPVersion = Id_IPv4
    Host = 'ftp.mikromundosistemas.com.br'
    Passive = True
    ConnectTimeout = 0
    Password = '5@t1r0d1@5377101cpWHM'
    Username = 'mkmsistemas'
    Port = 443
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    UseTLS = utUseExplicitTLS
    ReadTimeout = 9000
    Left = 1428
    Top = 111
  end
end
