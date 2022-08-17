object %0:s: T%0:s
  OnCreate = WebModuleCreate
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end>
  Height = 230
  Width = 415
  object RESTDWShellService1: TRESTDWShellService
    Active = False
    CORS = False
    CORS_CustomHeaders.Strings = (
      'Access-Control-Allow-Origin=*'

        'Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTI' +
        'ONS'
      
        'Access-Control-Allow-Headers=Content-Type, Origin, Accept, Autho' +
        'rization, X-CUSTOM-HEADER')
    PathTraversalRaiseError = True
    RequestTimeout = -1
    ServicePort = 8082
    ProxyOptions.ProxyPort = 0
    AuthenticationOptions.AuthorizationOption = rdwAONone
    Encoding = esUtf8
    RootPath = '/'
    ForceWelcomeAccess = False
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    Left = 176
    Top = 72
  end
end
