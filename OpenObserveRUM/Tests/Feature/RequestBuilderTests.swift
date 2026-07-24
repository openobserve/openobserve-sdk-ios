/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal
@testable import OpenObserveRUM

class RequestBuilderTests: XCTestCase {
    private let mockEvents: [Event] = [
        .init(data: "event 1".utf8Data),
        .init(data: "event 2".utf8Data),
        .init(data: "event 3".utf8Data)
    ]

    func testItCreatesPOSTRequest() throws {
        // Given
        let builder = RequestBuilder(
            customIntakeURL: nil,
            eventsFilter: .init(telemetry: TelemetryMock()),
            telemetry: NOPTelemetry()
        )

        // When
        let request = try builder.request(for: mockEvents, with: .mockAny(), execution: .mockAny())

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
    }

    func testItSetsRUMIntakeURL() {
        // Given
        let builder = RequestBuilder(
            customIntakeURL: nil,
            eventsFilter: .init(telemetry: TelemetryMock()),
            telemetry: NOPTelemetry()
        )

        // When
        func url(for site: OpenObserveSite) -> String {
            let request = try! builder.request(for: mockEvents, with: .mockWith(site: site), execution: .mockAny())
            return request.url!.absoluteStringWithoutQuery!
        }

        // Then
        XCTAssertEqual(url(for: .us1), "https://browser-intake-openobserve.ai/api/v2/rum")
        XCTAssertEqual(url(for: .us3), "https://browser-intake-us3-openobserve.ai/api/v2/rum")
        XCTAssertEqual(url(for: .us5), "https://browser-intake-us5-openobserve.ai/api/v2/rum")
        XCTAssertEqual(url(for: .eu1), "https://browser-intake-openobserve.eu/api/v2/rum")
        XCTAssertEqual(url(for: .ap1), "https://browser-intake-ap1-openobserve.ai/api/v2/rum")
        XCTAssertEqual(url(for: .ap2), "https://browser-intake-ap2-openobserve.ai/api/v2/rum")
        XCTAssertEqual(url(for: .us1_fed), "https://browser-intake-openobserve-gov.com/api/v2/rum")
        XCTAssertEqual(url(for: .us2_fed), "https://browser-intake-us2-openobserve-gov.com/api/v2/rum")
    }

    func testItSetsCustomIntakeURL() throws {
        // Given
        let randomURL: URL = .mockRandom()
        let builder = RequestBuilder(
            customIntakeURL: randomURL,
            eventsFilter: .init(telemetry: TelemetryMock()),
            telemetry: NOPTelemetry()
        )

        // When
        func url(for site: OpenObserveSite) -> String {
            let request = try! builder.request(for: mockEvents, with: .mockWith(site: site), execution: .mockAny())
            return request.url!.absoluteStringWithoutQuery!
        }

        // Then
        let expectedURL = randomURL.absoluteStringWithoutQuery
        XCTAssertEqual(url(for: .us1), expectedURL)
        XCTAssertEqual(url(for: .us3), expectedURL)
        XCTAssertEqual(url(for: .us5), expectedURL)
        XCTAssertEqual(url(for: .eu1), expectedURL)
        XCTAssertEqual(url(for: .ap1), expectedURL)
        XCTAssertEqual(url(for: .ap2), expectedURL)
        XCTAssertEqual(url(for: .us1_fed), expectedURL)
        XCTAssertEqual(url(for: .us2_fed), expectedURL)
    }

    func testItSetsRUMQueryParameters() throws {
        let randomSource: String = .mockRandom(among: .alphanumerics)
        let randomVersion: String = .mockRandom(among: .decimalDigits)
        let randomService: String = .mockRandom(among: .alphanumerics)
        let randomEnv: String = .mockRandom(among: .alphanumerics)
        let randomSDKVersion: String = .mockRandom(among: .alphanumerics)
        let randomAttempt: UInt = .mockRandom()
        let randomStatus: Int = .mockRandom()

        // Given
        let builder = RequestBuilder(
            customIntakeURL: nil,
            eventsFilter: .init(telemetry: TelemetryMock()),
            telemetry: NOPTelemetry()
        )
        let context: OpenObserveContext = .mockWith(
            service: randomService,
            env: randomEnv,
            version: randomVersion,
            source: randomSource,
            sdkVersion: randomSDKVersion
        )
        let execution: ExecutionContext = .mockWith(previousResponseCode: randomStatus, attempt: randomAttempt)

        // When
        let request = try builder.request(for: mockEvents, with: context, execution: execution)

        // Then
        let expextedQuery = "o2source=\(randomSource)&o2tags=retry_count:\(randomAttempt),retry_after:\(randomStatus)"
        XCTAssertEqual(request.url?.query, expextedQuery)
    }

    func testItSetsRUMHTTPHeaders() throws {
        let randomApplicationName: String = .mockRandom(among: .alphanumerics)
        let randomVersion: String = .mockRandom(among: .decimalDigits)
        let randomService: String = .mockRandom(among: .alphanumerics)
        let randomEnv: String = .mockRandom(among: .alphanumerics)
        let randomSource: String = .mockRandom(among: .alphanumerics)
        let randomOrigin: String = .mockRandom(among: .alphanumerics)
        let randomSDKVersion: String = .mockRandom(among: .alphanumerics)
        let randomClientToken: String = .mockRandom()
        let randomDeviceName: String = .mockRandom()
        let randomDeviceOSName: String = .mockRandom()
        let randomDeviceOSVersion: String = .mockRandom()

        // Given
        let builder = RequestBuilder(
            customIntakeURL: nil,
            eventsFilter: .init(telemetry: TelemetryMock()),
            telemetry: NOPTelemetry()
        )
        let context: OpenObserveContext = .mockWith(
            clientToken: randomClientToken,
            service: randomService,
            env: randomEnv,
            version: randomVersion,
            source: randomSource,
            sdkVersion: randomSDKVersion,
            ciAppOrigin: randomOrigin,
            applicationName: randomApplicationName,
            device: .mockWith(name: randomDeviceName),
            os: .mockWith(
                name: randomDeviceOSName,
                version: randomDeviceOSVersion
            )
        )

        // When
        let request = try builder.request(for: mockEvents, with: context, execution: .mockAny())

        // Then
        XCTAssertEqual(
            request.allHTTPHeaderFields?["User-Agent"],
            """
            \(randomApplicationName)/\(randomVersion) CFNetwork (\(randomDeviceName); \(randomDeviceOSName)/\(randomDeviceOSVersion))
            """
        )
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "text/plain;charset=UTF-8")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Encoding"], "deflate")
        XCTAssertEqual(request.allHTTPHeaderFields?["O2-API-KEY"], randomClientToken)
        XCTAssertEqual(request.allHTTPHeaderFields?["O2-EVP-ORIGIN"], randomOrigin)
        XCTAssertEqual(request.allHTTPHeaderFields?["O2-EVP-ORIGIN-VERSION"], randomSDKVersion)
        XCTAssertEqual(request.allHTTPHeaderFields?["O2-REQUEST-ID"]?.matches(regex: .uuidRegex), true)
    }

    func testItSetsHTTPBodyInExpectedFormat() throws {
        // Given
        let builder = RequestBuilder(
            customIntakeURL: nil,
            eventsFilter: .init(telemetry: TelemetryMock()),
            telemetry: NOPTelemetry()
        )

        // When
        let request = try builder.request(for: mockEvents, with: .mockAny(), execution: .mockAny())

        // Then
        let decompressed = zlib.decode(request.httpBody!)!
        let actual = String(data: decompressed, encoding: .utf8)
        let expected = """
        event 1
        event 2
        event 3
        """
        XCTAssertEqual(expected, actual, "It must separate each event with newline character")
    }

    func testItSetsNoRetryQueryParametersOnFirstRequest() throws {
        // Given
        let randomSource: String = .mockRandom(among: .alphanumerics)
        let builder = RequestBuilder(customIntakeURL: nil, eventsFilter: .init(telemetry: TelemetryMock()), telemetry: NOPTelemetry())
        let context: OpenObserveContext = .mockWith(source: randomSource)
        let execution: ExecutionContext = .mockWith(previousResponseCode: nil, attempt: 0)

        // When
        let request = try builder.request(for: mockEvents, with: context, execution: execution)

        // Then
        XCTAssertEqual(request.url?.query, "o2source=\(randomSource)") // no o2tags on first request
    }

    func testItSetsRetryQueryParametersOnNetworkErrorRetry() throws {
        // Given
        let randomSource: String = .mockRandom(among: .alphanumerics)
        let builder = RequestBuilder(customIntakeURL: nil, eventsFilter: .init(telemetry: TelemetryMock()), telemetry: NOPTelemetry())
        let context: OpenObserveContext = .mockWith(source: randomSource)
        let execution: ExecutionContext = .mockWith(previousResponseCode: nil, attempt: 1) // network error retry has no response code

        // When
        let request = try builder.request(for: mockEvents, with: context, execution: execution)

        // Then
        XCTAssertEqual(request.url?.query, "o2source=\(randomSource)&o2tags=retry_count:1") // no retry_after without response code
    }
}
