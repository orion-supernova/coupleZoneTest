//
//  HomePresenter.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import UIKit

protocol HomePresentationLogic {
    func present(_ response: HomeModels.FetchData.Response)
}

final class HomePresenter: HomePresentationLogic {
    
    // MARK: Public Properties
    weak var view: HomeDisplayLogic?

    // MARK: Presentation Logic
    func present(_ response: HomeModels.FetchData.Response) {
        switch response.result {
        case .success( let item):
            let displayableModel = HomeModels.FetchData.ViewModel.DisplayableModel.init(model: item)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.display(HomeModels.FetchData.ViewModel(displayModel: displayableModel))
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

extension HomeModels.FetchData.ViewModel.DisplayableModel {
    init(model: HomeItem) {
        self.imageURLString =  model.imageURLString
        self.numberOfDays = model.numberOfDays
        if let email = AppGlobal.shared.user?.email {
            if email == "zeynepozahishali@gmail.com" {
                self.partnerUsername = "cankoç, on the right"
            } else {
                self.partnerUsername = "zeynom, on the left"
            }
        } else {
            self.partnerUsername = "Error"
        }
        self.username = AppGlobal.shared.appleCredentialUserFullName?.givenName ?? "Anonymous"
    }
}
