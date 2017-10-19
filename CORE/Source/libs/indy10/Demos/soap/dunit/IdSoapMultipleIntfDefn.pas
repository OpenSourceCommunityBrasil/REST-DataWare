{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16431: IdSoapMultipleIntfDefn.pas 
{
{   Rev 1.0    25/2/2003 13:29:04  GGrieve
}
{
Version History:
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  12-Apr 2002   Andrew Cumming                  First added
}

unit IdSoapMultipleIntfDefn;

{$I IdSoapDefines.inc}

interface

uses
  IdSoapTypeRegistry;

Type
  IIdSoapMultiple = interface(IIDSoapInterface)
    ['{298B437F-A00B-4980-A019-AEEBB173C27E}']
    function Called(ANum: Integer): String; stdcall;
    end;


implementation

end.
