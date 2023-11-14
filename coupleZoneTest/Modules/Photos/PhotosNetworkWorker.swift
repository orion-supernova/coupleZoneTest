//
//  PhotosNetworkWorker.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import Foundation
import UIKit.UIImage

protocol PhotosWorker {
    func fetchData() async -> Result<[PhotosItem], RequestError>
    func uploadImage(_ image: UIImage) async -> Result<Bool, RequestError>
}

final class PhotosNetworkWorker: PhotosWorker {

    let PhotosServices: PhotosServices

    init(PhotosServices: PhotosServices) {
        self.PhotosServices = PhotosServices
    }

    func fetchData() async -> Result<[PhotosItem], RequestError> {
        return await PhotosServices.getPhotos()
    }

    func uploadImage(_ image: UIImage) async -> Result<Bool, RequestError> {
        return await PhotosServices.uploadPhoto(image)
    }
}
