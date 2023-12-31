//
//  Alertable.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit

public protocol Alertable: UIViewController {
    func displaySimpleAlert(title: String, message: String, okButtonText: String, completion: @escaping () -> Void)
    func displayAlertTwoButtons(title: String, message: String, firstButtonText: String, firstButtonStyle: UIAlertAction.Style, seconButtonText: String, secondButtonStyle: UIAlertAction.Style, firstButtonCompletion: @escaping () -> Void, secondButtonCompletion: @escaping () -> Void)
}

public extension Alertable {

    @MainActor func displaySimpleAlert(title: String, message: String, okButtonText: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonText, style: .default) { _ in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    @MainActor func displayAlertTwoButtons(title: String, message: String, firstButtonText: String, firstButtonStyle: UIAlertAction.Style, seconButtonText: String, secondButtonStyle: UIAlertAction.Style, firstButtonCompletion: @escaping () -> Void, secondButtonCompletion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstButtonAction = UIAlertAction(title: firstButtonText, style: firstButtonStyle) { _ in
            firstButtonCompletion()
        }
        let secondButtonAction = UIAlertAction(title: seconButtonText, style: secondButtonStyle) { _ in
            secondButtonCompletion()
        }
        alertController.addAction(firstButtonAction)
        alertController.addAction(secondButtonAction)
        present(alertController, animated: true)
    }
}
