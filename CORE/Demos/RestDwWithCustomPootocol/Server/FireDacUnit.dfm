inherited FireDac: TFireDac
  OldCreateOrder = True
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\Projects\Business\Bin\LOC\JCN.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'CharacterSet=WIN1252'
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
