{ ************************************************************************* }
{ rdw wizards components }
{ para delphi }
{ }
{ desenvolvido por a. brito }
{ email : comercial@abritolda.com }
{ web : http://www.abritolda.com }
{ }
{ ************************************************************************* }

Unit Stlwizard;

{$I ..\Includes\RDWWIZ.inc}

Interface

Uses
  Windows, Classes, Toolsapi, Dialogs;

Type
  Tstlapplicationwizard = Class(Tnotifierobject, Iotawizard, Iotaprojectwizard,
      Iotarepositorywizard, Iunknown, Iotarepositorywizard80
   {$IF COMPILERVERSION > 29},IOTARepositoryWizard160 {$IFEND}
   {$IF COMPILERVERSION > 31}, IOTARepositoryWizard190{$IFEND}
   {$IF COMPILERVERSION > 32}, IOTARepositoryWizard260{$IFEND})
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

    Function Getgallerycategory: Iotagallerycategory;
    Function Getpersonality: String;
    Function Getdesigner: String;


//160
   {$IF COMPILERVERSION > 29}
     function GetFrameworkTypes: TArray<string>;
    { Return the platform keys for the platforms this wizard supports }
    function GetPlatforms: TArray<string>;

    property FrameworkTypes: TArray<string> read GetFrameworkTypes;
    property Platforms: TArray<string> read GetPlatforms;
    {$ENDIF}

    //190
    {$IF COMPILERVERSION > 31}
    function GetSupportedPlatforms: TArray<string>;
    {$ENDIF}

    // 260
    {$IF COMPILERVERSION > 32}
    function GetGalleryCategories: TArray<IOTAGalleryCategory>;

    { GalleryCategories allow register a wizard under several caregories }
    property GalleryCategories: TArray<IOTAGalleryCategory> read GetGalleryCategories;
    {$ENDIF}
  Protected
  End;

  Tstlprojectcreator = Class(Tnotifierobject, Iotacreator, Iotaprojectcreator,
      Iotaprojectcreator50{$IFDEF DELPHI2006_LVL}, Iotaprojectcreator80{$ENDIF})
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
{$IFDEF DELPHI2006_LVL}
    Function Getprojectpersonality: String;
{$ENDIF}
  Public
    Constructor Create(Projfile, Projectdir, Unitname, Formclass,
      Afilename: String);
  End;

  Tstlfrmwizard = Class(Tnotifierobject, Iotawizard, Iotarepositorywizard,
      Iotaformwizard
{$IFDEF VER180}, Iotaformwizard100{$ENDIF}
{$IFDEF DELPHI2006_LVL}, Iotarepositorywizard80{$ENDIF}, Iunknown)
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

{$IFDEF DELPHI2006_LVL}
    // 60
    Function Getdesigner: String;
    Property Designer: String Read Getdesigner;
    // 80
    Function Getgallerycategory: Iotagallerycategory;
    Function Getpersonality: String;
    Property Gallerycategory: Iotagallerycategory Read Getgallerycategory;
    Property Personality: String Read Getpersonality;
{$ENDIF}
{$IFDEF ver180}
    Function Isvisible(Project: Iotaproject): Boolean;
{$ENDIF}
  End;

  Tstlunitcreator = Class(Tnotifierobject, Iotacreator, Iotamodulecreator)
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

  Tstlrdwdatamodule = Class(Tnotifierobject, Iotawizard, Iotarepositorywizard,
      Iotacreator, Iotamodulecreator, IOTAFormWizard
{$IFNDEF ver180}, Iotaformwizard100{$ENDIF},Iotarepositorywizard80
   {$IF COMPILERVERSION > 29},IOTARepositoryWizard160 {$IFEND}
   {$IF COMPILERVERSION > 31}, IOTARepositoryWizard190{$IFEND}
   {$IF COMPILERVERSION > 32}, IOTARepositoryWizard260{$IFEND}, Iunknown)
  Private
    Funitident: String;
    Fclassname: String;
    Ffilename: String;
    Fismainform: Boolean;
    Fowner: Iotamodule;
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
    // 60
    Function Getdesigner: String;
    Property Designer: String Read Getdesigner;
    // 80


    function GetGalleryCategory: IOTAGalleryCategory;
    function GetPersonality: string;

    { GalleryCategory takes precedence over the result from GetPage.
      If a wizard doesn't implement IOTARepositoryWizard80, it is
      put under the Delphi personality's default section, and creates a
      sub area named by the result of "GetPage". }
    property GalleryCategory: IOTAGalleryCategory read GetGalleryCategory;
    property Personality: string read GetPersonality;


   //160
   {$IF COMPILERVERSION > 29}
     function GetFrameworkTypes: TArray<string>;
    { Return the platform keys for the platforms this wizard supports }
    function GetPlatforms: TArray<string>;

    property FrameworkTypes: TArray<string> read GetFrameworkTypes;
    property Platforms: TArray<string> read GetPlatforms;
    {$ENDIF}

    //190
    {$IF COMPILERVERSION > 31}
    function GetSupportedPlatforms: TArray<string>;
    {$ENDIF}

    // 260
    {$IF COMPILERVERSION > 32}
    function GetGalleryCategories: TArray<IOTAGalleryCategory>;

    { GalleryCategories allow register a wizard under several caregories }
    property GalleryCategories: TArray<IOTAGalleryCategory> read GetGalleryCategories;
    {$ENDIF}

{$IFNDEF ver180}
    Function Isvisible(Project: Iotaproject): Boolean;
{$ENDIF}
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

  Tbasefilestl = Class(Tinterfacedobject)
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

  Tstlrdwdatamodulefile2016 = Class(Tbasefilestl, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  Tstlrdwdatamoduleformfile = Class(Tbasefilestl, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  Tstlunitfile = Class(Tbasefilestl, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  Tstlformfile = Class(Tbasefilestl, Iotafile)
  Protected
    Function Getsource: String;
    Function Getage: Tdatetime;
  End;

  Tstlprojectfile = Class(Tnotifierobject, Iotafile)
  Private
    Fprojectname: String;
    Funitname: String;
    Fformclass: String;
  Public
    Function Getsource: String;
    Function Getage: Tdatetime;
    Constructor Create(Projname, Unitname, Formclass: String);
  End;

{$IFNDEF DELPHI2006_LVL}

Var
  Easydelphicategory: Iotagallerycategory = Nil;
{$ENDIF}

Implementation

Uses
  Forms, Sysutils, Designintf, Registry, Shlobj
  {$IF COMPILERVERSION > 29}
  ,PlatformAPI
{$ENDIF};

Const
  Sauthor = 'abritolda.com';
  Spage = 'REST Dataware';

{.$R .\RDWSERVER.res}
//{$R stlrwdfrm.res}
//{$R stlrdwdatamunit.res}
//{$R stlrdwdatamfrm.res}

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
 {$IFNDEF ver185}
  {$IFDEF ver180} // delphi 2006
  Result := '\Software\Borland\BDS\4.0\Globals';
  {$ENDIF}
 {$ENDIF}
 {$IFDEF ver185} // delphi 2007
  Result := '\Software\Borland\BDS\5.0\Globals';
 {$ENDIF}
 {$IFDEF ver200} // delphi 2009
  Result := '\Software\CodeGear\BDS\6.0\Globals';
 {$ENDIF}
 {$IFDEF ver210} // delphi 2010
  Result := '\Software\CodeGear\BDS\7.0\Globals';
 {$ENDIF}
 {$IFDEF ver220} // delphi xe
  Result := '\Software\Embarcadero\BDS\8.0\Globals';
 {$ENDIF}
 {$IFDEF ver230} // delphi xe2
  Result := '\Software\Embarcadero\BDS\9.0\Globals';
 {$ENDIF}
 {$IFDEF ver240} // delphi xe3
  Result := '\Software\Embarcadero\BDS\10.0\Globals';
 {$ENDIF}
 {$IFDEF ver250} // delphi xe4
  Result := '\Software\Embarcadero\BDS\11.0\Globals';
 {$ENDIF}
 {$IFDEF ver260} // delphi xe5
  Result := '\Software\Embarcadero\BDS\12.0\Globals';
 {$ENDIF}
 {$IFDEF ver270} // delphi xe6
  Result := '\Software\Embarcadero\BDS\14.0\Globals';
 {$ENDIF}
 {$IFDEF ver280} // delphi xe7
  Result := '\Software\Embarcadero\BDS\15.0\Globals';
 {$ENDIF}
 {$IFDEF ver290} // delphi xe8
  Result := '\Software\Embarcadero\BDS\16.0\Globals';
 {$ENDIF}
 {$IFDEF ver300} // delphi xe10
  Result := '\Software\Embarcadero\BDS\17.0\Globals';
 {$ENDIF}
 {$IFDEF ver310} // delphi xe10.1
  Result := '\Software\Embarcadero\BDS\18.0\Globals';
 {$ENDIF}
 {$IFDEF ver320} // delphi xe10.2
  Result := '\Software\Embarcadero\BDS\19.0\Globals';
 {$ENDIF}
 {$IFDEF ver330} // delphi xe10.3
  Result := '\Software\Embarcadero\BDS\20.0\Globals';
 {$ENDIF}
 {$IFDEF ver340} // delphi xe10.4
  Result := '\Software\Embarcadero\BDS\21.0\Globals';
 {$ENDIF}
 {$IFDEF ver350} // delphi 11
  Result := '\Software\Embarcadero\BDS\22.0\Globals';
 {$ENDIF}
 {$IFDEF ver360} // delphi 12
  Result := '\Software\Embarcadero\BDS\23.0\Globals';
 {$ENDIF}
 {$IFDEF ver370} // delphi 13
  Result := '\Software\Embarcadero\BDS\37.0\Globals';
 {$ENDIF}
End;

Function Getideprojectpath: String;
Var
  Lpath: String;
 r : Tregistry;
 ResStream: TResourceStream;
Begin
 Try
  r := Tregistry.Create;
  r.Rootkey := Hkey_current_user;
  {$IFNDEF DELPHI2006_LVL}
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
      {$IFNDEF DELPHI2007_LVL}
       Lpath := Includetrailingpathdelim(Lpath) + 'Borland Studio Projects' + Pathdelim;
      {$ENDIF}
      {$IFDEF DELPHI2007_LVL}
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
  ResStream := TResourceStream.Create(HInstance, 'RDWUSOCK', RT_RCDATA);
  Try
   ResStream.Position := 0;
   ResStream.SaveToFile(lpath + 'uSock.pas');
  Finally
   ResStream.Free;
  End;
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

{ tbasefilestl }

Constructor Tbasefilestl.Create(Const Modulename,
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

{ tstlunitfile }

Function Tstlunitfile.Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWSRVUNIT';
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

Function Tstlunitfile.Getage: Tdatetime;
Begin
  Result := -1;
End;

// ------------------------------------------------------------------------------

{ tstlformfile }

Function Tstlformfile.Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWSRVFRM';
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

Function Tstlformfile.Getage: Tdatetime;
Begin
  Result := -1;
End;

// ------------------------------------------------------------------------------

{ tstlfrmwizard }
{ tstlfrmwizard.iotawizard }

Function Tstlfrmwizard.Getidstring: String;
Begin
  Result := 'RDW.RestDatawareServerForm';
End;

// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getname: String;
Begin
  Result := 'REST Dataware - Server Form';
End;

// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getstate: Twizardstate;
Begin
  Result := [Wsenabled];
End;

// ------------------------------------------------------------------------------

Procedure Tstlfrmwizard.Execute;
Var
  Lproj: Iotaproject;
  Frameclassname, Frameunitname: String;
Begin
{$IFDEF DELPHI2006_LVL}
  (Borlandideservices As Iotamoduleservices).Getnewmoduleandclassname('', Funitident,
    Fclassname, Ffilename);
  Fclassname := 'RDWUnit' + Copy(Funitident, 8, Length(Funitident));
{$ELSE}
  (Borlandideservices As Iotamoduleservices).Getnewmoduleandclassname('RDWForm',
    Funitident, Fclassname, Ffilename);
    Fclassname := 'RDWDMUnit' + Copy(Funitident, 8, Length(Funitident));
{$ENDIF}
  // (borlandideservices as iotamoduleservices).createmodule(self);
  Lproj := Getcurrentproject;
  If Lproj <> Nil Then
  Begin
    (Borlandideservices As Iotamoduleservices).Createmodule
      (Tstlrdwdatamodule.Createa(Lproj, Funitident, Fclassname, Ffilename));
  End;

  Frameclassname := Fclassname;
  Frameunitname := Funitident;

{$IFDEF DELPHI2006_LVL}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('', Funitident,
    Fclassname, Ffilename);
  Fclassname := 'RDWForm' +
    Copy(Funitident, 5, Length(Funitident));
{$ELSE}
  (Borlandideservices As Iotamoduleservices).Getnewmoduleandclassname('RDWForm',
    Funitident, Fclassname, Ffilename);
    Fclassname := 'RDWForm' +
    Copy(Funitident, 8, Length(Funitident));
{$ENDIF}
  // (borlandideservices as iotamoduleservices).createmodule(self);
  Lproj := Getcurrentproject;
  If Lproj <> Nil Then
  Begin
    (Borlandideservices As Iotamoduleservices).Createmodule(Tstlunitcreator.Create(Lproj,
      Funitident, Frameunitname, Fclassname, Frameclassname, Ffilename));
  End;
End;

// ------------------------------------------------------------------------------

{$IFDEF DELPHI2006_LVL}
{ tstlfrmwizard.iotarepositorywizard / tstlfrmwizard.iotaformwizard }

Function Tstlfrmwizard.Getgallerycategory
  : Iotagallerycategory;
Begin
  Result := Nil;

End;

// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getpersonality: String;
Begin
  Result := Sdelphipersonality;
End;

// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getdesigner: String;
Begin
  Result := Dvcl;
End;
{$ENDIF}
// ------------------------------------------------------------------------------
{$IFDEF ver180}

Function Tstlfrmwizard.Isvisible(Project: Iotaproject): Boolean;
Begin
  Result := True;
End;
{$ENDIF}
// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getglyph: Cardinal;
Begin
  Result := 0; // use standard icon
End;

// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getpage: String;
Begin
  Result := Spage;
End;

// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getauthor: String;
Begin
  Result := Sauthor;
End;

// ------------------------------------------------------------------------------

Function Tstlfrmwizard.Getcomment: String;
Begin
  Result := 'Cria um novo Servidor RestdataWare.'
End;

// ------------------------------------------------------------------------------

{ tstlunitcreator }

Constructor Tstlunitcreator.Create
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

Procedure Tstlunitcreator.Formcreated
  (Const Formeditor: Iotaformeditor);
Begin
  //
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getancestorname: String;
Begin
  Result := 'TForm'; // 'tform';
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getcreatortype: String;
Begin
  Result := Sform;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getexisting: Boolean;
Begin
  Result := False;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getfilesystem: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getformname: String;
Begin
  Result := Fclassname;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getimplfilename: String;
Var
  // currdir: array[0..max_path] of char;
  Projectdir: String;
Begin
  // note: full path name required!
  { getcurrentdirectory(sizeof(currdir), currdir);
    Result := Format('%s\%s.pas', [CurrDir, FUnitIdent, '.pas']);
  }

  Projectdir := Getideprojectpath;
  Projectdir :=
    Includetrailingpathdelim(Projectdir);

{$IFDEF delphi9_lvl}
  If Fismainform Then
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

Function Tstlunitcreator.Getintffilename: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getmainform: Boolean;
Begin
  Result := Fismainform;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getowner: Iotamodule;
Begin
  Result := Fowner;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getshowform: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getshowsource: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Getunnamed: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Newformfile
  (Const Formident, Ancestorident: String)
  : Iotafile;
Begin
  Result := Tstlformfile.Create('', Formident,
    Ancestorident, Fclassnameframe,
    Funitidentframe);
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Newimplsource
  (Const Moduleident, Formident,
  Ancestorident: String): Iotafile;
Begin
  Result := Tstlunitfile.Create(Moduleident,
    Formident, Ancestorident, Fclassnameframe,
    Funitidentframe);
End;

// ------------------------------------------------------------------------------

Function Tstlunitcreator.Newintfsource
  (Const Moduleident, Formident,
  Ancestorident: String): Iotafile;
Begin
  Result := Nil;
End;

// ------------------------------------------------------------------------------

{ tstlapplicationwizard }

Procedure Tstlapplicationwizard.Execute;
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
  Projectdir :=
    Includetrailingpathdelim(Projectdir);

{$IFDEF DELPHI2006_LVL}
  Lmoduleservices.Getnewmoduleandclassname('',
    Funitident, Fclassname, Ffilename);
  Fclassname := 'RDWForm' +
    Copy(Funitident, 8, Length(Funitident));
{$ELSE}
  Lmoduleservices.Getnewmoduleandclassname
    ('RDWForm', Funitident, Fclassname,
    Ffilename);
    Fclassname := 'RDWForm' +
    Copy(Funitident, 8, Length(Funitident));
{$ENDIF}
Fclassname := 'RDWForm' +
    Copy(Funitident, 8, Length(Funitident));
  Lmoduleservices.Createmodule
    (Tstlprojectcreator.Create(Fprojectname,
    Projectdir, Funitident, Fclassname,
    Ffilename));
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getauthor: String;
Begin
  Result := Sauthor;
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getcomment: String;
Begin
  Result := 'REST Dataware - Standalone Form Application';
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getgallerycategory
  : Iotagallerycategory;
Begin
  Result := Nil;

End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getpersonality: String;
Begin
  Result := Sdelphipersonality;
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getdesigner: String;
Begin
  Result := Dvcl;
End;

// ------------------------------------------------------------------------------

{$IF COMPILERVERSION > 29}
function Tstlapplicationwizard.GetFrameworkTypes: TArray<string>;
begin
  SetLength(Result, 2);
  Result[0] := sFrameworkTypeVCL;
  Result[1] := sFrameworkTypeFMX;
end;

{ Return the platform keys for the platforms this wizard supports }
function Tstlapplicationwizard.GetPlatforms: TArray<string>;
begin
  SetLength(Result, 3);
  Result[0] := cWin32Platform;
  Result[1] := cWin64Platform;
  Result[2] := cLinux64Platform;
//  Result[3] := cAndroidPlatform;
//  Result[4] := cAndroidPlatform;
//  Result[5] := cOSX64Platform;
//  Result[6] := ciOSSimulator64Platform;
//  Result[7] := ciOSDevice64Platform;
end;
 {$ENDIF}

{$IF COMPILERVERSION > 31}
function Tstlapplicationwizard.GetSupportedPlatforms: TArray<string>;
begin
  SetLength(Result, 6);
  Result[0] := cWin32Platform;
  Result[1] := cWin64Platform;
  Result[2] := cLinux64Platform;
  Result[3] := cOSX64Platform;
  Result[4] := ciOSSimulator64Platform;
  Result[5] := ciOSDevice64Platform;
//  Result[6] := cAndroidArm32Platform;
//  Result[7] := cAndroidArm64Platform;
end;
{$ENDIF}

{$IF COMPILERVERSION > 32}
function Tstlapplicationwizard.GetGalleryCategories: TArray<IOTAGalleryCategory>;
begin
  Result:=nil;
end;
{$ENDIF}

Function Tstlapplicationwizard.Getglyph: Cardinal;
Begin
  Result := 0;
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.
  Getidstring: String;
Begin
  Result := 'RDW.STLRestdatawareApplicationWizard';
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getname: String;
Begin
  Result := 'REST Dataware - Standalone Server application';
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getpage: String;
Begin
  Result := Spage;
End;

// ------------------------------------------------------------------------------

Function Tstlapplicationwizard.Getstate
  : Twizardstate;
Begin
  Result := [Wsenabled];
End;

// ------------------------------------------------------------------------------

{ tstlprojectcreator }

Constructor Tstlprojectcreator.Create(Projfile,
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

Function Tstlprojectcreator.Getcreatortype: String;
Begin
  Result := Sapplication;
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Getexisting: Boolean;
Begin
  Result := False;
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Getfilename: String;
Begin
  Result := Fprojectdirectory +
    Fprojectfile + '.dpr';
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Getfilesystem: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.
  Getoptionfilename: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Getowner: Iotamodule;
Begin
  Result := Nil;
End;

// ------------------------------------------------------------------------------

{$IFDEF DELPHI2006_LVL}

Function Tstlprojectcreator.Getprojectpersonality: String;
Begin
{$IFDEF DELPHI2006_LVL}
  Result := Sdelphipersonality;
{$ELSE}
  Result := 'Delphi.Personality';
{$ENDIF}
End;
{$ENDIF}
// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Getshowsource
  : Boolean;
Begin
  Result := True; // not fisbcb;
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Getunnamed: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Procedure Tstlprojectcreator.Newdefaultmodule;
Begin
  //
End;

// ------------------------------------------------------------------------------

Procedure Tstlprojectcreator.
  Newdefaultprojectmodule(Const Project
  : Iotaproject);
Var
  Lmoduleservices: Iotamoduleservices;
  Frameclassname, Frameunitname: String;
  Lproj: Iotaproject;
Begin
  Lmoduleservices :=
    (Borlandideservices As Iotamoduleservices);
  Lmoduleservices.Createmodule
    (Tstlrdwdatamodule.Createa(Project, Funitname,
    Fformclass, Ffilename, True));

  Frameclassname := Fformclass;
  Frameunitname := Funitname;

{$IFDEF DELPHI2006_LVL}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('', Funitname,
    Fformclass, Ffilename);
  Fformclass := 'RDWForm' +
    Copy(Funitname, 5, Length(Funitname));
{$ELSE}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('RDWForm',
    Funitname, Fformclass, Ffilename);
{$ENDIF}
  // (borlandideservices as iotamoduleservices).createmodule(self);
  Lproj := Getcurrentproject;
  If Lproj <> Nil Then
  Begin
    (Borlandideservices As Iotamoduleservices)
      .Createmodule(Tstlunitcreator.Create(Lproj,
      Funitname, Frameunitname, Fformclass,
      Frameclassname, Ffilename));
  End;
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Newoptionsource
  (Const Projectname: String): Iotafile;
Begin
  Result := Nil;
End;

// ------------------------------------------------------------------------------

Procedure Tstlprojectcreator.Newprojectresource
  (Const Project: Iotaproject);
Begin
  //
End;

// ------------------------------------------------------------------------------

Function Tstlprojectcreator.Newprojectsource
  (Const Projectname: String): Iotafile;
Begin
  Result := Tstlprojectfile.Create(Projectname,
    Funitname, Fformclass);
End;

// ------------------------------------------------------------------------------

{ tstlprojectfile }

Constructor Tstlprojectfile.Create(Projname,
  Unitname, Formclass: String);
Begin
  Inherited Create;
  Fprojectname := Projname;
  Funitname := Unitname;
  Fformclass := Formclass;
End;

// ------------------------------------------------------------------------------

Function Tstlprojectfile.Getage: Tdatetime;
Begin
  Result := -1;
End;

// ------------------------------------------------------------------------------

Function Tstlprojectfile.Getsource: String;
Begin
  Result := 'program ' + Fprojectname + ';' +
    #13#10 + #13#10 +
{$IFDEF DELPHI2006_LVL}
  'uses Forms;' + #13#10 +
{$ELSE}
  'uses Forms,' + #13#10 + ' ' + Funitname +
    ' in ''' + Funitname + '.pas'' {' + Fformclass
    + '};' + #13#10 +
{$ENDIF}
  '{$R *.res}' + #13#10 + #13#10 + 'begin' +
    #13#10 + '  Application.Initialize;'
    + #13#10 +
  '  Application.Run;' + #13#10 + 'end.';
End;

// ------------------------------------------------------------------------------

{ tstlrdwdatamodulefile2016 }

Function Tstlrdwdatamodulefile2016.Getage
  : Tdatetime;
Begin
  Result := -1;
End;

Function Tstlrdwdatamodulefile2016.
  Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWDATAMUNIT';
  Resinstance := Findresourcehinstance(Hinstance);
  Hres := Findresourcea(Resinstance,
    Pansichar(Resname), Pansichar(10));
  Text := Pansichar
    (Lockresource
    (Loadresource(Resinstance, Hres)));
  Setlength(Text,
    Sizeofresource(Resinstance, Hres));
  Result := Format(String(Text),
    [Fmodulename, Fformname, Fancestorname]);
End;

{ tstlrdwdatamoduleformfile }

Function Tstlrdwdatamoduleformfile.Getage
  : Tdatetime;
Begin
  Result := -1;
End;

Function Tstlrdwdatamoduleformfile.
  Getsource: String;
Var
  Text: Ansistring;
  Resinstance: Thandle;
  Hres: Hrsrc;
  Resname: Ansistring;
Begin
  Resname := 'RDWDATAMFRM';
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

{ tstlrdwdatamodule }

Constructor Tstlrdwdatamodule.Createa
  (Aowner: Iotamodule;
  Unitident, Classname, Afilename: String;
  Aismainform: Boolean);
Begin
  Funitident := Unitident;
  Fclassname := Classname;
  Ffilename := Afilename;
  Inherited Create;
  Fowner := Aowner;
  Fismainform := Aismainform;
End;

// ------------------------------------------------------------------------------

Procedure Tstlrdwdatamodule.Execute;
Var
  Lproj: Iotaproject;
Begin
{$IFDEF VER180}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('', Funitident,
    Fclassname, Ffilename);
  Fclassname := 'RDWDatam' +
    Copy(Funitident, 8, Length(Funitident));
{$ELSE}
  (Borlandideservices As Iotamoduleservices)
    .Getnewmoduleandclassname('RDWUnitDM',
    Funitident, Fclassname, Ffilename);
   Fclassname := 'RDWDatam' +
    Copy(Funitident, 10, Length(Funitident));
{$ENDIF}
  Lproj := Getcurrentproject;
    (Borlandideservices As Iotamoduleservices)
      .Createmodule
      (Tstlrdwdatamodule.Createa(Lproj,
      Funitident, Fclassname, Ffilename));
End;

Procedure Tstlrdwdatamodule.Formcreated
  (Const Formeditor: Iotaformeditor);
Begin
  //
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.
  Getancestorname: String;
Begin
  Result := 'TServerMethodDataModule'; // 'tform';
End;

Function Tstlrdwdatamodule.Getauthor: String;
Begin
  Result := Sauthor;
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getcomment: String;
Begin
  Result := 'Criar Novo DataModule.'
End;

Function Tstlrdwdatamodule.Getcreatortype: String;
Begin
  Result := Sform;
End;

Function Tstlrdwdatamodule.Getdesigner: String;
Begin
  Result := Dvcl;
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getexisting: Boolean;
Begin
  Result := False;
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getfilesystem: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getformname: String;
Begin
  Result := Fclassname;
End;

Function Tstlrdwdatamodule.Getgallerycategory
  : Iotagallerycategory;
Begin
  Result := Nil;
End;

Function Tstlrdwdatamodule.Getglyph: Cardinal;
Begin
  Result := 0; // use standard icon
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getidstring: String;
Begin
  Result := 'RDW.ServerDatamodule';
End;

Function Tstlrdwdatamodule.Getimplfilename: String;
Var
  // currdir: array[0..max_path] of char;
  Projectdir: String;
Begin
  // note: full path name required!
  { getcurrentdirectory(sizeof(currdir), currdir);
    Result := Format('%s\%s.pas', [CurrDir, FUnitIdent, '.pas']);
  }

  Projectdir := Getideprojectpath;
  Projectdir :=
    Includetrailingpathdelim(Projectdir);

{$IFDEF delphi9_lvl}
  If Fismainform Then
  Begin
    Result := Makefilename(Projectdir, Funitident, 'pas');
  End;
{$ELSE}
  Result := Makefilename(Projectdir, Funitident, 'pas');
{$ENDIF}
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getintffilename: String;
Begin
  Result := '';
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getmainform: Boolean;
Begin
  Result := Fismainform;
End;

Function Tstlrdwdatamodule.Getname: String;
Begin
  Result := 'REST Dataware - DataModule';
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getowner: Iotamodule;
Begin
  Result := Fowner;
End;

Function Tstlrdwdatamodule.Getpage: String;
Begin
  Result := Spage;
End;



Function Tstlrdwdatamodule.Getpersonality: string;
Begin
  Result := Sdelphipersonality;
End;


// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getshowform: Boolean;
Begin
  Result := True;
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getshowsource: Boolean;
Begin
  Result := True;
End;

Function Tstlrdwdatamodule.Getstate: Twizardstate;
Begin
  Result := [Wsenabled];
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Getunnamed: Boolean;
Begin
  Result := True;
End;

{$IF COMPILERVERSION > 29}
function Tstlrdwdatamodule.GetFrameworkTypes: TArray<string>;
begin
  SetLength(Result, 2);
  Result[0] := sFrameworkTypeVCL;
  Result[1] := sFrameworkTypeFMX;
end;


{ Return the platform keys for the platforms this wizard supports }
function Tstlrdwdatamodule.GetPlatforms: TArray<string>;
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

{$IF COMPILERVERSION > 31}
function Tstlrdwdatamodule.GetSupportedPlatforms: TArray<string>;
begin
  SetLength(Result, 6);
  Result[0] := cWin32Platform;
  Result[1] := cWin64Platform;
  Result[2] := cLinux64Platform;
  Result[3] := cOSX64Platform;
  Result[4] := ciOSSimulator64Platform;
  Result[5] := ciOSDevice64Platform;
//  Result[6] := cAndroidArm32Platform;
//  Result[7] := cAndroidArm64Platform;
end;
{$ENDIF}

{$IF COMPILERVERSION > 32}
function Tstlrdwdatamodule.GetGalleryCategories: TArray<IOTAGalleryCategory>;
begin
  Result:=nil;
end;

{$ENDIF}


{$IFNDEF ver180}
Function Tstlrdwdatamodule.Isvisible(Project: Iotaproject): Boolean;
Begin
  Result := True;
End;
{$ENDIF}
// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Newformfile(Const Formident, Ancestorident: String): Iotafile;
Begin
  Result := Tstlrdwdatamoduleformfile.Create('', Formident, Ancestorident, '', '');
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Newimplsource(Const Moduleident, Formident, Ancestorident: String): Iotafile;
Begin
  Result := Tstlrdwdatamodulefile2016.Create(Moduleident, Formident, Ancestorident, '', '');
End;

// ------------------------------------------------------------------------------

Function Tstlrdwdatamodule.Newintfsource(Const Moduleident, Formident, Ancestorident: String): Iotafile;
Begin
  Result := Nil;
End;

Initialization

Finalization

End.

