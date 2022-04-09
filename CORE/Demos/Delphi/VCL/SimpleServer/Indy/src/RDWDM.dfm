object DM: TDM
  Height = 119
  Width = 195
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
    Left = 80
    Top = 40
  end
end
