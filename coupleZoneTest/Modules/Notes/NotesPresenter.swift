//
//  NotesPresenter.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//  
//

import Foundation

protocol NotesPresentationLogic: AnyObject {
    func present(_ response: NotesModels.FetchData.Response)
    func presentAfterNewNote(_ response: NotesModels.CreateNote.Response)
}

final class NotesPresenter: NotesPresentationLogic {
    
    // MARK: Public Properties
    weak var view: NotesDisplayLogic?

    // MARK: Presentation Logic
    @MainActor func present(_ response: NotesModels.FetchData.Response) {
        switch response.result {
            case .success( let items):
                var displayableModels = [NotesModels.FetchData.ViewModel.DisplayableModel]()
                for item in items {
                    let displayableModel = NotesModels.FetchData.ViewModel.DisplayableModel.init(model: item)
                    displayableModels.append(displayableModel)
                }
                self.view?.display(NotesModels.FetchData.ViewModel(displayableModels: displayableModels))
            case .failure(let error):
                print(error.localizedDescription)
        }
    }
    @MainActor func presentAfterNewNote(_ response: NotesModels.CreateNote.Response) {
        switch response.result {
            case .success:
                view?.displayVoid()
            case .failure(let error):
                view?.displayError(error.localizedDescription)
                print(error.localizedDescription)
        }
    }
}

extension NotesModels.FetchData.ViewModel.DisplayableModel {
    init(model: NoteItem) {
        self.createdAt = model.createdAt ?? ""
        self.title = model.title
        self.note = model.note
        self.editedAt = model.editedAt ?? ""
    }
}
