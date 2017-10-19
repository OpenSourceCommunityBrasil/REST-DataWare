{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16433: IdSoapMultipleIntfImpl.pas 
{
{   Rev 1.0    25/2/2003 13:29:12  GGrieve
}
{
Version History:
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  12-Apr 2002   Andrew Cumming                  First added
}

Unit IdSoapMultipleIntfImpl;

{$I IdSoapDefines.inc}

interface

Uses
  SysUtils,
  IdSoapIntfRegistry,
  IdSoapMultipleIntfDefn;

type
  EMultipleInterfaceFailed = class(Exception);

  TIdSoapMultiple = Class (TIdSoapBaseImplementation, IIdSoapMultiple)
    public
      procedure Check(ACondition: Boolean; AMessage: String);
    published
      function Called(ANum: Integer): String; stdcall;
    end;

implementation

{ TIdSoapMultiple }

procedure TIdSoapMultiple.Check(ACondition: Boolean; AMessage: String);
begin
  if not ACondition then
    raise EMultipleInterfaceFailed.Create('Server Error: ' + AMessage);
end;

function TIdSoapMultiple.Called(ANum: Integer): String;
begin
  Check(ANum = 5634,'Invalid parameter received');
  Result := 'Just a string';
end;

Initialization
  IdSoapRegisterInterfaceClass('IIdSoapMultiple', TypeInfo(TIdSoapMultiple), TIdSoapMultiple);
end.
