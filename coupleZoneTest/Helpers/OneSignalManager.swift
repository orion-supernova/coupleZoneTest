//
//  OneSignalManager.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.11.2023.
//

import Foundation
import OneSignalFramework
import Supabase


class OneSignalManager: NSObject  {
    // MARK: - Shared Instances
    static let shared = OneSignalManager()

    let headers = [
        "accept": "application/json",
        "Authorization": "Basic \(SensitiveData.oneSignalRestAPIKey)",
        "Content-Type": "application/json"
    ]

    func createSegment(name: String) {
        let postData = NSData(data: "{\"name\":\"\(name)\"}".data(using: String.Encoding.utf8)!)

        let request = NSMutableURLRequest(url: NSURL(string: "https://onesignal.com/api/v1/apps/\(SensitiveData.oneSignalAppID)/segments")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? .init())
            }
        })

        dataTask.resume()
    }

    func setExternalID() {
        guard let externalUserId = AppGlobal.shared.user?.id.uuidString else { return }
        OneSignal.login(externalUserId)
        let hm = OneSignal.User.pushSubscription.id
        print(hm ?? "empty OneSignal Push ID")
    }

    func postNotification(to subscriptionIDs: [String], title: String, message: String, notificationSoundString: String? = nil, photoURLString: String? = nil, pushCategory: PushNotificationIdentifiers.Category, data: [String: Any]? = nil) {
        let parameters = [
            "app_id": SensitiveData.oneSignalAppID,
            "name": [
                "en": "Notification Name"
            ],
            "contents": [
                "en": message
            ],
            "headings": [
                "en": title
            ],
            "ios_attachments": [
                    "idAttachment": "\(photoURLString ?? "")"
            ],
            "ios_category": pushCategory.rawValue,
            "data": getCustomData(notificationCategory: pushCategory, additionalData: data ?? [:]),
            "ios_sound": notificationSoundString ?? "",
            "include_subscription_ids": subscriptionIDs,
            "content_available": true
        ] as [String : Any]

        let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        let request = NSMutableURLRequest(url: NSURL(string: "https://onesignal.com/api/v1/notifications")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData! as Data

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? .init())
            }
        })
        dataTask.resume()
    }
}

extension OneSignalManager {
    func getCustomData(notificationCategory: PushNotificationIdentifiers.Category, additionalData: [String: Any]) -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["notificationCategory"] = notificationCategory.rawValue
        dictionary["additionalData"] = additionalData
        return dictionary
    }
}

