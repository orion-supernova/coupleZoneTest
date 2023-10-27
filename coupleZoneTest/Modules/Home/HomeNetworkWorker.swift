//
//  HomeNetworkWorker.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

protocol HomeWorker {
    func fetchData() async -> Result<HomeItem, RequestError>
}

final class HomeNetworkWorker: HomeWorker {
    
    let homeServices: HomeServices
    
    init(homeServices: HomeServices) {
        self.homeServices = homeServices
    }
    
    func fetchData() async -> Result<HomeItem, RequestError> {
        return await homeServices.getHomeInfo()
    }
}
