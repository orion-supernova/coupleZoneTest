//
//  NotesWorker.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//  
//

import Foundation

protocol NotesWorker {
    func fetchData() async -> Result<[NoteItem], CustomMessageError>
    func createNote(title: String) async -> Result<Void, CustomMessageError>
    func disconnectSocket()
}

final class NotesNetworkWorker: NotesWorker {
    
    // MARK: - Private Properties
    private var notesServices: NotesServices

    init(notesServices: NotesServices = NotesServices()) {
        self.notesServices = notesServices
    }
    
    func fetchData() async -> Result<[NoteItem], CustomMessageError> {
        return await notesServices.getNotes()
    }
    func createNote(title: String) async -> Result<Void, CustomMessageError> {
        return await notesServices.createNote(title: title)
    }
    func disconnectSocket() {
        notesServices.disconnectSocket()
    }
}
