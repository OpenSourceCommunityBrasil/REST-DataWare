object ServerMethodDM: TServerMethodDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esUtf8
  OnUserTokenAuth = ServerMethodDataModuleUserTokenAuth
  OnGetToken = ServerMethodDataModuleGetToken
  Height = 365
  Width = 386
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
        Routes = [crGet]
        ContextRules = dwcrIndex
        OnlyPreDefinedParams = False
        IgnoreBaseHeader = False
        NeedAuthorization = False
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        Name = 'main'
        ContextName = 'login'
        Routes = [crPost]
        ContextRules = dwcrMain
        OnlyPreDefinedParams = False
        IgnoreBaseHeader = False
        NeedAuthorization = True
      end>
    BaseContext = 'www'
    RootContext = 'index'
    Left = 136
    Top = 145
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
      'function gettoken() {'
      '   var ausername = $("#email").val();'
      '   var apassword = $("#password").val();'
      '   var acnpj     = $("#cnpj").val();'
      '    if (ausername == null) {'
      '        window.location = "./index";'
      '    } else {'
      ''
      '        $.ajax({'
      '            type: "POST",'
      '            url: "./gettoken",'
      '            beforeSend: function(request) {'
      
        '                request.setRequestHeader("Authorization", "Beare' +
        'r " + btoa(ausername + ":" + acnpj + ":" + apassword));'
      '            },'
      '            success     : function (data) {'
      '                                           var aurl = "./main";'
      
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
      
        '                swal.fire("Aten'#231#227'o", "N'#227'o foi poss'#237'vel fazer log' +
        'in...", "warning");'
      '                return false;'
      '            },'
      '        });'
      '    }'
      '}'
      ''
      'function send() {'
      '    event.preventDefault();'
      '    debugger;'
      '    gettoken();'
      '}')
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <>
    OnBeforeRenderer = dwcrIndexBeforeRenderer
    Left = 276
    Top = 113
  end
  object dwcrMain: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '')
    MasterHtmlTag = '$body'
    IncludeScripts.Strings = (
      '$(document).ready(function() {'
      '                              let url = '#39#39';'
      '                              let opcion = null;'
      '                              let id, nome, fila;'
      '                              //MOSTRAR'
      
        '                              let usuarios = $('#39'#usuarios'#39').Data' +
        'Table({'
      '                                  "ajax": {'
      
        '                                      "url"     : url + '#39'/usuari' +
        'os'#39','
      
        '                                      headers   : {"Authorizatio' +
        'n": "Bearer "  + window.sessionStorage.getItem('#39'token'#39')},'
      '                                      "dataSrc" : ""'
      '                                  },'
      '                                  "columns": [{'
      '                                      "data": "id"'
      '                                  }, {'
      '                                      "data": "nome"'
      '                                  }, {'
      '                                      "data": "email"'
      '                                  }, {'
      
        '                                      "defaultContent": "<div cl' +
        'ass='#39'text-center'#39'><div class='#39'btn-group'#39'><button class='#39'btn btn-' +
        'warning btn-sm btnEditar'#39'>Editar</button><button class='#39'btn btn-' +
        'danger btn-sm btnBorrar'#39'>Excluir</button></div></div>"'
      '                                  }]'
      '                             });'
      '    //CREAR'
      '$("#btnCrear").click(function() {'
      ' opcion = '#39'crear'#39';'
      ' id = null;'
      ' $("#formArticulos").trigger("reset");'
      ' $(".modal-header").css("background-color", "#23272b");'
      ' $(".modal-header").css("color", "white");'
      ' $(".modal-title").text("Crear Art'#237'culo");'
      ' $('#39'#modalCRUD'#39').modal('#39'show'#39');'
      '});'
      ''
      '//EDITAR'
      '$(document).on("click", ".btnEditar", function() {'
      ' opcion = '#39'editar'#39';'
      ' fila = $(this).closest("tr");'
      ' id = parseInt(fila.find('#39'td:eq(0)'#39').text());'
      ' nome = fila.find('#39'td:eq(1)'#39').text();'
      ' email = fila.find('#39'td:eq(2)'#39').text();'
      ' $("#id").val(id);'
      ' $("#nome").val(nome);'
      ' $("#email").val(email);'
      ' $(".modal-header").css("background-color", "#7303c0");'
      ' $(".modal-header").css("color", "white");'
      ' $(".modal-title").text("Editar Art'#237'culo");'
      ' $('#39'#modalCRUD'#39').modal('#39'show'#39');'
      '});'
      ''
      '//deletar'
      '$(document).on("click", ".btnBorrar", function() {'
      ' fila = $(this);'
      ' id = parseInt($(this).closest('#39'tr'#39').find('#39'td:eq(0)'#39').text());'
      ' Swal.fire({title: '#39'Deseja realmente excluir este registro?'#39','
      '            showCancelButton: true,'
      '            confirmButtonText: `Confirmar`,'
      '           }).then((result) => {'
      '                                if (result.isConfirmed) {'
      '                                        $.ajax({'
      
        '                                            url: url + '#39'/usuario' +
        's?id='#39' + id,'
      '                                            method: '#39'DELETE'#39','
      
        '                                            headers   : {"Author' +
        'ization": "Bearer "  + window.sessionStorage.getItem('#39'token'#39')},'
      
        '                                            contentType: '#39'applic' +
        'ation/json'#39','
      
        '                                            success: function(re' +
        'sult) {'
      
        '                                                usuarios.row(fil' +
        'a.parents('#39'tr'#39')).remove().draw();'
      
        '                                                Swal.fire('#39'Regis' +
        'tro Excluido com sucesso!'#39', '#39#39', '#39'success'#39');'
      '                                            },'
      
        '                                            error: function(requ' +
        'est, msg, error) {'
      
        '                                                Swal.fire('#39'aten'#231 +
        #227'o'#39', request.responseText);'
      '                                            }'
      '                                        });'
      '                                 }})'
      '});'
      ''
      '//submit para el CREAR y EDITAR'
      '$('#39'#formArticulos'#39').submit(function(e) {'
      '        e.preventDefault();'
      '        id = $.trim($('#39'#id'#39').val());'
      '        nome = $.trim($('#39'#nome'#39').val());'
      '        email = $.trim($('#39'#email'#39').val());'
      ''
      '        if (opcion == '#39'crear'#39') {'
      '            $.ajax({'
      '                url: url + '#39'/usuarios'#39','
      '                method: '#39'post'#39','
      '                contentType: '#39'application/json'#39','
      
        '                headers   : {"Authorization": "Bearer "  + windo' +
        'w.sessionStorage.getItem('#39'token'#39')},'
      '                data: JSON.stringify({'
      '                    nome: nome,'
      '                    email: email'
      '                }),'
      '                success: function(data) {'
      '                    usuarios.ajax.reload(null, false);'
      '                }'
      '            });'
      '        }'
      '        if (opcion == '#39'editar'#39') {'
      '            console.log("EDITAR");'
      '            $.ajax({'
      '                url: url + '#39'/usuarios?id='#39' + id,'
      '                method: '#39'put'#39','
      
        '                headers   : {"Authorization": "Bearer "  + windo' +
        'w.sessionStorage.getItem('#39'token'#39')},'
      '                contentType: '#39'application/json'#39','
      '                data: JSON.stringify({'
      '                    id: id,'
      '                    nome: nome,'
      '                    email: email'
      '                }),'
      '                success: function(data) {'
      '                    usuarios.ajax.reload(null, false);'
      '                }'
      '            });'
      '        }'
      '        $('#39'#modalCRUD'#39').modal('#39'hide'#39');'
      '    });'
      '});')
    IncludeScriptsHtmlTag = '{%incscripts%}'
    Items = <>
    OnBeforeRenderer = dwcrMainBeforeRenderer
    Left = 248
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
  object seUsuarios: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'usuarios'
        EventName = 'usuarios'
        OnlyPreDefinedParams = False
        OnReplyEventByType = seUsuariosEventsusuariosReplyEventByType
      end
      item
        Routes = [crGet]
        NeedAuthorization = False
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'login'
        EventName = 'login'
        OnlyPreDefinedParams = False
        OnReplyEventByType = seUsuariosEventsloginReplyEventByType
      end>
    Left = 272
    Top = 240
  end
end
