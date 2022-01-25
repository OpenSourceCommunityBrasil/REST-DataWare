object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esUtf8
  OnMassiveProcess = ServerMethodDataModuleMassiveProcess
  OnUserTokenAuth = ServerMethodDataModuleUserTokenAuth
  OnGetToken = ServerMethodDataModuleGetToken
  QueuedRequest = False
  Height = 246
  Width = 496
  object Server_FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Program Files (x86)\Firebird\Firebird_2_1\examples\e' +
        'mpbuild\EMPLOYEE.FDB'
      'User_Name=SYSDBA'
      'Password=172157'
      'Server=localhost'
      'Port=3050'
      'CharacterSet='
      'DriverID=FB')
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckDefault
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords]
    ConnectedStoredUsage = []
    LoginPrompt = False
    Transaction = FDTransaction1
    OnError = Server_FDConnectionError
    BeforeConnect = Server_FDConnectionBeforeConnect
    Left = 37
    Top = 15
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 357
    Top = 67
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 329
    Top = 67
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 237
    Top = 71
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 385
    Top = 67
  end
  object FDTransaction1: TFDTransaction
    Options.AutoStop = False
    Options.DisconnectAction = xdRollback
    Connection = Server_FDConnection
    Left = 209
    Top = 71
  end
  object FDQuery1: TFDQuery
    Connection = Server_FDConnection
    SQL.Strings = (
      '')
    Left = 185
    Top = 15
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 413
    Top = 67
  end
  object RESTDWPoolerDB1: TRESTDWPoolerDB
    RESTDriver = RESTDWDriverFD1
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    ParamCreate = True
    Left = 56
    Top = 112
  end
  object DWServerEvents1: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
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
        EventName = 'servertime'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventsservertimeReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
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
        EventName = 'teste'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventstesteReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
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
        EventName = 'loaddatasetevent'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventsloaddataseteventReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'getemployee'
        EventName = 'getemployee'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventsgetemployeeReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'getemployeeDW'
        EventName = 'getemployeeDW'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventsgetemployeeReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'set'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'get'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'delete'
            Encoded = True
          end>
        JsonMode = jmPureJSON
        Name = 'employee'
        EventName = 'employee'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventsemployeeReplyEvent
      end>
    Left = 184
    Top = 120
  end
  object RESTDWDriverFD1: TRESTDWDriverFD
    CommitRecords = 100
    Connection = Server_FDConnection
    Left = 56
    Top = 64
  end
  object qryEmployee: TFDQuery
    Connection = Server_FDConnection
    SQL.Strings = (
      'SELECT * FROM EMPLOYEE !WHERE')
    Left = 249
    Top = 15
    MacroData = <
      item
        Value = Null
        Name = 'WHERE'
      end>
    object qryEmployeeEMP_NO: TSmallintField
      FieldName = 'EMP_NO'
      Origin = 'EMP_NO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object qryEmployeeFIRST_NAME: TStringField
      FieldName = 'FIRST_NAME'
      Origin = 'FIRST_NAME'
      Required = True
      Size = 15
    end
    object qryEmployeeLAST_NAME: TStringField
      FieldName = 'LAST_NAME'
      Origin = 'LAST_NAME'
      Required = True
    end
    object qryEmployeePHONE_EXT: TStringField
      FieldName = 'PHONE_EXT'
      Origin = 'PHONE_EXT'
      Size = 4
    end
    object qryEmployeeHIRE_DATE: TSQLTimeStampField
      FieldName = 'HIRE_DATE'
      Origin = 'HIRE_DATE'
    end
    object qryEmployeeDEPT_NO: TStringField
      FieldName = 'DEPT_NO'
      Origin = 'DEPT_NO'
      Required = True
      FixedChar = True
      Size = 3
    end
    object qryEmployeeJOB_CODE: TStringField
      FieldName = 'JOB_CODE'
      Origin = 'JOB_CODE'
      Required = True
      Size = 5
    end
    object qryEmployeeJOB_GRADE: TSmallintField
      FieldName = 'JOB_GRADE'
      Origin = 'JOB_GRADE'
      Required = True
    end
    object qryEmployeeJOB_COUNTRY: TStringField
      FieldName = 'JOB_COUNTRY'
      Origin = 'JOB_COUNTRY'
      Required = True
      Size = 15
    end
    object qryEmployeeSALARY: TFloatField
      FieldName = 'SALARY'
    end
    object qryEmployeeFULL_NAME: TStringField
      FieldName = 'FULL_NAME'
      Origin = 'FULL_NAME'
      Size = 37
    end
  end
end
