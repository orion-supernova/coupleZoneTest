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

final class HomeInteractor: HomeBusinessLogic {
    // MARK: Private Properties
    private let worker: HomeWorker
    private let presenter: HomePresentationLogic
    private var partnerUsername: String?

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
            switch result {
                case .success(let homeItem):
                    let homeModel = await setHomeModel(with: homeItem)
                    let viewModel = HomeModels.FetchData.ViewModel.init(displayModel: .init(item: homeItem, model: homeModel))
                    DispatchQueue.main.async {
                        self.presenter.presentData(viewModel, loadPhoto: request.fetchPhoto)
                    }
                case .failure:
                    DispatchQueue.main.async {
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
    // MARK: - Private Methods
    private func setHomeModel(with item: HomeItem) async -> HomeModels.FetchData.ViewModel.DisplayableModel {
        await setPartnerUsername()
        return .init(imageURLString: item.imageURLString, numberOfDays: 0, numberOfDaysInOrder: [0], partnerUsername: partnerUsername ?? "", username: AppGlobal.shared.username ?? "Anonymous")
    }
    private func setPartnerUsername() async {
        do {
            let result = await worker.getPartnerUsername()
            switch result {
                case .success(let partnerUsername):
                    self.partnerUsername = partnerUsername
                case .failure:
                    break
            }
        }
    }
}
