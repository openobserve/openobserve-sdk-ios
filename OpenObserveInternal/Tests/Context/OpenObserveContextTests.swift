/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import OpenObserveInternal
import TestUtilities
import XCTest

final class OpenObserveContextTests: XCTestCase {
    // MARK: - Test o2tags

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
        let ooTagsArray = ooContext.ooTags.split(separator: ",")

        let ooTags = ooTagsArray.reduce(into: [:]) {
            let item = $1.split(separator: ":")
            $0[String(item[0])] = String(item[1])
        }

        XCTAssertEqual(ooTags["service"] as! String, service)
        XCTAssertEqual(ooTags["env"] as! String, env)
        XCTAssertEqual(ooTags["version"] as! String, version)
        XCTAssertEqual(ooTags["sdk_version"] as! String, sdkVersion)
        XCTAssertEqual(ooTags["variant"] as! String, variant)
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
        let ooTagsArray = ooContext.ooTags.split(separator: ",")

        let ooTags = ooTagsArray.reduce(into: [:]) {
            let item = $1.split(separator: ":")
            $0[String(item[0])] = String(item[1])
        }

        XCTAssertEqual(ooTags["service"] as! String, "servicewithcolons")
        XCTAssertEqual(ooTags["env"] as! String, "proddev")
        XCTAssertEqual(ooTags["version"] as! String, "123")
        XCTAssertEqual(ooTags["sdk_version"] as! String, "321")
        XCTAssertEqual(ooTags["variant"] as! String, "variantwithcommas")
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
        let ooTagsArray = ooContext.ooTags.split(separator: ",")

        let ooTags = ooTagsArray.reduce(into: [:]) {
            let item = $1.split(separator: ":")
            $0[String(item[0])] = String(item[1])
        }

        XCTAssertEqual(ooTags["service"] as! String, service)
        XCTAssertEqual(ooTags["env"] as! String, env)
        XCTAssertEqual(ooTags["version"] as! String, version)
        XCTAssertEqual(ooTags["sdk_version"] as! String, sdkVersion)
        XCTAssertNil(ooTags["variant"])
    }

    // MARK: - ooTags caching

    func testDDTagsUpdatesWhenVersionChanges() throws {
        // Given
        var context: OpenObserveContext = .mockWith(version: "1.0.0")
        let originalDDTags = context.ooTags
        XCTAssertTrue(originalDDTags.contains("version:1.0.0"))

        // When
        context.version = "2.0.0"

        // Then
        XCTAssertTrue(context.ooTags.contains("version:2.0.0"))
        XCTAssertFalse(context.ooTags.contains("version:1.0.0"))
        XCTAssertNotEqual(context.ooTags, originalDDTags)
    }

    func testDDTagsSanitizesVersionOnUpdate() throws {
        // Given
        var context: OpenObserveContext = .mockWith(version: "1.0.0")

        // When
        context.version = "2,0:0"

        // Then
        XCTAssertEqual(context.version, "200")
        XCTAssertTrue(context.ooTags.contains("version:200"))
    }
}
