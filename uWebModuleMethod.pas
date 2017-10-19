unit uWebModuleMethod;

Interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Datasnap.DSHTTPCommon,
  Datasnap.DSHTTPWebBroker,  Datasnap.DSServer, Datasnap.DSHTTP,
  Datasnap.DSAuth,                IPPeerServer, Datasnap.DSCommonServer,
  Datasnap.DSSession,             Web.HTTPProd, URestPoolerDBMethod,
  System.ZLib;

 Type
  TOnAfterDispatch = Procedure (Sender      : TObject;
                                Request     : TWebRequest;
                                Response    : TWebResponse;
                                Var Handled : Boolean) Of Object;


 Type
  TDWModule = Class(TWebModule)
  Private
   vCompress : Boolean;
   Function  GetCompressVar : Boolean;
   Procedure SetCompressVar(Value : Boolean);
   Procedure OnAfterDispatch(Sender      : TObject;
                             Request     : TWebRequest;
                             Response    : TWebResponse;
                             Var Handled : Boolean);
  Public
   Constructor Create(AOwner : TComponent);Override;
  Published
   Property Compression   : Boolean Read GetCompressVar Write SetCompressVar;
 End;

implementation


Constructor TDWModule.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 AfterDispatch := OnAfterDispatch;
End;

Function TDWModule.GetCompressVar: Boolean;
Begin
 Result := vCompress;
End;

Procedure TDWModule.SetCompressVar(Value: Boolean);
Begin
 vCompress := Value;
End;

Procedure TDWModule.OnAfterDispatch(Sender      : TObject;
                                    Request     : TWebRequest;
                                    Response    : TWebResponse;
                                    Var Handled : Boolean);
{
Var
 Original,
 gZIPStream : TMemoryStream;
 oString    : String;
 Len        : Integer;
 Procedure doGZIP(Input, gZipped: TMemoryStream);//helper function
 Const
  GZIP = 31;//very important because gzip is a linux zip format
 Var
  CompactadorGZip : TZCompressionStream;
 Begin
  Input.Position   := 0;
  CompactadorGZip  := TZCompressionStream.Create(gZipped, zcMax, GZIP);
  CompactadorGZip.CopyFrom(Input, Input.Size);
  CompactadorGZip.Free;
  gZipped.Position := 0;
 End;
}
Begin
{
 If vCompress Then
  Begin
   Original   := TMemoryStream.Create;
   gZIPStream := TMemoryStream.Create;
   Try
    oString := UTF8String(Response.Content);
    Len     := Length(oString);
    Original.WriteBuffer(oString[1], len);
    //make it gzip
    doGZIP(Original, gZIPStream);
    //prepare responsestream and set content encoding and type
    Response.Content         := '';
    Response.ContentStream   := gZIPStream;
    Response.ContentEncoding := 'gzip, deflate';
    Response.ContentType     := 'application/json';
   Finally
    Original.DisposeOf;
    gZIPStream.DisposeOf;
   End;
  End;
}
End;

end.
