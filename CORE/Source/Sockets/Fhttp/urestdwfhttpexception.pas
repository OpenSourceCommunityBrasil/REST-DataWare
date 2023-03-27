unit uRESTDWFhttpException;

interface


uses
  SysUtils;

type
  // EIdException is the base class for all Exceptions raised in the Indy library.
  EException = class(Exception)
  public
    {
    The constructor must be virtual for Delphi NET if you want to call it with class methods.
    Otherwise, it will not compile in that IDE. Also it's overloaded so that it doesn't close
    the other methods declared by the DotNet exception (particularly InnerException constructors)
    }
    constructor Create(const AMsg: string); overload; virtual;
    class procedure Toss(const AMsg: string); {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use raise instead'{$ENDIF};{$ENDIF}
  end;

  TClassException = class of EException;

  // You can add EIdSilentException to the list of ignored exceptions to reduce debugger "trapping"
  // of "normal" exceptions
  ESilentException = class(EException);

  // EIdConnClosedGracefully is raised when remote side closes connection normally
  EConnClosedGracefully = class(ESilentException);

  // Other shared exceptions
  ESocketHandleError = class(EException);
  {$IFDEF UNIX}
  EIdNonBlockingNotSupported = class(EIdException);
  {$ENDIF}
  EPackageSizeTooBig = class(ESocketHandleError);
  ENotAllBytesSent = class (ESocketHandleError);
  ECouldNotBindSocket = class (ESocketHandleError);
  ECanNotBindPortInRange = class (ESocketHandleError);
  EInvalidPortRange = class(ESocketHandleError);
  ECannotSetIPVersionWhenConnected = class(ESocketHandleError);

implementation

{ EException }

constructor EException.Create(const AMsg : String);
begin
  inherited Create(AMsg);
end;


class procedure EException.Toss(const AMsg: string);

begin
  raise Create(AMsg);
end;

end.
