unit StopWatch;

 interface

 uses Windows, SysUtils, DateUtils;

 type TStopWatch = class
   private
     fFrequency : TLargeInteger;
     fIsRunning: boolean;
     fIsHighResolution: boolean;
     fStartCount, fStopCount : TLargeInteger;
     procedure SetTickStamp(var lInt : TLargeInteger) ;
     function GetElapsedTicks: TLargeInteger;
     function GetElapsedMilliseconds: TLargeInteger;
     function GetElapsed: string;
   public
     constructor Create(const startOnCreate : boolean = false) ;
     procedure Start;
     procedure Stop;
     property IsHighResolution : boolean read fIsHighResolution;
     property ElapsedTicks : TLargeInteger read GetElapsedTicks;
     property ElapsedMilliseconds : TLargeInteger read GetElapsedMilliseconds;
     property Elapsed : string read GetElapsed;
     property IsRunning : boolean read fIsRunning;
   end;

 implementation

 constructor TStopWatch.Create(const startOnCreate : boolean = false) ;
 begin
   inherited Create;

   fIsRunning := false;

   fIsHighResolution := QueryPerformanceFrequency(fFrequency) ;
   if NOT fIsHighResolution then fFrequency := MSecsPerSec;

   if startOnCreate then Start;
 end;

 function TStopWatch.GetElapsedTicks: TLargeInteger;
 begin
   result := fStopCount - fStartCount;
 end;

 procedure TStopWatch.SetTickStamp(var lInt : TLargeInteger) ;
 begin
   if fIsHighResolution then
     QueryPerformanceCounter(lInt)
   else
     lInt := MilliSecondOf(Now) ;
 end;

 function TStopWatch.GetElapsed: string;
 var
   dt : TDateTime;
 begin
   dt := ElapsedMilliseconds / MSecsPerSec / SecsPerDay;
   result := Format('%d days, %s', [trunc(dt), FormatDateTime('hh:nn:ss.z', Frac(dt))]) ;
 end;

 function TStopWatch.GetElapsedMilliseconds: TLargeInteger;
 begin
   result := (MSecsPerSec * (fStopCount - fStartCount)) div fFrequency;
 end;

 procedure TStopWatch.Start;
 begin
   SetTickStamp(fStartCount) ;
   fIsRunning := true;
 end;

 procedure TStopWatch.Stop;
 begin
   SetTickStamp(fStopCount) ;
   fIsRunning := false;
 end;
 end.
