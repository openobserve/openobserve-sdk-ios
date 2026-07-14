/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import SwiftUI
import UIKit

// MARK: - Main View

/// SwiftUI wrapper for our storyboard-based UIKit LocationsView
struct LocationsView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "LocationsView", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        return navigationController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {
        // No updates needed
    }
}

#Preview {
    LocationsView()
}
