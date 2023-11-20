//
//  Chat2Presenter.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 17.11.2023.
//  
//

import Foundation

protocol Chat2PresentationLogic: AnyObject {
    var view: Chat2DisplayLogic? { get set }
    
    func present(_ response: Chat2Models.FetchData.Response)
}

final class Chat2Presenter: Chat2PresentationLogic {
    
    // MARK: Public Properties
    weak var view: Chat2DisplayLogic?

    // MARK: Presentation Logic
    func present(_ response: Chat2Models.FetchData.Response) {
        
    }
}

extension Chat2Models.FetchData.ViewModel.DisplayableModel {
}
