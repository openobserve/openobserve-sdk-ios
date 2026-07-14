/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

#import <XCTest/XCTest.h>
@import OpenObserveTrace;

@interface DDW3CHTTPHeadersWriter_apiTests : XCTestCase
@end

/*
 * Objc APIs smoke tests - only check if the interface is available to Objc.
 */
@implementation DDW3CHTTPHeadersWriter_apiTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"

- (void)testInitWithSamplingRate {
    [[DDW3CHTTPHeadersWriter alloc] initWithTraceContextInjection:DDTraceContextInjectionAll];
}

#pragma clang diagnostic pop

@end
