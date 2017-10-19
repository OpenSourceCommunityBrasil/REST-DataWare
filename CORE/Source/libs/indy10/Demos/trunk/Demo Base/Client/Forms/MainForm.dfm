object frmMain: TfrmMain
  Left = 321
  Top = 179
  Width = 356
  Height = 490
  Caption = 'Indy Base Client'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 117
    Width = 348
    Height = 116
    Align = alTop
  end
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 348
    Height = 117
    Align = alTop
    Caption = 
      'This is nothing more then an example of a test client.  I would ' +
      'suggest that you create your own client application and use thre' +
      'ading to do load testing from a simple client such as this.  For' +
      ' example this client will connect and disconnect to/from a serve' +
      'r with threads.  If you wanted the client to run some test cases' +
      ' for you then you should add in those test cases in the appropri' +
      'ate spots on the Client component.  Each thread creates a duplic' +
      'ate of this component.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 8
    Top = 120
    Width = 25
    Height = 13
    Caption = 'Host:'
  end
  object Label3: TLabel
    Left = 8
    Top = 160
    Width = 22
    Height = 13
    Caption = 'Port:'
  end
  object Label4: TLabel
    Left = 144
    Top = 120
    Width = 68
    Height = 13
    Caption = 'Thread Count:'
  end
  object lblConCons: TLabel
    Left = 144
    Top = 163
    Width = 196
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Current Concurrent Connections: 0'
  end
  object lblMaxCons: TLabel
    Left = 144
    Top = 179
    Width = 196
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'lblMaxCons'
  end
  object lblTotalCons: TLabel
    Left = 144
    Top = 195
    Width = 196
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'lblTotalCons'
  end
  object Button1: TButton
    Left = 8
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = Button1Click
  end
  object edHost: TEdit
    Left = 8
    Top = 136
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'localhost'
  end
  object edPort: TEdit
    Left = 8
    Top = 176
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '8800'
    OnKeyPress = edPortKeyPress
  end
  object edThreads: TEdit
    Left = 144
    Top = 136
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '1'
    OnChange = edThreadsChange
    OnKeyPress = edThreadsKeyPress
  end
  object lvStatus: TListView
    Left = 0
    Top = 233
    Width = 348
    Height = 223
    Align = alClient
    Columns = <
      item
        Caption = 'Thread Number'
        Width = 100
      end
      item
        Caption = 'Thread State'
        Width = 200
      end>
    TabOrder = 4
    ViewStyle = vsReport
  end
  object SampleClient: TIdTCPClient
    OnDisconnected = SampleClientDisconnected
    OnWork = SampleClientWork
    ConnectTimeout = 0
    Host = 'localhost'
    IPVersion = Id_IPv4
    OnConnected = SampleClientConnected
    Port = 8800
    ReadTimeout = -1
    Left = 80
    Top = 200
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 112
    Top = 200
  end
end
