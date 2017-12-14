inherited DBX: TDBX
  OldCreateOrder = True
  Width = 144
  object DBConnection: TSQLConnection
    DriverName = 'Firebird'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXFirebird'
      
        'DriverPackageLoader=TDBXDynalinkDriverLoader,DbxCommonDriver240.' +
        'bpl'
      
        'DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borla' +
        'nd.Data.DbxCommonDriver,Version=24.0.0.0,Culture=neutral,PublicK' +
        'eyToken=91d62ebb5b0d1b1b'
      
        'MetaDataPackageLoader=TDBXFirebirdMetaDataCommandFactory,DbxFire' +
        'birdDriver240.bpl'
      
        'MetaDataAssemblyLoader=Borland.Data.TDBXFirebirdMetaDataCommandF' +
        'actory,Borland.Data.DbxFirebirdDriver,Version=24.0.0.0,Culture=n' +
        'eutral,PublicKeyToken=91d62ebb5b0d1b1b'
      'GetDriverFunc=getSQLDriverINTERBASE'
      'LibraryName=dbxfb.dll'
      'LibraryNameOsx=libsqlfb.dylib'
      
        'VendorLib=C:\Program Files (x86)\Firebird\Firebird_2_5\bin\fbcli' +
        'ent.dll'
      
        'VendorLibWin64=C:\Program Files (x86)\Firebird\Firebird_2_5\bin\' +
        'fbclient.dll'
      'VendorLibOsx=/Library/Frameworks/Firebird.framework/Firebird'
      'Database=C:\Projects\Business\Bin\LOC\MDL.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Role=RoleName'
      'MaxBlobSize=-1'
      'LocaleCode=0000'
      'IsolationLevel=ReadCommitted'
      'SQLDialect=3'
      'CommitRetain=False'
      'WaitOnLocks=True'
      'TrimChar=False'
      'BlobSize=-1'
      'ErrorResourceFile='
      'RoleName=RoleName'
      'ServerCharSet='
      'Trim Char=False')
    Left = 32
    Top = 16
  end
  object Query: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQLConnection = DBConnection
    Left = 96
    Top = 16
  end
end
