/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal
@_spi(objc)
@testable import OpenObserveCore

final class DDURLSessionInstrumentationConfigurationTests: XCTestCase {
    private var objc = objc_URLSessionInstrumentationConfiguration(delegateClass: SessionDataDelegateMock.self)
    private var swift: URLSessionInstrumentation.Configuration { objc.swiftConfig }

    func testDelegateClass() {
        XCTAssertTrue(objc.delegateClass === SessionDataDelegateMock.self)
    }

    func testFirstPartyHostsTracing() {
        objc.setFirstPartyHostsTracing(.init(hosts: ["example.com", "example.org"]))
        DDAssertReflectionEqual(swift.firstPartyHostsTracing, .trace(hosts: ["example.com", "example.org"]))

        objc.setFirstPartyHostsTracing(.init(hostsWithHeaderTypes: ["example.com": [.b3, .datadog]]))
        DDAssertReflectionEqual(swift.firstPartyHostsTracing, .traceWithHeaders(hostsWithHeaders: ["example.com": [.b3, .datadog]]))
    }
}
