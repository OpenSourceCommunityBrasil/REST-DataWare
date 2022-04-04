Unit uRESTDWAttachment;

{$I ..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
 Classes,
 uRESTDWMessageParts;

 Type
  TRESTDWAttachment = Class(TRESTDWMessagePart)
  public
    // here the methods you have to override...

    // for open handling
    // works like this:
    //  1) you create an attachment - and do whatever it takes to put data in it
    //  2) you send the message
    //  3) this will be called - first OpenLoadStream, to get a stream
    //  4) when the message is fully encoded, CloseLoadStream is called
    //     to close the stream. The Attachment implementation decides what to do
    function OpenLoadStream: TStream; virtual; abstract;
    procedure CloseLoadStream; virtual; abstract;

    // for save handling
    // works like this:
    //  1) new attachment is created
    //  2) PrepareTempStream is called
    //  3) stuff is loaded
    //  4) FinishTempStream is called of the newly created attachment
    function  PrepareTempStream: TStream; virtual; abstract;
    procedure FinishTempStream; virtual; abstract;

    procedure LoadFromFile(const FileName: String); virtual;
    procedure LoadFromStream(AStream: TStream); virtual;
    procedure SaveToFile(const FileName: String); virtual;
    procedure SaveToStream(AStream: TStream); virtual;
    
    class function PartType: TRESTDWMessagePartType; override;
  end;

  TRESTDWAttachmentClass = class of TRESTDWAttachment;

implementation

uses
  IdGlobal, IdGlobalProtocols, IdCoderHeader,
  SysUtils;

{ TRESTDWAttachment }

class function TRESTDWAttachment.PartType: TRESTDWMessagePartType;
begin
  Result := mptAttachment;
end;

procedure TRESTDWAttachment.LoadFromFile(const FileName: String);
var
  LStrm: TIdReadFileExclusiveStream;
begin
  LStrm := TIdReadFileExclusiveStream.Create(FileName); try
    LoadFromStream(LStrm);
  finally
    FreeAndNil(LStrm);
  end;
end;

procedure TRESTDWAttachment.LoadFromStream(AStream: TStream);
var
  LStrm: TStream;
begin
  LStrm := PrepareTempStream;
  try
                                                                           
    // CopyFrom() if (AStream.Size-AStream.Position) is <= 0.  Passing 0 to
    // CopyFrom() tells it to seek AStream to Position=0 and then copy the
    // entire stream, which is fine for the stream provided by LoadFromFile(),
    // but may not always be desirable for user-provided streams...
    LStrm.CopyFrom(AStream, 0);
  finally
    FinishTempStream;
  end;
end;

procedure TRESTDWAttachment.SaveToFile(const FileName: String);
var
  LStrm: TIdFileCreateStream;
begin
  LStrm := TIdFileCreateStream.Create(FileName); try
    SaveToStream(LStrm);
  finally
    FreeAndNil(LStrm);
  end;
end;

procedure TRESTDWAttachment.SaveToStream(AStream: TStream);
var
  LStrm: TStream;
begin
  LStrm := OpenLoadStream;
  try
    AStream.CopyFrom(LStrm, 0);
  finally
    CloseLoadStream;
  end;
end;

end.

