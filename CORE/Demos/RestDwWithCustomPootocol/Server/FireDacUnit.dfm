inherited FireDac: TFireDac
  OldCreateOrder = True
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\DelphiComponents\RestDW\DEMO\EMPLOYEE.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Server=localhost'
      'Port=3050'
      'CharacterSet='
      'DriverID=FB')
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords]
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = FDConnectionBeforeConnect
    Left = 38
    Top = 17
  end
  object FDQuery: TFDQuery
    Connection = FDConnection
    Left = 112
    Top = 17
  end
end
