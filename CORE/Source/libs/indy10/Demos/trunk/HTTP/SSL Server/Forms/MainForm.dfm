object frmMain: TfrmMain
  Left = 196
  Top = 179
  Width = 342
  Height = 296
  Caption = 'Indy HTTP Server Demo (SSL Only)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtonBar: TPanel
    Left = 0
    Top = 221
    Width = 334
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      334
      41)
    object btnStartStop: TButton
      Left = 256
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Start Server'
      TabOrder = 0
      OnClick = btnStartStopClick
    end
  end
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 334
    Height = 193
    ActivePage = tsSSLSetup
    Align = alTop
    TabIndex = 0
    TabOrder = 1
    object tsSSLSetup: TTabSheet
      Caption = 'SSL Setup'
      ImageIndex = 2
      object Label5: TLabel
        Left = 8
        Top = 8
        Width = 69
        Height = 13
        Caption = 'Certificate File:'
      end
      object Label6: TLabel
        Left = 144
        Top = 8
        Width = 52
        Height = 13
        Caption = 'Cipher List:'
      end
      object Label7: TLabel
        Left = 8
        Top = 56
        Width = 40
        Height = 13
        Caption = 'Key File:'
      end
      object Label8: TLabel
        Left = 144
        Top = 56
        Width = 95
        Height = 13
        Caption = 'Root Certificate File:'
      end
      object Label9: TLabel
        Left = 8
        Top = 104
        Width = 49
        Height = 13
        Caption = 'Password:'
      end
      object edCertFile: TEdit
        Left = 8
        Top = 24
        Width = 121
        Height = 21
        TabOrder = 0
        Text = 'edCertFile'
      end
      object edCipherList: TEdit
        Left = 144
        Top = 24
        Width = 121
        Height = 21
        TabOrder = 1
        Text = 'edCipherList'
      end
      object edKeyFile: TEdit
        Left = 8
        Top = 72
        Width = 121
        Height = 21
        TabOrder = 2
        Text = 'key.pem'
      end
      object edRootCertFile: TEdit
        Left = 144
        Top = 72
        Width = 121
        Height = 21
        TabOrder = 3
        Text = 'edRootCertFile'
      end
      object edPassword: TEdit
        Left = 8
        Top = 120
        Width = 121
        Height = 21
        PasswordChar = '*'
        TabOrder = 4
        Text = 'edPassword'
      end
      object cbMaskPass: TCheckBox
        Left = 136
        Top = 128
        Width = 97
        Height = 17
        Caption = 'Mask Password'
        Checked = True
        State = cbChecked
        TabOrder = 5
        OnClick = cbMaskPassClick
      end
    end
    object tsSettings: TTabSheet
      Caption = 'Settings'
      DesignSize = (
        326
        165)
      object Label2: TLabel
        Left = 4
        Top = 8
        Width = 51
        Height = 13
        Caption = 'Bind to IPs'
      end
      object Label3: TLabel
        Left = 120
        Top = 8
        Width = 54
        Height = 13
        Caption = 'Bind to port'
      end
      object Label4: TLabel
        Left = 120
        Top = 48
        Width = 118
        Height = 13
        Caption = 'Select port from stack list'
      end
      object Label1: TLabel
        Left = 120
        Top = 88
        Width = 83
        Height = 13
        Caption = 'Page Root Folder'
      end
      object lbIPs: TCheckListBox
        Left = 4
        Top = 24
        Width = 109
        Height = 133
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 13
        TabOrder = 0
      end
      object cbPorts: TComboBox
        Left = 120
        Top = 64
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 1
      end
      object edPort: TEdit
        Left = 120
        Top = 24
        Width = 65
        Height = 21
        TabOrder = 2
        Text = '8080'
        OnKeyPress = edPortKeyPress
      end
      object edServerRoot: TEdit
        Left = 120
        Top = 104
        Width = 201
        Height = 21
        TabOrder = 3
        Text = 'edServerRoot'
      end
    end
    object tsProcessLog: TTabSheet
      Caption = 'Process Log'
      ImageIndex = 1
      object lbProcesses: TListBox
        Left = 0
        Top = 0
        Width = 326
        Height = 165
        Style = lbOwnerDrawFixed
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnDrawItem = lbProcessesDrawItem
      end
    end
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 32
    Top = 200
  end
  object IdSchedulerOfThreadDefault1: TIdSchedulerOfThreadDefault
    MaxThreads = 100
    Left = 64
    Top = 200
  end
  object Server: TIdHTTPServer
    OnStatus = ServerStatus
    Bindings = <>
    IOHandler = OpenSSL
    OnConnect = ServerConnect
    OnDisconnect = ServerDisconnect
    OnException = ServerException
    Scheduler = IdSchedulerOfThreadDefault1
    OnCommandGet = ServerCommandGet
    Top = 200
  end
  object OpenSSL: TIdServerIOHandlerSSLOpenSSL
    SSLOptions.KeyFile = 'key.pem'
    SSLOptions.Method = sslvSSLv2
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    OnGetPassword = OpenSSLGetPassword
    Left = 96
    Top = 200
  end
end
