/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-2020 OpenObserve, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal

@testable import OpenObserveRUM

class TelemetryReceiverTests: XCTestCase {
    // MARK: - Thread safety

    func testSendTelemetryAndReset_onAnyThread() throws {
        let core = OpenObserveCoreProxy(
            context: .mockWith(
                version: .mockRandom(),
                source: .mockAnySource(),
                sdkVersion: .mockRandom()
            )
        )
        defer { XCTAssertNoThrow(try core.flushAndTearDown()) }

        RUM.enable(with: .mockAny(), in: core)

        // swiftlint:disable opening_brace
        callConcurrently(
            closures: [
                { core.telemetry.debug(id: .mockRandom(), message: "telemetry debug") },
                { core.telemetry.error(id: .mockRandom(), message: "telemetry error", kind: "error.kind", stack: "error.stack") },
                { core.telemetry.configuration(batchSize: .mockRandom()) },
                { core.set(context: RUMCoreContext.mockRandom()) }
            ],
            iterations: 50
        )
        // swiftlint:enable opening_brace
    }
}
