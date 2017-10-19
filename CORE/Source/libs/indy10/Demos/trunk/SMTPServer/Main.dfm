object Form1: TForm1
  Left = 193
  Top = 149
  BorderStyle = bsDialog
  Caption = 'IdSMTPServer Demo'
  ClientHeight = 239
  ClientWidth = 375
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 48
    Width = 16
    Height = 13
    Caption = 'To:'
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 26
    Height = 13
    Caption = 'From:'
  end
  object Label3: TLabel
    Left = 8
    Top = 80
    Width = 39
    Height = 13
    Caption = 'Subject:'
  end
  object ToLabel: TLabel
    Left = 56
    Top = 48
    Width = 3
    Height = 13
  end
  object FromLabel: TLabel
    Left = 56
    Top = 64
    Width = 3
    Height = 13
  end
  object SubjectLabel: TLabel
    Left = 56
    Top = 80
    Width = 3
    Height = 13
  end
  object Memo1: TMemo
    Left = 8
    Top = 96
    Width = 361
    Height = 137
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnServerOn: TButton
    Left = 242
    Top = 7
    Width = 65
    Height = 25
    Caption = 'Server on'
    TabOrder = 1
    OnClick = btnServerOnClick
  end
  object btnServerOff: TButton
    Left = 307
    Top = 7
    Width = 65
    Height = 25
    Caption = 'Server off'
    Enabled = False
    TabOrder = 2
    OnClick = btnServerOffClick
  end
  object IdSMTPServer1: TIdSMTPServer
    Bindings = <>
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '220'
    Greeting.Text.Strings = (
      'Welcome to the INDY SMTP Server')
    HelpReply.Text.Strings = (
      'Help follows')
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
    OnMsgReceive = IdSMTPServer1MsgReceive
    OnUserLogin = IdSMTPServer1UserLogin
    OnMailFrom = IdSMTPServer1MailFrom
    OnRcptTo = IdSMTPServer1RcptTo
    OnReceived = IdSMTPServer1Received
    ServerName = 'Indy SMTP Server'
    Left = 6
    Top = 2
  end
end
