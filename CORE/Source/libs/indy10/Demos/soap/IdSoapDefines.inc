{
IndySOAP: Indy Soap Global Defines
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  remove class_tracking, and indy10, compression, adv (kestral internal)
  18-Mar 2003   Grahame Grieve                  remove IDSOAP_USE_RENAMED_OPENXML
  17-Sep 2002   Grahame Grieve                  note regarding OpenXML define
  26-Mar 2002   Grahame Grieve                  Add VER140ENTERPRISE
   7-Feb 2002   Grahame Grieve                  Add SMARTERRORS
   3-Feb 2002   Andrew Cumming                  Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

{$I IdCompilerDefines.inc}

{$B-} // always use short circuit boolean logic

{$IFDEF DELPHI4}
  {$DEFINE DELPHI4OR5}
{$ENDIF}
{$IFDEF DELPHI5}
  {$DEFINE DELPHI4OR5}
{$ENDIF}

{=============================================================================
  Indy Defines
 =============================================================================}

{.$.DEFINE INDY_V10}

{ INDY 10 compatibility - support for Indy v10 }

{=============================================================================
  Indy Defines
 =============================================================================}

{$IFNDEF LINUX}
 {.$.DEFINE ID_SOAP_COMPRESSION}
{$ENDIF}

{ requires a working copy of ZLib.pas. We do not distribute this }


{=============================================================================
  Functional Defines
 =============================================================================}

{$DEFINE ID_SOAP_SORT_PROPERTIES}

// indySoap performs faster if the properties of an object are sorted. This
// will increase the speed at which the XML is loaded. The more properties an
// object has, the faster this will work
//
// however some clients may need the order to be preserved. So you can turn
// sorting using this define. Default is to sort. IndySoap doesn't care about
// order itself.
//
// this is a define since this happens so early - before any application host
// code is executed
//

{=============================================================================
  Defines Relating to OpenXML
 =============================================================================}

{.$.DEFINE IDSOAP_USE_RENAMED_OPENXML}

// This define has been removed - too much is changing in OpenXML to
// make it relevent - the only version supported by indysoap is the one provided
// as part of indysoap

{=============================================================================
  Defines Relating to VER140 Enterprise features
 =============================================================================}

{
IndySoap is able to make use of some of the features of Delphi (6?) (Enterprise?)
including
* the Interface RTTI from IntfInfo.pas.
* Web Broker Interface to allow use of IndySoap Server with Web Broker architecture

In order to use these features, you must have a version of Delphi/Kylix that includes
IntfInfo.dcu and the web broker architecture in the distribution. There appears to be
no way to determine whether this is the case, so if you are sure that you have the
required features, and you need the functionality, then you can define the following
define:
}

{.$.DEFINE VER140ENTERPRISE}

{=============================================================================
  Defines Relating to General Error Reporting
 =============================================================================}
{$DEFINE SMARTERRORS}

{$IFDEF SMARTERRORS}

  {$STACKFRAMES ON} //required to retrieve caller's address

{$ENDIF}

{=============================================================================
  Defines Relating to Object Tracking
 =============================================================================}

{$C+}
  { if this is disabled, then IndySOAP will run with the project assertion
    setting. You can use this setting to make IndySOAP run with a different
    assertion checking policy to the project (would usually be, project on,
    IndySOAP off)}

{$DEFINE OBJECT_TRACKING}
  { Complete Object Tracking. A full list of Objects is maintained in
    a separate list. Objects are cross-compared with the list. Not only
    does this provide leak tracking on a class per class basis, but it
    allows for authoritative checking that the object still points to
    an actual live instant that it is meant to. In addition, a watch can
    be requested on an object so that an break point will be called when
    the object is freed. }

{$IFOPT C+}
  // you can have assertions without having object tracking
  {.$.DEFINE OBJECT_TRACKING}
{$ELSE}
  {$UNDEF OBJECT_TRACKING}
{$ENDIF}

{$IFNDEF LINUX}
{.$.DEFINE USE_ADV}
  { Internal to Kestral only }
{$ENDIF}
