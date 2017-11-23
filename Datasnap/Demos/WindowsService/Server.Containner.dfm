object RESTDWServer: TRESTDWServer
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'REST Dataware - Server'
  Height = 231
  Width = 349
  object DSServer: TDSServer
    OnConnect = DSServerConnect
    OnDisconnect = DSServerDisconnect
    AutoStart = False
    Left = 96
    Top = 11
  end
  object DSHTTPService1: TDSHTTPService
    HttpPort = 8080
    OnHTTPTrace = DSHTTPService1HTTPTrace
    OnFormatResult = DSHTTPService1FormatResult
    Server = DSServer
    DSPort = 0
    Filters = <>
    AuthenticationManager = DSAuthenticationManager1
    Left = 96
    Top = 63
  end
  object DSServerClass1: TDSServerClass
    OnGetClass = DSServerClass1GetClass
    Server = DSServer
    Left = 96
    Top = 112
  end
  object DSAuthenticationManager1: TDSAuthenticationManager
    OnUserAuthenticate = DSAuthenticationManager1UserAuthenticate
    Roles = <>
    Left = 96
    Top = 168
  end
end
