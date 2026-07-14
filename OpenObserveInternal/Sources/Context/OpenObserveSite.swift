/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

public enum OpenObserveSite: String {
    /// US based servers.
    /// Sends data to [app.openobserve.ai](https://app.openobserve.ai/).
    case us1
    /// US based servers.
    /// Sends data to [app.openobserve.ai](https://us3.openobserve.ai/).
    case us3
    /// US based servers.
    /// Sends data to [app.openobserve.ai](https://us5.openobserve.ai/).
    case us5
    /// Europe based servers.
    /// Sends data to [app.openobserve.eu](https://app.openobserve.eu/).
    case eu1
    /// Asia based servers.
    /// Sends data to [ap1.openobserve.ai](https://ap1.openobserve.ai/).
    case ap1
    /// Asia based servers.
    /// Sends data to [ap2.openobserve.ai](https://ap2.openobserve.ai/).
    case ap2
    /// US based servers, FedRAMP compatible.
    /// Sends data to [app.ddog-gov.com](https://app.ddog-gov.com/).
    case us1_fed
    /// US based servers, FedRAMP compatible.
    /// Sends data to [us2.ddog-gov.com](https://us2.ddog-gov.com/).
    case us2_fed
}

extension OpenObserveSite {
    public var endpoint: URL {
        switch self {
        // swiftlint:disable force_unwrapping
        case .us1: return URL(string: "https://browser-intake-openobserve.ai/")!
        case .us3: return URL(string: "https://browser-intake-us3-openobserve.ai/")!
        case .us5: return URL(string: "https://browser-intake-us5-openobserve.ai/")!
        case .eu1: return URL(string: "https://browser-intake-openobserve.eu/")!
        case .ap1: return URL(string: "https://browser-intake-ap1-openobserve.ai/")!
        case .ap2: return URL(string: "https://browser-intake-ap2-openobserve.ai/")!
        case .us1_fed: return URL(string: "https://browser-intake-ddog-gov.com/")!
        case .us2_fed: return URL(string: "https://browser-intake-us2-ddog-gov.com/")!
        // swiftlint:enable force_unwrapping
        }
    }
}
