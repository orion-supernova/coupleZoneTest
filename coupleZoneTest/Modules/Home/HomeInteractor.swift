//
//  HomeInteractor.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

protocol HomeBusinessLogic {
    func fetchData(_ request: HomeModels.FetchData.Request)
    func changePhotoTapped()
    func uploadPhoto(_ request: HomeModels.UploadPhoto.Request)
    func sendLoveToPartner()
}

protocol HomeDataStore {
    var homeItem: HomeItem? { get }
}

final class HomeInteractor: HomeBusinessLogic, HomeDataStore {
    // MARK: Public Properties
    var homeItem: HomeItem?

    // MARK: Private Properties
    private let worker: HomeWorker
    private let presenter: HomePresentationLogic

    // MARK: Initializers
    init(presenter: HomePresentationLogic, worker: HomeWorker) {
        self.presenter = presenter
        self.worker = worker
        NotificationCenter.default.addObserver(self, selector: #selector(usernameChanged), name: .usernameChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(anniversaryChanged), name: .anniversaryChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addUserToHomeSuccess), name: .addUserToHomeSuccess, object: nil)
    }

    // MARK: Business Logic
    func fetchData(_ request: HomeModels.FetchData.Request) {
        Task {
            let result = await worker.fetchData()
            DispatchQueue.main.async {
                switch result {
                    case .success(let homeItem):
                        let viewModel = HomeModels.FetchData.ViewModel.init(displayModel: .init(model: homeItem))
                        self.presenter.presentData(viewModel, loadPhoto: request.fetchPhoto)
                    case .failure:
                        self.presenter.presentHomeNotExist()
                }
            }
        }
    }
    func changePhotoTapped() {
        presenter.presentImagePicker()
    }
    func uploadPhoto(_ request: HomeModels.UploadPhoto.Request) {
        Task {
            LottieHUD.shared.show()
            let result = await worker.uploadImage(request.image)
            let response = HomeModels.UploadPhoto.Response.init(result: result)
            LottieHUD.shared.dismiss()
            DispatchQueue.main.async {
                self.presenter.presentUploadPhotoResponse(response)
            }
        }
    }
    func sendLoveToPartner() {
        Task {
            let result = await worker.sendLoveToPartner()
            let response = HomeModels.SendLove.Response.init(result: result)
            DispatchQueue.main.async {
                self.presenter.presentLoveSentResponse(response)
            }
        }
    }
    // MARK: - Actions
    @objc private func usernameChanged() {
        fetchData(.init(fetchPhoto: false))
    }
    @objc private func anniversaryChanged() {
        fetchData(.init(fetchPhoto: false))
    }
    @objc private func addUserToHomeSuccess() {
        fetchData(.init(fetchPhoto: true))
    }
}
