unit uDWDatamodule;

interface

Uses
  SysUtils, Classes, SysTypes, uDWJSONObject, uDWConstsData;

 Type
  TServerMethodDataModule = Class(TDataModule)
  Private
   vReplyEvent     : TReplyEvent;
   vWelcomeMessage : TWelcomeMessage;
  Public
   Encoding: TEncodeSelect;
  Published
   Property OnReplyEvent     : TReplyEvent      Read vReplyEvent     Write vReplyEvent;
   Property OnWelcomeMessage : TWelcomeMessage  Read vWelcomeMessage Write vWelcomeMessage;
 End;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

end.
