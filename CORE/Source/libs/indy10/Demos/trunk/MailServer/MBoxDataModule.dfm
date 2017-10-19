object MBoxDataMod: TMBoxDataMod
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 182
  Top = 103
  Height = 480
  Width = 696
  object InternalPOP3: TIdPOP3Server
    OnStatus = InternalPOP3Status
    Bindings = <>
    OnBeforeListenerRun = InternalPOP3BeforeListenerRun
    OnBeforeConnect = InternalPOP3BeforeConnect
    OnConnect = InternalPOP3Connect
    OnDisconnect = InternalPOP3Disconnect
    OnException = InternalPOP3Exception
    OnListenException = InternalPOP3ListenException
    OnExecute = InternalPOP3Execute
    CommandHandlers = <>
    ExceptionReply.Code = '-ERR'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '+OK'
    Greeting.Text.Strings = (
      'Welcome to Indy POP3 Server')
    HelpReply.Code = '+OK'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '-ERR'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '-ERR'
    ReplyUnknownCommand.Text.Strings = (
      'Sorry, Unknown Command')
    OnBeforeCommandHandler = InternalPOP3BeforeCommandHandler
    OnCheckUser = InternalPOP3CheckUser
    OnList = InternalPOP3LIST
    OnRetrieve = InternalPOP3Retrieve
    OnDelete = InternalPOP3Delete
    OnUIDL = InternalPOP3UIDL
    OnStat = InternalPOP3STAT
    OnTop = InternalPOP3TOP
    OnReset = InternalPOP3Reset
    OnQuit = InternalPOP3QUIT
    OnAPOP = InternalPOP3APOP
    Left = 55
    Top = 40
  end
  object InternalSMTP: TIdSMTPServer
    OnStatus = InternalSMTPStatus
    Bindings = <>
    OnBeforeListenerRun = InternalSMTPBeforeListenerRun
    OnBeforeConnect = InternalSMTPBeforeConnect
    OnConnect = InternalSMTPConnect
    OnDisconnect = InternalSMTPDisconnect
    OnException = InternalSMTPException
    OnListenException = InternalSMTPListenException
    OnExecute = InternalSMTPExecute
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '220'
    Greeting.Text.Strings = (
      'Welcome to the INDY SMTP Server')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '500'
    ReplyUnknownCommand.Text.Strings = (
      'Syntax Error')
    ReplyUnknownCommand.EnhancedCode.StatusClass = 5
    ReplyUnknownCommand.EnhancedCode.Subject = 5
    ReplyUnknownCommand.EnhancedCode.Details = 2
    ReplyUnknownCommand.EnhancedCode.Available = True
    ReplyUnknownCommand.EnhancedCode.ReplyAsStr = '5.5.2'
    OnAfterCommandHandler = InternalSMTPAfterCommandHandler
    OnBeforeCommandHandler = InternalSMTPBeforeCommandHandler
    OnMsgReceive = InternalSMTPMsgReceive
    OnUserLogin = InternalSMTPUserLogin
    OnMailFrom = InternalSMTPMailFrom
    OnRcptTo = InternalSMTPRcptTo
    OnReceived = InternalSMTPReceived
    ServerName = 'Emil SMTP Server'
    Left = 190
    Top = 40
  end
  object ExternalSMTP: TIdSMTP
    SASLMechanisms = <>
    Left = 190
    Top = 130
  end
  object ExternalPOP3: TIdPOP3
    AutoLogin = True
    SASLMechanisms = <>
    Left = 55
    Top = 130
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 315
    Top = 45
  end
  object IdPOP3Server1: TIdPOP3Server
    Bindings = <>
    CommandHandlers = <>
    ExceptionReply.Code = '-ERR'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '+OK'
    Greeting.Text.Strings = (
      'Welcome to Indy POP3 Server')
    HelpReply.Code = '+OK'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '-ERR'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '-ERR'
    ReplyUnknownCommand.Text.Strings = (
      'Sorry, Unknown Command')
    Left = 190
    Top = 265
  end
end
