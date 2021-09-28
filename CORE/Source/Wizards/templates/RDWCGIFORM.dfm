object %0:s: T%0:s
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
    ServerParams.HasAuthentication = True
    ServerParams.UserName = 'testserver'
    ServerParams.Password = 'testserver'
    Encoding = esUtf8
    ForceWelcomeAccess = False
    ServerContext = 'restdataware'
    RootPath = '/'
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    TokenOptions.Active = False
    TokenOptions.ServerRequest = 'RESTDWServer01'
    TokenOptions.TokenHash = 'RDWTS_HASH'
    TokenOptions.LifeCycle = 30
    Left = 120
    Top = 112
  end
end
