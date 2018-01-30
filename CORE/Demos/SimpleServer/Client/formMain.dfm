object Form2: TForm2
  Left = 426
  Top = 153
  Caption = 'REST Client'
  ClientHeight = 449
  ClientWidth = 705
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poDesktopCenter
  OnCreate = FormCreate
  DesignSize = (
    705
    449)
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 13
    Top = 38
    Width = 26
    Height = 13
    Caption = 'Host'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Label5: TLabel
    Left = 155
    Top = 40
    Width = 31
    Height = 13
    Caption = 'Porta'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 8
    Top = 32
    Width = 689
    Height = 2
    Shape = bsTopLine
  end
  object Label7: TLabel
    Left = 8
    Top = 13
    Width = 177
    Height = 13
    Caption = 'CONFIGURA'#199#195'O SERVIDOR Rest'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 123
    Top = 79
    Width = 35
    Height = 13
    AutoSize = False
    Caption = 'Senha'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 13
    Top = 79
    Width = 43
    Height = 13
    AutoSize = False
    Caption = 'Usu'#225'rio'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel2: TBevel
    Left = 8
    Top = 137
    Width = 457
    Height = 2
    Shape = bsTopLine
  end
  object Label1: TLabel
    Left = 8
    Top = 122
    Width = 80
    Height = 13
    Caption = 'COMANDO SQL'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel3: TBevel
    Left = 8
    Top = 234
    Width = 689
    Height = 2
    Shape = bsTopLine
  end
  object Label2: TLabel
    Left = 8
    Top = 219
    Width = 66
    Height = 13
    Caption = 'RESULTADO'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object eHost: TEdit
    Left = 13
    Top = 55
    Width = 136
    Height = 21
    TabOrder = 0
    Text = '142.54.186.162'
  end
  object ePort: TEdit
    Left = 155
    Top = 52
    Width = 40
    Height = 21
    TabOrder = 1
    Text = '8083'
  end
  object edPasswordDW: TEdit
    Left = 123
    Top = 97
    Width = 100
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
    Text = 'oro@webServer'
  end
  object edUserNameDW: TEdit
    Left = 13
    Top = 97
    Width = 100
    Height = 21
    TabOrder = 3
    Text = 'oro@webServer'
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 242
    Width = 689
    Height = 187
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
    ParentFont = False
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
  end
  object mComando: TMemo
    Left = 8
    Top = 145
    Width = 354
    Height = 72
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Lines.Strings = (
      'select * from pofunc')
    ParentFont = False
    TabOrder = 5
  end
  object Button1: TButton
    Left = 366
    Top = 144
    Width = 104
    Height = 24
    Caption = 'Open Fixo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 229
    Top = 98
    Width = 91
    Height = 19
    Caption = 'Compression'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    State = cbChecked
    TabOrder = 7
  end
  object Button2: TButton
    Left = 366
    Top = 173
    Width = 104
    Height = 24
    Caption = 'Execute'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
    OnClick = Button2Click
  end
  object ProgressBar1: TProgressBar
    Left = 366
    Top = 200
    Width = 331
    Height = 17
    TabOrder = 9
  end
  object Button3: TButton
    Left = 481
    Top = 144
    Width = 104
    Height = 24
    Caption = 'Get Employee'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    OnClick = Button3Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 430
    Width = 705
    Height = 19
    Panels = <
      item
        Text = 'Status'
        Width = 50
      end>
  end
  object Memo1: TMemo
    Left = 465
    Top = 35
    Width = 232
    Height = 100
    Anchors = [akLeft, akTop, akRight]
    Lines.Strings = (
      'Memo1')
    TabOrder = 12
  end
  object Button4: TButton
    Left = 481
    Top = 173
    Width = 104
    Height = 24
    Caption = 'ApplyUpdates'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 13
    OnClick = Button4Click
  end
  object chkhttps: TCheckBox
    Left = 208
    Top = 57
    Width = 97
    Height = 17
    Caption = 'Usar HTTPS'
    TabOrder = 14
  end
  object Button5: TButton
    Left = 593
    Top = 173
    Width = 104
    Height = 24
    Caption = 'Show Massive'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 15
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 593
    Top = 144
    Width = 104
    Height = 24
    Caption = 'Server Time'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 16
    OnClick = Button6Click
  end
  object DataSource1: TDataSource
    DataSet = RESTDWClientSQL1
    Left = 263
    Top = 64
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    FieldDefs = <>
    MasterCascadeDelete = False
    Inactive = False
    Datapacks = -1
    OnGetDataError = RESTDWClientSQL1GetDataError
    DataCache = True
    Params = <>
    DataBase = RESTDWDataBase1
    SQL.Strings = (
      'select * from EMPLOYEE')
    UpdateTableName = 'employee'
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = True
    InBlockEvents = False
    Left = 235
    Top = 64
    object RESTDWClientSQL1EMP_NO: TSmallintField
      FieldName = 'EMP_NO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object RESTDWClientSQL1FIRST_NAME: TStringField
      FieldName = 'FIRST_NAME'
      Required = True
      Size = 15
    end
    object RESTDWClientSQL1LAST_NAME: TStringField
      FieldName = 'LAST_NAME'
      Required = True
    end
    object RESTDWClientSQL1PHONE_EXT: TStringField
      FieldName = 'PHONE_EXT'
      Size = 4
    end
    object RESTDWClientSQL1HIRE_DATE: TSQLTimeStampField
      FieldName = 'HIRE_DATE'
      Required = True
    end
    object RESTDWClientSQL1DEPT_NO: TStringField
      FieldName = 'DEPT_NO'
      Required = True
      Size = 3
    end
    object RESTDWClientSQL1JOB_CODE: TStringField
      FieldName = 'JOB_CODE'
      Required = True
      Size = 5
    end
    object RESTDWClientSQL1JOB_GRADE: TSmallintField
      FieldName = 'JOB_GRADE'
      Required = True
    end
    object RESTDWClientSQL1JOB_COUNTRY: TStringField
      FieldName = 'JOB_COUNTRY'
      Required = True
      Size = 15
    end
    object RESTDWClientSQL1SALARY: TFloatField
      FieldName = 'SALARY'
      Required = True
    end
    object RESTDWClientSQL1FULL_NAME: TStringField
      FieldName = 'FULL_NAME'
      ReadOnly = True
      Size = 37
    end
  end
  object RESTDWDataBase1: TRESTDWDataBase
    Active = False
    Compression = True
    Login = 'oro@webServer'
    Password = 'oro@webServer'
    Proxy = False
    ProxyOptions.Port = 8888
    PoolerService = '142.54.186.162'
    PoolerPort = 8083
    PoolerName = 'TServerMethodDM.RESTDWPoolerDB1'
    StateConnection.AutoCheck = False
    StateConnection.InTime = 1000
    RequestTimeOut = 9999999
    EncodeStrings = True
    Encoding = esASCII
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    ParamCreate = True
    Left = 208
    Top = 64
  end
  object ActionList1: TActionList
    Left = 48
    Top = 56
  end
  object DWClientEvents1: TDWClientEvents
    RESTClientPooler = RESTClientPooler1
    Events = <
      item
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovDateTime
            ParamName = 'result'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'inputdata'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
            ObjectValue = ovString
            ParamName = 'resultstring'
            Encoded = False
          end>
        JsonMode = jmDataware
        Name = 'servertime'
      end
      item
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'teste'
      end
      item
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'sql'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'loaddatasetevent'
      end
      item
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'segundoparam'
            Encoded = False
          end>
        JsonMode = jmDataware
        Name = 'getemployee'
      end>
    Left = 237
    Top = 21
  end
  object RESTClientPooler1: TRESTClientPooler
    DataCompression = True
    Encoding = esASCII
    Host = 'localhost'
    UserName = 'testserver'
    Password = 'testserver'
    ProxyOptions.BasicAuthentication = False
    ProxyOptions.ProxyPort = 0
    RequestTimeOut = 10000
    ThreadRequest = False
    AllowCookies = False
    HandleRedirects = False
    Left = 209
    Top = 21
  end
end
