//
//  HomeRouter.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import UIKit.UINavigationController

protocol HomeNavigationLogic: AnyObject {
    func routeToSettings()
}

final class HomeRouter: HomeNavigationLogic {
    // MARK: Public Properties
    weak var controller: HomeViewController?
    
    // MARK: Routing Logic
    func routeToSettings() {
        let settingsController = SettingsViewController()
        controller?.present(settingsController, animated: true)
    }
}
