//
//  AlertHelper.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 30.11.2023.
//

import UIKit

class AlertHelper {
    static func alertMessage(title: String, message: String, okButtonText: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonText, style: .default) { (action: UIAlertAction) in
        }
        alertVC.addAction(okAction)
        alertVC.view.tintColor = .systemPink

        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}
