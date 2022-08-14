object %0:s: T%0:s
  Encoding = esUtf8
  QueuedRequest = False
  Height = 156
  Width = 230
  object RESTDWServerEvents1: TRESTDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        NeedAuthorization = True
        Params = <>
        JsonMode = jmPureJSON
        Name = 'helloworld'
        EventName = 'helloworld'
        BaseURL = '/'
        OnlyPreDefinedParams = False
        OnReplyEventByType = RESTDWServerEvents1EventshelloworldReplyEventByType
      end>
    Left = 64
    Top = 32
  end
end
