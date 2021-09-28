object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esANSI
  Left = 606
  Top = 221
  Height = 302
  Width = 390
  object RESTDWPoolerDB1: TRESTDWPoolerDB
    RESTDriver = RESTDWDriverZeos1
    Compression = True
    Encoding = esANSI
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    ParamCreate = True
    Left = 52
    Top = 111
  end
  object ZConnection1: TZConnection
    ControlsCodePage = cGET_ACP
    AutoEncodeStrings = False
    BeforeConnect = ZConnection1BeforeConnect
    Port = 3050
    Protocol = 'firebird-2.5'
    Left = 56
    Top = 16
  end
  object ZQuery1: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 120
    Top = 16
  end
  object RESTDWDriverZeos1: TRESTDWDriverZeos
    CommitRecords = 100
    Connection = ZConnection1
    Left = 56
    Top = 64
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
        OnAuthRequest = dwsCrudServerContextListindexAuthRequest
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'login'
        Routes = [crGet]
        ContextRules = dwcrLogin
      end>
    BaseContext = 'www'
    RootContext = 'login'
    Left = 144
    Top = 105
  end
  object dwcrIndex: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '<!DOCTYPE html>'
      '<!--'
      
        'This is a starter template page. Use this page to start your new' +
        ' project from'
      
        'scratch. This page gets rid of all links and provides the needed' +
        ' markup only.'
      '-->'
      '<html>'
      '<head>'
      '  <meta charset="utf-8">'
      '  <meta http-equiv="X-UA-Compatible" content="IE=edge">'
      '  <title>REST Dataware - CRUD Sample</title>'
      '  <!-- Tell the browser to be responsive to screen width -->'
      
        '  <meta content="width=device-width, initial-scale=1, maximum-sc' +
        'ale=1, user-scalable=no" name="viewport">'
      
        '  <link rel="stylesheet" href="./bower_components/bootstrap/dist' +
        '/css/bootstrap.min.css">'
      '  <link rel="stylesheet" href="./dist/css/adminlte.min.css">'
      
        '  <link rel="stylesheet" href="./dist/css/skins/skin-blue.min.cs' +
        's">'
      
        '  <link rel="stylesheet" href="./bower_components/fontawesome/cs' +
        's/all.css">'
      
        '  <link rel="stylesheet" href="./bower_components/sweetalert/dis' +
        't/sweetalert.css">'
      '  <!-- Font Awesome -->'
      
        '  <link rel="stylesheet" href="./bower_components/font-awesome/c' +
        'ss/font-awesome.min.css">'
      '  <!-- Ionicons -->'
      
        '  <link rel="stylesheet" href="./bower_components/ionicons/css/i' +
        'onicons.min.css">'
      '  <!-- Theme style -->'
      '  <style type="text/css">'
      '   table.dataTable tbody th, table.dataTable tbody td {'
      '   padding: 8px 10px !important;}'
      '  </style>'
      
        '<script src="./bower_components/sweetalert/dist/sweetalert.js"><' +
        '/script>'
      '</head>'
      ''
      '<body class="hold-transition skin-blue sidebar-mini">'
      '<div class="wrapper">'
      ''
      '  <!-- Main Header -->'
      '  <header class="main-header">'
      ''
      '    <!-- Logo -->'
      '    <a href="./index" class="logo">'
      '      <!-- mini logo for sidebar mini 50x50 pixels -->'
      '      <span class="logo-mini"><b>R</b>DW</span>'
      '      <!-- logo for regular state and mobile devices -->'
      '      <span class="logo-lg"><b>Rest</b> Dataware</span>'
      '    </a>'
      ''
      '    <!-- Header Navbar -->'
      '    <nav class="navbar navbar-static-top" role="navigation">'
      '      <!-- Sidebar toggle button-->'
      
        '      <a href="#" class="sidebar-toggle" data-toggle="push-menu"' +
        ' role="button">'
      '        <span class="sr-only">Toggle navigation</span>'
      '      </a>'
      '      <!-- Navbar Right Menu -->'
      ''
      '    </nav>'
      '  </header>'
      '  <!-- Left side column. contains the logo and sidebar -->'
      '  <aside class="main-sidebar">'
      ''
      '    <!-- sidebar: style can be found in sidebar.less -->'
      '    <section class="sidebar">'
      ''
      '      <!-- Sidebar user panel (optional) -->'
      '      <div class="user-panel">'
      '        <div class="pull-left image">'
      
        '          <img src="dist/img/logordw.png" class="img-circle" alt' +
        '="User Image">'
      '        </div>'
      '        <div class="pull-left info">'
      '          <p>Developer</p>'
      '          <!-- Status -->'
      
        '          <a href="#"><i class="fa fa-circle text-success"></i> ' +
        'Online</a>'
      '        </div>'
      '      </div>'
      ''
      ''
      '      <!-- Sidebar Menu -->'
      '      <ul class="sidebar-menu" data-widget="tree">'
      '       {%dwsidemenu%} '
      '      </ul>'
      ''
      '    </section>'
      '    <!-- /.sidebar -->'
      '  </aside>'
      ''
      '  <!-- Content Wrapper. Contains page content -->'
      '  <div class="content-wrapper">'
      '    <!-- Content Header (Page header) -->'
      ''
      ''
      '    <!-- Main content -->'
      '    <section class="content container-fluid">'
      ''
      '      <section class="content container-fluid">'
      ''
      '      <div class="box box-primary">'
      '            <div class="box-header with-border">'
      '              <h3 class="box-title">Lista de empregados</h3>'
      '           '
      ''
      '                <div class="box-tools pull-right">'
      
        '                  <button type="button" class="btn btn-primary b' +
        'tn-sm" data-widget="collapse" data-toggle="modal"><i class="fa f' +
        'a-address-card"> </i> Cadastrar</button>'
      '                </div>  '
      '         </div>'
      ''
      '         <section class="content container-fluid">'
      '         <div class="row">'
      ''
      '          <div class="col-lg-12">'
      '         <p> {%datatable%} </p>'
      '        </div>'
      '          '
      '        </div>  '
      '      </section>'
      '      </div>'
      '      </div>'
      ''
      '    </section>'
      ''
      '    </section>'
      '    <!-- /.content -->'
      '  </div>'
      '  <!-- /.content-wrapper -->'
      ''
      '  <!-- Main Footer -->'
      '  <footer class="main-footer">'
      '    <!-- To the right -->'
      '    <div class="pull-right hidden-xs">'
      '      Wallace Oliveira & Gilberto Rocha'
      '    </div>'
      '    <!-- Default to the left -->'
      
        '    <strong>Copyright &copy; 2018 <a href="#">Rest DataWare</a>.' +
        '</strong> All rights reserved.'
      '  </footer>'
      ''
      '  <!-- Control Sidebar -->'
      '  <aside class="control-sidebar control-sidebar-dark">'
      '    <!-- Create the tabs -->'
      '    <ul class="nav nav-tabs nav-justified control-sidebar-tabs">'
      
        '      <li class="active"><a href="#control-sidebar-home-tab" dat' +
        'a-toggle="tab"><i class="fa fa-home"></i></a></li>'
      
        '      <li><a href="#control-sidebar-settings-tab" data-toggle="t' +
        'ab"><i class="fa fa-gears"></i></a></li>'
      '    </ul>'
      '    <!-- Tab panes -->'
      '    <div class="tab-content">'
      '      <!-- Home tab content -->'
      
        '      <div class="tab-pane active" id="control-sidebar-home-tab"' +
        '>'
      '        <h3 class="control-sidebar-heading">Recent Activity</h3>'
      '        <ul class="control-sidebar-menu">'
      '          <li>'
      '            <a href="javascript:;">'
      
        '              <i class="menu-icon fa fa-birthday-cake bg-red"></' +
        'i>'
      ''
      '              <div class="menu-info">'
      
        '                <h4 class="control-sidebar-subheading">Langdon'#39's' +
        ' Birthday</h4>'
      ''
      '                <p>Will be 23 on April 24th</p>'
      '              </div>'
      '            </a>'
      '          </li>'
      '        </ul>'
      '        <!-- /.control-sidebar-menu -->'
      ''
      '        <h3 class="control-sidebar-heading">Tasks Progress</h3>'
      '        <ul class="control-sidebar-menu">'
      '          <li>'
      '            <a href="javascript:;">'
      '              <h4 class="control-sidebar-subheading">'
      '                Custom Template Design'
      '                <span class="pull-right-container">'
      
        '                    <span class="label label-danger pull-right">' +
        '70%</span>'
      '                  </span>'
      '              </h4>'
      ''
      '              <div class="progress progress-xxs">'
      
        '                <div class="progress-bar progress-bar-danger" st' +
        'yle="width: 70%"></div>'
      '              </div>'
      '            </a>'
      '          </li>'
      '        </ul>'
      '        <!-- /.control-sidebar-menu -->'
      ''
      '      </div>'
      '      <!-- /.tab-pane -->'
      '      <!-- Stats tab content -->'
      
        '      <div class="tab-pane" id="control-sidebar-stats-tab">Stats' +
        ' Tab Content</div>'
      '      <!-- /.tab-pane -->'
      '      <!-- Settings tab content -->'
      '      <div class="tab-pane" id="control-sidebar-settings-tab">'
      '        <form method="post">'
      
        '          <h3 class="control-sidebar-heading">General Settings</' +
        'h3>'
      ''
      '          <div class="form-group">'
      '            <label class="control-sidebar-subheading">'
      '              Report panel usage'
      '              <input type="checkbox" class="pull-right" checked>'
      '            </label>'
      ''
      '            <p>'
      
        '              Some information about this general settings optio' +
        'n'
      '            </p>'
      '          </div>'
      '          <!-- /.form-group -->'
      '        </form>'
      '      </div>'
      '      <!-- /.tab-pane -->'
      '    </div>'
      '  </aside>'
      '  <!-- /.control-sidebar -->'
      '  <!-- Add the sidebar'#39's background. This div must be placed'
      '  immediately after the control sidebar -->'
      '  <div class="control-sidebar-bg"></div>'
      '</div>'
      '{%cadModal%}'
      '{%deleteModal%}'
      '<!-- ./wrapper -->'
      ''
      
        '<script src="./bower_components/jquery/dist/jquery.min.js"></scr' +
        'ipt>'
      
        '<script src="./bower_components/bootstrap/dist/js/bootstrap.min.' +
        'js"></script>'
      '<script src="./dist/js/adminlte.min.js"></script>'
      
        '<script src="./bower_components/sweetalert/dist/sweetalert.js"><' +
        '/script>'
      
        '<script type="text/javascript" language="javascript" src="./bowe' +
        'r_components/datatables.net/js/jquery.datatables.min.js"></scrip' +
        't>'
      
        '<script type="text/javascript" language="javascript" src="./bowe' +
        'r_components/datatables.net-bs/js/datatables.bootstrap.min.js"><' +
        '/script>'
      
        '<script type="text/javascript" language="javascript" src="./bowe' +
        'r_components/datatables.net-bs/js/datatables.responsive.min.js">' +
        '</script>'
      
        '<link rel="stylesheet" type="text/css" href="./bower_components/' +
        'datatables.net-bs/css/datatables.bootstrap.css">'
      
        '<link rel="stylesheet" type="text/css" href="./bower_components/' +
        'datatables.net-bs/css/responsive.datatables.css">'
      ' {%incscripts%}'#9' '
      '</body>'
      '</html>'
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
      ''
      '        $(document).ready(function () {'
      
        '            var datatable = $('#39'#my-table'#39').DataTable({ //dataTab' +
        'le tamb'#233'm funcionar'
      
        '                dom: "Bfrtip", // Use dom: '#39'Blfrtip'#39', para fazer' +
        ' o seletor "por p'#225'gina" aparecer.'
      '                ajax: {'
      '                    url: '#39'./www/index?dwmark:datatable'#39','
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
      '            console.log(datatable);'
      '        });'
      '      '
      '      function reloadDatatable(){'
      '       $('#39'#my-table'#39').DataTable().ajax.reload();'
      '      }'
      ''
      ''
      '      $('#39'.btn-sm'#39').click(function(){'
      '         $("#FIRST_NAME").val('#39#39');'
      '         $("#LAST_NAME").val('#39#39');'
      '         $("#PHONE_EXT").val('#39#39');'
      '         $("#HIRE_DATE").val('#39#39');'
      '         $("#JOB_GRADE").val('#39#39');'
      '         $("#JOB_COUNTRY").val('#39#39');'
      '         $("#SALARY").val('#39#39');'
      '         $('#39'.operacao'#39').val('#39'insert'#39');'
      '         $('#39'#modal_cadastro'#39').modal('#39'show'#39');'
      '      });'
      ' '
      '    $('#39'.close'#39').click(function(){'
      '       $('#39'#modal_cadastro'#39').modal('#39'hide'#39');'
      '    });'
      ''
      'function myActionE(id){'
      '   var url = '#39#39';'
      '   var myParams = {username: getCookie("username"),'
      '                              password: getCookie("password")};'
      '    if(id != '#39#39' && id !=undefined && id != null){'
      '        url =  '#39'./www/index?dwmark:editmodal&id='#39'+id;'
      '    } else {'
      '       url = '#39'./www/index?dwmark:editmodal'#39';'
      '    }'
      ''
      '   $('#39'#SAVE'#39').attr('#39'idd'#39',id);'
      '   $.getJSON('
      '                     url,'
      '                     myParams,'
      '                     function(j){'
      '                                      if(j.length > 0){'
      
        '                                       for (var i = 0; i < j.len' +
        'gth; i++) {'
      
        '                                        $("#FIRST_NAME").val(j[i' +
        '].FIRST_NAME);'
      
        '                                        $("#LAST_NAME").val(j[i]' +
        '.LAST_NAME);'
      
        '                                        $("#PHONE_EXT").val(j[i]' +
        '.PHONE_EXT);'
      
        '                                        $("#HIRE_DATE").val(j[i]' +
        '.HIRE_DATE);'
      
        '                                        $("#JOB_GRADE").val(j[i]' +
        '.JOB_GRADE);'
      
        '                                        $("#JOB_COUNTRY").val(j[' +
        'i].JOB_COUNTRY);'
      
        '                                        $("#SALARY").val(j[i].SA' +
        'LARY);'
      
        '                                        $('#39'.operacao'#39').val('#39'edit' +
        #39');'
      '                                       }'
      
        '                                       $('#39'#modal_cadastro'#39').moda' +
        'l('#39'show'#39');'
      '                                      } else {'
      
        '                                      $('#39'#modal_cadastro'#39').modal' +
        '('#39'hide'#39');'
      '                                      }'
      '          });'
      '  '
      '};'
      ''
      '$('#39'#CANCEL'#39').click(function(){'
      '    $('#39'#modal_cadastro'#39').modal('#39'hide'#39');'
      '});'
      ''
      '$('#39'#cancelar'#39').click(function(){'
      '    $('#39'#modal_apagar'#39').modal('#39'hide'#39');'
      '});'
      ''
      'function myActionD(id, name){'
      '      $('#39'#nome_empregado'#39').html(name);'
      '      $('#39'#ok'#39').attr('#39'idd'#39', id);'
      '     '
      '      $('#39'#modal_apagar'#39').modal('#39'show'#39');'
      '     '
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
      
        '                    url: '#39'./www/index?dwmark:operation&id='#39'+id+'#39 +
        '&operation=delete'#39','
      '                    success: function (data) {'
      '                        if (data) {'
      '                            $('#39'#modal_apagar'#39').modal('#39'hide'#39');'
      '                            reloadDatatable();'
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
      '                             HIRE_DATE: $("#HIRE_DATE").val(),'
      '                              JOB_GRADE: $("#JOB_GRADE").val(),'
      
        '                              JOB_COUNTRY: $("#JOB_COUNTRY").val' +
        '(),'
      '                              SALARY: $("#SALARY").val(),'
      '                              OPERATION:  $('#39'.operacao'#39').val() '
      '                             };'
      '       $.ajax({'
      '           type: "POST",'
      '           url: '#39'./www/index?dwmark:operation&id='#39'+id,'
      
        '           contentType: '#39'application/x-www-form-urlencoded; char' +
        'set=UTF-8'#39','
      '           dataType: "json",'
      '           data: sendInfo,'
      '           success: function (msg) {'
      '               if (msg) {'
      '                    if($('#39'.operacao'#39').val('#39'edit'#39') == '#39'edit'#39'){'
      
        '                      swal("Sucesso", "Empregado editado com suc' +
        'esso", "warning");                               '
      '                    }else{'
      
        '                      swal("Sucesso", "Cadastro realizado com su' +
        'cesso", "warning");'
      '                    }'
      '                    $.ajax({'
      '                         type: "post",'
      '                         url: '#39'./www/index?dwmark:datatable'#39','
      '                         contentType: false,                    '
      '                         data: {username: getCookie("username"),'
      
        '                                   password: getCookie("password' +
        '")},'
      '                        success: function (data) {'
      '                         if(data != '#39#39'){'
      
        '                              $('#39'#modal_cadastro'#39').modal('#39'hide'#39')' +
        ';'
      '                              $('#39'.conteudo'#39').html(data);'
      '                              reloadDatatable();'
      '                         } '
      '                    }'
      '                  });'
      '                }else {'
      
        '                           swal("Erro...", "N'#227'o foi poss'#237'vel fin' +
        'alizar a opera'#231#227'o", "error");'
      '               }'
      '           }'
      '           '
      '       });'
      '});'
      ''
      '</script>'
      '')
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <
      item
        ContextTag = 
          '<main role="main" class="col-md-9 ml-sm-auto col-lg-12 pt-3 px-4' +
          '"><div class="d-flex justify-content-between flex-wrap flex-md-n' +
          'owrap align-pessoas-center pb-2 mb-3 border-bottom"></div></main' +
          '><div class="col-xs-12 col-sm-12 col-md-12 col-lg-12"><div id="d' +
          'ata-table_wrapper" class="dataTables_wrapper form-inline dt-boot' +
          'strap no-footer"><table id="my-table"  class="table-striped tabl' +
          'e-hover bordered display responsive nowrap" style="width:100%"><' +
          '/table></div></div>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'iddatatable'
        TagReplace = '{%datatable%}'
        ObjectName = 'datatable'
        OnRequestExecute = dwcrIndexItemsdatatableRequestExecute
      end
      item
        ContextTag = 
          '<div class="modal fade bd-example-modal-lg" tabindex="-1"  id="m' +
          'odal_cadastro" role="dialog" >'#13#10'    <div class="modal-dialog" ro' +
          'le="document">'#13#10'    <div class="modal-content">'#13#10'      <div clas' +
          's="modal-header">'#13#10'        <h5 class="modal-title" id="title">In' +
          'serir/Editar Empregados</h5>'#13#10'        <button type="button" clas' +
          's="close" data-dismiss="modal" aria-label="Close">'#13#10'          <s' +
          'pan aria-hidden="true">&times;</span>'#13#10'        </button>'#13#10'      ' +
          '</div>'#13#10'      <div class="modal-body">'#13#10#9#9' <div class="row"><inp' +
          'ut type="hidden" name="operacao" class="operacao">'#13#10#9#9#9'<div clas' +
          's="col-lg-8">'#13#10#9#9#9'   <div class="form-group">'#13#10#9#9#9#9'  <label for=' +
          '"FIRST_NAME">Nome</label>'#13#10#9#9#9#9'  <input type="text" class="form-' +
          'control" id="FIRST_NAME" name="FIRST_NAME">'#13#10#9#9#9'   </div>'#13#10#9#9#9'</' +
          'div>'#13#10#9#9#9'<div class="col-lg-4">'#13#10#9#9#9'   <div class="form-group">'#13 +
          #10#9#9#9#9'  <label for="LAST_NAME">Sobre Nome</label>'#13#10#9#9#9#9'  <input t' +
          'ype="text" class="form-control" id="LAST_NAME" name="LAST_NAME">' +
          #13#10#9#9#9'   </div>'#13#10#9#9#9'</div>'#13#10#9#9' </div>'#13#10#9#9' <div class="row">'#13#10#9#9'  ' +
          '  <div class="col-lg-4">'#13#10#9#9#9#9'<div class="form-group">'#13#10#9#9#9#9'  <l' +
          'abel for="HIRE_DATE">Nascimento</label>'#13#10#9#9#9#9'  <input type="date' +
          '" class="form-control" id="HIRE_DATE" name="HIRE_DATE">'#13#10#9#9#9'   <' +
          '/div>'#13#10#9#9#9'</div>'#13#10#9#9#9'<div class="col-lg-4">'#13#10#9#9#9'   <div class="f' +
          'orm-group">'#13#10#9#9#9#9'  <label for="PHONE_EXT">Telefone(DDD)</label>'#13 +
          #10#9#9#9#9'  <input type="text" class="form-control" id="PHONE_EXT" na' +
          'me="PHONE_EXT">'#13#10#9#9#9'   </div>'#13#10#9#9#9'</div>'#13#10#9#9' </div>'#13#10#9#9' <div cla' +
          'ss="row">'#13#10#9#9'    <div class="col-lg-4">'#13#10#9#9#9'   <div class="form-' +
          'group">'#13#10#9#9#9#9'  <label for="JOB_COUNTRY">Pa'#237's/Emprego</label>'#13#10#9#9 +
          #9#9'  {%dwcbPaises%}'#13#10#9#9#9'   </div>'#13#10#9#9#9'</div>'#13#10#9#9#9'<div class="col-' +
          'lg-8">'#13#10#9#9#9'   <div class="form-group">'#13#10#9#9#9#9'  <label for="JOB_GR' +
          'ADE">Cargo</label>'#13#10#9#9#9#9'  {%dwcbCargos%}'#13#10#9#9#9'   </div>'#13#10#9#9#9'</div' +
          '>'#13#10#9#9' </div> '#13#10#9#9' <div class="row">'#13#10#9#9#9'<div class="col-lg-3">'#13#10 +
          #9#9#9'   <div class="form-group">'#13#10#9#9#9#9'  <label for="SALARY">Sal'#225'ri' +
          'o</label>'#13#10#9#9#9#9'  <input type="number" class="form-control" id="S' +
          'ALARY" name="SALARY">'#13#10#9#9#9'   </div>'#13#10#9#9#9'</div>'#13#10#9#9' </div>'#9' '#13#10'   ' +
          '   </div>'#13#10'      <div class="modal-footer">'#13#10'        <button typ' +
          'e="button" class="btn btn-danger"  id="CANCEL">Cancelar</button>' +
          #13#10'        <button type="button" class="btn btn-success" id="SAVE' +
          '">Salvar</button>'#13#10'      </div>'#13#10'    </div>'#13#10'  </div>'#13#10'</div>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'cadmodal'
        TagReplace = '{%cadModal%}'
        ObjectName = 'cadModal'
        OnRequestExecute = dwcrIndexItemscadModalRequestExecute
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule3">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'editmodal'
        TagReplace = '{%editModal%}'
        ObjectName = 'editModal'
        OnRequestExecute = dwcrIndexItemscadModalRequestExecute
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
        OnRequestExecute = dwcrIndexItemscadModalRequestExecute
      end
      item
        ContextTag = '<input {%itemtag%} placeholder="dwcontextrule5">'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'operation'
        TagReplace = '{%dwcontextrule5%}'
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
      end>
    Left = 172
    Top = 105
  end
  object dwcrLogin: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '<head>'
      '<meta charset="utf-8">'
      '<meta http-equiv="X-UA-Compatible" content="IE=edge">'
      
        '<meta name="viewport" content="width=device-width, initial-scale' +
        '=1">'
      '<title>REST Dataware - CRUD Sample</title>'
      
        '<link rel="stylesheet" href="./bower_components/font-awesome/css' +
        '/font-awesome.min.css">'
      
        '<link rel="stylesheet" href="./bower_components/bootstrap/dist/c' +
        'ss/bootstrap.min.css">'
      
        '<link rel="stylesheet" href="./bower_components/sweetalert/dist/' +
        'sweetalert.css">'
      
        '<script src="./bower_components/jquery/dist/jquery.min.js"></scr' +
        'ipt>'
      
        '<script src="./bower_components/bootstrap/dist/js/bootstrap.min.' +
        'js"></script>'
      
        '<script src="./bower_components/sweetalert/dist/sweetalert.js"><' +
        '/script>'
      '<style type="text/css">'
      '  #bg {'
      '    position: fixed; '
      '    top: 0; '
      '    left: 0; '
      #9
      '    /* Preserve aspet ratio */'
      '    min-width: 100%;'
      '    min-height: 100%;'
      '  }'
      #9'.modal-login {'#9#9
      #9#9'color: #636363;'
      #9#9'width: 350px;'
      #9'}'
      #9'.modal-login .modal-content {'
      #9#9'padding: 20px;'
      #9#9'border-radius: 5px;'
      #9#9'border: none;'
      #9'}'
      #9'.modal-login .modal-header {'
      #9#9'border-bottom: none;   '
      '        position: relative;'
      '        justify-content: center;'
      #9'}'
      #9'.modal-login h4 {'
      #9#9'text-align: center;'
      #9#9'font-size: 26px;'
      #9#9'margin: 30px 0 -15px;'
      #9'}'
      #9'.modal-login .form-control:focus {'
      #9#9'border-color: #70c5c0;'
      #9'}'
      #9'.modal-login .form-control, .modal-login .btn {'
      #9#9'min-height: 40px;'
      #9#9'border-radius: 3px; '
      #9'}'
      #9'.modal-login .close {'
      '        position: absolute;'
      #9#9'top: -5px;'
      #9#9'right: -5px;'
      #9'}'#9
      #9'.modal-login .modal-footer {'
      #9#9'background: #ecf0f1;'
      #9#9'border-color: #dee4e7;'
      #9#9'text-align: center;'
      '        justify-content: center;'
      #9#9'margin: 0 -20px -20px;'
      #9#9'border-radius: 5px;'
      #9#9'font-size: 13px;'
      #9'}'
      #9'.modal-login .modal-footer a {'
      #9#9'color: #999;'
      #9'}'#9#9
      #9'.modal-login .avatar {'
      #9#9'position: absolute;'
      #9#9'margin: 0 auto;'
      #9#9'left: 0;'
      #9#9'right: 0;'
      #9#9'top: -70px;'
      #9#9'width: 95px;'
      #9#9'height: 95px;'
      #9#9'border-radius: 50%;'
      #9#9'z-index: 9;'
      #9#9'background: #60c7c1;'
      #9#9'padding: 15px;'
      #9#9'box-shadow: 0px 2px 2px rgba(0, 0, 0, 0.1);'
      #9'}'
      #9'.modal-login .avatar img {'
      #9#9'width: 100%;'
      #9'}'
      #9'.modal-login.modal-dialog {'
      #9#9'margin-top: 80px;'
      #9'}'
      '    .modal-login .btn {'
      '        color: #fff;'
      '        border-radius: 4px;'
      #9#9'background: #60c7c1;'
      #9#9'text-decoration: none;'
      #9#9'transition: all 0.4s;'
      '        line-height: normal;'
      '        border: none;'
      '    }'
      #9'.modal-login .btn:hover, .modal-login .btn:focus {'
      #9#9'background: #45aba6;'
      #9#9'outline: none;'
      #9'}'
      #9'.trigger-btn {'
      #9#9'display: inline-block;'
      #9#9'margin: 100px auto;'
      #9'}'
      '</style>'
      '</head>'
      '<img src="./imgs/login.jpg" id="bg" alt="">'
      '<body class="modal-open">'
      '<!-- Modal HTML -->'
      '<div id="myModal" class="modal fade" style="display: block;">'
      
        #9'<div class="modal-dialog modal-dialog-centered modal-login" rol' +
        'e="document">'
      #9#9'<div class="modal-content">'
      #9#9#9'<div class="modal-header">'
      #9#9#9#9'<div class="avatar">'
      #9#9#9#9#9'<img src="./imgs/avatar.png" alt="Avatar">'
      #9#9#9#9'</div>'#9#9#9#9
      #9#9#9#9'<h4 class="modal-title">Login</h4>'#9
      #9#9#9'</div>'
      #9#9#9'<div class="modal-body">'
      #9#9#9'<div class="form-group">'
      
        #9#9#9#9'<input class="form-control" name="username" placeholder="Use' +
        'rname" required="required" id="usr" type="text">'#9#9
      #9#9#9'</div>'
      #9#9#9'<div class="form-group">'
      
        #9#9#9#9'<input class="form-control" name="password" placeholder="Pas' +
        'sword" required="required" id="pwd" type="password">'#9
      #9#9#9'</div>        '
      #9#9#9'<div class="form-group">'
      '                    {%login%}'
      #9#9#9'</div>'
      #9#9#9'</div>'
      #9#9'</div>'
      #9'</div>'
      '</div>'
      '{%incscripts%}'
      '</body>'
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
      end>
    Left = 176
    Top = 152
  end
end
