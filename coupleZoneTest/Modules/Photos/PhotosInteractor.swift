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
    func updatePhotoNotificationTime(_ request: PhotosModels.UpdateNotificationTime.Request)
    func getPhotoNotificationTime(_ request: PhotosModels.GetNotificationTime.Request, completion: @escaping (String) -> Void)
}

protocol PhotosDataStore {
    var PhotosItem: PhotosItem? { get }
}

final class PhotosInteractor: PhotosBusinessLogic, PhotosDataStore {
    
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
            LottieHUD.shared.show()
            let result = await worker.uploadImage(request.image)
            let response = PhotosModels.UploadPhoto.Response.init(result: result)
            LottieHUD.shared.dismiss()
            DispatchQueue.main.async {
                self.presenter.presentUploadPhoto(response)
            }
        }
    }
    
    func updatePhotoNotificationTime(_ request: PhotosModels.UpdateNotificationTime.Request) {
        Task {
            let result = await worker.updateNotificationTime(request.notificationTime)
            let response = PhotosModels.UpdateNotificationTime.Response.init(result: result)
            DispatchQueue.main.async {
                self.presenter.presentUpdateNotificationTime(response)
            }
        }
    }
    
    func getPhotoNotificationTime(_ request: PhotosModels.GetNotificationTime.Request, completion: @escaping (String) -> Void) {
        Task {
            let result = await worker.getNotificationTime()
            let response = PhotosModels.GetNotificationTime.Response.init(result: result)
            switch response.result {
            case .success(let time):
                DispatchQueue.main.async {
                    completion(time)
                }
            case .failure:
                break
            }
        }
    }
}
