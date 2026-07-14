/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if canImport(WebKit)
import Foundation
import WebKit
@testable import OpenObserveWebViewTracking

public final class WKUserContentControllerMock: WKUserContentController {
    private var handlers: [String: WKScriptMessageHandler] = [:]

    override public func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String) {
        handlers[name] = scriptMessageHandler
    }

    override public func removeScriptMessageHandler(forName name: String) {
        handlers[name] = nil
    }

    public func send(body: Any, from webView: WKWebView? = nil) {
        let handler = handlers[DDScriptMessageHandler.name]
        let message = WKScriptMessageMock(body: body, name: DDScriptMessageHandler.name, webView: webView)
        handler?.userContentController(self, didReceive: message)
    }

    public func scriptMessageHandler(forName name: String) -> WKScriptMessageHandler? {
        handlers[name]
    }

    public func flush() {
        let handler = handlers[DDScriptMessageHandler.name] as? DDScriptMessageHandler
        handler?.flush()
    }
}

private final class WKScriptMessageMock: WKScriptMessage {
    private let _body: Any
    private let _name: String
    private weak var _webView: WKWebView?

    init(body: Any, name: String, webView: WKWebView? = nil) {
        _body = body
        _name = name
        _webView = webView
    }

    override var body: Any { _body }
    override var name: String { _name }
    override weak var webView: WKWebView? { _webView }
}

#endif
