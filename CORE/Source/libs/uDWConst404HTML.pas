unit uDWConst404HTML;

interface

Uses
 SysUtils;

Const
 c404Header = '<!DOCTYPE html>' +
              '<html>' +
              '<head>' +
              '  <meta charset="utf-8">' +
              '  <meta http-equiv="X-UA-Compatible" content="IE=edge">' +
              '  <title>%s</title>';
 c404CSS    = '  <style type="text/css">' +
              '    html,' +
              '    body {' +
              '      margin: 0;' +
              '      padding: 0;' +
              '      height: 100%;' +
              '    }' +
              '    body {' +
              '      font-family: "Whitney SSm A", "Whitney SSm B", "Helvetica Neue", Helvetica, Arial, Sans-Serif;' +
              '      background-color: #2D72D9;' +
              '      color: #fff;' +
              '      -moz-font-smoothing: antialiased;' +
              '      -webkit-font-smoothing: antialiased;' +
              '    }' +
              '    .error-container {' +
              '      text-align: center;' +
              '      height: 100%;' +
              '    }' +
              '    @media (max-width: 480px) {' +
              '      .error-container {' +
              '        position: relative;' +
              '        top: 50%;' +
              '        height: initial;' +
              '        -webkit-transform: translateY(-50%);' +
              '        -ms-transform: translateY(-50%);' +
              '        transform: translateY(-50%);' +
              '      }' +
              '    }' +
              '    .error-container h1 {' +
              '      margin: 0;' +
              '      font-size: 130px;' +
              '      font-weight: 300;' +
              '    }' +
              '    @media (min-width: 480px) {' +
              '      .error-container h1 {' +
              '        position: relative;' +
              '        top: 50%;' +
              '        -webkit-transform: translateY(-50%);' +
              '        -ms-transform: translateY(-50%);' +
              '        transform: translateY(-50%);' +
              '      }' +
              '    }' +
              '    @media (min-width: 768px) {' +
              '      .error-container h1 {' +
              '        font-size: 220px;' +
              '      }' +
              '    }' +
              '    .return {' +
              '      color: rgba(255, 255, 255, 0.6);' +
              '      font-weight: 400;' +
              '      letter-spacing: -0.04em;' +
              '      margin: 0;' +
              '    }' +
              '    @media (min-width: 480px) {' +
              '      .return {' +
              '        position: absolute;' +
              '        width: 100%;' +
              '        bottom: 30px;' +
              '      }' +
              '    }' +
              '    .return a {' +
              '      padding-bottom: 1px;' +
              '      color: #fff;' +
              '      text-decoration: none;' +
              '      border-bottom: 1px solid rgba(255, 255, 255, 0.6);' +
              '      -webkit-transition: border-color 0.1s ease-in;' +
              '      transition: border-color 0.1s ease-in;' +
              '    }' +
              '    .return a:hover {' +
              '      border-bottom-color: #fff;' +
              '    }' +
              '  </style>' +
              '</head>';
 c404Body   = '<body>' +
              '<div class="error-container">' +
              '  <h1>%s</h1>' +
              '  <p class="return">%s</a></p>' +
              '</div>' +
              '</body>' +
              '</html>';

 Function Get404Error(Title, Body, Footer : String) : String;

implementation

Function Get404Error(Title, Body, Footer : String) : String;
Begin
 If Title = '' Then
  Title := '(404) The address you are looking for does not exist';
 If Body = '' Then
  Body := '404';
 If Footer = '' then
  Footer := 'Take me back to <a href="./">Home REST Dataware';
 Result := Format(c404Header, [Title]) + c404CSS + Format(c404Body, [Body, Footer]);
End;

end.
