unit utemplateproglaz;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


Const
 cRESTDWcgiproject = 'program restdwcgisample;' + sLineBreak
                     + sLineBreak
                     +'{$mode objfpc}{$H+}' + sLineBreak
                     + sLineBreak
                     +'Uses' + sLineBreak
                     +'  {$IFDEF UNIX}cthreads,{$ENDIF}fpCGI, unit1, unit2;' + sLineBreak
                     + sLineBreak
                     +'Begin' + sLineBreak
                     +'  Application.CreateForm(Trestdwcgiwebmodule1, restdwcgiwebmodule1);' + sLineBreak
                     +'  Application.Initialize;' + sLineBreak
                     +'  Application.Run;' + sLineBreak
                     +' end.';


implementation

end.

