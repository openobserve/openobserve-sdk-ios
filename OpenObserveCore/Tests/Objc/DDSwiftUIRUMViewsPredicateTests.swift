/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if !os(watchOS)

import XCTest
import TestUtilities

@_spi(objc)
@testable import OpenObserveRUM

class DDSwiftUIRUMViewsPredicateTests: XCTestCase {
    func testGivenDefaultPredicate_whenAskingForExtractedViewName_itReturnsView() {
        // Given
        let predicate = objc_DefaultSwiftUIRUMViewsPredicate()

        // When
        let rumView = predicate.rumView(for: "SwiftUIView")

        // Then
        XCTAssertEqual(rumView?.name, "SwiftUIView")
        XCTAssertTrue(rumView!.attributes.isEmpty)
    }
}

#endif
