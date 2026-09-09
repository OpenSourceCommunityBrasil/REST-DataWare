RESTDataware TDSWebView native backend location
SysOp=darwin
CPU=aarch64

Keep native runtime libraries for this exact operating system/processor here.
Do not copy binaries from another SysOp/CPU.

The common component API remains Laz.Datasnap.DSWebView.TDSWebView.
Windows currently uses the embedded WebView2/WebView4Delphi backend already
shipped with Laz.Datasnap. Other platform backends must use the native
browser engine for their SysOp and must preserve the same DOM editor bridge
(DSSEL/DSHTML/error bridge/InsertHTMLAt/Object Inspector/Delete).
