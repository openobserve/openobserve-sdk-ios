/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

#import <XCTest/XCTest.h>
@import OpenObserveCore;
@import OpenObserveInternal;

@interface DDOpenObserve_apiTests : XCTestCase
@end

/*
 * Objc APIs smoke tests - only check if the interface is available to Objc.
 */
@implementation DDOpenObserve_apiTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"

- (void)testDDTrackingConsentAPI {
    [DDTrackingConsent granted];
    [DDTrackingConsent notGranted];
    [DDTrackingConsent pending];
}

- (void)testDDOpenObserve {
    DDConfiguration *configuration = [[DDConfiguration alloc] initWithClientToken:@"abc" env:@"def"];

    [DDOpenObserve initializeWithConfiguration:configuration trackingConsent:[DDTrackingConsent notGranted]];

    [DDOpenObserve isInitialized];

    DDCoreLoggerLevel verbosity = [DDOpenObserve verbosityLevel];
    [DDOpenObserve setVerbosityLevel:verbosity];

    [DDOpenObserve setUserInfoWithUserId:@"" name:@"" email:@"" extraInfo:@{}];
    [DDOpenObserve addUserExtraInfo:@{}];
    [DDOpenObserve setTrackingConsentWithConsent:[DDTrackingConsent notGranted]];

    [DDOpenObserve clearAllData];
    [DDOpenObserve stopInstance];
}

#pragma clang diagnostic pop

@end
