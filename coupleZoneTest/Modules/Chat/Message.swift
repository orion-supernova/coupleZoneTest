//
//  Message.swift
//  coupleZoneTest
//
//  Created by muratcankoc on 08/06/2024.
//

import Foundation

struct MessageItem: Codable, Identifiable {

    var id: String?
    let message: String
    var profileImageURL: String?
    let createdAt: String
    var senderName: String?
    var senderUID: String?
    let homeID: String?

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case profileImageURL
        case createdAt
        case senderName
        case senderUID
        case homeID
    }

    init?(with json: JSON) {
        self.id = json[CodingKeys.id.stringValue] as? String ?? ""
        self.message = json[CodingKeys.message.stringValue] as? String ?? ""
        self.profileImageURL = json[CodingKeys.profileImageURL.stringValue] as? String ?? ""
        self.createdAt = json[CodingKeys.createdAt.stringValue] as? String ?? ""
        self.senderName = json[CodingKeys.senderName.stringValue] as? String ?? ""
        self.senderUID = json[CodingKeys.senderUID.stringValue] as? String ?? ""
        self.homeID = json[CodingKeys.homeID.stringValue] as? String ?? ""
    }

    var formattedCreatedAt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" // Adjust the format as needed
        if let date = dateFormatter.date(from: createdAt) {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                dateFormatter.dateFormat = "'today', HH:mm"
            } else if calendar.isDateInYesterday(date) {
                dateFormatter.dateFormat = "'yesterday', HH:mm"
            } else {
                dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
            }
            return dateFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
}

