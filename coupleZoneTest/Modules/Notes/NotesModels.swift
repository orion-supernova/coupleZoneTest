//
//  NotesModels.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//  
//

import Foundation

enum NotesModels {
    
    enum FetchData {
        struct Request {}
        
        struct Response {
            let result: Result<[NoteItem], CustomMessageError>
        }
        
        struct ViewModel {
            struct DisplayableModel {
                let createdAt: String
                let editedAt: String
                let title: String
                let note: [String: Any]
            }
            let displayableModels: [DisplayableModel]
        }
    }
    
    enum CreateNote {
        struct Request {
            let title: String
        }
        
        struct Response {
            let result: Result<Void, CustomMessageError>
        }
        
        struct ViewModel {}
    }

}
