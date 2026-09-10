# TDSWebView native backend sources

Common backend API:
- Laz.Datasnap.DSWebViewBackend.pas
- Laz.Datasnap.DSWebViewBackendFactory.pas

Backends:
- Windows: existing WebView2/WebView4Delphi implementation.
- Linux/FreeBSD GTK3: Laz.Datasnap.DSWebViewBackendWebKitGTK.pas.
- macOS Cocoa / iOS Cocoa-family: Laz.Datasnap.DSWebViewBackendWK.pas.
- Android: Laz.Datasnap.DSWebViewBackendAndroid.pas.

Runtime:
- Linux: WebKit2GTK 4.1 preferred, 4.0 fallback.
- FreeBSD: WebKitGTK matching GTK3.
- macOS/iOS: system WebKit.framework / WKWebView.
- Android: system android.webkit.WebView.

Validation:
Windows remains the runtime-tested backend in the current project.
validation on those OS/widgetsets. Android still requires the exact Lazarus Android
widgetset Activity/JavaVM resolver and is therefore not claimed homologated.
