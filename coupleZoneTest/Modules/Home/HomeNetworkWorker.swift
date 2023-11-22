//
//  HomeNetworkWorker.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation
import UIKit.UIImage

protocol HomeWorker {
    func fetchData() async -> Result<HomeItem, RequestError>
    func uploadImage(_ image: UIImage) async -> Result<Void, CustomMessageError>
    func sendLoveToPartner() async -> Result<Void, CustomMessageError>
    func getPartnerUsername() async -> Result<String, CustomMessageError>
}

final class HomeNetworkWorker: HomeWorker {
    
    let homeServices: HomeServices
    
    init(homeServices: HomeServices) {
        self.homeServices = homeServices
    }
    func fetchData() async -> Result<HomeItem, RequestError> {
        return await homeServices.getHomeInfo()
    }
    func uploadImage(_ image: UIImage) async -> Result<Void, CustomMessageError> {
        return await homeServices.uploadPhoto(image)
    }
    func sendLoveToPartner() async -> Result<Void, CustomMessageError> {
        return await homeServices.sendLoveToPartner()
    }
    func getPartnerUsername() async -> Result<String, CustomMessageError> {
        return await homeServices.getPartnerUsername()
    }
}
