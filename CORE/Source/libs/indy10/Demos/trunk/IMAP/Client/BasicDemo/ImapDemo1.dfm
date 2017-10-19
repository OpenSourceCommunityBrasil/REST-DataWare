object Form1: TForm1
  Left = 193
  Top = 114
  Width = 601
  Height = 382
  Caption = 'IMAP demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 22
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Server'
  end
  object Label2: TLabel
    Left = 22
    Top = 34
    Width = 48
    Height = 13
    Caption = 'Username'
  end
  object Label3: TLabel
    Left = 22
    Top = 60
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label4: TLabel
    Left = 10
    Top = 120
    Width = 100
    Height = 13
    Caption = 'Messages in mailbox:'
  end
  object Label5: TLabel
    Left = 12
    Top = 100
    Width = 349
    Height = 13
    Caption = 
      'Send emails to anonymous@cyrus.andrew.cmu.edu to populate the in' +
      'box.'
  end
  object Label6: TLabel
    Left = 390
    Top = 6
    Width = 189
    Height = 13
    Caption = 'Mailboxes (click one to view messages):'
  end
  object Label7: TLabel
    Left = 12
    Top = 84
    Width = 318
    Height = 13
    Caption = 
      'cyrus.andrew.cmu.edu is a publically-accessible Cyrus IMAP serve' +
      'r.'
  end
  object Edit1: TEdit
    Left = 90
    Top = 2
    Width = 171
    Height = 21
    TabOrder = 0
    Text = 'cyrus.andrew.cmu.edu'
  end
  object Edit2: TEdit
    Left = 90
    Top = 28
    Width = 171
    Height = 21
    TabOrder = 1
    Text = 'anonymous'
  end
  object Edit3: TEdit
    Left = 90
    Top = 54
    Width = 171
    Height = 21
    TabOrder = 2
    Text = 'You@somewhere.com'
  end
  object Button1: TButton
    Left = 284
    Top = 2
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 3
    OnClick = Button1Click
  end
  object StringGrid1: TStringGrid
    Left = 6
    Top = 140
    Width = 579
    Height = 120
    ColCount = 4
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    TabOrder = 4
  end
  object Button2: TButton
    Left = 250
    Top = 272
    Width = 95
    Height = 25
    Caption = 'Delete message'
    TabOrder = 5
    OnClick = Button2Click
  end
  object ListBox1: TListBox
    Left = 386
    Top = 26
    Width = 193
    Height = 89
    ItemHeight = 13
    TabOrder = 6
    OnClick = ListBox1Click
  end
end
