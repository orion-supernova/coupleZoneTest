//
//  HomeItem.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

final class HomeItem: APIResponse {
    
    private enum CodingKeys: String, CodingKey {
        case imageURLString = "imageURLString"
        case numberOfDays = "numberOfDays"
        case username = "username"
        case partnerUsername = "partnerUsername"
    }
    
    let imageURLString: String
    let numberOfDays: Int
    let username: String
    let partnerUsername: String
    
    init?(with json: JSON) {
        self.imageURLString = json[CodingKeys.imageURLString.stringValue] as? String ?? ""
        self.numberOfDays = json[CodingKeys.numberOfDays.stringValue] as? Int ?? 0
        self.username = json[CodingKeys.username.stringValue] as? String ?? ""
        self.partnerUsername = json[CodingKeys.partnerUsername.stringValue] as? String ?? ""
    }
}
