//
//  HomeServices.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

class HomeServices {
    
    let client = SensitiveData.client

    func getHomeInfo() async -> Result<HomeItem, RequestError> {
        do {
            let data = try await client.database.from("home").select(columns: "*", head: false).execute().underlyingResponse.data
            let stringData = String(data: data, encoding: .utf8) ?? ""
            guard let dict = stringData.convertStringToDictionary() else { return .failure(.generic) }
            guard let item = HomeItem(with: dict) else { return .failure(.generic) }
            return .success(item)
        } catch {
            return .failure(.generic)
        }
    }
}
