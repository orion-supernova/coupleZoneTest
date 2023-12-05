//
//  Alertable.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit

public protocol Alertable: UIViewController {
    func displaySimpleAlert(title: String, message: String, okButtonText: String, tintColor: UIColor?, completion: (() -> Void)?)
    func displayAlertTwoButtons(title: String, message: String, firstButtonText: String, firstButtonStyle: UIAlertAction.Style, seconButtonText: String, secondButtonStyle: UIAlertAction.Style, firstButtonCompletion: (() -> Void)?, secondButtonCompletion: (() -> Void)?)
}

public extension Alertable {

    @MainActor func displaySimpleAlert(title: String, message: String, okButtonText: String, tintColor: UIColor? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonText, style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        alertController.view.tintColor = tintColor
        present(alertController, animated: true)
    }
    @MainActor func displayAlertTwoButtons(title: String, message: String, firstButtonText: String, firstButtonStyle: UIAlertAction.Style, seconButtonText: String, secondButtonStyle: UIAlertAction.Style, firstButtonCompletion: (() -> Void)? = nil, secondButtonCompletion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstButtonAction = UIAlertAction(title: firstButtonText, style: firstButtonStyle) { _ in
            firstButtonCompletion?()
        }
        let secondButtonAction = UIAlertAction(title: seconButtonText, style: secondButtonStyle) { _ in
            secondButtonCompletion?()
        }
        alertController.addAction(firstButtonAction)
        alertController.addAction(secondButtonAction)
        present(alertController, animated: true)
    }
    @MainActor func displayAlertWithTextfield(title: String, message: String, okButtonText: String, cancelButtonText: String, placeholder: String? = nil, tintColor: UIColor? = nil, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = placeholder
        }
        let okButtonAction = UIAlertAction(title: okButtonText, style: .default) { _ in
            guard let textFields = alertController.textFields else { return }
            if let username = textFields[0].text {
                completion(username)
            }
        }
        let cancelButtonAction = UIAlertAction(title: cancelButtonText, style: .cancel)
        alertController.addAction(okButtonAction)
        alertController.addAction(cancelButtonAction)
        alertController.view.tintColor = tintColor
        present(alertController, animated: true)
    }
}
