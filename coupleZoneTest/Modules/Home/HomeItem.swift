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
        case anniversaryDate = "anniversary_date"
        case username = "username"
        case partnerUsername = "partnerUsername"
    }
    
    let imageURLString: String
    let anniversaryDate: String
    let username: String
    let partnerUsername: String
    
    init?(with json: JSON) {
        self.imageURLString = json[CodingKeys.imageURLString.stringValue] as? String ?? ""
        self.anniversaryDate = json[CodingKeys.anniversaryDate.stringValue] as? String ?? "1998-06-23"
        self.username = json[CodingKeys.username.stringValue] as? String ?? ""
        self.partnerUsername = json[CodingKeys.partnerUsername.stringValue] as? String ?? ""
    }
}
