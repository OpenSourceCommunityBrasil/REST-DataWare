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
    ServerParams.HasAuthentication = True
    ServerParams.UserName = 'testserver'
    ServerParams.Password = 'testserver'
    Encoding = esUtf8
    ServerContext = 'restdataware'
    Left = 120
    Top = 112
  end
end
