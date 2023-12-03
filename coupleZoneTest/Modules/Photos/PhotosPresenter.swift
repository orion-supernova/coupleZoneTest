//
//  PhotosPresenter.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import UIKit

protocol PhotosPresentationLogic {
    func present(_ response: PhotosModels.FetchData.Response)
    func presentUploadPhoto(_ response: PhotosModels.UploadPhoto.Response)
    func presentUpdateNotificationTime(_ response: PhotosModels.UpdateNotificationTime.Response)
}

final class PhotosPresenter: PhotosPresentationLogic {

    // MARK: Public Properties
    weak var view: PhotosDisplayLogic?

    // MARK: Presentation Logic
    @MainActor func present(_ response: PhotosModels.FetchData.Response) {
        switch response.result {
            case .success( let items):
                var displayableModels = [PhotosModels.FetchData.ViewModel.DisplayableModel]()
                for item in items {
                    let displayableModel = PhotosModels.FetchData.ViewModel.DisplayableModel.init(model: item)
                    displayableModels.append(displayableModel)
                }
                self.view?.display(PhotosModels.FetchData.ViewModel(displayModels: displayableModels))
            case .failure(let error):
                print(error.localizedDescription)
        }
    }
    @MainActor func presentUploadPhoto(_ response: PhotosModels.UploadPhoto.Response) {
        switch response.result {
            case .success():
                view?.displaySuccessAfterPhotoUpload()
            case .failure(let error):
                print(error.localizedDescription)
                presentError(error.localizedDescription)
        }
    }
    @MainActor func presentUpdateNotificationTime(_ response: PhotosModels.UpdateNotificationTime.Response) {
        switch response.result {
            case .success(let time):
            let viewModel = PhotosModels.UpdateNotificationTime.ViewModel.init(serverDateString: time)
                view?.displaySuccessAfterUpdateNotificationTime(viewModel)
            case .failure(let error):
                print(error.localizedDescription)
                presentError(error.localizedDescription)
        }
    }

    // MARK: - Private Methods
    @MainActor private func presentError(_ errorString: String) {
        view?.displayError(errorString)
    }
}

// MARK: - Displayable Model
extension PhotosModels.FetchData.ViewModel.DisplayableModel {
    init(model: PhotosItem) {
        self.imageURLString =  model.imageURLString
        self.uploadDate = model.createdAt ?? "Error"
        self.usernameString = model.username
    }
}
extension PhotosModels.UpdateNotificationTime.ViewModel {
    init(serverDateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        if let date = dateFormatter.date(from: serverDateString) {
            dateFormatter.dateFormat = "HH:mm"
            let convertedDateString = dateFormatter.string(from: date)
            self.notificationTime = convertedDateString
        } else {
            print("Invalid date string format")
            self.notificationTime = ""
        }
    }
}
