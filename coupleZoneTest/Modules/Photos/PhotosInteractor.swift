//
//  PhotosInteractor.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import Foundation
import UIKit.UIImage

protocol PhotosBusinessLogic {
    func fetchData(_ request: PhotosModels.FetchData.Request)
    func uploadPhoto(_ request: PhotosModels.UploadPhoto.Request)
}

protocol PhotosDataStore {
    var PhotosItem: PhotosItem? { get }
}

final class PhotosInteractor: PhotosBusinessLogic, PhotosDataStore {
    // MARK: Public Properties

    // MARK: Private Properties
    private let worker: PhotosWorker
    private let presenter: PhotosPresentationLogic
    var PhotosItem: PhotosItem?

    // MARK: Initializers
    init(presenter: PhotosPresentationLogic, worker: PhotosWorker) {
        self.presenter = presenter
        self.worker = worker
    }

    // MARK: Business Logic
    func fetchData(_ request: PhotosModels.FetchData.Request) {
        Task {
            let result = await worker.fetchData()
            let response = PhotosModels.FetchData.Response.init(result: result)
            self.presenter.present(response)
        }
    }

    func uploadPhoto(_ request: PhotosModels.UploadPhoto.Request) {
        Task {
            let result = await worker.uploadImage(request.image)
            let response = PhotosModels.UploadPhoto.Response.init(result: result)
            self.presenter.presentUploadPhoto(response)
        }
    }
}
