/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveInternal
import TestUtilities
import XCTest

final class OpenObserveContextTests: XCTestCase {
    // MARK: - Test ddtags

    func testOpenObserveDDTags() throws {
        // Given
        let service: String = .mockRandom()
        let env: String = .mockRandom()
        let version: String = .mockRandom()
        let sdkVersion: String = .mockRandom()
        let variant: String = .mockRandom()
        let ooContext: OpenObserveContext = .mockWith(
            service: service,
            env: env,
            version: version,
            variant: variant,
            sdkVersion: sdkVersion
        )

        // Then
        let ddTagsArray = ooContext.ddTags.split(separator: ",")

        let ddTags = ddTagsArray.reduce(into: [:]) {
            let item = $1.split(separator: ":")
            $0[String(item[0])] = String(item[1])
        }

        XCTAssertEqual(ddTags["service"] as! String, service)
        XCTAssertEqual(ddTags["env"] as! String, env)
        XCTAssertEqual(ddTags["version"] as! String, version)
        XCTAssertEqual(ddTags["sdk_version"] as! String, sdkVersion)
        XCTAssertEqual(ddTags["variant"] as! String, variant)
    }

    func testOpenObserveSanitizedDDTags() throws {
        // Given
        let service = "service:with:colons"
        let env = "prod,dev"
        let version = "1,2,3"
        let sdkVersion = "3,2,1"
        let variant = "variant,with,commas:"
        let ooContext: OpenObserveContext = .mockWith(
            service: service,
            env: env,
            version: version,
            variant: variant,
            sdkVersion: sdkVersion
        )

        // Then
        let ddTagsArray = ooContext.ddTags.split(separator: ",")

        let ddTags = ddTagsArray.reduce(into: [:]) {
            let item = $1.split(separator: ":")
            $0[String(item[0])] = String(item[1])
        }

        XCTAssertEqual(ddTags["service"] as! String, "servicewithcolons")
        XCTAssertEqual(ddTags["env"] as! String, "proddev")
        XCTAssertEqual(ddTags["version"] as! String, "123")
        XCTAssertEqual(ddTags["sdk_version"] as! String, "321")
        XCTAssertEqual(ddTags["variant"] as! String, "variantwithcommas")
    }

    func testOpenObserveDDTagsWithoutVariant() throws {
        // Given
        let service: String = .mockRandom()
        let env: String = .mockRandom()
        let version: String = .mockRandom()
        let sdkVersion: String = .mockRandom()
        let ooContext: OpenObserveContext = .mockWith(
            service: service,
            env: env,
            version: version,
            variant: nil,
            sdkVersion: sdkVersion
        )

        // Then
        let ddTagsArray = ooContext.ddTags.split(separator: ",")

        let ddTags = ddTagsArray.reduce(into: [:]) {
            let item = $1.split(separator: ":")
            $0[String(item[0])] = String(item[1])
        }

        XCTAssertEqual(ddTags["service"] as! String, service)
        XCTAssertEqual(ddTags["env"] as! String, env)
        XCTAssertEqual(ddTags["version"] as! String, version)
        XCTAssertEqual(ddTags["sdk_version"] as! String, sdkVersion)
        XCTAssertNil(ddTags["variant"])
    }

    // MARK: - ddTags caching

    func testDDTagsUpdatesWhenVersionChanges() throws {
        // Given
        var context: OpenObserveContext = .mockWith(version: "1.0.0")
        let originalDDTags = context.ddTags
        XCTAssertTrue(originalDDTags.contains("version:1.0.0"))

        // When
        context.version = "2.0.0"

        // Then
        XCTAssertTrue(context.ddTags.contains("version:2.0.0"))
        XCTAssertFalse(context.ddTags.contains("version:1.0.0"))
        XCTAssertNotEqual(context.ddTags, originalDDTags)
    }

    func testDDTagsSanitizesVersionOnUpdate() throws {
        // Given
        var context: OpenObserveContext = .mockWith(version: "1.0.0")

        // When
        context.version = "2,0:0"

        // Then
        XCTAssertEqual(context.version, "200")
        XCTAssertTrue(context.ddTags.contains("version:200"))
    }
}
