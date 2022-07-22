Unit %0:s;

Interface

Uses
  Sysutils,
  Classes,
  Systypes,
  Udwdatamodule,
  Udwmassivebuffer,
  System.Json,
  Udwjsonobject,
  Serverutils,
  Udwconstsdata,
  Urestdwpoolerdb,
  Udwconsts, Urestdwserverevents, Udwabout, Urestdwservercontext;

Type
  T%1:s = class(%2:s)
    Restdwpoolerdb1: Trestdwpoolerdb;
    Dwservercontext1: Tdwservercontext;
    Dwcremployee: Tdwcontextrules;
    Procedure Dwserverevents1eventsservertimereplyevent(Var Params: Tdwparams;
      Var Result: String);
    Procedure Dwserverevents1eventshelloworldreplyevent(Var Params: Tdwparams;
      Var Result: String);
    Procedure Dwservercontext1contextlistopenfilereplyrequeststream(
      Const Params: Tdwparams; Var Contenttype: String;
      Var Result: Tmemorystream; Const Requesttype: Trequesttype);
    Procedure Dwservercontext1contextlistinitreplyrequest(
      Const Params: Tdwparams; Var Contenttype, Result: String;
      Const Requesttype: Trequesttype);
  Private
    { private declarations }
    Vidvenda: Integer;
    Function Consultabanco(Var Params: Tdwparams): String; Overload;
  Public
    { public declarations }
  End;

Var
  %1:s: T%1:s;

Implementation

{%%classgroup 'vcl.controls.tcontrol'}
{$R *.dfm}

Uses Udwjsontools;

Function T%1:s.Consultabanco(Var Params: Tdwparams): String;
Begin

End;

Procedure T%1:s.Dwservercontext1contextlistinitreplyrequest(
  Const Params: Tdwparams; Var Contenttype, Result: String;
  Const Requesttype: Trequesttype);
Begin
  Result := '<!DOCTYPE html> ' +
    '<html>' +
    '  <head>' +
    '    <meta charset="utf-8">' +
    '    <title>My test page</title>' +
    '    <link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>' +
    '  </head>' +
    '  <body>' +
    '    <h1>REST Dataware is cool</h1>' +
    '    <img src="http://www.resteasyobjects.com.br/myimages/LogoDW.png" alt="The REST Dataware logo: Powerfull Web Service.">' +
    '  ' +
    '  ' +
    '    <p>working together to keep the Internet alive and accessible, help us to help you. Be free.</p>' +
    ' ' +
    '    <p><a href="https://github.com/OpenSourceCommunityBrasil/REST-DataWare/">REST Dataware site</a> to learn and help us.</p>' +
    '  </body>' +
    '</html>';
End;

Procedure T%1:s.Dwservercontext1contextlistopenfilereplyrequeststream(
  Const Params: Tdwparams; Var Contenttype: String; Var Result: Tmemorystream;
  Const Requesttype: Trequesttype);
Var
  Vnotfound: Boolean;
  Vfilename: String;
  Vstringstream: Tstringstream;
Begin
  Vnotfound := True;
  Result := Tmemorystream.Create;
  If Params.Itemsstring['filename'] <> Nil Then
  Begin
    Vfilename := '.\www\' + Decodestrings(Params.Itemsstring['filename'].Asstring);
    Vnotfound := Not Fileexists(Vfilename);
    If Not Vnotfound Then
    Begin
      Try
        Result.Loadfromfile(Vfilename);
        Contenttype := Getmimetype(Vfilename);
      Finally
      End;
    End;
  End;
  If Vnotfound Then
  Begin
    Vstringstream := Tstringstream.Create('<!DOCTYPE html> ' +
      '<html>' +
      '  <head>' +
      '    <meta charset="utf-8">' +
      '    <title>My test page</title>' +
      '    <link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>' +
      '  </head>' +
      '  <body>' +
      '    <h1>REST Dataware</h1>' +
      '    <img src="http://www.resteasyobjects.com.br/myimages/LogoDW.png" alt="The REST Dataware logo: Powerfull Web Service.">' +
      '  ' +
      '  ' +
      '    <p>File not Found.</p>' +
      '  </body>' +
      '</html>');
    Try
      Vstringstream.Position := 0;
      Result.Copyfrom(Vstringstream, Vstringstream.Size);
    Finally
      Vstringstream.Free;
    End;
  End;
End;

Procedure T%1:s.Dwserverevents1eventshelloworldreplyevent(
  Var Params: Tdwparams; Var Result: String);
Begin
  Result := Format('{"Message":"%%s"}', [Params.Itemsstring['entrada'].Asstring]);
End;

Procedure T%1:s.Dwserverevents1eventsservertimereplyevent(
  Var Params: Tdwparams; Var Result: String);
Begin
  If Params.Itemsstring['inputdata'].Asstring <> '' Then //servertime
    Params.Itemsstring['result'].Asdatetime := Now
  Else
    Params.Itemsstring['result'].Asdatetime := Now - 1;
  Params.Itemsstring['resultstring'].Asstring := 'testservice';
End;

End.

