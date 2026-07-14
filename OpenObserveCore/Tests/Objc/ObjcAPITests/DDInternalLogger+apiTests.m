/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

#import <XCTest/XCTest.h>
@import OpenObserveInternal;

@interface DDInternalLogger_apiTests : XCTestCase
@end

/*
 * `DDInternalLogger` APIs smoke tests - only check if the interface is available to Objc.
 */
@implementation DDInternalLogger_apiTests

- (void)testDDInternalLogger {

    [DDInternalLogger consolePrint:@"" :DDCoreLoggerLevelWarn];
    [DDInternalLogger telemetryDebugWithId:@"" message:@""];
    [DDInternalLogger telemetryErrorWithId:@"" message:@"" kind:@"" stack:@""];
}

@end
