{ ************************************************************************* }
{ rdw wizards components }
{ para delphi }
{ }
{ desenvolvido por a. brito }
{ email : comercial@abritolda.com }
{ web : http://www.abritolda.com }
{ }
{ ************************************************************************* }

Unit RDWCGIWizard;

{$I ..\Includes\uRESTDW.inc}
{$I ..\Includes\RDWWIZ.inc}

Interface

Uses
  Windows, Classes, Toolsapi, Dialogs;

Type
  TCGIapplicationwizard = Class(Tnotifierobject, Iotawizard, Iotaprojectwizard,
      Iotarepositorywizard, Iunknown
   {$IF     DEFINED(DELPHI10_3UP)}, IOTARepositoryWizard260
   {$ELSEIF DEFINED(DELPHI10_2UP)}, IOTARepositoryWizard190
   {$ELSEIF DEFINED(DELPHI10_0UP)}, IOTARepositoryWizard160{$IFEND})
  Private
    Funitident: String;
    Fclassname: String;
    Ffilename: String;
    Fprojectname: String;
  Public
    // iotawizard
    Function Getidstring: String;
    Function Getname: String;
    Function Getstate: Twizardstate;

    { iotaprojectwizard }
    Function Getauthor: String;
    Function Getcomment: String;
    Function Getpage: String;
    Function Getglyph: Cardinal;
    Procedure Execute;
    // iotarepositorywizard80
    //160
   {$IFDEF DELPHI10_0UP}
     function GetFrameworkTypes: TArray<string>;
    { Return the platform keys for the platforms this wizard supports }
    function GetPlatforms: TArray<string>;

    property FrameworkTypes: TArray<string> read GetFrameworkTypes;
    property Platforms: TArray<string> read GetPlatforms;
    {$ENDIF}

    //190
    {$IFDEF DELPHI10_2UP}
    function GetSupportedPlatforms: TArray<string>;
    {$ENDIF}

    // 260
    {$IFDEF DELPHI10_3UP}
    function GetGalleryCategories: TArray<IOTAGalleryCategory>;

    { GalleryCategories allow register a wizard under several caregories }
    property GalleryCategories: TArray<IOTAGalleryCategory> read GetGalleryCategories;
    {$ENDIF}

    {$IFDEF DELPHI2007UP}
    Function Getgallerycategory: Iotagallerycategory;
    Function Getpersonality: String;
    {$ENDIF}
    Function Getdesigner: String;

  Protected
  End;

  TCGIprojectcreator = Class(Tnotifierobject, Iotacreator, Iotaprojectcreator,
      Iotaprojectcreator50{$IFDEF DELPHI2006UP}, Iotaprojectcreator80{$ENDIF})
  Private
    Fprojectfile: String;
    Fprojectdirectory: String;
    Funitname: String;
    Fformclass: String;
    Ffilename: String;
  Protected
    // iotacreator
    Function Getcreatortype: String;
    Function Getexisting: Boolean;
    Function Getfilesystem: String;
    Function Getowner: Iotamodule;
    Function Getunnamed: Boolean;

    // iotaprojectcreator
    Function Getfilename: String;
    Function Getoptionfilename: String;
    Function Getshowsource: Boolean;
    Procedure Newdefaultmodule;
    Function Newoptionsource(Const Projectname: String): Iotafile;
    Procedure Newprojectresource(Const Project: Iotaproject);
    Function Newprojectsource(Const Projectname: String): Iotafile;
    // iotaprojectcreator50
    Procedure Newdefaultprojectmodule(Const Project: Iotaproject);
{$IFDEF DELPHI2006UP}
    Function Getprojectpersonality: String;
{$ENDIF}
  Public
    Constructor Create(Projfile, Projectdir, Unitname, Formclass,
      Afilename: String);
  End;

  TCGIfrmwizard = Class(Tnotifierobject, Iotawizard, Iotarepositorywizard,
      Iotaformwizard
{$IFDEF DELPHI2006UP}, Iotaformwizard100{$ENDIF}
{$IFDEF DELPHI2006UP}, Iotarepositorywizard80{$ENDIF}, Iunknown)
  Private
    Funitident: String;
    Fclassname: String;
    Ffilename: String;
  Public
    // iotawizard methods
    Function Getidstring: String;
    Function Getname: String;
    Function Getstate: Twizardstate;
    Procedure Execute;
    // iotarepositorywizard / iotaformwizard methods
    Function Getauthor: String;
    Function Getcomment: String;
    Function Getpage: String;
    // function getglyph: hicon;
    Function Getglyph: Cardinal;

{$IFDEF DELPHI2006UP}
    // 60
    Function Getdesigner: String;
    Property Designer: String Read Getdesigner;
    // 80
    Function Getgallerycategory: Iotagallerycategory;
    Function Getpersonality: String;
    Property Gallerycategory: Iotagallerycategory Read Getgallerycategory;
    Property Personality: String Read Getpersonality;
{$ENDIF}
{$IFDEF DELPHI2006UP}
    Function Isvisible(Project: Iotaproject): Boolean;
{$ENDIF}
  End;

  TCGIunitcreator = Class(Tnotifierobject, Iotacreator, Iotamodulecreator)
  Private
    Funitident, Funitidentframe: String;
    Fclassname: String;
    Ffilename: String;
    Fclassnameframe: String;
    Fismainform: Boolean;
    Fowner: Iotamodule;
  Public
    // iotacreator
    Function Getcreatortype: String;
    Function Getexisting: Boolean;
    Function Getfilesystem: String;
    Function Getowner: Iotamodule;
    Function Getunnamed: Boolean;
    // iotamodulecreator
    Function Getancestorname: String;
    Function Getimplfilename: String;
    Function Getintffilename: String;
    Function Getformname: String;
    Function Getmainform: Boolean;
    Function Getshowform: Boolean;
    Function Getshowsource: Boolean;
    Function Newformfile(Const Formident, Ancestorident: String): Iotafile;
    Function Newimplsource(Const Moduleident, Formident, Ancestorident: String)
      : Iotafile;
    Function Newintfsource(Const Moduleident, Formident, Ancestorident: String)
      : Iotafile;
    Procedure Formcreated(Const Formeditor: Iotaformeditor);
    Constructor Create(Aowner: Iotamodule; Unitident, Unitidentframe, Classname,
      Classnameframe, Afilename: String; Aismainform: Boolean = False);
  End;

  TCGIrdwdatamodule = Class(TNotifierObject, IOTACreator, IOTAModuleCreator)
  Private
    Funitident: String;
    Fclassname: String;
    Ffilename: String;
    Fismainform: Boolean;
    Fowner: Iotamodule;
  Public
    // iotacreator
    Function Getcreatortype: String;
    Function Getexisting: Boolean;
    Function Getfilesystem: String;
    Function Getowner: Iotamodule;
    Function Getunnamed: Boolean;
    // iotamodulecreator
    Function Getancestorname: String;
    Function Getimplfilename: String;
    Function Getintffilename: String;
    Function Getformname: String;
    Function Getmainform: Boolean;
    Function Getshowform: Boolean;
    Function Getshowsource: Boolean;
    Function Newformfile(Const Formident, Ancestorident: String): Iotafile;
    Function Newimplsource(Const Moduleident, Formident, Ancestorident: String)
      : Iotafile;
    Function Newintfsource(Const Moduleident, Formident, Ancestorident: String)
      : Iotafile;
    Procedure Formcreated(Const Formeditor: Iotaformeditor);
    Constructor Createa(Aowner: Iotamodule;
      Unitident, Classname, Afilename: String; Aismainform: Boolean = False);
  End;

  TCGIbasefile = Class(Tinterfacedobject)
  Private
    Fmodulename: String;
    Fformname: String;
    Fancestorname: String;
    Fframename: String;
    Fframeunit: String;
  Public
    Constructor Create(Const Modulename, Formname, Ancestorname, Framename,
      Frameunit: String);
  End;

  TCGIrdwdatamodulefile = Class(TCGIbasefile, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  TCGIrdwdatamoduleformfile = Class(TCGIbasefile, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  TCGIunitfile = Class(TCGIbasefile, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  TCGIformfile = Class(TCGIbasefile, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  TCGIprojectfile = Class(Tnotifierobject, Iotafile)
  Private
    Fprojectname: String;
    Funitname: String;
    Fformclass: String;
  Public
    Function Getsource: String;
    Function Getage: Tdatetime;
    Constructor Create(Projname, Unitname, Formclass: String);
  End;

{$IFDEF DELPHI2006UP}
Var
  Easydelphicategory: Iotagallerycategory = Nil;
{$ENDIF}

var
  sfformclass: string;

Implementation

Uses
  Forms, Sysutils, Designintf, Registry, Shlobj
  {$IFDEF DELPHI10_0UP}
  ,PlatformAPI
  {$ENDIF};

Const
  Sauthor = 'abritolda.com';
  Spage = 'REST Dataware';


  // ------------------------------------------------------------------------------

Function Getcurrentproject: Iotaproject;
Var
  Lservices: Iotamoduleservices;
  Lmodule: Iotamodule;
  Lproject: Iotaproject;
  Lprojectgroup: Iotaprojectgroup;
  Lmultipleprojects: Boolean;
  I: Integer;
Begin
  Result := Nil;
  Lmultipleprojects := False;
  Lservices := Borlandideservices As Iotamoduleservices;
  For I := 0 To Lservices.Modulecount - 1 Do
  Begin
    Lmodule := Lservices.Modules[I];
    If Lmodule.Queryinterface(Iotaprojectgroup, Lprojectgroup) = S_ok Then
    Begin
      Result := Lprojectgroup.Activeproject;
      Exit;
    End
    Else If Lmodule.Queryinterface(Iotaproject, Lproject) = S_ok Then
    Begin
      If Result = Nil Then
        Result := Lproject
      Else
      Begin
        Lmultipleprojects := True;
      End;
    End;
  End;
  If Lmultipleprojects Then
    Result := Nil;
End;

// ------------------------------------------------------------------------------

Function Includetrailingpathdelim(Const Aspath: String): String;
Begin
  Result := Aspath;
  If Length(Result) > 0 Then
  Begin
    If Result[Length(Result)] <> Pathdelim Then
    Begin
      Result := Result + Pathdelim;
    End;
  End;
End;

// ------------------------------------------------------------------------------

Function Getmydocuments: String;
Var
  R: Bool;
  Path: Array[0..Max_path] Of Char;
Begin
  R := Shgetspecialfolderpath(0, Path, Csidl_personal, False);
  If Not R Then
    Raise Exception.Create('Could not find MyDocuments folder location.');
  Result := Path;
End;

Function GetDelphiGlobalKey : String;
Begin
 Result := '';
 {$IF DEFINED(DELPHI11UP)} // delphi 11 Alexandria
  Result := '\Software\Embarcadero\BDS\22.0\Globals';
 {$ELSEIF DEFINED(DELPHI10_4UP)} // delphi 10.4 Sydney
  Result := '\Software\Embarcadero\BDS\21.0\Globals';
 {$ELSEIF DEFINED(DELPHI10_3UP)} // delphi 10.3 Rio
  Result := '\Software\Embarcadero\BDS\20.0\Globals';
 {$ELSEIF DEFINED(DELPHI10_2UP)} // delphi 10.2 Tokyo
  Result := '\Software\Embarcadero\BDS\19.0\Globals';
 {$ELSEIF DEFINED(DELPHI10_1UP)} // delphi 10.1 Berlin
  Result := '\Software\Embarcadero\BDS\18.0\Globals';
 {$ELSEIF DEFINED(DELPHI10_0UP)} // delphi 10 Seattle
  Result := '\Software\Embarcadero\BDS\17.0\Globals';
 {$ELSEIF DEFINED(DELPHIXE8UP)} // delphi xe8
  Result := '\Software\Embarcadero\BDS\16.0\Globals';
 {$ELSEIF DEFINED(DELPHIXE7UP)} // delphi xe7
  Result := '\Software\Embarcadero\BDS\15.0\Globals';
 {$ELSEIF DEFINED(DELPHIXE6UP)} // delphi xe6
  Result := '\Software\Embarcadero\BDS\14.0\Globals';
 {$ELSEIF DEFINED(DELPHIXE5UP)} // delphi xe5
  Result := '\Software\Embarcadero\BDS\12.0\Globals';
 {$ELSEIF DEFINED(DELPHIXE4UP)} // delphi xe4
  Result := '\Software\Embarcadero\BDS\11.0\Globals';
 {$ELSEIF DEFINED(DELPHIXE3UP)} // delphi xe3
  Result := '\Software\Embarcadero\BDS\10.0\Globals';
 {$ELSEIF DEFINED(DELPHIXE2UP)} // delphi xe2
  Result := '\Software\Embarcadero\BDS\9.0\Globals';
 {$ELSEIF DEFINED(DELPHIXEUP)} // delphi xe
  Result := '\Software\Embarcadero\BDS\8.0\Globals';
 {$ELSEIF DEFINED(DELPHI2010UP)} // delphi 2010
  Result := '\Software\CodeGear\BDS\7.0\Globals';
 {$ELSEIF DEFINED(DELPHI2009UP)} // delphi 2009
  Result := '\Software\CodeGear\BDS\6.0\Globals';
 {$ELSEIF DEFINED(DELPHI2007UP)} // delphi 2007
  Result := '\Software\Borland\BDS\5.0\Globals';
 {$ELSEIF DEFINED(DELPHI2006UP)} // delphi 2006
  Result := '\Software\Borland\BDS\4.0\Globals';
 {$IFEND}
End;

Function Getideprojectpath: String;
Var
  Lpath: String;
 r : Tregistry;
Begin
 r := Tregistry.Create;
 Try
  r.Rootkey := Hkey_current_user;
  {$IFNDEF DELPHI2006UP}
   Lpath := Extractfiledir(Paramstr(0));
   If Pos('BIN', Uppercase(Lpath)) > 0 Then
    Delete(Lpath, Pos('BIN', Uppercase(Lpath)), 3);
   Lpath := Includetrailingpathdelim(Lpath) + 'Projects' + Pathdelim;
   Result := Lpath;
  {$ENDIF}
  If r.Openkey(GetDelphiGlobalKey, False) Then
   Begin
    Lpath := r.Readstring('DefaultProjectsDirectory');
    r.Closekey;
    If Lpath = '' Then
     Begin
      Lpath := Getmydocuments;
      {$IFNDEF DELPHI2007UP}
       Lpath := Includetrailingpathdelim(Lpath) + 'Borland Studio Projects' + Pathdelim;
      {$ENDIF}
      {$IFDEF DELPHI2007UP}
        Lpath := Includetrailingpathdelim(Lpath) + 'RAD Studio\Projects' + Pathdelim;
      {$ENDIF}
      If Not Directoryexists(Lpath) Then
       Forcedirectories(Lpath);
     End
    Else
     Lpath := Includetrailingpathdelim(Lpath);
    Result := Lpath;
   End;
 Finally
  r.Free;
 End;
End;

Function Makefilename(Const Projectdirectory,
  Abasefilename: String;
  Const Aext: String): String;
Begin
  If Aext <> '' Then
  Begin
    Result := Projectdirectory + Abasefilename +
      '.' + Aext;
  End
  Else
  Begin
    Result := Projectdirectory + Abasefilename;
  End;
End;

// ------------------------------------------------------------------------------

Function Getactiveprojectgroup: Iotaprojectgroup;
Var
  Moduleservices: Iotamoduleservices;
  I: Integer;
Begin
  Result := Nil;
  If Assigned(Borlandideservices) Then
  Begin
    Moduleservices :=
      Borlandideservices As Iotamoduleservices;
    For I := 0 To Moduleservices.
      Modulecount - 1 Do
      If Supports(Moduleservices.Modules[I],
        Iotaprojectgroup, Result) Then
        Break;
  End;
End;

// ------------------------------------------------------------------------------

Function Projectexists(Const Aprojectgroup
  : Iotaprojectgroup; Aproject: String): Boolean;
Var
  A: Integer;
Begin
  Result := False;

  For A := 0 To Aprojectgroup.Projectcount - 1 Do
  Begin
    If Uppercase
      (Changefileext
      (Extractfilename(Aprojectgroup.Projects[A]
      .Filename), '')) = Uppercase(Aproject) Then
    Begin
      Result := True;
      Exit;
    End;
  End;
End;

// ------------------------------------------------------------------------------

Function Findnewprojectname(Const Aprojectgroup
  : Iotaprojectgroup): String;
Var
  A: Integer;
Begin
  A := 1;
  If Assigned(Aprojectgroup) Then
  Begin
    While Projectexists(Aprojectgroup,
      Format('Project%d', [A])) Do
      Inc(A);
  End;
  Result := Format('Project%d', [A]);
End;

// ------------------------------------------------------------------------------

{ TCGIbasefile }

Constructor TCGIbasefile.Create(Const Modulename,
  Formname, Ancestorname, Framename,
  Frameunit: String);
Begin
  Inherited Create;
  Fmodulename := Modulename;
  Fformname := Formname;
  Fancestorname := Ancestorname;
  Fframename := Framename;
  Fframeunit := Frameunit;
End;

// ------------------------------------------------------------------------------

{ TCGIunitfile }

Function TCGIunitfile.Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWCGISRVUNIT';
  Resinstance := Findresourcehinstance(Hinstance);
  Hres := Findresourcea(Resinstance,
    Pansichar(Resname), Pansichar(10));
  Text := Pansichar
    (Lockresource
    (Loadresource(Resinstance, Hres)));
  Setlength(Text,
    Sizeofresource(Resinstance, Hres));
  Result := Format(String(Text),
    [Fmodulename, Fformname, Fancestorname,
    Fframename, Fframeunit]);
End;

// ------------------------------------------------------------------------------

Function TCGIunitfile.Getage: Tdatetime;
Begin
  Result := -1;
End;

// ------------------------------------------------------------------------------

{ TCGIformfile }

Function TCGIformfile.Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWCGISRVFRM';
  Resinstance := Findresourcehinstance(Hinstance);
  Hres := Findresourcea(Resinstance,
    Pansichar(Resname), Pansichar(10));
  Text := Pansichar
    (Lockresource
    (Loadresource(Resinstance, Hres)));
  Setlength(Text,
    Sizeofresource(Resinstance, Hres));
  Result := Format(String(Text),
    [Fformname, Fframename]);
End;

// ------------------------------------------------------------------------------

Function TCGIformfile.Getage: Tdatetime;
Begin
  Result := -1;
End;

// ------------------------------------------------------------------------------

{ TCGIfrmwizard }
{ TCGIfrmwizard.iotawizard }

Function TCGIfrmwizard.Getidstring: String;
Begin
  Result := 'RDW.RestDatawareCGIServerForm';
End;

// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getname: String;
Begin
  Result := 'REST Dataware - CGI Server Form';
End;

// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getstate: Twizardstate;
Begin
  Result := [Wsenabled];
End;

// ------------------------------------------------------------------------------

Procedure TCGIfrmwizard.Execute;
Var
  Lproj: Iotaproject;
  Frameclassname, Frameunitname: String;
Begin
{$IFDEF DELPHI2006UP}
  (Borlandideservices As Iotamoduleservices).Getnewmoduleandclassname('', Funitident,
    Fclassname, Ffilename);
  Fclassname := 'RDWCGIForm' + Copy(Funitident, 5, Length(Funitident));
{$ELSE}
  (Borlandideservices As Iotamoduleservices).Getnewmoduleandclassname('RDWCGIForm',
    Funitident, Fclassname, Ffilename);
{$ENDIF}
  // (borlandideservices as iotamoduleservices).createmodule(self);
  Lproj := Getcurrentproject;
  If Lproj <> Nil Then
  Begin
    (Borlandideservices As Iotamoduleservices).Createmodule
      (TCGIrdwdatamodule.Createa(Lproj, Funitident, Fclassname, Ffilename));
  End;

  Frameclassname := Fclassname;
  Frameunitname := Funitident;

{$IFDEF DELPHI2006UP}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('', Funitident,
    Fclassname, Ffilename);
  Fclassname := 'RDWCGIForm' +
    Copy(Funitident, 5, Length(Funitident));
{$ELSE}
  (Borlandideservices As Iotamoduleservices).Getnewmoduleandclassname('RDWCGIForm',
    Funitident, Fclassname, Ffilename);
{$ENDIF}
  // (borlandideservices as iotamoduleservices).createmodule(self);
  Lproj := Getcurrentproject;
  If Lproj <> Nil Then
  Begin
    (Borlandideservices As Iotamoduleservices).Createmodule(TCGIunitcreator.Create(Lproj,
      Funitident, Frameunitname, Fclassname, Frameclassname, Ffilename));
  End;
End;

// ------------------------------------------------------------------------------

{$IFDEF DELPHI2006UP}
{ TCGIfrmwizard.iotarepositorywizard / TCGIfrmwizard.iotaformwizard }

Function TCGIfrmwizard.Getgallerycategory
  : Iotagallerycategory;
Begin
  Result := Nil;

End;

// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getpersonality: String;
Begin
  Result := Sdelphipersonality;
End;

// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getdesigner: String;
Begin
  Result := Dvcl;
End;
{$ENDIF}
// ------------------------------------------------------------------------------
{$IFDEF DELPHI2006UP}

Function TCGIfrmwizard.Isvisible(Project: Iotaproject): Boolean;
Begin
  Result := True;
End;
{$ENDIF}
// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getglyph: Cardinal;
Begin
  Result := 0; // use standard icon
End;

// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getpage: String;
Begin
  Result := Spage;
End;

// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getauthor: String;
Begin
  Result := Sauthor;
End;

// ------------------------------------------------------------------------------

Function TCGIfrmwizard.Getcomment: String;
Begin
  Result := 'Cria um novo Servidor CGI RestdataWare.'
End;

// ------------------------------------------------------------------------------
{
  function TCGIfrmwizard.GetOwner: IOTAModule;
  var
  I: Integer;
  ModServ: IOTAModuleServices;
  Module: IOTAModule;
  ProjGrp: IOTAProjectGroup;
  begin
  Result := nil;
  ModServ := BorlandIDEServices as IOTAModuleServices;
  for I := 0 to ModServ.ModuleCount - 1 do
  begin
  Module := ModSErv.Modules[I];
  // find current project group
  if CompareText(ExtractFileExt(Module.FileName), '.bpg') = 0 then
  if Module.QueryInterface(IOTAProjectGroup, ProjGrp) = S_OK then
  begin
  // return active project of group
  Result := ProjGrp.GetActiveProject;
  Exit;
  end;
  end;
  end;

  //------------------------------------------------------------------------------

  function TCGIfrmwizard.GetImplFileName: string;
  var
  CurrDir: array[0..MAX_PATH] of char;
  begin
  // Note: full path name required!
  GetCurrentDirectory(SizeOf(CurrDir), CurrDir);
  Result := Format('%s\%s.pas', [CurrDir, FUnitIdent, '.pas']);
  end;
}
// ------------------------------------------------------------------------------

{ TCGIunitcreator }

Constructor TCGIunitcreator.Create
  (Aowner: Iotamodule;
  Unitident, Unitidentframe, Classname,
  Classnameframe, Afilename: String;
  Aismainform: Boolean);
Begin
  Funitident := Unitident;
  Fclassname := Classname;
  Fclassnameframe := Classnameframe;
  Funitidentframe := Unitidentframe;
  Ffilename := Afilename;
  Inherited Create;
  Fowner := Aowner;
  Fismainform := Aismainform;
End;

// ------------------------------------------------------------------------------

Procedure TCGIunitcreator.Formcreated
  (Const Formeditor: Iotaformeditor);
Begin
  //
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getancestorname: String;
Begin
  Result := 'TWebModule'; // 'tform';
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getcreatortype: String;
Begin
  Result := Sform;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getexisting: Boolean;
Begin
  Result := False;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getfilesystem: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getformname: String;
Begin
  Result := Fclassname;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getimplfilename: String;
Var
  // currdir: array[0..max_path] of char;
  Projectdir: String;
Begin
  // note: full path name required!
  { getcurrentdirectory(sizeof(currdir), currdir);
    Result := Format('%s\%s.pas', [CurrDir, FUnitIdent, '.pas']);
  }

  Projectdir := Getideprojectpath;
  Projectdir := Includetrailingpathdelim(Projectdir);

{$IFDEF DELPHI2005UP}
  If Not Fismainform Then
  Begin
    // result := projectoptions.formfile;

    // result := ffilename;
  End
  Else
  Begin
    Result := Makefilename(Projectdir,
      Funitident, 'pas');
  End;
{$ELSE}
  Result := Makefilename(Projectdir,
    Funitident, 'pas');
{$ENDIF}
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getintffilename: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getmainform: Boolean;
Begin
  Result := Fismainform;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getowner: Iotamodule;
Begin
  Result := Fowner;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getshowform: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getshowsource: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Getunnamed: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Newformfile
  (Const Formident, Ancestorident: String)
  : Iotafile;
Begin
  Result := TCGIformfile.Create('', Formident,
    Ancestorident, Fclassnameframe,
    Funitidentframe);
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Newimplsource
  (Const Moduleident, Formident,
  Ancestorident: String): Iotafile;
Begin
  Result := TCGIunitfile.Create(Moduleident,
    Formident, Ancestorident, Fclassnameframe,
    Funitidentframe);
End;

// ------------------------------------------------------------------------------

Function TCGIunitcreator.Newintfsource
  (Const Moduleident, Formident,
  Ancestorident: String): Iotafile;
Begin
  Result := Nil;
End;

// ------------------------------------------------------------------------------

{ TCGIapplicationwizard }

Procedure TCGIapplicationwizard.Execute;
Var
  // lproj : iotaproject;
  Lmoduleservices: Iotamoduleservices;
  Projectdir: String;
Begin
  Lmoduleservices :=
    (Borlandideservices As Iotamoduleservices);
  Fprojectname :=
    Findnewprojectname(Getactiveprojectgroup);
  Projectdir := Getideprojectpath;
  Projectdir := Includetrailingpathdelim(Projectdir);

{$IFDEF DELPHI2006UP}
  Lmoduleservices.Getnewmoduleandclassname('',
    Funitident, Fclassname, Ffilename);
  Fclassname := 'RDWCGIDatam' +
    Copy(Funitident, 5, Length(Funitident));
{$ELSE}
  Lmoduleservices.Getnewmoduleandclassname('RDWunitDM', Funitident, Fclassname,
    Ffilename);
    Fclassname := 'RDWCGIDatam' +
    Copy(Funitident, 10, Length(Funitident));
{$ENDIF}
  Lmoduleservices.Createmodule(TCGIprojectcreator.Create(Fprojectname,
    Projectdir, Funitident, Fclassname, Ffilename));
End;

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.Getauthor: String;
Begin
  Result := Sauthor;
End;

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.Getcomment: String;
Begin
  Result := 'REST Dataware - CGI Application';
End;

// ------------------------------------------------------------------------------


{$IFDEF DELPHI2007UP}
Function TCGIapplicationwizard.Getgallerycategory
  : Iotagallerycategory;
Begin
  Result := Nil;
End;
{$ENDIF}

// ------------------------------------------------------------------------------

{$IFDEF DELPHI2007UP}
Function TCGIapplicationwizard.
  Getpersonality: String;
Begin
  Result := Sdelphipersonality;
End;
{$ENDIF}

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.
  Getdesigner: String;
Begin
  Result := Dvcl;
End;

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.Getglyph: Cardinal;
Begin
  Result := 0;
End;

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.
  Getidstring: String;
Begin
  Result := 'RDW.CGIRestdatawareApplicationWizard';
End;

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.Getname: String;
Begin
  Result := 'REST Dataware - CGI Server application';
End;

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.Getpage: String;
Begin
  Result := Spage;
End;

// ------------------------------------------------------------------------------

Function TCGIapplicationwizard.Getstate
  : Twizardstate;
Begin
  Result := [Wsenabled];
End;

{$IFDEF DELPHI10_0UP}
function TCGIapplicationwizard.GetFrameworkTypes: TArray<string>;
begin
  SetLength(Result, 2);
  Result[0] := sFrameworkTypeVCL;
  Result[1] := sFrameworkTypeFMX;
end;


{ Return the platform keys for the platforms this wizard supports }
function TCGIapplicationwizard.GetPlatforms: TArray<string>;
begin
  SetLength(Result, 4);
  Result[0] := cWin32Platform;
  Result[1] := cWin64Platform;
  Result[2] := cLinux64Platform;
  Result[3] := ciOSDevice64Platform;
//  Result[3] := cAndroidArm32Platform;
//  Result[4] := cAndroidArm64Platform;
//  Result[5] := cOSX64Platform;
//  Result[6] := ciOSSimulator64Platform;
end;
{$ENDIF}

{$IFDEF DELPHI10_2UP}
function TCGIapplicationwizard.GetSupportedPlatforms: TArray<string>;
begin
  SetLength(Result, 6);
  Result[0] := cWin32Platform;
  Result[1] := cWin64Platform;
  Result[2] := cLinux64Platform;
  Result[3] := cOSX64Platform;
  Result[4] := ciOSSimulator64Platform;
  Result[5] := ciOSDevice64Platform;
//  Result[3] := cAndroidArm32Platform;
//  Result[4] := cAndroidArm64Platform;
end;
{$ENDIF}

{$IFDEF DELPHI10_3UP}
function TCGIapplicationwizard.GetGalleryCategories: TArray<IOTAGalleryCategory>;
begin
  Result:=nil;
end;
{$ENDIF}

// ------------------------------------------------------------------------------

{ TCGIprojectcreator }

Constructor TCGIprojectcreator.Create(Projfile,
  Projectdir, Unitname, Formclass,
  Afilename: String);
Begin
  Inherited Create;
  Fprojectfile := Projfile;
  Fprojectdirectory := Projectdir;
  Funitname := Unitname;
  Fformclass := Formclass;
  Ffilename := Afilename;
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Getcreatortype: String;
Begin
  Result := Sapplication;
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Getexisting: Boolean;
Begin
  Result := False;
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Getfilename: String;
Begin
  Result := Fprojectdirectory +
    Fprojectfile + '.dpr';
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Getfilesystem: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.
  Getoptionfilename: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Getowner: Iotamodule;
Begin
  Result := Nil;
End;

// ------------------------------------------------------------------------------

{$IFDEF DELPHI2006UP}
Function TCGIprojectcreator.Getprojectpersonality: String;
Begin
  Result := Sdelphipersonality;
End;
{$ENDIF}
// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Getshowsource
  : Boolean;
Begin
  Result := True; // not fisbcb;
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Getunnamed: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Procedure TCGIprojectcreator.Newdefaultmodule;
Begin
  //
End;

// ------------------------------------------------------------------------------

Procedure TCGIprojectcreator.Newdefaultprojectmodule(Const Project
  : Iotaproject);
Var
  Lmoduleservices: Iotamoduleservices;
  Frameclassname, Frameunitname: String;
  Lproj: Iotaproject;
Begin
  Lmoduleservices :=(Borlandideservices As Iotamoduleservices);
  Lmoduleservices.Createmodule(TCGIrdwdatamodule.Createa(Project, Funitname,
    Fformclass, Ffilename, True));

  Frameclassname := Fformclass;
  Frameunitname := Funitname;

{$IFDEF DELPHI2006UP}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('', Funitname,
    Fformclass, Ffilename);
  Fformclass := 'RDWCGIFormSrv' +
    Copy(Funitname, 5, Length(Funitname));
{$ELSE}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('RDWDmUnSrv',
    Funitname, Fformclass, Ffilename);
    Fformclass := 'RDWCGIFormSrv' +
    Copy(Funitname, 11, Length(Funitname));
{$ENDIF}
  // (borlandideservices as iotamoduleservices).createmodule(self);
  Lproj := Getcurrentproject;
  If Lproj <> Nil Then
  Begin
    (Borlandideservices As Iotamoduleservices).Createmodule(TCGIunitcreator.Create(Lproj,
      Funitname, Frameunitname, Fformclass, Frameclassname, Ffilename));
  End;
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Newoptionsource
  (Const Projectname: String): Iotafile;
Begin
  Result := Nil;
End;

// ------------------------------------------------------------------------------

Procedure TCGIprojectcreator.Newprojectresource
  (Const Project: Iotaproject);
Begin
  //
End;

// ------------------------------------------------------------------------------

Function TCGIprojectcreator.Newprojectsource
  (Const Projectname: String): Iotafile;
Begin
  Result := TCGIprojectfile.Create(Projectname,
    Funitname, Fformclass);
End;

// ------------------------------------------------------------------------------

{ TCGIprojectfile }

Constructor TCGIprojectfile.Create(Projname,
  Unitname, Formclass: String);
Begin
  Inherited Create;
  Fprojectname := Projname;
  Funitname := Unitname;
  Fformclass := Formclass;
End;

// ------------------------------------------------------------------------------

Function TCGIprojectfile.Getage: Tdatetime;
Begin
  Result := -1;
End;

// ------------------------------------------------------------------------------

Function TCGIprojectfile.Getsource: String;
Begin
  if Pos('RDWCGIDA', uppercase(Fformclass)) > 0 then
  begin
     sfformclass := Fformclass;
  end;
  Result := 'program ' + Fprojectname + ';' +
    #13#10 +'{$APPTYPE CONSOLE}' +#13#10 +
{$IFDEF DELPHI2006UP}
  'uses WebBroker, CGIApp;' + #13#10 +
{$ELSE}
  'uses WebBroker, CGIApp,' + #13#10 + ' ' + Funitname +
    ' in ''' + Funitname + '.pas'' {' + Fformclass
    + '};' + #13#10 +
{$ENDIF}
  '{$R *.res}' + #13#10 + #13#10 + 'begin' +
    #13#10 + '  Application.Initialize;'
    + #13#10 +
    '  Application.WebModuleClass := WebModuleClass;' + #13#10
    + #13#10 +
{$IFDEF DELPHI2006UP}
{$ELSE}
  // '  application.createform(t'+fformclass+', '+fformclass+');' + #13#10 +
{$ENDIF}
  '  Application.Run;' + #13#10 + 'end.';




End;

// ------------------------------------------------------------------------------

{ TCGIrdwdatamodulefile }

Function TCGIrdwdatamodulefile.Getage: Tdatetime;
Begin
  Result := -1;
End;

Function TCGIrdwdatamodulefile. Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWCGIDATAMUNIT';
  Resinstance := Findresourcehinstance(Hinstance);
  Hres := Findresourcea(Resinstance,
    Pansichar(Resname), Pansichar(10));
  Text := Pansichar(Lockresource(Loadresource(Resinstance, Hres)));
  Setlength(Text, Sizeofresource(Resinstance, Hres));
  Result := Format(String(Text), [Fmodulename, Fformname, Fancestorname]);
End;

{ TCGIrdwdatamoduleformfile }

Function TCGIrdwdatamoduleformfile.Getage: Tdatetime;
Begin
  Result := -1;
End;

Function TCGIrdwdatamoduleformfile.Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWCGIDATAMFRM';
  Resinstance := Findresourcehinstance(Hinstance);
  Hres := Findresourcea(Resinstance,
    Pansichar(Resname), Pansichar(10));
  Text := Pansichar
    (Lockresource
    (Loadresource(Resinstance, Hres)));
  Setlength(Text,
    Sizeofresource(Resinstance, Hres));
  Result := Format(String(Text), [Fformname]);
End;

{ TCGIrdwdatamodule }

Constructor TCGIrdwdatamodule.Createa(Aowner: Iotamodule;
  Unitident, Classname, Afilename: String; Aismainform: Boolean);
Begin
  Funitident := Unitident;
  Fclassname := Classname;
  Ffilename := Afilename;
  Inherited Create;
  Fowner := Aowner;
  Fismainform := Aismainform;
End;

// ------------------------------------------------------------------------------

Procedure TCGIrdwdatamodule.Formcreated
  (Const Formeditor: Iotaformeditor);
Begin
  //
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getancestorname: String;
Begin
  Result := 'TServerMethodDataModule'; // 'tform';
End;


// ------------------------------------------------------------------------------


Function TCGIrdwdatamodule.Getcreatortype: String;
Begin
  Result := Sform;
End;


// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getexisting: Boolean;
Begin
  Result := False;
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getfilesystem: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getformname: String;
Begin
  Result := Fclassname;
End;

// ------------------------------------------------------------------------------


Function TCGIrdwdatamodule.Getimplfilename: String;
Var
  // currdir: array[0..max_path] of char;
  Projectdir: String;
Begin
  // note: full path name required!
  { getcurrentdirectory(sizeof(currdir), currdir);
    Result := Format('%s\%s.pas', [CurrDir, FUnitIdent, '.pas']);
  }

  Projectdir := Getideprojectpath;
  Projectdir := Includetrailingpathdelim(Projectdir);

{$IFDEF DELPHI2005UP}
  If Not Fismainform Then
  Begin
    // result := projectoptions.formfile;

    // result := ffilename;
  End
  Else
  Begin
    Result := Makefilename(Projectdir, Funitident, 'pas');
  End;
{$ELSE}
  Result := Makefilename(Projectdir, Funitident, 'pas');
{$ENDIF}
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getintffilename: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getmainform: Boolean;
Begin
  Result := Fismainform;
End;


// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getowner: Iotamodule;
Begin
  Result := Fowner;
End;


// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getshowform: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getshowsource: Boolean;
Begin
  Result := True;
End;


// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Getunnamed: Boolean;
Begin
  Result := True;
End;


// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Newformfile(Const Formident, Ancestorident: String): Iotafile;
Begin
  Result := TCGIrdwdatamoduleformfile.Create('', Formident, Ancestorident, '', '');
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Newimplsource(Const Moduleident, Formident, Ancestorident: String): Iotafile;
Begin
  Result := TCGIrdwdatamodulefile.Create(Moduleident, Formident, Ancestorident, '', '');
End;

// ------------------------------------------------------------------------------

Function TCGIrdwdatamodule.Newintfsource(Const Moduleident, Formident, Ancestorident: String): Iotafile;
Begin
  Result := Nil;
End;

Initialization

Finalization

End.

