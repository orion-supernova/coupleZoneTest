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
    
    // MARK: Private Properties
    private let worker: HomeWorker
    private let presenter: HomePresentationLogic
    var homeItem: HomeItem?
    
    // MARK: Initializers
    init(presenter: HomePresentationLogic, worker: HomeWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    // MARK: Business Logic
    func fetchData(_ request: HomeModels.FetchData.Request) {
        Task {
            let result = await worker.fetchData()
            DispatchQueue.main.async {
                switch result {
                case .success(let homeItem):
                    self.homeItem = homeItem
                case .failure:
                    self.homeItem = .none
                }
                
                let response = HomeModels.FetchData.Response.init(result: result)
                self.presenter.present(response)
            }
        }
    }
}
