//
//  PhotosModels.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import UIKit.UIImage

enum PhotosModels {

    enum FetchData {
        struct Request {}
        struct Response {
            let result: Result<[PhotosItem], RequestError>
        }
        struct ViewModel {
            struct DisplayableModel {
                let uploadDate: String
                let imageURLString: String
                let usernameString: String
            }
            let displayModels: [DisplayableModel]
        }
    }
    enum UploadPhoto {
        struct Request {
            let image: UIImage
        }
        struct Response {
            let result: Result<Void, RequestError>
        }
        struct ViewModel {}
    }
}
