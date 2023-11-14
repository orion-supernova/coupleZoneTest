//
//  PhotosRouter.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import UIKit.UINavigationController

protocol PhotosNavigationLogic: AnyObject {
    func routeToSettings()
}

final class PhotosRouter: PhotosNavigationLogic {
    // MARK: Public Properties
    weak var controller: PhotosViewController?

    // MARK: Routing Logic
    func routeToSettings() {
        let settingsController = SettingsViewController()
        controller?.present(settingsController, animated: true)
    }
}
