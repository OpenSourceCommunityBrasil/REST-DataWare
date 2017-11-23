object WebModule1: TWebModule1
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end
    item
      Name = 'ServerFunctionInvokerAction'
      PathInfo = '/ServerFunctionInvoker'
      Producer = ServerFunctionInvoker
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  Height = 230
  Width = 415
  object DSServer1: TDSServer
    OnConnect = DSServer1Connect
    OnDisconnect = DSServer1Disconnect
    Left = 96
    Top = 11
  end
  object DSHTTPWebDispatcher1: TDSHTTPWebDispatcher
    Server = DSServer1
    Filters = <>
    AuthenticationManager = DSAuthenticationManager1
    WebDispatch.PathInfo = 'datasnap*'
    Left = 96
    Top = 75
  end
  object DSServerClass1: TDSServerClass
    OnGetClass = DSServerClass1GetClass
    Server = DSServer1
    LifeCycle = 'Invocation'
    Left = 200
    Top = 11
  end
  object DSAuthenticationManager1: TDSAuthenticationManager
    OnUserAuthenticate = DSAuthenticationManager1UserAuthenticate
    Roles = <>
    Left = 192
    Top = 72
  end
  object ServerFunctionInvoker: TPageProducer
    HTMLFile = 'Templates\ServerFunctionInvoker.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 194
    Top = 127
  end
  object WebFileDispatcher1: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/x-png'
        Extensions = 'png'
      end
      item
        MimeType = 'text/html'
        Extensions = 'htm;html'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpg;jpeg;jpe'
      end
      item
        MimeType = 'image/gif'
        Extensions = 'gif'
      end>
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '.'
    Left = 82
    Top = 167
  end
  object DSRESTWebDispatcher1: TDSRESTWebDispatcher
    Server = DSServer1
    AuthenticationManager = DSAuthenticationManager1
    WebDispatch.PathInfo = 'datasnap*'
    Left = 82
    Top = 122
  end
end
