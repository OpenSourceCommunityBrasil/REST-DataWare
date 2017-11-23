object UniServerModule: TUniServerModule
  OldCreateOrder = False
  TempFolder = 'temp\'
  Title = 'Aplica'#231#227'o Modelo'
  SuppressErrors = []
  Bindings = <>
  MainFormDisplayMode = mfPage
  ServerMessages.UnavailableErrMsg = 'Erro de Comunica'#231#227'o'
  ServerMessages.LoadingMessage = 'Carregando...'
  SSL.SSLOptions.RootCertFile = 'root.pem'
  SSL.SSLOptions.CertFile = 'cert.pem'
  SSL.SSLOptions.KeyFile = 'key.pem'
  SSL.SSLOptions.Method = sslvTLSv1_1
  SSL.SSLOptions.SSLVersions = [sslvTLSv1_1]
  SSL.SSLOptions.Mode = sslmUnassigned
  SSL.SSLOptions.VerifyMode = []
  SSL.SSLOptions.VerifyDepth = 0
  ConnectionFailureRecovery.ErrorMessage = 'Connection Error'
  ConnectionFailureRecovery.RetryMessage = 'Retrying...'
  Height = 150
  Width = 215
end
