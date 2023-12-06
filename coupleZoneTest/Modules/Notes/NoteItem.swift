//
//  NoteItem.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//

import Foundation

final class NoteItem: APIResponse {

    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case title = "title"
        case note = "note"
        case editedAt = "edited_at"
        case id = "id"
    }
    let createdAt: String?
    let editedAt: String?
    let title: String
    let note: [String: Any]
    let id: Int

    init?(with json: JSON) {
        self.id = json[CodingKeys.id.stringValue] as? Int ?? 0
        self.createdAt = json[CodingKeys.createdAt.stringValue] as? String ?? ""
        self.editedAt = json[CodingKeys.editedAt.stringValue] as? String ?? ""
        self.title = json[CodingKeys.title.stringValue] as? String ?? ""
        if let noteData = json[CodingKeys.note.stringValue] as? [String: Any] {
            self.note = noteData
        } else {
            self.note = [:] // Default empty dictionary for note
        }
    }
}
