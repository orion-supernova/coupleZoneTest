//
//  UIViewControllerExtension.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 27.10.2023.
//

import UIKit

extension UIViewController {
    var topController: UIViewController? {
        if let controller = self as? UINavigationController {
            return controller.topViewController?.topController
        } else if let controller = self as? UITabBarController {
            return controller.selectedViewController?.topController
        } else if let controller = presentedViewController {
            return controller.topController
        } else {
            return self
        }
    }
    var rootController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}
