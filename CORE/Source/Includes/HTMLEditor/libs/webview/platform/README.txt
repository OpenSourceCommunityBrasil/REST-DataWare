RESTDataware WebView platform layout

Common API:
  TDSWebView

Platform backend policy:
  Windows : WebView2 (WebView4Delphi)
  Linux   : native WebKitGTK backend
  FreeBSD : native WebKitGTK backend
  macOS   : native WKWebView backend
  Android : native Android WebView backend when supported by Lazarus target
  iOS     : native WKWebView backend when supported by Lazarus target

Native libraries must live under:
  libs/webview/platform/<sysop>/<cpu>/

No Windows-specific unit/API may be referenced by the common PageProducer
editor. Platform-specific code must be isolated by IFDEF/backend units.
