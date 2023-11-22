//
//  HomeModels.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import UIKit.UIImage

enum HomeModels {
    
    enum FetchData {
        struct Request {
            let fetchPhoto: Bool
        }
        struct Response {
            let result: Result<HomeItem, RequestError>
        }
        struct ViewModel {
            struct DisplayableModel {
                let imageURLString: String
                // Computed Properties
                let numberOfDays: Int
                let numberOfDaysInOrder: [Int]
                let partnerUsername: String
                let username: String
            }
            let displayModel: DisplayableModel
        }
    }
    enum UploadPhoto {
        struct Request {
            let image: UIImage
        }
        struct Response {
            let result: Result<Void, CustomMessageError>
        }
        struct ViewModel {}
    }
    enum SendLove {
        struct Request { }
        struct Response { let result: Result<Void, CustomMessageError> }
        struct ViewModel {}
    }
}
