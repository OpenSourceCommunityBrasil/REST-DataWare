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
    ServerParams.HasAuthentication = True
    ServerParams.UserName = 'testserver'
    ServerParams.Password = 'testserver'
    Encoding = esUtf8
    ForceWelcomeAccess = False
    ServerContext = 'cgi-bin/webpascalisapi.dll'
    RootPath = '/'
    Left = 120
    Top = 112
  end
end
