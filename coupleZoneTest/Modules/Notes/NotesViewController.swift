//
//  NotesViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit

class NotesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: - FIXME: - Remove Bottom After Update
        if let email = AppGlobal.shared.user?.email {
            if email == SensitiveData.myPartnersEmail {
                displaySimpleAlert(title: "Notes In Progress...", message: "Update gelince bakarsın canım sevgilim.", okButtonText: "❤️")
            } else if email == SensitiveData.myEmail {
                displaySimpleAlert(title: "Notes In Progress...", message: "Bitircen mi artık?", okButtonText: "sg")
            }
        }
    }
}

extension NotesViewController: Alertable {}
