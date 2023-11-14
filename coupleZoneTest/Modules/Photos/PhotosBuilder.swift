//
//  PhotosBuilder.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import Foundation
import UIKit.UIView

enum PhotosBuilder {
    static func build() -> PhotosViewController {
        let presenter = PhotosPresenter()
        let worker = PhotosNetworkWorker(PhotosServices: PhotosServices())
        let router = PhotosRouter()
        let interactor = PhotosInteractor(presenter: presenter, worker: worker)
        let controller = PhotosViewController(interactor: interactor, router: router)
        presenter.view = controller
        router.controller = controller
        return controller
    }
}
