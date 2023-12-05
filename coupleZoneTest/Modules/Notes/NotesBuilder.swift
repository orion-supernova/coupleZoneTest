//
//  NotesBuilder.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//  
//

import UIKit.UIView

enum NotesBuilder {
    static func build() -> NotesViewController {
        let presenter = NotesPresenter()
        let worker = NotesNetworkWorker()
        let interactor = NotesInteractor(presenter: presenter, worker: worker)
        let view = NotesViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
