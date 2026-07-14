/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
import TestUtilities
@testable import OpenObserveCore

class FeatureContextTests: XCTestCase {
    func testFeatureContextSharing() throws {
        // Given
        let core = OpenObserveCore(
            directory: temporaryCoreDirectory,
            dateProvider: SystemDateProvider(),
            initialConsent: .granted,
            performance: .mockAny(),
            httpClient: HTTPClientMock(),
            encryption: nil,
            contextProvider: .mockAny(),
            applicationVersion: .mockAny(),
            maxBatchesPerUpload: .mockRandom(min: 1, max: 100),
            backgroundTasksEnabled: .mockAny()
        )

        defer { temporaryCoreDirectory.delete() }

        struct ContextMock: AdditionalContext {
            static let key: String = "test"
            let attribute: [String: String]
        }

        // When
        let attributes = ["key": "value"]
        core.set(context: ContextMock(attribute: attributes))

        // Then
        let context = core.contextProvider.read()
        XCTAssertEqual(context.additionalContext(ofType: ContextMock.self)?.attribute, attributes)
    }
}
