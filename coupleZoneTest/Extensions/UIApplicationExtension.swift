//
//  UIApplicationExtension.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-05.
//

import UIKit.UIApplication

extension UIApplication {
    var keyWindoww: UIWindow? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return keyWindow
    }
}
