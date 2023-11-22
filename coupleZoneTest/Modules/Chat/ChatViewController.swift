//
//  ChatViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import InputBarAccessoryView
import Kingfisher
import MapKit
import MessageKit
import UIKit

class ChatViewController: MessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: - FIXME: - Remove Bottom After Update
        if let email = AppGlobal.shared.user?.email {
            if email == SensitiveData.myPartnersEmail {
                displaySimpleAlert(title: "Chat In Progress...", message: "Update gelince bakarsın canım sevgilim.", okButtonText: "❤️")
            } else if email == SensitiveData.myEmail {
                displaySimpleAlert(title: "Chat In Progress...", message: "Bitircen mi artık?", okButtonText: "sg")
            }
        }
    }
    let sender = Sender(senderId: "any_unique_id", displayName: "Steven")
    let messages: [MessageType] = []
}

extension ChatViewController: MessagesDataSource {
    public struct Sender: SenderType {
        public let senderId: String
        public let displayName: String
    }
    
    var currentSender: MessageKit.SenderType {
        return Sender(senderId: "any_unique_id", displayName: "Steven")
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
}
extension ChatViewController: MessagesDisplayDelegate {}
extension ChatViewController: MessagesLayoutDelegate {}
extension ChatViewController: Alertable {}
