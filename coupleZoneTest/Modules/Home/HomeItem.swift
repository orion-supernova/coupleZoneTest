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
    }
    
    let imageURLString: String
    let anniversaryDate: String

    init?(with json: JSON) {
        self.imageURLString = json[CodingKeys.imageURLString.stringValue] as? String ?? ""
        self.anniversaryDate = json[CodingKeys.anniversaryDate.stringValue] as? String ?? "1998-06-23"
    }
}
