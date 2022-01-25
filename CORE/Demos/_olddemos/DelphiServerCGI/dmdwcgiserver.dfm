object dwCGIService: TdwCGIService
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = dwCGIServiceDefaultHandlerAction
    end>
  Height = 240
  Width = 290
  object RESTServiceCGI1: TRESTServiceCGI
    CORS = False
    CORS_CustomHeaders.Strings = (
      'Access-Control-Allow-Origin=*'
      
        'Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTI' +
        'ONS'
      
        'Access-Control-Allow-Headers=Content-Type, Origin, Accept, Autho' +
        'rization, X-CUSTOM-HEADER')
    AuthenticationOptions.AuthorizationOption = rdwAOToken
    AuthenticationOptions.OptionParams.TokenType = rdwJWT
    AuthenticationOptions.OptionParams.CryptType = rdwAES256
    AuthenticationOptions.OptionParams.Key = 'token'
    AuthenticationOptions.OptionParams.GetTokenEvent = 'GetToken'
    AuthenticationOptions.OptionParams.TokenHash = 'RDWTS_HASH0011'
    AuthenticationOptions.OptionParams.ServerSignature = 'RDWSERVER123'
    AuthenticationOptions.OptionParams.LifeCycle = 1800
    Encoding = esUtf8
    ForceWelcomeAccess = False
    ServerContext = 'restdataware'
    RootPath = '/'
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    Left = 120
    Top = 112
  end
end
