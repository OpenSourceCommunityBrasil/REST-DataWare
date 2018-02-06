unit uDWDatamodule;

interface

Uses
  SysUtils, Classes, SysTypes, uDWJSONObject, uDWConstsData, uRESTDWServerEvents;

 Type
  TServerMethodDataModule = Class(TDataModule)
  Private
   vReplyEvent     : TReplyEvent;
   vWelcomeMessage : TWelcomeMessage;
   vMassiveProcess : TMassiveProcess;
   vEncoding       : TEncodeSelect;
  Public
  Published
   Property Encoding         : TEncodeSelect    Read vEncoding       Write vEncoding;
   Property OnReplyEvent     : TReplyEvent      Read vReplyEvent     Write vReplyEvent;
   Property OnWelcomeMessage : TWelcomeMessage  Read vWelcomeMessage Write vWelcomeMessage;
   Property OnMassiveProcess : TMassiveProcess  Read vMassiveProcess Write vMassiveProcess;
 End;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

end.
