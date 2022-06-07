object DM: TDM
  Encoding = esUtf8
  QueuedRequest = False
  Height = 124
  Width = 152
  object DWServerEvents1: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'hello'
        EventName = 'hello'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventshelloReplyEvent
      end>
    Left = 48
    Top = 32
  end
end
