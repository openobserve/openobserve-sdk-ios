/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

#if canImport(WebKit)
import WebKit

@objc(DDWebViewTracking)
@_spi(objc)
public final class objc_WebViewTracking: NSObject {
    override private init() { }

    /// Enables SDK to correlate OpenObserve RUM events and Logs from the WebView with native RUM session.
    ///
    /// If the content loaded in WebView uses OpenObserve Browser SDK (`v4.2.0+`) and matches specified
    /// `hosts`, web events will be correlated with the RUM session from native SDK.
    ///
    /// - Parameters:
    ///   - webView: The web-view to track.
    ///   - hosts: A set of hosts instrumented with Browser SDK to capture OpenObserve events from.
    ///   - logsSampleRate: The sampling rate for logs coming from the WebView. Must be a value between `0` and `100`,
    ///   where 0 means no logs will be sent and 100 means all will be uploaded. Default: `100`.
    ///   - core: OpenObserve SDK core to use for tracking.
    @objc
    public static func enable(
        webView: WKWebView,
        hosts: Set<String> = [],
        logsSampleRate: SampleRate = .maxSampleRate
    ) {
        WebViewTracking.enable(
            webView: webView,
            hosts: hosts,
            logsSampleRate: logsSampleRate
        )
    }

    /// Disables OpenObserve iOS SDK and OpenObserve Browser SDK integration.
    ///
    /// Removes OpenObserve's ScriptMessageHandler and UserScript from the caller.
    /// - Note: This method **must** be called when the webview can be deinitialized.
    ///
    /// - Parameter webView: The web-view to stop tracking.
    @objc
    public static func disable(
        webView: WKWebView
    ) {
        WebViewTracking.disable(webView: webView)
    }
}
#endif
