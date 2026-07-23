/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation
import OpenObserveInternal

public class FeatureRequestBuilderMock: FeatureRequestBuilder {
    private let factory: (([Event], OpenObserveContext) throws -> URLRequest)

    public init(factory: @escaping (([Event], OpenObserveContext) throws -> URLRequest) = { _, _ in .mockAny() }) {
        self.factory = factory
    }

    public convenience init(request: URLRequest) {
        self.init(factory: { _, _ in request })
    }

    public func request(
        for events: [Event],
        with context: OpenObserveContext,
        execution: ExecutionContext
    ) throws -> URLRequest {
        return try factory(events, context)
    }
}

public  class FeatureRequestBuilderSpy: FeatureRequestBuilder {
    /// Stores the parameters passed to the `request(for:with:)` method.
    @ReadWriteLock
    public private(set) var requestParameters: [(events: [Event], context: OpenObserveContext)] = []

    /// A closure that is called when a request is about to be created in the `request(for:with:)` method.
    @ReadWriteLock
    public var onRequest: ((_ events: [Event], _ context: OpenObserveContext) -> Void)?

    public init() {}

    public func request(
        for events: [Event],
        with context: OpenObserveContext,
        execution: ExecutionContext
    ) throws -> URLRequest {
        requestParameters.append((events: events, context: context))
        onRequest?(events, context)
        return .mockAny()
    }
}

public struct FailingRequestBuilderMock: FeatureRequestBuilder {
    let error: Error

    public init(error: Error) {
        self.error = error
    }

    public func request(
        for events: [Event],
        with context: OpenObserveContext,
        execution: ExecutionContext
    ) throws -> URLRequest {
        throw error
    }
}

extension URLRequestBuilder.QueryItem: RandomMockable, AnyMockable {
    public static func mockRandom() -> Self {
        let all: [URLRequestBuilder.QueryItem] = [
            .oosource(source: .mockRandom()),
            .ootags(tags: .mockRandom()),
        ]
        return all.randomElement()!
    }

    public static func mockAny() -> Self {
        return .oosource(source: .mockRandom(among: .alphanumerics))
    }
}

extension URLRequestBuilder.HTTPHeader: RandomMockable, AnyMockable {
    public static func mockRandom() -> Self {
        let all: [URLRequestBuilder.HTTPHeader] = [
            .contentTypeHeader(contentType: Bool.random() ? .applicationJSON : .textPlainUTF8),
            .userAgentHeader(
                appName: .mockRandom(among: .alphanumerics),
                appVersion: .mockRandom(among: .alphanumerics),
                device: .mockAny(),
                os: .mockAny()
            ),
            .o2APIKeyHeader(clientToken: .mockRandom(among: .alphanumerics)),
            .ooEVPOriginHeader(source: .mockRandom(among: .alphanumerics)),
            .ooEVPOriginVersionHeader(sdkVersion: .mockRandom(among: .alphanumerics)),
            .ooRequestIDHeader()
        ]
        return all.randomElement()!
    }

    public static func mockAny() -> Self {
        return .ooEVPOriginVersionHeader(sdkVersion: "1.2.3")
    }
}

extension URLRequestBuilder: AnyMockable {
    public static func mockAny() -> Self {
        return mockWith()
    }

    public static func mockWith(
        url: URL = .mockAny(),
        queryItems: [QueryItem] = [],
        headers: [HTTPHeader] = []
    ) -> Self {
        return URLRequestBuilder(
            url: url,
            queryItems: queryItems,
            headers: headers
        )
    }
}
