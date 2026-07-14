/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
@_spi(objc)
import OpenObserveInternal

@objc(DDTrackingConsent)
@objcMembers
@_spi(objc)
public final class objc_TrackingConsent: NSObject {
    internal let sdkConsent: TrackingConsent

    internal init(sdkConsent: TrackingConsent) {
        self.sdkConsent = sdkConsent
    }

    // MARK: - Public

    public static func granted() -> objc_TrackingConsent { .init(sdkConsent: .granted) }

    public static func notGranted() -> objc_TrackingConsent { .init(sdkConsent: .notGranted) }

    public static func pending() -> objc_TrackingConsent { .init(sdkConsent: .pending) }
}

@objc(DDOpenObserve)
@objcMembers
@_spi(objc)
public final class objc_OpenObserve: NSObject {
    // MARK: - Public

    public static func initialize(
        configuration: objc_Configuration,
        trackingConsent: objc_TrackingConsent
    ) {
        OpenObserve.initialize(
            with: configuration.sdkConfiguration,
            trackingConsent: trackingConsent.sdkConsent
        )
    }

    public static func setVerbosityLevel(_ verbosityLevel: objc_CoreLoggerLevel) {
        switch verbosityLevel {
        case .debug: OpenObserve.verbosityLevel = .debug
        case .warn: OpenObserve.verbosityLevel = .warn
        case .error: OpenObserve.verbosityLevel = .error
        case .critical: OpenObserve.verbosityLevel = .critical
        case .none: OpenObserve.verbosityLevel = nil
        }
    }

    public static func verbosityLevel() -> objc_CoreLoggerLevel {
        switch OpenObserve.verbosityLevel {
        case .debug: return .debug
        case .warn: return .warn
        case .error: return .error
        case .critical: return .critical
        case .none: return .none
        }
    }

    public static func setUserInfo(userId: String, name: String? = nil, email: String? = nil, extraInfo: [String: Any] = [:]) {
        OpenObserve.setUserInfo(id: userId, name: name, email: email, extraInfo: extraInfo.dd.swiftAttributes)
    }

    public static func clearUserInfo() {
        OpenObserve.clearUserInfo()
    }

    public static func addUserExtraInfo(_ extraInfo: [String: Any]) {
        OpenObserve.addUserExtraInfo(extraInfo.dd.swiftAttributes)
    }

    public static func setAccountInfo(accountId: String, name: String? = nil, extraInfo: [String: Any] = [:]) {
        OpenObserve.setAccountInfo(id: accountId, name: name, extraInfo: extraInfo.dd.swiftAttributes)
    }

    public static func addAccountExtraInfo(_ extraInfo: [String: Any]) {
        OpenObserve.addAccountExtraInfo(extraInfo.dd.swiftAttributes)
    }

    public static func clearAccountInfo() {
        OpenObserve.clearAccountInfo()
    }

    public static func setTrackingConsent(consent: objc_TrackingConsent) {
        OpenObserve.set(trackingConsent: consent.sdkConsent)
    }

    public static func isInitialized() -> Bool {
        return OpenObserve.isInitialized()
    }

    public static func stopInstance() {
        OpenObserve.stopInstance()
    }

    public static func clearAllData() {
        OpenObserve.clearAllData()
    }

#if DD_SDK_COMPILED_FOR_TESTING
    public static func flushAndDeinitialize() {
        OpenObserve.flushAndDeinitialize()
    }
#endif
}
