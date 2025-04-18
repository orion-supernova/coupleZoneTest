//
//  ChatRoomViewModel.swift
//  coupleZoneTest
//
//  Created by muratcankoc on 08/06/2024.
//

import Foundation
import Supabase

protocol ChatRoomViewModelDelegate: AnyObject {
    func didChangeDataSource()
}

final class ChatRoomViewModel {

    // MARK: - Stored Properties
    var messages = [MessageItem]()
    var lastMessage: MessageItem?
    weak var delegate: ChatRoomViewModelDelegate?
    var selectedMessage: MessageItem?

    // MARK: - Lifecycle
    init() {
    }

    // MARK: - Functions
    func fetchMessages(completion: @escaping(() -> Void)) async {
        do {
            let homeID = await getHomeID()
            let messagesDict = try await SensitiveData.supabase.from("messages").select("*", head: false).eq("homeID", value: homeID).execute().data.convertDataToString().convertStringToDictionaryArray() ?? [[:]]

            // Convert array of dictionaries to Data
            let jsonDataArray: [Data] = messagesDict.compactMap { dictionary in
                do {
                    return try JSONSerialization.data(withJSONObject: dictionary, options: [])
                } catch {
                    print("Error converting dictionary to data: \(error)")
                    return nil
                }
            }

            // Create a JSONDecoder
            let decoder = JSONDecoder()

            // Convert Data to array of Message objects
            let messageArray = jsonDataArray.compactMap { jsonData in
                do {
                    return try decoder.decode(MessageItem.self, from: jsonData)
                } catch {
                    print("Error decoding data to Message: \(error)")
                    return nil
                }
            }
            messages = messageArray
            completion()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func getHomeID() async -> String {
        do {
            let userID = AppGlobal.shared.user?.id.uuidString ?? ""
            let homeID = try await SensitiveData.supabase.from("users").select("homeID", head: false).eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? "Not Found"
            return homeID
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }

    func getStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let dateString = dateFormatter.string(from: date)

        print("String from Date: \(dateString)")
        return dateString
    }

    func getPartnersPushNotificationIDs() async -> [String] {
        do {
            let partnerUserID = await getPartnerUserID()
            guard !partnerUserID.isEmpty else { return [] }
            let pushDevicesIDArray = try await SensitiveData.supabase.from("users").select("pushSubscriptionIDs").eq("userID", value: partnerUserID).execute().data.convertDataToString().convertStringToDictionary()?["pushSubscriptionIDs"] as? [String] ?? []
            return pushDevicesIDArray
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }

    private func getPartnerUserID() async -> String {
        do {
            guard let userID = AppGlobal.shared.user?.id.uuidString else { return "" }
            let partnerUserID = try await SensitiveData.supabase.from("users").select("partnerUserID").eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()?["partnerUserID"] as? String ?? ""
            guard !partnerUserID.isEmpty else { return "" }
            return (partnerUserID)
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }

    func uploadMessage(message: String) async {
        do {
            let homeID = await getHomeID()
            // Create a Message object
            let dict: [String: String] = [
                "id": UUID().uuidString,
                "message": message,
                "profileImageURL": "",
                "createdAt": getStringFromDate(date: Date()),
                "senderName": AppGlobal.shared.username ?? "",
                "senderUID": AppGlobal.shared.user?.id.uuidString ?? "",
                "homeID": homeID
            ]
            try await SensitiveData.supabase.from("messages").upsert(dict).execute()
            delegate?.didChangeDataSource()
            let partnerDevices = await getPartnersPushNotificationIDs()
            OneSignalManager.shared.postNotification(
                to: partnerDevices,
                title: "New Message!",
                message: "Please check your couple zone.",
                notificationSoundString: "message-received-notification.wav",
                pushCategory: .message,
                data: ["senderUID" : AppGlobal.shared.user?.id.uuidString ?? ""])
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
