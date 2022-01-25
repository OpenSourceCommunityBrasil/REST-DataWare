object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esUtf8
  OnMassiveProcess = ServerMethodDataModuleMassiveProcess
  OnUserTokenAuth = ServerMethodDataModuleUserTokenAuth
  OnGetToken = ServerMethodDataModuleGetToken
  Height = 252
  Width = 328
  object RESTDWPoolerFD: TRESTDWPoolerDB
    RESTDriver = RESTDWDriverFD1
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    ParamCreate = True
    Left = 78
    Top = 107
  end
  object RESTDWDriverFD1: TRESTDWDriverFD
    CommitRecords = 100
    OnPrepareConnection = RESTDWDriverFD1PrepareConnection
    Connection = Server_FDConnection
    Left = 52
    Top = 107
  end
  object Server_FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=D:\Meus Dados\Projetos\SUGV\Componentes\XyberPower\REST' +
        '_Controls\CORE\Demos\EMPLOYEE.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'DriverID=FB')
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckDefault
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords]
    ConnectedStoredUsage = []
    LoginPrompt = False
    Transaction = FDTransaction1
    OnError = Server_FDConnectionError
    BeforeConnect = Server_FDConnectionBeforeConnect
    Left = 53
    Top = 62
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 54
    Top = 17
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 193
    Top = 63
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 109
    Top = 62
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 82
    Top = 17
  end
  object FDTransaction1: TFDTransaction
    Options.AutoStop = False
    Options.DisconnectAction = xdRollback
    Connection = Server_FDConnection
    Left = 81
    Top = 62
  end
  object DWSETESTE: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        NeedAuthorization = True
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
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovBoolean
            ParamName = 'booleano'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'dwpurl0'
            Alias = '0'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'servertime'
        EventName = 'servertime'
        OnlyPreDefinedParams = True
        OnReplyEventByType = DWSETESTEEventsservertimeReplyEventByType
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
        JsonMode = jmDataware
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
          end
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
            ObjectValue = ovString
            ParamName = 'segundoparam'
            Encoded = True
          end>
        JsonMode = jmPureJSON
        Name = 'getemployeeDW'
        EventName = 'getemployeeDW'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventsgetemployeeDWReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovInteger
            ParamName = 'mynumber'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovInteger
            ParamName = 'result'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'eventint'
        EventName = 'eventint'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventseventintReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovDateTime
            ParamName = 'mydatetime'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovDateTime
            ParamName = 'result'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'eventdatetime'
        EventName = 'eventdatetime'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventseventdatetimeReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'entrada'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'helloworldPJ'
        EventName = 'helloworldPJ'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventshelloworldReplyEvent
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
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'entrada'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'helloworldRDW'
        EventName = 'helloworldRDW'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventshelloworldRDWReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'sql1'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'sql2'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'sql3'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'sql4'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'sql5'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovBoolean
            ParamName = 'result'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'athorarioliberar'
        EventName = 'athorarioliberar'
        OnlyPreDefinedParams = False
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmDataware
        Name = 'assyncevent'
        EventName = 'assyncevent'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents1EventsassynceventReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmDataware
        Name = 'dwevent11'
        EventName = 'dwevent11'
        OnlyPreDefinedParams = False
      end>
    ContextName = 'SE1'
    Left = 191
    Top = 108
  end
  object FDQuery1: TFDQuery
    AfterScroll = FDQuery1AfterScroll
    Connection = Server_FDConnection
    Left = 137
    Top = 62
  end
  object DWServerEvents2: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'helloworld'
        EventName = 'helloworld'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEvents2Eventshelloworld2ReplyEvent
      end>
    ContextName = 'SE2'
    Left = 219
    Top = 108
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    Left = 138
    Top = 17
  end
  object dwcrEmployee: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '<!DOCTYPE html>'
      '<html lang="pt-br">'
      '<head>'
      '    <meta charset="UTF-8">'
      ''
      
        '    <meta http-equiv="Content-Type" content="text/html; charset=' +
        'UTF-8">'
      
        '    <meta name="viewport" content="width=device-width, initial-s' +
        'cale=1, shrink-to-fit=no">'
      
        '    <meta name="description" content="Consumindo servidor RestDa' +
        'taware">'
      '    <link rel="icon" href="img/browser.ico">'
      ''
      
        '    <link rel="alternate" type="application/rss+xml" title="RSS ' +
        '2.0" href="http://www.datatables.net/rss.xml">'
      
        '    <link rel="stylesheet" type="text/css" href="https://cdnjs.c' +
        'loudflare.com/ajax/libs/twitter-bootstrap/4.1.1/css/bootstrap.cs' +
        's">'
      
        '    <link rel="stylesheet" type="text/css" href="https://cdn.dat' +
        'atables.net/1.10.19/css/dataTables.bootstrap4.min.css">'
      ''
      ''
      
        '    <script type="text/javascript" language="javascript" src="ht' +
        'tps://code.jquery.com/jquery-3.3.1.js"></script>'
      
        '    <script type="text/javascript" language="javascript" src="ht' +
        'tps://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></' +
        'script>'
      
        '    <script type="text/javascript" language="javascript" src="ht' +
        'tps://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js' +
        '"></script>'
      ''
      '    {%labeltitle%}'
      ''
      
        '    <link rel="stylesheet" type="text/css" href="//cdn.datatable' +
        's.net/1.10.15/css/jquery.dataTables.css">'
      ''
      '</head>'
      '<body>'
      '    {%navbar%}'
      '    {%datatable%}'
      '    {%incscripts%} '
      '</body>'
      '</html>')
    MasterHtmlTag = '$body'
    IncludeScripts.Strings = (
      '<script src="https://code.jquery.com/jquery-1.12.4.js"></script>'
      
        '    <script src="https://cdn.datatables.net/1.10.16/js/jquery.da' +
        'taTables.min.js"></script>'
      '    <script type="text/javascript">'
      '        $(document).ready(function () {'
      
        '            var datatable = $('#39'#my-table'#39').DataTable({ //dataTab' +
        'le tamb'#233'm funcionar'
      
        '                dom: "Bfrtip", // Use dom: '#39'Blfrtip'#39', para fazer' +
        ' o seletor "por p'#225'gina" aparecer.'
      '                ajax: {'
      '                    url: window.location + '#39'&dwmark:datatable'#39','
      '                    type: '#39'GET'#39','
      
        '                    '#39'beforeSend'#39': function (request) {request.se' +
        'tRequestHeader("content-type","application/x-www-form-urlencoded' +
        '; charset=UTF-8");},'
      '                    dataSrc: '#39#39'},'
      '                stateSave: true,'
      '                columns: ['
      '                    {title: '#39'CODIGO'#39', data: '#39'EMP_NO'#39'},'
      '                    {title: '#39'NOME'#39', data: '#39'FIRST_NAME'#39'},'
      '                    {title: '#39'SOBRENOME'#39', data: '#39'LAST_NAME'#39'},'
      '                    {title: '#39'TELEFONE'#39', data: '#39'PHONE_EXT'#39'},'
      '                    {title: '#39'DATA'#39', data: '#39'HIRE_DATE'#39'},'
      
        '                    {title: '#39'EMPREGO/PAIS'#39', data: '#39'JOB_COUNTRY'#39'}' +
        ','
      '                    {title: '#39'SALARIO'#39', data: '#39'SALARY'#39'},'
      '                ],'
      '            });'
      '            console.log(datatable);'
      '        });'
      '    </script>')
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <
      item
        ContextTag = '<title>Consumindo servidor RestDataware</title>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'labeltitle'
        TagReplace = '{%labeltitle%}'
        ObjectName = 'labeltitle'
      end
      item
        ContextTag = 
          '<nav class="navbar navbar-dark sticky-top bg-dark flex-md-nowrap' +
          ' p-0">'#13#10'        <a class="navbar-brand col-sm-3 col-md-2 mr-0" h' +
          'ref="index.html">'#13#10'            <img src="imgs/logodw.png" alt="R' +
          'EST DATAWARE" title="REST DATAWARE"/>'#13#10'        </a>'#13#10'        <h4' +
          ' style="color: #fff">Consumindo API REST (RDW) com Javascript</h' +
          '4>'#13#10'    </nav>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'navbar'
        TagReplace = '{%navbar%}'
        ObjectName = 'navbar'
      end
      item
        ContextTag = 
          '<main role="main" class="col-md-9 ml-sm-auto col-lg-12 pt-3 px-4' +
          '">'#13#10'        <div class="d-flex justify-content-between flex-wrap' +
          ' flex-md-nowrap align-pessoas-center pb-2 mb-3 border-bottom">'#13#10 +
          '            <h5 class="">Listagem de EMPREGADOS </h5>'#13#10'        <' +
          '/div>'#13#10'    </main>'#13#10#13#10'    <div class="col-xs-12 col-sm-12 col-md' +
          '-12 col-lg-12">'#13#10'        <div id="data-table_wrapper" class="dat' +
          'aTables_wrapper form-inline dt-bootstrap no-footer">'#13#10'          ' +
          '  <table id="my-table" class="display"></table>'#13#10'        </div>'#13 +
          #10'    </div>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'datatable'
        TagReplace = '{%datatable%}'
        ObjectName = 'datatable'
        OnRequestExecute = dwcrEmployeeItemsdatatableRequestExecute
      end>
    Left = 106
    Top = 153
  end
  object dwcLogin: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '')
    MasterHtmlTag = '$body'
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <
      item
        ContextTag = 
          '<ul class="navbar-nav"> <li class="nav-item"> <a class="nav-link' +
          '" href="index">Login</a></ul>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'menu'
        TagReplace = '{%LabelMenu%}'
        ObjectName = 'menu'
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="E-Mail">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'email'
        TagReplace = '{%edtEmail%}'
        ObjectName = 'email'
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="Senha">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'esenha'
        TagReplace = '{%edtSenha%}'
        ObjectName = 'esenha'
      end
      item
        ContextTag = '<button {%itemtag%}>Login</button>'
        TypeItem = 'button'
        ClassItem = 'btn btn-primary'
        TagID = 'blogin'
        TagReplace = '{%btnLoginOK%}'
        ObjectName = 'blogin'
      end
      item
        ContextTag = '<button {%itemtag%}>Esqueci minha Senha</button>'
        TypeItem = 'button'
        ClassItem = 'btn btn-warning'
        TagID = 'bescsenha'
        TagReplace = '{%iwBTNSenha%}'
        ObjectName = 'bescsenha'
      end
      item
        ContextTag = '<button {%itemtag%}>Cadastrar Senha</button>'
        TypeItem = 'button'
        ClassItem = 'btn btn-success'
        TagID = 'bcadsenha'
        TagReplace = '{%btnCadastro%}'
        ObjectName = 'bcadsenha'
      end>
    Left = 134
    Top = 153
  end
  object FDMoniRemoteClientLink1: TFDMoniRemoteClientLink
    Left = 166
    Top = 17
  end
  object FDPhysODBCDriverLink1: TFDPhysODBCDriverLink
    Left = 195
    Top = 17
  end
  object FDQuery2: TFDQuery
    Connection = Server_FDConnection
    SQL.Strings = (
      'select * from SALARY_HISTORY'
      'where emp_no = :emp_no')
    Left = 165
    Top = 62
    ParamData = <
      item
        Name = 'EMP_NO'
        ParamType = ptInput
      end>
  end
  object FDQLogin: TFDQuery
    Connection = Server_FDConnection
    Left = 221
    Top = 63
  end
  object DWServerContext1: TDWServerContext
    IgnoreInvalidParams = False
    ContextList = <
      item
        DWParams = <>
        ContentType = 'text/html'
        Name = 'openfile'
        ContextName = 'openfile'
        Routes = [crAll]
        OnlyPreDefinedParams = False
        IgnoreBaseHeader = False
        NeedAuthorization = True
        OnReplyRequestStream = DWServerContext1ContextListopenfileReplyRequestStream
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        Name = 'index'
        ContextName = 'index'
        Routes = [crAll]
        OnlyPreDefinedParams = False
        IgnoreBaseHeader = False
        NeedAuthorization = True
        OnReplyRequest = DWServerContext1ContextListindexReplyRequest
      end>
    BaseContext = 'www'
    RootContext = 'index'
    Left = 224
    Top = 152
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 110
    Top = 17
  end
end
