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
            case .success(let success):
                guard success else { 
                    presentError(RequestError.generic.localizedDescription)
                    return
                }
                view?.displaySuccess()
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
