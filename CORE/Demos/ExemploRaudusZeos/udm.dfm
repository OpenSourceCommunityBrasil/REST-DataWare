object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 164
  Width = 256
  object sqlDb: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    Properties.Strings = (
      'controls_cp=CP_UTF16')
    TransactIsolationLevel = tiReadCommitted
    Connected = True
    HostName = ''
    Port = 3050
    Database = '192.168.1.28/3050:C:\Raudus\examples\24-Employee\EMPLOYEE.FDB'
    User = 'SYSDBA'
    Password = 'masterkey'
    Protocol = 'firebird-2.5'
    LibraryLocation = 'C:\Windows\SysWOW64\fbclient.dll'
    Left = 32
    Top = 24
  end
  object ZQuery1: TZQuery
    Connection = sqlDb
    AfterScroll = ZQuery1AfterScroll
    SQL.Strings = (
      'select DEPT_NO, DEPARTMENT'
      'from DEPARTMENT'
      'order by DEPT_NO')
    Params = <>
    Left = 96
    Top = 24
    object ZQuery1DEPT_NO: TWideStringField
      FieldName = 'DEPT_NO'
      Required = True
      Size = 3
    end
    object ZQuery1DEPARTMENT: TWideStringField
      FieldName = 'DEPARTMENT'
      Required = True
      Size = 25
    end
  end
  object ZQuery2: TZQuery
    Connection = sqlDb
    SQL.Strings = (
      
        'select EMP_NO, FIRST_NAME, LAST_NAME,PHONE_EXT, HIRE_DATE, DEPT_' +
        'NO, SALARY from EMPLOYEE      where DEPT_NO = :DEPT_NO order by ' +
        'EMP_NO')
    Params = <
      item
        DataType = ftInteger
        Name = 'DEPT_NO'
        ParamType = ptUnknown
      end>
    Left = 96
    Top = 88
    ParamData = <
      item
        DataType = ftInteger
        Name = 'DEPT_NO'
        ParamType = ptUnknown
      end>
    object ZQuery2EMP_NO: TSmallintField
      FieldName = 'EMP_NO'
      Required = True
    end
    object ZQuery2FIRST_NAME: TWideStringField
      FieldName = 'FIRST_NAME'
      Required = True
      Size = 15
    end
    object ZQuery2LAST_NAME: TWideStringField
      FieldName = 'LAST_NAME'
      Required = True
    end
    object ZQuery2PHONE_EXT: TWideStringField
      FieldName = 'PHONE_EXT'
      Size = 4
    end
    object ZQuery2HIRE_DATE: TDateTimeField
      FieldName = 'HIRE_DATE'
      Required = True
    end
    object ZQuery2DEPT_NO: TWideStringField
      FieldName = 'DEPT_NO'
      Required = True
      Size = 3
    end
    object ZQuery2SALARY: TFloatField
      FieldName = 'SALARY'
      Required = True
    end
  end
  object DataSource1: TDataSource
    DataSet = ZQuery1
    Left = 168
    Top = 24
  end
end
