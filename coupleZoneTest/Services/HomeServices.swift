//
//  HomeServices.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

class HomeServices {
    
    let supabase = SensitiveData.supabase

    func getHomeInfo() async -> Result<HomeItem, RequestError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.generic) }
            let homeIDData = try await supabase.database.from("users").select(columns: "homeID").eq(column: "userID", value: userID).execute().underlyingResponse.data
            let homeIDStringData = String(data: homeIDData, encoding: .utf8) ?? ""
            let homeIDDict = homeIDStringData.convertStringToDictionary()
            let homeID = homeIDDict?["homeID"] as? String ?? ""
            let homeData = try await supabase.database.from("homes").select(columns: "*", head: false).eq(column: "id", value: homeID).execute().underlyingResponse.data
            let homeStringData = String(data: homeData, encoding: .utf8) ?? ""
            guard let homeDict = homeStringData.convertStringToDictionary() else { return .failure(.generic) }
            guard let item = HomeItem(with: homeDict) else { return .failure(.generic) }
            return .success(item)
        } catch {
            return .failure(.generic)
        }
    }
}
