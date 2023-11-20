//
//  Chat2Builder.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 17.11.2023.
//  
//

import UIKit.UIView

enum Chat2Builder {
    static func build() -> Chat2ViewController {
        let presenter = Chat2Presenter()
        let worker = Chat2NetworkWorker()
        let interactor = Chat2Interactor(presenter: presenter, worker: worker)
        let view = Chat2ViewController(interactor: interactor)
        
        presenter.view = view
        
        return view
    }
}
