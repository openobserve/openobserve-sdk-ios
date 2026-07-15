/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation

/// Type that acts as a generic extension point for all `OpenObserveExtended` types.
public struct OpenObserveExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    public private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    public init(_ type: ExtendedType) {
        self.type = type
    }
}

/// Protocol describing the `dd` extension points for OpenObserve extended types.
public protocol OpenObserveExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static OpenObserve extension point.
    static var dd: OpenObserveExtension<ExtendedType>.Type { get set }
    /// Instance OpenObserve extension point.
    var dd: OpenObserveExtension<ExtendedType> { get set }
}

extension OpenObserveExtended {
    /// Static OpenObserve extension point.
    public static var dd: OpenObserveExtension<Self>.Type {
        get { OpenObserveExtension<Self>.self }
        set {}
    }

    /// Instance OpenObserve extension point.
    public var dd: OpenObserveExtension<Self> {
        get { OpenObserveExtension(self) }
        set {}
    }
}

extension Array: OpenObserveExtended {}
extension Dictionary: OpenObserveExtended {}
