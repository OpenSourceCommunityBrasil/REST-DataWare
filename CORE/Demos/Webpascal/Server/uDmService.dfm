object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esUtf8
  OnUserTokenAuth = ServerMethodDataModuleUserTokenAuth
  OnGetToken = ServerMethodDataModuleGetToken
  Height = 288
  Width = 299
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
    Left = 60
    Top = 129
  end
  object RESTDWDriverFD1: TRESTDWDriverFD
    CommitRecords = 100
    Connection = Server_FDConnection
    Left = 61
    Top = 84
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
    Left = 61
    Top = 39
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 117
    Top = 84
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 89
    Top = 84
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 117
    Top = 39
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 145
    Top = 84
  end
  object FDTransaction1: TFDTransaction
    Options.AutoStop = False
    Options.DisconnectAction = xdRollback
    Connection = Server_FDConnection
    Left = 89
    Top = 39
  end
  object FDQuery1: TFDQuery
    Connection = Server_FDConnection
    SQL.Strings = (
      '')
    Left = 145
    Top = 39
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 173
    Top = 84
  end
  object dwsCrudServer: TDWServerContext
    IgnoreInvalidParams = False
    ContextList = <
      item
        DWParams = <>
        ContentType = 'text/html'
        Name = 'index'
        ContextName = 'index'
        Routes = [crGet, crPost]
        ContextRules = dwcrIndex
        OnlyPreDefinedParams = False
        IgnoreBaseHeader = False
        NeedAuthorization = True
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        Name = 'login'
        ContextName = 'login'
        Routes = [crGet]
        ContextRules = dwcrLogin
        OnlyPreDefinedParams = False
        IgnoreBaseHeader = False
        NeedAuthorization = False
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        Name = 'index2'
        ContextName = 'index2'
        Routes = [crAll]
        OnlyPreDefinedParams = False
        IgnoreBaseHeader = False
        NeedAuthorization = False
        OnBeforeRenderer = dwsCrudServerContextListindex2BeforeRenderer
      end>
    BaseContext = 'www'
    RootContext = 'login'
    OnBeforeRenderer = dwsCrudServerBeforeRenderer
    Left = 112
    Top = 169
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    Left = 201
    Top = 84
  end
  object dwcrIndex: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '')
    MasterHtmlTag = '$body'
    IncludeScripts.Strings = (
      '<script type="text/javascript">'
      ''
      'function setCookie(cname,cvalue,exdays) {'
      ' var d = new Date();'
      ' d.setTime(d.getTime() + (exdays*24*60*60*1000));'
      ' var strictd = "SameSite=Strict";'
      
        ' document.cookie = cname + "=" + cvalue + ";" + strictd + ";path' +
        '=/";'
      '}'
      ''
      'function getCookie(cname) {'
      ' var name = cname + "=";'
      ' var decodedCookie = decodeURIComponent(document.cookie);'
      ' var ca = decodedCookie.split('#39';'#39');'
      ' for(var i = 0; i < ca.length; i++) {'
      '  var c = ca[i];'
      '  while (c.charAt(0) == '#39' '#39') {'
      '   c = c.substring(1);'
      '  }'
      '  if (c.indexOf(name) == 0) {'
      '   return c.substring(name.length, c.length);'
      '  }'
      ' }'
      ' return "";'
      '}'
      ''
      'function logout() {'
      '    window.sessionStorage.removeItem("token");'
      '    window.location = "./login";'
      '}'
      ''
      'function reloadDatatable(value){'
      'var mydt = document.getElementById("employeesresut");'
      'var mydiv = document.getElementById("dataFrame");'
      'mydiv.style.visibility="hidden";'
      ' $('#39'#dataFrame'#39').hide();'
      ' mydt.style.visibility="visible";'
      ' $('#39'#employeesresut'#39').slideDown("slow");'
      ' if (!(value))'
      '  $('#39'#my-table'#39').DataTable().ajax.reload();'
      '}'
      ''
      'function myActionE(id){'
      '   var aurl =  '#39'./index?dwmark:editmodal&id='#39'+id;'
      '   MyHtml("cademployee");'
      '   myVar = setTimeout(carcaemployee(aurl, id), 100);'
      '};'
      ''
      'function ConvertToDecimal(num) {'
      '    num = num.toString(); //If it'#39's not already a String'
      
        '    num = num.slice(0, (num.indexOf(".")) + 3); //With 3 exposin' +
        'g the hundredths place'
      '}'
      ''
      'function cargaeditcontrols(data){'
      ' clearTimeout(myVar);'
      ' var mydt  = document.getElementById("employeesresut");'
      ' if(data.length > 0){'
      '  for (var i = 0; i < data.length; i++) {'
      '   $("#FIRST_NAME").val(data[i].FIRST_NAME);'
      '   $("#LAST_NAME").val(data[i].LAST_NAME);'
      '   $("#PHONE_EXT").val(data[i].PHONE_EXT);'
      '   $("#CAD_HIRE_DATEB").val(data[i].HIRE_DATE);'
      '   $("#JOB_GRADE").val(data[i].JOB_GRADE);'
      '   $("#JOB_COUNTRY").val(data[i].JOB_COUNTRY);'
      '   $("#SALARY").val("R$ " + data[i].SALARY);'
      '   $('#39'.operacao'#39').val('#39'edit'#39');'
      '   var JOBGRADE = data[i].JOB_GRADE;'
      '   var JOBCOUNTRY = data[i].JOB_COUNTRY;'
      '  }'
      '  loadJobs(JOBGRADE, "");'
      '  loadCountry(JOBCOUNTRY, "");'
      '  $('#39'#employeesresut'#39').hide();'
      '  mydt.style.visibility="hidden";'
      '  if (typeof (myVar) !== '#39'undefined'#39'){'
      '    clearTimeout(myVar);'
      '  }'
      '  var myVar = setTimeout(function(){clearTimeout(myVar);'
      
        '                                var mydiv = document.getElementB' +
        'yId("dataFrame");'
      
        '                                mydiv.style.visibility="visible"' +
        ';'
      
        '                                $('#39'#dataFrame'#39').slideDown("slow"' +
        ');}, 1000);'
      ' }'
      ' else {'
      '       reloadDatatable(true);'
      
        '       swal.fire("Aten'#231#227'o", "Erro na carga de dados.", "warning"' +
        ');'
      '      }'
      '}'
      ''
      'function carcaemployee(aurl, id){'
      '   setCookie("tempID", id, 1);'
      '   if (typeof (myVar) !== '#39'undefined'#39'){'
      '    clearTimeout(myVar);'
      '   }'
      '   $.ajax({type        : "post",'
      '           url         : aurl,'
      '           contentType : false,'
      '           contentType : '#39'application/json'#39','
      '           dataType    : '#39'json'#39','
      
        '           headers     : {"Authorization": "Bearer "  + window.s' +
        'essionStorage.getItem('#39'token'#39')},'
      '           success     : function (data) {'
      
        '                                           var myVar = setTimeou' +
        't(cargaeditcontrols(data), 1000);'
      '                                          },'
      '           error       : function(result) {'
      
        '                                           swal.fire("Aten'#231#227'o", ' +
        '"N'#227'o foi poss'#237'vel fazer login...", "warning");'
      '                                          }'
      '           });'
      ''
      '}'
      ''
      'function loaddatatable(){'
      
        'var datatable = $('#39'#my-table'#39').DataTable({ //dataTable tamb'#233'm fu' +
        'ncionar'
      
        '               "language": {'#10'"url": "./templates/brasil.json"'#10'},' +
        '                '
      
        '                dom: "Bfrtip", // Use dom: '#39'Blfrtip'#39', para fazer' +
        ' o seletor "por p'#225'gina" aparecer.'
      '                retrieve: true,'
      '                colReorder: true,'
      '                responsive: true,'
      '                ajax: {'
      '                    url: '#39'./index?dwmark:datatable'#39','
      '                    contentType: false,'
      
        '                    headers     : {"Authorization": "Bearer "  +' +
        ' window.sessionStorage.getItem('#39'token'#39')},'
      '                    type: '#39'POST'#39','
      '                    dataSrc: '#39#39'},'
      '                    stateSave: true,'
      '                    responsive: true,'
      '                    columns: ['
      '                    {title: '#39'ID'#39', data: '#39'EMP_NO'#39'},'
      '                    {title: '#39'Empresa'#39', data: '#39'FIRST_NAME'#39'},'
      '                    {title: '#39'Segundo Nome'#39', data: '#39'LAST_NAME'#39'},'
      '                    {title: '#39'DDD'#39', data: '#39'PHONE_EXT'#39'},'
      '                    {title: '#39'Aniver.'#39', data: '#39'HIRE_DATE'#39'},'
      '                    {title: '#39'Cidade'#39', data: '#39'JOB_COUNTRY'#39'},'
      
        '                    {title: '#39'Sal'#225'rio'#39', data: '#39'SALARY'#39', render: $' +
        '.fn.dataTable.render.number('#39'.'#39', '#39','#39', 2, '#39'R$ '#39')},'
      
        '                    {title: '#39'A'#231#245'es'#39', data: null, sortable: false' +
        ', render: function (obj) {'
      
        #9#9#9#9'      return '#39'<button type="button" class="btn btn-warning b' +
        'tn-xs" onclick="myActionE('#39'+ obj.EMP_NO +'#39')"><i class="far fa-ed' +
        'it"></i></button> '#39' +'
      
        '                                '#39'<button type="button" class="bt' +
        'n btn-danger btn-xs" onclick="myActionD(\'#39#39' + obj.EMP_NO + '#39'\'#39',\' +
        #39#39' + obj.FIRST_NAME + '#39' '#39' + obj.LAST_NAME + '#39'\'#39')"><i class="far ' +
        'fa-trash-alt"></i></button>'#39'; }}'
      '                              ],'
      '                 columnDefs: ['
      
        '                     {"className": "text-center", "width": "20px' +
        '", "targets": 0 },'
      '                     {"width": "100px", "targets": 1 },'
      '                     {"width": "100px", "targets": 2 },'
      
        '                     {"className": "text-center", "width": "30px' +
        '", "targets": 3},'
      '                     {"width": "70px", "targets": 4 },'
      
        '                     {"className": "text-center", "width": "70px' +
        '", "targets": 5 },'
      
        '                     {"className": "text-left", "width": "50px",' +
        ' "targets": 6 },'
      
        '                     {"className": "text-left", "width": "70px",' +
        ' "targets": 7 }'
      '                                       ],'
      
        '                 <!-- initComplete: function () {$( document ).o' +
        'n("click", "tr[role='#39'row'#39']", function(){myActionE($(this).childr' +
        'en('#39'td:first-child'#39').text())});} -->'
      '            });'
      ' console.log(datatable);'
      ' reloadDatatable(true);'
      '}'
      ''
      '$(document).ready(function () {'
      ' loaddatatable();'
      '});'
      ''
      'function MyHtml(htmlstring){'
      '   var aurl = '#39#39';'
      '   var mydt  = document.getElementById("employeesresut");'
      '   var divPessoa  = document.getElementById("dataFrame");'
      '   aurl =  '#39'./index?dwmark:dwmyhtml&myhtml='#39' + htmlstring;'
      '   $.ajax('
      '                {'
      '                   type: "post",'
      '                   url: aurl,'
      '                   contentType: false,'
      
        '                   headers     : {"Authorization": "Bearer " + w' +
        'indow.sessionStorage.getItem('#39'token'#39')},'
      
        '                   contentType: '#39'application/x-www-form-urlencod' +
        'ed; charset=UTF-8'#39','
      '                   success: function (data) {'
      
        '                             var mydt = document.getElementById(' +
        '"employeesresut");'
      
        '                             var mydiv = document.getElementById' +
        '("dataFrame");'
      '                             mydt.style.visibility="hidden";'
      
        '                             $('#39'#dataFrameContainer'#39').html(data)' +
        ';'
      '                             $('#39'#employeesresut'#39').hide();'
      '                             mydiv.style.visibility="visible";'
      '                             $('#39'#dataFrame'#39').slideDown("slow");'
      '                   },'
      '                   error: function(result) {'
      
        '                             swal.fire("Aten'#231#227'o", "Erro na auten' +
        'tica'#231#227'o.", "warning");'
      '                   }'
      '                   });'
      '}'
      ''
      'function keypressednum(elementname, obj , e ) {'
      '     var tecla = ( window.event ) ? e.keyCode : e.which;'
      '     var texto = document.getElementById(elementname).value'
      '     var indexvir = texto.indexOf(",")'
      '     var indexpon = texto.indexOf(".")'
      ''
      '    if ( tecla == 8 || tecla == 0 )'
      '        return true;'
      
        '    if ( tecla != 44 && tecla != 46 && tecla < 48 || tecla > 57 ' +
        ')'
      '        return false;'
      
        '    if (tecla == 44) { if (indexvir !== -1 || indexpon !== -1) {' +
        'return false} }'
      
        '    if (tecla == 46) { if (indexvir !== -1 || indexpon !== -1) {' +
        'return false} }'
      '}'
      '</script>')
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <
      item
        ContextTag = 
          '<table id="my-table" class="display nowrap" style="width:100%"><' +
          '/table>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'iddatatable'
        TagReplace = '{%datatable%}'
        ObjectName = 'datatable'
        OnRequestExecute = dwcrIndexItemsdatatableRequestExecute
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule2">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'cadmodal'
        TagReplace = '{%cadModal%}'
        ObjectName = 'cadModal'
        OnBeforeRendererContextItem = dwcrIndexItemscadModalBeforeRendererContextItem
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule3">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'editmodal'
        TagReplace = '{%editModal%}'
        ObjectName = 'editModal'
        OnRequestExecute = dwcrIndexItemseditModalRequestExecute
      end
      item
        ContextTag = 
          '<div class="modal fade bd-example-modal-lg" tabindex="-1"  id="m' +
          'odal_apagar" role="dialog" ><div class="modal-dialog" role="docu' +
          'ment"><div class="modal-content"><div class="modal-header"><h5 c' +
          'lass="modal-title" id="title">Apagar</h5><button type="button" o' +
          'nclick="canceldelete()" class="close" data-dismiss="modal" aria-' +
          'label="Close"><span aria-hidden="true">&times;</span></button></' +
          'div><div class="modal-body">Voc'#234' deseja realmente deletar o empr' +
          'egado <spam id="nome_empregado"></spam></div><div class="modal-f' +
          'ooter"><button type="button" onclick="deleteemployee()" class="b' +
          'tn btn-success" id="ok">Ok</button><button type="button" onclick' +
          '="canceldelete()" class="btn btn-danger"  id="cancelar">Cancelar' +
          '</button></div></div></div></div>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'deletemodal'
        TagReplace = '{%deleteModal%}'
        ObjectName = 'deleteModal'
        OnRequestExecute = dwcrIndexItemsdeleteModalRequestExecute
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule5">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'operation'
        TagReplace = '{%operation%}'
        ObjectName = 'operation'
        OnRequestExecute = dwcrIndexItemsoperationRequestExecute
      end
      item
        ContextTag = 
          '<select class="form-control" id="JOB_COUNTRY" name = "JOB_COUNTR' +
          'Y">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'dwcbpaises'
        TagReplace = '{%dwcbpaises%}'
        ObjectName = 'dwcbpaises'
        OnRequestExecute = dwcrIndexItemsdwcbpaisesRequestExecute
        OnBeforeRendererContextItem = dwcrIndexItemsdwcbPaisesBeforeRendererContextItem
      end
      item
        ContextTag = '<select class="form-control" id="JOB_GRADE" name = "JOB_GRADE">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'dwcbCargos'
        TagReplace = '{%dwcbCargos%}'
        ObjectName = 'dwcbCargos'
        OnRequestExecute = dwcrIndexItemsdwcbCargosRequestExecute
      end
      item
        ContextTag = '<li class="header">Menu</li>'#13#10#13#10
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'dwsidemenu'
        TagReplace = '{%dwsidemenu%}'
        ObjectName = 'dwsidemenu'
        OnBeforeRendererContextItem = dwcrIndexItemsdwsidemenuBeforeRendererContextItem
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule9">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'meuloginname'
        TagReplace = '{%meuloginname%}'
        ObjectName = 'meuloginname'
        OnBeforeRendererContextItem = dwcrIndexItemsmeuloginnameBeforeRendererContextItem
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule10">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'LabelMenu'
        TagReplace = '{%LabelMenu%}'
        ObjectName = 'LabelMenu'
        OnBeforeRendererContextItem = dwcrIndexItemsLabelMenuBeforeRendererContextItem
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule11">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'dwmyhtml'
        TagReplace = '{%dwmyhtml%}'
        ObjectName = 'dwmyhtml'
        OnRequestExecute = dwcrIndexItemsdwmyhtmlRequestExecute
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule12">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'dwframe'
        TagReplace = '{%dwframe%}'
        ObjectName = 'dwframe'
        OnBeforeRendererContextItem = dwcrIndexItemsdwframeBeforeRendererContextItem
      end>
    OnBeforeRenderer = dwcrIndexBeforeRenderer
    Left = 188
    Top = 129
  end
  object dwcrLogin: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '')
    MasterHtmlTag = '$body'
    IncludeScripts.Strings = (
      '<script>'
      'function setCookie(cname,cvalue,exdays) {'
      ' var d = new Date();'
      ' d.setTime(d.getTime() + (exdays*24*60*60*1000));'
      ' var strictd = "SameSite=Strict";'
      
        ' document.cookie = cname + "=" + cvalue + ";" + strictd + ";path' +
        '=/";'
      '}'
      ''
      'function getCookie(cname) {'
      ' var name = cname + "=";'
      ' var decodedCookie = decodeURIComponent(document.cookie);'
      ' var ca = decodedCookie.split('#39';'#39');'
      ' for(var i = 0; i < ca.length; i++) {'
      '  var c = ca[i];'
      '  while (c.charAt(0) == '#39' '#39') {'
      '   c = c.substring(1);'
      '  }'
      '  if (c.indexOf(name) == 0) {'
      '   return c.substring(name.length, c.length);'
      '  }'
      ' }'
      ' return "";'
      '}'
      ''
      ''
      'function gettoken() {'
      '   var ausername = $("#usr").val();'
      '   var apassword = $("#pwd").val();'
      '    if (ausername == null) {'
      '        window.location = "./index";'
      '    } else {'
      ''
      '        $.ajax({'
      '            type: "POST",'
      '            url: "./gettoken",'
      '            beforeSend: function(request) {'
      
        '                request.setRequestHeader("Authorization", "Beare' +
        'r " + btoa(ausername + ":" + apassword));'
      '            },'
      '            success     : function (data) {'
      '                                           var aurl = "./index";'
      
        '                                           window.sessionStorage' +
        '.setItem('#39'token'#39', data.token);'
      
        '                                           $.ajax({type        :' +
        ' "post",'
      
        '                                                   url         :' +
        ' aurl,'
      
        '                                                   contentType :' +
        ' false,'
      
        '                                                   contentType :' +
        ' '#39'application/x-www-form-urlencoded; charset=UTF-8'#39','
      
        '                                                   headers     :' +
        ' {"Authorization": "Bearer " + window.sessionStorage.getItem('#39'to' +
        'ken'#39')},'
      
        '                                                   success     :' +
        ' function (data){'
      
        '                                                                ' +
        '                  document.open();'
      
        '                                                                ' +
        '                  document.write(data);'
      
        '                                                                ' +
        '                  document.close();'
      
        '                                                                ' +
        '                },'
      
        '                                                   error       :' +
        ' function(result) {'
      
        '                                                                ' +
        '                   swal.fire("Aten'#231#227'o", "N'#227'o foi poss'#237'vel fazer ' +
        'login...", "warning");'
      
        '                                                                ' +
        '                  }'
      '                                                 });'
      '                                           return true;'
      '                                          },'
      '            error: function() {'
      '                window.location = "./index";'
      
        '                swal.fire("Aten'#231#227'o", "N'#227'o foi poss'#237'vel fazer log' +
        'in...", "warning");'
      '                return false;'
      '            },'
      '        });'
      '    }'
      '}'
      ''
      'function mylogin(){'
      ' gettoken()'
      '}'
      ''
      '$(document).ready(function(){'
      '   $("#myModal").modal({backdrop: '#39'static'#39', keyboard: false});'
      '});'
      ''
      '</script>'
      '')
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <
      item
        ContextTag = 
          '<button onclick="mylogin()" class="btn btn-primary btn-lg btn-bl' +
          'ock login-btn">Login</button>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'login'
        TagReplace = '{%login%}'
        ObjectName = 'login'
      end
      item
        ContextTag = '<li class="header"></li>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'LabelMenu'
        TagReplace = '{%LabelMenu%}'
        ObjectName = 'LabelMenu'
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule3">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'meuloginname'
        TagReplace = '{%meuloginname%}'
        ObjectName = 'meuloginname'
        OnBeforeRendererContextItem = dwcrLoginItemsmeuloginnameBeforeRendererContextItem
      end>
    OnBeforeRenderer = dwcrLoginBeforeRenderer
    Left = 184
    Top = 176
  end
  object rOpenSecrets: TRESTDWClientSQL
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    BinaryCompatibleMode = False
    MasterCascadeDelete = True
    BinaryRequest = False
    Datapacks = -1
    DataCache = False
    MassiveType = mtMassiveCache
    Params = <>
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    RaiseErrors = True
    ActionCursor = crSQLWait
    ReflectChanges = False
    Left = 128
    Top = 224
  end
end
