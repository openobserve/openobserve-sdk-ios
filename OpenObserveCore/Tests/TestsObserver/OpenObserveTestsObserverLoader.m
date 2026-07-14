/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "OpenObserveCoreTests-Swift.h"

/// This code runs when the `OpenObserveTests` bundle is loaded into memory and tests start.
/// Reference: https://developer.apple.com/documentation/objectivec/nsobject/1418815-load
__attribute__((constructor)) static void initialize_FrameworkLoadHandler(void) {
    [OpenObserveTestsObserver startObserving];
}
