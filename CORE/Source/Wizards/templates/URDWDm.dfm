object %0:s: T%0:s
  OldCreateOrder = False
  Encoding = esUtf8
  Left = 531
  Top = 234
  Height = 288
  Width = 390
  object RESTDWPoolerDB1: TRESTDWPoolerDB
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    ParamCreate = True
    Left = 84
    Top = 71
  end
  object DWServerEvents1: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'helloworld'
        OnReplyEvent = DWServerEvents1EventshelloworldReplyEvent
      end>
    ContextName = 'SE1'
    Left = 192
    Top = 71
  end
end
