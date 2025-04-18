//
//  MessageOptionsTableViewCellViewModel.swift
//  coupleZoneTest
//
//  Created by muratcankoc on 08/06/2024.
//

import Foundation

class MessageOptionsTableViewCellViewModel {
    // MARK: - Lifecycle
    deinit {
        print("MessageOptionsTableViewCellViewModel")
    }

    // MARK: - Public Methods
    func prepareOptions(with indexPath: IndexPath) -> MessageOption {
        switch indexPath.row {
            case 0:
                return MessageOption.init(title: "Copy", imageString: "doc.on.doc")
            case 1:
                return MessageOption.init(title: "Report", imageString: "exclamationmark.bubble")
            case 2:
                return MessageOption.init(title: "Reply", imageString: "arrowshape.turn.up.left")
            case 3:
                return MessageOption.init(title: "Delete", imageString: "trash")
            default:
                return MessageOption.init(title: "Copy", imageString: "doc.on.doc")
        }
    }
}

struct MessageOption {
    var title: String
    var imageString: String?
}
