//
//  NotificationService.swift
//  OneSignalNotificationServiceExtension
//
//  Created by Murat Can KOÇ on 17.11.2023.
//

import UserNotifications

import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        if let notificationContent = request.content.mutableCopy() as? UNMutableNotificationContent {
            let updatedContent = getNotificationContentForShowing(content: notificationContent)
            self.bestAttemptContent = updatedContent
        }

        if let bestAttemptContent = bestAttemptContent {
            /* DEBUGGING: Uncomment the 2 lines below to check this extension is executing
             Note, this extension only runs when mutable-content is set
             Setting an attachment or action buttons automatically adds this */
            // print("Running NotificationServiceExtension")
            // bestAttemptContent.body = "[Modified] " + bestAttemptContent.body

            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    private func getNotificationContentForShowing(content: UNMutableNotificationContent) -> UNMutableNotificationContent {
        if content.categoryIdentifier == "timeLinePhotoNotificationTimeUpdate" {
            guard let customData = content.userInfo["custom"] as? [String: Any] else { return content }
            guard let a = customData["a"] as? [String: Any] else { return content }
            guard let additionalData = a["additionalData"] as? [String: Any] else { return content }
            guard let time = additionalData["time"] as? String else { return content }
            let localTime = convertStringToDate(datestring: time, receivedformat: "yyyy-MM-dd'T'HH:mm:ssZ", desiredFormat: "HH:mm")
            content.body = "Your Beloved Partner has changed the time of notification to \(localTime)!"
            return content
        } else {
            return content
        }
    }
    private func convertStringToDate(datestring: String, receivedformat: String, desiredFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = receivedformat

        if let date = dateFormatter.date(from: datestring) {
            dateFormatter.dateFormat = desiredFormat
            let convertedDateString = dateFormatter.string(from: date)
            return convertedDateString
        } else {
            print("Invalid time string format")
            return ""
        }
    }
}
