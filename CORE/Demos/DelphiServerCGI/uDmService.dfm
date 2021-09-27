object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esUtf8
  OnMassiveProcess = ServerMethodDataModuleMassiveProcess
  OnUserTokenAuth = ServerMethodDataModuleUserTokenAuth
  OnGetToken = ServerMethodDataModuleGetToken
  Height = 207
  Width = 294
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
    Left = 52
    Top = 103
  end
  object RESTDWDriverFD1: TRESTDWDriverFD
    CommitRecords = 100
    Connection = Server_FDConnection
    Left = 53
    Top = 59
  end
  object Server_FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=D:\Meus Dados\Projetos\SUGV\Componentes\XyberPower\REST' +
        '_Controls\DEMO\EMPLOYEE.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
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
    BeforeConnect = Server_FDConnectionBeforeConnect
    Left = 53
    Top = 15
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 109
    Top = 59
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 81
    Top = 59
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 109
    Top = 15
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 137
    Top = 59
  end
  object FDTransaction1: TFDTransaction
    Options.AutoStop = False
    Options.DisconnectAction = xdRollback
    Connection = Server_FDConnection
    Left = 81
    Top = 15
  end
  object DWServerEvents1: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
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
        OnReplyEvent = DWServerEvents1EventsservertimeReplyEvent
      end
      item
        Routes = [crAll]
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
        OnReplyEvent = DWServerEvents1EventstesteReplyEvent
      end
      item
        Routes = [crAll]
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
        OnReplyEvent = DWServerEvents1EventsloaddataseteventReplyEvent
      end
      item
        Routes = [crAll]
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
            ObjectDirection = odIN
            ObjectValue = ovInteger
            ParamName = 'id'
            Encoded = True
          end>
        JsonMode = jmDataware
        Name = 'getemployee'
        OnReplyEvent = DWServerEvents1EventsgetemployeeReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'entrada'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'helloworld'
        OnReplyEvent = DWServerEvents1EventshelloworldReplyEvent
      end>
    ContextName = 'se1'
    Left = 80
    Top = 103
  end
  object FDQuery1: TFDQuery
    Connection = Server_FDConnection
    SQL.Strings = (
      '')
    Left = 137
    Top = 15
  end
  object DWServerContext1: TDWServerContext
    IgnoreInvalidParams = False
    ContextList = <
      item
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'entrada'
            Encoded = True
          end>
        ContentType = 'text/html'
        ContextName = 'init'
        Routes = [crAll]
        IgnoreBaseHeader = False
        OnReplyRequest = DWServerContext1ContextListinitReplyRequest
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'index'
        Routes = [crAll]
        IgnoreBaseHeader = False
        OnReplyRequest = DWServerContext1ContextListindexReplyRequest
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'openfile'
        Routes = [crAll]
        IgnoreBaseHeader = False
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'angular'
        Routes = [crAll]
        IgnoreBaseHeader = False
        OnReplyRequest = DWServerContext1ContextListangularReplyRequest
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'webpascal'
        DefaultHtml.Strings = (
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
          ''
          '    {%navbar%}'
          '    {%datatable%}'
          '    {%incscripts%} '
          '</body>'
          '</html>')
        Routes = [crAll]
        ContextRules = dwcrEmployee
        IgnoreBaseHeader = False
      end>
    BaseContext = 'www'
    RootContext = 'webpascal'
    Left = 108
    Top = 103
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
      '                    url: window.location + '#39'?dwmark:datatable'#39','
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
      '                    {title: '#39'DEPARTAMENTO'#39', data: '#39'DEPT_NO'#39'},'
      '                    {title: '#39'CARGO'#39', data: '#39'JOB_CODE'#39'},'
      '                    {title: '#39'CARGO/ID'#39', data: '#39'JOB_GRADE'#39'},'
      
        '                    {title: '#39'EMPREGO/PAIS'#39', data: '#39'JOB_COUNTRY'#39'}' +
        ','
      '                    {title: '#39'SALARIO'#39', data: '#39'SALARY'#39'},'
      '                    {title: '#39'NOME COMPLETO'#39', data: '#39'FULL_NAME'#39'},'
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
    Left = 136
    Top = 103
  end
  object FDQLogin: TFDQuery
    Connection = Server_FDConnection
    Left = 232
    Top = 48
  end
end
