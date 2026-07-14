/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveCrashReporting
@testable import OpenObserveInternal

/// Tests integration of `OpenObserveCore` and `OpenObserveCrashReporting` for backtrace generation.
class GeneratingBacktraceTests: XCTestCase {
    private var core: OpenObserveCoreProxy! // swiftlint:disable:this implicitly_unwrapped_optional

    override func setUp() {
        super.setUp()
        core = OpenObserveCoreProxy(context: .mockWith(trackingConsent: .granted))
    }

    override func tearDownWithError() throws {
        try core.flushAndTearDown()
        core = nil
        super.tearDown()
    }

    func testGeneratingBacktraceOfTheCurrentThread() throws {
        #if os(watchOS)
        throw XCTSkip("Backtrace generation is not supported on watchOS")
        #endif
        // Given
        CrashReporting.enable(in: core)
        XCTAssertNotNil(core.get(feature: BacktraceReportingFeature.self), "`BacktraceReportingFeature` must be registered")

        // When
        let backtrace = try XCTUnwrap(core.backtraceReporter.generateBacktrace())

        // Then
        XCTAssertGreaterThan(backtrace.threads.count, 0, "Some thread(s) should be recorded")
        XCTAssertGreaterThan(backtrace.binaryImages.count, 0, "Some binary image(s) should be recorded")
        XCTAssertFalse(backtrace.threads.contains(where: { $0.crashed }), "No thread should be marked as crashed")

        XCTAssertTrue(
            backtrace.stack.contains("OpenObserveIntegrationTests"),
            "Backtrace stack should include at least one frame from `OpenObserveCoreTests` image"
        )
        XCTAssertTrue(
            backtrace.stack.contains("XCTest"),
            "Backtrace stack should include at least one frame from `XCTest` image"
        )
        XCTAssertTrue(
            backtrace.binaryImages.contains(where: { $0.libraryName == "OpenObserveIntegrationTests" }),
            "Backtrace should include the image for `OpenObserveCoreTests`"
        )
        XCTAssertTrue(
            // Assert on prefix as it is `XCTestCore` on iOS 15+ and `XCTest` earlier:
            backtrace.binaryImages.contains(where: { $0.libraryName.hasPrefix("XCTest") }),
            "Backtrace should include the image for `XCTest`"
        )
    }

    func testGeneratingBacktraceOfTheMainThread() throws {
        #if os(watchOS)
        throw XCTSkip("Backtrace generation is not supported on watchOS")
        #endif
        // Given
        CrashReporting.enable(in: core)

        // When
        XCTAssertTrue(Thread.current.isMainThread)
        let threadID = Thread.currentThreadID
        let backtrace = try XCTUnwrap(core.backtraceReporter.generateBacktrace(threadID: threadID))

        // Then
        XCTAssertFalse(backtrace.stack.isEmpty)
        XCTAssertTrue(backtrace.stack.contains("XCTestCore"), "Main thread stack should include XCTestCore symbols")
    }

    func testGeneratingBacktraceOfSecondaryThread() throws {
        #if os(watchOS)
        throw XCTSkip("Backtrace generation is not supported on watchOS")
        #endif
        // Given
        CrashReporting.enable(in: core)

        // When
        let semaphore = DispatchSemaphore(value: 0)
        var threadID: ThreadID?

        let thread = Thread {
            XCTAssertFalse(Thread.current.isMainThread)
            threadID = Thread.currentThreadID
            semaphore.signal()
            Thread.sleep(forTimeInterval: 1)
        }

        thread.start()
        XCTAssertEqual(semaphore.wait(timeout: .now() + 5), .success)
        thread.cancel()

        let backtrace = try XCTUnwrap(core.backtraceReporter.generateBacktrace(threadID: threadID!))

        // Then
        XCTAssertFalse(backtrace.stack.isEmpty)
        XCTAssertFalse(backtrace.stack.contains("UIKit"), "Secondary thread stack should NOT include UIKit symbols")
    }
}
