/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

#import <XCTest/XCTest.h>

#if TARGET_OS_IOS || TARGET_OS_VISION


@import OpenObserveWebViewTracking;
@import WebKit;

@interface WebViewMock: WKWebView
@end

@implementation WebViewMock
@end

// MARK: - DDWebViewTracking tests

@interface DDWebViewTracking_apiTests : XCTestCase
@end

/*
 * `WebViewTracking` APIs smoke tests - minimal assertions, mainly check if the interface is available to Objc.
 */
@implementation DDWebViewTracking_apiTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"

- (void)testDDWebViewTrackingAPI {
    WebViewMock *webView = [WebViewMock new];
    [DDWebViewTracking enableWithWebView:webView
                                   hosts:[NSSet<NSString*> setWithArray:@[@"host1.com", @"host2.com"]]
                          logsSampleRate:100.0
    ];
    [DDWebViewTracking disableWithWebView:webView];
}

#pragma clang diagnostic pop

@end

#endif
