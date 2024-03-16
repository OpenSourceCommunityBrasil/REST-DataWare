unit uRESTDWAbout;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

uses Classes, SysUtils, uRESTDWConsts{$IFDEF RESTDWLAZARUS}, lclversion{$ENDIF};

Type
 TRESTDWAboutInfo = (RESTDWAbout);
 TRESTDWComponent = Class(TComponent)
 Private
  fsAbout : TRESTDWAboutInfo;
  Function GetVersionInfo : String;
 Public
  Property VersionInfo : String Read GetVersionInfo;
 Published
  Property AboutInfo : TRESTDWAboutInfo Read fsAbout Write fsAbout Stored False;
 End;

Type
 TRESTDWOwnedCollection = Class(TOwnedCollection)
 Private
  fsAbout : TRESTDWAboutInfo;
 Published
  Property AboutInfo : TRESTDWAboutInfo Read fsAbout Write fsAbout Stored False;
 End;

Procedure RESTDWAboutDialog;

Implementation

//uses {$IFNDEF RESTDWLAMW}uRESTDWAboutForm{$ENDIF};

{$IFNDEF RESTDWLAZARUS}
Function GetDelphiVersion : String;
Begin
 Result := '';
 {$IFDEF VER140}
  Result := 'Delphi 6';
 {$ENDIF}
 {$IFDEF VER150}
  Result := 'Delphi 7 (and 7.1)';
 {$ENDIF}
 {$IFDEF VER160}
  Result := 'Delphi 8 for .Net';
 {$ENDIF}
 {$IFDEF VER170}
  Result := 'Delphi 2005';
 {$ENDIF}
 {$IFNDEF ver185}
  {$IFDEF ver180} // delphi 2006
  Result := 'Delphi 2006';
  {$ENDIF}
 {$ENDIF}
 {$IFDEF ver185} // delphi 2007
  Result := 'Delphi 2007';
 {$ENDIF}
 {$IFDEF ver190} // Delphi 2007 for .Net
  Result := 'Delphi 2007 for .Net';
 {$ENDIF}
 {$IFDEF ver200} // delphi 2009
  Result := 'Delphi 2009';
 {$ENDIF}
 {$IFDEF ver210} // delphi 2010
  Result := 'Delphi 2010';
 {$ENDIF}
 {$IFDEF ver220} // delphi xe
  Result := 'Delphi XE';
 {$ENDIF}
 {$IFDEF ver230} // delphi xe2
  Result := 'Delphi XE2 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver240} // delphi xe3
  Result := 'Delphi XE3 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver250} // delphi xe4
  Result := 'Delphi XE4 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver260} // delphi xe5
  Result := 'Delphi XE5 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver270} // delphi xe6
  Result := 'Delphi XE6 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver280} // delphi xe7
  Result := 'Delphi XE7 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver290} // delphi xe8
  Result := 'Delphi XE8 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver300} // delphi 10
  Result := 'Delphi 10 Seattle (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver310} // delphi 10.1
  Result := 'Delphi 10.1 Berlin (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver320} // delphi 10.2
  Result := 'Delphi 10.2 Tokyo (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver330} // delphi 10.3
  Result := 'Delphi 10.3 Rio (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver340} // delphi 10.4
  Result := 'Delphi 10.4 Sydney (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver350} // delphi 11
  Result := 'Delphi 11 Alexandria (VCL/FMX)';
 {$ENDIF}
End;
{$ENDIF}

Function TRESTDWComponent.GetVersionInfo : String;
Begin
 Result := Format('%s%s', [RESTDWVersionINFO, RESTDWRelease]);
End;

Procedure RESTDWAboutDialog;
Var
 Msg : String;
 {$IFNDEF RESTDWLAMW}
  {$IFNDEF RESTDWFMX}
//  frm : Tfrm_About;
  {$ENDIF}
 {$ENDIF}
 // funcao para converter compatibilidade
 Function DWStr(const AString: String) : String;
 Begin
  {$IFDEF UNICODE}
   {$IFDEF FPC}
    Result := CP1252ToUTF8(AString);
   {$ELSE}
    Result := String(AString) ;
   {$ENDIF}
  {$ELSE}
   Result := AString
  {$ENDIF}
 End;
Begin
 {$IFDEF NOGUI}
  Msg := {$IFDEF RESTDWLAZARUS}'Lazarus/FPC ' + Format('%d.%d.%d', [lcl_major, lcl_minor, lcl_release]){$ELSE}GetDelphiVersion{$ENDIF}+sLineBreak+
         'Rest Dataware Componentes'+sLineBreak+
         'https://github.com/OpenSourceCommunityBrasil/REST-DataWare' +sLineBreak+sLineBreak+
         'Version : '+ RESTDWVERSAO;
  Msg := DWStr(Msg);
  Writeln( Msg )
 {$ELSE}
   Msg := {$IFDEF FPC}'Lazarus/FPC ' + Format('%d.%d.%d', [lcl_major, lcl_minor, lcl_release]){$ELSE}GetDelphiVersion{$ENDIF}+sLineBreak+
          'Rest Dataware Componentes' +sLineBreak+sLineBreak+
          'https://github.com/OpenSourceCommunityBrasil/REST-DataWare' +sLineBreak+sLineBreak+
          'Version : '+ RESTDWVERSAO;
   Msg := DWStr(Msg);
  {$IFNDEF RESTDWLAMW}
   {$IFNDEF RESTDWFMX}
//    frm := Tfrm_About.Create(nil);
//    {$IFNDEF FPC}
//     {$IF Defined(RESTDWFMX)}
//      frm.lbl_msg.Text := Msg;
//     {$ELSE}
//      frm.lbl_msg.Caption:= Msg;
//     {$IFEND}
//    {$ELSE}
//    frm.lbl_msg.Caption:= Msg;
//    {$ENDIF}
//    frm.ShowModal;
   {$ENDIF}
  {$ENDIF}
 {$ENDIF}
End;


end.

