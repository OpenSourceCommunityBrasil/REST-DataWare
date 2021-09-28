object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  Encoding = esUtf8
  Height = 226
  Width = 243
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
    Top = 105
  end
  object RESTDWDriverFD1: TRESTDWDriverFD
    CommitRecords = 100
    Connection = sqlLocalDBC
    Left = 53
    Top = 60
  end
  object FDQuery1: TFDQuery
    Connection = sqlLocalDBC
    SQL.Strings = (
      '')
    Left = 138
    Top = 16
  end
  object dwsCrudServer: TDWServerContext
    IgnoreInvalidParams = False
    ContextList = <
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'index'
        Routes = [crGet, crPost]
        ContextRules = dwcrIndex
        IgnoreBaseHeader = False
        OnAuthRequest = dwsCrudServerContextListindexAuthRequest
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'login'
        Routes = [crGet]
        ContextRules = dwcrLogin
        IgnoreBaseHeader = False
      end>
    BaseContext = 'www'
    RootContext = 'login'
    OnBeforeRenderer = dwsCrudServerBeforeRenderer
    Left = 144
    Top = 105
  end
  object dwcrIndex: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '')
    MasterHtmlTag = '$body'
    IncludeScripts.Strings = (
      '<script type="text/javascript">'
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
      'function reloadDatatable(value){'
      'var mydt = document.getElementById("employeesresut");'
      'var mydiv = document.getElementById("dataEmployee");'
      'mydiv.style.visibility="hidden";'
      ' $('#39'#dataEmployee'#39').hide();'
      ' mydt.style.visibility="visible";'
      ' $('#39'#employeesresut'#39').slideDown("slow");'
      ' if (!(value))'
      '  $('#39'#my-table'#39').DataTable().ajax.reload();'
      '}'
      ''
      'function loaddatatable(){'
      
        'var datatable = $('#39'#my-table'#39').DataTable({ //dataTable tamb'#233'm fu' +
        'ncionar'
      
        '                dom: "Bfrtip", // Use dom: '#39'Blfrtip'#39', para fazer' +
        ' o seletor "por p'#225'gina" aparecer.'
      '                ajax: {'
      '                    url: '#39'./index?dwmark:datatable'#39','
      '                    contentType: false,                    '
      '                    data: {username: getCookie("username"),'
      '                              password: getCookie("password")},'
      '                    type: '#39'POST'#39','
      '                    dataSrc: '#39#39'},'
      '                stateSave: true,'
      '                responsive: true,'
      '                columns: ['
      '                    {title: '#39'CODIGO'#39', data: '#39'EMP_NO'#39'},'
      '                    {title: '#39'NOME'#39', data: '#39'FIRST_NAME'#39'},'
      '                    {title: '#39'SOBRENOME'#39', data: '#39'LAST_NAME'#39'},'
      '                    {title: '#39'TELEFONE'#39', data: '#39'PHONE_EXT'#39'},'
      '                    {title: '#39'DATA'#39', data: '#39'HIRE_DATE'#39'},'
      
        '                    {title: '#39'EMPREGO/PAIS'#39', data: '#39'JOB_COUNTRY'#39'}' +
        ','
      '                    {title: '#39'SALARIO'#39', data: '#39'SALARY'#39'},'
      
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
      
        '                     {"className": "text-right", "width": "50px"' +
        ', "targets": 6 },'
      
        '                     {"className": "text-right", "width": "70px"' +
        ', "targets": 7 }'
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
      ' $('#39'#CAD_HIRE_DATEB'#39').mask('#39'99/99/9999'#39');'
      ' $('#39'#PHONE_EXT'#39').mask('#39'(999)'#39');'
      ' loaddatatable();'
      '});'
      '   '
      
        '$('#39'#CAD_HIRE_DATEB'#39').datepicker({timepicker:false, format: '#39'dd/m' +
        'm/yyyy'#39'});'
      ''
      'function newEmployee(){'
      '       var mydiv = document.getElementById("dataEmployee");'
      '       var mydt  = document.getElementById("employeesresut");'
      '       $('#39'#employeesresut'#39').hide();'
      '       mydt.style.visibility="hidden";'
      '       $("#FIRST_NAME").val('#39#39');'
      '       $("#LAST_NAME").val('#39#39');'
      '       $("#PHONE_EXT").val('#39#39');'
      '       $("#CAD_HIRE_DATEB").val('#39#39');'
      '       $("#JOB_GRADE").val('#39#39');'
      '       $("#JOB_COUNTRY").val('#39#39');'
      '       $("#SALARY").val('#39#39');'
      '       $('#39'.operacao'#39').val('#39'insert'#39');'
      '       mydiv.style.visibility="visible";'
      '       $('#39'#dataEmployee'#39').slideDown("slow");'
      '};'
      ' '
      '$('#39'.close'#39').click(function(){'
      '       reloadDatatable(true);'
      '});'
      ''
      'function myActionE(id){'
      '   var url = '#39#39';'
      '   var myParams = {username: getCookie("username"),'
      '                              password: getCookie("password")};'
      '    if(id != '#39#39' && id !=undefined && id != null){'
      '        url =  '#39'./index?dwmark:editmodal&id='#39'+id;'
      '    } else {'
      '       url = '#39'./index?dwmark:editmodal'#39';'
      '    }'
      ''
      '   $('#39'#SAVE'#39').attr('#39'idd'#39',id);'
      '   $.getJSON('
      '                     url,'
      '                     myParams,'
      '                     function(j){'
      
        '                                 var mydiv = document.getElement' +
        'ById("dataEmployee");'
      
        '                                 var mydt  = document.getElement' +
        'ById("employeesresut");'
      '                                 $('#39'#employeesresut'#39').hide();'
      '                                 mydt.style.visibility="hidden";'
      '                                      if(j.length > 0){'
      
        '                                       for (var i = 0; i < j.len' +
        'gth; i++) {'
      
        '                                        $("#FIRST_NAME").val(j[i' +
        '].FIRST_NAME);'
      
        '                                        $("#LAST_NAME").val(j[i]' +
        '.LAST_NAME);'
      
        '                                        $("#PHONE_EXT").val(j[i]' +
        '.PHONE_EXT);'
      
        '                                        $("#CAD_HIRE_DATEB").val' +
        '(j[i].HIRE_DATE);'
      
        '                                        $("#JOB_GRADE").val(j[i]' +
        '.JOB_GRADE);'
      
        '                                        $("#JOB_COUNTRY").val(j[' +
        'i].JOB_COUNTRY);'
      
        '                                        $("#SALARY").val(j[i].SA' +
        'LARY);'
      
        '                                        $('#39'.operacao'#39').val('#39'edit' +
        #39');'
      '                                       }'
      
        '                                        mydiv.style.visibility="' +
        'visible";'
      
        '                                        $('#39'#dataEmployee'#39').slide' +
        'Down("slow");'
      '                                      } else {'
      '                                      reloadDatatable(true);'
      '                                      }'
      '          });'
      '  '
      '};'
      ''
      '$('#39'#CANCEL'#39').click(function(){'
      '  reloadDatatable(true);'
      '});'
      ''
      '$('#39'#cancelar'#39').click(function(){'
      '    $('#39'#modal_apagar'#39').modal('#39'hide'#39');'
      '});'
      ''
      'function myActionD(id, name){'
      '      $('#39'#nome_empregado'#39').html(name);'
      '      $('#39'#ok'#39').attr('#39'idd'#39', id);     '
      '      $('#39'#modal_apagar'#39').modal('#39'show'#39');     '
      '};'
      ''
      '$('#39'#ok'#39').click(function(){'
      '     var id = $(this).attr('#39'idd'#39');'
      '     $.ajax('
      '                {'
      '                    type: "post",'
      '                    contentType: false,                    '
      '                    data: {username: getCookie("username"),'
      '                              password: getCookie("password")},'
      
        '                    url: '#39'./index?dwmark:operation&id='#39'+id+'#39'&ope' +
        'ration=delete'#39','
      '                    success: function (data) {'
      '                        if (data) {'
      '                            $('#39'#modal_apagar'#39').modal('#39'hide'#39');'
      '                            reloadDatatable();'
      '                            reloadDatatable(true);'
      '                        } else {'
      
        '                                    swal("Erro...", "N'#227'o foi pos' +
        's'#237'vel excluir o registro", "error");                            '
      '                        }'
      '                    }'
      '     });'
      '});'
      ''
      '$('#39'#SAVE'#39').click(function(){'
      '    var id = $(this).attr('#39'idd'#39');'
      '    var sendInfo = {'
      '                             username: getCookie("username"),'
      '                             password: getCookie("password"),'
      '                             FIRST_NAME: $("#FIRST_NAME").val(),'
      '                             LAST_NAME: $("#LAST_NAME").val(),'
      '                             PHONE_EXT: $("#PHONE_EXT").val(),'
      
        '                             HIRE_DATE: $("#CAD_HIRE_DATEB").val' +
        '(),'
      '                              JOB_GRADE: $("#JOB_GRADE").val(),'
      
        '                              JOB_COUNTRY: $("#JOB_COUNTRY").val' +
        '(),'
      '                              SALARY: $("#SALARY").val(),'
      '                              OPERATION:  $('#39'.operacao'#39').val() '
      '                             };'
      '       $.ajax({'
      '           type: "POST",'
      '           url: '#39'./index?dwmark:operation&id='#39'+id,'
      
        '           contentType: '#39'application/x-www-form-urlencoded; char' +
        'set=UTF-8'#39','
      '           dataType: "json",'
      '           data: sendInfo,'
      '           success: function (msg) {'
      '                    if (msg) {'
      
        '                         if($('#39'.operacao'#39').val('#39'edit'#39') == '#39'edit'#39 +
        '){'
      
        '                           swal("Sucesso", "Empregado editado co' +
        'm sucesso", "warning");                               '
      '                         }else{'
      
        '                           swal("Sucesso", "Cadastro realizado c' +
        'om sucesso", "warning");'
      '                         }'
      '                    reloadDatatable();'
      '                    reloadDatatable(true);'
      '                   }'
      '                 else {'
      
        '                           swal("Erro...", "N'#227'o foi poss'#237'vel fin' +
        'alizar a opera'#231#227'o", "error");'
      '               }'
      #9#9'   }});'
      '});'
      '   '
      '</script>')
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <
      item
        ContextTag = 
          '<main role="main" class="col-md-9 ml-sm-auto col-lg-12 pt-3 px-4' +
          '">'#13#10'        <div class="d-flex justify-content-between flex-wrap' +
          ' flex-md-nowrap align-pessoas-center pb-2 mb-3 border-bottom">'#13#10 +
          '        </div>'#13#10'    </main>'#13#10'    <div class="col-xs-12 col-sm-12' +
          ' col-md-12 col-lg-12">'#13#10'        <div id="data-table_wrapper" cla' +
          'ss="dataTables_wrapper form-inline dt-bootstrap no-footer">'#13#10'   ' +
          '         <table id="my-table"  class="table-striped table-hover ' +
          'bordered display responsive nowrap" style="width:100%"></table>'#13 +
          #10'        </div>'#13#10'    </div>'
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
          'odal_apagar" role="dialog" >'#13#10'    <div class="modal-dialog" role' +
          '="document">'#13#10'    <div class="modal-content">'#13#10'      <div class=' +
          '"modal-header">'#13#10'        <h5 class="modal-title" id="title">Apag' +
          'ar</h5>'#13#10'        <button type="button" class="close" data-dismis' +
          's="modal" aria-label="Close">'#13#10'          <span aria-hidden="true' +
          '">&times;</span>'#13#10'        </button>'#13#10'      </div>'#13#10'      <div cl' +
          'ass="modal-body">'#13#10#9#9'Voc'#234' deseja realmente deletar o empregado <' +
          'spam id="nome_empregado"></spam>'#9' '#13#10'      </div>'#13#10'      <div cla' +
          'ss="modal-footer">        '#13#10'        <button type="button" class=' +
          '"btn btn-success" id="ok">Ok</button>'#13#10#9#9'<button type="button" c' +
          'lass="btn btn-danger"  id="cancelar">Cancelar</button>'#13#10'      </' +
          'div>'#13#10'    </div>'#13#10'  </div>'#13#10'</div>'
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
        TagID = 'dwcbPaises'
        TagReplace = '{%dwcbPaises%}'
        ObjectName = 'dwcbPaises'
        OnBeforeRendererContextItem = dwcrIndexItemsdwcbPaisesBeforeRendererContextItem
      end
      item
        ContextTag = '<select class="form-control" id="JOB_GRADE" name = "JOB_GRADE">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'dwcbCargos'
        TagReplace = '{%dwcbCargos%}'
        ObjectName = 'dwcbCargos'
        OnBeforeRendererContextItem = dwcrIndexItemsdwcbCargosBeforeRendererContextItem
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
      end>
    OnBeforeRenderer = dwcrIndexBeforeRenderer
    Left = 172
    Top = 105
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
      ' var expires = "expires=" + d.toGMTString();'
      
        ' document.cookie = cname + "=" + cvalue + ";" + expires + ";path' +
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
      'function mylogin(){'
      '   var ausername = btoa($("#usr").val());  '
      '   var apassword = btoa($("#pwd").val());  '
      '   var aurl = '#39#39';'
      '   if(ausername != '#39#39' && apassword !='#39#39'){'
      '      aurl =  '#39'./index'#39';'
      '   setCookie("username", ausername, 1);'
      '   setCookie("password", apassword, 1);'
      '   $.ajax('
      '                {'
      '                    type: "post",'
      '                    url: aurl,'
      '                    contentType: false,                    '
      
        '                    data: jQuery.param({username: getCookie("use' +
        'rname"),'
      
        '                                                    password: ge' +
        'tCookie("password")}),'
      
        '                   contentType: '#39'application/x-www-form-urlencod' +
        'ed; charset=UTF-8'#39','
      '                   success: function (data) {'
      
        '                                                            docu' +
        'ment.open();'
      
        '                                                            docu' +
        'ment.write(data);'
      
        '                                                            docu' +
        'ment.close();'
      '                    },'
      '                    error: function(result) {'
      
        '                             swal("Aten'#231#227'o", "N'#227'o foi poss'#237'vel f' +
        'azer login...", "warning");'
      '                    }'
      #9#9#9#9' });'#9
      '    }else'
      '   {'
      
        '    swal("Aten'#231#227'o", "N'#227'o foi poss'#237'vel fazer login...", "warning"' +
        ');'
      '   }'
      '}'
      '$(document).ready(function(){'
      '   $("#usr").val(atob(getCookie("username")));'
      '   $("#pwd").val(atob(getCookie("password")));'
      '   $("#myModal").modal({backdrop: '#39'static'#39','
      
        '                                       keyboard: false  // to pr' +
        'event closing with Esc button (if you want this too)'
      '                                      });'
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
    Left = 176
    Top = 152
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 110
    Top = 16
  end
  object FDTransaction: TFDTransaction
    Connection = sqlLocalDBC
    Left = 81
    Top = 16
  end
  object sqlLocalDBC: TFDConnection
    ConnectionName = 'LocalConfigs'
    Params.Strings = (
      
        'Database=D:\Meus Dados\Projetos\SUGV\SUGV20\Mobile\Database\sugv' +
        'mobile2.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Transaction = FDTransaction
    BeforeConnect = sqlLocalDBCBeforeConnect
    Left = 52
    Top = 16
  end
end
