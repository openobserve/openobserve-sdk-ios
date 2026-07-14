/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

private class ModuleClass { }

extension Bundle {
    static var module: Bundle { Bundle(for: ModuleClass.self) }
}

public let bundle: Bundle = .module
