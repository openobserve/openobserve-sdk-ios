/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import UIKit

public final class TabbarViewControllers: UIViewController {
    @IBOutlet var tabbars: [UITabBar]!

    override public func viewDidLoad() {
        for tabbar in tabbars {
            // Select the first tabbar's item
            // so we can see both a selected and unselected item
            tabbar.selectedItem = tabbar.items?.first
        }
    }
}

public final class EmbeddedTabbarController: UITabBarController {
    override public func viewDidLoad() {
        tabBar.unselectedItemTintColor = nil
    }
}

public final class EmbeddedTabbarUnselectedTintColorController: UITabBarController {
    override public func viewDidLoad() {
        tabBar.unselectedItemTintColor = UIColor.green
    }
}
