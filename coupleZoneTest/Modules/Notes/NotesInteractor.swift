//
//  NotesInteractor.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//  
//

import Foundation

protocol NotesBusinessLogic: AnyObject {
    func fetchData(_ request: NotesModels.FetchData.Request)
    func createNote(_ request: NotesModels.CreateNote.Request)
}

final class NotesInteractor: NotesBusinessLogic {
  
    private let worker: NotesWorker
    private let presenter: NotesPresentationLogic
    
    // MARK: Initializers
    init(presenter: NotesPresentationLogic, worker: NotesWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    // MARK: Business Logic
    func fetchData(_ request: NotesModels.FetchData.Request) {
        Task {
            let result = await worker.fetchData()
            let response = NotesModels.FetchData.Response.init(result: result)
            DispatchQueue.main.async {
                self.presenter.present(response)
            }
        }
    }
    func createNote(_ request: NotesModels.CreateNote.Request) {
        Task {
            LottieHUD.shared.show()
            let result = await worker.createNote(title: request.title)
            let response = NotesModels.CreateNote.Response.init(result: result)
            DispatchQueue.main.async {
                LottieHUD.shared.dismiss()
                self.presenter.presentAfterNewNote(response)
            }
        }
    }
}
