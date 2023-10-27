//
//  HomeBuilder.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation
import UIKit.UIView

enum HomeBuilder {
    static func build() -> HomeViewController {
        let presenter = HomePresenter()
        let worker = HomeNetworkWorker(homeServices: HomeServices())
        let router = HomeRouter()
        let interactor = HomeInteractor(presenter: presenter, worker: worker)
        let controller = HomeViewController(interactor: interactor, router: router)
        presenter.view = controller
        router.controller = controller
        return controller
    }
}
