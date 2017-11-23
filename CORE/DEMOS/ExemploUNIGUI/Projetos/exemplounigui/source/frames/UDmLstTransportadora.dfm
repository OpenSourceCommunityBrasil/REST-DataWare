inherited DmLstTransportadora: TDmLstTransportadora
  OnDestroy = DataModuleDestroy
  object ACBrValidador1: TACBrValidador
    IgnorarChar = './-'
    Left = 59
    Top = 208
  end
  object ACBrCEP2: TACBrCEP
    ProxyPort = '8080'
    ParseText = True
    WebService = wsRepublicaVirtual
    PesquisarIBGE = True
    Left = 131
    Top = 208
  end
end
