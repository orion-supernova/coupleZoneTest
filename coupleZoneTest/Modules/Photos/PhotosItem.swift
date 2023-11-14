//
//  PhotosItem.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import Foundation

final class PhotosItem: APIResponse, Codable {

    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case imageURLString = "imageURL"
        case username = "username"
    }
    let createdAt: String?
    let imageURLString: String
    let username: String

    init?(with json: JSON) {
        self.createdAt = json[CodingKeys.createdAt.stringValue] as? String ?? ""
        self.imageURLString = json[CodingKeys.imageURLString.stringValue] as? String ?? ""
        self.username = json[CodingKeys.username.stringValue] as? String ?? ""
    }
    init?(imageURLString: String, username: String) {
        self.createdAt = nil
        self.imageURLString = imageURLString
        self.username = username
    }
}
