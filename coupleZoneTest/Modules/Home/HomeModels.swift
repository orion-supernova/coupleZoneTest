//
//  HomeModels.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import UIKit.UIImage

enum HomeModels {
    
    enum FetchData {
        struct Request {}
        
        struct Response {
            let result: Result<HomeItem, RequestError>
        }
        
        struct ViewModel {
            struct DisplayableModel {
                let imageURLString: String
                let username: String
                let partnerUsername: String
                // Computed Properties
                let numberOfDays: Int
                let numberOfDaysInOrder: [Int]
            }
            let displayModel: DisplayableModel
        }
    }
}
