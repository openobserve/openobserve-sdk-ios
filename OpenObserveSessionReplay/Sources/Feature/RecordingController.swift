/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)
import Foundation
import OpenObserveInternal

internal protocol RecordingController: AnyObject {
    var replaySampleRate: SampleRate { get }
    var textAndInputPrivacy: TextAndInputPrivacyLevel { get }
    var imagePrivacy: ImagePrivacyLevel { get }
    var touchPrivacy: TouchPrivacyLevel { get }

    func startRecording()
    func stopRecording()
}

extension RecordingCoordinator: RecordingController {
}
#endif
