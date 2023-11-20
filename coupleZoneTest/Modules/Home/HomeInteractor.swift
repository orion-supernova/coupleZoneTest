//
//  HomeInteractor.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

protocol HomeBusinessLogic {
    func fetchData(_ request: HomeModels.FetchData.Request)
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
    func changePhoto() {
        
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
