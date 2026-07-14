/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

/// An identifier for the current application process. Being static variable, it is the same for all instances of RUM within the same
/// process but different for RUM instances after app restart.
///
/// Use this identifier to distinguish data collected between different process instances and between SDK instances:
/// - Data collected in two processes will have different `processID`.
/// - Data collected in two SDK instances within the same process will share the same `processID`.
///
/// Example use case in fatal App Hangs tracking:
/// - SDK started → RUM enabled → [hang occurs] → pending App Hang saved → SDK stopped → SDK started again → RUM enabled again → pending App Hang loaded
/// - When restarting RUM , the `processID` check ensures dropping pending hang from the previous instance, preventing false "fatal" hang detection.
internal let currentProcessID = UUID()
